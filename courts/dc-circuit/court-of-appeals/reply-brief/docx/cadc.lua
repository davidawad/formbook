-- D.C. Circuit reply brief, docx engine: the brief as Word paragraphs and sections (typst: typst/cadc-reply-brief.typ,
-- latex: latex/template.tex). pandoc writes the body text (paragraphs, lists, footnotes) with the reference document
-- fb render builds from docx/reference.xml; this filter writes what needs Word formatting:
--   * the cover (FRAP 32(a)(2); Cir. R. 28(a)(8)), the table of contents, the table of authorities, the quotations,
--     the signature block and the certificates, as paragraphs with explicit spacing, indents and tabs;
--   * the heading labels (I., A., 1., a. in the Argument; A., 1., a., (1) elsewhere) and each heading's outline level
--     (Heading 1-5 styles, so the PDF has bookmarks);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of
--     every heading and citation in that PDF (the needles this filter writes), and renders again with those pages
--     (the pages file this filter reads); Circuit Rule 28(a)(2): every page, never "passim";
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1, 2 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- The word count is the typst template's count of the markdown source; the build stops over the reply limit.
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the shared Word model lib/docx/xengine.lua, exact line
-- spacing throughout (Word sets each line in a box of that height, the baseline at 0.8 of it), the typst template's
-- pitches and spaces in twips (20 x pt). Word may paginate slightly differently from the LibreOffice PDF the page
-- numbers come from (docs/DOCX.md).
local WORD_LIMIT = 6500   -- FRAP 28.1(e)(2)(C): reply = half of 13,000 (Cir. R. 32(e)(1))

local TOC_DEPTH = 4    -- heading levels listed in the table of contents (typst: toc-depth)
local TAB = 720        -- half an inch (para-indent, label width), in twips
local TEXT_W = 9360    -- the text width, 6.5 in
local TAB_R = 9360     -- the right tab of the tables: at the margin
local PNUM_TOC = 720   -- the column the contents' page numbers keep to themselves (typst toc-page-col, 36 pt)
local PNUM_TOA = 1120  -- the column of the authorities' page lists (typst toa-page-col, 56 pt)
local HALF_W = 4680    -- the middle of the text (typst half-text)
local SINGLE = 340     -- single-spaced material: 17 pt line boxes (typst pitch-single)
local DOUBLE = 588     -- body text (reference.docx Body Text): 29.4 pt (typst pitch-double, FRAP 32(a)(4))
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)
local TYPEFACE = "Times New Roman"   -- the typst template's font

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

-- A rule on the cover: an empty paragraph with a bottom border, `left_right` in from both margins (the 2 in rules);
-- "double": a thick line over a thin one across the text width.
local function rule(kind, before, left_right)
  local b = kind == "double"
      and '<w:pBdr><w:bottom w:val="thickThinSmallGap" w:sz="12" w:space="1" w:color="000000"/></w:pBdr>'
      or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  return para({ KEEP, b, spacing(before, 0, 120), ind(left_right or 0, nil, nil, left_right or 0) }, "")
end

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, written by fb render), page number format and
-- start, letter paper with 1 in margins (FRAP 32(a)(4)).
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

