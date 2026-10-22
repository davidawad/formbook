-- Eighth Circuit reply brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx. The cover, table of contents, table of authorities, signature block and certificates are written
-- here as paragraphs in the "CA ..." styles of reference.docx (raw WordprocessingML, one paragraph per call to P);
-- the body keeps its markdown structure. Headings get their labels (A. 1. a.) as text, with a tab. Sections (cover:
-- no number; front matter: lower roman; body: arabic from 1) and the footers are written by docx/render.sh, which
-- also fills the page numbers of the TOC and TOA from a first pass (DOCX_MANIFEST and DOCX_PAGEMAP, see
-- docx/pagemap.awk).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"; lib/docx/xengine.lua): every block is built as the
-- typst template (../typst/ca8-reply-brief.typ) builds it (the names in [brackets] are its functions), with its
-- spaces in twips (20 x pt, CFG.tw), so the lines and pages break alike.

local CFG = {
  kind = "reply-brief",
  toc_depth = 4,
  word_limit = 6500,       -- CA8-LIMIT-001: half of the 13,000-word principal limit (FRAP 32(a)(7)(B)(ii))
  font_name = "Gelasio, 14-point",   -- typst font-name, printed in the certificate of compliance
  -- The typst template's line boxes and spaces, in twips: the single pitch (17 pt); the cover's gap (14 pt, the
  -- largest typst tries) and its 4.9 pt between paragraphs; the right half (234 pt) and the quarter (117 pt) of the
  -- text block and the 7 pt step of the cover's address lines; the signature block (19.6 pt above, 16.8 pt after
  -- "Respectfully submitted,", 11.2 pt before each other signer, the date and the note); the certificates'
  -- paragraphs (14 pt apart); the authorities' first group (14 pt above, 2.8 pt below).
  tw = {single = 340, gap = 280, para = 98, half = 4680, quarter = 2340, step = 140, sig_above = 392, sig_gap = 336,
    date_gap = 224, form_par = 280, toa_first = 280, toa_after = 56},
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
local TOP = '<w:spacing w:before="0" w:after="308" w:line="' .. CFG.tw.single .. '" w:lineRule="exact"/>'
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

-- printed label of a numbered heading (levels 2 to 5) [heading-label]: A. / 1. / a. / (1)
local function label_for(level, n)
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return tostring(n) .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  if level == 5 then return "(" .. n .. ")" end
  fail("headings deeper than level 5 are not supported")
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
-- cover (FRAP 32(a)(2)(A)-(F); CA8-COVER-001 to -004) [cover-body]
-- ---------------------------------------------------------------------------

