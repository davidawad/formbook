-- S.D. Ind. complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it reads and breaks as
-- typst/insd-complaint.typ does: the court title, the caption (party column, a column of ")" marks, the case number),
-- the title (and the jury demand), the lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, block
-- quotations, the prayer list and the signature block (L.R. 5-1(b)). Every case-specific word comes from the
-- sample's frontmatter (read as written, $FORMBOOK_META) and body, never from this file. Font, margins and the page
-- number are in docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines number the same paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LABEL = 1440                       -- typst para-indent + number-box: the text after a number or list label, 1 in
local TEXTW = 9360                       -- 6.5 in
local CAP_PARTY, CAP_PAREN = 4896, 432   -- typst caption-party-w 3.4 in, caption-paren-w 0.3 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local SIG = 4680                         -- typst sig-left, 3.25 in
local PARA_GAP = 322                     -- typst para-gap, 16.1 pt
local HEADING_ABOVE = 240                -- typst heading-above, 12 pt
local COURT_GAP, TITLE_ABOVE, JURY_ABOVE, TITLE_BELOW = 480, 360, 120, 240 -- typst court-gap, title-above, jury-above, title-below
local SIG_ABOVE, DATE_GAP = 480, 240     -- typst sig-above, date-gap

local function read_file(path)
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (pandoc's metadata would drop the caption's leading spaces).
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

-- A doubled sign stays with its number ("¶¶ 27-29"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return bind_doubled(pandoc.Inlines(pandoc.utils.blocks_to_inlines(doc.blocks)):walk({ Str = breaks }))
end

local function upper(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
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

-- A line of plain text as written; "" is a blank line.
local function line(s, o) return p(s == "" and "" or xe.runs(s), o) end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local function cell(w, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function caption(c)
  local left, right = list(c.left), list(c.right)
  local l, m, r = {}, {}, {}
  for _, s in ipairs(left) do l[#l + 1] = line(s) end
  for _, s in ipairs(right) do r[#r + 1] = line(s) end
  for _ = 1, math.max(#left, #right) do m[#m + 1] = line(")") end
  if #l == 0 then l[1] = p("") end
  if #r == 0 then r[1] = p("") end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_PARTY .. '"/><w:gridCol w:w="' .. CAP_PAREN .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_PARTY - CAP_PAREN) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_PARTY, l) .. cell(CAP_PAREN, m) .. cell(TEXTW - CAP_PARTY - CAP_PAREN, r) .. '</w:tr></w:tbl>'
end

local function cover(out)
  for _, l in ipairs(list(RAW.court)) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end
  out[#out + 1] = p("", { line = COURT_GAP })
  out[#out + 1] = caption(RAW.caption or {})
  out[#out + 1] = p(xe.runs(pandoc.text.upper(RAW.title or ""), { b = true }), { before = TITLE_ABOVE, jc = "center" })
  if RAW.jury_demand == true then
    out[#out + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = JURY_ABOVE, jc = "center" })
  end
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's document loop
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

-- One chunk (typst: chunk()); above: the space above it, keep: kept with the next block.
local function chunk(t, num, above, keep, out)
  local hashes, htext = t:match("^(#+) (.*)$")
  if hashes and #hashes <= 3 then
    -- a heading: bold, single-spaced, kept with the text after it; levels 1 and 2 centered, level 1 in capitals
    local inl = md(htext)
    if #hashes == 1 then inl = upper(inl) end
    out[#out + 1] = p(xe.inl(inl, { b = true }), { before = math.max(above, HEADING_ABOVE), after = PARA_GAP,
      jc = #hashes == 3 and "left" or "center", keep = true })
  elseif t:match("^%- ") or t:match("^%d+%. ") then
    -- a list: each item's number as written (a bullet as "•") at the indent, its lines hanging at 1 in
    local items = {}
    for l in (t .. "\n"):gmatch("(.-)\n") do
      local mark, rest = l:match("^(%d+%.)[ \t]+(.*)$")
      if not mark and l:match("^%-[ \t]") then mark, rest = "\u{2022}", l:match("^%-[ \t]+(.*)$") end
      if mark then items[#items + 1] = { mark, rest } else items[#items][2] = items[#items][2] .. "\n" .. l end
    end
    for k, it in ipairs(items) do
      out[#out + 1] = p(xe.runs(it[1] .. "\t") .. xe.inl(md(it[2])), { line = BODY, after = PARA_GAP,
        before = k == 1 and above or 0, left = LABEL, hanging = LABEL - INDENT, tab = LABEL, keep = keep and k == #items })
    end
  elseif t:sub(1, 1) == ">" then
    local q = t:gsub("\n>[ \t]?", "\n"):gsub("^>[ \t]?", "")
    out[#out + 1] = p(xe.inl(md(q)), { before = above, after = PARA_GAP, left = QUOTE, right = QUOTE, keep = keep })
  elseif num then
    out[#out + 1] = p(xe.runs(num .. ".\t") .. xe.inl(md(t)), { line = BODY, after = PARA_GAP, before = above,
      first = INDENT, tab = LABEL, keep = keep })
  else
    out[#out + 1] = p(xe.inl(md(t)), { line = BODY, after = PARA_GAP, before = above, first = INDENT, keep = keep })
  end
end

local function body(out)
  local cs = chunks()
  local seen, n = false, 0
  for i, t in ipairs(cs) do
    if t:sub(1, 1) == "#" then seen = true end
    local list_or_quote = t:match("^%- ") or t:sub(1, 1) == ">" or t:match("^%d+%. ")
    local para = seen and t:sub(1, 1) ~= "#" and not list_or_quote and not t:match("^WHEREFORE")
    if para then n = n + 1 end
    chunk(t, para and n or nil, i == 1 and TITLE_BELOW or 0, i == #cs, out)
  end
end

-- ---------------------------------------------------------------------------
-- Signature block: the date line, then the signer's lines from 3.25 in, kept on one page
-- ---------------------------------------------------------------------------

local function signature(out)
  local sig = RAW.signature or {}
  local lines = list(sig.lines)
  out[#out + 1] = line(sig.date or "", { before = SIG_ABOVE, keep = #lines > 0 })
  for i, l in ipairs(lines) do
    out[#out + 1] = line(l, { before = i == 1 and DATE_GAP or 0, left = SIG, keep = i < #lines })
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
