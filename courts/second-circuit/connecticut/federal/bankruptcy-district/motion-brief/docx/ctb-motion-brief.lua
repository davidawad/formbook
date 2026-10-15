-- Memorandum of law in support of a motion, DOCX engine (docs/DOCX.md): the markdown contract -> the layout of
-- typst/ctb-motion-brief.typ on reference.docx. Three sections: the cover (caption, title; the oral-argument legend is
-- the cover's footer, written by docx/render.sh), the table of contents and table of authorities (lower roman), the body
-- (arabic from 1). Caption, signature block and authorities are OpenXML tables and paragraphs, which pandoc's table model
-- cannot style. Numbered paragraphs (after the first heading) get their number typed, as the typst counter does.
-- Page numbers: the table of contents is written with the page of each heading from a first pass (docx/render.sh gives
-- the map in CTB_PAGES; CTB_INDEX_OUT makes the first pass write the search index). The table of authorities uses the
-- pages given in the frontmatter, as the typst template does. No case text is written into this file.

local function S(v) if v == nil then return "" end return pandoc.utils.stringify(v) end

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, rpr)
  rpr = rpr or ""
  return '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
    '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
end

local function P(style, text, ppr, rpr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' ..
    (text and text ~= "" and run(text, rpr) or "") .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock('openxml', xml) end
local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')

local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

-- a section break: the paragraph that ends a section carries its sectPr
local function section_break(sect)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>' .. sect .. '</w:sectPr></w:pPr></w:p>')
end
local COVER_SECT = '<w:footerReference w:type="default" r:id="rId103"/>' .. PG .. '<w:cols w:space="720"/>'
local FRONT_SECT = '<w:headerReference w:type="default" r:id="rId101"/><w:footerReference w:type="default" r:id="rId102"/>' ..
  PG .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/><w:cols w:space="720"/>'

-- the caption of the typst template: left party box (3.4 in, right and bottom rules), a gutter, the right column
local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local function caption_row(left_xml, right_xml)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="288"/><w:gridCol w:w="4176"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/>' .. RULE ..
    '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>' .. left_xml .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    right_xml .. '</w:tc></w:tr></w:tbl>'
end

local function cap(text, indent)
  return P("CaptionLine", text, indent and ('<w:ind w:left="' .. indent .. '"/>') or nil)
end

local function caption(meta)
  local out = {}
  out[#out + 1] = P("CourtName", string.upper(S(meta.court)))
  out[#out + 1] = P("CourtName", string.upper(S(meta.district)))
  out[#out + 1] = P("CourtName", string.upper(S(meta.division)))
  out[#out + 1] = P("Normal", "")
  local l1 = cap("In re:") .. cap(S(meta.debtors), 720) .. cap("Debtors.", 3600)
  local r1 = cap("Chapter " .. S(meta.chapter)) .. cap(S(meta.main_case))
  if meta.jointly_administered == true or S(meta.jointly_administered) == "true" then
    r1 = r1 .. cap("(Jointly Administered)")
  end
  out[#out + 1] = caption_row(l1, r1)
  out[#out + 1] = P("CaptionLine", "")
  local l2 = ""
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then l2 = l2 .. cap("v.", 2880) end
    for _, n in ipairs(p.names or {}) do l2 = l2 .. cap(S(n)) end
    l2 = l2 .. cap(S(p.designation), 3600)
  end
  local r2 = cap("Adv. Pro. No. " .. S(meta.adv_number) .. " (" .. S(meta.judge) .. ")") .. cap("Dated: " .. S(meta.date))
  out[#out + 1] = caption_row(l2, r2)
  out[#out + 1] = P("Normal", "")
  out[#out + 1] = P("CoverTitle", S(meta.title))
  return out
end

-- the signature block of the typst template: RESPECTFULLY SUBMITTED, then one block per signing firm, side by side
local function signature(meta)
  local blocks = meta.signature.esigners or {}
  local n = #blocks
  local gut = 432
  local colw = math.floor((9360 - gut * (n - 1)) / n)
  local grid, cells = {}, {}
  for k, b in ipairs(blocks) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. colw .. '"/>'
    if k < n then grid[#grid + 1] = '<w:gridCol w:w="' .. gut .. '"/>' end
    local ps = { P("SignatureLine", string.upper(S(b.firm))), P("SignatureLine", "/s/ " .. S(b.esigner)) }
    for _, l in ipairs(b.lines or {}) do ps[#ps + 1] = P("SignatureLine", S(l)) end
    cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. colw .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
    if k < n then cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. gut .. '" w:type="dxa"/></w:tcPr><w:p/></w:tc>' end
  end
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    table.concat(cells) .. '</w:tr></w:tbl>'
  return {
    raw(P("Normal", "", "<w:keepNext/>")),
    raw(P("SignatureLine", "RESPECTFULLY SUBMITTED,", "<w:keepNext/>", "<w:b/><w:bCs/>")),
    raw(P("CaptionLine", "", "<w:keepNext/>")),
    raw(tbl),
  }
end

-- the table of contents (every heading of level 1 and 2, with its page) and the table of authorities (frontmatter pages)
local function front_matter(meta, toc_entries, pages)
  local out = {}
  out[#out + 1] = raw(P("FrontTitle", "TABLE OF CONTENTS"))
  out[#out + 1] = raw(P("Normal", ""))
  out[#out + 1] = raw(P("PageLabel", "Page"))
  for _, e in ipairs(toc_entries) do
    local inl = {}
    for _, x in ipairs(e.inlines) do inl[#inl + 1] = x end
    inl[#inl + 1] = TAB
    inl[#inl + 1] = pandoc.Str(pages[e.idx] or "00")
    out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "TOC Entry" })
  end
  out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="FrontTitle"/><w:pageBreakBefore/></w:pPr>' .. run("TABLE OF AUTHORITIES") .. '</w:p>')
  out[#out + 1] = raw(P("Normal", ""))
  out[#out + 1] = raw(P("PageLabel", "Page(s)"))
  for _, cat in ipairs(meta.authorities or {}) do
    out[#out + 1] = raw(P("AuthorityCategory", string.upper(S(cat.category))))
    for _, a in ipairs(cat.items or {}) do
      local inl = {}
      if type(a.cite[1]) == "userdata" or type(a.cite[1]) == "table" then
        for _, x in ipairs(a.cite) do inl[#inl + 1] = x end
      else
        local d = pandoc.read(S(a.cite), "markdown+smart")
        for _, x in ipairs(d.blocks[1].content) do inl[#inl + 1] = x end
      end
      inl[#inl + 1] = TAB
      inl[#inl + 1] = pandoc.Str(S(a.pages))
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Authority Entry" })
    end
  end
  return out
end

-- inlines of a block that the body keeps (a lettered sub-item: the letter is typed in front of its first paragraph)
local function lettered(b)
  local out = {}
  local start = b.listAttributes.start
  for i, item in ipairs(b.content) do
    local letter = string.char(string.byte("a") + start - 1 + i - 1)
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inl = { pandoc.Str(letter .. "."), pandoc.Space() }
      for _, x in ipairs(first.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Lettered Item" })
      for k = 2, #item do out[#out + 1] = item[k] end
    else
      for _, blk in ipairs(item) do out[#out + 1] = blk end
    end
  end
  return out
end

local function clean(s) return (s:gsub("%s+", "")) end

function Pandoc(doc)
  local meta = doc.meta
  -- headings of levels 1 and 2 (the table of contents), in order; the first body paragraph marks the body start
  local heads, marker = {}, nil
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 2 then
      heads[#heads + 1] = { idx = #heads + 1, inlines = b.content, text = clean(S(b.content)) }
    elseif b.t == "Para" and marker == nil then
      marker = clean(S(b.content)):sub(1, 40)
    end
  end
  local idxfile = os.getenv("CTB_INDEX_OUT")
  if idxfile then
    local f = assert(io.open(idxfile, "w"))
    f:write("start\t" .. (marker or "") .. "\n")
    for _, h in ipairs(heads) do f:write("h\t" .. h.idx .. "\t" .. h.text .. "\n") end
    f:close()
  end
  local pages = {}
  local pagesfile = os.getenv("CTB_PAGES")
  if pagesfile then
    for line in io.lines(pagesfile) do
      local i, p = line:match("^(%d+)\t(%S+)$")
      if i then pages[tonumber(i)] = p end
    end
  end

  local out = {}
  for _, c in ipairs(caption(meta)) do out[#out + 1] = raw(c) end
  out[#out + 1] = section_break(COVER_SECT)
  for _, x in ipairs(front_matter(meta, heads, pages)) do out[#out + 1] = x end
  out[#out + 1] = section_break(FRONT_SECT)

  local numbered = false
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      numbered = true
      local style = ({ [1] = "Heading1", [2] = "Heading2", [3] = "Heading3" })[b.level]
      out[#out + 1] = b
    elseif b.t == "Para" and numbered then
      n = n + 1
      local inl = { pandoc.Str(n .. "."), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Numbered Paragraph" })
    elseif b.t == "OrderedList" and b.listAttributes.style == "LowerAlpha" then
      for _, x in ipairs(lettered(b)) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
