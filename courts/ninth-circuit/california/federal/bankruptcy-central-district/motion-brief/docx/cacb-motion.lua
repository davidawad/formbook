-- Motion with notice and memorandum, C.D. Cal. bankruptcy court (cacb), DOCX engine (docs/DOCX.md): what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/cacb-motion-brief.typ does: the counsel
-- block on lines 1-7, the court title, the caption (debtor on the left, ruled; case number, chapter, title and hearing
-- on the right), then the body on the same first page. Headings are numbered from their level here (I., A., 1., a.;
-- level 1 is an unnumbered centered section that restarts the count); paragraphs are unnumbered and indented; lists
-- and tables (equal unruled columns) in numbered lines. <!-- signature --> places the signature block; <!-- pagebreak
-- --> starts the next block on a new page. A paragraph (or table) before a signature block is kept with it, and the
-- last three before a page break or the end are kept together. The line numbers, the pleading rules and the footer
-- come from docx/reference.xml; the footer's title and case number are the document's SUBJECT and COMMENTS
-- properties, set here from the sample. Everything printed comes from the sample's frontmatter and body: no case
-- text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 a numbered line, 240 a single line), the spaces between
-- blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 240            -- typst pitch, pitch-single
local HALF = 240                         -- typst half-gap 12 pt
local TO_GRID = 432                      -- typst to-grid 21.6 pt: single lines on the numbered lines' baselines
local GRID_PAD = 288                     -- typst grid-pad 14.4 pt: a block of single lines ends on the grid again
local RULE_PAD = GRID_PAD - 15           -- the same, less the 0.75 pt rule LibreOffice adds to the row
local INDENT = 720                       -- typst para-indent, item-indent and heading-step, 0.5 in
local TEXTW = 8640                       -- typst text-width, 6 in
local CAP_LEFT, CAP_GUTTER = 4752, 288   -- typst caption-left 3.3 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local CELL_INSET = 80                    -- typst cell-inset 4 pt
local SIG_LEFT = 3744                    -- typst sig-left 2.6 in
local COUNSEL_LINES = 7                  -- typst counsel-lines (Central Guide 9004-1(c)(1)(B))
local COUNSEL_DROP = 192                 -- typst counsel-drop 9.6 pt: the first counsel line on line 1's baseline
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'       -- 0.75 pt
local CANT_SPLIT = "<w:trPr><w:cantSplit/></w:trPr>"

local function text(v) return pandoc.utils.stringify(v) end

-- A metadata value as a list (a YAML list or one value).
local function list(v)
  if v == nil then return {} end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then return v end
  return { v }
