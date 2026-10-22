-- District of Idaho bankruptcy court, adversary complaint: pandoc filter for the docx engine (docs/DOCX.md).
-- The markdown contract (../README.md) -> Word, laid out and broken as typst/idb-adversary-complaint.typ lays it
-- out: the counsel block (LBR 5005-1(c)(1)), the court title, the caption (Official Form 416: two rows, each a
-- party cell closed by a vertical rule and a cell of case identifiers, the rule under the debtors), the title, the
-- unnumbered lead-in, the headings, the numbered allegations (Fed. R. Civ. P. 10(b)), the lettered items, the
-- unnumbered prayer and the signature block. Nothing case-specific is in this file: every word comes from the
-- sample. The frontmatter is read as written ($FORMBOOK_META, fb render).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double 27.6 pt, pitch-single 13.8 pt
local INDENT, NUM_TAB = 720, 1440        -- typst para-indent 0.5 in; + num-box 0.5 in
local ITEM_LEFT, ITEM_BOX = 1800, 360    -- typst item-indent + item-box 1.25 in; item-box 0.25 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_INSET = 4608, 216    -- typst caption-left 3.2 in, caption-inset 0.15 in
local DESIG = 2160                       -- typst designation-indent 1.5 in
local SIG_LEFT = 5040                    -- typst sig-left 3.5 in

local function read_file(path)
  local f = path and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(key)
  if RAW[key] == nil then error("idb.lua: missing required metadata field `" .. key .. "`") end
  return RAW[key]
end

-- A frontmatter string as inlines: its markdown read as pandoc reads the body (no fancy list markers: "(208) ..."
-- is text); a line that still reads as a block of another kind is its text.
local function md(s)
  s = s or ""
  local b = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS).blocks[1]
  if b == nil then return pandoc.Inlines({}) end
  if b.t == "Para" or b.t == "Plain" then return b.content end
  return pandoc.Inlines({ pandoc.Str(s) })
end

