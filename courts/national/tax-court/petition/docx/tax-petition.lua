-- Tax Court petition (Rule 34(b)) for pandoc's docx writer. Matches typst/tax-petition.typ.
-- The caption, the title and the signature block come from the YAML frontmatter (the same keys the typst
-- template reads: petitioners, date, signature). The body is pandoc's own markdown rendering, styled by
-- reference.docx (build-reference.sh). No case-specific text and no forced line breaks live here.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function str(m)
  return pandoc.utils.stringify(m)
end

-- A run of text; bold when asked. Empty text gives no run.
local function run(text, bold)
  if text == "" then return "" end
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- A paragraph of a named style. ppr is the direct paragraph properties, already in schema order.
local function para(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. inner .. "</w:p>"
end

local function cell(width, paras, top_rule)
  local borders = top_rule and '<w:tcBorders><w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. borders .. "</w:tcPr>" .. paras .. "</w:tc>"
end

-- A table with no borders and no cell margins: the layout of the caption and the signature block.
local function plain_table(widths, rows)
  local total, grid = 0, ""
  for _, w in ipairs(widths) do
    total = total + w
    grid = grid .. '<w:gridCol w:w="' .. w .. '"/>'
  end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders>' .. none
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. "<w:tblGrid>" .. grid .. "</w:tblGrid>" .. rows .. "</w:tbl>"
end

-- Caption (Rule 23(a)(1)): the same rows as the typst template. Column 4.0 in, ")" gutter 0.3 in, right 2.2 in.
local CAPTION_W = { 5760, 432, 3168 }
local function caption_rows(names, docket)
  local rows = {}
  local function add(left, indent, mid, right)
    local lpara = para("CaptionCell", run(left, false), indent and ('<w:ind w:left="' .. indent .. '" w:firstLine="0"/>') or "")
    local mpara = para("CaptionCell", run(mid, false), '<w:jc w:val="center"/>')
    local rpara = para("CaptionCell", run(right, false))
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(CAPTION_W[1], lpara) .. cell(CAPTION_W[2], mpara) .. cell(CAPTION_W[3], rpara) .. "</w:tr>"
  end
  for _, n in ipairs(names) do add(n, nil, ")", "") end
  add("", nil, ")", "")
  add(names.n > 1 and "Petitioners," or "Petitioner,", 1728, ")", "")
  add("", nil, ")", "")
  add("v.", 864, ")", docket)
  add("", nil, ")", "")
  add("COMMISSIONER OF INTERNAL REVENUE,", nil, ")", "")
  add("", nil, ")", "")
  add("Respondent.", 1728, ")", "")
  return plain_table(CAPTION_W, table.concat(rows))
end

-- Signature block (Rule 23(a)(2)-(3)): the date on the left, a rule and the name and contact lines on the right.
local function signature_block(meta, date)
  local sig = meta.signature
  local lines = {}
  lines[#lines + 1] = para("CaptionCell", run(str(sig.signer), false), '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="294" w:lineRule="exact"/>')
  for _, l in ipairs(sig.lines) do
    lines[#lines + 1] = para("CaptionCell", run(str(l), false), '<w:keepNext/>')
  end
  -- The rule is the top border of the right cell; the space below it is 0.6 em, as in the typst template.
  local right = para("CaptionCell", "", '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="168" w:lineRule="exact"/>')
    .. table.concat(lines)
  local left = para("CaptionCell", run("Dated: " .. date, false), '<w:keepNext/>')
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(4752, left) .. cell(4608, right, true) .. "</w:tr>"
  return plain_table({ 4752, 4608 }, row)
end


-- "(a)" paragraphs are read by pandoc as lettered lists. The typst template sets them as body paragraphs
-- (first-line indent, the label typed in the text), so each item becomes a paragraph with its label.
local ROMAN = { "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x", "xi", "xii", "xiii", "xiv", "xv", "xvi", "xvii", "xviii", "xix", "xx" }
local function convert_list(el)
  local a = el.listAttributes
  local out = {}
  for i, item in ipairs(el.content) do
    local n = a.start + i - 1
    local m
    if a.style == "LowerAlpha" then m = string.char(96 + n)
    elseif a.style == "UpperAlpha" then m = string.char(64 + n)
    elseif a.style == "LowerRoman" then m = ROMAN[n] or tostring(n)
    elseif a.style == "UpperRoman" then m = (ROMAN[n] or tostring(n)):upper()
    else m = tostring(n) end
    local label
    if a.delimiter == "TwoParens" then label = "(" .. m .. ")"
    elseif a.delimiter == "OneParen" then label = m .. ")"
    else label = m .. "." end
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inl = { pandoc.Str(label), pandoc.Space() }
      for _, x in ipairs(first.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Para(inl)
      for j = 2, #item do out[#out + 1] = item[j] end
    elseif first == nil then
      out[#out + 1] = pandoc.Para({ pandoc.Str(label) })   -- a label alone on its line ("I.")
    else
      for _, b in ipairs(item) do out[#out + 1] = b end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local date = str(meta.date)
  meta.date = nil -- pandoc would print it as a title-block date at the top of page 1
  local body = pandoc.Pandoc(doc.blocks):walk({ OrderedList = convert_list })

  local names = {}
  for _, n in ipairs(meta.petitioners) do names[#names + 1] = str(n) end
  names.n = #names
  local docket = "Docket No. __________"
  if meta.docket_no then docket = "Docket No. " .. str(meta.docket_no) end

  local blocks = {}
  local function raw(x) blocks[#blocks + 1] = pandoc.RawBlock("openxml", x) end

  raw(para("CourtTitle", run("UNITED STATES TAX COURT", true), '<w:spacing w:before="0" w:after="420" w:line="294" w:lineRule="exact"/>'))
  raw(caption_rows(names, docket))
  raw(para("CourtTitle", run("PETITION", true), '<w:keepNext/><w:spacing w:before="560" w:after="280" w:line="294" w:lineRule="exact"/>'))

  for _, b in ipairs(body.blocks) do blocks[#blocks + 1] = b end

  raw('<w:p><w:pPr><w:pStyle w:val="CaptionCell"/><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/></w:pPr></w:p>')
  raw(signature_block(meta, date))

  return pandoc.Pandoc(blocks, meta)
end
