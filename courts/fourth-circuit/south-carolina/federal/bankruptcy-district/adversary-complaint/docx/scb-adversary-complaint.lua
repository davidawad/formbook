-- scb adversary complaint, docx engine. Mirrors typst/scb-adversary-complaint.typ; rules and conventions are in
-- ../README.md. The court title, the caption (Official Form 416 layout: In re: / Debtor. over the adversary parties,
-- rules closing each block, the case column on the right), the opening paragraph, the numbered allegations (Fed. R.
-- Civ. P. 10(b) as applied by Rule 7010: a paragraph not directly after a quotation or list and not before a list),
-- the block quotations, the lettered prayer and the signature block (SC LBR 9011-4) with the "Dated" line are built
-- here. Font, size and the page number are styles and section settings in docx/reference.xml (fb render builds the
-- reference document from it). Numbers and letters are typed text, as the typst template types them.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 324 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 324              -- typst pitch-body 24 pt, pitch-single 16.2 pt
local TEXTW = 9360                         -- 6.5 in of text
local PARA_INDENT = 720                    -- typst para-indent 0.5 in
local NUMBER_BOX = 720                     -- typst number-box 0.5 in (a tab stop)
local LIST_INDENT, LETTER_BOX = 720, 720   -- typst list-indent, letter-box 0.5 in
local QUOTE_INDENT = 720                   -- typst quote-indent 0.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360     -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_PAD, CASE_PAD = 216, 360         -- typst caption-pad 0.15 in, case-pad 0.25 in
local DESIGNATION, VERSUS = 2016, 576      -- typst designation-indent 1.4 in, versus-indent 0.4 in
local SIG_LEFT = 4680                      -- typst sig-left 3.25 in
local CAPTION_GAP, COVER_GAP = 240, 480    -- typst caption-gap 12 pt, cover-gap 24 pt
local CASE_GAP, TITLE_GAP = 1440, 720      -- typst case-gap 72 pt, title-gap 36 pt
local HEADING_ABOVE = 240                  -- typst heading-above 12 pt
local QUOTE_ABOVE, QUOTE_BELOW, QUOTE_GAP = 240, 240, 216 -- typst quote-above, quote-below 12 pt, quote-gap 10.8 pt
local SIG_ABOVE, DATED_ABOVE = 480, 480    -- typst signature-above, dated-above 24 pt

-- A bottom border adds its width (0.75 pt, 15 twips) to its paragraph; typst's rule takes no height, so the space
-- after a rule is that much less.
local RULE_W = 15
local RULE = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>'

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

