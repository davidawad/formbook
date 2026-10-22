-- Pandoc filter for the wvsd complaint, engine docx, so that it reads and breaks as typst/wvsd-complaint.typ does:
--  * the cover (its own section, no page number): court title, caption, title of the paper;
--  * the table of contents when `toc: true` (its own section, numbered i, ii, ...);
--  * the body (its own section, numbered from 1): the lead-in, numbered allegations (Fed. R. Civ. P. 10(b)),
--    headings numbered by the template, footnotes, the signature block with the date beside its last line, and the
--    verification on a page of its own.
-- Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Allegations, lists,
-- quotations and footnotes are written by pandoc in the styles of docx/reference.xml; everything else here.
--
-- Page numbers of the contents: fb render (tools/fb/src/docxpass.rs) finds the needles this filter writes
-- (FORMBOOK_NEEDLES: the lead-in, then every heading with the words after it, in document order) in the LibreOffice
-- PDF and renders again with their pages (FORMBOOK_PAGES) until they settle; the body's numbering starts at the
-- page of the first needle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local H1_ABOVE, H_ABOVE, H_BELOW = 360, 240, 240 -- typst h1-above 18 pt, h-above, h-below 12 pt
local INDENT = 720                       -- typst para-indent and num-box, 0.5 in
local TAB = 720                          -- typst heading-tab, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local PARTY, PAREN = 5328, 432           -- typst caption-left 3.7 in, caption-paren 0.3 in
local RIGHT_PAD = 288                    -- typst caption-right-pad 0.2 in
local BLOCK = 4680                       -- typst block-indent 3.25 in
local TOC_COL, TOC_GAP = 720, 120        -- typst toc-col 36 pt, toc-gap 6 pt
local SIG_ABOVE = 480                    -- 24 pt above the signature block
local EXEC_ABOVE, VSIG_ABOVE = 240, 720  -- verification: 12 pt above "Executed on", 36 pt above the signature
local FOOTER = 732                       -- the page number's line 36.6 pt above the page foot (typst footer-descent 30 %)
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

