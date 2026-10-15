-- D. Kan. Bankr. adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/ksb-adversary-complaint.typ. The caption, the signature block and the page break before the
-- exhibits are built here as raw WordprocessingML (borderless and bordered tables, exact-height paragraphs);
-- the body keeps pandoc's paragraphs and headings. Numbered allegations are written as "N.<tab>text" in the
-- "Allegation" style (number at the 0.5 in indent, text at 1 in), with one running count across headings,
-- as the typst `enum` counter does. Page numbers come from the reference's footer.

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- one run of text: o.b bold, o.i italic
local function run(text, o)
  o = o or {}
  local rpr = (o.b and "<w:b/>" or "") .. (o.i and "<w:i/>" or "")
  return "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- one paragraph in a style; o.before / o.after in twips, o.left (indent, twips), o.jc alignment
local function para(style, runs, o)
  o = o or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if o.before or o.after then
    ppr = ppr .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '"/>'
  end
  if o.left then ppr = ppr .. '<w:ind w:left="' .. o.left .. '" w:firstLine="0"/>' end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. runs .. "</w:p>"
end

-- a table cell: width (twips), paragraphs (xml), o.rule right border, o.ml/o.mr side padding, o.mb bottom padding
local function cell(width, paras, o)
  o = o or {}
  local tcpr = '<w:tcW w:w="' .. width .. '" w:type="dxa"/>'
  if o.rule then
    tcpr = tcpr .. '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  end
  if o.ml or o.mr or o.mb then
    tcpr = tcpr .. "<w:tcMar>"
      .. (o.ml and ('<w:left w:w="' .. o.ml .. '" w:type="dxa"/>') or "")
      .. (o.mb and ('<w:bottom w:w="' .. o.mb .. '" w:type="dxa"/>') or "")
      .. (o.mr and ('<w:right w:w="' .. o.mr .. '" w:type="dxa"/>') or "")
      .. "</w:tcMar>"
  end
  return "<w:tc><w:tcPr>" .. tcpr .. "</w:tcPr>" .. paras .. "</w:tc>"
end

-- a borderless fixed-width table of one row
local function row_table(widths, cells)
  local total, grid = 0, ""
  for _, w in ipairs(widths) do
    total = total + w
    grid = grid .. '<w:gridCol w:w="' .. w .. '"/>'
  end
  return "<w:tbl><w:tblPr>"
    .. '<w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '</w:tblPr><w:tblGrid>' .. grid .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

local TEXT_W = 9360   -- 6.5 in between the 1 in margins
local CAPTION_LEFT = 5184  -- 3.6 in, the party column (typst caption-left)
local SIG_RIGHT = 4608     -- 3.2 in, the signature column (typst sig-left)
local GAP = 320            -- 16 pt: half a line pitch (typst line-pitch * 0.5)
local LINE = 640           -- 32 pt: the line pitch (typst line-pitch)

