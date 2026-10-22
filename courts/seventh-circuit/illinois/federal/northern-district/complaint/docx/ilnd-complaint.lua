-- Pandoc filter for the ilnd complaint, engine docx, so that it reads and breaks as typst/ilnd-complaint.typ does:
-- court title, caption (parties left in a column closed by a rule on its right and bottom; case number, title and
-- jury legend right), the unnumbered lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)) except after the prayer and
-- jury demand headings, headings, lettered prayer items, the signature block kept together with the last paragraph
-- (Fed. R. Civ. P. 11(a)). Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local BLANK, HEAD_GAP = 276, 138         -- typst blank 13.8 pt, head-gap 6.9 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local DESIGNATION, VERSUS = 720, 1296    -- typst designation-indent 0.5 in, versus-indent 0.9 in
local SIG = 4320                         -- typst sig-left, 3 in
local LEFT, GUTTER, TEXTW = 4752, 360, 9360  -- typst caption-left 3.3 in, caption-gutter 0.25 in; 6.5 in
local PAD, RIGHT_PAD = 200, 144          -- typst caption-pad 10 pt, caption-right-pad 0.1 in
local RULE = 15                          -- the 0.75 pt rule: Word adds its width to the cell, typst draws it over the inset

local UNNUMBERED = { ["PRAYER FOR RELIEF"] = true, ["DEMAND FOR JURY TRIAL"] = true }

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- First page (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function caption(meta, out)
  local title = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF ILLINOIS" }
  if meta.division then title[#title + 1] = pandoc.text.upper(plain(meta.division)) end
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #title and BLANK or 0 })
  end
  -- the party column: each name and designation its own single line, "v." between the sides
  local lp = {}
  local parties = meta.caption.parties
  for k, side in ipairs(parties) do
    for i, n in ipairs(side.names) do
      lp[#lp + 1] = p(xe.inl(n), { before = (k > 1 and i == 1) and BLANK or 0 })
    end
    lp[#lp + 1] = p(xe.inl(side.designation), { left = DESIGNATION, before = BLANK })
    if k < #parties then lp[#lp + 1] = p(xe.runs("v."), { left = VERSUS, before = BLANK }) end
  end
  -- the case number, the judge when assigned, the title and the jury legend
  local rp = { p(xe.runs("Case No.: " .. plain(meta.case_number)), { left = RIGHT_PAD }) }
  if meta.judge then rp[#rp + 1] = p(xe.runs("Judge " .. plain(meta.judge)), { left = RIGHT_PAD }) end
  for i, l in ipairs(meta.brief_title) do
    rp[#rp + 1] = p(xe.inl(l, { b = true }), { left = RIGHT_PAD, before = i == 1 and BLANK or 0 })
  end
  if meta.jury_demand then
    rp[#rp + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { left = RIGHT_PAD, before = BLANK })
  end
  local function cell(w, body, extra)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. body .. '</w:tc>'
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. (PAD - RULE) .. '" w:type="dxa"/><w:right w:w="' .. PAD .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = "<w:tbl>" .. '<w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="' ..
    (TEXTW - LEFT - GUTTER) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(LEFT, table.concat(lp), rule) .. cell(GUTTER, p("")) .. cell(TEXTW - LEFT - GUTTER, table.concat(rp)) ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature (Fed. R. Civ. P. 11(a))
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local rows = { { xe.runs("Dated: " .. plain(meta.date) .. "\tRespectfully submitted,"), 0, 0 } }
  rows[#rows + 1] = { xe.runs("/s/ ") .. xe.inl(sig.signer), SIG, BLANK }
  for _, l in ipairs(sig.lines) do rows[#rows + 1] = { xe.inl(l), SIG, 0 } end
  for i, l in ipairs(sig.firm) do rows[#rows + 1] = { xe.inl(l), SIG, i == 1 and BLANK or 0 } end
  for i, l in ipairs(sig.party) do rows[#rows + 1] = { xe.inl(l), SIG, i == 1 and BLANK or 0 } end
  for i, r in ipairs(rows) do
    out[#out + 1] = p(r[1], { left = r[2], before = i == 1 and BLANK or r[3], keep = i < #rows,
      tab = i == 1 and SIG or nil })
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 2201": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function upper(inlines)
  return inlines:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  assert(meta.caption and meta.caption.parties, "ilnd-complaint: frontmatter needs caption.parties")
  assert(meta.brief_title, "ilnd-complaint: frontmatter needs brief_title (Fed. R. Civ. P. 10(a))")
  assert(meta.signature, "ilnd-complaint: frontmatter needs signature")

  local out = {}
  caption(meta, out)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, before = BLANK }) end

  -- The body as a list of items: { kind, inlines or list, level }.
  local items = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      items[#items + 1] = { "head", b.content, b.level }
    elseif b.t == "Para" or b.t == "Plain" then
      items[#items + 1] = { "para", b.content }
    elseif b.t == "OrderedList" then
      items[#items + 1] = { "list", b }
    else
      error("ilnd-complaint.lua: unsupported block " .. b.t)
    end
  end
  -- the last paragraph and the headings right before it stay with the signature block
  local tail = #items
  while tail > 1 and items[tail - 1][1] == "head" do tail = tail - 1 end

  local n, numbered = 0, true
  for k, it in ipairs(items) do
    local keep = k >= tail
    if it[1] == "head" then
      local level = it[3]
      if level == 1 then numbered = not UNNUMBERED[pandoc.text.upper(plain(it[2]))] end
      -- single lines, bold; levels 1 and 2 centered and underlined (level 1 in capitals), level 3 at the margin; a
      -- group of headings has head-gap above and below it and none inside it
      local first = k == 1 or items[k - 1][1] ~= "head"
      local last = k == #items or items[k + 1][1] ~= "head"
      local txt = level == 1 and upper(it[2]) or it[2]
      out[#out + 1] = xe.para({ xe.KEEP, xe.spacing(first and HEAD_GAP or 0, last and HEAD_GAP or 0, SINGLE),
        xe.ind(0, nil, 0), xe.jc(level <= 2 and "center" or "left"),
        '<w:outlineLvl w:val="' .. (math.min(level, 3) - 1) .. '"/>' },
        xe.inl(txt, { b = true, u = level <= 2 }))
    elseif it[1] == "list" then
      -- prayer and other lists: (a), (b), ... in the number's place
      for j, item in ipairs(it[2].content) do
        local inl = pandoc.Inlines({})
        for m, b in ipairs(item) do
          if m > 1 then inl:insert(pandoc.Space()) end
          inl:extend(b.content)
        end
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + j) .. ")\t") .. xe.inl(inl),
          { line = BODY, first = INDENT, tab = 2 * INDENT, keep = keep })
      end
    elseif numbered then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(it[2]), { line = BODY, first = INDENT, tab = 2 * INDENT, keep = keep })
    else
      out[#out + 1] = p(xe.inl(it[2]), { line = BODY, first = INDENT, keep = keep })
    end
  end

  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
