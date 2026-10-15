-- nynb memorandum of law in support of a motion, DOCX engine (docs/DOCX.md). Mirrors
-- typst/nynb-motion-brief.typ: the cover (chambers legend, counsel, court title, bankruptcy caption, adversary
-- caption when the motion is in an adversary proceeding, title) as single-spaced paragraphs and two caption tables
-- with the caption rule; the body keeps the markdown structure (headings and paragraphs from the reference styles,
-- block quotations in Block Text); the certificate of service and the signature block as paragraphs and a
-- borderless table. Every case-specific word comes from the sample's frontmatter. Styles come from docx/reference.docx.

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- runs of text; "**" toggles bold and "*" toggles italic (the markdown of a metadata value)
local function runs(text)
  local out, buf, bold, ital, i = {}, "", false, false, 1
  local function flush()
    if buf ~= "" then
      local rpr = (bold and "<w:b/>" or "") .. (ital and "<w:i/>" or "")
      out[#out + 1] = "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
        .. '<w:t xml:space="preserve">' .. xesc(buf) .. "</w:t></w:r>"
      buf = ""
    end
  end
  while i <= #text do
    if text:sub(i, i + 1) == "**" then flush(); bold = not bold; i = i + 2
    elseif text:sub(i, i) == "*" then flush(); ital = not ital; i = i + 1
    else buf = buf .. text:sub(i, i); i = i + 1 end
  end
  flush()
  return table.concat(out)
end

local function para(style, text, ppr_extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or "") .. "</w:pPr>" .. runs(text) .. "</w:p>"
end

-- an empty line of exact height (twips): 480 = one double-spaced line (24 pt), 120 = 6 pt
local function spacer(twips, keep)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/>' .. (keep and "<w:keepNext/>" or "")
    .. '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- a metadata value as markdown (keeps ** and *)
local function md(v)
  if v == nil or v == false then return "" end
  if type(v) == "string" then return v end
  if pandoc.utils.type(v) == "Inlines" then
    local s = ""
    for _, x in ipairs(v) do
      if x.t == "Strong" then s = s .. "**" .. pandoc.utils.stringify(x) .. "**"
      elseif x.t == "Emph" then s = s .. "*" .. pandoc.utils.stringify(x) .. "*"
      else s = s .. pandoc.utils.stringify(x) end
    end
    return s
  end
  return pandoc.utils.stringify(v)
end

local NOBORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

-- three columns totalling 6.5 in (9360 twips): party or left column, 0.25 in gutter, right column
local function caption_table(left_xml, right_xml)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NOBORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="360"/><w:gridCol w:w="4104"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/>' .. RULE .. '<w:tcMar><w:right w:w="120" w:type="dxa"/>'
    .. '<w:bottom w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>' .. left_xml .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4104" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. right_xml .. "</w:tc></w:tr></w:tbl>"
end

-- "Dated" on the left (3 in), the signing lines on the right (4.5 in plus gutter)
local function sig_table(left_xml, right_xml)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NOBORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="4320"/><w:gridCol w:w="360"/><w:gridCol w:w="4680"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa"/></w:tcPr>' .. left_xml .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/></w:tcPr>' .. right_xml .. "</w:tc></w:tr></w:tbl>"
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add_xml(x) out[#out + 1] = raw(x) end

  -- cover: the chambers legend (LBR 9013-1(h)) above the counsel block, then the court title and captions
  if m.chambers_copy == true then
    add_xml(para("Single", "**ECF CASE – CHAMBERS COPY**", '<w:jc w:val="right"/>'))
    add_xml(spacer(276))
  end
  if m.counsel then
    for _, line in ipairs(m.counsel) do add_xml(para("Single", md(line))) end
    add_xml(spacer(480))
  end
  add_xml(para("Centered", "**UNITED STATES BANKRUPTCY COURT**"))
  add_xml(para("Centered", "**NORTHERN DISTRICT OF NEW YORK**"))
  add_xml(spacer(480))

  local left = { para("Single", "In re:") }
  for _, n in ipairs(m.debtor.names) do left[#left + 1] = para("Single", md(n)) end
  left[#left + 1] = para("Single", "(" .. md(m.debtor.tin) .. ")")
  left[#left + 1] = para("Single", "Debtor.")
  local right = {}
  if type(m.hearing) == "table" and m.hearing.date then
    right[#right + 1] = para("Single", "Hearing: " .. md(m.hearing.date))
    right[#right + 1] = para("Single", "Time: " .. md(m.hearing.time))
    right[#right + 1] = para("Single", "Location: " .. md(m.hearing.location))
  end
  right[#right + 1] = para("Single", "Case No. " .. md(m.case_number))
  right[#right + 1] = para("Single", "Chapter " .. md(m.chapter))
  add_xml(caption_table(table.concat(left), table.concat(right)))

  -- adversary caption, when the motion is filed in an adversary proceeding
  if type(m.adversary) == "table" and m.adversary.parties then
    add_xml(spacer(120))
    local rows = {}
    for k, p in ipairs(m.adversary.parties) do
      if k > 1 then rows[#rows + 1] = para("Single", "v.") end
      for _, n in ipairs(p.names) do rows[#rows + 1] = para("Single", md(n)) end
      rows[#rows + 1] = para("Single", md(p.designation))
    end
    add_xml(caption_table(table.concat(rows), para("Single", "Adv. Pro. No. " .. md(m.adversary.number))))
  end
  add_xml(spacer(480))
  add_xml(para("Centered", "**" .. md(m.title) .. "**"))
  add_xml(spacer(480))
  m.title = nil -- the title is printed above; no title block from the metadata

  -- body: the markdown structure (headings, paragraphs, block quotations) is kept as pandoc writes it
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end

  -- signature block (typst: "Dated" beside "Respectfully submitted," and the firm, then "By: /s/ signer")
  add_xml(spacer(480, true))
  local sl = { para("Single", "Respectfully submitted,") }
  for _, x in ipairs(m.signature.firm) do sl[#sl + 1] = para("Single", md(x)) end
  sl[#sl + 1] = para("Single", "")
  sl[#sl + 1] = para("Single", "By: /s/ " .. md(m.signature.signer))
  for _, x in ipairs(m.signature.lines) do sl[#sl + 1] = para("Single", md(x)) end
  add_xml(sig_table(para("Single", "Dated: " .. md(m.dated), "<w:keepNext/>"), table.concat(sl)))

  -- certificate of service (LBR 9013-1(c)): title, the sworn paragraphs, then the signature line
  if type(m.certificate) == "table" then
    add_xml(spacer(480, true))
    add_xml(para("Centered", "**" .. md(m.certificate.title or "CERTIFICATE OF SERVICE") .. "**", "<w:keepNext/>"))
    add_xml(spacer(480))
    for _, p in ipairs(m.certificate.paragraphs) do out[#out + 1] = pandoc.Para(p) end
    local cl = { para("Single", "") , para("Single", "/s/ " .. md(m.certificate.signer)) }
    add_xml(sig_table(para("Single", m.certificate.dated and ("Dated: " .. md(m.certificate.dated)) or ""), table.concat(cl)))
  end


  doc.blocks = pandoc.Blocks(out)
  return doc
end
