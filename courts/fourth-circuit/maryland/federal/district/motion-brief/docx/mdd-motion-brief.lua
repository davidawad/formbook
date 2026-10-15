-- mdd-motion-brief.lua (docx engine). Adds what pandoc's default conversion lacks, following motion-brief/typst/mdd-motion-brief.typ:
--   * the cover: court lines, the short caption (first plaintiff and first defendant only, LR 102.2.a; a Word table with
--     a right rule), the title; no separate cover page, the body starts under the title;
--   * lists are numbered 1., 2., ... with a hanging indent (the template numbers markdown lists, not paragraphs);
--   * the signature block and the certificate of service (optional, after the signature block), kept together;
--   * toc: true is refused: the table of contents (LR 105.4) is not built for docx (BLOCKED, see README).
-- Nothing case-specific, no forced line breaks, no coordinates.

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

-- Short caption (LR 102.2.a): the first plaintiff and the first defendant only, and the case number. Left column
-- 3.4 in (4896 twips) with a right rule (the typst caption has no bottom rule here), right column 4464.
local function caption_xml(meta)
  local parties = meta.caption.parties
  if #parties ~= 2 then error("mdd-motion-brief: LR 102.2.a: the short caption names the first plaintiff and the first defendant only") end
  local left = {}
  for k, p in ipairs(parties) do
    if k > 1 then
      table.insert(left, para({ style = "CaptionLeft", spacing = 'w:before="276" w:after="276"', jc = "center" }, runs({ pandoc.Str("v.") })))
    end
    for _, nm in ipairs(p.names) do table.insert(left, para({ style = "CaptionLeft" }, inl(nm))) end
    local after = (k == #parties) and 240 or 0
    table.insert(left, para({ style = "CaptionLeft", spacing = 'w:before="276" w:after="' .. after .. '"', ind = 'w:left="2592" w:right="288"' }, inl(p.designation)))
  end
  local right = { para({ style = "CaptionRight", spacing = 'w:before="72" w:after="0"' }, runs({ pandoc.Str("Case No. " .. txt(meta.case_number)) })) }
  local function cell(w, borders, paras)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. borders .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(4896, rule, left) .. cell(4464, '', right)
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

local function lettered_label_numbers(i) return tostring(i) .. "." end

function Pandoc(doc)
  local m = doc.meta
  if m.toc and txt(m.toc) == "true" then
    error("mdd-motion-brief: LR 105.4: the table of contents is not built for the docx engine (BLOCKED); a memorandum over fifteen pages needs one")
  end
  local out = {}
  -- Cover: court lines (single spaced, centered), 27.6 pt gap, the short caption, 27.6 pt gap, the title, 13.8 pt gap.
  local court = m.court
  for k, c in ipairs(court) do
    local last = (k == #court)
    table.insert(out, raw(para({ style = "CourtLine", spacing = last and 'w:before="0" w:after="552"' or nil }, inl(c))))
  end
  table.insert(out, raw(caption_xml(m)))
  table.insert(out, raw(para({ style = "CoverTitle" }, '<w:r><w:rPr><w:b/><w:caps/></w:rPr><w:t xml:space="preserve">' .. esc(txt(m.brief_title)) .. '</w:t></w:r>')))

  -- Body: paragraphs as pandoc styles them (Body Text, First Paragraph); lists numbered 1., 2., ... with a hanging indent.
  for _, b in ipairs(doc.blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      local start = (b.t == "OrderedList" and b.listAttributes) and b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local label = (b.t == "OrderedList") and lettered_label_numbers(start + i - 1) or "\u{2022}"
        local inlines = { pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        local first = item[1]
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

  -- Signature block, then the certificate of service (optional): kept together with the block.
  local cert = m.certificate
  local sig = signature_xml(m, false)
  if cert then
    local certxml = para({ style = "Heading1", spacing = 'w:before="395" w:after="0"' }, runs({ pandoc.Str("Certificate of Service") }))
      .. para({ style = "BodyText", keep = true, ind = 'w:firstLine="720"' }, inl(txt(cert.text)))
      .. para({ style = "SignatureLine", keep = true, spacing = 'w:before="552" w:after="0"' }, inl("/s/ _______________________"))
      .. para({ style = "SignatureLine", spacing = 'w:before="0" w:after="0"' }, inl(txt(cert.signer)))
    sig = sig .. certxml
  end
  table.insert(out, raw(sig))
  return pandoc.Pandoc(out)
end

-- A space before a footnote mark is not printed (the typst output sets the mark against the word).
function Inlines(inls)
  local out = {}
  for i, el in ipairs(inls) do
    if not (el.t == "Space" and inls[i + 1] and inls[i + 1].t == "Note") then table.insert(out, el) end
  end
  return out
end
