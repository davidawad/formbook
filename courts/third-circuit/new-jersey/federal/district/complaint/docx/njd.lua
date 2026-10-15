-- U.S. District Court, District of New Jersey, complaint: DOCX engine (docs/DOCX.md).
-- The markdown contract of ../README.md -> a Word document on reference.docx. The cover (counsel block, court
-- title, caption table with the party column closed by a right and a bottom rule, title), the body paragraph
-- numbers (Fed. R. Civ. P. 10(b)), the signature blocks and the certification (L.Civ.R. 11.2, on its own page)
-- are built here as raw OOXML in the styles of reference.docx ("Single", "Centered", "Gap", "Half", "CertTitle").
-- The body keeps its markdown structure (headings, lettered lists). Page numbers come from the reference footer.
-- Known limits: see README.md, "Engines".

-- The only values that differ from the typst template's parameters are the twip conversions (1 in = 1440).
local CFG = {
  court_name_caps = true,
  caption_left = 4608,      -- party column: 3.2 in (typst caption-left)
  caption_gutter = 360,     -- 0.25 in
  caption_right = 4392,     -- the rest of the 6.5 in text width
  party_indent = 2592,      -- designation indented 1.8 in (typst pad left)
  sig_left = 4320,          -- "Dated:" column: 3 in
  sig_right = 5040,         -- firm and signer column: the rest
  blank_case_number = "__________________",
}

