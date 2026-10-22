-- mdb-adversary-complaint.lua (docx engine): the Maryland bankruptcy adversary complaint as Word paragraphs, so that
-- it reads and breaks as typst/mdb-adversary-complaint.typ does: the court lines and division, the caption (one
-- table row per line: the party text, the ")" column, and the case number, chapter and adversary number centered
-- on the party lines), the title in capitals between two rules, the unnumbered lead-in, the allegations numbered
-- 1., 2., ... (Fed. R. Civ. P. 10(b), via Fed. R. Bankr. P. 7010; not the WHEREFORE lead-in, quotations or the
-- prayer), headings, block quotations, the prayer lettered A., B., ..., and the signature block. Everything printed
-- comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 280 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. pandoc reads the sample
-- without fancy lists (reference.xml pandoc-from), so a quotation's "I. ..." stays text, as typst reads it.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 280            -- typst pitch-double, pitch-single
local GAP = 240                          -- typst gap-half, 12 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_CLOSE = 5184, 576    -- typst caption-left - caption-close (3.6 in), caption-close (0.4 in)
local CAP_INSET = 360                    -- typst caption-inset, 0.25 in
local SIG = 4320                         -- typst sig-indent, 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep }.
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

local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="%d" w:space="0" w:color="000000"/></w:tcBorders>'

-- A borderless table of rows of exact height: rows = { { h = twips, cells = { { w, xml, rule } ... } } }; a cell
-- with `rule` (eighths of a point) has a bottom border, and a row with one cell spans every column.
local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for _, c in ipairs(row.cells) do
      local span = #row.cells == 1 and #widths > 1 and ('<w:gridSpan w:val="' .. #widths .. '"/>') or ""
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. span ..
        (c[3] and RULE:format(c[3]) or "") .. '</w:tcPr>' .. (c[2] or p("", { line = row.h })) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. row.h .. '" w:hRule="exact"/></w:trPr>' ..
      table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- A rule: a full-width table row of `h` twips whose foot is the rule (typst: rule-block).
local function rule(h, sz)
  return tbl({ TEXTW }, { { h = h, cells = { { TEXTW, nil, sz } } } })
end

-- ---------------------------------------------------------------------------
-- Cover: court lines, division, caption, title between rules
-- ---------------------------------------------------------------------------

-- The caption's party lines: { text, indented, ruled } per row (typst: caption-rows).
local function caption_rows(cap)
  local rows = {}
  if cap.in_re then
    rows[#rows + 1] = { "In re:" }
    for _, n in ipairs(cap.in_re.names) do rows[#rows + 1] = { n } end
    rows[#rows + 1] = { cap.in_re.designation, true }
    rows[#rows + 1] = { "", false, true }
  end
  for k, party in ipairs(cap.parties) do
    if k > 1 then rows[#rows + 1] = { "v.", true } end
    for _, n in ipairs(party.names) do rows[#rows + 1] = { n } end
    rows[#rows + 1] = { party.designation, true }
  end
  return rows
end

-- The right column (typst: caption-right): a blank line between the case number, chapter and adversary number.
local function caption_right(meta)
  local r = { "Case No. " .. plain(meta.case_number), "" }
  if plain(meta.chapter) ~= "" then r[#r + 1] = "Chapter " .. plain(meta.chapter) end
  r[#r + 1] = ""
  local adv = plain(meta.adv_number)
  r[#r + 1] = "Adv. Pro. No. " .. (adv ~= "" and adv or string.rep("_", 11))
  return r
end

local function caption(meta)
  local rows = caption_rows(meta.caption)
  local right = caption_right(meta)
  local first = math.max(0, (#rows - #right) // 2)
  local out = {}
  for i, r in ipairs(rows) do
    local k = i - 1 - first
    local rt = (k >= 0 and k < #right) and right[k + 1] or ""
    out[#out + 1] = { h = SINGLE, cells = {
      { CAP_LEFT, (not r[3]) and p(xe.inl(r[1]), { left = r[2] and INDENT or 0 }) or nil, r[3] and 4 or nil },
      { CAP_CLOSE, p(xe.runs(")")) },
      { TEXTW - CAP_LEFT - CAP_CLOSE, p(xe.inl(rt), { left = CAP_INSET }) },
    } }
  end
  return tbl({ CAP_LEFT, CAP_CLOSE, TEXTW - CAP_LEFT - CAP_CLOSE }, out)
end

local function cover(meta)
  local out = {}
  for _, t in ipairs(meta.court) do out[#out + 1] = p(xe.inl(t, { b = true }), { jc = "center" }) end
  if plain(meta.division) ~= "" then out[#out + 1] = p(xe.inl(meta.division, { b = true }), { jc = "center" }) end
  -- typst: the caption block stands a double line below the court lines
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = caption(meta)
  out[#out + 1] = rule(GAP, 6)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.title)), { b = true }), { jc = "center", before = GAP, line = BODY })
  out[#out + 1] = rule(GAP, 6)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: the date, then the firm and signer at the signature column; kept together
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local rows = { { xe.runs("Dated: ") .. xe.inl(meta.date), 0, BODY }, { xe.runs("Respectfully submitted,"), SIG, GAP } }
  for i, f in ipairs(sig.firm) do rows[#rows + 1] = { xe.inl(f), SIG, i == 1 and GAP or 0 } end
  rows[#rows + 1] = { xe.inl(sig.signer), SIG, GAP }
  for _, l in ipairs(sig.lines) do rows[#rows + 1] = { xe.inl(l), SIG, 0 } end
  local out = {}
  for i, r in ipairs(rows) do out[#out + 1] = p(r[1], { left = r[2], before = r[3], keep = i < #rows }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, bold, kept with the text: level 1 centered underlined capitals, level 2 centered,
-- level 3 bold italic at the margin. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  if b.level == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(b.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3, u = lvl == 1 }))
end

-- A body paragraph at the double pitch, first line indented: unnumbered, or the number, a tab to the end of its
-- half-inch box (typst: box(width: para-indent)), the text.
local function body_par(label, body, before)
  if label == nil then return p(body, { line = BODY, first = INDENT, before = before }) end
  return p(xe.runs(label .. "\t") .. body, { line = BODY, first = INDENT,
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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
  local out = cover(meta)
  if plain(meta.lead_in) ~= "" then
    local lead = pandoc.read(plain(meta.lead_in), "markdown+smart").blocks[1]
    out[#out + 1] = body_par(nil, xe.inl(lead.content), GAP)
  end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = GAP, after = GAP, left = QUOTE, right = QUOTE })
      end
    elseif b.t == "OrderedList" then
      -- the prayer, lettered: the letter at the item indent in a box of its width, the text hanging after it
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs(string.char(64 + i) .. ".\t") .. xe.inl(item[1].content),
          { line = BODY, before = GAP, left = 2 * INDENT, hanging = INDENT })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):match("^WHEREFORE") then
        out[#out + 1] = body_par(nil, xe.inl(b.content))
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", xe.inl(b.content))
      end
    else
      error("mdb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
