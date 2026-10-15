-- mnd-motion-brief.lua (docx engine): what the Word output adds to pandoc's default conversion, to match
-- typst/mnd-motion-brief.typ (see ../README.md "Engines"):
--   * the front page: the court's name, the caption table (party column between rules; on the right the court file
--     number, the bold title in capitals and the rule line right-aligned), all from the sample's frontmatter;
--   * the signature block (date on the left, firm and signer on the right), kept together;
--   * the certificate of compliance on its own page (LR 7.1(f)(2)), with the word count from the frontmatter, and the
--     12,000-word limit checked at build time (LR 7.1(f)(1)(A)), as the typst template asserts it.
-- Frontmatter values are read as plain text (stringify): the caption, signature and certificate carry no italics.
-- Raw openxml is used only where Word has no paragraph-level equivalent (table borders, the caption table).

local WORD_LIMIT = 12000
local TWIP_DOUBLE = 598 -- 29.9 pt: the typst body pitch (2.3 em at 13 pt)
local TWIP_SINGLE = 299 -- 14.95 pt: the typst single pitch (1.15 em)
local TWIP_STACK = 130 -- 6.5 pt: the typst stack spacing between single-spaced items

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- One run of text; rpr is the run-property XML (bold, size) or nil.
local function run(text, rpr)
  local props = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. props .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- One paragraph: ppr is the paragraph-property XML; a blank line is an empty paragraph with the same pitch.
local function para(ppr, runs)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (runs or "") .. "</w:p>"
end

local function spacing(line, after)
  return string.format('<w:spacing w:before="0" w:after="%d" w:line="%d" w:lineRule="exact" />', after or 0, line)
end

local BOLD = '<w:b /><w:bCs /><w:sz w:val="26" /><w:szCs w:val="26" />'
local PLAIN = '<w:sz w:val="26" /><w:szCs w:val="26" />'
local NO_BORDERS = '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'

