-- rid-complaint.lua (docx engine): what the Word output adds to pandoc's conversion, so the .docx has the form of
-- typst/rid-complaint.typ (see ../README.md "Engines"):
--   * the cover from the frontmatter: court title (two lines), the caption as a table (party column closed by a rule
--     on the right and below; "C.A. No." and the jury demand on the right), the title;
--   * the allegations numbered 1., 2., ... (Fed. R. Civ. P. 10(b)) by typed label and a tab; the WHEREFORE prayer
--     and the headings are not numbered;
--   * the signature block (LR Cv 5(a)(5)) as a borderless table, kept on one page.
-- Nothing in this file is case-specific: every word comes from the sample's frontmatter or body.

local TEXT_W = 9360 -- 6.5 in, in twips

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function str(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

-- One paragraph of single-spaced text (exact 13.8 pt), with optional bold, italic and spacing in points*20.
local function para(text, o)
  o = o or {}
  local x = '<w:p><w:pPr><w:pStyle w:val="SingleSpaced"/>'
  if o.keep then x = x .. "<w:keepNext/><w:keepLines/>" end
  x = x .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="276" w:lineRule="exact"/>', o.before or 0, o.after or 0)
  x = x .. '<w:jc w:val="' .. (o.jc or "left") .. '"/></w:pPr>'
  if text ~= "" then
    local rpr = ""
    if o.bold or o.italic then
      rpr = "<w:rPr>" .. (o.bold and "<w:b/><w:bCs/>" or "") .. (o.italic and "<w:i/><w:iCs/>" or "") .. "</w:rPr>"
    end
    x = x .. "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return x .. "</w:p>"
end

local function cell(w, content, o)
  o = o or {}
  local x = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>'
  if o.borders then x = x .. "<w:tcBorders>" .. o.borders .. "</w:tcBorders>" end
  if o.mar then x = x .. "<w:tcMar>" .. o.mar .. "</w:tcMar>" end
  x = x .. '<w:vAlign w:val="top"/></w:tcPr>'
  return x .. content .. "</w:tc>"
end

-- A borderless fixed-width table; cells are given as {width, xml, opts} and the row cannot split across pages.
local function table_of(cols, cells)
  local grid = ""
  for _, c in ipairs(cols) do grid = grid .. '<w:gridCol w:w="' .. c .. '"/>' end
  local nb = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  local row = ""
  for i, c in ipairs(cells) do row = row .. cell(cols[i], c[2], c[3]) end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. "<w:tblBorders>" .. nb .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. "<w:tblGrid>" .. grid .. "</w:tblGrid>"
    .. "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. row .. "</w:tr></w:tbl>"
end

local function raw(x) return pandoc.RawBlock("openxml", x) end

-- A gap of the given height in twips, as a paragraph inside a table cell (the typst v(...) inside a column).
local function gap(twips)
  return '<w:p><w:pPr><w:pStyle w:val="SingleSpaced"/><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function spacer(line)
  return raw('<w:p><w:pPr><w:pStyle w:val="SingleSpaced"/><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="'
    .. (line or 276) .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

-- The cover: court title, caption, title of the paper (LR Cv 5(a)(1), (2), (4)).
local function cover(m)
  local out = {}
  out[#out + 1] = raw(para("UNITED STATES DISTRICT COURT", { bold = true, jc = "center" }))
  out[#out + 1] = raw(para("FOR THE DISTRICT OF RHODE ISLAND", { bold = true, jc = "center", after = 432 }))

  local left = ""
  local parties = m.caption.parties
  for k, p in ipairs(parties) do
    if k > 1 then left = left .. para("v.") end
    for _, name in ipairs(p.names) do left = left .. para(str(name)) end
    left = left .. para(str(p.designation))
  end
  local number = str(m.case_number)
  number = number ~= "" and ("C.A. No. " .. number) or "C.A. No. ______________"
  local right = para(number)
  if m.jury_demand == true then right = right .. para("JURY TRIAL DEMANDED", { bold = true, before = 432 }) end
  local rule = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  local lmar = '<w:bottom w:w="173" w:type="dxa"/><w:right w:w="173" w:type="dxa"/>'
  out[#out + 1] = raw(table_of({ 4896, 360, 4104 }, {
    { 4896, left, { borders = rule, mar = lmar } },
    { 360, para(""), nil },
    { 4104, right, { mar = '<w:left w:w="144" w:type="dxa"/>' } },
  }))
  out[#out + 1] = raw(para(str(m.brief_title), { bold = true, jc = "center", before = 416, after = 0 }))
  out[#out + 1] = spacer(212)
  return out
end

-- The signature block (LR Cv 5(a)(5)): "Dated" at the left, the party line, the signers with "/s/" and bar
-- numbers, then the firm block. One row, kept on one page.
local function signature(m)
  local sig = m.signature
  local right = ""
  if sig.lead ~= nil then
    right = right .. para(str(sig.lead)) .. para("", { before = 0 })
  end
  for _, line in ipairs(sig.party) do right = right .. para(str(line)) end
  right = right .. gap(156)
  local rows = {}
  for _, s in ipairs(sig.signers) do
    local bar = s.bar and str(s.bar) or ""
    rows[#rows + 1] = para("/s/ " .. str(s.name))
    rows[#rows + 1] = para(bar ~= "" and (str(s.name) .. " " .. bar) or str(s.name))
    rows[#rows + 1] = gap(120)
  end
  if #rows > 0 then table.remove(rows) end
  for _, r in ipairs(rows) do right = right .. r end
  right = right .. gap(156)
  for _, line in ipairs(sig.firm) do right = right .. para(str(line)) end
  local dated = (m.date ~= nil) and para("Dated: " .. str(m.date)) or para("")
  return {
    spacer(376),
    raw(table_of({ 4176, 288, 4896 }, {
      { 4176, dated, nil },
      { 288, para(""), nil },
      { 4896, right, nil },
    })),
  }
end

local function is_wherefore(b)
  return b.t == "Para" and str(b):sub(1, 9) == "WHEREFORE"
end

function Pandoc(doc)
  -- pandoc would print date, title and author itself, above the cover; the cover is built here from the same
  -- values, so the writer gets empty metadata.
  local m = doc.meta
  doc.meta = pandoc.Meta({})
  assert(m.caption and m.caption.parties, "rid-complaint.lua: the sample needs caption.parties")
  assert(m.brief_title, "rid-complaint.lua: the sample needs brief_title")
  assert(m.signature, "rid-complaint.lua: the sample needs a signature block")

  local out = cover(m)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and not is_wherefore(b) then
      n = n + 1
      local content = { pandoc.Str(tostring(n) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
      for _, i in ipairs(b.content) do content[#content + 1] = i end
      out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { { "custom-style", "Numbered Paragraph" } }))
    else
      out[#out + 1] = b
    end
  end
  for _, b in ipairs(signature(m)) do out[#out + 1] = b end
  out[#out + 1] = raw(para(""))
  doc.blocks = out
  return doc
end
