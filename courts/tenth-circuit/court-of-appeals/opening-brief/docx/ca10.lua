-- Tenth Circuit brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/ca10-opening-brief.typ (the reference): the cover, the front matter (lower-roman pages: contents,
-- authorities, prior appeals), the body (arabic from 1), the statement in support of oral argument, the
-- certificates and the index of attachments.
-- Pages are separated by section breaks (SectionBreak paragraphs carrying a sectPr), so the footer numbering
-- follows the sections and no page starts with an empty line.
-- Heading labels are written here, as the typst template labels them (Argument: I. A. 1. a.; elsewhere
-- A. 1. a. (1)). Paragraph and heading geometry comes from the styles in reference.docx (build-reference.sh).
-- Known limit (BLOCKED, see the review): the contents and the table of authorities list their entries without
-- page numbers. Their page numbers need a field update in Word or LibreOffice (or a first-pass render), which
-- this headless pipeline does not do.

local WORD_LIMIT = 13000
local TYPEFACE = "EB Garamond"

local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local PAGE_SIZE = "<w:pgSz w:w=\"12240\" w:h=\"15840\"/>"
  .. "<w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" w:left=\"1440\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/>"

-- A section break: the paragraph ends the section. The cover has no footer; the front matter and the body
-- carry the page-number footer (rId100 of reference.docx) in roman or arabic.
local function section_break(footer, pgnum)
  local ftr = footer and "<w:footerReference w:type=\"default\" r:id=\"rId100\"/>" or ""
  return pandoc.RawBlock("openxml",
    "<w:p><w:pPr><w:pStyle w:val=\"SectionBreak\"/><w:sectPr>"
    .. ftr .. "<w:type w:val=\"nextPage\"/>" .. PAGE_SIZE .. (pgnum or "") .. "</w:sectPr></w:pPr></w:p>")
end
local BREAK_COVER = section_break(false, nil)
local BREAK_FRONT_FIRST = section_break(true, "<w:pgNumType w:fmt=\"lowerRoman\" w:start=\"1\"/>")
local BREAK_FRONT = section_break(true, "<w:pgNumType w:fmt=\"lowerRoman\"/>")
local BREAK_BODY = section_break(true, "<w:pgNumType w:fmt=\"decimal\"/>")
local BREAK_BODY_FIRST = section_break(true, "<w:pgNumType w:fmt=\"decimal\" w:start=\"1\"/>")

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

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

