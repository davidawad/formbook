-- tnwb-motion-brief.lua (docx engine): the W.D. Tenn. bankruptcy memorandum of law in support of a motion as Word
-- paragraphs, so that it reads and breaks as ../typst/tnwb-motion-brief.typ (the reference for the form) does:
--   * the court heading, the caption (FRBP 9004(b), 7010, Form 416 contents: a table, the parties on the left, a
--     section mark on every line, the case and adversary numbers on the right, a rule under the debtor block and
--     under the parties) and the title, written here;
--   * the body: headings (a typed label "A." in a half-inch box, the text hanging), tables and quotations written
--     here; paragraphs left to pandoc in the styles of docx/reference.xml, so their footnotes stay Word footnotes
--     (a paragraph that opens with a typed number "1." sets it at the indent with a tab to 1 in); lists as List Item;
--   * the signature block (LBR 1001-3(h)) at 3 in, kept with the last paragraph, and the certificate of service on a
--     page of its own (FRBP 9013(b); the exemplar's wording).
-- Every case word comes from the YAML frontmatter or the body. No coordinates, no forced line breaks.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 276, 240   -- typst pitch-body 24 pt, pitch-single 13.8 pt, gap (half a body line)
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT, CAP_MARK = 4752, 720      -- typst cap-left 3.3 in, cap-mark 0.5 in
local CAP_DESIGNATION, CAP_VERSUS = 2160, 720 -- typst cap-designation 1.5 in, cap-versus 0.5 in
local RULE_SZ, RULE = 4, 10               -- typst rule 0.5 pt (w:sz in eighths of a point; twips)
local TABLE_W = 5616                      -- typst table-width 60 % of 6.5 in
local CELL_X, CELL_Y = 160, 60            -- typst table-inset 8 pt, 3 pt
local HEAD_BOX = 720                      -- typst heading-box 0.5 in
local SIG = 4320                          -- typst signature-indent 3 in
local GUTTER = 432                        -- typst service-gutter 0.3 in
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(v)
  if v == nil then return {} end
  if type(v) == "string" or v.t == "MetaInlines" or v.t == "MetaString" then return { v } end
  local out = {}
  for _, x in ipairs(v) do out[#out + 1] = x end
  return out
end

-- A paragraph: o = { before, after, line, left, first, hanging, tab, jc, keep, brk } (keep: with the next paragraph
-- and its lines together; brk: a page break before it; tab: a left tab stop, twips). Single-spaced unless o.line.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" '
  .. 'w:noHBand="1" w:noVBand="1"/>'

local function border(side)
  return "<w:" .. side .. ' w:val="single" w:sz="' .. RULE_SZ .. '" w:space="0" w:color="000000"/>'
end

-- ---------------------------------------------------------------------------
-- Court heading, caption, title (FRBP 9004(b), 7010; Form 416 contents)
-- ---------------------------------------------------------------------------

local function court_heading(m, out)
  local lines = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF TENNESSEE" }
  if plain(m.division) ~= "" then lines[#lines + 1] = pandoc.text.upper(plain(m.division)) end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l), { jc = "center", after = i == #lines and BODY or 0 })
  end
end

-- typst caption: rows of (left, right, left indent, rule below). LibreOffice adds a cell's bottom border to its row's
-- height; typst gives a ruled row a bottom inset of the rule's width, so both rows grow by it.
local function caption(m, out)
  local rows = {}
  local function row(l, r, ind, ruled) rows[#rows + 1] = { l or "", r or "", ind or 0, ruled } end
  local debtor, chapter = list(m.debtor), list(m.chapter)
  local plaintiffs, defendants = list(m.plaintiffs), list(m.defendants)
  row("IN RE:")
  row("")
  local right = { "CASE NO.: " .. plain(m.case_number) }
  for _, c in ipairs(chapter) do right[#right + 1] = plain(c) end
  for i, d in ipairs(debtor) do row(pandoc.text.upper(plain(d)), right[i]) end
  for i = #debtor + 1, #right do row("", right[i]) end
  row("")
  row("DEBTOR.", nil, CAP_DESIGNATION)
  row("", nil, 0, true)
  for i, x in ipairs(plaintiffs) do
    row(pandoc.text.upper(plain(x)), i == 1 and ("ADVERSARY PROCEEDING NO.: " .. plain(m.adversary_number)) or "")
  end
  row(#plaintiffs > 1 and "Plaintiffs," or "Plaintiff,", nil, CAP_DESIGNATION)
  row("")
  row("vs.", nil, CAP_VERSUS)
  row("")
  for _, x in ipairs(defendants) do row(pandoc.text.upper(plain(x))) end
  row(#defendants > 1 and "Defendants." or "Defendant.", nil, CAP_DESIGNATION, true)

  local widths = { CAP_LEFT, CAP_MARK, TEXTW - CAP_LEFT - CAP_MARK }
  local x = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do x[#x + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  x[#x + 1] = "</w:tblGrid>"
  for _, r in ipairs(rows) do
    local function cell(j, body, ruled)
      local b = ruled and ("<w:tcBorders>" .. border("bottom") .. "</w:tcBorders>") or ""
      return '<w:tc><w:tcPr><w:tcW w:w="' .. widths[j] .. '" w:type="dxa"/>' .. b .. "</w:tcPr>" .. body .. "</w:tc>"
    end
    x[#x + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
      .. cell(1, p(xe.inl(r[1]), { left = r[3] }), r[4])
      .. cell(2, p(xe.runs("\u{00A7}"), { jc = "center" }), r[4])
      .. cell(3, p(xe.inl(r[2])), false)
      .. "</w:tr>"
  end
  x[#x + 1] = "</w:tbl>"
  out[#out + 1] = table.concat(x)
  -- the title: Word has no space after a table, so it takes the space before it
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(m.title)), { b = true }),
    { jc = "center", before = GAP, after = GAP, keep = true })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: single-spaced, half a body line from the text on either side, kept with the text; level 1 centered bold
-- capitals, level 2 centered bold, level 3 bold at the margin, a typed label ("A.") in a half-inch box with the text
-- hanging after it.
local function heading(el)
  local inl = el.content
  if el.level == 1 then
    return p(xe.inl(inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }), { b = true }),
      { keep = true, before = GAP, after = GAP, jc = "center" })
  elseif el.level == 2 then
    return p(xe.inl(inl, { b = true }), { keep = true, before = GAP, after = GAP, jc = "center" })
  end
  local a, b = inl[1], inl[2]
  if a and a.t == "Str" and b and b.t == "Space" and (a.text:match("^%u%.$") or a.text:match("^%d+%.$")
      or a.text:match("^[ivxIVX]+%.$")) then
    local rest = pandoc.Inlines({})
    for i = 3, #inl do rest:insert(inl[i]) end
    return p(xe.runs(a.text .. "\t", { b = true }) .. xe.inl(rest, { b = true }),
      { keep = true, before = GAP, after = GAP, left = HEAD_BOX, hanging = HEAD_BOX, tab = HEAD_BOX })
  end
  return p(xe.inl(inl, { b = true }), { keep = true, before = GAP, after = GAP })
end

-- A table (a markdown pipe table; typst transfer-table): centered, 60 % of the text width, the columns equal, single-spaced, 0.5 pt
-- rules, the header row bold and centered; rows not split, the header not repeated. LibreOffice sets a row's bottom
-- rule inside its padding: the padding below is less by the rule's width.
local function transfer_table(b, out)
  local rows = {}
  for _, r in ipairs(b.head.rows) do rows[#rows + 1] = r end
  for _, body in ipairs(b.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = r end
  end
  local ncol = #b.colspecs
  local w = math.floor(TABLE_W / ncol)
  local all = { "top", "left", "bottom", "right", "insideH", "insideV" }
  local borders = {}
  for _, s in ipairs(all) do borders[#borders + 1] = border(s) end
  local x = { '<w:tbl><w:tblPr><w:tblW w:w="' .. (w * ncol) .. '" w:type="dxa"/><w:jc w:val="center"/>'
    .. "<w:tblBorders>" .. table.concat(borders) .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="' .. CELL_Y .. '" w:type="dxa"/><w:left w:w="' .. CELL_X
    .. '" w:type="dxa"/><w:bottom w:w="' .. (CELL_Y - RULE) .. '" w:type="dxa"/><w:right w:w="' .. CELL_X
    .. '" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. "</w:tblPr><w:tblGrid>" }
  for _ = 1, ncol do x[#x + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  x[#x + 1] = "</w:tblGrid>"
  for i, r in ipairs(rows) do
    x[#x + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for j = 1, ncol do
      local c = r.cells[j]
      local inl = c and pandoc.Inlines(xe.inlines(pandoc.utils.blocks_to_inlines(c.contents))) or nil
      local body = inl and xe.inl(inl, { b = i == 1 }) or ""
      x[#x + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>'
        .. p(body, { jc = i == 1 and "center" or "left" }) .. "</w:tc>"
    end
    x[#x + 1] = "</w:tr>"
  end
  x[#x + 1] = "</w:tbl>"
  -- typst spacer(gap) above and below: empty paragraphs of half a body line (kept at the top of a page, as typst's
  -- block of that height is)
  out[#out + 1] = xe.raw(p("", { line = GAP }))
  out[#out + 1] = xe.raw(table.concat(x))
  out[#out + 1] = xe.raw(p("", { line = GAP }))
end

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

-- A paragraph pandoc writes (its footnotes stay notes), in a style of docx/reference.xml, after an optional label
-- and tab. A paragraph that anchors a footnote takes the style's "Note" variant (no widow control), the kept one
-- its "Keep" variant.
local function styled(base, inlines, label, keep)
  local l = pandoc.Inlines({})
  if label then
    l:insert(pandoc.Str(label))
    l:insert(TAB)
  end
  l:extend(inlines)
  local name = base
  if keep then
    name = base == "Body Text" and "Body Keep" or base .. " Keep"
  elseif has_note(inlines) then
    name = base .. " Note"
  end
  return pandoc.Div({ pandoc.Para(l:walk({ Inlines = xe.inlines })) }, { ["custom-style"] = name })
end

-- A block quotation: single-spaced, half an inch in on both sides, half a body line around it.
local function quotation(b, out)
  local paras = {}
  for _, x in ipairs(b.content) do
    if x.t == "Para" or x.t == "Plain" then paras[#paras + 1] = x.content end
  end
  for i, inl in ipairs(paras) do
    out[#out + 1] = xe.raw(xe.para({ xe.spacing(i == 1 and GAP or 0, i == #paras and GAP or 0, SINGLE),
      xe.ind(720, nil, 0, 720), xe.jc("left") }, xe.inl(inl)))
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 1001-3(h)) at 3 in, half a body line below the last paragraph: the closing, the firm (bold) a
-- single line below it, the /s/ signature, the name line, the address and contact lines and the role (italic);
-- kept together and with the last paragraph.
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local s = m.signature
  local lines = {
    { xe.inl(s.closing), GAP },
    { xe.inl(s.firm, { b = true }), SINGLE },
    { xe.runs("/s/ ") .. xe.inl(s.signer), 0 },
    { xe.inl(s.name_line ~= nil and s.name_line or s.signer), 0 },
  }
  for _, l in ipairs(list(s.lines)) do lines[#lines + 1] = { xe.inl(l), 0 } end
  lines[#lines + 1] = { xe.inl(s.role, { i = true }), 0 }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = i < #lines })
  end
end

-- Certificate of service (FRBP 9013(b); the exemplar's wording) on a page of its own: the heading, the statement,
-- the served parties two to a row (a single line below each row but the last), the /s/ signature at 3 in.
local function certificate(m, out)
  local svc, s = m.service, m.signature
  if svc == nil then return end
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true, u = true }),
    { brk = true, jc = "center", after = GAP, keep = true })
  out[#out + 1] = p(xe.runs("I hereby certify that on the ") .. xe.inl(svc.date) .. xe.runs(", the foregoing document "
    .. "has been served by electronic means via the Court\u{2019}s electronic filing system, unless otherwise indicated below:"),
    { line = BODY, first = 720, after = GAP, keep = true })
  local parties = list(svc.parties)
  local rows = math.ceil(#parties / 2)
  local half = (TEXTW - GUTTER) // 2
  local widths = { half, GUTTER, TEXTW - GUTTER - half }
  local x = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do x[#x + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  x[#x + 1] = "</w:tblGrid>"
  for r = 1, rows do
    local function cell(j, i)
      local body = {}
      local lines = parties[i] and list(parties[i]) or {}
      for k, l in ipairs(lines) do
        body[#body + 1] = p(xe.inl(l), { after = (k == #lines and r < rows) and SINGLE or 0 })
      end
      if #body == 0 then body[1] = p("", {}) end
      return '<w:tc><w:tcPr><w:tcW w:w="' .. widths[j] .. '" w:type="dxa"/></w:tcPr>' .. table.concat(body) .. "</w:tc>"
    end
    x[#x + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. cell(1, 2 * r - 1) .. cell(2, nil) .. cell(3, 2 * r) .. "</w:tr>"
  end
  x[#x + 1] = "</w:tbl>"
  out[#out + 1] = table.concat(x)
  out[#out + 1] = p(xe.runs("/s/ ") .. xe.inl(s.signer), { before = BODY, left = SIG })
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local m = doc.meta
  local head = {}
  court_heading(m, head)
  caption(m, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end

  -- the last body block stays with the signature block
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      local num = c[1] and c[1].t == "Str" and c[1].text:match("^%d+%.$") and c[2] and c[2].t == "Space"
      if num then
        out[#out + 1] = styled("Numbered Paragraph", pandoc.Inlines({ table.unpack(c, 3) }), c[1].text, last)
      else
        out[#out + 1] = styled("Body Text", c, nil, last)
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x:walk({ Inlines = xe.inlines }) end
    elseif b.t == "Table" then
      transfer_table(b, out)
    elseif b.t == "BlockQuote" then
      quotation(b, out)
    else
      error("tnwb-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  local tail = {}
  signature(m, tail)
  certificate(m, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
