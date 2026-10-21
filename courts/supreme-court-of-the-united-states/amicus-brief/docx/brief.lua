-- Supreme Court of the United States: amicus curiae brief (booklet format), docx engine
-- (typst: scotus-amicus-brief-amicus-brief.typ). pandoc writes the body (paragraphs, quotations, footnotes) with
-- docx/reference.docx (page setup, Schola 12/14 pt, 10/12 pt notes); this filter writes what needs Word formatting:
--   * the cover (Rule 34.1), the table of contents and the table of authorities (Rule 34.2), the headings and
--     their labels (I., A., 1., a.), the signature block (Rule 34.3) and the certificate of compliance (Rule 33.1(h)),
--     as paragraphs with explicit spacing, indents and tabs;
--   * list items as paragraphs whose bullet is a character of the body face (pandoc's list numbering would make
--     LibreOffice draw the bullet in OpenSymbol, DEF-FONT-002);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of
--     every heading and citation in the LibreOffice PDF (the needles this filter writes) and renders again with
--     those pages (FORMBOOK_PAGES), until they settle. A citation is each place the body's text contains an
--     authority's `match` text (typst: the show rule on the same text);
--   * the sections whose footers number the pages: cover (none), tables (i, ii ...), body and signature (1, 2 ...),
--     certificate (none). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local WORD_LIMITS = { government = 9000, other = 8000 } -- Rule 33.1(g): amicus briefs on the merits
local PASSIM = 6          -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local TOC_DEPTH = 3       -- heading levels in the table of contents (typst: toc-row for levels 1 to 3)
local TEXT_W = 5940       -- the text width, 4 1/8 in (Rule 33.1(c)), in twips
local PNUM = 576          -- the column the tables' page numbers keep to themselves
local LABEL = 576         -- the label box of point headings, 0.4 in (typst: label-tab)
local QUOTE_L = 480       -- reference.docx Block Text indent
local NEEDLE_MAX = 60     -- a needle is a prefix of the text (letters and digits only)

local stringify = pandoc.utils.stringify

-- ---------------------------------------------------------------------------
-- WordprocessingML
-- ---------------------------------------------------------------------------

local KEEP = "<w:keepNext/><w:keepLines/>"
local BREAK = "<w:pageBreakBefore/>"

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function spacing(before, after, line)
  return '<w:spacing w:before="' .. (before or 0) .. '" w:after="' .. (after or 0) .. '" w:line="' .. (line or 280)
    .. '" w:lineRule="exact"/>'
end

local function ind(left, hanging, right)
  return '<w:ind w:left="' .. (left or 0) .. '" w:right="' .. (right or 0) .. '"'
    .. (hanging and (' w:hanging="' .. hanging .. '"') or ' w:firstLine="0"') .. "/>"
end

local function jc(v) return '<w:jc w:val="' .. v .. '"/>' end

-- the tables' dot leader to the page number at the right margin
local LEADER = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/></w:tabs>'

-- pPr parts in schema order: keep, page break, tabs, spacing, indent, justification
local function para(ppr, body)
  return "<w:p><w:pPr>" .. table.concat(ppr) .. "</w:pPr>" .. (body or "") .. "</w:p>"
end

