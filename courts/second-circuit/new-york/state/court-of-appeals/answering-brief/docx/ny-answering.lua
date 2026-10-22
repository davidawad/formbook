-- New York Court of Appeals answering brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document in
-- the form of typst/ny-answering-brief.typ, on the styles of docx/reference.xml (fb render builds reference.docx).
-- pandoc writes the body text (paragraphs, quotations, lists, footnotes); this filter writes what needs Word
-- formatting: the cover, the disclosure statement, the table of contents (its pages: fb render renders the document,
-- finds the page of every heading in the LibreOffice PDF from the needles written here, and renders again with
-- them), the table of authorities (no page references, as in the typst template: known gap), the headings, the
-- signature block and the certificates; and the sections: cover (no number), front matter (ii, iii ...), body and
-- certificates (1, 2 ...). fb render writes the footers; the last section goes to FORMBOOK_FINAL.
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the shared Word model lib/docx/xengine.lua, exact line
-- spacing throughout (Word sets each line in a box of that height, the baseline at 0.8 of it), the typst template's
-- pitches and spaces in twips (20 x pt). Nothing here is case-specific.

local stringify = pandoc.utils.stringify
local xe = require("docx.xengine")
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK = xe.KEEP, xe.LINES, xe.BREAK

local TAB = 720        -- half an inch (para-indent), in twips
local SINGLE = 380     -- typst pitch-single (19 pt)
local DOUBLE = 628     -- typst pitch-double (31.4 pt)
-- The text width is typst's, 6.5 in (no right pad: a sample line typst fills to within 0.07 pt fits LibreOffice there,
-- whose glyph advances come out a hair narrower; with the 4 twips ca3 adds it moved a word on).
local RIGHT_PAD = 0
local TEXT_W = 9360 - RIGHT_PAD
local TAB_R = TEXT_W   -- the right tab of the contents: at the margin
local PNUM_TOC = 720   -- typst toc-col (36 pt)
local SIG = 4680       -- typst sig-indent (3.25 in)
local GUTTER = 432     -- typst: the cover's counsel columns, 0.3 in apart
local COVER_GAPS = { 4.4, 4, 3.6, 3.2, 2.8, 2.4, 2, 1.6, 1.3, 1, 0.8, 0.6, 0.4, 0.2, 0 } -- typst cover-gaps (single lines)
local NEEDLE_MAX = 60

local function tw(pt) return math.floor(pt * 20 + 0.5) end

-- ---------------------------------------------------------------------------
-- Break rules typst keeps (lib/typst/xengine.typ and the template) that LibreOffice does not
-- ---------------------------------------------------------------------------

-- No break inside a token of adjacent parentheses ("120.10(1)(a)"): a word joiner; a break after a slash before a
-- letter ("f/k/a"), as typst breaks there: a zero-width space.
local WJ, ZWSP = "\u{2060}", "\u{200B}"
local function fix_text(s)
  s = s:gsub("%)%(", ")" .. WJ .. "(")
  s = s:gsub("/(%a)", "/" .. ZWSP .. "%1")
  return s
end
-- A doubled section sign stays with its number ("§§ 110.00"; the template boxes "[§¶]+ \S+"; xe binds a single one).
local function bind_doubled(l)
  local out = pandoc.Inlines({})
  for i, el in ipairs(l) do
    local prev = l[i - 1]
    if el.t == "Space" and prev and prev.t == "Str" and prev.text:match("[\u{00A7}\u{00B6}]$") then
      out:insert(pandoc.Str("\u{00A0}"))
    else
      out:insert(el)
    end
  end
  return out
end
local function fix_inlines(l)
  l = bind_doubled(l)
  return l:walk({ Str = function(el) el.text = fix_text(el.text); return el end })
end
local function runs(text, o) return xe.runs(fix_text(text), o) end
local function inl(x, o)
  if type(x) == "string" then return runs(x, o) end
  if x ~= nil and type(x) == "table" and x.walk then x = fix_inlines(x) end
  return xe.inl(x, o)
end

local function spacing(before, after, line) return xe.spacing(before, after, line or SINGLE) end

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render, tools/fb/src/docxpass.rs and docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s) return (s:lower():gsub("[^a-z0-9]", "")) end

