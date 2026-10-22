-- docx engine, PTAB patent owner response (37 C.F.R. 42.120). The typst template (../typst/ptab-patent-owner-response.typ)
-- is the reference: this filter writes the same blocks with the same pitches and spaces (twips = 20 x the typst pt) on
-- the cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): exact line spacing,
-- typst's break rules on every run. It writes the cover, the contents, the headings (their labels as text), the
-- signature block and the two certificates; the body's paragraphs, lists and footnotes are pandoc's, on
-- reference.docx (docx/reference.xml). Everything comes from the frontmatter of the sample (schema: ../README.md,
-- "Markdown contract"); no text is specific to a case. It also writes the footers (FORMBOOK_FOOTERS: roman for the
-- contents; arabic from 1 for the body, with the running identification under the page number, as typst sets it) and
-- the body's section (FORMBOOK_FINAL). The contents' page numbers come from the PDF (fb render,
-- tools/fb/src/docxpass.rs): each pass writes a needle per heading (FORMBOOK_NEEDLES) and lists the pages of the
-- pass before (FORMBOOK_PAGES; placeholders on the first), until they settle.
--
-- Sections: cover (no number), contents (lower-case roman), body and certificates (arabic from 1).

local xe = require("docx.xengine")

local CFG = {
  kind = "ptab-patent-owner-response",
  limit = 14000, -- PTAB-POR-LEN-001: 37 C.F.R. 42.24(b)(2), the petition's limit (42.24(a)(1)(i))
  limit_cite = "42.24(b)(2)",
  word_cert = "Under the provisions of 37 C.F.R. § 42.24, the undersigned hereby certifies that the word count for the foregoing Patent Owner Response (excluding the table of contents, table of authorities, mandatory notices, certificate of service or word count, and appendix of exhibits or claim listing) totals {words} words, which is within the word limit allowed under 37 C.F.R. § 42.24(b)(2).",
  service = "Pursuant to 37 C.F.R. § 42.6(e), the undersigned hereby certifies service on the Petitioner of a copy of this Patent Owner Response and its respective exhibits, by {manner}, on the following at the addresses shown:",
  toc_depth = 2,
  running = "Patent Owner Response, {pn}", -- typst running-title
}

-- the typst numbers, in twips
local SINGLE, DOUBLE, QUOTE = 320, 640, 480 -- pitch-single 16 pt, pitch-double 32 pt, pitch-quote 24 pt
local INDENT = 720                          -- para-indent, label-box: 0.5 in
local SIG = 4320                            -- sig-indent: 3 in
local TEXTW = 9360                          -- 6.5 in, the text width
local PCOL = 720                            -- toc-page-col: 36 pt
local PAGE = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="688" w:gutter="0"/>'

local function fail(msg) error(CFG.kind .. ": " .. msg, 0) end

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- plain template text as runs: a section sign kept with its number (typst boxes "§ 42.24")
local function trun(s, o)
  return xe.runs((s:gsub("§ ", "§\u{00A0}")), o)
end

local function P(props, body) return xe.para(props, body) end

