-- S.D.N.Y. complaint, docx engine (docs/DOCX.md): the same markdown contract as typst/nysd-complaint.typ, and every
-- block laid out and broken as it sets it: the court title, the caption (a table: the parties left, with a rule at
-- the right and bottom of the party column; the file number, judge, legends and title right; Fed. R. Civ. P. 10(a)),
-- the lead-in, the headings, the numbered paragraphs (Fed. R. Civ. P. 10(b)), the lettered lists "(a)", "(b)", the
-- block quotations and footnotes (pandoc's), and the signature block. The numbering rules are the typst template's:
-- a paragraph under a heading that contains "JURY TRIAL" and a paragraph starting "WHEREFORE" are not numbered;
-- block quotations are not numbered. Nothing case-specific is in this file: every word comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_COL = 4680                     -- typst caption grid: two equal columns
local CAP_INSET = 288                    -- typst caption-inset 0.2 in
local CAP_PAD = 240                      -- typst caption-pad 12 pt
local DESIGNATION = 2592                 -- typst designation-indent 1.8 in
local SIG_COL = 4608                     -- typst sig-column 3.2 in
local LIST_IN, LIST_LABEL = 720, 576     -- typst list-indent 0.5 in, list-label 0.4 in
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local stringify = pandoc.utils.stringify

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("complaint.lua: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- Capitals of a metadata value, as typst's upper().
local function upper(x)
  if type(x) == "string" then return pandoc.text.upper(x) end
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, tab, jc, keep, style }; an empty body is a blank
-- line of its pitch.
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

-- A table without cell margins whose rows never split: widths in twips, a row = { cell = { pr, body } }.
local function tbl(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local trs = {}
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local court = list(need(meta, "court"))
  for i, l in ipairs(court) do
    -- the caption a double line below the court title (the title's space after; a table has none of its own)
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true, after = i == #court and BODY or 0 })
  end
  local left = {}
  local sides = list(need(meta, "caption"))
  for i, side in ipairs(sides) do
    if i > 1 then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("v."), { jc = "center" })
      left[#left + 1] = p("")
    end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
  end
  -- the party column's last line 12 pt above its bottom rule
  left[#left] = left[#left]:gsub('w:after="0"', 'w:after="' .. CAP_PAD .. '"', 1)
  local right = {}
  if meta.electronic == true then
    right[#right + 1] = p(xe.runs("ELECTRONICALLY FILED"))
    right[#right + 1] = p("")
  end
  right[#right + 1] = p(xe.runs("No. ") .. xe.inl(need(meta, "case_number")))
  if meta.judge then right[#right + 1] = p(xe.inl(meta.judge)) end
  right[#right + 1] = p("")
  for _, l in ipairs(list(meta.legends)) do right[#right + 1] = p(xe.inl(upper(l), { b = true })) end
  right[#right + 1] = p("")
  right[#right + 1] = p(xe.inl(upper(need(meta, "title")), { b = true }))
  for _, l in ipairs(list(meta["legends-after"])) do right[#right + 1] = p(xe.inl(upper(l), { b = true })) end
  out[#out + 1] = tbl({ CAP_COL, TEXTW - CAP_COL }, { {
    { pr = '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  } })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature: "Dated:" at the left, the signature column at the right; the row never splits. The double line above
-- it is a 1 pt paragraph kept with the table, its space before the rest: at the top of a page LibreOffice drops a
-- paragraph's space before, as typst drops a block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local right = { p(xe.runs("Respectfully submitted,")) }
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = BODY })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("Dated: ") .. xe.inl(need(meta, "date"))) }
  return p("", { keep = true, before = BODY - 20, line = 20 }) ..
    tbl({ TEXTW - SIG_COL, SIG_COL }, { { { body = left }, { body = right } } })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number, as the typst template boxes it.
local function bind_doubled(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- Headings single-spaced, bold, a single line above and (unless a heading follows) below, kept with the text:
-- level 1 centered capitals, level 2 centered, level 3 italic at the left.
local function heading(el, below)
  local lvl = math.min(el.level, 3)
  local content = lvl == 1 and upper(el.content) or el.content
  return p(xe.inl(content, { b = true, i = lvl == 3 }), { style = "Heading" .. lvl, keep = true, before = SINGLE,
    after = below, jc = lvl < 3 and "center" or "left" })
end

-- Lettered items (a), (b), ...: the label half an inch in, in a box of 0.4 in, the text hanging after it.
local function letter(i)
  if i <= 26 then return "(" .. string.char(96 + i) .. ")" end
  return "(" .. string.char(96 + (i - 1) // 26) .. string.char(97 + (i - 1) % 26) .. ")"
end

-- A body paragraph through pandoc (it may carry footnotes), in a style of reference.xml: numbered (the number, a tab
-- to 1 in), unnumbered; a variant without widow control when it carries a note, kept with the signature when last.
local function body_par(label, inlines, last)
  local base = label and "Numbered" or "Body Text"
  local style = last and (base .. " Keep") or has_note(inlines) and (base .. " Note") or base
  local content = pandoc.Inlines({})
  if label then
    content:insert(pandoc.Str(label))
    content:insert(pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
  end
  content:extend(inlines)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "case_number", "caption", "title", "signature", "date" }) do need(meta, k) end
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = xe.inlines })
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = xe.raw(x) end
  -- the lead-in, unnumbered, a double line below the caption
  if meta.lead_in then
    out[#out + 1] = xe.raw(p(xe.inl(meta.lead_in), { line = BODY, first = 720, before = BODY }))
  end
  local blocks = doc.blocks
  local n = 0
  local unnumbered = false
  for i, b in ipairs(blocks) do
    -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
    local last = i == #blocks
    if b.t == "Header" then
      unnumbered = stringify(b):find("JURY TRIAL", 1, true) ~= nil
      local next_heading = not last and blocks[i + 1].t == "Header"
      out[#out + 1] = xe.raw(heading(b, next_heading and 0 or SINGLE))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("complaint.lua: a list item holds one paragraph")
        end
        out[#out + 1] = xe.raw(p(xe.runs(letter(k) .. "\t") .. xe.inl(item[1].content), { line = BODY,
          left = LIST_IN + LIST_LABEL, hanging = LIST_LABEL, tab = LIST_IN + LIST_LABEL,
          keep = last and k == #b.content }))
      end
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
    elseif b.t == "Para" or b.t == "Plain" then
      if stringify(b):match("^WHEREFORE") or unnumbered then
        out[#out + 1] = body_par(nil, b.content, last)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, last)
      end
    else
      error("complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
