-- mnd-complaint.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/mnd-complaint.typ does (see ../README.md "Engines"): the court's name and the caption table (party column
-- between rules, file number and title on the right; Fed. R. Civ. P. 10(a)), the numbered allegations (Fed. R. Civ.
-- P. 10(b): every paragraph after a heading that is not DEMAND or PRAYER, numbered from 1), the lettered prayer
-- items, the headings and the signature block. Everything printed comes from the sample's frontmatter and body: no
-- case text lives in this file. Caption and signature are OOXML tables, because pandoc has no caption construct.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 598 the double-spaced body, 299 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 598, 299          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent and item-indent, 0.5 in
local TEXTW = 9360                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4752, 432 -- typst caption-left 3.3 in, caption-gutter 0.3 in
local CAP_PAD = 160                    -- typst caption-pad 8 pt
local RIGHT_INSET = 144                -- typst right-inset 0.1 in
local VS, DESIG = 432, 1728            -- typst vs-indent 0.3 in, designation-indent 1.2 in
local SIG_LEFT, SIG_GUTTER = 3744, 288 -- typst sig-left 2.6 in, sig-gutter 0.2 in
local COURT = { "UNITED STATES DISTRICT COURT", "DISTRICT OF MINNESOTA" } -- the court's name, not the case's

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
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

-- ---------------------------------------------------------------------------
-- Court name and caption (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  for i, l in ipairs(COURT) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #COURT and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation, indented; "v." between the parties. The rules stand the
  -- pad off the text as space before the first line and after the last (a cell margin would lower the whole row).
  local left = {}
  local parties = meta.caption
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { left = VS }) end
    for j, n in ipairs(party.names) do
      left[#left + 1] = p(xe.inl(n), { before = (k == 1 and j == 1) and CAP_PAD or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG, after = k == #parties and CAP_PAD or 0 })
  end
  -- Right cell: the file number (blank until the clerk assigns it) level with the first party line, then the title
  -- in capitals.
  local number = plain(meta.case_number)
  if number == "" then number = "____________________" end
  local right = {
    p(xe.runs("Civil No. " .. number), { before = CAP_PAD }),
    p(xe.runs(pandoc.text.upper(plain(meta.brief_title)), { b = true }), { before = SINGLE, jc = "center" }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:top ' .. rule .. '/><w:bottom ' .. rule .. '/></w:tcBorders>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" at the left; the firm and signer at the right ("" a blank line); the row never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local right = {}
  for i, l in ipairs(meta.signature or {}) do
    local s = plain(l)
    right[#right + 1] = p(s == "" and xe.runs("\u{00A0}") or xe.inl(l), { before = i == 1 and BODY or 0 })
  end
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = BODY }) }
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, before)
  if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT, before = before }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT, tab = 2 * INDENT, before = before })
end

-- A lettered prayer item: the letter half an inch in, the text hanging a further half inch (typst prayer-item).
local function prayer(letter, inlines, before)
  return p(xe.runs(letter .. "\t") .. xe.inl(inlines), { line = BODY, left = 2 * INDENT, hanging = INDENT, before = before })
end

-- Headings at the body pitch, bold and centered (capitals as written); kept with the text.
local function heading(el, before)
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(before or 0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(el.content, { b = true }))
end

-- A lettered item as markdown gives it: a paragraph that begins "A." (pandoc reads "A. " with one space as text).
local function lettered(b)
  if b.t ~= "Para" or #b.content < 3 then return nil end
  local first = b.content[1]
  if first.t ~= "Str" or not first.text:match("^[A-Z][.)]$") or b.content[2].t ~= "Space" then return nil end
  return first.text, pandoc.Inlines({ table.unpack(b.content, 3) })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = cover(meta)
  -- the caption stands a double line above the text (typst: the caption block's below); Word has no space after a
  -- table, so the first paragraph after it takes the space before it
  local gap = BODY
  local function take()
    local g = gap
    gap = 0
    return g
  end
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in, take()) end
  local numbered, n = false, 0
  for _, b in ipairs(doc.blocks) do
    local letter, rest = lettered(b)
    if b.t == "Header" then
      if b.level == 1 then
        local head = plain(b.content)
        numbered = not (head:match("^DEMAND") or head:match("^PRAYER"))
      end
      out[#out + 1] = heading(b, take())
    elseif letter then
      out[#out + 1] = prayer(letter, rest, take())
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = prayer(string.char(64 + b.listAttributes.start + i - 1) .. ".", item[1].content, take())
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local label = nil
      if numbered then
        n = n + 1
        label = n .. "."
      end
      out[#out + 1] = body_par(label, b.content, take())
    else
      error("mnd-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
