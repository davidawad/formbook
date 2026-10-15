-- FISCR amicus brief, DOCX engine (docs/DOCX.md): the markdown contract (../README.md) -> a Word document on
-- docx/reference.docx. Mirrors typst/fiscr-amicus-brief.typ: cover (unnumbered), front matter (statement
-- regarding oral argument, question presented, table of contents, table of authorities, identity and interest;
-- roman from ii), body (arabic from 1), then the signature and certificates (numbering continues).
-- Sections are written as openxml section breaks. Headings are paragraphs in the custom styles of reference.docx.
--
-- Page numbers of the table of contents and table of authorities are not computed by Word or LibreOffice at
-- conversion time. docx/render.sh renders a first pass, docx/pages.sh finds the pages of each heading and each
-- authority in that PDF, and this filter is run again with FISCR_PAGES set to that answer (see render.sh).
-- FISCR_KEYS (when set) receives the search keys that pages.sh needs. On the first pass the page numbers are "0".
--
-- Not built here (the filter stops with an error, so nothing is silently dropped): an addendum and a corporate
-- disclosure statement. The typst template builds both.

local COURT_NAME = "United States Foreign Intelligence Surveillance Court of Review"  -- FRAP 32(a)(2)(B) via R. 15(d)(2)
local WORD_LIMIT_APPOINTED = 13000  -- FRAP 32(a)(7)(B)(i), applied to a court-appointed amicus by FISCR R. 15(d)(2)
local WORD_LIMIT_OTHER = 6500       -- FRAP 29(a)(5)
local PASSIM_AT = 7                 -- an authority on this many pages or more is "passim"
local KEY_LEN = 30                  -- characters of a heading or citation used to find it in the PDF

local function env(name)
  local v = os.getenv(name)
  if v == nil or v == "" then return nil end
  return v
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- whitespace (and no-break spaces) removed, lower case: the form in which pages.sh compares text
local function norm(s)
  s = s:gsub("\194\160", "")
  s = s:gsub("%s+", "")
  s = s:gsub("%-", "")   -- hyphens: a line-end hyphen is not always kept in the PDF text
  return s:lower()
end

local function short_key(s)
  return norm(s):sub(1, KEY_LEN)
end

