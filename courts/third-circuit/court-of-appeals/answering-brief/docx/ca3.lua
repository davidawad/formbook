-- U.S. Court of Appeals for the Third Circuit: pandoc filter for the docx engine (one copy per doc type).
-- The same content and layout as the typst template of this doc type (typst/ca3-*.typ) and the LaTeX engine
-- (latex/template.tex, latex/ca3.lua), from the same markdown contract (../README.md). pandoc writes the body text
-- (paragraphs, quotations, lists, footnotes) with docx/reference.docx (built by make-reference.sh); this filter writes
-- what needs Word formatting:
--   * the cover (FRAP 32(a)(2)), the disclosure statement, the table of contents, the table of authorities, the
--     signature block and the certificates, as paragraphs with explicit spacing, indents and tabs;
--   * the heading labels (I., A., 1., a.; in the answering and reply briefs A., 1., a., (1) outside the Argument) and
--     each heading's outline level (Heading 1-5 styles, so the PDF has bookmarks);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of
--     every heading and citation in that PDF (the needles this filter writes), and renders again with those pages
--     (the pages file this filter reads);
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1, 2 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the shared Word model lib/docx/xengine.lua, exact line
-- spacing throughout (Word sets each line in a box of that height, the baseline at 0.8 of it), the typst template's
-- pitches and spaces in twips (20 x pt). Word may paginate slightly differently from the LibreOffice PDF the page
-- numbers come from (docs/DOCX.md).
-- Nothing here is case-specific. The only line that differs between the copies is TYPE.

local TYPE = "answering" -- "opening" | "answering" | "reply"

local LIMIT = ({ opening = 13000, answering = 13000, reply = 6500 })[TYPE]
local SCHEME = (TYPE == "opening") and "opening" or "argument"
-- The typst template's face (reference.docx sets it; the certificate of compliance names it).
local FACE = ({ opening = "Times New Roman", answering = "TeX Gyre Schola", reply = "Times New Roman" })[TYPE]

local TOC_DEPTH = 4    -- heading levels listed in the table of contents (typst: toc-depth)
local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local TAB = 720        -- half an inch (para-indent, label width), in twips
local TEXT_W = 9356    -- the text width: 6.5 in less 4 twips (RIGHT_PAD)
-- LibreOffice rounds every glyph advance to whole twips, so its lines come out up to 0.36 pt narrower than typst's
-- (never wider): the right margin is 4 twips (0.2 pt) wider, which centres that drift on the margin typst breaks at.
local RIGHT_PAD = 4
local TAB_R = 9356     -- the right tab of the tables: at the margin
local PNUM_TOC = 720   -- the column the contents' page numbers keep to themselves (typst toc-page-col, 36 pt)
local PNUM_TOA = 1120  -- the column of the authorities' page lists (typst toa-page-col, 56 pt)
local HALF_W = 4680    -- the middle of the text (typst half-width)
-- typst pitch-single and pitch-double: 20 / 31.4 pt (Times New Roman), 20.4 / 31.8 pt (TeX Gyre Schola)
local SINGLE = TYPE == "answering" and 408 or 400
local DOUBLE = TYPE == "answering" and 636 or 628
local HEAD_SZ = TYPE == "opening" and 28 or 32   -- section headings: 14 pt, the answering and reply briefs 16 pt
-- their line box: single, but 24 pt for 16 pt Schola (typst pitch-heading: LibreOffice sets its 1.21 em ascent inside it)
local HEAD_LINE = TYPE == "answering" and 480 or SINGLE
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)

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
local KEEP, LINES, BREAK, BR = xe.KEEP, xe.LINES, xe.BREAK, xe.BR
-- Before the leader tab of a table row (typst listing-row: the text and 0.75 em must fit before the page column).
-- LibreOffice keeps the last word on the line only if the no-break spaces before the right tab and another third of
-- their em fit before the right indent (measured: the threshold moves with the size of the spaces' run, not with the
-- page number); so two no-break spaces at 12.5 pt (2 x 0.25 + 1/3 of 12.5 pt = 10.4 pt; Schola: 0.278 em spaces, 12 pt,
-- 10.7 pt) stand for typst's 10.5 pt. They keep the leader off the last word and go with it when it wraps.
local LEAD_SZ = FACE == "TeX Gyre Schola" and 24 or 25
local LEAD = '<w:r><w:rPr><w:sz w:val="' .. LEAD_SZ .. '"/><w:szCs w:val="' .. LEAD_SZ ..
  '"/></w:rPr><w:t xml:space="preserve">\u{00A0}\u{00A0}</w:t></w:r><w:r><w:tab/></w:r>'
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

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, written by fb render), page number format and
-- start, letter paper with 1 in margins (L.A.R. 32.1(b)).
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="' .. (1440 + RIGHT_PAD) .. '" w:bottom="1440" w:left="1440" '
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

