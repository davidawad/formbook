-- gand-complaint.lua: pandoc filter for the N.D. Ga. complaint, docx engine (docs/DOCX.md), so that it reads and
-- breaks as typst/gand-complaint.typ does: the court title, the caption table, the title of the paper, the numbered
-- paragraphs (Fed. R. Civ. P. 10(b)), the unnumbered "~ " paragraphs, the lettered prayer items, the headings and the
-- signature block. Rules: N.D. Ga. LR 5.1(C), (D), (E), (G), (J), (K); Fed. R. Civ. P. 10(a), 10(b).
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs stay
-- pandoc paragraphs (style Body Text), so their footnotes are Word footnotes (style Footnote Text).

local xe = require("docx.xengine")

local BODY, SINGLE = 644, 322          -- typst pitch-body, pitch-single
local INDENT = 720                     -- typst para-indent, number-box and list-indent, 0.5 in
local TEXTW = 9360                     -- 6.5 in
local PARTY_W, PAREN_W = 4608, 504     -- typst caption-party-w 3.2 in, caption-paren-w 0.35 in
local DESIGNATION = 2160               -- typst designation-indent 1.5 in
local SIG_LEFT, SIG_GAP = 3888, 80     -- typst sig-left 2.7 in, sig-gap 4 pt

local function need(meta, key)
  if meta[key] == nil then error("gand-complaint: frontmatter field `" .. key .. "` is required") end
  return meta[key]
end

