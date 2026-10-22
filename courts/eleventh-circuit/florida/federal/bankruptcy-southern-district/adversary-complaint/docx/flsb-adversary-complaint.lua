-- flsb-adversary-complaint.lua (docx engine): the S.D. Fla. Bankruptcy adversary complaint as Word paragraphs, so
-- that it reads and breaks as typst/flsb-adversary-complaint.typ does: the court title and division, the caption
-- (Form 416 / L.R. 9004-1(e)(2)) as a borderless two-row table, the title, the allegations numbered from 1 after the
-- first heading (Civil Rule 10(b), via Rule 7010; the opening paragraph, the WHEREFORE clause and a "Dated" line are
-- not numbered), headings, block quotations, the lettered WHEREFORE items, and the signature block. Everything
-- printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. pandoc reads the sample
-- without fancy lists (reference.xml pandoc-from), so "(a) ..." stays a paragraph, as typst reads it.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local GAP = 240                          -- typst gap-half, 12 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288   -- typst caption-left 3.4 in, caption-gutter 0.2 in
local SIG_LEFT, SIG_GUTTER = 3744, 288   -- typst sig-left 2.6 in, sig-gutter 0.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single lines, the first with space above it.
local function lines(list, before, out)
  for i, l in ipairs(list) do out[#out + 1] = p(xe.inl(l), { before = i == 1 and before or 0 }) end
  return out
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless table: widths, then rows of cells (each a list of paragraphs); rows never split.
local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row) do
      if #c == 0 then c = { p("") } end
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. table.concat(c) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court, division, caption (Form 416 / L.R. 9004-1(e)(2)), title
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local function title(text, before, after)
    out[#out + 1] = p(xe.runs(text, { b = true }), { jc = "center", before = before, after = after })
  end
  title("UNITED STATES BANKRUPTCY COURT")
  title(plain(meta.district))
  -- the division is printed as a blank line when the sample does not name one (L.R. 9004-1(e)(2))
  local division = meta.division and plain(meta.division):upper() or "___________"
  title(division .. " DIVISION", BODY)

  -- the caption: the debtor with the case number and chapter; the parties with the adversary number at the first
  -- party's line (typst: a two-row grid, half a double line between the rows)
  local rule = string.rep("_", 36) .. "/"
  local debtor = { "In re:" }
  for _, n in ipairs(meta.debtor.names) do debtor[#debtor + 1] = n end
  debtor[#debtor + 1] = meta.debtor.designation
  local parties = {}
  for k, party in ipairs(meta.parties) do
    if k > 1 then parties[#parties + 1] = "vs." end
    for _, n in ipairs(party.names) do parties[#parties + 1] = n end
    parties[#parties + 1] = party.designation
  end
  -- typst: the caption block stands a double line below the division
  local row1 = lines({ rule }, GAP, lines(debtor, BODY, {}))
  local row2 = lines({ rule }, GAP, lines(parties, GAP, {}))
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { row1, { p("", { before = BODY }) }, lines({ "CASE NO.: " .. plain(meta.case_number), "CHAPTER " .. plain(meta.chapter) }, BODY, {}) },
    { row2, { p("", { before = GAP }) }, lines({ "ADV. CASE NO.: " .. plain(meta.adv_number) }, GAP, {}) },
  })
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = BODY, after = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" beside the firm (typst: signature-block)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = BODY }) }
  local right = { p(xe.runs("Respectfully submitted,"), { before = BODY }) }
  lines(sig.firm, GAP, right)
  local by = { "By: /s/ " .. plain(sig.signer), sig.signer }
  for _, l in ipairs(sig.lines) do by[#by + 1] = l end
  lines(by, GAP, right)
  return tbl({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER }, { { left, { p("", { before = BODY }) }, right } })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings (single-spaced): 12 pt, 12 pt above and below, kept with the text after them; level 1 centered bold
-- capitals, level 2 centered bold, level 3 bold italic. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  if b.level == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local runs = xe.inl(content, { b = true, i = b.level >= 3 })
  -- the Heading 1 style's capitals off: the text is already in capitals
  runs = runs:gsub("<w:rPr>(.-)</w:rPr>", function(x)
    local at = x:find("<w:sz", 1, true) or x:find("<w:u ", 1, true) or x:find("<w:bdr", 1, true) or (#x + 1)
    return "<w:rPr>" .. x:sub(1, at - 1) .. '<w:caps w:val="0"/>' .. x:sub(at) .. "</w:rPr>"
  end)
  return xe.para({ xe.style("Heading" .. math.min(b.level, 3)), xe.KEEP, xe.spacing(GAP, GAP, SINGLE), xe.ind(0, nil, 0),
    xe.jc(b.level <= 2 and "center" or "left") }, runs)
end

-- A body paragraph at the double pitch, first-line indented; a numbered one: the number, a tab to 1 in (typst: the
-- number in a box of the paragraph indent).
local function body_par(label, body, keep)
  return p((label and xe.runs(label .. "\t") or "") .. body, { line = BODY, first = INDENT, keep = keep })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
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
  local seen, n = false, 0
  local blocks = doc.blocks
  for k, b in ipairs(blocks) do
    -- the last block stays on one page with the signature block (typst: one unbreakable block)
    local last = k == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
      seen = true
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = GAP, after = GAP, left = QUOTE, right = QUOTE, keep = last })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local s = pandoc.utils.stringify(b)
      if s:match("^%([a-z]+%)%s") then
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, left = INDENT, keep = last })
      elseif seen and not s:match("^WHEREFORE") and not s:match("^Dated") then
        n = n + 1
        out[#out + 1] = body_par(n .. ".", xe.inl(b.content), last)
      else
        out[#out + 1] = body_par(nil, xe.inl(b.content), last)
      end
    else
      error("flsb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
