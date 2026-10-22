-- Tax Court pretrial memorandum for pandoc's docx writer. Matches typst/tax-pretrial-memorandum.typ.
-- The caption, the form fields, the attorney block, the amounts table, the status boxes and the signature
-- block come from the YAML frontmatter (the same keys the typst template reads). The narrative sections are
-- pandoc's own markdown rendering, styled by reference.docx (fb render builds it from docx/reference.xml). No case-specific text and
-- no forced line breaks live here.

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

local TAB = "<w:r><w:tab/></w:r>"

-- A paragraph of a named style. ppr is the direct paragraph properties, already in schema order.
local function para(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. inner .. "</w:p>"
end

-- The label of a field or a section: bold, single-spaced, with the space above it (0 when first).
local function label(text, before)
  return para("CaptionCell", run(text, true),
    '<w:keepNext/><w:spacing w:before="' .. (before or 0) .. '" w:after="84" w:line="294" w:lineRule="exact"/>')
end

-- A drawn check box: a bordered run (no font glyph, so no fallback), with an X when checked.
local function checkbox(checked)
  local glyph = checked and "\u{A0}X\u{A0}" or "\u{A0}\u{A0}\u{A0}"
  return '<w:r><w:rPr><w:bdr w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:rPr><w:t xml:space="preserve">'
    .. glyph .. "</w:t></w:r>"
end

local function option(text, on)
  return checkbox(on) .. run("\u{A0}" .. text, false)
end

local function cell(width, paras, top_rule)
  local borders = top_rule and '<w:tcBorders><w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. borders .. "</w:tcPr>" .. paras .. "</w:tc>"
end

local function grid_xml(widths)
  local g = ""
  for _, w in ipairs(widths) do g = g .. '<w:gridCol w:w="' .. w .. '"/>' end
  return "<w:tblGrid>" .. g .. "</w:tblGrid>"
end

-- A table with no borders and no cell margins: the caption, the attorney block and the signature block.
local function plain_table(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders>' .. none
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. grid_xml(widths) .. rows .. "</w:tbl>"
end

-- A table with the Table style's rules (0.5 pt on every edge), for the amounts in dispute.
local function ruled_table(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  return '<w:tbl><w:tblPr><w:tblStyle w:val="Table"/><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. grid_xml(widths) .. rows .. "</w:tbl>"
end

local function row(cells, header)
  local trpr = header and "<w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>" or "<w:trPr><w:cantSplit/></w:trPr>"
  return "<w:tr>" .. trpr .. cells .. "</w:tr>"
end

-- Caption (Rule 23(a)(1)): the same rows as the petition's caption, with the docket number.
local CAPTION_W = { 5760, 432, 3168 }
local function caption_rows(names, docket)
  local rows = {}
  local function add(left, indent, mid, right)
    local lpara = para("CaptionCell", run(left, false), indent and ('<w:ind w:left="' .. indent .. '" w:firstLine="0"/>') or "")
    local mpara = para("CaptionCell", run(mid, false), '<w:jc w:val="center"/>')
    local rpara = para("CaptionCell", run(right, false))
    rows[#rows + 1] = row(cell(CAPTION_W[1], lpara) .. cell(CAPTION_W[2], mpara) .. cell(CAPTION_W[3], rpara))
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

-- The names as one phrase: "A and B", or "A".
local function names_phrase(names)
  if #names == 1 then return names[1] end
  local head = {}
  for i = 1, #names - 1 do head[#head + 1] = names[i] end
  return table.concat(head, ", ") .. " and " .. names[#names]
end

-- Form fields: a borderless table, the label in a 3.6 in column and the value in the 2.9 in column that
-- follows (single-spaced, 0.9 em between fields). Fields are rows of one table, so they stay aligned.
local FIELD_W = { 5184, 4176 }
local function field_row(text, value)
  local sp = '<w:spacing w:before="0" w:after="252" w:line="294" w:lineRule="exact"/>'
  return row(cell(FIELD_W[1], para("CaptionCell", run(text, true), sp)) .. cell(FIELD_W[2], para("CaptionCell", run(value, false), sp)))
end

local function attorney_lines(a)
  local lines = { para("CaptionCell", run(str(a.name), false), '<w:keepNext/>') }
  if a.tel then lines[#lines + 1] = para("CaptionCell", run("Tel. No.: " .. str(a.tel), false), '<w:keepNext/>') end
  if a.email then lines[#lines + 1] = para("CaptionCell", run("Email: " .. str(a.email), false), '<w:keepNext/>') end
  return table.concat(lines)
end

local function form_block(meta)
  local out = {}
  local function add(x) out[#out + 1] = x end
  local party_names = {}
  for _, n in ipairs(meta.petitioners) do party_names[#party_names + 1] = str(n) end
  local frows = {}
  frows[#frows + 1] = field_row("NAME OF CASE:", names_phrase(party_names) .. " v. Commissioner of Internal Revenue")
  frows[#frows + 1] = field_row("DOCKET NO(S).:", str(meta.docket_no))
  frows[#frows + 1] = field_row("TRIAL CALENDAR:", str(meta.trial_calendar))
  add(plain_table(FIELD_W, table.concat(frows)))

  -- Attorneys: two columns, 3.1 in each with a 0.3 in gutter.
  add(label("ATTORNEYS:", 0))
  local att = meta.attorneys
  local p_cell = para("CaptionCell", run("Petitioner:", true), '<w:keepNext/>') .. attorney_lines(att.petitioner)
  local r_cell = para("CaptionCell", run("Respondent:", true), '<w:keepNext/>') .. attorney_lines(att.respondent)
  add(plain_table({ 4464, 432, 4464 }, row(cell(4464, p_cell) .. cell(432, para("CaptionCell", "")) .. cell(4464, r_cell)))
    .. para("CaptionCell", "", '<w:spacing w:before="0" w:after="0" w:line="252" w:lineRule="exact"/>'))

  -- Amounts in dispute: a ruled table, the header in bold, 1 : 1.6 : 1.6 columns.
  add(label("AMOUNTS IN DISPUTE:", 0))
  local aw = { 2229, 3566, 3565 }
  local rows = {}
  rows[#rows + 1] = row(cell(aw[1], para("CaptionCell", run("Year(s)/Period(s)", true)))
    .. cell(aw[2], para("CaptionCell", run("Deficiencies/Liabilities", true)))
    .. cell(aw[3], para("CaptionCell", run("Additions/Penalties", true))), true)
  for _, a in ipairs(meta.amounts) do
    rows[#rows + 1] = row(cell(aw[1], para("CaptionCell", run(str(a.years), false)))
      .. cell(aw[2], para("CaptionCell", run(str(a.deficiency), false)))
      .. cell(aw[3], para("CaptionCell", run(str(a.additions), false))))
  end
  add(ruled_table(aw, table.concat(rows))
    .. para("CaptionCell", "", '<w:spacing w:before="0" w:after="0" w:line="252" w:lineRule="exact"/>'))

  -- Status of the case: one box for each status, in three columns.
  local status = str(meta.status)
  add(label("STATUS OF CASE:", 0))
  add(para("CaptionCell",
    option("Probable Settlement", status == "probable-settlement") .. TAB
    .. option("Probable Trial", status == "probable-trial") .. TAB
    .. option("Definite Trial", status == "definite-trial"),
    '<w:keepNext/><w:tabs><w:tab w:val="left" w:pos="3120"/><w:tab w:val="left" w:pos="6240"/></w:tabs>'
    .. '<w:spacing w:before="0" w:after="252" w:line="294" w:lineRule="exact"/>'))

  add(para("CaptionCell", run("CURRENT ESTIMATE OF TRIAL TIME:", true) .. run(" " .. str(meta.trial_time) .. " hour(s)", false),
    '<w:spacing w:before="0" w:after="252" w:line="294" w:lineRule="exact"/>'))

  local stip = str(meta.stipulation_status)
  add(label("STATUS OF STIPULATION OF FACTS:", 0))
  add(para("CaptionCell",
    option("Completed, will be filed electronically", stip == "completed") .. TAB
    .. option("In Progress", stip == "in-progress"),
    '<w:tabs><w:tab w:val="left" w:pos="4680"/></w:tabs>'
    .. '<w:spacing w:before="0" w:after="252" w:line="294" w:lineRule="exact"/>'))

  return table.concat(out)
end

-- Signature block (Rule 23(a)(2)-(3)): the date on the left, a rule and the name and contact lines on the right.
local function signature_block(meta, date)
  local sig = meta.signature
  local lines = { para("CaptionCell", run(str(sig.signer), false), '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="294" w:lineRule="exact"/>') }
  for _, l in ipairs(sig.lines) do
    lines[#lines + 1] = para("CaptionCell", run(str(l), false), '<w:keepNext/>')
  end
  local right = para("CaptionCell", "", '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="168" w:lineRule="exact"/>')
    .. table.concat(lines)
  local left = para("CaptionCell", run("Dated: " .. date, false), '<w:keepNext/>')
  return plain_table({ 4752, 4608 }, row(cell(4752, left) .. cell(4608, right, true)))
end

-- "(a)" paragraphs are read by pandoc as lettered lists. Each item becomes a body paragraph with its label
-- typed in the text, as the typst template sets them.
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
    else m = tostring(n) end
    local lab
    if a.delimiter == "TwoParens" then lab = "(" .. m .. ")"
    elseif a.delimiter == "OneParen" then lab = m .. ")"
    else lab = m .. "." end
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inl = { pandoc.Str(lab), pandoc.Space() }
      for _, x in ipairs(first.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Para(inl)
      for j = 2, #item do out[#out + 1] = item[j] end
    else
      for _, b in ipairs(item) do out[#out + 1] = b end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local party = str(meta.party)
  if party ~= "petitioner" and party ~= "respondent" then
    error("tax-pretrial-memorandum: `party` must be `petitioner` or `respondent`")
  end
  local date = str(meta.date)
  meta.date = nil -- pandoc would print it as a title-block date at the top of page 1
  local body = pandoc.Pandoc(doc.blocks):walk({ OrderedList = convert_list })

  local names = {}
  for _, n in ipairs(meta.petitioners) do names[#names + 1] = str(n) end
  names.n = #names
  local docket = "Docket No. " .. str(meta.docket_no)

  local blocks = {}
  local function raw(x) blocks[#blocks + 1] = pandoc.RawBlock("openxml", x) end

  raw(para("CourtTitle", run("UNITED STATES TAX COURT", true), '<w:spacing w:before="0" w:after="420" w:line="294" w:lineRule="exact"/>'))
  raw(caption_rows(names, docket))
  local who = party == "petitioner" and "PETITIONER" or "RESPONDENT"
  raw(para("CourtTitle", run("PRETRIAL MEMORANDUM FOR " .. who, true), '<w:keepNext/><w:spacing w:before="560" w:after="280" w:line="294" w:lineRule="exact"/>'))
  raw(form_block(meta))

  for _, b in ipairs(body.blocks) do blocks[#blocks + 1] = b end

  raw('<w:p><w:pPr><w:pStyle w:val="CaptionCell"/><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/></w:pPr></w:p>')
  raw(signature_block(meta, date))

  return pandoc.Pandoc(blocks, meta)
end