-- A paragraph: o = { before, after, line, left, hanging, first, tab, jc, keep } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table of the text width; rows = { { cells = { { pr, body } }, pr } }.
local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row.cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (row.pr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Counsel, court title, caption, title
-- ---------------------------------------------------------------------------

local function cover()
  local out = {}
  -- counsel block: upper left, single spaced, from the top margin (LBR 5005-1(c)(1))
  for _, l in ipairs(need("counsel")) do out[#out + 1] = p(xe.inl(md(l))) end
  out[#out + 1] = p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { before = SINGLE, jc = "center" })
  out[#out + 1] = p(xe.runs("DISTRICT OF IDAHO", { b = true }), { after = SINGLE, jc = "center" })

  -- a party block: its names, a single line above them; the designation a single line below, indented
  local function party(cell, pt)
    for i, n in ipairs(pt.names) do cell[#cell + 1] = p(xe.inl(md(n)), { before = i == 1 and SINGLE or 0 }) end
    cell[#cell + 1] = p(xe.inl(md(pt.designation)), { before = SINGLE, left = DESIG })
  end
  local debtors = { p(xe.runs("In re:")) }
  party(debtors, need("debtors"))
  local parties = {}
  for k, pt in ipairs(need("parties")) do
    if k > 1 then parties[#parties + 1] = p(xe.runs("v."), { before = SINGLE }) end
    party(parties, pt)
  end
  -- the cell's pad below its last line (typst: inset bottom, a single line) as space after it
  local function pad(cell)
    cell[#cell] = cell[#cell]:gsub('w:after="0"', 'w:after="' .. SINGLE .. '"', 1)
    return cell
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  local ids = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { cells = {
      { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>', body = pad(debtors) },
      { pr = ids, body = {
        p(xe.inl(md("Case No. " .. need("case_number")))),
        p(xe.inl(md("Chapter " .. need("chapter"))), { before = SINGLE }),
      } },
    } },
    { cells = {
      { pr = '<w:tcBorders><w:right ' .. rule .. '/></w:tcBorders>', body = pad(parties) },
      { pr = ids, body = { p(xe.inl(md("Adv. No. " .. (RAW.adv_number or ""))), { before = SINGLE }) } },
    } },
  })
  -- the title: bold capitals, underlined, centered, a single line below the caption
  out[#out + 1] = p(xe.runs(pandoc.text.upper(need("title")), { b = true, u = true }),
    { line = BODY, jc = "center", before = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to 1 in (typst: the number in a box of num-box), the text.
local function body_par(label, inlines, keep)
  if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT, keep = keep }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT, tab = NUM_TAB, keep = keep })
end

-- Headings (typst heading-block), kept with the text: level 1 bold, underlined, centered on a single line, a single
-- line above it; level 2 right after it bold and centered, single spaced; any other level 2 bold and underlined at
-- the margin on a body line; level 3 bold on a body line. A single-spaced heading followed by text has a single
-- line below it.
local function heading(level, content, after_h1, then_text)
  local below = then_text and SINGLE or 0
  if level == 1 then
    return p(xe.inl(content, { b = true, u = true }), { keep = true, before = SINGLE, after = below, jc = "center" })
  elseif level == 2 and after_h1 then
    return p(xe.inl(content, { b = true }), { keep = true, after = below, jc = "center" })
  elseif level == 2 then
    return p(xe.inl(content, { b = true, u = true }), { keep = true, line = BODY })
  end
  return p(xe.inl(content, { b = true }), { keep = true, line = BODY })
end

-- Lettered items a., b., ...: the letter 1 in from the margin, the text hanging after a box of 0.25 in.
local function items(list, out, keep_last)
  for j, item in ipairs(list.content) do
    local inls = pandoc.Inlines({})
    for k, blk in ipairs(item) do
      if k > 1 then inls:insert(pandoc.Space()) end
      if blk.content then inls:extend(blk.content) end
    end
    out[#out + 1] = p(xe.runs(string.char(96 + j) .. ".\t") .. xe.inl(inls),
      { line = BODY, left = ITEM_LEFT, hanging = ITEM_BOX, keep = keep_last and j == #list.content })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text. Not in a heading: in an underlined run
-- LibreOffice sets the zero-width space as a gap, and the PDF text splits the word there.
local function joins(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}(")))
end
local function breaks(s)
  return pandoc.Str((joins(s).text:gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157(a)"; typst boxes it): a no-break space after it.
local function bind_doubled(ils)
  for i = 1, #ils - 1 do
    local a, b = ils[i], ils[i + 1]
    if a.t == "Str" and b.t == "Space" and (a.text == "§§" or a.text == "¶¶") then ils[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return ils
end

-- ---------------------------------------------------------------------------
-- Signature block: "Date:" at the margin; at 3.5 in the lines above the signature, two single lines, "/s/ Name",
-- the name in capitals and the lines under it; the row never splits. The space above it is a 1 pt paragraph kept
-- with the table, its space before the rest: at the top of a page LibreOffice drops a paragraph's space before, as
-- typst drops a block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

local function signature()
  local s = need("signature")
  local right = {}
  for _, l in ipairs(s.lines_above or {}) do right[#right + 1] = p(xe.inl(md(l))) end
  right[#right + 1] = p(xe.inl(md("/s/ " .. s.signer)), { before = 2 * SINGLE })
  right[#right + 1] = p(xe.runs(pandoc.text.upper(s.signer)))
  for _, l in ipairs(s.lines or {}) do right[#right + 1] = p(xe.inl(md(l))) end
  return p("", { keep = true, before = BODY - 20, line = 20 }) ..
    tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { pr = '<w:trPr><w:cantSplit/></w:trPr>', cells = {
      { body = { p(xe.inl(md("Date: " .. need("date")))) } },
      { body = right },
    } } })
end

function Pandoc(doc)
  local blocks = pandoc.Blocks(doc.blocks:map(function(b) return b:walk({ Str = b.t == "Header" and joins or breaks }) end))
    :walk({ Inlines = bind_doubled })
  local out = cover()
  -- the opening paragraph of the pleading is unnumbered in the filed form
  out[#out + 1] = body_par(nil, md(need("lead_in")))
  local n, num_on, prev = 0, true, 0
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local nxt = blocks[i + 1]
    if b.t == "Header" then
      if b.level == 1 and pandoc.utils.stringify(b.content):sub(1, 6) == "PRAYER" then num_on = false end
      out[#out + 1] = heading(b.level, b.content, b.level == 2 and prev == 1, not (nxt and nxt.t == "Header"))
      prev = b.level
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      items(b, out, last)
      prev = 0
    elseif b.t == "Para" or b.t == "Plain" then
      if num_on then n = n + 1 end
      out[#out + 1] = body_par(num_on and (n .. ".") or nil, b.content, last)
      prev = 0
    else
      error("idb.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature()
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
