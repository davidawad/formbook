-- California Superior Court notice of motion and motion with the memorandum of points and authorities, docx engine
-- (docs/DOCX.md): the paper as Word paragraphs, so that it reads and breaks as typst/calsuperct-motion-brief.typ does
-- (see ../README.md): pleading paper (CRC 2.108: 28 numbered lines of 24 pt, the numbers in a page-anchored frame of
-- the footer, the rules as page borders), the attorney block from line 1 left of center and the court title on line
-- 8 or below (CRC 2.111(1)-(3)), the caption with the papers combined, the hearing and the filing date (CRC
-- 2.111(4)-(7), 3.1110(b), 3.1112(c)), the notice and its signature block, the table of contents and the table of
-- authorities, each on its own page (CRC 3.1113(f)), the memorandum (headings, paragraphs, block quotations,
-- footnotes) and its signature block, and the footer (the page number, a printed line, the paper's title; CRC 2.109,
-- 2.110; FORMBOOK_FOOTERS, the last section FORMBOOK_FINAL). Every case word comes from the sample's frontmatter
-- (read as written, $FORMBOOK_META) and body, never from this file.
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines); a paragraph that refers to a footnote stays a pandoc paragraph (Body Text Note), so that pandoc writes the
-- note. Pages: fb render (tools/fb/src/docxpass.rs) finds the needles this filter writes (FORMBOOK_NEEDLES) in the
-- LibreOffice PDF and renders again with their pages (FORMBOOK_PAGES) until they settle: the contents' page of the
-- tables, the memorandum and each heading, and the authorities' pages of each `toa:` link. One numbering, Arabic
-- from page 1 (CRC 2.109).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered lines, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Word cannot put the text on
-- the next numbered line after a block of single lines whose height it alone knows (the caption's party column, a
-- block quotation): the filter counts their lines (docx/lib/measure.lua, the face's advances) and sets that space
-- itself, as typst measures it.

local xe = require("docx.xengine")
local measure = dofile(pandoc.path.join({ pandoc.path.directory(PANDOC_SCRIPT_FILE), "lib", "measure.lua" }))
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 240                -- typst pitch 24 pt, pitch-single 12 pt
local DROP = 192                             -- typst single-drop, 9.6 pt
local LINES = 28                             -- typst lines-per-page
local TOP, LEFT, RIGHT = 1440, 2160, 720     -- typst top-margin, left-margin, right-margin
local PAGE_H = 15840
local BOTTOM = PAGE_H - TOP - LINES * BODY   -- typst bottom-margin, 48 pt
local INDENT, TAB = 720, 720                 -- typst para-indent, heading-tab
local TEXTW = 9360                           -- 6.5 in
local CLERK = 7                              -- typst clerk-lines
local CAP_COL = 4680                         -- typst caption-col, 50 %
local CAP_INSET, CAP_RIGHT = 173, 288        -- typst caption-inset 0.12 in, caption-right 0.2 in
local CAP_FOOT, CAP_CLEAR = 120, 240         -- typst caption-foot 6 pt, caption-clear 12 pt
local RULE = 15                              -- the 0.75 pt rule under the party column, which Word adds to the row
local GAP = 240                              -- typst gap
local HEARING = 1080                         -- typst hearing-label, 0.75 in
local SPACE = 60                             -- typst space-indent, 0.25 em at 12 pt
local QUOTE = 720                            -- typst quote-inset 0.5 in
local SIG, SIG_NAME, SIG_RULE = 4464, 432, 3888 -- typst sig-col 3.1 in, sig-name 0.3 in, sig-rule 2.7 in
local TOC_COL, TOA_COL, TOA_IND = 720, 1080, 720 -- typst toc-col 0.5 in, toa-col 0.75 in, toa-indent 0.5 in
local PASSIM = 7                             -- typst passim-threshold
local SIZE = 12                              -- typst type-size, pt
local FOOT_SIZE, NUM_SIZE = 20, 24           -- typst footer-size 10 pt, number-size 12 pt (half points)
local FOOTER_GAP, RULE_LINE = 40, 80         -- typst footer-gap 2 pt; footer-rule-gap 4 pt
local NEEDLE_MAX = 60
local MEMO = "MEMORANDUM OF POINTS AND AUTHORITIES"

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

-- A doubled sign stays with its number ("§§ 7920.000"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, brk, tabs, frame, sz, nowidow };
-- single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.frame then props[#props + 1] = o.frame end
  if o.nowidow then props[#props + 1] = '<w:widowControl w:val="0"/>' end
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

local function tabs(t)
  local x = {}
  for _, s in ipairs(t) do
    x[#x + 1] = '<w:tab w:val="' .. s[1] .. '"' .. (s[3] and (' w:leader="' .. s[3] .. '"') or "") ..
      ' w:pos="' .. s[2] .. '"/>'
  end
  return "<w:tabs>" .. table.concat(x) .. "</w:tabs>"
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
    { line = RULE_LINE, tabs = tabs({ { "right", TEXTW } }), frame = below, sz = FOOT_SIZE })
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
  '<w:right w:val="single" w:sz="4" w:space="7" w:color="auto"/></w:pgBorders><w:pgNumType w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function needle(id, text, context, fallback)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = norm(fallback or text):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, "B", long, short }, "\t")
end

local pages = {}
local function load_pages()
  local s = read_file(os.getenv("FORMBOOK_PAGES"))
  if not s then return end
  for line in s:gmatch("[^\n]+") do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then pages[id] = label end
  end
end

local function page_of(id)
  return pages[id] or "0"
end

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
  return p(xe.inl(md(text), o.run), o), stringify(md(text)), o.left
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
  return n + #court
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
  local cellw = TEXTW - CAP_COL
  local right, ritems, gaps = { p("", { line = DROP }) }, {}, 0
  local function group(lines, bold, hearing)
    for k, l in ipairs(lines) do
      local o = { before = (k == 1 and #right > 1) and GAP or 0, run = { b = bold } }
      if o.before > 0 then gaps = gaps + 1 end
      if hearing and l[1] then
        o.left, o.hanging, o.tabs = HEARING, HEARING, tabs({ { "left", HEARING } })
        right[#right + 1] = p(xe.runs(l[1] .. "\t") .. xe.inl(md(l[2])), o)
        ritems[#ritems + 1] = { stringify(md(l[2])), HEARING, "regular" }
      else
        local x, text = cap_line(hearing and l[2] or l, o)
        right[#right + 1] = x
        ritems[#ritems + 1] = { text, 0, bold and "bold" or "regular" }
      end
    end
  end
  if cap.case_number ~= nil then group(list(cap.case_number), false) end
  group(list(need(cap, "title")), true)
  if cap.details ~= nil then group(list(cap.details), false) end
  local rows = {}
  for _, k in ipairs({ { "date", "Date:" }, { "time", "Time:" }, { "dept", "Dept.:" }, { "judge", "Judge:" } }) do
    if RAW.hearing ~= nil and RAW.hearing[k[1]] ~= nil then rows[#rows + 1] = { k[2], tostring(RAW.hearing[k[1]]) } end
  end
  if cap.action_filed ~= nil then rows[#rows + 1] = { nil, "Action Filed: " .. tostring(cap.action_filed) } end
  if #rows > 0 then group(rows, false, true) end
  if cap.concurrent ~= nil then group({ "[" .. tostring(cap.concurrent) .. "]" }, false) end
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
  local h = math.max(lh, rh + RULE)       -- Word adds the rule under the row to its height
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

local function chunks_of(body)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" and not c:match("^%[%^[^%]]+%]:") then out[#out + 1] = c end
  end
  return out
end

local SRC = assert(read_file(PANDOC_STATE.input_files[1])):gsub("\r", "")
local BODY_SRC = SRC:gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
local NOTES = {}
for id, text in ("\n" .. BODY_SRC):gmatch("\n%[%^([^%]]+)%]:[ \t]*([^\n]*)") do NOTES[id] = text end

-- the notice (before the memorandum's title line) and the memorandum
local function split_body()
  local s, e = ("\n" .. BODY_SRC):find("\n# " .. MEMO .. "[ \t]*\n")
  if not s then error("calsuperct.lua: the body needs exactly one line `# " .. MEMO .. "`", 0) end
  return BODY_SRC:sub(1, s - 1), BODY_SRC:sub(e)
end

local function has_note(inl)
  local found = false
  pandoc.Inlines(inl):walk({ Note = function() found = true end })
  return found
end

local function defs_of(t)
  local defs = ""
  for id in t:gmatch("%[%^([^%]]+)%]") do defs = defs .. "\n\n[^" .. id .. "]: " .. (NOTES[id] or "") end
  return defs
end

-- A heading's label typed by the author ("A.", "1.", "a.", "IV."), and the rest of its text (typst split-label).
local function split_label(t)
  local lab, rest = t:match("^(%a%a?%a?%a?%.)[ \t]+(.*)$")
  if not lab then lab, rest = t:match("^(%d%d?%d?%.)[ \t]+(.*)$") end
  return lab, rest or t
end

local function heading_of(t)
  local hashes, text = t:match("^(#+)[ \t]+(.-)%s*$")
  return #hashes, text
end

-- Headings on the numbered lines, bold, kept with the text: level 1 centered capitals; deeper levels with the
-- author's label in a box at the level's indent, the lines after the first hanging after it.
local function heading(level, t)
  if level == 1 then
    return p(xe.inl(upper(md(t)), { b = true }), { line = BODY, jc = "center", keep = true })
  end
  local lab, rest = split_label(t)
  local ind = (level - 1) * TAB
  local o = { b = true, i = level >= 4 }
  if not lab then return p(xe.inl(md(rest), o), { line = BODY, left = ind, keep = true }) end
  return p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(md(rest), o), { line = BODY, left = ind + TAB, hanging = TAB,
    tabs = tabs({ { "left", ind + TAB } }), keep = true })
end

-- The `toa:` links of a chunk in order, with the words after each (for its needle).
local hits, k_n = {}, 0
local function links(blocks, plain)
  pandoc.Blocks(blocks):walk({ Link = function(l)
    local key = l.target:match("^toa:(.+)$")
    if key then
      k_n = k_n + 1
      local id = "K:" .. k_n
      hits[key] = hits[key] or {}
      hits[key][#hits[key] + 1] = id
      local text = stringify(l.content)
      local at = plain:find(text, 1, true)
      needle(id, text, at and plain:sub(at + #text, at + #text + 40) or "")
    end
  end })
end

local function unlink(inl)
  return pandoc.Inlines(inl):walk({ Link = function(l) return l.content end })
end

-- A body paragraph; one that carries a footnote is left to pandoc (Body Text Note: the same pitch and indent, no
-- widow control), which writes the note.
local function bodypar(inl, keep)
  if has_note(inl) then
    if keep then error("calsuperct.lua: the last paragraph before a signature block carries a footnote", 0) end
    local c = unlink(inl):walk({ Inlines = function(l) return xe.inlines(l) end })
    return pandoc.Div({ pandoc.Para(c) }, { ["custom-style"] = "Body Text Note" })
  end
  return xe.raw(p(xe.inl(inl), { line = BODY, first = INDENT, keep = keep }))
end

-- Chunks as Word paragraphs; the last one kept with the signature block after it; `heads` collects the headings
-- (for the contents) and writes their needles.
local function body(res, src, heads)
  local cs = chunks_of(src)
  for i, t in ipairs(cs) do
    local defs = defs_of(t)
    local last = i == #cs
    if t:match("^#+[ \t]") then
      local level, text = heading_of(t)
      if heads then
        local id = "H:" .. (#heads + 1)
        heads[#heads + 1] = { id = id, level = level, text = text }
        -- pdftotext reads a heading's label in place but its text (a tab further in) after the line below it: the
        -- fallback is the label and the words after the heading
        local nxt = cs[i + 1] and stringify(md(cs[i + 1]):walk({ Note = function() return {} end })):sub(1, 30) or ""
        local lab = split_label(text)
        needle(id, text, nxt, lab and (lab .. " " .. nxt) or nil)
      end
      res[#res + 1] = xe.raw(heading(level, text))
    elseif t:sub(1, 1) == ">" then
      -- block quotation: single-spaced, 0.5 in in on both sides, its first line single-drop into the next numbered
      -- line, the text after it on the first numbered line half a single line clear of it (typst block-quote)
      local q = ("\n" .. t):gsub("\n>[ \t]?", "\n"):sub(2)
      local ps = {}
      for s in (q .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
        s = s:match("^%s*(.-)%s*$")
        if s ~= "" then ps[#ps + 1] = s end
      end
      local n = 0
      for _, s in ipairs(ps) do
        links(read(s), stringify(md(s)))
        n = n + measure.lines(stringify(md(s)), (TEXTW - 2 * QUOTE) / 20, SIZE, "regular")
      end
      for j, s in ipairs(ps) do
        local after = math.ceil((DROP + n * SINGLE + SINGLE / 2) / BODY - 0.001) * BODY - DROP - n * SINGLE
        res[#res + 1] = xe.raw(p(xe.inl(md(s .. defs)), { before = j == 1 and DROP or 0,
          after = j == #ps and after or 0, left = QUOTE, right = QUOTE,
          nowidow = true, keep = last }))
      end
    else
      links(read(t), stringify(md(t .. defs):walk({ Note = function() return {} end })))
      res[#res + 1] = bodypar(md(t .. defs), last)
    end
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
      o.left, o.tabs = col, tabs({ { "left", col + SIG_RULE } })
      res[#res + 1] = xe.raw(p(r[2], o))
    else
      o.left, o.hanging, o.tabs = col, col, tabs({ { "left", col } })
      res[#res + 1] = xe.raw(p(r[1] .. xe.runs("\t") .. r[2], o))
    end
  end
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities, each on its own page, rows on the numbered lines
-- ---------------------------------------------------------------------------

local function table_title(t)
  return p(xe.runs(t, { b = true }), { line = BODY, after = BODY, jc = "center", keep = true, brk = true })
end

-- A row (typst listing-row): the text from `first` with its later lines at `hang`, wrapping before the page column
-- `col`, a dot leader from three spaces after the text to the page.
local function row(text, page, first, hang, col, label_tab)
  local t = { { "right", TEXTW, "dot" } }
  if label_tab then table.insert(t, 1, { "left", label_tab }) end
  return p(text .. xe.runs(xe.LEAD) .. page, { line = BODY, left = hang, hanging = hang - first, right = col,
    tabs = tabs(t) })
end

local function contents(res, heads)
  res[#res + 1] = xe.raw(table_title("TABLE OF CONTENTS"))
  res[#res + 1] = xe.raw(row(xe.runs("TABLE OF AUTHORITIES"), xe.runs(page_of("T:toa")), 0, TAB, TOC_COL))
  res[#res + 1] = xe.raw(row(xe.runs(MEMO), xe.runs(page_of("T:memo")), 0, TAB, TOC_COL))
  for _, h in ipairs(heads) do
    local pg = xe.runs(page_of(h.id))
    if h.level == 1 then
      res[#res + 1] = xe.raw(row(xe.inl(upper(md(h.text))), pg, 0, TAB, TOC_COL))
    else
      local lab, rest = split_label(h.text)
      local ind = (h.level - 1) * TAB
      if lab then
        res[#res + 1] = xe.raw(row(xe.runs(lab .. "\t") .. xe.inl(md(rest)), pg, ind, ind + TAB, TOC_COL, ind + TAB))
      else
        res[#res + 1] = xe.raw(row(xe.inl(md(rest)), pg, ind, ind, TOC_COL))
      end
    end
  end
end

local GROUPS = { { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" } }

local function sort_key(a)
  return tostring(a.sort or a.name or a.cite or ""):lower()
end

local function authorities(res)
  res[#res + 1] = xe.raw(table_title("TABLE OF AUTHORITIES"))
  local first = true
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(RAW.authorities or {}) do
      if tostring(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
    if #members > 0 then
      res[#res + 1] = xe.raw(p(xe.runs(g[2], { b = true }), { line = BODY, keep = true, before = first and 0 or BODY }))
      first = false
      for _, m in ipairs(members) do
        local pgs, seen = {}, {}
        for _, id in ipairs(hits[m.key]) do
          local l = page_of(id)
          if not seen[l] then
            seen[l] = true
            pgs[#pgs + 1] = l
          end
        end
        local where = #pgs >= PASSIM and xe.runs("passim", { i = true }) or xe.runs(table.concat(pgs, ", "))
        local text = ""
        if m.a.name then text = xe.inl(md(m.a.name), { i = g[1] == "case" }) .. xe.runs(" ") end
        res[#res + 1] = xe.raw(row(text .. xe.inl(md(m.a.cite)), where, TOA_IND, 2 * TOA_IND, TOA_COL))
      end
    end
  end
  for key in pairs(hits) do
    if (RAW.authorities or {})[key] == nil then
      error("calsuperct.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter", 0)
    end
  end
end

-- The needle of the table of authorities: its title, its first group and its first entry (the contents name it too).
local function toa_needle()
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(RAW.authorities or {}) do
      if tostring(a.kind) == g[1] and hits[key] then members[#members + 1] = a end
    end
    table.sort(members, function(x, y) return sort_key(x) < sort_key(y) end)
    if #members > 0 then
      return "TABLE OF AUTHORITIES " .. g[2] .. " " .. stringify(md(members[1].name or members[1].cite))
    end
  end
  return "TABLE OF AUTHORITIES"
end

function Pandoc(doc)
  load_pages()
  local notice, memo = split_body()
  local out = {}
  local at = attorney(out)
  local pad = caption(out, at)
  out[#out + 1] = p("", { line = pad })
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end

  -- the notice of motion and its signature block
  body(res, notice, nil)
  signature(res)

  -- the memorandum, read first for its headings and links (their needles, in document order, after the tables')
  local mres, heads = {}, {}
  local memo_needles_at = #needles
  body(mres, memo, heads)
  local memo_first = chunks_of(memo)[1] or ""
  local mine = {}
  for i = memo_needles_at + 1, #needles do mine[#mine + 1] = needles[i] end
  for i = #needles, memo_needles_at + 1, -1 do needles[i] = nil end
  local attorneys = list(RAW.attorney)
  needle("S:1", tostring(attorneys[1] or ""), tostring(attorneys[2] or ""))
  needle("T:toa", toa_needle(), "")
  needle("T:memo", MEMO, memo_first:match("^#+[ \t]+(.*)$") or stringify(md(memo_first)):sub(1, 30))
  for _, n in ipairs(mine) do needles[#needles + 1] = n end
  needles[#needles + 1] = "#section\tS:1\tdecimal\t"

  contents(res, heads)
  authorities(res)
  res[#res + 1] = xe.raw(p(xe.runs(MEMO, { b = true }), { line = BODY, after = BODY, jc = "center", keep = true,
    brk = true }))
  for _, x in ipairs(mres) do res[#res + 1] = x end
  signature(res)

  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdCalsuperctPage\t" .. footer() .. "\n")
  write_file("FORMBOOK_FINAL", SECT)
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
