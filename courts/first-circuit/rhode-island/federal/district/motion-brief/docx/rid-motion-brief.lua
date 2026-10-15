-- rid-motion-brief.lua (docx engine): what the Word output adds to pandoc's conversion, so the .docx has the form of
-- typst/rid-motion-brief.typ (see ../README.md "Engines"):
--   * the cover from the frontmatter: court title (two lines), the caption as a table (party column closed by a rule
--     on the right and below; "C.A. No." on the right), the title;
--   * heading labels as the typst template prints them: level 1 "I. INTRODUCTION" (roman, capitals), level 2
--     "A. Tablada's Mortgage" (letter); level 3 is printed as written;
--   * the statement on oral argument (LR Cv 7(c));
--   * the signature block (LR Cv 5(a)(5)) as a borderless table kept on one page;
--   * the certificate of service: its heading, its text, the signer's "/s/" line.
-- Pandoc does the rest: body paragraphs (first-line indent), block quotations, and footnotes (10 pt, single).
-- Nothing in this file is case-specific: every word comes from the sample's frontmatter or body.

local TEXT_W = 9360 -- 6.5 in, in twips

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI",
  "XVII", "XVIII", "XIX", "XX" }

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function str(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

-- One paragraph of single-spaced text (exact 13.8 pt); spacing in twips.
local function para(text, o)
  o = o or {}
  local x = '<w:p><w:pPr><w:pStyle w:val="SingleSpaced"/>'
  if o.keep then x = x .. "<w:keepNext/><w:keepLines/>" end
  x = x .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="276" w:lineRule="exact"/>', o.before or 0, o.after or 0)
  x = x .. '<w:jc w:val="' .. (o.jc or "left") .. '"/></w:pPr>'
  if text ~= "" then
    local rpr = ""
    if o.bold then rpr = "<w:rPr><w:b/><w:bCs/></w:rPr>" end
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

-- A borderless fixed-width table; cells are given as {width, xml, opts}; the row cannot split across pages.
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

-- An empty paragraph of the given height in twips (the typst v(...) gap).
local function spacer(line)
  return raw('<w:p><w:pPr><w:pStyle w:val="SingleSpaced"/><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="'
    .. (line or 276) .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

-- The cover: court title, caption, title of the paper (LR Cv 5(a)(1), (2)).
local function cover(m)
  local out = {}
  out[#out + 1] = raw(para("UNITED STATES DISTRICT COURT", { bold = true, jc = "center" }))
  out[#out + 1] = raw(para("FOR THE DISTRICT OF RHODE ISLAND", { bold = true, jc = "center", after = 432 }))

  local left = ""
  for k, p in ipairs(m.caption.parties) do
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

-- The signature block (LR Cv 5(a)(5)): "Dated" at the left; the lead line ("Respectfully submitted by,"), the party
-- lines, the signers with "/s/" and bar numbers, then the firm block. One row, kept on one page.
local function signature(m)
  local sig = m.signature
  local right = ""
  if sig.lead ~= nil then
    right = right .. para(str(sig.lead)) .. gap(156)
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

-- The statement on oral argument (LR Cv 7(c)): "requested" with the estimated time, or "not requested".
local function oral_argument(m)
  local oa = m.oral_argument
  local statement
  if oa.requested == true then
    statement = "Oral argument and evidentiary hearing are requested"
    if oa.minutes ~= nil then statement = statement .. "; the estimated time is " .. str(oa.minutes) .. " minutes." else statement = statement .. "." end
  else
    statement = "Oral argument and evidentiary hearing are not requested."
  end
  local content = { pandoc.Strong({ pandoc.Str("Statement"), pandoc.Space(), pandoc.Str("on"), pandoc.Space(),
    pandoc.Str("oral"), pandoc.Space(), pandoc.Str("argument.") }), pandoc.Space() }
  for _, i in ipairs(pandoc.read(statement, "markdown").blocks[1].content) do content[#content + 1] = i end
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { { "custom-style", "Keep Together" } }))
end

-- The certificate of service (LR Cv 5(a)(5)): its heading, the text from the frontmatter, the signer's "/s/" line.
local function certificate(m)
  local cos = m.certificate_of_service
  local signer = m.signature.signers[1]
  local out = {}
  out[#out + 1] = spacer(376)
  out[#out + 1] = raw(para("CERTIFICATE OF SERVICE", { bold = true, jc = "center", keep = true, after = 56, before = 0 }))
  for _, b in ipairs(pandoc.read(str(cos.text), "markdown").blocks) do
    out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { { "custom-style", "Keep Together" } }))
  end
  local bar = signer.bar and str(signer.bar) or ""
  local block = para("/s/ " .. str(signer.name)) .. para(bar ~= "" and (str(signer.name) .. " " .. bar) or str(signer.name))
  out[#out + 1] = raw(table_of({ 4176, 288, 4896 }, {
    { 4176, para(""), nil },
    { 288, para(""), nil },
    { 4896, block, nil },
  }))
  return out
end

-- Heading labels, as the typst template prints them.
local counts = { 0, 0 }
local function label_heading(el)
  if el.level == 1 then
    counts[1] = counts[1] + 1
    counts[2] = 0
    local text = pandoc.text.upper(str(el.content))
    el.content = { pandoc.Str(ROMAN[counts[1]] .. "."), pandoc.Space(), pandoc.Str(text) }
  elseif el.level == 2 then
    counts[2] = counts[2] + 1
    local letter = string.char(64 + counts[2])
    table.insert(el.content, 1, pandoc.Space())
    table.insert(el.content, 1, pandoc.Str(letter .. "."))
  end
  return el
end

function Pandoc(doc)
  -- pandoc would print date, title and author itself, above the cover; the cover is built here from the same
  -- values, so the writer gets empty metadata.
  local m = doc.meta
  doc.meta = pandoc.Meta({})
  assert(m.caption and m.caption.parties, "rid-motion-brief.lua: the sample needs caption.parties")
  assert(m.brief_title, "rid-motion-brief.lua: the sample needs brief_title")
  assert(m.signature, "rid-motion-brief.lua: the sample needs a signature block")
  assert(m.oral_argument, "rid-motion-brief.lua: the sample needs oral_argument (LR Cv 7(c))")

  local out = cover(m)
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = label_heading(b)
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = oral_argument(m)
  for _, b in ipairs(signature(m)) do out[#out + 1] = b end
  if m.certificate_of_service ~= nil then
    for _, b in ipairs(certificate(m)) do out[#out + 1] = b end
  end
  out[#out + 1] = raw(para(""))
  doc.blocks = out
  return doc
end
