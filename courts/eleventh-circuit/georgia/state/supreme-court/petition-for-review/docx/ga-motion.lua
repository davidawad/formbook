-- ga-motion.lua (docx engine): the Supreme Court of Georgia motion or response (Rules 16, 17, 20, 26) and petition for
-- certiorari (Rules 38-45; petition-for-review adds the questions presented, Rule 41(2)) as Word paragraphs, so that
-- each reads and breaks as the folder's typst template (typst/ga-*.typ, the reference) does:
--   * the cover (no page number): case number, court, caption table (names and designation, a close-parenthesis
--     column, the docket), rules around the title, counsel two to a row, the party line; then a section break;
--   * the questions presented (when the frontmatter has them), the table of contents (the body's headings to level 3
--     and the certificate of service, a dot leader to the page in a 36 pt column), numbered from 1 in arabic (Rule 21);
--   * the body: headings written here, paragraphs, quotations, lists and footnotes left to pandoc in the styles of
--     docx/reference.xml (Body Text after a paragraph, Body Flush after a heading or quotation; "Note" variants for a
--     paragraph that anchors a footnote, "Keep" for the last paragraph, kept with the signature block);
--   * the Rule 20(7) word-count statement immediately above the signature block, and the certificate of service on a
--     page of its own.
-- The contents' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the page of every
-- heading in that PDF (the needles this filter writes to FORMBOOK_NEEDLES) and renders again with those pages
-- (FORMBOOK_PAGES) until they settle. The page-number footer (FORMBOOK_FOOTERS) and the last section (FORMBOOK_FINAL)
-- are given to fb render here. Rule 17(3): links keep their text and lose their targets.
-- Every case word comes from the frontmatter or the body. No coordinates, no forced line breaks.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt), the spaces between blocks those of the typst template.

local xe = require("docx.xengine")

local BODY, SINGLE = 390, 318      -- typst pitch-body 19.5 pt, pitch-single 15.9 pt
local TEXTW = 9360                 -- 6.5 in
local CAP_LEFT, CAP_PAREN = 4608, 432 -- typst cap-left 3.2 in, cap-paren 0.3 in
local COUNSEL_GUTTER = 312         -- typst counsel-gutter 15.6 pt
local SERVED_GUTTER = 260          -- typst served-gutter 13 pt
local ROW_GAP = 260                -- typst row-gap 13 pt
local TOC_COL = 720                -- typst toc-col 36 pt
local SIG_RIGHT = TEXTW - 6048     -- typst sig-width 4.2 in
local H1_ABOVE, H1_BELOW, H_ABOVE, H_BELOW = 390, 195, 312, 156 -- typst h1-above, h1-below, h-above, h-below
local INDENT = 720                 -- typst para-indent 0.5 in
local TOC_DEPTH = 3
local MARGINS = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="690" w:gutter="0"/>'
local SECT_COVER = "<w:sectPr>" .. MARGINS .. "</w:sectPr>"
local SECT_BODY = '<w:sectPr><w:footerReference w:type="default" r:id="rIdGaFtr"/>' .. MARGINS
  .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'
local FOOTER_P = '<w:p><w:pPr>' .. xe.spacing(0, 0, SINGLE) .. '<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>'
  .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" '
  .. 'w:noHBand="1" w:noVBand="1"/>'

