-- New York Appellate Division, Fourth Department: opening brief (appellant), docx engine (docs/DOCX.md). The
-- document as Word paragraphs, so that it reads and breaks as typst/nyappdiv-opening-brief.typ does: the cover
-- (22 NYCRR 1250.8(a)), the table of contents and the table of authorities with their page numbers (1250.8(b)(1)-(2)),
-- the body with its section, point and lettered headings, block quotations, the conclusion kept with the signature,
-- and the printing specifications statement with the word count (1250.8(j)). Every case-specific word comes from the
-- sample's frontmatter (as written, $FORMBOOK_META) and body, never from this file. Fonts and the paragraph styles
-- are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 560 the body, 322 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
--
-- The tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter
-- writes ($FORMBOOK_NEEDLES: the two table titles, each heading, each citation, in document order) in the LibreOffice
-- PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle. The front matter is numbered i, ii; the
-- body from 1; the cover carries no number.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local NAME = "nyappdiv-opening-brief"
local WORD_LIMIT = 14000                 -- 22 NYCRR 1250.8(f)(2): appellant's computer-generated brief
local FOOTNOTES_ALLOWED = false          -- typst footnotes-allowed (Part 1000; see README)
local COURT_LINES = { "SUPREME COURT OF THE STATE OF NEW YORK", "APPELLATE DIVISION", "FOURTH JUDICIAL DEPARTMENT" }

local BODY, SINGLE = 560, 322            -- typst pitch-body 28 pt, pitch-single 16.1 pt
local BLANK = SINGLE                     -- typst blank: a blank single line
local TEXTW = 9360                       -- 6.5 in
local INDENT = 720                       -- typst para-indent
local TAB = 720                          -- typst heading-tab
local POINT_BOX = 1440                   -- typst point-box
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-col, toa-col
local TOA_HANG = 720                     -- typst toa-hang
local TOC_ABOVE, TOA_ABOVE = 160, 80     -- typst toc-above 8 pt, toa-above 4 pt
local H_ABOVE, H_BELOW = 320, 240        -- typst heading-above 16 pt, heading-below 12 pt
local POINT_GAP = 120                    -- typst point-gap 6 pt
local SUB_ABOVE, SUB_BELOW = 240, 120    -- typst sub-above 12 pt, sub-below 6 pt
local QUOTE = 280                        -- typst quote-gap 14 pt
local CAP_INSET = 720                    -- typst caption-inset
local ARG_COL = 3600                     -- typst arg-col 2.5 in
local COUNSEL = 3600                     -- typst counsel-left 2.5 in
local SIG = 4320                         -- typst sig-left 3 in
local TOC_DEPTH = 4
local PASSIM_AT = 7
local NEEDLE_MAX = 60
local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Statutes" }, { "regulation", "Regulations" },
  { "rule", "Rules" }, { "constitution", "Constitutional Provisions" }, { "other", "Other Authorities" },
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

