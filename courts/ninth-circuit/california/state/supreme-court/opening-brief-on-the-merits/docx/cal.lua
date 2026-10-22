-- California Supreme Court opening brief on the merits (rule 8.520): pandoc filter for the docx engine. The same
-- content as the typst template (typst/cal-opening-brief-on-the-merits.typ) from the same markdown contract, in its
-- order:
--   the cover (rule 8.204(b)(10); page 1, no number shown, rule 8.204(b)(7)), the table of contents and the table of
--   authorities (rule 8.204(a)(1)(A)), the body (heading labels as typst: I./A./1./a.), the signature block kept with
--   the last paragraph, the certification of word count (rule 8.520(c)(1)) and the attorney's proof of service.
-- Styles come from docx/reference.xml (fb render builds reference.docx from it): one section, arabic page numbers
-- from the cover on, the cover's number not shown (titlePg).
-- The pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of every
-- heading and citation in that PDF (the needles this filter writes to FORMBOOK_NEEDLES), and renders again with those
-- pages (FORMBOOK_PAGES) until they settle; this filter writes the document's section (FORMBOOK_FINAL: fb render's
-- rIdFtrPage footer, rIdFtrNone on the cover). Word may paginate slightly differently from the LibreOffice PDF the page
-- numbers come from (docs/DOCX.md).

local WORD_LIMIT = 14000   -- rule 8.520(c)(1), computer-generated opening brief on the merits (typst: word-limit)
local TOC_DEPTH = 5        -- heading levels listed in the contents (typst: toc-depth)
local PASSIM = 7           -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local NEEDLE_MAX = 60      -- a needle is a prefix of the text (letters and digits only)
local TEXT_W = 7920        -- the text width: 8.5 in less 1.5 in on each side, in twips (rule 8.204(b)(6))
local TAB_R = TEXT_W - 20  -- the right tab of the tables: 1 pt inside the margin (a glyph may overhang)
local HALF = TEXT_W // 2   -- counsel and the proof's signature start at the middle of the text (typst: pad(left: 50%))
local SIG_L = TEXT_W - 4320 -- the signature block's right column is 3 in wide (typst: grid(columns: (1fr, 3in)))
local NBSP = "\u{00A0}"
local stringify = pandoc.utils.stringify

-- pandoc.utils.type: "List" for a YAML list, "table" for a map, "Inlines" for a single value.
local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then return v end
  return { v }
end

local function need(m, k)
  if m[k] == nil then error("cal: missing required metadata field `" .. k .. "`", 0) end
  return m[k]
end

-- ---------------------------------------------------------------------------
-- OOXML: runs and paragraphs
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Run properties: { b, i, u, caps }.
local function rpr(o)
  local s = ""
  if o.b then s = s .. "<w:b/><w:bCs/>" end
  if o.i then s = s .. "<w:i/><w:iCs/>" end
  if o.caps then s = s .. "<w:caps/>" end
  if o.u then s = s .. '<w:u w:val="single"/>' end
  return s == "" and "" or ("<w:rPr>" .. s .. "</w:rPr>")
end

local function run(text, o)
  return "<w:r>" .. rpr(o or {}) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local TAB = "<w:r><w:tab/></w:r>"
local BR = "<w:r><w:br/></w:r>"

