-- nceb-adversary-complaint.lua (docx engine): the E.D.N.C. bankruptcy adversary complaint as Word paragraphs, so that
-- it reads and breaks as typst/nceb-adversary-complaint.typ does: the court lines and division, the caption (the party
-- column ruled on its right and bottom, the case numbers beside it), the title, the allegations numbered 1., 2., ...
-- (FRCP 10(b); not the lead-in before the first heading, the lettered introduction items, a "(" continuation, a "["
-- note, the prayer's lead-in, quotations, tables or the prayer list), headings, ruled tables, block quotations, the
-- prayer list and the signature block. Everything printed comes from the sample's frontmatter and body: no case text
-- lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template (the larger of the one's below and the next one's above), and the break
-- rules of typst on every run. pandoc reads the sample without fancy lists (reference.xml pandoc-from), so "A. ..."
-- and a quotation's "a) ..." stay paragraphs, as typst reads them.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local GAP = 240                          -- typst gap, 12 pt
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4608                    -- typst caption-left, 3.2 in
local CAP_RIGHT_IND = 432                -- typst caption-gutter + caption-inset, 0.3 in
local RULE_R, RULE_B = 200, 145          -- typst rule-pad-right 10 pt, rule-pad-bottom 8 pt less the 0.75 pt rule
                                         -- LibreOffice adds to the row (measured)
local ITEM = 720                         -- typst item-indent, 0.5 in
local QUOTE = 1440                       -- typst quote-inset, 1 in
local SIG = 4320                         -- typst sig-indent, 3 in
local CELL_X, CELL_Y = 120, 60           -- typst cell-x 6 pt, cell-y 3 pt
local CELL_B = 50                        -- cell-y less the 0.5 pt row border LibreOffice adds to each row (measured)

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, jc, keep, page }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

local function tbl(widths, rows, borders)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(row) .. '</w:tr>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. (borders or "") .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local function tc(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Caption: court, division, the parties (ruled right and bottom) beside the case numbers, title
-- ---------------------------------------------------------------------------

local function caption(meta, out)
  for _, l in ipairs(meta.court) do out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }), { jc = "center" }) end
  -- typst: the caption block stands 18 pt below the division
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.division)), { b = true }), { jc = "center", after = 360 })
  local left = {}
  local function party(pt)
    for _, n in ipairs(pt.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(pt.designation), { jc = "right", after = GAP })
  end
  for _, pt in ipairs(meta.caption.in_re) do party(pt) end
  for _, pt in ipairs(meta.caption.parties) do party(pt) end
  local right = { p("", { line = BODY }), p(xe.runs("Case No. " .. plain(meta.case_number))),
    p(xe.runs("Chapter " .. plain(meta.chapter))) }
  if meta.adversary_number then
    right[#right + 1] = p(xe.runs("Adversary Proceeding No. " .. plain(meta.adversary_number)), { before = SINGLE })
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. RULE_B .. '" w:type="dxa"/><w:right w:w="' .. RULE_R .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, { {
    tc(CAP_LEFT, rule, table.concat(left)),
    tc(TEXTW - CAP_LEFT, '<w:tcMar><w:left w:w="' .. CAP_RIGHT_IND .. '" w:type="dxa"/></w:tcMar>', table.concat(right)),
  } })
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.title)), { b = true }), { jc = "center", before = 360, after = GAP })
end

-- ---------------------------------------------------------------------------
-- Tables (typst: pipe-table): ruled, single-spaced, the full width; each column's share its longest word (x3) plus
-- its longest cell (capped at 60 characters).
-- ---------------------------------------------------------------------------

-- characters as typst counts them: without the break marks this filter adds (zero-width space, word joiner)
local function ulen(s)
  s = s:gsub("\u{200B}", ""):gsub("\u{2060}", "")
  return utf8.len(s) or #s
end

