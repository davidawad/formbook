-- E.D. Cal. motion with notice and memorandum, docx engine (docs/DOCX.md): what the Word output adds to pandoc's
-- conversion, so that it reads and breaks as typst/caed-motion-brief.typ does (see ../README.md): the counsel block
-- (L.R. 131(a)), the court title, the caption (Fed. R. Civ. P. 10(a)), the notice, the signature blocks ("---"), the
-- table of contents and the table of authorities ([[TOC]], [[TOA]]; L.R. 133(k)), the memorandum ([[MEMO]]) with its
-- headings and lists. Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- Pleading paper (L.R. 130): the numbers 1 to 27 in the left margin are a frame of exact 24 pt lines anchored to the
-- page at the top margin, written into the footer with the description and the page number (L.R. 130(d)), so that
-- every section names one footer of this filter's ($FORMBOOK_FOOTERS). Three sections number the pages as typst does:
-- the cover and the notice arabic from 1, the tables lower roman from i, the memorandum arabic from 1 (the last
-- section, $FORMBOOK_FINAL). The contents' page numbers: fb render (tools/fb/src/docxpass.rs) finds the needles this
-- filter writes ($FORMBOOK_NEEDLES) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until
-- they settle (were docx/render.sh's measure loop and fix-sections.pl).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 240                          -- typst pitch, pitch-single
local DROP = 192                                       -- typst single-drop: a single-spaced group starts 9.6 pt down
local INDENT = 720                                     -- typst para-indent, list-indent, list-label, heading-step
local TEXTW = 8640                                     -- 6 in
local COUNSEL_LINES = 7                                -- typst counsel-lines (L.R. 131(a))
local CAP_LEFT, CAP_INSET, CAP_FOOT = 4608, 200, 160   -- typst caption-left 3.2 in, caption-inset 10 pt, the 8 pt foot
local CAP_GUTTER, CAP_RIGHT_INSET = 288, 144           -- typst caption-gutter 0.2 in, caption-right-inset 0.1 in
local GAP = 240                                        -- typst caption-gap, the signature's 12 pt, toa-gap
local SIG_LEFT, SIG_GUTTER = 3744, 288                 -- typst signature-left 2.6 in, its 0.2 in gutter
local TOC_COL, TOA_COL, TOA_HANG = 720, 1440, 576      -- typst toc-page-col 36 pt, toa-page-col 1 in, toa-hang 0.4 in
local NEEDLE_MAX = 60
local FOOTER = "rIdCaedPage"
local LINES = 27                                       -- typst lines-per-page

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, tabs, jc, keep, lines, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    local body = cells[i].body or {}
    if #body == 0 then body = { p("") } end
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- The first paragraph of a single-spaced group starts DROP twips further down (a cell keeps its space before).
local function dropped(paras)
  paras[1] = paras[1]:gsub('w:before="(%d+)"', function(b) return 'w:before="' .. (tonumber(b) + DROP) .. '"' end, 1)
  return paras
end

local function list_of(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

local function read_file(path)
  if not path or path == "" then return nil end
  local f = io.open(path, "r")
  if not f then return nil end
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

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = norm(text):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = "B", needle = long, fallback = short }
end

local labels = {}
local function load_pages()
  local s = read_file(os.getenv("FORMBOOK_PAGES"))
  if not s then return end
  for line in s:gmatch("[^\n]+") do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
end

-- ---------------------------------------------------------------------------
-- Page furniture: the footer (line numbers, description, page number) and the sections
-- ---------------------------------------------------------------------------

-- The numbers 1 to 27, one frame of exact 24 pt lines at the top margin, ending an inch from the page edge (typst
-- line-numbers); then the description in capitals and the page number on one 10 pt line in a 12 pt box (typst
-- footer-block).
local function footer(meta)
  local x = {}
  for i = 1, LINES do
    x[#x + 1] = '<w:p><w:pPr><w:framePr w:w="1440" w:hSpace="0" w:wrap="around" w:vAnchor="page" w:hAnchor="page" ' ..
      'w:x="0" w:y="1440"/>' .. xe.spacing(0, 0, BODY) .. xe.ind(0, nil, 0) .. xe.jc("right") .. '</w:pPr>' ..
      xe.runs(tostring(i)) .. '</w:p>'
  end
  local sz = { sz = 20 }
  x[#x + 1] = xe.para({ '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>', xe.spacing(0, 0, 240),
    xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs(pandoc.text.upper(plain(meta.footer_title)), sz) .. xe.runs("\t", sz) ..
    '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>' ..
    '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' ..
    '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t>1</w:t></w:r>' ..
    '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>')
  return table.concat(x)
end

-- Letter; top and bottom margins 1 in (27 numbered lines of 24 pt between them), left 1.5 in, right 1 in (typst);
-- the footer's foot 54 pt above the page edge (typst: 6 pt below the last numbered line); a double rule at the text's
-- left edge and a single rule at its right (page borders); pages numbered in `fmt` from 1.
local function sect_pr(fmt, next_page)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. FOOTER .. '"/>' ..
    (next_page and '<w:type w:val="nextPage"/>' or '') ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" ' ..
    'w:header="720" w:footer="1080" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" ' ..
    'w:space="12" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders>' ..
    '<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/></w:sectPr>'
end

-- The paragraph that ends a section: 1 twip high, its section's properties in it.
local function section_end(fmt)
  return '<w:p><w:pPr>' .. xe.spacing(0, 0, 20) .. sect_pr(fmt, true) .. '</w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel (lines 1-7 or more), court title, caption, title of the paper, hearing
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  -- counsel, one single line each (an empty one keeps its height), in at least COUNSEL_LINES numbered lines (typst
  -- counsel-block: a block of that height); the court title takes the rest as space before
  local counsel = list_of(meta.counsel)
  out[#out + 1] = p("", { line = DROP })
  for _, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l)) end
  local h = DROP + #counsel * SINGLE
  local pad = math.max(COUNSEL_LINES * BODY, math.ceil(h / BODY) * BODY) - h
  local courts = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF CALIFORNIA" }
  if meta.division then courts[#courts + 1] = pandoc.text.upper(plain(meta.division)) end
  for i, l in ipairs(courts) do
    -- the caption stands one numbered line below the court title (Word has no space before a table: the last title
    -- line takes it as space after)
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", line = BODY, before = i == 1 and pad or 0,
      after = i == #courts and BODY or 0 })
  end
  local left = {}
  for k, party in ipairs(list_of(meta.caption.parties)) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(list_of(party.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local q = { left = CAP_RIGHT_INSET }
  local g = { left = CAP_RIGHT_INSET, before = GAP }
  local right = { p(xe.runs("Case No.: ") .. xe.inl(meta.case_number), q) }
  if meta.judge then right[#right + 1] = p(xe.inl(meta.judge), q) end
  if meta.magistrate then right[#right + 1] = p(xe.inl(meta.magistrate), q) end
  right[#right + 1] = p(xe.inl(meta.brief_title, { b = true }), g)
  if meta.concurrent then right[#right + 1] = p(xe.inl(meta.concurrent), g) end
  if meta.hearing then
    right[#right + 1] = p(xe.runs("Date: ") .. xe.inl(meta.hearing.date), g)
    right[#right + 1] = p(xe.runs("Time: ") .. xe.inl(meta.hearing.time), q)
    right[#right + 1] = p(xe.runs("Place: ") .. xe.inl(meta.hearing.place), q)
  end
  if meta.action_filed then right[#right + 1] = p(xe.runs("Action Filed: ") .. xe.inl(meta.action_filed), g) end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER },
    { { pr = rule, body = dropped(left) }, { body = {} }, { body = dropped(right) } })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: the date at the left; the firm, "By: /s/" and the signer, and the signer's lines at the right;
-- a whole number of numbered lines high, one numbered line below the text, the row never split. The space above it
-- is a 1 pt paragraph kept with the table, its space before the rest: at the top of a page LibreOffice drops a
-- paragraph's space before, as typst drops a block's.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local firm, lines = list_of(sig.firm), list_of(sig.lines)
  local right = {}
  for _, l in ipairs(firm) do right[#right + 1] = p(xe.inl(l)) end
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = GAP })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(lines) do right[#right + 1] = p(xe.inl(l)) end
  local h = DROP + (#firm + 2 + #lines) * SINGLE + GAP
  local rows = math.ceil(h / BODY) * BODY
  return p("", { keep = true, before = BODY - 20, line = 20 }) ..
    tbl({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER },
      { { body = dropped({ p(xe.runs("Dated: ") .. xe.inl(meta.date)) }) }, { body = {} }, { body = dropped(right) } },
      '<w:trPr><w:cantSplit/><w:trHeight w:val="' .. rows .. '" w:hRule="exact"/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The tables
-- ---------------------------------------------------------------------------

-- A row of a table (typst listing-row): the text wraps before the page column, a dot leader to the page reference,
-- the later lines `hang` in; o = { left, hang, col, line, after, brk }.
local function listing(body, page, o)
  local q = { lines = true, tabs = xe.leader_tab(TEXTW), right = o.col, line = o.line, after = o.after, brk = o.brk }
  if o.hang then q.left, q.hanging = o.hang, o.hang else q.left = o.left end
  return p(body .. xe.runs(xe.LEAD) .. page, q)
end

local function toc(entries)
  local out = {}
  out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", line = BODY })
  out[#out + 1] = p(xe.runs("Page", { b = true }), { jc = "right", line = BODY })
  for _, e in ipairs(entries) do
    out[#out + 1] = listing(xe.inl(e.content), xe.runs(labels[e.id] or "0"),
      { left = (e.level - 1) * INDENT, col = TOC_COL, line = BODY })
  end
  return out
end

local function toa(meta)
  local out = {}
  out[#out + 1] = p(xe.runs("TABLE OF AUTHORITIES", { b = true }), { jc = "center", line = BODY, brk = true })
  out[#out + 1] = p(xe.runs("Page(s)", { b = true }), { jc = "right", line = BODY })
  for _, group in ipairs(list_of(meta.authorities)) do
    out[#out + 1] = p(xe.inl(group.category, { b = true }), { line = BODY })
    for _, e in ipairs(list_of(group.entries)) do
      out[#out + 1] = listing(xe.inl(e.cite), xe.inl(e.pages),
        { hang = TOA_HANG, col = TOA_COL, line = SINGLE, after = GAP })
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, bold: level 1 centered (as written), level 2 at the margin, level 3 a step in; kept
-- with the text.
local function heading(el)
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY),
    xe.ind(lvl >= 3 and INDENT or 0, nil, 0), xe.jc(lvl == 1 and "center" or "left") }, xe.inl(el.content, { b = true }))
end

-- A list: each item's number half an inch in, in a box of half an inch, the text hanging after it; numbers as
-- written, a bullet for "-". The last item is kept with a signature block after it.
local function items(list, keep_last, out)
  local n = list.t == "OrderedList" and list.listAttributes.start or 1
  for i, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("caed-motion-brief.lua: a list item holds one paragraph")
    end
    local lab = list.t == "OrderedList" and (n .. ".") or "\u{2022}"
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
      { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT, keep = keep_last and i == #list.content })
    n = n + 1
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 1788.301(a)"), as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function is_marker(b, name)
  return b.t == "Para" and plain(b) == name
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  local walk = function(x) return x:walk({ Str = breaks }):walk({ Inlines = bind_double_signs }) end
  doc.blocks = walk(doc.blocks)
  meta.authorities = walk(pandoc.Pandoc({}, meta)).meta.authorities
  local blocks = doc.blocks

  -- the needles: the tables' headings, the memorandum's title with its first heading (where its arabic numbering
  -- starts), then each memorandum heading with the words after it
  local memo, entries, ids = false, {}, {}
  need("S:toc", "TABLE OF CONTENTS Page")
  need("S:toa", "TABLE OF AUTHORITIES Page(s)")
  for i, b in ipairs(blocks) do
    if is_marker(b, "[[MEMO]]") then
      memo = true
      need("S:memo", plain(meta.memo_title), blocks[i + 1] and stringify(blocks[i + 1]) or "")
    elseif memo and b.t == "Header" then
      local id = "H:" .. (#entries + 1)
      ids[i] = id
      need(id, stringify(b.content), blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or "")
      entries[#entries + 1] = { id = id, level = b.level, content = b.content }
    end
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tS:memo\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", FOOTER .. "\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("decimal", false))

  local out = cover(meta)
  -- the notice starts on a new page
  local brk = true
  for i, b in ipairs(blocks) do
    -- the block before a signature block stays whole with it (typst: a sticky, unbreakable block)
    local keep = blocks[i + 1] ~= nil and blocks[i + 1].t == "HorizontalRule"
    local start = #out + 1
    if is_marker(b, "[[TOC]]") then
      out[#out + 1] = section_end("decimal")          -- the cover and the notice, arabic from 1
      for _, x in ipairs(toc(entries)) do out[#out + 1] = x end
    elseif is_marker(b, "[[TOA]]") then
      for _, x in ipairs(toa(meta)) do out[#out + 1] = x end
    elseif is_marker(b, "[[MEMO]]") then
      out[#out + 1] = section_end("lowerRoman")       -- the tables, roman from i
      out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.memo_title)), { b = true }), { jc = "center", line = BODY })
    elseif b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, keep, out)
    elseif b.t == "HorizontalRule" then
      out[#out + 1] = signature(meta)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = keep })
    else
      error("caed-motion-brief.lua: unsupported block " .. b.t)
    end
    if brk then
      -- in the schema's order: after the style and keeps, before the tabs and spacing
      local at = out[start]:find("<w:tabs>", 1, true) or out[start]:find("<w:spacing ", 1, true)
      out[start] = out[start]:sub(1, at - 1) .. xe.BREAK .. out[start]:sub(at)
      brk = false
    end
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
