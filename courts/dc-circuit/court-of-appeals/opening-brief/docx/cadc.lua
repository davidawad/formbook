-- D.C. Circuit principal brief, docx engine: the brief as Word paragraphs and sections (typst:
-- typst/cadc-opening-brief.typ, latex: latex/template.tex). pandoc writes the body text (paragraphs, quotations,
-- lists, footnotes) with the reference document fb render builds from docx/reference.xml; this filter writes what needs Word
-- formatting:
--   * the cover (FRAP 32(a)(2); Circuit Rule 28(a)(8)), the certificate as to parties (Circuit Rule 28(a)(1)), the
--     table of contents, the table of authorities, the glossary, the signature block and the certificates, as
--     paragraphs with explicit spacing, indents and tabs; the headings (Heading 1-3 styles, so the PDF has bookmarks);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of
--     every heading and citation in that PDF (the needles this filter writes), and renders again with those pages
--     (the pages file this filter reads);
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1, 2 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the shared Word model lib/docx/xengine.lua, exact line
-- spacing throughout (Word sets each line in a box of that height, the baseline at 0.8 of it), the typst template's
-- pitches and spaces in twips (20 x pt). Word may paginate slightly differently from the LibreOffice PDF the page
-- numbers come from (docs/DOCX.md).
local WORD_LIMIT = 13000 -- FRAP 28.1(e)(2)(A)(i), 32(a)(7)(B)(i); Circuit Rule 32(e)
local TYPEFACE = "TeX Gyre Schola" -- the typst template's font-family

local TAB = 720        -- half an inch (para-indent), in twips
local TEXT_W = 9360    -- the text width, 6.5 in: the right tab of the tables
local PNUM = 720       -- the column the tables' page numbers keep to themselves (typst toc-page-col, 36 pt)
local SIG_COL = 4820   -- the signer's column: (text width + 14 pt) / 2 (typst signature-block grid)
local CERT_SIG = 4212  -- under a certificate: 45 % of the text width (typst cert-signature)
local GLOSS = 1440     -- the glossary's abbreviation column, 1 in
local COUNSEL_W = 4512 -- a cover counsel column: (text width - 16.8 pt) / 2
local GUTTER = 336     -- 16.8 pt between the counsel columns
local SINGLE = 420     -- single-spaced material: 21 pt line boxes (typst pitch-single)
local COVER = 328      -- the cover: 16.4 pt line boxes (typst pitch-cover)
local BODY = 500       -- body text (reference.docx Body Text): 25 pt (typst pitch-body)
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)

local stringify = pandoc.utils.stringify
local xe = require("docx.xengine")

-- Word joiners (U+2060), which print nothing and are not in the PDF's text:
--   * no break inside a token of adjacent parentheses ("6103(i)(2)"): typst boxes it (lib/typst/xengine.typ) and TeX
--     has no break there, but LibreOffice breaks between ")" and "(" (Unicode line breaking) when the token does not fit;
--   * no ligatures: LibreOffice forms the fi, fl, ff, ffi and ffl ligatures of an OpenType face such as TeX Gyre Schola
--     (it reads no w14:ligatures and shapes across runs), which typst and LaTeX do not set (lib/typst/xengine.typ,
--     xengine.sty) and Word does not by default; a joiner between the letters keeps them apart.
local WJ = "\u{2060}"
local function join_parens(s)
  s = s:gsub("%)%(", ")" .. WJ .. "(")
  s = s:gsub("f([fil])", "f" .. WJ .. "%1"):gsub("f([fil])", "f" .. WJ .. "%1")
  return s
end

local function join_inlines(l)
  return l:walk({ Str = function(el) el.text = join_parens(el.text); return el end })
end
local function runs(text, o)
  return xe.runs(join_parens(text), o)
