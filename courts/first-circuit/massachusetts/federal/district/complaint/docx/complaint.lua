-- complaint.lua (docx engine): the D. Mass. complaint as Word paragraphs and a caption table, so that it reads and
-- breaks as typst/mad-complaint.typ does:
--   * the court title (MAD-CAP-001), then the caption: the party column closed by a rule on its right and below,
--     the civil action number and the title of the paper in bold to its right (MAD-CAP-002, MAD-CAP-003);
--   * the lead-in, then the allegations: each prose paragraph numbered 1., 2. ... (Fed. R. Civ. P. 10(b)); headings,
--     quotations, the prayer (lettered A., B., ...) and a WHEREFORE paragraph are not;
--   * the jury demand, the signature block at 3.0 in (MAD-SIG-001: the BBO number under each attorney's name), kept
--     together, and the date.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276             -- typst pitch-double, pitch-single
local INDENT = 720                        -- typst para-indent, item-indent, quote-indent: 0.5 in
local LABEL = 576                         -- typst item-label, 0.4 in
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT = 4680                     -- typst caption-left 3.25 in
local CAP_INSET = 200                     -- typst caption-inset 10 pt
local CAP_RIGHT = 504                     -- typst caption-gutter 0.25 in + caption-right-inset 0.1 in
local DESIGNATION, VS = 1800, 720         -- typst designation-indent 1.25 in, vs-indent 0.5 in
local SIG = 4320                          -- typst sig-indent 3.0 in

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  for _, l in ipairs({ "UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF MASSACHUSETTS" }) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true })
  end
  -- the party column: names, the designation a single line lower, "v." a single line off each side
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { before = SINGLE, left = VS }) end
    for j, name in ipairs(party.names) do
      left[#left + 1] = p(xe.inl(name), { before = (j == 1 and k > 1) and SINGLE or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { before = SINGLE, left = DESIGNATION })
  end
  local right = p(xe.runs("Civil Action No. ") .. xe.inl(meta.case_number)) ..
    p(xe.inl(meta.title, { b = true }), { before = BODY })
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  -- the caption stands a double line below the court title: an empty paragraph of that height before the table
  out[#out + 1] = p("", { line = BODY, keep = true })
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. rule ..
    '<w:tcMar><w:bottom w:w="' .. CAP_INSET .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/>' ..
    '<w:tcMar><w:left w:w="' .. CAP_RIGHT .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. right .. '</w:tc>' ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature block (MAD-SIG-001): one block that never breaks across a page
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = {}
  local function group(list, before)
    for i, l in ipairs(list) do
      lines[#lines + 1] = { body = l, before = i == 1 and before or 0, left = SIG }
    end
  end
  local party = {}
  for _, l in ipairs(sig.party) do party[#party + 1] = xe.inl(l) end
  group(party, BODY)
  group({ xe.runs("/s/ ") .. xe.inl(sig.signer) }, SINGLE)
  for _, a in ipairs(sig.attorneys) do
    group({ xe.inl(a.name) .. xe.runs(" (BBO# ") .. xe.inl(a.bbo) .. xe.runs(")"), xe.inl(a.email) }, SINGLE)
  end
  local firm = {}
  for _, l in ipairs(sig.firm) do firm[#firm + 1] = xe.inl(l) end
  group(firm, SINGLE)
  lines[#lines + 1] = { body = xe.runs("Dated: ") .. xe.inl(meta.date), before = BODY }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, left = l.left, keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch: level 1 centered capitals, level 2 centered bold, level 3 bold at the left, hanging;
-- kept with the text after them.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY),
    el.level <= 2 and xe.ind(0, nil, 0) or xe.ind(INDENT, INDENT),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- The marker of item n as typed ("(3)", "a.", "4)").
local function marker(attrs, n)
  local style, delim = tostring(attrs.style), tostring(attrs.delimiter)
  local m = tostring(n)
  if style == "LowerAlpha" then m = string.char(96 + n) elseif style == "UpperAlpha" then m = string.char(64 + n) end
  if delim == "OneParen" then return m .. ")" end
  if delim == "TwoParens" then return "(" .. m .. ")" end
  return m .. "."
end

-- Paragraphs of a quotation: a list item (pandoc reads "(b) Except ..." as one; commonmark, and so typst, keeps it
-- as typed) becomes a paragraph that starts with its marker.
local function flatten(list)
  local out = {}
  for _, b in ipairs(list) do
    if b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        for k, ib in ipairs(flatten(item)) do
          local c = pandoc.Inlines(ib.content)
          if k == 1 then
            c:insert(1, pandoc.Space())
            c:insert(1, pandoc.Str(marker(b.listAttributes, b.listAttributes.start + i - 1)))
          end
          out[#out + 1] = pandoc.Para(c)
        end
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = b
    else
      error("complaint.lua: unsupported block in a quotation " .. b.t)
    end
  end
  return out
end

local function blocks(doc, out)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b.content):sub(1, 9) == "WHEREFORE" then
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
      else
        -- the number in a box of para-indent after the first-line indent (typst: box(width: para-indent))
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT,
          tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- the prayer, lettered A., B., ...: the label half an inch in, the text hanging a label box after it
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and (b.t == "OrderedList" and (string.char(64 + j) .. ".\t") or "\u{2022}\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = INDENT + LABEL,
            hanging = LABEL })
        end
      end
    elseif b.t == "BlockQuote" then
      -- single-spaced, indented both sides, a single line off the text above and below
      local qs = flatten(b.content)
      for k, q in ipairs(qs) do
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT,
          before = k == 1 and SINGLE or 0, after = k == #qs and SINGLE or 0 })
      end
    else
      error("complaint.lua: unsupported block " .. b.t)
    end
  end
end

-- Line breaks inside a web address (as courts/tenth-circuit/court-of-appeals/reply-brief/docx/ca10.lua): typst
-- breaks a word that starts a web address ("https://", "www.": cmarker links both) where the class of character
-- changes: letter, digit, opening bracket, other; after an "other" character before anything, and between a letter
-- and a digit either way, never after an opening bracket; a piece of 16 characters or more breaks after any
-- character. LibreOffice breaks such a word by Unicode rules: the typst places get a zero-width space.
local ZWSP = "\u{200B}"

local function url_cuts(link)
  local function class(c)
    if c:match("^%a$") or #c > 1 then return "A" end
    if c:match("^%d$") then return "D" end
    if c == "(" or c == "[" then return "O" end
    return "X"
  end
  local cuts, starts = {}, {}
  for q in utf8.codes(link) do starts[#starts + 1] = q - 1 end
  local offset, prev = 0, "X"
  for i, b in ipairs(starts) do
    local c = link:sub(b + 1, starts[i + 1] or #link)
    local cl = class(c)
    if b > 0 and prev ~= "O" and ((cl == "X" and prev == "X") or (cl ~= "X" and cl ~= prev)) then
      if b - offset >= 16 then
        for _, q in ipairs(starts) do if q > offset and q < b then cuts[q] = true end end
      end
      cuts[b] = true
      offset = b
    end
    prev = cl
  end
  return cuts
end

local function url_breaks(text)
  local at = text:find("https?://") or text:find("www%.")
  if not at then return nil end
  local tail_at = #text + 1
  while tail_at > at and text:sub(tail_at - 1, tail_at - 1):match("[.,;:!?]") do tail_at = tail_at - 1 end
  local link = text:sub(at, tail_at - 1)
  local keys = {}
  for k in pairs(url_cuts(link)) do keys[#keys + 1] = k end
  table.sort(keys)
  local out, from = {}, 1
  for _, k in ipairs(keys) do
    out[#out + 1] = link:sub(from, k)
    from = k + 1
  end
  out[#out + 1] = link:sub(from)
  return text:sub(1, at - 1) .. table.concat(out, ZWSP) .. text:sub(tail_at)
end

-- typst's break opportunities that LibreOffice does not share: those inside a web address (above), none inside
-- ")(" (a word joiner), one after a slash before a letter ("and/or": a zero-width space). None shows in the PDF
-- text.
local function breaks(s)
  local t = url_breaks(s.text) or s.text:gsub("/([^%d])", "/" .. ZWSP .. "%1")
  return pandoc.Str((t:gsub("%)%(", ")\u{2060}(")))
end

-- A doubled sign stays with its number ("§§ 1331"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" and #a.text >= 4 and a.text:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, before = BODY })
  end
  blocks(doc, out)
  if meta.jury_demand then
    out[#out + 1] = p(xe.inl(meta.jury_demand, { b = true }), { line = BODY, first = INDENT, before = SINGLE })
  end
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
