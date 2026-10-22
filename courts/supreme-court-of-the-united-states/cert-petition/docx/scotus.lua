-- SCOTUS cert petition, docx engine (docs/DOCX.md; typst: scotus-cert-petition-cert-petition.typ). pandoc writes the
-- body (paragraphs, quotations, footnotes) with docx/reference.docx (fb render builds it from docx/reference.xml: Schola 12 pt in 14 pt
-- lines, 10 pt notes in 12 pt lines); this filter writes what needs Word formatting:
--   * the cover (Rule 34.1(a)-(g)), the headings, the tables of contents and authorities (Rule 34.2), the signature
--     (Rule 34.3) and the certificate of compliance (Rule 33.1(h)), as paragraphs with explicit spacing and indents;
--     the counsel columns as borderless tables;
--   * the front pages: the "Questions Presented" and "Parties to the Proceeding" sections of the markdown, each on its
--     own page after the cover (Rule 14.1(a), (b)), then the tables; the rest is the body;
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of
--     every heading and citation in the LibreOffice PDF (the needles this filter writes) and renders again with
--     those pages (FORMBOOK_PAGES), until they settle. A citation is a `[text](toa:key)` link (typst: the link
--     show rule);
--   * the sections whose footers number the pages: cover (none), front pages and tables (i, ii ...), body and
--     signature (1, 2 ...), certificate (none). fb render writes the footers; this filter writes the last section
--     (FORMBOOK_FINAL).
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every line and page breaks where the typst render
-- breaks it. The model is lib/docx/xengine.lua (the break rules of typst on every run, exact line spacing: each line
-- a box of its pitch, the space between paragraphs the larger of the two); the pitches and spaces below are the
-- typst template's, in twips (20 x pt).

