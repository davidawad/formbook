-- Motion with memorandum, DOCX engine (docs/DOCX.md): the markdown sample -> a Word document on reference.docx.
-- Mirrors typst/mab-motion-brief.typ: the cover (court lines, caption table, title), the signature block (date at
-- the left, signature groups at 3.0 in) and the service list (single-spaced, flush left) are built here from the
-- frontmatter; the body keeps its markdown structure; paragraphs are numbered with the reference's "Numbered
-- Paragraph" list style, except the certificate and the service list (MLBR 9013-1(a)). Page numbers come from the
-- reference's footer (none on page 1).

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value as a list of strings (a single string or a list of them; pandoc gives lists no tag)
local function lines(v)
  if v == nil then return {} end
  if v.t == nil or v.t == "MetaList" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = text_of(x) end
    return out
  end
  return { text_of(v) }
end

-- WordprocessingML paragraph with a style and optional paragraph / run properties
local function wp(style, text, ppr_extra, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local run = text == "" and "" or ('<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>')
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or "") .. '</w:pPr>' .. run .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function spacer(twips, keep)
  return raw(wp("Single", "", (keep and "<w:keepNext/>" or "") .. '<w:spacing w:before="0" w:after="0" w:line="' .. (twips or 480) .. '" w:lineRule="exact"/>'))
end

-- a borderless cell holding single-spaced lines
local function cell(width, paras, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. (mar or "") .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function table_xml(grid, row, cant)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr>' .. (cant and '<w:trPr><w:cantSplit/></w:trPr>' or '') .. table.concat(row) .. '</w:tr></w:tbl>'
end

-- the cover: court (FRBP 9004(b)), caption, title of the paper
local function cover(meta)
  local out = {}
  out[#out + 1] = raw(wp("Centered", "UNITED STATES BANKRUPTCY COURT", nil, true))
  out[#out + 1] = raw(wp("Centered", "FOR THE DISTRICT OF MASSACHUSETTS", nil, true))
  out[#out + 1] = raw(wp("Centered", string.upper(text_of(meta.division)), nil, true))
  out[#out + 1] = spacer(480)

  -- debtor (left, 3.4 in) and chapter / case number (right)
  local left, right = {}, {}
  left[#left + 1] = wp("Single", "In re:")
  left[#left + 1] = wp("Single", "")
  for _, s in ipairs(lines(meta.debtor_names)) do left[#left + 1] = wp("Single", s) end
  left[#left + 1] = wp("Single", text_of(meta.debtor_designation))
  right[#right + 1] = wp("Single", "CHAPTER " .. text_of(meta.chapter))
  right[#right + 1] = wp("Single", "")
  right[#right + 1] = wp("Single", "CASE NO. " .. text_of(meta.case_number))
  local grid = { '<w:gridCol w:w="4896"/>', '<w:gridCol w:w="288"/>', '<w:gridCol w:w="4176"/>' }
  out[#out + 1] = raw(table_xml(grid, { cell(4896, left), cell(288, { wp("Single", "") }), cell(4176, right) }))
  out[#out + 1] = spacer(480)

  -- adversary parties (left, bounded on the right and bottom) and the adversary number (right)
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local padding = '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="160" w:type="dxa"/></w:tcMar>'
  local parties = {}
  for _, s in ipairs(lines(meta.plaintiffs and meta.plaintiffs.names)) do parties[#parties + 1] = wp("Single", s) end
  parties[#parties + 1] = wp("Single", text_of(meta.plaintiffs and meta.plaintiffs.designation))
  parties[#parties + 1] = wp("Single", "")
  parties[#parties + 1] = wp("Single", "v.")
  parties[#parties + 1] = wp("Single", "")
  for _, s in ipairs(lines(meta.defendants and meta.defendants.names)) do parties[#parties + 1] = wp("Single", s) end
  parties[#parties + 1] = wp("Single", text_of(meta.defendants and meta.defendants.designation))
  local adv = text_of(meta.adv_number)
  local adv_line = adv == "" and "ADV. PROC. NO. ____________" or ("Adv. Proc. No. " .. adv)
  out[#out + 1] = raw(table_xml(grid, {
    cell(4896, parties, rule, padding),
    cell(288, { wp("Single", "") }),
    cell(4176, { wp("Single", adv_line, '<w:ind w:left="144" w:firstLine="0"/>') }),
  }))
  out[#out + 1] = spacer(480)
  out[#out + 1] = raw(wp("Centered", text_of(meta.title), nil, true))
  return out
end

-- the signature block (typst signature-block): "Dated:" at the left, the signature groups at 3.0 in; kept whole
local function signature(meta)
  local keep = "<w:keepNext/>"
  local groups = {}
  for gi, g in ipairs(meta.signature or {}) do
    for _, s in ipairs(lines(g)) do groups[#groups + 1] = wp("Single", s, keep) end
    if gi < #(meta.signature or {}) then groups[#groups + 1] = wp("Single", "", keep .. '<w:spacing w:before="0" w:after="0" w:line="180" w:lineRule="exact"/>') end
  end
  local out = { spacer(480, true) }
  out[#out + 1] = raw(table_xml(
    { '<w:gridCol w:w="4032"/>', '<w:gridCol w:w="288"/>', '<w:gridCol w:w="5040"/>' },
    { cell(4032, { wp("Single", "Dated: " .. text_of(meta.cover_date), keep) }),
      cell(288, { wp("Single", "", keep) }),
      cell(5040, groups) },
    true))
  return out
end

local UNNUMBERED = { ["CERTIFICATE OF SERVICE"] = true, ["SERVICE LIST"] = true }

local function styled_div(p, style)
  return pandoc.Div({ p }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

function Pandoc(doc)
  local meta = doc.meta
  -- the title and date are printed by the template (cover, signature), not by pandoc
  meta.cover_title = text_of(meta.title)
  meta.cover_date = text_of(meta.date)
  meta.title = nil
  meta.date = nil
  local body_text = pandoc.utils.stringify(pandoc.Pandoc(doc.blocks))
  -- FRBP 9013(b): a motion must set forth the relief or order requested
  if not body_text:find("respectfully requests", 1, true) then
    error("mab-motion-brief: FRBP 9013(b) requires the motion to set forth the relief or order requested")
  end

  local out = cover(meta)
  local numbered = false          -- the lead-in before the first heading is not numbered (typst "allegations")
  local single = false            -- the service list is single-spaced, flush left (Appendix 8(a) exception)
  local signed = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      local title = string.upper(pandoc.utils.stringify(b))
      if title == "CERTIFICATE OF SERVICE" and not signed then
        for _, s in ipairs(signature(meta)) do out[#out + 1] = s end
        signed = true
      end
      numbered = not UNNUMBERED[title]
      single = title == "SERVICE LIST"
      out[#out + 1] = b
    elseif b.t == "Para" and single then
      out[#out + 1] = styled_div(b, "Single")
    elseif b.t == "Para" and numbered then
      out[#out + 1] = styled_div(b, "Numbered Paragraph")
    else
      out[#out + 1] = b
    end
  end
  if not signed then
    for _, s in ipairs(signature(meta)) do out[#out + 1] = s end
  end
  doc.blocks = out
  return doc
end
