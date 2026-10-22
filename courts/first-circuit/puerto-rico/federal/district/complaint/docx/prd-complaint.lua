-- prd-complaint.lua (docx engine, D.P.R. complaint): what the Word output adds to pandoc's conversion, so that it reads
-- and breaks as typst/prd-complaint.typ does: the court title (PRD-CAP-001), the caption (PRD-CAP-002: parties left
-- with a rule on the right and bottom, case number and title right), the lead-in, the numbered allegations
-- (Fed. R. Civ. P. 10(b)), the "WHEREFORE" lead-in without a number, the lettered prayer items, the headings
-- (PRD-CONT-001) and the signature block (PRD-SIG-001). Everything printed comes from the sample's frontmatter and
-- body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local HALF = 240                         -- typst half-gap 12 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_TAB = 1440                  -- typst para-indent + number-box: the text of a numbered paragraph
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left 3.4 in
local CAP_INSET, CAP_PAD = 200, 240      -- typst caption-inset 10 pt, caption-pad 12 pt
local CAP_GUTTER = 504                   -- typst caption-gutter 0.35 in
local DESIGNATION = 2016                 -- typst designation-indent 1.4 in
local SIG_COL = 4608                     -- typst sig-column 3.2 in

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function text(v) return pandoc.utils.stringify(v) end

-- ---------------------------------------------------------------------------
-- Court title and caption
-- ---------------------------------------------------------------------------

local COURT = { "UNITED STATES DISTRICT COURT", "DISTRICT OF PUERTO RICO" }  -- PRD-CAP-001, the same for every case

local function cover(meta, out)
  for _, l in ipairs(COURT) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true }) end
  -- Left cell: each party's names, then its designation a line below, set in; "v." between the parties. The caption
  -- stands a double line below the court title (typst: the caption block's above).
  local left = {}
  local sides = meta.caption
  for i, side in ipairs(sides) do
    if i > 1 then left[#left + 1] = p(xe.runs("v."), { before = HALF }) end
    for j, n in ipairs(side.names) do
      left[#left + 1] = p(xe.inl(n), { before = (#left == 0) and BODY or (i > 1 and j == 1) and HALF or 0 })
    end
    left[#left + 1] = p(xe.inl(side.designation),
      { before = SINGLE, left = DESIGNATION, after = i == #sides and CAP_PAD or 0 })
  end
  local right = {
    p(xe.runs("No. " .. text(meta.case_number)), { before = BODY }),
    p(xe.inl(upper(meta.brief_title), { b = true }), { before = HALF }),
  }
  if meta.jury_demand then right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = HALF }) end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
end

-- ---------------------------------------------------------------------------
-- Signature block: the date left, "Respectfully submitted," and the counsel groups in the right column; the block
-- never breaks across a page: one table row that cannot split holds it all
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local right = { p(xe.runs("Respectfully submitted,"), { before = BODY }) }
  for _, g in ipairs(meta.signature.groups) do
    local lines = {}
    if g.signer then
      lines[#lines + 1] = xe.runs("By: s/ " .. text(g.signer))
      lines[#lines + 1] = xe.runs(text(g.signer))
    end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = xe.inl(l) end
    for j, l in ipairs(lines) do right[#right + 1] = p(l, { before = j == 1 and HALF or 0 }) end
  end
  out[#out + 1] = tbl({ TEXTW - SIG_COL, SIG_COL }, {
    { body = { p(xe.runs("Dated: " .. text(meta.date)), { before = BODY }) } },
    { body = right },
  }, "<w:trPr><w:cantSplit/></w:trPr>")
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el)
  local lvl = el.level
  local content = lvl == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. math.min(lvl, 5)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(content, { b = true, i = lvl >= 3 }))
end

local function body(blocks, out)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if text(b):sub(1, 9) == "WHEREFORE" then
        -- the prayer's lead-in is not an allegation: an indented paragraph without a number
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = NUMBER_TAB })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- prayer items, lettered A., B., ... (typst enum "A."): the letter half an inch in, the text a box after it
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ((b.t == "OrderedList" and (string.char(64 + j) .. ".") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
        end
      end
    else
      error("prd-complaint: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1983"), as the typst template boxes it (xe.inl binds a single sign).
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
  for _, k in ipairs({ "case_number", "caption", "brief_title", "date", "signature" }) do
    if doc.meta[k] == nil then error("prd-complaint: missing required metadata field `" .. k .. "`", 0) end
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, before = BODY }) end
  body(doc.blocks, out)
  signature(meta, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
