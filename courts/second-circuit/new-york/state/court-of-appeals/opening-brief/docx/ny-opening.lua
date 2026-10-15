-- New York Court of Appeals opening brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on docx/reference.docx, in the form of typst/ny-opening-brief.typ. The cover, the front matter,
-- the certificates and the affidavit are built here; the body keeps its markdown structure.
-- Sections (footers and page-number formats are in reference.docx): cover (no number), front matter
-- (lower roman), body and certificates (arabic from 1), addendum (arabic from 1).
-- Point headings get the typst numbering (I. / A. / 1. / a.) as text, so every viewer shows it.
-- Known limits (BLOCKED, see README "Engines"): the table of contents is a TOC field, so its page
-- numbers appear only after a field update; the table of authorities lists the authorities without
-- page numbers (a TOA field is not honoured by LibreOffice); the addendum is numbered 1, 2, ... (typst: Add-1).

local WORD_LIMIT = 14000
local DEFAULT_WORD_PROCESSOR = "a word-processing system"
local FONT_NAME = "EB Garamond"
local POINT_SIZE = 14
local TYPE_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("ny-opening: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- a metadata value (markdown) as a plain list of inlines (pandoc.utils.type: Inlines, Blocks or a string)
local function inl(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "string" then return { pandoc.Str(v) } end
  local ty = pandoc.utils.type(v)
  if ty == "Blocks" then return pandoc.utils.blocks_to_inlines(v) end
  if ty == "Inlines" then
    for _, i in ipairs(v) do out[#out + 1] = i end
  end
  return out
end

-- a metadata value (markdown blocks) as a plain list of blocks
local function blocks(v)
  local out = {}
  if v == nil then return out end
  if pandoc.utils.type(v) == "Blocks" then
    for _, b in ipairs(v) do out[#out + 1] = b end
  else
    out[1] = pandoc.Plain(inl(v))
  end
  return out
end

local function cat(...)
  local out = {}
  for _, l in ipairs({ ... }) do
    for _, i in ipairs(l) do out[#out + 1] = i end
  end
  return out
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(pandoc.Inlines(inlines)) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw_page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- end of a section: an empty paragraph carrying the section properties (footer rId, number format, start)
local function section_end(footer_rid, fmt, start)
  return pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:sectPr>'
    .. '<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>'
    .. '</w:sectPr></w:pPr></w:p>')
end

-- a borderless two-or-more-column table; each cell is a list of blocks
local function columns(widths, cells)
  local aligns = {}
  for i = 1, #widths do aligns[i] = pandoc.AlignDefault end
  local st = pandoc.SimpleTable({}, aligns, widths, {}, { cells })
  return pandoc.utils.from_simple_table(st)
end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function roman(n)
  local map = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(map) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

-- point heading label as typst's heading-label(): I. / A. / 1. / a. for levels 2 to 5
local function heading_label(level, c)
  if level == 2 then return roman(c[2]) .. "."
  elseif level == 3 then return string.char(64 + c[3]) .. "."
  elseif level == 4 then return tostring(c[4]) .. "."
  else return string.char(96 + c[5]) .. "."
  end
end

-- ---------------------------------------------------------------------------
-- word count (typst's count-words on the markdown body, questions presented excluded: 500.13(c)(3))
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("ny-opening: no input file to count words from", 0) end
  local h = io.open(f, "r")
  if not h then error("ny-opening: cannot read " .. f, 0) end
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
    local heading = line:match("^#+%s+(.-)%s*$")
    if heading then
      skipping = heading:lower() == "questions presented"
    end
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

-- ---------------------------------------------------------------------------
-- the document
-- ---------------------------------------------------------------------------

local function plain_of(v)
  return pandoc.utils.stringify(pandoc.Inlines(inl(v)))
end

-- inlines in upper case (text only; the case names inside are not italic here)
local function upper_str_inl(list)
  local out = {}
  for _, i in ipairs(list) do
    if i.t == "Str" then out[#out + 1] = pandoc.Str(string.upper(i.text)) else out[#out + 1] = i end
  end
  return out
end

local function cover(meta)
  local out = {}
  local arg = need(meta, "argument")
  local left = {}
  left[#left + 1] = styled("Single", inl(need(meta, "docket")))
  if meta.county_clerk_index then left[#left + 1] = styled("Single", inl(meta.county_clerk_index)) end
  local right = {}
  if arg.presenter then
    right[#right + 1] = styled("Right", { pandoc.Str("To be Argued by:") })
    right[#right + 1] = styled("Right", { pandoc.Strong(upper_str_inl(inl(arg.presenter))) })
    right[#right + 1] = styled("Right", cat({ pandoc.Str("(Time Requested: ") }, inl(arg.time_requested), { pandoc.Str(")") }))
  else
    right[#right + 1] = styled("Right", { pandoc.Str("Submitted without oral argument") })
  end
  out[#out + 1] = columns({ 0.6, 0.4 }, { left, right })
  out[#out + 1] = styled("Centered", { pandoc.Strong({ pandoc.Str("Court of Appeals of the State of New York") }) })
  for i, side in ipairs(need(meta, "caption")) do
    for _, n in ipairs(side.names) do out[#out + 1] = styled("Single", inl(n)) end
    out[#out + 1] = styled("Designation", inl(side.designation))
    if i < #need(meta, "caption") then
      out[#out + 1] = styled("Centered", { pandoc.Str("\u{2013} against \u{2013}") })
    end
  end
  out[#out + 1] = styled("CoverTitle", inl(need(meta, "brief_title")))
  local groups = {}
  for _, g in ipairs(need(meta, "counsel")) do
    local col = {}
    col[#col + 1] = styled("CoverFirm", inl(g.firm))
    for _, l in ipairs(g.lines) do col[#col + 1] = styled("Single", { pandoc.Emph(inl(l)) }) end
    groups[#groups + 1] = col
  end
  local widths = {}
  for i = 1, #groups do widths[i] = 1 / #groups end
  out[#out + 1] = columns(widths, groups)
  out[#out + 1] = styled("Centered", { pandoc.Emph(inl(need(meta, "attorneys_for"))) })
  out[#out + 1] = styled("Centered", cat({ pandoc.Str("Date Completed: ") }, inl(need(meta, "date_completed"))))
  out[#out + 1] = section_end("rId100", "decimal", 1)
  return out
end

-- the signature block (typst signature-block): firms side by side, the first with the "By:" line
local function signature_block(meta, with_address)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = styled("Single", { pandoc.Str("Dated: " .. plain_of(sig.place)) })
  out[#out + 1] = styled("Single", inl(sig.date))
  local cells = {}
  for bi, b in ipairs(sig.blocks) do
    local col = {}
    col[#col + 1] = styled("CoverFirm", inl(b.firm))
    if bi == 1 then col[#col + 1] = styled("Single", { pandoc.Str("By: ____________________________") }) end
    for _, n in ipairs(b.names) do col[#col + 1] = styled("Single", inl(n)) end
    if with_address then
      for _, l in ipairs(b.lines) do col[#col + 1] = styled("Single", { pandoc.Emph(inl(l)) }) end
    end
    cells[#cells + 1] = col
  end
  local widths = {}
  for i = 1, #cells do widths[i] = 1 / #cells end
  out[#out + 1] = columns(widths, cells)
  out[#out + 1] = styled("Single", { pandoc.Emph(inl(sig.attorneys_for)) })
  return out
end


-- the certificate of compliance (500.1(j) and 500.13(c)(1))
local function certificate_of_compliance(meta, words)
  local out = {}
  out[#out + 1] = styled("FrontHeadingBreak", { pandoc.Str("Certificate of Compliance") })
  local wp = meta.word_processor and inl(meta.word_processor) or { pandoc.Str(DEFAULT_WORD_PROCESSOR) }
  out[#out + 1] = pandoc.Div({ pandoc.Para(cat(
    { pandoc.Str("I hereby certify pursuant to 22 NYCRR 500.1(j) that the foregoing brief was prepared on a computer using ") },
    wp, { pandoc.Str(".") })) }, pandoc.Attr("", {}, { ["custom-style"] = "BodyText" }))
  out[#out + 1] = pandoc.Para({ pandoc.Str("A proportionally spaced typeface was used, as follows:") })
  out[#out + 1] = styled("Indented", { pandoc.Str("Name of typeface: " .. FONT_NAME) })
  out[#out + 1] = styled("Indented", { pandoc.Str("Point size: " .. POINT_SIZE) })
  out[#out + 1] = styled("Indented", { pandoc.Str("Line spacing: Double") })
  out[#out + 1] = pandoc.Para(cat(
    { pandoc.Strong({ pandoc.Str("Word Count.") }), pandoc.Space(),
      pandoc.Str("The total number of words in this brief, inclusive of point headings and footnotes and exclusive of pages containing the table of contents, table of citations, proof of service, certificate of compliance, corporate disclosure statement, questions presented, statement of related litigation, or any authorized addendum containing statutes, rules, regulations, etc., is " .. group_digits(words) .. ".") }))
  for _, p in ipairs(signature_block(meta, false)) do out[#out + 1] = p end
  return out
end

-- the affidavit of service (500.1(e)): blanks only
local function affidavit_of_service()
  local blank = "____________"
  local out = {}
  out[#out + 1] = styled("FrontHeadingBreak", { pandoc.Str("Affidavit of Service") })
  out[#out + 1] = styled("Single", { pandoc.Str("STATE OF NEW YORK )") })
  out[#out + 1] = styled("Single", { pandoc.Str(") ss.:") })
  out[#out + 1] = styled("Single", { pandoc.Str("COUNTY OF " .. blank .. " )") })
  out[#out + 1] = pandoc.Para({ pandoc.Str(blank .. ", being duly sworn, deposes and says: deponent is not a party to this action, is over 18 years of age, and resides at " .. blank .. ".") })
  out[#out + 1] = pandoc.Para({ pandoc.Str("On the " .. blank .. " day of " .. blank .. ", 20__, deponent served the within brief upon each attorney for each party to this appeal, at the address designated by that attorney for that purpose, by " .. blank .. ", and by " .. blank .. ".") })
  out[#out + 1] = styled("Signature", { pandoc.Str(blank) })
  out[#out + 1] = styled("Signature", { pandoc.Str("Sworn to before me this") })
  out[#out + 1] = styled("Signature", { pandoc.Str(blank .. " day of " .. blank .. ", 20__") })
  out[#out + 1] = styled("Signature", { pandoc.Str(blank) })
  out[#out + 1] = styled("Signature", { pandoc.Str("Notary Public") })
  return out
end

-- the table of authorities: the authorities cited in the document, by kind, sorted by name
local function table_of_authorities(authorities, used)
  local out = {}
  out[#out + 1] = styled("FrontHeadingBreak", { pandoc.Str("Table of Authorities") })
  for _, g in ipairs(TYPE_GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and plain_of(a.kind) == g[1] then members[#members + 1] = key end
    end
    if #members > 0 then
      local function sort_key(k)
        local a = authorities[k]
        local s = a.sort and plain_of(a.sort) or (plain_of(a.name or {}) .. " " .. plain_of(a.cite))
        return (s:lower():gsub("[^a-z0-9 ]", ""))
      end
      table.sort(members, function(x, y) return sort_key(x) < sort_key(y) end)
      out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str(g[2]) }) }) },
        pandoc.Attr("", {}, { ["custom-style"] = "Single" }))
      for _, k in ipairs(members) do
        local a = authorities[k]
        local line = {}
        if a.name then
          local nm = inl(a.name)
          if g[1] == "case" then nm = { pandoc.Emph(nm) } end
          line = cat(nm, { pandoc.Str(","), pandoc.LineBreak() })
        end
        line = cat(line, inl(a.cite))
        out[#out + 1] = styled("Authority", line)
      end
    end
  end
  return out
end

-- the table of contents: a TOC field (its page numbers come with a field update, see the header)
local function table_of_contents()
  local out = {}
  out[#out + 1] = styled("FrontHeadingBreak", { pandoc.Str("Table of Contents") })
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. '<w:r><w:t>Table of contents: update fields (Word: select all, then F9) to show the page numbers.</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
  return out
end

function Pandoc(doc)
  local meta = doc.meta

  -- ---- metadata checks (loud failure beats silent omission) ----
  for _, k in ipairs({ "docket", "argument", "caption", "brief_title", "counsel", "attorneys_for",
                       "date_completed", "signature", "related_litigation" }) do
    need(meta, k)
  end
  local authorities = meta.authorities or {}

  -- ---- citations: `[text](toa:key)` keeps its text; the key must be in the authorities registry ----
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if authorities[key] == nil then
        error("ny-opening: link `toa:" .. key .. "` has no entry under `authorities:`", 0)
      end
      used[key] = true
      return el.content
    end,
  })

  -- ---- split off the addendum ----
  local main, addendum = {}, nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and pandoc.utils.stringify(b.content):lower():match("^addendum%s*$") then
      addendum = { table.unpack(doc.blocks, i + 1) }
      break
    end
    main[#main + 1] = b
  end

  -- ---- word limit (500.13(c)(1)) ----
  local words = source_words()
  if words > WORD_LIMIT then
    error("ny-opening: the brief has " .. words .. " words; 22 NYCRR 500.13(c)(1) allows " .. WORD_LIMIT, 0)
  end

  -- ---- point headings: typst numbering, as text (level 1 resets the lower levels) ----
  local counters = { 0, 0, 0, 0, 0, 0 }
  for _, b in ipairs(main) do
    if b.t == "Header" then
      counters[b.level] = counters[b.level] + 1
      for k = b.level + 1, 5 do counters[k] = 0 end
      if b.level >= 2 and b.level <= 5 then
        local label = heading_label(b.level, counters)
        local nc = { pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        for _, i in ipairs(b.content) do nc[#nc + 1] = i end
        b.content = pandoc.Inlines(nc)
      end
    end
  end

  -- ---- the last paragraph and the signature block stay together ----
  local last = main[#main]
  if last and last.t == "Para" then
    main[#main] = styled("KeepWithNext", last.content)
  end

  -- ---- assemble ----
  local out = {}
  local function add_all(list) for _, b in ipairs(list) do out[#out + 1] = b end end

  add_all(cover(meta))

  -- front matter (lower roman): disclosure, related litigation, contents, authorities
  if meta.disclosure then
    out[#out + 1] = styled("FrontHeading", { pandoc.Str("Disclosure Statement Pursuant to Section 500.1(f) of the Rules of the Court of Appeals") })
    add_all(blocks(meta.disclosure))
  end
  out[#out + 1] = styled("FrontHeading", { pandoc.Str("Statement of Related Litigation") })
  out[#out + 1] = pandoc.Para(inl(meta.related_litigation))
  add_all(table_of_contents())
  add_all(table_of_authorities(authorities, used))
  out[#out + 1] = section_end("rId101", "lowerRoman", 1)

  -- body (arabic from 1)
  add_all(main)
  add_all(signature_block(meta, true))
  add_all(certificate_of_compliance(meta, words))
  add_all(affidavit_of_service())

  -- addendum (500.1(h)): its own section after the body, page numbers from 1
  if addendum then
    out[#out + 1] = section_end("rId101", "decimal", 1)
    out[#out + 1] = pandoc.Header(1, { pandoc.Str("Addendum") })
    add_all(addendum)
  end

  doc.blocks = out
  -- no title block: the cover is the first page; metadata is not printed by the writer
  doc.meta = pandoc.Meta({})
  return doc
end
