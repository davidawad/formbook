-- innb-motion-brief.lua (docx engine): the N.D. Ind. supporting brief as Word paragraphs and tables, so that it reads
-- and breaks as ../typst/innb-motion-brief.typ (the reference for the form) does:
--   * the court title, the debtor block (In re:, each debtor's names and designation, closed by a rule on its right
--     and below; the case number and chapter on the right) and the title, one line per entry, written here;
--   * the body: the paragraphs (no numbers, INNB-BRF-002), the typed "a." items as text, the block quotations and the
--     footnotes, written by pandoc in the styles of docx/reference.xml; the author's headings written here;
--   * the last paragraph kept with the signature block (the date at the margin, the signature in the right-hand
--     column), on one page.
-- No case text is in this file: every string comes from the frontmatter of the sample (schema: ../README.md).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 276, 240 -- typst pitch-body, pitch-single, gap (half a body line)
local TEXTW = 9360                      -- 6.5 in
local CAP_LEFT = 4680                   -- typst caption-left 3.25 in
local CAP_INSET = 288                   -- typst caption-inset 0.2 in
local NAME, DESIG = 720, 2304           -- typst name-indent 0.5 in, designation-indent 1.6 in
local SIG = 4608                        -- typst sig-column 3.2 in

local function need(meta, k)
  if meta[k] == nil then error("innb-motion-brief: missing required metadata field `" .. k .. "`", 0) end
  return meta[k]
end

local function list(v)
  local out = {}
  for _, x in ipairs(v or {}) do out[#out + 1] = x end
  return out
end

local function upper(m)
  return pandoc.Inlines(m):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, jc }; single-spaced unless o.line.
local function p(body, o)
  o = o or {}
  return xe.para({ xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE), xe.ind(o.left or 0, nil, 0),
    xe.jc(o.jc or "left") }, body)
end

-- A fixed one-row table with no cell margins; cells: list of { width, pr, body } (pr: more tcPr XML).
local function row(cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for _, c in ipairs(cells) do
    total = total + c[1]
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[2] or "") .. '</w:tcPr>' ..
      table.concat(c[3]) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function mar(side, w)
  return '<w:tcMar><w:' .. side .. ' w:w="' .. w .. '" w:type="dxa"/></w:tcMar>'
end

-- ---------------------------------------------------------------------------
-- Court title, caption and title (INNB-CAP-001, INNB-CAP-003; typst court-title, debtor-table, title-block)
-- ---------------------------------------------------------------------------

local function cover(m, out)
  local court = list(need(m, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  -- the debtors, ruled on the right and below; the last line takes the space above the bottom rule (typst: the
  -- cell's bottom inset); the case number and chapter from the line of the first name
  local debtors = list(need(m, "debtors"))
  local left = { p(xe.runs("In re:")) }
  for i, d in ipairs(debtors) do
    left[#left + 1] = p(xe.inl(d.names), { left = NAME, before = i > 1 and GAP or 0 })
    left[#left + 1] = p(xe.inl(d.designation), { left = DESIG, after = i == #debtors and GAP or 0 })
  end
  local right = { p(xe.runs("Case No. ") .. xe.inl(need(m, "case_number")), { before = SINGLE }),
    p(xe.runs("Chapter ") .. xe.inl(need(m, "chapter"))) }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = row({
    { CAP_LEFT, '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      mar("right", CAP_INSET), left },
    { TEXTW - CAP_LEFT, mar("left", CAP_INSET), right },
  })
  -- the title (INNB-FORM-002): Word has no space after a table, so it takes the space before it
  local title = list(need(m, "title"))
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", before = i == 1 and BODY or 0,
      after = i == #title and GAP or 0 })
  end
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block): kept on one page with the paragraph before it
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local sig = need(m, "signature")
  local left = { p(xe.runs("Dated: ") .. xe.inl(need(m, "date")), { before = BODY }) }
  local right = {}
  for _, l in ipairs(list(sig.preamble)) do right[#right + 1] = p(xe.inl(l)) end
  right[#right + 1] = p(xe.inl(sig.signer), { before = BODY })
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  -- the first line of each column a body line below the paragraph before it
  right[1] = right[1]:gsub('w:before="0"', 'w:before="' .. BODY .. '"', 1)
  out[#out + 1] = row({ { TEXTW - SIG, nil, left }, { SIG, nil, right } }, '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings: single-spaced, half a body line above and below, kept with the text; `#` centred bold capitals,
-- `##` bold at the margin (typst show heading).
local function heading(el)
  local t = el.level == 1 and upper(el.content) or el.content
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(el.level, 2)), xe.KEEP, xe.spacing(GAP, GAP, SINGLE),
    xe.ind(0, nil, 0), xe.jc(el.level == 1 and "center" or "left") }, xe.inl(t, { b = true })))
end

local function has_note(b)
  local found = false
  pandoc.Pandoc({ b }):walk({ Note = function() found = true end })
  return found
end

-- A body paragraph, written by pandoc: Body Text, without widow control when it anchors a footnote, kept with the
-- signature when it is the last.
local function body_par(b, keep)
  local style = keep and "Body Text Keep" or (has_note(b) and "Body Text Note" or "Body Text")
  return pandoc.Div({ pandoc.Para(pandoc.Inlines(b.content):walk({ Inlines = xe.inlines })) },
    { ["custom-style"] = style })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 105": a no-break space; typst binds it with a box).
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
  local m = doc.meta
  for _, k in ipairs({ "court", "debtors", "case_number", "chapter", "title", "date", "signature" }) do
    need(m, k)
  end
  local out = {}
  local head = {}
  cover(m, head)
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b, i == #blocks)
    elseif b.t == "BlockQuote" then
      -- single-spaced, inset half an inch on both sides, half a body line around it and between its paragraphs
      out[#out + 1] = b:walk({ Inlines = xe.inlines })
    else
      error("innb-motion-brief: unsupported block " .. b.t, 0)
    end
  end
  local tail = {}
  signature(m, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
