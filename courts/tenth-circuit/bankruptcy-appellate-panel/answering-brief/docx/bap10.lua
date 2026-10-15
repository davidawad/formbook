-- bap10 brief, DOCX engine (docs/DOCX.md): the markdown contract -> Word, on docx/reference.docx.
-- Mirrors the typst template (typst/bap10-<kind>.typ): cover, disclosure, table of contents, table of
-- authorities, the body with generated headings, signature, certificate of compliance, statement of related
-- cases. Three sections give the typst page numbering: no number on the cover, lowercase roman for the front
-- matter, arabic from 1 for the body (footers and section breaks come from reference.docx and the RawBlocks below).
-- Known limits (BLOCKED, see README.md "Engines"): the table of contents shows its entries without page numbers
-- until Word or LibreOffice updates the TOC field; the table of authorities has no page numbers (a TA/TOA
-- field is not honored by LibreOffice); the cover's line spacing is approximate (one page is not checked here).

-- The only part that differs between the three copies
local CFG = {
  kind = "answering-brief",
  word_limit = 13000,
  word_limit_note = "FRBP 8015(a)(7)(B)(i)",
}

local COURT_NAME = "UNITED STATES BANKRUPTCY APPELLATE PANEL OF THE TENTH CIRCUIT"
local TYPE_SIZE = "14"
local PAGE_W, PAGE_H, MARGIN = 12240, 15840, 1440

local function raw(xml) return pandoc.RawBlock("openxml", xml) end
local function rawi(xml) return pandoc.RawInline("openxml", xml) end
local TAB = '<w:r><w:tab/></w:r>'
local PAGE_BREAK = raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

local function sect(footer_ref, fmt)
  return '<w:sectPr>' .. (footer_ref and ('<w:footerReference w:type="default" r:id="' .. footer_ref .. '"/>') or '')
    .. '<w:pgSz w:w="' .. PAGE_W .. '" w:h="' .. PAGE_H .. '"/><w:pgMar w:top="' .. MARGIN .. '" w:right="' .. MARGIN
    .. '" w:bottom="' .. MARGIN .. '" w:left="' .. MARGIN .. '" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/><w:cols w:space="720"/></w:sectPr>'
end
local function section_break(footer_ref, fmt)
  return raw('<w:p><w:pPr>' .. sect(footer_ref, fmt) .. '</w:pPr></w:p>')
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

