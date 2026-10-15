-- scd-complaint.lua (docx engine). Builds from the sample's frontmatter what typst/scd-complaint.typ builds:
-- the court heading, the caption table (parties, a column of ")" marks, the case number), the document title and the
-- signature block. Every string comes from the frontmatter; nothing case-specific is written in this file.
-- pandoc has no OOXML writer for inlines in this build, so runs are written here (Str, Space, Emph, Strong, Quoted).

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function rpr(f)
  local s = ""
  if f.b then s = s .. "<w:b /><w:bCs />" end
  if f.i then s = s .. "<w:i /><w:iCs />" end
  if s == "" then return "" end
  return "<w:rPr>" .. s .. "</w:rPr>"
end

local function text_run(t, f)
  return '<w:r>' .. rpr(f) .. '<w:t xml:space="preserve">' .. esc(t) .. '</w:t></w:r>'
end

local function runs(inls, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = text_run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = text_run(" ", f)
    elseif t == "LineBreak" then
      out[#out + 1] = "<w:r><w:br /></w:r>"
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, { b = f.b, i = true })
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = f.i })
    elseif t == "Quoted" then
      local o, c = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then o, c = "\u{2018}", "\u{2019}" end
      out[#out + 1] = text_run(o, f) .. runs(el.content, f) .. text_run(c, f)
    elseif t == "Span" or t == "Link" then
      out[#out + 1] = runs(el.content, f)
    else
      out[#out + 1] = text_run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

-- a metadata value (markdown-parsed MetaInlines, or a plain Lua string) as inlines
local function inlines_of(x)
  if type(x) == "string" then
    return pandoc.utils.blocks_to_inlines(pandoc.read(x, "markdown+smart").blocks)
  end
  return x
end

-- a paragraph; ppr holds the direct paragraph properties, in schema order (spacing before ind before jc)
local function para(style, body, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '" />' .. (ppr or "") .. '</w:pPr>' .. body .. '</w:p>'
end

local function spacing(before, after)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" />'
end

-- a borderless fixed-width table with one row of cells; widths in twips
local function table_xml(grid, cells)
  local cols, total = {}, 0
  for _, w in ipairs(grid) do
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '" />'
    total = total + w
  end
  local tcs = {}
  for i, w in ipairs(grid) do
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa" /></w:tcPr>' .. cells[i] .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa" />'
    .. '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" />'
    .. '<w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit /></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function caption(meta)
  local left, mid = {}, {}
  local n = #meta.parties
  for i, p in ipairs(meta.parties) do
    local ind = tonumber(pandoc.utils.stringify(p.indent)) or 0
    local after = (i < n) and 97 or 0 -- row pitch about 18.7 pt, as the typst caption
    left[#left + 1] = para("CaptionText", runs(inlines_of(p.text)),
      spacing(0, after) .. '<w:ind w:left="' .. (ind * 720) .. '" />')
    mid[#mid + 1] = para("CaptionText", text_run(")", {}),
      spacing(0, after) .. '<w:jc w:val="center" />')
  end
  local case = { pandoc.Str("CASE"), pandoc.Space(), pandoc.Str("NO.:"), pandoc.Space() }
  for _, el in ipairs(inlines_of(meta.case_number)) do case[#case + 1] = el end
  local right = { para("CaptionText", runs(case), spacing(0, 0)) }
  return table_xml({ 5184, 432, 3744 }, {
    table.concat(left), table.concat(mid), table.concat(right),
  })
end

local function signature(meta)
  local s = meta.signature
  local left = { para("SignatureText", runs(inlines_of(s.dated)), spacing(360, 0)) }
  local right = {
    para("SignatureText", text_run("Respectfully submitted,", {}), spacing(360, 0)),
    para("SignatureText", text_run("s/ ", {}) .. runs(inlines_of(s.signer)), spacing(144, 0)),
  }
  for _, l in ipairs(s.lines) do
    right[#right + 1] = para("SignatureText", runs(inlines_of(l)), spacing(0, 0))
  end
  return table_xml({ 4752, 4608 }, { table.concat(left), table.concat(right) })
end

function Pandoc(doc)
  local m = doc.meta
  local front = {}
  local n = #m.court
  for i, line in ipairs(m.court) do
    front[#front + 1] = para(i == n and "CourtHeadingLast" or "CourtHeading", runs(inlines_of(line)))
  end
  local head = table.concat(front) .. caption(m)
    .. para("DocumentTitle", runs(inlines_of(m.doc_title)))
  local blocks = { pandoc.RawBlock("openxml", head) }
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", signature(m))
  return pandoc.Pandoc(blocks, m)
end
