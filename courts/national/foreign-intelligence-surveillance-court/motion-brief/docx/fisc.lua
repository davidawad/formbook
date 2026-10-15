-- Foreign Intelligence Surveillance Court: motion (doc type motion-brief), DOCX engine (docs/DOCX.md).
-- The same contract and layout as typst/fisc-motion-brief.typ: the YAML frontmatter of the sample gives
-- the court heading, caption, title, counsel, signature, clearance statement, verification and
-- certificate of service; the markdown body keeps its structure. Heading numbers (I., A., 1.) are written
-- as text. The styles (Centered, Single, Sig, BodyText, Heading1-3, ...) come from docx/reference.docx,
-- built by build-reference.sh; this filter only chooses them.
-- Known limit (see the README, Engines): the signature block keeps together with keepNext chains, which
-- LibreOffice and Word honor only while the block fits on one page.

local function fail(msg) error("fisc-motion-brief: " .. msg, 0) end

local function md_inlines(s)
  return pandoc.utils.blocks_to_inlines(pandoc.read(s, "markdown").blocks)
end

-- A value such as "(202) 514-9016" is read by pandoc's markdown as an ordered list (the frontmatter is markdown).
-- Its text is restored from the list marker, so the value reads as the YAML string it is.
local function unlist(v)
  if #v ~= 1 or v[1].t ~= "OrderedList" then return nil end
  local ol = v[1]
  if #ol.content ~= 1 then fail("a metadata value reads as a list of several items; quote it in the sample") end
  local a = ol.listAttributes
  local marker
  if a.delimiter == "TwoParens" then marker = "(" .. a.start .. ")"
  elseif a.delimiter == "OneParen" then marker = a.start .. ")"
  else marker = a.start .. "." end
  local inl = pandoc.List({ pandoc.Str(marker), pandoc.Space() })
  inl:extend(ol.content[1][1].content)
  return inl
end

-- A metadata value as inlines. pandoc gives a value as a Lua list of inlines, or of blocks when the markdown
-- makes blocks of it (a list, a paragraph).
local BLOCK = { Para = true, Plain = true, OrderedList = true, BulletList = true, Header = true, BlockQuote = true,
  CodeBlock = true, Div = true, RawBlock = true, Table = true, LineBlock = true, DefinitionList = true }
local function inlines_of(v)
  if v == nil then return nil end
  if type(v) == "string" then return md_inlines(v) end
  if v[1] ~= nil and BLOCK[v[1].t] then
    return unlist(v) or pandoc.utils.blocks_to_inlines(v)
  end
  return pandoc.Inlines(v)
end

local function need(m, key)
  local v = m[key]
  if v == nil then fail("missing required metadata field `" .. key .. "`") end
  return v
end

local function items(v)
  local out = {}
  if v == nil then return out end
  for i, x in ipairs(v) do out[i] = x end
  return out
end

