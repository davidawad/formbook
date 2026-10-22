-- wvnb-motion-brief.lua (docx engine): the N.D. W. Va. motion with memorandum as Word paragraphs, so that it reads and
-- breaks as typst/wvnb-motion-brief.typ (the reference for the form) does:
--   * the optional counsel block, the court lines, the caption (a table: the parties on the left with a rule on the
--     right and bottom of their column, the chapter, case, judge, adversary and motion docket numbers on the right),
--     the title and the optional LBR 9013-1(c)(2)(B) negative notice in a ruled box;
--   * the body: paragraphs in Body Text (pandoc writes them, with their footnotes; Body Text Noted, without widow
--     control, for one that holds a footnote mark), the author's headings, block quotations single-spaced and indented
--     on both sides;
--   * the date line and the signature block, kept together;
--   * the certificate of service (LBR 9013-1(c)(3)) on a page of its own: the statement, the parties served, the
--     signature.
-- Frontmatter values are printed as given; nothing in this file is case-specific.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 360 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 360, 276            -- typst pitch-body, pitch-single
local GAP, SMALL = 276, 138              -- typst gap, small-gap
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4608                    -- typst caption-left, 3.2 in
local CAP_INSET, RIGHT_INSET = 216, 360  -- typst caption-inset 0.15 in, right-inset 0.25 in
local DEBTOR, ROLE, V = 576, 144, 2160   -- typst debtor-indent 0.4 in, role-indent 0.1 in, v-indent 1.5 in
local NOTICE = 200                       -- typst notice-inset, 10 pt
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local SIG = 4608                         -- typst sig-column, 3.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function upper(x)
  if pandoc.utils.type(x) == "Inlines" then
    return x:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(plain(x))
end

-- A paragraph: o = { before, after, line, left, right, jc, keep, brk } (keep: with the next paragraph and its lines
-- together; brk: a page break before it).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_HEAD = '<w:tbl><w:tblPr><w:tblW w:w="%d" w:type="dxa"/><w:tblInd w:w="%d" w:type="dxa"/>%s' ..
  '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>' ..
  '</w:tblPr>'
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

-- ---------------------------------------------------------------------------
-- Counsel block, court lines, caption, title and negative notice
-- ---------------------------------------------------------------------------