end
-- A metadata value or a string read as markdown (smart quotes: "Court's" is set with a right quote, as typst's).
local function inl(x, o)
  if type(x) == "string" then
    local b = pandoc.read(x, "markdown+smart").blocks
    x = b[1] and b[1].content or pandoc.Inlines({})
  end
  if x ~= nil and type(x) == "table" and x.walk then x = join_inlines(x) end
  return xe.inl(x, o)
end
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.LEAD
local list_items = xe.list_items

-- Exact line spacing; single-spaced unless another pitch is given.
local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

local function tabs(kind, pos)
  return '<w:tabs><w:tab w:val="' .. kind .. '" w:pos="' .. pos .. '"/></w:tabs>'
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

local function need_meta(meta, k)
  if meta[k] == nil then error("cadc.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing). The fallback is the text's first words (at
-- least 8 letters and digits): a needle that runs over a page break is not found whole when the page's footnotes come
-- between its two halves in the PDF text.
local needles = {}
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
-- Words (FRAP 32(f)): the typst template's count of the markdown source (count-words), so every engine certifies the
-- same number
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
  local a = src:find("\n# Addendum[ \t]*\r?\n")
  if a then src = src:sub(1, a) end
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
-- Headings (typst show heading): level 1 centered bold 19.5 pt in 29 pt boxes, 24 / 20 pt around; level 2 bold 17 pt
-- in 25 pt boxes, 17 / 14 pt around; level 3 bold, half an inch in, single, 12 / 10 pt around
-- ---------------------------------------------------------------------------

-- LibreOffice sets a line of exact spacing with its baseline one font descent (0.711 em in TeX Gyre Schola) above the
-- bottom of the box when the face (1.635 em high) is taller than the box, where typst puts it at 0.8 of the box. The
-- pitches keep every line inside the margins wherever it falls (README); a line that opens a page by a hard break
-- moves down by the difference, taken from the space below it, so it lands where typst sets it and everything after
-- it stays put: 8.06 pt at 19.5 pt in 29 pt boxes, 7.09 pt at 17 pt in 25 pt, 5.75 pt at 14 pt in 21 pt, 6.67 pt at
-- 14 pt in the cover's 16.4 pt (twips).
-- `top`: the heading opens a page (no space above); `brk`: it also breaks the page (not after a section break);
-- `plain`: not an outline entry.
local DROP = { h1 = 161, h2 = 142, single = 115, cover = 133 }

local function h1(text, top, brk, plain)
  return para({ plain and "" or style("Heading1"), KEEP, brk and BREAK or "",
    spacing(top and DROP.h1 or 480, top and 400 - DROP.h1 or 400, 580),
    ind(0, nil, 0), jc("center") }, inl(text, { b = true, sz = 39 }))
end

local function heading_xml(level, content, top, brk)
  if level == 1 then return h1(content, top, brk) end
  if level == 2 then
    return para({ style("Heading2"), KEEP, brk and BREAK or "", spacing(top and DROP.h2 or 340, top and 280 - DROP.h2 or 280, 500), ind(0, nil, 0) },
      inl(content, { b = true, sz = 34 }))
  end
  return para({ style("Heading3"), KEEP, brk and BREAK or "", spacing(top and DROP.single or 240, top and 200 - DROP.single or 200), ind(TAB, nil, 0) }, inl(content, { b = true }))
end

-- One row of a table (typst listing-row): the text, a dot leader from three spaces after it to the page. The text
-- wraps before the page column (the right indent), hanging `hang`; the right tab sits beyond it.
local function row(text_xml, page, left, hang, before, col)
  return para({ LINES, xe.leader_tab(TEXT_W), spacing(before, 0), ind(left, hang, nil, col or PNUM) },
    text_xml .. runs(LEAD, {}) .. page)
end

-- ---------------------------------------------------------------------------
-- The table of authorities
-- ---------------------------------------------------------------------------

local KINDS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "regulation", "Regulations" },
  { "rule", "Rules" },
  { "other", "Other Authorities" },
}

local occurrences = {} -- the authority links, in document order: { key, index }

