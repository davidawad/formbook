-- nyed complaint, DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/nyed-complaint.typ. Counsel block, court name, caption (a ruled table), title, lead-in,
-- signature block and the page-number footer are built here; the body keeps its markdown structure.
-- Numbered allegations: each body paragraph gets its number as text (style Numbered: number at 0.5 in,
-- tab to 1 in, continuation lines at the margin). The prayer items are lettered in a label column.
-- No case-specific text in this file: everything comes from the frontmatter of the sample.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function rpr(f)
  return (f.b and "<w:b/><w:bCs/>" or "") .. (f.i and "<w:i/><w:iCs/>" or "")
end

local function run(text, f)
  f = f or {}
  if f.up then text = string.upper(text) end
  local p = rpr(f)
  local rp = p ~= "" and ("<w:rPr>" .. p .. "</w:rPr>") or ""
  return "<w:r>" .. rp .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- inlines -> runs (bold, italic, curly quotes, line breaks)
local runs
runs = function(inls, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then
      out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, { b = f.b, i = true, up = f.up })
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = f.i, up = f.up })
    elseif t == "Quoted" then
      local o, c = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then o, c = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(o, f) .. runs(el.content, f) .. run(c, f)
    elseif el.content then
      out[#out + 1] = runs(el.content, f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

-- pandoc 3 exposes metadata as plain Lua values: a string, a list (a table of values with no .t), inlines
-- (a table whose items have .t, e.g. Str) or blocks (items with .t Para or Plain).
local function is_list(v)
  return type(v) == "table" and v.t == nil and #v > 0 and type(v[1]) == "table" and v[1].t == nil
end

local function mx(v, f)
  if v == nil then return "" end
  if type(v) == "string" then return run(v, f) end
  if v.t == "MetaInlines" then return runs(v, f) end
  if v.t == "MetaString" then return run(v.text or pandoc.utils.stringify(v), f) end
  if v[1] and (v[1].t == "Para" or v[1].t == "Plain") then
    local o = {}
    for _, b in ipairs(v) do
      if b.content then o[#o + 1] = runs(b.content, f) end
    end
    return table.concat(o)
  end
  return runs(v, f)
end

-- a metadata list (or a single value) as a Lua list
local function list(v)
  if v == nil then return {} end
  if is_list(v) then return v end
  return { v }
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("nyed-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- paragraph XML: style, run XML, and the pPr children (already in schema order after pStyle)
local function p(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (inner or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function gap(twips)
  return p("Single", "", '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/>')
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- the caption: a two-column table, the party column ruled above and below (Fed. R. Civ. P. 10(a))
local function caption_table(left_xml, right_xml)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/><w:tcBorders>'
    .. '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. "</w:tcBorders></w:tcPr>" .. left_xml .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/><w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. right_xml .. "</w:tc></w:tr></w:tbl>"
end

local function caption_xml(meta)
  local sides = list(need(meta, "caption"))
  local left = {}
  for i, side in ipairs(sides) do
    if i > 1 then
      left[#left + 1] = p("Single", run("-against-"), '<w:spacing w:before="240" w:after="240"/><w:ind w:left="1728"/>')
    end
    local names = list(side.names)
    for j, n in ipairs(names) do
      local ppr = nil
      if i == 1 and j == 1 then ppr = '<w:spacing w:before="168"/>' end
      left[#left + 1] = p("Single", mx(n), ppr)
    end
    local last = (i == #sides)
    left[#left + 1] = p("Single", mx(side.designation),
      (last and '<w:spacing w:after="180"/>' or "") .. '<w:ind w:left="2736"/>')
  end
  local right = { p("Single", run("Docket No. ") .. mx(need(meta, "case_number"))) }
  if meta.jury_demand and meta.jury_demand == true then
    right[#right + 1] = p("Single", run("JURY TRIAL DEMANDED", { b = true }), '<w:spacing w:before="240"/>')
  end
  return caption_table(table.concat(left), table.concat(right))
end

-- the counsel block (top left), the court name (centered, bold capitals), the title
local function front_matter(meta)
  local out = {}
  for _, l in ipairs(list(meta.counsel)) do
    out[#out + 1] = p("Single", mx(l))
  end
  if meta.counsel then out[#out + 1] = gap(480) end
  for _, l in ipairs(list(need(meta, "court"))) do
    out[#out + 1] = p("Centered", mx(l, { b = true, up = true }))
  end
  out[#out + 1] = gap(480)
  out[#out + 1] = raw(caption_xml(meta))
  out[#out + 1] = gap(480)
  out[#out + 1] = p("Centered", mx(need(meta, "title"), { b = true, up = true }), '<w:spacing w:after="240"/>')
  return out
end

-- the signature block: "Dated:" at left, the signer at right (LCR-independent, Fed. R. Civ. P. 11(a))
local function signature_xml(meta)
  local sig = need(meta, "signature")
  local right = { p("Single", run("Respectfully submitted,")) }
  right[#right + 1] = p("Single", run("By: /s/ ") .. mx(sig.signer), '<w:spacing w:before="480"/>')
  for _, l in ipairs(list(sig.lines)) do
    right[#right + 1] = p("Single", mx(l))
  end
  local left = p("Single", run("Dated: ") .. mx(need(meta, "date")))
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="4608"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/></w:tcPr>' .. left .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. "</w:tc>"
    .. "</w:tr></w:tbl>"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = front_matter(meta)

  if meta.lead_in then
    out[#out + 1] = p("BodyText", mx(meta.lead_in))
  end

  -- the body: numbered paragraphs, headings, lettered prayer items
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local text = pandoc.utils.stringify(b)
      if text:match("^WHEREFORE") then
        out[#out + 1] = b
      else
        n = n + 1
        local inl = { pandoc.Str(tostring(n) .. "."), TAB }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
      end
    elseif b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        local inl = { pandoc.Str(string.char(64 + i) .. "."), TAB }
        for _, x in ipairs(first.content) do inl[#inl + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Prayer" }))
      end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = gap(480)
  out[#out + 1] = signature_xml(meta)
  -- XML strings from p(), gap() and the tables become raw OpenXML blocks; pandoc blocks pass through
  for i, x in ipairs(out) do
    if type(x) == "string" then out[i] = raw(x) end
  end
  return pandoc.Pandoc(out)
end
