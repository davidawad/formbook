-- Pandoc filter for the wvnd memorandum of law (motion brief), engine docx, so that it reads and breaks as
-- typst/wvnd-motion-brief.typ does: court title, caption (a ")" column; the case number beside its row), the brief
-- title, the body (first-line indent, footnotes), headings numbered I. / A. / 1. (levels 2-4), the signature block
-- (LR Gen P 5.03(c); Fed. R. Civ. P. 11(a)), and the certificate of service on its own page with the caption
-- repeated (LR Gen P 5.06(e)). Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. The body paragraphs (which
-- may carry footnotes) are written by pandoc in the styles of docx/reference.xml; everything else is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local COVER_GAP = 240                    -- typst cover-gap 12 pt
local INDENT = 720                       -- typst para-indent, served-indent, 0.5 in
local SIG = 4680                         -- typst sig-left, 3.25 in
local LEFT, PAREN, TEXTW = 4896, 432, 9360  -- typst caption-left 3.4 in, caption-paren 0.3 in; 6.5 in

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV",
  "XVI", "XVII", "XVIII", "XIX", "XX" }

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function brk(s)
  return (s:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1"))
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab, page }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.page then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Caption: court title, then one exact single-spaced row per caption line, ")" in the middle
-- ---------------------------------------------------------------------------

local function caption(meta, out, page)
  local title = { "UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF WEST VIRGINIA" }
  if meta.division then title[#title + 1] = plain(meta.division) end
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(l), { line = BODY, jc = "center", page = page and i == 1,
      after = i == #title and COVER_GAP or 0 })
  end
  local case_row = tonumber(plain(meta.caption.case_row or 0)) or 0
  local function cell(w, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
  end
  local rows = {}
  for i, item in ipairs(meta.caption.lines) do
    local text, indent = item, 0
    if type(item) == "table" and item.text ~= nil then
      text, indent = item.text, math.floor((tonumber(plain(item.indent)) or 0) * 1440 + 0.5)
    end
    local right = (i - 1 == case_row) and xe.runs(brk("No. " .. plain(meta.case_number))) or ""
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. SINGLE .. '" w:hRule="exact"/></w:trPr>' ..
      cell(LEFT, p(xe.inl(text), { left = indent })) .. cell(PAREN, p(xe.runs(")"))) ..
      cell(TEXTW - LEFT - PAREN, p(right)) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. PAREN .. '"/><w:gridCol w:w="' ..
    (TEXTW - LEFT - PAREN) .. '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- A centered bold title at the body pitch, the cover gap above it (Word has no space after a table, so the title
-- takes it), kept with the text.
local function title(body)
  return p(xe.inl(body, { b = true }), { line = BODY, before = COVER_GAP, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature (LR Gen P 5.03(c); Fed. R. Civ. P. 11(a)) and certificate of service (LR Gen P 5.06(e))
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local has_email, has_phone = false, false
  for _, l in ipairs(sig.lines) do
    local s = plain(l)
    if s:find("@", 1, true) then has_email = true end
    if s:match("%(?%d%d%d%)?[ .-]?%d%d%d[ .-]?%d%d%d%d") then has_phone = true end
  end
  assert(has_email, "wvnd-motion-brief: the signature lines need an e-mail address (Fed. R. Civ. P. 11(a))")
  assert(has_phone, "wvnd-motion-brief: the signature lines need a telephone number (Fed. R. Civ. P. 11(a))")
  local lines = {
    { xe.runs("DATED: " .. plain(meta.date)), BODY, 0, BODY },
    { xe.runs("Respectfully submitted,"), BODY, SIG, BODY },
    { xe.runs("s/ ") .. xe.inl(sig.signer), BODY, SIG, SINGLE },
  }
  for i, l in ipairs(sig.lines) do lines[#lines + 1] = { xe.inl(l), i == 1 and SINGLE or 0, SIG, SINGLE } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], line = l[4], keep = i < #lines })
  end
end

local function certificate(meta, out)
  local c = meta.certificate_of_service
  assert(c and c.served, "wvnd-motion-brief: the certificate needs served (who was served, LR Gen P 5.06(e))")
  caption(meta, out, true)
  out[#out + 1] = title("CERTIFICATE OF SERVICE")
  out[#out + 1] = p(xe.runs(brk("I hereby certify that on " .. plain(c.date) .. ", I electronically filed the " ..
    "foregoing with the Clerk of the District Court using the CM/ECF system, which will send notification of such " ..
    "filing electronically to the following counsel of record, who are served by that means:")),
    { line = BODY, first = INDENT })
  for _, s in ipairs(c.served) do out[#out + 1] = p(xe.inl(s), { before = SINGLE, left = INDENT }) end
  out[#out + 1] = p(xe.runs("s/ ") .. xe.inl(c.signer), { before = BODY, left = SIG, keep = true })
  out[#out + 1] = p(xe.inl(c.role), { before = SINGLE, left = SIG })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function breaks(s)
  return pandoc.Str(brk(s.text))
end

-- A doubled sign stays with its number ("¶¶ 7–8": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A paragraph that anchors a footnote has no widow control ("Body Text Note", docx/reference.xml): typst moves
-- such a paragraph's last line alone when its note does not fit, where Word would carry the line before it too.
local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function raw(xml)
  return xe.raw(xml)
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  assert(meta.case_number, "wvnd-motion-brief: frontmatter needs case_number")
  assert(meta.caption, "wvnd-motion-brief: frontmatter needs caption (lines and case_row)")
  assert(meta.brief_title, "wvnd-motion-brief: frontmatter needs brief_title")
  assert(meta.signature, "wvnd-motion-brief: frontmatter needs signature")
  assert(meta.certificate_of_service, "wvnd-motion-brief: frontmatter needs certificate_of_service")

  local out = {}
  local cover = {}
  caption(meta, cover)
  cover[#cover + 1] = title(meta.brief_title)
  for _, x in ipairs(cover) do out[#out + 1] = raw(x) end

  -- Headings: level 1 centered bold underlined; level 2 "I." in a half-inch box, bold; level 3 "A." half an inch
  -- in, bold; level 4 "1." an inch in, italic; the text hangs after the label (typst body-block, sticky).
  local h2, h3, h4 = 0, 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lvl = b.level
      if lvl == 1 then
        h2, h3, h4 = 0, 0, 0
        out[#out + 1] = raw(p(xe.inl(b.content, { b = true, u = true }), { line = BODY, jc = "center", keep = true,
          outline = 0 }))
      else
        local lab, at, o
        if lvl == 2 then
          h2, h3, h4 = h2 + 1, 0, 0
          lab, at, o = (ROMAN[h2] or tostring(h2)) .. ".", 0, { b = true }
        elseif lvl == 3 then
          h3, h4 = h3 + 1, 0
          lab, at, o = string.char(64 + h3) .. ".", INDENT, { b = true }
        else
          h4 = h4 + 1
          lab, at, o = h4 .. ".", 2 * INDENT, { i = true }
        end
        out[#out + 1] = raw(p(xe.runs(lab .. "\t") .. xe.inl(b.content, o), { line = BODY, left = at + INDENT,
          hanging = INDENT, tab = at + INDENT, keep = true, outline = math.min(lvl, 9) - 1 }))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) },
        { ["custom-style"] = has_note(b.content) and "Body Text Note" or "Body Text" })
    else
      error("wvnd-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  local tail = {}
  signature(meta, tail)
  certificate(meta, tail)
  for _, x in ipairs(tail) do out[#out + 1] = raw(x) end
  -- pandoc would print the metadata title and date above the body; the caption, title and date are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
