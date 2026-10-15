-- E.D. La. adversary complaint (typst/laeb-adversary-complaint.typ) as Word-native content.
-- Builds, from the markdown frontmatter only: the court title, the caption (a table whose party column has a
-- rule at its right edge), the title, the lead-in and the signature block. In the body: every top-level
-- paragraph is a numbered allegation (number, tab, text; Fed. R. Civ. P. 10(b)); an ordered list is lettered
-- (a), (b), ...; headings, block quotations and footnotes are pandoc's own (styled in reference.docx).
-- Content-agnostic: no case word appears in this file.

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- Inlines to WordprocessingML runs. Only bold and italic are carried over (the caption and signature use no
-- other run formatting); everything else is set by the paragraph style.
local function runs(inl, flags)
  local out = {}
  local function add(text, f)
    local rpr = ''
    if f.b or f.i then
      rpr = '<w:rPr>' .. (f.b and '<w:b/>' or '') .. (f.i and '<w:i/>' or '') .. '</w:rPr>'
    end
    out[#out + 1] = '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  local function walk(list, f)
    for _, el in ipairs(list) do
      local tag = el.tag
      if tag == 'Str' or tag == 'Code' then
        add(el.text, f)
      elseif tag == 'Space' or tag == 'SoftBreak' or tag == 'LineBreak' then
        add(' ', f)
      elseif tag == 'Emph' then
        walk(el.content, { b = f.b, i = true })
      elseif tag == 'Strong' then
        walk(el.content, { b = true, i = f.i })
      elseif tag == 'Quoted' then
        local q = el.quotetype == 'SingleQuote' and { '\u{2018}', '\u{2019}' } or { '\u{201C}', '\u{201D}' }
        add(q[1], f)
        walk(el.content, f)
        add(q[2], f)
      elseif tag == 'Note' then
        -- footnotes are not part of the caption or signature
      elseif el.content then
        walk(el.content, f)
      end
    end
  end
  walk(inl, flags or {})
  return table.concat(out)
end

-- A frontmatter value (inline markdown, a string, or a list) as Inlines.
local function inlines_of(v)
  if v == nil then return pandoc.Inlines({}) end
  local ty = pandoc.utils.type(v)
  if ty == 'Inlines' then return v end
  if ty == 'Blocks' then return pandoc.utils.blocks_to_inlines(v) end
  if ty == 'string' then return pandoc.utils.blocks_to_inlines(pandoc.read(v, 'markdown').blocks) end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

-- Inlines a then b, as one Inlines value.
local function cat(a, b)
  local r = pandoc.Inlines({})
  for _, x in ipairs(a) do r:insert(x) end
  for _, x in ipairs(b) do r:insert(x) end
  return r
end

local function list_of(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == 'List' then return v end
  return { v }
end

local function text(s) return pandoc.Inlines({ pandoc.Str(s) }) end

-- A raw WordprocessingML paragraph: paragraph style, optional keep-with-next, optional spacing before/after.
local function para(style, inl, opt)
  opt = opt or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if opt.keepNext then ppr = ppr .. '<w:keepNext/>' end
  if opt.before or opt.after or opt.line then
    ppr = ppr .. '<w:spacing' .. (opt.before and (' w:before="' .. opt.before .. '"') or '')
      .. (opt.after and (' w:after="' .. opt.after .. '"') or '')
      .. (opt.line and (' w:line="' .. opt.line .. '" w:lineRule="exact"') or '') .. '/>'
  end
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. runs(inl, opt.flags) .. '</w:p>'
end

-- Caption: party column (left, rule at its right edge) and case information (right). Party order and
-- designations as in the frontmatter; "v." before each party but the first, unless the party gives sep "".
local function caption_table(caption, meta_case_info)
  local left = {}
  for k, p in ipairs(list_of(caption.parties)) do
    local sep = p.sep == nil and text('v.') or inlines_of(p.sep)
    if k > 1 then
      left[#left + 1] = para('CaptionText', pandoc.Inlines({}), { line = 120 })
      if #sep > 0 then left[#left + 1] = para('CaptionText', sep) end
    end
    for _, n in ipairs(list_of(p.names)) do
      left[#left + 1] = para('CaptionText', inlines_of(n))
    end
    left[#left + 1] = para('CaptionDesignation', inlines_of(p.designation))
  end
  local right = {}
  for _, c in ipairs(list_of(meta_case_info)) do
    right[#right + 1] = para('CaptionCase', inlines_of(c))
  end
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>',
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>',
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>',
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid>',
    '<w:tr>',
    '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/><w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
    '<w:tcMar><w:bottom w:w="120" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>',
    table.concat(left), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/></w:tcPr>', table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

-- Signature block (typst signature-block): "Dated", "Respectfully submitted," the BY line, then each counsel
-- block single spaced on the right half, blocks separated by "And". Kept together.
local function signature_block(meta)
  local out = {}
  if meta.date ~= nil then
    out[#out + 1] = para('CaptionText', cat(text('Dated: '), inlines_of(meta.date)), { keepNext = true, before = 200 })
  end
  out[#out + 1] = para('Signature', text('Respectfully submitted,'), { keepNext = true, before = 200 })
  out[#out + 1] = para('Signature', cat(text('BY: '), inlines_of(meta.signature.by)), { keepNext = true, before = 200 })
  local blocks = list_of(meta.signature.blocks)
  for i, b in ipairs(blocks) do
    if i > 1 then
      out[#out + 1] = para('Signature', text('And'), { keepNext = true, before = 40 })
    end
    local lines = list_of(b)
    for j, line in ipairs(lines) do
      local last = (j == #lines) and (i == #blocks)
      out[#out + 1] = para('Signature', inlines_of(line), {
        keepNext = not last,
        before = (j == 1) and 40 or nil,
      })
    end
  end
  return out
end

local allegation = 0

-- A top-level paragraph: the next allegation number, a tab, the text (Allegation style: number at the 0.5 in
-- indent, text from 0.8 in; wrapped lines return to the margin).
local function numbered(p)
  allegation = allegation + 1
  local inl = pandoc.Inlines({ pandoc.Str(allegation .. '.'), TAB })
  for _, x in ipairs(p.content) do inl:insert(x) end
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr('', {}, { ['custom-style'] = 'Allegation' }))
end

-- An ordered list: each item is a "Pleading List" paragraph whose marker is (a), (b), ... (typst enum "(a)").
local function lettered_list(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local marker = '(' .. string.char(96 + i) .. ')'
    local first = true
    for _, b in ipairs(item) do
      if first and (b.tag == 'Para' or b.tag == 'Plain') then
        local inl = pandoc.Inlines({ pandoc.Str(marker), TAB })
        for _, x in ipairs(b.content) do inl:insert(x) end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr('', {}, { ['custom-style'] = 'Pleading List' }))
        first = false
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  local function raw(x) blocks[#blocks + 1] = pandoc.RawBlock('openxml', x) end

  -- court title, caption, title, lead-in (typst: court-lines, caption(), title, lead_in)
  raw(para('CourtTitle', text('UNITED STATES BANKRUPTCY COURT')))
  raw(para('CourtTitle', text('EASTERN DISTRICT OF LOUISIANA'), { after = 200 }))
  raw(caption_table(meta.caption, meta.case_info))
  raw(para('PleadingTitle', inlines_of(meta.title)))
  if meta.lead_in ~= nil then
    raw(para('BodyText', inlines_of(meta.lead_in)))
  end

  -- body
  for _, b in ipairs(doc.blocks) do
    if b.tag == 'Para' then
      blocks[#blocks + 1] = numbered(b)
    elseif b.tag == 'OrderedList' then
      for _, x in ipairs(lettered_list(b)) do blocks[#blocks + 1] = x end
    else
      blocks[#blocks + 1] = b
    end
  end

  -- signature block
  for _, l in ipairs(signature_block(meta)) do raw(l) end

  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
