-- United States Bankruptcy Appellate Panel of the Sixth Circuit, DOCX engine (docs/DOCX.md).
-- The markdown contract (typst/bap6-*.typ, README "Markdown contract") -> a Word document on docx/reference.docx.
-- Built here, as in the typst template: the cover (own section, no footer), the front matter (own section,
-- lower-roman footer: disclosure, table of contents, table of authorities, oral-argument statement), the brief
-- (arabic from 1: body, signature block, certificate of compliance, certificate of service, addendum).
-- Word fields: the table of contents is a TOC field and each citation carries a TA field; the table of
-- authorities is one TOA field per kind. Their page numbers are computed by Word on update (settings.xml sets
-- updateFields); the LibreOffice conversion does not compute them (BLOCKED in the README "Engines" section).
-- No case-specific text in this file. Metadata comes from the YAML frontmatter of the sample.

local FOOTER_RID = "rIdBapFooter1"
local TOC_INSTR = ' TOC \\o "1-9" \\h \\z \\u '
local KIND_ORDER = { "case", "constitution", "statute", "regulation", "rule", "other" }
local KIND_HEADING = {
  case = "Cases", constitution = "Constitutional Provisions", statute = "Statutes",
  regulation = "Regulations", rule = "Rules", other = "Other Authorities",
}
local TA_CATEGORY = { case = 1, constitution = 2, statute = 3, regulation = 4, rule = 5, other = 6 }

-- the only text that differs between the three copies of this file (see README "Engines")
local CFG = {
  kind = "opening",
  doc_title = "brief of appellant",
  word_limit = 13000,
  required = { "Statement of Jurisdiction", "Statement of the Issues", "Statement of the Case", "Summary of Argument", "Argument", "Conclusion" },
  oral_argument_required = true,
}

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function raw_inline(xml) return pandoc.RawInline("openxml", xml) end
local function raw_block(xml) return pandoc.RawBlock("openxml", xml) end

-- a paragraph in a named paragraph style (a custom-style Div)
local function styled(inl, style)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- a metadata value (markdown inlines or blocks) as a list of blocks
local function meta_blocks(v)
  if v == nil then return {} end
  if v.t == "MetaBlocks" then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b end
    return out
  end
  return { pandoc.Para(v) }
end

local function field_begin(instr)
  return '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve">'
    .. esc(instr) .. '</w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
end
local FIELD_END = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'

-- a Word field whose result is not written here: TA (one per citation)
local function ta_field(long, short, category)
  local l = long:gsub('"', "'")
  local s = short:gsub('"', "'")
  return raw_inline('<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve">'
    .. esc(' TA \\l "' .. l .. '" \\s "' .. s .. '" \\c ' .. tostring(category) .. ' ') .. '</w:instrText></w:r>'
    .. FIELD_END)
end

