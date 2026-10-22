-- Complaint, U.S. District Court for the District of Arizona (azd), DOCX engine (docs/DOCX.md): what the Word output
-- adds to pandoc's conversion, so that it reads and breaks as typst/azd-complaint.typ does: counsel from line 1
-- (LRCiv 7.1(a)(1)); court title on or below line 6 (7.1(a)(2)); caption with the case number, title and jury demand
-- right of center (7.1(a)(3)); the lead-in, the numbered allegations (Fed. R. Civ. P. 10(b)), the headings, the
-- lettered relief items, the signature block and the certificate of service. The page furniture (27 pleading
-- numbers in a header text box, the rules as page borders, the page number) lives in docx/reference.xml.
-- Everything case-specific comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 a numbered line, 320 a single line), the spaces between
-- blocks those of the typst template, and the break rules of typst on every run. Single-spaced blocks end on the
-- grid of numbered lines: the space after their last line is counted from their entries, as typst grid-pad does.

local xe = require("docx.xengine")

local PITCH, SINGLE = 480, 320           -- typst pitch, pitch-single
local LIFT = 128                         -- typst single-lift 6.4 pt: a single block's first baseline on a numbered line's
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_TAB = 1440                  -- typst para-indent + number-box: the text of an allegation
local ITEM_TEXT = 1296                   -- typst item-indent + item-box (0.4 in): the text of a relief item
local TEXTW = 8640                       -- typst text-width, 6 in
local CAP_LEFT, CAP_GUTTER = 4608, 288   -- typst caption-left 3.2 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local CAP_PAD = 160                      -- typst caption-pad 8 pt
local CAP_RULE = 15                      -- the 0.75 pt rule LibreOffice adds to the row (typst draws it over the cell)
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local TITLE_GAP = 240                    -- typst title-gap 12 pt
local COUNSEL_LINES = 5                  -- typst counsel-lines
local SIG = TEXTW - 4896                 -- typst signature-width 3.4 in, at the right margin
local CERT = TEXTW - 5184                -- typst certificate-width 3.6 in
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function text(v) return pandoc.utils.stringify(v) end

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- typst grid-pad: the space that brings n single lines (and `extra` twips) down to the next numbered line.
local function grid_pad(n, extra)
  local h = LIFT + n * SINGLE + (extra or 0)
  return math.ceil(h / PITCH) * PITCH - h
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

local function cell(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

-- The caption (LRCiv 7.1(a)(3)): party names, designations and "v." on the left, ruled below and to the right; the
-- case number and the title (with any jury demand) on the right. A numbered line above it; returns the space below
-- it (a numbered line, after the rows brought to the grid), which the next paragraph takes.
local function caption(meta, out)
  local rows = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then rows[#rows + 1] = xe.runs("v.") end
    for _, n in ipairs(party.names) do rows[#rows + 1] = xe.inl(n) end
    rows[#rows + 1] = xe.inl(party.designation)
  end
  local left = {}
  for i, r in ipairs(rows) do
    left[#left + 1] = p(r, { before = i == 1 and (PITCH + LIFT) or 0, after = i == #rows and (CAP_PAD - CAP_RULE) or 0 })
  end
  local right = p(xe.runs("Case No. " .. text(meta.case_number)), { before = PITCH + LIFT, left = RIGHT_INSET })
    .. p(xe.inl(meta.brief_title, { b = true }), { before = TITLE_GAP, left = RIGHT_INSET })
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="'
    .. (TEXTW - CAP_LEFT - CAP_GUTTER) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_LEFT, '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders><w:tcMar><w:right w:w="'
      .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', table.concat(left))
    .. cell(CAP_GUTTER, nil, p("", { before = PITCH + LIFT }))
    .. cell(TEXTW - CAP_LEFT - CAP_GUTTER, nil, right)
    .. '</w:tr></w:tbl>'
  return PITCH + grid_pad(#rows, CAP_PAD)
end

local function cover(meta, out)
  -- Lines 1 to 5 at least; a longer counsel block pushes the court title down (LRCiv 7.1(a)(2)).
  local counsel = meta.counsel
  local pad = math.max(grid_pad(#counsel), COUNSEL_LINES * PITCH - LIFT - #counsel * SINGLE)
  for i, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l), { before = i == 1 and LIFT or 0, after = i == #counsel and pad or 0 }) end
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { line = PITCH, jc = "center", keep = true })
  out[#out + 1] = p(xe.runs("FOR THE DISTRICT OF ARIZONA", { b = true }), { line = PITCH, jc = "center", keep = true })
  return caption(meta, out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el, before)
  local lvl = el.level
  local content = lvl == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. math.min(lvl, 5)), xe.KEEP, xe.spacing(before, 0, PITCH), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl >= 3 }))
end

-- Numbered allegations (Fed. R. Civ. P. 10(b)), unnumbered headings, lettered relief items; the last block is kept
-- with the signature block (typst: a sticky block).
local function body(blocks, out, before)
  local n = 0
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local top = i == 1 and before or 0
    if b.t == "Header" then
      out[#out + 1] = heading(b, top)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
        { line = PITCH, first = INDENT, tab = NUMBER_TAB, before = top, keep = last })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ((b.t == "OrderedList" and (string.char(64 + j) .. ".") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = PITCH, left = ITEM_TEXT,
            hanging = ITEM_TEXT - INDENT, before = (j == 1 and k == 1) and top or 0, keep = last })
        end
      end
    else
      error("azd-complaint: unsupported block " .. b.t)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

-- LRCiv 7.1 gives no signature form; the "DATED this ... day of ..." line is the form of the local rules' Appendix C.
-- The firm, a blank single line, the signature line and the lines under it, kept together and brought to the grid.
local function signature(meta, out)
  local sig = meta.signature
  out[#out + 1] = p(xe.runs("DATED this ") .. xe.inl(meta.date) .. xe.runs("."), { before = PITCH, line = PITCH, keep = true })
  local lines = {}
  for j, l in ipairs(sig.firm) do lines[#lines + 1] = { xe.inl(l), j == 1 and LIFT or 0 } end
  lines[#lines + 1] = { xe.runs("By: /s/ " .. text(sig.signer)), SINGLE }
  for _, l in ipairs(sig.lines) do lines[#lines + 1] = { xe.inl(l), 0 } end
  local pad = grid_pad(#lines + 1)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = i < #lines, after = i == #lines and pad or 0 })
  end
  return pad
end

-- `pad`: the space that ends the signature block (Word takes the larger of two spaces, typst adds a padding to one).
local function certificate(c, out, pad)
  out[#out + 1] = p(xe.inl(c.heading, { b = true }), { before = PITCH + pad, line = PITCH, jc = "center", keep = true })
  out[#out + 1] = p(xe.inl(c.text), { line = PITCH, first = INDENT })
  out[#out + 1] = p(xe.runs("/s/ " .. text(c.signer)), { line = PITCH, left = CERT })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1332"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  for _, k in ipairs({ "case_number", "caption", "brief_title", "counsel", "date", "signature" }) do
    if doc.meta[k] == nil then error("azd-complaint: the sample frontmatter needs `" .. k .. "`", 0) end
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  local below = cover(meta, out)
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { line = PITCH, first = INDENT, before = below })
    below = 0
  end
  body(doc.blocks, out, below)
  local pad = signature(meta, out)
  if meta.certificate then certificate(meta.certificate, out, pad) end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
