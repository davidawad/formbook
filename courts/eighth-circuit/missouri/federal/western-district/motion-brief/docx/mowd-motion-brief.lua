-- W.D. Mo. suggestions in support of a motion, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document.
-- The same content, numbering and page layout as typst/mowd-motion-brief.typ, from the same markdown contract:
--   section 1: the cover (no page number);
--   section 2: the table of contents and the table of authorities (roman numbers);
--   section 3: the body, the signature block and the certificate of service (arabic numbers from 1).
-- Paragraphs are pandoc Divs with the custom styles of reference.docx (build-reference.sh). The inline markdown
-- (italics, quotes) stays pandoc's. Heading numbers and the TOC/TOA are written as text, and their page numbers come
-- from a first pass: render.sh lays the document out, finds the page of every heading and every authority link on the
-- PDF, and runs this filter again with those numbers (env MOWD_PAGES). The filter also writes the search list for that
-- pass (env MOWD_SIDECAR): one line per heading ("H") and one per authority link ("N").
-- Known limits: see ../README.md "Engines" (the page numbers are the LibreOffice layout; Word may paginate differently).

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local KIND_ORDER = { "case", "constitution", "statute", "regulation", "rule", "other" }
local KIND_TITLE = {
  case = "Cases", constitution = "Constitutional Provisions", statute = "Statutes",
  regulation = "Regulations", rule = "Rules", other = "Other Authorities",
}
local SECT_XML = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local SECT_COVER = '<w:sectPr><w:type w:val="nextPage"/>' .. SECT_XML .. '</w:sectPr>'
local SECT_FRONT = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:type w:val="nextPage"/>' .. SECT_XML ..
  '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'

