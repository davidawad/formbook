-- E.D. Ky. bankruptcy adversary complaint, DOCX engine (docs/DOCX.md): markdown + YAML metadata -> Word. Mirrors
-- ../typst/kyeb-adversary-complaint.typ: the court lines, the caption table (rules beside and under the party
-- column), the debtors' note under it, the title, the allegations numbered by the template (FRCP 10(b)), the
-- unnumbered Count subtitles, lead-in, WHEREFORE and colon paragraphs, the lettered lists and the signature block.
-- No case-specific text: everything comes from the metadata. Font, sizes, the body pitch, margins and the page
-- number are styles and section settings in docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line, 240 the debtors' note),
-- the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE, NOTE = 280, 240               -- typst pitch-single 14 pt, pitch-note 12 pt
local NOTE_SZ = 20                          -- typst note-size 10 pt (half points)
local LEFT, RIGHT = 4752, 4608              -- typst caption-left 3.3 in; the rest of the 6.5 in measure
local SIG_RIGHT = 4608                      -- typst signature-col 3.2 in
local SIG_LEFT = 9360 - SIG_RIGHT
local CELL_PAD, ROW_PAD, CAPTION_FOOT = 216, 120, 240 -- typst cell-pad 10.8 pt, row-pad 6 pt, caption-foot 12 pt
-- A cell rule takes room in Word (LibreOffice adds its width to the row), not in typst: every cell of a row whose
-- foot is ruled keeps 0.75 pt (15 twips, w:sz 6) less below its text.
local RULE_W = 15
local DESIGNATION = 2592                    -- typst designation-indent 1.8 in
local HALF, COURT_BELOW = 240, 480          -- typst half-line 12 pt, court-below 24 pt
local NOTE_ABOVE = 120                      -- typst note-above 6 pt
local SIG_ABOVE, SIG_GAP = 480, 480         -- typst signature-above, signature-gap 24 pt

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("kyeb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List" and (v[1] == nil or v[1].t ~= "Str")) then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A single-spaced paragraph: o = { before, after, line, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function mar(top, right, bottom, left)
  return '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

-- A table of fixed columns, no borders and no cell margins unless a cell sets its own; rows are not split across
-- pages (typst: one grid row).
local function tbl(widths, rows)
  local grid = {}
  local total = 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

local function row(cells)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

-- ---------------------------------------------------------------------------
-- Court lines, caption (FRBP 9004(b), 7010; Official Form 416A substantially conformed) and title
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
local RULED = '<w:tcBorders>' .. string.format(RULE, "bottom") .. string.format(RULE, "right") .. '</w:tcBorders>'
local STAR = '<w:r><w:rPr><w:vertAlign w:val="superscript"/></w:rPr><w:t>*</w:t></w:r>'

local function cover(m)
  local out = {}
  local court = items(need(m, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", after = i == #court and COURT_BELOW or 0 })
  end

  local cap = need(m, "caption")
  local debtors = cap.debtors
  local lt = { p(xe.runs("In re:")) }
  for i, n in ipairs(items(debtors.names)) do
    local body = xe.inl(n)
    if i == 1 and debtors.footnote then body = body .. STAR end
    lt[#lt + 1] = p(body, { before = i == 1 and HALF or 0 })
  end
  lt[#lt + 1] = p(xe.inl(debtors.designation), { left = DESIGNATION })

  local rt = { p(xe.inl(need(m, "chapter"))),
    p(xe.runs("Case No. " .. pandoc.utils.stringify(need(m, "case_number"))), { before = HALF }) }
  if need(m, "jointly_administered") == true then rt[#rt + 1] = p(xe.runs("(Jointly Administered)")) end

  local lb = {}
  local parties = items(cap.parties)
  for i, side in ipairs(parties) do
    for j, n in ipairs(items(side.names)) do
      lb[#lb + 1] = p(xe.inl(n), { before = (i > 1 and j == 1) and HALF or 0 })
    end
    for _, l in ipairs(items(side.serve)) do lb[#lb + 1] = p(xe.inl(l)) end
    lb[#lb + 1] = p(xe.inl(side.designation), { left = DESIGNATION, before = side.serve and HALF or 0 })
    if i < #parties then lb[#lb + 1] = p(xe.runs("v."), { before = HALF }) end
  end

  local adv = pandoc.utils.stringify(m.adversary_number or "")
  local rb = { p(xe.runs("Adv. No. " .. (adv == "" and string.rep("_", 12) or adv))) }

  out[#out + 1] = tbl({ LEFT, RIGHT }, {
    row({ cell(LEFT, table.concat(lt), RULED .. mar(0, CELL_PAD, ROW_PAD - RULE_W, 0)),
      cell(RIGHT, table.concat(rt), mar(0, 0, ROW_PAD - RULE_W, CELL_PAD)) }),
    row({ cell(LEFT, table.concat(lb), RULED .. mar(ROW_PAD, CELL_PAD, CAPTION_FOOT - RULE_W, 0)),
      cell(RIGHT, table.concat(rb), mar(ROW_PAD, 0, CAPTION_FOOT - RULE_W, CELL_PAD)) }),
  })

  -- The debtors' note sits under the caption, in the flow (not a page-foot footnote), at 10 pt.
  if debtors.footnote then
    out[#out + 1] = p(xe.runs("* ", { sz = NOTE_SZ }) .. xe.inl(debtors.footnote, { sz = NOTE_SZ }),
      { before = NOTE_ABOVE, line = NOTE })
  end

  local title = items(need(m, "title"))
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.inl(l, { b = true }),
      { jc = "center", before = i == 1 and HALF or 0, after = i == #title and HALF or 0 })
  end
  return table.concat(out)
end

-- "Dated" on the left; the firm, the /s/ line and the counsel lines on the right (FRBP 9011(a)). typst
-- signature-above is spacing of its own before the block, kept with the last paragraph and the block.
local function signature(m)
  local s = need(m, "signature")
  local right = { p(xe.inl(s.firm)), p(xe.runs("By: /s/ ") .. xe.inl(s.signer), { before = SIG_GAP }) }
  for _, l in ipairs(items(s.lines)) do right[#right + 1] = p(xe.inl(l)) end
  return xe.para({ xe.KEEP, xe.spacing(0, 0, SIG_ABOVE) }, "")
    .. tbl({ SIG_LEFT, SIG_RIGHT }, { row({
      cell(SIG_LEFT, p(xe.runs("Dated: ") .. xe.inl(need(m, "date")))),
      cell(SIG_RIGHT, table.concat(right)) }) })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows
-- in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled section sign ("§§ 1408") stays with its number, as the typst template binds it; the shared bind_signs
-- (lib/pandoc/xengine.lua) binds a single sign only.
local function bind_double(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A paragraph that anchors a footnote has no widow control (the "Note" styles, docx/reference.xml): typst moves the
-- line with the mark alone when its note does not fit.
local function styled(style, inlines, keep)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  -- The last block is kept whole with the signature block (typst sticky): the "Last" styles keep it with the next.
  if keep then style = style .. " Last" elseif note then style = style .. " Note" end
  return { pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style }) }
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "court", "caption", "chapter", "case_number", "jointly_administered", "title", "date", "signature" }) do
    local _ = need(m, k)
  end

  local blocks = {}
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  local out = { xe.raw(cover(m)) }
  local numbering_on, after_heading, n = false, false, 0
  local last = #blocks
  for i, b in ipairs(blocks) do
    local keep = i == last
    if b.t == "Header" then
      local c = b.content
      if b.level == 1 then
        -- Level 1 in capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
        c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
      numbering_on, after_heading = true, true
    elseif b.t == "Para" or b.t == "Plain" then
      local text = pandoc.utils.stringify(b)
      if after_heading and text:match("^%(.*%)$") then
        out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Subtitle Line" })
      elseif numbering_on and not text:match("^WHEREFORE") and not text:match(":$") then
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
        inl:extend(b.content)
        for _, x in ipairs(styled("Allegation", inl, keep)) do out[#out + 1] = x end
      else
        for _, x in ipairs(styled("Body Text", b.content, keep)) do out[#out + 1] = x end
      end
      after_heading = false
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      -- The template letters every list a., b., c. (typed text, as in the typst template), the letter hanging.
      for k, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(string.char(96 + k) .. ".\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        for _, x in ipairs(styled("Lettered Item", inl, keep and k == #b.content)) do out[#out + 1] = x end
      end
      after_heading = false
    else
      out[#out + 1] = b
      after_heading = false
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind_double }, { Pandoc = finish } }
