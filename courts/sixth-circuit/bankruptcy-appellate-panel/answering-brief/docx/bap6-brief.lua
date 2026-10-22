-- United States Bankruptcy Appellate Panel of the Sixth Circuit, DOCX engine (docs/DOCX.md).
-- The markdown contract (typst/bap6-*.typ, README "Markdown contract") -> a Word document on docx/reference.docx
-- (built by fb render from docx/reference.xml). Built here, as in the typst template: the cover (own section, no
-- footer), the front matter (own section, lower roman from i: disclosure, table of contents, table of authorities,
-- oral-argument statement), the brief (arabic from 1: body, signature block, certificate of compliance,
-- certificate of service, addendum).
-- The pages in the contents and the table of authorities (FRBP 8014(a)(2)-(3)): fb render
-- (tools/fb/src/docxpass.rs) renders the document once, finds the page of every heading and citation in that PDF
-- (the needles this filter writes to FORMBOOK_NEEDLES), and renders again with those pages (FORMBOOK_PAGES) until
-- they settle. Sections name fb render's footers (rIdFtrNone, rIdFtrPage); the last section is written to
-- FORMBOOK_FINAL. Word may paginate slightly differently from the LibreOffice PDF the pages come from.
-- No case-specific text in this file. Metadata comes from the YAML frontmatter of the sample.

local KIND_ORDER = { "case", "constitution", "statute", "regulation", "rule", "other" }
local KIND_HEADING = {
  case = "Cases", constitution = "Constitutional Provisions", statute = "Statutes",
  regulation = "Regulations", rule = "Rules", other = "Other Authorities",
}
local FONT_NAME = "Times New Roman"   -- the face reference.xml names (typst: font-family.first())
local TYPE_SIZE = 14                  -- points (typst: type-size)
local PASSIM = 7                      -- an authority cited on this many pages or more prints "passim" (typst: passim-threshold)
local NEEDLE_MAX = 60                 -- a needle is a prefix of the text (letters and digits only)
local PAGE_SETUP = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440"'
  .. ' w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

-- the only text that differs between the three copies of this file (see README "Engines")
local CFG = {
  kind = "answering",
  doc_title = "brief of appellee",
  word_limit = 13000,
  required = { "Summary of Argument", "Argument", "Conclusion" },
  oral_argument_required = false,
}

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value (markdown inlines) as a list of inlines
local function inl_of(v)
  if v == nil then return pandoc.List() end
  if type(v) == "string" then return pandoc.List({ pandoc.Str(v) }) end
  if v.t == "MetaInlines" then return pandoc.List(v) end
  if v.t == "MetaBlocks" and #v == 1 and v[1].content then return pandoc.List(v[1].content) end
  return pandoc.List({ pandoc.Str(plain(v)) })
end

-- a metadata value (markdown inlines or blocks) as a list of blocks
local function meta_blocks(v)
  if v == nil then return {} end
  if v.t == "MetaBlocks" then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b end
    return out
  end
  return { pandoc.Para(inl_of(v)) }
end

-- a paragraph in a named paragraph style (a custom-style Div)
local function styled(inl, style)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw_block(xml) return pandoc.RawBlock("openxml", xml) end
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- the paragraph that ends a section (the next section starts on a new page)
local function section_end(footer_rid, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return raw_block('<w:p><w:pPr><w:pStyle w:val="SectionEnd"/><w:sectPr><w:footerReference w:type="default" r:id="'
    .. footer_rid .. '"/>' .. PAGE_SETUP .. pg .. '<w:cols w:space="720"/></w:sectPr></w:pPr></w:p>')
end

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
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
  for line in f:lines() do
    local id, page, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = lab } end
  end
  f:close()
end

