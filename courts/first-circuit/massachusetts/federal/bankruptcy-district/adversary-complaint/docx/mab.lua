-- mab adversary complaint, docx engine: what the Word output adds to pandoc's conversion, so that it reads and
-- breaks as typst/mab-adversary-complaint.typ does (README "Engines"): the court title and the caption (Fed. R.
-- Bankr. P. 7010, Form 416D), the title, the numbered allegations (Fed. R. Civ. P. 10(b); the lead-in, the WHEREFORE
-- prayer and the certificate and service list are not numbered), the lettered items, the body table and the
-- signature block with the date. Everything printed comes from the sample's frontmatter and body: no case text lives
-- in this file. Body paragraphs stay pandoc paragraphs (in the reference's styles) so that pandoc writes their
-- footnotes; the rest is written as WordprocessingML.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local GAP = SINGLE                       -- typst gap
local SIG_GAP = 138                      -- typst sig-gap, pitch-single / 2
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288   -- typst caption-left 3.4 in, caption-gutter 0.2 in
local CAP_RIGHT_INSET = 144              -- typst caption-right-inset 0.1 in
local CAP_PAD_RIGHT, CAP_PAD_BOTTOM = 200, 160  -- typst caption-pad-right 10 pt, caption-pad-bottom 8 pt
local SIG = 4464                         -- typst sig-indent 3.1 in
local TABLE_COL = 2160                   -- typst table-col 1.5 in
local TABLE_X, TABLE_Y = 160, 40         -- typst table-inset-x 8 pt, table-inset-y 2 pt
local UNNUMBERED = { ["CERTIFICATE OF SERVICE"] = true, ["SERVICE LIST"] = true }
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tc(w, body, pr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' ..
    (body ~= "" and body or p("")) .. '</w:tc>'
end

local function tbl(widths, rows, o)
  o = o or {}
  local grid = {}
  local total = 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. (o.jc and xe.jc(o.jc) or "") ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
    '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

local function tr(cells)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

-- Lines ({ body, before }) as single-spaced paragraphs; `first` is the space above the first one.
local function lines_xml(lines, first, left)
  local x = {}
  for i, l in ipairs(lines) do
    x[#x + 1] = p(l.body, { before = i == 1 and first or (l.before or 0), left = left })
  end
  return table.concat(x)
end

-- ---------------------------------------------------------------------------
-- Cover: court (Form 416D), caption, title of the paper
-- ---------------------------------------------------------------------------

local function caption(meta, out)
  for _, l in ipairs({ "UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF MASSACHUSETTS", plain(meta.division):upper() }) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true })
  end
  local widths = { CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }
  -- debtor (left) and chapter / case number (right); a double line below the court title
  local left = { { body = xe.runs("In re:") } }
  for i, n in ipairs(meta.debtor_names) do left[#left + 1] = { body = xe.inl(n), before = i == 1 and GAP or 0 } end
  left[#left + 1] = { body = xe.inl(meta.debtor_designation) }
  local right = { { body = xe.runs("CHAPTER " .. plain(meta.chapter)) },
    { body = xe.runs("CASE NO. ") .. xe.inl(meta.case_number), before = GAP } }
  out[#out + 1] = tbl(widths, { tr({ tc(widths[1], lines_xml(left, BODY)), tc(widths[2], p("", { before = BODY })),
    tc(widths[3], lines_xml(right, BODY)) }) })
  -- adversary parties (left, ruled on the right and below) and the adversary number (right); a double line below
  local parties = {}
  for _, n in ipairs(meta.plaintiffs.names) do parties[#parties + 1] = { body = xe.inl(n) } end
  parties[#parties + 1] = { body = xe.inl(meta.plaintiffs.designation) }
  parties[#parties + 1] = { body = xe.runs("v."), before = GAP }
  for i, n in ipairs(meta.defendants.names) do parties[#parties + 1] = { body = xe.inl(n), before = i == 1 and GAP or 0 } end
  parties[#parties + 1] = { body = xe.inl(meta.defendants.designation) }
  local adv = plain(meta.adv_number)
  local adv_line = adv == "" and xe.runs("ADV. PROC. NO. ____________") or (xe.runs("Adv. Proc. No. ") .. xe.inl(meta.adv_number))
  local box = '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. CAP_PAD_BOTTOM .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD_RIGHT .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = tbl(widths, { tr({ tc(widths[1], lines_xml(parties, BODY), box), tc(widths[2], p("", { before = BODY })),
    tc(widths[3], p(adv_line, { before = BODY, left = CAP_RIGHT_INSET })) }) })
  -- the title a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = BODY, after = SINGLE, keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature: the groups at the signature indent, half a line apart, then the date at the margin; every line kept
-- with the next, so the block never splits across pages.
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local lines = {}
  for k, g in ipairs(meta.signature) do
    for i, l in ipairs(g) do
      lines[#lines + 1] = { body = xe.inl(l), before = (i == 1 and k > 1) and SIG_GAP or 0, left = SIG }
    end
  end
  lines[1].before = BODY                 -- typst: the block's above
  lines[#lines + 1] = { body = xe.runs("Date: ") .. xe.inl(meta.date), before = SINGLE, left = 0 }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, left = l.left, keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body size and pitch, centered and bold (level 1 in capitals); kept with the text.
local function heading(el)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(content, { b = true }))
end

-- A markdown table: unruled, centered, single-spaced, fixed columns, a single line above and below (typst
-- body-table(): the space on the first row's and the last row's lines).
local function body_table(t)
  local aligns = {}
  for i, spec in ipairs(t.colspecs) do
    local a = tostring(spec[1])
    aligns[i] = a == "AlignCenter" and "center" or a == "AlignRight" and "right" or "left"
  end
  local rows = {}
  for _, r in ipairs(t.head.rows) do rows[#rows + 1] = r end
  for _, b in ipairs(t.bodies) do for _, r in ipairs(b.body) do rows[#rows + 1] = r end end
  local trs = {}
  for k, r in ipairs(rows) do
    local cells = {}
    for i, c in ipairs(r.cells) do
      local inl = pandoc.Inlines({})
      for _, cb in ipairs(c.contents) do inl:extend(cb.content) end
      local body = p(xe.inl(inl), { jc = aligns[i], before = k == 1 and SINGLE or 0, after = k == #rows and SINGLE or 0 })
      cells[#cells + 1] = tc(TABLE_COL, body, '<w:tcMar><w:top w:w="' .. TABLE_Y .. '" w:type="dxa"/><w:left w:w="' ..
        TABLE_X .. '" w:type="dxa"/><w:bottom w:w="' .. TABLE_Y .. '" w:type="dxa"/><w:right w:w="' .. TABLE_X ..
        '" w:type="dxa"/></w:tcMar>')
    end
    -- the table never splits (typst: breakable: false)
    if k < #rows then
      cells[1] = cells[1]:gsub("<w:pPr>", "<w:pPr><w:keepNext/>", 1)
    end
    trs[#trs + 1] = tr(cells)
  end
  local widths = {}
  for i = 1, #aligns do widths[i] = TABLE_COL end
  return tbl(widths, trs, { jc = "center" })
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A body paragraph in `style`, or its "Note" variant (no widow control) when it carries a footnote mark.
local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style .. (has_note(inlines) and " Note" or "") })
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function body(blocks, meta, out)
  local n = 0
  local numbered = false                 -- the lead-in before the first heading is not numbered
  local signed = false
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        local title = plain(b.content):upper()
        if title == "CERTIFICATE OF SERVICE" and not signed then
          signature(meta, out)
          signed = true
        end
        numbered = not UNNUMBERED[title]
      end
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      -- "WHEREFORE" paragraphs are the prayer: not numbered
      if numbered and not plain(b.content):find("^WHEREFORE") then
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inl:extend(b.content)
        out[#out + 1] = styled("Numbered Paragraph", inl)
      else
        out[#out + 1] = styled("Body Text", b.content)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- lettered items: the label half an inch in, a tab to the text, which hangs at one inch
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local inl = pandoc.Inlines({})
          if k == 1 then
            inl:insert(pandoc.Str(b.t == "OrderedList" and (string.char(96 + j) .. ".") or "\u{2022}"))
            inl:insert(TAB)
          end
          inl:extend(ib.content)
          out[#out + 1] = styled("Lettered Item", inl)
        end
      end
    elseif b.t == "Table" then
      out[#out + 1] = body_table(b)
    else
      error("mab.lua: unsupported block " .. b.t)
    end
  end
  if not signed then signature(meta, out) end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 547"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" and #a.text >= 4 and a.text:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  -- FRBP 7008(a): the complaint must state whether the pleader does or does not consent to final orders or judgment
  if not plain(pandoc.Pandoc(doc.blocks)):find("consent to the entry of final orders", 1, true) then
    error("mab-adversary-complaint: FRBP 7008(a) requires a statement of consent to the entry of final orders or judgment by the bankruptcy court")
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  -- the break rules on the body only: the frontmatter goes through xe.inl, which applies them itself
  local blocks = pandoc.Pandoc(doc.blocks):walk({ Inlines = xe.inlines }).blocks
  local out = {}
  caption(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  out = {}
  body(blocks, meta, out)
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  -- emptied metadata: pandoc would otherwise print the frontmatter title above the caption
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
