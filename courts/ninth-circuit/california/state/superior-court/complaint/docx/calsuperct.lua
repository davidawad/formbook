-- California Superior Court complaint, docx engine (docs/DOCX.md): the paper as Word paragraphs, so that it reads and
-- breaks as typst/calsuperct-complaint.typ does (see ../README.md): pleading paper (CRC 2.108: 28 numbered lines of
-- 24 pt, the numbers in a page-anchored frame of the footer, the rules as page borders), the attorney block from
-- line 1 left of center and the court title on line 8 or below (CRC 2.111(1)-(3)), the caption (CRC 2.111(4)-(9)),
-- the body (headings, paragraphs, footnotes), the signature block and the footer (the page number, a printed line,
-- the paper's title; CRC 2.109, 2.110; FORMBOOK_FOOTERS, the last section FORMBOOK_FINAL). Every case word comes
-- from the sample's frontmatter (read as written, $FORMBOOK_META) and body, never from this file.
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines); a paragraph that refers to a footnote stays a pandoc paragraph (Body Text Note), so that pandoc writes the
-- note.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered lines, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Word cannot put the body
-- on the next numbered line after the caption, whose party column wraps: the filter counts the column's lines
-- (docx/lib/measure.lua, the face's advances) and sets that space itself, as typst measures it.

local xe = require("docx.xengine")
local measure = dofile(pandoc.path.join({ pandoc.path.directory(PANDOC_SCRIPT_FILE), "lib", "measure.lua" }))

local BODY, SINGLE = 480, 240                -- typst pitch 24 pt, pitch-single 12 pt
local DROP = 192                             -- typst single-drop, 9.6 pt
local LINES = 28                             -- typst lines-per-page
local TOP, LEFT, RIGHT = 1440, 2160, 720     -- typst top-margin, left-margin, right-margin
local PAGE_H = 15840
local BOTTOM = PAGE_H - TOP - LINES * BODY   -- typst bottom-margin, 48 pt
local INDENT = 720                           -- typst para-indent
local TEXTW = 9360                           -- 6.5 in
local CLERK = 7                              -- typst clerk-lines
local CAP_COL = 4680                         -- typst caption-col, 50 %
local CAP_INSET, CAP_RIGHT = 173, 288        -- typst caption-inset 0.12 in, caption-right 0.2 in
local CAP_FOOT, CAP_CLEAR = 120, 240         -- typst caption-foot 6 pt, caption-clear 12 pt
local RULE = 15                              -- the 0.75 pt rule under the party column, which Word adds to the row
local GAP = 480                              -- typst gap
local SPACE = 60                             -- typst space-indent, 0.25 em at 12 pt
local SIG, SIG_NAME, SIG_RULE = 4464, 432, 3888 -- typst sig-col 3.1 in, sig-name 0.3 in, sig-rule 2.7 in
local SIZE = 12                              -- typst type-size, pt
local FOOT_SIZE, NUM_SIZE = 20, 24           -- typst footer-size 10 pt, number-size 12 pt (half points)
local FOOTER_GAP, RULE_LINE = 40, 80         -- typst footer-gap 2 pt; footer-rule-gap 4 pt + footer-rule-pad 0 pt

local function read_file(path)
  if path == nil or path == "" then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- The frontmatter as written (pandoc's metadata drops a caption line's leading spaces).
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(t, key)
  if t[key] == nil then error("calsuperct.lua: missing required metadata field `" .. key .. "`", 0) end
  return t[key]
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

-- A doubled sign stays with its number ("§§ 17200"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

local function fix(inl)
  return pandoc.Inlines(inl):walk({ Str = breaks, Inlines = bind_doubled })
end

-- Markdown text as blocks / inlines, read as typst's cmarker reads it (no "a)" or "A." lists).
local function read(s)
  return pandoc.read(tostring(s), "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS).blocks
end

local function md(s)
  return fix(pandoc.utils.blocks_to_inlines(read(s)))
end

local function upper(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tabs, frame, sz, nowidow }; single
-- pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.frame then props[#props + 1] = o.frame end
  if o.nowidow then props[#props + 1] = '<w:widowControl w:val="0"/>' end
  if o.border then props[#props + 1] = o.border end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.sz then
    props[#props + 1] = '<w:rPr><w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/></w:rPr>'
  end
  return xe.para(props, body or "")
end

local function tab(val, pos)
  return '<w:tabs><w:tab w:val="' .. val .. '" w:pos="' .. pos .. '"/></w:tabs>'
end

-- ---------------------------------------------------------------------------
-- Page furniture: the footer (the line numbers in a frame at the left margin, on the body's line boxes; the page
-- number; a printed line; the paper's title) and the last section (letter, the typst margins, the pleading rules:
-- a double rule left of the text, a single rule right of it).
-- ---------------------------------------------------------------------------

local function footer()
  local out = {}
  local frame = '<w:framePr w:w="' .. (LEFT - INDENT) .. '" w:h="' .. (LINES * BODY) .. '" w:hRule="exact" ' ..
    'w:wrap="notBeside" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="' .. TOP .. '"/>'
  for i = 1, LINES do out[#out + 1] = p(xe.runs(tostring(i)), { line = BODY, jc = "right", frame = frame }) end
  -- the page number and the title in a page-anchored frame of their own, footer-gap below the last numbered line: in
  -- the footer's flow LibreOffice grows the footer (it keeps the reference's 45 pt above it) into the 28th line
  local below = '<w:framePr w:w="' .. TEXTW .. '" w:wrap="notBeside" w:vAnchor="page" w:hAnchor="page" w:x="' ..
    LEFT .. '" w:y="' .. (PAGE_H - BOTTOM + FOOTER_GAP) .. '"/>'
  local r = '<w:r><w:rPr><w:sz w:val="' .. NUM_SIZE .. '"/><w:szCs w:val="' .. NUM_SIZE .. '"/></w:rPr>'
  out[#out + 1] = p(r .. '<w:fldChar w:fldCharType="begin"/></w:r>' .. r ..
    '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' .. r .. '<w:fldChar w:fldCharType="separate"/></w:r>' ..
    xe.runs("1", { sz = NUM_SIZE }) .. r .. '<w:fldChar w:fldCharType="end"/></w:r>',
    { line = SINGLE, jc = "center", sz = NUM_SIZE, frame = below })
  -- the printed line: an underlined tab across the text width in a line of its own (LibreOffice drops a framed
  -- paragraph's border)
  out[#out + 1] = p('<w:r><w:rPr><w:u w:val="single"/><w:sz w:val="' .. FOOT_SIZE .. '"/></w:rPr><w:tab/></w:r>',
    { line = RULE_LINE, tabs = tab("right", TEXTW), frame = below, sz = FOOT_SIZE })
  out[#out + 1] = p(xe.inl(upper(md(need(RAW, "footer_title"))), { sz = FOOT_SIZE }), { line = SINGLE,
    jc = "center", sz = FOOT_SIZE, frame = below })
  -- the frames' anchor: the footer's only line in the flow, 1 pt
  out[#out + 1] = p("", { line = 20 })
  return table.concat(out)
end

-- The footer's distance from the page edge (its flow holds no text: the frames above place it).
local FOOTER_DIST = 360

local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdCalsuperctPage"/>' ..
  '<w:pgSz w:w="12240" w:h="' .. PAGE_H .. '"/><w:pgMar w:top="' .. TOP .. '" w:right="' .. RIGHT .. '" w:bottom="' ..
  BOTTOM .. '" w:left="' .. LEFT .. '" w:header="720" w:footer="' .. FOOTER_DIST .. '" w:gutter="0"/>' ..
  '<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="auto"/>' ..
  '<w:right w:val="single" w:sz="4" w:space="7" w:color="auto"/></w:pgBorders></w:sectPr>'

-- ---------------------------------------------------------------------------
-- First page: attorney block, court title, caption
-- ---------------------------------------------------------------------------

-- A caption line as written: its leading spaces an indent (typst space-indent), an empty line a blank single line.
local function cap_line(s, o)
  s = tostring(s)
  local lead = #(s:match("^( *)"))
  local text = s:sub(lead + 1)
  o = o or {}
  o.left = (o.left or 0) + lead * SPACE
  if text:match("^%s*$") then return p("", o), "", o.left end
  return p(xe.inl(md(text), o.run), o), pandoc.utils.stringify(md(text)), o.left
end

-- The lines of a column of single lines, as typst breaks them (measure.lua): items of { text, indent, face }.
local function count(items, width)
  local n = 0
  for _, it in ipairs(items) do n = n + measure.lines(it[1], (width - it[2]) / 20, SIZE, it[3]) end
  return n
end

-- Lines 1 to 7 at least (CRC 2.111(1)-(2)): one line per item (typst stops on an item that does not fit left of
-- center), the court title on the first numbered line after them.
local function attorney(out)
  local items = list(need(RAW, "attorney"))
  out[#out + 1] = p("", { line = DROP })
  for _, l in ipairs(items) do out[#out + 1] = (cap_line(l)) end
  local n = math.max(CLERK, math.ceil((DROP + #items * SINGLE) / BODY))
  local court = list(need(RAW, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(md(l), { b = true }), { line = BODY, jc = "center",
      before = i == 1 and (n * BODY - DROP - #items * SINGLE) or 0, after = i == #court and BODY or 0 })
  end
  return n + #list(RAW.court)
end

-- The caption, a numbered line below the court title (`at`: the numbered lines above it); returns the space from
-- its foot to the first numbered line at least CAP_CLEAR below it.
local function caption(out, at)
  local cap = need(RAW, "caption")
  local left, litems = { p("", { line = DROP }) }, {}
  for _, l in ipairs(list(cap.left)) do
    local x, text, ind = cap_line(l, { nowidow = true })
    left[#left + 1] = x
    litems[#litems + 1] = { text, ind, "regular" }
  end
  left[#left + 1] = p("", { line = CAP_FOOT - RULE })
  local right, ritems, gaps = { p("", { line = DROP }) }, {}, 0
  for _, g in ipairs({ { "case_number", false }, { "title", true }, { "details", false }, { "amount_demanded", false } }) do
    if cap[g[1]] ~= nil then
      for k, l in ipairs(list(cap[g[1]])) do
        local o = { before = (k == 1 and #right > 1) and GAP or 0, run = { b = g[2] } }
        if o.before > 0 then gaps = gaps + 1 end
        local x, text = cap_line(l, o)
        right[#right + 1] = x
        ritems[#ritems + 1] = { text, 0, g[2] and "bold" or "regular" }
      end
    end
  end
  local cellw = TEXTW - CAP_COL
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_COL .. '"/><w:gridCol w:w="' .. cellw .. '"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_COL .. '" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" ' ..
    'w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(left) ..
    '</w:tc><w:tc><w:tcPr><w:tcW w:w="' .. cellw .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_RIGHT ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- where the caption ends: the taller column, run over the page end a line at a time
  local top = TOP + (at + 1) * BODY
  local lh = DROP + count(litems, CAP_COL - CAP_INSET) * SINGLE + CAP_FOOT
  local rh = DROP + count(ritems, cellw - CAP_RIGHT) * SINGLE + gaps * GAP
  local h = math.max(lh, rh)
  local foot = PAGE_H - BOTTOM
  local y = top + h
  if y > foot then
    local fit = math.floor((foot - top - DROP) / SINGLE)
    y = TOP + (lh - DROP - CAP_FOOT - fit * SINGLE) + CAP_FOOT
  end
  local k = math.ceil((y + CAP_CLEAR - TOP) / BODY - 0.001)
  return TOP + k * BODY - y
end

-- ---------------------------------------------------------------------------
-- The body: the chunks of typst's body-pieces()
-- ---------------------------------------------------------------------------

local function chunks()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out, "\n" .. body
end

local function has_note(inl)
  local found = false
  pandoc.Inlines(inl):walk({ Note = function() found = true end })
  return found
end

-- Headings, one numbered line each, kept with the text: levels 1 and 2 centered bold capitals, level 3 bold, deeper
-- levels bold italic.
local function heading(t)
  local b = read(t)[1]
  local inl = fix(b.content)
  if b.level <= 2 then
    return p(xe.inl(upper(inl), { b = true }), { line = BODY, jc = "center", keep = true })
  end
  return p(xe.inl(inl, { b = true, i = b.level > 3 }), { line = BODY, keep = true })
end

-- A body paragraph; one that carries a footnote is left to pandoc (Body Text Note: the same pitch and indent,
-- no widow control), which writes the note.
local function bodypar(inl, keep)
  if has_note(inl) then
    local c = pandoc.Inlines(inl):walk({ Inlines = function(l) return xe.inlines(l) end })
    if keep then error("calsuperct.lua: the last paragraph before the signature block carries a footnote", 0) end
    return pandoc.Div({ pandoc.Para(c) }, { ["custom-style"] = "Body Text Note" })
  end
  return xe.raw(p(xe.inl(inl), { line = BODY, first = INDENT, keep = keep }))
end

local function body(res)
  local cs, src = chunks()
  local notes = {}
  for id, text in src:gmatch("\n%[%^([^%]]+)%]:[ \t]*([^\n]*)") do notes[id] = text end
  local kept = {}
  for _, c in ipairs(cs) do if not c:match("^%[%^[^%]]+%]:") then kept[#kept + 1] = c end end
  for i, t in ipairs(kept) do
    local defs = ""
    for id in t:gmatch("%[%^([^%]]+)%]") do defs = defs .. "\n\n[^" .. id .. "]: " .. (notes[id] or "") end
    local last = i == #kept and RAW.jury_demand == nil
    if t:sub(1, 1) == "#" then
      res[#res + 1] = xe.raw(heading(t))
    else
      res[#res + 1] = bodypar(md(t .. defs), last)
    end
  end
  if RAW.jury_demand ~= nil then
    res[#res + 1] = xe.raw(p(xe.inl(upper(md(RAW.jury_demand)), { b = true }), { line = BODY, before = BODY,
      jc = "center", keep = true }))
  end
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated:" at the margin, the rest in the signature column, a numbered line below the text; kept
-- on one page with the last block.
-- ---------------------------------------------------------------------------

local function signature(res)
  local sig = need(RAW, "signature")
  local rows = {}
  local dated = sig.dated ~= nil and (xe.runs("Dated: ") .. xe.inl(md(sig.dated))) or ""
  local lines = list(sig.lines)
  for k, l in ipairs(lines) do rows[#rows + 1] = { k == 1 and dated or "", xe.inl(md(l)), 0, 0 } end
  if #lines == 0 then rows[#rows + 1] = { dated, "", 0, 0 } end
  rows[#rows + 1] = { "", xe.runs("By: ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>', BODY, 0, true }
  rows[#rows + 1] = { "", xe.inl(upper(md(need(sig, "signer"))), { b = true }), 0, SIG_NAME }
  if sig.role ~= nil then rows[#rows + 1] = { "", xe.inl(md(sig.role)), 0, SIG_NAME } end
  for i, r in ipairs(rows) do
    local col = SIG + r[4]
    local o = { before = i == 1 and (BODY + DROP) or r[3], keep = i < #rows }
    if r[5] then
      o.left, o.tabs = col, tab("left", col + SIG_RULE)
      res[#res + 1] = xe.raw(p(r[2], o))
    else
      o.left, o.hanging, o.tabs = col, col, tab("left", col)
      res[#res + 1] = xe.raw(p(r[1] .. xe.runs("\t") .. r[2], o))
    end
  end
end

function Pandoc(doc)
  local out = {}
  local at = attorney(out)
  local pad = caption(out, at)
  out[#out + 1] = p("", { line = pad })
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  body(res)
  signature(res)
  write_file("FORMBOOK_FOOTERS", "rIdCalsuperctPage\t" .. footer() .. "\n")
  write_file("FORMBOOK_FINAL", SECT)
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
