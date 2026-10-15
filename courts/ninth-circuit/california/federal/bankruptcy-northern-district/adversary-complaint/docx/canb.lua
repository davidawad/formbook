-- Adversary complaint, Bankruptcy Court for the Northern District of California (canb), DOCX engine (docs/DOCX.md).
-- The markdown contract -> a Word document on docx/reference.docx, laid out as typst/canb-adversary-complaint.typ:
-- counsel in two columns on the first lines, court title, the caption (debtor, parties, case numbers and the title
-- of the paper in a borderless table), a page break, then the numbered allegations (Fed. R. Civ. P. 10(b), applied by
-- FRBP 7010), lettered relief items (a), (b), ..., and the signature block kept whole. The 28 numbered lines and the
-- pleading rules are in the reference (header frame and page borders). Everything case-specific comes from the
-- sample's frontmatter, never from this file.

local TEXT_W = 9000   -- twips: 8.5 in - 1.5 in left - 0.75 in right = 6.25 in
local PITCH = 480     -- twips: 24 pt, one numbered line
local SINGLE = 276    -- twips: 13.8 pt, single-spaced lines (counsel, caption, signature)

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- a paragraph: style, direct pPr (in schema order, after pStyle), text, bold
local function para(style, text, ppr, bold)
  local body = (text ~= nil and text ~= "") and run(text, bold) or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. body .. '</w:p>'
end

local function sp(before, after, line, rule)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. line .. '" w:lineRule="' .. rule .. '"/>'
end

local function spacer(twips)
  return raw('<w:p><w:pPr><w:pStyle w:val="Single"/>' .. sp(0, 0, twips, "exact") .. '</w:pPr></w:p>')
end

local function cell(w, inner, borders)
  local b = ''
  if borders then b = '<w:tcBorders>' .. borders .. '</w:tcBorders>' end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. b .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- a borderless table: widths (twips) and the rows (each row a string of cells)
local function borderless_table(widths, rows, cant_split)
  local grid = ""
  local total = 0
  for _, w in ipairs(widths) do
    grid = grid .. '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  local trpr = cant_split and '<w:trPr><w:cantSplit/></w:trPr>' or ''
  local body = ""
  for _, r in ipairs(rows) do body = body .. '<w:tr>' .. trpr .. r .. '</w:tr>' end
  return '<w:tbl><w:tblPr><w:tblStyle w:val="TableNormal"/><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. grid .. '</w:tblGrid>' .. body .. '</w:tbl>'
end

local function line_list(list)
  local out = ""
  for _, l in ipairs(list or {}) do out = out .. para("Single", plain(l)) end
  return out
end

