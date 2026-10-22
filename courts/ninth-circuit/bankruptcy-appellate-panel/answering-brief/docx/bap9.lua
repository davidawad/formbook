-- Bankruptcy Appellate Panel of the Ninth Circuit, appellee's answering brief: DOCX engine (docs/DOCX.md).
-- The markdown contract (the frontmatter of usage/INPUT-*.md, as in typst/bap9-answering-brief.typ) becomes a Word
-- document on docx/reference.docx (built by docx/build-reference.sh with the shared style recipe). pandoc writes the
-- body text (paragraphs, quotations, footnotes) and this filter writes what needs Word formatting: the cover, the
-- table of contents and the table of authorities with their pages, the headings, lists, the signature block and the
-- certificates, as paragraphs with the typst template's pitches, spaces, indents and columns (the cross-engine
-- layout model, lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"), so LibreOffice and Word break every
-- line and page where typst does.
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of every heading and citation in
-- the LibreOffice PDF (the needles this filter writes) and renders again with those pages (FORMBOOK_PAGES).
-- Sections: cover (no page number), front matter (i, ii ...), body and certificates (1, 2 ...); fb render writes
-- the footers, this filter the last section (FORMBOOK_FINAL).
-- The three BAP9 filters (opening, answering, reply) are one text; only CFG differs.

local CFG = {
  kind = "answering",
  title = "Appellee\u{2019}s Answering Brief", -- the typst title, its apostrophe as the smart reader sets it
  word_limit = 13000,
  -- BAP-CONTENT-001: FRBP 8014(b): the summary, argument and conclusion remain required (the titles a brief may use).
  required = {
    { "Summary of Argument", "Summary of the Argument" },
    { "Argument", "Discussion" },
    { "Conclusion" },
  },
  authorities_required = false,
  -- BAP-CERT-001: interested parties (no related cases for an appellee), compliance, service
  certs = { "interested-parties", "compliance", "service" },
  -- the typeface (typst font-family) and its line pitches (typst pitch-double, pitch-single), in twips
  font = "Times New Roman",
  double = 620,
  single = 340,
  -- advances at 14 pt, in twips, for the width of a page list (typst measures it): a digit, a comma, a space
  digit = 140, comma = 70, space = 70,
}

local COURT = "United States Bankruptcy Appellate Panel of the Ninth Circuit"
local TEXT_W = 9360    -- the text width, 6.5 in
local TAB = 720        -- typst para-indent
local PNUM_TOC = 720   -- typst toc-page-col (36 pt)
local PNUM_TOA = 1120  -- typst toa-page-col (56 pt)
local HANG = 576       -- typst toa-hang (0.4 in)
local SIG = 4320       -- typst sig-indent (3 in)
local PASSIM = 7       -- typst passim-threshold
-- typst `space`, in twips (20 x pt)
local SP = {
  cover = 360, cover_small = 200,
  h1 = { 480, 280 }, h2 = { 400, 240 }, h3 = { 360, 240 },
  toc_row = 120, toa_group = { 360, 120 },
  sig = 480, cert = { 480, 280 }, cert_par = 240,
}
local NEEDLE_MAX = 60

local stringify = pandoc.utils.stringify
local xe = require("docx.xengine")
-- No break inside a token of adjacent parentheses ("362(a)(4)"): typst boxes it; LibreOffice would break between ")"
-- and "(" (Unicode line breaking allows it), so a word joiner binds them.
local function glue(s) return (s:gsub("%)%(", ")\u{2060}(")) end
local function glue_inlines(l)
  return pandoc.Inlines(l):walk({ Str = function(el) return pandoc.Str(glue(el.text)) end })
end
local function runs(t, o) return xe.runs(glue(t), o) end
local function inl(x, o)
  if x == nil or type(x) == "string" then return xe.inl(x and glue(x), o) end
  return xe.inl(glue_inlines(x), o)
end
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.LEAD

local function spacing(before, after, line)
  return xe.spacing(before, after, line or CFG.single)
end

local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="676" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section (1 pt tall) and carries its properties.
local function section(footer, fmt)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function bail(msg) error("bap9-" .. CFG.kind .. ": " .. msg, 0) end