local function counsel(m, out)
  if not m.counsel then return end
  for i, l in ipairs(m.counsel) do
    out[#out + 1] = p(xe.inl(l), { after = i == #m.counsel and GAP or 0 })
  end
end

local function caption(m, out)
  for i, l in ipairs(m.court) do
    out[#out + 1] = p(xe.inl(upper(l)), { jc = "center", after = i == #m.court and GAP or 0 })
  end
  -- the party column: the debtor, each side's names and designation, "v." between the sides; the last line takes the
  -- space above the bottom rule (typst: the cell's bottom inset)
  local left = {}
  if m.debtor then
    left[#left + 1] = { xe.runs("In re: ") .. xe.inl(m.debtor.name) .. xe.runs(","), 0, 0 }
    left[#left + 1] = { xe.runs("Debtor."), DEBTOR, GAP }
  end
  for i, side in ipairs(m.caption) do
    if i > 1 then left[#left + 1] = { xe.runs("v."), V, GAP } end
    for _, n in ipairs(side.names) do left[#left + 1] = { xe.inl(n), 0, 0 } end
    left[#left + 1] = { xe.inl(side.designation), ROLE, GAP }
  end
  local lp = {}
  for i, l in ipairs(left) do lp[#lp + 1] = p(l[1], { left = l[2], after = (i < #left) and l[3] or GAP }) end
  -- the case column, a single line below the top of the caption
  local right = {}
  if m.chapter then right[#right + 1] = p(xe.runs("Chapter ") .. xe.inl(m.chapter), { after = GAP }) end
  right[#right + 1] = p(xe.runs("Case No. ") .. xe.inl(m.case_number))
  if m.judge then right[#right + 1] = p(xe.runs("Judge ") .. xe.inl(m.judge)) end
  right[#right + 1] = p(xe.runs("Adv. Pro. No. ") .. xe.inl(m.adversary_number), { before = GAP })
  if m.motion_docket then right[#right + 1] = p(xe.runs("Motion Docket No. ") .. xe.inl(m.motion_docket)) end
  right[1] = right[1]:gsub('w:before="0"', 'w:before="' .. GAP .. '"', 1)
  out[#out + 1] = string.format(TBL_HEAD, TEXTW, 0, "") ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' ..
    RULE .. '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(lp) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. RIGHT_INSET ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- the title: Word has no space after a table, so it takes the gap before it
  out[#out + 1] = p(xe.inl(upper(m.motion_title), { b = true }), { before = GAP, after = GAP, jc = "center" })
end

-- LBR 9013-1(c)(2)(B) negative notice in a ruled box, only when the sample gives it (typst negative-notice). Word has
-- no space after a table: the paragraph after it takes the gap (Body Text Spaced, below).
local function notice(m, out)
  if not m.notice then return false end
  local paras = p(xe.runs("NOTICE OF OPPORTUNITY TO OBJECT", { b = true }), { after = SMALL }) ..
    p(xe.inl(m.notice.text))
  local mar = '<w:tcMar><w:top w:w="' .. NOTICE .. '" w:type="dxa"/><w:left w:w="' .. NOTICE .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. NOTICE .. '" w:type="dxa"/><w:right w:w="' .. NOTICE .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = string.format(TBL_HEAD, TEXTW, 0, '<w:tblBorders><w:top ' .. RULE .. '/><w:left ' .. RULE ..
    '/><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tblBorders>') ..
    '<w:tblGrid><w:gridCol w:w="' .. TEXTW .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. mar .. '</w:tcPr>' .. paras .. '</w:tc></w:tr></w:tbl>'
  return true
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings as typed: single-spaced and bold, a single line above and half a line below, kept with the text; level 1
-- centered capitals, level 2 centered, level 3 at the margin.
local function heading(el)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(GAP, SMALL, SINGLE),
    xe.ind(0, nil, 0), xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true })))
end

local function has_note(b)
  local found = false
  pandoc.Pandoc({ b }):walk({ Note = function() found = true end })
  return found
end

local function body(doc, out, spaced)
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      local style = has_note(b) and "Body Text Noted" or (spaced and "Body Text Spaced" or "Body Text")
      if spaced and style == "Body Text Noted" then style = "Body Text Spaced Noted" end
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BlockQuote" then
      for i, q in ipairs(b.content) do
        out[#out + 1] = xe.raw(p(xe.inl(q.content), { before = i == 1 and GAP or SMALL,
          after = i == #b.content and GAP or 0, left = QUOTE, right = QUOTE }))
      end
    else
      error("wvnb-motion-brief.lua: unsupported block " .. b.t)
    end
    spaced = false
  end
end

-- ---------------------------------------------------------------------------
-- Signature and certificate of service
-- ---------------------------------------------------------------------------

-- Lines kept together (typst: one unbreakable block). Each: { runs, before, after, left }.
local function kept(lines, out, first)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], after = l[3], left = l[4], keep = i < #lines, brk = first and i == 1,
      jc = l.jc })
  end
end

local function signature_lines(sig, lines)
  lines[#lines + 1] = { xe.runs("s/ ", { b = true }) .. xe.inl(sig.signer, { b = true }), 0, 0, SIG }
  for _, l in ipairs(sig.lines) do lines[#lines + 1] = { xe.inl(l), 0, 0, SIG } end
end

local function signature(m, out)
  local sig = m.signature
  local lines = {}
  if m.date then lines[#lines + 1] = { xe.runs("Dated: ") .. xe.inl(m.date), GAP, GAP, 0 } end
  lines[#lines + 1] = { xe.runs("Respectfully submitted,"), GAP, GAP, SIG }
  for _, l in ipairs(sig.parties or {}) do lines[#lines + 1] = { xe.inl(l), 0, 0, SIG } end
  signature_lines(sig, lines)
  kept(lines, out)
end

local function certificate(m, out)
  local svc = m.service
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { brk = true, after = GAP, jc = "center" })
  local text
  if svc.text then
    text = xe.inl(svc.text)
  else
    text = xe.runs("I certify that on ") .. xe.inl(svc.date) .. xe.runs(", I ") .. xe.inl(svc.method) ..
      xe.runs(" the foregoing ") .. xe.inl(m.motion_title) ..
      xe.runs(" and this certificate of service, which were served on the following parties:")
  end
  out[#out + 1] = p(text, { after = GAP })
  for _, party in ipairs(svc.parties or {}) do
    local lines = { { xe.inl(party.name), SMALL, 0, 0 } }
    for _, l in ipairs(party.lines or {}) do lines[#lines + 1] = { xe.inl(l), 0, 0, 0 } end
    lines[#lines][3] = SMALL
    kept(lines, out)
  end
  local lines = {}
  signature_lines(m.signature, lines)
  lines[1][2] = GAP
  kept(lines, out)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 544(b)": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local m = doc.meta
  local head = {}
  counsel(m, head)
  caption(m, head)
  local spaced = notice(m, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end
  body(doc, out, spaced)
  local tail = {}
  signature(m, tail)
  certificate(m, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
