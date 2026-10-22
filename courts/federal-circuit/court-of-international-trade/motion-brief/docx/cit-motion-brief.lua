-- cit-motion-brief.lua: pandoc filter for the CIT motion for judgment on the agency record, docx engine
-- (see ../README.md, "Engines"). Mirrors typst/cit-motion-brief.typ on the shared cross-engine layout model
-- (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph has exact line spacing at the typst
-- pitch (24 pt body, 14 pt single lines), the typst spaces and indents in twips, and its text through the shared
-- break rules. The motion cover with the motion's paragraphs and signature, the memorandum cover with the counsel
-- block, the table of contents and the table of authorities (Rule 56.2(c)(2)), the memorandum body, the signature
-- block and the Chambers word-count certificate. pandoc writes the body's paragraphs, quotations and footnotes in
-- the styles of reference.docx (make-reference.sh); this filter writes the rest as raw WordprocessingML.
--
-- Page numbers of the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of every
-- heading and citation in the LibreOffice PDF (the needles this filter writes to FORMBOOK_NEEDLES) and renders again
-- with those pages (FORMBOOK_PAGES), until they settle. One section: every page numbered from 1 (Rule 81(d)).

local xe = require("docx.xengine")
local runs, inl, para, raw, ind, jc = xe.runs, xe.inl, xe.para, xe.raw, xe.ind, xe.jc
local KEEP, LINES, BREAK, BR, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.BR, xe.LEAD
local stringify = pandoc.utils.stringify

-- the typst parameters, in twips (20 x pt)
local BODY, SINGLE = 480, 280          -- pitch, pitch-single
local INDENT = 720                     -- para-indent
local GAP = 240                        -- gap
local SECTION = { 480, 240 }           -- space-section (above, below)
local SUB = { 240, 240 }               -- space-sub
local TEXT_W = 9360                    -- the text width, 6.5 in
local CAP_LEFT, CAP_PAREN, CAP_RIGHT = 4896, 432, 4032   -- caption-left, caption-paren, the rest
local DESIG_INDENT = 1728              -- caption-desig
local COURT_INDENT = 288               -- caption-right
local COUNSEL_LEFT = 4752              -- counsel-left
local SIG_LEFT, SIG_RIGHT = 4032, 5328 -- sig-left, the rest
local PNUM_TOC = 720                   -- toc-page-col
local TOC_INDENT = 720                 -- toc-indent
local TOC_ABOVE = { 140, 98 }          -- toc-above
local PNUM_TOA = 1120                  -- toa-page-col
local TOA_HANG = 504                   -- toa-hang
local TOA_ABOVE = 196                  -- toa-above
local TOA_GROUP = { 280, 392, 56 }     -- toa-group: first, next, below
local FOOTER = 730                     -- the page number's line where typst sets it (footer-descent 30 %)
local DIGIT, PUNCT = 120, 60           -- Times New Roman 12 pt: a digit 0.5 em, a comma or space 0.25 em
local WORD_LIMIT = 14000               -- Chambers Procedures 2(B)(1)(a)
local PASSIM = 7                       -- passim-threshold
local TOC_DEPTH = 3
local NEEDLE_MAX = 60

local function fail(msg) error("cit-motion-brief: " .. msg, 0) end

local function need_meta(meta, k)
  if meta[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- ---------------------------------------------------------------------------
-- Break rules on pandoc's own inlines: the shared ones, and a doubled section sign bound to its number ("§§ 1500"),
-- as the typst template boxes it (the shared bind_signs binds a single sign only).
-- ---------------------------------------------------------------------------

local function bind_double(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function text(x, o)
  if x == nil then return "" end
  if type(x) ~= "string" and x.t ~= nil and x.t ~= "MetaInlines" and x.t ~= "Inlines" then x = pandoc.Inlines(stringify(x)) end
  if type(x) ~= "string" then x = bind_double(x) end
  return inl(x, o)
end

-- ---------------------------------------------------------------------------
-- Paragraphs
-- ---------------------------------------------------------------------------

-- A single-spaced line; `extra`: more properties after the spacing (indent, justification).
local function line(body, extra, before, props)
  return para({ props or "", xe.spacing(before or 0, 0, SINGLE), extra or "" }, body)
end

-- An empty line of the body pitch (typst v(pitch)).
local function spacer(keep)
  return para({ keep and KEEP or "", xe.spacing(0, 0, BODY) }, "")
end

local function cell(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. paras .. '</w:tc>'
end

-- A table with no borders, no cell margins and fixed column widths.
local function xtable(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>'
end

-- Caption (Rule 10(a)): each side's names, a designation, a ")" on every row, the joining word ("v.", "and")
-- centered between the sides, and the court number at the right of the first row.
local function caption(meta)
  local sides = need_meta(meta, "caption")
  local lines = {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do lines[#lines + 1] = { x = n } end
    lines[#lines + 1] = { x = side.designation, extra = ind(DESIG_INDENT) }
    if i < #sides then lines[#lines + 1] = { x = side.between or "v.", extra = jc("center") } end
  end
  local rows = {}
  for k, l in ipairs(lines) do
    local right
    if k == 1 then
      local court = line(runs("Ct. No. " .. stringify(need_meta(meta, "court_no"))), ind(COURT_INDENT))
      if meta.before then court = court .. line(runs("Before: " .. stringify(meta.before)), ind(COURT_INDENT)) end
      right = cell(CAP_RIGHT, court, '<w:vMerge w:val="restart"/>')
    else
      right = cell(CAP_RIGHT, line(""), '<w:vMerge/>')
    end
    rows[#rows + 1] = '<w:tr>' .. cell(CAP_LEFT, line(text(l.x), l.extra)) ..
      cell(CAP_PAREN, line(runs(")"))) .. right .. '</w:tr>'
  end
  return xtable({ CAP_LEFT, CAP_PAREN, CAP_RIGHT }, rows)
end

-- Court name, caption, party and title: the cover of the motion and of the memorandum; `brk`: it opens a page.
local function cover_page(meta, title, brk)
  local out = {}
  for i, l in ipairs(need_meta(meta, "court")) do
    out[#out + 1] = line(runs(stringify(l):upper(), { b = true }), jc("center"), 0, (brk and i == 1) and BREAK or "")
  end
  out[#out + 1] = spacer()
  out[#out + 1] = caption(meta)
  out[#out + 1] = spacer()
  out[#out + 1] = line(runs(stringify(need_meta(meta, "party")):upper(), { b = true }), jc("center"))
  out[#out + 1] = line(runs(stringify(title):upper(), { b = true }), jc("center"), GAP)
  return table.concat(out)
end

-- Signature block (Rule 11(a)): "Dated" at left, the signer and counsel lines at right; one row, never split.
local function signature(meta, keep)
  local sig = need_meta(meta, "signature")
  local right = { line(runs("Respectfully submitted,")), line(runs("/s/ " .. stringify(sig.signer)), nil, GAP) }
  for _, l in ipairs(sig.lines) do right[#right + 1] = line(text(l)) end
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(SIG_LEFT, line(runs("Dated: " .. stringify(need_meta(meta, "date"))))) ..
    cell(SIG_RIGHT, table.concat(right)) .. '</w:tr>'
  return spacer(keep) .. xtable({ SIG_LEFT, SIG_RIGHT }, { row })
end

-- Counsel block on the memorandum cover, then the date, centered.
local function counsel(meta)
  local out = { spacer() }
  for _, l in ipairs(need_meta(meta, "counsel")) do out[#out + 1] = line(text(l), ind(COUNSEL_LEFT)) end
  out[#out + 1] = spacer()
  out[#out + 1] = line(runs("Dated: " .. stringify(need_meta(meta, "date"))), jc("center"))
  return table.concat(out)
end

-- Headings (typst style-heading): level 1 centered bold capitals, lower levels bold with wrapped lines hanging half
-- an inch; single spaced. `top`: it opens a page (Word keeps the space above after a page break; typst drops it).
local function heading(level, content, top, outlined)
  local sty = outlined == false and "" or xe.style("Heading" .. math.min(level, 5))
  if level == 1 then
    return para({ sty, KEEP, top and BREAK or "", xe.spacing(top and 0 or SECTION[1], SECTION[2], SINGLE),
      ind(0, nil, 0), jc("center") }, runs(stringify(content):upper(), { b = true }))
  end
  return para({ sty, KEEP, xe.spacing(SUB[1], SUB[2], SINGLE), ind(INDENT, INDENT) }, text(content, { b = true }))
end

-- A body paragraph at the body pitch with a first-line indent (the motion's last one is kept with the signature).
local function body_para(content, props)
  return para({ props or "", xe.spacing(0, 0, BODY), ind(0, nil, INDENT) }, text(content))
end

-- ---------------------------------------------------------------------------
-- Words (Chambers 2(B)(1)(c)), counted on the markdown body exactly as the typst template counts them
-- (count-words): headings, footnotes and quotations count; markup, list markers and footnote labels do not.
-- ---------------------------------------------------------------------------

local function count_words()
  local path = PANDOC_STATE.input_files[1]
  local f = path and io.open(path, "r")
  if not f then fail("cannot read the input file to count its words") end
  local src = f:read("a")
  f:close()
  local body = src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n(.*)$")
  if not body then fail("the sample must start with a YAML frontmatter block") end
  body = body:gsub("<!%-%-.-%-%->", " ")
  local n = 0
  for l in (body .. "\n"):gmatch("([^\n]*)\n") do
    l = l:gsub("^%[%^[^%]]+%]:", " ")                -- footnote definition labels
    l = l:gsub("%[%^[^%]]+%]", "")                   -- footnote references
    l = l:gsub("%[([^%]]*)%]%([^)]*%)", "%1")        -- links keep their text
    l = l:gsub("^#+[ \t]+", "")                      -- heading marks (typst: #{1,6})
    l = l:gsub("^>[ \t]?", "")                       -- quotation marks
    l = l:gsub("^[ \t]*[-*+][ \t]+", "", 1)          -- list markers are not words
    l = l:gsub("^[ \t]*%d+[.)][ \t]+", "", 1)
    l = l:gsub("\\(.)", "%1")
    l = l:gsub("%*", "")
    for _ in l:gmatch("%S+") do n = n + 1 end
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local k
  repeat s, k = s:gsub("^(%d+)(%d%d%d)", "%1,%2") until k == 0
  return s
end

-- ---------------------------------------------------------------------------
-- Needles and pages (format: tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s) return (s:lower():gsub("[^a-z0-9]", "")) end

local needles = {}
local function opening(s)
  local out = ""
  for w in s:gmatch("%S+") do
    out = out .. norm(w)
    if #out >= 8 then break end
  end
  return out:sub(1, NEEDLE_MAX)
end

local function need(id, kind, s, context)
  local short = opening(s)
  local long = norm(s .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, page, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = label } end
  end
  f:close()
end

local function label_of(id)
  local l = labels[id]
  return l and l.label or "00" -- the first pass: a placeholder of the final width
end

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Table of contents and table of authorities (typst listing-row: the text wraps before the page column, a dot
-- leader from three spaces after it to the page)
-- ---------------------------------------------------------------------------

local function toc_row(h)
  local left = TOC_INDENT * (h.level - 1)
  return para({ LINES, xe.leader_tab(TEXT_W), xe.spacing(h.level == 1 and TOC_ABOVE[1] or TOC_ABOVE[2], 0, SINGLE),
    ind(left, nil, nil, PNUM_TOC) }, text(h.content) .. runs(LEAD .. label_of(h.id)))
end

local GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local occurrences = {} -- the authority links, in document order: { key, index }

local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
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
      if #out == 0 then head = head .. runs("\t") .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TEXT_W .. '"/></w:tabs>',
        xe.spacing(#out == 0 and TOA_GROUP[1] or TOA_GROUP[2], TOA_GROUP[3], SINGLE) }, head)
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
        table.sort(pages, function(x, y) return x.page < y.page end)
        local list, list_w = nil, 0
        if #pages >= PASSIM then
          list = runs("passim", { i = true })
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          local s = table.concat(l, ", ")
          list = runs(s)
          -- a list wider than the column widens the column (typst: the larger of the column and the list)
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and DIGIT or PUNCT) end
        end
        local name = ""
        if m.a.name then name = text(m.a.name, { i = g[1] == "case" }) .. runs(",") .. BR end
        out[#out + 1] = para({ LINES, xe.leader_tab(TEXT_W), xe.spacing(TOA_ABOVE, 0, SINGLE),
          ind(TOA_HANG, TOA_HANG, nil, math.max(PNUM_TOA, list_w)) }, name .. text(m.a.cite) .. runs(LEAD) .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Citations, in document order (the needles of the table of authorities)
-- ---------------------------------------------------------------------------

local scan_blocks

local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      occurrences[#occurrences + 1] = { key = el.target:sub(5), index = #occurrences + 1 }
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      need("T:" .. #occurrences, in_note and "N" or "B", stringify(el.content), stringify(rest))
    elseif el.t == "Note" then
      scan_blocks(el.content, true)
    elseif el.content and type(el.content) ~= "string" then
      scan_inlines(el.content, in_note)
    end
  end
end

scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" or b.t == "Header" then
      scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" then
      scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

-- The body as pandoc writes it: toa links as their text, the break rules on every run, lists as List Item paragraphs.
local function prepare(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
  end
  return pandoc.Pandoc(out):walk({
    Link = function(el) return el.content end,
    Inlines = function(l) return xe.inlines(bind_double(l)) end,
  }).blocks
end

local function next_text(blocks, i)
  local b = blocks[i + 1]
  if not b then return "" end
  return stringify(b):sub(1, 40)
end

local function sect_pr(footer, fmt, start)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start
    .. '"/></w:sectPr>'
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  local authorities = meta.authorities or {}

  -- Words first: the limit is a hard error, as in the typst engine.
  local words = count_words()
  if words > WORD_LIMIT then
    fail("the body has " .. words .. " words; Chambers Procedures 2(B)(1)(a) limit is " .. WORD_LIMIT)
  end

  -- the cover opens page 1; every page is numbered from it
  local first = need_meta(meta, "caption")[1].names[1]
  need("C:1", "B", stringify(need_meta(meta, "court")[1]), stringify(first))
  -- the table of authorities, so that no heading or citation is looked for in the tables
  need("S:toa", "B", "Table of Authorities", "")

  local out = {}
  local function add(x) out[#out + 1] = type(x) == "string" and raw(x) or x end

  -- ---- motion cover, the motion, signature ----
  add(cover_page(meta, need_meta(meta, "brief_title"), false))
  local motion = need_meta(meta, "motion")
  local mblocks = motion.t == "MetaInlines" and { pandoc.Para(motion) } or motion
  -- the space above the motion (typst: block(above: pitch)) is the first paragraph's
  for i, b in ipairs(mblocks) do
    local above = i == 1 and BODY or 0
    if b.t == "Para" or b.t == "Plain" then
      local props = i == #mblocks and (KEEP) or ""
      add(para({ props, xe.spacing(above, 0, BODY), ind(0, nil, INDENT) }, text(b.content)))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(prepare({ b })) do add(x) end
    else
      fail("the motion holds paragraphs and lists only, not " .. b.t)
    end
  end
  add(signature(meta, true))

  -- ---- memorandum cover, counsel block, date ----
  add(cover_page(meta, need_meta(meta, "memo_title"), true))
  add(counsel(meta))

  -- ---- the body: headings (needles, contents rows) and citations (needles) ----
  local headings, body = {}, {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local id = "H:" .. i
      need(id, "B", stringify(b.content), next_text(doc.blocks, i))
      if b.level <= TOC_DEPTH then headings[#headings + 1] = { id = id, level = b.level, content = b.content } end
      body[#body + 1] = raw(heading(b.level, b.content, #body == 0))
    else
      scan_blocks({ b }, false)
      for _, x in ipairs(prepare({ b })) do body[#body + 1] = x end
    end
  end
  if body[1] and body[1].t ~= "RawBlock" then fail("the body must start with a heading") end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then fail("link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter") end
  end
  need("S:cert", "B", "Certificate of Compliance", "This brief has been prepared")

  -- ---- contents and authorities ----
  add(heading(1, "Table of Contents", true, false))
  for _, h in ipairs(headings) do add(toc_row(h)) end
  add(heading(1, "Table of Authorities", true, false))
  add(toa_rows(authorities))

  for _, x in ipairs(body) do add(x) end
  add(signature(meta))

  -- ---- Chambers 2(B)(2) certificate of compliance ----
  add(line(runs("CERTIFICATE OF COMPLIANCE", { b = true }), jc("center"), 0, BREAK))
  add(para({ xe.spacing(BODY, 0, BODY), ind(0, nil, INDENT) }, runs(
    "This brief has been prepared using a proportionally spaced typeface (Times New Roman, 12-point). " ..
    "In accordance with the Standard Chambers Procedures of this Court, the undersigned certifies that " ..
    "this brief contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by " ..
    "Chambers Procedures 2(B)(1)(c). The count includes headings, footnotes and quotations.")))
  add(signature(meta))

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tC:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  doc.blocks = out
  doc.meta.date = nil
  doc.meta.title = nil
  return doc
end
