-- wied complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it reads and breaks as
-- typst/wied-complaint.typ does: the court title, the caption (parties left, "v." and the designations indented;
-- the case number and jury legend right; no ruled box), the document title, the lead-in, numbered paragraphs (Fed.
-- R. Civ. P. 10(b), Civil L.R. 10(a)), unnumbered under PRAYER and DEMAND, headings, the lettered prayer and the
-- signature block (General L.R. 5(c)). Every case-specific word comes from the sample's frontmatter and body, never
-- from this file. Font, margins and the page number are in docx/reference.xml (fb render builds the reference
-- document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines number and letter the same paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUMBER = 1440                      -- typst para-indent + number-box: a paragraph's text, 1 in
local LETTER = 1296                      -- typst para-indent + letter-box: a prayer item's text, 0.9 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4680                    -- typst caption-left, 3.25 in
local CAP_GUTTER = 432                   -- typst caption-gutter, 0.3 in
local CAP_RIGHT_PAD = 144                -- typst caption-right-pad, 0.1 in
local VS, DESIGNATION = 1080, 2160       -- typst vs-indent, designation-indent
local SIG = 4320                         -- typst sig-indent, 3.0 in
local COVER_GAP = 480                    -- typst cover-gap
local SECTION_ABOVE, LIST_BELOW = 240, 240 -- typst section-above, list-below
local SIG_ABOVE, SIG_GAP = 480, 276      -- typst sig-above, sig-gap

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

local function fix(inl)
  return bind_doubled(pandoc.Inlines(inl):walk({ Str = breaks }))
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
-- Cover: court title, caption, document title
-- ---------------------------------------------------------------------------

local function cell(w, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function caption(m)
  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { left = VS }) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(meta_runs(n)) end
    left[#left + 1] = p(meta_runs(party.designation), { left = DESIGNATION })
  end
  local num = plain(m.case_number)
  if num == "" then num = "____________" end
  local right = { p(xe.runs("Case No. " .. num), { left = CAP_RIGHT_PAD }) }
  if m.jury_demand == true then right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED"), { left = CAP_RIGHT_PAD }) end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, left) .. cell(CAP_GUTTER, { p("") }) .. cell(TEXTW - CAP_LEFT - CAP_GUTTER, right) ..
    '</w:tr></w:tbl>'
end

local function cover(m, out)
  out[#out + 1] = p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE EASTERN DISTRICT OF WISCONSIN", { b = true }), { jc = "center" })
  out[#out + 1] = p("", { line = COVER_GAP })
  out[#out + 1] = caption(m)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(m.document_title)), { b = true }),
    { before = COVER_GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Signature: "Dated this ...", then the firm, role, signers and contact lines at 3.0 in, kept together
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local s = m.signature
  local ls = { { meta_runs(s.firm), SIG_ABOVE }, { meta_runs(s.role), 0 } }
  for _, sg in ipairs(s.signers) do
    ls[#ls + 1] = { xe.runs("s/ " .. plain(sg.name)), SIG_GAP }
    ls[#ls + 1] = { meta_runs(sg.name), 0 }
    ls[#ls + 1] = { meta_runs(sg.bar), 0 }
  end
  for i, a in ipairs(items(s.address)) do ls[#ls + 1] = { meta_runs(a), i == 1 and SIG_GAP or 0 } end
  ls[#ls + 1] = { xe.runs("Telephone: " .. plain(s.telephone)), 0 }
  for _, sg in ipairs(s.signers) do ls[#ls + 1] = { xe.runs("E-mail: " .. plain(sg.email)), 0 } end
  out[#out + 1] = p(xe.runs("Dated this " .. plain(m.date) .. "."), { before = SIG_ABOVE, keep = true })
  for i, l in ipairs(ls) do
    out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = i < #ls })
  end
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's allegations()
-- ---------------------------------------------------------------------------

-- The sample's body: the text after its frontmatter, split at blank lines.
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
local function heading(lvl, text)
  local inl = md(text)
  if lvl == 1 then
    inl = inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  lvl = math.min(lvl, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(lvl == 1 and SECTION_ABOVE or 0, 0, BODY),
    xe.ind(0, nil, 0), xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(inl, { b = true, i = lvl == 3 }))
end

local function body(out)
  local numbered = true
  local n = 0
  for _, t in ipairs(chunks()) do
    if t:sub(1, 1) == "#" then
      local hashes, text = t:match("^(#+)%s+(.-)%s*$")
      if #hashes == 1 then
        local title = pandoc.text.upper(text)
        numbered = not (title:match("^PRAYER") or title:match("^DEMAND"))
      end
      out[#out + 1] = heading(#hashes, text)
    elseif t:match("^%d+%.[ \t]") then
      -- the prayer, lettered A., B., ...: the letter at the indent, the text hanging at 0.9 in
      local list = {}
      for line in (t .. "\n"):gmatch("(.-)\n") do
        local item = line:match("^%d+%.[ \t]+(.*)$")
        if item then list[#list + 1] = item else list[#list] = list[#list] .. "\n" .. line end
      end
      for i, item in ipairs(list) do
        out[#out + 1] = p(xe.runs(string.char(64 + i) .. ".\t") .. xe.inl(md(item)),
          { line = BODY, left = LETTER, hanging = LETTER - INDENT, tab = LETTER, after = i == #list and LIST_BELOW or 0 })
      end
    elseif numbered then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(md(t)), { line = BODY, first = INDENT, tab = NUMBER })
    else
      out[#out + 1] = p(xe.inl(md(t)), { line = BODY, first = INDENT })
    end
  end
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  cover(m, out)
  if m.lead_in ~= nil then
    out[#out + 1] = p(meta_runs(m.lead_in), { line = BODY, first = INDENT, before = COVER_GAP })
  end
  body(out)
  signature(m, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
