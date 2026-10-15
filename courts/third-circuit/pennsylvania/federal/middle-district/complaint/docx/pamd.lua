-- M.D. Pa. complaint, DOCX engine (docs/DOCX.md). The markdown sample becomes a Word document on
-- docx/reference.docx, following typst/pamd-complaint.typ: the court title, the caption (a borderless
-- table, one 16 pt row per caption line), the title, the lead-in, the numbered allegations (numbered
-- here, as text, so that the numbers do not depend on a Word list), the "^" paragraphs (unnumbered),
-- the lettered prayer items, headings, and the signature block (a borderless two-column table).
-- Constants below are the typst template's (LR 5.1 and the named layout choices in the .typ file).

local TEXT_WIDTH = 9360                   -- 6.5 in between the 1 in margins, in twips
local CAPTION_COLS = { 4896, 576 }        -- 3.4 in party column, 0.4 in colon column; the right column is the rest
local SIG_COLS = { 3744, 288 }            -- 2.6 in date column, 0.2 in gutter; the signature column is the rest
local SIG_LINE = 4608                     -- 3.2 in signature rule
local COURT_LINES = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE MIDDLE DISTRICT OF PENNSYLVANIA" }

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(s, rpr)
  return '<w:r>' .. (rpr or '') .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

-- a paragraph of a named style; extra is pPr content after the style, in schema order (ind, jc)
local function xp(style, inner, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or '') .. '</w:pPr>' .. (inner or '') .. '</w:p>'
end

local SPACER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="640" w:lineRule="exact"/></w:pPr></w:p>'
local BOLD = '<w:rPr><w:b/><w:bCs/></w:rPr>'

local function cell(width, paragraphs)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. paragraphs .. '</w:tc>'
end

local function table_xml(cols, rows)
  local total, grid = 0, {}
  for _, w in ipairs(cols) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

local function caption(rows)
  local right_w = TEXT_WIDTH - CAPTION_COLS[1] - CAPTION_COLS[2]
  local out = {}
  for _, r in ipairs(rows) do
    local ind = math.floor((tonumber(plain(r.indent)) or 0) * 1440 + 0.5)
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="320" w:hRule="exact"/></w:trPr>'
      .. cell(CAPTION_COLS[1], xp("Single", run(plain(r.left)), '<w:ind w:left="' .. ind .. '" w:firstLine="0"/>'))
      .. cell(CAPTION_COLS[2], xp("Single", run(":"), '<w:jc w:val="center"/>'))
      .. cell(right_w, xp("Single", run(plain(r.right))))
      .. '</w:tr>'
  end
  return table_xml({ CAPTION_COLS[1], CAPTION_COLS[2], right_w }, out)
end

local function cover(meta)
  local out = {}
  for _, line in ipairs(COURT_LINES) do out[#out + 1] = xp("Centered", run(line)) end
  out[#out + 1] = SPACER
  out[#out + 1] = caption(meta.caption)
  out[#out + 1] = SPACER
  out[#out + 1] = xp("Centered", run(plain(meta.title):upper(), BOLD))
  out[#out + 1] = SPACER
  return pandoc.RawBlock("openxml", table.concat(out, "\n"))
end

local function signature(meta)
  local date = meta.date and plain(meta.date) or ""
  local right = { xp("Single", run("Respectfully submitted,")), SPACER,
    -- the signature rule: an empty paragraph with a bottom border, ending 0.5 in short of the cell edge
    '<w:p><w:pPr><w:pStyle w:val="Single"/><w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>'
      .. '<w:ind w:left="0" w:right="' .. (TEXT_WIDTH - SIG_COLS[1] - SIG_COLS[2] - SIG_LINE) .. '" w:firstLine="0"/></w:pPr></w:p>' }
  for _, l in ipairs(meta.signature.lines) do right[#right + 1] = xp("Single", run(plain(l))) end
  local left = xp("Single", date ~= "" and run("Date: " .. date) or "")
  local rest = TEXT_WIDTH - SIG_COLS[1] - SIG_COLS[2]
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(SIG_COLS[1], left) .. cell(SIG_COLS[2], xp("Single", ""))
    .. cell(rest, table.concat(right)) .. '</w:tr>'
  return pandoc.RawBlock("openxml", SPACER .. table_xml({ SIG_COLS[1], SIG_COLS[2], rest }, { row }))
end

-- "^" marks an unnumbered paragraph in the sample; it is removed from the text
local function strip_marker(para, marker)
  local first = para.content[1]
  if first and first.t == "Str" and first.text:sub(1, 1) == marker then
    first.text = first.text:sub(2)
    if first.text == "" then table.remove(para.content, 1) end
    if para.content[1] and para.content[1].t == "Space" then table.remove(para.content, 1) end
    return true
  end
  return false
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = { cover(meta) }
  if meta.lead_in then blocks[#blocks + 1] = pandoc.Para(meta.lead_in) end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        b = b:walk({ Str = function(s) s.text = s.text:upper() return s end })
      end
      blocks[#blocks + 1] = b
    elseif b.t == "Para" and strip_marker(b, "^") then
      blocks[#blocks + 1] = b
    elseif b.t == "Para" then
      n = n + 1
      local inl = { pandoc.Str(tostring(n) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
      for _, el in ipairs(b.content) do inl[#inl + 1] = el end
      blocks[#blocks + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
    elseif b.t == "OrderedList" then
      -- the prayer's items are lettered (a), (b) ... in the typst template: literal labels, as for the allegations
      for i, item in ipairs(b.content) do
        local first = item[1]
        if not first or (first.t ~= "Para" and first.t ~= "Plain") then error("pamd complaint: unexpected block in a list item") end
        local inl = { pandoc.Str("(" .. string.char(string.byte("a") + i - 1) .. ")"), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        for _, el in ipairs(first.content) do inl[#inl + 1] = el end
        blocks[#blocks + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered" }))
        for j = 2, #item do blocks[#blocks + 1] = item[j] end
      end
    else
      blocks[#blocks + 1] = b
    end
  end

  blocks[#blocks + 1] = signature(meta)
  meta.title, meta.date = nil, nil
  return pandoc.Pandoc(blocks, meta)
end
