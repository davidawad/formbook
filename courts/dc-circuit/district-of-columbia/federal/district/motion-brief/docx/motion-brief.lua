-- Memorandum of points and authorities in support of a motion, for the U.S. District Court for the District of
-- Columbia (dcd), docx engine: what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/dcd-motion-brief.typ does (README "Engines"): the cover (court title, caption, title of the paper), the table
-- of contents, the headings, the block quotations and the signature block. Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle.
-- The cover is a section with no footer (rIdFtrNone); the contents number their pages in roman from i (rIdFtrPage);
-- the body numbers its pages from 1 (FORMBOOK_FINAL, rIdFtrPage). Word may paginate slightly differently.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent and quote-indent, 0.5 in
local GAP = 240                        -- typst gap, 12 pt
local TEXTW = 9360                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288 -- typst caption-left 3.4 in, caption-gutter 0.2 in
local CAP_INSET, CAP_PAD = 200, 138    -- typst caption-inset 10 pt, caption-pad (half a single line)
local RIGHT_INSET = 144                -- typst right-inset 0.1 in
local SIG_LEFT, SIG_GUTTER = 4032, 288 -- typst sig-left 2.8 in, sig-gutter 0.2 in
local PNUM = 720                       -- typst toc-page-col, 36 pt
local TOC_STEP = 360                   -- typst toc-step, 0.25 in
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep, lines, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
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
-- Sections
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption (LCvR 5.1(c), (d)), title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" }),
    p(xe.runs("FOR THE DISTRICT OF COLUMBIA", { b = true }), { jc = "center", after = BODY }),
  }
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_PAD or 0 })
  end
  local number = plain(meta.case_number)
  if number == "" then number = "____________" end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>',
      body = { p(xe.runs("Civil Action No. " .. number)) } },
  })
  -- the caption stands a double line above the title (Word has no space after a table)
  out[#out + 1] = p(xe.inl(meta.brief_title, { b = true }), { jc = "center", before = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" at the left; the signature column at the right; the row never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = BODY }) }
  local right = {
    p(xe.runs("Respectfully submitted,"), { before = BODY }),
    p(xe.inl(sig.firm), { before = GAP }),
    p(xe.runs("________________________________"), { before = GAP }),
    p(xe.inl(sig.signature)),
  }
  for _, lines in ipairs(sig.blocks or {}) do
    for i, l in ipairs(lines) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and GAP or 0 }) end
  end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings: single-spaced, bold, a single line above and below; level 1 centered in capitals, levels 2 and 3 at the
-- margin; kept with the text.
local function heading(el, before)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(before, SINGLE, SINGLE), xe.ind(0, nil, 0),
    xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local blocks = doc.blocks

  local body, entries = {}, {}
  local h_n = 0
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local next_text = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
    -- the body's first page starts the arabic numbering (a heading's own needle, or the opening paragraph's)
    if i == 1 and b.t ~= "Header" then need("S:1", stringify(b), next_text) end
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, stringify(b.content), next_text)
      entries[#entries + 1] = { id = id, level = b.level, title = b.content }
      -- the body opens a section (a new page): Word keeps the space above there, typst drops it
      body[#body + 1] = heading(b, i == 1 and 0 or SINGLE)
    elseif b.t == "BlockQuote" then
      for j, q in ipairs(b.content) do
        body[#body + 1] = p(xe.inl(q.content), { line = BODY, left = INDENT, right = INDENT,
          keep = last and j == #b.content })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: one unbreakable block)
      body[#body + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = last })
    else
      error("motion-brief.lua: unsupported block " .. b.t)
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\t" .. (blocks[1] and blocks[1].t == "Header" and "H:1" or "S:1") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  local out = cover(meta)
  out[#out + 1] = section("rIdFtrNone")
  if meta.toc == true then
    out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", after = GAP })
    for _, e in ipairs(entries) do
      local left = (e.level - 1) * TOC_STEP
      out[#out + 1] = p(xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
        { lines = true, tabs = xe.leader_tab(TEXTW), before = GAP, left = left, right = PNUM })
    end
    out[#out + 1] = section("rIdFtrPage", "lowerRoman")
  end
  for _, x in ipairs(body) do out[#out + 1] = x end
  out[#out + 1] = signature(meta)

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
