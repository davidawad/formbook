-- Bankr. N.D. Ga. adversary complaint, docx engine: the markdown contract (../README.md) as Word paragraphs, so that
-- it reads and breaks as typst/ganb-adversary-complaint.typ does: the first page (court title, caption, rule, title,
-- lead-in), the numbered allegations, the lettered prayer, the signature block and the certificate. Paragraph
-- numbers and prayer letters are typed into the text (as the typst template does), not Word list numbering. Every
-- word printed comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 414 the one-and-a-half-spaced body, 276 a single line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local LETTERS = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t" }
local BODY, SINGLE = 414, 276           -- typst pitch-body, pitch-single
local INDENT, NUM = 720, 576            -- typst para-indent 0.5 in, num-box 0.4 in
local TEXTW = 9360                      -- 6.5 in
local CAPTION_WIDTHS = { 4896, 432, 4032 } -- typst caption-left 3.4 in, caption-paren 0.3 in, the rest
local LINE_GAP, PAR_GAP = 120, 288      -- typst line-gap 6 pt, par-gap 14.4 pt
local STAMP_GAP = 576                   -- typst page1-caption-gap 0.4 in
local RULE_ABOVE, TITLE_GAP = 144, 264  -- typst rule-above 7.2 pt, title-gap 13.2 pt
local SIG_GAP, SIG_INDENT = 288, 4680   -- typst sig-gap 14.4 pt, sig-indent 3.25 in
local CERT_ABOVE, CERT_GAP = 360, 144   -- typst cert-above 18 pt, cert-gap 7.2 pt

local function plain(v)
  return v == nil and "" or pandoc.utils.stringify(v)
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, tab, rule } (rule: a bottom border, the rule under
-- the caption).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.rule then props[#props + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>' end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- metadata text (a string or inlines) in capitals, as typst's upper()
local function upper(v)
  if pandoc.utils.type(v) == "Inlines" then
    return v:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(plain(v))
end

-- page 1: court title, the gap for the filing stamp, the caption, a rule, the title
local function first_page(meta, out)
  for i, l in ipairs(meta.court_title) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { before = i > 1 and LINE_GAP or 0, jc = "center" })
  end
  local rows = {}
  for i, r in ipairs(meta.caption or {}) do
    local cells = { r[1], ")", r[2] }
    local tcs = {}
    for c, text in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_WIDTHS[c] .. '" w:type="dxa"/></w:tcPr>' ..
        p(xe.inl(text), { before = i == 1 and STAMP_GAP or LINE_GAP }) .. "</w:tc>"
    end
    rows[#rows + 1] = "<w:tr>" .. table.concat(tcs) .. "</w:tr>"
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAPTION_WIDTHS[1] .. '"/><w:gridCol w:w="' .. CAPTION_WIDTHS[2] ..
    '"/><w:gridCol w:w="' .. CAPTION_WIDTHS[3] .. '"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>"
  -- the rule: an empty paragraph of the rule's space, its bottom border the line (typst: a line block)
  out[#out + 1] = p("", { line = RULE_ABOVE, rule = true })
  local title = meta.title
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { before = i == 1 and TITLE_GAP or LINE_GAP,
      after = i == #title and TITLE_GAP or 0, jc = "center" })
  end
end

-- a body paragraph at the body pitch: a label in its box after the indent (tab), or none
local function body_par(label, inlines)
  if label == nil then return p(xe.inl(inlines), { before = PAR_GAP, after = PAR_GAP, line = BODY, first = INDENT }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines),
    { before = PAR_GAP, after = PAR_GAP, line = BODY, first = INDENT, tab = INDENT + NUM })
end

-- signature block: the date line (optional), then the counsel lines in the right half; kept together
local function signature(sig, dated, out)
  local lines = {}
  if dated and sig.dated then lines[#lines + 1] = { xe.inl(sig.dated), SIG_GAP, 0 } end
  for i, l in ipairs(sig.lines) do
    lines[#lines + 1] = { xe.inl(l), i > 1 and LINE_GAP or (#lines > 0 and SIG_GAP or SIG_GAP), SIG_INDENT }
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { keep = i < #lines, before = l[2], left = l[3] })
  end
end

local function certificate(meta, out)
  if meta.certificate == nil then return end
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }),
    { keep = true, before = CERT_ABOVE, after = CERT_GAP, jc = "center" })
  local text = meta.certificate
  if pandoc.utils.type(text) == "Blocks" then text = pandoc.utils.blocks_to_inlines(text) end
  out[#out + 1] = p(xe.inl(text), { keep = true, line = BODY })
  signature(meta.signature, false, out)
end

-- Headings: single-spaced, kept with the text after them; level 1 centered capitals, level 2 bold, level 3 bold
-- italic.
local function heading(el)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(PAR_GAP, PAR_GAP, SINGLE), xe.ind(0, nil, 0),
    xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, { b = true, i = el.level >= 3 }))
end

-- Allegations: a paragraph is numbered 1, 2, ... except one beginning "WHEREFORE"; a list is lettered (a), (b), ...
local function allegations(blocks, out)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      if plain(b):match("^WHEREFORE") then
        out[#out + 1] = body_par(nil, b.content)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content)
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          out[#out + 1] = body_par("(" .. LETTERS[k] .. ")", first.content)
        end
      end
    elseif b.t == "Header" then
      out[#out + 1] = heading(b)
    else
      error("ganb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("Movant/Plaintiff") and one between a period and a section sign ("U.S.C.§": typst breaks
-- there): a zero-width space. Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1"):gsub("%.\u{00A7}", ".\u{200B}\u{00A7}")))
end

-- A sign stays with its number when pandoc has not bound it already: doubled ("§§ 1334") or after other text
-- ("U.S.C.§ 157"); a no-break space, as typst binds it with a box.
local function bind_trailing_signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    local sign = a.t == "Str" and #a.text > 2 and a.text:sub(-2)
    if (sign == "\u{00A7}" or sign == "\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_trailing_signs })
  local meta = doc.meta
  local out = {}
  first_page(meta, out)
  if meta.lead_in ~= nil then
    local li = meta.lead_in
    if pandoc.utils.type(li) == "Blocks" then li = pandoc.utils.blocks_to_inlines(li) end
    out[#out + 1] = body_par(nil, li)
  end
  allegations(doc.blocks, out)
  signature(meta.signature, true, out)
  certificate(meta, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
