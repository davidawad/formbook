-- Motion with memorandum, U.S. District Court for the District of Arizona (azd), DOCX engine (docs/DOCX.md): what the
-- Word output adds to pandoc's conversion, so that it reads and breaks as typst/azd-motion.typ does: counsel from
-- line 1 (LRCiv 7.1(a)(1)); the court title on or below line 6 (7.1(a)(2)); the caption with the case number, title
-- and judge right of center (7.1(a)(3)); the body double-spaced on the numbered lines (7.1(b)(1)); headings numbered
-- by this filter (I., A., 1., a.) and hung from the margin; the signature block and the certificate of service. The
-- page furniture is this filter's too, since the running line comes from the sample: the footers (the pleading
-- numbers 1 to 27 in a frame on the page, the page number, and from page 2 the running line) go to
-- $FORMBOOK_FOOTERS and the section that names them to $FORMBOOK_FINAL (fb render, tools/fb/src/docxpass.rs).
-- Everything case-specific comes from the frontmatter; no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered line, 320 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local PITCH, SINGLE = 480, 320           -- typst pitch, pitch-single
local HALF = 320                         -- typst half-gap 16 pt
local INDENT = 720                       -- typst para-indent and heading-tab, 0.5 in
local LINES = 27                         -- typst lines-per-page
local COUNSEL_LINES = 5                  -- typst counsel-lines
local TEXTW = 8640                       -- 8.5 in - 1.5 in - 1 in
local CAP_LEFT, CAP_GUTTER = 4608, 288   -- typst caption-left 3.2 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local CAP_PAD = 177                      -- typst caption-pad 9.6 pt, less the 0.75 pt rule LibreOffice adds to the row
local OFFSET = 128                       -- typst single-offset 6.4 pt: a run of single lines starts this far below a
                                         -- numbered line (every single baseline on a numbered line's or 8 pt off it)
local RIGHT_PAD = 32                     -- typst right-pad 1.6 pt
local SIGNER_GAP = 352                   -- typst signer-gap 17.6 pt
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local SIG_IND = 3744                     -- typst sig-indent 2.6 in
local FOOTER_LINE, RUNNING_LINE, RUNNING_SZ = 300, 220, 18   -- typst pitch-footer, pitch-running, running-size
-- The footer stands footer-gap (8 pt) below the last numbered line: Word measures the footer from the page foot to
-- its last line, so the distance is the bottom margin (72 pt) less the gap and the footer's two lines (26 pt).
local FOOTER_DIST = 1440 - 160 - FOOTER_LINE - RUNNING_LINE
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function text(v) return pandoc.utils.stringify(v) end

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

-- Space after `n` single lines that brings them back onto the numbered lines, at least `min` of them (typst
-- grid-fill: counted from the lines, as there).
local function grid_fill(n, min)
  local used = OFFSET + n * SINGLE
  local lines = math.max(min or 0, math.ceil(used / PITCH))
  return lines * PITCH - used
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  local counsel = meta.counsel or {}
  local fill = grid_fill(#counsel, COUNSEL_LINES)
  for i, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l), { before = i == 1 and OFFSET or 0, after = i == #counsel and fill or 0 }) end
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { line = PITCH, jc = "center", keep = true })
  -- the caption a numbered line below (Word has no space before a table: the line above carries it)
  out[#out + 1] = p(xe.runs("FOR THE DISTRICT OF ARIZONA", { b = true }), { line = PITCH, jc = "center", keep = true,
    after = PITCH })
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names or {}) do left[#left + 1] = p(xe.inl(n), { before = #left == 0 and OFFSET or 0 }) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #meta.caption.parties and CAP_PAD or 0 })
  end
  local right = {
    p(xe.runs("Case No. " .. text(meta.case_number)), { before = OFFSET, left = RIGHT_INSET }),
    p(xe.inl(meta.brief_title, { b = true }), { before = HALF, left = RIGHT_INSET }),
    p(xe.inl(meta.judge), { before = HALF, after = RIGHT_PAD, left = RIGHT_INSET }),
  }
  local function tc(w, pr, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' ..
      table.concat(body) .. '</w:tc>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' ..
    (TEXTW - CAP_LEFT - CAP_GUTTER) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    tc(CAP_LEFT, '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', left) ..
    tc(CAP_GUTTER, nil, { p("") }) .. tc(TEXTW - CAP_LEFT - CAP_GUTTER, nil, right) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- heading labels, as typst numbers them: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 is unnumbered
local counters = { 0, 0, 0, 0, 0 }
local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end
local function heading_label(level)
  counters[level] = counters[level] + 1
  for k = level + 1, 5 do counters[k] = 0 end
  if level == 2 then return roman(counters[2]) .. "." end
  if level == 3 then return string.char(64 + counters[3]) .. "." end
  if level == 4 then return tostring(counters[4]) .. "." end
  return string.char(96 + counters[5]) .. "."
end

local function heading(el)
  local lvl = math.min(el.level, 5)
  if lvl == 1 then
    heading_label(1)
    local content = el.content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(0, 0, PITCH), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(content, { b = true }))
  end
  -- the label hangs from an indent of one tab per level below 2, the text a tab after it (typst heading-rule)
  local ind = (lvl - 2) * INDENT
  -- no Heading style below level 3: the recipe sets levels 4 and 5 italic, typst only level 5 (the run says so)
  return xe.para({ lvl <= 3 and xe.style("Heading" .. lvl) or "", xe.KEEP,
    '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + INDENT) .. '"/></w:tabs>', xe.spacing(0, 0, PITCH),
    xe.ind(ind + INDENT, INDENT), xe.jc("left"), '<w:outlineLvl w:val="' .. (lvl - 1) .. '"/>' },
    xe.runs(heading_label(lvl) .. "\t", { b = true, i = lvl == 5 }) .. xe.inl(el.content, { b = true, i = lvl == 5 }))
end

local function body(blocks, out)
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = PITCH, first = INDENT })
    else
      error("azd-motion: unsupported block " .. b.t)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  out[#out + 1] = p(xe.runs("DATED: " .. text(meta.date)), { line = PITCH, keep = true })
  local lines = {}
  for _, l in ipairs(sig.firm or {}) do lines[#lines + 1] = xe.inl(l) end
  lines[#lines + 1] = ""
  lines[#lines + 1] = xe.runs("By: /s/ " .. text(sig.signer))
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = xe.inl(l) end
  local fill = grid_fill(#lines)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { left = SIG_IND, keep = i < #lines, before = i == 1 and OFFSET or 0, after = i == #lines and fill or 0 })
  end
end

local function certificate(meta, out)
  local c = meta.certificate
  if not c then return end
  out[#out + 1] = p(xe.inl(c.heading, { b = true }), { before = PITCH, line = PITCH, jc = "center", keep = true })
  out[#out + 1] = p(xe.inl(c.text), { line = PITCH, first = INDENT })
  for i, l in ipairs(c.service or {}) do out[#out + 1] = p(xe.inl(l), { before = i == 1 and OFFSET or 0 }) end
  out[#out + 1] = p(xe.runs("/s/ " .. text(c.signer)), { before = SIGNER_GAP, line = PITCH, left = SIG_IND })
end

-- ---------------------------------------------------------------------------
-- Page furniture: footers and the section
-- ---------------------------------------------------------------------------

local function footer(running)
  local fr = '<w:framePr w:w="1440" w:h="' .. (LINES * PITCH) .. '" w:hRule="exact" w:hSpace="0" w:wrap="around"' ..
    ' w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="1440"/>'
  local x = {}
  -- the pleading numbers: one per numbered line, right-aligned in the inch left of the rules (typst line-numbers)
  for i = 1, LINES do
    x[#x + 1] = '<w:p><w:pPr>' .. fr .. xe.spacing(0, 0, PITCH) .. xe.jc("right") .. '</w:pPr>' .. xe.runs(tostring(i)) ..
      '</w:p>'
  end
  x[#x + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, FOOTER_LINE) .. xe.jc("center") .. '</w:pPr>' ..
    '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  x[#x + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, RUNNING_LINE) .. xe.jc("center") .. '</w:pPr>' ..
    xe.runs(running or "", { sz = RUNNING_SZ }) .. '</w:p>'
  return table.concat(x)
end

local function write_file(var, s)
  local path = os.getenv(var)
  if not path then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

local function furniture()
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  local s = f and f:read("a") or ""
  if f then f:close() end
  local meta = s ~= "" and pandoc.json.decode(s, false) or {}
  local running = meta.running_header and table.concat(meta.running_header, " | ") or nil
  write_file("FORMBOOK_FOOTERS", "rIdAzdFirst\t" .. footer(nil) .. "\nrIdAzdRun\t" .. footer(running) .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdAzdRun"/>' ..
    '<w:footerReference w:type="first" r:id="rIdAzdFirst"/><w:pgSz w:w="12240" w:h="15840"/>' ..
    '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" w:header="720" w:footer="' .. FOOTER_DIST ..
    '" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="12" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders><w:titlePg/></w:sectPr>')
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1983"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local t = a.text
      if #t >= 4 and t:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
        inlines[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = PITCH, first = INDENT, before = PITCH }) end
  body(doc.blocks, out)
  -- LRCiv 12.1(c) certification (optional; author content)
  if meta.certification then
    out[#out + 1] = p(xe.inl(meta.certification.heading, { b = true }), { line = PITCH, jc = "center", keep = true })
    out[#out + 1] = p(xe.inl(meta.certification.text), { line = PITCH, first = INDENT })
  end
  signature(meta, out)
  certificate(meta, out)
  furniture()
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
