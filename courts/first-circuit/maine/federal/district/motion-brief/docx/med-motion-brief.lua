-- med-motion-brief.lua (docx engine): the D. Me. motion to dismiss with incorporated memorandum of law as Word
-- paragraphs and a caption table, so that it reads and breaks as typst/med-motion-brief.typ does:
--   * the cover: court name, the caption table (the party block closed by a rule at its right and bottom, "v."
--     between parties, the designation set in from the names; "Civil Action No." and the case number at the right,
--     in the middle rows of the party block), the title of the motion in bold capitals;
--   * the body: unnumbered double-spaced paragraphs with a first-line indent and their footnotes, headings (level 1
--     centered bold capitals, level 2 bold, level 3 underlined, both hanging half an inch), single-spaced block
--     quotations;
--   * the signature block (the date at the margin, the signer's lines from 3 inches), kept on the page of the last
--     paragraph; the certificate of service when the sample has one.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs stay
-- pandoc paragraphs (style "Body Text", or "Body Text Note" in reference.xml), so pandoc writes their footnotes.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276             -- typst pitch-double, pitch-single
local INDENT = 720                        -- typst para-indent, quote-indent: 0.5 in
local TEXTW = 9360                        -- 6.5 in
local PARTY_W = 4896                      -- typst caption-left 3.4 in
local PARTY_PAD = 240                     -- typst caption-pad 12 pt
local PARTY_FOOT = 145                    -- typst caption-foot 8 pt less the rule (0.75 pt), which LibreOffice adds to the row
local CASE_LEFT = 576                     -- typst caption-gap + case-indent, 0.4 in
local RULE_W = 2304                       -- typst rule-w 1.6 in
local DESIGNATION = 2160                  -- typst designation-indent 1.5 in
local SIG_LEFT = 4320                     -- typst date-w 3.0 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

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

local function tab(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

local function upper(m)
  return pandoc.Inlines(m):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Cover (LR 10(a); Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  -- the caption a double line below the court name (typst: the caption block's above; the space goes after the
  -- court name, as LibreOffice sets no space before a table)
  local court = { "UNITED STATES DISTRICT COURT", "DISTRICT OF MAINE" }
  for i, l in ipairs(court) do
    out[#out + 1] = xe.raw(p(xe.runs(l, { b = true }), { jc = "center", keep = true, after = i == #court and BODY or 0 }))
  end
  -- the party block, one paragraph per entry
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIGNATION })
  end
  -- the case number, or the label and a blank rule for the clerk, in the middle rows of the party column (typst:
  -- counted by entries)
  local right = {}
  local case_no = plain(meta.case_number)
  local skip = math.max(0, math.floor((#left - (case_no == "" and 2 or 1)) / 2)) * SINGLE
  if case_no == "" then
    right[#right + 1] = p(xe.runs("Civil Action No."), { before = skip })
    -- an underlined tab to rule-w: a line of its own at the single pitch (typst: a box with a rule at its foot)
    right[#right + 1] = p(xe.runs("\t", { u = true }), { tabs = tab(RULE_W) })
  else
    right[#right + 1] = p(xe.runs("Civil Action No. ") .. xe.inl(meta.case_number), { before = skip })
  end
  local rw = TEXTW - PARTY_W
  out[#out + 1] = xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. PARTY_W .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. PARTY_W .. '" w:type="dxa"/><w:tcBorders>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. PARTY_FOOT .. '" w:type="dxa"/><w:right w:w="' .. PARTY_PAD .. '" w:type="dxa"/></w:tcMar>' ..
    '</w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. rw .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CASE_LEFT .. '" w:type="dxa"/></w:tcMar>' ..
    '</w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>')
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = xe.raw(p(xe.inl(upper(meta.title), { b = true }), { before = BODY, jc = "center", keep = true }))
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings, single-spaced at the type size, a single line above, kept with the text after them: level 1 centered
-- bold capitals, level 2 bold, level 3 underlined; levels 2 and 3 hang half an inch.
local function heading(el)
  local content, o, hang = el.content, { b = true }, INDENT
  if el.level == 1 then content, hang = upper(content), nil elseif el.level >= 3 then o = { u = true } end
  return xe.raw(xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(SINGLE, 0, SINGLE),
    xe.ind(hang or 0, hang, not hang and 0 or nil), xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, o)))
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

-- Paragraphs of a quotation: a list item becomes a paragraph that starts with its marker (pandoc reads "(1) ..."
-- as a list item; commonmark, and so typst, keeps it as typed).
local function flatten(list)
  local out = {}
  for _, b in ipairs(list) do
    if b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        for k, ib in ipairs(flatten(item)) do
          local c = pandoc.Inlines(ib.content)
          if k == 1 then c:insert(1, pandoc.Space()); c:insert(1, pandoc.Str(marker(b.listAttributes, b.listAttributes.start + i - 1))) end
          out[#out + 1] = pandoc.Para(c)
        end
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = b
    else
      error("med-motion-brief.lua: unsupported block in a quotation " .. b.t)
    end
  end
  return out
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A body paragraph. One with a footnote mark: pandoc writes it (and its notes) in "Body Text Note" (Body Text
-- without widow control) from `walked`, the inlines with the break rules applied. Any other is written here from
-- `raw` (xe.inl applies the break rules itself), with its own spacing: `before` above it, and `keep` with the next
-- (the first paragraph a single line under the title; the last one kept with the signature).
local function body_par(raw, walked, before, keep)
  if has_note(raw) then
    return pandoc.Div({ pandoc.Para(walked) }, { ["custom-style"] = "Body Text Note" })
  end
  return xe.raw(p(xe.inl(raw), { line = BODY, first = INDENT, before = before, keep = keep }))
end

-- The signature lines: the date at the margin with the /s/ line at 3 inches, the rest of the block under it.
local function signature(meta, out)
  local sig = meta.signature
  local lines = { { body = xe.runs("Dated: ") .. xe.inl(meta.date) .. xe.runs("\t/s/ ") .. xe.inl(sig.signer),
    o = { before = BODY, tabs = tab(SIG_LEFT) } } }
  for _, l in ipairs(sig.lines) do lines[#lines + 1] = { body = xe.inl(l), o = { left = SIG_LEFT } } end
  return lines
end

local function chain(lines, out, last_keep)
  for i, l in ipairs(lines) do
    l.o.keep = i < #lines or last_keep
    out[#out + 1] = xe.raw(p(l.body, l.o))
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 10"), as the typst template boxes it (xe.inl binds a single sign).
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
  -- the break rules on the body only: the frontmatter goes through xe.inl, which applies them itself
  local walked = pandoc.Pandoc(doc.blocks):walk({ Inlines = xe.inlines }).blocks
  local out = {}
  cover(meta, out)
  local n = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content, walked[i].content, i == 1 and SINGLE or 0, i == n)
    elseif b.t == "BlockQuote" then
      -- single-spaced, indented both sides, a single line off the text above and below
      local qs = flatten(b.content)
      for k, q in ipairs(qs) do
        out[#out + 1] = xe.raw(p(xe.inl(q.content), { left = INDENT, right = INDENT,
          before = k == 1 and SINGLE or 0, after = k == #qs and SINGLE or 0, keep = i == n }))
      end
    else
      error("med-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  chain(signature(meta, out), out, false)
  -- the certificate of service, when the sample has one: kept together, a double line below the signature
  if meta.certificate ~= nil and plain(meta.certificate) ~= "" then
    local cert = pandoc.read(plain(meta.certificate), "markdown+smart").blocks
    local lines = { { body = xe.runs("CERTIFICATE OF SERVICE", { b = true }), o = { before = BODY, jc = "center" } } }
    for k, cb in ipairs(cert) do
      lines[#lines + 1] = { body = xe.inl(cb.content), o = { line = BODY, first = INDENT, before = k == 1 and SINGLE or 0 } }
    end
    for _, l in ipairs(signature(meta, out)) do lines[#lines + 1] = l end
    chain(lines, out, false)
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