-- counsel (Civil L.R. 3-4(a)(1)): one column per list in frontmatter `counsel`, side by side, single spaced.
-- The block fills whole numbered lines, at least 7 (Civil L.R. 3-4(a)(3)); the court title follows on the grid.
local function counsel(cols)
  local n = #cols
  if n == 0 then return nil, nil end
  local gutter = 432
  local w = math.floor((TEXT_W - gutter * (n - 1)) / n)
  local widths, cells, maxlines = {}, {}, 0
  for i, c in ipairs(cols) do
    widths[#widths + 1] = w
    cells[#cells + 1] = cell(w, line_list(c))
    if #c > maxlines then maxlines = #c end
    if i < n then
      widths[#widths + 1] = gutter
      cells[#cells + 1] = cell(gutter, para("Single", ""))
    end
  end
  -- one tall row of cells; the pad after it rounds the block to whole numbered lines
  local out = raw(borderless_table(widths, { table.concat(cells) }, true))
  local h = maxlines * SINGLE / 20 -- in pt
  local target = math.max(7, math.ceil(h / 24)) * 24
  local pad = target - h
  local extra = nil
  if pad > 0 then extra = raw('<w:p><w:pPr><w:pStyle w:val="Single"/>' .. sp(0, 0, math.floor(pad * 20 + 0.5), "exact") .. '</w:pPr></w:p>') end
  return out, extra
end

-- caption (B.L.R. 1005-1; Official Form 416A layout): one row; the left cell holds the debtor ("In re:"), the
-- parties with "v." between them, ruled at the right and below as in the typst template; the right cell holds
-- the case numbers, chapter, judge, adversary number, the title (bold caps) and the jury demand legend.
local LEFT_W, GAP_W = 4608, 288
local RIGHT_W = TEXT_W - LEFT_W - GAP_W

local function caption(meta)
  local left = ""
  local c = meta.caption or {}
  if c.debtor then
    for _, n in ipairs(c.debtor.names or {}) do left = left .. para("Single", plain(n)) end
    left = left .. para("Single", plain(c.debtor.designation), '<w:ind w:left="2304"/>' .. sp(0, 240, SINGLE, "exact"))
  end
  for k, p in ipairs(c.parties or {}) do
    if k > 1 then left = left .. para("Single", "v.", '<w:jc w:val="center"/>' .. sp(0, 240, SINGLE, "exact")) end
    for _, n in ipairs(p.names or {}) do left = left .. para("Single", plain(n)) end
    left = left .. para("Single", plain(p.designation), '<w:ind w:left="2304"/>' .. sp(0, 160, SINGLE, "exact"))
  end
  local right_lines = { "Case No. " .. plain(meta.case_number) }
  if meta.chapter ~= nil then right_lines[#right_lines + 1] = "Chapter " .. plain(meta.chapter) end
  if meta.judge ~= nil and plain(meta.judge) ~= "" then right_lines[#right_lines + 1] = plain(meta.judge) end
  local adv = plain(meta.adversary_number)
  if adv == "" then adv = "____________" end
  right_lines[#right_lines + 1] = "Adversary Case No. " .. adv
  local right = ""
  for _, l in ipairs(right_lines) do right = right .. para("Single", l, '<w:ind w:left="144"/>') end
  right = right .. para("Single", "", '<w:ind w:left="144"/>' .. sp(0, 0, SINGLE, "exact"))
  right = right .. para("Single", plain(meta.brief_title):upper(), '<w:ind w:left="144"/>' .. sp(0, 240, SINGLE, "exact"), true)
  if meta.jury_demand == true then
    right = right .. para("Single", "DEMAND FOR JURY TRIAL", '<w:ind w:left="144"/>', true)
  end
  local rule = '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  local row = cell(LEFT_W, left, rule)
    .. cell(GAP_W, para("Single", ""))
    .. cell(RIGHT_W, right)
  return raw(borderless_table({ LEFT_W, GAP_W, RIGHT_W }, { row }, true))
end

local function relief_item(label, blocks)
  local inl = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
  local first = blocks[1]
  if first and (first.t == "Para" or first.t == "Plain") then
    inl:extend(first.content)
    blocks = { table.unpack(blocks, 2) }
  end
  local out = { pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Relief" })) }
  for _, b in ipairs(blocks) do out[#out + 1] = b end
  return out
end

local function letter(i)
  if i <= 26 then return string.char(96 + i) end
  return tostring(i)
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: counsel (lines 1 to 7 at least), court title (bold, centered, one numbered line each), caption
  local cols = {}
  for _, c in ipairs(meta.counsel or {}) do
    local lines = {}
    for _, l in ipairs(c) do lines[#lines + 1] = plain(l) end
    cols[#cols + 1] = lines
  end
  local tbl, pad = counsel(cols)
  if tbl then add(tbl) end
  if pad then add(pad) end
  for _, line in ipairs(meta.court or {}) do
    add(raw(para("CourtTitle", plain(line):upper())))
  end
  add(spacer(PITCH))
  add(caption(meta))

  -- the lead-in (or, without one, the first body block) starts page 2: the cover is its own page
  if meta.lead_in then
    add(pandoc.Div({ pandoc.Para(meta.lead_in) }, pandoc.Attr("", {}, { ["custom-style"] = "LeadIn" })))
  else
    add(raw('<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p>'))
  end

  -- body: each paragraph numbered 1, 2, ...; headings, tables and quotations unnumbered; lists lettered (a), (b)...
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
      inl:extend(b.content)
      add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" })))
    elseif b.t == "Header" and b.level == 1 then
      b.content = b.content:walk({ Str = function(s) s.text = s.text:upper(); return s end })
      add(b)
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        for _, x in ipairs(relief_item("(" .. letter(i) .. ")", item)) do add(x) end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, x in ipairs(relief_item("\u{2022}", item)) do add(x) end
      end
    else
      add(b)
    end
  end

  -- signature block (as typst signature-block): dated at left, kept whole on one page
  local sig = meta.signature or {}
  local right = para("Single", "Respectfully submitted,")
  right = right .. para("Single", "", sp(0, 0, PITCH, "exact"))
  for _, l in ipairs(sig.firm or {}) do right = right .. para("Single", plain(l)) end
  right = right .. para("Single", "", sp(0, 0, PITCH // 2, "exact"))
  right = right .. para("Single", "By: /s/ " .. plain(sig.signer))
  for _, l in ipairs(sig.lines or {}) do right = right .. para("Single", plain(l)) end
  local left = para("Single", meta.date and ("Dated: " .. plain(meta.date)) or "")
  add(raw(borderless_table({ 3744, 288, TEXT_W - 3744 - 288 }, {
    cell(3744, left) .. cell(288, para("Single", "")) .. cell(TEXT_W - 3744 - 288, right),
  }, true)))

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
