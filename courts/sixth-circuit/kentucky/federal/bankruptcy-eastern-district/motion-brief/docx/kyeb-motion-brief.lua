-- E.D. Ky. bankruptcy motion with memorandum, DOCX engine (docs/DOCX.md): markdown + YAML metadata -> Word.
-- Mirrors ../typst/kyeb-motion-brief.typ: the court lines, the caption table (with the judge line and, for an
-- adversary proceeding, the parties), the title between two rules, the notice of hearing under it (LBR 9013-1(a),
-- 9014-1(a)), the body (unnumbered paragraphs first-line indented, numbered paragraphs running on through the
-- motion, headings typed by the author), the signature block (FRBP 9011(a)), NOTICE and the certificate of
-- service with the signature block repeated. No case-specific text: everything comes from the metadata. Font,
-- sizes, the pitch, margins and the page number are styles and section settings in docx/reference.xml (fb render
-- builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 280), the spaces between blocks those of the typst
-- template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local PITCH = 280                           -- typst pitch 14 pt
local GAP, HALF = 240, 120                  -- typst gap 12 pt, half-gap 6 pt
local COURT_BELOW, JUDGE_ABOVE, ROW_GAP = 360, 360, 240 -- typst court-below, judge-above 18 pt, row-gap 12 pt
local CERT_GAP = 60                         -- typst cert-gap 3 pt
local LEFT = 4680                           -- typst caption-left 3.25 in
local RIGHT = 9360 - LEFT
local PAD = 288                             -- typst caption-pad 0.2 in
local DESIGNATION = 2592                    -- typst designation-indent 1.8 in
-- A rule takes room in Word (LibreOffice adds its width, 0.75 pt = 15 twips at w:sz 6, to the cell or paragraph),
-- not in typst's grid strokes: the title's cell keeps that much less above and below its text.
local RULE_W = 15
local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("kyeb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List" and (v[1] == nil or v[1].t ~= "Str")) then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A single-spaced paragraph: o = { before, after, left, jc, keep, border }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.border then props[#props + 1] = '<w:pBdr>' .. string.format(RULE, "bottom") .. '</w:pBdr>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, PITCH)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Space of its own between two tables or after one (typst: a block's space below it), an empty paragraph that
-- tall; only on the first page, where it cannot open a page.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function mar(top, right, bottom, left)
  return '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

-- A table of fixed columns, no borders and no cell margins unless a cell sets its own; rows are not split across
-- pages (typst: one grid row).
local function tbl(widths, rows)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

local function row(cells)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

-- A doubled section sign ("§§ 362") stays with its number, as the typst template binds it; the shared bind_signs
-- (lib/pandoc/xengine.lua) binds a single sign only.
local function bind_double(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- ---------------------------------------------------------------------------
-- Court lines, caption (FRBP 9004(b)), title and notice of hearing
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local court = items(need(m, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", after = i == #court and COURT_BELOW or 0 })
  end

  local cap = need(m, "caption")
  local debtors = cap.debtors
  local lt = { p(xe.runs("In re:")) }
  for i, n in ipairs(items(debtors.names)) do lt[#lt + 1] = p(xe.inl(n), { before = i == 1 and HALF or 0 }) end
  lt[#lt + 1] = p(xe.inl(debtors.designation))

  local rt = { p(xe.runs("Case No. " .. pandoc.utils.stringify(need(m, "case_number")))) }
  if need(m, "jointly_administered") == true then rt[#rt + 1] = p(xe.runs("(Jointly Administered)")) end
  rt[#rt + 1] = p(xe.inl(need(m, "chapter")), { before = HALF })
  if m.judge then rt[#rt + 1] = p(xe.inl(m.judge), { before = JUDGE_ABOVE }) end

  local rows = { row({ cell(LEFT, table.concat(lt), mar(0, PAD, 0, 0)), cell(RIGHT, table.concat(rt), mar(0, 0, 0, PAD)) }) }
  local parties = items(cap.parties)
  if #parties > 0 then
    local lb = {}
    for i, side in ipairs(parties) do
      for _, n in ipairs(items(side.names)) do lb[#lb + 1] = p(xe.inl(n)) end
      lb[#lb + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
      if i < #parties then lb[#lb + 1] = p(xe.runs("v."), { before = HALF, after = HALF }) end
    end
    local adv = pandoc.utils.stringify(m.adversary_number or "")
    local rb = adv ~= "" and p(xe.runs("Adv. No. " .. adv)) or p("")
    rows[#rows + 1] = row({ cell(LEFT, table.concat(lb), mar(ROW_GAP, PAD, 0, 0)),
      cell(RIGHT, rb, mar(ROW_GAP, 0, 0, PAD)) })
  end
  out[#out + 1] = tbl({ LEFT, RIGHT }, rows)
  out[#out + 1] = space(GAP)

  -- The title between two rules: one cell ruled above and below, the title lines run together.
  local title = {}
  for i, l in ipairs(items(need(m, "title"))) do
    if i > 1 then title[#title + 1] = xe.runs(" ", { b = true }) end
    title[#title + 1] = xe.inl(l, { b = true })
  end
  out[#out + 1] = tbl({ 9360 }, { row({ cell(9360, p(table.concat(title), { jc = "center" }),
    '<w:tcBorders>' .. string.format(RULE, "top") .. string.format(RULE, "bottom") .. '</w:tcBorders>'
    .. mar(HALF - RULE_W, 0, HALF - RULE_W, 0)) }) })
  out[#out + 1] = space(GAP)

  local h = m.hearing
  if h then
    local lines = {}
    if h.date then lines[#lines + 1] = xe.runs("Hearing: ") .. xe.inl(h.date) end
    if h.time then lines[#lines + 1] = xe.runs("Time: ") .. xe.inl(h.time) end
    if h.place then lines[#lines + 1] = xe.runs("Place: ") .. xe.inl(h.place) end
    if h.objection_deadline then lines[#lines + 1] = xe.runs("Objections due: ") .. xe.inl(h.objection_deadline) end
    for i, l in ipairs(lines) do out[#out + 1] = p(l, { after = i == #lines and GAP or 0 }) end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (FRBP 9011(a)), NOTICE and certificate of service
-- ---------------------------------------------------------------------------

-- The "/s/" block in the right half, a rule under the signer's name (a paragraph border; typst draws it below the
-- line and gives it its width). `opening` adds "Respectfully Submitted,".
local function signature(m, opening)
  local s = need(m, "signature")
  local right = {}
  if opening then right[#right + 1] = p(xe.runs("Respectfully Submitted,"), { after = GAP }) end
  right[#right + 1] = p(xe.runs("/s/ ") .. xe.inl(s.signer), { border = true })
  if s.firm then right[#right + 1] = p(xe.inl(s.firm)) end
  for _, l in ipairs(items(s.lines)) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ 9360 - LEFT, LEFT }, { row({ cell(9360 - LEFT, p("")), cell(LEFT, table.concat(right)) }) })
end

-- Blocks (the certificate's markdown) as paragraphs: hard line breaks kept as Word line breaks, as typst keeps them.
local function block_paras(blocks, last_after, o)
  local out = {}
  local list = {}
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then list[#list + 1] = b end
  end
  for i, b in ipairs(list) do
    local segs, cur = {}, pandoc.Inlines({})
    for _, x in ipairs(b.content) do
      if x.t == "LineBreak" then
        segs[#segs + 1] = cur
        cur = pandoc.Inlines({})
      else
        cur:insert(x)
      end
    end
    segs[#segs + 1] = cur
    local runs = {}
    for k, sgm in ipairs(segs) do
      if k > 1 then runs[#runs + 1] = xe.BR end
      runs[#runs + 1] = xe.inl(bind_double(sgm))
    end
    out[#out + 1] = p(table.concat(runs), { keep = o.keep, after = i == #list and last_after or CERT_GAP })
  end
  return table.concat(out)
end

-- After the signature block: NOTICE (its heading kept with its text) and the certificate, kept whole with its
-- signature block (typst: one unbreakable block). The first of them stands a gap below the table.
local function closing(m)
  local out = {}
  local before = GAP
  if m.notice then
    out[#out + 1] = p(xe.runs("NOTICE", { b = true }), { jc = "center", keep = true, before = before, after = GAP })
    out[#out + 1] = p(xe.inl(m.notice), { after = GAP })
    before = 0
  end
  local cert = m.certificate_of_service
  if cert then
    out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", keep = true, before = before, after = GAP })
    local text = cert.text
    local ty = pandoc.utils.type(text)
    local blocks = (ty == "Blocks") and text or { pandoc.Para(ty == "Inlines" and text or { pandoc.Str(pandoc.utils.stringify(text)) }) }
    out[#out + 1] = block_paras(blocks, HALF, { keep = true })
    out[#out + 1] = signature(m, false)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("362(d)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows
-- in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A paragraph that anchors a footnote has no widow control (the "Note" styles, docx/reference.xml): typst moves the
-- line with the mark alone when its note does not fit.
local function styled(style, inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  if note then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "court", "caption", "chapter", "case_number", "jointly_administered", "title", "date", "signature" }) do
    local _ = need(m, k)
  end

  local out = { xe.raw(cover(m)) }
  -- The paragraph numbers run on through the whole motion (typst counts them the same way).
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local c = b.content
      if b.level == 1 then
        -- Level 1 in capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
        c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled("Body Text", b.content)
    elseif b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Numbered Para", inl)
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs("\u{2022}\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Bullet Item", inl)
      end
    else
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(m, true) .. closing(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind_double }, { Pandoc = finish } }
