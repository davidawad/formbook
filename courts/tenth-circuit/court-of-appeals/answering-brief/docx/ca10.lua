-- Tenth Circuit answering brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/ca10-answering-brief.typ (the reference): the cover (two pages, page i unnumbered, page ii roman),
-- the contents (iii), the table of authorities and the prior-appeals statement (iv), the body (arabic from 1),
-- the statement of counsel as to oral argument, and the certificates (compliance, digital submission, service).
-- Pages are separated by section breaks (SectionBreak paragraphs carrying a sectPr), so the footer numbering
-- follows the sections. Paragraph and heading geometry comes from the styles in reference.docx (build-reference.sh).
-- Known limit (BLOCKED, see README.md, "Engines"): the contents and the table of authorities list their entries
-- without page numbers; the page numbers need a field update in Word or LibreOffice, which this pipeline does not do.

local WORD_LIMIT = 13000
local TYPEFACE = "EB Garamond"
local NBSP = "\u{00A0}"

local TOA_KINDS = {
  { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

-- Section breaks. The sectPr that ends a section carries that section's footer and page numbering.
local PG = "<w:pgSz w:w=\"12240\" w:h=\"15840\"/>"
  .. "<w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" w:left=\"1440\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/>"

local function section_break(footer, pgnum)
  local ftr = footer and "<w:footerReference w:type=\"default\" r:id=\"rId100\"/>" or ""
  return pandoc.RawBlock("openxml",
    "<w:p><w:pPr><w:pStyle w:val=\"SectionBreak\"/><w:sectPr>" .. ftr
    .. "<w:type w:val=\"nextPage\"/>" .. PG .. (pgnum or "") .. "</w:sectPr></w:pPr></w:p>")
end
local BREAK_COVER_1 = section_break(false, "<w:pgNumType w:fmt=\"lowerRoman\" w:start=\"1\"/>")
local BREAK_COVER_2 = section_break(true, "<w:pgNumType w:fmt=\"lowerRoman\" w:start=\"2\"/>")
local BREAK_FRONT = section_break(true, "<w:pgNumType w:fmt=\"lowerRoman\"/>")
local BREAK_BODY = section_break(true, "<w:pgNumType w:fmt=\"decimal\" w:start=\"1\"/>")
local BREAK_CERT = section_break(true, "<w:pgNumType w:fmt=\"decimal\"/>")

-- Metadata as an inline list (MetaInlines, MetaString or a plain Lua string).
local function I(v)
  if v == nil then return pandoc.List({}) end
  if type(v) == "string" then return pandoc.List({ pandoc.Str(v) }) end
  if v.t == "MetaString" then return pandoc.List({ pandoc.Str(pandoc.utils.stringify(v)) }) end
  if v.t == "MetaBlocks" then return pandoc.List(pandoc.utils.blocks_to_inlines(v)) end
  return pandoc.List(v)
end

-- Metadata as a block list (MetaBlocks, or one paragraph for inline metadata).
local function B(v)
  if v == nil then return {} end
  if v.t == "MetaBlocks" then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b end
    return out
  end
  return { pandoc.Para(I(v)) }
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- A paragraph in a named style (reference.docx).
local function styled(name, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- Turns the paragraphs of a block list into the "Single" style (single-spaced, no indent).
local function as_single(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Para" then out[#out + 1] = styled("Single", b.content) else out[#out + 1] = b end
  end
  return out
end

local function tab_run() return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") end

-- A vertical gap of an exact height in twips (the typst v() spacing), as an empty paragraph.
local function gap(twips)
  return pandoc.RawBlock("openxml",
    "<w:p><w:pPr><w:pStyle w:val=\"Gap\"/><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"" .. twips
    .. "\" w:lineRule=\"exact\"/></w:pPr><w:r><w:t xml:space=\"preserve\">" .. NBSP .. "</w:t></w:r></w:p>")
end

-- Plain word count of the markdown body, mirroring typst's count-words (ca10-answering-brief.typ):
-- footnote definitions and references out, link text kept, [*_#>`] become spaces, whitespace tokens counted.
local function body_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("ca10: no input file for the word count", 0) end
  local h = io.open(f, "r")
  if not h then error("ca10: cannot read " .. f, 0) end
  local text = h:read("a")
  h:close()
  -- the body is what follows the closing "---" of the frontmatter
  local body = text:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n(.*)$") or text
  local s = body:gsub("%[%^[^%]]+%]:[^\n]*", " ")
  s = s:gsub("%[%^[^%]]+%]", "")
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
  s = s:gsub("[%*_#>`]", " ")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function sig_block(meta, lead)
  -- "s/ <signer>" then the signature lines, one paragraph with hard line breaks (the typst linebreaks)
  local sig = meta.signature
  local inl = pandoc.List({ pandoc.Str(lead .. "s/ ") })
  inl:extend(I(sig.signer))
  for _, l in ipairs(sig.lines or {}) do
    inl:insert(pandoc.LineBreak())
    inl:extend(I(l))
  end
  return styled("SigLeft", inl)
end

local function toc_row(style, inlines)
  -- contents entries carry no page numbers (see the header of this file): no tab after the title
  return styled(style, pandoc.List(inlines))
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "judge", "district_court_case", "brief_title",
    "counsel", "phone", "signature", "date", "oral_argument", "oral_argument_statement", "prior_related",
    "virus_scanner", "authorities" }) do
    if meta[k] == nil then error("ca10: missing required metadata field `" .. k .. "`", 0) end
  end

  local auth = {}
  for key, a in pairs(meta.authorities) do
    auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite }
  end

  -- citations: the link text stays; a toa: link must name an authority
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("ca10: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      return el.content
    end,
  })

  local words = body_words()
  if words > WORD_LIMIT then
    error("ca10: the brief has " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. WORD_LIMIT, 0)
  end

  -- the body headings (levels 1 and 2 are the contents entries; the body keeps its numerals as written)
  local body = doc.blocks
  local toc = {}
  for _, b in ipairs(body) do
    if b.t == "Header" and b.level <= 2 then toc[#toc + 1] = { level = b.level, content = b.content } end
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end
  local oral = meta.oral_argument

  -- ---- cover, page i (unnumbered) ----
  add(styled("Centered", I("No. " .. plain(meta.case_number))))
  add(gap(864))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("UNITED STATES COURT OF APPEALS") }) }))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("FOR THE TENTH CIRCUIT") }) }))
  add(gap(1008))
  for i, side in ipairs(meta.caption) do
    for _, n in ipairs(side.names or {}) do add(styled("Centered", I(n))) end
    add(styled("Centered", I(side.designation)))
    if i < #meta.caption then
      add(gap(140))
      add(styled("Centered", { pandoc.Str("v.") }))
      add(gap(140))
    end
  end
  add(gap(1152))
  add(styled("Centered", I(meta.proceeding)))
  add(styled("Centered", I(meta.judge)))
  add(styled("Centered", I(meta.district_court_case)))
  add(BREAK_COVER_1)

  -- ---- cover, page ii (roman, numbered ii) ----
  add(gap(1152))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(plain(meta.brief_title):upper()) }) }))
  add(gap(720))
  add(styled("Centered", I(oral)))
  add(gap(1728))
  for _, g in ipairs(meta.counsel) do
    for _, n in ipairs(g.names or {}) do add(styled("Counsel", I(n))) end
    for _, l in ipairs(g.lines or {}) do add(styled("Counsel", { pandoc.Emph(I(l)) })) end
    add(gap(168))
  end
  add(styled("Centered", I(meta.phone)))
  add(BREAK_COVER_2)

  -- ---- contents (roman, iii): the rows follow the typst toc-section ----
  add(styled("SectionTitle", { pandoc.Str("TABLE OF CONTENTS") }))
  add(toc_row("TOCK0", { pandoc.Str("TABLE OF AUTHORITIES") }))
  add(toc_row("TOCK0", { pandoc.Str("STATEMENT OF PRIOR OR RELATED APPEALS") }))
  for _, e in ipairs(toc) do
    if e.level == 1 then
      add(toc_row("TOCK0", e.content))
    else
      add(toc_row("TOCK1", e.content))
    end
  end
  add(toc_row("TOCK0", { pandoc.Str("STATEMENT OF COUNSEL AS TO ORAL ARGUMENT") }))
  add(toc_row("TOCK0", { pandoc.Str("CERTIFICATE OF COMPLIANCE WITH TYPE-VOLUME LIMIT") }))
  add(toc_row("TOCK0", { pandoc.Str("CERTIFICATE OF DIGITAL SUBMISSION") }))
  add(toc_row("TOCK0", { pandoc.Str("CERTIFICATE OF SERVICE") }))
  add(BREAK_FRONT)

  -- ---- table of authorities and prior appeals (roman, iv): every authority of the four kinds, as typst lists them ----
  add(styled("SectionTitle", { pandoc.Str("TABLE OF AUTHORITIES") }))
  for _, g in ipairs(TOA_KINDS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return plain(auth[x].name):lower() < plain(auth[y].name):lower() end)
      add(styled("TOAGroup", { pandoc.Strong({ pandoc.Str(g[2]) }) }))
      for _, key in ipairs(members) do
        local a = auth[key]
        local nm = I(a.name)
        if g[1] == "case" then nm = pandoc.List({ pandoc.Emph(nm) }) end
        local line = pandoc.List({})
        line:extend(nm)
        if a.cite and plain(a.cite) ~= "" then
          line:insert(pandoc.Str(", "))
          line:extend(I(a.cite))
        end
        line:insert(tab_run())
        add(styled("TOALine", line))
      end
    end
  end
  add(gap(336))
  add(styled("SectionTitle", { pandoc.Str("STATEMENT OF PRIOR OR RELATED APPEALS") }))
  addall(as_single(B(meta.prior_related)))
  add(BREAK_FRONT)

  -- ---- body (arabic from 1) ----
  addall(body)
  add(styled("SigFirst", { pandoc.Str("Respectfully submitted,") }))
  add(gap(336))
  add(sig_block(meta, ""))

  -- statement of counsel as to oral argument (10th Cir. R. 28.2(C)(2); FRAP 34)
  add(gap(224))
  add(styled("SectionTitle", { pandoc.Str("STATEMENT OF COUNSEL AS TO ORAL ARGUMENT") }))
  addall(B(meta.oral_argument_statement))
  add(BREAK_BODY)

  -- certificates (FRAP 32(g); 10th Cir. R. 25.5; FRAP 25(d); 10th Cir. R. 25.4), each on its own page
  add(styled("SectionTitle", { pandoc.Str("CERTIFICATE OF COMPLIANCE WITH TYPE-VOLUME LIMIT") }))
  add(styled("Single", { pandoc.Str("1. This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because:") }))
  add(styled("CertIndent", { pandoc.Str("[x] this brief contains " .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f) and 10th Cir. R. 32(B).") }))
  add(gap(224))
  add(styled("Single", { pandoc.Str("2. This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because:") }))
  add(styled("CertIndent", { pandoc.Str("[x] this brief has been prepared in a proportionally spaced typeface using a proportionally spaced word processor in 14-point " .. TYPEFACE .. ".") }))
  add(gap(224))
  add(styled("Single", { pandoc.Str("Date: " .. plain(meta.date) .. ".") }))
  add(gap(336))
  add(sig_block(meta, ""))
  add(BREAK_CERT)

  -- certificate of digital submission (10th Cir. R. 25.5)
  add(styled("SectionTitle", { pandoc.Str("CERTIFICATE OF DIGITAL SUBMISSION") }))
  add(styled("Single", { pandoc.Str("I hereby certify that with respect to the foregoing:") }))
  add(styled("Single", { pandoc.Str("(1) all required privacy redactions have been made per 10th Cir. R. 25.5;") }))
  add(styled("Single", { pandoc.Str("(2) if required to file additional hard copies, that the ECF submission is an exact copy of those documents;") }))
  local item3 = pandoc.List({ pandoc.Str("(3) the digital submissions have been scanned for viruses with the most recent version of a commercial virus scanning program, ") })
  item3:extend(I(meta.virus_scanner))
  item3:insert(pandoc.Str(", and according to the program are free of viruses."))
  add(gap(168))
  add(styled("Single", item3))
  add(gap(336))
  add(sig_block(meta, ""))
  add(BREAK_CERT)

  -- certificate of service (FRAP 25; 10th Cir. R. 25.4): the last section, ends at the reference's final sectPr
  add(styled("SectionTitle", { pandoc.Str("CERTIFICATE OF SERVICE") }))
  add(styled("Single", { pandoc.Str("I hereby certify that on " .. plain(meta.date) .. " a true and correct copy of the foregoing was filed with the Clerk of the Court using CM/ECF system and also served on the following:") }))
  local svc = meta.service
  if svc and svc.unregistered then
    for _, g in ipairs(svc.unregistered) do
      local inl = pandoc.List({})
      for i, line in ipairs(g) do
        if i > 1 then inl:insert(pandoc.LineBreak()) end
        inl:extend(I(line))
      end
      add(gap(224))
      add(styled("Single", inl))
    end
  end
  add(gap(336))
  add(sig_block(meta, "By: "))

  -- the writer would print title, author and date from the metadata at the top; the cover prints them itself
  doc.meta.title = nil
  doc.meta.author = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end
