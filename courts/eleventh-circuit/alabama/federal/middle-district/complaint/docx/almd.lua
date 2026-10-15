-- almd.lua (docx engine): the M.D. Ala. complaint as Word paragraphs and a borderless caption table (typst:
-- almd-complaint.typ). pandoc writes the body with docx/reference.docx; this filter writes what the template sets by
-- hand: the court title, the FRCP 10(a) caption, the title, the FRCP 11(a) signature block and the service note.
-- Lettered items ("a.") stay paragraphs, as the typst template prints them (pandoc would read them as a list).
-- Spacing in twentieths of a point: SINGLE 16.1 pt, DOUBLE 32.2 pt, GAP 23.1 pt (the gap between blocks).
-- Word may paginate slightly differently from the LibreOffice PDF (docs/DOCX.md).

local stringify = pandoc.utils.stringify

local SINGLE = 322
local DOUBLE = 644
local GAP = 462
local INDENT = 720
local TEXT_W = 9360
local CAP_COLS = { 4896, 216, 4248 } -- 3.4 in, 0.15 in, 2.95 in: the caption grid of almd-complaint.typ
local KEEP = "<w:keepNext/><w:keepLines/>"
local JC_CENTER = '<w:jc w:val="center"/>'

local function str(x)
  if x == nil then return "" end
  if type(x) == "string" then return x end
  return stringify(x)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Text as Word runs; a line break (\n) is a w:br.
local function runs(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local out = {}
  local first = true
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if not first then out[#out + 1] = "<w:r>" .. rpr .. "<w:br/></w:r>" end
    first = false
    if line ~= "" then out[#out + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(line) .. "</w:t></w:r>" end
  end
  return table.concat(out)
end

-- A list of lines as one paragraph of runs, one line per w:br (the typst "\" at the end of each line).
local function lines(list)
  local parts = {}
  for i, l in ipairs(list) do parts[i] = str(l) end
  return runs(table.concat(parts, "\n"))
end

local function spacing(before, after, line)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before, after, line)
end

local function ind(left, first)
  return string.format('<w:ind w:left="%d" w:firstLine="%d"/>', left or 0, first or 0)
end

local function para(ppr, body)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. body .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- The court title: each line centered and bold, single-spaced, then a gap.
local function court_title(meta)
  local out = {}
  local n = #meta.court
  for i, line in ipairs(meta.court) do
    local keep = i < n and KEEP or ""
    local after = i == n and GAP or 0
    out[#out + 1] = raw(para(keep .. spacing(0, after, SINGLE) .. JC_CENTER, runs(str(line), true)))
  end
  return out
end

local function cell(width, ppr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. para(ppr, body) .. "</w:tc>"
end

-- The FRCP 10(a) caption: names on the left with a ")" column, the file number and the jury demand on the right.
-- Each side is its names (one row each) and its designation; a "v." row separates the sides.
local function caption(meta)
  local rows = {}
  local sep, defendant
  for i, side in ipairs(meta.caption.sides) do
    if i > 1 then
      sep = #rows + 1
      rows[#rows + 1] = { left = "v.", indent = true }
      defendant = #rows + 1
    end
    for _, name in ipairs(side.names) do rows[#rows + 1] = { left = str(name) } end
    rows[#rows + 1] = { left = str(side.designation), indent = true }
  end
  local label = str(meta.caption.case_label)
  if label == "" then label = "Civil Action No." end
  local case_no = str(meta.caption.case_number or meta.case_number)
  local jury = meta.jury_demand == true
  local ppr = spacing(0, 0, SINGLE)
  local trs = {}
  for k, r in ipairs(rows) do
    local right = ""
    if k == sep then right = label .. (case_no ~= "" and (" " .. case_no) or "") end
    if jury and k == defendant then right = "JURY DEMAND" end
    trs[#trs + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
      .. cell(CAP_COLS[1], ppr .. (r.indent and ind(INDENT) or ""), runs(r.left))
      .. cell(CAP_COLS[2], ppr, runs(")"))
      .. cell(CAP_COLS[3], ppr, runs(right))
      .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. "</w:tblPr><w:tblGrid>"
    .. "<w:gridCol w:w=\"" .. CAP_COLS[1] .. "\"/><w:gridCol w:w=\"" .. CAP_COLS[2] .. "\"/><w:gridCol w:w=\"" .. CAP_COLS[3] .. "\"/>"
    .. "</w:tblGrid>" .. table.concat(trs) .. "</w:tbl>"
end

-- The signature block (FRCP 11(a)): "Respectfully submitted," then each signer; "/s/" unless esign is false.
local function signature_block(meta)
  local out = {}
  out[#out + 1] = raw(para(KEEP .. spacing(0, GAP, SINGLE), runs("Respectfully submitted,")))
  for _, g in ipairs(meta.signature) do
    local sig = (g.esign ~= false and "/s/ " or "") .. str(g.signer)
    if g.note then sig = sig .. " (" .. str(g.note) .. ")" end
    local list = { sig }
    for _, l in ipairs(g.lines) do list[#list + 1] = l end
    out[#out + 1] = raw(para(KEEP .. spacing(0, GAP, SINGLE), lines(list)))
  end
  return out
end

-- Lines that follow the signature (the service address), single-spaced.
local function service_note(meta)
  local out = {}
  if meta.service_note then
    out[1] = raw(para(spacing(0, 0, SINGLE), lines(meta.service_note)))
  end
  return out
end

-- Lettered and numbered items that pandoc reads as a list: each stays a paragraph with its marker.
local function items_as_paragraphs(el)
  local out = pandoc.Blocks({})
  local start = el.listAttributes.start
  local style = tostring(el.listAttributes.style)
  if style ~= "LowerAlpha" and style ~= "Decimal" then
    error("almd.lua: unexpected list style " .. style)
  end
  for i, item in ipairs(el.content) do
    local n = start + i - 1
    local marker = style == "LowerAlpha" and (string.char(96 + n) .. ".") or (tostring(n) .. ".")
    local first = item[1]
    if first.t ~= "Para" and first.t ~= "Plain" then
      error("almd.lua: a lettered item must be a paragraph")
    end
    local inl = pandoc.Inlines({ pandoc.Str(marker), pandoc.Space() })
    for _, x in ipairs(first.content) do inl:insert(x) end
    out:insert(pandoc.Para(inl))
    for j = 2, #item do out:insert(item[j]) end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local body = pandoc.Pandoc(doc.blocks):walk({ OrderedList = items_as_paragraphs }).blocks
  local out = pandoc.Blocks({})
  for _, b in ipairs(court_title(meta)) do out:insert(b) end
  out:insert(raw(caption(meta)))
  out:insert(raw(para(KEEP .. spacing(GAP, GAP, SINGLE) .. JC_CENTER, runs(str(meta.title), true))))
  for _, b in ipairs(body) do out:insert(b) end
  for _, b in ipairs(signature_block(meta)) do out:insert(b) end
  for _, b in ipairs(service_note(meta)) do out:insert(b) end
  -- the title is written above, so pandoc writes no Title paragraph of its own
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
