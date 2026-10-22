-- rid-motion-brief.lua (docx engine): the D.R.I. memorandum as Word paragraphs and tables, so that it reads and breaks
-- as typst/rid-motion-brief.typ does (see ../README.md "Engines"): the court title, the caption as a table (party
-- column closed by a rule on the right and below; "C.A. No." on the right, LR Cv 5(a)(1)), the title, the headings
-- with the labels typst prints (level 1 "I. INTRODUCTION", level 2 "A. ...", level 3 as written), the body
-- paragraphs, block quotations and footnotes (pandoc writes them, so the notes stay Word footnotes), the statement on
-- oral argument (LR Cv 7(c)), the signature block (LR Cv 5(a)(5)) and the certificate of service, each one table row
-- that never splits. Nothing in this file is case-specific: every word comes from the sample's frontmatter or body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line, 230 a
-- footnote line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360   -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_INSET = 172                    -- typst caption-inset 8.6 pt
local NUM_INSET = 144                    -- typst number-inset 0.1 in
local SIG_LEFT, SIG_GUTTER = 4176, 288   -- typst sig-left 2.9 in, sig-gutter 0.2 in

local str = pandoc.utils.stringify

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI",
  "XVII", "XVIII", "XIX", "XX" }

local function upper(content)
  return pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, lines }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A fixed-width table of one row; cells = { { pr = tcPr children, body = { paragraphs } } }.
local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local CANTSPLIT = "<w:trPr><w:cantSplit/></w:trPr>"

-- The double line above a block that never splits: an empty 1 pt paragraph with the rest as space before, which Word
-- drops at the top of a page as typst drops the block's space above (a space before inside a table cell would stay).
local function gap(out)
  out[#out + 1] = xe.raw(p("", { before = BODY - 20, line = 20 }))
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title (LR Cv 5(a)(1), (2))
-- ---------------------------------------------------------------------------

local function cover(m, out)
  out[#out + 1] = xe.raw(p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center", keep = true }))
  -- the caption stands a double line below the court title (typst: the caption block's above), as the space after
  -- the court title: a space before inside the cells would run the caption's rule up into it
  out[#out + 1] = xe.raw(p(xe.runs("FOR THE DISTRICT OF RHODE ISLAND", { b = true }), { jc = "center", keep = true, after = BODY }))
  local left = {}
  local parties = m.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_INSET or 0 })
  end
  local number = str(m.case_number or "")
  local right = { p(xe.runs(number ~= "" and ("C.A. No. " .. number) or "C.A. No. ______________")) }
  if m.jury_demand == true then right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = BODY }) end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = xe.raw(tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("") } },
    { pr = '<w:tcMar><w:left w:w="' .. NUM_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  }))
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = xe.raw(p(xe.inl(m.brief_title, { b = true }), { before = BODY, after = SINGLE, jc = "center", keep = true }))
end

-- ---------------------------------------------------------------------------
-- Statement on oral argument, signature, certificate of service
-- ---------------------------------------------------------------------------

-- LR Cv 7(c): "requested" with the estimated time, or "not requested"; the paragraph never splits.
local function oral_argument(m, out)
  local oa = m.oral_argument
  local statement
  if oa.requested == true then
    statement = "Oral argument and evidentiary hearing are requested"
    if oa.minutes ~= nil then statement = statement .. "; the estimated time is " .. str(oa.minutes) .. " minutes."
    else statement = statement .. "." end
  else
    statement = "Oral argument and evidentiary hearing are not requested."
  end
  out[#out + 1] = xe.raw(p(xe.runs("Statement on oral argument.", { b = true }) .. xe.runs(" " .. statement),
    { line = BODY, first = INDENT, lines = true }))
end

