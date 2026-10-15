-- Pandoc Lua filter for the vid (District Court of the Virgin Islands) docx, built from the same sample
-- frontmatter as typst/vid-complaint.typ. It writes the parts that pandoc cannot express from markdown:
-- the court header, the caption table (parties, rule, number), the title, the numbered paragraphs, and the
-- signature block. Headings, quotations and lists are pandoc's own, styled by docx/reference.docx.
-- Content-agnostic: every case word comes from the frontmatter.

-- CFG: the only per-doc-type settings (the complaint numbers its paragraphs; a memorandum does not).
local CFG = {
  numbered = false,
  court_name = "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS",
  default_number_label = "Civil Action No.",
}

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>'

local function run(text, rpr)
  local r = ""
  if rpr and rpr ~= "" then r = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. r .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function xpara(ppr, runs)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (runs or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function str(x)
  return pandoc.utils.stringify(x or "")
end

local function gap(keep)
  -- one blank double-spaced line (the typst v(body-leading) between blocks)
  local ppr = '<w:pStyle w:val="CenteredBlock"/>' .. (keep and "<w:keepNext/>" or "")
  return raw(xpara(ppr, ""))
end

-- Caption: parties in the left cell (closed by a rule on the right and bottom), the number on the right.
local function caption_xml(parties, label, number)
  local left = {}
  local n = #parties
  for i, p in ipairs(parties) do
    for _, name in ipairs(p.names) do
      left[#left + 1] = xpara(SINGLE, run(str(name)))
    end
    left[#left + 1] = xpara('<w:spacing w:before="96" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="1728" w:firstLine="0"/>', run(str(p.designation)))
    if i < n then
      left[#left + 1] = xpara('<w:spacing w:before="144" w:after="144" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', run("v."))
    end
  end
  local right_text = label .. " " .. ((number == "") and "____________" or number)
  local rule = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5040"/><w:gridCol w:w="4320"/></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="5040" w:type="dxa"/><w:tcBorders>' .. rule .. '</w:tcBorders>'
    .. '<w:tcMar><w:right w:w="288" w:type="dxa"/><w:bottom w:w="173" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa"/><w:tcMar><w:left w:w="432" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. xpara(SINGLE, run(right_text)) .. '</w:tc></w:tr></w:tbl>'
end

-- Signature: date at left, counsel's block at right, single-spaced, kept on one row (typst: breakable false).
local function signature_xml(sig)
  local right = {}
  for _, l in ipairs(sig.preamble or {}) do
    right[#right + 1] = xpara(SINGLE, run(str(l)))
  end
  right[#right + 1] = xpara('<w:spacing w:before="144" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>', run("/s/ " .. str(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do
    right[#right + 1] = xpara(SINGLE, run(str(l)))
  end
  local none = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. none
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/></w:tcPr>' .. xpara(SINGLE, run("Dated: " .. str(sig.date))) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

local function list_items_sticky(lst)
  -- A list (the prayer) keeps with what follows: each item paragraph gets the keep-with-next style.
  for _, item in ipairs(lst.content) do
    for i, b in ipairs(item) do
      if b.t == "Para" or b.t == "Plain" then
        item[i] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Prayer Item" })
      end
    end
  end
  return lst
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- Court header, caption, title (typst court-header, caption, title; double spaced)
  local division = str(m.division):upper()
  add(raw(xpara('<w:pStyle w:val="CenteredBlock"/>', run(CFG.court_name, "<w:b/><w:bCs/>") .. '<w:r><w:br/></w:r>' .. run("DIVISION OF " .. division, "<w:b/><w:bCs/>"))))
  add(gap(false))
  local parties = m.caption or {}
  local label = str(m.number_label)
  if label == "" then label = CFG.default_number_label end
  add(raw(caption_xml(parties, label, str(m.case_number))))
  add(gap(false))
  add(raw(xpara('<w:pStyle w:val="CenteredBlock"/><w:keepNext/>', run(str(m.title), "<w:b/><w:bCs/>"))))

  -- Body: numbered paragraphs (complaint), unnumbered "~ " paragraphs, headings, quotes and lists
  local n = 0
  local first = true
  if m.lead_in then
    add(pandoc.Para(m.lead_in))
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local c = b.content
      local unnumbered = c[1] and c[1].t == "Str" and c[1].text == "~"
      if unnumbered then
        table.remove(c, 1)
        if c[1] and c[1].t == "Space" then table.remove(c, 1) end
        add(pandoc.Para(c))
      elseif CFG.numbered then
        n = n + 1
        local lead = { pandoc.Str(tostring(n) .. ".") , pandoc.Space() }
        for _, x in ipairs(c) do lead[#lead + 1] = x end
        add(pandoc.Para(lead))
      else
        add(pandoc.Para(c))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      add(list_items_sticky(b))
    else
      add(b)
    end
  end

  -- Signature (typst signature-block: one blank line above, kept together)
  add(gap(true))
  add(raw(signature_xml(m.signature or {})))

  -- Certificate of service (motion briefs; frontmatter `certificate`)
  if m.certificate then
    add(gap(true))
    add(raw(xpara('<w:pStyle w:val="CenteredBlock"/><w:keepNext/>', run(str(m.certificate.title), "<w:b/><w:bCs/>"))))
    add(pandoc.Para(m.certificate.text))
    add(raw(xpara('<w:pStyle w:val="SingleBlock"/><w:jc w:val="right"/>', run("/s/ " .. str(m.certificate.signer)))))
  end

  doc.blocks = out
  -- The frontmatter title is printed by the caption/title block above, not by pandoc.
  doc.meta.title = nil
  return doc
end