end

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pagebreak, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pagebreak then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table without borders; rows = { { cells = { { pr, body } } } }, every row kept whole.
local function tbl(widths, rows, mar)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row.cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. CANT_SPLIT .. table.concat(tcs) .. '</w:tr>'
  end
  mar = mar or 0
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="' .. mar .. '" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="' .. mar .. '" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- The last paragraph of a list of paragraphs gets `after` twips below it.
local function pad_last(ps, after)
  ps[#ps] = ps[#ps]:gsub('w:after="0"', 'w:after="' .. after .. '"', 1)
  return ps
end

-- ---------------------------------------------------------------------------
-- Cover: counsel (lines 1-7), court title (line 8), caption
-- ---------------------------------------------------------------------------

local COURT = { "UNITED STATES BANKRUPTCY COURT", "CENTRAL DISTRICT OF CALIFORNIA" }

local function cover(meta, out)
  -- counsel: single lines from line 1, filling at least lines 1-7; more lines push the court title down by whole
  -- numbered lines, half a line kept below the last (typst counsel-block)
  local counsel = list(meta.counsel)
  for j, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l), { before = j == 1 and COUNSEL_DROP or 0 }) end
  local rows = math.max(COUNSEL_LINES, math.ceil((#counsel + 1) / 2))
  local court = { COURT[1], COURT[2], pandoc.text.upper(text(meta.division)) }
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }),
      { line = BODY, jc = "center", keep = true, before = i == 1 and (rows * BODY - COUNSEL_DROP - #counsel * SINGLE) or 0 })
  end
  -- The caption stands a numbered line (less 2.4 pt, typst to-grid) below the court title: Word has no space before
  -- a table, so the first paragraph of each cell carries it; both columns end GRID_PAD below their last line.
  local left = { p(xe.runs("In re:"), { before = TO_GRID }) }
  for _, n in ipairs(list(meta.caption.debtor.names)) do left[#left + 1] = p(xe.inl(n)) end
  left[#left + 1] = p(xe.inl(meta.caption.debtor.designation))
  local function r(body, before) return p(body, { before = before or 0, left = RIGHT_INSET }) end
  local right = {
    r(xe.runs("Case No. " .. text(meta.bankruptcy_case)), TO_GRID),
    r(xe.runs("Chapter " .. text(meta.chapter))),
    r(xe.inl(meta.brief_title, { b = true }), HALF),
  }
  if meta.legend then right[#right + 1] = r(xe.runs(pandoc.text.upper(text(meta.legend)), { b = true }), HALF) end
  for j, l in ipairs(list(meta.hearing)) do right[#right + 1] = r(xe.inl(l), j == 1 and HALF or 0) end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, { { cells = {
    { pr = '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = pad_last(left, RULE_PAD) },
    { body = { p("", { before = TO_GRID }) } },
    { body = pad_last(right, RULE_PAD) },   -- LibreOffice adds the party column's rule to the whole row
  } } })
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, before = BODY }) end
end

-- ---------------------------------------------------------------------------
-- Signature block: the date left; the firm and the signer right; it ends on the grid again (GRID_PAD)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = {}
  for j, l in ipairs(list(sig.firm)) do right[#right + 1] = p(xe.inl(l), { before = j == 1 and TO_GRID or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ " .. text(sig.signer)), { before = #right == 0 and TO_GRID or HALF })
  right[#right + 1] = p(xe.runs(pandoc.text.upper(text(sig.signer))))
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ SIG_LEFT, CAP_GUTTER, TEXTW - SIG_LEFT - CAP_GUTTER }, { { cells = {
    { body = { p(xe.runs("Dated: " .. text(meta.date)), { before = TO_GRID }) } },
    { body = { p("", { before = TO_GRID }) } },
    { body = pad_last(right, GRID_PAD) },
  } } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n)
  local s = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return s
end

local function kind(b)
  if b.t == "RawBlock" and b.format == "html" then
    local m = b.text:match("^%s*<!%-%-%s*(%S+)%s*%-%->%s*$")
    if m == "signature" then return "signature" elseif m == "pagebreak" then return "break" end
  end
  if b.t == "Header" then return "heading" end
  if b.t == "Table" then return "table" end
  if b.t == "BlockQuote" then return "quote" end
  if b.t == "OrderedList" or b.t == "BulletList" then return "list" end
  if b.t == "Para" or b.t == "Plain" then return "para" end
  error("cacb-motion: unsupported block " .. b.t)
end

-- A table (typst data-table): equal unruled columns, cells inset 4 pt at the sides, the text in numbered lines; a
-- row never splits; o.keep keeps every row with the next block.
local function data_table(t, o, out)
  local rows = {}
  for _, r in ipairs(t.head.rows) do rows[#rows + 1] = r end
  for _, b in ipairs(t.bodies) do for _, r in ipairs(b.body) do rows[#rows + 1] = r end end
  local n = #rows[1].cells
  local w = math.floor(TEXTW / n)
  local widths = {}
  for i = 1, n do widths[i] = i < n and w or TEXTW - w * (n - 1) end
  if o.pagebreak then
    -- Word cannot start a page with a table: a 1 pt line before it (typst: the same block)
    out[#out + 1] = p("", { line = 20, pagebreak = true })
  end
  local trs = {}
  for _, r in ipairs(rows) do
    local cells = {}
    for _, c in ipairs(r.cells) do
      local inl = pandoc.Inlines({})
      for _, b in ipairs(c.contents) do if b.content then inl:extend(b.content) end end
      cells[#cells + 1] = { body = { p(xe.inl(inl), { line = BODY, keep = o.keep, lines = true }) } }
    end
    trs[#trs + 1] = { cells = cells }
  end
  out[#out + 1] = tbl(widths, trs, CELL_INSET)
end

local function heading(b, count, o, out)
  local lvl = b.level
  if lvl == 2 then
    out[#out + 1] = p(xe.runs(roman(count) .. ".", { b = true }),
      { line = BODY, jc = "center", keep = true, before = BODY, pagebreak = o.pagebreak })
    out[#out + 1] = xe.para({ xe.style("Heading2"), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(upper(b.content), { b = true }))
    return
  end
  local lab, left, ro = "", 0, { b = true }
  if lvl == 1 then
    out[#out + 1] = xe.para({ xe.style("Heading1"), xe.KEEP, o.pagebreak and xe.BREAK or "", xe.spacing(0, 0, BODY),
      xe.ind(0, nil, 0), xe.jc("center") }, xe.inl(upper(b.content), { b = true }))
    return
  elseif lvl == 3 then lab, left = string.char(64 + count) .. ". ", INDENT
  elseif lvl == 4 then lab, left = count .. ". ", 2 * INDENT
  else lab, left, ro = string.char(96 + count) .. ". ", 3 * INDENT, { i = true }
  end
  out[#out + 1] = xe.para({ xe.style("Heading" .. math.min(lvl, 5)), xe.KEEP, o.pagebreak and xe.BREAK or "",
    xe.spacing(0, 0, BODY), xe.ind(left, nil, 0), xe.jc("left") }, xe.runs(lab, ro) .. xe.inl(b.content, ro))
end

local function body(meta, blocks, out)
  local kinds = {}
  for i, b in ipairs(blocks) do kinds[i] = kind(b) end
  local function at(i) return kinds[i] or "end" end
  local function textlike(i) return at(i) == "para" or at(i) == "table" end
  local counts = { 0, 0, 0, 0 }
  for i, b in ipairs(blocks) do
    local k = kinds[i]
    -- typst body-chunks: kept with the signature block after it, or one of the last three before a break or the end
    local keep = textlike(i) and (at(i + 1) == "signature"
      or (textlike(i + 1) and (at(i + 2) == "break" or at(i + 2) == "end"
        or (textlike(i + 2) and (at(i + 3) == "break" or at(i + 3) == "end")))))
    local held = i > 1 and textlike(i - 1) and (at(i) == "signature"
      or (textlike(i) and (at(i + 1) == "break" or at(i + 1) == "end"
        or (textlike(i + 1) and (at(i + 2) == "break" or at(i + 2) == "end")))))
    -- the last of a kept group stays whole too (typst: the group is one unbreakable block)
    local o = { pagebreak = at(i - 1) == "break", keep = keep, lines = keep or held }
    if k == "signature" then
      out[#out + 1] = signature(meta)
    elseif k == "break" then
      -- the next block starts the page (pageBreakBefore)
    elseif k == "heading" then
      local lvl = b.level
      if lvl == 1 then counts = { 0, 0, 0, 0 } else
        counts[lvl - 1] = counts[lvl - 1] + 1
        for j = lvl, 4 do counts[j] = 0 end
      end
      heading(b, lvl > 1 and counts[lvl - 1] or 0, o, out)
    elseif k == "table" then
      data_table(b, o, out)
    elseif k == "quote" then
      for _, q in ipairs(b.content) do
        -- indented half an inch on both sides, no first-line indent (typst: the quotation block's inset)
        out[#out + 1] = p(xe.inl(q.content), { line = BODY, left = INDENT, right = INDENT, pagebreak = o.pagebreak })
        o.pagebreak = false
      end
    elseif k == "list" then
      -- the label half an inch in, the text a box after it (typst list-indent), from the markdown start number
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        for m, ib in ipairs(item) do
          local lab = m == 1 and ((b.t == "OrderedList" and ((start + j - 1) .. ".") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content),
            { line = BODY, left = 2 * INDENT, hanging = INDENT, pagebreak = o.pagebreak })
          o.pagebreak = false
        end
      end
    else
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = keep, lines = o.lines,
        pagebreak = o.pagebreak })
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 363"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local t = a.text
      if #t >= 4 and t:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
        inlines[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return inlines
end

function Pandoc(doc)
  for _, k in ipairs({ "footer_title", "bankruptcy_case", "chapter", "division", "caption", "brief_title", "counsel",
    "hearing", "date", "signature" }) do
    if doc.meta[k] == nil then error("cacb-motion: missing required metadata field `" .. k .. "`", 0) end
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  body(meta, doc.blocks, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  -- the footer reads the document properties (docProps/core.xml) through its SUBJECT and COMMENTS fields
  return pandoc.Pandoc(blocks, pandoc.Meta({
    subject = pandoc.MetaInlines({ pandoc.Str(pandoc.text.upper(text(meta.footer_title))) }),
    description = pandoc.MetaInlines({ pandoc.Str(text(meta.bankruptcy_case)) }),
  }))
end
