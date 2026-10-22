-- Supreme Court of the United States: amicus curiae brief (booklet format), docx engine
-- (typst: scotus-amicus-brief-amicus-brief.typ). pandoc writes the body (paragraphs, quotations, footnotes) with
-- docx/reference.docx (docx/reference.xml: Schola 12 pt in 14 pt lines, 10 pt notes in 12 pt lines); this
-- filter writes what needs Word formatting:
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
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every line and page breaks where the typst render
-- breaks it. The model is lib/docx/xengine.lua (the break rules of typst on every run, exact line spacing: each line
-- a box of its pitch, the space between paragraphs the larger of the two); the pitches and spaces below are the
-- typst template's, in twips (20 x pt).

local WORD_LIMITS = { government = 9000, other = 8000 } -- Rule 33.1(g): amicus briefs on the merits
local PASSIM = 6          -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local TOC_DEPTH = 3       -- heading levels in the table of contents (typst: toc-row for levels 1 to 3)
-- The text width, 4 1/8 in (Rule 33.1(c)), less what the right margin takes beyond 1 in (MARGIN_R). LibreOffice sets
-- Schola a little narrower than typst (0.088 % on the mean of 203 identical full lines of the amicus sample; its glyph
-- positions are rounded, unevenly: a no-break-hyphen run of 13 characters comes out 0.11 pt short) and starts each
-- line 0.1 pt in, so a line typst overflows by a hair would fit here. The margin is the measured one at which every
-- line of this folder's sample breaks as in typst (amicus-brief 1443 twips, merits-brief 1441: one twip either side
-- moves a line); a line of other text within 0.1 pt of the measure may still break differently (docs/EVAL-LOOP.md).
local TEXT_W = 5937
local MARGIN_R = 1443
local PITCH = 280         -- typst pitch-body: 14 pt (12-point type, 2-point leading; Rule 33.1(b))
local TOC_COL = 477       -- typst toc-page-col: 24 pt kept for the contents' page numbers, less the margin's extra
local TOA_COL = 800       -- typst toa-page-col: 40 pt (a longer page list widens its own row's column)
local LABEL = 576         -- the label box of point headings, 0.4 in (typst: label-tab)
local QUOTE_L = 576       -- reference.docx Block Text indent (typst: para-indent)
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

-- A centred bold title (the tables, the certificate): 12 pt below; `brk` opens a new page.
local function title(text, brk)
  return para({ KEEP, brk and BREAK or "", spacing(0, 240), ind(0), jc("center") }, runs(text:upper(), { b = true }))
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

-- Inlines in capitals (typst: upper).
local function upper_il(il)
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(e.text:upper()) end }).content
end

-- A body heading (typst style-heading): level 1 bold capitals centred, 16.8 pt above, 12 below; a point's label
-- sits in a 0.4 in box, its text hangs after it, 12 pt above, 10.8 below. One that opens a page has no space above
-- (typst drops it there; Word keeps it after a page or section break).
local function heading_xml(h, lab, top)
  if h.level == 1 then
    return para({ KEEP, spacing(top and 0 or 336, 240), ind(0), jc("center") }, inl(upper_il(h.content), { b = true }))
  end
  local left = (h.level - 2) * LABEL
  return para({ KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. (left + LABEL) .. '"/></w:tabs>',
    spacing(top and 0 or 240, 216), ind(left + LABEL, LABEL) }, runs(lab .. "\t", { b = true }) .. inl(h.content, { b = true }))
end

