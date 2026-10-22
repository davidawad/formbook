-- mtd-complaint.lua (docx engine): the D. Mont. complaint as Word paragraphs, so that it reads and breaks as
-- typst/mtd-complaint.typ does: the counsel groups in two columns with the role under the left one, the court title
-- (Appendix C, Form A), the caption (a table whose party column has the right and bottom rules, the case number and
-- the title beside it), then from page two the unnumbered lead-in, the paragraphs numbered 1., 2., ... (Fed. R. Civ.
-- P. 10(b)); a paragraph beginning "~ " is unnumbered (WHEREFORE, the jury demand; the marker is removed), headings,
-- the prayer lettered A., B., ..., and the signature block (L.R. 1.5(b), 11.1), kept with the last paragraph.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 640 the double-spaced body, 320 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. A paragraph that carries a
-- footnote is left to pandoc in "Body Text Note" (the same layout), so that pandoc writes the note.

local xe = require("docx.xengine")

local BODY, SINGLE = 640, 320            -- typst pitch-double, pitch-single
local GAP = 320                          -- typst gap-half
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAD = 4896, 288      -- typst caption-left 3.4 in, caption-pad 0.2 in
local DESIG = 2016                       -- typst designation-indent, 1.4 in
local GUTTER = 432                       -- typst counsel-gutter, 0.3 in
local SIG_LEFT = 4896                    -- typst sig-left, 3.4 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tabs, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
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

-- A borderless one-row table that never splits: cells = { { width, paragraphs, tcBorders } }.
local function tbl(cells)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    local body = #c[2] > 0 and table.concat(c[2]) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption and title (Appendix C, Form A)
-- ---------------------------------------------------------------------------

-- typst counsel-split: the first k groups on the left, so that the taller column has as few lines as possible.
local function counsel_split(groups)
  local n = #groups
  if n < 2 then return n end
  local function lines(a, b)
    local s, c = 0, 0
    for i = a, b do s = s + #groups[i]; c = c + 1 end
    return s + math.max(c - 1, 0)
  end
  local best, cost = 1, nil
  for k = 1, n - 1 do
    local m = math.max(lines(1, k), lines(k + 1, n))
    if cost == nil or m < cost then best, cost = k, m end
  end
  return best
end

