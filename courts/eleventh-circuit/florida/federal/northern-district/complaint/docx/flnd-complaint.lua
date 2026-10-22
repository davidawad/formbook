-- Complaint for the U.S. District Court for the Northern District of Florida (flnd), docx engine: what the Word output
-- adds to pandoc's conversion, so that it reads and breaks as typst/flnd-complaint.typ does (README "Engines"): the
-- court title and case style (Loc. R. 5.1(B); Fed. R. Civ. P. 10(a)), the title of the paper, the lead-in, the
-- numbered paragraphs (Fed. R. Civ. P. 10(b)) with the WHEREFORE paragraphs unnumbered, the roman-numbered list, the
-- headings and the signature block (Loc. R. 5.1(D)). Everything printed comes from the sample's frontmatter and body:
-- no case text lives in this file. Caption and signature are OOXML tables, because pandoc has no caption construct.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 644, 322           -- typst pitch-double, pitch-single
local INDENT = 720                      -- typst para-indent, 0.5 in (and the paragraph number's box after it)
local ITEM, LABEL = 1440, 720           -- typst item-indent 1 in, label-box 0.5 in
local TEXTW = 9360                      -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4752, 432  -- typst caption-left 3.3 in, caption-gutter 0.3 in
local CAP_INSET, CAP_PAD = 288, 144     -- typst caption-inset 0.2 in, caption-pad 0.1 in
local RIGHT_INSET = 144                 -- typst right-inset 0.1 in
local SIG_LEFT, SIG_GUTTER = 4320, 288  -- typst sig-left 3.0 in, sig-gutter 0.2 in

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tabs } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
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

-- ---------------------------------------------------------------------------
-- Court title, case style, title of the paper (Loc. R. 5.1(B); Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" }),
    p(xe.runs("NORTHERN DISTRICT OF FLORIDA", { b = true }), { jc = "center" }),
    p(xe.runs(pandoc.text.upper(pandoc.utils.stringify(meta.division)), { b = true }), { jc = "center", after = BODY }),
  }
  -- Left cell: each party's names, then its designation; "v." between the parties, a single line clear of each;
  -- the closing rule a tenth of an inch below the last line.
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { before = SINGLE, after = SINGLE }) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_PAD or 0 })
  end
  local right = { p(xe.runs("CASE NO.")), p(xe.inl(meta.case_number)) }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- the title a double line below the caption (Word has no space after a table: the title takes it before itself)
  -- and a double line above the text
  out[#out + 1] = p(xe.inl(meta.brief_title, { b = true }), { jc = "center", before = BODY, after = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (Loc. R. 5.1(D)): "Dated" at the left; the signature column at the right; the row never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) }
  local right = { p(xe.runs("Respectfully submitted,")) }
  for k, l in ipairs(sig.firm or {}) do right[#right + 1] = p(xe.inl(l), { before = k == 1 and SINGLE or 0 }) end
  right[#right + 1] = p(xe.inl(sig.by), { before = SINGLE })
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local NUM_TAB = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>'

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number at the first-line
-- indent, a tab to a further half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines)
  if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT, tabs = NUM_TAB })
end

-- Headings at the body pitch, bold, centered (level 1 in capitals); kept with the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
    xe.inl(content, { b = true }))
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- List items in lower-case roman numerals (typst enum "i."): the numeral an inch in, the text hanging half an inch
-- after it (typst item-indent and label-box).
local function list(el, out)
  local start = el.t == "OrderedList" and el.listAttributes.start or 1
  for j, item in ipairs(el.content) do
    for k, b in ipairs(item) do
      local lab = k == 1 and (roman(start + j - 1) .. ".\t") or ""
      out[#out + 1] = p(xe.runs(lab) .. xe.inl(b.content), { line = BODY, left = ITEM + LABEL, hanging = LABEL })
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("d/b/a": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = cover(meta)
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in) end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):match("^WHEREFORE") then
        out[#out + 1] = body_par(nil, b.content)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      list(b, out)
    else
      error("flnd-complaint.lua: unsupported block " .. b.t)
    end
  end
  -- the signature block a double line below the text: the space after the last paragraph (Word keeps a cell's space
  -- before at the top of a page, where typst drops the block's space above it)
  out[#out] = (out[#out]:gsub('w:after="0"', 'w:after="' .. BODY .. '"', 1))
  out[#out + 1] = signature(meta)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
