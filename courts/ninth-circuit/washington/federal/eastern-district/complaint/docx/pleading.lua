-- Pleading-paper helpers for the E.D. Wash. DOCX engine (docs/DOCX.md). Shared by complaint.lua and motion-brief.lua.
-- Every line is exact: 320 twips for a single-spaced line, 640 twips for a numbered line (the grid of the header's 21
-- numbers). Blocks that are not a whole number of grid lines are padded, so the text after them stays on the grid.

local GRID = 640     -- one numbered line (exact): 32 pt
local SINGLE = 320   -- one single-spaced line (exact): 16 pt
-- A single-spaced block starts 12.8 pt lower (PRE): the exact 16 pt line sits 12.8 pt higher in its slot than the exact
-- 32 pt numbered line does, and typst sets single lines from the top of their slot. With PRE the first single line's
-- baseline lands on the numbered line's baseline, and the blocks stay on the grid.
local PRE = 256
local PREF = '<w:spacing w:before="256"/>'
local BORDER = 175   -- a bottom rule sits 8 pt below its line (paragraph border space) and adds 0.75 pt
local RULE_R = '<w:pBdr><w:right w:val="single" w:sz="6" w:space="6" w:color="000000"/></w:pBdr>'
local RULE_RB = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="8" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="6" w:color="000000"/></w:pBdr>'

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

local function plain(v) return pandoc.utils.stringify(v) end

-- one paragraph of OpenXML: a paragraph style, bold, and extra paragraph properties (in schema order: borders, spacing)
local function PX(inl, sid, bold, ppr)
  return '<w:p><w:pPr>' .. (sid and ('<w:pStyle w:val="' .. sid .. '"/>') or '') .. (ppr or '') .. '</w:pPr>' ..
    runs(inl, { b = bold }) .. '</w:p>'
end

-- an empty paragraph exactly `tw` twips high
local function spacer(tw)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. tw .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- a paragraph that starts a new page (2 twips high, so the grid is unchanged)
local function page_break()
  return '<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="2" w:lineRule="exact"/></w:pPr></w:p>'
end

-- estimated width (points, 14 pt EB Garamond, by character class) and the wrapped line count of a text
local function text_width_pt(s, bold)
  local w = 0
  for ch in s:gmatch(utf8.charpattern) do
    if #ch > 1 then w = w + 7
    elseif ch:match("%u") then w = w + 9.6
    elseif ch:match("%l") then w = w + 6.4
    elseif ch:match("%d") then w = w + 7
    elseif ch == " " then w = w + 3.6
    else w = w + 5 end
  end
  return bold and w * 1.07 or w
end

local function wrapped_lines(s, width_pt, bold)
  local lines, cur = 1, 0
  for word in s:gmatch("%S+") do
    local ww = text_width_pt(word, bold)
    if cur == 0 then cur = ww
    elseif cur + 3.6 + ww <= width_pt then cur = cur + 3.6 + ww
    else lines = lines + 1; cur = ww end
  end
  return lines
end

