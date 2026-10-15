-- Shared helpers for the orb (D. Or. Bankruptcy) DOCX filters: the cover (counsel, court title, LBR 9004-2(c)
-- caption as a borderless table) and the signature block, as OpenXML. Loaded with dofile() by the doc-type filter.
-- The values are the typst parameters of orb-*.typ: 12 pt EB Garamond; body line 24 pt (exact 480 twips);
-- single line 13.8 pt (276); the v(leading-double) gap 16.2 pt (324); letter, 7 in text width (10080 twips).
local M = {}

M.SINGLE = 276      -- one single-spaced line (exact)
M.GAP = 324         -- the typst v(leading-double): 16.2 pt
M.CAP_LEFT = 4896   -- caption party column: 3.4 in
M.CAP_PAREN = 432   -- caption ")" column: 0.3 in
M.CAP_RIGHT = 4752  -- caption case-number column: the rest of 7 in
M.CAP_LEFT_PT = 244.8

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines -> runs; flags: b (bold), i (italic)
local function runs(inl, flags)
  local out = {}
  local function run(text)
    local rpr = ""
    if flags.b then rpr = rpr .. "<w:b/><w:bCs/>" end
    if flags.i then rpr = rpr .. "<w:i/><w:iCs/>" end
    out[#out + 1] = '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
      '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
  end
  for _, e in ipairs(inl) do
    local t = e.t
    if t == "Str" then run(e.text)
    elseif t == "Space" or t == "SoftBreak" then run(" ")
    elseif t == "LineBreak" then out[#out + 1] = '<w:r><w:br/></w:r>'
    elseif t == "Emph" then out[#out + 1] = runs(e.content, { b = flags.b, i = true })
    elseif t == "Strong" then out[#out + 1] = runs(e.content, { b = true, i = flags.i })
    elseif t == "Quoted" then
      local q = e.quotetype == "SingleQuote" and { "\u{2018}", "\u{2019}" } or { "\u{201C}", "\u{201D}" }
      run(q[1]); out[#out + 1] = runs(e.content, flags); run(q[2])
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(e.content, flags)
    elseif t == "Code" then run(e.text)
    else run(pandoc.utils.stringify(e)) end
  end
  return table.concat(out)
end
M.runs = runs

-- a meta value as inlines (a markdown paragraph, or the first block of a block value)
function M.minl(v)
  if v == nil then return {} end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" then return v end
  if ty == "Blocks" then return (v[1] and v[1].content) or {} end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

-- a meta value as blocks (pandoc has already read a multi-line YAML value as markdown)
function M.blocks_of(v)
  if v == nil then return {} end
  local ty = pandoc.utils.type(v)
  if ty == "Blocks" then return v end
  if ty == "Inlines" then return { pandoc.Para(v) } end
  return pandoc.read(pandoc.utils.stringify(v), "markdown").blocks
end

-- plain text of a meta value (caption rows, case numbers)
function M.plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- one paragraph of OpenXML with a paragraph style (styleId) and inlines
function M.PX(inl, sid)
  return '<w:p><w:pPr><w:pStyle w:val="' .. sid .. '"/></w:pPr>' .. runs(inl, {}) .. '</w:p>'
end

-- an empty paragraph exactly `tw` twips high (the typst v() gaps)
function M.pad(tw)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. tw .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- a page break before the next paragraph (the typst pagebreak())
function M.page_break()
  return '<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="2" w:lineRule="exact"/></w:pPr></w:p>'
end

-- a Pandoc block: inlines in a paragraph style (a custom-style Div, so pandoc keeps the inline markup)
function M.styled(inl, style)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- Width estimate for EB Garamond (em fractions, rounded from the face's average advances). Used only to count
-- the wrapped lines of a caption party line, so that the ")" column has one mark per line, as the typst
-- template measures them.
local EM = { upper = 0.62, lower = 0.43, digit = 0.5, space = 0.25, punct = 0.3, other = 0.5 }
local function cp_em(cp)
  local c = utf8.char(cp)
  if c == " " then return EM.space end
  if c:match("^%u$") then return EM.upper end
  if c:match("^%l$") then return EM.lower end
  if c:match("^%d$") then return EM.digit end
  if c:match("^[%.,;:'\"!%?%(%)%-/&]$") then return EM.punct end
  return EM.other
end

-- number of lines a text takes in width_pt at size_pt (greedy word wrap)
function M.wrap_lines(text, width_pt, size_pt)
  size_pt = size_pt or 12
  local lines, cur, first = 1, 0, true
  local space = EM.space * size_pt
  for word in text:gmatch("%S+") do
    local w = 0
    for _, cp in utf8.codes(word) do w = w + cp_em(cp) * size_pt end
    if first then
      cur = w; first = false
    elseif cur + space + w <= width_pt then
      cur = cur + space + w
    else
      lines = lines + 1; cur = w
    end
  end
  return lines
end

-- the LBR 9004-2(c) caption: the party column (rows as in orb-*.typ caption()), a ")" per row line, and the
-- case numbers, title, subtitle and jury demand or hearing lines at the right
local function caption_xml(meta)
  local c = meta.caption
  local rows = { "In re:" }
  for _, d in ipairs(c.debtor or {}) do rows[#rows + 1] = M.plain(d) end
  rows[#rows + 1] = M.plain(c.debtor_role)
  rows[#rows + 1] = ""
  for k, p in ipairs(c.parties or {}) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, n in ipairs(p.names or {}) do rows[#rows + 1] = M.plain(n) end
    rows[#rows + 1] = M.plain(p.designation)
  end
  local left, parens, n = {}, {}, 0
  for _, r in ipairs(rows) do
    left[#left + 1] = M.PX(r == "" and {} or { pandoc.Str(r) }, "PleadingSingle")
    n = n + (r == "" and 1 or M.wrap_lines(r, M.CAP_LEFT_PT))
  end
  for _ = 1, n do parens[#parens + 1] = M.PX({ pandoc.Str(")") }, "PleadingSingle") end

  local right = {
    M.PX({ pandoc.Str("Case No. " .. M.plain(meta.case_number)) }, "PleadingSingle"),
    M.PX({ pandoc.Str("Adv. Proc. No. " .. M.plain(meta.adv_number)) }, "PleadingSingle"),
    M.pad(M.SINGLE),
    M.PX({ pandoc.Strong(M.minl(meta.brief_title)) }, "PleadingSingle"),
  }
  if meta.subtitle then
    right[#right + 1] = M.PX(M.minl(meta.subtitle), "PleadingSingle")
  end
  if meta.hearing then
    right[#right + 1] = M.pad(M.SINGLE)
    right[#right + 1] = M.PX({ pandoc.Str("DATE OF HEARING: " .. M.plain(meta.hearing.date)) }, "PleadingSingle")
    right[#right + 1] = M.PX({ pandoc.Str("TIME OF HEARING: " .. M.plain(meta.hearing.time)) }, "PleadingSingle")
  end
  if meta.jury_demand then
    right[#right + 1] = M.pad(M.SINGLE)
    right[#right + 1] = M.PX({ pandoc.Str("DEMAND FOR JURY TRIAL") }, "PleadingSingle")
  end

  local nob = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="10080" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblBorders>', nob, '</w:tblBorders>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="', M.CAP_LEFT, '"/><w:gridCol w:w="', M.CAP_PAREN, '"/><w:gridCol w:w="', M.CAP_RIGHT, '"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="', M.CAP_LEFT, '" w:type="dxa"/></w:tcPr>', table.concat(left), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="', M.CAP_PAREN, '" w:type="dxa"/></w:tcPr>', table.concat(parens), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="', M.CAP_RIGHT, '" w:type="dxa"/></w:tcPr>', table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

-- the cover: counsel (single), the court title (centered, bold), the caption; then the page break
function M.cover(meta)
  local out = {}
  for _, c in ipairs(meta.counsel or {}) do out[#out + 1] = M.PX(M.minl(c), "PleadingSingle") end
  out[#out + 1] = M.pad(M.GAP)
  out[#out + 1] = M.PX({ pandoc.Str("UNITED STATES BANKRUPTCY COURT") }, "PleadingCourt")
  out[#out + 1] = M.PX({ pandoc.Str("FOR THE DISTRICT OF OREGON") }, "PleadingCourt")
  out[#out + 1] = M.pad(M.GAP)
  out[#out + 1] = caption_xml(meta)
  out[#out + 1] = M.page_break()
  return table.concat(out)
end

-- the date (a line of its own) and the signature block at 3 in from the left margin, single spaced
function M.signature(meta, date)
  local out = {}
  if date then out[#out + 1] = M.PX(M.minl(date), "PleadingDate") end
  for _, l in ipairs(meta.signature or {}) do out[#out + 1] = M.PX(M.minl(l), "PleadingSignature") end
  return table.concat(out)
end

return M
