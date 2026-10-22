-- Pandoc filter for the ilsd complaint, engine docx, so that it reads and breaks as typst/ilsd-complaint.typ does:
-- court name, caption (one table row per party line, a column of ")" marks, the case number on the "v." row and the
-- jury demand a blank line below it), the title, the unnumbered lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)),
-- unnumbered "~" paragraphs, headings, prayer items with their typed labels, the signature block kept together with
-- the last paragraph (Fed. R. Civ. P. 11(a)). Every case word comes from the sample's frontmatter and body, never
-- from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs and their
-- footnotes are written by pandoc in the styles of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local GAP = 276                          -- typst gap: a blank single line
local H1_ABOVE, H1_BELOW, H2_GAP = 360, 120, 240   -- typst h1-above 18 pt, h1-below 6 pt, h2-gap 12 pt
local TITLE_BELOW, ITEM_GAP = 240, 144   -- typst title-below 12 pt, item-gap 7.2 pt
local INDENT = 720                       -- typst para-indent, item-indent and item-label, 0.5 in
local DESIGNATION = 2016                 -- typst designation-indent, 1.4 in
local SIG = 4680                         -- typst sig-indent, 3.25 in
local LEFT, MARKS, RIGHT = 5040, 576, 360   -- typst caption-left 3.5 in, caption-marks 0.4 in, caption-right 0.25 in
local TEXTW = 9360                       -- 6.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  if m == nil then return {} end
  return m
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

