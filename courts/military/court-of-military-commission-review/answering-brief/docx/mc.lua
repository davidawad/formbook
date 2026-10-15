-- USCMCR brief (appellant or appellee), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document
-- on reference.docx. The layout is the typst template's (typst/mc-*.typ): the cover (caption, honorable line,
-- counsel), the table of contents, the body, the closing signature block and the two certificates are built
-- here; the body keeps its markdown structure. The cover and the table of contents are their own section with
-- no footer; the body numbers its pages from 1 (reference.docx footer). Layout values are in reference.docx
-- (docx/build-reference.sh). Known limits (BLOCKED, see the PR and ../README.md "Engines"): the table of
-- contents is a TOC field whose cached entries carry no page numbers (a field update adds them in Word and
-- LibreOffice); the certificates and signature blocks are not numbered.

-- Rules cited by the certificates (the typst template's constants; the rule text is unverified, see the README).
local TYPE_VOLUME_RULE = "Rule 14(i)"
local TYPEFACE_RULE = "Rule 14(e)"
local COURT_LINE = "IN THE UNITED STATES COURT OF MILITARY COMMISSION REVIEW"
local HONORABLE_LINE = "TO THE HONORABLE, THE JUDGES OF THE COURT OF MILITARY COMMISSION REVIEW"

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- a metadata value (markdown inlines) as an inline list
local function inl(v)
  local out = pandoc.Inlines({})
  if v == nil then return out end
  if type(v) == "string" then
    if v ~= "" then out:insert(pandoc.Str(v)) end
    return out
  end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  if v.t == "MetaInlines" or v.t == nil then
    for _, x in ipairs(v) do out:insert(x) end
    return out
  end
  local s = pandoc.utils.stringify(v)
  if s ~= "" then out:insert(pandoc.Str(s)) end
  return out
end

-- inline list concatenation: a list of inline lists or strings
local function join(...)
  local out = pandoc.Inlines({})
  for _, part in ipairs({ ... }) do
    if type(part) == "string" then
      if part ~= "" then out:insert(pandoc.Str(part)) end
    else
      for _, x in ipairs(part) do out:insert(x) end
    end
  end
  return out
end

local function raw(s) return pandoc.RawBlock("openxml", s) end

-- an empty paragraph of exact height (twips), e.g. the typst v(1em) gaps
local function spacer(twips, keep_next)
  return raw('<w:p><w:pPr>' .. (keep_next and '<w:keepNext/>' or '')
    .. '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

local function styled(style, content)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function heading_raw(text)
  return raw('<w:p><w:pPr><w:pStyle w:val="Heading1"/><w:pageBreakBefore/></w:pPr><w:r><w:t>' .. text .. '</w:t></w:r></w:p>')
end

local function group_digits(s)
  local n = tostring(s):match("^%d+$") and tostring(s) or nil
  if not n then return tostring(s) end
  local out = n:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- the caption: two sides, one row per line, a parenthesis column between them (typst caption())
local function caption_table(caption)
  local L = caption.left or {}
  local R = caption.right or {}
  local n = math.max(#L, #R)
  local rows = {}
  for i = 1, n do
    local cells = {
      pandoc.Cell({ styled("CaptionCell", inl(L[i])) }),
      pandoc.Cell({ styled("CaptionCell", pandoc.Inlines({ pandoc.Str(")") })) }),
      pandoc.Cell({ styled("CaptionCell", inl(R[i])) }),
    }
    rows[#rows + 1] = pandoc.Row(cells)
  end
  return pandoc.Table(
    pandoc.Caption(),
    { { pandoc.AlignDefault, 3.1 / 6.5 }, { pandoc.AlignDefault, 0.3 / 6.5 }, { pandoc.AlignDefault, 3.1 / 6.5 } },
    pandoc.TableHead({}),
    { pandoc.TableBody(rows) },
    pandoc.TableFoot({})
  )
end

-- the signature block (typst signature()): "//s//" before the signer's name, the lines in italics; with
-- `closing`, it starts with the date and "Respectfully submitted,". It is kept together (keepNext chain).
local function signature(meta, closing)
  local out = {}
  local sig = meta.signature or {}
  if closing then
    out[#out + 1] = spacer(360, true)
    out[#out + 1] = styled("Signature", join("Dated: ", inl(meta.date)))
    out[#out + 1] = spacer(360, true)
    out[#out + 1] = styled("Signature", join("Respectfully submitted,"))
    out[#out + 1] = spacer(240, true)
  end
  out[#out + 1] = styled("Signature", join("//s// ", inl(sig.signer)))
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do
    local style = (i == #lines) and "SignatureEnd" or "Signature"
    out[#out + 1] = styled(style, { pandoc.Emph(inl(l)) })
  end
  if #lines == 0 then
    -- the signer line is the last one
    out[#out] = styled("SignatureEnd", join("//s// ", inl(sig.signer)))
  end
  return out
end

-- the table of contents entries (depth 2, typst outline(depth: 2)): the cached result of a TOC field
local function toc_blocks(entries)
  local out = {}
  if #entries == 0 then return out end
  for i, e in ipairs(entries) do
    local content = pandoc.Inlines({})
    if i == 1 then
      content:insert(pandoc.RawInline("openxml",
        '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'))
    end
    content:insert(pandoc.Str(e.text))
    if i == #entries then
      content:insert(pandoc.RawInline("openxml", '<w:r><w:fldChar w:fldCharType="end"/></w:r>'))
    end
    out[#out + 1] = styled(e.level == 1 and "TOCLevel1" or "TOCLevel2", content)
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta

  -- body headings, depth 2 (for the table of contents)
  local body = doc.blocks
  local entries = {}
  for _, b in ipairs(body) do
    if b.t == "Header" and b.level <= 2 then
      entries[#entries + 1] = { level = b.level, text = pandoc.utils.stringify(b.content) }
    end
  end
  local cert_compliance, cert_service = "CERTIFICATE OF COMPLIANCE", "CERTIFICATE OF SERVICE"
  entries[#entries + 1] = { level = 1, text = cert_compliance }
  entries[#entries + 1] = { level = 1, text = cert_service }

  local out = {}
  local function add(list) for _, b in ipairs(list) do out[#out + 1] = b end end
  local function push(b) out[#out + 1] = b end

  -- ---- cover (typst: the unnumbered first page) ----
  push(styled("Centered", { pandoc.Strong(pandoc.Inlines({ pandoc.Str(COURT_LINE) })) }))
  push(spacer(480))
  push(caption_table(meta.caption or {}))
  push(spacer(480))
  push(styled("Centered", { pandoc.Strong(pandoc.Inlines({ pandoc.Str(HONORABLE_LINE) })) }))
  push(spacer(480))
  for _, g in ipairs(meta.counsel or {}) do
    for _, n in ipairs(g.names or {}) do push(styled("Counsel", inl(n))) end
    for _, l in ipairs(g.lines or {}) do push(styled("Counsel", { pandoc.Emph(inl(l)) })) end
    push(spacer(240))
  end

  -- ---- table of contents (its own section, no footer) ----
  push(raw('<w:p><w:pPr><w:pStyle w:val="Centered"/><w:pageBreakBefore/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>TABLE OF CONTENTS</w:t></w:r></w:p>'))
  push(spacer(240))
  add(toc_blocks(entries))
  -- section break: the section that ends here has no footer
  push(raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:pPr></w:p>'))

  -- ---- body (numbered from 1 by the reference footer) ----
  add(body)

  -- ---- after the conclusion: the signature, then the certificates ----
  add(signature(meta, true))

  push(heading_raw(cert_compliance))
  push(styled("CertPara", join("1. This brief complies with the type-volume limitation of " .. TYPE_VOLUME_RULE
    .. " because it contains " .. group_digits(plain(meta.word_count)) .. " words; and")))
  push(styled("CertPara", join("2. This brief complies with the typeface and style requirements of " .. TYPEFACE_RULE
    .. " because it has been prepared using " .. plain(meta.compliance and meta.compliance.typeface) .. ".")))
  push(spacer(240))
  push(styled("CertPara", join("Dated: ", inl(meta.date))))
  add(signature(meta, false))

  push(heading_raw(cert_service))
  push(styled("CertPara", inl(meta.service and meta.service.text)))
  add(signature(meta, false))

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
