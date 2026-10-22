-- Pandoc filter for the wvsd memorandum of law (motion brief), engine docx, so that it reads and breaks as
-- typst/wvsd-motion-brief.typ does: a cover (its own section, no page number) with the court title, the caption,
-- the title and the counsel block at 3.25 in; then the body (its own section, numbered from 1): headings numbered
-- by the template (level 1 unnumbered), the markdown body with its footnotes, the "Dated" line and the signature
-- block at 3.25 in. Every case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs, lists,
-- quotations and footnotes are written by pandoc in the styles of docx/reference.xml; everything else here.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local H1_ABOVE, H_ABOVE, H_BELOW = 360, 240, 240 -- typst h1-above 18 pt, h-above, h-below 12 pt
local TAB = 720                          -- typst heading-tab, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local PARTY, PAREN = 4320, 432           -- typst caption-left 3.0 in, caption-paren 0.3 in
local RIGHT_PAD = 288                    -- typst caption-right-pad 0.2 in
local BLOCK = 4680                       -- typst block-indent 3.25 in
local COUNSEL_ABOVE = 720                -- 36 pt between the title and the counsel block
local SIG_ABOVE = 480                    -- 24 pt above the signature block
local FOOTER = 732                       -- the page number's line 36.6 pt above the page foot (typst footer-descent 30 %)

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single-spaced lines at `left` (an empty one is a blank line: the next stands a single line lower), `above`
-- before the first; kept together when `keep` (the last line ends the chain).
local function lines(list, out, o)
  local skip = o.above or 0
  local ps = {}
  for _, l in ipairs(list or {}) do
    if plain(l) == "" then skip = skip + SINGLE else
      ps[#ps + 1] = { xe.inl(l), skip }
      skip = 0
    end
  end
  for i, l in ipairs(ps) do
    out[#out + 1] = p(l[1], { before = l[2], left = o.left, keep = o.keep and i < #ps })
  end
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title, counsel
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
  local items = {}
  for _, g in ipairs(meta.counsel or {}) do
    for _, n in ipairs(g.names or {}) do items[#items + 1] = n end
    for _, l in ipairs(g.lines or {}) do items[#items + 1] = l end
    items[#items + 1] = ""
  end
  while #items > 0 and items[#items] == "" do items[#items] = nil end
  lines(items, out, { left = BLOCK, above = COUNSEL_ABOVE })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return s
end

-- typst heading-numbering: level 2 "I.", 3 "A.", 4 "1.", 5 "a.", level 1 none.
local function heading_label(level, k)
  if level == 2 then return roman(k) .. "." end
  if level == 3 then return string.char(64 + k) .. "." end
  if level == 4 then return k .. "." end
  if level == 5 then return string.char(96 + k) .. "." end
  return ""
end

-- Headings single-spaced, 12 pt, bold to level 3; level 1 centered, deeper levels with the number in a box at the
-- level's indent and the text hanging after it; kept with the text.
local function heading(level, label, content, before)
  local o = { b = level <= 3 }
  if level == 1 then
    return p(xe.inl(content, o), { before = before, after = H_BELOW, jc = "center", keep = true })
  end
  local ind = (level - 2) * TAB
  return p(xe.runs(label .. "\t", o) .. xe.inl(content, o),
    { before = before, after = H_BELOW, left = ind + TAB, hanging = TAB, tab = ind + TAB, keep = true })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
-- In a web address typst also breaks after "//" and after each "/", ".", "-", "_", "?", "=", "&", "#" inside it
-- ("https://bit.ly/" ends a line before "45gxpLq"): a zero-width space there too.
local function url_breaks(u)
  local head, rest = u:match("^(%a+://)(.*)$")
  rest = rest:gsub("([/%.%-_%?=&#])(.)", "%1\u{200B}%2")
  return head .. "\u{200B}" .. rest
end

local function breaks(s)
  local t = s.text
  local a, b = t:find("%a+://%S*")
  if a then
    return pandoc.Str(t:sub(1, a - 1) .. url_breaks(t:sub(a, b)) .. t:sub(b + 1))
  end
  return pandoc.Str((t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 19-22": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local out = {}
  local function raw(list)
    for _, x in ipairs(list) do out[#out + 1] = xe.raw(x) end
  end

  local cov = {}
  cover(meta, cov)
  -- the paragraph that ends the cover's section (a 1 pt line, so it pushes nothing on); no page number there
  cov[#cov + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, 20) .. sect_pr("rIdFtrNone") .. '</w:pPr></w:p>'
  raw(cov)

  local counts = { 0, 0, 0, 0, 0, 0 }
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lv = math.min(b.level, 5)
      counts[lv] = counts[lv] + 1
      for j = lv + 1, #counts do counts[j] = 0 end
      -- the body opens a section (a new page): Word keeps the space above there, typst drops it
      local before = i == 1 and 0 or (lv == 1 and H1_ABOVE or H_ABOVE)
      raw({ heading(lv, heading_label(lv, counts[lv]), b.content, before) })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end

  local sig = {}
  sig[#sig + 1] = p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = SIG_ABOVE, keep = true })
  lines(meta.signature, sig, { left = BLOCK, above = BODY, keep = true })
  raw(sig)

  -- the body's page number: a single line, centered
  write_file("FORMBOOK_FOOTERS", "rIdFtrWvsd\t" .. p('<w:r><w:fldChar w:fldCharType="begin"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>', { jc = "center" }) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrWvsd", "decimal"))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
