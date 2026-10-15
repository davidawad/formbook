-- gamd-complaint.lua: pandoc filter for the complaint .docx (engine "docx").
-- It lays the sample out the way typst/gamd-complaint.typ does: court heading, caption, title, lead-in, numbered
-- allegations (Fed. R. Civ. P. 10(b)), headings, the lettered prayer, and the signature block. Every case-specific
-- word comes from the sample's YAML frontmatter; nothing in this file is case text. Styles are in reference.docx.

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function inlines_of(s)
  return pandoc.utils.blocks_to_inlines(pandoc.read(s, "markdown+smart").blocks)
end

-- A block (or blocks) carrying a named paragraph style; pandoc's docx writer applies custom-style to its paragraphs.
local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- Plain text from the frontmatter (court, signature and address lines): no markdown, so "(404)" stays as written.
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

-- Raw WordprocessingML paragraph, for the parts pandoc cannot express (fields, caption table cells).
local function xp(style, s, rpr)
  local run = ""
  if s ~= "" then
    run = '<w:r>' .. (rpr or "") .. '<w:t xml:space="preserve">' .. xesc(s) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. run .. '</w:p>'
end

-- ---------------------------------------------------------------------------
-- Cover: court heading, caption (a borderless table; the party column has a right rule, as the ")" column
-- does in the typst template), title.
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
  local jury = meta.jury_demand == true
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
    elseif k == 2 and jury then
      right = xp("CaptionRight", "JURY TRIAL DEMANDED", "<w:rPr><w:b/><w:bCs/></w:rPr>")
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
-- Signature page. Elements are lists of lines; each element's last line takes the gap (the typst stack spacing).
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

local function signature(meta)
  local sig = meta.signature
  local out = {}
  local groups = {}
  for _, g in ipairs(sig.signers) do
    local lines = {}
    for _, x in ipairs(g) do lines[#lines + 1] = pandoc.utils.stringify(x) end
    groups[#groups + 1] = lines
  end
  local firm = {}
  for _, x in ipairs(sig.firm) do firm[#firm + 1] = pandoc.utils.stringify(x) end
  local elements = { firm }
  for _, g in ipairs(groups) do elements[#elements + 1] = g end
  for _, b in ipairs(lines_of(elements, "SignatureBlock", "SignatureBlockGap")) do out[#out + 1] = b end

  -- Lead counsel (L.R. 83.1.2(A)): the name, and the address and telephone below, on the signature page.
  local addr = {}
  if sig.lead_counsel then addr[1] = "Lead Counsel: " .. pandoc.utils.stringify(sig.lead_counsel) end
  for _, x in ipairs(sig.address) do addr[#addr + 1] = pandoc.utils.stringify(x) end
  local attorney = {}
  for _, x in ipairs(sig.attorney_for) do attorney[#attorney + 1] = pandoc.utils.stringify(x) end
  for _, b in ipairs(lines_of({ addr }, "AddressBlock", "AddressBlockGap")) do out[#out + 1] = b end
  for _, b in ipairs(lines_of({ attorney }, "AddressBlock", "AddressBlock")) do out[#out + 1] = b end
  return out
end

-- ---------------------------------------------------------------------------
-- Body: numbered allegations, headings, the lettered prayer
-- ---------------------------------------------------------------------------

local allegation = 0

-- The prayer letter "(a)" followed by a tab. The letter is a SEQ field (\r 1 restarts the list at the first item).
local function prayer_label(i)
  return pandoc.RawInline("openxml",
    '<w:r><w:t>(</w:t></w:r>'
    .. '<w:fldSimple w:instr=" SEQ Prayer ' .. (i == 1 and '\\r 1 ' or '') .. '\\* alphabetic "><w:r><w:t>'
    .. string.char(96 + i) .. '</w:t></w:r></w:fldSimple>'
    .. '<w:r><w:t>)</w:t></w:r><w:r><w:tab/></w:r>')
end

-- The paragraph number: a Word sequence field (SEQ) with the number cached, so every viewer shows it and Word
-- renumbers it if a paragraph is added. The "." is ordinary text, outside the field.
local function number_block()
  allegation = allegation + 1
  return pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="AllegationNumber"/></w:pPr>'
    .. '<w:fldSimple w:instr=" SEQ Allegation \\* ARABIC "><w:r><w:t>' .. allegation .. '</w:t></w:r></w:fldSimple>'
    .. '<w:r><w:t>.</w:t></w:r></w:p>')
end

local function body(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      local s = pandoc.utils.stringify(b)
      if s:match("^WHEREFORE") then
        -- the request for relief is not a numbered allegation (Fed. R. Civ. P. 10(b))
        out[#out + 1] = styled("AllegationText", { b })
      else
        out[#out + 1] = number_block()
        out[#out + 1] = styled("AllegationText", { b })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- the prayer: items lettered (a), (b), ... as in the typst template. Each item is a paragraph with a hanging
      -- indent (marker at 0.5 in, text at 0.9 in) and a SEQ field for the letter, so Word can renumber it.
      for i, item in ipairs(b.content) do
        local first = true
        local blocks = {}
        for _, blk in ipairs(item) do
          if first then
            local lead = pandoc.Inlines({ prayer_label(i, true) })
            lead:extend(blk.content)
            blocks[#blocks + 1] = pandoc.Plain(lead)
            first = false
          else
            blocks[#blocks + 1] = blk
          end
        end
        out[#out + 1] = styled("PrayerItem", blocks)
      end
    else
      out[#out + 1] = b
    end
  end
  return out
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
  out[#out + 1] = styled("CoverTitle", { pandoc.Para(inlines_of(pandoc.utils.stringify(meta.title))) })
  if meta.lead_in then
    out[#out + 1] = styled("AllegationText", { pandoc.Para(inlines_of(pandoc.utils.stringify(meta.lead_in))) })
  end

  for _, b in ipairs(body(doc.blocks)) do out[#out + 1] = b end

  out[#out + 1] = para("SignatureLead", "Respectfully submitted " .. pandoc.utils.stringify(meta.date) .. ".")
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  return pandoc.Pandoc(out)
end
