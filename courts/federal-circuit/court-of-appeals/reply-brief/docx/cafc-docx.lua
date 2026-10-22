-- cafc-docx.lua: the Federal Circuit reply brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document
-- on the reference document fb render builds from docx/reference.xml. It lays the brief out as
-- ../typst/cafc-reply-brief.typ does, on the cross-engine layout model (lib/docx/xengine.lua): exact line boxes of the
-- typst pitches (32.2 pt text, 16.1 pt single), the typst spaces between blocks (twips = 20 x pt), first-fit breaking,
-- typst's break opportunities. The cover, the table of contents, the table of authorities, the signature block and the
-- certificates (Form 19, service) are written here as raw WordprocessingML paragraphs; the body keeps its markdown
-- structure, its headings get their labels (I. A. i. 1. a.) and a tab.
-- Sections (cover: no number; front matter: lower roman from i; body and certificates: arabic from 1) are section
-- breaks naming the footers this filter gives fb render (FORMBOOK_FOOTERS: rIdRomanFtr, rIdArabicFtr, a centered PAGE
-- field in a 16.1 pt line); the last section goes to FORMBOOK_FINAL. The page numbers of the contents and
-- authorities: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of every heading and
-- citation in that PDF (the needles this filter writes to FORMBOOK_NEEDLES), and renders again with those pages
-- (FORMBOOK_PAGES) until they settle (were docx/render.sh and docx/pagemap.awk). Word may paginate slightly
-- differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local xe = require("docx.xengine")

-- A line may end after a slash before a letter ("CM/ECF"), as typst breaks (Unicode line breaking); LibreOffice does
-- not: a zero-width space marks the place.
local ZWSP = "\u{200B}"
local function slash_breaks(s) return (s:gsub("/(%a)", "/" .. ZWSP .. "%1")) end

local WORD_LIMIT = 7000  -- Fed. Cir. R. 32(b)(1): reply brief (typst word-limit)
local TOC_DEPTH = 4      -- typst toc-depth
local TEXTW = 9360       -- 6.5 in, the text width (letter, 1 in margins)
local HALF = 4680        -- the right half of the text width (typst right-half)
local SIGCOL = 3744      -- the signature column starts 3.9 in from the right margin (typst grid (1fr, 3.9in))
local FORMCOL = 4820     -- Form 19's right column: (text width + 1 em) / 2 (typst grid (1fr, 1fr), gutter 14 pt)
local BODY, SINGLE = 644, 322   -- typst pitch-double (32.2 pt), pitch-single (16.1 pt)
local TOC_COL, TOA_COL = 720, 1120   -- typst toc-page-col (36 pt), toa-page-col (56 pt)
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="686" w:gutter="0"/></w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="rIdRomanFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="686" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
-- the footers (a centered PAGE field in a 16.1 pt line) and the body's section (arabic from 1), which name them
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="322" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT_BODY = '<w:sectPr><w:footerReference w:type="default" r:id="rIdArabicFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="686" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local function fail(msg) error("cafc reply-brief: " .. msg, 0) end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function need(meta, k)
  if meta[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- a metadata value as inlines (YAML strings are read as markdown)
local function minl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then return pandoc.Inlines({ pandoc.Str(v) }) end
  if v.t == nil then return pandoc.Inlines(v) end
  return pandoc.Inlines(pandoc.utils.stringify(v))
end

local function upper_il(il)
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(e.text:upper()) end }).content
end