local function runs(text, o)
  o = o or {}
  local rpr = (o.b and "<w:b/><w:bCs/>" or "") .. (o.i and "<w:i/><w:iCs/>" or "")
    .. (o.sz and ('<w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/>') or "")
  local out = {}
  for piece, tab in (text .. "\0"):gmatch("([^\t%z]*)([\t%z])") do
    if piece ~= "" then
      out[#out + 1] = "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
        .. '<w:t xml:space="preserve">' .. esc(piece) .. "</w:t></w:r>"
    end
    if tab == "\t" then out[#out + 1] = "<w:r><w:tab/></w:r>" end
  end
  return table.concat(out)
end

-- Inlines (or a metadata value) as runs: Emph is italic, Strong bold, quotes curly.
local function inl(x, o)
  o = o or {}
  if x == nil then return "" end
  local ty = pandoc.utils.type(x)
  if ty == "string" then return runs(x, o) end
  if ty == "Blocks" then
    local out = {}
    for _, b in ipairs(x) do out[#out + 1] = inl(b.content or {}, o) end
    return table.concat(out, runs(" ", o))
  end
  local out = {}
  for _, el in ipairs(x) do
    local t = el.t
    if t == "Str" then out[#out + 1] = runs(el.text, o)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then out[#out + 1] = runs(" ", o)
    elseif t == "Emph" then out[#out + 1] = inl(el.content, { b = o.b, i = not o.i, sz = o.sz })
    elseif t == "Strong" then out[#out + 1] = inl(el.content, { b = true, i = o.i, sz = o.sz })
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = runs(q[1], o) .. inl(el.content, o) .. runs(q[2], o)
    elseif t == "Note" then error("brief.lua: a footnote is not supported here (list item or metadata)")
    elseif el.content and type(el.content) ~= "string" then out[#out + 1] = inl(el.content, o)
    else out[#out + 1] = runs(stringify(el), o) end
  end
  return table.concat(out)
end

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, written by fb render) and page numbers, on the
-- booklet page of reference.docx (Rule 33.1(a), (c)).
local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="8820" w:h="13320"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1620" w:left="1440" '
    .. 'w:header="0" w:footer="540" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (1 pt high).
local function section(footer, fmt)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>")
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order), N (inside a footnote).
local needles = {}
local function need(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

local labels = {} -- id -> { page, label }; empty on the first pass
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
  return l and l.label or "00" -- the first pass: a placeholder of the final width
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Citations (each place the text contains an authority's `match` text): their needles, in document order
-- ---------------------------------------------------------------------------

local MATCHES = {}     -- { key, text }: the authorities' match texts (set from the frontmatter)
local occurrences = {} -- { key, index }

-- The plain text of inlines without footnotes, and the footnotes in it by position.
local function flatten(list, st)
  for _, el in ipairs(list) do
    if el.t == "Note" then
      st.events[#st.events + 1] = { pos = #st.buf, note = el.content }
    elseif el.t == "Str" then st.buf = st.buf .. el.text
    elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then st.buf = st.buf .. " "
    elseif el.content and type(el.content) ~= "string" then flatten(el.content, st)
    end
  end
end

local scan_blocks
local function scan_inlines(list, in_note)
  local st = { buf = "", events = {} }
  flatten(list, st)
  for _, m in ipairs(MATCHES) do
    local from = 1
    while true do
      local s, e = st.buf:find(m.text, from, true)
      if not s then break end
      st.events[#st.events + 1] = { pos = s, key = m.key, text = m.text, rest = st.buf:sub(e + 1) }
      from = e + 1
    end
  end
  -- in text order; a footnote mark sits after the text before it (its pos is that text's length)
  for i, e in ipairs(st.events) do e.order = i end
  table.sort(st.events, function(p, q)
    local a, b = p.note and p.pos + 0.5 or p.pos, q.note and q.pos + 0.5 or q.pos
    if a ~= b then return a < b end
    return p.order < q.order
  end)
  for _, e in ipairs(st.events) do
    if e.note then
      scan_blocks(e.note, true)
    else
      occurrences[#occurrences + 1] = { key = e.key, index = #occurrences + 1 }
      need("T:" .. #occurrences, in_note and "N" or "B", e.text, e.rest)
    end
  end
end

scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" then scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Word count (typst count-words: the markdown source of the body, markup removed)
-- ---------------------------------------------------------------------------

local function count_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then error("brief.lua: cannot read the sample to count its words") end
  local s = h:read("a")
  h:close()
  s = s:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1)
  s = s:gsub("<!%-%-.-%-%->", " ")
  local lines = {}
  for line in (s .. "\n"):gmatch("(.-)\r?\n") do
    line = line:gsub("^%[%^[^%]]+%]:", " ")       -- footnote labels; the note text counts (Rule 33.1(d))
    line = line:gsub("%[%^[^%]]+%]", "")           -- footnote references
    line = line:gsub("%[([^%]]*)%]%([^%)]*%)", "%1") -- links keep their text
    line = line:gsub("^#+[ \t]+", "")
    line = line:gsub("^>[ \t]?", "")
    line = line:gsub("^[ \t]*[-*+][ \t]+", ""):gsub("^[ \t]*%d+[.)][ \t]+", "")
    line = line:gsub("\\(.)", "%1"):gsub("%*", "")
    lines[#lines + 1] = line
  end
  local n = 0
  for _ in table.concat(lines, "\n"):gmatch("%S+") do n = n + 1 end
  return n
end

local function group_digits(n)
  local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (s:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

local function need_meta(meta, k)
  if meta[k] == nil then error("brief.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- A section heading: bold capitals, centered; `brk` opens a new page.
local function section_heading(text, brk)
  return para({ KEEP, brk and BREAK or "", spacing(brk and 0 or 240, 240), ind(0), jc("center") },
    runs(text:upper(), { b = true }))
end

-- The label of a point heading (typst heading-label): level 2 "I.", 3 "A.", 4 "1.", 5 "a.".
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

local function heading_label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return n .. "." end
  if level == 5 then return string.char(96 + n) .. "." end
  error("brief.lua: headings deeper than level 5 are not supported")
end

-- A body heading: level 1 a section heading; a point's label sits in a 0.4 in box, its text hangs after it.
local function heading_xml(h, lab)
  if h.level == 1 then return section_heading(stringify(h.content), false) end
  return para({ KEEP, spacing(120, 240), ind((h.level - 2) * LABEL + LABEL, LABEL) },
    runs(lab .. "\t", { b = true }) .. inl(h.content, { b = true }))
end

-- Bullet list items: "•", a tab, the text, hanging at the tab (inside a quotation: in its indents).
local function bullets(list, quoted)
  local left = (quoted and QUOTE_L or 0) + 720
  local out = {}
  for _, item in ipairs(list.content) do
    for k, b in ipairs(item) do
      if b.t ~= "Plain" and b.t ~= "Para" then error("brief.lua: a list item holds only text") end
      local lead = k == 1 and runs("\u{2022}\t") or runs("\t")
      out[#out + 1] = raw(para({ '<w:pStyle w:val="' .. (quoted and "BlockText" or "BodyText") .. '"/>',
        spacing(60, 60), ind(left, 360, quoted and QUOTE_L or 0) }, lead .. inl(b.content)))
    end
  end
  return out
end

-- The body's lists, at the top level and in quotations.
local function fix_lists(blocks, quoted)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" then
      for _, x in ipairs(bullets(b, quoted)) do out[#out + 1] = x end
    elseif b.t == "BlockQuote" then
      local run = {}
      local function flush()
        if #run > 0 then out[#out + 1] = pandoc.BlockQuote(run); run = {} end
      end
      for _, c in ipairs(b.content) do
        if c.t == "BulletList" then
          flush()
          for _, x in ipairs(bullets(c, true)) do out[#out + 1] = x end
        else
          run[#run + 1] = c
        end
      end
      flush()
    elseif b.t == "OrderedList" then
      -- a paragraph that opens with its own letter ("b. The ...") reads as a list: it stays a body paragraph
      -- with the letter as written (typst's markdown reader does not make lists of letters)
      local a = b.listAttributes
      for k, item in ipairs(b.content) do
        local n = a.start + k - 1
        local lab = tostring(n)
        if a.style == "LowerAlpha" then lab = string.char(96 + n)
        elseif a.style == "UpperAlpha" then lab = string.char(64 + n) end
        lab = lab .. (a.delimiter == "OneParen" and ")" or ".")
        for j, c in ipairs(item) do
          if j == 1 and (c.t == "Para" or c.t == "Plain") then
            local content = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
            content:extend(c.content)
            out[#out + 1] = pandoc.Para(content)
          else
            out[#out + 1] = c
          end
        end
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

local function cover(meta)
  local x = {}
  local function add(body, o)
    o = o or {}
    x[#x + 1] = para({ spacing(o.before, o.after), ind(0), jc(o.jc or "center") }, body)
  end
  -- (a) the docket number, (b) the Court, (c) the caption, (d) the proceeding, (e) the title (Rule 34.1)
  add(runs("No. ") .. inl(need_meta(meta, "case_number")), { jc = "left", after = 400 })
  add(runs("In the"))
  add(runs("SUPREME COURT OF THE UNITED STATES", { b = true }), { after = 280 })
  for i, side in ipairs(need_meta(meta, "caption")) do
    if i > 1 then add(runs("v."), { before = 120, after = 120 }) end
    for _, n in ipairs(side.names) do add(inl(n)) end
    add(inl(side.designation))
  end
  add(inl(need_meta(meta, "proceeding")), { before = 280, after = 280 })
  add(runs(stringify(need_meta(meta, "brief_title")):upper(), { b = true }), { after = 400 })
  -- (f) counsel: the counsel of record is identified with the notation directly under the name
  for gi, g in ipairs(need_meta(meta, "counsel")) do
    for _, n in ipairs(g.names) do add(inl(n)) end
    if g.role then add(inl(g.role, { i = true })) end
    for _, l in ipairs(g.lines or {}) do add(inl(l)) end
    if gi == 1 then add(inl(need_meta(meta, "phone"))) end
    add("", {})
  end
  add(inl(need_meta(meta, "counsel_role"), { i = true }), { after = 240 })
  add(inl(need_meta(meta, "date")))
  return raw(table.concat(x))
end

-- The signer's block (signature and certificate): name in bold capitals, lines, date; never split.
local function signer_block(meta, before)
  local sig = need_meta(meta, "signature")
  local out = { para({ KEEP, spacing(before, 0), ind(0) },
    runs(stringify(need_meta(sig, "signer")):upper(), { b = true })) }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = para({ KEEP, spacing(0, 0), ind(0) }, inl(l)) end
  -- the last line keeps no next: the block moves to the next page whole, never split
  out[#out + 1] = para({ "<w:keepLines/>", spacing(160, 0), ind(0) }, inl(need_meta(meta, "date")))
  return table.concat(out)
end

local function signature(meta)
  return para({ KEEP, spacing(280, 0), ind(0) }, runs("Respectfully submitted,")) .. signer_block(meta, 400)
end

local function certificate(meta, words, limit)
  local kind = stringify(need_meta(meta, "amicus_class")) == "government"
    and "an amicus curiae identified in Rule 37.6" or "any other amicus curiae"
  return section_heading("Certificate of Compliance", false)
    .. para({ spacing(0, 240), ind(0) }, runs("Pursuant to Rule 33.1(h), I certify that the attached brief complies "
      .. "with the word limitation of Rule 33.1(g). It contains " .. group_digits(words) .. " words, excluding the "
      .. "items listed in Rule 33.1(d). The limit for " .. kind .. " is " .. group_digits(limit) .. " words."))
    .. signer_block(meta, 0)
end

-- One row of a table: the text, a dot leader and the page, the text hanging at `hang`.
local function row(left, hang, body, page)
  return para({ "<w:keepLines/>", LEADER, spacing(60, 0), ind(left + (hang or 0), hang, PNUM) },
    body .. runs(" \t") .. runs(page))
end

local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "regulation", "Regulations" },
  { "other", "Other Authorities" } }

local function sort_key(a)
  return (stringify(a.name):lower():gsub("[^a-z0-9 ]", ""))
end

-- Every page on which an authority is cited, or "passim" (typst: toa-section).
local function toa_rows(authorities)
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if stringify(a.kind) == g[1] then members[#members + 1] = { key = key, a = a, sort = sort_key(a) } end
    end
    table.sort(members, function(p, q)
      if p.sort ~= q.sort then return p.sort < q.sort end
      return p.key < q.key
    end)
    if #members > 0 then
      out[#out + 1] = para({ KEEP, spacing(200, 60), ind(0) }, runs(g[2], { b = true }))
      for _, m in ipairs(members) do
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local k = l and l.page or -o.index
            if not seen[k] then
              seen[k] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
            end
          end
        end
        -- a table of authorities lists cited authorities only: an uncited entry is an error
        if #pages == 0 then error("brief.lua: authority `" .. m.key .. "` is listed but not cited in the body") end
        table.sort(pages, function(p, q) return p.page < q.page end)
        local list = {}
        for _, p in ipairs(pages) do list[#list + 1] = p.label end
        local where = #pages >= PASSIM and "passim" or table.concat(list, ", ")
        local body = inl(m.a.name)
        if m.a.cite and stringify(m.a.cite) ~= "" then body = body .. runs(", ") .. inl(m.a.cite) end
        out[#out + 1] = row(0, LABEL, body, where)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "counsel_role",
    "signature", "date", "amicus_class" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  for key, a in pairs(authorities) do
    if not a.match then error("brief.lua: authority `" .. key .. "` has no `match` text") end
    MATCHES[#MATCHES + 1] = { key = key, text = stringify(a.match) }
  end
  table.sort(MATCHES, function(p, q) return p.key < q.key end)
  local words = count_words()
  local limit = WORD_LIMITS[stringify(meta.amicus_class)] or WORD_LIMITS.other
  if words > limit then
    error("brief.lua: the body has " .. words .. " words; Rule 33.1(g) allows " .. limit)
  end

  need("S:toc", "B", "Table of Contents", "")
  need("S:toa", "B", "Table of Authorities", "")

  -- the body: headings (labels, needles, contents entries) and citations (needles)
  local items = {}
  local counts = { 0, 0, 0, 0, 0 }
  local body = {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level > 5 then error("brief.lua: headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, #counts do counts[k] = 0 end
      local lab = b.level > 1 and heading_label(b.level, counts[b.level]) or ""
      local id = "H:" .. i
      local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
      need(id, "B", lab .. stringify(b.content), nxt)
      if b.level <= TOC_DEPTH then
        items[#items + 1] = { id = id, level = b.level, label = lab, title = stringify(b.content), content = b.content }
      end
      scan_blocks({ pandoc.Para(b.content) }, false)
      body[#body + 1] = raw(heading_xml(b, lab))
    else
      scan_blocks({ b }, false)
      body[#body + 1] = b
    end
  end
  body = fix_lists(body)

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (items[1] and items[1].id or "S:toa") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  local cert = meta.certificate == true or (meta.certificate ~= nil and stringify(meta.certificate) == "true")
  -- the last section: the certificate (no number), or the body's own when there is none
  write_file("FORMBOOK_FINAL", cert and sect_pr("rIdFtrNone") or sect_pr("rIdFtrPage", "decimal"))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  add(cover(meta))
  add(section("rIdFtrNone"))

  -- Section 2: the tables (i, ii ...); the table of authorities starts its own page
  add(raw(section_heading("Table of Contents", false)))
  for _, it in ipairs(items) do
    if it.level == 1 then
      add(raw(row(0, nil, runs(it.title:upper()), label_of(it.id))))
    else
      add(raw(row((it.level - 2) * LABEL, LABEL, runs(it.label .. "\t") .. inl(it.content), label_of(it.id))))
    end
  end
  add(raw(section_heading("Table of Authorities", true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman"))

  -- Section 3: the body (1, 2 ...) and the signature block, kept together
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))

  -- Section 4: the certificate of compliance (Rule 33.1(h)), separate from the brief, unnumbered
  if cert then
    add(section("rIdFtrPage", "decimal"))
    add(raw(certificate(meta, words, limit)))
  end

  -- empty metadata: pandoc would otherwise print the date as a title block above the cover
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