local function need_meta(meta, k)
  if meta[k] == nil then error("ca3-" .. TYPE .. ": missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function is_true(x)
  return x == true or (x ~= nil and stringify(x) == "true")
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
  if not f then error("ca3-" .. TYPE .. ": cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
  local a = src:find("\n#[ \t]+[Aa][Dd][Dd][Ee][Nn][Dd][Uu][Mm][ \t]*\r?\n")
  if a then src = src:sub(1, a) end
  return src
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block (of
-- the text from the Statement of the Case on, in the opening brief) is not a heading and not a footnote definition.
local function keep_last(src)
  local text = src
  if TYPE == "opening" then
    local s = ("\n" .. text):lower():find("\n#[ \t]+statement of the case[ \t]*\n")
    if s then text = text:sub(s) end
  end
  text = text:gsub("%s+$", "")
  local cut = 1
  for e in text:gmatch("\n[ \t]*\n()") do cut = e end
  local tail = text:sub(cut)
  return tail ~= "" and tail:sub(1, 1) ~= "#" and tail:sub(1, 2) ~= "[^"
end

-- ---------------------------------------------------------------------------
-- Headings
-- ---------------------------------------------------------------------------

-- The label of a numbered heading (typst heading-label).
local function label(level, n, arg)
  if SCHEME == "opening" or arg then
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

-- The indent of a sub-heading's label, in half inches (typst label-indent).
local function step(level, arg)
  if SCHEME == "opening" or arg then return level - 2 end
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

-- A section heading (level 1, the tables, the certificates): bold capitals, centered.
-- `top`: the heading opens a page (no space above); `brk`: it also breaks the page (not after a section break);
-- `plain`: not an outline entry.
local function section_heading(text, top, brk, plain)
  return para({ plain and "" or hstyle(1), KEEP, brk and BREAK or "", spacing(top and 0 or SPACE.section[1], SPACE.section[2], HEAD_LINE),
    ind(0, nil, 0), jc("center") }, runs(text:upper(), { b = true, sz = HEAD_SZ }))
end

-- A body heading.
local function heading_xml(level, content, lab, arg)
  if level == 1 then return section_heading(stringify(content), false) end
  if arg and level == 2 then
    return para({ hstyle(2), KEEP, spacing(SPACE.point[1], SPACE.point[2]), ind(0, nil, 0), jc("center") },
      runs(lab .. " ", { b = true }) .. inl(content, { b = true }))
  end
  local k = step(level, arg)
  local o = { b = true, i = level >= 4 }
  return para({ hstyle(level), KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. (TAB * (k + 1)) .. '"/></w:tabs>',
    spacing(SPACE.sub[1], SPACE.sub[2]), ind(TAB * (k + 1), TAB) },
    runs(lab .. "\t", o) .. inl(content, o))
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
    lead .. inl(item.content or title, {}) .. LEAD .. runs(label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

local occurrences = {} -- the authority links, in document order: { key, index }

-- Sort key as typst's: the name and citation, lower case, letters, digits and spaces only.
local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function toa_rows(authorities)
  local used = {}
  for _, o in ipairs(occurrences) do used[o.key] = true end
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and a.kind and stringify(a.kind) == g[1] then
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
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
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
          -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): digits are
          -- 0.5 em in Times New Roman (140 twips at 14 pt), 0.556 em in Schola (156), a comma 0.25 / 0.278 em and the
          -- space 0.25 / 0.278 em
          local digit, other = 140, 70
          if FACE == "TeX Gyre Schola" then digit, other = 156, 78 end
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and digit or other) end
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = stringify(m.a.kind) == "case" }) .. runs(",", {}) .. BR
        end
        out[#out + 1] = para({ LINES, dot_tabs(), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. LEAD .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body)
-- ---------------------------------------------------------------------------

-- One counsel group: names, then the lines half an em in (italic in the answering and reply briefs); the last group
-- carries the phone (and, in the opening brief, the party counsel act for).
local function lines_of(meta, g, last)
  local italic = TYPE ~= "opening"
  local ls = {}
  for _, n in ipairs(g.names or {}) do ls[#ls + 1] = { x = inl(n, {}), first = 0 } end
  for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = { x = inl(l, { i = italic }), first = 140 } end
  if last then
    ls[#ls + 1] = { x = inl(need_meta(meta, "phone"), { i = italic }), first = 140 }
    if TYPE == "opening" and meta.counsel_for then ls[#ls + 1] = { x = inl(meta.counsel_for, { i = true }), first = 140 } end
  end
  return ls
end

-- The height of cover paragraphs, estimated (twips): the space above and the lines of each, a line holding about
-- (width / 150 twips) characters (0.54 em at 14 pt: a little wider than the average letter, so the estimate is safe).
local function height(xml)
  local h = 0
  for p in xml:gmatch("<w:p>.-</w:p>") do
    local before = tonumber(p:match('w:before="(%d+)"') or "0")
    local line = tonumber(p:match('w:line="(%d+)"') or tostring(SINGLE))
    local left = tonumber(p:match('w:left="(%d+)"') or "0")
    local right = tonumber(p:match('w:right="(%d+)"') or "0")
    local text = ""
    for t in p:gmatch("<w:t[^>]*>([^<]*)</w:t>") do text = text .. t end
    local _, brs = p:gsub("<w:br/>", "")
    local n = math.max(1, math.ceil(utf8.len(text) * 150 / (TEXT_W - left - right))) + brs
    h = h + before + n * line
  end
  return h
end

-- The cover is one page (typst: the largest of 1, 0.8, 0.6 ... em between its parts at which it fits): the largest
-- gap whose estimated height leaves a line to spare.
local build_cover
local function cover(meta)
  for _, gap in ipairs({ 280, 224, 168, 126, 84, 56, 28, 0 }) do
    local blocks, h = build_cover(meta, gap)
    if h <= 12960 - 2 * SINGLE or gap == 0 then return blocks end
  end
end

build_cover = function(meta, gap)
  local sides = need_meta(meta, "caption")
  local counsel = need_meta(meta, "counsel")
  local small = math.floor(gap * 0.3)
  local extra = 0 -- the estimated height of the counsel table (the reply's two columns)
  local out = {}
  local function add(x) out[#out + 1] = x end
  local function center(x, before)
    add(para({ KEEP, spacing(before or 0, 0), ind(0, nil, 0), jc("center") }, x))
  end
  center(runs("No. ", { b = true }) .. inl(need_meta(meta, "case_number"), { b = true }), 0)
  add(rule("double", gap))
  if TYPE == "opening" then
    center(runs("IN THE UNITED STATES COURT OF APPEALS FOR THE\u{00A0}THIRD\u{00A0}CIRCUIT", { b = true }), gap)
  else
    center(runs("IN THE UNITED STATES COURT OF APPEALS", { b = true }) .. BR .. runs("FOR THE THIRD CIRCUIT", { b = true }), gap)
  end
  add(rule("short", gap, 3240))
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do center(inl(n, {}), (k == 1 and i == 1) and gap or 0) end
    add(para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 0) }, inl(side.designation, {})))
    if i < #sides then
      add(para({ KEEP, spacing(small, small), ind(0, nil, 0), jc("center") }, runs("v.", {})))
    end
  end
  add(rule("short", gap, 3240))
  center(inl(need_meta(meta, "proceeding"), {}), gap)
  if TYPE == "opening" then
    if meta.district_court_case then center(runs("(", {}) .. inl(meta.district_court_case, {}) .. runs(")", {}), 0) end
    if meta.judge then center(runs("(", {}) .. inl(meta.judge, {}) .. runs(")", {}), 0) end
  elseif TYPE == "answering" then
    if meta.district_court_case or meta.judge then
      local x = ""
      if meta.district_court_case then x = runs("D.C. No. ", {}) .. inl(meta.district_court_case, {}) end
      if meta.district_court_case and meta.judge then x = x .. runs("; ", {}) end
      if meta.judge then x = x .. inl(meta.judge, {}) end
      center(x, 0)
    end
  else
    if meta.district_court_case then center(runs("No. ", {}) .. inl(meta.district_court_case, {}), 0) end
    if meta.judge then center(inl(meta.judge, {}), 0) end
  end
  add(rule("short", gap, 3240))
  center(inl(meta.brief_title, { b = true, caps = true }), gap)
  if TYPE == "opening" and meta.appendix then center(inl(meta.appendix, {}), 0) end
  add(rule("short", gap, 3240))
  -- counsel (FRAP 32(a)(2)(F)): name, office address and telephone number
  if TYPE == "reply" and #counsel > 1 then
    -- two to a row across the full width (typst grid: 1fr 1fr, 14 pt between the columns and the rows): a
    -- borderless table
    local cw = (TEXT_W - 280) // 2
    local function column(gi)
      if not counsel[gi] then return para({ spacing(0, 0) }, "") end
      local xml = {}
      for _, l in ipairs(lines_of(meta, counsel[gi], gi == #counsel)) do
        xml[#xml + 1] = para({ spacing(0, 0), ind(0, nil, l.first) }, l.x)
      end
      return table.concat(xml)
    end
    local cell = function(x, w, right)
      return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/><w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="'
        .. right .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. x .. "</w:tc>"
    end
    add(para({ KEEP, spacing(gap, 0, 20) }, ""))
    local rows = {}
    for r = 1, #counsel, 2 do
      if r > 1 then
        rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="280" w:hRule="exact"/></w:trPr>' .. cell(para({ spacing(0, 0, 20) }, ""), cw + 280, 280)
          .. cell(para({ spacing(0, 0, 20) }, ""), cw, 0) .. "</w:tr>"
        extra = extra + 280
      end
      local n1 = #lines_of(meta, counsel[r], r == #counsel)
      local n2 = counsel[r + 1] and #lines_of(meta, counsel[r + 1], r + 1 == #counsel) or 0
      extra = extra + math.max(n1, n2) * SINGLE
      rows[#rows + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. cell(column(r), cw + 280, 280)
        .. cell(column(r + 1), cw, 0) .. "</w:tr>"
    end
    add('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
      .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
      .. '</w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="' .. (cw + 280) .. '"/><w:gridCol w:w="' .. cw
      .. '"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>")
  else
    for gi, g in ipairs(counsel) do
      for li, l in ipairs(lines_of(meta, g, gi == #counsel)) do
        local before = li == 1 and (gi == 1 and gap or 140) or 0
        add(para({ LINES, spacing(before, 0), ind(HALF_W, nil, l.first) }, l.x))
      end
    end
  end
  add(rule("double", gap))
  local blocks = {}
  local h = extra
  for _, x in ipairs(out) do
    blocks[#blocks + 1] = raw(x)
    if x:sub(1, 7) ~= "<w:tbl>" then h = h + height(x) end
  end
  return blocks, h
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates (typst signature-block, certificate-signature / cert-signature / form-sig-line)
-- ---------------------------------------------------------------------------

local SIGLINE = TYPE == "answering" and "s/ " or "/s/ "

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  local function add(x) out[#out + 1] = x end
  add(para({ KEEP, spacing(392, 0), ind(HALF_W, nil, 0) }, runs("Respectfully submitted,", {})))
  add(para({ KEEP, spacing(336, 0), ind(HALF_W, nil, 0) }, runs(SIGLINE .. signer, {})))
  if TYPE ~= "opening" then add(para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 0) }, runs(signer:upper(), {}))) end
  local ls = sig.lines or {}
  for i, l in ipairs(ls) do
    local last = i == #ls and not meta.date
    local x = TYPE == "opening" and inl(l, {}) or inl(l, { i = true })
    add(para({ last and LINES or KEEP, spacing(0, 0), ind(HALF_W, nil, TYPE == "opening" and 0 or 140) }, x))
  end
  if meta.date then add(para({ LINES, spacing(224, 0), ind(0, nil, 0) }, inl(meta.date, {}))) end
  return table.concat(out)
end

local FORM_COL = 4820 -- typst form-sig-line: two 1fr columns 14 pt apart, the right one 241 pt in
local function cert_signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  if TYPE == "reply" then
    local tab = '<w:tabs><w:tab w:val="left" w:pos="' .. FORM_COL .. '"/></w:tabs>'
    local d = meta.date and inl(meta.date, {}) or ""
    return para({ KEEP, tab, spacing(448, 0), ind(0, nil, 0) }, runs(SIGLINE .. signer .. "\t", {}) .. d)
      .. para({ LINES, tab, spacing(0, 0), ind(0, nil, 0) }, runs("Signature\tDate", {}))
  end
  local out = {}
  out[#out + 1] = para({ KEEP, spacing(TYPE == "opening" and 392 or 448, 0), ind(HALF_W, nil, 0) },
    runs(SIGLINE .. signer, {}))
  if TYPE == "answering" then out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 0) }, runs(signer, {})) end
  local ls = sig.lines or {}
  for i, l in ipairs(ls) do
    local last = i == #ls and not (TYPE == "opening" and meta.date)
    out[#out + 1] = para({ last and LINES or KEEP, spacing(0, 0), ind(HALF_W, nil, 0) },
      TYPE == "opening" and inl(l, {}) or inl(l, { i = true }))
  end
  if TYPE == "opening" and meta.date then
    out[#out + 1] = para({ LINES, spacing(224, 0), ind(0, nil, 0) }, inl(meta.date, {}))
  end
  return table.concat(out)
end

-- A double-spaced paragraph, the first line indented (FRAP 32(a)(4)).
local function text_para(body)
  return para({ spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, body)
end

-- A served person's line: half an inch in, no first-line indent, 9.8 pt above.
local function served(u)
  return para({ LINES, spacing(196, 0, DOUBLE), ind(TAB, nil, 0) }, inl(u.name, {}) .. runs(", ", {}) .. inl(u.address, {}))
end

-- A certificate on its own page: its heading (in the contents of the answering and reply briefs), double-spaced
-- paragraphs, the signature. Its heading's needle names the page for the contents.
local cert_items = {}
local function cert(meta, title, paras)
  if TYPE ~= "opening" then
    local id = "C:" .. (#cert_items + 1)
    cert_items[#cert_items + 1] = { id = id, level = 1, title = title, step = 0 }
  end
  local out = { section_heading(title, true, true, TYPE == "opening") }
  for _, p in ipairs(paras) do out[#out + 1] = p end
  out[#out + 1] = cert_signature(meta)
  return table.concat(out)
end

-- The certificates' titles and first words (their needles), in order: { title, first words }.
local function cert_list(meta)
  if TYPE == "opening" then return {} end
  if TYPE == "answering" then
    local l = { { "Certificate of Bar Membership", "I hereby certify" }, { "Electronic-Filing Certification", "I hereby certify" },
      { "Certificate of Compliance", "1. This brief" } }
    if meta.service then l[#l + 1] = { "Certificate of Service", "I certify that" } end
    return l
  end
  local l = { { "Certificate of Compliance", "The undersigned counsel" } }
  if meta.service and is_true(meta.service.certificate) then l[#l + 1] = { "Certificate of Service", "I hereby certify" } end
  return l
end

local FRAP = "Fed. R. App. P."

local function certificates(meta, words)
  local n = group_digits(words)
  local out = {}
  local signer = stringify(need_meta(meta, "signature").signer)
  local function tp(s) return text_para(runs(s, {})) end
  if TYPE == "opening" then
    local using = meta.prepared_with and (" using " .. stringify(meta.prepared_with)) or ""
    out[#out + 1] = cert(meta, "Certificate of Compliance", {
      tp("This brief complies with the type-volume limitation of " .. FRAP .. " 32(a)(7)(B) because it contains " .. n ..
        " words, excluding the parts of the brief exempted by " .. FRAP .. " 32(f)."),
      tp("This brief complies with the typeface requirements of " .. FRAP .. " 32(a)(5) and the type-style requirements of " ..
        FRAP .. " 32(a)(6) because it has been prepared in a proportionally spaced typeface" .. using ..
        " in font size 14, font style " .. FACE .. "."),
    })
    out[#out + 1] = cert(meta, "Certification of Bar Membership", {
      tp("I certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court, or has filed an application for admission under 3d Cir. L.A.R. 46.1."),
    })
    local e = { tp("I certify that the text of the E-Brief and the text of the hard copies of this brief are identical.") }
    if meta.virus_software then
      e[#e + 1] = text_para(runs("I certify that a virus check was performed on the PDF file of this brief. The virus software used was ", {})
        .. inl(meta.virus_software, {}) .. runs(".", {}))
    end
    out[#out + 1] = cert(meta, "Certification of Text of E-Brief and Virus Check", e)
    local svc = meta.service and meta.service.certificate
    if svc == nil or is_true(svc) then
      out[#out + 1] = cert(meta, "Certificate of Service", {
        text_para(runs("I, " .. signer .. ", counsel for the filer and a member of the bar of this Court, certify that, on ", {})
          .. inl(need_meta(meta, "date"), {}) .. runs(", the brief and all accompanying appendices were filed electronically through the appellate CM/ECF system with the Clerk of Court. I further certify that all parties required to be served have been served.", {})),
      })
    end
  elseif TYPE == "answering" then
    out[#out + 1] = cert(meta, "Certificate of Bar Membership", {
      tp("I hereby certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court."),
    })
    out[#out + 1] = cert(meta, "Electronic-Filing Certification", {
      tp("I hereby certify that the text of the electronically filed brief is identical to the text in the paper copies. I also certify that a virus detection program has been run on the electronic file and that no virus was detected. The virus detection program used, and its version, is " ..
        string.rep("_", 20) .. "."),
    })
    out[#out + 1] = cert(meta, "Certificate of Compliance", {
      tp("1. This brief complies with the type-volume limitation of " .. FRAP .. " 32(a)(7)(B) because it contains " .. n ..
        " words, excluding the parts of the brief exempted by " .. FRAP .. " 32(f). The count includes " ..
        stringify(meta.manual_image_words or "0") .. " words counted by hand in any visual images."),
      tp("2. This brief complies with the typeface requirements of " .. FRAP .. " 32(a)(5) and the type-style requirements of " ..
        FRAP .. " 32(a)(6) because it has been prepared in a proportionally spaced typeface, 14-point " .. FACE .. "."),
    })
    if meta.service then
      local svc = meta.service
      local p = { text_para(runs("I certify that on ", {}) .. inl(svc.date, {}) .. runs(" I caused the foregoing ", {}) ..
        inl(need_meta(meta, "brief_title"), {}) .. runs(" to be served by ", {}) .. inl(svc.method, {}) .. runs(" on the following:", {})) }
      for _, u in ipairs(svc.to or {}) do p[#p + 1] = served(u) end
      out[#out + 1] = cert(meta, "Certificate of Service", p)
    end
  else
    out[#out + 1] = cert(meta, "Certificate of Compliance", {
      tp("The undersigned counsel certifies pursuant to L.A.R. 46.1(e) that counsel is a member in good standing of the bar of this Court."),
      text_para(runs("This brief complies with the type-volume limitation of FRAP 32(a)(7)(B)(ii) because it contains " .. n ..
        " words, including headings, footnotes, and quotations, and excluding the items exempted by FRAP 32(f). It is prepared in ", {}) ..
        inl(meta.typeface or "14-point, proportionally spaced serif type", {}) ..
        runs(" and complies with the typeface and type-style requirements of FRAP 32(a)(5) and (6).", {})),
      text_para(runs("The text of the electronic document is identical to the paper copies. Pursuant to L.A.R. 31.1(c), this electronic document was scanned for viruses using ", {}) ..
        inl(need_meta(meta, "virus_scanner"), {}) .. runs(" prior to filing and found to be virus free.", {})),
    })
    if meta.service and is_true(meta.service.certificate) then
      local p = { tp("I hereby certify that the foregoing brief was electronically filed on this date with the Clerk of the Court for the United States Court of Appeals for the Third Circuit by using the appellate CM/ECF system. Participants in the case who are registered CM/ECF users will be served by the appellate CM/ECF system.") }
      local unreg = meta.service.unregistered or {}
      if #unreg > 0 then
        p[#p + 1] = text_para(runs("Service on Case Participants Who Are NOT Registered for Electronic Filing:", { b = true }))
        p[#p + 1] = tp("I certify that I served the foregoing document on this date by hand delivery, mail, third party commercial carrier for delivery within 3 calendar days, or, having obtained prior consent, by email to the following unregistered case participants (list each name and mailing/email address):")
        for _, u in ipairs(unreg) do p[#p + 1] = served(u) end
      end
      out[#out + 1] = cert(meta, "Certificate of Service", p)
    end
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
  local required = { "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature" }
  if TYPE == "opening" then required[#required + 1] = "related_cases" end
  if TYPE == "reply" then required[#required + 1] = "virus_scanner" end
  for _, k in ipairs(required) do need_meta(meta, k) end
  local authorities = meta.authorities or {}
  doc = doc:walk({ OrderedList = ordered_list })
  local src = source_body()
  local words = count_md(src)
  if TYPE == "opening" then words = words + count_md(stringify(meta.related_cases)) end
  if words > LIMIT then
    error("ca3-" .. TYPE .. ": the brief has " .. words .. " words; the limit is " .. LIMIT)
  end

  local disclosure = meta.disclosure
  if disclosure then need("S:disc", "B", "Corporate Disclosure Statement", "") end
  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles). The opening
  -- brief's related-cases statement goes before the Statement of the Case (L.A.R. 28.1(a)(2)).
  local blocks = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and stringify(b.content):lower() == "addendum" then
      error("ca3-" .. TYPE .. ": an addendum is set by the typst engine only (see ../README.md)")
    end
    if TYPE == "opening" and b.t == "Header" and b.level == 1 and stringify(b.content):lower() == "statement of the case" then
      blocks[#blocks + 1] = pandoc.Header(1, pandoc.Inlines({ pandoc.Str("Statement of Related Cases") }))
      blocks[#blocks + 1] = pandoc.Para(pandoc.Inlines(meta.related_cases))
    end
    blocks[#blocks + 1] = b
  end
  local headings = {}
  local body = {}
  local in_arg = false
  local h_n = 0
  -- the printed text of every heading (its label and title), for the needles
  local printed, labs = {}, {}
  do
    local c, arg = { 0, 0, 0, 0, 0, 0 }, false
    for i, b in ipairs(blocks) do
      if b.t == "Header" and b.level <= 5 then
        c[b.level] = c[b.level] + 1
        for k = b.level + 1, 6 do c[k] = 0 end
        if b.level == 1 then arg = SCHEME == "argument" and norm(stringify(b.content)) == "argument" end
        labs[i] = b.level == 1 and "" or label(b.level, c[b.level], arg)
        printed[i] = labs[i] .. " " .. stringify(b.content)
      end
    end
  end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level > 5 then error("ca3-" .. TYPE .. ": headings deeper than level 5 are not supported") end
      if b.level == 1 then in_arg = SCHEME == "argument" and norm(stringify(b.content)) == "argument" end
      local lab = labs[i]
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", lab .. stringify(b.content), next_text(blocks, i, printed))
      if b.level <= TOC_DEPTH then
        local point = in_arg and b.level == 2
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
      error("ca3-" .. TYPE .. ": link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  -- the table of authorities' needle goes on with its first group title (the contents may list the same title)
  for _, g in ipairs(GROUPS) do
    local used = false
    for _, o in ipairs(occurrences) do
      local a = authorities[o.key]
      if a and a.kind and stringify(a.kind) == g[1] then used = true end
    end
    if used then
      for _, nd in ipairs(needles) do
        if nd.id == "S:toa" then nd.needle = norm("Table of Authorities " .. g[2]):sub(1, NEEDLE_MAX) end
      end
      break
    end
  end
  body = strip_links(body)
  -- typst moves the line that holds a footnote reference to the next page with its note, even when that leaves it a
  -- widow: a paragraph with a footnote has no widow control (style Body Text Noted, make-reference.sh)
  for i, b in ipairs(body) do
    if b.t == "Para" and has_note(b) then body[i] = pandoc.Div({ b }, { ["custom-style"] = "Body Text Noted" }) end
  end
  -- The last paragraph is not broken and stays with the signature block (typst: one unbreakable block, unless the
  -- brief's last markdown block is a heading or a footnote definition).
  local last = body[#body]
  if keep_last(src) and last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end

  -- the certificates' needles (their pages for the contents of the answering and reply briefs)
  for k, c in ipairs(cert_list(meta)) do need("C:" .. k, "B", c[1], c[2]) end
  local nl = {}
  for _, nd in ipairs(needles) do nl[#nl + 1] = table.concat({ nd.id, nd.kind, nd.needle, nd.fallback }, "\t") end
  -- how fb render labels pages: each section starts at the page of a needle (format, prefix)
  nl[#nl + 1] = "#section\t" .. (disclosure and "S:disc" or "S:toc") .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local certs = certificates(meta, words)

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): the disclosure statement, the table of contents, the table of authorities
  if disclosure then
    add(raw(section_heading("Corporate Disclosure Statement", true, false, true)))
    local dblocks = pandoc.utils.type(disclosure) == "Blocks" and disclosure or { pandoc.Para(pandoc.Inlines(disclosure)) }
    for k, p in ipairs(dblocks) do
      add(raw(para({ spacing(k == 1 and 0 or 280, 0), ind(0, nil, 0) }, inl(p.content or stringify(p), {}))))
    end
  end
  add(raw(section_heading("Table of Contents", true, disclosure ~= nil, true)))
  -- "Page" over the page column, 1 pt in: LibreOffice lets the underlined word overhang its advance
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, 0, 20), jc("right") }, runs("Page", { b = true, u = true }))))
  local items = {}
  if TYPE ~= "opening" then items[#items + 1] = { id = "S:toa", level = 1, title = "Table of Authorities", step = 0 } end
  for _, h in ipairs(headings) do items[#items + 1] = h end
  for _, c in ipairs(cert_items) do items[#items + 1] = c end
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true, TYPE == "opening")))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...), the signature, and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(certs))

  doc.blocks = out
  doc.meta.date = nil -- the date is printed by the signature blocks only, not by pandoc at the top
  doc.meta.title = nil
  return doc
end