-- The markdown body of the input file (the frontmatter dropped).
local function source_body()
  local f = PANDOC_STATE.input_files[1] and io.open(PANDOC_STATE.input_files[1], "r")
  if not f then error("cadc.lua: cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
  return src
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block is
-- not a heading and not a footnote definition.
local function keep_last(src)
  local text = src:gsub("%s+$", "")
  local cut = 1
  for e in text:gmatch("\n[ \t]*\n()") do cut = e end
  local tail = text:sub(cut)
  return tail ~= "" and tail:sub(1, 1) ~= "#" and tail:sub(1, 2) ~= "[^"
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

-- The indent of a heading's label, in half inches (typst label-indent): level 2 at the margin, each deeper level one
-- step in.
local function step(level)
  return level - 2
end

local function hstyle(level)
  return style("Heading" .. level)
end

-- typst style-heading: the spacing above and below each kind of heading, in twips (21 / 15.4 pt around a section
-- heading, 15.4 / 12.6 pt around a numbered one).
local SPACE = {
  section = { 420, 308 },
  sub = { 308, 252 },
}

-- A section heading (level 1, the tables, the certificates): bold capitals, centered, 14 pt.
-- `top`: the heading opens a page (no space above); `brk`: it also breaks the page (not after a section break);
-- `plain`: not an outline entry.
local function section_heading(text, top, brk, plain)
  return para({ plain and "" or hstyle(1), KEEP, brk and BREAK or "", spacing(top and 0 or SPACE.section[1], SPACE.section[2]),
    ind(0, nil, 0), jc("center") }, runs(text:upper(), { b = true }))
end

-- A body heading: the label in a half-inch box at its indent, the text hanging under the text; bold, bold italic from
-- level 4.
local function heading_xml(level, content, lab)
  if level == 1 then return section_heading(stringify(content), false) end
  local k = step(level)
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
    lead .. inl(item.content or title, {}) .. runs(LEAD .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities (Circuit Rule 28(a)(2): every page, no "passim")
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

-- typst's sort-key: the sort field, else name and citation; lower case, letters, digits and spaces only.
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
        local s = table.concat(pages, ", ")
        -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): Times New Roman
        -- digits are 0.5 em (140 twips at 14 pt), a comma and a space 0.25 em each
        local list_w = 0
        for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 140 or 70) end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = g[1] == "case" }) .. runs(",", {}) .. BR
        end
        out[#out + 1] = para({ LINES, dot_tabs(), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. runs(LEAD .. s, {}))
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body)
-- ---------------------------------------------------------------------------

