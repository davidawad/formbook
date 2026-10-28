-- First Circuit brief, DOCX engine (mirrors ../typst/ca1-opening-brief.typ and ../latex/ca1.lua). Pandoc filter on
-- docx/reference.docx (make-reference.sh: the shared style recipe of the cross-engine layout model). pandoc writes the
-- body text (paragraphs, quotations, lists, footnotes); this filter writes what needs Word formatting:
--   * the cover (FRAP 32(a)(2)), the disclosure statement, the table of contents, the table of authorities, the
--     signature block, the certificate of compliance (Form 6), the certificate of service and the addendum
--     (1st Cir. R. 28.0), as paragraphs with explicit spacing (exact line spacing: the typst pitches), indents and tabs;
--   * the heading labels (I., A., 1., a. in the Argument; A., 1., a., (1) elsewhere) and each heading's outline level;
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of
--     every heading and citation in that PDF (the needles this filter writes), and renders again with those pages
--     (the pages file this filter reads);
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1, 2 ...), addendum (Add-1 ...). fb render writes the footers; this filter writes the last section.
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).
-- Per-folder settings: the word limit and whether an addendum is required (as in the latex engine).

local WORD_LIMIT = 6500          -- FRAP 32(a)(7)(B) (see the typst template for the rule)
local ADDENDUM = "optional"       -- 1st Cir. R. 28.0(b)(1): not required in this brief
local TOC_DEPTH = 4    -- heading levels listed in the table of contents (typst: toc-depth)
local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local TAB = 720        -- half an inch (para-indent, label width), in twips
local TAB_R = 9360     -- the right tab of the tables: at the margin (the text width, 6.5 in)
local PNUM_TOC = 720   -- the column the contents' page numbers keep to themselves (typst toc-page-col, 36 pt)
local PNUM_TOA = 1120  -- the column of the authorities' page lists (typst toa-page-col, 56 pt)
local HALF_W = 4680    -- the middle of the text: counsel and signature blocks start here
local SINGLE = 400     -- single-spaced material (headings, cover, tables, certificates, notes): typst pitch-single, 20 pt
local DOUBLE = 628     -- body text (reference.docx Body Text): typst pitch-double, 31.4 pt (FRAP 32(a)(4))
local HEAD_SZ = 32     -- section headings: 16 pt (half points; typst heading-size)
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)

local stringify = pandoc.utils.stringify

-- The shared helpers of the cross-engine layout model (lib/docx/xengine.lua): runs with the break rules of typst,
-- paragraph properties in the schema's order, exact line spacing, the leader rows, the list items.
local xe = require("docx.xengine")

-- No break inside a token of adjacent parentheses ("32(a)(7)(B)"), as the typst template keeps it whole
-- (lib/typst/xengine.typ boxes it): Unicode line breaking allows one between ")" and "(", and LibreOffice and Word
-- take it; a word joiner (U+2060, no width, no glyph, not in the PDF text) between them forbids it.
local WJ = "\u{2060}"
local function join_parens(s)
  return (s:gsub("%)%(", ")" .. WJ .. "("))
end
-- No line break before a closing or separating mark even after a space ("her case . . .," stays whole): Unicode line
-- breaking (UAX #14, rules LB13 and LB15d), which typst follows and LibreOffice does not, has no break opportunity
-- before . , : ; ! ? ) ] } / (a period or comma before a digit excepted, LB15c). The space becomes a no-break space
-- of the same width.
local function bind_closers(l)
  local out = pandoc.Inlines({})
  for i, el in ipairs(l) do
    local nx = l[i + 1]
    if el.t == "Space" and nx and nx.t == "Str" and nx.text:match("^[%.,:;!%?%)%]}/]")
        and not nx.text:match("^[%.,:;]%d") then
      out:insert(pandoc.Str("\u{00A0}"))
    else
      out:insert(el)
    end
  end
  return out
end
local function join_inlines(l)
  return bind_closers(pandoc.Inlines(l):walk({ Str = function(s) s.text = join_parens(s.text); return s end }))
