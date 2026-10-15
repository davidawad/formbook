-- alsd-complaint.lua (docx engine): the S.D. Ala. complaint as Word paragraphs and a caption table (typst:
-- typst/alsd-complaint.typ). pandoc writes the body with docx/reference.docx; this filter writes what Word needs as
-- explicit paragraphs:
--   * the cover: court title, caption table (party column, a column of ")" marks, the civil action number on the
--     middle row), title of the paper, and the jury line when jury_demand is set;
--   * the allegations: each prose paragraph is numbered 1, 2 ... (Civ. L.R. 10(a)); headings, lettered lists, block
--     quotations and unnumbered paragraphs (a bracketed record cite, a WHEREFORE lead-in) are not;
--   * lettered lists (a), (b) ...;
--   * the signature block at 3.0 in, kept together.
-- Spacing: double is exact 24 pt, single is exact 13.8 pt, the pitches the typst output measures. Word may paginate
-- slightly differently from the LibreOffice PDF (docs/DOCX.md).

local stringify = pandoc.utils.stringify

local TEXT_W = 9360          -- 6.5 in, in twips
local PARTY_W = 4608         -- 3.2 in: the party column of the caption
local PAREN_W = 432          -- 0.3 in: the column of ")" marks
local LAST_W = TEXT_W - PARTY_W - PAREN_W
local SIG_LEFT = 4320        -- 3.0 in: the signature block sits in the right half of the page
local ITEM_LEFT = 1296       -- 0.9 in: text of a lettered item; its label starts at 0.5 in
local ITEM_HANG = 576        -- 0.4 in
local DOUBLE = 480           -- 24 pt
local SINGLE = 276           -- 13.8 pt
local KEEP = "<w:keepNext/><w:keepLines/>"

-- ---------------------------------------------------------------------------
-- XML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Text as one run; a line break inside it is a Word line break.
local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    lines[#lines + 1] = '<w:t xml:space="preserve">' .. esc(line) .. "</w:t>"
  end
  return "<w:r>" .. rpr .. table.concat(lines, "<w:br/>") .. "</w:r>"
end

local TAB_XML = "<w:r><w:tab/></w:r>"

-- Exact line spacing and the spacing around a paragraph, in twips.
local function spacing(line, before, after)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before or 0, after or 0, line)
end

local function ind(left)
  return '<w:ind w:left="' .. left .. '"/>'
end

