-- hib-motion-brief.lua (docx engine, docs/DOCX.md): the markdown contract -> Word, laid out and broken as
-- typst/hib-motion-brief.typ lays it out: the cover (counsel, court title, the caption as a ruled table with the
-- adversary number, the title and the noticed hearing; FRBP 9004(b), LBR 9013-1(c)(1)), the table of contents and
-- the table of authorities (LBR 9013-2(b)), the memorandum (pandoc's body, with its footnotes; headings numbered
-- I., A., 1., a.) and the signature block. Nothing case-specific is in this file: every word comes from the sample.
-- The frontmatter is read as written ($FORMBOOK_META, fb render).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle:
-- the contents' page of each heading, and the authorities' pages of each `toa:` link (a link in a footnote is
-- looked for on the page the body has reached). Three sections: the cover (no number on its first page, a page it
-- runs onto numbered from 2), the tables (lower roman from i) and the memorandum (arabic from 1; FORMBOOK_FINAL).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 644, 322            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_COL = 4680                     -- typst caption grid: two equal columns
local CAP_INSET = 288                    -- typst caption-inset 0.2 in
local CAP_PAD = 240                      -- typst caption-pad 12 pt
local DESIGNATION = 2592                 -- typst designation-indent 1.8 in
local SIG_COL = 4608                     -- typst sig-column 3.2 in
local TAB = 720                          -- typst heading-tab 0.5 in
local TOC_COL, TOA_COL = 720, 1080       -- typst toc-col 0.5 in, toa-col 0.75 in
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local ROW_GAP = 160                      -- typst row-gap 8 pt
local FOOTER = 686                       -- the page number's line 34.3 pt above the page foot (typst footer-descent 30 %)
local PASSIM = 7                         -- typst passim-threshold
local NEEDLE_MAX = 60

local function read_file(path)
  local f = path and path ~= "" and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(k)
  if RAW[k] == nil then error("hib-motion-brief.lua: missing required metadata field `" .. k .. "`") end
  return RAW[k]
end

-- A frontmatter string as inlines, read as typst's cmarker reads it.
local function md(s)
  local b = pandoc.read(s or "", "commonmark+smart", PANDOC_READER_OPTIONS).blocks[1]
  if b == nil then return pandoc.Inlines({}) end
  if b.t == "Para" or b.t == "Plain" then return b.content end
  return pandoc.Inlines({ pandoc.Str(s) })
end

-- A paragraph: o = { style, brk, before, after, line, left, right, first, hanging, tabs, jc, keep, lines, b, i }; a string
-- body is frontmatter markdown (an empty one a blank line), unless it is runs already written ("<w:...").
local function p(s, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  local body = s
  if s:sub(1, 3) ~= "<w:" then body = s == "" and "" or xe.inl(md(s), { b = o.b, i = o.i }) end
  return xe.para(props, body)
end

-- A section's properties: its footers (fb render's rIdFtrNone and rIdFtrPage), the page numbers, letter paper with
-- 1-inch margins (LBR 9004-1(a)(2), (b)(3)); `first`: no number on the section's first page.
local function sect_pr(fmt, first)
  return '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage"/>' ..
    (first and '<w:footerReference w:type="first" r:id="rIdFtrNone"/>' or '') ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" ' ..
    'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>' ..
    (first and '<w:titlePg/>' or '') .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(fmt, first)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' ..
    sect_pr(fmt, first) .. '</w:pPr></w:p>'
end

local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function tbl(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local trs = {}
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function add_needle(id, kind, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, kind, long, short:sub(1, NEEDLE_MAX) }, "\t")
end

local labels = {}
local function load_pages()
  local s = read_file(os.getenv("FORMBOOK_PAGES"))
  if not s then return end
  for line in s:gmatch("[^\n]+") do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
end

