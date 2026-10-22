-- txwb-motion-brief.lua (docx engine, docs/DOCX.md): the markdown contract -> Word, laid out and broken as
-- typst/txwb-motion-brief.typ lays it out: the court title, the caption (a table: debtor and parties left, with a rule
-- on the right and the bottom; case block right), the negative notice (W.D. Tex. L.R. 9014-1(a): bold, 12 pt,
-- directly below the caption), the title, the addressee, the unnumbered lead-in, the headings (not numbered), the
-- numbered paragraphs, the lettered lists ((a), (b), ...), the signature block and the certificate of service
-- (L.R. 9013-1(c)). Nothing case-specific is in this file: every word comes from the sample. The frontmatter is read
-- as written ($FORMBOOK_META, fb render).
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
local SERVICE_GUTTER = 432               -- typst service-gutter 0.3 in
local SERVICE_COL = (TEXTW - SERVICE_GUTTER) // 2

-- Negative-notice form language, W.D. Tex. L.R. 9014-1(a) (fixed text of the rule, as in typst/txwb-motion-brief.typ).
-- The Clerk's mailing address is the one thing the rule asks to be filled in: it comes from the sample's clerk_address.
local function negative_notice(meta)
  return {
    "This pleading requests relief that may be adverse to your interests.",
    "If no timely response is filed within 21 days from the date of service, the relief requested herein may be granted without a hearing being held.",
    "A timely filed response is necessary for a hearing to be held.",
    "Any response must be timely filed with the United States Bankruptcy Clerk, Western District of Texas, " .. meta.clerk_address .. ".",
    "If a timely response is filed, the Court will then set a hearing on the Motion, and you will be provided with notice of the date, time, and place of the hearing.",
    "If you do not attend the hearing, the Court may decide that you do not oppose the Motion.",
  }
end

local function read_file(path)
  local f = path and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

