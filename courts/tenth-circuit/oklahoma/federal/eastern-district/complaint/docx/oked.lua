-- E.D. Okla. complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it reads and breaks as
-- typst/oked-complaint.typ does: the court title, the caption (party column with the parties numbered, LCvR 3.1, a
-- column of ")" marks, the case number and legends), the title, the body (numbered paragraphs, Fed. R. Civ. P.
-- 10(b); headings; block quotations; lettered prayer items) and the signature block (Fed. R. Civ. P. 11(a)). Every
-- case-specific word comes from the sample's frontmatter (read as written, $FORMBOOK_META) and body, never from this
-- file. Font, margins and the page number are in docx/reference.xml (fb render builds the reference document).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines number the same paragraphs. Each chunk is read by
-- pandoc alone, as cmarker reads it: "[McCurtain County Sheriff Kevin Clardy]" in a quotation stays text (read with
-- the whole document, pandoc made it a link to the heading of that name and dropped the brackets: DEF-CONT-001).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LABEL = 1440                       -- typst para-indent + number-width: the text after a number or letter, 1 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAREN = 5040, 432    -- typst caption-left 3.5 in, caption-paren 0.3 in
local CAP_NUMBER = 720                   -- typst caption-number, 0.5 in
local CAP_VERSUS, CAP_DESIG = 1584, 2592 -- typst caption-versus 1.1 in, caption-designation 1.8 in
local QUOTE_LEFT, QUOTE_RIGHT = 1440, 720 -- typst quote-left 1 in, quote-right 0.5 in
local SIG = 4608                         -- typst sig-left, 3.2 in
local COURT_GAP, TITLE_ABOVE, TITLE_BELOW = 480, 480, 240 -- typst court-gap, title-above, title-below
local HEADING_ABOVE, QUOTE_GAP = 240, 240 -- typst heading-above, quote-gap
local SIG_ABOVE, SIG_GAP = 480, 240      -- typst sig-above, sig-gap
local UNNUMBERED = "<!--unnumbered-->"

