-- tex-petition-for-review.lua (docx engine): a Supreme Court of Texas petition for review as Word paragraphs, so that
-- it reads and breaks as ../typst/tex-petition-for-review.typ (the reference for the form) does:
--   * the cover (TRAP 9.4(g)): case number, court, caption, the court below, the title between rules, written here;
--     the lead counsel in a frame at the foot of the page (typst sets them after a fill);
--   * the front matter (lower roman, the cover counted as i): the sections before `body_start` (the identities
--     single-spaced), the table of contents (every heading to the third level, page numbers from the layout) and the
--     index of authorities (from the frontmatter `authorities`, the pages as typed there);
--   * the body (arabic from 1): headings written here; paragraphs, lists, quotations and footnotes left to pandoc in
--     the styles of docx/reference.xml; the signature block after the prayer, kept with its last paragraph; a short
--     signature under each certificate; the appendix on a new page; the word count (TRAP 9.4(i)) in place of
--     {{word-count}}.
-- Every case word comes from the YAML frontmatter or the body. No coordinates, no forced line breaks.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- The contents' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of every
-- heading in that PDF (the needles this filter writes to FORMBOOK_NEEDLES) and renders again with those pages
-- (FORMBOOK_PAGES) until they settle (were docx/render.sh's two passes). Three sections: the cover (no number), the
-- front matter (lower roman from ii) and the body (arabic from 1; FORMBOOK_FINAL), the page number in the footer
-- FORMBOOK_FOOTERS lists.

local xe = require("docx.xengine")

-- Rule 9.4(i)(2)(D): a petition for review, 6,500 words (2026; former text 4,500), the introduction included and
-- capped at 1,000 words (Rule 53.2(a), 2026).
local WORD_LIMITS = { ["2026"] = 6500, ["2025"] = 4500 }
local INTRO_LIMIT = 1000
local DEFAULT_EDITION = "2026"

local SINGLE = 322              -- typst pitch-single, 16.1 pt
local HEAD_BEFORE = 258         -- typst heading-above, 12.9 pt
local HEAD_AFTER = 64           -- typst heading-below, 3.2 pt
local GAP = 160                 -- typst gap, 8 pt
local TEXTW = 9360              -- 6.5 in
local LEVEL = 720               -- typst level-indent, 0.5 in
local TOC_COL = 720             -- typst toc-col, 36 pt
local TOA_COL = 56              -- typst toa-col, 56 pt (whole points)
local TOA_HANG = 720            -- typst toa-hang, 0.5 in
local SIG = 4680                -- typst sig-indent, 3.25 in
local FOOTER = 686              -- the footer's foot, 34.3 pt above the page edge (reference.xml)
local NEEDLE_MAX = 60

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  if type(v) == "boolean" then return tostring(v) end
  return pandoc.utils.stringify(v)
end

local function list(v)
  local out = {}
  if type(v) ~= "table" then return out end
  for _, x in ipairs(v) do out[#out + 1] = x end
  return out
end

local function fail(msg) error("tex: " .. msg, 0) end

-- A paragraph: o = { style, before, after, line, left, right, first, hanging, tabs, jc, keep, lines, brk, frame,
-- border }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.frame then props[#props + 1] = o.frame end
  if o.border then props[#props + 1] = o.border end
  if o.tabs then props[#props + 1] = o.tabs end
  if o.before or o.after or o.line then
    props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  end
  if o.left or o.right or o.first or o.hanging then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  end
  if o.jc then props[#props + 1] = xe.jc(o.jc) end
  return xe.raw(xe.para(props, body))
end

-- ---------------------------------------------------------------------------
-- Word count (TRAP 9.4(i)(1), 2026 text; the typst template's word-count, on the markdown source)
-- ---------------------------------------------------------------------------

local EXCLUDED = {
  "^identit", "^table of contents", "^index of authorities", "^statement regarding oral argument",
  "^statement of the case", "^statement of jurisdiction", "^statement of procedural history",
  "^issues? presented", "^certificat", "^appendix",
}

local function count_words(s)
  local n = 0
  for tok in s:gmatch("%S+") do
    if tok:find("%w") then n = n + 1 end
  end
  return n
end

-- The markdown source's H1 sections: { title, text } (the text from the "# " line on).
local function source_sections()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then fail("no input file to count words in") end
  local h = assert(io.open(f, "rb"))
  local text = h:read("a")
  h:close()
  local fm = text:match("^%-%-%-\r?\n.-\n%-%-%-[ \t]*\r?\n")
  if fm then text = text:sub(#fm + 1) end
  local secs, cur = {}, nil
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if line:sub(1, 2) == "# " then
      cur = { title = line:sub(3):match("^%s*(.-)%s*$"), text = { line } }
      secs[#secs + 1] = cur
    elseif cur then
      cur.text[#cur.text + 1] = line
    end
  end
  for _, s in ipairs(secs) do s.text = table.concat(s.text, "\n") end
  return secs
end

local function word_count(secs)
  local total = 0
  for _, s in ipairs(secs) do
    local t = s.title:lower()
    local excluded = false
    for _, pat in ipairs(EXCLUDED) do
      if t:find(pat) then excluded = true break end
    end
    if not excluded then
      local body = s.text
      local cut = body:find("Respectfully submitted", 1, true)
      if cut then body = body:sub(1, cut - 1) end
      total = total + count_words(body)
    end
  end
  return total
end

local function commas(n)
  local s = tostring(n)
  local k
  repeat s, k = s:gsub("^(%d+)(%d%d%d)", "%1,%2") until k == 0
  return s
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function letters(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context)
  local long = letters(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = letters(text):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, "B", long, short }, "\t")
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Sections and footers
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt, start)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' .. pg .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(footer, fmt, start)
  return xe.raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. '</w:pPr></w:p>')
end

-- The page number, centered in a single line (typst: the footer in a 16.1 pt line box).
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r>'
  .. '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'

-- ---------------------------------------------------------------------------
-- Break rules typst and LibreOffice do not share
-- ---------------------------------------------------------------------------

-- None inside ")(" (a word joiner), one after a slash before a letter ("Respondent/Appellee": a zero-width space).
-- Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/(%a)", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ I."; typst boxes "[§¶]{2} \S+"; xe.inlines binds a single one).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function div(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- ---------------------------------------------------------------------------
-- The cover (TRAP 9.4(g))
-- ---------------------------------------------------------------------------

local FRAME = '<w:framePr w:w="' .. TEXTW .. '" w:hSpace="0" w:wrap="around" w:vAnchor="margin" w:hAnchor="margin"'
  .. ' w:yAlign="bottom"/>'

local function cover(meta, out)
  local function c(before, body)
    out[#out + 1] = p(body, { before = before, line = SINGLE, first = 0, jc = "center" })
  end
  c(0, xe.runs("No. " .. plain(meta.case_number)))
  c(648, xe.runs("IN THE SUPREME COURT OF TEXAS", { b = true }))
  for i, side in ipairs(list(meta.caption)) do
    if i > 1 then c(288, xe.runs("v.")) end
    c(i == 1 and 504 or 288, xe.inl(side))
  end
  c(504, xe.inl(meta.on_review))
  -- the title between rules 14 pt clear of it (typst: a block with a 0.75 pt top and bottom stroke, 14 pt inset)
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { before = 504, line = SINGLE, first = 0, jc = "center",
    border = '<w:pBdr><w:top w:val="single" w:sz="6" w:space="14" w:color="000000"/>'
      .. '<w:bottom w:val="single" w:sz="6" w:space="14" w:color="000000"/></w:pBdr>' })
  -- the lead counsel and the filing party at the foot of the page
  local lead = meta.lead_counsel or {}
  local function f(before, body, center)
    out[#out + 1] = p(body, { frame = FRAME, before = before, line = SINGLE, first = 0, jc = center and "center" or "left" })
  end
  f(0, xe.inl(lead.name))
  for _, l in ipairs(list(lead.address)) do f(0, xe.inl(l)) end
  f(0, xe.inl(lead.phone))
  f(0, xe.inl(lead.email))
  f(0, xe.runs("Texas Bar No. " .. plain(lead.bar_number)))
  f(432, xe.inl(meta.filing_party))
  if meta.oral_argument_requested == true then
    f(576, xe.runs("ORAL ARGUMENT REQUESTED", { b = true }), true)
  end
end

-- ---------------------------------------------------------------------------
-- Signatures (TRAP 9.1, 9.5(e))
-- ---------------------------------------------------------------------------

local function signature(sig, out)
  local lines = { { xe.runs("Respectfully submitted,"), SINGLE } }
  for i, l in ipairs(list(sig.office)) do lines[#lines + 1] = { xe.inl(l), i == 1 and SINGLE or 0 } end
  lines[#lines + 1] = { xe.runs("By: /s/ " .. plain(sig.name)), SINGLE }
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { xe.inl(l), 0 } end
  if plain(sig["for"]) ~= "" then lines[#lines + 1] = { xe.inl(sig["for"], { i = true }), SINGLE } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = SIG, first = 0, keep = i < #lines, lines = true })
  end
end

local function certificate_signature(sig, out)
  out[#out + 1] = p(xe.runs("/s/ " .. plain(sig.name)), { before = SINGLE, left = SIG, first = 0, keep = true })
  out[#out + 1] = p(xe.inl(sig.name), { left = SIG, first = 0, lines = true })
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- The page column of an index row (typst page-col): 56 pt, or the page list's width at 14 pt in whole points and
-- 7 pt clear of the leader; Times New Roman advances in 1/1000 em.
local ADV = {
  ["0"] = 500, ["1"] = 500, ["2"] = 500, ["3"] = 500, ["4"] = 500, ["5"] = 500, ["6"] = 500, ["7"] = 500,
  ["8"] = 500, ["9"] = 500, [","] = 250, [" "] = 250, ["-"] = 333, ["\u{2013}"] = 500, p = 500, a = 444, s = 389,
  i = 278, m = 778, n = 500, v = 500, x = 500, f = 333, l = 278, c = 444,
}
local function page_col(pages)
  local units = 0
  for _, ch in utf8.codes(pages) do units = units + (ADV[utf8.char(ch)] or 500) end
  return math.max(TOA_COL, (units * 14 + 999) // 1000 + 7) * 20
end

-- The first words after a heading, for its needle: the next block's text, or the next heading's.
local function after(blocks, i)
  local b = blocks[i]
  if b == nil then return "" end
  if b.t == "OrderedList" then
    return tostring(b.listAttributes.start) .. " " .. plain(b.content[1] and b.content[1][1] or ""):sub(1, 40)
  end
  if b.t == "BulletList" then return plain(b.content[1] and b.content[1][1] or ""):sub(1, 40) end
  return plain(b):sub(1, 40)
end

local function split_sections(blocks)
  local secs = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      secs[#secs + 1] = { title = plain(b.content), inl = b.content, blocks = {} }
    elseif #secs > 0 then
      local s = secs[#secs]
      s.blocks[#s.blocks + 1] = b
    else
      fail("text before the first section heading")
    end
  end
  return secs
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  local edition = plain(meta.rules_edition)
  if edition == "" then edition = DEFAULT_EDITION end
  local limit = WORD_LIMITS[edition]
  if not limit then fail("rules_edition must be 2026 or 2025") end
  if meta.signature == nil then fail("frontmatter `signature` is required (Rule 9.1)") end

  -- the word count (every counted section, wherever it sits)
  local src = source_sections()
  local words = word_count(src)
  if words > limit then
    fail("word count " .. words .. " exceeds the " .. limit .. "-word limit of Rule 9.4(i)(2)")
  end
  if INTRO_LIMIT and edition == "2026" then
    for _, s in ipairs(src) do
      if s.title:lower():find("^introduction") and count_words(s.text) > INTRO_LIMIT then
        fail("introduction has " .. count_words(s.text) .. " words; Rule 53.2(a) allows " .. INTRO_LIMIT)
      end
    end
  end
  local count = commas(words)

  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  -- (the blocks only: xe.inl applies the same rules to a metadata value, and reads a raw no-break hyphen as text)
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  doc = doc:walk({
    Str = function(s)
      if s.text:find("{{word-count}}", 1, true) then
        return pandoc.Str((s.text:gsub("{{word%-count}}", count)))
      end
    end,
  })
  meta = doc.meta

  local body_start = plain(meta.body_start):lower()
  local secs = split_sections(doc.blocks)
  local front, main = {}, {}
  for _, s in ipairs(secs) do
    if #main == 0 and s.title:lower() ~= body_start then front[#front + 1] = s else main[#main + 1] = s end
  end
  if #main == 0 then fail("body_start heading not found: " .. plain(meta.body_start)) end

  -- the headings, in document order, for the contents and the needles
  local heads = {}
  local function head(level, inl, context, o)
    local id = "H:" .. (#heads + 1)
    heads[#heads + 1] = { id = id, level = level, inl = inl }
    need(id, plain(inl), context)
    o = o or {}
    o.style = "Heading" .. level
    o.before = o.before or HEAD_BEFORE
    o.after = o.after or HEAD_AFTER
    return p(xe.inl(inl), o), id
  end

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- the cover
  need("S:cover", "No. " .. plain(meta.case_number) .. " IN THE SUPREME COURT OF TEXAS", "")
  cover(meta, out)
  add(section_end("rIdFtrNone"))

  -- body blocks of a section: headings, paragraphs (with or without a footnote), lists, quotations
  local function body(blocks, o)
    o = o or {}
    for i, b in ipairs(blocks) do
      if b.t == "Header" then
        if b.level > 3 then fail("headings deeper than level 3 are not supported") end
        add((head(b.level, b.content, after(blocks, i + 1))))
      elseif b.t == "Para" or b.t == "Plain" then
        local style = o.para or (has_note(b.content) and "Body Text Note" or "Body Text")
        if o.keep_last and i == #blocks then style = "Body Keep" end
        add(div(style, b.content))
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        for _, x in ipairs(xe.list_items(b)) do add(x) end
      else
        add(b)
      end
    end
  end

  -- the front matter
  for k, s in ipairs(front) do
    local identities = s.title:lower():find("^identit") ~= nil
    add((head(1, s.inl, after(s.blocks, 1), { before = 0, after = identities and GAP or nil, brk = k > 1 })))
    body(s.blocks, identities and { para = "Identity" } or nil)
  end

  -- the table of contents (rows filled in below, once every heading is known)
  add(p(xe.runs("TABLE OF CONTENTS"), { style = "Heading1", before = 0, after = HEAD_AFTER, brk = #front > 0 }))
  local toc_at = #out + 1
  add(false)

  -- the index of authorities
  local groups = list(meta.authorities)
  local first = ""
  if groups[1] then
    first = plain(groups[1].group)
    local it = list(groups[1].items)[1]
    if it then first = first .. " " .. plain(it.name) end
  end
  add((head(1, pandoc.Inlines({ pandoc.Str("INDEX OF AUTHORITIES") }), first, { before = 0, brk = true })))
  for _, g in ipairs(groups) do
    add(p(xe.runs(plain(g.group), { b = true }), { keep = true, before = SINGLE, after = GAP, first = 0 }))
    for _, it in ipairs(list(g.items)) do
      local pages = plain(it.pages)
      local name = xe.inl(it.name, { i = it.italic == true })
      add(p(name .. xe.inl(it.rest) .. xe.runs(xe.LEAD) .. xe.runs(pages), { lines = true,
        tabs = xe.leader_tab(TEXTW), before = GAP, left = TOA_HANG, hanging = TOA_HANG, right = page_col(pages) }))
    end
  end
  add(section_end("rIdTexFtr", "lowerRoman", 2))

  -- the body
  local body_id
  for k, s in ipairs(main) do
    local t = s.title:lower()
    local appendix = t:find("^appendix") ~= nil
    local h, id = head(1, s.inl, after(s.blocks, 1), (k == 1 or appendix) and { before = 0, brk = appendix } or nil)
    body_id = body_id or id
    add(h)
    local prayer = t:find("prayer") ~= nil
    local last = s.blocks[#s.blocks]
    body(s.blocks, { keep_last = prayer and last and (last.t == "Para" or last.t == "Plain") })
    if prayer then signature(meta.signature, out) end
    if t:find("^certificat") then certificate_signature(meta.signature, out) end
  end

  -- the contents rows: every heading to the third level, with its page
  local rows = {}
  for _, h in ipairs(heads) do
    local ind = (h.level - 1) * LEVEL
    rows[#rows + 1] = p(xe.inl(h.inl) .. xe.runs(xe.LEAD) .. xe.runs(labels[h.id] or "0"), { lines = true,
      tabs = xe.leader_tab(TEXTW), before = GAP, left = ind, first = 0, right = TOC_COL })
  end
  table.remove(out, toc_at)
  for i, r in ipairs(rows) do table.insert(out, toc_at + i - 1, r) end

  needles[#needles + 1] = "#section\tS:cover\tlower-roman\t"
  needles[#needles + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdTexFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdTexFtr", "decimal", 1))

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
