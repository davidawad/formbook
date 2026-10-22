-- Memorandum, United States District Court for the District of Alaska (akd), DOCX engine (docs/DOCX.md): what the
-- Word output adds to pandoc's conversion, so that it reads and breaks as typst/akd-motion-brief.typ does: the cover
-- (counsel block, court title, caption with the case number and judge, title and statute; L.R. 7.5(b), 8.1(a)), the
-- tables of contents and authorities, the numbered headings (I., A., 1., a. written as text, as typst prints them),
-- the body, the signature block (L.R. 7.5(c)) and the certificate of service, and the footer with the page number,
-- the short title and the case name and number on every page (L.R. 7.5(a)(1)(C)). Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file. The caption is an OOXML table; body paragraphs are
-- pandoc paragraphs ("Body Text"), so pandoc writes their footnotes.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 600 the double-spaced body, 300 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES: the memorandum's first block, every heading and every `toa:` link, with the words after it, in
-- document order) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle. The
-- cover and the tables are one section numbered in lower-case roman from i; the memorandum numbers its pages from 1
-- (FORMBOOK_FINAL). Both name the footer this filter writes (FORMBOOK_FOOTERS, rIdFtrAkd).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 600, 300            -- typst pitch-double, pitch-single
local HALF, SMALL = 300, 120             -- typst half-gap 15 pt, small-gap 6 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local TAB = 720                          -- typst heading-tab, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 160   -- typst caption-left 3.4 in, caption-gutter 8 pt
local CAP_INSET = 160                    -- typst caption-inset 8 pt
local CAP_PAD = 145                      -- caption-inset less the 0.75 pt rule LibreOffice adds to the row
local COURT_DROP = 1152                  -- typst court-drop 0.8 in
local SIG = 3600                         -- typst sig-indent 2.5 in
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-page-col 36 pt, toa-page-col 72 pt
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function need_meta(meta, k)
  if meta[k] == nil then error("akd-motion-brief: the sample frontmatter needs `" .. k .. "`", 0) end
  return meta[k]
