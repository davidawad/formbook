-- Motion with memorandum for the United States Bankruptcy Court for the District of Columbia (dcb), docx engine: what
-- the Word output adds to pandoc's conversion, so that it reads and breaks as typst/dcb-motion-brief.typ does (README
-- "Engines"): the counsel block (LBR 5005-1(c)), the court title and the ")" caption (FRBP 9004(b)), the title, the
-- notice box (LBR 9013-1(c), (d)), the headings, the block quotations, the signature block and the certificate of
-- service (LBR 9013-1(f)). Everything printed comes from the sample's frontmatter and body: no case text lives in
-- this file. Caption, notice and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent and quote-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_MID = 4752, 504      -- typst caption-left 3.3 in, caption-mid 0.35 in
local BOX_INSET = 200                    -- typst box-inset, 10 pt
local SIG_LEFT, SIG_GUTTER = 4032, 288   -- typst sig-left 2.8 in, sig-gutter 0.2 in
local CERT_COL = 4032                    -- typst cert-col, 2.8 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single lines, the first with space above it.
local function group(lines, before, keep)
  local out = {}
  for i, l in ipairs(lines) do out[#out + 1] = p(xe.inl(l), { before = i == 1 and before or 0, keep = keep }) end
  return out
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
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body or c) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, caption, title, notice
-- ---------------------------------------------------------------------------

