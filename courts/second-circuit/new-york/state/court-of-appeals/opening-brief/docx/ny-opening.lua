-- New York Court of Appeals opening brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document in the
-- form of typst/ny-opening-brief.typ, on the styles of docx/reference.xml (fb render builds reference.docx). pandoc
-- writes the body text (paragraphs, quotations, lists, footnotes); this filter writes what needs Word formatting:
--   * the cover (500.13(b)), the disclosure statement (500.1(f)), the statement of related litigation (500.13(a)),
--     the table of contents, the table of authorities, the signature block, the certificate of compliance and the
--     affidavit of service, as paragraphs with explicit spacing, indents and tabs;
--   * the heading labels (I., A., 1., a.) and each heading's outline level;
--   * the pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of
--     every heading and citation in that PDF (the needles this filter writes), and renders again with those pages;
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1, 2 ...). fb render writes the footers; this filter writes the last section (FORMBOOK_FINAL).
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the shared Word model lib/docx/xengine.lua, exact line
-- spacing throughout (Word sets each line in a box of that height, the baseline at 0.8 of it), the typst template's
-- pitches and spaces in twips (20 x pt). Word may paginate slightly differently from the LibreOffice PDF the page
-- numbers come from (docs/DOCX.md). An addendum (500.1(h)) is set by the typst engine only (../README.md).
-- Nothing here is case-specific.

local LIMIT = 14000    -- 500.13(c)(1)
local FACE = "Times New Roman" -- the typst template's face (reference.docx sets it; the certificate names it)
local TOC_DEPTH = 4    -- heading levels listed in the table of contents (typst: toc-depth)
local PASSIM = 7       -- typst passim-threshold
local TAB = 720        -- half an inch (para-indent, heading-tab), in twips
local TEXT_W = 9360    -- the text width, 6.5 in
local TAB_R = 9360     -- the right tab of the tables: at the margin
local PNUM_TOC = 720   -- typst toc-col (36 pt)
local PNUM_TOA = 1120  -- typst toa-col (56 pt)
local HALF_W = 4680    -- typst half-width (3.25 in)
local ARG_COL = 4464   -- typst arg-col (3.1 in)
local SINGLE = 400     -- typst pitch-single (20 pt)
local DOUBLE = 628     -- typst pitch-double (31.4 pt)
local NEEDLE_MAX = 60
-- typst blanks (underscores)
local BLANK = { by = 22, long = 26, mid = 16, day = 8, year = 4 }
local SS_COL = 4320    -- typst ss-col (3 in)

local stringify = pandoc.utils.stringify
local xe = require("docx.xengine")
local para, raw, style, ind, jc = xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, LINES, BREAK, BR = xe.KEEP, xe.LINES, xe.BREAK, xe.BR

local function tw(pt) return math.floor(pt * 20 + 0.5) end
local function blank(n) return string.rep("_", n) end

-- ---------------------------------------------------------------------------
-- Break rules typst keeps (lib/typst/xengine.typ and the template) that LibreOffice does not
-- ---------------------------------------------------------------------------

-- No break inside a token of adjacent parentheses ("63(12)(a)"): a word joiner; a break after a slash before a
-- letter ("F/K/A"), as typst breaks there: a zero-width space.
local WJ, ZWSP = "\u{2060}", "\u{200B}"
local function fix_text(s)
  s = s:gsub("%)%(", ")" .. WJ .. "(")
  s = s:gsub("/(%a)", "/" .. ZWSP .. "%1")
  return s
end
-- A doubled section sign stays with its number (the template boxes "[§¶]+ \S+"; xe binds a single one).
local function bind_doubled(l)
  local out = pandoc.Inlines({})
  for i, el in ipairs(l) do
    local prev = l[i - 1]
    if el.t == "Space" and prev and prev.t == "Str" and prev.text:match("[\u{00A7}\u{00B6}]$") then
      out:insert(pandoc.Str("\u{00A0}"))
    else
      out:insert(el)
    end
  end
  return out
end
local function fix_inlines(l)
  l = bind_doubled(l)
  return l:walk({ Str = function(el) el.text = fix_text(el.text); return el end })
