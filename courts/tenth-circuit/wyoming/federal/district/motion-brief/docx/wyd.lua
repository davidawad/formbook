-- D. Wyo. motion brief, docx engine (docs/DOCX.md). The memorandum as Word paragraphs, so that it reads and breaks as
-- typst/wyd-motion-brief.typ does: the attorney information block (LR 10.1(b)), the court name, the caption (party
-- column, a column of ")" marks, the case number level with the separator; Fed. R. Civ. P. 10(a)), the title, the
-- headings ("I." and "A." hanging, others centered), the paragraphs, the numbered relief list, the signature block and
-- the certificate of service. Every case-specific word comes from the sample's frontmatter (read as written,
-- $FORMBOOK_META) and body, never from this file. Font, margins and the page number are in docx/reference.xml (fb
-- render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local ITEM = 1224                        -- typst para-indent + item-box: the text after a list number, 0.85 in
local H1, H2 = 720, 1296                 -- typst h1-box (0.5 in), para-indent + h2-box (0.9 in): a heading's text
local TEXTW = 9360                       -- 6.5 in
local GUTTER = 432                       -- typst attorney-gutter, 0.3 in
local CAP_LEFT, CAP_MID = 4464, 504      -- typst caption-left 3.1 in, caption-mid 0.35 in
local DESIGNATION = 1440                 -- typst designation-indent, 1 in
local SIG = 3600                         -- typst sig-left, 2.5 in
local COURT_ABOVE, CAPTION_ABOVE, TITLE_ABOVE, TITLE_BELOW = 360, 360, 360, 240 -- typst court-above, caption-above, title-above, title-below
local HEADING_ABOVE = 240                -- typst heading-above, 12 pt
local SIG_ABOVE, SIG_GAP, SIG_BLANK = 480, 480, 552 -- typst sig-above, sig-gap, sig-blank (two single lines)
local CERT_ABOVE, CERT_GAP = 480, 240    -- typst cert-above, cert-gap
local COURT = { "UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF WYOMING" }

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

-- Line breaks inside a web address (as courts/tenth-circuit/court-of-appeals/reply-brief/docx/ca10.lua). typst
-- breaks a word that holds "http://" or "https://" (from there to the end of the word, less trailing punctuation)
-- where the class of character changes: letter, digit, opening bracket, other; after an "other" character before
-- anything, and between a letter and a digit either way, never after an opening bracket; a piece of 16 characters or
-- more breaks after any character. LibreOffice breaks such a word by Unicode rules: the typst places get a zero-width
-- space.
local ZWSP = "\u{200B}"

local function url_cuts(link)
  local function class(c)
    if c:match("^%a$") or #c > 1 then return "A" end
    if c:match("^%d$") then return "D" end
    if c == "(" or c == "[" then return "O" end
    return "X"
  end
  local cuts, starts = {}, {}
  for q in utf8.codes(link) do starts[#starts + 1] = q - 1 end
  local offset, prev = 0, "X"
  for i, b in ipairs(starts) do
    local c = link:sub(b + 1, starts[i + 1] or #link)
    local cl = class(c)
    if b > 0 and prev ~= "O" and ((cl == "X" and prev == "X") or (cl ~= "X" and cl ~= prev)) then
      if b - offset >= 16 then
        for _, q in ipairs(starts) do if q > offset and q < b then cuts[q] = true end end
      end
      cuts[b] = true
      offset = b
    end
    prev = cl
  end
  return cuts
end

local function url_breaks(text)
  local at = text:find("https?://")
  if not at then return nil end
  local tail_at = #text + 1
  while tail_at > at and text:sub(tail_at - 1, tail_at - 1):match("[.,;:!?]") do tail_at = tail_at - 1 end
  local link = text:sub(at, tail_at - 1)
  local keys = {}
  for k in pairs(url_cuts(link)) do keys[#keys + 1] = k end
  table.sort(keys)
  local out, from = {}, 1
  for _, k in ipairs(keys) do
    out[#out + 1] = link:sub(from, k)
    from = k + 1
  end
  out[#out + 1] = link:sub(from)
  return text:sub(1, at - 1) .. table.concat(out, ZWSP) .. text:sub(tail_at)
end

-- typst's break opportunities that LibreOffice does not share: those inside a web address (above); none inside ")("
-- (a word joiner); one after a slash before a letter (a zero-width space). None shows in the PDF text.
local function breaks(s)
  local t = url_breaks(s.text)
  if t == nil then t = s.text:gsub("/([^/%d%s])", "/" .. ZWSP .. "%1") end
  t = t:gsub("%)%(", ")\u{2060}(")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 17-29"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
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

-- A single line of inline markdown; "" is a blank line.
local function mline(s, o) return p((s == nil or s == "") and "" or xe.inl(md(s), o and o.r), o) end

-- ---------------------------------------------------------------------------
-- First page: attorney information block, court name, caption, title
-- ---------------------------------------------------------------------------

local function cell(w, ps)
  if #ps == 0 then ps = { p("") } end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

-- A borderless table of fixed columns, no cell margins; rows: a list of rows, each a list of cell XML.
local function tbl(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local trs = {}
  for _, r in ipairs(rows) do trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(r) .. '</w:tr>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>' .. table.concat(grid) ..
    '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- LR 10.1(b): one column per firm group, each line single spaced.
local function attorney_block(out)
  local groups = list(RAW.attorney)
  local n = #groups
  if n == 0 then return end
  local w = (TEXTW - GUTTER * (n - 1)) // n
  local widths, cells = {}, {}
  for g, group in ipairs(groups) do
    if g > 1 then
      widths[#widths + 1] = GUTTER
      cells[#cells + 1] = cell(GUTTER, {})
    end
    widths[#widths + 1] = w
    local ps = {}
    for _, l in ipairs(list(group)) do ps[#ps + 1] = mline(l) end
    cells[#cells + 1] = cell(w, ps)
  end
  out[#out + 1] = tbl(widths, { cells })
end


local function caption(out)
  local c = RAW.caption or {}
  local sep = c.separator or "v."
  local rows = {}   -- { text, is-designation }
  local sep_row
  for k, party in ipairs(list(c.parties)) do
    if k > 1 then
      if sep_row == nil then sep_row = #rows + 2 end
      rows[#rows + 1] = { "", false }
      rows[#rows + 1] = { sep, false }
      rows[#rows + 1] = { "", false }
    end
    for _, nm in ipairs(list(party.names)) do rows[#rows + 1] = { nm, false } end
    rows[#rows + 1] = { party.designation or "", true }
  end
  local case_row = sep_row or 1
  local right_w = TEXTW - CAP_LEFT - CAP_MID
  local trs = {}
  for i, r in ipairs(rows) do
    trs[#trs + 1] = {
      cell(CAP_LEFT, { mline(r[1], { left = r[2] and DESIGNATION or 0 }) }),
      cell(CAP_MID, { p(xe.runs(")")) }),
      cell(right_w, { i == case_row and p(xe.runs("Case No. " .. (RAW.case_number or ""))) or p("") }),
    }
  end
  -- the space above the caption: an empty paragraph of that height (a table carries no spacing of its own)
  out[#out + 1] = p("", { line = CAPTION_ABOVE })
  out[#out + 1] = tbl({ CAP_LEFT, CAP_MID, right_w }, trs)
end

local function first_page(out)
  attorney_block(out)
  out[#out + 1] = p(xe.runs(COURT[1], { b = true }), { before = COURT_ABOVE, jc = "center" })
  out[#out + 1] = p(xe.runs(COURT[2], { b = true }), { jc = "center" })
  caption(out)
  -- the title on the body pitch, centered, bold capitals, kept with the body
  out[#out + 1] = p(xe.inl(upper(md(RAW.title or "")), { b = true }), { line = BODY, before = TITLE_ABOVE, jc = "center",
    keep = true })
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


-- A heading on the body pitch, bold, kept with the text after it: "I. Title" with "I." at the margin in a 0.5 in box,
-- "A. Title" with "A." at 0.5 in in a 0.4 in box, the lines hanging after the box; any other heading centered.
local function heading(level, title, above)
  local o = { line = BODY, before = math.max(above, HEADING_ABOVE), keep = true }
  local num, rest = title:match("^([IVXL]+%.)[ \t]+(.*)$")
  if not num then num, rest = title:match("^([A-Z]%.)[ \t]+(.*)$") end
  if num then
    local at = level == 1 and H1 or H2
    o.left, o.hanging, o.tab = at, level == 1 and H1 or (H2 - INDENT), at
    return p(xe.runs(num .. "\t", { b = true }) .. xe.inl(md(rest), { b = true }), o)
  end
  o.jc = "center"
  return p(xe.inl(md(title), { b = true }), o)
end

local function body(out)
  local cs = chunks()
  for i, t in ipairs(cs) do
    local above = i == 1 and TITLE_BELOW or 0
    local keep = i == #cs
    local hashes, htext = t:match("^(#+)%s*(.-)$")
    if hashes then
      out[#out + 1] = heading(#hashes, htext, above)
    elseif t:match("^%d+%.[ \t]") then
      -- a numbered list as written: the number in a box after the indent, the lines hanging at 0.85 in
      local items = {}
      for l in (t .. "\n"):gmatch("(.-)\n") do
        if l:match("^%s*$") then
        elseif l:match("^%d+%.[ \t]") then
          local num, rest = l:match("^(%d+)%.[ \t]+(.*)$")
          items[#items + 1] = { num, rest }
        else items[#items][2] = items[#items][2] .. " " .. l:match("^%s*(.-)%s*$") end
      end
      for k, it in ipairs(items) do
        out[#out + 1] = p(xe.runs(it[1] .. ".\t") .. xe.inl(md(it[2])), { line = BODY,
          before = k == 1 and above or 0, left = ITEM, hanging = ITEM - INDENT, tab = ITEM, keep = keep and k == #items })
      end
    else
      out[#out + 1] = p(xe.inl(md(t)), { line = BODY, before = above, first = INDENT, keep = keep })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature block: the date line, then from 2.5 in "Respectfully submitted,", the "/s/" line, the signer's lines and
-- the role, kept on one page; the certificate of service after it, kept on one page
-- ---------------------------------------------------------------------------

local function signature(out)
  local sig = RAW.signature or {}
  out[#out + 1] = mline(RAW.dated or "", { before = SIG_ABOVE, keep = true })
  out[#out + 1] = p(xe.runs("Respectfully submitted,"), { before = SIG_GAP, left = SIG, keep = true })
  local lines = { "/s/ " .. (sig.signer or "") }
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = l end
  local role = list(sig.role)
  for i, l in ipairs(lines) do
    out[#out + 1] = mline(l, { before = i == 1 and SIG_BLANK or 0, left = SIG, keep = i < #lines or #role > 0 })
  end
  for i, l in ipairs(role) do
    out[#out + 1] = mline(l, { before = i == 1 and SIG_BLANK or 0, left = SIG, keep = i < #role })
  end
end

local function certificate(out)
  local c = RAW.certificate
  if c == nil then return end
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { line = BODY, before = CERT_ABOVE, jc = "center",
    keep = true })
  out[#out + 1] = p(xe.inl(md(c.text or "")), { line = BODY, before = CERT_GAP, first = INDENT, keep = true })
  for i, l in ipairs(list(c.served)) do
    out[#out + 1] = mline(l, { before = i == 1 and CERT_GAP or 0, left = INDENT, keep = true })
  end
  out[#out + 1] = mline("/s/ " .. (c.signer or ""), { before = BODY, left = SIG })
end

function Pandoc(doc)
  local out = {}
  first_page(out)
  body(out)
  signature(out)
  certificate(out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
