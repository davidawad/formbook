-- E.D. Okla. motion with brief in support, docx engine (docs/DOCX.md). The paper as Word paragraphs, so that it reads
-- and breaks as typst/oked-motion-brief.typ does: the court title, the boxed caption (party box, the case number and
-- judge at the right), the title (LCvR 7.1(b)), the body (paragraphs numbered only where marked "<!--numbered-->",
-- headings labelled "I." and "A." here, block quotations, footnotes at 12 pt, LCvR 5.2(a)), the date and the
-- signature block, and the certificate of service on a new page with its own signature. Every case-specific word
-- comes from the sample's frontmatter (read as written, $FORMBOOK_META) and body, never from this file. Font,
-- margins, the page number and the footnote style are in docx/reference.xml (fb render builds the reference).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is); a paragraph that refers to a footnote stays a pandoc paragraph (Body
-- Text, Body Text Keep), so that pandoc writes the note; they print 1 to 4 as in typst (the shell port before it came
-- out of LibreOffice with 1, 1, 2, 3: DEF-CONT-001).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line or a footnote
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LABEL = 1440                       -- typst para-indent + number-width: a numbered paragraph's text, 1 in
local TEXTW = 9360                       -- 6.5 in
local CAP_BOX, CAP_GUTTER = 5040, 432    -- typst caption-box-width 3.5 in, caption-gutter 0.3 in
local CAP_RULE = 15                      -- typst caption-rule, 0.75 pt (Word sets the rule inside the cell margin)
local CAP_X, CAP_Y = 144 - CAP_RULE, 173 - CAP_RULE -- typst caption-inset-x 0.1 in, caption-inset-y 0.12 in
local CAP_VERSUS, CAP_DESIG = 1584, 2736 -- typst caption-versus 1.1 in, caption-designation 1.9 in
local HEADING_TAB = 720                  -- typst heading-tab, 0.5 in
local QUOTE_LEFT, QUOTE_RIGHT = 1440, 720 -- typst quote-left 1 in, quote-right 0.5 in
local SIG = 4320                         -- typst sig-left, 3 in
local COURT_GAP, TITLE_ABOVE, TITLE_BELOW = 480, 480, 240 -- typst court-gap, title-above, title-below
local HEADING_ABOVE, QUOTE_GAP = 240, 240 -- typst heading-above, quote-gap
local SIG_ABOVE, SIG_GAP = 480, 240      -- typst sig-above, sig-gap
local NUMBERED = "<!--numbered-->"
local CERT = "CERTIFICATE OF SERVICE"
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV",
  "XVI", "XVII", "XVIII", "XIX", "XX" }

