-- Pandoc filter for the ilcd complaint, engine docx, so that it reads and breaks as typst/ilcd-complaint.typ does:
-- court title with the division (CDIL LR 40.1(E)(1)), the caption (party lines with a ")" mark on every row, the case
-- number and the jury legend at the right), the title (LR 38.1), the unnumbered lead-in, numbered paragraphs
-- (Fed. R. Civ. P. 10(b)), headings, unnumbered "~ " paragraphs, lettered prayer items, and the signature blocks
-- (LR 5.11(A)(2), LR 11.1) kept together with the last paragraph. Every case word comes from the sample's
-- frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                -- typst pitch-body, pitch-single
local GAP = 480                              -- typst gap, one blank double-spaced line (24 pt)
local INDENT = 720                           -- typst para-indent, item-indent and item-label, 0.5 in
local DESIGNATION = 1800                     -- typst designation-indent, 1.25 in
local CASE_INDENT = 216                      -- typst case-indent, 0.15 in
local SIG = 4680                             -- typst sig-left, 3.25 in
local LEFT, PAREN, TEXTW = 4608, 432, 9360   -- typst caption-left 3.2 in, paren-col 0.3 in; 6.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Inlines in capitals (a level 1 heading, the title), as typst's upper().
local function upper(inl)
  return pandoc.Inlines(inl):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  local title = { "UNITED STATES DISTRICT COURT", "CENTRAL DISTRICT OF ILLINOIS",
    -- LR 40.1(E)(1): the caption identifies the division in which the case is pending
    pandoc.text.upper(plain(meta.division)) }
  for _, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true })
  end
  -- the caption: one row per line, a ")" on every row, a blank row between the entries; the case number on the row
  -- of the first designation, the jury legend on the row of the last one
  local rows = {}
  local parties = meta.caption.parties
  for k, side in ipairs(parties) do
    if k > 1 then
      rows[#rows + 1] = { xe.runs("v."), DESIGNATION }
      rows[#rows + 1] = { "", 0 }
    end
    for _, n in ipairs(side.names) do rows[#rows + 1] = { xe.inl(n), 0 } end
    rows[#rows + 1] = { "", 0 }
    rows[#rows + 1] = { xe.inl(side.designation), DESIGNATION, true }
    if k < #parties then rows[#rows + 1] = { "", 0 } end
  end
  local desig = {}
  for i, r in ipairs(rows) do if r[3] then desig[#desig + 1] = i end end
  local case_row = desig[1]
  local jury_row = desig[#desig] ~= case_row and desig[#desig] or case_row + 2
  if meta.jury_demand then
    while jury_row > #rows do rows[#rows + 1] = { "", 0 } end
  end
  local function cell(w, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
  end
  local trs = {}
  for i, r in ipairs(rows) do
    local right = ""
    if i == case_row then right = xe.runs("Case No. " .. plain(meta.case_number))
    elseif meta.jury_demand and i == jury_row then right = xe.runs("Jury Trial Demanded") end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      cell(LEFT, p(r[1], { left = r[2], keep = i < #rows })) ..
      cell(PAREN, p(xe.runs(")"), { jc = "right", keep = i < #rows })) ..
      cell(TEXTW - LEFT - PAREN, p(right, { left = CASE_INDENT, keep = i < #rows })) .. '</w:tr>'
  end
  -- the space above the caption: an empty single line of the gap's height before the table (a table has none)
  out[#out + 1] = p("", { line = GAP, keep = true })
  out[#out + 1] = "<w:tbl>" .. '<w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. PAREN .. '"/><w:gridCol w:w="' ..
    (TEXTW - LEFT - PAREN) .. '"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
  -- the title (Fed. R. Civ. P. 10(a); LR 38.1) and, when the prayer seeks it, the equitable relief marking
  local relief = meta.equitable_relief
  out[#out + 1] = p(xe.inl(upper(meta.brief_title), { b = true }),
    { before = GAP, after = relief and 0 or GAP, jc = "center", keep = true })
  if relief then
    out[#out + 1] = p(xe.runs("EQUITABLE RELIEF IS SOUGHT", { b = true }), { after = GAP, jc = "center", keep = true })
  end
end

-- ---------------------------------------------------------------------------
-- Signature (LR 5.11(A)(2), LR 11.1)
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local lines = {
    { xe.inl("Dated: " .. plain(meta.date)), GAP, 0 },
    { xe.runs("Respectfully submitted,"), GAP, SIG },
  }
  for _, s in ipairs(meta.signature or {}) do
    lines[#lines + 1] = { xe.inl("/s/ " .. plain(s.signer)), GAP, SIG }
    for _, l in ipairs(s.lines or {}) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines })
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
  if not meta.division then error("ilcd-complaint: LR 40.1(E)(1) requires the division in the caption (frontmatter: division)", 0) end
  if meta.jury_demand and not plain(meta.brief_title):lower():find("and demand for jury trial", 1, true) then
    error("ilcd-complaint: LR 38.1: a jury demand needs 'and demand for jury trial' in the title", 0)
  end

  local out = {}
  cover(meta, out)
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
            if db.t ~= "Para" and db.t ~= "Plain" then error("ilcd-complaint.lua: unsupported block " .. db.t) end
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
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items[#items + 1] = { "list", b }
    else
      error("ilcd-complaint.lua: unsupported block " .. b.t)
    end
  end

  local n = 0
  for k, it in ipairs(items) do
    local last = k == #items
    if it[1] == "head" then
      -- level 1 centered bold capitals; levels 2 and 3 centered bold (count headings and their subtitles)
      local t = it[3] == 1 and upper(it[2]) or it[2]
      out[#out + 1] = xe.para({ xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center"),
        '<w:outlineLvl w:val="' .. (math.min(it[3], 3) - 1) .. '"/>' }, xe.inl(t, { b = true }))
    elseif it[1] == "list" then
      -- prayer items: (a), (b), ...; the label half an inch in, the text hanging an inch in
      for j, item in ipairs(it[2].content) do
        if j > 26 then error("ilcd-complaint: more than 26 lettered items in one list", 0) end
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

  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- pandoc would print the metadata title and date above the body; the cover and date are written above
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
