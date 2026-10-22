-- Eighth Circuit appellant's (opening) brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- the reference document fb render builds from docx/reference.xml. The cover, summary of the case (the body's "Summary
-- of the Case" section), disclosure statement, table of contents, table of authorities, signature block and
-- certificates are written here as paragraphs in the "CA ..." styles of docx/reference.xml (raw WordprocessingML, one
-- paragraph per call to P); the body keeps its markdown structure. Headings get their labels (I. A. 1. a.) as text,
-- with a tab. Sections (cover: no number; front matter: lower roman; body: arabic from 1) are section breaks naming the
-- footers this filter gives fb render (FORMBOOK_FOOTERS: rIdRomanFtr, rIdArabicFtr, a centered PAGE field); the last
-- section goes to FORMBOOK_FINAL. The TOC and TOA page numbers: fb render (tools/fb/src/docxpass.rs) renders the
-- document once, finds the page of every heading and citation in that PDF (the needles this filter writes to
-- FORMBOOK_NEEDLES), and renders again with those pages (FORMBOOK_PAGES) until they settle (were docx/render.sh and
-- docx/pagemap.awk). Word may paginate slightly differently from the LibreOffice PDF the page numbers come from
-- (docs/DOCX.md). Styles: docx/reference.xml.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"; lib/docx/xengine.lua): every block is built as the
-- typst template (../typst/ca8-opening-brief.typ) builds it (the names in [brackets] are its functions), with its
-- spaces in twips (20 x pt, CFG.tw), so the lines and pages break alike.

local CFG = {
  kind = "opening-brief",
  toc_depth = 4,
  word_limit = 13000,      -- FRAP 32(a)(7)(B)(i): principal brief
  court = "United States Court of Appeals for the Eighth Circuit",   -- FRAP 32(a)(2)(B)
  -- The typst template's line boxes and spaces, in twips: the single pitch (17 pt); the cover's gap (14 pt, the
  -- largest typst tries) and its 4.9 pt between paragraphs; the counsel columns' gutter (0.25 in); the right half of
  -- the text block (234 pt) and the 7 pt step of the signature's lines; the signature block (19.6 pt above, 16.8 pt
  -- after "Respectfully submitted,", 11.2 pt before the date); the certificates' signature (22.4 pt above), their
  -- paragraphs (14 pt apart) and options (11.2 pt above and below); the authorities' first group (14 pt above, 2.8 pt
  -- below).
  tw = {single = 340, gap = 280, para = 98, counsel_gutter = 360, half = 4680, step = 140, sig_above = 392,
    sig_gap = 336, date_gap = 224, form_above = 448, form_par = 280, option = 224, toa_first = 280, toa_after = 56},
}

local TOA_GROUPS = {
  {"case", "Cases:"}, {"constitution", "Constitutional Provisions:"}, {"statute", "Statutes:"},
  {"regulation", "Regulations:"}, {"rule", "Rules:"}, {"other", "Other Authorities:"},
}

