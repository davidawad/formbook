-- mtb.lua (docx engine, D. Mont. bankruptcy court, motion): the motion as Word paragraphs, so that it reads and
-- breaks as typst/mtb-motion-brief.typ does: the counsel block (LBR 5005-2(b)), the court title, the caption (one row
-- per caption block, the party column ruled at its right and foot; FRBP 9004(b)), the title, the body (paragraphs
-- with the numbers the sample types, headings, block quotations, a ruled pipe table), the signature block (LBR
-- 5005-2(c)), the notice of opportunity to respond (LBR 9013-1(f)-(g), in a ruled box, bold) and the certificate of
-- service (LBR 9013-1(e)). Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 280 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 280            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local TEXTW = 9360                       -- typst text-width, 6.5 in
local CAP_LEFT = 5184                    -- typst caption-left, 3.6 in
local CAP_PAD = 120                      -- typst cap-pad, 6 pt
local CAP_PAD_FOOT = 105                 -- typst cap-pad less the 0.75 pt rule Word sets inside the cell's foot
local CASE_PAD = 240                     -- typst case-pad, 12 pt
local SIG = 4608                         -- typst sig-col, 3.2 in
local ADDR = 720                         -- typst addressee-indent, 0.5 in
local HEARING = 1728                     -- typst hearing-indent, 1.2 in
local NOTICE_PAD = 160                   -- typst notice-pad, 8 pt
local NOTICE_PAD_RULED = 145             -- typst notice-pad less the 0.75 pt rule Word sets inside the cell's top and foot
local COURT_ABOVE, CAPTION_ABOVE = 720, 480 -- typst court-above 36 pt, caption-above 24 pt
local TITLE_ABOVE, TITLE_BELOW = 480, 240   -- typst title-above 24 pt, title-below 12 pt
local QUOTE_SPACE, TABLE_SPACE = 240, 240   -- typst quote-space 12 pt, table-space 12 pt
local TABLE_RULE = 10                       -- typst table-rule 0.5 pt
local TABLE_INSET, TABLE_PAD, TABLE_CAP = 100, 60, 40 -- typst table-inset 5 pt, table-pad 3 pt, table-cap
local SIG_ABOVE, SIG_GAP = 480, 240         -- typst sig-above 24 pt, sig-gap 12 pt
local NOTICE_ABOVE, NOTICE_GAP = 480, 160   -- typst notice-above 24 pt, notice-gap 8 pt
local CERT_ABOVE, CERT_GAP, CERT_SIG = 720, 240, 480 -- typst cert-above 36 pt, cert-gap 12 pt, cert-sig-above 24 pt

