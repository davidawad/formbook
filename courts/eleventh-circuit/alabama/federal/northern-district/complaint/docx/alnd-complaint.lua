-- alnd complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The court heading, caption, title, numbered paragraphs, lettered prayer items, headings and signature block
-- follow typst/alnd-complaint.typ and are built here in the styles of reference.docx (make-reference.sh).
-- Numbering: a body paragraph is numbered from 1 unless it starts with {unnumbered} or {centered}; a list is
-- lettered A., B., ... (the same rules as the typst template's `allegations`).
-- Known limits (see README.md "Engines"): the caption and signature grid are Word tables built from the
-- plain text of their entries (no italics inside them); the page numbers are the PAGE field of the reference.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function xesc(s)
  local out = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return out
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value as inlines (markdown already parsed by pandoc)
local function inlines(v)
  if v == nil then return pandoc.List({}) end
  if v.t == "MetaInlines" then return pandoc.List(v) end
  return pandoc.List({ pandoc.Str(text(v)) })
end

local function para(style, content)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- an empty paragraph of the given style (pandoc drops an empty Para, so it is written as raw XML)
local function blank(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

local function upper_inlines(content)
  local out = pandoc.List({})
  for _, el in ipairs(content) do
    if el.t == "Str" then out:insert(pandoc.Str(el.text:upper())) else out:insert(el) end
  end
  return out
end

-- one paragraph of a Word table cell (raw XML): plain text, styled by the reference's styles
local function cell_p(style, s, ppr)
  local run = s ~= "" and ('<w:r><w:t xml:space="preserve">' .. xesc(s) .. "</w:t></w:r>") or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. run .. "</w:p>"
end

local NONE = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
  .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'

local function table_xml(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>' .. NONE .. '</w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(rows) .. '</w:tr></w:tbl>'
end

-- caption (typst: a party column with a right and bottom rule, and the case number beside it)
local function caption_xml(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = cell_p("Single", "v.", '<w:jc w:val="center"/>') end
    for _, n in ipairs(p.names) do left[#left + 1] = cell_p("Single", text(n)) end
    left[#left + 1] = cell_p("Single", text(p.designation), '<w:ind w:left="2592"/>')
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local c1 = '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/>' .. rule
    .. '<w:tcMar><w:right w:w="312" w:type="dxa"/><w:bottom w:w="260" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
  local c2 = '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/><w:tcMar><w:left w:w="312" w:type="dxa"/>'
    .. '<w:top w:w="198" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. cell_p("Single", "Case No.: " .. text(meta.case_number), '<w:spacing w:before="78"/>') .. "</w:tc>"
  return table_xml({ 4608, 4752 }, { c1, c2 })
end

-- signature: the firms side by side (typst: grid with a 0.3 in gutter), each line one paragraph
local function signature_grid(firms)
  local n = #firms
  local gutter = 432
  local w = math.floor((9360 - gutter * (n - 1)) / n)
  local cells, widths = {}, {}
  for i, lines in ipairs(firms) do
    local ps = {}
    for _, l in ipairs(lines) do
      local s = text(l)
      if s == "" then ps[#ps + 1] = '<w:p><w:pPr><w:pStyle w:val="Gap26"/></w:pPr></w:p>'
      else ps[#ps + 1] = cell_p("Signature", s) end
    end
    local mar = i < n and ('<w:tcMar><w:right w:w="' .. gutter .. '" w:type="dxa"/></w:tcMar>') or ""
    cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. mar .. '</w:tcPr>'
      .. table.concat(ps) .. "</w:tc>"
    widths[#widths + 1] = w
  end
  return table_xml(widths, cells)
end

local function signature_blocks(meta)
  local sig = meta.signature
  local out = {}
  out[#out + 1] = blank("Gap24Keep")
  out[#out + 1] = para("Signature", inlines(meta.date_line))
  out[#out + 1] = blank("Gap24Keep")
  local firms = {}
  for _, f in ipairs(sig.firms) do firms[#firms + 1] = f end
  out[#out + 1] = pandoc.RawBlock("openxml", signature_grid(firms))
  out[#out + 1] = blank("Gap24Keep")
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = para("Signature", inlines(l)) end
  return out
end

-- body: the numbered paragraphs, the lettered list, the headings and the centered and unnumbered lines
local function body_blocks(blocks)
  local out = {}
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level > 3 then error("alnd-complaint: headings deeper than level 3 are not in the template", 0) end
      out[#out + 1] = b
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and (string.char(64 + i) .. ".") or "\u{2022}"
        local first = true
        for _, ib in ipairs(item) do
          local content = (ib.t == "Plain" or ib.t == "Para") and ib.content or pandoc.List({})
          if first then
            local c = pandoc.List({ pandoc.Str(label), TAB })
            c:extend(content)
            out[#out + 1] = para("ListLetter", c)
            first = false
          else
            out[#out + 1] = para("ListLetter", content)
          end
        end
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      local head = c[1]
      if head and head.t == "Str" and head.text == "{unnumbered}" then
        local rest = pandoc.List({})
        for i = 2, #c do rest:insert(c[i]) end
        if rest[1] and rest[1].t == "Space" then rest:remove(1) end
        out[#out + 1] = para("Unnumbered", rest)
      elseif head and head.t == "Str" and head.text == "{centered}" then
        local rest = pandoc.List({})
        for i = 2, #c do rest:insert(c[i]) end
        if rest[1] and rest[1].t == "Space" then rest:remove(1) end
        out[#out + 1] = para("Centered", rest)
      else
        n = n + 1
        local content = pandoc.List({ TAB, pandoc.Str(tostring(n)), TAB })
        content:extend(c)
        out[#out + 1] = para("Numbered", content)
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "caption", "brief_title", "case_number", "signature", "date_line" }) do
    if meta[k] == nil then error("alnd-complaint: missing required metadata field `" .. k .. "`", 0) end
  end

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court heading, caption, title (typst: court-title, caption, heading-block)
  for _, l in ipairs(meta.court) do add(para("CourtTitle", inlines(l))) end
  add(blank("GapCaption"))
  add(pandoc.RawBlock("openxml", caption_xml(meta)))
  add(blank("GapCaption"))
  add(para("Centered", { pandoc.Strong(upper_inlines(inlines(meta.brief_title))) }))

  if meta.lead_in then add(para("Unnumbered", inlines(meta.lead_in))) end

  for _, b in ipairs(body_blocks(doc.blocks)) do add(b) end
  for _, b in ipairs(signature_blocks(meta)) do add(b) end

  doc.blocks = out
  return doc
end