-- The cross-engine layout model (lib/docx/xengine.lua): the break rules of typst on every run (a no-break hyphen
-- before a digit, pandoc's abbreviation no-break spaces undone, a section sign bound to its number).
local xe = require("docx.xengine")
-- Before the page number of a table row: three no-break spaces, so the leader is never shorter than that.
local LEAD = pandoc.Str("\u{00A0}\u{00A0}\u{00A0}")
local TEXTW = 9360
local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="rIdRomanFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
-- the footers (centered PAGE field) and the body's section (arabic from 1), which name them
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT_BODY = '<w:sectPr><w:footerReference w:type="default" r:id="rIdArabicFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function fail(msg) error("ca8-" .. CFG.kind .. ": " .. msg, 0) end

-- a metadata value as inlines
local function minl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then return pandoc.Inlines({pandoc.Str(v)}) end
  if v.t == nil then return pandoc.Inlines(v) end   -- a list of inlines (YAML strings are read as Markdown)
  return pandoc.Inlines(pandoc.utils.stringify(v))
end

-- a metadata value that holds markdown blocks (summary, disclosure)
local function mblocks(v)
  if v == nil then return pandoc.Blocks({}) end
  local ty = pandoc.utils.type(v)
  if ty == "string" then return pandoc.read(v, "markdown+smart").blocks end
  if ty == "Blocks" then return pandoc.Blocks(v) end
  return pandoc.Blocks({pandoc.Para(pandoc.Inlines(v))})
end

local function need(meta, k)
  if meta[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function upper_il(il)
  return pandoc.Plain(il):walk({Str = function(e) return pandoc.Str(e.text:upper()) end}).content
end

local function cat(...)
  local out = pandoc.Inlines({})
  for _, x in ipairs({...}) do
    if type(x) == "string" then out:insert(pandoc.Str(x))
    elseif x.t == nil then out:extend(pandoc.Inlines(x))   -- a plain list of inlines
    else out:insert(x) end
  end
  return out
end

-- inline content as WordprocessingML runs (emphasis, strong, line breaks, raw openxml)
local function xesc(s) return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
-- Break opportunities as typst has them, where LibreOffice and Word have others: a word joiner between ")" and "("
-- (no break inside "32(a)(5)": typst boxes the token), a zero-width space after a slash that neither a digit nor a
-- second slash follows (a line may end after "Meta/", as Unicode line breaking lets typst end it), and in a URL also
-- after "?", "=" and "&", never after the "//" of its scheme (a word joiner there; the typst template boxes a URL's
-- parts at these points).
local function typst_breaks(text)
  text = text:gsub("https?://%S+", function(u) return (u:gsub("([%?=&])(.)", "%1\u{200B}%2")) end)
  text = text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d/])", "/\u{200B}%1")
  return (text:gsub("://\u{200B}", "://\u{2060}"))
