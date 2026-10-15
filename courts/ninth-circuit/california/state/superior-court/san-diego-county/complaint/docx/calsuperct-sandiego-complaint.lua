-- San Diego County Superior Court (calsuperct-sandiego), civil complaint, DOCX engine (docs/DOCX.md).
-- Mirrors typst/calsuperct-sandiego-complaint.typ. The body is the markdown itself; this filter adds
-- what markdown cannot express, all from the YAML frontmatter of the sample:
--   lines 1-7   attorney block (a table row of fixed minimum height, 168 pt), fee label top right;
--   lines 8-9   court title; line 10 blank;
--   caption     a two-column table: parties (right and bottom rule), case number and title on the right;
--   end         jury demand (if any) and the signature block.
-- The footer title is written by docx/render.sh (it reads footer_title from the same frontmatter).
-- Units: 1 in = 1440 twips; 1 space at 12 pt Liberation Serif = 0.25 em = 3 pt = 60 twips.

local CLERK_ROW = 3360        -- lines 1-7 at 24 pt each (CRC 2.111(2)): 168 pt, as an at-least row height
local LEFT_CAP = 5184         -- 3.6 in: caption, parties
local RIGHT_CAP = 4176        -- 2.9 in: caption, case number and title
local ATT_W = 6048            -- 4.2 in: attorney block when a fee label sits at the top right
local FEE_W = 3312            -- 2.3 in: fee label
local FULL_W = 9360           -- 6.5 in: text width
local TWIPS_PER_SPACE = 60

