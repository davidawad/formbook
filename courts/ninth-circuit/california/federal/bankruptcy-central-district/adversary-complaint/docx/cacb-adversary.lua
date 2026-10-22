-- Adversary complaint, C.D. Cal. bankruptcy court (cacb), DOCX engine (docs/DOCX.md): what the Word output adds to
-- pandoc's conversion, so that it reads and breaks as typst/cacb-adversary-complaint.typ does: the counsel block on
-- lines 1-7 (Central Guide 9004-1(c)(1)), the court title, the double caption (a table: the debtor and the parties
-- ruled on the left, the case numbers, the title and the hearing on the right), then the body from page 2: the
-- allegations numbered here (FRBP 7010), WHEREFORE and headings unnumbered, list items numbered from the markdown
-- start number, the signature block (a table) kept with the last paragraph. The line numbers, the pleading rules and
-- the footer come from docx/reference.xml; the footer's title and adversary number are the document's SUBJECT and
-- COMMENTS properties, set here from the sample. Everything printed comes from the sample's frontmatter and body:
-- no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 a numbered line, 240 a single line), the spaces between
-- blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 240            -- typst pitch, pitch-single
local HALF = 240                         -- typst half-gap 12 pt
local TO_GRID = 432                      -- typst to-grid 21.6 pt: single lines on the numbered lines' baselines
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_TAB = 1440                  -- typst para-indent + number-box: the text of an allegation or list item
local TEXTW = 8640                       -- typst text-width, 6 in
local CAP_LEFT, CAP_GUTTER = 4176, 288   -- typst caption-left 2.9 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local CAP_PAD = 145                      -- typst caption-pad 8 pt, less the 0.75 pt rule LibreOffice adds to the row
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local SIG_LEFT = 3744                    -- typst sig-left 2.6 in
local COUNSEL_LINES = 7                  -- typst counsel-lines (Central Guide 9004-1(c)(1)(B))
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

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab, pagebreak }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.pagebreak then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table without borders of its own or cell margins; cells = { { pr, body } }.
local function tbl(widths, cells)
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
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. CANT_SPLIT .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel (lines 1-7), court title (line 8), double caption
-- ---------------------------------------------------------------------------

local COURT = { "UNITED STATES BANKRUPTCY COURT", "CENTRAL DISTRICT OF CALIFORNIA" }

local function cover(meta, out)
  -- counsel: single lines from line 1, filling at least lines 1-7; more lines push the court title down by whole
  -- numbered lines, half a line kept below the last (typst counsel-block)
  local counsel = list(meta.counsel)
  for _, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l)) end
  local rows = math.max(COUNSEL_LINES, math.ceil((#counsel + 1) / 2))
  local court = { COURT[1], COURT[2], pandoc.text.upper(text(meta.division)) }
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }),
      { line = BODY, jc = "center", keep = true, before = i == 1 and (rows * BODY - #counsel * SINGLE) or 0 })
  end
  -- The caption stands a numbered line (less 2.4 pt, typst to-grid) below the court title: Word has no space before a table, so the first
  -- paragraph of each cell carries it.
  local left = { p(xe.runs("In re:"), { before = TO_GRID }) }
  for _, n in ipairs(list(meta.caption.debtor.names)) do left[#left + 1] = p(xe.inl(n)) end
  left[#left + 1] = p(xe.inl(meta.caption.debtor.designation))
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { before = HALF }) end
    for j, n in ipairs(list(party.names)) do left[#left + 1] = p(xe.inl(n), { before = j == 1 and HALF or 0 }) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  left[#left] = left[#left]:gsub('w:after="0"', 'w:after="' .. CAP_PAD .. '"', 1)
  local function r(body, before) return p(body, { before = before or 0, left = RIGHT_INSET }) end
  local right = {
    r(xe.runs("Case No. " .. text(meta.bankruptcy_case)), TO_GRID),
    r(xe.runs("Chapter " .. text(meta.chapter))),
    r(xe.runs("Adv. No. " .. text(meta.adversary_number)), HALF),
    r(xe.inl(meta.brief_title, { b = true }), HALF),
  }
  if meta.legend then right[#right + 1] = r(xe.runs(pandoc.text.upper(text(meta.legend)), { b = true }), HALF) end
  for j, l in ipairs(list(meta.hearing)) do right[#right + 1] = r(xe.inl(l), j == 1 and HALF or 0) end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("", { before = TO_GRID }) } },
    { body = right },
  })
end

-- ---------------------------------------------------------------------------
-- Signature block: the date left; "Respectfully submitted,", the firm and the signer right; one numbered line above
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,"), { before = TO_GRID }) }
  for j, l in ipairs(list(sig.firm)) do right[#right + 1] = p(xe.inl(l), { before = j == 1 and HALF or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ " .. text(sig.signer)), { before = HALF })
  right[#right + 1] = p(xe.runs(pandoc.text.upper(text(sig.signer))))
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ SIG_LEFT, CAP_GUTTER, TEXTW - SIG_LEFT - CAP_GUTTER }, {
    { body = { p(xe.runs("Dated: " .. text(meta.date)), { before = TO_GRID }) } },
    { body = { p("", { before = TO_GRID }) } },
    { body = right },
  })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el)
  local lvl = el.level
  local content = lvl == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. math.min(lvl, 5)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl >= 3 }))
end

-- The body blocks; the last paragraph or list item is kept with the signature block (typst: one unbreakable block).
local function body(blocks, out, first)
  local n = 0
  local function o(t) t.pagebreak = first; first = false; return t end
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if text(b):sub(1, 9) == "WHEREFORE" then
        -- the prayer's lead-in is not an allegation: an indented paragraph without a number
        out[#out + 1] = p(xe.inl(b.content), o({ line = BODY, first = INDENT, keep = last }))
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          o({ line = BODY, first = INDENT, tab = NUMBER_TAB, keep = last }))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- the number half an inch in, the text a box after it, from the markdown start number (typst's enum)
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ((b.t == "OrderedList" and ((start + j - 1) .. ".") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content),
            o({ line = BODY, left = NUMBER_TAB, hanging = NUMBER_TAB - INDENT, keep = last and j == #b.content }))
        end
      end
    else
      error("cacb-adversary: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 547"), as the typst template boxes it (xe.inl binds a single sign).
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
  for _, k in ipairs({ "footer_title", "adversary_number", "bankruptcy_case", "chapter", "division", "caption",
    "brief_title", "counsel", "date", "signature" }) do
    if doc.meta[k] == nil then error("cacb-adversary: missing required metadata field `" .. k .. "`", 0) end
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  -- the body starts on page 2 (the cover is page 1)
  local first = true
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, pagebreak = true })
    first = false
  end
  body(doc.blocks, out, first)
  out[#out + 1] = signature(meta)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  -- the footer reads the document properties (docProps/core.xml) through its SUBJECT and COMMENTS fields
  return pandoc.Pandoc(blocks, pandoc.Meta({
    subject = pandoc.MetaInlines({ pandoc.Str(pandoc.text.upper(text(meta.footer_title))) }),
    description = pandoc.MetaInlines({ pandoc.Str(text(meta.adversary_number)) }),
  }))
end