-- A frontmatter string as inlines: its markdown read as pandoc reads the body (no fancy list markers: "(713) ..."
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

-- A one-row table: widths, cells = { { pr, body } }, the row properties, the table width.
local function tbl(widths, cells, trpr, width)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (width or TEXTW) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local CANT_SPLIT = '<w:trPr><w:cantSplit/></w:trPr>'

-- Lines of a column, the first `gap` below the line before (typst lines-block).
local function lines(list, out, gap, left)
  for k, l in ipairs(list or {}) do
    out[#out + 1] = p(xe.inl(md(l)), { before = k == 1 and (gap or 0) or 0, left = left })
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Court title, caption, negative notice, title, addressee
-- ---------------------------------------------------------------------------

local function cover(meta)
  local title = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF TEXAS" }
  if meta.division then title[#title + 1] = pandoc.text.upper(meta.division) .. " DIVISION" end
  local out = {}
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center", after = i == #title and SINGLE or 0 })
  end
  -- Left cell: "In re:", the debtor, "Debtor." indented; then each party's names and designation, "v." between the
  -- parties; the bottom rule stands the pad off the last line (space after it).
  local left = {
    p(xe.runs("In re:")),
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
  local right = {
    p(xe.inl(md("Case No. " .. meta.debtor.case_number))),
    p(xe.inl(md(meta.debtor.chapter))),
    p(xe.inl(md("Adv. Pro. No. " .. meta.adversary_number)), { before = SINGLE }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- The negative notice a double line below the caption (Word has no space after a table: the first sentence
  -- takes the space before it), each sentence a bold single-spaced paragraph.
  for k, s in ipairs(negative_notice(meta)) do
    out[#out + 1] = p(xe.inl(md(s), { b = true }), { before = k == 1 and BODY or 0 })
  end
  out[#out + 1] = p(xe.runs(pandoc.text.upper(meta.brief_title), { b = true }),
    { line = BODY, jc = "center", before = BODY, after = SINGLE })
  if meta.addressee then out[#out + 1] = p(xe.inl(md(meta.addressee)), { line = BODY, after = SINGLE }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to 0.9 in (typst: the number in a box of num-box), the text.
local function body_par(label, inlines, o)
  o = o or {}
  if label == nil then
    return p(xe.inl(inlines), { line = BODY, first = INDENT, keep = o.keep, before = o.before })
  end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT, tab = NUM_TAB, keep = o.keep })
end

-- Headings at the body pitch: level 1 centered bold, level 2 centered bold italic, level 3 bold italic at the margin;
-- kept with the text.
-- The recipe's Heading 1 sets capitals; typst prints a heading as written, so every run turns them off.
local NOCAPS = '<w:caps w:val="0"/></w:rPr>'
local function heading(level, content)
  local lvl = math.min(level, 3)
  local r = xe.inl(content, { b = true, i = lvl >= 2 }):gsub("</w:rPr>", NOCAPS)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, r)
end

-- Lists, lettered (a), (b), ... (typst enum "(a)"; a bullet list keeps its bullet): the letter half an inch in, the
-- text hanging after a box of 0.6 in (typst item-indent and item-box).
local function items(list, out)
  for j, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("txwb-motion-brief.lua: a list item holds one paragraph")
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

-- A doubled sign stays with its number ("§§ 24.005"; typst boxes it): a no-break space after it.
local function bind_doubled(ils)
  for i = 1, #ils - 1 do
    local a, b = ils[i], ils[i + 1]
    if a.t == "Str" and b.t == "Space" and (a.text == "§§" or a.text == "¶¶") then ils[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return ils
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service: each one table row that never splits. The space above each is a
-- 1 pt paragraph kept with the table, its space before the rest: at the top of a page LibreOffice drops a
-- paragraph's space before, as typst drops a block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

local function spacer()
  return p("", { keep = true, before = BODY - 20, line = 20 })
end

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,")) }
  for k, g in ipairs(sig.groups) do
    if k > 1 then right[#right + 1] = p(xe.runs("-AND-"), { before = SIG_GAP }) end
    local ls = {}
    if g.signer then ls = { "By: /s/ " .. g.signer, g.signer } end
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = l end
    lines(ls, right, SIG_GAP)
  end
  lines(sig.role, right, SIG_GAP)
  return spacer() .. tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = { p(xe.inl(md("Dated: " .. meta.date))) } },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } }, CANT_SPLIT)
end

local function certificate(meta)
  local c = meta.certificate
  if c == nil then return "" end
  local cell = {
    p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { line = BODY, jc = "center" }),
    body_par(nil, md(c.text), { before = SINGLE }),
  }
  -- the service list: two columns, a gutter between them; each further row a single line below the one above
  local service = c.service or {}
  for k = 1, #service, 2 do
    local a = lines(service[k].lines, {})
    local b = service[k + 1] and lines(service[k + 1].lines, {}) or { p("") }
    local first = '<w:tcMar><w:top w:w="' .. SINGLE .. '" w:type="dxa"/></w:tcMar>'
    cell[#cell + 1] = tbl({ SERVICE_COL, TEXTW - SERVICE_COL }, {
      { pr = first, body = a },
      { pr = '<w:tcMar><w:top w:w="' .. SINGLE .. '" w:type="dxa"/><w:left w:w="' .. SERVICE_GUTTER ..
        '" w:type="dxa"/></w:tcMar>', body = b },
    }, CANT_SPLIT)
  end
  local signer = { "By: /s/ " .. c.signer, c.signer }
  for _, l in ipairs(c.lines or {}) do signer[#signer + 1] = l end
  lines(signer, cell, SINGLE, SIG_LEFT + SIG_GUTTER)
  return spacer() .. tbl({ TEXTW }, { { body = cell } }, CANT_SPLIT)
end

function Pandoc(doc)
  local meta = RAW
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local out = cover(meta)
  if meta.lead_in then out[#out + 1] = body_par(nil, md(meta.lead_in)) end
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b.level, b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      n = n + 1
      out[#out + 1] = body_par(n .. ".", b.content, { keep = last })
    else
      error("txwb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  out[#out + 1] = certificate(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
