-- N.D. Okla. motion with brief in support, docx engine (docs/DOCX.md). The paper as Word paragraphs, so that it reads
-- and breaks as typst/oknd-motion-brief.typ does: the court name, the caption (the party column ruled at its right
-- and foot, the case number beside it), the title, the body (paragraphs, headings labelled I., A., 1., a., block
-- quotations, footnotes), the signature block and the certificate of service on its own page. Every case word comes
-- from the sample's frontmatter (read as written, $FORMBOOK_META) and body, never from this file. Font, margins, the
-- page number and the footnote style are in docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is); a paragraph that refers to a footnote stays a pandoc paragraph (in
-- the Body Text style), so that pandoc writes the note.
--
-- BLOCKED here: the tables of contents and authorities (toc_toa: true, LCvR7-1(d)). The typst form builds them; this
-- filter stops with an error rather than omit them silently. Links to authorities (toa:KEY) are plain text.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, the face's own double spacing, never
-- "Exactly 24 pt", LGnR2-4(a); 276 a single line and a footnote line), the spaces between blocks those of the typst
-- template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local TAB = 720                          -- typst heading-tab, 0.5 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local SERVICE = 720                      -- typst service-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_COL = 4680                     -- typst caption columns, 1fr each
local CAP_PAD = 273                      -- typst caption-pad 14.4 pt (288), less the 0.75 pt rule Word sets inside it
local CAP_FOOT = 225                     -- typst caption-foot 12 pt (240), less the rule
local CAP_RIGHT = 288                    -- typst caption-right-pad 14.4 pt
local DESIGNATION = 2592                 -- typst designation-indent, 1.8 in
local SIG = 4752                         -- the text width less typst sig-col (3.2 in): 3.3 in
local COURT_GAP, VERSUS_GAP = 552, 276   -- typst court-gap, versus-gap
local TITLE_ABOVE, TITLE_BELOW = 552, 276 -- typst title-above, title-below
local HEADING_GAP, QUOTE_GAP = 276, 276  -- typst heading-gap, quote-gap
local SIG_ABOVE, SIGNER_ABOVE = 552, 552 -- typst sig-above, signer-above

