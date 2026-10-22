-- Complaint for the U.S. District Court for the Southern District of Mississippi (mssd), docx engine: what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/mssd-complaint.typ does: the court title
-- and caption (Fed. R. Civ. P. 10(a)), the title of the paper, the unnumbered lead-in, the headings, the numbered
-- allegations (Fed. R. Civ. P. 10(b)), the lettered list items and the signature block (L.U.Civ.R. 11(a)).
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file. The caption is
-- an OOXML table.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local LIST_LEFT = 720                    -- typst list-left, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 5184, 144   -- typst caption-left 3.6 in, caption-gutter 0.1 in
local SIG_LEFT = 4320                    -- typst sig-left 3 in
local HEAD_ABOVE = BODY                  -- typst heading-above

local REQUIRED_SIG = { "signer", "bar_no", "firm", "address", "telephone", "fax", "email" }

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { style, keep, before, after, line, left, hanging, first, jc, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = (o.keep == "next" and "<w:keepNext/>") or (o.keep == "lines" and xe.LINES) or xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless one-row table; cells = { { pr, body = { paragraphs } }, ... }.
local function tbl(widths, cells)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- The document as a list of blocks: a paragraph keeps its options until the end, so that the space below it can
-- still be set when a table follows (Word puts no space above a table; the paragraph before it carries the gap).
-- Between two blocks the space is the larger of the one's below and the other's above (typst's collapse).
-- ---------------------------------------------------------------------------

local out, gap = {}, 0

local function add_p(body, o, below)
  o.before = math.max(gap, o.before or 0)
  out[#out + 1] = { body = body, o = o }
  gap = below or 0
end

local function add_tbl(xml, above, below)
  local g = math.max(gap, above or 0)
  local last = out[#out]
  if g > 0 and last and last.o then last.o.after = g end
  out[#out + 1] = { xml = xml }
  gap = below or 0
end

-- ---------------------------------------------------------------------------
-- Court title, caption (Fed. R. Civ. P. 10(a)), title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta)
  for _, l in ipairs(meta.court) do
    add_p(xe.runs(pandoc.text.upper(plain(l)), { b = true }), { jc = "center" })
  end
  -- Left cell: each party's names, then its designation; "v." between the parties, a blank line above and below.
  -- Right cell: "CIVIL ACTION NO." and the case number from the line of the first "v.".
  local left, row, v_row, pending = {}, 0, nil, 0
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then
      if not v_row then v_row = row + 1 end
      left[#left + 1] = p(xe.runs("v."), { before = SINGLE })
      row = row + 2
      pending = SINGLE
    end
    local lines = {}
    for _, n in ipairs(party.names) do lines[#lines + 1] = n end
    lines[#lines + 1] = party.designation
    for _, n in ipairs(lines) do
      left[#left + 1] = p(xe.inl(n), { before = pending })
      pending = 0
      row = row + 1
    end
    if k > 1 then row = row + 1 end
  end
  local right = {
    p(xe.runs("CIVIL ACTION NO."), { before = (v_row or 0) * SINGLE }),
    p(xe.inl(meta.case_number)),
  }
  add_tbl(tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right },
  }), BODY, BODY)
  add_p(xe.inl(pandoc.text.upper(plain(meta.brief_title)), { b = true, u = true }), { jc = "center" }, SINGLE)
end

-- ---------------------------------------------------------------------------
-- Signature block (L.U.Civ.R. 11(a)), in the right half of the page; its lines stay together.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local s = meta.signature
  if not s then error("mssd-complaint: the sample needs a signature block (L.U.Civ.R. 11(a))") end
  for _, k in ipairs(REQUIRED_SIG) do
    if s[k] == nil then error("mssd-complaint: signature." .. k .. " is required (L.U.Civ.R. 11(a))") end
  end
  local lines = {
    { xe.runs("Respectfully submitted,"), BODY },
    { xe.runs("/s/ ") .. xe.inl(s.signer), SINGLE },
    { xe.runs(pandoc.text.upper(plain(s.signer)) .. " (" .. plain(s.bar_no) .. ")") },
    { xe.inl(s.firm) },
  }
  for _, a in ipairs(s.address) do lines[#lines + 1] = { xe.inl(a) } end
  lines[#lines + 1] = { xe.runs("Telephone: " .. plain(s.telephone)) }
  lines[#lines + 1] = { xe.runs("Facsimile: " .. plain(s.fax)) }
  lines[#lines + 1] = { xe.runs("Email: " .. plain(s.email)) }
  if s.role then lines[#lines + 1] = { xe.runs(pandoc.text.upper(plain(s.role))), SINGLE } end
  for k, l in ipairs(lines) do
    add_p(l[1], { before = l[2] or 0, left = SIG_LEFT, keep = k < #lines and "next" or "lines" })
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: the first-line indent, then (numbered) the number in a box of the indent
-- (a tab to 1 in), the text.
local TAB2 = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>'
local function body_par(label, inlines)
  local body = (label and xe.runs(label .. "\t") or "") .. xe.inl(inlines)
  add_p(body, { line = BODY, first = INDENT, tabs = label and TAB2 or nil })
end

-- Headings single-spaced, centered, bold: level 1 in capitals, level 2 as written; a double line above, kept with
-- the block after them.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  add_p(xe.inl(content, { b = true }),
    { style = "Heading" .. math.min(el.level, 2), keep = true, before = HEAD_ABOVE, jc = "center" }, 0)
end

-- List items, lettered a., b., ... or bulleted: the label at 0.5 in in a box of the indent, the text hanging at 1 in.
local LIST_TAB = '<w:tabs><w:tab w:val="left" w:pos="' .. (LIST_LEFT + INDENT) .. '"/></w:tabs>'
local function list(b)
  for j, item in ipairs(b.content) do
    for k, blk in ipairs(item) do
      local lab = ""
      if k == 1 then lab = (b.t == "OrderedList" and (string.char(96 + j) .. ".") or "\u{2022}") .. "\t" end
      add_p(xe.runs(lab) .. xe.inl(blk.content), { line = BODY, left = LIST_LEFT + INDENT, hanging = INDENT,
        tabs = LIST_TAB })
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space), none between a doubled section sign and its number (typst
-- boxes the last sign with the number).
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end
local function signs(inls)
  for i = 1, #inls - 1 do
    local a, b = inls[i], inls[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then inls[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return inls
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  cover(meta)
  if meta.lead_in then body_par(nil, meta.lead_in) end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      -- Fed. R. Civ. P. 10(b): each body paragraph is a numbered allegation
      n = n + 1
      body_par(n .. ".", b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      list(b)
    else
      error("mssd-complaint.lua: unsupported block " .. b.t)
    end
  end
  signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x.xml or p(x.body, x.o)) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
