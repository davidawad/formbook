-- nvd-motion-brief.lua (docx engine): the D. Nev. motion to dismiss with its memorandum (one document, LR 7-2(a)) as
-- Word paragraphs, so that it reads and breaks as typst/nvd-motion-brief.typ does: counsel (LR IA 10-2) on lines 1 to
-- 7 at least, the court title, the caption (a table whose party column has the right and bottom rules; the case
-- number and the title beside it), the motion and the memorandum on page one (paragraphs, headings with their labels
-- in half-inch boxes, quotations single spaced and indented, LR IA 10-1(a)(4)), the date and signature block, and the
-- certificate of service on its own page. The footer holds the pleading paper's 28 line numbers (LR IA 10-1(a)(1)) in
-- a text box anchored to the page and the page number (LR IA 10-1(a)(5)). Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 460 a numbered line, 276 a single line), the spaces between
-- blocks those of the typst template (whole multiples of 92 twips; a run of single lines 10 twips down, 82 after),
-- and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 460, 276            -- typst pitch, pitch-single
local SHIFT, RESYNC = 10, 82             -- typst single-shift 0.5 pt, single-resync 4.1 pt: around a run of single lines
local QUOTE = 92                         -- typst quote-gap, 4.6 pt above and below a quotation
local LINES = 28                         -- typst lines-per-page (LR IA 10-1(a)(1))
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 8640                       -- 6 in: 8.5 in less the 1.5 in and 1 in margins
local CAP_LEFT, CAP_GUTTER = 4608, 288   -- typst caption-left 3.2 in, caption-gutter 0.2 in
local CAP_PAD, CAP_BOTTOM = 200, 159     -- typst caption-pad 10 pt, caption-bottom 8.7 pt less the 0.75 pt (15 twips) of
                                         -- the bottom rule, which LibreOffice adds to the row and typst draws over the inset
local CAP_RIGHT_PAD = 144                -- typst caption-right-pad 0.1 in
local DESIG = 1728                       -- typst designation-indent 1.2 in
local SIG = 3744                         -- typst sig-indent 2.6 in
local COUNSEL_LINES = 7                  -- typst counsel-lines
local FOOTER = 720                       -- typst footer-foot 0.5 in
local EMU = 635                          -- EMU per twip
local NUM_RIGHT, NUM_W = 1512, 1008      -- typst number-right 1.05 in; the numbers' box is 0.7 in wide
local TOP = 1440                         -- typst top-margin

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless one-row table that never splits: cells = { { width, paragraphs, tcPr extra } }.
local function tbl(cells)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    local body = #c[2] > 0 and table.concat(c[2]) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

-- A single line: an empty one is a blank line (typst: line-block("")).
local function single(m, o)
  return p(plain(m) == "" and "" or xe.inl(m, o and o.r), o)
end

