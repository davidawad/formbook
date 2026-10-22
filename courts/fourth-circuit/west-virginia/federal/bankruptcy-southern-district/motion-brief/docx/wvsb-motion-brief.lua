-- wvsb-motion-brief.lua (docx engine): the S.D. W. Va. bankruptcy motion as Word paragraphs and tables, so
-- that it reads and breaks as ../typst/wvsb-motion-brief.typ does:
--   * the court title, the caption table (the sides of the case on the left, a rule under and beside them, the case
--     information on the right), the debtors note under the caption, the title, the headings (level 1 centered
--     capitals, deeper levels labelled A., 1., a.), the block quotations, the signature block (the prayer, the date,
--     then the counsel blocks two to a row) and the certificate of service on a page of its own, written here;
--   * the body: pandoc's paragraphs and footnotes in the Body Text and Footnote Text styles of docx/reference.xml
--     (the author types the paragraph numbers "1\."; they stay text).
-- No case text is in this file: every string comes from the frontmatter of the sample (schema: ../README.md).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line, 230 a line of
-- the 10 pt note), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, NOTE, GAP = 480, 276, 230, 240 -- typst pitch-body, pitch-single, pitch-note, gap (half a body line)
local NOTE_SZ = 20                       -- typst note-size 10 pt, in half points
local INDENT = 720                       -- typst para-indent 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4680                    -- typst caption-left 3.25 in
local CAP_INSET = 288                    -- typst caption-inset 0.2 in
local SEP_INDENT, DESIG_INDENT = 1728, 2592 -- typst sep-indent 1.2 in, designation-indent 1.8 in
local SIG = 4608                         -- typst sig-column 3.2 in
local TAB = 720                          -- typst heading-tab 0.5 in
local QUOTE = 720                        -- typst quote-inset 0.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(v)
  local out = {}
  for _, x in ipairs(v or {}) do out[#out + 1] = x end
  return out
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, tab, jc, keep, page, outline };
-- single-spaced unless o.line.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.page then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

