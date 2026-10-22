-- cavc.lua (docx engine): the U.S. Court of Appeals for Veterans Claims principal brief as Word paragraphs and
-- sections (typst: ../typst/cavc-<kind>.typ), on the shared cross-engine layout model (lib/docx/xengine.lua;
-- docs/EVAL-LOOP.md, "Cross-engine gate"): every line and page breaks where the typst render breaks it. pandoc
-- writes the body text (paragraphs, quotations, lists, footnotes) with docx/reference.docx; this filter writes
-- what needs Word formatting:
--   * the caption page (Rule 32(c), Form 2), the table of contents, the table of authorities (Rule 28(a)(1)-(2)),
--     the signature block and the certificate of service (Rule 25(a)), as paragraphs with explicit spacing,
--     indents and tabs;
--   * the heading labels (I., A., 1., a. in the Argument; A., 1., a., (1) elsewhere) and each heading's outline
--     level; the level-1 sections Rule 28 requires, in order (the build fails without them, as typst's does);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of
--     every heading and citation in that PDF (the needles this filter writes) and renders again with those pages;
--   * the sections whose footers number the pages (Rule 32(d)): caption page none; contents and authorities i, ii
--     ...; body 1, 2 ...; certificate of service i. fb render writes the footers; this filter writes the last
--     section (FORMBOOK_FINAL).
-- The 30-page limit of Rule 32(e) is checked by the typst template (the docx breaks its pages alike).
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

-- The only part that differs between the two copies (answering-brief/docx and opening-brief/docx).
local CFG = {
  kind = "answering-brief",
  required = { "summary of the argument", "argument", "conclusion" },
  summary_may_open_argument = false,
  -- the face (typst font-family) at 14 pt, in twips: digits 0.556 em, comma and space 0.278 em; about 64
  -- characters on a 6.5 in line, 30 on the half line (the caption page's spacing estimate)
  digit_w = 156, punct_w = 78, chars = 64, half_chars = 30,
}

local TOC_DEPTH = 4    -- heading levels listed in the table of contents (typst: toc-depth)
local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local TAB = 720        -- half an inch (para-indent, label width), in twips
local TAB_R = 9360     -- the right tab of the tables: at the margin (typst sets the page numbers flush with it)
local PNUM_TOC = 720   -- the column the contents' page numbers keep to themselves (typst toc-page-col, 36 pt)
local PNUM_TOA = 1120  -- the column of the authorities' page lists (typst toa-page-col, 56 pt)
local HALF_W = 4680    -- the middle of the text: designations, counsel and signature blocks start here
local SINGLE = 340     -- single-spaced material (headings, caption page, tables, signature): 17 pt (typst pitch-single)
local DOUBLE = 588     -- body text (reference.docx Body Text): 29.4 pt, 2.1 x 14 pt (CAVC-FORM-003; typst pitch-double)
local HEAD = 400       -- section headings: 20 pt line (typst pitch-heading)
local HEAD_SZ = 32     -- section headings: 16 pt (half points; typst heading-size)
local DIGIT_W, PUNCT_W = CFG.digit_w, CFG.punct_w
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)

local stringify = pandoc.utils.stringify

-- ---------------------------------------------------------------------------
-- XML helpers: the shared ones of the cross-engine layout model (lib/docx/xengine.lua)
-- ---------------------------------------------------------------------------

local xe = require("docx.xengine")
local runs, inl = xe.runs, xe.inl
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, BR, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.BR, xe.LEAD
local list_items = xe.list_items

local function fail(msg) error("cavc-" .. CFG.kind .. ": " .. msg, 0) end

-- Exact line spacing; single-spaced unless another pitch is given.
local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

-- A dot leader to the right margin (the page number follows the last tab).
local function dot_tabs()
  return xe.leader_tab(TAB_R)
end

-- A horizontal rule: an empty paragraph with a bottom border. `left_right` narrows it (the 2 in rules).
local function rule(kind, before, left_right)
  local b = kind == "double"
      and '<w:pBdr><w:bottom w:val="thickThinSmallGap" w:sz="12" w:space="1" w:color="000000"/></w:pBdr>'
      or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  return para({ b, spacing(before, 0, 20), ind(left_right or 0, nil, nil, left_right or 0) }, "")
end

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, written by fb render), page number format and
-- start, letter paper with 1 in margins.
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="676" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (a 1 pt line, so it never pushes a line on).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

