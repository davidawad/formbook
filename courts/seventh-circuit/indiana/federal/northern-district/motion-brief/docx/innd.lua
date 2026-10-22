-- N.D. Ind. motion brief (supporting memorandum), docx engine (docs/DOCX.md). The brief as Word paragraphs, so that
-- it reads and breaks as typst/innd-motion-brief.typ does: the court title, the caption (the party column ruled at
-- its right and foot, the case number and judge beside it), the paper title, unnumbered body paragraphs with their
-- footnotes (pandoc writes the notes), headings, block quotations, the signature block and the certificate of
-- service. Every case-specific word comes from the sample's frontmatter and body, never from this file. Font,
-- margins, the footnote and body paragraph styles and the page number are in docx/reference.xml (fb render builds
-- the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4608                    -- typst caption-left, 3.2 in
local CAP_GUTTER = 432                   -- typst caption-gutter, 0.3 in
local CAP_PAD_RIGHT = 158                -- typst caption-pad-right, 0.12 in (173 twips), less the 0.75 pt rule Word sets inside it
local CAP_PAD_BOTTOM = 129               -- typst caption-pad-bottom, 0.1 in (144 twips), less the rule
local DESIGNATION = 1728                 -- typst designation-indent, 1.2 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local SIG = 4608                         -- typst sig-col, 3.2 in
local PARA_GAP, BLOCK_GAP = 396, 552     -- typst para-gap, block-gap

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

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("¶¶ 67-68"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

local function fix(inl)
  return bind_doubled(pandoc.Inlines(inl):walk({ Str = breaks }))
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

local function text(v) return plain(v) == "" and "" or xe.inl(type(v) == "string" and v or fix(v)) end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, paper title
-- ---------------------------------------------------------------------------

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function mar(bottom, right)
  return '<w:tcMar><w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. (right or 0) ..
    '" w:type="dxa"/></w:tcMar>'
end

local function caption(m)
  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("v."))
      left[#left + 1] = p("")
    end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(text(n)) end
    left[#left + 1] = p(text(party.designation), { left = DESIGNATION })
  end
  local right = { p(xe.runs("Case No. " .. plain(m.case_number))) }
  if m.judge ~= nil then
    right[#right + 1] = p("")
    right[#right + 1] = p(xe.runs("Judge " .. plain(m.judge)))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, RULES .. mar(CAP_PAD_BOTTOM, CAP_PAD_RIGHT), left) ..
    cell(CAP_GUTTER, "", { p("") }) ..
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, mar(CAP_PAD_BOTTOM), right) .. '</w:tr></w:tbl>'
end

local function upper(inl)
  return pandoc.Inlines(inl):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function cover(m, out)
  for _, l in ipairs(items(m.court)) do out[#out + 1] = p(xe.inl(fix(l), { b = true }), { jc = "center" }) end
  if m.division ~= nil then
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(m.division)), { b = true }), { jc = "center" })
  end
  out[#out + 1] = p("", { line = BLOCK_GAP })
  out[#out + 1] = caption(m)
  out[#out + 1] = p(xe.inl(upper(fix(m.title)), { b = true }),
    { before = BLOCK_GAP, after = BLOCK_GAP, line = BODY, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature and certificate: single lines in the column from SIG, "Dated:" beside the first
-- ---------------------------------------------------------------------------

-- ls: { {runs, space above}, ... }; an empty runs string is a blank line. All but the last are kept with the next.
local function sig_lines(ls, first, out)
  for i, l in ipairs(ls) do
    local keep = i < #ls
    if i == 1 and first then
      out[#out + 1] = p(xe.runs(first .. "\t") .. l[1], { before = l[2], left = SIG, hanging = SIG, tab = SIG, keep = keep })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = keep })
    end
  end
end

local function signature(m, out)
  local sig = m.signature
  local ls = { { xe.runs("Respectfully submitted,"), BLOCK_GAP } }
  local gap = BLOCK_GAP
  if sig.party ~= nil then
    ls[#ls + 1] = { xe.runs(pandoc.text.upper(plain(sig.party))), gap }
    gap = SINGLE
  end
  ls[#ls + 1] = { xe.runs("By: " .. plain(sig.by)), gap }
  if sig.role ~= nil then ls[#ls + 1] = { text(sig.role), 0 } end
  for i, c in ipairs(items(sig.counsel)) do ls[#ls + 1] = { text(c), i == 1 and BLOCK_GAP or 0 } end
  sig_lines(ls, "Dated: " .. plain(sig.dated), out)
end

local function certificate(m, out)
  local c = m.certificate
  if c == nil then return end
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(c.title)), { b = true }),
    { before = BLOCK_GAP, line = BODY, jc = "center", keep = true })
  out[#out + 1] = p(xe.inl(fix(c.text)), { before = BLOCK_GAP, line = BODY, first = INDENT, keep = true })
  local ls = {}
  for i, l in ipairs(items(c.counsel)) do ls[#ls + 1] = { text(l), i == 1 and BLOCK_GAP or 0 } end
  sig_lines(ls, nil, out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings on the body pitch, a double line above and 19.8 pt below, kept with the text: level 1 centered bold
-- capitals, level 2 bold at the margin, level 3 bold italic.
local function heading(b)
  local lvl = math.min(b.level, 3)
  local content = lvl == 1 and upper(b.content) or b.content
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(BLOCK_GAP, PARA_GAP, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local m = doc.meta
  local raw = {}
  cover(m, raw)
  local res = {}
  local function flush()
    for _, x in ipairs(raw) do res[#res + 1] = xe.raw(x) end
    raw = {}
  end
  local last = 0
  for i, b in ipairs(doc.blocks) do
    if b.t == "Para" then last = i end
  end
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      raw[#raw + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for j, q in ipairs(b.content) do
        raw[#raw + 1] = p(xe.inl(q.content), { before = j == 1 and BLOCK_GAP or SINGLE, after = BLOCK_GAP,
          left = QUOTE, right = QUOTE })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- a list: each item's number (a bullet as "•") at the indent, its text from 1 in (typst list-text)
      flush()
      local n = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.Str(b.t == "OrderedList" and (n .. ".") or "\u{2022}"),
          pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        local para = pandoc.Pandoc({ pandoc.Para(inl) }):walk({ Inlines = xe.inlines }).blocks[1]
        res[#res + 1] = styled("List Para", para.content)
        n = n + 1
      end
    elseif b.t == "Para" then
      -- a body paragraph: pandoc writes it with its footnotes
      flush()
      local style = i == last and "Body Last" or "Body Para"
      -- the break rules on the inlines pandoc writes itself, its footnotes included
      b = pandoc.Pandoc({ b }):walk({ Inlines = xe.inlines }).blocks[1]
      res[#res + 1] = styled(style, b.content)
    else
      error("innd.lua: unsupported block " .. b.t)
    end
  end
  signature(m, raw)
  certificate(m, raw)
  flush()
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