local needles = {}
local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, "B", long, short:sub(1, NEEDLE_MAX) }, "\t")
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, label = line:match("^([^\t]+)\t[^\t]*\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end
local function label_of(id) return labels[id] or "00" end -- the first pass: a placeholder of the final width

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function need_meta(meta, key)
  local v = meta[key]
  if v == nil then error("ny-answering: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- typst's count-words on the body markdown: footnote definitions removed, then whitespace-delimited tokens
local function body_words(body)
  local s = ("\n" .. body):gsub("\n%[%^[^%]]+%]:[^\n]*", "\n")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

-- the markdown after the frontmatter
local function body_markdown()
  local f = PANDOC_STATE.input_files[1] and io.open(PANDOC_STATE.input_files[1], "r")
  if not f then error("ny-answering: cannot read the input file to count its words", 0) end
  local text = f:read("a")
  f:close()
  local _, e = text:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if not e then error("ny-answering: the sample must start with a YAML frontmatter block", 0) end
  return text:sub(e + 1)
end

-- the section's properties: footer (rIdFtrNone / rIdFtrPage, written by fb render), page number format and start,
-- letter paper with one-inch margins (500.1(l))
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="' .. (1440 + RIGHT_PAD)
    .. '" w:bottom="1440" w:left="1440" w:header="720" w:footer="644" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- the paragraph that ends a section (1 pt high: it must not push a full page's last line on)
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

-- typst line-par: one single-spaced paragraph
local function line_par(x, before, align, left, keep)
  return para({ keep or KEEP, spacing(before or 0, 0), ind(left or 0, nil, 0), align and jc(align) or "" }, x)
end

-- typst page-heading: bold, centred, 14 pt above the text, at the top of its page
local function page_heading(text, brk)
  return para({ KEEP, brk and BREAK or "", spacing(0, 280), ind(0, nil, 0), jc("center") }, runs(text, { b = true }))
end

-- typst double-spaced: a body paragraph
local function text_para(x)
  return para({ spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, x)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body)
-- ---------------------------------------------------------------------------

-- The height of cover paragraphs, estimated (twips): the space above and the lines of each, a line holding about
-- (width / 150 twips) characters (0.54 em at 14 pt: a little wider than the average letter, so the estimate is safe).
local function height(xml, width)
  local h = 0
  for p in xml:gmatch("<w:p>.-</w:p>") do
    local before = tonumber(p:match('w:before="(%d+)"') or "0")
    local text = ""
    for t in p:gmatch("<w:t[^>]*>([^<]*)</w:t>") do text = text .. t end
    h = h + before + math.max(1, math.ceil(utf8.len(text) * 150 / width)) * SINGLE
  end
  return h
end

local function upper_inlines(l)
  return l:walk({ Str = function(el) el.text = el.text:upper(); return el end })
end

local function cover_body(meta, g)
  local gap = g * SINGLE
  local out, h = {}, 0
  local function add(x, width)
    out[#out + 1] = x
    h = h + height(x, width or TEXT_W)
  end
  local function c(x, before) add(line_par(x, tw(before or 0) // 1, "center")) end
  local gp = g * 19 -- the gap in pt
  if meta.argued_by then
    add(line_par(runs("To be argued by:", {}), 0, "right"))
    add(line_par(inl(meta.argued_by, {}), 0, "right"))
  end
  c(runs("Court of Appeals", { b = true }), meta.argued_by and gp or 0)
  c(runs("of the State of New York", { b = true }))
  c(inl(need_meta(meta, "apl_docket"), {}), gp)
  if meta.county_clerk_index then c(inl(meta.county_clerk_index, {})) end
  local sides = need_meta(meta, "caption")
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do
      c(inl(n, {}), k > 1 and 0 or (i == 1 and gp or 8.4 + gp / 4))
    end
    c(inl(side.designation, {}), 4.2)
    if i < #sides then c(runs("\u{2013}against\u{2013}", { i = true }), 8.4 + gp / 4) end
  end
  c(inl(upper_inlines(pandoc.Inlines(need_meta(meta, "brief_title"))), { b = true }), gp)
  if meta.proceeding then c(inl(meta.proceeding, {}), gp / 2) end
  -- counsel, side by side: a borderless table of equal columns 0.3 in apart (typst grid)
  local groups = need_meta(meta, "counsel")
  local n = #groups
  local cw = (9360 - (n - 1) * GUTTER) // n
  local cells, rows_h = {}, 0
  for gi, grp in ipairs(groups) do
    local xs = {}
    for _, nm in ipairs(grp.names or {}) do xs[#xs + 1] = line_par(inl(nm, {}), 0, nil, 0, LINES) end
    for _, l in ipairs(grp.lines or {}) do xs[#xs + 1] = line_par(inl(l, { i = true }), 0, nil, 0, LINES) end
    if #xs == 0 then xs[1] = para({ spacing(0, 0) }, "") end
    local x = table.concat(xs)
    rows_h = math.max(rows_h, height(x, cw))
    local right = gi < n and GUTTER or 0
    cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. (cw + right) .. '" w:type="dxa"/><w:tcMar><w:left w:w="0" w:type="dxa"/>'
      .. '<w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. x .. "</w:tc>"
  end
  local grid = {}
  for gi = 1, n do grid[#grid + 1] = '<w:gridCol w:w="' .. (cw + (gi < n and GUTTER or 0)) .. '"/>' end
  -- the space above the table: an empty paragraph 1 pt high, the gap above it
  out[#out + 1] = para({ KEEP, spacing(math.max(0, tw(gp) - 20), 0, 20) }, "")
  h = h + math.max(20, tw(gp))
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>'
    .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
  h = h + rows_h
  add(line_par(inl(need_meta(meta, "phone"), {}), 224))
  if meta.fax then add(line_par(inl(meta.fax, {}))) end
  if meta.date then add(line_par(inl(meta.date, {}), 112, nil, 0, LINES)) end
  return out, h
end

-- The cover is one page (typst: the largest gap at which it fits): the largest gap whose estimated height fits.
local function cover(meta)
  for _, g in ipairs(COVER_GAPS) do
    local out, h = cover_body(meta, g)
    if h <= 12960 or g == 0 then return table.concat(out) end
  end
end

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

-- One row of the table of contents (typst listing-row): the title wraps before the page column (the right indent),
-- a dot leader from the end of the title to the page, on the right tab beyond the indent. Before the tab: two
-- no-break spaces at 12.5 pt (LibreOffice keeps the last word on the line only if they and a third of their em fit
-- before the right indent: 10.4 pt, for typst's 0.75 em = 10.5 pt).
local LEAD = '<w:r><w:rPr><w:sz w:val="25"/><w:szCs w:val="25"/></w:rPr><w:t xml:space="preserve">\u{00A0}\u{00A0}</w:t></w:r><w:r><w:tab/></w:r>'
local function toc_row(h)
  local left = (h.level - 1) * TAB
  return para({ LINES, xe.leader_tab(TAB_R), spacing(h.level == 1 and 168 or 84, 0), ind(left, nil, 0, PNUM_TOC) },
    inl(h.content, {}) .. LEAD .. runs(label_of(h.id), {}))
end

local GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

-- the registry, alphabetical within each group (typst: lower(name + " " + cite))
local function toa_rows(auths)
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(auths) do
      if stringify(a.kind) == g[1] then
        members[#members + 1] = { a = a, key = key, sort = (stringify(a.name) .. " " .. stringify(a.cite)):lower() }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      out[#out + 1] = para({ KEEP, spacing(#out == 0 and 0 or 380, 0), ind(0, nil, 0) }, runs(g[2], { b = true }))
      for _, m in ipairs(members) do
        local name = inl(m.a.name, { i = g[1] == "case" })
        out[#out + 1] = para({ LINES, spacing(140, 0), ind(TAB, TAB) }, name .. runs(", ", {}) .. inl(m.a.cite, {}))
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings (typst show heading): level 1 centred bold capitals; 2 bold; 3 bold, half an inch in; 4 italic, an inch in
-- ---------------------------------------------------------------------------

local H_SPACE = { { 392, 336, 0 }, { 336, 252, 0 }, { 364, 308, 720 }, { 336, 280, 1440 } }

local function heading_xml(level, content, first)
  local s = H_SPACE[math.min(level, 4)]
  local before = first and 0 or s[1]
  if level == 1 then
    return para({ style("Heading1"), KEEP, spacing(before, s[2]), ind(0, nil, 0), jc("center") },
      inl(upper_inlines(content), { b = true }))
  end
  local x
  if level >= 4 then
    x = inl(content, { i = true }):gsub("<w:rPr>", '<w:rPr><w:b w:val="0"/><w:bCs w:val="0"/>')
  else
    x = inl(content, { b = true })
  end
  return para({ style("Heading" .. math.min(level, 5)), KEEP, spacing(before, s[2]), ind(s[3], nil, 0), jc("left") }, x)
end

-- ---------------------------------------------------------------------------
-- Signature and certificates
-- ---------------------------------------------------------------------------

local function signature_block(meta)
  local sig = need_meta(meta, "signature")
  local out = { line_par(runs("Respectfully submitted,", {}), 420, nil, SIG) }
  out[#out + 1] = line_par(inl(sig.signer, {}), 504, nil, SIG)
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = line_par(inl(l, { i = true }), 0, nil, SIG) end
  if meta.date then out[#out + 1] = line_par(inl(meta.date, {}), 0, nil, SIG) end
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return table.concat(out)
end

local function signer_block(meta)
  local out = { line_par(inl(need_meta(meta, "signature").signer, {}), 420, nil, SIG) }
  if meta.date then out[#out + 1] = line_par(inl(meta.date, {}), 0, nil, SIG) end
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return table.concat(out)
end

local function certificate_of_compliance(meta, words)
  return page_heading("CERTIFICATE OF COMPLIANCE", true)
    .. text_para(runs("I certify that this brief complies with the word limit of 22 NYCRR 500.13(c)(1), that it contains "
      .. group_digits(words) .. " words in the body of the brief, excluding the caption, tables and signature block, and that the count was made by the word-processing system used to prepare it.", {}))
    .. signer_block(meta)
end

local function certificate_of_service(meta)
  local svc = meta.service
  if not svc then return "" end
  local out = { page_heading("CERTIFICATE OF SERVICE", true) }
  out[#out + 1] = text_para(runs("I certify that on the date below I served copies of this brief on counsel for all parties by ", {})
    .. inl(svc.method, {}) .. runs(".", {}))
  for _, u in ipairs(svc.unregistered or {}) do
    out[#out + 1] = line_par(inl(u.name, {}), 280)
    out[#out + 1] = line_par(inl(u.address, {}), 0, nil, 0, LINES)
  end
  out[#out + 1] = signer_block(meta)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "apl_docket", "caption", "brief_title", "counsel", "phone", "signature" }) do need_meta(meta, k) end
  local words = body_words(body_markdown())

  -- the body: headings written here (and their needles), the rest left to pandoc with the break rules
  local blocks = doc.blocks:walk({ Link = function(el) return el.content end })
  local body, headings = {}, {}
  local hn = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      hn = hn + 1
      local id = "H:" .. hn
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      need(id, stringify(b.content), nxt)
      if b.level <= 2 then headings[#headings + 1] = { id = id, level = b.level, content = b.content } end
      body[#body + 1] = raw(heading_xml(b.level, b.content, #body == 0))
    else
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
  end
  body = pandoc.Pandoc(body):walk({ Inlines = function(l) return fix_inlines(xe.inlines(l)) end }).blocks
  -- typst moves the line that holds a footnote reference to the next page with its note, even when that leaves a
  -- widow: a paragraph with a footnote has no widow control (Body Text Note, docx/reference.xml)
  for i, b in ipairs(body) do
    if b.t == "Para" and has_note(b) then body[i] = pandoc.Div({ b }, { ["custom-style"] = "Body Text Note" }) end
  end

  -- needles: the tables first (they move the search past the contents), then the headings
  local nl = { table.concat({ "S:toc", "B", norm("TABLE OF CONTENTS Page"), norm("TABLE OF CONTENTS") }, "\t") }
  if meta.authorities then
    nl[#nl + 1] = table.concat({ "S:toa", "B", norm("TABLE OF AUTHORITIES"), norm("TABLE OF AUTHORITIES") }, "\t")
  end
  for _, n in ipairs(needles) do nl[#nl + 1] = n end
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = type(x) == "string" and raw(x) or x end

  -- section 1: the cover (no page number)
  add(cover(meta))
  add(section("rIdFtrNone"))

  -- section 2: the front matter (ii, iii ...): disclosure statement, contents, authorities
  local brk = false
  if meta.disclosure then
    add(page_heading("DISCLOSURE STATEMENT", false))
    local d = meta.disclosure
    local dblocks = pandoc.utils.type(d) == "Blocks" and d or { pandoc.Para(pandoc.Inlines(d)) }
    for _, p in ipairs(dblocks) do add(text_para(inl(p.content or stringify(p), {}))) end
    brk = true
  end
  add(page_heading("TABLE OF CONTENTS", brk))
  add(line_par(runs("Page", { b = true, u = true }), 0, "right"))
  for _, h in ipairs(headings) do add(toc_row(h)) end
  if meta.authorities then
    add(page_heading("TABLE OF AUTHORITIES", true))
    add(toa_rows(meta.authorities))
  end
  add(section("rIdFtrPage", "lowerRoman", 2))

  -- section 3: the body (1, 2 ...), the signature and the certificates
  for _, b in ipairs(body) do add(b) end
  add(signature_block(meta))
  add(certificate_of_compliance(meta, words))
  add(certificate_of_service(meta))

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
