-- cafc-docx.lua: pandoc filter for the cafc .docx engine (docx/render.sh). It lays out the brief the way the typst
-- template does: cover, front matter (roman), body (arabic), addendum (Add-), certificates (arabic, continuing).
-- The styles come from docx/reference.docx (made from docx/styles.xml.in by docx/make-reference.sh).
--
-- Page numbers in the contents and the table of authorities are not known to pandoc. render.sh runs the build
-- more than once: a run writes CAFC_PATTERNS (what to look for, and where), LibreOffice renders the .docx, pages.sh
-- finds the page labels, and the next run reads them from CAFC_PAGES. The first run writes placeholders.
--
-- Metadata: label_scheme = opening | answering | reply (passed by render.sh): the numbering of the headings.

local SCHEME = "opening"
local DATE = nil -- the brief's date (frontmatter), kept out of the metadata pandoc prints

-- ---------------------------------------------------------------------------
-- Inputs written by render.sh between runs
-- ---------------------------------------------------------------------------

local PAGES = {}
do
  local path = os.getenv("CAFC_PAGES")
  local f = path and io.open(path, "r")
  if f then
    for line in f:lines() do
      local id, val = line:match("^([^\t]+)\t(.*)$")
      if id then
        PAGES[id] = val
      end
    end
    f:close()
  end
end

local function pg(id)
  return PAGES[id] or "00"
end

local PATTERNS = {} -- lines "mode area id needle" for pages.sh

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function text(x)
  return pandoc.utils.stringify(x)
end

-- Upper case (ASCII), single spaces: the form pages.sh compares (it runs in the C locale).
local function norm(s)
  s = s:gsub("\194\160", " ")
  s = s:gsub("%s+", " ")
  s = s:gsub("^ ", ""):gsub(" $", "")
  return s:upper()
end

