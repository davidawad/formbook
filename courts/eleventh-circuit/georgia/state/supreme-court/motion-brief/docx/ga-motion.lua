-- Georgia Supreme Court motion or petition, DOCX engine (docs/DOCX.md). Family B: the 1.5-spaced motion
-- and petition, built to motion-brief/typst/ga-motion-brief.typ (petition-for-review adds the questions
-- presented). The cover, the questions presented, the table of contents, the closing and the certificate of
-- service are built here from the sample's frontmatter; the body keeps its markdown structure. Sections: cover
-- (no folio), then the body from page 1 (arabic). The footer and the section reference are fixed by docx/render.sh.
--
-- Page numbers in the TOC come from a first render, as in ga-brief.lua: pass 1 (GA_PASS=1) marks each body
-- heading (zqh<n>zq) and the certificate heading (zqh0zq); docx/render.sh reads the pages back and runs the
-- filter again with GA_PAGES set (lines "h<n><TAB>pages"), which writes the numbers and no markers.

local PASS1 = os.getenv("GA_PASS") == "1"
local PAGES = {}
if os.getenv("GA_PAGES") and os.getenv("GA_PAGES") ~= "" then
  local f = assert(io.open(os.getenv("GA_PAGES"), "r"))
  for line in f:lines() do
    local key, val = line:match("^(%S+)\t(.*)$")
    if key then PAGES[key] = val end
  end
  f:close()
end
local HAVE_PAGES = next(PAGES) ~= nil

local TOC_DEPTH = 3
-- the date of the signature block: the frontmatter "date", read before Pandoc() clears it from the metadata
local DATE_TEXT = ""

-- ---- helpers --------------------------------------------------------------------------------------