local function str(m) return pandoc.utils.stringify(m) end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Cover: the court title, the caption, the title of the paper (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

-- The caption: party lines on the left, a column of ")" marks, the case number on the middle row and the jury
-- demand two rows below it; every row one single line (typst: caption()).
local function caption(meta)
  local lines = {}
  for k, party in ipairs(need(need(meta, "caption"), "parties")) do
    if k > 1 then lines[#lines + 1] = { "v.", 0 } end
    for _, n in ipairs(need(party, "names")) do lines[#lines + 1] = { n, 0 } end
    lines[#lines + 1] = { need(party, "designation"), DESIGNATION }
  end
  local case_no = (meta.case_number and str(meta.case_number) ~= "") and str(meta.case_number) or "______________"
  local mid = (#lines - 1) // 2
  local right = { [mid] = "Civil Action No. " .. case_no }
  local rows = math.max(#lines, mid + 1)
  if meta.jury_demand then
    right[mid + 2] = "JURY TRIAL DEMANDED"
    rows = math.max(rows, mid + 3)
  end
  local function cell(w, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
  end
  local out = {}
  for i = 1, rows do
    local l = lines[i]
    out[#out + 1] = '<w:tr><w:trPr><w:trHeight w:val="' .. SINGLE .. '" w:hRule="exact"/></w:trPr>' ..
      cell(PARTY_W, p(l and xe.inl(l[1]) or "", { left = l and l[2] or 0 })) ..
      cell(PAREN_W, p(l and xe.runs(")") or "")) ..
      cell(TEXTW - PARTY_W - PAREN_W, p(right[i - 1] and xe.runs(right[i - 1]) or "")) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. PARTY_W .. '"/><w:gridCol w:w="' .. PAREN_W .. '"/><w:gridCol w:w="' ..
    (TEXTW - PARTY_W - PAREN_W) .. '"/></w:tblGrid>' .. table.concat(out) .. '</w:tbl>'
end

local function cover(meta, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE NORTHERN DISTRICT OF GEORGIA", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs(str(need(meta, "division")):upper() .. " DIVISION", { b = true }),
    { jc = "center", after = SINGLE })
  out[#out + 1] = caption(meta)
  -- Word has no space after a table: the title takes the caption's space before it
  out[#out + 1] = p(xe.runs(str(need(meta, "title")):upper(), { b = true }),
    { jc = "center", before = SINGLE, after = SINGLE })
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 5.1(G): name, complete address, telephone, email and bar number on every document);
-- every line kept with the next (typst: one unbreakable block).
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local s = need(meta, "signature")
  local attorneys = need(s, "attorneys")
  assert(#attorneys > 0, "gand-complaint: LR 5.1(G) needs at least one attorney block")
  for _, a in ipairs(attorneys) do
    for _, k in ipairs({ "name", "bar", "email" }) do
      if a[k] == nil then error("gand-complaint: LR 5.1(G) needs `" .. k .. "` for every attorney") end
    end
  end
  local lines = { { xe.runs("Dated: " .. str(need(meta, "date"))), BODY, 0 },
    { xe.runs("/s/ " .. str(need(s, "signer"))), BODY, SIG_LEFT } }
  for _, a in ipairs(attorneys) do
    lines[#lines + 1] = { xe.runs(str(a.name) .. ", Georgia Bar No. " .. str(a.bar)), 0, SIG_LEFT }
  end
  for i, l in ipairs(need(s, "firm")) do lines[#lines + 1] = { xe.inl(l), i == 1 and SIG_GAP or 0, SIG_LEFT } end
  for _, l in ipairs(need(s, "address")) do lines[#lines + 1] = { xe.inl(l), 0, SIG_LEFT } end
  lines[#lines + 1] = { xe.runs("Telephone: " .. str(need(s, "phone"))), 0, SIG_LEFT }
  for _, a in ipairs(attorneys) do lines[#lines + 1] = { xe.runs(str(a.email)), 0, SIG_LEFT } end
  lines[#lines + 1] = { xe.inl(need(s, "role")), SIG_GAP, SIG_LEFT }
  for i, l in ipairs(lines) do out[#out + 1] = p(l[1], { keep = i < #lines, before = l[2], left = l[3] }) end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings: single-spaced, a single line above and below, kept with the text; level 1 centered capitals, level 2
-- centered, level 3 at the margin; all bold.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(SINGLE, SINGLE, SINGLE), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- A body paragraph (style Body Text: the double pitch, a half-inch first-line indent), its notes Word footnotes.
local function body_par(label, inlines)
  local content = pandoc.Inlines({})
  if label then
    content:insert(pandoc.Str(label))
    content:insert(pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
  end
  content:extend(xe.inlines(inlines))
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Body Text" })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("a/k/a": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- typst sets a footnote mark against the word before it: a space before a note is dropped.
local function tight_notes(inlines)
  local out = pandoc.Inlines({})
  for i, el in ipairs(inlines) do
    local nxt = inlines[i + 1]
    if not ((el.t == "Space" or el.t == "SoftBreak") and nxt and nxt.t == "Note") then out:insert(el) end
  end
  return out
end

-- A doubled sign stays with its number ("§§ 2201": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = tight_notes })
  local meta = doc.meta
  local raw = {}
  cover(meta, raw)
  local blocks = {}
  for _, x in ipairs(raw) do blocks[#blocks + 1] = xe.raw(x) end
  if meta.lead_in then blocks[#blocks + 1] = body_par(nil, meta.lead_in) end

  -- A paragraph is numbered (Fed. R. Civ. P. 10(b)) unless it starts with the unnumbered marker "~ ". Ordered lists
  -- are the lettered prayer items: the letter half an inch in, a tab to one inch, the text hanging at one inch.
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      blocks[#blocks + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      if c[1] and c[1].t == "Str" and c[1].text == "~" and c[2] and c[2].t == "Space" then
        local rest = pandoc.Inlines({})
        for i = 3, #c do rest:insert(c[i]) end
        blocks[#blocks + 1] = body_par(nil, rest)
      else
        n = n + 1
        blocks[#blocks + 1] = body_par(n .. ".", c)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Para" and item[1].t ~= "Plain") then
          error("gand-complaint: a list item must be one paragraph")
        end
        blocks[#blocks + 1] = xe.raw(p(xe.runs(string.char(64 + i) .. ".\t") .. xe.inl(item[1].content),
          { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT }))
      end
    else
      error("gand-complaint: unsupported block " .. b.t)
    end
  end

  local sig = {}
  signature(meta, sig)
  for _, x in ipairs(sig) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
