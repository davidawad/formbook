-- med-complaint.lua (docx engine): the D. Me. complaint as Word paragraphs and a caption table, so that it reads and
-- breaks as typst/med-complaint.typ does:
--   * the cover: court name, the caption table (the party block closed by a rule at its right and bottom, "v."
--     between parties, the designation set in from the names; "Civil Action No." at the right, centered on it, a
--     blank for the clerk when there is no case number), the title in bold capitals and its subtitle;
--   * the body: each paragraph numbered 1, 2 ... (Fed. R. Civ. P. 10(b)) unless it starts with "~ " (the marker is
--     dropped); headings; the prayer lettered A., B. ...; single-spaced block quotations;
--   * the signature block: the date at the margin, the signer's lines from 3 inches, kept on the page of the last
--     paragraph.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276             -- typst pitch-double, pitch-single
local INDENT = 720                        -- typst para-indent, item-indent, item-label, quote-indent: 0.5 in
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
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true, after = i == #court and BODY or 0 })
  end
  -- the party block, one paragraph per line
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
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
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
    '</w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { before = BODY, jc = "center", keep = true })
  if plain(meta.subtitle) ~= "" then
    out[#out + 1] = p(xe.inl(meta.subtitle), { jc = "center", keep = true })
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings, single-spaced at the type size: level 1 centered bold capitals a single line below the text, level 2
-- centered bold right under it, level 3 bold italic at the left; kept with the text after them.
local function heading(el)
  local content, o = el.content, { b = true }
  if el.level == 1 then content = upper(content) elseif el.level >= 3 then o.i = true end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(el.level == 2 and 0 or SINGLE, 0, SINGLE),
    xe.ind(0, nil, 0), xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, o))
end

-- A paragraph that starts with "~ " is not numbered; the marker is dropped.
local function tilde(b)
  local c = b.content
  if c[1] and c[1].t == "Str" and c[1].text == "~" then
    local rest = pandoc.Inlines({})
    for j = 2, #c do
      if not (j == 2 and c[j].t == "Space") then rest:insert(c[j]) end
    end
    return rest
  end
  return nil
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

-- Paragraphs of a quotation: a list item becomes a paragraph that starts with its marker.
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
      error("med-complaint.lua: unsupported block in a quotation " .. b.t)
    end
  end
  return out
end

-- Each block as a list of paragraph specs { body, o }: the last block is kept with the signature.
local function blocks(doc)
  local res = {}
  local n = 0
  local function add(body, o) res[#res + 1] = { body = body, o = o } end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      res[#res + 1] = { xml = heading(b) }
    elseif b.t == "Para" or b.t == "Plain" then
      local rest = tilde(b)
      if rest then
        add(xe.inl(rest), { line = BODY, first = INDENT })
      else
        -- the number in a box of para-indent after the first-line indent (typst: box(width: para-indent))
        n = n + 1
        add(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tabs = tab(2 * INDENT) })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- the prayer, lettered A., B. ...: the letter half an inch in, the text hanging after it at 1 inch
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and (b.t == "OrderedList" and (string.char(64 + j) .. ".\t") or "\u{2022}\t") or ""
          add(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
        end
      end
    elseif b.t == "BlockQuote" then
      -- single-spaced, indented both sides, a single line off the text above and below
      local qs = flatten(b.content)
      for k, q in ipairs(qs) do
        add(xe.inl(q.content), { left = INDENT, right = INDENT,
          before = k == 1 and SINGLE or 0, after = k == #qs and SINGLE or 0 })
      end
    else
      error("med-complaint.lua: unsupported block " .. b.t)
    end
  end
  return res
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
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  local body = blocks(doc)
  -- the text a single line under the title
  if body[1] and body[1].o then body[1].o.before = math.max(body[1].o.before or 0, SINGLE) end
  -- the last paragraph and the signature block never break across a page (typst: one unbreakable block)
  local sig = meta.signature
  local tail = { { body = xe.runs("Dated: ") .. xe.inl(meta.date) .. xe.runs("\t/s/ ") .. xe.inl(sig.signer),
    o = { before = BODY, tabs = tab(SIG_LEFT) } } }
  for _, l in ipairs(sig.lines) do tail[#tail + 1] = { body = xe.inl(l), o = { left = SIG_LEFT } } end
  for i, b in ipairs(body) do
    if b.xml then
      out[#out + 1] = b.xml
    else
      if i == #body then b.o.keep = true end
      out[#out + 1] = p(b.body, b.o)
    end
  end
  for i, b in ipairs(tail) do
    b.o.keep = i < #tail
    out[#out + 1] = p(b.body, b.o)
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
