-- W.D. Okla. motion and brief in support, docx engine (docs/DOCX.md). The paper as Word paragraphs, so that it reads
-- and breaks as typst/okwd-motion-brief.typ does: the court title, the caption (party column, a column of ")" marks,
-- the case number and the jury demand), the title, the body (paragraphs indented on the first line, headings, lettered
-- or bulleted list items), the signature block (LCvR5.4) and the certificate of mailing (Fed. R. Civ. P. 5(b)(2)(C)).
-- Every case-specific word comes from the sample's frontmatter (read as written, $FORMBOOK_META) and body, never from
-- this file. Font, margins and the page number are in docx/reference.xml (fb render builds the reference document
-- from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 598 the double-spaced body, 299 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 598, 299            -- typst pitch-body 29.9 pt, pitch-single 14.95 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LABEL = 720                        -- typst label-box, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAREN = 4896, 432    -- typst caption-left 3.4 in, paren-w 0.3 in
local CAP_RIGHT_PAD = 432                -- typst caption-right-pad, 0.3 in
local DESIGNATION = 720                  -- typst designation-indent, 0.5 in
local SIG = 4896                         -- typst sig-left, 3.4 in
local COVER_GAP = 299                    -- typst cover-gap, 14.95 pt
local HEADING_ABOVE = 299                -- typst heading-above
local SIG_ABOVE, JURY_GAP = 299, 299     -- typst sig-above, jury-gap
local function read_file(path)
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

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

-- A doubled sign stays with its number (typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- No break at the space before a period (". . ."): Unicode line breaking, which typst follows, never breaks before a
-- full stop, even after a space; LibreOffice does.
local function bind_stops(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Space" and b.t == "Str" and b.text:match("^%.") then inl[i] = pandoc.Str("\u{00A0}") end
  end
  return inl
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(3)" or "A." lists).
local function md(s)
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return bind_stops(bind_doubled(pandoc.Inlines(pandoc.utils.blocks_to_inlines(doc.blocks)):walk({ Str = breaks })))
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

-- A line of plain text as written; "" is a blank line.
local function line(s, o) return p(s == "" and "" or xe.runs(s, o and o.run), o) end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local function cell(w, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function caption(c)
  local l, m, r = {}, {}, {}
  for k, party in ipairs(list(c.parties)) do
    if k > 1 then l[#l + 1] = line("v.") end
    for _, n in ipairs(list(party.names)) do l[#l + 1] = line(n) end
    l[#l + 1] = line(party.designation or "", { left = DESIGNATION })
  end
  for _ = 1, #l do m[#m + 1] = line(")", { jc = "center" }) end
  local cn = RAW.case_number or ""
  r[1] = line(cn == "" and "Case No. ____________" or cn, { left = CAP_RIGHT_PAD })
  if RAW.jury_demand == true then
    r[2] = line("JURY TRIAL DEMANDED", { before = JURY_GAP, left = CAP_RIGHT_PAD, run = { b = true } })
  end
  if #l == 0 then l[1] = p("") ; m[1] = p("") end
  local rest = TEXTW - CAP_LEFT - CAP_PAREN
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_PAREN .. '"/><w:gridCol w:w="' .. rest ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, l) .. cell(CAP_PAREN, m) .. cell(rest, r) .. '</w:tr></w:tbl>'
end

local function cover(out)
  out[#out + 1] = line("IN THE UNITED STATES DISTRICT COURT", { jc = "center", run = { b = true } })
  out[#out + 1] = line("FOR THE WESTERN DISTRICT OF OKLAHOMA", { jc = "center", run = { b = true } })
  out[#out + 1] = p("", { line = COVER_GAP })
  out[#out + 1] = caption(RAW.caption or {})
  out[#out + 1] = line(pandoc.text.upper(RAW.brief_title or ""), { before = COVER_GAP, jc = "center", run = { b = true } })
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's body-chunks()
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

-- A heading, bold and single-spaced, kept with the text after it (typst heading()): level 1 centered in capitals;
-- level 2 at the margin, its label in a 0.5 in box, its lines hanging after it; level 3 the same after the paragraph
-- indent, in bold italic.
local function heading(level, s, above, keep)
  local o = { before = math.max(above, HEADING_ABOVE), keep = keep }
  if level == 1 then
    o.jc = "center"
    return p(xe.inl(upper(md(s)), { b = true }), o)
  end
  local r = { b = true, i = level > 2 }
  local ind = level == 2 and 0 or INDENT
  local lab, rest
  for _, pat in ipairs({ "^([IVXLC]+)%.[ \t]+(.*)$", "^(%a)%.[ \t]+(.*)$", "^(%d+)%.[ \t]+(.*)$" }) do
    lab, rest = s:match(pat)
    if lab then break end
  end
  if not lab then
    o.left = ind
    return p(xe.inl(md(s), r), o)
  end
  o.left, o.hanging, o.tab = ind + LABEL, LABEL, ind + LABEL
  return p(xe.runs(lab .. ".\t", r) .. xe.inl(md(rest), r), o)
end

-- A body paragraph on the double pitch, its first line indented; a list item's label in a box after the indent, its
-- lines hanging under its text (typst body-par()).
local function body_par(inl, o)
  o = o or {}
  local q = { line = BODY, before = o.before or 0, keep = o.keep }
  if o.label then
    q.left, q.hanging, q.tab = INDENT + LABEL, LABEL, INDENT + LABEL
    return p(xe.runs(o.label .. "\t") .. xe.inl(inl), q)
  end
  q.first = INDENT
  return p(xe.inl(inl), q)
end

local function body(out)
  local cs = chunks()
  for i, t in ipairs(cs) do
    local a = i == 1 and COVER_GAP or 0
    local last = i == #cs
    local hashes, htext = t:match("^(#+)[ \t]+(.-)%s*$")
    if hashes then
      out[#out + 1] = heading(#hashes, htext, a, true)
    elseif t:match("^%d+%.[ \t]") or t:match("^[-*+][ \t]") then
      -- "1." items lettered A., B., ... by their number, "-" items bulleted; one paragraph per item
      local items = {}
      for l in (t .. "\n"):gmatch("(.-)\n") do
        local n, rest = l:match("^(%d+)%.[ \t]+(.*)$")
        local mark = n and (string.char(64 + tonumber(n)) .. ".") or nil
        if not n and l:match("^[-*+][ \t]") then mark, rest = "\u{2022}", l:match("^[-*+][ \t]+(.*)$") end
        if mark then items[#items + 1] = { mark, rest } else items[#items][2] = items[#items][2] .. "\n" .. l end
      end
      for k, it in ipairs(items) do
        out[#out + 1] = body_par(md(it[2]), { label = it[1], before = k == 1 and a or 0, keep = last and k == #items })
      end
    else
      out[#out + 1] = body_par(md(t), { before = a, keep = last })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate: single lines from 3.4 in, each kept on one page
-- ---------------------------------------------------------------------------

-- The paragraphs of one unbreakable block: each kept with the next, the last ending the chain.
local function kept(out, ls)
  for i, x in ipairs(ls) do
    if i == #ls then x = x:gsub(xe.KEEP, "", 1) end
    out[#out + 1] = x
  end
end

local function signature(out)
  local sig = RAW.signature or {}
  local ls = {}
  local date = RAW.date and ("Dated: " .. RAW.date) or ""
  ls[#ls + 1] = p(xe.runs(date .. "\tRespectfully submitted,"), { before = SIG_ABOVE, left = SIG, hanging = SIG,
    tab = SIG, keep = true })
  ls[#ls + 1] = p("", { keep = true })
  local firm = list(sig.firm)
  for _, l in ipairs(firm) do ls[#ls + 1] = line(l, { left = SIG, keep = true }) end
  if #firm > 0 then ls[#ls + 1] = p("", { keep = true }) end
  ls[#ls + 1] = line(sig.sign or "", { left = SIG, keep = true })
  for _, l in ipairs(list(sig.lines)) do ls[#ls + 1] = line(l, { left = SIG, keep = true }) end
  kept(out, ls)
end

local function certificate(out)
  local c = RAW.certificate
  if c == nil then return end
  local ls = {}
  ls[#ls + 1] = heading(1, c.title or "", SIG_ABOVE, true)
  ls[#ls + 1] = p(xe.inl(md(c.text or "")), { line = BODY, first = INDENT, keep = true })
  ls[#ls + 1] = p("", { keep = true })
  for _, l in ipairs(list(c.recipients)) do ls[#ls + 1] = line(l, { left = SIG, keep = true }) end
  ls[#ls + 1] = p("", { keep = true })
  ls[#ls + 1] = line(c.sign or "", { left = SIG, keep = true })
  for _, l in ipairs(list(c.lines)) do ls[#ls + 1] = line(l, { left = SIG, keep = true }) end
  kept(out, ls)
end

function Pandoc(doc)
  local out = {}
  cover(out)
  body(out)
  signature(out)
  certificate(out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