local function need_meta(meta, k)
  if meta[k] == nil then bail("missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function has_cert(c)
  for _, x in ipairs(CFG.certs) do if x == c then return true end end
  return false
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

local function norm(s) return (s:lower():gsub("[^a-z0-9]", "")) end

local needles = {}
-- The fallback of a needle that runs over a page end (the page's footnotes come between its halves in the PDF
-- text): the text's first word, which is where typst files the citation (its tag follows the first word). Found
-- from the needle before it on, so it is the next occurrence of that word.
local function opening(text)
  for w in text:gmatch("%S+") do
    local n = norm(w)
    if n ~= "" then return n:sub(1, NEEDLE_MAX) end
  end
  return ""
end

local function need(id, kind, text, context)
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

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Word count: typst count-words on the body markdown (after the frontmatter): link targets dropped, every
-- space-separated token with a letter or digit
-- ---------------------------------------------------------------------------
local function body_words()
  local f = PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then bail("cannot read the sample markdown for the word count") end
  local text = h:read("a")
  h:close()
  local body = text:match("^%-%-%-[ \t]*\r?\n.-\n%-%-%-[ \t]*\r?\n(.*)$") or text
  body = body:gsub("%]%([^%)]*%)", "]"):gsub("[\t\r\n]", " ")
  local n = 0
  for tok in body:gmatch("[^ ]+") do
    if tok:find("[A-Za-z0-9]") then n = n + 1 end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover): centered single-spaced lines, the gaps as space above
-- ---------------------------------------------------------------------------
local function cover(meta)
  local out = {}
  local function line(before, body)
    out[#out + 1] = para({ spacing(before, 0), ind(0, nil, 0), jc("center") }, body)
  end
  line(0, inl(need_meta(meta, "case_number"), { b = true }))
  if meta.district_court_case then line(0, inl(meta.district_court_case)) end
  line(SP.cover, runs(COURT:upper(), { b = true }))
  local first = true
  if meta.bankruptcy_case then
    for _, n in ipairs(meta.bankruptcy_case.names) do line(first and SP.cover or 0, inl(n)); first = false end
    line(0, inl(meta.bankruptcy_case.designation))
  end
  for i, side in ipairs(need_meta(meta, "caption")) do
    if i > 1 then line(SP.cover_small, runs("v.")) end
    for k, n in ipairs(side.names) do
      line(k == 1 and (i == 1 and SP.cover or SP.cover_small) or 0, inl(n))
    end
    line(0, inl(side.designation))
  end
  local proceeding = need_meta(meta, "proceeding")
  if stringify(proceeding) ~= "" then line(SP.cover, inl(proceeding)) end
  if meta.brief_title then
    line(SP.cover, inl(meta.brief_title, { b = true, caps = true }))
  else
    line(SP.cover, runs(CFG.title:upper(), { b = true }))
  end
  local groups = need_meta(meta, "counsel")
  for gi, g in ipairs(groups) do
    for ni, n in ipairs(g.names) do
      line(ni == 1 and (gi == 1 and SP.cover or SP.cover_small) or 0, inl(n))
    end
    for _, l in ipairs(g.lines or {}) do line(0, inl(l)) end
    if gi == #groups then line(0, inl(need_meta(meta, "phone"))) end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Tables (typst listing-row): the text wraps before the page column (the right indent); a dot leader on a right
-- tab at the margin runs from three spaces after the text to the page
-- ---------------------------------------------------------------------------
local function title_para(text, brk)
  return para({ KEEP, brk and BREAK or "", spacing(0, SP.h1[2]), ind(0, nil, 0), jc("center") },
    runs(text:upper(), { b = true }))
end

local function listing_row(body, page, col, left, hang, keep)
  return para({ keep and KEEP or LINES, xe.leader_tab(TEXT_W), spacing(SP.toc_row, 0), ind(left, hang, nil, col) },
    body .. runs(LEAD) .. page)
end

local function toc_row(h)
  local label = labels[h.id] and labels[h.id].label or "00"
  local step = (h.level - 1) * TAB
  return listing_row(inl(h.content), runs(label), PNUM_TOC, step + TAB, TAB)
end

local GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "rule", "Rules" }, { "regulation", "Regulations" }, { "other", "Other Authorities" },
}

