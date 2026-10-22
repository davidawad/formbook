-- Motion with memorandum in support, United States Bankruptcy Court, W.D. Virginia (vawb), docx engine.
-- Mirrors typst/vawb-motion-brief.typ; rules and conventions are in ../README.md. The cover (court name and division;
-- the caption, LR 9013-1(I): each debtor's names beside that debtor's chapter and case number, the parties in a
-- column ruled right and below, the motion or adversary number beside them; the title), the numbered paragraphs, the
-- I. / A. / 1. / a. heading labels, the signature block (counsel lower left, LR 9013-1(C)) and the certificate of
-- service (LR 9013-1(E)) are built here. Font, spacing, margins, footnotes and the page number are styles and section
-- settings in docx/reference.xml (fb render builds the reference document from it). Numbers and labels are typed
-- text, as the typst template types them. Content-agnostic: every case-specific word comes from the sample's
-- frontmatter or body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line, 230 a footnote line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                -- typst pitch-body, pitch-single
local TEXTW = 9360                           -- typst text-width, 6.5 in
local COURT = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF VIRGINIA" }
local CAP_LEFT, CAP_GUTTER = 5760, 360       -- typst caption-left 4 in, caption-gutter 0.25 in
local CAP_PAD, CAP_PAD_BOTTOM = 200, 145     -- typst caption-pad 10 pt, caption-pad-bottom 8 pt less the 0.75 pt rule Word adds below the cell
local CASE_PAD = 144                         -- typst case-pad 0.1 in
local COURT_BELOW, CAPTION_BELOW = 480, 480  -- typst court-below, caption-below 24 pt
local CAPTION_GAP = 240                      -- typst caption-gap 12 pt
local TITLE_BELOW = 480                      -- typst title-below 24 pt
local SIG_RIGHT, SIG_GUTTER = 4176, 288      -- typst sig-right 2.9 in, sig-gutter 0.2 in
local SIG_ABOVE, CERT_ABOVE = 480, 480       -- typst signature-above, certificate-above 24 pt
local GAP = 120                              -- typst block-gap 6 pt
local SERVICE_GAP = 240                      -- typst service-gap 12 pt
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }

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

-- A table without borders or cell margins of its own, its rows not split across pages; rows: lists of cells.
local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, r in ipairs(rows) do trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(r) .. '</w:tr>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption, title
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(m)
  local out = {}
  local court = { table.unpack(COURT) }
  if not empty(m.division) then court[#court + 1] = txt(m.division):upper() end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center" }) end
  out[#out + 1] = space(COURT_BELOW)

  local cap_right = TEXTW - CAP_LEFT - CAP_GUTTER
  local case_mar = '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>'
  local rows = {}
  for k, d in ipairs(items(m.caption.in_re)) do
    local left = { k == 1 and "In re:" or "" }
    for _, n in ipairs(items(d.names)) do left[#left + 1] = n end
    left[#left + 1] = d.designation
    local above = k == 1 and 0 or CAPTION_GAP
    rows[#rows + 1] = {
      cell(CAP_LEFT, stack(left, above)),
      cell(CAP_GUTTER, ""),
      cell(cap_right, stack({ cat("Chapter ", d.chapter), cat("Case No. ", d.case_number) }, above), case_mar),
    }
  end
  local parties = {}
  for k, pt in ipairs(items(m.caption.parties)) do
    if k > 1 then parties[#parties + 1] = "v." end
    for _, n in ipairs(items(pt.names)) do parties[#parties + 1] = n end
    parties[#parties + 1] = pt.designation
  end
  -- A blank number stays a blank for the filer to fill in.
  local num = m.caption.number
  rows[#rows + 1] = {
    cell(CAP_LEFT, stack(parties, CAPTION_GAP), '<w:tcBorders>' .. string.format(RULE, "bottom")
      .. string.format(RULE, "right") .. '</w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_PAD_BOTTOM
      .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'),
    cell(CAP_GUTTER, ""),
    cell(cap_right, stack({ num.label, empty(num.value) and "________" or num.value }, CAPTION_GAP), case_mar),
  }
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, cap_right }, rows)
  out[#out + 1] = space(CAPTION_BELOW)
  out[#out + 1] = p(xe.runs(txt(m.title):upper(), { b = true }), { line = BODY, jc = "center" })
  out[#out + 1] = space(TITLE_BELOW)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (counsel lower left, LR 9013-1(C); party and signer lower right) and certificate of service
-- (LR 9013-1(E)), each after a space of its own
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
  return space(SIG_ABOVE) .. tbl({ sig_left, SIG_GUTTER, SIG_RIGHT },
    { { cell(sig_left, left), cell(SIG_GUTTER, ""), cell(SIG_RIGHT, stack(right, dated and (SINGLE + GAP) or 0)) } })
end

-- The certificate is kept on one page (typst breakable: false): every paragraph but the last keeps with the next.
local function certificate(m)
  local s = m.service
  if s == nil then return "" end
  local paras = {
    { xe.runs("CERTIFICATE OF SERVICE", { b = true }), { line = BODY, jc = "center" } },
    { xe.inl(s.statement), { line = BODY, before = SERVICE_GAP } },
  }
  local function group(lines)
    local gap = SERVICE_GAP
    for _, l in ipairs(lines) do
      paras[#paras + 1] = { line(l), { before = gap } }
      gap = 0
    end
  end
  for _, g in ipairs(items(s.parties)) do
    local l = {}
    for _, n in ipairs(items(g.names)) do l[#l + 1] = n end
    for _, n in ipairs(items(g.lines)) do l[#l + 1] = n end
    group(l)
  end
  local signer = { cat("/s/ ", s.signer) }
  for _, n in ipairs(items(s.lines)) do signer[#signer + 1] = n end
  group(signer)
  local out = { space(CERT_ABOVE) }
  for i, x in ipairs(paras) do
    x[2].keep = i < #paras
    out[#out + 1] = p(x[1], x[2])
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("3001(c)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("CM/ECF", "A/B"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after
-- it. Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there even after a word joiner): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

-- A paragraph that anchors a footnote has no widow control (the "Note" styles, docx/reference.xml).
local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function styled(style, inlines)
  if has_note(inlines) then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function label(lvl, n)
  if lvl == 2 then return ROMAN[n] .. "." end
  if lvl == 3 then return string.char(64 + n) .. "." end
  if lvl == 4 then return n .. "." end
  return string.char(96 + n) .. "."
end

local function finish(doc)
  local m = doc.meta
  local out = { xe.raw(cover(m)) }
  local c = { 0, 0, 0, 0, 0 } -- heading counters, levels 2 to 5
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lvl = math.min(b.level, 5)
      if lvl == 1 then
        out[#out + 1] = pandoc.Header(1, upper(b.content))
      else
        c[lvl] = c[lvl] + 1
        for j = lvl + 1, 5 do c[j] = 0 end
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(label(lvl, c[lvl]) .. "\t")) })
        inl:extend(b.content)
        out[#out + 1] = pandoc.Header(lvl, inl)
      end
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
      error("vawb-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(m) .. certificate(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
