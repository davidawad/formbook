-- Pandoc Lua filter for the TTAB inter partes paper (docx engine).
-- Builds the caption, title, signature block and certificate of service from the YAML frontmatter
-- (same contract as the typst engine, ../README.extra.md), numbers the paragraphs, and sets drafting
-- notes ("**[...]**" paragraphs) in their own style. Requirement IDs refer to ../rules.md.

local stringify = pandoc.utils.stringify

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, props)
  return '<w:r>' .. (props and ('<w:rPr>' .. props .. '</w:rPr>') or '') ..
         '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function para(style, text, extra_ppr, props)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '" />' .. (extra_ppr or '') .. '</w:pPr>' ..
         run(text, props) .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock('openxml', xml) end

local function need(meta, key)
  if meta[key] == nil then error("ttab.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function lines_of(list)
  local out = {}
  if list then for _, l in ipairs(list) do out[#out + 1] = stringify(l) end end
  return out
end

local BORDER_SZ = '6'

local function caption(meta)
  local kind = meta.kind and stringify(meta.kind) or 'opposition'
  local label = (kind == 'cancellation') and 'Cancellation No.' or 'Opposition No.'
  local pl, df = need(meta, 'plaintiff'), need(meta, 'defendant')
  local left = {}
  for _, l in ipairs(lines_of(need(meta, 'matter'))) do left[#left + 1] = para('CaptionLine', l) end
  left[#left + 1] = para('CaptionLine', '')
  left[#left + 1] = para('CaptionLine', stringify(pl.name))
  left[#left + 1] = para('CaptionLine', stringify(pl.role), '<w:ind w:left="720" />')
  left[#left + 1] = para('CaptionLine', 'v.', '<w:ind w:left="360" />', '<w:i />')
  left[#left + 1] = para('CaptionLine', stringify(df.name))
  left[#left + 1] = para('CaptionLine', stringify(df.role), '<w:ind w:left="720" />')
  local head = para('CaptionCenter', 'IN THE UNITED STATES PATENT AND TRADEMARK OFFICE') ..
               para('CaptionCenter', 'BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD') ..
               para('CaptionLine', '')
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" /><w:tblLayout w:type="fixed" />' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="5990" /><w:gridCol w:w="3370" /></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="5990" w:type="dxa" /><w:tcBorders>' ..
    '<w:bottom w:val="single" w:sz="' .. BORDER_SZ .. '" w:space="0" w:color="000000" />' ..
    '<w:right w:val="single" w:sz="' .. BORDER_SZ .. '" w:space="0" w:color="000000" /></w:tcBorders></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="3370" w:type="dxa" /><w:vAlign w:val="center" /></w:tcPr>' ..
    para('CaptionLine', label .. ' ' .. stringify(need(meta, 'proceeding_number')), '<w:ind w:left="240" />') ..
    '</w:tc></w:tr></w:tbl>'
  local title = para('PaperTitle', stringify(need(meta, 'title')))
  return raw(head .. tbl .. title)
end

local function signature(meta)
  local sg = need(meta, 'signature')
  local out = {}
  out[#out + 1] = para('Normal', 'Dated: ' .. stringify(sg.date), '<w:keepNext /><w:spacing w:before="480" w:after="120" />')
  out[#out + 1] = para('SignatureBlock', 'Respectfully submitted,')
  out[#out + 1] = para('SignatureBlock', stringify(sg.firm), '', '<w:b />')
  out[#out + 1] = para('SignatureBlock', stringify(sg.esign), '<w:spacing w:before="360" w:after="0" />')
  out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="SignatureBlock" /><w:pBdr><w:top w:val="single" w:sz="4" w:space="1" w:color="000000" /></w:pBdr><w:spacing w:after="0" /></w:pPr></w:p>'
  out[#out + 1] = para('SignatureBlock', stringify(sg.name))
  out[#out + 1] = para('SignatureBlock', stringify(sg.title))
  for _, l in ipairs(lines_of(sg.lines)) do out[#out + 1] = para('SignatureBlock', l) end
  return raw(table.concat(out))
end

local function certificate(meta)
  local sv = meta.service
  if not sv then return nil end
  local method = sv.method and stringify(sv.method) or 'email'
  local by = (method == 'email') and 'by email' or method
  local out = {}
  out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="PaperTitle" /><w:pageBreakBefore /></w:pPr>' ..
                  run('CERTIFICATE OF SERVICE') .. '</w:p>'
  out[#out + 1] = para('Normal', 'I hereby certify that on ' .. stringify(sv.date) ..
    ', a true and complete copy of the foregoing ' .. stringify(sv.paper) .. ' was served ' .. by .. ' on:',
    '<w:ind w:firstLine="720" /><w:spacing w:after="200" />')
  for _, r in ipairs(sv.recipients) do
    local ind = '<w:keepNext /><w:ind w:left="720" /><w:spacing w:after="0" />'
    out[#out + 1] = para('Normal', stringify(r.name) .. ', ' .. stringify(r.role), ind)
    for _, l in ipairs(lines_of(r.lines)) do out[#out + 1] = para('Normal', l, ind) end
    out[#out + 1] = para('Normal', stringify(r.email), '<w:ind w:left="720" /><w:spacing w:after="240" />')
  end
  out[#out + 1] = para('SignatureBlock', stringify(sv.esign), '<w:spacing w:before="360" w:after="0" />')
  out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="SignatureBlock" /><w:pBdr><w:top w:val="single" w:sz="4" w:space="1" w:color="000000" /></w:pBdr><w:spacing w:after="0" /></w:pPr></w:p>'
  out[#out + 1] = para('SignatureBlock', stringify(sv.name))
  out[#out + 1] = para('SignatureBlock', stringify(sv.title))
  return raw(table.concat(out))
end

-- A paragraph that is a single Strong whose text starts with "[" is a drafting note (TTAB-TOOL-002).
local function is_marker(block)
  if block.t ~= 'Para' or #block.content ~= 1 or block.content[1].t ~= 'Strong' then return false end
  return stringify(block.content[1]):sub(1, 1) == '['
end

local function number_items(list)
  local out = {}
  local n = list.start or 1
  for _, item in ipairs(list.content) do
    local first = item[1]
    if first and (first.t == 'Plain' or first.t == 'Para') then
      local inl = pandoc.List({ pandoc.Str(n .. '.'), pandoc.Str('\u{00A0}\u{00A0}') })
      inl:extend(first.content)
      item[1] = pandoc.Para(inl)
    end
    for _, b in ipairs(item) do out[#out + 1] = b end
    n = n + 1
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = pandoc.List()
  blocks:insert(caption(meta))
  meta.title = nil
  for _, b in ipairs(doc.blocks) do
    if b.t == 'OrderedList' then
      blocks:extend(number_items(b))
    elseif is_marker(b) then
      blocks:insert(pandoc.Div({ pandoc.Para(b.content[1].content) }, pandoc.Attr('', {}, { ['custom-style'] = 'Drafting Note' })))
    else
      blocks:insert(b)
    end
  end
  -- keep the last paragraph with the signature block so the block never stands alone on a page
  local last = blocks[#blocks]
  if last and last.t == 'Para' then
    blocks[#blocks] = pandoc.Div({ last }, pandoc.Attr('', {}, { ['custom-style'] = 'Body Text Keep' }))
  end
  blocks:insert(signature(meta))
  local cert = certificate(meta)
  if cert then blocks:insert(cert) end
  return pandoc.Pandoc(blocks, meta)
end