-- ---------------------------------------------------------------------------
-- Metadata helpers
-- ---------------------------------------------------------------------------

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- a metadata value (markdown inlines or blocks) as a list of blocks
local function meta_blocks(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return { pandoc.Plain(v) } end
  local out = {}
  for _, b in ipairs(v) do out[#out + 1] = b end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("njd: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- ---------------------------------------------------------------------------
-- OOXML fragments (raw), built from pandoc inlines
-- ---------------------------------------------------------------------------

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function with(p, k)
  local q = {}
  for a, b in pairs(p) do q[a] = b end
  q[k] = true
  return q
end

local function rpr(p)
  local s = ""
  if p.b then s = s .. "<w:b/><w:bCs/>" end
  if p.i then s = s .. "<w:i/><w:iCs/>" end
  if s == "" then return "" end
  return "<w:rPr>" .. s .. "</w:rPr>"
end

local function run(text, p)
  if p.caps then text = text:upper() end
  return "<w:r>" .. rpr(p) .. '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

-- inlines -> runs (only the inline kinds the front matter uses: text, emphasis, strong, quotes, breaks)
local function runs(list, p, out)
  out = out or {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, p)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", p)
    elseif t == "LineBreak" then out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then runs(el.content, with(p, "i"), out)
    elseif t == "Strong" then runs(el.content, with(p, "b"), out)
    elseif t == "Quoted" then
      local q1, q2 = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then q1, q2 = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(q1, p)
      runs(el.content, p, out)
      out[#out + 1] = run(q2, p)
    elseif t == "Link" or t == "Span" then runs(el.content, p, out)
    elseif t == "Code" then out[#out + 1] = run(el.text, p)
    else out[#out + 1] = run(pandoc.utils.stringify(el), p)
    end
  end
  return out
end

-- one paragraph: style, optional left indent (twips), inlines, run properties
local function para_xml(style, list, p, indent)
  local ppr = ""
  if style then ppr = '<w:pStyle w:val="' .. style .. '"/>' end
  if indent then ppr = ppr .. '<w:ind w:left="' .. indent .. '" w:firstLine="0"/>' end
  if ppr ~= "" then ppr = "<w:pPr>" .. ppr .. "</w:pPr>" end
  return "<w:p>" .. ppr .. table.concat(runs(list or {}, p or {}), "") .. "</w:p>"
end

local function cat(...)
  local out = {}
  for _, l in ipairs({ ... }) do
    for _, x in ipairs(l) do out[#out + 1] = x end
  end
  return out
end

-- a table cell: paras = { {style=, list=, p=, indent=} }; rules and padding in twips
local function cell_xml(w, c)
  local tcpr = '<w:tcW w:w="' .. w .. '" w:type="dxa"/>'
  local b = ""
  if c.bottom_rule then b = b .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  if c.right_rule then b = b .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  if b ~= "" then tcpr = tcpr .. "<w:tcBorders>" .. b .. "</w:tcBorders>" end
  local mar = ""
  if c.left_pad then mar = mar .. '<w:left w:w="' .. c.left_pad .. '" w:type="dxa"/>' end
  if c.right_pad then mar = mar .. '<w:right w:w="' .. c.right_pad .. '" w:type="dxa"/>' end
  if mar ~= "" then tcpr = tcpr .. "<w:tcMar>" .. mar .. "</w:tcMar>" end
  local body = {}
  for _, p in ipairs(c.paras) do body[#body + 1] = para_xml(p.style, p.list, p.p, p.indent) end
  if #body == 0 then body[1] = "<w:p/>" end
  return "<w:tc><w:tcPr>" .. tcpr .. "</w:tcPr>" .. table.concat(body) .. "</w:tc>"
end

-- a borderless table with fixed column widths; rows = { { cell, cell, ... }, ... }
local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local out = {
    '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
      .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
      .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
      .. '<w:tblLayout w:type="fixed"/>'
      .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
      .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. "</w:tblGrid>",
  }
  for _, row in ipairs(rows) do
    local cells = {}
    for i, c in ipairs(row) do cells[#cells + 1] = cell_xml(widths[i], c) end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- ---------------------------------------------------------------------------
-- Cover, caption, signature blocks, certification
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local function add(xml) out[#out + 1] = raw(xml) end
  for _, line in ipairs(need(meta, "counsel")) do add(para_xml("Single", line)) end
  add(para_xml("Gap", {}))
  for _, line in ipairs(need(meta, "court")) do
    add(para_xml("Centered", line, { b = true, caps = CFG.court_name_caps }))
  end
  add(para_xml("Gap", {}))

  -- caption: parties (left, closed by a right and a bottom rule), case number, judge and title (right)
  local left = {}
  for k, party in ipairs(need(meta, "caption").parties) do
    if k > 1 then left[#left + 1] = { style = "Single", list = { pandoc.Str("v.") } } end
    for _, n in ipairs(party.names) do left[#left + 1] = { style = "Single", list = n } end
    left[#left + 1] = { style = "Single", list = party.designation, indent = CFG.party_indent }
  end
  left[#left + 1] = { style = "Half", list = {} }

  local cn = plain(need(meta, "case_number"))
  local right = {}
  right[#right + 1] = { style = "Single", list = { pandoc.Str("Civil Action No. " .. (cn == "" and CFG.blank_case_number or cn)) } }
  local judge = plain(need(meta, "judge"))
  if judge ~= "" then
    right[#right + 1] = { style = "Single", list = { pandoc.Str("Hon. " .. judge .. ", U.S.D.J.") } }
  end
  right[#right + 1] = { style = "Half", list = {} }
  right[#right + 1] = { style = "Half", list = {} }
  right[#right + 1] = { style = "Single", list = need(meta, "title"), p = { b = true, caps = true } }

  add(table_xml({ CFG.caption_left, CFG.caption_gutter, CFG.caption_right }, {
    {
      { paras = left, right_rule = true, bottom_rule = true, right_pad = 200 },
      { paras = {} },
      { paras = right, left_pad = 144 },
    },
  }))
  add(para_xml("Gap", {}))
  return out
end

local function signature(date, sig)
  local left = { { style = "Single", list = cat({ pandoc.Str("Dated: ") }, date) } }
  local right = {}
  for _, l in ipairs(sig.firm) do right[#right + 1] = { style = "Single", list = l } end
  right[#right + 1] = { style = "Half", list = {} }
  right[#right + 1] = { style = "Single", list = cat({ pandoc.Str("By: /s/ ") }, sig.signer) }
  for _, l in ipairs(sig.lines) do right[#right + 1] = { style = "Single", list = l } end
  return table_xml({ CFG.sig_left, CFG.sig_right }, {
    { { paras = left }, { paras = right } },
  })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

function Pandoc(doc)
  local meta = doc.meta
  local prefixes = {}
  for _, p in ipairs(meta.unnumbered_prefixes or {}) do prefixes[#prefixes + 1] = plain(p) end

  -- loud failures (as the typst template does)
  for _, k in ipairs({ "counsel", "court", "caption", "case_number", "judge", "title", "jury_demand", "date", "signature" }) do
    need(meta, k)
  end
  if meta.jury_demand and not plain(meta.title):lower():find("demand for jury trial", 1, true) then
    error("njd: a jury demand needs `and Demand for Jury Trial` in the title (L.Civ.R. 38.1)", 0)
  end

  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local text = pandoc.utils.stringify(b)
      local unnumbered = false
      for _, p in ipairs(prefixes) do
        if starts_with(text, p) then unnumbered = true end
      end
      if not unnumbered then
        n = n + 1
        table.insert(b.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
        table.insert(b.content, 1, pandoc.Str(n .. "."))
      end
    elseif b.t == "OrderedList" then
      -- the prayer items are lettered (a., b., ...), as in the typst template
      b.listAttributes = pandoc.ListAttributes(1, "LowerAlpha", "Period")
    end
    out[#out + 1] = b
  end

  out[#out + 1] = raw(para_xml("Gap", {}))
  out[#out + 1] = raw(signature(need(meta, "date"), need(meta, "signature")))

  -- certification (L.Civ.R. 11.2): its own page, its own signature
  if meta.certification then
    local cert = meta.certification
    out[#out + 1] = raw(para_xml("CertTitle", cert.title, { b = true, caps = true }))
    for _, b in ipairs(meta_blocks(cert.text)) do out[#out + 1] = b end
    out[#out + 1] = raw(para_xml("Gap", {}))
    out[#out + 1] = raw(signature(cert.date, cert.signature))
  end

  -- pandoc would print the title and date metadata as its own title block; the cover is built here instead
  doc.meta.title, doc.meta.subtitle, doc.meta.author, doc.meta.date, doc.meta.abstract = nil, nil, nil, nil, nil
  doc.blocks = out
  return doc
end
