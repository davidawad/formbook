-- N.D. Okla. complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it reads and breaks as
-- typst/oknd-complaint.typ does: the court name, the caption (the party column ruled at its right and foot, the case
-- number beside it), the title and the jury notation (LCvR38-1), the lead-in, numbered paragraphs (Fed. R. Civ. P.
-- 10(b)), headings, lettered lists and the signature block. Every case-specific word comes from the sample's
-- frontmatter (read as written, $FORMBOOK_META) and body, never from this file. Font, margins and the page number are
-- in docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines number the same paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, the face's own double spacing, never
-- "Exactly 24 pt", LGnR2-4(a); 276 a single line), the spaces between blocks those of the typst template, and the
-- break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUMBER = 1440                      -- typst para-indent + number-box: a numbered paragraph's text, 1 in
local LABEL = 1296                       -- typst para-indent + label-box: a list item's text, 0.9 in
local TEXTW = 9360                       -- 6.5 in
local CAP_COL = 4680                     -- typst caption columns, 1fr each
local CAP_PAD = 273                      -- typst caption-pad 14.4 pt (288), less the 0.75 pt rule Word sets inside it
local CAP_FOOT = 225                     -- typst caption-foot 12 pt (240), less the rule
local CAP_RIGHT = 288                    -- typst caption-right-pad 14.4 pt
local DESIGNATION = 2592                 -- typst designation-indent, 1.8 in
local SIG = 4752                         -- the text width less typst sig-col (3.2 in): 3.3 in
local COURT_GAP, VERSUS_GAP = 552, 276   -- typst court-gap, versus-gap
local TITLE_ABOVE, JURY_ABOVE, TITLE_BELOW = 552, 276, 552 -- typst title-above, jury-above, title-below
local HEADING_GAP = 276                  -- typst heading-gap
local SIG_ABOVE, SIGNER_ABOVE = 552, 552 -- typst sig-above, signer-above

