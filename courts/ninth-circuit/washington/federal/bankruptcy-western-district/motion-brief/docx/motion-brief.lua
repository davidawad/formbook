-- Motion with a combined memorandum, DOCX engine (docs/DOCX.md). The markdown contract -> one OpenXML body on
-- reference.docx, the same layout as ../typst/wawb-motion-brief.typ: the notation at the top right (the judge,
-- the chapter, the hearing location, date and time and the response date: LBR 9013-1(d)(1)(B)), the court title,
-- the caption (the debtor's case and the parties with a ")" column, a bottom rule under the parties; the case number
-- and the title at right), then the body on the 28-line grid. Paragraphs are not numbered (LBR 9013-1 does not number
-- them). Level 1 headings are centered caps; level 2 bold; level 3 italic. Block quotations are indented 0.5 in on
-- both sides and double spaced. The "Dated:" paragraph is kept whole on one page. Nothing case-specific is written
-- here: every word comes from the sample's frontmatter.

local GRID = 480     -- one numbered line (exact)
local SINGLE = 280   -- one single-spaced line (exact)
local TEXT_W = 9000  -- text width in twips (6.25 in)

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines -> runs; flags: b (bold), i (italic), caps (upper case the text)
local function runs(inl, flags)
  local out = {}
  local function run(text)
    if flags.caps then text = string.upper(text) end
    local rpr = ""
    if flags.b then rpr = rpr .. "<w:b/><w:bCs/>" end
    if flags.i then rpr = rpr .. "<w:i/><w:iCs/>" end
    out[#out + 1] = '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
      '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
  end
  for _, e in ipairs(inl) do
    local t = e.t
    if t == "Str" then run(e.text)
    elseif t == "Space" or t == "SoftBreak" then run(" ")
    elseif t == "LineBreak" then out[#out + 1] = '<w:r><w:br/></w:r>'
    elseif t == "Emph" then out[#out + 1] = runs(e.content, { b = flags.b, i = true, caps = flags.caps })
    elseif t == "Strong" then out[#out + 1] = runs(e.content, { b = true, i = flags.i, caps = flags.caps })
    elseif t == "Quoted" then
      local q = e.quotetype == "SingleQuote" and { "\u{2018}", "\u{2019}" } or { "\u{201C}", "\u{201D}" }
      run(q[1]); out[#out + 1] = runs(e.content, flags); run(q[2])
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(e.content, flags)
    else run(pandoc.utils.stringify(e)) end
  end
  return table.concat(out)
end

-- metadata value -> inlines (the frontmatter is markdown)
local function minl(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return (v[1] and v[1].content) or {} end
  if v.t == "MetaString" then return { pandoc.Str(v) } end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function mstr(v) return v == nil and "" or pandoc.utils.stringify(v) end

-- one paragraph: a style id, optional extra pPr XML, inlines and flags
local function P(inl, sid, ppr, flags)
  return '<w:p><w:pPr><w:pStyle w:val="' .. sid .. '"/>' .. (ppr or '') .. '</w:pPr>' ..
    runs(inl, flags or {}) .. '</w:p>'
end

-- an empty paragraph exactly `tw` twips high (a grid pad or a half line)
local function pad(tw)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. tw .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- lines a string takes at `cpl` characters per line (upper case is wider)
local function lines_of(s, cpl)
  if s == string.upper(s) then cpl = math.floor(cpl * 0.78) end
  return math.max(1, math.ceil(#s / cpl))
end

-- a table row's minimum height: whole grid lines around n single lines
local function row_h(n_single)
  return math.max(math.ceil(n_single * SINGLE / GRID) * GRID, GRID)
end

local function tbl(grid_cols, rows_xml)
  local cols = {}
  for _, w in ipairs(grid_cols) do cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' .. rows_xml .. '</w:tbl>'
end

local function cell(w, content, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (borders or '') .. (mar or '') ..
    '</w:tcPr>' .. content .. '</w:tc>'
end

-- the notation at the top right (LBR 9013-1(d)(1)(B); LBR 9004-1(b)(2)): a 3.6 in column at the right of the text,
-- single spaced, at least as many grid lines as its estimated wrapped lines
local function notation(meta)
  local h = meta.hearing or {}
  local rows = {}
  local n = 0
  local function add(inl, s)
    rows[#rows + 1] = P(inl, "PleadingRight")
    n = n + lines_of(s, 44)
  end
  if meta.judge then add(minl(meta.judge), mstr(meta.judge)) end
  if meta.chapter then add(minl(meta.chapter), mstr(meta.chapter)) end
  for _, pair in ipairs({
    { "Hearing location: ", h.location },
    { "Hearing date: ", h.date },
    { "Hearing time: ", h.time },
    { "Response date: ", h.response_date },
  }) do
    if pair[2] then
      local inl = { pandoc.Str(pair[1]) }
      for _, x in ipairs(minl(pair[2])) do inl[#inl + 1] = x end
      rows[#rows + 1] = P(inl, "PleadingRight")
      n = n + lines_of(pair[1] .. mstr(pair[2]), 44)
    end
  end
  local row = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. row_h(n) .. '" w:hRule="atLeast"/></w:trPr>' ..
    cell(TEXT_W - 5184, '<w:p/>') .. cell(5184, table.concat(rows)) .. '</w:tr>'
  return tbl({ TEXT_W - 5184, 5184 }, row)
end

local function court_title(meta)
  local out = {
    P({ pandoc.Str("IN THE UNITED STATES BANKRUPTCY COURT") }, "PleadingCentered", nil, { b = true }),
    P({ pandoc.Str("FOR THE WESTERN DISTRICT OF WASHINGTON") }, "PleadingCentered", nil, { b = true }),
  }
  if meta.division then
    out[#out + 1] = P(minl(meta.division), "PleadingCentered", nil, { b = true, caps = true })
  end
  return table.concat(out)
end

-- the caption: the debtor names and the designation (left, with a bottom rule), a ")" column, and the case number
-- and the title of the paper at right
local function caption(meta)
  local left_items = {}
  for _, nm in ipairs(meta.debtor.names or {}) do left_items[#left_items + 1] = nm end
  left_items[#left_items + 1] = meta.debtor.designation
  local left, parens, n = {}, {}, 0
  for _, it in ipairs(left_items) do
    left[#left + 1] = P(minl(it), "PleadingSingle")
    parens[#parens + 1] = P({ pandoc.Str(")") }, "PleadingSingle")
    n = n + lines_of(mstr(it), 34)
  end
  local right = {
    P({ pandoc.Str(mstr(meta.case_number)) }, "PleadingSingle"),
    pad(240),
    P(minl(meta.brief_title), "PleadingSingle", nil, { b = true }),
  }
  local m = 1 + 0.5 + lines_of(mstr(meta.brief_title), 34)
  local bl = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local row = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. row_h(math.max(n + 1, math.ceil(m))) ..
    '" w:hRule="atLeast"/></w:trPr>' ..
    cell(4320, table.concat(left), bl, '<w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar>') ..
    cell(360, table.concat(parens)) ..
    cell(4320, table.concat(right), nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>') .. '</w:tr>'
  return tbl({ 4320, 360, 4320 }, row)
end

-- a list item: a borderless two-column row, the marker in a 0.4 in column at 0.5 in, the text at 0.9 in (the typst
-- template's list indent and body indent). A table column is used instead of a tab stop so the text lines up in
-- every renderer, and the wrapped lines start at the text column.
local function list_item(marker, inl)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (TEXT_W - 720) .. '" w:type="dxa"/><w:tblInd w:w="720" w:type="dxa"/>' ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="576"/><w:gridCol w:w="' .. (TEXT_W - 720 - 576) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(576, P({ pandoc.Str(marker) }, "PleadingFlush")) ..
    cell(TEXT_W - 720 - 576, P(inl, "PleadingFlush")) .. '</w:tr></w:tbl>'
end

-- inline text of a block list (for a heading or a list item)
local function heading_xml(h)
  local sid = "Heading" .. math.min(h.level, 3)
  local flags = {}
  if h.level == 1 then flags = { b = true, caps = true } end
  return P(h.content, sid, nil, flags)
end

-- the body: each paragraph (first-line indent), each block quotation (indented both sides), each list (bullets)
local function body(doc)
  local out = {}
  for _, b in ipairs(doc.blocks) do
    local t = b.t
    if t == "Header" then
      out[#out + 1] = heading_xml(b)
    elseif t == "BlockQuote" then
      for _, blk in ipairs(b.content) do
        if blk.t == "Para" or blk.t == "Plain" then
          out[#out + 1] = P(blk.content, "PleadingQuote")
        end
      end
    elseif t == "Para" or t == "Plain" then
      if #b.content > 0 then
        local ppr = nil
        -- the signature paragraph (its chunk starts "Dated:") is kept whole on one page
        if pandoc.utils.stringify(b):sub(1, 6) == "Dated:" then ppr = '<w:keepLines/>' end
        out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="PleadingBody"/>' .. (ppr or '') .. '</w:pPr>' ..
          runs(b.content, {}) .. '</w:p>'
      end
    elseif t == "OrderedList" or t == "BulletList" then
      for k, item in ipairs(b.content) do
        local marker = (t == "OrderedList") and (tostring(k) .. ".") or "\u{2022}"
        local first = true
        for _, blk in ipairs(item) do
          if blk.t == "Para" or blk.t == "Plain" then
            if first then
              out[#out + 1] = list_item(marker, blk.content)
            else
              out[#out + 1] = P(blk.content, "PleadingFlush", '<w:ind w:left="1296" w:firstLine="0"/>')
            end
            first = false
          end
        end
      end
    end
  end
  return table.concat(out)
end

function Pandoc(doc)
  local m = doc.meta
  local xml = {}
  xml[#xml + 1] = notation(m)
  xml[#xml + 1] = pad(GRID)
  xml[#xml + 1] = court_title(m)
  xml[#xml + 1] = pad(GRID)
  xml[#xml + 1] = caption(m)
  xml[#xml + 1] = pad(GRID)
  xml[#xml + 1] = body(doc)
  return pandoc.Pandoc({ pandoc.RawBlock("openxml", table.concat(xml)) }, pandoc.Meta({}))
end
