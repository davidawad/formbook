-- ca5 answering brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The cover, front statements, table of contents, table of authorities, signature block and certificates are written
-- here as paragraphs in the "CA ..." styles of reference.docx (raw WordprocessingML, one paragraph per call to P); the
-- body keeps its markdown structure. Headings get their labels (I. A. 1. a.) as text, with a tab. The typst template
-- (../typst/ca5-answering-brief.typ) is the reference for every line and page break (cross-engine layout model,
-- docs/EVAL-LOOP.md; lib/docx/xengine.lua). Sections (cover: counted, no number; the rest: arabic going on, so the
-- page after the cover is "2") are a section break and the last section (FORMBOOK_FINAL), which names the footer
-- this filter gives fb render (FORMBOOK_FOOTERS: rIdArabicFtr, a centered PAGE field). The TOC and TOA page numbers:
-- fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of every heading and citation in that
-- PDF (the needles this filter writes to FORMBOOK_NEEDLES) and renders again with those pages (FORMBOOK_PAGES) until
-- they settle (were docx/render.sh and docx/pagemap.awk). Styles: docx/reference.xml. No case-specific text in this
-- file.

local WORD_LIMIT = 13000   -- CA5-LEN-001: FRAP 32(a)(7)(B)(i)
local TOC_DEPTH = 4
local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

-- The cross-engine layout model (lib/docx/xengine.lua): the break rules of typst on every run (a no-break hyphen
-- before a digit, pandoc's abbreviation no-break spaces undone, a section sign bound to its number).
local xe = require("docx.xengine")
-- One more rule, as typst's xengine has it: no break inside a token of adjacent parentheses ("32(a)(7)(B)"); a word
-- joiner (U+2060) between ")" and "(" (LibreOffice and Word would break there).
local function xinl(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(xe.inlines(l)) do
    if el.t == "Str" and el.text:find(")(", 1, true) then
      out:insert(pandoc.Str((el.text:gsub("%)%(", ")\u{2060}("))))
    else
      out:insert(el)
    end
  end
  return out
end
-- Before the page number of a table row: three no-break spaces, so the leader is never shorter than that.
local LEAD = pandoc.Str("\u{00A0}\u{00A0}\u{00A0}")
local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local LB = pandoc.LineBreak()
-- the cover: counted as page 1 (decimal from 1), no footer; the last section (FORMBOOK_FINAL) goes on in arabic
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'
-- the footer (centered PAGE field) and the last section, which names it
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT_BODY = '<w:sectPr><w:footerReference w:type="default" r:id="rIdArabicFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function fail(msg) error("ca5-answering-brief: " .. msg, 0) end

-- a metadata value as inlines
local function minl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then return pandoc.Inlines({ pandoc.Str(v) }) end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  if v.t == nil then return pandoc.Inlines(v) end
  return pandoc.Inlines(pandoc.utils.stringify(v))
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
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(e.text:upper()) end }).content
end

local function cat(...)
  local out = pandoc.Inlines({})
  for _, x in ipairs({ ... }) do
    if type(x) == "string" then out:insert(pandoc.Str(x))
    elseif x.t == nil then out:extend(pandoc.Inlines(x))
    else out:insert(x) end
  end
  return out
end