-- ---------------------------------------------------------------------------
-- Numbers, needles and pages
-- ---------------------------------------------------------------------------

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

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing).
local needles = {}
-- The fallback is the text's first words (at least 8 letters and digits): a needle that runs over a page break
-- is not found whole, because the page's footnotes come between its two halves in the PDF text.
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

-- The pages of the previous pass: id -> { page, label }. Absent on the first pass itself.
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
  return "00" -- the first pass: a placeholder of the final width
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Headings
-- ---------------------------------------------------------------------------

-- The label of a numbered heading (typst heading-label). The Argument: I. / A. / 1. / a.; elsewhere: A. / 1. / a. / (1).
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

-- The indent of a sub-heading's label, in half inches (typst label-indent): the Argument's point is centered.
local function step(level, arg)
  if arg then return level - 2 end
  return level - 1
end

local function hstyle(level)
  return style("Heading" .. level)
end

-- typst `space`: the spacing above and below each kind of heading, in twips (21 / 15.4, 16.8 / 14, 15.4 / 12.6 pt).
local SPACE = {
  section = { 420, 308 },
  point = { 336, 280 },
  sub = { 308, 252 },
  plain = { 336, 252 },
}

-- A section heading (level 1, the tables, the certificate): bold capitals, centered, 16 pt.
-- `top`: the heading opens a page (no space above); `brk`: it also breaks the page (not after a section break);
-- `plain`: not a Heading style (not in the outline).
local function section_heading(text, top, brk, plain)
  return para({ plain and "" or hstyle(1), KEEP, brk and BREAK or "", spacing(top and 0 or SPACE.section[1], SPACE.section[2], HEAD),
    ind(0, nil, 0), jc("center") }, runs(text:upper(), { b = true, sz = HEAD_SZ }))
end

-- A body heading (typst style-heading).
local function heading_xml(level, content, lab, arg)
  if level == 1 then return section_heading(stringify(content), false) end
  if arg and level == 2 then
    return para({ hstyle(2), KEEP, spacing(SPACE.point[1], SPACE.point[2]), ind(0, nil, 0), jc("center") },
      runs(lab .. " ", { b = true }) .. inl(content, { b = true }))
  end
  local k = step(level, arg)
  local o = { b = true, i = level >= 4 }
  return para({ hstyle(level), KEEP, spacing(SPACE.sub[1], SPACE.sub[2]), ind(TAB * (k + 1), TAB) },
    runs(lab .. "\t", o) .. inl(content, o))
end

