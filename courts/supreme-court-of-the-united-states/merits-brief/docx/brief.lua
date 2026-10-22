-- Supreme Court of the United States: brief on the merits (booklet format), docx engine
-- (typst: merits-brief.typ). pandoc writes the body (paragraphs, quotations, footnotes) with
-- docx/reference.docx (docx/build-reference.sh: Schola 12 pt in 14 pt lines, 10 pt notes in 12 pt lines); this
-- filter writes what needs Word formatting:
--   * the cover (Rule 34.1), the questions and parties pages (Rule 24.1), the tables (Rules 24.1(c), 34.2), the
--     headings, the block quotations, the signature block (Rule 34.3) and the certificate of compliance (Rule 33.1(h)),
--     as paragraphs with explicit spacing, indents and tabs;
--   * list items as paragraphs whose bullet is a character of the body face (pandoc's list numbering would make
--     LibreOffice draw the bullet in OpenSymbol, DEF-FONT-002);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of
--     every heading and citation in the LibreOffice PDF (the needles this filter writes) and renders again with
--     those pages (FORMBOOK_PAGES), until they settle. A citation is a `[text](toa:key)` link (typst: the link
--     show rule);
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and signature (1, 2 ...),
--     certificate (none). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every line and page breaks where the typst render
-- breaks it. The model is lib/docx/xengine.lua (the break rules of typst on every run, exact line spacing: each line
-- a box of its pitch, the space between paragraphs the larger of the two); the pitches and spaces below are the
-- typst template's, in twips (20 x pt).