-- inline content as WordprocessingML runs (emphasis, strong, line breaks, raw openxml)
local function xesc(s) return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
local function run(text, f)
  local rpr = (f.b and "<w:b/>" or "") .. (f.i and "<w:i/>" or "") .. (f.u and '<w:u w:val="single"/>' or "")
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end
local function inl_xml(il, f, out)
  for _, el in ipairs(il) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then inl_xml(el.content, { b = f.b, i = true, u = f.u }, out)
    elseif t == "Strong" then inl_xml(el.content, { b = true, i = f.i, u = f.u }, out)
    elseif t == "Underline" then inl_xml(el.content, { b = f.b, i = f.i, u = true }, out)
    elseif t == "Span" or t == "Link" or t == "SmallCaps" then inl_xml(el.content, f, out)
    elseif t == "RawInline" then
      if el.format == "openxml" then out[#out + 1] = el.text end
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
end

-- one paragraph as WordprocessingML: style, inlines, optional extra pPr elements in schema order, run format
local function P_xml(style, il, extra, f)
  local d = pandoc.Pandoc({ pandoc.Plain(pandoc.Inlines(il)) }):walk({ Inlines = xinl })
  local out = {}
  inl_xml(d.blocks[1].content, f or {}, out)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. "</w:pPr>" .. table.concat(out) .. "</w:p>"
end
local function P(style, il, extra, f) return pandoc.RawBlock("openxml", P_xml(style, il, extra, f)) end
local function raw_p(xml) return pandoc.RawBlock("openxml", xml) end
local KEEP = "<w:keepNext/>"
-- the empty paragraph that ends a section takes no room (it would push a full page's last line on)
local SECT_LINE = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
local BREAK_BEFORE = "<w:pageBreakBefore/>"
-- a section heading that opens a page has no space above it (typst drops it at the top of a page; Word keeps it
-- after a section or page break)
local TOP = '<w:spacing w:before="0" w:after="308" w:line="400" w:lineRule="exact"/>'
local function sp(b, a) return string.format('<w:spacing w:before="%d" w:after="%d" w:line="400" w:lineRule="exact"/>', b, a) end

local function rule(style) return raw_p('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>') end


local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- printed label of a numbered heading (typst heading-label). Argument: I. / A. / 1. / a.  Elsewhere: A. / 1. / a. / (1)
local function label_for(level, n, in_arg)
  if in_arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    if level == 5 then return string.char(96 + n) .. "." end
  else
    if level == 2 then return string.char(64 + n) .. "." end
    if level == 3 then return tostring(n) .. "." end
    if level == 4 then return string.char(96 + n) .. "." end
    if level == 5 then return "(" .. n .. ")" end
  end
  fail("headings deeper than level 5 are not supported")
end

-- label indent steps (half inches; typst label-indent): labels half an inch in, a step per level; in the Argument the
-- level-2 point heading is centered, so its sub-headings start at the first step
local function steps_for(level, in_arg)
  return level - (in_arg and 3 or 2) + 1
end


-- ---------------------------------------------------------------------------
-- Words (CA5-LEN-001): the typst template's count-words on the markdown source of the body (all of it but the
-- frontmatter and an addendum); the LaTeX engine counts the same way.
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then fail("no input file to count words in") end
  local h = assert(io.open(f, "r"))
  local src = h:read("a")
  h:close()
  local t = src:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1)
  t = "\n" .. t
  local a = t:lower():find("\n#[ \t]+addendum[ \t]*\n") or t:lower():find("\n#[ \t]+addendum[ \t]*$")
  if a then t = t:sub(1, a) end
  t = t:gsub("<!%-%-.-%-%->", " ")
  t = t:gsub("\n%[%^[^%]]+%]:", "\n ")
  t = t:gsub("%[%^[^%]]+%]", "")
  t = t:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
  t = t:gsub("\n#+[ \t]+", "\n")
  t = t:gsub("\n>[ \t]?", "\n")
  t = t:gsub("\n[ \t]*[-*+][ \t]+", "\n")
  t = t:gsub("\n[ \t]*%d+[.)][ \t]+", "\n")
  t = t:gsub("\\(.)", "%1")
  t = t:gsub("%*", "")
  t = t:gsub('([%s%(%[\"])_', "%1"):gsub("\u{201C}_", "\u{201C}")
  t = t:gsub('_([%s%.,;:%)%]\"!%?])', "%1"):gsub("_\u{201D}", "\u{201D}"):gsub("_$", "")
  local n = 0
  for _ in t:gmatch("%S+") do n = n + 1 end
  return n
end

