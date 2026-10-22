-- cafc-docx.lua: the Federal Circuit answering brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on reference.docx (docx/build-reference.sh). It lays the brief out as ../typst/cafc-answering-brief.typ
-- does, on the cross-engine layout model (lib/docx/xengine.lua): exact line boxes of the typst pitches (32.2 pt text,
-- 16.1 pt single), the typst spaces between blocks (twips = 20 x pt), first-fit breaking, typst's break opportunities.
-- The cover, the representative claims, the table of contents, the table of authorities, the statement of related
-- cases, the signature block and the certificates are written here as raw WordprocessingML paragraphs; the body keeps
-- its markdown structure, its headings get their labels (I. A. 1. a. (1)) and a tab.
-- Sections (cover: no number; front matter: lower roman from i; body and certificates: arabic from 1) and the footers
-- are written by docx/render.sh, which also fills the page numbers of the contents and authorities from a first pass
-- (DOCX_MANIFEST and DOCX_PAGEMAP, see docx/pagemap.awk).

local xe = require("docx.xengine")

local WORD_LIMIT = 14000 -- Fed. Cir. R. 32(b) (typst word-limit)
local TOC_DEPTH = 4      -- typst toc-depth
local TEXTW = 9360       -- 6.5 in, the text width (letter, 1 in margins)
local HALF = 4680        -- the right half of the text width (typst right-half)
local BODY, SINGLE = 644, 322   -- typst pitch-double (32.2 pt), pitch-single (16.1 pt)
local TOC_COL, TOA_COL = 720, 1120   -- typst toc-page-col (36 pt), toa-page-col (56 pt)
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="686" w:gutter="0"/></w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="RIDROMAN"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="686" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'

local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local function fail(msg) error("cafc answering-brief: " .. msg, 0) end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function need(meta, k)
  if meta[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- a metadata value as inlines (YAML strings are read as markdown)
local function minl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then return pandoc.Inlines({ pandoc.Str(v) }) end
  if v.t == nil then return pandoc.Inlines(v) end
  return pandoc.Inlines(pandoc.utils.stringify(v))
end

local function upper_il(il)
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(e.text:upper()) end }).content
end

