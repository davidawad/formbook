-- vtb DOCX engine (docs/DOCX.md): the markdown contract of the typst template -> a Word document on reference.docx.
-- The caption (court lines, debtor and parties table, title), the signature block and the paragraph numbers are
-- built here in the custom styles of reference.docx; the body keeps its markdown structure (headings, lists,
-- quotations). Mirrors typst/vtb-*.typ. Page numbers come from the reference's footer.
-- Paragraphs are numbered from 1; the first `unnumbered` paragraphs carry no number (motion brief, as filed).

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function items(v)
  local out = {}
  if v == nil then return out end
  local t = v.t
  if t == "MetaInlines" or t == "MetaString" or t == "MetaBlocks" then
    out[1] = plain(v)
  else
    for _, x in ipairs(v) do out[#out + 1] = plain(x) end
  end
  return out
end

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- one caption/signature paragraph: style, optional extra pPr (indent, jc) and text
local function xpara(style, text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr><w:r>' .. rpr
    .. '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r></w:p>'
end

-- a paragraph with a paragraph-level override (indent) on top of its style
local function xpara_ind(style, left, text)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/><w:ind w:left="' .. left .. '" w:firstLine="0"/></w:pPr><w:r><w:t xml:space="preserve">'
    .. xesc(text) .. '</w:t></w:r></w:p>'
end

-- the caption table (typst caption(): 3.35 in | 3.15 in; rules under and right of the debtor and parties cells)
local function cell(width, rule, mar, paras)
  local borders = ""
  if rule then
    borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
      .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. borders
    .. '<w:tcMar><w:top w:w="' .. mar.top .. '" w:type="dxa"/><w:left w:w="' .. mar.left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. mar.bottom .. '" w:type="dxa"/><w:right w:w="' .. mar.right .. '" w:type="dxa"/></w:tcMar>'
    .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function caption_table(meta)
  local d = meta.debtor or {}
  local c = meta.caption or {}
  local plaintiffs = items(c.plaintiffs)
  local defendants = items(c.defendants)
  local L, R = 4824, 4536
  local left1 = { xpara("Single", "In re: " .. plain(d.name) .. ","), xpara_ind("CaptionIndent", 2160, "Debtor.") }
  local right1 = { xpara("Single", "Chapter " .. plain(d.chapter)), xpara("Single", "Case No. " .. plain(d.case_no)) }
  local left2 = {}
  for _, p in ipairs(plaintiffs) do left2[#left2 + 1] = xpara("Single", p .. ",") end
  left2[#left2 + 1] = xpara_ind("CaptionIndent", 1440, "Plaintiff,")
  left2[#left2 + 1] = xpara_ind("CaptionHalf", 720, "v.")
  for _, dn in ipairs(defendants) do left2[#left2 + 1] = xpara("Single", dn) end
  left2[#left2 + 1] = xpara_ind("CaptionIndent", 2160, "Defendants.")
  local right2 = { xpara("Single", "Adv. Proc. No. " .. plain(meta.adv_no)) }
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. L .. '"/><w:gridCol w:w="' .. R .. '"/></w:tblGrid>'
    .. '<w:tr>' .. cell(L, true, { top = 0, left = 0, bottom = 202, right = 259 }, left1)
    .. cell(R, false, { top = 0, left = 360, bottom = 0, right = 0 }, right1) .. '</w:tr>'
    .. '<w:tr>' .. cell(L, true, { top = 216, left = 0, bottom = 202, right = 259 }, left2)
    .. cell(R, false, { top = 216, left = 360, bottom = 0, right = 0 }, right2) .. '</w:tr></w:tbl>'
  return tbl
end

local function caption(meta)
  local out = {}
  local court = items(meta.court)
  for i, l in ipairs(court) do
    local style = (i == #court) and "CourtLineLast" or "CourtLine"
    out[#out + 1] = pandoc.RawBlock("openxml", xpara(style, l, true))
  end
  out[#out + 1] = pandoc.RawBlock("openxml", caption_table(meta))
  out[#out + 1] = pandoc.RawBlock("openxml", xpara("CaptionTitle", plain(meta.title), true))
  return out
end

local function signature(meta)
  local out = {}
  local s = meta.signature
  if not s then return out end
  out[#out + 1] = pandoc.RawBlock("openxml", xpara("SigDate", plain(s.dated)))
  for _, l in ipairs(items(s.lines)) do
    out[#out + 1] = pandoc.RawBlock("openxml", xpara("SigLine", l))
  end
  return out
end

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function letter(i)
  return string.char(string.byte("a") + i - 1)
end

-- list items as lettered paragraphs: "(a)" from the list start; quoted items in the QuoteSingle style
local function lettered_items(lst, quoted, add)
  local start = 1
  if lst.t == "OrderedList" and lst.listAttributes then start = lst.listAttributes.start end
  for i, item in ipairs(lst.content) do
    for j, blk in ipairs(item) do
      if j == 1 and (blk.t == "Para" or blk.t == "Plain") then
        local inl = pandoc.List({ pandoc.Str("(" .. letter(start + i - 1) .. ")"), pandoc.Space() })
        inl:extend(blk.content)
        add(styled(quoted and "QuoteSingle" or "Lettered", inl))
      else
        add(blk)
      end
    end
  end
end

function Pandoc(doc)
  local meta = doc.meta
  local unnumbered = tonumber(plain(meta.unnumbered)) or 0
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function lettered(lst, quoted) lettered_items(lst, quoted, add) end

  for _, b in ipairs(caption(meta)) do add(b) end

  local n = 0
  local seen = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      seen = seen + 1
      if seen <= unnumbered then
        add(styled("Numbered", b.content))
      else
        n = n + 1
        local inl = pandoc.List({ pandoc.Str(tostring(n) .. ".") , pandoc.Space() })
        inl:extend(b.content)
        add(styled("Numbered", inl))
      end
    elseif b.t == "BlockQuote" then
      -- a quotation: single-spaced; a "(a)" list inside it (pandoc reads the letters as a list) keeps its letters
      for _, q in ipairs(b.content) do
        if q.t == "Para" or q.t == "Plain" then
          add(styled("QuoteSingle", q.content))
        elseif q.t == "BulletList" or q.t == "OrderedList" then
          lettered(q, true)
        else
          add(q)
        end
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      lettered(b, false)
    else
      add(b)
    end
  end

  -- the last paragraph of the body stays with the signature block
  local last = out[#out]
  if meta.signature and last and last.t == "Div" then
    local st = last.attr.attributes["custom-style"]
    if st == "Numbered" or st == "Lettered" then last.attr.attributes["custom-style"] = st .. "Keep" end
  end

  for _, b in ipairs(signature(meta)) do add(b) end

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