local function read_file(path)
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (fb render's $FORMBOOK_META), for the strings typst reads as markdown.
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

local function has_note(inl)
  local found = false
  pandoc.Inlines(inl):walk({ Note = function() found = true end })
  return found
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, lines, brk, tab }; single pitch by
-- default. Every paragraph stands 1 twip (0.05 pt) in from the right margin: LibreOffice decides a line in whole
-- twips and kept a word on a line that ran 0.04 pt past the measure, where typst wraps it (docs/EVAL-LOOP.md, "A line
-- typst fills to within a few hundredths of a point"); with the twip every line breaks as in typst.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, (o.right or 0) + 1)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function rule(side)
  return '<w:' .. side .. ' w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
end

local BOX = '<w:tcBorders>' .. rule("top") .. rule("left") .. rule("bottom") .. rule("right") .. '</w:tcBorders>' ..
  '<w:tcMar><w:top w:w="' .. CAP_Y .. '" w:type="dxa"/><w:left w:w="' .. CAP_X .. '" w:type="dxa"/>' ..
  '<w:bottom w:w="' .. CAP_Y .. '" w:type="dxa"/><w:right w:w="' .. CAP_X .. '" w:type="dxa"/></w:tcMar>'

-- the right column starts where the box's text does: typst pads it by caption-inset-y
local RIGHT = '<w:tcMar><w:top w:w="' .. (CAP_Y + CAP_RULE) .. '" w:type="dxa"/></w:tcMar>'

local function caption()
  local c = RAW.caption or {}
  local l = {}
  local function side(parties)
    for _, party in ipairs(list(parties)) do
      for _, s in ipairs(list(party.names)) do l[#l + 1] = p(xe.inl(md(s))) end
      if party.designation then l[#l + 1] = p(xe.inl(md(party.designation), { i = true }), { left = CAP_DESIG }) end
    end
  end
  side(c.plaintiffs)
  l[#l + 1] = p("")
  l[#l + 1] = p(xe.runs("v."), { left = CAP_VERSUS })
  l[#l + 1] = p("")
  side(c.defendants)
  -- typst: the case number and the judge two single lines below the top of the box
  local r = { p(""), p(""), p(xe.runs("Case No. " .. tostring(RAW.case_number or ""))) }
  if RAW.judge then r[#r + 1] = p(xe.inl(md(RAW.judge))) end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_BOX .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_BOX - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_BOX, BOX, l) .. cell(CAP_GUTTER, "", { p("") }) .. cell(TEXTW - CAP_BOX - CAP_GUTTER, RIGHT, r) ..
    '</w:tr></w:tbl>'
end

local function cover(out)
  for _, s in ipairs(list(RAW.court)) do
    out[#out + 1] = xe.raw(p(xe.inl(upper(md(s)), { b = true }), { jc = "center" }))
  end
  out[#out + 1] = xe.raw(p("", { line = COURT_GAP }))
  out[#out + 1] = xe.raw(caption())
  out[#out + 1] = xe.raw(p(xe.inl(upper(md(RAW.brief_title or "")), { b = true }),
    { before = TITLE_ABOVE, after = TITLE_BELOW, jc = "center" }))
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's body()
-- ---------------------------------------------------------------------------

-- The sample's body: the text after its frontmatter.
local function source()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  return (src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1))
end

-- The chunks of a body (split at blank lines), without the footnote definitions.
local function chunks_of(s)
  local out = {}
  for c in (s .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" and not c:match("^%[%^[^%]]+%]:") then out[#out + 1] = c end
  end
  return out
end

-- A body paragraph on the body pitch, its first line indented; a number and a tab to 1 in. One that carries a
-- footnote is left to pandoc (Body Text: the same pitch and indent; Body Text Keep kept with the signature), which
-- writes the note.
local function bodypar(label, inl, keep, out)
  if has_note(inl) then
    local c = pandoc.Inlines({})
    if label then c:extend({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }) end
    c:extend(xe.inlines(inl))
    out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, { ["custom-style"] = keep and "Body Text Keep" or "Body Text" })
  elseif label then
    out[#out + 1] = xe.raw(p(xe.runs(label .. "\t") .. xe.inl(inl), { line = BODY, first = INDENT, tab = LABEL,
      keep = keep }))
  else
    out[#out + 1] = xe.raw(p(xe.inl(inl), { line = BODY, first = INDENT, keep = keep }))
  end
end

-- One body (typst body()): st = { n, h2, h3 } the counters, notes the footnote texts by id.
local function body(cs, notes, keep_last, st, out)
  for i, t in ipairs(cs) do
    local last = keep_last and i == #cs
    local defs = ""
    for id in t:gmatch("%[%^([^%]]+)%]") do defs = defs .. "\n\n[^" .. id .. "]: " .. (notes[id] or "") end
    local hashes, htext = t:match("^(#+)[ \t]+(.*)$")
    if hashes then
      -- single-spaced, kept with the text after it; level 1 centered bold capitals, 2 "I." and 3 "A." hanging
      local inl, lvl = md(htext .. defs), #hashes
      if lvl == 1 then
        out[#out + 1] = xe.raw(p(xe.inl(upper(inl), { b = true }), { before = HEADING_ABOVE, jc = "center", keep = true }))
      else
        local label, left
        if lvl == 2 then
          st.h2, st.h3, left = st.h2 + 1, 0, 0
          label = (ROMAN[st.h2] or tostring(st.h2)) .. "."
        else
          st.h3, left = st.h3 + 1, HEADING_TAB
          label = string.char(64 + st.h3) .. "."
        end
        out[#out + 1] = xe.raw(p(xe.runs(label .. "\t") .. xe.inl(inl, { b = true }), { before = HEADING_ABOVE,
          left = left + HEADING_TAB, hanging = HEADING_TAB, tab = left + HEADING_TAB, keep = true }))
      end
    elseif t:sub(1, 1) == ">" then
      -- single-spaced (LCvR 5.2(a) excepts blocked quotations), indented, not split (typst breakable: false)
      local q = t:gsub("\n>[ \t]?", "\n"):gsub("^>[ \t]?", "")
      out[#out + 1] = xe.raw(p(xe.inl(md(q .. defs)), { before = QUOTE_GAP, after = QUOTE_GAP, left = QUOTE_LEFT,
        right = QUOTE_RIGHT, keep = last, lines = true }))
    elseif t:sub(1, #NUMBERED) == NUMBERED then
      st.n = st.n + 1
      bodypar(st.n .. ".", md(t:sub(#NUMBERED + 1):match("^%s*(.-)$") .. defs), last, out)
    else
      bodypar(nil, md(t .. defs), last, out)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block: the date at the left, "Respectfully submitted," and the signer's lines from 3 in; one page
-- ---------------------------------------------------------------------------

local function signature(sig, date, attorneys, out)
  sig = sig or {}
  local ls = { { (date and xe.runs("Date: ") .. xe.inl(md(date)) or "") .. xe.runs("\tRespectfully submitted,"), 0,
    true } }
  ls[#ls + 1] = { xe.inl(md("/s/ " .. tostring(sig.signer or ""))), SIG_GAP }
  for _, l in ipairs(list(sig.lines)) do ls[#ls + 1] = { xe.inl(md(l)), 0 } end
  if attorneys then ls[#ls + 1] = { xe.inl(md(attorneys)), SIG_GAP } end
  for i, l in ipairs(ls) do
    local o = { before = i == 1 and SIG_ABOVE or l[2], left = SIG, keep = i < #ls }
    if l[3] then o.hanging, o.tab = SIG, SIG end
    out[#out + 1] = xe.raw(p(l[1], o))
  end
end

function Pandoc(doc)
  local out = {}
  cover(out)
  local src = source()
  local notes = {}
  for id, text in ("\n" .. src):gmatch("\n%[%^([^%]]+)%]:[ \t]*([^\n]*)") do notes[id] = text end
  -- the body up to the certificate of service, the signature, then the certificate on a new page
  local head, cert = src, nil
  local a, b = src:find("\n# " .. CERT .. "[ \t]*\n")
  if a then head, cert = src:sub(1, a), src:sub(b + 1) end
  local st = { n = 0, h2 = 0, h3 = 0 }
  body(chunks_of(head), notes, true, st, out)
  signature(RAW.signature, RAW.date, RAW.attorneys_for, out)
  if cert then
    out[#out + 1] = xe.raw(p(xe.runs(CERT, { b = true }), { brk = true, after = TITLE_BELOW, jc = "center" }))
    local c = RAW.certificate
    body(chunks_of(cert), notes, c ~= nil, { n = 0, h2 = 0, h3 = 0 }, out)
    if c then signature(c, nil, c.attorneys_for, out) end
  end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
