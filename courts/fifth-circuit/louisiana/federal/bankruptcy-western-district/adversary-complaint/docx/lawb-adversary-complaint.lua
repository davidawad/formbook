-- lawb-adversary-complaint.lua (docx engine): what the Word output adds to pandoc's default conversion, so that it
-- follows typst/lawb-adversary-complaint.typ (see ../README.md, "Engines"):
--   * the cover: court name, division, title, and the caption (parties left, a vertical rule, case numbers right);
--   * numbered paragraphs (Fed. R. Civ. P. 10(b)): each top-level paragraph gets its number typed ("1.", a tab), so the
--     number is text, not a list; the unnumbered opening paragraph and the prayer lead-in are block quotations in the
--     markdown and get only the first-line indent;
--   * lettered items "(a)", "(b)" ... from the markdown's numbered lists (the prayer for relief);
--   * a blank double line after each table; the signature block (LBR 5005-1(b)), single-spaced on the right half of
--     the page and kept together.
-- Court name and layout constants are here; every case-specific word comes from the sample's frontmatter.
-- Lengths are in twips (1 pt = 20): SINGLE is 15 pt, DOUBLE is 26 pt (the typst pitch), BLANK is 1.35 em = 17.55 pt.

local SINGLE = 300
local DOUBLE = 520
local BLANK = 351
local COURT = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF LOUISIANA" }
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Metadata value to plain text.
local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- Metadata value to a list of plain-text lines (a YAML list or a single value).
local function lines(v)
  local out = {}
  if v == nil then return out end
  if v.t == "MetaList" then
    for _, item in ipairs(v) do out[#out + 1] = str(item) end
  else
    out[1] = str(v)
  end
  return out
end

local function spacing(before, after, line)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before, after, line)
end

local function xrun(s, rpr)
  return string.format('<w:r>%s<w:t xml:space="preserve">%s</w:t></w:r>', rpr or "", esc(s))
end

local function xpara(ppr, runs)
  return string.format("<w:p><w:pPr>%s</w:pPr>%s</w:p>", ppr, runs or "")
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function spacer(height)
  return raw(xpara(spacing(0, 0, height)))
end

local BOLD = "<w:rPr><w:b/><w:bCs/></w:rPr>"
local BOLD_UNDERLINE = '<w:rPr><w:b/><w:bCs/><w:u w:val="single"/></w:rPr>'
local CENTER = '<w:jc w:val="center"/>'

-- ---------------------------------------------------------------------------
-- Cover: court name, title, caption
-- ---------------------------------------------------------------------------

-- The caption box: parties in a left cell with a vertical rule on its right edge (the typst divider), a gutter, and the
-- case numbers in the right cell. Every cell is single-spaced; the table has no other borders.
local function caption(meta)
  local left, right = {}, {}
  for _, item in ipairs(meta.caption.left) do
    local t = str(item.t)
    local indent = tonumber(str(item.i)) or 0
    local ppr = spacing(0, 0, SINGLE)
    if indent > 0 then ppr = ppr .. string.format('<w:ind w:left="%d"/>', 720 * indent) end
    left[#left + 1] = xpara(ppr, t ~= "" and xrun(t) or nil)
  end
  for _, t in ipairs(lines(meta.caption.right)) do
    right[#right + 1] = xpara(spacing(0, 0, SINGLE), t ~= "" and xrun(t) or nil)
  end
  local function cell(width, borders, mar, paras)
    return string.format('<w:tc><w:tcPr><w:tcW w:w="%d" w:type="dxa"/>%s%s</w:tcPr>%s</w:tc>', width, borders, mar, table.concat(paras))
  end
  return string.format(
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
      .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
      .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
      .. '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="360"/><w:gridCol w:w="4248"/></w:tblGrid><w:tr>%s%s%s</w:tr></w:tbl>',
    cell(4752,
      '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
      '<w:tcMar><w:bottom w:w="144" w:type="dxa"/><w:right w:w="288" w:type="dxa"/></w:tcMar>',
      left),
    cell(360, "", "", { "<w:p/>" }),
    cell(4248, "", '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>', right))
end

local function cover(meta)
  local out = {}
  local court = { table.unpack(COURT) }
  if meta.division then table.insert(court, str(meta.division):upper()) end
  for _, line in ipairs(court) do
    out[#out + 1] = raw(xpara(spacing(0, 0, SINGLE) .. CENTER, xrun(line, BOLD)))
  end
  out[#out + 1] = spacer(BLANK)
  out[#out + 1] = raw(xpara(spacing(0, 0, SINGLE) .. CENTER, xrun(str(meta.title):upper(), BOLD_UNDERLINE)))
  out[#out + 1] = spacer(BLANK)
  out[#out + 1] = raw(caption(meta))
  out[#out + 1] = spacer(BLANK)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 5005-1(b)): single-spaced, at 3.25 in, kept together
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local items = { { "Respectfully submitted,", BLANK } }
  items[#items + 1] = { str(sig.firm) }
  items[#items + 1] = { "By: " .. str(sig.by) }
  for _, l in ipairs(lines(sig.lines)) do items[#items + 1] = { l } end
  items[#items + 1] = { "" }
  for _, l in ipairs(lines(sig.counsel_for)) do items[#items + 1] = { l } end
  local out = {}
  for i, item in ipairs(items) do
    local keep = i < #items and "<w:keepNext/><w:keepLines/>" or "<w:keepLines/>"
    local sp = item[2] and spacing(item[2], item[2], SINGLE) or spacing(0, 0, SINGLE)
    local text = item[1] ~= "" and xrun(item[1]) or nil
    out[#out + 1] = raw(xpara(keep .. sp .. '<w:ind w:left="4680"/>', text))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local numbered = 0

local function numbered_paragraph(inlines)
  numbered = numbered + 1
  local content = pandoc.List({ pandoc.Str(numbered .. "."), TAB })
  content:extend(inlines)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Numbered Paragraph" })
end

local function lettered_item(i, blocks)
  local first = blocks[1]
  if #blocks ~= 1 or (first.t ~= "Para" and first.t ~= "Plain") then
    error("lawb-adversary-complaint.lua: a list item must be a single paragraph")
  end
  local content = pandoc.List({ pandoc.Str("(" .. string.char(96 + i) .. ")"), TAB })
  content:extend(first.content)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "List Letter" })
end

function Pandoc(doc)
  local meta = doc.meta
  local out = pandoc.List()
  out:extend(cover(meta))
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      out:insert(numbered_paragraph(b.content))
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" then error("lawb-adversary-complaint.lua: a block quotation must be a paragraph") end
        out:insert(pandoc.Div({ pandoc.Para(q.content) }, { ["custom-style"] = "Unnumbered Paragraph" }))
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do out:insert(lettered_item(i, item)) end
    elseif b.t == "Table" then
      out:insert(b)
      out:insert(spacer(BLANK))
    else
      out:insert(b)
    end
  end
  out:extend(signature(meta))
  -- The YAML title is the paper's title on the cover, not a Title paragraph.
  meta.title = nil
  return pandoc.Pandoc(out, meta)
end
