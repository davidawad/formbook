-- Supreme Court of the United States: brief on the merits (booklet format), docx engine (typst: merits-brief.typ).
-- pandoc writes the body (paragraphs, quotations, footnotes) with docx/reference.docx (page setup, Schola 12/14 pt,
-- 10/12 pt notes); this filter writes what needs Word formatting:
--   * the cover (Rule 34.1), the Question Presented and Parties pages (Rule 24.1(a), (b)), the table of contents and
--     the table of authorities (Rule 34.2), the headings, the signature block (Rule 34.3) and the certificate of
--     compliance (Rule 33.1(h)), as paragraphs with explicit spacing, indents and tabs;
--   * list items as paragraphs whose bullet is a character of the body face (pandoc's list numbering would make
--     LibreOffice draw the bullet in OpenSymbol, DEF-FONT-002);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of
--     every heading and citation in the LibreOffice PDF (the needles this filter writes) and renders again with
--     those pages (FORMBOOK_PAGES), until they settle;
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and signature
--     (1, 2 ...), certificate (none). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local WORD_LIMIT = 13000  -- Rule 33.1(g): brief on the merits for a petitioner or appellant
local TOC_DEPTH = 3       -- heading levels in the table of contents (typst: outline depth 3)
local TEXT_W = 5940       -- the text width, 4 1/8 in (Rule 33.1(c)), in twips
local PNUM = 576          -- the column the tables' page numbers keep to themselves
local STEP = 432          -- a heading level's indent in the contents, 0.3 in (typst: 0.3in)
local HEAD_HANG = 576     -- the hanging indent of point headings, 0.4 in (typst: heading-indent)
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
-- Citations (`[text](toa:key)` links): their needles, in document order
-- ---------------------------------------------------------------------------

local occurrences = {} -- { key, index }

