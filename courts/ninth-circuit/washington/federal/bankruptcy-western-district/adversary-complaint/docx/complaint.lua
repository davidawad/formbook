-- Adversary complaint, DOCX engine (docs/DOCX.md). The markdown contract -> one OpenXML body on reference.docx, the
-- same layout as ../typst/wawb-adversary-complaint.typ: counsel top left and the judge top right (a table row of
-- exact 480-twip grid lines), the court title, the caption (a table with a right and a bottom rule under the parties;
-- the adversary number and the title at right), a page break, then the lead-in and the numbered paragraphs. Every
-- table row is a whole number of 480-twip grid lines, so the text stays on the 28 numbers in the header text box.
-- Lists are lettered A., B., (the exemplar's prayer convention). The signature block is one unbreakable table row.
-- Nothing case-specific is written here: every word comes from the sample's frontmatter.

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

-- a table row height: whole grid lines around n single lines (exact, so the grid holds whatever wraps)
local function row_h(n_single)
  local h = math.ceil(n_single * SINGLE / GRID) * GRID
  return math.max(h, GRID)
end

local function tbl(grid_cols, rows_xml, extra_pr)
  local cols = {}
  for _, w in ipairs(grid_cols) do cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    (extra_pr or '') ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' .. rows_xml .. '</w:tbl>'
end

local function cell(w, content, borders, mar, valign)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' ..
    (borders or '') .. (mar or '') .. (valign and ('<w:vAlign w:val="' .. valign .. '"/>') or '') ..
    '</w:tcPr>' .. content .. '</w:tc>'
end

-- the counsel block (left) and the judge and chapter (right), in one exact-height row, at least 7 grid lines
local function top_block(meta)
  local left, n = {}, 0
  for _, c in ipairs(meta.counsel or {}) do
    left[#left + 1] = P(minl(c), "PleadingSingle")
    n = n + lines_of(mstr(c), 56)
  end
  local right, m = {}, 0
  for _, k in ipairs({ "judge", "chapter" }) do
    if meta[k] then
      right[#right + 1] = P(minl(meta[k]), "PleadingRight")
      m = m + lines_of(mstr(meta[k]), 30)
    end
  end
  local h = math.max(7 * GRID, row_h(n), row_h(m))
  local row = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. h .. '" w:hRule="exact"/></w:trPr>' ..
    cell(5616, table.concat(left)) .. cell(3384, table.concat(right)) .. '</w:tr>'
  return tbl({ 5616, 3384 }, row)
end

-- the caption: the debtor's case and the parties in the left column (right and bottom rules), the adversary number
-- and the title at right
local function caption(meta)
  local left, n = {}, 0
  local function add(inl, s, sid)
    left[#left + 1] = P(inl, sid or "PleadingSingle")
    n = n + lines_of(s, 34)
  end
  if meta.debtor then
    for _, nm in ipairs(meta.debtor.names or {}) do add(minl(nm), mstr(nm)) end
    if meta.debtor.case_number then add(minl(meta.debtor.case_number), mstr(meta.debtor.case_number)) end
    if meta.debtor.note then add(minl(meta.debtor.note), mstr(meta.debtor.note)) end
    add({}, "")
  end
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then add({ pandoc.Str("v.") }, "v.") end
    for _, nm in ipairs(p.names or {}) do add(minl(nm), mstr(nm)) end
    add(minl(p.designation), mstr(p.designation))
  end
  local right, m = {}, 0
  right[#right + 1] = P({ pandoc.Str("Adversary No. " .. mstr(meta.adversary_number)) }, "PleadingSingle")
  m = m + 1
  right[#right + 1] = pad(240)
  right[#right + 1] = P(minl(meta.brief_title), "PleadingSingle", nil, { b = true })
  m = m + lines_of(mstr(meta.brief_title), 36) + 0.5
  local bl = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(4608, table.concat(left), bl, '<w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar>') ..
    cell(288, '<w:p/>') ..
    cell(4104, table.concat(right), nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>') .. '</w:tr>'
  return tbl({ 4608, 288, 4104 }, row)
end

-- the court title: three bold centered lines, each a grid line, with a grid line either side
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

-- the date and the signature for each firm (right column); one unbreakable row
local function signature(meta)
  local right = {}
  for _, s in ipairs(meta.signature or {}) do
    right[#right + 1] = P(minl(s.firm), "PleadingSignature")
    right[#right + 1] = pad(240)
    right[#right + 1] = P({ pandoc.Str("/s/ " .. mstr(s.signer)) }, "PleadingSignature")
    for _, l in ipairs(s.lines or {}) do right[#right + 1] = P(minl(l), "PleadingSignature") end
    right[#right + 1] = pad(480)
  end
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(3744, P({ pandoc.Str("Dated: " .. mstr(meta.date)) }, "PleadingSingle")) ..
    cell(288, '<w:p/>') ..
    cell(4968, table.concat(right)) .. '</w:tr>'
  return tbl({ 3744, 288, 4968 }, row)
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

local function body(doc)
  local out = {}
  local counter = 0
  local first_para = true
  for _, b in ipairs(doc.blocks) do
    local t = b.t
    if t == "Header" then
      out[#out + 1] = heading_xml(b)
    elseif t == "Para" or t == "Plain" then
      if #b.content == 0 then
        -- skip
      else
        counter = counter + 1
        out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="PleadingBody"/><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs></w:pPr>' ..
          '<w:r><w:t xml:space="preserve">' .. counter .. '.</w:t></w:r><w:r><w:tab/></w:r>' ..
          runs(b.content, {}) .. '</w:p>'
      end
    elseif t == "OrderedList" or t == "BulletList" then
      for k, item in ipairs(b.content) do
        local marker = (t == "OrderedList") and (string.char(string.byte("A") + k - 1) .. ".") or "\u{2022}"
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
  xml[#xml + 1] = top_block(m)
  xml[#xml + 1] = pad(GRID)
  xml[#xml + 1] = court_title(m)
  xml[#xml + 1] = pad(GRID)
  xml[#xml + 1] = caption(m)
  local lead = ''
  if m.lead_in then
    lead = P(minl(m.lead_in), "PleadingBody", '<w:pageBreakBefore/>')
  end
  if lead ~= '' then
    -- the page break goes on the lead-in paragraph itself
    xml[#xml + 1] = lead
  end
  xml[#xml + 1] = body(doc)
  -- a paragraph between the prayer (list tables) and the signature table: adjacent tables merge in Word and LibreOffice
  xml[#xml + 1] = pad(240)
  xml[#xml + 1] = signature(m)
  return pandoc.Pandoc({ pandoc.RawBlock("openxml", table.concat(xml)) }, pandoc.Meta({}))
end
