-- W.D. Wash. complaint, docx engine. Mirrors typst/wawd-complaint.typ; rules and conventions are in ../README.md. The
-- cover (judge, court title, the caption: the parties in a ruled column at left, the case number, the title and the
-- notes at right), the headings, the numbered allegations (Fed. R. Civ. P. 10(b)), the unnumbered paragraphs under the
-- prayer and the jury demand, the numbered prayer and the signature block (LCR 10(e)(4)) are built here, and the
-- bottom notation (LCR 10(e)(3): the title and case number with the page number at left, the firm block at right)
-- and the section (FORMBOOK_FOOTERS, FORMBOOK_FINAL). Font, spacing, the numbered paper (header rIdWawdLines) are in
-- docx/reference.xml (fb render builds the reference document from it). Numbers are typed text, as the typst
-- template types them. Content-agnostic: every case-specific word comes from the sample's frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 240 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, HALF = 480, 240, 240   -- typst pitch-body 24 pt, pitch-single 12 pt, half-line 12 pt
local TEXTW = 8640                         -- typst text-width, 6 in
local CAP_LEFT, CAP_GUTTER = 4464, 360     -- typst caption-left 3.1 in, caption-gutter 0.25 in
local CAP_PAD, CAP_FOOT = 200, 160         -- typst caption-pad 10 pt, caption-foot 8 pt
local CAP_INSET = 144                      -- typst caption-inset 0.1 in
local RULE = 15                            -- the caption rule, 0.75 pt (w:sz 6 eighths of a point)
local DROP = 192                           -- typst single-drop 9.6 pt: a single-spaced block's first baseline is a number's
local SIG_LEFT, SIG_GUTTER = 4320, 288     -- typst sig-left 3.0 in, sig-gutter 0.2 in
local NOTATION, FIRM = 240, 210            -- typst notation-pitch 12 pt, firm-pitch 10.5 pt
local FIRST_BLANK = 6                      -- typst first-page-blank: lines 1 to 6 above the court title
local COURT = { "UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF WASHINGTON" }

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
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

-- ---------------------------------------------------------------------------
-- Line count of a caption line (typst measures the caption and rounds it up to whole numbered lines; this computes
-- the same height). Times New Roman's advances in 1/1000 em (the vendored face typst and Word set, without kerning or
-- ligatures: a line's width is the sum of its advances), printable ASCII in code order, then the other characters
-- the samples use; first fit at the spaces, as typst breaks (linebreaks: "simple").
-- ---------------------------------------------------------------------------

local ASCII = {
  regular = { 250, 333.01, 408.2, 500, 500, 833.01, 777.83, 180.18, 333.01, 333.01, 500, 563.96, 250, 333.01, 250,
    277.83, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 277.83, 277.83, 563.96, 563.96, 563.96, 443.85, 920.9,
    722.17, 666.99, 666.99, 722.17, 610.84, 556.15, 722.17, 722.17, 333.01, 389.16, 722.17, 610.84, 889.16, 722.17,
    722.17, 556.15, 722.17, 666.99, 556.15, 610.84, 722.17, 722.17, 943.85, 722.17, 722.17, 610.84, 333.01, 277.83,
    333.01, 469.24, 500, 333.01, 443.85, 500, 443.85, 500, 443.85, 333.01, 500, 500, 277.83, 277.83, 500, 277.83,
    777.83, 500, 500, 500, 500, 333.01, 389.16, 277.83, 500, 500, 722.17, 500, 500, 443.85, 479.98, 200.2, 479.98,
    541.02 },
  bold = { 250, 333.01, 555.18, 500, 500, 1000, 833.01, 277.83, 333.01, 333.01, 500, 569.82, 250, 333.01, 250,
    277.83, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 333.01, 333.01, 569.82, 569.82, 569.82, 500, 930.18,
    722.17, 666.99, 722.17, 722.17, 666.99, 610.84, 777.83, 777.83, 389.16, 500, 777.83, 666.99, 943.85, 722.17,
    777.83, 610.84, 777.83, 722.17, 556.15, 666.99, 722.17, 722.17, 1000, 722.17, 722.17, 666.99, 333.01, 277.83,
    333.01, 581.05, 500, 333.01, 500, 556.15, 443.85, 556.15, 443.85, 333.01, 500, 556.15, 277.83, 333.01, 556.15,
    277.83, 833.01, 556.15, 500, 556.15, 556.15, 443.85, 389.16, 333.01, 556.15, 500, 722.17, 500, 500, 443.85,
    394.04, 220.21, 394.04, 520.02 },
}
local OTHER = {
  regular = { ["\u{2019}"] = 333.01, ["\u{2018}"] = 333.01, ["\u{201C}"] = 443.85, ["\u{201D}"] = 443.85,
    ["\u{2013}"] = 500, ["\u{2014}"] = 1000, ["\u{00A7}"] = 500, ["\u{00B6}"] = 453.13, ["\u{2026}"] = 1000 },
  bold = { ["\u{2019}"] = 333.01, ["\u{2018}"] = 333.01, ["\u{201C}"] = 500, ["\u{201D}"] = 500,
    ["\u{2013}"] = 500, ["\u{2014}"] = 1000, ["\u{00A7}"] = 500, ["\u{00B6}"] = 540.04, ["\u{2026}"] = 1000 },
}