-- typst sort-key: the sort field, else name and cite, without markup, straight quotes, digit runs padded
local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite or ""))
  s = s:lower():gsub("\u{2018}", "'"):gsub("\u{2019}", "'"):gsub("\u{201C}", '"'):gsub("\u{201D}", '"')
  return (s:gsub("%d+", function(d) return string.rep("0", math.max(0, 10 - #d)) .. d end))
end

local occurrences = {} -- the authority links in document order: { key }

local function toa_rows(authorities)
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if (a.kind and stringify(a.kind) or "other") == g[1] then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      out[#out + 1] = para({ KEEP, spacing(SP.toa_group[1], SP.toa_group[2]), ind(0, nil, 0) }, runs(g[2], { b = true }))
      for _, m in ipairs(members) do
        local pages, seen = {}, {}
        for i, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. i]
            local p = l and l.page or 0
            if not seen[p] then
              seen[p] = true
              pages[#pages + 1] = { page = p, label = l and l.label or "00" }
            end
          end
        end
        if #pages == 0 then bail("authority `" .. m.key .. "` is listed but never cited") end
        table.sort(pages, function(x, y) return x.page < y.page end)
        local shown
        if #pages >= PASSIM then
          shown = "passim"
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          shown = table.concat(l, ", ")
        end
        -- typst: the page column is the larger of 56 pt and the list's own width
        local w = 0
        for c in shown:gmatch(".") do
          w = w + (c:match("%d") and CFG.digit or c == "," and CFG.comma or c == " " and CFG.space or CFG.digit)
        end
        local col = math.max(PNUM_TOA, math.ceil(w))
        local a = m.a
        local body = ""
        if a.name and stringify(a.name) ~= stringify(a.cite) then body = inl(a.name) .. runs(", ") end
        body = body .. inl(a.cite)
        out[#out + 1] = listing_row(body, runs(shown), col, HANG, HANG)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings, signature, certificates
-- ---------------------------------------------------------------------------
-- A body heading; `top`: it opens a page (Word keeps space above there, typst drops it). Level 1 centered, as
-- written (the Heading 1 style's capitals are turned off: typst does not capitalize); levels 2 and 3 hang.
local function heading_xml(level, content, top)
  if level == 1 then
    return para({ style("Heading1"), KEEP, spacing(top and 0 or SP.h1[1], SP.h1[2]), ind(0, nil, 0), jc("center") },
      (inl(content, { b = true }):gsub("</w:rPr>", "<w:caps w:val=\"0\"/></w:rPr>")))
  end
  local s = level == 2 and SP.h2 or SP.h3
  return para({ style("Heading" .. math.min(level, 5)), KEEP, spacing(top and 0 or s[1], s[2]), ind(TAB, TAB) },
    inl(content, { b = true }))
end

local function signature(meta)
  local sig = need_meta(meta, "signature")
  local lines = { runs("/s/ ") .. inl(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = inl(l) end
  if meta.date then lines[#lines + 1] = inl(meta.date) end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = para({ i < #lines and KEEP or LINES, spacing(i == 1 and SP.sig or 0, 0), ind(SIG, nil, 0) }, l)
  end
  return table.concat(out)
end

local function certificates(meta, words)
  local sig = need_meta(meta, "signature")
  local out = {}
  local first = true
  -- one certificate: kept on one page (every paragraph but the last kept with the next)
  local function cert(title, paras)
    local x = { para({ KEEP, first and BREAK or "", spacing(first and 0 or SP.cert[1], SP.cert[2]), ind(0, nil, 0),
      jc("center") }, runs(title:upper(), { b = true })) }
    paras[#paras + 1] = { SIG, runs("/s/ ") .. inl(sig.signer) }
    for i, p in ipairs(paras) do
      local left, hang = 0, nil
      if p[1] == HANG then left, hang = HANG, HANG elseif p[1] == SIG then left = SIG end
      x[#x + 1] = para({ i < #paras and KEEP or LINES, spacing(SP.cert_par, 0), ind(left, hang, hang == nil and 0 or nil) }, p[2])
    end
    out[#out + 1] = table.concat(x)
    first = false
  end
  if has_cert("interested-parties") then
    local ps = { { 0, runs("The following listed parties have an interest in the outcome of this case. These representations are made in order that judges of the Panel may evaluate possible disqualification or recusal.") } }
    for _, p in ipairs(need_meta(meta, "interested_parties")) do ps[#ps + 1] = { HANG, inl(p) } end
    cert("Certification of Interested Parties", ps)
  end
  if has_cert("related-cases") then
    local rc = need_meta(meta, "related_cases")
    local status = rc.status and stringify(rc.status) or "none"
    local ps
    if status == "none" then
      ps = { { 0, runs("Appellant is aware of no related cases or appeals pending before this Panel, the Ninth Circuit Court of Appeals, or the district court.") } }
    else
      ps = { { 0, runs("The following related cases and appeals are known to the appellant:") } }
      for _, c in ipairs(rc.cases or {}) do
        ps[#ps + 1] = { HANG, inl(c.number) .. runs(", ") .. inl(c.name) .. runs(", ") .. inl(c.relationship) }
      end
    end
    cert("Certification of Related Cases", ps)
  end
  if has_cert("compliance") then
    cert("Certificate of Compliance", {
      { 0, runs("This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g).") },
      { 0, runs("This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, 14-point " .. CFG.font .. ", with plain roman type and italics for emphasis.") },
    })
  end
  if has_cert("service") then
    local svc = meta.service or {}
    local unreg = svc.unregistered or {}
    local ps = { { 0, runs("I hereby certify that on ") .. inl(need_meta(meta, "date")) .. runs(", I electronically filed the foregoing document with the Clerk of the Court for the Bankruptcy Appellate Panel for the Ninth Circuit by using the CM/ECF system.") } }
    if #unreg == 0 then
      ps[#ps + 1] = { 0, runs("I certify that all parties of record to this appeal either are registered CM/ECF users, or have registered for electronic notice, or have consented in writing to electronic service, and that service will be accomplished through the CM/ECF system.") }
    else
      ps[#ps + 1] = { 0, runs("I further certify that parties of record to this appeal who either are registered CM/ECF users, or who have registered for electronic notice, or who have consented in writing to electronic service, will be served through the CM/ECF system.") }
      ps[#ps + 1] = { 0, runs("I further certify that some of the parties of record to this appeal have not consented to electronic service. I have mailed the foregoing document by First-Class Mail, postage prepaid, or have dispatched it to a third party commercial carrier for delivery within 3 calendar days, to the following parties:") }
      for _, u in ipairs(unreg) do ps[#ps + 1] = { HANG, inl(u.name) .. runs(", ") .. inl(u.address) } end
    end
    cert("Certificate of Service", ps)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Citations in document order (the needles of the table of authorities)
-- ---------------------------------------------------------------------------
local scan_blocks

local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      occurrences[#occurrences + 1] = { key = el.target:sub(5) }
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
    Link = function(el) if el.target:match("^toa:") then return el.content end end,
    Inlines = function(l) return glue_inlines(xe.inlines(l)) end,
  }).blocks
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

local function next_text(blocks, i)
  local b = blocks[i + 1]
  if not b then return "" end
  return stringify(b):sub(1, 40)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------
function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "counsel", "phone", "signature" }) do need_meta(meta, k) end
  local authorities = meta.authorities
  if CFG.authorities_required then need_meta(meta, "authorities") end

  -- required level-1 headings (BAP-CONTENT-001), with or without a roman enumerator, in any case
  local check = not (meta.section_check ~= nil and stringify(meta.section_check) == "false")
  if check then
    local h1 = {}
    for _, b in ipairs(doc.blocks) do
      if b.t == "Header" and b.level == 1 then
        h1[(stringify(b.content):lower():gsub("^[ivxlc]+%.%s+", ""))] = true
      end
    end
    for _, titles in ipairs(CFG.required) do
      local ok = false
      for _, t in ipairs(titles) do ok = ok or h1[t:lower()] end
      if not ok then bail("the brief has no level-1 heading `" .. table.concat(titles, "` or `") .. "` (FRBP 8014(a))") end
    end
  end

  -- length (BAP-LENGTH-001): the body only
  local words = body_words()
  if words > CFG.word_limit then bail("the brief has " .. words .. " words; FRBP 8015(a)(7) allows " .. CFG.word_limit) end

  -- the body, in order: headings (needles, contents entries) and citations (needles)
  local blocks = doc.blocks
  local headings, body = {}, {}
  local toc_first
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local id = "H:" .. i
      if i == 1 then id = "S:body" end
      need(id, "B", stringify(b.content), next_text(blocks, i))
      if b.level <= 2 then
        headings[#headings + 1] = { id = id, level = b.level, content = b.content }
        toc_first = toc_first or stringify(b.content)
      end
      body[#body + 1] = raw(heading_xml(b.level, b.content, #body == 0))
    else
      if i == 1 then need("S:body", "B", stringify(b), "") end
      scan_blocks({ b }, false)
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if not (authorities and authorities[o.key]) then bail("link `toa:" .. o.key .. "` has no entry under `authorities:`") end
  end
  body = strip_links(body)
  -- the last paragraph stays with the signature block (typst: the tail block is kept with it)
  local last = body[#body]
  if last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, CFG.double), ind(0, nil, TAB) }, inl(last.content)))
  end

  -- the needles of the front matter come first (document order)
  local front = {}
  local toc_need = { "S:toc", "B", "Table of Contents", toc_first or "" }
  local toa_first
  if authorities then
    for _, g in ipairs(GROUPS) do
      for _, a in pairs(authorities) do
        if (a.kind and stringify(a.kind) or "other") == g[1] then toa_first = g[2] end
      end
      if toa_first then break end
    end
  end
  local body_needles = needles
  needles = {}
  need(table.unpack(toc_need))
  if authorities then need("S:toa", "B", "Table of Authorities", toa_first or "") end
  for _, n in ipairs(body_needles) do needles[#needles + 1] = n end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tS:body\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  local out = {}
  local function add(x) out[#out + 1] = x end
  -- section 1: the cover
  add(raw(cover(meta)))
  add(section("rIdFtrNone"))
  -- section 2: the front matter (i, ii ...)
  add(raw(title_para("Table of Contents")))
  for _, h in ipairs(headings) do add(raw(toc_row(h))) end
  if authorities then
    add(raw(title_para("Table of Authorities", true)))
    add(raw(toa_rows(authorities)))
  end
  add(section("rIdFtrPage", "lowerRoman"))
  -- section 3: the body, the signature and the certificates (1, 2 ...)
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(certificates(meta, words)))

  doc.blocks = out
  doc.meta = pandoc.Meta({}) -- the frontmatter is consumed here; no title block
  return doc
end
