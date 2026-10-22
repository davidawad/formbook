-- gasb-adversary-complaint.lua (docx engine): the S.D. Ga. adversary complaint as Word paragraphs and tables, so
-- that it reads and breaks as ../typst/gasb-adversary-complaint.typ does:
--   * the court title, the caption table (debtor and parties on the left, case numbers on the right, a rule under and
--     beside the left cell), the title of the complaint and the signature block, written here;
--   * the body (pandoc's paragraphs and footnotes, in the Body Text and Footnote Text styles of docx/reference.xml);
--     the author types "1.", "2.", ...: each ordered-list item is a Body Text paragraph that starts with its number
--     and a tab (the number half an inch in, the text an inch in, the lines after the first at the margin), the
--     numbers keeping the start the author typed (paragraph 30 starts at 30).
-- No case text is in this file: every string comes from the frontmatter of the sample (schema: ../README.md).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 276, 240 -- typst pitch-body, pitch-single, gap (half a body line)
local TEXTW = 9360                      -- 6.5 in
local CAP_LEFT = 5904                   -- typst caption-left 4.1 in
local CAP_INSET = 288                   -- typst caption-inset 0.2 in
local DEBTOR_INDENT, DESIG_INDENT = 1728, 2592 -- typst debtor-indent 1.2 in, designation-indent 1.8 in
local SIG_RIGHT = 4608                  -- typst sig-column 3.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A single-spaced paragraph: o = { before, after, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function upper(m)
  if pandoc.utils.type(m) == "Inlines" then
    return m:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(plain(m))
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title (typst: court-title, caption-left-cell, caption-right-cell, caption-table)
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  for i, l in ipairs(meta.court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", after = i == #meta.court and BODY or 0 })
  end
  local left = {}
  for _, l in ipairs(meta.in_re) do left[#left + 1] = p(xe.inl(l)) end
  left[#left + 1] = p(xe.inl(meta.debtor_role or "Debtor."), { left = DEBTOR_INDENT, after = GAP })
  for i, side in ipairs(meta.caption) do
    for _, n in ipairs(side.names) do left[#left + 1] = p(xe.inl(n)) end
    local last = i == #meta.caption
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIG_INDENT, after = last and GAP or 0 })
    if not last then left[#left + 1] = p(xe.runs("v."), { before = GAP, after = GAP, jc = "center" }) end
  end
  local right = {
    p(xe.runs("CASE NO. " .. plain(meta.case_number)), { after = GAP }),
    p(xe.runs("CHAPTER " .. plain(meta.chapter)), { after = GAP }),
  }
  if meta.judge then right[#right + 1] = p(xe.inl(meta.judge), { after = GAP }) end
  local adv = plain(meta.adversary_number)
  right[#right + 1] = p(xe.runs("ADV. PRO. NO. " .. (adv == "" and string.rep("_", 11) or adv)))
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- Word has no space after a table: the title takes the caption's space before it
  out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { jc = "center", before = BODY, after = GAP })
end

-- ---------------------------------------------------------------------------
-- Signature block (typst: signature-block): "Respectfully submitted" at left, the firm and counsel at right; the row
-- never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local left = { p(xe.runs("Respectfully submitted this ") .. xe.inl(meta.submitted_on) .. xe.runs("."),
    { before = BODY }) }
  local right = {
    p(xe.inl(sig.firm, { b = true }), { before = BODY, after = GAP }),
    p(xe.runs("/s/ " .. plain(sig.signer))),
    p(xe.inl(sig.signer)),
  }
  for _, l in ipairs(sig.signer_lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  for i, l in ipairs(sig.other_counsel_lines or {}) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and GAP or 0 }) end
  right[#right + 1] = p(xe.inl(sig.role, { i = true }), { before = GAP })
  for _, l in ipairs(sig.address) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ TEXTW - SIG_RIGHT, SIG_RIGHT }, { { body = left }, { body = right } }, '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings: bold, centered, single-spaced, half a body line above and below, kept with the text.
local function heading(el)
  -- no heading style (the recipe's level 1 sets capitals; the headings are as typed), its outline level only
  return xe.para({ xe.KEEP, xe.spacing(GAP, GAP, SINGLE), xe.ind(0, nil, 0), xe.jc("center"),
    '<w:outlineLvl w:val="' .. (el.level - 1) .. '"/>' }, xe.inl(el.content, { b = true }))
end

-- A body paragraph (pandoc writes it, footnotes included): Body Text, the body pitch, a half-inch first-line indent.
-- A paragraph that anchors a footnote is set without widow control (Body Text Note): typst moves its last line alone
-- to the next page when the note does not fit, which Word's widow control would not.
local function body_par(inlines)
  local para = pandoc.Para(inlines):walk({ Inlines = xe.inlines })
  local note = false
  para:walk({ Note = function() note = true end })
  return pandoc.Div({ para }, { ["custom-style"] = note and "Body Text Note" or "Body Text" })
end

-- The author's numbered paragraphs: the number, a tab to one inch (Body Text's first-line indent puts the number
-- half an inch in; Word's default stops are every half inch), the text.
local function numbered(list, out)
  local n = list.listAttributes.start
  for _, item in ipairs(list.content) do
    for k, b in ipairs(item) do
      local inl = pandoc.Inlines({})
      if k == 1 then inl:extend({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }) end
      inl:extend(b.content)
      out[#out + 1] = body_par(inl)
    end
    n = n + 1
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("Loan/Award": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1334": a no-break space; typst binds it with a box).
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
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content)
    elseif b.t == "OrderedList" then
      numbered(b, out)
    else
      error("gasb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
