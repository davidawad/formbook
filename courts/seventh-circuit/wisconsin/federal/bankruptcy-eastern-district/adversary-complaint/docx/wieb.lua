-- E.D. Wis. bankruptcy adversary complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it
-- reads and breaks as typst/wieb-adversary-complaint.typ does: the court title, the caption (a table of two rows,
-- each ruled at its foot: the bankruptcy case and the adversary proceeding, their numbers centered beside them), the
-- title, the consent statement (FRBP 7008(a)), the body chunks (headings, paragraphs with the drafter's numbers,
-- FRCP 10(b) via FRBP 7010) and the signature block. Every case-specific word comes from the YAML frontmatter and
-- the body, never from this file; the rule text below is constant, as in the typst. Font, margins and the page
-- number are in docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 288 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local CONSENT = { ["does"] = true, ["does not"] = true }

local BODY, SINGLE = 480, 288            -- typst pitch-body 24 pt, pitch-single 14.4 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUMBER = 1296                      -- typst para-indent + number-box, 0.9 in
local TEXTW = 9360                       -- 6.5 in
local GUTTER = 576                       -- typst caption-gutter, 0.4 in
local COL = (TEXTW - GUTTER) // 2        -- each caption column
local CAP_INDENT, DESIGNATION, VERSUS = 720, 3168, 1296 -- typst caption-indent, designation-indent, versus-indent
local CAP_PAD = 144                      -- typst caption-pad, 7.2 pt
local RULE = 15                          -- typst caption-rule, 0.75 pt (Word sets it inside the cell's bottom margin)
local SIG = 4680                         -- typst sig-indent, 3.25 in
local TITLE_GAP, IN_RE_GAP, VERSUS_GAP = 288, 144, 216 -- typst title-gap, in-re-gap, versus-gap
local TITLE_BELOW, CONSENT_BELOW = 192, 288 -- typst title-below, consent-below
local H_ABOVE = { 288, 240, 192 }        -- typst h1-above, h2-above, h3-above
local H_BELOW = { 144, 144, 120 }        -- typst h-below, h3-below
local SIG_ABOVE, SIGNER_ABOVE, SIGNER_GAP = 576, 288, 48 -- typst sig-above, signer-above, signer-gap

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("wieb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
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

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A sign stays with its number, and the number is not broken ("§§ 727", "§ 727(a)(4)(A)": typst boxes
-- "[§¶]+ \S+"; xe.inl binds a single sign to its number, LibreOffice would still break after a dash or slash in it).
local function bind_signs(inl)
  for i = 1, #inl - 1 do
    local a, b, c = inl[i], inl[i + 1], inl[i + 2]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      if a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") then inl[i + 1] = pandoc.Str("\u{00A0}") end
      if c and c.t == "Str" then
        inl[i + 2] = pandoc.Str((c.text:gsub("\u{200B}", ""):gsub("\u{2013}", "\u{2013}\u{2060}")
          :gsub("\u{2014}", "\u{2014}\u{2060}"):gsub("/", "/\u{2060}")))
      end
    end
  end
  return inl
end

local function fix(inl)
  return bind_signs(pandoc.Inlines(inl):walk({ Str = breaks }))
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(a)" or "A." lists).
local function md(s)
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return fix(pandoc.utils.blocks_to_inlines(doc.blocks))
end

local function text(v)
  if type(v) == "string" then return xe.inl(md(v)) end
  return xe.inl(fix(v))
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- ---------------------------------------------------------------------------
-- Caption (FRBP 7010: the caption must substantially conform to Form 416A)
-- ---------------------------------------------------------------------------

local function cell(w, top, ps, center)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" ' ..
    'w:space="0" w:color="000000"/></w:tcBorders><w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:bottom w:w="' ..
    (CAP_PAD - RULE) .. '" w:type="dxa"/></w:tcMar>' .. (center and '<w:vAlign w:val="center"/>' or "") ..
    '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function row(top, left, right)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(COL, top, left) .. cell(GUTTER, top, { p("") }) ..
    cell(TEXTW - COL - GUTTER, top, right, true) .. '</w:tr>'
end

local function caption(m, out)
  local d, pl, df = need(m, "debtor"), need(m, "plaintiff"), need(m, "defendant")
  out[#out + 1] = p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("EASTERN DISTRICT OF WISCONSIN", { b = true }), { jc = "center" })
  out[#out + 1] = p("", { line = TITLE_GAP })
  local r1 = {
    p(xe.runs("In re:")),
    p(text(d.name), { before = IN_RE_GAP, left = CAP_INDENT }),
    p(text(d.designation), { left = CAP_INDENT }),
  }
  local r2 = {}
  for _, n in ipairs(items(pl.names)) do r2[#r2 + 1] = p(text(n)) end
  r2[#r2 + 1] = p(text(pl.designation), { left = DESIGNATION })
  r2[#r2 + 1] = p(xe.runs("v."), { before = VERSUS_GAP, left = VERSUS })
  for k, n in ipairs(items(df.names)) do r2[#r2 + 1] = p(text(n), { before = k == 1 and VERSUS_GAP or 0 }) end
  r2[#r2 + 1] = p(text(df.designation), { left = DESIGNATION })
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    COL .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - COL - GUTTER) .. '"/></w:tblGrid>' ..
    row(0, r1, { p(text(d.case_number)), p(text(d.chapter)) }) ..
    row(CAP_PAD, r2, { p(text(need(m, "adversary_number"))) }) .. '</w:tbl>'
  out[#out + 1] = p(xe.inl(md(plain(need(m, "title"))), { b = true }),
    { before = TITLE_GAP, after = TITLE_BELOW, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Consent statement (FRBP 7008(a); LR 7008-1 forfeits a statement that is missing)
-- ---------------------------------------------------------------------------

local function consent(m, out)
  local c = plain(need(m, "consent"))
  if not CONSENT[c] then error("wieb-adversary-complaint: `consent` must be \"does\" or \"does not\"", 0) end
  out[#out + 1] = p(xe.inl(md("Pursuant to Fed. R. Bankr. P. 7008(a), the Plaintiff " .. c ..
    " consent to the entry of final orders or judgment by the Bankruptcy Court.")), { after = CONSENT_BELOW })
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's body-blocks()
-- ---------------------------------------------------------------------------

-- The sample's body: the text after its frontmatter, split at blank lines.
local function chunks()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out
end

-- Headings single-spaced at the type size, kept with the text: level 1 centered bold, level 2 bold, level 3 bold
-- italic.
local function heading(t)
  local hashes, s = t:match("^(#+)%s+(.-)%s*$")
  local lvl = math.min(#hashes, 3)
  return p(xe.inl(md(s), { b = true, i = lvl == 3 }),
    { before = H_ABOVE[lvl], after = H_BELOW[lvl], jc = lvl == 1 and "center" or "left", keep = true })
end

local function body(out)
  for _, t in ipairs(chunks()) do
    local label, rest = t:match("^(%d+%.)[ \t]+(.*)$")
    if t:sub(1, 1) == "#" then
      out[#out + 1] = heading(t)
    elseif label then
      out[#out + 1] = p(xe.runs(label .. "\t") .. xe.inl(md(rest)),
        { line = BODY, left = NUMBER, hanging = NUMBER - INDENT, tab = NUMBER })
    else
      out[#out + 1] = p(xe.inl(md(t)), { line = BODY })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 5005-2(a)(1)(A): "/s/" followed by the printed name), kept on one page
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local ps = { { xe.runs("Dated: " .. plain(need(m, "dated"))), { before = SIG_ABOVE } } }
  for _, s in ipairs(need(m, "signers")) do
    ps[#ps + 1] = { xe.runs("/s/ " .. plain(s.signer)), { before = SIGNER_ABOVE, left = SIG } }
    for k, l in ipairs(items(s.lines)) do
      ps[#ps + 1] = { text(l), { before = k == 1 and SIGNER_GAP or 0, left = SIG } }
    end
  end
  for i, x in ipairs(ps) do
    x[2].keep = i < #ps
    out[#out + 1] = p(x[1], x[2])
  end
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  caption(m, out)
  consent(m, out)
  body(out)
  signature(m, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
