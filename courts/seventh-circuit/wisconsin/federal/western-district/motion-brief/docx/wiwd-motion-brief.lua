-- W.D. Wis. brief in support of a motion, docx engine (docs/DOCX.md). The brief as Word paragraphs, so that it reads
-- and breaks as typst/wiwd-motion-brief.typ does: the court title, the caption (the party column ruled at its right and
-- foot, the case number beside it), the title, unnumbered body paragraphs, headings, lettered lists and the signature
-- block in the right half of the page. Every case-specific word comes from the sample's frontmatter and body, never
-- from this file. Font, margins and the page number are in docx/reference.xml (fb render builds the reference
-- document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local ITEM = 1296                        -- typst para-indent + item-box: a list item's text, 0.9 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4608                    -- typst caption-left, 3.2 in
local CAP_GUTTER = 288                   -- typst caption-gutter, 0.2 in
local CAP_PAD_RIGHT = 185                -- typst caption-pad-right, 10 pt (200 twips), less the 0.75 pt rule Word sets inside it
local CAP_PAD_BOTTOM = 145               -- typst caption-pad-bottom, 8 pt (160 twips), less the rule
local CAP_RIGHT_PAD = 144                -- typst caption-right-pad, 0.1 in
local SIG_LEFT, SIG_W = 3960, 5040       -- typst sig-left 2.75 in, sig-width 3.5 in
local COVER_GAP, TITLE_BELOW = 276, 480  -- typst cover-gap, title-below
local SIG_ABOVE, SIG_GAP = 480, 480      -- typst sig-above, sig-gap

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- The items of a metadata list (or of a single metadata value).
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

-- A doubled sign stays with its number ("§§ 1981"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- No break at the space before a period ("exception . . . [and]"): Unicode line breaking, which typst follows,
-- never breaks before a full stop, even after a space; LibreOffice does.
local function bind_stops(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Space" and b.t == "Str" and b.text:match("^%.") then inl[i] = pandoc.Str("\u{00A0}") end
  end
  return inl
end

local function fix(inl)
  return bind_stops(bind_doubled(pandoc.Inlines(inl):walk({ Str = breaks })))
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(a)" or "A." lists).
local function md(s)
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return fix(pandoc.utils.blocks_to_inlines(doc.blocks))
end

-- A metadata value (or a string) as Word runs.
local function meta_runs(v, o)
  if type(v) == "string" then return xe.runs(v, o) end
  return xe.inl(fix(v), o)
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

local function mar(bottom, right)
  return '<w:tcMar><w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. (right or 0) ..
    '" w:type="dxa"/></w:tcMar>'
end

local function caption(m)
  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(meta_runs(n)) end
    left[#left + 1] = p(meta_runs(party.designation))
  end
  local right = { p(xe.runs("Case No. " .. plain(m.case_number)), { left = CAP_RIGHT_PAD }) }
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, RULES .. mar(CAP_PAD_BOTTOM, CAP_PAD_RIGHT), left) ..
    cell(CAP_GUTTER, "", { p("") }) ..
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, mar(CAP_PAD_BOTTOM), right) .. '</w:tr></w:tbl>'
end

local function cover(m, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE WESTERN DISTRICT OF WISCONSIN", { b = true }), { jc = "center" })
  out[#out + 1] = p("", { line = COVER_GAP })
  out[#out + 1] = caption(m)
  out[#out + 1] = p(meta_runs(m.brief_title, { b = true }), { before = COVER_GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Signature: single lines in the right half of the page, kept together
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local s = m.signature
  local ls = {}
  for _, l in ipairs(items(s.preamble)) do ls[#ls + 1] = { meta_runs(l), 0 } end
  ls[#ls + 1] = { xe.runs("/s/ " .. plain(s.signer)), #ls > 0 and SIG_GAP or 0 }
  ls[#ls + 1] = { meta_runs(s.signer), 0 }
  for _, l in ipairs(items(s.lines)) do ls[#ls + 1] = { meta_runs(l), 0 } end
  ls[1][2] = SIG_ABOVE
  for i, l in ipairs(ls) do
    out[#out + 1] = p(l[1], { before = l[2], keep = i < #ls, left = SIG_LEFT, right = TEXTW - SIG_LEFT - SIG_W })
  end
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's brief-body()
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

-- Headings at the type size on the body pitch, kept with the text: level 1 centered bold capitals with half a
-- double line above, level 2 centered bold, level 3 bold italic at the margin.
-- Headings at the type size on the body pitch with no space of their own, kept with the text: level 1 centered bold
-- capitals, level 2 centered bold, level 3 bold italic at the margin.
-- Headings at the type size on the body pitch with no space of their own, kept with the text: level 1 centered bold
-- capitals, level 2 bold at the margin, level 3 bold italic at the margin.
local function heading(lvl, text, before)
  local inl = md(text)
  if lvl == 1 then
    inl = inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  lvl = math.min(lvl, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(before, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(inl, { b = true, i = lvl == 3 }))
end

local function body(out)
  local before = TITLE_BELOW
  for _, t in ipairs(chunks()) do
    if t:sub(1, 1) == "#" then
      local hashes, text = t:match("^(#+)%s+(.-)%s*$")
      out[#out + 1] = heading(#hashes, text, before)
    elseif t:match("^%d+%.[ \t]") or t:match("^[-*+][ \t]") then
      -- "1." items lettered a., b., ..., "-" items bulleted; the label at the indent, the text at 0.9 in
      local lettered = t:match("^%d") ~= nil
      local list = {}
      for line in (t .. "\n"):gmatch("(.-)\n") do
        local item = line:match("^%d+%.[ \t]+(.*)$") or line:match("^[-*+][ \t]+(.*)$")
        if item then list[#list + 1] = item else list[#list] = list[#list] .. "\n" .. line end
      end
      for i, item in ipairs(list) do
        local label = lettered and (string.char(96 + i) .. ".") or "\u{2022}"
        out[#out + 1] = p(xe.runs(label .. "\t") .. xe.inl(md(item)),
          { line = BODY, left = ITEM, hanging = ITEM - INDENT, tab = ITEM, before = i == 1 and before or 0 })
      end
    else
      out[#out + 1] = p(xe.inl(md(t)), { line = BODY, first = INDENT, before = before })
    end
    before = 0
  end
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  cover(m, out)
  body(out)
  signature(m, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
