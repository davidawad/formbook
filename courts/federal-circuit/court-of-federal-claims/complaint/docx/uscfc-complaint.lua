-- uscfc-complaint.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads as
-- typst/uscfc-complaint.typ does (README "Engines"): the caption (RCFC 10(a), 5.5(h)), the signature block
-- (RCFC 5.5(d)-(f)), the certificate of service (RCFC 5(d)(1)(B)), and the prayer-for-relief lists at their
-- typst indents. Everything printed comes from the sample's frontmatter: no case text lives in this file.
-- Caption and signature are built as OOXML (tables with rules), because pandoc has no caption construct.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Run properties in CT_RPr order: b, i, caps, color, sz, u.
local function rpr(f)
  local x = ""
  if f.b then x = x .. "<w:b/><w:bCs/>" end
  if f.i then x = x .. "<w:i/><w:iCs/>" end
  if f.caps then x = x .. "<w:caps/>" end
  if f.sz then x = x .. '<w:sz w:val="' .. f.sz .. '"/><w:szCs w:val="' .. f.sz .. '"/>' end
  if f.u then x = x .. '<w:u w:val="single"/>' end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function merge(f, more)
  local out = {}
  for k, v in pairs(f) do out[k] = v end
  for k, v in pairs(more) do out[k] = v end
  return out
end

local function run(text, f)
  return "<w:r>" .. rpr(f or {}) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- Paragraph properties in CT_PPr order: pStyle, keepNext, pageBreakBefore, pBdr, spacing, ind, jc.
-- Every caption, cover and signature line is single spaced (exact 13.8 pt, the typst single-line).
local function ppr(o)
  o = o or {}
  local x = ""
  if o.keepNext then x = x .. "<w:keepNext/>" end
  if o.pageBreakBefore then x = x .. "<w:pageBreakBefore/>" end
  if o.bottomRule then x = x .. '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>' end
  x = x .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) ..
    '" w:line="' .. (o.line or 276) .. '" w:lineRule="exact"/>'
  x = x .. '<w:ind w:left="' .. (o.left or 0) .. '" w:firstLine="' .. (o.first or 0) .. '"/>'
  x = x .. '<w:jc w:val="' .. (o.jc or "left") .. '"/>'
  return "<w:pPr>" .. x .. "</w:pPr>"
end

local function para(content, o)
  return "<w:p>" .. ppr(o) .. content .. "</w:p>"
end

