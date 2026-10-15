-- pawb adversary complaint, DOCX engine (docs/DOCX.md). The markdown contract of the typst template
-- (typst/pawb-adversary-complaint.typ) becomes a Word document on docx/reference.docx:
--   cover: court title, the Form 416D caption (a borderless table with the two boxed cells), the title;
--   body: markdown through pandoc; numbered paragraphs ("N." and a 1 in tab) except the lead-in, WHEREFORE
--         clauses and the certificate; hard-break chunks (addresses) single-spaced and unindented;
--   signature block (from the frontmatter) before the certificate, which starts on a new page.
-- Everything case-specific comes from the frontmatter. Styles (Centered, Single, Address, BodyText, headings)
-- are defined in docx/reference.docx. Page numbers come from its footer.

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

-- the page break as its own 1 pt paragraph, so no empty body line opens the next page
local PAGE_BREAK = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>'

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
  local case_no = "Case No. " .. plain(meta.bankruptcy_case)
  local case_cell = para("Single", run(case_no) .. LINE_BREAK .. run(plain(meta.chapter)), spacing(0, 0))
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

-- signature block (typst signature-block): "Respectfully submitted,", the date, then each signer's "/s/" name,
-- upper-case name, Bar ID and address lines; one 1.35 em gap before each group, lines kept together
local function signature(meta)
  local out = {}
  local function line(text, before, keep)
    local extra = (keep and "<w:keepNext/>" or "") .. spacing(before, 0)
    out[#out + 1] = raw(para("Single", run(text), extra))
  end
  line("Respectfully submitted,", 351, true)
  line("Date: " .. plain(meta.date), 351, true)
  local blocks = meta.signature.blocks
  for k, b in ipairs(blocks) do
    local items = { "/s/ " .. plain(b.signer), string.upper(plain(b.signer)), plain(b.pa_id) }
    for _, l in ipairs(b.lines) do items[#items + 1] = plain(l) end
    for j, text in ipairs(items) do
      local last = (k == #blocks) and (j == #items)
      line(text, (j == 1) and 351 or 0, not last)
    end
  end
  return out
end

local function has_line_break(p)
  for _, el in ipairs(p.content) do
    if el.t == "LineBreak" then return true end
  end
  return false
end

function Pandoc(doc)
  local meta = doc.meta

  local out = {}
  out[#out + 1] = raw(para("Centered", run("IN THE UNITED STATES BANKRUPTCY COURT", BOLD) .. LINE_BREAK
    .. run("FOR THE WESTERN DISTRICT OF PENNSYLVANIA", BOLD), spacing(0, 390)))
  out[#out + 1] = raw(caption_table(meta))
  out[#out + 1] = raw(para("Centered", run(plain(meta.title), BOLD), spacing(390, 260)))

  local started, certificate, numbered, sig_done = false, false, 0, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = plain(b.content)
      if b.level == 1 and text:match("^CERTIFICATE") then
        if not sig_done then
          for _, s in ipairs(signature(meta)) do out[#out + 1] = s end
          sig_done = true
        end
        out[#out + 1] = raw(PAGE_BREAK)
        certificate = true
      else
        certificate = false
      end
      started = true
      out[#out + 1] = b
    elseif b.t == "Para" then
      if has_line_break(b) then
        -- an address or a signature line group: single-spaced, unindented (typst: hard-break chunks)
        out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Address" }))
      else
        if started and not certificate and not plain(b):match("^WHEREFORE") then
          numbered = numbered + 1
          table.insert(b.content, 1, pandoc.RawInline("openxml", run(numbered .. ".") .. "<w:r><w:tab/></w:r>"))
        end
        out[#out + 1] = b
      end
    else
      out[#out + 1] = b
    end
  end
  if not sig_done then
    for _, s in ipairs(signature(meta)) do out[#out + 1] = s end
  end

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
