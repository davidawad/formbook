-- Second Circuit brief, docx engine: the brief as Word paragraphs and sections (typst: typst/ca2-<doc>.typ, latex:
-- latex/template.tex). pandoc writes the body text (paragraphs, quotations, lists, footnotes) with
-- docx/reference.docx (built by make-reference.sh); this filter writes what needs Word formatting:
--   * the cover (FRAP 32(a)(2)), the table of contents, the table of authorities, the signature block and the
--     certificates, as paragraphs with explicit spacing, indents and tabs;
--   * the heading labels (I., A., 1., a. in the Argument; A., 1., a., (1) elsewhere) and each heading's outline
--     level (Heading 1-5 styles, so the PDF has bookmarks);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of
--     every heading and citation in that PDF (the needles this filter writes), and renders again with those pages
--     (the pages file this filter reads);
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1, 2 ...), the answering brief's addendum when the sample has a `# Addendum` section (FRAP 28(f): its own
--     contents, pages Add-1 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the shared Word model lib/docx/xengine.lua, exact line
-- spacing throughout (Word sets each line in a box of that height, the baseline at 0.8 of it), the typst template's
-- pitches and spaces in twips (20 x pt). Word may paginate slightly differently from the LibreOffice PDF the page
-- numbers come from (docs/DOCX.md).
--
-- DOC selects the wording and layout of the doc type's own template: "opening", "answering" or "reply".
local DOC = "opening"
local WORD_LIMIT = ({ opening = 14000, answering = 14000, reply = 7000 })[DOC]   -- Local Rule 32.1(a)(4)

local TOC_DEPTH = 4    -- heading levels listed in the table of contents (typst: toc-depth)
local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local TAB = 720        -- half an inch (para-indent, label width), in twips
local TEXT_W = 9360    -- the text width, 6.5 in
local TAB_R = 9360     -- the right tab of the tables: at the margin
local PNUM_TOC = 720   -- the column the contents' page numbers keep to themselves (typst toc-page-col, 36 pt)
local PNUM_TOA = 1120  -- the column of the authorities' page lists (typst toa-page-col, 56 pt)
local HALF_W = 4680    -- the middle of the text
local SINGLE = 400     -- single-spaced material: 20 pt line boxes (typst pitch-single)
local DOUBLE = 628     -- body text (reference.docx Body Text): 31.4 pt (typst pitch-double, CA2-CONV-001)
local HEAD_SZ = DOC == "reply" and 28 or 32   -- section headings: 16 pt, the reply 14 pt (half points; typst)
local DOCKET = 1600    -- the cover's one-inch docket number: an 80 pt line box (typst pitch-docket)
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)
local TYPEFACE = DOC == "reply" and "Liberation Serif" or "Times New Roman"   -- the typst template's font

local stringify = pandoc.utils.stringify
local xe = require("docx.xengine")

-- No break inside a token of adjacent parentheses ("32(a)(7)(B)"): typst boxes it (lib/typst/xengine.typ) and TeX has no
-- break there, but LibreOffice breaks between ")" and "(" (Unicode line breaking) when the token does not fit; a word
-- joiner (U+2060) forbids it.
local WJ = "\u{2060}"
local function join_parens(s)
  return (s:gsub("%)%(", ")" .. WJ .. "("))
end
local function join_inlines(l)
  return l:walk({ Str = function(el) el.text = join_parens(el.text); return el end })
end
local function runs(text, o)
  return xe.runs(join_parens(text), o)
end
local function inl(x, o)
  if type(x) == "string" then return xe.inl(join_parens(x), o) end
  if x ~= nil and type(x) == "table" and x.walk then x = join_inlines(x) end
  return xe.inl(x, o)
end
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, BR, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.BR, xe.LEAD
local list_items = xe.list_items

-- Exact line spacing; single-spaced unless another pitch is given.
local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

local function dot_tabs()
  return xe.leader_tab(TAB_R)
end

-- A rule on the cover: an empty paragraph with a bottom border, `left_right` in from both margins (the 2 in rules).
local function rule(kind, before, left_right)
  local b = kind == "double"
      and '<w:pBdr><w:bottom w:val="thickThinSmallGap" w:sz="12" w:space="1" w:color="000000"/></w:pBdr>'
      or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  return para({ KEEP, b, spacing(before, 0, 120), ind(left_right or 0, nil, nil, left_right or 0) }, "")
end

