-- Complaint, United States District Court for the District of Alaska (akd), DOCX engine (docs/DOCX.md): what the
-- Word output adds to pandoc's conversion, so that it reads and breaks as typst/akd-complaint.typ does: the counsel
-- block, court title, caption and title (L.R. 7.5(b), 8.1(a)), the lead-in, the numbered paragraphs (Fed. R. Civ. P.
-- 10(b)) with their footnotes, the headings (level 1 numbered I., II., ...), the lettered prayer items, the jury
-- demand, the signature block (L.R. 7.5(c)) and the verification, and the footer with the page number, case name
-- and case number (L.R. 7.5(a)(1)(C)), written to fb render's $FORMBOOK_FOOTERS with the last section in
-- $FORMBOOK_FINAL. Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 600 the double-spaced body, 300 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. A paragraph that carries a
-- footnote is pandoc's (it writes the note), in the reference's "Allegation" styles.

local xe = require("docx.xengine")

local BODY, SINGLE = 600, 300            -- typst pitch-double, pitch-single
local HALF, SMALL = 300, 120             -- typst half-gap 15 pt, small-gap 6 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local ITEM_TEXT = 1440                   -- typst item-indent + item-box: the text of a prayer item
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 160   -- typst caption-left 3.4 in, caption-gutter 8 pt
local CAP_INSET = 160                    -- typst caption-inset 8 pt
local CAP_PAD = 145                      -- caption-inset less the 0.75 pt rule LibreOffice adds to the row
local COURT_DROP = 1152                  -- typst court-drop 0.8 in
local SIG = 3600                         -- typst sig-indent 2.5 in
local VERIFY = 4320                      -- typst verify-indent 3 in
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function text(v) return pandoc.utils.stringify(v) end