local function para_xml(ppr, inner)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (inner or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- An empty line of the double-spaced body (typst: v(body-leading)).
local function blank_line()
  return raw(para_xml(spacing(DOUBLE), ""))
end

local function custom(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- A metadata value as plain text (MetaString, MetaInlines); a missing value is empty.
local function plain(v)
  if v == nil then return "" end
  return stringify(v)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local function caption_cell(width, text, bold)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>'
    .. para_xml(spacing(SINGLE), text ~= "" and run(text, bold) or "") .. "</w:tc>"
end

-- The caption: one row per line of the party block, a ")" on each, and the civil action number on the middle row
-- (the S.D. Ala. form, as the typst template draws it).
local function caption(meta)
  local rows = {}
  local parties = meta.caption.parties
  for k, p in ipairs(parties) do
    for _, name in ipairs(p.names) do rows[#rows + 1] = plain(name) end
    rows[#rows + 1] = plain(p.designation)
    if k < #parties then
      rows[#rows + 1] = ""
      rows[#rows + 1] = "v."
      rows[#rows + 1] = ""
    end
  end
  local mid = math.floor(#rows / 2)
  local out = {
    '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
      .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
      .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
      .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
      .. '<w:tblGrid><w:gridCol w:w="' .. PARTY_W .. '"/><w:gridCol w:w="' .. PAREN_W .. '"/><w:gridCol w:w="' .. LAST_W .. '"/></w:tblGrid>',
  }
  for i, text in ipairs(rows) do
    local case = (i - 1 == mid) and ("Civil Action No. " .. plain(meta.case_number)) or ""
    out[#out + 1] = "<w:tr>" .. caption_cell(PARTY_W, text, false) .. caption_cell(PAREN_W, ")", false)
      .. caption_cell(LAST_W, case, false) .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return raw(table.concat(out))
end

-- The exact line heights do the gaps: a double line after a single one sits 24 pt below it, as in the typst cover.
local function cover(meta)
  local out = {}
  out[#out + 1] = raw(para_xml(KEEP .. spacing(SINGLE) .. '<w:jc w:val="center"/>',
    run("IN THE UNITED STATES DISTRICT COURT\nFOR THE SOUTHERN DISTRICT OF ALABAMA\n" .. plain(meta.division):upper(), true)))
  out[#out + 1] = caption(meta)
  out[#out + 1] = raw(para_xml(KEEP .. spacing(DOUBLE) .. '<w:jc w:val="center"/>', run(plain(meta.brief_title), true)))
  if meta.jury_demand then
    out[#out + 1] = raw(para_xml(KEEP .. spacing(DOUBLE, 240) .. '<w:jc w:val="center"/>', run("JURY TRIAL DEMANDED", true)))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local numbered = 0

-- A prose paragraph: numbered, unless it is a bracketed record cite or a WHEREFORE lead-in (flush left, unnumbered).
local function allegation(p)
  local s = stringify(p.content)
  if s:sub(1, 1) == "[" or s:sub(1, 8) == "WHEREFORE" then
    return custom("Flush Text", { p })
  end
  numbered = numbered + 1
  local content = { pandoc.Str(numbered .. "."), pandoc.RawInline("openxml", TAB_XML) }
  for _, x in ipairs(p.content) do content[#content + 1] = x end
  return pandoc.Para(content)
end

-- A lettered list: each item's label (a), (b) ... at 0.5 in, its text at 0.9 in; a second paragraph of an item
-- is indented to the text.
local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local label = "(" .. string.char(96 + i) .. ")"
    for j, b in ipairs(item) do
      if j == 1 and (b.t == "Para" or b.t == "Plain") then
        local content = { pandoc.Str(label), pandoc.RawInline("openxml", TAB_XML) }
        for _, x in ipairs(b.content) do content[#content + 1] = x end
        out[#out + 1] = custom("List Item", { pandoc.Para(content) })
      else
        out[#out + 1] = custom("List Continue", { b })
      end
    end
  end
  return out
end

-- A block quotation whose first line is "(3) ..." or "(5) ...": pandoc reads "(n)" as a list marker, so the
-- marker is written back as text. The quoted words are unchanged; the paragraph stays in the Block Text style.
local function quotation(b)
  local blocks = {}
  for _, x in ipairs(b.content) do
    if x.t == "OrderedList" and (x.listAttributes.delimiter == "TwoParens" or x.listAttributes.delimiter == "OneParen") then
      for i, item in ipairs(x.content) do
        local content = { pandoc.Str("(" .. (x.listAttributes.start + i - 1) .. ")"), pandoc.Space() }
        for _, y in ipairs(item[1].content) do content[#content + 1] = y end
        blocks[#blocks + 1] = pandoc.Para(content)
        for j = 2, #item do blocks[#blocks + 1] = item[j] end
      end
    else
      blocks[#blocks + 1] = x
    end
  end
  return pandoc.BlockQuote(blocks)
end

local function body(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      out[#out + 1] = allegation(b)
    elseif b.t == "OrderedList" then
      for _, x in ipairs(lettered(b)) do out[#out + 1] = x end
    elseif b.t == "BlockQuote" then
      out[#out + 1] = quotation(b)
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (Gen. L.R. 5(a)(3)): the date, then each attorney's block under "Respectfully submitted,"
-- ---------------------------------------------------------------------------

local function signature(meta)
  local out = {}
  local function line(text)
    out[#out + 1] = raw(para_xml(KEEP .. spacing(SINGLE), run(text)))
  end
  local function signing(text)
    out[#out + 1] = raw(para_xml(KEEP .. spacing(SINGLE) .. ind(SIG_LEFT), run(text)))
  end
  out[#out + 1] = blank_line()
  line("Dated: " .. plain(meta.date))
  out[#out + 1] = blank_line()
  signing("Respectfully submitted,")
  out[#out + 1] = blank_line()
  for k, lines in ipairs(meta.signature.blocks) do
    if k > 1 then out[#out + 1] = blank_line() end
    for _, l in ipairs(lines) do signing(plain(l)) end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local blocks = cover(meta)
  if meta.lead_in then
    blocks[#blocks + 1] = pandoc.Para(meta.lead_in)
  end
  for _, b in ipairs(body(doc.blocks)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks)
end
