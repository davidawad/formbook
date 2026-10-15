-- Adversary complaint, DOCX engine (docs/DOCX.md): the markdown sample -> a Word document on reference.docx.
-- Mirrors typst/mab-adversary-complaint.typ: the cover (court lines, caption table, title) and the signature
-- block are built here from the frontmatter; the body keeps its markdown structure; paragraphs are numbered
-- with the reference's "Numbered Paragraph" list style, except after an unnumbered heading and the WHEREFORE
-- prayer (Fed. R. Civ. P. 10(b)). Page numbers come from the reference's footer (none on page 1).

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

-- a spacer of one exact line pitch (24 pt, the body pitch; or the given twips)
local function spacer(twips)
  return raw(wp("Single", "", '<w:spacing w:before="0" w:after="0" w:line="' .. (twips or 480) .. '" w:lineRule="exact"/>'))
end

-- a borderless cell holding single-spaced lines (typst line-stack)
local function cell(width, paras, borders, mar)
  local b = borders or ""
  local m = mar or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. b .. m .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function table_xml(cells)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(cells.grid) .. '</w:tblGrid>'
    .. '<w:tr>' .. table.concat(cells.row) .. '</w:tr></w:tbl>'
end

-- the cover: court (FRBP 7010, Form 416D), caption, title (typst "caption")
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
  out[#out + 1] = raw(table_xml({
    grid = { '<w:gridCol w:w="4896"/>', '<w:gridCol w:w="288"/>', '<w:gridCol w:w="4176"/>' },
    row = {
      cell(4896, left),
      cell(288, { wp("Single", "") }),
      cell(4176, right),
    },
  }))
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
  out[#out + 1] = raw(table_xml({
    grid = { '<w:gridCol w:w="4896"/>', '<w:gridCol w:w="288"/>', '<w:gridCol w:w="4176"/>' },
    row = {
      cell(4896, parties, rule, padding),
      cell(288, { wp("Single", "") }),
      cell(4176, { wp("Single", adv_line, '<w:ind w:left="144" w:firstLine="0"/>') }),
    },
  }))
  out[#out + 1] = spacer(480)
  out[#out + 1] = raw(wp("Centered", meta.cover_title, nil, true))
  return out
end

-- the signature block (typst signature-block): groups of lines at 3.1 in, then the date at the left margin
local function signature(meta)
  -- kept together on one page (typst: breakable: false)
  local out = { raw(wp("Single", "", '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>')) }
  local groups = meta.signature or {}
  for gi, g in ipairs(groups) do
    for _, s in ipairs(lines(g)) do out[#out + 1] = raw(wp("Signature", s, "<w:keepNext/>")) end
    if gi < #groups then out[#out + 1] = raw(wp("Single", "", '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="180" w:lineRule="exact"/>')) end
  end
  out[#out + 1] = raw(wp("Single", "", '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/>'))
  out[#out + 1] = raw(wp("Single", "Date: " .. meta.cover_date))
  return out
end

local UNNUMBERED = { ["CERTIFICATE OF SERVICE"] = true, ["SERVICE LIST"] = true }

local function numbered_div(p)
  return pandoc.Div({ p }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Paragraph" }))
end

function Pandoc(doc)
  local meta = doc.meta
  -- the title and date are printed by the template (cover, signature), not by pandoc
  meta.cover_title = text_of(meta.title)
  meta.cover_date = text_of(meta.date)
  meta.title = nil
  meta.date = nil
  local body_text = pandoc.utils.stringify(pandoc.Pandoc(doc.blocks))
  -- FRBP 7008(a): the complaint must state whether the pleader does or does not consent to final orders or judgment
  if not body_text:find("consent to the entry of final orders", 1, true) then
    error("mab-adversary-complaint: FRBP 7008(a) requires a statement of consent to the entry of final orders or judgment by the bankruptcy court")
  end

  local out = cover(meta)
  local numbered = false          -- the lead-in before the first heading is not numbered (typst "allegations")
  local signed = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      local title = string.upper(pandoc.utils.stringify(b))
      if title == "CERTIFICATE OF SERVICE" and not signed then
        for _, s in ipairs(signature(meta)) do out[#out + 1] = s end
        signed = true
      end
      numbered = not UNNUMBERED[title]
      out[#out + 1] = b
    elseif b.t == "Para" and numbered and not pandoc.utils.stringify(b):find("^WHEREFORE") then
      out[#out + 1] = numbered_div(b)
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
