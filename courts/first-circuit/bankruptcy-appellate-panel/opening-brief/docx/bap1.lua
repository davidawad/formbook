-- bap1 brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx, on the shared
-- cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every line and page
-- breaks where the typst render (typst/bap1-*.typ, the reference) breaks it. pandoc writes the body text
-- (paragraphs, quotations, lists, footnotes) with docx/reference.docx; this filter writes, as paragraphs with the
-- typst template's pitches and spaces (twips = 20 x pt):
--   * the cover (its own section, no page number), the corporate disclosure (when given), the table of contents,
--     the table of authorities, the oral-argument statement, the headings (numbered I., A., 1., a. from level 2),
--     the signature block, the certificate of compliance and the statements regarding related cases and
--     interested parties (1st Cir. BAP L.R. 8014-1(a)(2), (3));
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of
--     every heading and citation in the LibreOffice PDF (the needles this filter writes) and renders again with
--     those pages (FORMBOOK_PAGES), until they settle. Pages are numbered from the cover, as typst numbers them.
-- The word limit and the required sections are checked here, as in the typst template. The same file is in each
-- doc-type folder; only the KIND and FONT_NAME lines differ.
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local KIND = "opening"   -- "opening" | "answering" | "reply"  (set per doc-type folder)
local FONT_NAME, FONT_SIZE = "Times New Roman", 14   -- typst: font-family (its first face), type-size

local KINDS = {
  opening = { title = "BRIEF FOR APPELLANT", limit = 13000, cite = "Fed. R. Bankr. P. 8015(a)(7)(A)",
    required = {
      { "Jurisdictional Statement", "Statement of Jurisdiction", "Statement of Appellate Jurisdiction",
        "Statement of the Basis for Appellate Jurisdiction" },
      { "Statement of the Issues", "Statement of Issues", "Statement of the Issues Presented", "Issues Presented" },
      { "Statement of the Case" },
      { "Summary of the Argument", "Summary of Argument" },
      { "Argument" },
      { "Conclusion" },
    } },
  answering = { title = "BRIEF FOR APPELLEE", limit = 13000, cite = "Fed. R. Bankr. P. 8015(a)(7)(A)",
    required = { { "Argument" }, { "Conclusion" } } },
  reply = { title = "REPLY BRIEF FOR APPELLANT", limit = 6500, cite = "Fed. R. Bankr. P. 8015(a)(7)(B)",
    required = { { "Argument" }, { "Conclusion" } } },
}
local CFG = KINDS[KIND]

-- The typst template's numbers, in twips.
local DOUBLE = 628     -- pitch-double, 31.4 pt (BAP-FORM-004; reference.docx Body Text)
local SINGLE = 400     -- pitch-single, 20 pt: headings, cover, tables, quotations, footnotes
local FORM = 368       -- pitch-form, 18.4 pt: signature blocks and the L.R. 8014-1 statements
local COVER_GAP = 64   -- cover-gap, 3.2 pt between the cover's lines
local INDENT = 720     -- para-indent, half an inch: paragraph indent, heading label box, list label box
local BOX_COL = 448    -- box-col, 1.6 em: the check-box column
local TEXT_W = 9360    -- the text width, 6.5 in (letter, 1 in margins)
local TOC_COL = 720    -- toc-page-col, 36 pt
local TOA_COL = 1120   -- toa-page-col, 56 pt
local PASSIM = 7       -- passim-threshold
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)

local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

local stringify = pandoc.utils.stringify
local xe = require("docx.xengine")
local para, raw, ind, jc = xe.para, xe.raw, xe.ind, xe.jc
local KEEP, LINES, BREAK, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.LEAD

-- No break inside a token of adjacent parentheses ("8015(a)(7)(A)"), as typst boxes it: LibreOffice would break
-- between ")" and "(", so a word joiner (U+2060, no width) binds them.
local WJ = "\u{2060}"
local function join_parens(s)
  return (s:gsub("%)%(", ")" .. WJ .. "("))
end
local function join_inlines(l)
  return l:walk({ Str = function(el) if el.text:find(")(", 1, true) then return pandoc.Str(join_parens(el.text)) end end })
end

-- Plain text as runs; a section sign or pilcrow stays with its number (typst boxes "§ 158").
local function runs(text, o)
  return xe.runs(join_parens((text:gsub("([\u{00A7}\u{00B6}]) ", "%1\u{00A0}"))), o)
