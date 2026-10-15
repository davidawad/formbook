-- flnd-motion-brief.lua (docx engine). What the Word output adds to pandoc's conversion, so that it follows the typst
-- template (typst/flnd-motion-brief.typ; rules: ../README.md, "Engines"):
--   * the cover: court title, case style (parties, CASE NO.), the title of the paper, the lead-in. Built as OpenXML
--     with the styles of reference.docx (Court Title, Caption Line, ...), so the caption rule is a cell border;
--   * the signature block (Loc. R. 5.1(D)) before the certificate of service when there is one (as the typst does),
--     otherwise after the last paragraph; kept in one row;
--   * body paragraphs unnumbered (a memorandum, Loc. R. 7.1(E)); the pandoc conversion of the body is otherwise kept.
-- Every case-specific word comes from the sample's frontmatter, never from this file.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

-- One run of text with bold/italic flags (fl.b, fl.i); rPr children in schema order.
local function run(text, fl)
  local rp = ""
  if fl.b then rp = rp .. "<w:b/><w:bCs/>" end
  if fl.i then rp = rp .. "<w:i/><w:iCs/>" end
  if rp ~= "" then rp = "<w:rPr>" .. rp .. "</w:rPr>" end
  return '<w:r>' .. rp .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- Inline content to runs. Emphasis (case names, "*Attorney for Defendant*") becomes italic.
local function runs(inlines, fl)
  fl = fl or {}
  local out = {}
  for _, el in ipairs(inlines) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, fl)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out[#out + 1] = run(" ", fl)
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, { b = fl.b, i = true })
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = fl.i })
    elseif t == "Quoted" then
      local q = el.quotetype == "SingleQuote" and { "\u{2018}", "\u{2019}" } or { "\u{201C}", "\u{201D}" }
      out[#out + 1] = run(q[1], fl) .. runs(el.content, fl) .. run(q[2], fl)
    elseif el.content then
      out[#out + 1] = runs(el.content, fl)
    elseif el.text then
      out[#out + 1] = run(el.text, fl)
    end
  end
  return table.concat(out)
end

-- A metadata value as inlines: markdown-parsed MetaInlines, or a plain string.
local function inl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then
    local doc = pandoc.read(v, "markdown")
    local first = doc.blocks[1]
    return first and first.content or pandoc.Inlines({})
  end
  return v
end

local function para(style, xml)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '" /></w:pPr>' .. xml .. '</w:p>'
end

local function spacer(style)
  return para(style, "")
end

-- Case style (Loc. R. 5.1(B)): the parties at the left, closed by a rule at the foot of the column; CASE NO. and the
-- number at the right. Between parties, one single line of space, as the typst template (no "v." in this caption).
local function caption_table(m)
  local left = {}
  for k, p in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = spacer("SpacerPitch") end
    for _, n in ipairs(p.names) do
      left[#left + 1] = para("CaptionLine", runs(inl(n)))
    end
    left[#left + 1] = para("CaptionLine", runs(inl(p.designation)))
  end
  local right = para("CaptionLine", run("CASE NO.", {})) .. para("CaptionLine", runs(inl(m.case_number)))
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" /><w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752" /><w:gridCol w:w="432" /><w:gridCol w:w="4176" /></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit /></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa" /><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000" /></w:tcBorders>'
    .. '<w:tcMar><w:bottom w:w="144" w:type="dxa" /><w:right w:w="288" w:type="dxa" /></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="432" w:type="dxa" /></w:tcPr>' .. spacer("CaptionLine") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa" /><w:tcMar><w:left w:w="144" w:type="dxa" /></w:tcMar></w:tcPr>'
    .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

-- The signature block (Loc. R. 5.1(D)), as in the typst template: the date at the left; "Respectfully submitted,",
-- the firm, then the signing attorney's lines at the right. One row, so it does not split across pages.
local function signature_table(m)
  local sig = m.signature
  -- The typst blank lines are 16 pt, but its signature lines are 9.1 pt high (the 7 pt leading goes between lines):
  -- a 9.1 pt gap here gives the same baseline distance. Without a firm, the second blank line follows in full.
  local firm = sig.firm or {}
  local right = para("SigLine", run("Respectfully submitted,", {})) .. spacer("SpacerSigGap")
  for _, line in ipairs(firm) do
    right = right .. para("SigLine", runs(inl(line)))
  end
  right = right .. spacer(#firm > 0 and "SpacerSigGap" or "SpacerSingle")
  right = right .. para("SigLine", runs(inl(sig.by)))
  for _, line in ipairs(sig.lines or {}) do
    right = right .. para("SigLine", runs(inl(line)))
  end
  local dated = para("SigLine", run("Dated: " .. pandoc.utils.stringify(inl(m.date)), {}))
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" /><w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4320" /><w:gridCol w:w="5040" /></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit /></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa" /></w:tcPr>' .. dated .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5040" w:type="dxa" /><w:tcMar><w:left w:w="288" w:type="dxa" /></w:tcMar></w:tcPr>'
    .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

local function signature_blocks(m)
  return pandoc.RawBlock("openxml", spacer("SpacerPitch")), pandoc.RawBlock("openxml", signature_table(m))
end

local function cover(m)
  local blocks = {}
  local function raw(xml) blocks[#blocks + 1] = pandoc.RawBlock("openxml", xml) end
  raw(para("CourtTitle", run("UNITED STATES DISTRICT COURT", { b = true })))
  raw(para("CourtTitle", run("NORTHERN DISTRICT OF FLORIDA", { b = true })))
  raw(para("CourtTitle", run(pandoc.utils.stringify(inl(m.division)):upper(), { b = true })))
  raw(spacer("SpacerPitch"))
  raw(spacer("SpacerSingle"))
  raw(caption_table(m))
  raw(spacer("SpacerPitch"))
  raw(para("CaseTitle", runs(inl(m.brief_title), { b = true })))
  raw(spacer("SpacerPitch"))
  if m.lead_in then
    raw(para("BodyText", runs(inl(m.lead_in))))
  end
  return blocks
end

function Pandoc(doc)
  local m = doc.meta
  local out = cover(m)
  local signed = false
  for _, el in ipairs(doc.blocks) do
    if el.t == "Header" and el.level == 1 and not signed
        and pandoc.utils.stringify(el):find("CERTIFICATE OF SERVICE", 1, true) then
      local pitch, sig = signature_blocks(m)
      out[#out + 1] = pitch
      out[#out + 1] = sig
      signed = true
    end
    out[#out + 1] = el
  end
  if not signed then
    local pitch, sig = signature_blocks(m)
    out[#out + 1] = pitch
    out[#out + 1] = sig
  end
  -- The title block is the cover built here: pandoc must not add its own title, author or date.
  m.title, m.subtitle, m.author, m.date = nil, nil, nil, nil
  return pandoc.Pandoc(out, m)
end
