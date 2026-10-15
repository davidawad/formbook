-- mdd-complaint.lua (docx engine). Adds what pandoc's default conversion lacks, following complaint/typst/mdd-complaint.typ:
--   * the cover: court lines, the caption (a Word table with the right and bottom rules), the title, the lead-in;
--   * numbered allegations (FRCP 10(b)): each body paragraph is numbered 1, 2, ... with a tab after the number;
--   * a paragraph beginning "^ " is unnumbered (WHEREFORE, the jury demand); the marker is removed;
--   * markdown lists are lettered (a), (b), ... with a hanging indent;
--   * the signature block (a borderless two-column table) after the last paragraph.
-- Everything here is metadata-driven: nothing case-specific, no forced line breaks, no coordinates.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- Inline content to WordprocessingML runs. fmt is extra run properties (already in schema order: b before i).
local function runs(inlines, fmt)
  fmt = fmt or ""
  local out = {}
  local function emit(s)
    if s ~= "" then
      table.insert(out, '<w:r><w:rPr>' .. fmt .. '</w:rPr><w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>')
    end
  end
  for _, el in ipairs(inlines) do
    local t = el.t
    if t == "Str" then emit(el.text)
    elseif t == "Space" or t == "SoftBreak" then emit(" ")
    elseif t == "Emph" then table.insert(out, runs(el.content, fmt .. "<w:i/>"))
    elseif t == "Strong" then table.insert(out, runs(el.content, fmt .. "<w:b/>"))
    elseif t == "Quoted" then
      local o, c = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then o, c = "\u{2018}", "\u{2019}" end
      emit(o)
      table.insert(out, runs(el.content, fmt))
      emit(c)
    elseif t == "Span" or t == "Link" then table.insert(out, runs(el.content, fmt))
    else emit(pandoc.utils.stringify(el)) end
  end
  return table.concat(out)
end

-- Paragraph with pPr in schema order: pStyle, keepNext, spacing, ind, jc.
local function para(o, body)
  local p = '<w:p><w:pPr>'
  if o.style then p = p .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep then p = p .. '<w:keepNext/>' end
  if o.spacing then p = p .. '<w:spacing ' .. o.spacing .. '/>' end
  if o.ind then p = p .. '<w:ind ' .. o.ind .. '/>' end
  if o.jc then p = p .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return p .. '</w:pPr>' .. (body or '') .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock('openxml', xml) end

local function inl(v)
  if type(v) == "string" then return runs({ pandoc.Str(v) }) end
  return runs(v)
end

