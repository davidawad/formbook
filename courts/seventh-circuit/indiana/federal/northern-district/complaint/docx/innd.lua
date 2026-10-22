-- N.D. Ind. complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it reads and breaks as
-- typst/innd-complaint.typ does: the court title, the caption (a table row, the party column ruled at its right and
-- foot; beside it the case number and the jury demand), the title, numbered paragraphs (counted here, Fed. R. Civ.
-- P. 10(b)), unnumbered lead-ins ("^ "), lettered prayer items ("A. "), lists lettered "a.", headings, block
-- quotations, footnotes and the signature block. Every case-specific word comes from the sample's frontmatter and
-- body, never from this file. Font, margins and the page number are in docx/reference.xml (fb render builds the
-- reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines number and label the same paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUMBER = 1440                      -- typst para-indent + number-box (list-label): the text after a label, 1 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4608                    -- typst caption-left, 3.2 in
local CAP_GUTTER = 432                   -- typst caption-gutter, 0.3 in
local CAP_PAD_RIGHT = 158                -- typst caption-pad-right, 0.12 in (173 twips), less the 0.75 pt rule Word sets inside it
local CAP_PAD_BOTTOM = 129               -- typst caption-pad-bottom, 0.1 in (144 twips), less the rule
local DESIGNATION = 1728                 -- typst designation-indent, 1.2 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local SIG = 4608                         -- typst sig-col, 3.2 in
local PARA_GAP = 396                     -- typst para-gap, 19.8 pt
local COVER_GAP, HEADING_ABOVE, QUOTE_GAP = 552, 552, 552 -- typst cover-gap, heading-above, quote-gap
local SIG_ABOVE, SIG_GAP = 552, 552      -- typst sig-above, sig-gap

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

-- A doubled sign stays with its number ("§§ 1332"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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

-- The footnote definitions of the sample ("[^n]: text" chunks), appended to every chunk read, so a chunk's
-- references become pandoc notes.
local NOTES = ""

-- Markdown text as inlines, read as typst's cmarker reads it (no "(a)" or "A." lists).
local function md(s)
  local doc = pandoc.read(s .. NOTES, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return fix(pandoc.utils.blocks_to_inlines(doc.blocks))
end

local function has_note(inl)
  local found = false
  pandoc.Inlines(inl):walk({ Note = function() found = true end })
  return found
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- A body paragraph whose text is pandoc inlines: raw Word XML, or (when it carries a footnote, which only pandoc
-- writes) a native paragraph in a style that has the same spacing ("Body Note": docx/reference.xml).
local function body_par(label, inl, o)
  if has_note(inl) then
    local il = pandoc.Inlines({})
    if label then
      il:insert(pandoc.Str(label))
      il:insert(pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
    end
    il:extend(xe.inlines(inl))
    return pandoc.Div({ pandoc.Para(il) }, { ["custom-style"] = o.note_style })
  end
  return xe.raw(p((label and xe.runs(label .. "\t") or "") .. xe.inl(inl), o))
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
    if k > 1 then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("v."))
      left[#left + 1] = p("")
    end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(xe.inl(fix(n))) end
    left[#left + 1] = p(xe.inl(fix(party.designation)), { left = DESIGNATION })
  end
  local right = { p(xe.runs("Case No.: " .. plain(m.case_number))) }
  if m.jury_demand then right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = SINGLE }) end
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
  local title = {}
  for _, t in ipairs(items(m.court)) do title[#title + 1] = plain(t) end
  if m.division ~= nil then title[#title + 1] = pandoc.text.upper(plain(m.division)) end
  for _, t in ipairs(title) do out[#out + 1] = xe.raw(p(xe.runs(t, { b = true }), { jc = "center" })) end
  out[#out + 1] = xe.raw(p("", { line = COVER_GAP }))
  out[#out + 1] = xe.raw(caption(m))
  out[#out + 1] = xe.raw(p(xe.runs(pandoc.text.upper(plain(m.title)), { b = true }),
    { before = COVER_GAP, after = COVER_GAP, jc = "center" }))
end

-- ---------------------------------------------------------------------------
-- Signature: "Dated:" in the first column, the first line beside it (a tab to the hanging indent), the rest under it
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local sig = m.signature
  local ls = { { "Respectfully submitted,", 0 } }
  local gap = SIG_GAP
  if sig.party ~= nil then
    ls[#ls + 1] = { pandoc.text.upper(plain(sig.party)), gap }
    gap = SINGLE
  end
  ls[#ls + 1] = { "By: " .. plain(sig.by), gap }
  if sig.role ~= nil then ls[#ls + 1] = { plain(sig.role), 0 } end
  for k, c in ipairs(items(sig.counsel)) do ls[#ls + 1] = { plain(c), k == 1 and SIG_GAP or 0 } end
  for i, l in ipairs(ls) do
    local keep = i < #ls
    if i == 1 then
      out[#out + 1] = xe.raw(p(xe.runs("Dated: " .. plain(sig.dated) .. "\t") .. xe.inl(md(l[1])),
        { before = SIG_ABOVE, left = SIG, hanging = SIG, tab = SIG, keep = keep }))
    else
      out[#out + 1] = xe.raw(p(xe.inl(md(l[1])), { before = l[2], left = SIG, keep = keep }))
    end
  end
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's body-blocks()
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

-- Headings at the type size on the body pitch, kept with the text: level 1 centered bold capitals, level 2
-- centered bold, level 3 bold at the margin.
local function heading(t)
  local hashes, text = t:match("^(#+)%s+(.-)%s*$")
  local lvl = math.min(#hashes, 3)
  local inl = md(text)
  if lvl == 1 then
    inl = inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(HEADING_ABOVE, PARA_GAP, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(inl, { b = true }))
end

local function body(out)
  local all, cs = chunks(), {}
  local defs = {}
  for _, c in ipairs(all) do
    if c:match("^%[%^") then defs[#defs + 1] = c else cs[#cs + 1] = c end
  end
  if #defs > 0 then NOTES = "\n\n" .. table.concat(defs, "\n\n") end
  local n = 0
  for i, t in ipairs(cs) do
    local last = i == #cs
    local o = { line = BODY, first = INDENT, after = PARA_GAP, keep = last, note_style = "Body Note" }
    if t:sub(1, 1) == "#" then
      out[#out + 1] = xe.raw(heading(t))
    elseif t:match("^%d+%.[ \t]") or t:match("^[-*+][ \t]") then
      -- a list: each item lettered a., b., ... at the indent, its lines hanging at 1 in
      local its = {}
      for line in (t .. "\n"):gmatch("(.-)\n") do
        local rest = line:match("^%d+%.[ \t]+(.*)$") or line:match("^[-*+][ \t]+(.*)$")
        if rest then its[#its + 1] = rest elseif #its > 0 then its[#its] = its[#its] .. "\n" .. line end
      end
      for k, item in ipairs(its) do
        out[#out + 1] = body_par(string.char(96 + k) .. ".", md(item),
          { line = BODY, left = NUMBER, hanging = NUMBER - INDENT, tab = NUMBER, after = PARA_GAP,
            note_style = "List Note" })
      end
    elseif t:sub(1, 1) == ">" then
      local q = t:gsub("\n>[ \t]?", "\n"):gsub("^>[ \t]?", "")
      out[#out + 1] = body_par(nil, md(q), { before = QUOTE_GAP, after = QUOTE_GAP, left = QUOTE, right = QUOTE,
        note_style = "Block Text" })
    elseif t:match("^%^ ") then
      out[#out + 1] = body_par(nil, md(t:sub(3)), o)
    elseif t:match("^%u%.[ \t]") then
      local letter, rest = t:match("^(%u%.)[ \t]+(.*)$")
      o.tab = NUMBER
      out[#out + 1] = body_par(letter, md(rest), o)
    else
      n = n + 1
      o.tab = NUMBER
      out[#out + 1] = body_par(n .. ".", md(t), o)
    end
  end
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  cover(m, out)
  body(out)
  signature(m, out)
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
