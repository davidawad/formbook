-- Complaint commencing an adversary proceeding, United States Bankruptcy Court, W.D. Virginia (vawb), docx engine.
-- Mirrors typst/vawb-adversary-complaint.typ; rules and conventions are in ../README.md. The cover (court name and
-- division, the caption: the "In re" block and the parties in a column ruled right and below, chapter, case number
-- and adversary number on the right (Form 416); the title and the salutation), the numbered allegations (Fed. R. Civ.
-- P. 10(b)), the signature block (counsel lower left, LR 7001-1(C)(4)) and the service addresses are built here.
-- Font, spacing, margins and the page number are styles and section settings in docx/reference.xml (fb render builds
-- the reference document from it). Numbers are typed text, the sample's own, as the typst template types them.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter or body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                -- typst pitch-body, pitch-single
local TEXTW = 9360                           -- typst text-width, 6.5 in
local COURT = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF VIRGINIA" }
local CAP_LEFT, CAP_GUTTER = 5760, 360       -- typst caption-left 4 in, caption-gutter 0.25 in
local CAP_PAD, CAP_PAD_BOTTOM = 200, 145     -- typst caption-pad 10 pt, caption-pad-bottom 8 pt less the 0.75 pt rule Word adds below the cell
local CASE_PAD = 144                         -- typst case-pad 0.1 in
local COURT_BELOW, CAPTION_BELOW = 480, 480  -- typst court-below, caption-below 24 pt
local SIG_RIGHT, SIG_GUTTER = 4176, 288      -- typst sig-right 2.9 in, sig-gutter 0.2 in
local SIG_ABOVE, SERVICE_ABOVE = 480, 480    -- typst signature-above, service-above 24 pt
local GAP = 120                              -- typst block-gap 6 pt

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

local function empty(v)
  return v == nil or txt(v) == ""
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph in exact line boxes: o = { before, line, jc, keep, b }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- A line of text: a string as runs, a metadata value as its inlines.
local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- Single-spaced lines (typst line-stack): an empty item is a blank line, the next line a line lower; `above` a space
-- of its own above the first line; keep: every line keeps with the next.
local function stack(lines, above, keep)
  local out, gap = {}, above or 0
  for _, l in ipairs(lines) do
    if txt(l) == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(line(l), { before = gap, keep = keep })
      gap = 0
    end
  end
  return table.concat(out)
end

-- A metadata value with text before or after it, as one line (inlines).
local function cat(...)
  local out = pandoc.Inlines({})
  for _, x in ipairs({ ... }) do
    if type(x) == "string" then out:insert(pandoc.Str(x)) else out:extend(pandoc.Inlines(x)) end
  end
  return out
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>'
    .. (inner ~= "" and inner or p("")) .. '</w:tc>'
end

-- A one-row table without borders or cell margins of its own, not split across pages.
local function table1(widths, cells)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. table.concat(cells) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption, title, salutation
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(m)
  local out = {}
  local court = { table.unpack(COURT) }
  if not empty(m.division) then court[#court + 1] = txt(m.division):upper() end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center" }) end
  out[#out + 1] = space(COURT_BELOW)

  local left, right = {}, {}
  for k, d in ipairs(items(m.caption.in_re)) do
    left[#left + 1] = k == 1 and "In re:" or ""
    for _, n in ipairs(items(d.names)) do left[#left + 1] = n end
    left[#left + 1] = d.designation
    left[#left + 1] = ""
    right[#right + 1] = cat("Chapter ", d.chapter)
    right[#right + 1] = cat("Case No. ", d.case_number)
    right[#right + 1] = ""
  end
  for k, pt in ipairs(items(m.caption.parties)) do
    if k > 1 then left[#left + 1] = "v." end
    for _, n in ipairs(items(pt.names)) do left[#left + 1] = n end
    left[#left + 1] = pt.designation
  end
  -- A blank number stays a blank to be filled in by the filer.
  local num = m.caption.number
  right[#right + 1] = cat(num.label, " ", empty(num.value) and "________" or num.value)
  local cap_right = TEXTW - CAP_LEFT - CAP_GUTTER
  out[#out + 1] = table1({ CAP_LEFT, CAP_GUTTER, cap_right }, {
    cell(CAP_LEFT, stack(left), '<w:tcBorders>' .. string.format(RULE, "bottom") .. string.format(RULE, "right")
      .. '</w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_PAD_BOTTOM .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD
      .. '" w:type="dxa"/></w:tcMar>'),
    cell(CAP_GUTTER, ""),
    cell(cap_right, stack(right), '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>'),
  })
  out[#out + 1] = space(CAPTION_BELOW)
  if not empty(m.title) then
    out[#out + 1] = p(xe.runs(txt(m.title):upper(), { b = true }), { line = BODY, jc = "center" })
  end
  if not empty(m.salutation) then out[#out + 1] = p(xe.inl(m.salutation), { line = BODY }) end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (counsel lower left, LR 7001-1(C)(4); party and signer lower right), service addresses
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local dated = not empty(s.date)
  local left = ""
  if dated then left = stack({ cat("Dated: ", s.date) }) end
  local counsel = {}
  for _, n in ipairs(items(m.counsel.names)) do counsel[#counsel + 1] = n end
  for _, n in ipairs(items(m.counsel.lines)) do counsel[#counsel + 1] = n end
  left = left .. stack(counsel, dated and GAP or 0)
  local right = { "Respectfully submitted,", "", txt(s.party):upper(), "", cat("BY: /s/ ", s.signer) }
  for _, n in ipairs(items(s.lines)) do right[#right + 1] = n end
  local sig_left = TEXTW - SIG_RIGHT - SIG_GUTTER
  return space(SIG_ABOVE) .. table1({ sig_left, SIG_GUTTER, SIG_RIGHT },
    { cell(sig_left, left), cell(SIG_GUTTER, ""), cell(SIG_RIGHT, stack(right, dated and (SINGLE + GAP) or 0)) })
end

local function service(m)
  if m.service == nil then return "" end
  -- (text, space above) per line; every line but the last keeps with the next, so the block stays on one page
  -- (typst breakable: false)
  local lines = { { "Service:", 0 } }
  for _, g in ipairs(items(m.service)) do
    local gap = GAP
    for _, key in ipairs({ "names", "lines" }) do
      for _, n in ipairs(items(g[key])) do
        lines[#lines + 1] = { n, gap }
        gap = 0
      end
    end
  end
  local out = { space(SERVICE_ABOVE) }
  for i, l in ipairs(lines) do out[#out + 1] = p(line(l[1]), { before = l[2], keep = i < #lines }) end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("523(a)(8)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function finish(doc)
  local m = doc.meta
  local out = { xe.raw(cover(m)) }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lvl = math.min(b.level, 3)
      out[#out + 1] = pandoc.Header(lvl, lvl == 1 and upper(b.content) or b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled("Body Text", b.content)
    elseif b.t == "OrderedList" then
      local n = b.listAttributes.start
      for _, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Numbered Paragraph", inl)
        n = n + 1
      end
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do out[#out + 1] = styled("Block Text", q.content) end
    else
      error("vawb-adversary-complaint.lua: unexpected block " .. b.t)
    end
  end
  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(m) .. service(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules }, { Pandoc = finish } }