-- "Dated" at the left; the lead line, the party lines, the signers with "/s/" and bar numbers, then the firm block.
local function signature(m, out)
  local sig = m.signature
  local right = {}
  local function add(body, before) right[#right + 1] = p(body, { before = #right > 0 and before or 0 }) end
  if sig.lead ~= nil then
    add(xe.inl(sig.lead))
    add("")
  end
  for _, l in ipairs(sig.party) do add(xe.inl(l)) end
  for _, s in ipairs(sig.signers) do
    local bar = s.bar and str(s.bar) or ""
    add(xe.runs("/s/ ") .. xe.inl(s.name), SINGLE)
    add(xe.inl(s.name) .. (bar ~= "" and (xe.runs(" ") .. xe.inl(s.bar)) or ""))
  end
  for i, l in ipairs(sig.firm) do add(xe.inl(l), i == 1 and SINGLE or 0) end
  gap(out)
  local dated = m.date ~= nil and (xe.runs("Dated: ") .. xe.inl(m.date)) or ""
  out[#out + 1] = xe.raw(tbl({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER }, {
    { body = { p(dated) } },
    { body = { p("") } },
    { body = right },
  }, CANTSPLIT))
end

-- The heading, the text (double-spaced, first-line indent), the first signer's "/s/" lines in the signature column.
local function certificate(m, out)
  local cos = m.certificate_of_service
  local s = m.signature.signers[1]
  local bar = s.bar and str(s.bar) or ""
  local col = SIG_LEFT + SIG_GUTTER
  gap(out)
  out[#out + 1] = xe.raw(tbl({ TEXTW }, { { body = {
    p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { line = BODY, jc = "center" }),
    p(xe.inl(cos.text), { line = BODY, first = INDENT }),
    p(xe.runs("/s/ ") .. xe.inl(s.name), { before = SINGLE, left = col }),
    p(xe.inl(s.name) .. (bar ~= "" and (xe.runs(" ") .. xe.inl(s.bar)) or ""), { left = col }),
  } } }, CANTSPLIT))
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, bold, kept with the text after them: level 1 centered "I. INTRODUCTION", level 2
-- "A. ..." at the left, level 3 as written at the left.
local counts = { 0, 0 }
local function heading(el)
  local lvl = math.min(el.level, 3)
  local body
  if lvl == 1 then
    counts[1], counts[2] = counts[1] + 1, 0
    body = xe.runs(ROMAN[counts[1]] .. ". ", { b = true }) .. xe.inl(upper(el.content), { b = true })
  elseif lvl == 2 then
    counts[2] = counts[2] + 1
    body = xe.runs(string.char(64 + counts[2]) .. ". ", { b = true }) .. xe.inl(el.content, { b = true })
  else
    body = xe.inl(el.content, { b = true })
  end
  return xe.raw(xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, body))
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A body paragraph: pandoc writes it (and its footnotes) in "Body Text"; a paragraph that carries a footnote mark
-- in "Body Text Note" (no widow control: typst lets the line with the mark move on alone when its note does not fit).
local function body_par(inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = has_note(inlines) and "Body Text Note" or "Body Text" })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 2601"), as the typst template boxes it (xe.inl binds a single sign).
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
  local m = doc.meta
  assert(m.caption and m.caption.parties, "rid-motion-brief.lua: the sample needs caption.parties")
  assert(m.brief_title, "rid-motion-brief.lua: the sample needs brief_title")
  assert(m.signature, "rid-motion-brief.lua: the sample needs a signature block")
  assert(m.oral_argument, "rid-motion-brief.lua: the sample needs oral_argument (LR Cv 7(c))")
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  m = doc.meta
  local out = {}
  cover(m, out)
  for _, b in ipairs(doc.blocks) do
    -- the break rules on the blocks pandoc writes: the headings and the frontmatter go through xe.inl, which applies
    -- them itself (it would drop the no-break hyphens xe.inlines writes as raw runs)
    if b.t ~= "Header" then b = b:walk({ Inlines = xe.inlines }) end
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content)
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b                    -- "Block Text" (reference.xml: double-spaced, half an inch in each side)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("rid-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  oral_argument(m, out)
  signature(m, out)
  if m.certificate_of_service ~= nil then certificate(m, out) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