-- Caption: a two-column borderless table; the party column has a rule above and below (typst "caption").
local function caption_table(meta)
  local left = {}
  for k, p in ipairs(meta.caption or {}) do
    if k > 1 then
      left[#left + 1] = { ppr = spacing(TWIP_SINGLE, TWIP_STACK) .. '<w:ind w:left="432" />', runs = run("v.", PLAIN) }
    end
    for _, name in ipairs(p.names or {}) do
      left[#left + 1] = { ppr = spacing(TWIP_SINGLE, TWIP_STACK), runs = run(txt(name), PLAIN) }
    end
    left[#left + 1] = { ppr = spacing(TWIP_SINGLE, TWIP_STACK) .. '<w:ind w:left="1728" />', runs = run(txt(p.designation), PLAIN) }
  end
  local left_xml = {}
  for i, item in ipairs(left) do
    local ppr = item.ppr
    if i == #left then ppr = ppr:gsub('w:after="%d+"', 'w:after="0"') end
    left_xml[#left_xml + 1] = para(ppr, item.runs)
  end
  local right_xml = {
    para(spacing(TWIP_SINGLE, 0), run("Court File No. " .. txt(meta.case_number), PLAIN)),
    para(spacing(TWIP_DOUBLE, 0), ""),
    para(spacing(TWIP_SINGLE, 0) .. '<w:jc w:val="center" />', run(string.upper(txt(meta.brief_title)), BOLD)),
    para(spacing(TWIP_DOUBLE, 0), ""),
    para(spacing(TWIP_SINGLE, 0) .. '<w:jc w:val="right" />', run(txt(meta.rule_line), PLAIN)),
  }
  local rule = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000" /><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000" />'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" /><w:tblInd w:w="0" w:type="dxa" />' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar><w:tblLook w:val="0000" /></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752" /><w:gridCol w:w="432" /><w:gridCol w:w="4176" /></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa" /><w:tcBorders>' .. rule .. '</w:tcBorders>'
    .. '<w:tcMar><w:top w:w="160" w:type="dxa" /><w:bottom w:w="160" w:type="dxa" /></w:tcMar></w:tcPr>' .. table.concat(left_xml) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="432" w:type="dxa" /></w:tcPr>' .. para(spacing(TWIP_SINGLE, 0), "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa" /><w:tcMar><w:left w:w="144" w:type="dxa" /></w:tcMar></w:tcPr>' .. table.concat(right_xml) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

-- Court name, centred and bold, single-spaced; then a double line (typst court-title and front-page).
local function front_page(meta)
  local out = {}
  for _, line in ipairs({ "UNITED STATES DISTRICT COURT", "DISTRICT OF MINNESOTA" }) do
    out[#out + 1] = para(spacing(TWIP_SINGLE, 0) .. '<w:jc w:val="center" />', run(line, BOLD))
  end
  out[#out + 1] = para(spacing(TWIP_DOUBLE, 0), "")
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = para(spacing(TWIP_DOUBLE, 0), "")
  return table.concat(out)
end

-- Two-column line: the date in a 2.6-inch column, the text in the column to its right (typst "signature-block").
local function date_and_lines(date, lines)
  local right = {}
  for i, l in ipairs(lines) do
    local s = txt(l)
    if s == "" then s = "\u{00A0}" end
    local after = (i < #lines) and TWIP_STACK or 0
    right[#right + 1] = para('<w:keepNext />' .. spacing(TWIP_SINGLE, after), run(s, PLAIN))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" /><w:tblInd w:w="0" w:type="dxa" />' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar><w:tblLook w:val="0000" /></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="3744" /><w:gridCol w:w="288" /><w:gridCol w:w="5328" /></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit /></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa" /></w:tcPr>' .. para('<w:keepNext />' .. spacing(TWIP_SINGLE, 0), run("Dated: " .. txt(date), PLAIN)) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa" /></w:tcPr>' .. para(spacing(TWIP_SINGLE, 0), "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5328" w:type="dxa" /></w:tcPr>' .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

-- Certificate of compliance: its own page; the body is double-spaced and first-line indented (typst "certificate").
local function certificate(meta)
  local count = tonumber(txt(meta.word_count))
  if not count or count > WORD_LIMIT then
    error("mnd-motion-brief.lua: word_count must be a number at or below the LR 7.1(f)(1)(A) limit of 12,000")
  end
  local text = "I hereby certify that this memorandum complies with the word limit of D. Minn. LR 7.1(f)(1)(A) and the type-size requirement of D. Minn. LR 7.1(h)(1). The memorandum contains "
    .. txt(meta.word_count) .. " words, counted with " .. txt(meta.word_software)
    .. ", which was applied to include all text, including headings, footnotes, and quotations. The count excludes the caption, the signature block, and this certificate (LR 7.1(f)(1)(C))."
  return para('<w:pageBreakBefore />' .. spacing(TWIP_DOUBLE, 0) .. '<w:jc w:val="center" />', run("CERTIFICATE OF COMPLIANCE", BOLD))
    .. para(spacing(TWIP_DOUBLE, 0), "")
    .. para(spacing(TWIP_DOUBLE, 0) .. '<w:ind w:firstLine="720" /><w:jc w:val="both" />', run(text, PLAIN))
    .. para(spacing(TWIP_DOUBLE, 0), "")
    .. date_and_lines(meta.date, { meta.certificate_signer })
end

function Pandoc(doc)
  local out = {}
  out[#out + 1] = pandoc.RawBlock("openxml", front_page(doc.meta))
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  out[#out + 1] = pandoc.RawBlock("openxml", para(spacing(TWIP_DOUBLE, 0), ""))
  out[#out + 1] = pandoc.RawBlock("openxml", date_and_lines(doc.meta.date, doc.meta.signature or {}))
  out[#out + 1] = pandoc.RawBlock("openxml", certificate(doc.meta))
  doc.meta.date = nil -- the date is printed in the signature block only, not as a title block
  return pandoc.Pandoc(out, doc.meta)
end