-- one single-spaced line: before (twips), alignment, left indent, keep with the next
local function line(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pbb then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.sect then props[#props + 1] = o.sect end
  return P(props, body)
end

-- 10543 -> "10,543"
local function thousands(n)
  local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (s:gsub("^,", ""))
end

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

-- typst heading-number: I. / A. / 1. / a.
local function label(level, n)
  if level == 1 then return roman(n) .. "."
  elseif level == 2 then return string.char(64 + n) .. "."
  elseif level == 3 then return n .. "."
  else return string.char(96 + n) .. "." end
end

local function cover(m)
  local out = {}
  local function c(body, before, o)
    o = o or {}
    out[#out + 1] = line(body, { before = before, jc = o.jc or "center", sect = o.sect })
  end
  c(trun("UNITED STATES PATENT AND TRADEMARK OFFICE"), 0)
  c(trun("BEFORE THE PATENT TRIAL AND APPEAL BOARD"), 240)
  c(xe.inl(m.petitioner.name, { b = true }), 680)
  c(xe.inl(m.petitioner.role), 0, { jc = "right" })
  c(trun("v."), 340)
  c(xe.inl(m["patent-owner"].name, { b = true }), 340)
  c(xe.inl(m["patent-owner"].role), 0, { jc = "right" })
  c(xe.inl(m["patent-number"]), 680)
  c(xe.inl(m["patent-title"]), 240)
  c(xe.inl(m["case-number"]), 240)
  -- the last cover paragraph ends section 1: no footer, no page number
  c(xe.inl(m.title, { b = true }), 680, { sect = "<w:sectPr>" .. PAGE .. "</w:sectPr>" })
  return out
end

-- a centered bold heading of the front matter and the certificates (typst plain-heading: 16 pt below)
local function plain_heading(s, pbb)
  return line(trun(s, { b = true }), { keep = true, pbb = pbb, after = 320, jc = "center" })
end

-- The pages of the pass before (FORMBOOK_PAGES: id<TAB>page<TAB>label per needle): heading index -> its folio;
-- nil on the first pass.
local function read_pagemap()
  local map = {}
  local f = os.getenv("FORMBOOK_PAGES")
  if f == nil or f == "" then return nil end
  local h = io.open(f, "r")
  if h == nil then return nil end
  for l in h:lines() do
    local idx, folio = l:match("^H:(%d+)\t[^\t]*\t(.*)$")
    if idx then map[tonumber(idx)] = folio end
  end
  h:close()
  if next(map) == nil then return nil end
  return map
end

-- Contents: one row per heading of levels 1..toc_depth (typst toc-entry and listing-row): the label in a half-inch
-- box at the heading's depth, the title hanging after it and wrapping before the page column, a dot leader from
-- three spaces after the text to the page number.
local function contents(headings, map, last_row)
  local out = { plain_heading("TABLE OF CONTENTS") }
  local rows = {}
  for i, h in ipairs(headings) do
    if h.level <= CFG.toc_depth then rows[#rows + 1] = { i = i, h = h } end
  end
  for k, r in ipairs(rows) do
    local h = r.h
    local ind = (h.level - 1) * INDENT
    local page = map and map[r.i] or "0"
    if map and not map[r.i] then fail("no page for heading " .. r.i) end
    local props = {
      xe.LINES,
      '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + INDENT) .. '"/><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>',
      xe.spacing(h.level == 1 and 200 or 140, 0, SINGLE),
      xe.ind(ind + INDENT, INDENT, nil, PCOL),
      xe.jc("left"),
    }
    -- the last contents paragraph ends section 2 (roman numbers)
    if k == #rows then
      props[#props + 1] = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooterRoman"/>' .. PAGE .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
      last_row(txt(h.content) .. " " .. page)
    end
    out[#out + 1] = P(props, xe.runs(h.label .. "\t") .. xe.inl(h.content) .. xe.runs(xe.LEAD .. page))
  end
  return out
end

-- a body heading (typst style-heading): level 1 centered capitals, 16 pt above, 12 pt below; deeper levels flush
-- left, 14 pt above, 10 pt below, level 3 and deeper italic; all bold, single spaced, kept with the next block. A
-- heading that opens the body's section has no space above: Word keeps the space above the first paragraph of a
-- section, typst drops it at the top of a page.
local function heading(h, opens)
  local content = h.content
  if h.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local o = { b = true, i = h.level >= 3 }
  local body = xe.runs(h.label .. " ", o) .. xe.inl(content, o)
  local props = { xe.style("Heading" .. math.min(h.level, 5)), xe.KEEP }
  if h.level == 1 then
    props[#props + 1] = xe.spacing(opens and 0 or 320, 240, SINGLE)
    props[#props + 1] = xe.ind(0, nil, 0)
    props[#props + 1] = xe.jc("center")
  else
    props[#props + 1] = xe.spacing(opens and 0 or 280, 200, SINGLE)
    props[#props + 1] = xe.ind(0, nil, 0)
    props[#props + 1] = xe.jc("left")
  end
  return P(props, body)
end

-- The signature block (typst signature-block): "Dated:" 24 pt below the text above, the signature 32 pt below it,
-- at 3 in; the block is kept together.
local function signature_block(m)
  local sig = m.signature
  local lines = {}
  if m.date then lines[#lines + 1] = { trun("Dated: " .. txt(m.date)), 480, 0 } end
  lines[#lines + 1] = { trun("/s/ " .. txt(sig.signer)), 640, SIG }
  lines[#lines + 1] = { trun(txt(sig["signer-name"]) .. " (Reg. No. " .. txt(sig["reg-no"]) .. ")"), 0, SIG }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = line(l[1], { before = l[2], left = l[3], keep = i < #lines, lines = true })
  end
  return out
end

-- a certificate's statement (typst statement): double spaced, first line indented, never split
local function statement(s)
  return line(trun(s), { lines = true, pitch = DOUBLE, first = INDENT })
end

local function certificate_of_word_count(m)
  local words = tonumber(txt(m["word-count"]))
  if words == nil then fail("word-count must be a number") end
  if words > CFG.limit then
    fail("word count " .. words .. " exceeds the " .. CFG.limit .. "-word limit (" .. CFG.limit_cite .. ")")
  end
  local out = { plain_heading("CERTIFICATION UNDER 37 C.F.R. § 42.24", true) }
  out[#out + 1] = statement((CFG.word_cert:gsub("{words}", thousands(words))))
  for _, p in ipairs(signature_block(m)) do out[#out + 1] = p end
  return out
end

local function certificate_of_service(m)
  local svc = m.service
  local out = { plain_heading("CERTIFICATE OF SERVICE", true) }
  out[#out + 1] = statement((CFG.service:gsub("{manner}", function() return txt(svc.manner) end)))
  for _, r in ipairs(svc.recipients or {}) do
    local ls = { xe.inl(r.name) }
    for _, l in ipairs(r.lines or {}) do ls[#ls + 1] = xe.inl(l) end
    for i, l in ipairs(ls) do
      out[#out + 1] = line(l, { before = i == 1 and 240 or 0, left = INDENT, keep = i < #ls, lines = true })
    end
  end
  for _, p in ipairs(signature_block(m)) do out[#out + 1] = p end
  return out
end

-- a block quotation (typst show quote): 1.5 spaced, indented a half inch from both margins, 12 pt above and below
local function block_quote(b)
  local out = {}
  local paras = {}
  for _, p in ipairs(b.content) do
    if p.t ~= "Para" and p.t ~= "Plain" then return { b } end
    paras[#paras + 1] = p
  end
  for i, p in ipairs(paras) do
    out[#out + 1] = xe.raw(P({ xe.spacing(i == 1 and 240 or 0, i == #paras and 240 or 0, QUOTE),
      xe.ind(INDENT, nil, 0, INDENT), xe.jc("left") }, xe.inl(p.content)))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Page search, footers and the body's section (fb render's multi-pass build)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60 -- a needle is a prefix of the text (letters and digits only, tools/fb/src/docxpages.rs)

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- a needle line: ID, B (body), the text and what follows it, and the text's first words (at least 8 letters and
-- digits) for a needle that runs over a page break
local function need(list, id, text, context)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  short = short:sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  list[#list + 1] = id .. "\tB\t" .. long .. "\t" .. short
end

local function write_file(env, text)
  local path = os.getenv(env)
  if path == nil or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function read_file(path)
  if path == nil or path == "" then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- the footer sits 18.4 pt above the page edge (typst: 30 % footer descent below the 1 in margin's text area, two
-- 16 pt lines); the cover and the contents keep the filter's 34.4 pt (one line)
local FPAGE = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="368" w:gutter="0"/>'
local FLINE = '<w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/>'
local PAGENO = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'

-- The two footers (FORMBOOK_FOOTERS): the contents' page number; the body's, with the running identification
-- (typst running-title) naming the patent number of the frontmatter as written, its hyphens unbreakable.
local function footers(m)
  local meta = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)
  local pn = meta["patent-number"]
  if type(pn) ~= "string" and type(pn) ~= "number" then fail("the frontmatter has no patent-number") end
  pn = tostring(pn):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    :gsub("%-(%d)", '</w:t><w:noBreakHyphen/><w:t xml:space="preserve">%1')
  local running = CFG.running:gsub("{pn}", function() return pn end)
  local page = '<w:p><w:pPr>' .. FLINE .. '<w:jc w:val="center"/></w:pPr>' .. PAGENO .. '</w:p>'
  return "rIdFooterRoman\t" .. page .. "\n" ..
    "rIdFooterArabic\t" .. page .. '<w:p><w:pPr>' .. FLINE .. '<w:jc w:val="right"/></w:pPr><w:r><w:t xml:space="preserve">' ..
    running .. "</w:t></w:r></w:p>\n"
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function raw(list)
    out[#out + 1] = pandoc.RawBlock("openxml", table.concat(list, ""))
  end

  -- number the headings (typst heading-number)
  local headings, counters = {}, { 0, 0, 0, 0, 0, 0 }
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local l = b.level
      counters[l] = counters[l] + 1
      for k = l + 1, #counters do counters[k] = 0 end
      local h = { level = l, content = b.content, label = label(l, counters[l]), at = i }
      headings[#headings + 1] = h
    end
  end
  -- the text of the block after a heading, as the body sets it (a heading with its label)
  local function after(i)
    local b = doc.blocks[i + 1]
    if b == nil then return "" end
    for _, h in ipairs(headings) do
      if h.at == i + 1 then return h.label .. " " .. txt(h.content) end
    end
    return txt(b)
  end

  -- the needles of the page search, in document order: the contents' last row, its title and page (the body's
  -- headings are searched after it; the PDF text of the contents puts the labels out of order), then each heading as the body sets it (label and title) with the text after it
  local needles = {}
  raw(cover(m))
  raw(contents(headings, read_pagemap(), function(row) need(needles, "T:end", row) end))
  for i, h in ipairs(headings) do
    need(needles, "H:" .. i, h.label .. " " .. txt(h.content), after(h.at))
  end
  needles[#needles + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", footers(m))
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooterArabic"/>' .. FPAGE ..
    '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>')

  -- body: section 3 (FORMBOOK_FINAL gives it the arabic numbering and the footer)
  local body = {}
  local hi = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      hi = hi + 1
      body[#body + 1] = xe.raw(heading(headings[hi], #body == 0))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(block_quote(b)) do body[#body + 1] = x end
    else
      body[#body + 1] = b
    end
  end
  -- the last paragraph stays on the page of the signature block (typst: block(breakable: false))
  local last = body[#body]
  if last and (last.t == "Para" or last.t == "Plain") then
    body[#body] = pandoc.Div({ pandoc.Para(last.content) }, pandoc.Attr("", {}, { ["custom-style"] = "Body Keep" }))
  end
  for _, b in ipairs(body) do out[#out + 1] = b end
  raw(signature_block(m))

  -- certificates: same section as the body
  raw(certificate_of_word_count(m))
  raw(certificate_of_service(m))

  -- pandoc would print the title and the date as a title block ahead of the cover; the cover carries them
  doc.meta.title = nil
  doc.meta.date = nil
  return pandoc.Pandoc(out, doc.meta):walk({ Inlines = xe.inlines })
end