-- A section's properties: its footer (rIdFtrNone, rIdFtrPage or rIdFtrAdd, written by fb render), page number format
-- and start, letter paper with 1 in margins (CA2-FORM-003).
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="676" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (1 pt high: it must not push a full page's last line on).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing).
local needles = {}
-- The fallback is the text's first words (at least 8 letters and digits): a needle that runs over a page break is not
-- found whole, because the page's footnotes come between its two halves in the PDF text.
local function opening(text)
  local out = ""
  for w in text:gmatch("%S+") do
    out = out .. norm(w)
    if #out >= 8 then break end
  end
  return out:sub(1, NEEDLE_MAX)
end

local function need(id, kind, text, context)
  local short = opening(text)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- The pages of the previous pass: id -> { page, label }. Absent on the first pass itself.
local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = label } end
  end
  f:close()
end

local function label_of(id)
  local l = labels[id]
  if l then return l.label end
  return "00" -- the first pass: a placeholder of the final width
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Words (FRAP 32(f)): the typst template's count of the markdown source, so every engine certifies the same number
-- ---------------------------------------------------------------------------

local function count_md(md)
  md = md:gsub("<!%-%-.-%-%->", " ")
  local lines = {}
  for line in (md .. "\n"):gmatch("(.-)\r?\n") do
    line = line:gsub("^%[%^[^%]]+%]:", " ")       -- footnote definition labels
    line = line:gsub("^#+[ \t]+", "")             -- heading markers
    line = line:gsub("^>[ \t]?", "")              -- quotation markers
    line = line:gsub("^[ \t]*[-*+][ \t]+", "")    -- list markers are not words
    line = line:gsub("^[ \t]*%d+[.)][ \t]+", "")
    lines[#lines + 1] = line
  end
  local s = table.concat(lines, "\n")
  s = s:gsub("%[%^[^%]]+%]", "")                 -- footnote references
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")      -- links keep their text
  s = s:gsub("\\(.)", "%1")
  s = s:gsub("%*", "")
  local n = 0
  for w in s:gmatch("%S+") do
    if w:gsub("_", "") ~= "" then n = n + 1 end
  end
  return n
end

-- The markdown body of the input file (the frontmatter dropped), up to an "# Addendum" heading.
local function source_body()
  local f = PANDOC_STATE.input_files[1] and io.open(PANDOC_STATE.input_files[1], "r")
  if not f then error("ca2.lua: cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
  local a = src:find("\n#[ \t]+[Aa][Dd][Dd][Ee][Nn][Dd][Uu][Mm][ \t]*\r?\n")
  if a then src = src:sub(1, a) end
  return src
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block of
-- the text (opening: footnote definitions taken out first; answering and reply: the text before the definitions) is
-- not a heading and (answering, reply) holds no footnote.
local function keep_last(src)
  local text = src
  if DOC == "opening" then text = ("\n" .. text):gsub("\n%[%^[^%]]+%]:[^\n]*", "\n") end
  text = text:gsub("%s+$", "")
  if DOC ~= "opening" then
    local d = text:find("\n\n%[%^[^%]]+%]:")
    if d then text = text:sub(1, d - 1) end
  end
  local cut = 1
  for e in text:gmatch("\n[ \t]*\n()") do cut = e end
  local tail = text:sub(cut)
  if tail == "" or tail:sub(1, 1) == "#" then return false end
  if DOC ~= "opening" and tail:find("[^", 1, true) then return false end
  return true
end

-- ---------------------------------------------------------------------------
-- Headings
-- ---------------------------------------------------------------------------

-- The label of a numbered heading (typst heading-label). The Argument: I. / A. / 1. / a.; elsewhere: A. / 1. / a. / (1).
local function label(level, n, arg)
  if arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    return string.char(96 + n) .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

-- The indent of a sub-heading's label, in half inches (typst label-indent): opening and answering center the
-- Argument's point headings, so their sub-headings start at the first step; the reply sets its points at the margin.
local function step(level, arg)
  if DOC == "reply" then return level - 2 end
  if arg then return level - 2 end
  return level - 1
end

local function hstyle(level)
  return style("Heading" .. level)
end

-- typst style-heading: the spacing above and below each kind of heading, in twips (21 / 15.4, 16.8 / 14,
-- 15.4 / 12.6 pt).
local SPACE = {
  section = { 420, 308 },
  point = { 336, 280 },
  sub = { 308, 252 },
}

-- A section heading (level 1, the tables, the certificates): bold capitals, centered, 16 pt.
-- `top`: the heading opens a page (no space above); `brk`: it also breaks the page (not after a section break);
-- `plain`: not an outline entry.
local function section_heading(text, top, brk, plain)
  return para({ plain and "" or hstyle(1), KEEP, brk and BREAK or "", spacing(top and 0 or SPACE.section[1], SPACE.section[2]),
    ind(0, nil, 0), jc("center") }, runs(text:upper(), { b = true, sz = HEAD_SZ }))
end

-- A body heading.
local function heading_xml(level, content, lab, arg)
  if level == 1 then return section_heading(stringify(content), false) end
  if arg and level == 2 and DOC ~= "reply" then
    return para({ hstyle(2), KEEP, spacing(SPACE.point[1], SPACE.point[2]), ind(0, nil, 0), jc("center") },
      runs(lab .. " ", { b = true }) .. inl(content, { b = true }))
  end
  local k = step(level, arg)
  local o = { b = true, i = level >= 4 }
  local text = inl(content, o)
  if DOC == "reply" and arg and level == 2 then text = inl(content, { b = true, caps = true }) end
  return para({ hstyle(level), KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. (TAB * (k + 1)) .. '"/></w:tabs>',
    spacing(SPACE.sub[1], SPACE.sub[2]), ind(TAB * (k + 1), TAB) },
    runs(lab .. "\t", o) .. text)
end

-- One row of the table of contents (typst listing-row): label, title, a dot leader from the end of the title and the
-- page. The title wraps before the page column (the right indent); the right tab sits beyond it.
local function toc_row(item)
  local title = item.level == 1 and item.title:upper() or item.title
  local left = TAB * item.step + TAB
  local lead = ""
  if item.label then lead = runs(item.label .. "\t", {}) end
  return para({ LINES, dot_tabs(),
    spacing(item.level == 1 and 168 or 98, 0), ind(left, TAB, nil, PNUM_TOC) },
    lead .. inl(item.content or title, {}) .. runs(LEAD .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities
-- ---------------------------------------------------------------------------

local GROUPS = {
  { { "case" }, "Cases:" },
  { { "constitution" }, "Constitutional Provisions:" },
  { { "statute" }, "Statutes:" },
  { { "regulation" }, "Regulations:" },
  { { "rule" }, "Rules:" },
  { { "other" }, "Other Authorities:" },
}
if DOC == "reply" then
  GROUPS = {
    { { "case" }, "Cases:" },
    { { "constitution" }, "Constitutional Provisions:" },
    { { "statute" }, "Statutes:" },
    { { "regulation", "rule" }, "Rules & Regulations:" },
    { { "other" }, "Other Authorities:" },
  }
end

local occurrences = {} -- the authority links, in document order: { key, index }

-- Sort key as typst's: case-insensitive, digit runs compared by value.
local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  s = s:lower():gsub("%d+", function(d) return string.rep("0", math.max(0, 10 - #d)) .. d end)
  return (s:gsub("[^a-z0-9 ]", ""))
end

local function in_group(g, kind)
  for _, k in ipairs(g[1]) do if k == kind then return true end end
  return false
end

local function toa_rows(authorities)
  local used = {}
  for _, o in ipairs(occurrences) do used[o.key] = true end
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and a.kind and in_group(g, stringify(a.kind)) then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      -- the group title; the first one carries the column heading "Page(s)" at the right margin (typst toa-section)
      local head = runs(g[2], { b = true })
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = DOC ~= "reply" }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TAB_R .. '"/></w:tabs>',
        spacing(#out == 0 and 280 or 392, 56) }, head)
      for _, m in ipairs(members) do
        -- the distinct pages of the authority, in document order (typst: the printed labels, in document order)
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local lab = l and l.label or ("00" .. o.index)
            if not seen[lab] then
              seen[lab] = true
              pages[#pages + 1] = l and l.label or "00"
            end
          end
        end
        local list
        local list_w = 0
        if #pages >= PASSIM then
          list = runs("passim", { i = true })
        else
          local s = table.concat(pages, ", ")
          list = runs(s, {})
          -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): Times New
          -- Roman digits are 0.5 em (140 twips at 14 pt), a comma and a space 0.25 em each
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 140 or 70) end
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = stringify(m.a.kind) == "case" }) .. runs(",", {}) .. BR
        end
        out[#out + 1] = para({ LINES, dot_tabs(), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. runs(LEAD, {}) .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body)
-- ---------------------------------------------------------------------------

local function need_meta(meta, k)
  if meta[k] == nil then error("ca2.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function lines_of(g, phone, phone_italic)
  local ls = {}
  for _, n in ipairs(g.names or {}) do ls[#ls + 1] = { x = inl(n, {}), first = 0 } end
  for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = { x = inl(l, { i = true }), first = 140 } end
  if phone then ls[#ls + 1] = { x = inl(phone, { i = phone_italic }), first = 140 } end
  return ls
end

local function cover(meta)
  local sides = need_meta(meta, "caption")
  local counsel = need_meta(meta, "counsel")
  -- The gap between the cover's parts is 14 pt (typst: the largest of 1, 0.8, 0.6 ... em at which the cover fits one
  -- page, which is 1 em for the samples); the parts that do not fit push nothing: the cover is one page.
  local gap = 280
  local small = 84
  -- the cover's line boxes: single spacing; the reply's closer (typst pitch-cover, 17 pt), or its four counsel groups
  -- would push the cover onto a second page
  local pitch = DOC == "reply" and 340 or SINGLE
  local function spacing(before, after, line) return xe.spacing(before, after, line or pitch) end
  local out = {}
  local function add(x) out[#out + 1] = x end
  local function center(x, before, o)
    add(para({ KEEP, spacing(before or 0, 0), ind(0, nil, 0), jc("center") }, x))
  end
  local rules = DOC ~= "reply"
  add(para({ KEEP, spacing(0, 0, DOCKET), ind(0, nil, 0), jc("center") },
    inl(meta.case_number, { b = DOC ~= "reply", sz = 144 })))
  if DOC == "opening" then
    add(rule("double", gap))
    center(runs("IN THE UNITED STATES COURT OF APPEALS", { b = true }) .. BR .. runs("FOR THE SECOND CIRCUIT", { b = true }), gap)
  elseif DOC == "answering" then
    center(runs("IN THE", { b = true }) .. BR .. runs("United States Court of Appeals for the Second Circuit", { b = true }), gap)
  else
    center(runs("In the United States Court of Appeals for the Second Circuit", {}), gap)
  end
  if rules then add(rule("short", gap, 3240)) end
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do center(inl(n, {}), (k == 1 and i == 1) and gap or 0) end
    if DOC == "opening" then
      add(para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 0) }, inl(side.designation, {})))
    elseif DOC == "answering" then
      center(inl(side.designation, {}), 0)
    else
      add(para({ KEEP, spacing(0, 0), ind(0, nil, 0), jc("right") }, inl(side.designation, {})))
    end
    if i < #sides then
      local sep = ({ opening = "-v-", answering = "\u{2013} v. \u{2013}", reply = "v." })[DOC]
      add(para({ KEEP, spacing(small, small), ind(0, nil, 0), jc("center") }, runs(sep, {})))
    end
  end
  if rules then add(rule("short", gap, 3240)) end
  if DOC == "reply" then
    local x = inl(need_meta(meta, "proceeding"), { caps = true })
    if meta.district_court_case or meta.judge then
      local parts = {}
      if meta.district_court_case then parts[#parts + 1] = "No. " .. stringify(meta.district_court_case) end
      if meta.judge then parts[#parts + 1] = stringify(meta.judge) end
      x = x .. BR .. runs(table.concat(parts, ", "):upper(), {})
    end
    center(x, gap)
  else
    center(inl(need_meta(meta, "proceeding"), {}), gap)
    if DOC == "opening" and (meta.district_court_case or meta.judge) then
      local x = ""
      if meta.district_court_case then x = runs("D.C. No. ", {}) .. inl(meta.district_court_case, {}) end
      if meta.district_court_case and meta.judge then x = x .. runs("; ", {}) end
      if meta.judge then x = x .. inl(meta.judge, {}) end
      center(x, 0)
    elseif DOC == "answering" and meta.district_court_case then
      local x = runs("Case No. ", {}) .. inl(meta.district_court_case, {})
      if meta.judge then x = x .. runs(" (", {}) .. inl(meta.judge, {}) .. runs(")", {}) end
      center(x, 0)
    end
  end
  if rules then add(rule("short", gap, 3240)) end
  center(inl(meta.brief_title, { b = true, caps = true }), gap)
  if rules then add(rule("short", gap, 3240)) end
  -- counsel (FRAP 32(a)(2)(F)): name, office address and telephone number
  if DOC == "reply" then
    -- two columns (typst grid 1fr 1fr, a half-inch gutter): a borderless table; 15.4 pt between groups
    local half = math.ceil(#counsel / 2)
    local function column(first, last)
      local xml = {}
      for gi = first, last do
        for li, l in ipairs(lines_of(counsel[gi], counsel[gi].phone, false)) do
          xml[#xml + 1] = para({ spacing((li == 1 and gi > first) and 308 or 0, 0), ind(0, nil, l.first) }, l.x)
        end
      end
      return table.concat(xml)
    end
    local cw = (TEXT_W - TAB) // 2
    local cell = function(x, w, right)
      return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/><w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="'
        .. right .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. x .. "</w:tc>"
    end
    add(para({ KEEP, spacing(gap, 0, 20) }, ""))
    add('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
      .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
      .. '</w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="' .. (cw + TAB) .. '"/><w:gridCol w:w="' .. cw
      .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(column(1, half), cw + TAB, TAB)
      .. cell(column(half + 1, #counsel), cw, 0) .. "</w:tr></w:tbl>")
    if meta.counsel_for then
      add(para({ spacing(gap, 0), ind(0, nil, 0), jc("center") }, inl(meta.counsel_for, { i = true })))
    end
  else
    local left = DOC == "opening" and HALF_W or 3276   -- 50 % / 35 % of the text width (typst pad)
    for gi, g in ipairs(counsel) do
      local phone = gi == #counsel and need_meta(meta, "phone") or nil
      for li, l in ipairs(lines_of(g, phone, true)) do
        local before = li == 1 and (gi == 1 and gap or 140) or 0
        add(para({ LINES, spacing(before, 0), ind(left, nil, l.first) }, l.x))
      end
    end
  end
  if DOC == "opening" then add(rule("double", gap)) end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates (typst signature-block, form-sig-line, certificates)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  local function add(x) out[#out + 1] = x end
  local left = DOC == "answering" and 3276 or HALF_W
  local first = 392
  if DOC == "answering" then
    local x = meta.date and (runs("Dated: ", {}) .. inl(meta.date, {})) or ""
    if meta.city then x = x .. (x ~= "" and BR or "") .. inl(meta.city, {}) end
    if x ~= "" then add(para({ KEEP, spacing(first, 0), ind(0, nil, 0) }, x)); first = 336 end
  elseif DOC == "reply" then
    add(para({ KEEP, spacing(first, 0), ind(0, nil, 0) }, runs("Dated: ", {}) .. inl(need_meta(meta, "date"), {})))
    first = 336
  end
  add(para({ KEEP, spacing(first, 0), ind(left, nil, 0) }, runs("Respectfully submitted,", {})))
  local sigline = (DOC == "opening" and "s/ " or "/s/ ") .. signer
  add(para({ KEEP, spacing(336, 0), ind(left, nil, 0) }, runs(sigline, {})))
  add(para({ KEEP, spacing(0, 0), ind(left, nil, 0) }, runs(DOC == "answering" and signer or signer:upper(), {})))
  local ls = sig.lines or {}
  for i, l in ipairs(ls) do
    local last = i == #ls and not (DOC == "opening" and meta.date) and not (DOC == "reply" and meta.counsel_for)
    add(para({ last and LINES or KEEP, spacing(0, 0), ind(left, nil, DOC == "reply" and 0 or 140) }, inl(l, { i = true })))
  end
  if DOC == "reply" and meta.counsel_for then
    add(para({ LINES, spacing(168, 0), ind(left, nil, 0) }, inl(meta.counsel_for, { i = true })))
  end
  if DOC == "opening" and meta.date then
    add(para({ LINES, spacing(224, 0), ind(0, nil, 0) }, inl(meta.date, {})))
  end
  return table.concat(out)
end

-- The signature under a certificate (typst form-sig-line): two columns, "s/ Name" over "Signature" at the margin and
-- the date over "Date" in the right one (the columns are 1fr with a 1 em gutter: the right one starts 241 pt in).
local FORM_COL = 4820
local function form_signature(meta, signer, date)
  if DOC == "reply" then
    return para({ KEEP, spacing(448, 0), ind(0, nil, 0) }, runs("Dated: ", {}) .. inl(need_meta(meta, "date"), {}))
      .. para({ KEEP, spacing(336, 0), ind(0, nil, 0) }, runs("/s/ " .. signer, {}))
      .. para({ LINES, spacing(0, 0), ind(0, nil, 0) }, runs(signer, {}))
  end
  local tab = '<w:tabs><w:tab w:val="left" w:pos="' .. FORM_COL .. '"/></w:tabs>'
  local d = date and inl(date, {}) or ""
  return para({ KEEP, tab, spacing(448, 0), ind(0, nil, 0) },
      runs((DOC == "opening" and "s/ " or "/s/ ") .. signer .. "\t", {}) .. d)
    .. para({ LINES, tab, spacing(0, 0), ind(0, nil, 0) }, runs("Signature\tDate", {}))
end

local function text_para(body, after)
  return para({ spacing(0, after or 280), ind(0, nil, 0) }, body)
end

local function compliance(meta, words)
  local n = group_digits(words)
  local t
  if DOC == "opening" then
    t = { "1. This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) and Local Rule 32.1(a) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f): this document contains " .. n .. " words.",
      "2. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because: this document has been prepared in a proportionally spaced typeface using " .. TYPEFACE .. " in 14-point type." }
  elseif DOC == "answering" then
    local face = meta.typeface and stringify(meta.typeface) or TYPEFACE
    local using = meta.software and (stringify(meta.software) .. " in 14-point " .. face) or ("14-point " .. face)
    t = { "This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) and Local Rule 32.1(a)(4)(A) because this brief contains " .. n .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f).",
      "This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because this brief has been prepared in a proportionally spaced typeface using " .. using .. "." }
  else
    t = { "This brief complies with the type-volume limitation set forth in Local Rule 32.1(a)(4)(B) because it contains " .. n .. " words, excluding the parts of the brief exempted by Federal Rule of Appellate Procedure 32(f).",
      "This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and the type-style requirements of Federal Rule of Appellate Procedure 32(a)(6) because it was prepared in a proportionally spaced typeface using " .. stringify(need_meta(meta, "typeface_software")) .. " in " .. stringify(need_meta(meta, "typeface")) .. " 14-point font." }
  end
  local out = { section_heading("Certificate of Compliance", true, true, DOC ~= "answering") }
  for _, x in ipairs(t) do out[#out + 1] = text_para(runs(x, {})) end
  out[#out + 1] = form_signature(meta, stringify(need_meta(meta, "signature").signer), meta.date)
  return table.concat(out)
end

local function service(meta)
  local svc = need_meta(meta, "service")
  local out = { section_heading("Certificate of Service", true, true, DOC ~= "answering") }
  local signer = stringify(need_meta(meta, "signature").signer)
  if DOC == "opening" then
    out[#out + 1] = text_para(runs("I certify that on ", {}) .. inl(svc.date, {}) .. runs(", I served one copy of the foregoing ", {})
      .. inl(meta.brief_title, {}) .. runs(" on the following counsel of record, by the method stated:", {}), 0)
    for _, p in ipairs(svc.parties or {}) do
      out[#out + 1] = para({ LINES, spacing(196, 0), ind(TAB, nil, 0) },
        inl(p.name, {}) .. BR .. inl(p.address, {}) .. BR .. inl(p.method, { i = true }))
    end
    out[#out + 1] = form_signature(meta, svc.signer and stringify(svc.signer) or signer, svc.date)
  elseif DOC == "answering" then
    out[#out + 1] = text_para(runs("I hereby certify that on ", {}) .. inl(need_meta(meta, "date"), {})
      .. runs(", a true and correct copy of the foregoing was served via ", {}) .. inl(svc.method or "ACMS", {})
      .. runs(" to all counsel of record or parties pro se.", {}))
    local unreg = svc.unregistered or {}
    if #unreg > 0 then
      out[#out + 1] = text_para(runs("The following case participants are NOT registered for electronic filing and were served by mail or another method (name and address):", {}), 0)
      for _, u in ipairs(unreg) do
        out[#out + 1] = para({ LINES, spacing(196, 0), ind(TAB, nil, 0) }, inl(u.name, {}) .. runs(", ", {}) .. inl(u.address, {}))
      end
    end
    out[#out + 1] = form_signature(meta, signer, meta.date)
  else
    out[#out + 1] = text_para(runs("I hereby certify that, on ", {}) .. inl(need_meta(meta, "date"), {})
      .. runs(", I electronically filed the foregoing ", {}) .. inl(meta.brief_title, {})
      .. runs(" with the United States Court of Appeals for the Second Circuit using the Court\u{2019}s electronic filing system, which will serve copies on all registered counsel.", {}))
    out[#out + 1] = form_signature(meta, signer, nil)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Citations, in document order (the needles of the table of authorities)
-- ---------------------------------------------------------------------------

local scan_blocks

local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local key = el.target:sub(5)
      occurrences[#occurrences + 1] = { key = key, index = #occurrences + 1 }
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      need("T:" .. #occurrences, in_note and "N" or "B", stringify(el.content), stringify(rest))
    elseif el.t == "Note" then
      scan_blocks(el.content, true)
    elseif el.content and type(el.content) ~= "string" and el.t ~= "Link" then
      scan_inlines(el.content, in_note)
    end
  end
end

scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" or b.t == "Div" then
      scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

local function strip_links(blocks)
  return pandoc.Pandoc(blocks):walk({
    Link = function(el) return el.content end,
    Inlines = xe.inlines,
    Str = function(el) el.text = join_parens(el.text); return el end,
  }).blocks
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- The text a heading's needle continues with: the start of the block after it, as printed (a heading with its label).
local function next_text(blocks, i, printed)
  local b = blocks[i + 1]
  if not b then return "" end
  return (printed[i + 1] or stringify(b)):sub(1, 40)
end

-- Markers such as (A) that open a paragraph are text, as written (typst's markdown reader knows only "1." and "1)"
-- as list markers); pandoc reads them as list items, which would be renumbered.
local function marker(st, n)
  if st == "UpperAlpha" then return string.char(64 + n)
  elseif st == "LowerAlpha" then return string.char(96 + n)
  elseif st == "UpperRoman" then return roman(n)
  elseif st == "LowerRoman" then return roman(n):lower()
  end
  return tostring(n)
end

local function ordered_list(l)
  local a = l.listAttributes
  if (a.style == "Decimal" or a.style == "DefaultStyle") and a.delimiter ~= "TwoParens" then return nil end
  local out = {}
  for i, item in ipairs(l.content) do
    local lab = marker(a.style, a.start + i - 1)
    if a.delimiter == "TwoParens" then lab = "(" .. lab .. ")"
    elseif a.delimiter == "OneParen" then lab = lab .. ")"
    else lab = lab .. "." end
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local x = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
      x:extend(first.content)
      item[1] = pandoc.Para(x)
    end
    for _, b in ipairs(item) do out[#out + 1] = b end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "signature" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  doc = doc:walk({ OrderedList = ordered_list })
  local words = count_md(source_body())
  if words > WORD_LIMIT then
    error("ca2.lua: the brief has " .. words .. " words; Local Rule 32.1(a)(4) allows " .. WORD_LIMIT)
  end

  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles).
  local headings = {}
  local body = {}
  local in_arg = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n = 0
  -- the body and, in the answering brief, the addendum (from a level-1 heading "Addendum"; typst splits it off too)
  local blocks, add_blocks = {}, nil
  for _, b in ipairs(doc.blocks) do
    if add_blocks then
      add_blocks[#add_blocks + 1] = b
    elseif DOC == "answering" and b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "addendum" then
      add_blocks = {}
    else
      blocks[#blocks + 1] = b
    end
  end
  -- the printed text of every heading (its label and title), for the needles
  local printed, labs = {}, {}
  do
    local c, arg = { 0, 0, 0, 0, 0, 0 }, false
    for i, b in ipairs(blocks) do
      if b.t == "Header" and b.level <= 5 then
        c[b.level] = c[b.level] + 1
        for k = b.level + 1, 6 do c[k] = 0 end
        if b.level == 1 then arg = norm(stringify(b.content)) == "argument" end
        labs[i] = b.level == 1 and "" or label(b.level, c[b.level], arg)
        printed[i] = labs[i] .. " " .. stringify(b.content)
      end
    end
  end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level > 5 then error("ca2.lua: headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then in_arg = norm(stringify(b.content)) == "argument" end
      local lab = labs[i]
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", lab .. stringify(b.content), next_text(blocks, i, printed))
      if b.level <= TOC_DEPTH then
        local point = in_arg and b.level == 2 and DOC ~= "reply"
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = stringify(b.content), content = b.level > 1 and b.content or nil,
          step = b.level == 1 and 0 or (point and 0 or step(b.level, in_arg)) }
      end
      local x = heading_xml(b.level, b.content, lab, in_arg)
      -- the body opens a section (a new page): Word keeps space above there, typst drops it at the top of a page
      if #body == 0 then x = x:gsub('w:before="%d+"', 'w:before="0"', 1) end
      body[#body + 1] = raw(x)
    else
      scan_blocks({ b }, false)
      for _, x in ipairs(list_items(b)) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("ca2.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  -- the table of authorities' needle goes on with its first group title (the contents list the same title)
  for _, g in ipairs(GROUPS) do
    local used = false
    for _, o in ipairs(occurrences) do
      local a = authorities[o.key]
      if a and a.kind and in_group(g, stringify(a.kind)) then used = true end
    end
    if used then
      for _, n in ipairs(needles) do
        if n.id == "S:toa" then n.needle = norm("Table of Authorities " .. g[2]):sub(1, NEEDLE_MAX) end
      end
      break
    end
  end
  body = strip_links(body)
  -- The last paragraph is not broken and stays with the signature block (typst: one unbreakable block, unless the
  -- brief's last markdown block is a heading or holds footnotes).
  local last = body[#body]
  if keep_last(source_body()) and last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end

  local svc = meta.service and meta.service.certificate
  local with_service = DOC == "opening" or svc == true or (svc ~= nil and stringify(svc) == "true")
  if DOC == "answering" then
    need("H:compliance", "B", "Certificate of Compliance", "This brief complies")
    if with_service then need("H:service", "B", "Certificate of Service", "I hereby certify") end
  end
  -- The addendum (FRAP 28(f); typst: its heading, its own contents of the level 2 headings, a page break, the text;
  -- pages Add-1 ... from its heading): level 2 headings bold at the margin (typst's unnumbered sub-headings).
  local add_toc, add_body = {}, {}
  if add_blocks then
    need("A:start", "B", "Addendum Table of Contents", "")
    for i, b in ipairs(add_blocks) do
      if b.t == "Header" then
        if b.level ~= 2 then error("ca2.lua: in the addendum only level 2 headings are supported") end
        local id = "A:" .. (#add_toc + 1)
        need(id, "B", stringify(b.content), next_text(add_blocks, i, {}))
        add_toc[#add_toc + 1] = { id = id, level = 2, title = stringify(b.content), content = b.content, step = 0 }
        add_body[#add_body + 1] = raw(para({ KEEP, spacing(#add_body == 0 and 0 or 336, 252), ind(0, nil, 0) },
          inl(b.content, { b = true })))
      else
        scan_blocks({ b }, false)
        for _, x in ipairs(list_items(b)) do add_body[#add_body + 1] = x end
      end
    end
    for _, o in ipairs(occurrences) do
      if not authorities[o.key] then
        error("ca2.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
      end
    end
    add_body = strip_links(add_body)
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: each section starts at the page of a needle (format, prefix)
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  if add_blocks then nl[#nl + 1] = "#section\tA:start\tdecimal\tAdd-" end
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", add_blocks and sect_pr("rIdFtrAdd", "decimal", 1) or sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): the table of contents, the table of authorities
  add(raw(section_heading("Table of Contents", true, false, true)))
  -- "Page" over the page column, 1 pt in: LibreOffice lets the underlined word overhang its advance
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, 0, 20), jc("right") }, runs("Page", { b = true, u = DOC ~= "reply" }))))
  local items = {}
  if DOC ~= "reply" then items[#items + 1] = { id = "S:toa", level = 1, title = "Table of Authorities", step = 0 } end
  for _, h in ipairs(headings) do items[#items + 1] = h end
  if DOC == "answering" then
    items[#items + 1] = { id = "H:compliance", level = 1, title = "Certificate of Compliance", step = 0 }
    if with_service then items[#items + 1] = { id = "H:service", level = 1, title = "Certificate of Service", step = 0 } end
    if add_blocks then items[#items + 1] = { id = "A:start", level = 1, title = "Addendum", step = 0 } end
  end
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true, DOC == "reply")))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...), the signature, and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(compliance(meta, words)))
  if with_service then add(raw(service(meta))) end

  -- Section 4: the addendum (Add-1 ...): its heading and contents, then its text from a new page
  if add_blocks then
    add(section("rIdFtrPage", "decimal", 1))
    add(raw(section_heading("Addendum", true, false)))
    add(raw(section_heading("Table of Contents", false, false, true)))
    for _, it in ipairs(add_toc) do add(raw(toc_row(it))) end
    local first = add_body[1]
    if first and first.t == "RawBlock" then
      first.text = first.text:gsub("<w:pPr>", "<w:pPr>" .. BREAK, 1)
    else
      add(raw(para({ BREAK, spacing(0, 0, 20) }, "")))
    end
    for _, x in ipairs(add_body) do add(x) end
  end

  doc.blocks = out
  doc.meta.date = nil -- the date is printed by the signature blocks only, not by pandoc at the top
  doc.meta.title = nil
  return doc
end