local function need(meta, key)
  if meta[key] == nil then error("mtb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  local out = {}
  for _, v in ipairs(m or {}) do out[#out + 1] = v end
  return out
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

-- Single lines, one per item; an empty item is a blank line (typst: lines).
local function lines(items, o, out)
  out = out or {}
  for _, l in ipairs(items) do out[#out + 1] = p(plain(l) == "" and "" or xe.inl(l), o) end
  return out
end

local function cell(w, pr, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- A table of fixed columns, no borders and no cell margins of its own; rows are not split across pages.
local function tbl(widths, rows)
  local g, total = {}, 0
  for _, w in ipairs(widths) do
    g[#g + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  local trs = {}
  for _, r in ipairs(rows) do trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. r .. '</w:tr>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>' .. table.concat(g) ..
    '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- Vertical space of its own (typst: v(), or the space above a table): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

-- ---------------------------------------------------------------------------
-- Counsel block, court title, caption, title
-- ---------------------------------------------------------------------------

local function caption(meta)
  local rows = {}
  for _, b in ipairs(need(meta, "caption")) do
    rows[#rows + 1] = cell(CAP_LEFT, '<w:tcBorders>' .. string.format(RULE, "bottom") .. string.format(RULE, "right") ..
        '</w:tcBorders><w:tcMar><w:top w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_PAD_FOOT ..
        '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>', table.concat(lines(list(b.left)))) ..
      cell(TEXTW - CAP_LEFT, '<w:tcMar><w:top w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:left w:w="' .. CASE_PAD ..
        '" w:type="dxa"/></w:tcMar>', table.concat(lines(list(b.right))))
  end
  return tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, rows)
end

local function cover(meta, out)
  lines(list(need(meta, "counsel")), nil, out)
  if meta.counsel_role and plain(meta.counsel_role) ~= "" then
    out[#out + 1] = p(xe.inl(meta.counsel_role, { i = true }))
  end
  for i, l in ipairs(list(need(meta, "court"))) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }),
      { jc = "center", before = i == 1 and COURT_ABOVE or 0 })
  end
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = caption(meta)
  -- the title in capitals as typst upper() sets it; a section sign kept with its number (a no-break space, as xe.inl)
  local title = pandoc.text.upper(plain(need(meta, "title"))):gsub("\u{00A7} ", "\u{00A7}\u{00A0}")
  out[#out + 1] = p(xe.runs(title, { b = true }),
    { jc = "center", before = TITLE_ABOVE, after = TITLE_BELOW })
end

-- ---------------------------------------------------------------------------
-- The table (typst pipe-table): ruled, single-spaced, the width of the text; a column's width in proportion to its
-- longest cell (characters), at most TABLE_CAP, rounded to the twip, the last column the rest; the header row repeats
-- on every page; the column alignment the delimiter row sets.
-- ---------------------------------------------------------------------------

local TRULE = '<w:%s w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
local JC = { AlignRight = "right", AlignCenter = "center" }

local function pipe_table(b)
  local rows = {}
  for _, r in ipairs(b.head.rows) do rows[#rows + 1] = r end
  for _, body in ipairs(b.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = r end
  end
  local ncol = #b.colspecs
  local need_ = {}
  for j = 1, ncol do need_[j] = 0 end
  for _, r in ipairs(rows) do
    for j, c in ipairs(r.cells) do
      local n = math.min(TABLE_CAP, utf8.len(pandoc.utils.stringify(c.contents)))
      if n > need_[j] then need_[j] = n end
    end
  end
  local total = 0
  for _, n in ipairs(need_) do total = total + n end
  local widths, used = {}, 0
  for j = 1, ncol - 1 do
    widths[j] = math.floor(TEXTW * need_[j] / total + 0.5)
    used = used + widths[j]
  end
  widths[ncol] = TEXTW - used
  local borders = {}
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    borders[#borders + 1] = string.format(TRULE, side)
  end
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for i, r in ipairs(rows) do
    local tcs = {}
    for j, c in ipairs(r.cells) do
      local jc = JC[tostring(b.colspecs[j][1])] or "left"
      tcs[#tcs + 1] = cell(widths[j], nil, p(xe.inl(pandoc.utils.blocks_to_inlines(c.contents)), { jc = jc }))
    end
    local trpr = i == 1 and '<w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>' or ''
    trs[#trs + 1] = '<w:tr>' .. trpr .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>'
    .. '<w:tblBorders>' .. table.concat(borders) .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="' .. TABLE_PAD .. '" w:type="dxa"/><w:left w:w="' .. TABLE_INSET .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. TABLE_PAD .. '" w:type="dxa"/><w:right w:w="' .. TABLE_INSET .. '" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature block, notice of opportunity to respond, certificate of service
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = need(meta, "signature")
  local right = lines(list(sig.preamble))
  right[#right + 1] = p(xe.runs("/s/ ") .. xe.inl(sig.signer), { before = SIG_GAP })
  right[#right + 1] = p(xe.inl(sig.signer))
  right[#right + 1] = p(xe.inl(sig.signer_role))
  out[#out + 1] = space(SIG_ABOVE)
  out[#out + 1] = tbl({ TEXTW - SIG, SIG }, { cell(TEXTW - SIG, nil, p(xe.inl(sig.date))) ..
    cell(SIG, nil, table.concat(right)) })
end

-- LBR 9013-1(f): bold, in one ruled box kept whole (a one-cell table whose row is not split). The response period is
-- the rule's 14 days unless the sample sets response_days (a period set by another rule, LBR 9013-1(g)).
local function notice(meta, out)
  local days = meta.response_days and plain(meta.response_days) or "14"
  local B = { b = true }
  local ps = {
    p(xe.runs("NOTICE OF OPPORTUNITY TO RESPOND AND REQUEST A HEARING", B), { jc = "center" }),
    p(xe.runs("If you object to the motion, you must file a written responsive pleading and request a hearing within "
      .. days .. " days of the motion\u{2019}s date. The responding party shall schedule the hearing on the motion at "
      .. "least 21 days after the date of the response and request for a hearing and shall include in the caption of "
      .. "the responsive pleading in bold and conspicuous print the date, time, and location of the hearing by "
      .. "inserting in the caption the following:", B), { before = NOTICE_GAP }),
    p(xe.runs("NOTICE OF HEARING", B), { jc = "center", before = NOTICE_GAP }),
    p(xe.runs("Date:", B), { left = HEARING, before = NOTICE_GAP }),
    p(xe.runs("Time:", B), { left = HEARING }),
    p(xe.runs("Location:", B), { left = HEARING }),
    p(xe.runs("If no objections are timely filed, the Court may grant the relief requested as a failure to respond by "
      .. "any entity shall be deemed an admission that the relief requested should be granted.", B),
      { before = NOTICE_GAP }),
  }
  local borders = {}
  for _, side in ipairs({ "top", "left", "bottom", "right" }) do borders[#borders + 1] = string.format(RULE, side) end
  out[#out + 1] = space(NOTICE_ABOVE)
  out[#out + 1] = tbl({ TEXTW }, { cell(TEXTW, '<w:tcBorders>' .. table.concat(borders) .. '</w:tcBorders>' ..
    '<w:tcMar><w:top w:w="' .. NOTICE_PAD_RULED .. '" w:type="dxa"/><w:left w:w="' .. NOTICE_PAD .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. NOTICE_PAD_RULED .. '" w:type="dxa"/><w:right w:w="' .. NOTICE_PAD .. '" w:type="dxa"/></w:tcMar>',
    table.concat(ps)) })
end

-- The title kept with the statement; the signer's three lines kept together (typst: sticky, unbreakable).
local function certificate(meta, out)
  local c = meta.certificate
  if c == nil then return end
  local L = TEXTW - SIG
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(c.title)), { b = true }),
    { jc = "center", before = CERT_ABOVE, keep = true })
  out[#out + 1] = p(xe.inl(c.text), { line = BODY, first = INDENT, before = CERT_GAP, after = CERT_GAP })
  lines(list(c.addressees), { left = ADDR }, out)
  out[#out + 1] = p(xe.runs("/s/ ") .. xe.inl(c.signer), { left = L, before = CERT_SIG, keep = true })
  out[#out + 1] = p(xe.inl(c.signer), { left = L, keep = true })
  out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(c.date), { left = L })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: centered bold capitals on the body pitch, kept with the text after them.
local function heading(b)
  local content = pandoc.Inlines(b.content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  return xe.para({ xe.style("Heading" .. math.min(b.level, 3)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(content, { b = true }))
end

local function blocks(list_, out)
  for _, b in ipairs(list_) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = QUOTE_SPACE, after = QUOTE_SPACE, left = QUOTE, right = QUOTE })
      end
    elseif b.t == "Table" then
      out[#out + 1] = space(TABLE_SPACE)
      out[#out + 1] = pipe_table(b)
      out[#out + 1] = space(TABLE_SPACE + TABLE_RULE)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    else
      error("mtb.lua: unsupported block " .. b.t, 0)
    end
  end
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

function Pandoc(doc)
  for _, k in ipairs({ "case_number", "court", "counsel", "caption", "title", "signature" }) do
    local _ = need(doc.meta, k)
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  blocks(doc.blocks, out)
  signature(meta, out)
  notice(meta, out)
  certificate(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
