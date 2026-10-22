-- lawd motion-brief, docx engine. Mirrors typst/lawd-motion-brief.typ; rules and conventions are in ../README.md
-- (Engines). The court title, the caption (parties | one asterisk per line of the party column | case number and
-- judges), the title and subtitle, the front matter, the table of contents and the table of authorities (LR 7.1,
-- 7.8), the body, the signature block (LR 11.1) and the certificate of service are built here as WordprocessingML.
-- Font, size and margins are styles and section settings in docx/reference.xml (fb render builds the reference
-- document from it). Content-agnostic: every case-specific word comes from the sample's frontmatter and body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
--
-- Sections and page numbers (were docx/render.sh, which copied a footer part for the front section): the caption,
-- the front matter and the tables are a section numbered in lower roman from i, the body a section numbered from 1
-- ($FORMBOOK_FINAL); both name fb render's page-number footer (rIdFtrPage). The table of contents' page numbers:
-- fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes ($FORMBOOK_NEEDLES,
-- one per heading) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst block-gap 24 pt
local SUBTITLE_ABOVE = 120               -- typst subtitle-above 6 pt
local INDENT = 720                       -- typst para-indent, list-indent 0.5 in
local TEXT_AT = 1440                     -- a list item's text: 1 in (typst list-indent + label-box)
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_STAR = 4752, 432     -- typst caption-left 3.3 in, caption-star 0.3 in
local DESIG = 2160                       -- typst designation-indent 1.5 in
local SIG_LEFT = 4680                    -- typst sig-left 3.25 in
local TOC_STEP = 360                     -- typst toc-step 18 pt
local PNUM = 720                         -- typst page-col 0.5 in
local TOA_HANG = 720                     -- typst toa-hang 0.5 in
local BLANK = string.rep("_", 23)        -- typst blank
local NEEDLE_MAX = 60

