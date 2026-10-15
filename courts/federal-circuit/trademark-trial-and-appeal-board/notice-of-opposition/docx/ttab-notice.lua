-- ttab-notice.lua (docx engine, notice of opposition). Builds the front matter and the trailing blocks of the
-- notice as WordprocessingML, from the same YAML frontmatter the typst template reads (../README.md, "Markdown
-- contract"), and leaves the body to pandoc's own conversion (styles from reference.docx, see make-reference.sh).
--   * the USPTO heading and the "In re Application of" block (tab stops, hanging indent);
--   * the party caption as a borderless table: names, a ")" column, and the opposition number, vertically centered;
--   * the title, the signature block (left indent 3 in.), one slip sheet per exhibit (a framed paragraph, vertically
--     centered on its page, after a page break);
--   * the document metadata title and date are cleared, so pandoc prints no title block.
-- No case text is in this file. Every value comes from the sample's frontmatter.

local TWIP = 1440
local function tw(inches) return math.floor(inches * TWIP + 0.5) end

local function sp(before, after)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="240" w:lineRule="auto" />'
end
local SINGLE = sp(0, 0)
local TEXT_WIDTH = tw(6.5)

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function rpr(b, i, caps)
  local x = ""
  if b then x = x .. "<w:b />" end
  if i then x = x .. "<w:i />" end
  if caps then x = x .. "<w:caps />" end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function run(text, b, i, caps)
  return "<w:r>" .. rpr(b, i, caps) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- Inline markdown (already parsed by pandoc from the YAML strings) as runs. Emphasis is kept as italics.
local function runs(inlines, b, i, caps)
  local out = {}
  local function walk(list, bb, ii, cc)
    for _, el in ipairs(list) do
      local t = el.t
      if t == "Str" then
        out[#out + 1] = run(el.text, bb, ii, cc)
      elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
        out[#out + 1] = run(" ", bb, ii, cc)
      elseif t == "Emph" then
        walk(el.content, bb, true, cc)
      elseif t == "Strong" then
        walk(el.content, true, ii, cc)
      elseif t == "Span" or t == "Link" then
        walk(el.content, bb, ii, cc)
      else
        out[#out + 1] = run(pandoc.utils.stringify(el), bb, ii, cc)
      end
    end
  end
  walk(inlines, b, i, caps)
  return table.concat(out)
end

local function para(ppr, body)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. body .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function str_of(v)
  return pandoc.utils.stringify(v)
end

-- ---------------------------------------------------------------------------
-- Front matter
-- ---------------------------------------------------------------------------

-- TBMP 309.02(a): the heading the Board requires at the top of the complaint (two lines, centered, bold).
local function board_heading()
  local ppr = SINGLE .. '<w:ind w:firstLine="0" /><w:jc w:val="center" />'
  return raw(
    para(ppr, run("IN THE UNITED STATES PATENT AND TRADEMARK OFFICE", true))
      .. para(ppr, run("BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD", true))
  )
end

-- TBMP 309.02(a): identification of the applications opposed; a label column of 2.2 in.
local function applications(meta)
  local out = {}
  local labels = {
    { "applicant", "In re Application of:" },
    { "serial", "Serial No.:" },
    { "mark", "Mark:" },
    { "application_date", "Application Date:" },
    { "publication_date", "Publication Date:" },
  }
  if meta.applications == nil then return out end
  for _, app in ipairs(meta.applications) do
    for n, pair in ipairs(labels) do
      local key, label = pair[1], pair[2]
      local before = (n == 1) and 288 or 0
      local after = (n == #labels) and 96 or 84
      local ppr = '<w:tabs><w:tab w:val="left" w:pos="' .. tw(2.2) .. '" /></w:tabs>'
        .. sp(before, after)
        .. '<w:ind w:left="' .. tw(2.2) .. '" w:hanging="' .. tw(2.2) .. '" />'
      local value = ""
      if key == "applicant" or key == "mark" then
        value = runs(app[key])
      else
        value = run(str_of(app[key]))
      end
      out[#out + 1] = para(ppr, run(label) .. "<w:r><w:tab /></w:r>" .. value)
    end
  end
  return out
end

-- The party caption, TBMP 309.02(a). One table row per line of names, a ")" column beside every row, and the
-- opposition number in a cell that spans the whole caption and is vertically centered.
local function caption_table(meta)
  local sides = meta.caption
  local rows = {}
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do
      rows[#rows + 1] = { ind = 0, body = runs(name) }
    end
    rows[#rows + 1] = { ind = tw(2.1), body = runs(side.designation) }
    if i < #sides then
      rows[#rows + 1] = { ind = 0, body = "" }
      rows[#rows + 1] = { ind = tw(1.2), body = run("v.") }
      rows[#rows + 1] = { ind = 0, body = "" }
    end
  end
  local number = meta.opposition_no and str_of(meta.opposition_no) or "______________"
  local W = { tw(3.4), tw(0.35), tw(2.4) }
  local out = {}
  for r, row in ipairs(rows) do
    local left = '<w:tc><w:tcPr><w:tcW w:w="' .. W[1] .. '" w:type="dxa" /></w:tcPr>'
      .. para(SINGLE .. '<w:ind w:left="' .. row.ind .. '" w:firstLine="0" />', row.body) .. "</w:tc>"
    local mid = '<w:tc><w:tcPr><w:tcW w:w="' .. W[2] .. '" w:type="dxa" /></w:tcPr>'
      .. para(SINGLE .. '<w:ind w:firstLine="0" /><w:jc w:val="center" />', run(")")) .. "</w:tc>"
    local right
    if r == 1 then
      right = '<w:tc><w:tcPr><w:tcW w:w="' .. W[3] .. '" w:type="dxa" /><w:vMerge w:val="restart" />'
        .. '<w:vAlign w:val="center" /></w:tcPr>'
        .. para(SINGLE .. '<w:ind w:firstLine="0" />', run("Opposition No. " .. number)) .. "</w:tc>"
    else
      right = '<w:tc><w:tcPr><w:tcW w:w="' .. W[3] .. '" w:type="dxa" /><w:vMerge />'
        .. '<w:vAlign w:val="center" /></w:tcPr>' .. para(SINGLE, "") .. "</w:tc>"
    end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit /></w:trPr>" .. left .. mid .. right .. "</w:tr>"
  end
  local none = '<w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" />'
    .. '<w:insideH w:val="nil" /><w:insideV w:val="nil" />'
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="' .. (W[1] + W[2] + W[3]) .. '" w:type="dxa" />'
    .. "<w:tblBorders>" .. none .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:top w:w="29" w:type="dxa" /><w:left w:w="0" w:type="dxa" />'
    .. '<w:bottom w:w="29" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />'
    .. "</w:tblPr><w:tblGrid>"
    .. '<w:gridCol w:w="' .. W[1] .. '" /><w:gridCol w:w="' .. W[2] .. '" /><w:gridCol w:w="' .. W[3] .. '" />'
    .. "</w:tblGrid>" .. table.concat(out) .. "</w:tbl>"
  return raw(tbl)
end

-- A vertical space of exactly `twips` (typst's v(...em)): an empty paragraph on an exact line of that height.
local function spacer(twips)
  return raw(para('<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact" />', ""))
end

local function front_matter(meta)
  local blocks = { board_heading() }
  for _, b in ipairs(applications(meta)) do blocks[#blocks + 1] = raw(b) end
  blocks[#blocks + 1] = spacer(288)
  blocks[#blocks + 1] = caption_table(meta)
  blocks[#blocks + 1] = spacer(288)
  local title = runs(meta.title, true, false, true)
  blocks[#blocks + 1] = raw(para('<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" />', title))
  blocks[#blocks + 1] = spacer(144)
  return blocks
end

-- ---------------------------------------------------------------------------
-- Trailing blocks: signature, exhibit slip sheets
-- ---------------------------------------------------------------------------

local SIG_LEFT = tw(3.0)

-- Signature block, kept on one page (typst: a block that does not break). Every line but the last keeps with the next.
local function signature(meta)
  local sig = meta.signature
  local ind = '<w:ind w:left="' .. SIG_LEFT .. '" w:firstLine="0" />'
  local lines = {}
  if meta.date then
    lines[#lines + 1] = { sp(384, 0) .. '<w:ind w:firstLine="0" />', run("Date: ") .. runs(meta.date) }
  end
  lines[#lines + 1] = { sp(meta.date and 0 or 384, 0) .. ind, run("Respectfully submitted,") }
  lines[#lines + 1] = { sp(288, 0) .. ind, run("By: /" .. str_of(sig.signer) .. "/") }
  for _, l in ipairs(sig.lines) do
    lines[#lines + 1] = { SINGLE .. ind, runs(l) }
  end
  local blocks = {}
  for k, l in ipairs(lines) do
    local keep = (k < #lines) and "<w:keepNext />" or ""
    blocks[#blocks + 1] = raw(para(keep .. "<w:keepLines />" .. l[1], l[2]))
  end
  return blocks
end

-- One slip sheet per exhibit, on its own page: "EXHIBIT N" and its description, centered on the page both ways.
-- The sheet is a one-cell table of exact height (the text area less the two 1 pt spacer paragraphs), with its
-- cell vertically centered; a page break ends each spacer paragraph, so the table starts a new page.
local TINY = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact" /><w:ind w:firstLine="0" />'
local SHEET_HEIGHT = tw(9) - 60

local function with_page_break(xml)
  return (xml:gsub("</w:p>$", '<w:r><w:br w:type="page" /></w:r></w:p>'))
end

local function slip_sheet(label, desc)
  local centered = SINGLE .. '<w:ind w:firstLine="0" /><w:jc w:val="center" />'
  local cell = para(centered, run(label:upper(), true))
  if desc ~= "" then cell = cell .. para(centered, run(desc)) end
  local none = '<w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" />'
    .. '<w:insideH w:val="nil" /><w:insideV w:val="nil" />'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_WIDTH .. '" w:type="dxa" /><w:tblBorders>' .. none .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:top w:w="0" w:type="dxa" /><w:left w:w="0" w:type="dxa" />'
    .. '<w:bottom w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. TEXT_WIDTH .. '" /></w:tblGrid>'
    .. '<w:tr><w:trPr><w:trHeight w:val="' .. SHEET_HEIGHT .. '" w:hRule="exact" /></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. TEXT_WIDTH .. '" w:type="dxa" /><w:vAlign w:val="center" /></w:tcPr>'
    .. cell .. "</w:tc></w:tr></w:tbl>"
end

local function exhibit_sheets(meta)
  local blocks = {}
  if meta.exhibits == nil then return blocks end
  for _, ex in ipairs(meta.exhibits) do
    local text = str_of(ex)
    local label, desc = text:match("^(.-):%s*(.*)$")
    if label == nil then label, desc = text, "" end
    blocks[#blocks + 1] = raw(with_page_break(para(TINY, "")))
    blocks[#blocks + 1] = raw(slip_sheet(label, desc))
  end
  if #blocks > 0 then blocks[#blocks + 1] = raw(para(TINY, "")) end
  return blocks
end

-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local blocks = front_matter(meta)
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(exhibit_sheets(meta)) do blocks[#blocks + 1] = b end
  -- pandoc prints the title and date metadata as a title block; the notice's own heading block is above.
  doc.meta.title = nil
  doc.meta.date = nil
  return pandoc.Pandoc(blocks, doc.meta)
end
