-- W.D. Mich. brief in support of a dispositive motion (miwd), docx engine. Mirrors typst/miwd-motion-brief.typ: the
-- cover (the court title centered in bold; the caption, Fed. R. Civ. P. 10(a): the parties single-spaced in a column
-- ruled on its right and under it, "v." between them, and at the right the case number, the judge and, when
-- requested, ORAL ARGUMENT REQUESTED in bold, LCivR 7.2(d); the title of the brief), the table of contents (generated
-- from the headings, levels 1 and 2), the brief (headings numbered I. / A. / 1. / a., the body and its footnotes as
-- pandoc writes them) and the signature block (Fed. R. Civ. P. 11(a); LCivR 10.3), kept on one page with the last
-- paragraph. Every case word comes from the frontmatter and the body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle:
-- the contents' page of each heading and the brief's last page (LCivR 7.2(b): 25 pages). Three sections: the cover
-- (no number), the contents (lower roman from i), the brief (arabic from 1; FORMBOOK_FINAL); the page number
-- centered in a single-pitch footer ($FORMBOOK_FOOTERS). Word may paginate slightly differently from LibreOffice.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local TEXTW = 9360                            -- 6.5 in
local INDENT = 720                            -- typst para-indent: 0.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360        -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_RIGHT = TEXTW - CAP_LEFT - CAP_GUTTER
local CAP_INSET = 144                         -- typst caption-right-inset 0.1 in
local CAP_PAD_RIGHT = 200                     -- typst caption-pad-right 10 pt
local CAP_PAD_BOTTOM = 160 - 15               -- typst caption-pad-bottom 8 pt, less the 0.75 pt rule LibreOffice
                                              -- sets below the row (typst strokes take no room)
local CAPTION_ABOVE, ORAL_ABOVE = 480, 240    -- typst caption-above 24 pt, oral-above 12 pt
local TITLE_ABOVE, TITLE_INSET = 1440, 936    -- typst title-above 72 pt, title-inset 0.65 in
local TOC_PAGE_ABOVE, ROW_GAP = 480, 240      -- typst toc-page-above 24 pt, row-gap 12 pt
local TOC_COL = 720                           -- typst toc-page-col 36 pt
local HEADING_GAP = 240                       -- typst heading-gap 12 pt
local SIG_COL = 4032                          -- typst sig-col 2.8 in
local SIG_ABOVE, SIG_GAP = 480, 240           -- typst sig-above 24 pt, sig-gap 12 pt
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge
local PAGE_LIMIT = 25                         -- LCivR 7.2(b)
local NEEDLE_MAX = 60
local RULE = ' w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }

local function check(cond, msg)
  if not cond then error("miwd motion-brief docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- One line of the frontmatter. pandoc reads a value that starts like a list label ("(616) 742-3930") as a list and
-- keeps only the item's text: such a value is set from its text as written in the sample (`raw`, from
-- $FORMBOOK_META), as typst reads it.
local function line(l, o, raw)
  if type(l) == "string" then return xe.runs(l, o) end
  if type(raw) == "string" and (raw:match("^%(?%d+[%.%)]%s") or raw:match("^%(?%a[%.%)]%s")) then return xe.runs(raw, o) end
  if pandoc.utils.type(l) == "Blocks" then
    if #l == 1 and (l[1].t == "Para" or l[1].t == "Plain") then return xe.inl(l[1].content, o) end
    check(type(raw) == "string", "a frontmatter line pandoc reads as blocks: " .. stringify(l))
    return xe.runs(raw, o)
  end
  return xe.inl(l, o)
end

-- The items of a metadata list, each with the same item as written in the sample (`raw`, a list of strings or nil).
local function with_raw(v, raw)
  local out = {}
  for i, x in ipairs(items(v)) do out[i] = { x, type(raw) == "table" and raw[i] or nil } end
  return out
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

