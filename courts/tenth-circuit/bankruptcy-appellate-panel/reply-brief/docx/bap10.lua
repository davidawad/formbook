-- bap10 brief, DOCX engine (docs/DOCX.md): the markdown contract -> Word, on the styles of docx/reference.xml
-- (fb render builds reference.docx from it). Mirrors the typst template (typst/bap10-<kind>.typ): cover,
-- disclosure, table of contents, table of authorities, the body with generated headings, signature, certificate
-- of compliance, statement of related cases. Three sections give the typst page numbering: no number on the
-- cover, lowercase roman for the front matter, arabic from 1 for the body.
-- The pages in the contents and the table of authorities: fb render (tools/fb/src/docxpass.rs) renders the
-- document once, finds the page of every heading and citation in that PDF (the needles this filter writes to
-- FORMBOOK_NEEDLES), and renders again with those pages (FORMBOOK_PAGES) until they settle. fb render writes the
-- footers (rIdFtrNone, rIdFtrPage); this filter writes the last section (FORMBOOK_FINAL). Word may paginate
-- slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

-- The only part that differs between the three copies
local CFG = {
  kind = "reply-brief",
  word_limit = 6500,
  word_limit_note = "FRBP 8015(a)(7)(B)(ii)",
}

local COURT_NAME = "UNITED STATES BANKRUPTCY APPELLATE PANEL OF THE TENTH CIRCUIT"
local TYPE_SIZE = "14"
local TOC_DEPTH = 4    -- heading levels listed in the contents (typst: toc-depth)
local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)
local PAGE_SIZE = '<w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

local function raw(xml) return pandoc.RawBlock("openxml", xml) end
local function rawi(xml) return pandoc.RawInline("openxml", xml) end
local TAB = '<w:r><w:tab/></w:r>'
-- An empty paragraph of a style (a rule or a gap): pandoc drops an empty Para, so it is written raw.
local function empty(style) return raw('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>') end

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, the centered PAGE field fb render writes), page
-- size and margins, page number format; footnotes numbered through the brief.
local function sect_pr(footer, pgnum)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. (footer and "rIdFtrPage" or "rIdFtrNone") .. '"/>'
    .. '<w:footnotePr><w:numFmt w:val="decimal"/><w:numRestart w:val="continuous"/></w:footnotePr>'
    .. '<w:type w:val="nextPage"/>' .. PAGE_SIZE .. (pgnum or "") .. '<w:cols w:space="720"/></w:sectPr>'
end
local function section_break(footer, pgnum)
  return raw('<w:p><w:pPr><w:pStyle w:val="SectionBreak"/>' .. sect_pr(footer, pgnum) .. '</w:pPr></w:p>')
end

