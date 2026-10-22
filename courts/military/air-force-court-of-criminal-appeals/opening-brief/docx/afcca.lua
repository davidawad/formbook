-- AFCCA brief, DOCX engine (docs/DOCX.md): the markdown sample -> a Word document on reference.docx (built by
-- docx/make-reference.sh with the shared style recipe), to the form of typst/afcca-opening-brief.typ. Identical in
-- the opening-brief and answering-brief folders.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): the typst render is
-- the reference, and every paragraph this filter writes carries exact line spacing at the typst pitches and the
-- typst spaces in twips (pt x 20), so Word and LibreOffice break every line and page where typst does. pandoc
-- writes the body text (paragraphs, quotations, footnotes) on the reference's Body Text, Block Text and Footnote
-- Text styles; this filter writes the rest:
--   caption page (court line, caption table, counsel block, and the TO THE HONORABLE line when not indexed);
--   with `index: true`: a section break, the table of contents and the table of authorities (lower-case roman
--   pages, the caption page unnumbered), a section break, then the body from page 1;
--   the body headings (numbered I./A./1./a. in the roman sections, as typst computes them), the signature block,
--   and the certificate on a new page.
-- Page numbers in the two tables: fb render's multi-pass build (tools/fb/src/docxpass.rs, docxpages.rs) finds the
-- page of every heading and citation (the needles written to $FORMBOOK_NEEDLES) in the LibreOffice PDF and renders
-- again with them ($FORMBOOK_PAGES) until they settle. The footers (rIdFtrNone, rIdFtrPage) are fb render's; the
-- last section is written to $FORMBOOK_FINAL. Word may paginate slightly differently from LibreOffice.

local xe = require("docx.xengine")
local runs, inl, para, raw, ind, jc = xe.runs, xe.inl, xe.para, xe.raw, xe.ind, xe.jc
local KEEP, LINES, BREAK, BR, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.BR, xe.LEAD
local stringify = pandoc.utils.stringify

local ROMAN = {
  ["assignments of error"] = true, ["assignment of error"] = true, ["issues presented"] = true,
  ["argument"] = true, ["additional arguments"] = true, ["reply argument"] = true,
}
local CHAINED = { ["assignments of error"] = true, ["assignment of error"] = true, ["issues presented"] = true }
local UNNUMBERED = {
  ["standard of review"] = true, ["law and analysis"] = true, ["law & analysis"] = true, ["additional facts"] = true,
}
local COURT = "IN THE UNITED STATES AIR FORCE COURT OF CRIMINAL APPEALS"
local HONORABLE = "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES AIR FORCE COURT OF CRIMINAL APPEALS:"
local TOC_DEPTH = 4
local PASSIM = 7          -- typst passim-threshold: an authority cited on this many pages or more
local TAB = 720           -- heading-tab, para-indent: half an inch
local TEXT_W = 9360       -- the text width, 6.5 in: the right tab of the tables
local PNUM_TOC = 624      -- typst toc-page-col (31.2 pt)
local PNUM_TOA = 1120     -- typst toa-page-col (56 pt)
local SIG = 4320          -- typst sig-indent (3 in)
local SINGLE = 294        -- typst pitch-single (14.7 pt)
local BODY = 492          -- typst pitch-body (24.6 pt)
-- typst: the spaces above and below each kind of heading (16.8/12, 14.4/12, 14.4/12, 13.2/10.8 pt)
local SPACE = { section = { 336, 240 }, front = { 288, 240 }, point = { 288, 240 }, sub = { 264, 216 } }
local CAP_GAP, CAP_STEP, CAP_SKIP, COUNSEL_AFTER = 384, 72, 360, 144
local NEEDLE_MAX = 60

local function spacing(before, after, line) return xe.spacing(before, after, line or SINGLE) end
local function outline(n) return '<w:outlineLvl w:val="' .. n .. '"/>' end

