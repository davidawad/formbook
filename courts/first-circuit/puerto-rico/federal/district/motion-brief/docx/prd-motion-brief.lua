-- prd-motion-brief.lua (docx engine, D.P.R. motion with memorandum): what the Word output adds to pandoc's
-- conversion, so that it reads and breaks as typst/prd-motion-brief.typ does: the cover (court title PRD-CAP-001,
-- caption PRD-CAP-002 with the case number, judge and title, the counsel blocks two to a row), the tables of contents
-- and authorities, the numbered headings (I., A., 1., a. written as text, as typst prints them; PRD-CONT-001), the
-- body, the signature block (PRD-SIG-001) and the certificate of service (PRD-SIG-002). Everything printed comes from
-- the sample's frontmatter and body, except the court's name and the certificate's CM/ECF form sentence (the same in
-- every case, as in the typst template): no case text lives in this file. Caption, counsel and signature are OOXML
-- tables; body paragraphs are pandoc paragraphs (style "Body Text", widow control on as typst keeps two
-- lines together), so pandoc writes their footnotes.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES: the first block of the memorandum, every heading and every `toa:` link, with the words after
-- it, in document order) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they
-- settle. The cover is a section with no footer (rIdFtrNone); the tables number their pages in roman from i
-- (rIdFtrPage); the memorandum numbers its pages from 1 (FORMBOOK_FINAL, rIdFtrPage).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local HALF = 240                         -- typst half-gap 12 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local TAB = 720                          -- typst heading-tab, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left 3.4 in
local CAP_INSET, CAP_PAD = 200, 240      -- typst caption-inset 10 pt, caption-pad 12 pt
local CAP_GUTTER = 480                   -- typst caption-gutter 24 pt
local DESIGNATION = 2016                 -- typst designation-indent 1.4 in
local GUTTER = 432                       -- typst column-gutter 0.3 in
local CERT_SIG = 4896                    -- typst cert-sig-width 3.4 in
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-page-col 36 pt, toa-page-col 72 pt
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local ROW_GAP = 120                      -- typst row-gap 6 pt
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60

local COURT = { "UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF PUERTO RICO" }  -- PRD-CAP-001
local CERT_TEXT = "I HEREBY CERTIFY that on this same date I electronically filed the foregoing with the Clerk of the "
  .. "Court using the CM/ECF system, which will send notification of such filing to all counsel of record."

local function need_meta(meta, k)
  if meta[k] == nil then error("prd-motion-brief: missing required metadata field `" .. k .. "`", 0) end
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

-- A table of one or more rows; rows = { { cell, cell, .. }, .. }, a cell = { pr, body = { xml, .. } }.
local function tbl(widths, rows, trpr)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, w in ipairs(widths) do
      local c = cells[i] or { body = { p("", { line = 20 }) } }
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
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
local function need(id, kind, text, context)
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
-- Cover: court title, caption, counsel
-- ---------------------------------------------------------------------------