local function roman(n)
  local vals = { { 1000, "m" }, { 900, "cm" }, { 500, "d" }, { 400, "cd" }, { 100, "c" }, { 90, "xc" },
    { 50, "l" }, { 40, "xl" }, { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

-- a metadata value (string, inlines or blocks) as a list of inlines
local function to_inlines(v)
  if v == nil then return pandoc.List({}) end
  if type(v) == "string" then return pandoc.List({ pandoc.Str(v) }) end
  if v.t == "MetaInlines" then return pandoc.List(v) end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return pandoc.List({ pandoc.Str(plain(v)) })
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function raw(x) return pandoc.RawBlock("openxml", x) end
local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local LINE = pandoc.LineBreak()

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para(inls) return pandoc.Para(inls) end

-- upper case of the text (the table of contents lists level-1 titles in capitals; the page numbers stay as they are)
local function upper_inlines(inls)
  return pandoc.Inlines(inls):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

local function strs(text) return pandoc.Str(text) end

-- section break: the paragraph carries the sectPr of the section that ends here
local function section_break(footer_rid, numbering)
  return raw('<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="' .. footer_rid
    .. '"/><w:type w:val="nextPage"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" '
    .. 'w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>' .. (numbering or "")
    .. '</w:sectPr></w:pPr></w:p>')
end
local FOOTER_EMPTY = "rId101"   -- footer2.xml, the cover
local FOOTER_PAGE = "rId100"    -- footer1.xml, the centred PAGE field
local ROMAN_FROM_II = '<w:pgNumType w:fmt="lowerRoman" w:start="2"/>'
local ARABIC_FROM_1 = '<w:pgNumType w:fmt="decimal" w:start="1"/>'

local function rule_double() return raw('<w:p><w:pPr><w:pStyle w:val="DoubleRule"/></w:pPr></w:p>') end
local function rule_short() return raw('<w:p><w:pPr><w:pStyle w:val="ShortRule"/></w:pPr></w:p>') end
local function sig_space() return raw('<w:p><w:pPr><w:pStyle w:val="SigLine"/></w:pPr></w:p>') end

-- ---------------------------------------------------------------------------
-- Source checks (the markdown source; the same counting rules as typst's count-words)
-- ---------------------------------------------------------------------------

-- word count of the markdown source, as typst counts it: frontmatter and the statement regarding oral
-- argument excluded (FRAP 32(f)); markup removed first; links keep their text
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("fiscr-amicus.lua: no input file name for the word count", 0) end
  local h = io.open(f, "r")
  if not h then error("fiscr-amicus.lua: cannot read " .. f, 0) end
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

-- the level-1 section whose heading matches pat (lower case); its blocks without the heading
local function take(blocks, pat)
  local rest, sec, active = {}, nil, false
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      active = false
      if not sec and plain(b.content):lower():match(pat) then
        sec = { title = b.content, blocks = {} }
        active = true
      end
    end
    if active then
      table.insert(sec.blocks, b)
    else
      table.insert(rest, b)
    end
  end
  if sec then table.remove(sec.blocks, 1) end  -- the heading itself
  return sec, rest
end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2) as applied by FISCR R. 15(d)(2)); same lines and order as the typst cover
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function line(inls, bold)
    local l = to_inlines(inls)
    if bold then l = pandoc.List({ pandoc.Strong(l) }) end
    add(styled("CoverLine", { para(l) }))
  end
  line(pandoc.List({ strs("Docket No. " .. plain(meta.case_number)) }), true)
  add(rule_double())
  line(pandoc.List({ strs("In the") }))
  line(pandoc.List({ strs(COURT_NAME:upper()) }), true)
  add(rule_short())
  local sides = meta.caption
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do line(n) end
    if side.designation and plain(side.designation) ~= "" then line(side.designation) end
    if i < #sides then line(pandoc.List({ strs("v.") })) end
  end
  add(rule_short())
  line(meta.proceeding)
  if meta.district_court_case then
    local d = pandoc.List({ strs("D.C. No. ") })
    d:extend(to_inlines(meta.district_court_case))
    if meta.judge then
      d:insert(strs("; "))
      d:extend(to_inlines(meta.judge))
    end
    line(d)
  end
  add(rule_short())
  line(pandoc.List({ strs(plain(meta.brief_title):upper()) }), true)
  add(rule_short())
  -- counsel: name, office address; the telephone number after the last group (as the typst cover)
  local groups = meta.counsel
  for gi, g in ipairs(groups) do
    local l = pandoc.List({})
    for _, n in ipairs(g.names) do
      l:extend(to_inlines(n))
      l:insert(LINE)
    end
    local lines = {}
    if g.lines then for _, x in ipairs(g.lines) do lines[#lines + 1] = x end end
    if gi == #groups and meta.phone then lines[#lines + 1] = meta.phone end
    for _, x in ipairs(lines) do
      l:insert(strs(""))
      l:insert(pandoc.Emph(to_inlines(x)))
      l:insert(LINE)
    end
    add(styled("Counsel", { para(l) }))
  end
  if meta.date then line(meta.date) end
  add(rule_double())
  add(section_break(FOOTER_EMPTY, nil))
  return out
end

-- ---------------------------------------------------------------------------
-- Body: headings, labels, table-of-contents entries
-- ---------------------------------------------------------------------------

-- Labels as the typst template prints them. In the Argument: I. / A. / 1.; elsewhere: A. / 1. / a.
local function label_for(level, n, in_arg)
  if in_arg then
    if level == 2 then return roman(n):upper() .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    return n .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  return string.char(96 + n) .. "."
end

local function body_transform(blocks, toc)
  local out = {}
  local in_arg = false
  local cnt = { 0, 0, 0, 0, 0 }
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        local t = plain(b.content):lower()
        in_arg = (t:match("^argument%s*$") ~= nil) or (t:match("^reply argument%s*$") ~= nil)
        cnt = { 0, 0, 0, 0, 0 }
        toc[#toc + 1] = { level = 1, label = "", inl = b.content, key = short_key(plain(b.content)) }
        out[#out + 1] = styled("SectionHeading", { para(b.content) })
      elseif b.level >= 2 and b.level <= 4 then
        for i = b.level + 1, 5 do cnt[i] = 0 end
        cnt[b.level] = cnt[b.level] + 1
        local lab = label_for(b.level, cnt[b.level], in_arg)
        toc[#toc + 1] = { level = b.level, label = lab, inl = b.content, key = short_key(lab .. plain(b.content)) }
        if in_arg and b.level == 2 then
          local l = pandoc.List({ strs(lab), pandoc.Space() })
          l:extend(b.content)
          out[#out + 1] = styled("PointHeading", { para(l) })
        else
          local l = pandoc.List({ strs(lab), TAB })
          l:extend(b.content)
          out[#out + 1] = styled("SubHeading", { para(l) })
        end
      else
        error("fiscr-amicus.lua: headings deeper than level 4 are not supported (heading: " .. plain(b.content) .. ")", 0)
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- page label of a pdf page: roman for the front matter (the cover is page 1), arabic from the body's first page
local function label_of(p, body_page)
  if p == nil or p == "?" or body_page == nil then return "?" end
  local n = tonumber(p)
  if n < body_page then return roman(n) end
  return tostring(n - body_page + 1)
end

-- the answers of docx/pages.sh: lines "B<TAB><TAB>page", "H<TAB>t<i><TAB>page", "A<TAB><id><TAB>p1,p2"
local function read_pages(path)
  if not path then return nil end
  local f = io.open(path, "r")
  if not f then error("fiscr-amicus.lua: cannot read the page map " .. path, 0) end
  local r = { H = {}, A = {}, B = nil }
  for line in f:lines() do
    local kind, id, val = line:match("^(%a)\t([^\t]*)\t(.*)$")
    if kind == "B" then r.B = (val ~= "?") and tonumber(val) or nil
    elseif kind == "H" then r.H[id] = val
    elseif kind == "A" then r.A[id] = val
    end
  end
  f:close()
  return r
end

local function toc_page(pages, i)
  if not pages then return "0" end
  return label_of(pages.H["t" .. i], pages.B)
end


local function toc_section(entries, pages)
  local out = {}
  out[#out + 1] = styled("SectionHeadingBreak", { para({ strs("Table of Contents") }) })
  out[#out + 1] = styled("TOCHead", { para({ pandoc.Underline({ strs("Page") }) }) })
  for i, e in ipairs(entries) do
    local page = toc_page(pages, i)
    if e.level == 1 then
      local l = pandoc.List({})
      l:extend(upper_inlines(e.inl))
      l:insert(TAB)
      l:insert(strs(page))
      out[#out + 1] = styled("TOC1", { para(l) })
    else
      local l = pandoc.List({ strs(e.label), TAB })
      l:extend(e.inl)
      l:insert(TAB)
      l:insert(strs(page))
      out[#out + 1] = styled(e.level == 2 and "TOC2" or "TOC3", { para(l) })
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Table of authorities (typst: the authorities linked from the body, by kind, sorted)
-- ---------------------------------------------------------------------------

local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local function toa_section(auth, used, pages)
  local out = {}
  out[#out + 1] = styled("SectionHeadingBreak", { para({ strs("Table of Authorities") }) })
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local function sk(k)
          local a = auth[k]
          if a.sort then return plain(a.sort):lower() end
          return (plain(a.name) .. " " .. plain(a.cite)):lower()
        end
        return sk(x) < sk(y)
      end)
      local head = pandoc.List({ strs(g[2]) })
      if first then
        head:insert(TAB)
        head:insert(pandoc.Strong({ pandoc.Underline({ strs("Page(s)") }) }))
      end
      out[#out + 1] = styled("TOAGroup", { para(head) })
      first = false
      for _, key in ipairs(members) do
        local a = auth[key]
        local l = pandoc.List({})
        if a.name then
          local nm = to_inlines(a.name)
          if g[1] == "case" then nm = pandoc.List({ pandoc.Emph(nm) }) end
          l:extend(nm)
          l:insert(strs(","))
          l:insert(LINE)
        end
        l:extend(to_inlines(a.cite))
        l:insert(TAB)
        local labels = {}
        if not pages then
          labels = { "0" }
        elseif pages.A[key] then
          for p in pages.A[key]:gmatch("[^,]+") do
            local lab = label_of(p, pages.B)
            local seen = false
            for _, x in ipairs(labels) do
              if x == lab then seen = true end
            end
            if not seen then labels[#labels + 1] = lab end
          end
        else
          labels = { "?" }
        end
        if #labels >= PASSIM_AT then
          l:insert(pandoc.Emph({ strs("passim") }))
        else
          l:insert(strs(table.concat(labels, ", ")))
        end
        out[#out + 1] = styled("TOAEntry", { para(l) })
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature and certificates (FRAP 32(g)(1), Form 6; FISCR R. 14(a)(10) via R. 15(d)(1); R. 10(c))
-- ---------------------------------------------------------------------------

local function signature(meta, keep)
  local sig = meta.signature
  local out = {}
  out[#out + 1] = styled(keep and "SigBlockKeep" or "Counsel", { para({ strs("Respectfully submitted,") }) })
  out[#out + 1] = sig_space()
  local l = pandoc.List({ strs(plain(sig.signer)) })
  for _, x in ipairs(sig.lines or {}) do
    l:insert(LINE)
    l:insert(pandoc.Emph(to_inlines(x)))
  end
  out[#out + 1] = styled("Counsel", { para(l) })
  if meta.date then out[#out + 1] = styled("Single", { para(to_inlines(meta.date)) }) end
  return out
end

local function form_signature(meta)
  local sig = meta.signature
  local out = { sig_space() }
  local l = pandoc.List({ strs(plain(sig.signer)), LINE })
  if sig["for"] then
    l:extend(to_inlines(sig["for"]))
    l:insert(LINE)
  end
  if meta.date then
    l:insert(strs("Dated: "))
    l:extend(to_inlines(meta.date))
  end
  out[#out + 1] = styled("Counsel", { para(l) })
  return out
end

local function certificates(meta, words, limit_cite)
  local out = {}
  out[#out + 1] = styled("SectionHeading", { para({ strs("Certificate of Compliance") }) })
  out[#out + 1] = styled("Single", { para({ strs("Pursuant to FISC Ct. Rev. R. P. 15(d)(1)-(2), the undersigned certifies that this brief complies with the content requirements of FISC Ct. Rev. R. P. 14(a)(2)-(8) and (10), with the exceptions in FISC Ct. Rev. R. P. 15(d)(1)(A)-(C), and with the type-volume limit of " .. limit_cite .. ". Excluding the parts of the brief exempted by Fed. R. App. P. 32(f):") }) })
  out[#out + 1] = styled("CheckLine", { para({ strs("[X]"), strs(" this brief contains " .. group_digits(words) .. " words.") }) })
  out[#out + 1] = styled("Single", { para({ strs("The undersigned relied upon the word count of the word-processing system used to prepare this brief, as Fed. R. App. P. 32(g)(1) permits.") }) })
  local typeface = pandoc.List({ strs("this brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6): it has been prepared in a proportionally spaced typeface using ") })
  typeface:extend(to_inlines(meta.word_processor))
  typeface:extend({ strs(" in 14-point ") })
  typeface:extend(to_inlines(meta.typeface))
  typeface:extend({ strs(" roman type.") })
  local check = pandoc.List({ strs("[X]"), strs(" ") })
  check:extend(typeface)
  out[#out + 1] = styled("CheckLine", { para(check) })
  for _, b in ipairs(form_signature(meta)) do out[#out + 1] = b end

  local s = meta.service
  if s and s.certificate then
    out[#out + 1] = styled("SectionHeadingBreak", { para({ strs("Certificate of Service") }) })
    local t = pandoc.List({ strs("I hereby certify that on ") })
    t:extend(to_inlines(meta.date or "__________"))
    if s.time then
      t:insert(strs(" at "))
      t:extend(to_inlines(s.time))
    end
    t:insert(strs(", I "))
    t:extend(to_inlines(s.method))
    t:insert(strs("."))
    out[#out + 1] = styled("Single", { para(t) })
    for _, u in ipairs(s.recipients or {}) do
      local r = pandoc.List({})
      r:extend(to_inlines(u.name))
      r:insert(strs(", "))
      r:extend(to_inlines(u.address))
      out[#out + 1] = styled("Indent", { para(r) })
    end
    for _, b in ipairs(form_signature(meta)) do out[#out + 1] = b end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The brief
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc writes a title block (title, author, date) from the metadata at the top of a docx; the cover
  -- prints the date itself, so the metadata is taken away from pandoc here
  doc.meta = pandoc.Meta({})
  if meta.disclosure then
    error("fiscr-amicus.lua: a corporate disclosure statement is not built by the docx template (typst builds it)", 0)
  end
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "signature", "word_processor", "typeface", "court_appointed" }) do
    if meta[k] == nil then error("fiscr-amicus.lua: missing required metadata field `" .. k .. "`", 0) end
  end

  -- authorities: citation links (toa:key) take their text from the body; the page is found later
  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
    end
  end
  local used, link_keys = {}, {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("fiscr-amicus.lua: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      link_keys[key] = link_keys[key] or {}
      link_keys[key][short_key(plain(el.content))] = true
      return el.content
    end,
  })

  -- front sections, taken out by heading (their position is fixed below)
  local oa, rest = take(doc.blocks, "^statement regarding oral argument")
  local qp
  qp, rest = take(rest, "^question presented")
  local idn
  idn, rest = take(rest, "^identity and interest")
  for _, b in ipairs(rest) do
    if b.t == "Header" and b.level == 1 and plain(b.content):lower():match("^addendum%s*$") then
      error("fiscr-amicus.lua: an addendum is not built by the docx template (typst builds it)", 0)
    end
  end

  -- the sections the rules require, in order (FISCR R. 14(a)(6)-(8) as applied by R. 15(d)(1))
  local titles = {}
  for _, b in ipairs(rest) do
    if b.t == "Header" and b.level == 1 then titles[#titles + 1] = plain(b.content):lower() end
  end
  -- each entry: alternatives. "Introduction" is accepted as the statement of the case (README, Known gaps 2).
  local required = {
    { "^statement of the case$", "^statement of case$", "^introduction$" },
    { "^summary of the argument$", "^summary of argument$" },
    { "^argument$" },
  }
  local pos = 1
  for _, alts in ipairs(required) do
    local found = nil
    for i = pos, #titles do
      for _, pat in ipairs(alts) do
        if found == nil and titles[i]:match(pat) then found = i end
      end
      if found then break end
    end
    if not found then
      error("fiscr-amicus.lua: the brief needs a section titled `" .. alts[1] .. "` (in this order; FISCR R. 14(a), 15(d))", 0)
    end
    pos = found + 1
  end

  -- length (FRAP 32(a)(7) / 29(a)(5), with the 32(f) exclusions, as typst counts it)
  local words = source_words()
  local limit = meta.court_appointed and WORD_LIMIT_APPOINTED or WORD_LIMIT_OTHER
  if words > limit then
    error("fiscr-amicus.lua: the brief has " .. words .. " words; the limit is " .. limit, 0)
  end
  local limit_cite = meta.court_appointed and "Fed. R. App. P. 32(a)(7)(B) (FISC Ct. Rev. R. P. 15(d)(2))" or "Fed. R. App. P. 29(a)(5)"

  -- keys (for docx/pages.sh) and the page map of a previous pass
  local toc = {}
  if oa then toc[#toc + 1] = { level = 1, label = "", inl = oa.title, key = short_key(plain(oa.title)) } end
  if qp then toc[#toc + 1] = { level = 1, label = "", inl = qp.title, key = short_key(plain(qp.title)) } end
  if idn then toc[#toc + 1] = { level = 1, label = "", inl = idn.title, key = short_key(plain(idn.title)) } end

  -- the body's first paragraph is searched for, to find where the body starts
  local body_key = nil
  for _, b in ipairs(rest) do
    if b.t == "Para" then body_key = short_key(plain(b)) break end
  end
  if not body_key then error("fiscr-amicus.lua: the body has no paragraph", 0) end

  local body = body_transform(rest, toc)

  -- signature: the last body paragraph stays with it (KeepBody), as typst keeps the tail with the block
  local last = body[#body]
  if last and last.t == "Para" then
    body[#body] = styled("KeepBody", { last })
  end

  local pages = read_pages(env("FISCR_PAGES"))
  local pass_key_file = env("FISCR_KEYS")

  -- certificates are part of the TOC too
  local cert_blocks = certificates(meta, words, limit_cite)
  if meta.service and meta.service.certificate then
    toc[#toc + 1] = { level = 1, label = "", inl = pandoc.List({ strs("Certificate of Compliance") }), key = short_key("Certificate of Compliance") }
    toc[#toc + 1] = { level = 1, label = "", inl = pandoc.List({ strs("Certificate of Service") }), key = short_key("Certificate of Service") }
  else
    toc[#toc + 1] = { level = 1, label = "", inl = pandoc.List({ strs("Certificate of Compliance") }), key = short_key("Certificate of Compliance") }
  end

  if pass_key_file then
    local f = io.open(pass_key_file, "w")
    if not f then error("fiscr-amicus.lua: cannot write " .. pass_key_file, 0) end
    f:write(table.concat({ "B", "body", "S", body_key }, "\t"), "\n")
    f:write(table.concat({ "M", "toc", "L", "tableofcontents" }, "\t"), "\n")
    f:write(table.concat({ "M", "toa", "L", "tableofauthorities" }, "\t"), "\n")
    if idn then f:write(table.concat({ "M", "ident", "L", short_key(plain(idn.title)) }, "\t"), "\n") end
    for i, e in ipairs(toc) do
      f:write(table.concat({ "H", "t" .. i, "L", e.key }, "\t"), "\n")
    end
    for key in pairs(used) do
      for t in pairs(link_keys[key]) do
        f:write(table.concat({ "A", key, "S", t }, "\t"), "\n")
      end
    end
    f:close()
  end

  -- assemble
  local out = {}
  local function addall(bs) for _, b in ipairs(bs) do out[#out + 1] = b end end

  addall(cover(meta))

  if oa then
    out[#out + 1] = styled("SectionHeading", { para(oa.title) })
    addall(oa.blocks)
  end
  if qp then
    out[#out + 1] = styled("SectionHeadingBreak", { para(qp.title) })
    addall(qp.blocks)
  end
  addall(toc_section(toc, pages))
  addall(toa_section(auth, used, pages))
  if idn then
    out[#out + 1] = styled("SectionHeadingBreak", { para(idn.title) })
    addall(idn.blocks)
  end
  out[#out + 1] = section_break(FOOTER_PAGE, ROMAN_FROM_II)

  addall(body)
  addall(signature(meta, true))
  out[#out + 1] = section_break(FOOTER_PAGE, ARABIC_FROM_1)
  addall(cert_blocks)
  -- the final section (the certificates) continues the arabic numbering of the body

  doc.blocks = out
  return doc
end