-- Caption: left column (3.6 in = 5184 twips) with right and bottom rules, right column (4176) with the case number.
local function caption_xml(meta)
  local parties = meta.caption.parties
  local left = {}
  for k, p in ipairs(parties) do
    if k > 1 then
      table.insert(left, para({ style = "CaptionLeft", spacing = 'w:before="276" w:after="276"', jc = "center" }, runs({ pandoc.Str("v.") })))
    end
    for _, nm in ipairs(p.names) do table.insert(left, para({ style = "CaptionLeft" }, inl(nm))) end
    if p.address then for _, a in ipairs(p.address) do table.insert(left, para({ style = "CaptionLeft" }, inl(a))) end end
    if p.county then table.insert(left, para({ style = "CaptionLeft" }, inl(p.county))) end
    local after = (k == #parties) and 240 or 0
    table.insert(left, para({ style = "CaptionLeft", spacing = 'w:before="276" w:after="' .. after .. '"', ind = 'w:left="2592" w:right="288"' }, inl(p.designation)))
  end
  local num = txt(meta.case_number)
  local casexml
  if num == "" then
    casexml = runs({ pandoc.Str("Case No.") }) .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>'
  else
    casexml = runs({ pandoc.Str("Case No. " .. num) })
  end
  local right = { para({ style = "CaptionRight", spacing = 'w:before="72" w:after="0"' }, casexml) }
  local function cell(w, borders, paras)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. borders .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5184"/><w:gridCol w:w="4176"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(5184, rule, left) .. cell(4176, '', right)
    .. '</w:tr></w:tbl>'
end

-- Signature block (LR-102.1.b.i): two columns, 3.4 in and 3.1 in, as the typst grid. Kept together.
local function signature_xml(meta, complaint)
  local sig = meta.signature
  local function line(s) return para({ style = "SignatureLine", keep = true }, inl(s)) end
  local right = {}
  local first = true
  local function add(s)
    if first then
      table.insert(right, para({ style = "SignatureLine", keep = true, spacing = 'w:before="552" w:after="0"' }, inl(s)))
      first = false
    else table.insert(right, line(s)) end
  end
  if complaint then add("Respectfully submitted,") end
  add("/s/ " .. txt(sig.name))
  add(txt(sig.name))
  add(txt(sig.bar))
  for _, f in ipairs(sig.firm) do add(txt(f)) end
  for _, a in ipairs(sig.address) do add(txt(a)) end
  add("Telephone: " .. txt(sig.phone))
  add("Facsimile: " .. txt(sig.fax))
  add(txt(sig.email))
  add(txt(sig.role))
  local dated = ""
  if meta.date then dated = para({ style = "SignatureLine", keep = true, spacing = 'w:before="552" w:after="0"' }, inl("Dated: " .. txt(meta.date))) end
  if dated == "" then dated = para({ style = "SignatureLine", keep = true, spacing = 'w:before="552" w:after="0"' }, "") end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/></w:tcPr>' .. dated .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

local function is_marker(el) return el and el.t == "Str" and el.text == "^" end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  -- Cover: court lines (single spaced, centered), a 27.6 pt gap, the caption, a gap, the title, half a gap.
  local court = m.court
  for k, c in ipairs(court) do
    local last = (k == #court)
    table.insert(out, raw(para({ style = "CourtLine", spacing = last and 'w:before="0" w:after="552"' or nil }, inl(c))))
  end
  table.insert(out, raw(caption_xml(m)))
  table.insert(out, raw(para({ style = "CoverTitle" }, '<w:r><w:rPr><w:b/><w:caps/></w:rPr><w:t xml:space="preserve">' .. esc(txt(m.brief_title)) .. '</w:t></w:r>')))
  if m.lead_in then table.insert(out, pandoc.Para(pandoc.utils.blocks_to_inlines(pandoc.read(txt(m.lead_in), "markdown").blocks))) end

  -- Body.
  local n = 0
  local nblocks = #doc.blocks
  for bi, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local c = b.content
      if is_marker(c[1]) then
        local rest = { table.unpack(c, 2) }
        if rest[1] and rest[1].t == "Space" then table.remove(rest, 1) end
        if bi == nblocks then
          table.insert(out, pandoc.Div({ pandoc.Para(rest) }, pandoc.Attr("", {}, { ["custom-style"] = "Closing Paragraph" })))
        else
          table.insert(out, pandoc.Para(rest))
        end
      else
        n = n + 1
        local lead = { pandoc.Str(tostring(n) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        local inlines = {}
        for _, x in ipairs(lead) do table.insert(inlines, x) end
        for _, x in ipairs(c) do table.insert(inlines, x) end
        table.insert(out, pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Paragraph" })))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local label = "(" .. string.char(96 + i) .. ")"
        local first = item[1]
        local inlines = { pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        if first and (first.t == "Para" or first.t == "Plain") then
          for _, x in ipairs(first.content) do table.insert(inlines, x) end
          local blocks = { pandoc.Para(inlines) }
          for j = 2, #item do table.insert(blocks, item[j]) end
          table.insert(out, pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = "Lettered Item" })))
        else
          table.insert(out, pandoc.Div({ pandoc.Para(inlines), table.unpack(item) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered Item" })))
        end
      end
    else
      table.insert(out, b)
    end
  end

  -- Signature block (kept with the last paragraph by keepNext on the last body paragraph is not set; the block itself is kept together).
  table.insert(out, raw(signature_xml(m, true)))
  return pandoc.Pandoc(out)
end
