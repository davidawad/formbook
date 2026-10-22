-- ncmb-motion-brief.lua (docx engine): the M.D.N.C. Bankruptcy motion brief as Word paragraphs, so that it reads and
-- breaks as typst/ncmb-motion-brief.typ does: the court lines, the caption (Form 416D; one table row per line: the
-- parties, a ")" column, the case numbers, closed by a rule), the title, the body (paragraphs, headings numbered I.,
-- A., 1., a. below an unnumbered level 1, numbered lists, footnotes), the signature block (LR 9011-4) and the
-- certificate of service on a page of its own (LR 9004-1). Everything printed comes from the sample's frontmatter
-- and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line, 320 a caption
-- row), the spaces between blocks those of the typst template, and the break rules of typst on every run. A body
-- paragraph that carries a footnote is left to pandoc (it writes the note) in the style "Body Text Note"
-- (reference.xml); every other one is written here.

local xe = require("docx.xengine")

local BODY, SINGLE, ROW = 480, 276, 320  -- typst pitch-double, pitch-single, cap-row
local GAP = 240                          -- typst gap-half, 12 pt
local RULE_GAP = 180                     -- typst caption-rule-gap, 9 pt
local INDENT = 720                       -- typst para-indent and heading-tab, 0.5 in
local RECIPIENT = 720                    -- typst recipient-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAREN = 4608, 504    -- typst caption-left 3.2 in, caption-paren 0.35 in
local CAP_INSET = 360                    -- typst caption-inset, 0.25 in
local SIG = 4680                         -- typst signature-indent, 3.25 in

local stringify = pandoc.utils.stringify

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

local function need(m, key)
  if m[key] == nil then error("ncmb-motion-brief.lua: missing required frontmatter field `" .. key .. "`") end
  return m[key]
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, brk, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless table of rows of exact height: rows = { { h = twips, cells = { { w, xml, rule } ... } } }; a cell
-- with `rule` (eighths of a point) has a bottom border, and a row with one cell spans every column.
local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for _, c in ipairs(row.cells) do
      local span = #row.cells == 1 and #widths > 1 and ('<w:gridSpan w:val="' .. #widths .. '"/>') or ""
      local rule = c[3] and ('<w:tcBorders><w:bottom w:val="single" w:sz="' .. c[3] ..
        '" w:space="0" w:color="000000"/></w:tcBorders>') or ""
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. span .. rule .. '</w:tcPr>' ..
        (c[2] or p("", { line = row.h })) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. row.h .. '" w:hRule="exact"/></w:trPr>' ..
      table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court lines, caption (Form 416D), title
-- ---------------------------------------------------------------------------

local JC = { l = "left", c = "center", r = "right" }

-- A caption row is a string, or a map {t: text, a: "l" | "c" | "r"}.
local function cap_cell(item, left)
  local t, a = item, "l"
  if type(item) == "table" and item[1] == nil and type(item.t) == "table" then
    t = item["t"]
    a = item["a"] and plain(item["a"]) or "l"
  end
  return p(xe.inl(t), { line = ROW, left = left, jc = JC[a] })
end

