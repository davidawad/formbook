-- W.D. Tex. motion with brief, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that
-- it reads and breaks as typst/txwd-motion-brief.typ does (see ../README.md): the cover (court title, caption with
-- the § column, title; CV-10(a)), the table of contents on its own page, the body from a new page (level-1 headings
-- centered bold capitals, levels 2 and 3 bold at the margin, paragraphs with a half-inch first-line indent, block
-- quotations, lists), the signature block (CV-10(b)) and the certificate of service. Everything printed comes from
-- the sample's frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 288 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle.
-- One section, numbered in arabic from the first page (FORMBOOK_FINAL, rIdFtrPage).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 288                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, quote-indent and list-indent, 0.5 in
local LABEL = 360                                      -- typst list-label, 0.25 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_MID = 5328, 432                    -- typst caption-left 3.7 in, caption-mid 0.3 in
local CAP_INSET, CAP_LEAD = 288, 108                   -- typst caption-right-inset 0.2 in, caption-lead 0.075 in
local SIG_RIGHT = 4608                                 -- typst signature-indent 3.2 in
local PNUM, TOC_STEP, TOC_GAP = 720, 360, 216          -- typst toc-page-col 36 pt, toc-step 18 pt, toc-gap 10.8 pt
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, tabs, jc, keep, lines, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function read_file(path)
  if not path or path == "" then return nil end
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The sample's frontmatter as written ($FORMBOOK_META): pandoc drops a caption row's leading spaces, which the typst
-- template turns into an indent.
local function raw_meta()
  local s = read_file(os.getenv("FORMBOOK_META"))
  return s and pandoc.json.decode(s, false) or {}
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
  local s = read_file(os.getenv("FORMBOOK_PAGES"))
  if not s then return end
  for line in s:gmatch("[^\n]+") do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local function cover(meta, rows)
  local out = {}
  local court = meta.court or {}
  for i, l in ipairs(court) do
    -- the caption stands two single lines below the court title (Word has no space before a table here: the last
    -- title line takes it as space after)
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", after = i == #court and 2 * SINGLE or 0 })
  end
  local left, mid, right = {}, {}, {}
  for _, r in ipairs(rows or {}) do
    local l = r[1] or ""
    local stripped = l:gsub("^%s+", "")
    left[#left + 1] = p(xe.runs(stripped), { left = (#l - #stripped) * CAP_LEAD })
    mid[#mid + 1] = p(xe.runs("§"), { jc = "center" })
    right[#right + 1] = p(xe.runs(r[2] or ""), { left = CAP_INSET })
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_MID, TEXTW - CAP_LEFT - CAP_MID }, { { body = left }, { body = mid },
    { body = right } })
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = 2 * SINGLE, line = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 16.033"), as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A heading's text: level 1 in capitals (typst upper()).
local function heading_content(el)
  if el.level ~= 1 then return el.content end
  return el.content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- Headings at the body pitch, bold: level 1 centered, levels 2 and 3 at the margin; kept with the text.
local function heading(el, before, brk)
  local props = { xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP }
  if brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(before, 0, BODY)
  props[#props + 1] = xe.ind(0, nil, 0)
  props[#props + 1] = xe.jc(el.level == 1 and "center" or "left")
  return xe.para(props, xe.inl(heading_content(el), { b = true }))
end

-- Lists: the label half an inch in per level (a nested list a further half inch), in a box of a quarter inch, the
-- text hanging after it; numbers as written, a bullet for "-".
local function items(list, level, out, o)
  local n = list.t == "OrderedList" and list.listAttributes.start or 1
  for _, item in ipairs(list.content) do
    local lab = list.t == "OrderedList" and (n .. ".") or "\u{2022}"
    local left = INDENT * (level + 1) + LABEL
    local first = true
    for _, b in ipairs(item) do
      if b.t == "Plain" or b.t == "Para" then
        if not first then error("txwd-motion-brief.lua: a list item holds one paragraph") end
        out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(b.content),
          { line = BODY, left = left, hanging = LABEL, tab = left, before = o.before, brk = o.brk })
        o.before, o.brk = 0, false
        first = false
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        items(b, level + 1, out, o)
      else
        error("txwd-motion-brief.lua: unsupported block in a list: " .. b.t)
      end
    end
    n = n + 1
  end
end

-- ---------------------------------------------------------------------------
-- Signature block (CV-10(b)) and certificate of service
-- ---------------------------------------------------------------------------

-- In the right 3.2 inches: "Respectfully submitted", the firm lines, "/s/" and the signer, the signer's lines, a
-- single line between the groups; the row never splits. The space above it is a 1 pt paragraph kept with the table,
-- its space before the rest: at the top of a page LibreOffice drops a paragraph's space before, as typst drops a
-- block's, but keeps it in a cell.
local function signature(sig, before)
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(sig.firm or {}) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and SINGLE or 0 }) end
  right[#right + 1] = p(xe.runs("/s/ ") .. xe.inl(sig.signer), { before = SINGLE })
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  return p("", { keep = true, before = before - 20, line = 20 }) ..
    tbl({ TEXTW - SIG_RIGHT, SIG_RIGHT }, { { body = { p("") } }, { body = right } }, '<w:trPr><w:cantSplit/></w:trPr>')
end

-- The heading centered and bold at the body pitch, the paragraph a single line below it, the signer's lines at the
-- right a single line below that; kept on one page.
local function certificate(c, out)
  out[#out + 1] = p(xe.inl(c.heading, { b = true }), { jc = "center", before = 2 * SINGLE, line = BODY, keep = true })
  out[#out + 1] = p(xe.inl(c.text), { before = SINGLE, line = BODY, first = INDENT, keep = true })
  local lines = { xe.runs("/s/ ") .. xe.inl(c.signer) }
  for _, l in ipairs(c.lines or {}) do lines[#lines + 1] = xe.inl(l) end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { jc = "right", before = i == 1 and SINGLE or 0, keep = i < #lines })
  end
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local blocks = doc.blocks

  -- the needles: the court title (where the arabic numbering starts), then each heading with the words after it
  local court = {}
  for _, l in ipairs(meta.court or {}) do court[#court + 1] = plain(l) end
  need("S:0", table.concat(court, " "))
  local entries, ids = {}, {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local id = "H:" .. (#entries + 1)
      ids[i] = id
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      need(id, stringify(heading_content(b)), nxt)
      if b.level <= 3 then entries[#entries + 1] = { id = id, level = b.level, title = heading_content(b) } end
    end
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:0\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = cover(meta, raw_meta().caption)

  -- table of contents, on its own page: the text wraps before the page column, a dot leader to the number
  out[#out + 1] = p(xe.inl(meta.toc_title, { b = true }), { jc = "center", brk = true })
  for i, e in ipairs(entries) do
    local left = (e.level - 1) * TOC_STEP
    out[#out + 1] = p(xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
      { lines = true, tabs = xe.leader_tab(TEXTW), before = i == 1 and SINGLE or TOC_GAP, left = left, right = PNUM })
  end

  -- the body, from a new page (a page drops the space above its first line); the space a block asks for below it
  -- is taken by the next paragraph as space before it (between two blocks the larger applies, as in typst)
  local gap, brk = 0, true
  local function take(before)
    local g = math.max(gap, before or 0)
    gap = 0
    return g
  end
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local first = brk
    brk = false
    if b.t == "Header" then
      out[#out + 1] = heading(b, take(), first)
    elseif b.t == "BlockQuote" then
      -- single spaced, indented from both margins, a single line above and below
      out[#out + 1] = p(xe.inl(pandoc.utils.blocks_to_inlines(b.content)),
        { left = INDENT, right = INDENT, before = take(SINGLE), brk = first })
      gap = SINGLE
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, 0, out, { before = take(), brk = first })
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, before = take(), keep = last, brk = first })
    else
      error("txwd-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  if meta.signature then out[#out + 1] = signature(meta.signature, take(SINGLE)) end
  if meta.certificate then certificate(meta.certificate, out) end

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