local function label_of(id)
  local l = labels[id]
  if l then return l.label end
  return "00" -- the first pass: a placeholder of about the final width
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- typst's count-words, line by line, on the markdown source of the body (FRBP 8015(g): headings count)
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("bap6: no input file to count words in", 0) end
  local h = io.open(f, "r")
  if not h then error("bap6: cannot open " .. f, 0) end
  local text = h:read("a")
  h:close()
  local lines, dashes = {}, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    elseif line:match("^#%s+[Aa]ddendum%s*$") then
      break
    else
      lines[#lines + 1] = line
    end
  end
  local n = 0
  for _, line in ipairs(lines) do
    local s = line
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

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
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
      if not KIND_HEADING[auth[key].kind] then
        error("bap6: authority `" .. key .. "` has kind `" .. auth[key].kind .. "`", 0)
      end
    end
  end

  local disclosure = meta.disclosure and meta_blocks(meta.disclosure) or nil
  local oral = meta.oral_argument and meta_blocks(meta.oral_argument) or nil

  -- body and addendum (typst: the addendum starts at a line `# Addendum` and keeps its heading)
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
    if not found then error("bap6: the sample has no `# " .. s .. "` section, required for a " .. CFG.kind .. " brief (FRBP 8014)", 0) end
  end
  if CFG.oral_argument_required and not meta.oral_argument then
    error("bap6: the frontmatter needs `oral_argument` for a " .. CFG.kind .. " brief (FRBP 8019(a); LBR 8014-1(b))", 0)
  end
  local words = source_words()
  if words > CFG.word_limit then
    error("bap6: the brief has " .. words .. " words; the limit for a " .. CFG.kind .. " brief is " .. CFG.word_limit .. " (FRBP 8015(a)(7)(B))", 0)
  end

  -- Citations and headings, in document order: each `toa:` link is an occurrence and a needle (kind N inside a
  -- footnote), each heading a needle and a contents entry (typst lists every outlined heading).
  local used, occurrences, entries = {}, {}, {}
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        if not auth[key] then error("bap6: link toa:" .. key .. " has no entry in the authorities registry", 0) end
        used[key] = true
        occurrences[#occurrences + 1] = { key = key, id = "T:" .. (#occurrences + 1) }
        local rest = {}
        for j = i + 1, #list do rest[#rest + 1] = list[j] end
        need(occurrences[#occurrences].id, in_note and "N" or "B", plain(el.content), pandoc.utils.stringify(rest))
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
  local function text_after(blocks, i)
    return blocks[i + 1] and pandoc.utils.stringify(blocks[i + 1]):sub(1, 40) or ""
  end
  -- a front-matter heading: a needle (its title and what follows) and, unless `quiet`, a contents entry
  local function front_heading(id, title, after, quiet)
    need(id, "B", title, after)
    if not quiet then entries[#entries + 1] = { id = id, level = 1, text = title } end
  end
  local h_n = 0
  local function scan_body(blocks)
    for i, b in ipairs(blocks) do
      if b.t == "Header" then
        h_n = h_n + 1
        local id = "H:" .. h_n
        need(id, "B", plain(b.content), text_after(blocks, i))
        entries[#entries + 1] = { id = id, level = b.level, text = plain(b.content) }
      else
        scan_blocks({ b }, false)
      end
    end
  end

  -- the first group of the table of authorities (its heading's needle runs into it)
  local first_kind = nil
  for _, kind in ipairs(KIND_ORDER) do
    for _, a in pairs(auth) do if not first_kind and a.kind == kind then first_kind = kind end end
  end

  -- front matter, in page order
  local front_id
  if disclosure then
    front_id = "F:disclosure"
    front_heading(front_id, "Corporate Disclosure Statement", pandoc.utils.stringify(disclosure[1]):sub(1, 40))
    scan_blocks(disclosure, false)
  end
  need("F:toc", "B", "Table of Contents", "")
  front_id = front_id or "F:toc"
  front_heading("F:toa", "Table of Authorities", first_kind and KIND_HEADING[first_kind] or "")
  if oral then
    front_heading("F:oral", "Statement Regarding Oral Argument", pandoc.utils.stringify(oral[1]):sub(1, 40))
    scan_blocks(oral, false)
  end
  -- the brief
  local body_id = "S:body"
  if main[1] and main[1].t == "Header" then
    body_id = "H:1"
  elseif main[1] then
    need(body_id, "B", pandoc.utils.stringify(main[1]):sub(1, NEEDLE_MAX), "")
  end
  scan_body(main)
  if addendum then scan_body(addendum) end
  for key in pairs(auth) do
    if not used[key] then error("bap6: authority `" .. key .. "` is listed but never cited in the body", 0) end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: the front matter from its first page (i, ii ...), the brief from its first block
  nl[#nl + 1] = "#section\t" .. front_id .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage"/>' .. PAGE_SETUP
    .. '<w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr>')

  -- links to toa: keep their text only
  local unlink = {
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  }
  local function unlinked(blocks) return pandoc.Pandoc(blocks):walk(unlink).blocks end
  -- the first paragraph after a heading has no first-line indent (typst: first-line-indent skips it)
  local function first_unindented(blocks)
    local out = {}
    for i, b in ipairs(blocks) do
      if i == 1 and b.t == "Para" then b = styled(b.content, "FirstParagraph") end
      out[#out + 1] = b
    end
    return out
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  local function signature_block()
    local sig = meta.signature
    if not sig then return end
    add(styled({ pandoc.Str("Respectfully submitted,") }, "SignatureLead"))
    add(styled(pandoc.List({ pandoc.Str("s/"), pandoc.Space() }) .. inl_of(sig.signer), "Signature"))
    for _, l in ipairs(sig.lines or {}) do add(styled(inl_of(l), "Signature")) end
    if meta.date then add(styled(inl_of(meta.date), "SignatureDate")) end
  end

  -- ---- cover (FRBP 8015(a)(2)): its own section, no footer
  add(styled(pandoc.List({ pandoc.Str("Case No. ") }) .. inl_of(meta.case_number), "Centered"))
  add(styled({ pandoc.Strong({ pandoc.Str("United States Bankruptcy Appellate Panel of the Sixth Circuit") }) }, "CoverGap"))
  for i, side in ipairs(meta.caption or {}) do
    for j, n in ipairs(side.names or {}) do
      add(styled(inl_of(n), (j == 1) and "CoverGap" or "Centered"))
    end
    add(styled(inl_of(side.designation), "Centered"))
    if i < #meta.caption then add(styled({ pandoc.Str("v.") }, "CoverGap")) end
  end
  add(styled(inl_of(meta.proceeding), "CoverWide"))
  add(styled(inl_of(meta.brief_title), "CoverTitle"))
  for gi, group in ipairs(meta.counsel or {}) do
    for ni, n in ipairs(group.names or {}) do
      local style = "Centered"
      if ni == 1 then style = (gi == 1) and "CoverBottom" or "CoverGroup" end
      add(styled(inl_of(n), style))
    end
    for _, l in ipairs(group.lines or {}) do add(styled(inl_of(l), "Centered")) end
  end
  if meta.phone then add(styled(inl_of(meta.phone), "CoverGroup")) end
  if meta.date then add(styled(inl_of(meta.date), "CoverDate")) end
  add(section_end("rIdFtrNone", nil))

  -- ---- front matter (lower roman from i)
  if disclosure then
    add(styled({ pandoc.Str("Corporate Disclosure Statement") }, "FrontHeading"))
    addall(first_unindented(unlinked(disclosure)))
  end
  add(styled({ pandoc.Str("Table of Contents") }, disclosure and "ContentsHeadingBreak" or "ContentsHeading"))
  for _, e in ipairs(entries) do
    add(styled({ pandoc.Str(e.text), TAB, pandoc.Str(label_of(e.id)) }, "TOCEntry" .. math.min(e.level, 4)))
  end

  add(styled({ pandoc.Str("Table of Authorities") }, "AuthoritiesHeading"))
  for _, kind in ipairs(KIND_ORDER) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == kind then members[#members + 1] = key end
    end
    if #members > 0 then
      local function sort_key(k)
        local a = auth[k]
        return a.sort and plain(a.sort) or (a.name and plain(a.name) or plain(a.cite))
      end
      table.sort(members, function(x, y) return sort_key(x) < sort_key(y) end)
      add(styled({ pandoc.Str(KIND_HEADING[kind]) }, "AuthorityKind"))
      for _, k in ipairs(members) do
        local a = auth[k]
        local inl = pandoc.List({})
        if a.name then
          if kind == "case" then inl:insert(pandoc.Emph(inl_of(a.name))) else inl:extend(inl_of(a.name)) end
          inl:insert(pandoc.Str(", "))
        end
        inl:extend(inl_of(a.cite))
        -- the distinct pages of the authority, in page order (typst: passim from PASSIM pages)
        local pages, seen = {}, {}
        for oi, o in ipairs(occurrences) do
          if o.key == k then
            local l = labels[o.id]
            local p = l and l.page or -oi
            if not seen[p] then
              seen[p] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
            end
          end
        end
        table.sort(pages, function(x, y) return x.page < y.page end)
        inl:insert(TAB)
        if #pages >= PASSIM then
          inl:insert(pandoc.Str("passim"))
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          inl:insert(pandoc.Str(table.concat(l, ", ")))
        end
        add(styled(inl, "TOAEntry"))
      end
    end
  end

  if oral then
    add(styled({ pandoc.Str("Statement Regarding Oral Argument") }, "FrontHeadingBreak"))
    addall(first_unindented(unlinked(oral)))
  end
  add(section_end("rIdFtrPage", "lowerRoman"))

  -- ---- the brief (arabic from 1)
  -- the first heading opens a page: no space above it (typst drops a block's space at the top of a page)
  for i, b in ipairs(unlinked(main)) do
    if i == 1 and b.t == "Header" and b.level == 1 then
      b = styled(b.content, "Heading1Top")
    elseif i == 2 and b.t == "Para" and main[1].t == "Header" then
      b = styled(b.content, "FirstParagraph")
    end
    add(b)
  end
  signature_block()

  -- certificate of compliance (FRBP 8015(h)); each certificate is kept together, as typst's unbreakable block
  add(styled({ pandoc.Str("Certificate of Compliance") }, "FrontHeadingBreak"))
  add(styled({ pandoc.Str("This " .. CFG.doc_title .. " complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g). It complies with the typeface requirement of Fed. R. Bankr. P. 8015(a)(5) and the type-style requirement of Fed. R. Bankr. P. 8015(a)(6) because it was prepared in a proportionally spaced typeface, " .. FONT_NAME .. " at " .. TYPE_SIZE .. "-point, with case names in italics.") }, "CertText"))
  signature_block()

  -- certificate of service (FRBP 8011, CM/ECF convention; the wording is ours, see README)
  if meta.service == true then
    add(styled({ pandoc.Str("Certificate of Service") }, "CertHeading"))
    add(styled({ pandoc.Str("I certify that on " .. (meta.date and plain(meta.date) or "[date]") .. " I filed this " .. CFG.doc_title .. " with the Clerk of the Bankruptcy Appellate Panel of the Sixth Circuit through the court’s electronic filing system, which will send notice of the filing to all counsel of record.") }, "CertText"))
    signature_block()
  end

  if addendum then
    local first = true
    for _, b in ipairs(unlinked(addendum)) do
      if first and b.t == "Header" then
        add(styled(b.content, "FrontHeadingBreak"))
      else
        add(b)
      end
      first = false
    end
  end

  -- the frontmatter is consumed here; pandoc would print a title block
  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
