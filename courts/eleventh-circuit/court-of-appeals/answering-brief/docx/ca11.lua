-- ca11.lua (docx engine): the ca11 answer brief as Word paragraphs and sections (typst: ca11-answering-brief.typ).
-- pandoc writes the body text (paragraphs, quotations, lists, footnotes) with the reference document fb render builds
-- from docx/reference.xml; this filter writes what Word needs formatting for:
--   * the cover, the statement on oral argument, the tables, the certificates and the signature blocks, as
--     paragraphs (and borderless tables for the counsel columns and the form signature) with explicit spacing,
--     indents and tabs;
--   * the heading labels (I., A., 1., a. at every level);
--   * the table of contents and the table of authorities: their entries and page numbers. fb render renders the
--     document once, finds the page of every heading and citation in the PDF (the needles this filter writes,
--     tools/fb/src/docxpages.rs), and renders again with those pages (the pages file this filter reads);
--   * the sections whose footers number the pages: cover (none), front matter (i, ii ...), body and certificates
--     (1 ...). fb render adds the footers this filter lists.
-- Word may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every line and page breaks where the typst render
-- breaks it. The model is lib/docx/xengine.lua (the break rules of typst on every run, exact line spacing: each line
-- a box of its pitch, the space between paragraphs the larger of the two); the pitches and spaces below are the
-- typst template's, in twips (20 x pt).

local TOC_DEPTH = 4     -- heading levels listed in the table of contents (typst: toc-depth)
local WORD_LIMITS = { standard = 13000, ["cross-appeal"] = 15300 }  -- FRAP 32(a)(7)(B)(i); FRAP 28.1(e)(2)(A)(ii)
local TAB = 720         -- half an inch, in twips
local TEXT_W = 9360     -- the text width, 6.5 in
local HALF_W = 4680     -- the middle of the page: the caption, a single counsel group and the signature start here
local STEP = 140        -- 0.5 em: the counsel's and the signature's lines step in (typst: h(0.5em))
local GUTTER = 280      -- 1 em between the cover's counsel columns and the form signature's columns (typst grid)
local DOUBLE = 628      -- typst pitch-double: 31.4 pt (11th Cir. R. 32-3, double spacing)
local SINGLE = 400      -- typst pitch-single: 20 pt (headings, quotations, footnotes, cover, signature)
local HEAD_SZ = 32      -- section headings: 16 pt (half points; typst heading-size)
local TOC_COL = 616     -- typst toc-page-col: 30.8 pt kept for the contents' page numbers
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