local function counsel_column(groups, a, b, out)
  for i = a, b do
    for j, l in ipairs(groups[i]) do
      out[#out + 1] = p(xe.inl(l), { before = (i > a and j == 1) and GAP or 0 })
    end
  end
  return out
end

local function counsel(meta)
  local groups = {}
  for _, g in ipairs(meta.counsel) do groups[#groups + 1] = g end
  local k = counsel_split(groups)
  local left = counsel_column(groups, 1, k, {})
  left[#left + 1] = p(xe.inl(meta.counsel_role, { i = true }), { before = GAP })
  local right = counsel_column(groups, k + 1, #groups, {})
  local half = (TEXTW - GUTTER) // 2
  return tbl({ { half, left }, { GUTTER, {} }, { TEXTW - GUTTER - half, right } })
end

local function caption(meta)
  local left = {}
  local function add(x, o)
    o = o or {}
    o.right = CAP_PAD
    left[#left + 1] = p(x, o)
  end
  for k, side in ipairs(meta.caption) do
    if k > 1 then add(xe.runs("v."), { before = GAP, after = GAP }) end
    for _, n in ipairs(side.names) do add(xe.inl(n)) end
    -- the last designation keeps the caption's bottom padding (typst: pad(bottom: gap-half))
    add(xe.inl(side.designation), { before = GAP, left = DESIG, after = k == #meta.caption and GAP or 0 })
  end
  local num = plain(meta.case_number)
  -- an empty case number leaves a blank for the clerk
  local right = {
    p(xe.runs("Case No. " .. (num ~= "" and num or string.rep("_", 14))), { left = CAP_PAD }),
    p(xe.runs(pandoc.text.upper(plain(meta.title)), { b = true }), { before = BODY, left = CAP_PAD }),
  }
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return tbl({ { CAP_LEFT, left, rule }, { TEXTW - CAP_LEFT, right } })
end

local function cover(meta)
  local out = { counsel(meta) }
  local lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF MONTANA",
    pandoc.text.upper(plain(meta.division)) }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", before = i == 1 and BODY or 0 })
  end
  -- typst: the caption stands half a double line below the court title
  out[#out + 1] = p("", { line = GAP })
  out[#out + 1] = caption(meta)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (L.R. 1.5(b), 11.1): the date beside the signature column; one row that never splits
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = {}
  if sig.firm then right[#right + 1] = p(xe.inl(pandoc.text.upper(plain(sig.firm)), { b = true }), { before = BODY }) end
  right[#right + 1] = p(xe.runs("/s/ " .. plain(sig.signer)), { before = BODY })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("DATED: " .. plain(meta.date)), { before = BODY }) }
  return tbl({ { SIG_LEFT, left }, { TEXTW - SIG_LEFT, right } })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, kept with the text: level 1 centered bold capitals, level 2 bold at the margin, level 3
-- bold italic. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  local lvl = math.min(b.level, 3)
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

local TABS = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>'

-- A body paragraph at the double pitch, first line indented: unnumbered, or the label, a tab to the end of its
-- half-inch box (typst: box(width: para-indent)), the text.
local function body_par(label, body, o)
  o = o or {}
  if label == nil then return p(body, { line = BODY, first = INDENT, keep = o.keep, brk = o.brk }) end
  return p(xe.runs(label .. "\t") .. body, { line = BODY, first = INDENT, keep = o.keep, brk = o.brk, tabs = TABS })
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- A paragraph that carries a footnote, written by pandoc (Body Text Note: the same layout as body_par).
local function note_par(label, inlines)
  local c = pandoc.Inlines({})
  if label then
    c:insert(pandoc.Str(label))
    c:insert(pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
  end
  c:extend(inlines)
  return pandoc.Div({ pandoc.Para(c):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = "Body Text Note" })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A space before a footnote mark is not printed (typst sets the mark against the word).
local function tight_notes(inl)
  for i = #inl - 1, 1, -1 do
    if inl[i].t == "Space" and inl[i + 1].t == "Note" then inl:remove(i) end
  end
  return inl
end

-- A doubled sign stays with its number ("§§ 2201"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- The paragraph's text without a leading "~ " marker, and whether it had one.
local function unmark(c)
  if c[1] and c[1].t == "Str" and c[1].text == "~" then
    local rest = pandoc.Inlines({ table.unpack(c, 2) })
    if rest[1] and rest[1].t == "Space" then rest:remove(1) end
    return rest, true
  end
  return c, false
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "division", "counsel", "counsel_role", "caption", "title", "signature", "date" }) do
    if meta[k] == nil then error("mtd-complaint: missing required metadata field `" .. k .. "`", 0) end
  end
  if meta.jury_demand == true and not plain(meta.title):upper():find("JURY TRIAL", 1, true) then
    error("mtd-complaint: L.R. 38.1: the title must indicate the jury demand", 0)
  end
  if #meta.caption < 2 then error("mtd-complaint: FRCP 10(a): the title must name all parties on both sides", 0) end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = tight_notes })
  local out = cover(meta)
  -- page two opens with the lead-in (typst: pagebreak() after the cover)
  local brk = true
  if meta.lead_in then
    local lead = pandoc.read(plain(meta.lead_in), "markdown+smart").blocks[1]
    out[#out + 1] = body_par(nil, xe.inl(lead.content), { brk = true })
    brk = false
  end
  local n = 0
  local blocks = doc.blocks
  for k, b in ipairs(blocks) do
    -- the last block stays on one page with the signature block (typst: one unbreakable block)
    local keep = k == #blocks
    local first = brk
    brk = false
    if b.t == "Header" then
      local h = heading(b)
      if first then h = h:gsub("<w:keepNext/>", "<w:keepNext/>" .. xe.BREAK, 1) end
      out[#out + 1] = h
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local lab = string.char(64 + i) .. "."
        if has_note(item[1]) then
          out[#out + 1] = note_par(lab, item[1].content)
        else
          out[#out + 1] = body_par(lab, xe.inl(item[1].content), { keep = keep })
        end
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local c, unnumbered = unmark(b.content)
      local lab = nil
      if not unnumbered then
        n = n + 1
        lab = n .. "."
      end
      if has_note(b) then
        out[#out + 1] = note_par(lab, c)
      else
        out[#out + 1] = body_par(lab, xe.inl(c), { keep = keep, brk = first })
      end
    else
      error("mtd-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
