-- D.N.M. complaint, docx engine (docs/DOCX.md): the same markdown contract as typst/nmd-complaint.typ, and every
-- block written as it sets it: the court title, the caption (one row per line: the parties, a ")" beside each row and
-- the case number beside the first; Fed. R. Civ. P. 10(a), LR-Civ. 10.1), the title, the lead-in, the headings, the
-- numbered allegations (Fed. R. Civ. P. 10(b)), the unnumbered paragraphs ("^ ": the request for relief, the jury
-- demand), the lettered list items and the signature block (LR-Civ. 83.4(a)). Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file. The caption is an OOXML table. Allegation numbers
-- are typed text followed by a tab (the typst template types them too), so a Word edit does not renumber them.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local GAP = 240                                        -- typst gap, 12 pt
local INDENT = 720                                     -- typst para-indent and list-indent, 0.5 in
local LABEL = 576                                      -- typst list-label, 0.4 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_MARK = 4752, 432                   -- typst caption-left (3.3 in), caption-mark (0.3 in)
local CAP_INSET = 1728                                 -- typst caption-inset, 1.2 in
local CASE_GAP = 288                                   -- typst case-gap, 0.2 in
local SIG_LEFT = 4752                                  -- typst signature-left, 3.3 in

local stringify = pandoc.utils.stringify

local function need(meta, key)
  assert(meta[key] ~= nil, "nmd.lua: the sample's frontmatter must give '" .. key .. "'")
  return meta[key]
end

-- A paragraph: o = { before, after, line, left, hanging, first, tab, jc, keep, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table without cell margins or borders, its rows never split: widths in twips, rows a list of cell lists, each
-- cell a list of paragraphs.
local function tbl(widths, rows)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local trs = {}
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. table.concat(c) ..
        '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- ---------------------------------------------------------------------------
-- First page: court title, caption, title
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local court = list(need(meta, "court"))
  for i, l in ipairs(court) do
    -- the caption a double line below the court title (the last line's space after)
    out[#out + 1] = p(xe.runs(stringify(l):upper(), { b = true }),
      { jc = "center", keep = true, after = i == #court and BODY or 0 })
  end
  local rows = {}
  for k, party in ipairs(list(need(meta, "caption").parties)) do
    if k > 1 then rows[#rows + 1] = p(xe.runs("v."), { left = CAP_INSET }) end
    for _, n in ipairs(list(party.names)) do rows[#rows + 1] = p(xe.inl(n)) end
    rows[#rows + 1] = p(xe.inl(party.designation), { left = CAP_INSET })
  end
  local trs = {}
  for k, r in ipairs(rows) do
    local right = k == 1 and p(xe.runs("Case No. ") .. xe.inl(need(meta, "case_number")), { left = CASE_GAP }) or p("")
    trs[#trs + 1] = { { r }, { p(xe.runs(")")) }, { right } }
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_MARK, TEXTW - CAP_LEFT - CAP_MARK }, trs)
  -- the title a double line below the caption, at the body pitch, 12 pt above the body
  out[#out + 1] = p(xe.inl(need(meta, "brief_title"), { b = true }),
    { line = BODY, before = BODY, after = GAP, jc = "center", keep = true })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature: a double line below the body, the date line (optional) at the margin, then the firm's lines, each
-- attorney group ("and" between), and the attorneys' line, 3.3 in from the left margin, 12 pt between the groups;
-- kept whole.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  local function line(body, gap, left)
    out[#out + 1] = p(body, { left = left or SIG_LEFT, keep = true, before = #out == 0 and BODY or gap or 0 })
  end
  if meta.date then line(xe.runs("Dated: ") .. xe.inl(meta.date), 0, 0) end
  for _, l in ipairs(list(sig.firm)) do line(xe.inl(l)) end
  for k, b in ipairs(list(sig.blocks)) do
    if k > 1 then line(xe.runs("and"), GAP) end
    for i, l in ipairs(list(b)) do line(xe.inl(l), i == 1 and GAP or 0) end
  end
  line(xe.inl(sig.attorneys_for), GAP)
  -- the last line ends the chain
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines)
  local q = { line = BODY, first = INDENT }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings single-spaced, 12 pt above and below, kept with the text: levels 1 and 2 centered bold capitals, level 3
-- bold italic at the margin.
local function heading(el)
  local lvl = math.min(el.level, 3)
  local content = el.content
  if lvl < 3 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return p(xe.inl(content, { b = true, i = lvl == 3 }), { style = "Heading" .. lvl, keep = true, before = GAP,
    after = GAP, jc = lvl < 3 and "center" or "left" })
end

-- List items: `1.` lettered a., b., ... by their number, bullets "•"; the label half an inch in, in a box of 0.4 in,
-- the text hanging after it.
local function letter(i)
  if i <= 26 then return string.char(96 + i) .. "." end
  return string.char(96 + (i - 1) // 26) .. string.char(97 + (i - 1) % 26) .. "."
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

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = cover(meta)
  local start = #out + 1
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in) end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local k = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("nmd.lua: a list item holds one paragraph")
        end
        local label = b.t == "OrderedList" and letter(k) or "\u{2022}"
        out[#out + 1] = p(xe.runs(label .. "\t") .. xe.inl(item[1].content),
          { line = BODY, left = INDENT + LABEL, hanging = LABEL, tab = INDENT + LABEL })
        k = k + 1
      end
    elseif (b.t == "Para" or b.t == "Plain") and b.content[1] and b.content[1].t == "Str"
      and b.content[1].text == "^" and b.content[2] and b.content[2].t == "Space" then
      -- unnumbered: the "^" marker and the space after it dropped
      out[#out + 1] = body_par(nil, pandoc.Inlines({ table.unpack(b.content, 3) }))
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(n .. ".", b.content)
    else
      error("nmd.lua: unsupported block " .. b.t)
    end
  end
  -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
  if #out >= start and not out[#out]:find("<w:keepNext/>", 1, true) then
    out[#out] = out[#out]:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1)
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
