-- USCMCR brief (appellant or appellee), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- docx/reference.xml. The layout is the typst template's (typst/mc-*.typ), on the shared cross-engine layout model
-- (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every line a box of its exact pitch (the typst
-- pitches in twips), the spaces between blocks the typst ones, first-fit breaks on the same break opportunities.
-- This filter writes the cover (caption, honorable line, counsel), the table of contents, the headings, the closing
-- signature block and the two certificates; pandoc writes the body paragraphs and footnotes.
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle.
-- The cover is a section with no footer (rIdFtrNone); the contents numbers its pages in roman from i (rIdFtrPage,
-- lowerRoman, as the typst copy and the filed briefs); the body numbers its pages from 1 (FORMBOOK_FINAL,
-- rIdFtrPage). Word may paginate slightly differently from LibreOffice.

-- Rules cited by the certificates (the typst template's constants; APP-1's certificate form).
local TYPE_VOLUME_RULE = "Rule 14(i)"
local TYPEFACE_RULE = "Rule 14(e)"
local COURT_LINE = "IN THE UNITED STATES COURT OF MILITARY COMMISSION REVIEW"
local HONORABLE_LINE = "TO THE HONORABLE, THE JUDGES OF THE COURT OF MILITARY COMMISSION REVIEW"

-- The typst numbers, in twips (20 x pt) and half points.
local SINGLE = 276     -- pitch-single, 13.8 pt
local DOUBLE = 552     -- pitch-double, 27.6 pt (reference Body Text)
local H1, H1_SZ, H1_SP = 392, 34, 268   -- section headings: 19.6 pt line, 17 pt, 13.4 pt above and below
local H2, H2_SZ, H2_SP = 334, 29, 232   -- argument headings: 16.7 pt line, 14.5 pt, 11.6 pt
local H3_SP = 144                       -- sub-headings: 7.2 pt
local TEXT_W = 9360    -- 6.5 in
local PNUM = 720       -- the contents' page column (typst toc-page-col, 36 pt)
local TOC_STEP = 360   -- a level-2 contents entry steps in 18 pt (typst toc-step)
local CERT_LABEL = 360 -- the certificate items' number box (typst cert-label, 18 pt)
local COUNSEL_L = 3168 -- 2.2 in
local SIG_L = 4032     -- 2.8 in
local COL_SIDE, COL_MID = 4464, 432    -- caption columns: 3.1 in, 0.3 in, 3.1 in
local NEEDLE_MAX = 60

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify
local runs, inl, para, raw, style, ind, jc = xe.runs, xe.inl, xe.para, xe.raw, xe.style, xe.ind, xe.jc
local KEEP, BREAK, LINES, LEAD = xe.KEEP, xe.BREAK, xe.LINES, xe.LEAD

local function spacing(before, after, line)
  return xe.spacing(before, after, line or SINGLE)
end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

local function group_digits(s)
  local n = tostring(s):match("^%d+$") and tostring(s) or nil
  if not n then return tostring(s) end
  local out = n:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function opening(text)
  local out = ""
  for w in text:gmatch("%S+") do
    out = out .. norm(w)
    if #out >= 8 then break end
  end
  return out:sub(1, NEEDLE_MAX)
end

local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = opening(text)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = "B", needle = long, fallback = short }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

local function label_of(id)
  return labels[id] or "0" -- the first pass: a placeholder
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The text of a block without its footnotes (the needles follow the PDF's body text).
local function text_of(b)
  if not b then return "" end
  local c = pandoc.Pandoc({ b }):walk({ Note = function() return {} end })
  return stringify(c.blocks)
end

-- ---------------------------------------------------------------------------
-- Sections
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt, start)
  local pg = ""
  if fmt then pg = '<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. (start or 1) .. '"/>' end
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt, start)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. "</w:pPr></w:p>")
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

local function cell(width, body, after, center)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>'
    .. para({ spacing(0, after), ind(0, nil, 0), center and jc("center") or "" }, body) .. "</w:tc>"
end

