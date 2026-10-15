-- N.D. Ill. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/ilnd-complaint.typ. The first page (court title, caption box, title, jury legend) and the
-- signature block are built here as styled paragraphs and tables; the body keeps its markdown structure.
-- Numbers (1, 2, ...) and prayer letters ((a), (b), ...) are typed text, not Word list numbering.
-- Every case-specific word comes from the sample's frontmatter, never from this file.
-- Not verified (no soffice on this box; see the README "Engines" section): the caption box borders, the
-- position of the numbers, the signature table and the page breaks.

local UNNUMBERED = { ["prayer for relief"] = true, ["demand for jury trial"] = true }

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

-- opts: borders, mar (xml); the cell's paragraphs follow the properties
local function tc(width, paras, opts)
  opts = opts or {}
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (opts.borders or "") .. (opts.mar or "")
    .. "</w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

local function tr(cells)
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
end

-- the caption box: the names and designation of each party, "v." between them; the party column is closed by
-- a rule on its right and bottom (as in the template)
local function caption(meta)
  local left = {}
  local parties = (meta.caption and meta.caption.parties) or {}
  for k, p in ipairs(parties) do
    if k > 1 then left[#left + 1] = P("Single", run("v."), '<w:ind w:left="1296"/>') end
    for _, n in ipairs(p.names or {}) do left[#left + 1] = P("Single", runs(inl(n))) end
    left[#left + 1] = P("Single", runs(inl(p.designation)), '<w:ind w:left="720"/>')
  end
  local right = { P("Single", run("Case No.: " .. plain(meta.case_number))) }
  if meta.judge then
    right[#right + 1] = space(120)
    right[#right + 1] = P("Single", run("Judge " .. plain(meta.judge)))
  end
  right[#right + 1] = space(288)
  for _, l in ipairs(meta.brief_title or {}) do right[#right + 1] = P("Single", runs(inl(l), { b = true })) end
  if meta.jury_demand then
    right[#right + 1] = space(288)
    right[#right + 1] = P("Single", run("JURY TRIAL DEMANDED", { b = true }))
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return table_xml({ 4608, 360, 4392 }, {
    tr({
      tc(4608, left, { borders = rule, mar = '<w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>' }),
      tc(360, { P("Single", "") }),
      tc(4392, right, { mar = '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>' }),
    }),
  })
end

-- signature block: "Dated" at left; the firm's signature lines at right (as in the template)
local function signature(meta)
  local sig = meta.signature or {}
  local right = { P("Single", run("Respectfully submitted,")), space(240), P("Single", run("/s/ " .. plain(sig.signer))) }
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = P("Single", runs(inl(l))) end
  right[#right + 1] = space(240)
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = P("Single", runs(inl(l))) end
  right[#right + 1] = space(240)
  for _, l in ipairs(sig.party or {}) do right[#right + 1] = P("Single", runs(inl(l))) end
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

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- first page: court, division, caption box, the title and the jury legend (typst: court-title, caption)
  local title = P("Centered", run("IN THE UNITED STATES DISTRICT COURT", { b = true }))
    .. P("Centered", run("FOR THE NORTHERN DISTRICT OF ILLINOIS", { b = true }))
  if meta.division then title = title .. P("Centered", run(string.upper(plain(meta.division)), { b = true })) end
  add(raw(title))
  add(raw(space(552)))
  add(raw(caption(meta)))
  add(raw(space(552)))
  if meta.lead_in then add(raw(P("BodyText", runs(inl(meta.lead_in))))) end

  -- body: numbered paragraphs (1, 2, ...) until a level-1 heading in UNNUMBERED; lettered list items
  local numbered, n = true, 0
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then numbered = not UNNUMBERED[plain(b.content):lower()] end
      body[#body + 1] = b
    elseif b.t == "Para" then
      if numbered then
        n = n + 1
        table.insert(b.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
        table.insert(b.content, 1, pandoc.Str(n .. "."))
      end
      body[#body + 1] = b
    elseif b.t == "OrderedList" then
      for i, it in ipairs(b.content) do
        for _, x in ipairs(item("(" .. letter(i) .. ")", it)) do body[#body + 1] = x end
      end
    elseif b.t == "BulletList" then
      for _, it in ipairs(b.content) do
        for _, x in ipairs(item("\u{2022}", it)) do body[#body + 1] = x end
      end
    else
      body[#body + 1] = b
    end
  end
  -- the last block stays with the signature block
  if #body > 0 then
    local last = body[#body]
    body[#body] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "Keep With Next" }))
  end
  for _, b in ipairs(body) do add(b) end
  add(raw(signature(meta)))
  add(raw(P("Single", "")))  -- a Word body does not end on a table

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
