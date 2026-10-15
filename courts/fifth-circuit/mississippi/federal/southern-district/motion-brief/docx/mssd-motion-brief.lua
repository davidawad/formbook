-- Memorandum brief in support of a motion, S.D. Miss. (mssd), DOCX engine (docs/DOCX.md): the markdown contract ->
-- Word on reference.docx. Mirrors motion-brief/typst/mssd-motion-brief.typ. The cover (court title, caption table,
-- title of the paper), the signature block and the certificate of service are built here from the sample's
-- frontmatter, in the styles build-reference.sh defines. The body keeps its markdown structure (headings, paragraphs,
-- native footnotes). Every case word comes from doc.meta; nothing case-specific is in this file.
-- Known limits: the caption is a borderless table; its party names are plain text. The 35-page limit of
-- L.U.Civ.R. 7(b)(5) is checked in the typst engine only (see ../README.md, Engines).

local REQUIRED_SIG = { "signer", "bar_no", "firm", "address", "telephone", "fax", "email" }

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function line(style, s)
  return styled(style, { pandoc.Para({ pandoc.Str(s) }) })
end

local function gap()
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Gap"/></w:pPr></w:p>')
end

-- a metadata value that is inline markdown (a list of inlines) or blocks, as a list of blocks
local function meta_blocks(v)
  local out = {}
  local first = v[1]
  if first and (first.t == "Para" or first.t == "Plain") then
    for _, b in ipairs(v) do out[#out + 1] = b end
  else
    out[1] = pandoc.Para(v)
  end
  return out
end

local function xml_para(style, s)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr><w:r><w:t xml:space="preserve">'
    .. esc(s) .. '</w:t></w:r></w:p>'
end

local function cell(width, content, valign)
  local v = valign and ('<w:vAlign w:val="' .. valign .. '"/>') or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. v .. '</w:tcPr>' .. content .. '</w:tc>'
end

-- Caption: parties on the left (each block: names, then its designation; "v." between blocks, each block set off by a
-- short gap), the case number on the right, centered vertically. Borderless table.
local function caption(meta)
  local left = {}
  local parties = meta.caption and meta.caption.parties or {}
  for k, p in ipairs(parties) do
    local first = true
    local function add(s)
      left[#left + 1] = xml_para((first and k > 1) and "CaptionBlock" or "Single", s)
      first = false
    end
    if k > 1 then
      left[#left + 1] = xml_para("CaptionBlock", "v.")
      first = false
    end
    for _, n in ipairs(p.names or {}) do add(text_of(n)) end
    add(text_of(p.designation))
  end
  local right = xml_para("Single", "CIVIL ACTION NO.") .. xml_para("Single", text_of(meta.case_number))
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5184"/><w:gridCol w:w="144"/><w:gridCol w:w="4032"/></w:tblGrid><w:tr>'
    .. cell(5184, table.concat(left))
    .. cell(144, '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p>')
    .. cell(4032, right, "center")
    .. '</w:tr></w:tbl>'
  return pandoc.RawBlock("openxml", xml)
end

local function cover(meta)
  local out = {}
  for _, l in ipairs(meta.court or {}) do
    out[#out + 1] = styled("Court Title", { pandoc.Para({ pandoc.Str(text_of(l)) }) })
  end
  out[#out + 1] = gap()
  out[#out + 1] = caption(meta)
  out[#out + 1] = gap()
  out[#out + 1] = styled("Cover Title", { pandoc.Para({ pandoc.Str(text_of(meta.brief_title)) }) })
  out[#out + 1] = gap()
  return out
end

-- counsel block at the right half of the page (the typst pad of 3 in), after "Respectfully submitted, this the ..."
local function signature(meta)
  local s = meta.signature
  if not s then error("mssd-motion-brief: the sample needs a signature block (L.U.Civ.R. 11(a))") end
  for _, k in ipairs(REQUIRED_SIG) do
    if s[k] == nil then error("mssd-motion-brief: signature." .. k .. " is required (L.U.Civ.R. 11(a))") end
  end
  local out = { gap() }
  if s.date then out[#out + 1] = line("Signature Intro", "Respectfully submitted, this the " .. text_of(s.date)) end
  out[#out + 1] = line("Signature Block", text_of(s.firm))
  for _, a in ipairs(s.address) do out[#out + 1] = line("Signature Block", text_of(a)) end
  out[#out + 1] = line("Signature Block", "Telephone: " .. text_of(s.telephone))
  out[#out + 1] = line("Signature Block", "Facsimile: " .. text_of(s.fax))
  out[#out + 1] = line("Signature Gap", "s/ " .. text_of(s.signer))
  out[#out + 1] = line("Signature Block", string.upper(text_of(s.signer)) .. ", " .. text_of(s.bar_no))
  out[#out + 1] = line("Signature Block", "Email: " .. text_of(s.email))
  return out
end

-- certificate of service (optional): a centered heading, one indented paragraph, the "s/" signature
local function certificate(meta)
  local c = meta.certificate
  if not c then return {} end
  local out = { styled("Certificate Heading", { pandoc.Para({ pandoc.Str("CERTIFICATE OF SERVICE") }) }) }
  local body = meta_blocks(c.text)
  out[#out + 1] = styled("Certificate Body", { body[1] })
  out[#out + 1] = line("Signature Gap", "s/ " .. text_of(c.signer))
  out[#out + 1] = line("Signature Block", string.upper(text_of(c.signer)) .. ", " .. text_of(c.bar_no))
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = cover(meta)
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  for _, b in ipairs(certificate(meta)) do out[#out + 1] = b end
  return pandoc.Pandoc(out, doc.meta)
end