-- A paragraph: o = { before, after, pitch, left, right, hanging, first, jc, keep, lines, brk, tabs, style }; single
-- pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (a block's space above a table): an empty paragraph that tall.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- A one-row table without cell margins: cells = { { w, body, pr } }, pr: the cell's own borders and margins.
local function row(cells)
  local total, grid, tcs = 0, {}, {}
  for _, c in ipairs(cells) do
    total = total + c[1]
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>'
      .. (c[2] ~= "" and c[2] or p("")) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Footer and sections (LCivR 10.1: letter, 1 in margins)
-- ---------------------------------------------------------------------------

local PAGE_FOOTER = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')

-- A section's properties: its footer (fb render's empty rIdFtrNone, or this filter's page number) and numbering.
local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>'
    .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(...)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. sect_pr(...)
    .. '</w:pPr></w:p>'
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
  local s = read_file(os.getenv("FORMBOOK_PAGES"))
  if not s then return end
  for l in s:gmatch("[^\n]+") do
    local id, _, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
end

-- The text of inlines as the PDF prints it, up to the first footnote mark (a needle stops there: the mark's number
-- is in the PDF text, its note is not).
local function text_of(inlines)
  local out = {}
  for _, el in ipairs(inlines) do
    if el.t == "Note" then
      out[#out + 1] = "\0"
      break
    elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then
      out[#out + 1] = " "
    elseif el.t == "Str" then
      out[#out + 1] = el.text
    elseif el.content then
      out[#out + 1] = text_of(el.content)
    else
      out[#out + 1] = stringify(el)
    end
  end
  return (table.concat(out):match("^[^\0]*"))
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the brief
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local court = { "UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF MICHIGAN" }
  if m.division and txt(m.division) ~= "" then court[#court + 1] = txt(m.division):upper() end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end

  local blank = "__________________"
  local cn = txt(m.case_number)
  if cn == "" then cn = blank end
  local hon = txt(m.judge)
  if hon == "" then hon = blank end
  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(line(n)) end
    left[#left + 1] = p(line(party.designation))
  end
  local right = {
    p(xe.runs("Case No. " .. cn), { left = CAP_INSET }),
    p(xe.runs("Hon. " .. hon), { left = CAP_INSET }),
  }
  if m.oral_argument_requested then
    right[#right + 1] = p(xe.runs("ORAL ARGUMENT REQUESTED", { b = true }), { left = CAP_INSET, before = ORAL_ABOVE })
  end
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = row({
    { CAP_LEFT, table.concat(left), '<w:tcBorders><w:bottom' .. RULE .. '<w:right' .. RULE .. '</w:tcBorders>'
      .. '<w:tcMar><w:bottom w:w="' .. CAP_PAD_BOTTOM .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD_RIGHT
      .. '" w:type="dxa"/></w:tcMar>' },
    { CAP_GUTTER, "" },
    { CAP_RIGHT, table.concat(right) },
  })
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { jc = "center", pitch = BODY, before = TITLE_ABOVE,
    left = TITLE_INSET, right = TITLE_INSET })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Table of contents: rows with a dot leader to the page column (typst toc-entry)
-- ---------------------------------------------------------------------------

local function contents(entries)
  local out = { p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", keep = true }) }
  out[#out + 1] = p(xe.runs("Page"), { jc = "right", keep = true, before = TOC_PAGE_ABOVE })
  for _, e in ipairs(entries) do
    local ind = (e.level - 1) * INDENT
    out[#out + 1] = p(xe.runs(e.label .. "\t") .. xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
      { lines = true, before = ROW_GAP, left = ind + INDENT, hanging = INDENT, right = TOC_COL,
        tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + INDENT) .. '"/><w:tab w:val="right" w:leader="dot" w:pos="'
          .. TEXTW .. '"/></w:tabs>' })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The brief: headings and signature
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A heading (typst style-heading): single-spaced, the label in a half-inch box (a tab) after the level's step, the
-- text hanging after it; 12 pt above and below, kept with the next block. Level 1 bold capitals, level 2 bold,
-- levels 3 and 4 regular. A heading that opens the brief has no space above (typst drops it at the top of a page;
-- Word keeps it after a section break).
local function heading(b, label, first)
  local lv = math.min(b.level, 4)
  local ind = (lv - 1) * INDENT
  local o = lv <= 2 and { b = true } or nil
  local content = lv == 1 and upper(b.content) or b.content
  return p(xe.runs(label .. "\t", o) .. xe.inl(content, o), { keep = true, before = first and 0 or HEADING_GAP,
    after = HEADING_GAP, left = ind + INDENT, hanging = INDENT,
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + INDENT) .. '"/></w:tabs>' })
end

-- The signature block (typst signature-block): single-spaced from SIG_COL, "Dated:" and the date at the left of its
-- first line (a tab), kept on one page, a space of its own above.
local function signature(m, R)
  local sig = m.signature
  local rs = R.signature or {}
  local lines = {}
  for _, f in ipairs(items(sig.firm)) do lines[#lines + 1] = { line(f), 0 } end
  lines[#lines + 1] = { xe.runs("/s/ " .. txt(sig.signer)), SIG_GAP }
  for _, l in ipairs(with_raw(sig.lines, rs.lines)) do lines[#lines + 1] = { line(l[1], nil, l[2]), 0 } end
  local out = {}
  for i, l in ipairs(lines) do
    local keep = i < #lines
    if i == 1 then
      out[#out + 1] = p(xe.runs("Dated: " .. txt(m.date) .. "\t") .. l[1], { before = SIG_ABOVE, left = SIG_COL,
        hanging = SIG_COL, tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. SIG_COL .. '"/></w:tabs>', keep = keep })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG_COL, keep = keep })
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Break rules (typst's, which LibreOffice does not share)
-- ---------------------------------------------------------------------------

-- None inside a token of adjacent parentheses ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060)
-- between ")" and "("; one after a slash followed by a letter ("and/or"), where LibreOffice keeps the word whole: a
-- zero-width space (U+200B) after it. Neither shows in the PDF text.
local function breaks(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("¶¶ 60–63"; the typst template boxes them): no-break spaces.
local function binds(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("^[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

function Pandoc(doc)
  load_pages()
  local m = doc.meta
  local R = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)
  check(m.caption ~= nil and m.caption.parties ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.title ~= nil, "Fed. R. Civ. P. 10(a): the title is required")
  check(m.signature ~= nil, "Fed. R. Civ. P. 11(a): the signature is required")
  local blocks = doc.blocks

  -- headings numbered I. / A. / 1. / a. (typst brief-numbering); the needles in document order: the contents' title
  -- (roman from i), the brief's first block (arabic from 1), each heading with the words after it, and the brief's
  -- last line
  need("S:toc", "TABLE OF CONTENTS")
  local counts, labelled = { 0, 0, 0, 0 }, {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = math.min(b.level, 4)
      counts[lv] = counts[lv] + 1
      for k = lv + 1, 4 do counts[k] = 0 end
      local n = counts[lv]
      labelled[i] = lv == 1 and (ROMAN[n] .. ".") or lv == 2 and (string.char(64 + n) .. ".")
        or lv == 3 and (n .. ".") or (string.char(96 + n) .. ".")
    end
  end
  local start = "S:body"
  if blocks[1] and blocks[1].t ~= "Header" then need(start, text_of(blocks[1].content or {})) else start = "H:1" end
  local entries, h_n = {}, 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = blocks[i + 1] and blocks[i + 1].content and text_of(blocks[i + 1].content) or ""
      need(id, labelled[i] .. " " .. text_of(b.content), nxt)
      if b.level <= 2 then entries[#entries + 1] = { id = id, level = b.level, label = labelled[i], title = b.content } end
    end
  end
  local sl = R.signature and R.signature.lines or {}
  need("S:end", type(sl) == "table" and sl[#sl] or txt(m.signature.signer))
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n#section\tS:toc\tlower-roman\t\n#section\t"
    .. start .. "\tdecimal\t\n")
  write_file("FORMBOOK_FOOTERS", "rIdMiwdPage\t" .. PAGE_FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdMiwdPage", "decimal"))

  -- LCivR 7.2(b): a dispositive-motion brief is at most 25 pages, exclusive of cover sheet, tables and indices
  local pages = tonumber(labels["S:end"] or "")
  check(not pages or pages <= PAGE_LIMIT, "the brief is " .. tostring(pages) .. " pages; LCivR 7.2(b) allows "
    .. PAGE_LIMIT .. " for a dispositive-motion brief")

  -- links keep their text; the break rules on every run pandoc writes
  blocks = blocks:walk({ Link = function(l) return l.content end }):walk({ Inlines = binds })
    :walk({ Str = breaks }):walk({ Inlines = xe.inlines })

  local out = {}
  local function raw(x) out[#out + 1] = xe.raw(x) end
  raw(cover(m))
  raw(section_end("rIdFtrNone", "decimal"))
  raw(contents(entries))
  raw(section_end("rIdMiwdPage", "lowerRoman"))
  -- the last paragraph stays whole with the signature (typst: one unbreakable block), unless it is a heading
  local tail = #blocks
  if blocks[tail] and blocks[tail].t ~= "Para" then tail = nil end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      raw(heading(b, labelled[i], i == 1))
    elseif b.t == "Para" or b.t == "Plain" then
      local style = i == tail and "Body Text Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BlockQuote" then
      out[#out + 1] = pandoc.Div(b.content, { ["custom-style"] = "Block Text" })
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("miwd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  raw(signature(m, R))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
