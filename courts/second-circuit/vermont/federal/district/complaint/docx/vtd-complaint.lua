-- D. Vt. complaint, docx engine (docs/DOCX.md): the same markdown contract as typst/vtd-complaint.typ, and every
-- block written as it sets it: the court title, the caption (the parties closed by a rule at the right and the
-- bottom; the case number, the title and the jury demand at the right; Fed. R. Civ. P. 10(a)), the headings, the
-- numbered paragraphs (Fed. R. Civ. P. 10(b)), the unnumbered paragraphs ("~ ", the WHEREFORE clause), the prayer
-- lettered A., B., ... and the signature block. Everything printed comes from the sample's frontmatter and body: no
-- case text lives in this file. The caption is an OOXML table.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent and list-indent, 0.5 in
local LABEL = 576                                      -- typst list-label, 0.4 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4464, 360                 -- typst caption-left (3.1 in), caption-gutter (0.25 in)
local CAP_GAP = 216                                    -- typst caption-gap, 0.15 in
local CAP_PAD = 240                                    -- typst caption-pad, 12 pt
local CAP_FOOT = 185                                   -- typst caption-foot (200) less the 0.75 pt rule LibreOffice
                                                       -- sets below the cell
local SIG_LEFT = 4176                                  -- typst signature-indent, 2.9 in
local RULE = 'w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt

local stringify = pandoc.utils.stringify

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

-- ---------------------------------------------------------------------------
-- Court title and caption
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center", keep = true }),
    -- the caption a double line below the court title (the title's space after)
    p(xe.runs("FOR THE DISTRICT OF VERMONT", { b = true }), { jc = "center", keep = true, after = BODY }),
  }
  local left = {}
  for k, party in ipairs(list(meta.caption.parties)) do
    if k > 1 then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("v."))
      left[#left + 1] = p("")
    end
    for _, n in ipairs(list(party.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p("")
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local label = meta.case_label and stringify(meta.case_label) or "Civil Action No."
  local right = {
    p(xe.runs(label .. " ") .. xe.inl(meta.case_number), { left = CAP_GAP }),
    p(xe.inl(meta.brief_title, { b = true }), { left = CAP_GAP, before = BODY }),
  }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { left = CAP_GAP, before = SINGLE })
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" ' .. RULE .. '/><w:right w:val="single" ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("") } },
    { body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature: the date line at the body pitch, a double line below it "By:" and each counsel's block with a blank
-- line between, 2.9 in from the left margin; kept whole.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local s = meta.signature
  local out = { p(xe.inl(s.date_line), { line = BODY, first = INDENT, before = BODY, keep = true }) }
  local first = true
  local function line(body)
    out[#out + 1] = p(body, { left = SIG_LEFT, keep = true, before = first and BODY or 0 })
    first = false
  end
  if s.by then line(xe.runs("By: /s/ ") .. xe.inl(s.by)) else line(xe.runs(string.rep("_", 34))) end
  for _, b in ipairs(list(s.blocks)) do
    line("")
    for _, l in ipairs(list(b)) do line(xe.inl(l)) end
  end
  if s.counsel_for then
    line("")
    line(xe.inl(s.counsel_for))
  end
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

-- Headings single-spaced, a single line above and below, kept with the text: level 1 centered bold capitals, level 2
-- centered bold, level 3 bold italic at the margin.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return p(xe.inl(content, { b = true, i = lvl == 3 }), { style = "Heading" .. lvl, keep = true, before = SINGLE,
    after = SINGLE, jc = lvl < 3 and "center" or "left" })
end

-- Prayer items A., B., ... by their number: the label half an inch in, in a box of 0.4 in, the text hanging after it.
local function letter(i)
  if i <= 26 then return string.char(64 + i) .. "." end
  return string.char(64 + (i - 1) // 26) .. string.char(65 + (i - 1) % 26) .. "."
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
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" then
      local k = b.listAttributes.start
      for _, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("vtd-complaint.lua: a prayer item holds one paragraph")
        end
        out[#out + 1] = p(xe.runs(letter(k) .. "\t") .. xe.inl(item[1].content),
          { line = BODY, left = INDENT + LABEL, hanging = LABEL, tab = INDENT + LABEL })
        k = k + 1
      end
    elseif (b.t == "Para" or b.t == "Plain") and b.content[1] and b.content[1].t == "Str"
      and b.content[1].text == "~" then
      -- unnumbered: the "~" marker and the space after it dropped
      out[#out + 1] = body_par(nil, pandoc.Inlines({ table.unpack(b.content, 3) }))
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(n .. ".", b.content)
    else
      error("vtd-complaint.lua: unsupported block " .. b.t)
    end
  end
  -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
  if #out >= start and not out[#out]:find("<w:keepNext/>", 1, true) then
    out[#out] = out[#out]:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1)
  end
  -- the body a double line below the caption
  if out[start] then
    out[start] = out[start]:gsub('w:before="%d+"', 'w:before="' .. BODY .. '"', 1)
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
