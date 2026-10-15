-- flsb-adversary-complaint.lua (docx engine): the S.D. Fla. Bankruptcy adversary complaint as Word paragraphs
-- (typst: typst/flsb-adversary-complaint.typ). pandoc writes the body with docx/reference.docx; this filter writes
-- what Word needs formatting for:
--   * the cover (court, division, caption table, title) and the signature block, as paragraphs and a table with
--     explicit spacing and indents;
--   * the allegations, numbered from 1 after the first heading (Civil Rule 10(b), via Rule 7010); the opening
--     paragraph, the WHEREFORE clause and the "Dated" line are not numbered;
--   * lettered and roman items, in the "Lettered" style (left indent, not numbered as paragraphs).
-- The caption and the signature are written from the sample's frontmatter; no case text is in this file.

local stringify = pandoc.utils.stringify

local TEXT_W = 9360              -- 6.5 in in twips
local CAP_L, CAP_GUT, CAP_R = 4896, 288, 4176   -- caption: party column 3.4 in, gutter 0.2 in, case column
local SIG_L, SIG_GUT, SIG_R = 3744, 288, 5328   -- signature: "Dated" column 2.6 in, gutter 0.2 in, firm column
local LABEL = { case = "CASE NO.: ", chapter = "CHAPTER ", adv = "ADV. CASE NO.: ", vs = "vs." }

