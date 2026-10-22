-- Motion to dismiss with memorandum in support, for the U.S. District Court for the District of North Dakota (ndd),
-- docx engine: what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/ndd-motion-brief.typ does (README "Engines"): the court title with the division (Civil Rule 3.1(A)), the
-- caption with its column of ")" marks, the body paragraphs (not numbered), the headings, lettered lists,
-- quotations, the signature block and the certificate of service. Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file. Caption, signature and certificate are OOXML tables (the
-- last two one row that never splits, typst: breakable: false).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276             -- typst pitch-double, pitch-single
local INDENT = 720                        -- typst para-indent, 0.5 in
local LIST_BOX = 720                      -- typst list-box, 0.5 in
local QUOTE = 1440                        -- typst quote-indent, 1 in
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT, CAP_PAREN = 4896, 432     -- typst caption-left 3.4 in, caption-paren 0.3 in
local CAP_INSET = 288                     -- typst caption-inset 0.2 in
local SIG_INDENT = 4680                   -- typst sig-indent 3.25 in
local SERVED = 720                        -- typst served-indent 0.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local CANT_SPLIT = '<w:trPr><w:cantSplit/></w:trPr>'

local function upper_inlines(m)
  if type(m) == "string" then return pandoc.text.upper(m) end
  return pandoc.Inlines(m):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Court title and caption (Civil Rule 3.1(A); Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local keys = { "court", "district", "division" }
  for i, key in ipairs(keys) do
    -- the last title line carries the space above the caption (typst: the caption block's above)
    out[#out + 1] = p(xe.inl(upper_inlines(meta[key]), { b = true }),
      { jc = "center", after = i == #keys and SINGLE or 0 })
  end
  -- Left cell: each party's names, then its designation when it has one; "v." between the parties; a ")" beside
  -- every row.
  local left, paren = {}, {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    if plain(party.designation) ~= "" then left[#left + 1] = p(xe.inl(party.designation)) end
  end
  for _ = 1, #left do paren[#paren + 1] = p(xe.runs(")")) end
  -- Right cell: the case number (blank until assigned) and the title.
  local number = plain(meta.case_number)
  if number == "" then number = "____________" end
  local right = {
    p(xe.runs("Case No. " .. number)),
    p(xe.inl(upper_inlines(meta.title), { b = true }), { before = SINGLE }),
  }
  out[#out + 1] = tbl({ CAP_LEFT, CAP_PAREN, TEXTW - CAP_LEFT - CAP_PAREN }, {
    { body = left }, { body = paren },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

-- after: the space below the block (the certificate's pitch-double above, given as space after the signature, because
-- Word keeps the space above a paragraph that opens a page, where typst drops it).
local function signature(meta, after)
  local sig = meta.signature
  local cell = {}
  local gap = BODY -- the block's own space above it (typst: above pitch-double)
  local function add(body, left, before)
    cell[#cell + 1] = p(body, { left = left, before = math.max(gap, before or 0) })
    gap = 0
  end
  local dated = plain(meta.date) ~= ""
  if dated then add(xe.runs("Dated: ") .. xe.inl(meta.date), 0) end
  local g = dated and BODY or 0
  if meta.closing then
    add(xe.inl(meta.closing), SIG_INDENT, g)
    g = BODY
  end
  for k, l in ipairs(sig.firm or {}) do add(xe.inl(l), SIG_INDENT, k == 1 and g or 0) end
  add(xe.runs("/s/ ") .. xe.inl(sig.signer), SIG_INDENT, BODY)
  for _, l in ipairs(sig.lines or {}) do add(xe.inl(l), SIG_INDENT) end
  if after > 0 then cell[#cell] = cell[#cell]:gsub('w:after="0"', 'w:after="' .. after .. '"', 1) end
  return tbl({ TEXTW }, { { body = cell } }, CANT_SPLIT)
end

local function certificate(c)
  local cell = {
    p(xe.inl(upper_inlines(c.heading), { b = true }), { line = BODY, jc = "center" }),
    p(xe.inl(c.text), { line = BODY, first = INDENT, before = BODY }),
  }
  for _, l in ipairs(c.served or {}) do cell[#cell + 1] = p(xe.inl(l), { left = SERVED }) end
  cell[#cell + 1] = p(xe.runs("/s/ ") .. xe.inl(c.signer), { left = SIG_INDENT, before = BODY })
  for _, l in ipairs(c.signer_lines or {}) do cell[#cell + 1] = p(xe.inl(l), { left = SIG_INDENT }) end
  return tbl({ TEXTW }, { { body = cell } }, CANT_SPLIT)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function body_par(inlines, before)
  return p(xe.inl(inlines), { line = BODY, first = INDENT, before = before })
end

-- Headings at the body pitch, kept with the text: level 1 bold, centered, in capitals; level 2 bold and level 3
-- bold italic, at the margin with a hanging indent of para-indent.
local function heading(el, before)
  local content = el.content
  if el.level == 1 then content = upper_inlines(content) end
  local ind = el.level == 1 and xe.ind(0, nil, 0) or xe.ind(INDENT, INDENT)
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(before or 0, 0, BODY), ind,
    xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, { b = true, i = el.level >= 3 }))
end

-- Lettered lists (typst enum "(a)" in a pad of para-indent): the label at 0.5 in, the text hanging at 1 in.
local function lettered(list, out, before)
  for j, item in ipairs(list.content) do
    for k, b in ipairs(item) do
      local lab = k == 1 and ("(" .. string.char(96 + j) .. ")\t") or ""
      out[#out + 1] = p(xe.runs(lab) .. xe.inl(b.content),
        { line = BODY, left = INDENT + LIST_BOX, hanging = LIST_BOX, before = before })
      before = 0
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  assert(meta.division, "ndd-motion-brief: the caption must designate the division (Civil Rule 3.1(A))")
  local out = cover(meta)
  -- the caption stands a single line above the text (typst: the caption block's below); Word has no space after a
  -- table, so the first paragraph after it takes the space before it
  local gap = SINGLE
  local function take()
    local g = gap
    gap = 0
    return g
  end
  if meta.lead_in then out[#out + 1] = body_par(meta.lead_in, take()) end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b, take())
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content, take())
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      lettered(b, out, take())
    elseif b.t == "BlockQuote" then
      -- quoted material, single-spaced (Civil Rule 5.1(B)(2)), a single line below it
      for _, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { left = QUOTE, right = QUOTE, before = take(), after = SINGLE })
      end
    else
      error("ndd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta, meta.certificate and BODY or 0)
  if meta.certificate then out[#out + 1] = certificate(meta.certificate) end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
