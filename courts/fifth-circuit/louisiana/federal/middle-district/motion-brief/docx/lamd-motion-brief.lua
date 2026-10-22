-- lamd memorandum in support of a motion, docx engine. Mirrors typst/lamd-motion-brief.typ; rules and conventions are
-- in ../README.md. The cover (court name, caption table, title), the body (unnumbered: a memorandum is not a pleading)
-- and the signature block (LR 11(a)(3)) are built here. "<!-- signature -->" marks where the signature block goes
-- (after the conclusion, before the certificate of service); the paragraph before it stays on the page with the
-- signature. A block quotation (">") is single spaced and indented 1 in on both sides; a "/s/" paragraph is set in
-- the signature column. Font, spacing, margins and the page number are styles and section settings in
-- docx/reference.xml (fb render builds the reference document from it). Content-agnostic: every case-specific word
-- comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local BLANK = 480                        -- typst blank: one blank double-spaced line
local TEXTW = 9360                       -- typst text-width, 6.5 in
local INDENT = 720                       -- typst para-indent 0.5 in (and a level 3 heading's indent)
local QUOTE = 1440                       -- typst quote-indent 1 in
local PARTY_W, CAP_PAD = 3888, 432       -- typst caption-party-w 2.7 in, caption-pad 0.3 in
local SIG_IND = 3600                     -- typst signature-indent 2.5 in

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

-- The items of a metadata list, as plain strings (typst sets them as typed).
local function strings(v)
  local out = {}
  if v == nil then return out end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    for _, x in ipairs(v) do out[#out + 1] = txt(x) end
  else
    out[1] = txt(v)
  end
  return out
end

-- Inlines as runs, a hard line break kept as a line break (typst: linebreak()).
local function runs(inl, o)
  local out, seg = {}, pandoc.Inlines({})
  for _, el in ipairs(inl) do
    if el.t == "LineBreak" then
      out[#out + 1] = xe.inl(seg, o) .. xe.BR
      seg = pandoc.Inlines({})
    else
      seg:insert(el)
    end
  end
  out[#out + 1] = xe.inl(seg, o)
  return table.concat(out)
end

-- A paragraph: o = { style, keep, before, after, line, left, right, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single-spaced lines (typst line-stack): an empty item is a blank single line, the next line a line lower.
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for k, l in ipairs(lines) do
    if l == "" then
      gap = gap + SINGLE
    else
      local last = true
      for j = k + 1, #lines do if lines[j] ~= "" then last = false end end
      out[#out + 1] = p(xe.runs(l), { before = gap, after = last and o.after or 0, left = o.left,
        keep = o.keep and not last })
      gap = 0
    end
  end
  return out
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption, title (LR 10(a)(2))
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { line = BODY, jc = "center" }),
    p(xe.runs("MIDDLE DISTRICT OF LOUISIANA", { b = true }), { line = BODY, jc = "center" }),
    p("", { line = BLANK }),      -- typst caption: above blank
  }
  local number = txt(m.civil_action_no)
  for _, j in ipairs(strings(m.judges)) do number = number .. "-" .. j end
  local right = { "CIVIL ACTION NO. " .. number }
  if txt(m.judge) ~= "" then right[#right + 1] = ""; right[#right + 1] = txt(m.judge) end
  if txt(m.magistrate) ~= "" then right[#right + 1] = ""; right[#right + 1] = txt(m.magistrate) end
  local left = stack(strings(m.caption))
  if #left == 0 then left = { p("") } end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. PARTY_W .. '"/><w:gridCol w:w="' .. (TEXTW - PARTY_W) .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(PARTY_W, table.concat(left))
    .. cell(TEXTW - PARTY_W, table.concat(stack(right)), '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. '</w:tr></w:tbl>'
  out[#out + 1] = p(xe.runs(txt(m.title), { b = true }), { before = BLANK, line = BODY, jc = "center" })
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) and t:sub(1, 3) ~= "/s/" then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function is_marker(b)
  return b.t == "RawBlock" and b.text:match("^<!%-%-%s*signature%s*%-%->%s*$")
end

-- The body blocks as raw paragraphs (typst paragraphs()). first_above: the space above the first block; keep_last:
-- the last block is kept whole and with the signature block.
local function convert(blocks, first_above, keep_last)
  local out = {}
  for i, b in ipairs(blocks) do
    local keep = keep_last and i == #blocks
    local above = i == 1 and first_above or 0
    if b.t == "Header" then
      -- kept with the next block; level 1 centred capitals, level 2 at the margin, level 3 half an inch in; bold on
      -- the body pitch, no space of their own
      local c = b.content
      if b.level == 1 then c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end }) end
      local level = math.min(b.level, 3)
      out[#out + 1] = p(runs(c, { b = true }), { style = "Heading" .. level, keep = true, before = above, line = BODY,
        left = level >= 3 and INDENT or 0, jc = level == 1 and "center" or "left" })
    elseif b.t == "BlockQuote" then
      -- single spaced, 1 in in on both sides, a blank double-spaced line below
      for j, c in ipairs(b.content) do
        out[#out + 1] = p(runs(c.content), { style = "BlockText", keep = keep, before = j == 1 and above or 0,
          after = j == #b.content and BLANK or 0, left = QUOTE, right = QUOTE })
      end
    elseif (b.t == "Para" or b.t == "Plain") and pandoc.utils.stringify(b):sub(1, 3) == "/s/" then
      -- an electronic signature line (LR 11(a)(2)) in the signature column, a blank line above and below
      out[#out + 1] = p(runs(b.content), { keep = keep, before = BLANK, after = BLANK, left = SIG_IND })
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(runs(b.content), { style = "BodyText", keep = keep, before = above, line = BODY,
        first = INDENT })
    elseif not is_marker(b) then
      error("lamd-motion-brief: unsupported block " .. b.t)
    end
  end
  return out
end

local function finish(doc)
  local m = doc.meta
  local x = cover(m)

  -- the body splits at the signature marker; the certificate follows the signature block
  local before, after, seen = {}, {}, false
  for _, b in ipairs(doc.blocks) do
    if is_marker(b) then seen = true
    elseif seen then after[#after + 1] = b
    else before[#before + 1] = b end
  end
  for _, s in ipairs(convert(before, BLANK, true)) do x[#x + 1] = s end
  -- signature block (LR 11(a)(3)): from mid-page, single spaced, kept together, a blank line above and below
  for _, s in ipairs(stack(strings(m.signature_lines), { above = BLANK, after = BLANK, left = SIG_IND, keep = true })) do
    x[#x + 1] = s
  end
  for _, s in ipairs(convert(after, 0, false)) do x[#x + 1] = s end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }
