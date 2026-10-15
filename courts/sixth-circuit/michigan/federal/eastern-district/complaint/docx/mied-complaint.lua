-- E.D. Mich. complaint, DOCX engine (docs/DOCX.md). The same markdown contract as the typst template
-- (typst/mied-complaint.typ; contract in ../README.md). Styles come from docx/reference.docx; this filter builds
-- the caption, the numbered paragraphs, the lettered prayer items and the signature block, from the frontmatter.
-- Content-agnostic: no case-specific text and no forced line breaks here.
--
-- Word-native parts: paragraph numbers are text ("1." and an em space, as in the typst template), not a list;
-- the caption is a borderless table whose left cell has the right and bottom rules (docs/DOCX.md, "Cover pages and
-- caption boxes": table borders render slightly differently in Word and LibreOffice).

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- one paragraph as WordprocessingML; `ppr` is extra pPr content placed after the style
local function px(style, text, ppr)
  local run = ""
  if text ~= "" then run = '<w:r><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>' end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. run .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- Fed. R. Civ. P. 10(a): court title (three lines), spacer, caption table (parties | case number and judge), title
local function caption(m)
  local out = {}
  out[#out + 1] = raw(px("CourtTitle", "UNITED STATES DISTRICT COURT"))
  out[#out + 1] = raw(px("CourtTitle", "FOR THE EASTERN DISTRICT OF MICHIGAN"))
  if m.division then out[#out + 1] = raw(px("CourtTitle", plain(m.division):upper())) end
  local left, right = {}, {}
  for i, p in ipairs(m.caption.parties) do
    if i > 1 then left[#left + 1] = px("CaptionCell", "v.") end
    for _, n in ipairs(p.names) do left[#left + 1] = px("CaptionCell", plain(n)) end
    left[#left + 1] = px("CaptionCell", plain(p.designation))
  end
  right[#right + 1] = px("CaptionCell", "Case No. " .. plain(m.case_number), '<w:ind w:left="144"/>')
  if m.judge then right[#right + 1] = px("CaptionCell", plain(m.judge), '<w:ind w:left="144"/>') end
  if m.judges then
    for _, j in ipairs(m.judges) do right[#right + 1] = px("CaptionCell", plain(j), '<w:ind w:left="144"/>') end
  end
  out[#out + 1] = raw(px("Single", "", '<w:spacing w:before="644" w:after="0"/>'))
  out[#out + 1] = raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="4608"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/><w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/><w:tcMar><w:left w:w="504" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>')
  out[#out + 1] = raw(px("CaptionTitle", plain(m.brief_title)))
  return out
end

-- lead-in (unnumbered, first-line indent, double spaced), when the frontmatter has one
local function lead_in(m)
  if not m.lead_in then return {} end
  return { pandoc.Div({ pandoc.Para(m.lead_in) }, pandoc.Attr("", {}, { ["custom-style"] = "Body Text" })) }
end

-- Respectfully submitted, /s/ signer, then the attorney's contact lines (typst: signature-block)
local function signature(m)
  local sig = m.signature
  local out = {}
  local function sp(style, text) out[#out + 1] = raw(px(style, text)) end
  sp("SigTop", "Respectfully submitted,")
  sp("Signature", "")
  sp("Signature", "/s/ " .. plain(sig.signer))
  sp("Signature", plain(sig.signer))
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do sp(i == #lines and "SigLast" or "Signature", plain(l)) end
  return out
end

-- numbered paragraphs (Fed. R. Civ. P. 10(b)): "n.<em space>" then the text, as in the typst template
local function numbered(b, n)
  table.insert(b.content, 1, pandoc.Str(n .. ".\u{2003}"))
  return pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
end

-- lettered prayer items: "A.", "B.", ... (the markdown numbers are not shown; typst: enum with letters)
local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local label = string.char(64 + i) .. "."
    for j, b in ipairs(item) do
      if j == 1 and (b.t == "Para" or b.t == "Plain") then
        local c = { pandoc.Str(label), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
        for _, x in ipairs(b.content) do c[#c + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered" }))
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

function Pandoc(doc)
  local m = doc.meta
  local out = caption(m)
  for _, b in ipairs(lead_in(m)) do out[#out + 1] = b end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      out[#out + 1] = numbered(b, n)
    elseif b.t == "OrderedList" then
      for _, x in ipairs(lettered(b)) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = raw(px("Single", "", '<w:spacing w:before="644" w:after="0"/>'))
  for _, b in ipairs(signature(m)) do out[#out + 1] = b end
  doc.blocks = out
  doc.meta.title = nil
  doc.meta.date = nil
  return doc
end