local function upper(content)
  if type(content) == "string" then return pandoc.text.upper(content) end
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, border }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.border then props[#props + 1] = '<w:pBdr><w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.raw(xe.para(props, body))
end

-- ---------------------------------------------------------------------------
-- Footer and last section (L.R. 7.5(a)(1)(B)-(C)): page number, case name, case number, single lines, centered;
-- in the bottom margin, its top 6 pt below the text area (typst footer-gap): its last line ends 21 pt above the page
-- foot (792 - 720 - 6 - 3 x 15).
-- ---------------------------------------------------------------------------

local PAGE = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'

local function write_footer(meta)
  local path, final = os.getenv("FORMBOOK_FOOTERS"), os.getenv("FORMBOOK_FINAL")
  if not path or not final then return end
  local function line(runs)
    return '<w:p><w:pPr>' .. xe.spacing(0, 0, SINGLE) .. xe.jc("center") .. '</w:pPr>' .. runs .. '</w:p>'
  end
  local f = assert(io.open(path, "w"))
  f:write("rIdFtrAkd\t", line(PAGE), line(xe.runs(text(meta.footer_title))),
    line(xe.runs("Case No. " .. text(meta.case_number))), "\n")
  f:close()
  f = assert(io.open(final, "w"))
  f:write('<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrAkd"/><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="420" '
    .. 'w:gutter="0"/></w:sectPr>')
  f:close()
end

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, caption, title (L.R. 7.5(b))
-- ---------------------------------------------------------------------------

local function cell(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

local function cover(meta, out)
  for _, l in ipairs(meta.counsel) do out[#out + 1] = p(xe.inl(l)) end
  for i, l in ipairs(meta.court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { before = i == 1 and COURT_DROP or 0, jc = "center", keep = true })
  end
  -- The caption stands a double line below the court title: Word has no space before a table, so the first
  -- paragraph of each cell carries it.
  local left = {}
  for i, s in ipairs(meta.caption) do
    for j, n in ipairs(s.names) do
      left[#left + 1] = p(xe.inl(n), { before = (i == 1 and j == 1) and BODY or (j == 1 and HALF or 0) })
    end
    left[#left + 1] = p(xe.inl(s.designation), { before = SMALL, jc = "right", after = i == #meta.caption and CAP_PAD or 0 })
  end
  local function xml(list)
    local t = {}
    for _, b in ipairs(list) do t[#t + 1] = b.text end
    return table.concat(t)
  end
  local right = p(xe.runs("Case No. " .. text(meta.case_number)), { before = BODY })
  out[#out + 1] = xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="'
    .. (TEXTW - CAP_LEFT - CAP_GUTTER) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_LEFT, '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders><w:tcMar><w:right w:w="'
      .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', xml(left))
    .. cell(CAP_GUTTER, nil, p("", { before = BODY }).text)
    .. cell(TEXTW - CAP_LEFT - CAP_GUTTER, nil, right.text)
    .. '</w:tr></w:tbl>')
  out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { before = BODY, jc = "center" })
  if meta.statute then out[#out + 1] = p(xe.runs("(") .. xe.inl(meta.statute) .. xe.runs(")"), { jc = "center" }) end
  if meta.oral_argument then out[#out + 1] = p(xe.runs("Oral Argument Requested", { b = true }), { jc = "center" }) end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A numbered paragraph: the number and a tab (the reference's Allegation styles: the number half an inch in, the
-- text an inch in), written by pandoc so that it writes the footnotes. "Allegation Note" has no widow control
-- (typst lets the line with the mark move on alone when its note does not fit); "Allegation Keep" is kept with the
-- signature block.
local function allegation(n, inlines, keep)
  local l = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
  l:extend(inlines)
  local style = keep and "Allegation Keep" or has_note(inlines) and "Allegation Note" or "Allegation"
  return pandoc.Div({ pandoc.Para(l) }, { ["custom-style"] = style })
end

local function body(blocks, out)
  local n, h1 = 0, 0
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      local content = b.content
      if b.level == 1 then
        h1 = h1 + 1
        content = upper(pandoc.Inlines({ pandoc.Str(roman(h1) .. "."), pandoc.Space() }) .. content)
      end
      out[#out + 1] = xe.raw(xe.para({ xe.style("Heading" .. math.min(b.level, 5)), xe.KEEP, xe.spacing(0, 0, BODY),
        xe.ind(0, nil, 0), xe.jc("center") }, xe.inl(content, { b = true })))
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = allegation(n, b.content, last)
    elseif b.t == "BlockQuote" then
      -- L.R. 7.5(a)(1)(A): quotations single-spaced and indented (the reference's Block Text)
      out[#out + 1] = b
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- prayer items, lettered (a), (b), ...: the label half an inch in, the text an inch in
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ((b.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = ITEM_TEXT,
            hanging = ITEM_TEXT - INDENT, keep = last })
        end
      end
    else
      error("akd-complaint: unsupported block " .. b.t)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Jury demand, signature block (L.R. 7.5(c)), verification
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = {}
  if meta.date then lines[#lines + 1] = { xe.inl(meta.date), { before = BODY, left = INDENT } } end
  lines[#lines + 1] = { xe.inl(sig.firm, { b = true }), { before = #lines == 0 and BODY or HALF, left = SIG } }
  if sig.role then lines[#lines + 1] = { xe.inl(sig.role), { left = SIG } } end
  lines[#lines + 1] = { xe.runs("/s/ " .. text(sig.signer)), { before = HALF, left = SIG } }
  lines[#lines + 1] = { xe.runs(text(sig.signer)), { left = SIG } }
  if sig.bar then lines[#lines + 1] = { xe.inl(sig.bar), { left = SIG } } end
  for i, l in ipairs(lines) do
    l[2].keep = i < #lines
    out[#out + 1] = p(l[1], l[2])
  end
end

local function verification(v, out)
  out[#out + 1] = xe.raw(xe.para({ xe.style("Heading2"), xe.KEEP, xe.BREAK, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(upper(v.heading), { b = true })))
  out[#out + 1] = p(xe.inl(v.text), { before = HALF, line = BODY, first = INDENT })
  if v.date then out[#out + 1] = p(xe.inl(v.date), { before = HALF, left = INDENT }) end
  out[#out + 1] = p(xe.inl(v.signer), { before = 2 * BODY, left = VERIFY, border = true })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 701"), as the typst template boxes it (xe binds a single sign).
local function signs(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "case_number", "footer_title", "caption", "counsel", "title", "signature" }) do
    if meta[k] == nil then error("akd-complaint: the sample frontmatter needs `" .. k .. "`", 0) end
  end
  write_footer(meta)
  doc = pandoc.Pandoc(doc.blocks):walk({ Str = breaks }):walk({ Inlines = signs }):walk({ Inlines = xe.inlines })
  local out = {}
  cover(meta, out)
  if meta.opening then out[#out + 1] = p(xe.inl(meta.opening), { before = HALF, line = BODY, first = INDENT }) end
  body(doc.blocks, out)
  if meta.jury_demand then
    out[#out + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = BODY, line = BODY, jc = "center", keep = true })
    out[#out + 1] = p(xe.runs("Plaintiff demands a trial by jury on all issues so triable."), { line = BODY, first = INDENT })
  end
  signature(meta, out)
  if meta.verification then verification(meta.verification, out) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
