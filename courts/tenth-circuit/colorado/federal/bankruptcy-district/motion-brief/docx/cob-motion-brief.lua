-- Bankr. D. Colo. motion with memorandum, docx engine (docs/DOCX.md): the same markdown contract as
-- typst/cob-motion-brief.typ, and every block written as it sets it: the court title, the caption (the debtor block,
-- then the adversary block when the frontmatter has one, each the party column beside the case column; FRBP 9004(b),
-- 7010), the title, the headings (level 1 centered bold capitals, level 2 and deeper numbered I., A., 1.), the
-- paragraphs with their native footnotes (pandoc writes them, styles of reference.xml), the block quotations, the
-- signature block and the optional certificate of service. Everything printed comes from the sample's frontmatter and
-- body: no case text lives in this file. The caption blocks and the "Dated:" rows are OOXML tables of one row that is
-- never split. A Westlaw star page ("at *4") is written `\*4` in the sample, as typst's CommonMark reader needs it.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, quote-indent: 0.5 in
local TAB = 720                                        -- typst heading-tab, 0.5 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_RIGHT, CAP_GUTTER = 3744, 432                -- typst caption-right (2.6 in), caption-gutter (0.3 in)
local NAME, DESIGNATION = 576, 1152                    -- typst name-indent (0.4 in), designation-indent (0.8 in)
local SIG_COL = 4608                                   -- typst signature-column, 3.2 in

local stringify = pandoc.utils.stringify

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

-- A one-row table without cell margins that is never split: widths in twips, cells = { { paragraphs } }.
local function tbl(widths, cells)
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
  if v == nil then error("cob-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function upper(v)
  return pandoc.Inlines(v):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Caption: the court title, a single line below it the debtor block, a single line below that the adversary block,
-- and the title a single line above and below (an empty single line between the two tables keeps them apart).
-- ---------------------------------------------------------------------------

local function caption_block(left, right)
  return tbl({ TEXTW - CAP_RIGHT - CAP_GUTTER, CAP_GUTTER, CAP_RIGHT }, { left, { p("") }, right })
end

local function caption(meta)
  local out = {}
  local court = list(need(meta, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true, after = i == #court and SINGLE or 0 })
  end
  local d = need(meta, "debtor")
  local left = { p(xe.runs("IN RE:")), p("") }
  for _, n in ipairs(list(d.names)) do left[#left + 1] = p(xe.inl(n), { left = NAME }) end
  left[#left + 1] = p("")
  left[#left + 1] = p(d.designation and xe.inl(d.designation) or xe.runs("Debtor."), { left = DESIGNATION })
  local right = { p(xe.runs("Case No. ") .. xe.inl(d.case_number)) }
  if d.chapter then right[#right + 1] = p(xe.inl(d.chapter)) end
  out[#out + 1] = caption_block(left, right)
  if meta.adversary then
    local adv = meta.adversary
    out[#out + 1] = p("")
    left = {}
    for i, side in ipairs(list(adv.parties)) do
      if i > 1 then left[#left + 1] = p("") end
      for _, n in ipairs(list(side.names)) do left[#left + 1] = p(xe.inl(n)) end
      left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
    end
    out[#out + 1] = caption_block(left, { p(xe.runs("Adv. Proc. No. ") .. xe.inl(adv.case_number)) })
  end
  out[#out + 1] = p(xe.inl(need(meta, "title"), { b = true }), { jc = "center", before = SINGLE, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature and certificate of service: "Dated:" at the left margin, the signer's lines in a column at the right.
-- ---------------------------------------------------------------------------

local function dated(date, right)
  return tbl({ TEXTW - SIG_COL, SIG_COL }, { { p(xe.runs("Dated: ") .. xe.inl(date)) }, right })
end

local function signature(meta)
  local s = need(meta, "signature")
  local right = { p(xe.runs("Respectfully submitted,")), p("") }
  local firm = list(s.firm)
  for _, l in ipairs(firm) do right[#right + 1] = p(xe.inl(l)) end
  if #firm > 0 then right[#right + 1] = p("") end
  right[#right + 1] = p(xe.runs("/s/ ") .. xe.inl(s.signer))
  for _, l in ipairs(list(s.lines)) do right[#right + 1] = p(xe.inl(l)) end
  return dated(need(meta, "date"), right)
end

-- A double line below the signature: the heading, a single line below it the certificate at the body pitch, a single
-- line below that the date and the "/s/" line; kept whole.
local function certificate(cert)
  return {
    p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", before = BODY, after = SINGLE, keep = true }),
    p(xe.inl(cert.text), { line = BODY, first = INDENT, after = SINGLE, keep = true }),
    dated(cert.date, { p(xe.runs("/s/ ") .. xe.inl(cert.signer)) }),
  }
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do
      s = s .. v[2]
      n = n - v[1]
    end
  end
  return s
end

-- typst heading-label: level 2 "I.", level 3 "A.", level 4 "1.".
local function label(level, k)
  if level == 2 then return roman(k) .. "." end
  if level == 3 then return string.char(64 + k) .. "." end
  return k .. "."
end

-- Headings single-spaced, a single line above and below, kept with the text: level 1 centered bold capitals; level 2
-- and deeper bold, the label in a box of heading-tab (each level a heading-tab further in), the title hanging.
local function heading(el, k)
  if el.level == 1 then
    return p(xe.inl(upper(el.content), { b = true }), { before = SINGLE, after = SINGLE, keep = true, jc = "center" })
  end
  local level = math.min(el.level, 4)
  local left = (level - 1) * TAB
  return p(xe.runs(label(level, k) .. "\t", { b = true }) .. xe.inl(el.content, { b = true }),
    { before = SINGLE, after = SINGLE, keep = true, left = left, hanging = TAB, tab = left })
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

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

function Pandoc(doc)
  -- the break rules on the body and on every metadata value the template prints (the certificate's "CM/ECF")
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtor", "title", "signature", "date" }) do need(meta, k) end
  local blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = xe.raw(x) end
  local counts = { 0, 0, 0, 0 }
  for i, b in ipairs(blocks) do
    -- the last block stays whole with the signature block, a double line below it
    local last = i == #blocks
    if b.t == "Header" then
      local level = math.min(b.level, 4)
      counts[level] = counts[level] + 1
      for j = level + 1, 4 do counts[j] = 0 end
      out[#out + 1] = xe.raw(heading(b, counts[level]))
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("cob-motion-brief.lua: a quotation holds paragraphs") end
        out[#out + 1] = xe.raw(p(xe.inl(q.content), { left = INDENT, right = INDENT, before = SINGLE, after = SINGLE,
          keep = last }))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local style = last and "Body Text Last" or has_note(b.content) and "Body Text Note" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    else
      error("cob-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  if meta.certificate then
    for _, x in ipairs(certificate(meta.certificate)) do out[#out + 1] = xe.raw(x) end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
