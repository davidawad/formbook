-- ca11.lua (docx engine): the ca11 opening brief as Word paragraphs and sections (typst: ca11-opening-brief.typ).
-- pandoc writes the body text with docx/reference.docx; this filter writes what Word needs formatting for:
--   * the cover, the Certificate of Interested Persons, the statement on oral argument, the tables, the certificates
--     and the signature blocks, as paragraphs with explicit spacing, indents and tabs;
--   * the heading labels (I., A., 1., a., (1)) and the outline level of each heading;
--   * the table of contents and the table of citations: their entries and page numbers. render.sh renders the
--     document once, finds the page of every heading and citation in the PDF (the needles this filter writes),
--     and renders again with those pages (the pages file this filter reads);
--   * the sections whose footers number the pages: cover (none), Certificate of Interested Persons (C-1 ...),
--     front matter (i, ii ...), body and certificates (1 ...). render.sh adds the footers.
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local TOC_DEPTH = 4     -- heading levels listed in the table of contents (typst: toc-depth)
local LIMIT = 13000     -- FRAP 32(a)(7)(B)(i)
local TAB = 720         -- half an inch, in twips
local TEXT_W = 9360     -- the text width, 6.5 in
local HALF_W = 4680     -- the middle of the page: the caption and the counsel block start here
local NEEDLE_MAX = 80
local DATE = ""         -- the date of the brief, set from the frontmatter by Pandoc()   -- a needle is a prefix of the text: it must fit on one page

local stringify = pandoc.utils.stringify

-- ---------------------------------------------------------------------------
-- XML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function merge(a, b)
  local out = {}
  for k, v in pairs(a or {}) do out[k] = v end
  for k, v in pairs(b or {}) do out[k] = v end
  return out
end

local function rpr(o)
  local x = ""
  if o.b then x = x .. "<w:b/><w:bCs/>" end
  if o.i then x = x .. "<w:i/><w:iCs/>" end
  if o.u then x = x .. '<w:u w:val="single"/>' end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