end
local function runs(text, o)
  return xe.runs(join_parens(text), o)
end
local function inl(x, o)
  if x == nil then return "" end
  if type(x) == "string" then return runs(x, o) end
  return xe.inl(join_inlines(x), o)
end
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, BR, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.BR, xe.LEAD
local list_items = xe.list_items

-- Exact line spacing; single-spaced unless another pitch is given.
local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

local function dot_tabs()
  return xe.leader_tab(TAB_R)
end

-- A horizontal rule [full-rule, short-rule]: an empty paragraph with a bottom border; `left_right` narrows it.
local function rule(kind, before, left_right)
  local b = kind == "full"
      and '<w:pBdr><w:bottom w:val="single" w:sz="8" w:space="1" w:color="000000"/></w:pBdr>'
      or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  return para({ b, spacing(before, 0, 120), ind(left_right or 0, nil, nil, left_right or 0) }, "")
end

-- A section's properties: its footer (rIdFtrNone, rIdFtrPage or rIdFtrAdd, written by fb render), page number
-- format and start, letter paper with 1 in margins (FRAP 32(a)(4)).
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="628" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (a 1 pt line: it takes no room).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local ROMAN_VALUES = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
  { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
local function roman_upper(n)
  local out = ""
  for _, v in ipairs(ROMAN_VALUES) do
    while n >= v[1] do out = out .. v[2]; n = n - v[1] end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

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
  return "00" -- the first pass: a placeholder
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Headings [style-heading]
-- ---------------------------------------------------------------------------

-- The label of a numbered heading (typst heading-label). The Argument: I. / A. / 1. / a.; elsewhere: A. / 1. / a. / (1).
local function label(level, n, arg)
  if arg then
    if level == 2 then return roman_upper(n) .. "." end
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

-- The spacing above and below each kind of heading, in twips (typst: 21 / 15.4, 16.8 / 14, 15.4 / 12.6,
-- 16.8 / 12.6 pt).
local SPACE = {
  section = { 420, 308 },
  point = { 336, 280 },
  sub = { 308, 252 },
  plain = { 336, 252 },
}

-- A section heading (level 1, the tables, the certificates): bold capitals, 16 pt, centered. `top`: the heading opens
-- a page (no space above); `brk`: it also breaks the page (not after a section break); `plain`: not in the outline.
local function section_heading(text, top, brk, plain)
  return para({ plain and "" or hstyle(1), KEEP, brk and BREAK or "", spacing(top and 0 or SPACE.section[1], SPACE.section[2]),
    ind(0, nil, 0), jc("center") }, runs(text:upper(), { b = true, sz = HEAD_SZ }))
end

-- A body heading (latex: \caonesec, \caonepoint, \caonesub).
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

-- One row of a table of contents [listing-row]: label, title, a dot leader from the end of the title and the page.
-- The title wraps before the page column (the right indent), hanging half an inch after the label's indent; the
-- right tab sits beyond it.
local function toc_row(item)
  local title = item.level == 1 and item.title:upper() or item.title
  local lead = ""
  if item.label then lead = runs(item.label .. "\t", {}) end
  return para({ LINES, dot_tabs(), spacing(item.level == 1 and 168 or 98, 0),
    ind(TAB * item.step + TAB, TAB, nil, PNUM_TOC) }, lead .. runs(title .. LEAD .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities [toa-section]
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
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
      table.sort(members, function(x, y) return x.sort < y.sort end)
      -- the group title; the first one carries the column heading "Page(s)" at the right margin
      local head = runs(g[2], { b = true })
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TAB_R .. '"/></w:tabs>',
        spacing(#out == 0 and 280 or 392, 56) }, head)
      for _, m in ipairs(members) do
        -- the distinct pages of the authority, in page order
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
        local list
        local list_w = 0
        if #pages >= PASSIM then
          list = runs("passim", { i = true })
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          local s = table.concat(l, ", ")
          list = runs(s, {})
          -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): Times New
          -- Roman digits are 0.5 em (140 twips at 14 pt), a comma and a space 0.25 em each
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 140 or 70) end
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
-- Cover [cover-body]
-- ---------------------------------------------------------------------------

local function need_meta(meta, k)
  if meta[k] == nil then error("ca1: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- Lines a text takes in a column of `chars` characters (an estimate: Times New Roman 14 pt averages about
-- 6.3 pt a character, so 6.5 in holds about 74).
local function est_lines(text, chars)
  return math.max(1, math.ceil(#stringify(text) / chars))
end

local function cover(meta)
  local sides = need_meta(meta, "caption")
  local counsel = need_meta(meta, "counsel")
  -- The gap between the cover's parts is the largest that keeps it on one page (typst: cover); the type size and
  -- line pitch never shrink. 9 in of text height = 648 pt, less a safety margin for the estimate.
  local lines = 1 + 1 + est_lines(need_meta(meta, "proceeding"), 70) + est_lines(need_meta(meta, "brief_title"), 60)
  if meta.district_court_case or meta.judge then lines = lines + 1 end
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do lines = lines + est_lines(n, 70) end
    lines = lines + 1 + (i < #sides and 1 or 0)
  end
  for _, g in ipairs(counsel) do
    for _, n in ipairs(g.names or {}) do lines = lines + est_lines(n, 32) end
    for _, l in ipairs(g.lines or {}) do lines = lines + est_lines(l, 32) end
  end
  lines = lines + 1 -- the telephone
  local free = (612 - lines * SINGLE / 20 - 6 * 6) * 20 -- twips left for the 12 gaps
  local gap = math.max(0, math.min(280, math.floor(free / 12.6)))

  local out = {}
  local function add(x) out[#out + 1] = x end
  add(para({ KEEP, spacing(math.floor(gap * 0.6), 0), jc("center") }, runs("No. ", { b = true }) .. inl(meta.case_number, { b = true })))
  add(rule("full", gap))
  add(para({ spacing(gap, 0), jc("center") }, runs(("United States Court of Appeals for the First Circuit"):upper(), { b = true })))
  add(rule("short", gap, 3240))
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do
      add(para({ spacing((i == 1 and k == 1) and gap or 98, 0), jc("center") }, inl(n, {})))
    end
    add(para({ spacing(98, 0), jc("center") }, inl(side.designation, {}))) -- centered under the names [cover-body]
    if i < #sides then
      add(para({ spacing(math.floor(gap * 0.3), math.floor(gap * 0.3)), jc("center") }, runs("v.", {})))
    end
  end
  add(rule("short", gap, 3240))
  add(para({ spacing(gap, 0), jc("center") }, inl(meta.proceeding, {})))
  if meta.district_court_case or meta.judge then
    local x = ""
    if meta.district_court_case then x = runs("D.C. No. ", {}) .. inl(meta.district_court_case, {}) end
    if meta.district_court_case and meta.judge then x = x .. runs("; ", {}) end
    if meta.judge then x = x .. inl(meta.judge, {}) end
    add(para({ spacing(98, 0), jc("center") }, x))
  end
  add(rule("short", gap, 3240))
  add(para({ spacing(gap, 0), jc("center") }, inl(meta.brief_title, { b = true, caps = true })))
  add(rule("short", gap, 3240))
  -- counsel (FRAP 32(a)(2)(F)): name, office address and telephone number, from the middle of the page
  for gi, g in ipairs(counsel) do
    local first = true
    local function cl(body, first_ind)
      add(para({ LINES, spacing(first and (gi == 1 and gap or 140) or 0, 0), ind(HALF_W, nil, first_ind) }, body))
      first = false
    end
    for _, n in ipairs(g.names or {}) do cl(inl(n, {})) end
    local ls = {}
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = l end
    if gi == #counsel then ls[#ls + 1] = need_meta(meta, "phone") end
    for _, l in ipairs(ls) do cl(inl(l, { i = true }), 140) end -- typst: half an em in
  end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Signature blocks and certificates
-- ---------------------------------------------------------------------------

-- [signature-block]: "Respectfully submitted," then 16.8 pt, the signature and the signer's lines in the right half
-- (the address lines half an em in), then 11.2 pt and the date at the margin.
local function signature(meta)
  local sig = need_meta(meta, "signature")
  local signer = stringify(need_meta(sig, "signer"))
  local out = {}
  out[#out + 1] = para({ KEEP, spacing(392, 0), ind(HALF_W) }, runs("Respectfully submitted,", {}))
  out[#out + 1] = para({ KEEP, spacing(336, 0), ind(HALF_W) }, runs("/s/ " .. signer, {}))
  out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W) }, runs(signer:upper(), {}))
  for _, l in ipairs(sig.lines or {}) do
    out[#out + 1] = para({ KEEP, spacing(0, 0), ind(HALF_W, nil, 140) }, inl(l, { i = true }))
  end
  if meta.date then
    out[#out + 1] = para({ LINES, spacing(224, 0), ind(0) }, inl(meta.date, {}))
  end
  return table.concat(out)
end

-- [form-sig-line]: the signature, "Attorney for ..." and the date in the right half, 22.4 pt below the text.
local function form_signature(meta)
  local sig = meta.signature
  local out = {}
  out[#out + 1] = para({ KEEP, spacing(448, 0), ind(HALF_W) }, runs("/s/ " .. stringify(sig.signer), {}))
  out[#out + 1] = para({ meta.date and KEEP or LINES, spacing(0, 0), ind(HALF_W) },
    runs("Attorney for ", {}) .. inl(sig["for"] or "", {}))
  if meta.date then
    out[#out + 1] = para({ LINES, spacing(0, 0), ind(HALF_W) }, runs("Dated: ", {}) .. inl(meta.date, {}))
  end
  return table.concat(out)
end

-- A numbered paragraph of a form [enum, list-indent 0.5 in]: the number in a half-inch box, the text hanging.
local function num_para(n, body)
  return para({ LINES, spacing(0, 0), ind(TAB, TAB) }, runs(n .. "\t", {}) .. body)
end

-- [check-row]: a ruled box around an X (a bordered run: no symbol font, so no fallback face) in a 22.4 pt column,
-- 22.4 pt in from the margin; the text hangs after the box; 11.2 pt above and below.
local function check_row(body)
  return para({ LINES, spacing(224, 224), ind(896, 448) }, runs("X", { box = true }) .. runs("\t", {}) .. body)
end

-- Certificate of compliance, Form 6 wording (FRAP 32(g)(1)-(2)).
local function compliance(meta, words)
  local out = { section_heading("Certificate of Compliance", true, true) }
  out[#out + 1] = num_para("1.", runs("This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) "
    .. "because, excluding the parts of the document exempted by Fed. R. App. P. 32(f):", {}))
  out[#out + 1] = check_row(runs("this document contains " .. group_digits(words) .. " words.", {}))
  out[#out + 1] = num_para("2.", runs("This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) "
    .. "and the type-style requirements of Fed. R. App. P. 32(a)(6) because:", {}))
  out[#out + 1] = check_row(runs("this document has been prepared in a proportionally spaced typeface using ", {})
    .. inl(need_meta(meta, "word_processor"), {}) .. runs(" in 14-point ", {}) .. inl(need_meta(meta, "typeface"), {})
    .. runs(" roman type.", {}))
  out[#out + 1] = form_signature(meta)
  return table.concat(out)
end

-- Certificate of service: only when `service.certificate: true` (1st Cir. R. 25.0(e)).
local function service(meta)
  local svc = meta.service or {}
  local out = { section_heading("Certificate of Service", true, true) }
  out[#out + 1] = para({ spacing(0, 280), ind(0) }, runs("I hereby certify that on ", {})
    .. inl(meta.date or "__________", {}) .. runs(", I electronically filed the foregoing with the Clerk of the Court "
    .. "for the United States Court of Appeals for the First Circuit by using the appellate CM/ECF system, which will "
    .. "send notification of such filing to all counsel of record.", {}))
  if svc.unregistered and #svc.unregistered > 0 then
    out[#out + 1] = para({ spacing(0, 280), ind(0) }, runs("I further certify that on the same date I served the "
      .. "foregoing by mail on the following persons who are not registered for electronic filing:", {}))
    for _, u in ipairs(svc.unregistered) do
      out[#out + 1] = para({ LINES, spacing(196, 0), ind(TAB) }, inl(u.name, {}) .. runs(", ", {}) .. inl(u.address, {}))
    end
  end
  out[#out + 1] = form_signature(meta)
  return table.concat(out)
end

-- The disclosure statement (FRAP 26.1; in front of the table of contents).
local function disclosure(meta)
  return section_heading("Disclosure Statement", true, false, true)
    .. para({ spacing(0, 280), ind(0) }, inl(meta.disclosure, {}))
end

-- ---------------------------------------------------------------------------
-- Word count: as the typst template counts (the same number in every engine)
-- ---------------------------------------------------------------------------

-- Words in a block, footnotes included. A note becomes a space; Unicode spaces split words as typst's \s does.
local block_words
local function block_words_of(b)
  local text = {}
  local plain = pandoc.Blocks({ b }):walk({ Note = function(nt)
    text[#text + 1] = stringify(nt.content)
    return pandoc.Space()
  end })
  table.insert(text, 1, stringify(plain))
  local n = 0
  for _, s in ipairs(text) do
    s = s:gsub("\194\160", " "):gsub("\226\128\137", " "):gsub("\226\128\175", " ")
    for _ in s:gmatch("%S+") do n = n + 1 end
  end
  return n
end
-- Lists and quotations are counted item by item (stringify would run the items together).
block_words = function(b)
  if b.t == "BulletList" or b.t == "OrderedList" then
    local n = 0
    if b.t == "OrderedList" and b.listAttributes.style ~= "Decimal" then n = #b.content end
    for _, item in ipairs(b.content) do
      for _, c in ipairs(item) do n = n + block_words(c) end
    end
    return n
  elseif b.t == "BlockQuote" then
    local n = 0
    for _, c in ipairs(b.content) do n = n + block_words(c) end
    return n
  end
  return block_words_of(b)
end

-- The oral-argument statement is excluded (FRAP 32(f)).
local function count_words(blocks)
  local n = 0
  local skipping = false
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      skipping = stringify(b.content):lower():find("oral argument", 1, true) ~= nil
    end
    if not skipping then n = n + block_words(b) end
  end
  return n
end

-- Roman and letter lists are paragraphs with their label as text ("II. Whether ..."), as typst reads them.
local function unlist(l)
  local style_ = l.listAttributes.style
  if style_ == "Decimal" then return nil end
  local blocks = {}
  for i, item in ipairs(l.content) do
    local n = l.listAttributes.start + i - 1
    local lab
    if style_ == "LowerRoman" then lab = roman_upper(n):lower()
    elseif style_ == "UpperRoman" then lab = roman_upper(n)
    elseif style_ == "LowerAlpha" then lab = string.char(96 + n)
    else lab = string.char(64 + n) end
    lab = lab .. "."
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local c = pandoc.Inlines({ pandoc.Str(lab), pandoc.Space() })
      c:extend(first.content)
      item[1] = pandoc.Para(c)
    end
    for _, b in ipairs(item) do blocks[#blocks + 1] = b end
  end
  return blocks
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
    Inlines = function(l) return join_inlines(xe.inlines(l)) end,
  }).blocks
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- The text a heading's needle continues with: the start of the block after it (a heading with its label, as printed).
local printed = {} -- index in the body -> a heading's printed text
local function next_text(blocks, i, labelled)
  local b = blocks[i + 1]
  if not b then return "" end
  return ((labelled and printed[i + 1]) or stringify(b)):sub(1, 40)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature",
      "word_processor", "typeface" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}

  -- the body and the addendum
  local body_in, add_in, has_add = {}, {}, false
  for _, b in ipairs(doc.blocks) do
    if not has_add and b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "addendum" then
      has_add = true
    elseif has_add then
      add_in[#add_in + 1] = b
    else
      body_in[#body_in + 1] = b
    end
  end
  if not has_add and ADDENDUM == "required" then
    error("ca1: 1st Cir. R. 28.0(a)(1) requires an addendum with the order or decision appealed from; add a `# Addendum` section")
  end
  local words = count_words(body_in)
  if words > WORD_LIMIT then
    error("ca1: the brief has " .. words .. " words; FRAP 32(a)(7)(B) allows " .. WORD_LIMIT)
  end
  body_in = pandoc.Blocks(body_in):walk({ OrderedList = unlist })
  add_in = pandoc.Blocks(add_in):walk({ OrderedList = unlist })

  if meta.disclosure then need("S:ds", "B", "Disclosure Statement", stringify(meta.disclosure)) end
  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "Page(s)")

  -- The body, in order: headings (labels, outline, needles, contents entries) and citations (needles).
  local headings = {}
  local body = {}
  local in_arg = false
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n = 0
  local labs = {}
  local last_list = nil -- the body's last block when it is a list (kept with the signature)
  for i, b in ipairs(body_in) do
    if b.t == "Header" then
      if b.level > 5 then error("ca1: headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then
        local t = stringify(b.content):lower()
        in_arg = t == "argument" or t == "reply argument"
      end
      labs[i] = { b.level == 1 and "" or label(b.level, counts[b.level], in_arg), in_arg }
      printed[i] = labs[i][1] .. " " .. stringify(b.content)
    end
  end
  for i, b in ipairs(body_in) do
    if b.t == "Header" then
      local lab = labs[i][1]
      in_arg = labs[i][2]
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", lab .. stringify(b.content), next_text(body_in, i, true))
      if b.level <= TOC_DEPTH then
        local point = in_arg and b.level == 2
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = stringify(b.content), step = (point or b.level == 1) and 0 or step(b.level, in_arg) }
      end
      local x = heading_xml(b.level, b.content, lab, in_arg)
      -- the body opens a section (a new page): Word keeps space above there, typst drops it at the top of a page
      if #body == 0 then x = x:gsub('w:before="%d+"', 'w:before="0"', 1) end
      body[#body + 1] = raw(x)
    else
      scan_blocks({ b }, false)
      local xs = list_items(b)
      if i == #body_in and xs[1] ~= b then last_list = b end
      for _, x in ipairs(xs) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("ca1: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  -- the table of authorities' needle goes on with its first group title (the contents list the same title)
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
  -- The last paragraph, or every item of a last list, stays with the signature block (typst: the tail block is kept
  -- with the signature).
  local last = body[#body]
  if last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  elseif last_list and not has_note(last_list) then
    local items = {}
    local n = last_list.t == "OrderedList" and last_list.listAttributes.start or 1
    local delim = last_list.t == "OrderedList" and last_list.listAttributes.delimiter or "Period"
    for _, item in ipairs(last_list.content) do
      if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then items = nil; break end
      local lab = "\u{2022}"
      if last_list.t == "OrderedList" then
        lab = delim == "OneParen" and (n .. ")") or delim == "TwoParens" and ("(" .. n .. ")") or (n .. ".")
      end
      local content = strip_links({ pandoc.Plain(item[1].content) })[1].content
      items[#items + 1] = raw(para({ style("ListItem"), KEEP }, runs(lab .. "\t", {}) .. inl(content, {})))
      n = n + 1
    end
    if items then
      for _ = 1, #last_list.content do body[#body] = nil end
      for _, x in ipairs(items) do body[#body + 1] = x end
    end
  end

  local svc = meta.service and meta.service.certificate
  local with_service = svc == true or (svc ~= nil and stringify(svc) == "true")
  need("H:compliance", "B", "Certificate of Compliance", "1. This document complies")
  if with_service then need("H:service", "B", "Certificate of Service", "I hereby certify") end

  -- The addendum: unnumbered headings; its level-2 headings are listed in its own contents.
  local add_items, add_body = {}, {}
  if has_add then
    need("S:add", "B", "Addendum", "Table of Contents")
    for i, b in ipairs(add_in) do
      if b.t == "Header" then
        if b.level ~= 2 then error("ca1: the addendum may only use level-2 headings") end
        local id = "A:" .. i
        add_items[#add_items + 1] = { id = id, title = stringify(b.content) }
        need(id, "B", stringify(b.content), next_text(add_in, i))
        add_body[#add_body + 1] = raw(para({ hstyle(2), KEEP, spacing(SPACE.plain[1], SPACE.plain[2]), ind(0, nil, 0) },
          inl(b.content, { b = true })))
      else
        scan_blocks({ b }, false)
        for _, x in ipairs(list_items(b)) do add_body[#add_body + 1] = x end
      end
    end
    add_body = strip_links(add_body)
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: each section starts at the page of a needle (format, prefix)
  nl[#nl + 1] = "#section\t" .. (meta.disclosure and "S:ds" or "S:toc") .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  if has_add then nl[#nl + 1] = "#section\tS:add\tdecimal\tAdd-" end
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  -- the last section is the document's own sectPr: arabic from 1, or Add-1 when the addendum ends the brief
  write_file("FORMBOOK_FINAL", sect_pr(has_add and "rIdFtrAdd" or "rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the front matter (i, ii ...): the disclosure statement, the table of contents, the table of authorities
  if meta.disclosure then add(raw(disclosure(meta))) end
  -- [toc-section]: the title (a section heading that is not itself listed) and "Page" over the page column
  add(raw(section_heading("Table of Contents", true, meta.disclosure ~= nil, true)))
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, nil, 20), jc("right") }, runs("Page", { b = true, u = true })))) -- 1 pt in: LibreOffice lets the underlined word overhang its advance
  local items = { { id = "S:toa", level = 1, step = 0, title = "Table of Authorities" } }
  for _, h in ipairs(headings) do items[#items + 1] = h end
  items[#items + 1] = { id = "H:compliance", level = 1, step = 0, title = "Certificate of Compliance" }
  if with_service then items[#items + 1] = { id = "H:service", level = 1, step = 0, title = "Certificate of Service" } end
  if has_add then items[#items + 1] = { id = "S:add", level = 1, step = 0, title = "Addendum" } end
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Authorities", true, true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...), the signature, and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(compliance(meta, words)))
  if with_service then add(raw(service(meta))) end

  -- Section 4: the addendum (Add-1 ...), with its own contents; FORMBOOK_FINAL closes it with the last section's footer
  if has_add then
    add(section("rIdFtrPage", "decimal", 1))
    add(raw(section_heading("Addendum", true)))
    add(raw(section_heading("Table of Contents", false, false, true)))
    for _, it in ipairs(add_items) do
      add(raw(toc_row({ id = it.id, level = 2, step = 0, title = it.title })))
    end
    -- the items start on the page after the addendum's contents (typst and latex do the same)
    if add_body[1] and add_body[1].t == "RawBlock" then
      -- Word keeps the space above a paragraph that breaks the page; typst drops it at the top of a page
      local x = add_body[1].text:gsub("<w:keepLines/>", "<w:keepLines/>" .. BREAK, 1):gsub('w:before="%d+"', 'w:before="0"', 1)
      add_body[1] = raw(x)
    else
      add(raw(para({ BREAK, spacing(0, 0, 20) }, "")))
    end
    for _, x in ipairs(add_body) do add(x) end
  end

  doc.blocks = out
  doc.meta = pandoc.Meta({}) -- the frontmatter is on the page already; no pandoc title block
  return doc
end