-- The width of a word at 12 pt, in pt.
local function width(word, bold)
  local face = bold and "bold" or "regular"
  local w = 0
  for _, c in utf8.codes(word) do
    local ch = utf8.char(c)
    w = w + ((c >= 32 and c <= 126) and ASCII[face][c - 31] or OTHER[face][ch] or 500)
  end
  return w * 12 / 1000
end

-- The lines a text takes in a column `measure` pt wide.
local function line_count(text, measure, bold)
  local n, line = 1, nil
  local space = width(" ", bold)
  for word in text:gsub("\u{00A0}", " "):gmatch("%S+") do
    local w = width(word, bold)
    if line == nil then
      line = w
    elseif line + space + w <= measure + 0.01 then
      line = line + space + w
    else
      n, line = n + 1, w
    end
  end
  return n
end

-- A height rounded up to whole numbered lines (typst on-grid).
local function grid(h)
  return math.ceil(h / BODY - 0.001) * BODY
end

-- ---------------------------------------------------------------------------
-- Paragraphs
-- ---------------------------------------------------------------------------

-- A paragraph: o = { style, keep, before, after, line, left, hanging, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  if not o.style or o.left then props[#props + 1] = xe.ind(o.left or 0, o.hanging, o.first or 0) end
  if o.jc then props[#props + 1] = xe.jc(o.jc) end
  return xe.para(props, body)
end

-- Single-spaced lines (typst line-stack): an item is a metadata value or a string. o = { above, b, keep, left }.
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for _, l in ipairs(lines) do
    local r = type(l) == "string" and xe.runs(l, { b = o.b }) or xe.inl(l, { b = o.b })
    out[#out + 1] = p(r, { before = gap, keep = o.keep, left = o.left })
    gap = 0
  end
  return out
end

local function cell(width_tw, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width_tw .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. inner
    .. '</w:tc>'
end

local function tbl(cols, row)
  local grid = {}
  local w = 0
  for _, c in ipairs(cols) do grid[#grid + 1] = '<w:gridCol w:w="' .. c .. '"/>'; w = w + c end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. w .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. row .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: lines 1 to 6 (the judge's name on line 1), the court title on lines 7 to 9, a blank line, the caption
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local judge = txt(m.judge) ~= "" and xe.inl(m.judge, { b = true }) or ""
  out[#out + 1] = p(judge, { line = BODY, after = (FIRST_BLANK - 1) * BODY, jc = "right" })
  local court = { COURT[1], COURT[2], txt(m.location):upper() }
  for k, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, after = k == #court and BODY or 0, jc = "center" })
  end

  -- the parties: each party's names, then its designation; "v." between the parties
  local rows = {}
  for k, party in ipairs(items(m.caption.parties)) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, l in ipairs(items(party.names)) do rows[#rows + 1] = l end
    rows[#rows + 1] = party.designation
  end
  local left_measure = (CAP_LEFT - CAP_PAD) / 20
  local lh = DROP + CAP_FOOT
  for _, r in ipairs(rows) do lh = lh + SINGLE * line_count(txt(r), left_measure) end

  local right_measure = (TEXTW - CAP_LEFT - CAP_GUTTER - CAP_INSET) / 20
  local number = "Case No. " .. txt(m.case_number)
  local right = stack({ number })
  local rh = DROP + SINGLE * line_count(number, right_measure)
  for _, v in ipairs({ m.brief_title, table.unpack(items(m.caption_notes)) }) do
    right[#right + 1] = stack({ v }, { above = HALF, b = true })[1]
    rh = rh + HALF + SINGLE * line_count(txt(v), right_measure, true)
  end
  -- the row: whole numbered lines (typst caption(): the measured height rounded up); LibreOffice sets the 0.75 pt
  -- rule below the row on top of its height (typst draws the stroke on the cell's edge), so the row is that much less
  local h = grid(math.max(lh, rh)) - RULE

  -- the 8 pt below the parties as the last line's space after: LibreOffice would give a bottom cell margin to the whole row
  local parties = stack(rows)
  parties[#parties] = parties[#parties]:gsub('w:after="0"', 'w:after="' .. CAP_FOOT .. '"', 1)
  local w3 = TEXTW - CAP_LEFT - CAP_GUTTER
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, w3 },
    '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. h .. '" w:hRule="atLeast"/></w:trPr>'
    .. cell(CAP_LEFT, table.concat(parties),
      '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
      .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
      .. '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/>'
      .. '<w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. cell(CAP_GUTTER, p("", {}))
    .. cell(w3, table.concat(right), '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:left w:w="'
      .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>')
    .. '</w:tr>')
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (LCR 10(e)(4)): the date at left; "Respectfully submitted," the firm and the signers at 3.2 in;
-- a numbered line below, the rest of the counsel list and the role, kept together
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local w2 = TEXTW - SIG_LEFT - SIG_GUTTER
  local measure = w2 / 20
  local right = stack({ "Respectfully submitted," })
  local rh = DROP + SINGLE * line_count("Respectfully submitted,", measure)
  if txt(s.firm) ~= "" then
    right[#right + 1] = stack({ s.firm }, { above = HALF })[1]
    rh = rh + HALF + SINGLE * line_count(txt(s.firm), measure)
  end
  local signers = {}
  for k, l in ipairs(items(s.signers)) do
    signers[#signers + 1] = k == 1 and ("By: " .. txt(l)) or l
    rh = rh + (k == 1 and HALF or 0) + SINGLE * line_count(txt(signers[#signers]), measure)
  end
  for _, x in ipairs(stack(signers, { above = HALF })) do right[#right + 1] = x end
  local lh = DROP + SINGLE * line_count(txt(s.date), SIG_LEFT / 20)
  local top = '<w:top w:w="' .. DROP .. '" w:type="dxa"/>'
  local keep = function(list)
    local o = {}
    for k, x in ipairs(list) do o[k] = x:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1) end
    return table.concat(o)
  end
  -- the signers' row on whole numbered lines (typst on-grid); the counsel list a second row, a numbered line below,
  -- kept with the first (typst: one unbreakable block)
  local row = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. grid(math.max(lh, rh)) .. '" w:hRule="atLeast"/></w:trPr>'
    .. cell(SIG_LEFT + SIG_GUTTER, keep(stack({ s.date })),
      '<w:tcMar>' .. top .. '<w:right w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>')
    .. cell(w2, keep(right), '<w:tcMar>' .. top .. '</w:tcMar>')
    .. '</w:tr>'
  if s.additional then
    local rows = items(s.additional)
    if s.role then rows[#rows + 1] = s.role end
    row = row .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      .. cell(TEXTW, table.concat(stack(rows)), '<w:gridSpan w:val="2"/><w:tcMar><w:top w:w="' .. (BODY + DROP)
        .. '" w:type="dxa"/></w:tcMar>')
      .. '</w:tr>'
  end
  return { tbl({ SIG_LEFT + SIG_GUTTER, w2 }, row) }
end

-- ---------------------------------------------------------------------------
-- Bottom notation and the section
-- ---------------------------------------------------------------------------

local PAGE = '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t>1</w:t></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>'

-- LCR 10(e)(3), from the frontmatter as written (typst footer-block sets the strings as they are, not as markdown):
-- the title in capitals and "(Case No. ...) – page" at left, 10 pt; the firm lines at right, 9 pt; then the 1 pt
-- paragraph a footer table needs after it.
local function notation(meta)
  local function line(t, sz, pitch, jc, tail)
    return xe.para({ xe.spacing(0, 0, pitch), xe.ind(0, nil, 0), xe.jc(jc) },
      xe.runs(t, { sz = sz }) .. (tail or ""))
  end
  local left = line(tostring(meta.footer_title or ""):upper(), 20, NOTATION, "left")
    .. line("(Case No. " .. tostring(meta.case_number or "") .. ") \u{2013} ", 20, NOTATION, "left", PAGE)
  local right = {}
  for _, l in ipairs(meta.footer_firm or {}) do right[#right + 1] = line(tostring(l), 18, FIRM, "right") end
  if #right == 0 then right[1] = line("", 18, FIRM, "right") end
  local w1 = 5040
  return tbl({ w1, TEXTW - w1 }, '<w:tr>' .. cell(w1, left) .. cell(TEXTW - w1, table.concat(right)) .. '</w:tr>')
    .. xe.para({ xe.spacing(0, 0, 20) }, "")
end

local FINAL = '<w:sectPr><w:headerReference w:type="default" r:id="rIdWawdLines"/>'
  .. '<w:footerReference w:type="default" r:id="rIdWawdNotation"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" w:header="720" w:footer="288" w:gutter="0"/>'
  .. '<w:cols w:space="720"/></w:sectPr>'

local function write_file(var, text)
  local path = os.getenv(var)
  if not path then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function read_meta()
  local path = os.getenv("FORMBOOK_META")
  if not path then return {} end
  local f = io.open(path, "r")
  if not f then return {} end
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1114(1)(a)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A Str of two or more section signs or pilcrows ("§§"; each two bytes): typst keeps it with its number
-- (lib/typst/xengine.typ boxes "§ 1331" inside "§§ 1331"), lib/pandoc/xengine.lua binds a single sign only.
local function doubled_sign(t)
  local _, s = t:gsub("\u{00A7}", "")
  local _, q = t:gsub("\u{00B6}", "")
  return s + q >= 2 and #t == 2 * (s + q)
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there), nor after a doubled sign: the space becomes a no-break space, as wide.
local function no_break(l)
  for i = 2, #l do
    if l[i].t == "Space" and l[i - 1].t == "Str" and doubled_sign(l[i - 1].text) then
      l[i] = pandoc.Str("\u{00A0}")
    end
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function upper(c)
  return c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- Headings (typst heading-block): on the body pitch, kept with the next block; level 1 centred bold capitals, level 2
-- centred roman, level 3 bold at the margin (the styles in docx/reference.xml).
local function heading(b)
  local level = math.min(b.level, 3)
  local c = level == 1 and upper(b.content) or b.content
  return p(xe.inl(c), { style = "Heading" .. level, keep = true, line = BODY })
end

local function finish(doc)
  local m = doc.meta
  local x = cover(m)
  local first = true
  -- the caption's foot to the first block: a numbered line (typst caption below: pitch-body)
  local function add(s)
    if first then
      s = s:gsub('<w:spacing w:before="0"', '<w:spacing w:before="' .. BODY .. '"', 1)
      first = false
    end
    x[#x + 1] = s
  end
  local unnumbered, n = false, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local t = txt(b.content)
      unnumbered = t:find("PRAYER FOR RELIEF", 1, true) ~= nil or t:find("DEMAND FOR JURY TRIAL", 1, true) ~= nil
      add(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered then
        add(p(xe.inl(b.content), { style = "BodyText", line = BODY }))
      else
        n = n + 1
        add(p(xe.runs(n .. ".\t") .. xe.inl(b.content), { style = "NumberedParagraph", line = BODY }))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local k = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and (k .. ".") or "\u{2022}"
        add(p(xe.runs(lab .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)), { style = "PrayerItem", line = BODY }))
        k = k + 1
      end
    else
      error("complaint.lua: unsupported block " .. b.t)
    end
  end
  -- the last block to the signature: a numbered line (typst signature-block above: pitch-body), dropped at a page end
  x[#x] = x[#x]:gsub('w:after="0"', 'w:after="' .. BODY .. '"', 1)
  -- the last paragraph (or the prayer's last item) stays with the signature block (typst: one unbreakable block)
  if not x[#x]:find("<w:keepNext/>", 1, true) then
    x[#x] = x[#x]:gsub('(<w:pStyle w:val="[^"]+"/>)', "%1" .. xe.KEEP, 1)
  end
  for _, s in ipairs(signature(m)) do x[#x + 1] = s end

  write_file("FORMBOOK_FOOTERS", "rIdWawdNotation\t" .. notation(read_meta()) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break }, { Pandoc = finish } }
