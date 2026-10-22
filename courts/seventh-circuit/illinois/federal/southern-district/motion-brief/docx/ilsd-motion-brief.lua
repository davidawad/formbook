-- Pandoc filter for the ilsd motion to dismiss with a brief in support, engine docx, so that it reads and breaks as
-- typst/ilsd-motion-brief.typ does: court name, caption (one table row per party line, a column of ")" marks, the
-- civil action number on the "v." row), title, body with the headings numbered by the filter (I. with the label on
-- a line of its own, A. and 1. with a hanging label; the typed headings carry no numbers), native footnotes, the last
-- paragraph kept with the signature block, and the certificate of service on its own page. Every case word comes
-- from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs, quotations,
-- lists and footnotes are written by pandoc in the styles of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local GAP = 276                          -- typst gap: a blank single line
local H1_ABOVE, H1_BELOW, H2_GAP = 360, 240, 240   -- typst h1-above 18 pt, h1-below 12 pt, h2-gap 12 pt
local TITLE_BELOW = 240                  -- typst title-below 12 pt
local CERT_GAP, RECIPIENT_GAP = 240, 120 -- typst cert-gap 12 pt, recipient-gap 6 pt
local INDENT = 720                       -- typst para-indent and heading-tab, 0.5 in
local DESIGNATION = 2016                 -- typst designation-indent, 1.4 in
local TITLE_INSET = 936                  -- typst title-inset, 10 % of 6.5 in
local SIG = 3960                         -- typst sig-indent, 2.75 in
local RECIPIENT = 1440                   -- typst recipient-indent, 1 in
local LEFT, MARKS, RIGHT = 5040, 576, 360   -- typst caption-left 3.5 in, caption-marks 0.4 in, caption-right 0.25 in
local TEXTW = 9360                       -- 6.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  if m == nil then return {} end
  return m
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tab_at(kind, pos)
  return '<w:tabs><w:tab w:val="' .. kind .. '" w:pos="' .. pos .. '"/></w:tabs>'
end

