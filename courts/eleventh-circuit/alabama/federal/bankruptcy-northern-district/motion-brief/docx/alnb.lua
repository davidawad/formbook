-- alnb.lua (docx engine, motion with memorandum): the N.D. Ala. bankruptcy motion as Word paragraphs and borderless
-- caption tables, so that it reads and breaks as typst/alnb-motion-brief.typ does (see ../README.md "Engines"): the
-- court title, the caption (party names | ")" column | case text), the title of the paper, the headings (level 1
-- centered, level 2 half an inch in), the body as unnumbered paragraphs (a motion states its grounds in prose, Fed.
-- R. Bankr. P. 9013), the signature block and the certificate of service with the served parties. Everything comes
-- from the sample's frontmatter and body; nothing case-specific or measured is in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs stay
-- pandoc paragraphs (style "Body Text", or "Body Text Note" in reference.xml), so pandoc writes their footnotes.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_MID = 4824, 576      -- typst caption-left 3.35 in, caption-mid 0.4 in
local DESIGNATION = 3240                 -- typst designation-indent 2.25 in
local SIG = 4680                         -- typst sig-indent 3.25 in
local INDENT = 720                       -- typst para-indent, 0.5 in

-- Designations in the caption ("Plaintiff,", "Defendants.") sit in from the left; other caption lines do not.
local STEMS = { "Plaintiff", "Defendant", "Debtor", "Movant", "Respondent" }
local function is_designation(s)
  local stem = s:match("^(.-)s?[,.]$")
  if stem == nil then return false end
  for _, x in ipairs(STEMS) do
    if stem == x then return true end
  end
  return s:match("^Counter%-?%w*[,.]$") ~= nil
end

local function upper(m)
  return pandoc.Inlines(m):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.raw(xe.para(props, body))
end

local function cell(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function xml(b) return b.text end

-- One caption block: a fixed-width table without borders, one row per line; `before` on its first row.
local function caption_table(blk, before)
  local left, right = blk.left or {}, blk.right or {}
  local rows = {}
  for i = 1, math.max(#left, #right) do
    local l = left[i] and pandoc.utils.stringify(left[i]) or ""
    local b = i == 1 and before or 0
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      cell(CAP_LEFT, xml(p(left[i] and xe.inl(left[i]) or "", { before = b, left = is_designation(l) and DESIGNATION or 0 }))) ..
      cell(CAP_MID, xml(p(xe.runs(")"), { before = b, jc = "center" }))) ..
      cell(TEXTW - CAP_LEFT - CAP_MID, xml(p(right[i] and xe.inl(right[i]) or "", { before = b }))) .. '</w:tr>'
  end
  return xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_MID .. '"/>' ..
    '<w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_MID) .. '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>')
end

-- Lines at the signature indent, the first with `before` above it.
local function sig_lines(lines, list, before)
  for i, l in ipairs(list) do
    lines[#lines + 1] = { body = l, before = i == 1 and before or 0, left = SIG }
  end
end

local function each_inl(list)
  local out = {}
  for _, l in ipairs(list or {}) do out[#out + 1] = xe.inl(l) end
  return out
end

-- Paragraphs that never break across a page: each kept with the next, the last one ends the chain.
local function chain(lines, out)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, left = l.left, first = l.first, jc = l.jc, keep = i < #lines })
  end
end

-- The signature block: "Dated" at the margin, the rest at the signature indent.
local function signature(sig, out)
  local lines = { { body = xe.runs("Dated: ") .. xe.inl(sig.date), before = BODY } }
  lines[#lines + 1] = { body = xe.runs("Respectfully submitted,"), before = SINGLE, left = SIG }
  sig_lines(lines, each_inl(sig.lead), BODY)
  local signer = { xe.runs("/s/ ") .. xe.inl(sig.signer) }
  for _, l in ipairs(each_inl(sig.lines)) do signer[#signer + 1] = l end
  sig_lines(lines, signer, SINGLE)
  if sig.of_counsel then sig_lines(lines, each_inl(sig.of_counsel), SINGLE) end
  chain(lines, out)
end

-- The certificate of service: its heading, the statement (single-spaced, indented), each served party half an
-- inch in, the signer at the signature indent.
local function certificate(cert, out)
  local lines = { { body = xe.runs("CERTIFICATE OF SERVICE", { b = true }), before = BODY, jc = "center" } }
  lines[#lines + 1] = { body = xe.inl(cert.text), before = SINGLE, first = INDENT }
  for _, party in ipairs(cert.served or {}) do
    for i, l in ipairs(party) do
      lines[#lines + 1] = { body = xe.inl(l), before = i == 1 and SINGLE or 0, left = INDENT }
    end
  end
  local signer = { xe.runs("/s/ ") .. xe.inl(cert.signer) }
  for _, l in ipairs(each_inl(cert.signer_lines)) do signer[#signer + 1] = l end
  sig_lines(lines, signer, SINGLE)
  chain(lines, out)
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A body paragraph: pandoc writes it (and its footnotes) in "Body Text"; a paragraph that carries a footnote mark
-- in "Body Text Note" (no widow control).
local function body_par(inlines)
  local style = has_note(inlines) and "Body Text Note" or "Body Text"
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- Headings: bold, single-spaced, a single line above and below, kept with the text; level 1 centered, level 2
-- half an inch in.
local function heading(el)
  return p(xe.inl(el.content, { b = true }), { before = SINGLE, after = SINGLE, keep = true,
    jc = el.level == 1 and "center" or "left", left = el.level == 1 and 0 or INDENT })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157"), as the typst template boxes it (xe.inl binds a single sign).
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
  local m = doc.meta
  -- the break rules on the body only: the frontmatter goes through xe.inl, which applies them itself
  doc = pandoc.Pandoc(doc.blocks):walk({ Inlines = xe.inlines })
  local out = {}

  for _, l in ipairs(m.court or {}) do out[#out + 1] = p(xe.inl(upper(l)), { jc = "center", keep = true }) end
  for i, blk in ipairs(m.caption or {}) do out[#out + 1] = caption_table(blk, i == 1 and BODY or SINGLE) end
  -- Word has no space after a table: the title takes the space above it
  out[#out + 1] = p(xe.inl(upper(m.title), { b = true }), { before = BODY, after = SINGLE, jc = "center", keep = true })

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" then
      out[#out + 1] = body_par(b.content)
    else
      error("alnb.lua: unsupported block " .. b.t)
    end
  end
  if m.signature then signature(m.signature, out) end
  if m.certificate then certificate(m.certificate, out) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