-- the right half of the text block (typst right-half); a quarter in, the first line `first` twips more
local function half() return '<w:ind w:left="' .. CFG.tw.half .. '" w:firstLine="0"/>' end
local function quarter(first) return '<w:ind w:left="' .. CFG.tw.quarter .. '" w:firstLine="' .. first .. '"/>' end

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  local G, PARA = CFG.tw.gap, CFG.tw.para
  local function C(il, before, extra) add(P("CACentered", il, (extra or "") .. SP(before or 0, 0))) end
  C({pandoc.Strong(cat("No. ", minl(need(meta, "case_number"))))}, 0, KEEP)
  C({pandoc.Strong({pandoc.Str("IN THE UNITED STATES COURT OF APPEALS")})}, G, KEEP)
  C({pandoc.Strong({pandoc.Str("FOR THE EIGHTH CIRCUIT")})}, 0, KEEP)
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for ni, name in ipairs(side.names) do
      C(minl(name), ni > 1 and PARA or (i == 1 and G * 15 // 10 or G * 6 // 10))
    end
    add(P("CACounsel", minl(side.designation), SP(PARA, 0) .. half()))
    if i < #sides then C({pandoc.Str("v.")}, G * 6 // 10) end
  end
  C(minl(need(meta, "proceeding")), G * 15 // 10)
  if meta.district_court_case ~= nil then C(cat("D.C. No. ", plain(meta.district_court_case)), PARA) end
  C({pandoc.Strong(upper_il(minl(need(meta, "brief_title"))))}, G * 15 // 10)
  -- counsel, from a quarter of the width: each group the names, then its lines 7 pt in (the last holds the phone); a
  -- paragraph a line, so a wrapped line returns to the quarter, as typst's does
  for gi, g in ipairs(need(meta, "counsel")) do
    for ni, n in ipairs(g.names) do
      add(P("CACounsel", minl(n), KEEP .. SP(ni == 1 and (gi == 1 and G * 15 // 10 or G // 2) or 0, 0) .. quarter(0)))
    end
    for _, l in ipairs(g.lines or {}) do add(P("CACounsel", minl(l), KEEP .. quarter(CFG.tw.step))) end
  end
  if meta.date ~= nil then C(minl(meta.date), G) end
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_COVER .. '</w:pPr></w:p>'))
  return B
end

-- ---------------------------------------------------------------------------
-- signature and certificates (FRAP 32(g); CA8-CERT-001 to -003)
-- ---------------------------------------------------------------------------

-- [signature-block]: 19.6 pt below the text, in the right half: "Respectfully submitted,", 16.8 pt, "/s/ Signer", the
-- signer, the further lines; each other signer 11.2 pt below with its lines; then 11.2 pt and the date at the margin,
-- 11.2 pt and the note; kept together
local function signature(meta)
  local sig = need(meta, "signature")
  local rows = {{{pandoc.Str("Respectfully submitted,")}, CFG.tw.sig_above, half()},
    {cat("/s/ ", minl(sig.signer)), CFG.tw.sig_gap, half()}, {minl(sig.signer), 0, half()}}
  for _, l in ipairs(sig.lines or {}) do rows[#rows + 1] = {minl(l), 0, half()} end
  for _, a in ipairs(sig.also or {}) do
    rows[#rows + 1] = {minl(a.name), CFG.tw.date_gap, half()}
    for _, l in ipairs(a.lines or {}) do rows[#rows + 1] = {minl(l), 0, half()} end
  end
  if meta.date ~= nil then rows[#rows + 1] = {minl(meta.date), CFG.tw.date_gap, ""} end
  if sig.note ~= nil then rows[#rows + 1] = {minl(sig.note), CFG.tw.date_gap, ""} end
  local B = {}
  for i, r in ipairs(rows) do
    B[#B + 1] = P("CACounsel", r[1], (i < #rows and KEEP or "") .. "<w:keepLines/>" .. SP(r[2], 0) .. r[3])
  end
  return B
end

-- [cert-sig]: 19.6 pt below the text, in the right half: "/s/ Signer", the signer, the role
local function cert_sig(meta)
  local sig = need(meta, "signature")
  local lines = {cat("/s/ ", minl(sig.signer)), minl(sig.signer), minl(sig.role or "Counsel for Appellant")}
  local B = {}
  for i, il in ipairs(lines) do
    B[#B + 1] = P("CACounsel", il, (i < #lines and KEEP or "") .. SP(i == 1 and CFG.tw.sig_above or 0, 0) .. half())
  end
  return B
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
  for _, k in ipairs({"case_number", "caption", "proceeding", "brief_title", "counsel", "signature"}) do need(meta, k) end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^%s*addendum%s*$") then
      fail("the DOCX engine does not render an addendum")
    end
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
        -- a URL may break at its break points (typst_breaks), and the PDF text then has a space there: the needle is
        -- the URL up to its first break point, which no line can split
        local u = lt:match("^https?://[^/]*/") or lt:match("^https?://%S-[%?=&%-]")
        if u then text = u end
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

  -- the words (CA8-LIMIT-001), footnotes included, counted before the inline rules (they write some characters as raw
  -- runs, which stringify leaves out)
  local words = count_blocks(doc.blocks)
  if words > CFG.word_limit then
    fail("the reply brief has " .. words .. " words; FRAP 32(a)(7)(B)(ii) allows " .. CFG.word_limit)
  end
  -- the break rules of typst on the text pandoc writes itself (body, footnotes)
  doc = doc:walk({Inlines = xe.inlines})
  doc = doc:walk({Str = function(s)
    local t = typst_breaks(s.text)
    if t ~= s.text then return pandoc.Str(t) end
  end})

  -- the body: headings get their labels (A. 1. a. (1), one step in per level; titles from level 4 in italics, the
  -- label never); lists as List Item paragraphs
  local heads, body = {}, {}
  local counters = {0, 0, 0, 0, 0, 0}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = plain(b.content)
      if b.level == 1 then counters = {0, 0, 0, 0, 0, 0} end
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      local idx = #heads + 1
      local h = {level = b.level, title = b.content, idx = idx}
      if b.level == 1 then
        h.label, h.steps = "", 0
        body[#body + 1] = P("CASection", b.content, KEEP .. (#body == 0 and TOP or ""))
      else
        h.label = label_for(b.level, counters[b.level])
        h.steps = b.level - 2
        local title = b.level >= 4 and {pandoc.Emph(b.content)} or b.content
        body[#body + 1] = P("CAHeadL" .. b.level .. "S" .. h.steps, cat(h.label, TAB, title), KEEP)
      end
      -- the page map finds a heading by its label and title at the start of a line
      h.key = search_key(h.label ~= "" and (h.label .. " " .. text) or text)
      heads[idx] = h
    else
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
  end
  -- the last paragraph (above the footnote definitions) stays with the signature block, unless it is a heading
  if #body > 0 and body[#body].t == "Para" then
    body[#body] = pandoc.Div({body[#body]}, pandoc.Attr("", {}, {["custom-style"] = "CA Body Last"}))
  end
  local svc = meta.service ~= nil and meta.service.certificate == true

  -- manifest for the first pass of docx/render.sh
  local man_path = os.getenv("DOCX_MANIFEST")
  if man_path ~= nil and man_path ~= "" then
    local f = assert(io.open(man_path, "w"))
    for _, h in ipairs(heads) do f:write(string.format("H\t%d\t%d\t%s\n", h.idx, h.level, h.key)) end
    f:write("S\tcc\tbody\tcertificate of compliance\n")
    if svc then f:write("S\tcs\tbody\tcertificate of service\n") end
    for _, n in ipairs(needles) do f:write(string.format("C\t%s\t%s\t%s\n", n.key, n.kind, n.text)) end
    f:close()
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- section 1: the cover (no page number)
  addall(cover(meta))

  -- section 2 (lower roman): [toc-section] the outlined headings up to toc_depth (the body and the certificates; not
  -- the tables), then [toa-section] on its own page
  add(P("CASection", {pandoc.Str("Table of Contents")}, TOP))
  add(P("CATocPage", {pandoc.Str("Page")}))
  local function top_row(title, key, what)
    add(P("CATocTop", cat(pandoc.Str(title:upper()), LEAD, TAB, pandoc.Str(pm_get(PM.S, key, what)))))
  end
  for _, h in ipairs(heads) do
    if h.level <= CFG.toc_depth then
      local page = pandoc.Str(pm_get(PM.H, h.idx, "heading " .. h.idx))
      if h.level == 1 then
        add(P("CATocTop", cat(upper_il(h.title), LEAD, TAB, page)))
      else
        add(P("CATocS" .. h.steps, cat(h.label, TAB, h.title, LEAD, TAB, page)))
      end
    end
  end
  top_row("Certificate of Compliance", "cc", "the certificate of compliance")
  if svc then top_row("Certificate of Service", "cs", "the certificate of service") end

  add(P("CASection", {pandoc.Str("Table of Authorities")}, BREAK_BEFORE .. TOP))
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
        local pg = pm_get(PM.T, m.key, "authority " .. m.key)
        il:insert(pg == "passim" and pandoc.Emph({pandoc.Str("passim")}) or pandoc.Str(pg))
        add(P("CAToaEntry", il))
      end
    end
  end
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_ROMAN .. '</w:pPr></w:p>'))

  -- section 3 (arabic from 1): the body, the signature block, the certificates (each on its own page)
  addall(body)
  addall(signature(meta))
  local NB = "\u{00A0}"   -- typst "~": a no-break space (written as runs: xe.inlines would undo one after a period)
  local function R(t) return pandoc.RawInline("openxml", run(t, {})) end
  local frap = "Fed." .. NB .. "R." .. NB .. "App." .. NB .. "P."
  local fname = CFG.font_name:gsub(" ", NB):gsub("," .. NB, ", ")   -- each part kept whole (typst boxes them)
  add(P("CASection", {pandoc.Str("Certificate of Compliance")}, BREAK_BEFORE .. TOP))
  add(formpar({R("I certify that this brief complies with the type-volume limitation of " .. frap
    .. " 32(a)(7)(B) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by "
    .. frap .. " 32(f). The brief complies with the typeface requirements of " .. frap .. " 32(a)(5) and the type-style "
    .. "requirements of " .. frap .. " 32(a)(6) because it has been prepared in a proportionally spaced typeface ("
    .. fname .. ").")}))
  add(formpar({R("Pursuant to Circuit" .. NB .. "Rule" .. NB .. "28A(h), I also certify that the electronic "
    .. "files of this brief have been submitted to the Clerk through the Court’s CM/ECF system and have been scanned "
    .. "for viruses and are virus-free.")}))
  addall(cert_sig(meta))
  if svc then
    add(P("CASection", {pandoc.Str("Certificate of Service")}, BREAK_BEFORE .. TOP))
    add(formpar(cat(R("Pursuant to " .. frap .. " 25 and Circuit" .. NB .. "Rule" .. NB .. "25A(a), I hereby certify that on "),
      meta.date ~= nil and minl(meta.date) or "__________", ", I filed a copy of the " .. plain(meta.brief_title)
      .. " with the Clerk of the Court through the Court’s CM/ECF system, which will serve electronic copies on all "
      .. "registered counsel.")))
    addall(cert_sig(meta))
  end

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({})   -- pandoc would print the date and title as a block at the top
  return doc
end
