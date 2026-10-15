-- Adversary complaint, United States Bankruptcy Court, District of the Virgin Islands (vib), DOCX engine
-- (docs/DOCX.md). The markdown contract (../README.md) -> a Word document on reference.docx.
-- Built here, as the typst template builds them: the court header, the caption (a table with the rules of
-- VIB-AC-CAPTION), the title, the numbered paragraphs (one counter for the whole document, VIB-AC-NUMBER),
-- and the signature block (VIB-AC-SIGNATURE). Everything else is the markdown body in the styles of
-- reference.docx. The footer ("Page n of N") is in reference.docx.
-- Known limits: the footer carries no short title (a reference footer cannot take per-document text in pandoc);
-- the caption table is raw WordprocessingML, so its borders are drawn by Word and LibreOffice alike, but
-- Word may space its rows a little differently (see README.md, "Engines").

local COL = { 4968, 4392 } -- the caption: 3.45 in and the rest of the 6.5 in text block (twips)
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local PAGE_BREAK = pandoc.RawBlock("openxml",
  '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- inline content of a metadata value (markdown inlines, as parsed from the YAML)
local function inlines(v)
  if v == nil then return pandoc.List({}) end
  if v.t == "MetaInlines" then return pandoc.List(v) end
  return pandoc.List({ pandoc.Str(txt(v)) })
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function attr(style) return pandoc.Attr("", {}, { ["custom-style"] = style }) end
local function styled(style, inl) return pandoc.Div({ pandoc.Para(inl) }, attr(style)) end

-- vertical space of `twips`, as an empty paragraph on an exact line
local function gap(twips)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

local function centered_bold(inl)
  return styled("Centered", { pandoc.Strong(inl) })
end

-- caption table: a left column (debtor, then the adversary parties) and a right column (chapter, case and
-- adversary numbers), with the rules of Form 416: a box around the left column, a vertical rule between the
-- columns, no other rules
local function xpara(text, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="Front"/>' .. (ppr or "") .. '</w:pPr><w:r><w:t xml:space="preserve">'
    .. esc(text) .. '</w:t></w:r></w:p>'
end

local function rule(side, on)
  if on then return '<w:' .. side .. ' w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  return '<w:' .. side .. ' w:val="nil"/>'
end

local function cell(width, top, left, bottom, right, mar, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/><w:tcBorders>'
    .. rule("top", top) .. rule("left", left) .. rule("bottom", bottom) .. rule("right", right)
    .. '</w:tcBorders><w:tcMar>' .. mar .. '</w:tcMar></w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function margins(top, bottom, left, right)
  return '<w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/><w:bottom w:w="'
    .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/>'
end

local function names_xml(list, ppr_first)
  local out = {}
  for i, n in ipairs(list) do out[#out + 1] = xpara(txt(n), i == 1 and ppr_first or nil) end
  return out
end

local function caption_table(meta)
  local debtor, adv, sides = meta.debtor, meta.adversary, meta.caption
  local plaintiff, defendant = sides[1], sides[2]
  local indent = '<w:ind w:left="1728" w:firstLine="0"/>' -- 1.2 in, the designation
  local r0c0, r0c1, r1c0, r1c1 = {}, {}, {}, {}
  r0c0[#r0c0 + 1] = xpara("In re:", '<w:spacing w:after="120"/>')
  for _, n in ipairs(debtor.names) do r0c0[#r0c0 + 1] = xpara(txt(n)) end
  r0c0[#r0c0 + 1] = xpara(txt(debtor.designation), indent)
  r0c1[#r0c1 + 1] = xpara(txt(meta.chapter), '<w:spacing w:after="240"/>')
  r0c1[#r0c1 + 1] = xpara("Case No. " .. txt(meta.case_number))
  for _, n in ipairs(plaintiff.names) do r1c0[#r1c0 + 1] = xpara(txt(n)) end
  r1c0[#r1c0 + 1] = xpara(txt(plaintiff.designation), indent)
  r1c0[#r1c0 + 1] = xpara("v.", '<w:spacing w:before="120" w:after="120"/>')
  for _, n in ipairs(defendant.names) do r1c0[#r1c0 + 1] = xpara(txt(n)) end
  r1c0[#r1c0 + 1] = xpara(txt(defendant.designation), indent)
  r1c1[#r1c1 + 1] = xpara("Adv. Proc. No. " .. txt(adv.number))
  if adv.note then r1c1[#r1c1 + 1] = xpara(txt(adv.note), '<w:spacing w:before="120"/>') end

  local row1 = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(COL[1], true, false, true, true, margins(100, 180, 0, 360), r0c0)
    .. cell(COL[2], false, true, false, false, margins(100, 180, 360, 0), r0c1) .. '</w:tr>'
  local row2 = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(COL[1], false, false, true, true, margins(180, 180, 0, 360), r1c0)
    .. cell(COL[2], false, true, false, false, margins(180, 180, 360, 0), r1c1) .. '</w:tr>'
  return pandoc.RawBlock("openxml", '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. COL[1] .. '"/><w:gridCol w:w="' .. COL[2] .. '"/></w:tblGrid>'
    .. row1 .. row2 .. '</w:tbl>')
end

-- numbered paragraphs: every list item of the body is one paragraph, numbered from one counter through the
-- whole document (VIB-AC-NUMBER). The typed numbers are not used, as in the typst template.
local function numbered(blocks)
  local out, n = {}, 0
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        n = n + 1
        local first = true
        for _, ib in ipairs(item) do
          if first and (ib.t == "Para" or ib.t == "Plain") then
            local inl = pandoc.List({ pandoc.Str(tostring(n) .. "."), TAB })
            inl:extend(ib.content)
            out[#out + 1] = styled("Numbered Paragraph", inl)
            first = false
          else
            out[#out + 1] = ib
          end
        end
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  -- pandoc would write the metadata title and date as a block at the top of the body; the cover has its own
  -- title and the "Dated:" line, so they are taken out of the metadata here
  local title, date = meta.title, meta.date
  meta.title = nil
  meta.date = nil

  -- cover: court header, caption, title (VIB-AC-CAPTION)
  add(centered_bold({ pandoc.Str("IN THE DISTRICT COURT OF THE VIRGIN ISLANDS") }))
  add(centered_bold({ pandoc.Str("DIVISION OF " .. txt(meta.division):upper() .. ", BANKRUPTCY DIVISION") }))
  add(gap(416))
  add(caption_table(meta))
  add(gap(416))
  add(centered_bold({ pandoc.Str(txt(title):upper()) }))
  add(gap(156))

  for _, b in ipairs(numbered(doc.blocks)) do add(b) end

  -- signature block (VIB-AC-SIGNATURE): dated, then each counsel group, separated by "- and -"
  add(styled("Front", { pandoc.Str("Dated: " .. txt(date)) }))
  for i, g in ipairs(meta.signature or {}) do
    if i > 1 then
      add(gap(260))
      add(styled("Signature", { pandoc.Str("- and –") }))
      add(gap(208))
    else
      add(gap(208))
    end
    if g.signer then
      add(styled("Signature", { pandoc.Str("By: /s/ " .. txt(g.signer)) }))
    else
      add(gap(208))
    end
    for _, l in ipairs(g.lines or {}) do add(styled("Signature", inlines(l))) end
  end

  doc.blocks = out
  return doc
end