-- Sort key as typst's: case-insensitive, digit runs compared by value (8 digits).
local function sort_key(a)
  local s = stringify(a.sort or a.name or a.cite)
  return (s:lower():gsub("%d+", function(d) return string.rep("0", math.max(0, 8 - #d)) .. d end))
end

local function toa_rows(authorities)
  local used = {}
  for _, o in ipairs(occurrences) do used[o.key] = true end
  local out = {}
  for _, g in ipairs(KINDS) do
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
      out[#out + 1] = para({ KEEP, spacing(#out == 0 and 80 or 320, 40), ind(0, nil, 0) }, runs(g[2], { b = true }))
      for _, m in ipairs(members) do
        -- the distinct page labels of the authority, in document order (every page: Circuit Rule 28(a)(2))
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local lab = l and l.label or "00"
            if not seen[lab] or not l then
              seen[lab] = true
              pages[#pages + 1] = lab
            end
          end
        end
        local s = table.concat(pages, ", ")
        -- a list wider than the column widens it (typst: the larger of 36 pt and the list): TeX Gyre Schola digits
        -- are 0.556 em (156 twips at 14 pt), a comma and a space 0.278 em each
        local w = 0
        for c in s:gmatch(".") do w = w + (c:match("%d") and 156 or 78) end
        local text
        if m.a.name then
          text = inl(m.a.name, { i = g[1] == "case" }) .. runs(", ", {}) .. inl(m.a.cite, {})
        else
          text = inl(m.a.cite, {})
        end
        out[#out + 1] = row(text, runs(s, {}), 504, 504, 60, math.max(PNUM, w))
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body): fixed gaps, single spaced; counsel in rows of two columns
-- ---------------------------------------------------------------------------

local function cover(meta)
  local gap, caption, major = 200, 224, 280
  local function spacing(before, after) return xe.spacing(before, after, COVER) end
  local out = {}
  local function add(x) out[#out + 1] = x end
  local function center(x, before)
    add(para({ KEEP, spacing(before or 0, 0), ind(0, nil, 0), jc("center") }, x))
  end
  -- the first line moves down into place (DROP.cover), the gap after it gives that back
  center(inl(stringify(need_meta(meta, "oral_argument")):upper(), { b = true }), DROP.cover)
  center(runs("No. ", {}) .. inl(need_meta(meta, "case_number"), {}), gap - DROP.cover)
  center(runs("UNITED STATES COURT OF APPEALS", {}), gap)
  center(runs("FOR THE DISTRICT OF COLUMBIA CIRCUIT", {}), 56)
  for i, side in ipairs(need_meta(meta, "caption")) do
    if i > 1 then center(runs("v.", {}), 112) end
    for k, n in ipairs(side.names) do center(inl(n, {}), k == 1 and (i == 1 and caption or 112) or 0) end
    center(inl(side.designation, {}), 84)
  end
  center(inl(need_meta(meta, "proceeding"), {}), caption)
  if meta.district_court_case then center(inl(meta.district_court_case, {}), 84) end
  if meta.judge then center(inl(meta.judge, {}), 84) end
  center(inl(stringify(need_meta(meta, "brief_title")):upper(), { b = true }), major)
  -- counsel (FRAP 32(a)(2)(F)): rows of two groups, a borderless table of two 225.6 pt columns 16.8 pt apart
  local groups = need_meta(meta, "counsel")
  local function cell(g, w, right, before)
    local xml = {}
    if g then
      local ls = {}
      for _, n in ipairs(g.names) do ls[#ls + 1] = inl(n, {}) end
      for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = inl(l, { i = true }) end
      for li, x in ipairs(ls) do xml[#xml + 1] = para({ spacing(li == 1 and before or 0, 0), ind(0, nil, 0) }, x) end
    else
      xml[1] = para({ spacing(0, 0) }, "")
    end
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/><w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="'
      .. right .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(xml) .. "</w:tc>"
  end
  local rows = {}
  for i = 1, #groups, 2 do
    local before = i == 1 and major or 168
    rows[#rows + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. cell(groups[i], COUNSEL_W + GUTTER, GUTTER, before)
      .. cell(groups[i + 1], COUNSEL_W, 0, before) .. "</w:tr>"
  end
  add('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="'
    .. (COUNSEL_W + GUTTER) .. '"/><w:gridCol w:w="' .. COUNSEL_W .. '"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>")
  if meta.date then add(para({ spacing(major, 0), ind(0, nil, 0) }, inl(meta.date, {}))) end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Certificate as to parties, signature, certificates
-- ---------------------------------------------------------------------------

-- Paragraphs of a markdown text (a metadata value), as body paragraphs: double spaced, the first line indented.
local function text_paras(x, first_indent)
  local blocks
  if type(x) == "string" then blocks = pandoc.read(x, "markdown+smart").blocks
  elseif pandoc.utils.type(x) == "Blocks" then blocks = x
  else blocks = { pandoc.Para(x) } end
  local out = {}
  for _, b in ipairs(blocks) do
    out[#out + 1] = para({ spacing(0, 0, BODY), ind(0, nil, first_indent or TAB) }, inl(b.content, {}))
  end
  return table.concat(out)
end

local function certificate(meta)
  local c = need_meta(meta, "certificate")
  local out = { h1("CERTIFICATE AS TO PARTIES, RULINGS, AND RELATED CASES, AND RULE 26.1 DISCLOSURE", true),
    text_paras("Pursuant to Circuit Rule 28(a)(1) and Federal Rule of Appellate Procedure 26.1, the undersigned counsel certifies as follows:") }
  for _, p in ipairs({ { "A. Parties and Amici", c.parties }, { "B. Rulings Under Review", c.rulings },
    { "C. Related Cases", c.related }, { "Rule 26.1 Disclosure", c.disclosure } }) do
    out[#out + 1] = para({ KEEP, spacing(224, 0, BODY), ind(0, nil, 0) }, runs(p[1], { b = true }))
    out[#out + 1] = text_paras(p[2])
  end
  return table.concat(out)
end

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  local function add(x) out[#out + 1] = x end
  add(para({ KEEP, tabs("left", SIG_COL), spacing(240, 0), ind(0, nil, 0) },
    (meta.date and inl(meta.date, {}) or "") .. runs("\t", {}) .. runs("Respectfully submitted,", {})))
  add(para({ KEEP, spacing(140, 0), ind(SIG_COL, nil, 0) }, inl("/s/ " .. signer, {})))
  local ls = sig.lines or {}
  add(para({ #ls > 0 and KEEP or LINES, spacing(0, 0), ind(SIG_COL, nil, 0) }, inl(signer, {})))
  for i, l in ipairs(ls) do
    add(para({ i == #ls and LINES or KEEP, spacing(i == 1 and 20 or 0, 0), ind(SIG_COL, nil, 0) }, inl(l, { i = true })))
  end
  return table.concat(out)
end

local function cert_signature(meta)
  local signer = stringify(need_meta(meta, "signature").signer)
  return para({ KEEP, spacing(240, 0), ind(CERT_SIG, nil, 0) }, inl("/s/ " .. signer, {}))
    .. para({ LINES, spacing(0, 0), ind(CERT_SIG, nil, 0) }, inl(signer, {}))
end

local function certificates(meta, words)
  return h1("CERTIFICATE OF COMPLIANCE", true, true)
    .. para({ spacing(0, 0, BODY), ind(0, nil, 0) }, inl("This document complies with the type-volume limitations of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by the Federal Rules of Appellate Procedure and this Court's rules, this document contains " .. group_digits(words) .. " words, as calculated by my word processing software.", {}))
    .. para({ spacing(224, 0, BODY), ind(0, nil, 0) }, inl("This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because this document has been prepared in a proportionally spaced typeface, 14-point " .. TYPEFACE .. ", using " .. stringify(need_meta(meta, "word_processor")) .. ".", {}))
    .. cert_signature(meta)
    .. h1("CERTIFICATE OF SERVICE", true, true)
    .. para({ spacing(0, 0, BODY), ind(0, nil, TAB) }, inl("I hereby certify that, on " .. stringify(need_meta(meta, "date")) .. ", the foregoing document was served through the Court's ECF system on counsel for all parties.", {}))
    .. cert_signature(meta)
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

-- Markers such as (A) or I. that open a paragraph are text, as written (typst's markdown reader knows only "1." and
-- "1)" as list markers); pandoc reads them as list items, which would be renumbered.
local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do out = out .. v[2]; n = n - v[1] end
  end
  return out
end

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
  for _, k in ipairs({ "case_number", "oral_argument", "caption", "proceeding", "brief_title", "counsel", "date",
    "word_processor", "certificate", "signature" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  doc = doc:walk({ OrderedList = ordered_list })
  local src = source_body()
  local words = count_md(src)
  if words > WORD_LIMIT then
    error("cadc.lua: body is " .. words .. " words; FRAP 28.1(e)(2)(A)(i) allows " .. WORD_LIMIT)
  end

  -- split at `# Addendum`
  local blocks, addendum = {}, nil
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and stringify(b.content) == "Addendum" then
      addendum = {}
    elseif addendum then
      addendum[#addendum + 1] = b
    else
      blocks[#blocks + 1] = b
    end
  end

  need("S:cert", "B", "CERTIFICATE AS TO PARTIES, RULINGS, AND RELATED CASES, AND RULE 26.1 DISCLOSURE", "Pursuant")
  need("S:toa", "B", "TABLE OF AUTHORITIES", "")
  if meta.glossary then
    local g = meta.glossary[1]
    need("S:gloss", "B", "GLOSSARY", stringify(g.abbr) .. " " .. stringify(g.meaning))
  end

  -- The body, in order: headings (outline, needles, contents entries) and citations (needles).
  local toc = {}
  local body = {}
  local h_n = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      need(id, "B", stringify(b.content), nxt)
      if b.level <= 2 then toc[#toc + 1] = { id = id, level = b.level, content = b.content } end
      body[#body + 1] = raw(heading_xml(b.level, strip_links({ pandoc.Plain(b.content) })[1].content, #body == 0))
    else
      scan_blocks({ b }, false)
      for _, x in ipairs(list_items(b)) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("cadc.lua: cited authority `" .. o.key .. "` is not in the authorities registry")
    end
  end
  -- the table of authorities' needle goes on with its first group title (the contents list the same heading)
  for _, g in ipairs(KINDS) do
    local used = false
    for _, o in ipairs(occurrences) do
      local a = authorities[o.key]
      if a and a.kind and stringify(a.kind) == g[1] then used = true end
    end
    if used then
      for _, n in ipairs(needles) do
        if n.id == "S:toa" then n.needle = norm("TABLE OF AUTHORITIES " .. g[2]):sub(1, NEEDLE_MAX) end
      end
      break
    end
  end
  body = strip_links(body)
  -- The last paragraph is not broken and stays with the signature block (typst: one unbreakable block, unless the
  -- brief's last markdown block is a heading or a footnote definition).
  local last = body[#body]
  if keep_last(src) and last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, BODY), ind(0, nil, TAB) }, xe.inl(last.content, {})))
  end

  need("H:compliance", "B", "CERTIFICATE OF COMPLIANCE", "This document complies")
  need("H:service", "B", "CERTIFICATE OF SERVICE", "I hereby certify")
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: each section starts at the page of a needle (format, prefix)
  nl[#nl + 1] = "#section\tS:cert\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  add(raw(cover(meta)))
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): the certificate as to parties, the contents, the authorities, the glossary
  add(raw(certificate(meta)))
  add(raw(h1("TABLE OF CONTENTS", true, true, true)))
  local items = { { id = "S:cert", level = 1, content = "CERTIFICATE AS TO PARTIES, RULINGS, AND RELATED CASES, AND RULE 26.1 DISCLOSURE" },
    { id = "S:toa", level = 1, content = "TABLE OF AUTHORITIES" } }
  if meta.glossary then items[#items + 1] = { id = "S:gloss", level = 1, content = "GLOSSARY" } end
  for _, h in ipairs(toc) do items[#items + 1] = h end
  items[#items + 1] = { id = "H:compliance", level = 1, content = "CERTIFICATE OF COMPLIANCE" }
  items[#items + 1] = { id = "H:service", level = 1, content = "CERTIFICATE OF SERVICE" }
  for _, it in ipairs(items) do
    local left = it.level == 1 and TAB or 2 * TAB
    add(raw(row(inl(it.content, {}), runs(label_of(it.id), {}), left, TAB, 80)))
  end
  add(raw(h1("TABLE OF AUTHORITIES", true, true)))
  add(raw(toa_rows(authorities)))
  if meta.glossary then
    add(raw(h1("GLOSSARY", true, true)))
    for i, g in ipairs(meta.glossary) do
      add(raw(para({ tabs("left", GLOSS), spacing(i == 1 and 0 or 100, 0), ind(GLOSS, GLOSS) },
        inl(g.abbr, {}) .. runs("\t", {}) .. inl(g.meaning, {}))))
    end
  end
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...), the signature, and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(certificates(meta, words)))
  if addendum then
    local first = true
    for _, b in ipairs(strip_links(addendum)) do
      if b.t == "Header" then
        add(raw(heading_xml(b.level, b.content, first, first)))
      elseif first then
        add(raw(para({ BREAK }, "")))
        add(b)
      else
        add(b)
      end
      first = false
    end
  end

  doc.blocks = out
  doc.meta.date = nil -- the date is printed by the signature blocks only, not by pandoc at the top
  doc.meta.title = nil
  return doc
end
