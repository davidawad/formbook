-- mtb.lua (docx engine, D. Mont. bankruptcy court, adversary complaint): the complaint as Word paragraphs, so that
-- it reads and breaks as typst/mtb-adversary-complaint.typ does: the counsel block (LBR 5005-2(b)), the court title,
-- the caption (one row per caption block, the party column ruled at its right and foot; FRBP 9004(b)), the title, the
-- body (paragraphs with the numbers the sample types, headings), the signature block (LBR 5005-2(c)) and the
-- certificate of mailing. Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 280 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 280            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- typst text-width, 6.5 in
local CAP_LEFT = 5184                    -- typst caption-left, 3.6 in
local CAP_PAD = 120                      -- typst cap-pad, 6 pt
local CAP_PAD_FOOT = 105                 -- typst cap-pad less the 0.75 pt rule Word sets inside the cell's foot
local CASE_PAD = 240                     -- typst case-pad, 12 pt
local SIG = 4608                         -- typst sig-col, 3.2 in
local ADDR = 720                         -- typst addressee-indent, 0.5 in
local COURT_ABOVE, CAPTION_ABOVE = 720, 480 -- typst court-above 36 pt, caption-above 24 pt
local TITLE_ABOVE, TITLE_BELOW = 480, 240   -- typst title-above 24 pt, title-below 12 pt
local SIG_ABOVE, SIG_GAP = 480, 240         -- typst sig-above 24 pt, sig-gap 12 pt
local CERT_ABOVE, CERT_GAP, CERT_SIG = 720, 240, 480 -- typst cert-above 36 pt, cert-gap 12 pt, cert-sig-above 24 pt

local function need(meta, key)
  if meta[key] == nil then error("mtb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  local out = {}
  for _, v in ipairs(m or {}) do out[#out + 1] = v end
  return out
end

-- A paragraph: o = { before, after, line, left, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single lines, one per item; an empty item is a blank line (typst: lines).
local function lines(items, o, out)
  out = out or {}
  for _, l in ipairs(items) do out[#out + 1] = p(plain(l) == "" and "" or xe.inl(l), o) end
  return out
end

local function cell(w, pr, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- A table of fixed columns, no borders and no cell margins of its own; rows are not split across pages.
local function tbl(widths, rows)
  local g, total = {}, 0
  for _, w in ipairs(widths) do
    g[#g + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  local trs = {}
  for _, r in ipairs(rows) do trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. r .. '</w:tr>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>' .. table.concat(g) ..
    '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- Vertical space of its own (typst: the space above a table): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- ---------------------------------------------------------------------------
-- Counsel block, court title, caption, title
-- ---------------------------------------------------------------------------

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function caption(meta)
  local rows = {}
  for _, b in ipairs(need(meta, "caption")) do
    rows[#rows + 1] = cell(CAP_LEFT, RULES .. '<w:tcMar><w:top w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:bottom w:w="' ..
        CAP_PAD_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>',
        table.concat(lines(list(b.left)))) ..
      cell(TEXTW - CAP_LEFT, '<w:tcMar><w:top w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:left w:w="' .. CASE_PAD ..
        '" w:type="dxa"/></w:tcMar>', table.concat(lines(list(b.right))))
  end
  return tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, rows)
end

local function cover(meta, out)
  lines(list(need(meta, "counsel")), nil, out)
  if meta.counsel_role and plain(meta.counsel_role) ~= "" then
    out[#out + 1] = p(xe.inl(meta.counsel_role, { i = true }))
  end
  for i, l in ipairs(list(need(meta, "court"))) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }),
      { jc = "center", before = i == 1 and COURT_ABOVE or 0 })
  end
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = caption(meta)
  -- the title in capitals as typst upper() sets it; a section sign kept with its number (a no-break space, as xe.inl)
  local title = pandoc.text.upper(plain(need(meta, "title"))):gsub("\u{00A7} ", "\u{00A7}\u{00A0}")
  out[#out + 1] = p(xe.runs(title, { b = true }),
    { jc = "center", before = TITLE_ABOVE, after = TITLE_BELOW })
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of mailing
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = need(meta, "signature")
  local right = lines(list(sig.preamble))
  right[#right + 1] = p(xe.runs("By /s/ ") .. xe.inl(sig.signer), { before = SIG_GAP })
  right[#right + 1] = p(xe.inl(sig.signer_role))
  out[#out + 1] = space(SIG_ABOVE)
  out[#out + 1] = tbl({ TEXTW - SIG, SIG }, { cell(TEXTW - SIG, nil, p(xe.inl(sig.date))) ..
    cell(SIG, nil, table.concat(right)) })
end

-- Kept whole, as typst's unbreakable block: every paragraph but the last kept with the next.
local function certificate(meta, out)
  local c = meta.certificate
  if c == nil then return end
  local L = TEXTW - SIG
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(c.title)), { b = true }),
    { jc = "center", before = CERT_ABOVE, keep = true })
  out[#out + 1] = p(xe.inl(c.text), { line = BODY, first = INDENT, before = CERT_GAP, after = CERT_GAP, keep = true })
  lines(list(c.addressees), { left = ADDR, keep = true }, out)
  out[#out + 1] = p(xe.runs("/s/ ") .. xe.inl(c.signer), { left = L, before = CERT_SIG, keep = true })
  out[#out + 1] = p(xe.inl(c.signer), { left = L, keep = true })
  out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(c.date), { left = L })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: centered bold capitals on the body pitch, kept with the text after them.
local function heading(b)
  local content = pandoc.Inlines(b.content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  return xe.para({ xe.style("Heading" .. math.min(b.level, 3)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(content, { b = true }))
end

local function blocks(list_, out)
  for _, b in ipairs(list_) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    else
      error("mtb.lua: unsupported block " .. b.t, 0)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  for _, k in ipairs({ "case_number", "adversary_number", "court", "counsel", "caption", "title", "signature" }) do
    local _ = need(doc.meta, k)
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  blocks(doc.blocks, out)
  signature(meta, out)
  certificate(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
