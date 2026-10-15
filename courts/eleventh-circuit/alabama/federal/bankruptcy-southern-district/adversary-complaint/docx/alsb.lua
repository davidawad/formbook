-- alsb adversary complaint, DOCX engine. Run by tools/render-docx.sh as a pandoc --lua-filter with reference.docx.
-- Reads the same YAML frontmatter as typst/alsb-adversary-complaint.typ and lays out the caption, the stipulation line
-- and the signature block as WordprocessingML (raw openxml; pandoc cannot express a caption box or a borderless
-- signature grid). Layout values mirror the typst template: twips (1 pt = 20), 13 pt body, 26 pt body lines, 1 in margins.
-- Numbered paragraphs use the "Numbered Paragraph" style, whose numbering (reference.docx numId 1) runs continuously
-- through the document. Requirement IDs and rule text: ../README.md. No case-specific text lives here.

-- ---------------------------------------------------------------------------
-- WordprocessingML helpers
-- ---------------------------------------------------------------------------

local function xesc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- Run properties in schema order (b, i, caps, sz, szCs, vertAlign).
local function rpr(f)
  local s = ""
  if f.b then s = s .. "<w:b/>" end
  if f.i then s = s .. "<w:i/>" end
  if f.caps then s = s .. "<w:caps/>" end
  if f.sz then s = s .. '<w:sz w:val="' .. f.sz .. '"/><w:szCs w:val="' .. f.sz .. '"/>' end
  if s == "" then return "" end
  return "<w:rPr>" .. s .. "</w:rPr>"
end

local function run(text, f)
  return "<w:r>" .. rpr(f or {}) .. '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

