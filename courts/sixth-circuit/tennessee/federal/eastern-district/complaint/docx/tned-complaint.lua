-- Pandoc filter for the E.D. Tenn. complaint, engine docx, so that it reads and breaks as typst/tned-complaint.typ
-- does: court title (with the division when the filing names one), caption (the parties left in a column closed by
-- rules on the right and below; the case number and the title right; Fed. R. Civ. P. 10(a)), the lead-in, numbered
-- paragraphs (Fed. R. Civ. P. 10(b)), unnumbered WHEREFORE paragraphs, headings kept with what follows, lettered
-- items (a), (b), ... for "1." lists, and the signature block (LR 5.1, Fed. R. Civ. P. 11(a)) kept together with the
-- last paragraph. Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs and their
-- footnotes are written by pandoc in the styles of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body (LR 5.1 double spacing), pitch-single
local GAP = 276                          -- typst gap: a blank single line
local CAPTION_BELOW = 240                -- typst caption-below, 12 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LEFT, INSET, RIGHT_GAP = 4608, 200, 360   -- typst caption-left 3.2 in, caption-inset 10 pt, caption-gap 0.25 in
local DESIGNATION, VERSUS = 1440, 720    -- typst designation-indent 1 in, versus-indent 0.5 in
local SIG = 4680                         -- typst sig-indent, 3.25 in
local TEXTW = 9360                       -- 6.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  if m == nil then return {} end
  return m
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1681n": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- Metadata inlines with the body's break rules.
local function meta_inl(m, o)
  if m == nil then return "" end
  if type(m) == "string" then return xe.runs(m, o) end
  local l = pandoc.Inlines(m):walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  return xe.inl(l, o)
end

-- ---------------------------------------------------------------------------
-- Court title and caption (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function tc(w, props, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. props .. '</w:tcPr>' .. body .. '</w:tc>'
end

local function caption(meta, out)
  local court = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF TENNESSEE" }
  if meta.division then court[#court + 1] = pandoc.text.upper(plain(meta.division)) end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  -- the parties: names, a blank line, the designation; "v." a blank line from each side
  local left = {}
  for k, side in ipairs(list(meta.caption.parties)) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { before = GAP, left = VERSUS }) end
    for j, n in ipairs(list(side.names)) do
      left[#left + 1] = p(meta_inl(n), { before = (k > 1 and j == 1) and GAP or 0 })
    end
    left[#left + 1] = p(meta_inl(side.designation), { before = GAP, left = DESIGNATION })
  end
  local right = p(xe.runs("Case No. " .. plain(meta.case_number))) ..
    p(meta_inl(meta.title, { b = true }), { before = BODY })
  local borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local lmar = '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="' .. INSET ..
    '" w:type="dxa"/><w:right w:w="' .. INSET .. '" w:type="dxa"/></w:tcMar>'
  local rmar = '<w:tcMar><w:left w:w="' .. RIGHT_GAP .. '" w:type="dxa"/></w:tcMar>'
  local rw = TEXTW - LEFT
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(LEFT, borders .. lmar, table.concat(left)) ..
    tc(rw, rmar, right) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature (LR 5.1; Fed. R. Civ. P. 11(a))
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local dated = sig.date and ("Dated: " .. plain(sig.date)) or ""
  local lines = { { xe.runs(dated .. "\tRespectfully submitted,"), BODY, 0, true } }
  for i, f in ipairs(list(sig.firm)) do lines[#lines + 1] = { meta_inl(f, { b = true }), i == 1 and GAP or 0, SIG } end
  lines[#lines + 1] = { xe.runs("By: /s/ ") .. meta_inl(sig.signer), GAP, SIG }
  lines[#lines + 1] = { meta_inl(sig.signer), 0, SIG }
  if sig.bpr then lines[#lines + 1] = { meta_inl(sig.bpr), 0, SIG } end
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { meta_inl(l), 0, SIG } end
  if sig.role then lines[#lines + 1] = { meta_inl(sig.role, { i = true }), GAP, SIG } end
  -- kept on one page (typst's unbreakable block): every line but the last keeps with the next
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l[1], { before = l[2], left = l[3], keep = i < #lines, tab = l[4] and SIG or nil }))
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function upper(inlines)
  return inlines:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "title", "signature" }) do
    assert(meta[k], "tned-complaint: frontmatter needs " .. k)
  end

  local raw = {}
  caption(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  if meta.lead_in then
    out[#out + 1] = xe.raw(p(meta_inl(meta.lead_in), { before = CAPTION_BELOW, line = BODY, first = INDENT }))
  end

  local blocks = doc.blocks
  local n = 0
  for k, b in ipairs(blocks) do
    local last = k == #blocks
    if b.t == "Header" then
      -- a body line, kept with what follows: level 1 centered bold capitals underlined, level 2 centered bold,
      -- level 3 bold at the left
      local lvl = b.level
      local body = lvl == 1 and xe.inl(upper(b.content), { b = true, u = true }) or xe.inl(b.content, { b = true })
      out[#out + 1] = xe.raw(xe.para({ xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
        xe.jc(lvl <= 2 and "center" or "left"), '<w:outlineLvl w:val="' .. (math.min(lvl, 3) - 1) .. '"/>' }, body))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- the label in a half-inch box half an inch in, the text hanging an inch in
      for j, item in ipairs(b.content) do
        local inl = pandoc.Inlines({})
        for m, ib in ipairs(item) do
          if m > 1 then inl:insert(pandoc.Space()) end
          inl:extend(ib.content)
        end
        local lab = b.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")") or "\u{2022}"
        out[#out + 1] = xe.raw(p(xe.runs(lab .. "\t") .. xe.inl(inl), { line = BODY, left = 2 * INDENT,
          hanging = INDENT, tab = 2 * INDENT, keep = last and j == #b.content }))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local style, inl
      if pandoc.utils.stringify(b):match("^WHEREFORE") then
        style, inl = "Body Text", b.content
      else
        n = n + 1
        style = "Body Numbered"
        inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inl:extend(b.content)
      end
      if last then style = style == "Body Text" and "Body Keep" or "Body Numbered Keep" end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
    else
      error("tned-complaint.lua: unsupported block " .. b.t)
    end
  end

  signature(meta, out)
  -- pandoc would print the metadata title above the body; the caption and title are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
