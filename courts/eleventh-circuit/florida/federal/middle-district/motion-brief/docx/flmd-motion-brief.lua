-- flmd motion with legal memorandum, pandoc filter for docx/reference.docx. The layout follows
-- motion-brief/typst/flmd-motion-brief.typ: court title and caption, lead-in, indented body paragraphs (not
-- numbered: memoranda are not pleadings), lettered lists, headings levels 1 to 4, the signature block (Local Rule
-- 3.01(g) certificate first), and the certificate of service printed after the signature as one kept-together block.
-- Rule-driven and content-agnostic: everything comes from the sample's YAML frontmatter. Styles: reference.docx.

local function plain(x)
  return pandoc.utils.stringify(x)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- A paragraph in a named paragraph style (see reference.docx).
local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function gap(style)
  return styled(style or "CaptionGap", {})
end

-- Raw WordprocessingML paragraph, for the caption table and the cover (exact spacing and indents).
local function xp(style, s, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. '</w:pPr>'
    .. '<w:r><w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r></w:p>'
end

-- Party column (names, designations, "v." between parties, closing rule) and the case number column.
-- Widths in twips: 2.9 in party column, 0.25 in gutter, the rest (3.35 in) for the number.
local function caption_block(meta)
  local versus = meta.caption.versus and plain(meta.caption.versus) or "v."
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = xp("CaptionLine", versus)
    end
    for _, n in ipairs(p.names) do
      left[#left + 1] = xp("CaptionLine", plain(n))
    end
    left[#left + 1] = xp("CaptionLine", plain(p.designation), '<w:ind w:left="720"/>')
  end
  left[#left + 1] = xp("CaptionLine", string.rep("_", 28) .. "/")
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4176"/><w:gridCol w:w="360"/><w:gridCol w:w="4824"/></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4824" w:type="dxa"/></w:tcPr>'
    .. xp("CaptionLine", "CASE NO.: " .. plain(meta.case_number), '<w:spacing w:before="720"/>')
    .. '</w:tc></w:tr></w:tbl>'
end

local function cover(meta)
  local out = {}
  out[#out + 1] = pandoc.RawBlock("openxml", xp("CoverTitle", "UNITED STATES DISTRICT COURT", '<w:spacing w:after="140"/>'))
  out[#out + 1] = pandoc.RawBlock("openxml", xp("CoverTitle", "MIDDLE DISTRICT OF FLORIDA", '<w:spacing w:after="140"/>'))
  if meta.division then
    out[#out + 1] = pandoc.RawBlock("openxml", xp("CoverTitle", string.upper(plain(meta.division))))
  end
  out[#out + 1] = gap()
  out[#out + 1] = pandoc.RawBlock("openxml", caption_block(meta))
  out[#out + 1] = gap()
  out[#out + 1] = styled("CoverTitle", { pandoc.Str(plain(meta.brief_title)) })
  out[#out + 1] = gap()
  if meta.lead_in then
    out[#out + 1] = styled("IndentedPara", pandoc.utils.blocks_to_inlines(
      pandoc.read(plain(meta.lead_in), "markdown").blocks))
  end
  return out
end

-- The signature block (Fed. R. Civ. P. 11(a)): "Respectfully submitted," then the firm, each counsel's
-- s/ line and details, the address and "Attorneys for ..." at 3 inches, single-spaced, kept as one block.
local function signature(meta)
  local out = {}
  out[#out + 1] = gap("KeepGap")
  out[#out + 1] = styled("SignatureOpen", { pandoc.Str("Respectfully submitted,") })
  out[#out + 1] = gap("KeepGap")
  for _, f in ipairs(meta.signature.firm) do
    out[#out + 1] = styled("SignatureLine", { pandoc.Str(plain(f)) })
  end
  out[#out + 1] = gap("KeepGap")
  for _, counsel in ipairs(meta.signature.counsel) do
    for _, l in ipairs(counsel) do
      out[#out + 1] = styled("SignatureLine", { pandoc.Str(plain(l)) })
    end
    out[#out + 1] = gap("KeepGap")
  end
  for _, l in ipairs(meta.signature.address) do
    out[#out + 1] = styled("SignatureLine", { pandoc.Str(plain(l)) })
  end
  out[#out + 1] = styled("SignatureLine", { pandoc.Str(plain(meta.signature["for"])) })
  return out
end

-- One body block. keep=true keeps it with the next block (the certificate moves whole).
local function body_block(b, keep)
  if b.t == "Para" then
    local first, second = b.content[1], b.content[2]
    if first and first.t == "Str" and first.text == "~" and second and second.t == "Space" then
      -- `~ text`: no first-line indent (certificate lines, signature lines); a hard break inside it is kept.
      local rest = {}
      for i = 3, #b.content do
        rest[#rest + 1] = b.content[i]
      end
      return styled(keep and "KeepUnindented" or "UnindentedPara", rest)
    end
    return styled(keep and "KeepIndented" or "IndentedPara", b.content)
  elseif b.t == "OrderedList" then
    -- Lettered items (a), (b), ... as the typst enum does.
    local out = {}
    for i, item in ipairs(b.content) do
      local label = "(" .. string.char(96 + i) .. ")"
      local first = item[1]
      if first and (first.t == "Plain" or first.t == "Para") then
        local inl = { pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. label .. '</w:t></w:r><w:r><w:tab/></w:r>') }
        for _, x in ipairs(first.content) do
          inl[#inl + 1] = x
        end
        out[#out + 1] = styled("LetteredItem", inl)
        for j = 2, #item do
          out[#out + 1] = item[j]
        end
      else
        out[#out + 1] = pandoc.Div(item, { ["custom-style"] = "LetteredItem" })
      end
    end
    return pandoc.Div(out)
  end
  return b
end

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc would print `date` as a title block; the sample's date (if any) is not used here.
  meta.date = nil
  local blocks = doc.blocks
  -- The certificate of service follows the signature block, as in the typst template.
  local cert_at = nil
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content) == "CERTIFICATE OF SERVICE" then
      cert_at = i
      break
    end
  end
  local out = cover(meta)
  for i = 1, (cert_at and cert_at - 1 or #blocks) do
    out[#out + 1] = body_block(blocks[i], false)
  end
  for _, b in ipairs(signature(meta)) do
    out[#out + 1] = b
  end
  if cert_at then
    for i = cert_at, #blocks do
      -- Every block of the certificate but the last is kept with the next: the certificate moves as one block.
      out[#out + 1] = body_block(blocks[i], i < #blocks)
    end
  end
  return pandoc.Pandoc(out, meta)
end
