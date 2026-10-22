-- tnmb-motion-brief.lua (docx engine): the M.D. Tenn. bankruptcy memorandum of law as Word paragraphs, so that it
-- reads and breaks as ../typst/tnmb-motion-brief.typ (the reference for the form) does:
--   * the court title, the caption (LBR 9004-2: a table, one single line per row, the debtor and the parties on the
--     left, a ")" column, the case number, chapter, judge and adversary number on the right) and the title, written
--     here;
--   * the body: headings (level 1 centered bold, level 2 and deeper the typed label in a half-inch box at the indent,
--     the text hanging, bold; they may carry a footnote), paragraphs (not numbered), block quotations, lists and
--     footnotes written by pandoc in the styles of docx/reference.xml; a paragraph right after a quotation at the
--     margin; the last paragraph kept with the signature;
--   * "Respectfully submitted," and the signature lines, kept together, and the certificate of service (LBR 9013-3),
--     kept together.
-- Every case word comes from the YAML frontmatter or the body. No coordinates, no forced line breaks.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 276, 240  -- typst pitch-body, pitch-single, gap (half a body line)
local TEXTW = 9360                       -- 6.5 in
local INDENT = 720                       -- typst para-indent, designation-indent, recipient-indent 0.5 in
local CAP_LEFT, CAP_MID = 5328, 432      -- typst caption-left 3.7 in, caption-mid 0.3 in
local SIG = 3600                         -- typst sig-indent 2.5 in
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(v)
  local out = {}
  for _, x in ipairs(v or {}) do out[#out + 1] = x end
  return out
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep } (keep: with the next paragraph and its
-- lines together). Single-spaced unless o.line.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title (LBR 9004-2(a)(1), (b))
-- ---------------------------------------------------------------------------

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function cover(m, out)
  local court = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE MIDDLE DISTRICT OF TENNESSEE" }
  if plain(m.division) ~= "" then court[#court + 1] = pandoc.text.upper(plain(m.division)) end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  -- the rows: { inlines, indent } or false for a blank row
  local c = m.caption
  local left = { { xe.runs("IN RE:"), 0 }, false }
  for _, d in ipairs(list(c.debtor)) do left[#left + 1] = { xe.inl(d), 0 } end
  left[#left + 1] = { xe.runs("Debtor."), INDENT }
  left[#left + 1] = false
  for k, side in ipairs(list(c.parties)) do
    if k > 1 then
      left[#left + 1] = { xe.runs("v."), 0 }
      left[#left + 1] = false
    end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = { xe.inl(n), 0 } end
    left[#left + 1] = { xe.inl(side.designation), INDENT }
    left[#left + 1] = false
  end
  local adv = plain(m.adv_proc_no)
  if adv == "" then adv = string.rep("_", 8) end
  local right = {
    xe.runs("Case No. " .. plain(m.case_number)),
    xe.runs("Chapter " .. plain(m.chapter)),
    xe.runs("Judge " .. plain(m.judge)),
    false,
    xe.runs("Adv. Proc. No. " .. adv),
  }
  local rw = TEXTW - CAP_LEFT - CAP_MID
  local rows = {}
  for i = 1, math.max(#left, #right) do
    local l, r = left[i], right[i]
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      tc(CAP_LEFT, l and p(l[1], { left = l[2] }) or p("")) .. tc(CAP_MID, p(xe.runs(")"))) ..
      tc(rw, r and p(r) or p("")) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_MID .. '"/><w:gridCol w:w="' .. rw ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- the title, bold; Word has no space after a table, so the first line takes the space before it
  local title = list(m.title)
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }),
      { jc = "center", before = i == 1 and BODY or 0, after = i == #title and BODY or 0 })
  end
end

-- ---------------------------------------------------------------------------
-- Signature and certificate of service (LBR 9013-3)
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local lines = { { xe.runs("Respectfully submitted,"), SINGLE } }
  for i, l in ipairs(list(m.signature)) do lines[#lines + 1] = { xe.inl(l), i == 1 and SINGLE or 0 } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = i < #lines })
  end
end

local function certificate(m, out)
  local cert = m.certificate
  if not cert then return end
  local paras = {
    p(xe.runs("CERTIFICATE OF SERVICE", { b = true, u = true }), { jc = "center", before = BODY, after = GAP }),
    p(xe.inl(cert.text), { first = INDENT }),
  }
  for _, addressee in ipairs(list(cert.recipients)) do
    for j, l in ipairs(list(addressee)) do
      paras[#paras + 1] = p(xe.inl(l), { before = j == 1 and GAP or 0, left = INDENT })
    end
  end
  -- kept together (typst: unbreakable)
  for i, x in ipairs(paras) do
    if i < #paras then x = x:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1) end
    out[#out + 1] = x
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

-- A heading's typed label ("A.", "1.", "IV.": its first word) and the rest of its inlines.
local function split_label(inl)
  local a, b = inl[1], inl[2]
  if a and a.t == "Str" and b and b.t == "Space" and
    (a.text:match("^[IVXLC]+%.$") or a.text:match("^%a%.$") or a.text:match("^%d+%.$")) then
    return a.text, pandoc.Inlines({ table.unpack(inl, 3) })
  end
  return "", inl
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 541(a)(1)": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function div(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local m = doc.meta
  local head = {}
  cover(m, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end

  local blocks = doc.blocks
  local last = #blocks
  local after_quote = false
  for i, b in ipairs(blocks) do
    local quote = false
    if b.t == "Header" then
      if b.level == 1 then
        out[#out + 1] = div("Head 1", b.content)
      else
        local lab, rest = split_label(b.content)
        local inl = pandoc.Inlines({ pandoc.Str(lab), TAB })
        inl:extend(rest)
        out[#out + 1] = div("Head 2", inl)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local style = after_quote and "Body Flush" or "Body Text"
      if i == last then
        style = after_quote and "Body Flush Keep" or "Body Keep"
      elseif has_note(b.content) then
        style = after_quote and "Body Flush Note" or "Body Text Note"
      end
      out[#out + 1] = div(style, b.content)
    elseif b.t == "BlockQuote" then
      quote = true
      out[#out + 1] = b
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("tnmb-motion-brief.lua: unsupported block " .. b.t)
    end
    after_quote = quote
  end

  local tail = {}
  signature(m, tail)
  certificate(m, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