local function caption_xml(meta)
  local left = { para("Single", run("In re:")) }
  local debtor = meta.debtor
  for i, n in ipairs(debtor.names) do
    left[#left + 1] = para("Single", run(plain(n)), { before = i == 1 and GAP or 0 })
  end
  left[#left + 1] = para("Single", run(plain(debtor.designation)), { left = 2880 })
  for si, side in ipairs(meta.caption) do
    if si > 1 then left[#left + 1] = para("Single", run("v."), { before = GAP, jc = "center" }) end
    for i, n in ipairs(side.names) do
      left[#left + 1] = para("Single", run(plain(n)), { before = i == 1 and GAP or 0 })
    end
    -- the last designation carries the gap that closes the party column
    local last = si == #meta.caption
    left[#left + 1] = para("Single", run(plain(side.designation)), { left = 2880, after = last and GAP or nil })
  end

  local adv = plain(meta.adversary_number)
  if adv == "" then adv = "Adv. Proc. No. " .. string.rep("_", 14) end
  local right = {
    para("Single", run(plain(meta.bankruptcy_case)), { before = LINE * 3 // 2 }),
    para("Single", run(plain(meta.chapter))),
    para("Single", run(adv), { before = LINE * 5 // 2 }),
  }
  return row_table({ CAPTION_LEFT, TEXT_W - CAPTION_LEFT }, {
    cell(CAPTION_LEFT, table.concat(left), { rule = true, mr = 384, mb = 160 }),
    cell(TEXT_W - CAPTION_LEFT, table.concat(right), { ml = 384 }),
  })
end

-- signature block: the date at the left, the signer at the right (typst signature-block)
local function signature_xml(meta, sig)
  local left = para("Single", run(plain(meta.date)), { before = LINE })
  local R = {}
  R[#R + 1] = para("Single", run("Respectfully submitted,"), { before = LINE })
  for i, l in ipairs(sig.preamble or {}) do
    R[#R + 1] = para("Single", run(plain(l)), { before = i == 1 and GAP or 0 })
  end
  local by = "By: /s/ " .. plain(sig.signer)
  R[#R + 1] = para("Single", run(by), { before = GAP })
  local name = plain(sig.signer)
  if sig.bar then name = name .. ", " .. plain(sig.bar) end
  R[#R + 1] = para("Single", run(name))
  for _, l in ipairs(sig.lines or {}) do R[#R + 1] = para("Single", run(plain(l))) end
  if sig.role then R[#R + 1] = para("Single", run(plain(sig.role), { b = true }), { before = GAP }) end
  return row_table({ TEXT_W - SIG_RIGHT, SIG_RIGHT }, {
    cell(TEXT_W - SIG_RIGHT, left),
    cell(SIG_RIGHT, table.concat(R)),
  })
end

local function page_break_run()
  return '<w:r><w:br w:type="page"/></w:r>'
end

local function is_marker(b)
  return b.t == "Para" and plain(b) == "[[signature]]"
end

function Pandoc(doc)
  local meta = doc.meta
  local sig = meta.signature
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- court title, caption, document title (typst: the first page)
  for i, l in ipairs(meta.court) do
    add(pandoc.RawBlock("openxml", para("Single", run(plain(l):upper(), { b = true }),
      { jc = "center", after = i == #meta.court and LINE or 0 })))
  end
  add(pandoc.RawBlock("openxml", caption_xml(meta)))
  add(pandoc.RawBlock("openxml", para("Single", run(plain(meta.title):upper(), { b = true }),
    { jc = "center", before = LINE, after = GAP })))

  -- body: the markdown blocks; the signature block replaces the [[signature]] marker
  local after_sig = false
  for _, b in ipairs(doc.blocks) do
    if is_marker(b) then
      add(pandoc.RawBlock("openxml", signature_xml(meta, sig)))
      after_sig = true
    elseif after_sig then
      -- exhibits start on their own page (typst pagebreak(weak: true))
      if b.t == "Header" then
        b.content = { pandoc.RawInline("openxml", page_break_run()), table.unpack(b.content) }
      else
        add(pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'))
      end
      add(b)
      after_sig = false
    else
      add(b)
    end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

-- numbered allegations: one running count across the whole document (typst `enum` counter)
local number = 0
function OrderedList(el)
  local out = {}
  for _, item in ipairs(el.content) do
    number = number + 1
    local first = item[1]
    local inl = pandoc.List({ pandoc.Str(number .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
    local rest = {}
    if first and (first.t == "Para" or first.t == "Plain") then
      inl:extend(first.content)
      for i = 2, #item do rest[#rest + 1] = item[i] end
    else
      for i = 1, #item do rest[#rest + 1] = item[i] end
    end
    out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" }))
    for _, b in ipairs(rest) do out[#out + 1] = b end
  end
  return out
end
-- the exhibit table, as the typst template sets it: no rules, 6 pt side and 3 pt top and bottom insets, the
-- header row in bold and repeated on each page, rows that do not split across pages, the total row in bold.
-- Column widths (twips) are those the typst auto columns take for this table (typst output, not a filed PDF).
local EXHIBIT_TW = { PAYEE = 3120, DATE = 1800, ["PAYMENT TYPE"] = 2304, AMOUNT = 2000 }

local function exhibit_row(cells, widths, header)
  local xml = {}
  for i, c in ipairs(cells) do
    local text = plain(c.contents)
    local first = c.contents[1] and c.contents[1].content and c.contents[1].content[1]
    local bold = header or (first ~= nil and first.t == "Strong")
    xml[#xml + 1] = cell(widths[i], para("Compact", run(text, { b = bold })))
  end
  return "<w:tr><w:trPr><w:cantSplit/>" .. (header and "<w:tblHeader/>" or "") .. "</w:trPr>"
    .. table.concat(xml) .. "</w:tr>"
end

function Table(t)
  local head = t.head.rows[1]
  local widths = {}
  for i, c in ipairs(head.cells) do
    widths[i] = EXHIBIT_TW[plain(c.contents):upper()] or math.floor(TEXT_W / #head.cells)
  end
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local grid = ""
  for _, w in ipairs(widths) do grid = grid .. '<w:gridCol w:w="' .. w .. '"/>' end
  local rows = {}
  for _, r in ipairs(t.head.rows) do rows[#rows + 1] = exhibit_row(r.cells, widths, true) end
  for _, body in ipairs(t.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = exhibit_row(r.cells, widths, false) end
  end
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="60" w:type="dxa"/><w:left w:w="120" w:type="dxa"/>'
    .. '<w:bottom w:w="60" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. "<w:tblGrid>" .. grid .. "</w:tblGrid>" .. table.concat(rows) .. "</w:tbl>"
  return pandoc.RawBlock("openxml", xml)
end