end

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, brk, tabs, border }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.border then props[#props + 1] = '<w:pBdr><w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>' end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
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
-- Footer and sections (L.R. 7.5(a)(1)(B)-(C)): page number, short title, case name and number, single lines,
-- centered, in the bottom margin, its top 6 pt below the text area (typst footer-gap): its last line ends 21 pt above
-- the page foot (792 - 720 - 6 - 3 x 15).
-- ---------------------------------------------------------------------------

local PAGE = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'

local function footer(meta)
  local function line(runs)
    return '<w:p><w:pPr>' .. xe.spacing(0, 0, SINGLE) .. xe.jc("center") .. '</w:pPr>' .. runs .. '</w:p>'
  end
  return "rIdFtrAkd\t" .. line(PAGE) .. line(xe.inl(meta.footer_title))
    .. line(xe.inl(meta.case_name) .. xe.runs(", Case No. " .. stringify(meta.case_number))) .. "\n"
end

local function sect_pr(fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrAkd"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="420" w:gutter="0"/><w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/></w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, caption, title (L.R. 7.5(b))
-- ---------------------------------------------------------------------------

local function cell(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

local function cover(meta, out)
  for _, l in ipairs(need_meta(meta, "counsel")) do out[#out + 1] = p(xe.inl(l)) end
  for i, l in ipairs(need_meta(meta, "court")) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { before = i == 1 and COURT_DROP or 0, jc = "center", keep = true })
  end
  -- The caption stands a double line below the court title: Word has no space before a table, so the first
  -- paragraph of each cell carries it.
  local left = {}
  local sides = need_meta(meta, "caption")
  for i, s in ipairs(sides) do
    for j, n in ipairs(s.names) do
      left[#left + 1] = p(xe.inl(n), { before = (i == 1 and j == 1) and BODY or (j == 1 and HALF or 0) })
    end
    left[#left + 1] = p(xe.inl(s.designation), { before = SMALL, jc = "right", after = i == #sides and CAP_PAD or 0 })
  end
  local right = p(xe.runs("No. " .. stringify(meta.case_number)), { before = BODY })
  if meta.judge then right = right .. p(xe.inl(meta.judge)) end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="'
    .. (TEXTW - CAP_LEFT - CAP_GUTTER) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_LEFT, '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders><w:tcMar><w:right w:w="'
      .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', table.concat(left))
    .. cell(CAP_GUTTER, nil, p("", { before = BODY }))
    .. cell(TEXTW - CAP_LEFT - CAP_GUTTER, nil, right)
    .. '</w:tr></w:tbl>'
  out[#out + 1] = p(xe.inl(upper(need_meta(meta, "title")), { b = true }), { before = BODY, jc = "center" })
  if meta.statute then out[#out + 1] = p(xe.runs("(") .. xe.inl(meta.statute) .. xe.runs(")"), { jc = "center" }) end
  if meta.oral_argument then out[#out + 1] = p(xe.runs("Oral Argument Requested", { b = true }), { jc = "center" }) end
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities
-- ---------------------------------------------------------------------------

local function table_head(out, title, col)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(title), { b = true }), { jc = "center", keep = true, brk = true })
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
        { lines = true, tabs = row_tabs(ind + TAB), before = SMALL, left = ind + TAB, hanging = TAB, right = TOC_COL })
    end
  end
end

local GROUPS = {
  { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" },
  { "regulation", "Regulations" }, { "other", "Other Authorities" },
}

local function authorities(meta, cites, out)
  table_head(out, "Table of Authorities", "Page(s)")
  local auth = meta.authorities or {}
  for key in pairs(cites) do
    if auth[key] == nil then
      error("akd-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter", 0)
    end
  end
  local function sort_key(a) return pandoc.text.lower(stringify(a.sort or a.name or a.cite)) end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if stringify(a.kind) == g[1] and cites[key] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
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
          { lines = true, tabs = row_tabs(), before = SMALL, left = TOA_HANG, hanging = TOA_HANG, right = TOA_COL })
      end
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block (L.R. 7.5(c)) and certificate of service
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = need_meta(meta, "signature")
  local lines = {}
  if meta.date then lines[#lines + 1] = { xe.inl(meta.date), { before = BODY, left = INDENT } } end
  for j, l in ipairs(sig.preamble or {}) do
    lines[#lines + 1] = { xe.inl(l), { before = j == 1 and (#lines == 0 and BODY or HALF) or 0, left = SIG } }
  end
  lines[#lines + 1] = { xe.runs("/s/ " .. stringify(sig.signer)), { before = #lines == 0 and BODY or HALF, left = SIG } }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { xe.inl(l), { left = SIG } } end
  for i, l in ipairs(lines) do
    l[2].keep = i < #lines
    out[#out + 1] = p(l[1], l[2])
  end
end

local function certificate(c, out)
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", keep = true, brk = true })
  out[#out + 1] = p(xe.inl(c.text), { before = HALF, line = BODY, first = INDENT })
  out[#out + 1] = p(xe.inl(c.signer), { before = 2 * BODY, left = SIG, border = true })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
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

-- A doubled sign stays with its number ("§§ 1331"), as the typst template boxes it (xe.inl binds a single sign).
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

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- `toa:` links print their text only.
local function unlink(x)
  return x:walk({ Link = function(el) if el.target:match("^toa:") then return el.content end end })
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, k in ipairs({ "court", "case_number", "case_name", "footer_title", "caption", "counsel", "title", "signature" }) do
    need_meta(meta, k)
  end
  doc = pandoc.Pandoc(doc.blocks):walk({ Str = breaks }):walk({ Inlines = signs })
  local blocks = doc.blocks
  if blocks[1] == nil then error("akd-motion-brief: the memorandum has no body") end

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
  -- the label each heading prints (a heading's needle runs on into the next heading, label and all)
  local labs, c2 = {}, { 0, 0, 0, 0, 0, 0 }
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      c2[b.level] = c2[b.level] + 1
      for j = b.level + 1, #c2 do c2[j] = 0 end
      labs[i] = heading_label(b.level, c2[b.level])
    end
  end
  for i, b in ipairs(blocks) do
    local next_text = blocks[i + 1] and ((labs[i + 1] or "") .. " " .. printed(blocks[i + 1])):sub(1, 40) or ""
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
      local inlines = unlink(pandoc.Pandoc({ pandoc.Para(b.content) })):walk({ Inlines = xe.inlines }).blocks[1].content
      -- the last paragraph is kept with the signature block (typst: a sticky block); one that carries a footnote
      -- mark has no widow control (typst lets the line with the mark move on alone when its note does not fit)
      local style = (i == #blocks and not has_note(inlines)) and "Body Text Keep"
        or has_note(inlines) and "Body Text Note" or "Body Text"
      body[#body + 1] = pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do if q.content then links(q.content, "B") end end
      -- L.R. 7.5(a)(1)(A): quotations single-spaced and indented (the reference's Block Text)
      body[#body + 1] = unlink(pandoc.Pandoc({ b })):walk({ Inlines = xe.inlines }).blocks[1]
    else
      error("akd-motion-brief: unsupported block " .. b.t)
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
  write_file("FORMBOOK_FOOTERS", footer(meta))
  write_file("FORMBOOK_FINAL", sect_pr("decimal"))

  local out = {}
  cover(meta, out)
  contents(entries, out)
  authorities(meta, cites, out)
  out[#out + 1] = section("lowerRoman")

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  for _, x in ipairs(body) do res[#res + 1] = x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
