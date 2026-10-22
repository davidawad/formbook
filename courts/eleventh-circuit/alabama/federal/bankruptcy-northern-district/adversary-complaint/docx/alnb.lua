-- alnb.lua (docx engine, adversary complaint): the N.D. Ala. bankruptcy adversary complaint as Word paragraphs and
-- borderless caption tables, so that it reads and breaks as typst/alnb-adversary-complaint.typ does (see ../README.md
-- "Engines"): the court title, the caption (party names | ")" column | case text), the title of the paper, the
-- lead-in, the consent statement (Fed. R. Bankr. P. 7008(a)) and every body paragraph except a WHEREFORE prayer
-- numbered 1., 2., ... (Fed. R. Civ. P. 10(b)), the headings and the signature block. Everything comes from the
-- sample's frontmatter and body; nothing case-specific or measured is in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs stay
-- pandoc paragraphs (styles "Body Text", "Allegation" and their "Note" twins in reference.xml), so pandoc writes
-- their footnotes.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_MID = 4824, 576      -- typst caption-left 3.35 in, caption-mid 0.4 in
local DESIGNATION = 3240                 -- typst designation-indent 2.25 in
local SIG = 4680                         -- typst sig-indent 3.25 in

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

-- A paragraph: o = { before, after, line, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
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

-- The signature block: "Dated" at the margin, the rest at the signature indent; it never breaks across a page.
local function signature(sig, out)
  local lines = { { body = xe.runs("Dated: ") .. xe.inl(sig.date), before = BODY } }
  lines[#lines + 1] = { body = xe.runs("Respectfully submitted,"), before = SINGLE, left = SIG }
  for i, s in ipairs(sig.signers or {}) do
    lines[#lines + 1] = { body = (i == 1 and xe.runs("/s/ ") or "") .. xe.inl(s), before = i == 1 and BODY or 0, left = SIG }
  end
  for _, group in ipairs({ sig.firm or {}, sig.address or {}, sig.contact or {}, sig.role or {} }) do
    for i, l in ipairs(group) do
      lines[#lines + 1] = { body = xe.inl(l), before = i == 1 and SINGLE or 0, left = SIG }
    end
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, left = l.left, keep = i < #lines })
  end
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A body paragraph: pandoc writes it (and its footnotes) in "Body Text", or numbered in "Allegation" (the number,
-- a tab to the number box's end); a paragraph that carries a footnote mark in the "Note" twin (no widow control).
local function body_par(num, inlines)
  local style = num and "Allegation" or "Body Text"
  if has_note(inlines) then style = style .. " Note" end
  local content = pandoc.Inlines({})
  if num then content:insert(pandoc.RawInline("openxml", xe.runs(num .. ".\t"))) end
  content:extend(inlines)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

local function heading(inlines)
  return p(xe.inl(inlines, { b = true }), { before = SINGLE, after = SINGLE, jc = "center", keep = true })
end

local function is_wherefore(b)
  local first = b.content[1]
  return first ~= nil and first.t == "Str" and first.text:match("^WHEREFORE") ~= nil
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local m = doc.meta
  -- the break rules on the body only: the frontmatter goes through xe.inl, which applies them itself
  doc = pandoc.Pandoc(doc.blocks):walk({ Inlines = xe.inlines })
  local out = {}

  for _, l in ipairs(m.court or {}) do out[#out + 1] = p(xe.inl(upper(l)), { jc = "center", keep = true }) end
  for i, blk in ipairs(m.caption or {}) do out[#out + 1] = caption_table(blk, i == 1 and BODY or SINGLE) end
  -- Word has no space after a table: the title takes the space above it
  out[#out + 1] = p(xe.inl(upper(m.title), { b = true }), { before = BODY, after = SINGLE, jc = "center", keep = true })

  if m.lead_in then out[#out + 1] = body_par(nil, xe.inlines(m.lead_in)) end
  local n = 0
  if m.consent then
    n = n + 1
    out[#out + 1] = body_par(n, xe.inlines(m.consent))
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b.content)
    elseif b.t == "Para" and is_wherefore(b) then
      out[#out + 1] = body_par(nil, b.content)
    elseif b.t == "Para" then
      n = n + 1
      out[#out + 1] = body_par(n, b.content)
    else
      error("alnb.lua: unsupported block " .. b.t)
    end
  end
  if m.signature then signature(m.signature, out) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