-- A borderless fixed table; rows: list of cells { pr, body }; trpr on every row.
local function tbl(widths, rows, trpr)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local trs = {}
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, w in ipairs(widths) do
      local c = cells[i] or { body = { p("") } }
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local function upper(m)
  return pandoc.Inlines(m):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- The note mark on a designation (typst super[\*]: LibreOffice's superscript is the same 58 %).
local MARK = '<w:r><w:rPr><w:vertAlign w:val="superscript"/></w:rPr><w:t>*</w:t></w:r>'

-- ---------------------------------------------------------------------------
-- Court title, caption, note, title (typst: caption and the first page)
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  local court = list(meta.court)
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(l), { jc = "center", after = i == #court and BODY or 0 })
  end
  local sides = list(meta.caption)
  local left = {}
  local notes = {}
  for i, side in ipairs(sides) do
    if side.sep then left[#left + 1] = p(xe.inl(side.sep), { before = GAP, after = GAP, left = SEP_INDENT }) end
    local first = i > 1 and not side.sep
    for j, n in ipairs(list(side.names)) do
      left[#left + 1] = p(xe.inl(n), { before = (first and j == 1) and GAP or 0 })
    end
    local d = xe.inl(side.designation)
    if side.footnote then
      d = d .. MARK
      notes[#notes + 1] = side.footnote
    end
    left[#left + 1] = p(d, { left = DESIG_INDENT, after = i == #sides and GAP or 0 })
  end
  local right = {}
  for _, l in ipairs(list(meta.case_info)) do right[#right + 1] = p(xe.inl(l)) end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, { {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  } })
  -- the debtors note under the caption, in the flow (typst: a 10 pt block half a gap below the caption)
  for _, n in ipairs(notes) do
    out[#out + 1] = p(xe.runs("* ", { sz = NOTE_SZ }) .. xe.inl(n, { sz = NOTE_SZ }), { before = GAP / 2, line = NOTE })
  end
  -- Word has no space after a table: the title takes the space before it
  out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { jc = "center", before = BODY, after = GAP })
end

-- ---------------------------------------------------------------------------
-- Signature block (typst: signature-block): the prayer, the date, the preamble and the counsel blocks, kept on one
-- page, as typst's unbreakable block. `first`: the space above it.
-- ---------------------------------------------------------------------------

local function signature(sig, closing, out)
  local before = BODY
  if closing then
    out[#out + 1] = p(xe.inl(closing), { keep = true, before = before, after = GAP, line = BODY, first = INDENT })
    before = 0
  end
  local dated = sig.dated ~= nil
  if dated then
    out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(sig.dated), { keep = true, before = before })
    before = GAP
  end
  for i, l in ipairs(list(sig.preamble)) do
    out[#out + 1] = p(xe.inl(l), { keep = true, before = i == 1 and before or 0, left = TEXTW - SIG })
    before = GAP
  end
  local blocks = list(sig.blocks)
  local rows = {}
  for r = 1, #blocks, 2 do
    local row = {}
    for c = 0, 1 do
      local blk = blocks[r + c]
      if blk then
        local body = {}
        for j, l in ipairs(list(blk)) do body[#body + 1] = p(xe.inl(l), { keep = true, before = j == 1 and before or 0 }) end
        row[#row + 1] = { body = body }
      end
    end
    rows[#rows + 1] = row
    before = GAP
  end
  if #rows > 0 then out[#out + 1] = tbl({ TEXTW - SIG, SIG }, rows, '<w:trPr><w:cantSplit/></w:trPr>') end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Heading labels (typst heading-num): level 2 "A.", level 3 "1.", level 4 "a."; level 1 is unnumbered.
local function label(level, k)
  if level == 2 then return string.char(64 + k) .. "." end
  if level == 3 then return k .. "." end
  if level == 4 then return string.char(96 + k) .. "." end
  return ""
end

-- Headings: single-spaced, half a body line above and below, kept with the text; level 1 centered bold capitals;
-- deeper levels the label (level - 2) half inches in, a tab to the bold title, the title hanging.
local function heading(el, k)
  if el.level == 1 then
    return p(xe.inl(upper(el.content), { b = true }), { keep = true, before = GAP, after = GAP, jc = "center", outline = 0 })
  end
  local ind = (el.level - 2) * TAB
  return p(xe.runs(label(el.level, k) .. "\t", { b = true }) .. xe.inl(el.content, { b = true }),
    { keep = true, before = GAP, after = GAP, left = ind + TAB, hanging = TAB, tab = ind + TAB, outline = el.level - 1 })
end

-- A body paragraph (pandoc writes it, footnotes included): Body Text, the body pitch, a half-inch first-line indent.
-- A paragraph that anchors a footnote is set without widow control (Body Text Note): typst moves its last line alone
-- to the next page when the note does not fit, which Word's widow control would not.
local function body_par(inlines)
  local para = pandoc.Para(inlines):walk({ Inlines = xe.inlines })
  local note = false
  para:walk({ Note = function() note = true end })
  return pandoc.Div({ para }, { ["custom-style"] = note and "Body Text Note" or "Body Text" })
end

-- A block quotation (typst: show quote): single-spaced paragraphs inset half an inch on both sides, half a body line
-- around the quotation and between its paragraphs.
local function quotation(b, out)
  local paras = {}
  for _, x in ipairs(b.content) do
    if x.t ~= "Para" and x.t ~= "Plain" then error("wvsb-motion-brief.lua: unsupported block in a quotation: " .. x.t) end
    paras[#paras + 1] = x
  end
  for i, x in ipairs(paras) do
    out[#out + 1] = xe.raw(p(xe.inl(x.content), { before = GAP, after = i == #paras and GAP or 0, left = QUOTE,
      right = QUOTE }))
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local head = {}
  cover(meta, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end
  local counter = { 0, 0, 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      counter[b.level] = counter[b.level] + 1
      for j = b.level + 1, #counter do counter[j] = 0 end
      out[#out + 1] = xe.raw(heading(b, counter[b.level]))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content)
    elseif b.t == "BlockQuote" then
      quotation(b, out)
    else
      error("wvsb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  local tail = {}
  signature(meta.signature, meta.closing, tail)
  -- the certificate of service, when the sample gives one: on a page of its own (typst: pagebreak())
  local c = meta.certificate
  if c then
    tail[#tail + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { page = true, after = GAP, jc = "center" })
    tail[#tail + 1] = p(xe.inl(c.text), { line = BODY, first = INDENT })
    signature(c, nil, tail)
  end
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
