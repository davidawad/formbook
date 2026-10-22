-- Pandoc filter for the W.D. Tenn. memorandum in support of a motion (motion-brief), engine docx, so that it reads
-- and breaks as typst/tnwd-motion-brief.typ does: the court title, the caption (one table row per party line, a
-- column of ")" marks, the file number opposite "v."), the title (LR 7.2(a)(1): "so identified"), unnumbered body
-- paragraphs, section headings (centered bold), point headings (the typed label in a half-inch box, the text
-- hanging), quotations, the signature block (LR 11.1(b)) kept with the last paragraph, and the certificate of
-- service (Fed. R. Civ. P. 5(b)) on a page of its own. Every case word comes from the sample's frontmatter and body,
-- never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs, quotations
-- and footnotes are written by pandoc in the styles of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body, pitch-single
local GAP = 276                          -- typst gap: a blank single line
local HEAD_BELOW = 138                   -- typst head-below, 6.9 pt
local INDENT = 720                       -- typst para-indent and point-label, 0.5 in
local SERVED = 720                       -- typst served-indent, 0.5 in
local DESIGNATION = 1800                 -- typst designation-indent, 1.25 in
local SIG = 4680                         -- typst sig-indent, 3.25 in
local BLANK = 2304                       -- typst blank-width, 1.6 in
local LEFT, MARKS, RIGHT = 4752, 576, 144   -- typst caption-left 3.3 in, caption-marks 0.4 in, caption-right 0.1 in
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

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- An underlined tab to `pos`: a blank to write on (typst: a box with a bottom rule).
local function rule_to(pos)
  return '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>', pos
end

