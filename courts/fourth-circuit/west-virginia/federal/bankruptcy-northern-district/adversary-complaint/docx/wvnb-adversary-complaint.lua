-- wvnb-adversary-complaint.lua (docx engine): the N.D. W. Va. adversary complaint as Word paragraphs, so that it reads
-- and breaks as typst/wvnb-adversary-complaint.typ (the reference for the form) does:
--   * the optional counsel block, the court lines, the caption (a table: the parties on the left with a rule on the
--     right and bottom of their column, the chapter, case, judge and adversary numbers on the right), and the title;
--   * the body: a lead paragraph, the headings, the numbered paragraphs (FRCP 10(b)), numbered once across the whole
--     complaint, the number in a half-inch box at the first-line indent and the text wrapping to the margin;
--   * "Dated" and the signature in the right-hand column, kept together;
--   * the part after the signature (a level-2 heading "Schedule ...") on a page of its own, its table ruled.
-- Frontmatter values are printed as given; nothing in this file is case-specific.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 552, 276, 276  -- typst pitch-body, pitch-single, gap
local INDENT = 720                       -- typst para-indent and number-box, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4608                    -- typst caption-left, 3.2 in
local CAP_INSET, RIGHT_INSET = 216, 360  -- typst caption-inset 0.15 in, right-inset 0.25 in
local DEBTOR, ROLE, V = 576, 144, 2160   -- typst debtor-indent 0.4 in, role-indent 0.1 in, v-indent 1.5 in
local SIG = 4608                         -- typst sig-column, 3.2 in
local CELL = 108                         -- typst cell-inset 5.4 pt

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function upper(x)
  if pandoc.utils.type(x) == "Inlines" then
    return x:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(plain(x))
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, brk, tab } (keep: with the next paragraph and its
-- lines together; brk: a page break before it; tab: a left tab stop, twips).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_HEAD = '<w:tbl><w:tblPr><w:tblW w:w="%d" w:type="dxa"/><w:tblInd w:w="%d" w:type="dxa"/>%s<w:tblLayout w:type="fixed"/>' ..
  '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="%d" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
  '<w:right w:w="%d" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>' ..
  '</w:tblPr>'

-- ---------------------------------------------------------------------------
-- Counsel block, court lines, caption and title (FRBP 9004(b), FRCP 10(a))
-- ---------------------------------------------------------------------------

