-- Memorandum of law, DOCX engine (docs/DOCX.md). Mirrors typst/ctd-motion-brief.typ (requirement IDs in ../README.md).
-- The cover (court, caption table with its rules, optional oral-argument legend in the footer), the table of contents
-- and the table of authorities (roman pages), the body (arabic pages) with numbered headings, lettered and numbered
-- lists, footnotes, the signature block and the certification of service. Section breaks are raw OpenXML sectPr.
--
-- Every case word comes from the sample's frontmatter; nothing here is case-specific.
-- Page numbers in the TOC and TOA come from a first pass (docx/render.sh): this filter writes the search index
-- (MOTION_INDEX_OUT) on the first pass and reads the page map (MOTION_PAGES) on the second. The map gives printed
-- page numbers (body pages from 1).

local TEXT_W = 9360    -- twips: 6.5 in between the margins
local PASSIM_AT = 7    -- an authority on this many pages or more prints "passim" (as typst/ctd-motion-brief.typ)
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function minl(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return (v[1] and v[1].content) or {} end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

-- one run of text, with direct bold / italic / caps-free formatting
local function run(text, opts)
  opts = opts or {}
  local rpr = ""
  if opts.bold or opts.italic then
    rpr = "<w:rPr>" .. (opts.bold and "<w:b/><w:bCs/>" or "") .. (opts.italic and "<w:i/><w:iCs/>" or "") .. "</w:rPr>"
  end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
end

-- inlines -> OpenXML runs (for the cover, counsel and signature blocks, which are written as OpenXML)
local function runs(inl, flags)
  local out = {}
  local function r(text)
    out[#out + 1] = run(text, flags)
  end
  for _, e in ipairs(inl) do
    local t = e.t
    if t == "Str" then r(e.text)
    elseif t == "Space" or t == "SoftBreak" then r(" ")
    elseif t == "Emph" then out[#out + 1] = runs(e.content, { bold = flags.bold, italic = true })
    elseif t == "Strong" then out[#out + 1] = runs(e.content, { bold = true, italic = flags.italic })
    elseif t == "Quoted" then
      local q = e.quotetype == "SingleQuote" and { "\u{2018}", "\u{2019}" } or { "\u{201C}", "\u{201D}" }
      r(q[1]); out[#out + 1] = runs(e.content, flags); r(q[2])
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(e.content, flags)
    else r(pandoc.utils.stringify(e)) end
  end
  return table.concat(out)
end

-- a paragraph: style, optional extra paragraph properties (in schema order, after the style), runs
local function P(style, inner, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. '</w:pPr>' .. (inner or "") .. '</w:p>'
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- the end of a section: an empty paragraph carrying the section properties (footer and page numbering)
local function section_break(footer_rid, pgnum)
  return '<w:p><w:pPr><w:pStyle w:val="Normal"/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' ..
    '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>' ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>' ..
    (pgnum or "") .. '<w:cols w:space="720"/></w:sectPr></w:pPr></w:p>'
end

local function no_borders()
  return '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
end

-- a borderless table: the widths in twips, the cells as {width, xml, cell-properties}
local function table_xml(grid, cells)
  local cols, total = {}, 0
  for _, w in ipairs(grid) do cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'; total = total + w end
  local tcs = {}
  for _, c in ipairs(cells) do
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' .. c[2] .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. no_borders() ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- the cover: the court (single spaced, centred, bold caps), a double line, the caption table (the party column with
-- a right and a bottom rule; the title at the right in bold caps), the legend is in the cover footer
local function cover(meta)
  local out = {}
  for _, l in ipairs(meta.court or {}) do
    out[#out + 1] = P("PleadingSingle", run(string.upper(str(l)), { bold = true }), '<w:jc w:val="center"/>')
  end
  out[#out + 1] = P("Normal", "")

  -- party column: each side's names, the designation indented 1.5 in, "v." between the sides
  local left = {}
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names or {}) do left[#left + 1] = P("PleadingSingle", runs(minl(n), {})) end
    left[#left + 1] = P("PleadingSingle", runs(minl(side.designation), {}), '<w:ind w:left="2160" w:firstLine="0"/>')
    if i < #sides then
      left[#left + 1] = P("PleadingSingle", run("v."), '<w:spacing w:before="276" w:after="276" w:line="276" w:lineRule="exact"/>')
    end
  end
  local right = {
    P("PleadingSingle", run("Case No. " .. str(meta.case_number))),
    P("PleadingSingle", "", '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>'),
    P("PleadingSingle", run("Date: " .. str(meta.date))),
    P("PleadingSingle", "", '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>'),
    P("PleadingSingle", run(string.upper(str(meta.brief_title)), { bold = true })),
  }
  out[#out + 1] = table_xml({ 4752, 288, 4320 }, {
    { 4752, table.concat(left),
      '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
      '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:right w:w="144" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/></w:tcMar>' },
    { 288, P("PleadingSingle", "") },
    { 4320, table.concat(right), '<w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="144" w:type="dxa"/></w:tcMar>' },
  })
  out[#out + 1] = section_break("rId102", nil)
  return table.concat(out)
end

-- authorities: the kinds and the order of their groups (as typst/ctd-motion-brief.typ)
local KINDS = {
  { "case", "Cases" },
  { "statute", "Statutes" },
  { "rule", "Federal Rules" },
  { "regulation", "Regulations" },
  { "other", "Other Authorities" },
}

-- the page map of the first pass: "h<TAB>seq<TAB>page" and "t<TAB>key<TAB>pages" (printed page numbers)
local function read_pagemap()
  local path = os.getenv("MOTION_PAGES")
  local pm = { h = {}, t = {} }
  if not path then return pm end
  local f = assert(io.open(path, "r"))
  for line in f:lines() do
    local kind, id, val = line:match("^(%a+)\t([^\t]*)\t(.*)$")
    if kind == "h" then pm.h[tonumber(id)] = val
    elseif kind == "t" then pm.t[id] = val end
  end
  f:close()
  return pm
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- the table of contents: each heading of levels 1 to 4 with its page, label and title, dot leader to the page
local function toc(headings, pm)
  local out = { P("FrontHeading", run("Table of Contents")) }
  out[#out + 1] = P("PleadingSingle", run("Page", { bold = true }), '<w:jc w:val="right"/>')
  for _, h in ipairs(headings) do
    if h.level <= 4 then
      local ind = math.max(h.level - 2, 0) * 720
      local page = pm.h[h.seq] or "0"
      local inner
      if h.level == 1 then
        inner = run(string.upper(h.title)) .. '<w:r><w:tab/></w:r>' .. run(page)
      else
        inner = run(h.label) .. '<w:r><w:tab/></w:r>' .. run(h.title) .. '<w:r><w:tab/></w:r>' .. run(page)
      end
      out[#out + 1] = P("TocEntry", inner,
        '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + 720) .. '"/></w:tabs>' ..
        '<w:ind w:left="' .. (ind + 720) .. '" w:right="720" w:hanging="720"/>')
    end
  end
  return table.concat(out)
end

-- the table of authorities: the authorities the memorandum links to, by kind, with their printed pages
local function toa(meta, hit_order, pm)
  local out = { P("FrontHeading", run("Table of Authorities")) }
  out[#out + 1] = P("PleadingSingle", run("Page(s)", { bold = true }), '<w:jc w:val="right"/>')
  local members = {}
  for _, key in ipairs(hit_order) do
    local a = meta.authorities[key]
    members[#members + 1] = { key = key, kind = str(a.kind), name = a.name and str(a.name) or nil, cite = str(a.cite) }
  end
  for _, g in ipairs(KINDS) do
    local group = {}
    for _, m in ipairs(members) do if m.kind == g[1] then group[#group + 1] = m end end
    if #group > 0 then
      table.sort(group, function(x, y) return string.lower(x.name or x.cite) < string.lower(y.name or y.cite) end)
      out[#out + 1] = P("AuthorityGroup", run(g[2]))
      for _, m in ipairs(group) do
        local pages = pm.t[m.key] or "0"
        local count = 0
        for _ in pages:gmatch("[^,]+") do count = count + 1 end
        local shown = count >= PASSIM_AT and run("passim", { italic = true }) or run(pages)
        local name_runs = ""
        if m.name then name_runs = run(m.name, { italic = (m.kind == "case") }) .. run(", ") end
        out[#out + 1] = P("TableAuthority", name_runs .. run(m.cite) .. '<w:r><w:tab/></w:r>' .. shown)
      end
    end
  end
  return table.concat(out)
end

-- the signature block (CTD-SIG-001): "Dated:" at left; "Respectfully submitted," and each signer at right
local function signature(meta)
  local sig = meta.signature or {}
  local signers = { sig }
  for _, o in ipairs(sig.others or {}) do signers[#signers + 1] = o end
  local left = { P("SignatureBlock", run("Dated: " .. str(meta.date))) }
  local right = { P("SignatureBlock", run("Respectfully submitted,")) }
  for _, s in ipairs(signers) do
    right[#right + 1] = P("PleadingSingle", "", '<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/>')
    right[#right + 1] = P("SignatureBlock", run("BY: /s/ " .. str(s.signer)))
    local name = str(s.signer)
    if s.bar then name = name .. ", Fed. Bar No. " .. str(s.bar) end
    right[#right + 1] = P("PleadingSingle", run(name))
    for _, l in ipairs(s.lines or {}) do right[#right + 1] = P("PleadingSingle", runs(minl(l), {})) end
  end
  return P("PleadingSingle", "", '<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/>') ..
    table_xml({ 3744, 5616 }, {
      { 3744, table.concat(left) },
      { 5616, table.concat(right), '<w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>' },
    })
end

-- the certification of service (CTD-CERT-001): a centred heading (not in the table of contents), the text flush and
-- double spaced, the signer at right
local function certification(meta)
  local c = meta.certification
  if not c then return "" end
  local out = { P("FrontHeading", run("Certification of Service")) }
  -- the certification is one block: its heading, text and spacer keep with the next paragraph (the signature table)
  out[#out + 1] = P("Normal", runs(minl(c.text), {}), "<w:keepNext/><w:keepLines/>" .. '<w:ind w:firstLine="0"/>')
  out[#out + 1] = P("PleadingSingle", "", "<w:keepNext/>" .. '<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/>')
  local right = { P("SignatureBlock", run("/s/ " .. str(c.signer))), P("PleadingSingle", run(str(c.signer))) }
  for _, l in ipairs(c.lines or {}) do right[#right + 1] = P("PleadingSingle", runs(minl(l), {})) end
  out[#out + 1] = table_xml({ 3744, 5616 }, {
    { 3744, P("PleadingSingle", "") },
    { 5616, table.concat(right), '<w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>' },
  })
  return table.concat(out)
end

-- label of a numbered heading: level 2 "A.", 3 "1.", 4 "a." (level 1 is unnumbered)
local function label_of(level, c)
  if level == 2 then return string.char(string.byte("A") + c[2] - 1) .. "."
  elseif level == 3 then return tostring(c[3]) .. "."
  elseif level == 4 then return string.char(string.byte("a") + c[4] - 1) .. "."
  end
  return nil
end

local function strip_ws(s)
  return (s:gsub("%s", ""):gsub("\194\160", ""):lower())
end

local function first_chars(s, n)
  local len = utf8.len(s)
  if len and len > n then return s:sub(1, utf8.offset(s, n + 1) - 1) end
  return s
end

function Pandoc(doc)
  local meta = {}
  for k, v in pairs(doc.meta) do meta[k] = v end
  -- pandoc would print the date as a title block; the date is set in the caption and the signature block instead
  doc.meta.date = nil
  local index_out = os.getenv("MOTION_INDEX_OUT")
  local pm = read_pagemap()

  -- 1. the authority links (toa:KEY): recorded for the index and the table, then shown as plain text
  local hits, hit_order = {}, {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if key then
        if not meta.authorities or not meta.authorities[key] then
          error("motion-brief: link toa:" .. key .. " has no entry under authorities: in the frontmatter")
        end
        if not hits[key] then hits[key] = {}; hit_order[#hit_order + 1] = key end
        hits[key][#hits[key] + 1] = strip_ws(first_chars(str(el.content), 40))
        return el.content
      end
    end,
  })

  -- 2. the headings, numbered as the memorandum numbers them
  local headings = {}
  local c = { 0, 0, 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local L = b.level
      c[L] = c[L] + 1
      for j = L + 1, 6 do c[j] = 0 end
      headings[#headings + 1] = { level = L, label = label_of(L, c), title = str(b.content), seq = #headings + 1 }
    end
  end

  -- 3. the search index for the first pass: the body's first words, then each heading and each authority's text
  local first_para
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then first_para = strip_ws(first_chars(str(b), 40)); break end
  end
  if index_out then
    local f = assert(io.open(index_out, "w"))
    f:write("start\t\t" .. (first_para or "") .. "\n")
    for _, h in ipairs(headings) do
      f:write("h\t" .. h.seq .. "\t" .. strip_ws(first_chars(h.title, 40)) .. "\n")
    end
    for _, key in ipairs(hit_order) do
      for _, s in ipairs(hits[key]) do f:write("t\t" .. key .. "\t" .. s .. "\n") end
    end
    f:close()
  end

  -- 4. the front matter: cover, table of contents, table of authorities (each in its own section)
  local out = { raw(cover(meta)) }
  out[#out + 1] = raw(toc(headings, pm) .. section_break("rId101", '<w:pgNumType w:fmt="lowerRoman" w:start="1"/>'))
  out[#out + 1] = raw(toa(meta, hit_order, pm) .. section_break("rId101", '<w:pgNumType w:fmt="lowerRoman"/>'))

  -- 5. the body: headings with their labels, lists lettered or numbered as the template, quotations single spaced
  local hi = 0
  local blocks = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      hi = hi + 1
      if b.level == 1 then
        blocks[#blocks + 1] = b
      else
        local inl = pandoc.List({ pandoc.Str(headings[hi].label), TAB })
        inl:extend(b.content)
        blocks[#blocks + 1] = pandoc.Header(b.level, inl, b.attr)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local start = 1
      if b.t == "OrderedList" and b.listAttributes and b.listAttributes.start then start = b.listAttributes.start end
      for k, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and ((start + k - 1) .. ")") or "\u{2022}"
        for _, ib in ipairs(item) do
          if ib.t == "Plain" or ib.t == "Para" then
            local inl = pandoc.List({ pandoc.Str(label), TAB })
            inl:extend(ib.content)
            blocks[#blocks + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Item" }))
          else
            blocks[#blocks + 1] = ib
          end
        end
      end
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        blocks[#blocks + 1] = pandoc.Div({ q }, pandoc.Attr("", {}, { ["custom-style"] = "Block Text" }))
      end
    else
      blocks[#blocks + 1] = b
    end
  end
  for _, b in ipairs(blocks) do out[#out + 1] = b end
  out[#out + 1] = raw(signature(meta))
  out[#out + 1] = raw(certification(meta))
  doc.blocks = out
  return doc
end