-- ---------------------------------------------------------------------------
-- Caption (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

-- The lines a caption line takes in its column (typst measures it), first fit on its words: Times New Roman's
-- advances (1/1000 em, regular) at 12 pt; a character not in the table counts 0.5 em.
local ADV = {
  A = 722, B = 667, C = 667, D = 722, E = 611, F = 556, G = 722, H = 722, I = 333, J = 389, K = 722, L = 611,
  M = 889, N = 722, O = 722, P = 556, Q = 722, R = 667, S = 556, T = 611, U = 722, V = 722, W = 944, X = 722,
  Y = 722, Z = 611, a = 444, b = 500, c = 444, d = 500, e = 444, f = 333, g = 500, h = 500, i = 278, j = 278,
  k = 500, l = 278, m = 778, n = 500, o = 500, p = 500, q = 500, r = 333, s = 389, t = 278, u = 500, v = 500,
  w = 722, x = 500, y = 500, z = 444, [" "] = 250, [","] = 250, ["."] = 250, [";"] = 278, [":"] = 278,
  ["/"] = 278, ["-"] = 333, ["("] = 333, [")"] = 333, ["&"] = 778, ["'"] = 180, ['"'] = 408,
  ["\u{2018}"] = 333, ["\u{2019}"] = 333, ["\u{201C}"] = 444, ["\u{201D}"] = 444, ["\u{2013}"] = 500,
}
local function width(s)
  local w = 0
  for _, c in utf8.codes(s) do
    w = w + (ADV[utf8.char(c)] or 500) * 12 / 1000
  end
  return w
end

-- The line may break after a space and after a hyphen that is not before a digit (Unicode line breaking, as typst
-- breaks); a piece is a word with its hyphen, the space before the next piece counted when the line goes on.
local function caption_rows(text, indent)
  local room = (LEFT - indent) / 20
  local lines, line = 1, nil
  for word in text:gmatch("%S+") do
    local first = true
    for piece in word:gsub("%-(%D)", "-\1%1"):gmatch("[^\1]+") do
      local ww = width(piece)
      local sep = (line and first) and width(" ") or 0
      if line and line + sep + ww > room then
        lines, line = lines + 1, ww
      else
        line = (line or 0) + sep + ww
      end
      first = false
    end
  end
  return lines
end

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function caption(meta, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT"), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE WESTERN DISTRICT OF TENNESSEE"), { jc = "center" })
  if plain(meta.court_division) ~= "" then
    out[#out + 1] = p(xe.inl(meta.court_division), { jc = "center" })
  end
  -- the party lines: { inlines, plain text, left indent, is "v." }; nil inlines is a blank line
  local left = {}
  local sides = list(meta.caption)
  for i, side in ipairs(sides) do
    for _, n in ipairs(list(side.names)) do left[#left + 1] = { xe.inl(n), plain(n), 0, false } end
    left[#left + 1] = { xe.inl(side.designation), plain(side.designation), DESIGNATION, false }
    if i < #sides then
      left[#left + 1] = { nil, "", 0, false }
      left[#left + 1] = { xe.runs("v."), "v.", 0, true }
      left[#left + 1] = { nil, "", 0, false }
    end
  end
  local right = TEXTW - LEFT - MARKS
  local rows = {}
  for _, l in ipairs(left) do
    local text, n = p(""), 1
    if l[1] then
      text = p(l[1], { left = l[3] })
      n = caption_rows(l[2], l[3])
    end
    local marks = {}
    for _ = 1, n do marks[#marks + 1] = p(xe.runs(")"), { jc = "center" }) end
    local r = p("")
    if l[4] then
      local cn = plain(meta.case_number)
      if cn ~= "" then
        r = p(xe.runs("No. " .. cn), { left = RIGHT })
      else
        local run, pos = rule_to(RIGHT + 600 + BLANK)
        r = p(xe.runs("No. ") .. run, { left = RIGHT, tab = pos })
      end
    end
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(LEFT, text) .. tc(MARKS, table.concat(marks)) ..
      tc(right, r) .. '</w:tr>'
  end
  -- typst: the caption a blank double line under the court title
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. MARKS .. '"/><w:gridCol w:w="' .. right ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- LR 7.2(a)(1): the title identifies the memorandum; Word has no space after a table, so the title takes
  -- the space before it
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { before = BODY, after = BODY, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature (LR 11.1(b)) and certificate of service (Fed. R. Civ. P. 5(b))
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = {}
  local dated = plain(meta.date) ~= ""
  if dated then lines[#lines + 1] = { xe.runs("Dated: " .. plain(meta.date)), BODY, 0 } end
  lines[#lines + 1] = { xe.runs("Respectfully submitted,"), dated and GAP or BODY, SIG }
  lines[#lines + 1] = { xe.runs("s/ ") .. xe.inl(sig.signer), GAP, SIG }
  lines[#lines + 1] = { xe.runs("Attorney Bar No. " .. plain(sig.bar_number)), 0, SIG }
  if sig.firm then lines[#lines + 1] = { xe.inl(sig.firm), 0, SIG } end
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  -- kept on one page (typst's unbreakable block): every line but the last keeps with the next
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines })
  end
end

local function certificate(meta, out)
  local cert, sig = meta.certificate, meta.signature
  if not cert then return end
  local lines = {}
  -- on a page of its own (Word keeps the space above a paragraph after a page break: none there)
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { after = GAP, jc = "center", keep = true, brk = true })
  local doc = cert.document or meta.title
  out[#out + 1] = p(xe.runs("The undersigned hereby certifies that a true and correct copy of the foregoing ") ..
    xe.inl(doc) .. xe.runs(" was ") .. xe.inl(cert.method) .. xe.runs(" upon:"),
    { line = BODY, first = INDENT, keep = true })
  for i, l in ipairs(list(cert.served_on)) do lines[#lines + 1] = { xe.inl(l), i == 1 and GAP or 0, SERVED } end
  if cert.date then lines[#lines + 1] = { xe.runs("DATE: ") .. xe.inl(cert.date), GAP, 0 } end
  if sig.firm then lines[#lines + 1] = { xe.inl(sig.firm), GAP, SIG } end
  lines[#lines + 1] = { xe.runs("s/ ") .. xe.inl(sig.signer), GAP, SIG }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). In a web address typst breaks after "//" and after each "/", ".",
-- "-", "_", "?", "=", "&", "#" inside it: a zero-width space there too. None shows in the PDF text.
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

-- A doubled sign stays with its number ("§§ 1331": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- A point heading's typed label ("I.", "A.", "1."), split from its text: label, rest; or nil.
local function label_of(inl)
  local first = inl[1]
  if first and first.t == "Str" and inl[2] and inl[2].t == "Space" and
    (first.text:match("^[IVXLC]+%.$") or first.text:match("^%u%.$") or first.text:match("^%d+%.$")) then
    local rest = pandoc.Inlines({})
    for k = 3, #inl do rest:insert(inl[k]) end
    return first.text, rest
  end
  return nil
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  for _, k in ipairs({ "caption", "title", "signature" }) do
    assert(meta[k], "tnwd-motion-brief: frontmatter needs " .. k)
  end

  local raw = {}
  caption(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end

  for k, b in ipairs(doc.blocks) do
    local last = k == #doc.blocks
    if b.t == "Header" then
      if b.level == 1 then
        -- section heading: single-spaced, centered bold, a blank single line above and half a line below
        out[#out + 1] = xe.raw(xe.para({ xe.KEEP, xe.spacing(GAP, HEAD_BELOW, SINGLE), xe.ind(0, nil, 0),
          xe.jc("center"), '<w:outlineLvl w:val="0"/>' }, xe.inl(b.content, { b = true })))
      else
        -- point heading: the typed label in a half-inch box, the text hanging after it
        local lab, rest = label_of(b.content)
        local body = lab and (xe.runs(lab .. "\t", { b = true }) .. xe.inl(rest, { b = true })) or xe.inl(b.content, { b = true })
        out[#out + 1] = xe.raw(xe.para({ xe.KEEP,
          lab and ('<w:tabs><w:tab w:val="left" w:pos="' .. INDENT .. '"/></w:tabs>') or "",
          xe.spacing(GAP, HEAD_BELOW, SINGLE), lab and xe.ind(INDENT, INDENT) or xe.ind(0, nil, 0), xe.jc("left"),
          '<w:outlineLvl w:val="' .. (math.min(b.level, 3) - 1) .. '"/>' }, body))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = last and "Body Keep" or "Body Text" })
    elseif b.t == "BlockQuote" then
      out[#out + 1] = pandoc.Div(b.content, { ["custom-style"] = "Block Text" })
    else
      error("tnwd-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  local tail = {}
  signature(meta, tail)
  certificate(meta, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  -- pandoc would print the metadata title and date above the body; the caption and title are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
