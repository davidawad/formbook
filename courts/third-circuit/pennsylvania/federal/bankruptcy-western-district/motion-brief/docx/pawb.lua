-- pawb brief in support of a motion, DOCX engine (docs/DOCX.md). The markdown contract of the typst template
-- (typst/pawb-motion-brief.typ) becomes a Word document on docx/reference.docx:
--   cover: court title, the Form 416D caption (a borderless table with the two boxed cells), the title;
--   body: markdown through pandoc (headings, footnotes, block quotes, first-line indent on every paragraph);
--   signature block (from the frontmatter) after the body.
-- Everything case-specific comes from the frontmatter. Styles (Centered, Single, BodyText, headings, footnotes,
-- BlockText) are defined in docx/reference.docx. Page numbers come from its footer.

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local BOLD = "<w:b/><w:bCs/>"

local function run(text, rpr)
  local props = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. props .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local LINE_BREAK = "<w:r><w:br/></w:r>"

-- pPr children must stay in schema order: pStyle, keepNext, spacing, ind, jc
local function para(style, inner, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. "</w:pPr>" .. inner .. "</w:p>"
end

local function spacing(before, after)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="299" w:lineRule="exact"/>'
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- Form 416D caption: a 3-column borderless table (debtor/parties | gutter | case no./adv. no.), the left
-- boxes drawn with a top and right rule (debtor) or a bottom and right rule (parties), as in the typst grid.
local COL_LEFT, COL_GUTTER, COL_RIGHT = 4896, 360, 4104
local BORDER_TOP_RIGHT = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
local BORDER_BOTTOM_RIGHT = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cell(width, borders, top, bottom, right, inner)
  local b = borders and ("<w:tcBorders>" .. borders .. "</w:tcBorders>") or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. b
    .. '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:bottom w:w="' .. bottom
    .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. inner .. "</w:tc>"
end

local EMPTY_CELL = '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p>'
local DESIGNATION_IND = '<w:ind w:left="2160" w:firstLine="0"/>'

local function caption_table(meta)
  local debtor = {
    para("Single", run("In re:"), spacing(0, 0)),
    para("Single", run(plain(meta.debtor.name)), spacing(0, 0)),
    para("Single", run(plain(meta.debtor.designation)), spacing(0, 0) .. DESIGNATION_IND),
  }
  -- parties: each party's names one line each, the designation indented 1.5 in, 6.5 pt between parties
  local parties = {}
  for k, p in ipairs(meta.caption.parties) do
    for j, n in ipairs(p.names) do
      parties[#parties + 1] = para("Single", run(plain(n)), spacing(((k > 1 and j == 1) and 130 or 0), 0))
    end
    parties[#parties + 1] = para("Single", run(plain(p.designation)), spacing(0, 0) .. DESIGNATION_IND)
  end
  local case_cell = para("Single", run("Case No. " .. plain(meta.bankruptcy_case)) .. LINE_BREAK
    .. run(plain(meta.chapter)), spacing(0, 0))
  local adv = plain(meta.adversary_number)
  local adv_text = adv ~= "" and ("Adv. Proc. No. " .. adv) or ("Adv. Proc. No. " .. string.rep("_", 14))

  local row1 = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(COL_LEFT, BORDER_TOP_RIGHT, 120, 0, 200, table.concat(debtor))
    .. cell(COL_GUTTER, nil, 0, 0, 0, EMPTY_CELL)
    .. cell(COL_RIGHT, nil, 120, 0, 0, case_cell) .. "</w:tr>"
  local row2 = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(COL_LEFT, BORDER_BOTTOM_RIGHT, 260, 120, 200, table.concat(parties))
    .. cell(COL_GUTTER, nil, 0, 0, 0, EMPTY_CELL)
    .. cell(COL_RIGHT, nil, 390, 0, 0, para("Single", run(adv_text), spacing(0, 0))) .. "</w:tr>"

  local no_borders = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (COL_LEFT + COL_GUTTER + COL_RIGHT)
    .. '" w:type="dxa"/><w:tblBorders>' .. no_borders .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. COL_LEFT .. '"/><w:gridCol w:w="' .. COL_GUTTER .. '"/><w:gridCol w:w="' .. COL_RIGHT .. '"/></w:tblGrid>'
    .. row1 .. row2 .. "</w:tbl>"
end

-- signature block (typst signature-block): "Respectfully submitted,", the firm lines, then each attorney's name
-- ("/s/" on the filing user only), Bar ID and address lines; a 1.35 em gap before each group, lines kept together
local function signature(meta)
  local out = {}
  local function line(text, before, keep)
    local extra = (keep and "<w:keepNext/>" or "") .. spacing(before, 0)
    out[#out + 1] = raw(para("Single", run(text), extra))
  end
  line("Respectfully submitted,", 351, true)
  local firm = meta.signature.firm
  if firm then
    for j, l in ipairs(firm) do line(plain(l), (j == 1) and 351 or 0, true) end
  end
  local blocks = meta.signature.blocks
  for k, b in ipairs(blocks) do
    local first = (b.sign and "/s/" or "") .. plain(b.signer)
    local items = { first, plain(b.pa_id) }
    for _, l in ipairs(b.lines) do items[#items + 1] = plain(l) end
    for j, text in ipairs(items) do
      local last = (k == #blocks) and (j == #items)
      line(text, (j == 1) and 351 or 0, not last)
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta

  local out = {}
  out[#out + 1] = raw(para("Centered", run("IN THE UNITED STATES BANKRUPTCY COURT", BOLD) .. LINE_BREAK
    .. run("FOR THE WESTERN DISTRICT OF PENNSYLVANIA", BOLD), spacing(0, 390)))
  out[#out + 1] = raw(caption_table(meta))
  out[#out + 1] = raw(para("Centered", run(plain(meta.title), BOLD), spacing(390, 260)))

  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  for _, s in ipairs(signature(meta)) do out[#out + 1] = s end

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
