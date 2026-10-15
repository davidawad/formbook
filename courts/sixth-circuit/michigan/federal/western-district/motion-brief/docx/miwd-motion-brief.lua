-- W.D. Mich. motion brief (miwd), DOCX engine (docs/DOCX.md): the markdown contract -> a Word body on reference.docx.
-- Mirrors typst/miwd-motion-brief.typ:
--   * cover (section 1, no page number): court title, caption (party column closed by a rule; case number, judge,
--     ORAL ARGUMENT REQUESTED at right), the title of the brief centered below;
--   * contents (section 2, lower roman): "TABLE OF CONTENTS", a TOC field over Heading 1 and 2 (dirty: updated on open);
--   * brief (section 3, arabic from 1): headings numbered by the filter (I., A., 1., a.), body double spaced,
--     block quotations, footnotes (pandoc), signature block at the end.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter.

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
  if pandoc.utils.type(v) == "List" then
    for _, item in ipairs(v) do out[#out + 1] = text(item) end
  else
    out[1] = text(v)
  end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("miwd-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one paragraph. opts: style, ind (left twips), first (first-line twips), jc, keepNext, pageBreak, rpr, line (exact
-- twips), before, after
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.keepLines then ppr = ppr .. "<w:keepLines/>" end
  if opts.line then
    ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0)
      .. '" w:line="' .. opts.line .. '" w:lineRule="exact"/>'
  elseif opts.before or opts.after then
    ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) .. '"/>'
  end
  if opts.ind or opts.first or opts.right then
    ppr = ppr .. '<w:ind w:left="' .. (opts.ind or 0) .. '"' .. (opts.right and (' w:right="' .. opts.right .. '"') or '')
      .. ' w:firstLine="' .. (opts.first or 0) .. '"/>'
  end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local run = ""
  if s ~= nil and s ~= "" then
    run = '<w:r>' .. (opts.rpr and ('<w:rPr>' .. opts.rpr .. '</w:rPr>') or '')
      .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
  end
  return '<w:p>' .. (ppr ~= "" and ('<w:pPr>' .. ppr .. '</w:pPr>') or '') .. run .. '</w:p>'
end

local BOLD = "<w:b/><w:bCs/>"
local SINGLE = 276   -- exact single line (13.8 pt), as the typst single-leading
local DOUBLE = 480   -- exact double line (24 pt pitch)

local function blank(line)
  return p("", { style = "Single", line = line or SINGLE })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- a borderless fixed-width table; widths in twips; rows[r][c] = cell XML; borders[c] = tcBorders XML (optional)
local function table_xml(widths, rows, borders)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for c, cell in ipairs(row) do
      local tcb = (borders and borders[c]) or ""
      local tcmar = (borders and borders[c]) and '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>' or ""
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/>' .. tcb .. tcmar .. '</w:tcPr>' .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

