-- Eighth Circuit appellee's (answering) brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on reference.docx. The cover, summary of the case, disclosure statement, table of contents, table of
-- authorities, signature block and certificates are written here as paragraphs in the "CA ..." styles of
-- reference.docx (raw WordprocessingML, one paragraph per call to P); the body keeps its markdown structure.
-- Headings get their labels (I. A. 1. a.) as text, with a tab. Sections (cover: no number; front matter: lower
-- roman; body: arabic from 1) and the footers are written by docx/render.sh, which also fills the page numbers of
-- the TOC and TOA from a first pass (DOCX_MANIFEST and DOCX_PAGEMAP, see docx/pagemap.awk).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"; lib/docx/xengine.lua): every block is built as the
-- typst template (../typst/ca8-answering-brief.typ) builds it (the names in [brackets] are its functions), with its
-- spaces in twips (20 x pt, CFG.tw), so the lines and pages break alike.

local CFG = {
  kind = "answering-brief",
  toc_depth = 4,
  word_limit = 13000,      -- FRAP 32(a)(7)(B)(i): the appellee's brief is a principal brief (FRAP 28(b))
  summary_title = "Summary of the Case and Statement on Oral Argument",   -- 8th Cir. R. 28A(i)(1)
  typeface = "14-point Times New Roman",   -- typst: #int(type-size / 1pt)-point #font-family.first()
  -- The typst template's line boxes and spaces, in twips: the single pitch (17 pt); the cover's gap (14 pt, the
  -- largest typst tries) and its 4.9 pt between paragraphs; the counsel grid's gutters (16.8 pt); the signature
  -- block (19.6 pt above, 14 pt between its columns, 16.8 pt after "Respectfully submitted,"); the certificates'
  -- signature line (22.4 pt above).
  tw = {single = 340, gap = 280, para = 98, counsel_gutter = 336, sig_above = 392, sig_gutter = 280, sig_gap = 336,
    form_above = 448},
}

local TOA_GROUPS = {
  {"case", "Cases"}, {"constitution", "Constitutional Provisions"}, {"statute", "Statutes"},
  {"regulation", "Regulations"}, {"rule", "Rules"}, {"other", "Other Authorities"},
}

