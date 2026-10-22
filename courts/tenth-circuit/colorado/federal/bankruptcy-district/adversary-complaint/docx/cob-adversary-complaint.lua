-- Bankr. D. Colo. adversary complaint, docx engine (docs/DOCX.md): the same markdown contract as
-- typst/cob-adversary-complaint.typ, and every block written as it sets it: the court title, the caption (the debtor
-- block and the adversary block, each the party column beside the case column; FRBP 7010, Official Form 416D), the
-- title, the generated FRBP 7008 consent statement (numbered paragraph 1), the numbered allegations (FRCP 10(b) via
-- FRBP 7010), "^" unnumbered paragraphs, "~ " centered sub-captions, the headings, the lettered or bulleted lists, the
-- quotations and the signature block (FRBP 9011(a), LBR 9011-4). Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file. The caption blocks and the signature are OOXML tables of one
-- row that is never split.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, list-indent, quote-indent: 0.5 in
local LABEL = 576                                      -- typst list-label, 0.4 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_RIGHT, CAP_GUTTER = 3744, 432                -- typst caption-right (2.6 in), caption-gutter (0.3 in)
local NAME, DESIGNATION = 576, 1152                    -- typst name-indent (0.4 in), designation-indent (0.8 in)
local SIG_COL = 4608                                   -- typst signature-column, 3.2 in
local FILL = 18                                        -- typst fill-line

