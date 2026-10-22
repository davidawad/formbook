-- Adversary complaint, Bankruptcy Court for the District of Alaska (akb), DOCX engine (docs/DOCX.md): what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/akb-adversary-complaint.typ does: the
-- counsel block (LBR 9004-1(c)(2)), the court title and the caption (FRBP 9004(b), Official Form 416D: each party
-- group ruled below, the case numbers beside it), the title of the paper, the lead-in, the numbered allegations
-- (Fed. R. Civ. P. 10(b), applied by FRBP 7010), the headings, the data tables, the lettered relief items, the
-- consent statement (FRBP 7008(a); LBR 7012-1) and the signature block (LBR 9004-1(a)(9)). Everything printed comes
-- from the sample's frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local HALF, SMALL = 240, 120             -- typst half-gap 12 pt, small-gap 6 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_TAB = 1224                  -- typst para-indent + number-box (0.35 in): the text of an allegation
local ITEM_TEXT = 1296                   -- typst item-indent + item-box (0.4 in): the text of a relief item
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4752, 360   -- typst caption-left 3.3 in, caption-gutter 0.25 in
local CAP_INSET, CAP_PAD = 200, 105      -- typst caption-inset 10 pt; caption-pad 6 pt less the 0.75 pt rule LibreOffice
                                         -- adds to the row (typst draws the rule over the cell)
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local VERSUS = 1728                      -- typst versus-indent 1.2 in
local CELL_PAD = 100                     -- typst cell-pad 5 pt
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'       -- 0.75 pt
local THIN = 'w:val="single" w:sz="4" w:space="0" w:color="000000"'       -- 0.5 pt