end
local function runs(text, o) return xe.runs(fix_text(text), o) end
local function inl(x, o)
  if type(x) == "string" then return runs(x, o) end
  if x ~= nil and type(x) == "table" and x.walk then x = fix_inlines(x) end
  return xe.inl(x, o)
end
local function upper_inlines(l)
  return pandoc.Inlines(l):walk({ Str = function(el) el.text = el.text:upper(); return el end })
end

local function spacing(before, after, line) return xe.spacing(before, after, line or SINGLE) end

-- typst line-par: one single-spaced paragraph
local function line_par(x, before, align, left, keep)
  return para({ keep or KEEP, spacing(before or 0, 0), ind(left or 0, nil, 0), align and jc(align) or "" }, x)
end

-- A double-spaced paragraph, the first line indented (500.1(l)).
local function text_para(x, keep)
  return para({ keep or "", spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, x)
end

-- A borderless one-row table of columns `gutter` apart; `cols` are lists of paragraph XML, `widths` in twips
-- (the last column takes the rest).
local function columns(widths, gutter, cols)
  local grid, cells = {}, {}
  for i, w in ipairs(widths) do
    local right = i < #widths and gutter or 0
    grid[#grid + 1] = '<w:gridCol w:w="' .. (w + right) .. '"/>'
    local x = table.concat(cols[i] or {})
    if x == "" then x = para({ spacing(0, 0) }, "") end
    cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. (w + right) .. '" w:type="dxa"/><w:tcMar><w:left w:w="0" w:type="dxa"/>'
      .. '<w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. x .. "</w:tc>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>'
    .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

-- equal columns over the text width
local function equal(n, gutter)
  local w = (TEXT_W - (n - 1) * gutter) // n
  local ws = {}
  for i = 1, n do ws[i] = w end
  return ws
end

-- The space above a table: an empty paragraph 1 pt high, the rest of the space above it.
local function space_above(t)
  return para({ KEEP, spacing(math.max(0, t - 20), 0, 20) }, "")
end

-- A section's properties: its footer (rIdFtrNone or rIdFtrPage, written by fb render), page number format and
-- start, letter paper with one-inch margins (500.1(l)).
local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="628" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section and carries its properties (1 pt high: it must not push a full page's last line on).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

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

local function need_meta(meta, k)
  if meta[k] == nil then error("ny-opening: missing required metadata field `" .. k .. "`", 0) end
  return meta[k]
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render (docxpages.rs) normalizes the PDF text the same way.
local function norm(s) return (s:lower():gsub("[^a-z0-9]", "")) end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order), N (inside a footnote).
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
-- Words (500.13(c)): the typst template's count of the markdown source, so both engines certify the same number
-- ---------------------------------------------------------------------------

local function count_md(md)
  md = md:gsub("<!%-%-.-%-%->", " ")
  local lines = {}
  for line in (md .. "\n"):gmatch("(.-)\r?\n") do
    line = line:gsub("^%[%^[^%]]+%]:", " ")       -- footnote definition labels
    line = line:gsub("^#+[ \t]+", "")             -- heading markers
    line = line:gsub("^>[ \t]?", "")              -- quotation markers
    line = line:gsub("^[ \t]*[-*+][ \t]+", "")    -- list markers are not words
    line = line:gsub("^[ \t]*%d+[.)][ \t]+", "")
    lines[#lines + 1] = line
  end
  local s = table.concat(lines, "\n")
  s = s:gsub("%[%^[^%]]+%]", "")                 -- footnote references
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")      -- links keep their text
  s = s:gsub("\\(.)", "%1")
  s = s:gsub("%*", "")
  local n = 0
  for w in s:gmatch("%S+") do
    if w:gsub("_", "") ~= "" then n = n + 1 end
  end
  return n
end

-- typst without-section: the level-1 section headed `title` (case-insensitive) removed
local function without_section(md, title)
  local text = "\n" .. md
  local heads = {}
  for s, name in text:gmatch("\n()#[ \t]+([^\n]*)") do heads[#heads + 1] = { s = s, name = name } end
  for i, h in ipairs(heads) do
    if h.name:lower():gsub("%s+$", "") == title then
      local stop = heads[i + 1] and heads[i + 1].s or #text + 1
      return (text:sub(1, h.s - 1) .. text:sub(stop)):sub(2)
    end
  end
  return md
end

-- The markdown body of the input file (the frontmatter dropped), up to an "# Addendum" heading.
local function source_body()
  local f = PANDOC_STATE.input_files[1] and io.open(PANDOC_STATE.input_files[1], "r")
  if not f then error("ny-opening: cannot read the input file to count its words", 0) end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if e then src = src:sub(e + 1) end
  local a = ("\n" .. src):find("\n#[ \t]+[Aa][Dd][Dd][Ee][Nn][Dd][Uu][Mm][ \t]*\r?\n")
  return src, a ~= nil
end

-- Whether the typst template keeps the brief's last paragraph with the signature block: the last markdown block that
-- is not a footnote definition is not a heading.
local function keep_last(src)
  local parts = {}
  local text = src:gsub("%s+$", "") .. "\n\n"
  for p in text:gmatch("(.-)\n[ \t]*\n") do parts[#parts + 1] = p end
  local k = #parts
  while k > 1 and parts[k]:sub(1, 2) == "[^" do k = k - 1 end
  return k > 0 and parts[k]:sub(1, 1) ~= "#"
end

-- ---------------------------------------------------------------------------
-- Headings
-- ---------------------------------------------------------------------------

local function label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return n .. "." end
  return string.char(96 + n) .. "."
end

-- typst style-heading: the space above and below each kind of heading, in twips (21 / 15.4, 16.8 / 12.6,
-- 15.4 / 12.6 pt).
local SPACE = { section = { 420, 308 }, plain = { 336, 252 }, sub = { 308, 252 } }

-- A section heading (level 1, the front pages, the certificates): bold capitals, centred.
-- `top`: the heading opens a page (no space above); `brk`: it also breaks the page; `plain`: not an outline entry.
local function section_heading(text, top, brk, plain)
  return para({ plain and "" or style("Heading1"), KEEP, brk and BREAK or "",
    spacing(top and 0 or SPACE.section[1], SPACE.section[2]), ind(0, nil, 0), jc("center") },
    runs(text:upper(), { b = true }))
end

-- A body heading: level 1 as a section heading; a numbered heading with its label in a half-inch box at the level's
-- indent, the text hanging after it (capitals at level 2, bold italic from level 4).
local function heading_xml(level, content, lab)
  if level == 1 then
    return para({ style("Heading1"), KEEP, spacing(SPACE.section[1], SPACE.section[2]), ind(0, nil, 0), jc("center") },
      inl(upper_inlines(content), { b = true }))
  end
  local k = level - 2
  local o = { b = true, i = level >= 4 }
  local text = level == 2 and upper_inlines(content) or content
  return para({ style("Heading" .. math.min(level, 5)), KEEP,
    '<w:tabs><w:tab w:val="left" w:pos="' .. (TAB * (k + 1)) .. '"/></w:tabs>',
    spacing(SPACE.sub[1], SPACE.sub[2]), ind(TAB * (k + 1), TAB), jc("left") },
    runs(lab .. "\t", o) .. inl(text, o))
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities
-- ---------------------------------------------------------------------------

-- Before the leader tab of a table row (typst listing-row: the text and 0.75 em must fit before the page column).
-- LibreOffice keeps the last word on the line only if the no-break spaces before the right tab and another third of
-- their em fit before the right indent: two no-break spaces at 12.5 pt (2 x 0.25 + 1/3 of 12.5 pt = 10.4 pt) stand for
-- typst's 10.5 pt. They keep the leader off the last word and go with it when it wraps.
local LEAD = '<w:r><w:rPr><w:sz w:val="25"/><w:szCs w:val="25"/></w:rPr><w:t xml:space="preserve">\u{00A0}\u{00A0}</w:t></w:r><w:r><w:tab/></w:r>'

-- One row of the table of contents (typst toc-entry on listing-row).
local function toc_row(item)
  local left = TAB * item.step + TAB
  local lead = item.label and runs(item.label .. "\t", {}) or ""
  return para({ LINES, xe.leader_tab(TAB_R), spacing(item.level == 1 and 168 or 98, 0), ind(left, TAB, nil, PNUM_TOC) },
    lead .. inl(item.content, {}) .. LEAD .. runs(label_of(item.id), {}))
end

local GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local occurrences = {} -- the authority links, in document order: { key, index }

-- Sort key as typst's: the sort field, or the name and citation, lower case, letters, digits and spaces only.
local function sort_key(a)
  local s = a.sort and stringify(a.sort) or (stringify(a.name or "") .. " " .. stringify(a.cite))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
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
      -- the group title; the first one carries the column heading "Page(s)" at the right margin
      local head = runs(g[2], { b = true })
      if #out == 0 then head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para({ KEEP, '<w:tabs><w:tab w:val="right" w:pos="' .. TAB_R .. '"/></w:tabs>',
        spacing(#out == 0 and 280 or 392, 56) }, head)
      for _, m in ipairs(members) do
        -- the distinct pages of the authority, in document order
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local lab = l and l.label or ("00" .. o.index)
            if not seen[lab] then
              seen[lab] = true
              pages[#pages + 1] = l and l.label or "00"
            end
          end
        end
        local list, list_w = nil, 0
        if #pages >= PASSIM then
          list = runs("passim", { i = true })
        else
          local s = table.concat(pages, ", ")
          list = runs(s, {})
          -- a list wider than the column widens the column (typst: the larger of 56 pt and the list): digits are
          -- 0.5 em in Times New Roman (140 twips at 14 pt), a comma and the space 0.25 em
          for c in s:gmatch(".") do list_w = list_w + (c:match("%d") and 140 or 70) end
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = stringify(m.a.kind) == "case" }) .. runs(",", {}) .. BR
        end
        out[#out + 1] = para({ LINES, xe.leader_tab(TAB_R), spacing(196, 0), ind(504, 504, nil, math.max(PNUM_TOA, list_w)) },
          name .. inl(m.a.cite, {}) .. LEAD .. list)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover-body)
-- ---------------------------------------------------------------------------

-- A rule on the cover: an empty paragraph with a bottom border, `left_right` in from both margins (the 2 in rule).
local function rule(kind, before, left_right)
  local b = kind == "double"
      and '<w:pBdr><w:bottom w:val="thickThinSmallGap" w:sz="12" w:space="1" w:color="000000"/></w:pBdr>'
      or '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
  -- a 1 pt line: the border below it takes the rest of the rule's height (typst: 4.6 pt double, 0.7 pt single)
  local up = kind == "double" and 60 or 0
  return para({ KEEP, b, spacing(math.max(0, before - up), 0, 20), ind(left_right or 0, nil, nil, left_right or 0) }, "")
end

-- The height of cover paragraphs, estimated (twips): the space above and the lines of each, a line holding about
-- (width / 150 twips) characters (0.54 em at 14 pt: a little wider than the average letter, so the estimate is safe).
local function height(xml, width)
  local h = 0
  for p in xml:gmatch("<w:p>.-</w:p>") do
    local before = tonumber(p:match('w:before="(%d+)"') or "0")
    local line = tonumber(p:match('w:line="(%d+)"') or tostring(SINGLE))
    local left = tonumber(p:match('w:left="(%d+)"') or "0")
    local right = tonumber(p:match('w:right="(%d+)"') or "0")
    local text = ""
    for t in p:gmatch("<w:t[^>]*>([^<]*)</w:t>") do text = text .. t end
    local n = text == "" and 1 or math.max(1, math.ceil(utf8.len(text) * 150 / (width - left - right)))
    h = h + before + n * line
  end
  return h
end

local function cover_body(meta, gap)
  local out, h = {}, 0
  local function add(x, hh)
    out[#out + 1] = x
    h = h + (hh or height(x, TEXT_W))
  end
  local function c(x, before) add(line_par(x, before or 0, "center")) end
  local function tbl(widths, gutter, cols, before)
    add(space_above(before), math.max(before, 20))
    local hh = 0
    for i, col in ipairs(cols) do hh = math.max(hh, height(table.concat(col), widths[i])) end
    add(columns(widths, gutter, cols), hh)
  end
  -- docket on the left, the argument request in the upper right corner (500.13(b))
  local arg = need_meta(meta, "argument")
  local left = { line_par(inl(need_meta(meta, "docket"), {}), 0, nil, 0, LINES) }
  if meta.county_clerk_index then left[#left + 1] = line_par(inl(meta.county_clerk_index, {}), 0, nil, 0, LINES) end
  local right = {}
  if arg.presenter then
    right[#right + 1] = line_par(runs("To be Argued by:", {}), 0, nil, 0, LINES)
    right[#right + 1] = line_par(inl(upper_inlines(arg.presenter), { b = true }), 0, nil, 0, LINES)
    right[#right + 1] = line_par(runs("(Time Requested: ", {}) .. inl(arg.time_requested, {}) .. runs(")", {}), 0, nil, 0, LINES)
  else
    right[#right + 1] = line_par(runs("Submitted without oral argument", {}), 0, nil, 0, LINES)
  end
  add(columns({ TEXT_W - ARG_COL - 432, ARG_COL }, 432, { left, right }),
    math.max(height(table.concat(left), TEXT_W - ARG_COL - 432), height(table.concat(right), ARG_COL)))
  c(runs("Court of Appeals of the State of New York", { b = true }), gap)
  add(rule("double", gap))
  local sides = need_meta(meta, "caption")
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do
      c(inl(n, {}), k > 1 and 98 or (i == 1 and gap or gap * 3 // 10))
    end
    add(line_par(inl(side.designation, {}), 98, nil, HALF_W))
    if i < #sides then c(runs("\u{2013} against \u{2013}", {}), gap * 3 // 10) end
  end
  add(rule("double", gap))
  c(inl(upper_inlines(need_meta(meta, "brief_title")), { b = true }), gap)
  add(rule("short", gap, 3240))
  -- counsel: name, office address, telephone and facsimile (500.13(b)), side by side
  local cols = {}
  for _, g in ipairs(need_meta(meta, "counsel")) do
    local col = { line_par(inl(upper_inlines(g.firm), { b = true }), 0, nil, 0, LINES) }
    for _, l in ipairs(g.lines or {}) do col[#col + 1] = line_par(inl(l, { i = true }), 0, nil, 0, LINES) end
    cols[#cols + 1] = col
  end
  tbl(equal(#cols, 576), 576, cols, gap)
  c(inl(need_meta(meta, "attorneys_for"), { i = true }), gap // 2)
  c(runs("Date Completed: ", {}) .. inl(need_meta(meta, "date_completed"), {}), gap)
  add(rule("double", gap))
  return out, h
end

-- typst cover-estimate, on the frontmatter as written ($FORMBOOK_META), in pt: the cover's height at a gap.
local function read_file(path)
  if not path or path == "" then return nil end
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function cover_estimate(gap)
  local w, pitch = 468, 20
  local function lines(s, col)
    local width = 0
    for _, cp in utf8.codes(tostring(s)) do
      width = width + (cp == 32 and 0.25 or (cp >= 65 and cp <= 90) and 0.66 or 0.47)
    end
    return math.max(1, math.ceil(width * 14 / (col * 0.97)))
  end
  local function col_lines(ls, col)
    local n = 0
    for _, l in ipairs(ls) do n = n + lines(l, col) end
    return n
  end
  local arg = RAW.argument or {}
  local half = w - 223.2 - 21.6
  local docket = { RAW.docket }
  if RAW.county_clerk_index then docket[#docket + 1] = RAW.county_clerk_index end
  local args = arg.presenter and { "To be Argued by:", arg.presenter, "(Time Requested: " .. tostring(arg.time_requested) .. ")" }
    or { "Submitted without oral argument" }
  local h = math.max(col_lines(docket, half), col_lines(args, 223.2)) * pitch
  h = h + gap + lines("Court of Appeals of the State of New York", w) * pitch
  h = h + gap + 7
  local sides = RAW.caption or {}
  for i, side in ipairs(sides) do
    for k, n in ipairs(side.names) do
      h = h + (k > 1 and 4.9 or (i == 1 and gap or gap * 0.3)) + lines(n, w) * pitch
    end
    h = h + 4.9 + lines(side.designation, w - 234) * pitch
    if i < #sides then h = h + gap * 0.3 + pitch end
  end
  h = h + gap + 7
  h = h + gap + lines(tostring(RAW.brief_title):upper(), w) * pitch
  h = h + gap + 3
  local groups = RAW.counsel or {}
  local cw = (w - (#groups - 1) * 28.8) / #groups
  local m = 0
  for _, g in ipairs(groups) do m = math.max(m, lines(tostring(g.firm):upper(), cw) + col_lines(g.lines or {}, cw)) end
  h = h + gap + m * pitch
  h = h + gap * 0.5 + lines(RAW.attorneys_for, w) * pitch
  h = h + gap + lines("Date Completed: " .. tostring(RAW.date_completed), w) * pitch
  return h + gap + 7
end

-- The cover is one page (typst cover: the largest of 1, 0.8, 0.6 ... em between its parts at which the estimate
-- fits the 9 in of the page).
local function cover(meta)
  for _, g in ipairs({ 1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0 }) do
    if cover_estimate(g * 14) <= 648 or g == 0 then return table.concat((cover_body(meta, tw(g * 14)))) end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates
-- ---------------------------------------------------------------------------

local function signature_block(meta, address)
  local sig = need_meta(meta, "signature")
  local out = {}
  out[#out + 1] = line_par(runs("Dated: ", {}) .. inl(sig.place, {}), 392)
  out[#out + 1] = line_par(inl(sig.date, {}))
  local cols = {}
  for bi, b in ipairs(sig.blocks) do
    local col = { line_par(inl(upper_inlines(b.firm), { b = true }), 0, nil, 0, LINES) }
    if bi == 1 then col[#col + 1] = line_par(runs("By: " .. blank(BLANK.by), {}), 0, nil, 0, LINES) end
    for _, n in ipairs(b.names or {}) do col[#col + 1] = line_par(inl(n, {}), 0, nil, 0, LINES) end
    if address then
      for _, l in ipairs(b.lines or {}) do col[#col + 1] = line_par(inl(l, { i = true }), 0, nil, 0, LINES) end
    end
    cols[#cols + 1] = col
  end
  out[#out + 1] = space_above(336)
  out[#out + 1] = columns(equal(#cols, 576), 576, cols)
  out[#out + 1] = line_par(inl(sig.attorneys_for, { i = true }), 168, nil, 0, LINES)
  return table.concat(out)
end

-- the certificate of compliance (500.1(j) and 500.13(c)(1)): one block, kept on one page
local function certificate_of_compliance(meta, words)
  local wp = meta.word_processor and inl(meta.word_processor, {}) or runs("a word-processing system", {})
  local out = { section_heading("Certificate of Compliance", true, true, true) }
  out[#out + 1] = text_para(runs("I hereby certify pursuant to 22 NYCRR 500.1(j) that the foregoing brief was prepared on a computer using ", {})
    .. wp .. runs(".", {}), KEEP)
  out[#out + 1] = text_para(runs("A proportionally spaced typeface was used, as follows:", {}), KEEP)
  out[#out + 1] = line_par(runs("Name of typeface: " .. FACE, {}), 224, nil, TAB)
  out[#out + 1] = line_par(runs("Point size: 14", {}), 0, nil, TAB)
  out[#out + 1] = line_par(runs("Line spacing: Double", {}), 0, nil, TAB)
  out[#out + 1] = para({ KEEP, spacing(224, 0, DOUBLE), ind(0, nil, TAB) },
    runs("Word Count.", { b = true }) .. runs(" The total number of words in this brief, inclusive of point headings and footnotes and exclusive of pages containing the table of contents, table of citations, proof of service, certificate of compliance, corporate disclosure statement, questions presented, statement of related litigation, or any authorized addendum containing statutes, rules, regulations, etc., is " .. group_digits(words) .. ".", {}))
  out[#out + 1] = signature_block(meta, false)
  return table.concat(out)
end

-- the affidavit of service (500.1(e)): blanks only
local function affidavit_of_service()
  local out = { section_heading("Affidavit of Service", true, true, true) }
  local tab = '<w:tabs><w:tab w:val="left" w:pos="' .. SS_COL .. '"/></w:tabs>'
  local function venue(l, r) out[#out + 1] = para({ KEEP, tab, spacing(0, 0), ind(0, nil, 0) }, runs(l .. "\t" .. r, {})) end
  venue("STATE OF NEW YORK", ")")
  venue("", ") ss.:")
  venue("COUNTY OF " .. blank(BLANK.mid), ")")
  out[#out + 1] = para({ spacing(336, 0, DOUBLE), ind(0, nil, TAB) }, runs(blank(BLANK.long) ..
    ", being duly sworn, deposes and says: deponent is not a party to this action, is over 18 years of age, and resides at " ..
    blank(BLANK.long) .. ".", {}))
  out[#out + 1] = text_para(runs("On the " .. blank(BLANK.day) .. " day of " .. blank(BLANK.day) .. ", 20" .. blank(BLANK.year) ..
    ", deponent served the within brief upon each attorney for each party to this appeal, at the address designated by that attorney for that purpose, by " ..
    blank(BLANK.mid) .. ", and by " .. blank(BLANK.mid) .. ".", {}))
  out[#out + 1] = line_par(runs(blank(BLANK.long), {}), 504, nil, HALF_W)
  out[#out + 1] = line_par(runs("Sworn to before me this", {}), 0, nil, HALF_W)
  out[#out + 1] = line_par(runs(blank(BLANK.day) .. " day of " .. blank(BLANK.day) .. ", 20" .. blank(BLANK.year), {}), 0, nil, HALF_W)
  out[#out + 1] = line_par(runs(blank(BLANK.long), {}), 336, nil, HALF_W)
  out[#out + 1] = line_par(runs("Notary Public", {}), 0, nil, HALF_W, LINES)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Citations, in document order (the needles of the table of authorities)
-- ---------------------------------------------------------------------------

local scan_blocks

local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local key = el.target:sub(5)
      occurrences[#occurrences + 1] = { key = key, index = #occurrences + 1 }
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
    elseif b.t == "BlockQuote" or b.t == "Div" then
      scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

local function strip_links(blocks)
  return pandoc.Pandoc(blocks):walk({
    Link = function(el) return el.content end,
    Inlines = function(l) return fix_inlines(xe.inlines(l)) end,
  }).blocks
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
  for _, k in ipairs({ "docket", "argument", "caption", "brief_title", "counsel", "attorneys_for",
                       "date_completed", "signature", "related_litigation" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  local src, has_addendum = source_body()
  if has_addendum then
    error("ny-opening: an addendum (500.1(h)) is set by the typst engine only (see ../README.md)", 0)
  end
  local words = count_md(without_section(src, "questions presented"))
  if words > LIMIT then
    error("ny-opening: the brief has " .. words .. " words; 22 NYCRR 500.13(c)(1) allows " .. LIMIT, 0)
  end

  -- front matter needles: the disclosure heading (an outline entry), then the tables (they move the search past the
  -- contents)
  local disclosure = meta.disclosure
  local dblocks
  if disclosure then
    dblocks = pandoc.utils.type(disclosure) == "Blocks" and disclosure or pandoc.Blocks({ pandoc.Para(pandoc.Inlines(disclosure)) })
    need("S:disc", "B", "Disclosure Statement Pursuant to Section 500.1(f) of the Rules of the Court of Appeals",
      stringify(dblocks):sub(1, 40))
  end
  need("S:rel", "B", "Statement of Related Litigation", stringify(meta.related_litigation):sub(1, 40))
  need("S:toc", "B", "Table of Contents", "Page")
  need("S:toa", "B", "Table of Authorities", "")

  -- the body: headings (labels, outline, needles, contents entries) and citations (needles)
  local blocks = doc.blocks
  local headings, body = {}, {}
  local c = { 0, 0, 0, 0, 0, 0 }
  local printed, labs = {}, {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level > 5 then error("ny-opening: headings deeper than level 5 are not supported", 0) end
      c[b.level] = c[b.level] + 1
      for k = b.level + 1, 6 do c[k] = 0 end
      labs[i] = b.level == 1 and "" or label(b.level, c[b.level])
      printed[i] = labs[i] .. " " .. stringify(b.content)
    end
  end
  local hn = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      hn = hn + 1
      local id = "H:" .. hn
      local nb = blocks[i + 1]
      local nxt = nb and (printed[i + 1] or stringify(nb)):sub(1, 40) or ""
      need(id, "B", labs[i] .. " " .. stringify(b.content), nxt)
      if b.level <= TOC_DEPTH then
        local title = (b.level <= 2) and upper_inlines(b.content) or b.content
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and labs[i] or nil,
          content = title, step = b.level == 1 and 0 or (b.level - 2) }
      end
      local x = heading_xml(b.level, b.content, labs[i])
      -- the body opens a section (a new page): Word keeps space above there, typst drops it at the top of a page
      if #body == 0 then x = x:gsub('w:before="%d+"', 'w:before="0"', 1) end
      body[#body + 1] = raw(x)
    else
      scan_blocks({ b }, false)
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    end
  end
  for _, o in ipairs(occurrences) do
    if not authorities[o.key] then
      error("ny-opening: link `toa:" .. o.key .. "` has no entry under `authorities:` in the frontmatter", 0)
    end
  end
  -- the table of authorities' needle goes on with its first group title
  for _, g in ipairs(GROUPS) do
    local used = false
    for _, o in ipairs(occurrences) do
      local a = authorities[o.key]
      if a and a.kind and stringify(a.kind) == g[1] then used = true end
    end
    if used then
      for _, nd in ipairs(needles) do
        if nd.id == "S:toa" then nd.needle = norm("Table of Authorities " .. g[2]):sub(1, NEEDLE_MAX) end
      end
      break
    end
  end
  body = strip_links(body)
  -- typst moves the line that holds a footnote reference to the next page with its note, even when that leaves it a
  -- widow: a paragraph with a footnote has no widow control (style Body Text Note, docx/reference.xml)
  for i, b in ipairs(body) do
    if b.t == "Para" and has_note(b) then body[i] = pandoc.Div({ b }, { ["custom-style"] = "Body Text Note" }) end
  end
  -- The last paragraph is not broken and stays with the signature block (typst: one unbreakable block, unless the
  -- brief's last markdown block is a heading).
  local last = body[#body]
  if keep_last(src) and last and last.t == "Para" and not has_note(last) then
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end

  local nl = {}
  for _, nd in ipairs(needles) do nl[#nl + 1] = table.concat({ nd.id, nd.kind, nd.needle, nd.fallback }, "\t") end
  nl[#nl + 1] = "#section\t" .. (disclosure and "S:disc" or "S:rel") .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = type(x) == "string" and raw(x) or x end

  -- section 1: the cover (no page number)
  add(cover(meta))
  add(section("rIdFtrNone"))

  -- section 2: the front matter (i, ii ...): disclosure, related litigation, contents, authorities
  if disclosure then
    add(section_heading("Disclosure Statement Pursuant to Section 500.1(f) of the Rules of the Court of Appeals", true, false, false))
    local db = pandoc.Pandoc(dblocks):walk({ Inlines = function(l) return fix_inlines(xe.inlines(l)) end }).blocks
    for _, b in ipairs(db) do
      for _, x in ipairs(xe.list_items(b)) do add(x) end
    end
  end
  add(section_heading("Statement of Related Litigation", not disclosure, false, true))
  add(text_para(inl(meta.related_litigation, {})))
  add(section_heading("Table of Contents", true, true, true))
  add(para({ KEEP, spacing(84, 0), ind(0, nil, 0, 20), jc("right") }, runs("Page", { b = true, u = true })))
  local items = {}
  if disclosure then
    items[#items + 1] = { id = "S:disc", level = 1, step = 0,
      content = pandoc.Inlines({ pandoc.Str("DISCLOSURE STATEMENT PURSUANT TO SECTION 500.1(F) OF THE RULES OF THE COURT OF APPEALS") }) }
  end
  for _, h in ipairs(headings) do items[#items + 1] = h end
  for _, it in ipairs(items) do add(toc_row(it)) end
  add(section_heading("Table of Authorities", true, true, true))
  add(toa_rows(authorities))
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- section 3: the body (1, 2 ...), the signature, and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(signature_block(meta, true))
  add(certificate_of_compliance(meta, words))
  add(affidavit_of_service())

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