local function as_bool(v) return v == true or (v ~= nil and v ~= false and plain(v) == "true") end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function left_tab(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

-- Single-spaced lines at `left` (an empty one is a blank line: the next stands a single line lower), `above`
-- before the first, kept together; `last`, if given, stands at the left margin on the line of the last entry.
local function sig_lines(list, out, o)
  local skip = o.above or 0
  local ls = {}
  for _, l in ipairs(list or {}) do
    if plain(l) == "" then skip = skip + SINGLE else
      ls[#ls + 1] = { l, skip }
      skip = 0
    end
  end
  for i, l in ipairs(ls) do
    if o.last and i == #ls then
      out[#out + 1] = p(xe.inl(o.last) .. xe.runs("\t") .. xe.inl(l[1]), { before = l[2], tabs = left_tab(o.left) })
    else
      out[#out + 1] = p(xe.inl(l[1]), { before = l[2], left = o.left, keep = i < #ls })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, "B", long, short:sub(1, NEEDLE_MAX) }, "\t")
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Sections
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr>' .. xe.spacing(0, 0, 20) .. sect_pr(footer, fmt) .. '</w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

-- Caption: a borderless three-column table, one row per line of the party column, ")" in the middle, the case
-- number and judge in the rows at the middle of the caption (typst caption()).
local function caption(meta, out)
  local rows = {}
  local sides = meta.caption or {}
  for k, side in ipairs(sides) do
    local lead = side.lead
    if lead == nil then lead = k == 1 and "" or "v." end
    if plain(lead) ~= "" then rows[#rows + 1] = { 720, lead } end
    for _, n in ipairs(side.names or {}) do rows[#rows + 1] = { 0, n } end
    rows[#rows + 1] = { 1440, side.designation }
    if k < #sides then rows[#rows + 1] = false end
  end
  local right = {}
  if meta.civil_action then right[#right + 1] = meta.civil_action end
  if meta.judge then right[#right + 1] = meta.judge end
  local first = (#rows - #right) // 2
  local function cell(w, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
  end
  local trs = {}
  for i, r in ipairs(rows) do
    local j = i - 1 - first
    local rt = right[j + 1]
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      cell(PARTY, r and p(xe.inl(r[2]), { left = r[1] }) or p("")) ..
      cell(PAREN, p(xe.runs(")"))) ..
      cell(TEXTW - PARTY - PAREN, (j >= 0 and rt) and p(xe.inl(rt), { left = RIGHT_PAD }) or p("")) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. PARTY .. '"/><w:gridCol w:w="' .. PAREN .. '"/><w:gridCol w:w="' ..
    (TEXTW - PARTY - PAREN) .. '"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local function cover(meta, out)
  local court = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF WEST VIRGINIA",
    pandoc.text.upper(plain(meta.division)) }
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  caption(meta, out)
  -- the title: Word has no space after a table, so it takes the space before it
  out[#out + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = BODY, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Headings and contents
-- ---------------------------------------------------------------------------

local function roman(n, lower)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return lower and s:lower() or s
end

-- typst heading-numbering: I., A., 1., (i), (1), (A).
local function heading_label(level, k)
  if level == 1 then return roman(k) .. "." end
  if level == 2 then return string.char(64 + k) .. "." end
  if level == 3 then return k .. "." end
  if level == 4 then return "(" .. roman(k, true) .. ")" end
  if level == 5 then return "(" .. k .. ")" end
  return "(" .. string.char(64 + k) .. ")"
end

-- Headings single-spaced, 12 pt, bold to level 3: the number in a box at the level's indent, the text hanging
-- after it; kept with the text.
local function heading(level, label, content, before)
  local o = { b = level <= 3 }
  local at = (level - 1) * TAB + TAB
  return p(xe.runs(label .. "\t", o) .. xe.inl(content, o),
    { before = before, after = H_BELOW, left = at, hanging = TAB, tabs = left_tab(at), keep = true })
end

-- Contents: the number in its box at the heading's indent, the title hanging after it, the page in its column.
local function contents(entries, depth, out)
  out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", after = H_BELOW, keep = true })
  for _, e in ipairs(entries) do
    if e.level <= depth then
      local at = (e.level - 1) * TAB + TAB
      out[#out + 1] = p(xe.runs(e.label .. "\t") .. xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
        { lines = true, before = TOC_GAP, left = at, hanging = TAB, right = TOC_COL,
          tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. at .. '"/><w:tab w:val="right" w:leader="dot" w:pos="' ..
            TEXTW .. '"/></w:tabs>' })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Verification (28 U.S.C. § 1746), on a page of its own
-- ---------------------------------------------------------------------------

local function verification(v, out)
  out[#out + 1] = p(xe.inl(v.heading, { b = true, u = true }), { jc = "center", after = H_BELOW, brk = true, keep = true })
  out[#out + 1] = p(xe.inl(v.lead), { line = BODY })
  for k, item in ipairs(v.items or {}) do
    out[#out + 1] = p(xe.runs(k .. ".\t") .. xe.inl(item), { line = BODY, left = INDENT, tabs = left_tab(2 * INDENT) })
  end
  out[#out + 1] = p(xe.runs("Executed on ") .. xe.inl(v.executed) .. xe.runs("."), { line = BODY, before = EXEC_ABOVE })
  sig_lines(v.signature, out, { left = BLOCK, above = VSIG_ABOVE })
end

-- ---------------------------------------------------------------------------
-- Break rules
-- ---------------------------------------------------------------------------

-- In a web address typst also breaks after "//" and after each "/", ".", "-", "_", "?", "=", "&", "#" inside it:
-- a zero-width space there too.
local function url_breaks(u)
  local head, rest = u:match("^(%a+://)(.*)$")
  rest = rest:gsub("([/%.%-_%?=&#])(.)", "%1\u{200B}%2")
  return head .. "\u{200B}" .. rest
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text
  local a, b = t:find("%a+://%S*")
  if a then
    return pandoc.Str(t:sub(1, a - 1) .. url_breaks(t:sub(a, b)) .. t:sub(b + 1))
  end
  return pandoc.Str((t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1331": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local toc = as_bool(meta.toc)
  local depth = tonumber(plain(meta.toc_depth or "2")) or 2

  local body = {}
  local function raw(list)
    for _, x in ipairs(list) do body[#body + 1] = xe.raw(x) end
  end

  -- the lead-in: the address to the court flush left, the paragraphs after it indented
  local lead = {}
  for k, l in ipairs(meta.lead_in or {}) do
    if k == 1 then
      need("L:1", plain(l), meta.lead_in[2] and plain(meta.lead_in[2]):sub(1, 40) or "")
    end
    lead[#lead + 1] = p(xe.inl(l), { line = BODY, first = k == 1 and 0 or INDENT })
  end
  raw(lead)

  local blocks = doc.blocks
  -- each block as printed (its number or label first), for the words after a heading's needle
  local printed = {}
  do
    local c, k = { 0, 0, 0, 0, 0, 0 }, 0
    for i, b in ipairs(blocks) do
      if b.t == "Header" then
        local lv = math.min(b.level, 6)
        c[lv] = c[lv] + 1
        for j = lv + 1, #c do c[j] = 0 end
        printed[i] = heading_label(lv, c[lv]) .. " " .. stringify(b.content)
      elseif b.t == "Para" or b.t == "Plain" then
        k = k + 1
        printed[i] = k .. ". " .. stringify(b.content)
      else
        printed[i] = stringify(b)
      end
    end
  end
  local entries = {}
  local counts = { 0, 0, 0, 0, 0, 0 }
  local n, h = 0, 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = math.min(b.level, 6)
      counts[lv] = counts[lv] + 1
      for j = lv + 1, #counts do counts[j] = 0 end
      h = h + 1
      local id = "H:" .. h
      local label = heading_label(lv, counts[lv])
      local next_text = (printed[i + 1] or ""):sub(1, 40)
      need(id, stringify(b.content), next_text)
      entries[#entries + 1] = { id = id, level = lv, label = label, title = b.content }
      -- the body opens a section (a new page): Word keeps the space above there, typst drops it
      local before = (i == 1 and #lead == 0) and 0 or (lv == 1 and H1_ABOVE or H_ABOVE)
      raw({ heading(lv, label, b.content, before) })
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      local c = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
      c:extend(b.content)
      body[#body + 1] = pandoc.Div({ pandoc.Para(c) }, { ["custom-style"] = "Allegation" })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    else
      body[#body + 1] = b
    end
  end

  local tail = {}
  sig_lines(meta.signature, tail, { left = BLOCK, above = SIG_ABOVE, last = meta.date })
  if meta.verification then verification(meta.verification, tail) end
  raw(tail)

  -- the page number, a single line centered (roman on the contents, arabic on the body: the sections' format)
  write_file("FORMBOOK_FOOTERS", "rIdFtrWvsd\t" .. p('<w:r><w:fldChar w:fldCharType="begin"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>', { jc = "center" }) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrWvsd", "decimal"))

  local front = {}
  cover(meta, front)
  front[#front + 1] = section("rIdFtrNone")
  if toc then
    if #needles == 0 then error("complaint.lua: a table of contents needs a lead-in or a heading", 0) end
    needles[#needles + 1] = "#section\t" .. needles[1]:match("^[^\t]+") .. "\tdecimal\t"
    write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
    contents(entries, depth, front)
    front[#front + 1] = section("rIdFtrWvsd", "lowerRoman")
  end

  local out = {}
  for _, x in ipairs(front) do out[#out + 1] = xe.raw(x) end
  for _, x in ipairs(body) do out[#out + 1] = x end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