local WORD_LIMIT = 9000   -- Rule 33.1(g)(i): petition for a writ of certiorari
local TOC_DEPTH = 2       -- heading levels in the table of contents (typst: toc-depth)
local TOA_GROUPS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes and Other Authorities" },
}
-- The text width, 4 1/8 in (Rule 33.1(c)), less what the right margin takes beyond 1 in (MARGIN_R). LibreOffice sets
-- Schola a little narrower than typst (0.088 % on the mean of 203 identical full lines of the amicus sample; its glyph
-- positions are rounded, unevenly) and starts each line 0.1 pt in, so a line typst overflows by a hair would fit
-- here. The margin is the measured one at which every line of this folder's sample breaks as in typst; a line of
-- other text within 0.1 pt of the measure may still break differently (docs/EVAL-LOOP.md).
local TEXT_W = 5939
local MARGIN_R = 1441
local PITCH = 280         -- typst pitch-body: 14 pt (12-point type, 2-point leading; Rule 33.1(b))
local NOTE = 240          -- typst pitch-note: 12 pt (10-point counsel)
local COVER = 260         -- typst pitch-cover: 13 pt (the 11-point cover, Rule 34.1(g))
local TOC_COL = 479       -- typst toc-page-col: 24 pt kept for the contents' page numbers, less the margin's extra
local TOA_COL = 800       -- typst toa-page-col: 40 pt (a longer page list widens its own row's column)
local STEP = 432          -- a heading level's indent in the contents, 0.3 in
local HEAD_HANG = 576     -- the hanging indent of level 2 and 3 headings, 0.4 in
local COUNSEL_COL = 2862  -- a counsel column: (4 1/8 in - 0.15 in) / 2 (typst: grid, column-gutter 0.15in)
local COUNSEL_GAP = 216
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
-- booklet page (Rule 33.1(a), (c)), the text field centred top to bottom (typst: margin-y 1 1/16 in).
local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="8820" w:h="13320"/><w:pgMar w:top="1530" w:right="' .. MARGIN_R .. '" w:bottom="1530" w:left="1440" '
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
-- Word count (typst count-words on the markdown source of the body sections)
-- ---------------------------------------------------------------------------

local function count_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then error("scotus.lua: cannot read the sample to count its words") end
  local src = h:read("a")
  h:close()
  src = src:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1)
  -- the body: every level-1 section but Questions Presented and Parties to the Proceeding (typst: section-kind)
  local lines, kind = {}, "body"
  for line in (src .. "\n"):gmatch("(.-)\r?\n") do
    local t = line:match("^# (.*)$")
    if t then
      t = t:lower():gsub("^%s+", "")
      if t:find("^questions presented") then kind = "qp"
      elseif t:find("^parties to the proceeding") then kind = "parties"
      else kind = "body" end
    end
    if kind == "body" then lines[#lines + 1] = line end
  end
  local s = "\n" .. table.concat(lines, "\n")
  s = s:gsub("\n%[%^[^%]]*%]:", "\n ")
  s = s:gsub("%[%^[^%]]*%]", "")
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[%-%*%+][ \t]+", "\n")
  s = s:gsub("\n[ \t]*%d+[%.%)][ \t]+", "\n")
  s = s:gsub("\\(.)", "%1")
  s = s:gsub("%*", "")
  s = s:gsub("([%s%(%[\"])_", "%1")
  s = s:gsub("_([%s%.,;:%)%]\"!%?])", "%1")
  local n = 0
  for w in s:gmatch("%S+") do
    if w:find("[%w]") then n = n + 1 end
  end
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
  if meta[k] == nil then error("scotus.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- A heading (typst: show heading), 12 pt: level 1 bold, centred, 14.4 pt above and 10.8 below; level 2 bold and
-- level 3 bold italic, their wrapped lines hanging 0.4 in, 12 / 8.4 and 10.8 / 7.2 pt. One that opens a page has no
-- space above (typst drops it there; Word keeps it after a page or section break).
local function heading_xml(level, content, top)
  if level == 1 then
    return para({ KEEP, spacing(top and 0 or 288, 216), ind(0), jc("center") }, inl(content, { b = true }))
  end
  local sp = level == 2 and spacing(top and 0 or 240, 168) or spacing(top and 0 or 216, 144)
  return para({ KEEP, sp, ind(HEAD_HANG, HEAD_HANG) }, inl(content, { b = true, i = level >= 3 }))
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- The counsel columns (typst: counsel-block): a borderless table of two 143.1 pt columns 0.15 in apart, 10-point lines
-- of 12 pt, a blank line kept as one; `before` above its first line. `float`: at the foot of the text block (the
-- cover; typst: v(1fr)); otherwise kept with what follows it.
local function counsel_table(cols, before, float)
  local function cell(lines)
    local ps = {}
    if #lines == 0 then lines = { "" } end
    for k, l in ipairs(lines) do
      local body = stringify(l) == "" and "" or inl(l, { sz = 20 })
      ps[#ps + 1] = para({ float and "" or KEEP, spacing(k == 1 and before or 0, 0, NOTE), ind(0) }, body)
    end
    return '<w:tc><w:tcPr><w:tcW w:w="' .. COUNSEL_COL .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. "</w:tc>"
  end
  local pos = float and ('<w:tblpPr w:leftFromText="0" w:rightFromText="0" w:vertAnchor="margin" '
    .. 'w:horzAnchor="margin" w:tblpYSpec="bottom"/>') or ""
  return '<w:tbl><w:tblPr>' .. pos .. '<w:tblW w:w="' .. (2 * COUNSEL_COL + COUNSEL_GAP) .. '" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. COUNSEL_COL .. '"/><w:gridCol w:w="' .. COUNSEL_GAP .. '"/><w:gridCol w:w="' .. COUNSEL_COL
    .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(cols[1] or {})
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. COUNSEL_GAP .. '" w:type="dxa"/></w:tcPr><w:p><w:pPr>' .. spacing(0, 0, NOTE)
    .. "</w:pPr></w:p></w:tc>" .. cell(cols[2] or {}) .. "</w:tr></w:tbl>"
end

-- The cover (typst: cover): centred 11-point lines of 13 pt, the title 13-point bold on 15 pt; the counsel at the foot.
local function cover(meta)
  local x = {}
  local function line(before, body, pitch)
    x[#x + 1] = para({ spacing(before, 0, pitch or COVER), ind(0), jc("center") }, body)
  end
  local caption = need_meta(meta, "caption")
  line(0, runs("No. ", { sz = 22 }) .. inl(need_meta(meta, "docket"), { sz = 22 }))
  line(352, runs("IN THE", { sz = 22 }))
  line(110, runs("Supreme Court of the United States", { sz = 22, b = true }))
  for i, l in ipairs(caption.petitioner or {}) do line(i == 1 and 308 or 0, inl(l, { sz = 22 })) end
  line(66, inl(need_meta(meta, "petitioner-designation"), { sz = 22 }))
  for i, l in ipairs(caption.respondents or {}) do line(i == 1 and 198 or 0, inl(l, { sz = 22 })) end
  line(66, inl(need_meta(meta, "respondent-designation"), { sz = 22 }))
  line(264, inl(need_meta(meta, "proceeding"), { sz = 22 }))
  line(264, inl(need_meta(meta, "title"), { sz = 26, b = true }), 300)
  x[#x + 1] = counsel_table(need_meta(meta, "counsel").columns or {}, 0, true)
  return raw(table.concat(x))
end

-- typst: signature-block. 13.2 pt above "Respectfully submitted,", the counsel 10.8 pt below it, then 10.8 pt to the
-- line naming the party and the date; never split.
local function signature(meta)
  local counsel = need_meta(meta, "counsel")
  return para({ KEEP, spacing(264, 0), ind(0) }, runs("Respectfully submitted,"))
    .. counsel_table(counsel.columns or {}, 216, false)
    .. para({ KEEP, spacing(216, 0), ind(0) }, inl(counsel["attorneys-for"] or ""))
    .. para({ LINES, spacing(0, 0), ind(0) }, inl(counsel.date or ""))
end

-- One row of a table (typst listing-row): `before` above it; the text from `left`, its wrapped lines at `left` +
-- `hang`, wraps before the page column `col`; a dot leader from 0.75 em after the text runs to the page.
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

local function sort_key(a)
  local s = a.sort and stringify(a.sort) or ((a.name and stringify(a.name) or "") .. " " .. stringify(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

-- The authorities cited in the body, by kind, each with its pages in document order (typst: toa-section).
local function toa_rows(authorities)
  local out = {}
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      local cited = false
      for _, o in ipairs(occurrences) do if o.key == key then cited = true end end
      if stringify(a.kind) == g[1] and cited then members[#members + 1] = { key = key, a = a, sort = sort_key(a) } end
    end
    table.sort(members, function(p, q)
      if p.sort ~= q.sort then return p.sort < q.sort end
      return p.key < q.key
    end)
    if #members > 0 then
      -- the kind's title: 12 pt (the first) or 16.8 pt above, 6 below, kept with its first entry
      out[#out + 1] = para({ KEEP, spacing(first and 240 or 336, 120), ind(0) }, runs(g[2], { b = true }))
      first = false
      for _, m in ipairs(members) do
        local list, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local lab = l and l.label or "00"
            if not seen[lab] then
              seen[lab] = true
              list[#list + 1] = lab
            end
          end
        end
        local where = table.concat(list, ", ")
        local body = ""
        if m.a.name then body = inl(m.a.name, { i = g[1] == "case" }) .. runs(", ") end
        body = body .. inl(m.a.cite)
        out[#out + 1] = row(144, 0, 432, math.max(TOA_COL, list_width(where)), body, where)
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
  for _, k in ipairs({ "docket", "caption", "petitioner-designation", "respondent-designation", "proceeding", "title",
    "counsel", "certificate-signer" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  local words = count_words()
  if words > WORD_LIMIT then
    error("scotus.lua: body is " .. words .. " words; Rule 33.1(g)(i) allows " .. WORD_LIMIT)
  end

  -- the sections: Questions Presented and Parties to the Proceeding (front pages), the rest the body (typst:
  -- section-kind); each block written with its needles (headings, citations) in document order
  local parts = { qp = {}, parties = {}, body = {} }
  local kind = "body"
  local items = {}
  local after_para = false -- typst indents a paragraph only after a paragraph (not after a heading or a quotation)
  local count = 0
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      local t = stringify(b.content):lower()
      if t:find("^questions presented") then kind = "qp"
      elseif t:find("^parties to the proceeding") then kind = "parties"
      else kind = "body" end
    end
    local out = parts[kind]
    if b.t == "Header" then
      if b.level > 3 then error("scotus.lua: headings deeper than level 3 are not supported") end
      local id = "H:" .. i
      local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
      need(id, "B", stringify(b.content), nxt)
      if b.level <= TOC_DEPTH then items[#items + 1] = { id = id, level = b.level, title = b.content, kind = kind } end
      out[#out + 1] = { id = id, xml = heading_xml(b.level, b.content, #out == 0) }
      after_para = false
    else
      if kind == "body" then scan_blocks({ b }, false) end
      b = pandoc.Pandoc({ b }):walk({
        Link = function(el) if el.target:match("^toa:") then return el.content end end,
      }).blocks[1]
      -- the break rules of typst on the text pandoc writes itself (body, footnotes, quotations)
      b = b:walk({ Inlines = xe.inlines }):walk(BIND)
      if b.t == "Para" then
        local style = (after_para and "Body Text" or "First Paragraph") .. (has_note(b) and " Note" or "")
        out[#out + 1] = { block = pandoc.Div({ b }, { ["custom-style"] = style }) }
      else
        for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = { block = x } end
      end
      after_para = b.t == "Para"
    end
    count = count + 1
  end
  if #parts.body == 0 then error("scotus.lua: the sample has no body section") end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("scotus.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end

  -- needles: the front pages' headings, the table of authorities, the body's headings and citations, in that order
  local front_ids, body_ids = {}, {}
  for _, it in ipairs(items) do
    if it.kind == "body" then body_ids[it.id] = true else front_ids[it.id] = true end
  end
  local nl, first_front, first_body = {}, nil, nil
  local function emit(n) nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  for _, n in ipairs(needles) do
    if front_ids[n.id] then emit(n); first_front = first_front or n.id end
  end
  local toa = { id = "S:toa", kind = "B", needle = "tableofauthorities", fallback = "tableofauthorities" }
  emit(toa)
  first_front = first_front or toa.id
  for _, n in ipairs(needles) do
    if not front_ids[n.id] then emit(n) end
    if body_ids[n.id] then first_body = first_body or n.id end
  end
  nl[#nl + 1] = "#section\t" .. first_front .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (first_body or "S:toa") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  -- the certificate of compliance (Rule 33.1(h)): the last section, on its own page, no number
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrNone"))

  local out = {}
  local function add(x) out[#out + 1] = x end
  local function add_part(list)
    for _, e in ipairs(list) do add(e.xml and raw(e.xml) or e.block) end
  end
  local function page_break() add(raw(para({ BREAK, spacing(0, 0, 20) }, ""))) end

  -- Section 1: the cover (no page number)
  add(cover(meta))
  add(section("rIdFtrNone"))

  -- Section 2: the front pages (i, ii ...): Questions Presented, Parties (each on its own page, Rule 14.1(a)), the
  -- table of contents (depth 2, rows 6 pt apart), the table of authorities
  if #parts.qp > 0 then add_part(parts.qp); page_break() end
  if #parts.parties > 0 then add_part(parts.parties); page_break() end
  add(raw(heading_xml(1, pandoc.Inlines({ pandoc.Str("Table of Contents") }), true)))
  for _, it in ipairs(items) do
    add(raw(row(120, (it.level - 1) * STEP, nil, TOC_COL, inl(it.title), label_of(it.id))))
  end
  page_break()
  add(raw(heading_xml(1, pandoc.Inlines({ pandoc.Str("Table of Authorities") }), true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman"))

  -- Section 3: the body (1, 2 ...) and the signature block (Rule 34.3)
  add_part(parts.body)
  add(raw(signature(meta)))
  add(section("rIdFtrPage", "decimal"))

  -- Section 4: the certificate of compliance, separate from the document; FORMBOOK_FINAL closes it
  local counsel = need_meta(meta, "counsel")
  add(raw(para({ KEEP, spacing(0, 240), ind(0), jc("center") }, runs("CERTIFICATE OF COMPLIANCE", { b = true }))))
  add(raw(para({ spacing(240, 0), ind(0) },
    runs("I certify that this petition complies with the word limitation of Supreme Court Rule 33.1(g)(i), "
      .. group_digits(WORD_LIMIT) .. " words, and contains ")
    .. runs(group_digits(words), { b = true })
    .. runs(" words, counted as Rule 33.1(d) directs: the question presented, the list of parties and corporate "
      .. "disclosure statement, the table of contents, the table of cited authorities, the counsel listing and any "
      .. "appendix are excluded."))))
  add(raw(para({ KEEP, spacing(336, 0), ind(0), jc("right") }, inl(need_meta(meta, "certificate-signer")))
    .. para({ KEEP, spacing(0, 0), ind(0), jc("right") }, runs("Counsel of Record", { b = true }))
    .. para({ LINES, spacing(0, 0), ind(0), jc("right") }, inl(counsel.date or ""))))

  -- empty metadata: pandoc would otherwise print the title above the cover
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