local WORD_LIMIT = 13000  -- Rule 33.1(g)(v): brief on the merits for a petitioner or appellant
local TOC_DEPTH = 3       -- heading levels in the table of contents (typst: levels 1 to 3)
-- The text width, 4 1/8 in (Rule 33.1(c)), less what the right margin takes beyond 1 in (MARGIN_R). LibreOffice sets
-- Schola a little narrower than typst (0.088 % on the mean of 203 identical full lines of the amicus sample; its glyph
-- positions are rounded, unevenly: a no-break-hyphen run of 13 characters comes out 0.11 pt short) and starts each
-- line 0.1 pt in, so a line typst overflows by a hair would fit here. The margin is the measured one at which every
-- line of this folder's sample breaks as in typst (amicus-brief 1443 twips, merits-brief 1441: one twip either side
-- moves a line); a line of other text within 0.1 pt of the measure may still break differently (docs/EVAL-LOOP.md).
local TEXT_W = 5939
local MARGIN_R = 1441
local PITCH = 280         -- typst pitch-body: 14 pt (12-point type, 2-point leading; Rule 33.1(b))
local NOTE = 240          -- typst pitch-note: 12 pt (10-point counsel on the cover)
local TOC_COL = 479       -- typst toc-page-col: 24 pt kept for the contents' page numbers, less the margin's extra
local TOA_COL = 800       -- typst toa-page-col: 40 pt (a longer page list widens its own row's column)
local STEP = 432          -- a heading level's indent in the contents, 0.3 in (typst: para-indent)
local HEAD_HANG = 576     -- the hanging indent of level 2 and 3 headings, 0.4 in (typst: heading-indent)
local QUOTE = 576         -- a block quotation's indent on both sides, 0.4 in (typst: pad)
local LIST = 432          -- the bullet's box, 0.3 in (typst: xengine list-indent)
local NEEDLE_MAX = 60     -- a needle is a prefix of the text (letters and digits only)

local stringify = pandoc.utils.stringify

-- ---------------------------------------------------------------------------
-- WordprocessingML: the shared helpers of the cross-engine layout model (lib/docx/xengine.lua)
-- ---------------------------------------------------------------------------

local xe = require("docx.xengine")
local raw, para, jc, KEEP, LINES, BREAK = xe.raw, xe.para, xe.jc, xe.KEEP, xe.LINES, xe.BREAK
-- Before the leader tab of a table row: no-break spaces as wide as typst's 0.75 em (9 pt) between the text and the
-- leader. Schola's space is 0.278 em, so xe.LEAD's three are 10 pt (LibreOffice ignores character spacing on them):
-- two at 12 pt and one at 8.5 pt, 9.04 pt.
local LEAD_XML = '<w:r><w:t xml:space="preserve">\u{00A0}\u{00A0}</w:t></w:r><w:r><w:rPr><w:sz w:val="17"/></w:rPr>'
  .. '<w:t xml:space="preserve">\u{00A0}</w:t></w:r><w:r><w:tab/></w:r>'

local function spacing(before, after, line)
  return xe.spacing(before or 0, after or 0, line or PITCH)
end

local function ind(left, hanging, right)
  return xe.ind(left or 0, hanging, hanging == nil and 0 or nil, right)
end

local function runs(text, o) return xe.runs(text, o or {}) end

-- typst never breaks inside a token of adjacent parentheses ("922(o)(1)": lib/typst/xengine.typ boxes it); LibreOffice
-- would break between ")" and "(": a word joiner (U+2060) between every two characters of such a token.
local function bind_parens(s)
  return (s:gsub("%S+", function(tok)
    if not tok:find(")(", 1, true) then return tok end
    local cs = {}
    for _, c in utf8.codes(tok) do cs[#cs + 1] = utf8.char(c) end
    return table.concat(cs, "\u{2060}")
  end))
end
-- A line may end after a slash before a letter, as typst breaks a web address (Unicode line breaking); LibreOffice
-- would not: a zero-width space there.
local function slash_breaks(s)
  return (s:gsub("/(%a)", "/\u{200B}%1"))
end
local BIND = { Str = function(s) return pandoc.Str(slash_breaks(bind_parens(s.text))) end }

-- A value that reads as a list item ("(202) 787-1060") is a line of text with its marker as written (typst).
local function unlist(x)
  if pandoc.utils.type(x) ~= "Blocks" then return x end
  local out = pandoc.Inlines({})
  for i, b in ipairs(x) do
    if i > 1 then out:insert(pandoc.Space()) end
    if b.t == "OrderedList" and #b.content == 1 and #b.content[1] == 1 then
      local a, n = b.listAttributes, tostring(b.listAttributes.start)
      local lab = a.delimiter == "TwoParens" and ("(" .. n .. ")") or a.delimiter == "OneParen" and (n .. ")") or (n .. ".")
      out:insert(pandoc.Str(lab))
      out:insert(pandoc.Space())
      out:extend(b.content[1][1].content)
    elseif b.content and type(b.content) == "table" then
      out:extend(b.content)
    end
  end
  return out
end

-- Inlines (or a metadata value) as runs: Emph is italic, Strong bold, quotes curly; typst's break rules.
local function inl(x, o)
  if x == nil then return "" end
  if pandoc.utils.type(x) == "string" then return runs(bind_parens(x), o) end
  return xe.inl(pandoc.Inlines(unlist(x)):walk(BIND), o or {})
end

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, written by fb render) and page numbers, on the
-- booklet page (Rule 33.1(a), (c)).
local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="8820" w:h="13320"/><w:pgMar w:top="1440" w:right="' .. MARGIN_R .. '" w:bottom="1620" w:left="1440" '
    .. 'w:header="0" w:footer="540" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (1 pt high).
local function section(footer, fmt)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>")
end

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

-- A heading (typst: show heading), bold, 12 pt: level 1 centred, 13.2 pt above and 10.8 below; levels 2 and 3 with
-- their wrapped lines hanging 0.4 in, 10.8 / 8.4 and 9.6 / 7.2 pt. One that opens a page has no space above (typst
-- drops it there; Word keeps it after a page or section break).
local function heading_xml(level, content, top)
  if level == 1 then
    return para({ KEEP, spacing(top and 0 or 264, 216), ind(0), jc("center") }, inl(content, { b = true }))
  end
  local sp = level == 2 and spacing(top and 0 or 216, 168) or spacing(top and 0 or 192, 144)
  return para({ KEEP, sp, ind(HEAD_HANG, HEAD_HANG) }, inl(content, { b = true }))
end

-- A block quotation (typst: quote): 0.4 in in on both sides, 9 pt above and below; its paragraphs 9 pt apart, its
-- list items (the bullet in a 0.3 in box, the text hanging) with no space of their own.
local function quotation(q)
  local items = {}
  for _, b in ipairs(q.content) do
    if b.t == "BulletList" then
      for _, it in ipairs(b.content) do
        if #it ~= 1 or (it[1].t ~= "Plain" and it[1].t ~= "Para") then error("brief.lua: a list item holds only text") end
        items[#items + 1] = { list = true, body = runs("\u{2022}\t") .. inl(it[1].content) }
      end
    elseif b.t == "Para" or b.t == "Plain" then
      items[#items + 1] = { list = false, body = inl(b.content) }
    else
      error("brief.lua: a block quotation holds paragraphs and bullet lists only")
    end
  end
  local out = {}
  for i, it in ipairs(items) do
    local prev, nxt = items[i - 1], items[i + 1]
    local before = (i == 1 and 180) or ((it.list or prev.list) and 0) or 180
    local after = (i == #items and 180) or ((it.list or nxt.list) and 0) or 180
    local indent = it.list and ind(QUOTE + LIST, LIST, QUOTE) or ind(QUOTE, nil, QUOTE)
    local tabs = it.list and ('<w:tabs><w:tab w:val="left" w:pos="' .. (QUOTE + LIST) .. '"/></w:tabs>') or ""
    out[#out + 1] = para({ tabs, spacing(before, after), indent }, it.body)
  end
  return raw(table.concat(out))
end

-- A paragraph pandoc reads as a list and typst does not ("b. The ...": letters as list markers): a paragraph with
-- the marker as written.
local function unlist_blocks(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" and (b.listAttributes.style == "LowerAlpha" or b.listAttributes.style == "UpperAlpha") then
      local a = b.listAttributes
      for k, item in ipairs(b.content) do
        local n = a.start + k - 1
        local lab = a.style == "LowerAlpha" and string.char(96 + n) or string.char(64 + n)
        lab = lab .. (a.delimiter == "OneParen" and ")" or ".")
        for j, c in ipairs(item) do
          if j == 1 and (c.t == "Para" or c.t == "Plain") then
            local il = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
            il:extend(c.content)
            out[#out + 1] = pandoc.Para(il)
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

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- The cover (typst: cover): centred lines and two rules; the counsel in two columns (a table of 139.5 pt columns,
-- 0.25 in apart) at the foot of the page, 10-point type in 12 pt lines (Rule 34.1(g)).
local function cover(meta)
  local x = {}
  local function line(before, body)
    x[#x + 1] = para({ spacing(before, 0), ind(0), jc("center") }, body)
  end
  local function rule(before)
    x[#x + 1] = para({ '<w:pBdr><w:bottom w:val="single" w:sz="5" w:space="0" w:color="000000"/></w:pBdr>',
      spacing(before, 0, 20), ind(0) }, "")
  end
  line(0, inl(need_meta(meta, "docket")))
  line(1296, runs("IN THE"))
  line(48, runs("Supreme Court of the United States"))
  rule(144)
  for i, c in ipairs(need_meta(meta, "caption")) do line(i == 1 and 144 or 0, inl(c)) end
  rule(144)
  line(144, inl(need_meta(meta, "proceeding")))
  line(144, inl(need_meta(meta, "brief_title"), { b = true }))
  local cells = {}
  for _, g in ipairs(need_meta(meta, "counsel")) do
    local ps = {}
    for _, n in ipairs(g.names) do ps[#ps + 1] = { body = inl(n, { sz = 20 }) } end
    for _, l in ipairs(g.lines or {}) do ps[#ps + 1] = { body = inl(l, { sz = 20, i = true }) } end
    cells[#cells + 1] = ps
  end
  local COL = 2790
  local function cell(ps, first_row)
    local body = {}
    for k, p in ipairs(ps or {}) do
      body[#body + 1] = para({ spacing((k == 1 and not first_row) and 216 or 0, 0, NOTE), ind(0) }, p.body)
    end
    if #body == 0 then body[1] = para({ spacing(0, 0, NOTE) }, "") end
    return '<w:tc><w:tcPr><w:tcW w:w="' .. COL .. '" w:type="dxa"/></w:tcPr>' .. table.concat(body) .. "</w:tc>"
  end
  local rows = {}
  for i = 1, #cells, 2 do
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(cells[i], i == 1)
      .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr><w:p><w:pPr>' .. spacing(0, 0, NOTE) .. '</w:pPr></w:p></w:tc>'
      .. cell(cells[i + 1], i == 1) .. "</w:tr>"
  end
  -- the counsel table floats at the foot of the text block (typst: v(1fr))
  x[#x + 1] = '<w:tbl><w:tblPr><w:tblpPr w:leftFromText="0" w:rightFromText="0" w:vertAnchor="margin" w:horzAnchor="margin" '
    .. 'w:tblpYSpec="bottom"/><w:tblW w:w="' .. (2 * COL + 360) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="' .. COL .. '"/>'
    .. '<w:gridCol w:w="360"/><w:gridCol w:w="' .. COL .. '"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>"
  return raw(table.concat(x))
end

-- typst: signature-block. 14.4 pt above, "Respectfully submitted," 24 pt above the signer, the date 9.6 pt below the
-- lines; never split.
local function signature(meta)
  local sig = need_meta(meta, "signature")
  local out = { para({ KEEP, spacing(288, 480), ind(0) }, runs("Respectfully submitted,")),
    para({ KEEP, spacing(0, 0), ind(0) }, inl(need_meta(sig, "signer"))) }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = para({ KEEP, spacing(0, 0), ind(0) }, inl(l)) end
  if meta.date then out[#out + 1] = para({ LINES, spacing(192, 0), ind(0) }, inl(meta.date)) end
  return table.concat(out)
end

-- One row of a table (typst listing-row): `before` above it; the text from `left`, its wrapped lines at `left` +
-- `hang`, wraps before the page column `col`; a dot leader from three spaces after the text runs to the page.
local function row(before, left, hang, col, body, page)
  return para({ LINES, xe.leader_tab(TEXT_W), spacing(before, 0), ind(left + (hang or 0), hang, col) },
    body .. LEAD_XML .. runs(page))
end

-- The width of a page list in twips (Schola advances at 12 pt): the authorities' page column is as wide as a longer
-- list (typst: calc.max(toa-page-col, measure(ps).width)).
local function list_width(s)
  local u = 0
  for c in s:gmatch(".") do u = u + ((c == "," or c == " ") and 278 or 556) end
  return math.ceil(u * 240 / 1000)
end

local GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

-- Every page on which an authority is cited, in page order (typst: toa-section; no "passim").
local function toa_rows(authorities)
  local used = {}
  for _, o in ipairs(occurrences) do used[o.key] = true end
  for key in pairs(authorities) do
    if not used[key] then error("brief.lua: authority `" .. key .. "` is listed in the frontmatter but never cited") end
  end
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if stringify(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = stringify(a.sort or a.name):lower() }
      end
    end
    table.sort(members, function(p, q)
      if p.sort ~= q.sort then return p.sort < q.sort end
      return p.key < q.key
    end)
    if #members > 0 then
      -- the kind's title: 12 pt above, 4.8 below, kept with its first entry
      out[#out + 1] = para({ KEEP, spacing(240, 96), ind(0) }, runs(g[2], { b = true }))
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
        table.sort(pages, function(p, q) return p.page < q.page end)
        local list = {}
        for _, p in ipairs(pages) do list[#list + 1] = p.label end
        local where = table.concat(list, ", ")
        local body = inl(m.a.name, { i = g[1] == "case" })
        if m.a.cite and stringify(m.a.cite) ~= "" then body = body .. runs(", ") .. inl(m.a.cite) end
        out[#out + 1] = row(120, 0, 360, math.max(TOA_COL, list_width(where)), body, where)
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

  -- the body: headings (needles, contents entries), citations (needles), paragraphs with their styles: the one after
  -- a heading not indented (typst indents a paragraph only after a paragraph), one with a footnote mark without
  -- widow control (typst keeps two lines together by their height alone: when a line's footnote does not fit, that
  -- line moves on and the one before it stays behind alone)
  local items = { { id = "S:qp", level = 1, title = pandoc.Inlines({ pandoc.Str(qp_title) }) },
    { id = "S:parties", level = 1, title = pandoc.Inlines({ pandoc.Str("Parties to the Proceedings") }) } }
  if meta.disclosure then
    items[#items + 1] = { id = "S:disclosure", level = 1, title = pandoc.Inlines({ pandoc.Str("Corporate Disclosure Statement") }) }
  end
  local blocks = unlist_blocks(doc.blocks)
  local body = {}
  local after_para = false -- typst indents a paragraph only after a paragraph (not after a heading or a quotation)
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level > 3 then error("brief.lua: headings deeper than level 3 are not supported") end
      local id = "H:" .. i
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      need(id, "B", stringify(b.content), nxt)
      if b.level <= TOC_DEPTH then items[#items + 1] = { id = id, level = b.level, title = b.content } end
      body[#body + 1] = raw(heading_xml(b.level, b.content, #body == 0))
      after_para = false
    else
      scan_blocks({ b }, false)
      b = pandoc.Pandoc({ b }):walk({
        Link = function(el) if el.target:match("^toa:") then return el.content end end,
      }).blocks[1]
      -- the break rules of typst on the text pandoc writes itself (body, footnotes)
      b = b:walk({ Inlines = xe.inlines }):walk(BIND)
      if b.t == "Para" then
        local style = (after_para and "Body Text" or "First Paragraph") .. (has_note(b) and " Note" or "")
        body[#body + 1] = pandoc.Div({ b }, { ["custom-style"] = style })
      elseif b.t == "BlockQuote" then
        body[#body + 1] = quotation(b)
      else
        for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
      end
      after_para = b.t == "Para"
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("brief.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end

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
  local function front_para(before, x)
    add(raw(para({ spacing(before, 180), ind(0) }, inl(x))))
  end

  -- Section 1: the cover (no page number)
  add(cover(meta))
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...), each part on its own page
  add(raw(heading_xml(1, pandoc.Inlines({ pandoc.Str(qp_title) }), true)))
  for _, q in ipairs(qs) do front_para(0, q) end
  add(raw(para({ BREAK, spacing(0, 0, 20) }, "")))
  add(raw(heading_xml(1, pandoc.Inlines({ pandoc.Str("Parties to the Proceedings") }), true)))
  front_para(0, meta.parties)
  if meta.disclosure then
    add(raw(heading_xml(1, pandoc.Inlines({ pandoc.Str("Corporate Disclosure Statement") }), false)))
    front_para(0, meta.disclosure)
  end
  add(raw(para({ BREAK, spacing(0, 0, 20) }, "")))
  add(raw(heading_xml(1, pandoc.Inlines({ pandoc.Str("Table of Contents") }), true)))
  add(raw(para({ KEEP, spacing(0, 0, NOTE), ind(0), jc("right") }, runs("Page", { sz = 20 }))))
  for _, it in ipairs(items) do
    if it.level <= TOC_DEPTH then
      add(raw(row(96, (it.level - 1) * STEP, nil, TOC_COL, inl(it.title), label_of(it.id))))
    end
  end
  add(raw(para({ BREAK, spacing(0, 0, 20) }, "")))
  add(raw(heading_xml(1, pandoc.Inlines({ pandoc.Str("Table of Authorities") }), true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman"))

  -- Section 3: the body (1, 2 ...) and the signature block
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(section("rIdFtrPage", "decimal"))

  -- Section 4: the certificate of compliance (Rule 33.1(h)), unnumbered; FORMBOOK_FINAL closes it
  add(raw(heading_xml(1, pandoc.Inlines({ pandoc.Str("Certificate of Compliance") }), true)))
  add(raw(para({ spacing(0, 180), ind(0) }, runs("I certify that this brief complies with the word limit of Supreme "
    .. "Court Rule 33.1(g), " .. group_digits(WORD_LIMIT) .. " words for a brief on the merits for a petitioner or "
    .. "appellant, and that it contains " .. group_digits(words) .. " words, excluding the parts that Rule 33.1(d) "
    .. "excludes."))))
  add(raw(signature(meta)))

  -- empty metadata: pandoc would otherwise print the date as a title block above the cover
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
