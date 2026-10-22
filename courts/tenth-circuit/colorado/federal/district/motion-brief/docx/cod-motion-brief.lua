-- D. Colo. motion to dismiss with its memorandum, docx engine (docs/DOCX.md): the same markdown contract as
-- typst/cod-motion-brief.typ, and every block written as it sets it: the caption (the court in two centered bold
-- lines, "Civil Action No.", the parties with "v." between them, the title; Fed. R. Civ. P. 10(a)), the lead-in, the
-- certificate of conferral the sample supplies (LCivR 7.1(a)), the body (sections numbered by the template: I.
-- centered capitals; A., 1., a. with the label in a half-inch box; paragraphs with their native footnotes, which
-- pandoc writes in the styles of reference.xml; block quotations), the signature block (LCivR 5.1; Fed. R. Civ. P.
-- 11(a)) and the certificate of service (Fed. R. Civ. P. 5(b)). Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, LCivR 10.1(e); 276 a single
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, designation-indent, service-indent
local LABEL = 720                                      -- typst heading-label, 0.5 in
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

-- The last paragraph of a kept chain ends it.
local function unkeep(out)
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
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
  unkeep(out)
  return out
end

-- A centered bold heading of the paper's own (a certificate): single-spaced, a single line below, kept with the text.
local function title(text, before)
  return p(xe.inl(text, { b = true }), { jc = "center", keep = true, before = before, after = SINGLE })
end

-- A paragraph at the double pitch, indented, written here (no footnotes).
local function body_par(inlines, before, keep)
  return p(xe.inl(inlines), { line = BODY, first = INDENT, before = before or 0, keep = keep })
end

-- ---------------------------------------------------------------------------
-- Signature, a double line below the body: the intro lines at the margin; each signer a blank line below, "s/ Name"
-- (or sig_line), the name and the contact lines; a blank line and the role; the signer and role lines 3 in from the
-- margin. Kept whole.
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
  unkeep(out)
  return out
end

-- Certificate of service, a double line below the signature: the heading, the text at the double pitch, the party
-- lines half an inch in a single line below it, and a double line below them the signer's lines 3 in in. Kept whole.
local function service(s)
  local out = { title(s.heading and stringify(s.heading) or "CERTIFICATE OF SERVICE", BODY),
    body_par(s.text, 0, true) }
  for k, l in ipairs(list(s.party_lines)) do
    out[#out + 1] = p(xe.inl(l), { left = INDENT, keep = true, before = k == 1 and SINGLE or 0 })
  end
  for k, l in ipairs(list(s.signer_lines)) do
    out[#out + 1] = p(xe.inl(l), { left = SIG_LEFT, keep = true, before = k == 1 and BODY or 0 })
  end
  unkeep(out)
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Section headings numbered as typst: level 1 "I.", level 2 "A.", level 3 "1.", level 4 "a.".
local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return s
end
local MARKS = {
  function(n) return roman(n) .. "." end,
  function(n) return string.char(64 + n) .. "." end,
  function(n) return tostring(n) .. "." end,
  function(n) return string.char(96 + n) .. "." end,
}

-- Headings single-spaced, a single line above and below, kept with the text: level 1 centered bold capitals; deeper
-- levels bold, the label in a half-inch box (a tab) and the title hanging after it, level 2 at the margin and each
-- level after it half an inch further in.
local function heading(lvl, mark, el, before)
  local content = el.content
  if lvl == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return p(xe.runs(mark .. " ", { b = true }) .. xe.inl(content, { b = true }),
      { style = "Heading1", keep = true, before = before, after = SINGLE, jc = "center" })
  end
  local left = (lvl - 1) * LABEL
  return p(xe.runs(mark .. "\t", { b = true }) .. xe.inl(content, { b = true }),
    { style = "Heading" .. lvl, keep = true, before = before, after = SINGLE, left = left, hanging = LABEL,
      tab = left })
end

-- A block quotation: its paragraphs single-spaced, 1 in in on both sides, a single line above, below and between.
local function quotation(b, keep)
  local out = {}
  for k, q in ipairs(b.content) do
    if q.t ~= "Para" and q.t ~= "Plain" then error("cod-motion-brief.lua: a quotation holds paragraphs only") end
    local last = k == #b.content
    out[#out + 1] = p(xe.inl(q.content), { left = QUOTE, right = QUOTE, before = SINGLE,
      after = last and SINGLE or 0, keep = keep and last })
  end
  return out
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
-- A hyphen before a digit is bound by a word joiner, not by xengine's Word non-breaking hyphen: LibreOffice sets
-- that from another glyph that Liberation Sans' PDF text drops ("1:26-cv02065").
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1"):gsub("%-(%d)", "-\u{2060}%1")))
end

-- A section sign or pilcrow and the token after it are one box in typst ("§ 18–3–206"): no break after a dash or a
-- slash inside that token either (word joiners).
local function bind_sign_tokens(l)
  for i = 1, #l - 2 do
    if l[i].t == "Str" and l[i].text:match("[§¶]$") and l[i + 1].t == "Space" and l[i + 2].t == "Str" then
      l[i + 2] = pandoc.Str((l[i + 2].text:gsub("–", "–\u{2060}"):gsub("—", "—\u{2060}"):gsub("/", "/\u{2060}")))
    end
  end
  return l
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

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

function Pandoc(doc)
  doc = doc:walk({ Inlines = bind_sign_tokens }):walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
    :walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local out = {}
  local function raw(x) out[#out + 1] = xe.raw(x) end
  for _, x in ipairs(caption(meta)) do raw(x) end
  -- the opening paragraph a double line below the caption, then the certificate of conferral
  local opened = false
  if meta.lead_in then
    raw(body_par(meta.lead_in, BODY))
    opened = true
  end
  if meta.conferral then
    raw(title(meta.conferral_heading and stringify(meta.conferral_heading) or "CERTIFICATE OF COMPLIANCE",
      opened and SINGLE or BODY))
    raw(body_par(meta.conferral))
    opened = true
  end
  local blocks = doc.blocks
  local sec = { 0, 0, 0, 0 }
  for i, b in ipairs(blocks) do
    -- the body a double line below the caption (when nothing opened it); the last block stays whole with the
    -- signature block
    local first, last = i == 1 and not opened, i == #blocks
    if b.t == "Header" then
      local lvl = math.min(b.level, 4)
      sec[lvl] = sec[lvl] + 1
      for k = lvl + 1, 4 do sec[k] = 0 end
      raw(heading(lvl, MARKS[lvl](sec[lvl]), b, first and BODY or SINGLE))
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(quotation(b, last)) do raw(x) end
    elseif b.t == "Para" or b.t == "Plain" then
      local style = last and "Body Text Keep" or first and "Body Text First" or has_note(b.content) and
        "Body Text Note" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    else
      error("cod-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  for _, x in ipairs(signature(meta.signature)) do raw(x) end
  if meta.service then
    for _, x in ipairs(service(meta.service)) do raw(x) end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