-- A borderless table of cells (each a string of paragraphs) in columns of `w` twips, `gutter` apart; rows are not
-- split (typst grid). widths: the text width of each column.
local function grid(rows, widths, gutter)
  local n = #widths
  local cols, total = {}, 0
  for c = 1, n do
    cols[c] = widths[c] + (c < n and gutter or 0)
    total = total + cols[c]
  end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>' }
  for c = 1, n do out[#out + 1] = '<w:gridCol w:w="' .. cols[c] .. '"/>' end
  out[#out + 1] = '</w:tblGrid>'
  for _, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for c = 1, n do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. cols[c] .. '" w:type="dxa"/><w:tcMar><w:right w:w="'
        .. (c < n and gutter or 0) .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
        .. (row[c] or para({ spacing(0, 0) }, "")) .. '</w:tc>'
    end
    out[#out + 1] = '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return table.concat(out)
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

-- The footers the sections name (centered in a 20 pt line: the cover's empty, the others the page number) and the
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
-- Headings (typst: heading-label, style-heading, label-indent) and the table of contents (typst: toc-entry)
-- ---------------------------------------------------------------------------

local counts = { 0, 0, 0, 0, 0, 0 }
local headings = {}    -- the headings the table of contents lists (outlined), in order
local occurrences = {} -- the table-of-authorities links, in document order: { key, index }

-- Every numbered heading is labeled I. / A. / 1. / a. (level 2 to 5), wherever it is (typst heading-label).
local function label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return n .. "." end
  return string.char(96 + n) .. "."
end

-- Label indent in half inches: level 2 at the margin, each deeper level half an inch further in (typst label-indent).
local function step(level)
  return level - 2
end

-- A section heading (typst style-heading, level 1): bold capitals, 16 pt, centered, single-spaced, 21 pt above,
-- 15.4 below; one that opens a page has no space above (typst drops it there; Word keeps it after a page or section
-- break). `text`: a string or inlines.
local function section_heading(text, top, brk)
  local props = { KEEP }
  if brk then props[#props + 1] = BREAK end
  props[#props + 1] = spacing(top and 0 or 420, 308)
  props[#props + 1] = ind(0, nil, 0)
  props[#props + 1] = jc("center")
  local body = type(text) == "string" and runs(text:upper(), { b = true, sz = HEAD_SZ })
    or inl(upper_il(text), { b = true, sz = HEAD_SZ })
  return para(props, body)
end

-- The XML of a body heading (typst: style-heading). Level 1 is a section heading; the others hang under their label
-- (15.4 / 12.6 pt), each level half an inch further in; bold, italic from level 4.
local function heading_xml(level, content, lab, top)
  if level == 1 then return section_heading(content, top) end
  local k = step(level)
  local o = { b = true, i = level >= 4 }
  return para({ KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. TAB * (k + 1) .. '"/></w:tabs>', spacing(308, 252),
    ind(TAB * (k + 1), TAB) }, runs(lab .. "\t", { b = true, i = level >= 4 }) .. inl(content, o))
end

-- One row of the table of contents (typst: toc-entry, listing-row): double-spaced; the label in a half-inch box,
-- the title hanging after it and wrapping before the page column, a dot leader to the page.
local function toc_row(item)
  local title = item.level == 1 and upper_il(item.title) or item.title
  local left = item.step * TAB
  local lead = item.label and runs(item.label .. "\t", {}) or ""
  return para({ LINES, row_tabs(item.label and left + TAB or nil), spacing(0, 0, DOUBLE),
    ind(left + TAB, TAB, nil, TOC_COL) }, lead .. inl(title, {}) .. runs(LEAD .. label_of(item.id), {}))
end

-- ---------------------------------------------------------------------------
-- The table of authorities (typst: toa-section)
-- ---------------------------------------------------------------------------

local GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

-- The rows of the table, and the needle of its first entry.
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
        -- the distinct pages of the authority, in document order
        local pages, seen = {}, {}
        for _, o in ipairs(occurrences) do
          if o.key == m.key then
            local l = labels["T:" .. o.index]
            local k = l and tostring(l.page) or ("?" .. o.index)
            if not seen[k] then
              seen[k] = true
              pages[#pages + 1] = l and l.label or "00"
            end
          end
        end
        local page_text = table.concat(pages, ", ")
        if first_needle == nil then
          first_needle = m.a.name and stringify(m.a.name) or stringify(m.a.cite)
        end
        local name = ""
        if m.a.name then
          name = inl(m.a.name, { i = g[1] == "case" }) .. runs(",", {}) .. BR
        end
        -- one double-spaced row (listing-row): the citation hanging 0.35 in, the page column
        local col = math.max(TOA_COL, list_width(page_text))
        out[#out + 1] = para({ LINES, row_tabs(nil), spacing(0, 0, DOUBLE), ind(504, 504, nil, col) },
          name .. inl(m.a.cite, {}) .. runs(LEAD .. page_text, {}))
      end
    end
  end
  return table.concat(out), first_needle
end

-- ---------------------------------------------------------------------------
-- Cover (typst: cover-body), signature, form signature
-- ---------------------------------------------------------------------------

local function need_meta(meta, k)
  if meta[k] == nil then error("ca11.lua: missing required metadata field `" .. k .. "`") end
  return meta[k]
end

-- A 2 in rule between the cover's parts (typst short-rule), 14 pt (1 em) on either side.
local function rule()
  return raw(para({ '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>',
    spacing(0, 280, 120), '<w:ind w:left="3240" w:right="3240"/>', jc("center") }, ""))
end

-- The double rule across the page (typst double-rule: 1.6 pt, then 0.5 pt), 14 pt on either side.
local function double_rule()
  return raw(para({ '<w:pBdr><w:bottom w:val="thickThinSmallGap" w:sz="12" w:space="1" w:color="000000"/></w:pBdr>',
    spacing(280, 280, 120), ind(0, nil, 0) }, ""))
end

-- The paragraphs of one counsel group (typst: group-body): the names, then the lines (the telephone closes the last
-- group) 0.5 em in, wrapped lines 1 em in, italic; 3.5 pt between them. `left`: the group's left edge.
local function counsel_group(meta, gi, g, ngroups, left)
  local out, first = {}, true
  local function line(l, h, body)
    out[#out + 1] = para({ KEEP, spacing(first and 0 or 70, 0), ind(l, h) }, body)
    first = false
  end
  for _, n in ipairs(g.names or {}) do line(left, nil, inl(n, {})) end
  local lines = {}
  for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
  if gi == ngroups then lines[#lines + 1] = need_meta(meta, "phone") end
  for _, l in ipairs(lines) do line(left + 2 * STEP, STEP, inl(l, { i = true })) end
  return table.concat(out)
end

-- The cover: single-spaced, centered; 4.9 pt between paragraphs, 14 pt (1 em) between its parts.
local function cover(meta)
  local out = {}
  local function c(before, body)
    out[#out + 1] = raw(para({ spacing(before, 98), jc("center") }, body))
  end
  c(168, runs("No. ", { b = true }) .. inl(need_meta(meta, "case_number"), { b = true }))
  out[#out + 1] = double_rule()
  c(0, runs("IN THE UNITED STATES COURT OF APPEALS", { b = true }) .. BR .. runs("FOR THE ELEVENTH CIRCUIT", { b = true }))
  out[#out + 1] = rule()
  local sides = need_meta(meta, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do c(0, inl(name, {})) end
    out[#out + 1] = raw(para({ spacing(0, 98), ind(HALF_W) }, inl(side.designation, {})))
    if i < #sides then c(84, runs("v.", {})) end
  end
  out[#out + 1] = rule()
  c(0, inl(need_meta(meta, "proceeding"), {}))
  if meta.district_court_case or meta.judge then
    local x = ""
    if meta.district_court_case then x = runs("D.C. Docket No. ", {}) .. inl(meta.district_court_case, {}) end
    if meta.district_court_case and meta.judge then x = x .. runs("; ", {}) end
    if meta.judge then x = x .. inl(meta.judge, {}) end
    c(0, x)
  end
  out[#out + 1] = rule()
  c(0, inl(upper_il(need_meta(meta, "brief_title")), { b = true }))
  out[#out + 1] = rule()
  -- counsel (FRAP 32(a)(2)(F)): one group from the middle of the page; two or more side by side, up to three a row
  local groups = need_meta(meta, "counsel")
  if #groups == 1 then
    out[#out + 1] = raw(counsel_group(meta, 1, groups[1], 1, HALF_W))
  else
    local cols = math.min(#groups, 3)
    local w = math.floor((TEXT_W - GUTTER * (cols - 1)) / cols)
    local widths = {}
    for k = 1, cols do widths[k] = w end
    widths[cols] = TEXT_W - GUTTER * (cols - 1) - w * (cols - 1)
    local rows = {}
    for r = 1, #groups, cols do
      local row = {}
      for gi = r, math.min(r + cols - 1, #groups) do
        row[#row + 1] = counsel_group(meta, gi, groups[gi], #groups, 0)
      end
      rows[#rows + 1] = row
    end
    out[#out + 1] = raw(grid(rows, widths, GUTTER))
  end
  out[#out + 1] = double_rule()
  return out
end

-- typst: signature-block. Single-spaced, 19.6 pt above; from the middle of the page "Respectfully submitted," then
-- 16.8 pt below it the signature, the name in capitals and the lines (0.5 em in, italic); the date at the margin
-- 11.2 pt below. The lines stay together on one page.
local function signature(meta)
  local sig = need_meta(meta, "signature")
  local out = { para({ KEEP, spacing(392, 0), ind(HALF_W) }, runs("Respectfully submitted,", {})) }
  local lines = { { runs("s/ " .. stringify(sig.signer), {}) }, { runs(stringify(sig.signer):upper(), {}) } }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { inl(l, { i = true }), STEP } end
  for i, l in ipairs(lines) do
    local last = i == #lines and DATE == ""
    out[#out + 1] = para({ last and LINES or KEEP, spacing(i == 1 and 336 or 0, 0), ind(HALF_W, nil, l[2]) }, l[1])
  end
  if DATE ~= "" then
    out[#out + 1] = para({ LINES, spacing(224, 0), ind(0, nil, 0) }, runs("Dated: " .. DATE, {}))
  end
  return table.concat(out)
end

-- typst: form-sig-line. 22.4 pt above; two columns of (text width - 1 em) / 2: the signature and "Attorney for" the
-- party on the left, the date on the right.
local function form_signature(meta)
  local sig = need_meta(meta, "signature")
  local party = sig.party and stringify(sig.party) or "__________"
  local w = (TEXT_W - GUTTER) / 2
  local left = para({ KEEP, spacing(0, 0), ind(0, nil, 0) }, runs("s/ " .. stringify(sig.signer), {}))
    .. para({ LINES, spacing(0, 0), ind(0, nil, 0) }, runs("Attorney for " .. party, {}))
  local right = para({ LINES, spacing(0, 0), ind(0, nil, 0) }, runs("Dated: " .. (DATE ~= "" and DATE or "__________"), {}))
  -- the space above: an empty 1 pt paragraph that keeps with the table
  return para({ KEEP, spacing(428, 0, 20) }, "") .. grid({ { left, right } }, { w, w }, GUTTER)
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
  DATE = meta.date and stringify(meta.date) or ""
  doc.meta.date = nil
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature",
    "oral_argument" }) do
    need_meta(meta, k)
  end
  local authorities = meta.authorities or {}
  local basis = meta.word_limit_basis and stringify(meta.word_limit_basis) or "standard"
  local limit = WORD_LIMITS[basis]
  if limit == nil then error("ca11.lua: unknown word_limit_basis `" .. basis .. "`") end
  local words = count_body_words()
  if words > limit then
    error("ca11.lua: the brief has " .. words .. " words; FRAP 32(a)(7)(B) allows " .. limit)
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "addendum" then
      error("ca11.lua: the addendum is not built for docx yet (BLOCKED, see README \"Engines\")")
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
      if el.t == "Link" and el.target:match("^toa:") then
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
      if el.target:match("^toa:") then cite_at[#cite_at + 1] = i end
    end })
  end
  local function place(block, k) return block * 100000 + k end

  -- The body, walked in order: citations (their needles), headings (labels, needles, table entries).
  local walked = pandoc.Pandoc(doc.blocks, meta):walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if key == nil then return nil end
      occurrences[#occurrences + 1] = { key = key, index = #occurrences + 1 }
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
      local lab = b.level == 1 and "" or label(b.level, counts[b.level])
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, "H", lab .. stringify(b.content), nil, place(head_at[h_n], 0))   -- its label and title
      if b.level <= TOC_DEPTH then
        headings[#headings + 1] = { id = id, level = b.level, label = b.level > 1 and lab or nil,
          title = b.content, step = b.level > 1 and step(b.level) or 0 }
      end
      body[#body + 1] = raw(heading_xml(b.level, b.content, lab, #body == 0))
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
  local toa, toa_first = toa_rows(authorities)
  need("S:oral", "S", "Statement Regarding Oral Argument", nil, -3)
  need("S:toc", "S", "Table of Contents", nil, -2)
  need("S:toa", "S", toa_first or "", nil, -1)
  need("S:body", "S", (first_para or ""):sub(1, NEEDLE_MAX), nil, place(para_at or 0, 0))
  local svc = meta.service or {}
  local service = svc.certificate
  write_needles({ { "S:oral", "lower-roman" }, { "S:body", "decimal" } })
  write_footers()

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- Section 1: the cover (no page number)
  for _, x in ipairs(cover(meta)) do add(x) end
  add(section("rIdFtrCover"))

  -- Section 2: the front matter (i, ii ...): oral argument, table of contents, table of authorities (unlisted)
  add(raw(section_heading("Statement Regarding Oral Argument", true)))
  add(raw(para({ spacing(0, 0, DOUBLE), ind(0, nil, TAB) }, inl(meta.oral_argument, {}))))
  add(raw(section_heading("Table of Contents", true, true)))
  add(raw(para({ KEEP, spacing(84, 0), ind(0, nil, 0), jc("right") }, runs("Page", { b = true, u = true }))))
  for _, h in ipairs(headings) do add(raw(toc_row(h))) end
  add(raw(section_heading("Table of Authorities", true, true)))
  add(raw(toa))
  add(section("rIdFtrFront", "lowerRoman", 1))

  -- Section 3: the body (1, 2 ...) and the certificates, which continue its numbering
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta)))
  add(section("rIdFtrBody", "decimal", 1))

  -- Certificate of Compliance (Form 6 wording), double-spaced
  local manual = meta.manual_image_words and tonumber(stringify(meta.manual_image_words)) or 0
  add(raw(section_heading("Certificate of Compliance", true, true)))
  add(raw(para({ spacing(0, 0, DOUBLE), ind(0, nil, 0) },
    runs("This brief complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B)"
      .. (basis == "cross-appeal" and " (as applied by Fed. R. App. P. 28.1(e)(2)(A)(ii))" or "")
      .. " because, excluding the parts of the brief exempted by Fed. R. App. P. 32(f) and 11th Cir. R. 32-4, it contains "
      .. group_digits(words) .. " words"
      .. (manual > 0 and (", including " .. manual .. " words manually counted in visual images") or "") .. ".", {}))))
  add(raw(para({ spacing(0, 0, DOUBLE), ind(0, nil, 0) },
    runs("This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because it has been prepared in a proportionally spaced typeface, Times New Roman, 14-point.", {}))))
  add(raw(form_signature(meta)))

  -- Certificate of Service, single-spaced, 14 pt between paragraphs
  if service then
    add(raw(section_heading("Certificate of Service", true, true)))
    add(raw(para({ spacing(0, 0), ind(0, nil, 0) },
      runs("I certify that on " .. (DATE ~= "" and DATE or "__________") .. ", I filed the foregoing document with the Clerk of the Court for the United States Court of Appeals for the Eleventh Circuit through the CM/ECF system, which serves notice of the filing on all registered counsel of record.", {}))))
    local unreg = svc.unregistered or {}
    if #unreg > 0 then
      add(raw(para({ spacing(280, 0), ind(0, nil, 0) }, runs("Service on Persons Who Are NOT Registered for CM/ECF:", { b = true }))))
      add(raw(para({ spacing(280, 0), ind(0, nil, 0) },
        runs("I certify that I served the foregoing document on this date by hand delivery, mail, third-party commercial carrier, or, having obtained prior consent, by email, to the following persons (list each name and mailing or email address):", {}))))
      for _, u in ipairs(unreg) do
        add(raw(para({ LINES, spacing(196, 0), ind(TAB, nil, 0) }, inl(u.name, {}) .. runs(", ", {}) .. inl(u.address, {}))))
      end
    end
    add(raw(form_signature(meta)))
  end

  doc.blocks = out
  return doc
end
