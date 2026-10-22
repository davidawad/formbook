-- W.D.N.Y. adversary complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it reads and
-- breaks as typst/nywb-adversary-complaint.typ does: the court title, the caption (the party column ruled at its right
-- and foot: the debtor (In re:), then the adversary parties with "vs."; beside it the case number, chapter, judge
-- (LBR 9004-2), the adversary number and the title in bold), the lead-in, numbered allegations (Civil Rule 10(b),
-- through Fed. R. Bankr. P. 7010), headings, block quotations, the lettered prayer and the signature block. Every
-- case-specific word comes from the sample's frontmatter and body, never from this file. Font, margins and the page
-- number are in docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LABEL = 1440                       -- typst para-indent + number-box: the text after a number or letter, 1 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_GUTTER = 360                   -- typst caption-gutter, 0.25 in
local CAP_PAD = 185                      -- typst caption-pad, 10 pt (200 twips), less the 0.75 pt rule Word sets inside it
local CAP_RIGHT_PAD = 144                -- typst caption-right-pad, 0.1 in
local SIG = 4608                         -- typst sig-col, 3.2 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local COVER_GAP = 276                    -- typst cover-gap
local LEAD_ABOVE = 552                   -- typst lead-above
local QUOTE_ABOVE, QUOTE_BELOW = 276, 138 -- typst quote-above, quote-below
local SIG_ABOVE, SIG_GAP = 552, 276      -- typst sig-above, sig-gap

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
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

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Single lines, one per item; an empty item is a blank line (typst: slines).
local function lines(list, left, out)
  out = out or {}
  for _, l in ipairs(list) do out[#out + 1] = p(plain(l) == "" and "" or xe.inl(l), { left = left }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption
-- ---------------------------------------------------------------------------

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function caption(m)
  local left = {}
  if m.debtor ~= nil then
    left[#left + 1] = "In re:"
    left[#left + 1] = ""
    for _, n in ipairs(items(m.debtor.names)) do left[#left + 1] = n end
    left[#left + 1] = m.debtor.designation
    left[#left + 1] = ""
  end
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then
      left[#left + 1] = ""
      left[#left + 1] = "vs."
      left[#left + 1] = ""
    end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = n end
    left[#left + 1] = party.designation
  end
  local right = { "Case No. " .. plain(m.case_number) }
  if m.chapter ~= nil then right[#right + 1] = plain(m.chapter) end
  if m.judge ~= nil then right[#right + 1] = "Hon. " .. plain(m.judge) end
  local adv = plain(m.adv_number)
  right[#right + 1] = ""
  right[#right + 1] = "Adv. Pro. No. " .. (adv ~= "" and adv or "__________")
  right[#right + 1] = ""
  local rps = lines(right, CAP_RIGHT_PAD)
  rps[#rps + 1] = p(xe.inl(m.brief_title, { b = true }), { left = CAP_RIGHT_PAD })
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, RULES .. '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', lines(left, 0)) ..
    cell(CAP_GUTTER, "", { p("") }) ..
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, "", rps) .. '</w:tr></w:tbl>'
end

local function cover(m, out)
  for _, t in ipairs(items(m.court_name)) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(t)), { b = true }), { jc = "center" })
  end
  out[#out + 1] = p("", { line = COVER_GAP })
  out[#out + 1] = caption(m)
  if m.counsel ~= nil then
    local c = lines(items(m.counsel), CAP_LEFT + CAP_GUTTER)
    c[1] = c[1]:gsub('w:before="0"', 'w:before="' .. SINGLE .. '"', 1)
    for _, x in ipairs(c) do out[#out + 1] = x end
  end
end

-- ---------------------------------------------------------------------------
-- Signature: "Dated:" in the first column, the first line beside it (a tab to the hanging indent), the rest under it
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local sig = m.signature
  local firm = items(sig.firm)
  local ls = {}
  for _, f in ipairs(firm) do ls[#ls + 1] = { xe.inl(f), 0 } end
  ls[#ls + 1] = { xe.runs("By: /s/ " .. plain(sig.signer)), #firm > 0 and SIG_GAP or 0 }
  for _, l in ipairs(items(sig.lines)) do ls[#ls + 1] = { xe.inl(l), 0 } end
  for i, l in ipairs(ls) do
    local keep = i < #ls
    if i == 1 then
      out[#out + 1] = p(xe.runs("Dated: " .. plain(m.date) .. "\t") .. l[1],
        { before = SIG_ABOVE, left = SIG, hanging = SIG, tab = SIG, keep = keep })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = keep })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings on the body pitch with no space of their own, kept with the text: level 1 centered bold capitals,
-- level 2 centered bold, level 3 bold italic at the margin.
local function heading(b)
  local content = b.content
  if b.level == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(b.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

local function blocks(list, out)
  local n = 0
  for _, b in ipairs(list) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for i, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = i == 1 and QUOTE_ABOVE or SINGLE, after = QUOTE_BELOW,
          left = QUOTE, right = QUOTE })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- the prayer, lettered A., B., ...: the letter at the indent, the text hanging at 1 in
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs(string.char(64 + i) .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { line = BODY, left = LABEL, hanging = INDENT, tab = LABEL })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local first = b.content[1]
      if first and first.t == "Str" and first.text:match("^WHEREFORE") then
        -- the prayer's lead-in: not numbered, kept with the prayer
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = true })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = LABEL })
      end
    else
      error("nywb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 544"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local m = doc.meta
  local out = {}
  cover(m, out)
  if m.lead_in ~= nil then
    out[#out + 1] = p(xe.inl(m.lead_in), { line = BODY, first = INDENT, before = LEAD_ABOVE })
  end
  blocks(doc.blocks, out)
  signature(m, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
