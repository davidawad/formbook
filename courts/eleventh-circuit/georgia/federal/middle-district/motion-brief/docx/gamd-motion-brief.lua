-- gamd-motion-brief.lua: pandoc filter for the brief supporting a motion, .docx (engine "docx").
-- It lays the sample out the way typst/gamd-motion-brief.typ does: court heading, caption, title, the body (headings
-- as typed, first-line indent on every paragraph, footnotes), and the signature block at each [[signature]] line
-- (or at the end). Every case-specific word comes from the sample's YAML frontmatter; styles are in reference.docx.

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end


-- A block carrying a named paragraph style; pandoc's docx writer applies custom-style to its paragraphs.
local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- Plain text from the frontmatter (court, caption, signature and address lines): no markdown, so "(404)" stays
-- as written.
local function plain_inlines(s)
  local out = pandoc.Inlines({})
  for word in pandoc.utils.stringify(s):gmatch("%S+") do
    if #out > 0 then out:insert(pandoc.Space()) end
    out:insert(pandoc.Str(word))
  end
  return out
end

local function para(style, s)
  return styled(style, { pandoc.Para(plain_inlines(s)) })
end

-- Raw WordprocessingML paragraph, for the caption table cells.
local function xp(style, s, rpr)
  local run = ""
  if s ~= "" then
    run = '<w:r>' .. (rpr or "") .. '<w:t xml:space="preserve">' .. xesc(s) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. run .. '</w:p>'
end

-- ---------------------------------------------------------------------------
-- Cover: court heading, caption (a borderless table; the party column has a right rule, as the ")" column does
-- in the typst template), title.
-- ---------------------------------------------------------------------------

local CAP_LEFT, CAP_GAP, CAP_RIGHT = 4752, 432, 4176 -- 3.3 in, 0.3 in, 2.9 in: the 6.5 in text width
local RIGHT_RULE = '<w:tcBorders><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders>'

local function cell(width, paras, borders)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. '</w:tcPr>'
    .. table.concat(paras) .. '</w:tc>'
end

local function row(...)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat({ ... }) .. '</w:tr>'
end

local function caption_table(meta)
  local label = meta.case_label and pandoc.utils.stringify(meta.case_label) or "Civil Action No."
  local number = pandoc.utils.stringify(meta.case_number or "")
  local rows = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      rows[#rows + 1] = row(
        cell(CAP_LEFT, { xp("CaptionName", "v.") }, RIGHT_RULE),
        cell(CAP_GAP, { xp("CaptionName", "") }),
        cell(CAP_RIGHT, { xp("CaptionRight", "") }))
    end
    local lines = {}
    for _, n in ipairs(p.names) do
      lines[#lines + 1] = xp("CaptionName", pandoc.utils.stringify(n))
    end
    lines[#lines + 1] = xp("CaptionDesignation", pandoc.utils.stringify(p.designation))
    local right = xp("CaptionRight", "")
    if k == 1 then
      right = xp("CaptionRight", ((label .. " " .. number):gsub("%s+$", "")))
    end
    rows[#rows + 1] = row(cell(CAP_LEFT, lines, RIGHT_RULE), cell(CAP_GAP, { xp("CaptionName", "") }),
      cell(CAP_RIGHT, { right }))
  end
  -- the closing rule under the parties
  local rule = '<w:p><w:pPr><w:pStyle w:val="CaptionName"/><w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr></w:pPr></w:p>'
  rows[#rows + 1] = row(cell(CAP_LEFT, { rule }, RIGHT_RULE), cell(CAP_GAP, { xp("CaptionName", "") }),
    cell(CAP_RIGHT, { xp("CaptionRight", "") }))
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GAP .. '"/><w:gridCol w:w="' .. CAP_RIGHT .. '"/></w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature block (L.R. 83.1.2(B): State Bar numbers on the signature page). Elements are lists of lines; each
-- element's last line takes the gap (the typst stack spacing). The lead-counsel line is optional (L.R. 83.1.2(A)).
-- ---------------------------------------------------------------------------

local function lines_of(elements, indent_style, gap_style)
  local out = {}
  for _, el in ipairs(elements) do
    for i, line in ipairs(el) do
      local style = i == #el and gap_style or indent_style
      out[#out + 1] = para(style, line)
    end
  end
  return out
end

local function strings(list)
  local out = {}
  for _, x in ipairs(list) do out[#out + 1] = pandoc.utils.stringify(x) end
  return out
end

local function signature(meta)
  local sig = meta.signature
  -- the closing line sits a line below the text (the typst block spacing), then the firm and the signers
  local out = { para("SignatureBlockFirst", "Respectfully submitted,") }
  local elements = { strings(sig.firm) }
  for _, g in ipairs(sig.signers) do elements[#elements + 1] = strings(g) end
  for _, b in ipairs(lines_of(elements, "SignatureBlock", "SignatureBlockGap")) do out[#out + 1] = b end

  local addr = {}
  if sig.lead_counsel then addr[1] = "Lead Counsel: " .. pandoc.utils.stringify(sig.lead_counsel) end
  for _, x in ipairs(strings(sig.address)) do addr[#addr + 1] = x end
  for _, b in ipairs(lines_of({ addr }, "AddressBlock", "AddressBlockGap")) do out[#out + 1] = b end
  for _, b in ipairs(lines_of({ strings(sig.attorney_for) }, "AddressBlock", "AddressBlock")) do out[#out + 1] = b end
  return out
end

-- ---------------------------------------------------------------------------
-- Document
-- ---------------------------------------------------------------------------

local function is_marker(b)
  return b.t == "Para" and pandoc.utils.stringify(b) == "[[signature]]"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, line in ipairs(meta.court) do
    out[#out + 1] = para("CourtHeading", pandoc.utils.stringify(line))
  end
  if meta.division then
    out[#out + 1] = para("CourtHeading", pandoc.utils.stringify(meta.division))
  end
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="BodyText"/></w:pPr></w:p>')
  out[#out + 1] = pandoc.RawBlock("openxml", caption_table(meta))
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="BodyText"/></w:pPr></w:p>')
  out[#out + 1] = styled("CoverTitle", { pandoc.Para(plain_inlines(pandoc.utils.stringify(meta.title))) })

  -- The body is one markdown document (footnotes work across it). A [[signature]] line places the signature block
  -- there (the certificate of service repeats it); without the marker, the block closes the document.
  local signed = false
  for _, b in ipairs(doc.blocks) do
    if is_marker(b) then
      for _, s in ipairs(signature(meta)) do out[#out + 1] = s end
      signed = true
    else
      out[#out + 1] = b
    end
  end
  if not signed then
    for _, s in ipairs(signature(meta)) do out[#out + 1] = s end
  end
  return pandoc.Pandoc(out)
end
