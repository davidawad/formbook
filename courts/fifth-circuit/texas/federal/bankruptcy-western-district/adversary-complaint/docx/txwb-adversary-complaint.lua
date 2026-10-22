-- txwb-adversary-complaint.lua (docx engine, docs/DOCX.md): the markdown contract -> Word, laid out and broken as
-- typst/txwb-adversary-complaint.typ lays it out: the court title, the caption (a table: debtor and parties left, with
-- a rule on the right and the bottom; case block right; Fed. R. Bankr. P. 7010), the title, the unnumbered lead-in,
-- the headings (# I., II., ...; ## A., B., ...), the numbered paragraphs (Fed. R. Civ. P. 10(b)), the lettered prayer
-- items ((a), (b), ...) and the signature block. Nothing case-specific is in this file: every word comes from the
-- sample. The frontmatter is read as written ($FORMBOOK_META, fb render).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUM_TAB = 1296                     -- typst para-indent + num-box, 0.9 in
local ITEM_LEFT, ITEM_BOX = 1584, 864    -- typst item-indent + item-box 1.1 in; item-box 0.6 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 432   -- typst caption-left 3.4 in, caption-gutter 0.3 in
local CAP_INSET, CAP_PAD = 200, 160      -- typst caption-inset 10 pt, caption-pad 8 pt
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local DEBTOR_INDENT = 720                -- typst debtor-indent 0.5 in
local PARTY_GAP = 276                    -- typst party-gap, a single line
local SIG_LEFT, SIG_GUTTER = 3744, 288   -- typst sig-left 2.6 in, sig-gutter 0.2 in
local SIG_GAP = 200                      -- typst sig-gap 10 pt

local function read_file(path)
  local f = path and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

-- A frontmatter string as inlines: its markdown read as pandoc reads the body (no fancy list markers: "(512) ..."
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

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta)
  local lines = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF TEXAS" }
  if meta.division then lines[#lines + 1] = pandoc.text.upper(meta.division) .. " DIVISION" end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center", after = i == #lines and SINGLE or 0 })
  end
  -- Left cell: "IN RE:", the debtor, "Debtor." indented; then each party's names and designation, "v." between the
  -- parties; the bottom rule stands the pad off the last line (space after it).
  local left = {
    p(xe.runs("IN RE:")),
    p(xe.inl(md(meta.debtor.name))),
    p(xe.runs("Debtor."), { left = DEBTOR_INDENT }),
  }
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for j, n in ipairs(party.names) do
      left[#left + 1] = p(xe.inl(md(n)), { before = (k == 1 and j == 1) and PARTY_GAP or 0 })
    end
    left[#left + 1] = p(xe.inl(md(party.designation)), { after = k == #parties and CAP_PAD or 0 })
  end
  local adv = (meta.adversary_number or "") ~= "" and meta.adversary_number or "____________________"
  local right = {
    p(xe.inl(md("Case No. " .. meta.debtor.case_number))),
    p(xe.inl(md(meta.debtor.chapter))),
    p(xe.inl(md("Adv. Pro. No. " .. adv)), { before = SINGLE }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- the title stands a double line below the caption (typst: the caption block's below); Word has no space after a
  -- table, so the title takes the space before it
  out[#out + 1] = p(xe.runs(pandoc.text.upper(meta.brief_title), { b = true }),
    { line = BODY, jc = "center", before = BODY, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to 0.9 in (typst: the number in a box of num-box), the text.
local function body_par(label, inlines, o)
  o = o or {}
  if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT, keep = o.keep }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT, tab = NUM_TAB, keep = o.keep })
end

-- Headings at the body pitch: level 1 centered bold, level 2 bold at the margin, level 3 bold italic; kept with
-- the text.
-- The recipe's Heading 1 sets capitals; typst prints a heading as written, so every run turns them off.
local NOCAPS = '<w:caps w:val="0"/></w:rPr>'
local function heading(level, content)
  local lvl = math.min(level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, (xe.inl(content, { b = true, i = lvl >= 3 }):gsub("</w:rPr>", NOCAPS)))
end

-- Lists, lettered (a), (b), ... (typst enum "(a)"; a bullet list keeps its bullet): the letter half an inch in, the
-- text hanging after a box of 0.6 in (typst item-indent and item-box).
local function items(list, out)
  for j, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("txwb-adversary-complaint.lua: a list item holds one paragraph")
    end
    local lab = list.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")") or "\u{2022}"
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
      { line = BODY, left = ITEM_LEFT, hanging = ITEM_BOX })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
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
-- Signature block: "Dated:" at the left; "Respectfully submitted," the firm, each group and the role at the right;
-- the row never splits. The space above it is a 1 pt paragraph kept with the table, its space before the rest: at
-- the top of a page LibreOffice drops a paragraph's space before, as typst drops a block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,")) }
  local function lines(list)
    for k, l in ipairs(list or {}) do right[#right + 1] = p(xe.inl(md(l)), { before = k == 1 and SIG_GAP or 0 }) end
  end
  lines(sig.firm)
  for k, g in ipairs(sig.groups) do
    if k > 1 then right[#right + 1] = p(xe.runs("-AND-"), { before = SIG_GAP }) end
    local ls = {}
    if g.signer then ls = { "/s/ " .. g.signer, g.signer } end
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = l end
    lines(ls)
  end
  lines(sig.role)
  return p("", { keep = true, before = BODY - 20, line = 20 }) ..
    tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = { p(xe.inl(md("Dated: " .. meta.date))) } },
      { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
      '<w:trPr><w:cantSplit/></w:trPr>')
end

function Pandoc(doc)
  local meta = RAW
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local out = cover(meta)
  -- the opening paragraph of the pleading is unnumbered in the filed form
  if meta.lead_in then out[#out + 1] = body_par(nil, md(meta.lead_in)) end
  local n, h1, h2 = 0, 0, 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      local content = pandoc.Inlines({})
      if b.level == 1 then
        h1, h2 = h1 + 1, 0
        content:extend({ pandoc.Str(roman(h1) .. "."), pandoc.Space() })
      elseif b.level == 2 then
        h2 = h2 + 1
        content:extend({ pandoc.Str(string.char(64 + h2) .. "."), pandoc.Space() })
      end
      content:extend(b.content)
      out[#out + 1] = heading(b.level, content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      n = n + 1
      out[#out + 1] = body_par(n .. ".", b.content, { keep = last })
    else
      error("txwb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
