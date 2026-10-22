-- ttab-notice.lua (docx engine, notice of opposition). Builds the front matter and the trailing blocks of the
-- notice as WordprocessingML, from the same YAML frontmatter the typst template reads (../README.md, "Markdown
-- contract"), and leaves the body paragraphs to pandoc (Body Text from reference.docx, see make-reference.sh).
--   * the USPTO heading and the "In re Application of" block (a tab stop, a hanging indent);
--   * the party caption as a borderless table: names, a ")" column, and the opposition number on the middle row;
--   * the title, the count headings, the signature block (left indent 3 in.) kept with the last paragraph, one slip
--     sheet per exhibit (a one-cell table vertically centered on its page, after a page break);
--   * the document metadata is cleared, so pandoc prints no title block.
-- No case text is in this file. Every value comes from the sample's frontmatter.
--
-- Cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph has
-- exact line spacing at the typst template's pitch (typst/ttab-notice-of-opposition.typ: pitch-double 24 pt = 480
-- twips, pitch-single 13.8 pt = 276 twips) and the typst spaces between blocks (twips = 20 x pt). Where typst
-- collapses two spaces to the larger, the larger is written on one side only.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local TWIP = 1440
local function tw(inches) return math.floor(inches * TWIP + 0.5) end

local SINGLE = 276
local DOUBLE = 480
local INDENT = 720
local TEXT_WIDTH = tw(6.5)
local SIG_LEFT = tw(3.0)

local function T(s, o) return xe.runs(s, o) end
local function I(v, o) return xe.inl(v, o) end

local function upper_inl(v)
  return pandoc.Inlines(v):walk({ Str = function(e) return pandoc.Str(pandoc.text.upper(e.text)) end })
end

