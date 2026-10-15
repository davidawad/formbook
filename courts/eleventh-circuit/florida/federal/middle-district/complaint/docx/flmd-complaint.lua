-- flmd complaint, pandoc filter for docx/reference.docx. The layout follows complaint/typst/flmd-complaint.typ:
-- court title and caption (FRCP 10(a)), numbered paragraphs (FRCP 10(b)), lettered lists, the jury demand
-- (`~ ` chunk, indented, unnumbered) and the signature block. Rule-driven and content-agnostic: everything
-- comes from the sample's YAML frontmatter; no case text is written here. Styles are defined in reference.docx.

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

-- The signature block: "RESPECTFULLY SUBMITTED <date>.", then the firm, the s/ line and the counsel lines
-- at 3 inches, single-spaced, kept as one block (keep-with-next on each line).
local function signature(meta)
  local out = {}
  out[#out + 1] = gap("KeepGap")
  out[#out + 1] = styled("KeepIndented", { pandoc.Str("RESPECTFULLY SUBMITTED " .. plain(meta.date) .. ".") })
  out[#out + 1] = gap("KeepGap")
  local lines = {}
  for _, f in ipairs(meta.signature.firm) do
    lines[#lines + 1] = plain(f)
  end
  lines[#lines + 1] = "s/" .. plain(meta.signature.signer)
  for _, l in ipairs(meta.signature.lines) do
    lines[#lines + 1] = plain(l)
  end
  for _, l in ipairs(lines) do
    out[#out + 1] = styled("SignatureLine", { pandoc.Str(l) })
  end
  return out
end

local function is_jury_demand(b)
  local first, second = b.content[1], b.content[2]
  return first and first.t == "Str" and first.text == "~" and second and second.t == "Space"
end

function Pandoc(doc)
  local out = cover(doc.meta)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and is_jury_demand(b) then
      -- `~ text`: an unnumbered, indented paragraph (the jury demand).
      local rest = {}
      for i = 3, #b.content do
        rest[#rest + 1] = b.content[i]
      end
      out[#out + 1] = styled("IndentedPara", rest)
    elseif b.t == "Para" then
      -- Numbered paragraph (FRCP 10(b)): "N." then a tab to 1 inch; the text wraps to the margin.
      n = n + 1
      local inl = { pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. n .. '.</w:t></w:r><w:r><w:tab/></w:r>') }
      for _, x in ipairs(b.content) do
        inl[#inl + 1] = x
      end
      out[#out + 1] = styled("NumberedPara", inl)
    elseif b.t == "OrderedList" then
      -- Lettered items (a), (b), ... continuing across the list, as the typst enum does.
      for i, item in ipairs(b.content) do
        local label = "(" .. string.char(96 + i) .. ")"
        local first = item[1]
        local inl = { pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. label .. '</w:t></w:r><w:r><w:tab/></w:r>') }
        if first and (first.t == "Plain" or first.t == "Para") then
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
    else
      out[#out + 1] = b
    end
  end
  for _, b in ipairs(signature(doc.meta)) do
    out[#out + 1] = b
  end
  -- pandoc would print `date` as a title block; the date is in the signature block instead.
  local meta = doc.meta
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
