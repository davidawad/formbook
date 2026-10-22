-- ca10.lua (docx engine): the Tenth Circuit reply brief (FRAP 28(c)) as Word paragraphs and sections (typst:
-- ca10-reply-brief.typ, the reference). pandoc writes the body text (paragraphs, quotations, lists, footnotes) with
-- docx/reference.docx; this filter writes what needs Word formatting:
--   * the cover (FRAP 32(a)(2)(A)-(F)), the table of contents, the table of authorities, the signature block and the
--     certificates (Form 6 compliance; digital submission, 10th Cir. R. 25.5; service, FRAP 25), as paragraphs with
--     explicit spacing, indents and tabs;
--   * the heading labels (Argument: I. A. 1. a.; elsewhere A. 1. a. (1)) and each heading's outline level;
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page
--     of every heading and citation in that PDF (the needles this filter writes), and renders again with them;
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1, 2 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in exact line boxes of the typst
-- pitches, the typst spaces in twips (20 x pt), the break rules of lib/docx/xengine.lua.

local WORD_LIMIT = 6500    -- FRAP 32(a)(7)(B)(ii): half of the principal-brief limit
local TYPEFACE = "Times New Roman" -- typst font-family.first()
local TOC_DEPTH = 4        -- typst toc-depth
local PASSIM = 7           -- typst passim-threshold
local TAB = 720            -- half an inch (para-indent, heading-tab), in twips
local TEXT_W = 9360        -- the text width, 6.5 in
local HALF_W = 4680        -- the middle of the text: designations, counsel and signatures start here
local PNUM_TOC = 720       -- typst toc-page-col, 36 pt
local PNUM_TOA = 1120      -- typst toa-page-col, 56 pt
local SINGLE = 400         -- typst pitch-single, 20 pt
local DOUBLE = 628         -- typst pitch-double, 31.4 pt (CA10-FORM-001)
local HEAD_SZ = 32         -- typst heading-size, 16 pt (half points)
local NEEDLE_MAX = 60      -- a needle is a prefix of the text (letters and digits only)

local stringify = pandoc.utils.stringify

local xe = require("docx.xengine")
-- No break inside a token of adjacent parentheses ("32(a)(7)(B)(ii)"): typst boxes it (lib/typst/xengine.typ),
-- Unicode line breaking (LibreOffice) would break between ")" and "(": a word joiner binds them.
local WJ = "\u{2060}"
local function bind_parens(s)
  return (s:gsub("%)%(", ")" .. WJ .. "("))
end
local function runs(text, o)
  return xe.runs(bind_parens(text), o)
end
local function inl(x, o)
  if type(x) == "string" then return runs(x, o) end
  local walker = { Str = function(s) return pandoc.Str(bind_parens(s.text)) end }
  local ty = pandoc.utils.type(x)
  if ty == "Inlines" then x = x:walk(walker)
  elseif ty == "Blocks" then x = pandoc.utils.blocks_to_inlines(x):walk(walker) end
  return xe.inl(x, o)
end
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.LEAD
local list_items = xe.list_items

local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

-- A dot leader to the right margin (the page number follows the last tab).
local function dot_tabs()
  return xe.leader_tab(TEXT_W)
end

-- A horizontal rule: an empty paragraph with a bottom border; `width` narrows it (centered).
local function rule(kind, before, after, width)
  local b = kind == "double"
      and '<w:pBdr><w:bottom w:val="thickThinSmallGap" w:sz="12" w:space="1" w:color="000000"/></w:pBdr>'
      or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  local side = width and math.floor((TEXT_W - width) / 2) or 0
  return para({ KEEP, b, spacing(before, after, 120), ind(side, nil, nil, side) }, "")
