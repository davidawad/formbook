-- Georgia Supreme Court brief, DOCX engine (docs/DOCX.md). Family A: the double-spaced briefs (answering,
-- opening, reply), built to answering-brief/typst/ga-answering-brief.typ. The cover, the table of contents,
-- the table of authorities, the closing and the certificate of service are built here from the sample's
-- frontmatter; the body keeps its markdown structure. Sections: cover (no folio), front matter (roman), body
-- (arabic from 1). The footer and the section references are fixed by docx/render.sh.
--
-- Page numbers in the TOC and TOA come from a first render. docx/render.sh runs this filter with GA_PASS=1:
-- every body heading and every citation then carries a 1-pt white marker (zqh<n>zq, zqa<k>zq) that the
-- PDF text shows and the layout does not. It reads the pages back and runs the filter again with GA_PAGES
-- set to that file (lines: "h<n><TAB>pages" and "a<k><TAB>pages"), which writes the numbers and no markers.

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

local TOC_DEPTH = 2

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
  if meta[key] == nil then error("ga-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- a paragraph in one of the reference's custom styles (see build-reference.sh)
local function para(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- an empty paragraph of the given height (a raw paragraph: pandoc drops an empty Para in a Div)
local function gap(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. (style or "Gap") .. '"/></w:pPr></w:p>')
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

-- a section break: the paragraph carries the sectPr of the section that ends here. The footer
-- reference is rIdGaFooter here; docx/render.sh replaces it with the id pandoc gives the footer part.
local function section_break(footer, fmt)
  local refs = footer and '<w:footerReference w:type="default" r:id="rIdGaFooter"/>' or ""
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
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

-- ---- the cover (answering-brief ga-answering-brief.typ, cover) -----------------------------------

local function cover(meta)
  local out = {}
  local function add(b) out[#out + 1] = b end

  add(para("Centered", { bold({ pandoc.Str("IN THE SUPREME COURT") }) }))
  add(para("Centered", { bold({ pandoc.Str("STATE OF GEORGIA") }) }))
  add(gap("GapLarge"))

  -- caption (left) and docket (right)
  local left = {}
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do left[#left + 1] = para("Single", inlines(n)) end
    left[#left + 1] = para("Indent", inlines(side.designation))
    if i < #sides then
      left[#left + 1] = gap("GapSmall")
      left[#left + 1] = para("Indent", { pandoc.Str("v.") })
      left[#left + 1] = gap("GapSmall")
    end
  end
  local right = { para("Single", { pandoc.Str("Case No. " .. plain(need(meta, "case_number"))) }) }
  if meta.lower_court_case then
    right[#right + 1] = gap("GapSmall")
    right[#right + 1] = para("Single", { pandoc.Str("Lower Court Case No. " .. plain(meta.lower_court_case)) })
  end
  add(grid({ left, right }, { 0.5, 0.5 }))
  add(gap("GapMid"))

  add(para("Centered", { bold(inlines(need(meta, "brief_title"))) }))
  add(gap("GapXL"))

  -- counsel: one column per group, names then lines (the lines in italics, as the exemplar sets them)
  local counsel = need(meta, "counsel")
  local cells = {}
  for _, g in ipairs(counsel) do
    local c = {}
    for _, n in ipairs(g.names) do c[#c + 1] = para("Single", inlines(n)) end
    for _, l in ipairs(g.lines) do c[#c + 1] = para("Single", { pandoc.Emph(inlines(l)) }) end
    cells[#cells + 1] = c
  end
  add(grid(cells))
  return out
end

-- ---- table of contents and authorities (Rule 19) -------------------------------------------------

local KINDS = {
  { key = "case", title = "CASES" },
  { key = "statute", title = "STATUTES" },
  { key = "constitution", title = "CONSTITUTIONAL PROVISIONS" },
  { key = "rule", title = "RULES" },
  { key = "other", title = "OTHER AUTHORITIES" },
}

-- the authorities, numbered k in key order (the same numbering in both passes)
local function authority_list(meta)
  local keys, list = {}, {}
  if meta.authorities then
    for key, _ in pairs(meta.authorities) do keys[#keys + 1] = key end
  end
  table.sort(keys)
  for k, key in ipairs(keys) do
    local a = meta.authorities[key]
    list[key] = { k = k, kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
  end
  return list
end

local function sort_key(a)
  if a.sort then return plain(a.sort):lower() end
  if a.name then return plain(a.name):lower() end
  return plain(a.cite):lower()
end

local function pages_text(key)
  if PASS1 or not HAVE_PAGES then return "0" end
  return PAGES[key]
end

local function toc(headers)
  local out = { para("FrontTitle", { bold({ pandoc.Str("TABLE OF CONTENTS") }) }) }
  for _, h in ipairs(headers) do
    if h.level <= TOC_DEPTH then
      local page = PAGES["h" .. h.idx] or (not HAVE_PAGES and "0") or ""
      local inl = pandoc.Inlines(h.content)
      inl:insert(TAB)
      inl:insert(pandoc.Str(page))
      out[#out + 1] = para("TOCEntry", inl)
    end
  end
  return out
end

local function toa(auths, meta)
  local out = { para("FrontTitleTight", { bold({ pandoc.Str("TABLE OF AUTHORITIES") }) }) }
  for _, kind in ipairs(KINDS) do
    local rows = {}
    for key, a in pairs(auths) do
      if a.kind == kind.key then rows[#rows + 1] = { key = key, a = a } end
    end
    if #rows > 0 then
      table.sort(rows, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
      out[#out + 1] = para("TOACategory", { pandoc.Str(kind.title) })
      for _, r in ipairs(rows) do
        local pages = pages_text("a" .. r.a.k)
        if pages and pages ~= "" then
          local inl = pandoc.Inlines({})
          if kind.key == "case" then
            inl:insert(pandoc.Emph(inlines(r.a.name)))
          else
            inl:extend(inlines(r.a.name))
          end
          if r.a.cite then
            inl:insert(pandoc.Str(","))
            inl:insert(pandoc.Space())
            inl:extend(inlines(r.a.cite))
          end
          inl:insert(TAB)
          inl:insert(pandoc.Str(pages))
          out[#out + 1] = para("TOAEntry", inl)
        end
      end
    end
  end
  return out
end

-- ---- closing and certificate (typst: closing, signature-blocks, certificate-of-service) ---------

local CLOSING_SENTENCE = "This submission does not exceed the word-count limit imposed by Rule 20."

-- the date of the closing line: the frontmatter "date", read before Pandoc() clears it from the metadata
local DATE_TEXT = ""
local function date_text()
  return DATE_TEXT
end

local function signature_blocks(meta)
  local groups = need(meta, "signature")
  local cells = {}
  for _, g in ipairs(groups) do
    local c = {}
    for _, l in ipairs(g.lines) do c[#c + 1] = para("SigSingle", inlines(l)) end
    cells[#cells + 1] = c
  end
  return grid(cells)
end

-- the closing block stays on one page (typst: block(breakable: false)): keep-with-next on its lines
local function closing(meta)
  local out = {}
  out[#out + 1] = para("ClosingKeep", { pandoc.Str(CLOSING_SENTENCE) })
  out[#out + 1] = para("ClosingKeep", { pandoc.Str("Respectfully submitted, this " .. date_text() .. ".") })
  out[#out + 1] = gap("GapLargeKeep")
  out[#out + 1] = signature_blocks(meta)
  return out
end

local function certificate(meta)
  local svc = need(meta, "service")
  local out = { para("FrontTitleTight", { bold({ pandoc.Str("CERTIFICATE OF SERVICE") }) }) }
  if svc.email then
    out[#out + 1] = para("BodyNoIndent", { pandoc.Str("I certify that there is a prior agreement with counsel to allow documents in a PDF format sent via e-mail to suffice for service under Supreme Court Rule 14. I further certify that I have on this day served true and correct copies of the foregoing upon the following counsel of record via e-mail:") })
  else
    out[#out + 1] = para("BodyNoIndent", { pandoc.Str("I certify that I have on this day served true and correct copies of the foregoing upon the following counsel of record by " .. plain(svc.method) .. ":") })
  end
  out[#out + 1] = gap("GapLarge")
  local cells = {}
  for _, g in ipairs(svc.recipients) do
    local c = {}
    for _, n in ipairs(g.names) do c[#c + 1] = para("Single", inlines(n)) end
    for _, l in ipairs(g.lines) do c[#c + 1] = para("Single", inlines(l)) end
    cells[#cells + 1] = c
  end
  out[#out + 1] = grid(cells)
  out[#out + 1] = gap("GapLarge")
  out[#out + 1] = para("BodyNoIndent", { pandoc.Str("Respectfully submitted, this " .. date_text() .. ".") })
  out[#out + 1] = gap("GapLarge")
  out[#out + 1] = signature_blocks(meta)
  return out
end

-- ---- the document --------------------------------------------------------------------------------

-- Headings, in document order. Pass 1 puts a marker in each (the TOC numbering is hi, the order of the
-- headers). A level-2 or level-3 heading that follows body text (or opens the body) is a paragraph in the
-- Heading<n>Body style: typst sets the space above it against the paragraph spacing, which LibreOffice
-- and Word add to it, so it has none here (see the reference). Level 1 and headings after a heading keep
-- the heading style.
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
      after_variant = false
      if b.level >= 2 and (prev == nil or prev.t ~= "Header") then
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Heading" .. b.level .. "Body" }))
        after_variant = true
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
  local auths = authority_list(meta)
  -- pandoc would print the date as a title block; the closing carries it instead
  DATE_TEXT = plain(need(meta, "date"))
  meta.date = nil

  -- headers in document order (the TOC numbering), and citations (toa: links) in the body
  local headers = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      headers[#headers + 1] = { idx = #headers + 1, level = b.level, content = b.content }
    end
  end

  doc.blocks = header_blocks(doc.blocks)
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return el.content end
      if not auths[key] then
        io.stderr:write("ga-brief: warning: link `toa:" .. key .. "` has no entry under `authorities:`; no table entry\n")
        return el.content
      end
      local inl = pandoc.Inlines(el.content)
      local m = marker("zqa" .. auths[key].k .. "zq")
      if m then inl:insert(m) end
      return inl
    end,
  })
  local blocks = doc.blocks
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  addall(cover(meta))
  add(section_break(false, nil))
  addall(toc(headers))
  add(page_break())
  if meta.authorities then addall(toa(auths, meta)) end
  add(section_break(true, "lowerRoman"))
  addall(blocks)
  addall(closing(meta))
  if meta.service then
    add(page_break())
    addall(certificate(meta))
  end

  -- pandoc writes the metadata (date) as paragraphs of its own; the closing above carries it
  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