-- ---------------------------------------------------------------------------
-- XML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- text as runs; a tab in the text is a Word tab
local function runs(text, o)
  local rpr = ""
  if o.b then rpr = rpr .. "<w:b/><w:bCs/>" end
  if o.i then rpr = rpr .. "<w:i/><w:iCs/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  local parts, pos = {}, 1
  while true do
    local s, e = text:find("\t", pos, true)
    if not s then
      parts[#parts + 1] = text:sub(pos)
      break
    end
    parts[#parts + 1] = text:sub(pos, s - 1)
    pos = e + 1
  end
  local out = {}
  for k, seg in ipairs(parts) do
    if k > 1 then out[#out + 1] = "<w:r>" .. rpr .. "<w:tab/></w:r>" end
    if seg ~= "" then
      out[#out + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(seg) .. "</w:t></w:r>"
    end
  end
  return table.concat(out)
end

-- one paragraph. o: jc, b, i, keep, before, after, line, exact, left, right, first (twips)
local function para(text, o)
  o = o or {}
  local ppr = ""
  if o.keep then ppr = ppr .. "<w:keepNext/>" end
  ppr = ppr .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>',
    o.before or 0, o.after or 0, o.line or 240, o.exact and "exact" or "auto")
  if o.left or o.right or o.first then
    ppr = ppr .. string.format('<w:ind w:left="%d" w:right="%d" w:firstLine="%d"/>', o.left or 0, o.right or 0, o.first or 0)
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. runs(text, o) .. "</w:p>"
end

-- an empty paragraph of single-spaced height: the vertical space between parts of the cover and signature
local function gap(twips)
  return string.format('<w:p><w:pPr><w:spacing w:before="0" w:after="%d" w:line="240" w:lineRule="auto"/></w:pPr></w:p>', twips)
end

-- a borderless one-row table; cells[k] is a list of paragraph XML for column k
local function table_row(widths, cells)
  local x = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>',
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>',
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>',
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '</w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do x[#x + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  x[#x + 1] = "</w:tblGrid><w:tr>"
  for k, w in ipairs(widths) do
    local ps = cells[k] or {}
    if #ps == 0 then ps = { gap(0) } end
    x[#x + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. "</w:tc>"
  end
  x[#x + 1] = "</w:tr></w:tbl>"
  return table.concat(x)
end

-- ---------------------------------------------------------------------------
-- Cover: court, division, caption (Form 416 / L.R. 9004-1(e)(2)), title
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  out[#out + 1] = para("UNITED STATES BANKRUPTCY COURT", { jc = "center", b = true, line = 240 })
  out[#out + 1] = para(stringify(meta.district), { jc = "center", b = true, line = 240 })
  out[#out + 1] = gap(480)
  local division = meta.division and (stringify(meta.division):upper() .. " DIVISION") or "___________ DIVISION"
  out[#out + 1] = para(division, { jc = "center", b = true, line = 240 })
  out[#out + 1] = gap(480)

  local left, right = {}, {}
  local function single(list, text) list[#list + 1] = para(text, { line = 240 }) end
  single(left, "In re:")
  for _, n in ipairs(meta.debtor.names) do single(left, stringify(n)) end
  single(left, stringify(meta.debtor.designation))
  left[#left + 1] = gap(240)
  single(left, string.rep("_", 36) .. "/")
  left[#left + 1] = gap(240)
  for k, p in ipairs(meta.parties) do
    if k > 1 then single(left, LABEL.vs) end
    for _, n in ipairs(p.names) do single(left, stringify(n)) end
    single(left, stringify(p.designation))
  end
  left[#left + 1] = gap(240)
  single(left, string.rep("_", 36) .. "/")

  single(right, LABEL.case .. stringify(meta.case_number))
  single(right, LABEL.chapter .. stringify(meta.chapter))
  right[#right + 1] = gap(960)
  single(right, LABEL.adv .. stringify(meta.adv_number))

  out[#out + 1] = table_row({ CAP_L, CAP_GUT, CAP_R }, { left, {}, right })
  out[#out + 1] = gap(480)
  out[#out + 1] = para(stringify(meta.title), { jc = "center", b = true, line = 240 })
  out[#out + 1] = gap(480)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" beside the firm (typst: signature-block)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = {}
  local function single(text) right[#right + 1] = para(text, { line = 240 }) end
  single("Respectfully submitted,")
  right[#right + 1] = gap(240)
  for _, l in ipairs(sig.firm) do single(stringify(l)) end
  right[#right + 1] = gap(240)
  single("By: /s/ " .. stringify(sig.signer))
  single(stringify(sig.signer))
  for _, l in ipairs(sig.lines) do single(stringify(l)) end
  return { gap(480), table_row({ SIG_L, SIG_GUT, SIG_R }, { { para("Dated: " .. stringify(meta.date), { line = 480, exact = true }) }, {}, right }) }
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

-- the marker of item n of a list: (a), (ii), (3)
local function marker(n, style)
  local s = tostring(style):lower()
  local m
  if s:find("roman") then m = roman(n):lower()
  elseif s:find("alpha") then m = string.char(96 + n)
  else m = tostring(n) end
  if s:find("upper") then m = m:upper() end
  return "(" .. m .. ")"
end

-- a lettered list becomes one paragraph per item, with its marker typed in (pandoc reads "(a)" as a list)
local function lettered(el)
  local blocks = {}
  local start = el.listAttributes.start
  for i, item in ipairs(el.content) do
    local m = marker(start + i - 1, el.listAttributes.style)
    for j, b in ipairs(item) do
      if j == 1 and (b.t == "Plain" or b.t == "Para") then
        local inl = { pandoc.Str(m), pandoc.Space() }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        blocks[#blocks + 1] = pandoc.Para(inl)
      else
        blocks[#blocks + 1] = b
      end
    end
  end
  return pandoc.Div(blocks, { ["custom-style"] = "Lettered" })
end

local function raw(list)
  local out = {}
  for _, x in ipairs(list) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = raw(cover(meta))
  local seen, n = false, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      seen = true
      out[#out + 1] = b
    elseif b.t == "Para" then
      local s = stringify(b)
      if seen and not s:find("^WHEREFORE") and not s:find("^Dated") then
        -- the number, then a tab to 0.8 in: the "Numbered" style
        n = n + 1
        table.insert(b.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
        table.insert(b.content, 1, pandoc.Str(tostring(n)))
        out[#out + 1] = pandoc.Div({ b }, { ["custom-style"] = "Numbered" })
      else
        out[#out + 1] = b
      end
    elseif b.t == "OrderedList" then
      out[#out + 1] = lettered(b)
    else
      out[#out + 1] = b
    end
  end
  for _, x in ipairs(raw(signature(meta))) do out[#out + 1] = x end
  -- the title and date are written by the cover and the signature; pandoc must not write them again
  meta.title = nil
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