local function styled(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

local function para(name, inlines)
  return styled(name, { pandoc.Para(inlines) })
end

-- An empty paragraph in a style (pandoc drops empty paragraphs in a Div, so the spacers are written here).
local function spacer(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

local function raw_para(sect_xml)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' ..
    sect_xml .. '</w:pPr></w:p>')
end

-- A metadata value as inlines (YAML strings are parsed as markdown by pandoc).
local function inlines_of(v)
  if v == nil then return pandoc.Inlines({}) end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" and v[1] and v[1].t == "Para" then return v[1].content end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- A table with no borders: one row per list of cells, each cell a list of blocks.
local function borderless_table(widths, rows)
  local specs = {}
  for i, w in ipairs(widths) do specs[i] = { pandoc.AlignDefault, w } end
  local body = {}
  for _, r in ipairs(rows) do
    local cells = {}
    for _, c in ipairs(r) do cells[#cells + 1] = pandoc.Cell(c) end
    body[#body + 1] = pandoc.Row(cells)
  end
  return pandoc.Table(pandoc.Caption(), specs, pandoc.TableHead(), { pandoc.TableBody(body) }, pandoc.TableFoot())
end

local function xml_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function xml_para(style, text, bold)
  local rpr = bold and "<w:rPr><w:b/></w:rPr>" or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr><w:r>' .. rpr ..
    '<w:t xml:space="preserve">' .. xml_escape(text) .. "</w:t></w:r></w:p>"
end

-- A signature row that may not break across pages (the typst block is unbreakable): left cell empty,
-- right cell the lines. pandoc tables cannot carry w:cantSplit, so this is WordprocessingML.
local function signature_row(right_xml)
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblStyle w:val="Table"/><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4464"/><w:gridCol w:w="4896"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/></w:tcPr><w:p/></w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/></w:tcPr>' .. right_xml .. '</w:tc>' ..
    '</w:tr></w:tbl>')
end

-- ---------------------------------------------------------------------------
-- Inputs from render.sh (the first pass has none: the page numbers are placeholders)
-- ---------------------------------------------------------------------------

local PAGE_OF = nil -- PAGE_OF.H[i] (heading i) and PAGE_OF.K[key] (authority key), once the first pass is laid out

local function load_pages()
  local path = os.getenv("MOWD_PAGES")
  if path == nil or path == "" then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local pages = { H = {}, K = {} }
  for line in f:lines() do
    local kind, k, v = line:match("^(%a)\t([^\t]*)\t(.*)$")
    if kind == "H" then pages.H[tonumber(k)] = v end
    if kind == "K" then pages.K[k] = v end
  end
  f:close()
  return pages
end

local function heading_page(i)
  if PAGE_OF == nil then return "0" end
  local v = PAGE_OF.H[i]
  if v == nil then error("mowd-motion-brief: no page for heading " .. i .. " (render.sh must lay out pass 1 first)") end
  return v
end

local function authority_pages(key)
  if PAGE_OF == nil then return "0" end
  local v = PAGE_OF.K[key]
  if v == nil then error("mowd-motion-brief: no page for authority " .. key) end
  return v
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

local function cover(m, out)
  out[#out + 1] = para("MowdCourtTitle", { pandoc.Str("UNITED STATES DISTRICT COURT") })
  if m.division ~= nil then
    out[#out + 1] = para("MowdCourtTitle", { pandoc.Str("FOR THE WESTERN DISTRICT OF MISSOURI") })
    out[#out + 1] = para("MowdDivision", { pandoc.Strong({ pandoc.Str(text_of(m.division):upper()) }) })
  else
    out[#out + 1] = para("MowdCourtTitleLast", { pandoc.Str("FOR THE WESTERN DISTRICT OF MISSOURI") })
  end

  -- Caption: the parties left, the separator ("v." or "vs.") between the sides; the case number right.
  local between = (m.caption.between ~= nil) and text_of(m.caption.between) or "v."
  local left = {}
  for k, p in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = para("MowdCaptionLine", { pandoc.Str(between) }) end
    for _, n in ipairs(p.names) do
      left[#left + 1] = para("MowdCaptionLine", inlines_of(n))
    end
    left[#left + 1] = para("MowdCaptionLine", inlines_of(p.designation))
  end
  local right = { para("MowdCaptionRight", { pandoc.Str("Case No. " .. text_of(m.case_number)) }) }
  out[#out + 1] = borderless_table({ 3.25, 0.25, 3.0 }, { { left, {}, right } })
  out[#out + 1] = para("MowdCoverTitle", { pandoc.Strong(inlines_of(m.title)) })
end

-- ---------------------------------------------------------------------------
-- Headings: numbered I., A., 1., a. unless the heading has its own number or is Introduction / Certificate
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return string.upper(out)
end

local function starts_word(s, word)
  if s:sub(1, #word) ~= word then return false end
  local nxt = s:sub(#word + 1, #word + 1)
  return nxt == "" or not nxt:match("%a")
end

local function unnumbered(plain)
  return starts_word(plain, "Introduction") or starts_word(plain, "Certificate of Service")
end

-- An own number at the start of the heading ("I.", "A.", "12.", "a."): returns the label and the rest.
local function split_own_number(inl)
  local first = inl[1]
  if first == nil or first.t ~= "Str" then return nil, inl end
  local n = first.text:match("^([IVXLC]+)%.$") or first.text:match("^([A-H])%.$") or
    first.text:match("^(%d+)%.$") or first.text:match("^([a-h])%.$")
  if n == nil then return nil, inl end
  local i = 2
  while inl[i] ~= nil and inl[i].t == "Space" do i = i + 1 end
  local rest = pandoc.Inlines({})
  for j = i, #inl do rest:insert(inl[j]) end
  return n .. ".", rest
end

local COUNTERS = { 0, 0, 0, 0 }

local function label_for(level, k)
  if level == 1 then return roman(k) .. "." end
  if level == 2 then return string.char(64 + k) .. "." end
  if level == 3 then return tostring(k) .. "." end
  return string.char(96 + k) .. "."
end

-- Returns the output blocks for one heading and records it in HEADS (the TOC entry and the search text).
local function heading(b, heads)
  local level = b.level
  if level > 4 then error("mowd-motion-brief: heading level " .. level .. " has no style") end
  local plain = pandoc.utils.stringify(b.content)
  local label, body = "", b.content
  if unnumbered(plain) then
    local style = (starts_word(plain, "Certificate of Service")) and "MowdHeadingCapsBreak" or "MowdHeadingCaps"
    heads[#heads + 1] = { level = 1, label = "", inl = body, search = plain:upper() }
    return para(style, body)
  end
  local own, rest = split_own_number(b.content)
  if own ~= nil then
    label, body = own, rest
  else
    COUNTERS[level] = COUNTERS[level] + 1
    for j = level + 1, 4 do COUNTERS[j] = 0 end
    label = label_for(level, COUNTERS[level])
  end
  heads[#heads + 1] = { level = level, label = label, inl = body, search = pandoc.utils.stringify(body) }
  local inl = pandoc.Inlines({ pandoc.Str(label), TAB })
  inl:extend(body)
  return para("MowdHeadingNum" .. level, inl)
end

-- ---------------------------------------------------------------------------
-- Body: paragraphs, block quotations, lists; authority links are recorded and written as plain text
-- ---------------------------------------------------------------------------

local function registry_of(m)
  local reg = {}
  if m.authorities == nil then return reg end
  for key, a in pairs(m.authorities) do
    reg[key] = {
      kind = text_of(a.kind),
      name = (a.name ~= nil) and text_of(a.name) or nil,
      cite = text_of(a.cite),
      sort = (a.sort ~= nil) and text_of(a.sort) or nil,
    }
    if reg[key].kind == "" then error("mowd-motion-brief: authority " .. key .. " has no kind") end
  end
  return reg
end

local function body_blocks(doc, reg, heads, needles)
  local out = {}
  local function body_inlines(inl)
    return inl:walk({
      Link = function(el)
        if el.target:sub(1, 4) ~= "toa:" then return nil end
        local key = el.target:sub(5)
        if reg[key] == nil then error("mowd-motion-brief: authority key not in the registry: " .. key) end
        local needle = pandoc.utils.stringify(el.content)
        needles[#needles + 1] = { key = key, needle = needle }
        return el.content
      end,
    })
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b, heads)
    elseif b.t == "Para" then
      out[#out + 1] = para("MowdBodyPara", body_inlines(b.content))
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" then error("mowd-motion-brief: a block quotation holds only paragraphs") end
        out[#out + 1] = para("MowdBlockQuote", body_inlines(q.content))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        if first == nil or (first.t ~= "Plain" and first.t ~= "Para") or #item > 1 then
          error("mowd-motion-brief: a list item holds one paragraph")
        end
        local marker = (b.t == "OrderedList") and (tostring((b.start or 1) + i - 1) .. ".") or "•"
        local inl = pandoc.Inlines({ pandoc.Str(marker), TAB })
        inl:extend(body_inlines(first.content))
        out[#out + 1] = para("MowdListItem", inl)
      end
    else
      error("mowd-motion-brief: unsupported block " .. b.t)
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

local function signature_lines(sig)
  local right = xml_para("MowdSigRespect", "Respectfully submitted,", false) ..
    xml_para("MowdSigSigner", text_of(sig.signer), true)
  for _, line in ipairs(sig.lines) do
    right = right .. xml_para("MowdSigLine", text_of(line), false)
  end
  return right
end

local function certificate_blocks(m, cert_head)
  local svc = m.service
  local out = { cert_head }
  out[#out + 1] = para("MowdBodyPara", pandoc.Inlines({
    pandoc.Str("I hereby certify that on " .. text_of(svc.date) .. ", I caused a copy of the foregoing document to be sent to all counsel of record via this Court’s CM/ECF system and via electronic mail to " .. text_of(svc.recipients) .. "."),
  }))
  out[#out + 1] = spacer("MowdSpacer")
  out[#out + 1] = signature_row(xml_para("MowdSigRespect", text_of(svc.signer), true))
  return out
end

-- ---------------------------------------------------------------------------
-- Table of contents and table of authorities
-- ---------------------------------------------------------------------------

-- Runs of WordprocessingML for an inline list (italic and bold kept). Used for the contents and the authorities,
-- which are paragraphs with a right tab (not tables): a table in a row of tables gets an empty paragraph from pandoc.
local function run_xml(text, rpr)
  return '<w:r>' .. ((rpr ~= "") and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
    '<w:t xml:space="preserve">' .. xml_escape(text) .. '</w:t></w:r>'
end

local function inlines_xml(inl, rpr)
  local out = {}
  for _, el in ipairs(inl) do
    if el.t == "Str" then
      out[#out + 1] = run_xml(el.text, rpr)
    elseif el.t == "Space" or el.t == "SoftBreak" then
      out[#out + 1] = run_xml(" ", rpr)
    elseif el.t == "Emph" then
      out[#out + 1] = inlines_xml(el.content, rpr .. "<w:i/>")
    elseif el.t == "Strong" then
      out[#out + 1] = inlines_xml(el.content, rpr .. "<w:b/>")
    elseif el.t == "Span" then
      out[#out + 1] = inlines_xml(el.content, rpr)
    else
      out[#out + 1] = run_xml(pandoc.utils.stringify(el), rpr)
    end
  end
  return table.concat(out)
end

-- One table cell and one row of cells (borderless, fixed widths in twips). A row of paragraphs with a right
-- tab would put the page number on the last line of a wrapped entry in LibreOffice; a cell keeps it on the
-- first line, as the typst grid does.
local function cell_xml(w, style, inl_xml)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="' ..
    style .. '"/></w:pPr>' .. inl_xml .. '</w:p></w:tc>'
end

local function row_xml(widths, cells)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblStyle w:val="Table"/><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    table.concat(cells) .. '</w:tr></w:tbl>'
end

-- The gap before each contents or authority line (typst: a block above of one single line).
local ENTRY_GAP = '<w:p><w:pPr><w:pStyle w:val="MowdEntryGap"/></w:pPr></w:p>'

-- One contents line: the label at its level's indent, the title, and the page number at the right margin.
-- The label column is 0.6 in (the typst grid's label column); the page column is 0.5 in, the typst page column.
local function toc_line(h, pg)
  local indent = (h.level - 1) * 720
  local widths, cells = {}, {}
  if indent > 0 then
    widths[#widths + 1] = indent
    cells[#cells + 1] = cell_xml(indent, "MowdEntryCell", "")
  end
  local tw = 9360 - indent - 864 - 720
  widths[#widths + 1] = 864
  cells[#cells + 1] = cell_xml(864, "MowdEntryCell", run_xml(h.label, ""))
  widths[#widths + 1] = tw
  cells[#cells + 1] = cell_xml(tw, "MowdEntryCell", inlines_xml(h.inl, ""))
  widths[#widths + 1] = 720
  cells[#cells + 1] = cell_xml(720, "MowdEntryPage", run_xml(pg, ""))
  return pandoc.RawBlock("openxml", ENTRY_GAP .. row_xml(widths, cells))
end

local function toc_rows(heads, out)
  out[#out + 1] = para("MowdPageTitle", { pandoc.Str("TABLE OF CONTENTS") })
  for i, h in ipairs(heads) do
    out[#out + 1] = toc_line(h, heading_page(i))
  end
end

-- One authority line: the citation (case names in italic) and its pages at the right margin. The text is 5.8 in
-- and the pages 0.7 in (typst: 5.8 in of text, 0.6 in of pages, 0.1 in between).
local function toa_line(inl, pg)
  return pandoc.RawBlock("openxml", ENTRY_GAP .. row_xml({ 8352, 1008 }, {
    cell_xml(8352, "MowdEntryCell", inlines_xml(inl, "")),
    cell_xml(1008, "MowdEntryPage", run_xml(pg, "")),
  }))
end

local function toa_entries(reg, needles, out)
  out[#out + 1] = para("MowdPageTitleBreak", { pandoc.Str("TABLE OF AUTHORITIES") })
  local cited = {}
  for _, n in ipairs(needles) do cited[n.key] = true end
  for _, kind in ipairs(KIND_ORDER) do
    local keyed = {}
    for key, a in pairs(reg) do
      if a.kind == kind and cited[key] then
        local sort = a.sort or a.name or a.cite
        keyed[#keyed + 1] = { key = key, sort = sort:lower(), a = a }
      end
    end
    if #keyed > 0 then
      table.sort(keyed, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      out[#out + 1] = para("MowdToaGroup", { pandoc.Str(KIND_TITLE[kind]) })
      for _, x in ipairs(keyed) do
        local a = x.a
        local md
        if a.name ~= nil then
          if kind == "case" then md = "*" .. a.name .. "*, " .. a.cite else md = a.name .. ", " .. a.cite end
        else
          md = a.cite
        end
        local inl = pandoc.read(md, "markdown").blocks[1].content
        out[#out + 1] = toa_line(inl, authority_pages(x.key))
      end
      out[#out + 1] = spacer("MowdSpacer")
    end
  end
end

local function write_sidecar(heads, needles)
  local path = os.getenv("MOWD_SIDECAR")
  if path == nil or path == "" then return end
  local f = assert(io.open(path, "w"))
  for i, h in ipairs(heads) do
    f:write("H\t" .. i .. "\t" .. h.search .. "\n")
  end
  for _, n in ipairs(needles) do
    if n.needle:find("[\t\n]") then error("mowd-motion-brief: a link text holds a tab or newline: " .. n.needle) end
    f:write("N\t" .. n.key .. "\t" .. n.needle .. "\n")
  end
  f:close()
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- The last paragraph keeps with the signature block: a signature alone on a page is a defect.
local KEEP_NEXT = { MowdBodyNumbered = true, MowdBodyPara = true }
local function keep_with_next(blocks)
  local last = blocks[#blocks]
  if last ~= nil and last.t == "Div" then
    local name = last.attr.attributes["custom-style"]
    if KEEP_NEXT[name] then blocks[#blocks] = styled(name .. "Keep", last.content) end
  end
end

function Pandoc(doc)
  local m = doc.meta
  PAGE_OF = load_pages()
  local reg = registry_of(m)
  local heads, needles = {}, {}
  local body = body_blocks(doc, reg, heads, needles)
  -- The certificate heading is the last entry of the contents, so it is recorded before the contents are written.
  local cert_head = heading(pandoc.Header(1, pandoc.Inlines({ pandoc.Str("Certificate of Service") })), heads)

  local out = {}
  cover(m, out)
  out[#out + 1] = raw_para(SECT_COVER)

  toc_rows(heads, out)
  toa_entries(reg, needles, out)
  out[#out + 1] = raw_para(SECT_FRONT)

  for _, b in ipairs(body) do out[#out + 1] = b end
  keep_with_next(out)
  out[#out + 1] = spacer("MowdSpacerKeep")
  out[#out + 1] = signature_row(signature_lines(m.signature))
  for _, b in ipairs(certificate_blocks(m, cert_head)) do out[#out + 1] = b end

  write_sidecar(heads, needles)
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
