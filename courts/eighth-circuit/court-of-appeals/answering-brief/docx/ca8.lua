-- Eighth Circuit brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The cover, summary, disclosure, table of contents and table of authorities, and the certificates are
-- built here as paragraphs in the "Centered" and "Single" styles of reference.docx; the body keeps its
-- markdown structure. Page numbers come from the reference's footer.
-- Known limits (BLOCKED, see the PR): the table of contents is a TOC field, so its page numbers appear only
-- after Word or LibreOffice updates fields; the table of authorities lists the authorities without page
-- numbers (a TOA field would need the same update, and LibreOffice does not honor TA/TOA fields).

-- The only part that differs between the three copies (the LaTeX copies have the same CFG block).
local CFG = {
  kind = "answering-brief",
  word_limit = 13000,
  toa_colons = false,
  toa_outline = true,
  district = { prefix = "", sep = ", ", judge = true },
  service = "the foregoing brief was filed with the Clerk of Court for the U.S. Court of Appeals for the Eighth Circuit through the CM/ECF system, which will send a notification of such filing to all counsel of record.",
  summary_title = "Summary of the Case and Statement on Oral Argument",
}

local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}
if CFG.toa_colons then
  for _, g in ipairs(TOA_GROUPS) do g[2] = g[2] .. ":" end
end

