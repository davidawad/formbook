-- mdb-adversary-complaint.lua (docx engine). Adds to pandoc's conversion what the typst template
-- (typst/mdb-adversary-complaint.typ) does and Word needs a filter for; see make-reference.sh for the styles.
--   * the cover: court lines, division, the caption (a borderless table: party lines, a ")" column, and the case
--     number, chapter and adversary number vertically centred on the right), the rules and the title in capitals;
--   * the lead-in paragraph (unnumbered);
--   * allegations numbered 1., 2., ... (every plain paragraph; not the WHEREFORE lead-in, quotations or lists);
--   * level-1 headings in capitals (the style underlines them);
--   * the prayer list lettered A., B., ... ;
--   * the signature block, kept together.
-- Content comes only from the sample's frontmatter and body.
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function S(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

-- Raw WordprocessingML paragraphs. Element order follows the schema (rPr: b, i, sz, u; pPr: keepNext, pBdr,
-- spacing, ind, jc).
local function rpr(o)
  local s = ""
  if o.b then s = s .. "<w:b/><w:bCs/>" end
  if o.i then s = s .. "<w:i/><w:iCs/>" end
  if o.sz then s = s .. '<w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/>' end
  if o.u then s = s .. '<w:u w:val="single"/>' end
  if s == "" then return "" end
  return "<w:rPr>" .. s .. "</w:rPr>"
end

local function run(text, o)
  return "<w:r>" .. rpr(o) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function ppr(o)
  local s = ""
  if o.keepNext then s = s .. "<w:keepNext/><w:keepLines/>" end
  if o.bottom then
    s = s .. '<w:pBdr><w:bottom w:val="single" w:sz="' .. o.bottom .. '" w:space="0" w:color="000000"/></w:pBdr>'
  end
  s = s .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="0" w:line="' .. (o.line or 280)
    .. '" w:lineRule="exact"/>'
  if o.left or o.right then
    s = s .. '<w:ind w:left="' .. (o.left or 0) .. '" w:right="' .. (o.right or 0) .. '"/>'
  end
  if o.jc then s = s .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:pPr>" .. s .. "</w:pPr>"
end

local function para(text, o)
  o = o or {}
  local body = ""
  if text ~= "" then body = run(text, o) end
  return "<w:p>" .. ppr(o) .. body .. "</w:p>"
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- Caption: a borderless three-column table, one row per caption line (14 pt exact, as the typst caption-row).
-- Columns: party text 3.6 in, ")" 0.4 in, right column 2.5 in (the case number block, centred vertically).
local function caption_table(meta, right_lines)
  local cap = meta.caption
  local rows = {}
  local function row(text, ind, rule) rows[#rows + 1] = { text = text, ind = ind, rule = rule } end
  if cap.in_re then
    row("In re:")
    for _, n in ipairs(cap.in_re.names) do row(S(n)) end
    row(S(cap.in_re.designation), 720)
    row("", nil, true)
  end
  for k, p in ipairs(cap.parties) do
    if k > 1 then row("v.", 720) end
    for _, n in ipairs(p.names) do row(S(n)) end
    row(S(p.designation), 720)
  end
  local right = table.concat(right_lines)
  local out = {}
  for i, r in ipairs(rows) do
    local rc
    if i == 1 then
      rc = '<w:tc><w:tcPr><w:tcW w:w="3600" w:type="dxa"/><w:vMerge w:val="restart"/>'
        .. '<w:tcMar><w:left w:w="360" w:type="dxa"/></w:tcMar><w:vAlign w:val="center"/></w:tcPr>'
        .. right .. "</w:tc>"
    else
      rc = '<w:tc><w:tcPr><w:tcW w:w="3600" w:type="dxa"/><w:vMerge/></w:tcPr><w:p/></w:tc>'
    end
    out[#out + 1] = '<w:tr><w:trPr><w:trHeight w:val="280" w:hRule="exact"/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="5184" w:type="dxa"/>'
      .. (r.rule and '<w:tcBorders><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders>' or "")
      .. "</w:tcPr>"
      .. para(r.text, { line = 280, left = r.ind }) .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="576" w:type="dxa"/></w:tcPr>' .. para(")", { line = 280 }) .. "</w:tc>"
      .. rc .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5184"/><w:gridCol w:w="576"/><w:gridCol w:w="3600"/></w:tblGrid>'
    .. table.concat(out) .. "</w:tbl>"
end

local function cover(meta)
  local x = {}
  for _, t in ipairs(meta.court) do x[#x + 1] = para(S(t), { jc = "center", b = true, line = 280 }) end
  if S(meta.division) ~= "" then x[#x + 1] = para(S(meta.division), { jc = "center", b = true, line = 280 }) end
  x[#x + 1] = para("", { line = 480 })
  local right = {}
  right[#right + 1] = para("Case No. " .. S(meta.case_number), { line = 280 })
  right[#right + 1] = para("", { line = 280 })
  if S(meta.chapter) ~= "" then right[#right + 1] = para("Chapter " .. S(meta.chapter), { line = 280 }) end
  right[#right + 1] = para("", { line = 280 })
  if S(meta.adv_number) ~= "" then
    right[#right + 1] = para("Adv. Pro. No. " .. S(meta.adv_number), { line = 280 })
  else
    right[#right + 1] = para("Adv. Pro. No. " .. string.rep(" ", 24), { line = 280, u = true })
  end
  x[#x + 1] = caption_table(meta, right)
  x[#x + 1] = para("", { line = 240 })
  x[#x + 1] = para("", { line = 20, bottom = 6 })
  x[#x + 1] = para("", { line = 240 })
  x[#x + 1] = para(string.upper(S(meta.title)), { jc = "center", b = true, line = 480 })
  x[#x + 1] = para("", { line = 240 })
  x[#x + 1] = para("", { line = 20, bottom = 6 })
  x[#x + 1] = para("", { line = 240 })
  local blocks = {}
  for _, s in ipairs(x) do blocks[#blocks + 1] = raw(s) end
  return blocks
end

-- Signature block: date, then "Respectfully submitted," and the firm, signer and address at the right half
-- (3 in indent). Kept together, as the typst signature block is unbreakable.
local function signature(meta)
  local lines = {}
  local function add(text, o)
    o.keepNext = true
    lines[#lines + 1] = { text = text, o = o }
  end
  add("Dated: " .. S(meta.date), { line = 280, before = 480 })
  add("Respectfully submitted,", { line = 280, left = 4320, before = 240 })
  for k, f in ipairs(meta.signature.firm) do
    add(S(f), { line = 280, left = 4320, before = k == 1 and 240 or 0 })
  end
  local lines_sig = meta.signature.lines
  add(S(meta.signature.signer), { line = 280, left = 4320, before = 240 })
  for k, l in ipairs(lines_sig) do
    local o = { line = 280, left = 4320 }
    if k == #lines_sig then o.keepNext = nil end
    lines[#lines + 1] = { text = S(l), o = o }
  end
  local out = {}
  for _, l in ipairs(lines) do out[#out + 1] = raw(para(l.text, l.o)) end
  return out
end

local function upper_inlines(inls)
  return inls:walk({ Str = function(s) return pandoc.Str(string.upper(s.text)) end })
end

local function numbered(content, n)
  local c = { pandoc.Str(n .. "."), TAB }
  for _, x in ipairs(content) do c[#c + 1] = x end
  return pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" }))
end

local function prayer(list, out)
  for i, item in ipairs(list.content) do
    for j, b in ipairs(item) do
      if j == 1 then
        local c = { pandoc.Str(string.char(64 + i) .. "."), TAB }
        for _, x in ipairs(b.content or {}) do c[#c + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "PrayerItem" }))
      else
        out[#out + 1] = b
      end
    end
  end
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- A list written inside a block quotation (the quoted certification's "I.", "II." items) is set as text with
-- its typed label, as the typst template prints it, not as a Word list.
local function list_label(style, i)
  if style == "UpperRoman" then return roman(i) .. "." end
  if style == "LowerRoman" then return string.lower(roman(i)) .. "." end
  if style == "UpperAlpha" then return string.char(64 + i) .. "." end
  if style == "LowerAlpha" then return string.char(96 + i) .. "." end
  return i .. "."
end

local function quote_lists_as_text(bq)
  local out = {}
  for _, b in ipairs(bq.content) do
    if b.t == "OrderedList" then
      local style = tostring(b.listAttributes.style)
      local start = b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local c = { pandoc.Str(list_label(style, start + i - 1)), pandoc.Space() }
        for _, x in ipairs(item[1] and item[1].content or {}) do c[#c + 1] = x end
        out[#out + 1] = pandoc.Para(c)
      end
    else
      out[#out + 1] = b
    end
  end
  return pandoc.BlockQuote(out)
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = cover(meta)
  if S(meta.lead_in) ~= "" then
    local lead = pandoc.read(S(meta.lead_in), "markdown+smart").blocks[1]
    blocks[#blocks + 1] = pandoc.Para(lead.content)
  end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        blocks[#blocks + 1] = pandoc.Header(1, upper_inlines(b.content))
      elseif b.level == 2 or b.level == 3 then
        blocks[#blocks + 1] = pandoc.Header(b.level, b.content)
      else
        error("mdb-adversary-complaint.lua: headings deeper than level 3 are not in the form")
      end
    elseif b.t == "Para" then
      if S(b):match("^WHEREFORE") then
        blocks[#blocks + 1] = pandoc.Para(b.content)
      else
        n = n + 1
        blocks[#blocks + 1] = numbered(b.content, n)
      end
    elseif b.t == "OrderedList" then
      prayer(b, blocks)
    elseif b.t == "BlockQuote" then
      blocks[#blocks + 1] = quote_lists_as_text(b)
    else
      blocks[#blocks + 1] = b
    end
  end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = blocks
  return doc
end