-- inlines as runs: xe.inl, with the line breaks (TOA: name, then the cite) and raw runs the tables need
local function runs(il, o)
  il = pandoc.Inlines(il):walk({ Str = function(e) return pandoc.Str(slash_breaks(e.text)) end })
  local out, part = {}, pandoc.Inlines({})
  local function flush()
    if #part > 0 then out[#out + 1] = xe.inl(part, o) end
    part = pandoc.Inlines({})
  end
  for _, el in ipairs(il) do
    if el.t == "LineBreak" then flush(); out[#out + 1] = xe.BR
    elseif el.t == "RawInline" and el.format == "openxml" then flush(); out[#out + 1] = el.text
    else part:insert(el) end
  end
  flush()
  return table.concat(out)
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local LB = pandoc.LineBreak()

-- one paragraph: properties in schema order (keep, page break, tabs, spacing, indent, jc), then the runs
local function P(props, il, o)
  return xe.raw(xe.para(props, runs(pandoc.Inlines(il), o)))
end
local function sp(before, after, line) return xe.spacing(before, after, line or SINGLE) end
local IND0 = xe.ind(0, nil, 0)
local CENTER = xe.jc("center")

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n, lower)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return lower and out:lower() or out
end

-- printed label of a numbered heading (typst heading-label): I. / A. / i. / 1. / a.
local function label_for(level, n)
  if level == 1 then return roman(n) .. "." end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return roman(n, true) .. "." end
  if level == 4 then return tostring(n) .. "." end
  if level == 5 then return string.char(96 + n) .. "." end
  fail("headings deeper than level 5 are not supported")
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
-- cover (FRAP 32(a)(2); typst cover-body): single-spaced, centered, 14 pt between its parts
-- ---------------------------------------------------------------------------
-- strings, inlines and inline elements, in order, as one list of inlines
local function cat_str(...)
  local out = pandoc.Inlines({})
  for _, x in ipairs({ ... }) do
    if type(x) == "string" then out:insert(pandoc.Str(x))
    elseif x.t == nil then out:extend(pandoc.Inlines(x))
    else out:insert(x) end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- cover (Fed. Cir. R. 32(a)(1); FRAP 32(a)(2); typst cover-body): single-spaced, centered, 14 pt between its parts
-- ---------------------------------------------------------------------------

local GAP = 280
local function rule_p(kind, before, after)
  local border = kind == "double"
    and '<w:pBdr><w:top w:val="double" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
    or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  local ind = kind == "double" and IND0 or xe.ind(3240, nil, 0, 3240)
  return xe.raw(xe.para({ "<w:keepNext/>", border, sp(before, after, 120), ind }, ""))
end

-- a borderless table of two columns (typst grid (1fr, 1fr), gutter 0.1 in): cells of paragraphs (XML strings)
local COLS = { { 4752, 144 }, { 4608, 0 } }
local function grid(rows)
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="4608"/></w:tblGrid>' }
  for _, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for c = 1, 2 do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. COLS[c][1] .. '" w:type="dxa"/><w:tcMar><w:right w:w="'
        .. COLS[c][2] .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. (row[c] or '<w:p/>') .. '</w:tc>'
    end
    out[#out + 1] = '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return xe.raw(table.concat(out))
end

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  local function centered(il, before, o) add(P({ "<w:keepNext/>", sp(before or 0, 0), IND0, CENTER }, il, o)) end
  local function right(il, before) add(P({ "<w:keepNext/>", sp(before or 0, 0), xe.ind(HALF, nil, 0) }, il)) end
  centered(minl("No. " .. plain(need(meta, "case_number"))), 168, { b = true })
  -- the court's name in a 4 in block, centered
  add(P({ "<w:keepNext/>", sp(GAP, 0), xe.ind(1800, nil, 0, 1800), CENTER },
    { pandoc.Str("UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT") }, { b = true }))
  add(rule_p("short", GAP, GAP))
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for j, name in ipairs(side.names) do centered(minl(name), j > 1 and 98 or 0) end
    right(minl(side.designation), 98)
    if i < #sides then centered({ pandoc.Str("v.") }, 84); add(xe.raw(xe.para({ sp(0, 84, 20) }, ""))) end
  end
  add(rule_p("short", GAP, GAP))
  centered(minl(need(meta, "proceeding")))
  add(rule_p("short", GAP, GAP))
  centered(upper_il(minl(need(meta, "brief_title"))), 0, { b = true })
  add(rule_p("short", GAP, GAP))
  -- counsel (FRAP 32(a)(2)(F)): two groups to a row; each line a paragraph, a line too long for its column hanging
  -- 14 pt; 8.4 pt between the rows
  local groups = need(meta, "counsel")
  local function cell(g)
    local x = {}
    local all = {}
    for _, n in ipairs(g.names) do all[#all + 1] = n end
    for _, l in ipairs(g.lines or {}) do all[#all + 1] = l end
    for _, l in ipairs(all) do
      x[#x + 1] = xe.para({ "<w:keepNext/>", sp(0, 0), xe.ind(280, 280, nil) }, runs(minl(l)))
    end
    return table.concat(x)
  end
  local rows = {}
  for i = 1, #groups, 2 do
    rows[#rows + 1] = { cell(groups[i]), groups[i + 1] and cell(groups[i + 1]) or nil }
  end
  -- rows after the first: 8.4 pt above (the cells' first paragraphs)
  for r = 2, #rows do
    for c = 1, 2 do
      if rows[r][c] then rows[r][c] = rows[r][c]:gsub('w:before="0"', 'w:before="168"', 1) end
    end
  end
  add(xe.raw(xe.para({ "<w:keepNext/>", sp(0, 0, 20) }, "")))
  add(grid(rows))
  centered(minl(need(meta, "counsel_for")), 168)
  add(rule_p("double", GAP, 0))
  return B
end

local TOP_HEAD = '<w:pageBreakBefore/>'
local function page_heading(title)
  -- a heading that opens a page has no space above it (typst drops it at the top of a page; Word keeps it after a
  -- page break)
  return P({ "<w:keepNext/><w:keepLines/>", TOP_HEAD, sp(0, 308), IND0, CENTER }, upper_il(minl(title)), { b = true })
end

-- ---------------------------------------------------------------------------
-- signature and certificates (typst signature-block, certificate-of-compliance, certificate-of-service)
-- ---------------------------------------------------------------------------

-- the right column of the signature [grid (1fr, 3.9 in)]: the first line as it is, every further one 0.5 em in
-- (typst: linebreak, h(0.5em)); a line that wraps goes on at the column's edge
local function sig_par(il, before, first_ind)
  return P({ "<w:keepNext/><w:keepLines/>", sp(before or 0, 0), xe.ind(SIGCOL, nil, first_ind or 0) }, il)
end

local function signature(meta)
  local sig = need(meta, "signature")
  local B = {}
  local dated = meta.date ~= nil and ("Dated: " .. plain(meta.date)) or ""
  B[#B + 1] = P({ "<w:keepNext/><w:keepLines/>", '<w:tabs><w:tab w:val="left" w:pos="' .. SIGCOL .. '"/></w:tabs>',
    sp(392, 0), IND0 }, { pandoc.Str(dated), TAB, pandoc.Str("Respectfully submitted,") })
  B[#B + 1] = sig_par({ pandoc.Str("/s/ " .. plain(sig.signer)) }, 336)
  for _, l in ipairs(sig.lines or {}) do B[#B + 1] = sig_par(minl(l), 0, 140) end
  for _, o in ipairs(sig.also or {}) do
    B[#B + 1] = sig_par(minl(o.name), 336)
    for _, l in ipairs(o.lines or {}) do B[#B + 1] = sig_par(minl(l), 0, 140) end
  end
  B[#B + 1] = P({ "<w:keepLines/>", sp(224, 0), xe.ind(SIGCOL, nil, 0) }, minl(need(meta, "counsel_for")))
  return B
end

local BLANK = string.rep("_", 10)

-- one option of Form 19 [option-row]: the box in a 22.4 pt column, the text hanging after it; 11.2 pt above
local function option_row(checked, text)
  local box = checked and "X" or "\u{00A0}\u{00A0}\u{00A0}"
  return xe.raw(xe.para({ "<w:keepLines/>", '<w:tabs><w:tab w:val="left" w:pos="448"/></w:tabs>', sp(224, 0),
    xe.ind(448, 448, nil) }, xe.runs(box, { box = true }) .. "<w:r><w:tab/></w:r>" .. runs({ pandoc.Str(text) })))
end

local function certificate_of_compliance(meta, words, out)
  out[#out + 1] = page_heading("Certificate of Compliance with Type-Volume Limitations")
  local function para(il, before) out[#out + 1] = P({ sp(before, 0), IND0 }, il) end
  para(cat_str("Case Number: ", minl(need(meta, "case_number"))), 0)
  para(cat_str("Short Case Caption: ", minl(need(meta, "short_caption"))), 280)
  para({ pandoc.Str("Instructions: When computing a word, line, or page count, you may exclude any items listed as " ..
    "exempted under Fed. R. App. P. 5(c), Fed. R. App. P. 21(d), Fed. R. App. P. 27(d)(2), Fed. R. App. P. 32(f), " ..
    "or Fed. Cir. R. 32(b)(2).") }, 280)
  para({ pandoc.Str("The foregoing filing complies with the relevant type-volume limitation of the Federal Rules of " ..
    "Appellate Procedure and Federal Circuit Rules because it meets one of the following:") }, 280)
  out[#out + 1] = option_row(true, "the filing has been prepared using a proportionally-spaced typeface and includes " ..
    group_digits(words) .. " words.")
  out[#out + 1] = option_row(false, "the filing has been prepared using a monospaced typeface and includes " .. BLANK ..
    " lines of text.")
  out[#out + 1] = option_row(false, "the filing contains " .. BLANK .. " pages / " .. BLANK .. " words / " .. BLANK ..
    " lines of text, which does not exceed the maximum authorized by this court\u{2019}s order (ECF No. " .. BLANK .. ").")
  -- [grid (1fr, 1fr), gutter 14 pt]: the date at the margin, the signature and the name in the right column
  out[#out + 1] = P({ "<w:keepNext/><w:keepLines/>", '<w:tabs><w:tab w:val="left" w:pos="' .. FORMCOL .. '"/></w:tabs>',
    sp(448, 0), IND0 }, cat_str("Date: ", minl(need(meta, "date")), TAB,
    pandoc.Str("Signature: /s/ " .. plain(need(meta, "signature").signer))))
  out[#out + 1] = P({ "<w:keepLines/>", sp(280, 0), xe.ind(FORMCOL, nil, 0) },
    { pandoc.Str("Name: " .. plain(need(meta, "signature").signer)) })
end

local function certificate_of_service(meta, out)
  local sig = need(meta, "signature")
  out[#out + 1] = page_heading("Certificate of Service")
  out[#out + 1] = P({ sp(0, 0), IND0 }, cat_str("I hereby certify that on ", minl(need(meta, "date")),
    ", I electronically filed the foregoing ", minl(need(meta, "brief_title")),
    ", with the Court\u{2019}s CM/ECF filing system, which constitutes service, pursuant to Fed. R. App. P. 25(c) and " ..
    "Fed. Cir. R. 25(a)."))
  out[#out + 1] = P({ "<w:keepNext/><w:keepLines/>", '<w:tabs><w:tab w:val="left" w:pos="' .. SIGCOL .. '"/></w:tabs>',
    sp(448, 0), IND0 }, cat_str("Date: ", minl(need(meta, "date")), TAB, pandoc.Str("/s/ " .. plain(sig.signer))))
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = sig_par(minl(l), 0, 140) end
end


-- ---------------------------------------------------------------------------
-- words (Fed. Cir. R. 32(b)): the typst template's count, block by block, headings and footnotes included
-- ---------------------------------------------------------------------------

local function words_in(s)
  local n = 0
  for _ in s:gsub("\194\160", " "):gmatch("%S+") do n = n + 1 end
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
      local without = pandoc.Pandoc({ b }):walk({
        Note = function(note) notes[#notes + 1] = note.content; return {} end,
      })
      n = n + words_in(pandoc.utils.stringify(without.blocks))
      for _, c in ipairs(notes) do n = n + count_blocks(c) end
    end
  end
  return n
end

-- the width of a page list in the table of authorities (typst: max(56 pt, the list's own width)), in twips, from
-- the advance widths of Times New Roman at 14 pt
local ADV = { [","] = 70, [" "] = 70, i = 78, v = 140, x = 140, l = 78, c = 124, p = 140, a = 124, s = 109, m = 218 }
local function list_width(s)
  local w = 0
  for ch in s:gmatch(".") do w = w + (ADV[ch] or 140) end
  return w
end

-- ---------------------------------------------------------------------------
-- the filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  load_pages()
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "short_caption", "counsel",
    "counsel_for", "signature", "date" }) do
    need(meta, k)
  end
  local words = count_blocks(doc.blocks)
  if words > WORD_LIMIT then
    fail("the brief has " .. words .. " words; Fed. Cir. R. 32(b)(1) allows " .. WORD_LIMIT .. " for a reply brief")
  end

  -- every toa: citation in document order, per top-level block, as a needle: the link text and the words after it
  -- in its paragraph (up to a footnote mark or a quotation), so that the same words elsewhere in the brief,
  -- unlinked, are not taken for it. Kind B (body) moves the search on; N (in a footnote) is searched from the page
  -- the body has reached.
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
        list[#list + 1] = { key = el.target:sub(5), kind = kind, text = plain(pandoc.Inlines(el.content)),
          context = plain(pandoc.Inlines(rest)) }
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
  for bi, b in ipairs(doc.blocks) do
    cites[bi] = {}
    scan_blocks({ b }, "B", cites[bi])
  end

  local auth = meta.authorities or {}
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return el.content end
      if auth[key] == nil then fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
      hits[key] = true
      return el.content
    end,
  })
  -- the text each block starts with, before the inline rules (they write some characters as raw runs): what a
  -- heading's needle runs on into
  local leads = {}
  for bi, b in ipairs(doc.blocks) do leads[bi] = lead_text(pandoc.Div(xe.list_items(b))):sub(1, 40) end
  -- the break rules of typst on the text pandoc writes itself (body, footnotes)
  doc = doc:walk({ Inlines = xe.inlines })
  doc = doc:walk({ Str = function(e) return pandoc.Str(slash_breaks(e.text)) end })

  -- the body: headings get their labels; lists their label boxes
  -- The body's page 1 is the page of its first block. A heading's needle is its label and title and the text after it
  -- (the next block, as printed), so the same words earlier on the page are not taken for it.
  local blocks = doc.blocks
  local body_id = "S:body"
  if blocks[1] and blocks[1].t ~= "Header" then need_at(body_id, "B", leads[1], "") end
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
  local counters = { 0, 0, 0, 0, 0, 0 }
  for bi, b in ipairs(blocks) do
    if b.t == "Header" then
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      local lab = label_for(b.level, counters[b.level])
      local first = #body == 0 -- none above the heading that opens the body's first page
      if b.level == 1 then
        -- [style-heading, numbered, level 1]: centered, bold, the label and the title in capitals; 21 / 15.4 pt
        body[#body + 1] = P({ "<w:keepNext/><w:keepLines/>", sp(first and 0 or 420, 308), IND0, CENTER },
          cat_str(lab .. " ", upper_il(b.content)), { b = true })
      else
        -- [style-heading]: the label in a half-inch box at its indent, the text hanging after it; 15.4 / 12.6 pt
        local ind = (b.level - 1) * 720
        local o = { b = true, i = b.level >= 4 }
        body[#body + 1] = xe.raw(xe.para({ "<w:keepNext/><w:keepLines/>",
          '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + 720) .. '"/></w:tabs>', sp(first and 0 or 308, 252),
          xe.ind(ind + 720, 720, nil) },
          runs({ pandoc.Str(lab) }, o) .. "<w:r><w:tab/></w:r>" .. runs(b.content, o)))
      end
      local title = b.level == 1 and upper_il(b.content) or b.content
      local id = "H:" .. (#heads + 1)
      if bi == 1 then body_id = id end
      flush(lab .. " " .. plain(title))
      pending = { id = id, text = lab .. " " .. plain(title), bi = bi }
      heads[#heads + 1] = { level = b.level, label = lab, title = title, id = id }
    else
      flush(leads[bi])
      -- a paragraph that anchors a footnote has no widow control: typst's widow and orphan rules do not see the note,
      -- so a line whose note does not fit moves to the next page alone
      local note = false
      if b.t == "Para" then pandoc.Pandoc({ b }):walk({ Note = function(n) note = true return n end }) end
      if note then
        body[#body + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Body Text Note" }))
      else
        for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
      end
      cite_needles(bi)
    end
  end
  flush("")

  -- the printed pages of an authority: its distinct pages in the order cited (every page is listed: "passim" is
  -- not used, proposed Fed. Cir. R. 32(j); typst toa-section)
  local function pages_of(key)
    local ls, seen = {}, {}
    for _, o in ipairs(occurrences) do
      local l = label_of(o.id)
      if o.key == key and not seen[l] then seen[l] = true; ls[#ls + 1] = l end
    end
    return table.concat(ls, ", ")
  end

  -- the needles, in document order: the contents (its heading and the "Page" over its column), the body's
  table.insert(needles, 1, { id = "S:toc", kind = "B", needle = norm("Table of Contents Page"),
    fallback = norm("Table of Contents") })
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: the contents are page i, the body and the certificates from the body's first block
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdRomanFtr\t" .. FOOTER_P .. "\nrIdArabicFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", SECT_BODY)

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- section 1: the cover (no page number)
  addall(cover(meta))
  add(xe.raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. SECT_COVER .. '</w:pPr></w:p>'))

  -- section 2 (lower roman): the table of contents [toc-entry, listing-row]
  add(P({ "<w:keepNext/><w:keepLines/>", sp(0, 308), IND0, CENTER }, { pandoc.Str("TABLE OF CONTENTS") }, { b = true }))
  add(P({ "<w:keepNext/>", sp(84, 0), IND0, xe.jc("right") }, { pandoc.Str("Page") }, { b = true, u = true }))
  for _, h in ipairs(heads) do
    if h.level <= TOC_DEPTH then
      local ind = (h.level - 1) * 720
      local page = label_of(h.id)
      local il = pandoc.Inlines({ pandoc.Str(h.label), TAB })
      il:extend(h.title)
      il:insert(pandoc.Str(xe.LEAD))
      il:insert(pandoc.Str(page))
      add(P({ "<w:keepLines/>", '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + 720) ..
        '"/><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>',
        sp(h.level == 1 and 168 or 98, 0), xe.ind(ind + 720, 720, nil, TOC_COL) }, il))
    end
  end

  -- the table of authorities (its own page); every page is listed ("passim" is not used)
  add(page_heading("Table of Authorities"))
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    local function sk(a)
      local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
      return (s:lower():gsub("[^a-z0-9 ]", ""))
    end
    table.sort(members, function(x, y)
      local kx, ky = sk(x.a), sk(y.a)
      if kx == ky then return x.key < y.key end
      return kx < ky
    end)
    if #members > 0 then
      -- the group: 14 pt below the heading (the first, with the column head), 19.6 pt after the last entry
      local head = runs({ pandoc.Str(g[2]) }, { b = true })
      if first then head = head .. "<w:r><w:tab/></w:r>" .. runs({ pandoc.Str("Page(s)") }, { b = true, u = true }) end
      add(xe.raw(xe.para({ "<w:keepNext/>", '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>',
        sp(first and 280 or 392, 56), IND0 }, head)))
      first = false
      for _, m in ipairs(members) do
        local page = pages_of(m.key)
        local il = pandoc.Inlines({})
        if m.a.name ~= nil then
          local nm = minl(m.a.name)
          if g[1] == "case" then il:insert(pandoc.Emph(nm)) else il:extend(nm) end
          il:insert(pandoc.Str(",")); il:insert(LB)
        end
        il:extend(minl(m.a.cite))
        il:insert(pandoc.Str(xe.LEAD))
        il:insert(pandoc.Str(page))
        local col = math.max(TOA_COL, list_width(page))
        add(P({ "<w:keepLines/>", xe.leader_tab(TEXTW), sp(196, 0), xe.ind(504, 504, nil, col) }, il))
      end
    end
  end
  add(xe.raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. SECT_ROMAN .. '</w:pPr></w:p>'))

  -- section 3 (arabic from 1): the body, the signature block (kept whole), the certificates
  addall(body)
  addall(signature(meta))
  certificate_of_compliance(meta, words, out)
  certificate_of_service(meta, out)

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({}) -- pandoc would print the date and title as a block at the top
  return doc
end
