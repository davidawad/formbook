-- D. Guam complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it reads
-- and breaks as typst/gud-complaint.typ does (see ../README.md): the counsel block (GNLR 5.1(c)(1)), the court title
-- at 3 in. (GNLR 5.1(b)), the caption (party column, case column; GNLR 5.1(c)(2)-(3), FRCP 10(a)), the lead-in, the
-- numbered paragraphs (FRCP 10(b)), the headings, the lettered items, the unnumbered paragraphs (<!-- unnumbered -->)
-- and the signature block (GNLR 5.1(d)). Everything printed comes from the sample's frontmatter and body: no case
-- text lives in this file. Counsel block and caption are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent and list-indent, 0.5 in
local LABEL = 576                                      -- typst list-label, 0.4 in
local TEXTW = 9360                                     -- 6.5 in
local COUNSEL_W = 4680                                 -- typst counsel-w and caption-w, 3.25 in
local GUTTER = 360                                     -- typst caption-gutter, 0.25 in
local COUNSEL_H = 2880 - SINGLE                        -- typst court-title-top less the margin and a single line
local SIG_LEFT = 4320                                  -- typst signature-indent, 3 in

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

-- A borderless one-row table: widths in twips, a cell = { paragraphs }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(cells[i]) ..
      '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/>' .. (trpr or "") .. '</w:trPr>' ..
    table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  -- counsel in a row at least as tall as the space down to a single line above the court title (3 in. from the top)
  local counsel = {}
  for _, l in ipairs(meta.counsel) do counsel[#counsel + 1] = p(xe.inl(l)) end
  out[#out + 1] = tbl({ COUNSEL_W }, { counsel }, '<w:trHeight w:val="' .. COUNSEL_H .. '" w:hRule="atLeast"/>')
  local court = meta.court_title
  for i, l in ipairs(court) do
    -- the caption stands a double line below the court title (the last title line takes it as space after)
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", before = i == 1 and SINGLE or 0,
      after = i == #court and BODY or 0 })
  end
  local left, right = {}, {}
  for k, side in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.inl(meta.caption.between), { left = INDENT })
      left[#left + 1] = p("")
    end
    for _, n in ipairs(side.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = 2 * INDENT })
  end
  right[#right + 1] = p(xe.inl(meta.case_number))
  right[#right + 1] = p(xe.inl(meta.designation))
  right[#right + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = BODY })
  if meta.brief_subtitle then right[#right + 1] = p(xe.inl(meta.brief_subtitle), { before = SINGLE }) end
  out[#out + 1] = tbl({ COUNSEL_W, GUTTER, TEXTW - COUNSEL_W - GUTTER }, { left, { p("") }, right })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature (GNLR 5.1(d)): a double line above "Respectfully submitted this <date>.", a double line below it the
-- firm, a blank line, "/s/" and the signer, and the signer's lines 3 in. from the left margin; kept whole.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local out = { p(xe.runs("Respectfully submitted this ") .. xe.inl(meta.date) .. xe.runs("."),
    { before = BODY, keep = true }) }
  for i, f in ipairs(sig.firm) do out[#out + 1] = p(xe.inl(f), { left = SIG_LEFT, before = i == 1 and BODY or 0,
    keep = true }) end
  out[#out + 1] = p(xe.runs("/s/ ") .. xe.inl(sig.signer), { left = SIG_LEFT, before = SINGLE, keep = true })
  for _, l in ipairs(sig.lines) do out[#out + 1] = p(xe.inl(l), { left = SIG_LEFT, keep = true }) end
  -- the last line ends the chain
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, keep)
  local q = { line = BODY, first = INDENT, keep = keep }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings at the body pitch, bold, a double line above: level 1 centered in capitals, level 2 at the margin; kept
-- with the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 2)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(BODY, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- Lettered items (a), (b), ...: the label half an inch in, in a box of 0.4 in, the text hanging after it.
local function letter(i)
  if i <= 26 then return "(" .. string.char(96 + i) .. ")" end
  return "(" .. string.char(96 + (i - 1) // 26) .. string.char(97 + (i - 1) % 26) .. ")"
end

local function items(list, out)
  for i, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("gud-complaint.lua: a list item holds one paragraph")
    end
    out[#out + 1] = p(xe.runs(letter(i) .. "\t") .. xe.inl(item[1].content),
      { line = BODY, left = INDENT + LABEL, hanging = LABEL, tab = INDENT + LABEL })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number, as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- An HTML comment marker (<!-- name -->): its name, or nil.
local function marker(b)
  if b.t == "RawBlock" and b.format == "html" then return b.text:match("^<!%-%-%s*(%a+)%s*%-%->") end
  return nil
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = cover(meta)
  -- the body without its markers; an unnumbered marker flags the paragraph after it
  local blocks, flagged = {}, {}
  local pending = false
  for _, b in ipairs(doc.blocks) do
    local m = marker(b)
    if m then
      pending = pending or m == "unnumbered"
    else
      blocks[#blocks + 1] = b
      flagged[#blocks] = pending
      pending = false
    end
  end
  -- the first block of the body stands a double line below the caption
  local gap = BODY
  local function take()
    local g = gap
    gap = 0
    return g
  end
  if meta.lead_in then
    out[#out + 1] = body_par(nil, meta.lead_in, #blocks == 0)
    out[#out] = out[#out]:gsub('w:before="0"', 'w:before="' .. take() .. '"', 1)
  end
  local n = 0
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local before = take()
    local start = #out + 1
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      if flagged[i] then
        out[#out + 1] = body_par(nil, b.content, last)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, last)
      end
    else
      error("gud-complaint.lua: unsupported block " .. b.t)
    end
    if before > 0 and b.t ~= "Header" then
      out[start] = out[start]:gsub('w:before="0"', 'w:before="' .. before .. '"', 1)
    end
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