-- The cross-engine layout model (lib/docx/xengine.lua): the break rules of typst on every run (a no-break hyphen
-- before a digit, pandoc's abbreviation no-break spaces undone, a section sign bound to its number).
local xe = require("docx.xengine")
-- Before the page number of a table row: three no-break spaces, so the leader is never shorter than that.
local LEAD = pandoc.Str("\u{00A0}\u{00A0}\u{00A0}")
local TEXTW = 9360
local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="RIDROMAN"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'

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
-- after "?", "=" and "&" (the typst template boxes a URL's parts there).
local function typst_breaks(text)
  text = text:gsub("https?://%S+", function(u) return (u:gsub("([%?=&])(.)", "%1\u{200B}%2")) end)
  return (text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d/])", "/\u{200B}%1"))
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
local TOP = '<w:spacing w:before="0" w:after="308" w:line="' .. CFG.tw.single .. '" w:lineRule="exact"/>'
local CENTER = '<w:jc w:val="center"/>'

-- a borderless two-column table of paragraphs (XML strings); rows: list of {xml, xml}. The columns are typst's
-- grid(columns: (1fr, 1fr), column-gutter: g): two halves of the text width less the gutter, the gutter a right
-- margin of the left cell. Rows are never split.
local function grid(rows, gutter)
  local half = (TEXTW - gutter) // 2
  local COLS = {{half + gutter, gutter}, {TEXTW - half - gutter, 0}}
  local out = {'<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. COLS[1][1] .. '"/><w:gridCol w:w="' .. COLS[2][1] .. '"/></w:tblGrid>'}
  for _, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for c = 1, 2 do
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

-- a whole link text, for the search in the PDF (no cut)
local function norm_text(s)
  return (s:gsub("\u{2060}", ""):gsub("\u{200B}", ""):gsub("\u{00A0}", " "):lower():gsub("%s+", " "):gsub("^ ", ""):gsub(" $", ""))
end

-- the search key of a heading in the PDF: lower case, at most about 30 characters
local function search_key(s)
  s = norm_text(s)
  if #s > 30 then s = s:sub(1, 30):match("^(.*)%s%S*$") or s:sub(1, 30) end
  return s
end

-- ---------------------------------------------------------------------------
-- page numbers from a first pass (docx/render.sh): DOCX_PAGEMAP, DOCX_MANIFEST
-- ---------------------------------------------------------------------------

local PM = {H = {}, S = {}, T = {}}
local pm_path = os.getenv("DOCX_PAGEMAP")
local have_pm = pm_path ~= nil and pm_path ~= ""
if have_pm then
  local f = io.open(pm_path, "r")
  if not f then fail("cannot read the page map " .. pm_path) end
  for line in f:lines() do
    local k, a, b = line:match("^(%u)\t([^\t]*)\t(.*)$")
    if k == "H" then PM.H[tonumber(a)] = b
    elseif k == "S" then PM.S[a] = b
    elseif k == "T" then PM.T[a] = b
    end
  end
  f:close()
end
-- the page for a key of the page map: "0" on the first pass, the first pass's value afterwards
local function pm_get(tbl, key, what)
  if not have_pm then return "0" end
  local v = tbl[key]
  if v == nil then fail("no page for " .. what .. " in the page map") end
  return v
end

-- ---------------------------------------------------------------------------
-- cover (FRAP 32(a)(2)) [cover-body]
-- ---------------------------------------------------------------------------

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  local G, PARA = CFG.tw.gap, CFG.tw.para
  local function C(il, before, extra) add(P("CACentered", il, (extra or "") .. SP(before or 0, 0))) end
  local function rule() add(raw_p('<w:p><w:pPr><w:pStyle w:val="CADoubleRule"/>'
    .. '<w:spacing w:before="' .. G .. '" w:after="' .. G .. '" w:line="50" w:lineRule="exact"/></w:pPr></w:p>')) end
  C(cat("No. ", minl(need(meta, "case_number"))), G * 6 // 10, KEEP)
  C({pandoc.Strong({pandoc.Str("IN THE UNITED STATES COURT OF APPEALS")})}, G, KEEP)
  C({pandoc.Strong({pandoc.Str("FOR THE EIGHTH CIRCUIT")})}, 0, KEEP)
  rule()
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for ni, name in ipairs(side.names) do C(minl(name), (ni == 1 and i > 1) and G * 3 // 10 or PARA) end
    C({pandoc.Emph(minl(side.designation))}, PARA)
    if i < #sides then C({pandoc.Str("v.")}, G * 3 // 10) end
  end
  rule()
  C(minl(need(meta, "proceeding")))
  local d = pandoc.Inlines({})
  if meta.district_court_case ~= nil then d:extend(minl(meta.district_court_case)) end
  if meta.district_court_case ~= nil and meta.judge ~= nil then d:insert(pandoc.Str(", ")) end
  if meta.judge ~= nil then d:extend(minl(meta.judge)) end
  if #d > 0 then C(d, PARA) end
  rule()
  C({pandoc.Strong(minl(need(meta, "brief_title")))})
  rule()
  -- [counsel-block]: two columns 16.8 pt apart, rows 16.8 pt apart, centered: the names, then the lines in italics;
  -- a group's own phone after its lines, a top-level phone (when no group has one) after the last group's
  local groups = need(meta, "counsel")
  local has_group_phone = false
  for _, g in ipairs(groups) do if g.phone ~= nil then has_group_phone = true end end
  local cells = {}
  for gi, g in ipairs(groups) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = minl(n) end
    local rest = {}
    for _, l in ipairs(g.lines or {}) do rest[#rest + 1] = l end
    if g.phone ~= nil then rest[#rest + 1] = g.phone
    elseif gi == #groups and not has_group_phone then rest[#rest + 1] = need(meta, "phone") end
    for _, l in ipairs(rest) do lines[#lines + 1] = {pandoc.Emph(minl(l))} end
    cells[#cells + 1] = lines
  end
  local rows = {}
  for i = 1, #cells, 2 do
    local before = i > 1 and CFG.tw.counsel_gutter or 0
    rows[#rows + 1] = {cell(cells[i], before, CENTER), cells[i + 1] and cell(cells[i + 1], before, CENTER) or nil}
  end
  add(grid(rows, CFG.tw.counsel_gutter))
  rule()
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_COVER .. '</w:pPr></w:p>'))
  return B
end

-- ---------------------------------------------------------------------------
-- signature and certificates
-- ---------------------------------------------------------------------------

-- [signature-block]: two columns 14 pt apart, 19.6 pt below the text: the date on the left; "Respectfully
-- submitted,", 16.8 pt, "/s/ Signer" in italics, the signer in capitals, the further lines in italics on the right
local function signature(meta)
  local sig = need(meta, "signature")
  local right = {{pandoc.Emph(cat("/s/ ", minl(sig.signer)))}, {pandoc.Str(plain(sig.signer):upper())}}
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = {pandoc.Emph(minl(l))} end
  local left = meta.date ~= nil and cell({cat("Dated: ", minl(meta.date))}, CFG.tw.sig_above) or nil
  local r = cell({{pandoc.Str("Respectfully submitted,")}}, CFG.tw.sig_above) .. cell(right, CFG.tw.sig_gap)
  return grid({{left, r}}, CFG.tw.sig_gutter)
end

-- [form-sig-line]: 22.4 pt below the text; "Dated: date" | "/s/ Signer" over the signer in capitals
local function form_sig_line(meta)
  local sig = need(meta, "signature")
  return grid({{cell({cat("Dated: ", minl(need(meta, "date")))}, CFG.tw.form_above),
    cell({{pandoc.Emph(cat("/s/ ", minl(sig.signer)))}, {pandoc.Str(plain(sig.signer):upper())}}, CFG.tw.form_above)}},
    CFG.tw.sig_gutter)
end

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
  for _, k in ipairs({"case_number", "caption", "proceeding", "brief_title", "counsel", "signature", "virus_check",
      "summary"}) do
    need(meta, k)
  end

  -- every toa: citation in document order, as a needle for the page map (docx/pagemap.awk): the link text and the
  -- words after it in its paragraph (up to a footnote mark or a quotation), so that the same words elsewhere in the
  -- brief, unlinked, are not taken for it. Kind B (body) moves the search on; N (in a footnote) is searched from the
  -- page the body has reached.
  local needles = {}
  local scan_blocks
  local function scan(inls, kind)
    for i, el in ipairs(inls) do
      if el.t == "Link" and el.target:match("^toa:") then
        local rest = {}
        for j = i + 1, math.min(#inls, i + 12) do
          local t = inls[j].t
          if t == "Note" or t == "Quoted" or t == "Link" then break end
          rest[#rest + 1] = inls[j]
        end
        local lt = norm_text(plain(pandoc.Inlines(el.content)))
        local tail = norm_text(plain(pandoc.Inlines(rest)))
        if #tail > 20 then tail = tail:sub(1, 20):match("^(.*)%s%S*$") or "" end
        local text = lt
        if tail ~= "" then text = lt .. (tail:match("^[%.,;:%)]") and "" or " ") .. tail end
        needles[#needles + 1] = {key = el.target:sub(5), kind = kind, text = text}
      elseif el.t == "Note" then
        scan_blocks(el.content, "N")
      elseif el.content ~= nil and type(el.content) == "table" and el.t ~= "Code" then
        scan(el.content, kind)
      end
    end
  end
  scan_blocks = function(blocks, kind)
    for _, b in ipairs(blocks) do
      if b.t == "Para" or b.t == "Plain" or b.t == "Header" then scan(b.content, kind)
      elseif b.t == "BlockQuote" or b.t == "Div" then scan_blocks(b.content, kind)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, kind) end
      end
    end
  end
  scan_blocks(doc.blocks, "B")

  -- every toa: citation: the authority key
  local hits = {}
  local auth = meta.authorities or {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if auth[key] == nil then fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
      hits[key] = true
      return el.content
    end,
  })

  -- the words of the body, footnotes included, counted before the inline rules (they write some characters as raw
  -- runs, which stringify leaves out)
  local words = count_blocks(doc.blocks)
  if words > CFG.word_limit then
    fail("the brief has " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. CFG.word_limit)
  end
  -- the break rules of typst on the text pandoc writes itself (body, footnotes)
  local function typst_inlines(d)
    d = d:walk({Inlines = xe.inlines})
    return d:walk({Str = function(s)
      local t = typst_breaks(s.text)
      if t ~= s.text then return pandoc.Str(t) end
    end})
  end
  doc = typst_inlines(doc)

  -- the body: headings get their labels; the addendum is not produced by this engine
  local heads, body = {}, {}
  local counters, in_arg = {0, 0, 0, 0, 0, 0}, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = plain(b.content)
      if b.level == 1 and text:lower():match("^%s*addendum%s*$") then
        fail("the DOCX engine does not yet render an addendum (FRAP 28(f))")
      end
      if b.level == 1 then
        in_arg = text:lower():match("^%s*argument%s*$") ~= nil
        counters = {0, 0, 0, 0, 0, 0}
      end
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      local idx = #heads + 1
      local h = {level = b.level, title = b.content, idx = idx}
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
      -- the page map finds a heading by its label and title at the start of a line
      h.key = search_key(h.label ~= "" and (h.label .. " " .. text) or text)
      heads[idx] = h
    else
      body[#body + 1] = b
    end
  end
  if #body > 0 and body[#body].t == "Para" and keeps_tail() then
    body[#body] = pandoc.Div({body[#body]}, pandoc.Attr("", {}, {["custom-style"] = "CA Body Last"}))
  end

  -- manifest for the first pass of docx/render.sh
  local man_path = os.getenv("DOCX_MANIFEST")
  if man_path ~= nil and man_path ~= "" then
    local f = assert(io.open(man_path, "w"))
    for _, h in ipairs(heads) do f:write(string.format("H\t%d\t%d\t%s\n", h.idx, h.level, h.key)) end
    f:write("S\tsum\troman\t" .. norm_text(CFG.summary_title) .. "\n")
    if meta.disclosure ~= nil then f:write("S\tdisc\troman\tcorporate disclosure statement\n") end
    f:write("S\ttoc\troman\ttable of contents\n")
    f:write("S\ttoa\troman\ttable of authorities\n")
    f:write("S\tcc\tbody\tcertificate of compliance\n")
    f:write("S\tcs\tbody\tcertificate of service\n")
    for _, n in ipairs(needles) do f:write(string.format("C\t%s\t%s\t%s\n", n.key, n.kind, n.text)) end
    f:close()
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end
  local function front_blocks(v) addall(typst_inlines(pandoc.Pandoc(mblocks(v))).blocks) end

  -- section 1: the cover (no page number)
  addall(cover(meta))

  -- section 2 (lower roman): the summary of the case, the disclosure statement, the contents, the authorities, each
  -- on its own page
  add(P("CASection", {pandoc.Str(CFG.summary_title)}, TOP))
  front_blocks(meta.summary)
  if meta.disclosure ~= nil then
    add(P("CASection", {pandoc.Str("Corporate Disclosure Statement")}, BREAK_BEFORE .. TOP))
    front_blocks(meta.disclosure)
  end

  -- [toc-section]: every outlined heading up to toc_depth, front matter and certificates included
  add(P("CASection", {pandoc.Str("Table of Contents")}, BREAK_BEFORE .. TOP))
  local function top_row(title, key, what)
    add(P("CATocTop", cat(pandoc.Str(title:upper()), LEAD, TAB, pandoc.Str(pm_get(PM.S, key, what)))))
  end
  top_row(CFG.summary_title, "sum", "the summary of the case")
  if meta.disclosure ~= nil then top_row("Corporate Disclosure Statement", "disc", "the disclosure statement") end
  top_row("Table of Contents", "toc", "the table of contents")
  top_row("Table of Authorities", "toa", "the table of authorities")
  for _, h in ipairs(heads) do
    if h.level <= CFG.toc_depth then
      local page = pandoc.Str(pm_get(PM.H, h.idx, "heading " .. h.idx))
      if h.level == 1 then
        add(P("CATocTop", cat(upper_il(h.title), LEAD, TAB, page)))
      else
        add(P("CATocS" .. (h.centered and 0 or h.steps), cat(h.label, TAB, h.title, LEAD, TAB, page)))
      end
    end
  end
  top_row("Certificate of Compliance", "cc", "the certificate of compliance")
  top_row("Certificate of Service", "cs", "the certificate of service")

  -- [toa-section] (its own page)
  add(P("CASection", {pandoc.Str("Table of Authorities")}, BREAK_BEFORE .. TOP))
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
      add(P("CAToaGroup", {pandoc.Str(g[2])}))
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
        il:insert(pandoc.Str(pm_get(PM.T, m.key, "authority " .. m.key)))
        add(P("CAToaEntry", il))
      end
    end
  end
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_ROMAN .. '</w:pPr></w:p>'))

  -- section 3 (arabic from 1): the body, the signature block, the certificates (each on its own page)
  addall(body)
  add(signature(meta))
  add(P("CASection", {pandoc.Str("Certificate of Compliance")}, BREAK_BEFORE .. TOP))
  add(P("BodyText", cat(("This brief complies with the type-volume limitations imposed by Federal Rule of "
    .. "Appellate Procedure 32(a)(7)(B)(i) because it contains " .. group_digits(words) .. " words, excluding the "
    .. "parts of the brief exempted by Rule 32(f). This brief complies with the typeface and typestyle requirements "
    .. "of Federal Rules of Appellate Procedure 32(a)(5) and 32(a)(6) because it has been prepared in a "
    .. "proportionally spaced typeface, " .. CFG.typeface .. ". This brief complies with the electronic-filing "
    .. "requirements of Local Rule 28A(h)(2) because it was "), minl(need(meta, "virus_check")), ".")))
  add(form_sig_line(meta))
  add(P("CASection", {pandoc.Str("Certificate of Service")}, BREAK_BEFORE .. TOP))
  add(P("BodyText", cat("I hereby certify that on ", minl(need(meta, "date")), ", the foregoing brief was filed "
    .. "with the Clerk of Court for the U.S. Court of Appeals for the Eighth Circuit through the CM/ECF system, which "
    .. "will send a notification of such filing to all counsel of record.")))
  add(form_sig_line(meta))

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({})   -- pandoc would print the date and title as a block at the top
  return doc
end
