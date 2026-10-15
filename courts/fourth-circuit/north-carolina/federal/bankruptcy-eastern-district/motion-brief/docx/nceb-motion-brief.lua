-- nceb-motion-brief.lua (docx engine). Builds what pandoc does not build from the sample's frontmatter, in the form of
-- typst/nceb-motion-brief.typ: the caption (court lines, division, caption table with "In re:", the rule at its right and
-- bottom edges, the title), the signature block ("Dated", "Respectfully submitted,", the "s/" signers, the role line),
-- and the certificate of service on its own page. No case text is written here; every word comes from the sample.
-- See ../README.md "Engines".

local function txt(x) return pandoc.utils.stringify(x) end

local function xesc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function xpara(style, text, after)
  local sp = after and ('<w:spacing w:after="' .. after .. '"/>') or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. sp .. '</w:pPr>' ..
    (text ~= "" and ('<w:r><w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>') or "") .. '</w:p>'
end

-- Caption table: left column 3.4 in (ruled on its right and bottom), right column 3.1 in, indented 0.3 in.
-- Widths in twips: 4896 + 4464 = 9360 (6.5 in text width).
local function caption_table(meta)
  local left = { xpara("NCEBCaptionCell", "In re:", 120) }
  local function party(p)
    for _, n in ipairs(p.names) do table.insert(left, xpara("NCEBCaptionCell", txt(n))) end
    table.insert(left, xpara("NCEBDesignation", txt(p.designation)))
  end
  for _, p in ipairs(meta.caption.in_re) do party(p) end
  for _, p in ipairs(meta.caption.parties) do party(p) end
  local right = { xpara("NCEBCaseNumbers", "Case No. " .. txt(meta.case_number)) }
  table.insert(right, xpara("NCEBCaptionCell", "Chapter " .. txt(meta.chapter)))
  if meta.adversary_number then
    table.insert(right, xpara("NCEBCaptionCell", ""))
    table.insert(right, xpara("NCEBCaptionCell", "Adversary Proceeding No. " .. txt(meta.adversary_number)))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/><w:tcBorders>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/><w:tcMar><w:left w:w="432" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- A numbered list inside a block quotation: each item becomes a labelled paragraph inside the quotation's indent
-- (pandoc's list numbering would start at the margin, outside the quotation).
local function quote_list(l)
  local out = {}
  local start = l.listAttributes.start
  for i, item in ipairs(l.content) do
    local label = (start + i - 1) .. ".\t"
    local inl = pandoc.List({ pandoc.Str(label) })
    local first = item[1]
    local from = 1
    if first and (first.t == "Plain" or first.t == "Para") then
      for _, x in ipairs(first.content) do inl:insert(x) end
      from = 2
    end
    table.insert(out, pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "NCEB Quote Item" }))
    for k = from, #item do table.insert(out, item[k]) end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({
    BlockQuote = function(bq)
      local content = {}
      for _, b in ipairs(bq.content) do
        if b.t == "OrderedList" then
          for _, x in ipairs(quote_list(b)) do table.insert(content, x) end
        else
          table.insert(content, b)
        end
      end
      bq.content = content
      return bq
    end,
  })
  local blocks = {}
  for _, line in ipairs(meta.court) do
    table.insert(blocks, styled("NCEB Court", { pandoc.Str(txt(line):upper()) }))
  end
  table.insert(blocks, styled("NCEB Division", { pandoc.Str(txt(meta.division):upper()) }))
  table.insert(blocks, pandoc.RawBlock("openxml", caption_table(meta)))
  table.insert(blocks, styled("NCEB Title", { pandoc.Str(txt(meta.title):upper()) }))
  for _, b in ipairs(doc.blocks) do table.insert(blocks, b) end
  -- signature block (LBR 9011-4; Admin Guide 5005-4(8))
  local sig = meta.signature
  if sig then
    if sig.date then table.insert(blocks, styled("NCEB Lead In", { pandoc.Str("Dated: " .. txt(sig.date)) })) end
    table.insert(blocks, styled("NCEB Signature Last", { pandoc.Str("Respectfully submitted,") }))
    for _, s in ipairs(sig.signers) do
      table.insert(blocks, styled("NCEB Signature", { pandoc.Str(txt(s.sign)) }))
      local lines = s.lines
      for i, l in ipairs(lines) do
        local style = (i == #lines) and "NCEB Signature Last" or "NCEB Signature"
        table.insert(blocks, styled(style, { pandoc.Str(txt(l)) }))
      end
    end
    if sig.role then table.insert(blocks, styled("NCEB Role", { pandoc.Emph({ pandoc.Str(txt(sig.role)) }) })) end
  end
  -- certificate of service (LBR 9013-3): its own page
  local c = meta.certificate
  if c then
    table.insert(blocks, styled("NCEB Certificate Title", { pandoc.Str(txt(c.title):upper()) }))
    local text = pandoc.utils.blocks_to_inlines(pandoc.read(txt(c.text), "markdown").blocks)
    table.insert(blocks, pandoc.Para(text))
    for i, l in ipairs(c.served) do
      local style = "NCEB Served"
      if i == 1 then style = "NCEB Served First" end
      if i == #c.served then style = "NCEB Served Last" end
      table.insert(blocks, styled(style, { pandoc.Str(txt(l)) }))
    end
    table.insert(blocks, styled("NCEB Signature", { pandoc.Str("Dated: " .. txt(c.date)) }))
    table.insert(blocks, styled("NCEB Signature", { pandoc.Str(txt(c.signer.sign)) }))
    for i, l in ipairs(c.signer.lines) do
      local style = (i == #c.signer.lines) and "NCEB Signature Last" or "NCEB Signature"
      table.insert(blocks, styled(style, { pandoc.Str(txt(l)) }))
    end
  end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
