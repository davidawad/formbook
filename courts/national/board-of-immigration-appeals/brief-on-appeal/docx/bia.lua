-- BIA brief on appeal, DOCX engine (docs/DOCX.md). Pandoc writes the markdown body; this filter writes the
-- front matter and the back matter as WordprocessingML, from the same frontmatter fields that
-- typst/bia-brief-on-appeal.typ reads: the cover, the contents (a TOC field with its result filled in), the
-- signature block and the certificate of service. Sections: cover (no footer), contents (footer, roman from i), body
-- (footer with the page number and the A-number; numbering restarts at the Introduction, as in the typst copy).
-- The table of contents page numbers come from docx/render.sh (a first pass renders the PDF and finds each
-- heading), passed as metadata bia_toc=<file>, one page number per line in heading order.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a MetaList (or a single value) as an array of strings
local function lines_of(v)
  local out = {}
  if v == nil then return out end
  if pandoc.utils.type(v) == "List" then
    for _, x in ipairs(v) do out[#out + 1] = str(x) end
  else
    out[#out + 1] = str(v)
  end
  return out
end

local BOLD = "<w:b/><w:bCs/>"
local SECT = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
-- the contents section: the body's footer (page number and A-number, docx/build-reference.sh), numbered in roman from i
-- (PM ch. 4.6(b) pagination, ch. 4.6(c)(2) A-number on every page after the cover; typst numbers it the same way)
local TOC_SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdBiaFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
local NOBORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function R(text, rpr)
  return '<w:r>' .. (rpr and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- a paragraph: style, runs, and paragraph properties (in schema order: framePr, spacing, ind, jc, sectPr)
local function P(style, runs, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function RAW(xml)
  return pandoc.RawBlock('openxml', xml)
end

-- a borderless table; widths in twips; rows = array of arrays of cell XML (each cell ends in a paragraph)
local function TABLE(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NOBORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' }
  for _, row in ipairs(rows) do
    local cells = {}
    for i, cell in ipairs(row) do
      cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. cell .. '</w:tc>'
    end
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return table.concat(out)
end

-- ---- cover (typst: "cover page", ch. 3.3(c)(6), App. E) ----
local function cover(meta)
  local blocks = {}
  local filer = meta.filer or {}
  local left = P("CoverSmall", R(str(filer.name)))
  for _, l in ipairs(lines_of(filer.lines)) do left = left .. P("CoverSmall", R(l)) end
  local custody = meta.custody and str(meta.custody) or ""
  local box = ""
  if custody ~= "" then
    box = P("Single", R(string.upper(custody), BOLD),
      '<w:pBdr><w:top w:val="single" w:sz="8" w:space="4" w:color="000000"/><w:left w:val="single" w:sz="8" w:space="4" w:color="000000"/>'
      .. '<w:bottom w:val="single" w:sz="8" w:space="4" w:color="000000"/><w:right w:val="single" w:sz="8" w:space="4" w:color="000000"/></w:pBdr>'
      .. '<w:ind w:left="72" w:right="72"/><w:jc w:val="right"/>')
  else
    box = P("Single", "")
  end
  blocks[#blocks + 1] = RAW(TABLE({ 6480, 2880 }, { { left, box } }))

  local centre = P("Centered", R("UNITED STATES DEPARTMENT OF JUSTICE", BOLD), '<w:spacing w:before="720"/>')
    .. P("Centered", R("EXECUTIVE OFFICE FOR IMMIGRATION REVIEW", BOLD))
    .. P("Centered", R("BOARD OF IMMIGRATION APPEALS", BOLD))
    .. P("Centered", R(str(meta.location)))
  blocks[#blocks + 1] = RAW(centre)

  local respondent = meta.respondent or {}
  local caption_left = P("Single", R("In the Matter of:"), '<w:spacing w:before="480" w:after="240"/>')
    .. P("Single", R(str(respondent.name)), '<w:spacing w:after="240"/>')
    .. P("Single", R(str(respondent.role)), '<w:spacing w:after="240"/>')
    .. P("Single", R(str(meta.proceeding_type)))
  local caption_right = P("Single", R("File No.: A" .. str(meta.a_number)), '<w:spacing w:before="864"/>')
  blocks[#blocks + 1] = RAW(TABLE({ 5328, 288, 3744 }, { { caption_left, P("Single", ""), caption_right } }))

  blocks[#blocks + 1] = RAW(P("Centered", R(string.upper(str(meta.title)), BOLD), '<w:spacing w:before="720"/>'))

  -- the counsel block sits at the foot of the page: a frame anchored to the bottom of the text area
  local frame = '<w:framePr w:w="4680" w:hSpace="0" w:wrap="around" w:vAnchor="margin" w:hAnchor="margin" w:yAlign="bottom"/>'
  local counsel = meta.counsel or {}
  local fr = ""
  for _, n in ipairs(lines_of(counsel.names)) do fr = fr .. P("Single", R(n), frame) end
  for _, l in ipairs(lines_of(counsel.lines)) do fr = fr .. P("Single", R(l), frame) end
  fr = fr .. P("Single", R(str(counsel.role)), frame)
  blocks[#blocks + 1] = RAW(fr)

  -- section break: the cover has no footer
  blocks[#blocks + 1] = RAW(P("Single", "", SECT))
  return blocks
end

-- ---- contents page (typst: "table of contents", generated from the headings) ----
local function contents(entries, pages)
  local out = { RAW(P("Centered", R("TABLE OF CONTENTS", BOLD), '<w:spacing w:after="360"/>')) }
  local xml = {}
  for i, e in ipairs(entries) do
    local style = e.level == 1 and "TOC1" or "TOC2"
    local runs = ""
    if i == 1 then
      runs = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    runs = runs .. R(e.text) .. '<w:r><w:tab/></w:r>' .. R(pages[i] or "")
    if i == #entries then
      runs = runs .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
    end
    xml[#xml + 1] = P(style, runs)
  end
  if #entries == 0 then
    xml[#xml + 1] = P("Single", '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')
  end
  out[#out + 1] = RAW(table.concat(xml))
  out[#out + 1] = RAW(P("Single", "", TOC_SECT))
  return out
end

-- ---- signature block (typst: "signature block", ch. 3.3(b), ch. 4.6(c)(1)) ----
local function signature(meta)
  local sig = meta.signature or {}
  local right = P("Single", R("Respectfully submitted,"), '<w:spacing w:after="576"/>')
    .. P("Single", "", '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr><w:ind w:right="0"/>')
    .. P("Single", R(str(sig.signer)))
  for _, l in ipairs(lines_of(sig.lines)) do right = right .. P("Single", R(l)) end
  return RAW(TABLE({ 5040, 4320 }, { { P("Single", R("Dated: " .. str(meta.date))), right } }))
end

-- ---- certificate of service (typst: ch. 3.2(d)) ----
local function certificate(meta)
  local svc = meta.service or {}
  local out = {}
  out[#out + 1] = RAW(P("Centered", R("CERTIFICATE OF SERVICE", BOLD), '<w:pageBreakBefore/><w:spacing w:after="432"/>'))
  local text
  if str(svc.means) == "ecas" then
    text = "This document was electronically filed through ECAS and both parties are participating in ECAS. Therefore, no separate service was completed."
  else
    text = "I certify that on " .. str(svc.date) .. ", I served a copy of the foregoing " .. str(svc.document) .. ", by "
      .. str(svc.means) .. ", on " .. str(svc.served_on and svc.served_on.name) .. ", at "
      .. str(svc.served_on and svc.served_on.address) .. "."
  end
  out[#out + 1] = RAW(P("BodyText", R(text)))
  local by = svc.served_by or {}
  local right = P("Single", "", '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="576"/><w:ind w:right="0"/>')
    .. P("Single", R(str(by.name)))
    .. P("Single", R(str(by.role)))
  out[#out + 1] = RAW(TABLE({ 5040, 4320 }, { { P("Single", ""), right } }))
  return out
end

function Pandoc(doc)
  local meta = doc.meta

  -- contents entries: the level-1 and level-2 headings of the body, in order
  local entries = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 2 then
      entries[#entries + 1] = { level = b.level, text = str(b.content) }
    end
  end
  local pages = {}
  local f = str(meta.bia_toc)
  if f ~= "" then
    local h = io.open(f, "r")
    if h then
      for line in h:lines() do pages[#pages + 1] = line end
      h:close()
    end
  end

  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(contents(entries, pages)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = RAW(P("Single", "", '<w:spacing w:before="240"/>'))
  blocks[#blocks + 1] = signature(meta)
  for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