local function read_file(path)
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (pandoc's metadata would read "____" as emphasis).
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(key)
  if RAW[key] == nil then error("oknd-complaint: missing required metadata field `" .. key .. "`", 0) end
  return RAW[key]
end

local function list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 77l"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(3)" or "A." lists).
local function md(s)
  local doc = pandoc.read(tostring(s), "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return bind_doubled(pandoc.Inlines(pandoc.utils.blocks_to_inlines(doc.blocks)):walk({ Str = breaks }))
end

local function upper(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
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
-- Cover: court name, caption, title, jury notation
-- ---------------------------------------------------------------------------

local function caption()
  local sides = need("caption")
  local left = {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(list(side.names)) do left[#left + 1] = p(xe.inl(md(n))) end
    left[#left + 1] = p(xe.inl(md(side.designation or "")), { left = DESIGNATION })
    if i < #sides then
      left[#left + 1] = p(xe.runs("v."), { before = VERSUS_GAP, after = VERSUS_GAP, jc = "center" })
    end
  end
  if #left == 0 then left[1] = p("") end
  local rules = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  local right = '<w:tcMar><w:left w:w="' .. CAP_RIGHT .. '" w:type="dxa"/></w:tcMar><w:vAlign w:val="center"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_COL .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_COL) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_COL .. '" w:type="dxa"/>' .. rules .. '</w:tcPr>' .. table.concat(left) ..
    '</w:tc><w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_COL) .. '" w:type="dxa"/>' .. right .. '</w:tcPr>' ..
    p(xe.runs("Case No. " .. tostring(need("case_number")))) .. '</w:tc></w:tr></w:tbl>'
end

local function cover(out)
  out[#out + 1] = p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("NORTHERN DISTRICT OF OKLAHOMA", { b = true }), { jc = "center" })
  out[#out + 1] = p("", { line = COURT_GAP })
  out[#out + 1] = caption()
  out[#out + 1] = p(xe.inl(md(need("title")), { b = true }), { before = TITLE_ABOVE, jc = "center" })
  -- LCvR38-1: "Jury Trial Demanded" on the front page, immediately following the title.
  if RAW.jury_demand == true then
    out[#out + 1] = p(xe.runs("Jury Trial Demanded", { b = true }), { before = JURY_ABOVE, jc = "center" })
  end
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's document loop
-- ---------------------------------------------------------------------------

-- The sample's body: the text after its frontmatter, split at blank lines.
local function chunks()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out
end

local function is_list(t) return t:match("^%d+%.[ \t]") or t:match("^[-*+][ \t]") end

-- typst numbering("(a)", k): a .. z, then aa, ab, ...
local function letters(k)
  local s = ""
  while k > 0 do
    local r = (k - 1) % 26
    s = string.char(97 + r) .. s
    k = (k - 1 - r) // 26
  end
  return "(" .. s .. ")"
end

-- One chunk (typst: chunk()); above: the space above it, keep: kept with the next block.
local function chunk(t, num, above, keep, out)
  local hashes, htext = t:match("^(#+) (.*)$")
  if hashes and #hashes <= 3 then
    -- a heading on the single pitch, a blank single line above and below, kept with the text after it: level 1
    -- centred bold capitals, level 2 centred bold, level 3 bold italic at the margin
    local inl = md(htext)
    if #hashes == 1 then inl = upper(inl) end
    out[#out + 1] = p(xe.inl(inl, { b = true, i = #hashes == 3 }), { before = math.max(above, HEADING_GAP),
      after = HEADING_GAP, jc = #hashes == 3 and "left" or "center", keep = true })
  elseif is_list(t) then
    -- a list: lettered (a), (b), ... (a bullet as "•") at the indent, its lines hanging at 0.9 in
    local bullet = t:match("^[-*+]") ~= nil
    local items = {}
    for l in (t .. "\n"):gmatch("(.-)\n") do
      local rest = l:match("^%d+%.[ \t]+(.*)$") or l:match("^[-*+][ \t]+(.*)$")
      if rest then items[#items + 1] = rest elseif #items > 0 then items[#items] = items[#items] .. "\n" .. l end
    end
    for k, it in ipairs(items) do
      local lab = bullet and "\u{2022}" or letters(k)
      out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(md(it)), { line = BODY, before = k == 1 and above or 0,
        left = LABEL, hanging = LABEL - INDENT, tab = LABEL, keep = keep and k == #items })
    end
  elseif num then
    out[#out + 1] = p(xe.runs(num .. ".\t") .. xe.inl(md(t)), { line = BODY, before = above, first = INDENT,
      tab = NUMBER, keep = keep })
  else
    -- the prayer's lead-in (WHEREFORE ...): an indented paragraph, not a numbered allegation
    out[#out + 1] = p(xe.inl(md(t)), { line = BODY, before = above, first = INDENT, keep = keep })
  end
end

local function body(out)
  local cs = chunks()
  if RAW.lead_in ~= nil then
    out[#out + 1] = p(xe.inl(md(RAW.lead_in)), { line = BODY, before = TITLE_BELOW, first = INDENT })
  end
  local n = 0
  for i, t in ipairs(cs) do
    local para = t:sub(1, 1) ~= "#" and not is_list(t) and not t:match("^WHEREFORE")
    if para then n = n + 1 end
    chunk(t, para and n or nil, (i == 1 and RAW.lead_in == nil) and TITLE_BELOW or 0, i == #cs, out)
  end
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated:" at the left, "Respectfully submitted," and the signer's lines at 3.3 in, on one page
-- ---------------------------------------------------------------------------

local function signature(out)
  local sig = need("signature")
  local rows = { { xe.runs("Dated: " .. tostring(need("date"))), xe.runs("Respectfully submitted,"), SIG_ABOVE },
    { "", xe.inl(md("/s/ " .. tostring(sig.signer or ""))), SIGNER_ABOVE } }
  for _, l in ipairs(list(sig.lines)) do rows[#rows + 1] = { "", xe.inl(md(l)), 0 } end
  for i, r in ipairs(rows) do
    out[#out + 1] = p(r[1] .. xe.runs("\t") .. r[2], { before = r[3], left = SIG, hanging = SIG, tab = SIG,
      keep = i < #rows })
  end
end

function Pandoc(doc)
  local out = {}
  cover(out)
  body(out)
  signature(out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