-- ---------------------------------------------------------------------------
-- Line count of the party column (typst measures it; Word cannot, so the filter sets the text as typst does:
-- first fit at the face's advance widths, a break at a space or after a hyphen before a letter).
-- ---------------------------------------------------------------------------

-- Times New Roman advance widths (units of 2048 per em) of U+0020..U+007E, then ’ ‘ “ ” – — § no-break space … é;
-- measured from the pinned font (typst measure, kerning off), regular and italic.
local CHARS = {}
for c = 32, 126 do CHARS[#CHARS + 1] = utf8.char(c) end
for _, c in ipairs({ "’", "‘", "“", "”", "–", "—", "§", "\u{a0}", "…", "é" }) do CHARS[#CHARS + 1] = c end
local ADV_R = { 512,682,836,1024,1024,1706,1593,369,682,682,1024,1155,512,682,512,569,1024,1024,1024,1024,1024,1024,
  1024,1024,1024,1024,569,569,1155,1155,1155,909,1886,1479,1366,1366,1479,1251,1139,1479,1479,682,797,1479,1251,1821,
  1479,1479,1139,1479,1366,1139,1251,1479,1479,1933,1479,1479,1251,682,569,682,961,1024,682,909,1024,909,1024,909,
  682,1024,1024,569,569,1024,569,1593,1024,1024,1024,1024,682,797,569,1024,1024,1479,1024,1024,909,983,410,983,1108,
  682,682,909,909,1024,2048,1024,512,2048,909 }
local ADV_I = { 512,682,860,1024,1024,1706,1593,438,682,682,1024,1382,512,682,512,569,1024,1024,1024,1024,1024,1024,
  1024,1024,1024,1024,682,682,1382,1382,1382,1024,1884,1251,1251,1366,1479,1251,1251,1479,1479,682,909,1366,1139,
  1706,1366,1479,1251,1479,1251,1024,1139,1479,1251,1706,1251,1139,1139,797,569,797,864,1024,682,1024,1024,909,1024,
  909,569,1024,1024,569,569,909,569,1479,1024,1024,1024,1024,797,797,569,1024,909,1366,909,909,797,819,563,819,1108,
  682,682,1139,1139,1024,1821,1024,512,1821,909 }
local W_R, W_I = {}, {}
for i, c in ipairs(CHARS) do W_R[c], W_I[c] = ADV_R[i], ADV_I[i] end
local SIZE = 12

-- The characters of inlines (or a metadata value), each with its width in points at the type size.
local function glyphs(x, italic, out)
  out = out or {}
  if x == nil then return out end
  if type(x) == "string" then x = pandoc.Inlines({ pandoc.Str(x) }) end
  for _, el in ipairs(x) do
    if el.t == "Str" then
      for _, c in utf8.codes(el.text) do
        local ch = utf8.char(c)
        out[#out + 1] = { ch, ((italic and W_I or W_R)[ch] or 1024) * SIZE / 2048 }
      end
    elseif el.t == "Space" or el.t == "SoftBreak" then
      out[#out + 1] = { " ", W_R[" "] * SIZE / 2048 }
    elseif el.t == "Emph" then
      glyphs(el.content, true, out)
    elseif el.content then
      glyphs(el.content, italic, out)
    end
  end
  return out
end

-- The number of lines the text takes in a column `width` points wide, broken first fit.
local function count_lines(x, width)
  local g = glyphs(x)
  -- segments: a run of characters, then whether a space follows (else a hyphen break)
  local segs, cur, w = {}, {}, 0
  for i, gl in ipairs(g) do
    if gl[1] == " " then
      segs[#segs + 1] = { w = w, space = gl[2] }
      w = 0
    else
      w = w + gl[2]
      local nxt = g[i + 1]
      if gl[1] == "-" and nxt and nxt[1] ~= " " and not nxt[1]:match("%d") then
        segs[#segs + 1] = { w = w, space = 0 }
        w = 0
      end
    end
  end
  segs[#segs + 1] = { w = w, space = 0 }
  local lines, line, pend = 1, 0, 0
  for _, s in ipairs(segs) do
    if line > 0 and line + pend + s.w > width + 0.01 then
      lines = lines + 1
      line = s.w
    else
      line = line + pend + s.w
    end
    pend = s.space
  end
  return lines
end
-- ---------------------------------------------------------------------------
-- Paragraphs and tables
-- ---------------------------------------------------------------------------

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, tabs, pre }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table with fixed column widths (twips), no borders and no cell margins; the row is not split across
-- pages (typst: one grid row).
local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. cells[i] .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- Single-spaced lines (typst line-stack): an empty item is a blank line, the next line a line lower. A cell needs
-- a paragraph even when it holds no line.
local function stack(lines)
  local out, gap = {}, 0
  for _, l in ipairs(lines) do
    local s = type(l) == "string" and l or stringify(l)
    if s == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(type(l) == "string" and xe.runs(l) or xe.inl(l), { before = gap })
      gap = 0
    end
  end
  if #out == 0 then out[1] = p("") end
  return table.concat(out)
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
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
  needles[#needles + 1] = { id = id, kind = "B", needle = long, fallback = short:sub(1, NEEDLE_MAX) }
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
-- Sections: the page number in fb render's footer (rIdFtrPage), 0.3 in above the page foot (typst footer-descent)
-- ---------------------------------------------------------------------------

local function sect_pr(fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="432" w:gutter="0"/><w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/></w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Court title, caption (FRCP 10(a); LR 10.1), title and subtitle
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT"), { jc = "center" }),
    p(xe.runs("WESTERN DISTRICT OF LOUISIANA"), { jc = "center" }),
    p(xe.runs(stringify(m.division):upper() .. " DIVISION"), { jc = "center", after = GAP }),
  }
  local cap = m.caption
  local sep = cap.separator and stringify(cap.separator) or "v."
  local left, n = {}, 0
  for i, party in ipairs(cap.parties) do
    if i > 1 then
      -- the separator, then a blank line (the next name sits a line lower)
      left[#left + 1] = p(xe.runs(sep))
      n = n + 2
    end
    for j, name in ipairs(items(party.names)) do
      left[#left + 1] = p(xe.inl(name), { before = (i > 1 and j == 1) and SINGLE or 0 })
      n = n + count_lines(name, CAP_LEFT / 20)
    end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG })
    n = n + count_lines(party.designation, (CAP_LEFT - DESIG) / 20)
  end
  local stars = {}
  for _ = 1, n do stars[#stars + 1] = p(xe.runs("*"), { jc = "center" }) end
  local function entry(label, v)
    return label .. " " .. (v and stringify(v) or BLANK)
  end
  local right = { entry("CIVIL ACTION NO.", m.case_number), entry("JUDGE", m.judge),
    entry("MAGISTRATE JUDGE", m.magistrate) }
  if m.legend then
    right[#right + 1] = ""
    right[#right + 1] = stringify(m.legend)
  end
  out[#out + 1] = table_xml({ CAP_LEFT, CAP_STAR, TEXTW - CAP_LEFT - CAP_STAR },
    { table.concat(left), table.concat(stars), stack(right) })
  -- the caption stands a blank double line above the title (Word has no space after a table)
  local title = p(xe.runs(stringify(m.title):upper(), { b = true }), { jc = "center", before = GAP })
  if m.subtitle then
    title = title .. p(xe.runs(stringify(m.subtitle):upper(), { b = true }), { jc = "center", before = SUBTITLE_ABOVE })
  end
  out[#out + 1] = title
  -- typst v(block-gap): a space of its own
  out[#out + 1] = xe.para({ xe.spacing(0, 0, GAP) }, "")
  return table.concat(out)
end

-- A signature block (LR 11.1): the date (if any) at the left; at the right the lead-in (if any), a blank line and
-- the sample's lines; the space above it is spacing of its own, kept with the block (typst: one unbreakable block).
local function signature(sig, lead)
  local right = {}
  if lead then right = { lead, "" } end
  for _, l in ipairs(items(sig.lines)) do right[#right + 1] = l end
  local left = sig.date and { "Dated: " .. stringify(sig.date) } or {}
  return xe.para({ xe.KEEP, xe.spacing(0, 0, GAP) }, "")
    .. table_xml({ SIG_LEFT, TEXTW - SIG_LEFT }, { stack(left), stack(right) })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("CM/ECF"), where LibreOffice keeps the word whole: a zero-width space (U+200B). Neither
-- shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

-- A heading on the body pitch, a blank line above it (none where it opens the body's section: Word keeps the space
-- there, typst drops it at the top of a page), kept with the block after it.
local function heading(b, before)
  local c = b.content
  if b.level == 1 then c = c:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }) end
  return p(xe.inl(c, { b = true, i = b.level >= 3 }),
    { before = before, line = BODY, keep = true, jc = b.level == 1 and "center" or "left" })
end

-- The blocks of a run of the body, as { xml } or { body, o } (the last is kept with the signature block).
local function blocks_of(list, first_of_section, entries)
  local parts = {}
  for i, b in ipairs(list) do
    if b.t == "RawBlock" then
      -- a directive (an HTML comment): nothing is printed
    elseif b.t == "Header" then
      local id = "H:" .. (#entries + 1)
      local nxt = list[i + 1] and stringify(list[i + 1]):sub(1, 40) or ""
      need(id, stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = b.level, title = b.content }
      parts[#parts + 1] = { xml = heading(b, (first_of_section and i == 1) and 0 or GAP) }
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        parts[#parts + 1] = { body = xe.runs("(" .. k .. ")\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          o = { line = BODY, left = TEXT_AT, hanging = TEXT_AT - INDENT } }
      end
    elseif b.t == "Para" or b.t == "Plain" then
      parts[#parts + 1] = { body = xe.inl(b.content), o = { line = BODY, first = INDENT } }
    else
      error("lawd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  return parts
end

local function emit(parts, out, keep_last)
  for i, x in ipairs(parts) do
    if x.xml then
      out[#out + 1] = x.xml
    else
      if keep_last and i == #parts then x.o.keep = true end
      out[#out + 1] = p(x.body, x.o)
    end
  end
end

-- ---------------------------------------------------------------------------
-- The tables (LR 7.1, 7.8)
-- ---------------------------------------------------------------------------

local function table_title(s)
  return p(xe.runs(s, { b = true }), { pre = xe.BREAK, jc = "center", line = BODY, after = GAP })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages, left, hanging)
  return p(text_xml .. xe.runs(xe.LEAD .. pages), { lines = true, tabs = xe.leader_tab(TEXTW), line = BODY,
    left = left, hanging = hanging, right = PNUM })
end

local function toc(entries)
  local out = { table_title("TABLE OF CONTENTS") }
  for _, e in ipairs(entries) do
    local ind = (e.level - 1) * TOC_STEP
    out[#out + 1] = row(xe.inl(e.title), labels[e.id] or "0", ind, nil)
  end
  return table.concat(out)
end

local function toa(groups)
  local out = { table_title("TABLE OF AUTHORITIES") }
  for _, g in ipairs(groups) do
    out[#out + 1] = p(xe.inl(g.category, { b = true }), { keep = true, line = BODY })
    for _, item in ipairs(items(g.items)) do
      out[#out + 1] = row(xe.inl(item.cite), stringify(item.pages), TOA_HANG, TOA_HANG)
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The memorandum
-- ---------------------------------------------------------------------------

local function finish(doc)
  load_pages()
  local m = doc.meta
  -- the front matter: the blocks before the first level 1 heading; the body: the rest
  local front, body = {}, {}
  for _, b in ipairs(doc.blocks) do
    if #body == 0 and not (b.t == "Header" and b.level == 1) then front[#front + 1] = b else body[#body + 1] = b end
  end

  local entries = {}
  local front_parts = blocks_of(front, false, entries)
  entries = {}
  needles = {}
  -- the body's first page starts the arabic numbering (a heading's own needle, or the opening paragraph's)
  local start = "H:1"
  if body[1] and body[1].t ~= "Header" then
    start = "S:1"
    need(start, stringify(body[1]), body[2] and stringify(body[2]):sub(1, 40) or "")
  end
  local body_parts = blocks_of(body, true, entries)

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\t" .. start .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("decimal"))

  local out = { cover(m) }
  emit(front_parts, out, false)
  if m.authorities then
    out[#out + 1] = toc(entries)
    out[#out + 1] = toa(m.authorities)
  end
  out[#out + 1] = section("lowerRoman")
  emit(body_parts, out, true)
  out[#out + 1] = signature(m.signature, "Respectfully submitted,")
  if m.certificate then
    -- heading, text and signature kept together (typst: one unbreakable block)
    out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { before = GAP, line = BODY, keep = true, jc = "center" })
    out[#out + 1] = p(xe.inl(m.certificate.text), { line = BODY, first = INDENT, keep = true })
    out[#out + 1] = signature(m.certificate.signature, nil)
  end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
