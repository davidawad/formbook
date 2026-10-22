-- mdb-motion-brief.lua (docx engine): the Maryland bankruptcy memorandum in support of a motion as Word paragraphs,
-- so that it reads and breaks as typst/mdb-motion-brief.typ does: the court lines and division, the caption (one
-- table row per line: the party text, the ")" column, and the case number, chapter and adversary number centered
-- on the party lines), the title in capitals between two rules, the indented lead-in and body paragraphs (not
-- numbered), headings, block quotations, the signature block kept with the last paragraph before it, and the
-- Certificate of Service on a new page after it. Everything printed comes from the sample's frontmatter and body:
-- no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 280 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 280            -- typst pitch-double, pitch-single
local GAP = 240                          -- typst gap-half, 12 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_CLOSE = 5184, 576    -- typst caption-left - caption-close (3.6 in), caption-close (0.4 in)
local CAP_INSET = 360                    -- typst caption-inset, 0.25 in
local SIG = 4320                         -- typst sig-indent, 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="%d" w:space="0" w:color="000000"/></w:tcBorders>'

-- A borderless table of rows of exact height: rows = { { h = twips, cells = { { w, xml, rule } ... } } }; a cell
-- with `rule` (eighths of a point) has a bottom border, and a row with one cell spans every column.
local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for _, c in ipairs(row.cells) do
      local span = #row.cells == 1 and #widths > 1 and ('<w:gridSpan w:val="' .. #widths .. '"/>') or ""
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. span ..
        (c[3] and RULE:format(c[3]) or "") .. '</w:tcPr>' .. (c[2] or p("", { line = row.h })) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. row.h .. '" w:hRule="exact"/></w:trPr>' ..
      table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- A rule: a full-width table row of `h` twips whose foot is the rule (typst: rule-block).
local function rule(h, sz)
  return tbl({ TEXTW }, { { h = h, cells = { { TEXTW, nil, sz } } } })
end

-- ---------------------------------------------------------------------------
-- Cover: court lines, division, caption, title between rules
-- ---------------------------------------------------------------------------

-- The caption's party lines: { text, indented, ruled } per row (typst: caption-rows).
local function caption_rows(cap)
  local rows = {}
  if cap.in_re then
    rows[#rows + 1] = { "In re:" }
    for _, n in ipairs(cap.in_re.names) do rows[#rows + 1] = { n } end
    rows[#rows + 1] = { cap.in_re.designation, true }
    rows[#rows + 1] = { "", false, true }
  end
  for k, party in ipairs(cap.parties) do
    if k > 1 then rows[#rows + 1] = { "v.", true } end
    for _, n in ipairs(party.names) do rows[#rows + 1] = { n } end
    rows[#rows + 1] = { party.designation, true }
  end
  return rows
end

-- The right column (typst: caption-right): the case number, then the chapter and adversary number when given.
local function caption_right(meta)
  local r = { "Case No. " .. plain(meta.case_number) }
  if plain(meta.chapter) ~= "" then r[#r + 1] = ""; r[#r + 1] = "Chapter " .. plain(meta.chapter) end
  if plain(meta.adv_number) ~= "" then r[#r + 1] = ""; r[#r + 1] = "Adv. Pro. No. " .. plain(meta.adv_number) end
  return r
end

local function caption(meta)
  local rows = caption_rows(meta.caption)
  local right = caption_right(meta)
  local first = math.max(0, (#rows - #right) // 2)
  local out = {}
  for i, r in ipairs(rows) do
    local k = i - 1 - first
    local rt = (k >= 0 and k < #right) and right[k + 1] or ""
    out[#out + 1] = { h = SINGLE, cells = {
      { CAP_LEFT, (not r[3]) and p(xe.inl(r[1]), { left = r[2] and INDENT or 0 }) or nil, r[3] and 4 or nil },
      { CAP_CLOSE, p(xe.runs(")")) },
      { TEXTW - CAP_LEFT - CAP_CLOSE, p(xe.inl(rt), { left = CAP_INSET }) },
    } }
  end
  return tbl({ CAP_LEFT, CAP_CLOSE, TEXTW - CAP_LEFT - CAP_CLOSE }, out)
end

local function cover(meta)
  local out = {}
  for _, t in ipairs(meta.court) do out[#out + 1] = p(xe.inl(t, { b = true }), { jc = "center" }) end
  if plain(meta.division) ~= "" then out[#out + 1] = p(xe.inl(meta.division, { b = true }), { jc = "center" }) end
  -- typst: the caption block stands a double line below the court lines
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = caption(meta)
  out[#out + 1] = rule(GAP, 6)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.title)), { b = true }), { jc = "center", before = GAP, line = BODY })
  out[#out + 1] = rule(GAP, 6)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: the date, then the firm and signer at the signature column; kept together
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local rows = { { xe.inl(meta.date), 0, BODY }, { xe.runs("Respectfully submitted:"), SIG, GAP } }
  for i, f in ipairs(sig.firm) do rows[#rows + 1] = { xe.inl(f), SIG, i == 1 and GAP or 0 } end
  rows[#rows + 1] = { xe.inl(sig.signer), SIG, GAP }
  for _, l in ipairs(sig.lines) do rows[#rows + 1] = { xe.inl(l), SIG, 0 } end
  local out = {}
  for i, r in ipairs(rows) do out[#out + 1] = p(r[1], { left = r[2], before = r[3], keep = i < #rows }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, bold, kept with the text: level 1 centered underlined capitals, levels 2 and 3 at the
-- margin. The Heading styles give the outline level; the certificate's heading opens a new page.
local function heading(b, brk)
  local content = b.content
  local lvl = math.min(b.level, 3)
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return p(xe.inl(content, { b = true, u = lvl == 1 }), { style = "Heading" .. lvl, keep = true, brk = brk,
    line = BODY, jc = lvl == 1 and "center" or "left" })
end

-- Inlines as runs, the sample's own line breaks ("\\" at a line end) kept as Word line breaks.
local function inl_br(inlines)
  local parts, cur = {}, pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "LineBreak" then parts[#parts + 1] = cur; cur = pandoc.Inlines({}) else cur:insert(el) end
  end
  parts[#parts + 1] = cur
  local body = {}
  for i, x in ipairs(parts) do body[#body + 1] = (i > 1 and xe.BR or "") .. xe.inl(x) end
  return table.concat(body)
end

-- A block quotation's paragraph: single-spaced, indented both sides.
local function quote_par(inlines, keep)
  return p(inl_br(inlines), { before = GAP, after = GAP, left = QUOTE, right = QUOTE, keep = keep })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

local function body_blocks(list, out, keep_last)
  for k, b in ipairs(list) do
    local keep = keep_last and k == #list
    if b.t == "Header" then
      out[#out + 1] = heading(b, b.level == 1 and plain(b.content):match("^Certificate of Service") ~= nil)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do out[#out + 1] = quote_par(q.content, keep) end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(inl_br(b.content), { line = BODY, first = INDENT, keep = keep })
    else
      error("mdb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = cover(meta)
  if plain(meta.lead_in) ~= "" then
    local lead = pandoc.read(plain(meta.lead_in), "markdown+smart").blocks[1]
    out[#out + 1] = p(xe.inl(lead.content), { line = BODY, first = INDENT, before = GAP })
  end
  -- The body up to the Certificate of Service, its last block kept with the signature (typst: one unbreakable
  -- block); then the certificate.
  local body, cert = {}, {}
  local target = body
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):match("^Certificate of Service") then target = cert end
    target[#target + 1] = b
  end
  body_blocks(body, out, true)
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  body_blocks(cert, out, false)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
