-- California Supreme Court petition for review (rules 8.500, 8.504; the format of rules 8.204 and 8.74), docx engine
-- (docs/DOCX.md). The document as Word paragraphs, so that it reads and breaks as typst/cal-petition-for-review.typ
-- does, from the same markdown contract (../README.md): the cover (page 1, its number not shown, rule 8.204(b)(7)),
-- the table of contents and the table of authorities (built from the `toa:` links of the body, as typst builds them),
-- the body with its heading labels (I. / A. / 1. / a. / (1)), lists, block quotations and footnotes, the signature
-- block kept with the last paragraph, the certificate of compliance with the word count (rule 8.504(d)(1)) and the
-- proof of service (rule 8.25(a)). Every case-specific word comes from the sample's frontmatter and body, never from
-- this file. Fonts and the paragraph styles pandoc writes itself (Body Text Note, Body Text Keep, Footnote Text) are
-- in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 299 a single line), the spaces between blocks
-- those of the typst template (between two blocks only the larger is written, on the second), and the break rules of
-- typst on every run. A paragraph that anchors a footnote stays a pandoc paragraph (style Body Text Note, without
-- widow control, as typst sets it without widow or orphan rule).
--
-- The tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter
-- writes ($FORMBOOK_NEEDLES: the cover, the two table titles, each heading, each citation, the certificates, in
-- document order) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle. The
-- pages are numbered in arabic from the cover (rule 8.204(b)(7)); this filter writes the section ($FORMBOOK_FINAL)
-- and the page-number footer ($FORMBOOK_FOOTERS), none on the cover.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

-- typst parameters, in twips
local BODY, SINGLE = 480, 299            -- pitch-body 24 pt, pitch-single 14.95 pt
local TEXTW = 7920                       -- 8.5 in less margin-x 1.5 in on each side
local INDENT = 720                       -- para-indent 0.5 in
local LABEL = 720                        -- label-box 0.5 in
local QUOTE_INSET = 720                  -- quote-inset 0.5 in
local TOC_STEP = 504                     -- toc-step 0.35 in
local TOC_COL, TOA_COL = 720, 1800       -- toc-col 0.5 in, toa-col 1.25 in
local TOA_HANG = 504                     -- toa-hang 0.35 in
local COUNSEL = 2880                     -- counsel-left 2 in
local SERVICE_IND = 720                  -- service-indent 0.5 in
local RULE = 2880                        -- rule-length 2 in
local COVER_GAP = 360                    -- cover-gap 18 pt
local H1_ABOVE, H_ABOVE, H_BELOW = 480, 240, 240 -- h1-above 24 pt, heading-above 12 pt, heading-below 12 pt
local QUOTE_GAP = 240                    -- quote-gap 12 pt
local TOC_ROW, TOC_H1 = 120, 240         -- toc-row-gap 6 pt, toc-h1-gap 12 pt
local TOA_GROUP, TOA_ROW = 299, 180      -- toa-group-gap 14.95 pt, toa-row-gap 9 pt
local SIG_ABOVE, SIGNER_ABOVE = 480, 480 -- sig-above, signer-above 24 pt
local SERVICE_GAP = 240                  -- service-gap 12 pt
local TOC_DEPTH = 4                      -- toc-depth
local PASSIM_AT = 7                      -- passim-threshold
local WORD_LIMIT = 8400                  -- word-limit: rule 8.504(d)(1)
local FONT_NAMED = "Times New Roman"     -- font-named: the face the certificate states (typst and docx alike)
local NEEDLE_MAX = 60
local GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

-- The section: letter page, 1.5 in left and right, 1 in top and bottom (rule 8.204(b)(6)); the page number centered
-- on every page but the cover (titlePg; rule 8.204(b)(7)) in a single-pitch line whose box ends 0.5 in above the
-- page edge (typst footer-distance).
local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:left="0" w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrCal"/>'
  .. '<w:footerReference w:type="first" r:id="rIdFtrNone"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="2160" w:bottom="1440" w:left="2160" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/><w:titlePg/></w:sectPr>'

