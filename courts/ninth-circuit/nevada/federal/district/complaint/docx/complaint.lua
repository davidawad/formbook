-- Complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a pleading-paper Word document on reference.docx.
-- The cover (counsel, court title, caption box with the claims list) is written as OpenXML: a table with a right and
-- bottom rule under the parties, which pandoc's table model cannot style. The body keeps its markdown structure,
-- with the paragraph styles of reference.docx. Numbered paragraphs (Fed. R. Civ. P. 10(b)) get their number typed,
-- as the typst counter does. Exact 462-twip lines keep every line on the grid of the header's 28 numbers; single
-- spaced blocks (280 twips) are padded to whole grid lines, as the typst template rounds them.

local GRID = 462     -- one numbered line (exact)
local SINGLE = 280   -- one single-spaced line (exact): 14 pt, the single spacing the typst caption measures

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines -> runs; flags: b (bold), i (italic)
local function runs(inl, flags)
  local out = {}
  local function run(text)
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
    elseif t == "Emph" then out[#out + 1] = runs(e.content, { b = flags.b, i = true })
    elseif t == "Strong" then out[#out + 1] = runs(e.content, { b = true, i = flags.i })
    elseif t == "Quoted" then
      local q = e.quotetype == "SingleQuote" and { "\u{2018}", "\u{2019}" } or { "\u{201C}", "\u{201D}" }
      run(q[1]); out[#out + 1] = runs(e.content, flags); run(q[2])
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(e.content, flags)
    else run(pandoc.utils.stringify(e)) end
  end
  return table.concat(out)
end

local function minl(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return (v[1] and v[1].content) or {} end
  if v.t == "MetaString" then return { pandoc.Str(v) } end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

-- one paragraph of OpenXML with a paragraph style (styleId) and inlines
local function PX(inl, sid)
  return '<w:p><w:pPr><w:pStyle w:val="' .. sid .. '"/></w:pPr>' .. runs(inl, {}) .. '</w:p>'
end

-- an empty paragraph exactly `tw` twips high (a grid pad, or a half line)
local function pad(tw)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. tw .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- the rest of a block of single lines (n lines of SINGLE) up to a whole number of grid lines, at least 7 lines
local function grid_pad(n_single, min_lines)
  local h = n_single * SINGLE
  local target = math.max((min_lines or 0) * GRID, math.ceil(h / GRID) * GRID)
  if target - h > 0 then return pad(target - h) end
  return ""
end

local function page_break()
  return '<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="2" w:lineRule="exact"/></w:pPr></w:p>'
end

local function lines_of(s, cpl) return math.max(1, math.ceil(#s / cpl)) end

-- the caption box: parties at left (right and bottom rule), the case number, title and claims at right
local function caption_xml(meta)
  local left, lh = {}, 0
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = PX(meta.caption.separator and minl(meta.caption.separator) or { pandoc.Str("v.") }, "PleadingCaption")
      lh = lh + 1
    end
    for _, n in ipairs(p.names or {}) do
      left[#left + 1] = PX(minl(n), "PleadingCaption")
      lh = lh + lines_of(pandoc.utils.stringify(n), 34)
    end
    left[#left + 1] = PX(minl(p.designation), "PleadingDesignation")
    lh = lh + lines_of(pandoc.utils.stringify(p.designation), 26)
  end
  local case = "Case No.: " .. pandoc.utils.stringify(meta.case_number or "")
  local right, rh = { PX({ pandoc.Str(case) }, "PleadingCaption") }, lines_of(case, 32)
  right[#right + 1] = pad(231)
  rh = rh + 0.5
  if meta.brief_title then
    right[#right + 1] = PX({ pandoc.Strong(minl(meta.brief_title)) }, "PleadingCaption")
    rh = rh + lines_of(pandoc.utils.stringify(meta.brief_title), 20)
  end
  if meta.jury_demand then
    right[#right + 1] = pad(231)
    right[#right + 1] = PX({ pandoc.Strong({ pandoc.Str("JURY DEMAND") }) }, "PleadingCaption")
    rh = rh + 1.5
  end
  if meta.summary then
    right[#right + 1] = pad(231)
    rh = rh + 0.5
    for k, s in ipairs(meta.summary) do
      right[#right + 1] = PX({ pandoc.Str("(" .. k .. ") "), pandoc.Strong(minl(s)) }, "PleadingHanging")
      rh = rh + lines_of(pandoc.utils.stringify(s), 20)
    end
  end
  -- the row sizes to its text: the complaint body starts on the next page, so the box need not end on the grid
  -- (the motion body follows on the same page and keeps a grid-rounded row)
  local trh = ""
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="8640" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="288"/><w:gridCol w:w="3744"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/>', trh, '</w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>',
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
    '<w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>', table.concat(left), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>',
    table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

-- the cover: counsel single spaced (padded to whole lines, at least 7), a grid line, the court title,
-- a grid line, the caption box
local function cover(meta)
  local out = {}
  local counsel = meta.counsel or {}
  for _, c in ipairs(counsel) do out[#out + 1] = PX(minl(c), "PleadingSingle") end
  out[#out + 1] = grid_pad(#counsel, 7)
  out[#out + 1] = '<w:p/>'
  out[#out + 1] = PX({ pandoc.Strong({ pandoc.Str("UNITED STATES DISTRICT COURT") }) }, "PleadingCentered")
  out[#out + 1] = PX({ pandoc.Strong({ pandoc.Str("DISTRICT OF NEVADA") }) }, "PleadingCentered")
  out[#out + 1] = '<w:p/>'
  out[#out + 1] = caption_xml(meta)
  return table.concat(out)
end

-- the date, the signature block at 2.6 in (the firm, then "By: /s/" and the signer's lines)
local function signature(meta, date)
  local sig = meta.signature
  local out = { PX(minl(date), "PleadingFlush"), '<w:p/>' }
  local firm = {}
  for _, l in ipairs(sig.firm or {}) do firm[#firm + 1] = PX(minl(l), "PleadingSignature") end
  out[#out + 1] = table.concat(firm)
  out[#out + 1] = grid_pad(#(sig.firm or {}))
  out[#out + 1] = pad(231)
  local by = { PX({ pandoc.Str("By: /s/ " .. pandoc.utils.stringify(sig.signer)) }, "PleadingSignature") }
  for _, l in ipairs(sig.lines or {}) do by[#by + 1] = PX(minl(l), "PleadingSignature") end
  out[#out + 1] = table.concat(by)
  out[#out + 1] = grid_pad(#(sig.lines or {}) + 1)
  return table.concat(out)
end

local function quote_lines(blocks)
  local n = 0
  for _, b in ipairs(blocks) do n = n + lines_of(pandoc.utils.stringify(b), 62) end
  return n
end

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc would print the date as a title block at the top; the date is set in the signature block instead
  local date = meta.date
  doc.meta.date = nil
  local out = { pandoc.RawBlock("openxml", cover(meta) .. page_break()) }

  local unnumbered = {}
  for _, s in ipairs(meta.unnumbered_sections or {}) do unnumbered[pandoc.utils.stringify(s):upper()] = true end
  local section, n = "", 0

  if meta.lead_in then
    out[#out + 1] = pandoc.Div({ pandoc.Para(minl(meta.lead_in)) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Body" }))
  end

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      section = pandoc.utils.stringify(b.content):upper()
      out[#out + 1] = b
    elseif b.t == "Para" then
      local text = pandoc.utils.stringify(b)
      if text:match("^%(.*%)$") then
        out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Centered" }))
      elseif unnumbered[section] then
        out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Body" }))
      else
        n = n + 1
        local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        inl:extend(b.content)
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Body" }))
      end
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = pandoc.Div({ q }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Quote" }))
      end
      local h = quote_lines(b.content) * SINGLE
      local t = math.ceil(h / GRID) * GRID
      if t - h > 0 then out[#out + 1] = pandoc.RawBlock("openxml", pad(t - h)) end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta, date))
  doc.blocks = out
  return doc
end
