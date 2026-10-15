-- E.D. Mich. motion to dismiss with brief, DOCX engine (docs/DOCX.md). The same markdown contract as the typst
-- template (typst/mied-motion-brief.typ; contract in ../README.md). Styles come from docx/reference.docx. This filter
-- builds the two covers, the caption, the sections (page-number formats), the authorities, the contents field, the
-- signature blocks and the certificate, from the frontmatter and the [[brief]] / [[toc]] / [[body]] markers.
-- Content-agnostic: no case-specific text and no forced line breaks here.
--
-- Sections: 1 = motion (arabic from 1), 2 = brief cover (unnumbered, footer FOOTER_BLANK), 3 = front matter (roman),
-- 4 = body and certificate (arabic from 1; the final sectPr comes from reference.docx). The sectPr footer ids are
-- placeholders that docx/render.sh maps to the relationship ids pandoc writes.
-- Word-native parts: the contents is a TOC field over the heading styles (cached entries, no page numbers until the
-- field is updated; see the README, "Engines"); front-matter headings use styles with no outline level, so they are
-- not in the contents, as the typst template keeps them out.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function px(style, text, ppr)
  local run = ""
  if text ~= "" then run = '<w:r><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>' end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. run .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function styled(style, blocks_or_inlines)
  return pandoc.Div({ pandoc.Para(blocks_or_inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- A section break: the paragraph that ends the section carries its properties (letter, 1 in margins).
local function section_break(footer, fmt, start)
  local pg = '<w:pgNumType w:fmt="' .. fmt .. '"' .. (start and (' w:start="' .. start .. '"') or '') .. '/>'
  return raw('<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>' .. pg .. '</w:sectPr></w:pPr></w:p>')
end

-- Fed. R. Civ. P. 10(a) and LR 5.1: court title (three lines), caption table, title of the paper
local function cover(m, title)
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
  out[#out + 1] = raw(px("CaptionTitle", plain(title)))
  return out
end

-- Dated (when the frontmatter has a date), "Respectfully submitted," the firm, "By: /s/" and the signer's lines
local function signature(m)
  local sig = m.signature
  local out = {}
  local function sp(style, text, ppr) out[#out + 1] = raw(px(style, text, ppr)) end
  if m.date then sp("DatedLine", "Dated: " .. plain(m.date)) end
  sp("SigTop", "Respectfully submitted,")
  for i, l in ipairs(sig.firm or {}) do sp("Signature", plain(l), i == 1 and '<w:spacing w:before="644" w:after="0"/>' or nil) end
  sp("Signature", "By: /s/ " .. plain(sig.signer), '<w:spacing w:before="280" w:after="0"/>')
  sp("Signature", plain(sig.signer))
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do sp(i == #lines and "SigLast" or "Signature", plain(l)) end
  return out
end

-- Table of contents: a TOC field over the body headings. The cached entries are the heading texts (no page
-- numbers): the field is updated by Word on open (updateFields) or by LibreOffice; see the README.
local function toc_field(entries)
  local xml = {}
  for i, e in ipairs(entries) do
    local pre, post = "", ""
    if i == 1 then
      pre = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    if i == #entries then post = '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    xml[#xml + 1] = '<w:p><w:pPr><w:pStyle w:val="TOC' .. e.level .. '"/></w:pPr>' .. pre
      .. '<w:r><w:t xml:space="preserve">' .. esc(e.text) .. '</w:t></w:r>' .. post .. '</w:p>'
  end
  return raw(table.concat(xml))
end

-- lists: numbered issues ("1.") and bulleted authorities (a bullet and a tab, single spaced, hanging)
local function issues(list)
  local out = {}
  for i, item in ipairs(list.content) do
    for j, b in ipairs(item) do
      if j == 1 and (b.t == "Para" or b.t == "Plain") then
        local c = { pandoc.Str(i .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
        for _, x in ipairs(b.content) do c[#c + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "Issue" }))
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

local function authorities(list)
  local out = {}
  for _, item in ipairs(list.content) do
    for j, b in ipairs(item) do
      if j == 1 and (b.t == "Para" or b.t == "Plain") then
        local c = { pandoc.Str("\u{2022}"), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
        for _, x in ipairs(b.content) do c[#c + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "Authority" }))
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

local function is_marker(b, name)
  return b.t == "Para" and plain(b) == name
end

local function is_cert(b)
  return b.t == "Header" and b.level == 1 and plain(b.content) == "CERTIFICATE OF SERVICE"
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(list) for _, x in ipairs(list) do out[#out + 1] = x end end

  -- the contents entries: the body headings (after [[body]], before the certificate), levels 1 to 3
  local entries, in_body = {}, false
  for _, b in ipairs(doc.blocks) do
    if is_marker(b, "[[body]]") then in_body = true
    elseif is_cert(b) then in_body = false
    elseif in_body and b.t == "Header" and b.level <= 3 then
      entries[#entries + 1] = { level = b.level, text = plain(b.content) }
    end
  end

  -- 1. the motion (numbered from 1)
  add(cover(m, m.motion_title))
  local phase = "motion"
  for _, b in ipairs(doc.blocks) do
    if is_marker(b, "[[brief]]") then
      add(signature(m))
      out[#out + 1] = section_break("FOOTER_PAGE", "decimal", 1)
      -- 2. the brief's cover (unnumbered)
      add(cover(m, m.brief_title))
      out[#out + 1] = section_break("FOOTER_BLANK", "lowerRoman", 1)
      phase = "front"
    elseif is_marker(b, "[[toc]]") then
      out[#out + 1] = styled("TOCTitle", pandoc.Str("Table of Contents"))
      out[#out + 1] = toc_field(entries)
    elseif is_marker(b, "[[body]]") then
      -- 3. the front matter ends (roman numerals); 4. the body starts (arabic from 1), the final section
      out[#out + 1] = section_break("FOOTER_PAGE", "lowerRoman", nil)
      phase = "body"
    elseif is_cert(b) then
      add(signature(m))
      out[#out + 1] = styled("CertHeading", b.content)
      phase = "cert"
    elseif b.t == "Header" and phase ~= "body" and phase ~= "cert" then
      -- motion and front-matter headings: not in the contents
      out[#out + 1] = styled(b.level == 1 and "FrontHeading" or "FrontSubhead", b.content)
    elseif b.t == "OrderedList" then
      add(issues(b))
    elseif b.t == "BulletList" then
      add(authorities(b))
    else
      out[#out + 1] = b
    end
  end
  doc.blocks = out
  doc.meta.title = nil
  doc.meta.date = nil
  return doc
end
