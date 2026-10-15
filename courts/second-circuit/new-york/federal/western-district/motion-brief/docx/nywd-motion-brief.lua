-- nywd memorandum of law (W.D.N.Y.), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/nywd-motion-brief.typ: the cover (court title, caption with the case number at right, the title,
-- the counsel block at right), the table of contents (a TOC field with cached entries and dot leaders), the body
-- (level 2 headings numbered I., II. and level 3 headings A., B. by this filter; paragraphs unnumbered; block
-- quotations single-spaced), and the signature block after the conclusion.
-- Sections: cover (no page number), table of contents (lower roman), body (arabic from 1), as in the typst template.
-- The table of contents' page numbers are not computed here: docx/render.sh makes a first pass, finds each heading's
-- page in the PDF, and passes the numbers to this filter in the file named by NYWD_TOC_PAGES (one per heading, in
-- order). Without that file the entries show no page number.

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

local function raw_block(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function para(style, inner, ppr)
  return "<w:p><w:pPr><w:pStyle w:val=\"" .. style .. "\"/>" .. (ppr or "") .. "</w:pPr>" .. inner .. "</w:p>"
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
    out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[2] or "") .. "</w:tcPr>" .. c[3] .. "</w:tc>"
  end
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(out) .. "</w:tr>"
end

local CAPTION_LEFT_TCPR = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  .. '<w:tcMar><w:right w:w="144" w:type="dxa"/></w:tcMar>'