-- The frontmatter values as a list of inline lists (one per line of the paper).
local function to_inlines(v)
  if v == nil or type(v) == "boolean" then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaInlines" then return v end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function items(v)
  local out = {}
  if v == nil then return out end
  for _, it in ipairs(v) do out[#out + 1] = to_inlines(it) end
  return out
end

local function labeled(label, v)
  local out = { pandoc.Str(label), pandoc.Space() }
  for _, x in ipairs(to_inlines(v)) do out[#out + 1] = x end
  return out
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Inline content as runs. Bold and italic are kept; links and notes are flattened to their text
-- (the first page has neither). Run properties are emitted in schema order (b, bCs, i, iCs).
local function runs(inlines)
  local out = {}
  local function emit(text, b, i)
    local rpr = (b and "<w:b/><w:bCs/>" or "") .. (i and "<w:i/><w:iCs/>" or "")
    out[#out + 1] = "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
      .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  local function walk(list, b, i)
    for _, x in ipairs(list) do
      local t = x.t
      if t == "Str" then
        emit(x.text, b, i)
      elseif t == "Space" or t == "SoftBreak" then
        emit(" ", b, i)
      elseif t == "LineBreak" then
        out[#out + 1] = "<w:r><w:br/></w:r>"
      elseif t == "Emph" then
        walk(x.content, b, true)
      elseif t == "Strong" then
        walk(x.content, true, i)
      elseif t == "Quoted" then
        local open, close = "\u{201C}", "\u{201D}"
        if x.quotetype == "SingleQuote" then open, close = "\u{2018}", "\u{2019}" end
        emit(open, b, i)
        walk(x.content, b, i)
        emit(close, b, i)
      elseif (t == "Span" or t == "Link") and type(x.content) == "table" then
        walk(x.content, b, i)
      else
        emit(pandoc.utils.stringify(x), b, i)
      end
    end
  end
  walk(inlines, false, false)
  return table.concat(out)
end

-- One paragraph in a custom paragraph style, as openxml. ind_left (twips) is set on the paragraph.
local function para_xml(inlines, style, ind_left)
  local ind = (ind_left and ind_left > 0) and ('<w:ind w:left="' .. ind_left .. '"/>') or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. ind .. "</w:pPr>" .. runs(inlines) .. "</w:p>"
end

local function blank(style)
  return para_xml({}, style or "Normal")
end

-- A borderless table; cells are { tcpr = "...", paras = { xml, ... } }.
local function table_xml(widths, cells, trpr)
  local total, grid, tcs = 0, {}, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  for i, c in ipairs(cells) do
    local paras = #c.paras > 0 and table.concat(c.paras) or blank("Single")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. c.tcpr .. '</w:tcPr>'
      .. paras .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr>' .. trpr .. '</w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- Leading spaces of each caption.left item. Pandoc drops them when it reads the YAML strings, so they
-- are read from the sample's own frontmatter lines (the i-th list item under "left:" is the i-th line).
local function left_indents()
  local out = {}
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then return out end
  local in_left, n = false, 0
  for line in h:lines() do
    if line:match("^%s*left:%s*$") then
      in_left = true
    elseif in_left then
      local rest = line:match("^%s+%-%s+(.*)$")
      if rest then
        local sp = rest:match('^"( *)')
        out[#out + 1] = sp and #sp or 0
      elseif not line:match("^%s*$") then
        in_left = false
      end
    end
  end
  h:close()
  return out
end

local function first_page(meta)
  local blocks = {}
  local att = items(meta.attorney)
  local attorney_paras = {}
  for _, it in ipairs(att) do attorney_paras[#attorney_paras + 1] = para_xml(it, "Single") end
  local cells, widths
  if meta.fee_exempt then
    widths = { ATT_W, FEE_W }
    local fee_paras = {}
    for _, it in ipairs(items(meta.fee_exempt)) do fee_paras[#fee_paras + 1] = para_xml(it, "FeeLabel") end
    cells = {
      { tcpr = "", paras = attorney_paras },
      { tcpr = "", paras = fee_paras },
    }
  else
    widths = { FULL_W }
    cells = { { tcpr = "", paras = attorney_paras } }
  end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", table_xml(widths, cells,
    '<w:cantSplit/><w:trHeight w:val="' .. CLERK_ROW .. '" w:hRule="atLeast"/>'))

  for _, it in ipairs(items(meta.court)) do blocks[#blocks + 1] = pandoc.RawBlock("openxml", para_xml(it, "CourtTitle")) end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", blank("Normal"))
  return blocks
end

local function caption(meta, indents)
  local cap = meta.caption
  if not cap then error("calsuperct-sandiego-complaint: missing required metadata field `caption`") end
  local left = {}
  for i, it in ipairs(items(cap.left)) do
    left[#left + 1] = para_xml(it, "Single", (indents[i] or 0) * TWIPS_PER_SPACE)
  end
  local right = {}
  local function add(p) right[#right + 1] = p end
  if cap.case_number then
    add(para_xml(to_inlines(cap.case_number), "Single"))
    add(blank("Single"))
  end
  if cap.limited_civil == true then
    add(para_xml({ pandoc.Str("LIMITED CIVIL CASE") }, "Single"))
    add(blank("Single"))
  end
  for _, it in ipairs(items(cap.title)) do add(para_xml(it, "CaptionTitle")) end
  if cap.details then
    add(blank("Single"))
    for _, it in ipairs(items(cap.details)) do add(para_xml(it, "Single")) end
  end
  if cap.judge or cap.dept then
    add(blank("Single"))
    if cap.dept then add(para_xml(labeled("Dept.:", cap.dept), "Single")) end
    if cap.judge then add(para_xml(labeled("Judge:", cap.judge), "Single")) end
  end
  if cap.amount_demanded then
    add(blank("Single"))
    add(para_xml(to_inlines(cap.amount_demanded), "Single"))
  end
  local tbl = table_xml({ LEFT_CAP, RIGHT_CAP }, {
    { tcpr = '<w:tcBorders><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
        .. '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders>'
        .. '<w:tcMar><w:bottom w:w="173" w:type="dxa"/><w:right w:w="173" w:type="dxa"/></w:tcMar>', paras = left },
    { tcpr = '<w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>', paras = right },
  }, '<w:cantSplit/>')
  return pandoc.RawBlock("openxml", tbl)
end

local function closing(meta)
  local blocks = {}
  if meta.jury_demand then
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", para_xml(to_inlines(meta.jury_demand), "JuryDemand"))
  end
  local sig = meta.signature
  if not sig then error("calsuperct-sandiego-complaint: missing required metadata field `signature`") end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", blank("Normal"))
  if sig.dated then blocks[#blocks + 1] = pandoc.RawBlock("openxml", para_xml(labeled("Dated:", sig.dated), "Normal")) end
  for _, it in ipairs(items(sig.lines)) do blocks[#blocks + 1] = pandoc.RawBlock("openxml", para_xml(it, "SigBlock")) end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", blank("Normal"))
  -- "By:" then an underlined tab: the signature line, 2.7 in long, from 3.1 in (tab at 5.8 in from the margin)
  blocks[#blocks + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="SigBlock"/><w:tabs><w:tab w:val="left" w:pos="8352"/></w:tabs></w:pPr>'
    .. '<w:r><w:t xml:space="preserve">By: </w:t></w:r><w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r></w:p>')
  if sig.signer then blocks[#blocks + 1] = pandoc.RawBlock("openxml", para_xml(to_inlines(sig.signer), "SigName")) end
  if sig.role then blocks[#blocks + 1] = pandoc.RawBlock("openxml", para_xml(to_inlines(sig.role), "SigRole")) end
  return blocks
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, b in ipairs(first_page(meta)) do out[#out + 1] = b end
  out[#out + 1] = caption(meta, left_indents())
  out[#out + 1] = pandoc.RawBlock("openxml", blank("Normal"))
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  for _, b in ipairs(closing(meta)) do out[#out + 1] = b end
  return pandoc.Pandoc(out, meta)
end