-- Text with tabs (\t) and line breaks (\n) as Word runs.
local function runs(text, o)
  local x = rpr(o or {})
  local out = {}
  local pos = 1
  while pos <= #text do
    local c = text:sub(pos, pos)
    if c == "\t" then
      out[#out + 1] = "<w:r>" .. x .. "<w:tab/></w:r>"
      pos = pos + 1
    elseif c == "\n" then
      out[#out + 1] = "<w:r>" .. x .. "<w:br/></w:r>"
      pos = pos + 1
    else
      local e = text:find("[\t\n]", pos) or (#text + 1)
      out[#out + 1] = "<w:r>" .. x .. '<w:t xml:space="preserve">' .. esc(text:sub(pos, e - 1)) .. "</w:t></w:r>"
      pos = e
    end
  end
  return table.concat(out)
end

-- Pandoc inlines as Word runs; links keep their text, a metadata string is one run.
local function inl(x, o)
  o = o or {}
  if type(x) == "string" then return runs(x, o) end
  local out = {}
  for _, el in ipairs(x or {}) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = runs(el.text, o)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = runs(" ", o)
    elseif t == "LineBreak" then
      out[#out + 1] = runs("\n", o)
    elseif t == "Emph" then
      out[#out + 1] = inl(el.content, merge(o, { i = true }))
    elseif t == "Strong" then
      out[#out + 1] = inl(el.content, merge(o, { b = true }))
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = runs(q[1], o) .. inl(el.content, o) .. runs(q[2], o)
    elseif t == "Link" or t == "Span" then
      out[#out + 1] = inl(el.content, o)
    else
      out[#out + 1] = runs(stringify(el), o)
    end
  end
  return table.concat(out)
end

-- A paragraph. The properties are given in the schema's order: keep, page break, border, tabs, spacing, indent,
-- justification, outline level. Word refuses a file whose paragraph properties are out of order or repeated.
local function para(props, body)
  return "<w:p><w:pPr>" .. table.concat(props) .. "</w:pPr>" .. body .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local KEEP = "<w:keepNext/><w:keepLines/>"
local KEEP_BREAK = "<w:keepNext/><w:keepLines/><w:pageBreakBefore/>"

-- Line spacing: DOUBLE is the body's 31.43 pt, SINGLE the 19.95 pt of headings, cover and certificates.
local function spacing(before, after, line, rule)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>', before, after, line, rule or "exact")
end

local function ind(left, hanging, first)
  local x = '<w:ind w:left="' .. (left or 0) .. '"'
  if hanging then x = x .. ' w:hanging="' .. hanging .. '"' end
  if first then x = x .. ' w:firstLine="' .. first .. '"' end
  return x .. "/>"
end

local function jc(v)
  return '<w:jc w:val="' .. v .. '"/>'
end

-- The tab stops of a row: a dot leader to the right margin (the page number follows the last tab).
local function dot_tabs()
  return '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/></w:tabs>'
end

-- A right-aligned tab with no leader (the "Page" and "Page(s)" labels).
local function right_tab()
  return '<w:tabs><w:tab w:val="right" w:pos="' .. TEXT_W .. '"/></w:tabs>'
end

-- The paragraph that ends a section: its sectPr is the section's (footer, page number format and start).
local function section(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="432" w:gutter="0"/>' .. pg .. "</w:sectPr></w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Numbers, normalization, needles and pages
-- ---------------------------------------------------------------------------

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- Letters and digits only, lower case: render.sh normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {} -- { id, kind, needle } in document order
local function need(id, kind, text)
  local n = norm(text):sub(1, NEEDLE_MAX)
  if n ~= "" then needles[#needles + 1] = { id = id, kind = kind, needle = n } end
end

-- The pages of the first pass: id -> { page, label }. Absent on the first pass itself.
local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = label } end
  end
  f:close()
end

local function label_of(id)
  local l = labels[id]
  if l then return l.label end
  return "00" -- the first pass: a placeholder of the final width
end

local function write_needles()
  local path = os.getenv("FORMBOOK_NEEDLES")
  if not path then return end
  local f = assert(io.open(path, "w"))
  for _, n in ipairs(needles) do
    f:write(n.id, "\t", n.kind, "\t", n.needle, "\n")
  end
  f:close()
end

-- ---------------------------------------------------------------------------
-- Headings and the table of contents
-- ---------------------------------------------------------------------------

local in_arg = false
local counts = { 0, 0, 0, 0, 0, 0 }
local headings = {}    -- the headings the table of contents lists, in order
local occurrences = {} -- the table-of-citations links, in document order: { key, primary, index }

-- The label of a numbered heading (typst heading-label). The Argument: I. / A. / 1. / a.; elsewhere: A. / 1. / a. / (1).
local function label(level, n, arg)
  if arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    return string.char(96 + n) .. "."
  end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

-- Label indent in half inches (typst label-indent): the Argument's point is centered, its sub-headings start at 0.
local function step(level, arg)
  if arg then return level - 3 + 1 end
  return level - 2 + 1
end

-- The XML of a body heading (typst: style-heading). Level 1 is centered and capitalized; in the Argument the level-2
-- point is centered; the others hang under their label, each level half an inch further in.
local function heading_xml(level, content, lab, arg)
  local text = stringify(content)
  if level == 1 then
    return para({ KEEP, spacing(420, 300, 240, "auto"), jc("center") }, runs(text:upper(), { b = true }))
  end
  if arg and level == 2 then
    return para({ KEEP, spacing(240, 200, 240, "auto"), jc("center") },
      runs(lab .. " " .. text:upper(), { b = true }))
  end
  local k = step(level, arg)
  local o = { b = true, i = level >= 4 }
  return para({ KEEP, spacing(240, 180, 240, "auto"), ind(TAB * (k + 1), TAB) },
    runs(lab .. "\t", { b = true }) .. inl(content, o))
end

-- One row of the table of contents (typst: toc-entry): the label, the title, a dot leader and the page.
local function toc_row(item)
  local title = item.title
  if item.level == 1 then title = title:upper() end
  local left, hanging, lead = 0, nil, ""
  if item.label then
    left, hanging = TAB * item.step + TAB, TAB
    lead = runs(item.label .. "\t", {})
  end
  local before = item.level == 1 and 120 or 0
  return para({ dot_tabs(), spacing(before, 0, 629), ind(left, hanging) },
    lead .. runs(title .. " \t", {}) .. runs(label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of citations (typst: toa-section)
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "regulation", "Regulations" },
  { "rule", "Rules" },
  { "other", "Other Authorities" },
}

-- The rows of the table, and the needle of its first entry (the table's heading also sits in the table of contents).
local function toa_rows(authorities)
  local used = {}
  for _, o in ipairs(occurrences) do
    used[o.key] = true
    if not authorities[o.key] then
      error("ca11.lua: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  local out = {}
  local first_needle = nil
  local first_group = true
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if a.kind and stringify(a.kind) == g[1] and used[key] then
        local base = a.sort and stringify(a.sort) or ((a.name and stringify(a.name) or "") .. " " .. stringify(a.cite))
        members[#members + 1] = { key = key, a = a, sort = norm(base) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      local head = runs(g[2], { b = true })
      if first_group then
        head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true })
      end
      out[#out + 1] = para({ right_tab(), KEEP, spacing(first_group and 240 or 360, 100, 399, "exact") }, head)
      first_group = false
      for _, m in ipairs(members) do
        -- the distinct pages of the authority, in page order; a page is starred when a primary citation is on it
        local pages = {}
        local seen = {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local k = l and tostring(l.page) or ("?" .. o.index)
            if not seen[k] then
              seen[k] = { page = l and l.page or 0, label = l and l.label or "00", star = false }
              pages[#pages + 1] = seen[k]
            end
            if o.primary then seen[k].star = true end
          end
        end
        table.sort(pages, function(x, y) return x.page < y.page end)
        local list = {}
        for _, p in ipairs(pages) do list[#list + 1] = (p.star and "*" or "") .. p.label end
        if first_needle == nil then
          first_needle = m.a.name and stringify(m.a.name) or stringify(m.a.cite)
        end
        local name = ""
        if m.a.name then
          local nm = g[1] == "case" and inl(m.a.name, { i = true }) or inl(m.a.name, {})
          name = nm .. runs(",\n", {})
        end
        out[#out + 1] = para({ dot_tabs(), KEEP, spacing(140, 0, 629), ind(504, 504) },
          name .. inl(m.a.cite, {}) .. runs(" \t" .. table.concat(list, ", "), {}))
      end
    end
  end
  return table.concat(out), first_needle
end

-- ---------------------------------------------------------------------------
-- Cover (typst: cover-body), Certificate of Interested Persons, statement on oral argument, signature
-- ---------------------------------------------------------------------------

local function need_meta(meta, k)
  if meta[k] == nil then error("ca11.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

local function rule()
  return raw(para({ '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>',
    spacing(0, 240, 399), '<w:ind w:left="3240" w:right="3240"/>', jc("center") }, ""))
end

local function cover(meta)
  local out = {}
  out[#out + 1] = raw(para({ KEEP, spacing(0, 240, 399), jc("center") },
    runs("Case No. ", { b = true }) .. inl(need_meta(meta, "case_number"), { b = true })))
  out[#out + 1] = raw(para({ spacing(0, 240, 399), jc("center") },
    runs("In the United States Court of Appeals\nfor the Eleventh Circuit", { b = true })))
  out[#out + 1] = rule()
  local sides = need_meta(meta, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do
      out[#out + 1] = raw(para({ spacing(0, 120, 399), jc("center") }, inl(name, {})))
    end
    out[#out + 1] = raw(para({ spacing(0, 120, 399), ind(HALF_W) }, inl(side.designation, {})))
    if i < #sides then
      out[#out + 1] = raw(para({ spacing(120, 120, 399), jc("center") }, runs("v.", {})))
    end
  end
  out[#out + 1] = rule()
  out[#out + 1] = raw(para({ spacing(0, 120, 399), jc("center") }, inl(need_meta(meta, "proceeding"), {})))
  if meta.district_court_case then
    out[#out + 1] = raw(para({ spacing(0, 120, 399), jc("center") }, inl(meta.district_court_case, {})))
  end
  out[#out + 1] = rule()
  out[#out + 1] = raw(para({ spacing(0, 240, 399), jc("center") }, inl(need_meta(meta, "brief_title"), { b = true })))
  out[#out + 1] = rule()
  for _, g in ipairs(need_meta(meta, "counsel")) do
    for _, n in ipairs(g.names or {}) do
      out[#out + 1] = raw(para({ spacing(0, 0, 399), ind(HALF_W) }, inl(n, {})))
    end
    for _, l in ipairs(g.lines or {}) do
      out[#out + 1] = raw(para({ spacing(0, 0, 399), ind(HALF_W) }, inl(l, { i = true })))
    end
    out[#out + 1] = raw(para({ spacing(0, 240, 399), ind(HALF_W) }, inl(need_meta(meta, "phone"), { i = true })))
  end
  out[#out + 1] = rule()
  out[#out + 1] = raw(para({ spacing(0, 0, 399), jc("center") }, inl(need_meta(meta, "role"), { i = true })))
  return out
end

-- typst: signature-block. The lines stay together on one page.
local function signature(meta)
  local sig = need_meta(meta, "signature")
  local out = {}
  out[#out + 1] = para({ KEEP, spacing(280, 240, 399), ind(0) },
    runs("Respectfully submitted this " .. DATE .. ".", {}))
  out[#out + 1] = para({ KEEP, spacing(240, 0, 399), ind(HALF_W) }, runs("/s/ " .. stringify(sig.signer), {}))
  out[#out + 1] = para({ KEEP, spacing(0, 0, 399), ind(HALF_W) }, runs(stringify(sig.signer), {}))
  for _, l in ipairs(sig.lines or {}) do
    out[#out + 1] = para({ KEEP, spacing(0, 0, 399), ind(HALF_W) }, inl(l, { i = true }))
  end
  return table.concat(out)
end

-- The words of the markdown body, counted as the typst template counts them (count-words).
local function count_body_words()
  local path = PANDOC_STATE.input_files[1]
  local f = assert(io.open(path, "r"))
  local src = f:read("a")
  f:close()
  local s = "\n" .. (src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n(.*)$") or src)
  s = s:gsub("<!%-%-.-%-%->", " ")
  s = s:gsub("\n%[%^[^%]]*%]:", "\n ")
  s = s:gsub("%[%^[^%]]*%]", "")
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[%-%*%+][ \t]+", "\n")
  s = s:gsub("\n[ \t]*%d+[%.%)][ \t]+", "\n")
  s = s:gsub("\\(.)", "%1")
  s = s:gsub("%*", "")
  s = s:gsub("([%s%(%[\"])_", "%1")
  s = s:gsub("_([%s%.,;:%)%]\"!%?])", "%1")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  -- the date is printed by the signature blocks only: pandoc would also set it at the top of the document
  DATE = stringify(meta.date or "")
  doc.meta.date = nil
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "role",
    "signature", "cip_intro", "cip", "cip_closing", "oral_argument" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  local words = count_body_words()
  if words > LIMIT then
    error("ca11.lua: the brief has " .. words .. " words; FRAP 32(a)(7)(B)(i) allows " .. LIMIT)
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "addendum" then
      error("ca11.lua: the opening brief has no addendum section; remove the `# Addendum` heading")
    end
  end

  -- The body, walked in order: citations (their needles), headings (labels, outline, needles, table entries).
  local walked = pandoc.Pandoc(doc.blocks, meta):walk({
    Link = function(el)
      local star, key = el.target:match("^toa(%*?):(.+)$")
      if key == nil then return nil end
      occurrences[#occurrences + 1] = { key = key, primary = star == "*", index = #occurrences + 1 }
      need("T:" .. #occurrences, "T", stringify(el.content))
      return el.content
    end,
  })
  local body = {}
  local first_para = nil
  local h_n = 0
  for _, b in ipairs(walked.blocks) do
    if b.t == "Header" then
      if b.level > 5 then error("ca11.lua: headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then in_arg = norm(stringify(b.content)) == "argument" end
      local lab = b.level == 1 and "" or label(b.level, counts[b.level], in_arg)
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "H", stringify(b.content))
      if b.level <= TOC_DEPTH then
        local arg_point = in_arg and b.level == 2
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = stringify(b.content), step = arg_point and 0 or step(b.level, in_arg) }
      end
      body[#body + 1] = raw(heading_xml(b.level, b.content, lab, in_arg))
    elseif b.t == "Para" then
      if first_para == nil then first_para = stringify(b) end
      body[#body + 1] = b
    else
      body[#body + 1] = b
    end
  end
  -- The last paragraph stays with the signature block (typst: the tail block is kept with the signature).
  local last = body[#body]
  if last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, 629), ind(0, nil, TAB) }, inl(last.content, {})))
  end
  need("S:cip", "S", "Certificate of Interested Persons and Corporate Disclosure Statement")
  need("S:oral", "S", "Statement Regarding Oral Argument")
  need("S:toc", "S", "Table of Contents")
  local toa, toa_first = toa_rows(authorities)
  need("S:toa", "S", toa_first or "")
  need("S:body", "S", (first_para or ""):sub(1, NEEDLE_MAX))
  need("H:cert-c", "H", "Certificate of Compliance")
  if meta.service_list then need("H:cert-s", "H", "Certificate of Service") end
  write_needles()

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrCover"))

  -- Section 2: the Certificate of Interested Persons (C-1, C-2 ...)
  add(raw(para({ KEEP, spacing(0, 240, 399), jc("center") },
    runs("CERTIFICATE OF INTERESTED PERSONS AND CORPORATE DISCLOSURE STATEMENT", { b = true }))))
  add(raw(para({ spacing(0, 0, 629), ind(0, nil, 0) }, inl(meta.cip_intro, {}))))
  for i, e in ipairs(meta.cip) do
    add(raw(para({ spacing(0, 0, 629), ind(TAB, TAB) }, runs(i .. ".\t", {}) .. inl(e, {}))))
  end
  add(raw(para({ spacing(0, 0, 629), ind(0, nil, 0) }, inl(meta.cip_closing, {}))))
  add(section("rIdFtrCip", "decimal", 1))

  -- Section 3: the front matter (i, ii ...): oral argument, table of contents, table of citations
  add(raw(para({ KEEP, spacing(0, 240, 399), jc("center") }, runs("STATEMENT REGARDING ORAL ARGUMENT", { b = true }))))
  add(raw(para({ spacing(0, 0, 629), ind(0, nil, 0) }, inl(meta.oral_argument, {}))))
  add(raw(para({ KEEP_BREAK, spacing(0, 240, 399), jc("center") }, runs("TABLE OF CONTENTS", { b = true }))))
  add(raw(para({ right_tab(), spacing(0, 120, 399) }, runs("\t", {}) .. runs("Page", { b = true, u = true }))))
  local items = {
    { id = "S:cip", level = 1, title = "Certificate of Interested Persons and Corporate Disclosure Statement", step = 0 },
    { id = "S:oral", level = 1, title = "Statement Regarding Oral Argument", step = 0 },
    { id = "S:toc", level = 1, title = "Table of Contents", step = 0 },
    { id = "S:toa", level = 1, title = "Table of Citations", step = 0 },
  }
  for _, h in ipairs(headings) do items[#items + 1] = h end
  items[#items + 1] = { id = "H:cert-c", level = 1, title = "Certificate of Compliance", step = 0 }
  if meta.service_list then items[#items + 1] = { id = "H:cert-s", level = 1, title = "Certificate of Service", step = 0 } end
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(para({ KEEP_BREAK, spacing(0, 240, 399), jc("center") }, runs("TABLE OF CITATIONS", { b = true }))))
  add(raw(toa))
  add(section("rIdFtrFront", "lowerRoman", 1))

  -- Section 4: the body (1, 2 ...) and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(section("rIdFtrBody", "decimal", 1))

  add(raw(para({ KEEP_BREAK, spacing(0, 240, 399), jc("center") }, runs("CERTIFICATE OF COMPLIANCE", { b = true }))))
  add(raw(para({ spacing(0, 0, 629), ind(0, nil, 0) },
    runs("Pursuant to Rule 32(g) of the Federal Rules of Appellate Procedure, I certify that the foregoing ", {})
    .. runs(stringify(meta.brief_title):upper(), { b = true })
    .. runs(" complies with (1) the word limit of Rule 32(a)(7)(B) of the Federal Rules of Appellate Procedure because it contains "
      .. group_digits(words) .. " words, which is no more than " .. group_digits(LIMIT)
      .. ", and (2) the typeface and type-style requirements of Rule 32(a)(5) and (6) of the Federal Rules of Appellate Procedure because it has been prepared in a proportionally spaced typeface (EB Garamond) in 14-point.", {}))))
  add(raw(signature(meta)))

  if meta.service_list then
    add(raw(para({ KEEP_BREAK, spacing(0, 240, 399), jc("center") }, runs("CERTIFICATE OF SERVICE", { b = true }))))
    add(raw(para({ spacing(0, 240, 399), ind(0, nil, 0) },
      runs("This is to certify that I, " .. stringify(meta.signature.signer)
        .. ", have this day electronically filed the foregoing ", {})
      .. runs(stringify(meta.brief_title):upper(), { b = true })
      .. runs(" with the Clerk of Court using the CM/ECF system, which will automatically send electronic notification of such filing to counsel of record who are CM/ECF participants:", {}))))
    for _, s in ipairs(meta.service_list) do
      local joined = {}
      for i, l in ipairs(s.lines) do
        if i > 1 then joined[#joined + 1] = runs(", ", {}) end
        joined[#joined + 1] = inl(l, {})
      end
      add(raw(para({ spacing(140, 0, 399), ind(TAB, nil, 0) }, table.concat(joined))))
    end
    add(raw(signature(meta)))
  end

  doc.blocks = out
  return doc
end