-- One row of the table of contents (typst listing-row): label, title, a dot leader from the end of the title and
-- the page. The title wraps before the page column (the right indent); the right tab sits beyond it.
local function toc_row(item)
  local title = item.level == 1 and item.title:upper() or item.title
  local left, hanging, lead = 0, nil, ""
  if item.label then
    left, hanging = TAB * item.step + TAB, TAB
    lead = runs(item.label .. "\t", {})
  end
  return para({ LINES, dot_tabs(), spacing(item.level == 1 and 168 or 98, 0), ind(left, hanging, nil, PNUM_TOC) },
    lead .. runs(title .. LEAD .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities (typst toa-section)
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "case", "Cases:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
  { "rba", "Citations to the Record Before the Agency:" },
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
      -- the group title; the first one carries the column heading "Page(s)" at the right margin
      local head = runs(g[2], { b = true })
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TAB_R .. '"/></w:tabs>',
        spacing(#out == 0 and 280 or 392, 56) }, head)
      for _, m in ipairs(members) do
        -- the distinct pages of the authority, in document order
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local k = l and l.label or ("?" .. o.index)
            if not seen[k] then
              seen[k] = true
              pages[#pages + 1] = l and l.label or "00"
            end
          end
        end
        local list
        local list_w = 0
        if #pages >= PASSIM then
          list = runs("passim", { i = true })
        else
          local s = table.concat(pages, ", ")
          list = runs(s, {})
          -- a list wider than the column widens the column (typst: the larger of 56 pt and the list)
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and DIGIT_W or PUNCT_W) end
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = g[1] == "case" }) .. runs(",", {}) .. BR
        end
        out[#out + 1] = para({ LINES, dot_tabs(), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. runs(LEAD, {}) .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Caption page (typst cover-body)
-- ---------------------------------------------------------------------------

local function need_meta(meta, k)
  if meta[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- Lines a text takes in a column of `chars` characters (an estimate: CFG.chars on a full line).
local function est_lines(text, chars)
  return math.max(1, math.ceil(#stringify(text) / chars))
end

local function cover(meta)
  local sides = need_meta(meta, "caption")
  local counsel = need_meta(meta, "counsel")
  local proceeding = stringify(need_meta(meta, "proceeding"))
  -- The gap between the caption page's parts is the largest that keeps it on one page (typst: cover); the type
  -- size and line pitch never shrink. 9 in of text height = 648 pt, less a safety margin for the estimate.
  local lines = 1 + 2 + est_lines(need_meta(meta, "brief_title"), CFG.chars - 8)
  local gaps = 10.6
  if proceeding ~= "" then
    lines = lines + est_lines(proceeding, CFG.chars - 8)
    gaps = gaps + 2
  end
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do lines = lines + est_lines(n, CFG.chars - 2) end
    lines = lines + 1 + (i < #sides and 1 or 0)
  end
  for _, g in ipairs(counsel) do
    for _, n in ipairs(g.names or {}) do lines = lines + est_lines(n, CFG.half_chars) end
    for _, l in ipairs(g.lines or {}) do lines = lines + est_lines(l, CFG.half_chars) end
  end
  lines = lines + 1 -- the telephone
  local free = (612 - lines * SINGLE / 20 - 6 * 6) * 20 -- twips left for the gaps
  local gap = math.max(0, math.min(280, math.floor(free / gaps)))

  local out = {}
  local function add(x) out[#out + 1] = x end
  add(para({ KEEP, spacing(math.floor(gap * 0.6), 0), jc("center") },
    runs("Vet. App. No. ", { b = true }) .. inl(meta.case_number, { b = true })))
  add(rule("double", gap))
  -- the court's name on two lines, broken after APPEALS (typst cover-body)
  add(para({ spacing(gap, 0), jc("center") },
    runs("IN THE UNITED STATES COURT OF APPEALS", { b = true }) .. BR .. runs("FOR VETERANS CLAIMS", { b = true })))
  add(rule("short", gap, 3240))
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do
      add(para({ spacing((i == 1 and k == 1) and gap or 0, 0), jc("center") }, inl(n, {})))
    end
    add(para({ spacing(0, 0), ind(HALF_W) }, inl(side.designation, {})))
    if i < #sides then
      add(para({ spacing(math.floor(gap * 0.3), math.floor(gap * 0.3)), jc("center") }, runs("v.", {})))
    end
  end
  add(rule("short", gap, 3240))
  if proceeding ~= "" then
    add(para({ spacing(gap, 0), jc("center") }, inl(meta.proceeding, { b = true })))
    add(rule("short", gap, 3240))
  end
  add(para({ spacing(gap, 0), jc("center") }, runs(stringify(meta.brief_title):upper(), { b = true })))
  add(rule("short", gap, 3240))
  -- counsel (Rule 32(f)): name, address and telephone number
  for gi, g in ipairs(counsel) do
    local first = true
    local function cl(body, first_ind)
      add(para({ LINES, spacing(first and (gi == 1 and gap or 100) or 0, 0), ind(HALF_W, nil, first_ind) }, body))
      first = false
    end
    for _, n in ipairs(g.names or {}) do cl(inl(n, {})) end
    local ls = {}
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = l end
    if gi == #counsel then ls[#ls + 1] = need_meta(meta, "phone") end
    for _, l in ipairs(ls) do cl(inl(l, { i = true }), 140) end -- typst: half an em in
  end
  add(rule("double", gap))
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (typst signature-block, certificate-of-service)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  -- "Respectfully submitted," then 16.8 pt, the signature, the signer's lines (0.5 em in) and the telephone in the
  -- right half; then 11.2 pt and the date at the margin
  out[#out + 1] = para({ KEEP, spacing(392, 0), ind(HALF_W) }, runs("Respectfully submitted,", {}))
  out[#out + 1] = para({ KEEP, spacing(336, 0), ind(HALF_W) }, runs("s/ " .. signer, {}))
  out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W) }, runs(signer:upper(), {}))
  local ls = {}
  for _, l in ipairs(sig.lines or {}) do ls[#ls + 1] = l end
  ls[#ls + 1] = need_meta(meta, "phone")
  for i, l in ipairs(ls) do
    out[#out + 1] = para({ (i < #ls or meta.date) and KEEP or LINES, spacing(0, 0), ind(HALF_W, nil, 140) }, inl(l, { i = true }))
  end
  if meta.date then
    out[#out + 1] = para({ LINES, spacing(224, 0), ind(0) }, inl(meta.date, {}))
  end
  return table.concat(out)
end

-- Rule 25(a): proof of service; the wording is drafted for this template (typst certificate-of-service).
local function service(meta)
  local s = need_meta(meta, "service")
  local signer = stringify(need_meta(meta, "signature").signer)
  local out = { section_heading("Certificate of Service", true, false, true) }
  out[#out + 1] = para({ spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, runs("I certify that on ", {}) .. inl(s.date, {})
    .. runs(", I filed the foregoing " .. stringify(meta.brief_title)
      .. " with the Clerk of the Court and served it on counsel for the other party by ", {})
    .. inl(s.method, {}) .. runs(".", {}))
  out[#out + 1] = para({ KEEP, spacing(448, 0), ind(HALF_W) }, runs("s/ " .. signer, {}))
  out[#out + 1] = para({ LINES, spacing(0, 0), ind(HALF_W) }, runs(signer:upper(), {}))
  return table.concat(out)
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
    Inlines = xe.inlines,
  }).blocks
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- The text a heading's needle continues with: the start of the block after it.
local function next_text(blocks, i)
  local b = blocks[i + 1]
  if not b then return "" end
  return stringify(b):sub(1, 40)
end

-- Fails the build when a level-1 section required by Rule 28 is missing or out of order (typst check-sections).
local function check_sections(blocks)
  local heads = {}
  -- Rule 28(a)(5) (CFG.summary_may_open_argument): a summary that opens the Argument section (its first block is
  -- a sub-heading or a paragraph starting with "Summary") meets the rule as a level-1 summary section does.
  local summary_opens = false
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      heads[#heads + 1] = (stringify(b.content):lower():gsub("^%s+", ""):gsub("%s+$", ""))
      if heads[#heads] == "argument" and blocks[i + 1] then
        summary_opens = stringify(blocks[i + 1]):lower():match("^%s*summary") ~= nil
      end
    end
  end
  local required = {}
  for _, want in ipairs(CFG.required) do
    if not (want == "summary of the argument" and summary_opens and CFG.summary_may_open_argument) then
      required[#required + 1] = want
    end
  end
  local i = 1
  for _, want in ipairs(required) do
    local found = false
    while i <= #heads and not found do
      found = heads[i]:sub(1, #want) == want
      i = i + 1
    end
    if not found then fail("Vet. App. R. 28 needs a level-1 section `# " .. want .. "` in this order") end
  end
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "service" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  check_sections(doc.blocks)

  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "Page(s)")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles).
  local headings = {}
  local body = {}
  local in_arg = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level > 5 then fail("headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then in_arg = norm(stringify(b.content)) == "argument" end
      local lab = b.level == 1 and "" or label(b.level, counts[b.level], in_arg)
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", lab .. stringify(b.content), next_text(blocks, i))
      if b.level <= TOC_DEPTH then
        local point = in_arg and b.level == 2
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = stringify(b.content), step = point and 0 or step(b.level, in_arg) }
      end
      local x = heading_xml(b.level, b.content, lab, in_arg)
      -- the body opens a section (a new page): Word keeps space above there, typst drops it at the top of a page
      if #body == 0 then x = x:gsub('w:before="%d+"', 'w:before="0"', 1) end
      body[#body + 1] = raw(x)
    else
      scan_blocks({ b }, false)
      for _, x in ipairs(list_items(b)) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      fail("link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  -- the table of authorities' needle goes on with its first group title
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

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: each section starts at the page of a needle (format, prefix)
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  -- the last section is the document's own sectPr: the certificate of service, lower roman from i
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "lowerRoman", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the caption page (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): the table of contents, the table of authorities
  -- typst toc-section: the title (a section heading that is not itself listed) and "Page" over the page column
  add(raw(section_heading("Table of Contents", true, false, true)))
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, nil, 20), jc("right") }, runs("Page", { b = true, u = true })))) -- 1 pt in: LibreOffice lets the underlined word overhang its advance
  for _, it in ipairs(headings) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true, true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...) and the signature
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(section("rIdFtrPage", "decimal", 1))

  -- Section 4: the certificate of service (i); FORMBOOK_FINAL closes it
  add(raw(service(meta)))

  doc.blocks = out
  doc.meta.date = nil -- the date is printed by the signature block only, not by pandoc at the top
  doc.meta.title = nil
  return doc
end