-- Inlines (markdown in the frontmatter) as runs; emphasis nests into the run properties.
local function runs(list, o)
  o = o or {}
  local out = {}
  local function with(k)
    local q = {}
    for a, b in pairs(o) do q[a] = b end
    q[k] = not o[k]
    return q
  end
  for _, el in ipairs(list or {}) do
    if el.t == "Str" then out[#out + 1] = run(el.text, o)
    elseif el.t == "Space" or el.t == "SoftBreak" then out[#out + 1] = run(" ", o)
    elseif el.t == "LineBreak" then out[#out + 1] = BR
    elseif el.t == "Emph" then out[#out + 1] = runs(el.content, with("i"))
    elseif el.t == "Strong" then out[#out + 1] = runs(el.content, with("b"))
    elseif el.t == "Quoted" then
      local q1, q2 = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then q1, q2 = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(q1, o) .. runs(el.content, o) .. run(q2, o)
    elseif el.content and type(el.content) ~= "string" then out[#out + 1] = runs(el.content, o)
    else out[#out + 1] = run(stringify(el), o)
    end
  end
  return table.concat(out)
end

-- A metadata value (Inlines or a string) as runs.
local function mruns(v, o)
  if v == nil then return "" end
  if type(v) == "string" then return run(v, o) end
  if pandoc.utils.type(v) == "Inlines" then return runs(v, o) end
  return run(stringify(v), o)
end

-- A paragraph. o: { style, jc, left, right, hanging, first, before, after, line (exact twips; single otherwise),
-- keep (keepNext), lines (keepLines), brk (pageBreakBefore), rule ("double" or "single", a bottom border), tabs }.
local function p(body, o)
  o = o or {}
  local s = ""
  if o.style then s = s .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep then s = s .. "<w:keepNext/>" end
  if o.lines then s = s .. "<w:keepLines/>" end
  if o.brk then s = s .. "<w:pageBreakBefore/>" end
  if o.rule then
    s = s .. '<w:pBdr><w:bottom w:val="' .. o.rule .. '" w:sz="' .. (o.rule == "double" and 6 or 6)
      .. '" w:space="1" w:color="000000"/></w:pBdr>'
  end
  if o.tabs then s = s .. "<w:tabs>" .. o.tabs .. "</w:tabs>" end
  local line = o.line and ('w:line="' .. o.line .. '" w:lineRule="exact"') or 'w:line="240" w:lineRule="auto"'
  s = s .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '" ' .. line .. "/>"
  s = s .. '<w:ind w:left="' .. (o.left or 0) .. '" w:right="' .. (o.right or 0) .. '"'
  if o.hanging then s = s .. ' w:hanging="' .. o.hanging .. '"' else s = s .. ' w:firstLine="' .. (o.first or 0) .. '"' end
  s = s .. "/>"
  if o.jc then s = s .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. s .. "</w:pPr>" .. (body or "") .. "</w:p>"
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local DOT_TAB = '<w:tab w:val="right" w:leader="dot" w:pos="' .. TAB_R .. '"/>'

-- A section heading of the front and back matter (typst: a level-1 heading, bold capitals, centered, in the
-- outline): the Heading 1 style, so the PDF has a bookmark for it.
local function heading1(text, brk)
  return p(run(text, { b = true, caps = true }), { style = "Heading1", jc = "center", keep = true, brk = brk, before = 0, after = 260 })
end

-- ---------------------------------------------------------------------------
-- Needles and pages (the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing).
local needles = {}
local function needle(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
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
    local id, page, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = lab } end
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
-- Numbers and words
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

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- typst count-words: the whole markdown body (headings and footnotes included), markup removed, links keep their
-- text, list markers dropped, split on whitespace.
local function count_words()
  local f = PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then error("cal: cannot read the sample markdown for the word count", 0) end
  local src = h:read("a")
  h:close()
  local body = src:match("^%-%-%-[ \t]*\r?\n.-\r?\n%-%-%-[ \t]*\r?\n(.*)$") or src
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

-- The label of a numbered heading (typst heading-label): I. / A. / 1. / a., the same in every section.
local function heading_label(level, k)
  if level < 2 then return nil end
  if level > 5 then error("cal: headings deeper than level 5 are not supported", 0) end
  return ({ roman(k) .. ".", string.char(64 + k) .. ".", tostring(k) .. ".", string.char(96 + k) .. "." })[level - 1]
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body): court, caption beside the case numbers, review line, title, counsel; one page
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local function add(x) out[#out + 1] = x end
  local gap = 312  -- typst: the largest gap that fits, 1.2 em
  for _, l in ipairs(items(need(m, "court_lines"))) do add(p(mruns(l), { jc = "center" })) end
  -- caption on the left (3.4 parts), the Supreme Court and Court of Appeal numbers on the right (2.6 parts)
  local gutter = 360
  local lw = (TEXT_W - gutter) * 34 // 60
  local rw = TEXT_W - lw
  local pad = lw // 4
  local left = {}
  local sides = items(need(m, "caption"))
  for i, side in ipairs(sides) do
    for _, n in ipairs(items(side.names)) do left[#left + 1] = p(mruns(n), { after = 100 }) end
    left[#left + 1] = p(mruns(side.designation), { left = pad, after = 100 })
    if i < #sides then left[#left + 1] = p(run("v."), { left = pad, before = gap * 4 // 10 - 100, after = gap * 4 // 10 }) end
  end
  local right = p(run("Supreme Court No. ") .. mruns(need(m, "case_number")), { after = 100 })
    .. p(run("Court of Appeal No. ") .. mruns(need(m, "court_of_appeal_number")))
  add(p("", { after = 0, line = gap }))
  add('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblCellMar>'
    .. '<w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. lw .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. lw .. '" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. rw .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. gutter .. '" w:type="dxa"/></w:tcMar>'
    .. '<w:vAlign w:val="center"/></w:tcPr>' .. right .. '</w:tc></w:tr></w:tbl>')
  -- review line, trial court and its number, the judge; then the title
  add(p(mruns(need(m, "proceeding")), { jc = "center", before = gap }))
  add(p(mruns(need(m, "trial_court")), { jc = "center" }))
  add(p(run("Superior Court No. ") .. mruns(need(m, "superior_case_number")), { jc = "center" }))
  add(p(mruns(need(m, "judge")), { jc = "center", after = gap * 16 // 10 }))
  add(p(mruns(need(m, "brief_title"), { b = true, caps = true }), { jc = "center", after = gap * 16 // 10 }))
  -- counsel (rule 8.204(b)(10)(D)): from the middle of the text, then the party represented
  for _, g in ipairs(items(need(m, "counsel"))) do
    local x = {}
    for _, n in ipairs(items(g.names)) do x[#x + 1] = mruns(n) end
    for _, l in ipairs(items(g.lines)) do x[#x + 1] = mruns(l) end
    for i, r in ipairs(x) do add(p(r, { left = HALF, keep = true, after = i == #x and 130 or 0 })) end
  end
  add(p(mruns(need(m, "counsel_for"), { i = true }), { left = HALF }))
  return { raw(table.concat(out)) }
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities (typst toc-section, toa-section)
-- ---------------------------------------------------------------------------

local function toc(entries)
  local x = { heading1("Table of Contents", true),
    p(run("Page", { b = true, u = true }), { jc = "right", keep = true, after = 60 }) }
  for _, e in ipairs(entries) do
    local lead, left = "", 720
    if e.label then
      lead = run(e.label) .. TAB
      left = (e.level - 2) * 720 + 720
    end
    local title = e.level == 1 and run(e.text, { caps = true }) or run(e.text)
    x[#x + 1] = p(lead .. title .. run(" ") .. TAB .. run(label_of(e.id)),
      { tabs = '<w:tab w:val="left" w:pos="' .. left .. '"/>' .. DOT_TAB, left = left, right = 620, hanging = 720,
        lines = true, before = e.level == 1 and 120 or 60 })
  end
  return { raw(table.concat(x)) }
end

local GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function toa(authorities, occurrences)
  local x = { heading1("Table of Authorities", true) }
  local first = true
  local used = {}
  for _, o in ipairs(occurrences) do used[o.key] = true end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and stringify(a.kind) == g[1] then members[#members + 1] = { key = key, a = a, sort = sort_key(a) } end
    end
    if #members > 0 then
      table.sort(members, function(u, v)
        if u.sort ~= v.sort then return u.sort < v.sort end
        return u.key < v.key
      end)
      local head = run(g[2], { b = true })
      if first then head = head .. TAB .. run("Page(s)", { b = true, u = true }) end
      x[#x + 1] = p(head, { tabs = '<w:tab w:val="right" w:pos="' .. TAB_R .. '"/>', keep = true, before = first and 260 or 360, after = 40 })
      first = false
      for _, mb in ipairs(members) do
        local pages, seen = {}, {}
        for oi, o in ipairs(occurrences) do
          if o.key == mb.key then
            local l = labels[o.id]
            local pg = l and l.page or -oi
            if not seen[pg] then
              seen[pg] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
            end
          end
        end
        table.sort(pages, function(u, v) return u.page < v.page end)
        local list
        if #pages >= PASSIM then
          list = run("passim", { i = true })
        else
          local l = {}
          for _, pg in ipairs(pages) do l[#l + 1] = pg.label end
          list = run(table.concat(l, ", "))
        end
        local name = ""
        if mb.a.name then name = mruns(mb.a.name, { i = g[1] == "case" }) .. run(",") .. BR end
        x[#x + 1] = p(name .. mruns(mb.a.cite) .. run(" ") .. TAB .. list,
          { tabs = DOT_TAB, left = 504, right = 1120, hanging = 504, lines = true, before = 140 })
      end
    end
  end
  return { raw(table.concat(x)) }
end

-- ---------------------------------------------------------------------------
-- Signature block, certification of word count, attorney's proof of service (typst signature-block,
-- certificate-of-word-count, proof-of-service)
-- ---------------------------------------------------------------------------

-- DATED on the left; on the right, 3 in wide: Respectfully submitted, a blank line, By: /s/ SIGNER, the signer, the
-- role. Kept together.
local function signature(m)
  local sig = need(m, "signature")
  local x = {}
  x[#x + 1] = p(run("DATED: ") .. mruns(need(m, "date")) .. TAB .. run("Respectfully submitted,"),
    { tabs = '<w:tab w:val="left" w:pos="' .. SIG_L .. '"/>', keep = true, before = 360 })
  x[#x + 1] = p("", { keep = true })
  x[#x + 1] = p(run("By: /s/ ") .. run(stringify(sig.signer):upper()), { left = SIG_L, keep = true })
  x[#x + 1] = p(mruns(sig.signer), { left = SIG_L, keep = true })
  x[#x + 1] = p(mruns(sig.role, { i = true }), { left = SIG_L })
  return x
end

local function word_count(m, words)
  local sig = need(m, "signature")
  local x = { heading1("Certification of Word Count", true) }
  x[#x + 1] = p(run("Pursuant to rule 8.520(c)(1) of the California Rules of Court, I, ") .. mruns(sig.signer) .. run(", ")
    .. mruns(need(m, "certificate_role"), { i = true })
    .. run(", certify that I prepared the foregoing document on behalf of my client, and that the word count for this brief is "
      .. group_digits(words) .. ", excluding the tables and this certificate. This brief therefore complies with the rule, which limits a computer-generated opening brief on the merits to "
      .. group_digits(WORD_LIMIT) .. " words. The count includes footnotes and was computed from the text of the brief. I certify under penalty of perjury under the laws of the State of California that the foregoing is true and correct."))
  for _, s in ipairs(signature(m)) do x[#x + 1] = s end
  return { raw(table.concat(x)) }
end

local function service(m)
  local svc = need(m, "service")
  local x = { heading1("Attorney's Proof of Service", true) }
  local function add(body, o) o = o or {}; o.after = o.after or 210; x[#x + 1] = p(body, o) end
  add(run("(Code Civ. Proc., \u{00A7} 1013a, subd. (2); Cal. Rules of Court, rules 8.71(f) and 8.77)"))
  add(run("I, ") .. mruns(svc.declarant) .. run(", certify: I am an active member of the State Bar of California and am not a party to this cause. My electronic service address is ")
    .. mruns(svc.electronic_address) .. run(" and my business address is ") .. mruns(svc.business_address) .. run(". On ")
    .. mruns(need(m, "date")) .. run(", I served the persons and entities listed below by the method checked. For those marked \u{201C}Served Electronically,\u{201D} I transmitted a PDF version of ")
    .. mruns(need(m, "brief_title")) .. run(" by electronic service to the e-mail service address provided below."))
  for _, s in ipairs(items(svc.served)) do
    add(mruns(s.name) .. BR .. mruns(s.address) .. BR .. mruns(s.method) .. run("."), { left = 720, lines = true, after = 160 })
  end
  add(run("I declare under penalty of perjury under the laws of the State of California that the foregoing is true and correct. Executed on ")
    .. mruns(svc.executed_on) .. run(", at ") .. mruns(svc.executed_at) .. run("."), { before = 50, keep = true, after = 360 })
  x[#x + 1] = p(run("/s/ ") .. mruns(svc.declarant) .. BR .. mruns(svc.declarant) .. BR .. mruns(svc.state_bar_line), { left = HALF, lines = true })
  return { raw(table.concat(x)) }
end

-- ---------------------------------------------------------------------------
-- The brief
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "court_lines", "case_number", "court_of_appeal_number", "caption", "proceeding", "trial_court",
    "superior_case_number", "judge", "brief_title", "counsel", "counsel_for", "signature", "certificate_role", "date",
    "service" }) do
    need(m, k)
  end
  local authorities = m.authorities or {}
  local words = count_words()
  if words > WORD_LIMIT then
    error("cal: the brief has " .. words .. " words; rule 8.520(c)(1) allows " .. WORD_LIMIT, 0)
  end

  -- Citations, in document order: each `toa:` link is an occurrence and a needle (kind N inside a footnote).
  local occurrences = {}
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        if not authorities[key] then error("cal: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
        occurrences[#occurrences + 1] = { key = key, id = "T:" .. (#occurrences + 1) }
        local rest = {}
        for j = i + 1, #list do rest[#rest + 1] = list[j] end
        needle(occurrences[#occurrences].id, in_note and "N" or "B", stringify(el.content), stringify(rest))
      elseif el.t == "Note" then
        scan_blocks(el.content, true)
      elseif el.content and type(el.content) ~= "string" then
        scan_inlines(el.content, in_note)
      end
    end
  end
  scan_blocks = function(list, in_note)
    for _, b in ipairs(list) do
      if b.t == "Para" or b.t == "Plain" then
        scan_inlines(b.content, in_note)
      elseif b.t == "BlockQuote" or b.t == "Div" then
        scan_blocks(b.content, in_note)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
      end
    end
  end

  -- The body: heading labels, contents entries and needles of headings and citations, in order.
  local src = doc.blocks
  local counts = { 0, 0, 0, 0, 0, 0 }
  local body, entries, h_n = {}, {}, 0
  for i, b in ipairs(src) do
    if b.t == "Header" then
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      local lab = heading_label(b.level, counts[b.level])
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = src[i + 1] and stringify(src[i + 1]):sub(1, 40) or ""
      needle(id, "B", (lab and (lab .. " ") or "") .. stringify(b.content), nxt)
      if b.level <= TOC_DEPTH then
        entries[#entries + 1] = { id = id, level = b.level, label = lab, text = stringify(b.content) }
      end
      if lab then
        local inl = pandoc.List({ pandoc.Str(lab), pandoc.RawInline("openxml", TAB) })
        if b.level >= 4 then inl:insert(pandoc.Emph(b.content)) else inl:extend(b.content) end
        body[#body + 1] = pandoc.Header(b.level, inl, b.attr)
      else
        body[#body + 1] = b
      end
    else
      scan_blocks({ b }, false)
      body[#body + 1] = b
    end
  end
  body = pandoc.Pandoc(body):walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  }).blocks
  -- the last paragraph stays with the signature block (typst: a block that does not break)
  if body[#body] and body[#body].t == "Para" then
    body[#body] = pandoc.Div({ body[#body] }, pandoc.Attr("", {}, { ["custom-style"] = "Cal Body Keep" }))
  end

  -- The needles in page order: the cover, the two tables, the body, the certificates. Pages are numbered from the
  -- cover on (typst: numbering continues from the cover, rule 8.204(b)(7)).
  local court1 = stringify(items(m.court_lines)[1] or "")
  local first_group = ""
  for _, g in ipairs(GROUPS) do
    for _, o in ipairs(occurrences) do
      if first_group == "" and stringify(authorities[o.key].kind) == g[1] then first_group = g[2] end
    end
  end
  local front = {
    { "S:cover", court1, "" },
    { "S:toc", "Table of Contents", "Page" },
    { "S:toa", "Table of Authorities", first_group .. " Page(s)" },
  }
  local f = {}
  for _, x in ipairs(front) do
    f[#f + 1] = { id = x[1], kind = "B", needle = norm(x[2] .. " " .. x[3]):sub(1, NEEDLE_MAX), fallback = norm(x[2]):sub(1, NEEDLE_MAX) }
  end
  for i = #f, 1, -1 do table.insert(needles, 1, f[i]) end
  needle("C:wordcount", "B", "Certification of Word Count", "Pursuant to rule")
  needle("C:service", "B", "Attorney's Proof of Service", "(Code Civ. Proc.")
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  -- the one section: fb render's centered page-number footer, none on the cover page (titlePg); 1.1 in top margin
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage"/>'
    .. '<w:footerReference w:type="first" r:id="rIdFtrNone"/>'
    .. '<w:footnotePr><w:numFmt w:val="decimal"/><w:numRestart w:val="continuous"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1580" w:right="2160" w:bottom="1440" w:left="2160" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/><w:titlePg/></w:sectPr>')

  local out = {}
  local function addall(xs) for _, x in ipairs(xs) do out[#out + 1] = x end end
  addall(cover(m))
  addall(toc(entries))
  addall(toa(authorities, occurrences))
  -- the body starts on a new page
  out[#out + 1] = raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')
  addall(body)
  addall({ raw(table.concat(signature(m))) })
  addall(word_count(m, words))
  addall(service(m))
  return pandoc.Pandoc(out, pandoc.Meta({})) -- no title block: the frontmatter is consumed here
end
