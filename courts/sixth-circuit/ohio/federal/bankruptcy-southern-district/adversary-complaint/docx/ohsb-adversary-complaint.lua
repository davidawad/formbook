-- S.D. Ohio adversary complaint (ohsb), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx. Mirrors typst/ohsb-adversary-complaint.typ:
--   * court title (three centered single lines), caption as a borderless table (parties | ")" column | case
--     information), the title of the paper, all from the sample's frontmatter;
--   * body paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b)) with the number, a tab, then the text;
--     the lead-in is unnumbered; headings are the reference's Heading 1/2 (centered); roman relief items keep
--     their numeral; lettered and numbered lists keep their markers;
--   * the signature block from the frontmatter at {{SIGNATURE}} (a borderless table: "Dated:" left, signer right);
--   * the centered "***" rule (pandoc reads a line of three asterisks as a horizontal rule).
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter.

local NUMBER_PARAS = true -- Fed. R. Civ. P. 10(b): the allegations are numbered (the motion template sets this false)

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return (s:gsub('"', "&quot;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or a single value) as a Lua list of strings
local function strings(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then
    for _, item in ipairs(v) do out[#out + 1] = text(item) end
  else
    out[1] = text(v)
  end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("ohsb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one paragraph as XML. opts: style, keepNext, tabs (twips), line (exact twips), ind (left), first (first line),
-- jc, rpr (run properties XML). Child order follows the schema (pStyle, keepNext, tabs, spacing, ind, jc).
local function p(s, o)
  o = o or {}
  local ppr = ""
  if o.style then ppr = ppr .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if o.tabs then ppr = ppr .. '<w:tabs><w:tab w:val="left" w:pos="' .. o.tabs .. '"/></w:tabs>' end
  if o.line then ppr = ppr .. '<w:spacing w:before="0" w:after="0" w:line="' .. o.line .. '" w:lineRule="exact"/>' end
  if o.ind or o.first then
    ppr = ppr .. '<w:ind w:left="' .. (o.ind or 0) .. '" w:firstLine="' .. (o.first or 0) .. '"/>'
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  local run = ""
  if s ~= "" then
    run = "<w:r>" .. (o.rpr and ("<w:rPr>" .. o.rpr .. "</w:rPr>") or "")
      .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
  end
  return "<w:p>" .. (ppr ~= "" and ("<w:pPr>" .. ppr .. "</w:pPr>") or "") .. run .. "</w:p>"
end

local BOLD = "<w:b/><w:bCs/>"

-- one blank line at the double pitch (a blank line of the typst template: v(body-leading))
local function blank_line()
  return p("", { style = "Single", line = 480 })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- a borderless table: widths in twips; rows[r][c] = the cell's paragraphs as XML
local function table_xml(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. "</w:tblCellMar></w:tblPr><w:tblGrid>" }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for c, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/></w:tcPr>' .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- cover: court title, caption, title of the paper (typst: court-title, caption, cover)
-- widths: 3.4 in | 0.3 in | 2.8 in (the rest), total 6.5 in; the case information is indented 0.15 in
-- ---------------------------------------------------------------------------

local CAP_W = { 4896, 432, 4032 }
local SIG_W = { 3744, 288, 5328 }

local function cover(meta)
  local out = {}
  for _, l in ipairs({ "UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF OHIO", text(need(meta, "division")) }) do
    out[#out + 1] = p(l, { style = "Single", jc = "center", rpr = BOLD })
  end
  out[#out + 1] = blank_line()

  local cap = need(meta, "caption")
  local left = strings(need(cap, "left"))
  local right = strings(need(cap, "right"))
  local rows = {}
  for i = 1, math.max(#left, #right) do
    rows[#rows + 1] = {
      p(left[i] or "", { style = "Single" }),
      p(i <= #left and ")" or "", { style = "Single", jc = "center" }),
      p(right[i] or "", { style = "Single", ind = 216 }),
    }
  end
  out[#out + 1] = table_xml(CAP_W, rows)

  out[#out + 1] = blank_line()
  out[#out + 1] = p(text(need(meta, "brief_title")), { style = "Single", jc = "center", rpr = BOLD })
  out[#out + 1] = blank_line()
  return out
end

-- ---------------------------------------------------------------------------
-- signature block (typst: signature-block): "Dated:" at the left, the closing and the signer's lines at the right
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local right = {}
  local closing = sig.closing and text(sig.closing) or ""
  if closing ~= "" then
    right[#right + 1] = p(closing, { style = "Single" })
    right[#right + 1] = p("", { style = "Single" })
  end
  if sig.firm then
    for _, l in ipairs(strings(sig.firm)) do right[#right + 1] = p(l, { style = "Single" }) end
    right[#right + 1] = p("", { style = "Single" })
  end
  for _, l in ipairs(strings(need(sig, "lines"))) do right[#right + 1] = p(l, { style = "Single" }) end
  local date = meta.date and text(meta.date) or ""
  local left = p(date ~= "" and ("Dated: " .. date) or "", { style = "Single" })
  return blank_line() .. table_xml(SIG_W, { { left, p("", { style = "Single" }), table.concat(right) } })
end

-- ---------------------------------------------------------------------------
-- body
-- ---------------------------------------------------------------------------

local function styled(style, content)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function has_break(content)
  for _, i in ipairs(content) do
    if i.t == "LineBreak" then return true end
  end
  return false
end

local ROMAN = { { 1000, "m" }, { 900, "cm" }, { 500, "d" }, { 400, "cd" }, { 100, "c" }, { 90, "xc" },
  { 50, "l" }, { 40, "xl" }, { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
local function lower_roman(n)
  local s = ""
  for _, r in ipairs(ROMAN) do
    while n >= r[1] do
      s = s .. r[2]
      n = n - r[1]
    end
  end
  return s
end

-- the marker of list item n (from the list's start) in the list's style and delimiter
local function marker(style, delim, n)
  local body
  if style == "Decimal" then
    body = tostring(n)
  elseif style == "LowerRoman" then
    body = lower_roman(n)
  elseif style == "UpperAlpha" then
    body = string.char(64 + n)
  elseif style == "LowerAlpha" then
    body = string.char(96 + n)
  else
    error("ohsb-adversary-complaint: unsupported list style " .. style, 0)
  end
  if delim == "TwoParens" then return "(" .. body .. ")" end
  if delim == "OneParen" then return body .. ")" end
  return body .. "."
end

-- a list becomes one paragraph per item: the marker, a tab (or a space for a lettered quotation), the text.
-- Decimal items hang (Enum), roman items are indented (Relief), lettered items are block quotations (Quotation).
local function list_blocks(b)
  local la = b.listAttributes
  local start, style, delim = la.start, tostring(la.style), tostring(la.delimiter)
  local out = {}
  for i, item in ipairs(b.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("ohsb-adversary-complaint: a list item must hold one paragraph", 0)
    end
    local m = marker(style, delim, start + i - 1)
    local c = { pandoc.Str(m) }
    if style == "UpperAlpha" or style == "LowerAlpha" then
      c[#c + 1] = pandoc.Str(" ")
    else
      c[#c + 1] = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
    end
    for _, x in ipairs(item[1].content) do c[#c + 1] = x end
    local custom = (style == "Decimal") and "Enum" or ((style == "LowerRoman") and "Relief" or "Quotation")
    out[#out + 1] = styled(custom, c)
  end
  return out
end

local function numbered(n, content)
  local c = { pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
  for _, x in ipairs(content) do c[#c + 1] = x end
  return c
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  if meta.lead_in ~= nil then
    out[#out + 1] = pandoc.RawBlock("openxml", p(text(meta.lead_in), { style = "BodyText" }))
  end

  local sig = signature(meta)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local s = pandoc.utils.stringify(b)
      if s == "{{SIGNATURE}}" then
        out[#out + 1] = pandoc.RawBlock("openxml", sig)
      elseif s == "{{NOTICE_21_DAY}}" then
        error("ohsb-adversary-complaint: {{NOTICE_21_DAY}} is not built for docx (the complaint has no notice)", 0)
      elseif has_break(b.content) then
        out[#out + 1] = styled("Single", b.content)
      elseif NUMBER_PARAS then
        n = n + 1
        out[#out + 1] = pandoc.Para(numbered(n, b.content))
      else
        out[#out + 1] = b
      end
    elseif b.t == "OrderedList" then
      for _, d in ipairs(list_blocks(b)) do out[#out + 1] = d end
    elseif b.t == "HorizontalRule" then
      out[#out + 1] = styled("Asterisks", { pandoc.Str("***") })
    else
      out[#out + 1] = b
    end
  end

  -- the cover carries the title and the date; pandoc would otherwise write them again
  meta.title, meta.date, meta.author, meta.subtitle = nil, nil, nil, nil
  return pandoc.Pandoc(out, meta)
end
