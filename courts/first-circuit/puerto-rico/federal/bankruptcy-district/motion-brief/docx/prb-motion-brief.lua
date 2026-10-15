-- prb motion brief (memorandum of law in support of a motion), DOCX engine (docs/DOCX.md).
-- Mirrors typst/prb-motion-brief.typ: the court lines, the caption (a two-column table: parties on the left with
-- a right and bottom rule, the case and adversary numbers on the right), the title, the lead-in, the body
-- (headings, paragraphs and block quotations pass through from the markdown; footnotes are pandoc's native
-- footnotes), the response-time NOTICE (LBR 9013-1(c)), the certificate of service (LBR 9013-3(a)) when the
-- frontmatter has one, and the signature block. Every case word comes from the sample; nothing here is
-- case-specific. Styles are defined in reference.docx.

local function inlines_of(v)
  if v == nil then return pandoc.Inlines({}) end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function cat(...)
  local out = pandoc.Inlines({})
  for _, part in ipairs({ ... }) do
    for _, x in ipairs(part) do out[#out + 1] = x end
  end
  return out
end

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- Table cells are written as raw WordprocessingML (pandoc cannot give a cell its own borders).
local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function runs(inl, flags)
  local out = {}
  for _, x in ipairs(inl) do
    if x.t == "Str" then
      local rpr = (flags.b and "<w:b/>" or "") .. (flags.i and "<w:i/>" or "")
      if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
      out[#out + 1] = '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(x.text) .. '</w:t></w:r>'
    elseif x.t == "Space" or x.t == "SoftBreak" then
      out[#out + 1] = runs(pandoc.Inlines({ pandoc.Str(" ") }), flags)
    elseif x.t == "Emph" then
      out[#out + 1] = runs(x.content, { b = flags.b, i = true })
    elseif x.t == "Strong" then
      out[#out + 1] = runs(x.content, { b = true, i = flags.i })
    elseif x.t == "Quoted" then
      local q = x.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = runs(pandoc.Inlines({ pandoc.Str(q[1]) }), flags)
      out[#out + 1] = runs(x.content, flags)
      out[#out + 1] = runs(pandoc.Inlines({ pandoc.Str(q[2]) }), flags)
    else
      out[#out + 1] = runs(pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(x)) }), flags)
    end
  end
  return table.concat(out)
end

local function para_xml(style, inl)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. runs(inl, {}) .. '</w:p>'
end

local RULE_XML = '<w:p><w:pPr><w:pStyle w:val="CaptionRule"/></w:pPr></w:p>'

-- caption: parties (left, 3.4 in, right and bottom rules) | gutter (0.2 in) | case numbers (2.9 in, 0.15 in in)
local function caption_table(left, right)
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="288"/><w:gridCol w:w="4176"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/><w:tcBorders>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '</w:tcBorders><w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa"/><w:tcMar><w:left w:w="216" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

local function caption(meta)
  assert(meta.bankruptcy_case, "prb-motion-brief: LBR 1005-1(a) requires bankruptcy_case in the frontmatter")
  assert(meta.chapter, "prb-motion-brief: LBR 1005-1(a) requires chapter in the frontmatter")
  local left = { para_xml("CaptionText", pandoc.Inlines({ pandoc.Str("In re:") })) }
  for _, n in ipairs(meta.debtor.names) do left[#left + 1] = para_xml("CaptionText", inlines_of(n)) end
  left[#left + 1] = para_xml("CaptionText", inlines_of(meta.debtor.designation))
  left[#left + 1] = RULE_XML
  for k, p in ipairs(meta.parties) do
    if k > 1 then left[#left + 1] = para_xml("CaptionText", pandoc.Inlines({ pandoc.Str("v.") })) end
    for _, n in ipairs(p.names) do left[#left + 1] = para_xml("CaptionText", inlines_of(n)) end
    left[#left + 1] = para_xml("CaptionText", inlines_of(p.designation))
  end
  local adv = pandoc.utils.stringify(meta.adversary or "")
  local adv_inl = adv == "" and pandoc.Inlines({ pandoc.Str("__________") }) or inlines_of(meta.adversary)
  local right = {
    para_xml("CaptionText", cat(pandoc.Inlines({ pandoc.Str("Bankr. Case No. ") }), inlines_of(meta.bankruptcy_case))),
    para_xml("CaptionText", inlines_of(meta.chapter)),
    para_xml("CaptionText", cat(pandoc.Inlines({ pandoc.Str("Adv. Proceeding No. ") }), adv_inl)),
  }
  return caption_table(left, right)
end

-- LBR 9013-1(c)(1): the response-time notice, in its own words (the period from LBR 9013-1(c)(2))
local DAYS = { ["14"] = "fourteen (14)", ["21"] = "twenty-one (21)", ["30"] = "thirty (30)" }
local function response_notice(meta)
  local days = pandoc.utils.stringify(meta.response_days or "14")
  assert(DAYS[days], "prb-motion-brief: LBR 9013-1(c)(2) gives a response period of 14, 21 or 30 days (response_days)")
  local text = "Within " .. DAYS[days] .. " days after service as evidenced by the certification, and an additional three (3) days pursuant to Fed. R. Bank. P. 9006(f) if you were served by mail, any party against whom this paper has been served, or any other party to the action who objects to the relief sought herein, shall serve and file an objection or other appropriate response to this paper with the clerk's office of the United States Bankruptcy Court for the District of Puerto Rico. If no objection or other response is filed within the time allowed herein, the paper will be deemed unopposed and may be granted unless: (i) the requested relief is forbidden by law; (ii) the requested relief is against public policy; or (iii) in the opinion of the court, the interest of justice requires otherwise."
  return {
    styled("Notice Heading", pandoc.Inlines({ pandoc.Str("NOTICE") })),
    styled("Notice Text", pandoc.Inlines({ pandoc.Str(text) })),
  }
end

local function signature(sig)
  assert(sig and sig.signer, "prb-motion-brief: the frontmatter needs signature.signer (LBR 5005-4(b)(2)(C)(ii))")
  local out = {
    styled("Signature Gap", pandoc.Inlines({ pandoc.Str("Respectfully submitted,") })),
    styled("Signature Gap", inlines_of(sig.date)),
    styled("Signature Indent Gap", cat(pandoc.Inlines({ pandoc.Str("/s/"), pandoc.Space() }), inlines_of(sig.signer))),
  }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = styled("Signature Indent", inlines_of(l)) end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  assert(meta.signature, "prb-motion-brief: the frontmatter needs a signature block (LBR 1005-1(c))")
  local out = {}
  for k, l in ipairs(meta.court) do
    out[#out + 1] = styled(k == #meta.court and "Court Title Last" or "Court Title", inlines_of(l))
  end
  out[#out + 1] = caption(meta)
  out[#out + 1] = styled("Caption Title", inlines_of(meta.title))
  out[#out + 1] = styled("Court Heading", pandoc.Inlines({ pandoc.Str("TO THE HONORABLE COURT:") }))
  if meta.lead_in then out[#out + 1] = pandoc.Para(inlines_of(meta.lead_in)) end
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end

  for _, b in ipairs(response_notice(meta)) do out[#out + 1] = b end
  if meta.certificate then
    out[#out + 1] = pandoc.Div({ pandoc.Para(cat(pandoc.Inlines({ pandoc.Str("CERTIFICATE OF SERVICE:"), pandoc.Space() }), inlines_of(meta.certificate))) },
      pandoc.Attr("", {}, { ["custom-style"] = "Certificate" }))
  end
  for _, b in ipairs(signature(meta.signature)) do out[#out + 1] = b end
  doc.meta.title = nil
  return pandoc.Pandoc(out, doc.meta)
end