local function text(v) return pandoc.utils.stringify(v) end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table without borders of its own and without cell margins; rows = { { trpr, cells = { { pr, body } } } }.
local function tbl(widths, rows, borders, mar)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row.cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (row.trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  mar = mar or 0
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. (borders or '') ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="' .. mar .. '" w:type="dxa"/><w:left w:w="' .. mar ..
    '" w:type="dxa"/><w:bottom w:w="' .. mar .. '" w:type="dxa"/><w:right w:w="' .. mar .. '" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local CANT_SPLIT = "<w:trPr><w:cantSplit/></w:trPr>"

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local COURT = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF ALASKA" }  -- FRBP 9004(b)(1)

local function cover(meta, out)
  for _, l in ipairs(meta.counsel or {}) do out[#out + 1] = p(xe.inl(l)) end
  for i, l in ipairs(COURT) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true, before = i == 1 and BODY or 0 })
  end
  -- The caption stands a double line below the court title: Word has no space before a table, so the first row's
  -- paragraphs carry it.
  local rows = {}
  for k, party in ipairs(meta.caption.parties) do
    local top = k == 1 and BODY or 0
    if k > 1 then
      rows[#rows + 1] = { trpr = CANT_SPLIT, cells = {
        { body = { p(xe.runs("v."), { before = SMALL, after = SMALL, left = VERSUS }) } },
        { body = { p("") } }, { body = { p("") } } } }
    end
    local left = {}
    local lines = {}
    if party.lead then lines[#lines + 1] = party.lead end
    for _, n in ipairs(party.names or {}) do lines[#lines + 1] = n end
    for j, l in ipairs(lines) do left[#left + 1] = p(xe.inl(l), { before = j == 1 and top or 0 }) end
    left[#left + 1] = p(xe.inl(party.designation), { jc = "right", after = CAP_PAD })
    local right = {}
    for j, r in ipairs(party.right or {}) do
      right[#right + 1] = p(xe.inl(r), { before = j == 1 and top or 0, left = RIGHT_INSET })
    end
    if #right == 0 then right[1] = p("", { before = top }) end
    rows[#rows + 1] = { trpr = CANT_SPLIT, cells = {
      { pr = '<w:tcBorders><w:bottom ' .. RULE .. '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET ..
        '" w:type="dxa"/></w:tcMar>', body = left },
      { body = { p("", { before = top }) } },
      { body = right } } }
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, rows)
  out[#out + 1] = p(xe.inl(meta.brief_title:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }), { b = true }),
    { before = BODY, jc = "center" })
  if meta.brief_subtitle then out[#out + 1] = p(xe.inl(meta.brief_subtitle), { before = SMALL, jc = "center" }) end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el, before)
  local lvl = el.level
  local content = el.content
  if lvl == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. math.min(lvl, 5)), xe.KEEP, xe.spacing(math.max(before, HALF), 0, BODY),
    xe.ind(0, nil, 0), xe.jc(lvl == 1 and "center" or "left") }, xe.inl(content, { b = true, i = lvl >= 3 }))
end

-- A data table (typst data-table): equal columns, thin rules, every cell padded 5 pt, single lines, the header row
-- bold; the table is kept on one page (each row with the next, no row split).
local function data_table(t, before, out)
  local rows = {}
  for _, r in ipairs(t.head.rows) do rows[#rows + 1] = { cells = r.cells, b = true } end
  for _, body in ipairs(t.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = { cells = r.cells } end
  end
  local n = #rows[1].cells
  local w = math.floor(TEXTW / n)
  local widths = {}
  for i = 1, n do widths[i] = i < n and w or TEXTW - w * (n - 1) end
  local trs = {}
  for k, r in ipairs(rows) do
    local cells = {}
    for _, c in ipairs(r.cells) do
      local inl = pandoc.Inlines({})
      for _, b in ipairs(c.contents) do if b.content then inl:extend(b.content) end end
      cells[#cells + 1] = { body = { p(xe.inl(inl, { b = r.b }), { keep = k < #rows }) } }
    end
    trs[#trs + 1] = { trpr = CANT_SPLIT, cells = cells }
  end
  -- Word has no space before a table: the paragraph above carries it (typst: the table's block above).
  local last = out[#out]
  out[#out] = last:gsub('w:after="(%d+)"', function(a) return 'w:after="' .. math.max(tonumber(a), before) .. '"' end, 1)
  out[#out + 1] = tbl(widths, trs, '<w:tblBorders><w:top ' .. THIN .. '/><w:left ' .. THIN .. '/><w:bottom ' .. THIN ..
    '/><w:right ' .. THIN .. '/><w:insideH ' .. THIN .. '/><w:insideV ' .. THIN .. '/></w:tblBorders>', CELL_PAD)
  return #rows + 1
end

local function body(blocks, out)
  local n = 0
  local pending = 0                      -- the space below the block before (a table's), for the next paragraph
  for _, b in ipairs(blocks) do
    local before = pending
    pending = 0
    if b.t == "Header" then
      out[#out + 1] = heading(b, before)
    elseif (b.t == "Para" or b.t == "Plain") and text(b):match("^Table %d") and #text(b) < 40 then
      -- a table title, centered and bold, unnumbered, kept with its table
      out[#out + 1] = p(xe.inl(b.content, { b = true }), { before = math.max(before, HALF), jc = "center", keep = true })
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
        { line = BODY, first = INDENT, tab = NUMBER_TAB, before = before })
    elseif b.t == "Table" then
      -- LibreOffice adds each 0.5 pt rule (10 twips) to the table's height; typst draws them over the cells
      pending = HALF - 10 * data_table(b, HALF, out)
    elseif b.t == "BlockQuote" then
      -- LBR 9004-1(a)(4): quotations over fifty words single-spaced and indented
      for k, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = k == 1 and math.max(before, HALF) or 0,
          after = k == #b.content and HALF or 0, left = INDENT, right = INDENT })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- relief items, lettered A., B., ... (typst enum "A."): the letter half an inch in, the text a box after it
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ((b.t == "OrderedList" and (string.char(64 + j) .. ".") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content),
            { line = BODY, left = ITEM_TEXT, hanging = ITEM_TEXT - INDENT, before = j == 1 and k == 1 and before or 0 })
        end
      end
    else
      error("akb: unsupported block " .. b.t)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Consent statement and signature block
-- ---------------------------------------------------------------------------

local function consent(meta, out)
  out[#out + 1] = p(xe.runs("STATEMENT REGARDING CONSENT", { b = true }), { before = BODY, line = BODY, keep = true })
  -- kept with the signature block, so the signature never stands on a page alone
  out[#out + 1] = p(xe.inl(meta.consent), { line = BODY, first = INDENT, keep = true })
end

local function signature(meta, out)
  local sig = meta.signature
  local right = {}
  for j, l in ipairs(sig.firm or {}) do right[#right + 1] = p(xe.inl(l), { before = j == 1 and BODY or 0 }) end
  for j, l in ipairs(sig.lines or {}) do
    right[#right + 1] = p(xe.inl(l), { before = j == 1 and (#right == 0 and BODY or SMALL) or 0 })
  end
  right[#right + 1] = p(xe.runs("/s/ " .. text(sig.signer)), { before = #right == 0 and BODY or HALF })
  right[#right + 1] = p(xe.runs(text(sig.signer)))
  local left = p(meta.date and xe.runs("Dated: " .. text(meta.date)) or "", { before = BODY })
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, { { trpr = CANT_SPLIT, cells = {
    { body = { left } }, { body = { p("", { before = BODY }) } }, { body = right } } } })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 549"), as the typst template boxes it (xe.inl binds a single sign).
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
  if doc.meta.consent == nil then
    error("akb: FRBP 7008(a) and LBR 7012-1 require a consent statement (frontmatter: consent)", 0)
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, before = BODY }) end
  body(doc.blocks, out)
  consent(meta, out)
  signature(meta, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