-- A single-spaced paragraph: o = { before, after, left, jc, keep, rule, line, first, hanging, right, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.rule then props[#props + 1] = RULE end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = nil
  if not o.hanging then first = o.first or 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- ---------------------------------------------------------------------------
-- Cover: court title and caption (Fed. R. Bankr. P. 7010, 9004(b))
-- ---------------------------------------------------------------------------

local function court_title(m)
  local out, lines = {}, items(m.court)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.inl(l, { b = i == #lines }), { jc = "center" })
  end
  return table.concat(out)
end

local function caption(m)
  local b = m.bankruptcy
  local left = { p(xe.runs("In re:")) }
  for i, d in ipairs(items(b.debtor)) do
    left[#left + 1] = p(xe.inl(d), { before = i == 1 and CAPTION_GAP or 0 })
  end
  left[#left + 1] = p(xe.runs("Debtor."), { before = CAPTION_GAP, jc = "right", rule = true })
  local parties = items(m.caption.parties)
  for i, pt in ipairs(parties) do
    for j, n in ipairs(items(pt.names)) do
      left[#left + 1] = p(xe.inl(n), { before = j == 1 and (CAPTION_GAP - (i == 1 and RULE_W or 0)) or 0 })
    end
    left[#left + 1] = p(xe.inl(pt.designation), { left = DESIGNATION, rule = i == #parties })
    if i < #parties then
      left[#left + 1] = p(xe.runs("v."), { before = CAPTION_GAP, left = VERSUS })
    end
  end
  local right = {
    p(xe.inl(b.case_number)),
    p(xe.inl(b.chapter)),
    p(xe.inl(m.adversary_number), { before = CASE_GAP }),
    p(xe.inl(m.title, { b = true }), { before = TITLE_GAP }),
  }
  local cap_right = TEXTW - CAP_LEFT - CAP_GUTTER
  return xe.para({ xe.spacing(0, 0, COVER_GAP) }, "")
    .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="'
    .. cap_right .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_LEFT, table.concat(left), '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
      .. '<w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. cell(CAP_GUTTER, p(""))
    .. cell(cap_right, table.concat(right), '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. '</w:tr></w:tbl>'
    .. xe.para({ xe.spacing(0, 0, COVER_GAP - RULE_W) }, "")
end

-- ---------------------------------------------------------------------------
-- Signature block (SC LBR 9011-4) and the "Dated" line
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local out = { p(xe.runs("/s/ ") .. xe.inl(s.signer), { before = SIG_ABOVE, left = SIG_LEFT, keep = true }) }
  for _, l in ipairs(items(s.lines)) do out[#out + 1] = p(xe.inl(l), { left = SIG_LEFT, keep = true }) end
  out[#out + 1] = p(xe.inl(s.role), { left = SIG_LEFT, keep = true })
  out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(s.date), { before = DATED_ABOVE })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(H)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function kind(b)
  if b.t == "Header" then return "heading" end
  if b.t == "BlockQuote" then return "quote" end
  if b.t == "BulletList" or b.t == "OrderedList" then return "list" end
  if b.t == "Para" or b.t == "Plain" then return "para" end
  error("scb-adversary-complaint.lua: unexpected block " .. b.t)
end

-- One markdown block as Word paragraphs; keep: every paragraph kept with the next (the closing blocks).
local function convert(b, k, prev, nxt, n, keep)
  local out = {}
  if k == "heading" then
    out[#out + 1] = p(xe.inl(b.content, { b = true }),
      { style = "Heading2", keep = true, before = HEADING_ABOVE, line = BODY, jc = "center" })
  elseif k == "quote" then
    for i, q in ipairs(b.content) do
      if q.t ~= "Para" and q.t ~= "Plain" then error("scb-adversary-complaint.lua: a block quotation must hold paragraphs") end
      out[#out + 1] = p(xe.inl(q.content), { keep = keep, before = i == 1 and QUOTE_ABOVE or QUOTE_GAP,
        left = QUOTE_INDENT, right = QUOTE_INDENT })
    end
  elseif k == "list" then
    for i, item in ipairs(b.content) do
      out[#out + 1] = p(xe.runs(string.char(96 + i) .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
        { keep = keep, line = BODY, left = LIST_INDENT + LETTER_BOX, hanging = LETTER_BOX })
    end
  elseif n then
    out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { keep = keep, line = BODY, tab = NUMBER_BOX })
  else
    out[#out + 1] = p(xe.inl(b.content), { keep = keep, line = BODY, before = prev == "quote" and QUOTE_BELOW or 0 })
  end
  return table.concat(out)
end

local function finish(doc)
  local m = doc.meta
  local out = { court_title(m), caption(m) }
  if m.lead_in then out[#out + 1] = p(xe.inl(m.lead_in), { line = BODY, first = PARA_INDENT }) end
  local blocks = doc.blocks
  local kinds = {}
  for i, b in ipairs(blocks) do kinds[i] = kind(b) end
  local n = 0
  for i, b in ipairs(blocks) do
    local k = kinds[i]
    local prev = i > 1 and kinds[i - 1] or "heading"
    local nxt = i < #blocks and kinds[i + 1] or ""
    local num
    if k == "para" and prev ~= "quote" and prev ~= "list" and nxt ~= "list" then
      n = n + 1
      num = n
    end
    out[#out + 1] = convert(b, k, prev, nxt, num, i >= #blocks - 1)
  end
  out[#out + 1] = signature(m)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
