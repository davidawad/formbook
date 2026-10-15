-- nynd complaint (N.D.N.Y.), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/nynd-complaint.typ: the caption (L.R. 10.1(c)(1)) and the signature block (L.R. 10.1(c)(2))
-- are built here from the frontmatter as OpenXML tables and paragraphs in the reference's styles. The body
-- keeps its markdown structure; numbered allegations get their number as text and a tab (Fed. R. Civ. P.
-- 10(b)), lettered prayer items "a." "b." ..., a chunk "{unnumbered} ..." is an indented unnumbered
-- paragraph, and a chunk wrapped in parentheses is a centered unnumbered subtitle.
-- Page numbers come from the footer in reference.docx. No line numbers or margin rules (not required here).

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

-- one row; each cell is { width, borders (tcBorders inner xml or nil), paragraphs (xml) }
local function row(cells)
  local out = {}
  for _, c in ipairs(cells) do
    local b = c[2] and ("<w:tcBorders>" .. c[2] .. "</w:tcBorders>") or ""
    out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. b .. "</w:tcPr>" .. c[3] .. "</w:tc>"
  end
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(out) .. "</w:tr>"
end

local RULE_BOTTOM = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

-- L.R. 10.1(c)(1): court title, party block with rule, case number and judges' initials, title of the paper
local function caption(m)
  local left = {}
  for k, p in ipairs(m.caption.parties) do
    for _, nm in ipairs(p.names) do
      left[#left + 1] = para("Single", run(plain(nm)))
    end
    left[#left + 1] = para("Single", run(plain(p.designation)), '<w:ind w:left="2880"/>')
    if k < #m.caption.parties then
      left[#left + 1] = para("Single", run(plain(m.caption.between)),
        '<w:spacing w:before="120" w:after="120"/><w:ind w:left="720"/>')
    end
  end
  -- the rule sits 10 pt under the party block (typst: inset bottom 10pt)
  left[#left] = para("Single", run(plain(m.caption.parties[#m.caption.parties].designation)),
    '<w:spacing w:after="200"/><w:ind w:left="2880"/>')
  local right = para("Single", run(plain(m.case_number) .. " (" .. plain(m.judges) .. ")"),
    '<w:spacing w:after="960"/><w:ind w:left="144"/>')
  right = right .. para("Single", run(string.upper(plain(m.brief_title)), "<w:b/><w:bCs/>"), '<w:ind w:left="144"/>')
  local head = para("Single", run("UNITED STATES DISTRICT COURT"))
    .. para("Single", run("NORTHERN DISTRICT OF NEW YORK"), '<w:spacing w:after="240"/>')
  return raw_block(head .. table_xml({ 5184, 432, 3744 }, {
    row({
      { 5184, RULE_BOTTOM, table.concat(left) },
      { 432, nil, para("Single", "") },
      { 3744, nil, right },
    }),
  }))
end

function raw_block(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- L.R. 10.1(c)(2): dated at the left; firm, signature line, signing attorneys, address, telephone and role at right
local function signature(sig)
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
  r[#r + 1] = para("Single", run(plain(sig.role), "<w:i/><w:iCs/>"), '<w:spacing w:before="120"/>')
  return raw_block(table_xml({ 4464, 288, 4608 }, {
    row({ { 4464, nil, left }, { 288, nil, para("Single", "") }, { 4608, nil, table.concat(r) } }),
  }))
end

-- "{unnumbered} text": drop the marker and the space after it
local function drop_marker(inlines)
  local i = 1
  if inlines[1] and inlines[1].t == "Str" and inlines[1].text == "{unnumbered}" then i = 2 end
  while inlines[i] and inlines[i].t == "Space" do i = i + 1 end
  local out = pandoc.Inlines({})
  for j = i, #inlines do out:insert(inlines[j]) end
  return out
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

function Pandoc(doc)
  local m = doc.meta
  local out = { caption(m) }

  if m.lead_in and plain(m.lead_in) ~= "" then
    out[#out + 1] = raw_block(para("BodyText", run(plain(m.lead_in)), '<w:spacing w:before="960"/>'))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" then
      local s = plain(b)
      if s:match("^{unnumbered}") then
        out[#out + 1] = styled("BodyText", { pandoc.Para(drop_marker(b.content)) })
      elseif s:match("^%(") and s:match("%)$") then
        out[#out + 1] = styled("CenteredDouble", { pandoc.Para(b.content) })
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inl:extend(b.content)
        out[#out + 1] = styled("Numbered", { pandoc.Para(inl) })
      end
    elseif b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        local first = item[1]
        local letter = string.char(96 + k) .. "."
        local inl = pandoc.Inlines({ pandoc.Str(letter), TAB })
        if first and (first.t == "Para" or first.t == "Plain") then
          inl:extend(first.content)
        end
        out[#out + 1] = styled("Lettered", { pandoc.Para(inl) })
      end
    elseif b.t == "Header" and b.level == 1 then
      out[#out + 1] = b
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = signature(m.signature)
  doc.blocks = out
  return doc
end