local function caption(meta)
  local cap = need(meta, "caption")
  local left = need(cap, "left")
  local right = cap.right or {}
  local rows = {}
  for i = 1, math.max(#left, #right) do
    rows[#rows + 1] = { h = ROW, cells = {
      { CAP_LEFT, cap_cell(left[i] or "") },
      { CAP_PAREN, p(xe.runs(")"), { line = ROW, jc = "center" }) },
      { TEXTW - CAP_LEFT - CAP_PAREN, cap_cell(right[i] or "", CAP_INSET) },
    } }
  end
  -- the rule under the caption (typst: a block of caption-rule-gap with a bottom stroke)
  rows[#rows + 1] = { h = RULE_GAP, cells = { { TEXTW, nil, 6 } } }
  return tbl({ CAP_LEFT, CAP_PAREN, TEXTW - CAP_LEFT - CAP_PAREN }, rows)
end

local function cover(meta, out)
  for _, l in ipairs(need(meta, "court")) do out[#out + 1] = p(xe.inl(l), { jc = "center" }) end
  -- typst: the caption block stands a double line below the court lines
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = caption(meta)
  out[#out + 1] = p(xe.inl(need(meta, "title"), { b = true }), { jc = "center", before = GAP, after = GAP })
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 9011-4) and certificate of service (LR 9004-1): kept together
-- ---------------------------------------------------------------------------

-- rows: { body, left, before }; every paragraph but the last kept with the next.
local function kept(rows, out, brk)
  for i, r in ipairs(rows) do
    out[#out + 1] = p(r[1], { left = r[2], before = r[3], line = r[4], first = r[5], jc = r[6],
      keep = i < #rows, brk = brk and i == 1 })
  end
end

local function group(rows, before, left, items)
  for i, l in ipairs(items) do
    rows[#rows + 1] = { type(l) == "string" and xe.runs(l) or xe.inl(l), left, i == 1 and before or 0 }
  end
end

local function signature(meta, out)
  local sig = need(meta, "signature")
  local rows = { { xe.inl(need(sig, "dated")), 0, BODY } }
  group(rows, GAP, SIG, { "/s/ " .. plain(need(sig, "signed_by")) })
  for _, s in ipairs(need(sig, "signers")) do
    group(rows, GAP, SIG, { plain(s.name), "N.C. State Bar No. " .. plain(s.bar), "Email: " .. plain(s.email) })
  end
  local tail = {}
  for _, l in ipairs(need(sig, "firm")) do tail[#tail + 1] = l end
  for _, l in ipairs(need(sig, "address")) do tail[#tail + 1] = l end
  tail[#tail + 1] = "Telephone: " .. plain(need(sig, "phone"))
  group(rows, GAP, SIG, tail)
  group(rows, GAP, SIG, need(sig, "role"))
  kept(rows, out)
end

local function certificate(meta, out)
  local svc = meta.service
  if not svc then return end
  local sig = need(meta, "signature")
  -- the heading opens a new page (typst: pagebreak), then the statement at the body pitch
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", keep = true, brk = true })
  out[#out + 1] = p(xe.inl(need(svc, "statement")), { line = BODY, first = INDENT, before = GAP })
  -- each recipient: the lines, then the method in italics; never split across a page
  for _, r in ipairs(need(svc, "recipients")) do
    local rows = {}
    group(rows, GAP, RECIPIENT, need(r, "lines"))
    rows[#rows + 1] = { xe.inl(need(r, "method"), { i = true }), RECIPIENT, 0 }
    kept(rows, out)
  end
  local rows = { { xe.inl(svc.dated or need(sig, "dated")), 0, BODY } }
  group(rows, GAP, SIG, { "/s/ " .. plain(need(sig, "signed_by")) })
  kept(rows, out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- The label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a." (typst heading-label).
local function heading_label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return n .. "." end
  return string.char(96 + n) .. "."
end

local counts = { 0, 0, 0, 0, 0, 0 }

-- Headings: single-spaced, 12 pt above and below, kept with the text. Level 1 centered bold capitals, unnumbered;
-- level 2 and deeper: the label in a half-inch box at the level's indent, the bold title hanging after it. The
-- Heading styles give the outline level (reference.xml turns the recipe's italics of Heading 4 and 5 off).
local function heading(b)
  if b.level == 1 then
    local content = pandoc.Inlines(b.content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(GAP, GAP, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(content, { b = true }))
  end
  if b.level > 5 then error("ncmb-motion-brief.lua: headings deeper than level 5 are not supported") end
  counts[b.level] = counts[b.level] + 1
  for k = b.level + 1, 6 do counts[k] = 0 end
  local ind = (b.level - 2) * INDENT
  -- the label is not bold (typst: only the title is strong); the Heading style is
  local runs = '<w:r><w:rPr><w:b w:val="0"/><w:bCs w:val="0"/></w:rPr><w:t xml:space="preserve">' ..
    heading_label(b.level, counts[b.level]) .. '</w:t></w:r><w:r><w:tab/></w:r>' .. xe.inl(b.content, { b = true })
  return xe.para({ xe.style("Heading" .. b.level), xe.KEEP, xe.spacing(GAP, GAP, SINGLE),
    xe.ind(ind + INDENT, INDENT, nil), xe.jc("left") }, runs)
end

local function has_note(b)
  local found = false
  b:walk({ Note = function() found = true end })
  return found
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 16-17"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  for _, k in ipairs({ "court", "caption", "title", "signature" }) do need(meta, k) end
  local out = {}
  cover(meta, out)
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" then
      -- the number at the paragraph indent in a box of its width, the text hanging after it
      local n = b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        if has_note(pandoc.Div(item)) then error("ncmb-motion-brief.lua: a footnote in a list item is not supported") end
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(item[1].content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
        n = n + 1
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if has_note(b) then
        -- pandoc writes the footnote; the paragraph takes Body Text's pitch and indent, without widow control
        out[#out + 1] = pandoc.Div({ pandoc.Para(b.content):walk({ Inlines = xe.inlines }) },
          { ["custom-style"] = "Body Text Note" })
      else
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
      end
    else
      error("ncmb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  certificate(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
