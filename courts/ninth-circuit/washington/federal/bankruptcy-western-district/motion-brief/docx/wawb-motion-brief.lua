-- Motion with a combined memorandum, U.S. Bankruptcy Court, W.D. Washington (wawb), docx engine (docs/DOCX.md).
-- Mirrors typst/wawb-motion-brief.typ; rules and conventions are in ../README.md. Built here: the notation at the top
-- right (the judge, the chapter, the hearing location, date and time and the response date: LBR 9013-1(d)(1)(B),
-- LBR 9004-1(b)(2)), the court title, the caption (the debtor's names and designation over a rule, a ")" column, the
-- case number and the title at right), the body (paragraphs with a first-line indent, not numbered; block quotations
-- indented both sides, double spaced; bulleted lists; the "Dated:" paragraph kept whole); and the page furniture
-- of the pleading paper in the footer this filter writes ($FORMBOOK_FOOTERS, fb render; tools/fb/src/docxpass.rs):
-- the line numbers 1 to 27 down the left margin level with the numbered lines (LBR 9004-1(b)(1)), the double rule at
-- the text's left edge and the single rule at its right, and the bottom notation (LBR 9004-1(b)(3): the abbreviated
-- title and the page number at left, counsel at right, from the frontmatter's footer_title and footer_counsel), and
-- the last section ($FORMBOOK_FINAL). Font and sizes are styles in docx/reference.xml.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter or body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 a numbered line, 240 a single line), the spaces between
-- blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, FOOT = 480, 240, 240     -- typst pitch, pitch-single, pitch-footer
local LINES = 27                             -- typst lines-per-page
local TEXTW = 8640                           -- typst text-width, 6 in
local LEFT_MARGIN, TOP_MARGIN = 2160, 1440   -- typst left-margin 1.5 in, top-margin 1 in
local PARA_INDENT, QUOTE_INDENT = 720, 720   -- typst para-indent, quote-indent 0.5 in
local LIST_INDENT, LIST_BOX = 720, 576       -- typst list-indent 0.5 in, list-box 0.4 in
local NOTATION_W = 5184                      -- typst notation-width 3.6 in
local CAP_LEFT, CAP_GUTTER = 4320, 360       -- typst caption-left 3 in, caption-gutter 0.25 in
local CAP_PAD_BOTTOM = 225                   -- typst caption-pad-bottom 12 pt less the 0.75 pt rule Word adds below
local CASE_PAD = 144                         -- typst case-pad 0.1 in
local FOOT_RIGHT, FOOT_GUTTER = 3888, 288    -- typst footer-right 2.7 in, footer-gutter 0.2 in
local FOOT_GAP = 80                          -- typst footer-gap 4 pt
local FOOT_SIZE = 22                         -- typst footer-size 11 pt (half points)
-- The footer: a row of exact height below the 72 pt bottom margin's top, then a 1 pt paragraph that holds the
-- page-anchored furniture; with the footer distance they fill the margin, so the row starts at the last numbered
-- line's foot (720 pt) and its text 4 pt lower, where typst places the notation. 1040 + 20 + 380 = 1440.
local FOOT_ROW, FOOT_END, FOOT_DIST = 1040, 20, 380

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

local function items(v)
  if v == nil then return {} end
  if type(v) == "table" and (v.t == "MetaList" or v.t == nil) then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph in exact line boxes: o = { before, line, jc, keep, first, left, hanging, tab, outline }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  local first = nil
  if not o.hanging then first = o.first or 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- Single-spaced lines (typst line-stack): an empty item is a blank line, the next line a line lower; `above` a space
-- of its own above the first line.
local function stack(lines, above, o)
  local out, gap = {}, above or 0
  o = o or {}
  for _, l in ipairs(lines) do
    if txt(l) == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(line(l, o), { before = gap, jc = o.jc })
      gap = 0
    end
  end
  return table.concat(out)
end