end

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, written by fb render), page number format and start,
-- letter paper with 1 in margins, the page number 30.4 pt above the foot of the page (typst footer-descent 30 %).
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="608" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (1 pt high: it pushes nothing on).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
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
  return "00" -- the first pass: a placeholder
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Line breaks inside a web address (latex: url_breaks). typst breaks a word that holds "http://" or "https://" (from
-- there to the end of the word, less trailing punctuation) where the class of character changes: letter, digit,
-- opening bracket, other; after an "other" character before anything, and between a letter and a digit either way,
-- never after an opening bracket; a piece of 16 characters or more breaks after any character. LibreOffice breaks
-- such a word by Unicode rules: the typst places get a zero-width space.
-- ---------------------------------------------------------------------------

local ZWSP = "\u{200B}"

local function url_cuts(link)
  local function class(c)
    if c:match("^%a$") or #c > 1 then return "A" end
    if c:match("^%d$") then return "D" end
    if c == "(" or c == "[" then return "O" end
    return "X"
  end
  local cuts, starts = {}, {}
  for p in utf8.codes(link) do starts[#starts + 1] = p - 1 end
  local offset, prev = 0, "X"
  for i, b in ipairs(starts) do
    local c = link:sub(b + 1, starts[i + 1] or #link)
    local cl = class(c)
    if b > 0 and prev ~= "O" and ((cl == "X" and prev == "X") or (cl ~= "X" and cl ~= prev)) then
      if b - offset >= 16 then
        for _, q in ipairs(starts) do if q > offset and q < b then cuts[q] = true end end
      end
      cuts[b] = true
      offset = b
    end
    prev = cl
  end
  return cuts
end

local function url_breaks(s)
  local text = s.text
  local at = text:find("https?://")
  if not at then
    -- outside a web address: Unicode line breaking (typst) breaks after a slash before a digit unless a number
    -- comes before it ("timeline/288768"); LibreOffice does not
    local t = text:gsub("([^%d/])/(%d)", "%1/" .. ZWSP .. "%2")
    if t == text then return nil end
    return pandoc.Str(t)
  end
  local tail_at = #text + 1
  while tail_at > at and text:sub(tail_at - 1, tail_at - 1):match("[.,;:!?]") do tail_at = tail_at - 1 end
  local link = text:sub(at, tail_at - 1)
  local keys = {}
  for k in pairs(url_cuts(link)) do keys[#keys + 1] = k end
  table.sort(keys)
  local out, from = {}, 1
  for _, k in ipairs(keys) do
    out[#out + 1] = link:sub(from, k)
    from = k + 1
  end
  out[#out + 1] = link:sub(from)
  return pandoc.Str(text:sub(1, at - 1) .. table.concat(out, ZWSP) .. text:sub(tail_at))
end

-- ---------------------------------------------------------------------------
-- Headings
-- ---------------------------------------------------------------------------

-- typst heading-label: Argument I. / A. / 1. / a.; elsewhere A. / 1. / a. / (1).
local function label(level, n, arg)
  if arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    return string.char(96 + n) .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

-- typst label-indent, in half inches: the Argument's point heading is centered, its sub-headings start one step in.
local function step(level, arg)
  return level - (arg and 3 or 2) + 1
end

local function hstyle(level)
  return style("Heading" .. level)
end

-- A section heading (level 1, the front matter, the statements, the certificates): bold capitals, centered, 16 pt;
-- 21 pt above, 15.4 pt below. `top`: it opens a page (no space above); `brk`: it also breaks the page.
local function section_heading(text, top, brk, plain)
  return para({ plain and "" or hstyle(1), KEEP, brk and BREAK or "", spacing(top and 0 or 420, 308),
    ind(0, nil, 0), jc("center") }, runs(pandoc.text.upper(text), { b = true, sz = HEAD_SZ }))
end

local function heading_xml(level, content, lab, arg)
  if level == 1 then
    return para({ hstyle(1), KEEP, spacing(420, 308), ind(0, nil, 0), jc("center") },
      inl(pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }),
        { b = true, sz = HEAD_SZ }))
  end
  if arg and level == 2 then
    return para({ hstyle(2), KEEP, spacing(336, 280), ind(0, nil, 0), jc("center") },
      runs(lab .. " ", { b = true }) .. inl(content, { b = true }))
  end
  local k = step(level, arg)
  local o = { b = true, i = level >= 4 }
  return para({ hstyle(level), KEEP, spacing(308, 252), ind(TAB * (k + 1), TAB) },
    runs(lab .. "\t", o) .. inl(content, o))
end

-- One row of the table of contents (typst listing-row): label, title, a dot leader and the page.
local function toc_row(item)
  local title = item.level == 1 and pandoc.text.upper(item.title) or item.title
  title = title:gsub("%.\u{00A0}", ". ") -- pandoc's abbreviation no-break space (typst sets a space: xe.unabbrev)
  local lead = ""
  if item.label then lead = runs(item.label .. "\t", {}) end
  local left = TAB * item.step + TAB
  return para({ LINES, dot_tabs(), spacing(item.level == 1 and 168 or 98, 0), ind(left, TAB, nil, PNUM_TOC) },
    lead .. ((item.content and item.level > 1) and inl(item.content, {}) or runs(title, {})) .. runs(LEAD .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities (typst toa-section)
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

local occurrences = {} -- the authority links, in document order: { key, index }

-- typst sort-key: lowercased plain text without punctuation, digit runs zero-padded.
local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  s = s:lower():gsub("[^a-z0-9 ]", "")
  return (s:gsub("%d+", function(d) return string.rep("0", math.max(0, 8 - #d)) .. d end))
end

-- Width of a page list in twips (Times New Roman 14 pt: digits and roman numerals' letters as measured; a comma and a
-- space 0.25 em each): a list wider than the column widens the column (typst: the larger of 56 pt and the list).
local function list_width(s)
  local w = 0
  for c in s:gmatch(".") do
    if c:match("%d") then w = w + 140
    elseif c == "i" or c == "," or c == " " then w = w + 78
    elseif c == "v" or c == "x" then w = w + 140
    else w = w + 140 end
  end
  return w
end

local function toa_rows(authorities)
  local used = {}
  for _, o in ipairs(occurrences) do used[o.key] = true end
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and a.kind and stringify(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      local head = runs(g[2], { b = true })
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TEXT_W .. '"/></w:tabs>',
        spacing(#out == 0 and 280 or 392, 56), ind(0) }, head)
      for _, m in ipairs(members) do
        -- the distinct page labels of the authority, in document order
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local lab = l and l.label or ("00" .. o.index)
            if not seen[lab] then
              seen[lab] = true
              pages[#pages + 1] = l and l.label or "00"
            end
          end
        end
        local list, list_w
        if #pages >= PASSIM then
          list, list_w = runs("passim", { i = true }), 0
        else
          local s = table.concat(pages, ", ")
          list, list_w = runs(s, {}), list_width(s)
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = g[1] == "case" }) .. runs(",", {}) .. xe.BR
        end
        out[#out + 1] = para({ LINES, dot_tabs(), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. runs(LEAD, {}) .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body)
-- ---------------------------------------------------------------------------

-- Lines a text takes in a column of `chars` characters (an estimate: Times New Roman 14 pt averages about 6.3 pt a
-- character, so 6.5 in holds about 74).
local function est_lines(text, chars)
  return math.max(1, math.ceil(#stringify(text) / chars))
end

local function cover(meta)
  local sides = need_meta(meta, "caption")
  local counsel = need_meta(meta, "counsel")
  -- The gap between the cover's parts is the largest that keeps it on one page (typst: the largest of 1, 0.8 ... 0 em
  -- at which the cover fits); the type size and line pitch never shrink. 9 in of text height = 648 pt.
  local lines = 1 + 2 + est_lines(need_meta(meta, "proceeding"), 70) + 1 + est_lines(need_meta(meta, "brief_title"), 60) + 1
  local paras = 4
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do lines = lines + est_lines(n, 70); paras = paras + 1 end
    lines = lines + est_lines(side.designation, 32) + ((i > 1 and not side["no-v"]) and 1 or 0)
  end
  for _, g in ipairs(counsel) do
    for _, n in ipairs(g.names or {}) do lines = lines + est_lines(n, 32) end
    for _, l in ipairs(g.lines or {}) do lines = lines + est_lines(l, 32) end
  end
  local free = (648 - lines * SINGLE / 20 - paras * 4.9 - #counsel * 7 - 3 * 6) * 20
  local gap = 280
  for _, g in ipairs({ 280, 224, 168, 126, 84, 56, 28, 0 }) do
    gap = g
    if 9.6 * g <= free then break end
  end

  local out = {}
  local function add(x) out[#out + 1] = x end
  local function center(body, before, after)
    add(para({ KEEP, spacing(before or 0, after or 98), ind(0, nil, 0), jc("center") }, body))
  end
  -- (A) the number of the case; (B) the name of the court
  center(runs("No. ", { b = true }) .. inl(meta.case_number, { b = true }), math.floor(gap * 0.6), 0)
  center(runs("IN THE UNITED STATES COURT OF APPEALS", { b = true }) .. xe.BR .. runs("FOR THE TENTH CIRCUIT", { b = true }), gap, gap)
  -- (C) the title of the case: each side's parties, the designation, and "v." between the sides
  for i, side in ipairs(sides) do
    if i > 1 then
      local nov = side["no-v"]
      if nov == true or (nov ~= nil and nov ~= false and stringify(nov) == "true") then
        out[#out] = out[#out]:gsub('w:after="%d+"', 'w:after="' .. math.floor(gap * 0.6) .. '"', 1)
      else
        center(runs("v.", {}), math.floor(gap * 0.3), math.floor(gap * 0.3))
      end
    end
    for _, n in ipairs(side.names) do center(inl(n, {})) end
    add(para({ KEEP, spacing(0, 98), ind(HALF_W) }, inl(side.designation, {})))
  end
  add(rule("short", gap, gap, 2880))
  -- (D) the nature of the proceeding and the court below
  center(inl(meta.proceeding, {}))
  if meta.district_court_case or meta.judge then
    local x = ""
    if meta.district_court_case then x = runs("D.C. No. ", {}) .. inl(meta.district_court_case, {}) end
    if meta.district_court_case and meta.judge then x = x .. runs("; ", {}) end
    if meta.judge then x = x .. inl(meta.judge, {}) end
    center(x, 0, 0)
  end
  add(rule("short", gap, gap, 2880))
  -- (E) the title of the brief
  center(inl(meta.brief_title, { b = true, caps = true }), 0, 0)
  add(rule("short", gap, gap, 2880))
  -- (F) counsel: name, office address, telephone number (the phone line goes with the last group); in the right
  -- half, the lines half an em in; 7 pt between groups
  for gi, g in ipairs(counsel) do
    local first = true
    local function cl(body, first_ind)
      add(para({ KEEP, spacing(first and gi > 1 and 140 or 0, 0), ind(HALF_W, nil, first_ind) }, body))
      first = false
    end
    for _, n in ipairs(g.names or {}) do cl(inl(n, {})) end
    local ls = {}
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = l end
    if gi == #counsel then ls[#ls + 1] = need_meta(meta, "phone") end
    for _, l in ipairs(ls) do cl(inl(l, { i = true }), 140) end
  end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates
-- ---------------------------------------------------------------------------

-- typst signature-block: "Respectfully submitted," 19.6 pt below the text, 16.8 pt, the signature, the signer in
-- capitals and the signer's lines (half an em in, italic) in the right half; 11.2 pt and the date at the margin.
local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  out[#out + 1] = para({ KEEP, spacing(392, 0), ind(HALF_W) }, runs("Respectfully submitted,", {}))
  out[#out + 1] = para({ KEEP, spacing(336, 0), ind(HALF_W) }, runs("s/ " .. signer, {}))
  out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W) }, runs(pandoc.text.upper(signer), {}))
  for _, l in ipairs(sig.lines or {}) do
    out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 140) }, inl(l, { i = true }))
  end
  if meta.date then
    out[#out + 1] = para({ LINES, spacing(224, 0), ind(0) }, inl(meta.date, {}))
  end
  out[#out] = out[#out]:gsub(KEEP, LINES, 1)
  return table.concat(out)
end

-- typst form-sig-line: two columns ((text width - 1 em) / 2 each, a 1 em gutter: the right one starts 241 pt in),
-- "s/ Name" over "Signature" and the date over "Date", 22.4 pt below the text.
local FORM_COL = 4820
local function form_signature(meta)
  local signer = stringify(meta.signature.signer)
  local tab = '<w:tabs><w:tab w:val="left" w:pos="' .. FORM_COL .. '"/></w:tabs>'
  local date = meta.date and inl(meta.date, {}) or ""
  return para({ KEEP, tab, spacing(448, 0), ind(0) }, runs("s/ " .. signer .. "\t", {}) .. date)
    .. para({ LINES, tab, spacing(0, 0), ind(0) }, runs("Signature\tDate", {}))
end

-- A numbered item of Form 6 (typst reads "1. ..." in the template as a list item: the number in a half-inch box,
-- the text hanging after it, no space between items).
local function form_item(num, body)
  return para({ LINES, spacing(0, 0), ind(TAB, TAB) }, runs(num .. "\t", {}) .. body)
end

-- A single-spaced paragraph of a certificate at the margin, 14 pt after the one before (typst par spacing).
local function cert_para(body, before)
  return para({ LINES, spacing(before or 280, 0), ind(0) }, body)
end

-- ---------------------------------------------------------------------------
-- Word count: the typst template's count-words over the markdown source (whitespace-delimited, markup removed,
-- footnote text included), so every engine certifies the same number.
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("ca10.lua: no input file to count words in") end
  local h = assert(io.open(f, "r"))
  local text = h:read("a")
  h:close()
  local dashes, n = 0, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    else
      local s = line:gsub("<!%-%-.-%-%->", " ")
      s = s:gsub("^%[%^[^%]]+%]:", " ")
      s = s:gsub("%[%^[^%]]*%]", "")
      s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
      s = s:gsub("^#+[ \t]+", "")
      s = s:gsub("^>[ \t]?", "")
      s = s:gsub("^[ \t]*[-*+][ \t]+", "")
      s = s:gsub("^[ \t]*%d+[.)][ \t]+", "")
      s = s:gsub("\\(.)", "%1")
      s = s:gsub("%*", "")
      s = s:gsub("_", "")
      for _ in s:gmatch("%S+") do n = n + 1 end
    end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Fancy list markers ("(I)", "A.", "(1)") are text in the markdown contract (CommonMark has no such lists): they
-- become paragraphs that keep their marker.
-- ---------------------------------------------------------------------------

local function list_marker(n, st, delim)
  local s
  if st == "LowerRoman" or st == "UpperRoman" then
    s = roman(n)
    if st == "LowerRoman" then s = s:lower() end
  elseif st == "LowerAlpha" or st == "UpperAlpha" then
    s = string.char((st == "LowerAlpha" and 96 or 64) + n)
  else
    s = tostring(n)
  end
  if delim == "OneParen" then return s .. ")" end
  if delim == "TwoParens" then return "(" .. s .. ")" end
  return s .. "."
end

local function unlist_fancy(blocks)
  return pandoc.Pandoc(blocks):walk({
    OrderedList = function(el)
      local a = el.listAttributes
      local st, dl = tostring(a.style), tostring(a.delimiter)
      local fancy = st == "LowerRoman" or st == "UpperRoman" or st == "LowerAlpha" or st == "UpperAlpha"
        or dl == "OneParen" or dl == "TwoParens"
      if not fancy then return nil end
      local out = {}
      for i, item in ipairs(el.content) do
        local marker = list_marker(a.start + i - 1, st, dl)
        for j, b in ipairs(item) do
          if j == 1 and (b.t == "Para" or b.t == "Plain") then
            local x = pandoc.Inlines({ pandoc.Str(marker), pandoc.Space() })
            x:extend(b.content)
            out[#out + 1] = pandoc.Para(x)
          else
            out[#out + 1] = b
          end
        end
      end
      return out
    end,
  }).blocks
end

-- ---------------------------------------------------------------------------
-- Citations, in document order (the needles of the table of authorities)
-- ---------------------------------------------------------------------------

local scan_blocks

local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local key = el.target:sub(5)
      occurrences[#occurrences + 1] = { key = key, index = #occurrences + 1 }
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      need("T:" .. #occurrences, in_note and "N" or "B", stringify(el.content), stringify(rest))
    elseif el.t == "Note" then
      scan_blocks(el.content, true)
    elseif el.content and type(el.content) ~= "string" and el.t ~= "Link" then
      scan_inlines(el.content, in_note)
    end
  end
end

scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" then
      scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

local function strip_links(blocks)
  return pandoc.Pandoc(blocks):walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  }):walk({ Str = function(s) return pandoc.Str(bind_parens((url_breaks(s) or s).text)) end }):walk({ Inlines = xe.inlines }).blocks
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

local function next_text(blocks, i)
  local b = blocks[i + 1]
  if not b then return "" end
  return stringify(b):sub(1, 40)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

local COMPLIANCE = "Certificate of Compliance With Type-Volume Limit, Typeface Requirements, and Type Style Requirements"

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "date" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  local ds = meta.digital_submission
  local digital = ds == true or (ds ~= nil and ds ~= false and stringify(ds) == "true")
  if digital then need_meta(meta, "virus_scanner") end

  local words = source_words()
  if words > WORD_LIMIT then
    error("ca10.lua: the reply brief has " .. words .. " words; FRAP 32(a)(7)(B)(ii) allows " .. WORD_LIMIT)
  end

  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles).
  local body_in = unlist_fancy(doc.blocks)
  local headings = {}
  local body = {}
  local in_arg = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n = 0
  for i, b in ipairs(body_in) do
    if b.t == "Header" then
      if b.level > 5 then error("ca10.lua: headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then in_arg = norm(stringify(b.content)) == "argument" end
      local lab = b.level == 1 and "" or label(b.level, counts[b.level], in_arg)
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", lab .. stringify(b.content), next_text(body_in, i))
      if b.level <= TOC_DEPTH then
        local point = in_arg and b.level == 2
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = stringify(b.content), content = b.content, step = (b.level == 1 or point) and 0 or step(b.level, in_arg) }
      end
      local x = heading_xml(b.level, b.content, lab, in_arg)
      -- the body opens a section (a new page): Word keeps space above there, typst drops it at the top of a page
      if #body == 0 then x = x:gsub('w:before="%d+"', 'w:before="0"', 1) end
      body[#body + 1] = raw(x)
    else
      scan_blocks({ b }, false)
      if b.t == "Para" and has_note(b) then
        -- a paragraph with a footnote mark: no widow control (reference.docx, "Body Text Note")
        body[#body + 1] = pandoc.Div({ b }, { ["custom-style"] = "Body Text Note" })
      else
        for _, x in ipairs(list_items(b)) do body[#body + 1] = x end
      end
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("ca10.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  -- the table of authorities' needle goes on with its first group title (the contents list the same title)
  for _, g in ipairs(GROUPS) do
    local used = false
    for _, o in ipairs(occurrences) do
      local a = authorities[o.key]
      if a and a.kind and stringify(a.kind) == g[1] then used = true end
    end
    if used then
      for _, n in ipairs(needles) do
        if n.id == "S:toa" then n.needle = norm("Table of Authorities " .. g[2]):sub(1, NEEDLE_MAX) end
      end
      break
    end
  end
  body = strip_links(body)
  -- The last paragraph stays with the signature block (typst: the tail block is kept with the signature).
  local last = body[#body]
  if last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end

  need("H:cc", "B", COMPLIANCE, "1. This document complies")
  if digital then need("H:cds", "B", "Certificate of Digital Submission", "I hereby certify") end
  need("H:cs", "B", "Certificate of Service", "I hereby certify")

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): contents, authorities (FRAP 28(c): both are required in a reply brief)
  add(raw(section_heading("Table of Contents", true, false, true)))
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, nil, 20), jc("right") }, runs("Page", { b = true, u = true })))) -- 1 pt in: LibreOffice lets the underlined word overhang its advance
  local items = { { id = "S:toa", level = 1, title = "Table of Authorities", step = 0 } }
  for _, h in ipairs(headings) do items[#items + 1] = h end
  items[#items + 1] = { id = "H:cc", level = 1, title = COMPLIANCE, step = 0 }
  if digital then items[#items + 1] = { id = "H:cds", level = 1, title = "Certificate of Digital Submission", step = 0 } end
  items[#items + 1] = { id = "H:cs", level = 1, title = "Certificate of Service", step = 0 }
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...), the signature and the certificates
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))

  -- Form 6 (FRAP 32(g); 10th Cir. R. 32), on its own page; the typesetting program only when the INPUT names it
  local program = meta.typeset_with and (" using " .. stringify(meta.typeset_with)) or ""
  add(raw(section_heading(COMPLIANCE, true, true)
    .. form_item("1.", runs("This document complies with the word limit of Fed. R. App. P. 32(a)(7)(B)(ii) because, "
      .. "excluding the parts of the document exempted by Fed. R. App. P. 32(f), this document contains "
      .. group_digits(words) .. " words.", {}))
    .. form_item("2.", runs("This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the "
      .. "type style requirements of Fed. R. App. P. 32(a)(6) because this document has been prepared in a "
      .. "proportionally spaced typeface" .. program .. " in 14-point " .. TYPEFACE .. ".", {}))
    .. form_signature(meta)))

  -- certificate of digital submission (10th Cir. R. 25.5; FRAP 25(a)(5)), on its own page when asked for
  if digital then
    add(raw(section_heading("Certificate of Digital Submission", true, true)
      .. cert_para(runs("I hereby certify that with respect to the foregoing:", {}), 0)
      .. cert_para(runs("(1) all required privacy redactions have been made per Fed. R. App. P. 25(a)(5) and 10th Cir. R. 25.5;", {}))
      .. cert_para(runs("(2) this document is a native PDF document;", {}))
      .. cert_para(runs("(3) the ECF submission is an exact copy of that document;", {}))
      .. cert_para(runs("(4) the digital submission has been scanned for viruses with ", {}) .. inl(meta.virus_scanner, {})
        .. runs(", and", {}))
      .. cert_para(runs("(5) according to the program, this document is free of viruses.", {}))
      .. form_signature(meta)))
  end

  -- certificate of service (FRAP 25), on its own page
  local svc = meta.service or {}
  local x = section_heading("Certificate of Service", true, true)
    .. cert_para(runs("I hereby certify that on ", {}) .. inl(meta.date, {}) .. runs(", pursuant to Fed. R. App. P. 25, "
      .. "I electronically filed the foregoing using the Court\u{2019}s CM/ECF system, which in turn caused electronic "
      .. "notifications of such filing to be sent to all counsel of record.", {}), 0)
  if svc.unregistered and #svc.unregistered > 0 then
    x = x .. cert_para(runs("I certify that I served the foregoing on this date by hand delivery, mail, third-party "
      .. "commercial carrier for delivery within 3 calendar days, or email to the following unregistered case "
      .. "participants:", {}))
    for _, u in ipairs(svc.unregistered) do
      x = x .. para({ LINES, spacing(196, 0), ind(TAB) }, inl(u.name, {}) .. runs(", ", {}) .. inl(u.address, {}))
    end
  end
  add(raw(x .. form_signature(meta)))

  doc.blocks = out
  doc.meta.date = nil -- the date is printed by the signature blocks only, not by pandoc at the top
  doc.meta.title = nil
  doc.meta.author = nil
  return doc
end
