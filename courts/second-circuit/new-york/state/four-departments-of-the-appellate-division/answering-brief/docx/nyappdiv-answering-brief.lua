-- New York Appellate Division (all four Departments): answering brief (respondent), docx engine (docs/DOCX.md). The
-- document as Word paragraphs, so that it reads and breaks as typst/nyappdiv-answering-brief.typ does: the cover
-- (22 NYCRR 1250.8(b)), the table of contents and the table of authorities with their page numbers, the body with its
-- section and point headings, block quotations and footnotes, the last paragraph kept with the signature block, the
-- printing specifications statement with the word count (1250.8(j)) and the affidavit of service (blanks only).
-- Every case-specific word comes from the sample's frontmatter (as written, $FORMBOOK_META) and body, never from this
-- file. Fonts and the paragraph styles are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 560 the body, 322 a single line and a footnote line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run. A paragraph that
-- anchors a footnote stays a pandoc paragraph (Body Text), so that pandoc writes the note.
--
-- The tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter
-- writes ($FORMBOOK_NEEDLES: the two table titles, the start of the body, each heading, each citation, in document
-- order) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle. The front
-- matter is numbered i, ii; the body from 1; the cover carries no number.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local NAME = "nyappdiv-answering-brief"
local WORD_LIMIT = 14000                 -- 22 NYCRR 1250.8(f)(2): computer-generated respondent's brief

local BODY, SINGLE = 560, 322            -- typst pitch-body 28 pt, pitch-single 16.1 pt
local BLANK = SINGLE                     -- typst blank
local TEXTW = 9360                       -- 6.5 in
local INDENT = 720                       -- typst para-indent
local TAB = 720                          -- typst heading-tab
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-col, toa-col
local TOA_HANG = 720                     -- typst toa-hang
local TOC_ABOVE, TOA_ABOVE = 160, 80     -- typst toc-above 8 pt, toa-above 4 pt
local GROUP_ABOVE, GROUP_BELOW = 320, 80 -- typst group-above 16 pt, group-below 4 pt
local H_ABOVE, H_BELOW = 320, 240        -- typst heading-above 16 pt, heading-below 12 pt
local SUB_ABOVE, SUB_BELOW = 240, 120    -- typst sub-above 12 pt, sub-below 6 pt
local QUOTE, QUOTE_PAR = 280, 240        -- typst quote-gap 14 pt, quote-par 12 pt
local COVER_GAP = 160                    -- typst cover-gap 8 pt
local DOCKET_COL, ARG_COL = 4464, 4464   -- typst docket-col, arg-col 3.1 in
local DESIG = 4680                       -- typst designation-left 3.25 in
local COUNSEL = 4464                     -- typst counsel-left 3.1 in
local SHORT_RULE = 2880                  -- typst short-rule 2 in
local CLOSING = 4680                     -- typst closing-left 3.25 in
local SIG_GUTTER = 576                   -- typst sig-gutter 0.4 in
local SIG_GAP = 320                      -- typst sig-gap 16 pt
local OATH_COL = 4320                    -- typst oath-col 3 in
local NOTARY = 4680                      -- typst notary-left 3.25 in
local TOC_DEPTH = 4
local PASSIM_AT = 7
local NEEDLE_MAX = 60
local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

-- The page number: centred in a single-pitch line whose box ends 0.5 in above the page edge (typst footer-distance).
local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:left="0" w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'

local function fail(msg) error(NAME .. ": " .. msg, 0) end

local function read_file(path)
  if path == nil or path == "" then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The frontmatter as written: typst prints the plain fields as typed and reads the others as inline markdown.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

local function need(t, key)
  if t[key] == nil then fail("missing required metadata field `" .. key .. "`") end
  return t[key]
end

