-- D.C. Circuit answering brief, docx engine: the brief as Word paragraphs and sections (typst:
-- typst/cadc-answering-brief.typ, latex: latex/template.tex). pandoc writes the body text (paragraphs, quotations,
-- lists, footnotes) with docx/reference.docx (built by make-reference.sh); this filter writes what needs Word
-- formatting:
--   * the cover (FRAP 32(a)(2)), the certificate of parties, rulings and related cases (D.C. Cir. R. 28(a)(1)), the
--     table of contents, the table of authorities, the signature block, the certificates and the addendum
--     (D.C. Cir. R. 28(a)(5)), as paragraphs with explicit spacing, indents and tabs;
--   * the heading labels (I., A., 1., a. in the Argument; A., 1., a., (1) elsewhere) and each heading's outline
--     level (Heading 1-5 styles, so the PDF has bookmarks);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of
--     every heading and citation in that PDF (the needles this filter writes), and renders again with those pages
--     (the pages file this filter reads);
--   * the sections whose footers number the pages: cover (page i, none printed), front matter (ii, iii ...), body and
--     certificates (1, 2 ...), addendum (Add-1 ...). fb render writes the footers; this filter writes the last section
--     (FORMBOOK_FINAL).
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the shared Word model lib/docx/xengine.lua, exact line
-- spacing throughout (Word sets each line in a box of that height, the baseline at 0.8 of it), the typst template's
-- pitches and spaces in twips (20 x pt). Word may paginate slightly differently from the LibreOffice PDF the page
-- numbers come from (docs/DOCX.md).
local WORD_LIMIT = 13000 -- FRAP 32(a)(7)(B)(i): principal brief (appellee's brief included)

local TOC_DEPTH = 4    -- heading levels listed in the table of contents (typst: toc-depth)
local TAB = 720        -- half an inch (para-indent, label width), in twips
local TAB_R = 9360     -- the right tab of the tables: at the margin (the text width, 6.5 in)
local PNUM_TOC = 720   -- the column the contents' page numbers keep to themselves (typst toc-page-col, 36 pt)
local PNUM_TOA = 1120  -- the column of the authorities' page lists (typst toa-page-col, 56 pt)
local HALF_W = 4680    -- the middle of the text (typst half-pad)
local SINGLE = 350     -- single-spaced material: 17.5 pt line boxes (typst pitch-single)
local DOUBLE = 528     -- body text (reference.docx Body Text): 26.4 pt (typst pitch-double, FRAP 32(a)(4))
local HEAD = 420       -- section headings: 21 pt line boxes (typst pitch-heading)
local HEAD_SZ = 32     -- section headings: 16 pt (half points; typst heading-size)
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)
local TYPEFACE = "TeX Gyre Schola"   -- the typst template's font

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
-- LibreOffice sets TeX Gyre Schola's f-ligatures (OpenType liga, on by default; a zero-width non-joiner would keep
-- them apart but stays in the document's text): the typst and LaTeX engines set them too.
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
-- and start, letter paper with 1 in margins (FRAP 32(a)(4)).
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
  if not f then error("cadc.lua: cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
  local a = src:find("\n#[ \t]+[Aa][Dd][Dd][Ee][Nn][Dd][Uu][Mm][ \t]*\r?\n")
  if a then src = src:sub(1, a) end
  return src
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block of
-- the text before the footnote definitions is not a heading and holds no footnote.
local function keep_last(src)
  local text = src:gsub("%s+$", "")
  local d = text:find("\n\n%[%^[^%]]+%]:")
  if d then text = text:sub(1, d - 1) end
  local cut = 1
  for e in text:gmatch("\n[ \t]*\n()") do cut = e end
  local tail = text:sub(cut)
  if tail == "" or tail:sub(1, 1) == "#" then return false end
  if tail:find("[^", 1, true) then return false end
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

-- The indent of a sub-heading's label, in half inches (typst label-indent): the Argument's point headings are
-- centered, so their sub-headings start at the first step.
local function step(level, arg)
  if arg then return level - 2 end
  return level - 1
end

local function hstyle(level)
  return style("Heading" .. level)
end

-- typst style-heading: the spacing above and below each kind of heading, in twips (21 / 15.4, 16.8 / 14,
-- 15.4 / 12.6, 16.8 / 12.6 pt).
local SPACE = {
  section = { 420, 308 },
  point = { 336, 280 },
  sub = { 308, 252 },
  plain = { 336, 252 },
}

-- A section heading (level 1, the front matter, the certificates): bold capitals, centered, 16 pt in 18 pt boxes.
-- `top`: the heading opens a page (no space above); `brk`: it also breaks the page (not after a section break);
-- `plain`: not an outline entry.
local function section_heading(text, top, brk, plain)
  return para({ plain and "" or hstyle(1), KEEP, brk and BREAK or "", spacing(top and 0 or SPACE.section[1], SPACE.section[2], HEAD),
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

-- An addendum heading (unnumbered): level 1 a section heading, deeper ones bold at the margin.
local function addendum_heading_xml(level, content)
  if level == 1 then return section_heading(stringify(content), false) end
  return para({ hstyle(level), KEEP, spacing(SPACE.plain[1], SPACE.plain[2]), ind(0, nil, 0) }, inl(content, { b = true }))
end

-- One row of the table of contents (typst listing-row): label, title, a dot leader from the end of the title and the
-- page. The title wraps before the page column (the right indent); the right tab sits beyond it.
local function toc_row(item)
  local title = item.level == 1 and item.title:upper() or item.title
  local left = TAB * item.step + TAB
  local lead = ""
  if item.label then lead = runs(item.label .. "\t", {}) end
  -- an addendum page ("Add-12") takes the authorities' wider column (typst: the page column is never narrower than
  -- the page label)
  return para({ LINES, dot_tabs(),
    spacing(item.level == 1 and 168 or 98, 0), ind(left, TAB, nil, item.add and PNUM_TOA or PNUM_TOC) },
    lead .. inl(item.content or title, {}) .. runs(LEAD .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities (Circuit Rule 28(a)(2): every page is listed; "passim" may not be used)
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

-- Sort key as typst's: lower case, letters, digits and spaces only.
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
        -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): TeX Gyre Schola
        -- digits are 0.556 em (156 twips at 14 pt), a comma and a space 0.278 em each (78 twips)
        local list_w = 0
        for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 156 or 78) end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = stringify(m.a.kind) == "case" }) .. runs(",", {}) .. BR
        end
        out[#out + 1] = para({ LINES, dot_tabs(), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. runs(LEAD, {}) .. runs(s, {}))
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
  -- The spaces between the cover's parts as the typst render sets them for the sample (its gap is the largest of 1,
  -- 0.8, 0.6 ... em at which the cover fits one page, and 4.9 pt part paragraphs): a short rule and the gaps around it
  -- add 26.6 pt between two lines, the double rule under the number 34 pt.
  local gap = 206
  local small = 148
  local par = 98
  local out = {}
  local function add(x) out[#out + 1] = x end
  local function center(x, before)
    add(para({ KEEP, spacing(before or 0, 0), ind(0, nil, 0), jc("center") }, x))
  end
  local first = 0
  if meta.oral_argument then
    add(para({ KEEP, spacing(0, 0), ind(0, nil, 0) }, inl(meta.oral_argument, { b = true })))
    first = 198
  end
  center(runs("No. ", { b = true }) .. inl(need_meta(meta, "case_number"), { b = true }), first)
  add(rule("double", gap))
  center(runs("UNITED STATES COURT OF APPEALS", { b = true }) .. BR .. runs("FOR THE DISTRICT OF COLUMBIA CIRCUIT", { b = true }), 354)
  add(rule("short", gap, 3240))
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do center(inl(n, {}), k == 1 and (i == 1 and gap or small) or par) end
    add(para({ KEEP, spacing(par, 0), ind(HALF_W, nil, 0) }, inl(side.designation, {})))
    if i < #sides then
      add(para({ KEEP, spacing(small, small), ind(0, nil, 0), jc("center") }, runs("v.", {})))
    end
  end
  add(rule("short", gap, 3240))
  center(inl(need_meta(meta, "proceeding"), {}), gap)
  if meta.district_court_case or meta.judge then
    local x = ""
    if meta.district_court_case then x = inl(meta.district_court_case, {}) end
    if meta.district_court_case and meta.judge then x = x .. runs("; ", {}) end
    if meta.judge then x = x .. inl(meta.judge, {}) end
    center(x, 98)
  end
  add(rule("short", gap, 3240))
  center(inl(meta.brief_title, { b = true, caps = true }), gap)
  add(rule("short", gap, 3240))
  -- counsel (FRAP 32(a)(2)(F)): name, office address and telephone number, at the middle of the text width
  for gi, g in ipairs(counsel) do
    local ls = {}
    for _, n in ipairs(g.names or {}) do ls[#ls + 1] = { x = inl(n, {}), first = 0 } end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #counsel then lines[#lines + 1] = need_meta(meta, "phone") end
    for _, l in ipairs(lines) do ls[#ls + 1] = { x = inl(l, { i = true }), first = 140 } end
    for li, l in ipairs(ls) do
      local before = li == 1 and (gi == 1 and gap or 140) or 0
      add(para({ LINES, spacing(before, 0), ind(HALF_W, nil, l.first) }, l.x))
    end
  end
  add(rule("double", gap))
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Certificate of parties, signature block and certificates (typst signature-block, form-sig-line, certificates)
-- ---------------------------------------------------------------------------

local function text_para(body, after)
  return para({ spacing(0, after or 280), ind(0, nil, 0) }, body)
end

-- A metadata value of several paragraphs, 14 pt apart.
local function paras_of(x)
  local blocks
  if pandoc.utils.type(x) == "Blocks" then blocks = x
  elseif pandoc.utils.type(x) == "Inlines" then blocks = { pandoc.Para(x) }
  else blocks = pandoc.read(stringify(x), "markdown+smart").blocks end
  local out = {}
  for i, b in ipairs(blocks) do
    if b.content then out[#out + 1] = text_para(inl(b.content, {}), i < #blocks and 280 or 0) end
  end
  return table.concat(out)
end

local function certificate_of_parties(meta)
  local out = { section_heading("Certificate of Parties, Rulings, and Related Cases", true, false, true),
    paras_of(need_meta(meta, "certificate_of_parties")) }
  if meta.statutes_and_regulations then
    out[#out + 1] = section_heading("Statutes and Regulations", false, false, true)
    out[#out + 1] = paras_of(meta.statutes_and_regulations)
  end
  return table.concat(out)
end

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  local function add(x) out[#out + 1] = x end
  add(para({ KEEP, spacing(392, 0), ind(HALF_W, nil, 0) }, runs("Respectfully submitted,", {})))
  add(para({ KEEP, spacing(336, 0), ind(HALF_W, nil, 0) }, runs("/s/ " .. signer, {})))
  local ls = sig.lines or {}
  add(para({ #ls == 0 and LINES or KEEP, spacing(0, 0), ind(HALF_W, nil, 0) }, runs(signer:upper(), {})))
  for i, l in ipairs(ls) do
    add(para({ i == #ls and LINES or KEEP, spacing(0, 0), ind(HALF_W, nil, 140) }, inl(l, { i = true })))
  end
  return table.concat(out)
end

-- The signature under a certificate (typst form-sig-line): at the middle of the text width, the first line only.
local function form_signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local ls = sig.lines or {}
  local out = para({ KEEP, spacing(448, 0), ind(HALF_W, nil, 0) }, runs("/s/ " .. signer, {}))
    .. para({ ls[1] and KEEP or LINES, spacing(0, 0), ind(HALF_W, nil, 0) }, runs(signer:upper(), {}))
  if ls[1] then out = out .. para({ LINES, spacing(0, 0), ind(HALF_W, nil, 140) }, inl(ls[1], { i = true })) end
  return out
end

local function compliance(words)
  return section_heading("Certificate of Compliance", true, true, true)
    .. text_para(runs("I HEREBY CERTIFY pursuant to Fed. R. App. P. 32(g) that this brief contains " .. group_digits(words)
      .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f) and D.C. Circuit Rule 32(e)(1), and therefore complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B). This brief has been prepared in 14-point "
      .. TYPEFACE .. ", a proportionally spaced typeface.", {}), 0)
end

local function service(meta)
  local svc = need_meta(meta, "service")
  return section_heading("Certificate of Service", true, true, true)
    .. text_para(runs("I HEREBY CERTIFY that I have caused a copy of the foregoing ", {}) .. inl(svc.document, {})
      .. runs(" to be served by electronic means, through the Court\u{2019}s CM/ECF system, upon ", {})
      .. inl(svc.served_upon, {}) .. runs(", on this ", {}) .. inl(svc.date, {}) .. runs(".", {}), 0)
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
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature",
    "certificate_of_parties" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  doc = doc:walk({ OrderedList = ordered_list })
  local words = count_md(source_body())
  if words > WORD_LIMIT then
    error("cadc.lua: the brief has " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. WORD_LIMIT)
  end

  need("S:cover", "B", "No. " .. stringify(meta.case_number), "")
  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles); the addendum
  -- after `# Addendum` apart.
  local headings = {}
  local body = {}
  local add_blocks = nil
  local in_arg = false
  local h_n = 0
  local blocks = doc.blocks
  -- the printed text of every heading (its label and title), for the needles
  local printed, labs = {}, {}
  do
    local c, arg = { 0, 0, 0, 0, 0, 0 }, false
    for i, b in ipairs(blocks) do
      if b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "addendum" then break end
      if b.t == "Header" and b.level <= 5 then
        c[b.level] = c[b.level] + 1
        for k = b.level + 1, 6 do c[k] = 0 end
        if b.level == 1 then arg = norm(stringify(b.content)) == "argument" end
        labs[i] = b.level == 1 and "" or label(b.level, c[b.level], arg)
        printed[i] = labs[i] .. " " .. stringify(b.content)
      end
    end
  end
  local add_headings = {}
  for i, b in ipairs(blocks) do
    if add_blocks == nil and b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "addendum" then
      add_blocks = {}
      need("S:add", "B", "Addendum", "Table of Contents")
    elseif add_blocks then
      if b.t == "Header" then
        h_n = h_n + 1
        local id = "H:" .. h_n
        need(id, "B", stringify(b.content), next_text(blocks, i, {}))
        if b.level == 2 then add_headings[#add_headings + 1] = { id = id, level = 2, add = true, title = stringify(b.content),
          content = b.content, step = 0 } end
        add_blocks[#add_blocks + 1] = raw(addendum_heading_xml(b.level, b.content))
      else
        for _, x in ipairs(list_items(b)) do add_blocks[#add_blocks + 1] = x end
      end
    elseif b.t == "Header" then
      if b.level > 5 then error("cadc.lua: headings deeper than level 5 are not supported") end
      if b.level == 1 then in_arg = norm(stringify(b.content)) == "argument" end
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
  -- The last paragraph is not broken and stays with the signature block (typst: one unbreakable block, unless the
  -- brief's last markdown block is a heading or holds footnotes).
  local last = body[#body]
  if keep_last(source_body()) and last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end

  local svc = meta.service and meta.service.certificate
  local with_service = svc == true or (svc ~= nil and stringify(svc) == "true")
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: each section starts at the page of a needle (format, prefix)
  nl[#nl + 1] = "#section\tS:cover\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  if add_blocks then nl[#nl + 1] = "#section\tS:add\tdecimal\tAdd-" end
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", add_blocks and sect_pr("rIdFtrAdd", "decimal", 1) or sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (page i, no number printed)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (ii, iii ...): the certificate of parties, the contents, the authorities
  add(raw(certificate_of_parties(meta)))
  add(raw(section_heading("Table of Contents", true, true, true)))
  -- "Page" over the page column, 1 pt in: LibreOffice lets the underlined word overhang its advance
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, 0, 20), jc("right") }, runs("Page", { b = true, u = true }))))
  local items = {}
  for _, h in ipairs(headings) do items[#items + 1] = h end
  if add_blocks then items[#items + 1] = { id = "S:add", level = 1, title = "Addendum", step = 0, add = true } end
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true, true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 2))

  -- Section 3: the body (1, 2 ...), the signature, and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(compliance(words) .. form_signature(meta)))
  if with_service then add(raw(service(meta) .. form_signature(meta))) end

  -- Section 4: the addendum (Add-1 ...): its heading, its own contents, then its text
  if add_blocks then
    add(section("rIdFtrPage", "decimal", 1))
    add(raw(section_heading("Addendum", true, false, false)))
    add(raw(section_heading("Table of Contents", false, false, true)))
    for _, it in ipairs(add_headings) do add(raw(toc_row(it))) end
    -- the addendum's text opens a page: its first block breaks it, with no space above (typst drops it there)
    local first = add_blocks[1]
    if first and first.t == "RawBlock" then
      first.text = first.text:gsub("<w:keepLines/>", "<w:keepLines/>" .. BREAK, 1):gsub('w:before="%d+"', 'w:before="0"', 1)
    else
      add(raw(para({ BREAK, spacing(0, 0, 20) }, "")))
    end
    for _, x in ipairs(strip_links(add_blocks)) do add(x) end
  end

  doc.blocks = out
  doc.meta.date = nil -- printed by the certificates only, not by pandoc at the top
  doc.meta.title = nil
  return doc
end
