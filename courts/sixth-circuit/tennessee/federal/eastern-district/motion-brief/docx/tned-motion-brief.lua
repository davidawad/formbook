-- Pandoc filter for the E.D. Tenn. memorandum of law (motion brief), engine docx, so that it reads and breaks as
-- typst/tned-motion-brief.typ does: court title (with the division when the filing names one), caption (the parties
-- left in a column closed by rules on the right and below, the case number right; Fed. R. Civ. P. 10(a)), the title
-- of the paper, the body (headings with their typed labels, block quotations, native footnotes), the last paragraph
-- kept with the signature block (LR 5.1: name, BPR number, address), and the certificate of service on its own page.
-- Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs, quotations,
-- lists and footnotes are written by pandoc in the styles of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body (LR 5.1 double spacing), pitch-single
local GAP = 276                          -- typst gap: a blank single line
local TITLE_ABOVE, TITLE_BELOW = 480, 240   -- typst title-above 24 pt, title-below 12 pt
local HEAD_GAP = 240                     -- typst head-gap 12 pt
local CERT_GAP = 240                     -- typst cert-gap 12 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LEFT, INSET, RIGHT_GAP = 4608, 200, 360   -- typst caption-left 3.2 in, caption-inset 10 pt, caption-gap 0.25 in
local DESIGNATION, VERSUS = 1440, 720    -- typst designation-indent 1 in, versus-indent 0.5 in
local SIG = 4680                         -- typst sig-indent, 3.25 in
local RECIPIENT = 1440                   -- typst recipient-indent, 1 in
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

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, brk, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). In a web address typst also breaks after "//" and after each "/",
-- ".", "-", "_", "?", "=", "&", "#" inside it: a zero-width space there too. None shows in the PDF text.
local function url_breaks(u)
  local head, rest = u:match("^(%a+://)(.*)$")
  rest = rest:gsub("([/%.%-_%?=&#])(.)", "%1\u{200B}%2")
  return head .. "\u{200B}" .. rest
end

