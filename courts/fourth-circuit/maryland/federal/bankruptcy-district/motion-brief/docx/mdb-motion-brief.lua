-- mdb-motion-brief.lua (docx engine). Adds to pandoc's conversion what the typst template
-- (typst/mdb-motion-brief.typ) does and Word needs a filter for; see make-reference.sh for the styles.
--   * the cover: court lines, division, the caption (a borderless table: party lines, a ")" column, and the case
--     number, chapter and adversary number vertically centred on the right), the rules and the title in capitals;
--   * the lead-in paragraph (indented);
--   * level-1 headings in capitals (the style underlines them);
--   * the signature block after the last section, kept together with that section's last paragraph;
--   * the Certificate of Service on a new page, after the signature.
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
  if S(meta.chapter) ~= "" then
    right[#right + 1] = para("", { line = 280 })
    right[#right + 1] = para("Chapter " .. S(meta.chapter), { line = 280 })
  end
  if S(meta.adv_number) ~= "" then
    right[#right + 1] = para("", { line = 280 })
    right[#right + 1] = para("Adv. Pro. No. " .. S(meta.adv_number), { line = 280 })
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

-- Signature block: the date, then "Respectfully submitted:" and the firm, signer and address at the right half
-- (3 in indent). Kept together, as the typst signature block is unbreakable.
local function signature(meta)
  local lines = {}
  lines[#lines + 1] = { text = S(meta.date), o = { line = 280, before = 480, keepNext = true } }
  lines[#lines + 1] = { text = "Respectfully submitted:", o = { line = 280, left = 4320, before = 240, keepNext = true } }
  for k, f in ipairs(meta.signature.firm) do
    lines[#lines + 1] = { text = S(f), o = { line = 280, left = 4320, before = k == 1 and 240 or 0, keepNext = true } }
  end
  lines[#lines + 1] = { text = S(meta.signature.signer), o = { line = 280, left = 4320, before = 240, keepNext = true } }
  local sig = meta.signature.lines
  for k, l in ipairs(sig) do
    local o = { line = 280, left = 4320, keepNext = k < #sig }
    lines[#lines + 1] = { text = S(l), o = o }
  end
  local out = {}
  for _, l in ipairs(lines) do out[#out + 1] = raw(para(l.text, l.o)) end
  return out
end

local function upper_inlines(inls)
  return inls:walk({ Str = function(s) return pandoc.Str(string.upper(s.text)) end })
end

-- A list written inside a block quotation is set as text with its typed label (see the complaint filter).
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

  -- Split the body at the Certificate of Service (it follows the signature and starts a new page).
  local body, cert = {}, {}
  local target = body
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and S(b):match("^Certificate of Service") then target = cert end
    target[#target + 1] = b
  end

  local function add_body(list, into)
    for _, b in ipairs(list) do
      if b.t == "Header" then
        if b.level == 1 then
          into[#into + 1] = pandoc.Header(1, upper_inlines(b.content))
        elseif b.level == 2 or b.level == 3 then
          into[#into + 1] = pandoc.Header(b.level, b.content)
        else
          error("mdb-motion-brief.lua: headings deeper than level 3 are not in the form")
        end
      elseif b.t == "BlockQuote" then
        into[#into + 1] = quote_lists_as_text(b)
      else
        into[#into + 1] = b
      end
    end
  end

  add_body(body, blocks)

  -- The last section's last paragraph stays with the signature (the typst "tail"): keep-with-next on it.
  for i = #blocks, 1, -1 do
    if blocks[i].t == "Para" then
      blocks[i] = pandoc.Div({ blocks[i] }, pandoc.Attr("", {}, { ["custom-style"] = "KeepNextBody" }))
      break
    end
  end

  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end

  if #cert > 0 then
    local head = cert[1]
    blocks[#blocks + 1] = pandoc.Div(
      { pandoc.Para(upper_inlines(head.content)) },
      pandoc.Attr("", {}, { ["custom-style"] = "CertificateHeading" }))
    local rest = {}
    for i = 2, #cert do rest[#rest + 1] = cert[i] end
    add_body(rest, blocks)
  end

  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = blocks
  return doc
end
