-- nhb (D.N.H. bankruptcy court) motion or memorandum, DOCX engine (docs/DOCX.md): the court title, the bankruptcy
-- caption, the title, the body (headings, unnumbered paragraphs, quotations, footnotes), the signature block and
-- (when the sample has one) the certificate of service, so that it reads and breaks as typst/nhb-motion-brief.typ
-- does. This file holds no case text: every word comes from the sample (its YAML frontmatter and body).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs and
-- quotations stay pandoc paragraphs (styles "Body Text", "Body Text Note", "Body Last" and "Block Text" in
-- reference.xml), so pandoc writes their footnotes.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276             -- typst pitch-double, pitch-single
local CAP_GAP = 240                       -- typst cap-gap, 12 pt
local HEAD_ABOVE = 120                    -- typst head-above, 6 pt
local INDENT = 720                        -- typst para-indent, 0.5 in
local SIG = 4680                          -- typst sig-indent, 3.25 in
local TEXTW = 9360                        -- 6.5 in
local COL = TEXTW / 2                     -- the caption's two equal columns
local RULE = 'w:val="single" w:sz="4" w:space="0" w:color="000000"'   -- typst rule, 0.5 pt

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A metadata list (or a single value) as an array.
local function list(v)
  if v == nil then return {} end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" or ty == "Blocks" or ty == "string" then return { v } end
  return v
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A section sign or pilcrow stays with its number when it is doubled ("§§ 329") or follows other characters ("“§
-- 105(a)"), as the typst template boxes it (xe.inl binds a sign that stands alone only).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" and (a.text:find("\u{00A7}$") or a.text:find("\u{00B6}$")) then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- ---------------------------------------------------------------------------
-- The bankruptcy caption (Fed. R. Bankr. P. 9004(b); LBR 7102(a)): two equal columns, the left one ruled at its
-- right and foot, its text 10 pt off the rule and 8 pt above the foot (typst inset), the right one 18 pt off the
-- rule; both 2 pt from the top.
-- ---------------------------------------------------------------------------

local function margins(t, l, b, r)
  return '<w:tcMar><w:top w:w="' .. t .. '" w:type="dxa"/><w:left w:w="' .. l .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. b .. '" w:type="dxa"/><w:right w:w="' .. r .. '" w:type="dxa"/></w:tcMar>'
end

local function caption(b)
  local left = p(xe.runs("In re:")) ..
    p(xe.inl(b.debtor, { b = true }), { before = CAP_GAP }) ..
    p(xe.inl(b.designation), { before = CAP_GAP, jc = "right" })
  local right = p(xe.inl(b.chapter)) .. p(xe.runs("Case No. ") .. xe.inl(b.case_number), { before = CAP_GAP })
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. COL .. '"/><w:gridCol w:w="' .. COL .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. COL .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE ..
    '/></w:tcBorders>' .. margins(40, 0, 160, 200) .. '</w:tcPr>' .. left .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. COL .. '" w:type="dxa"/>' .. margins(40, 360, 0, 0) .. '</w:tcPr>' ..
    right .. '</w:tc></w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- A signature block: the date at the margin, the rest at the signature indent; every line kept with the next, so
-- the block never splits (typst: one unbreakable block).
-- ---------------------------------------------------------------------------

local function signature(label, date, intro, signer, lines_, out)
  label = plain(label) ~= "" and plain(label) or "Date:"
  local lines = { { body = xe.runs(label .. " ") .. xe.inl(date), before = CAP_GAP, left = 0 } }
  for i, l in ipairs(list(intro)) do lines[#lines + 1] = { body = xe.inl(l), before = i == 1 and CAP_GAP or 0 } end
  lines[#lines + 1] = { body = xe.inl(signer), before = 2 * CAP_GAP }
  for i, l in ipairs(list(lines_)) do lines[#lines + 1] = { body = xe.inl(l), before = i == 1 and CAP_GAP or 0 } end
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l.body, { before = l.before, left = l.left or SIG, keep = i < #lines }))
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- Headings at the body pitch, kept with the text: level 1 centered bold, 6 pt above; level 2 bold with a hanging
-- half inch; level 3 bold italic.
local function heading(h)
  if h.level == 1 then
    return p(xe.inl(h.content, { b = true }), { before = HEAD_ABOVE, line = BODY, jc = "center", keep = true })
  elseif h.level == 2 then
    return p(xe.inl(h.content, { b = true }), { line = BODY, left = INDENT, hanging = INDENT, keep = true })
  end
  return p(xe.inl(h.content, { b = true, i = true }), { line = BODY, keep = true })
end

-- A body paragraph: pandoc writes it (and its footnotes) in "Body Text"; one that carries a footnote mark in "Body
-- Text Note" (no widow control); the last one in "Body Last" (kept whole and with the signature block).
local function body_par(inlines, last)
  local style = last and "Body Last" or has_note(inlines) and "Body Text Note" or "Body Text"
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local m = doc.meta
  -- the break rules on the body only: the frontmatter goes through xe.inl, which applies them itself
  local blocks = pandoc.Pandoc(doc.blocks):walk({ Inlines = xe.inlines }).blocks
  local out = {}
  -- court title, centered bold, one line per entry; the caption stands 18 pt below
  local court = list(m.court)
  for i, l in ipairs(court) do
    out[#out + 1] = xe.raw(p(xe.inl(l, { b = true }), { jc = "center", keep = true, after = i == #court and 360 or 0 }))
  end
  out[#out + 1] = xe.raw(caption(m.bankruptcy))
  -- the title 18 pt below the caption (Word has no space after a table: the title takes it), 12 pt above the body
  out[#out + 1] = xe.raw(p(xe.inl(m.title, { b = true }), { before = 360, after = 240, jc = "center", keep = true }))
  local last
  for i, b in ipairs(blocks) do
    if b.t == "Para" then last = i end
  end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" then
      out[#out + 1] = body_par(b.content, i == last)
    elseif b.t == "BlockQuote" then
      -- a quotation: single-spaced, half an inch in on both sides, 12 pt off the text ("Block Text")
      out[#out + 1] = b
    else
      error("nhb.lua: unsupported block " .. b.t)
    end
  end
  local s = m.signature
  signature(m.date_label, m.date, s.intro, s.signer, s.lines, out)
  -- certificate of service (LBR 7103): its heading kept with its text, the text at the body pitch, its own signature
  local c = m.certificate
  if c then
    out[#out + 1] = xe.raw(p(xe.inl(c.title, { b = true }), { before = 2 * CAP_GAP, after = HEAD_ABOVE, jc = "center", keep = true }))
    for _, para in ipairs(list(c.paragraphs)) do
      out[#out + 1] = xe.raw(p(xe.inl(para), { line = BODY, first = INDENT }))
    end
    signature(c.date_label, c.date, {}, c.signer, c.lines, out)
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
