-- armfor.lua (docx engine): the CAAF brief on behalf of the appellant (Rule 24) and the supplement to a petition
-- for grant of review (Rule 21(b)) as Word paragraphs and sections, on the shared cross-engine layout model
-- (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"). The typst template (../typst/armfor-*.typ) is the
-- reference: every line and page breaks where it breaks them. The same file serves both doc types; the doc type is
-- the name of the folder fb render runs pandoc in (opening-brief | petition-supplement).
--
-- pandoc writes the body text (paragraphs, quotations, footnotes) with docx/reference.docx (make-reference.sh);
-- this filter writes:
--   * the cover (Rule 24(a) form), the index of brief and the table of cases, statutes and other authorities
--     (Rule 37(c)(1)), the signature block (Rule 38), the certificates of compliance (Rule 24(d) / 21(b)) and of
--     filing and service (Rule 39(c)(2)), as paragraphs with exact line spacing at the typst pitches;
--   * the heading labels (I., A., 1., a. in the Argument; A., 1., a., (1) elsewhere);
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of
--     every heading and citation in the LibreOffice PDF (the needles this filter writes to FORMBOOK_NEEDLES) and
--     renders again with those pages (FORMBOOK_PAGES) until they settle;
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1, 2 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local xe = require("docx.xengine")
local runs, inl = xe.runs, xe.inl
local para, raw, ind, jc = xe.para, xe.raw, xe.ind, xe.jc
local KEEP, LINES, BREAK = xe.KEEP, xe.LINES, xe.BREAK
-- Before the leader tab of a table row: three spaces the line cannot break at (typst listing-row: h(0.75em)). Not
-- xe.LEAD's three no-break spaces: LibreOffice lets a row end on those only 4.6 pt short of the right indent
-- (measured on this template's index rows), so it wrapped a last word typst kept. Four-per-em spaces (0.25 em, the
-- width of a space) bound by word joiners fit exactly as typst's space does.
local LEAD = "\u{2060}\u{2005}\u{2060}\u{2005}\u{2060}\u{2005}\u{2060}\t"
local stringify = pandoc.utils.stringify

-- The typst numbers, in twips (20 x pt).
local DOUBLE = 518     -- body text: 25.9 pt (typst pitch-double; reference.docx Body Text)
local SINGLE = 288     -- everything single-spaced: 14.4 pt (typst pitch-single)
local TAB = 720        -- half an inch (para-indent, heading-tab)
local TEXT_W = 9360    -- the text width, 6.5 in: the leader tab of the tables
local HALF_W = 4680    -- the signature block starts in the middle of the text (pad(left: 50%))
local TOC_COL = 720    -- index: the page column (typst toc-page-col, 36 pt)
local TOA_COL = 1120   -- authorities: the page column (typst toa-page-col, 56 pt)
local TOA_HANG = 504   -- authorities: continuation lines (typst toa-hang, 0.35 in)
local TOC_DEPTH = 4
local PASSIM = 7       -- an authority cited on this many pages or more prints "passim"
local NEEDLE_MAX = 60
-- the space above and below each kind of heading (typst `space`)
local SPACE = { section = { 420, 308 }, point = { 336, 280 }, sub = { 308, 252 } }

local function kind_of_folder()
  local cwd = pandoc.system.get_working_directory()
  return cwd:match("([^/\\]+)[/\\]?$")
end

local KIND = kind_of_folder()
local CFG = {
  ["opening-brief"] = {
    tag = "armfor-opening-brief",
    word_limit = 13000, limit_rule = "Rule 24(b)(1)", order_rule = "Rule 24(a)",
    cover_title = function(meta) return "BRIEF ON BEHALF OF " .. stringify(meta.filer_role):upper() end,
    cover_par = 112, cover_gap = 336,
    required = { "issue", "statement of statutory jurisdiction", "statement of the case", "statement of facts",
      "summary of argument", "^argument$", "^conclusion$" },
    standard_of_review = true,
    fields = { "crim_app_dkt", "uscaaf_dkt", "filer_role", "caption", "counsel", "signature", "date", "service" },
    comp_heading = "Certificate of Compliance with Rule 24(b)",
    comp_text = function(n)
      return "This brief complies with the type-volume limitation of Rule 24(b) because: This brief contains " .. n
        .. " words. This brief complies with the typeface and type style requirements of Rule 37."
    end,
  },
  ["petition-supplement"] = {
    tag = "armfor-petition-supplement",
    word_limit = 9000, limit_rule = "Rule 21(b)", order_rule = "Rule 21(b)",
    cover_title = function() return "SUPPLEMENT TO PETITION FOR GRANT OF REVIEW" end,
    cover_par = 168, cover_gap = 504,
    required = { "issue", "statement of statutory jurisdiction", "statement of the case", "statement of facts",
      "^argument$" },
    standard_of_review = false,
    fields = { "crim_app_dkt", "uscaaf_dkt", "caption", "counsel", "signature", "date", "service" },
    comp_heading = "Certificate of Compliance",
    comp_text = function(n)
      return "The undersigned counsel hereby certifies that: (1) this supplement complies with the type-volume "
        .. "limitation of Rule 21(b) because it contains " .. n .. " words; and (2) this supplement complies with the "
        .. "style requirements of Rule 37."
    end,
  },
}
local C = CFG[KIND] or error("armfor.lua: unknown doc type folder " .. tostring(KIND))

local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

local function need_meta(meta, k)
  if meta[k] == nil then error(C.tag .. ": missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- ---------------------------------------------------------------------------
-- Sections, needles and pages (the multi-pass engine of fb render)
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="718" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (a 1 pt line, so it never pushes a line on).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function opening(text)
  local out = ""
  for w in text:gmatch("%S+") do
    out = out .. norm(w)
    if #out >= 8 then break end
  end
  return out:sub(1, NEEDLE_MAX)
end

local function need(id, kind, text, context)
  local short = opening(text)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
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

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Word count: the typst count-words, on the same markdown, so both engines certify the same number
-- ---------------------------------------------------------------------------

local function markdown_body()
  local path = PANDOC_STATE.input_files[1]
  local f = assert(io.open(path, "r"), C.tag .. ": cannot read " .. tostring(path))
  local src = f:read("a")
  f:close()
  local s, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if not s then error(C.tag .. ": the sample must start with a YAML frontmatter block") end
  return src:sub(e + 1)
end

local function count_words(md)
  -- every line-anchored rule runs on "\n" .. line, as typst's (?m)^ does
  local s = "\n" .. md
  s = s:gsub("\n%[%^[^%]]+%]:", "\n ")                    -- footnote definition labels
  s = s:gsub("%[%^[^%]]+%]", "")                          -- footnote references
  s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")              -- links keep their text
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[%-%*%+][ \t]+", "\n")              -- list markers are not words
  s = s:gsub("\n[ \t]*%d+[%.%)][ \t]+", "\n")
  s = s:gsub("\\(.)", "%1")                               -- backslash escapes
  s = s:gsub("%*", "")
  s = s:gsub("([%s%(%[\"])_", "%1"):gsub("\u{201C}_", "\u{201C}")
  s = s:gsub("_([%s%.,;:%)%]\"!%?])", "%1"):gsub("_\u{201D}", "\u{201D}"):gsub("_$", "")
  local n = 0
  for w in s:gmatch("%S+") do
    -- a word holds a letter or a digit (ASCII, or a Latin letter with a diacritic: UTF-8 lead bytes C3 to C5)
    if w:find("%w") or w:find("[\195-\197]") then n = n + 1 end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Headings (typst heading-label, label-indent, style-heading)
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

local function label(level, n, arg)
  if level > 5 then error(C.tag .. ": headings deeper than level 5 are not supported") end
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

-- the left edge of a sub-heading's label: each level steps in half an inch (typst label-indent)
local function label_indent(level, arg)
  local first = arg and 3 or 2
  return (level - first + 1) * TAB
end

local function section_heading(text, top, brk)
  return para({ KEEP, brk and BREAK or "", spacing(top and 0 or SPACE.section[1], SPACE.section[2]), ind(0, nil, 0),
    jc("center") }, inl(text, { b = true }))
end

local function heading_xml(level, content, lab, arg)
  if level == 1 then return section_heading(content, false) end
  if arg and level == 2 then
    return para({ KEEP, spacing(SPACE.point[1], SPACE.point[2]), ind(0, nil, 0), jc("center") },
      runs(lab .. " ", { b = true }) .. inl(content, { b = true }))
  end
  local left = label_indent(level, arg)
  return para({ KEEP, spacing(SPACE.sub[1], SPACE.sub[2]), ind(left + TAB, TAB) },
    runs(lab .. "\t", { b = true }) .. inl(content, { b = true }))
end

-- One index row (typst toc-entry and listing-row): the label at the heading's own label indent (the Argument's
-- point at the margin), the title hanging after it, wrapped before the page column, a dot leader to the page.
local function toc_row(item)
  local lead = ""
  if item.label then lead = runs(item.label .. "\t", {}) end
  return para({ LINES, xe.leader_tab(TEXT_W), spacing(item.level == 1 and 168 or 98, 0),
    ind(item.ind + TAB, TAB, nil, TOC_COL) }, lead .. inl(item.content, {}) .. runs(LEAD .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of cases, statutes and other authorities (typst toa-section)
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "constitution", "Constitutional Provisions" },
  { "scotus", "Supreme Court of the United States" },
  { "caaf", "Court of Appeals for the Armed Forces and Court of Military Appeals" },
  { "service", "Service Courts of Criminal Appeals" },
  { "other-court", "State and Other Federal Court Cases" },
  { "statute", "Statutes" },
  { "rule", "Rules and Other Authorities" },
  { "other", "Other Authorities" },
}
local CASE_KINDS = { scotus = true, caaf = true, service = true, ["other-court"] = true }

local occurrences = {} -- the authority links, in document order: { key, index }

local function sort_key(a)
  return stringify(a.sort or a.name or a.cite):lower()
end

local function toa_rows(authorities)
  local used = {}
  for _, o in ipairs(occurrences) do used[o.key] = true end
  local out = {}
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and a.kind and stringify(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      local head = runs(g[2], { b = true })
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TEXT_W .. '"/></w:tabs>',
        spacing(#out == 0 and 280 or 392, 56) }, head)
      for _, m in ipairs(members) do
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local k = l and l.label or ("?" .. o.index)
            if not seen[k] then
              seen[k] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
            end
          end
        end
        table.sort(pages, function(x, y) return x.page < y.page end)
        local list, list_w
        if #pages >= PASSIM then
          list, list_w = runs("passim", { i = true }), 0
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          local s = table.concat(l, ", ")
          list = runs(s, {})
          -- a list wider than the column widens it (typst: the larger of 56 pt and the list): Times New Roman
          -- digits are 0.5 em (140 twips at 14 pt), a comma and a space 0.25 em each
          list_w = 0
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 140 or 70) end
        end
        local name = ""
        if m.a.name then name = inl(m.a.name, { i = CASE_KINDS[g[1]] or false }) .. runs(", ", {}) end
        out[#out + 1] = para({ LINES, xe.leader_tab(TEXT_W), spacing(196, 0),
          ind(TOA_HANG, TOA_HANG, nil, math.max(TOA_COL, list_w)) }, name .. inl(m.a.cite, {}) .. runs(LEAD, {}) .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover: one paragraph a line, the counsel in two columns at the foot of the page)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local par, gap = C.cover_par, C.cover_gap
  local out = {}
  local function line(before, body, align)
    out[#out + 1] = para({ spacing(before, 0), ind(0, nil, 0), jc(align or "center") }, body)
  end
  line(0, runs("IN THE UNITED STATES COURT OF APPEALS", { b = true }))
  line(par, runs("FOR THE ARMED FORCES", { b = true }))
  for i, side in ipairs(need_meta(meta, "caption")) do
    if i > 1 then line(par, runs("v.", {})) end
    for k, n in ipairs(side.names or {}) do line(k > 1 and 84 or (i == 1 and gap or par), inl(n, {})) end
    for k, l in ipairs(side.lines or {}) do line(k > 1 and 0 or par, inl(l, {})) end
    line(par, inl(side.role, { i = true }))
  end
  line(gap, runs(C.cover_title(meta), { b = true }))
  line(gap, inl(need_meta(meta, "crim_app_dkt"), {}))
  line(par, inl(need_meta(meta, "uscaaf_dkt"), {}))
  line(gap, runs("TO THE JUDGES OF THE UNITED STATES COURT OF APPEALS FOR THE ARMED FORCES:", {}), "left")
  -- counsel: two groups a row in columns of (6.5 in - 21 pt) / 2, 21 pt apart, 16.8 pt between the rows; a table
  -- anchored to the foot of the text area (typst: v(1fr) before the grid)
  local COL, GUT = 4470, 420
  local function cell(w, g)
    local ps = {}
    if g then
      for _, n in ipairs(g.names or {}) do ps[#ps + 1] = para({ spacing(0, 0), ind(0, nil, 0) }, inl(n, {})) end
      for _, l in ipairs(g.lines or {}) do ps[#ps + 1] = para({ spacing(0, 0), ind(0, nil, 0) }, inl(l, { i = true })) end
    end
    if #ps == 0 then ps[1] = para({ spacing(0, 0, 20) }, "") end
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. "</w:tc>"
  end
  local groups = need_meta(meta, "counsel")
  local trs = {}
  for i = 1, #groups, 2 do
    if i > 1 then
      trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="336" w:hRule="exact"/></w:trPr>'
        .. cell(COL) .. cell(GUT) .. cell(COL) .. "</w:tr>"
    end
    trs[#trs + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. cell(COL, groups[i]) .. cell(GUT) .. cell(COL, groups[i + 1]) .. "</w:tr>"
  end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblpPr w:leftFromText="0" w:rightFromText="0" w:vertAnchor="margin" '
    .. 'w:horzAnchor="margin" w:tblpX="0" w:tblpYSpec="bottom"/><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblBorders>' .. none .. '</w:tblBorders><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="' .. COL .. '"/>'
    .. '<w:gridCol w:w="' .. GUT .. '"/><w:gridCol w:w="' .. COL .. '"/></w:tblGrid>' .. table.concat(trs) .. "</w:tbl>"
  -- a document may not end a section on a table: an empty 1 pt paragraph closes the cover
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = raw(x) end
  return blocks
end

-- ---------------------------------------------------------------------------
-- Signature and certificates (typst sig-lines, signature-block, certificate-of-*)
-- ---------------------------------------------------------------------------

local function sig_lines(meta, above, gap, keep_all)
  local sig = need_meta(meta, "signature")
  local lines = sig.lines or {}
  local out = { para({ KEEP, spacing(above, 0), ind(HALF_W, nil, 0) }, runs("/s/ ", {}) .. inl(sig.signer, {})) }
  for k, l in ipairs(lines) do
    local keep = keep_all or k < #lines
    out[#out + 1] = para({ keep and KEEP or LINES, spacing(k == 1 and gap or 0, 0), ind(HALF_W, nil, 0) }, inl(l, {}))
  end
  return table.concat(out)
end

local function signature(meta)
  local x = sig_lines(meta, 392, 140, meta.date ~= nil)
  if meta.date then
    x = x .. para({ LINES, spacing(224, 0), ind(HALF_W, nil, 0) }, runs("Dated: ", {}) .. inl(meta.date, {}))
  end
  return x
end

local function certificate(title, text, meta)
  return section_heading(title, true, true)
    .. para({ KEEP, spacing(0, 0), ind(0, nil, 0) }, text)
    .. sig_lines(meta, 392, 112, false)
end

-- ---------------------------------------------------------------------------
-- Citations, in document order (the needles of the table of authorities)
-- ---------------------------------------------------------------------------

local scan_blocks

local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      occurrences[#occurrences + 1] = { key = el.target:sub(5), index = #occurrences + 1 }
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      need("T:" .. #occurrences, in_note and "N" or "B", stringify(el.content), stringify(rest))
    elseif el.t == "Note" then
      scan_blocks(el.content, true)
    elseif el.content and type(el.content) ~= "string" and el.t ~= "Link" then
      scan_inlines(el.content, in_note)
    end
  end
end

scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" then
      scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

local function strip_links(blocks)
  return pandoc.Pandoc(blocks):walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
    Inlines = xe.inlines,
  }).blocks
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- The text a heading's needle continues with: the start of the block after it (a heading with its label, as the
-- PDF prints it).
local function next_text(blocks, labs, i)
  local b = blocks[i + 1]
  if not b then return "" end
  return ((labs[i + 1] or "") .. stringify(b)):sub(1, 40)
end

local function check_structure(titles)
  local i = 1
  for _, req in ipairs(C.required) do
    local found = false
    while i <= #titles and not found do
      local t = titles[i]:lower():gsub("^%s+", ""):gsub("%s+$", "")
      found = t:find(req) ~= nil
      i = i + 1
    end
    if not found then
      error(C.tag .. ": required section matching `" .. req .. "` is missing or out of order (" .. C.order_rule .. ")")
    end
  end
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  -- no break inside a token of adjacent parentheses ("502(c)(3)"; typst boxes it, LibreOffice would break before
  -- the second parenthesis): a word joiner between them, in the body and in the metadata
  doc = doc:walk({ Str = function(s)
    if s.text:find(")(", 1, true) then return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("))) end
  end })
  local meta = doc.meta
  for _, k in ipairs(C.fields) do need_meta(meta, k) end
  local authorities = meta.authorities or {}

  local words = count_words(markdown_body())
  if words > C.word_limit then
    error(C.tag .. ": the document has " .. words .. " words; " .. C.limit_rule .. " allows " .. C.word_limit)
  end

  need("S:toc", "B", "Index of Brief", "Page")

  local items, body, titles = {}, {}, {}
  local in_arg, any_sor = false, false
  local counts = { 0, 0, 0, 0, 0, 0 }
  -- every heading's label first (a heading's needle goes on with the label of the heading after it)
  local labs = {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level > 5 then error(C.tag .. ": headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then in_arg = norm(stringify(b.content)) == "argument" end
      if b.level > 1 then labs[i] = label(b.level, counts[b.level], in_arg) end
    end
  end
  in_arg = false
  local h_n = 0
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = stringify(b.content)
      if b.level == 1 then
        in_arg = norm(text) == "argument"
        titles[#titles + 1] = text
      end
      if text:lower():find("standard of review", 1, true) then any_sor = true end
      local lab = labs[i]
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "B", (lab or "") .. text, next_text(doc.blocks, labs, i))
      if b.level <= TOC_DEPTH then
        local point = in_arg and b.level == 2
        items[#items + 1] = { id = id, level = b.level, label = lab, content = b.content,
          ind = (b.level == 1 or point) and 0 or label_indent(b.level, in_arg) }
      end
      local x = heading_xml(b.level, b.content, lab, in_arg)
      -- the body opens a section (a new page): Word keeps space above there, typst drops it at the top of a page
      if #body == 0 then x = x:gsub('w:before="%d+"', 'w:before="0"', 1) end
      body[#body + 1] = raw(x)
    else
      scan_blocks({ b }, false)
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
  end
  check_structure(titles)
  if C.standard_of_review and not any_sor then
    error(C.tag .. ": no heading names the standard of review (Rule 24(a), Argument)")
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error(C.tag .. ": link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  body = strip_links(body)
  -- the signature block never stands alone: the last paragraph is kept with it (typst: one unbreakable block)
  local last = body[#body]
  if last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrNone"))

  -- Section 2: the index and the authorities (i, ii ...)
  add(raw(section_heading("Index of Brief", true)))
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, 0, 20), jc("right") }, runs("Page", { b = true, u = true }))))
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Cases, Statutes, and Other Authorities", true, true)))
  add(raw(toa_rows(authorities)))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...), the signature and the certificates
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(raw(certificate(C.comp_heading, runs(C.comp_text(words), {}), meta)))
  local svc = meta.service
  if svc.certificate == true or (svc.certificate ~= nil and stringify(svc.certificate) == "true") then
    add(raw(certificate("Certificate of Filing and Service",
      runs("I certify that a copy of the foregoing was electronically filed with the Court and electronically served on ", {})
        .. inl(svc["served-on"], {}) .. runs(" on ", {}) .. inl(meta.date, {}) .. runs(".", {}), meta)))
  end
  return pandoc.Pandoc(out, {})
end
