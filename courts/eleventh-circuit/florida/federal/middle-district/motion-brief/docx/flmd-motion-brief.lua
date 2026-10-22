-- Motion with legal memorandum for the U.S. District Court for the Middle District of Florida (flmd), docx engine:
-- what the Word output adds to pandoc's conversion, so that it reads and breaks as typst/flmd-motion-brief.typ does:
-- the court title and caption (FRCP 10(a)), the lead-in, the indented body paragraphs (not numbered: memoranda are
-- not pleadings), the `~ ` paragraphs without indent, lettered lists, indented quotations, headings levels 1 to 4,
-- the signature block, and the certificate of service printed after it as one kept-together block. Everything
-- printed comes from the sample's frontmatter and body: no case text lives in this file. "~ " is an unindented
-- paragraph in this contract, so pandoc's definition lists are off (reference.xml pandoc-from).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 644, 322          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent, 0.5 in
local TEXTW = 9360                     -- 6.5 in
local CAP_W, CAP_GUTTER = 4176, 360    -- typst caption-w 2.9 in, caption-gutter 0.25 in
local DESIG = 720                      -- typst designation-indent 0.5 in
local CASE_DROP = 720                  -- typst case-number-drop 0.5 in
local ITEM_INDENT, ITEM_LABEL = 720, 576 -- typst item-indent 0.5 in, item-label 0.4 in
local QUOTE = 720                      -- typst quote-indent 0.5 in
local SIG_INDENT = 4320                -- typst sig-indent 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Inlines as runs, a hard line break of the sample ("\" at a line end) kept as Word's line break.
local function runs_br(inlines)
  local out, cur = {}, pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "LineBreak" then
      out[#out + 1] = xe.inl(cur)
      out[#out + 1] = xe.BR
      cur = pandoc.Inlines({})
    else
      cur:insert(el)
    end
  end
  out[#out + 1] = xe.inl(cur)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Court title and caption (FRCP 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" }),
    p(xe.runs("MIDDLE DISTRICT OF FLORIDA", { b = true }), { jc = "center" }),
  }
  if meta.division then
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.division)), { b = true }), { jc = "center" })
  end
  -- the caption stands a double line below the title (typst: the caption block's above); Word has no space before a
  -- table, so the last title line takes it as space after
  out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. BODY .. '"', 1)
  -- Party column: names, the designation (indented), the versus word between the parties, the closing rule.
  local versus = meta.caption.versus and plain(meta.caption.versus) or "v."
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.inl(versus)) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG })
  end
  left[#left + 1] = p(xe.runs(string.rep("_", 29) .. "/"))
  local right = { p(xe.runs("CASE NO.: " .. plain(meta.case_number)), { before = CASE_DROP }) }
  local rest = TEXTW - CAP_W
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_W .. '"/><w:gridCol w:w="' .. rest .. '"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_W .. '" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. rest .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_GUTTER ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- The title of the paper: a double line below the caption, a single line above the text.
  out[#out + 1] = p(xe.inl(meta.brief_title, { b = true }), { jc = "center", before = BODY, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, bold; levels 1 and 2 centered, 3 at the margin, 4 italic; kept with the text.
local function heading(el, o)
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(o.before or 0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(el.content, { b = true, i = el.level > 3 }))
end

local function is_unindented(b)
  local first, second = b.content[1], b.content[2]
  return first and first.t == "Str" and first.text == "~" and second and second.t == "Space"
end

-- One body block into `out`. o = { keep, before }: keep holds it with the next block (the certificate moves whole),
-- before is the space above its first paragraph.
local function body_block(b, out, o)
  if b.t == "Header" then
    out[#out + 1] = heading(b, o)
  elseif (b.t == "Para" or b.t == "Plain") and is_unindented(b) then
    local rest = pandoc.Inlines({})
    for i = 3, #b.content do rest:insert(b.content[i]) end
    out[#out + 1] = p(runs_br(rest), { line = BODY, keep = o.keep, before = o.before })
  elseif b.t == "Para" or b.t == "Plain" then
    out[#out + 1] = p(runs_br(b.content), { line = BODY, first = INDENT, keep = o.keep, before = o.before })
  elseif b.t == "OrderedList" or b.t == "BulletList" then
    -- Lettered items (a), (b), ... (typst enum "(a)"): the label half an inch in, the text hanging after it.
    for j, item in ipairs(b.content) do
      for k, ib in ipairs(item) do
        local lab = k == 1 and ("(" .. string.char(96 + j) .. ")\t") or ""
        out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content),
          { line = BODY, left = ITEM_INDENT + ITEM_LABEL, hanging = ITEM_LABEL, keep = o.keep })
      end
    end
  elseif b.t == "BlockQuote" then
    -- Indented quotation, single-spaced, half an inch in from both margins, a single line below.
    for k, q in ipairs(b.content) do
      out[#out + 1] = p(runs_br(q.content), { left = QUOTE, right = QUOTE, keep = o.keep,
        after = k == #b.content and SINGLE or 0 })
    end
  else
    error("flmd-motion-brief.lua: unsupported block " .. b.t)
  end
end

-- ---------------------------------------------------------------------------
-- Signature (Fed. R. Civ. P. 11(a))
-- ---------------------------------------------------------------------------

-- "Respectfully submitted," at the paragraph indent, then the firm, each counsel and the address with the "for"
-- line, single-spaced at 3 in with a single line between the groups; the lines kept together.
local function signature(meta, out)
  local sig = meta.signature
  local lines = { { xe.runs("Respectfully submitted,"), INDENT, SINGLE } }
  local groups = { sig.firm or {} }
  for _, c in ipairs(sig.counsel or {}) do groups[#groups + 1] = c end
  local last = {}
  for _, l in ipairs(sig.address or {}) do last[#last + 1] = l end
  last[#last + 1] = sig["for"] or ""
  groups[#groups + 1] = last
  for _, g in ipairs(groups) do
    for k, l in ipairs(g) do lines[#lines + 1] = { xe.inl(l), SIG_INDENT, k == 1 and SINGLE or 0 } end
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { left = l[2], before = l[3], keep = i < #lines })
  end
end

-- typst binds a doubled section sign or pilcrow to its number ("¶¶ 24-39"); pandoc's own binding takes one sign.
local function bind_double_signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks, Inlines = bind_double_signs })
  local meta = doc.meta
  local blocks = doc.blocks
  -- The certificate of service follows the signature block, as in the typst template.
  local cert_at
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content) == "CERTIFICATE OF SERVICE" then
      cert_at = i
      break
    end
  end
  local out = cover(meta)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT }) end
  for i = 1, (cert_at and cert_at - 1 or #blocks) do body_block(blocks[i], out, {}) end
  signature(meta, out)
  if cert_at then
    for i = cert_at, #blocks do
      -- Every block of the certificate but the last is kept with the next: the certificate moves as one block,
      -- a double line below the signature.
      body_block(blocks[i], out, { keep = i < #blocks, before = i == cert_at and BODY or nil })
    end
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