local function need_pattern(mode, area, id, needle)
  PATTERNS[#PATTERNS + 1] = mode .. "\t" .. area .. "\t" .. id .. "\t" .. norm(needle)
end

-- Inlines of a metadata value, emphasis kept (YAML strings are read as markdown by pandoc).
local function inlines_of(v)
  if v == nil then
    return {}
  end
  if v.t == "MetaInlines" then
    return v
  elseif v.t == "MetaString" then
    return { pandoc.Str(v) }
  elseif v.t == "MetaBlocks" then
    local out = {}
    for _, b in ipairs(v) do
      if b.content then
        for _, x in ipairs(b.content) do
          out[#out + 1] = x
        end
      end
    end
    return out
  end
  return { pandoc.Str(text(v)) }
end

local function append(list, more)
  for _, x in ipairs(more) do
    list[#list + 1] = x
  end
  return list
end

-- A paragraph in one of the court's styles (docx/styles.xml.in).
local function P(style, inls)
  return pandoc.Div({ pandoc.Para(inls) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw(x)
  return pandoc.RawBlock("openxml", x)
end

local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

-- A box for the type-volume certificate (drawn with a glyph from the vendored DejaVu Sans).
local function checkbox(checked)
  local ch = checked and "\226\152\146" or "\226\152\144" -- U+2612 BALLOT BOX WITH X, U+2610 BALLOT BOX
  return pandoc.RawInline("openxml", '<w:r><w:rPr><w:rFonts w:ascii="DejaVu Sans" w:hAnsi="DejaVu Sans"/></w:rPr><w:t>' .. ch .. "</w:t></w:r>")
end

-- Vertical space: one empty line of exact height, in twentieths of a point.
local function gap(twips)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

-- The same, kept with the next paragraph: the spacing inside a signature block (the block stays on one page).
local function gapk(twips)
  return raw('<w:p><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

-- Cover rules: a double rule, a single rule (full width), or a short rule (2 in, centered).
local function rule(kind)
  local ind = ""
  local border = '<w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/>'
  if kind == "double" then
    border = '<w:bottom w:val="double" w:sz="6" w:space="1" w:color="000000"/>'
  elseif kind == "short" then
    ind = '<w:ind w:left="3240" w:right="3240"/>'
  end
  return raw('<w:p><w:pPr><w:pBdr>' .. border .. '</w:pBdr><w:spacing w:before="0" w:after="0" w:line="200" w:lineRule="exact"/>' .. ind .. "</w:pPr></w:p>")
end

local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="0" w:footer="576" w:gutter="0"/>'

-- The section break that ends a section: its footer part (nil: none), its page number format and start.
local function section_end(footer_rid, fmt, start)
  local x = "<w:sectPr>"
  if footer_rid then
    x = x .. '<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>'
  end
  x = x .. '<w:type w:val="nextPage"/>' .. PG
  if fmt then
    x = x .. '<w:pgNumType w:fmt="' .. fmt .. '"' .. (start and (' w:start="' .. start .. '"') or "") .. "/>"
  end
  x = x .. "</w:sectPr>"
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. x .. "</w:pPr></w:p>")
end

local function page_break()
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="200" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function heading_1(inls)
  return pandoc.Header(1, inls)
end

-- ---------------------------------------------------------------------------
-- Headings: labels as the typst template numbers them (heading-label)
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { 1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1 }
  local syms = { "m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i" }
  local s = ""
  for i, v in ipairs(vals) do
    while n >= v do
      s = s .. syms[i]
      n = n - v
    end
  end
  return s
end

local function letter(n)
  return string.char(64 + n)
end

local function alpha(n)
  return string.char(96 + n)
end

-- The printed label of a heading of `level` (1 to 5) with the running counters `c`.
local function label_of(level, c, in_arg)
  if SCHEME == "opening" then
    if in_arg then
      if level == 2 then return roman(c[2]):upper() .. "." end
      if level == 3 then return letter(c[3]) .. "." end
      if level == 4 then return tostring(c[4]) .. "." end
      if level == 5 then return alpha(c[5]) .. "." end
    else
      if level == 2 then return letter(c[2]) .. "." end
      if level == 3 then return tostring(c[3]) .. "." end
      if level == 4 then return alpha(c[4]) .. "." end
      if level == 5 then return "(" .. c[5] .. ")" end
    end
    return nil
  end
  if level == 1 then return roman(c[1]):upper() .. "." end
  if level == 2 then return letter(c[2]) .. "." end
  if SCHEME == "reply" then
    if level == 3 then return roman(c[3]):lower() .. "." end
    if level == 4 then return tostring(c[4]) .. "." end
    if level == 5 then return alpha(c[5]) .. "." end
  else
    if level == 3 then return tostring(c[3]) .. "." end
    if level == 4 then return alpha(c[4]) .. "." end
    if level == 5 then return "(" .. c[5] .. ")" end
  end
  return nil
end

-- ---------------------------------------------------------------------------
-- Citations: a toa: link is plain text here; its shown text is what the page search looks for
-- ---------------------------------------------------------------------------

local cited, seen = {}, {}

local function link_filter(el)
  local key = el.target:match("^toa:(.+)$")
  if not key then
    return nil
  end
  if not seen[key] then
    seen[key] = true
    cited[#cited + 1] = key
  end
  PATTERNS[#PATTERNS + 1] = "all\tbody\tt:" .. key .. "\t" .. norm(text(el.content))
  return pandoc.Span(el.content)
end

local groups = {
  { kind = "case", title = "Cases:" },
  { kind = "constitution", title = "Constitutional Provisions:" },
  { kind = "statute", title = "Statutes:" },
  { kind = "regulation", title = "Regulations:" },
  { kind = "rule", title = "Rules:" },
  { kind = "other", title = "Other Authorities:" },
}

local function sort_key(a)
  local s = a.sort and text(a.sort) or (text(a.name or "") .. " " .. text(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

-- The table of authorities: each group's title, then each cited authority: name, cite, dot leader, pages.
local function toa_blocks(authorities)
  local out = {}
  local first = true
  for _, g in ipairs(groups) do
    local members = {}
    for _, key in ipairs(cited) do
      local a = authorities[key]
      if a and text(a.kind) == g.kind then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(p, q)
        if p.sort == q.sort then
          return p.key < q.key
        end
        return p.sort < q.sort
      end)
      local head = { pandoc.Str(g.title) }
      if first then
        head[#head + 1] = tab()
        head[#head + 1] = pandoc.Strong({ pandoc.Str("Page(s)") })
      end
      first = false
      out[#out + 1] = P("Authority Group", head)
      for _, m in ipairs(members) do
        local a = m.a
        local line = {}
        if a.name then
          local nm = inlines_of(a.name)
          if g.kind == "case" then
            line[#line + 1] = pandoc.Emph(nm)
          else
            append(line, nm)
          end
          line[#line + 1] = pandoc.Str(",")
          line[#line + 1] = pandoc.LineBreak()
        end
        append(line, inlines_of(a.cite))
        line[#line + 1] = tab()
        line[#line + 1] = pandoc.Str(pg("t:" .. m.key))
        out[#out + 1] = P("Authority Entry", line)
        need_pattern("all", "body", "t:" .. m.key, text(a.cite))
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

-- The counsel of the reply brief: two columns to a row, as the typst grid sets them (plain text, no emphasis).
local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function counsel_cell(g)
  local x = '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/></w:tcPr>'
  local lines = {}
  for _, nm in ipairs(g.names or {}) do
    lines[#lines + 1] = text(nm)
  end
  for _, l in ipairs(g.lines or {}) do
    lines[#lines + 1] = text(l)
  end
  for _, s in ipairs(lines) do
    x = x .. '<w:p><w:pPr><w:pStyle w:val="CounselBlock"/><w:ind w:left="0"/></w:pPr><w:r><w:t xml:space="preserve">' .. xesc(s) .. "</w:t></w:r></w:p>"
  end
  if #lines == 0 then
    x = x .. '<w:p/>'
  end
  return x .. "</w:tc>"
end

local function counsel_table(groups)
  local rows = {}
  for i = 1, #groups, 2 do
    local cells = counsel_cell(groups[i])
    if groups[i + 1] then
      cells = cells .. counsel_cell(groups[i + 1])
    else
      cells = cells .. '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
    end
    rows[#rows + 1] = "<w:tr>" .. cells .. "</w:tr>"
  end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="144" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="4680"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>")
end

local function cover(meta)
  local out = {}
  local CG = SCHEME == "opening" and 200 or 60 -- the answering and reply covers are tighter (one page each)
  local function add(b)
    out[#out + 1] = b
  end
  local court = "UNITED STATES COURT OF APPEALS FOR THE FEDERAL CIRCUIT"
  add(gap(CG))
  local number = { pandoc.Str(SCHEME == "reply" and "No. " or ""), table.unpack(inlines_of(meta.case_number)) }
  add(P("Cover Line", { pandoc.Strong(number) }))
  add(gap(CG))
  add(rule("double"))
  add(gap(CG))
  add(P("Cover Line", { pandoc.Strong({ pandoc.Str(court) }) }))
  add(gap(CG))
  add(rule("short"))
  add(gap(CG))
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for _, nm in ipairs(side.names or {}) do
      add(P("Cover Line", inlines_of(nm)))
    end
    add(P("Caption Side", inlines_of(side.designation)))
    if i < #sides then
      add(P("Cover Line", { pandoc.Str("v.") }))
    end
    add(gap(CG))
  end
  add(rule("short"))
  add(gap(CG))
  add(P("Cover Line", inlines_of(meta.proceeding)))
  add(gap(CG))
  add(rule("short"))
  add(gap(CG))
  add(P("Cover Line", { pandoc.Strong({ pandoc.Str(norm(text(meta.brief_title))) }) }))
  add(gap(CG))
  add(rule("short"))
  add(gap(CG))
  local groups_c = meta.counsel or {}
  if SCHEME == "reply" then
    add(counsel_table(groups_c))
    groups_c = {}
  end
  for gi, g in ipairs(groups_c) do
    for _, nm in ipairs(g.names or {}) do
      add(P("Counsel Block", inlines_of(nm)))
    end
    for _, l in ipairs(g.lines or {}) do
      add(P("Counsel Block", SCHEME == "opening" and { pandoc.Emph(inlines_of(l)) } or inlines_of(l)))
    end
    if gi == #groups_c and meta.phone and SCHEME ~= "reply" then
      add(P("Counsel Block", { pandoc.Emph(inlines_of(meta.phone)) }))
    end
    add(gap(CG))
  end
  if meta.counsel_for then
    add(gap(CG))
    add(P("Cover Line", inlines_of(meta.counsel_for)))
  end
  if DATE and SCHEME == "answering" then
    add(gap(CG))
    add(P("Counsel Block", inlines_of(DATE)))
  end
  add(gap(CG))
  add(rule("double"))
  return out
end

-- ---------------------------------------------------------------------------
-- Signatures and certificates
-- ---------------------------------------------------------------------------

-- "/s/ NAME", the name in capitals, the signer's lines. `certificate` picks the certificate's lines.
local function signer_lines(sig, lines, out)
  out[#out + 1] = P("Signature Block", { pandoc.Str("/s/ " .. text(sig.signer or "")) })
  out[#out + 1] = P("Signature Block", { pandoc.Str(norm(text(sig.signer or ""))) })
  for _, l in ipairs(lines) do
    out[#out + 1] = P("Signature Block", inlines_of(l))
  end
  return out
end

-- "Is/ NAME", the name in capitals, the date (the form of a certificate filed by counsel).
local function certificate_signature(meta)
  local out = {}
  local sig = meta.signature or {}
  out[#out + 1] = gapk(280)
  out[#out + 1] = P("Signature Block", { pandoc.Str("Is/ " .. text(sig.signer or "")) })
  out[#out + 1] = P("Signature Block", { pandoc.Str(norm(text(sig.signer or ""))) })
  if DATE then
    out[#out + 1] = gap(200)
    out[#out + 1] = P("Signature Block", inlines_of(DATE))
  end
  return out
end

-- Words of the brief body (footnotes included, the addendum and the certificates excluded), for the certificate.
local function count_words(blocks)
  local n = 0
  local function words(s)
    for _ in s:gsub("\194\160", " "):gmatch("%S+") do
      n = n + 1
    end
  end
  for _, b in ipairs(blocks) do
    words(text(b))
    pandoc.Pandoc({ b }):walk({
      Note = function(note)
        words(text(note.content))
      end,
    })
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Meta(meta)
  if meta.label_scheme then
    SCHEME = text(meta.label_scheme)
  end
  -- pandoc would print the date as a title block at the top of the document: the date is set by the brief itself
  DATE = meta.date
  meta.date = nil
  return meta
end

function Pandoc(doc)
  local meta = doc.meta
  local body, add = {}, {}
  local in_add = false
  for _, b in ipairs(doc.blocks) do
    if not in_add and b.t == "Header" and b.level == 1 and text(b.content):lower() == "addendum" then
      in_add = true
    elseif in_add then
      add[#add + 1] = b
    else
      body[#body + 1] = b
    end
  end
  local authorities = meta.authorities or {}
  local has_interest = meta.interest ~= nil
  local has_addendum = #add > 0
  local sig = meta.signature or {}
  local words = count_words(body)

  -- ---- the body: labels, contents entries, the body blocks ----
  local c = { 0, 0, 0, 0, 0 }
  local in_arg = false
  local contents = {}
  local body_blocks = {}
  local bd = pandoc.Pandoc(body):walk({ Link = link_filter })

  for _, b in ipairs(bd.blocks) do
    if b.t == "Header" then
      local level = b.level
      local title = text(b.content):lower()
      if level == 1 then
        for k = 2, 5 do
          c[k] = 0
        end
        in_arg = (title == "argument")
      end
      local label = nil
      if not (level == 1 and SCHEME == "opening") then
        c[level] = c[level] + 1
        for k = level + 1, 5 do
          c[k] = 0
        end
        label = label_of(level, c, in_arg)
      end
      local id = "h:" .. (#contents + 1)
      need_pattern("line", "body", id, text(b.content))
      if level <= 4 then
        contents[#contents + 1] = { level = level, label = label, title = b.content, id = id }
      end
      if SCHEME == "opening" and level == 2 and in_arg then
        -- a point heading of the Argument: centered, bold small capitals, its label before the title
        body_blocks[#body_blocks + 1] = P("Point Heading", append({ pandoc.Str(label), pandoc.Space() }, b.content))
      elseif level == 1 and SCHEME == "answering" then
        body_blocks[#body_blocks + 1] = P("Section Hang", append({ pandoc.Str(label), tab() }, b.content))
      elseif level == 1 and SCHEME == "reply" then
        body_blocks[#body_blocks + 1] = heading_1(append({ pandoc.Str(label), pandoc.Space() }, b.content))
      elseif level == 1 then
        body_blocks[#body_blocks + 1] = heading_1(b.content)
      else
        local inl = {}
        if label then
          inl[#inl + 1] = pandoc.Str(label)
          inl[#inl + 1] = tab()
        end
        body_blocks[#body_blocks + 1] = pandoc.Header(level, append(inl, b.content))
      end
    else
      body_blocks[#body_blocks + 1] = b
    end
  end

  -- ---- front matter (roman): certificate of interest (opening brief) ----
  local front = {}
  if has_interest then
    local ci = meta.interest
    front[#front + 1] = heading_1({ pandoc.Str("Certificate of Interest") })
    need_pattern("top", "front", "f:interest", "CERTIFICATE OF INTEREST")
    front[#front + 1] = P("Certificate Text", append({ pandoc.Str("Counsel for ") }, append(inlines_of(ci["for"]), { pandoc.Str(" certifies the following:") })))
    local items = {
      { pandoc.Str("The full name of every party or amicus represented by me is: ") }, ci.represented,
      { pandoc.Str("The name of the real party in interest represented by me is: ") }, ci.real_party,
      { pandoc.Str("All parent corporations and any publicly held companies that own 10 percent of the stock of a party or amicus curiae represented by me are: ") }, ci.parents,
      { pandoc.Str("The names of all law firms and the partners and associates that (a) appeared for the entities in the originating court or agency or (b) are expected to appear in this court for the entities not including those who have already entered an appearance in this court: ") }, ci.other_counsel,
    }
    local n = 0
    local i = 1
    while i <= #items do
      n = n + 1
      local lead = items[i]
      local val = items[i + 1]
      local inl = { pandoc.Str(n .. "."), tab() }
      append(inl, lead)
      append(inl, inlines_of(val))
      inl[#inl + 1] = pandoc.Str(".")
      front[#front + 1] = P("Numbered Item", inl)
      i = i + 2
    end
    local five
    if meta.related_cases and meta.related_cases.cases then
      five = { pandoc.Str("Related or prior cases meeting the criteria under Fed. Cir. R. 47.5(a) are listed in the Statement of Related Cases.") }
    else
      five = { pandoc.Str("I am unaware of any cases pending in this or any other court or agency that meet the criteria under Fed. Cir. R. 47.5(a). I am unaware of any cases pending that will directly affect or be directly affected by this court's decision in the pending appeal.") }
    end
    front[#front + 1] = P("Numbered Item", append({ pandoc.Str("5."), tab() }, five))
    append(front, certificate_signature(meta))
    front[#front + 1] = page_break()
  end

  -- ---- contents ----
  local toc = {}
  toc[#toc + 1] = heading_1({ pandoc.Str("Table of Contents") })
  toc[#toc + 1] = P("Contents Head", { pandoc.Str("Page") })
  local function entry(level, label, title, id)
    local ln = {}
    if label then
      ln[#ln + 1] = pandoc.Str(label)
      ln[#ln + 1] = tab()
    end
    append(ln, title)
    ln[#ln + 1] = tab()
    ln[#ln + 1] = pandoc.Str(pg(id))
    return P("Contents Level " .. level, ln)
  end
  -- the front matter is listed in the contents of the opening brief only (the typst template lists it there)
  if has_interest then
    toc[#toc + 1] = entry(1, nil, { pandoc.Str("CERTIFICATE OF INTEREST") }, "f:interest")
    toc[#toc + 1] = entry(1, nil, { pandoc.Str("TABLE OF CONTENTS") }, "f:contents")
    toc[#toc + 1] = entry(1, nil, { pandoc.Str("TABLE OF AUTHORITIES") }, "f:authorities")
    need_pattern("top", "front", "f:contents", "TABLE OF CONTENTS")
    need_pattern("top", "front", "f:authorities", "TABLE OF AUTHORITIES")
  end
  if has_interest and meta.related_cases then
    toc[#toc + 1] = entry(1, nil, { pandoc.Str("STATEMENT OF RELATED CASES") }, "f:related")
    need_pattern("top", "front", "f:related", "STATEMENT OF RELATED CASES")
  end
  for _, e in ipairs(contents) do
    local title = e.title
    if e.level == 1 and SCHEME ~= "answering" then
      title = { pandoc.Str(norm(text(e.title))) }
    end
    toc[#toc + 1] = entry(e.level, e.label, title, e.id)
  end
  if has_addendum then
    toc[#toc + 1] = entry(1, nil, { pandoc.Str("ADDENDUM") }, "f:addendum")
    need_pattern("top", "add", "f:addendum", "ADDENDUM")
  end

  -- ---- table of authorities ----
  local toa = { heading_1({ pandoc.Str("Table of Authorities") }) }
  append(toa, toa_blocks(authorities))

  -- ---- related cases (opening: the statement; answering: the sample's own statement) ----
  local related = {}
  if meta.related_cases then
    related[#related + 1] = heading_1({ pandoc.Str("Statement of Related Cases") })
    need_pattern("top", "front", "f:related", "STATEMENT OF RELATED CASES")
    local who = inlines_of(meta.interest and meta.interest["for"] or {})
    related[#related + 1] = P("Certificate Text", append(append({ pandoc.Str("Pursuant to Federal Circuit Rules 28(a)(4) and 47.5, counsel for ") }, who), { pandoc.Str(" certifies:") }))
    if meta.related_cases.cases then
      for i, cs in ipairs(meta.related_cases.cases) do
        related[#related + 1] = P("Numbered Item", append({ pandoc.Str(i .. "."), tab() }, inlines_of(cs)))
      end
    else
      related[#related + 1] = P("Numbered Item", { pandoc.Str("1."), tab(), pandoc.Str("I am unaware of any other appeal in or from the same civil action or proceeding in the originating tribunal that was previously before this or any other appellate court.") })
      related[#related + 1] = P("Numbered Item", { pandoc.Str("2."), tab(), pandoc.Str("I am unaware of any case pending in this or any other tribunal that will directly affect or be directly affected by this court's decision in the pending case.") })
    end
    append(related, certificate_signature(meta))
  elseif meta.related_statement then
    related[#related + 1] = heading_1({ pandoc.Str("Statement of Related Cases") })
    need_pattern("top", "front", "f:related", "STATEMENT OF RELATED CASES")
    for _, p in ipairs(meta.related_statement) do
      related[#related + 1] = P("Body Text", inlines_of(p))
    end
  end

  -- ---- the signature after the body ----
  local closing = { gapk(280) }
  if SCHEME == "reply" then
    closing[#closing + 1] = P("Signature Block", append({ pandoc.Str("Dated: ") }, inlines_of(DATE)))
    closing[#closing + 1] = P("Signature Block", { pandoc.Str("Respectfully submitted,") })
    closing[#closing + 1] = gapk(340)
    closing[#closing + 1] = P("Signature Block", { pandoc.Str("/s/ " .. text(sig.signer or "")) })
    for _, l in ipairs(sig.lines or {}) do
      closing[#closing + 1] = P("Signature Block", inlines_of(l))
    end
    for _, o in ipairs(sig.also or {}) do
      closing[#closing + 1] = gapk(340)
      closing[#closing + 1] = P("Signature Block", inlines_of(o.name))
      for _, l in ipairs(o.lines or {}) do
        closing[#closing + 1] = P("Signature Block", inlines_of(l))
      end
    end
    closing[#closing + 1] = gapk(200)
    closing[#closing + 1] = P("Certificate Text", inlines_of(meta.counsel_for))
  elseif SCHEME == "answering" then
    if DATE then
      closing[#closing + 1] = P("Signature Block", append({ pandoc.Str("Dated: ") }, inlines_of(DATE)))
    end
    closing[#closing + 1] = P("Signature Block", { pandoc.Str("Respectfully submitted,") })
    closing[#closing + 1] = gapk(340)
    signer_lines(sig, sig.lines or {}, closing)
  else
    closing[#closing + 1] = P("Signature Block", { pandoc.Str("Respectfully submitted,") })
    closing[#closing + 1] = gapk(340)
    signer_lines(sig, sig.lines or {}, closing)
    if DATE then
      closing[#closing + 1] = gapk(200)
      closing[#closing + 1] = P("Signature Block", inlines_of(DATE))
    end
  end

  -- ---- addendum: its own contents of level-2 headings ----
  local addendum = {}
  if has_addendum then
    addendum[#addendum + 1] = heading_1({ pandoc.Str("Addendum") })
    addendum[#addendum + 1] = heading_1({ pandoc.Str("Table of Contents") })
    local ad = pandoc.Pandoc(add):walk({ Link = link_filter })
    local nadd = 0
    for _, b in ipairs(ad.blocks) do
      if b.t == "Header" and b.level == 2 then
        nadd = nadd + 1
        local id = "a:" .. nadd
        need_pattern("notoc", "add", id, text(b.content))
        addendum[#addendum + 1] = entry(2, nil, b.content, id)
      end
    end
    addendum[#addendum + 1] = page_break()
    for _, b in ipairs(ad.blocks) do
      if b.t == "Header" then
        addendum[#addendum + 1] = pandoc.Header(b.level, b.content)
      else
        addendum[#addendum + 1] = b
      end
    end
  end

  -- ---- certificates ----
  local certs = {}
  if SCHEME == "answering" then
    certs[#certs + 1] = heading_1({ pandoc.Str("Certificate of Compliance") })
    certs[#certs + 1] = P("Certificate Text", { pandoc.Str("I certify that this brief complies with the type-volume limitation of Fed. Cir. R. 32(b). The total number of words in the brief is " .. group_digits(words) .. ", as calculated by " .. (meta.word_counter and text(meta.word_counter) or "the word-processing system used to prepare it") .. ".") })
    certs[#certs + 1] = P("Certificate Text", { pandoc.Str("The brief's typeface and type style comply with FRAP 32(a)(5) and (6).") })
    certs[#certs + 1] = gapk(340)
    signer_lines(sig, meta.signature and meta.signature.certificate_lines or {}, certs)
  else
    certs[#certs + 1] = heading_1({ pandoc.Str("Certificate of Compliance with Type-Volume Limitations") })
    certs[#certs + 1] = P("Certificate Text", { pandoc.Str("Case Number: " .. text(meta.case_number)) })
    certs[#certs + 1] = P("Certificate Text", append({ pandoc.Str("Short Case Caption: ") }, inlines_of(meta.short_caption or meta.brief_title)))
    if SCHEME == "reply" then
      certs[#certs + 1] = P("Certificate Text", { pandoc.Str("Instructions: When computing a word, line, or page count, you may exclude any items listed as exempted under Fed. R. App. P. 5(c), Fed. R. App. P. 21(d), Fed. R. App. P. 27(d)(2), Fed. R. App. P. 32(f), or Fed. Cir. R. 32(b)(2).") })
    end
    certs[#certs + 1] = P("Certificate Text", { pandoc.Str("The foregoing filing complies with the relevant type-volume limitation of the Federal Rules of Appellate Procedure and Federal Circuit Rules because it meets one of the following:") })
    certs[#certs + 1] = P("Checkbox Row", { checkbox(true), tab(), pandoc.Str("the filing has been prepared using a proportionally-spaced typeface and includes " .. group_digits(words) .. " words.") })
    certs[#certs + 1] = P("Checkbox Row", { checkbox(false), tab(), pandoc.Str("the filing has been prepared using a monospaced typeface and includes ____ lines of text.") })
    certs[#certs + 1] = P("Checkbox Row", { checkbox(false), tab(), pandoc.Str("the filing contains ____ pages / ____ words / ____ lines of text, which does not exceed the maximum authorized by this court's order (ECF No. ____).") })
    certs[#certs + 1] = gapk(340)
    certs[#certs + 1] = P("Signature Block", append({ pandoc.Str("Date: ") }, inlines_of(DATE)))
    certs[#certs + 1] = P("Signature Block", { pandoc.Str("Signature: /s/ " .. text(sig.signer or "")) })
    certs[#certs + 1] = P("Signature Block", { pandoc.Str("Name: " .. norm(text(sig.signer or ""))) })
  end

  -- the certificate of service: the opening and answering briefs when the sample asks for it, the reply always
  local serve = (meta.service and meta.service.certificate) or SCHEME == "reply"
  if serve then
    certs[#certs + 1] = page_break()
    certs[#certs + 1] = heading_1({ pandoc.Str("Certificate of Service") })
    if SCHEME == "reply" then
      certs[#certs + 1] = P("Certificate Text", append(append({ pandoc.Str("I hereby certify that on ") }, inlines_of(DATE)), append({ pandoc.Str(", I electronically filed the foregoing ") }, append(inlines_of(meta.brief_title), { pandoc.Str(", with the Court's CM/ECF filing system, which constitutes service, pursuant to Fed. R. App. P. 25(c) and Fed. Cir. R. 25(a).") }))))
      certs[#certs + 1] = gapk(340)
      certs[#certs + 1] = P("Signature Block", append({ pandoc.Str("Date: ") }, inlines_of(DATE)))
      signer_lines(sig, sig.lines or {}, certs)
    elseif SCHEME == "answering" then
      certs[#certs + 1] = P("Certificate Text", append(append({ pandoc.Str("I certify that on ") }, inlines_of(DATE)), { pandoc.Str(" I electronically filed the foregoing brief with the Clerk of Court using the CM/ECF system, which will send notice of the filing to all counsel of record.") }))
      certs[#certs + 1] = gapk(340)
      signer_lines(sig, sig.certificate_lines or {}, certs)
    else
      certs[#certs + 1] = P("Certificate Text", append(append({ pandoc.Str("I hereby certify under penalty of perjury that on ") }, inlines_of(DATE)), append({ pandoc.Str(", a copy of the foregoing \u{201C}") }, append(inlines_of(meta.brief_title), { pandoc.Str("\u{201D} was filed electronically and served via the Court's ECF system.") }))))
      local unreg = meta.service and meta.service.unregistered or {}
      if #unreg > 0 then
        certs[#certs + 1] = P("Certificate Text", { pandoc.Str("I further certify that on the same date I served the foregoing by U.S. Mail on the following persons, who are not registered for electronic filing:") })
        for _, u in ipairs(unreg) do
          certs[#certs + 1] = P("Numbered Item", append(append(inlines_of(u.name), { pandoc.Str(", ") }), inlines_of(u.address)))
        end
      end
      certs[#certs + 1] = gapk(340)
      certs[#certs + 1] = P("Signature Block", { pandoc.Str("Is/ " .. text(sig.signer or "")) })
      certs[#certs + 1] = P("Signature Block", { pandoc.Str(norm(text(sig.signer or ""))) })
    end
  end

  -- ---- assemble: cover | front matter (roman) | body (arabic) | addendum (Add-) | certificates (arabic) ----
  local result = {}
  append(result, cover(meta))
  result[#result + 1] = section_end(nil)
  append(result, front)
  append(result, toc)
  result[#result + 1] = page_break()
  append(result, toa)
  result[#result + 1] = page_break()
  append(result, related)
  result[#result + 1] = section_end("rIdFooterArabic", "lowerRoman", "1")
  append(result, body_blocks)
  append(result, closing)
  result[#result + 1] = section_end("rIdFooterArabic", "decimal", "1")
  append(result, addendum)
  if has_addendum then
    result[#result + 1] = section_end("rIdFooterAdd", "decimal", "1")
  end
  append(result, certs)

  local pf = os.getenv("CAFC_PATTERNS")
  local f = pf and io.open(pf, "w")
  if f then
    f:write(table.concat(PATTERNS, "\n"), "\n")
    f:close()
  end
  doc.blocks = result
  return doc
end
