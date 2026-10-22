-- Pandoc filter for the vaed memorandum in support of a motion, engine docx, so that it reads and breaks as
-- typst/vaed-motion-brief.typ does: court title, party-box caption with the case number on the line of the first
-- "v.", the underlined title, headings (level 1 centered capitals; levels 2 and 3 with the label hanging), double-
-- spaced paragraphs with a first-line indent, the last paragraph kept with the signature block, the certificate of
-- service on its own page. Every case word comes from the sample's frontmatter and body, never from this file.
-- Known difference: the 30-page cap of L.R. 7(F)(3) is a typst build assertion; it is not enforced here (README).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body and headings, 276 a single
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run. Every
-- paragraph is written here (the template carries no footnotes, lists or quotations: typst renders each chunk of
-- the body as one paragraph).

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local GAP, SIG_GAP = 480, 276            -- typst gap (24 pt), sig-gap (13.8 pt)
local INDENT, LABEL = 720, 720           -- typst para-indent, label-w (0.5 in)
local SIG = 4680                         -- typst sig-indent, 3.25 in
local DESIGNATION = 2016                 -- typst designation-indent, 1.4 in
local TEXTW = 9360                       -- 6.5 in
local BOX, GUTTER, INSET = 4752, 360, 216 -- typst caption-w 3.3 in, caption-gutter 0.25 in, caption-inset 0.15 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- Inlines in capitals (typst upper).
local function upper(x)
  return pandoc.walk_inline(pandoc.Span(x), {
    Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end,
  }).content
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, o.first or (o.hanging == nil and 0 or nil))
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  local court = meta.court or {}
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", after = i == #court and GAP or 0 })
  end
  -- Caption: a borderless table, the ruled party box, a gutter, and the case number on the line of the first "v."
  -- (the case number's cell has the box's top margin, so that it starts level with the box's first line)
  local left = {}
  local parties = meta.caption.parties
  for i, party in ipairs(parties) do
    for _, l in ipairs(party.lines) do left[#left + 1] = p(xe.inl(l)) end
    if party.designation ~= nil then left[#left + 1] = p(xe.inl(party.designation), { left = DESIGNATION }) end
    if i < #parties then left[#left + 1] = p(xe.runs("v."), { before = SIG_GAP, after = SIG_GAP }) end
  end
  local first = #parties[1].lines + (parties[1].designation ~= nil and 1 or 0)
  local down = first * SINGLE + (#parties > 1 and SIG_GAP or 0)
  local bd = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:left w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  local mar = '<w:tcMar><w:top w:w="' .. INSET .. '" w:type="dxa"/><w:left w:w="' .. INSET .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. INSET .. '" w:type="dxa"/><w:right w:w="' .. INSET .. '" w:type="dxa"/></w:tcMar>'
  local rest = TEXTW - BOX - GUTTER
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. BOX .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="' .. rest ..
    '"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. BOX .. '" w:type="dxa"/><w:tcBorders>' .. bd .. '</w:tcBorders>' .. mar ..
    '</w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. GUTTER .. '" w:type="dxa"/></w:tcPr>' .. p("") .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. rest .. '" w:type="dxa"/><w:tcMar><w:top w:w="' .. INSET ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    p(xe.inl(meta.caption.case_number), { before = down }) .. '</w:tc></w:tr></w:tbl>'
  -- the title: Word has no space after a table, so it takes the gap before it
  out[#out + 1] = p(xe.inl(meta.brief_title, { b = true, u = true }), { before = GAP, after = GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A heading at the body pitch, kept with what follows: level 1 centered capitals; levels 2 and 3 with the label
-- ("I.", "A.") hanging half an inch, level 3 half an inch further in.
local function heading(b)
  if b.level == 1 then
    return p(xe.inl(upper(b.content), { b = true }), { line = BODY, jc = "center", keep = true })
  end
  local c, left = b.content, b.level == 2 and 0 or LABEL
  local first, second = c[1], c[2]
  if first and first.t == "Str" and second and second.t == "Space" and (first.text:match("^[IVX]+%.$") or
      first.text:match("^[A-Z]%.$") or first.text:match("^%d+%.$")) then
    local rest = pandoc.Inlines({})
    for k = 3, #c do rest:insert(c[k]) end
    return p(xe.runs(first.text .. "\t", { b = true }) .. xe.inl(rest, { b = true }),
      { line = BODY, left = left + LABEL, hanging = LABEL, keep = true })
  end
  return p(xe.inl(c, { b = true }), { line = BODY, left = left, keep = true })
end

local function body_par(inlines, keep)
  return p(xe.inl(inlines), { line = BODY, first = INDENT, keep = keep })
end

-- ---------------------------------------------------------------------------
-- Signature (L.R. 7(B)) and certificate of service
-- ---------------------------------------------------------------------------

-- full: the date line, the closing and the party too (the brief's own signature); else the signer's lines alone.
local function signature(sig, full, out)
  local lines = {}
  if full and sig.date ~= nil then lines[#lines + 1] = { xe.runs("Date: ") .. xe.inl(sig.date), GAP, 0 } end
  local before = GAP
  for _, k in ipairs(full and { "closing", "party", "by" } or { "by" }) do
    if sig[k] ~= nil then
      lines[#lines + 1] = { xe.inl(sig[k]), before, SIG }
      before = SIG_GAP
    end
  end
  for i, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { xe.inl(l), i == 1 and before or 0, SIG } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines })
  end
end

local function certificate(meta, out)
  local cert = meta.certificate
  out[#out + 1] = p(xe.inl(upper(cert.title), { b = true }), { line = BODY, jc = "center", keep = true, brk = true })
  out[#out + 1] = p(xe.inl(cert.text), { line = BODY, first = INDENT })
  -- the persons served, an empty entry ending one address: each address after a single-spaced blank line
  local served = {}
  local before = SIG_GAP
  for _, l in ipairs(cert.served or {}) do
    if plain(l) == "" then before = SIG_GAP else served[#served + 1] = { l, before }; before = 0 end
  end
  for i, s in ipairs(served) do
    out[#out + 1] = p(xe.inl(s[1]), { before = s[2], keep = i < #served })
  end
  if meta.signature ~= nil then signature(meta.signature, false, out) end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 3": a no-break space; typst binds it with a box).
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
  local meta = doc.meta
  local raw = {}
  cover(meta, raw)
  -- the body: headings and paragraphs; the last paragraph is kept with the signature block
  local blocks, sig = doc.blocks, meta.signature
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      raw[#raw + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      raw[#raw + 1] = body_par(b.content, sig ~= nil and i == #blocks)
    else
      error("vaed-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  if sig ~= nil then signature(sig, true, raw) end
  if meta.certificate ~= nil then certificate(meta, raw) end
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