local function pipe_table(t)
  local rows = {}
  local function add(rs)
    for _, r in ipairs(rs) do
      local row = {}
      for _, c in ipairs(r.cells) do row[#row + 1] = c.contents end
      rows[#rows + 1] = row
    end
  end
  add(t.head.rows)
  for _, b in ipairs(t.bodies) do add(b.head); add(b.body) end
  -- an all-empty header row is not a row
  if #rows > 0 then
    local empty = true
    for _, c in ipairs(rows[1]) do if plain(c) ~= "" then empty = false end end
    if empty then table.remove(rows, 1) end
  end
  local n = #t.colspecs
  local weights, total = {}, 0
  for i = 1, n do
    local word, text = 1, 1
    for _, r in ipairs(rows) do
      local s = plain(r[i] or {})
      for w in s:gmatch("%S+") do word = math.max(word, ulen(w)) end
      text = math.max(text, math.min(ulen(s), 60))
    end
    weights[i] = 3 * word + text
    total = total + weights[i]
  end
  local widths = {}
  for i = 1, n do widths[i] = math.floor(TEXTW * weights[i] / total + 0.5) end
  local B = '<w:%s w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  local borders = '<w:tblBorders>' .. B:format("top") .. B:format("left") .. B:format("bottom") .. B:format("right") ..
    B:format("insideH") .. B:format("insideV") .. '</w:tblBorders>'
  local mar = '<w:tcMar><w:top w:w="' .. CELL_Y .. '" w:type="dxa"/><w:left w:w="' .. CELL_X .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. CELL_B .. '" w:type="dxa"/><w:right w:w="' .. CELL_X .. '" w:type="dxa"/></w:tcMar>'
  local trs = {}
  for _, r in ipairs(rows) do
    local tcs = {}
    for i = 1, n do
      local blocks = r[i] or {}
      local inl = (#blocks > 0 and blocks[1].content) or pandoc.Inlines({})
      tcs[#tcs + 1] = tc(widths[i], mar, p(xe.inl(inl)))
    end
    trs[#trs + 1] = tcs
  end
  return tbl(widths, trs, borders)
end

-- ---------------------------------------------------------------------------
-- Signature block: kept together (typst: an unbreakable block)
-- ---------------------------------------------------------------------------

local function signature(sig, out)
  local rows = {}
  if sig.lead then rows[#rows + 1] = { xe.inl(sig.lead), 0, GAP } end
  if sig.firm then rows[#rows + 1] = { xe.runs(pandoc.text.upper(plain(sig.firm))), SIG, GAP } end
  for _, s in ipairs(sig.signers) do
    rows[#rows + 1] = { xe.inl(s.sign), SIG, GAP }
    for _, l in ipairs(s.lines) do rows[#rows + 1] = { xe.inl(l), SIG, 0 } end
  end
  if sig.role then rows[#rows + 1] = { xe.inl(sig.role, { i = true }), SIG, GAP } end
  for i, r in ipairs(rows) do out[#out + 1] = p(r[1], { left = r[2], before = r[3], keep = i < #rows }) end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings, single-spaced and centered, kept with the text: level 1 bold capitals (24 pt above, 12 below), level 2
-- bold (6 and 6), level 3 plain (6 and 12).
local SPACE = { { 2 * GAP, GAP }, { GAP // 2, GAP // 2 }, { GAP // 2, GAP } }
local function heading(b)
  local lvl = math.min(b.level, 3)
  local content = b.content
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(SPACE[lvl][1], SPACE[lvl][2], SINGLE), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(content, { b = lvl <= 2 }))
end

local function body_par(body, left)
  return p(body, { line = BODY, left = left })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 151"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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
  local out = {}
  caption(meta, out)
  local blocks = doc.blocks
  local first_h = #blocks + 1
  for i, b in ipairs(blocks) do
    if b.t == "Header" then first_h = i break end
  end
  local n = 0
  for i, b in ipairs(blocks) do
    local next = blocks[i + 1]
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    elseif b.t == "Table" then
      -- typst: 6 pt above the table, 12 pt below it (the next block's own space if larger)
      out[#out + 1] = p("", { line = GAP // 2 })
      out[#out + 1] = pipe_table(b)
      local nb = 0
      if next and next.t == "Header" then nb = SPACE[math.min(next.level, 3)][1] end
      if next and next.t == "BlockQuote" then nb = GAP // 2 end
      if GAP > nb then out[#out + 1] = p("", { line = GAP - nb }) end
    elseif b.t == "BlockQuote" then
      local qs = b.content
      for k, q in ipairs(qs) do
        out[#out + 1] = p(xe.inl(q.content), { before = k == 1 and GAP // 2 or GAP, after = k == #qs and GAP or 0,
          left = QUOTE, right = QUOTE })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local s = plain(b)
      if (s:match(":$") and next and next.t == "OrderedList") or s:match("^%(") or i < first_h then
        out[#out + 1] = body_par(xe.inl(b.content))
      elseif s:match("^%[") then
        out[#out + 1] = body_par(xe.inl(b.content, { i = true }))
      elseif s:match("^[A-Z]%. ") then
        out[#out + 1] = body_par(xe.inl(b.content), ITEM)
      else
        n = n + 1
        out[#out + 1] = body_par(xe.runs(n .. ".\u{2003}") .. xe.inl(b.content))
      end
    else
      error("nceb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  signature(meta.signature, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
