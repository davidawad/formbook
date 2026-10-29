-- ca11.lua (docx engine): the ca11 opening brief as Word paragraphs and sections (typst: ca11-opening-brief.typ).
-- pandoc writes the body text with the reference document fb render builds from docx/reference.xml; this filter
-- writes what Word needs formatting for:
--   * the cover, the Certificate of Interested Persons, the statement on oral argument, the tables, the certificates
--     and the signature blocks, as paragraphs with explicit spacing, indents and tabs;
--   * the heading labels (I., A., 1., a., (1)) and the outline level of each heading;
--   * the table of contents and the table of citations: their entries and page numbers. fb render renders the
--     document once, finds the page of every heading and citation in the PDF (the needles this filter writes,
--     tools/fb/src/docxpages.rs), and renders again with those pages (the pages file this filter reads);
--   * the sections whose footers number the pages: cover (none), Certificate of Interested Persons (C-1 ...),
--     front matter (i, ii ...), body and certificates (1 ...). fb render adds the
--     footers this filter lists.
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every line and page breaks where the typst render
-- breaks it. The model is lib/docx/xengine.lua (the break rules of typst on every run, exact line spacing: each line
-- a box of its pitch, the space between paragraphs the larger of the two); the pitches and spaces below are the
-- typst template's, in twips (20 x pt).

local TOC_DEPTH = 4     -- heading levels listed in the table of contents (typst: toc-depth)
local LIMIT = 13000     -- FRAP 32(a)(7)(B)(i)
local TAB = 720         -- half an inch, in twips
local TEXT_W = 9360     -- the text width, 6.5 in
local HALF_W = 4680     -- the middle of the page: the caption and the counsel block start here
local STEP = 140        -- 0.5 em: the counsel's lines step in under the name (typst: h(0.5em))
local DOUBLE = 628      -- typst pitch-double: 31.4 pt (11th Cir. R. 32-3, double spacing)
local SINGLE = 400      -- typst pitch-single: 20 pt (headings, quotations, footnotes, cover, signature)
local TOC_COL = 728     -- typst toc-page-col: 36.4 pt kept for the contents' page numbers
local TOA_COL = 1120    -- typst toa-page-col: 56 pt (a longer page list widens its own row's column)
local NEEDLE_MAX = 80   -- a needle is a prefix of the text: it must fit on one page
local DATE = ""         -- the date of the brief, set from the frontmatter by Pandoc()

local stringify = pandoc.utils.stringify

-- ---------------------------------------------------------------------------
-- XML helpers: the shared ones of the cross-engine layout model (lib/docx/xengine.lua)
-- ---------------------------------------------------------------------------

local xe = require("docx.xengine")
local runs, inl, para, raw, ind, jc = xe.runs, xe.inl, xe.para, xe.raw, xe.ind, xe.jc
local KEEP, LINES, BREAK, BR, LEAD = xe.KEEP, xe.LINES, xe.BREAK, xe.BR, xe.LEAD

-- Exact line spacing; single-spaced unless another pitch is given.
local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

-- Tab stops: a left one for a label box (pos, or none) and the dot leader to the margin of a table row.
local function row_tabs(label_pos)
  local l = label_pos and ('<w:tab w:val="left" w:pos="' .. label_pos .. '"/>') or ""
  return '<w:tabs>' .. l .. '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/></w:tabs>'
end

-- A right-aligned tab with no leader (the "Page(s)" label).
local function right_tab()
  return '<w:tabs><w:tab w:val="right" w:pos="' .. TEXT_W .. '"/></w:tabs>'
end

-- The paragraph that ends a section: its sectPr is the section's (footer, page number format and start). It takes
-- a 1 pt line, or it would push a full page's last line on.
local function section(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="608" w:gutter="0"/>' .. pg .. "</w:sectPr></w:pPr></w:p>")
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- Inlines in capitals (typst: upper).
local function upper_il(il)
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(e.text:upper()) end }).content
end

-- The width of a page list in twips (Times New Roman advances at 14 pt): the authorities' page column is as wide as
-- a longer list (typst: calc.max(toa-page-col, measure(page-text).width)).
local ADV = { [","] = 512, [" "] = 512, ["*"] = 1024, ["-"] = 682, ["C"] = 1366, ["i"] = 569, ["v"] = 1024, ["x"] = 1024 }
local function list_width(s)
  local u = 0
  for c in s:gmatch(".") do u = u + (ADV[c] or 1024) end
  return math.ceil(u * 280 / 2048)
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

