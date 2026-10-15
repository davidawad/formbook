-- N.D. Ill. memorandum in support of a motion (motion-brief), DOCX engine (docs/DOCX.md): the markdown contract ->
-- a Word document on reference.docx. Mirrors typst/ilnd-motion-brief.typ. The cover (court, caption with a column
-- of ")" marks, title, counsel) and the signature block and certificate of service are built here as styled
-- paragraphs and borderless tables; the body keeps its markdown structure. The cover is its own section, so the
-- body's page numbers start at 1 (the template's counter reset). Every case-specific word comes from the sample's
-- frontmatter, never from this file.
-- Not verified (no soffice on this box; see the README "Engines" section): the caption table, the counsel block
-- position (the template pushes it to the foot of the cover), the signature table and the page breaks.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, o)
  o = o or {}
  local rpr = (o.b and "<w:b/><w:bCs/>" or "") .. (o.i and "<w:i/><w:iCs/>" or "")
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- inline elements (pandoc inlines or a MetaInlines list) as runs
local function runs(inl, o)
  o = o or {}
  local out = {}
  for _, x in ipairs(inl or {}) do
    local t = x.t
    if t == "Str" then out[#out + 1] = run(x.text, o)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", o)
    elseif t == "LineBreak" then out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then out[#out + 1] = runs(x.content, { b = o.b, i = true })
    elseif t == "Strong" then out[#out + 1] = runs(x.content, { b = true, i = o.i })
    elseif t == "Quoted" then
      local q1, q2 = "\u{201C}", "\u{201D}"
      if x.quotetype == "SingleQuote" then q1, q2 = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(q1, o) .. runs(x.content, o) .. run(q2, o)
    else
      out[#out + 1] = run(pandoc.utils.stringify(x), o)
    end
  end
  return table.concat(out)
end

-- a metadata value as inlines (a string or a MetaInlines)
local function inl(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaInlines" then return v end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function P(style, body, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (body or "") .. "</w:p>"
end

-- a blank space of exactly `twips` (the template's v(...) spacing; 552 = double line, 276 = single line)
local function space(twips)
  return P("Single", "", '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/>')
end

local function raw(x) return pandoc.RawBlock("openxml", x) end

local NOBORDER = ""
for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
  NOBORDER = NOBORDER .. '<w:' .. side .. ' w:val="nil"/>'
end

local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. "<w:tblBorders>" .. NOBORDER .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. "</w:tblGrid>"
    .. table.concat(rows) .. "</w:tbl>"
end

-- opts: vmerge (xml), valign (string); the cell's paragraphs follow the properties
local function tc(width, paras, opts)
  opts = opts or {}
  local valign = opts.valign and ('<w:vAlign w:val="' .. opts.valign .. '"/>') or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (opts.vmerge or "") .. valign
    .. "</w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

local function tr(cells)
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
end

-- the caption: one row per line of the party column (names, blank rows, "v.", designation), each with a ")" in the
-- next column; the case number and judge sit in the last column, centred vertically across the rows
local function caption(meta)
  local lines = {}
  for k, p in ipairs((meta.caption and meta.caption.parties) or {}) do
    if k > 1 then
      lines[#lines + 1] = {}
      lines[#lines + 1] = { text = "v.", ind = 1440 }
      lines[#lines + 1] = {}
    end
    for _, n in ipairs(p.names or {}) do lines[#lines + 1] = { inl = n } end
    lines[#lines + 1] = {}
    lines[#lines + 1] = { inl = p.designation, ind = 720 }
  end
  local right = { P("Single", run("Case No. " .. plain(meta.case_number))) }
  if meta.judge then
    right[#right + 1] = P("Single", run("Honorable " .. plain(meta.judge)), '<w:spacing w:before="120"/>')
  end
  local rows = {}
  for i, l in ipairs(lines) do
    local name
    if l.text then name = run(l.text) elseif l.inl then name = runs(inl(l.inl)) else name = "" end
    local cells = {
      tc(4608, { P("Single", name, l.ind and ('<w:ind w:left="' .. l.ind .. '"/>') or "") }),
      tc(432, { P("Single", run(")")) }),
      tc(432, { P("Single", "") }),
    }
    if i == 1 then
      cells[#cells + 1] = tc(3888, right, { vmerge = '<w:vMerge w:val="restart"/>', valign = "center" })
    else
      cells[#cells + 1] = tc(3888, { P("Single", "") }, { vmerge = "<w:vMerge/>" })
    end
    rows[#rows + 1] = tr(cells)
  end
  return table_xml({ 4608, 432, 432, 3888 }, rows)
end

-- counsel block at the lower right of the cover; one group per counsel, a blank line between groups
local function counsel(meta)
  local out = {}
  for k, g in ipairs(meta.counsel or {}) do
    if k > 1 then out[#out + 1] = space(240) end
    for _, l in ipairs(g) do out[#out + 1] = P("Single", runs(inl(l)), '<w:ind w:left="4752"/>') end
  end
  return table.concat(out)
end

-- signature block: "Dated" at left; the party, "By: /s/" and the signer's role at right (as in the template)
local function signature(meta)
  local sig = meta.signature or {}
  local right = { P("Single", run("Respectfully submitted,")), space(240) }
  for _, l in ipairs(sig.party or {}) do right[#right + 1] = P("Single", runs(inl(l))) end
  right[#right + 1] = space(240)
  right[#right + 1] = P("Single", run("By: /s/ " .. plain(sig.signer)))
  for _, l in ipairs(sig.role or {}) do right[#right + 1] = P("Single", runs(inl(l))) end
  local left = { P("BodyText", run("Dated: " .. plain(meta.date)), '<w:ind w:firstLine="0"/>') }
  return table_xml({ 4032, 288, 5040 }, {
    tr({ tc(4032, left), tc(288, { P("Single", "") }), tc(5040, right) }),
  })
end

local function letter(i)
  if i <= 26 then return string.char(96 + i) end
  return tostring(i)
end

-- a list item: the label, a tab, then the item's first paragraph in the hanging style; any further blocks follow
local function item(label, blocks)
  local out = {}
  local first = blocks[1]
  if first and (first.t == "Plain" or first.t == "Para") then
    local c = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
    c:extend(first.content)
    out[1] = pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "Hanging Item" }))
    for i = 2, #blocks do out[#out + 1] = blocks[i] end
  else
    for _, b in ipairs(blocks) do out[#out + 1] = b end
  end
  return out
end

-- page size and margins shared by the cover section and the body section (the body's footer and numbering
-- come from reference.docx)
local SECT_COVER = '<w:p><w:pPr><w:sectPr><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  .. "</w:sectPr></w:pPr></w:p>"
local PAGE_BREAK = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court, division, caption, title, counsel; no page number (its own section)
  local cover = P("Centered", run("IN THE UNITED STATES DISTRICT COURT", { b = true }))
    .. P("Centered", run("FOR THE NORTHERN DISTRICT OF ILLINOIS", { b = true }))
  if meta.division then cover = cover .. P("Centered", run(string.upper(plain(meta.division)), { b = true })) end
  cover = cover .. space(552) .. caption(meta) .. space(1104)
  for _, l in ipairs(meta.brief_title or {}) do cover = cover .. P("Centered", runs(inl(l), { b = true })) end
  cover = cover .. space(1104) .. counsel(meta) .. SECT_COVER
  add(raw(cover))

  -- body: the first block, a level-1 heading, ends the cover section; the last block stays with the signature
  local body = {}
  for _, b in ipairs(doc.blocks) do body[#body + 1] = b end
  if #body > 0 then
    local last = body[#body]
    body[#body] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "Keep With Next" }))
  end
  for _, b in ipairs(body) do add(b) end
  add(raw(space(552) .. signature(meta)))
  add(raw(P("Single", "")))  -- a Word body does not end on a table

  -- certificate of service: its own page (Fed. R. Civ. P. 5(b)), double-spaced text, signed by counsel
  if meta.certificate then
    local cert = PAGE_BREAK .. P("Heading1", run("CERTIFICATE OF SERVICE"))
      .. P("BodyText", runs(inl(meta.certificate.text)))
      .. space(552)
    local sig = { P("Single", run("/s/ " .. plain(meta.certificate.signer)), '<w:ind w:left="4752"/>') }
    for _, l in ipairs(meta.certificate.role or {}) do
      sig[#sig + 1] = P("Single", runs(inl(l)), '<w:ind w:left="4752"/>')
    end
    cert = cert .. table.concat(sig)
    add(raw(cert))
  end

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
