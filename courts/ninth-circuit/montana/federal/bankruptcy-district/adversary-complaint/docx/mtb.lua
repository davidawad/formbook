-- U.S. Bankruptcy Court, D. Montana: pandoc filter for the docx engine (adversary complaint).
-- Writes the first-page blocks (counsel, court title, caption table, title of the paper) and the closing
-- blocks (signature, certificate of mailing) from the sample's YAML frontmatter, the same content as
-- typst/mtb-adversary-complaint.typ. The body paragraphs stay pandoc's. Styles, page size, margins and
-- the footer come from reference.docx (make-reference.sh). Layout set in XML, not rendered here.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("mtb-adversary-complaint: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- Paragraph. o: style (styleId), jc, bold, italic, caps, before, after, line (twips), line_rule,
-- ind_left, ind_right, ind_first, keep_next, box (paragraph border on all sides).
local function para(s, o)
  o = o or {}
  local ppr = ""
  if o.style then ppr = ppr .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if o.box then
    local b = '<w:%s w:val="single" w:sz="6" w:space="6" w:color="000000"/>'
    ppr = ppr .. "<w:pBdr>" .. string.format(b, "top") .. string.format(b, "left") .. string.format(b, "bottom") .. string.format(b, "right") .. "</w:pBdr>"
  end
  ppr = ppr .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '" w:line="' .. (o.line or 240) .. '" w:lineRule="' .. (o.line_rule or "auto") .. '"/>'
  if o.ind_left or o.ind_right or o.ind_first then
    ppr = ppr .. "<w:ind"
    if o.ind_left then ppr = ppr .. ' w:left="' .. o.ind_left .. '"' end
    if o.ind_right then ppr = ppr .. ' w:right="' .. o.ind_right .. '"' end
    if o.ind_first then ppr = ppr .. ' w:firstLine="' .. o.ind_first .. '"' end
    ppr = ppr .. "/>"
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  local rpr = ""
  if o.bold then rpr = rpr .. "<w:b/><w:bCs/>" end
  if o.italic then rpr = rpr .. "<w:i/><w:iCs/>" end
  if o.caps then rpr = rpr .. "<w:caps/>" end
  rpr = rpr == "" and "" or ("<w:rPr>" .. rpr .. "</w:rPr>")
  local body = ""
  body = body .. '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. body .. "</w:p>"
end

-- Lines of one single-spaced stack (counsel, caption cells, addressees). "" is a blank line.
local function lines(list, o)
  local out = {}
  for _, l in ipairs(list) do
    local s = plain(l)
    local po = { after = 40 }
    for k, v in pairs(o or {}) do po[k] = v end
    out[#out + 1] = para(s, po)
  end
  return table.concat(out)
end

-- A borderless or ruled table cell.
local function cell(width, inner, borders, mar)
  local tcpr = '<w:tcW w:w="' .. width .. '" w:type="dxa"/>'
  if borders then tcpr = tcpr .. "<w:tcBorders>" .. borders .. "</w:tcBorders>" end
  if mar then tcpr = tcpr .. "<w:tcMar>" .. mar .. "</w:tcMar>" end
  return '<w:tc><w:tcPr>' .. tcpr .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local NIL_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(grid, rows)
  local g = {}
  for _, w in ipairs(grid) do g[#g + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (grid[1] + grid[2]) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. NIL_BORDERS .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(g) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- Caption (FRBP 9004(b)(2)-(3)): party column 3.6 in with a right and bottom rule; case number column.
local CAPTION_LEFT, TEXT_WIDTH = 5184, 9360
local function caption_xml(meta)
  local rows = {}
  for _, blk in ipairs(need(meta, "caption")) do
    local rule = '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    local left = cell(CAPTION_LEFT, lines(blk.left, { before = 120 }), rule,
      '<w:right w:w="180" w:type="dxa"/>')
    local right = cell(TEXT_WIDTH - CAPTION_LEFT, lines(blk.right, { before = 120 }), nil,
      '<w:left w:w="180" w:type="dxa"/>')
    rows[#rows + 1] = "<w:tr>" .. left .. right .. "</w:tr>"
  end
  return table_xml({ CAPTION_LEFT, TEXT_WIDTH - CAPTION_LEFT }, rows)
end

-- Counsel block (LBR 5005-2(b)), court title (FRBP 9004(b)(1)), caption, title of the paper.
local function cover_xml(meta)
  local out = {}
  out[#out + 1] = lines(need(meta, "counsel"))
  if meta.counsel_role and plain(meta.counsel_role) ~= "" then
    out[#out + 1] = para(plain(meta.counsel_role), { italic = true, before = 40 })
  end
  for i, l in ipairs(need(meta, "court")) do
    out[#out + 1] = para(string.upper(plain(l)), { jc = "center", bold = true, before = (i == 1) and 720 or 0, after = 0 })
  end
  out[#out + 1] = para("", { after = 240 })
  out[#out + 1] = caption_xml(meta)
  out[#out + 1] = para(string.upper(plain(need(meta, "title"))), { jc = "center", bold = true, before = 480, after = 240 })
  return table.concat(out)
end

-- Signature (LBR 5005-2(c)) and certificate of mailing: right column 3.2 in (4608 twips).
local SIG_RIGHT = 4608
local function signature_xml(meta)
  local sig = need(meta, "signature")
  local right = lines(sig.preamble or {})
    .. para("", { after = 240 })
    .. para("By /s/ " .. plain(sig.signer), {})
    .. para(plain(sig.signer_role), {})
  local row = "<w:tr>" .. cell(TEXT_WIDTH - SIG_RIGHT, para(plain(sig.date), {}), nil, nil)
    .. cell(SIG_RIGHT, right, nil, nil) .. "</w:tr>"
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:p>'
    .. table_xml({ TEXT_WIDTH - SIG_RIGHT, SIG_RIGHT }, { row })
end

local function certificate_xml(meta)
  local c = meta.certificate
  if c == nil then return "" end
  local out = {}
  out[#out + 1] = para(string.upper(plain(c.title)), { jc = "center", bold = true, before = 720, after = 240, keep_next = true })
  out[#out + 1] = para(plain(c.text), { style = "BodyText" })
  out[#out + 1] = lines(c.addressees or {}, { ind_left = 720, before = 0 })
  out[#out + 1] = para("/s/ " .. plain(c.signer), { ind_left = SIG_RIGHT, before = 480 })
  out[#out + 1] = para(plain(c.signer), { ind_left = SIG_RIGHT })
  out[#out + 1] = para("Dated: " .. plain(c.date), { ind_left = SIG_RIGHT })
  return table.concat(out)
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = { pandoc.RawBlock("openxml", cover_xml(meta)) }
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  local closing = signature_xml(meta) .. certificate_xml(meta)
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", closing)
  -- The title is set on the cover above; do not let pandoc print it again as a Title paragraph.
  meta.title = nil
  return pandoc.Pandoc(blocks, meta)
end