-- A paragraph in a named style (reference.docx). Pass blocks, or inlines with inline = true.
local function styled(name, content, inline)
  local blocks = content
  if inline then blocks = { pandoc.Para(content) } end
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- Turns the paragraphs of a block list into the "Single" style (single-spaced, no indent).
local function as_single(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Para" then out[#out + 1] = styled("Single", b.content, true) else out[#out + 1] = b end
  end
  return out
end

local function tab_run() return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") end
local NBSP = "\u{00A0}"
local function rule(name) return pandoc.Div({ pandoc.Para({ pandoc.Str(NBSP) }) }, pandoc.Attr("", {}, { ["custom-style"] = name })) end
local function blank(name) return styled(name or "Gap", { pandoc.Str(NBSP) }, true) end

-- ---------------------------------------------------------------------------
-- Headings: the labels and the contents entries
-- ---------------------------------------------------------------------------

local counts = { 0, 0, 0, 0, 0 }
local in_arg = false

local function label_for(level)
  local n = counts[level]
  if in_arg then
    if level == 2 then return roman(n) .. "."
    elseif level == 3 then return string.char(64 + n) .. "."
    elseif level == 4 then return tostring(n) .. "."
    elseif level == 5 then return string.char(96 + n) .. "."
    end
  else
    if level == 2 then return string.char(64 + n) .. "."
    elseif level == 3 then return tostring(n) .. "."
    elseif level == 4 then return string.char(96 + n) .. "."
    elseif level == 5 then return "(" .. tostring(n) .. ")"
    end
  end
  error("ca10: headings deeper than level 5 are not supported", 0)
end

local toc = {}   -- contents entries, in order: { level, label, text, k }

-- The body heading for a markdown heading. k is the label's step: label at k half-inches, text hangs after it.
local function body_heading(h)
  local level = h.level
  local text = pandoc.utils.stringify(h.content)
  if level == 1 then
    in_arg = text:lower():match("^%s*(.-)%s*$") == "argument"
    for l = 2, 5 do counts[l] = 0 end
    counts[1] = counts[1] + 1
    toc[#toc + 1] = { level = 1, label = nil, text = text, k = 0 }
    return pandoc.Header(1, h.content)
  end
  if level > 5 then error("ca10: headings deeper than level 5 are not supported", 0) end
  for l = level + 1, 5 do counts[l] = 0 end
  counts[level] = counts[level] + 1
  local lab = label_for(level)
  if in_arg and level == 2 then
    toc[#toc + 1] = { level = 2, label = lab, text = text, k = 0 }
    local inl = pandoc.List({ pandoc.Str(lab), pandoc.Space() })
    inl:extend(h.content)
    return styled("PointHeading", inl, true)
  end
  local first = in_arg and 3 or 2
  local k = level - first + 1
  toc[#toc + 1] = { level = level, label = lab, text = text, k = k }
  local inl
  if level >= 4 then
    inl = pandoc.List({ pandoc.Strong(pandoc.Emph({ pandoc.Str(lab) })), tab_run(),
      pandoc.Strong(pandoc.Emph(h.content)) })
  else
    inl = pandoc.List({ pandoc.Strong({ pandoc.Str(lab) }), tab_run(), pandoc.Strong(h.content) })
  end
  return styled("SubHead" .. k, inl, true)
end

-- Contents line for one toc entry (label at its step, title hanging after it; level 1 has no label).
local function toc_line(e)
  local inl = pandoc.List({})
  if e.label then inl:insert(pandoc.Str(e.label)); inl:insert(tab_run()) end
  if e.level == 1 then inl:insert(pandoc.Str(e.text:upper())) else inl:extend(pandoc.List({ pandoc.Str(e.text) })) end
  return styled("TOCK" .. e.k, inl, true)
end

-- Plain word count of the markdown body (typst's count-words rules, line by line; approximate).
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return 0 end
  local h = io.open(f, "r")
  if not h then return 0 end
  local text = h:read("a")
  h:close()
  local dashes, n = 0, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    else
      local s = line:gsub("<!%-%-.-%-%->", " ")
      s = s:gsub("^%[%^[^%]]+%]:", " ")
      s = s:gsub("%[%^[^%]]*%]", "")
      s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
      s = s:gsub("^#+[ \t]+", "")
      s = s:gsub("^>[ \t]?", "")
      s = s:gsub("^[ \t]*[-*+][ \t]+", "")
      s = s:gsub("^[ \t]*%d+[.)][ \t]+", "")
      s = s:gsub("\\(.)", "%1")
      s = s:gsub("%*", "")
      s = s:gsub("_", "")
      for _ in s:gmatch("%S+") do n = n + 1 end
    end
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function sort_key(a)
  local s = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

-- Fancy list markers ("(I)", "A.", "(1)") are text in the markdown contract, not lists (CommonMark reads them
-- as text, and so does the typst template): they become paragraphs that keep their marker.
local function list_marker(n, style, delim)
  local s
  if style == "LowerRoman" or style == "UpperRoman" then
    s = roman(n)
    if style == "LowerRoman" then s = s:lower() end
  elseif style == "LowerAlpha" or style == "UpperAlpha" then
    s = string.char((style == "LowerAlpha" and 96 or 64) + n)
  else
    s = tostring(n)
  end
  if delim == "OneParen" then return s .. ")" end
  if delim == "TwoParens" then return "(" .. s .. ")" end
  return s .. "."
end

local function unlist_fancy(doc)
  return doc:walk({
    OrderedList = function(el)
      local a = el.listAttributes
      local st, dl = tostring(a.style), tostring(a.delimiter)
      local fancy = st == "LowerRoman" or st == "UpperRoman" or st == "LowerAlpha" or st == "UpperAlpha"
        or dl == "OneParen" or dl == "TwoParens"
      if not fancy then return nil end
      local out = {}
      for i, item in ipairs(el.content) do
        local marker = list_marker(a.start + i - 1, st, dl)
        for j, b in ipairs(item) do
          if j == 1 and (b.t == "Para" or b.t == "Plain") then
            local inl = pandoc.List({ pandoc.Str(marker), pandoc.Space() })
            inl:extend(b.content)
            out[#out + 1] = pandoc.Para(inl)
          else
            out[#out + 1] = b
          end
        end
      end
      return out
    end,
  })
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "proceeding", "judge", "district_court_case", "brief_title",
    "counsel", "signature", "date", "oral_argument", "prior_appeals", "digital_submission", "attachments" }) do
    if meta[k] == nil then error("ca10: missing required metadata field `" .. k .. "`", 0) end
  end
  local oral = plain(meta.oral_argument)
  if oral ~= "requested" and oral ~= "not requested" then
    error("ca10: oral_argument must be `requested` or `not requested`", 0)
  end
  if oral == "requested" and meta.oral_argument_statement == nil then
    error("ca10: oral_argument is requested but there is no oral_argument_statement", 0)
  end

  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
    end
  end

  doc = unlist_fancy(doc)
  -- citations: the link text stays; the keys cited are collected for the table of authorities
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("ca10: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      return el.content
    end,
  })

  local words = source_words()
  if words > WORD_LIMIT then
    error("ca10: the brief has " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. WORD_LIMIT, 0)
  end

  -- the body, labelled (this also fills the contents entries)
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then body[#body + 1] = body_heading(b) else body[#body + 1] = b end
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- ---- cover (FRAP 32(a)(2); 10th Cir. R. 28.2(C)(1)-(2)) ----
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("No. "), table.unpack(I(meta.case_number)) }) }, true))
  add(rule("RuleThick"))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("IN THE UNITED STATES COURT OF APPEALS") }) }, true))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("FOR THE TENTH CIRCUIT") }) }, true))
  add(rule("RuleShort"))
  for i, side in ipairs(meta.caption) do
    for _, n in ipairs(side.names or {}) do add(styled("Centered", I(n), true)) end
    add(styled("Designation", I(side.designation), true))
    if i < #meta.caption then add(styled("Centered", { pandoc.Str("v.") }, true)) end
  end
  add(rule("RuleShort"))
  add(styled("Centered", I(meta.proceeding), true))
  add(styled("Centered", I(meta.judge), true))
  add(styled("Centered", { pandoc.Str("Case No. "), table.unpack(I(meta.district_court_case)) }, true))
  add(rule("RuleShort"))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(plain(meta.brief_title):upper()) }) }, true))
  add(rule("RuleShort"))
  for _, g in ipairs(meta.counsel) do
    for _, n in ipairs(g.names or {}) do add(styled("Designation", I(n), true)) end
    for _, l in ipairs(g.lines or {}) do add(styled("SigLine", { pandoc.Emph(I(l)) }, true)) end
    add(blank())
  end
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(oral == "requested" and "ORAL ARGUMENT REQUESTED" or "ORAL ARGUMENT NOT REQUESTED") }) }, true))
  add(rule("RuleThick"))
  add(BREAK_COVER)

  -- ---- front matter (lower roman): contents, authorities, prior appeals ----
  -- the contents lists the front matter and the body, in order; the page column has no numbers (see the header)
  local sig = meta.signature

  -- table of authorities: the authorities cited in the body, grouped by kind
  local toa = {}
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return sort_key(auth[x]) < sort_key(auth[y]) end)
      toa[#toa + 1] = { title = g[2], members = members, kind = g[1] }
    end
  end

  -- the contents lines (they list the authorities, prior appeals, body and certificates, as the template does)
  add(pandoc.Header(1, { pandoc.Str("Table of Contents") }))
  add(styled("RightHead", { pandoc.Str("Page") }, true))
  for _, e in ipairs({ { level = 1, text = "Table of Authorities", k = 0 }, { level = 1, text = "Statement of Prior or Related Appeals", k = 0 } }) do
    add(toc_line(e))
  end
  for _, e in ipairs(toc) do add(toc_line(e)) end
  if oral == "requested" then add(toc_line({ level = 1, text = "Statement in Support of Oral Argument", k = 0 })) end
  for _, t in ipairs({ "Certificate of Compliance", "Certificate of Digital Submission", "Certificate of Service", "Index of Attachments" }) do
    add(toc_line({ level = 1, text = t, k = 0 }))
  end
  add(BREAK_FRONT_FIRST)

  add(pandoc.Header(1, { pandoc.Str("Table of Authorities") }))
  for gi, g in ipairs(toa) do
    local head = pandoc.List({ pandoc.Strong({ pandoc.Str(g.title) }) })
    if gi == 1 then head:insert(tab_run()); head:insert(pandoc.Strong(pandoc.Underline({ pandoc.Str("Page(s)") }))) end
    add(styled("TOAGroup", head, true))
    for _, k in ipairs(g.members) do
      local a = auth[k]
      local line = pandoc.List({})
      if a.name then
        local nm = I(a.name)
        if g.kind == "case" then nm = pandoc.List({ pandoc.Emph(nm) }) end
        line:extend(nm)
        line:insert(pandoc.Str(","))
        line:insert(pandoc.LineBreak())
      end
      line:extend(I(a.cite))
      line:insert(tab_run())
      add(styled("TOALine", line, true))
    end
  end
  add(BREAK_FRONT)

  add(pandoc.Header(1, { pandoc.Str("Statement of Prior or Related Appeals") }))
  addall(as_single(B(meta.prior_appeals)))
  add(BREAK_FRONT)

  -- ---- body (arabic from 1) ----
  addall(body)
  add(styled("SigLeft", { pandoc.Str("Respectfully submitted,") }, true))
  add(blank("GapSig"))
  add(styled("SigLeft", { pandoc.Str("/s/ " .. plain(sig.signer)) }, true))
  add(styled("SigLeft", I(sig.signer), true))
  for _, l in ipairs(sig.lines or {}) do add(styled("SigLine", { pandoc.Emph(I(l)) }, true)) end
  add(styled("Single", { pandoc.Str("Dated: "), table.unpack(I(meta.date)) }, true))

  if oral == "requested" then
    add(pandoc.Header(1, { pandoc.Str("Statement in Support of Oral Argument") }))
    addall(as_single(B(meta.oral_argument_statement)))
  end

  -- certificates (FRAP 32(g)(1); 10th Cir. R. 25.4, 25.5) and the index of attachments
  add(BREAK_BODY_FIRST)
  add(pandoc.Header(1, { pandoc.Str("Certificate of Compliance") }))
  add(styled("Single", { pandoc.Str("This brief complies with the type-volume limitation of Federal Rule of Appellate Procedure 32(a)(7)(B), because it contains " .. group_digits(words) .. " words, which is no more than the " .. group_digits(WORD_LIMIT) .. " words permitted for a principal brief, excluding the parts of the brief exempted by Federal Rule of Appellate Procedure 32(f).") }, true))
  add(styled("Single", { pandoc.Str("The brief also complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and the type style requirements of Federal Rule of Appellate Procedure 32(a)(6), because it has been prepared in a proportionally spaced typeface, " .. TYPEFACE .. ", in 14-point type.") }, true))
  add(blank("GapSig"))
  add(styled("SigLeft", { pandoc.Str("/s/ " .. plain(sig.signer)) }, true))
  add(styled("SigLeft", I(sig.signer), true))
  add(styled("SigLeft", I(meta.date), true))

  local ds = meta.digital_submission
  add(BREAK_BODY)
  add(pandoc.Header(1, { pandoc.Str("Certificate of Digital Submission") }))
  add(styled("Single", { pandoc.Str("I hereby certify that with respect to the foregoing:") }, true))
  add(styled("DigitalItem", { pandoc.Str("(1) all required privacy redactions have been made per Fed. R. App. P. 25(a)(5) and 10th Cir. R. 25.5;") }, true))
  add(styled("DigitalItem", { pandoc.Str("(2) that this document is a native PDF document;") }, true))
  add(styled("DigitalItem", { pandoc.Str("(3) that the ECF submission is an exact copy of those documents;") }, true))
  local item4 = pandoc.List({ pandoc.Str("(4) the digital submission has been scanned for viruses with the most recent version of a commercial virus scanning program, ") })
  item4:extend(I(ds.scanner))
  item4:insert(pandoc.Str(", last updated on "))
  item4:extend(I(ds.updated))
  item4:insert(pandoc.Str("; and"))
  add(styled("DigitalItem", item4, true))
  add(styled("DigitalItem", { pandoc.Str("(5) according to the program, this document is free of viruses.") }, true))
  add(blank("GapSig"))
  add(styled("SigLeft", { pandoc.Str("/s/ " .. plain(sig.signer)) }, true))
  add(styled("SigLeft", I(sig.signer), true))
  add(styled("SigLeft", I(meta.date), true))

  add(pandoc.Header(1, { pandoc.Str("Certificate of Service") }))
  add(styled("Single", { pandoc.Str("I hereby certify that on " .. plain(meta.date) .. ", pursuant to Fed. R. App. P. 25 and 10th Cir. R. 25.4, I electronically filed the foregoing using the Court\u{2019}s CM/ECF system, which in turn caused electronic notifications of such filing to be sent to all counsel of record.") }, true))
  add(blank("GapSig"))
  add(styled("SigLeft", { pandoc.Str("/s/ " .. plain(sig.signer)) }, true))
  add(styled("SigLeft", I(sig.signer), true))
  add(styled("SigLeft", I(meta.date), true))

  add(BREAK_BODY)
  add(pandoc.Header(1, { pandoc.Str("Index of Attachments") }))
  for i, a in ipairs(meta.attachments) do
    local line = I(a)
    line:insert(tab_run())
    line:insert(pandoc.Str("Attachment " .. i))
    add(styled("TOALine", line, true))
  end

  -- the writer would print title, author and date from the metadata at the top; the cover prints them itself
  doc.meta.title = nil
  doc.meta.author = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end