-- pandoc maps custom-style to a style by its name (w:name in reference.docx), not by its styleId
local STYLE_NAME = {
  Centered = "Centered", CenteredPB = "Centered Page Start", Single = "Single", KeepSingle = "Single Keep",
  Sig = "Signature", SigEnd = "Signature End", Recipient = "Recipient", BodyNoIndent = "Body No Indent",
  BodyText = "Body Text",
}
local function para(inl, style)
  local name = STYLE_NAME[style] or style
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- an empty paragraph of an exact height (twips), for the vertical spaces of the typst template
local function gap(twips, style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

-- the WordprocessingML runs of an inline list (caption cells: plain text, emphasis and strong)
local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end
local function runs(inl, it, bd)
  local out = {}
  for _, el in ipairs(inl) do
    local t = el.t
    if t == "Str" then
      local rpr = (bd and "<w:b/>" or "") .. (it and "<w:i/>" or "")
      out[#out + 1] = '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') .. '<w:t xml:space="preserve">' .. esc(el.text) .. '</w:t></w:r>'
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out[#out + 1] = '<w:r><w:t xml:space="preserve"> </w:t></w:r>'
    elseif t == "Emph" then out[#out + 1] = runs(el.content, true, bd)
    elseif t == "Strong" then out[#out + 1] = runs(el.content, it, true)
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = runs(pandoc.List({ pandoc.Str(q[1]) }):extend(el.content):extend({ pandoc.Str(q[2]) }), it, bd)
    else
      out[#out + 1] = runs({ pandoc.Str(pandoc.utils.stringify(el)) }, it, bd)
    end
  end
  return table.concat(out)
end

-- one styled paragraph as WordprocessingML (for the caption cells)
local function para_xml(inl, style)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. runs(inl, false, false) .. '</w:p>'
end

local function upper_inlines(inl)
  local p = pandoc.Para(inl):walk({
    Str = function(s) return pandoc.Str(s.text:upper()) end,
  })
  return p.content
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- a keep-together chain: every paragraph but the last keeps with the next one
local KEEP_END = { KeepSingle = "Single", Sig = "SigEnd" }
local function chain(list)
  local out = {}
  for i, it in ipairs(list) do
    local style = it.style
    if i == #list and KEEP_END[style] then style = KEEP_END[style] end
    if it.gap then out[#out + 1] = gap(it.gap, style)
    else out[#out + 1] = para(it.inl, style) end
  end
  return out
end
local function P(inl, style) return { inl = inl, style = style } end
local function G(h, style) return { gap = h, style = style } end

local function caption_table(caption, docket)
  local cell = {}
  for _, inl in ipairs(caption) do cell[#cell + 1] = para_xml(inl, "Single") end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid><w:tr><w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/>'
    .. '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:top w:w="120" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="190" w:type="dxa"/><w:right w:w="160" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(cell)
    .. '</w:tc><w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/>'
    .. '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/></w:tcBorders>'
    .. '<w:tcMar><w:top w:w="120" w:type="dxa"/><w:left w:w="432" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>'
    .. '<w:vAlign w:val="center"/></w:tcPr>' .. para_xml(docket, "Single")
    .. '</w:tc></w:tr></w:tbl>'
end

function Pandoc(doc)
  local meta = doc.meta
  local filer = pandoc.utils.stringify(need(meta, "filer"))
  if filer ~= "government" and filer ~= "other" then fail("`filer` must be `government` or `other`") end
  local adversarial = meta.adversarial ~= nil and meta.adversarial == true
  if adversarial and meta.counsel == nil then fail("an adversarial submission must carry `counsel` (FISC-FILE-007)") end
  if adversarial and filer == "other" and meta.clearance == nil then
    fail("a non-government party in an adversarial proceeding must state its clearances (FISC-FILE-008)")
  end
  local docket = inlines_of(need(meta, "docket"))
  local title = inlines_of(need(meta, "brief_title"))
  local caption = {}
  for i, c in ipairs(items(need(meta, "caption"))) do caption[i] = inlines_of(c) end
  local signature = need(meta, "signature")

  local out = {}
  local function push(b) out[#out + 1] = b end

  -- court heading (FISC-FORM-005)
  local court_lines
  if filer == "government" then
    court_lines = { "UNITED STATES", "FOREIGN INTELLIGENCE SURVEILLANCE COURT", "WASHINGTON, D.C." }
  else
    court_lines = { "IN THE FOREIGN INTELLIGENCE SURVEILLANCE COURT" }
  end
  for _, l in ipairs(court_lines) do push(para({ pandoc.Str(l) }, "Centered")) end
  push(gap(360, "Single"))

  -- caption box and docket (FISC-FORM-007)
  push(pandoc.RawBlock("openxml", caption_table(caption, docket)))
  push(gap(360, "Single"))

  -- title (FISC-FORM-008)
  push(para({ pandoc.Strong(upper_inlines(title)) }, "Centered"))
  push(gap(144, "Single"))

  -- body: heading numbers as text, no indent for the paragraph after a heading
  local counters = { 0, 0, 0 }
  local after_heading = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level > 3 then fail("headings deeper than level 3 are not supported") end
      counters[b.level] = counters[b.level] + 1
      for j = b.level + 1, 3 do counters[j] = 0 end
      local label
      if b.level == 1 then label = roman(counters[1]) .. "."
      elseif b.level == 2 then label = string.char(64 + counters[2]) .. "."
      else label = counters[3] .. "." end
      local content = pandoc.List({ pandoc.Str(label), pandoc.Space() })
      content:extend(b.content)
      b.content = content
      push(b)
      after_heading = true
    elseif b.t == "Para" and after_heading then
      push(para(b.content, "BodyNoIndent"))
      after_heading = false
    else
      push(b)
      after_heading = false
    end
  end

  -- signature block, with the Dated line and the counsel block (FISC-FILE-007), kept together
  local list = {}
  push(gap(288, "Single"))
  if meta.dated ~= nil then
    local dated = pandoc.List({ pandoc.Str("Dated:"), pandoc.Space() })
    dated:extend(inlines_of(meta.dated))
    list[#list + 1] = P(dated, "KeepSingle")
    list[#list + 1] = G(240, "KeepSingle")
  end
  list[#list + 1] = P({ pandoc.Str("Respectfully submitted,") }, "Sig")
  list[#list + 1] = G(576, "KeepSingle")
  for _, l in ipairs(items(need(signature, "lines"))) do list[#list + 1] = P(inlines_of(l), "Sig") end
  if meta.counsel ~= nil then
    list[#list + 1] = G(288, "KeepSingle")
    for _, g in ipairs(items(meta.counsel)) do
      for _, l in ipairs(items(need(g, "names"))) do list[#list + 1] = P(inlines_of(l), "KeepSingle") end
      list[#list + 1] = G(48, "KeepSingle")
      for _, l in ipairs(items(need(g, "lines"))) do list[#list + 1] = P(inlines_of(l), "KeepSingle") end
      list[#list + 1] = G(216, "KeepSingle")
    end
  end
  for _, b in ipairs(chain(list)) do push(b) end

  -- Rule 7(i) clearance statement, for a non-government party in an adversarial proceeding
  if meta.clearance ~= nil then
    push(gap(324, "Single"))
    local cl = pandoc.List({ pandoc.Strong({ pandoc.Str("Security clearances (FISC Rule 7(i))") }), pandoc.Space() })
    cl:extend(inlines_of(meta.clearance))
    push(para(cl, "Single"))
  end

  -- verification, 28 U.S.C. § 1746, on its own page
  if meta.verification ~= nil then
    local ver = meta.verification
    push(para({ pandoc.Strong({ pandoc.Str("VERIFICATION") }) }, "CenteredPB"))
    push(gap(240, "Single"))
    local statement = ver.statement ~= nil and inlines_of(ver.statement) or md_inlines("is true and correct.")
    local sent = pandoc.List({ pandoc.Str("I declare under penalty of perjury that the foregoing") , pandoc.Space() })
    sent:extend(title)
    sent:insert(pandoc.Space())
    sent:extend(statement)
    sent:insert(pandoc.Space())
    sent:extend(md_inlines("Executed pursuant to 28 U.S.C. § 1746 on"))
    sent:insert(pandoc.Space())
    sent:extend(inlines_of(need(ver, "date")))
    sent:insert(pandoc.Str("."))
    push(para(sent, "BodyText"))
    local vlist = { G(576, "KeepSingle") }
    for _, l in ipairs(items(need(ver, "signature"))) do vlist[#vlist + 1] = P(inlines_of(l), "Sig") end
    for _, b in ipairs(chain(vlist)) do push(b) end
  end

  -- certificate of service (FISC-FILE-005, Rule 8(c): time and manner), on its own page
  if meta.service ~= nil then
    local svc = meta.service
    push(para({ pandoc.Strong({ pandoc.Str("CERTIFICATE OF SERVICE") }) }, "CenteredPB"))
    push(gap(240, "Single"))
    local cert = pandoc.List({ pandoc.Str("I hereby certify that on"), pandoc.Space() })
    cert:extend(inlines_of(need(svc, "date")))
    if svc.time ~= nil then
      cert:extend(md_inlines(","))
      cert:insert(pandoc.Space())
      cert:insert(pandoc.Str("at"))
      cert:insert(pandoc.Space())
      cert:extend(inlines_of(svc.time))
    end
    cert:extend(md_inlines(",")); cert:insert(pandoc.Space())
    cert:extend(md_inlines("I served copies of the foregoing motion on:"))
    push(para(cert, "BodyText"))
    push(gap(192, "Single"))
    for _, rec in ipairs(items(need(svc, "recipients"))) do
      for _, l in ipairs(items(need(rec, "lines"))) do push(para(inlines_of(l), "Recipient")) end
      push(gap(216, "Single"))
    end
    local manner = pandoc.List({ pandoc.Str("pursuant to FISC Rule 8 and"), pandoc.Space() })
    manner:extend(inlines_of(need(svc, "manner")))
    manner:insert(pandoc.Str("."))
    push(para(manner, "BodyNoIndent"))
    local slist = { G(576, "KeepSingle") }
    for _, l in ipairs(items(need(svc, "signature"))) do slist[#slist + 1] = P(inlines_of(l), "Sig") end
    for _, b in ipairs(chain(slist)) do push(b) end
  end

  doc.blocks = out
  return doc
end
