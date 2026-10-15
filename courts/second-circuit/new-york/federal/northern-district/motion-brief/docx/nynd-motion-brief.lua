-- nynd memorandum of law (N.D.N.Y.), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/nynd-motion-brief.typ: the cover (caption, title of the paper, filing firm) and the signature
-- block are built here from the frontmatter as OpenXML tables and paragraphs in the reference's styles. The
-- body keeps its markdown structure (headings, paragraphs, footnotes, bullet lists).
-- Sections: the cover has no page number (L.R. 10.1(a)); the table of contents is numbered i, ii, ...; the
-- memorandum is numbered 1, 2, ... from its first page (L.R. 7.1(b)(1)). Each section's sectPr sits in the last
-- paragraph of that section.
-- The table of contents is a TOC field whose cached entries carry the page numbers. The pages are found by
-- docx/render.sh from a first LibreOffice pass and passed in through NYND_TOC_MAP (one page label per heading,
-- in order); NYND_TOC_LIST makes this filter write the heading list for that pass.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, rpr)
  local props = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. props .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function para(style, inner, ppr)
  return "<w:p><w:pPr><w:pStyle w:val=\"" .. style .. "\"/>" .. (ppr or "") .. "</w:pPr>" .. inner .. "</w:p>"
end

local function raw_block(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function table_xml(widths, rows)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. "</w:tblPr><w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid>" .. table.concat(rows) .. "</w:tbl>"
end

local function row(cells)
  local out = {}
  for _, c in ipairs(cells) do
    local b = c[2] and ("<w:tcBorders>" .. c[2] .. "</w:tcBorders>") or ""
    out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. b .. "</w:tcPr>" .. c[3] .. "</w:tc>"
  end
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(out) .. "</w:tr>"
end

local RULES = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

-- L.R. 10.1(c)(1): court title, party block between rules, case number and judges' initials at the right
local function caption(m)
  local left = {}
  local parties = m.caption.parties
  for k, p in ipairs(parties) do
    local first = (k == 1)
    for _, nm in ipairs(p.names) do
      left[#left + 1] = para("Single", run(plain(nm)), first and '<w:spacing w:before="200"/>' or nil)
      first = false
    end
    left[#left + 1] = para("Single", run(plain(p.designation)), '<w:ind w:left="2880"/>')
    if k < #parties then
      left[#left + 1] = para("Single", run(plain(m.caption.between)),
        '<w:spacing w:before="120" w:after="120"/><w:ind w:left="720"/>')
    end
  end
  left[#left] = para("Single", run(plain(parties[#parties].designation)),
    '<w:spacing w:after="200"/><w:ind w:left="2880"/>')
  local right = para("Single", run("Case No. " .. plain(m.case_number) .. " (" .. plain(m.judges) .. ")"),
    '<w:spacing w:before="200"/><w:ind w:left="144"/>')
  local head = para("Single", run("UNITED STATES DISTRICT COURT"))
    .. para("Single", run("NORTHERN DISTRICT OF NEW YORK"), '<w:spacing w:after="240"/>')
  return head .. table_xml({ 5184, 432, 3744 }, {
    row({
      { 5184, RULES, table.concat(left) },
      { 432, nil, para("Single", "") },
      { 3744, nil, right },
    }),
  })
end

-- the filing firm on the cover: at 3.25 in from the left margin, single-spaced with one line of space per item
local function firm_block(sig, role)
  local x = {}
  local function item(text, rpr)
    local sp = (#x == 0) and '<w:spacing w:before="2990"/>' or ""
    x[#x + 1] = para("Single", run(text, rpr), '<w:ind w:left="4680"/>' .. sp)
  end
  item(string.upper(plain(sig.firm)), "<w:b/><w:bCs/>")
  for _, s in ipairs(sig.signers) do
    item(plain(s.name))
    item(plain(s.bar_roll))
    item(plain(s.email))
  end
  for _, a in ipairs(sig.address) do item(plain(a)) end
  item(plain(sig.phone))
  item(plain(role), "<w:i/><w:iCs/>")
  return table.concat(x)
end

-- L.R. 10.1(c)(2): dated at the left; firm, signature line, signing attorneys, address, telephone and role at right
local function signature(sig, role)
  local left = para("Single", run("Dated: " .. plain(sig.dated)), '<w:spacing w:before="480"/>')
  local r = {}
  r[#r + 1] = para("Single", run(string.upper(plain(sig.firm)), "<w:b/><w:bCs/>"), '<w:spacing w:before="480"/>')
  r[#r + 1] = para("Single", run("By: ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    '<w:tabs><w:tab w:val="left" w:pos="3744"/></w:tabs><w:spacing w:before="480"/>')
  for _, s in ipairs(sig.signers) do
    r[#r + 1] = para("Single", run(plain(s.name)))
    r[#r + 1] = para("Single", run(plain(s.bar_roll)))
    r[#r + 1] = para("Single", run(plain(s.email)))
  end
  for i, a in ipairs(sig.address) do
    r[#r + 1] = para("Single", run(plain(a)), i == 1 and '<w:spacing w:before="120"/>' or nil)
  end
  r[#r + 1] = para("Single", run(plain(sig.phone)))
  r[#r + 1] = para("Single", run(plain(role), "<w:i/><w:iCs/>"), '<w:spacing w:before="120"/>')
  return table_xml({ 4392, 288, 4680 }, {
    row({ { 4392, nil, left }, { 288, nil, para("Single", "") }, { 4680, nil, table.concat(r) } }),
  })
end

-- section properties for the cover (no footer), the contents (roman) and the memorandum body (arabic)
local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local function section_break(footer, fmt)
  local f = footer and '<w:footerReference w:type="default" r:id="rId100"/>' or ""
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return raw_block('<w:p><w:pPr><w:sectPr>' .. f .. PG .. pg .. '</w:sectPr></w:pPr></w:p>')
end

-- TOC entries: the page labels come from the first pass (NYND_TOC_MAP); placeholders on that pass
local function toc_entries(heads)
  local pages = {}
  local f = os.getenv("NYND_TOC_MAP")
  if f and f ~= "" then
    local h = io.open(f, "r")
    if not h then error("nynd-motion-brief: cannot read NYND_TOC_MAP " .. f, 0) end
    for line in h:lines() do pages[#pages + 1] = line end
    h:close()
    if #pages ~= #heads then
      error("nynd-motion-brief: NYND_TOC_MAP has " .. #pages .. " pages for " .. #heads .. " headings", 0)
    end
  end
  local xml = {}
  for i, hd in ipairs(heads) do
    local page = pages[i] or "00"
    local begin = ""
    if i == 1 then
      begin = '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
        .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    local ending = (i == #heads) and '<w:r><w:fldChar w:fldCharType="end"/></w:r>' or ""
    local inner = begin .. run(hd.text) .. "<w:r><w:tab/></w:r>" .. run(page) .. ending
    xml[#xml + 1] = para("TOC" .. hd.level, inner)
  end
  return table.concat(xml)
end

-- "- item" lists: a bullet at 0.5 in, the text at 1 in
local function bullet_items(list)
  local out = {}
  for _, item in ipairs(list.content) do
    local inl = pandoc.Inlines({ pandoc.Str("\u{2022}"), TAB })
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then inl:extend(first.content) end
    out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Bullet" }))
    for k = 2, #item do out[#out + 1] = item[k] end
  end
  return out
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}

  -- cover (page 1, no number)
  out[#out + 1] = raw_block(caption(m))
  out[#out + 1] = raw_block(para("CenteredDouble", run(string.upper(plain(m.brief_title)), "<w:b/><w:bCs/>"),
    '<w:keepNext/><w:spacing w:before="3020" w:after="0"/>'))
  out[#out + 1] = raw_block(firm_block(m.signature, plain(m.counsel_role)))
  out[#out + 1] = section_break(false, nil)

  -- the body headings, for the contents and the first pass
  local heads = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 3 then
      heads[#heads + 1] = { level = b.level, text = plain(b.content) }
    end
  end
  local list = os.getenv("NYND_TOC_LIST")
  if list and list ~= "" then
    local h = io.open(list, "w")
    for _, hd in ipairs(heads) do h:write(hd.level, "\t", hd.text, "\n") end
    h:close()
  end

  -- contents (page i, ii, ...)
  out[#out + 1] = raw_block(para("CenteredDouble", run("TABLE OF CONTENTS", "<w:b/><w:bCs/>"),
    '<w:spacing w:after="480"/>'))
  out[#out + 1] = raw_block(toc_entries(heads))
  out[#out + 1] = section_break(true, "lowerRoman")

  -- body: the memorandum from page 1; markdown structure kept, bullets written as paragraphs
  for _, b in ipairs(doc.blocks) do
    if b.t == "BulletList" then
      for _, blk in ipairs(bullet_items(b)) do out[#out + 1] = blk end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = raw_block(signature(m.signature, plain(m.counsel_role)))
  doc.blocks = out
  return doc
end
