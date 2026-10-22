-- Pandoc filter for the gasd complaint, engine docx, so that it reads and breaks as typst/gasd-complaint.typ does:
-- court title, caption, title, lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, block quotations,
-- lettered prayer items, signature block (LR 11.1). Every case word comes from the sample's frontmatter and body,
-- never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local GAP, SIG_GAP = 324, 162            -- typst gap 16.2 pt, sig-gap
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local LABEL = 576                        -- typst item-label, 0.4 in
local QUOTE = 1080                       -- typst quote-indent, 0.75 in
local TEXTW = 9360                       -- 6.5 in
local PARTY, PAREN = 4464, 432           -- typst caption-party-width 3.1 in, caption-paren-width 0.3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  local lines = { "IN THE UNITED STATES DISTRICT COURT", "SOUTHERN DISTRICT OF GEORGIA" }
  if meta.division then lines[#lines + 1] = pandoc.text.upper(plain(meta.division)) end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #lines and GAP or 0 })
  end
  -- Caption: a borderless three-column table, one row per line of the party column, ")" in the middle.
  local rows = {}
  local function cell(w, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. p(body) .. '</w:tc>'
  end
  for _, r in ipairs(meta.caption.rows) do
    rows[#rows + 1] = '<w:tr>' .. cell(PARTY, xe.inl(r.left)) .. cell(PAREN, xe.runs(")")) ..
      cell(TEXTW - PARTY - PAREN, xe.inl(r.right)) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. PARTY .. '"/><w:gridCol w:w="' .. PAREN .. '"/><w:gridCol w:w="' ..
    (TEXTW - PARTY - PAREN) .. '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- the title: Word has no space after a table, so it takes the gap before it
  local t = pandoc.utils.type(meta.title) == "Inlines" and meta.title:walk({
    Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }) or pandoc.text.upper(plain(meta.title))
  out[#out + 1] = p(xe.inl(t, { b = true }), { before = GAP, after = GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: a gap above and below, kept with the text; level 1 centered capitals, level 2 centered, level 3 at the
-- margin; all bold, at the body pitch.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(GAP, GAP, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- The quotations of the source, in order: each a list of paragraphs, each a list of its lines as typed (typst sets
-- them as text, so their list labels stay text; pandoc would read them as lists).
local function source_quotes()
  local f = PANDOC_STATE.input_files[1] and io.open(PANDOC_STATE.input_files[1], "r")
  if not f then error("gasd-complaint.lua: cannot read the sample") end
  local src = f:read("a"):gsub("\r", "")
  f:close()
  src = src:gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "")
  local quotes = {}
  for chunk in (src .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    chunk = chunk:match("^%s*(.-)%s*$")
    if chunk:sub(1, 1) == ">" then
      local paras, cur = {}, {}
      for line in (chunk .. "\n"):gmatch("(.-)\n") do
        local l = line:match("^%s*>?%s*(.-)%s*$")
        if l == "" then
          if #cur > 0 then paras[#paras + 1] = cur end
          cur = {}
        else
          cur[#cur + 1] = l
        end
      end
      if #cur > 0 then paras[#paras + 1] = cur end
      quotes[#quotes + 1] = paras
    end
  end
  return quotes
end

local function quotation(paras, out)
  local n = 0
  for _, para in ipairs(paras) do n = n + #para end
  local k = 0
  for i, para in ipairs(paras) do
    for j, l in ipairs(para) do
      k = k + 1
      out[#out + 1] = p(xe.runs(l), { before = (i > 1 and j == 1) and SINGLE or 0, after = k == n and GAP or 0,
        left = QUOTE, right = QUOTE })
    end
  end
end

-- Prayer items, lettered (a), (b), ...: the label half an inch in, the text hanging after a 0.4 in label box.
local function items(list, keep, out)
  for j, item in ipairs(list.content) do
    local lab = "(" .. string.char(96 + j) .. ")\t"
    local inl = pandoc.Inlines({})
    for k, b in ipairs(item) do
      if k > 1 then inl:insert(pandoc.Space()) end
      inl:extend(b.content)
    end
    out[#out + 1] = p(xe.runs(lab) .. xe.inl(inl), { line = BODY, after = GAP, left = INDENT + LABEL,
      hanging = LABEL, tab = INDENT + LABEL, keep = keep })
  end
end

-- The signature block (LR 11.1): firm, each signer, the address, the party represented; kept together.
local function signature(meta, out)
  local sig = meta.signature
  local lines = { { xe.inl(pandoc.utils.type(sig.firm) == "Inlines" and sig.firm:walk({
    Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }) or pandoc.text.upper(plain(sig.firm)),
    { b = true }), GAP } }
  for _, s in ipairs(sig.signers) do
    lines[#lines + 1] = { xe.runs("/s/ ") .. xe.inl(s.name), GAP }
    for _, l in ipairs(s.lines) do lines[#lines + 1] = { xe.inl(l), 0 } end
  end
  for i, l in ipairs(sig.address) do lines[#lines + 1] = { xe.inl(l), i == 1 and GAP or 0 } end
  lines[#lines + 1] = { xe.inl(sig["counsel-for"]), SIG_GAP }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], keep = i < #lines })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("Loan/Award": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1334": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, after = GAP }) end

  -- Body: each paragraph is one numbered paragraph; headings, quotations and lists are not numbered. The last list
  -- (the prayer) is kept with the signature block.
  local quotes = source_quotes()
  local q, n = 0, 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
        { line = BODY, first = INDENT, after = GAP, tab = 2 * INDENT })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, i == #blocks, out)
    elseif b.t == "BlockQuote" then
      q = q + 1
      quotation(quotes[q], out)
    else
      error("gasd-complaint.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
