-- S.D. Ind. brief in support of a motion, docx engine (docs/DOCX.md). The brief as Word paragraphs, so that it reads
-- and breaks as typst/insd-motion-brief.typ does: the court title, the caption (party lines, a column of ")" marks,
-- the case number), the title (and a jury demand), the body chunks (headings, paragraphs, lists, quotations) and the
-- signature block. Every case-specific word comes from the sample's frontmatter and body, never from this file.
-- Font, margins and the page number are in docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between two
-- newlines in a row; its first characters say what it is).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local NUMBERED = false                   -- typst numbered: briefs are not numbered
local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LABEL = 1440                       -- typst para-indent + number-box, 1 in
local TEXTW = 9360                       -- 6.5 in
local PARTY, PAREN = 4896, 432           -- typst caption-party-w 3.4 in, caption-paren-w 0.3 in
local QUOTE = 720                        -- typst quote-inset
local SIG = 4680                         -- typst sig-indent, 3.25 in
local COVER_GAP, TITLE_ABOVE, JURY_ABOVE = 480, 360, 120 -- typst cover-gap, title-above, jury-above
local HEADING_ABOVE = 240                -- typst heading-above
local SIG_ABOVE, SIG_GAP = 480, 240      -- typst sig-above, sig-gap

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- The items of a frontmatter list (or of a single value).
local function items(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

-- The sample's frontmatter as written ($FORMBOOK_META, fb render): the caption keeps its leading spaces, which
-- pandoc's metadata reader drops.
local function frontmatter()
  local f = assert(io.open(assert(os.getenv("FORMBOOK_META"), "FORMBOOK_META is not set (render with fb render)"), "r"))
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("¶¶ 37"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
-- The number after a sign is not broken either ("§§ 26:1–26:19": typst boxes the whole token, LibreOffice would
-- break after the dash): a word joiner after each dash or slash in it.
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b, c = inl[i], inl[i + 1], inl[i + 2]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      if a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") then inl[i + 1] = pandoc.Str("\u{00A0}") end
      if c and c.t == "Str" then
        inl[i + 2] = pandoc.Str((c.text:gsub("\u{200B}", ""):gsub("\u{2013}", "\u{2013}\u{2060}")
          :gsub("\u{2014}", "\u{2014}\u{2060}"):gsub("/", "/\u{2060}")))
      end
    end
  end
  return inl
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(a)" or "A." lists).
local function md(s)
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return bind_doubled(pandoc.Inlines(pandoc.utils.blocks_to_inlines(doc.blocks)):walk({ Str = breaks }))
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

-- A single line set as written (the caption's leading spaces stay); "" is a blank line.
local function sline(s, o)
  s = plain(s)
  return p(s == "" and "" or xe.runs(s), o)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local function cell(w, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function caption(m)
  local left, right, parens = {}, {}, {}
  for _, l in ipairs(items(m.caption.left)) do left[#left + 1] = sline(l) end
  for _, l in ipairs(items(m.caption.right)) do right[#right + 1] = sline(l) end
  for _ = 1, math.max(#left, #right) do parens[#parens + 1] = sline(")") end
  if #left == 0 then left[1] = p("") end
  if #right == 0 then right[1] = p("") end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    PARTY .. '"/><w:gridCol w:w="' .. PAREN .. '"/><w:gridCol w:w="' .. (TEXTW - PARTY - PAREN) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(PARTY, left) .. cell(PAREN, parens) .. cell(TEXTW - PARTY - PAREN, right) .. '</w:tr></w:tbl>'
end

local function cover(m, out)
  for _, l in ipairs(items(m.court)) do out[#out + 1] = p(xe.runs(plain(l), { b = true }), { jc = "center" }) end
  out[#out + 1] = p("", { line = COVER_GAP })
  out[#out + 1] = caption(m)
  local jury = m.jury_demand == true
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(m.title)), { b = true }),
    { before = TITLE_ABOVE, after = jury and 0 or COVER_GAP, jc = "center" })
  if jury then
    out[#out + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }),
      { before = JURY_ABOVE, after = COVER_GAP, jc = "center" })
  end
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's chunk()
-- ---------------------------------------------------------------------------

-- The sample's body: the text after its frontmatter, split where typst splits it (two newlines in a row).
local function chunks()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local body = src:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1)
  local out = {}
  local pos = 1
  while true do
    local s = body:find("\n\n", pos, true)
    local c = body:sub(pos, (s or #body + 1) - 1):match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
    if not s then break end
    pos = s + 2
  end
  return out
end

-- A heading: single-spaced, bold, kept with the text after it.
local function heading(s, jc)
  return p(xe.inl(md(s), { b = true }), { before = HEADING_ABOVE, jc = jc, keep = true })
end

local function body(out)
  local seen, n = false, 0
  for _, t in ipairs(chunks()) do
    if t:sub(1, 1) == "#" then seen = true end
    local list = t:match("^%- ") or t:match("^%d+%. ")
    local para = seen and t:sub(1, 1) ~= "#" and not list and t:sub(1, 1) ~= ">" and not t:match("^WHEREFORE")
    if t:match("^### ") then
      out[#out + 1] = heading(t:sub(5), "left")
    elseif t:match("^## ") then
      out[#out + 1] = heading(t:sub(4), "center")
    elseif t:match("^# ") then
      out[#out + 1] = heading(pandoc.text.upper(t:sub(3)), "center")
    elseif list then
      local its = {}
      for line in (t .. "\n"):gmatch("(.-)\n") do
        local rest = line:match("^%d+%.[ \t]+(.*)$") or line:match("^%-[ \t]+(.*)$")
        if rest then its[#its + 1] = rest elseif #its > 0 then its[#its] = its[#its] .. "\n" .. line end
      end
      for k, item in ipairs(its) do
        local label = t:match("^%- ") and "\u{2022}" or (k .. ".")
        out[#out + 1] = p(xe.runs(label .. "\t") .. xe.inl(md(item)),
          { line = BODY, left = LABEL, hanging = LABEL - INDENT, tab = LABEL })
      end
    elseif t:sub(1, 1) == ">" then
      local q = t:gsub("\n>[ \t]?", "\n"):gsub("^>[ \t]?", "")
      out[#out + 1] = p(xe.inl(md(q)), { left = QUOTE, right = QUOTE })
    elseif para and NUMBERED then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(md(t)), { line = BODY, first = INDENT, tab = LABEL })
    else
      out[#out + 1] = p(xe.inl(md(t)), { line = BODY, first = INDENT })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block (L.R. 5-1(b)): the date, then the signature lines from 3.25 in, kept on one page
-- ---------------------------------------------------------------------------

local function signature(sig, out)
  local ls = items(sig.lines)
  out[#out + 1] = sline(sig.date, { before = SIG_ABOVE, keep = #ls > 0 })
  for i, l in ipairs(ls) do
    out[#out + 1] = sline(l, { before = i == 1 and SIG_GAP or 0, left = SIG, keep = i < #ls })
  end
end

function Pandoc(doc)
  local m = frontmatter()
  local out = {}
  cover(m, out)
  body(out)
  signature(m.signature, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
