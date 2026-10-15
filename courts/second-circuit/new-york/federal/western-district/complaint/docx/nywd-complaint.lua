-- nywd complaint (W.D.N.Y.), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/nywd-complaint.typ: the court title and the caption (parties left with a right and bottom rule,
-- title and "Civil Action No." right) and the signature block are built here as OpenXML tables and paragraphs in
-- the reference's styles. The body keeps its markdown structure: each body paragraph is numbered (the number is
-- text and a tab, Fed. R. Civ. P. 10(b)); a list is lettered "(a)" "(b)" ...; a paragraph starting with "::" is
-- an unnumbered indented paragraph; a block quotation is single-spaced and indented.
-- Page numbers come from the footer in reference.docx. No line numbers (not required by the court).

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

-- a paragraph in a named style; ppr holds the direct formatting that differs from the style (schema order)
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

-- one row; each cell is { width, tcpr (inner xml of tcPr after tcW, or nil), paragraphs (xml) }
local function row(cells)
  local out = {}
  for _, c in ipairs(cells) do
    out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[2] or "") .. "</w:tcPr>" .. c[3] .. "</w:tc>"
  end
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(out) .. "</w:tr>"
end

-- typst caption: the parties box has a right and a bottom rule, 0.1 in inside the right edge, 8 pt above the rule
local CAPTION_LEFT_TCPR = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  .. '<w:tcMar><w:right w:w="144" w:type="dxa"/></w:tcMar>'

-- court title, then the caption box (L.R. 10(a); Fed. R. Civ. P. 10(a))
local function caption(m)
  local head = para("Centered", run("UNITED STATES DISTRICT COURT", "<w:b/><w:bCs/>"))
    .. para("Centered", run("WESTERN DISTRICT OF NEW YORK", "<w:b/><w:bCs/>"))
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
  -- 8 pt between the last line of the parties and the rule
  left[#left] = para("Single", run(plain(m.caption.parties[#m.caption.parties].designation)),
    '<w:spacing w:after="160"/><w:ind w:left="3168"/>')
  local right = para("Single", run(string.upper(plain(m.title)), "<w:b/><w:bCs/>"))
    .. para("Single", run("Civil Action No. __________________"), '<w:spacing w:before="324"/>')
  if m.jury_demand then
    right = right .. para("Single", run("JURY TRIAL DEMANDED", "<w:b/><w:bCs/>"), '<w:spacing w:before="324"/>')
  end
  return raw_block(head .. para("Single", "", '<w:spacing w:after="0"/>') .. table_xml({ 4896, 432, 4032 }, {
    row({
      { 4896, CAPTION_LEFT_TCPR, table.concat(left) },
      { 432, nil, para("Single", "") },
      { 4032, nil, right },
    }),
  }))
end

-- Fed. R. Civ. P. 11(a): dated at the left; firm, signer and address at the right (typst: grid 1fr | 3.2in)
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

-- "::" prefix: drop the marker and the space after it
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
  local out = { caption(m) }

  if m.lead_in and plain(m.lead_in) ~= "" then
    out[#out + 1] = raw_block(para("Unnumbered", run(plain(m.lead_in)), '<w:spacing w:before="324"/>'))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" then
      local s = plain(b)
      if s:match("^::") then
        out[#out + 1] = styled("Unnumbered", { pandoc.Para(drop_marker(b.content)) })
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inl:extend(b.content)
        out[#out + 1] = styled("Numbered", { pandoc.Para(inl) })
      end
    elseif b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        local first = item[1]
        local inl = pandoc.Inlines({ pandoc.Str("(" .. string.char(96 + k) .. ")"), TAB })
        if first and (first.t == "Para" or first.t == "Plain") then
          inl:extend(first.content)
        end
        out[#out + 1] = styled("Lettered", { pandoc.Para(inl) })
      end
    elseif b.t == "BlockQuote" then
      local ps = {}
      for _, q in ipairs(b.content) do
        if q.t == "Para" or q.t == "Plain" then ps[#ps + 1] = pandoc.Para(q.content) end
      end
      out[#out + 1] = styled("BlockText", ps)
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = signature(m)
  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