-- The plain text of inlines without footnotes, and the citations and footnotes in it by position.
local function flatten(list, st)
  for _, el in ipairs(list) do
    if el.t == "Note" then
      st.events[#st.events + 1] = { pos = #st.buf, note = el.content }
    elseif el.t == "Link" and el.target:match("^toa:") then
      st.events[#st.events + 1] = { pos = #st.buf, key = el.target:sub(5), text = stringify(el.content) }
      flatten(el.content, st)
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
  for _, e in ipairs(st.events) do
    if e.note then
      scan_blocks(e.note, true)
    else
      occurrences[#occurrences + 1] = { key = e.key, index = #occurrences + 1 }
      need("T:" .. #occurrences, in_note and "N" or "B", e.text, st.buf:sub(e.pos + #e.text + 1))
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

-- A body heading: level 1 a section heading; points (the sample writes their numerals) hang at 0.4 in.
local function heading_xml(h)
  if h.level == 1 then return section_heading(stringify(h.content), false) end
  return para({ KEEP, spacing(120, 240), ind((h.level - 2) * HEAD_HANG + HEAD_HANG, HEAD_HANG) },
    inl(h.content, { b = true }))
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

local function strip_links(blocks)
  return pandoc.Pandoc(blocks):walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  }).blocks
end

local function cover(meta)
  local x = {}
  local function add(body, o)
    o = o or {}
    x[#x + 1] = para({ spacing(o.before, o.after), ind(0), jc(o.jc or "center") }, body)
  end
  add(inl(need_meta(meta, "docket")), { jc = "left" })
  add(runs("IN THE"), { before = 1000 })
  add(runs("SUPREME COURT OF THE UNITED STATES", { b = true }), { after = 280 })
  for _, c in ipairs(need_meta(meta, "caption")) do add(inl(c)) end
  add(inl(need_meta(meta, "proceeding")), { before = 280, after = 280 })
  add(inl(need_meta(meta, "brief_title"), { b = true }), { after = 400 })
  -- counsel (Rule 34.1(f), (g)): 10 pt, exempt from the 11-point floor
  for gi, g in ipairs(need_meta(meta, "counsel")) do
    for k, n in ipairs(g.names) do
      x[#x + 1] = para({ spacing((k == 1 and gi > 1) and 160 or 0, 0, 240), ind(0), jc("center") }, inl(n, { sz = 20 }))
    end
    for _, l in ipairs(g.lines or {}) do
      x[#x + 1] = para({ spacing(0, 0, 240), ind(0), jc("center") }, inl(l, { sz = 20 }))
    end
  end
  if meta.date then add(inl(meta.date), { before = 280 }) end
  return raw(table.concat(x))
end

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local out = { para({ KEEP, spacing(280, 280), ind(0) }, runs("Respectfully submitted,")),
    para({ KEEP, spacing(0, 0), ind(0) }, runs(stringify(need_meta(sig, "signer")))) }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = para({ KEEP, spacing(0, 0), ind(0) }, inl(l)) end
  if meta.date then out[#out + 1] = para({ "<w:keepLines/>", spacing(240, 0), ind(0) }, inl(meta.date)) end
  -- the last line keeps no next: the block moves to the next page whole, never split
  return table.concat(out)
end

-- One row of a table: the text, a dot leader and the page, the text hanging at `hang`.
local function row(left, hang, body, page, before)
  return para({ "<w:keepLines/>", LEADER, spacing(before or 60, 0), ind(left + (hang or 0), hang, PNUM) },
    body .. runs(" \t") .. runs(page))
end

local GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

local function sort_key(a)
  return (stringify(a.sort or a.name):lower():gsub("[^a-z0-9 ]", ""))
end

-- Rule 34.2: every page on which an authority is cited, no "passim" (typst: toa-section).
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
        if #pages == 0 then error("brief.lua: authority `" .. m.key .. "` is listed but never cited") end
        table.sort(pages, function(p, q) return p.page < q.page end)
        local list = {}
        for _, p in ipairs(pages) do list[#list + 1] = p.label end
        local body = inl(m.a.name, { i = g[1] == "case" })
        if m.a.cite then body = body .. runs(", ") .. inl(m.a.cite) end
        out[#out + 1] = row(0, 288, body, table.concat(list, ", "))
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
  for _, k in ipairs({ "docket", "caption", "proceeding", "brief_title", "counsel", "questions", "parties",
    "signature" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  local words = count_words()
  if words > WORD_LIMIT then
    error("brief.lua: the body is " .. words .. " words, over the Rule 33.1(g) limit of " .. WORD_LIMIT)
  end
  local qs = meta.questions
  local qp_title = #qs == 1 and "Question Presented" or "Questions Presented"

  -- the front matter's needles, in page order
  need("S:qp", "B", qp_title, stringify(qs[1]))
  need("S:parties", "B", "Parties to the Proceedings", stringify(meta.parties))
  if meta.disclosure then need("S:disclosure", "B", "Corporate Disclosure Statement", stringify(meta.disclosure)) end
  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "")

  -- the body: headings (needles, contents entries) and citations (needles)
  local items = { { id = "S:qp", level = 1, title = qp_title },
    { id = "S:parties", level = 1, title = "Parties to the Proceedings" } }
  if meta.disclosure then items[#items + 1] = { id = "S:disclosure", level = 1, title = "Corporate Disclosure Statement" } end
  local body = {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local id = "H:" .. i
      local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
      need(id, "B", stringify(b.content), nxt)
      if b.level <= TOC_DEPTH then
        items[#items + 1] = { id = id, level = b.level, title = stringify(b.content) }
      end
      body[#body + 1] = raw(heading_xml(b))
    else
      scan_blocks({ b }, false)
      body[#body + 1] = b
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("brief.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  body = fix_lists(strip_links(body))

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  local first_h
  for _, it in ipairs(items) do
    if it.id:match("^H:") then first_h = it.id; break end
  end
  nl[#nl + 1] = "#section\tS:qp\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (first_h or "S:toa") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrNone"))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  add(cover(meta))
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...), each part on its own page
  add(raw(section_heading(qp_title, false)))
  for _, q in ipairs(qs) do add(raw(para({ spacing(0, 240), ind(0), jc("both") }, inl(q)))) end
  add(raw(section_heading("Parties to the Proceedings", true)))
  add(raw(para({ spacing(0, 240), ind(0), jc("both") }, inl(meta.parties))))
  if meta.disclosure then
    add(raw(section_heading("Corporate Disclosure Statement", false)))
    add(raw(para({ spacing(0, 240), ind(0), jc("both") }, inl(meta.disclosure))))
  end
  add(raw(section_heading("Table of Contents", true)))
  add(raw(para({ KEEP, spacing(0, 60), ind(0), jc("right") }, runs("Page", { sz = 20 }))))
  for _, it in ipairs(items) do
    add(raw(row((it.level - 1) * STEP, it.level > 1 and STEP or nil, runs(it.title), label_of(it.id))))
  end
  add(raw(section_heading("Table of Authorities", true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman"))

  -- Section 3: the body (1, 2 ...) and the signature block, kept together
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(section("rIdFtrPage", "decimal"))

  -- Section 4: the certificate of compliance (Rule 33.1(h)), unnumbered; FORMBOOK_FINAL closes it
  add(raw(section_heading("Certificate of Compliance", false)))
  add(raw(para({ spacing(0, 240), ind(0), jc("both") }, runs("I certify that this brief complies with the word "
    .. "limit of Supreme Court Rule 33.1(g), " .. group_digits(WORD_LIMIT) .. " words for a brief on the merits for "
    .. "a petitioner or appellant, and that it contains " .. group_digits(words) .. " words, excluding the parts "
    .. "that Rule 33.1(d) excludes."))))
  add(raw(signature(meta)))

  -- empty metadata: pandoc would otherwise print the date as a title block above the cover
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