local RULE = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function raw(xml) return pandoc.RawBlock("openxml", xml) end
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- section properties: footer rId100 = PAGE field, rId101 = empty; pgNum = "lowerRoman" or "decimal" (restarts at 1)
local function sect(footer, pgnum)
  local pn = pgnum and ('<w:pgNumType w:fmt="' .. pgnum .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pn .. '<w:cols w:space="720"/></w:sectPr>'
end
-- a paragraph that ends a section
local function section_end(footer, pgnum)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>' .. sect(footer, pgnum) .. '</w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Cover (Fed. R. Civ. P. 10(a); LCivR 7.2(d))
-- ---------------------------------------------------------------------------
local function cover(meta)
  local out = {}
  out[#out + 1] = p("UNITED STATES DISTRICT COURT", { style = "Centered", rpr = BOLD })
  out[#out + 1] = p("WESTERN DISTRICT OF MICHIGAN", { style = "Centered", rpr = BOLD })
  if meta.division ~= nil and text(meta.division) ~= "" then
    out[#out + 1] = p(string.upper(text(meta.division)), { style = "Centered", rpr = BOLD })
  end
  out[#out + 1] = blank(DOUBLE)

  local cn = text(meta.case_number)
  if cn == "" then cn = "__________________" end
  local hon = text(meta.judge)
  if hon == "" then hon = "__________________" end

  local left = {}
  for k, side in ipairs(need(meta, "caption").parties) do
    if k > 1 then left[#left + 1] = p("v.", { style = "Single" }) end
    for _, n in ipairs(strings(side.names)) do left[#left + 1] = p(n, { style = "Single" }) end
    left[#left + 1] = p(text(side.designation), { style = "Single" })
  end
  local right = {
    p("Case No. " .. cn, { style = "Single", ind = 504 }),
    p("Hon. " .. hon, { style = "Single", ind = 504 }),
  }
  if meta.oral_argument_requested == true then
    right[#right + 1] = blank(SINGLE * 0 + 240)
    right[#right + 1] = p("ORAL ARGUMENT REQUESTED", { style = "Single", ind = 504, rpr = BOLD })
  end
  out[#out + 1] = table_xml({ 4680, 4680 }, { { table.concat(left), table.concat(right) } }, { RULE, nil })
  out[#out + 1] = blank(DOUBLE)
  out[#out + 1] = blank(DOUBLE)
  out[#out + 1] = blank(DOUBLE)
  -- the title of the brief, centered, 80% of the text width (0.65 in each side)
  out[#out + 1] = p(text(need(meta, "title")), { style = "Centered", rpr = BOLD, line = DOUBLE, ind = 936, right = 936 })
  out[#out + 1] = section_end("rId101", nil)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (Fed. R. Civ. P. 11(a); LCivR 10.3)
-- ---------------------------------------------------------------------------
local function signature(meta)
  local sig = need(meta, "signature")
  local left = p("Dated: " .. text(meta.date), { style = "Single", keepNext = true })
  local right = {}
  for _, n in ipairs(strings(sig.firm)) do right[#right + 1] = p(n, { style = "Single", ind = 288, keepNext = true }) end
  right[#right + 1] = blank(240)
  local lines = strings(sig.lines)
  right[#right + 1] = p("/s/ " .. text(sig.signer), { style = "Single", ind = 288, keepNext = #lines > 0 })
  for k, n in ipairs(lines) do
    right[#right + 1] = p(n, { style = "Single", ind = 288, keepNext = k < #lines })
  end
  return { raw(table_xml({ 3744, 5616 }, { { left, table.concat(right) } })) }
end

-- ---------------------------------------------------------------------------
-- Headings: numbers from the template (I., A., 1., a.), never from the sample
-- ---------------------------------------------------------------------------
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
local counters = { 0, 0, 0, 0 }
local function heading_label(level)
  counters[level] = counters[level] + 1
  for k = level + 1, 4 do counters[k] = 0 end
  local n = counters[level]
  if level == 1 then return ROMAN[n] .. "." end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return tostring(n) .. "." end
  return string.char(96 + n) .. "."
end

-- ---------------------------------------------------------------------------
-- Contents: a TOC field over the numbered headings; the entries are cached (no page numbers until the field
-- is updated: see render notes in README.md)
-- ---------------------------------------------------------------------------
local function contents(entries)
  local out = {}
  out[#out + 1] = p("TABLE OF CONTENTS", { style = "Centered", rpr = BOLD })
  out[#out + 1] = blank(DOUBLE)
  out[#out + 1] = p("Page", { style = "Single", jc = "right" })
  out[#out + 1] = blank(240)
  local n = #entries
  for k, e in ipairs(entries) do
    local begin = ""
    if k == 1 then
      begin = '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>'
        .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\z \\u </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="TOC' .. e.level .. '"/></w:pPr>' .. begin
      .. '<w:r><w:t xml:space="preserve">' .. esc(e.label) .. '</w:t></w:r><w:r><w:tab/></w:r>'
      .. '<w:r><w:t xml:space="preserve">' .. esc(e.text) .. '</w:t></w:r></w:p>'
  end
  out[#out + 1] = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  out[#out + 1] = section_end("rId100", "lowerRoman")
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------
function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  local entries = {}

  -- number the headings first, so the contents can list them
  local numbered = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 4 then
      local label = heading_label(b.level)
      local inl = { pandoc.Str(label), TAB }
      for _, i in ipairs(b.content) do inl[#inl + 1] = i end
      if b.level <= 2 then
        entries[#entries + 1] = { level = b.level, label = label, text = text(pandoc.Plain(b.content)) }
      end
      numbered[#numbered + 1] = pandoc.Header(b.level, inl, b.attr)
    else
      numbered[#numbered + 1] = b
    end
  end

  for _, x in ipairs(cover(meta)) do blocks[#blocks + 1] = raw(x) end
  for _, x in ipairs(contents(entries)) do blocks[#blocks + 1] = raw(x) end
  for _, b in ipairs(numbered) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
