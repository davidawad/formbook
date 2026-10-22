-- Motion with memorandum for the United States Bankruptcy Court, District of Guam (gub), docx engine: what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/gub-motion-brief.typ does (see
-- ../README.md): the cover (counsel block upper left in the first 2 inches, the court title 3 inches from the top,
-- GNLR 5.1(b), (c); the caption with the right-hand case information), the headings (level 1 centered bold
-- capitals, levels 2 and 3 bold with the author's number and a half-inch hanging indent, level 3 half an inch in),
-- the block quotations (single-spaced, indented on both sides) and the signature block (GNLR 5.1(d), Fed. R.
-- Bankr. P. 9011(a)). pandoc writes the body paragraphs (styles Body Text, Body Continue after a block quotation, the
-- last one Body Keep) and the footnotes (Footnote Text). Counsel block and caption are OOXML tables. Everything
-- printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst quote-indent and head-hang, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local COUNSEL_H = 2880                   -- typst counsel-height, 2 in
local CAP_LEFT, CAP_GUTTER = 4752, 360   -- typst caption-left 3.3 in, caption-gutter 0.25 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local CAP_PAD = 145                      -- typst caption-pad (8 pt, 160) less the 0.75 pt rule, which LibreOffice adds
                                         -- to the cell height
local RIGHT_INSET = 216                  -- typst right-inset 0.15 in
local SIG_LEFT = 4032                    -- typst sig-left 2.8 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { keep, before, after, line, left, right, hanging, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }; trpr the row's properties.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/>' .. (trpr or "") .. '</w:trPr>' ..
    table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  -- Counsel identification, upper left (GNLR 5.1(c)(1)), in a row exactly 2 inches high, so the court title starts
  -- 3 inches from the top (GNLR 5.1(b)).
  local counsel = {}
  for _, l in ipairs(meta.counsel or {}) do counsel[#counsel + 1] = p(xe.inl(l)) end
  out[#out + 1] = tbl({ TEXTW }, { { body = counsel } }, '<w:trHeight w:val="' .. COUNSEL_H .. '" w:hRule="exact"/>')
  local title = { "DISTRICT COURT OF GUAM", "TERRITORY OF GUAM", "BANKRUPTCY DIVISION" }
  for k, l in ipairs(title) do
    -- the caption stands a single line below (Word has no space before a table: the last title line takes it)
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = k == #title and SINGLE or 0 })
  end
  -- Left cell: the lead lines, each party's names and designation, "vs." between the parties.
  local left = {}
  for _, l in ipairs(meta.caption.lead or {}) do left[#left + 1] = xe.inl(l) end
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = xe.runs("vs.") end
    for _, n in ipairs(party.names) do left[#left + 1] = xe.inl(n) end
    left[#left + 1] = xe.inl(party.designation)
  end
  for k, l in ipairs(left) do left[k] = p(l, { after = k == #left and CAP_PAD or 0 }) end
  -- Right cell: the case information (GNLR 5.1(c)(3)), a single line between the groups.
  local right = { p(xe.runs("Case No. ") .. xe.inl(meta.case_number)) }
  if meta.chapter then right[#right + 1] = p(xe.inl(meta.chapter)) end
  right[#right + 1] = p(xe.runs("Adversary Proceeding"), { before = SINGLE })
  right[#right + 1] = p(xe.runs("Adv. Proc. No. ") .. xe.inl(meta.adversary_number))
  right[#right + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE })
  if meta.memorandum then
    right[#right + 1] = p(xe.runs("With Memorandum in Support", { b = true }), { before = SINGLE })
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("") } },
    { pr = '<w:tcMar><w:left w:w="' .. RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
end

-- ---------------------------------------------------------------------------
-- Signature block: a single line below the body, in the right column; kept together on one page.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local lines = { { xe.runs("Respectfully submitted this " .. plain(meta.date) .. "."), SINGLE },
    { xe.runs("/s/ ") .. xe.inl(sig.signer), SINGLE }, { xe.inl(sig.signer), 0 } }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { xe.inl(l), 0 } end
  local out = {}
  for k, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { left = SIG_LEFT, before = l[2], keep = k < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings, kept with what follows, in lines of the body pitch: level 1 bold, centered, in capitals; levels 2 and 3
-- bold, the lines after the first hanging half an inch, level 3 half an inch in.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local ind = el.level == 1 and xe.ind(0, nil, 0) or xe.ind(INDENT * math.min(el.level - 1, 2), INDENT)
  return xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(0, 0, BODY), ind,
    xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- A block quotation: its paragraphs single-spaced, indented half an inch on both sides, a single line above and
-- below the whole.
local function quotation(b)
  local paras = {}
  for _, x in ipairs(b.content) do
    if x.t ~= "Para" and x.t ~= "Plain" then error("gub-motion-brief.lua: unsupported block in a quotation: " .. x.t) end
    paras[#paras + 1] = x
  end
  local out = {}
  for k, x in ipairs(paras) do
    out[#out + 1] = p(xe.inl(x.content), { left = INDENT, right = INDENT, before = k == 1 and SINGLE or 0,
      after = k == #paras and SINGLE or 0 })
  end
  return table.concat(out)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space), none between a doubled section sign and its number (typst boxes the
-- signs with the number).
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
  -- the body a double line below the caption: an empty line of the body pitch (typst v(pitch-double))
  out[#out + 1] = xe.raw(p("", { line = BODY }))
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
      out[#out + 1] = xe.raw(quotation(b))
      after_quote = true
    else
      error("gub-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
