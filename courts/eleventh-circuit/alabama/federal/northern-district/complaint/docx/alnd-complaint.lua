-- alnd complaint, docx engine: what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/alnd-complaint.typ does: the court title, the caption (Fed. R. Civ. P. 10(a)), the title, the numbered
-- paragraphs (Fed. R. Civ. P. 10(b)), the lettered prayer items, the "<!--unnumbered-->" and "<!--centered-->"
-- paragraphs, the headings and the signature block (Fed. R. Civ. P. 11(a)). Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_TAB = 1440                  -- typst para-indent + number-box: the text of a numbered paragraph
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4608                    -- typst caption-left 3.2 in
local CAP_INSET, CAP_PAD = 280, 138      -- typst caption-inset 14 pt, caption-pad (half a single line)
local DESIGNATION = 2592                 -- typst designation-indent 1.8 in
local SIG_GUTTER = 432                   -- typst sig-gutter 0.3 in

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

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

local function cover(meta, out)
  for _, l in ipairs(meta.court) do out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", keep = true }) end
  -- Left cell: each party's names, then its designation set in; "v." centered between the parties. The caption
  -- stands a double line below the court title (typst: the caption block's above).
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { jc = "center" }) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n), { before = #left == 0 and BODY or 0 }) end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIGNATION, after = k == #parties and CAP_PAD or 0 })
  end
  local right = { p(xe.runs("Case No.: ") .. xe.inl(meta.case_number), { before = BODY }) }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(upper(meta.brief_title), { b = true }),
    { line = BODY, before = BODY, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Date and signature: the firms side by side; the block never breaks across a page: one table row that cannot split
-- holds it all (LibreOffice does not carry a keep-with-next chain past a table)
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local inner = { p(xe.inl(meta.date_line), { before = BODY }) }
  local n = #sig.firms
  local w = (TEXTW - SIG_GUTTER * (n - 1)) // n
  local widths, cells = {}, {}
  for i, lines in ipairs(sig.firms) do
    local ps = {}
    for j, l in ipairs(lines) do
      ps[#ps + 1] = p(pandoc.utils.stringify(l) == "" and "" or xe.inl(l), { before = j == 1 and BODY or 0 })
    end
    if i < n then
      widths[#widths + 1] = w + SIG_GUTTER
      cells[#cells + 1] = { pr = '<w:tcMar><w:right w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = ps }
    else
      widths[#widths + 1] = TEXTW - (w + SIG_GUTTER) * (n - 1)
      cells[#cells + 1] = { body = ps }
    end
  end
  inner[#inner + 1] = tbl(widths, cells)
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do inner[#inner + 1] = p(xe.inl(l), { before = i == 1 and BODY or 0 }) end
  -- a cell ends in a paragraph: a 1 pt one when there are no closing lines
  if #lines == 0 then inner[#inner + 1] = p("", { line = 20 }) end
  out[#out + 1] = tbl({ TEXTW }, { { body = inner } }, "<w:trPr><w:cantSplit/></w:trPr>")
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
    xe.inl(content, { b = true }))
end

local function body(blocks, out)
  local n = 0
  -- pandoc reads the marker comment that opens a paragraph ("<!--unnumbered-->", "<!--centered-->") as a block
  -- of its own: it applies to the paragraph after it
  local m
  for _, b in ipairs(blocks) do
    if b.t == "RawBlock" and b.format:match("html") and b.text:match("^<!%-%-%a+%-%->$") then
      m = b.text:match("^<!%-%-(%a+)%-%->$")
    elseif b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      local rest = b.content
      if m == "unnumbered" then
        out[#out + 1] = p(xe.inl(rest), { line = BODY, first = INDENT })
      elseif m == "centered" then
        out[#out + 1] = p(xe.inl(rest), { line = BODY, jc = "center" })
      elseif m then
        error("alnd-complaint: unknown paragraph marker <!--" .. m .. "-->")
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. "\t") .. xe.inl(rest), { line = BODY, first = INDENT, tab = NUMBER_TAB })
      end
      m = nil
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- prayer items, lettered A., B., ... (typst enum "A."): the letter half an inch in, the text a box after it
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ((b.t == "OrderedList" and (string.char(64 + j) .. ".") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
        end
      end
    else
      error("alnd-complaint: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 2201"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local t = a.text
      if #t >= 4 and t:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
        inlines[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return inlines
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "caption", "brief_title", "case_number", "signature", "date_line" }) do
    if meta[k] == nil then error("alnd-complaint: missing required metadata field `" .. k .. "`", 0) end
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT }) end
  body(doc.blocks, out)
  signature(meta, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