-- The caption (typst caption()): one row per line, the parenthesis column between the sides, 6 pt between rows.
local function caption_table(caption)
  local L, R = caption.left or {}, caption.right or {}
  local n = math.max(#L, #R)
  local rows = {}
  for i = 1, n do
    local after = i < n and 120 or 0
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(COL_SIDE, inl(L[i]), after)
      .. cell(COL_MID, runs(")"), after, true) .. cell(COL_SIDE, inl(R[i]), after) .. "</w:tr>"
  end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders>' .. none .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. COL_SIDE .. '"/><w:gridCol w:w="' .. COL_MID .. '"/><w:gridCol w:w="'
    .. COL_SIDE .. '"/></w:tblGrid>' .. table.concat(rows) .. "</w:tbl>"
end

local function cover(meta)
  local out = {}
  out[#out + 1] = para({ spacing(0, 480), ind(0, nil, 0), jc("center") }, runs(COURT_LINE, { b = true }))
  out[#out + 1] = caption_table(meta.caption or {})
  out[#out + 1] = para({ spacing(480, 0), ind(0, nil, 0), jc("center") }, runs(HONORABLE_LINE, { b = true }))
  -- counsel groups (typst counsel-block): 24 pt above the first, 12 pt between them; a group is never split
  for gi, g in ipairs(meta.counsel or {}) do
    local lines = {}
    for _, n in ipairs(g.names or {}) do lines[#lines + 1] = inl(n) end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = inl(l, { i = true }) end
    for i, l in ipairs(lines) do
      local before = i == 1 and (gi == 1 and 480 or 240) or 0
      out[#out + 1] = para({ i < #lines and KEEP or LINES, spacing(before, 0), ind(COUNSEL_L, nil, 0) }, l)
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature and certificates
-- ---------------------------------------------------------------------------

-- typst signature(): "//s//" before the signer's name, the lines in italics, kept together; with `closing`, the
-- date and "Respectfully submitted," before it.
local function signature(meta, closing, above)
  local sig = meta.signature or {}
  local lines = {}
  if closing then
    lines[#lines + 1] = { 0, runs("Dated: ") .. inl(meta.date) }
    lines[#lines + 1] = { 360, runs("Respectfully submitted,") }
  end
  lines[#lines + 1] = { closing and 240 or 0, runs("//s// ") .. inl(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { 0, inl(l, { i = true }) } end
  lines[1][1] = above
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = para({ i < #lines and KEEP or LINES, spacing(l[1], 0), ind(SIG_L, nil, 0) }, l[2])
  end
  return table.concat(out)
end

local function cert_heading(text)
  -- a page break: Word keeps the space above, typst drops it at the top of a page
  return para({ style("Heading1"), KEEP, BREAK, spacing(0, H1_SP, H1), ind(0, nil, 0), jc("center") },
    runs(text, { b = true, sz = H1_SZ }))
end

local function cert_item(n, body)
  return para({ spacing(240, 0), ind(CERT_LABEL, CERT_LABEL) }, runs(n .. ".\t") .. body)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function heading_xml(level, content)
  if level == 1 then
    return para({ style("Heading1"), KEEP, spacing(H1_SP, H1_SP, H1), ind(0, nil, 0), jc("center") },
      inl(content, { b = true, sz = H1_SZ }))
  elseif level == 2 then
    return para({ style("Heading2"), KEEP, spacing(H2_SP, H2_SP, H2), ind(0, nil, 0) },
      inl(content, { b = true, sz = H2_SZ }))
  end
  return para({ style("Heading" .. math.min(level, 6)), KEEP, spacing(H3_SP, H3_SP), ind(0, nil, 0) },
    inl(content, { b = true }))
end

-- pandoc's fancy_lists reads "(a) Statutory ..." or "(I) file ..." as a list; CommonMark (the typst engine) reads a
-- paragraph. Such a list is written back as paragraphs that start with their label.
local function roman(n, upper)
  local out = ""
  for _, v in ipairs({ { 1000, "m" }, { 900, "cm" }, { 500, "d" }, { 400, "cd" }, { 100, "c" }, { 90, "xc" },
    { 50, "l" }, { 40, "xl" }, { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }) do
    while n >= v[1] do out, n = out .. v[2], n - v[1] end
  end
  return upper and out:upper() or out
end

local function list_label(attr, n)
  local s = attr.style
  local num = tostring(n)
  if s == "LowerAlpha" then num = string.char(96 + n)
  elseif s == "UpperAlpha" then num = string.char(64 + n)
  elseif s == "LowerRoman" then num = roman(n, false)
  elseif s == "UpperRoman" then num = roman(n, true) end
  local d = attr.delimiter
  if d == "TwoParens" then return "(" .. num .. ")" end
  if d == "OneParen" then return num .. ")" end
  return num .. "."
end

local function is_commonmark_list(b)
  local a = b.listAttributes
  return (a.style == "Decimal" or a.style == "DefaultStyle" or a.style == "Example")
    and (a.delimiter == "Period" or a.delimiter == "OneParen" or a.delimiter == "DefaultDelim")
end

local function unlist(b)
  if b.t ~= "OrderedList" or is_commonmark_list(b) then return { b } end
  local out = {}
  local n = b.listAttributes.start
  for _, item in ipairs(b.content) do
    for j, x in ipairs(item) do
      if j == 1 and (x.t == "Plain" or x.t == "Para") then
        local c = pandoc.Inlines({ pandoc.Str(list_label(b.listAttributes, n)), pandoc.Space() })
        c:extend(x.content)
        out[#out + 1] = pandoc.Para(c)
      else
        out[#out + 1] = x.t == "Plain" and pandoc.Para(x.content) or x
      end
    end
    n = n + 1
  end
  return out
end

local function styled(name, b)
  return pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta

  -- the body's blocks, the fancy lists back to paragraphs
  local blocks = {}
  for _, b in ipairs(doc.blocks) do
    for _, x in ipairs(unlist(b)) do blocks[#blocks + 1] = x end
  end
  blocks = pandoc.Pandoc(blocks):walk({ Inlines = xe.inlines }).blocks

  local body, entries = {}, {}
  local after_heading = true -- typst indents no paragraph that opens the body or follows a heading
  local h_n = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, stringify(b.content), text_of(blocks[i + 1]):sub(1, 40))
      if b.level <= 2 then
        entries[#entries + 1] = { id = id, level = b.level, title = b.content }
      end
      local x = heading_xml(b.level, b.content)
      -- the body opens a section (a new page): Word keeps the space above there, typst drops it
      if #body == 0 then x = x:gsub('w:before="%d+"', 'w:before="0"', 1) end
      body[#body + 1] = raw(x)
      after_heading = true
    elseif b.t == "Para" then
      body[#body + 1] = styled(after_heading and "First Paragraph" or "Body Text", b)
      after_heading = false
    else
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
      after_heading = false
    end
  end
  local cert_c, cert_s = "CERTIFICATE OF COMPLIANCE", "CERTIFICATE OF SERVICE"
  need("C:1", cert_c, "1. This brief complies")
  need("C:2", cert_s, plain(meta.service and meta.service.text):sub(1, 40))
  entries[#entries + 1] = { id = "C:1", level = 1, title = cert_c }
  entries[#entries + 1] = { id = "C:2", level = 1, title = cert_s }

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- ---- cover (its own section, no page number), then the contents (numbered i) ----
  add(raw(cover(meta)))
  add(section("rIdFtrNone"))
  add(raw(para({ BREAK, spacing(0, 240), ind(0, nil, 0), jc("center") }, runs("TABLE OF CONTENTS", { b = true }))))
  for _, e in ipairs(entries) do
    local left = e.level >= 2 and TOC_STEP or 0
    add(raw(para({ LINES, xe.leader_tab(TEXT_W), spacing(0, 0), ind(left, nil, nil, PNUM) },
      inl(e.title) .. runs(LEAD .. label_of(e.id)))))
  end
  add(section("rIdFtrPage", "lowerRoman", 1))

  -- ---- body (numbered from 1) ----
  for _, x in ipairs(body) do add(x) end
  add(raw(signature(meta, true, 360)))

  -- ---- certificates ----
  add(raw(cert_heading(cert_c)))
  add(raw(cert_item(1, runs("This brief complies with the type-volume limitation of " .. TYPE_VOLUME_RULE
    .. " because it contains " .. group_digits(plain(meta.word_count)) .. " words; and"))))
  add(raw(cert_item(2, runs("This brief complies with the typeface and style requirements of " .. TYPEFACE_RULE
    .. " because it has been prepared using " .. plain(meta.compliance and meta.compliance.typeface) .. "."))))
  add(raw(para({ spacing(480, 0), ind(0, nil, 0) }, runs("Dated: ") .. inl(meta.date))))
  add(raw(signature(meta, false, 240)))

  add(raw(cert_heading(cert_s)))
  add(raw(para({ spacing(0, 0), ind(0, nil, 0) }, inl(meta.service and meta.service.text))))
  add(raw(signature(meta, false, 240)))

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
