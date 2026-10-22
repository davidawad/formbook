-- W.D. Wis. bankruptcy adversary complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it
-- reads and breaks as typst/wiwb-adversary-complaint.typ does: the court title, the caption (a table row: the party
-- column ruled at its right and foot, "Adversary Case No." beside it), the title, numbered paragraphs (Fed. R. Civ.
-- P. 10(b), through Fed. R. Bankr. P. 7010), headings, the lettered prayer and the signature block. Every case word
-- comes from the sample's frontmatter and body, never from this file. Font, margins and the page number are in
-- docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines number and letter the same paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUMBER = 1440                      -- typst para-indent + number-box: a paragraph's text, 1 in
local ITEM = 1296                        -- typst para-indent + item-box: a prayer item's text, 0.9 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_GUTTER = 360                   -- typst caption-gutter, 0.25 in
local CAP_PAD = 185                      -- typst caption-pad, 10 pt (200 twips), less the 0.75 pt rule Word sets inside it
local DESIGNATION_RIGHT = 376            -- typst designation-right less caption-pad: 0.4 in - 10 pt
local SIG = 4896                         -- typst sig-col, 3.4 in
local TITLE_GAP, DEBTOR_GAP = 360, 288   -- typst title-gap, debtor-gap
local DESIGNATION_GAP, VERSUS_GAP = 120, 192 -- typst designation-gap, versus-gap
local ADV_ABOVE = 48                     -- typst adv-above
local H1_ABOVE, H1_BELOW = 288, 144      -- typst h1-above, h1-below
local H2_ABOVE, H2_BELOW = 240, 120      -- typst h2-above, h2-below
local SIG_ABOVE, SIG_GAP = 648, 120      -- typst sig-above, sig-gap
local SIG_LINE_ABOVE, SIGNER_ABOVE = 648, 48 -- typst sig-line-above, signer-above
local ADV_BLANK = "____________"         -- typst adv-blank
local SIG_BLANK = "__________________________" -- typst sig-blank
local COURT_NAME = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF WISCONSIN" } -- Fed. R. Bankr. P. 9004(b)(1)

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number (typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

local function fix(inl)
  return bind_doubled(pandoc.Inlines(inl):walk({ Str = breaks }))
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(a)" or "A." lists).
local function md(s)
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return fix(pandoc.utils.blocks_to_inlines(doc.blocks))
end

local function meta_inl(v)
  return type(v) == "string" and v or fix(v)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function caption(m)
  local left = {}
  for _, l in ipairs({ "In re:", m.debtor, "Case No. " .. plain(m.bankruptcy_case), "Chapter " .. plain(m.chapter) }) do
    left[#left + 1] = p(xe.inl(meta_inl(l)))
  end
  local sides = items(m.caption)
  for i, side in ipairs(sides) do
    for j, n in ipairs(items(side.names)) do
      left[#left + 1] = p(xe.inl(meta_inl(n)), { before = j == 1 and DEBTOR_GAP or 0 })
    end
    left[#left + 1] = p(xe.inl(meta_inl(side.designation)),
      { before = DESIGNATION_GAP, right = DESIGNATION_RIGHT, jc = "right" })
    if i < #sides then left[#left + 1] = p(xe.runs("v."), { before = VERSUS_GAP, after = VERSUS_GAP }) end
  end
  local adv = plain(m.adversary_case)
  local right = { p(xe.runs("Adversary Case No.", { b = true }) .. xe.runs(" " .. (adv ~= "" and adv or ADV_BLANK)),
    { before = ADV_ABOVE }) }
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, RULES .. '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', left) ..
    cell(CAP_GUTTER, "", { p("") }) ..
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, "", right) .. '</w:tr></w:tbl>'
end

local function cover(m, out)
  for _, t in ipairs(COURT_NAME) do out[#out + 1] = p(xe.runs(t, { b = true }), { jc = "center" }) end
  out[#out + 1] = p("", { line = TITLE_GAP })
  out[#out + 1] = caption(m)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(m.title)), { b = true }),
    { before = TITLE_GAP, after = TITLE_GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Signature: the date in the first column, the firm beside it (a tab to the hanging indent), the rest under it
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local sig = m.signature
  local ls = {}
  if sig.firm ~= nil then ls[#ls + 1] = { xe.inl(meta_inl(sig.firm), { b = true }), 0 } end
  ls[#ls + 1] = { xe.runs("Respectfully submitted,"), sig.firm ~= nil and SIG_GAP or 0 }
  ls[#ls + 1] = { xe.runs("/s/ " .. SIG_BLANK), SIG_LINE_ABOVE }
  ls[#ls + 1] = { xe.inl(meta_inl(sig.signer)), SIGNER_ABOVE }
  for _, l in ipairs(items(sig.lines)) do ls[#ls + 1] = { xe.inl(meta_inl(l)), 0 } end
  for i, l in ipairs(ls) do
    local keep = i < #ls
    if i == 1 then
      local date = m.date ~= nil and xe.inl(meta_inl(m.date)) or ""
      out[#out + 1] = p(date .. xe.runs("\t") .. l[1],
        { before = SIG_ABOVE, left = SIG, hanging = SIG, tab = SIG, keep = keep })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = keep })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's allegations()
-- ---------------------------------------------------------------------------

local function chunks()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out
end

-- Headings on the single pitch, kept with the text: level 1 centered bold capitals, level 2 bold at the margin.
local function heading(t)
  local hashes, text = t:match("^(#+)%s+(.-)%s*$")
  local lvl = math.min(#hashes, 2)
  local inl = md(text)
  if lvl == 1 then
    inl = inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local above, below = H1_ABOVE, H1_BELOW
  if lvl == 2 then above, below = H2_ABOVE, H2_BELOW end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(above, below, SINGLE), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(inl, { b = true }))
end

-- A list chunk's items: the text after each "1." / "-" marker at the start of a line.
local function list_items(t)
  local out = {}
  for line in (t .. "\n"):gmatch("(.-)\n") do
    local rest = line:match("^%d+%.[ \t]+(.*)$") or line:match("^[-*+][ \t]+(.*)$")
    if rest then out[#out + 1] = rest elseif #out > 0 then out[#out] = out[#out] .. "\n" .. line end
  end
  return out
end

local function body(out)
  local n = 0
  for _, t in ipairs(chunks()) do
    if t:sub(1, 1) == "#" then
      out[#out + 1] = heading(t)
    elseif t:match("^%d+%.[ \t]") or t:match("^[-*+][ \t]") then
      for i, item in ipairs(list_items(t)) do
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + i) .. ")\t") .. xe.inl(md(item)),
          { line = BODY, left = ITEM, hanging = ITEM - INDENT, tab = ITEM })
      end
    elseif t:match("^WHEREFORE") then
      out[#out + 1] = p(xe.inl(md(t)), { line = BODY, first = INDENT, keep = true })
    else
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(md(t)), { line = BODY, first = INDENT, tab = NUMBER })
    end
  end
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  cover(m, out)
  body(out)
  if m.signature ~= nil then signature(m, out) end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