-- ---------------------------------------------------------------------------
-- Needles and pages (the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing).
local needles = {}
local function need(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- The pages of the previous pass: id -> { page, label }. Empty on the first pass.
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

local function P(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- a metadata value (YAML string, inlines or blocks) as a list of inlines
local function inls(v)
  if v == nil then return pandoc.List() end
  if type(v) == "string" then return pandoc.List({ pandoc.Str(v) }) end
  if v.t == "MetaInlines" then return pandoc.List(v) end
  if v.t == "MetaBlocks" then
    local o = pandoc.List()
    for _, b in ipairs(v) do if b.content then o:extend(b.content) end end
    return o
  end
  return pandoc.List({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function meta_blocks(v)
  if v.t == "MetaInlines" then return { pandoc.Plain(v) } end
  local out = {}
  for _, b in ipairs(v) do out[#out + 1] = b end
  return out
end

local function single(blocks)
  for i, b in ipairs(blocks) do
    if b.t == "Para" then blocks[i] = P("Single", b.content) end
  end
  return blocks
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local t = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(t) do while n >= p[1] do s = s .. p[2]; n = n - p[1] end end
  return s
end

-- typst's count-words, line by line, on the markdown source (the rules match bap10-*.typ count-words)
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("bap10: no input file to count words from", 0) end
  local h = io.open(f, "r")
  if not h then error("bap10: cannot read " .. f, 0) end
  local text = h:read("a")
  h:close()
  local lines, dashes = {}, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    else
      lines[#lines + 1] = line
    end
  end
  local n, skipping = 0, false
  for _, line in ipairs(lines) do
    if line:match("^#%s+.*[Oo]ral [Aa]rgument") then skipping = true
    elseif skipping and line:match("^#%s") then skipping = false end
    if not skipping then
      local s = line
      s = s:gsub("<!%-%-.-%-%->", " ")
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
  end
  return n
end

local function letter(n) return string.char(64 + n) end

-- Every scanned citation (a `toa:` link) in document order: { key, id }.
local function scan_citations(blocks, auth, used, occurrences)
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        if not auth[key] then error("bap10: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
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
  scan_blocks = function(bs, in_note)
    for _, b in ipairs(bs) do
      if b.t == "Para" or b.t == "Plain" then
        scan_inlines(b.content, in_note)
      elseif b.t == "BlockQuote" or b.t == "Div" then
        scan_blocks(b.content, in_note)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
      end
    end
  end
  scan_blocks(blocks, false)
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "email", "signature", "word_processor", "typeface", "related_cases" }) do
    if meta[k] == nil then error("bap10: missing required metadata field `" .. k .. "`", 0) end
  end
  local sig = meta.signature
  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
    end
  end

  -- split off a generated "Statement of Related Cases" section (it is generated below, not authored)
  local main = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^statement of related cases%s*$") then break end
    main[#main + 1] = b
  end

  local words = source_words()
  if words > CFG.word_limit then
    error("bap10: the " .. CFG.kind .. " has " .. words .. " words; " .. CFG.word_limit_note .. " allows " .. CFG.word_limit, 0)
  end

  -- headings: numbering as the typst template (Argument: I. A. 1. a.; elsewhere A. 1. a. (1))
  local counters = { 0, 0, 0, 0, 0, 0 }
  local in_arg = false
  local function number(b)
    local level = b.level
    if level == 1 then
      counters = { 0, 0, 0, 0, 0, 0 }
      local t = plain(b.content):lower():match("^%s*(.-)%s*$")
      in_arg = (t == "argument" or t == "reply argument")
      return nil
    end
    counters[level] = counters[level] + 1
    for k = level + 1, 5 do counters[k] = 0 end
    local n = counters[level]
    local lab
    if in_arg then
      if level == 2 then lab = roman(n) .. "."
      elseif level == 3 then lab = letter(n) .. "."
      elseif level == 4 then lab = tostring(n) .. "."
      elseif level == 5 then lab = string.char(96 + n) .. "."
      end
    else
      if level == 2 then lab = letter(n) .. "."
      elseif level == 3 then lab = tostring(n) .. "."
      elseif level == 4 then lab = string.char(96 + n) .. "."
      elseif level == 5 then lab = "(" .. n .. ")"
      end
    end
    if not lab then error("bap10: headings deeper than level 5 are not supported", 0) end
    return lab
  end

  -- the front matter's needles first (document order): disclosure, contents, authorities; then the body's
  if meta.disclosure then
    needles[#needles + 1] = { id = "S:disc", kind = "B", needle = norm("Disclosure Statement"), fallback = norm("Disclosure Statement") }
  end
  needles[#needles + 1] = { id = "S:toc", kind = "B", needle = norm("Table of Contents Page Table of Authorities"),
    fallback = norm("Table of Contents") }
  needles[#needles + 1] = { id = "S:toa", kind = "B", needle = norm("Table of Authorities"), fallback = norm("Table of Authorities") }
  local toa_slot = #needles

  -- body: headings (labels, contents entries, needles) and citations (needles), in order; its page 1 is the page
  -- of its first block
  local used, occurrences = {}, {}
  local toc = {}  -- contents entries: { id, level, label, inl, k }
  local body_id = "S:body"
  if main[1] and main[1].t == "Header" then
    body_id = "H:" .. (#needles + 1)
  elseif main[1] then
    need(body_id, "B", pandoc.utils.stringify(main[1]):sub(1, NEEDLE_MAX), "")
  end
  local body = {}
  local last_para = nil
  for i, b in ipairs(main) do
    if b.t == "Header" then
      if b.level > 5 then error("bap10: headings deeper than level 5 are not supported", 0) end
      local lab = number(b)
      local title = b.content
      local text = plain(title)
      local id = "H:" .. (#needles + 1)
      local nxt = main[i + 1] and pandoc.utils.stringify(main[i + 1]):sub(1, 40) or ""
      need(id, "B", (lab and (lab .. " ") or "") .. text, nxt)
      if b.level == 1 then
        body[#body + 1] = pandoc.Header(1, title)
        toc[#toc + 1] = { id = id, level = 1, inl = pandoc.List({ pandoc.Str(text:upper()) }), k = 0 }
      elseif in_arg and b.level == 2 then
        -- the Argument's point headings are centered; in the contents the label starts at the margin
        local inl = pandoc.List({ pandoc.Str(lab), pandoc.Space() }):extend(title)
        body[#body + 1] = P("PointHeading", inl)
        toc[#toc + 1] = { id = id, level = 2, label = lab, inl = title, k = 0 }
      else
        -- label at k half-inches (typst label-indent), the title hanging half an inch after it
        local k = b.level - (in_arg and 3 or 2) + 1
        local lab_inl = pandoc.Strong({ pandoc.Str(lab) })
        local t_inl = pandoc.Strong(title)
        if b.level >= 4 then lab_inl = pandoc.Strong({ pandoc.Emph({ pandoc.Str(lab) }) }); t_inl = pandoc.Strong({ pandoc.Emph(title) }) end
        body[#body + 1] = P("SubHead" .. math.min(k, 4), pandoc.List({ lab_inl, rawi(TAB), t_inl }))
        if b.level <= TOC_DEPTH then
          toc[#toc + 1] = { id = id, level = b.level, label = lab, inl = title, k = math.min(k, 3) }
        end
      end
    else
      scan_citations({ b }, auth, used, occurrences)
      body[#body + 1] = b
      if b.t == "Para" then last_para = #body else last_para = nil end
    end
  end
  -- the signature block never stands alone on a page: the last paragraph keeps with it (typst does the same)
  if sig and last_para then body[last_para] = P("BodyKeep", body[last_para].content) end
  body = pandoc.Pandoc(body):walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  }).blocks

  -- table of authorities: groups and members
  local groups = {
    { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
    { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
  }
  local function sort_text(a) return (a.sort and plain(a.sort) or (plain(a.name or "") .. " " .. plain(a.cite))):lower():gsub("[^a-z0-9 ]", "") end
  local toa_members = {}
  for _, g in ipairs(groups) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    table.sort(members, function(x, y) return sort_text(auth[x]) < sort_text(auth[y]) end)
    if #members > 0 then toa_members[#toa_members + 1] = { g, members } end
  end
  if toa_members[1] then
    local g1 = toa_members[1][1][2]
    needles[toa_slot].needle = norm("Table of Authorities " .. g1 .. " Page(s)"):sub(1, NEEDLE_MAX)
  end

  need("C:compliance", "B", "Certificate of Compliance", "1. This brief complies")
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: the front matter from its first page (i, ii ...), the body, the certificate and
  -- the statement of related cases from the body's first block (1, 2 ...)
  nl[#nl + 1] = "#section\t" .. (meta.disclosure and "S:disc" or "S:toc") .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr(true, '<w:pgNumType w:fmt="decimal" w:start="1"/>'))

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover (FRBP 8015(a)(2)(A)-(F)); no page number. Rules as typst: double under the case number and at the foot,
  -- 2 in rules between the parts.
  add(P("Centered", pandoc.List({ pandoc.Strong(pandoc.List({ pandoc.Str("BAP No. ") }):extend(inls(meta.case_number))) })))
  add(empty("RuleDouble"))
  add(P("Centered", pandoc.List({ pandoc.Strong({ pandoc.Str(COURT_NAME) }) })))
  add(empty("RuleShort"))
  if meta.in_re then
    for _, n in ipairs(meta.in_re.names or {}) do add(P("Centered", inls(n))) end
    add(P("Designation", inls(meta.in_re.designation)))
  end
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names or {}) do add(P("Centered", inls(n))) end
    add(P("Designation", inls(side.designation)))
    if i < #sides then add(P("Centered", pandoc.List({ pandoc.Str("v.") }))) end
  end
  if meta.bankruptcy then add(P("Right", inls(meta.bankruptcy))) end
  add(empty("RuleShort"))
  add(P("Centered", inls(meta.proceeding)))
  add(empty("RuleShort"))
  add(P("Centered", pandoc.List({ pandoc.Strong({ pandoc.Str(plain(meta.brief_title):upper()) }) })))
  add(empty("RuleShort"))
  for gi, g in ipairs(meta.counsel or {}) do
    for _, n in ipairs(g.names or {}) do add(P("Counsel", inls(n))) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #meta.counsel then lines[#lines + 1] = meta.phone; lines[#lines + 1] = meta.email end
    for _, l in ipairs(lines) do add(P("CounselLine", pandoc.List({ pandoc.Emph(inls(l)) }))) end
    if gi < #meta.counsel then add(empty("Gap")) end
  end
  add(empty("RuleDouble"))
  add(section_break(false, nil))

  -- front matter (lowercase roman): disclosure, table of contents, table of authorities
  local first_front = "FrontHeading"
  if meta.disclosure then
    add(P("FrontHeading", pandoc.List({ pandoc.Str("Disclosure Statement") })))
    addall(single(meta_blocks(meta.disclosure)))
    first_front = "FrontHeadingBreak"
  end

  -- contents: label at its step, title hanging after it, the dot leader and the entry's page (TOCK styles: a right
  -- tab inside the margin, past the page column's right indent)
  local function toc_line(e)
    local inl = pandoc.List({})
    if e.label then inl:insert(pandoc.Str(e.label)); inl:insert(rawi(TAB)) end
    inl:extend(e.inl)
    inl:insert(pandoc.Space())
    inl:insert(rawi(TAB))
    inl:insert(pandoc.Str(label_of(e.id)))
    return P("TOCK" .. e.k, inl)
  end
  add(P(first_front, pandoc.List({ pandoc.Str("Table of Contents") })))
  add(P("RightHead", pandoc.List({ pandoc.Str("Page") })))
  add(toc_line({ id = "S:toa", level = 1, inl = pandoc.List({ pandoc.Str("TABLE OF AUTHORITIES") }), k = 0 }))
  for _, e in ipairs(toc) do add(toc_line(e)) end
  add(toc_line({ id = "C:compliance", level = 1, inl = pandoc.List({ pandoc.Str("CERTIFICATE OF COMPLIANCE") }), k = 0 }))

  add(P("FrontHeadingBreak", pandoc.List({ pandoc.Str("Table of Authorities") })))
  for gi, gm in ipairs(toa_members) do
    local g, members = gm[1], gm[2]
    local head = pandoc.List({ pandoc.Str(g[2]) })
    if gi == 1 then head:extend({ rawi(TAB), pandoc.Underline({ pandoc.Str("Page(s)") }) }) end
    add(P("TOAGroup", head))
    for _, k in ipairs(members) do
      local a = auth[k]
      local line = pandoc.List({})
      if a.name then
        local nm = inls(a.name)
        if g[1] == "case" then nm = pandoc.List({ pandoc.Emph(nm) }) end
        line:extend(nm)
        line:insert(pandoc.Str(","))
        line:insert(pandoc.LineBreak())
      end
      line:extend(inls(a.cite))
      -- the distinct pages of the authority, in page order (typst: printed page labels, passim from PASSIM)
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
      line:insert(pandoc.Space())
      line:insert(rawi(TAB))
      if #pages >= PASSIM then
        line:insert(pandoc.Emph({ pandoc.Str("passim") }))
      else
        local l = {}
        for _, p in ipairs(pages) do l[#l + 1] = p.label end
        line:insert(pandoc.Str(table.concat(l, ", ")))
      end
      add(P("TOALine", line))
    end
  end
  add(section_break(true, '<w:pgNumType w:fmt="lowerRoman" w:start="1"/>'))

  -- body (arabic from 1)
  addall(body)
  if sig then
    add(empty("Gap"))
    add(P("Counsel", pandoc.List({ pandoc.Str("Respectfully submitted,") })))
    add(empty("Gap"))
    add(P("Counsel", pandoc.List({ pandoc.Str("/s/ ") }):extend(inls(sig.signer))))
    add(P("Counsel", pandoc.List({ pandoc.Str(plain(sig.signer):upper()) })))
    for _, l in ipairs(sig.lines or {}) do add(P("CounselLine", pandoc.List({ pandoc.Emph(inls(l)) }))) end
    if meta.date then
      add(empty("Gap"))
      add(P("Single", inls(meta.date)))
    end
  end

  -- certificate of compliance (FRBP 8015(h)); the checkbox is a bordered run holding "X" (no symbol font)
  add(P("Heading1Break", pandoc.List({ pandoc.Str("Certificate of Compliance") })))
  add(P("CertItem", pandoc.List({ pandoc.Str("1."), rawi(TAB), pandoc.Str("This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g) and 10th Cir. BAP L.R. 8015-1(d), it contains no more than " .. group_digits(CFG.word_limit) .. " words. The brief contains " .. group_digits(words) .. " words, as counted by the drafting software.") })))
  add(P("CheckLine", pandoc.List({
    rawi('<w:r><w:rPr><w:b/><w:sz w:val="22"/><w:szCs w:val="22"/><w:bdr w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:rPr><w:t xml:space="preserve">X</w:t></w:r>'),
    pandoc.Str(" "), pandoc.Space(), pandoc.Str("this brief contains " .. group_digits(words) .. " words.") })))
  add(P("CertItem", pandoc.List({ pandoc.Str("2."), rawi(TAB), pandoc.Str("This brief complies with the typeface requirements of Fed. R. Bankr. P. 8015(a)(5) and 10th Cir. BAP L.R. 8015-1(b) because it has been prepared in a proportionally spaced typeface using " .. plain(meta.word_processor) .. " in " .. TYPE_SIZE .. "-point " .. plain(meta.typeface) .. " roman type.") })))
  if sig then
    add(empty("Gap"))
    add(P("Counsel", pandoc.List({ pandoc.Str("/s/ ") }):extend(inls(sig.signer))))
    add(P("Counsel", pandoc.List({ pandoc.Str("Attorney for ") }):extend(inls(sig["for"]))))
    if meta.date then add(P("Counsel", pandoc.List({ pandoc.Str("Dated: ") }):extend(inls(meta.date)))) end
  end

  -- statement of related cases (L.R. 8014-1): the last page
  add(P("FrontHeadingBreak", pandoc.List({ pandoc.Str("Statement of Related Cases") })))
  local rc = meta.related_cases
  if plain(rc.status or "none") == "none" then
    add(P("Single", pandoc.List({ pandoc.Str("The filer knows of no related case pending before the United States Supreme Court, any United States Court of Appeals, any United States District Court, or the Bankruptcy Appellate Panel.") })))
  else
    add(P("Single", pandoc.List({ pandoc.Str("The following related case(s) are pending before the court(s) listed. A related case involves substantially the same litigants and substantially the same fact pattern or legal issues as this appeal.") })))
    for _, c in ipairs(rc.cases or {}) do add(P("Designation", inls(c))) end
  end

  -- the frontmatter is read above; pandoc must not write its own title block (date, title) before the cover
  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
