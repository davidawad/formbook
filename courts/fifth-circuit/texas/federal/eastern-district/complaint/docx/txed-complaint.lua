-- txed-complaint.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/txed-complaint.typ does (see ../README.md, "Engines"): the court lines, the caption (parties on the left, the
-- case number and the jury demand at the foot of the right column, CV-38(a)) and the title of the paper; level-1
-- headings labelled I., II., ...; numbered paragraphs (Fed. R. Civ. P. 10(b): one counter for the whole pleading, the
-- markdown's own numbers ignored); the prayer lettered a., b., ...; the signature block at the right half of the
-- page. Everything printed comes from the sample's frontmatter and body: no case text lives in this file. The caption
-- is an OOXML table.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs are pandoc's
-- own (styles in docx/reference.xml), so that their footnotes are Word footnotes.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_RIGHT, CAP_GUTTER = 3744, 360  -- typst caption-right 2.6 in, caption-gutter 0.25 in
local DESIG = 2160                       -- typst designation-indent 1.5 in
local SIG = 4320                         -- typst signature-indent 3 in
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, jc, keep, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function upper(ils)
  return ils:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Cover: court lines, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local court = meta.court or {}
  -- the caption stands a double line below the court (typst: the caption block's above); Word has no space before
  -- a table, so the last court line takes it as space after
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(upper(pandoc.Inlines(l)), { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation, indented; "v." between the parties.
  local left = {}
  for k, party in ipairs(meta.caption) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG })
  end
  -- Right cell, at the foot of the row (typst: align(bottom)): the case number, the jury demand a single line below.
  local right = { p(xe.inl(meta.case_number)) }
  if meta.jury_demand then right[#right + 1] = p(xe.inl(meta.jury_demand, { b = true }), { before = SINGLE }) end
  local capl = TEXTW - CAP_RIGHT - CAP_GUTTER
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. capl .. '"/><w:gridCol w:w="' .. (TEXTW - capl) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. capl .. '" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - capl) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_GUTTER ..
    '" w:type="dxa"/></w:tcMar><w:vAlign w:val="bottom"/></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- The title: bold capitals, centered, a double line below the caption (as space before: Word has no space after a
  -- table); the text follows on its grid.
  out[#out + 1] = p(xe.inl(upper(pandoc.Inlines(meta.brief_title)), { b = true }),
    { jc = "center", before = BODY, keep = true })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (CV-10(a)(3)): at 3 in, single spaced, a double line below the text; kept on one page (each line
-- kept with the next, as the typst block is unbreakable).
-- ---------------------------------------------------------------------------

local function signature(sig)
  local lines = {}
  local function add(body, before) lines[#lines + 1] = { body, before or 0 } end
  add(xe.runs("Respectfully submitted,"), BODY)
  for i, l in ipairs(sig.firm or {}) do add(xe.inl(l), i == 1 and SINGLE or 0) end
  add(xe.runs("/s/ ") .. xe.inl(sig.signer), SINGLE)
  add(xe.inl(sig.signer))
  for _, l in ipairs(sig.lines or {}) do add(xe.inl(l)) end
  add(xe.inl(sig.role), SINGLE)
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { left = SIG, before = l[2], keep = i < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph in its style (pandoc writes it, footnotes included); the Noted variant (no widow control) for a
-- paragraph that holds a footnote: typst moves the line with the reference on with its note; the Keep variant for
-- a paragraph kept whole with the block after it.
local function div(style, ils, keep)
  local noted = false
  pandoc.Inlines(ils):walk({ Note = function() noted = true end })
  local v = keep and " Keep" or noted and " Noted" or ""
  return pandoc.Div({ pandoc.Para(ils) }, { ["custom-style"] = style .. v })
end

-- Headings at the body pitch, bold, kept with the text: level 1 centered capitals numbered I., II., ...; deeper
-- levels at the margin.
local function heading(el, n)
  if el.level == 1 then
    local ils = pandoc.Inlines({ pandoc.Str(roman(n) .. "."), pandoc.Space() })
    ils:extend(upper(el.content))
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(ils, { b = true }))
  end
  return xe.para({ xe.style("Heading" .. math.min(el.level, 5)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("left") }, xe.inl(el.content, { b = true }))
end

local function item_inlines(item, what)
  if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
    error("txed-complaint.lua: a " .. what .. " holds one paragraph")
  end
  return item[1].content
end

-- A doubled section or paragraph sign stays with its number ("§§ 271"), as typst boxes it.
local function signs(ils)
  for i = 1, #ils - 1 do
    if ils[i].t == "Str" and ils[i].text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and ils[i + 1].t == "Space" then
      ils[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return ils
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Inlines = function(ils) return signs(xe.inlines(ils)) end })
  doc.blocks = doc.blocks:walk({ Str = breaks })
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = xe.raw(x) end
  local sections, n = 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then sections = sections + 1 end
      out[#out + 1] = xe.raw(heading(b, sections))
    elseif b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        n = n + 1
        local ils = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        ils:extend(item_inlines(item, "numbered paragraph"))
        out[#out + 1] = div("Numbered Paragraph", ils)
      end
    elseif b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local ils = pandoc.Inlines({ pandoc.Str(string.char(96 + i) .. "."), TAB })
        ils:extend(item_inlines(item, "prayer item"))
        -- the last item stays whole with what follows (the signature block), as in typst
        out[#out + 1] = div("Lettered Item", ils, i == #b.content)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = div("Body Text", b.content)
    else
      error("txed-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta.signature))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
