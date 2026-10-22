-- ncwd memorandum of law, docx engine. Mirrors typst/ncwd-motion-brief.typ; rules and conventions are in
-- ../README.md. The court title, the caption (the parties at left, a ")" beside each row, the civil action number and
-- the title at right), the headings, the body paragraphs (unnumbered: a brief is not a pleading), the flush ">"
-- paragraphs, the lists, the signature block (Fed. R. Civ. P. 11(a)), the AI certification (June 18, 2024 Standing
-- Order, 3:24-mc-104) and the certificate of service are built here. Font, spacing, margins and the page number are
-- styles and section settings in docx/reference.xml (fb render builds the reference document from it).
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst gap 24 pt
local COURT_BELOW = 276                  -- typst court-below 13.8 pt
local CAPTION_GAP = 276                  -- typst caption-gap 13.8 pt
local HEADING_BELOW = 276                -- typst heading-below 13.8 pt
local TEXTW = 9360                       -- typst text-width, 6.5 in
local CAP_LEFT, CAP_MARK = 4176, 432     -- typst caption-left 2.9 in, caption-mark 0.3 in
local CAP_GUTTER, CAP_PAD = 144, 144     -- typst caption-gutter 0.1 in, caption-pad 0.1 in
local SIG_LEFT = 4320                    -- typst sig-left 3.0 in
local COURT = { "UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF NORTH CAROLINA" }

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

-- A single-spaced paragraph: o = { before, after, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, SINGLE)
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

local function append(out, list)
  for _, x in ipairs(list) do out[#out + 1] = x end
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
  local right = { p(xe.runs("Civil Action No. " .. txt(m.case_number)), { left = CAP_GUTTER + CAP_PAD }) }
  append(right, stack(items(m.title), { above = CAPTION_GAP, left = CAP_GUTTER + CAP_PAD, b = true }))
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
-- Signature block (Fed. R. Civ. P. 11(a)): the date line at the left, then each firm's block at the right half;
-- every line but the last kept with the next (typst with-signature: one unbreakable block with the block before).
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local out = stack({ s.date_line }, { above = GAP, keep = true })
  for k, b in ipairs(items(s.blocks)) do
    local lines = { b.firm }
    if txt(b.by) ~= "" then lines[#lines + 1] = "By: /s/ " .. txt(b.by) end
    append(lines, items(b.lines))
    append(out, stack(lines, { above = GAP, left = SIG_LEFT, keep = true }))
  end
  out[#out] = out[#out]:gsub(xe.KEEP, "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("CM/ECF"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
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

-- A paragraph at the body pitch in style `style` (Body Text: first line half an inch in). o = { keep, before, flush }.
local function para(style, runs, o)
  o = o or {}
  local props = { xe.style(style) }
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, BODY)
  if o.flush then props[#props + 1] = xe.ind(0, nil, 0) end
  return xe.para(props, runs)
end

-- Headings (typst heading-block): single-spaced, kept with the next block; level 1 centred bold capitals, level 2
-- bold at the left, level 3 bold italic at the left.
local function heading(level, inlines)
  level = math.min(level, 3)
  if level == 1 then inlines = inlines:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end }) end
  return xe.para({ xe.style("Heading" .. level), xe.KEEP, xe.spacing(GAP, HEADING_BELOW, SINGLE), xe.ind(0, nil, 0),
    xe.jc(level == 1 and "center" or "left") }, xe.inl(inlines, { b = true, i = level == 3 }))
end

-- One markdown block as raw paragraphs (typst chunk). keep: every paragraph kept with the next.
local function convert(b, keep)
  local out = {}
  if b.t == "Header" then
    out[1] = heading(b.level, b.content)
  elseif b.t == "Para" or b.t == "Plain" then
    out[1] = para("BodyText", xe.inl(b.content), { keep = keep })
  elseif b.t == "BlockQuote" then
    for _, c in ipairs(b.content) do out[#out + 1] = para("BodyText", xe.inl(c.content), { keep = keep, flush = true }) end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    local n = b.t == "OrderedList" and b.listAttributes.start or 1
    for _, item in ipairs(b.content) do
      local label = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
      out[#out + 1] = para("BriefList", xe.runs(label .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
        { keep = keep })
      n = n + 1
    end
  else
    error("motion-brief.lua: unsupported block " .. b.t)
  end
  return out
end

-- The AI certification the June 18, 2024 Standing Order requires (wording as in ncwd-motion-brief.typ).
local function ai_certification(m)
  local out = { heading(1, pandoc.Inlines({ pandoc.Str("Certification Regarding Use of Artificial Intelligence") })) }
  local intro = pandoc.Inlines({ pandoc.Str("Pursuant to the June 18, 2024 Standing Order of this Court ") })
  intro:insert(pandoc.Emph({ pandoc.Str("In Re: Use of Artificial Intelligence") }))
  intro:insert(pandoc.Str(", 3:24-mc-104, counsel, by signing above, submits the following certification regarding "))
  intro:extend(pandoc.utils.blocks_to_inlines({ pandoc.Plain(m.ai_title) }))
  intro:insert(pandoc.Str("."))
  out[#out + 1] = para("BodyText", xe.inl(intro))
  out[#out + 1] = para("BodyText", xe.runs("1. No artificial intelligence was employed in doing the research for the preparation of this Memorandum, with the exception of such artificial intelligence embedded in the standard on-line legal research sources Westlaw, Lexis, FastCase, and Bloomberg, as well as Google and Google Scholar;"))
  out[#out + 1] = para("BodyText", xe.runs("2. Every statement and every citation to an authority contained in this Memorandum has been checked by the undersigned as to the accuracy of the proposition for which it is offered, and the citation to authority provided."), { keep = true })
  return append(out, signature(m))
end

-- The certificate of service: the filing, the counsel served (each block whole), the date and the signature.
local function certificate_of_service(m)
  local out = { heading(1, pandoc.Inlines({ pandoc.Str("Certificate of Service") })) }
  local intro = pandoc.Inlines({ pandoc.Str("This is to certify that the undersigned has this day electronically filed the foregoing ") })
  intro:extend(pandoc.utils.blocks_to_inlines({ pandoc.Plain(m.service_title) }))
  intro:insert(pandoc.Str(" with the Clerk of the Court using the CM/ECF system which will send notification of such filing to the following counsel of record:"))
  out[#out + 1] = para("BodyText", xe.inl(intro:walk({ Str = break_rules })))
  local counsel = items(m.service.counsel)
  for k, c in ipairs(counsel) do
    local lines = stack(items(c), { above = GAP, keep = true })
    -- a block other than the last keeps its own lines together only (typst: an unbreakable block)
    if k < #counsel then lines[#lines] = lines[#lines]:gsub(xe.KEEP, xe.LINES, 1) end
    append(out, lines)
  end
  return append(out, signature(m))
end

local function finish(doc)
  local m = doc.meta
  local x = cover(m)
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local ps = convert(b, i == #blocks)
    -- the first block takes the gap below the caption (typst: v(gap, weak: true))
    if i == 1 then ps[1] = ps[1]:gsub('<w:spacing w:before="%d+"', '<w:spacing w:before="' .. GAP .. '"', 1) end
    append(x, ps)
  end
  append(x, signature(m))
  if m.ai_certification == true then append(x, ai_certification(m)) end
  if m.service ~= nil then append(x, certificate_of_service(m)) end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
