-- ncmb-adversary-complaint.lua (docx engine): the M.D.N.C. Bankruptcy adversary complaint as Word paragraphs, so
-- that it reads and breaks as typst/ncmb-adversary-complaint.typ does: the court lines, the caption (Form 416D; one
-- table row per line: the parties, a ")" column, the case numbers, closed by a rule), the title, the unnumbered
-- lead-in, the numbered paragraphs (Fed. R. Civ. P. 10(b); a WHEREFORE chunk is not numbered), headings, block
-- quotations, a paragraph's (i), (ii) sub-items, the prayer lettered A., B., ..., the footnotes (a [^n] marker
-- becomes a Word footnote whose text is footnotes.n in the frontmatter) and the signature block (LR 9011-4).
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line, 320 a caption
-- row), the spaces between blocks those of the typst template, and the break rules of typst on every run. A body
-- paragraph that carries a footnote is left to pandoc (it writes the note) in the style "Body Text Note" or
-- "Numbered Note" (reference.xml); every other one is written here. pandoc reads the sample without fancy lists
-- (reference.xml pandoc-from), so "- (i) ..." is a bullet item holding the text "(i) ...", as typst reads it.

local xe = require("docx.xengine")

local BODY, SINGLE, ROW = 480, 276, 320  -- typst pitch-double, pitch-single, cap-row
local GAP = 240                          -- typst gap-half, 12 pt
local RULE_GAP = 180                     -- typst caption-rule-gap, 9 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local SUB = 1440                         -- typst sub-indent, 1 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAREN = 4608, 504    -- typst caption-left 3.2 in, caption-paren 0.35 in
local CAP_INSET = 360                    -- typst caption-inset, 0.25 in
local SIG = 4680                         -- typst signature-indent, 3.25 in
local TAB2 = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>'

local stringify = pandoc.utils.stringify

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

local function need(m, key)
  if m[key] == nil then error("ncmb-adversary-complaint.lua: missing required frontmatter field `" .. key .. "`") end
  return m[key]
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
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
  local n = math.max(#left, #right)
  local rows = {}
  for i = 1, n do
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

local function cover(meta)
  local out = {}
  for _, l in ipairs(need(meta, "court")) do out[#out + 1] = p(xe.inl(l), { jc = "center" }) end
  -- typst: the caption block stands a double line below the court lines
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = caption(meta)
  out[#out + 1] = p(xe.inl(need(meta, "title"), { b = true }), { jc = "center", before = GAP, after = GAP })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 9011-4): kept together
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local rows = { { xe.inl(need(sig, "dated")), 0, BODY } }
  local function group(items)
    for i, l in ipairs(items) do rows[#rows + 1] = { type(l) == "string" and xe.runs(l) or xe.inl(l), SIG, i == 1 and GAP or 0 } end
  end
  group(need(sig, "firm"))
  group({ "/s/ " .. plain(need(sig, "signed_by")) })
  for _, s in ipairs(need(sig, "signers")) do
    group({ plain(s.name), "N.C. State Bar No. " .. plain(s.bar), "Email: " .. plain(s.email) })
  end
  local tail = {}
  for _, l in ipairs(need(sig, "address")) do tail[#tail + 1] = l end
  tail[#tail + 1] = "Telephone: " .. plain(need(sig, "phone"))
  for _, l in ipairs(need(sig, "role")) do tail[#tail + 1] = l end
  group(tail)
  local out = {}
  for i, r in ipairs(rows) do out[#out + 1] = p(r[1], { left = r[2], before = r[3], keep = i < #rows }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Footnote markers: pandoc leaves "[^n]" as text when its definition is not in the body, so the Str is split and
-- each marker becomes a Note holding footnotes.n.
local function expand(inls, notes)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inls) do
    if el.t == "Str" and el.text:find("%[%^%d+%]") then
      local s, pos = el.text, 1
      while true do
        local a, b, k = s:find("%[%^(%d+)%]", pos)
        if not a then break end
        if a > pos then out:insert(pandoc.Str(s:sub(pos, a - 1))) end
        if notes[k] == nil then error("ncmb-adversary-complaint.lua: footnote [^" .. k .. "] has no text under `footnotes:`") end
        out:insert(pandoc.Note({ pandoc.Para(pandoc.Inlines(notes[k])) }))
        pos = b + 1
      end
      if pos <= #s then out:insert(pandoc.Str(s:sub(pos))) end
    else
      out:insert(el)
    end
  end
  return out
end

local function has_note(inls)
  for _, el in ipairs(inls) do if el.t == "Note" then return true end end
  return false
end

-- Headings: single-spaced, 12 pt above and below, kept with the text; level 1 centered bold capitals, level 2
-- centered bold, level 3 bold italic at the margin. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  if b.level == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(b.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(GAP, GAP, SINGLE), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

-- A body paragraph at the double pitch, first line indented: unnumbered, or the number, a tab to the end of its
-- half-inch box (typst: box(width: para-indent)), the text. One with a footnote is written by pandoc.
local function body_par(label, inls)
  if has_note(inls) then
    local c = pandoc.Inlines({})
    if label then c:extend({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }) end
    c:extend(inls)
    local para = pandoc.Para(c):walk({ Inlines = xe.inlines })
    return pandoc.Div({ para }, { ["custom-style"] = label and "Numbered Note" or "Body Text Note" })
  end
  if label == nil then return p(xe.inl(inls), { line = BODY, first = INDENT }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inls), { line = BODY, first = INDENT, tabs = TAB2 })
end

-- Footnotes are written by pandoc in a body paragraph only.
local function no_note(inls, where)
  if has_note(inls) then error("ncmb-adversary-complaint.lua: a footnote in " .. where .. " is not supported") end
  return inls
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1408"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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
  local fix = { Str = breaks }
  doc = doc:walk(fix):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  for _, k in ipairs({ "court", "caption", "title", "lead_in", "signature" }) do need(meta, k) end
  local notes = {}
  for k, v in pairs(meta.footnotes or {}) do
    notes[k] = pandoc.Inlines(v):walk(fix):walk({ Inlines = bind_doubled })
  end
  local out = cover(meta)
  out[#out + 1] = body_par(nil, expand(pandoc.Inlines(meta.lead_in), notes))
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(no_note(expand(q.content, notes), "a quotation")),
          { before = GAP, after = GAP, left = QUOTE, right = QUOTE })
      end
    elseif b.t == "OrderedList" then
      -- the prayer, lettered: the letter at the item indent in a box of its width, the text hanging after it
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs(string.char(64 + i) .. ".\t") .. xe.inl(no_note(expand(item[1].content, notes), "the prayer")),
          { line = BODY, left = 2 * INDENT, hanging = INDENT })
      end
    elseif b.t == "BulletList" then
      -- a paragraph's sub-items, with their own (i), (ii) labels and no bullet
      for _, item in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(no_note(expand(item[1].content, notes), "a sub-item")), { line = BODY, left = SUB })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local inls = expand(b.content, notes)
      if stringify(b):match("^WHEREFORE") then
        out[#out + 1] = body_par(nil, inls)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", inls)
      end
    else
      error("ncmb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