-- ---------------------------------------------------------------------------
-- needles and pages (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60   -- a needle is a prefix of the text (letters and digits only)
local PASSIM = 7        -- an authority cited on this many pages or more is "passim"

-- letters and digits only, lower case: fb render normalizes the PDF text the same way
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- a needle: { id, kind, needle, fallback }; kind B (body, in document order: moves the search on) or N (inside a
-- footnote: searched from the page the body has reached, moves nothing). The fallback, for a needle that runs over
-- a page end (the folio and the footnotes come between its halves), is the text's first two words.
local needles = {}
local function need_at(id, kind, text, context)
  local w1, w2 = text:match("^%s*(%S+)%s+(%S+)")
  local short = norm(w1 and (w1 .. " " .. w2) or text):sub(1, NEEDLE_MAX)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- the pages of the previous pass: id -> printed page; empty on the first pass
local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
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
-- cover (FRAP 32(a)(2); typst cover-body): the parts and rules without the gaps between them (typst shrinks its gaps
-- until the cover fits a page; Word cannot, so the docx cover is the tightest one, and its lines break the same)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  add(P("CACentered", { pandoc.Strong(cat("No. ", minl(need(meta, "case_number")))) }))
  add(rule("CADoubleRule"))
  add(P("CACoverCourt", { pandoc.Str("IN THE UNITED STATES COURT OF APPEALS FOR THE FIFTH CIRCUIT") }))
  add(rule("CARule"))
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(P("CACentered", minl(name))) end
    add(P("CACaption", minl(side.designation)))
    if i < #sides then add(P("CACentered", { pandoc.Str("v.") })) end
  end
  add(rule("CARule"))
  add(P("CACentered", minl(need(meta, "proceeding"))))
  add(rule("CARule"))
  add(P("CACentered", { pandoc.Strong(upper_il(minl(need(meta, "brief_title")))) }))
  add(rule("CARule"))
  -- counsel (FRAP 32(a)(2)(F)): in the right half, the lines in italics 0.5 em in, the telephone with the last group,
  -- 7 pt between the groups
  local groups = need(meta, "counsel")
  for gi, g in ipairs(groups) do
    for ni, n in ipairs(g.names) do
      add(P("CACaption", minl(n), KEEP .. (gi > 1 and ni == 1 and '<w:spacing w:before="140" w:after="0" w:line="400" w:lineRule="exact"/>' or "")))
    end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = need(meta, "phone") end
    for _, l in ipairs(lines) do
      add(P("CACaption", { pandoc.Emph(minl(l)) }, KEEP .. '<w:ind w:left="4820" w:firstLine="0"/>'))
    end
  end
  if meta.counsel_for ~= nil then
    add(P("CACaption", { pandoc.Strong(upper_il(minl(meta.counsel_for))) },
      '<w:spacing w:before="112" w:after="0" w:line="400" w:lineRule="exact"/>'))
  end
  add(rule("CADoubleRule"))
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_COVER .. '</w:pPr></w:p>'))
  return B
end

-- ---------------------------------------------------------------------------
-- signature and certificates
-- ---------------------------------------------------------------------------

