-- nvb-motion-brief.lua (docx engine, D. Nev. bankruptcy court, motion with points and authorities): the motion as Word
-- paragraphs, so that it reads and breaks as typst/nvb-motion-brief.typ does: the cover (counsel block from the third
-- numbered line, court title, caption ruled at the right and foot of the party column, the title and any hearing date
-- and time at the right), the body paragraphs (pandoc paragraphs in Body Text, so their footnotes are pandoc's),
-- headings, lists, block quotations, the signature block at the [signature] marker, a heading after it on a new page
-- (the certificate of service), and the [sig] lines in the signature column. Every case word comes from the
-- sample's frontmatter and body, never from this file. Font, size, pitches, margins, the line numbers, the page number
-- and the footnote style are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body on the numbered lines, 240 a
-- single line), the spaces between blocks those of the typst template, and the break rules of typst on every run.
-- A single-spaced block (counsel, caption, signature: a table row; a quotation: the space after it) is rounded up to
-- whole numbered lines, as typst's grid-row and quote-item do; its lines are counted first fit with the face's
-- advances (docx/lib/tnr.lua), where typst measures them.

local xe = require("docx.xengine")
local dir = PANDOC_SCRIPT_FILE:match("^(.*)/[^/]*$") or "."
local tnr = dofile(dir .. "/lib/tnr.lua")

local SIZE = 12                          -- typst type-size
local BODY, SINGLE = 480, 240            -- typst pitch 24 pt, pitch-single 12 pt
local TEXTW = 8640                       -- 6 in: 8.5 in less the 1.5 in and 1 in margins
local TITLE_LINES = 2                    -- typst title-page-lines
local COUNSEL_GUT = 360                  -- typst counsel-gutter 0.25 in
local CAP_LEFT = 4608                    -- typst caption-left 3.2 in
local BOX_PAD, RULE_PAD = 160, 160       -- typst box-pad, rule-pad 8 pt
local CAP_GUT = 288                      -- typst caption-gutter 0.2 in
local CAP_GAP = 240                      -- typst caption-gap 12 pt
local INDENT = 720                       -- typst para-indent 0.5 in
local LIST_LEFT, LABEL_BOX = 1440, 360   -- typst list-left 1 in, label-box 0.25 in
local QUOTE, QGAP = 720, 240             -- typst quote-inset 0.5 in, quote-gap 12 pt
local SIG_COL, SIG_GUT = 4608, 288       -- typst sig-col 3.2 in (caption-left), sig-gutter 0.2 in
local SIGNER_GAP = 240                   -- typst caption-gap 12 pt between signers
-- LibreOffice draws a cell's foot rule below the row height it is given (0.75 pt, 15 twips): the row of a ruled cell
-- is set that much lower, so the next line stays on the numbered lines.
local RULE = 15

local stringify = pandoc.utils.stringify

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("nvb-motion-brief.lua: missing required metadata field `" .. key .. "`") end
  return v
end

