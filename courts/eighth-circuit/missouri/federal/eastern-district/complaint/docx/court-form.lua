-- Court form for the E.D. Mo. docx engine: what the Word output adds to pandoc's conversion, so that it reads and
-- breaks as typst/moed-<doctype>.typ does: the court name in the 2 inch band (L.R. 2.01(A)(2)), the caption table,
-- the title, the lead-in, the body (headings, paragraphs, lettered lists, notes) and the signature block. Everything
-- printed comes from the sample's frontmatter and body: no case text lives in this file. The caption is an OOXML
-- table, because pandoc has no caption construct.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

-- NUMBERED: the template numbers each body paragraph (the complaint); the motion brief is unnumbered prose.
local NUMBERED = true
-- Heading alignment by level (the complaint centers levels 1 and 2), and the indent of each level.
local HEADING_JC = { "center", "center", "left" }
local HEADING_IND = { 0, 0, 0 }

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276             -- typst pitch-double, pitch-single
local INDENT = 720                        -- typst para-indent and item-indent, 0.5 in
local TEXTW = 9360                        -- 6.5 in
local BAND = 1440                         -- typst corner - margin: the court name's band, 1 in
local CAP_LEFT, CAP_GUTTER = 4752, 432    -- typst caption-left 3.3 in, caption-gutter 0.3 in
local CAP_INSET, CAP_PAD = 216, 144       -- typst caption-inset 0.15 in, caption-pad 0.1 in
local DESIG = 720                         -- typst designation-indent 0.5 in
local SIG = 4680                          -- typst signature-indent 3.25 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, hanging, first, tab, jc, keep, style } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- First page: the court name in the band, the caption, the title
-- ---------------------------------------------------------------------------

local function court_title(m)
  local lines = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF MISSOURI" }
  if m.division then lines[#lines + 1] = plain(m.division) end
  local out = {}
  for i, l in ipairs(lines) do
    -- the last line's space after fills the band, so the caption starts 2 inches from the top of the page
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #lines and (BAND - SINGLE * #lines) or 0 })
  end
  return table.concat(out)
end

local function caption(m)
  local left = {}
  local parties = m.caption.parties
  for i, party in ipairs(parties) do
    if i > 1 then left[#left + 1] = p(xe.runs("v.")) end
    left[#left + 1] = p(xe.inl(party.names))
    -- the bottom rule stands the pad off the last line (as space after it: a cell margin would move the whole row)
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG, after = i == #parties and CAP_PAD or 0 })
  end
  local number = m.case_number and plain(m.case_number) or "______________"
  local right = { p(xe.runs("Case No. " .. number)) }
  for i, l in ipairs(m.legends or {}) do
    right[#right + 1] = p(xe.inl(l, { b = true }), { before = i == 1 and SINGLE or 0 })
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. rule .. '/><w:right ' ..
    rule .. '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_GUTTER ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

-- The title of the paper: bold, centered, single-spaced, a double line below the caption, a single line above the
-- text (Word has no space after a table, so the title takes it as space before).
local function title(s)
  return p(xe.inl(s, { b = true }), { jc = "center", before = BODY, after = SINGLE, keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature block (L.R. 2.01(A)(1): name, address, telephone, email and bar number under each signature), at
-- 3.25 inch, single spaced; then the party represented. Kept on one page (each line kept with the next).
-- ---------------------------------------------------------------------------

local function signature(m, after)
  local lines = {}
  local function add(body, o) lines[#lines + 1] = { body, o } end
  if m.date then add(xe.runs("DATED: ") .. xe.inl(m.date), {}) end
  add(xe.runs("Respectfully submitted,"), { left = SIG, before = m.date and BODY or 0 })
  for _, f in ipairs(m.signature) do
    add(xe.inl(f.firm, { b = true }), { left = SIG, before = SINGLE })
    if f.signer then add(xe.inl(f.signer), { left = SIG }) end
    for _, l in ipairs(f.lines) do add(xe.inl(l), { left = SIG }) end
  end
  if m.attorneys_for then add(xe.inl(m.attorneys_for, { i = true }), { left = SIG, before = SINGLE }) end
  lines[1][2].before = BODY
  local out = {}
  for i, l in ipairs(lines) do
    l[2].keep = i < #lines
    if i == #lines then l[2].after = after end
    out[#out + 1] = p(l[1], l[2])
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the first-line
-- indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines)
  if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT, tab = 2 * INDENT })
end

local function heading(el)
  local lv = math.min(el.level, 3)
  return p(xe.inl(el.content, { b = true }), { style = "Heading" .. el.level, keep = true, line = BODY,
    left = HEADING_IND[lv], jc = HEADING_JC[lv] })
end

-- Lettered items (a), (b), ...: the label half an inch in, the text hanging a further half inch.
local function list(b, out)
  for i, item in ipairs(b.content) do
    for k, blk in ipairs(item) do
      local lab = k == 1 and ("(" .. string.char(96 + i) .. ")\t") or ""
      out[#out + 1] = p(xe.runs(lab) .. xe.inl(blk.content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
    end
  end
end

local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  local m = doc.meta
  doc = doc:walk({ Str = breaks })
  local out = { court_title(m), caption(m) }
  if m.title then out[#out + 1] = title(m.title) end
  if m.lead_in then out[#out + 1] = body_par(nil, m.lead_in) end
  local signed = false
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 and starts_with(plain(b.content), "CERTIFICATE") and m.signature and not signed then
        -- The signature ends the argument; the certificate of service follows it (as in the filed brief).
        out[#out + 1] = signature(m, BODY)
        signed = true
      end
      out[#out + 1] = heading(b)
    elseif (b.t == "Para" or b.t == "Plain") and starts_with(plain(b.content):gsub("\u{200B}", ""), "/s/") then
      -- A signature line (certificate of service): single spaced, at the signature indent.
      out[#out + 1] = p(xe.inl(b.content), { left = SIG, before = SINGLE })
    elseif b.t == "Para" or b.t == "Plain" then
      local label = nil
      if NUMBERED then
        n = n + 1
        label = n .. "."
      end
      out[#out + 1] = body_par(label, b.content)
    elseif b.t == "BlockQuote" then
      -- A note (an omission marker): single spaced, a single line off the text.
      for _, q in ipairs(b.content) do out[#out + 1] = p(xe.inl(q.content), { before = SINGLE, after = SINGLE }) end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      list(b, out)
    else
      error("court-form.lua: unsupported block " .. b.t)
    end
  end
  if m.signature and not signed then out[#out + 1] = signature(m, 0) end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
