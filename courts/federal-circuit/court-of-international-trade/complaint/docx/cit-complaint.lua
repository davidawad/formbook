-- cit-complaint.lua: pandoc filter for the CIT complaint, docx engine (see ../README.md, "Engines").
-- Mirrors typst/cit-complaint.typ: the cover (court, caption with a ")" column, title), numbered
-- allegations (Rule 10(b)) with a tab after the number, lettered lists (a), (b), ..., the signature block
-- (Rule 11(a)). Paragraph formats live in reference.docx (make-reference.sh), not here.
-- Raw WordprocessingML is used only for the cover, the caption and the signature block, which are
-- tables and lines that pandoc cannot style per cell.

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')
local PAGE_BREAK = pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

-- Text width 6 1/2 in = 9360 twips. Caption columns: party 3.4 in, ")" 0.3 in, court number the rest.
local CAP_LEFT, CAP_PAREN, CAP_RIGHT = 4896, 432, 4032
local DESIG_INDENT = 1728 -- 1.2 in, "Plaintiff," / "Defendants."

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function text_of(x)
  return pandoc.utils.stringify(x)
end

-- One paragraph of raw WordprocessingML. ppr and runs are XML strings.
local function xpara(runs, ppr)
  return '<w:p>' .. (ppr and ('<w:pPr>' .. ppr .. '</w:pPr>') or '') .. (runs or '') .. '</w:p>'
end

local function xrun(s, rpr)
  return '<w:r>' .. (rpr and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
    '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'
local DOUBLE = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
local CENTER = '<w:jc w:val="center"/>'
local BOLD = '<w:b/>'

-- An empty line of the body's double pitch (typst v(pitch)).
local function spacer()
  return pandoc.RawBlock('openxml', xpara('', DOUBLE))
end

local function cell(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. paras .. '</w:tc>'
end

-- A table with no borders and fixed column widths.
local function xtable(widths, rows)
  local total = 0
  local grid = {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return pandoc.RawBlock('openxml',
    '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>')
end

-- The caption (Rule 10(a)): every party line with a ")" on each row, the designation indented, the
-- court number at the right of the first row.
local function caption(meta)
  local rows = {}
  local lines = {}
  for i, side in ipairs(meta.caption) do
    for _, n in ipairs(side.names) do
      lines[#lines + 1] = { text = text_of(n) }
    end
    lines[#lines + 1] = { text = text_of(side.designation), indent = DESIG_INDENT }
    if i < #meta.caption then
      lines[#lines + 1] = { text = 'v.', center = true }
    end
  end
  for k, l in ipairs(lines) do
    local ppr = SINGLE
    if l.center then ppr = ppr .. CENTER
    elseif l.indent then ppr = ppr .. '<w:ind w:left="' .. l.indent .. '"/>' end
    local right
    if k == 1 then
      local court = xpara(xrun('Court No. ' .. text_of(meta.court_no)), SINGLE .. '<w:ind w:left="288"/>')
      if meta.before then
        court = court .. xpara(xrun('Before: ' .. text_of(meta.before)), SINGLE .. '<w:ind w:left="288"/>')
      end
      right = cell(CAP_RIGHT, court, '<w:vMerge w:val="restart"/>')
    else
      right = cell(CAP_RIGHT, xpara('', SINGLE), '<w:vMerge/>')
    end
    rows[#rows + 1] = '<w:tr>' ..
      cell(CAP_LEFT, xpara(xrun(l.text), ppr)) ..
      cell(CAP_PAREN, xpara(xrun(')'), SINGLE)) ..
      right .. '</w:tr>'
  end
  return xtable({ CAP_LEFT, CAP_PAREN, CAP_RIGHT }, rows)
end

local function cover(meta, title)
  local out = {}
  for _, l in ipairs(meta.court) do
    out[#out + 1] = pandoc.RawBlock('openxml', xpara(xrun(text_of(l):upper(), BOLD), SINGLE .. CENTER))
  end
  out[#out + 1] = spacer()
  out[#out + 1] = caption(meta)
  out[#out + 1] = spacer()
  out[#out + 1] = pandoc.RawBlock('openxml', xpara(xrun(title:upper(), BOLD), SINGLE .. CENTER))
  out[#out + 1] = PAGE_BREAK
  return out
end

-- Signature block (Rule 11(a)): "Dated" at left, the counsel block at right; kept on one page.
local function signature(meta)
  local sig = meta.signature
  local right = {}
  right[#right + 1] = xpara(xrun('Respectfully submitted,'), SINGLE)
  right[#right + 1] = xpara('', '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>')
  right[#right + 1] = xpara(xrun('/s/ ' .. text_of(sig.signer)), SINGLE)
  for _, l in ipairs(sig.lines) do
    right[#right + 1] = xpara(xrun(text_of(l)), SINGLE)
  end
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(3744, xpara(xrun('Dated: ' .. text_of(meta.date)), SINGLE)) ..
    cell(5616, table.concat(right)) .. '</w:tr>'
  return { spacer(), xtable({ 3744, 5616 }, { row }) }
end

-- Lettered list: (a), (b), ... ; each item is one paragraph in the CIT Item style.
local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local letter = string.char(string.byte('a') + i - 1)
    local inl = {}
    inl[#inl + 1] = pandoc.Str('(' .. letter .. ')')
    inl[#inl + 1] = TAB
    if item[1] and (item[1].t == 'Plain' or item[1].t == 'Para') then
      for _, x in ipairs(item[1].content) do inl[#inl + 1] = x end
    end
    local blocks = { pandoc.Para(inl) }
    for j = 2, #item do blocks[#blocks + 1] = item[j] end
    out[#out + 1] = pandoc.Div(blocks, { ['custom-style'] = 'CIT Item' })
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local unnumbered = {}
  for _, h in ipairs(meta.unnumbered or {}) do unnumbered[text_of(h)] = true end

  -- pandoc writes the date and title metadata as paragraphs at the top; the cover carries them instead
  local out = cover(meta, text_of(meta.brief_title))
  if meta.lead_in then
    out[#out + 1] = pandoc.Para(pandoc.read(text_of(meta.lead_in), 'markdown+smart').blocks[1].content)
  end

  local n = 0
  local in_unnumbered = false
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' then
      in_unnumbered = unnumbered[text_of(b.content)] == true
      out[#out + 1] = b
    elseif b.t == 'Para' and not in_unnumbered then
      n = n + 1
      local inl = { pandoc.Str(n .. '.'), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Para(inl)
    elseif b.t == 'OrderedList' or b.t == 'BulletList' then
      for _, d in ipairs(lettered(b)) do out[#out + 1] = d end
    else
      out[#out + 1] = b
    end
  end

  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  local meta_out = doc.meta
  meta_out.date = nil
  return pandoc.Pandoc(out, meta_out)
end