local function need(meta, key)
  if meta[key] == nil then error("afcca.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render's multi-pass build)
-- ---------------------------------------------------------------------------

local function norm(s) return (s:lower():gsub("[^a-z0-9]", "")) end

local needles = {}
local function opening(text)
  local out = ""
  for w in text:gmatch("%S+") do
    out = out .. norm(w)
    if #out >= 8 then break end
  end
  return out:sub(1, NEEDLE_MAX)
end
local function add_needle(id, kind, text, context)
  local short = opening(text)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

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
-- Sections
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

-- ---------------------------------------------------------------------------
-- Headings (typst style-heading, heading-label)
-- ---------------------------------------------------------------------------

local function roman_upper(n)
  local out = ""
  for _, p in ipairs({ { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function label_for(level, n)
  if level == 2 then return roman_upper(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return tostring(n) .. "." end
  if level == 5 then return string.char(96 + n) .. "." end
  error("afcca.lua: headings deeper than level 5 are not supported")
end

-- A centered bold title (the TOC, TOA and certificate titles): it opens a page, so no space above.
local function front_title(text, brk)
  return para({ KEEP, brk and BREAK or "", spacing(0, SPACE.front[2]), ind(0, nil, 0), jc("center"), outline(0) },
    runs(text, { b = true }))
end

local function heading_xml(level, content, lab, roman_sec, chained)
  if level == 1 then
    return para({ KEEP, spacing(SPACE.section[1], SPACE.section[2]), ind(0, nil, 0), jc("center"), outline(0) },
      inl(content, { b = true }))
  end
  local a, b = SPACE.sub[1], SPACE.sub[2]
  if not lab then
    return para({ KEEP, spacing(a, b), ind(0, nil, 0), roman_sec and jc("center") or "", outline(level - 1) },
      inl(content, { b = true }))
  end
  if level == 2 then
    return para({ chained and LINES or KEEP, spacing(SPACE.point[1], SPACE.point[2]), ind(0, nil, 0), jc("center"),
      outline(1) }, runs(lab, { b = true }) .. BR .. inl(content, { b = true }))
  end
  local o = { b = true, i = level >= 4 }
  local step = (level - 2) * TAB
  return para({ KEEP, spacing(a, b), ind(step + TAB, TAB), outline(level - 1) },
    runs(lab .. "\t", { b = true }) .. inl(content, o))
end

-- One row of the tables (typst listing-row): the text wraps before the page column (the right indent), three
-- no-break spaces and a dot leader run to the page at the right margin.
local function row(props_before, left, hanging, col, body, page)
  return para({ LINES, xe.leader_tab(TEXT_W), spacing(props_before, 0), ind(left, hanging, nil, col) },
    body .. runs(LEAD, {}) .. page)
end

-- ---------------------------------------------------------------------------
-- Table of authorities
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local occurrences = {} -- the authority links, in document order: { key, index }

local function sort_key(a)
  local s = a.sort and stringify(a.sort) or ((a.name and stringify(a.name) or "") .. " " .. stringify(a.cite))
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
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TEXT_W .. '"/></w:tabs>',
        spacing(#out == 0 and 240 or 336, 48), ind(0, nil, 0) }, head)
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
          list = runs(s, {})
          -- a list wider than the column widens it (typst: the larger of 56 pt and the list): Times New Roman
          -- digits are 0.5 em (120 twips at 12 pt), a comma and a space 0.25 em each
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 120 or 60) end
        end
        local name = ""
        if m.a.name then name = inl(m.a.name, { i = g[1] == "case" }) .. runs(",", {}) .. BR end
        out[#out + 1] = row(168, 504, 504, math.max(PNUM_TOA, list_w), name .. inl(m.a.cite, {}), list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Caption page (typst caption-page)
-- ---------------------------------------------------------------------------

local function cell(width, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. table.concat(paras) .. "</w:tc>"
end

local function caption_page(meta, index)
  local out = {}
  out[#out + 1] = para({ KEEP, spacing(0, CAP_GAP), ind(0, nil, 0), jc("center") }, runs(COURT, { b = true }))
  local lhs, paren, rhs = {}, {}, {}
  local function left(body, indent)
    local before = #lhs == 0 and 0 or CAP_STEP
    lhs[#lhs + 1] = para({ spacing(before, 0), ind(indent or 0, nil, 0) }, body)
    paren[#paren + 1] = para({ spacing(before, 0), ind(0, nil, 0), jc("center") }, runs(")", {}))
  end
  for i, side in ipairs(need(meta, "caption")) do
    if i > 1 then left(runs("v.", {}), 1296) end
    for _, n in ipairs(side.names) do left(inl(n, {})) end
    left(inl(side.designation, {}), 2304)
  end
  for i, v in ipairs({ { need(meta, "brief_title"), { b = true } }, { need(meta, "panel"), {} },
    { need(meta, "case_number"), {} }, { need(meta, "date"), {} } }) do
    rhs[#rhs + 1] = para({ spacing(i == 1 and 0 or CAP_SKIP, 0), ind(0, nil, 0) }, inl(v[1], v[2]))
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="8856" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="504"/><w:gridCol w:w="3456"/></w:tblGrid>'
    .. "<w:tr>" .. cell(4896, lhs) .. cell(504, paren) .. cell(3456, rhs) .. "</w:tr></w:tbl>"
  local before = CAP_GAP
  if meta.counsel then
    for _, group in ipairs(meta.counsel) do
      local lines = {}
      for _, line in ipairs(group) do lines[#lines + 1] = inl(line, {}) end
      out[#out + 1] = para({ spacing(before, COUNSEL_AFTER), ind(936, nil, 0, 936), jc("center") },
        table.concat(lines, BR))
      before = 0
    end
  end
  if not index then
    out[#out + 1] = para({ KEEP, spacing(before, 0), ind(0, nil, 0), jc("center") }, runs(HONORABLE, { b = true }))
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block)
-- ---------------------------------------------------------------------------

local function signature(sig, closing)
  local out = {}
  if closing ~= "" then
    out[#out + 1] = para({ KEEP, spacing(240, 0), ind(SIG, nil, 0) }, runs(closing, {}))
  end
  local body = inl(sig.signer, { b = true })
  for _, line in ipairs(sig.lines or {}) do body = body .. BR .. inl(line, {}) end
  out[#out + 1] = para({ LINES, spacing(closing ~= "" and 528 or 240, 0), ind(SIG, nil, 0) }, body)
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
      add_needle("T:" .. #occurrences, in_note and "N" or "B", stringify(el.content), stringify(rest))
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
    Link = function(el) return el.content end,
    Inlines = xe.inlines,
  }).blocks
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  local index = meta.index == true
  local authorities = meta.authorities or {}
  local sig, cert = meta.signature, meta.certificate

  if index then
    add_needle("S:cap", "B", COURT)
    add_needle("S:honor", "B", HONORABLE)
  end

  -- the body: headings (labels as typst computes them, contents entries, needles) and citations (needles)
  local counters = { 0, 0, 0, 0, 0, 0 }
  local roman_sec, cur_sec = false, ""
  local heads, body = {}, {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local L = b.level
      if L > 5 then error("afcca.lua: headings deeper than level 5 are not supported") end
      local key = stringify(b.content):lower():gsub("^%s+", ""):gsub("%s+$", "")
      for k = L + 1, 6 do counters[k] = 0 end
      local unnum = UNNUMBERED[key] == true
      if L == 1 then roman_sec = ROMAN[key] == true; cur_sec = key end
      if not unnum then counters[L] = counters[L] + 1 end
      local lab = nil
      if L >= 2 and roman_sec and not unnum then lab = label_for(L, counters[L]) end
      local id = "H:" .. i
      local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
      add_needle(id, "B", (lab or "") .. " " .. stringify(b.content), nxt)
      if L <= TOC_DEPTH then heads[#heads + 1] = { id = id, level = L, label = lab, content = b.content } end
      body[#body + 1] = raw(heading_xml(L, b.content, lab, roman_sec, CHAINED[cur_sec]))
    else
      scan_blocks({ b }, false)
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if authorities[o.key] == nil then
      error("afcca.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  body = strip_links(body)

  local out = {}
  local function add(x) out[#out + 1] = x end
  add(raw(caption_page(meta, index)))

  if index then
    add(section("rIdFtrNone"))
    -- the table of contents (typst toc-section)
    local x = { front_title("Table of Contents"),
      para({ KEEP, spacing(72, 180), ind(0, nil, nil, 20), jc("right") }, runs("Page", { b = true, u = true })) }
    for _, h in ipairs(heads) do
      local step = h.level >= 2 and (h.level - 2) * TAB or 0
      local lead = h.label and runs(h.label .. "\t", {}) or ""
      -- the first line starts at the label's indent (a hanging indent of one tab), the rest hang under the title
      x[#x + 1] = row(h.level == 1 and 144 or 84, step + TAB, TAB, PNUM_TOC, lead .. inl(h.content, {}),
        runs(label_of(h.id), {}))
    end
    -- the table of authorities (typst toa-section)
    x[#x + 1] = front_title("Table of Authorities", true)
    x[#x + 1] = toa_rows(authorities)
    add(raw(table.concat(x)))
    add(section("rIdFtrPage", "lowerRoman", 2))
    add(raw(para({ KEEP, spacing(0, 0), ind(0, nil, 0), jc("center") }, runs(HONORABLE, { b = true }))))
  end

  for _, b in ipairs(body) do add(b) end
  if sig ~= nil then
    local closing = sig.closing and stringify(sig.closing) or "Respectfully submitted,"
    add(raw(signature(sig, closing)))
  end
  if cert ~= nil then
    add(raw(front_title("Certificate of Filing and Service", true)
      .. para({ spacing(0, 0, BODY), ind(0, nil, TAB) },
        runs("I certify that the original and copies of the foregoing were ", {}) .. inl(cert.method, {})
        .. runs(" to the Court and served on ", {}) .. inl(cert.recipient, {}) .. runs(" on ", {})
        .. inl(cert.date, {}) .. runs(".", {}))
      .. signature(cert, "")))
  end

  if index then
    local nl = {}
    for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
    -- the caption page is i (unnumbered), the front matter ii, iii; the body is numbered from 1
    nl[#nl + 1] = "#section\tS:cap\tlower-roman\t"
    nl[#nl + 1] = "#section\tS:honor\tdecimal\t"
    write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  end
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  -- No break inside a token of adjacent parentheses ("922(g)(7)"): typst boxes it (lib/typst/xengine.typ),
  -- LibreOffice would break between ")" and "(" (Unicode line breaking allows it); a word joiner forbids it.
  local function wj(s) return (s:gsub("%)%(", ")\u{2060}(")) end
  doc.blocks = pandoc.Blocks(out):walk({
    Str = function(el) el.text = wj(el.text); return el end,
    RawBlock = function(el) el.text = wj(el.text); return el end,
  })
  doc.meta = pandoc.Meta({})
  return doc
end
