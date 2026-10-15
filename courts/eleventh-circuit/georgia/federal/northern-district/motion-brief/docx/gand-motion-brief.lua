-- gand-motion-brief.lua: pandoc filter for the N.D. Ga. motion with supporting memorandum, docx engine (docs/DOCX.md).
-- The same content and frontmatter contract as typst/gand-motion-brief.typ, written as pandoc blocks and one raw
-- WordprocessingML caption table. Styles (fonts, spacing, indents, the page footer) come from reference.docx;
-- make-reference.sh builds it. Rules: N.D. Ga. LR 5.1(C), (D), (E), (G), (J), (K); LR 7.1(A)(1), (D) (the font
-- certificate); Fed. R. Civ. P. 10(a), 5(b)(2)(E).
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

local TWIPS_CAPTION_PARTY = 4608 -- 3.2 in, the party column
local TWIPS_CAPTION_PAREN = 504 -- 0.35 in, the column of ")" marks
local TWIPS_CAPTION_RIGHT = 4248 -- the rest of the 6.5 in text width
local TWIPS_DESIGNATION = 2160 -- 1.5 in, the indent of "Plaintiff," and "Defendant."
local RULE_FONT_SIZE = "14" -- LR 5.1(C): Times New Roman at least 14 point

local function need(meta, key)
  if meta[key] == nil then error("gand-motion-brief: frontmatter field `" .. key .. "` is required") end
  return meta[key]
end

local function str(m) return pandoc.utils.stringify(m) end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- A paragraph in a named paragraph style (a custom-style Div; the style is in reference.docx).
local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function words(s)
  return pandoc.Inlines({ pandoc.Str(s) })
end

-- One caption paragraph inside a table cell. opts: indent (twips), before (twips).
local function cap_p(text, opts)
  opts = opts or {}
  local spacing = opts.before and ('<w:spacing w:before="' .. opts.before .. '" w:after="0" w:line="392" w:lineRule="exact"/>') or ""
  local ind = (opts.indent or 0) > 0 and ('<w:ind w:left="' .. opts.indent .. '"/>') or ""
  return '<w:p><w:pPr><w:pStyle w:val="GANDCaption"/>' .. spacing .. ind .. '</w:pPr><w:r><w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>"
end