-- The text of inlines without their footnotes.
local function text_of(ils)
  local out = {}
  for _, el in ipairs(ils) do
    if el.t ~= "Note" then out[#out + 1] = stringify(el) end
  end
  return table.concat(out)
end

-- Every `toa:` link of a run of inlines, in order, as a needle (the link's text and the words after it); the links
-- of a footnote at the place of its mark (kind N). hits[key] lists the needle ids.
local hits, n_hits = {}, 0
local function scan(ils, kind)
  for i, el in ipairs(ils) do
    if el.t == "Link" and el.target:sub(1, 4) == "toa:" then
      n_hits = n_hits + 1
      local id = "T:" .. n_hits
      local key = el.target:sub(5)
      hits[key] = hits[key] or {}
      hits[key][#hits[key] + 1] = id
      local after = {}
      for j = i + 1, #ils do after[#after + 1] = ils[j] end
      add_needle(id, kind, stringify(el.content), text_of(after):sub(1, 60))
    elseif el.t == "Note" then
      for _, b in ipairs(el.content) do
        if b.content then scan(b.content, "N") end
      end
    elseif el.content and type(el.content) == "table" and el.t ~= "Link" then
      scan(el.content, kind)
    end
  end
end

-- The links of a block of the body (a footnote's are scanned at its mark).
local function scan_block(b)
  if b.t == "Para" or b.t == "Plain" then
    scan(b.content, "B")
  elseif b.t == "BlockQuote" then
    for _, c in ipairs(b.content) do scan_block(c) end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    for _, item in ipairs(b.content) do
      for _, c in ipairs(item) do scan_block(c) end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption, title of the paper, hearing (HIB-FORM-001, -005, -006)
-- ---------------------------------------------------------------------------

local function caption_side(side, out)
  for _, n in ipairs(side.names or {}) do out[#out + 1] = p(n) end
  out[#out + 1] = p(side.designation or "", { left = DESIGNATION })
end

local function cover()
  local out = {}
  for _, l in ipairs(need("counsel")) do out[#out + 1] = p(l) end
  if RAW.counsel_role then out[#out + 1] = p(RAW.counsel_role, { i = true }) end
  for i, l in ipairs(need("court")) do
    out[#out + 1] = p(pandoc.text.upper(l), { b = true, before = i == 1 and SINGLE or 0, jc = "center" })
  end
  local sides = need("caption")
  -- the left cell of a row: its text 0.2 in off the rule on its right, 12 pt above its foot; the last row's rule
  -- closes the party column below
  local function left(body, last)
    body[#body] = body[#body]:gsub('w:after="0"', 'w:after="' .. CAP_PAD .. '"', 1)
    return { pr = '<w:tcBorders>' .. (last and '<w:bottom ' .. RULE .. '/>' or '') .. '<w:right ' .. RULE .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = body }
  end
  local function right(body)
    if #body == 0 then body = { p("") } end
    return { pr = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = body }
  end
  local l1 = {}
  local bk = RAW.bankruptcy or {}
  for _, l in ipairs(bk) do l1[#l1 + 1] = p(l) end
  if #bk > 0 then l1[#l1 + 1] = p("") end
  caption_side(sides[1], l1)
  local rows = { { left(l1, #sides == 1),
    right({ p(need("adversary_number")), p(""), p(pandoc.text.upper(need("brief_title")), { b = true }) }) } }
  -- the noticed hearing, opposite the remaining parties (LBR 9013-1(c)(1))
  local hearing = {}
  local h = RAW.hearing or {}
  for _, k in ipairs({ { "date", "Date:" }, { "time", "Time:" }, { "place", "Place:" }, { "judge", "Judge:" } }) do
    if h[k[1]] then hearing[#hearing + 1] = p(k[2] .. " " .. h[k[1]]) end
  end
  for i = 2, #sides do
    local l = { p("v.", { jc = "center" }), p("") }
    caption_side(sides[i], l)
    rows[#rows + 1] = { left(l, i == #sides), right(i == 2 and hearing or {}) }
  end
  -- the caption stands a single line below the court title (Word: the title's space after; a table has no space of
  -- its own)
  out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. SINGLE .. '"', 1)
  -- each row a table of its own, a 0.1 pt paragraph between them (LibreOffice draws a rule above a row that a
  -- table carries over to a new page; typst's rows are blocks of their own)
  for i, r in ipairs(rows) do
    if i > 1 then out[#out + 1] = p("", { line = 2 }) end
    out[#out + 1] = tbl({ CAP_COL, CAP_COL }, { r })
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Tables (LBR 9013-2(b)): contents and authorities, rows with a dot leader to the page column
-- ---------------------------------------------------------------------------

local function table_title(title, col, brk)
  return {
    p(xe.runs(title, { b = true }), { jc = "center", keep = true, brk = brk }),
    p(xe.runs(col, { b = true }), { jc = "right", before = SINGLE, keep = true }),
  }
end

-- A row: the text, at least three spaces, a dot leader to the page column (the right indent), the page.
local function row(text, page, o)
  o.lines, o.before, o.right = true, ROW_GAP, o.right
  o.tabs = '<w:tabs>' .. (o.tab and ('<w:tab w:val="left" w:pos="' .. o.tab .. '"/>') or '') ..
    '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return p(text .. xe.runs(xe.LEAD) .. page, o)
end

local ROMAN = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
local function roman(n)
  local s = ""
  for _, v in ipairs(ROMAN) do
    while n >= v[1] do
      s, n = s .. v[2], n - v[1]
    end
  end
  return s
end

-- Heading labels as typst numbers them: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 is unnumbered.
local counters = { 0, 0, 0, 0, 0 }
local function label(level)
  counters[level] = counters[level] + 1
  for l = level + 1, 5 do counters[l] = 0 end
  local k = counters[level]
  if level == 2 then return roman(k) .. "."
  elseif level == 3 then return string.char(64 + k) .. "."
  elseif level == 4 then return tostring(k) .. "."
  elseif level == 5 then return string.char(96 + k) .. "." end
  return ""
end

local function contents(entries)
  local out = table_title("TABLE OF CONTENTS", "Page")
  for _, e in ipairs(entries) do
    local ind = (e.level - 2) * TAB
    out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), xe.runs(labels[e.id] or "0"),
      { left = ind + TAB, hanging = TAB, tab = ind + TAB, right = TOC_COL })
  end
  return out
end

local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "other", "Other Authorities" } }

local function authorities()
  local out = table_title("TABLE OF AUTHORITIES", "Page(s)", true)
  local auth = RAW.authorities or {}
  for key in pairs(hits) do
    if auth[key] == nil then
      error("hib-motion-brief.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      local kx, ky = (x.a.name or x.a.cite or ""):lower(), (y.a.name or y.a.cite or ""):lower()
      if kx ~= ky then return kx < ky end
      return x.key < y.key
    end)
    if #members > 0 then
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = SINGLE, keep = true })
      for _, m in ipairs(members) do
        local pages, seen = {}, {}
        for _, id in ipairs(hits[m.key]) do
          local l = labels[id] or "0"
          if not seen[l] then
            seen[l] = true
            pages[#pages + 1] = l
          end
        end
        local where = #pages >= PASSIM and xe.runs("passim", { i = true }) or xe.runs(table.concat(pages, ", "))
        local text = ""
        if m.a.name then text = xe.inl(md(m.a.name), { i = g[1] == "case" }) .. xe.runs(", ") end
        out[#out + 1] = row(text .. xe.inl(md(m.a.cite)), where, { left = TOA_HANG, hanging = TOA_HANG, right = TOA_COL })
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (HIB-FORM-007): "DATED:" at the left, the signatures in a 3.2 in column at the right, a blank
-- line between them; the row never splits. The space above it is a 1 pt paragraph kept with the table, its space
-- before the rest: at the top of a page LibreOffice drops a paragraph's space before, as typst drops a block's, but
-- keeps it in a cell.
-- ---------------------------------------------------------------------------

local function signature()
  local right = {}
  for i, b in ipairs(need("signature")) do
    if i > 1 then right[#right + 1] = p("") end
    for _, l in ipairs(b) do right[#right + 1] = p(l) end
  end
  return p("", { keep = true, before = SINGLE - 20, line = 20 }) ..
    tbl({ TEXTW - SIG_COL, SIG_COL }, { { { body = { p("DATED: " .. need("date")) } }, { body = right } } })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 548"; typst boxes it): a no-break space after it.
local function bind_doubled(ils)
  for i = 1, #ils - 1 do
    local a, b = ils[i], ils[i + 1]
    if a.t == "Str" and b.t == "Space" and (a.text == "§§" or a.text == "¶¶") then ils[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return ils
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- Headings bold at the body pitch, no space of their own, kept with the text: level 1 centered in capitals (the
-- recipe's Heading 1 capitals off, so the PDF text is the text set); deeper levels the label in a half-inch box at
-- the level's indent (a tab), the title hanging after it.
local NOCAPS = '<w:caps w:val="0"/></w:rPr>'
local function heading(level, lab, content)
  local lvl = math.min(level, 3)
  local props = { xe.style("Heading" .. lvl), xe.KEEP }
  local body
  if level == 1 then
    body = xe.inl(content, { b = true }):gsub('(<w:t xml:space="preserve">)([^<]*)',
      function(t, s) return t .. pandoc.text.upper(s) end)
    props[#props + 1] = xe.spacing(0, 0, BODY)
    props[#props + 1] = xe.ind(0, nil, 0)
    props[#props + 1] = xe.jc("center")
  else
    local ind = (level - 2) * TAB
    body = xe.runs(lab .. "\t") .. xe.inl(content, { b = true })
    props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + TAB) .. '"/></w:tabs>'
    props[#props + 1] = xe.spacing(0, 0, BODY)
    props[#props + 1] = xe.ind(ind + TAB, TAB)
    props[#props + 1] = xe.jc("left")
  end
  return xe.raw(xe.para(props, (body:gsub("</w:rPr>", NOCAPS))))
end

local function unlink(el)
  if el.target:sub(1, 4) == "toa:" then return el.content end
end

function Pandoc(doc)
  load_pages()
  local blocks = doc.blocks:walk({ Inlines = bind_doubled })

  -- the needles, in document order: the tables' start (lower roman from i), the memorandum's first words (arabic
  -- from 1), each heading with the words after it, and each authority link with the words after it
  add_needle("S:toc", "B", "TABLE OF CONTENTS Page")
  add_needle("S:body", "B", text_of(blocks[1].content or {}):sub(1, 60))
  local entries, h_n = {}, 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      add_needle(id, "B", stringify(b.content), nxt)
      local lab = label(b.level)
      b.attributes["label"] = lab
      if b.level >= 2 and b.level <= 4 then entries[#entries + 1] = { id = id, level = b.level, label = lab, title = b.content } end
    elseif b.content and type(b.content) == "table" then
      scan_block(b)
    end
  end
  needles[#needles + 1] = "#section\tS:toc\tlower-roman\t"
  needles[#needles + 1] = "#section\tS:body\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("decimal", false))

  blocks = blocks:walk({ Link = unlink }):walk({ Str = breaks }):walk({ Inlines = xe.inlines })
  local out = {}
  for _, x in ipairs(cover()) do out[#out + 1] = xe.raw(x) end
  out[#out + 1] = xe.raw(section_end("decimal", true))
  for _, x in ipairs(contents(entries)) do out[#out + 1] = xe.raw(x) end
  for _, x in ipairs(authorities()) do out[#out + 1] = xe.raw(x) end
  out[#out + 1] = xe.raw(section_end("lowerRoman", false))

  local last = #blocks
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b.level, b.attributes["label"], b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      local style = i == last and "Body Text Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
    else
      error("hib-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature())
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
