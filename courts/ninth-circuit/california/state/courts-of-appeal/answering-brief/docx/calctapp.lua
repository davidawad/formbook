-- California Court of Appeal (calctapp) answering brief: pandoc filter for the docx engine. The same content as the
-- typst template (typst/calctapp-answering-brief.typ) from the same markdown contract, in its order:
--   the cover (rule 8.204(b)(10); page 1, no number shown), the certificate of interested entities or persons (rule
--   8.208), the table of contents and the table of authorities (rule 8.204(a)(1)(A)), the body (heading labels as
--   typst: I./A./1./a. in the Argument, A./1./a./(1) elsewhere), the signature block kept with the last paragraph,
--   the certificate of compliance (rule 8.204(c)(1)) and the proof of service (rule 8.212, when `service` is given).
-- Styles and the page come from docx/reference.xml (fb render builds reference.docx from it): one section, arabic
-- page numbers from the cover on, the cover's number not shown (titlePg).
-- The pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of every
-- heading and citation in that PDF (the needles this filter writes to FORMBOOK_NEEDLES), and renders again with those
-- pages (FORMBOOK_PAGES) until they settle; this filter writes the document's section (FORMBOOK_FINAL). Word may
-- paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local WORD_LIMIT = 14000   -- rule 8.204(c)(1), computer-produced brief (typst: word-limit)
local TOC_DEPTH = 4        -- heading levels listed in the contents (typst: toc-depth)
local PASSIM = 7           -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local NEEDLE_MAX = 60      -- a needle is a prefix of the text (letters and digits only)
local TEXT_W = 7920        -- the text width: 8.5 in less 1.5 in on each side, in twips
local TAB_R = TEXT_W - 20  -- the right tab of the tables: 1 pt inside the margin (a glyph may overhang)
local HALF = TEXT_W // 2   -- the signature block starts at the middle of the text (typst: pad(left: 50%))
local TYPEFACE = "TeX Gyre Schola"
local COURT = "IN THE COURT OF APPEAL OF THE STATE OF CALIFORNIA"
local NBSP = "\u{00A0}"

local stringify = pandoc.utils.stringify

-- pandoc.utils.type: "List" for a YAML list, "table" for a map, "Inlines" for a single value.
local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then return v end
  return { v }
end

local function need(m, k)
  if m[k] == nil then error("calctapp: missing required metadata field `" .. k .. "`", 0) end
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

-- A check box drawn as a bordered run (no symbol font, so no fallback face; docs/DOCX.md, lessons from ca9).
local function checkbox(checked)
  return '<w:r><w:rPr><w:bdr w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:rPr><w:t xml:space="preserve">'
    .. (checked and "X" or (NBSP .. NBSP)) .. "</w:t></w:r>"
end

-- A section heading of the front and back matter (typst: a level-1 heading, bold capitals, centered, in the
-- outline): the Heading 1 style, so the PDF has a bookmark for it.
local function heading1(text, brk)
  return p(run(text, { b = true, caps = true }), { style = "Heading1", jc = "center", keep = true, brk = brk, before = 0, after = 240 })
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

-- typst count-words: the body markdown, markup removed, links keep their text, split on whitespace.
local function count_words()
  local f = PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then error("calctapp: cannot read the sample markdown for the word count", 0) end
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

