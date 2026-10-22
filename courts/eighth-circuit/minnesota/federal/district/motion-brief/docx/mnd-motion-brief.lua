-- mnd-motion-brief.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads and breaks
-- as typst/mnd-motion-brief.typ does (see ../README.md "Engines"): the court's name and the caption table (party
-- column between rules; on the right the court file number, the bold title in capitals and the rule line), the
-- headings, the signature block (date on the left, firm and signer on the right) and the certificate of compliance
-- on its own page (LR 7.1(f)(2)), with the word count from the frontmatter and the 12,000-word limit checked at build
-- time (LR 7.1(f)(1)(A)), as the typst template asserts it. Body paragraphs, block quotations and footnotes stay
-- pandoc's (Body Text, Block Text, Footnote Text in docx/reference.xml). Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 598 the double-spaced body, 299 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local WORD_LIMIT = 12000
local BODY, SINGLE = 598, 299          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent, 0.5 in
local TEXTW = 9360                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4752, 432 -- typst caption-left 3.3 in, caption-gutter 0.3 in
local CAP_PAD = 160                    -- typst caption-pad 8 pt
local RIGHT_INSET = 144                -- typst right-inset 0.1 in
local VS, DESIG = 432, 1728            -- typst vs-indent 0.3 in, designation-indent 1.2 in
local SIG_LEFT, SIG_GUTTER = 3744, 288 -- typst sig-left 2.6 in, sig-gutter 0.2 in
local COURT = { "UNITED STATES DISTRICT COURT", "DISTRICT OF MINNESOTA" } -- the court's name, not the case's

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

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

-- ---------------------------------------------------------------------------
-- Court name and caption (LR 5.2(a); Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  for i, l in ipairs(COURT) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #COURT and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation, indented; "v." between the parties. The rules stand the
  -- pad off the text as space before the first line and after the last (a cell margin would lower the whole row).
  local left = {}
  local parties = meta.caption
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { left = VS }) end
    for j, n in ipairs(party.names) do
      left[#left + 1] = p(xe.inl(n), { before = (k == 1 and j == 1) and CAP_PAD or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG, after = k == #parties and CAP_PAD or 0 })
  end
  -- Right cell: the court file number level with the first party line, then the title in capitals and the rule
  -- line, a single line apart.
  local right = {
    p(xe.runs("Court File No. " .. plain(meta.case_number)), { before = CAP_PAD }),
    p(xe.runs(pandoc.text.upper(plain(meta.brief_title)), { b = true }), { before = SINGLE, jc = "center" }),
    p(xe.inl(meta.rule_line), { before = SINGLE, jc = "right" }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:top ' .. rule .. '/><w:bottom ' .. rule .. '/></w:tcBorders>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature and certificate
-- ---------------------------------------------------------------------------

-- The date on the left, single-spaced lines on the right ("" a blank line); the row never splits. The space above
-- it is a 1 pt paragraph kept with the table, its space before the rest: at the top of a page LibreOffice drops a
-- paragraph's space before, as typst drops a block's, but keeps it in a table cell.
local function dated(date, lines, before)
  local right = {}
  for _, l in ipairs(lines) do
    right[#right + 1] = p(plain(l) == "" and xe.runs("\u{00A0}") or xe.inl(l))
  end
  local left = { p(xe.runs("Dated: ") .. xe.inl(date)) }
  return p("", { keep = true, before = before - 20, line = 20 }) .. tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- Certificate of compliance: its own page, the text double-spaced and first-line indented (typst certificate).
local function certificate(meta)
  local count = tonumber(plain(meta.word_count))
  if not count or count > WORD_LIMIT then
    error("mnd-motion-brief.lua: word_count must be a number at or below the LR 7.1(f)(1)(A) limit of 12,000")
  end
  local text = "I hereby certify that this memorandum complies with the word limit of D. Minn. LR 7.1(f)(1)(A) and the "
    .. "type-size requirement of D. Minn. LR 7.1(h)(1). The memorandum contains " .. plain(meta.word_count)
    .. " words, counted with " .. plain(meta.word_software) .. ", which was applied to include all text, including "
    .. "headings, footnotes, and quotations. The count excludes the caption, the signature block, and this "
    .. "certificate (LR 7.1(f)(1)(C))."
  return {
    p(xe.runs("CERTIFICATE OF COMPLIANCE", { b = true }), { brk = true, jc = "center", after = SINGLE }),
    p(xe.runs(text), { line = BODY, first = INDENT }),
    dated(meta.date, { meta.certificate_signer }, BODY),
  }
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings (LR 7.1(h)(1) lets them be single-spaced): bold, a single line above and below; level 1 centred, level 2
-- hanging by the paragraph indent, level 3 a further half inch in; kept with the text.
local function heading(el, before)
  local lvl = math.min(el.level, 3)
  local ind = lvl == 1 and xe.ind(0, nil, 0) or xe.ind((lvl - 1) * INDENT, INDENT)
  -- (level 1 without the Heading 1 style, whose capitals typst does not set)
  local props = { lvl > 1 and xe.style("Heading" .. lvl) or "", xe.KEEP, xe.spacing(before, SINGLE, SINGLE), ind,
    xe.jc(lvl == 1 and "center" or "left"), '<w:outlineLvl w:val="' .. (lvl - 1) .. '"/>' }
  return xe.para(props, xe.inl(el.content, { b = true }))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  -- the break rules on the body pandoc writes (the frontmatter goes through xe.inl, which applies them itself)
  doc = doc:walk({ Str = breaks })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = xe.raw(x) end
  -- the caption stands a double line above the text (typst: the caption block's below); Word has no space after a
  -- table, so the first block after it takes the space before it
  local first = true
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b, first and BODY or SINGLE))
    elseif first and (b.t == "Para" or b.t == "Plain") then
      out[#out + 1] = xe.raw(p(xe.inl(b.content), { line = BODY, first = INDENT, before = BODY }))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Body Text" })
    elseif b.t == "BlockQuote" then
      out[#out + 1] = pandoc.Div(b.content, { ["custom-style"] = "Block Text" })
    else
      out[#out + 1] = b
    end
    first = false
  end
  out[#out + 1] = xe.raw(dated(meta.date, meta.signature or {}, BODY))
  for _, x in ipairs(certificate(meta)) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