-- section break: the paragraph ends the section that precedes it
local function section_break(footer, fmt)
  local f = footer and ('<w:footerReference w:type="default" r:id="' .. FOOTER_RID .. '"/>') or ""
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return raw_block('<w:p><w:pPr><w:sectPr>' .. f
    .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. '<w:cols w:space="720"/></w:sectPr></w:pPr></w:p>')
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
  local meta = doc.meta

  -- registry of authorities (frontmatter `authorities:`)
  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
      if not TA_CATEGORY[auth[key].kind] then
        error("bap6: authority `" .. key .. "` has kind `" .. auth[key].kind .. "`", 0)
      end
    end
  end
  local used = {}

  -- every [text](toa:KEY) link: the text stays, a TA field follows it
  local function cite_filter(el)
    local key = el.target:match("^toa:(.+)$")
    if not key then return nil end
    local a = auth[key]
    if not a then error("bap6: link toa:" .. key .. " has no entry in the authorities registry", 0) end
    used[key] = true
    local long = a.name and (plain(a.name) .. ", " .. plain(a.cite)) or plain(a.cite)
    local short = a.name and plain(a.name) or plain(a.cite)
    local out = pandoc.List(el.content)
    out:insert(ta_field(long, short, TA_CATEGORY[a.kind]))
    return out
  end

  -- front matter and body are walked; the addendum is not counted but its citations are recorded
  local walker = { Link = cite_filter }
  local disclosure = meta.disclosure and pandoc.Pandoc(meta_blocks(meta.disclosure)):walk(walker).blocks or nil
  local oral = meta.oral_argument and pandoc.Pandoc(meta_blocks(meta.oral_argument)):walk(walker).blocks or nil
  doc = doc:walk(walker)

  -- body and addendum
  local main, addendum = {}, nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):match("^Addendum%s*$") then
      addendum = { table.unpack(doc.blocks, i + 1) }
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
  for key in pairs(auth) do
    if not used[key] then error("bap6: authority `" .. key .. "` is listed but never cited in the body", 0) end
  end

  -- table of contents entries: every outlined heading, in order (typst lists them all)
  local toc = {}
  if disclosure then toc[#toc + 1] = { level = 1, inl = pandoc.List({ pandoc.Str("Corporate Disclosure Statement") }) } end
  toc[#toc + 1] = { level = 1, inl = pandoc.List({ pandoc.Str("Table of Authorities") }) }
  if oral then toc[#toc + 1] = { level = 1, inl = pandoc.List({ pandoc.Str("Statement Regarding Oral Argument") }) } end
  for _, b in ipairs(main) do
    if b.t == "Header" then toc[#toc + 1] = { level = math.min(b.level, 9), inl = b.content } end
  end
  if addendum then toc[#toc + 1] = { level = 1, inl = pandoc.List({ pandoc.Str("Addendum") }) } end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- ---- cover (FRBP 8015(a)(2)): its own section, no footer
  add(styled({ pandoc.Str("Case No. " .. plain(meta.case_number)) }, "Centered"))
  add(styled({ pandoc.Strong({ pandoc.Str("United States Bankruptcy Appellate Panel of the Sixth Circuit") }) }, "CoverGap"))
  for i, side in ipairs(meta.caption or {}) do
    for j, n in ipairs(side.names or {}) do
      add(styled(n, (j == 1) and "CoverGap" or "Centered"))
    end
    add(styled(side.designation, "Centered"))
    if i < #meta.caption then add(styled({ pandoc.Str("v.") }, "Centered")) end
  end
  add(styled(meta.proceeding, "CoverGap"))
  add(styled(meta.brief_title, "CoverTitle"))
  for gi, group in ipairs(meta.counsel or {}) do
    for ni, n in ipairs(group.names or {}) do
      add(styled(n, (gi == 1 and ni == 1) and "CoverBottom" or ((ni == 1) and "CoverGap" or "Centered")))
    end
    for _, l in ipairs(group.lines or {}) do add(styled(l, "Centered")) end
  end
  if meta.phone then add(styled(meta.phone, "CoverGap")) end
  if meta.date then add(styled(meta.date, "CoverGap")) end
  add(section_break(false, nil))

  -- ---- front matter (lower-roman footer)
  if disclosure then
    add(pandoc.Header(1, { pandoc.Str("Corporate Disclosure Statement") }))
    addall(disclosure)
  end
  add(styled({ pandoc.Str("Table of Contents") }, disclosure and "FrontHeadingBreak" or "FrontHeading"))
  for i, e in ipairs(toc) do
    local inl = pandoc.List({})
    if i == 1 then inl:insert(raw_inline(field_begin(TOC_INSTR))) end
    inl:extend(e.inl)
    if i == #toc then inl:insert(raw_inline(FIELD_END)) end
    add(styled(inl, "toc " .. math.min(e.level, 4)))
  end

  add(styled({ pandoc.Str("Table of Authorities") }, "OutlineBreak"))
  for _, kind in ipairs(KIND_ORDER) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == kind then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local ax = auth[x].sort and plain(auth[x].sort) or (auth[x].name and plain(auth[x].name) or plain(auth[x].cite))
        local ay = auth[y].sort and plain(auth[y].sort) or (auth[y].name and plain(auth[y].name) or plain(auth[y].cite))
        return ax < ay
      end)
      add(styled({ pandoc.Str(KIND_HEADING[kind]) }, "AuthorityKind"))
      for idx, k in ipairs(members) do
        local a = auth[k]
        local inl = pandoc.List({})
        if idx == 1 then inl:insert(raw_inline(field_begin(' TOA \\h \\c "' .. TA_CATEGORY[kind] .. '" '))) end
        if a.name then
          if kind == "case" then inl:insert(pandoc.Emph(a.name)) else inl:extend(a.name) end
          inl:insert(pandoc.Str(", "))
        end
        inl:extend(a.cite)
        if idx == #members then inl:insert(raw_inline(FIELD_END)) end
        add(styled(inl, "AuthorityLine"))
      end
    end
  end

  if oral then
    add(styled({ pandoc.Str("Statement Regarding Oral Argument") }, "OutlineBreak"))
    addall(oral)
  end
  add(section_break(true, "lowerRoman"))

  -- ---- the brief (arabic from 1)
  addall(main)
  if meta.signature then
    add(styled({ pandoc.Str("Respectfully submitted,") }, "SignatureLead"))
    add(styled({ pandoc.Str("s/ " .. plain(meta.signature.signer)) }, "Signature"))
    for _, l in ipairs(meta.signature.lines or {}) do add(styled(l, "Signature")) end
    if meta.date then add(styled(meta.date, "SignatureDate")) end
  end

  -- certificate of compliance (FRBP 8015(h))
  add(styled({ pandoc.Str("Certificate of Compliance") }, "FrontHeadingBreak"))
  add(pandoc.Para({ pandoc.Str("This " .. CFG.doc_title .. " complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because it contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g). It complies with the typeface requirement of Fed. R. Bankr. P. 8015(a)(5) and the type-style requirement of Fed. R. Bankr. P. 8015(a)(6) because it was prepared in a proportionally spaced typeface, EB Garamond at 14-point, with case names in italics.") }))
  if meta.signature then
    add(styled({ pandoc.Str("Respectfully submitted,") }, "SignatureLead"))
    add(styled({ pandoc.Str("s/ " .. plain(meta.signature.signer)) }, "Signature"))
    for _, l in ipairs(meta.signature.lines or {}) do add(styled(l, "Signature")) end
    if meta.date then add(styled(meta.date, "SignatureDate")) end
  end

  -- certificate of service (FRBP 8011, CM/ECF convention; the wording is ours, see README)
  if meta.service == true then
    add(styled({ pandoc.Str("Certificate of Service") }, "FrontHeading"))
    add(pandoc.Para({ pandoc.Str("I certify that on " .. (meta.date and plain(meta.date) or "[date]") .. " I filed this " .. CFG.doc_title .. " with the Clerk of the Bankruptcy Appellate Panel of the Sixth Circuit through the court's electronic filing system, which will send notice of the filing to all counsel of record.") }))
    if meta.signature then
      add(styled({ pandoc.Str("Respectfully submitted,") }, "SignatureLead"))
      add(styled({ pandoc.Str("s/ " .. plain(meta.signature.signer)) }, "Signature"))
      for _, l in ipairs(meta.signature.lines or {}) do add(styled(l, "Signature")) end
      if meta.date then add(styled(meta.date, "SignatureDate")) end
    end
  end

  if addendum then
    add(styled({ pandoc.Str("Addendum") }, "OutlineBreak"))
    addall(addendum)
  end

  -- pandoc would print the frontmatter date as a title block; the cover prints it instead
  doc.meta.date = nil
  doc.blocks = out
  return doc
end
