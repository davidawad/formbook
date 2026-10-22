-- nynd complaint (N.D.N.Y.), docx engine (docs/DOCX.md): the same markdown contract as typst/nynd-complaint.typ,
-- and every block written as it sets it: the court's name and the caption (L.R. 10.1(c)(1): the party column ruled
-- below, the civil action number with the judges' initials and the paper's title at its right), the lead-in, the
-- numbered allegations (Fed. R. Civ. P. 10(b)), the headings, the centered "(...)" subtitles, the unnumbered
-- paragraphs ("<!-- unnumbered -->"), the lettered prayer items, block quotations and the signature block (L.R.
-- 10.1(c)(2)). Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
-- Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, number-tab, list-indent, list-label
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER, CAP_PAD = 5184, 432, 144   -- typst caption-left, caption-gutter, caption-case-pad
local CAP_FOOT = 185                                   -- typst caption-foot (10 pt) less the 0.75 pt rule LibreOffice
                                                       -- sets inside the cell
local BETWEEN, DESIGNATION = 720, 2880                 -- typst between-indent, designation-indent
local SIG_W, SIG_GUTTER = 4608, 288                    -- typst signature-w, signature-gutter
local BY_TAB = 407 + 3744                              -- "By: " (20.34 pt) and typst by-line (2.6 in)
local QUOTE, QUOTE_SPACE = 1440, 240                   -- typst quote-indent, quote-space
local RULE = 'w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt
local MARK = "<!-- unnumbered -->"

local stringify = pandoc.utils.stringify

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

-- A one-row table without cell margins that is never split: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- Capitals of a metadata value or inlines, as typst's upper().
local function upper(x)
  if type(x) == "string" then return pandoc.text.upper(x) end
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Caption (L.R. 10.1(c)(1))
-- ---------------------------------------------------------------------------

local function caption(m)
  if not m.judges or stringify(m.judges) == "" then
    error("nynd-complaint: L.R. 10.1(c)(1) requires the assigned judge's initials in the caption (frontmatter: judges)", 0)
  end
  local out = { p(xe.runs("UNITED STATES DISTRICT COURT")), p(xe.runs("NORTHERN DISTRICT OF NEW YORK"), { after = BODY }) }
  local left = {}
  for k, party in ipairs(list(m.caption.parties)) do
    if k > 1 then left[#left + 1] = p(xe.inl(m.caption.between), { before = SINGLE, left = BETWEEN }) end
    for i, n in ipairs(list(party.names)) do
      left[#left + 1] = p(xe.inl(n), { before = (k > 1 and i == 1) and SINGLE or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIGNATION })
  end
  local right = {
    p(xe.inl(m.case_number) .. xe.runs(" (") .. xe.inl(m.judges) .. xe.runs(")"), { left = CAP_PAD }),
    p(xe.inl(upper(m.brief_title), { b = true }), { left = CAP_PAD, before = 3 * SINGLE }),
  }
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" ' .. RULE .. '/></w:tcBorders><w:tcMar><w:bottom w:w="' ..
      CAP_FOOT .. '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("") } },
    { body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (L.R. 10.1(c)(2)): a double line below the body (the space above the first lines of its cells)
-- ---------------------------------------------------------------------------

local function signature(sig)
  for _, s in ipairs(list(sig.signers)) do
    if not s.bar_roll or stringify(s.bar_roll) == "" then
      error("nynd-complaint: L.R. 10.1(c)(2) requires the bar roll number of each signing attorney", 0)
    end
  end
  local r = { p(xe.inl(upper(sig.firm), { b = true }), { before = BODY }) }
  r[#r + 1] = p(xe.runs("By: ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    { before = BODY, tab = BY_TAB })
  for _, s in ipairs(list(sig.signers)) do
    r[#r + 1] = p(xe.inl(s.name))
    r[#r + 1] = p(xe.inl(s.bar_roll))
    r[#r + 1] = p(xe.inl(s.email))
  end
  for i, a in ipairs(list(sig.address)) do r[#r + 1] = p(xe.inl(a), { before = i == 1 and SINGLE or 0 }) end
  r[#r + 1] = p(xe.inl(sig.phone))
  r[#r + 1] = p(xe.inl(sig.role, { i = true }), { before = SINGLE })
  local left = { p(xe.runs("Dated: ") .. xe.inl(sig.dated), { before = BODY }) }
  return tbl({ TEXTW - SIG_W - SIG_GUTTER, SIG_GUTTER, SIG_W }, { { body = left }, { body = { p("") } }, { body = r } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of number-tab), the text.
local function body_par(label, inlines, keep)
  local q = { line = BODY, first = INDENT, keep = keep }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings at the body pitch, bold, kept with the text: level 1 centered in capitals, level 2 centered, level 3 at
-- the margin.
local function heading(el)
  local content = el.content
  if el.level == 1 then content = upper(content) end
  local lvl = math.min(el.level, 3)
  return p(xe.inl(content, { b = true }), { style = "Heading" .. lvl, keep = true, line = BODY,
    jc = lvl < 3 and "center" or "left" })
end

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

-- "<!-- unnumbered --> text" is an HTML block to CommonMark: the text after the marker, read as the body is.
local function unnumbered(b)
  if b.t ~= "RawBlock" or b.format ~= "html" or b.text:sub(1, #MARK) ~= MARK then return nil end
  local d = pandoc.read(b.text:sub(#MARK + 1), "commonmark+smart")
  d = d:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  return d.blocks[1] and d.blocks[1].content or pandoc.Inlines({})
end

function Pandoc(doc)
  local m = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = caption(m)
  -- the lead-in two double lines below the caption
  if m.lead_in and stringify(m.lead_in) ~= "" then
    out[#out + 1] = body_par(nil, m.lead_in):gsub('w:before="0"', 'w:before="' .. 2 * BODY .. '"', 1)
  end
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
    local last = i == #blocks
    local un = unnumbered(b)
    if un then
      out[#out + 1] = body_par(nil, un, last)
    elseif b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("nynd-complaint.lua: a list item holds one paragraph")
        end
        out[#out + 1] = p(xe.runs(letter(k) .. "\t") .. xe.inl(item[1].content), { line = BODY, left = 2 * INDENT,
          hanging = INDENT, tab = 2 * INDENT, keep = last and k == #b.content })
      end
    elseif b.t == "BlockQuote" then
      local ps = b.content
      for k, q in ipairs(ps) do
        out[#out + 1] = p(xe.inl(q.content), { left = QUOTE, right = QUOTE, before = k == 1 and QUOTE_SPACE or 0,
          after = k == #ps and QUOTE_SPACE or 0 })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local s = stringify(b)
      if s:match("^%(") and s:match("%)$") then
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, jc = "center", keep = true })
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, last)
      end
    else
      error("nynd-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(m.signature)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