local function fail(msg) error("ga-motion: " .. msg, 0) end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function list(v)
  if v == nil then return {} end
  if type(v) == "string" or v.t == "MetaInlines" or v.t == "MetaString" then return { v } end
  local out = {}
  for _, x in ipairs(v) do out[#out + 1] = x end
  return out
end

local function need(m, key)
  if m[key] == nil then fail("missing required metadata field `" .. key .. "`") end
  return m[key]
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, tab, jc, keep, brk, lines, border, outline,
-- leader }. Single lines unless o.line. Properties in the schema's order.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.border then
    props[#props + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>'
  end
  if o.leader then props[#props + 1] = xe.leader_tab(TEXTW)
  elseif o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

-- A borderless table of fixed column widths, no cell margins; rows: lists of { xml, valign } cells; rows not split.
local function tbl(widths, rows)
  local x = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do x[#x + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  x[#x + 1] = "</w:tblGrid>"
  for _, r in ipairs(rows) do
    x[#x + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for j, c in ipairs(r) do
      local va = c[2] and ('<w:vAlign w:val="' .. c[2] .. '"/>') or ""
      local body = c[1] ~= "" and c[1] or p("", {})
      x[#x + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[j] .. '" w:type="dxa"/>' .. va .. "</w:tcPr>" .. body .. "</w:tc>"
    end
    x[#x + 1] = "</w:tr>"
  end
  x[#x + 1] = "</w:tbl>"
  return table.concat(x)
end

-- Groups of single lines (names, then lines), two to a row, `gutter` apart, ROW_GAP between rows (typst groups).
local function groups(gs, gutter)
  gs = list(gs)
  local n = math.min(#gs, 2)
  local rows = math.ceil(#gs / n)
  local function cell(i, r)
    local g = gs[i]
    if g == nil then return { "" } end
    local lines = {}
    for _, x in ipairs(list(g.names)) do lines[#lines + 1] = x end
    for _, x in ipairs(list(g.lines)) do lines[#lines + 1] = x end
    local body = {}
    for k, l in ipairs(lines) do
      body[#body + 1] = p(xe.inl(l), { after = (k == #lines and r < rows) and ROW_GAP or 0 })
    end
    return { table.concat(body) }
  end
  local half = (TEXTW - gutter) // 2
  local widths = n == 1 and { TEXTW } or { half, gutter, TEXTW - gutter - half }
  local out = {}
  for r = 1, rows do
    if n == 1 then out[#out + 1] = { cell(r, r) }
    else out[#out + 1] = { cell(2 * r - 1, r), { "" }, cell(2 * r, r) } end
  end
  return tbl(widths, out)
end

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60
local needles = {}
local function letters(s) return (s:lower():gsub("[^a-z0-9]", "")) end
local function needle(id, text, context)
  local w1, w2 = text:match("^%s*(%S+)%s+(%S+)")
  local short = letters(w1 and (w1 .. " " .. w2) or text):sub(1, NEEDLE_MAX)
  local long = letters(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  needles[#needles + 1] = table.concat({ id, "B", long, short ~= "" and short or long }, "\t")
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = lab end
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
-- Cover (typst cover)
-- ---------------------------------------------------------------------------

local function cover(m, out)
  out[#out + 1] = p(xe.inl(need(m, "case_number"), { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("IN THE", { b = true }), { jc = "center", before = 312 })
  -- Word has no space before a table: the line above it takes it
  out[#out + 1] = p(xe.runs("SUPREME COURT OF GEORGIA", { b = true }), { jc = "center", after = 390 })

  local left = {}
  local sides = list(need(m, "caption"))
  for i, side in ipairs(sides) do
    for j, n in ipairs(list(side.names)) do
      left[#left + 1] = p(xe.inl(n), { before = (j == 1 and i > 1) and 312 or 0 })
    end
    left[#left + 1] = p(xe.inl(side.designation), { before = 104, jc = "right" })
    if i < #sides then left[#left + 1] = p(xe.runs("v."), { before = 312, jc = "center" }) end
  end
  local docket = {}
  for _, d in ipairs(list(need(m, "docket"))) do docket[#docket + 1] = p(xe.inl(d)) end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_PAREN, TEXTW - CAP_LEFT - CAP_PAREN }, { {
    { table.concat(left), "center" }, { p(xe.runs(")"), { jc = "center" }), "center" }, { table.concat(docket), "center" },
  } })

  -- the rules: an empty 1 pt line with a border below it
  out[#out + 1] = p("", { before = 390, line = 20, border = true })
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(need(m, "title"))), { b = true }), { jc = "center", before = 234 })
  if m.filed_by then out[#out + 1] = p(xe.inl(m.filed_by), { jc = "center", before = 156 }) end
  out[#out + 1] = p("", { before = 234, after = 312, line = 20, border = true })
  out[#out + 1] = groups(need(m, "counsel"), COUNSEL_GUTTER)
  out[#out + 1] = p(xe.inl(need(m, "attorneys_for"), { b = true }), { jc = "center", before = 312 })
  -- the cover's section ends here: an empty paragraph of 1 pt, no footer
  out[#out + 1] = xe.para({ xe.spacing(0, 0, 20), SECT_COVER }, "")
end

-- ---------------------------------------------------------------------------
-- Questions presented (petition: Rule 41(2), before the table of contents; typst questions-page)
-- ---------------------------------------------------------------------------

local function questions(m, out)
  out[#out + 1] = p(xe.runs("QUESTIONS PRESENTED", { b = true }), { jc = "center", after = 260, keep = true })
  for i, q in ipairs(list(m.questions_presented)) do
    out[#out + 1] = p(xe.runs(i .. ".\t") .. xe.inl(q),
      { line = BODY, before = i > 1 and BODY or 0, left = INDENT, hanging = INDENT, tab = INDENT })
  end
end

-- ---------------------------------------------------------------------------
-- Headings, contents, signature, certificate
-- ---------------------------------------------------------------------------

-- A heading (typst show heading): level 1 centered bold, level 2 bold, level 3 bold italic; single lines, kept with
-- the text after it. `top`: it opens a page (no space above it, as typst drops it there).
local function heading(level, content, top, brk)
  local above = top and 0 or (level == 1 and H1_ABOVE or H_ABOVE)
  return p(xe.inl(content, { b = true, i = level == 3 }), { before = above, after = level == 1 and H1_BELOW or H_BELOW,
    keep = true, brk = brk, jc = level == 1 and "center" or "left", outline = level - 1 })
end

local function contents(heads, out, brk)
  out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", after = 208, keep = true, brk = brk })
  for _, h in ipairs(heads) do
    out[#out + 1] = p(xe.inl(h.content) .. xe.runs(xe.LEAD .. (labels[h.id] or "0")),
      { line = BODY, right = TOC_COL, leader = true, lines = true })
  end
end

local function signature(m, out)
  local sig = need(m, "signature")
  local lines = {
    { xe.runs("This submission does not exceed the word-count limit imposed by Rule 20."), BODY },
  }
  if m.date then lines[#lines + 1] = { xe.inl(m.date), SINGLE } end
  lines[#lines + 1] = { xe.runs("Respectfully submitted,"), 208 }
  local block = #lines + 1
  lines[#lines + 1] = { xe.runs("/s/ ") .. xe.inl(sig.signer), 260 }
  lines[#lines + 1] = { xe.runs(pandoc.text.upper(plain(sig.signer))), 0 }
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { xe.inl(l), 0 } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], keep = i < #lines, lines = true, right = i >= block and SIG_RIGHT or nil })
  end
end

local function certificate(m, out)
  local svc = m.service
  out[#out + 1] = heading(1, pandoc.Inlines({ pandoc.Str("Certificate of Service") }), true, true)
  out[#out + 1] = p(xe.inl(svc.statement), { line = BODY, after = 208 })
  out[#out + 1] = groups(svc.served, SERVED_GUTTER)
  if svc.note then out[#out + 1] = p(xe.inl(svc.note), { line = BODY, before = 208 }) end
  local signer = need(m, "signature").signer
  out[#out + 1] = p(xe.runs("/s/ ") .. xe.inl(signer), { before = BODY, keep = true })
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(signer))))
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 21-2-385(b)": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

-- A paragraph pandoc writes (its footnotes stay notes): Body Text after a paragraph, Body Flush elsewhere; the
-- "Keep" variant for the last paragraph, else the "Note" variant when it anchors a footnote.
local function styled(inlines, after_par, keep)
  local base = after_par and "Body Text" or "Body Flush"
  local name = base
  if keep then name = after_par and "Body Keep" or "Body Flush Keep"
  elseif has_note(inlines) then name = base .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = name })
end

-- the words after block i (for a heading's needle): the next heading's text or the next block's first words
local function after_text(blocks, i)
  local b = blocks[i + 1]
  if b == nil then return "" end
  return plain(b):sub(1, 40)
end

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Link = function(el) return el.content end })
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local m = doc.meta
  -- the metadata goes through xe.inl, which applies the break rules itself; the blocks pandoc writes get them here
  local blocks = pandoc.Blocks(doc.blocks):walk({ Inlines = xe.inlines })
  local orig = doc.blocks -- the headings, written here through xe.inl

  -- the headings for the contents, in document order, and their needles
  local heads, first_id = {}, "S:first"
  if m.questions_presented then
    local q1 = list(m.questions_presented)[1]
    needle(first_id, "Questions Presented", plain(q1))
  else
    local h1
    for _, b in ipairs(blocks) do if b.t == "Header" then h1 = b; break end end
    needle(first_id, "Table of Contents", h1 and plain(h1.content) or "")
  end
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= TOC_DEPTH then
      local h = { id = "H:" .. (#heads + 1), content = orig[i].content }
      heads[#heads + 1] = h
      needle(h.id, plain(b.content), after_text(blocks, i))
    end
  end
  if m.service then
    local h = { id = "H:cert", content = pandoc.Inlines({ pandoc.Str("Certificate of Service") }) }
    heads[#heads + 1] = h
    needle(h.id, "Certificate of Service", plain(m.service.statement):sub(1, 40))
  end
  needles[#needles + 1] = "#section\t" .. first_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdGaFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", SECT_BODY)

  local raw = {}
  cover(m, raw)
  if m.questions_presented then questions(m, raw) end
  contents(heads, raw, m.questions_presented ~= nil)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end

  -- the last paragraph stays with the signature block
  local last = 0
  for i, b in ipairs(blocks) do if b.t == "Para" or b.t == "Plain" then last = i end end
  local prev
  for i, b in ipairs(blocks) do
    local after_par = prev ~= nil and (prev.t == "Para" or prev.t == "Plain")
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b.level, orig[i].content, prev == nil, prev == nil))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled(b.content, after_par, i == last)
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(b.content) do
        if x.t ~= "Para" and x.t ~= "Plain" then fail("a block quotation holds only paragraphs") end
        out[#out + 1] = pandoc.Div({ pandoc.Para(x.content) }, { ["custom-style"] = "Block Text" })
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    elseif b.t == "HorizontalRule" then
      -- nothing
    else
      fail("unsupported block " .. b.t)
    end
    prev = b
  end

  local tail = {}
  signature(m, tail)
  if m.service then certificate(m, tail) end
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
