-- ncmd-complaint.lua (docx engine). Builds what pandoc cannot read from the frontmatter, in the form of
-- typst/ncmd-complaint.typ: the cover (court title, caption table with the rules that close the party column),
-- the numbered allegations (FRCP 10(b): "N." and a tab, the prayer and any section in unnumbered_sections are not
-- numbered), the sign-off line and the signature block (LR 7.1(b)). No case-specific text is written here: every
-- string comes from the frontmatter of the sample.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function R(text, rpr)
  local pr = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. pr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end
local BR = "<w:r><w:br/></w:r>"
local TAB = "<w:r><w:tab/></w:r>"
local function P(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (inner or "") .. "</w:p>"
end
local function TC(width, borders, mar, inner)
  local b = borders and ("<w:tcBorders>" .. borders .. "</w:tcBorders>") or ""
  local m = mar and ("<w:tcMar>" .. mar .. "</w:tcMar>") or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. b .. m .. "</w:tcPr>" .. inner .. "</w:tc>"
end
local function TBL(cols, rows)
  local sum, grid = 0, ""
  for _, c in ipairs(cols) do
    sum = sum + c
    grid = grid .. '<w:gridCol w:w="' .. c .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. sum .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. "</w:tblPr><w:tblGrid>" .. grid .. "</w:tblGrid><w:tr>" .. rows .. "</w:tr></w:tbl>"
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("ncmd-complaint.lua: missing required metadata field `" .. key .. "`") end
  return v
end
local function str(v)
  return pandoc.utils.stringify(v)
end
local function strs(list)
  local out = {}
  for _, v in ipairs(list) do out[#out + 1] = str(v) end
  return out
end

local RULE_BOTTOM_RIGHT = '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(meta)
  local out = {}
  for _, l in ipairs(strs(need(meta, "court"))) do
    out[#out + 1] = P("CoverTitle", R(l:upper(), "<w:b/><w:bCs/>"))
  end
  if meta.division ~= nil then
    out[#out + 1] = P("Normal", "")
    out[#out + 1] = P("CoverTitle", R(str(meta.division):upper(), "<w:b/><w:bCs/>"))
  end
  out[#out + 1] = P("Normal", "")

  -- caption: party column (3.4 in, closed by a right and a bottom rule), case block (rest of the width)
  local left = {}
  local sides = need(meta, "caption").parties
  for i, side in ipairs(sides) do
    for _, n in ipairs(strs(side.names)) do
      left[#left + 1] = P("SingleSpaced", R(n))
    end
    left[#left + 1] = P("SingleSpaced", R(str(side.designation)), '<w:ind w:left="1728" w:firstLine="0"/>')
    if i < #sides then
      left[#left + 1] = P("SingleSpaced", R("v."), '<w:spacing w:before="230" w:after="230" w:line="420" w:lineRule="exact"/><w:jc w:val="center"/>')
    end
  end
  local right = {}
  right[#right + 1] = P("CaptionText", R("Civil Action No. " .. str(need(meta, "case_number"))))
  right[#right + 1] = P("CaptionText", R(str(need(meta, "brief_title")):upper(), "<w:b/><w:bCs/>"), '<w:spacing w:before="230" w:after="0" w:line="420" w:lineRule="exact"/>')
  if meta.jury_demand == true then
    right[#right + 1] = P("CaptionText", R("(Jury Trial Demanded)"), '<w:spacing w:before="230" w:after="0" w:line="420" w:lineRule="exact"/>')
  end
  out[#out + 1] = TBL({ 4896, 4464 },
    TC(4896, RULE_BOTTOM_RIGHT, '<w:right w:w="288" w:type="dxa"/><w:bottom w:w="230" w:type="dxa"/>', table.concat(left))
    .. TC(4464, nil, '<w:left w:w="312" w:type="dxa"/>', table.concat(right)))
  out[#out + 1] = P("Normal", "")
  return pandoc.RawBlock("openxml", table.concat(out))
end

local function signature(meta)
  local sig = need(meta, "signature")
  local parts = {}
  parts[#parts + 1] = P("SingleSpaced", R("This the " .. str(need(meta, "date_line"))), '<w:keepNext/><w:spacing w:before="460" w:after="0" w:line="420" w:lineRule="exact"/>')
  parts[#parts + 1] = P("SignatureBlock", R(str(sig.firm)), '<w:spacing w:before="460" w:after="0" w:line="420" w:lineRule="exact"/>')
  local line = R("/s/ " .. str(sig.signer)) .. BR .. R(str(sig.signer)) .. BR .. R(str(sig.bar_number))
  for _, l in ipairs(strs(sig.address)) do
    line = line .. BR .. R(l)
  end
  line = line .. BR .. R(str(sig.phone)) .. BR .. R(str(sig.email))
  parts[#parts + 1] = P("SignatureBlock", line, '<w:spacing w:before="230" w:after="0" w:line="420" w:lineRule="exact"/>')
  parts[#parts + 1] = P("SignatureBlock", R(str(sig.role), "<w:i/><w:iCs/>"), '<w:spacing w:before="230" w:after="0" w:line="420" w:lineRule="exact"/>')
  return pandoc.RawBlock("openxml", table.concat(parts))
end

local function unnumbered_set(meta)
  local set = {}
  if meta.unnumbered_sections ~= nil then
    for _, s in ipairs(strs(meta.unnumbered_sections)) do set[s:upper()] = true end
  end
  return set
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "brief_title", "date_line", "signature" }) do
    need(meta, k)
  end
  local unnum = unnumbered_set(meta)
  local blocks = { cover(meta) }
  local numbered, n = true, 0
  -- the prayer (the last section) is kept with the signature block: every block from its heading on keeps with the next
  local last_h1 = 0
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then last_h1 = i end
  end
  for i, b in ipairs(doc.blocks) do
    if i >= last_h1 and last_h1 > 0 and (b.t == "Para" or b.t == "Plain" or b.t == "OrderedList" or b.t == "BulletList") then
      b = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Keep Next Body" }))
    end
    if b.t == "Header" and b.level == 1 then
      numbered = not unnum[str(b.content):upper()]
      blocks[#blocks + 1] = b
    elseif b.t == "Para" and numbered then
      n = n + 1
      table.insert(b.content, 1, pandoc.RawInline("openxml", R(n .. ".") .. TAB))
      if str(b):sub(-1) == ":" then
        -- a paragraph that introduces a list stays with the list
        b = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Keep Next Body" }))
      end
      blocks[#blocks + 1] = b
    else
      blocks[#blocks + 1] = b
    end
  end
  blocks[#blocks + 1] = signature(meta)
  doc.blocks = pandoc.List(blocks)
  doc.meta = pandoc.Meta({})
  return doc
end