local function list(m)
  local out = {}
  for _, v in ipairs(m or {}) do out[#out + 1] = v end
  return out
end

-- Whole numbered lines (typst snap).
local function snap(h)
  return ((h + BODY - 1) // BODY) * BODY
end

-- A paragraph: o = { before, line, left, right, first, hanging, jc, keep, brk, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  local first = o.first or 0
  if o.hanging then first = nil end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function blank(line)
  return p("", { line = line or BODY })
end

-- Pandoc inlines of a metadata value (a string in the frontmatter is read as markdown).
local function inlines(v)
  if type(v) == "string" then return pandoc.Inlines({ pandoc.Str(v) }) end
  if pandoc.utils.type(v) == "Inlines" then return v end
  return pandoc.utils.blocks_to_inlines(pandoc.Blocks(v))
end

-- Single lines (typst stack): items are metadata values or { v, bold, above }; an empty one is a blank single line.
-- Returns the paragraphs and their height in twips at the column width (twips).
local function stack(items, width)
  local out, h = {}, 0
  for _, it in ipairs(items) do
    local v, bold, above = it, false, 0
    if type(it) == "table" and it.v ~= nil then v, bold, above = it.v, it.bold, it.above or 0 end
    local il = inlines(v)
    if stringify(il) == "" then
      out[#out + 1] = p("", { before = above })
      h = h + above + SINGLE
    else
      out[#out + 1] = p(xe.inl(il, { b = bold }), { before = above })
      h = h + above + SINGLE * tnr.lines(tnr.runs(il, bold), width / 20, SIZE)
    end
  end
  return table.concat(out), h
end

-- A one-row table whose row is rounded up to whole numbered lines (typst grid-row). cells: { w, xml, h, pr }.
local function grid_row(cells, ruled)
  local h, grid, tcs = 0, {}, {}
  for _, c in ipairs(cells) do
    h = math.max(h, c.h)
    grid[#grid + 1] = '<w:gridCol w:w="' .. c.w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.w .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>'
      .. c.xml .. '</w:tc>'
  end
  local H = snap(h) - (ruled and RULE or 0)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>' .. table.concat(grid)
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. H .. '" w:hRule="atLeast"/></w:trPr>'
    .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function mar(side, w)
  return '<w:tcMar><w:' .. side .. ' w:w="' .. w .. '" w:type="dxa"/></w:tcMar>'
end

-- ---------------------------------------------------------------------------
-- Cover: attorney identification, court title, caption
-- ---------------------------------------------------------------------------

local function counsel_block(meta)
  local groups = list(need(meta, "counsel"))
  local n = #groups
  local w = (TEXTW - (n - 1) * COUNSEL_GUT) // n
  local cells = {}
  for k, g in ipairs(groups) do
    local x, h = stack(list(need(g, "lines")), w)
    local gut = k == 1 and 0 or COUNSEL_GUT
    cells[#cells + 1] = { w = w + gut, xml = x, h = h, pr = k == 1 and "" or mar("left", gut) }
  end
  return grid_row(cells)
end

local function court_title()
  local out = {}
  for _, t in ipairs({ "UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF NEVADA" }) do
    out[#out + 1] = p(xe.runs(t, { b = true }), { line = BODY, jc = "center" })
  end
  return table.concat(out)
end

local function caption(meta)
  local debtor = need(meta, "debtor")
  local left = {}
  if debtor.heading then left[#left + 1] = debtor.heading end
  for _, n in ipairs(list(need(debtor, "names"))) do left[#left + 1] = n end
  left[#left + 1] = need(debtor, "designation")
  local right = { "Case No.: " .. stringify(need(meta, "case_number")) }
  if meta.chapter then right[#right + 1] = meta.chapter end
  right[#right + 1] = { v = need(meta, "title"), bold = true, above = CAP_GAP }
  if meta.hearing then
    right[#right + 1] = { v = "Hearing Date: " .. stringify(need(meta.hearing, "date")), above = CAP_GAP }
    right[#right + 1] = "Hearing Time: " .. stringify(need(meta.hearing, "time"))
  end
  local lx, lh = stack(left, CAP_LEFT - RULE_PAD)
  local rx, rh = stack(right, TEXTW - CAP_LEFT - CAP_GUT)
  local rules = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return grid_row({
    { w = CAP_LEFT, xml = lx, h = lh + BOX_PAD, pr = rules .. mar("right", RULE_PAD) },
    { w = TEXTW - CAP_LEFT, xml = rx, h = rh + RULE, pr = mar("left", CAP_GUT) },
  }, true)
end

local function cover(meta)
  local out = {}
  for _ = 1, TITLE_LINES do out[#out + 1] = blank() end
  out[#out + 1] = counsel_block(meta)
  out[#out + 1] = blank()
  out[#out + 1] = court_title()
  out[#out + 1] = blank()
  out[#out + 1] = caption(meta)
  out[#out + 1] = blank()
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature (LR 9004(c)): "Dated" in the first column; each signer's firm, a blank line, "/s/ Name", the name and
-- the role in the second
-- ---------------------------------------------------------------------------

local function signature_block(meta)
  local right = {}
  local signers = need(meta, "signature")
  signers = signers.signer and { signers } or list(signers)
  for k, s in ipairs(signers) do
    local gap = k == 1 and 0 or SIGNER_GAP
    if s.firm then
      right[#right + 1] = { v = s.firm, bold = true, above = gap }
      gap = 0
    end
    right[#right + 1] = { v = "", above = gap }
    right[#right + 1] = "/s/ " .. stringify(need(s, "signer"))
    right[#right + 1] = need(s, "signer")
    for _, l in ipairs(list(need(s, "lines"))) do right[#right + 1] = l end
  end
  local lx, lh = stack({ pandoc.Inlines({ pandoc.Str("Dated: ") }) .. inlines(need(meta, "date")) }, SIG_COL)
  local rx, rh = stack(right, TEXTW - SIG_COL - SIG_GUT)
  return grid_row({
    { w = SIG_COL, xml = lx, h = lh },
    { w = TEXTW - SIG_COL, xml = rx, h = rh, pr = mar("left", SIG_GUT) },
  })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function upper(il)
  return pandoc.Inlines(il):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A heading on the numbered lines, kept with the next block: level 1 centered bold capitals underlined, level 2
-- centered bold, level 3 bold at the margin (typst heading-item); brk: it opens a page.
local function heading(b, brk)
  local lvl = math.min(b.level, 3)
  local c = lvl == 1 and upper(b.content) or b.content
  local props = { xe.style("Heading" .. lvl), xe.KEEP }
  if brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(0, 0, BODY)
  props[#props + 1] = xe.ind(0, nil, 0)
  props[#props + 1] = xe.jc(lvl <= 2 and "center" or "left")
  return xe.para(props, xe.inl(c, { b = true, u = lvl == 1 }))
end

-- A block quotation (typst quote-item): single lines indented on both sides, a quote gap around and between its
-- paragraphs, then the space that brings the next line back onto the numbered lines.
local function quotation(paras)
  local out, h = {}, 0
  for k, q in ipairs(paras) do
    out[#out + 1] = p(xe.inl(q), { before = QGAP, left = QUOTE, right = QUOTE })
    h = h + (k > 1 and QGAP or 0) + SINGLE * tnr.lines(tnr.runs(q), (TEXTW - 2 * QUOTE) / 20, SIZE)
  end
  out[#out + 1] = p("", { line = snap(h + 2 * QGAP) - h - QGAP })
  return table.concat(out)
end

local TAB = "<w:r><w:tab/></w:r>"

-- The lines of a paragraph split at its soft breaks, each without its leading "[sig]" marker.
local function sig_lines(il)
  local lines, cur = {}, pandoc.Inlines({})
  for _, el in ipairs(il) do
    if el.t == "SoftBreak" or el.t == "LineBreak" then
      lines[#lines + 1] = cur
      cur = pandoc.Inlines({})
    else
      cur:insert(el)
    end
  end
  lines[#lines + 1] = cur
  for k, l in ipairs(lines) do
    if l[1] and l[1].t == "Str" and l[1].text == "[sig]" then
      lines[k] = pandoc.Inlines({ table.unpack(l, (l[2] and l[2].t == "Space") and 3 or 2) })
    end
  end
  return lines
end

-- The body: raw paragraphs and tables (strings) and pandoc paragraphs in Body Text (blocks, so footnotes stay
-- pandoc's).
local function body(blocks, meta, out)
  local quotes = {}
  local signed = false
  local function flush()
    if #quotes > 0 then out[#out + 1] = quotation(quotes); quotes = {} end
  end
  for i, b in ipairs(blocks) do
    if b.t ~= "BlockQuote" then flush() end
    local nb = blocks[i + 1]
    local nxt = nb and (nb.t == "Para" or nb.t == "Plain") and stringify(nb) or ""
    local keep = nxt == "[signature]" or nxt:sub(1, 5) == "[sig]"
    local text = (b.t == "Para" or b.t == "Plain") and stringify(b) or ""
    if b.t == "Header" then
      out[#out + 1] = heading(b, signed)
      signed = false
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("nvb-motion-brief.lua: unsupported quotation block " .. q.t) end
        quotes[#quotes + 1] = q.content
      end
    elseif text == "[signature]" then
      out[#out + 1] = p("", { line = BODY, keep = true })
      out[#out + 1] = signature_block(meta)
      signed = true
    elseif text:sub(1, 5) == "[sig]" then
      -- typst sig-item: single lines in the signature column, kept together, the row rounded to numbered lines
      out[#out + 1] = p("", { line = BODY, keep = true })
      local x, h = stack(sig_lines(b.content), TEXTW - SIG_COL - SIG_GUT)
      out[#out + 1] = grid_row({ { w = TEXTW, xml = x, h = h, pr = mar("left", SIG_COL + SIG_GUT) } })
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = keep and "Nvb Body Keep" or "Nvb Body" })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("nvb-motion-brief.lua: list items hold one paragraph")
        end
        local lab = b.t == "OrderedList" and xe.runs(string.char(96 + k) .. ".") or ""
        out[#out + 1] = p(lab .. TAB .. xe.inl(item[1].content),
          { line = BODY, left = LIST_LEFT + LABEL_BOX, hanging = LABEL_BOX,
            tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (LIST_LEFT + LABEL_BOX) .. '"/></w:tabs>' })
      end
    else
      error("nvb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  flush()
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(il)
  for i = 1, #il - 1 do
    local a, b = il[i], il[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      il[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return il
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = { cover(meta) }
  body(doc.blocks, meta, out)
  local res = pandoc.Blocks({})
  for _, x in ipairs(out) do
    if type(x) == "string" then res:insert(xe.raw(x)) else res:insert(x) end
  end
  -- the break rules of typst on the inlines pandoc writes itself (the body paragraphs and their footnotes)
  res = res:walk({ Inlines = xe.inlines })
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
