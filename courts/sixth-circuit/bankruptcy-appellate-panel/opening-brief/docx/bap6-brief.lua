-- United States Bankruptcy Appellate Panel of the Sixth Circuit, DOCX engine (docs/DOCX.md).
-- The markdown contract (typst/bap6-*.typ, README "Markdown contract") -> a Word document on docx/reference.docx,
-- on the cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box
-- of the typst pitch (exact line spacing), the typst template's spaces in twips (20 x pt), its break rules on every
-- run. Built here, as in the typst template: the cover (own section, no footer), the front matter (own section,
-- lower roman from i: disclosure, table of contents, table of authorities, oral-argument statement), the brief
-- (arabic from 1, the section FORMBOOK_FINAL: body, signature block, certificate of compliance, certificate of
-- service, addendum). The pages in the contents and the table of authorities (FRBP 8014(a)(2)-(3)): fb render
-- (tools/fb/src/docxpass.rs) renders the document once, finds the page of every heading and citation in that PDF
-- (the needles this filter writes to FORMBOOK_NEEDLES), and renders again with those pages (FORMBOOK_PAGES) until
-- they settle. The sections name fb render's empty footer (rIdFtrNone) and this filter's page-number footer
-- (rIdBapPage, FORMBOOK_FOOTERS: the number in a line box of the single pitch, as typst sets it). Word may
-- paginate slightly differently from the LibreOffice PDF the pages come from.
-- No case-specific text in this file. Metadata comes from the YAML frontmatter of the sample.

local xe = require("docx.xengine")

-- the only text that differs between the three copies of this file (see README "Engines")
local CFG = {
  kind = "opening",
  doc_title = "brief of appellant",
  word_limit = 13000,
  required = { "Statement of Jurisdiction", "Statement of the Issues", "Statement of the Case", "Summary of Argument", "Argument", "Conclusion" },
  oral_argument_required = true,
}

local FACE, SIZE = "Times New Roman", 14   -- typst font-family.first(), type-size
local KIND_ORDER = { "case", "constitution", "statute", "regulation", "rule", "other" }
local KIND_HEADING = {
  case = "Cases", constitution = "Constitutional Provisions", statute = "Statutes",
  regulation = "Regulations", rule = "Rules", other = "Other Authorities",
}
-- typst pitches and spaces, in twips
local SINGLE, H1, H2 = 364, 480, 400            -- pitch-single 18.2 pt, pitch-h1 24 pt, pitch-h2 20 pt
local H1_SZ, H2_SZ, TITLE_SZ = 39, 34, 32       -- 19.5, 17, 16 pt (half points)
local TEXTW = 9360                              -- 6.5 in: letter, 1 in margins
local TOC_STEP, TOC_COL, TOA_COL = 420, 720, 1120   -- toc-step 21 pt, toc-page-col 36 pt, toa-page-col 56 pt
local PASSIM = 7                                -- an authority cited on this many pages or more prints "passim"
local NEEDLE_MAX = 60                           -- a needle is a prefix of the text (letters and digits only)
local SIG_LEFT = 4680                           -- the signature block's left edge: half the text width
local SECT_LINE = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
local PAGE = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local SECT_COVER = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrNone"/>' .. PAGE .. '</w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="rIdBapPage"/>' .. PAGE
  .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

-- the page-number footer (FORMBOOK_FOOTERS): centered, in a line box of the single pitch, as typst's folio
local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="364" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
  .. '<w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE '
  .. '</w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'

local function fail(msg) error("bap6: " .. msg, 0) end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- a metadata value (markdown inlines or blocks) as a list of blocks
local function meta_blocks(v)
  if v == nil then return {} end
  if v.t == "MetaBlocks" then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b end
    return out
  end
  return { pandoc.Para(pandoc.Inlines(v)) }
end