end
local function run(text, f)
  local rpr = (f.b and "<w:b/>" or "") .. (f.i and "<w:i/>" or "")
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. xesc(typst_breaks(text)) .. "</w:t></w:r>"
end
local function inl_xml(il, f, out)
  for _, el in ipairs(il) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then inl_xml(el.content, {b = f.b, i = true}, out)
    elseif t == "Strong" then inl_xml(el.content, {b = true, i = f.i}, out)
    elseif t == "Span" or t == "Link" or t == "SmallCaps" or t == "Underline" then inl_xml(el.content, f, out)
    elseif t == "RawInline" then
      if el.format == "openxml" then out[#out + 1] = el.text end
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
end

-- one paragraph as WordprocessingML (an XML string): style, inlines, optional extra pPr elements in schema order
local function P_xml(style, il, extra)
  local out = {}
  inl_xml(xe.inlines(pandoc.Inlines(il)), {}, out)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. "</w:pPr>" .. table.concat(out) .. "</w:p>"
end
local function P(style, il, extra) return pandoc.RawBlock("openxml", P_xml(style, il, extra)) end
local function raw_p(xml) return pandoc.RawBlock("openxml", xml) end
local KEEP = "<w:keepNext/>"
-- the empty paragraph that ends a section takes no room (it would push a full page's last line on)
local SECT_LINE = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
local BREAK_BEFORE = "<w:pageBreakBefore/>"
-- single-spaced line boxes with the given spaces above and below (twips)
local function SP(before, after)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. CFG.tw.single .. '" w:lineRule="exact"/>'
end
-- a section heading that opens a page has no space above it (typst drops it at the top of a page; Word keeps it
-- after a section or page break)
local TOP = '<w:spacing w:before="0" w:after="308" w:line="400" w:lineRule="exact"/>'
local CENTER = '<w:jc w:val="center"/>'

-- a borderless table of paragraphs (XML strings), `n` columns (2 by default); rows: lists of n XML strings. The
-- columns are typst's grid(columns: (1fr,) * n, column-gutter: g): equal shares of the text width less the gutters,
-- each gutter a right margin of the cell before it. Rows are never split.
local function grid(rows, gutter, n)
  n = n or 2
  local w = (TEXTW - gutter * (n - 1)) // n
  local COLS = {}
  for c = 1, n do COLS[c] = c < n and {w + gutter, gutter} or {TEXTW - (w + gutter) * (n - 1), 0} end
  local out = {'<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>'}
  for c = 1, n do out[#out + 1] = '<w:gridCol w:w="' .. COLS[c][1] .. '"/>' end
  out[#out + 1] = '</w:tblGrid>'
  for _, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for c = 1, n do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. COLS[c][1] .. '" w:type="dxa"/><w:tcMar><w:right w:w="'
        .. COLS[c][2] .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. (row[c] or '<w:p/>') .. '</w:tc>'
    end
    out[#out + 1] = '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return raw_p(table.concat(out))
end

-- a stack of lines (lists of inlines) as one paragraph each: the first `before` twips below what precedes it
local function cell(lines, before, jc)
  local x = {}
  for i, il in ipairs(lines) do
    x[#x + 1] = P_xml("CACounsel", il, KEEP .. SP(i == 1 and before or 0, 0) .. (jc or ""))
  end
  return table.concat(x)
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local vals = {{1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"}, {100, "C"}, {90, "XC"},
    {50, "L"}, {40, "XL"}, {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"}}
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- printed label of a numbered heading (levels 2 to 5) [heading-label]: in the Argument I. / A. / 1. / a.,
-- elsewhere A. / 1. / a. / (1)
local function label_for(level, n, in_arg)
  if level == 2 then return in_arg and (roman(n) .. ".") or (string.char(64 + n) .. ".") end
  if level == 3 then return in_arg and (string.char(64 + n) .. ".") or (tostring(n) .. ".") end
  if level == 4 then return in_arg and (tostring(n) .. ".") or (string.char(96 + n) .. ".") end
  if level == 5 then return in_arg and (string.char(96 + n) .. ".") or ("(" .. n .. ")") end
  fail("headings deeper than level 5 are not supported")
end

-- label indent steps (half inches) for a heading [label-indent]
local function steps_for(level, in_arg)
  return level - (in_arg and 2 or 1)
end

-- ---------------------------------------------------------------------------
-- needles and pages (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60   -- a needle is a prefix of the text (letters and digits only)

-- letters and digits only, lower case: fb render normalizes the PDF text the same way
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- a needle: { id, kind, needle, fallback }; kind B (body, in document order: moves the search on) or N (inside a
-- footnote: searched from the page the body has reached, moves nothing); the fallback is the text alone (a needle
-- that runs over a page end, with the footnotes between its halves)
local needles = {}
local function need_at(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = {id = id, kind = kind, needle = long, fallback = short}
end

-- the text a block starts with, as the PDF prints it (a footnote's text is not there: the text stops at its mark)
local function lead_text(b)
  local d = pandoc.Pandoc({b}):walk({Note = function() return pandoc.Str("\1") end})
  return (pandoc.utils.stringify(d):match("^[^\1]*"))
end

-- the pages of the previous pass: id -> printed page; empty on the first pass
local labels, have_pages = {}, false
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  have_pages = true
  for line in f:lines() do
    local id, _, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = lab end
  end
  f:close()
end

-- the printed page of a needle: "0" on the first pass
local function label_of(id)
  return labels[id] or "0"
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- cover (FRAP 32(a)(2)(A)-(F)) [cover-body]
-- ---------------------------------------------------------------------------

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  local G, PARA = CFG.tw.gap, CFG.tw.para
  local function C(il, before, extra) add(P("CACentered", il, (extra or "") .. SP(before or 0, 0))) end
  local function rule(style) add(raw_p('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>'
    .. '<w:spacing w:before="' .. G .. '" w:after="' .. G .. '" w:line="' .. (style == "CARule" and 20 or 50)
    .. '" w:lineRule="exact"/></w:pPr></w:p>')) end
  C({pandoc.Strong(cat("No. ", minl(need(meta, "case_number"))))}, G * 6 // 10, KEEP)   -- (A)
  rule("CADoubleRule")
  C({pandoc.Strong({pandoc.Str(CFG.court:upper())})}, 0, KEEP)                          -- (B)
  rule("CARule")
  local sides = need(meta, "caption")                                                    -- (C)
  for i, side in ipairs(sides) do
    for ni, name in ipairs(side.names) do C(minl(name), (ni == 1 and i > 1) and G * 3 // 10 or PARA) end
    add(P("CACounsel", minl(side.designation), SP(PARA, 0) .. '<w:ind w:left="' .. CFG.tw.half .. '" w:firstLine="0"/>'))
    if i < #sides then C({pandoc.Str("v.")}, G * 3 // 10) end
  end
  rule("CARule")
  C(minl(need(meta, "proceeding")))                                                      -- (D)
  local d = pandoc.Inlines({})
  if meta.district_court_case ~= nil then d:extend(cat("Case No. ", plain(meta.district_court_case))) end
  if meta.district_court_case ~= nil and meta.judge ~= nil then d:insert(pandoc.Str("; ")) end
  if meta.judge ~= nil then d:extend(minl(meta.judge)) end
  if #d > 0 then C(d, PARA) end
  rule("CARule")
  C({pandoc.Strong(upper_il(minl(need(meta, "brief_title"))))})                          -- (E)
  rule("CARule")
  -- (F) one column of counsel per group, side by side, 0.25 in apart, left-aligned: the names, then the lines in
  -- italics; the telephone line closes the last group
  local groups = need(meta, "counsel")
  local row = {}
  for gi, g in ipairs(groups) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = minl(n) end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = {pandoc.Emph(minl(l))} end
    if gi == #groups then lines[#lines + 1] = {pandoc.Emph(minl(need(meta, "phone")))} end
    row[#row + 1] = cell(lines, 0)
  end
  add(grid({row}, CFG.tw.counsel_gutter, #groups))
  rule("CADoubleRule")
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_COVER .. '</w:pPr></w:p>'))
  return B
end

-- ---------------------------------------------------------------------------
-- signature and certificates (FRAP 32(g); Form 6)
-- ---------------------------------------------------------------------------

-- right half of the text block (typst right-half), `step` twips more
local function half(step) return '<w:ind w:left="' .. (CFG.tw.half + (step or 0)) .. '" w:firstLine="0"/>' end

-- [signature-block]: 19.6 pt below the text, in the right half: "Respectfully submitted,", 16.8 pt, "/s/ Signer", the
-- signer in capitals, the further lines 7 pt in and in italics; then 11.2 pt and the date at the margin; kept together
local function signature(meta)
  local sig = need(meta, "signature")
  local B = {}
  local lines = {{pandoc.Str("/s/ " .. plain(sig.signer)), 0}, {pandoc.Str(plain(sig.signer):upper()), 0}}
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = {pandoc.Emph(minl(l)), CFG.tw.step} end
  B[#B + 1] = P("CACounsel", {pandoc.Str("Respectfully submitted,")}, KEEP .. SP(CFG.tw.sig_above, 0) .. half())
  for i, l in ipairs(lines) do
    local last = i == #lines and meta.date == nil
    B[#B + 1] = P("CACounsel", {l[1]}, (last and "" or KEEP) .. SP(i == 1 and CFG.tw.sig_gap or 0, 0) .. half(l[2]))
  end
  if meta.date ~= nil then B[#B + 1] = P("CACounsel", minl(meta.date), SP(CFG.tw.date_gap, 0)) end
  return B
end

-- [form-sig-line]: 22.4 pt below the text, in the right half: "/s/ Signer", "Attorney for ...", "Dated: date"
local function form_sig_line(meta)
  local sig = need(meta, "signature")
  local lines = {{pandoc.Str("/s/ " .. plain(sig.signer))}, cat("Attorney for ", minl(sig["for"]))}
  if meta.date ~= nil then lines[#lines + 1] = cat("Dated: ", minl(meta.date)) end
  local B = {}
  for i, il in ipairs(lines) do
    B[#B + 1] = P("CACounsel", il, (i < #lines and KEEP or "") .. SP(i == 1 and CFG.tw.form_above or 0, 0) .. half())
  end
  return B
end

-- [option-row]: a checked option of Form 6: the box (a bordered run around an X) 22.4 pt in, the text at 44.8 pt,
-- hanging there; 11.2 pt above and below
local function option(il)
  local box = '<w:r><w:rPr><w:bdr w:val="single" w:sz="5" w:space="0" w:color="000000"/></w:rPr><w:t xml:space="preserve">X</w:t></w:r>'
  return P("CACounsel", cat(pandoc.RawInline("openxml", box), TAB, il), '<w:keepLines/><w:tabs><w:tab w:val="left" w:pos="896"/></w:tabs>'
    .. SP(CFG.tw.option, CFG.tw.option) .. '<w:ind w:left="896" w:hanging="448"/>')
end

-- a paragraph of a form: single-spaced, at the margin, 14 pt above
local function formpar(il, extra) return P("CACounsel", il, (extra or "") .. SP(CFG.tw.form_par, 0)) end

-- ---------------------------------------------------------------------------
-- words (FRAP 32(f), (g)(1)) [count-words]: block by block, footnote text included
-- ---------------------------------------------------------------------------

local function words_in(s)
  local n = 0
  for _ in s:gsub("\u{00A0}", " "):gmatch("%S+") do n = n + 1 end
  return n
end

local function count_blocks(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do n = n + count_blocks(item) end
    elseif b.t == "BlockQuote" or b.t == "Div" then
      n = n + count_blocks(b.content)
    elseif b.t ~= "RawBlock" then
      local notes = {}
      local without = pandoc.Pandoc({b}):walk({
        Note = function(note) notes[#notes + 1] = note.content; return {} end,
      })
      n = n + words_in(pandoc.utils.stringify(without.blocks))
      for _, c in ipairs(notes) do n = n + count_blocks(c) end
    end
  end
  return n
end

-- the brief's last paragraph travels with the signature unless the markdown's last block (after the last blank
-- line) is a heading or a footnote definition, read from the source as typst reads it
local function keeps_tail()
  local f = PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then return true end
  local src = h:read("a")
  h:close()
  src = src:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1):gsub("%s+$", "")
  local tail, pos = src, 1
  while true do
    local s, e = src:find("\n[ \t]*\n", pos)
    if not s then break end
    tail, pos = src:sub(e + 1), e
  end
  return #tail > 0 and tail:sub(1, 1) ~= "#" and tail:sub(1, 2) ~= "[^"
end

-- ---------------------------------------------------------------------------
-- the filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  load_pages()
  for _, k in ipairs({"case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature",
      "word_processor", "typeface"}) do
    need(meta, k)
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^%s*addendum%s*$") then
      fail("the DOCX engine does not render an addendum in the brief (8th Cir. R. 28A(g): filed as its own PDF)")
    end
  end

  -- every toa: citation in document order, per top-level block, as a needle: the link text and the words after it
  -- in its paragraph (up to a footnote mark or a quotation), so that the same words elsewhere in the brief,
  -- unlinked, are not taken for it. Kind B (body) moves the search on; N (in a footnote) is searched from the page
  -- the body has reached. (The summary of the case is on a roman page: its citations are not searched there.)
  local cites = {}
  local scan_blocks
  local function scan(inls, kind, list)
    for i, el in ipairs(inls) do
      if el.t == "Link" and el.target:match("^toa:") then
        local rest = {}
        for j = i + 1, math.min(#inls, i + 12) do
          local t = inls[j].t
          if t == "Note" or t == "Quoted" or t == "Link" then break end
          rest[#rest + 1] = inls[j]
        end
        list[#list + 1] = {key = el.target:sub(5), kind = kind, text = plain(pandoc.Inlines(el.content)),
          context = plain(pandoc.Inlines(rest))}
      elseif el.t == "Note" then
        scan_blocks(el.content, "N", list)
      elseif el.content ~= nil and type(el.content) == "table" and el.t ~= "Code" then
        scan(el.content, kind, list)
      end
    end
  end
  scan_blocks = function(blocks, kind, list)
    for _, b in ipairs(blocks) do
      if b.t == "Para" or b.t == "Plain" or b.t == "Header" then scan(b.content, kind, list)
      elseif b.t == "BlockQuote" or b.t == "Div" then scan_blocks(b.content, kind, list)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, kind, list) end
      end
    end
  end

  -- the summary of the case (8th Cir. R. 28A(i)(1)): the body's first "Summary of the Case" section, set on the
  -- first front page
  local summary, rest = nil, pandoc.Blocks({})
  do
    local i = 1
    while i <= #doc.blocks do
      local b = doc.blocks[i]
      local t = b.t == "Header" and b.level == 1 and plain(b.content):lower() or nil
      if t and not summary and t:match("^summary of t?h?e? ?case") then
        summary = pandoc.Blocks({})
        i = i + 1
        while i <= #doc.blocks and not (doc.blocks[i].t == "Header" and doc.blocks[i].level == 1) do
          summary:insert(doc.blocks[i])
          i = i + 1
        end
      else
        rest:insert(b)
        i = i + 1
      end
    end
  end
  for bi, b in ipairs(rest) do
    cites[bi] = {}
    scan_blocks({b}, "B", cites[bi])
  end
  -- a summary citation is on page i, ii, ...: the page map does not see it (typst lists that roman page)
  local summary_hits = {}
  if summary then
    pandoc.Pandoc(summary):walk({Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if key then summary_hits[key] = true end
    end})
  end

  -- every toa: citation: the authority key
  local hits = {}
  local auth = meta.authorities or {}
  local function unlink(blocks)
    return pandoc.Pandoc(blocks):walk({
      Link = function(el)
        local key = el.target:match("^toa:(.+)$")
        if not key then return nil end
        if auth[key] == nil then fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
        hits[key] = true
        return el.content
      end,
    }).blocks
  end
  rest = unlink(rest)
  if summary then summary = unlink(summary) end
  -- the text each block starts with, before the inline rules (they write some characters as raw runs): what a
  -- heading's needle runs on into
  local leads = {}
  for bi, b in ipairs(rest) do leads[bi] = lead_text(pandoc.Div(xe.list_items(b))):sub(1, 40) end

  -- the words (FRAP 32(f)): the summary and the body, a statement regarding oral argument left out; counted before
  -- the inline rules (they write some characters as raw runs, which stringify leaves out)
  local counted = pandoc.Blocks({})
  if summary then counted:extend(summary) end
  local skipping = false
  for _, b in ipairs(rest) do
    if b.t == "Header" and b.level == 1 then skipping = plain(b.content):lower():find("oral argument", 1, true) ~= nil end
    if not skipping then counted:insert(b) end
  end
  local words = count_blocks(counted)
  if words > CFG.word_limit then
    fail("the brief has " .. words .. " words; FRAP 32(a)(7)(B) allows " .. CFG.word_limit)
  end
  -- the break rules of typst on the text pandoc writes itself (body, footnotes)
  local function typst_inlines(blocks)
    local d = pandoc.Pandoc(blocks):walk({Inlines = xe.inlines})
    return d:walk({Str = function(s)
      local t = typst_breaks(s.text)
      if t ~= s.text then return pandoc.Str(t) end
    end}).blocks
  end
  rest = typst_inlines(rest)
  if summary then summary = typst_inlines(summary) end

  -- the body: headings get their labels and needles; lists as List Item paragraphs (the label in a half-inch box).
  -- The body's page 1 is the page of its first block. A heading's needle is its label and title and the text after
  -- it (the next block, as printed), so the same words earlier on the page are not taken for it.
  local body_id = "S:body"
  if rest[1] and rest[1].t ~= "Header" then need_at(body_id, "B", leads[1], "") end
  local occurrences = {}
  local function cite_needles(bi)
    for _, c in ipairs(cites[bi] or {}) do
      occurrences[#occurrences + 1] = {key = c.key, id = "T:" .. (#occurrences + 1)}
      need_at(occurrences[#occurrences].id, c.kind, c.text, c.context)
    end
  end
  local pending = nil   -- a heading waits for the text after it
  local function flush(next_text)
    if pending then
      need_at(pending.id, "B", pending.text, next_text)
      cite_needles(pending.bi)
      pending = nil
    end
  end
  local heads, body = {}, {}
  local counters, in_arg = {0, 0, 0, 0, 0, 0}, false
  for bi, b in ipairs(rest) do
    if b.t == "Header" then
      local text = plain(b.content)
      if b.level == 1 then
        local t = text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        in_arg = t == "argument" or t == "reply argument"
        counters = {0, 0, 0, 0, 0, 0}
      end
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      local id = "H:" .. (#heads + 1)
      if bi == 1 then body_id = id end
      local h = {level = b.level, title = b.content, id = id}
      if b.level == 1 then
        h.label, h.steps, h.centered = "", 0, false
        body[#body + 1] = P("CASection", b.content, KEEP .. (#body == 0 and TOP or ""))
      else
        h.label = label_for(b.level, counters[b.level], in_arg)
        h.steps = steps_for(b.level, in_arg)
        h.centered = in_arg and b.level == 2
        if h.centered then
          body[#body + 1] = P("CAPoint", cat(h.label, " ", b.content), KEEP)
        else
          body[#body + 1] = P("CAHeadL" .. b.level .. "S" .. h.steps, cat(h.label, TAB, b.content), KEEP)
        end
      end
      local shown = h.label ~= "" and (h.label .. " " .. text) or text
      flush(shown)
      pending = {id = id, text = shown, bi = bi}
      heads[#heads + 1] = h
    else
      flush(leads[bi])
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
      cite_needles(bi)
    end
  end
  flush("")
  if #body > 0 and body[#body].t == "Para" and keeps_tail() then
    body[#body] = pandoc.Div({body[#body]}, pandoc.Attr("", {}, {["custom-style"] = "CA Body Last"}))
  end
  local svc = meta.service ~= nil and meta.service.certificate == true

  -- the printed pages of an authority: its distinct pages in the order cited; passim from 7 pages, as typst prints it
  local function pages_of(key)
    local ls, seen = {}, {}
    for _, o in ipairs(occurrences) do
      local l = label_of(o.id)
      if o.key == key and not seen[l] then seen[l] = true; ls[#ls + 1] = l end
    end
    if #ls >= 7 then return "passim" end
    return table.concat(ls, ", ")
  end

  -- the needles, in document order: the first front page's heading, the authorities heading (with the first
  -- group's head, so the contents' "TABLE OF AUTHORITIES" line is not taken for it), the body's, then the
  -- certificates'
  local first_group = nil
  for _, g in ipairs(TOA_GROUPS) do
    for key, a in pairs(auth) do
      if first_group == nil and plain(a.kind) == g[1] and hits[key] then first_group = g[2] end
    end
  end
  local front = summary and "Summary of the Case" or meta.disclosure ~= nil and "Corporate Disclosure Statement"
    or "Table of Contents"
  need_at("C:compliance", "B", "Certificate of Compliance", "1. This document complies")
  if svc then need_at("C:service", "B", "Certificate of Service", "") end
  local toa = norm("Table of Authorities" .. (first_group or ""))
  table.insert(needles, 1, {id = "S:front", kind = "B", needle = norm(front), fallback = norm(front)})
  table.insert(needles, 2, {id = "S:toa", kind = "B", needle = toa, fallback = toa})
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({n.id, n.kind, n.needle, n.fallback}, "\t") end
  -- how fb render labels pages: the front matter from page i, the body and the certificates from the body's first
  -- block
  nl[#nl + 1] = "#section\tS:front\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdRomanFtr\t" .. FOOTER_P .. "\nrIdArabicFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", SECT_BODY)

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- section 1: the cover (no page number)
  addall(cover(meta))

  -- section 2 (lower roman): the summary of the case, the disclosure statement, the contents, the authorities, each
  -- on its own page
  local first_front = true
  local function front_head(title)
    add(P("CASection", {pandoc.Str(title)}, (first_front and "" or BREAK_BEFORE) .. TOP))
    first_front = false
  end
  if summary then
    front_head("Summary of the Case")
    for _, b in ipairs(summary) do for _, x in ipairs(xe.list_items(b)) do add(x) end end
  end
  if meta.disclosure ~= nil then
    front_head("Corporate Disclosure Statement")   -- [disclosure-page]: single-spaced, at the margin
    add(formpar(minl(meta.disclosure)))
  end

  -- [toc-section]: the outlined headings up to toc_depth: the table of authorities, the body, the certificates
  front_head("Table of Contents")
  add(P("CATocPage", {pandoc.Str("Page")}))
  local function top_row(title, key)
    add(P("CATocTop", cat(pandoc.Str(title:upper()), LEAD, TAB, pandoc.Str(label_of(key)))))
  end
  top_row("Table of Authorities", "S:toa")
  for _, h in ipairs(heads) do
    if h.level <= CFG.toc_depth then
      local page = pandoc.Str(label_of(h.id))
      if h.level == 1 then
        add(P("CATocTop", cat(upper_il(h.title), LEAD, TAB, page)))
      else
        add(P("CATocS" .. (h.centered and 0 or h.steps), cat(h.label, TAB, h.title, LEAD, TAB, page)))
      end
    end
  end
  top_row("Certificate of Compliance", "C:compliance")
  if svc then top_row("Certificate of Service", "C:service") end

  -- [toa-section] (its own page): the first group carries the underlined "Page(s)"; 7 or more pages: passim
  front_head("Table of Authorities")
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = {key = key, a = a} end
    end
    local function sk(a)
      local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
      return (s:lower():gsub("[^a-z0-9 ]", ""))
    end
    table.sort(members, function(x, y) return sk(x.a) < sk(y.a) end)
    if #members > 0 then
      local head = {pandoc.Str(g[2])}
      if first then
        head[#head + 1] = TAB
        head[#head + 1] = pandoc.RawInline("openxml", '<w:r><w:rPr><w:b/><w:u w:val="single"/></w:rPr><w:t>Page(s)</w:t></w:r>')
      end
      add(P("CAToaGroup", head, first and SP(CFG.tw.toa_first, CFG.tw.toa_after) or nil))
      first = false
      for _, m in ipairs(members) do
        local il = pandoc.Inlines({})
        if m.a.name ~= nil then
          local nm = minl(m.a.name)
          if g[1] == "case" then il:insert(pandoc.Emph(nm)) else il:extend(nm) end
          il:insert(pandoc.Str(",")); il:insert(pandoc.LineBreak())
        end
        il:extend(minl(m.a.cite))
        il:insert(LEAD)
        il:insert(TAB)
        local pg = pages_of(m.key)
        if have_pages and summary_hits[m.key] then fail("a citation in the summary of the case (`" .. m.key .. "`): its roman page is not in the page map") end
        il:insert(pg == "passim" and pandoc.Emph({pandoc.Str("passim")}) or pandoc.Str(pg))
        add(P("CAToaEntry", il))
      end
    end
  end
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_ROMAN .. '</w:pPr></w:p>'))

  -- section 3 (arabic from 1): the body, the signature block, the certificates (each on its own page)
  addall(body)
  addall(signature(meta))
  -- [certificate-of-compliance]: Form 6
  add(P("CASection", {pandoc.Str("Certificate of Compliance")}, BREAK_BEFORE .. TOP))
  add(formpar({pandoc.Str("1. This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) "
    .. "because, excluding the parts of the document exempted by Fed. R. App. P. 32(f):")}, KEEP))
  add(option({pandoc.Str("this document contains " .. group_digits(words) .. " words.")}))
  add(formpar({pandoc.Str("2. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) "
    .. "and the type-style requirements of Fed. R. App. P. 32(a)(6) because:")}, KEEP))
  add(option(cat("this document has been prepared in a proportionally spaced typeface using ",
    minl(meta.word_processor), " in 14-point ", minl(meta.typeface), " roman type.")))
  add(formpar({pandoc.Str("3. The brief has been scanned for viruses and it is virus free.")}, KEEP))
  addall(form_sig_line(meta))
  if svc then
    -- [certificate-of-service]
    add(P("CASection", {pandoc.Str("Certificate of Service")}, BREAK_BEFORE .. TOP))
    add(formpar(cat("I hereby certify that on ", meta.date ~= nil and minl(meta.date) or "__________",
      ", I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for "
      .. "the Eighth Circuit by using the appellate CM/ECF system, which will send notification of such filing to "
      .. "all counsel of record.")))
    local unreg = meta.service.unregistered or {}
    if #unreg > 0 then
      add(formpar({pandoc.Str("I further certify that on the same date I served the foregoing by mail on the "
        .. "following persons who are not registered for electronic filing:")}))
      for _, u in ipairs(unreg) do
        add(P("CACounsel", cat(minl(u.name), ", ", minl(u.address)), '<w:keepLines/>' .. SP(196, 0)
          .. '<w:ind w:left="720" w:firstLine="0"/>'))
      end
    end
    addall(form_sig_line(meta))
  end

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({})   -- pandoc would print the date and title as a block at the top
  return doc
end