-- Break opportunities as typst has them: none inside a token of adjacent parentheses ("63(12)(a)"; xengine boxes
-- it): a word joiner between ")" and "("; one after a slash followed by a letter: a zero-width space. Neither shows
-- in the PDF text.
local function brk(t)
  return (t:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1"))
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."): a no-break space. A doubled sign stays with its number.
local function bind(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    local a = l[i]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function upper_inl(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A frontmatter string as typst's inl() reads it (cmarker, CommonMark with smart punctuation); a string that is not
-- one paragraph there stays as typed.
local function md(s)
  s = tostring(s)
  local doc = pandoc.read(s, "commonmark+smart")
  if #doc.blocks == 1 and (doc.blocks[1].t == "Para" or doc.blocks[1].t == "Plain") then
    return bind(pandoc.Inlines(doc.blocks[1].content):walk({ Str = break_rules }))
  end
  return pandoc.Inlines({ pandoc.Str(s) })
end

local function R(text, o) return xe.runs(brk(tostring(text)), o) end
local function I(s, o) return xe.inl(md(s), o) end
local function U(s, o) return xe.inl(upper_inl(md(s)), o) end

-- A blank to fill in by hand (typst fill-in): a run of underscores.
local function fill(n) return string.rep("_", n) end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs, bdr }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.bdr then props[#props + 1] = o.bdr end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function left_tab(pos) return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>' end

-- Single-spaced lines (typst line-stack): each item an xml string, { xml, o } with its own paragraph options, or ""
-- (a blank single line).
local function stack(items, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for k, x in ipairs(items) do
    if x == "" then
      gap = gap + BLANK
    else
      local xml, po = x, {}
      if type(x) == "table" then xml, po = x[1], x[2] end
      local q = { before = gap, left = o.left, right = o.right, jc = o.jc, keep = o.keep_all or (o.keep and k < #items),
        tabs = o.tabs }
      for key, v in pairs(po) do q[key] = v end
      out[#out + 1] = p(xml, q)
      gap = 0
    end
  end
  if #out == 0 then out[1] = p("") end
  return table.concat(out)
end

-- A one-row table with fixed column widths and no cell margins; the row is not split across pages.
local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. cells[i] .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- A section's properties: letter paper, 1 in margins (1250.8(h)), its footer and page numbering.
local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. sect_pr(footer, fmt)
    .. '</w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Word count (typst count-words, rule for rule, on the markdown after the frontmatter)
-- ---------------------------------------------------------------------------

local function source_md()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local text = read_file(f) or ""
  local a, b = text:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if not a then fail("the sample must start with a YAML frontmatter block") end
  return text:sub(b + 1)
end

local function count_words(s)
  s = "\n" .. s
  s = s:gsub("<!%-%-.-%-%->", " ")
  s = s:gsub("\n%[%^[^%]]+%]:", "\n ")
  s = s:gsub("%[%^[^%]]+%]", "")
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[-*+][ \t]+", "\n")
  s = s:gsub("\n[ \t]*%d+[.)][ \t]+", "\n")
  s = s:gsub("\\(.)", "%1")
  s = s:gsub("%*", "")
  s = s:gsub("([%s%(%[\"])_", "%1"):gsub("\u{201C}_", "\u{201C}")
  s = s:gsub("_([%s.,;:%)%]\"!?])", "%1"):gsub("_\u{201D}", "\u{201D}"):gsub("_$", "")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s) return (s:lower():gsub("[^a-z0-9]", "")) end

local needles = {}
local function needle(id, kind, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local text = read_file(os.getenv("FORMBOOK_PAGES"))
  if not text then return end
  for l in text:gmatch("[^\n]+") do
    local id, _, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
end

-- The citations of a block, in document order, as needles (B in the body, N in a footnote): the link text and the
-- words after it.
local cites = {}
local scan_blocks
local function scan_inlines(l, in_note)
  for i, el in ipairs(l) do
    if el.t == "Link" and el.target:match("^toa:") then
      local rest = {}
      for j = i + 1, #l do rest[#rest + 1] = l[j] end
      local id = "A:" .. (#cites + 1)
      cites[#cites + 1] = { id = id, key = el.target:sub(5) }
      needle(id, in_note and "N" or "B", stringify(el.content), stringify(rest):sub(1, 40))
    elseif el.t == "Note" then
      scan_blocks(el.content, true)
    elseif el.content and type(el.content) ~= "string" and el.t ~= "Link" then
      scan_inlines(el.content, in_note)
    end
  end
end
scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" then scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

local function has_note(b)
  local found = false
  pandoc.Blocks({ b }):walk({ Note = function() found = true end })
  return found
end

-- ---------------------------------------------------------------------------
-- Cover (1250.8(b))
-- ---------------------------------------------------------------------------

-- The double rule (a heavy line over a light one, typst double-rule) and the short rule under the title: empty
-- paragraphs with borders.
local function double_rule()
  return p("", { before = COVER_GAP, after = COVER_GAP, line = 20,
    bdr = '<w:pBdr><w:top w:val="single" w:sz="12" w:space="0" w:color="000000"/>'
      .. '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>' })
end
local function title_rule()
  local side = (TEXTW - SHORT_RULE) // 2
  return p("", { before = COVER_GAP, after = COVER_GAP, line = 20, left = side, right = side,
    bdr = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>' })
end

local function cover()
  local out = {}
  local arg = need(RAW, "argument")
  local docket = { I(need(RAW, "docket")) }
  if RAW.county_clerk_index ~= nil then docket[#docket + 1] = R(RAW.county_clerk_index) end
  local arg_lines
  if arg.presenter ~= nil then
    arg_lines = { R("To be Argued by:"), U(arg.presenter, { b = true }),
      R("(Time Requested: " .. tostring(arg.time_requested) .. ")") }
  else
    arg_lines = { R("Submitted without oral argument") }
  end
  out[#out + 1] = table_xml({ DOCKET_COL, TEXTW - DOCKET_COL - ARG_COL, ARG_COL },
    { stack(docket), stack({}), stack(arg_lines) })
  out[#out + 1] = stack({ R("New York Supreme Court", { b = true }),
    R("Appellate Division\u{2014}" .. tostring(need(RAW, "department"))) }, { above = COVER_GAP, jc = "center" })
  out[#out + 1] = double_rule()
  local cap = {}
  for i, side in ipairs(list(need(RAW, "caption"))) do
    if i > 1 then
      cap[#cap + 1] = { side.joiner ~= nil and I(side.joiner) or R("\u{2013} against \u{2013}"), { jc = "center" } }
    end
    for _, n in ipairs(list(side.names)) do cap[#cap + 1] = { I(n), { jc = "center" } } end
    cap[#cap + 1] = { I(side.designation), { left = DESIG } }
  end
  if RAW.caption_note ~= nil then cap[#cap + 1] = { I(RAW.caption_note), { jc = "center" } } end
  out[#out + 1] = stack(cap)
  out[#out + 1] = double_rule()
  out[#out + 1] = stack({ U(need(RAW, "brief_title"), { b = true }) }, { jc = "center" })
  out[#out + 1] = title_rule()
  local c = {}
  for _, g in ipairs(list(need(RAW, "counsel"))) do
    c[#c + 1] = U(g.firm, { b = true })
    for _, l in ipairs(list(g.lines)) do c[#c + 1] = I(l) end
    c[#c + 1] = ""
  end
  c[#c + 1] = I(need(RAW, "attorneys_for"), { i = true })
  out[#out + 1] = stack(c, { left = COUNSEL })
  out[#out + 1] = double_rule()
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings
-- ---------------------------------------------------------------------------

local function roman(n)
  local s = ""
  for _, v in ipairs({ { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

-- typst heading-label: under the Argument I. / A. / 1. / a.; elsewhere A. / 1. / a. / (1).
local function heading_label(level, n, argument)
  if level < 2 or level > 5 then fail("headings deeper than level 5 are not supported") end
  if argument then
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

-- A section heading: bold capitals, centred. `top`: it opens a page.
local function section_heading(content_xml, top, pre)
  return p(content_xml, { pre = pre, keep = true, before = top and 0 or H_ABOVE, after = H_BELOW, jc = "center" })
end

local function heading(h, top)
  if h.level == 1 then return section_heading(xe.inl(upper_inl(h.content), { b = true }), top) end
  local ind = (h.level - 2) * TAB
  local point = h.argument and h.level == 2
  local body = xe.inl(point and upper_inl(h.content) or h.content, { b = true, i = h.level >= 4 })
  return p(R(h.label .. "\t", { b = true, i = h.level >= 4 }) .. body, { keep = true,
    before = top and 0 or SUB_ABOVE, after = SUB_BELOW, left = ind + TAB, hanging = TAB, tabs = left_tab(ind + TAB) })
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities
-- ---------------------------------------------------------------------------

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging, col, before, label_tab)
  local tabs = '<w:tabs>' .. (label_tab and ('<w:tab w:val="left" w:pos="' .. label_tab .. '"/>') or "")
    .. '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = tabs,
    before = before, left = left, hanging = hanging, right = col })
end

local function toc(entries)
  local out = { section_heading(R("TABLE OF CONTENTS", { b = true }), true),
    p(R("Page", { b = true, u = true }), { keep = true, jc = "right" }) }
  for _, e in ipairs(entries) do
    if e.level <= TOC_DEPTH then
      local page = R(labels[e.id] or "0")
      if e.label == nil then
        out[#out + 1] = row(xe.inl(upper_inl(e.content)), page, TAB, TAB, TOC_COL, TOC_ABOVE)
      else
        local ind = (e.level - 2) * TAB
        local title = (e.argument and e.level == 2) and upper_inl(e.content) or e.content
        out[#out + 1] = row(R(e.label .. "\t") .. xe.inl(title), page, ind + TAB, TAB, TOC_COL, 0, ind + TAB)
      end
    end
  end
  return table.concat(out)
end

local function sort_key(a)
  local s = a.sort or ((a.name or "") .. " " .. a.cite)
  return (pandoc.text.lower(stringify(md(s))):gsub("[^a-z0-9 ]", ""))
end

local function toa(authorities)
  local out = { section_heading(R("TABLE OF AUTHORITIES", { b = true }), true, xe.BREAK) }
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then fail("link `toa:" .. c.key .. "` has no entry under `authorities:` in the frontmatter") end
    pages[c.key] = pages[c.key] or {}
    seen[c.key] = seen[c.key] or {}
    local l = labels[c.id] or "0"
    if not seen[c.key][l] then
      seen[c.key][l] = true
      pages[c.key][#pages[c.key] + 1] = l
    end
  end
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if a.kind == g[1] and pages[key] then members[#members + 1] = { key = key, a = a, sort = sort_key(a) } end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      local title = R(g[2], { b = true })
      local o = { before = first and 0 or GROUP_ABOVE, after = GROUP_BELOW, keep = true }
      if first then
        title = title .. R("\t") .. R("Page(s)", { b = true, u = true })
        o.tabs = '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>'
      end
      first = false
      out[#out + 1] = p(title, o)
      for _, mm in ipairs(members) do
        local a = mm.a
        local text
        if a.name ~= nil then text = I(a.name, { i = g[1] == "case" }) .. R(", ") .. I(a.cite)
        else text = I(a.cite) end
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and R("passim", { i = true }) or R(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_HANG, TOA_HANG, TOA_COL, TOA_ABOVE)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature, printing statement, proof of service
-- ---------------------------------------------------------------------------

-- typst signature-block: date and place, the closing from the middle, each firm a column, whom they represent; kept
-- together and with the paragraph before it.
local function signature()
  local sig = need(RAW, "signature")
  local out = { stack({ R(sig.date), R(sig.place) }, { above = H_ABOVE, keep_all = true }) }
  if sig.closing ~= nil then out[#out + 1] = stack({ I(sig.closing) }, { left = CLOSING, keep_all = true }) end
  local cells = {}
  for _, b in ipairs(list(sig.blocks)) do
    local l = { U(b.firm, { b = true }) }
    if b.by ~= nil then l[#l + 1] = R("By: " .. fill(18)) end
    for _, n in ipairs(list(b.names)) do l[#l + 1] = I(n) end
    for _, x in ipairs(list(b.lines)) do l[#l + 1] = I(x, { i = true }) end
    cells[#cells + 1] = l
  end
  if #cells == 1 then
    out[#out + 1] = stack(cells[1], { above = SIG_GAP, keep_all = true })
  else
    -- Word has no space above a table: a paragraph of that height (typst: the grid's block above sig-gap)
    out[#out + 1] = p("", { line = SIG_GAP, keep = true })
    local n = #cells
    local w = (TEXTW - (n - 1) * SIG_GUTTER) // n
    local widths, xs = {}, {}
    for k, l in ipairs(cells) do
      if k > 1 then
        widths[#widths + 1] = SIG_GUTTER
        xs[#xs + 1] = stack({})
      end
      widths[#widths + 1] = k == n and (TEXTW - (n - 1) * (w + SIG_GUTTER)) or w
      xs[#xs + 1] = stack(l, { keep_all = true })
    end
    out[#out + 1] = table_xml(widths, xs)
  end
  out[#out + 1] = stack({ I(sig.attorneys_for, { i = true }) }, { above = SIG_GAP })
  return table.concat(out)
end

local function printing_statement(words)
  return table.concat({
    p(R("I hereby certify pursuant to 22 NYCRR 1250.8(j) that the foregoing brief was prepared on a computer."),
      { line = BODY, first = INDENT }),
    p(R("A proportionally spaced typeface was used, as follows:"), { line = BODY, first = INDENT }),
    stack({ R("Name of typeface: Times New Roman"), R("Point size: 14"), R("Line spacing: Double") },
      { above = QUOTE, left = INDENT }),
    p(R("Word Count.", { b = true }) .. R(" The total number of words in this brief, inclusive of point headings and "
      .. "footnotes and exclusive of pages containing the table of contents, table of citations, proof of service, and "
      .. "this statement, is " .. group_digits(words) .. "."), { line = BODY, first = INDENT, before = QUOTE }),
  })
end

local function affidavit()
  local tabs = left_tab(OATH_COL)
  return table.concat({
    section_heading(R("AFFIDAVIT OF SERVICE", { b = true }), true, xe.BREAK),
    stack({ R("STATE OF NEW YORK\t)"), R("\t) ss.:"), R("COUNTY OF " .. fill(14) .. "\t)") }, { tabs = tabs }),
    p(R(fill(26) .. ", being duly sworn, deposes and says: deponent is not a party to this action, is over 18 years "
      .. "of age, and resides at " .. fill(24) .. "."), { line = BODY, first = INDENT, before = BLANK }),
    p(R("On the " .. fill(7) .. " day of " .. fill(12) .. ", 20" .. fill(4) .. ", deponent served the within brief "
      .. "upon each attorney for each party to this appeal, at the address designated by that attorney for that "
      .. "purpose, by " .. fill(24) .. ", and by " .. fill(14) .. "."), { line = BODY, first = INDENT }),
    stack({ R(fill(24)), R("Sworn to before me this"), R(fill(7) .. " day of " .. fill(12) .. ", 20" .. fill(4)), "",
      R(fill(24)), R("Notary Public") }, { above = 2 * BLANK, left = NOTARY }),
  })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body block: raw paragraphs, or (a paragraph that anchors a footnote) a pandoc paragraph in Body Text.
local function body_block(b, out, keep)
  if b.t == "Para" or b.t == "Plain" then
    if has_note(b) then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = keep and "Body Text Keep" or "Body Text" })
    else
      out[#out + 1] = xe.raw(p(xe.inl(b.content), { line = BODY, first = INDENT, keep = keep }))
    end
  elseif b.t == "BlockQuote" then
    for k, q in ipairs(b.content) do
      if (q.t ~= "Para" and q.t ~= "Plain") or has_note(q) then fail("unsupported block in a quotation: " .. q.t) end
      out[#out + 1] = xe.raw(p(xe.inl(q.content), { before = k == 1 and QUOTE or QUOTE_PAR,
        after = k == #b.content and QUOTE or 0, left = INDENT, right = INDENT, keep = keep, lines = true }))
    end
  else
    fail("unsupported block " .. b.t)
  end
end

local function finish(doc)
  load_pages()
  local words = count_words(source_md())
  if words > WORD_LIMIT then
    fail("the brief has " .. words .. " words; 22 NYCRR 1250.8(f)(2) allows " .. WORD_LIMIT .. " for a respondent's brief")
  end
  for _, k in ipairs({ "docket", "department", "argument", "caption", "brief_title", "counsel", "attorneys_for", "signature" }) do
    need(RAW, k)
  end
  local authorities = RAW.authorities or {}
  local blocks = doc.blocks

  -- the blocks kept with the signature: the last paragraph, and the heading right before it
  local tail = #blocks
  if blocks[tail - 1] and blocks[tail - 1].t == "Header" then tail = tail - 1 end

  -- heading labels (the counters restart under each level 1 heading)
  local c = { 0, 0, 0, 0, 0 }
  local argument = false
  local heads = {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = b.level
      if lv > 5 then fail("headings deeper than level 5 are not supported") end
      c[lv] = c[lv] + 1
      for j = lv + 1, 5 do c[j] = 0 end
      if lv == 1 then argument = pandoc.text.lower(stringify(b.content)) == "argument" end
      local h = { level = lv, content = b.content, argument = argument }
      if lv > 1 then h.label = heading_label(lv, c[lv], argument) end
      h.text = (h.label and (h.label .. " ") or "") .. stringify(b.content)
      heads[i] = h
    end
  end

  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Cases")
  needle("S:body", "B", heads[1] and heads[1].text or stringify(blocks[1]), "")
  local entries, body = {}, {}
  for i, b in ipairs(blocks) do
    local keep = i >= tail
    if b.t == "Header" then
      local h = heads[i]
      h.id = "H:" .. (#entries + 1)
      local nxt = heads[i + 1] and heads[i + 1].text or (blocks[i + 1] and stringify(blocks[i + 1]) or "")
      needle(h.id, "B", h.text, nxt:sub(1, 40))
      entries[#entries + 1] = h
      body[#body + 1] = xe.raw(heading(h, i == 1))
    else
      scan_blocks({ b }, false)
      body_block(b, body, keep)
    end
  end
  body[#body + 1] = xe.raw(signature())

  -- the printing specifications statement (in the contents) and the affidavit of service, each on a new page
  local ps = { id = "H:" .. (#entries + 1), level = 1, content = pandoc.Inlines({ pandoc.Str("Printing"), pandoc.Space(),
    pandoc.Str("Specifications"), pandoc.Space(), pandoc.Str("Statement") }) }
  entries[#entries + 1] = ps
  needle(ps.id, "B", "PRINTING SPECIFICATIONS STATEMENT", "I hereby certify")
  body[#body + 1] = xe.raw(section_heading(R("PRINTING SPECIFICATIONS STATEMENT", { b = true }), true, xe.BREAK)
    .. printing_statement(words) .. affidavit())

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tS:body\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrNy\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrNy", "decimal"))

  local out = {
    xe.raw(cover() .. section("rIdFtrNone") .. toc(entries) .. toa(authorities) .. section("rIdFtrNy", "lowerRoman")),
  }
  for _, x in ipairs(body) do out[#out + 1] = x end
  -- a citation link prints its text only; the break rules on what pandoc writes itself (paragraphs with notes)
  local result = pandoc.Blocks(out):walk({ Link = function(el) return el.content end }):walk({ Inlines = xe.inlines })
  return pandoc.Pandoc(result, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