-- ---------------------------------------------------------------------------
-- Caption (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

-- The lines a caption line takes in its column (typst measures it): its width estimated from Times New Roman's
-- advances at 12 pt (capitals and wide letters 0.72 em, small letters 0.47 em, spaces 0.25 em, the rest 0.4 em).
local function caption_rows(text, indent)
  local w = indent / 20
  for _, c in utf8.codes(text) do
    local ch = utf8.char(c)
    if ch == " " then w = w + 3
    elseif ch:match("^[A-Z]$") or ch == "m" or ch == "w" then w = w + 8.64
    elseif ch:match("^[a-z]$") then w = w + 5.64
    else w = w + 4.8 end
  end
  return math.max(1, math.ceil(w / (LEFT / 20)))
end

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function cover(meta, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT"), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE SOUTHERN DISTRICT OF ILLINOIS"), { jc = "center", after = BODY })
  -- the party lines: { inlines, plain text, left indent, centered, is "v." }; nil inlines is a blank line
  local left = {}
  local sides = list(meta.caption)
  for i, side in ipairs(sides) do
    for _, n in ipairs(list(side.names)) do left[#left + 1] = { xe.inl(n), plain(n), 0, false, false } end
    left[#left + 1] = { nil }
    left[#left + 1] = { xe.inl(side.designation), plain(side.designation), DESIGNATION, false, false }
    if i < #sides then
      left[#left + 1] = { nil }
      left[#left + 1] = { xe.runs("v."), "v.", 0, true, true }
      left[#left + 1] = { nil }
    end
  end
  local v
  for k, l in ipairs(left) do
    if l[5] and not v then v = k end
  end
  local right = TEXTW - LEFT - MARKS
  local rows = {}
  for k, l in ipairs(left) do
    local text, n = p(""), 1
    if l[1] then
      text = p(l[1], { left = l[3], jc = l[4] and "center" or "left" })
      n = caption_rows(l[2], l[3])
    end
    local marks = {}
    for _ = 1, n do marks[#marks + 1] = p(xe.runs(")"), { jc = "center" }) end
    local r = p("")
    if k == v then r = p(xe.runs("Civil Action No. " .. plain(meta.case_number)), { left = RIGHT }) end
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(LEFT, text) .. tc(MARKS, table.concat(marks)) ..
      tc(right, r) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. MARKS .. '"/><w:gridCol w:w="' .. right ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- the title, centered in the middle 80 % of the line; Word has no space after a table, so the title takes the
  -- space before it
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { before = BODY, after = TITLE_BELOW, left = TITLE_INSET,
    right = TITLE_INSET, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = {
    { xe.inl(meta.date_line), GAP, 0 },
    { xe.runs("Respectfully submitted,"), GAP, SIG },
    { xe.runs("By: /s/ ") .. xe.inl(sig.signer), GAP, SIG },
  }
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  if sig.role then lines[#lines + 1] = { xe.inl(sig.role, { b = true }), GAP, SIG } end
  -- kept on one page (typst's unbreakable block): every line but the last keeps with the next
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines })
  end
end

-- The certificate's text, as the typst template words it (typst's smart quotes: pandoc's smart reader).
local CERT = 'I certify that a true and correct copy of the foregoing pleading was electronically filed with the ' ..
  'clerk for the U.S. District Court, Southern District of Illinois, using the electronic case filing system of the ' ..
  'court, and the electronic case filing system sent a "Notice of Electronic Filing" to the following attorneys of ' ..
  'record who have consented in writing to accept this Notice as service of this document by electronic means, as ' ..
  'follows:'

local function certificate(meta, out)
  local svc = meta.service
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { after = CERT_GAP, jc = "center", brk = true,
    keep = true })
  local cert = pandoc.read(CERT, "markdown+smart").blocks[1].content
  out[#out + 1] = p(xe.inl(cert), { after = RECIPIENT_GAP, line = BODY, first = INDENT })
  for _, r in ipairs(list(svc.recipients)) do
    out[#out + 1] = p(xe.inl(r.name), { before = RECIPIENT_GAP, left = RECIPIENT, keep = true })
    out[#out + 1] = p(xe.runs("Email: ") .. xe.inl(r.email), { after = RECIPIENT_GAP, left = RECIPIENT, keep = true })
  end
  out[#out + 1] = p(xe.inl(svc.date) .. xe.runs("\t/s/ ") .. xe.inl(svc.signer),
    { before = CERT_GAP, tabs = tab_at("right", TEXTW) })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

local function heading(b, c, out)
  local lvl = math.min(b.level, 4)
  c[lvl] = c[lvl] + 1
  for k = lvl + 1, 4 do c[k] = 0 end
  local outline = '<w:outlineLvl w:val="' .. (lvl - 1) .. '"/>'
  if lvl == 1 then
    -- the label on a line of its own above the heading text, both centered
    out[#out + 1] = xe.raw(xe.para({ xe.KEEP, xe.spacing(H1_ABOVE, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
      xe.runs(roman(c[1]) .. ".", { b = true })))
    out[#out + 1] = xe.raw(xe.para({ xe.KEEP, xe.spacing(0, H1_BELOW, SINGLE), xe.ind(0, nil, 0), xe.jc("center"),
      outline }, xe.inl(b.content, { b = true })))
  else
    local label = lvl == 2 and (string.char(64 + c[2]) .. ".") or lvl == 3 and (c[3] .. ".") or
      (string.char(96 + c[4]) .. ".")
    local left = lvl >= 3 and 2 * INDENT or INDENT
    out[#out + 1] = xe.raw(xe.para({ xe.KEEP, tab_at("left", left), xe.spacing(H2_GAP, H2_GAP, SINGLE),
      xe.ind(left, INDENT), xe.jc("left"), outline }, xe.runs(label .. "\t", { b = true }) .. xe.inl(b.content, { b = true })))
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 1, 3": a no-break space; typst binds it with a box).
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
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "title", "date_line", "signature", "service" }) do
    assert(meta[k], "ilsd-motion-brief: frontmatter needs " .. k)
  end

  local raw = {}
  cover(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end

  -- the last block, when it is a paragraph, is kept with the signature block (typst: one unbreakable block)
  local c = { 0, 0, 0, 0 }
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      heading(b, c, out)
    elseif b.t == "Para" or b.t == "Plain" then
      local style = i == #doc.blocks and "Body Keep" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("ilsd-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  raw = {}
  signature(meta, raw)
  certificate(meta, raw)
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
