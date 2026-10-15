-- nced-motion-brief.lua (docx engine): what the Word output adds to pandoc's conversion, in the form of the typst
-- template (typst/nced-motion-brief.typ) and docs/DOCX.md:
--   * the cover (court and division, "No." line, caption with the ")" column, title block): raw WordprocessingML, because
--     the caption is a borderless table with a column of ")" marks, which markdown cannot write;
--   * heading labels as the template prints them: under ARGUMENT, I., II. (level 2) and A., B. (level 3); elsewhere
--     A., B. (level 2) and 1., 2. (level 3); the counters reset at each higher level; the label is followed by a tab
--     to the hanging indent;
--   * the dated signature block, the word-count certificate (LR 7.2(f)(3)) on its own page when frontmatter has
--     word_count, and the certificate of service (Fed. R. Civ. P. 5(d)(1)(B)) when frontmatter has certificate.
-- All case-specific text comes from the sample's frontmatter, never from this file.

local function xml(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- One WordprocessingML paragraph, as a string. Child elements in schema order (keepNext, pageBreakBefore, spacing,
-- ind, jc). opts: keepNext, pageBreakBefore, after (twips), ind (left, twips), jc, bold.
local function Px(style, s, opts)
  opts = opts or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.pageBreakBefore then ppr = ppr .. "<w:pageBreakBefore/>" end
  if opts.after then ppr = ppr .. '<w:spacing w:before="0" w:after="' .. opts.after .. '"/>' end
  if opts.ind then ppr = ppr .. '<w:ind w:left="' .. opts.ind .. '" w:firstLine="0"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local run = ""
  if s ~= "" then
    local rpr = opts.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
    run = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. xml(s) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. run .. "</w:p>"
end

local function P(style, s, opts)
  return pandoc.RawBlock("openxml", Px(style, s, opts))
end

-- A vertical gap of a given height in twips (exact line height), for the cover and the certificates.
local function gap(twips, keep)
  return pandoc.RawBlock("openxml", "<w:p><w:pPr><w:pStyle w:val=\"Normal\"/>" .. (keep and "<w:keepNext/>" or "") .. "<w:spacing w:before=\"0\" w:after=\"0\" w:line=\""
    .. twips .. "\" w:lineRule=\"exact\"/></w:pPr></w:p>")
end

-- One body double line (typst v(body-leading)); keep=true keeps it with the next paragraph.
local function blank(keep)
  return P("Normal", "", { keepNext = keep })
end

-- Caption: a borderless three-column table: party lines | ")" marks | title block (vertically centred).
local COL1, COL2, COL3 = 4896, 360, 4104 -- 3.4 in, 0.25 in, the rest of the 6.5 in text width
local GAP_COVER = { 276, 0, 254 } -- twips: after the court title, after "No.", after the caption (measured against the typst render)

local function caption(meta)
  local rows = {}
  local lines = meta.caption and meta.caption.lines or {}
  for _, item in ipairs(lines) do
    if item.t ~= nil then
      table.insert(rows, { t = text(item.t), i = tonumber(text(item.i)) or 0 })
    else
      table.insert(rows, { t = text(item), i = 0 })
    end
  end
  local title = Px("CaptionTitle", text(meta.brief_title))
  local out = {}
  table.insert(out, '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. ''
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. COL1 .. '"/><w:gridCol w:w="' .. COL2 .. '"/><w:gridCol w:w="' .. COL3 .. '"/></w:tblGrid>')
  for k, r in ipairs(rows) do
    local lcell = Px("CaptionLine", r.t, { ind = (r.i > 0) and (r.i * 720) or nil })
    local pcell = Px("CaptionLine", ")")
    local tcell
    if k == 1 then
      tcell = '<w:tc><w:tcPr><w:tcW w:w="' .. COL3 .. '" w:type="dxa"/><w:vMerge w:val="restart"/><w:vAlign w:val="center"/></w:tcPr>' .. title .. "</w:tc>"
    else
      tcell = '<w:tc><w:tcPr><w:tcW w:w="' .. COL3 .. '" w:type="dxa"/><w:vMerge/></w:tcPr>' .. Px("CaptionLine", "") .. "</w:tc>"
    end
    table.insert(out, "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. COL1 .. '" w:type="dxa"/></w:tcPr>' .. lcell .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. COL2 .. '" w:type="dxa"/></w:tcPr>' .. pcell .. "</w:tc>"
      .. tcell .. "</w:tr>")
  end
  table.insert(out, "</w:tbl>")
  return pandoc.RawBlock("openxml", table.concat(out))
end

local function cover(meta)
  local blocks = pandoc.List()
  blocks:insert(P("CourtTitle", "IN THE UNITED STATES DISTRICT COURT"))
  blocks:insert(P("CourtTitle", "FOR THE EASTERN DISTRICT OF NORTH CAROLINA"))
  blocks:insert(P("CourtTitle", string.upper(text(meta.division)) .. " DIVISION"))
  blocks:insert(gap(GAP_COVER[1]))
  local num = text(meta.case_number)
  if num == "" then
    blocks:insert(P("Normal", "No. " .. string.rep("_", 14), { jc = "center" }))
  else
    blocks:insert(P("Normal", "No. " .. num, { jc = "center" }))
  end
  blocks:insert(gap(GAP_COVER[2]))
  blocks:insert(caption(meta))
  blocks:insert(gap(GAP_COVER[3]))
  return blocks
end

-- The attorney block (LR 10.1(f), (h), (i)): firm, the "BY: /s/" line, each signer, the address and the party.
-- Every line is kept with the next one (typst's block is unbreakable); keep_last holds the block with what follows.
local function signature_lines(meta, keep_last)
  local lines = {}
  local sig = meta.signature or {}
  local function group(items)
    for _, s in ipairs(items) do table.insert(lines, s) end
  end
  local firm = {}
  for _, s in ipairs(sig.firm or {}) do table.insert(firm, text(s)) end
  local signers = sig.signers or {}
  local by = sig.by and text(sig.by) or (signers[1] and text(signers[1].name)) or ""
  group(firm)
  if #firm > 0 then group({ "BY: /s/ " .. by }) else group({ "/s/ " .. by }) end
  for _, s in ipairs(signers) do
    local items = { text(s.name) }
    for _, l in ipairs(s.lines or {}) do table.insert(items, text(l)) end
    group(items)
  end
  local address = {}
  for _, s in ipairs(sig.address or {}) do table.insert(address, text(s)) end
  group(address)
  local counsel = {}
  for _, s in ipairs(sig.counsel_for or {}) do table.insert(counsel, text(s)) end
  group(counsel)
  local blocks = pandoc.List()
  for k, s in ipairs(lines) do
    blocks:insert(P("SigBlock", s, { keepNext = (k < #lines) or keep_last }))
  end
  return blocks
end

-- The dated signature after the conclusion (LR 10.1(g)); the date and the block are kept together.
local function signature(meta)
  local blocks = pandoc.List()
  blocks:insert(P("Single", "This the " .. text(meta.date) .. ".", { keepNext = true }))
  blocks:insert(gap(280, true))
  blocks:extend(signature_lines(meta, false))
  return blocks
end

-- LR 7.2(f)(3): a memorandum that uses the word limit carries a certificate of its word count (own page).
local function word_certificate(meta)
  local blocks = pandoc.List()
  blocks:insert(P("CertTitle", "CERTIFICATE OF COMPLIANCE WITH WORD LIMIT", { pageBreakBefore = true, keepNext = true }))
  blocks:insert(blank(true))
  blocks:insert(P("BodyText",
    "The undersigned certifies that this memorandum complies with the word limit of Local Civil Rule 7.2(f)(3)(A) and contains "
    .. text(meta.word_count) .. " words, excluding the matters listed in Local Civil Rule 7.2(f)(1), as counted by the word-processing software used to prepare it.",
    { keepNext = true }))
  blocks:insert(blank(true))
  blocks:extend(signature_lines(meta, false))
  return blocks
end

-- Fed. R. Civ. P. 5(d)(1)(B): the certificate of service, with the parties served and the date. Kept as one block.
local function service_certificate(meta)
  local cert = meta.certificate
  local blocks = pandoc.List()
  blocks:insert(P("CertTitle", "CERTIFICATE OF SERVICE", { keepNext = true }))
  blocks:insert(blank(true))
  blocks:insert(P("BodyText", text(cert.text), { keepNext = true }))
  blocks:insert(blank(true))
  for _, s in ipairs(cert.served or {}) do blocks:insert(P("ServedLine", text(s), { keepNext = true })) end
  blocks:insert(blank(true))
  blocks:insert(P("BodyText", "This the " .. text(cert.date) .. ".", { keepNext = true }))
  blocks:insert(blank(true))
  blocks:extend(signature_lines(meta, false))
  return blocks
end

-- Heading labels. Level 1 sets the scheme; under ARGUMENT, level 2 is roman and level 3 lettered; elsewhere level 2
-- is lettered and level 3 numbered (the typst template's numbering).
local in_argument = false
local counts = { 0, 0, 0 }

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function label(level, n)
  if level == 2 then
    if in_argument then return roman(n) .. "." end
    return string.char(64 + n) .. "."
  end
  if in_argument then return string.char(64 + n) .. "." end
  return n .. "."
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

function Header(el)
  if el.level == 1 then
    in_argument = pandoc.utils.stringify(el.content):lower():match("^%s*(.-)%s*$") == "argument"
    counts = { 0, 0, 0 }
    return el
  end
  if el.level > 3 then error("nced-motion-brief.lua: headings deeper than level 3 are not supported") end
  counts[el.level] = counts[el.level] + 1
  for k = el.level + 1, 3 do counts[k] = 0 end
  table.insert(el.content, 1, TAB)
  table.insert(el.content, 1, pandoc.Str(label(el.level, counts[el.level])))
  return el
end

function Pandoc(doc)
  local meta = doc.meta
  local date = text(meta.date)
  local out = pandoc.List()
  out:extend(cover(meta))
  out:extend(doc.blocks)
  out:insert(blank())
  out:extend(signature(meta))
  if meta.word_count ~= nil then out:extend(word_certificate(meta)) end
  if meta.certificate ~= nil then
    out:insert(blank())
    out:extend(service_certificate(meta))
  end
  -- pandoc would print the date and title at the top of the body; the dates sit in the signature and certificates
  meta.date = nil
  meta.title = nil
  return pandoc.Pandoc(out, meta)
end