end

-- Pandoc inlines (or a metadata value) as runs, with the same break rules.
local function inl(x, o)
  if x ~= nil and type(x) ~= "string" and pandoc.utils.type(x) == "Inlines" then x = join_inlines(x) end
  return xe.inl(x, o)
end

local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

local function outline(level)
  return '<w:outlineLvl w:val="' .. (level - 1) .. '"/>'
end

-- ---------------------------------------------------------------- needles and pages

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

-- A needle: the text and what follows it (B: body, found in document order; N: inside a footnote).
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

-- ---------------------------------------------------------------- helpers

local function need_meta(meta, key)
  if meta[key] == nil then error("bap1: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function roman(n)
  local out = ""
  for _, p in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- A section's properties: its footer (written by fb render), letter paper, 1 in margins; the page numbers run on.
local function sect_pr(footer)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="676" w:gutter="0"/></w:sectPr>'
end

-- Words, block by block (typst: plain(), with every block set off by spaces): footnotes count.
local function words_in(s)
  local n = 0
  for w in s:gsub("\194\160", " "):gmatch("%S+") do
    if w:find("[%w]") then n = n + 1 end
  end
  return n
end

local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do n = n + count_words(item) end
    elseif b.t == "BlockQuote" then
      n = n + count_words(b.content)
    else
      n = n + words_in(stringify(b))
      pandoc.Pandoc({ b }):walk({ Note = function(note) n = n + count_words(note.content) end })
    end
  end
  return n
end

-- ---------------------------------------------------------------- cover (typst: cover)

-- Lines a text takes in a column of `chars` characters (an estimate: Times 14 pt averages about 6.4 pt a character).
local function est(text, chars)
  return math.max(1, math.ceil(#stringify(text) / chars))
end

local function brief_title(meta)
  if meta.party then return CFG.title .. ", " .. stringify(meta.party):upper() end
  return CFG.title
end

local function cover(meta)
  local caption = need_meta(meta, "caption")
  local groups = need_meta(meta, "counsel")
  -- The typst cover spreads its parts with fractions of the free height (1.2, 0.8, 0.8, 1, 1); Word has none, so
  -- the free height is estimated from the lines (20 pt each, 3.2 pt between), with a margin.
  local lines, extra = 3, 0
  if meta.bankruptcy_case then lines = lines + 1; extra = extra + 11.2 end
  if meta.debtor then
    for _, n in ipairs(meta.debtor.names) do lines = lines + est(n, 70) end
    lines = lines + 1; extra = extra + 8.4
  end
  for i, side in ipairs(caption) do
    for _, n in ipairs(side.names) do lines = lines + est(n, 70) end
    lines = lines + 1
    if i == 1 then lines = lines + 1; extra = extra + 11.2 end
  end
  lines = lines + est(need_meta(meta, "proceeding"), 70) + est(brief_title(meta), 60)
  local cl = {}
  for gi, g in ipairs(groups) do
    local n = #g.names
    for _, l in ipairs(g.lines or {}) do n = n + est(l, #groups > 1 and 32 or 70) end
    cl[gi] = n
  end
  if #groups > 1 then
    for r = 1, #groups, 2 do lines = lines + math.max(cl[r], cl[r + 1] or 0); extra = extra + 9.8 end
  else
    lines = lines + cl[1]
  end
  if meta.phone then lines = lines + 1; extra = extra + 9.8 end
  local free = 648 - lines * 23.2 - extra - 24
  local fr = math.max(0, math.floor(free / 4.8 * 20))

  local out = {}
  local function add(x) out[#out + 1] = x end
  local function line(before, after, body, o)
    local props = { spacing(before or COVER_GAP, after or COVER_GAP), ind(0, nil, 0), jc((o and o.left) and "left" or "center") }
    add(para(props, body))
  end
  line(0, nil, runs("BAP No. ", {}) .. inl(need_meta(meta, "case_number"), {}))
  line(math.floor(1.2 * fr), nil, runs("UNITED STATES BANKRUPTCY APPELLATE PANEL", {}))
  line(nil, nil, runs("FOR THE FIRST CIRCUIT", {}))
  if meta.bankruptcy_case then line(224, nil, runs("Bankruptcy Case No. ", {}) .. inl(meta.bankruptcy_case, {})) end
  local first = true
  local function top()
    local b = first and math.floor(0.8 * fr) or nil
    first = false
    return b
  end
  if meta.debtor then
    for _, n in ipairs(meta.debtor.names) do line(top(), nil, inl(n, {})) end
    line(nil, 168, inl(meta.debtor.designation, {}))
  end
  for i, side in ipairs(caption) do
    for _, n in ipairs(side.names) do line(top(), nil, inl(n, {})) end
    line(nil, nil, inl(side.designation, {}))
    if i == 1 then line(112, 112, runs("v.", {})) end
  end
  line(math.floor(0.8 * fr), nil, inl(need_meta(meta, "proceeding"), {}))
  line(fr, nil, runs(brief_title(meta), { b = true }))
  -- counsel (FRBP 8015(a)(2)(F)): several groups side by side in two columns (typst grid, 1 em gutter)
  local function cell(g, before, after)
    local items = {}
    for _, n in ipairs(g.names) do items[#items + 1] = runs(stringify(n):upper(), { b = true }) end
    for _, l in ipairs(g.lines or {}) do items[#items + 1] = inl(l, { i = true }) end
    local x = {}
    for k, body in ipairs(items) do
      x[#x + 1] = para({ spacing(k == 1 and before or COVER_GAP, k == #items and after or COVER_GAP), ind(0, nil, 0),
        jc("left") }, body)
    end
    return table.concat(x)
  end
  -- the last cover line carries the section's properties (no footer), so a full cover adds no line
  local last = meta.phone and "" or sect_pr("rIdFtrNone")
  if #groups == 1 then
    add(cell(groups[1], fr, COVER_GAP))
  else
    -- typst grid: no space at the top or bottom of a cell; 9.8 pt between rows
    local t = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblBorders>'
      .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
      .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
      .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
      .. '<w:tblGrid><w:gridCol w:w="4820"/><w:gridCol w:w="4540"/></w:tblGrid>' }
    local cols = { { 4820, 280 }, { 4540, 0 } }
    for r = 1, #groups, 2 do
      t[#t + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      for c = 1, 2 do
        local g = groups[r + c - 1]
        t[#t + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. cols[c][1] .. '" w:type="dxa"/><w:tcMar><w:right w:w="'
          .. cols[c][2] .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
          .. (g and cell(g, r == 1 and fr or 196, 0) or para({ spacing(0, 0, 20) }, "")) .. '</w:tc>'
      end
      t[#t + 1] = '</w:tr>'
    end
    t[#t + 1] = '</w:tbl>'
    add(table.concat(t))
    -- a table cannot end a section: a 1 pt line after it
    if last ~= "" then add(para({ spacing(0, 0, 20), last }, "")); last = "" end
  end
  if meta.phone then
    add(para({ spacing(196, 0), ind(0, nil, 0), jc("left"), sect_pr("rIdFtrNone") },
      runs("Telephone: ", {}) .. inl(meta.phone, {})))
  elseif last ~= "" then
    -- the last counsel line ends the section
    local s = out[#out]
    local at = s:match(".*()</w:pPr>")
    out[#out] = s:sub(1, at - 1) .. last .. s:sub(at)
  end
  return raw(table.concat(out))
end

-- A front-matter page title (typst front-title): it opens its page (no space above).
local function front_title(text)
  return para({ KEEP, BREAK, spacing(0, 336), ind(0, nil, 0), jc("center") }, runs(text:upper(), { b = true }))
end

-- A body paragraph of the front or back matter (typst: a paragraph at the body pitch).
local function body_para(body, indent)
  return para({ spacing(0, 0, DOUBLE), ind(0, nil, indent and INDENT or 0) }, body)
end

-- ---------------------------------------------------------------- headings

local function heading_label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return tostring(n) .. "." end
  return string.char(96 + n) .. "."
end

-- typst: level 1 above 16.8 pt, below 14; level 2 14 / 14; level 3 14 / 11.2; levels 4-5 11.2 / 8.4.
local SPACE = { { 336, 280 }, { 280, 280 }, { 280, 224 }, { 224, 168 }, { 224, 168 } }

local function heading_xml(level, content, lab, top)
  local sp = SPACE[level]
  local before = top and 0 or sp[1]
  if level == 1 then
    return para({ KEEP, top and BREAK or "", spacing(before, sp[2]), ind(0, nil, 0), jc("center"), outline(1) },
      runs(stringify(content):upper(), { b = true }))
  end
  local o = level >= 5 and { i = true } or { b = true }
  return para({ KEEP, top and BREAK or "", spacing(before, sp[2]), ind(INDENT, INDENT), outline(level) },
    runs(lab .. "\t", o) .. inl(content, o))
end

-- ---------------------------------------------------------------- tables

local function toc_row(h)
  local left, hanging, lead = 0, nil, ""
  if h.level >= 2 then
    left = (h.level - 2) * INDENT + INDENT
    hanging = INDENT
    lead = runs(h.label .. "\t", {})
  end
  return para({ LINES, xe.leader_tab(TEXT_W), spacing(224, 0), ind(left, hanging, nil, TOC_COL) },
    lead .. inl(h.content, {}) .. runs(LEAD .. label_of(h.id), {}))
end

local occurrences = {}

local function toa_rows(auths)
  local out = {}
  for _, g in ipairs(TOA_GROUPS) do
    local entries = {}
    for key, a in pairs(auths) do
      if stringify(a.kind) == g[1] then
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == key then
            local l = labels["T:" .. o.index]
            local p = l and l.page or -o.index
            if not seen[p] then
              seen[p] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
            end
          end
        end
        if #pages > 0 then
          entries[#entries + 1] = { key = key, a = a, pages = pages,
            sort = stringify(a.sort or a.name or a.cite):lower() }
        end
      end
    end
    -- an authority the body never cites is left out, as is an empty group (typst)
    if #entries > 0 then
      table.sort(entries, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      out[#out + 1] = para({ KEEP, spacing(280, 112), ind(0, nil, 0) }, runs(g[2], { b = true }))
      for _, e in ipairs(entries) do
        table.sort(e.pages, function(x, y) return x.page < y.page end)
        local refs
        if #e.pages >= PASSIM then
          refs = "passim"
        else
          local l = {}
          for _, p in ipairs(e.pages) do l[#l + 1] = p.label end
          refs = table.concat(l, ", ")
        end
        -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): Times digits
        -- are 0.5 em (140 twips at 14 pt), a comma and a space 0.25 em each
        local w = 0
        for c in refs:gmatch(".") do w = w + (c:match("%d") and 140 or 70) end
        local a = e.a
        local name
        if a.name ~= nil then
          name = inl(a.name, { i = g[1] == "case" }) .. runs(", ", {}) .. inl(a.cite, {})
        else
          name = inl(a.cite, {})
        end
        out[#out + 1] = para({ LINES, xe.leader_tab(TEXT_W), spacing(70, 0), ind(280, 280, nil, math.max(TOA_COL, w)) },
          name .. runs(LEAD .. refs, {}))
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------- citations, in document order

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
    Inlines = function(l) return join_inlines(xe.inlines(l)) end,
  }).blocks
end

-- ---------------------------------------------------------------- signature blocks and statements

local function sig_line(before, body, keep, left)
  return para({ keep and KEEP or LINES, spacing(before, 0, FORM), ind(left or 0, nil, 0), jc("left") }, body)
end

local function form_statement(meta, title, rule, options, extra)
  local sig = meta.signature
  local out = {}
  local function c(before, after, body)
    out[#out + 1] = para({ KEEP, #out == 0 and BREAK or "", spacing(before, after, FORM), ind(0, nil, 0), jc("center") }, body)
  end
  c(0, 0, runs("UNITED STATES BANKRUPTCY APPELLATE PANEL", {}))
  c(0, 0, runs("FOR THE FIRST CIRCUIT", {}))
  c(168, 0, runs("BAP No. ", {}) .. inl(meta.case_number, {}))
  if meta.bankruptcy_case then c(0, 0, runs("Bankruptcy Case No. ", {}) .. inl(meta.bankruptcy_case, {})) end
  local first = 168
  if meta.debtor then
    for _, n in ipairs(meta.debtor.names) do c(first, 0, inl(n, {})); first = 0 end
    c(0, 168, inl(meta.debtor.designation, {}))
  end
  for i, side in ipairs(meta.caption) do
    for _, n in ipairs(side.names) do c(first, 0, inl(n, {})); first = 0 end
    c(0, 0, inl(side.designation, {}))
    if i == 1 then c(112, 112, runs("v.", {})) end
  end
  c(168, 0, runs(title:upper(), { b = true }))
  c(0, 336, runs(rule, {}))
  for i, opt in ipairs(options) do
    local box = runs(opt[1] and "X" or "\u{00A0}\u{00A0}\u{00A0}", { box = true })
    out[#out + 1] = para({ LINES, spacing(0, 224, FORM), ind(BOX_COL, BOX_COL) }, box .. runs("\t", {}) .. runs(opt[2], {}))
    if i == 1 then
      for _, x in ipairs(extra) do
        out[#out + 1] = para({ LINES, spacing(0, 112, FORM), ind(INDENT, nil, 0) }, x)
      end
    end
  end
  local half = TEXT_W / 2
  out[#out + 1] = sig_line(336, runs("s/ " .. stringify(sig.signer):upper(), {}), true, half)
  for _, l in ipairs(sig.lines) do out[#out + 1] = sig_line(0, inl(l, {}), true, half) end
  if meta.date then out[#out + 1] = sig_line(0, runs("Dated: ", {}) .. inl(meta.date, {}), false, half) end
  return table.concat(out)
end

-- ---------------------------------------------------------------- the document

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "counsel", "signature" }) do need_meta(meta, k) end
  local auths = meta.authorities or {}
  local sig = meta.signature

  -- required sections (FRBP 8014), compared case-insensitively, and the word limit
  local present = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then present[stringify(b.content):lower()] = true end
  end
  for _, titles in ipairs(CFG.required) do
    local ok = false
    for _, h in ipairs(titles) do if present[h:lower()] then ok = true end end
    if not ok then
      error("bap1: the " .. KIND .. " brief needs a level-1 heading titled one of `" .. table.concat(titles, "`, `")
        .. "` (FRBP 8014)", 0)
    end
  end
  local words = count_words(doc.blocks)
  if words > CFG.limit then
    error("bap1: " .. words .. " words exceeds the " .. CFG.limit .. "-word limit (" .. CFG.cite .. ")", 0)
  end

  need("S:cover", "B", "BAP No. " .. stringify(meta.case_number), "United States Bankruptcy Appellate Panel")

  -- the body: headings (labels, needles, contents rows), citations (needles), paragraphs
  -- every heading's label first (a heading's needle goes on with the next block, its label included)
  local counters = { 0, 0, 0, 0, 0 }
  local labs = {}
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lvl = math.min(b.level, 5)
      labs[i] = ""
      if lvl >= 2 then
        counters[lvl] = counters[lvl] + 1
        for d = lvl + 1, 5 do counters[d] = 0 end
        labs[i] = heading_label(lvl, counters[lvl])
      else
        for d = 2, 5 do counters[d] = 0 end
      end
    end
  end
  local body, headings = {}, {}
  local prev = nil
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lvl = math.min(b.level, 5)
      local lab = labs[i]
      local id = "H:" .. (#headings + 1)
      local nxt = blocks[i + 1] and ((labs[i + 1] or "") .. " " .. stringify(blocks[i + 1])):sub(1, 40) or ""
      need(id, "B", lab .. " " .. stringify(b.content), nxt)
      headings[#headings + 1] = { id = id, level = lvl, label = lab, content = b.content }
      body[#body + 1] = raw(heading_xml(lvl, b.content, lab, #body == 0))
    else
      scan_blocks({ b }, false)
      if b.t == "Para" and (prev == nil or prev.t ~= "Para") then
        -- typst indents only a paragraph that follows another paragraph
        body[#body + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "BAP First" }))
      else
        for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
      end
    end
    prev = b
  end
  for _, o in ipairs(occurrences) do
    if not auths[o.key] then error("bap1: link toa:" .. o.key .. " has no entry under authorities:", 0) end
  end
  body = strip_links(body)

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage"))

  local out = {}
  local function add(x) out[#out + 1] = x end
  local function addx(x) out[#out + 1] = raw(x) end

  -- page 1: the cover (its own section, no page number)
  add(cover(meta))

  -- corporate disclosure (FRBP 8012), when given
  if meta.disclosure then
    addx(front_title("Corporate Disclosure Statement") .. body_para(inl(meta.disclosure, {})))
  end

  -- table of contents (FRBP 8014(a)(2))
  local toc = { front_title("Table of Contents") }
  for _, h in ipairs(headings) do
    if h.level <= 4 then toc[#toc + 1] = toc_row(h) end
  end
  addx(table.concat(toc))

  -- table of authorities (FRBP 8014(a)(3))
  addx(front_title("Table of Authorities") .. toa_rows(auths))

  -- statement regarding oral argument (1st Cir. BAP L.R. 8019-1(a)), after the tables
  if meta["oral-argument"] then
    addx(front_title("Statement Regarding Oral Argument") .. body_para(inl(meta["oral-argument"], {})))
  end

  -- the brief
  for _, x in ipairs(body) do add(x) end

  -- signature block, kept whole
  local s = { sig_line(336, runs("Respectfully submitted,", {}), true) }
  if meta.date then s[#s + 1] = sig_line(0, inl(meta.date, {}), true) end
  s[#s + 1] = sig_line(224, runs("s/ " .. stringify(sig.signer):upper(), {}), #sig.lines > 0)
  for i, l in ipairs(sig.lines) do s[#s + 1] = sig_line(0, inl(l, { i = true }), i < #sig.lines) end
  addx(table.concat(s))

  -- certificate of compliance (FRBP 8015(h)); wording as in the typst template
  local c = { front_title("Certificate of Compliance"),
    body_para(runs("This brief complies with the type-volume limitation of " .. CFG.cite .. " because it contains "
      .. words .. " words, excluding the parts of the brief exempted under Fed. R. Bankr. P. 8015(g).", {})),
    body_para(runs("This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) "
      .. "and (6) because it has been prepared in a proportionally spaced typeface, " .. FONT_NAME .. " " .. FONT_SIZE
      .. "-point, using the vendored font.", {}), true) }
  local tail = {}
  tail[#tail + 1] = runs("s/ " .. stringify(sig.signer):upper(), {})
  if sig.lines[1] then tail[#tail + 1] = inl(sig.lines[1], { i = true }) end
  if meta.date then tail[#tail + 1] = runs("Dated: ", {}) .. inl(meta.date, {}) end
  for i, x in ipairs(tail) do c[#c + 1] = sig_line(i == 1 and 336 or 0, x, i < #tail) end
  addx(table.concat(c))

  -- statement regarding related cases (1st Cir. BAP L.R. 8014-1(a)(2), Official Form 1)
  local rc = meta.related_cases or {}
  local rcs = rc.status and stringify(rc.status) or "none"
  local cases = {}
  if rcs == "pending" then
    for _, k in ipairs(rc.cases or {}) do
      cases[#cases + 1] = inl(k.number, {}) .. runs(", ", {}) .. inl(k.name, {}) .. runs(" (", {})
        .. inl(k.relationship, {}) .. runs(")", {})
    end
  end
  addx(form_statement(meta, "Statement Regarding Related Cases", "1st Cir. BAP L.R. 8014-1(a)(2)", {
    { rcs == "pending", "The undersigned certifies that the following are known related cases and appeals:" },
    { rcs == "none", "The undersigned certifies that the undersigned knows of no related cases or appeals as that term "
      .. "is defined in 1st Cir. BAP L.R. 8014-1(a)(2)(A)." },
  }, cases))

  -- statement regarding interested parties (L.R. 8014-1(a)(3), Official Form 2); not for governmental parties
  local gov = meta.governmental_party
  if not (gov == true or (gov ~= nil and stringify(gov) == "true")) then
    local ip = meta.interested_parties or {}
    local ips = ip.status and stringify(ip.status) or "none"
    local parties = {}
    if ips == "listed" then
      for _, p in ipairs(ip.parties or {}) do parties[#parties + 1] = inl(p, {}) end
    end
    addx(form_statement(meta, "Statement Regarding Interested Parties", "1st Cir. BAP L.R. 8014-1(a)(3)", {
      { ips == "listed", "The undersigned certifies that the following parties have an interest in the outcome of "
        .. "this appeal. These representations are made to enable the judges of the Panel to evaluate possible "
        .. "disqualification or recusal." },
      { ips == "none", "The undersigned certifies that the undersigned knows of no interested party as that term is "
        .. "defined in 1st Cir. BAP L.R. 8014-1(a)(3)(A)." },
    }, parties))
  end

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
