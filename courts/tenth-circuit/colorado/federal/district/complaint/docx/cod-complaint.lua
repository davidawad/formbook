-- D. Colo. complaint, docx engine (docs/DOCX.md): the same markdown contract as typst/cod-complaint.typ, and every
-- block written as it sets it: the caption (the court in two centered bold lines, "Civil Action No.", the parties
-- with "v." between them, the title; Fed. R. Civ. P. 10(a)), the lead-in, the headings, the numbered paragraphs
-- (Fed. R. Civ. P. 10(b)), the unnumbered paragraphs ("~ "), the block quotations, the prayer lettered A., B., ...
-- and the signature block (LCivR 5.1; Fed. R. Civ. P. 11(a)). Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, LCivR 10.1(e); 276 a single
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, designation-indent, list-indent: 0.5 in
local LABEL = 720                                      -- typst list-label, 0.5 in
local QUOTE = 1440                                     -- typst quote-indent, 1 in on each side
local SIG_LEFT = 4320                                  -- typst signature-indent, 3 in

local stringify = pandoc.utils.stringify

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- ---------------------------------------------------------------------------
-- Caption: the court in two centered bold lines; a double line below them "Civil Action No."; a double line below
-- that the parties (names, a blank line, the designation half an inch in; "v." between them with a blank line on
-- each side); a double line below them the title, centered and bold. Kept whole.
-- ---------------------------------------------------------------------------

local function caption(meta)
  local out = {}
  local function add(body, o)
    o = o or {}
    o.keep = true
    out[#out + 1] = p(body, o)
  end
  add(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
  add(xe.runs("FOR THE DISTRICT OF COLORADO", { b = true }), { jc = "center" })
  local cn = meta.case_number and stringify(meta.case_number) or ""
  if cn == "" then cn = string.rep("_", 18) end
  add(xe.runs("Civil Action No. " .. cn), { before = BODY })
  for k, party in ipairs(list(meta.caption)) do
    if k > 1 then
      add("")
      add(xe.runs("v."))
      add("")
    end
    for j, n in ipairs(list(party.names)) do add(xe.inl(n), { before = (k == 1 and j == 1) and BODY or 0 }) end
    add("")
    add(xe.inl(party.designation), { left = INDENT })
  end
  add(xe.inl(meta.title, { b = true }), { jc = "center", before = BODY })
  -- the title ends the chain
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature, a double line below the body: the intro lines at the margin; a blank line and the firm; each signer a
-- blank line below, "s/ Name" (or sig_line), the name and the contact lines; a blank line and the role; the firm,
-- signer and role lines 3 in from the margin. Kept whole.
-- ---------------------------------------------------------------------------

local function signature(sig)
  local out = {}
  local function line(body, left)
    out[#out + 1] = p(body, { left = left or 0, keep = true, before = #out == 0 and BODY or 0 })
  end
  for _, l in ipairs(list(sig.intro)) do line(xe.inl(l)) end
  if sig.firm then
    line("")
    line(xe.inl(sig.firm), SIG_LEFT)
  end
  for _, s in ipairs(list(sig.signers)) do
    line("")
    if s.sig_line then line(xe.inl(s.sig_line), SIG_LEFT) else line(xe.runs("s/ ") .. xe.inl(s.name), SIG_LEFT) end
    line(xe.inl(s.name), SIG_LEFT)
    for _, l in ipairs(list(s.lines)) do line(xe.inl(l), SIG_LEFT) end
  end
  if sig.role then
    line("")
    line(xe.inl(sig.role), SIG_LEFT)
  end
  -- the last line ends the chain
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines)
  local q = { line = BODY, first = INDENT }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings single-spaced, a single line above and below, kept with the text: level 1 centered bold capitals, level 2
-- centered bold, level 3 bold italic at the margin.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return p(xe.inl(content, { b = true, i = lvl == 3 }), { style = "Heading" .. lvl, keep = true, before = SINGLE,
    after = SINGLE, jc = lvl < 3 and "center" or "left" })
end

-- A block quotation: its paragraphs single-spaced, 1 in in on both sides, a single line above, below and between.
local function quotation(b)
  local out = {}
  for k, q in ipairs(b.content) do
    if q.t ~= "Para" and q.t ~= "Plain" then error("cod-complaint.lua: a quotation holds paragraphs only") end
    out[#out + 1] = p(xe.inl(q.content), { left = QUOTE, right = QUOTE, before = SINGLE,
      after = k == #b.content and SINGLE or 0 })
  end
  return out
end

-- Prayer items A., B., ... by their number.
local function letter(i)
  if i <= 26 then return string.char(64 + i) .. "." end
  return string.char(64 + (i - 1) // 26) .. string.char(65 + (i - 1) % 26) .. "."
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

local function unnumbered(b)
  return (b.t == "Para" or b.t == "Plain") and b.content[1] and b.content[1].t == "Str" and b.content[1].text == "~"
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local meta = doc.meta
  local out = caption(meta)
  local start = #out + 1
  local n = 0
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in) end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(quotation(b)) do out[#out + 1] = x end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local k = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("cod-complaint.lua: a list item holds one paragraph")
        end
        local lab = b.t == "OrderedList" and letter(k) or "\u{2022}"
        out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
          { line = BODY, left = INDENT + LABEL, hanging = LABEL, tab = INDENT + LABEL })
        k = k + 1
      end
    elseif unnumbered(b) then
      -- the "~" marker and the space after it dropped
      out[#out + 1] = body_par(nil, pandoc.Inlines({ table.unpack(b.content, 3) }))
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(n .. ".", b.content)
    else
      error("cod-complaint.lua: unsupported block " .. b.t)
    end
  end
  -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
  if #out >= start and not out[#out]:find("<w:keepNext/>", 1, true) then
    out[#out] = out[#out]:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1)
  end
  -- the body a double line below the caption
  if out[start] then
    out[start] = out[start]:gsub('w:before="%d+"', 'w:before="' .. BODY .. '"', 1)
  end
  for _, x in ipairs(signature(meta.signature)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