local function counsel(m, out)
  if not m.counsel then return end
  for i, l in ipairs(m.counsel) do
    out[#out + 1] = p(xe.inl(l), { after = i == #m.counsel and GAP or 0 })
  end
end

local function caption(m, out)
  for i, l in ipairs(m.court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", after = i == #m.court and GAP or 0 })
  end
  -- the party column: the debtor, each side's names and designation, "v." between the sides; the last line takes the
  -- space above the bottom rule (typst: the cell's bottom inset)
  local left = {}
  if m.debtor then
    left[#left + 1] = { xe.runs("In re: ") .. xe.inl(m.debtor.name) .. xe.runs(","), 0, 0 }
    left[#left + 1] = { xe.runs("Debtor."), DEBTOR, GAP }
  end
  for i, side in ipairs(m.caption) do
    if i > 1 then left[#left + 1] = { xe.runs("v."), V, GAP } end
    for _, n in ipairs(side.names) do left[#left + 1] = { xe.inl(n), 0, 0 } end
    left[#left + 1] = { xe.inl(side.designation), ROLE, GAP }
  end
  local lp = {}
  for i, l in ipairs(left) do lp[#lp + 1] = p(l[1], { left = l[2], after = (i < #left) and l[3] or GAP }) end
  -- the case column, a single line below the top of the caption
  local right = { p(xe.runs("Chapter " .. plain(m.chapter)), { before = GAP, after = GAP }),
    p(xe.runs("Case No. ") .. xe.inl(m.case_number)) }
  if m.judge then right[#right + 1] = p(xe.runs("Judge ") .. xe.inl(m.judge)) end
  right[#right + 1] = p(xe.runs("Adv. Pro. No. ") .. xe.inl(m.adversary_number), { before = GAP })
  if m.adversary_title then right[#right + 1] = p(xe.inl(m.adversary_title)) end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = string.format(TBL_HEAD, TEXTW, 0, "", 0, 0) ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. rule .. '/><w:right ' ..
    rule .. '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(lp) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. RIGHT_INSET ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- the title: Word has no space after a table, so it takes the gap before it
  out[#out + 1] = p(xe.inl(upper(m.complaint_title), { b = true }), { before = GAP, after = GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: centered and bold (level 1 in capitals), single-spaced, a single line from the text on either side, kept
-- with the text; one that opens a page after a hard break carries no space above (typst drops it there).
local function heading(el, brk)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, brk and xe.BREAK or "",
    xe.spacing(brk and 0 or GAP, GAP, SINGLE), xe.ind(0, nil, 0), xe.jc("center") }, xe.inl(content, { b = true }))
end

-- A table (the schedule): equal columns across the text width, ruled, single-spaced cells, the header row bold.
local function table_xml(t)
  local rows = {}
  for _, r in ipairs(t.head.rows) do rows[#rows + 1] = { r, true } end
  for _, body in ipairs(t.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = { r, false } end
  end
  local n = #t.colspecs
  local w = math.floor(TEXTW / n)
  local border = 'w:val="single" w:sz="4" w:space="0" w:color="000000"'
  local borders = '<w:tblBorders><w:top ' .. border .. '/><w:left ' .. border .. '/><w:bottom ' .. border ..
    '/><w:right ' .. border .. '/><w:insideH ' .. border .. '/><w:insideV ' .. border .. '/></w:tblBorders>'
  local x = { string.format(TBL_HEAD, TEXTW, CELL, borders, CELL, CELL), '<w:tblGrid>' }
  for _ = 1, n do x[#x + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  x[#x + 1] = '</w:tblGrid>'
  for _, r in ipairs(rows) do
    x[#x + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for _, c in ipairs(r[1].cells) do
      local inl = pandoc.Inlines({})
      for _, b in ipairs(c.contents) do inl:extend(b.content) end
      x[#x + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' ..
        p(xe.inl(inl, { b = r[2] })) .. '</w:tc>'
    end
    x[#x + 1] = '</w:tr>'
  end
  x[#x + 1] = '</w:tbl>'
  return table.concat(x)
end

-- The body blocks: numbered paragraphs (one counter for the whole complaint), headings, other paragraphs, tables.
local function body(blocks, out, counter, brk)
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b, brk)
      brk = false
    elseif b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        counter.n = counter.n + 1
        local inl = pandoc.Inlines({})
        for k, blk in ipairs(item) do
          if k > 1 then inl:insert(pandoc.Space()) end
          inl:extend(blk.content)
        end
        out[#out + 1] = p(xe.runs(counter.n .. ".\t") .. xe.inl(inl), { line = BODY, first = INDENT, tab = 2 * INDENT })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    elseif b.t == "Table" then
      out[#out + 1] = table_xml(b)
    else
      error("wvnb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
end

-- "Dated" at the margin, "Respectfully submitted," in the right-hand column on the same line, then the signer (typst:
-- signature-block, one unbreakable block).
local function signature(m, out)
  local sig = m.signature
  local first = (m.date and (xe.runs("Dated: ") .. xe.inl(m.date)) or "") .. xe.runs("\tRespectfully submitted,")
  local lines = { { first, BODY, 0 }, { xe.runs("s/ ", { b = true }) .. xe.inl(sig.signer, { b = true }), GAP, SIG } }
  for _, l in ipairs(sig.lines) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines, tab = i == 1 and SIG or nil })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 547": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- an attachment: a level-2 heading "Schedule ..." starts the part that follows the signature (on its own page)
local function starts_attachment(b)
  return b.t == "Header" and b.level == 2 and plain(b):match("^Schedule") ~= nil
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local m = doc.meta
  local out = {}
  counsel(m, out)
  caption(m, out)
  local main, tail = {}, nil
  for _, b in ipairs(doc.blocks) do
    if not tail and starts_attachment(b) then tail = {} end
    if tail then tail[#tail + 1] = b else main[#main + 1] = b end
  end
  local counter = { n = 0 }
  body(main, out, counter, false)
  signature(m, out)
  if tail then body(tail, out, counter, true) end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