-- One single-spaced line paragraph (style Bap Line), its properties in schema order. o: keep (keep with the next
-- paragraph), brk (page break before), tabs, before, after, line (twips), ind (xml), jc, body (runs).
local function line(o)
  local p = { xe.style("BapLine") }
  if o.keep then p[#p + 1] = xe.KEEP elseif o.lines then p[#p + 1] = xe.LINES end
  if o.brk then p[#p + 1] = xe.BREAK end
  if o.tabs then p[#p + 1] = o.tabs end
  p[#p + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  if o.ind then p[#p + 1] = o.ind end
  if o.jc then p[#p + 1] = xe.jc(o.jc) end
  return xe.raw(xe.para(p, o.body or ""))
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- typst's count-words, line by line, on the markdown source of the body (FRBP 8015(g): headings count)
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then fail("no input file to count words in") end
  local h = io.open(f, "r")
  if not h then fail("cannot open " .. f) end
  local text = h:read("a")
  h:close()
  local lines, dashes = {}, 0
  for l in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if l == "---" then dashes = dashes + 1 end
    elseif l:match("^#%s+[Aa]ddendum%s*$") then
      break
    else
      lines[#lines + 1] = l
    end
  end
  local n = 0
  for _, l in ipairs(lines) do
    local s = l
    s = s:gsub("^%[%^[^%]]+%]:", " ")
    s = s:gsub("%[%^[^%]]*%]", "")
    s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
    s = s:gsub("^#+%s+", "")
    s = s:gsub("^>%s?", "")
    s = s:gsub("^%s*[-*+]%s+", "")
    s = s:gsub("^%s*%d+[.)]%s+", "")
    s = s:gsub("\\(.)", "%1")
    s = s:gsub("%*", "")
    s = s:gsub("_", "")
    for _ in s:gmatch("%S+") do n = n + 1 end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- page numbers from the pass before (fb render, tools/fb/src/docxpass.rs and docxpages.rs)
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render (docxpages.rs) reduces the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- needles: { id, kind, needle, fallback }; kind B (body, in document order), N (inside a footnote)
local needles = {}
local function need(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- the pages of the previous pass: id -> { page, label }; empty on the first pass
local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, page, lab = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = lab } end
  end
  f:close()
end

-- the printed page of a needle: "0" on the first pass, the pass before's label afterwards
local function label_of(id)
  local l = labels[id]
  if l then return l.label end
  return "0"
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- the parts
-- ---------------------------------------------------------------------------

-- a heading as typst sets it (brief-style); top: it opens a page (no space above it)
local function heading(level, inlines, top, brk)
  local o = { keep = true, brk = brk }
  if level == 1 then
    o.before, o.after, o.line, o.jc = 448, 336, H1, "center"
    o.body = xe.inl(inlines, { b = true, sz = H1_SZ })
  elseif level == 2 then
    o.before, o.after, o.line = 336, 280, H2
    o.body = xe.inl(inlines, { b = true, sz = H2_SZ })
  elseif level == 3 then
    o.before, o.after, o.ind = 308, 280, xe.ind(720)
    o.body = xe.inl(inlines, { b = true })
  else
    o.before, o.after, o.ind = 280, 280, xe.ind(1440)
    o.body = xe.inl(inlines, { i = true })
  end
  if top then o.before = 0 end
  return line(o)
end

-- the signature block (typst signature-block): 22.4 pt above, at the middle of the line; `last_keep`: its last line
-- stays with what follows
local function signature(meta, out)
  local sig = meta.signature
  if sig == nil then return end
  local L = {}
  L[#L + 1] = { before = 448, body = xe.runs("Respectfully submitted,") }
  L[#L + 1] = { before = 336, body = xe.runs("s/ " .. plain(sig.signer)) }
  for _, l in ipairs(sig.lines or {}) do L[#L + 1] = { body = xe.inl(l) } end
  if meta.date then L[#L + 1] = { before = 224, body = xe.inl(meta.date) } end
  for i, o in ipairs(L) do
    o.ind = xe.ind(SIG_LEFT)
    o.keep = i < #L
    o.lines = true
    out[#out + 1] = line(o)
  end
end

-- body blocks as typst sets them: a paragraph that follows another is indented, any other is not; headings,
-- quotations and lists in the typst shapes. `top`: the first block opens a page.
local function body(blocks, out, toc, top)
  local prev = nil
  for i, b in ipairs(blocks) do
    local first = top and i == 1
    if b.t == "Header" then
      out[#out + 1] = heading(b.level, b.content, first)
      prev = "head"
    elseif b.t == "Para" or b.t == "Plain" then
      local st = prev == "para" and "Body Text" or "First Paragraph"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = st })
      prev = "para"
    elseif b.t == "BlockQuote" then
      local n = #b.content
      for j, q in ipairs(b.content) do
        local st = n == 1 and "Bap Quote Only" or j == 1 and "Bap Quote First" or j == n and "Bap Quote Last" or "Bap Quote"
        if q.t == "Para" or q.t == "Plain" then
          out[#out + 1] = pandoc.Div({ pandoc.Para(q.content) }, { ["custom-style"] = st })
        else
          out[#out + 1] = q
        end
      end
      prev = "quote"
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
      prev = "list"
    else
      out[#out + 1] = b
      prev = "other"
    end
  end
end

-- ---------------------------------------------------------------------------
-- the document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta

  -- registry of authorities (frontmatter `authorities:`)
  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
      if not KIND_HEADING[auth[key].kind] then fail("authority `" .. key .. "` has kind `" .. auth[key].kind .. "`") end
    end
  end

  local disclosure = meta.disclosure and meta_blocks(meta.disclosure) or nil
  local oral = meta.oral_argument and meta_blocks(meta.oral_argument) or nil

  -- body and addendum
  local main, addendum = {}, nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):match("^Addendum%s*$") then
      addendum = { table.unpack(doc.blocks, i) }
      break
    end
    main[#main + 1] = b
  end

  -- the rules the template enforces (FRBP 8014, 8015, 8019; LBR 8014-1(b))
  for _, s in ipairs(CFG.required) do
    local found = false
    for _, b in ipairs(main) do
      if b.t == "Header" and b.level == 1 and plain(b.content):sub(1, #s) == s then found = true end
    end
    if not found then fail("the sample has no `# " .. s .. "` section, required for a " .. CFG.kind .. " brief (FRBP 8014)") end
  end
  if CFG.oral_argument_required and not oral then
    fail("the frontmatter needs `oral_argument` for a " .. CFG.kind .. " brief (FRBP 8019(a); LBR 8014-1(b))")
  end
  local words = source_words()
  if words > CFG.word_limit then
    fail("the brief has " .. words .. " words; the limit for a " .. CFG.kind .. " brief is " .. CFG.word_limit .. " (FRBP 8015(a)(7)(B))")
  end

  -- Citations and headings, in page order: each `toa:` link is an occurrence and a needle (kind N inside a
  -- footnote), each heading a needle and a contents entry (typst lists every outlined heading). A needle is its
  -- text and what follows it, so a heading is found in the body, not at its entry in the table of contents.
  local used, occurrences, toc = {}, {}, {}
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        if not auth[key] then fail("link toa:" .. key .. " has no entry in the authorities registry") end
        used[key] = true
        occurrences[#occurrences + 1] = { key = key, id = "T:" .. (#occurrences + 1) }
        local rest = {}
        for j = i + 1, #list do rest[#rest + 1] = list[j] end
        -- typst records a citation where its link text ends (on the next page when the text runs over the page
        -- end), so the needle starts at the last word of the link text
        local last = ""
        for w in plain(el.content):gmatch("%S+") do if norm(w) ~= "" then last = w end end
        need(occurrences[#occurrences].id, in_note and "N" or "B", last, plain(rest))
      elseif el.t == "Note" then
        scan_blocks(el.content, true)
      elseif el.content ~= nil and type(el.content) == "table" and el.t ~= "Code" then
        scan_inlines(el.content, in_note)
      end
    end
  end
  scan_blocks = function(list, in_note)
    for _, b in ipairs(list) do
      if b.t == "Para" or b.t == "Plain" or b.t == "Header" then
        scan_inlines(b.content, in_note)
      elseif b.t == "BlockQuote" or b.t == "Div" then
        scan_blocks(b.content, in_note)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
      end
    end
  end
  local function text_after(blocks, i)
    return blocks[i + 1] and plain(blocks[i + 1]):sub(1, 40) or ""
  end
  local function toc_add(id, level, inls) toc[#toc + 1] = { id = id, level = level, inl = inls } end
  local function front(id, title, after, list)
    need(id, "B", title, after)
    toc_add(id, 1, pandoc.Inlines({ pandoc.Str(title) }))
    scan_blocks(list or {}, false)
  end
  local h_n = 0
  local function scan_body(blocks)
    for i, b in ipairs(blocks) do
      if b.t == "Header" then
        h_n = h_n + 1
        need("H:" .. h_n, "B", plain(b.content), text_after(blocks, i))
        toc_add("H:" .. h_n, b.level, b.content)
      end
      scan_blocks({ b }, false)
    end
  end
  -- the first group of the table of authorities (its heading's needle runs into it)
  local first_kind = nil
  for _, kind in ipairs(KIND_ORDER) do
    for _, a in pairs(auth) do if not first_kind and a.kind == kind then first_kind = kind end end
  end

  -- front matter, in page order
  local front_id = "F:toc"
  if disclosure then
    front_id = "F:disclosure"
    front(front_id, "Corporate Disclosure Statement", plain(disclosure[1]):sub(1, 40), disclosure)
  end
  need("F:toc", "B", "Table of Contents", "")
  front("F:toa", "Table of Authorities", first_kind and KIND_HEADING[first_kind] or "")
  if oral then front("F:oral", "Statement Regarding Oral Argument", plain(oral[1]):sub(1, 40), oral) end
  -- the brief
  local body_id = "S:body"
  if main[1] and main[1].t == "Header" then
    body_id = "H:1"
  elseif main[1] then
    need(body_id, "B", plain(main[1]):sub(1, NEEDLE_MAX), "")
  end
  scan_body(main)
  if addendum then scan_body(addendum) end
  for key in pairs(auth) do
    if not used[key] then fail("authority `" .. key .. "` is listed but never cited in the body") end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: the front matter from its first page (i, ii ...), the brief from its first block
  nl[#nl + 1] = "#section\t" .. front_id .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdBapPage\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdBapPage"/>' .. PAGE
    .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>')

  -- the text of a citation stays, the link goes; typst's break rules on every run pandoc writes
  local function prep(blocks)
    local d = pandoc.Pandoc(blocks):walk({ Link = function(el) if el.target:match("^toa:") then return el.content end end })
    return d:walk({ Inlines = xe.inlines }).blocks
  end
  if disclosure then disclosure = prep(disclosure) end
  if oral then oral = prep(oral) end
  main = prep(main)
  if addendum then addendum = prep(addendum) end

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- ---- cover (FRBP 8015(a)(2)): its own section, no footer (typst cover)
  local function cl(before, body) add(line({ before = before, jc = "center", body = body })) end
  cl(0, xe.runs("Case No. " .. plain(meta.case_number)))
  cl(252, xe.runs("United States Bankruptcy Appellate Panel of the Sixth Circuit", { b = true }))
  for i, side in ipairs(meta.caption or {}) do
    for j, n in ipairs(side.names or {}) do cl(j == 1 and 252 or 0, xe.inl(n)) end
    cl(0, xe.inl(side.designation))
    if i < #meta.caption then cl(252, xe.runs("v.")) end
  end
  cl(392, xe.inl(meta.proceeding))
  cl(392, xe.runs(pandoc.text.upper(plain(meta.brief_title)), { b = true, sz = TITLE_SZ }))
  for gi, group in ipairs(meta.counsel or {}) do
    for ni, n in ipairs(group.names or {}) do cl(ni > 1 and 0 or gi == 1 and 728 or 252, xe.inl(n)) end
    for _, l in ipairs(group.lines or {}) do cl(0, xe.inl(l)) end
  end
  if meta.phone then cl(252, xe.inl(meta.phone)) end
  if meta.date then cl(224, xe.inl(meta.date)) end
  add(xe.raw('<w:p><w:pPr>' .. SECT_LINE .. SECT_COVER .. '</w:pPr></w:p>'))

  -- ---- front matter (lower-roman footer)
  local opened = false   -- whether a page of the front matter has begun (the next heading breaks the page)
  if disclosure then
    add(heading(1, pandoc.Inlines({ pandoc.Str("Corporate Disclosure Statement") }), true))
    body(disclosure, out, nil, false)
    opened = true
  end
  add(heading(1, pandoc.Inlines({ pandoc.Str("Table of Contents") }), true, opened))
  local toc_tabs = xe.leader_tab(TEXTW)
  for _, e in ipairs(toc) do
    local ind = TOC_STEP * (e.level - 1)
    add(line({ lines = true, tabs = toc_tabs, before = 140, ind = xe.ind(ind + TOC_STEP, TOC_STEP, nil, TOC_COL),
      body = xe.inl(e.inl) .. xe.runs(xe.LEAD) .. xe.runs(label_of(e.id)) }))
  end

  add(heading(1, pandoc.Inlines({ pandoc.Str("Table of Authorities") }), true, true))
  for _, kind in ipairs(KIND_ORDER) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == kind then members[#members + 1] = key end
    end
    if #members > 0 then
      local function sk(k)
        local a = auth[k]
        return a.sort and plain(a.sort) or (a.name and plain(a.name) or plain(a.cite))
      end
      table.sort(members, function(x, y) return sk(x) < sk(y) end)
      add(line({ keep = true, before = 336, after = 224, body = xe.runs(KIND_HEADING[kind], { b = true }) }))
      for _, k in ipairs(members) do
        local a = auth[k]
        local il = pandoc.Inlines({})
        if a.name then
          if kind == "case" then il:insert(pandoc.Emph(pandoc.Inlines(a.name))) else il:extend(pandoc.Inlines(a.name)) end
          il:insert(pandoc.Str(","))
          il:insert(pandoc.Space())
        end
        il:extend(pandoc.Inlines(a.cite))
        -- the distinct pages of the authority, in page order (typst: passim from PASSIM pages)
        local pages, seen = {}, {}
        for oi, o in ipairs(occurrences) do
          if o.key == k then
            local l = labels[o.id]
            local p = l and l.page or -oi
            if not seen[p] then
              seen[p] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "0" }
            end
          end
        end
        table.sort(pages, function(x, y) return x.page < y.page end)
        local where
        if #pages >= PASSIM then
          where = "passim"
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          where = table.concat(l, ", ")
        end
        add(line({ lines = true, tabs = toc_tabs, before = 140, ind = xe.ind(720, 720, nil, TOA_COL),
          body = xe.inl(il) .. xe.runs(xe.LEAD) .. xe.runs(where) }))
      end
    end
  end

  if oral then
    add(heading(1, pandoc.Inlines({ pandoc.Str("Statement Regarding Oral Argument") }), true, true))
    body(oral, out, nil, false)
  end
  add(xe.raw('<w:p><w:pPr>' .. SECT_LINE .. SECT_ROMAN .. '</w:pPr></w:p>'))

  -- ---- the brief (arabic from 1)
  body(main, out, nil, true)
  signature(meta, out)

  -- certificate of compliance (FRBP 8015(h)): one unbreakable block on a new page
  add(heading(1, pandoc.Inlines({ pandoc.Str("Certificate of Compliance") }), true, true))
  add(line({ keep = true, body = xe.runs("This " .. CFG.doc_title .. " complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g). It complies with the typeface requirement of Fed. R. Bankr. P. 8015(a)(5) and the type-style requirement of Fed. R. Bankr. P. 8015(a)(6) because it was prepared in a proportionally spaced typeface, " .. FACE .. " at " .. SIZE .. "-point, with case names in italics.") }))
  signature(meta, out)

  -- certificate of service (FRBP 8011, CM/ECF convention; the wording is ours, see README)
  if meta.service == true then
    add(heading(1, pandoc.Inlines({ pandoc.Str("Certificate of Service") }), false))
    add(line({ keep = true, body = xe.runs("I certify that on " .. (meta.date and plain(meta.date) or "[date]") .. " I filed this " .. CFG.doc_title .. " with the Clerk of the Bankruptcy Appellate Panel of the Sixth Circuit through the court’s electronic filing system, which will send notice of the filing to all counsel of record.") }))
    signature(meta, out)
  end

  if addendum then
    out[#out + 1] = heading(1, addendum[1].content, true, true)
    body({ table.unpack(addendum, 2) }, out, nil, false)
  end

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({})   -- pandoc would print the date and title as a block at the top
  return doc
end
