-- lamd complaint, docx engine. Mirrors typst/lamd-complaint.typ; rules and conventions are in ../README.md. The cover
-- (court name, caption table, title, subtitle), the lead-in, the numbered allegations (Fed. R. Civ. P. 10(b)), the
-- lists and the signature block (LR 11(a)(3)) are built here; a ">" paragraph is unnumbered. Font, spacing, margins
-- and the page number are styles and section settings in docx/reference.xml (fb render builds the reference document
-- from it). Numbers are typed text, as the typst template types them. Content-agnostic: every case-specific word
-- comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local BLANK = 480                        -- typst blank: one blank double-spaced line
local TEXTW = 9360                       -- typst text-width, 6.5 in
local PARTY_W, CAP_PAD = 3888, 432       -- typst caption-party-w 2.7 in, caption-pad 0.3 in
local SIG_IND = 4320                     -- typst sig-indent 3 in

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

-- A paragraph: o = { before, line, left, first, jc, keep, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
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
      out[#out + 1] = p(xe.runs(l), { before = gap, left = o.left, keep = o.keep and k < #lines })
      gap = 0
    end
  end
  return out
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption, title (Fed. R. Civ. P. 10(a); LR 10(a)(2))
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
  local rightp = stack(right)
  if #left == 0 then left = { p("") } end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. PARTY_W .. '"/><w:gridCol w:w="' .. (TEXTW - PARTY_W) .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(PARTY_W, table.concat(left))
    .. cell(TEXTW - PARTY_W, table.concat(rightp), '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. '</w:tr></w:tbl>'
  out[#out + 1] = p(xe.runs(txt(m.title), { b = true }), { before = BLANK, line = BODY, jc = "center" })
  if txt(m.subtitle) ~= "" then
    out[#out + 1] = p(xe.runs(txt(m.subtitle)), { line = BODY, jc = "center" })
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 11(a)(3)): the date at the margin when given, the counsel lines in the right part of the page
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature or {}
  local out = {}
  local date = txt(s.date)
  if date ~= "" then
    for _, x in ipairs(stack({ "Dated: " .. date }, { above = BLANK, keep = false })) do
      out[#out + 1] = x:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1)
    end
  end
  for _, x in ipairs(stack(strings(s.lines), { above = BLANK, left = SIG_IND, keep = true })) do
    out[#out + 1] = x
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1332(a)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A body paragraph (typst body-par): the body pitch, first line half an inch in. keep: with the next paragraph.
local function body_par(inl, keep, before)
  local props = { xe.style("BodyText") }
  if keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(before or 0, 0, BODY)
  return xe.para(props, xe.inl(inl))
end

local function styled(style, keep, label, inl)
  local props = { xe.style(style) }
  if keep then props[#props + 1] = xe.KEEP end
  return xe.para(props, xe.runs(label .. "\t") .. xe.inl(inl))
end

-- Heading (typst heading-block): kept with the next block; level 1 centred capitals, level 2 centred, level 3 left;
-- all bold on the body pitch, no space of their own.
local function heading(b)
  local c = b.content
  if b.level == 1 then c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end }) end
  local level = math.min(b.level, 3)
  return xe.para({ xe.style("Heading" .. level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(level <= 2 and "center" or "left") }, xe.inl(c, { b = true }))
end

-- The body blocks as raw paragraphs; numbering continues from n. keep: every paragraph kept with the next (the last
-- block stays with the signature block, as the typst template keeps it in one unbreakable block).
local function convert(blocks, n, keep)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = styled("NumberedParagraph", keep, n .. ".", b.content)
    elseif b.t == "BlockQuote" then
      -- an unnumbered paragraph (the jurisdiction statement, the prayer's lead-in)
      for _, c in ipairs(b.content) do
        out[#out + 1] = body_par(c.content, keep)
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for k, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and ((start + k - 1) .. ".") or "\u{2022}"
        out[#out + 1] = styled("LamdList", keep, label, pandoc.utils.blocks_to_inlines(item))
      end
    else
      error("lamd-complaint: unsupported block " .. b.t)
    end
  end
  return out, n
end

local function finish(doc)
  local m = doc.meta
  local x = cover(m)
  if m.lead_in then x[#x + 1] = body_par(m.lead_in, false, BLANK) end

  -- The last paragraph (or, when the body ends in a list, its last item) is kept with the signature block (typst:
  -- one unbreakable block); the rest of a list may stay behind on the page before.
  local blocks = doc.blocks
  local head = {}
  for i = 1, #blocks - 1 do head[#head + 1] = blocks[i] end
  local tail = blocks[#blocks]
  if (tail.t == "BulletList" or tail.t == "OrderedList") and #tail.content > 1 then
    local items = tail.content
    local rest, final = pandoc.List({}), pandoc.List({ items[#items] })
    for k = 1, #items - 1 do rest:insert(items[k]) end
    if tail.t == "OrderedList" then
      local a = tail.listAttributes
      head[#head + 1] = pandoc.OrderedList(rest, a)
      tail = pandoc.OrderedList(final, pandoc.ListAttributes(a.start + #items - 1, a.style, a.delimiter))
    else
      head[#head + 1] = pandoc.BulletList(rest)
      tail = pandoc.BulletList(final)
    end
  end
  local main, n = convert(head, 0, false)
  local last = convert({ tail }, n, true)
  for _, s in ipairs(main) do x[#x + 1] = s end
  for _, s in ipairs(last) do x[#x + 1] = s end
  for _, s in ipairs(signature(m)) do x[#x + 1] = s end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }
