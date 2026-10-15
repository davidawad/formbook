-- W.D. Ky. adversary complaint (kywb), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx. Mirrors typst/kywb-adversary-complaint.typ:
--   * the caption (court, debtor block, adversary block, title) as single-spaced paragraphs and two borderless
--     tables, with the adversary block's rule (right and bottom border of the party cell) as cell borders;
--   * allegations numbered here, one per top-level paragraph; a paragraph whose text starts with "~" is not numbered;
--   * the relief list lettered A., B., C. (UpperAlpha) by the list attributes;
--   * the signature block at 3 in from the left margin, then each exhibit on its own page as a bordered table.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter.
-- Requirement IDs (KYWB-...) are in ../README.md.

local TEXT_W = 9360 -- 6.5 in of text width, in twips (letter, 1 in margins)

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
  if meta[key] == nil then error("kywb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- ---------------------------------------------------------------------------
-- raw WordprocessingML helpers
-- ---------------------------------------------------------------------------

-- one paragraph; opts: style, ind (left twips), first (first-line twips), jc, before, after, keepNext, rpr (run XML)
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.pageBreakBefore then ppr = ppr .. "<w:pageBreakBefore/>" end
  if opts.keepLines then ppr = ppr .. "<w:keepLines/>" end
  if opts.before or opts.after then
    ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) .. '"/>'
  end
  if opts.ind or opts.first then
    ppr = ppr .. '<w:ind w:left="' .. (opts.ind or 0) .. '" w:firstLine="' .. (opts.first or 0) .. '"/>'
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

local function spacer(twips)
  return p("", { style = "Single", before = twips, after = 0 })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local ALL_BORDERS = '<w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tblBorders>'

