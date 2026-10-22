-- Memorandum brief in support of a motion for the U.S. District Court for the Northern District of Mississippi
-- (msnd), docx engine: what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/msnd-motion-brief.typ does (README "Engines"): the court title and caption (Fed. R. Civ. P. 10(a)), the
-- title, the headings (level 1 centered in capitals, level 2 bold, level 3 bold italic), the list items and the
-- signature block (the date line; "Respectfully submitted," and the party, signer and counsel lines at 3 inches,
-- L.U.Civ.R. 11(a); the OF COUNSEL block at the margin). pandoc writes the body paragraphs (styles Body Text, Body
-- Continue after a block quotation, the last one Body Keep), the block quotations (Block Text) and the footnotes
-- (Footnote Text). The caption is an OOXML table, because pandoc has no caption construct. Everything printed comes
-- from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local ITEM_LEFT, ITEM_BOX = 1296, 576    -- typst item-indent + item-box (0.9 in), item-box 0.4 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360   -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET = 240                    -- typst caption-inset 12 pt
local CAP_PAD = 123                      -- typst caption-pad (half a single line, 138) less the 0.75 pt rule, which
                                         -- LibreOffice adds to the cell height
local RIGHT_INSET = 288                  -- typst right-inset 0.2 in
local SIG_INDENT = 4320                  -- typst sig-indent 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { style, keep, before, after, line, left, hanging, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption (Fed. R. Civ. P. 10(a)), title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  -- The caption stands a single line below the title lines (Word has no space before a table: the last title line
  -- takes it as space after).
  local lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF MISSISSIPPI" }
  if plain(meta.division) ~= "" then lines[#lines + 1] = pandoc.text.upper(plain(meta.division)) .. " DIVISION" end
  for k, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = k == #lines and SINGLE or 0 })
  end
  -- Left cell: each party's names, then its designation; "v." between the parties.
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_PAD or 0 })
  end
  -- Right cell: "CIVIL ACTION NO.:" and the number.
  local right = { p(xe.runs("CIVIL ACTION NO.:")), p(xe.inl(meta.case_number)) }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- The title: centered, bold, a line of the body pitch; Word has no space after a table, so it takes the single
  -- line below the caption as space before.
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { line = BODY, jc = "center", before = SINGLE, keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature block: the date line at the paragraph indent; "Respectfully submitted,", the signing party, the signer
-- and counsel (L.U.Civ.R. 11(a)) at 3 inches; the OF COUNSEL block at the margin; kept together on one page.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local out = { p(xe.inl(meta.date_line), { line = BODY, first = INDENT, keep = true }) }
  out[#out + 1] = p(xe.runs("Respectfully submitted,"), { left = SIG_INDENT, before = SINGLE, keep = true })
  out[#out + 1] = p(xe.inl(sig.party), { left = SIG_INDENT, before = SINGLE, keep = true })
  out[#out + 1] = p(xe.inl(sig.signer), { left = SIG_INDENT, keep = true })
  for _, l in ipairs(sig.counsel or {}) do out[#out + 1] = p(xe.inl(l), { left = SIG_INDENT, keep = true }) end
  local oc = sig.of_counsel or {}
  for k, l in ipairs(oc) do
    out[#out + 1] = p(xe.inl(l), { before = k == 1 and SINGLE or 0, keep = k < #oc })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings, kept with what follows, in a line of the body pitch: level 1 bold, centered, in capitals; level 2 bold;
-- level 3 bold italic.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, { b = true, i = el.level >= 3 }))
end

-- List items: the number half an inch in, in a 0.4 in box, the text hanging after it; double-spaced.
local function list(b, out)
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  for _, item in ipairs(b.content) do
    for k, blk in ipairs(item) do
      local lab = k == 1 and ((b.t == "OrderedList" and (n .. ".") or "\u{2022}") .. "\t") or ""
      out[#out + 1] = xe.raw(p(xe.runs(lab) .. xe.inl(blk.content), { line = BODY, left = ITEM_LEFT, hanging = ITEM_BOX }))
    end
    n = n + 1
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space), none between a doubled section sign and its number (typst boxes the
-- last sign with the number).
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end
local function signs(inls)
  for i = 1, #inls - 1 do
    local a, b = inls[i], inls[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then inls[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return inls
end
-- A space before a footnote mark is dropped, as the typst template does (its markdown renderer trims it).
local function tight_marks(inls)
  local out = pandoc.Inlines({})
  for i, el in ipairs(inls) do
    local nxt = inls[i + 1]
    if not (el.t == "Space" and nxt and nxt.t == "Note") then out:insert(el) end
  end
  return out
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs }):walk({ Inlines = tight_marks })
  -- the body inlines pandoc writes itself; the metadata strings stay text (xe.inl applies the same rules to them)
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local raw = {}
  cover(meta, raw)
  local out = { xe.raw(table.concat(raw)) }
  local blocks = doc.blocks
  local after_quote = false
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
      after_quote = false
    elseif b.t == "Para" or b.t == "Plain" then
      local style = i == #blocks and "Body Keep" or after_quote and "Body Continue" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
      after_quote = false
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
      after_quote = true
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      list(b, out)
      after_quote = false
    else
      error("msnd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
