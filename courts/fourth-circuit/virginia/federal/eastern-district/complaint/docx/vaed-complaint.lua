-- vaed complaint, docx engine (docs/DOCX.md). Mirrors typst/vaed-complaint.typ; rules are in ../README.md. Court
-- title, party-box caption (a table) with the case number beside its first line, the title, the unnumbered lead-in, numbered
-- allegations (Fed. R. Civ. P. 10(b)), unnumbered (">") paragraphs, lettered prayer items, the signature block kept
-- together (L.R. 7(B)). Font, size, margins and the page number are styles and section settings in
-- docx/reference.xml (fb render builds the reference document from it). Nothing case-specific here.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276             -- typst pitch-body 24 pt, pitch-single 13.8 pt
local TEXTW = 9360                        -- typst text-width, 6.5 in
local INDENT = 720                        -- typst para-indent 0.5 in
local NUMBER = 720                        -- typst number-box 0.5 in
local CAP_W, CAP_GUTTER = 4752, 360       -- typst caption-w 3.3 in, caption-gutter 0.25 in
local CAP_INSET = 216                     -- typst caption-inset 0.15 in (left and right) ...
local CAP_INSET_Y = 201                   -- ... above and below less the rule (0.75 pt, inside the cell in Word, centred on
                                          -- the edge in typst): the box as tall in both engines
local DESIG = 2016                        -- typst designation-indent 1.4 in
local SIG_LEFT = 4680                     -- typst sig-left 3.25 in
local SMALL = 120                         -- typst small-gap 6 pt
local COURT_BELOW, CAPTION_BELOW = 480, 480 -- typst court-below, caption-below 24 pt
local TITLE_BELOW = 240                   -- typst title-below 12 pt
local SIG_ABOVE = 480                     -- typst sig-above 24 pt

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph: o = { line, before, after, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A single-spaced line of plain text (typst line()).
local function line(t, o)
  return p(xe.runs(txt(t)), o)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function caption(c)
  local left, above = {}, 0
  local parties = items(c.parties)
  for i, pt in ipairs(parties) do
    for _, l in ipairs(items(pt.lines)) do
      left[#left + 1] = line(l, { before = above })
      above = 0
    end
    if pt.designation ~= nil then left[#left + 1] = line(pt.designation, { left = DESIG }) end
    if i < #parties then
      left[#left + 1] = line("v.", { before = SMALL })
      above = SMALL
    end
  end
  local borders = {}
  for _, side in ipairs({ "top", "left", "bottom", "right" }) do borders[#borders + 1] = string.format(RULE, side) end
  local right = TEXTW - CAP_W - CAP_GUTTER
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_W .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/>'
    .. '<w:gridCol w:w="' .. right .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_W .. '" w:type="dxa"/><w:tcBorders>' .. table.concat(borders) .. '</w:tcBorders>'
    .. '<w:tcMar><w:top w:w="' .. CAP_INSET_Y .. '" w:type="dxa"/><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. CAP_INSET_Y .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcPr>' .. p("") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. right .. '" w:type="dxa"/><w:tcMar><w:top w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. line(c.case_number) .. '</w:tc></w:tr></w:tbl>'
end

local function cover(m)
  local out = {}
  local court = items(m.court)
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(txt(l), { b = true }), { jc = "center", keep = true, after = i == #court and COURT_BELOW or 0 })
  end
  out[#out + 1] = caption(m.caption)
  out[#out + 1] = p(xe.runs(txt(m.brief_title), { b = true }),
    { line = BODY, jc = "center", keep = true, before = CAPTION_BELOW, after = TITLE_BELOW })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("4(k)(2)(B)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- "I. Title" -> label and the rest (the label hangs half an inch, as in the typst template), or nil.
local function label_of(inls)
  local first, second = inls[1], inls[2]
  if first and first.t == "Str" and second and second.t == "Space"
    and (first.text:match("^[IVX]+%.$") or first.text:match("^[A-Z]%.$") or first.text:match("^%d+%.$")) then
    local rest = pandoc.Inlines({})
    for k = 3, #inls do rest:insert(inls[k]) end
    return first.text, rest
  end
end

local function convert(blocks)
  local out, n = {}, 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      out[#out + 1] = p(xe.inl(upper(b.content), { b = true }), { line = BODY, jc = "center", keep = true })
    elseif b.t == "Header" then
      local label, rest = label_of(b.content)
      local body = label and (xe.runs(label .. "\t", { b = true }) .. xe.inl(rest, { b = true })) or xe.inl(b.content, { b = true })
      out[#out + 1] = p(body, { line = BODY, keep = true, left = INDENT, hanging = INDENT, tab = INDENT })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- lettered prayer items: the letter half an inch in, the text hanging 1 in from the margin
      for k, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs(string.char(64 + k) .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { line = BODY, left = INDENT + NUMBER, hanging = NUMBER, tab = INDENT + NUMBER })
      end
    elseif b.t == "BlockQuote" then
      -- an unnumbered body paragraph
      for _, c in ipairs(b.content) do out[#out + 1] = p(xe.inl(c.content), { line = BODY, first = INDENT }) end
    elseif b.t == "Para" or b.t == "Plain" then
      -- a numbered allegation: the number at the indent, a tab to 1 in, the text; wrapped lines at the margin
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
        { line = BODY, first = INDENT, tab = INDENT + NUMBER })
    else
      error("vaed-complaint.lua: unexpected block " .. b.t)
    end
  end
  return table.concat(out)
end

-- The signature block: the date line at the margin, the rest in the signature column; kept together.
local function signature(sig)
  local lines = {}
  if sig.date ~= nil then lines[#lines + 1] = { "Dated: " .. txt(sig.date), 0, 0 } end
  local above = sig.date ~= nil and SMALL or 0
  for _, k in ipairs({ "closing", "party", "by" }) do
    if sig[k] ~= nil then
      lines[#lines + 1] = { txt(sig[k]), SIG_LEFT, above }
      above = SMALL
    end
  end
  for _, l in ipairs(items(sig.lines)) do
    lines[#lines + 1] = { txt(l), SIG_LEFT, above }
    above = 0
  end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = line(l[1], { left = l[2], before = i == 1 and SIG_ABOVE or l[3], keep = i < #lines })
  end
  return table.concat(out)
end

local function finish(doc)
  local m = doc.meta
  local x = cover(m)
  if m.lead_in ~= nil then x = x .. p(xe.inl(m.lead_in), { line = BODY, first = INDENT }) end
  x = x .. convert(doc.blocks)
  if m.signature ~= nil then x = x .. signature(m.signature) end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(x) }, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }
