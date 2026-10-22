-- Pandoc filter for the tnmd memorandum of law, engine docx, so that it reads and breaks as typst/tnmd-motion-brief.typ
-- does: court name and division, caption (one table row per party line, a column of ")" marks, on the right line by
-- line from the "v." row down "Case No.", a blank line, "JURY DEMAND" (LR 7.03(c)), a blank line and the judges (LR
-- 7.03(a))), the title, headings with their typed labels, body paragraphs and native footnotes, the last paragraph
-- kept with the signature block ("<!-- signature -->"), the certificate of service on its own page with its service
-- entries ("<!-- service -->"). Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs, lists and
-- footnotes are written by pandoc in the styles of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local GAP = 276                          -- typst gap: a blank single line
local HEAD_ABOVE, HEAD_BELOW = 276, 138  -- typst head-above 13.8 pt, head-below 6.9 pt
local SIG_GAP = 138                      -- typst sig-gap 6.9 pt
local INDENT = 720                       -- typst para-indent and heading-tab, 0.5 in
local DESIGNATION = 720                  -- typst designation-indent, 0.5 in
local SIG = 4680                         -- typst signature-indent, 3.25 in
local SERVICE = 720                      -- typst service-indent, 0.5 in
local LEFT, MARKS = 4752, 432            -- typst caption-left 3.3 in, caption-marks 0.3 in
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
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 26": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A metadata value with the same break rules as the body.
local function meta_inl(m)
  if type(m) == "string" then return m end
  return pandoc.Inlines(m):walk({ Str = breaks }):walk({ Inlines = bind_doubled })
end

-- ---------------------------------------------------------------------------
-- Caption (Fed. R. Civ. P. 10(a); LR 7.03(a), (c))
-- ---------------------------------------------------------------------------

-- Times New Roman's advances (1/1000 em) of the characters a caption line holds; any other character 500.
local ADV = {
  [" "] = 250, ["!"] = 333, ["\""] = 408, ["#"] = 500, ["$"] = 500, ["%"] = 833, ["&"] = 778, ["'"] = 180,
  ["("] = 333, [")"] = 333, ["*"] = 500, ["+"] = 564, [","] = 250, ["-"] = 333, ["."] = 250, ["/"] = 278,
  [":"] = 278, [";"] = 278, ["?"] = 444, ["@"] = 921,
  A = 722, B = 667, C = 667, D = 722, E = 611, F = 556, G = 722, H = 722, I = 333, J = 389, K = 722, L = 611,
  M = 889, N = 722, O = 722, P = 556, Q = 722, R = 667, S = 556, T = 611, U = 722, V = 722, W = 944, X = 722,
  Y = 722, Z = 611, a = 444, b = 500, c = 444, d = 500, e = 444, f = 333, g = 500, h = 500, i = 278, j = 278,
  k = 500, l = 278, m = 778, n = 500, o = 500, p = 500, q = 500, r = 333, s = 389, t = 278, u = 500, v = 500,
  w = 722, x = 500, y = 500, z = 444, ["\u{2019}"] = 333, ["\u{2018}"] = 333, ["\u{201C}"] = 444,
  ["\u{201D}"] = 444, ["\u{2013}"] = 500, ["\u{2014}"] = 1000, ["\u{00A7}"] = 500, ["\u{00B6}"] = 453,
}

local function width(s)
  local w = 0
  for _, c in utf8.codes(s) do w = w + (ADV[utf8.char(c)] or 500) end
  return w * 12 / 1000
end

-- The lines a caption line takes in its column (typst measures it): first fit over its words, at 12 pt.
local function caption_rows(text, indent)
  local col = (LEFT - indent) / 20
  local n, line = 1, nil
  for word in text:gmatch("%S+") do
    local try = line and (line .. " " .. word) or word
    if line and width(try) > col then
      n, line = n + 1, word
    else
      line = try
    end
  end
  return n
