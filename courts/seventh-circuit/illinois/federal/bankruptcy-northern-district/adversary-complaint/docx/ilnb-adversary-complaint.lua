-- ilnb-adversary-complaint.lua (docx engine): the N.D. Ill. bankruptcy adversary complaint as Word paragraphs, so that
-- it reads and breaks as typst/ilnb-adversary-complaint.typ (the reference for the form) does:
--   * the court lines and division, the caption (a table: the parties on the left with a rule on the right and bottom
--     of their column, the chapter, case number, adversary number and judge on the right) and the title
--     (ILNB-CAP-001..003);
--   * the lead paragraph, the headings (level 1 centered bold capitals, level 2 bold, level 3 bold italic; kept with
--     the text) and the numbered paragraphs (ILNB-BODY-001): every body paragraph, one counter, the number in a
--     0.4 in box after the half-inch indent and the text wrapping to the margin; pandoc writes them with their
--     footnotes (Numbered Paragraph);
--   * the WHEREFORE paragraph and its lettered items, the last kept with the signature;
--   * "Dated" and the city at the margin, the signature and counsel in the right-hand column, kept together
--     (ILNB-SIG-001..002).
-- Frontmatter values are printed as given; nothing in this file is case-specific.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body, pitch-single
local GAP, SMALL, BIG = 276, 138, 552    -- typst gap, small-gap, big-gap
local INDENT, NUMBER = 720, 576          -- typst para-indent 0.5 in, number-box 0.4 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_INSET, GUTTER = 216, 432       -- typst caption-inset 0.15 in, caption-gutter 0.3 in
local DESIG = 2016                       -- typst designation-indent, 1.4 in
local SIG = 3888                         -- typst sig-column, 2.7 in

local function need(m, key)
  if m[key] == nil then error("ilnb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return m[key]
end

-- a metadata value (markdown) as inlines
local function meta_inlines(v)
  local t = pandoc.utils.type(v)
  if t == "Inlines" then return v end
  if t == "Blocks" then return pandoc.utils.blocks_to_inlines(v) end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function upper(x)
  if pandoc.utils.type(x) == "Inlines" then
    return x:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(pandoc.utils.stringify(x))
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, tab } (keep: with the next paragraph and its lines
-- together; tab: a left tab stop, twips).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_HEAD = '<w:tbl><w:tblPr><w:tblW w:w="%d" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' ..
  '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>' ..
  '</w:tblPr>'

-- ---------------------------------------------------------------------------
-- Court lines, caption and title (ILNB-CAP-001..003)
-- ---------------------------------------------------------------------------

