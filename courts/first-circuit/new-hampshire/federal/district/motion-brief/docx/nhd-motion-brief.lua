-- Motion to dismiss with accompanying memorandum of law (nhd), docx engine: what the Word output adds to pandoc's
-- conversion, so that it reads and breaks as typst/nhd-motion-brief.typ does: the court title, the caption with the
-- column of ")" marks (LR 5.1(c)), the title, the headings, the body paragraphs, the lettered items, the signature
-- block (LR 5.1(b)) and the certificate of service (LR 5.1(d)). Everything printed comes from the sample's frontmatter
-- and body: no case text lives in this file. Caption, signature and certificate are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local ITEM = 1584                        -- typst item-indent + item-box: the text of a lettered item, 1.1 in
local STEP = 720                         -- typst heading-step 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_NAMES, CAP_PAREN = 5328, 432   -- typst caption-names 3.7 in, caption-paren 0.3 in
local SIG = 4680                         -- typst sig-indent 3.25 in

local stringify = pandoc.utils.stringify

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Plain text lines (the caption, signature and certificate fields carry no markdown, as in the typst template).
local function plain(v) return xe.runs(type(v) == "string" and v or stringify(v)) end

-- A table of rows (each a list of cells, each a list of paragraphs); trpr on every row.
local function tbl(widths, rows, trpr)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, w in ipairs(widths) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(cells[i]) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center", keep = true })
  out[#out + 1] = p(xe.runs("FOR THE DISTRICT OF NEW HAMPSHIRE", { b = true }), { jc = "center", keep = true })
  -- One single-spaced row per line of the party block, "v." between the parties, a ")" in the middle column of each
  -- row, and the case number on the middle row. The caption stands a single line below the court title (typst: the
  -- caption block's above): the first row's paragraphs carry it.
  local lines = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then lines[#lines + 1] = "v." end
    for _, n in ipairs(party.names) do lines[#lines + 1] = n end
    lines[#lines + 1] = party.designation
  end
  local mid = #lines // 2                -- 0-based, as the typst template
  local rows = {}
  for i, l in ipairs(lines) do
    local o = { before = i == 1 and SINGLE or 0 }
    rows[#rows + 1] = { { p(plain(l), o) }, { p(xe.runs(")"), o) },
      { p(i - 1 == mid and plain(meta.case_number) or "", o) } }
  end
  out[#out + 1] = tbl({ CAP_NAMES, CAP_PAREN, TEXTW - CAP_NAMES - CAP_PAREN }, rows)
  -- the title a single line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(stringify(meta.title)), { b = true }),
    { line = BODY, before = SINGLE, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, bold: level 1 centered caps; level 2 flush left; level 3 indented a step; level 4
-- italic, two steps in (typst heading-step).
local function heading(level, content, before)
  if level == 1 then content = upper(content) end
  local left = STEP * math.max(level - 2, 0)
  return xe.para({ xe.style("Heading" .. level), xe.KEEP, xe.spacing(before or 0, 0, BODY), xe.ind(left, nil, 0),
    xe.jc(level == 1 and "center" or "left") }, xe.inl(content, { b = true, i = level >= 4 }))
end

local function body_par(inlines) return p(xe.inl(inlines), { line = BODY, first = INDENT }) end

local function body(blocks, out)
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b.level, b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content)
    elseif b.t == "OrderedList" then
      -- lettered items (a), (b), ... (typst enum "(a)"): the letter half an inch in, the text 1.1 in, hanging
      local start = b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ("(" .. string.char(96 + start + j - 1) .. ")\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = ITEM, hanging = ITEM - INDENT })
        end
      end
    else
      error("nhd-motion-brief: unsupported block " .. b.t)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature (LR 5.1(b)) and certificate of service (LR 5.1(d)): plain paragraphs kept together (keep-with-next), not
-- a table, so that the space above a block is dropped when it opens a page, as typst drops it
-- ---------------------------------------------------------------------------

-- Groups of single lines at the right half of the page, a blank single line between them, a blank double line above.
local function signature(meta, out)
  local s = meta.signature
  if not s then error("nhd-motion-brief: the sample needs a signature block (LR 5.1(b))", 0) end
  local groups = { { s.intro } }
  if s.party then groups[#groups + 1] = s.party end
  if s.date then groups[#groups + 1] = { s.date } end
  groups[#groups + 1] = { "/s/ " .. stringify(s.signer) }
  for _, b in ipairs(s.blocks or {}) do groups[#groups + 1] = b end
  for i, g in ipairs(groups) do
    for j, l in ipairs(g) do
      local before = 0
      if j == 1 then before = i == 1 and BODY or SINGLE end
      local last = i == #groups and j == #g
      out[#out + 1] = p(plain(l), { before = before, left = SIG, keep = not last })
    end
  end
end

-- The heading a blank double line below the signature, the text, the signer a blank double line below it: plain
-- paragraphs kept together (keep-with-next), not a table, so that the space above the heading is dropped when it
-- opens a page, as typst drops it.
local function certificate(meta, out)
  local cert = meta.certificate
  out[#out + 1] = heading(1, pandoc.Inlines({ pandoc.Str("Certificate"), pandoc.Space(), pandoc.Str("of"),
    pandoc.Space(), pandoc.Str("Service") }), BODY)
  out[#out + 1] = p(plain(cert.text), { line = BODY, first = INDENT, keep = true })
  for j, l in ipairs(cert.signer) do
    out[#out + 1] = p(plain(l), { before = j == 1 and BODY or 0, left = SIG, keep = j < #cert.signer })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 2201"), as the typst template boxes it (xe.inl binds a single sign).
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
  for _, k in ipairs({ "caption", "case_number", "title", "signature" }) do
    if doc.meta[k] == nil then error("nhd-motion-brief: missing required metadata field `" .. k .. "`", 0) end
  end
  local meta = doc.meta
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local out = {}
  cover(meta, out)
  body(doc.blocks, out)
  signature(meta, out)
  if meta.certificate then certificate(meta, out) end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  -- empty metadata: pandoc would otherwise write the frontmatter title as a Title paragraph
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
