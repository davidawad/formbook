-- N.D. Tex. complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it reads
-- and breaks as typst/txnd-complaint.typ does (see ../README.md "Engines"): the court title, the caption table (one
-- row per party line with a section mark beside it, the case number and the jury legend on the middle rows), the
-- title of the paper, the numbered paragraphs (Fed. R. Civ. P. 10(b)), the headings, the numbered prayer items, the
-- unnumbered WHEREFORE lead-in and the signature block. Everything printed comes from the sample's frontmatter and
-- body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent, item-indent and heading-hang, 0.5 in
local TEXTW = 9360                     -- 6.5 in
local CAP_LEFT, CAP_SIGN = 5184, 576   -- typst caption-left 3.6 in, caption-sign 0.4 in
local SIG_LEFT, SIG_GUTTER = 4320, 288 -- typst sig-left 3.0 in, sig-gutter 0.2 in
local COVER_GAP, TITLE_AFTER = 360, 200 -- typst cover-gap 18 pt, title-after 10 pt
local H_ABOVE, H_BELOW = 320, 40       -- typst heading-above 16 pt, heading-below 2 pt
local SIG_GAP = 120                    -- typst sig-gap 6 pt

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table without borders or cell margins: widths, rows of cells (each a list of paragraphs), row properties.
local function tbl(widths, rows, trpr)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, w in ipairs(widths) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
        table.concat(cells[i].body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Court title, caption and title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local court = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF TEXAS" }
  if meta.court_division and plain(meta.court_division) ~= "" then
    court[#court + 1] = pandoc.text.upper(plain(meta.court_division))
  end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end
  -- The caption: one row per party line, a section mark beside it; the case number on the middle row, the jury
  -- legend on the row after it. Word has no space around a table: the paragraphs before and after it carry it.
  local lines = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then lines[#lines + 1] = "v." end
    for _, n in ipairs(party.names) do lines[#lines + 1] = n end
    lines[#lines + 1] = party.designation
  end
  local mid = math.floor(#lines / 2)
  local rows = {}
  for i, l in ipairs(lines) do
    local right = ""
    if i == mid then
      right = xe.runs("CIVIL ACTION NO. ") .. xe.inl(meta.case_number)
    elseif i == mid + 1 and meta.jury_demand == true then
      right = xe.runs("JURY TRIAL DEMANDED", { b = true })
    end
    rows[#rows + 1] = { { body = { p(xe.inl(l)) } }, { body = { p(xe.runs("§"), { jc = "center" }) } },
      { body = { p(right) } } }
  end
  -- the space above the caption: a 1 pt paragraph carries it (a table cell would keep it at a page top)
  out[#out + 1] = p("", { before = COVER_GAP - 20, line = 20 })
  out[#out + 1] = tbl({ CAP_LEFT, CAP_SIGN, TEXTW - CAP_LEFT - CAP_SIGN }, rows, '<w:trPr><w:cantSplit/></w:trPr>')
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.brief_title)), { b = true }),
    { jc = "center", before = COVER_GAP, after = TITLE_AFTER })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" at the left; "Respectfully submitted," the firm, the signature, the address and the
-- role at the right, single spaced, the groups 6 pt apart; the row never splits. The space above it is a 1 pt
-- paragraph kept with the table, its space before the rest (at the top of a page LibreOffice drops a paragraph's
-- space before, as typst drops a block's, but keeps it in a cell).
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,")) }
  local function group(items)
    for i, l in ipairs(items) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and SIG_GAP or 0 }) end
  end
  group(sig.firm)
  group({ "/s/ " .. plain(sig.signer), plain(sig.signer), sig.bar })
  group(sig.address)
  group(sig.lines)
  return p("", { keep = true, before = BODY - 20, line = 20 }) ..
    tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { { body = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) } },
      { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } } },
      '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, o)
  local q = { line = BODY, first = INDENT, keep = o.keep }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings, single spaced and bold, kept with the text: level 1 centered capitals, level 2 at the margin with its
-- label ("I.") in a half-inch box and the text hanging after it, level 3 centered.
local function heading(el)
  local lvl = math.min(el.level, 3)
  local content = el.content
  local o = { style = "Heading" .. lvl, keep = true, before = H_ABOVE, after = H_BELOW, jc = "center" }
  local body
  if lvl == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    body = xe.inl(content, { b = true })
  elseif lvl == 2 then
    o.jc = "left"
    local first = content[1]
    if first and first.t == "Str" and (first.text:match("^[IVXLC]+%.$") or first.text:match("^[A-Z]%.$")
        or first.text:match("^%d+%.$")) and content[2] and content[2].t == "Space" then
      o.left, o.hanging = INDENT, INDENT
      local rest = pandoc.Inlines({})
      for k = 3, #content do rest:insert(content[k]) end
      body = xe.runs(first.text .. "\t", { b = true }) .. xe.inl(rest, { b = true })
    else
      body = xe.inl(content, { b = true })
    end
  else
    body = xe.inl(content, { b = true })
  end
  return p(body, o)
end

-- Prayer items, numbered 1., 2., ... (a bullet list keeps its bullet): the number half an inch in, the text hanging
-- a further half inch (typst item-indent and the label box), double spaced.
local function items(list, out)
  for j, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("txnd-complaint.lua: a list item holds one paragraph")
    end
    local lab = list.t == "OrderedList" and (j .. ".") or "\u{2022}"
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 45.50.471"; typst boxes "[§¶]+ \S+"; xe.inl binds one sign).
local function doubled_signs(inlines)
  for k = 1, #inlines - 1 do
    local a, b = inlines[k], inlines[k + 1]
    if a.t == "Str" and a.text:match("^[§¶][§¶]+$") and b.t == "Space" then inlines[k + 1] = pandoc.Str("\u{00A0}") end
  end
  return inlines
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Inlines = doubled_signs }):walk({ Str = breaks })
  local out = cover(meta)
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      if plain(b):sub(1, 9) == "WHEREFORE" then
        out[#out + 1] = body_par(nil, b.content, { keep = last })
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, { keep = last })
      end
    else
      error("txnd-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