-- a frontmatter value as inlines (pandoc has already read the YAML string as markdown)
local function inlines(v)
  if v == nil then return pandoc.Inlines({}) end
  if pandoc.utils.type(v) == "Inlines" then return pandoc.Inlines(v) end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function need(meta, key)
  if meta[key] == nil then error("ga-motion: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- a paragraph in one of the reference's custom styles (see build-reference.sh)
local function para(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- an empty paragraph of the given height (a raw paragraph: pandoc drops an empty Para in a Div)
local function gap(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

-- an empty paragraph that keeps with the next one (the signature block stays on one page)
local function gap_keep(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/><w:keepNext/></w:pPr></w:p>')
end

-- a full-width rule: an empty paragraph with a bottom border (typst: line(length: 100%))
local function rule()
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>'
    .. '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:p>')
end

local function bold(inl) return pandoc.Strong(inl) end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- the 1-pt marker of the first render (pass 1 only); see the header comment
local function marker(tag)
  if not PASS1 then return nil end
  return pandoc.RawInline("openxml", '<w:r><w:rPr><w:color w:val="FFFFFF"/><w:sz w:val="2"/><w:szCs w:val="2"/></w:rPr><w:t>' .. tag .. "</w:t></w:r>")
end

local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- a section break: the paragraph carries the sectPr of the section that ends here. The cover has no footer;
-- the body (numbering continues from the cover, which is page 0) has the page number. A section break, not a page
-- break, starts the body and the certificate: LibreOffice drops the space above a heading at the top of a page
-- that a page break starts, and typst keeps it (the level-1 heading of the body sits 0.9 em below the top margin).
local function section_break(footer, restart)
  local refs = footer and '<w:footerReference w:type="default" r:id="rIdGaFooter"/>' or ""
  local pg = restart and '<w:pgNumType w:fmt="decimal" w:start="1"/>' or ""
  return pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. '<w:sectPr>' .. refs .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. '</w:sectPr></w:pPr></w:p>')
end

-- a borderless table: one cell per block list, widths as fractions of the text width
local function grid(cells, widths)
  local colspecs = {}
  for i = 1, #cells do
    colspecs[i] = { pandoc.AlignDefault, widths and widths[i] or (1 / #cells) }
  end
  local row = {}
  for i, c in ipairs(cells) do row[i] = pandoc.Cell(c) end
  return pandoc.Table(pandoc.Caption(), colspecs, pandoc.TableHead({}),
    { pandoc.TableBody({ pandoc.Row(row) }) }, pandoc.TableFoot({}))
end

-- a borderless table of at most ncols columns: the cells wrap onto the next row (typst: min(n, 2) columns)
local function grid_wrap(cells, ncols)
  local colspecs, rows = {}, {}
  for i = 1, ncols do colspecs[i] = { pandoc.AlignDefault, 1 / ncols } end
  for i = 1, #cells, ncols do
    local row = {}
    for j = 0, ncols - 1 do
      row[#row + 1] = pandoc.Cell(cells[i + j] or { pandoc.Para({}) })
    end
    rows[#rows + 1] = pandoc.Row(row)
  end
  return pandoc.Table(pandoc.Caption(), colspecs, pandoc.TableHead({}), { pandoc.TableBody(rows) }, pandoc.TableFoot({}))
end

-- ---- the cover (motion-brief ga-motion-brief.typ, cover) -----------------------------------------

local function cover(meta)
  local out = {}
  local function add(b) out[#out + 1] = b end

  add(para("Centered", { bold(inlines(need(meta, "case_number"))) }))
  add(gap("Gap12"))
  add(para("Centered", { bold({ pandoc.Str("IN THE") }) }))
  add(para("Centered", { bold({ pandoc.Str("SUPREME COURT OF GEORGIA") }) }))
  add(gap("Gap15"))

  -- caption: the names and designation on the left, a close-parenthesis column, the docket on the right
  local left = {}
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do left[#left + 1] = para("Single", inlines(n)) end
    left[#left + 1] = gap("Gap04")
    left[#left + 1] = para("RightSingle", inlines(side.designation))
    if i < #sides then
      left[#left + 1] = gap("Gap12")
      left[#left + 1] = para("Centered", { pandoc.Str("v.") })
      left[#left + 1] = gap("Gap12")
    end
  end
  local docket = {}
  for _, d in ipairs(need(meta, "docket")) do docket[#docket + 1] = para("Single", inlines(d)) end
  add(grid({ left, { para("Centered", { pandoc.Str(")") }) }, docket }, { 0.5, 0.06, 0.44 }))
  add(gap("Gap15"))

  add(rule())
  add(gap("Gap09"))
  add(para("Centered", { bold({ pandoc.Str(string.upper(plain(need(meta, "title")))) }) }))
  if meta.filed_by then
    add(gap("Gap06"))
    add(para("Centered", inlines(meta.filed_by)))
  end
  add(gap("Gap09"))
  add(rule())
  add(gap("Gap12"))

  -- counsel: one column per group, names then lines (the lines are markdown, as written in the frontmatter)
  local cells = {}
  for _, g in ipairs(need(meta, "counsel")) do
    local c = {}
    for _, n in ipairs(g.names) do c[#c + 1] = para("Single", inlines(n)) end
    for _, l in ipairs(g.lines) do c[#c + 1] = para("Single", inlines(l)) end
    cells[#cells + 1] = c
  end
  add(grid_wrap(cells, 2))
  add(gap("Gap12"))
  add(para("Centered", { bold(inlines(need(meta, "attorneys_for"))) }))
  return out
end

-- ---- questions presented (petition-for-review: Rule 41(2), before the table of contents) ----------

local function questions(meta)
  local out = { para("FrontTitle", { bold({ pandoc.Str("QUESTIONS PRESENTED") }) }) }
  for i, q in ipairs(need(meta, "questions_presented")) do
    local inl = pandoc.Inlines({ pandoc.Str(i .. ".") , pandoc.Space() })
    inl:extend(inlines(q))
    out[#out + 1] = para("Question", inl)
  end
  return out
end

-- ---- table of contents (typst: outline, depth 3, the certificate of service included) -------------

local function toc(headers)
  local out = { para("FrontTitle", { bold({ pandoc.Str("TABLE OF CONTENTS") }) }) }
  local function entry(inl, key)
    local page = PAGES[key] or (not HAVE_PAGES and "0") or ""
    local line = pandoc.Inlines(inl)
    line:insert(TAB)
    line:insert(pandoc.Str(page))
    out[#out + 1] = para("TOCEntry", line)
  end
  for _, h in ipairs(headers) do
    if h.level <= TOC_DEPTH then entry(h.content, "h" .. h.idx) end
  end
  entry({ pandoc.Str("Certificate of Service") }, "h0")
  return out
end

-- ---- closing and certificate (typst: signature, service-certificate) -----------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = gap_keep("Gap12")
  out[#out + 1] = para("SigSingle", { pandoc.Str("This submission does not exceed the word-count limit imposed by Rule 20.") })
  out[#out + 1] = gap_keep("Gap10")
  if DATE_TEXT ~= "" then
    out[#out + 1] = para("SigSingle", { pandoc.Str(DATE_TEXT) })
    out[#out + 1] = gap_keep("Gap08")
  end
  out[#out + 1] = para("SigSingle", { pandoc.Str("Respectfully submitted,") })
  out[#out + 1] = gap_keep("Gap10")
  out[#out + 1] = para("SigBlock", { pandoc.Str("/s/ " .. plain(sig.signer)) })
  out[#out + 1] = para("SigBlock", { pandoc.Str(string.upper(plain(sig.signer))) })
  for _, l in ipairs(sig.lines) do out[#out + 1] = para("SigBlock", inlines(l)) end
  return out
end

local function certificate(meta)
  local svc = need(meta, "service")
  local out = {}
  -- the heading is numbered 0 for the table of contents (a level-1 heading, in the outline)
  local inl = pandoc.Inlines({})
  local m = marker("zqh0zq")
  if m then inl:insert(m) end
  inl:insert(pandoc.Str("Certificate of Service"))
  out[#out + 1] = pandoc.Header(1, inl)
  out[#out + 1] = para("BodyNoIndent", inlines(svc.statement))
  out[#out + 1] = gap("Gap08")
  local cells = {}
  for _, g in ipairs(svc.served) do
    local c = {}
    for _, n in ipairs(g.names) do c[#c + 1] = para("Single", inlines(n)) end
    for _, l in ipairs(g.lines) do c[#c + 1] = para("Single", inlines(l)) end
    cells[#cells + 1] = c
  end
  out[#out + 1] = grid_wrap(cells, 2)
  if svc.note then
    out[#out + 1] = gap("Gap08")
    out[#out + 1] = para("BodyNoIndent", inlines(svc.note))
  end
  out[#out + 1] = gap("Gap10")
  out[#out + 1] = gap("Gap06")
  out[#out + 1] = para("SigBlock", { pandoc.Str("/s/ " .. plain(need(meta, "signature").signer)) })
  out[#out + 1] = para("SigBlock", { pandoc.Str(string.upper(plain(need(meta, "signature").signer))) })
  return out
end

-- ---- the document --------------------------------------------------------------------------------

-- The space above a heading depends on what comes before it (see the reference): after body text the heading
-- style is Heading<n>Body; a level-2 or level-3 heading that opens the body is too; a level-1 heading at the top of
-- the body is the plain heading style (typst keeps its space there). Other headings keep the heading style.
local function body_variant(level, prev)
  local after_body = prev ~= nil and prev.t ~= "Header"
  if level == 1 then return after_body and "Heading1Body" or nil end
  if prev == nil or after_body then return "Heading" .. level .. "Body" end
  return nil
end

-- Headings, in document order. Pass 1 puts a marker in each (the TOC numbering is hi, the order of the headers).
local function header_blocks(blocks)
  local out, hi, prev = {}, 0, nil
  local after_variant = false -- the paragraph after a Heading<n>Body opens its section: no first-line indent
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      hi = hi + 1
      local inl = pandoc.Inlines({})
      local m = marker("zqh" .. hi .. "zq")
      if m then inl:insert(m) end
      inl:extend(b.content)
      local style = body_variant(b.level, prev)
      after_variant = style ~= nil
      if style then
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
      else
        b.content = inl
        out[#out + 1] = b
      end
    elseif after_variant and b.t == "Para" then
      out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "BodyNoIndent" }))
      after_variant = false
    else
      out[#out + 1] = b
      after_variant = false
    end
    prev = b
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  DATE_TEXT = plain(meta.date)
  meta.date = nil -- pandoc would print the date as a title block; the signature block carries it

  local headers = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      headers[#headers + 1] = { idx = #headers + 1, level = b.level, content = b.content }
    end
  end

  doc.blocks = header_blocks(doc.blocks)
  -- Rule 17(3): no links to other documents or sites; a link keeps its text
  doc = doc:walk({
    Link = function(el) return el.content end,
  })
  local blocks = doc.blocks
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  addall(cover(meta))
  add(section_break(false, false))
  if meta.questions_presented then
    addall(questions(meta))
    add(page_break())
  end
  addall(toc(headers))
  add(section_break(true, true))
  addall(blocks)
  addall(signature(meta))
  if meta.service then
    add(section_break(true, false))
    addall(certificate(meta))
  end

  -- pandoc writes the metadata (title, date) as paragraphs of its own; the cover and closing above carry them
  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
