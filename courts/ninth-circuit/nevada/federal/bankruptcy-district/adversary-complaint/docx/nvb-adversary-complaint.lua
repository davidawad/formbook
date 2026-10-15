-- nvb-adversary-complaint.lua: pandoc filter for the D. Nev. adversary complaint, docx engine.
-- Mirrors typst/nvb-adversary-complaint.typ: the cover (counsel block, court title, caption), the numbered
-- paragraphs, lettered and bulleted lists, headings, block quotations, the prayer and the signature block.
-- Everything case-specific comes from the sample's frontmatter; the layout comes from reference.docx styles.
-- Cover, caption and signature are raw WordprocessingML built here. Heights are in twips (1 pt = 20).

local SINGLE = 299   -- single-spaced line (15 pt): the typst single-leading gap plus the 13 pt line box
local BLANK = 260    -- blank line inside a single-spaced stack (typst: a 6.5 pt block)
local PITCH = 480    -- one numbered line (24 pt)
local GAP12 = 240    -- v(pitch * 0.5)
local TEXTW = 9000   -- text width: 8.5 in - 1.5 in - 0.75 in = 6.25 in
local GUT = 360      -- 0.25 in gutter between counsel groups
local CAP_LEFT = 4608   -- 3.2 in: the caption's party column
local CAP_GUT = 288     -- 0.2 in
local SIG_LEFT = 3744   -- 2.6 in: the "Dated" column of the signature block
local SIG_GUT = 288

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function snap(h)
  return ((h + PITCH - 1) // PITCH) * PITCH
end

local function ptext(s, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

local function para(style, inner, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. "</w:pPr>" .. inner .. "</w:p>"
end

-- an empty paragraph of exact height (twips): the v(...) gaps of typst
local function spacer(twips)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- Estimated number of lines a string takes at 13 pt in a column of width_tw twips. Used only to keep the
-- cover and signature on the 24 pt grid of numbered lines; a conservative (wide) estimate.
local function wrap_lines(s, width_tw, bold)
  local width = width_tw / 20
  local em = 13
  local function cw(ch)
    local w
    if ch:match("%u") then w = 0.60
    elseif ch:match("%l") then w = 0.41
    elseif ch:match("%d") then w = 0.45
    elseif ch == " " then w = 0.23
    else w = 0.40 end
    return w * em * (bold and 1.12 or 1)
  end
  local lines, cur = 1, 0
  for word in s:gmatch("%S+") do
    local w = 0
    for ch in word:gmatch(utf8.charpattern) do w = w + cw(ch) end
    local sp = (cur > 0) and cw(" ") or 0
    if cur > 0 and cur + sp + w > width then
      lines = lines + 1
      cur = w
    else
      cur = cur + sp + w
    end
  end
  return lines
end

-- A single-spaced stack. Items: a string (one line; "" is a blank line), {t=, b=} (bold line), or {gap=twips}.
-- opts.ppr is applied to every paragraph of the stack, opts.last to the last one (borders). Returns the XML
-- and the estimated height.
local function stack(items, width_tw, opts)
  opts = opts or {}
  local xml, h = {}, 0
  for i, it in ipairs(items) do
    local bdr = ((i == #items) and (opts.last or opts.ppr) or opts.ppr) or ""
    local ind = opts.ind or ""
    if type(it) == "table" and it.gap then
      xml[#xml + 1] = spacer(it.gap)
      h = h + it.gap
    else
      local t, b = it, false
      if type(it) == "table" then t, b = it.t, it.b end
      if t == "" then
        xml[#xml + 1] = '<w:p><w:pPr>' .. bdr .. '<w:spacing w:before="0" w:after="0" w:line="' .. BLANK .. '" w:lineRule="exact"/>' .. ind .. '</w:pPr></w:p>'
        h = h + BLANK
      else
        xml[#xml + 1] = para("Single", ptext(t, b), bdr .. ind)
        h = h + SINGLE * wrap_lines(t, width_tw, b)
      end
    end
  end
  return table.concat(xml), h
end

-- A borderless layout table, one row. cells: {w=, xml=, h=, tcpr=}. Returns the XML and the tallest cell.
local function row(cells, H)
  local grid, tcs, hmax = {}, {}, 0
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c.w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.w .. '" w:type="dxa"/>' .. (c.tcpr or "")
      .. '<w:vAlign w:val="top"/></w:tcPr>' .. c.xml .. "</w:tc>"
    hmax = math.max(hmax, c.h or 0)
  end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblBorders>' .. none
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>'
    .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. H .. '" w:hRule="atLeast"/></w:trPr>' .. table.concat(tcs)
    .. "</w:tr></w:tbl>"
  return xml
end

-- A stack ends with a line whose 6.5 pt of leading typst does not add after the last item; the grid height
-- of a block is measured without it (typst on-grid).
local TRAIL = 130

local BDR_RIGHT = '<w:pBdr><w:right w:val="single" w:sz="6" w:space="10" w:color="000000"/></w:pBdr>'
local IND_RIGHT = '<w:ind w:right="200"/>'
local BDR_BOTTOM = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="8" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="10" w:color="000000"/></w:pBdr>'

local function gutter(w)
  return { w = w, xml = spacer(20), h = 0 }
end

-- ---------------------------------------------------------------------------
-- Frontmatter
-- ---------------------------------------------------------------------------

local function s(x)
  return pandoc.utils.stringify(x)
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("nvb-adversary-complaint: missing required metadata field `" .. key .. "`") end
  return v
end

local function lines_of(list)
  local out = {}
  for _, l in ipairs(list) do out[#out + 1] = s(l) end
  return out
end

-- counsel block: one column per counsel group (LR 9004(g)), single-spaced, on the grid
local function counsel_block(meta)
  local groups = need(meta, "counsel")
  local n = #groups
  local colw = (TEXTW - (n - 1) * GUT) // n
  local cells, hmax = {}, 0
  for i, g in ipairs(groups) do
    local x, h = stack(lines_of(need(g, "lines")), colw)
    hmax = math.max(hmax, h)
    cells[#cells + 1] = { w = colw, xml = x, h = h }
    if i < n then cells[#cells + 1] = gutter(GUT) end
  end
  local x = row(cells, snap(hmax - TRAIL))
  return x
end

-- court title (LR 9004(g)): two lines, bold, centered, one numbered line each
local function court_title()
  return para("Normal", ptext("UNITED STATES BANKRUPTCY COURT", true), '<w:jc w:val="center"/>')
    .. para("Normal", ptext("DISTRICT OF NEVADA", true), '<w:jc w:val="center"/>')
end

-- caption (LR 7010(b)): the debtor and the adversary parties on the left, the case and adversary numbers,
-- the title of the paper on the right
local function caption(meta)
  local debtor = need(meta, "debtor")
  local left = {}
  if debtor.heading then left[#left + 1] = s(debtor.heading) end
  for _, n in ipairs(lines_of(need(debtor, "names"))) do left[#left + 1] = n end
  left[#left + 1] = s(need(debtor, "designation"))
  if meta.caption_parties then
    left[#left + 1] = ""
    for k, p in ipairs(meta.caption_parties) do
      if k > 1 then left[#left + 1] = "v." end
      for _, n in ipairs(lines_of(need(p, "names"))) do left[#left + 1] = n end
      left[#left + 1] = s(need(p, "designation"))
    end
  end
  local lx, lh = stack(left, CAP_LEFT - 200, { ppr = BDR_RIGHT, last = BDR_BOTTOM, ind = IND_RIGHT })
  lh = lh - TRAIL + 160 -- the typst block adds an 8 pt inset under the rule

  local right = { "Case No.: " .. s(need(meta, "case_number")) }
  if meta.chapter then right[#right + 1] = s(meta.chapter) end
  right[#right + 1] = { gap = GAP12 }
  right[#right + 1] = "Adversary No.: " .. (meta.adversary_number and s(meta.adversary_number) or "")
  right[#right + 1] = { gap = GAP12 }
  right[#right + 1] = { t = s(need(meta, "title")), b = true }
  if meta.subtitle then right[#right + 1] = { t = s(meta.subtitle), b = true } end
  if meta.jury_demand == true then
    right[#right + 1] = { gap = GAP12 }
    right[#right + 1] = { t = "DEMAND FOR JURY TRIAL", b = true }
  end
  local rx, rh = stack(right, TEXTW - CAP_LEFT - CAP_GUT - 144)
  rh = rh - TRAIL

  local x = row({
    { w = CAP_LEFT, xml = lx, h = lh, },
    gutter(CAP_GUT),
    { w = TEXTW - CAP_LEFT - CAP_GUT, xml = rx, h = rh, tcpr = '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>' },
  }, snap(math.max(lh, rh)))
  return x
end

local function cover(meta)
  return spacer(PITCH) .. spacer(PITCH) -- title-page-lines = 2: the counsel block starts on line 3
    .. counsel_block(meta)
    .. spacer(PITCH)
    .. court_title()
    .. spacer(PITCH)
    .. caption(meta)
end

-- signature block (LR 9004(c)): "Dated" on the left; each signer's firm, "/s/ Name", name and role on the right
local function signature_block(meta)
  local blocks = need(meta, "signature")
  if blocks.signer then blocks = { blocks } end
  local right = {}
  for i, b in ipairs(blocks) do
    if i > 1 then right[#right + 1] = { gap = GAP12 } end
    if b.firm then right[#right + 1] = s(b.firm) end
    right[#right + 1] = ""
    right[#right + 1] = "/s/ " .. s(need(b, "signer"))
    right[#right + 1] = s(need(b, "signer"))
    for _, l in ipairs(lines_of(need(b, "lines"))) do right[#right + 1] = l end
  end
  local rx, rh = stack(right, TEXTW - SIG_LEFT - SIG_GUT)
  local lx, lh = stack({ "Dated: " .. s(need(meta, "date")) }, SIG_LEFT)
  local x = row({
    { w = SIG_LEFT, xml = lx, h = lh },
    gutter(SIG_GUT),
    { w = TEXTW - SIG_LEFT - SIG_GUT, xml = rx, h = rh },
  }, snap(math.max(lh, rh) - TRAIL))
  return x
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local numbered = 0

local function drop_unnumbered(inlines)
  local out, skip = {}, false
  local i = 1
  if inlines[1] and inlines[1].t == "Str" and inlines[1].text == "[unnumbered]" then
    i = 2
    if inlines[i] and inlines[i].t == "Space" then i = i + 1 end
  end
  for j = i, #inlines do out[#out + 1] = inlines[j] end
  return out
end

local QUOTE_W = TEXTW - 1440 -- quotation: indented 0.5 in on both sides

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function upper_inlines(inlines)
  return inlines:walk({
    Str = function(el) return pandoc.Str(pandoc.text.upper(el.text)) end,
  })
end

local function inline_list(b)
  if b.t == "Para" or b.t == "Plain" then return b.content end
  error("nvb-adversary-complaint: list item content not supported: " .. b.t)
end

local function body_blocks(blocks, lead)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then b.content = upper_inlines(b.content) end
      out[#out + 1] = b
    elseif b.t == "Para" then
      local text = s(b)
      if text:sub(1, 12) == "[unnumbered]" then
        out[#out + 1] = pandoc.Para(drop_unnumbered(b.content))
      else
        numbered = numbered + 1
        local content = pandoc.List({ pandoc.Str(tostring(numbered) .. "."), TAB })
        content:extend(b.content)
        out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Numbered Paragraph" })
      end
    elseif b.t == "OrderedList" then
      local idx = 0
      for _, item in ipairs(b.content) do
        idx = idx + 1
        local content = pandoc.List({ pandoc.Str(string.char(96 + idx) .. "."), TAB })
        content:extend(inline_list(item[1]))
        out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Lettered Item" })
      end
    elseif b.t == "BlockQuote" then
      -- a quotation is single-spaced: its height is rounded up to whole numbered lines so the text after it
      -- stays on the grid (the typst template does the same with on-grid)
      local total = 0
      for _, p in ipairs(b.content) do
        if p.t == "Para" or p.t == "Plain" then total = total + SINGLE * wrap_lines(s(p), QUOTE_W, false) end
      end
      out[#out + 1] = b
      local fill = snap(total) - total
      if fill > 0 then out[#out + 1] = pandoc.RawBlock("openxml", spacer(fill)) end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        out[#out + 1] = pandoc.Div({ pandoc.Para(inline_list(item[1])) }, { ["custom-style"] = "Bullet Item" })
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local cov = cover(meta)
  local sig = signature_block(meta)
  local lead = meta.lead_in and pandoc.read(s(meta.lead_in), "markdown").blocks or {}
  -- the title, subtitle and date are set on the cover, not by pandoc's title block
  doc.meta.title = nil
  doc.meta.subtitle = nil
  doc.meta.date = nil
  local body = body_blocks(doc.blocks, lead)
  local blocks = { pandoc.RawBlock("openxml", cov .. spacer(PITCH)) }
  for _, b in ipairs(lead) do
    blocks[#blocks + 1] = pandoc.Para(b.content)
  end
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", spacer(PITCH) .. sig)
  return pandoc.Pandoc(blocks, doc.meta)
end
