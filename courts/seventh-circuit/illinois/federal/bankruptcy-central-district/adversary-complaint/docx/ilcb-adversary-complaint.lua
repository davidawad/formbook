-- ilcb-adversary-complaint.lua (docx engine): the C.D. Ill. bankruptcy adversary complaint as Word paragraphs and a
-- caption table, so that it reads and breaks as ../typst/ilcb-adversary-complaint.typ (the reference) does:
--   * the court lines, the caption (one row per frontmatter line: the party line, ")", the case line), the title,
--     the headings (level 1 centered bold, level 2 bold, level 3 bold italic, level 4 italic) and the signature block
--     ("Dated", the signer's lines in the right-hand column, the counsel lines at the margin), written here;
--   * the body: pandoc's paragraphs and footnotes in the Body Text and Footnote Text styles of docx/reference.xml (the
--     author types the paragraph numbers "1\." and the sub-paragraph labels "(i)"; they stay text); the last
--     paragraph is kept with the signature block (Body Keep).
-- No case text is in this file: every string comes from the frontmatter of the sample (schema: ../README.md).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 552, 276, 276  -- typst pitch-body, pitch-single, gap
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAREN = 4896, 432    -- typst caption-left-width 3.4 in, caption-paren-width 0.3 in
local TITLE_INSET = 720                  -- typst title-inset 0.5 in
local SIG = 4212                         -- typst sig-indent 2.925 in
local COURT = { "UNITED STATES BANKRUPTCY COURT", "CENTRAL DISTRICT OF ILLINOIS" } -- typst court-lines

local function list(v)
  local out = {}
  for _, x in ipairs(v or {}) do out[#out + 1] = x end
  return out
end

-- A paragraph: o = { before, after, line, left, right, jc, keep }; single-spaced unless o.line.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Court lines, caption, title (typst: court-heading, caption, title-block)
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  for i, l in ipairs(COURT) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #COURT and BODY or 0 })
  end
  local cap = meta.caption or {}
  local left, right = list(cap.left), list(cap.right)
  local widths = { CAP_LEFT, CAP_PAREN, TEXTW - CAP_LEFT - CAP_PAREN }
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local rows = {}
  for i = 1, math.max(#left, #right) do
    local cells = { p(xe.inl(left[i])), p(xe.runs(")"), { jc = "center" }), p(xe.inl(right[i])) }
    local tcs = {}
    for k, w in ipairs(widths) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. cells[k] .. '</w:tc>'
    end
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- Word has no space after a table: the title takes the space before it
  out[#out + 1] = p(xe.inl(meta.document_title, { b = true }),
    { jc = "center", before = BODY, after = GAP, left = TITLE_INSET, right = TITLE_INSET })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: single-spaced, a single line above and below, kept with the text.
local function heading(el)
  local o = ({ { b = true }, { b = true }, { b = true, i = true } })[el.level] or { i = true }
  return xe.para({ xe.style("Heading" .. math.min(el.level, 4)), xe.KEEP, xe.spacing(GAP, GAP, SINGLE),
    xe.ind(0, nil, 0), xe.jc(el.level == 1 and "center" or "left") }, xe.inl(el.content, o))
end

-- A body paragraph (pandoc writes it, footnotes included): Body Text, the body pitch, a half-inch first-line indent.
-- A paragraph that anchors a footnote is set without widow control (Body Text Note): typst moves its last line alone
-- to the next page when the note does not fit, which Word's widow control would not. The last one is kept with the
-- signature block (Body Keep; typst: one unbreakable block).
local function body_par(inlines, last)
  local para = pandoc.Para(inlines):walk({ Inlines = xe.inlines })
  local note = false
  para:walk({ Note = function() note = true end })
  local style = last and "Body Keep" or note and "Body Text Note" or "Body Text"
  return pandoc.Div({ para }, { ["custom-style"] = style })
end

-- "Dated", "Respectfully submitted,", the firm, "By: /s/", "One of Its Attorneys" (right-hand column), the counsel
-- lines at the margin, kept together (typst: signature-block in an unbreakable block).
local function signature(meta, out)
  local sig = meta.signature
  local lines = {}
  local before = BODY
  if meta.dated then
    lines[#lines + 1] = { xe.runs("Dated: ") .. xe.inl(meta.dated), before, 0 }
    before = GAP
  end
  lines[#lines + 1] = { xe.runs("Respectfully submitted,"), before, SIG }
  lines[#lines + 1] = { xe.inl(sig.firm, { b = true }), GAP, SIG }
  lines[#lines + 1] = { xe.runs("By: /s/ ") .. xe.inl(sig.signer), GAP, SIG }
  lines[#lines + 1] = { xe.runs("One of Its Attorneys"), 0, SIG }
  for i, l in ipairs(list(sig.counsel)) do lines[#lines + 1] = { xe.inl(l), i == 1 and GAP or 0, 0 } end
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l[1], { before = l[2], left = l[3], keep = i < #lines }))
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
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

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local head = {}
  cover(meta, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content, i == #blocks)
    else
      error("ilcb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
