-- E.D. Cal. complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it reads
-- and breaks as typst/caed-complaint.typ does (see ../README.md): the counsel block (L.R. 131(a)), the court title,
-- the caption (Fed. R. Civ. P. 10(a)), the lead-in, the numbered paragraphs (Fed. R. Civ. P. 10(b)), the headings,
-- the prayer items, the unnumbered paragraphs ("[unnumbered] ") and the signature blocks ("---"). The numbered lines,
-- the rules and the footer are docx/reference.xml's; the footer's description is the SUBJECT property, set here from
-- footer_title. Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 240                          -- typst pitch, pitch-single
local INDENT = 720                                     -- typst para-indent, list-indent and list-label, 0.5 in
local TEXTW = 8640                                     -- 6 in
local COUNSEL_LINES = 7                                -- typst counsel-lines (L.R. 131(a))
local CAP_LEFT, CAP_INSET, CAP_FOOT = 4608, 200, 160   -- typst caption-left 3.2 in, caption-inset 10 pt, the 8 pt foot
local CAP_GUTTER, CAP_RIGHT_INSET = 288, 144           -- typst caption-gutter 0.2 in, caption-right-inset 0.1 in
local GAP = 240                                        -- 12 pt between the caption's and signature's groups
local DROP = 192                                       -- typst single-drop: a single-spaced group starts 9.6 pt down
local SIG_LEFT, SIG_GUTTER = 3744, 288                 -- typst signature-left 2.6 in, its 0.2 in gutter

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    local body = cells[i].body or {}
    if #body == 0 then body = { p("") } end
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- The first paragraph of a single-spaced group starts DROP twips further down (a cell keeps its space before).
local function dropped(paras)
  paras[1] = paras[1]:gsub('w:before="(%d+)"', function(b) return 'w:before="' .. (tonumber(b) + DROP) .. '"' end, 1)
  return paras
end

local function list_of(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover: counsel (lines 1-7), court title (line 8), caption, then a new page
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  -- counsel, one single line each, in at least COUNSEL_LINES numbered lines (typst counsel-block: a block of that
  -- height); the court title takes the rest as space before
  local counsel = list_of(meta.counsel)
  out[#out + 1] = p("", { line = DROP })
  for _, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l)) end
  local h = DROP + #counsel * SINGLE
  local pad = math.max(COUNSEL_LINES * BODY, math.ceil(h / BODY) * BODY) - h
  local courts = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF CALIFORNIA" }
  if meta.division then courts[#courts + 1] = pandoc.text.upper(plain(meta.division)) end
  for i, l in ipairs(courts) do
    -- the caption stands one numbered line below the court title (Word has no space before a table: the last title
    -- line takes it as space after)
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", line = BODY, before = i == 1 and pad or 0,
      after = i == #courts and BODY or 0 })
  end
  local left = {}
  for k, party in ipairs(list_of(meta.caption.parties)) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(list_of(party.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local right = { p(xe.runs("Case No.: ") .. xe.inl(meta.case_number), { left = CAP_RIGHT_INSET }),
    p(xe.inl(meta.brief_title, { b = true }), { left = CAP_RIGHT_INSET, before = GAP }) }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { left = CAP_RIGHT_INSET, before = GAP })
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER },
    { { pr = rule, body = dropped(left) }, { body = {} }, { body = dropped(right) } })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: the date at the left; the firm, "By: /s/" and the signer, and the signer's lines at the right;
-- a whole number of numbered lines high, one numbered line below the text, the row never split. The space above it
-- is a 1 pt paragraph kept with the table, its space before the rest: at the top of a page LibreOffice drops a
-- paragraph's space before, as typst drops a block's.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local firm, lines = list_of(sig.firm), list_of(sig.lines)
  local right = {}
  for _, l in ipairs(firm) do right[#right + 1] = p(xe.inl(l)) end
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = GAP })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(lines) do right[#right + 1] = p(xe.inl(l)) end
  local h = DROP + (#firm + 2 + #lines) * SINGLE + GAP
  local rows = math.ceil(h / BODY) * BODY
  return p("", { keep = true, before = BODY - 20, line = 20 }) ..
    tbl({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER },
      { { body = dropped({ p(xe.runs("Dated: ") .. xe.inl(meta.date)) }) }, { body = {} }, { body = dropped(right) } },
      '<w:trPr><w:cantSplit/><w:trHeight w:val="' .. rows .. '" w:hRule="exact"/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, o)
  local q = { line = BODY, first = INDENT, keep = o.keep, brk = o.brk }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings at the body pitch, bold: levels 1 and 2 centered (level 1 in capitals), level 3 at the margin; kept with
-- the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- The prayer: each item's number half an inch in, in a box of half an inch, the text hanging after it; numbers as
-- written, a bullet for "-". The last item is kept with a signature block after it.
local function items(list, keep_last, out)
  local n = list.t == "OrderedList" and list.listAttributes.start or 1
  for i, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("caed-complaint.lua: a list item holds one paragraph")
    end
    local lab = list.t == "OrderedList" and (n .. ".") or "\u{2022}"
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
      { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT, keep = keep_last and i == #list.content })
    n = n + 1
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 1114"), as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph that starts with "[unnumbered]" is not an allegation: its content without the marker, or nil.
local function unnumbered(b)
  local first = b.content[1]
  if first and first.t == "Str" and first.text == "[unnumbered]" then
    local rest = pandoc.Inlines(b.content)
    rest:remove(1)
    if rest[1] and (rest[1].t == "Space" or rest[1].t == "SoftBreak") then rest:remove(1) end
    return rest
  end
  return nil
end

function Pandoc(doc)
  local meta = doc.meta
  local walk = function(x) return x:walk({ Str = breaks }):walk({ Inlines = bind_double_signs }) end
  doc.blocks = walk(doc.blocks)
  local out = cover(meta)
  -- the body starts on a new page
  local brk = true
  if meta.lead_in then
    out[#out + 1] = body_par(nil, walk(pandoc.Inlines(meta.lead_in)), { brk = true })
    brk = false
  end
  local blocks = doc.blocks
  local n = 0
  for i, b in ipairs(blocks) do
    -- the block before a signature block stays whole with it (typst: a sticky, unbreakable block)
    local keep = blocks[i + 1] ~= nil and blocks[i + 1].t == "HorizontalRule"
    local start = #out + 1
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, keep, out)
    elseif b.t == "HorizontalRule" then
      out[#out + 1] = signature(meta)
    elseif b.t == "Para" or b.t == "Plain" then
      local u = unnumbered(b)
      if u then
        out[#out + 1] = body_par(nil, u, { keep = keep })
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, { keep = keep })
      end
    else
      error("caed-complaint.lua: unsupported block " .. b.t)
    end
    if brk then
      -- in the schema's order: after the style and keeps, before the tabs and spacing
      local at = out[start]:find("<w:tabs>", 1, true) or out[start]:find("<w:spacing ", 1, true)
      out[start] = out[start]:sub(1, at - 1) .. xe.BREAK .. out[start]:sub(at)
      brk = false
    end
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- the footer's description (L.R. 130(d)): the SUBJECT property, in capitals as typst sets it
  return pandoc.Pandoc(res, pandoc.Meta({
    subject = pandoc.MetaInlines({ pandoc.Str(pandoc.text.upper(plain(meta.footer_title))) }),
  }))
end
