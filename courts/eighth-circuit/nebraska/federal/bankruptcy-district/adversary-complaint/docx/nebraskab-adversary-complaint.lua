-- Adversary complaint for the United States Bankruptcy Court, District of Nebraska (nebraskab), docx engine: what the
-- Word output adds to pandoc's conversion, so that it reads and breaks as typst/nebraskab-adversary-complaint.typ does
-- (README "Engines"): the court name and the caption (Official Form 416; FRBP 9004(b)), the title in capitals, the
-- headings, the numbered allegations (Fed. R. Civ. P. 10(b)) from the first heading to the prayer, the lettered
-- prayer items and the signature block (FRBP 9011(a); LR 9011-1). Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables; the body paragraphs
-- are pandoc's own (Body Text), so their footnotes are Word footnotes.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360   -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_INDENT, DESIG_INDENT = 720, 1440 -- typst caption-indent 0.5 in, designation-indent 1 in
local INDENT, LETTER_BOX = 720, 576      -- typst para-indent 0.5 in, letter-box 0.4 in
local COURT_NAME = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEBRASKA" }
local LETTERS = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p" }
local CONSENT = "consent to the entry of final orders"
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- a metadata list as Lua values; a single value is a list of one
local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function upper_inlines(ins)
  return pandoc.Inlines(ins):walk({ Str = function(s) s.text = pandoc.text.upper(s.text); return s end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first or 0
  if o.hanging then first = nil end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A table: widths, then rows of cells (each a list of paragraphs, or { pr = .., body = {..} }).
local function tbl(widths, rows, trpr)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row) do
      local body = c.body or c
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption, title (Official Form 416; FRBP 9004(b))
-- ---------------------------------------------------------------------------

-- The caption, one table row per entry (typst: one grid row per entry): the party column, a gutter, the case-number
-- column. Above the rule the "In re:" block with the chapter and case lines; under it the parties with "v." between
-- them, the adversary line at the first party's designation. The rule is the bottom border of the last party-column
-- cell above it.
local function caption(meta)
  local left_a = { "In re:" }
  for _, v in ipairs(items(meta.in_re)) do left_a[#left_a + 1] = v end
  local right_a = { "", meta.chapter }
  for _, v in ipairs(items(meta.case_lines)) do right_a[#right_a + 1] = v end
  local n = math.max(#left_a, #right_a)
  local rows = {}
  for i = 1, n do rows[#rows + 1] = { left_a[i] or "", right_a[i] or "", 0, i == n } end
  rows[#rows + 1] = { "", "", 0, false }
  for k, party in ipairs(items(meta.parties)) do
    if k > 1 then
      rows[#rows + 1] = { "", "", 0, false }
      rows[#rows + 1] = { "v.", "", CAP_INDENT, false }
      rows[#rows + 1] = { "", "", 0, false }
    end
    for _, nm in ipairs(items(party.names)) do rows[#rows + 1] = { nm, "", 0, false } end
    rows[#rows + 1] = { "", "", 0, false }
    rows[#rows + 1] = { party.designation, k == 1 and meta.adversary_line or "", DESIG_INDENT, false }
  end
  local out = {}
  local function text(x) if type(x) == "string" then return xe.runs(x) end return xe.inl(x) end
  for _, r in ipairs(rows) do
    local rule = r[4] and '<w:tcBorders><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders>' or ""
    out[#out + 1] = {
      { pr = rule, body = { p(text(r[1]), { left = r[3] }) } },
      { p("") },
      { p(text(r[2])) },
    }
  end
  return tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, out)
end

local function cover(meta)
  local out = {}
  for i, l in ipairs(COURT_NAME) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #COURT_NAME and BODY or 0 })
  end
  out[#out + 1] = caption(meta)
  -- the title: bold capitals, single spaced, a double line above it (Word has no space after a table) and a single
  -- line below it
  out[#out + 1] = p(xe.inl(upper_inlines(meta.title), { b = true }), { jc = "center", before = BODY, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A heading: one centered bold line at the body pitch (level 1 in capitals, as typed: the Heading 1 style's capitals
-- off), kept with the text after it.
local function heading(content, level)
  if level == 1 then content = upper_inlines(content) end
  local runs = xe.inl(content, { b = true })
  runs = runs:gsub("<w:rPr>(.-)</w:rPr>", function(x)
    local at = x:find("<w:sz", 1, true) or x:find("<w:u ", 1, true) or x:find("<w:bdr", 1, true) or (#x + 1)
    return "<w:rPr>" .. x:sub(1, at - 1) .. '<w:caps w:val="0"/>' .. x:sub(at) .. "</w:rPr>"
  end)
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(level, 5)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, runs))
end

-- A body paragraph (Body Text: the double pitch, first-line indent 0.5 in), written by pandoc so that its footnotes
-- are Word footnotes; a numbered one: the number, a tab to 1 in (typst: the number in a box of the paragraph
-- indent), the text. The last paragraph before the signature is Body Text Last (a double line after it).
local function body_par(num, content, last)
  local ins = pandoc.Inlines({})
  if num then ins:insert(pandoc.Str(num .. ".")); ins:insert(TAB) end
  ins:extend(xe.inlines(content))
  return pandoc.Div({ pandoc.Para(ins) }, pandoc.Attr("", {}, { ["custom-style"] = last and "Body Text Last" or "Body Text" }))
end

-- Lettered prayer items: "(a)" at the paragraph indent, a tab to 0.9 in, the text hanging there; the last one before
-- the signature with a double line after it.
local function lettered(list, last)
  local out = {}
  for k, item in ipairs(list.content) do
    local first = item[1]
    if #item ~= 1 or (first.t ~= "Plain" and first.t ~= "Para") then
      error("nebraskab-adversary-complaint.lua: a prayer item is one paragraph")
    end
    out[#out + 1] = xe.raw(p(xe.runs("(" .. LETTERS[k] .. ")\t") .. xe.inl(first.content),
      { line = BODY, left = INDENT + LETTER_BOX, hanging = LETTER_BOX,
        after = (last and k == #list.content) and BODY or 0 }))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature (FRBP 9011(a); LR 9011-1)
-- ---------------------------------------------------------------------------

-- "Dated" at the left; "Respectfully submitted," and each signer's lines at the right, a blank line between them;
-- one row that does not split. The double line above it (typst: the block's space above, dropped at the top of a
-- page) is the space after the last body paragraph (Body Text Last, or the last prayer item), so a signature that
-- opens a page starts at its top as in typst (Word keeps a table's space before there).
local function signature(meta)
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) }
  local right = { p(xe.runs("Respectfully submitted,")) }
  for _, b in ipairs(items(meta.signature)) do
    for j, l in ipairs(items(b)) do right[#right + 1] = p(xe.inl(l), { before = j == 1 and SINGLE or 0 }) end
  end
  return tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, { { left, { p("") }, right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- "§§ 547" stays whole (typst boxes it): the space after a run of section signs is a no-break space.
local function bind_double_signs(ins)
  for i = 1, #ins - 1 do
    if ins[i].t == "Str" and ins[i].text:match("§§$") and ins[i + 1].t == "Space" then ins[i + 1] = pandoc.Str("\u{a0}") end
  end
  return ins
end

function Pandoc(doc)
  if not pandoc.utils.stringify(doc.blocks):find(CONSENT, 1, true) then
    error("nebraskab-adversary-complaint: the complaint must state consent to the entry of final orders (FRBP 7008(a))", 0)
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = xe.raw(x) end
  -- allegations are numbered from the first heading to the prayer; the intro and the prayer are not
  local numbering, n = false, 0
  for bi, b in ipairs(doc.blocks) do
    local last = bi == #doc.blocks
    if b.t == "Header" then
      if b.level == 1 then numbering = pandoc.text.upper(plain(b.content)) ~= "PRAYER FOR RELIEF" end
      out[#out + 1] = heading(b.content, b.level)
    elseif b.t == "Para" or b.t == "Plain" then
      if numbering then
        n = n + 1
        out[#out + 1] = body_par(n, b.content, last)
      else
        out[#out + 1] = body_par(nil, b.content, last)
      end
    elseif b.t == "BulletList" then
      for _, x in ipairs(lettered(b, last)) do out[#out + 1] = x end
    else
      error("nebraskab-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