-- ---------------------------------------------------------------------------
-- Caption (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

-- The lines a caption line takes in its column (typst measures it): its width estimated from Times New Roman's
-- advances at 12 pt (capitals and wide letters 0.72 em, small letters 0.47 em, spaces 0.25 em, the rest 0.4 em).
local function caption_rows(text, indent)
  local w = indent / 20
  for _, c in utf8.codes(text) do
    local ch = utf8.char(c)
    if ch == " " then w = w + 3
    elseif ch:match("^[A-Z]$") or ch == "m" or ch == "w" then w = w + 8.64
    elseif ch:match("^[a-z]$") then w = w + 5.64
    else w = w + 4.8 end
  end
  return math.max(1, math.ceil(w / (LEFT / 20)))
end

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function caption(meta, out)
  out[#out + 1] = p(xe.runs("UNITED STATES DISTRICT COURT"), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE SOUTHERN DISTRICT OF ILLINOIS"), { jc = "center", after = BODY })
  -- the party lines: { inlines, plain text, left indent, centered, is "v." }; nil inlines is a blank line
  local left = {}
  local sides = list(meta.caption)
  for i, side in ipairs(sides) do
    for _, n in ipairs(list(side.names)) do left[#left + 1] = { xe.inl(n), plain(n), 0, false, false } end
    left[#left + 1] = { nil }
    left[#left + 1] = { xe.inl(side.designation), plain(side.designation), DESIGNATION, false, false }
    if i < #sides then
      left[#left + 1] = { nil }
      left[#left + 1] = { xe.runs("v."), "v.", 0, true, true }
      left[#left + 1] = { nil }
    end
  end
  local v
  for k, l in ipairs(left) do
    if l[5] and not v then v = k end
  end
  local right = TEXTW - LEFT - MARKS
  local rows = {}
  for k, l in ipairs(left) do
    local text, n = p(""), 1
    if l[1] then
      text = p(l[1], { left = l[3], jc = l[4] and "center" or "left" })
      n = caption_rows(l[2], l[3])
    end
    local marks = {}
    for _ = 1, n do marks[#marks + 1] = p(xe.runs(")"), { jc = "center" }) end
    local r = p("")
    if k == v then
      r = p(xe.runs("Case No. " .. plain(meta.case_number)), { left = RIGHT })
    elseif meta.jury_demand == true and v and k == v + 2 then
      r = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { left = RIGHT })
    end
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(LEFT, text) .. tc(MARKS, table.concat(marks)) ..
      tc(right, r) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. MARKS .. '"/><w:gridCol w:w="' .. right ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- Fed. R. Civ. P. 10(a): the title of the complaint names the paper; Word has no space after a table, so the title
  -- takes the space before it
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { before = BODY, after = TITLE_BELOW, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature (Fed. R. Civ. P. 11(a))
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = {
    { xe.runs("Dated: " .. plain(meta.date)), BODY, 0 },
    { xe.runs("Respectfully submitted,"), GAP, SIG },
    { xe.inl(sig.firm, { b = true }), GAP, SIG },
    { xe.runs("By: /s/ ") .. xe.inl(sig.signer), GAP, SIG },
  }
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  for i, l in ipairs(list(sig.other)) do lines[#lines + 1] = { xe.inl(l), i == 1 and GAP or 0, SIG } end
  if sig.role then lines[#lines + 1] = { xe.inl(sig.role, { i = true }), GAP, SIG } end
  -- kept on one page (typst's unbreakable block): every line but the last keeps with the next
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l[1], { before = l[2], left = l[3], keep = i < #lines }))
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

-- A prayer item's typed label ("1.", "(a)", "a)"), split from its text: label, rest; or nil.
local function label_of(inl)
  local first = inl[1]
  if first and first.t == "Str" and inl[2] and inl[2].t == "Space" and
    (first.text:match("^%d+%.$") or first.text:match("^%(?[%w]+%)$")) then
    local rest = pandoc.Inlines({})
    for k = 3, #inl do rest:insert(inl[k]) end
    return first.text, rest
  end
  return nil
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "title", "date", "signature" }) do
    assert(meta[k], "ilsd-complaint: frontmatter needs " .. k)
  end

  local raw = {}
  caption(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  if meta.lead_in then
    local li = pandoc.Inlines(meta.lead_in):walk({ Str = breaks }):walk({ Inlines = bind_doubled })
    out[#out + 1] = pandoc.Div({ pandoc.Para(xe.inlines(li)) }, { ["custom-style"] = "Body Text" })
  end

  -- The body as a list of items: { kind, inlines | block, level }. pandoc reads a "~ " paragraph after another
  -- paragraph as the definition of a term (the paragraph before it); both are paragraphs here.
  local items = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "DefinitionList" then
      for _, item in ipairs(b.content) do
        items[#items + 1] = { "para", item[1] }
        for _, d in ipairs(item[2]) do
          for _, db in ipairs(d) do
            if db.t ~= "Para" and db.t ~= "Plain" then error("ilsd-complaint.lua: unsupported block " .. db.t) end
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
    elseif b.t == "BulletList" then
      items[#items + 1] = { "list", b }
    else
      error("ilsd-complaint.lua: unsupported block " .. b.t)
    end
  end

  local n = 0
  for k, it in ipairs(items) do
    local last = k == #items
    if it[1] == "head" then
      -- single-spaced, bold, centered: level 1 18 pt above and 6 pt below, deeper levels 12 pt above and below
      local before, after = H2_GAP, H2_GAP
      if it[3] == 1 then before, after = H1_ABOVE, H1_BELOW end
      out[#out + 1] = xe.raw(xe.para({ xe.KEEP, xe.spacing(before, after, SINGLE), xe.ind(0, nil, 0), xe.jc("center"),
        '<w:outlineLvl w:val="' .. (math.min(it[3], 3) - 1) .. '"/>' }, xe.inl(it[2], { b = true })))
    elseif it[1] == "list" then
      -- prayer items: the typed label in a half-inch box half an inch in, the text hanging an inch in
      local its = it[2].content
      for j, item in ipairs(its) do
        local inl = pandoc.Inlines({})
        for m, b in ipairs(item) do
          if m > 1 then inl:insert(pandoc.Space()) end
          inl:extend(b.content)
        end
        local lab, rest = label_of(inl)
        local body = lab and (xe.runs(lab .. "\t") .. xe.inl(rest)) or (xe.runs("\t") .. xe.inl(inl))
        out[#out + 1] = xe.raw(p(body, { before = ITEM_GAP, line = BODY, left = 2 * INDENT, hanging = INDENT,
          tab = 2 * INDENT, keep = last and j == #its }))
      end
    else
      local rest = unmarked(it[2])
      local style
      local inl
      if rest then
        style, inl = "Body Text", rest
      else
        n = n + 1
        style = "Body Numbered"
        inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inl:extend(it[2])
      end
      if last then style = style == "Body Text" and "Body Keep" or "Body Numbered Keep" end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
    end
  end

  signature(meta, out)
  -- pandoc would print the metadata title and date above the body; the caption, title and date are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
