-- W.D.N.Y. adversary complaint, DOCX engine (docs/DOCX.md). Mirrors typst/nywb-adversary-complaint.typ:
-- the cover (court title, caption grid, title of the pleading), the lead-in, numbered allegations (Civil Rule 10(b)),
-- headings, block quotations, the lettered prayer and the signature block. Every case-specific word comes from the
-- sample's frontmatter. Paragraphs that pandoc writes (body, headings, numbered allegations, prayer, block quotes) take
-- their styles from build-reference.sh. The cover and signature are raw OpenXML tables; their paragraphs carry direct
-- formatting, because pandoc drops reference styles that the document body does not use (a raw paragraph that names
-- an unknown style makes LibreOffice stack the table cells).

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

-- direct paragraph formatting (schema order: keepNext, spacing, ind, jc)
local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
local SINGLE_IND = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>'
local GAP_IND = '<w:spacing w:before="120" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>'
local BLANK = '<w:spacing w:before="0" w:after="0" w:line="120" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
local BLANK_12 = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
local CENTER_BOLD = '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>'
local BOLD = '<w:b/><w:bCs/>'

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
local function cover_title(meta)
  local out = {}
  for _, line in ipairs(plain_list(meta.court_name)) do
    out[#out + 1] = raw(para(CENTER_BOLD, run(line:upper(), BOLD)))
  end
  out[#out + 1] = raw(para(BLANK_12))
  return out
end

-- the caption: the debtor (In re:) then the adversary parties with "vs."; right rule and bottom rule on the party
-- column. Right: case number, chapter, judge; adversary number (blank line if none); the title in bold.
local function caption(meta)
  local left = {}
  local function add(s) left[#left + 1] = s and para(SINGLE, run(s)) or para(BLANK) end
  if meta.debtor ~= nil then
    add("In re:")
    add(nil)
    for _, n in ipairs(plain_list(meta.debtor.names)) do add(n) end
    add(plain(meta.debtor.designation))
    add(nil)
  end
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then add(nil); add("vs."); add(nil) end
    for _, n in ipairs(plain_list(p.names)) do add(n) end
    add(plain(p.designation))
  end
  -- schema order inside tcBorders: bottom before right
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local right = {}
  right[#right + 1] = para(SINGLE_IND, run("Case No. " .. plain(meta.case_number)))
  if meta.chapter ~= nil then right[#right + 1] = para(SINGLE_IND, run(plain(meta.chapter))) end
  if meta.judge ~= nil then right[#right + 1] = para(SINGLE_IND, run("Hon. " .. plain(meta.judge))) end
  local adv = (meta.adv_number ~= nil and plain(meta.adv_number) ~= "") and plain(meta.adv_number) or "__________"
  right[#right + 1] = para(GAP_IND, run("Adv. Pro. No. " .. adv))
  right[#right + 1] = para(GAP_IND, run(plain(meta.brief_title), BOLD))
  local tbl = table_xml({ 4896, 360, 4104 }, {
    row({
      cell(4896, table.concat(left), rule),
      cell(360, para(SINGLE)),
      cell(4104, table.concat(right)),
    }),
  })
  return { raw(tbl) }
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
  return { raw(para('<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/>')), raw(tbl) }
end

-- a paragraph with a literal label (paragraph number or prayer letter), a tab, then its inlines
local function labelled(label, inlines, style)
  local inl = { pandoc.Str(label), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
  for _, x in ipairs(inlines) do inl[#inl + 1] = x end
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

function Pandoc(doc)
  local meta = doc.meta
  doc.meta = pandoc.Meta({})  -- the frontmatter is laid out by this filter; pandoc must not print date or title

  local out = {}
  for _, b in ipairs(cover_title(meta)) do out[#out + 1] = b end
  for _, b in ipairs(caption(meta)) do out[#out + 1] = b end
  out[#out + 1] = raw(para('<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/>'))

  if meta.lead_in ~= nil then
    out[#out + 1] = pandoc.Para(pandoc.read(plain(meta.lead_in), "markdown").blocks[1].content)
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local first = b.content[1]
      if first and first.t == "Str" and first.text:match("^WHEREFORE") then
        out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Lead" }))
      else
        n = n + 1
        out[#out + 1] = labelled(n .. ".", b.content, "Allegation")
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local inl = {}
        local first = item[1]
        if first and (first.t == "Plain" or first.t == "Para") then
          inl = first.content
        end
        out[#out + 1] = labelled(string.char(64 + i) .. ".", inl, "Prayer")
      end
    elseif b.t == "BlockQuote" then
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