-- a table: widths in twips; cells[r][c] = { xml = paragraphs, borders = tcBorders XML or nil }
local function table_xml(widths, rows, tbl_borders, cell_margin, header_row)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. tbl_borders
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="' .. (cell_margin or 0)
    .. '" w:type="dxa"/><w:right w:w="' .. (cell_margin or 0) .. '" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for r, row in ipairs(rows) do
    local trpr = ""
    if header_row and r == 1 then trpr = "<w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>"
    else trpr = "<w:trPr><w:cantSplit/></w:trPr>" end
    out[#out + 1] = "<w:tr>" .. trpr
    for c, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/>'
        .. (cell.borders or "") .. '</w:tcPr>' .. cell.xml .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the caption (Fed. R. Bankr. P. 9004(b), 7010: Form 416 layout)
-- ---------------------------------------------------------------------------

local function caption(meta)
  local c = need(meta, "caption")
  local out = {}
  for _, l in ipairs(strings(need(meta, "court"))) do
    out[#out + 1] = p(l:upper(), { style = "Centered", rpr = BOLD })
  end
  out[#out + 1] = spacer(480)

  -- debtor block: names on the left, the bankruptcy identifiers on the right
  local left, right = {}, {}
  local names = strings(c.debtor_names)
  for i, n in ipairs(names) do
    left[#left + 1] = p(n, { style = "Single", ind = (i == 1) and 0 or 720 })
  end
  left[#left + 1] = spacer(240)
  left[#left + 1] = p(text(c.debtor_designation), { style = "Single", ind = 2592 })
  for _, l in ipairs(strings(c.bankruptcy_lines)) do
    right[#right + 1] = p(l, { style = "Single", ind = 312 })
  end
  out[#out + 1] = table_xml({ 5040, 4320 }, {
    { { xml = table.concat(left) }, { xml = table.concat(right) } },
  }, NO_BORDERS, 0)

  -- adversary block: the parties on the left, cell-bordered on the right and bottom (the rule), the number on the right
  local pl, pr = {}, {}
  local parties = need(c, "parties")
  for i, side in ipairs(parties) do
    for _, n in ipairs(strings(side.names)) do pl[#pl + 1] = p(n, { style = "Single" }) end
    pl[#pl + 1] = p(text(side.designation), { style = "Single", ind = 2592 })
    if i < #parties then
      pl[#pl + 1] = spacer(240)
      pl[#pl + 1] = p("v.", { style = "Single", ind = 1296 })
      pl[#pl + 1] = spacer(240)
    end
  end
  local number = text(c.adversary_number)
  if number == "" then number = string.rep("_", 12) end
  pr[#pr + 1] = p("Adv. Proc. No. " .. number, { style = "Single", ind = 312 })
  if c.judge ~= nil then
    pr[#pr + 1] = spacer(240)
    pr[#pr + 1] = p(text(c.judge), { style = "Single", ind = 312 })
  end
  out[#out + 1] = table_xml({ 5040, 4320 }, {
    { { xml = table.concat(pl), borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' },
      { xml = table.concat(pr) } },
  }, NO_BORDERS, 0)

  out[#out + 1] = spacer(480)
  out[#out + 1] = p(text(need(meta, "title")):upper(), { style = "Centered", rpr = BOLD })
  out[#out + 1] = spacer(240)
  return out
end

-- ---------------------------------------------------------------------------
-- signature block and exhibits
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local out = { spacer(480) }
  local firm = sig.firm_lines and strings(sig.firm_lines) or { text(sig.firm) }
  for _, l in ipairs(firm) do out[#out + 1] = p(l, { style = "Signature", keepNext = true, keepLines = true, rpr = BOLD }) end
  out[#out + 1] = spacer(240)
  out[#out + 1] = p("/s/ " .. text(sig.signer), { style = "Signature", keepNext = true, keepLines = true })
  for _, l in ipairs(strings(sig.lines)) do out[#out + 1] = p(l, { style = "Signature", keepNext = true, keepLines = true }) end
  return out
end

local function exhibit(ex)
  local out = {}
  out[#out + 1] = p(text(ex.title):upper(), { style = "Centered", pageBreakBefore = true, rpr = BOLD .. '<w:u w:val="single"/>' })
  out[#out + 1] = spacer(480)
  local widths, right, rows = {}, {}, {}
  local total_w = 0
  for i, w in ipairs(strings(ex.widths)) do
    widths[i] = math.floor(tonumber(w) * TEXT_W / 6.5 + 0.5)
  end
  local sum = 0
  for _, w in ipairs(widths) do sum = sum + w end
  widths[#widths] = widths[#widths] + (TEXT_W - sum)
  for _, r in ipairs(strings(ex.right)) do right[tonumber(r) + 1] = true end
  local function row_cells(vals, bold)
    local cells = {}
    for c = 1, #widths do
      local v = vals[c] or ""
      cells[c] = { xml = p(v, { style = "Single", jc = right[c] and "right" or "left", rpr = bold and BOLD or nil }) }
    end
    return cells
  end
  local header = strings(ex.header)
  rows[#rows + 1] = row_cells(header, true)
  for _, r in ipairs(ex.rows or {}) do rows[#rows + 1] = row_cells(strings(r), false) end
  local total = strings(ex.total)
  if #total > 0 then rows[#rows + 1] = row_cells(total, true) end
  out[#out + 1] = table_xml(widths, rows, ALL_BORDERS, 100, true)
  return out
end

-- ---------------------------------------------------------------------------
-- the body: numbered allegations, the lettered relief list
-- ---------------------------------------------------------------------------

local function starts_with_tilde(para)
  local first, second = para.content[1], para.content[2]
  return first and first.t == "Str" and first.text == "~" and second and second.t == "Space"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
    for _, x in ipairs(caption(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  meta.title = nil

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      if starts_with_tilde(b) then
        table.remove(b.content, 1)
        table.remove(b.content, 1)
      else
        n = n + 1
        table.insert(b.content, 1, pandoc.Space())
        table.insert(b.content, 1, pandoc.Str(tostring(n) .. "."))
      end
    elseif b.t == "OrderedList" then
      b.listAttributes = pandoc.ListAttributes(1, "UpperAlpha", "Period")
    end
    out[#out + 1] = b
  end

  for _, x in ipairs(signature(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  for _, ex in ipairs(meta.exhibits or {}) do
    for _, x in ipairs(exhibit(ex)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  end
  return pandoc.Pandoc(out, meta)
end