-- Break opportunities as typst has them: none inside a token of adjacent parentheses ("1250.8(f)(2)"; xengine boxes
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

-- Plain text (typst prints a string field as typed) as runs.
local function R(text, o) return xe.runs(brk(tostring(text)), o) end
local function I(s, o) return xe.inl(md(s), o) end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function left_tab(pos) return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>' end

-- Single-spaced lines (typst line-stack): each item an xml string or "" (a blank single line).
local function stack(items, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for k, x in ipairs(items) do
    if x == "" then
      gap = gap + BLANK
    else
      out[#out + 1] = p(x, { before = gap, left = o.left, right = o.right, jc = o.jc, keep = o.keep and k < #items or o.keep_all })
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

-- The citations of a block, in document order, as needles: the link text and the words after it.
local cites = {}
local function scan_inlines(l)
  for i, el in ipairs(l) do
    if el.t == "Link" and el.target:match("^toa:") then
      local rest = {}
      for j = i + 1, #l do rest[#rest + 1] = l[j] end
      local id = "A:" .. (#cites + 1)
      cites[#cites + 1] = { id = id, key = el.target:sub(5) }
      needle(id, "B", stringify(el.content), stringify(rest):sub(1, 40))
    elseif el.content and type(el.content) ~= "string" and el.t ~= "Link" and el.t ~= "Note" then
      scan_inlines(el.content)
    end
  end
end
local function scan_blocks(blocks)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then scan_inlines(b.content)
    elseif b.t == "BlockQuote" then scan_blocks(b.content)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item) end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Cover (22 NYCRR 1250.8(a))
-- ---------------------------------------------------------------------------

local function cover()
  local out = {}
  local arg = need(RAW, "argument")
  local arg_lines
  if arg.presenter ~= nil then
    arg_lines = { R("To be argued by:"), I(arg.presenter, { b = true }), R("Time requested: " .. tostring(arg.time_requested)) }
  else
    arg_lines = { R("Submitted") }
  end
  out[#out + 1] = table_xml({ TEXTW - ARG_COL, ARG_COL }, { stack({ R(need(RAW, "docket"), { b = true }) }), stack(arg_lines) })
  local court = {}
  for _, l in ipairs(COURT_LINES) do court[#court + 1] = R(l, { b = true }) end
  out[#out + 1] = stack(court, { above = 2 * BLANK, jc = "center" })
  local cap = {}
  for i, side in ipairs(list(need(RAW, "caption"))) do
    if i > 1 then
      cap[#cap + 1] = ""
      cap[#cap + 1] = R("-against-")
      cap[#cap + 1] = ""
    end
    for _, n in ipairs(list(side.names)) do cap[#cap + 1] = I(n) end
    cap[#cap + 1] = I(side.designation)
  end
  out[#out + 1] = stack(cap, { above = 2 * BLANK, left = CAP_INSET, right = CAP_INSET, jc = "center" })
  if RAW.index_number ~= nil then out[#out + 1] = stack({ R(RAW.index_number) }, { above = BLANK, jc = "right" }) end
  out[#out + 1] = stack({ I(need(RAW, "proceeding")) }, { above = 2 * BLANK, left = CAP_INSET, right = CAP_INSET, jc = "center" })
  out[#out + 1] = stack({ R(pandoc.text.upper(tostring(need(RAW, "brief_title"))), { b = true }) }, { above = 2 * BLANK, jc = "center" })
  local c = {}
  for gi, g in ipairs(list(need(RAW, "counsel"))) do
    if gi > 1 then c[#c + 1] = "" end
    for _, n in ipairs(list(g.names)) do c[#c + 1] = R(n, { b = true }) end
    for _, l in ipairs(list(g.lines)) do c[#c + 1] = I(l) end
  end
  c[#c + 1] = R(need(RAW, "phone"))
  c[#c + 1] = R(need(RAW, "email"))
  out[#out + 1] = stack(c, { above = 3 * BLANK, left = COUNSEL })
  out[#out + 1] = stack({ R(need(RAW, "date")) }, { above = 2 * BLANK })
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

-- typst heading-label: Argument: POINT I, A., 1., a.; elsewhere: A., 1., a., (1).
local function heading_label(level, n, argument)
  if argument then
    if level == 2 then return "POINT " .. roman(n) end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    if level == 5 then return string.char(96 + n) .. "." end
  else
    if level == 2 then return string.char(64 + n) .. "." end
    if level == 3 then return n .. "." end
    if level == 4 then return string.char(96 + n) .. "." end
    if level == 5 then return "(" .. n .. ")" end
  end
  fail("headings deeper than level 5 are not supported")
end

-- A section heading: bold capitals, centred (typst style-heading level 1). `top`: it opens a page.
local function section_heading(content_xml, top, pre, keep_after)
  return p(content_xml, { pre = pre, keep = true, before = top and 0 or H_ABOVE, after = H_BELOW, jc = "center" })
end

local function heading(h, top)
  if h.level == 1 then
    return section_heading(xe.inl(upper_inl(h.content), { b = true }), top)
  elseif h.argument and h.level == 2 then
    return p(R(h.label, { b = true }), { keep = true, before = top and 0 or H_ABOVE, jc = "center" })
      .. p(xe.inl(h.content, { b = true }), { keep = true, before = POINT_GAP, after = H_BELOW, jc = "center" })
  end
  local ind = (h.level - 2) * TAB
  return p(R(h.label .. "\t", { b = true }) .. xe.inl(h.content, { b = true, i = h.level >= 4 }), { keep = true,
    before = top and 0 or SUB_ABOVE, after = SUB_BELOW, left = ind + TAB, hanging = TAB, tabs = left_tab(ind + TAB) })
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities
-- ---------------------------------------------------------------------------

-- A table's title (a section heading opening its page) and its column label at the right.
local function table_head(title, col, pre)
  return section_heading(R(title, { b = true }), true, pre)
    .. p(R(col, { b = true, u = true }), { keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging, col, before, label_tab)
  local tabs = '<w:tabs>' .. (label_tab and ('<w:tab w:val="left" w:pos="' .. label_tab .. '"/>') or "")
    .. '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = tabs,
    before = before, left = left, hanging = hanging, right = col })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    if e.level <= TOC_DEPTH then
      local page = R(labels[e.id] or "0")
      if e.level == 1 then
        out[#out + 1] = row(xe.inl(upper_inl(e.content)), page, TAB, TAB, TOC_COL, TOC_ABOVE)
      elseif e.level == 2 and e.argument then
        out[#out + 1] = row(R(e.label .. "\t") .. xe.inl(e.content), page, POINT_BOX, POINT_BOX, TOC_COL, 0, POINT_BOX)
      else
        local ind = (e.level - 2) * TAB
        out[#out + 1] = row(R(e.label .. "\t") .. xe.inl(e.content), page, ind + TAB, TAB, TOC_COL, 0, ind + TAB)
      end
    end
  end
  return table.concat(out)
end

local function toa(authorities)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)", xe.BREAK) }
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    pages[c.key] = pages[c.key] or {}
    seen[c.key] = seen[c.key] or {}
    local l = labels[c.id] or "0"
    if not seen[c.key][l] then
      seen[c.key][l] = true
      pages[c.key][#pages[c.key] + 1] = l
    end
  end
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if (a.kind or "other") == g[1] then
        local sort = a.sort or ((a.name or "") .. " " .. a.cite)
        members[#members + 1] = { key = key, a = a, sort = pandoc.text.lower(stringify(md(sort))) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      out[#out + 1] = p(R(g[2], { b = true }), { before = BLANK, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        local pl = pages[mm.key]
        if pl == nil then fail("authority `" .. mm.key .. "` is listed but never cited with a `toa:` link") end
        local text
        if a.kind == "case" and a.name ~= nil then text = I("*" .. a.name .. "*, " .. a.cite)
        elseif a.name ~= nil then text = I(a.name .. ", " .. a.cite)
        else text = I(a.cite) end
        local pxml = #pl >= PASSIM_AT and R("passim") or R(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_HANG, TOA_HANG, TOA_COL, TOA_ABOVE)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function body_block(b, out, keep)
  if b.t == "Para" or b.t == "Plain" then
    out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = keep })
  elseif b.t == "BlockQuote" then
    for k, q in ipairs(b.content) do
      if q.t ~= "Para" and q.t ~= "Plain" then fail("unsupported block in a quotation: " .. q.t) end
      out[#out + 1] = p(xe.inl(q.content), { before = k == 1 and QUOTE or 0, after = k == #b.content and QUOTE or 0,
        left = INDENT, right = INDENT, keep = keep, lines = true })
    end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    local n = b.t == "OrderedList" and b.listAttributes.start or 1
    for _, item in ipairs(b.content) do
      if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then fail("unsupported list item (one paragraph each)") end
      local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
      out[#out + 1] = p(R(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = TAB, hanging = TAB,
        keep = keep, tabs = left_tab(TAB) })
      n = n + 1
    end
  else
    fail("unsupported block " .. b.t)
  end
end

local function finish(doc)
  load_pages()
  local mdtext = source_md()
  local words = count_words(mdtext)
  if words > WORD_LIMIT then
    fail(words .. " words; 22 NYCRR 1250.8(f)(2) limits this brief to " .. WORD_LIMIT)
  end
  if not FOOTNOTES_ALLOWED then
    doc:walk({ Note = function() fail("footnotes are not allowed (22 NYCRR Part 1000; see README)") end })
  end
  local authorities = need(RAW, "authorities")
  doc:walk({ Link = function(el)
    local key = el.target:match("^toa:(.+)$")
    if key and authorities[key] == nil then fail("toa key `" .. key .. "` is not in authorities:") end
  end })

  -- headings: labels (counters restart under each level 1), the contents' entries
  local blocks = doc.blocks
  local conclusion_at
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 and pandoc.text.lower(stringify(b.content)) == "conclusion" then
      conclusion_at = conclusion_at or i
    end
  end
  if conclusion_at == nil then fail("no `# Conclusion` section") end

  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
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
  local entries, body = {}, {}
  for i, b in ipairs(blocks) do
    local keep = i >= conclusion_at
    if b.t == "Header" then
      local h = heads[i]
      h.id = "H:" .. (#entries + 1)
      -- the words after the heading (a following heading with its label), so a needle is found at its heading
      local nxt = heads[i + 1] and heads[i + 1].text or (blocks[i + 1] and stringify(blocks[i + 1]) or "")
      nxt = nxt:sub(1, 40)
      needle(h.id, "B", (h.label and (h.label .. " ") or "") .. stringify(b.content), nxt)
      entries[#entries + 1] = h
      body[#body + 1] = heading(h, i == 1)
    else
      scan_blocks({ b })
      body_block(b, body, keep)
    end
  end
  if #entries == 0 then fail("the body has no headings") end

  -- the signature (typst line-stack at sig-left, a double line below the conclusion), kept with it
  local sig = need(RAW, "signature")
  local sl = { R("Respectfully submitted,"), "", R("s/ " .. pandoc.text.upper(tostring(sig.signer)), { b = true }) }
  for _, l in ipairs(list(sig.lines)) do sl[#sl + 1] = I(l) end
  if RAW.date ~= nil then
    sl[#sl + 1] = ""
    sl[#sl + 1] = R(RAW.date)
  end
  body[#body + 1] = stack(sl, { above = BODY, left = SIG, keep = true })

  -- printing specifications statement (22 NYCRR 1250.8(b)(6), (j)), on a new page
  body[#body + 1] = section_heading(R("PRINTING SPECIFICATIONS STATEMENT", { b = true }), true, xe.BREAK)
  body[#body + 1] = p(R("This brief was prepared on a computer. The typeface is Times New Roman, 14 point. The body text is "
    .. "double-spaced. Headings, block quotations, and the tables are single-spaced. The brief contains "
    .. group_digits(words) .. " words, exclusive of the cover, the tables, the signature block, and any certificate of "
    .. "service, as counted by the word-processing system used to prepare it (22 NYCRR 1250.8(f)(2), (j))."),
    { line = BODY, first = INDENT })
  body[#body + 1] = p(R("Signed under 22 NYCRR 130-1.1-a(a), which is also the signer\u{2019}s representation that this "
    .. "statement is accurate."), { line = BODY, first = INDENT })
  local fl = { R("s/ " .. pandoc.text.upper(tostring(sig.signer)), { b = true }) }
  for _, l in ipairs(list(sig.lines)) do fl[#fl + 1] = I(l) end
  body[#body + 1] = stack(fl, { above = SINGLE })

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrNy\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrNy", "decimal"))

  local out = {
    cover(), section("rIdFtrNone"),
    toc(entries), toa(authorities), section("rIdFtrNy", "lowerRoman"),
    table.concat(body),
  }
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