-- [signature-block]: "Respectfully submitted," (19.6 pt above), 16.8 pt, "s/ Name", the name in capitals, the lines
-- in italics 0.5 em in, all in the right half; the date at the margin 11.2 pt below
local function signature(meta)
  local sig = need(meta, "signature")
  local B = {}
  B[#B + 1] = P("CASigHead", { pandoc.Str("Respectfully submitted,") }, KEEP)
  B[#B + 1] = P("CASignature", cat(pandoc.Str("s/ " .. plain(sig.signer)), LB, pandoc.Str(plain(sig.signer):upper())),
    KEEP .. '<w:spacing w:before="336" w:after="0" w:line="400" w:lineRule="exact"/>')
  for _, l in ipairs(sig.lines or {}) do
    B[#B + 1] = P("CASignature", { pandoc.Emph(minl(l)) }, KEEP .. '<w:ind w:left="4820" w:firstLine="0"/>')
  end
  if meta.date ~= nil then
    B[#B + 1] = P("CASignature", minl(meta.date),
      '<w:spacing w:before="224" w:after="0" w:line="400" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/>')
  end
  return B
end

-- [signature-mark]: "s/ Name" over the first line of the signature, 45 % in, 19.6 pt below the text
local function signature_mark(meta)
  local sig = need(meta, "signature")
  local il = cat(pandoc.Str("s/ " .. plain(sig.signer)))
  local lines = sig.lines or {}
  if #lines > 0 then il:insert(LB); il:extend(minl(lines[1])) end
  return P("CAMark", il, '<w:spacing w:before="392" w:after="0" w:line="400" w:lineRule="exact"/>')
end

-- ---------------------------------------------------------------------------
-- the filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "prepared_with" }) do
    need(meta, k)
  end
  local auth = meta.authorities or {}
  load_pages()

  -- every toa: citation in document order, per top-level block, for a needle: the link text and the words after it
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

  -- every toa: citation keeps its text; the key must be in the registry
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
  -- the break rules of typst on the text pandoc writes itself (body, footnotes)
  doc = doc:walk({ Inlines = xinl })

  local words = source_words()
  if words > WORD_LIMIT then fail("the brief has " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. WORD_LIMIT) end

  -- the TOC entries in document order: the front statements, the table of authorities, the body headings, the
  -- certificates; each is a needle (its label and title, with the first words after it), in document order with
  -- the citations. The cover's first line starts the page count (the cover is page 1); the contents' heading moves
  -- the search past the contents, and the authorities' heading is searched with its first group's head, so the
  -- contents' "TABLE OF AUTHORITIES" line is not taken for it.
  local heads = {}
  local function head(level, label, title, steps, context)
    local idx = #heads + 1
    local text = plain(title)
    heads[idx] = { level = level, label = label, title = title, steps = steps, idx = idx, id = "H:" .. idx }
    need_at(heads[idx].id, "B", label ~= "" and (label .. " " .. text) or text, context)
    return idx
  end
  local svc = meta.service
  local has_svc = svc ~= nil and svc.certificate == true
  local toa_first = ""
  for _, g in ipairs(TOA_GROUPS) do
    for key, a in pairs(auth) do
      if toa_first == "" and plain(a.kind) == g[1] and hits[key] then toa_first = g[2] end
    end
  end
  need_at("S:cover", "B", "No. " .. plain(need(meta, "case_number")), "")
  if meta.interested_persons ~= nil then
    head(1, "", { pandoc.Str("Certificate of Interested Persons") }, 0, plain(meta.interested_persons):sub(1, 40))
  end
  if meta.oral_argument ~= nil then
    head(1, "", { pandoc.Str("Statement Regarding Oral Argument") }, 0, plain(meta.oral_argument):sub(1, 40))
  end
  need_at("S:toc", "B", "Table of Contents", "Page")
  head(1, "", { pandoc.Str("Table of Authorities") }, 0, toa_first)

  -- the body: headings get their labels; the addendum is not produced by this engine
  local occurrences = {}
  local function cite_needles(bi)
    for _, c in ipairs(cites[bi] or {}) do
      occurrences[#occurrences + 1] = { key = c.key, id = "T:" .. (#occurrences + 1) }
      need_at(occurrences[#occurrences].id, c.kind, c.text, c.context)
    end
  end
  -- the label of every heading, for the words after a heading: a heading followed by another is searched with that
  -- one's label and title
  local labels_at = {}
  do
    local c, arg = { 0, 0, 0, 0, 0, 0 }, false
    for bi, b in ipairs(doc.blocks) do
      if b.t == "Header" then
        if b.level == 1 then arg = plain(b.content):lower():match("^%s*argument%s*$") ~= nil end
        c[b.level] = c[b.level] + 1
        for i = b.level + 1, 6 do c[i] = 0 end
        labels_at[bi] = b.level == 1 and "" or label_for(b.level, c[b.level], arg)
      end
    end
  end
  local function after(bi)
    local b = doc.blocks[bi]
    if b == nil then return "" end
    if b.t == "Header" then return (labels_at[bi] ~= "" and (labels_at[bi] .. " ") or "") .. plain(b.content) end
    return plain(b):sub(1, 40)
  end
  local body = {}
  local counters, in_arg = { 0, 0, 0, 0, 0, 0 }, false
  local has = {}
  for bi, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = plain(b.content)
      local nxt = after(bi + 1)
      if b.level == 1 and text:lower():match("^%s*addendum%s*$") then
        fail("the DOCX engine does not yet render an addendum (FRAP 28(f)); see the Engines section of the README")
      end
      if b.level == 1 then
        in_arg = text:lower():match("^%s*argument%s*$") ~= nil
        has[text:lower():gsub("^%s+", ""):gsub("%s+$", "")] = true
      end
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      if b.level == 1 then
        head(1, "", b.content, 0, nxt)
        body[#body + 1] = P("CASection", b.content, KEEP .. (#body == 0 and (BREAK_BEFORE .. TOP) or ""))
      else
        local label = label_for(b.level, counters[b.level], in_arg)
        if in_arg and b.level == 2 then
          head(2, label, b.content, 0, nxt)
          body[#body + 1] = P("CAPoint", cat(label, " ", b.content), KEEP)
        else
          local s = steps_for(b.level, in_arg)
          head(b.level, label, b.content, s, nxt)
          body[#body + 1] = P("CAHeadL" .. b.level .. "S" .. s, cat(label, TAB, b.content), KEEP)
        end
      end
    else
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
    cite_needles(bi)
  end
  if not has["argument"] then fail("the brief has no `# Argument` section (FRAP 28(a)(8))") end
  if not has["conclusion"] then fail("the brief has no `# Conclusion` section (FRAP 28(a)(9))") end
  local idx_svc = has_svc and head(1, "", { pandoc.Str("Certificate of Service") }, 0, "I certify that on") or nil
  local idx_cc = head(1, "", { pandoc.Str("Certificate of Compliance") }, 0, "1. This brief complies")

  -- the last paragraph stays whole and with the signature block (typst keeps them together)
  if #body > 0 and body[#body].t == "Para" then
    body[#body] = pandoc.Div({ body[#body] }, pandoc.Attr("", {}, { ["custom-style"] = "CA Body Last" }))
  end

  -- the printed pages of an authority: its distinct pages in the order cited; passim from PASSIM pages
  local function pages_of(key)
    local ls, seen = {}, {}
    for _, o in ipairs(occurrences) do
      local l = label_of(o.id)
      if o.key == key and not seen[l] then seen[l] = true; ls[#ls + 1] = l end
    end
    if #ls >= PASSIM then return "passim" end
    return table.concat(ls, ", ")
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: arabic from the cover (page 1) on
  nl[#nl + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdArabicFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", SECT_BODY)

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- the cover (page 1, no number)
  addall(cover(meta))

  -- front statements (5th Cir. R. 28.2.1; FRAP 28(b)), each on its own page, double spaced
  local first_page = true
  local function page_head(title)
    add(P("CASection", { pandoc.Str(title) }, (first_page and "" or BREAK_BEFORE) .. TOP))
    first_page = false
  end
  if meta.interested_persons ~= nil then
    page_head("Certificate of Interested Persons")
    add(pandoc.Para(minl(meta.interested_persons):walk({ Inlines = xinl })))
    add(signature_mark(meta))
  end
  if meta.oral_argument ~= nil then
    page_head("Statement Regarding Oral Argument")
    add(pandoc.Para(minl(meta.oral_argument):walk({ Inlines = xinl })))
  end

  -- table of contents
  page_head("Table of Contents")
  add(P("CATocPage", { pandoc.Str("Page") }))
  local function folio_il(v)
    if v == "passim" then return { pandoc.Emph({ pandoc.Str("passim") }) } end
    return { pandoc.Str(v) }
  end
  for _, h in ipairs(heads) do
    if h.level <= TOC_DEPTH then
      local page = label_of(h.id)
      if h.level == 1 then
        add(P("CATocTop", cat(upper_il(h.title), LEAD, TAB, folio_il(page))))
      else
        add(P("CATocS" .. h.steps, cat(h.label, TAB, h.title, LEAD, TAB, folio_il(page))))
      end
    end
  end

  -- table of authorities (its own page)
  page_head("Table of Authorities")
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
    table.sort(members, function(x, y) return sk(x.a) < sk(y.a) end)
    if #members > 0 then
      local hd = { pandoc.Str(g[2]) }
      if first then hd[#hd + 1] = TAB; hd[#hd + 1] = pandoc.Strong({ pandoc.Underline({ pandoc.Str("Page(s)") }) }) end
      -- the first group 14 pt below the heading, the others 19.6 pt below the last entry
      add(P("CAToaGroup", hd, first and '<w:spacing w:before="280" w:after="56" w:line="400" w:lineRule="exact"/>' or nil))
      first = false
      for _, m in ipairs(members) do
        local il = pandoc.Inlines({})
        if m.a.name ~= nil then
          local nm = minl(m.a.name)
          if g[1] == "case" then il:insert(pandoc.Emph(nm)) else il:extend(nm) end
          il:insert(pandoc.Str(",")); il:insert(LB)
        end
        il:extend(minl(m.a.cite))
        il:insert(LEAD)
        il:insert(TAB)
        il:extend(folio_il(pages_of(m.key)))
        add(P("CAToaEntry", il))
      end
    end
  end

  -- the body (its first heading opens a page), the signature block, the certificates
  addall(body)
  addall(signature(meta))

  if has_svc then
    add(P("CASection", { pandoc.Str("Certificate of Service") }, BREAK_BEFORE .. TOP))
    add(P("CACertificate", cat("I certify that on ", minl(need(meta, "date")),
      ", the foregoing document was electronically filed with the Clerk of the Court for the United States Court of Appeals for the Fifth Circuit using the electronic case filing system of the Court. I further certify that I have complied with the privacy and redaction requirements of Fed. R. App. P. 25(a)(5).")))
    if svc.recipients ~= nil then add(P("CACertificate", minl(svc.recipients))) end
    add(signature_mark(meta))
  end
  add(P("CASection", { pandoc.Str("Certificate of Compliance") }, BREAK_BEFORE .. TOP))
  -- "1." and 0.4 em, then the text (typst: 1.#h(0.4em)): a tab at the width of "1." (10.5 pt) and 0.4 em (5.6 pt)
  local tab = '<w:tabs><w:tab w:val="left" w:pos="322"/></w:tabs>'
  add(P("CACertificate", cat("1.", TAB, "This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because: this brief contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f)."), tab))
  add(P("CACertificate", cat("2.", TAB, "This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because: this brief has been prepared in a proportionally spaced typeface using ", minl(need(meta, "prepared_with")), "."), tab))
  add(signature_mark(meta))

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({})   -- pandoc would print the date and title as a block at the top
  return doc
end