-- Inline content from the YAML (already parsed as markdown by pandoc) as runs. Emphasis is kept; anything else is text.
local function runs(inlines, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(inlines) do
    if el.t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif el.t == "Space" or el.t == "SoftBreak" then
      out[#out + 1] = run(" ", f)
    elseif el.t == "Emph" then
      out[#out + 1] = runs(el.content, { b = f.b, i = true, caps = f.caps, sz = f.sz })
    elseif el.t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = f.i, caps = f.caps, sz = f.sz })
    elseif el.t == "LineBreak" then
      out[#out + 1] = "<w:r><w:br/></w:r>"
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

-- Paragraph properties in schema order (pStyle, keepNext, spacing, ind, jc). Values are twips.
local function ppr(o)
  local s = ""
  if o.style then s = s .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keepNext then s = s .. "<w:keepNext/>" end
  if o.before or o.after then
    s = s .. "<w:spacing"
    if o.before then s = s .. ' w:before="' .. o.before .. '"' end
    if o.after then s = s .. ' w:after="' .. o.after .. '"' end
    s = s .. "/>"
  end
  if o.left then s = s .. '<w:ind w:left="' .. o.left .. '"/>' end
  if o.jc then s = s .. '<w:jc w:val="' .. o.jc .. '"/>' end
  if s == "" then return "" end
  return "<w:pPr>" .. s .. "</w:pPr>"
end

local function para(o, inner)
  return "<w:p>" .. ppr(o) .. (inner or "") .. "</w:p>"
end

-- Borderless fixed-width table. widths in twips; cells is a list of {width=, borderRight=bool, margins=xml, content=xml}.
local function table_xml(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local nil_b = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  local out = {
    '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>' .. nil_b .. "</w:tblBorders>"
      .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
      .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. "</w:tblGrid>",
  }
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for _, c in ipairs(row) do
      local borders = ""
      if c.borderRight then
        borders = '<w:tcBorders><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders>'
      end
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.width .. '" w:type="dxa"/>' .. borders .. (c.margins or "")
        .. "</w:tcPr>" .. c.content .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Frontmatter pieces
-- ---------------------------------------------------------------------------

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("alsb.lua: missing required metadata field `" .. key .. "`") end
  return v
end

-- Party group in the caption's left column: names, then the designation (Debtor., Plaintiff,, Defendant.).
local function party_xml(p)
  local out = {}
  for _, n in ipairs(p.names) do
    out[#out + 1] = para({ style = "SignatureBlock" }, runs(n))
  end
  out[#out + 1] = para({ style = "SignatureBlock", before = 52, after = 182 }, runs(p.designation))
  return table.concat(out)
end

local function caption_xml(meta)
  local cap = need(meta, "caption")
  local out = {}
  for _, l in ipairs(need(meta, "court")) do
    out[#out + 1] = para({ style = "SignatureBlock", after = 40, jc = "center" }, runs(l, { b = true, caps = true }))
  end
  -- v(1.6em) above the caption box
  local left = party_xml(cap.debtor) .. party_xml(cap.plaintiff)
    .. para({ style = "SignatureBlock", before = 52, after = 52 }, run("v."))
    .. party_xml(cap.defendant)
  local right = {}
  right[#right + 1] = para({ style = "SignatureBlock", left = 432, after = 156 }, run("Case No. " .. pandoc.utils.stringify(need(meta, "case_number"))))
  right[#right + 1] = para({ style = "SignatureBlock", left = 432, after = 156 }, run("Chapter " .. pandoc.utils.stringify(need(meta, "chapter"))))
  right[#right + 1] = para({ style = "SignatureBlock", left = 432, after = 156 }, run("Adv. Pro. No. " .. pandoc.utils.stringify(need(meta, "adversary_number"))))
  out[#out + 1] = table_xml({ 4896, 4464 }, {
    {
      {
        width = 4896,
        borderRight = true,
        margins = '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="288" w:type="dxa"/></w:tcMar>',
        content = left,
      },
      {
        width = 4464,
        margins = '<w:tcMar><w:top w:w="78" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>',
        content = table.concat(right),
      },
    },
  })
  -- Title, centered bold caps, v(1.4em) above and below (typst: caption(meta))
  out[#out + 1] = para({ style = "SignatureBlock", before = 364, after = 364, jc = "center" },
    runs(need(meta, "title"), { b = true, caps = true }))
  return table.concat(out)
end

-- LBR 7026-1 statement, a body paragraph after the last numbered paragraph (typst: block(...stipulation-26-1)).
local function stipulation_xml(meta)
  return para({ style = "BodyText", before = 260 }, runs(need(meta, "stipulation-26-1")))
end

-- Signature block: "Dated" on the left, counsel on the right (typst: signature-block, grid 1fr | 3.0in).
local function signature_xml(meta)
  local sig = need(meta, "signature")
  local dated = meta.date and pandoc.utils.stringify(meta.date) or "__________, 20__"
  local right = {}
  right[#right + 1] = para({ style = "SignatureBlock", before = 312 }, run("Respectfully submitted,"))
  right[#right + 1] = para({ style = "SignatureBlock", before = 312 }, run("/s/ " .. pandoc.utils.stringify(sig.signer)))
  for _, l in ipairs(sig.lines) do
    right[#right + 1] = para({ style = "SignatureBlock" }, runs(l, { sz = 24 }))
  end
  return table_xml({ 5040, 4320 }, {
    {
      {
        width = 5040,
        content = para({ style = "SignatureBlock", before = 312 }, run("Dated: " .. dated)),
      },
      {
        width = 4320,
        content = table.concat(right),
      },
    },
  })
end

-- ---------------------------------------------------------------------------
-- Body: numbered paragraphs and the "(1)" prayer items
-- ---------------------------------------------------------------------------

local function ordered(el)
  local blocks = pandoc.List()
  local start = el.listAttributes.start
  local delim = tostring(el.listAttributes.delimiter)
  for i, item in ipairs(el.content) do
    local bs = pandoc.List()
    for _, b in ipairs(item) do
      if b.t == "Plain" then b = pandoc.Para(b.content) end
      bs:insert(b)
    end
    if delim:find("Paren") and bs[1] and bs[1].t == "Para" then
      -- Labelled sub-items ("(1)", "(2)"; pandoc delimiter TwoParens) are literal text, as in the typst render.
      table.insert(bs[1].content, 1, pandoc.Space())
      table.insert(bs[1].content, 1, pandoc.Str("(" .. (start + i - 1) .. ")"))
      for _, b in ipairs(bs) do blocks:insert(b) end
    else
      -- Each numbered paragraph takes the style; the numbering runs through the whole document.
      if bs[1] then blocks:insert(pandoc.Div({ bs[1] }, { ["custom-style"] = "Numbered Paragraph" })) end
      for j = 2, #bs do blocks:insert(bs[j]) end
    end
  end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Entry point
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local body = doc.blocks:walk({ OrderedList = ordered })

  local out = pandoc.List()
  out:insert(pandoc.RawBlock("openxml", caption_xml(m)))
  out:extend(body)
  out:insert(pandoc.RawBlock("openxml", stipulation_xml(m)))
  out:insert(pandoc.RawBlock("openxml", signature_xml(m)))
  local cert = m["certificate-of-service"]
  if cert then
    for _, b in ipairs(cert) do out:insert(b) end
  end

  -- The frontmatter title and date would print as a pandoc title block; the caption above carries them instead.
  m.title = nil
  m.date = nil
  m.author = nil
  return pandoc.Pandoc(out, m)
end
