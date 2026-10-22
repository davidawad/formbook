-- Complaint for the U.S. District Court for the Middle District of Florida (flmd), docx engine: what the Word output
-- adds to pandoc's conversion, so that it reads and breaks as typst/flmd-complaint.typ does: the court title and
-- caption (FRCP 10(a)), the numbered paragraphs (FRCP 10(b)), the lettered lists, the unnumbered `~ ` paragraphs
-- (the jury demand), the headings and the signature block. Everything printed comes from the sample's frontmatter
-- and body: no case text lives in this file. The caption is an OOXML table, because pandoc has no caption construct.
-- "~ " is an unnumbered paragraph in this contract, so pandoc's definition lists are off (reference.xml pandoc-from).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 644, 322          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent, 0.5 in
local NUMBER_BOX = 720                 -- typst number-box: the text of a numbered paragraph starts at 1 in
local TEXTW = 9360                     -- 6.5 in
local CAP_W, CAP_GUTTER = 4176, 360    -- typst caption-w 2.9 in, caption-gutter 0.25 in
local DESIG = 720                      -- typst designation-indent 0.5 in
local CASE_DROP = 720                  -- typst case-number-drop 0.5 in
local ITEM_INDENT, ITEM_LABEL = 720, 576 -- typst item-indent 0.5 in, item-label 0.4 in
local SIG_INDENT = 4320                -- typst sig-indent 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tabs } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tab_at(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

-- ---------------------------------------------------------------------------
-- Court title and caption (FRCP 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" }),
    p(xe.runs("MIDDLE DISTRICT OF FLORIDA", { b = true }), { jc = "center" }),
  }
  if meta.division then
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.division)), { b = true }), { jc = "center" })
  end
  -- the caption stands a double line below the title (typst: the caption block's above); Word has no space before a
  -- table, so the last title line takes it as space after
  out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. BODY .. '"', 1)
  -- Party column: names, the designation (indented), the versus word between the parties, the closing rule.
  local versus = meta.caption.versus and plain(meta.caption.versus) or "v."
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.inl(versus)) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG })
  end
  left[#left + 1] = p(xe.runs(string.rep("_", 29) .. "/"))
  local right = { p(xe.runs("CASE NO.: " .. plain(meta.case_number)), { before = CASE_DROP }) }
  local rest = TEXTW - CAP_W
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_W .. '"/><w:gridCol w:w="' .. rest .. '"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_W .. '" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. rest .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_GUTTER ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- The title of the paper: a double line below the caption, a single line above the text.
  out[#out + 1] = p(xe.inl(meta.brief_title, { b = true }), { jc = "center", before = BODY, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Body and signature
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered (FRCP 10(b)): the indent, the
-- number, a tab to the end of its box (typst: the number in a box of number-box), the text.
local function body_par(label, inlines, o)
  o = o or {}
  local body = xe.inl(inlines)
  local tabs
  if label then
    body = xe.runs(label .. "\t") .. body
    tabs = tab_at(INDENT + NUMBER_BOX)
  end
  return p(body, { line = BODY, first = INDENT, tabs = tabs, before = o.before, keep = o.keep })
end

-- Headings at the body pitch, bold; level 1 and 2 centered, level 3 italic at the margin; kept with the text.
local function heading(el)
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(el.content, { b = true, i = el.level > 2 }))
end

-- Lettered items (a), (b), ... continuing across the list (typst enum "(a)"): the label half an inch in, the text
-- hanging a label box after it.
local function lettered(list, out)
  for j, item in ipairs(list.content) do
    for k, b in ipairs(item) do
      local lab = k == 1 and ("(" .. string.char(96 + j) .. ")\t") or ""
      out[#out + 1] = p(xe.runs(lab) .. xe.inl(b.content),
        { line = BODY, left = ITEM_INDENT + ITEM_LABEL, hanging = ITEM_LABEL })
    end
  end
end

-- "RESPECTFULLY SUBMITTED <date>." at the double pitch, then the firm, the s/ line and the counsel lines,
-- single-spaced at 3 in; the lines kept together.
local function signature(meta, out)
  out[#out + 1] = body_par(nil, "RESPECTFULLY SUBMITTED " .. plain(meta.date) .. ".", { before = SINGLE })
  local sig = meta.signature
  local lines = {}
  for _, f in ipairs(sig.firm or {}) do lines[#lines + 1] = xe.inl(f) end
  lines[#lines + 1] = xe.runs("s/" .. plain(sig.signer))
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = xe.inl(l) end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { left = SIG_INDENT, before = i == 1 and BODY or 0, keep = i < #lines })
  end
end

local function is_unnumbered(b)
  local first, second = b.content[1], b.content[2]
  return first and first.t == "Str" and first.text == "~" and second and second.t == "Space"
end

-- typst binds a doubled section sign or pilcrow to its number ("§§ 1331"); pandoc's own binding takes one sign.
local function bind_double_signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks, Inlines = bind_double_signs })
  local meta = doc.meta
  local out = cover(meta)
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in) end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif (b.t == "Para" or b.t == "Plain") and is_unnumbered(b) then
      local rest = pandoc.Inlines({})
      for i = 3, #b.content do rest:insert(b.content[i]) end
      out[#out + 1] = body_par(nil, rest)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(n .. ".", b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      lettered(b, out)
    else
      error("flmd-complaint.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
