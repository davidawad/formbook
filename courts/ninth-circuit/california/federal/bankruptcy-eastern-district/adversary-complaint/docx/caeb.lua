-- Adversary complaint, U.S. Bankruptcy Court, E.D. California (caeb), DOCX engine (docs/DOCX.md): what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/caeb-adversary-complaint.typ does: the
-- counsel block clear of the clerk's stamp space (LBR 9004-1(b), 9004-2(b)(3)), the court title, the caption (a
-- table: the debtors above the party box, ruled right and below; case, chapter and adversary numbers, the title and
-- the jury demand at right; FRBP 9004(b), LBR 7038-1(b)), then the body from page 2: the allegations numbered here
-- (FRCP 10(b), applied by FRBP 7010), a paragraph marked "^" unnumbered, headings, (a), (b) list items, quotations,
-- and the signature blocks kept together with the last paragraph or item. The line numbers, the page total, the
-- pleading rules and the page number come from docx/reference.xml. Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 a numbered line, 240 a single line), the spaces between
-- blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 240            -- typst pitch, pitch-single
local HALF = 240                         -- typst half-gap 12 pt
local DROP = 192                         -- typst drop 9.6 pt: single lines on the line numbers' baselines
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_TAB = 1440                  -- typst para-indent + number-box: the text of an allegation or list item
local TEXTW = 8640                       -- typst text-width, 6 in
local COUNSEL_RIGHT = 2880               -- typst counsel-width 4 in: the counsel lines end 2 in before the margin
local COUNSEL_LINES = 7                  -- typst counsel-lines
local CAP_LEFT, CAP_GUTTER = 4464, 288   -- typst caption-left 3.1 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local DEBTOR_PAD = 200                   -- typst debtor-pad 10 pt
local CAP_PAD = 145                      -- typst caption-pad 8 pt, less the 0.75 pt rule LibreOffice adds to the row
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local SIG_LEFT = 3744                    -- typst sig-left 2.6 in
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'       -- 0.75 pt
local CANT_SPLIT = "<w:trPr><w:cantSplit/></w:trPr>"

local function text(v) return pandoc.utils.stringify(v) end

-- A metadata value as a list (a YAML list or one value).
local function list(v)
  if v == nil then return {} end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then return v end
  return { v }
end

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- typst grid-rows: the numbered lines a block of single lines fills (DROP, n lines and `gaps` half lines).
local function grid_rows(n, gaps)
  return math.ceil((DROP + n * SINGLE + gaps * HALF) / BODY)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, pagebreak, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.pagebreak then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table without borders of its own or cell margins; rows = { { cells = { { pr, body } } } }, no row split.