-- Letters and digits only, lower case: fb render normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {} -- { id, kind, needle, short, at }: `at` is the needle's place in the document (write_needles)
local function need(id, kind, text, short, at)
  local n = norm(text):sub(1, NEEDLE_MAX)
  if n ~= "" then
    needles[#needles + 1] = { id = id, kind = kind, needle = n, short = short and norm(short):sub(1, NEEDLE_MAX) or "",
      at = at, seq = #needles + 1 }
  end
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

-- The needles for fb render (tools/fb/src/docxpages.rs), in document order (fb finds each after the one before it),
-- and the sections that number the pages: `sections` is a list of { needle id, lower-roman|decimal, prefix }.
local function write_needles(sections)
  local path = os.getenv("FORMBOOK_NEEDLES")
  if not path then return end
  table.sort(needles, function(a, b)
    if a.at ~= b.at then return a.at < b.at end
    return a.seq < b.seq
  end)
  local f = assert(io.open(path, "w"))
  for _, n in ipairs(needles) do
    f:write(n.id, "\t", n.kind, "\t", n.needle, "\t", n.short, "\n")
  end
  for _, s in ipairs(sections) do
    f:write("#section\t", s[1], "\t", s[2], "\t", s[3] or "", "\n")
  end
  f:close()
end

-- The footers the sections name (centered in a 20 pt line: the cover's empty, the others the page number, "C-" before it
-- in the Certificate of Interested Persons) and the
-- last section (the certificates: the page number of the recipe's footer, continuing the body's numbers), for fb
-- render's $FORMBOOK_FOOTERS and $FORMBOOK_FINAL.
local PAGE = '<w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r>'
local function write_footers()
  local path, final = os.getenv("FORMBOOK_FOOTERS"), os.getenv("FORMBOOK_FINAL")
  if not path or not final then return end
  local function footer(runs_xml)
    return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact" />'
      .. '<w:jc w:val="center" /></w:pPr>' .. runs_xml .. '</w:p>'
  end
  local f = assert(io.open(path, "w"))
  f:write("rIdFtrCover\t", footer(""), "\n")
  f:write("rIdFtrCip\t", footer('<w:r><w:t xml:space="preserve">C-</w:t></w:r>' .. PAGE), "\n")
  f:write("rIdFtrFront\t", footer(PAGE), "\n")
  f:write("rIdFtrBody\t", footer(PAGE), "\n")
  f:write("rIdFtrEnd\t", '<w:p><w:pPr><w:jc w:val="center" /></w:pPr>' .. PAGE .. '</w:p>', "\n")
  f:close()
  f = assert(io.open(final, "w"))
  f:write('<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrEnd"/><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="608" '
    .. 'w:gutter="0"/></w:sectPr>')
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

-- A section heading (typst style-heading, level 1): bold capitals, centered, single-spaced, 21 pt above, 15.4 below;
-- one that opens a page has no space above (typst drops it there; Word keeps it after a page or section break).
local function section_heading(text, top, brk)
  local props = { KEEP }
  if brk then props[#props + 1] = BREAK end
  props[#props + 1] = spacing(top and 0 or 420, 308)
  props[#props + 1] = ind(0, nil, 0)
  props[#props + 1] = jc("center")
  return para(props, runs(text:upper(), { b = true }))
end

-- The XML of a body heading (typst: style-heading). Level 1 is centered and capitalized; in the Argument the level-2
-- point is centered (16.8 / 14 pt); the others hang under their label (15.4 / 12.6 pt), each level half an inch in.
local function heading_xml(level, content, lab, arg, top)
  if level == 1 then
    return para({ KEEP, spacing(top and 0 or 420, 308), ind(0, nil, 0), jc("center") },
      inl(upper_il(content), { b = true }))
  end
  if arg and level == 2 then
    return para({ KEEP, spacing(336, 280), ind(0, nil, 0), jc("center") },
      runs(lab .. " ", { b = true }) .. inl(upper_il(content), { b = true }))
  end
  local k = step(level, arg)
  local o = { b = true, i = level >= 4 }
  return para({ KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. TAB * (k + 1) .. '"/></w:tabs>', spacing(308, 252),
    ind(TAB * (k + 1), TAB) }, runs(lab .. "\t", o) .. inl(content, o))
end

-- One row of the table of contents (typst: toc-entry, listing-row): double-spaced; the label in a half-inch box,
-- the title hanging after it and wrapping before the page column, a dot leader to the page.
local function toc_row(item)
  local title = item.level == 1 and upper_il(item.title) or item.title
  local left = item.step * TAB
  local lead = item.label and runs(item.label .. "\t", {}) or ""
  return para({ LINES, row_tabs(item.label and left + TAB or nil), spacing(item.level == 1 and 168 or 0, 0, DOUBLE),
    ind(left + TAB, TAB, nil, TOC_COL) }, lead .. inl(title, {}) .. runs(LEAD .. label_of(item.id), {}))
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
        members[#members + 1] = { key = key, a = a, sort = base:lower():gsub("[^a-z0-9 ]", "") }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      -- the group's title, single-spaced: 14 pt (the first) or 19.6 pt above, 2.8 pt below; it stays with its entry
      local head = runs(g[2], { b = true })
      if first_group then
        head = head .. runs("\t", {}) .. runs("Page(s)", { b = true, u = true })
      end
      out[#out + 1] = para({ KEEP, right_tab(), spacing(first_group and 280 or 392, 56), ind(0, nil, 0) }, head)
      first_group = false
      for _, m in ipairs(members) do
        -- the distinct pages of the authority, in document order; a page is starred when a primary citation is on it
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
        local list = {}
        for _, p in ipairs(pages) do list[#list + 1] = (p.star and "*" or "") .. p.label end
        local page_text = table.concat(list, ", ")
        if first_needle == nil then
          first_needle = m.a.name and stringify(m.a.name) or stringify(m.a.cite)
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = g[1] == "case" }) .. runs(",", {}) .. BR
        end
        -- one double-spaced row (listing-row): 9.8 pt above, the citation hanging 0.35 in, the page column
        local col = math.max(TOA_COL, list_width(page_text))
        out[#out + 1] = para({ LINES, row_tabs(nil), spacing(196, 0, DOUBLE), ind(504, 504, nil, col) },
          name .. inl(m.a.cite, {}) .. runs(LEAD .. page_text, {}))
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

-- A 2 in rule between the cover's parts (typst short-rule), with 14 pt (1 em) on either side.
local function rule()
  return raw(para({ '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>',
    spacing(0, 280, 120), '<w:ind w:left="3240" w:right="3240"/>', jc("center") }, ""))
end

-- The cover: single-spaced, centered; 4.9 pt between paragraphs, 14 pt (1 em) between its parts.
local function cover(meta)
  local out = {}
  local function c(before, body, o)
    out[#out + 1] = raw(para({ spacing(before, 98), jc("center") }, body))
  end
  c(168, runs("Case No. ", { b = true }) .. inl(need_meta(meta, "case_number"), { b = true }))
  c(280, runs("In the United States Court of Appeals", { b = true }) .. BR .. runs("for the Eleventh Circuit", { b = true }))
  out[#out + 1] = rule()
  local sides = need_meta(meta, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do c(0, inl(name, {})) end
    out[#out + 1] = raw(para({ spacing(0, 98), ind(HALF_W) }, inl(side.designation, {})))
    if i < #sides then c(84, runs("v.", {})) end
  end
  out[#out + 1] = rule()
  c(0, inl(need_meta(meta, "proceeding"), {}))
  if meta.district_court_case then c(0, inl(meta.district_court_case, {})) end
  out[#out + 1] = rule()
  c(0, inl(upper_il(need_meta(meta, "brief_title")), { b = true }))
  out[#out + 1] = rule()
  -- counsel (FRAP 32(a)(2)(F)): the names, then the lines and the telephone 0.5 em in, from the middle of the page
  for gi, g in ipairs(need_meta(meta, "counsel")) do
    local first = true
    local function line(left, body)
      out[#out + 1] = raw(para({ KEEP, spacing(first and gi > 1 and 140 or 0, 0), ind(left) }, body))
      first = false
    end
    for _, n in ipairs(g.names or {}) do line(HALF_W, inl(n, {})) end
    for _, l in ipairs(g.lines or {}) do line(HALF_W + STEP, inl(l, { i = true })) end
    line(HALF_W + STEP, inl(need_meta(meta, "phone"), {}))
  end
  out[#out + 1] = raw(para({ spacing(168, 0), jc("center") }, inl(need_meta(meta, "role"), { i = true })))
  return out
end

-- typst: signature-block. Single-spaced, 19.6 pt above; the date line, then 16.8 pt below it the signer's lines
-- from the middle of the page. The lines stay together on one page.
local function signature(meta)
  local sig = need_meta(meta, "signature")
  local lines = { runs("/s/ " .. stringify(sig.signer), {}), runs(stringify(sig.signer), {}) }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = inl(l, { i = true }) end
  local out = { para({ KEEP, spacing(392, 0), ind(0, nil, 0) }, runs("Respectfully submitted this " .. DATE .. ".", {})) }
  for i, l in ipairs(lines) do
    out[#out + 1] = para({ i < #lines and KEEP or LINES, spacing(i == 1 and 336 or 0, 0), ind(HALF_W) }, l)
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

  -- Every citation in document order, as a needle for the page lookup of fb render: the link text and the words
  -- after it in its paragraph (up to a footnote, a quotation or another link), so that the same words elsewhere in
  -- the brief, unlinked, are not taken for it; its first words alone are the fallback. Kind B (body) moves the search
  -- on; N (in a footnote) is searched from the page the body has reached.
  local cites = {}
  local scan_blocks
  local function scan(inls, kind)
    for i, el in ipairs(inls) do
      if el.t == "Link" and el.target:match("^toa%*?:") then
        local rest = {}
        for j = i + 1, math.min(#inls, i + 12) do
          local t = inls[j].t
          if t == "Note" or t == "Quoted" or t == "Link" then break end
          rest[#rest + 1] = inls[j]
        end
        local lt = stringify(el.content)
        cites[#cites + 1] = { kind = kind, text = lt .. norm(stringify(pandoc.Inlines(rest))):sub(1, 16),
          short = norm(lt):sub(1, 24) }   -- its first words alone: a citation may run over a page end
      elseif el.t == "Note" then
        scan_blocks(el.content, "N")
      elseif el.content ~= nil and type(el.content) == "table" then
        scan(el.content, kind)
      end
    end
  end
  scan_blocks = function(bs, kind)
    for _, b in ipairs(bs) do
      if b.t == "Para" or b.t == "Plain" or b.t == "Header" then scan(b.content, kind)
      elseif b.t == "BlockQuote" or b.t == "Div" then scan_blocks(b.content, kind)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, it in ipairs(b.content) do scan_blocks(it, kind) end
      end
    end
  end
  scan_blocks(doc.blocks, "B")

  -- Where each needle sits: the top-level block of every citation (in the order the walk below meets them), of every
  -- heading and of the first paragraph; a needle's place is its block, then its order in it (the heading first).
  local cite_at, head_at, para_at = {}, {}, nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then head_at[#head_at + 1] = i end
    if b.t == "Para" and para_at == nil then para_at = i end
    pandoc.Blocks({ b }):walk({ Link = function(el)
      if el.target:match("^toa%*?:") then cite_at[#cite_at + 1] = i end
    end })
  end
  local function place(block, k) return block * 100000 + k end

  -- The body, walked in order: citations (their needles), headings (labels, outline, needles, table entries).
  local walked = pandoc.Pandoc(doc.blocks, meta):walk({
    Link = function(el)
      local star, key = el.target:match("^toa(%*?):(.+)$")
      if key == nil then return nil end
      occurrences[#occurrences + 1] = { key = key, primary = star == "*", index = #occurrences + 1 }
      local c = cites[#occurrences]
      need("T:" .. #occurrences, c.kind, c.text, c.short, place(cite_at[#occurrences], #occurrences))
      return el.content
    end,
  })
  -- the break rules of typst on the text pandoc writes itself (body, quotations, footnotes); lists as List Item
  -- paragraphs (the number in a half-inch box, the text hanging after it)
  walked = walked:walk({ Inlines = xe.inlines })
  local blocks = {}
  for _, b in ipairs(walked.blocks) do
    for _, x in ipairs(xe.list_items(b)) do blocks[#blocks + 1] = x end
  end
  local body = {}
  local first_para = nil
  local h_n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level > 5 then error("ca11.lua: headings deeper than level 5 are not supported") end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      if b.level == 1 then in_arg = norm(stringify(b.content)) == "argument" end
      local lab = b.level == 1 and "" or label(b.level, counts[b.level], in_arg)
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "H", lab .. stringify(b.content), nil, place(head_at[h_n], 0))   -- its label and title
      if b.level <= TOC_DEPTH then
        local arg_point = in_arg and b.level == 2
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = b.content, step = arg_point and 0 or (b.level == 1 and 0 or step(b.level, in_arg)) }
      end
      body[#body + 1] = raw(heading_xml(b.level, b.content, lab, in_arg, #body == 0))
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
    body[#body] = raw(para({ KEEP, spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(last.content, {})))
  end
  need("S:cip", "S", "Certificate of Interested Persons and Corporate Disclosure Statement", nil, -4)
  need("S:oral", "S", "Statement Regarding Oral Argument", nil, -3)
  need("S:toc", "S", "Table of Contents", nil, -2)
  local toa, toa_first = toa_rows(authorities)
  need("S:toa", "S", toa_first or "", nil, -1)
  need("S:body", "S", (first_para or ""):sub(1, NEEDLE_MAX), nil, place(para_at or 0, 0))
  need("H:cert-c", "H", "Certificate of Compliance", nil, place(#doc.blocks + 1, 1))
  if meta.service_list then need("H:cert-s", "H", "Certificate of Service", nil, place(#doc.blocks + 1, 2)) end
  write_needles({ { "S:cip", "decimal", "C-" }, { "S:oral", "lower-roman" }, { "S:body", "decimal" } })
  write_footers()

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrCover"))

  -- Section 2: the Certificate of Interested Persons (C-1, C-2 ...), double-spaced: the intro, the entries (the
  -- number in a half-inch box), 18.7 pt, the closing statement
  add(raw(section_heading("Certificate of Interested Persons and Corporate Disclosure Statement", true)))
  add(raw(para({ spacing(0, 0, DOUBLE), ind(0, nil, 0) }, inl(meta.cip_intro, {}))))
  for i, e in ipairs(meta.cip) do
    add(raw(para({ spacing(0, 0, DOUBLE), ind(TAB, TAB) }, runs(i .. ".\t", {}) .. inl(e, {}))))
  end
  add(raw(para({ spacing(374, 0, DOUBLE), ind(0, nil, 0) }, inl(meta.cip_closing, {}))))
  add(section("rIdFtrCip", "decimal", 1))

  -- Section 3: the front matter (i, ii ...): oral argument, table of contents, table of citations
  add(raw(section_heading("Statement Regarding Oral Argument", true)))
  add(raw(para({ spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(meta.oral_argument, {}))))
  add(raw(section_heading("Table of Contents", true, true)))
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, 0), jc("right") }, runs("Page", { b = true, u = true }))))
  local function top(title) return { id = nil, level = 1, title = pandoc.Inlines({ pandoc.Str(title) }), step = 0 } end
  local items = {}
  local function item(id, title) local t = top(title); t.id = id; items[#items + 1] = t end
  item("S:cip", "Certificate of Interested Persons and Corporate Disclosure Statement")
  item("S:oral", "Statement Regarding Oral Argument")
  item("S:toc", "Table of Contents")
  item("S:toa", "Table of Citations")
  for _, h in ipairs(headings) do items[#items + 1] = h end
  item("H:cert-c", "Certificate of Compliance")
  if meta.service_list then item("H:cert-s", "Certificate of Service") end
  for _, it in ipairs(items) do add(raw(toc_row(it))) end
  add(raw(section_heading("Table of Citations", true, true)))
  add(raw(toa))
  add(section("rIdFtrFront", "lowerRoman", 1))

  -- Section 4: the body (1, 2 ...) and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(section("rIdFtrBody", "decimal", 1))

  add(raw(section_heading("Certificate of Compliance", true, true)))
  add(raw(para({ spacing(0, 0, DOUBLE), ind(0, nil, 0) },
    runs("Pursuant to Rule 32(g) of the Federal Rules of Appellate Procedure, I certify that the foregoing ", {})
    .. inl(upper_il(meta.brief_title), { b = true })
    .. runs(" complies with (1) the word limit of Rule 32(a)(7)(B) of the Federal Rules of Appellate Procedure because it contains "
      .. group_digits(words) .. " words, which is no more than " .. group_digits(LIMIT)
      .. ", and (2) the typeface and type-style requirements of Rule 32(a)(5) and (6) of the Federal Rules of Appellate Procedure because it has been prepared in a proportionally spaced typeface (Times New Roman) in 14-point.", {}))))
  add(raw(signature(meta)))

  -- The certificate of service: single-spaced; the service list and the signature stay together, 14 pt below the
  -- text, 9.8 pt between the entries, each 0.5 in in.
  if meta.service_list then
    add(raw(section_heading("Certificate of Service", true, true)))
    add(raw(para({ spacing(0, 0), ind(0, nil, 0) },
      runs("This is to certify that I, " .. stringify(meta.signature.signer)
        .. ", have this day electronically filed the foregoing ", {})
      .. inl(upper_il(meta.brief_title), { b = true })
      .. runs(" with the Clerk of Court using the CM/ECF system, which will automatically send electronic notification of such filing to counsel of record who are CM/ECF participants:", {}))))
    for i, s in ipairs(meta.service_list) do
      local joined = {}
      for j, l in ipairs(s.lines) do
        if j > 1 then joined[#joined + 1] = runs(", ", {}) end
        joined[#joined + 1] = inl(l, {})
      end
      add(raw(para({ KEEP, spacing(i == 1 and 280 or 196, 0), ind(TAB, nil, 0) }, table.concat(joined))))
    end
    add(raw(signature(meta)))
  end

  doc.blocks = out
  return doc
end
