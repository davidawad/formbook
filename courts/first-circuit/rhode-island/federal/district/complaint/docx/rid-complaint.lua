-- rid-complaint.lua (docx engine): the D.R.I. complaint as Word paragraphs and tables, so that it reads and breaks as
-- typst/rid-complaint.typ does (see ../README.md "Engines"): the court title, the caption as a table (party column
-- closed by a rule on the right and below; "C.A. No." and the jury demand on the right, LR Cv 5(a)(1), (4)), the
-- title, the allegations numbered 1., 2., ... (Fed. R. Civ. P. 10(b)) with the number in a box after the first-line
-- indent, the unnumbered WHEREFORE prayer, the headings, and the signature block (LR Cv 5(a)(5)) as one table row
-- that never splits. Nothing in this file is case-specific: every word comes from the sample's frontmatter or body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUMBER_TAB = 1440                  -- typst para-indent + number-box: the text of a numbered paragraph
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360   -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_INSET = 172                    -- typst caption-inset 8.6 pt
local NUM_INSET = 144                    -- typst number-inset 0.1 in
local SIG_LEFT, SIG_GUTTER = 4176, 288   -- typst sig-left 2.9 in, sig-gutter 0.2 in

local str = pandoc.utils.stringify

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab }.
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

-- A fixed-width table of one row; cells = { { pr = tcPr children, body = { paragraphs } } }.
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
-- Court title, caption, title (LR Cv 5(a)(1), (2), (4))
-- ---------------------------------------------------------------------------

local function cover(m, out)
  out[#out + 1] = p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center", keep = true })
  out[#out + 1] = p(xe.runs("FOR THE DISTRICT OF RHODE ISLAND", { b = true }), { jc = "center", keep = true, after = BODY })
  -- the caption stands a double line below the court title (typst: the caption block's above), as the space after
  -- the court title: a space before inside the cells would run the caption's rule up into it
  local left = {}
  local parties = m.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_INSET or 0 })
  end
  local number = str(m.case_number or "")
  local right = { p(xe.runs(number ~= "" and ("C.A. No. " .. number) or "C.A. No. ______________")) }
  if m.jury_demand == true then right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = BODY }) end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("") } },
    { pr = '<w:tcMar><w:left w:w="' .. NUM_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(m.brief_title, { b = true }), { before = BODY, after = SINGLE, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- The signature block (LR Cv 5(a)(5)): "Dated" at the left; the party lines, the signers with "/s/" and bar numbers,
-- then the firm block. One table row that cannot split.
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local sig = m.signature
  local right = {}
  local function add(body, before) right[#right + 1] = p(body, { before = #right > 0 and before or 0 }) end
  if sig.lead ~= nil then
    add(xe.inl(sig.lead))
    add("")
  end
  for _, l in ipairs(sig.party) do add(xe.inl(l)) end
  for _, s in ipairs(sig.signers) do
    local bar = s.bar and str(s.bar) or ""
    add(xe.runs("/s/ ") .. xe.inl(s.name), SINGLE)
    add(xe.inl(s.name) .. (bar ~= "" and (xe.runs(" ") .. xe.inl(s.bar)) or ""))
  end
  for i, l in ipairs(sig.firm) do add(xe.inl(l), i == 1 and SINGLE or 0) end
  -- the double line above the block: an empty 1 pt paragraph with the rest as space before, which Word drops at the
  -- top of a page as typst drops the block's space above (a space before inside a table cell would stay)
  out[#out + 1] = p("", { before = BODY - 20, line = 20 })
  local dated = m.date ~= nil and (xe.runs("Dated: ") .. xe.inl(m.date)) or ""
  out[#out + 1] = tbl({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER }, {
    { body = { p(dated) } },
    { body = { p("") } },
    { body = right },
  }, "<w:trPr><w:cantSplit/></w:trPr>")
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Level 1 centered bold, level 2 centered bold italic, level 3 bold at the left; at the body pitch, kept with the
-- text after them.
local function heading(el)
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl < 3 and "center" or "left") }, xe.inl(el.content, { b = true, i = lvl == 2 }))
end

local function is_wherefore(b)
  return str(b):sub(1, 9) == "WHEREFORE"
end

local function body(blocks, out)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif (b.t == "Para" or b.t == "Plain") and is_wherefore(b) then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = NUMBER_TAB })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- prayer items, (a), (b), ... (typst enum "(a)"): the label half an inch in, the text a box after it
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ((b.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
        end
      end
    else
      error("rid-complaint.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 2601"), as the typst template boxes it (xe.inl binds a single sign).
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
  local m = doc.meta
  assert(m.caption and m.caption.parties, "rid-complaint.lua: the sample needs caption.parties")
  assert(m.brief_title, "rid-complaint.lua: the sample needs brief_title")
  assert(m.signature, "rid-complaint.lua: the sample needs a signature block")
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  m = doc.meta
  local out = {}
  cover(m, out)
  body(doc.blocks, out)
  signature(m, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