-- Single lines start this far below a numbered line's top (typst single-offset: every other one on a numbered
-- line's baseline, the others halfway between two), and the space that brings a block of height h (from a numbered
-- line's top) back onto the numbered lines (typst regrid). Heights are counted from the items, as typst counts them.
local OFFSET = (BODY - SINGLE) * 4 // 5
local function regrid(h)
  local r = h % BODY
  return r == 0 and 0 or BODY - r
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>'
    .. (inner ~= "" and inner or p("")) .. '</w:tc>'
end

-- A one-row table without borders or cell margins of its own, not split across pages; `tr` more row properties.
local function table1(widths, cells, tr)
  local grid, w = {}, 0
  for _, x in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. x .. '"/>'
    w = w + x
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. w .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/>' .. (tr or "")
    .. '</w:trPr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

-- A metadata value with text before it, as one line (inlines).
local function cat(prefix, v)
  local out = pandoc.Inlines({ pandoc.Str(prefix) })
  if v ~= nil then out:extend(pandoc.Inlines(v)) end
  return out
end

local function notation_rows(m)
  local h = m.hearing or {}
  local out = {}
  for _, k in ipairs({ "judge", "chapter" }) do
    if m[k] ~= nil then out[#out + 1] = m[k] end
  end
  out[#out + 1] = cat("Hearing location: ", h.location)
  out[#out + 1] = cat("Hearing date: ", h.date)
  out[#out + 1] = cat("Hearing time: ", h.time)
  out[#out + 1] = cat("Response date: ", h.response_date)
  return out
end

local function caption_rows(m)
  local rows = {}
  for _, n in ipairs(items(m.debtor.names)) do rows[#rows + 1] = n end
  rows[#rows + 1] = m.debtor.designation
  return rows
end

local function cover(m)
  local out = {}
  local notation = notation_rows(m)
  out[#out + 1] = table1({ TEXTW - NOTATION_W, NOTATION_W }, {
    cell(TEXTW - NOTATION_W, ""),
    cell(NOTATION_W, stack(notation, OFFSET, { jc = "right" })),
  })
  local court = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF WASHINGTON" }
  if m.division ~= nil then court[#court + 1] = pandoc.text.upper(txt(m.division)) end
  for k, l in ipairs(court) do
    local before = k == 1 and (BODY + regrid(OFFSET + #notation * SINGLE)) or 0
    out[#out + 1] = p(xe.runs(l, { b = true }), { before = before, line = BODY, jc = "center" })
  end
  out[#out + 1] = space(BODY)
  local cap_right = TEXTW - CAP_LEFT - CAP_GUTTER
  local caption = caption_rows(m)
  local parens = {}
  for _ in ipairs(caption) do parens[#parens + 1] = ")" end
  out[#out + 1] = table1({ CAP_LEFT, CAP_GUTTER, cap_right }, {
    cell(CAP_LEFT, stack(caption, OFFSET), '<w:tcBorders>' .. string.format(RULE, "bottom")
      .. '</w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_PAD_BOTTOM .. '" w:type="dxa"/></w:tcMar>'),
    cell(CAP_GUTTER, stack(parens, OFFSET)),
    cell(cap_right, stack({ m.case_number }, OFFSET) .. stack({ m.brief_title }, SINGLE, { b = true }),
      '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_PAD_BOTTOM .. '" w:type="dxa"/></w:tcMar>'),
  })
  return table.concat(out), BODY + regrid(OFFSET + (#caption + 1) * SINGLE)
end

-- ---------------------------------------------------------------------------
-- The footer: line numbers, rules and the bottom notation (typst line-numbers, pleading-rules, footer-block)
-- ---------------------------------------------------------------------------

local EMU = 635   -- per twip
local NS = 'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
  .. 'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
  .. 'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"'

-- A shape anchored to the page at (x, y) twips, cx by cy twips, behind the text.
local function anchor(id, name, x, y, cx, cy, shape)
  return '<w:r><w:drawing><wp:anchor ' .. NS .. ' distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="'
    .. (251659264 + id) .. '" behindDoc="1" locked="1" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/>'
    .. '<wp:positionH relativeFrom="page"><wp:posOffset>' .. (x * EMU) .. '</wp:posOffset></wp:positionH>'
    .. '<wp:positionV relativeFrom="page"><wp:posOffset>' .. (y * EMU) .. '</wp:posOffset></wp:positionV>'
    .. '<wp:extent cx="' .. (cx * EMU) .. '" cy="' .. (cy * EMU) .. '"/><wp:effectExtent l="0" t="0" r="0" b="0"/>'
    .. '<wp:wrapNone/><wp:docPr id="' .. id .. '" name="' .. name .. '"/><wp:cNvGraphicFramePr/><a:graphic>'
    .. '<a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp>' .. shape
    .. '</wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r>'
end

local function geometry(cx, cy, prst)
  return '<a:xfrm><a:off x="0" y="0"/><a:ext cx="' .. (cx * EMU) .. '" cy="' .. (cy * EMU) .. '"/></a:xfrm>'
    .. '<a:prstGeom prst="' .. prst .. '"><a:avLst/></a:prstGeom>'
end

-- The numbers 1 to 27 in a text box of the first inch, one per numbered line, right-aligned.
local function numbers()
  local ps = {}
  for i = 1, LINES do
    ps[#ps + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, BODY) .. xe.ind(0, nil, 0) .. xe.jc("right") .. '</w:pPr>'
      .. xe.runs(tostring(i)) .. '</w:p>'
  end
  return anchor(1, "Line numbers", 0, TOP_MARGIN, 1440, LINES * BODY,
    '<wps:cNvSpPr txBox="1"/><wps:spPr>' .. geometry(1440, LINES * BODY, "rect") .. '<a:noFill/><a:ln><a:noFill/></a:ln>'
    .. '</wps:spPr><wps:txbx><w:txbxContent>' .. table.concat(ps) .. '</w:txbxContent></wps:txbx>'
    .. '<wps:bodyPr rot="0" vert="horz" wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="t" anchorCtr="0">'
    .. '<a:noAutofit/></wps:bodyPr>')
end

-- A rule down the whole page at x twips, 0.75 pt.
local function rule(id, x)
  return anchor(id, "Rule " .. id, x, 0, 0, 15840, '<wps:cNvCnPr/><wps:spPr>' .. geometry(0, 15840, "line")
    .. '<a:ln w="9525"><a:solidFill><a:srgbClr val="000000"/></a:solidFill></a:ln></wps:spPr><wps:bodyPr/>')
end

local PAGE = '<w:r><w:rPr><w:sz w:val="' .. FOOT_SIZE .. '"/><w:szCs w:val="' .. FOOT_SIZE .. '"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="' .. FOOT_SIZE .. '"/><w:szCs w:val="' .. FOOT_SIZE .. '"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="' .. FOOT_SIZE .. '"/><w:szCs w:val="' .. FOOT_SIZE .. '"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="' .. FOOT_SIZE .. '"/><w:szCs w:val="' .. FOOT_SIZE .. '"/></w:rPr><w:t>1</w:t></w:r>'
  .. '<w:r><w:rPr><w:sz w:val="' .. FOOT_SIZE .. '"/><w:szCs w:val="' .. FOOT_SIZE .. '"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>'

-- The sample's frontmatter as written (fb render's $FORMBOOK_META): the notation's strings are plain text in typst.
local function frontmatter()
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  if not f then return {} end
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false)
end

local function footer(fm)
  local o = { sz = FOOT_SIZE }
  local left = p(xe.runs(pandoc.text.upper(fm.footer_title or "") .. " - ", o) .. PAGE, { before = FOOT_GAP, line = FOOT })
  local right = {}
  for k, l in ipairs(fm.footer_counsel or {}) do
    right[#right + 1] = p(xe.runs(l, o), { before = k == 1 and FOOT_GAP or 0, line = FOOT, jc = "right" })
  end
  local left_w = TEXTW - FOOT_GUTTER - FOOT_RIGHT
  local notation = table1({ left_w, FOOT_GUTTER, FOOT_RIGHT },
    { cell(left_w, left), cell(FOOT_GUTTER, ""), cell(FOOT_RIGHT, table.concat(right)) },
    '<w:trHeight w:val="' .. FOOT_ROW .. '" w:hRule="exact"/>')
  -- typst pleading-rules: 0.2 in and 0.16 in left of the text, 0.1 in right of it
  local furniture = numbers() .. rule(2, LEFT_MARGIN - 288) .. rule(3, LEFT_MARGIN - 230) .. rule(4, LEFT_MARGIN + TEXTW + 144)
  return notation .. xe.para({ xe.spacing(0, 0, FOOT_END) }, furniture)
end

local function write_file(var, text)
  local path = os.getenv(var)
  if not path then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole ("and/or"): a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 502"), as typst keeps it (xengine.lua binds a single sign).
local function bind_doubled(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and l[i].text:match("^[§¶][§¶]+$") and l[i + 1].t == "Space" then l[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- Inlines as runs, a hard line break (the author's "\" at a line's end) as a Word line break (typst linebreak()).
local function inl_br(inlines, o)
  local out, seg = {}, pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "LineBreak" then
      out[#out + 1] = xe.inl(seg, o) .. xe.BR
      seg = pandoc.Inlines({})
    else
      seg:insert(el)
    end
  end
  out[#out + 1] = xe.inl(seg, o)
  return table.concat(out)
end

local function body(doc, first_above)
  local out = {}
  for k, b in ipairs(doc.blocks) do
    local before = 0
    if k == 1 then
      if b.t == "Para" or b.t == "Plain" then before = first_above else out[#out + 1] = space(first_above) end
    end
    if b.t == "Header" then
      local lvl = math.min(b.level, 3)
      local o = { b = lvl < 3, i = lvl == 3 }
      out[#out + 1] = p(xe.inl(lvl == 1 and upper(b.content) or b.content, o),
        { line = BODY, jc = lvl == 1 and "center" or "left", keep = true, outline = lvl - 1 })
    elseif b.t == "Para" or b.t == "Plain" then
      -- the signature paragraph (it starts "Dated:") is kept whole on one page
      local dated = pandoc.utils.stringify(b):sub(1, 6) == "Dated:"
      local props = { xe.spacing(before, 0, BODY), xe.ind(0, nil, PARA_INDENT), xe.jc("left") }
      if dated then table.insert(props, 1, xe.LINES) end
      out[#out + 1] = xe.para(props, inl_br(b.content))
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = xe.para({ xe.spacing(0, 0, BODY), xe.ind(QUOTE_INDENT, nil, 0, QUOTE_INDENT), xe.jc("left") },
          inl_br(q.content))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local n = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
        out[#out + 1] = p(xe.runs(lab .. "\t") .. inl_br(pandoc.utils.blocks_to_inlines(item)),
          { line = BODY, left = LIST_INDENT + LIST_BOX, hanging = LIST_BOX, tab = LIST_INDENT + LIST_BOX })
        n = n + 1
      end
    else
      error("wawb-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  return table.concat(out)
end

local function finish(doc)
  local m = doc.meta
  write_file("FORMBOOK_FOOTERS", "rIdWawbFooter\t" .. footer(frontmatter()) .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdWawbFooter"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="' .. TOP_MARGIN .. '" w:right="1440" w:bottom="1440" w:left="'
    .. LEFT_MARGIN .. '" w:header="720" w:footer="' .. FOOT_DIST .. '" w:gutter="0"/></w:sectPr>')
  local front, below = cover(m)
  local xml = front .. body(doc, below)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(xml) }, pandoc.Meta({}))
end

return { { Str = break_rules }, { Inlines = bind_doubled }, { Pandoc = finish } }
