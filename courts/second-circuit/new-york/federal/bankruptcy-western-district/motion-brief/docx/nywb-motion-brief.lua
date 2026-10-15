-- W.D.N.Y. motion with memorandum of law, DOCX engine (docs/DOCX.md). Mirrors typst/nywb-motion-brief.typ:
-- the cover (court title, caption, title of the paper, counsel block), the table of contents (roman page numbers),
-- the body (arabic page numbers from 1; every paragraph indented, double spaced), and the signature block.
-- Every case-specific word comes from the sample's frontmatter. Paragraphs that pandoc writes take their styles from
-- build-reference.sh. The cover, table of contents and signature are raw OpenXML; their paragraphs carry direct
-- formatting, because pandoc drops reference styles that the document body does not use (a raw paragraph that
-- names an unknown style makes LibreOffice stack the table cells).
-- The table of contents lists the headings with page numbers measured on a first pass (docx/render.sh writes the
-- file named by NYWB_TOC_PAGES: one "page" per heading, in heading order; absent on the first pass).

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value that is a list (or a single value) as a list of plain strings
local function plain_list(v)
  if v == nil then return {} end
  if v.t ~= nil then return { plain(v) } end  -- a single value (MetaInlines)
  local out = {}
  for _, x in ipairs(v) do out[#out + 1] = plain(x) end  -- a list (pandoc gives a plain table here)
  return out
end

-- direct paragraph formatting (schema order: keepNext, tabs, spacing, ind, jc, sectPr last)
local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
local SINGLE_IND = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>'
local ADV_IND = '<w:spacing w:before="120" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>'
local TITLE_IND = '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>'
local COUNSEL = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="5256" w:firstLine="0"/>'
local BLANK = '<w:spacing w:before="0" w:after="0" w:line="120" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
local BLANK_12 = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
local BLANK_LINE = '<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
local CENTER_BOLD = '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>'
local CENTER_BOLD_LINE = '<w:keepNext/><w:spacing w:before="0" w:after="240" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>'
local BOLD = '<w:b/><w:bCs/>'

local PAGE_W, MARGIN_W = 12240, 1440
local PGMAR = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

-- a section break (sectPr ends a section; it goes in the pPr of the section's last paragraph)
local function sect(footer, fmt)
  local f = footer and '<w:footerReference w:type="default" r:id="rId100"/>' or ''
  local n = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ''
  return '<w:sectPr>' .. f .. PGMAR .. n .. '</w:sectPr>'
end

local function para(ppr, runs)
  return '<w:p><w:pPr>' .. (ppr or '') .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function run(text, rpr)
  return '<w:r>' .. (rpr and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
    '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function cell(width, paras_xml, borders)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or '') ..
    '</w:tcPr>' .. paras_xml .. '</w:tc>'
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>' ..
  '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(widths, rows_xml)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NO_BORDERS .. '<w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' ..
    table.concat(rows_xml) .. '</w:tbl>'
end

local function row(cells_xml)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells_xml) .. '</w:tr>'
end

-- the court title: each line bold, centered, in capitals (typst: upper())
local function court_title(meta)
  local out = {}
  for _, line in ipairs(plain_list(meta.court_name)) do
    out[#out + 1] = raw(para(CENTER_BOLD, run(line:upper(), BOLD)))
  end
  out[#out + 1] = raw(para(BLANK_12))
  return out
end

-- the caption: the parties with "v." between them; right rule and bottom rule on the party column. Right: case
-- number, chapter, adversary number (when given), the title of the paper in bold.
local function caption(meta)
  local left = {}
  local function add(s) left[#left + 1] = s and para(SINGLE, run(s)) or para(BLANK) end
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then add(nil); add("v."); add(nil) end
    for _, n in ipairs(plain_list(p.names)) do add(n) end
    add(plain(p.designation))
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local right = {}
  right[#right + 1] = para(SINGLE_IND, run("Case No. " .. plain(meta.case_number)))
  if meta.chapter ~= nil then right[#right + 1] = para(SINGLE_IND, run(plain(meta.chapter))) end
  if meta.adv_number ~= nil and plain(meta.adv_number) ~= "" then
    right[#right + 1] = para(ADV_IND, run("Adv. Proc. No. " .. plain(meta.adv_number)))
  end
  right[#right + 1] = para(TITLE_IND, run(plain(meta.brief_title), BOLD))
  local tbl = table_xml({ 4896, 360, 4104 }, {
    row({
      cell(4896, table.concat(left), rule),
      cell(360, para(SINGLE)),
      cell(4104, table.concat(right)),
    }),
  })
  return raw(tbl)
end

-- the cover: court title, caption, counsel block at the lower right; its last paragraph ends section 1 (no footer)
local function cover(meta)
  local out = court_title(meta)
  out[#out + 1] = caption(meta)
  local counsel = plain_list(meta.counsel)
  if #counsel > 0 then
    out[#out + 1] = raw(para('<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/><w:ind w:firstLine="0"/>'))
    for i, l in ipairs(counsel) do
      local ppr = COUNSEL
      if i == #counsel then ppr = ppr .. sect(false, nil) end
      out[#out + 1] = raw(para(ppr, run(l)))
    end
  else
    out[#out + 1] = raw(para(sect(false, nil)))
  end
  return out
end

-- the table of contents: every heading (levels 1 to 3) with a dot leader to its page; the last entry ends section 2
-- (roman page numbers)
local function toc(headers, pages)
  local out = { raw(para(CENTER_BOLD_LINE, run("TABLE OF CONTENTS", BOLD))) }
  for i, h in ipairs(headers) do
    local indent = (h.level - 1) * 576
    local ppr = '<w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs>' ..
      '<w:spacing w:before="120" w:after="0" w:line="276" w:lineRule="exact"/>' ..
      '<w:ind w:left="' .. (indent + 0) .. '" w:right="720" w:firstLine="0"/>'
    local page = pages and pages[i] or ""
    if i == #headers then ppr = ppr .. sect(true, "lowerRoman") end
    out[#out + 1] = raw(para(ppr, run(h.text) .. '<w:r><w:tab/></w:r>' .. run(page)))
  end
  return out
end

-- the signature block: "Dated:" at the left, the firm and "By: /s/" at the right (typst: grid 3.0 in, gutter 0.2 in)
local function signature(meta)
  local sig = meta.signature
  local right = {}
  for _, l in ipairs(plain_list(sig.firm)) do right[#right + 1] = para(SINGLE, run(l)) end
  right[#right + 1] = para(BLANK_12)
  local lines = { "By: /s/ " .. plain(sig.signer) }
  for _, l in ipairs(plain_list(sig.lines)) do lines[#lines + 1] = l end
  for _, l in ipairs(lines) do right[#right + 1] = para(SINGLE, run(l)) end
  local tbl = table_xml({ 4320, 288, 4752 }, {
    row({
      cell(4320, para(SINGLE, run("Dated: " .. plain(meta.date)))),
      cell(288, para(SINGLE)),
      cell(4752, table.concat(right)),
    }),
  })
  return { raw(para(BLANK_LINE)), raw(tbl) }
end

-- the page numbers from the first pass (one per heading, in order), or nil on the first pass
local function read_pages()
  local f = os.getenv("NYWB_TOC_PAGES")
  if f == nil or f == "" then return nil end
  local h = io.open(f, "r")
  if h == nil then return nil end
  local pages = {}
  for line in h:lines() do
    if line ~= "" then pages[#pages + 1] = line end
  end
  h:close()
  return pages
end

function Pandoc(doc)
  local meta = doc.meta
  doc.meta = pandoc.Meta({})  -- the frontmatter is laid out by this filter; pandoc must not print date or title

  local headers = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 3 then
      headers[#headers + 1] = { level = b.level, text = plain(b.content) }
    end
  end

  local out = cover(meta)
  for _, b in ipairs(toc(headers, read_pages())) do out[#out + 1] = b end

  for _, b in ipairs(doc.blocks) do
    if b.t == "BlockQuote" then
      -- single-spaced, indented both sides (the reference's Block Text style)
      out[#out + 1] = pandoc.Div(b.content, pandoc.Attr("", {}, { ["custom-style"] = "Block Text" }))
    else
      out[#out + 1] = b
    end
  end

  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  doc.blocks = out
  return doc
end
