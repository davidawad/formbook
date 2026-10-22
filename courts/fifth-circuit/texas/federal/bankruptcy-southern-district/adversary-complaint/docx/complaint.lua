-- Adversary complaint, S.D. Tex. bankruptcy court, docx engine (docs/DOCX.md): what the Word output adds to pandoc's
-- conversion, so that it reads and breaks as typst/txsb-adversary-complaint.typ does: the court name lines, the
-- caption (a table: the party column with a rule at its right and bottom, the case block at the right), the debtors
-- note under it, the title, the lead-in, the numbered paragraphs (FRCP 10(b)), the lettered lists, the unnumbered
-- ">" paragraphs, the headings and the signature block. Content-agnostic: every case word comes from the sample's
-- frontmatter and body; the only fixed text is the court's own heading. Caption and signature lines are set as
-- written ($FORMBOOK_META, fb render), as typst sets them.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line, 230 the
-- debtors note), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, NOTE = 480, 276, 230          -- typst pitch-double, pitch-single, pitch-note
local NOTE_SIZE = 20                              -- typst note-size 10 pt, in half points
local NOTE_GAP = 120                              -- typst note-gap 6 pt
local INDENT = 720                                -- typst para-indent and item-indent, 0.5 in
local ITEM_TEXT = 1296                            -- typst item-indent + item-label, 0.9 in
local TEXTW = 9360                                -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360            -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET, CAP_PAD = 240, 185               -- typst caption-inset 12 pt, caption-pad 10 pt less the 0.75 pt
                                                  -- rule, which Word sets below the cell and typst on its edge
local RIGHT_INSET = 144                           -- typst right-inset 0.1 in
local DESIGNATION, VERSUS = 1800, 720             -- typst designation-indent 1.25 in, versus-indent 0.5 in
local COURT = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF TEXAS" }

local function read_file(path)
  if not path then return nil end
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (fb render), where pandoc's metadata would read each string as markdown.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

-- A frontmatter string as inlines: its markdown read as pandoc reads the body (no fancy list markers).
local function md(s)
  local b = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS).blocks[1]
  if b == nil then return pandoc.Inlines({}) end
  if b.t == "Para" or b.t == "Plain" then return b.content end
  return pandoc.Inlines({ pandoc.Str(s) })
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
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

-- ---------------------------------------------------------------------------
-- Cover: court name lines, caption, debtors note, title
-- ---------------------------------------------------------------------------

local function cover()
  local out = {}
  local lines = { COURT[1], COURT[2], pandoc.text.upper(RAW.division) }
  for i, l in ipairs(lines) do
    -- the caption stands a single line below (typst: the caption block's above); Word has no space before a table
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #lines and SINGLE or 0 })
  end
  local c = RAW.caption
  local left = { p(xe.runs("In re:")) }
  for i, n in ipairs(c.debtor_names) do
    local mark = ""
    if i == #c.debtor_names and c.debtor_footnote then
      mark = '<w:r><w:rPr><w:vertAlign w:val="superscript"/></w:rPr><w:t>*</w:t></w:r>'
    end
    left[#left + 1] = p(xe.runs(n) .. mark)
  end
  left[#left + 1] = p(xe.runs(c.debtor_designation), { left = DESIGNATION })
  for i, n in ipairs(c.plaintiff_names) do left[#left + 1] = p(xe.runs(n), { before = i == 1 and SINGLE or 0 }) end
  left[#left + 1] = p(xe.runs(c.plaintiff_designation), { left = DESIGNATION })
  left[#left + 1] = p(xe.runs("v."), { left = VERSUS })
  for _, n in ipairs(c.defendant_names) do left[#left + 1] = p(xe.runs(n)) end
  -- the bottom rule stands the pad off the last line (space after it)
  left[#left + 1] = p(xe.runs(c.defendant_designation), { left = DESIGNATION, after = CAP_PAD })
  -- Right cell: chapter, case number, joint administration, adversary number; "" a blank line.
  local rows = { RAW.chapter, "", RAW.case_number }
  if RAW.joint_admin then rows[#rows + 1] = RAW.joint_admin end
  rows[#rows + 1] = ""
  rows[#rows + 1] = ""
  rows[#rows + 1] = RAW.adversary_number
  local right = {}
  for _, r in ipairs(rows) do right[#right + 1] = p(xe.runs(r)) end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- The debtors note under the caption, in the flow, single spaced at its size.
  if c.debtor_footnote then
    out[#out + 1] = p(xe.runs("* " .. c.debtor_footnote, { sz = NOTE_SIZE }), { before = NOTE_GAP, line = NOTE })
  end
  out[#out + 1] = p(xe.runs(pandoc.text.upper(RAW.title), { b = true }),
    { jc = "center", before = SINGLE, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, keep)
  local q = { line = BODY, first = INDENT, keep = keep }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings at the body pitch, bold, as written: levels 1 and 2 centered, level 3 at the margin; kept with the text.
local function heading(el)
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(el.content, { b = true }))
end

-- Lists, lettered (a), (b), ... (typst enum "(a)"): the letter half an inch in, the text hanging after its box.
local function items(list, out)
  for j, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("complaint.lua: a list item holds one paragraph")
    end
    local lab = list.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")") or "\u{2022}"
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
      { line = BODY, left = ITEM_TEXT, hanging = ITEM_TEXT - INDENT })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 157"), as typst boxes "§ 157" (xe.inl binds a single one).
local function bind_doubled(ils)
  for i = 1, #ils - 1 do
    if ils[i].t == "Str" and ils[i].text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and ils[i + 1].t == "Space" then
      ils[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return ils
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated:" at the left; "Respectfully submitted," and the signing blocks at the right, a single
-- line apart around "-and-"; the row never splits. The space above it is a 1 pt paragraph kept with the table, its
-- space before the rest: at the top of a page LibreOffice drops a paragraph's space before, as typst drops a
-- block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

-- Each further signing block follows at the signature column, "-and-" a single line above it, kept whole on one page
-- (typst: one unbreakable block each).
local function signature()
  local blocks = RAW.signature.blocks
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(blocks[1]) do right[#right + 1] = p(xe.runs(l), { before = i == 1 and SINGLE or 0 }) end
  local out = { p("", { keep = true, before = SINGLE - 20, line = 20 }) ..
    tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, { { body = { p(xe.runs("Dated: " .. RAW.dated)) } },
      { pr = '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
      '<w:trPr><w:cantSplit/></w:trPr>') }
  for k = 2, #blocks do
    out[#out + 1] = p(xe.runs("-and-"), { before = SINGLE, left = CAP_LEFT + CAP_GUTTER, keep = true })
    for i, l in ipairs(blocks[k]) do
      out[#out + 1] = p(xe.runs(l), { before = i == 1 and SINGLE or 0, left = CAP_LEFT + CAP_GUTTER, keep = i < #blocks[k] })
    end
  end
  return table.concat(out)
end

function Pandoc(doc)
  doc.blocks = doc.blocks:walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Str = breaks })
  local out = cover()
  if RAW.lead_in then out[#out + 1] = body_par(nil, md(RAW.lead_in)) end
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, out)
    elseif b.t == "BlockQuote" then
      -- an unnumbered paragraph (a clause the filing does not number)
      for j, q in ipairs(b.content) do
        out[#out + 1] = body_par(nil, q.content, last and j == #b.content)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(n .. ".", b.content, last)
    else
      error("complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature()
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
