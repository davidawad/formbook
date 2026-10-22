-- Motion with memorandum, Bankruptcy Court for the District of Arizona (arb), DOCX engine (docs/DOCX.md): what the
-- Word output adds to pandoc's conversion, so that it reads and breaks as typst/arb-motion-brief.typ does: the filer
-- block from line 1 (LRBP 9004-1(a)), the court title (LRBP 1005-1(a)), the caption (LRBP 9004-1(a), (c), (e)), the
-- headings (numbered I., A., 1., a. under level 2), and the signature block. Paragraphs, list items, quotations and
-- tables stay pandoc's (styles of docx/reference.xml), so pandoc writes their footnotes. The page furniture is this
-- filter's too, since the footer names the paper and its case number: the footer (the pleading numbers 1 to 27 in a
-- frame on the page, the page number, the title and "CASE NO." or "ADV. NO.") goes to $FORMBOOK_FOOTERS and the
-- section that names it to $FORMBOOK_FINAL (fb render, tools/fb/src/docxpass.rs). Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered line, 320 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local PITCH, SINGLE = 480, 320           -- typst pitch, pitch-single
local INDENT = 720                       -- typst heading-tab, 0.5 in
local LINES = 27                         -- typst lines-per-page
local FILER_LINES = 7                    -- typst filer-lines
local TEXTW = 8640                       -- 8.5 in - 1.5 in - 1 in
local CAP_LEFT, CAP_GUTTER = 4464, 288   -- typst caption-left 3.1 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local OFFSET = 128                       -- typst single-offset 6.4 pt: a run of single lines starts this far below a
                                         -- numbered line (every single baseline on a numbered line's or 8 pt off it)
local CAP_PAD = 177                      -- typst caption-pad 9.6 pt, less the 0.75 pt rule LibreOffice adds to a row
local TABLE_GAP = 320                    -- typst table-gap 16 pt above a table; a numbered line below it
local SIG_LEFT, SIG_GUTTER = 3744, 288   -- typst sig-left 2.6 in, sig-gutter 0.2 in
local NUMBERS_W = 1440                   -- typst left-margin - 0.5 in: the box of the pleading numbers
local FOOTER_LINE, FOOTER_SZ, FOOTER_GAP = 260, 22, 80   -- typst pitch-footer, footer-size, footer-line-gap
-- Word measures the footer from the page foot to its last line: the bottom margin (72 pt) less the gap above the
-- footer (typst footer-gap, 6 pt) and the footer's own height (two 13 pt lines and 4 pt between them).
local FOOTER_DIST = 1440 - 120 - 2 * FOOTER_LINE - FOOTER_GAP
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function text(v) return pandoc.utils.stringify(v) end

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A run of single lines (typst line-run): `single-offset` above the first, `after` below the last; false is an
-- empty line.
local function run_of(lines, o)
  o = o or {}
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l or "", { before = i == 1 and OFFSET or 0, after = i == #lines and (o.after or 0) or 0 })
  end
  return out
end

local function tc(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. table.concat(body) ..
    '</w:tc>'
end

local function tbl(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- First page: filer block, court title, caption
-- ---------------------------------------------------------------------------

local COURT = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF ARIZONA" }  -- LRBP 1005-1(a)

local function hearing_rows(meta, rows)
  if not meta.hearing then return end
  local hr = meta.hearing
  rows[#rows + 1] = false
  rows[#rows + 1] = xe.runs("Hearing date: " .. text(hr.date or ""))
  rows[#rows + 1] = xe.runs("Time: " .. text(hr.time or ""))
  rows[#rows + 1] = xe.runs("Place: " .. text(hr.place or ""))
end

local function cover(meta, out)
  local filer = {}
  for _, l in ipairs(meta.filer) do filer[#filer + 1] = xe.inl(l) end
  -- at least filer-lines numbered lines, counted from the lines as typst counts them
  local used = OFFSET + #filer * SINGLE
  for _, x in ipairs(run_of(filer, { after = math.max(FILER_LINES, math.ceil(used / PITCH)) * PITCH - used })) do
    out[#out + 1] = x
  end
  for i, l in ipairs(COURT) do
    -- the caption a numbered line below (Word has no space before a table: the line above carries it)
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = PITCH, jc = "center", keep = true, after = i == #COURT and PITCH or 0 })
  end

  local debtor = meta.debtor
  local debtor_rows = { xe.runs("In re:"), false }
  for _, n in ipairs(debtor.names) do debtor_rows[#debtor_rows + 1] = xe.inl(n) end
  debtor_rows[#debtor_rows + 1] = false
  debtor_rows[#debtor_rows + 1] = xe.runs("Debtor.", { i = true })
  local case_rows = { xe.runs("Chapter " .. text(debtor.chapter)), false, xe.runs("Case No. " .. text(debtor.case_number)) }
  local title_rows = { xe.inl(upper(meta.title), { b = true }), false, xe.inl(meta.relief) }
  hearing_rows(meta, title_rows)

  local rows
  if meta.adversary_number then
    local party_rows = {}
    for k, party in ipairs(meta.parties) do
      if k > 1 then
        party_rows[#party_rows + 1] = false
        party_rows[#party_rows + 1] = xe.runs("v.")
        party_rows[#party_rows + 1] = false
      end
      for _, n in ipairs(party.names) do party_rows[#party_rows + 1] = xe.inl(n) end
      party_rows[#party_rows + 1] = false
      party_rows[#party_rows + 1] = xe.inl(party.designation, { i = true })
    end
    local adv_rows = { xe.runs("Adv. No. " .. text(meta.adversary_number)), false }
    for _, r in ipairs(title_rows) do adv_rows[#adv_rows + 1] = r end
    rows = { { debtor_rows, case_rows }, { party_rows, adv_rows } }
  else
    local right = case_rows
    right[#right + 1] = false
    for _, r in ipairs(title_rows) do right[#right + 1] = r end
    rows = { { debtor_rows, right } }
  end

  local rule = '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>'
  local trs = {}
  for _, r in ipairs(rows) do
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      tc(CAP_LEFT, rule, run_of(r[1], { after = CAP_PAD })) .. tc(CAP_GUTTER, nil, { p("") }) ..
      tc(TEXTW - CAP_LEFT - CAP_GUTTER, '<w:tcMar><w:left w:w="' .. RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>',
        run_of(r[2], { after = CAP_PAD })) .. '</w:tr>'
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, trs)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- heading labels, as typst numbers them: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 is unnumbered
local counters = { 0, 0, 0, 0, 0 }
local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end
local function heading_label(level)
  counters[level] = counters[level] + 1
  for k = level + 1, 5 do counters[k] = 0 end
  if level == 2 then return roman(counters[2]) .. "." end
  if level == 3 then return string.char(64 + counters[3]) .. "." end
  if level == 4 then return tostring(counters[4]) .. "." end
  return string.char(96 + counters[5]) .. "."
end

local function heading(el)
  local lvl = math.min(el.level, 5)
  if lvl == 1 then
    heading_label(1)
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(0, 0, PITCH), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(upper(el.content), { b = true }))
  end
  -- the label hangs from an indent of one tab per level below 2, the text a tab after it (typst heading-rule);
  -- no Heading style below level 3: the recipe sets levels 4 and 5 italic, typst none
  local ind = (lvl - 2) * INDENT
  return xe.para({ lvl <= 3 and xe.style("Heading" .. lvl) or "", xe.KEEP,
    '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + INDENT) .. '"/></w:tabs>', xe.spacing(0, 0, PITCH),
    xe.ind(ind + INDENT, INDENT), xe.jc("left"), '<w:outlineLvl w:val="' .. (lvl - 1) .. '"/>' },
    xe.runs(heading_label(lvl) .. "\t", { b = true }) .. xe.inl(el.content, { b = true }))
end

local function has_note(inlines)
  local found = false
  pandoc.Inlines(inlines):walk({ Note = function() found = true end })
  return found
end

local function styled(style, blocks)
  return pandoc.Div(blocks, { ["custom-style"] = style })
end

-- An empty line of `h` twips (the space a typst block keeps above or below a table), kept with what follows.
local function gap(h)
  return xe.raw(xe.para({ xe.KEEP, xe.spacing(0, 0, h), xe.ind(0, nil, 0) }, ""))
end

-- A pipe table: equal columns (typst data-table), its cells in style Compact, the table in the geometry of style Table
-- of docx/reference.xml (thin rules, the cell padding), the header row repeated on every page. Written here, so that
-- no row splits across a page (w:cantSplit, typst table.cell breakable: false), unless a cell holds a footnote: pandoc
-- writes that table, for its footnotes are Word's own (pandoc sets no w:cantSplit, and LibreOffice reads none from the
-- table style, so such a table's row may split across a page where typst's does not).
local function data_table(t)
  local n = #t.colspecs
  for i = 1, n do t.colspecs[i] = { pandoc.AlignDefault, 1 / n } end
  local noted = false
  t:walk({ Note = function() noted = true end })
  if noted then return t end
  local rows = {}
  for _, r in ipairs(t.head.rows) do rows[#rows + 1] = { cells = r.cells, head = true } end
  for _, b in ipairs(t.bodies) do
    for _, r in ipairs(b.body) do rows[#rows + 1] = { cells = r.cells } end
  end
  local w = TEXTW // n
  local widths, grid = {}, {}
  for i = 1, n do
    widths[i] = i < n and w or TEXTW - w * (n - 1)
    grid[#grid + 1] = '<w:gridCol w:w="' .. widths[i] .. '"/>'
  end
  local trs = {}
  for _, r in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(r.cells) do
      local ps = {}
      for _, cb in ipairs(c.contents) do
        ps[#ps + 1] = xe.para({ xe.style("Compact") }, xe.inl(cb.content or {}))
      end
      if #ps == 0 then ps[1] = xe.para({ xe.style("Compact") }, "") end
      tcs[#tcs + 1] = tc(widths[i], nil, ps)
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/>' .. (r.head and '<w:tblHeader/>' or "") .. '</w:trPr>' ..
      table.concat(tcs) .. '</w:tr>'
  end
  return xe.raw('<w:tbl><w:tblPr><w:tblStyle w:val="Table"/><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblLayout w:type="fixed"/><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0"' ..
    ' w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' ..
    table.concat(trs) .. '</w:tbl>')
end

local function body(blocks)
  local out = {}
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      -- a paragraph that carries a footnote mark has no widow control (typst lets its line move on alone); the
      -- last is kept with the signature block
      local style = last and "Body Text Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
      out[#out + 1] = styled(style, { pandoc.Para(b.content) })
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    elseif b.t == "BlockQuote" then
      local paras = {}
      for _, q in ipairs(b.content) do paras[#paras + 1] = pandoc.Para(q.content) end
      out[#out + 1] = styled("Block Quote", paras)
    elseif b.t == "Table" then
      out[#out + 1] = gap(TABLE_GAP)
      out[#out + 1] = data_table(b)
      out[#out + 1] = gap(PITCH - 10)   -- a numbered line, less the 0.5 pt of the top rule Word adds to the table
    else
      error("arb-motion: unsupported block " .. b.t)
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local rows = { xe.runs("Respectfully submitted,"), false, xe.runs("/s/ " .. text(sig.signer)) }
  for _, l in ipairs(sig.lines or {}) do rows[#rows + 1] = xe.inl(l) end
  return tbl({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER }, { '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    tc(SIG_LEFT, nil, run_of({ xe.runs("Dated: " .. text(meta.date)) })) .. tc(SIG_GUTTER, nil, { p("") }) ..
    tc(TEXTW - SIG_LEFT - SIG_GUTTER, nil, run_of(rows)) .. '</w:tr>' })
end

-- ---------------------------------------------------------------------------
-- Page furniture: footer and the section
-- ---------------------------------------------------------------------------

local function footer(title, right)
  local fr = '<w:framePr w:w="' .. NUMBERS_W .. '" w:h="' .. (LINES * PITCH) .. '" w:hRule="exact" w:hSpace="0"' ..
    ' w:wrap="around" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="1440"/>'
  local x = {}
  -- the pleading numbers: one per numbered line, right-aligned left of the rules (typst line-numbers)
  for i = 1, LINES do
    x[#x + 1] = '<w:p><w:pPr>' .. fr .. xe.spacing(0, 0, PITCH) .. xe.jc("right") .. '</w:pPr>' .. xe.runs(tostring(i)) ..
      '</w:p>'
  end
  local o = { sz = FOOTER_SZ }
  x[#x + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, FOOTER_LINE) .. xe.jc("center") .. '</w:pPr>' ..
    '<w:r>' .. xe.rpr(o) .. '<w:fldChar w:fldCharType="begin"/></w:r><w:r>' .. xe.rpr(o) ..
    '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>' .. xe.rpr(o) ..
    '<w:fldChar w:fldCharType="separate"/></w:r><w:r>' .. xe.rpr(o) .. '<w:t>1</w:t></w:r><w:r>' .. xe.rpr(o) ..
    '<w:fldChar w:fldCharType="end"/></w:r></w:p>'
  x[#x + 1] = '<w:p><w:pPr><w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>' ..
    xe.spacing(FOOTER_GAP, 0, FOOTER_LINE) .. xe.jc("left") .. '</w:pPr>' .. xe.runs(title .. "\t" .. right, o) .. '</w:p>'
  return table.concat(x)
end

local function write_file(var, s)
  local path = os.getenv(var)
  if not path then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

local function furniture(meta)
  -- the footer title as written in the frontmatter (typst reads the string, not markdown)
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  local s = f and f:read("a") or ""
  if f then f:close() end
  local raw = s ~= "" and pandoc.json.decode(s, false) or {}
  local title = raw.footer_title or text(meta.footer_title)
  local right = meta.adversary_number and ("ADV. NO. " .. text(meta.adversary_number)) or
    ("CASE NO. " .. text(meta.debtor.case_number))
  write_file("FORMBOOK_FOOTERS", "rIdArbFooter\t" .. footer(pandoc.text.upper(title), right) .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdArbFooter"/>' ..
    '<w:footnotePr><w:numRestart w:val="continuous"/></w:footnotePr>' ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160"' ..
    ' w:header="720" w:footer="' .. FOOTER_DIST .. '" w:gutter="0"/><w:pgBorders w:offsetFrom="text">' ..
    '<w:left w:val="double" w:sz="4" w:space="12" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders></w:sectPr>')
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 547"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local t = a.text
      if #t >= 4 and t:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
        inlines[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return inlines
end

function Pandoc(doc)
  for _, k in ipairs({ "filer", "debtor", "title", "relief", "footer_title", "date", "signature" }) do
    if doc.meta[k] == nil then error("arb-motion: missing required metadata field `" .. k .. "`", 0) end
  end
  if doc.meta.adversary_number and doc.meta.parties == nil then
    error("arb-motion: missing required metadata field `parties`", 0)
  end
  local meta = doc.meta
  doc = pandoc.Pandoc(doc.blocks):walk({ Str = breaks }):walk({ Inlines = signs }):walk({ Inlines = xe.inlines })
  local raw = {}
  cover(meta, raw)
  local blocks = {}
  for _, x in ipairs(raw) do blocks[#blocks + 1] = xe.raw(x) end
  -- the last block is kept with the signature block
  for _, b in ipairs(body(doc.blocks)) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = xe.raw(signature(meta))
  furniture(meta)
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
