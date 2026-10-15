-- okwd complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/okwd-complaint.typ: the court title, the caption (parties with a ")" column, case number),
-- the title, the lead-in, the numbered allegations (Fed. R. Civ. P. 10(b)), lettered prayer items, and the
-- signature block kept with the last paragraph. Styles and page setup come from reference.docx
-- (build-reference.sh). Page numbers come from its footer.
-- Known differences (see README.md, "## Engines"): the caption and signature are tables (Word draws them with
-- its own table metrics); the numbers are typed text, not Word list numbering; the ")" column is one ")" per caption
-- line, as in the typst template, so a party name that wraps in Word will not get a second ")".

local BOLD = '<w:rPr><w:b/></w:rPr>'

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- one raw WordprocessingML paragraph: style, text, and options (keep = keep with next, bold)
local function p(style, text, opts)
  opts = opts or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>' .. (opts.keep and '<w:keepNext/>' or '')
  local body = ''
  if text ~= '' then
    body = '<w:r>' .. (opts.bold and BOLD or '') .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. body .. '</w:p>'
end
local GAP = p('Gap', '')

local function raw(xml) return pandoc.RawBlock('openxml', xml) end

-- a table cell: width in twips, its paragraphs, an optional left cell margin
local function cell(w, paras, mar_left)
  local mar = mar_left and ('<w:tcMar><w:left w:w="' .. mar_left .. '" w:type="dxa"/></w:tcMar>') or ''
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. mar .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

-- a borderless fixed-width table with one row of cells (the row may not split across pages)
local function row_table(widths, cells)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

local function text_of(v)
  if v == nil then return '' end
  return pandoc.utils.stringify(v)
end

-- caption: party names, "v." between parties, designations indented; one ")" per line (LCvR3.1)
local function caption(meta)
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p('Single', 'v.') end
    for _, name in ipairs(party.names) do left[#left + 1] = p('Single', text_of(name)) end
    left[#left + 1] = p('SingleIndent', text_of(party.designation))
  end
  local parens = {}
  for i = 1, #left do parens[i] = p('Centered', ')') end
  local case_no = text_of(meta.case_number)
  local right = {}
  right[#right + 1] = p('Single', case_no == '' and 'Case No. ____________' or case_no)
  if meta.jury_demand then
    right[#right + 1] = GAP
    right[#right + 1] = p('Single', 'JURY TRIAL DEMANDED', { bold = true })
  end
  return row_table({ 4896, 432, 288, 3744 }, {
    cell(4896, left), cell(432, parens), cell(288, { p('Single', '') }), cell(3744, right, 144),
  })
end

-- signature block (LCvR5.4; Fed. R. Civ. P. 11(a)): date and signer in a borderless table
local function signature(meta)
  local sig = meta.signature
  local left = { p('Single', meta.date and ('Dated: ' .. text_of(meta.date)) or '') }
  local right = { p('Single', 'Respectfully submitted,', { keep = true }), p('SingleKeep', '') }
  local firm = sig.firm or {}
  for _, line in ipairs(firm) do right[#right + 1] = p('SingleKeep', text_of(line)) end
  if #firm > 0 then right[#right + 1] = p('SingleKeep', '') end
  right[#right + 1] = p('SingleKeep', text_of(sig.sign))
  for i, line in ipairs(sig.lines) do
    right[#right + 1] = p(i < #sig.lines and 'SingleKeep' or 'Single', text_of(line))
  end
  return row_table({ 4608, 288, 4464 }, { cell(4608, left), cell(288, { p('Single', '') }), cell(4464, right) })
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- the cover: court title, caption, title (typst cover())
  add(raw(p('Centered', 'IN THE UNITED STATES DISTRICT COURT', { bold = true })))
  add(raw(p('Centered', 'FOR THE WESTERN DISTRICT OF OKLAHOMA', { bold = true })))
  add(raw(GAP))
  add(raw(caption(m)))
  add(raw(GAP))
  add(raw(p('CenteredBody', string.upper(text_of(m.brief_title)), { bold = true })))
  add(raw(GAP))

  if m.lead_in then add(raw(p('BodyText', text_of(m.lead_in)))) end

  -- the unnumbered sections named in the frontmatter (the prayer and the jury demand)
  local unnumbered = {}
  for _, u in ipairs(m.unnumbered or {}) do unnumbered[#unnumbered + 1] = text_of(u) end
  local numbering, counter = true, 0

  local blocks = doc.blocks
  for i, el in ipairs(blocks) do
    local last = i == #blocks
    if el.t == 'Header' then
      if el.level == 1 then
        local title = pandoc.utils.stringify(el.content)
        numbering = true
        for _, u in ipairs(unnumbered) do
          if title:find(u, 1, true) then numbering = false end
        end
      end
      add(el)
    elseif el.t == 'Para' then
      local content = el.content
      if numbering then
        counter = counter + 1
        local inl = pandoc.List({ pandoc.Str(tostring(counter) .. '.'), pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>') })
        inl:extend(content)
        content = inl
      end
      if last then
        add(pandoc.Div({ pandoc.Para(content) }, pandoc.Attr('', {}, { ['custom-style'] = 'BodyKeep' })))
      else
        add(pandoc.Para(content))
      end
    elseif el.t == 'OrderedList' or el.t == 'BulletList' then
      -- prayer items are lettered A., B., ... (typst: enum numbering "A.")
      for k, item in ipairs(el.content) do
        local label = (el.t == 'OrderedList') and (string.char(64 + k) .. '.') or '\u{2022}'
        local first = item[1]
        if first and (first.t == 'Para' or first.t == 'Plain') then
          local inl = pandoc.List({ pandoc.Str(label), pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>') })
          inl:extend(first.content)
          add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr('', {}, { ['custom-style'] = 'ListItem' })))
          for j = 2, #item do add(item[j]) end
        else
          for _, b in ipairs(item) do add(b) end
        end
      end
      add(raw(GAP))
    else
      add(el)
    end
  end

  -- signature block (typst: v(body-leading) then the signature)
  add(raw(GAP))
  add(raw(signature(m)))
  return pandoc.Pandoc(out)
end