local function read_file(path)
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (pandoc's metadata would read "____" as emphasis).
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(t, key)
  if t[key] == nil then error("oknd-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return t[key]
end

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

-- A doubled sign stays with its number ("§§ 151-200"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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
  return pandoc.Inlines(inl):walk({ Str = breaks, Inlines = bind_doubled })
end

-- Markdown text as blocks / inlines, read as typst's cmarker reads it (no "(a)" or "A." lists); a link to an
-- authority (toa:KEY) is its text.
local function read(s)
  return pandoc.read(tostring(s), "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS).blocks
end

local function md(s)
  return fix(pandoc.utils.blocks_to_inlines(read(s)))
end

local function upper(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab, brk }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption, title
-- ---------------------------------------------------------------------------

local function caption()
  local sides = need(RAW, "caption")
  local left = {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(list(side.names)) do left[#left + 1] = p(xe.inl(md(n))) end
    left[#left + 1] = p(xe.inl(md(side.designation or "")), { left = DESIGNATION })
    if i < #sides then
      left[#left + 1] = p(xe.runs("v."), { before = VERSUS_GAP, after = VERSUS_GAP, jc = "center" })
    end
  end
  if #left == 0 then left[1] = p("") end
  local rules = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  local right = '<w:tcMar><w:left w:w="' .. CAP_RIGHT .. '" w:type="dxa"/></w:tcMar><w:vAlign w:val="center"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_COL .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_COL) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_COL .. '" w:type="dxa"/>' .. rules .. '</w:tcPr>' .. table.concat(left) ..
    '</w:tc><w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_COL) .. '" w:type="dxa"/>' .. right .. '</w:tcPr>' ..
    p(xe.runs("Case No. " .. tostring(need(RAW, "case_number")))) .. '</w:tc></w:tr></w:tbl>'
end

local function cover(out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT FOR THE", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("NORTHERN DISTRICT OF OKLAHOMA", { b = true }), { jc = "center" })
  out[#out + 1] = p("", { line = COURT_GAP })
  out[#out + 1] = caption()
  out[#out + 1] = p(xe.inl(md(need(RAW, "title")), { b = true }), { before = TITLE_ABOVE, after = TITLE_BELOW,
    jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's brief-body()
-- ---------------------------------------------------------------------------

local function chunks()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out, "\n" .. body
end

local function has_note(inl)
  local found = false
  pandoc.Inlines(inl):walk({ Note = function() found = true end })
  return found
end

-- Heading labels: level 2 is I., II., level 3 A., level 4 1., level 5 a. (typst heading-num); level 1 unnumbered.
local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return s
end

local function alpha(n, base)
  local s = ""
  while n > 0 do
    local r = (n - 1) % 26
    s = string.char(base + r) .. s
    n = (n - 1 - r) // 26
  end
  return s
end

local function label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return alpha(n, 65) .. "." end
  if level == 4 then return n .. "." end
  if level == 5 then return alpha(n, 97) .. "." end
  return ""
end

local counters = { 0, 0, 0, 0, 0, 0 }

-- A heading at the type size on the single pitch, a blank single line above and below, kept with the text: level 1
-- centred bold capitals; deeper levels bold, the label in a 0.5 in box at the level's indent, the lines after the
-- first hanging after the label.
local function heading(t, defs)
  local b = read(t .. defs)[1]
  local lvl = b.level
  counters[lvl] = counters[lvl] + 1
  for k = lvl + 1, #counters do counters[k] = 0 end
  local inl = fix(b.content)
  if lvl == 1 then
    return p(xe.inl(upper(inl), { b = true }), { before = HEADING_GAP, after = HEADING_GAP, jc = "center", keep = true })
  end
  local ind = (lvl - 2) * TAB
  local lab = label(lvl, counters[lvl])
  return p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(inl, { b = true }), { before = HEADING_GAP,
    after = HEADING_GAP, left = ind + TAB, hanging = TAB, tab = ind + TAB, keep = true })
end

-- A body paragraph; one that carries a footnote is left to pandoc (Body Text: the same pitch and indent), which
-- writes the note.
local function bodypar(inl, keep, out)
  if has_note(inl) then
    local c = pandoc.Inlines(inl):walk({ Inlines = function(l) return xe.inlines(l) end })
    out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, { ["custom-style"] = keep and "Body Text Keep" or "Body Text Note" })
  else
    out[#out + 1] = xe.raw(p(xe.inl(inl), { line = BODY, first = INDENT, keep = keep }))
  end
end

local function body(out)
  local cs, src = chunks()
  local notes = {}
  for id, text in src:gmatch("\n%[%^([^%]]+)%]:[ \t]*([^\n]*)") do notes[id] = text end
  local kept = {}
  for _, c in ipairs(cs) do if not c:match("^%[%^[^%]]+%]:") then kept[#kept + 1] = c end end
  for i, t in ipairs(kept) do
    local defs = ""
    for id in t:gmatch("%[%^([^%]]+)%]") do defs = defs .. "\n\n[^" .. id .. "]: " .. (notes[id] or "") end
    local last = i == #kept
    if t:sub(1, 1) == "#" then
      out[#out + 1] = xe.raw(heading(t, defs))
    elseif t:sub(1, 1) == ">" then
      -- block quotation: each paragraph single-spaced, 0.5 in in on both sides, a blank single line above and below
      local q = ("\n" .. t):gsub("\n>[ \t]?", "\n"):sub(2)
      local ps = {}
      for s in (q .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
        s = s:match("^%s*(.-)%s*$")
        if s ~= "" then ps[#ps + 1] = s end
      end
      for k, s in ipairs(ps) do
        out[#out + 1] = xe.raw(p(xe.inl(md(s .. defs)), { before = k == 1 and QUOTE_GAP or 0,
          after = k == #ps and QUOTE_GAP or 0, left = QUOTE, right = QUOTE }))
      end
    else
      bodypar(md(t .. defs), last, out)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

-- Rows of the signature column: { lead at the left margin, text at 3.3 in, space above }; kept on one page.
local function sig_rows(rows, above, out)
  for i, r in ipairs(rows) do
    out[#out + 1] = xe.raw(p(r[1] .. xe.runs("\t") .. r[2], { before = i == 1 and above or r[3], left = SIG,
      hanging = SIG, tab = SIG, keep = i < #rows }))
  end
end

local function signature(out)
  local sig = need(RAW, "signature")
  local rows = { { RAW.date ~= nil and xe.runs("Dated: " .. tostring(RAW.date)) or "", xe.runs("Respectfully submitted,"), 0 },
    { "", xe.inl(md("/s/ " .. tostring(sig.signer or ""))), SIGNER_ABOVE } }
  for _, l in ipairs(list(sig.lines)) do rows[#rows + 1] = { "", xe.inl(md(l)), 0 } end
  sig_rows(rows, SIG_ABOVE, out)
end

-- Certificate of service (FRCP 5(d)(1)(B)); on its own page (typst: certificate-block()).
local function certificate(out)
  local c = RAW.certificate
  out[#out + 1] = xe.raw(p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { after = HEADING_GAP, jc = "center",
    keep = true, brk = true }))
  out[#out + 1] = xe.raw(p(xe.inl(md(need(c, "text"))), { line = BODY, first = INDENT }))
  local svc = list(c.service)
  for k, l in ipairs(svc) do
    out[#out + 1] = xe.raw(p(xe.inl(md(l)), { before = k == 1 and HEADING_GAP or 0, left = SERVICE, keep = k < #svc }))
  end
  local signer = tostring(need(c, "signer"))
  sig_rows({ { "", xe.inl(md("/s/ " .. signer)), 0 }, { "", xe.inl(md(signer)), 0 } }, SIGNER_ABOVE, out)
end

function Pandoc(doc)
  if RAW.toc_toa == true then
    error("oknd-motion-brief: toc_toa: true (indexed TOC and TOA, LCvR7-1(d)) is not built by the docx engine; " ..
      "BLOCKED, see README.md ## Engines", 0)
  end
  local out = {}
  cover(out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  body(res)
  signature(res)
  if RAW.certificate ~= nil then certificate(res) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