-- Inline pandoc content to runs, keeping emphasis (signature lines are italic in the sample).
local function inl(list, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then
      out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then
      out[#out + 1] = inl(el.content, merge(f, { i = true }))
    elseif t == "Strong" then
      out[#out + 1] = inl(el.content, merge(f, { b = true }))
    elseif t == "Quoted" then
      local open, close = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then open, close = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(open, f) .. inl(el.content, f) .. run(close, f)
    elseif t == "Link" or t == "Span" then
      out[#out + 1] = inl(el.content, f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

-- A metadata value as inline content (pandoc parses frontmatter strings as markdown).
local function mi(m)
  if m == nil then return {} end
  if type(m) == "string" then return { pandoc.Str(m) } end
  return m
end

local function plain(m)
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(mi(m))
end

local function flag(m)
  return m == true
end

local function need(meta, key)
  if meta[key] == nil then error("uscfc-complaint.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- ---------------------------------------------------------------------------
-- Caption (RCFC 10(a), 5.5(h) bid protest, 7(a) designation; 5.5(g) judge blank)
-- ---------------------------------------------------------------------------

local function caption(meta)
  local out = {}
  -- typst v(1.5em) (18 pt) between the court name and the table.
  local court_after = flag(meta.bid_protest) and 0 or 360
  out[#out + 1] = para(run(plain(need(meta, "court")), { b = true }), { jc = "center", after = court_after })
  if flag(meta.bid_protest) then
    out[#out + 1] = para(run("BID PROTEST", { b = true }), { jc = "center", after = 360 })
  end
  -- Left cell: the parties, each side's names then its designation. Gap lines are single-line gaps (typst v(single-line)).
  local left = {}
  for i, side in ipairs(need(meta, "caption")) do
    if i > 1 then
      left[#left + 1] = para(run("v.", {}), { jc = "center", before = 276, after = 276 })
    end
    for _, name in ipairs(side.names) do
      left[#left + 1] = para(inl(mi(name)), {})
    end
    left[#left + 1] = para(inl(mi(side.designation)), { left = 2160, before = 276 })
  end
  -- Right cell: the file number (blank for the clerk until given) and the judge line (RCFC 5.5(g)).
  local blank = run(string.rep("\u{00A0}", 14), { u = true })
  local fileno = meta.file_number ~= nil and run(plain(meta.file_number), {}) or blank
  local right = {
    para(run("Case No. ", {}) .. fileno, { left = 0, after = 0 }),
    para(run("Judge ", {}) .. run(string.rep("\u{00A0}", 14), { u = true }), {}),
  }
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders></w:tcPr>' ..
    table.concat(left) .. para("", { after = 138 }) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/><w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar><w:vAlign w:val="bottom"/></w:tcPr>' ..
    table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  out[#out + 1] = tbl
  -- typst v(2em) above the title and v(1em) below it.
  out[#out + 1] = para(run(plain(need(meta, "title")):upper(), { b = true }), { jc = "center", before = 480, after = 240 })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (RCFC 5.5(d)(1)(A), (e), (f); 5(d)(1)(B))
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local left = { para(run("Dated: ", {}) .. inl(mi(need(meta, "date")), {}), { before = 552 }) }
  local right = { para(run("Respectfully submitted,", {}), { before = 552 }),
    para("", { before = 552 }) }
  right[#right + 1] = para(run("/s/ " .. plain(sig.signer), {}), { bottomRule = true, before = 0, after = 0 })
  right[#right + 1] = para(run(plain(sig.signer), {}), {})
  for _, l in ipairs(sig.lines or {}) do
    right[#right + 1] = para(inl(mi(l), {}), {})
  end
  right[#right + 1] = para(run("Telephone: " .. plain(need(sig, "phone")), {}), {})
  right[#right + 1] = para(run("E-mail: " .. plain(need(sig, "email")), {}), {})
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    -- The block never breaks across a page (typst: block(breakable: false)).
    '<w:tblGrid><w:gridCol w:w="6120"/><w:gridCol w:w="3240"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="6120" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="3240" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. '</w:tc>' ..
    '</w:tr></w:tbl>'
end

local function certificate(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = para(run("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", pageBreakBefore = true })
  out[#out + 1] = para(run("I hereby certify that on " .. plain(need(meta, "date")) .. ", I caused a copy of the " ..
    string.lower(plain(need(meta, "title"))) .. " to be served on all parties via the Court\u{2019}s electronic case filing system.", {}),
    { before = 552, first = 720, jc = "both" })
  out[#out + 1] = para(run("/s/ " .. plain(sig.signer), {}), { left = 4680, before = 552, bottomRule = true, after = 0 })
  out[#out + 1] = para(run(plain(sig.signer), {}), { left = 4680 })
  return out
end

-- ---------------------------------------------------------------------------
-- Filters
-- ---------------------------------------------------------------------------

-- Prayer-for-relief lists. The sample types its letters and numerals (a., i.) itself, so pandoc reads them as
-- ordered-list markers and their labels would be lost: each item's label is rebuilt from the list's start number
-- and style, and every item becomes a paragraph at its typst indent (0.58 in, then 1.17 in when nested).
local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function label(lst, idx)
  local a = lst.listAttributes
  local n = a.start + idx - 1
  if a.style == "LowerAlpha" then return string.char(96 + n) .. "." end
  if a.style == "UpperAlpha" then return string.char(64 + n) .. "." end
  if a.style == "LowerRoman" then return roman(n) .. "." end
  return tostring(n) .. "."
end

local function items(lst, depth, out)
  local style = depth == 1 and "Prayer Item" or "Prayer Item 2"
  local ordered = lst.t == "OrderedList"
  for idx, item in ipairs(lst.content) do
    for _, b in ipairs(item) do
      if b.t == "Plain" or b.t == "Para" then
        local content = {}
        if ordered then
          content[1] = pandoc.Str(label(lst, idx))
          content[2] = pandoc.Space()
        end
        for _, x in ipairs(b.content) do content[#content + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
      elseif b.t == "BulletList" then
        items(b, depth + 1, out)
      elseif b.t == "OrderedList" then
        items(b, depth, out)
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

function BulletList(el)
  return items(el, 1, {})
end

function OrderedList(el)
  return items(el, 1, {})
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  for _, b in ipairs(caption(meta)) do blocks[#blocks + 1] = pandoc.RawBlock("openxml", b) end
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", signature(meta))
  if flag(meta.certificate_of_service) then
    for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = pandoc.RawBlock("openxml", b) end
  end
  doc.blocks = blocks
  -- pandoc would print title and date above the body; the caption already carries both (typst does not repeat them).
  doc.meta.title = nil
  doc.meta.date = nil
  return doc
end
