-- prd-motion-brief.lua (docx engine, D.P.R. motion with memorandum). What the Word output adds to pandoc's
-- default conversion, so that the .docx reads as typst/prd-motion-brief.typ does (see ../README.md, "Engines"):
--   * the cover from the frontmatter: court title, caption table (rules, case number, judge, title), counsel
--     blocks two to a row; no page number on the cover (section 1, no footer);
--   * the table of contents (section 2, lower-roman page numbers): one paragraph per heading of levels 1 to 4 with
--     its label, a dot leader and a PAGEREF field to the heading's bookmark (LibreOffice computes the page;
--     Word shows the cached value until fields are updated, see README);
--   * heading labels as typst prints them: I., A., 1., a. for levels 2 to 5, hanging under the heading text;
--   * signature block (two per row), the certificate of service;
--   * the body starts a new section at arabic page 1 (the final section, from reference.docx).
-- The table of authorities is NOT built (BLOCKED, see README): no TA/TOA fields and no page list.
-- Raw Word XML is written for the tables and the cover; the section breaks are raw sectPr paragraphs whose
-- footer reference id is the placeholder RIDFOOTER, replaced by docx/render.sh with the id of footer1.xml.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, flags)
  flags = flags or {}
  local rpr = ""
  if flags.b then rpr = rpr .. "<w:b/><w:bCs/>" end
  if flags.i then rpr = rpr .. "<w:i/><w:iCs/>" end
  if flags.caps then rpr = rpr .. "<w:caps/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function runs(inls, flags)
  flags = flags or {}
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, flags)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", flags)
    elseif t == "LineBreak" then out[#out + 1] = '<w:r><w:br/></w:r>'
    elseif t == "Emph" then out[#out + 1] = runs(el.content, { b = flags.b, i = true, caps = flags.caps })
    elseif t == "Strong" then out[#out + 1] = runs(el.content, { b = true, i = flags.i, caps = flags.caps })
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], flags) .. runs(el.content, flags) .. run(q[2], flags)
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(el.content, flags)
    elseif t == "Code" then out[#out + 1] = run(el.text, flags)
    else out[#out + 1] = run(pandoc.utils.stringify(el), flags)
    end
  end
  return table.concat(out)
end

local function inlines_of(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaString" then return pandoc.utils.blocks_to_inlines(pandoc.read(v, "markdown").blocks) end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function para(style, inner, ppr_extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or "") .. '</w:pPr>' .. inner .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local BORDER_NONE = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function cell(width, content, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. (mar or "")
    .. '<w:vAlign w:val="top"/></w:tcPr>' .. content .. '</w:tc>'
end

local function table_xml(widths, rows)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'; total = total + w end
  local trs = {}
  for _, r in ipairs(rows) do trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. r .. '</w:tr>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' .. BORDER_NONE
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local RULE = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

-- Caption (PRD-CAP-002): parties left with a rule on the right and bottom; case number, judge, title right.
local function caption_xml(meta)
  local left = {}
  for i, side in ipairs(meta.caption or {}) do
    for _, n in ipairs(side.names) do left[#left + 1] = para("Single", runs(inlines_of(n))) end
    left[#left + 1] = para("Single", runs(inlines_of(side.designation)), '<w:ind w:left="2016"/>')
    if i < #meta.caption then
      left[#left + 1] = para("Single", run("v.", {}), '<w:spacing w:before="120" w:after="120"/><w:jc w:val="center"/>')
    end
  end
  local right = { para("Single", run("Case No. " .. pandoc.utils.stringify(meta.case_number), {})) }
  if meta.judge then right[#right + 1] = para("Single", runs(inlines_of(meta.judge), {})) end
  right[#right + 1] = para("Single", runs(inlines_of(meta.brief_title), { b = true, caps = true }),
    '<w:spacing w:before="240" w:after="0"/>')
  return table_xml({ 4896, 360, 4104 }, {
    cell(4896, table.concat(left), RULE, '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="240" w:type="dxa"/></w:tcMar>')
      .. cell(360, para("Single", ""))
      .. cell(4104, table.concat(right), nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'),
  })
end

local function lines_xml(lines, first_before)
  local ps = {}
  for i, l in ipairs(lines) do
    local extra = (i == 1 and first_before) and '<w:spacing w:before="240" w:after="0"/>' or nil
    ps[#ps + 1] = para("Single", runs(inlines_of(l)), extra)
  end
  return table.concat(ps)
end

local function counsel_xml(meta)
  local groups = meta.counsel
  local rows = {}
  for i = 1, #groups, 2 do
    local a = lines_xml(groups[i], i > 1)
    local b = groups[i + 1] and lines_xml(groups[i + 1], i > 1) or para("Single", "")
    rows[#rows + 1] = cell(4536, a) .. cell(288, para("Single", "")) .. cell(4536, b)
  end
  return raw(para("Spacer", "") .. table_xml({ 4536, 288, 4536 }, rows))
end

local function signature_xml(meta)
  local sig = meta.signature
  local rows = {}
  rows[#rows + 1] = cell(4536, para("Single", run("Respectfully submitted,", {})))
    .. cell(288, para("Single", ""))
    .. cell(4536, para("SigRight", run("Dated: " .. pandoc.utils.stringify(meta.date), {})))
  local groups = {}
  for _, g in ipairs(sig.groups) do
    local ps = {}
    local lines = {}
    if g.signer then
      lines[#lines + 1] = "By: s/ " .. pandoc.utils.stringify(g.signer)
      lines[#lines + 1] = pandoc.utils.stringify(g.signer)
    end
    local ps_xml = {}
    for i, s in ipairs(lines) do ps_xml[#ps_xml + 1] = para(i == 1 and "SigGroup" or "Single", run(s, {})) end
    for _, l in ipairs(g.lines or {}) do ps_xml[#ps_xml + 1] = para("Single", runs(inlines_of(l))) end
    groups[#groups + 1] = table.concat(ps_xml)
  end
  for i = 1, #groups, 2 do
    local b = groups[i + 1] or ""
    rows[#rows + 1] = cell(4536, groups[i]) .. cell(288, para("Single", "")) .. cell(4536, b)
  end
  return raw(para("Spacer", "") .. table_xml({ 4536, 288, 4536 }, rows))
end

local function certificate_xml(meta)
  if not meta.certificate then return {} end
  local c = meta.certificate
  local out = {}
  out[#out + 1] = raw(para("FrontHeading", run("Certificate of Service", {})))
  out[#out + 1] = raw(para("BodyText", run("I HEREBY CERTIFY that on this same date I electronically filed the foregoing with the Clerk of the Court using the CM/ECF system, which will send notification of such filing to all counsel of record.", {})))
  out[#out + 1] = raw(para("BodyText", run("In " .. pandoc.utils.stringify(c.place) .. ", this " .. pandoc.utils.stringify(c.date) .. ".", {})))
  local ps = { para("Single", run("s/ " .. pandoc.utils.stringify(c.signer), {}), '<w:spacing w:before="240" w:after="0"/>'),
    para("Single", run(pandoc.utils.stringify(c.signer), {})) }
  for _, l in ipairs(c.lines or {}) do ps[#ps + 1] = para("Single", runs(inlines_of(l))) end
  out[#out + 1] = raw(table.concat(ps))
  return out
end

-- Section break: the paragraph carries the sectPr of the section that ends here.
local function section_break(fmt, footer)
  local fr = footer and '<w:footerReference w:type="default" r:id="RIDFOOTER"/>' or ""
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0"/><w:sectPr>' .. fr
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. '</w:sectPr></w:pPr></w:p>')
end

-- Heading labels (typst/prd-motion-brief.typ, heading-num): level 2 I., 3 A., 4 1., 5 a.
local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do out = out .. v[2]; n = n - v[1] end
  end
  return out
end

local function label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return tostring(n) .. "." end
  if level == 5 then return string.char(96 + n) .. "." end
  return nil
end

local function toc_entry(level, lab, inls, pageref)
  local body = ""
  if lab then body = run(lab, {}) .. '<w:r><w:tab/></w:r>' end
  body = body .. runs(inls, {})
  local field = '<w:r><w:tab/></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> PAGEREF ' .. pageref .. ' \\h </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
  return raw(para("PRDToc" .. level, body .. field))
end

function Pandoc(doc)
  -- Authority links (toa:KEY) are shown as their text: the table of authorities is not built (BLOCKED).
  doc = doc:walk({ Link = function(l) if l.target:sub(1, 4) == "toa:" then return l.content end end })
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- Pass 1: heading labels and the table-of-contents entries (levels 1 to 4).
  local counts = { 0, 0, 0, 0, 0, 0 }
  local labels, toc = {}, {}
  for i, el in ipairs(doc.blocks) do
    if el.t == "Header" then
      counts[el.level] = counts[el.level] + 1
      for k = el.level + 1, 6 do counts[k] = 0 end
      labels[i] = label(el.level, counts[el.level])
      -- short bookmark names: a PAGEREF to a long pandoc identifier shows "Error: Reference source not found" (Word limits names to 40 characters)
      el.identifier = "sec" .. i
      if el.level <= 4 then toc[#toc + 1] = { level = el.level, lab = labels[i], inls = el.content, id = el.identifier } end
    end
  end

  -- page-number map for docx/render.sh (second pass): one line per table-of-contents entry, its id and text
  local mapfile = os.getenv("PRD_TOC_MAP")
  if mapfile then
    local f = assert(io.open(mapfile, "w"))
    for _, e in ipairs(toc) do f:write(e.id, "\t", pandoc.utils.stringify(pandoc.Para(e.inls)), "\n") end
    f:close()
  end

  -- cover (section 1: no page number)
  for _, l in ipairs({ "UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF PUERTO RICO" }) do
    add(raw(para("CourtTitle", run(l, { b = true }))))
  end
  add(raw(para("Spacer", "")))
  add(raw(caption_xml(meta)))
  if meta.counsel then add(counsel_xml(meta)) end
  add(section_break(nil, false))

  -- front matter (section 2: lower-roman page numbers): table of contents
  add(raw(para("FrontHeading", run("Table of Contents", {}))))
  add(raw(para("PageLabel", run("Page", {}))))
  for _, e in ipairs(toc) do add(toc_entry(e.level, e.lab, e.inls, e.id)) end
  add(section_break("lowerRoman", true))

  -- body (final section: arabic from 1)
  for i, el in ipairs(doc.blocks) do
    if el.t == "Header" and el.level > 1 and labels[i] then
      table.insert(el.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
      table.insert(el.content, 1, pandoc.Str(labels[i]))
    end
    add(el)
  end

  add(signature_xml(meta))
  for _, b in ipairs(certificate_xml(meta)) do add(b) end

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
