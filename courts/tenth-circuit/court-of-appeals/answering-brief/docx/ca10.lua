-- ca10.lua (docx engine): the Tenth Circuit answering brief as Word paragraphs and sections (typst:
-- ca10-answering-brief.typ, the reference). pandoc writes the body text (paragraphs, lists, quotations, footnotes)
-- with docx/reference.docx; this filter writes what needs Word formatting:
--   * the cover (FRAP 32(a)(2); 10th Cir. R. 28.2(C)(1)-(2)), the table of contents, the table of authorities, the
--     statement of prior or related appeals, the signature block, the statement of counsel as to oral argument and
--     the certificates (compliance, digital submission, service), as paragraphs with explicit spacing and indents;
--   * the body headings (kept as typed: centered section headings, hanging point headings) with outline levels;
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page
--     of every heading and citation in that PDF (the needles this filter writes), and renders again with them. A
--     citation is every match of an authority's `search` pattern in the body and the back matter, as typst tags it;
--   * the sections whose footers number the pages: cover (i, no number shown), front matter (ii, iii ...), body and
--     certificates (1, 2 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in exact line boxes of the typst
-- pitches, the typst spaces in twips (20 x pt), the break rules of lib/docx/xengine.lua.

local TYPEFACE = "Times New Roman" -- typst font-family.first()
local PASSIM = 7           -- typst passim-threshold
local TAB = 720            -- half an inch (para-indent), in twips
local HANG = 576           -- typst list-hang and cert-indent, 0.4 in
local TEXT_W = 9360        -- the text width, 6.5 in
local SIG_W = 4680         -- typst sig-indent, 3.25 in
local PNUM_TOC = 720       -- typst toc-page-col, 36 pt
local PNUM_TOA = 1120      -- typst toa-page-col, 56 pt
local SINGLE = 376         -- typst pitch-single, 18.8 pt
local DOUBLE = 562         -- typst pitch-double, 28.1 pt (CA10-FORM-003)
local H1, H1_SZ = 480, 39  -- typst pitch-h1 and h1-size (19.5 pt)
local H2, H2_SZ = 400, 34  -- typst pitch-h2 and h2-size (17 pt)
local GAP = 70             -- typst single-gap, 3.5 pt
local TITLE_ABOVE, TITLE_BELOW = 260, 96
local CERT_GAP = 294       -- typst cert-gap, 14.7 pt
local SIG_GAP = 406        -- typst sig-gap, 20.3 pt
local NEEDLE_MAX = 60

local stringify = pandoc.utils.stringify

local xe = require("docx.xengine")
local runs, inl = xe.runs, xe.inl
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, BR, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.BR, xe.LEAD
local list_items = xe.list_items

local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

local function dot_tabs()
  return xe.leader_tab(TEXT_W)
end

local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="608" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function need_meta(meta, k)
  if meta[k] == nil then error("ca10.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- ---------------------------------------------------------------------------
-- Needles and pages (docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function opening(text)
  local out = ""
  for w in text:gmatch("%S+") do
    out = out .. norm(w)
    if #out >= 8 then break end
  end
  return out:sub(1, NEEDLE_MAX)
end

local function need(id, kind, text, context)
  local short = opening(text)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = label } end
  end
  f:close()
end

local function label_of(id)
  local l = labels[id]
  if l then return l.label end
  return "00"
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Citations: every match of an authority's `search` pattern (a regex of literal text, `.` any character, `\`
-- escaping), as the typst template's show rule tags them; one alternation, leftmost match first.
-- ---------------------------------------------------------------------------

local function lua_pattern(re)
  local out, i = {}, 1
  while i <= #re do
    local c = re:sub(i, i)
    if c == "\\" then
      local n = re:sub(i + 1, i + 1)
      out[#out + 1] = n:match("%p") and ("%" .. n) or n
      i = i + 2
    else
      out[#out + 1] = c:match("[%(%)%%%+%-%*%?%[%]%^%$]") and ("%" .. c) or c
      i = i + 1
    end
  end
  return table.concat(out)
end

local patterns = {} -- { key, pat }, in the frontmatter's order (typst's alternation order)
local hits = {}     -- { key, index }, in document order

-- The citations in `text` (a paragraph's text): a needle for each, kind B (body) or N (footnote).
local function cite_needles(text, kind)
  local pos = 1
  while true do
    local best_s, best_e, keys
    for _, p in ipairs(patterns) do
      local s, e = text:find(p.pat, pos)
      if s and (not best_s or s < best_s) then best_s, best_e = s, e end
    end
    if not best_s then return end
    local m = text:sub(best_s, best_e)
    keys = {}
    for _, p in ipairs(patterns) do
      if m:find(p.pat) then keys[#keys + 1] = p.key end
    end
    for _, k in ipairs(keys) do hits[#hits + 1] = { key = k, index = #hits + 1 } end
    need("T:" .. #hits, kind, m, text:sub(best_e + 1, best_e + 40))
    pos = best_e + 1
  end
end

-- The text of a block, its footnotes apart (each scanned as kind N after it).
local function scan_block(b)
  local notes = {}
  local without = pandoc.Pandoc({ b }):walk({
    Note = function(n) notes[#notes + 1] = n.content; return {} end,
  })
  if b.t == "BulletList" or b.t == "OrderedList" then
    for _, item in ipairs(b.content) do
      for _, x in ipairs(item) do cite_needles(stringify(x), "B") end
    end
  else
    cite_needles(stringify(without.blocks), "B")
  end
  for _, n in ipairs(notes) do
    for _, x in ipairs(n) do cite_needles(stringify(x), "N") end
  end
end

-- ---------------------------------------------------------------------------
-- Break opportunities typst has and LibreOffice would not, or the other way round:
--   * typst never breaks inside a token of adjacent parentheses ("32(a)(7)(B)", "34(2)(a)-(c)": lib/typst/xengine.typ
--     boxes it); LibreOffice would break between ")" and "(" or after a hyphen in it: a word joiner (U+2060) between
--     every two characters of such a token;
--   * the tag the typst template puts after each citation splits the text there, so a parenthesis token right after a
--     citation ("Fed. R. App. P. 34" + "(2)(a)-(c)") is a box of its own that may start a line: a zero-width space.
-- ---------------------------------------------------------------------------

local WJ, ZWSP = "\u{2060}", "\u{200B}"

local function bind_token(tok)
  if not tok:find(")(", 1, true) then return tok end
  local cs = {}
  for _, c in utf8.codes(tok) do cs[#cs + 1] = utf8.char(c) end
  return table.concat(cs, WJ)
end

-- In plain text: every token of adjacent parentheses bound.
local function bp(s)
  local parts = {}
  for seg in (s .. ZWSP):gmatch("(.-)" .. ZWSP) do parts[#parts + 1] = (seg:gsub("%S+", bind_token)) end
  return table.concat(parts, ZWSP)
end

-- In a list of inlines: a zero-width space after a citation that ends inside a word whose rest is a parenthesis token.
local function tag_breaks(list)
  local text, owner = {}, {}
  for i, el in ipairs(list) do
    local s = el.t == "Str" and el.text or ((el.t == "Space" or el.t == "SoftBreak") and " " or "\0")
    for k = 1, #s do text[#text + 1] = s:sub(k, k); owner[#owner + 1] = { i, k } end
  end
  local str = table.concat(text)
  local cuts = {}
  for _, p in ipairs(patterns) do
    local pos = 1
    while true do
      local _, e = str:find(p.pat, pos)
      if not e then break end
      local rest = str:sub(e + 1):match("^%S+")
      if rest and rest:find(")(", 1, true) and owner[e + 1] and owner[e + 1][1] == owner[e][1] then
        cuts[#cuts + 1] = owner[e]
      end
      pos = e + 1
    end
  end
  if #cuts == 0 then return nil end
  table.sort(cuts, function(a, b) return a[1] > b[1] or (a[1] == b[1] and a[2] > b[2]) end)
  for _, c in ipairs(cuts) do
    local el = list[c[1]]
    list[c[1]] = pandoc.Str(el.text:sub(1, c[2]) .. ZWSP .. el.text:sub(c[2] + 1))
  end
  return list
end

local function bind_inlines(x)
  return pandoc.Inlines(x):walk({ Inlines = tag_breaks }):walk({ Str = function(s) return pandoc.Str(bp(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Paragraphs
-- ---------------------------------------------------------------------------

-- A title the template prints (typst section-title): bold, centered, single-spaced. `brk`: it opens a page.
local function title(text, before, brk)
  return para({ KEEP, brk and BREAK or "", spacing(brk and 0 or (before or TITLE_ABOVE), TITLE_BELOW), ind(0, nil, 0),
    jc("center") }, runs(text, { b = true }))
end

-- A single-spaced paragraph (typst spar).
local function spar(body, before, center, keep)
  return para({ keep and KEEP or LINES, spacing(before or GAP, GAP), ind(0, nil, 0), center and jc("center") or "" }, body)
end

-- A signature in the right half: `first` and the signer's lines (typst sig-block).
local function sig_block(meta, first, before)
  local out = { para({ KEEP, spacing(before or SIG_GAP, 0), ind(SIG_W) }, first) }
  for _, l in ipairs(meta.signature.lines or {}) do
    out[#out + 1] = para({ KEEP, spacing(0, 0), ind(SIG_W) }, inl(l, {}))
  end
  out[#out] = out[#out]:gsub(KEEP, LINES, 1)
  return table.concat(out)
end

-- One row of a table (typst listing-row): the text wraps before the page column, a dot leader runs to the page.
local function row(body, page, col, first_ind)
  return para({ LINES, dot_tabs(), spacing(0, 0), ind(HANG, first_ind and nil or HANG, first_ind, col) },
    body .. runs(LEAD, {}) .. page)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover: the parts spread with flexible space over the page)
-- ---------------------------------------------------------------------------

local function est_lines(text, chars)
  return math.max(1, math.ceil(#stringify(text) / chars))
end

local function cover(meta)
  local sides = need_meta(meta, "caption")
  local counsel = need_meta(meta, "counsel")
  local lines, paras = 1 + 2 + est_lines(need_meta(meta, "proceeding"), 70) + est_lines(need_meta(meta, "brief_title"), 60) + 2, 7
  if meta.judge then lines, paras = lines + 1, paras + 1 end
  if meta.district_court_case then lines, paras = lines + 1, paras + 1 end
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do lines, paras = lines + est_lines(n, 66), paras + 1 end
    lines, paras = lines + 1 + (i > 1 and 1 or 0), paras + 1 + (i > 1 and 1 or 0)
  end
  for _, g in ipairs(counsel) do
    for _, n in ipairs(g.names or {}) do lines, paras = lines + 1, paras + 1 end
    for _, l in ipairs(g.lines or {}) do lines, paras = lines + 1, paras + 1 end
  end
  -- 6.5 flexible parts share what the lines and their gaps leave of the 9 in text height, less a margin
  local free = 12960 - lines * SINGLE - paras * GAP - 600
  local fr = math.max(0, math.floor(free / 6.5 * 0.8))

  local out = {}
  local function add(x) out[#out + 1] = x end
  local function rule(before)
    local side = math.floor(TEXT_W * 0.3)
    add(para({ KEEP, '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>',
      spacing(before or 0, 0, 120), ind(side, nil, nil, side) }, ""))
  end
  add(spar(runs("No. ", {}) .. inl(meta.case_number, {}), 0, true))
  add(spar(runs("UNITED STATES COURT OF APPEALS", { b = true }) .. BR .. runs("FOR THE TENTH CIRCUIT", { b = true }), fr, true))
  for i, side in ipairs(sides) do
    if i > 1 then add(spar(runs("v.", {}), 210, true)) end
    for k, n in ipairs(side.names) do
      add(spar(inl(n, {}), (i == 1 and k == 1) and fr or (i > 1 and k == 1) and 210 or GAP, true))
    end
    add(spar(inl(side.designation, {}), GAP, true))
  end
  add(spar(inl(meta.proceeding, {}), fr, true))
  if meta.judge then add(spar(inl(meta.judge, {}), GAP, true)) end
  if meta.district_court_case then add(spar(inl(meta.district_court_case, {}), GAP, true)) end
  rule(fr)
  add(spar(runs(pandoc.text.upper(stringify(meta.brief_title)), { b = true }), GAP, true))
  rule(0)
  add(spar(inl(meta.oral_argument, {}), fr, true))
  for gi, g in ipairs(counsel) do
    local first = true
    for _, n in ipairs(g.names or {}) do
      add(spar(inl(n, {}), first and (gi == 1 and fr or 168) or GAP, true, true))
      first = false
    end
    for _, l in ipairs(g.lines or {}) do add(spar(inl(l, { i = true }), GAP, true, true)) end
  end
  add(spar(inl(meta.phone, {}), 168, true))
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Word count: the typst template's count-words over the markdown body (whitespace-delimited; footnote definitions,
-- footnote references and markup characters removed; links keep their text), so both engines certify one number.
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("ca10.lua: no input file to count words in") end
  local h = assert(io.open(f, "r"))
  local text = h:read("a")
  h:close()
  local _, e = text:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if not e then error("ca10.lua: the sample must start with a YAML frontmatter block") end
  local s = text:sub(e + 1)
  s = s:gsub("%[%^[^%]]+%]:[^\n]*", " ")
  s = s:gsub("%[%^[^%]]+%]", "")
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
  s = s:gsub("[%*_#>`]", " ")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "oral_argument",
    "oral_argument_statement", "signature", "date", "prior_related", "virus_scanner", "authorities" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities
  for key, a in pairs(authorities) do
    patterns[#patterns + 1] = { key = key, pat = lua_pattern(stringify(a.search)) }
  end
  table.sort(patterns, function(x, y) return x.key < y.key end)
  local words = source_words()
  local signer = stringify(meta.signature.signer)

  need("S:cover", "B", "No. " .. stringify(meta.case_number), "UNITED STATES COURT OF APPEALS")
  need("S:toc", "B", "TABLE OF CONTENTS", "Page")
  need("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
  need("H:pra", "B", "STATEMENT OF PRIOR OR RELATED APPEALS", stringify(meta.prior_related))

  -- The body: headings (outline, needles, contents entries) and citations (needles), in document order.
  local headings, body = {}, {}
  local h_n = 0
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level > 2 then error("ca10.lua: the answering brief has two heading levels") end
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
      need(id, "B", stringify(b.content), nxt)
      headings[#headings + 1] = { id = id, level = b.level, title = stringify(b.content) }
      local x
      if b.level == 1 then
        x = para({ style("Heading1"), KEEP, spacing(#body == 0 and 0 or 240, 40, H1), ind(0, nil, 0), jc("center") },
          inl(b.content, { b = true, sz = H1_SZ }))
      else
        x = para({ style("Heading2"), KEEP, spacing(#body == 0 and 0 or 200, 0, H2), ind(TAB, TAB), jc("left") },
          inl(b.content, { b = true, sz = H2_SZ }))
      end
      body[#body + 1] = raw(x)
    else
      scan_block(b)
      for _, x in ipairs(list_items(b)) do body[#body + 1] = x end
    end
  end
  body = pandoc.Pandoc(body):walk({ Inlines = tag_breaks }):walk({ Str = function(s) return pandoc.Str(bp(s.text)) end })
    :walk({ Inlines = xe.inlines }).blocks

  -- the back matter's titles and citations, in document order
  local oral_text = stringify(meta.oral_argument_statement)
  need("H:oral", "B", "STATEMENT OF COUNSEL AS TO ORAL ARGUMENT", oral_text)
  cite_needles(oral_text, "B")
  local c1 = "This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because:"
  local c1x = "[x] this brief contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by "
    .. "Fed. R. App. P. 32(f) and 10th Cir. R. 32(B)."
  local c2 = "This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style "
    .. "requirements of Fed. R. App. P. 32(a)(6) because:"
  local c2x = "[x] this brief has been prepared in a proportionally spaced typeface, " .. TYPEFACE .. ", in 14-point type."
  need("H:cc", "B", "CERTIFICATE OF COMPLIANCE WITH TYPE-VOLUME LIMIT", "1. " .. c1)
  for _, t in ipairs({ c1, c1x, c2, c2x }) do cite_needles(t, "B") end
  local d = {
    "I hereby certify that with respect to the foregoing:",
    "(1) all required privacy redactions have been made per 10th Cir. R. 25.5;",
    "(2) if required to file additional hard copies, that the ECF submission is an exact copy of those documents;",
    "(3) the digital submissions have been scanned for viruses with the most recent version of a commercial virus "
      .. "scanning program, " .. stringify(meta.virus_scanner) .. ", and according to the program are free of viruses.",
  }
  need("H:cds", "B", "CERTIFICATE OF DIGITAL SUBMISSION", d[1])
  for _, t in ipairs(d) do cite_needles(t, "B") end
  local svc = meta.service
  local with_service = svc ~= nil and svc.certificate ~= nil
  local s1 = "I hereby certify that on " .. stringify(meta.date) .. " a true and correct copy of the foregoing was filed "
    .. "with the Clerk of the Court using CM/ECF system and also served on the following:"
  if with_service then
    need("H:cs", "B", "CERTIFICATE OF SERVICE", s1)
    cite_needles(s1, "B")
  end

  for _, h in ipairs(hits) do
    if not authorities[h.key] then error("ca10.lua: no authority " .. h.key) end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (page i, no number shown)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone", "lowerRoman", 1))

  -- Section 2: the front matter (ii, iii ...)
  local front = { title("TABLE OF CONTENTS", 0),
    para({ KEEP, spacing(TITLE_BELOW, GAP), ind(0, nil, nil, 20), jc("right") }, runs("Page", { b = true, u = true })) }
  local items = {
    { id = "S:toa", title = "TABLE OF AUTHORITIES", level = 1 },
    { id = "H:pra", title = "STATEMENT OF PRIOR OR RELATED APPEALS", level = 1 },
  }
  for _, h in ipairs(headings) do items[#items + 1] = h end
  items[#items + 1] = { id = "H:oral", title = "STATEMENT OF COUNSEL AS TO ORAL ARGUMENT", level = 1 }
  items[#items + 1] = { id = "H:cc", title = "CERTIFICATE OF COMPLIANCE WITH TYPE-VOLUME LIMIT", level = 1 }
  items[#items + 1] = { id = "H:cds", title = "CERTIFICATE OF DIGITAL SUBMISSION", level = 1 }
  if with_service then items[#items + 1] = { id = "H:cs", title = "CERTIFICATE OF SERVICE", level = 1 } end
  for _, it in ipairs(items) do
    front[#front + 1] = row(runs(it.title, {}), runs(label_of(it.id), {}), PNUM_TOC, it.level == 2 and 0 or nil)
  end
  -- the table of authorities: every authority of the four kinds, sorted by name; the pages it is cited on
  front[#front + 1] = title("TABLE OF AUTHORITIES", 0, true)
  front[#front + 1] = para({ KEEP, spacing(TITLE_BELOW, 0), ind(0, nil, nil, 20), jc("right") },
    runs("Page(s)", { b = true, u = true }))
  for _, k in ipairs({ { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "other", "Other Authorities" } }) do
    local members = {}
    for key, a in pairs(authorities) do
      local kind = a.kind and stringify(a.kind) or "other"
      if kind == k[1] then members[#members + 1] = { key = key, a = a, sort = stringify(a.name):lower() } end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      front[#front + 1] = para({ KEEP, spacing(40, 0), ind(0) }, runs(k[2], { b = true }))
      for _, m in ipairs(members) do
        local pages, seen = {}, {}
        for _, h in ipairs(hits) do
          if h.key == m.key then
            local l = labels["T:" .. h.index]
            local lab = l and l.label or "00"
            -- front matter pages are not counted (typst pages-cited); a roman label is front matter
            if not lab:match("^[ivxlc]+$") and not seen[lab] then
              seen[lab] = true
              pages[#pages + 1] = lab
            end
          end
        end
        local mark
        if #pages == 0 then mark = "--" elseif #pages >= PASSIM then mark = "passim" else mark = table.concat(pages, ", ") end
        local name = inl(m.a.name, { i = k[1] == "case" })
        local cite = m.a.cite and stringify(m.a.cite) or ""
        if cite ~= "" then name = name .. runs(", ", {}) .. inl(m.a.cite, {}) end
        local w = 0
        for c in mark:gmatch(".") do w = w + (c:match("%d") and 140 or 70) end
        front[#front + 1] = row(name, runs(mark, {}), math.max(PNUM_TOA, w))
      end
    end
  end
  front[#front + 1] = title("STATEMENT OF PRIOR OR RELATED APPEALS", 320)
  front[#front + 1] = spar(inl(meta.prior_related, {}), TITLE_BELOW)
  add(raw(table.concat(front)))
  add(section("rIdFtrPage", "lowerRoman", 2))

  -- Section 3: the body (1, 2 ...), the signature, the statement of counsel as to oral argument, the certificates
  for _, x in ipairs(body) do add(x) end
  add(raw(para({ KEEP, spacing(220, 0), ind(SIG_W) }, runs("Respectfully submitted,", {}))
    .. sig_block(meta, runs("s/ " .. signer, {}))))
  add(raw(title("STATEMENT OF COUNSEL AS TO ORAL ARGUMENT")
    .. para({ spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(bind_inlines(meta.oral_argument_statement), {}))))

  local function item(num, text, before)
    return para({ LINES, spacing(before or GAP, GAP), ind(HANG, HANG) }, runs(num .. "\t" .. bp(text), {}))
  end
  local function checked(text)
    return para({ LINES, spacing(GAP, GAP), ind(HANG) }, runs(bp(text), {}))
  end
  add(raw(title("CERTIFICATE OF COMPLIANCE WITH TYPE-VOLUME LIMIT", 0, true)
    .. item("1.", c1) .. checked(c1x) .. item("2.", c2, CERT_GAP) .. checked(c2x)
    .. spar(runs("Date: ", {}) .. inl(meta.date, {}) .. runs(".", {}), SIG_GAP)
    .. sig_block(meta, runs("s/ " .. signer, {}))))

  local dx = { title("CERTIFICATE OF DIGITAL SUBMISSION", 0, true) }
  for _, t in ipairs(d) do dx[#dx + 1] = spar(runs(bp(t), {})) end
  dx[#dx + 1] = sig_block(meta, runs("s/ " .. signer, {}))
  add(raw(table.concat(dx)))

  if with_service then
    local sx = { title("CERTIFICATE OF SERVICE", 0, true), spar(runs(bp(s1), {})) }
    for _, g in ipairs(svc.unregistered or {}) do
      local ls = {}
      for _, l in ipairs(g) do ls[#ls + 1] = inl(l, {}) end
      sx[#sx + 1] = spar(table.concat(ls, BR), CERT_GAP)
    end
    sx[#sx + 1] = sig_block(meta, runs("By: s/ " .. signer, {}), 520)
    add(raw(table.concat(sx)))
  end

  doc.blocks = out
  doc.meta.date = nil
  doc.meta.title = nil
  doc.meta.author = nil
  return doc
end
