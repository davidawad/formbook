-- M.D. Pa. brief in support of a motion, DOCX engine (docs/DOCX.md). The markdown sample becomes a Word
-- document on docx/reference.docx, following typst/pamd-motion-brief.typ: the court title, the caption (a
-- borderless table, one 16 pt row per caption line), the title, the body (first-line indent, headings
-- flush left), the lettered Statement of Questions (the "A." paragraphs are not a Word list), the
-- single-spaced blocks marked "~" (service lists), and the signature block (a borderless two-column table).
-- Constants below are the typst template's (LR 5.1 and the named layout choices in the .typ file).

local TEXT_WIDTH = 9360                   -- 6.5 in between the 1 in margins, in twips
local CAPTION_COLS = { 4896, 576 }        -- 3.4 in party column, 0.4 in colon column; the right column is the rest
local SIG_COLS = { 3744, 288 }            -- 2.6 in date column, 0.2 in gutter; the signature column is the rest
local SIG_RULE = 4608                     -- 3.2 in signature rule, from the "By:" label
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

-- a paragraph of a named style; extra is pPr content after the style, in schema order (tabs, ind, jc)
local function xp(style, inner, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or '') .. '</w:pPr>' .. (inner or '') .. '</w:p>'
end

local SPACER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="640" w:lineRule="exact"/></w:pPr></w:p>'
local HALF_SPACER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="160" w:lineRule="exact"/></w:pPr></w:p>'
local BLOCK_GAP = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="460" w:lineRule="exact"/></w:pPr></w:p>'
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
  local rest = TEXT_WIDTH - SIG_COLS[1] - SIG_COLS[2]
  local date = meta.date and plain(meta.date) or ""
  local right = { xp("Single", run("Respectfully submitted,")), HALF_SPACER }
  for _, l in ipairs(meta.signature.firm or {}) do right[#right + 1] = xp("Single", run(plain(l))) end
  right[#right + 1] = SPACER
  -- "By:" and the rule after it: a tab with an underline, ending at 3.2 in from the left of the cell
  right[#right + 1] = xp("Single", run("By:") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    '<w:tabs><w:tab w:val="left" w:pos="' .. SIG_RULE .. '"/></w:tabs>')
  right[#right + 1] = HALF_SPACER
  for _, l in ipairs(meta.signature.lines) do right[#right + 1] = xp("Single", run(plain(l))) end
  local left = xp("Single", date ~= "" and run("Dated: " .. date) or "")
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(SIG_COLS[1], left) .. cell(SIG_COLS[2], xp("Single", ""))
    .. cell(rest, table.concat(right)) .. '</w:tr>'
  return pandoc.RawBlock("openxml", SPACER .. table_xml({ SIG_COLS[1], SIG_COLS[2], rest }, { row }))
end

-- "~" marks a single-spaced block (a service list, an address) in the sample; it is removed from the text
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

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        b = b:walk({ Str = function(s) s.text = s.text:upper() return s end })
      end
      blocks[#blocks + 1] = b
    elseif b.t == "Para" and strip_marker(b, "~") then
      blocks[#blocks + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Single" }))
      blocks[#blocks + 1] = pandoc.RawBlock("openxml", BLOCK_GAP)
    elseif b.t == "OrderedList" and b.listAttributes.style == pandoc.UpperAlpha then
      -- the Statement of Questions: "A.", "B." ... paragraphs with the label as text (not a Word list)
      for i, item in ipairs(b.content) do
        local label = string.char(string.byte("A") + (b.listAttributes.start - 1) + i - 1)
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local inl = { pandoc.Str(label .. "."), pandoc.Space() }
          for _, el in ipairs(first.content) do inl[#inl + 1] = el end
          blocks[#blocks + 1] = pandoc.Para(inl)
          for j = 2, #item do blocks[#blocks + 1] = item[j] end
        else
          error("pamd brief: unexpected block in a lettered question")
        end
      end
    else
      blocks[#blocks + 1] = b
    end
  end

  blocks[#blocks + 1] = signature(meta)
  meta.title, meta.date = nil, nil
  return pandoc.Pandoc(blocks, meta)
end
