-- Motion or brief for the United States Bankruptcy Court, District of Nebraska (nebraskab), docx engine: what the
-- Word output adds to pandoc's conversion, so that it reads and breaks as typst/nebraskab-motion-brief.typ does
-- (README "Engines"): the court name and the caption (FRBP 9004(b); the "In re" block with a rule under it, the
-- parties with "v.", intervenors after them; the case lines, the adversary line and the title in bold capitals on
-- the right), sections numbered I., II. (## headings) and subsections A., B. (### headings) restarting under each
-- section, the signature block kept with the last paragraph, and the CM/ECF certificate of service on its own page.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file. Caption and
-- signatures are OOXML tables; the body paragraphs are pandoc's own (Body Text), so their footnotes are Word
-- footnotes.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 576 the double-spaced body, 288 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 576, 288            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360   -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_INDENT, DESIG_INDENT = 720, 1440 -- typst caption-indent 0.5 in, designation-indent 1 in
local SIG_LEFT = 4320                    -- typst sig-left 3 in
local INDENT = 720                       -- typst para-indent 0.5 in
local COURT_NAME = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEBRASKA" }
local CERT_TEXT = "I hereby certify that on "
local CERT_END = ", I electronically filed the foregoing document with the Clerk of the Court using the CM/ECF " ..
  "system which sent notification of said filing to all CM/ECF participants."

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- a metadata list as Lua values; a single value is a list of one
local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function upper_inlines(ins)
  return pandoc.Inlines(ins):walk({ Str = function(s) s.text = pandoc.text.upper(s.text); return s end })
end

-- Roman numerals for section numbers (I., II., ...), as typst's numbering("I.", n)
local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do out, n = out .. v[2], n - v[1] end
  end
  return out
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first or 0
  if o.hanging then first = nil end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A table: widths, then rows of cells (each a list of paragraphs, or { pr = .., body = {..} }).
local function tbl(widths, rows, trpr)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row) do
      local body = c.body or c
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- A column of single lines (typst column()): "" a blank line, { text, indent } an indented one; o.before on the first.
local function column(entries, before)
  local out = {}
  for i, e in ipairs(entries) do
    local text, left = e, 0
    if type(e) == "table" and e.indent then text, left = e[1], e.indent end
    local runs = ""
    if type(text) == "string" then runs = xe.runs(text) else runs = xe.inl(text) end
    out[#out + 1] = p(runs, { left = left, before = i == 1 and before or 0 })
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Caption and title (FRBP 9004(b))
-- ---------------------------------------------------------------------------

-- Two rows of three columns (party column, gutter, case column). Row 1: the "In re:" block and the case lines, the
-- rule (a bottom border) under its party column. Row 2: the parties with "v." between them and the intervenors after
-- them; the adversary line, a blank double line, and the title in bold capitals.
local function caption(meta)
  local left_a = { "In re:" }
  for _, v in ipairs(items(meta.in_re)) do left_a[#left_a + 1] = v end
  left_a[#left_a + 1] = ""
  local right_a = { "" }
  for _, v in ipairs(items(meta.case_lines)) do right_a[#right_a + 1] = v end
  local left_b = { "" }
  local function party(pt)
    for _, nm in ipairs(items(pt.names)) do left_b[#left_b + 1] = nm end
    left_b[#left_b + 1] = ""
    left_b[#left_b + 1] = { pt.designation, indent = DESIG_INDENT }
  end
  for k, pt in ipairs(items(meta.parties)) do
    if k > 1 then
      left_b[#left_b + 1] = ""
      left_b[#left_b + 1] = { "v.", indent = CAP_INDENT }
      left_b[#left_b + 1] = ""
    end
    party(pt)
  end
  for _, pt in ipairs(items(meta.intervenors)) do
    left_b[#left_b + 1] = ""
    left_b[#left_b + 1] = ""
    party(pt)
  end
  local right_b = column({ "", meta.adversary_line, "", "" })
  right_b[#right_b + 1] = p(xe.inl(upper_inlines(meta.title), { b = true }))
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders>'
  return tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { { pr = rule, body = column(left_a) }, { p("") }, column(right_a) },
    { column(left_b), { p("") }, right_b },
  })
end

local function cover(meta)
  local out = {}
  for i, l in ipairs(COURT_NAME) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #COURT_NAME and BODY or 0 })
  end
  out[#out + 1] = caption(meta)
  out[#out + 1] = p("")   -- a single blank line between the caption and the text
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A heading line at the body pitch, bold, kept with the text after it (the Heading style's capitals off; level 1
-- and 2 text in capitals as typed by this filter).
local function heading(level, runs, o)
  runs = runs:gsub("<w:rPr>(.-)</w:rPr>", function(x)
    local at = x:find("<w:sz", 1, true) or x:find("<w:u ", 1, true) or x:find("<w:bdr", 1, true) or (#x + 1)
    return "<w:rPr>" .. x:sub(1, at - 1) .. '<w:caps w:val="0"/>' .. x:sub(at) .. "</w:rPr>"
  end)
  local first = 0
  if o.hanging then first = nil end
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(level, 5)), xe.KEEP, xe.spacing(0, 0, BODY),
    xe.ind(o.left or 0, o.hanging, first), xe.jc(o.jc or "left") }, runs))
end

-- A body paragraph (Body Text: the double pitch, first-line indent 0.5 in), written by pandoc so that its footnotes
-- are Word footnotes. The last one is Body Text Last: kept with the signature block after it (typst: one unbreakable
-- block).
local function body_par(content, last)
  return pandoc.Div({ pandoc.Para(xe.inlines(content)) },
    pandoc.Attr("", {}, { ["custom-style"] = last and "Body Text Last" or "Body Text" }))
end

-- ---------------------------------------------------------------------------
-- Signature and certificate of service
-- ---------------------------------------------------------------------------

-- The signature block in the right column (3 in from the margin), one row that does not split; `before` the space
-- above it (typst: the block's space above).
local function signature_tbl(lines, before)
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { { p("", { before = before }) }, column(lines, before) } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

local function signature(meta)
  local sig = meta.signature
  local lines = { sig.party, "" }
  for _, l in ipairs(items(sig.lines)) do lines[#lines + 1] = l end
  return signature_tbl(lines, BODY)
end

-- CM/ECF certificate (LR 5005-1(C)) on its own page.
local function certificate(meta)
  local cert = meta.certificate
  if not cert then
    error("nebraskab-motion-brief: the frontmatter must give the certificate of service (certificate.date, certificate.signer)", 0)
  end
  local signer = plain(cert.signer)
  return {
    p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { brk = true, keep = true, line = BODY, after = BODY, jc = "center" }),
    p(xe.runs(CERT_TEXT) .. xe.inl(cert.date) .. xe.runs(CERT_END), { line = BODY, first = INDENT }),
    signature_tbl({ "/s/ " .. signer, "", signer }, 2 * BODY),
  }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- "§§ 547" stays whole (typst boxes it): the space after a run of section signs is a no-break space.
local function bind_double_signs(ins)
  for i = 1, #ins - 1 do
    if ins[i].t == "Str" and ins[i].text:match("§§$") and ins[i + 1].t == "Space" then ins[i + 1] = pandoc.Str("\u{a0}") end
  end
  return ins
end

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = xe.raw(x) end
  -- level 2 headings are sections (I., II.), level 3 subsections (A., B., restarting per section); paragraphs are
  -- not numbered (a brief's numbering is typed by the author)
  local sec, sub = 0, 0
  for bi, b in ipairs(doc.blocks) do
    local last = bi == #doc.blocks
    if b.t == "Header" and b.level == 2 then
      sec, sub = sec + 1, 0
      out[#out + 1] = heading(2, xe.runs(roman(sec) .. ". ", { b = true }) .. xe.inl(upper_inlines(b.content), { b = true }),
        { jc = "center" })
    elseif b.t == "Header" and b.level == 3 then
      sub = sub + 1
      out[#out + 1] = heading(3, xe.runs(string.char(64 + sub) .. ".\t", { b = true }) .. xe.inl(b.content, { b = true }),
        { left = INDENT, hanging = INDENT })
    elseif b.t == "Header" then
      out[#out + 1] = heading(b.level, xe.inl(upper_inlines(b.content), { b = true }), { jc = "center" })
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content, last)
    else
      error("nebraskab-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  for _, x in ipairs(certificate(meta)) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