local function cover(meta)
  local c = meta.counsel
  local lines = { c.name, c.firm }
  for _, l in ipairs(c.address) do lines[#lines + 1] = l end
  lines[#lines + 1] = c.phone
  lines[#lines + 1] = c.email
  for _, l in ipairs(c.represents) do lines[#lines + 1] = l end
  local out = group(lines, 0)
  for i, l in ipairs(meta.court) do
    out[#out + 1] = p(xe.runs(plain(l), { b = true }), { jc = "center", before = i == 1 and BODY or 0,
      after = i == #meta.court and SINGLE or 0 })
  end
  -- The caption: one table row per line (typst: one grid row per line).
  local cap = meta.caption
  local left = {}
  local function add(list) for _, x in ipairs(list) do left[#left + 1] = x end end
  add(cap.debtor.names)
  add({ cap.debtor.designation, "" })
  add(cap.plaintiff.names)
  add({ cap.plaintiff.designation, "vs.", "Adversary No. " .. plain(cap.adversary_number), "" })
  add(cap.defendant.names)
  add({ cap.defendant.designation })
  local rows = {}
  for i, l in ipairs(left) do
    local right = ""
    if i == 1 then right = "In re:"
    elseif i == 2 then right = "Case No. " .. plain(cap.case_number)
    elseif i == 3 then right = "(Chapter " .. plain(cap.chapter) .. ")" end
    rows[#rows + 1] = { { p(xe.inl(l)) }, { p(xe.runs(")"), { jc = "center" }) }, { p(xe.inl(right)) } }
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_MID, TEXTW - CAP_LEFT - CAP_MID }, rows)
  -- typst: the caption stands a single line above the title (Word has no space after a table)
  out[#out + 1] = p(xe.runs(plain(meta.title), { b = true }), { jc = "center", before = SINGLE })
  -- The notice (LBR 9013-1(c), (d)): a ruled box, its text 10 pt inside the rule; a blank field a fill-in line.
  local n = meta.notice
  local function fill(s)
    s = plain(s)
    return s == "" and "________________" or s
  end
  local rule = 'w:val="single" w:sz="5" w:space="0" w:color="000000"'
  out[#out + 1] = p("", { line = 20, before = SINGLE, keep = true })
  out[#out + 1] = tbl({ TEXTW }, { { {
    pr = '<w:tcBorders><w:top ' .. rule .. '/><w:left ' .. rule .. '/><w:bottom ' .. rule .. '/><w:right ' .. rule ..
      '/></w:tcBorders><w:tcMar><w:top w:w="' .. BOX_INSET .. '" w:type="dxa"/><w:left w:w="' .. BOX_INSET ..
      '" w:type="dxa"/><w:bottom w:w="' .. BOX_INSET .. '" w:type="dxa"/><w:right w:w="' .. BOX_INSET ..
      '" w:type="dxa"/></w:tcMar>',
    body = {
      p(xe.runs("NOTICE OF MOTION, OBJECTION DEADLINE, AND HEARING", { b = true }), { jc = "center" }),
      p(xe.runs("Any response to this motion must be filed with the Court and served on the movant\u{2019}s counsel no later than ")
        .. xe.runs(fill(n.response_deadline), { i = true })
        .. xe.runs(". If no response is timely filed, the Court may grant the relief requested without a hearing. A hearing on this motion is set for ")
        .. xe.runs(fill(n.hearing), { i = true }) .. xe.runs("."), { before = SINGLE }),
    } } } }, '<w:trPr><w:cantSplit/></w:trPr>')
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (LBR 9013-1(f))
-- ---------------------------------------------------------------------------

local function sig_lines(s, role)
  local lines = { "/s/ " .. plain(s.signer), s.signer }
  for _, l in ipairs(s.address) do lines[#lines + 1] = l end
  lines[#lines + 1] = "Phone: " .. plain(s.phone)
  lines[#lines + 1] = "Email: " .. plain(s.email)
  if role then for _, l in ipairs(s.role) do lines[#lines + 1] = l end end
  return lines
end

local function signature(s)
  local left = { p(xe.runs("Date: ") .. xe.inl(s.date), { before = BODY }) }
  local right = group({ "Respectfully submitted,", s.firm }, BODY)
  for _, x in ipairs(group(sig_lines(s, true), SINGLE)) do right[#right + 1] = x end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { left,
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- On one page (typst: an unbreakable block): every paragraph kept with the next, the signature row unsplit.
local function certificate(s, sig)
  local out = {
    p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", before = BODY, after = SINGLE, keep = true }),
    p(xe.runs("I HEREBY CERTIFY that on " .. plain(s.date) .. ", a copy of the foregoing was served through ") ..
      xe.inl(s.method) .. xe.runs(", on the following:"), { line = BODY, first = INDENT, after = SINGLE, keep = true }),
  }
  for _, r in ipairs(s.recipients) do
    local lines = { r.name }
    for _, l in ipairs(r.lines) do lines[#lines + 1] = l end
    for _, x in ipairs(group(lines, SINGLE, true)) do out[#out + 1] = x end
  end
  -- typst: the signature grid a double line below the recipients (Word puts it on an empty paragraph in the left cell)
  out[#out + 1] = tbl({ TEXTW - CERT_COL, CERT_COL }, { { { p("", { before = BODY }) }, group(sig_lines(sig, false), BODY) } },
    '<w:trPr><w:cantSplit/></w:trPr>')
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: single-spaced, a single line above and below, kept with the text after them; level 1 centered bold,
-- level 2 bold, level 3 bold italic, a step in.
local function heading(el)
  local runs = xe.inl(el.content, { b = true, i = el.level >= 3 })
  return xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(SINGLE, SINGLE, SINGLE),
    xe.ind(el.level >= 3 and INDENT or 0, nil, 0), xe.jc(el.level == 1 and "center" or "left") },
    (runs:gsub("<w:r><w:rPr>(.-)</w:rPr>", function(x)
      -- schema order: bold, italic, then capitals off (the Heading 1 style sets them; typst prints the text as written)
      local at = x:find("<w:sz", 1, true) or (#x + 1)
      return "<w:r><w:rPr>" .. x:sub(1, at - 1) .. '<w:caps w:val="0"/>' .. x:sub(at) .. "</w:rPr>"
    end)))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = cover(meta)
  -- typst: the notice box stands a single line above the text (Word has no space after a table)
  local gap = SINGLE
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for j, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT, before = j == 1 and SINGLE or 0,
          after = j == #b.content and SINGLE or 0 })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, before = gap })
    else
      error("dcb-motion-brief.lua: unsupported block " .. b.t)
    end
    gap = 0
  end
  out[#out + 1] = signature(meta.signature)
  for _, x in ipairs(certificate(meta.service, meta.signature)) do out[#out + 1] = x end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