-- The caption (Fed. R. Civ. P. 10(a)): party lines on the left, a column of ")" marks, the case number on the
-- right, centred vertically. Each party line is one table row of exact height, so the ")" marks line up.
local function caption_table(meta)
  local cap = need(meta, "caption")
  local lines = {}
  for k, p in ipairs(need(cap, "parties")) do
    if k > 1 then lines[#lines + 1] = { text = "v.", indent = 0 } end
    for _, n in ipairs(need(p, "names")) do lines[#lines + 1] = { text = str(n), indent = 0 } end
    lines[#lines + 1] = { text = str(need(p, "designation")), indent = TWIPS_DESIGNATION }
  end
  local case_no = (meta.case_number and str(meta.case_number) ~= "") and str(meta.case_number) or "______________"

  local rows = {}
  for i, l in ipairs(lines) do
    local right_cell
    if i == 1 then
      right_cell = '<w:tc><w:tcPr><w:tcW w:w="' .. TWIPS_CAPTION_RIGHT .. '" w:type="dxa"/><w:vMerge w:val="restart"/><w:vAlign w:val="center"/></w:tcPr>'
        .. cap_p("Civil Action No. " .. case_no) .. "</w:tc>"
    else
      right_cell = '<w:tc><w:tcPr><w:tcW w:w="' .. TWIPS_CAPTION_RIGHT .. '" w:type="dxa"/><w:vMerge/></w:tcPr><w:p><w:pPr><w:pStyle w:val="GANDCaption"/></w:pPr></w:p></w:tc>'
    end
    rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="392" w:hRule="exact"/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. TWIPS_CAPTION_PARTY .. '" w:type="dxa"/></w:tcPr>' .. cap_p(l.text, { indent = l.indent }) .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. TWIPS_CAPTION_PAREN .. '" w:type="dxa"/></w:tcPr>' .. cap_p(")") .. "</w:tc>"
      .. right_cell .. "</w:tr>"
  end

  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>' .. none .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. TWIPS_CAPTION_PARTY .. '"/><w:gridCol w:w="' .. TWIPS_CAPTION_PAREN .. '"/><w:gridCol w:w="' .. TWIPS_CAPTION_RIGHT .. '"/></w:tblGrid>'
    .. table.concat(rows) .. "</w:tbl>")
end

-- Cover: the three-line court title, the caption, the title of the paper (Fed. R. Civ. P. 10(a)).
local function cover(meta)
  local division = str(need(meta, "division"))
  return {
    styled("GAND Court Title", words("IN THE UNITED STATES DISTRICT COURT")),
    styled("GAND Court Title", words("FOR THE NORTHERN DISTRICT OF GEORGIA")),
    styled("GAND Court Title Last", words(division:upper() .. " DIVISION")),
    caption_table(meta),
    styled("GAND Cover Title", words(str(need(meta, "title")))),
  }
end

-- LR 5.1(G): name, complete address, telephone, email and bar number on every document.
local function signature(meta)
  local s = need(meta, "signature")
  local attorneys = need(s, "attorneys")
  assert(#attorneys > 0, "gand-motion-brief: LR 5.1(G) needs at least one attorney block")
  for _, a in ipairs(attorneys) do
    for _, k in ipairs({ "name", "bar", "email" }) do
      if a[k] == nil then error("gand-motion-brief: LR 5.1(G) needs `" .. k .. "` for every attorney") end
    end
  end
  local out = { styled("GAND Signature Lead", words("Respectfully submitted,")) }
  out[#out + 1] = styled("GAND Signature Block Lead", words("s/ " .. str(need(s, "signer"))))
  for _, a in ipairs(attorneys) do
    out[#out + 1] = styled("GAND Signature Block", words(str(a.name) .. ", Georgia Bar No. " .. str(a.bar)))
  end
  for i, l in ipairs(need(s, "firm")) do
    out[#out + 1] = styled(i == 1 and "GAND Signature Gap" or "GAND Signature Block", words(str(l)))
  end
  for _, l in ipairs(need(s, "address")) do out[#out + 1] = styled("GAND Signature Block", words(str(l))) end
  out[#out + 1] = styled("GAND Signature Block", words("Telephone: " .. str(need(s, "phone"))))
  for _, a in ipairs(attorneys) do out[#out + 1] = styled("GAND Signature Block", words(str(a.email))) end
  out[#out + 1] = styled("GAND Signature Gap", words(str(need(s, "role"))))
  return out
end

-- LR 7.1(D): counsel certifies the font and point size at the end of the brief. The certificate names the rule's
-- face (Times New Roman), the face the filer prepares the brief in, and the docx declares that same face.
local function font_certificate(meta)
  local s = need(meta, "signature")
  return {
    styled("GAND Certificate Heading", words("CERTIFICATE PURSUANT TO LOCAL RULE 7.1(D)")),
    styled("GAND Certificate Body", words("I certify that the foregoing brief conforms to the requirements of LR 5.1(C). The brief is prepared in "
      .. RULE_FONT_SIZE .. "-point Times New Roman font.")),
    styled("GAND Signature Right", words("s/ " .. str(need(s, "signer")))),
  }
end

-- Certificate of service through CM/ECF.
local function service_certificate(meta)
  local s = need(meta, "signature")
  return {
    styled("GAND Certificate Heading", words("CERTIFICATE OF SERVICE")),
    styled("GAND Certificate Body", words("I certify that I have this day served the foregoing pleading with the Clerk of Court using the CM/ECF system which will automatically send email notification of such filing to all counsel of record.")),
    styled("GAND Certificate Body", words("This " .. str(need(meta, "service_text")) .. ".")),
    styled("GAND Signature Right", words("s/ " .. str(need(s, "signer")))),
  }
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end

  -- The body is unnumbered (a brief is not pleaded in numbered paragraphs): headings, paragraphs with the
  -- first-line indent, block quotations and footnotes come from pandoc and the reference styles.
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end

  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(font_certificate(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(service_certificate(meta)) do blocks[#blocks + 1] = b end

  -- pandoc writes the title, date and author metadata as a title block at the top of the document; the cover
  -- above already carries them, so they are dropped here.
  local out_meta = {}
  for k, v in pairs(meta) do out_meta[k] = v end
  out_meta.title, out_meta.subtitle, out_meta.author, out_meta.date = nil, nil, nil, nil
  return pandoc.Pandoc(blocks, out_meta)
end