-- The label of a numbered heading (typst heading-label).
local function heading_label(level, k, arg)
  if level < 2 then return nil end
  if level > 5 then error("calctapp: headings deeper than level 5 are not supported", 0) end
  if arg then
    return ({ roman(k) .. ".", string.char(64 + k) .. ".", tostring(k) .. ".", string.char(96 + k) .. "." })[level - 1]
  end
  return ({ string.char(64 + k) .. ".", tostring(k) .. ".", string.char(96 + k) .. ".", "(" .. k .. ")" })[level - 1]
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body): centered, rules between the parts, one page
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local function add(x) out[#out + 1] = x end
  local gap = 160
  local short = { rule = "single", left = (TEXT_W - 2880) // 2, right = (TEXT_W - 2880) // 2, after = gap, before = 0 }
  local function c(body, o)
    o = o or {}
    o.jc = "center"
    o.after = o.after or 0
    return p(body, o)
  end
  add(c(run("No. ", { b = true }) .. mruns(need(m, "case_number"), { b = true }), { after = gap }))
  add(p("", { rule = "double", after = gap }))
  add(c(run(COURT, { b = true }), { after = 80 }))
  add(c(mruns(need(m, "district"), { b = true, caps = true }), { after = gap }))
  add(p("", short))
  local sides = items(need(m, "caption"))
  for i, side in ipairs(sides) do
    for _, n in ipairs(items(side.names)) do add(c(mruns(n))) end
    add(c(mruns(side.designation)))
    if i < #sides then add(c(run("v."), { before = 60, after = 60 })) end
  end
  add(p("", { rule = "single", left = short.left, right = short.right, before = 0, after = gap }))
  add(c(mruns(need(m, "proceeding"))))
  add(c(mruns(need(m, "trial_judge")) .. run(" \u{2013} Case No. ") .. mruns(need(m, "trial_case_number")), { after = gap }))
  add(p("", short))
  add(c(mruns(need(m, "brief_title"), { b = true, caps = true }), { after = gap }))
  add(p("", short))
  -- Counsel: the lead group centered across the page, the others in two columns (typst: a grid).
  local groups = items(need(m, "counsel"))
  -- a parenthetical on a counsel line (a bar number) is kept whole (typst: show regex as box)
  local function whole(v) return (stringify(v):gsub("%b()", function(s) return (s:gsub(" ", NBSP)) end)) end
  local function group(g, jc)
    local x = {}
    for _, n in ipairs(items(g.names)) do x[#x + 1] = p(run(whole(n)), { jc = jc }) end
    for _, l in ipairs(items(g.lines)) do x[#x + 1] = p(run(whole(l), { i = true }), { jc = jc }) end
    return table.concat(x)
  end
  if groups[1] then add(group(groups[1], "center")) end
  if #groups > 1 then
    local cells, rows = {}, {}
    for i = 2, #groups do cells[#cells + 1] = group(groups[i], "left") end
    local col = TEXT_W // 2
    for i = 1, #cells, 2 do
      local function cell(x) return '<w:tc><w:tcPr><w:tcW w:w="' .. col .. '" w:type="dxa"/></w:tcPr>' .. (x or "<w:p/>") .. "</w:tc>" end
      rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(cells[i]) .. cell(cells[i + 1]) .. "</w:tr>"
    end
    add(p("", { after = 0, line = 120 }))
    add('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblCellMar>'
      .. '<w:left w:w="0" w:type="dxa"/><w:right w:w="60" w:type="dxa"/><w:bottom w:w="120" w:type="dxa"/></w:tblCellMar>'
      .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="' .. col .. '"/><w:gridCol w:w="' .. col
      .. '"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>")
  end
  add(c(mruns(need(m, "counsel_for"), { i = true }), { before = gap, after = gap }))
  add(p("", { rule = "double", after = 0 }))
  return { raw(table.concat(out)) }
end

-- ---------------------------------------------------------------------------
-- Certificate of interested entities or persons (typst interested-page; rule 8.208)
-- ---------------------------------------------------------------------------

local function interested(m)
  local ie = m.interested_entities
  local none = ie == nil or stringify(ie) == "none"
  local supplemental = m.certificate_type ~= nil and stringify(m.certificate_type) == "supplemental"
  local sig = need(m, "signature")
  local x = { heading1("Certificate of Interested Entities or Persons", true) }
  local function add(s) x[#x + 1] = s end
  add(p(run("Case Name: ") .. mruns(need(m, "short_caption")) .. BR .. run("Court of Appeal No. ") .. mruns(need(m, "case_number")), { after = 200 }))
  add(p(run("(Check One)" .. NBSP .. NBSP .. NBSP) .. checkbox(not supplemental) .. run(" Initial Certificate" .. NBSP .. NBSP .. NBSP .. NBSP)
    .. checkbox(supplemental) .. run(" Supplemental Certificate"), { after = 200 }))
  add(p(checkbox(none) .. run(" There are no interested entities or persons to list in this Certificate per California Rules of Court, rule 8.208(d)."),
    { left = 420, hanging = 420, lines = true, after = 200 }))
  if not none then
    add(p(checkbox(true) .. run(" Interested entities or persons are listed below:"), { left = 420, hanging = 420, after = 120 }))
    for _, e in ipairs(items(ie)) do
      add(p(mruns(e.name) .. run(" (" .. stringify(e.party or "") .. ") ") .. mruns(e.interest), { left = 840, hanging = 420, lines = true, after = 120 }))
    end
  end
  add(p(run("The undersigned certifies that the above listed persons or entities (corporations, partnerships, firms or any other association, but not including government entities or their agencies), have either (i) an ownership interest of 10 percent or more in the party if an entity; or (ii) a financial or other interest in the outcome of the proceeding that the justices should consider in determining whether to disqualify themselves, as defined in rule 8.208(e)(2)."), { after = 240 }))
  add(p(run("Date: ") .. mruns(m.date or "__________"), { keep = true, after = 280 }))
  add(p(run("s/ ") .. mruns(sig.signer), { keep = true }))
  local lines = items(sig.lines)
  add(p(mruns(sig.signer, { caps = true }), { keep = #lines > 0 }))
  for i, l in ipairs(lines) do add(p(mruns(l, { i = true }), { keep = i < #lines })) end
  return { raw(table.concat(x)) }
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities (typst toc-section, toa-section)
-- ---------------------------------------------------------------------------

local function toc(entries)
  local x = { p(run("Table of Contents", { b = true, caps = true }), { jc = "center", brk = true, keep = true, after = 120 }),
    p(run("Page", { b = true, u = true }), { jc = "right", keep = true, after = 160 }) }
  for _, e in ipairs(entries) do
    local lead, left = "", 720
    if e.label then
      lead = run(e.label) .. TAB
      left = e.ind + 720
    elseif e.level >= 2 then
      left = (e.level - 2) * 720 + 720
    end
    local title = e.level == 1 and run(e.text, { caps = true }) or run(e.text)
    x[#x + 1] = p(lead .. title .. run(" ") .. TAB .. run(label_of(e.id)),
      { tabs = DOT_TAB, left = left, right = 620, hanging = 720, lines = true, before = e.level == 1 and 120 or 60 })
  end
  return { raw(table.concat(x)) }
end

local GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function toa(authorities, occurrences)
  local x = { heading1("Table of Authorities", true) }
  local first = true
  for _, g in ipairs(GROUPS) do
    local members = {}
    local used = {}
    for _, o in ipairs(occurrences) do used[o.key] = true end
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
      x[#x + 1] = p(head, { tabs = '<w:tab w:val="right" w:pos="' .. TAB_R .. '"/>', keep = true, before = first and 240 or 320, after = 40 })
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
-- Signature block and certificates (typst signature-block, certificate-of-compliance, certificate-of-service)
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = need(m, "signature")
  local x = {}
  if m.date then x[#x + 1] = p(run("Date: ") .. mruns(m.date), { keep = true, before = 280, after = 160 }) end
  x[#x + 1] = p(run("Respectfully submitted,"), { left = HALF, keep = true })
  if sig.firm then x[#x + 1] = p(mruns(sig.firm, { caps = true }), { left = HALF, keep = true }) end
  -- the signature line: an underlined tab to 2.6 in past "By:" (typst: a 2.6 in rule)
  x[#x + 1] = p(run("By: ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    { left = HALF, keep = true, before = 280, tabs = '<w:tab w:val="left" w:pos="' .. (HALF + 3744) .. '"/>' })
  local lines = items(sig.lines)
  x[#x + 1] = p(mruns(sig.signer), { left = HALF, keep = #lines > 0 })
  for i, l in ipairs(lines) do x[#x + 1] = p(mruns(l, { i = true }), { left = HALF, keep = i < #lines }) end
  return { raw(table.concat(x)) }
end

local function compliance(m, words)
  local sig = need(m, "signature")
  local x = { heading1("Certificate of Compliance", true) }
  x[#x + 1] = p(run("The foregoing ") .. mruns(need(m, "brief_title")) .. run(" complies with the type-volume limitation of California Rules of Court, rule 8.204(c)(1) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by rule 8.204(c)(3), and was prepared in 13-point " .. TYPEFACE .. ", a proportionally spaced typeface, using a word-processing program. The electronic brief was subject to a virus scan and no virus was detected prior to its submission."), { after = 280 })
  x[#x + 1] = p(run("Dated: ") .. mruns(m.date or "__________"), { keep = true, after = 280 })
  local lines = items(sig.lines)
  x[#x + 1] = p(mruns(sig.signer), { left = HALF, keep = #lines > 0 })
  for i, l in ipairs(lines) do x[#x + 1] = p(mruns(l, { i = true }), { left = HALF, keep = i < #lines }) end
  return { raw(table.concat(x)) }
end

local function service(m)
  local svc = m.service
  local x = { heading1("Certificate of Service", true) }
  local function add(body, o) o = o or {}; o.after = o.after or 240; x[#x + 1] = p(body, o) end
  add(run("At the time of service, I was over 18 years of age and not a party to this action. I am employed in the County of ")
    .. mruns(svc.county) .. run(", State of California. My business address is ") .. mruns(svc.address) .. run("."))
  add(run("On the date set forth below, I served one true copy of the following document(s) described as ")
    .. mruns(need(m, "brief_title")) .. run(" on the interested parties in this action as follows:"))
  for _, method in ipairs(items(svc.methods)) do add(mruns(method)) end
  for _, u in ipairs(items(svc.served)) do
    x[#x + 1] = p(mruns(u.name), { left = 720, keep = true, lines = true })
    add(mruns(u.address), { left = 720, lines = true })
  end
  add(run("I declare under penalty of perjury under the laws of the State of California that the foregoing is true and correct."))
  add(run("Executed on ") .. mruns(m.date or "__________") .. run(" at ") .. mruns(svc.place) .. run(", California."), { keep = true, after = 280 })
  x[#x + 1] = p(mruns(svc.declarant), { left = HALF })
  return { raw(table.concat(x)) }
end

-- ---------------------------------------------------------------------------
-- The brief
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "case_number", "district", "caption", "proceeding", "trial_judge", "trial_case_number",
    "brief_title", "short_caption", "counsel", "counsel_for", "signature" }) do
    need(m, k)
  end
  local authorities = m.authorities or {}
  local words = count_words()
  if words > WORD_LIMIT then
    error("calctapp: the brief has " .. words .. " words; rule 8.204(c)(1) allows " .. WORD_LIMIT, 0)
  end

  -- Citations, in document order: each `toa:` link is an occurrence and a needle (kind N inside a footnote).
  local occurrences = {}
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        if not authorities[key] then error("calctapp: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
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
  local counts, arg = { 0, 0, 0, 0, 0, 0 }, false
  local body, entries, h_n = {}, {}, 0
  for i, b in ipairs(src) do
    if b.t == "Header" then
      if b.level == 1 then arg = norm(stringify(b.content)) == "argument" end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      local lab = heading_label(b.level, counts[b.level], arg)
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = src[i + 1] and stringify(src[i + 1]):sub(1, 40) or ""
      needle(id, "B", (lab and (lab .. " ") or "") .. stringify(b.content), nxt)
      if b.level <= TOC_DEPTH then
        entries[#entries + 1] = { id = id, level = b.level, label = lab, text = stringify(b.content), ind = (b.level - 2) * 720 }
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
    body[#body] = pandoc.Div({ body[#body] }, pandoc.Attr("", {}, { ["custom-style"] = "Calctapp Body Keep" }))
  end

  -- The needles in page order: the cover, the certificate of interested entities, the two tables, the body, the
  -- certificates. Pages are numbered from the cover on (typst: numbering continues from the cover).
  local front = {
    { "S:cover", "No. " .. stringify(m.case_number), COURT },
    { "S:cie", "Certificate of Interested Entities or Persons", "Case Name" },
    { "S:toc", "Table of Contents", "Page" },
  }
  local first_group = ""
  for _, g in ipairs(GROUPS) do
    for _, o in ipairs(occurrences) do
      if first_group == "" and stringify(authorities[o.key].kind) == g[1] then first_group = g[2] end
    end
  end
  front[#front + 1] = { "S:toa", "Table of Authorities", first_group .. " Page(s)" }
  local f = {}
  for _, x in ipairs(front) do
    f[#f + 1] = { id = x[1], kind = "B", needle = norm(x[2] .. " " .. x[3]):sub(1, NEEDLE_MAX), fallback = norm(x[2]):sub(1, NEEDLE_MAX) }
  end
  for i = #f, 1, -1 do table.insert(needles, 1, f[i]) end
  needle("C:compliance", "B", "Certificate of Compliance", "The foregoing")
  if m.service then needle("C:service", "B", "Certificate of Service", "At the time of service") end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  -- the one section: reference.xml's (the centered page-number footer, none on the cover page)
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdCalctappFooter"/>'
    .. '<w:footnotePr><w:numRestart w:val="continuous"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1580" w:right="2160" w:bottom="1440" w:left="2160" w:header="720" w:footer="720" w:gutter="0"/>'
    .. "<w:titlePg/></w:sectPr>")

  local items_toc = { { id = "S:cie", level = 1, text = "Certificate of Interested Entities or Persons" },
    { id = "S:toa", level = 1, text = "Table of Authorities" } }
  for _, e in ipairs(entries) do items_toc[#items_toc + 1] = e end
  items_toc[#items_toc + 1] = { id = "C:compliance", level = 1, text = "Certificate of Compliance" }
  if m.service then items_toc[#items_toc + 1] = { id = "C:service", level = 1, text = "Certificate of Service" } end

  local out = {}
  local function addall(xs) for _, x in ipairs(xs) do out[#out + 1] = x end end
  addall(cover(m))
  addall(interested(m))
  addall(toc(items_toc))
  addall(toa(authorities, occurrences))
  -- the body starts on a new page
  out[#out + 1] = raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')
  addall(body)
  addall(signature(m))
  addall(compliance(m, words))
  if m.service then addall(service(m)) end
  return pandoc.Pandoc(out, pandoc.Meta({})) -- no title block: the frontmatter is consumed here
end