local function read_file(path)
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (pandoc's metadata would read it as markdown with the whole document's references).
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 1331"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(3)" or "A." lists).
local function md(s)
  local doc = pandoc.read(tostring(s), "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return bind_doubled(pandoc.Inlines(pandoc.utils.blocks_to_inlines(doc.blocks)):walk({ Str = breaks }))
end

local function upper(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, lines, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
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

local function cell(w, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

-- typst caption-rows(): each party's lines (the first numbered "(n)", LCvR 3.1), its designation, a blank row
-- between parties, a blank row, "v." and a blank row between the sides.
local function caption_rows(c)
  local rows, k = {}, 0
  for si, key in ipairs({ "plaintiffs", "defendants" }) do
    if si > 1 then
      rows[#rows + 1] = false
      rows[#rows + 1] = { left = CAP_VERSUS, text = "v." }
      rows[#rows + 1] = false
    end
    for pi, party in ipairs(list(c[key])) do
      if pi > 1 then rows[#rows + 1] = false end
      k = k + 1
      for li, l in ipairs(list(party.names)) do rows[#rows + 1] = { number = li == 1 and k or nil, text = l } end
      if party.designation then rows[#rows + 1] = { left = CAP_DESIG, text = party.designation } end
    end
  end
  return rows
end

local function caption()
  local rows = caption_rows(RAW.caption or {})
  local l, m, r = {}, {}, {}
  for _, row in ipairs(rows) do
    if not row then
      l[#l + 1] = p("")
    elseif row.left then
      l[#l + 1] = p(xe.inl(md(row.text)), { left = row.left })
    else
      l[#l + 1] = p(xe.runs((row.number and ("(" .. row.number .. ")") or "") .. "\t") .. xe.inl(md(row.text)),
        { left = CAP_NUMBER, hanging = CAP_NUMBER, tab = CAP_NUMBER })
    end
    m[#m + 1] = p(xe.runs(")"))
  end
  -- typst: the case number on row floor(n / 2) - 1, two blank rows, then the legends
  local r0 = math.max(0, #rows // 2 - 1)
  for _ = 1, r0 do r[#r + 1] = p("") end
  r[#r + 1] = p(xe.runs("Case No. " .. tostring(RAW.case_number or "")))
  r[#r + 1] = p("")
  r[#r + 1] = p("")
  for _, s in ipairs(list(RAW.legends)) do r[#r + 1] = p(xe.inl(md(s), { b = true })) end
  if #l == 0 then l[1] = p("") end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_PAREN .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_PAREN) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, l) .. cell(CAP_PAREN, m) .. cell(TEXTW - CAP_LEFT - CAP_PAREN, r) .. '</w:tr></w:tbl>'
end

local function cover(out)
  for _, l in ipairs(list(RAW.court)) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(l), { b = true }), { jc = "center" })
  end
  out[#out + 1] = p("", { line = COURT_GAP })
  out[#out + 1] = caption()
  out[#out + 1] = p(xe.inl(upper(md(RAW.title or "")), { b = true }),
    { before = TITLE_ABOVE, after = TITLE_BELOW, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's body()
-- ---------------------------------------------------------------------------

-- The sample's body: the text after its frontmatter, split at blank lines.
local function chunks()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out
end

-- A body paragraph on the body pitch, its first line indented; a label (number or letter) and a tab to 1 in.
local function bodypar(label, inl, keep)
  if label then
    return p(xe.runs(label .. "\t") .. xe.inl(inl), { line = BODY, first = INDENT, tab = LABEL, keep = keep })
  end
  return p(xe.inl(inl), { line = BODY, first = INDENT, keep = keep })
end

local function body(out)
  local cs = chunks()
  local n = 0
  for i, t in ipairs(cs) do
    local last = i == #cs
    local hashes, htext = t:match("^(#+)[ \t]+(.*)$")
    if hashes then
      -- level 1 centered bold capitals, 2 bold, 3 bold italic; single-spaced, kept with the text after it
      local inl, lvl = md(htext), #hashes
      if lvl == 1 then inl = upper(inl) end
      out[#out + 1] = p(xe.inl(inl, { b = true, i = lvl >= 3 }), { before = HEADING_ABOVE,
        jc = lvl == 1 and "center" or "left", keep = true })
    elseif t:sub(1, 1) == ">" then
      -- single-spaced, indented, not split (typst breakable: false)
      local q = t:gsub("\n>[ \t]?", "\n"):gsub("^>[ \t]?", "")
      out[#out + 1] = p(xe.inl(md(q)), { before = QUOTE_GAP, after = QUOTE_GAP, left = QUOTE_LEFT,
        right = QUOTE_RIGHT, keep = last, lines = true })
    elseif t:match("^%-[ \t]") then
      -- the prayer items, lettered (a), (b), ...
      local items = {}
      for l in (t .. "\n"):gmatch("(.-)\n") do
        local rest = l:match("^%-[ \t]+(.*)$")
        if rest then items[#items + 1] = rest elseif #items > 0 then items[#items] = items[#items] .. "\n" .. l end
      end
      for k, it in ipairs(items) do
        out[#out + 1] = bodypar("(" .. string.char(96 + k) .. ").", md(it), last and k == #items)
      end
    elseif t:sub(1, #UNNUMBERED) == UNNUMBERED then
      out[#out + 1] = bodypar(nil, md(t:sub(#UNNUMBERED + 1):match("^%s*(.-)$")), last)
    else
      n = n + 1
      out[#out + 1] = bodypar(n .. ".", md(t), last)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block: from 3.2 in, kept on one page
-- ---------------------------------------------------------------------------

local function signature(out)
  local ls = { { xe.runs("Respectfully submitted,"), 0 } }
  for i, s in ipairs(list(RAW.signature)) do
    if i > 1 then ls[#ls + 1] = { xe.runs("and"), SIG_GAP } end
    for j, f in ipairs(list(s.firm)) do ls[#ls + 1] = { xe.inl(md(f), { b = true }), j == 1 and SIG_GAP or 0 } end
    ls[#ls + 1] = { xe.inl(md("By: /s/ " .. tostring(s.signer or ""))), SIG_GAP }
    for _, l in ipairs(list(s.lines)) do ls[#ls + 1] = { xe.inl(md(l)), 0 } end
  end
  if RAW.attorneys_for then ls[#ls + 1] = { xe.inl(md(RAW.attorneys_for)), SIG_GAP } end
  for i, l in ipairs(ls) do
    out[#out + 1] = p(l[1], { before = i == 1 and SIG_ABOVE or l[2], left = SIG, keep = i < #ls })
  end
end

function Pandoc(doc)
  local out = {}
  cover(out)
  body(out)
  signature(out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