local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row.cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. CANT_SPLIT .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- The last paragraph of a list of paragraphs gets `after` twips below it.
local function pad_last(ps, after)
  ps[#ps] = ps[#ps]:gsub('w:after="0"', 'w:after="' .. after .. '"', 1)
  return ps
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  -- counsel: single lines from line 1's baseline, filling at least lines 1-7; more lines push the court title down
  -- by whole numbered lines, half a line kept below the last (typst counsel-block)
  local counsel = list(meta.counsel)
  for j, l in ipairs(counsel) do
    out[#out + 1] = p(xe.inl(l), { before = j == 1 and DROP or 0, right = COUNSEL_RIGHT })
  end
  local rows = math.max(COUNSEL_LINES, grid_rows(#counsel, 1))
  for i, l in ipairs(list(meta.court)) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }),
      { line = BODY, jc = "center", keep = true, before = i == 1 and (rows * BODY - DROP - #counsel * SINGLE) or 0 })
  end
  -- The caption stands a numbered line and DROP below the court title: Word has no space before a table, so the
  -- first paragraph of each cell carries it. The right column spans both rows (the debtors, the party box).
  local top = BODY + DROP
  local debtors = {}
  for j, l in ipairs(list(meta.caption.debtors)) do debtors[#debtors + 1] = p(xe.inl(l), { before = j == 1 and top or 0 }) end
  local parties = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then parties[#parties + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(list(party.names)) do parties[#parties + 1] = p(xe.inl(n)) end
    parties[#parties + 1] = p(xe.inl(party.designation))
  end
  local function r(body, before) return p(body, { before = before or 0, left = RIGHT_INSET }) end
  local right = {}
  for j, l in ipairs(list(meta.caption["case-lines"])) do right[#right + 1] = r(xe.inl(l), j == 1 and top or 0) end
  for j, l in ipairs(list(meta.caption["chapter-lines"])) do right[#right + 1] = r(xe.inl(l), j == 1 and HALF or 0) end
  right[#right + 1] = r(xe.runs("Adv. Proc. No.: " .. text(meta.caption.adversary)), HALF)
  if meta.caption.dcn then right[#right + 1] = r(xe.runs("DCN: " .. text(meta.caption.dcn)), HALF) end
  right[#right + 1] = r(xe.inl(upper(meta.brief_title), { b = true }), HALF)
  if meta.jury_demand then right[#right + 1] = r(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), HALF) end
  local mar = '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { cells = {
      { pr = mar, body = pad_last(debtors, DEBTOR_PAD) },
      { pr = '<w:vMerge w:val="restart"/>', body = { p("", { before = top }) } },
      { pr = '<w:vMerge w:val="restart"/>', body = right },
    } },
    { cells = {
      { pr = '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' .. mar,
        body = pad_last(parties, CAP_PAD) },
      { pr = '<w:vMerge/>', body = { p("") } },
      { pr = '<w:vMerge/>', body = { p("") } },
    } },
  })
end

-- ---------------------------------------------------------------------------
-- Signature blocks: a numbered line above each; the date left; "Respectfully submitted,", the firm and the signer
-- right, single lines from a line number's baseline, filling whole numbered lines. All of them are one table row
-- that cannot split (typst: one unbreakable block): each "Dated:" line stands level with its block's first line.
-- ---------------------------------------------------------------------------

local function signatures(meta, out)
  local left, right = {}, {}
  local since = 0                        -- twips from the end of the left column's last line to the next block
  local pad = 0                          -- twips from the end of the right column's last line to the next block
  -- (a space below one paragraph and above the next collapse to the larger, so the whole gap goes above)
  for _, sig in ipairs(list(meta.signature)) do
    local firm, lines = list(sig.firm), list(sig.lines)
    local rows = grid_rows(1 + #firm + 2 + #lines, 2)
    left[#left + 1] = p(xe.runs("Dated: " .. text(meta.date)), { before = since + BODY + DROP })
    since = rows * BODY - DROP - SINGLE
    right[#right + 1] = p(xe.runs("Respectfully submitted,"), { before = pad + BODY + DROP })
    for j, l in ipairs(firm) do right[#right + 1] = p(xe.inl(l), { before = j == 1 and HALF or 0 }) end
    right[#right + 1] = p(xe.runs("By: /s/ " .. text(sig.signer)), { before = HALF })
    right[#right + 1] = p(xe.runs(text(sig.signer)))
    for _, l in ipairs(lines) do right[#right + 1] = p(xe.inl(l)) end
    pad = rows * BODY - DROP - (3 + #firm + #lines) * SINGLE - 2 * HALF
  end
  pad_last(right, pad)
  out[#out + 1] = tbl({ SIG_LEFT, CAP_GUTTER, TEXTW - SIG_LEFT - CAP_GUTTER }, { { cells = {
    { body = left }, { body = { p("", { before = BODY + DROP }) } }, { body = right },
  } } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el)
  local lvl = el.level
  local content = lvl == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. math.min(lvl, 5)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl >= 3 }))
end

-- A paragraph the sample marks with a leading "^" (an unnumbered lead-in such as "WHEREFORE"), without the mark.
local function unmarked(b)
  local c = b.content
  if c[1] and c[1].t == "Str" and c[1].text:sub(1, 1) == "^" then
    local rest = pandoc.Inlines({})
    if #c[1].text > 1 then rest:insert(pandoc.Str(c[1].text:sub(2))) end
    for k = 2, #c do if not (k == 2 and #c[1].text == 1 and c[k].t == "Space") then rest:insert(c[k]) end end
    return rest
  end
end

-- The body blocks; the last paragraph or list item is kept with the signature blocks (typst: one unbreakable block).
local function body(blocks, out, first)
  local n = 0
  local function o(t) t.pagebreak = first; first = false; return t end
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      local lead = unmarked(b)
      if lead then
        out[#out + 1] = p(xe.inl(lead), o({ line = BODY, first = INDENT, keep = last }))
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          o({ line = BODY, first = INDENT, tab = NUMBER_TAB, keep = last }))
      end
    elseif b.t == "BlockQuote" then
      -- LBR 9004-2(b)(1): single spaced, indented on both sides
      for k, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), o({ before = k == 1 and DROP or 0, left = INDENT, right = INDENT,
          keep = last }))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- (a), (b), ... (typst enum "(a)"), from the markdown start number: the label half an inch in, the text a box
      -- after it
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        for m, ib in ipairs(item) do
          local lab = m == 1 and ((b.t == "OrderedList" and ("(" .. string.char(96 + start + j - 1) .. ")") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content),
            o({ line = BODY, left = NUMBER_TAB, hanging = NUMBER_TAB - INDENT, keep = last and j == #b.content }))
        end
      end
    else
      error("caeb: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 9-406"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local t = a.text
      if #t >= 4 and t:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
        inlines[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return inlines
end

function Pandoc(doc)
  for _, k in ipairs({ "counsel", "court", "caption", "brief_title" }) do
    if doc.meta[k] == nil then error("caeb: missing required metadata field `" .. k .. "`", 0) end
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  -- the body starts on page 2 (page 1 ends at the caption)
  local first = true
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT, pagebreak = true })
    first = false
  end
  body(doc.blocks, out, first)
  if meta.signature then signatures(meta, out) end
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