local function caption(meta)
  local left = {}
  local sep = meta.caption.separator or "v."
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = single(sep, { before = SINGLE, after = SINGLE }) end
    for _, n in ipairs(party.names) do left[#left + 1] = single(n) end
    left[#left + 1] = single(party.designation, { left = DESIG })
  end
  local right = { p(xe.runs("Case No.: ") .. xe.inl(meta.case_number)) }
  right[#right + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE })
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:top w:w="' .. SHIFT .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_BOTTOM .. '" w:type="dxa"/>' ..
    '<w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  local pad = '<w:tcMar><w:top w:w="' .. SHIFT .. '" w:type="dxa"/><w:left w:w="' .. CAP_RIGHT_PAD .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. RESYNC .. '" w:type="dxa"/></w:tcMar>'
  return tbl({ { CAP_LEFT, left, rule }, { CAP_GUTTER, {} }, { TEXTW - CAP_LEFT - CAP_GUTTER, right, pad } })
end

local function cover(meta)
  local out = { p("", { line = SHIFT }) }
  local counsel = meta.counsel or {}
  for _, c in ipairs(counsel) do out[#out + 1] = single(c) end
  -- counsel fills lines 1 to 7 at least (a longer block is followed by RESYNC), then a blank numbered line
  local h = #counsel * SINGLE
  local target = math.max(COUNSEL_LINES * BODY, SHIFT + h + RESYNC)
  out[#out + 1] = p("", { line = target - SHIFT - h + BODY })
  out[#out + 1] = p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { line = BODY, jc = "center" })
  out[#out + 1] = p(xe.runs("DISTRICT OF NEVADA", { b = true }), { line = BODY, jc = "center" })
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = caption(meta)
  out[#out + 1] = p("", { line = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

-- The date, a blank numbered line, the firm, "By: /s/" and the signer's lines at 2.6 in; kept on one page (typst:
-- one unbreakable block).
local function signature(meta)
  local sig = meta.signature
  local out = { p(xe.inl(meta.date), { line = BODY, after = BODY + SHIFT, keep = true }) }
  for _, l in ipairs(sig.firm or {}) do out[#out + 1] = single(l, { left = SIG, keep = true }) end
  local lines = sig.lines or {}
  out[#out + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = SINGLE, left = SIG, keep = #lines > 0 })
  for i, l in ipairs(lines) do out[#out + 1] = single(l, { left = SIG, keep = i < #lines }) end
  return out
end

-- The certificate on its own page: heading, paragraphs double spaced, the service list half an inch in, a numbered
-- line, the signature (typst: certificate-block).
local function certificate(cert)
  local out = { p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { line = BODY, jc = "center", brk = true }) }
  for _, para in ipairs(cert.paragraphs or {}) do out[#out + 1] = p(xe.inl(para), { line = BODY, first = INDENT }) end
  out[#out + 1] = p("", { line = SHIFT })
  local rec = cert.recipients or {}
  for i, r in ipairs(rec) do out[#out + 1] = single(r, { left = INDENT, after = i == #rec and BODY or 0 }) end
  out[#out + 1] = p(xe.runs("By: /s/ ") .. xe.inl(cert.signer), { left = SIG })
  for _, l in ipairs(cert.lines or {}) do out[#out + 1] = single(l, { left = SIG }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Footer and last section
-- ---------------------------------------------------------------------------

-- The 28 line numbers: a text box anchored to the page, its line boxes of the numbered pitch from the top margin,
-- the numbers set right to typst's number-right (typst: line-numbers()).
local function line_numbers()
  local ps = {}
  for i = 1, LINES do
    ps[#ps + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, BODY) .. xe.ind(0, nil, 0) .. xe.jc("right") .. '</w:pPr>' ..
      xe.runs(tostring(i)) .. '</w:p>'
  end
  local x, y, cx, cy = (NUM_RIGHT - NUM_W) * EMU, TOP * EMU, NUM_W * EMU, LINES * BODY * EMU
  return '<w:r><w:drawing xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" ' ..
    'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" ' ..
    'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">' ..
    '<wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="251659264" behindDoc="1" ' ..
    'locked="1" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/>' ..
    '<wp:positionH relativeFrom="page"><wp:posOffset>' .. x .. '</wp:posOffset></wp:positionH>' ..
    '<wp:positionV relativeFrom="page"><wp:posOffset>' .. y .. '</wp:posOffset></wp:positionV>' ..
    '<wp:extent cx="' .. cx .. '" cy="' .. cy .. '"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/>' ..
    '<wp:docPr id="1" name="Pleading line numbers"/><wp:cNvGraphicFramePr/><a:graphic>' ..
    '<a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp>' ..
    '<wps:cNvSpPr txBox="1"/><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="' .. cx .. '" cy="' .. cy .. '"/></a:xfrm>' ..
    '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></wps:spPr>' ..
    '<wps:txbx><w:txbxContent>' .. table.concat(ps) .. '</w:txbxContent></wps:txbx>' ..
    '<wps:bodyPr rot="0" vert="horz" wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="t" anchorCtr="0">' ..
    '<a:noAutofit/></wps:bodyPr></wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r>'
end

-- The footer (typst: footer-block): the page number and, when the sample gives one, the paper's title in capitals,
-- centred in single line boxes.
local function footer(meta)
  local fp = '<w:pPr>' .. xe.spacing(0, 0, SINGLE) .. xe.ind(0, nil, 0) .. xe.jc("center") .. '</w:pPr>'
  local out = '<w:p>' .. fp .. line_numbers() ..
    '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>' ..
    '</w:p>'
  local title = plain(meta.footer_title)
  if title ~= "" then out = out .. '<w:p>' .. fp .. xe.runs(pandoc.text.upper(title)) .. '</w:p>' end
  return out
end

-- Letter page; margins 1 in top, bottom and right, 1.5 in left (LR IA 10-1(a)(6)); the pleading rules: a double
-- rule left of the text and a single rule right of it.
local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdNvdFooter"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" ' ..
  'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' ..
  '<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders>' ..
  '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A heading of level 2 or more: bold, its label ("I.", "A.") in a half-inch box, the text hanging after it (typst:
-- labelled()).
local function heading(b)
  local c = b.content
  local first = c[1] and c[1].t == "Str" and c[1].text or ""
  local label = first:match("^[IVXLC]+%.$") or first:match("^[A-Z]%.$") or first:match("^%d+%.$")
  if label and c[2] and c[2].t == "Space" then
    local rest = pandoc.Inlines({ table.unpack(c, 3) })
    return xe.runs(label .. "\t", { b = true }) .. xe.inl(rest, { b = true })
  end
  return xe.inl(c, { b = true })
end

-- The paragraphs of a quotation: a list in it is text, its number as typed ("1. ").
local function quote_paras(blocks, out)
  for _, q in ipairs(blocks) do
    if q.t == "OrderedList" then
      local k = q.listAttributes.start
      for _, item in ipairs(q.content) do
        local inl = pandoc.Inlines({ pandoc.Str(k .. "."), pandoc.Space() })
        inl:extend(item[1].content)
        out[#out + 1] = inl
        k = k + 1
      end
    elseif q.t == "Para" or q.t == "Plain" then
      out[#out + 1] = q.content
    else
      error("nvd-motion-brief.lua: unsupported block in a quotation: " .. q.t)
    end
  end
  return out
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  write_file("FORMBOOK_FOOTERS", "rIdNvdFooter\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = cover(meta)
  local blocks = doc.blocks
  local k = 1
  while k <= #blocks do
    local b = blocks[k]
    if b.t == "Header" then
      if b.level == 1 then
        local c = pandoc.Inlines(b.content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
        out[#out + 1] = p(xe.inl(c, { b = true }), { line = BODY, jc = "center", keep = true })
      else
        out[#out + 1] = p(heading(b), { line = BODY, left = 2 * INDENT, hanging = INDENT, keep = true })
      end
      k = k + 1
    elseif b.t == "BlockQuote" then
      -- consecutive quotations are one (typst: quoted chunks in a row), single spaced, indented both sides
      local paras = {}
      while k <= #blocks and blocks[k].t == "BlockQuote" do
        quote_paras(blocks[k].content, paras)
        k = k + 1
      end
      out[#out + 1] = p("", { line = QUOTE + SHIFT })
      for _, q in ipairs(paras) do out[#out + 1] = p(xe.inl(q), { left = INDENT, right = INDENT }) end
      out[#out + 1] = p("", { line = RESYNC + QUOTE })
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays on one page with the signature block (typst: one unbreakable block)
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = k == #blocks })
      k = k + 1
    else
      error("nvd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  if meta.certificate then
    for _, x in ipairs(certificate(meta.certificate)) do out[#out + 1] = x end
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