local function fail(msg) error("cal-petition: " .. msg, 0) end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function need(m, k)
  if m[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return m[k]
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("60(b)(5)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide. A doubled
-- sign stays with its number ("§§ 1281": typst binds it with a box).
local function bind(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    local a = l[i]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- ---------------------------------------------------------------------------
-- Paragraphs
-- ---------------------------------------------------------------------------

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs, border, outline }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.border then
    props[#props + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>'
  end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

-- The document as a list of items: { xml, o } (a paragraph this filter writes; its spacing settled in `flush`) or
-- { block } (a block pandoc writes). Between two paragraphs of this filter only the larger of the space below the
-- first and above the second is written, above the second (typst: two explicit spaces collapse to the larger).
local function flush(list)
  for i = 1, #list - 1 do
    local a, b = list[i], list[i + 1]
    if a.o and b.o and (a.o.after or 0) > 0 then
      b.o.before = math.max(b.o.before or 0, a.o.after)
      a.o.after = 0
    end
  end
  local out = {}
  for _, it in ipairs(list) do
    if it.block then out[#out + 1] = it.block else out[#out + 1] = xe.raw(p(it.xml, it.o)) end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function needle(id, kind, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, _, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
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

-- The citations of a list of inlines, in document order, as needles (B in the body, N in a footnote): the link text
-- and the words after it.
local cites = {}
local scan_blocks
local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      local id = "A:" .. (#cites + 1)
      cites[#cites + 1] = { id = id, key = el.target:sub(5) }
      needle(id, in_note and "N" or "B", stringify(el.content), stringify(rest):sub(1, 40))
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
    elseif b.t == "BlockQuote" or b.t == "Div" then
      scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

local function has_note(b)
  local found = false
  pandoc.Blocks({ b }):walk({ Note = function() found = true end })
  return found
end

-- ---------------------------------------------------------------------------
-- Numbers and words
-- ---------------------------------------------------------------------------

local function roman(n)
  local s = ""
  for _, v in ipairs({ { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

-- typst heading-number: I. / A. / 1. / a. / (1), by level.
local function heading_label(level, k)
  if level == 1 then return roman(k) .. "." end
  if level == 2 then return string.char(64 + k) .. "." end
  if level == 3 then return tostring(k) .. "." end
  if level == 4 then return string.char(96 + k) .. "." end
  if level == 5 then return "(" .. k .. ")" end
  fail("headings deeper than level 5 are not supported")
end

local function group_digits(n)
  local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (s:gsub("^,", ""))
end

-- typst count-words, rule for rule, on the markdown body after the frontmatter.
local function count_words()
  local f = PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then fail("cannot read the sample markdown for the word count") end
  local src = h:read("a")
  h:close()
  local body = src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n(.*)$")
  if not body then fail("the sample must start with a YAML frontmatter block") end
  body = body:gsub("<!%-%-.-%-%->", " ")
  local n = 0
  for line in (body .. "\n"):gmatch("(.-)\n") do
    local s = line:gsub("^%[%^[^%]]+%]:", " ")
    s = s:gsub("%[%^[^%]]+%]", "")
    s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
    s = s:gsub("^#+[ \t]+", "")
    s = s:gsub("^>[ \t]?", "")
    s = s:gsub("^[ \t]*[-*+][ \t]+", "")
    s = s:gsub("^[ \t]*%d+[.)][ \t]+", "")
    s = s:gsub("\\(.)", "%1")
    s = s:gsub("%*", "")
    for _ in s:gmatch("%S+") do n = n + 1 end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body)
-- ---------------------------------------------------------------------------

local function cover(m, list)
  local function add(xml, o) list[#list + 1] = { xml = xml, o = o or {} } end
  local function rule() add("", { before = COVER_GAP, line = 20, border = true, left = (TEXTW - RULE) // 2, right = (TEXTW - RULE) // 2 }) end
  add(xe.runs("No. " .. (m.supreme_court_case and plain(m.supreme_court_case) or "S__________"), { b = true }), { jc = "center" })
  add(xe.runs("In the Supreme Court of the State of California"), { before = COVER_GAP, jc = "center" })
  rule()
  local sides = items(need(m, "caption"))
  for i, side in ipairs(sides) do
    for k, n in ipairs(items(side.names)) do add(xe.inl(n), { before = k == 1 and COVER_GAP or 0, jc = "center" }) end
    add(xe.inl(side.designation), { jc = "right" })
    if i < #sides then add(xe.runs("v."), { before = COVER_GAP // 2, jc = "center" }) end
  end
  rule()
  add(xe.inl(need(m, "court_of_appeal")), { before = COVER_GAP, jc = "center" })
  add(xe.inl(need(m, "trial_court")), { jc = "center" })
  if m.judge then add(xe.inl(m.judge), { jc = "center" }) end
  rule()
  add(xe.runs("PETITION FOR REVIEW", { b = true }), { before = COVER_GAP, jc = "center" })
  rule()
  local groups = items(need(m, "counsel"))
  for gi, g in ipairs(groups) do
    local lines = {}
    for _, x in ipairs(items(g.names)) do lines[#lines + 1] = xe.inl(x) end
    for _, x in ipairs(items(g.lines)) do lines[#lines + 1] = xe.inl(x) end
    if gi == #groups then lines[#lines + 1] = xe.runs("Telephone: " .. plain(need(m, "phone"))) end
    for k, x in ipairs(lines) do add(x, { before = k == 1 and COVER_GAP or 0, left = COUNSEL }) end
  end
  add(xe.inl(need(m, "represents"), { i = true }), { left = COUNSEL })
  add(xe.inl(need(m, "date")), { before = COVER_GAP })
end

-- ---------------------------------------------------------------------------
-- Headings
-- ---------------------------------------------------------------------------

-- typst style-heading: single pitch, bold, kept with the text after it. Level 1 centered capitals after its numeral;
-- deeper levels the label in a box at the level's indent, the later lines hanging after it.
local function heading(level, label, content, o)
  o = o or {}
  local q = { keep = true, before = o.before, after = H_BELOW, pre = o.pre, outline = level - 1 }
  if level == 1 then
    q.before = q.before or H1_ABOVE
    q.jc = "center"
    local text = label and (xe.runs(label .. " ", { b = true }) .. xe.inl(upper(content), { b = true }))
      or xe.inl(upper(content), { b = true })
    return { xml = text, o = q }
  end
  local ind = (level - 2) * LABEL
  q.before = q.before or H_ABOVE
  q.left, q.hanging = ind + LABEL, LABEL
  q.tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + LABEL) .. '"/></w:tabs>'
  return { xml = xe.runs(label .. "\t", { b = true }) .. xe.inl(content, { b = true }), o = q }
end

-- An unnumbered level 1 heading of the front and back matter, opening a new page (Word keeps the space above a
-- paragraph after a page break, typst drops it: none).
local function page_heading(text)
  return heading(1, nil, pandoc.Inlines({ pandoc.Str(text) }), { before = 0, pre = xe.BREAK })
end

-- ---------------------------------------------------------------------------
-- The tables (typst toc-section, toa-section)
-- ---------------------------------------------------------------------------

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging, col, before, label_tab)
  local tabs = '<w:tabs>' .. (label_tab and ('<w:tab w:val="left" w:pos="' .. label_tab .. '"/>') or "")
    .. '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return { xml = text_xml .. xe.runs(xe.LEAD) .. pages_xml,
    o = { lines = true, tabs = tabs, before = before, left = left, hanging = hanging, right = col } }
end

local function table_head(list, title, col)
  list[#list + 1] = page_heading(title)
  list[#list + 1] = { xml = xe.runs(col, { b = true, u = true }), o = { keep = true, jc = "right" } }
end

local function toc(list, entries)
  table_head(list, "Table of Contents", "Page")
  for _, e in ipairs(entries) do
    if e.level <= TOC_DEPTH then
      local ind = (e.level - 1) * TOC_STEP
      local title = e.level == 1 and upper(e.title) or e.title
      local page = xe.runs(labels[e.id] or "0")
      list[#list + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(title), page, ind + LABEL, LABEL, TOC_COL,
        e.level == 1 and TOC_H1 or TOC_ROW, ind + LABEL)
    end
  end
end

local function sort_key(a)
  local s = a.sort and plain(a.sort) or (plain(a.name or "") .. " " .. plain(a.cite))
  return (pandoc.text.lower(s):gsub("[^a-z0-9 ]", ""))
end

local function toa(list, authorities)
  table_head(list, "Table of Authorities", "Page(s)")
  -- the distinct page labels of each authority, in document order (the page a citation starts on)
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then fail("link `toa:" .. c.key .. "` has no entry under `authorities:` in the frontmatter") end
    pages[c.key] = pages[c.key] or {}
    seen[c.key] = seen[c.key] or {}
    local l = labels[c.id] or "0"
    if not seen[c.key][l] then
      seen[c.key][l] = true
      pages[c.key][#pages[c.key] + 1] = l
    end
  end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if pages[key] and plain(a.kind) == g[1] then members[#members + 1] = { key = key, a = a, sort = sort_key(a) } end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      list[#list + 1] = { xml = xe.runs(g[2], { b = true }), o = { before = TOA_GROUP, keep = true } }
      for _, mm in ipairs(members) do
        local a = mm.a
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pl, ", "))
        if a.name ~= nil then
          list[#list + 1] = { xml = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(","),
            o = { before = TOA_ROW, keep = true, lines = true, right = TOA_COL, left = TOA_HANG, hanging = TOA_HANG } }
          list[#list + 1] = row(xe.inl(a.cite), pxml, TOA_HANG, 0, TOA_COL, 0)
        else
          list[#list + 1] = row(xe.inl(a.cite), pxml, TOA_HANG, TOA_HANG, TOA_COL, TOA_ROW)
        end
      end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block, certificate of compliance, proof of service
-- ---------------------------------------------------------------------------

-- typst signature-block: "Dated:" at the margin; from counsel-left "Respectfully submitted,", "/s/" and the signer,
-- the signer in capitals, the lines in italics; kept on one page.
local function signature(m, list)
  local sig = need(m, "signature")
  local rows = {
    { xe.runs("Dated: ") .. xe.inl(need(m, "date")), { before = SIG_ABOVE } },
    { xe.runs("Respectfully submitted,"), { before = SIG_ABOVE, left = COUNSEL } },
    { xe.runs("/s/ ") .. xe.inl(sig.signer), { before = SIGNER_ABOVE, left = COUNSEL } },
    { xe.runs(pandoc.text.upper(plain(sig.signer))), { left = COUNSEL } },
  }
  for _, l in ipairs(items(sig.lines)) do rows[#rows + 1] = { xe.inl(l, { i = true }), { left = COUNSEL } } end
  for k, r in ipairs(rows) do
    if k < #rows then r[2].keep = true else r[2].lines = true end
    list[#list + 1] = { xml = r[1], o = r[2] }
  end
end

local function certificate(m, words, list)
  list[#list + 1] = page_heading("Certificate of Compliance")
  list[#list + 1] = { xml = xe.runs("I certify that the attached PETITION FOR REVIEW uses a 13-point " .. FONT_NAMED
    .. " font and contains " .. group_digits(words) .. " words."), o = {} }
  signature(m, list)
end

local function service(m, list)
  list[#list + 1] = page_heading("Proof of Service")
  list[#list + 1] = { xml = xe.runs("I certify that the foregoing PETITION FOR REVIEW was electronically served on the following interested parties on ")
    .. xe.inl(need(m, "date")) .. xe.runs(", in the manner described."), o = {} }
  for _, s in ipairs(items(need(m, "service"))) do
    local lines = { xe.inl(s.party) }
    for _, x in ipairs(items(s.names)) do lines[#lines + 1] = xe.inl(x) end
    for _, x in ipairs(items(s.lines)) do lines[#lines + 1] = xe.inl(x) end
    lines[#lines + 1] = xe.inl(s.method)
    for k, x in ipairs(lines) do
      list[#list + 1] = { xml = x, o = { before = k == 1 and SERVICE_GAP or 0, left = SERVICE_IND,
        keep = k < #lines, lines = true } }
    end
  end
  signature(m, list)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body block as Word paragraphs (typst petition-body): a paragraph on the body pitch, its first line indented
-- (one with a footnote stays a pandoc paragraph: Body Text Note; the last one is kept with the signature block: Body
-- Text Keep); a list's items with the label in a half-inch box at the margin; a block quotation's paragraphs single
-- spaced, half an inch in on both sides.
local function body_block(b, list, last)
  if b.t == "Para" or b.t == "Plain" then
    if last then
      list[#list + 1] = { block = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Body Text Keep" }) }
    elseif has_note(b) then
      list[#list + 1] = { block = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Body Text Note" }) }
    else
      list[#list + 1] = { xml = xe.inl(b.content), o = { line = BODY, first = INDENT } }
    end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    local n = b.t == "OrderedList" and b.listAttributes.start or 1
    for _, item in ipairs(b.content) do
      if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") or has_note(item[1]) then
        fail("unsupported list item (one paragraph each, without footnotes)")
      end
      local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
      list[#list + 1] = { xml = xe.runs(lab .. "\t") .. xe.inl(item[1].content), o = { line = BODY, left = LABEL,
        hanging = LABEL, tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. LABEL .. '"/></w:tabs>' } }
      n = n + 1
    end
  elseif b.t == "BlockQuote" then
    local ps = b.content
    for k, q in ipairs(ps) do
      if (q.t ~= "Para" and q.t ~= "Plain") or has_note(q) then fail("unsupported block quotation (paragraphs without footnotes)") end
      list[#list + 1] = { xml = xe.inl(q.content), o = { before = k == 1 and QUOTE_GAP or 0,
        after = k == #ps and QUOTE_GAP or 0, left = QUOTE_INSET, right = QUOTE_INSET } }
    end
  else
    fail("unsupported block " .. b.t)
  end
  if last and b.t ~= "Para" and b.t ~= "Plain" then
    fail("the body must end with a paragraph (the conclusion), kept with the signature block")
  end
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "caption", "court_of_appeal", "trial_court", "counsel", "phone", "represents", "signature",
    "date", "service" }) do
    need(m, k)
  end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end
  local blocks = doc.blocks

  -- rule 8.504(b)(1): the body opens with the statement of the issues presented; it needs a conclusion
  if not (blocks[1] and blocks[1].t == "Header" and blocks[1].level == 1
      and pandoc.text.lower(stringify(blocks[1].content)):find("issue", 1, true)) then
    fail("the body must open with the statement of issues presented (rule 8.504(b)(1))")
  end
  local words = count_words()
  if words > WORD_LIMIT then fail("the petition has " .. words .. " words; rule 8.504(d)(1) allows " .. WORD_LIMIT) end

  local cover_list = {}
  cover(m, cover_list)
  needle("S:cover", "B", "No. " .. (m.supreme_court_case and plain(m.supreme_court_case) or "S__________"),
    "In the Supreme Court")
  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")

  -- the body: heading labels and the contents' entries, needles of headings and citations, in order
  local c = { 0, 0, 0, 0, 0 }
  local entries, body = {}, {}
  for i, b in ipairs(blocks) do
    local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local lv = b.level
      if lv > 5 then fail("headings deeper than level 5 are not supported") end
      c[lv] = c[lv] + 1
      for j = lv + 1, 5 do c[j] = 0 end
      local label = heading_label(lv, c[lv])
      local id = "H:" .. (#entries + 1)
      needle(id, "B", label .. " " .. stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = lv, label = label, title = b.content }
      body[#body + 1] = heading(lv, label, b.content, { pre = i == 1 and xe.BREAK or nil, before = i == 1 and 0 or nil })
    else
      scan_blocks({ b }, false)
      body_block(b, body, i == #blocks)
    end
  end
  signature(m, body)
  needle("C:compliance", "B", "CERTIFICATE OF COMPLIANCE", "I certify that the attached")
  needle("C:service", "B", "PROOF OF SERVICE", "I certify that the foregoing")

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrCal\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", SECT)

  local all = {}
  local function addall(xs) for _, x in ipairs(xs) do all[#all + 1] = x end end
  addall(cover_list)
  local front = {}
  toc(front, entries)
  toa(front, authorities)
  addall(front)
  addall(body)
  local back = {}
  certificate(m, words, back)
  service(m, back)
  addall(back)
  local out = flush(all)
  -- a citation link prints its text only; the break rules on what pandoc writes
  local result = pandoc.Blocks(out):walk({ Link = function(el) return el.content end }):walk({ Inlines = xe.inlines })
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(result, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