local function need_meta(meta, k)
  if meta[k] == nil then error("cadc.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function cover(meta)
  local sides = need_meta(meta, "caption")
  local counsel = need_meta(meta, "counsel")
  -- typst: 4.9 pt between the cover's paragraphs and a gap of 14 pt more between its parts (the largest of 1, 0.8 ...
  -- em at which the cover fits one page, which is 1 em for the sample); a rule takes a gap above and below it, the
  -- space typst's rule blocks take less the rule paragraph's own 6 pt line (15 pt each side of a short rule, 17.6 pt
  -- of the double rule).
  local par = 98
  local gap = 300
  local gap2 = 352
  local out = {}
  local function add(x) out[#out + 1] = x end
  local function center(x, before, o)
    add(para({ KEEP, spacing(before or par, 0), ind(0, nil, 0), jc("center") }, x))
  end
  -- Circuit Rule 28(a)(8): the oral-argument statement, in capitals, at the top of the front cover.
  local first = 0
  if meta.oral_argument then
    center(inl(meta.oral_argument, { b = true, caps = true }), 0)
    first = 168 + par
  end
  center(runs("No. ", { b = true }) .. inl(meta.case_number, { b = true }), first)
  add(rule("double", gap2))
  center(runs("IN THE UNITED STATES COURT OF APPEALS", { b = true }) .. BR ..
    runs("FOR THE DISTRICT OF COLUMBIA CIRCUIT", { b = true }), gap2)
  add(rule("short", gap, 3240))
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do center(inl(n, {}), (k == 1 and i == 1) and gap or (k == 1 and 84 + par or par)) end
    add(para({ KEEP, spacing(par, 0), ind(HALF_W, nil, 0) }, inl(side.designation, {})))
    if i < #sides then center(runs("v.", {}), 84 + par) end
  end
  add(rule("short", gap, 3240))
  center(inl(need_meta(meta, "proceeding"), {}), gap)
  if meta.district_court_case or meta.judge then
    local x = ""
    if meta.district_court_case then x = runs("D.C. No. ", {}) .. inl(meta.district_court_case, {}) end
    if meta.district_court_case and meta.judge then x = x .. runs("; ", {}) end
    if meta.judge then x = x .. inl(meta.judge, {}) end
    center(x, par)
  end
  add(rule("short", gap, 3240))
  center(inl(meta.brief_title, { b = true, caps = true }), gap)
  add(rule("short", gap, 3240))
  -- counsel (FRAP 32(a)(2)): name, office address and telephone number, from the middle of the text width; the
  -- telephone number is the last line of the last group
  for gi, g in ipairs(counsel) do
    local ls = {}
    for _, n in ipairs(g.names or {}) do ls[#ls + 1] = { x = inl(n, {}), first = 0 } end
    local more = {}
    for _, l in ipairs(g.lines or {}) do more[#more + 1] = l end
    if gi == #counsel then more[#more + 1] = need_meta(meta, "phone") end
    for _, l in ipairs(more) do ls[#ls + 1] = { x = inl(l, { i = true }), first = 140 } end
    for li, l in ipairs(ls) do
      local before = li == 1 and (gi == 1 and gap or 140) or 0
      add(para({ li < #ls and KEEP or LINES, spacing(before, 0), ind(HALF_W, nil, l.first) }, l.x))
    end
  end
  add(rule("double", gap2))
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Quotations (typst: single-spaced, half an inch in on both sides, 14 pt above and below, 12.6 pt between paragraphs,
-- none next to a list; a list inside one has its label in a half-inch box)
-- ---------------------------------------------------------------------------

local function quote(q)
  local items = {}
  for _, b in ipairs(q.content) do
    if b.t == "Para" or b.t == "Plain" then
      items[#items + 1] = { list = false, x = inl(b.content, {}), left = TAB, hang = nil }
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local n = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
        local x = {}
        for _, ib in ipairs(item) do
          if ib.t ~= "Para" and ib.t ~= "Plain" then error("cadc.lua: a quotation's list item holds only text") end
          x[#x + 1] = inl(ib.content, {})
        end
        items[#items + 1] = { list = true, x = runs(lab .. "\t", {}) .. table.concat(x, runs(" ", {})), left = 2 * TAB, hang = TAB }
        n = n + 1
      end
    else
      error("cadc.lua: a quotation holds paragraphs and lists only")
    end
  end
  local out = {}
  for i, it in ipairs(items) do
    local prev, nxt = items[i - 1], items[i + 1]
    local before = not prev and 280 or ((prev.list or it.list) and 0 or 252)
    local after = not nxt and 280 or 0
    local first = 0
    if it.hang then first = nil end
    out[#out + 1] = para({ spacing(before, after), ind(it.left, it.hang, first, TAB) }, it.x)
  end
  return raw(table.concat(out))
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates (typst signature-block, form-sig-line, certificates)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  local function add(x) out[#out + 1] = x end
  add(para({ KEEP, spacing(392, 0), ind(HALF_W, nil, 0) }, runs("Respectfully submitted,", {})))
  add(para({ KEEP, spacing(336, 0), ind(HALF_W, nil, 0) }, runs("/s/ " .. signer, {})))
  add(para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 0) }, runs(signer, {})))
  local ls = sig.lines or {}
  for i, l in ipairs(ls) do
    local last = i == #ls and not meta.date
    add(para({ last and LINES or KEEP, spacing(0, 0), ind(HALF_W, nil, 140) }, inl(l, { i = true })))
  end
  if meta.date then add(para({ LINES, spacing(224, 0), ind(0, nil, 0) }, inl(meta.date, {}))) end
  return table.concat(out)
end

-- The signature under a certificate (typst form-sig-line): two columns, "/s/ Name" over "Signature" at the margin and
-- the date over "Date" in the right one (the columns are 1fr with a 1 em gutter: the right one starts 241 pt in).
local FORM_COL = 4820
local function form_signature(meta)
  local signer = stringify(need_meta(meta, "signature").signer)
  local tab = '<w:tabs><w:tab w:val="left" w:pos="' .. FORM_COL .. '"/></w:tabs>'
  local d = meta.date and inl(meta.date, {}) or ""
  return para({ KEEP, tab, spacing(448, 0), ind(0, nil, 0) }, runs("/s/ " .. signer .. "\t", {}) .. d)
    .. para({ LINES, tab, spacing(0, 0), ind(0, nil, 0) }, runs("Signature\tDate", {}))
end

local function text_para(body, before)
  return para({ spacing(before or 0, 0), ind(0, nil, 0) }, body)
end

-- Certificate of Compliance (FRAP 32(g)(1); FRAP 28.1(e)(2)(C); Cir. R. 32(e)(1)).
local function compliance(meta, words)
  local images = meta.manual_image_words and stringify(meta.manual_image_words) or "0"
  return section_heading("Certificate of Compliance", true, true, true)
    .. text_para(runs("I hereby certify that this brief complies with the type-volume limitation of Fed. R. App. P. 28.1(e)(2)(C) and Circuit Rule 32(e)(1). Excluding the parts of the document exempted by Fed. R. App. P. 32(f), this brief contains "
      .. group_digits(words) .. " words, including " .. images .. " words manually counted in any visual images.", {}))
    .. text_para(runs("This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6): it is prepared in a proportionally spaced serif typeface ("
      .. TYPEFACE .. "), 14-point.", {}), 280)
    .. form_signature(meta)
end

-- Certificate of Service (FRAP 25(d)): only when service.certificate is true.
local function service(meta)
  local svc = need_meta(meta, "service")
  local out = { section_heading("Certificate of Service", true, true, true) }
  out[#out + 1] = text_para(runs("I hereby certify that on this date I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the District of Columbia Circuit using the appellate CM/ECF system, which will send notice of the filing to all counsel of record.", {}))
  local unreg = svc.unregistered or {}
  if #unreg > 0 then
    out[#out + 1] = text_para(runs("Service on Participants Who Are NOT Registered for Electronic Filing:", { b = true }), 280)
    out[#out + 1] = text_para(runs("I certify that I served the foregoing on this date by hand delivery, mail, or third-party commercial carrier for delivery within 3 calendar days to the following unregistered participants (list each name and mailing address):", {}), 280)
    for _, u in ipairs(unreg) do
      out[#out + 1] = para({ LINES, spacing(196, 0), ind(TAB, nil, 0) }, inl(u.name, {}) .. runs(", ", {}) .. inl(u.address, {}))
    end
  end
  out[#out + 1] = form_signature(meta)
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

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  local words = count_md(source_body())
  if words > WORD_LIMIT then
    error("cadc.lua: the brief has " .. words .. " words; FRAP 28.1(e)(2)(C) allows " .. WORD_LIMIT .. " for a reply brief")
  end

  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles).
  local headings = {}
  local body = {}
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n = 0
  local blocks = doc.blocks
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
      if b.level > 5 then error("cadc.lua: headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      local lab = labs[i]
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", lab .. stringify(b.content), next_text(blocks, i, printed))
      if b.level <= TOC_DEPTH then
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = stringify(b.content), content = b.level > 1 and b.content or nil,
          step = b.level == 1 and 0 or step(b.level) }
      end
      local x = heading_xml(b.level, b.content, lab)
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
      error("cadc.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  -- the table of authorities' needle goes on with its first group title
  for _, g in ipairs(GROUPS) do
    local used = false
    for _, o in ipairs(occurrences) do
      local a = authorities[o.key]
      if a and a.kind and stringify(a.kind) == g[1] then used = true end
    end
    if used then
      for _, n in ipairs(needles) do
        if n.id == "S:toa" then n.needle = norm("Table of Authorities " .. g[2]):sub(1, NEEDLE_MAX) end
      end
      break
    end
  end
  body = strip_links(body)
  for i, b in ipairs(body) do
    if b.t == "BlockQuote" then body[i] = quote(b) end
  end
  -- The last paragraph is not broken and stays with the signature block (typst: one unbreakable block, unless the
  -- brief's last markdown block is a heading or a footnote definition).
  local last = body[#body]
  if keep_last(source_body()) and last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end

  local svc = meta.service and meta.service.certificate
  local with_service = svc == true or (svc ~= nil and stringify(svc) == "true")
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: each section starts at the page of a needle (format, prefix)
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): the table of contents, the table of authorities
  add(raw(section_heading("Table of Contents", true, false, true)))
  -- "Page" over the page column, 1 pt in: LibreOffice lets the underlined word overhang its advance
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, 0, 20), jc("right") }, runs("Page", { b = true, u = true }))))
  for _, it in ipairs(headings) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true, true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...), the signature, and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(compliance(meta, words)))
  if with_service then add(raw(service(meta))) end

  doc.blocks = out
  doc.meta.date = nil -- the date is printed by the signature blocks only, not by pandoc at the top
  doc.meta.title = nil
  return doc
end