function Pandoc(doc)
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

  -- citations: the link text stays; the page cannot be computed here (see the TOA note above)
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("bap10: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      return el.content
    end,
  })

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
  local toc = {}  -- entries for the cached table of contents: { level, text }
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

  local body = {}
  for _, b in ipairs(main) do
    if b.t == "Header" then
      if b.level > 5 then error("bap10: headings deeper than level 5 are not supported", 0) end
      local lab = number(b)
      local title = b.content
      local text = plain(title)
      if b.level == 1 then
        body[#body + 1] = pandoc.Header(1, title)
        toc[#toc + 1] = { 1, text:upper() }
      elseif in_arg and b.level == 2 then
        -- the Argument's point headings are centered (style "Point Heading", outline level 2)
        local inl = pandoc.List({ pandoc.Str(lab), pandoc.Space() }):extend(title)
        body[#body + 1] = P("PointHeading", inl)
        toc[#toc + 1] = { 2, lab .. " " .. text }
      else
        local inl = pandoc.List({ pandoc.Str(lab), rawi(TAB) }):extend(title)
        body[#body + 1] = pandoc.Header(b.level, inl)
        toc[#toc + 1] = { b.level, lab .. "\t" .. text }
      end
    else
      body[#body + 1] = b
    end
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover (FRBP 8015(a)(2)(A)-(F)); no page number
  add(P("Centered", pandoc.List({ pandoc.Strong(pandoc.List({ pandoc.Str("BAP No. ") }):extend(inls(meta.case_number))) })))
  add(P("Rule", pandoc.List()))
  add(P("Centered", pandoc.List({ pandoc.Strong({ pandoc.Str(COURT_NAME) }) })))
  add(P("Rule", pandoc.List()))
  if meta.in_re then
    for _, n in ipairs(meta.in_re.names or {}) do add(P("Centered", inls(n))) end
    add(P("IndentBlock", inls(meta.in_re.designation)))
    add(P("Centered", pandoc.List()))
  end
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names or {}) do add(P("Centered", inls(n))) end
    add(P("IndentBlock", inls(side.designation)))
    if i < #sides then add(P("Centered", pandoc.List({ pandoc.Str("v.") }))) end
  end
  if meta.bankruptcy then add(P("Right", inls(meta.bankruptcy))) end
  add(P("Rule", pandoc.List()))
  add(P("Centered", inls(meta.proceeding)))
  add(P("Rule", pandoc.List()))
  local title = inls(meta.brief_title)
  add(P("Centered", pandoc.List({ pandoc.Strong(title) })))
  add(P("Rule", pandoc.List()))
  for gi, g in ipairs(meta.counsel or {}) do
    for _, n in ipairs(g.names or {}) do add(P("IndentBlock", inls(n))) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #meta.counsel then lines[#lines + 1] = meta.phone; lines[#lines + 1] = meta.email end
    for _, l in ipairs(lines) do add(P("IndentBlock", pandoc.List({ pandoc.Emph(inls(l)) }))) end
    add(P("Centered", pandoc.List()))
  end
  add(P("Rule", pandoc.List()))
  add(section_break(nil, "decimal"))

  -- front matter (lowercase roman): disclosure, table of contents, table of authorities
  if meta.disclosure then
    add(P("FrontHeading", pandoc.List({ pandoc.Str("Disclosure Statement") })))
    addall(single(meta_blocks(meta.disclosure)))
    add(PAGE_BREAK)
  end

  add(P("FrontHeading", pandoc.List({ pandoc.Str("Table of Contents") })))
  add(P("Right", pandoc.List({ pandoc.Strong({ pandoc.Underline({ pandoc.Str("Page") }) }) })))

  -- table of authorities: groups and members (the TOA heading is in the TOC list below)
  local groups = {
    { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
    { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
  }
  local function sort_text(a) return (a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))):lower() end
  local toa_members = {}
  for _, g in ipairs(groups) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    table.sort(members, function(x, y) return sort_text(auth[x]) < sort_text(auth[y]) end)
    toa_members[#toa_members + 1] = { g, members }
  end

  -- the TOC field: cached entries (no page numbers) so every viewer shows the list
  local entries = { { 1, "TABLE OF AUTHORITIES" } }
  for _, e in ipairs(toc) do entries[#entries + 1] = e end
  entries[#entries + 1] = { 1, "CERTIFICATE OF COMPLIANCE" }
  for i, e in ipairs(entries) do
    local lvl, text = e[1], e[2]
    local inl = pandoc.List()
    if i == 1 then
      inl:extend({ rawi('<w:r><w:fldChar w:fldCharType="begin"/></w:r>'),
        rawi('<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h \\z \\u </w:instrText></w:r>'),
        rawi('<w:r><w:fldChar w:fldCharType="separate"/></w:r>') })
    end
    local parts = {}
    for piece in (text .. "\t"):gmatch("(.-)\t") do parts[#parts + 1] = piece end
    for pi_, piece in ipairs(parts) do
      if pi_ > 1 then inl:insert(rawi(TAB)) end
      inl:insert(pandoc.Str(piece))
    end
    if i == #entries then inl:insert(rawi('<w:r><w:fldChar w:fldCharType="end"/></w:r>')) end
    add(P("TOCLine" .. math.min(lvl, 4), inl))
  end
  add(PAGE_BREAK)

  add(pandoc.Header(1, pandoc.List({ pandoc.Str("Table of Authorities") })))
  for _, gm in ipairs(toa_members) do
    local g, members = gm[1], gm[2]
    if #members > 0 then
      add(P("TOAGroup", pandoc.List({ pandoc.Str(g[2]) })))
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
        add(P("TOAEntry", line))
      end
    end
  end
  add(section_break("rId101", "lowerRoman"))

  -- body (arabic from 1)
  addall(body)
  if sig then
    add(P("Signature", pandoc.List({ pandoc.Str("Respectfully submitted,") })))
    add(P("IndentBlock", pandoc.List({ pandoc.Str("/s/ "), pandoc.Space() }):extend(inls(sig.signer))))
    add(P("IndentBlock", pandoc.List({ pandoc.Str(plain(sig.signer):upper()) })))
    for _, l in ipairs(sig.lines or {}) do add(P("IndentBlock", pandoc.List({ pandoc.Emph(inls(l)) }))) end
    if meta.date then add(P("Single", inls(meta.date))) end
  end

  -- certificate of compliance (FRBP 8015(h)); the checkbox is text, not a drawn box
  add(PAGE_BREAK)
  add(pandoc.Header(1, pandoc.List({ pandoc.Str("Certificate of Compliance") })))
  add(P("Single", pandoc.List({ pandoc.Str("1. This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g) and 10th Cir. BAP L.R. 8015-1(d), it contains no more than " .. group_digits(CFG.word_limit) .. " words. The brief contains " .. group_digits(words) .. " words, as counted by the drafting software.") })))
  add(P("IndentBlock", pandoc.List({ pandoc.Str("[X] this brief contains " .. group_digits(words) .. " words.") })))
  add(P("Single", pandoc.List({ pandoc.Str("2. This brief complies with the typeface requirements of Fed. R. Bankr. P. 8015(a)(5) and 10th Cir. BAP L.R. 8015-1(b) because it has been prepared in a proportionally spaced typeface using " .. plain(meta.word_processor) .. " in " .. TYPE_SIZE .. "-point " .. plain(meta.typeface) .. " roman type.") })))
  if sig then
    add(P("Signature", pandoc.List({ pandoc.Str("/s/ "), pandoc.Space() }):extend(inls(sig.signer))))
    add(P("IndentBlock", pandoc.List({ pandoc.Str("Attorney for ") }):extend(inls(sig["for"]))))
    if meta.date then add(P("IndentBlock", pandoc.List({ pandoc.Str("Dated: ") }):extend(inls(meta.date)))) end
  end

  -- statement of related cases (L.R. 8014-1): the last page
  add(PAGE_BREAK)
  add(P("FrontHeading", pandoc.List({ pandoc.Str("Statement of Related Cases") })))
  local rc = meta.related_cases
  if plain(rc.status or "none") == "none" then
    add(P("Single", pandoc.List({ pandoc.Str("The filer knows of no related case pending before the United States Supreme Court, any United States Court of Appeals, any United States District Court, or the Bankruptcy Appellate Panel.") })))
  else
    add(P("Single", pandoc.List({ pandoc.Str("The following related case(s) are pending before the court(s) listed. A related case involves substantially the same litigants and substantially the same fact pattern or legal issues as this appeal.") })))
    for _, c in ipairs(rc.cases or {}) do add(P("IndentBlock", inls(c))) end
  end

  -- the frontmatter is read above; pandoc must not write its own title block (date, title) before the cover
  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
