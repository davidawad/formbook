-- alnd motion brief (memorandum in support), docx engine: what the Word output adds to pandoc's conversion, so that
-- it reads and breaks as typst/alnd-motion-brief.typ does: the cover (court title, caption, title of the paper), the
-- tables of contents and authorities, the numbered headings (I., A., 1., a. written as text, as typst prints them),
-- the body, the signature block and the certificate of service. Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES: every heading and every `toa:` link, with the words after it, in document order) in the
-- LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle. The cover is a section with
-- no footer (rIdFtrNone); the tables number their pages in roman from i (rIdFtrPage); the body numbers its pages
-- from 1 (FORMBOOK_FINAL, rIdFtrPage). Word may paginate slightly differently.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TAB = 720                          -- typst heading-tab, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_INSET, CAP_PAD = 280, 138      -- typst caption-inset 14 pt, caption-pad (half a single line)
local DESIGNATION = 2592                 -- typst designation-indent 1.8 in
local TITLE_INSET = 702                  -- typst title-inset 35.1 pt
local SIG_GUTTER = 432                   -- typst sig-gutter 0.3 in
local CERT_SIG = 4608                    -- typst cert-sig-width 3.2 in
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-page-col 36 pt, toa-page-col 72 pt
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local ROW_GAP, GROUP_GAP = 120, 240      -- typst row-gap 6 pt, group-gap 12 pt
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60

local function need_meta(meta, k)
  if meta[k] == nil then error("alnd-motion-brief: missing required metadata field `" .. k .. "`", 0) end
  return meta[k]