local function cover(m, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE NORTHERN DISTRICT OF ILLINOIS", { b = true }), { jc = "center", after = GAP })
  out[#out + 1] = p(xe.inl(upper(need(m, "division")), { b = true }), { jc = "center", after = BIG })
  local cap = need(m, "caption")
  -- the party column: "In re:", the debtor, then each adversary party with "v." between them; the last line takes
  -- the space above the bottom rule (typst: the cell's bottom inset)
  local left = { { xe.runs("In re:"), 0, 0, GAP } }
  local function party(pt, before)
    for i, n in ipairs(pt.names) do left[#left + 1] = { xe.inl(n), 0, i == 1 and before or 0, 0 } end
    left[#left + 1] = { xe.inl(pt.designation), DESIG, 0, 0 }
  end
  party(cap.in_re, 0)
  if cap.adversary then
    for k, pt in ipairs(cap.adversary.parties) do
      if k > 1 then left[#left + 1] = { xe.runs("v."), 0, GAP, 0 } end
      party(pt, GAP)
    end
  end
  local lp = {}
  for i, l in ipairs(left) do
    lp[#lp + 1] = p(l[1], { left = l[2], before = l[3], after = i == #left and GAP or l[4] })
  end
  -- the case column: chapter, case number, adversary number, judge, half a line apart
  local rows = {}
  if cap.chapter then rows[#rows + 1] = xe.inl(cap.chapter) end
  rows[#rows + 1] = xe.runs("Case No. ") .. xe.inl(cap.case_number)
  if cap.adversary then rows[#rows + 1] = xe.runs("Adv. Pro. No. ") .. xe.inl(cap.adversary.number) end
  if cap.judge then rows[#rows + 1] = xe.inl(cap.judge) end
  local rp = {}
  for i, r in ipairs(rows) do rp[#rp + 1] = p(r, { after = i < #rows and SMALL or 0 }) end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = string.format(TBL_HEAD, TEXTW) ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. rule .. '/><w:right ' ..
    rule .. '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(lp) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. GUTTER ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(rp) .. '</w:tc></w:tr></w:tbl>'
  -- the title: Word has no space after a table, so it takes the space before it
  out[#out + 1] = p(xe.inl(upper(need(m, "title")), { b = true }), { before = BIG, after = BIG, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings (ILNB-HEAD-001): single-spaced, a single line from the text on either side, kept with the text.
local function heading(el)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(GAP, GAP, SINGLE),
    xe.ind(0, nil, 0), xe.jc(el.level == 1 and "center" or "left") },
    xe.inl(content, { b = true, i = el.level >= 3 })))
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- A body paragraph pandoc writes (with its footnotes): a label and a tab first when it is numbered. Widow control
-- stays on for a paragraph that holds a footnote mark: typst (each paragraph its own par, not a block) keeps its
-- two lines together and moves both on with the note, as Word does.
local function body_par(inlines, label)
  local style = label and "Numbered Paragraph" or "Body Text"
  local content = pandoc.Inlines({})
  if label then content:extend({ pandoc.Str(label), TAB }) end
  content:extend(inlines)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

-- ---------------------------------------------------------------------------
-- Prayer and signature (ILNB-SIG-001..002)
-- ---------------------------------------------------------------------------

local function letter(k) return string.char(96 + k) end

-- The lettered items as numbered paragraphs (raw: no notes in frontmatter); the last kept with the signature.
local function prayer_items(m, out)
  local items = m.prayer_items or {}
  for k, item in ipairs(items) do
    out[#out + 1] = xe.raw(p(xe.runs(letter(k) .. ".\t") .. xe.inl(item),
      { line = BODY, first = INDENT, tab = INDENT + NUMBER, keep = k == #items }))
  end
end

-- "Dated" at the margin with the signature at the column's tab, the city below it, then each counsel group in the
-- column, half a line apart; every line kept with the next (typst: one unbreakable block).
local function signature(m, out)
  local sig = need(m, "signature")
  local lines = {
    { xe.runs("Dated: ") .. xe.inl(sig.date) .. xe.runs("\ts/ ") .. xe.inl(sig.signer), BIG, 0, SIG },
    { xe.inl(sig.city), 0, 0 },
  }
  for k, g in ipairs(sig.counsel or {}) do
    if k > 1 then lines[#lines + 1] = { xe.runs("- and -"), SMALL, SIG } end
    local first = true
    for _, list in ipairs({ g.names or {}, g.lines or {} }) do
      for _, l in ipairs(list) do
        lines[#lines + 1] = { xe.inl(l), first and SMALL or 0, SIG }
        first = false
      end
    end
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l[1], { before = l[2], left = l[3], keep = i < #lines, tab = l[4] }))
  end
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local m = doc.meta
  local head = {}
  cover(m, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end
  if m.intro then out[#out + 1] = body_par(xe.inlines(meta_inlines(m.intro))) end
  -- numbered paragraphs (ILNB-BODY-001): every body paragraph is numbered; headings and lists are not
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(b.content, n .. ".")
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("ilnb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  if m.prayer then
    out[#out + 1] = body_par(xe.inlines(meta_inlines(m.prayer)))
    prayer_items(m, out)
  end
  signature(m, out)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
