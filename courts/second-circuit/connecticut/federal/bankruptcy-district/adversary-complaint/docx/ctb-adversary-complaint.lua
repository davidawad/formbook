-- Adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> the layout of typst/ctb-adversary-complaint.typ
-- on reference.docx. The cover (court name, caption box with its right and bottom rules, title) and the signature block are
-- written as OpenXML tables, which pandoc's table model cannot style. The body keeps its markdown structure; numbered
-- paragraphs (FRCP 10(b) via FRBP 7010) get their number typed, as the typst counter does: continuous from the first
-- heading, not under the prayer for relief. The frontmatter is read here; no case text is written into this file.

local function S(v) if v == nil then return "" end return pandoc.utils.stringify(v) end

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, rpr)
  rpr = rpr or ""
  return '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
    '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
end

-- one OpenXML paragraph: style id, pPr children (in schema order, after pStyle), plain text
local function P(style, text, ppr, rpr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' ..
    (text and text ~= "" and run(text, rpr) or "") .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock('openxml', xml) end

-- the caption of the typst template: left party box (3.4 in, right and bottom rules), a gutter, the right column
local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local function caption_row(left_xml, right_xml)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="288"/><w:gridCol w:w="4176"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/>' .. RULE ..
    '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>' .. left_xml .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    right_xml .. '</w:tc></w:tr></w:tbl>'
end

local function cap(text, indent)
  return P("CaptionLine", text, indent and ('<w:ind w:left="' .. indent .. '"/>') or nil)
end

local function caption(meta)
  local out = {}
  out[#out + 1] = P("CourtName", string.upper(S(meta.court)))
  out[#out + 1] = P("CourtName", string.upper(S(meta.district)))
  out[#out + 1] = P("CourtName", string.upper(S(meta.division)))
  out[#out + 1] = P("Normal", "")                                  -- v(body-leading)
  -- row 1: the debtors | the chapter and the main case
  local l1 = cap("In re:") .. cap(S(meta.debtors), 720) .. cap("Debtors.", 3600)
  local r1 = cap("Chapter " .. S(meta.chapter)) .. cap(S(meta.main_case))
  if meta.jointly_administered == true or S(meta.jointly_administered) == "true" then
    r1 = r1 .. cap("(Jointly Administered)")
  end
  out[#out + 1] = caption_row(l1, r1)
  out[#out + 1] = P("CaptionLine", "")                             -- v(body-leading * 0.5)
  -- row 2: the parties | the adversary number and the date
  local l2 = ""
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then l2 = l2 .. cap("v.", 2880) end
    for _, n in ipairs(p.names or {}) do l2 = l2 .. cap(S(n)) end
    l2 = l2 .. cap(S(p.designation), 3600)
  end
  local r2 = cap("Adv. Pro. No. " .. S(meta.adv_number) .. " (" .. S(meta.judge) .. ")") .. cap("Dated: " .. S(meta.date))
  out[#out + 1] = caption_row(l2, r2)
  out[#out + 1] = P("Normal", "")                                  -- v(body-leading)
  -- title: the frontmatter title, bold and centred
  out[#out + 1] = P("CoverTitle", S(meta.title))
  out[#out + 1] = P("Normal", "")                                  -- v(body-leading)
  return out
end

-- the signature block: the date and place at left (3.0 in), the party, the signature, the signers, the firm, the role
local function signature(meta)
  local s = meta.signature
  local left, right = {}, {}
  left[#left + 1] = P("SignatureLine", "Dated: " .. S(meta.date))
  left[#left + 1] = P("SignatureLine", S(s.dated_place))
  right[#right + 1] = P("SignatureLine", string.upper(S(s.party)))
  right[#right + 1] = P("SignatureLine", "By: /s/ " .. S(s.esigner))
  for _, signer in ipairs(s.signers or {}) do
    right[#right + 1] = P("SignatureLine", S(signer[1]))
    right[#right + 1] = P("SignatureLine", S(signer[2]))
  end
  for _, l in ipairs(s.firm or {}) do right[#right + 1] = P("SignatureLine", S(l)) end
  right[#right + 1] = P("SignatureLine", S(s.role))
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4320"/><w:gridCol w:w="288"/><w:gridCol w:w="4752"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. '</w:tc>' ..
    '</w:tr></w:tbl>'
  return { raw(P("Normal", "")), raw(tbl) }
end

-- inlines of a block that the body keeps (a list item's first paragraph, with a letter typed in front)
local function lettered(b)
  local out = {}
  local start = b.listAttributes.start
  for i, item in ipairs(b.content) do
    local letter = string.char(string.byte("a") + start - 1 + i - 1)
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inl = { pandoc.Str(letter .. ".") , pandoc.Space() }
      for _, x in ipairs(first.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Lettered Item" })
      for k = 2, #item do out[#out + 1] = item[k] end
    else
      for _, blk in ipairs(item) do out[#out + 1] = blk end
    end
  end
  return out
end

function Pandoc(doc)
  local out = {}
  local numbered = false
  local n = 0
  for _, c in ipairs(caption(doc.meta)) do out[#out + 1] = raw(c) end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      numbered = not S(b.content):find("PRAYER", 1, true)
      out[#out + 1] = b
    elseif b.t == "Para" and numbered then
      n = n + 1
      local inl = { pandoc.Str(n .. "."), pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>') }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Numbered Paragraph" })
    elseif b.t == "OrderedList" and b.listAttributes.style == "LowerAlpha" then
      for _, x in ipairs(lettered(b)) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end
  for _, x in ipairs(signature(doc.meta)) do out[#out + 1] = x end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
