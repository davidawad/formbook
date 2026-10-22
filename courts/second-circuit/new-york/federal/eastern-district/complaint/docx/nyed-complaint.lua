-- nyed complaint, docx engine (docs/DOCX.md): the same markdown contract as typst/nyed-complaint.typ, and every block
-- written as it sets it: the counsel block, the court's name, the caption (the party column between two rules, the
-- docket number and the jury demand at its right; Fed. R. Civ. P. 10(a)), the title, the lead-in, the numbered
-- allegations (Fed. R. Civ. P. 10(b)), the headings, the unnumbered WHEREFORE paragraph, the lettered prayer
-- ("- ") and the signature block (Fed. R. Civ. P. 11(a)). Everything printed comes from the sample's frontmatter and
-- body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, number-tab and prayer-tab, 0.5 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_GAP = 4896, 288                    -- typst caption-left (3.4 in), caption-gap (0.2 in)
local CAP_PAD = 165                                    -- typst caption-pad (9 pt) less the 0.75 pt rule LibreOffice
                                                       -- sets inside the cell
local AGAINST, DESIGNATION = 1728, 2736                -- typst against-indent (1.2 in), designation-indent (1.9 in)
local SIG_W = 4608                                     -- typst signature-w, 3.2 in
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

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("nyed-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- Capitals of a metadata value or inlines, as typst's upper().
local function upper(x)
  if type(x) == "string" then return pandoc.text.upper(x) end
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Counsel block, court's name, caption, title
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local counsel = list(meta.counsel)
  for _, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l)) end
  local court = list(need(meta, "court"))
  for i, l in ipairs(court) do
    -- a double line below the counsel block; the caption a double line below the last line (its space after)
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true,
      before = (i == 1 and #counsel > 0) and BODY or 0, after = i == #court and BODY or 0 })
  end
  local left = {}
  local sides = list(need(meta, "caption"))
  for i, side in ipairs(sides) do
    if i > 1 then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("-against-"), { left = AGAINST })
      left[#left + 1] = p("")
    end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
  end
  local right = { p(xe.runs("Docket No. ") .. xe.inl(need(meta, "case_number")), { left = CAP_GAP }) }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { left = CAP_GAP, before = SINGLE })
  end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:top w:val="single" ' .. RULE .. '/><w:bottom w:val="single" ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:top w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', body = left },
    { body = right },
  })
  out[#out + 1] = p(xe.inl(upper(need(meta, "title")), { b = true }), { jc = "center", before = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature: a double line below the body (the space above its first lines), "Dated:" at the left, the signature column at the right; never split.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local right = { p(xe.runs("Respectfully submitted,"), { before = BODY }) }
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = BODY })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("Dated: ") .. xe.inl(need(meta, "date")), { before = BODY }) }
  return tbl({ TEXTW - SIG_W, SIG_W }, { { body = left }, { body = right } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of number-tab), the text.
local function body_par(label, inlines, o)
  local q = { line = BODY, first = INDENT, keep = o.keep, before = o.before }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings single-spaced, a single line above and below, kept with the text: level 1 centered bold capitals, level 2
-- centered bold, level 3 at the margin bold.
local function heading(el)
  local content = el.content
  if el.level == 1 then content = upper(content) end
  local lvl = math.min(el.level, 3)
  return p(xe.inl(content, { b = true }), { style = "Heading" .. lvl, keep = true, before = SINGLE, after = SINGLE,
    jc = lvl < 3 and "center" or "left" })
end

-- Prayer items A., B., ...: the label half an inch in, in a box of half an inch, the text hanging after it.
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
  for _, k in ipairs({ "case_number", "court", "caption", "title", "date", "signature" }) do need(meta, k) end
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = cover(meta)
  -- the lead-in a single line below the title
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in, { before = SINGLE }) end
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("nyed-complaint.lua: a prayer item holds one paragraph")
        end
        out[#out + 1] = p(xe.runs(letter(k) .. "\t") .. xe.inl(item[1].content), { line = BODY, left = 2 * INDENT,
          hanging = INDENT, tab = 2 * INDENT, keep = last and k == #b.content })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if stringify(b):match("^WHEREFORE") then
        out[#out + 1] = body_par(nil, b.content, { keep = last })
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, { keep = last })
      end
    else
      error("nyed-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
