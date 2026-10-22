-- W.D. Mo. complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it reads
-- and breaks as typst/mowd-complaint.typ does (see ../README.md "Engines"): the court title and caption table (case
-- number, title, jury legend), the numbered paragraphs (Fed. R. Civ. P. 10(b)), the headings, the block quotations,
-- the lettered lists (A., B., ...), the unnumbered WHEREFORE lead-in and the signature block. Everything printed comes
-- from the sample's frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent, item-indent and quote-indent, 0.5 in
local TEXTW = 9360                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360 -- typst caption-left 3.25 in, caption-gutter 0.25 in
local SIG_LEFT, SIG_GUTTER = 3744, 288 -- typst sig-left 2.6 in, sig-gutter 0.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
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
-- Court title and caption
-- ---------------------------------------------------------------------------

local function cover(meta)
  local lines = { "UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF MISSOURI" }
  if meta.division then lines[#lines + 1] = pandoc.text.upper(plain(meta.division)) end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #lines and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation; "v." between the parties.
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  -- Right cell: the case number, the title, the jury legend, a single line apart.
  local right = {
    p(xe.runs("Case No. ") .. xe.inl(meta.case_number)),
    p(xe.inl(meta.title, { b = true }), { before = SINGLE }),
  }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = SINGLE })
  end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" at the left; "Respectfully submitted", the signer and one block per firm at the right;
-- the row never splits. The space above it is a 1 pt paragraph kept with the table, its space before the rest: at
-- the top of a page LibreOffice drops a paragraph's space before, as typst drops a block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = {
    p(xe.runs("Respectfully submitted,")),
    p(xe.inl(sig.signer, { b = true }), { before = SINGLE }),
  }
  for k, firm in ipairs(sig.blocks) do
    for i, l in ipairs(firm) do right[#right + 1] = p(xe.inl(l), { before = (k > 1 and i == 1) and SINGLE or 0 }) end
  end
  return p("", { keep = true, before = BODY - 20, line = 20 }) ..
    tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = { p(xe.runs("Dated: ") .. xe.inl(sig.date)) } },
      { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
      '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, o)
  o = o or {}
  local q = { line = BODY, first = INDENT, before = o.before, keep = o.keep }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings at the body pitch, bold: level 1 centered capitals, level 2 centered, level 3 at the margin; kept with
-- the text.
local function heading(el, before)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(before or 0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- Lists, lettered A., B., ... (typst enum "A."; a bullet list keeps its bullet): the letter half an inch in, the
-- text hanging a further half inch (typst item-indent and the label box).
local function items(list, out)
  for j, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("mowd-complaint.lua: a list item holds one paragraph")
    end
    local lab = list.t == "OrderedList" and (string.char(64 + j) .. ".") or "\u{2022}"
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks })
  local out = cover(meta)
  -- the caption stands a double line above the text (typst: the caption block's below); Word has no space after a
  -- table, so the first paragraph after it takes the space before it
  local gap = BODY
  local function take()
    local g = gap
    gap = 0
    return g
  end
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b, take())
    elseif b.t == "BlockQuote" then
      -- indented from both margins, single spaced, a single line below (typst: the quotation block)
      for j, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT, before = take(),
          after = j == #b.content and SINGLE or 0 })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      take()
      items(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      if plain(b):sub(1, 9) == "WHEREFORE" then
        out[#out + 1] = body_par(nil, b.content, { before = take(), keep = last })
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, { before = take(), keep = last })
      end
    else
      error("mowd-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