-- One single-spaced paragraph: o = { before, after, left, hanging, jc, keep, tabs, line }
local function line(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and 0 or nil)
  if o.jc then props[#props + 1] = xe.jc(o.jc) end
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>' ..
  '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local NO_MARGINS = '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
local function tbl_open(widths)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do total = total + w; grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS ..
    '<w:tblLayout w:type="fixed"/>' .. NO_MARGINS ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>' ..
    '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
end
local function cell(w, body, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Front matter
-- ---------------------------------------------------------------------------

-- TBMP 309.02(a): the heading the Board requires at the top of the complaint (two lines, centered, bold).
local function board_heading()
  -- 4 pt above the first line (typst top-gap): the ascender of the face stays inside the top margin
  return line(T("IN THE UNITED STATES PATENT AND TRADEMARK OFFICE", { b = true }), { jc = "center", keep = true, before = 80 }) ..
    line(T("BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD", { b = true }), { jc = "center", keep = true })
end

-- TBMP 309.02(a): identification of the applications opposed; a label column of 2.2 in. (typst label-col):
-- 14.4 pt above each application, 4.2 pt between its rows.
local function applications(meta)
  local out = {}
  local labels = {
    { "applicant", "In re Application of:" },
    { "serial", "Serial No.:" },
    { "mark", "Mark:" },
    { "application_date", "Application Date:" },
    { "publication_date", "Publication Date:" },
  }
  if meta.applications == nil then return "" end
  local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. tw(2.2) .. '"/></w:tabs>'
  for _, app in ipairs(meta.applications) do
    for n, pair in ipairs(labels) do
      local key, label = pair[1], pair[2]
      out[#out + 1] = line(T(label .. "\t") .. I(app[key]), {
        keep = n < #labels, tabs = tabs, left = tw(2.2), hanging = tw(2.2),
        before = (n == 1) and 288 or 84 })
    end
  end
  return table.concat(out)
end

-- The party caption, TBMP 309.02(a). One table row per line, a ")" column beside every row, and the
-- opposition number on the middle row. 14.4 pt above it (typst caption-table).
local function caption_table(meta)
  local sides = meta.caption
  local rows = {}
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do rows[#rows + 1] = { ind = 0, body = I(name) } end
    rows[#rows + 1] = { ind = tw(2.1), body = I(side.designation) }
    if i < #sides then
      rows[#rows + 1] = { ind = 0, body = "" }
      rows[#rows + 1] = { ind = tw(1.2), body = T("v.") }
      rows[#rows + 1] = { ind = 0, body = "" }
    end
  end
  local number = meta.opposition_no and stringify(meta.opposition_no) or "______________"
  local mid = math.floor(#rows / 2) + 1
  local W = { tw(3.4), tw(0.35), tw(2.4) }
  local out = {}
  for r, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. SINGLE .. '" w:hRule="exact"/></w:trPr>' ..
      cell(W[1], line(row.body, { left = row.ind })) ..
      cell(W[2], line(T(")"), { jc = "center" })) ..
      cell(W[3], line(r == mid and T("Opposition No. " .. number) or "")) .. '</w:tr>'
  end
  -- the space above the table: an empty exact line (a table cannot carry space before)
  local gap = line("", { line = 288, keep = true })
  return gap .. tbl_open(W) .. table.concat(out) .. '</w:tbl>'
end

local function front_matter(meta)
  local title = line(I(upper_inl(meta.title), { b = true }), { jc = "center", keep = true, before = 288, after = 144 })
  return xe.raw(board_heading() .. applications(meta) .. caption_table(meta) .. title)
end

-- ---------------------------------------------------------------------------
-- Trailing blocks: signature, exhibit slip sheets
-- ---------------------------------------------------------------------------

-- Signature block, kept on one page (typst: a block that does not break), 19.2 pt below the last paragraph.
local function signature(meta)
  local sig = meta.signature
  local out = {}
  if meta.date then
    out[#out + 1] = line(T("Date: ") .. I(meta.date), { keep = true, before = 384 })
  end
  out[#out + 1] = line(T("Respectfully submitted,"), { keep = true, left = SIG_LEFT, before = meta.date and 0 or 384 })
  out[#out + 1] = line(T("By: /" .. stringify(sig.signer) .. "/"), { keep = true, left = SIG_LEFT, before = 288 })
  local lines = sig.lines or {}
  for k, l in ipairs(lines) do
    out[#out + 1] = line(I(l), { keep = k < #lines, left = SIG_LEFT })
  end
  return xe.raw(table.concat(out))
end

-- One slip sheet per exhibit, on its own page: "EXHIBIT N" and its description, centered on the page both ways.
-- The sheet is a one-cell table of exact height (the text area less the two 1 pt spacer paragraphs), with its
-- cell vertically centered; a page break ends each spacer paragraph, so the table starts a new page.
local TINY = '<w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/></w:pPr>'
local SHEET_HEIGHT = tw(9) - 60

local function slip_sheet(label, desc)
  local c = line(T(pandoc.text.upper(label), { b = true }), { jc = "center" })
  if desc ~= "" then c = c .. line(T(desc), { jc = "center" }) end
  return tbl_open({ TEXT_WIDTH }) ..
    '<w:tr><w:trPr><w:trHeight w:val="' .. SHEET_HEIGHT .. '" w:hRule="exact"/></w:trPr>' ..
    cell(TEXT_WIDTH, c, '<w:vAlign w:val="center"/>') .. '</w:tr></w:tbl>'
end

local function exhibit_sheets(meta)
  local out = {}
  if meta.exhibits == nil then return nil end
  for _, ex in ipairs(meta.exhibits) do
    local text = stringify(ex)
    local label, desc = text:match("^(.-):%s*(.*)$")
    if label == nil then label, desc = text, "" end
    out[#out + 1] = '<w:p>' .. TINY .. '<w:r><w:br w:type="page"/></w:r></w:p>'
    out[#out + 1] = slip_sheet(label, desc)
  end
  if #out > 0 then out[#out + 1] = '<w:p>' .. TINY .. '</w:p>' end
  return xe.raw(table.concat(out))
end

-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ Inlines = xe.inlines })
  local blocks = pandoc.List({ front_matter(meta) })
  local n = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- count headings: centered, bold, capitals, single-spaced; 16.8 pt above, 12 pt below
      blocks:insert(xe.raw(line(I(upper_inl(b.content), { b = true }),
        { keep = true, before = 336, after = 240, jc = "center", outline = b.level - 1 })))
    elseif i == n and b.t == "Para" then
      -- the last paragraph is kept with the signature block (typst: one unbreakable block)
      blocks:insert(xe.raw(xe.para({ xe.KEEP, xe.spacing(0, 0, DOUBLE), xe.ind(0, nil, INDENT) }, I(b.content))))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      blocks:extend(xe.list_items(b))
    else
      blocks:insert(b)
    end
  end
  blocks:insert(signature(meta))
  local ex = exhibit_sheets(meta)
  if ex then blocks:insert(ex) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