-- the cover: counsel single spaced from the top of line 1 (PRE), padded to whole grid lines, at least 4 (lines 1 to 4,
-- so the court title starts on line 5), then the court title, one blank grid line and the caption (caller)
local function counsel_xml(counsel)
  local out = {}
  for k, c in ipairs(counsel) do
    out[#out + 1] = PX(minl(c), "PleadingSingle", false, k == 1 and PREF or nil)
  end
  local n = #counsel
  local total = math.max(4 * GRID, math.ceil((PRE + n * SINGLE) / GRID) * GRID)
  local pad = total - PRE - n * SINGLE
  if pad > 0 then out[#out + 1] = spacer(pad) end
  return table.concat(out)
end

-- the caption table. Left cell: the parties, each line from the top of the row (PRE); its right rule (cell border) and
-- its bottom rule (cell border) end at the parties, as typst's box, 10 pt from the text. Right cell: the case number,
-- title and hearing or jury lines (items {inl=, bold=} or {spacer=true}). The row is the taller cell; after the table, a
-- spacer takes the row up to whole grid lines, so the text after the caption stays on the numbers.
local function caption_xml(meta, right_items)
  local left, ln = {}, 0
  local first = true
  local function lp(inl, bold)
    left[#left + 1] = PX(inl, "PleadingCaption", bold, first and PREF or nil)
    first = false
  end
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      lp({ pandoc.Str("v.") }, false); ln = ln + 1
    end
    for _, n in ipairs(p.names or {}) do
      lp(minl(n), false)
      ln = ln + wrapped_lines(plain(n), 218, false)
    end
    lp(minl(p.designation), false)
    ln = ln + wrapped_lines(plain(p.designation), 218, false)
  end
  local right, rn = {}, 0
  for k, r in ipairs(right_items) do
    if r.spacer then
      right[#right + 1] = spacer(SINGLE); rn = rn + 1
    else
      right[#right + 1] = PX(r.inl, "PleadingCaption", r.bold, k == 1 and PREF or nil)
      rn = rn + wrapped_lines(plain(r.inl), 205, r.bold)
    end
  end
  left[#left + 1] = spacer(160)   -- 8 pt under the last line, as typst's box
  local left_h = ln * SINGLE + PRE + 160
  local right_h = rn * SINGLE + PRE
  local row_h = math.max(left_h, right_h)
  local target = math.ceil(row_h / GRID) * GRID
  if right_h < row_h then right[#right + 1] = spacer(row_h - right_h) end
  local table_xml = table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="9216" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="288"/><w:gridCol w:w="4320"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/><w:tcBorders>',
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>',
    '</w:tcBorders><w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>', table.concat(left), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa"/><w:tcMar><w:left w:w="216" w:type="dxa"/></w:tcMar></w:tcPr>',
    table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
  -- the grid pad after the table: the table is row_h tall (LibreOffice adds the 0.75 pt rule, 15 twips, to the row)
  local after = target - row_h - 15
  if after > 0 then return table_xml .. spacer(after) end
  return table_xml
end

-- the date and the signature block (typst: a 2.6 in date column, a 0.2 in gutter, the signature column). right_items:
-- {inl=} lines or {spacer=true}
local function signature_xml(date, right_items)
  local ldate = wrapped_lines("DATED " .. plain(date or ""), 187, false)
  local left = '<w:p><w:pPr><w:pStyle w:val="PleadingSingle"/>' .. PREF .. '</w:pPr>' ..
    runs({ pandoc.Str("DATED"), pandoc.Space() }, {}) .. runs(minl(date), {}) .. '</w:p>'
  local right, rn = {}, 0
  for k, r in ipairs(right_items) do
    if r.spacer then
      right[#right + 1] = spacer(SINGLE); rn = rn + 1
    else
      right[#right + 1] = PX(r.inl, "PleadingSingle", false, k == 1 and PREF or nil)
      rn = rn + wrapped_lines(plain(r.inl), 255, false)
    end
  end
  local target = math.ceil(math.max(ldate * SINGLE + PRE, rn * SINGLE + PRE) / GRID) * GRID
  local pad = target - rn * SINGLE - PRE
  if pad > 0 then right[#right + 1] = spacer(pad) end
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="9216" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="3744"/><w:gridCol w:w="288"/><w:gridCol w:w="5184"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/></w:tcPr>', left, '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="5184" w:type="dxa"/></w:tcPr>', table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

-- the signature column of a filing: "Respectfully submitted," (complaint only), the firm, then the signer
local function signature_items(sig, signer_lines, respectfully)
  local items = {}
  if respectfully then
    items[#items + 1] = { inl = { pandoc.Str("Respectfully submitted,") } }
    items[#items + 1] = { spacer = true }
  end
  for _, l in ipairs(sig.firm or {}) do items[#items + 1] = { inl = minl(l) } end
  items[#items + 1] = { spacer = true }
  for _, l in ipairs(signer_lines) do items[#items + 1] = { inl = l } end
  return items
end

return {
  PX = PX, runs = runs, minl = minl, plain = plain, spacer = spacer, page_break = page_break,
  counsel_xml = counsel_xml, caption_xml = caption_xml, signature_xml = signature_xml,
  signature_items = signature_items, wrapped_lines = wrapped_lines, xesc = xesc,
  PREF = PREF, GRID = GRID, SINGLE = SINGLE, PRE = PRE,
}