-- the section properties of a section that ends here (pgNumType: nil for the cover, lowerRoman for the table of
-- contents); the footer is one of reference.docx's: rId102 empty, rId101 roman, rId100 arabic
local function section_break(footer, pgnum)
  return raw_block('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:sectPr>'
    .. '<w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. (pgnum or "") .. '</w:sectPr></w:pPr></w:p>')
end

-- cover: court title, caption (parties left with the rules, case number at right), title, counsel at right
local function cover(m)
  local out = {}
  out[#out + 1] = raw_block(para("Centered", run("UNITED STATES DISTRICT COURT", "<w:b/><w:bCs/>"))
    .. para("Centered", run("WESTERN DISTRICT OF NEW YORK", "<w:b/><w:bCs/>")))
  local left = {}
  for k, p in ipairs(m.caption.parties) do
    local names = {}
    for _, nm in ipairs(p.names) do names[#names + 1] = plain(nm) end
    left[#left + 1] = para("Single", run(table.concat(names, " ")))
    left[#left + 1] = para("Single", run(plain(p.designation)), '<w:ind w:left="3168"/>')
    if k < #m.caption.parties then
      left[#left + 1] = para("Single", run("v."), '<w:ind w:left="1728"/>')
    end
  end
  left[#left] = para("Single", run(plain(m.caption.parties[#m.caption.parties].designation)),
    '<w:spacing w:after="160"/><w:ind w:left="3168"/>')
  local right = para("Single", run("Case No. " .. plain(m.case_number)), '<w:spacing w:before="324"/>')
  out[#out + 1] = raw_block('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="324" w:lineRule="exact"/></w:pPr></w:p>'
    .. table_xml({ 4896, 432, 4032 }, {
      row({
        { 4896, CAPTION_LEFT_TCPR, table.concat(left) },
        { 432, nil, para("Single", "") },
        { 4032, nil, right },
      }),
    }))
  out[#out + 1] = raw_block(para("CoverTitle", run(string.upper(plain(m.title)))))

  -- counsel groups at the right: the first name line is the firm (bold), then the names and the lines
  local groups = {}
  for gi, g in ipairs(m.counsel or {}) do
    local names = g.names or {}
    local ps = {}
    for i, nm in ipairs(names) do
      local rpr = (i == 1) and "<w:b/><w:bCs/>" or nil
      ps[#ps + 1] = para("Counsel", run(plain(nm), rpr), gi > 1 and i == 1 and '<w:spacing w:before="312"/>' or nil)
    end
    for _, l in ipairs(g.lines or {}) do
      ps[#ps + 1] = para("Counsel", run(plain(l)))
    end
    groups[#groups + 1] = table.concat(ps)
  end
  if #groups > 0 then
    out[#out + 1] = raw_block(table_xml({ 4320, 5040 }, {
        row({ { 4320, nil, para("Single", "") }, { 5040, nil, table.concat(groups) } }),
      }))
  end
  out[#out + 1] = section_break("rId102", nil)
  return out
end

-- headings: level 1 is a section; level 2 is numbered I., II. and level 3 A., B. (numbers reset at each higher level)
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
local LETTER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function label_heading(level, label, inl)
  local out = pandoc.Inlines({})
  if label then
    out:insert(pandoc.Str(label))
    out:insert(TAB)
  end
  out:extend(inl)
  return pandoc.Header(level, out)
end

local function toc_pages()
  local pages = {}
  local path = os.getenv("NYWD_TOC_PAGES")
  if not path or path == "" then return pages end
  local f = io.open(path, "r")
  if not f then return pages end
  for line in f:lines() do
    local p = line:match("^%s*(%S+)%s*$")
    if p then pages[#pages + 1] = p end
  end
  f:close()
  return pages
end

-- the table of contents: a TOC field whose cached result is the entries with dot leaders and page numbers
local function toc(entries)
  local pages = toc_pages()
  local paras = {}
  for i, e in ipairs(entries) do
    local label = e.label and (e.label .. " ") or ""
    local body = run(label .. e.text) .. "<w:r><w:tab/></w:r>" .. run(pages[i] or "")
    local style = "TOC" .. e.level
    local pre, post = "", ""
    if i == 1 then
      pre = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    if i == #entries then
      post = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
    end
    paras[#paras + 1] = para(style, pre .. body .. post)
  end
  return paras
end

local function signature(m)
  local sig = m.signature
  local left = para("Single", run("Dated: " .. plain(m.date)), '<w:spacing w:before="324"/>')
  local r = {}
  r[#r + 1] = para("Single", run(plain(sig.firm[1]), "<w:b/><w:bCs/>"), '<w:spacing w:before="324"/>')
  r[#r + 1] = para("Single", run("By: " .. plain(sig.by)), '<w:spacing w:before="324"/>')
  for _, l in ipairs(sig.lines) do
    r[#r + 1] = para("Single", run(plain(l)))
  end
  return raw_block(table_xml({ 4752, 4608 }, {
    row({ { 4752, nil, left }, { 4608, nil, table.concat(r) } }),
  }))
end

local function drop_marker(inlines)
  local out = pandoc.Inlines({})
  for _, il in ipairs(inlines) do out:insert(il) end
  if out[1] and out[1].t == "Str" and out[1].text:sub(1, 2) == "::" then
    out[1] = pandoc.Str(out[1].text:sub(3))
  end
  while out[1] and (out[1].t == "Space" or (out[1].t == "Str" and out[1].text == "")) do out:remove(1) end
  return out
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

function Pandoc(doc)
  local m = doc.meta
  local out = cover(m)

  -- first pass over the body: the heading list (for the table of contents) and the numbered headings
  local entries, h2, h3 = {}, 0, 0
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = pandoc.utils.stringify(b.content)
      if b.level == 1 then
        h2, h3 = 0, 0
        entries[#entries + 1] = { level = 1, text = text }
        body[#body + 1] = label_heading(1, nil, b.content)
      elseif b.level == 2 then
        h2, h3 = h2 + 1, 0
        local label = ROMAN[h2] .. "."
        entries[#entries + 1] = { level = 2, label = label, text = text }
        body[#body + 1] = label_heading(2, label, b.content)
      elseif b.level == 3 then
        h3 = h3 + 1
        local label = LETTER:sub(h3, h3) .. "."
        entries[#entries + 1] = { level = 3, label = label, text = text }
        body[#body + 1] = label_heading(3, label, b.content)
      else
        body[#body + 1] = b
      end
    elseif (b.t == "Para" or b.t == "Plain") and plain(b):match("^::") then
      body[#body + 1] = styled("Unnumbered", { pandoc.Para(drop_marker(b.content)) })
    elseif b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        local first = item[1]
        local inl = pandoc.Inlines({ pandoc.Str("(" .. string.char(96 + k) .. ")"), TAB })
        if first and (first.t == "Para" or first.t == "Plain") then inl:extend(first.content) end
        body[#body + 1] = styled("Lettered", { pandoc.Para(inl) })
      end
    elseif b.t == "BlockQuote" then
      local ps = {}
      for _, q in ipairs(b.content) do
        if q.t == "Para" or q.t == "Plain" then ps[#ps + 1] = pandoc.Para(q.content) end
      end
      body[#body + 1] = styled("BlockText", ps)
    else
      body[#body + 1] = b
    end
  end

  -- table of contents (section 2, lower roman), then the body (section 3, arabic from 1)
  out[#out + 1] = raw_block(para("TOCHeading", run("TABLE OF CONTENTS", "<w:b/><w:bCs/>"), '<w:spacing w:after="324"/>'))
  for _, p in ipairs(toc(entries)) do out[#out + 1] = raw_block(p) end
  out[#out + 1] = section_break("rId101", '<w:pgNumType w:fmt="lowerRoman" w:start="1"/>')

  for _, b in ipairs(body) do out[#out + 1] = b end
  out[#out + 1] = signature(m)

  -- the heading list, one per line in order, for docx/render.sh (the page numbers are found in the PDF)
  local listpath = os.getenv("NYWD_TOC_LIST")
  if listpath and listpath ~= "" then
    local f = assert(io.open(listpath, "w"))
    for _, e in ipairs(entries) do f:write((e.label and (e.label .. " ") or ""), e.text, "\n") end
    f:close()
  end
  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
