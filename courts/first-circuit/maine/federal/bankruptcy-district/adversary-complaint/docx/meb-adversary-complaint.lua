-- meb-adversary-complaint.lua (docx engine): the D. Me. bankruptcy adversary complaint as Word paragraphs and a
-- caption table, so that it reads and breaks as typst/meb-adversary-complaint.typ does:
--   * the cover: the without-hearing legend when set, the court name, the caption (the main case and, when the
--     sample has `parties`, the adversary proceeding; each a pair of boxes closed by rules), the title of the paper;
--   * the unnumbered opening paragraphs, then the body: each prose paragraph numbered 1, 2 ... (Fed. R. Civ. P.
--     10(b)); headings and lettered lists are not;
--   * the WHEREFORE paragraph kept with the date and signature block.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276             -- typst pitch-double, pitch-single
local GAP = 240                           -- typst heading-gap, 12 pt
local INDENT = 720                        -- typst para-indent, number-width, item-indent, item-label: 0.5 in
local CAPTION_LEFT, CAPTION_RIGHT = 4896, 4464 -- typst caption-left 3.4 in, the rest of the 6.5 in
local INSET_TOP, INSET_BOTTOM = 120, 200  -- typst caption-inset 6 pt, 10 pt
local GAP_LEFT, GAP_RIGHT = 200, 288      -- typst caption-gap-left 10 pt, caption-gap-right 0.2 in
local RULE = 6                            -- typst rule 0.75 pt, in eighths of a point
local SIG = 4320                          -- typst sig-col, 3 in

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tabs .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A metadata value as a list of values (a YAML list, or one value).
local function list(v)
  if v == nil then return {} end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then return v end
  return { v }
end

-- A metadata value that holds markdown (one paragraph, or several) as a list of inline lists.
local function paragraphs(v)
  if v == nil then return {} end
  if v.t == "MetaBlocks" then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b.content end
    return out
  end
  return { v }
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption, title of the paper (FRBP 7010; LBR 7003-1(a))
-- ---------------------------------------------------------------------------

local function rule(sides)
  local x = {}
  for _, s in ipairs(sides) do
    x[#x + 1] = '<w:' .. s .. ' w:val="single" w:sz="' .. RULE .. '" w:space="0" w:color="000000"/>'
  end
  return '<w:tcBorders>' .. table.concat(x) .. '</w:tcBorders>'
end

local function cell(width, lines, borders, left, right)
  local ps = {}
  for _, l in ipairs(lines) do ps[#ps + 1] = p(l) end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. borders ..
    '<w:tcMar><w:top w:w="' .. INSET_TOP .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. INSET_BOTTOM .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>' ..
    '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function caption(m)
  local left = { xe.runs("In re:") }
  for _, n in ipairs(list(m.debtor.names)) do left[#left + 1] = xe.inl(n) end
  left[#left + 1] = xe.inl(m.debtor.designation)
  local rows = { { left, { xe.runs("Chapter ") .. xe.inl(m.chapter), xe.runs("Case No. ") .. xe.inl(m.case_number) } } }
  if m.parties ~= nil then
    local parties = {}
    for k, party in ipairs(m.parties) do
      if k > 1 then parties[#parties + 1] = xe.runs("v.") end
      for _, n in ipairs(list(party.names)) do parties[#parties + 1] = xe.inl(n) end
      parties[#parties + 1] = xe.inl(party.designation)
    end
    rows[#rows + 1] = { parties, { xe.runs("Adv. Proc. No. ") .. xe.inl(m.adv_number) } }
  end
  local trs = {}
  for _, r in ipairs(rows) do
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      cell(CAPTION_LEFT, r[1], rule({ "bottom", "right" }), 0, GAP_LEFT) ..
      cell(CAPTION_RIGHT, r[2], rule({ "bottom" }), GAP_RIGHT, 0) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (CAPTION_LEFT + CAPTION_RIGHT) .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAPTION_LEFT .. '"/><w:gridCol w:w="' .. CAPTION_RIGHT .. '"/></w:tblGrid>' ..
    table.concat(trs) .. '</w:tbl>'
end

local function cover(m, out)
  local legend = m.without_hearing == true
  if legend then
    -- D. Me. LBR 9013-3: the legend goes in the upper right corner of the first page.
    out[#out + 1] = p(xe.runs("RELIEF REQUESTED WITHOUT A HEARING", { b = true }), { jc = "right", keep = true })
  end
  out[#out + 1] = p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }),
    { jc = "center", keep = true, before = legend and GAP or 0 })
  -- the caption a double line below the court name (Word has no space before a table: the line above takes it)
  out[#out + 1] = p(xe.runs("DISTRICT OF MAINE", { b = true }), { jc = "center", keep = true, after = BODY })
  out[#out + 1] = caption(m)
  -- the title a double line below the caption, half a double line above the text
  out[#out + 1] = p(xe.inl(upper(m.title), { b = true }), { before = BODY, after = GAP, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings in a double line box, half a double line above and below: level 1 centered capitals, level 2 bold,
-- level 3 bold italic; kept with the text after them.
local function heading(el)
  local content, o = el.content, { b = true }
  if el.level == 1 then content = upper(content) elseif el.level >= 3 then o.i = true end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(GAP, GAP, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, o))
end

local function blocks(doc, out)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the number in a box of number-width after the first-line indent (typst: box(width: number-width))
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tabs = 2 * INDENT })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- lettered (a), (b) ...: the label half an inch in, the text hanging a label box after it
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ("(" .. string.char(96 + j) .. ")\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
        end
      end
    else
      error("meb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
end

-- The WHEREFORE paragraph, then "Dated:" at the margin with "/s/" at sig-col, the signer's lines under it; one
-- block that never breaks across a page.
local function closing(m, out)
  local ps = {}
  for _, c in ipairs(paragraphs(m.wherefore)) do ps[#ps + 1] = { xe.inl(c), { line = BODY, first = INDENT } } end
  ps[#ps + 1] = { xe.runs("Dated: ") .. xe.inl(m.date) .. xe.runs("\t/s/ ") .. xe.inl(m.signature.signer),
    { before = BODY, tabs = SIG } }
  for _, l in ipairs(list(m.signature.lines)) do ps[#ps + 1] = { xe.inl(l), { left = SIG } } end
  for i, x in ipairs(ps) do
    x[2].keep = i < #ps
    out[#out + 1] = p(x[1], x[2])
  end
end

-- A doubled sign stays with its number ("§§ 157"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" and #a.text >= 4 and a.text:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Inlines = signs })
  local m = doc.meta
  local out = {}
  cover(m, out)
  for _, c in ipairs(paragraphs(m.lead_in)) do out[#out + 1] = p(xe.inl(c), { line = BODY, first = INDENT }) end
  blocks(doc, out)
  closing(m, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
