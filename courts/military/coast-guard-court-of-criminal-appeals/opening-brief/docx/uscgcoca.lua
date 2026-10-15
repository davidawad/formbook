-- uscgcoca brief, DOCX engine (docs/DOCX.md): the sample's frontmatter becomes the caption, case block,
-- counsel block, signature block and the certificate of filing and service, laid out as in
-- typst/uscgcoca-*.typ (same order, same wording, same spacing in points). The body keeps its markdown
-- structure. Page numbers come from the footer of reference.docx.
-- Gaps are exact-height empty paragraphs (no forced line breaks in the text).

local COURT = "United States Coast Guard Court of Criminal Appeals"

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function items(v)
  local out = {}
  if v == nil then return out end
  if v.t == nil or v.t == "MetaList" then
    for _, x in ipairs(v) do out[#out + 1] = x end
  else
    out[#out + 1] = v
  end
  return out
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- an empty paragraph exactly `twips` tall (1 pt = 20 twips): the typst v(...) gaps
local function gap(twips)
  return pandoc.RawBlock("openxml", string.format(
    '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="%d" w:lineRule="exact"/></w:pPr></w:p>', twips))
end

-- the signature rule: a 3.2 in wide top border (right indent 4752 twips leaves 3.2 in of the 6.5 in measure)
local function signature_rule()
  return pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:keepNext/><w:pBdr><w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>'
    .. '<w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/><w:ind w:left="0" w:right="4752" w:firstLine="0"/></w:pPr></w:p>')
end

local function signature_lines(sig, date)
  local out = { signature_rule() }
  out[#out + 1] = styled("SignatureBlock", { pandoc.Str(plain(sig.signer)) })
  for _, l in ipairs(items(sig.lines)) do
    out[#out + 1] = styled("SignatureBlock", { pandoc.Str(plain(l)) })
  end
  if date then
    out[#out + 1] = styled("SignatureBlock", { pandoc.Str(date) })
  end
  return out
end

function Pandoc(doc)
  local m = doc.meta
  local date = m.date and plain(m.date) or nil
  -- pandoc would set the date in a title block at the top of the page; the date belongs to the certificate
  m.date = nil
  local front = {}
  local function add(b) front[#front + 1] = b end

  -- caption: "In the <court>", the parties, the brief title, the proceeding
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("In the " .. COURT) }) }))
  add(gap(144))
  local sides = items(m.caption)
  for i, side in ipairs(sides) do
    if i > 1 then add(styled("CaptionLine", { pandoc.Str("v.") })) end
    for _, n in ipairs(items(side.names)) do
      add(styled("CaptionLine", { pandoc.Str(plain(n)) }))
    end
    add(styled("CaptionLine", { pandoc.Str(plain(side.designation)) }))
  end
  add(gap(288))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(plain(m.brief_title)) }) }))
  add(gap(144))
  if m.proceeding then add(styled("CenteredSingle", { pandoc.Str(plain(m.proceeding)) })) end
  -- the space after the proceeding: 22.2 pt, so the first counsel line sits 37.8 pt below the last proceeding line
  add(gap(444))

  -- counsel block: names, then the rank, address and telephone lines in italics; 9.6 pt between groups,
  -- and 6 pt after the last one (the typst spacing before the signature and the first heading; see README)
  local groups = items(m.counsel)
  for gi, g in ipairs(groups) do
    for _, n in ipairs(items(g.names)) do add(styled("Single", { pandoc.Str(plain(n)) })) end
    for _, l in ipairs(items(g.lines)) do add(styled("Single", { pandoc.Emph({ pandoc.Str(plain(l)) }) })) end
    if gi < #groups then add(gap(192)) else add(gap(120)) end
  end

  local tail = {}
  if m.signature then
    tail[#tail + 1] = gap(360)
    for _, b in ipairs(signature_lines(m.signature, date)) do tail[#tail + 1] = b end
  end

  -- certificate of filing and service (App. B, item 8; wording as in the typst template), on a new page
  tail[#tail + 1] = styled("CertTitle", { pandoc.Strong({ pandoc.Str("CERTIFICATE OF FILING AND SERVICE") }) })
  tail[#tail + 1] = gap(240)
  tail[#tail + 1] = pandoc.Para({ pandoc.Str(
    "I certify that a copy of the foregoing was mailed or delivered to the Court and opposing counsel on "
    .. (date or "__________") .. ".") })
  tail[#tail + 1] = gap(480)
  local cert_sig = m.signature and m.signature or { signer = "", lines = {} }
  tail[#tail + 1] = signature_rule()
  tail[#tail + 1] = styled("SignatureBlock", { pandoc.Str(plain(cert_sig.signer)) })

  local blocks = {}
  for _, b in ipairs(front) do blocks[#blocks + 1] = b end
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  for _, b in ipairs(tail) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, m)
end
