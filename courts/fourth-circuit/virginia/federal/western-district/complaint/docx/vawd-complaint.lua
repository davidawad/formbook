-- Pandoc filter for the W.D. Va. complaint, engine docx, so that it reads and breaks as typst/vawd-complaint.typ
-- does: court title, caption (box or ")" style), the title if the sample has one, lead-in, numbered paragraphs
-- (Fed. R. Civ. P. 10(b)), headings, lettered prayer items, "DATED:" line and signature block (Fed. R. Civ. P.
-- 11(a); W.D. Va. Local Rule 11(a)). Every case word comes from the sample's frontmatter and body, never from this
-- file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
-- Known limit: the ")" caption counts its marks from the text length, not measured (../README.md, "Engines").

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body, pitch-single
local GAP, HEAD_GAP = 552, 276           -- typst gap, head-gap
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local LABEL = 576                        -- typst item-label, 0.4 in
local TEXTW = 9360                       -- 6.5 in
local PARTY = 4752                       -- typst caption-width, 3.3 in
local INSET, TOP = 180, 90               -- typst caption-inset 9 pt, caption-top 4.5 pt
local CASE_GAP = 360                     -- typst case-gap, 0.25 in
local SIG = 4680                         -- typst sig-indent, 3.25 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function upper(m)
  if pandoc.utils.type(m) == "Inlines" then
    return m:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(plain(m))
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, tab, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(cols, rows)
  local grid = {}
  local total = 0
  for _, c in ipairs(cols) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c .. '"/>'
    total = total + c
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- A table cell: width, extra cell properties, its paragraphs.
local function tc(w, pr, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or '') .. '</w:tcPr>' ..
    table.concat(paras) .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