-- Bullet list items: "•", a tab, the text, hanging at the tab (inside a quotation: in its indents).
local function bullets(list, quoted)
  local left = (quoted and QUOTE_L or 0) + 720
  local out = {}
  for _, item in ipairs(list.content) do
    for k, b in ipairs(item) do
      if b.t ~= "Plain" and b.t ~= "Para" then error("brief.lua: a list item holds only text") end
      local lead = k == 1 and runs("\u{2022}\t") or runs("\t")
      out[#out + 1] = raw(para({ xe.style(quoted and "BlockText" or "BodyText"),
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

-- The cover (typst: cover): one centred line or paragraph per part, the counsel at the foot of the page (a frame at
-- the bottom of the text block: typst's v(1fr)).
local function cover(meta)
  local x = {}
  local FOOT = '<w:framePr w:wrap="notBeside" w:vAnchor="margin" w:hAnchor="margin" w:xAlign="center" w:yAlign="bottom" w:w="'
    .. TEXT_W .. '"/>'
  local function add(before, body, o)
    o = o or {}
    x[#x + 1] = para({ o.frame and FOOT or "", spacing(before), ind(0), jc(o.left and "left" or "center") }, body)
  end
  -- (a) the docket number, (b) the Court, (c) the caption, (d) the proceeding, (e) the title (Rule 34.1)
  add(0, runs("No. ") .. inl(need_meta(meta, "case_number")), { left = true })
  add(400, runs("In the"))
  add(0, runs("SUPREME COURT OF THE UNITED STATES", { b = true }))
  for i, side in ipairs(need_meta(meta, "caption")) do
    if i > 1 then add(120, runs("v.")) end
    for j, n in ipairs(side.names) do add(j > 1 and 0 or (i == 1 and 280 or 120), inl(n)) end
    add(0, inl(side.designation))
  end
  add(280, inl(need_meta(meta, "proceeding")))
  add(280, inl(upper_il(unlist(need_meta(meta, "brief_title"))), { b = true }))
  -- (f) counsel: the counsel of record is identified with the notation directly under the name
  for gi, g in ipairs(need_meta(meta, "counsel")) do
    for j, n in ipairs(g.names) do add((gi > 1 and j == 1) and 240 or 0, inl(n), { frame = true }) end
    if g.role then add(0, inl(g.role, { i = true }), { frame = true }) end
    for _, l in ipairs(g.lines or {}) do add(0, inl(l), { frame = true }) end
    if gi == 1 then add(0, inl(need_meta(meta, "phone")), { frame = true }) end
  end
  add(240, inl(need_meta(meta, "counsel_role"), { i = true }), { frame = true })
  add(240, inl(need_meta(meta, "date")), { frame = true })
  return raw(table.concat(x))
end

-- The signer's name in bold capitals, the lines, and the date 8 pt below them (typst: signer-lines); never split.
local function signer_lines(meta, before)
  local sig = need_meta(meta, "signature")
  local out = { para({ KEEP, spacing(before, 0), ind(0) }, inl(upper_il(unlist(need_meta(sig, "signer"))), { b = true })) }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = para({ KEEP, spacing(0, 0), ind(0) }, inl(l)) end
  -- the last line keeps no next: the block moves to the next page whole, never split
  out[#out + 1] = para({ LINES, spacing(160, 0), ind(0) }, inl(need_meta(meta, "date")))
  return table.concat(out)
end

-- typst: signature-block, 14 pt above, "Respectfully submitted," 20 pt above the signer.
local function signature(meta)
  return para({ KEEP, spacing(280, 0), ind(0) }, runs("Respectfully submitted,")) .. signer_lines(meta, 400)
end

local function certificate(meta, words, limit)
  local kind = stringify(need_meta(meta, "amicus_class")) == "government"
    and "an amicus curiae identified in Rule 37.6" or "any other amicus curiae"
  return title("Certificate of Compliance", false)
    .. para({ spacing(240, 240), ind(0) }, runs("Pursuant to Rule 33.1(h), I certify that the attached brief complies "
      .. "with the word limitation of Rule 33.1(g). It contains " .. group_digits(words) .. " words, excluding the "
      .. "items listed in Rule 33.1(d). The limit for " .. kind .. " is " .. group_digits(limit) .. " words."))
    .. signer_lines(meta, 240)
end

-- One row of a table (typst listing-row): `before` above it; the text, hanging at `hang` from `left`, wraps before
-- the page column `col`; a dot leader from three spaces after the text runs to the page at the margin.
local function row(before, left, hang, col, body, page)
  return para({ LINES, xe.leader_tab(TEXT_W), spacing(before, 0), ind(left + (hang or 0), hang, col) },
    body .. LEAD_XML .. runs(page))
end

-- The width of a page list in twips (Schola advances at 12 pt): the authorities' page column is as wide as a longer
-- list (typst: calc.max(toa-page-col, measure(where).width)).
local ADV = { [","] = 278, [" "] = 278, p = 574, a = 556, s = 463, i = 315, m = 889 }
local function list_width(s)
  local u = 0
  for c in s:gmatch(".") do u = u + (ADV[c] or 556) end
  return math.ceil(u * 240 / 1000)
end

local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "regulation", "Regulations" },
  { "other", "Other Authorities" } }

local function sort_key(a)
  return (stringify(a.name):gsub("[%*“”\"]", ""))
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
      -- the kind's title: 13.2 pt above, 8.4 below, kept with its first entry
      out[#out + 1] = para({ KEEP, spacing(264, 168), ind(0) }, runs(g[2], { b = true }))
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
        out[#out + 1] = row(144, 0, LABEL, math.max(TOA_COL, list_width(where)), body, where)
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

  -- the body: headings (labels, needles, contents entries) and citations (needles); the paragraph after a heading
  -- is not indented (typst indents a paragraph only after a paragraph)
  local items = {}
  local counts = { 0, 0, 0, 0, 0 }
  local body = {}
  local after_heading = false
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
        items[#items + 1] = { id = id, level = b.level, label = lab, content = b.content }
      end
      scan_blocks({ pandoc.Para(b.content) }, false)
      body[#body + 1] = raw(heading_xml(b, lab, #body == 0))
      after_heading = true
    else
      scan_blocks({ b }, false)
      -- the break rules of typst on the text pandoc writes itself (body, quotations, footnotes)
      b = b:walk({ Inlines = xe.inlines })
      b = b:walk(BIND)
      if b.t == "Para" then
        body[#body + 1] = pandoc.Div({ b }, { ["custom-style"] = after_heading and "First Paragraph" or "Body Text" })
      else
        body[#body + 1] = b
      end
      after_heading = false
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

  -- Section 2: the tables (i, ii ...); the table of authorities starts its own page. Contents rows 6 pt apart.
  add(raw(title("Table of Contents", false)))
  for _, it in ipairs(items) do
    if it.level == 1 then
      add(raw(row(120, 0, nil, TOC_COL, inl(upper_il(it.content)), label_of(it.id))))
    else
      local left = (it.level - 2) * LABEL
      add(raw(row(120, left, LABEL, TOC_COL, runs(it.label .. "\t") .. inl(it.content), label_of(it.id))))
    end
  end
  add(raw(title("Table of Authorities", true)))
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