-- a metadata value (markdown inlines or blocks) as a list of blocks
local function meta_blocks(v)
  if v.t == "MetaInlines" then return { pandoc.Plain(v) } end
  local out = {}
  for _, b in ipairs(v) do out[#out + 1] = b end
  return out
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function centered(inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Centered" }))
end

local function single(blocks)
  for i, b in ipairs(blocks) do
    if b.t == "Para" then blocks[i] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Single" })) end
  end
  return blocks
end

local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function toc_field()
  return pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="Centered"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>Table of contents: update fields to show page numbers.</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- typst's count-words, line by line, on the markdown source (see the LaTeX filter for the rules)
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return 0 end
  local h = io.open(f, "r")
  if not h then return 0 end
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
  local n, skipping = 0, false
  for _, line in ipairs(lines) do
    if line:match("^#%s+.*[Oo]ral [Aa]rgument") then skipping = true
    elseif skipping and line:match("^#%s") then skipping = false end
    if not skipping then
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
  end
  return n
end

function Pandoc(doc)
  local meta = doc.meta
  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
    end
  end
  local used = {}
  -- citations: the link text stays, the page cannot be computed here (see the TOA note above)
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("ca8: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      return el.content
    end,
  })

  local main, addendum = {}, nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^addendum%s*$") then
      addendum = { table.unpack(doc.blocks, i + 1) }
      break
    end
    main[#main + 1] = b
  end

  local summary, body = nil, {}
  if meta.summary then summary = meta_blocks(meta.summary) end
  do
    local i = 1
    while i <= #main do
      local b = main[i]
      local h = b.t == "Header" and b.level == 1 and plain(b.content):lower() or nil
      if h and not summary and (h:match("^summary of the case") or h:match("^summary of case")) then
        summary = {}
        i = i + 1
        while i <= #main and not (main[i].t == "Header" and main[i].level == 1) do
          summary[#summary + 1] = main[i]
          i = i + 1
        end
      else
        body[#body + 1] = b
        i = i + 1
      end
    end
  end

  local words = source_words()
  if words > CFG.word_limit then error("ca8: the brief has " .. words .. " words; the limit is " .. CFG.word_limit, 0) end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover (FRAP 32(a)(2))
  local sig = meta.signature
  add(centered({ pandoc.Str("No. " .. plain(meta.case_number)) }))
  add(centered({ pandoc.Strong({ pandoc.Str("UNITED STATES COURT OF APPEALS FOR THE EIGHTH CIRCUIT") }) }))
  for i, side in ipairs(meta.caption or {}) do
    for _, n in ipairs(side.names or {}) do add(centered(n)) end
    add(centered(side.designation))
    if i < #meta.caption then add(centered({ pandoc.Str("v.") })) end
  end
  local proc = pandoc.List(meta.proceeding or {})
  add(centered(proc))
  if meta.district_court_case then
    local d = pandoc.List({ pandoc.Str(CFG.district.prefix .. plain(meta.district_court_case)) })
    if CFG.district.judge and meta.judge then
      d:insert(pandoc.Str(CFG.district.sep)); d:extend(meta.judge)
    end
    add(centered(d))
  end
  add(centered({ pandoc.Strong(meta.brief_title or {}) }))
  local any_group_phone = false
  for _, g in ipairs(meta.counsel or {}) do
    for _, n in ipairs(g.names or {}) do add(centered(n)) end
    for _, l in ipairs(g.lines or {}) do add(centered(l)) end
    if g.phone then add(centered(g.phone)); any_group_phone = true end
  end
  if meta.phone and not any_group_phone then add(centered(meta.phone)) end
  add(page_break())

  if summary then
    add(pandoc.Header(1, { pandoc.Str(CFG.summary_title) }))
    addall(summary)
    add(page_break())
  end
  if meta.disclosure then
    add(pandoc.Header(1, { pandoc.Str("Corporate Disclosure Statement") }))
    addall(meta_blocks(meta.disclosure))
    add(page_break())
  end

  add(pandoc.Header(1, { pandoc.Str("Table of Contents") }))
  add(toc_field())
  add(page_break())

  add(pandoc.Header(1, { pandoc.Str("Table of Authorities") }))
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local ax = auth[x].sort and plain(auth[x].sort) or (plain(auth[x].name) .. " " .. plain(auth[x].cite))
        local ay = auth[y].sort and plain(auth[y].sort) or (plain(auth[y].name) .. " " .. plain(auth[y].cite))
        return ax:lower() < ay:lower()
      end)
      add(pandoc.Para({ pandoc.Strong({ pandoc.Str(g[2]) }) }))
      for _, k in ipairs(members) do
        local a = auth[k]
        local line = pandoc.List({})
        if a.name then
          local nm = a.name
          if g[1] == "case" then nm = { pandoc.Emph(nm) } end
          line:extend(nm)
          line:insert(pandoc.Str(","))
          line:insert(pandoc.LineBreak())
        end
        line:extend(a.cite)
        add(pandoc.Div({ pandoc.Para(line) }, pandoc.Attr("", {}, { ["custom-style"] = "Single" })))
      end
    end
  end
  add(page_break())

  -- body; the last paragraph and the signature block stay together
  local last = body[#body]
  for _, b in ipairs(body) do add(b) end
  if sig then
    add(pandoc.Div({ pandoc.Para({ pandoc.Str("Respectfully submitted,") }) }, pandoc.Attr("", {}, { ["custom-style"] = "Single" }))
    )
    add(pandoc.Div({ pandoc.Para({ pandoc.Emph({ pandoc.Str("/s/ " .. plain(sig.signer)) }) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Single" }))
    )
    add(pandoc.Div({ pandoc.Para({ pandoc.Str(plain(sig.signer):upper()) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Single" })))
    if meta.date then add(pandoc.Para({ pandoc.Str(plain(meta.date)) })) end
  end

  -- certificates (FRAP 32(g)): the compliance certificate and the service certificate when asked for
  add(page_break())
  add(pandoc.Header(1, { pandoc.Str("Certificate of Compliance") }))
  add(pandoc.Para({ pandoc.Str("1. This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f): this document contains " .. group_digits(words) .. " words.") }))
  add(pandoc.Para({ pandoc.Str("2. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because this document has been prepared in a proportionally spaced typeface using " .. plain(meta.word_processor) .. " in 14-point " .. plain(meta.typeface) .. " roman type.") }))
  add(pandoc.Para({ pandoc.Str("3. The brief has been scanned for viruses and it is virus free.") }))
  if sig then
    add(pandoc.Div({ pandoc.Para({ pandoc.Emph({ pandoc.Str("/s/ " .. plain(sig.signer)) }) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Single" }))
    )
    add(pandoc.Div({ pandoc.Para({ pandoc.Str("Attorney for " .. plain(sig["for"])) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Single" })))
  end
  if meta.service and meta.service.certificate then
    add(page_break())
    add(pandoc.Header(1, { pandoc.Str("Certificate of Service") }))
    add(pandoc.Para({ pandoc.Str("I hereby certify that on " .. plain(meta.date) .. ", " .. CFG.service) }))
  end

  if addendum then
    add(page_break())
    add(pandoc.Header(1, { pandoc.Str("Addendum") }))
    addall(addendum)
  end

  doc.blocks = out
  return doc
end
