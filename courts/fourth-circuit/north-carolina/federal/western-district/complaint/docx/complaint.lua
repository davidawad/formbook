-- ncwd complaint, docx engine. Mirrors typst/ncwd-complaint.typ; rules and conventions are in ../README.md. The court
-- title, the caption (the parties at left, a ")" beside each row, the civil action number, the title and the jury
-- demand at right), the lead-in, the headings, the numbered allegations (Fed. R. Civ. P. 10(b)), the unnumbered ">"
-- paragraphs, the lettered prayer and the signature block (Fed. R. Civ. P. 11(a)) are built here. Font, spacing,
-- margins and the page number are styles and section settings in docx/reference.xml (fb render builds the reference
-- document from it). Numbers and letters are typed text, as the typst template types them. Content-agnostic: every
-- case-specific word comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst gap 24 pt
local COURT_BELOW = 276                  -- typst court-below 13.8 pt
local CAPTION_GAP = 276                 -- typst caption-gap 13.8 pt
local HEADING_BELOW = 276                -- typst heading-below 13.8 pt
local TEXTW = 9360                       -- typst text-width, 6.5 in
local CAP_LEFT, CAP_MARK = 4320, 432     -- typst caption-left 3.0 in, caption-mark 0.3 in
local CAP_GUTTER, CAP_PAD = 144, 144     -- typst caption-gutter 0.1 in, caption-pad 0.1 in
local SIG_LEFT = 3960                    -- typst sig-left 2.75 in
local COURT = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF NORTH CAROLINA" }

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A single-spaced paragraph: o = { before, left, jc, keep, b }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single-spaced lines (typst line-stack): an item is a metadata value or a string; an empty one a blank line.
-- o = { above, left, keep, b, jc }: keep keeps every line with the next.
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for _, l in ipairs(lines) do
    if txt(l) == "" then
      gap = gap + SINGLE
    else
      local r = type(l) == "string" and xe.runs(l, { b = o.b }) or xe.inl(l, { b = o.b })
      out[#out + 1] = p(r, { before = gap, left = o.left, keep = o.keep, jc = o.jc })
      gap = 0
    end
  end
  return out
end

local function cell(width, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. inner .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Court title and caption (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(m)
  local court = { table.unpack(COURT) }
  if txt(m.division) ~= "" then court[#court + 1] = txt(m.division):upper() end
  local out = stack(court, { b = true, jc = "center", keep = true })
  -- the gap to the caption (typst court-below): the last line's space after
  out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. COURT_BELOW .. '"', 1)

  local rows = {}
  for k, party in ipairs(items(m.caption.parties)) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, l in ipairs(items(party.lines)) do rows[#rows + 1] = l end
    rows[#rows + 1] = party.designation
  end
  local marks = {}
  for k = 1, #rows do marks[k] = ")" end
  local number = txt(m.case_number) ~= "" and ("Civil Action No. " .. txt(m.case_number)) or "Civil Action No.:"
  local right = { p(xe.runs(number), { left = CAP_GUTTER + CAP_PAD }) }
  local title = stack(items(m.title), { above = CAPTION_GAP, left = CAP_GUTTER + CAP_PAD, b = true })
  for _, x in ipairs(title) do right[#right + 1] = x end
  if m.jury_demand then
    right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = CAPTION_GAP, left = CAP_GUTTER + CAP_PAD })
  end
  local w2 = CAP_GUTTER + CAP_MARK
  local w3 = TEXTW - CAP_LEFT - w2
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. w2 .. '"/><w:gridCol w:w="'
    .. w3 .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_LEFT, table.concat(stack(rows)))
    .. cell(w2, table.concat(stack(marks, { left = CAP_GUTTER })))
    .. cell(w3, table.concat(right))
    .. '</w:tr></w:tbl>'
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (Fed. R. Civ. P. 11(a)): the date at the margin, then "Respectfully submitted," and each firm's
-- block at the right half; every line kept with the next (typst: one unbreakable block with the last paragraph).
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local out = stack({ "Dated: " .. txt(s.date) }, { above = GAP, keep = true })
  local function add(lines)
    for _, x in ipairs(stack(lines, { above = GAP, left = SIG_LEFT, keep = true })) do out[#out + 1] = x end
  end
  add({ "Respectfully submitted," })
  for _, b in ipairs(items(s.blocks)) do
    local lines = { b.firm }
    if txt(b.by) ~= "" then lines[#lines + 1] = "By: /s/ " .. txt(b.by) end
    for _, l in ipairs(items(b.lines)) do lines[#lines + 1] = l end
    add(lines)
  end
  -- the last line keeps with nothing
  out[#out] = out[#out]:gsub(xe.KEEP, "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("216(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or", "d/b/a", a URL), where LibreOffice keeps the word whole: a zero-width space (U+200B)
-- after it. Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A Str of two or more section signs or pilcrows ("§§", "¶¶"; each two bytes): typst boxes it with its number,
-- lib/pandoc/xengine.lua binds a single sign only.
local function doubled_sign(t)
  local _, s = t:gsub("\u{00A7}", "")
  local _, q = t:gsub("\u{00B6}", "")
  return s + q >= 2 and #t == 2 * (s + q)
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there), nor after a doubled sign ("¶¶ 8–9"): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    if l[i].t == "Space" and l[i - 1].t == "Str" and doubled_sign(l[i - 1].text) then
      l[i] = pandoc.Str("\u{00A0}")
    end
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

-- A body paragraph at the body pitch (style props first); keep: with the next paragraph, its lines together.
local function para(style, keep, before, runs)
  local props = { xe.style(style) }
  if keep then props[#props + 1] = xe.KEEP end
  if before then props[#props + 1] = xe.spacing(before, 0, BODY) end
  return xe.para(props, runs)
end

-- Headings (typst heading-block): single-spaced, centred, kept with the next block; level 1 bold capitals, level 2
-- bold, level 3 plain (Heading 3 in docx/reference.xml).
local function heading(b)
  local level = math.min(b.level, 3)
  local c = b.content
  if level == 1 then c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end }) end
  return xe.para({ xe.style("Heading" .. level), xe.KEEP, xe.spacing(GAP, HEADING_BELOW, SINGLE), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(c, { b = level <= 2 }))
end

-- The body blocks as raw paragraphs; paragraph numbers continue from n, prayer letters from k. keep: every paragraph
-- kept with the next (the last block stays with the signature block).
local function convert(blocks, n, k, keep)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = para("NumberedParagraph", keep, nil, xe.runs(n .. ".\t") .. xe.inl(b.content))
    elseif b.t == "BlockQuote" then
      for _, c in ipairs(b.content) do out[#out + 1] = para("BodyText", keep, nil, xe.inl(c.content)) end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        k = k + 1
        out[#out + 1] = para("ListLetter", keep, nil,
          xe.runs(string.char(64 + k) .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)))
      end
    else
      error("complaint.lua: unsupported block " .. b.t)
    end
  end
  return out, n, k
end

local function finish(doc)
  local m = doc.meta
  local x = cover(m)
  local first = #x + 1
  if m.lead_in then x[#x + 1] = para("BodyText", false, GAP, xe.inl(m.lead_in)) end

  -- The last paragraph (or, when the body ends in a list, its last item) is kept with the signature block.
  local blocks = doc.blocks
  local head = {}
  for i = 1, #blocks - 1 do head[#head + 1] = blocks[i] end
  local tail = blocks[#blocks]
  if (tail.t == "BulletList" or tail.t == "OrderedList") and #tail.content > 1 then
    local its = tail.content
    local rest = pandoc.List({})
    for i = 1, #its - 1 do rest:insert(its[i]) end
    head[#head + 1] = pandoc.BulletList(rest)
    tail = pandoc.BulletList({ its[#its] })
  end
  local main, n, k = convert(head, 0, 0, false)
  local last = convert({ tail }, n, k, true)
  for _, s in ipairs(main) do x[#x + 1] = s end
  for _, s in ipairs(last) do x[#x + 1] = s end
  -- No lead-in: the first block takes the gap below the caption.
  if not m.lead_in then
    x[first] = x[first]:gsub('<w:spacing w:before="%d+"', '<w:spacing w:before="' .. GAP .. '"', 1)
    if not x[first]:find("<w:spacing", 1, true) then
      x[first] = x[first]:gsub("</w:pStyle>", "", 1):gsub('(<w:pStyle w:val="[^"]+"/>)', "%1" .. xe.spacing(GAP, 0, BODY), 1)
    end
  end
  for _, s in ipairs(signature(m)) do x[#x + 1] = s end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
