-- E.D. Ky. complaint, DOCX engine (docs/DOCX.md). The same markdown contract as the typst template
-- (typst/kyed-complaint.typ; contract in ../README.md). Styles come from docx/reference.docx; this filter
-- only builds the caption, the signature block, the paragraph numbers and the lettered lists.
-- Requirement IDs (KYED-...) are in ../README.md. No case-specific text and no forced line breaks here.
--
-- Word-native parts: paragraph numbers are text ("1." then a tab stop at 1 in), not a list, so they cannot
-- drift when a paragraph is added; the caption is a borderless table (the party block and JURY DEMAND side by
-- side), as the caption box is in Word (docs/DOCX.md, "Cover pages and caption boxes").

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- one paragraph as WordprocessingML; `ppr` is extra pPr content placed after the style (schema order: spacing last)
local function px(style, text, ppr)
  local run = ""
  if text ~= "" then run = '<w:r><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>' end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. run .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- KYED-FIRST-001, KYED-FIRST-002: court title, case number, e-filing legend, caption box, title of the paper
local function caption(m)
  local out = {}
  for _, l in ipairs(m.court) do out[#out + 1] = raw(px("CourtTitle", plain(l):upper())) end
  out[#out + 1] = raw(px("Centered", "Civil Action No. " .. plain(m.case_number), '<w:spacing w:before="480"/>'))
  if m.electronically_filed then
    out[#out + 1] = raw(px("Centered", "ELECTRONICALLY FILED", '<w:spacing w:before="240"/>'))
  end
  out[#out + 1] = raw(px("CaptionRule", ""))
  local parties = {}
  for i, p in ipairs(m.caption) do
    if i > 1 then parties[#parties + 1] = px("PartyV", "v.") end
    for _, n in ipairs(p.names) do parties[#parties + 1] = px("Single", plain(n)) end
    local d = plain(p.designation)
    if d ~= "" then parties[#parties + 1] = px("PartyDesig", d) end
  end
  local right = m.jury_demand and px("Single", "JURY DEMAND") or px("Single", "")
  out[#out + 1] = raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5544"/><w:gridCol w:w="3816"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5544" w:type="dxa"/></w:tcPr>' .. table.concat(parties) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3816" w:type="dxa"/><w:tcMar><w:left w:w="360" w:type="dxa"/></w:tcMar></w:tcPr>' .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>')
  out[#out + 1] = raw(px("CaptionRule", ""))
  out[#out + 1] = raw(px("CaptionTitle", plain(m.title):upper()))
  return out
end

-- KYED-SIG-001: the signature block at the right half of the page, single spaced
local function signature(m)
  local sig = m.signature
  local out = {}
  local function sp(style, text) out[#out + 1] = raw(px(style, text)) end
  sp("SigTop", "Respectfully submitted,")
  local pre = sig.preamble or {}
  for i, l in ipairs(pre) do sp(i == 1 and "SigGap" or "SigKeep", plain(l)) end
  sp("SigGap", "s/" .. plain(sig.signer))
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do sp(i == #lines and "SigLast" or "SigKeep", plain(l)) end
  return out
end

-- KYED-CONT-001: numbered paragraphs (Fed. R. Civ. P. 10(b)). An unnumbered paragraph is marked "::" in the sample.
local function starts_marker(b)
  local c = b.content
  return c[1] ~= nil and c[1].t == "Str" and c[1].text == "::"
end

local function strip_marker(b)
  local c = b.content
  table.remove(c, 1)
  if c[1] ~= nil and c[1].t == "Space" then table.remove(c, 1) end
end

local TAB = '<w:r><w:tab/></w:r>'

local function label_para(label, b, style)
  local c = b.content
  table.insert(c, 1, pandoc.RawInline("openxml", TAB))
  table.insert(c, 1, pandoc.Str(label))
  return pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- KYED-CONT-002: a list in the sample is lettered (a), (b), ... as in the typst template
local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local label = "(" .. string.char(96 + i) .. ")"
    for j, b in ipairs(item) do
      if j == 1 and (b.t == "Para" or b.t == "Plain") then
        out[#out + 1] = label_para(label, pandoc.Para(b.content), "Lettered")
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
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and starts_marker(b) then
      strip_marker(b)
      out[#out + 1] = b
    elseif b.t == "Para" then
      n = n + 1
      out[#out + 1] = label_para(n .. ".", b, "Numbered")
    elseif b.t == "OrderedList" then
      for _, x in ipairs(lettered(b)) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end
  for _, b in ipairs(signature(m)) do out[#out + 1] = b end
  doc.blocks = out
  doc.meta.title = nil
  doc.meta.date = nil
  return doc
end
