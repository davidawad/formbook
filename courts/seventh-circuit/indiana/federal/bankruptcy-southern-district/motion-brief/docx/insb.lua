-- S.D. Ind. bankruptcy motion, docx engine (docs/DOCX.md). The motion as Word paragraphs, so that it reads and
-- breaks as typst/insb-motion-brief.typ does: the court title, the bankruptcy caption (a table row, the party column
-- ruled at its right and foot), the title (B-9013-1(a)), the argument (unnumbered paragraphs, headings, block
-- quotations, citation lines flush left), the date line and signature, and the certificate of service (B-9013-2) on a
-- page of its own. Every case word comes from the sample's frontmatter and body, never from this file. Font, margins
-- and the page number are in docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines set the same paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_GUTTER = 288                   -- typst caption-gutter, 0.2 in
local CAP_PAD_RIGHT = 185                -- typst caption-pad-right, 10 pt (200 twips), less the 0.75 pt rule Word sets inside it
local CAP_PAD_BOTTOM = 145               -- typst caption-pad-bottom, 8 pt (160 twips), less the rule
local CAP_RIGHT_PAD = 144                -- typst caption-right-pad, 0.1 in
local QUOTE_LEFT, QUOTE_RIGHT = 1440, 720 -- typst quote-left, quote-right
local SIG = 4320                         -- typst sig-left, 3 in
local COVER_GAP = 552                    -- typst cover-gap
local HEADING_GAP, QUOTE_GAP = 276, 276  -- typst heading-gap, quote-gap
local SIG_GAP = 276                      -- typst sig-gap

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

-- A paragraph: o = { before, after, line, left, right, first, jc, keep, brk }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Single lines, one per item, from `left`; an empty item is a blank line (typst: slines). o.keep: each kept with
-- the next (the last too, when o.keep_last).
local function lines(list, left, o)
  o = o or {}
  local out = {}
  for i, l in ipairs(list) do
    local keep = o.keep and (i < #list or o.keep_last)
    out[#out + 1] = p(plain(l) == "" and "" or xe.inl(type(l) == "string" and l or fix(l)),
      { left = left, keep = keep, before = i == 1 and o.before or 0 })
  end
  return out
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

local function caption(left, right)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, RULES .. mar(CAP_PAD_BOTTOM, CAP_PAD_RIGHT), lines(left, 0)) ..
    cell(CAP_GUTTER, "", { p("") }) ..
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, mar(CAP_PAD_BOTTOM), lines(right, CAP_RIGHT_PAD)) .. '</w:tr></w:tbl>'
end

local function cover(m, out)
  local title = { "UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF INDIANA" }
  if m.division ~= nil and plain(m.division) ~= "" then
    title[#title + 1] = pandoc.text.upper(plain(m.division)) .. " DIVISION"
  end
  for _, t in ipairs(title) do out[#out + 1] = p(xe.runs(t, { b = true }), { jc = "center" }) end
  out[#out + 1] = p("", { line = COVER_GAP })
  local left = { "In re:", "" }
  for _, n in ipairs(items(m.debtor.names)) do left[#left + 1] = n end
  left[#left + 1] = m.debtor.designation
  out[#out + 1] = caption(left, { "Case No. " .. plain(m.case_number), "Chapter " .. plain(m.chapter) })
  out[#out + 1] = p(xe.inl(fix(m.title), { b = true }),
    { before = COVER_GAP, after = COVER_GAP, line = BODY, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's argument()
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

-- Headings at the type size on the body pitch, half a double line above and below, kept with the text: level 1
-- centered bold capitals, level 2 bold at the margin.
local function heading(t)
  local hashes, text = t:match("^(#+)%s+(.-)%s*$")
  local lvl = math.min(#hashes, 2)
  local inl = md(text)
  if lvl == 1 then
    inl = inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(HEADING_GAP, HEADING_GAP, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(inl, { b = true }))
end

local function body(out)
  local cs = chunks()
  for i, t in ipairs(cs) do
    -- the last chunk is kept with the signature after it
    local last = i == #cs
    if t:sub(1, 1) == "#" then
      out[#out + 1] = heading(t)
    elseif t:sub(1, 1) == ">" then
      local q = t:gsub("\n>[ \t]?", "\n"):gsub("^>[ \t]?", "")
      for para in (q .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
        para = para:match("^%s*(.-)%s*$")
        if para ~= "" then
          out[#out + 1] = p(xe.inl(md(para)), { before = QUOTE_GAP, after = QUOTE_GAP, left = QUOTE_LEFT,
            right = QUOTE_RIGHT })
        end
      end
    elseif t:match("^Id%.") or t:match("^%d") then
      out[#out + 1] = p(xe.inl(md(t)), { line = BODY, keep = last })
    else
      out[#out + 1] = p(xe.inl(md(t)), { line = BODY, first = INDENT, keep = last })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature and certificate
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local sig = m.signature
  if m.date_line ~= nil then
    out[#out + 1] = p(xe.inl(fix(m.date_line)), { line = BODY, first = INDENT, keep = true })
  end
  local ls = { "/s/ " .. plain(sig.signer), plain(sig.signer) }
  for _, l in ipairs(items(sig.lines)) do ls[#ls + 1] = l end
  for _, x in ipairs(lines(ls, SIG, { keep = true, before = SIG_GAP })) do out[#out + 1] = x end
end

local function certificate(m, out)
  local c = m.certificate
  if c == nil then return end
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", brk = true })
  out[#out + 1] = p(xe.inl(fix(c.text)), { before = COVER_GAP, line = BODY, first = INDENT })
  local ls = { "/s/ " .. plain(c.signer) }
  for _, l in ipairs(items(c.lines)) do ls[#ls + 1] = l end
  for _, x in ipairs(lines(ls, SIG, { before = COVER_GAP })) do out[#out + 1] = x end
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  cover(m, out)
  body(out)
  signature(m, out)
  certificate(m, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