end

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function caption(meta, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT"), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE MIDDLE DISTRICT OF TENNESSEE"), { jc = "center" })
  out[#out + 1] = p(xe.inl(meta_inl(meta.division)), { jc = "center", after = BODY })
  -- the party lines: { runs, plain text, left indent, is "v." }; { nil } is a blank line
  local left = {}
  local parties = list(meta.caption.parties)
  for i, side in ipairs(parties) do
    if i > 1 then
      left[#left + 1] = { nil }
      left[#left + 1] = { xe.runs("v."), "v.", 0, true }
      left[#left + 1] = { nil }
    end
    left[#left + 1] = { xe.inl(meta_inl(side.names)), plain(side.names), 0, false }
    left[#left + 1] = { nil }
    left[#left + 1] = { xe.inl(meta_inl(side.designation), { i = true }), plain(side.designation), DESIGNATION, false }
  end
  local v = 1
  for k, l in ipairs(left) do
    if l[4] then v = k; break end
  end
  -- the right column, line by line from the "v." row down; false is a blank line
  local case_no = plain(meta.case_number)
  if case_no == "" then case_no = string.rep("_", 16) end
  local right = { xe.runs("Case No. " .. case_no) }
  if meta.jury_demand == true then
    right[#right + 1] = false
    right[#right + 1] = xe.runs("JURY DEMAND")
  end
  if meta.judges and #meta.judges > 0 then
    right[#right + 1] = false
    for _, j in ipairs(meta.judges) do right[#right + 1] = xe.inl(meta_inl(j)) end
  end
  local lines, total = {}, 0
  for k, l in ipairs(left) do
    lines[k] = l[1] and caption_rows(l[2], l[3]) or 1
    if k >= v then total = total + lines[k] end
  end
  while total < #right do
    left[#left + 1] = { nil }
    lines[#left] = 1
    total = total + 1
  end
  local rw = TEXTW - LEFT - MARKS
  local rows = {}
  local at = 1
  for k, l in ipairs(left) do
    local n = lines[k]
    local text = l[1] and p(l[1], { left = l[3] }) or p("")
    local marks, r = {}, {}
    for _ = 1, n do marks[#marks + 1] = p(xe.runs(")")) end
    if k >= v then
      for j = at, at + n - 1 do r[#r + 1] = right[j] and p(right[j]) or p("") end
      at = at + n
    else
      r[1] = p("")
    end
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(LEFT, text) .. tc(MARKS, table.concat(marks)) ..
      tc(rw, table.concat(r)) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. MARKS .. '"/><w:gridCol w:w="' .. rw ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- the title; Word has no space after a table, so the title takes the space before it
  out[#out + 1] = p(xe.inl(meta_inl(meta.title), { b = true }), { before = BODY, after = GAP, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Headings, signature, certificate of service
-- ---------------------------------------------------------------------------

-- Level 1 centered bold; level 2 the typed label at the margin in a half-inch box, the text bold and underlined,
-- hanging; level 3 the same half an inch in, bold italic. Single-spaced, kept with what follows.
local function heading(b, out, brk)
  local before = brk and 0 or HEAD_ABOVE
  local lvl = b.level
  if lvl == 1 then
    out[#out + 1] = xe.raw(p(xe.inl(b.content, { b = true }), { before = before, after = HEAD_BELOW, jc = "center",
      keep = true, brk = brk, outline = 0 }))
    return
  end
  -- no word joiner in ")(" here: LibreOffice sets it apart in bold underlined text, so the PDF text reads "12(b) (6)"
  local inl = b.content:walk({ Str = function(s) return pandoc.Str((s.text:gsub("\u{2060}", ""))) end })
  local label = ""
  if inl[1] and inl[1].t == "Str" and inl[1].text:match("^%S+%.$") and inl[2] and inl[2].t == "Space" then
    label = inl[1].text
    local rest = pandoc.Inlines({})
    for k = 3, #inl do rest:insert(inl[k]) end
    inl = rest
  end
  local o = lvl == 2 and { b = true, u = true } or { b = true, i = true }
  local left = lvl >= 3 and 2 * INDENT or INDENT
  out[#out + 1] = xe.raw(p(xe.runs(label, o) .. xe.runs("\t") .. xe.inl(inl, o), { before = before,
    after = HEAD_BELOW, left = left, hanging = INDENT, tab = left, keep = true, brk = brk,
    outline = math.min(lvl, 3) - 1 }))
end

-- "Respectfully submitted," (a signature; a certificate's signer has none), a blank line, the signer, half a line,
-- the typed name and counsel lines, at the middle of the page; kept on one page.
local function signature(sig, opening, out)
  local lines = {}
  if opening then lines[#lines + 1] = { xe.runs("Respectfully submitted,"), GAP } end
  lines[#lines + 1] = { xe.inl(meta_inl(sig.signer)), GAP }
  for i, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { xe.inl(meta_inl(l)), i == 1 and SIG_GAP or 0 } end
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l[1], { before = l[2], left = SIG, keep = i < #lines }))
  end
end

-- The service entries, single-spaced, a blank line apart, each kept whole; then the certificate's signer.
local function service(cert, out)
  for _, entry in ipairs(list(cert.service)) do
    for i, l in ipairs(entry) do
      out[#out + 1] = xe.raw(p(xe.inl(meta_inl(l)), { before = i == 1 and GAP or 0, left = SERVICE, keep = i < #entry }))
    end
  end
  signature(cert, false, out)
end

local function marker(b)
  if b.t ~= "RawBlock" then return nil end
  return b.text:match("^<!%-%-%s*(%a+)%s*%-%->$")
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  for _, k in ipairs({ "title", "division", "caption", "signature" }) do
    assert(meta[k], "tnmd-motion-brief: frontmatter needs " .. k)
  end

  local raw = {}
  caption(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end

  local after_sig = false
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local m = marker(b)
    if m == "signature" then
      signature(meta.signature, true, out)
      after_sig = true
    elseif m == "service" then
      service(meta.certificate, out)
    elseif b.t == "Header" then
      -- a heading after the signature (the certificate of service) opens a new page
      heading(b, out, after_sig)
      after_sig = false
    elseif b.t == "Para" or b.t == "Plain" then
      -- the paragraph before the signature is kept with it (typst: one unbreakable block)
      local style = marker(blocks[i + 1] or pandoc.Null()) == "signature" and "Body Keep" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("tnmd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  -- pandoc would print the metadata title above the body; the caption and title are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