end

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- A left tab at `at` (a label's box) and the dot leader to the page column.
local function row_tabs(at)
  return '<w:tabs>' .. (at and ('<w:tab w:val="left" w:pos="' .. at .. '"/>') or "") ..
    '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = "B", needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
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
-- Sections
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="732" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  for _, l in ipairs(need_meta(meta, "court")) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", keep = true })
  end
  -- Left cell: each party's names, then its designation set in; "v." centered between the parties. The caption
  -- stands a double line below the court title (typst: the caption block's above).
  local left = {}
  local sides = need_meta(meta, "caption")
  for k, side in ipairs(sides) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { jc = "center" }) end
    for _, n in ipairs(side.names) do left[#left + 1] = p(xe.inl(n), { before = #left == 0 and BODY or 0 }) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION, after = k == #sides and CAP_PAD or 0 })
  end
  local right = { p(xe.inl(need_meta(meta, "case_label")) .. xe.runs(" ") .. xe.inl(need_meta(meta, "case_number")),
    { before = BODY }) }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ TEXTW // 2, TEXTW // 2 }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(upper(need_meta(meta, "brief_title")), { b = true }),
    { before = BODY, jc = "center", left = TITLE_INSET, right = TITLE_INSET })
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities
-- ---------------------------------------------------------------------------

local function table_head(out, title, col, brk)
  out[#out + 1] = p(xe.runs(title, { b = true }), { jc = "center", keep = true, brk = brk })
  out[#out + 1] = p(xe.runs(col, { b = true }), { jc = "right", before = GROUP_GAP, keep = true })
end

-- Contents: the label in its box at the heading's indent, the title hanging after it, the page in its column.
local function contents(entries, out)
  table_head(out, "TABLE OF CONTENTS", "Page")
  for _, e in ipairs(entries) do
    if e.level <= 4 then
      local ind = math.max(e.level - 2, 0) * TAB
      local lab = e.label ~= "" and xe.runs(e.label .. "\t") or ""
      local title = e.level == 1 and upper(e.title) or e.title
      out[#out + 1] = p(lab .. xe.inl(title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
        { lines = true, tabs = row_tabs(ind + TAB), before = ROW_GAP, left = ind + TAB, hanging = TAB, right = TOC_COL })
    end
  end
end

local GROUPS = {
  { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" }, { "other", "Other Authorities" },
}

local function authorities(meta, cites, out)
  table_head(out, "TABLE OF AUTHORITIES", "Page(s)", true)
  local auth = meta.authorities or {}
  for key in pairs(cites) do
    if auth[key] == nil then
      error("alnd-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter", 0)
    end
  end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if stringify(a.kind) == g[1] and cites[key] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      local kx = pandoc.text.lower(stringify(x.a.name or x.a.cite))
      local ky = pandoc.text.lower(stringify(y.a.name or y.a.cite))
      return kx < ky
    end)
    if #members > 0 then
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = GROUP_GAP, keep = true })
      for _, m in ipairs(members) do
        -- distinct printed page labels, in document order
        local pages, seen = {}, {}
        for _, id in ipairs(cites[m.key]) do
          local l = labels[id] or "0"
          if not seen[l] then seen[l] = true; pages[#pages + 1] = l end
        end
        local pg = #pages >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pages, ", "))
        local name = ""
        if m.a.name then name = xe.inl(m.a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        out[#out + 1] = p(name .. xe.inl(m.a.cite) .. xe.runs(xe.LEAD) .. pg,
          { lines = true, tabs = row_tabs(), before = ROW_GAP, left = TOA_HANG, hanging = TOA_HANG, right = TOA_COL })
      end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

local function sig_par(l, before)
  return p(stringify(l) == "" and "" or xe.inl(l), { before = before })
end

-- The date line, the firms side by side (an empty entry is a blank line), the closing lines; never split: one
-- table row that cannot split holds them all (LibreOffice does not carry a keep-with-next chain past a table).
local function signature(meta, out)
  local sig = need_meta(meta, "signature")
  local inner = { p(xe.inl(need_meta(meta, "date_line")), { before = BODY }) }
  local n = #sig.firms
  local w = (TEXTW - SIG_GUTTER * (n - 1)) // n
  local widths, cells = {}, {}
  for i, lines in ipairs(sig.firms) do
    local ps = {}
    for j, l in ipairs(lines) do ps[#ps + 1] = sig_par(l, j == 1 and BODY or 0) end
    if i < n then
      widths[#widths + 1] = w + SIG_GUTTER
      cells[#cells + 1] = { pr = '<w:tcMar><w:right w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = ps }
    else
      widths[#widths + 1] = TEXTW - (w + SIG_GUTTER) * (n - 1)
      cells[#cells + 1] = { body = ps }
    end
  end
  inner[#inner + 1] = tbl(widths, cells)
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do inner[#inner + 1] = sig_par(l, i == 1 and BODY or 0) end
  -- a cell ends in a paragraph: a 1 pt one when there are no closing lines
  if #lines == 0 then inner[#inner + 1] = p("", { line = 20 }) end
  out[#out + 1] = tbl({ TEXTW }, { { body = inner } }, "<w:trPr><w:cantSplit/></w:trPr>")
end

-- The certificate on a page of its own: its heading, the text, the signature at the right margin; never split.
local function certificate(c, out)
  out[#out + 1] = xe.para({ xe.style("Heading1"), xe.KEEP, xe.BREAK, xe.spacing(0, SINGLE, SINGLE), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(upper(c.title), { b = true }))
  out[#out + 1] = p(xe.inl(c.text), { line = BODY, first = INDENT, keep = true })
  local left = TEXTW - CERT_SIG
  out[#out + 1] = p(xe.inl(c.date_line), { before = BODY, left = left, keep = true })
  out[#out + 1] = p(xe.runs("/s/ ") .. xe.inl(c.signer), { before = BODY, left = left, keep = true })
  out[#out + 1] = p(xe.inl(c.signer), { left = left })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return s
end

-- typst heading-num: level 2 "I.", 3 "A.", 4 "1.", 5 "a.", level 1 none.
local function heading_label(level, k)
  if level == 2 then return roman(k) .. "." end
  if level == 3 then return string.char(64 + k) .. "." end
  if level == 4 then return k .. "." end
  if level == 5 then return string.char(96 + k) .. "." end
  return ""
end

-- Headings single-spaced and bold, a single line above and below: level 1 centered in capitals, deeper levels with
-- the label in a box at the level's indent and the title hanging after it; kept with the text.
local function heading(level, label, content, before)
  if level == 1 then
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(before, SINGLE, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(upper(content), { b = true }))
  end
  local ind = math.max(level - 2, 0) * TAB
  return xe.para({ xe.style("Heading" .. level), xe.KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + TAB) .. '"/></w:tabs>',
    xe.spacing(before, SINGLE, SINGLE), xe.ind(ind + TAB, TAB), xe.jc("left") },
    xe.runs(label .. "\t", { b = true }) .. xe.inl(content, { b = true }))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" and #a.text >= 4 and a.text:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  for _, k in ipairs({ "court", "caption", "case_label", "case_number", "brief_title", "signature", "date_line" }) do
    need_meta(meta, k)
  end
  local blocks = doc.blocks

  local body, entries, cites = {}, {}, {}
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n, l_n = 0, 0
  -- every `toa:` link of a paragraph, as a needle: its text and the words after it
  local function links(inlines)
    for i, el in ipairs(inlines) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        l_n = l_n + 1
        local id = "A:" .. l_n
        local after = {}
        for j = i + 1, #inlines do after[#after + 1] = inlines[j] end
        need(id, stringify(el.content), stringify(pandoc.Inlines(after)):sub(1, 40))
        cites[key] = cites[key] or {}
        table.insert(cites[key], id)
      end
    end
  end
  for i, b in ipairs(blocks) do
    local next_text = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      counts[b.level] = counts[b.level] + 1
      for j = b.level + 1, #counts do counts[j] = 0 end
      h_n = h_n + 1
      local id = "H:" .. h_n
      local label = heading_label(b.level, counts[b.level])
      need(id, stringify(b.content), next_text)
      entries[#entries + 1] = { id = id, level = b.level, label = label, title = b.content }
      -- the body opens a section (a new page): Word keeps the space above there, typst drops it
      body[#body + 1] = heading(b.level, label, b.content, i == 1 and 0 or SINGLE)
    elseif b.t == "Para" or b.t == "Plain" then
      links(b.content)
      body[#body + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        links(q.content)
        body[#body + 1] = p(xe.inl(q.content), { line = BODY, left = INDENT, right = INDENT })
      end
    else
      error("alnd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, body)
  if meta.certificate then
    h_n = h_n + 1
    local id = "H:" .. h_n
    need(id, stringify(meta.certificate.title), stringify(meta.certificate.text):sub(1, 40))
    entries[#entries + 1] = { id = id, level = 1, label = "", title = meta.certificate.title }
    certificate(meta.certificate, body)
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  if blocks[1] == nil or blocks[1].t ~= "Header" then error("alnd-motion-brief.lua: the body must open with a heading") end
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  local out = {}
  cover(meta, out)
  out[#out + 1] = section("rIdFtrNone")
  contents(entries, out)
  authorities(meta, cites, out)
  out[#out + 1] = section("rIdFtrPage", "lowerRoman")
  for _, x in ipairs(body) do out[#out + 1] = x end

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