-- inlines as runs: xe.inl, with the line breaks (TOA: name, then the cite) and raw runs the tables need
local function runs(il, o)
  local out, part = {}, pandoc.Inlines({})
  local function flush()
    if #part > 0 then out[#out + 1] = xe.inl(part, o) end
    part = pandoc.Inlines({})
  end
  for _, el in ipairs(il) do
    if el.t == "LineBreak" then flush(); out[#out + 1] = xe.BR
    elseif el.t == "RawInline" and el.format == "openxml" then flush(); out[#out + 1] = el.text
    else part:insert(el) end
  end
  flush()
  return table.concat(out)
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local LB = pandoc.LineBreak()

-- one paragraph: properties in schema order (keep, page break, tabs, spacing, indent, jc), then the runs
local function P(props, il, o)
  return xe.raw(xe.para(props, runs(pandoc.Inlines(il), o)))
end
local function sp(before, after, line) return xe.spacing(before, after, line or SINGLE) end
local IND0 = xe.ind(0, nil, 0)
local CENTER = xe.jc("center")

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- printed label of a numbered heading (typst heading-label): I. / A. / 1. / a. / (1)
local function label_for(level, n)
  if level == 1 then return roman(n) .. "." end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return tostring(n) .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  if level == 5 then return "(" .. n .. ")" end
  fail("headings deeper than level 5 are not supported")
end

local function norm_text(s)
  return (s:gsub("\u{00A0}", " "):lower():gsub("%s+", " "):gsub("^ ", ""):gsub(" $", ""))
end

-- the search key of a heading in the PDF: lower case, at most about 30 characters
local function search_key(s)
  s = norm_text(s)
  if #s > 30 then s = s:sub(1, 30):match("^(.*)%s%S*$") or s:sub(1, 30) end
  return s
end

-- ---------------------------------------------------------------------------
-- page numbers from a first pass (docx/render.sh): DOCX_PAGEMAP, DOCX_MANIFEST
-- ---------------------------------------------------------------------------

local PM = { H = {}, S = {}, T = {} }
local pm_path = os.getenv("DOCX_PAGEMAP")
local have_pm = pm_path ~= nil and pm_path ~= ""
if have_pm then
  local f = io.open(pm_path, "r")
  if not f then fail("cannot read the page map " .. pm_path) end
  for line in f:lines() do
    local k, a, b = line:match("^(%u)\t([^\t]*)\t(.*)$")
    if k == "H" then PM.H[tonumber(a)] = b
    elseif k == "S" then PM.S[a] = b
    elseif k == "T" then PM.T[a] = b
    end
  end
  f:close()
end
local function pm_get(tbl, key, what)
  if not have_pm then return "0" end
  local v = tbl[key]
  if v == nil then fail("no page for " .. what .. " in the page map") end
  return v
end

-- ---------------------------------------------------------------------------
-- cover (FRAP 32(a)(2); typst cover-body): single-spaced, centered, 14 pt between its parts
-- ---------------------------------------------------------------------------

local GAP = 280
local function rule_p(kind, before, after)
  local border = kind == "double"
    and '<w:pBdr><w:top w:val="double" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
    or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  local ind = kind == "double" and IND0 or xe.ind(3240, nil, 0, 3240)
  return xe.raw(xe.para({ "<w:keepNext/>", border, sp(before, after, 120), ind }, ""))
end

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  local function centered(il, before, o) add(P({ "<w:keepNext/>", sp(before or 0, 0), IND0, CENTER }, il, o)) end
  local function right(il, before) add(P({ "<w:keepNext/>", sp(before or 0, 0), xe.ind(HALF, nil, 0) }, il)) end
  centered(minl(need(meta, "case_number")), 168, { b = true })
  add(rule_p("double", GAP, GAP))
  centered({ pandoc.Str("UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT") }, 0, { b = true })
  add(rule_p("short", GAP, GAP))
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for j, name in ipairs(side.names) do centered(minl(name), j > 1 and 98 or 0) end
    right(minl(side.designation), 98)
    if i < #sides then centered({ pandoc.Str("v.") }, 84); add(xe.raw(xe.para({ sp(0, 84, 20) }, ""))) end
  end
  add(rule_p("short", GAP, GAP))
  centered(minl(need(meta, "proceeding")))
  add(rule_p("short", GAP, GAP))
  centered(upper_il(minl(need(meta, "brief_title"))), 0, { b = true })
  add(rule_p("short", GAP, GAP))
  -- counsel (FRAP 32(a)(2)(F)): the right half; the names, then the lines 0.5 em in (wrapped lines too), 7 pt between
  -- the groups, the telephone number after the last group's lines
  local groups = need(meta, "counsel")
  for gi, g in ipairs(groups) do
    for j, n in ipairs(g.names) do right(minl(n), (j == 1 and gi > 1) and 140 or 0) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = need(meta, "phone") end
    for _, l in ipairs(lines) do
      add(P({ "<w:keepNext/>", sp(0, 0), xe.ind(HALF + 140, nil, 0) }, minl(l)))
    end
  end
  if meta.date ~= nil then right(minl(meta.date), GAP) end
  add(rule_p("double", GAP, 0))
  return B
end

-- Exemplary patent claims (Fed. Cir. R. 32(a)(3); typst patent-claims-page): their own unnumbered page after the
-- cover, single-spaced, 14 pt between the paragraphs.
local function section_heading(title, props)
  return P({ "<w:keepNext/><w:keepLines/>", props or "", sp(420, 308), IND0, CENTER }, upper_il(minl(title)), { b = true })
end
local TOP_HEAD = '<w:pageBreakBefore/>'
local function page_heading(title)
  -- a heading that opens a page has no space above it (typst drops it at the top of a page; Word keeps it after a
  -- page break)
  return P({ "<w:keepNext/><w:keepLines/>", TOP_HEAD, sp(0, 308), IND0, CENTER }, upper_il(minl(title)), { b = true })
end

-- ---------------------------------------------------------------------------
-- signature and certificates (typst signature-block, certificate-signature)
-- ---------------------------------------------------------------------------

local function right_lines(lines, first_before, keep)
  local B = {}
  for i, il in ipairs(lines) do
    B[#B + 1] = P({ keep and "<w:keepNext/><w:keepLines/>" or "<w:keepLines/>", sp(i == 1 and first_before or 0, 0),
      xe.ind(HALF, nil, 0) }, il)
  end
  return B
end

local function signature(meta)
  local sig = need(meta, "signature")
  local B = {}
  local before = 392 -- 19.6 pt below the last paragraph
  if meta.date ~= nil then
    B[#B + 1] = P({ "<w:keepNext/><w:keepLines/>", sp(before, 0), IND0 }, { pandoc.Str("Dated: " .. plain(meta.date)) })
    before = 280
  end
  local lines = { { pandoc.Str("Respectfully submitted,") } }
  for _, b in ipairs(right_lines(lines, before, true)) do B[#B + 1] = b end
  lines = { { pandoc.Str("/s/ " .. plain(sig.signer)) } }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = minl(l) end
  local rl = right_lines(lines, 336, true)
  for _, b in ipairs(rl) do B[#B + 1] = b end
  return B
end

local function certificate_signature(meta)
  local sig = need(meta, "signature")
  local lines = { { pandoc.Str("/s/ " .. plain(sig.signer)) }, { pandoc.Str(plain(sig.signer):upper()) } }
  for _, l in ipairs(sig.certificate_lines or {}) do lines[#lines + 1] = minl(l) end
  return right_lines(lines, 448, true)
end

-- ---------------------------------------------------------------------------
-- words (Fed. Cir. R. 32(b)): the typst template's count, block by block, headings and footnotes included
-- ---------------------------------------------------------------------------

local function words_in(s)
  local n = 0
  for _ in s:gsub("\194\160", " "):gmatch("%S+") do n = n + 1 end
  return n
end

local function count_blocks(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do n = n + count_blocks(item) end
    elseif b.t == "BlockQuote" or b.t == "Div" then
      n = n + count_blocks(b.content)
    elseif b.t ~= "RawBlock" then
      local notes = {}
      local without = pandoc.Pandoc({ b }):walk({
        Note = function(note) notes[#notes + 1] = note.content; return {} end,
      })
      n = n + words_in(pandoc.utils.stringify(without.blocks))
      for _, c in ipairs(notes) do n = n + count_blocks(c) end
    end
  end
  return n
end

-- the width of a page list in the table of authorities (typst: max(56 pt, the list's own width)), in twips, from
-- the advance widths of Times New Roman at 14 pt
local ADV = { [","] = 70, [" "] = 70, i = 78, v = 140, x = 140, l = 78, c = 124, p = 140, a = 124, s = 109, m = 218 }
local function list_width(s)
  local w = 0
  for ch in s:gmatch(".") do w = w + (ADV[ch] or 140) end
  return w
end

-- ---------------------------------------------------------------------------
-- the filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature",
    "related_statement" }) do
    need(meta, k)
  end
  local words = count_blocks(doc.blocks)
  if words > WORD_LIMIT then fail("the brief has " .. words .. " words; Fed. Cir. R. 32(b) allows " .. WORD_LIMIT) end

  -- every toa: citation in document order, as a needle for the page map (docx/pagemap.awk): the link text and the
  -- words after it in its paragraph (up to a footnote mark or a quotation), so that the same words elsewhere in the
  -- brief, unlinked, are not taken for it. Kind B (body) moves the search on; N (in a footnote) is searched from the
  -- page the body has reached.
  local needles = {}
  local scan_blocks
  local function scan(inls, kind)
    for i, el in ipairs(inls) do
      if el.t == "Link" and el.target:match("^toa:") then
        local rest = {}
        for j = i + 1, math.min(#inls, i + 12) do
          local t = inls[j].t
          if t == "Note" or t == "Quoted" or t == "Link" then break end
          rest[#rest + 1] = inls[j]
        end
        local lt = norm_text(plain(pandoc.Inlines(el.content)))
        local tail = norm_text(plain(pandoc.Inlines(rest)))
        if #tail > 20 then tail = tail:sub(1, 20):match("^(.*)%s%S*$") or "" end
        local text = lt
        if tail ~= "" then text = lt .. (tail:match("^[%.,;:%)]") and "" or " ") .. tail end
        needles[#needles + 1] = { key = el.target:sub(5), kind = kind, text = text }
      elseif el.t == "Note" then
        scan_blocks(el.content, "N")
      elseif el.content ~= nil and type(el.content) == "table" and el.t ~= "Code" then
        scan(el.content, kind)
      end
    end
  end
  scan_blocks = function(blocks, kind)
    for _, b in ipairs(blocks) do
      if b.t == "Para" or b.t == "Plain" or b.t == "Header" then scan(b.content, kind)
      elseif b.t == "BlockQuote" or b.t == "Div" then scan_blocks(b.content, kind)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, kind) end
      end
    end
  end
  scan_blocks(doc.blocks, "B")

  local auth = meta.authorities or {}
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return el.content end
      if auth[key] == nil then fail("link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
      hits[key] = true
      return el.content
    end,
  })
  -- the break rules of typst on the text pandoc writes itself (body, footnotes)
  doc = doc:walk({ Inlines = xe.inlines })

  -- the body: headings get their labels; lists their label boxes
  local heads, body = {}, {}
  local counters = { 0, 0, 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      local lab = label_for(b.level, counters[b.level])
      local ind = (b.level - 1) * 720
      local title = b.level == 1 and upper_il(b.content) or b.content
      local o = { b = true, i = b.level >= 4 }
      -- [style-heading]: the label in a half-inch box at its indent, the text hanging after it; 15.4 / 12.6 pt
      body[#body + 1] = xe.raw(xe.para({ "<w:keepNext/><w:keepLines/>",
        '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + 720) .. '"/></w:tabs>', sp(#body == 0 and 0 or 308, 252),   -- none above the heading that opens the body's first page
        xe.ind(ind + 720, 720, nil) },
        runs({ pandoc.Str(lab) }, o) .. "<w:r><w:tab/></w:r>" .. runs(title, o)))
      heads[#heads + 1] = { level = b.level, label = lab, title = b.content,
        key = search_key(lab .. " " .. plain(title)) }
    else
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
  end
  -- the last paragraph stays with the signature block (typst keeps them together)
  if #body > 0 and body[#body].t == "Para" then
    body[#body] = pandoc.Div({ body[#body] }, pandoc.Attr("", {}, { ["custom-style"] = "Body Last" }))
  end

  -- manifest for the first pass of docx/render.sh
  local man_path = os.getenv("DOCX_MANIFEST")
  if man_path ~= nil and man_path ~= "" then
    local f = assert(io.open(man_path, "w"))
    for i, h in ipairs(heads) do f:write(string.format("H\t%d\t%d\t%s\n", i, h.level, h.key)) end
    for _, n in ipairs(needles) do f:write(string.format("C\t%s\t%s\t%s\n", n.key, n.kind, n.text)) end
    f:close()
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- section 1: the cover and the representative claims (no page number)
  addall(cover(meta))
  if meta.patent_claims ~= nil then
    add(page_heading(meta.patent_claims_heading ~= nil and meta.patent_claims_heading or "Exemplary Patent Claims"))
    for i, p in ipairs(meta.patent_claims) do add(P({ sp(i > 1 and 280 or 0, 0), IND0 }, minl(p))) end
  end
  add(xe.raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. SECT_COVER .. '</w:pPr></w:p>'))

  -- section 2 (lower roman): the table of contents [toc-entry, listing-row]
  add(P({ "<w:keepNext/><w:keepLines/>", sp(0, 308), IND0, CENTER }, { pandoc.Str("TABLE OF CONTENTS") }, { b = true }))
  add(P({ "<w:keepNext/>", sp(84, 0), IND0, xe.jc("right") }, { pandoc.Str("Page") }, { b = true, u = true }))
  local function folio_il(v)
    if v == "passim" then return { pandoc.Emph({ pandoc.Str("passim") }) } end
    return { pandoc.Str(v) }
  end
  for i, h in ipairs(heads) do
    if h.level <= TOC_DEPTH then
      local ind = (h.level - 1) * 720
      local page = pm_get(PM.H, i, "heading " .. i)
      local il = pandoc.Inlines({ pandoc.Str(h.label), TAB })
      il:extend(h.title)
      il:insert(pandoc.Str(xe.LEAD))
      il:extend(folio_il(page))
      add(P({ "<w:keepLines/>", '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + 720) ..
        '"/><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>',
        sp(h.level == 1 and 168 or 98, 0), xe.ind(ind + 720, 720, nil, TOC_COL) }, il))
    end
  end

  -- the table of authorities (its own page)
  add(page_heading("Table of Authorities"))
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    local function sk(a)
      local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
      return (s:lower():gsub("[^a-z0-9 ]", ""))
    end
    table.sort(members, function(x, y)
      local kx, ky = sk(x.a), sk(y.a)
      if kx == ky then return x.key < y.key end
      return kx < ky
    end)
    if #members > 0 then
      -- the group: 14 pt below the heading (the first, with the column head), 19.6 pt after the last entry
      local head = runs({ pandoc.Str(g[2]) }, { b = true })
      if first then head = head .. "<w:r><w:tab/></w:r>" .. runs({ pandoc.Str("Page(s)") }, { b = true, u = true }) end
      add(xe.raw(xe.para({ "<w:keepNext/>", '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>',
        sp(first and 280 or 392, 56), IND0 }, head)))
      first = false
      for _, m in ipairs(members) do
        local page = pm_get(PM.T, m.key, "authority " .. m.key)
        local il = pandoc.Inlines({})
        if m.a.name ~= nil then
          local nm = minl(m.a.name)
          if g[1] == "case" then il:insert(pandoc.Emph(nm)) else il:extend(nm) end
          il:insert(pandoc.Str(",")); il:insert(LB)
        end
        il:extend(minl(m.a.cite))
        il:insert(pandoc.Str(xe.LEAD))
        il:extend(folio_il(page))
        local col = math.max(TOA_COL, list_width(page))
        add(P({ "<w:keepLines/>", xe.leader_tab(TEXTW), sp(196, 0), xe.ind(504, 504, nil, col) }, il))
      end
    end
  end

  -- the statement of related cases (Fed. Cir. R. 47.5): the sample's paragraphs, set as the text
  add(page_heading("Statement of Related Cases"))
  for _, p in ipairs(need(meta, "related_statement")) do
    add(P({ sp(0, 0, BODY), xe.ind(0, nil, 720) }, minl(p)))
  end
  add(xe.raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. SECT_ROMAN .. '</w:pPr></w:p>'))

  -- section 3 (arabic from 1): the body, the signature block, the certificates
  addall(body)
  addall(signature(meta))

  add(page_heading("Certificate of Compliance"))
  local counter = meta.word_counter ~= nil and plain(meta.word_counter) or "the word-processing system used to prepare it"
  add(P({ sp(0, 0), IND0 }, { pandoc.Str("I certify that this brief complies with the type-volume limitation of " ..
    "Fed. Cir. R. 32(b). The total number of words in the brief is " .. group_digits(words) .. ", as calculated by " ..
    counter .. ".") }))
  add(P({ sp(280, 0), IND0 }, { pandoc.Str("The brief\u{2019}s typeface and type style comply with FRAP 32(a)(5) and (6).") }))
  addall(certificate_signature(meta))
  if meta.service ~= nil and meta.service.certificate then
    add(page_heading("Certificate of Service"))
    add(P({ sp(0, 0), IND0 }, { pandoc.Str("I certify that on " .. (meta.date ~= nil and plain(meta.date) or "the date of filing") ..
      " I electronically filed the foregoing brief with the Clerk of Court using the CM/ECF system, which will send " ..
      "notice of the filing to all counsel of record.") }))
    addall(certificate_signature(meta))
  end

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({}) -- pandoc would print the date and title as a block at the top
  return doc
end
