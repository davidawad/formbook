-- U.S. Bankruptcy Court, M.D. La.: motion with incorporated memorandum, DOCX engine (docs/DOCX.md).
-- Mirrors ../typst/lamb-motion-brief.typ: Form 416 style caption (main case, or adversary when the frontmatter has a
-- plaintiff), title, notice of motion and opportunity for hearing (LR 9013-1(b)(2)), the body (LR 9013-2), signature
-- block with contact details (LR 9013-1(a)). Every string comes from the YAML frontmatter; nothing is case-specific
-- here. Font, spacing, margins and the page number are styles and section settings in docx/reference.xml (fb render
-- builds the reference document from it). Footnotes are pandoc's native footnotes (style "footnote text", 12 pt).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 313 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 313              -- typst pitch-body 24 pt, pitch-single 15.65 pt
local TEXTW = 9360                         -- typst text-width, 6.5 in
local COL, GUTTER = 4500, 360              -- typst caption-col, caption-gutter 0.25 in
local CAP_PAD, CASE_PAD = 173, 144         -- typst caption-pad 8.65 pt, case-pad 0.1 in
local LABEL, V_IND = 2160, 1080            -- typst label-indent 1.5 in, v-indent 0.75 in
local COURT_BELOW = 360                    -- typst court-below 18 pt
local IN_RE_GAP, GROUP_GAP, V_GAP = 48, 216, 108 -- typst in-re-gap 2.4 pt, group-gap 10.8 pt, v-gap 5.4 pt
local CAPTION_BELOW, TITLE_BELOW = 336, 216 -- typst caption-below 16.8 pt, title-below 10.8 pt
local SIG_ABOVE, SIG_GAP, CONTACT_GAP = 240, 216, 48 -- typst signature-above 12 pt, signature-gap 10.8 pt, contact-gap
local TABLE_SPACE, TABLE_RULE = 120, 10    -- typst table-space 6 pt, table-rule 0.5 pt
local TABLE_INSET, TABLE_PAD, TABLE_CAP = 100, 60, 40 -- typst table-inset 5 pt, table-pad 3 pt, table-cap

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("lamb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- A metadata value as plain text, as typst reads the YAML string: pandoc's abbreviation no-break spaces undone.
local function txt(v)
  return v and (pandoc.utils.stringify(v):gsub("\u{00A0}", " ")) or ""
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph: o = { before, after, line (single), left, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function line(v, o)
  return xe.runs(txt(v), o)
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- Two columns and the gutter, fixed widths, no borders and no cell margins unless a cell sets its own; the row is
-- not split across pages (typst: one grid row).
local function grid3(left, right, left_extra, right_extra)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (2 * COL + GUTTER) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. COL .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="' .. COL
    .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(COL, left, left_extra) .. cell(GUTTER, p("")) .. cell(COL, right, right_extra) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Caption, title, notice
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(m)
  local out = {
    p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }),
    p(xe.runs("MIDDLE DISTRICT OF LOUISIANA", { b = true }), { jc = "center" }),
    space(COURT_BELOW),
  }
  local left = { p(xe.runs("In re:")), p(line(need(m, "debtor")), { before = IN_RE_GAP }),
    p(xe.runs("Debtor."), { left = LABEL }) }
  if m.plaintiff ~= nil then
    for i, l in ipairs(items(m.plaintiff)) do
      left[#left + 1] = p(line(l), { before = i == 1 and GROUP_GAP or 0 })
    end
    left[#left + 1] = p(xe.runs("Plaintiff,"), { left = LABEL })
    left[#left + 1] = p(xe.runs("v."), { left = V_IND, before = V_GAP })
    for i, l in ipairs(items(need(m, "defendants"))) do
      left[#left + 1] = p(line(l), { before = i == 1 and V_GAP or 0 })
    end
    left[#left + 1] = p(xe.runs("Defendant."), { left = LABEL })
  end
  local right = {
    p(xe.runs("Case No. " .. txt(need(m, "case_no")))),
    p(line(need(m, "chapter")), { before = IN_RE_GAP }),
  }
  if m.adv_no ~= nil then
    right[#right + 1] = p(xe.runs("Adversary Proceeding No. " .. txt(m.adv_no)), { before = IN_RE_GAP })
  end
  local borders = '<w:tcBorders>' .. string.format(RULE, "bottom") .. string.format(RULE, "right") .. '</w:tcBorders>'
  local mar = '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = grid3(table.concat(left), table.concat(right), borders .. mar,
    '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>')
  -- The title, centred bold capitals on the body pitch (typst upper(); the text is upper-cased, not a style).
  out[#out + 1] = p(xe.runs(txt(need(m, "title")):upper(), { b = true }),
    { jc = "center", line = BODY, before = CAPTION_BELOW })
  -- The notice of motion and opportunity for hearing (LR 9013-1(b)(2)); the objection wording follows the rule. The
  -- title in curly quotes, as typst sets the straight quotes of its markup.
  local h = need(m, "hearing")
  out[#out + 1] = p(xe.runs("NOTICE OF MOTION AND OPPORTUNITY FOR HEARING", { b = true }),
    { jc = "center", line = BODY, before = TITLE_BELOW, keep = true })
  local notice = {
    'PLEASE TAKE NOTICE that the motion titled \u{201C}' .. txt(need(m, "title")) .. '\u{201D} has been filed. The motion seeks '
      .. txt(need(m, "relief")),
    "A hearing on the motion is set for " .. txt(need(h, "date")) .. " at " .. txt(need(h, "time")) .. ", in "
      .. txt(need(h, "place")) .. ".",
    "Any party opposing the motion must file an objection or response no later than eight days before the scheduled "
      .. "hearing and must at the same time serve a copy of the objection or response on the mover or its counsel, "
      .. "and on all other parties entitled to notice of the objection.",
  }
  for _, s in ipairs(notice) do out[#out + 1] = p(xe.runs(s), { line = BODY, first = 720 }) end
  out[#out + 1] = space(TITLE_BELOW)
  return table.concat(out)
end

-- Dated line on the left, signature and contact block on the right (typst signature()), after typst
-- signature-above of space of its own.
local function signature(m)
  local s = need(m, "signature")
  local c = need(m, "contact")
  local right = { p(xe.runs("Respectfully submitted,")),
    p(xe.runs("/s/ " .. txt(s.signer)), { before = SIG_GAP }) }
  for _, l in ipairs(items(s.lines)) do right[#right + 1] = p(line(l, { i = true })) end
  for i, l in ipairs(items(need(c, "address"))) do
    right[#right + 1] = p(line(l, { i = true }), { before = i == 1 and CONTACT_GAP or 0 })
  end
  right[#right + 1] = p(xe.runs("Telephone: " .. txt(need(c, "phone")), { i = true }))
  right[#right + 1] = p(xe.runs("Email: " .. txt(need(c, "email")), { i = true }))
  return space(SIG_ABOVE) .. grid3(p(xe.runs("Dated: " .. txt(need(m, "date")))), table.concat(right))
end

-- ---------------------------------------------------------------------------
-- The table (typst pipe-table): ruled, single-spaced, the width of the text; a column's width in proportion to its
-- longest cell (characters), at most TABLE_CAP, rounded to the twip, the last column the rest; the header row repeats
-- on every page; a row longer than the rest of a page splits there, between two lines.
-- ---------------------------------------------------------------------------

local TRULE = '<w:%s w:val="single" w:sz="4" w:space="0" w:color="000000"/>'

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
      local inl = pandoc.utils.blocks_to_inlines(c.contents)
      tcs[#tcs + 1] = cell(widths[j], p(xe.inl(inl)))
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
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("4001(b)(1)(B)(i)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a
-- slash followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither
-- shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

-- A paragraph that anchors a footnote has no widow control (the "Note" styles, docx/reference.xml).
local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function styled(style, inlines)
  if has_note(inlines) then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "title", "relief", "hearing", "debtor", "case_no", "chapter", "date", "signature", "contact" }) do
    local _ = need(m, k)
  end
  if m.plaintiff ~= nil then local _ = need(m, "defendants") end

  local out = { xe.raw(cover(m)) }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- Level 1 in capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
      local c = b.content
      if b.level == 1 then
        c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "Para" or b.t == "Plain" then
      -- The conclusion stays with the signature block that follows it (typst sticky).
      local wherefore = pandoc.utils.stringify(b):sub(1, 9) == "WHEREFORE"
      out[#out + 1] = styled(wherefore and "Conclusion" or "Body Text", b.content)
    elseif b.t == "Table" then
      out[#out + 1] = xe.raw(space(TABLE_SPACE) .. pipe_table(b) .. space(TABLE_SPACE + TABLE_RULE))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      -- The block quotation (Block Text) is kept as pandoc writes it.
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
