-- Pandoc filter for the wvnd complaint, engine docx, so that it reads and breaks as typst/wvnd-complaint.typ does:
-- court title, caption (parties left, civil action number right, a rule beneath), the title, the unnumbered lead-in,
-- numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lettered prayer items, the signature block kept together
-- with the last paragraph (Fed. R. Civ. P. 11(a); LR Gen P 5.03(c)). Every case word comes from the sample's
-- frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local CAPTION_GAP, COVER_GAP = 120, 240  -- typst caption-gap 6 pt, cover-gap 12 pt
local INDENT = 720                       -- typst para-indent, item-indent and item-label, 0.5 in
local DESIGNATION = 1440                 -- typst designation-indent, 1 in
local SIG = 4680                         -- typst sig-left, 3.25 in
local LEFT, GUTTER, TEXTW = 5184, 360, 9360  -- typst caption-left 3.6 in, caption-gutter 0.25 in; 6.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab, rule }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.rule then props[#props + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>' end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Caption
-- ---------------------------------------------------------------------------

local function caption(meta, out)
  local title = { "UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF WEST VIRGINIA" }
  if meta.division then title[#title + 1] = plain(meta.division) end
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(l), { line = BODY, jc = "center", after = i == #title and COVER_GAP or 0 })
  end
  -- the party column: each name and designation its own single-spaced paragraph, "v." between the sides
  local left = {}
  local sides = meta.caption
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do left[#left + 1] = { xe.inl(n), 0 } end
    left[#left + 1] = { xe.inl(side.designation), DESIGNATION }
    if i < #sides then left[#left + 1] = { xe.runs("v."), 0 } end
  end
  local lp = {}
  for k, l in ipairs(left) do
    lp[#lp + 1] = p(l[1], { left = l[2], after = k < #left and CAPTION_GAP or 0 })
  end
  local rp = { p(xe.runs("Civil Action No. " .. plain(meta.case_number))) }
  if meta.judge then rp[#rp + 1] = p(xe.runs("Judge: " .. plain(meta.judge)), { before = CAPTION_GAP }) end
  local function cell(w, body, valign)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' ..
      (valign and '<w:vAlign w:val="' .. valign .. '"/>' or "") .. '</w:tcPr>' .. body .. '</w:tc>'
  end
  out[#out + 1] = "<w:tbl>" .. '<w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="' ..
    (TEXTW - LEFT - GUTTER) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(LEFT, table.concat(lp)) .. cell(GUTTER, p("")) .. cell(TEXTW - LEFT - GUTTER, table.concat(rp), "bottom") ..
    '</w:tr></w:tbl>'
  -- the rule: a 1 pt line with the rule as its bottom border (typst rule-height 1.75 pt)
  out[#out + 1] = p("", { line = 20, before = COVER_GAP, after = COVER_GAP, rule = true })
  -- Fed. R. Civ. P. 10(a): the title of the complaint names the paper
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { line = BODY, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature (Fed. R. Civ. P. 11(a); LR Gen P 5.03(c))
-- ---------------------------------------------------------------------------

local function signature(sig, out)
  local has_email, has_phone = false, false
  for _, l in ipairs(sig.lines) do
    local s = plain(l)
    if s:find("@", 1, true) then has_email = true end
    if s:match("%(?%d%d%d%)?[ .-]?%d%d%d[ .-]?%d%d%d%d") then has_phone = true end
  end
  assert(has_email, "wvnd-complaint: the signature lines need an e-mail address (Fed. R. Civ. P. 11(a))")
  assert(has_phone, "wvnd-complaint: the signature lines need a telephone number (Fed. R. Civ. P. 11(a))")
  local lines = {
    { xe.runs("Dated: " .. plain(sig.date)), BODY, 0, BODY },
    { xe.inl(sig.party), 0, SIG, BODY },
    { xe.runs("By Counsel,"), 0, SIG, BODY },
    { xe.runs("s/ ") .. xe.inl(sig.signer), BODY, SIG, SINGLE },
  }
  for i, l in ipairs(sig.lines) do lines[#lines + 1] = { xe.inl(l), i == 1 and SINGLE or 0, SIG, SINGLE } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], line = l[4], keep = i < #lines })
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

-- A doubled sign stays with its number ("§§ 1331": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A paragraph that starts "~ " is unnumbered: the inlines without the marker, or nil.
local function unmarked(inl)
  if inl[1] and inl[1].t == "Str" and inl[1].text == "~" then
    local rest = pandoc.Inlines({})
    for k = 2, #inl do rest:insert(inl[k]) end
    if rest[1] and rest[1].t == "Space" then rest:remove(1) end
    return rest
  end
  return nil
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  assert(meta.case_number, "wvnd-complaint: frontmatter needs case_number")
  assert(meta.caption, "wvnd-complaint: frontmatter needs caption (a list of sides)")
  assert(meta.title, "wvnd-complaint: frontmatter needs title (Fed. R. Civ. P. 10(a))")
  assert(meta.signature, "wvnd-complaint: frontmatter needs signature")

  local out = {}
  caption(meta, out)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT }) end

  -- The body as a list of items: { kind, inlines }. pandoc reads a "~ " paragraph after another paragraph as the
  -- definition of a term (the paragraph before it); both are paragraphs here.
  local items = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "DefinitionList" then
      for _, item in ipairs(b.content) do
        items[#items + 1] = { "para", item[1] }
        for _, d in ipairs(item[2]) do
          for _, db in ipairs(d) do
            if db.t ~= "Para" and db.t ~= "Plain" then error("wvnd-complaint.lua: unsupported block " .. db.t) end
            local c = pandoc.Inlines({ pandoc.Str("~"), pandoc.Space() })
            c:extend(db.content)
            items[#items + 1] = { "para", c }
          end
        end
      end
    elseif b.t == "Header" then
      items[#items + 1] = { "head", b.content, b.level }
    elseif b.t == "Para" or b.t == "Plain" then
      items[#items + 1] = { "para", b.content }
    elseif b.t == "OrderedList" then
      items[#items + 1] = { "list", b }
    else
      error("wvnd-complaint.lua: unsupported block " .. b.t)
    end
  end

  local n = 0
  for k, it in ipairs(items) do
    local last = k == #items
    if it[1] == "head" then
      -- headings as typed (no style capitals): levels 1 and 2 centered bold, level 3 bold italic at the margin
      out[#out + 1] = xe.para({ xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
        xe.jc(it[3] <= 2 and "center" or "left"), '<w:outlineLvl w:val="' .. (math.min(it[3], 3) - 1) .. '"/>' },
        xe.inl(it[2], { b = true, i = it[3] > 2 }))
    elseif it[1] == "list" then
      -- prayer and other lettered lists: (a), (b), ...; the label half an inch in, the text hanging an inch in
      for j, item in ipairs(it[2].content) do
        local inl = pandoc.Inlines({})
        for m, b in ipairs(item) do
          if m > 1 then inl:insert(pandoc.Space()) end
          inl:extend(b.content)
        end
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + j) .. ")\t") .. xe.inl(inl),
          { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT, keep = last })
      end
    else
      local rest = unmarked(it[2])
      if rest then
        out[#out + 1] = p(xe.inl(rest), { line = BODY, first = INDENT, keep = last })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(it[2]),
          { line = BODY, first = INDENT, tab = 2 * INDENT, keep = last })
      end
    end
  end

  signature(meta.signature, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- pandoc would print the metadata title and date above the body; the caption, title and date are written above
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
