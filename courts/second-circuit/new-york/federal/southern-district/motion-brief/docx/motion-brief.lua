-- S.D.N.Y. memorandum of law (motion brief), docx engine. Mirrors typst/nysd-motion-brief.typ; rules and conventions
-- are in ../README.md. The cover (counsel block, court title, caption), the table of contents and the table of
-- authorities (built from the `toa:` links of the body, as typst builds them), the heading labels (I., A., 1., a.),
-- the signature block and the certificate of compliance (Local Civ. R. 7.1(c)) are built here; body paragraphs,
-- bullets and block quotations stay pandoc's (styles of docx/reference.xml), so their footnotes are pandoc's.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter and body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Sections and page numbers (were docx/render.sh's two passes and pages.awk): the cover a section without a page
-- number (fb render's rIdFtrNone), the tables a section numbered in lower roman from i, the body a section numbered
-- from 1, both with fb render's page-number footer (rIdFtrPage), the certificate a last section without a number
-- ($FORMBOOK_FINAL). The tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the
-- needles this filter writes ($FORMBOOK_NEEDLES: the two table titles, each heading, each citation, in document
-- order) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-double 24 pt, pitch-single 13.8 pt
local ROW_ABOVE = 120                    -- typst row-above 6 pt
local TEXTW = 9360                       -- 6.5 in
local CAP_COL = 4680                     -- typst caption grid: two equal columns
local CAP_INSET = 288                    -- typst caption-inset 0.2 in
local CAP_PAD = 240                      -- typst caption-pad 12 pt
local DESIG = 2592                       -- typst designation-indent 1.8 in
local SIG_COL = 4608                     -- typst sig-column 3.2 in
local TAB_W = 720                        -- typst heading-tab 0.5 in
local PNUM = 720                         -- typst page-col 0.5 in
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local PASSIM_AT = 7                      -- typst passim-threshold
local FACE = "Times New Roman"           -- typst font-family.first(), the face {font} names in docx/reference.xml
local NEEDLE_MAX = 60
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("motion-brief.lua: missing required metadata field `" .. key .. "`") end
  return v
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide; a doubled
-- section sign stays with its number, as the typst template boxes it.
local function bind(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table with fixed column widths and no cell margins; cells = { { xml, tcpr } }; the row never splits.
local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i][2] or "") .. '</w:tcPr>'
      .. cells[i][1] .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function needle(id, kind, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, _, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Sections: letter page, 1-inch margins (Local Civ. R. 7.1(b)(2)); the footer 0.5 in above the bottom edge
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for _, l in ipairs(items(need(m, "counsel"))) do out[#out + 1] = p(xe.inl(l)) end
  local court = items(need(m, "court"))
  for i, l in ipairs(court) do
    -- the court title a double line below the counsel block, the caption a double line below it (the title's space
    -- after; a table has none of its own)
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true, before = i == 1 and BODY or 0,
      after = i == #court and BODY or 0 })
  end
  local left = {}
  local sides = items(need(m, "caption"))
  for i, side in ipairs(sides) do
    if i > 1 then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("v."), { jc = "center" })
      left[#left + 1] = p("")
    end
    for _, n in ipairs(items(side.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIG })
  end
  -- the party column's last line 12 pt above its bottom rule
  left[#left] = left[#left]:gsub('w:after="0"', 'w:after="' .. CAP_PAD .. '"', 1)
  local right = {}
  for _, l in ipairs(items(m.legends)) do right[#right + 1] = p(xe.inl(l)) end
  right[#right + 1] = p("")
  local flabel = m["file-label"] and stringify(m["file-label"]) or "No."
  right[#right + 1] = p(xe.runs(flabel .. " ") .. xe.inl(need(m, "case_number")))
  if m.judge then right[#right + 1] = p(xe.inl(m.judge)) end
  right[#right + 1] = p("")
  right[#right + 1] = p(xe.inl(upper(need(m, "title")), { b = true }))
  out[#out + 1] = table_xml({ CAP_COL, TEXTW - CAP_COL }, {
    { table.concat(left), '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>'
      .. '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>' },
    { table.concat(right), '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>' },
  })
  out[#out + 1] = section("rIdFtrNone", nil)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings: "I." level 2, "A." level 3, "1." level 4, "a." level 5; level 1 unnumbered
-- ---------------------------------------------------------------------------

local function roman(n)
  local t = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, x in ipairs(t) do while n >= x[1] do s = s .. x[2]; n = n - x[1] end end
  return s
end

local function label(level, k)
  if level == 2 then return roman(k) .. "."
  elseif level == 3 then return string.char(64 + k) .. "."
  elseif level == 4 then return k .. "."
  elseif level == 5 then return string.char(96 + k) .. "."
  end
  return ""
end

local function indent(level)
  return math.max(level - 2, 0) * TAB_W
end

-- A heading single-spaced, bold, a single line above and below, kept with the next block (typst sticky): level 1
-- centred capitals; deeper levels the label in a box half an inch wide (a tab), the title hanging after it.
local function heading(level, lab, content)
  if level == 1 then
    return p(xe.inl(upper(content), { b = true }), { before = SINGLE, after = SINGLE, keep = true, jc = "center" })
  end
  local ind = indent(level)
  return p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(content, { b = true }),
    { before = SINGLE, after = SINGLE, keep = true, left = ind + TAB_W, hanging = TAB_W })
end

-- ---------------------------------------------------------------------------
-- The tables (contents and authorities)
-- ---------------------------------------------------------------------------

-- A table's title (on the body pitch), a double line below it the column label at the right (typst table-head).
local function table_head(title, col, pre)
  return p(xe.runs(title, { b = true }), { pre = pre, line = BODY, after = BODY, keep = true, jc = "center" })
    .. p(xe.runs(col, { b = true }), { keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging)
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = xe.leader_tab(TEXTW),
    before = ROW_ABOVE, left = left, hanging = hanging, right = PNUM })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    if e.level <= 4 then
      local pg = xe.runs(labels[e.id] or "0")
      if e.label == "" then
        out[#out + 1] = row(xe.inl(e.level == 1 and upper(e.title) or e.title), pg, 0, nil)
      else
        local ind = indent(e.level)
        out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), pg, ind + TAB_W, TAB_W)
      end
    end
  end
  return table.concat(out)
end

local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "regulation", "Regulations" },
  { "other", "Other Authorities" } }

local function toa(authorities, cites)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)", xe.BREAK) }
  -- the distinct page labels of each authority, in document order (the page a citation starts on)
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then
      error("motion-brief.lua: link `toa:" .. c.key .. "` has no entry under `authorities:` in the frontmatter")
    end
    pages[c.key] = pages[c.key] or {}
    seen[c.key] = seen[c.key] or {}
    local l = labels[c.id] or "0"
    if not seen[c.key][l] then
      seen[c.key][l] = true
      pages[c.key][#pages[c.key] + 1] = l
    end
  end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if pages[key] and stringify(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = pandoc.text.lower(stringify(a.name or a.cite or "")) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = SINGLE, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        local text = ""
        if a.name then text = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        text = text .. xe.inl(a.cite)
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_HANG, TOA_HANG)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of compliance (Local Civ. R. 7.1(c))
-- ---------------------------------------------------------------------------

-- A double line above the block: a 1 pt paragraph kept with the table, its space before the rest (at the top of a
-- page LibreOffice drops a paragraph's space before, as typst drops a block's, but keeps it in a cell).
local function above_table()
  return p("", { keep = true, before = BODY - 20, line = 20 })
end

local function dated(m)
  local place = m.place and xe.inl(m.place) or xe.runs("New York, New York")
  return p(xe.runs("Dated: ") .. place) .. p(xe.inl(need(m, "date")))
end

-- The place and date at the left; in the signature column "Respectfully submitted,", a double line below it the
-- firm, a single line below that the signer's s/ and name and lines.
local function signature(m)
  local sig = need(m, "signature")
  local right = { p(xe.runs("Respectfully submitted,")) }
  local firm = items(sig.firm)
  for i, l in ipairs(firm) do right[#right + 1] = p(xe.inl(l, { b = true }), { before = i == 1 and BODY or 0 }) end
  right[#right + 1] = p(xe.runs("s/ ") .. xe.inl(sig.signer), { before = #firm > 0 and SINGLE or BODY })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(items(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  return above_table() .. table_xml({ TEXTW - SIG_COL, SIG_COL }, { { dated(m) }, { table.concat(right) } })
end

-- The certificate (its own page, no page number): the word count from the frontmatter, the face and size as the
-- typst template prints them.
local function certificate(m)
  local par = function(x) return p(x, { line = BODY, first = 720 }) end
  local sig = need(m, "signature")
  return p(xe.runs("CERTIFICATE OF COMPLIANCE", { b = true }), { line = BODY, keep = true, jc = "center" })
    .. par(xe.runs(brk("1. This memorandum complies with the word-count limit of Local Civil Rule 7.1(c) because it "
      .. "contains ")) .. xe.inl(need(m, "word_count")) .. xe.runs(brk(" words, excluding the caption, table of "
      .. "contents, table of authorities, signature block and this certificate, as counted by the word-processing "
      .. "program used to prepare it.")))
    .. par(xe.runs(brk("2. This memorandum complies with the formatting requirements of Local Civil Rule 7.1(b) "
      .. "because it is printed in " .. FACE .. ", 12-point type, with one-inch margins on all sides, and is "
      .. "double-spaced except for headings, footnotes and block quotations.")))
    .. above_table() .. table_xml({ TEXTW - SIG_COL, SIG_COL }, { { dated(m) },
      { p(xe.runs("Respectfully submitted,")) .. p(xe.runs("s/ ") .. xe.inl(sig.signer), { before = BODY }) } })
end

-- ---------------------------------------------------------------------------
-- The memorandum
-- ---------------------------------------------------------------------------

-- The citations of a list of inlines, in document order, as needles (B in the body, N in a footnote): the link text
-- and the words after it.
local cites = {}
local scan_blocks
local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      local id = "A:" .. (#cites + 1)
      cites[#cites + 1] = { id = id, key = el.target:sub(5) }
      needle(id, in_note and "N" or "B", stringify(el.content), stringify(rest):sub(1, 40))
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

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "court", "case_number", "caption", "title", "counsel", "signature", "date", "word_count" }) do
    local _ = need(m, k)
  end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end

  -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
  local last = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" then last = i end
  end

  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
  local counters = { 0, 0, 0, 0, 0, 0 }
  local entries, body = {}, {}
  local start = nil
  for i, b in ipairs(doc.blocks) do
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local level = math.min(b.level, 6)
      counters[level] = counters[level] + 1
      for l = level + 1, 6 do counters[l] = 0 end
      local lab = label(level, counters[level])
      local id = "H:" .. (#entries + 1)
      needle(id, "B", (lab ~= "" and (lab .. " ") or "") .. stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = level, label = lab, title = b.content }
      local hx = heading(level, lab, b.content)
      -- the heading that opens the body opens a section: Word keeps the space above it there, typst drops it at the
      -- top of a page
      if not start then hx = hx:gsub('w:before="%d+"', 'w:before="0"', 1) end
      body[#body + 1] = xe.raw(hx)
      start = start or id
    else
      if not start then
        start = "S:body"
        needle(start, "B", stringify(b), nxt)
      end
      scan_blocks({ b }, false)
      if b.t == "Para" or b.t == "Plain" then
        local style = i == last and "Body Text Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
        body[#body + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
      elseif b.t == "BlockQuote" then
        body[#body + 1] = b
      else
        error("motion-brief.lua: unsupported block " .. b.t)
      end
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (start or "S:toa") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrNone", nil))

  local out = { xe.raw(cover(m) .. toc(entries) .. toa(authorities, cites) .. section("rIdFtrPage", "lowerRoman")) }
  for _, x in ipairs(pandoc.Blocks(body):walk({ Inlines = xe.inlines })) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m) .. section("rIdFtrPage", "decimal") .. certificate(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
