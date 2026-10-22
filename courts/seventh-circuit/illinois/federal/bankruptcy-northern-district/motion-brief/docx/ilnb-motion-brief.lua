-- ilnb-motion-brief.lua (docx engine): the N.D. Ill. bankruptcy memorandum of law as Word paragraphs, so that it
-- reads and breaks as typst/ilnb-motion-brief.typ (the reference for the form) does:
--   * the court lines and division, the caption (a table: the parties on the left with a rule on the right and bottom
--     of their column, the chapter, case number, adversary number and judge on the right) and the title
--     (ILNB-CAP-001..003);
--   * the body: paragraphs in Body Text (pandoc writes them, with their footnotes), the headings with their labels
--     (ILNB-HEAD-001: "I.", "A.", "1.", "a." in a half-inch box at the level's indent, the text hanging after it,
--     bold, kept with the text), block quotations single-spaced and indented on both sides;
--   * "Dated" at the margin and "Respectfully submitted," in the signature column, the party and the signature in
--     the column, counsel at the margin, kept together (ILNB-SIG-001..002).
-- Frontmatter values are printed as given; nothing in this file is case-specific.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                       -- typst pitch-single
local GAP, SMALL, BIG = 276, 138, 552    -- typst gap, small-gap, big-gap
local TAB_W = 720                        -- typst heading-tab, 0.5 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_INSET, GUTTER = 216, 432       -- typst caption-inset 0.15 in, caption-gutter 0.3 in
local DESIG = 2016                       -- typst designation-indent, 1.4 in
local SIG = 3888                         -- typst sig-column, 2.7 in

local function need(m, key)
  if m[key] == nil then error("ilnb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return m[key]
end

local function upper(x)
  if pandoc.utils.type(x) == "Inlines" then
    return x:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(pandoc.utils.stringify(x))
end

-- A paragraph: o = { before, after, line, left, hanging, right, jc, keep, tab, outline } (keep: with the next paragraph
-- and its lines together; tab: a left tab stop, twips).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and 0 or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
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
  -- the party column: "In re:", the debtor, then any adversary parties with "v." between them; the last line takes
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

-- Heading labels as the typst template draws them: level 1 "I.", level 2 "A.", level 3 "1.", level 4 "a.".
local function roman(k)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while k >= v[1] do s, k = s .. v[2], k - v[1] end
  end
  return s
end

local function label(level, k)
  if level == 1 then return roman(k) .. "."
  elseif level == 2 then return string.char(64 + k) .. "."
  elseif level == 3 then return tostring(k) .. "."
  elseif level == 4 then return string.char(96 + k) .. "."
  end
  return ""
end

-- Headings (ILNB-HEAD-001): bold, single-spaced, a single line from the text on either side, kept with the text; the
-- label at the level's indent, a tab to the half-inch box's end, the text hanging there; an outline level, not the
-- Heading style (whose capitals typst does not set).
local function heading(el, lab)
  local left = (math.min(el.level, 4)) * TAB_W
  return xe.raw(p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(el.content, { b = true }),
    { outline = math.min(el.level, 9) - 1, keep = true, before = GAP, after = GAP, left = left,
      hanging = TAB_W, tab = left }))
end

-- Block quotations: single-spaced, indented on both sides, half a line between their paragraphs.
local function quotation(b, out)
  for i, q in ipairs(b.content) do
    if q.t ~= "Para" and q.t ~= "Plain" then error("ilnb-motion-brief.lua: unsupported block in a quotation " .. q.t) end
    out[#out + 1] = xe.raw(p(xe.inl(q.content), { before = i == 1 and GAP or SMALL,
      after = i == #b.content and GAP or 0, left = QUOTE, right = QUOTE }))
  end
end

-- ---------------------------------------------------------------------------
-- Signature (ILNB-SIG-001..002)
-- ---------------------------------------------------------------------------

-- "Dated" at the margin with "Respectfully submitted," at the column's tab; the party, the signature and the role
-- in the column; counsel at the margin; every line kept with the next (typst: one unbreakable block).
local function signature(m, out)
  local sig = need(m, "signature")
  local lines = {
    { xe.runs("Dated: ") .. xe.inl(sig.date) .. xe.runs("\tRespectfully submitted,"), BIG, 0, SIG },
    { xe.inl(sig.party), GAP, SIG },
    { xe.runs("/s/ ") .. xe.inl(sig.signer), GAP, SIG },
    { xe.inl(sig.role), 0, SIG },
  }
  for k, g in ipairs(sig.counsel or {}) do
    if k > 1 then lines[#lines + 1] = { xe.runs("- and -"), GAP, 0 } end
    local first = true
    for _, list in ipairs({ g.names or {}, g.lines or {} }) do
      for _, l in ipairs(list) do
        lines[#lines + 1] = { xe.inl(l), first and GAP or 0, 0 }
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

-- A doubled sign stays with its number ("§§ 707": a no-break space; typst binds it with a box).
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
  local counts = { 0, 0, 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lv = math.min(b.level, 6)
      for l = lv + 1, 6 do counts[l] = 0 end
      counts[lv] = counts[lv] + 1
      out[#out + 1] = heading(b, label(lv, counts[lv]))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Body Text" })
    elseif b.t == "BlockQuote" then
      quotation(b, out)
    else
      error("ilnb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  signature(m, out)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
