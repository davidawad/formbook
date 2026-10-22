-- Complaint for the U.S. District Court for the District of South Dakota (sdd), docx engine: what the Word output
-- adds to pandoc's conversion, so that it reads and breaks as typst/sdd-complaint.typ does: the court title and
-- caption (LR 10.1(A); Fed. R. Civ. P. 10(a)), the headings (LR 83.4: single-spaced), the ruled body tables, the
-- numbered paragraphs (Fed. R. Civ. P. 10(b)), the unnumbered "~" paragraphs, the lettered list items and the
-- signature block (LR 10.1(B), LR 5.1(A)(4)). Everything printed comes from the sample's frontmatter and body: no
-- case text lives in this file. Caption, tables and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360   -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET, CAP_PAD = 240, 123      -- typst caption-inset 12 pt, caption-pad (half a single line, 138) less the
                                         -- 0.75 pt rule, which LibreOffice adds to the cell height
local RIGHT_INSET = 216                  -- typst right-inset 0.15 in
local SIG_LEFT, SIG_GUTTER = 3744, 288   -- typst sig-left 2.6 in, sig-gutter 0.2 in
local SIG_RULE = 4608                    -- typst sig-rule 3.2 in
local LABEL_COL = 2520                   -- typst label-col 1.75 in
local CELL_X, CELL_Y = 100, 60           -- typst cell-x 5 pt, cell-y 3 pt
local CELL_TOP = CELL_Y - 10             -- LibreOffice adds each row's 0.5 pt rule to its height: taken off above
local HEAD = 240                         -- typst heading-space 12 pt

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, hanging, first, right, jc, keep, tabs, border }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.border then props[#props + 1] = o.border end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table of one or more rows; cells = { { width, pr, body = { paragraphs } }, ... } per row.
local function tbl(widths, rows, o)
  o = o or {}
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  local m = o.mar or { 0, 0, 0, 0 }
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. (o.borders or
      '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
      '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>') ..
    '<w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="' .. m[1] .. '" w:type="dxa"/><w:left w:w="' .. m[2] .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. m[3] .. '" w:type="dxa"/><w:right w:w="' .. m[4] .. '" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- The document as a list of blocks: a paragraph keeps its options until the end, so that the space below it can
-- still be set when a table follows (Word puts no space above a table; the paragraph before it carries the gap).
-- Between two blocks the space is the larger of the one's below and the other's above (typst's collapse).
-- ---------------------------------------------------------------------------

local out, gap = {}, 0

local function add_p(body, o, below)
  o.before = math.max(gap, o.before or 0)
  out[#out + 1] = { body = body, o = o }
  gap = below or 0
end

local function add_tbl(xml, above, below)
  local g = math.max(gap, above or 0)
  local last = out[#out]
  if g > 0 and last and last.o then last.o.after = g end
  out[#out + 1] = { xml = xml }
  gap = below or 0
end

-- ---------------------------------------------------------------------------
-- Court title and caption (LR 10.1(A); Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local lines = { "UNITED STATES DISTRICT COURT", "DISTRICT OF SOUTH DAKOTA" }
  if meta.division then lines[#lines + 1] = pandoc.text.upper(plain(meta.division)) end
  for _, l in ipairs(lines) do add_p(xe.runs(l, { b = true }), { jc = "center" }) end
  -- Left cell: each party's names, then its designation; "v." between the parties.
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_PAD or 0 })
  end
  -- Right cell: the case number, the title, the jury line.
  local right = {
    p(xe.runs("Case No. " .. plain(meta.case_number))),
    p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE }),
  }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = SINGLE })
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  add_tbl(tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, { {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  } }), BODY, BODY)
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 10.1(B), LR 5.1(A)(4)): "Dated" at the left; at the right the signature (a line for a party
-- without an attorney, "/s/" for a filing user) and the typed name, address, telephone and e-mail beneath it; the
-- row never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) }
  local right = {}
  local rightw = TEXTW - SIG_LEFT
  if sig.pro_se == true then
    right[#right + 1] = p("", { border = '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>',
      right = rightw - SIG_GUTTER - SIG_RULE })
    right[#right + 1] = p(xe.inl(sig.signer), { before = 80 })
    right[#right + 1] = p(xe.runs("Plaintiff, without counsel"))
  else
    if sig.firm then
      for _, l in ipairs(sig.firm) do right[#right + 1] = p(xe.inl(l)) end
    end
    right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = sig.firm and SINGLE or 0 })
    right[#right + 1] = p(xe.inl(sig.signer))
  end
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  add_tbl(tbl({ SIG_LEFT, rightw }, { { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } } }), BODY, 0)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: the first-line indent, then (numbered) the number in a box of the indent
-- (a tab to 1 in), the text.
local TAB2 = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>'
local function body_par(label, inlines, keep)
  local body = (label and xe.runs(label .. "\t") or "") .. xe.inl(inlines)
  add_p(body, { line = BODY, first = INDENT, tabs = label and TAB2 or nil, keep = keep })
end

-- Headings single-spaced (LR 83.4), 12 pt above and below; level 1 centered capitals, level 2 bold, level 3 bold
-- italic; kept with the block after them.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  add_p(xe.inl(content, { b = true, i = el.level >= 3 }),
    { style = "Heading" .. el.level, keep = true, before = HEAD, jc = el.level == 1 and "center" or "left" }, HEAD)
end

-- A markdown table, single-spaced and ruled: the label column, the others sharing the rest (typst body-table).
local function body_table(t)
  local rows = {}
  local function add_row(r)
    local cells = {}
    for _, c in ipairs(r.cells) do
      local inls = pandoc.Inlines({})
      for _, b in ipairs(c.contents) do
        if #inls > 0 then inls:insert(pandoc.Space()) end
        inls:extend(b.content or {})
      end
      cells[#cells + 1] = { body = { p(xe.inl(inls)) } }
    end
    rows[#rows + 1] = cells
  end
  for _, r in ipairs(t.head.rows) do add_row(r) end
  for _, tb in ipairs(t.bodies) do
    for _, r in ipairs(tb.head) do add_row(r) end
    for _, r in ipairs(tb.body) do add_row(r) end
  end
  for _, r in ipairs(t.foot.rows) do add_row(r) end
  local n = #rows[1]
  local widths = { n == 1 and TEXTW or LABEL_COL }
  for k = 2, n do widths[k] = math.floor((TEXTW - LABEL_COL) / (n - 1) + 0.5) end
  local line = 'w:val="single" w:sz="4" w:space="0" w:color="000000"'
  local borders = '<w:tblBorders><w:top ' .. line .. '/><w:left ' .. line .. '/><w:bottom ' .. line .. '/><w:right ' ..
    line .. '/><w:insideH ' .. line .. '/><w:insideV ' .. line .. '/></w:tblBorders>'
  add_tbl(tbl(widths, rows, { borders = borders, mar = { CELL_TOP, CELL_X, CELL_Y, CELL_X } }), 0, HEAD)
end

-- List items, lettered (a), (b), ... or bulleted: the label in a box of the indent, the text hanging after it.
local function list(b)
  for j, item in ipairs(b.content) do
    for k, blk in ipairs(item) do
      local lab = ""
      if k == 1 then lab = (b.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")") or "\u{2022}") .. "\t" end
      add_p(xe.runs(lab) .. xe.inl(blk.content), { line = BODY, left = INDENT, hanging = INDENT })
    end
  end
end

-- "~" marks an unnumbered paragraph (the typst template's rule); the mark is removed
local function strip_tilde(inls)
  local first = inls[1]
  if not (first and first.t == "Str" and first.text:sub(1, 1) == "~") then return false end
  local rest = first.text:sub(2)
  if rest == "" then table.remove(inls, 1) else inls[1] = pandoc.Str(rest) end
  if inls[1] and inls[1].t == "Space" then table.remove(inls, 1) end
  return true
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("c/o": a zero-width space), none between a doubled section sign and its number (typst
-- boxes the last sign with the number).
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end
local function signs(inls)
  for i = 1, #inls - 1 do
    local a, b = inls[i], inls[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then inls[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return inls
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  cover(meta)
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      local unnumbered = strip_tilde(b.content)
      local label = nil
      if not unnumbered then
        n = n + 1
        label = n .. "."
      end
      -- the last paragraph stays on the page with the signature block
      body_par(label, b.content, i == #blocks)
    elseif b.t == "Table" then
      body_table(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      list(b)
    else
      error("sdd-complaint.lua: unsupported block " .. b.t)
    end
  end
  if meta.signature then signature(meta) end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x.xml or p(x.body, x.o)) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