-- The lines of the party block: { runs, left indent }: each name, "v." between the parties, each designation.
local function party_lines(caption)
  local items = {}
  for i, party in ipairs(caption.parties) do
    if i > 1 then items[#items + 1] = { xe.runs("v."), 864 } end
    for _, n in ipairs(party.names) do items[#items + 1] = { xe.inl(n), 0, plain(n) } end
    items[#items + 1] = { xe.inl(party.designation), 2160 }
  end
  return items
end

local function case_line(meta)
  return xe.runs((meta.case_label and plain(meta.case_label) or "Civil Action No.") .. " " .. plain(meta.case_number))
end

-- Box caption: the party block closed by a rule at its right and bottom, a blank single line between its lines;
-- the file number opposite, centered on the block's height.
local function caption_box(meta, caption)
  local left = {}
  for i, it in ipairs(party_lines(caption)) do
    left[#left + 1] = p(it[1], { before = i > 1 and SINGLE or 0, left = it[2] })
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local mar = '<w:tcMar><w:top w:w="' .. TOP .. '" w:type="dxa"/><w:bottom w:w="' .. INSET .. '" w:type="dxa"/>' ..
    '<w:right w:w="' .. INSET .. '" w:type="dxa"/></w:tcMar>'
  return tbl({ PARTY, TEXTW - PARTY }, { '<w:tr>' .. tc(PARTY, rule .. mar, left) ..
    tc(TEXTW - PARTY, '<w:vAlign w:val="center"/>', { p(case_line(meta), { left = CASE_GAP }) }) .. '</w:tr>' })
end

-- Estimated number of lines a caption text takes in the 3.3 in party column (typst measures it): a capital letter
-- counts 1.5 lower-case ones, 40 lower-case letters to a line.
local function caption_lines(s)
  local units = 0
  for ch in s:gmatch(".") do units = units + (ch:match("%u") and 1.5 or 1) end
  return math.max(1, math.ceil(units / 40))
end

-- ")" caption: one row per party line, a ")" for each of its lines; the file number below.
local function caption_parens(meta, caption)
  local rows = {}
  for _, it in ipairs(party_lines(caption)) do
    local marks = {}
    for _ = 1, caption_lines(it[3] or "") do marks[#marks + 1] = p(xe.runs(")"), { jc = "center" }) end
    rows[#rows + 1] = '<w:tr>' .. tc(PARTY, nil, { p(it[1], { left = it[2] }) }) .. tc(576, nil, marks) .. '</w:tr>'
  end
  return tbl({ PARTY, 576 }, rows)
end

-- Returns the space the paragraph after the cover takes above it (Word has no space after a table).
local function cover(meta, out)
  local lines = { "UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF VIRGINIA", pandoc.text.upper(plain(meta.division)) }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l), { jc = "center", after = i == #lines and GAP or 0 })
  end
  local caption = meta.caption or {}
  if plain(caption.style) == "parens" then
    out[#out + 1] = caption_parens(meta, caption)
    out[#out + 1] = p(case_line(meta), { before = SINGLE, after = GAP })
  else
    out[#out + 1] = caption_box(meta, caption)
    if not meta.title then return GAP end
  end
  if meta.title then
    out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { before = SINGLE, after = GAP, jc = "center" })
  end
  return 0
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, kept with the text after them; level 1 centered capitals, level 2 centered, level 3
-- at the margin; all bold.
local function heading(el, before)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(before, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- Prayer items, lettered a., b., ...: the label half an inch in, the text hanging after a 0.4 in label box.
local function items(list, out)
  for j, item in ipairs(list.content) do
    local inl = pandoc.Inlines({})
    for k, b in ipairs(item) do
      if k > 1 then inl:insert(pandoc.Space()) end
      inl:extend(b.content)
    end
    out[#out + 1] = { xe.runs(string.char(96 + j) .. ".\t") .. xe.inl(inl),
      { line = BODY, left = INDENT + LABEL, hanging = LABEL, tab = INDENT + LABEL } }
  end
end

-- The signature block: "DATED:", then at 3.25 in "Respectfully submitted,", the firm lines, "By: /s/" and the
-- signer, the Rule 11(a) lines; all kept together.
local function signature(meta, out)
  local sig = meta.signature or {}
  local lines = { { xe.runs("DATED: " .. plain(meta.date) .. "."), GAP, 0 },
    { xe.runs("Respectfully submitted,"), GAP, SIG } }
  for i, l in ipairs(sig.firm or {}) do lines[#lines + 1] = { xe.inl(l), i == 1 and GAP or 0, SIG } end
  lines[#lines + 1] = { xe.runs("By: /s/ ") .. xe.inl(sig.signer), GAP, SIG }
  lines[#lines + 1] = { xe.inl(sig.signer), 0, SIG }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("D/B/A": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1331": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function is_prayer(b)
  return b.t == "Header" and plain(b.content):find("PRAYER", 1, true) ~= nil
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  local before = cover(meta, out)
  -- body paragraphs as { runs, options }, written once the last one (kept with the signature) is known
  local body = {}
  if meta.lead_in then body[#body + 1] = { xe.inl(meta.lead_in), { line = BODY, first = INDENT } } end
  local n = 0
  local unnumbered_next, after_heading = false, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if is_prayer(b) then unnumbered_next = true end
      body[#body + 1] = { heading = b, before = after_heading and 0 or HEAD_GAP }
      after_heading = true
    else
      after_heading = false
      if b.t == "OrderedList" or b.t == "BulletList" then
        items(b, body)
      elseif b.t == "Para" or b.t == "Plain" then
        if unnumbered_next then
          body[#body + 1] = { xe.inl(b.content), { line = BODY, first = INDENT } }
        else
          n = n + 1
          body[#body + 1] = { xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = 2 * INDENT } }
        end
      else
        error("vawd-complaint.lua: unsupported block " .. b.t)
      end
      unnumbered_next = false
    end
  end
  for i, x in ipairs(body) do
    local sp = i == 1 and before or 0
    if x.heading then
      out[#out + 1] = heading(x.heading, math.max(sp, x.before))
    else
      x[2].before = math.max(sp, x[2].before or 0)
      x[2].keep = i == #body
      out[#out + 1] = p(x[1], x[2])
    end
  end
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