-- Groups of lines two to a row, the rows half a line apart; `before` above the first row.
local function two_columns(groups, before)
  local w = (TEXTW - GUTTER) // 2
  local rows = {}
  for i = 1, #groups, 2 do
    local row = {}
    for k = 0, 1 do
      local g = groups[i + k]
      if g then
        local ps = {}
        for j, l in ipairs(g) do ps[#ps + 1] = p(l, { before = j == 1 and (i == 1 and before or HALF) or 0 }) end
        row[#row + 1] = { body = ps }
      end
    end
    if row[1] then row[1].pr = '<w:tcMar><w:right w:w="' .. GUTTER .. '" w:type="dxa"/></w:tcMar>' end
    rows[#rows + 1] = row
  end
  return tbl({ w + GUTTER, TEXTW - w - GUTTER }, rows, "<w:trPr><w:cantSplit/></w:trPr>")
end

local function cover(meta, out)
  for _, l in ipairs(COURT) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true }) end
  -- Left cell: each party's names, then its designation set in; "v." centered between the parties. The caption
  -- stands a double line below the court title (typst: the caption block's above).
  local left = {}
  local sides = need_meta(meta, "caption")
  for i, side in ipairs(sides) do
    if i > 1 then left[#left + 1] = p(xe.runs("v."), { before = HALF, jc = "center" }) end
    for j, n in ipairs(side.names) do
      left[#left + 1] = p(xe.inl(n), { before = (#left == 0) and BODY or (i > 1 and j == 1) and HALF or 0 })
    end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION, after = i == #sides and CAP_PAD or 0 })
  end
  local right = { p(xe.runs("Case No. " .. stringify(meta.case_number)), { before = BODY }) }
  if meta.judge then right[#right + 1] = p(xe.inl(meta.judge)) end
  right[#right + 1] = p(xe.inl(upper(need_meta(meta, "brief_title")), { b = true }), { before = HALF })
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, { {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right },
  } })
  if meta.counsel then
    local groups = {}
    for _, g in ipairs(meta.counsel) do
      local ls = {}
      for _, l in ipairs(g) do ls[#ls + 1] = xe.inl(l) end
      groups[#groups + 1] = ls
    end
    out[#out + 1] = two_columns(groups, BODY)
  end
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities
-- ---------------------------------------------------------------------------

local function table_head(out, title, col, brk)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(title), { b = true }), { jc = "center", keep = true, brk = brk })
  out[#out + 1] = p(xe.runs(col, { b = true }), { jc = "right", before = HALF, keep = true })
end

-- Contents: the label in its box at the heading's indent, the title hanging after it, the page in its column.
local function contents(entries, out)
  table_head(out, "Table of Contents", "Page")
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
  { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" },
  { "regulation", "Regulations" }, { "other", "Other Authorities" },
}

local function authorities(meta, cites, out)
  table_head(out, "Table of Authorities", "Page(s)", true)
  local auth = meta.authorities or {}
  for key in pairs(cites) do
    if auth[key] == nil then
      error("prd-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter", 0)
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
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = HALF, keep = true })
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

-- "Respectfully submitted," and the date on one line, the signing groups two to a row; never split: one table row
-- that cannot split holds them all (LibreOffice does not carry a keep-with-next chain past a table).
local function signature(meta, out)
  local inner = { p(xe.runs("Respectfully submitted,\t") .. xe.runs("Dated: " .. stringify(meta.date)),
    { before = BODY, tabs = '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>' }) }
  local groups = {}
  for _, g in ipairs(need_meta(meta, "signature").groups) do
    local ls = {}
    if g.signer then
      ls[#ls + 1] = xe.runs("By: s/ " .. stringify(g.signer))
      ls[#ls + 1] = xe.runs(stringify(g.signer))
    end
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = xe.inl(l) end
    groups[#groups + 1] = ls
  end
  inner[#inner + 1] = two_columns(groups, HALF)
  -- a cell ends in a paragraph: a 1 pt one
  inner[#inner + 1] = p("", { line = 20 })
  out[#out + 1] = tbl({ TEXTW }, { { { body = inner } } }, "<w:trPr><w:cantSplit/></w:trPr>")
end

-- The certificate: its heading, the form sentence and the place and date, the signer's lines; kept together.
local function certificate(c, out)
  out[#out + 1] = xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(BODY, HALF, SINGLE), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.runs("CERTIFICATE OF SERVICE", { b = true }))
  out[#out + 1] = p(xe.runs(CERT_TEXT), { line = BODY, first = INDENT, keep = true })
  out[#out + 1] = p(xe.runs("In " .. stringify(c.place) .. ", this " .. stringify(c.date) .. "."),
    { line = BODY, first = INDENT, keep = true })
  local lines = { xe.runs("s/ " .. stringify(c.signer)), xe.runs(stringify(c.signer)) }
  for _, l in ipairs(c.lines or {}) do lines[#lines + 1] = xe.inl(l) end
  for j, l in ipairs(lines) do
    out[#out + 1] = p(l, { before = j == 1 and HALF or 0, right = TEXTW - CERT_SIG, keep = j < #lines })
  end
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

-- Headings single-spaced and bold, a double line above and half of one below: level 1 centered in capitals, deeper
-- levels with the label in a box at the level's indent and the title hanging after it; kept with the text.
local function heading(level, label, content, before)
  if level == 1 then
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(before, HALF, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(upper(content), { b = true }))
  end
  local ind = math.max(level - 2, 0) * TAB
  return xe.para({ xe.style("Heading" .. math.min(level, 5)), xe.KEEP,
    '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + TAB) .. '"/></w:tabs>',
    xe.spacing(before, HALF, SINGLE), xe.ind(ind + TAB, TAB), xe.jc("left") },
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

-- The printed text of a block or of inlines, without footnotes (a note is printed at the foot of the page).
local function printed(x)
  local blocks = x.t and { x } or { pandoc.Plain(x) }
  return stringify(pandoc.Pandoc(blocks):walk({ Note = function() return {} end }))
end

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "brief_title", "date", "signature" }) do need_meta(meta, k) end
  local blocks = doc.blocks
  if blocks[1] == nil then error("prd-motion-brief: the memorandum has no body") end

  local body, entries, cites = {}, {}, {}
  local counts = { 0, 0, 0, 0, 0, 0 }
  local h_n, l_n = 0, 0
  -- every `toa:` link of a paragraph or of its footnotes, as a needle: its text and the words after it
  local function links(inlines, kind)
    for i, el in ipairs(inlines) do
      if el.t == "Link" and el.target:match("^toa:") then
        local key = el.target:sub(5)
        l_n = l_n + 1
        local id = "A:" .. l_n
        local after = {}
        for j = i + 1, #inlines do after[#after + 1] = inlines[j] end
        need(id, kind, stringify(el.content), printed(pandoc.Inlines(after)):sub(1, 40))
        cites[key] = cites[key] or {}
        table.insert(cites[key], id)
      elseif el.t == "Note" then
        for _, nb in ipairs(el.content) do
          if nb.content then links(nb.content, "N") end
        end
      end
    end
  end
  -- the memorandum's first page: the page of its first block
  local first_id = "S:1"
  for i, b in ipairs(blocks) do
    local next_text = blocks[i + 1] and printed(blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      counts[b.level] = counts[b.level] + 1
      for j = b.level + 1, #counts do counts[j] = 0 end
      h_n = h_n + 1
      local id = "H:" .. h_n
      if i == 1 then first_id = id end
      local label = heading_label(b.level, counts[b.level])
      need(id, "B", stringify(b.content), next_text)
      entries[#entries + 1] = { id = id, level = b.level, label = label, title = b.content }
      -- the memorandum opens a section (a new page): Word keeps the space above there, typst drops it
      body[#body + 1] = xe.raw(heading(b.level, label, b.content, i == 1 and 0 or BODY))
    elseif b.t == "Para" or b.t == "Plain" then
      if i == 1 then need(first_id, "B", printed(b):sub(1, 40), "") end
      links(b.content, "B")
      local inlines = pandoc.Pandoc({ pandoc.Para(b.content) }):walk({
        Link = function(el) if el.target:match("^toa:") then return el.content end end,
      }):walk({ Inlines = xe.inlines }).blocks[1].content
      body[#body + 1] = pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = "Body Text" })
    else
      error("prd-motion-brief: unsupported block " .. b.t)
    end
  end
  local tail = {}
  signature(meta, tail)
  if meta.certificate then certificate(meta.certificate, tail) end
  for _, x in ipairs(tail) do body[#body + 1] = xe.raw(x) end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\t" .. first_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  local out = {}
  cover(meta, out)
  out[#out + 1] = section("rIdFtrNone")
  contents(entries, out)
  authorities(meta, cites, out)
  out[#out + 1] = section("rIdFtrPage", "lowerRoman")

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  for _, x in ipairs(body) do res[#res + 1] = x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