local stringify = pandoc.utils.stringify

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table without cell margins that is never split: widths in twips, cells = { { paragraphs } }.
local function tbl(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(cells[i]) ..
      '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("cob-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function upper(v)
  return pandoc.Inlines(v):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Caption: the court title, a single line below it the debtor block, a single line below that the adversary block,
-- and the title a single line above and below (an empty single line between the two tables keeps them apart).
-- ---------------------------------------------------------------------------

local function caption_block(left, right)
  return tbl({ TEXTW - CAP_RIGHT - CAP_GUTTER, CAP_GUTTER, CAP_RIGHT }, { left, { p("") }, right })
end

local function caption(meta)
  local out = {}
  local court = list(need(meta, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true, after = i == #court and SINGLE or 0 })
  end
  local d = need(meta, "debtor")
  local left = { p(xe.runs("IN RE:")), p("") }
  for _, n in ipairs(list(d.names)) do left[#left + 1] = p(xe.inl(n), { left = NAME }) end
  left[#left + 1] = p("")
  left[#left + 1] = p(d.designation and xe.inl(d.designation) or xe.runs("Debtor."), { left = DESIGNATION })
  local right = { p(xe.runs("Case No. ") .. xe.inl(d.case_number)) }
  if d.chapter then right[#right + 1] = p(xe.inl(d.chapter)) end
  out[#out + 1] = caption_block(left, right)
  out[#out + 1] = p("")
  local adv = need(meta, "adversary")
  left = {}
  for i, side in ipairs(list(adv.parties)) do
    if i > 1 then left[#left + 1] = p("") end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
  end
  local num = adv.case_number and stringify(adv.case_number) or ""
  if num == "" then num = string.rep("_", FILL) end
  out[#out + 1] = caption_block(left, { p(xe.runs("Adv. Proc. No. " .. num)) })
  out[#out + 1] = p(xe.inl(need(meta, "title"), { b = true }), { jc = "center", before = SINGLE, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- The FRBP 7008 statement, from `proceeding` and `consent` (typst consent-text)
-- ---------------------------------------------------------------------------

local function consent(meta)
  local kind = stringify(need(meta, "proceeding")) == "core" and "a core proceeding" or "a non-core proceeding"
  local c = stringify(need(meta, "consent"))
  local x = xe.runs("This proceeding is " .. kind .. " under 28 U.S.C. §\u{00A0}157. ")
  if c == "missing" then
    return x .. xe.runs("[FRBP 7008(a) CONSENT STATEMENT ABSENT FROM THE FILED COMPLAINT]", { b = true })
  end
  return x .. xe.runs("Plaintiff " .. c .. " to the entry of final orders or judgment by the bankruptcy judge.")
end

-- ---------------------------------------------------------------------------
-- Signature: a double line below the body, "Dated:" at the left margin, the signatories in a column at the right, a
-- double line between them; one row, never split.
-- ---------------------------------------------------------------------------

local function sig_column(s, out, before)
  local first = #out + 1
  for _, l in ipairs(list(s.firm)) do out[#out + 1] = p(xe.inl(l)) end
  if #out >= first then out[#out + 1] = p("") end
  local mark = s.mark and stringify(s.mark) or "/s/"
  if mark == "/s/" or mark:sub(1, 7) == "By: /s/" then
    out[#out + 1] = p(xe.inl(s.mark or "/s/") .. xe.runs(" ") .. xe.inl(s.signer))
  else
    out[#out + 1] = p(xe.inl(s.mark))
    out[#out + 1] = p(xe.inl(s.signer))
  end
  for _, l in ipairs(list(s.lines)) do out[#out + 1] = p(xe.inl(l)) end
  if before then out[first] = out[first]:gsub('w:before="0"', 'w:before="' .. before .. '"', 1) end
end

local function signature(meta)
  local s = need(meta, "signature")
  local right = {}
  if s.lead ~= false then
    right[#right + 1] = p(xe.runs("Respectfully submitted,"))
    right[#right + 1] = p("")
  end
  sig_column(s, right)
  for _, extra in ipairs(list(s.also)) do sig_column(extra, right, BODY) end
  return tbl({ TEXTW - SIG_COL, SIG_COL }, { { p(xe.runs("Dated: ") .. xe.inl(need(meta, "date"))) }, right })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, runs, keep)
  local q = { line = BODY, first = INDENT, keep = keep }
  if label == nil then return p(runs, q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. runs, q)
end

-- Headings single-spaced, a single line above and below, kept with the text: level 1 centered bold capitals, deeper
-- levels bold at the margin.
local function heading(el)
  if el.level == 1 then
    return p(xe.inl(upper(el.content), { b = true }), { before = SINGLE, after = SINGLE, keep = true, jc = "center" })
  end
  return p(xe.inl(el.content, { b = true }), { before = SINGLE, after = SINGLE, keep = true })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number, as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- The paragraph's marker ("^" or "~"): the inlines without it, or nil.
local function marked(b, ch)
  if (b.t ~= "Para" and b.t ~= "Plain") or not b.content[1] or b.content[1].t ~= "Str" then return nil end
  local s = b.content[1].text
  if s:sub(1, #ch) ~= ch then return nil end
  local rest = pandoc.Inlines({ table.unpack(b.content, 2) })
  if #s > #ch then
    rest:insert(1, pandoc.Str(s:sub(#ch + 1)))
  elseif rest[1] and rest[1].t == "Space" then
    rest:remove(1)
  end
  return rest
end

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

local function body(meta, blocks)
  local out = {}
  local n = 0
  local consent_done = false
  for k, b in ipairs(blocks) do
    -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
    local last = k == #blocks
    -- the FRBP 7008(a) statement is paragraph 1: after the unnumbered opening, before the first other block
    if not consent_done and not marked(b, "^") then
      consent_done = true
      n = n + 1
      out[#out + 1] = body_par(n .. ".", consent(meta))
    end
    local un, sub = marked(b, "^"), marked(b, "~")
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif sub then
      -- centered single lines, one per source line, kept with the text after them, a single line below
      local lines = { pandoc.Inlines({}) }
      for _, el in ipairs(sub) do
        if el.t == "SoftBreak" or el.t == "LineBreak" then lines[#lines + 1] = pandoc.Inlines({})
        else lines[#lines]:insert(el) end
      end
      for i, l in ipairs(lines) do
        out[#out + 1] = p(xe.inl(l), { jc = "center", keep = true, after = i == #lines and SINGLE or 0 })
      end
    elseif un then
      out[#out + 1] = body_par(nil, xe.inl(un), last)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("cob-adversary-complaint.lua: a list item holds one paragraph")
        end
        local lab = b.t == "BulletList" and "\u{2022}" or "(" .. LETTERS:sub(i, i) .. ")"
        out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = INDENT + LABEL,
          hanging = LABEL, tab = INDENT + LABEL, keep = last and i == #b.content })
      end
    elseif b.t == "BlockQuote" then
      -- single-spaced, half an inch in on both sides, a single line above and below
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("cob-adversary-complaint.lua: a quotation holds paragraphs") end
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT, before = SINGLE, after = SINGLE,
          keep = last })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(n .. ".", xe.inl(b.content), last)
    else
      error("cob-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  if not consent_done then
    n = n + 1
    out[#out + 1] = body_par(n .. ".", consent(meta), true)
  end
  -- the signature block a double line below the body (the last paragraph's space after: a table has none above)
  out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. BODY .. '"', 1)
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtor", "adversary", "title", "proceeding", "consent", "signature", "date" }) do
    need(meta, k)
  end
  local blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = caption(meta)
  for _, x in ipairs(body(meta, blocks)) do out[#out + 1] = x end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
