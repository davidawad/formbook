-- Bankr. D. Vt. motion (with memorandum) in an adversary proceeding, docx engine (docs/DOCX.md): the same markdown
-- contract as typst/vtb-motion-brief.typ, and every block written as it sets it: the court lines, the caption (the
-- debtor box and the parties box, each ruled at its right and bottom, the case column beside them; FRBP 7010,
-- Official Form 416A), the title, the unnumbered introduction (`unnumbered` paragraphs, as filed) and the numbered
-- paragraphs after it, the headings, the single-spaced
-- quotations ("> "), the lettered lists ("1. " or "- ") and the signature block (Vt. LBR 5005-1(b)). Everything
-- printed comes from the sample's frontmatter and body: no case text lives in this file. The caption boxes are
-- OOXML tables, one row per line.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst indent, 0.5 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT = 4824                                  -- typst caption-left, 3.35 in
local CAP_PAD, CAP_GAP = 180, 360                      -- typst caption-pad (0.125 in), caption-gap (0.25 in)
local CAP_FOOT = 105                                   -- typst caption-foot (6 pt) less the 0.75 pt rule LibreOffice
                                                       -- sets below the cell
local DESIGNATION, VERSUS = 2160, 720                  -- typst designation-indent (1.5 in), versus-indent (0.5 in)
local SIG = 4320                                       -- typst signature-indent, 3 in
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

-- A paragraph: o = { before, after, line, left, right, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("vtb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function str(v) return pandoc.utils.stringify(v) end

-- ---------------------------------------------------------------------------
-- Caption: a box is a table of one row per single line, the left cell ruled at its right, rows never split; its
-- foot, a short row ruled at its right and bottom, is a table of its own a tenth of a point below (LibreOffice draws
-- a table's last bottom rule again above the last page of a table that runs over pages).
-- ---------------------------------------------------------------------------

local function tbl(rows)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>'
end

local function row(l, r, foot)
  local lb = '<w:right ' .. RULE .. '/>' .. (foot and ('<w:bottom ' .. RULE .. '/>') or "")
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders>' .. lb .. '</w:tcBorders>' ..
    '<w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. l .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_GAP ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. r .. '</w:tc></w:tr>'
end

local function box(left, right)
  local rows = {}
  for i = 1, math.max(#left, #right) do rows[#rows + 1] = row(left[i] or p(""), right[i] or p("")) end
  return tbl(rows) .. p("", { line = 2 }) .. tbl({ row(p("", { line = CAP_FOOT }), p("", { line = CAP_FOOT }), true) })
end

local function caption(meta)
  local out = {}
  local court = list(need(meta, "court"))
  -- the debtor box a single line below the court
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", keep = true, after = i == #court and SINGLE or 0 })
  end
  local d = need(meta, "debtor")
  local c = need(meta, "caption")
  out[#out + 1] = box(
    { p(xe.runs("In re: ") .. xe.inl(d.name) .. xe.runs(",")), p(xe.runs("Debtor."), { left = DESIGNATION }) },
    { p(xe.runs("Chapter " .. str(d.chapter))), p(xe.runs("Case No. " .. str(d.case_no))) })
  -- the parties box a tenth of a point below (a table of its own), its first line a blank one
  out[#out + 1] = p("", { line = 2 })
  local left = { p("") }
  local plaintiffs = list(c.plaintiffs)
  for _, x in ipairs(plaintiffs) do left[#left + 1] = p(xe.inl(x) .. xe.runs(",")) end
  left[#left + 1] = p(xe.runs(#plaintiffs > 0 and "Plaintiff," or "Plaintiff"), { left = DESIGNATION })
  left[#left + 1] = p(xe.runs("v."), { left = VERSUS })
  for _, x in ipairs(list(c.defendants)) do left[#left + 1] = p(xe.inl(x)) end
  left[#left + 1] = p(xe.runs("Defendants."), { left = DESIGNATION })
  out[#out + 1] = box(left, { p(""), p(xe.runs("Adv. Proc. No. " .. str(need(meta, "adv_no")))) })
  -- the title a single line below the caption and above the body
  out[#out + 1] = p(xe.inl(need(meta, "title"), { b = true }), { jc = "center", before = SINGLE, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature: a single line below the body the dated line, a double line below it the signature lines 3 in. from the
-- left margin; kept whole.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local s = need(meta, "signature")
  local out = { p(xe.inl(s.dated), { before = SINGLE, keep = true }) }
  for i, l in ipairs(list(s.lines)) do
    out[#out + 1] = p(xe.inl(l), { left = SIG, before = i == 1 and BODY or 0, keep = true })
  end
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, bold, kept with the text: levels 1 and 2 centered, level 3 bold italic at the margin.
local function heading(el)
  if el.level < 3 then return p(xe.inl(el.content, { b = true }), { line = BODY, jc = "center", keep = true }) end
  return p(xe.inl(el.content, { b = true, i = true }), { line = BODY, keep = true })
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

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

-- The body blocks; `unnumbered`: how many paragraphs open it without a number.
local function body(blocks, unnumbered)
  local out = {}
  local n, seen = 0, 0
  for k, b in ipairs(blocks) do
    -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
    local last = k == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      -- single-spaced, half an inch in on both sides, a single line above and below
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("vtb-motion-brief.lua: a quotation holds paragraphs") end
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT, before = SINGLE, after = SINGLE,
          keep = last })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("vtb-motion-brief.lua: a list item holds one paragraph")
        end
        out[#out + 1] = p(xe.runs("(" .. LETTERS:sub(i, i) .. ") ") .. xe.inl(item[1].content),
          { line = BODY, left = INDENT, keep = last and i == #b.content })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      seen = seen + 1
      local lead = ""
      if seen > unnumbered then
        n = n + 1
        lead = xe.runs(n .. ". ")
      end
      out[#out + 1] = p(lead .. xe.inl(b.content), { line = BODY, first = INDENT, keep = last })
    else
      error("vtb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = caption(meta)
  for _, x in ipairs(body(doc.blocks, tonumber(pandoc.utils.stringify(meta.unnumbered or "0")) or 0)) do out[#out + 1] = x end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