local function breaks(s)
  local t = s.text
  local a, b = t:find("%a+://%S*")
  if a then
    return pandoc.Str(t:sub(1, a - 1) .. url_breaks(t:sub(a, b)) .. t:sub(b + 1))
  end
  return pandoc.Str((t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 14, 15": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- Metadata inlines with the body's break rules.
local function meta_inl(m, o)
  if m == nil then return "" end
  if type(m) == "string" then return xe.runs(m, o) end
  local l = pandoc.Inlines(m):walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  return xe.inl(l, o)
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Court title, caption (Fed. R. Civ. P. 10(a)) and title
-- ---------------------------------------------------------------------------

local function tc(w, props, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. props .. '</w:tcPr>' .. body .. '</w:tc>'
end

local function cover(meta, out)
  local court = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF TENNESSEE" }
  if meta.division then court[#court + 1] = pandoc.text.upper(plain(meta.division)) end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  -- the parties: names, a blank line, the designation; "v." a blank line from each side
  local left = {}
  for k, side in ipairs(list(meta.caption.parties)) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { before = GAP, left = VERSUS }) end
    for j, n in ipairs(list(side.names)) do
      left[#left + 1] = p(meta_inl(n), { before = (k > 1 and j == 1) and GAP or 0 })
    end
    left[#left + 1] = p(meta_inl(side.designation), { before = GAP, left = DESIGNATION })
  end
  local right = p(xe.runs("No. " .. plain(meta.case_number)))
  local borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local lmar = '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="' .. INSET ..
    '" w:type="dxa"/><w:right w:w="' .. INSET .. '" w:type="dxa"/></w:tcMar>'
  local rmar = '<w:tcMar><w:left w:w="' .. RIGHT_GAP .. '" w:type="dxa"/></w:tcMar>'
  local rw = TEXTW - LEFT
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(LEFT, borders .. lmar, table.concat(left)) ..
    tc(rw, rmar, right) .. '</w:tr></w:tbl>'
  -- the title of the paper, centered bold capitals; Word has no space after a table, so the title takes it before
  out[#out + 1] = p(meta_inl(upper(meta.title), { b = true }), { before = TITLE_ABOVE, after = TITLE_BELOW,
    jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 5.1; Fed. R. Civ. P. 11(a)) and certificate of service (Fed. R. Civ. P. 5(b))
-- ---------------------------------------------------------------------------

local function keep_together(lines, out, first_before)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = (i == 1 and first_before) or l[2], left = l[3], keep = i < #lines })
  end
end

local function signature(meta, out)
  local sig = meta.signature
  local lines = { { xe.runs("Respectfully submitted,"), 0, SIG } }
  for i, f in ipairs(list(sig.firm)) do lines[#lines + 1] = { meta_inl(f), i == 1 and GAP or 0, SIG } end
  lines[#lines + 1] = { xe.runs("By: /s/ ") .. meta_inl(sig.by), GAP, SIG }
  for _, a in ipairs(list(sig.attorneys)) do
    local head = plain(a.name)
    if a.bpr then head = head .. ", " .. plain(a.bpr) end
    lines[#lines + 1] = { xe.runs(head), GAP, SIG }
    for _, l in ipairs(list(a.lines)) do lines[#lines + 1] = { meta_inl(l), 0, SIG } end
  end
  if sig.role then lines[#lines + 1] = { meta_inl(sig.role, { i = true }), GAP, SIG } end
  keep_together(lines, out, BODY)
end

local function certificate(c, out)
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true, u = true }), { after = CERT_GAP, jc = "center",
    brk = true, keep = true })
  out[#out + 1] = p(meta_inl(c.text), { line = BODY, first = INDENT })
  local lines = {}
  for i, r in ipairs(list(c.recipients)) do
    for j, l in ipairs(list(r)) do lines[#lines + 1] = { meta_inl(l), (i > 1 and j == 1) and GAP or 0, RECIPIENT } end
  end
  lines[#lines + 1] = { xe.runs("By: /s/ ") .. meta_inl(c.by), GAP, SIG }
  lines[#lines + 1] = { meta_inl(c.by), 0, SIG }
  keep_together(lines, out, CERT_GAP)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings, single-spaced, bold, kept with what follows, 12 pt above and below: level 1 centered capitals; deeper
-- levels the typed label in a half-inch box, the text hanging after it (level 2 at the margin, 3 half an inch in,
-- 4 an inch in and italic).
local function heading(b, out)
  local lvl = math.min(b.level, 4)
  if lvl == 1 then
    out[#out + 1] = xe.raw(p(xe.inl(upper(b.content), { b = true }), { before = HEAD_GAP, after = HEAD_GAP,
      jc = "center", keep = true, outline = 0 }))
    return
  end
  local inl = pandoc.Inlines(b.content)
  local lab = ""
  local first = inl[1]
  if first and first.t == "Str" and inl[2] and inl[2].t == "Space" and
    (first.text:match("^%(?[%w]+[%.%)]$") and #first.text <= 6) then
    lab = first.text
    inl = pandoc.Inlines({ table.unpack(inl, 3) })
  end
  local left = (lvl - 1) * INDENT
  local o = { b = true, i = lvl == 4 or nil }
  out[#out + 1] = xe.raw(p(xe.runs(lab .. "\t", o) .. xe.inl(inl, o), { before = HEAD_GAP, after = HEAD_GAP,
    left = left, hanging = INDENT, tab = left, keep = true, outline = lvl - 1 }))
end

local function has_note(inlines)
  local found = false
  pandoc.Inlines(inlines):walk({ Note = function() found = true end })
  return found
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "title", "signature" }) do
    assert(meta[k], "tned-motion-brief: frontmatter needs " .. k)
  end

  local raw = {}
  cover(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end

  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      heading(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      local style = i == #doc.blocks and "Body Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("tned-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  raw = {}
  signature(meta, raw)
  if meta.certificate_of_service then certificate(meta.certificate_of_service, raw) end
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  -- pandoc would print the metadata title above the body; the caption and title are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
