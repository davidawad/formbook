-- Pandoc Lua filter for the rib adversary complaint (docx engine). Mirrors typst/rib-adversary-complaint.typ:
-- court title, caption table, title, lead-in, numbered paragraphs (1., 2., ...), lettered lists (a), (b), ...,
-- block quotations, signature block. Named styles (RibSingle, RibBody, ...) come from docx/reference.docx
-- (built by docx/build-reference.sh). Case text comes only from the sample's frontmatter and body.

local COURT = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF RHODE ISLAND" }
local CAPTION_LEFT, GUTTER, TEXT_W = 4752, 360, 9360 -- twips: 3.3 in, 0.25 in, 6.5 in

local function xesc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function s(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a meta list (or a single value) as a Lua array of plain strings
local function strings(v)
  local t = {}
  if v == nil then return t end
  -- a list of values (each a list of inlines, or a meta value) or one value (a list of inlines)
  if v[1] ~= nil and v[1].t == nil then
    for _, x in ipairs(v) do t[#t + 1] = s(x) end
  else
    t[1] = s(v)
  end
  return t
end

local function run(text)
  return '<w:r><w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
end

-- one paragraph of raw WordprocessingML; ppr is the pPr children after pStyle, in schema order
local function para(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. (inner or '') .. '</w:p>'
end

local function raw(xml)
  return pandoc.RawBlock('openxml', xml)
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr('', {}, { ['custom-style'] = style }))
end

-- a paragraph whose first run is a label (number or "(a)") followed by a tab, then the content
local function labelled(label, inlines, style)
  local c = pandoc.Inlines {
    pandoc.RawInline('openxml', run(label) .. '<w:r><w:tab/></w:r>'),
  }
  c:extend(inlines)
  return styled(style, { pandoc.Para(c) })
end

local function is_text_block(b)
  return b.t == "Para" or b.t == "Plain"
end

-- caption: the bankruptcy case (In re) on the left above a rule, the case numbers on the right
local function caption_table(meta)
  local left = {}
  left[#left + 1] = para('RibSingle', run('IN RE:'))
  for _, name in ipairs(strings(meta.in_re)) do
    left[#left + 1] = para('RibSingle', run(name))
  end
  left[#left + 1] = para('RibRight', run(s(meta.debtor_designation)), '<w:spacing w:before="0" w:after="120"/>')
  local first = true
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = para('RibSingle', run('v.'))
    end
    for _, name in ipairs(strings(p.names)) do
      left[#left + 1] = para('RibSingle', run(name))
    end
    left[#left + 1] = para('RibSingle', run(s(p.designation)))
  end
  local right = {
    para('RibSingle', run('Chapter ' .. s(meta.chapter))),
    para('RibSingle', run('Bankruptcy Case No. ' .. s(meta.case_number))),
    para('RibGap6', ''),
    para('RibSingle', run('Adversary Proceeding No. ' .. s(meta.adversary_number))),
  }
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local lmar = '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  local rmar = '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAPTION_LEFT .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="'
    .. (TEXT_W - CAPTION_LEFT - GUTTER) .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_LEFT .. '" w:type="dxa"/>' .. rule .. lmar .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. GUTTER .. '" w:type="dxa"/></w:tcPr>' .. para('RibSingle', '') .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXT_W - CAPTION_LEFT - GUTTER) .. '" w:type="dxa"/>' .. rmar .. '</w:tcPr>' .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

-- signature block: the case line (LBR 1005-1(a)), then "Respectfully submitted", signer, firm and bar number
local function signature_xml(meta)
  local sig = meta.signature
  local out = {}
  out[#out + 1] = para('RibSignature', run('In re ' .. table.concat(strings(meta.in_re), ', ')
    .. ', Debtor; Chapter ' .. s(meta.chapter) .. '; Bankruptcy Case No. ' .. s(meta.case_number)
    .. '; Adversary Proceeding No. ' .. s(meta.adversary_number)), '<w:spacing w:before="0" w:after="204"/>')
  local dated = meta.date and para('RibSignature', run('Dated: ' .. s(meta.date))) or para('RibSignature', '')
  local right = {}
  right[#right + 1] = para('RibSignature', run('Respectfully submitted,'), '<w:spacing w:before="0" w:after="120"/>')
  right[#right + 1] = para('RibSignature', run(s(sig.client)))
  right[#right + 1] = para('RibSignature', run(s(sig.by)), '<w:spacing w:before="0" w:after="120"/>')
  right[#right + 1] = para('RibSignature', run('/s/ ' .. s(sig.signer)))
  right[#right + 1] = para('RibSignature', run(s(sig.signer)))
  for _, line in ipairs(strings(sig.firm)) do right[#right + 1] = para('RibSignature', run(line)) end
  right[#right + 1] = para('RibSignature', run('RI Bar No. ' .. s(sig.bar_id)))
  for _, line in ipairs(strings(sig.lines)) do right[#right + 1] = para('RibSignature', run(line)) end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4032"/><w:gridCol w:w="288"/><w:gridCol w:w="5040"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4032" w:type="dxa"/></w:tcPr>' .. dated .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. para('RibSingle', '') .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5040" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
  return table.concat(out)
end

local function cover(meta, out)
  for _, line in ipairs(COURT) do out:insert(raw(para('RibCenterBold', run(line)))) end
  out:insert(raw(para('RibGap16', '')))
  out:insert(raw(caption_table(meta)))
  out:insert(raw(para('RibGap16', '')))
  out:insert(raw(para('RibTitle', run(s(meta.title):upper()))))
  out:insert(raw(para('RibGap16', '')))
end

function Pandoc(doc)
  local meta = doc.meta
  local out = pandoc.List()
  cover(meta, out)

  -- lead-in paragraphs: unnumbered, first line indented
  if meta.lead_in then
    -- a single paragraph is one inline list; several are a list of inline lists
    local leads = meta.lead_in[1] and meta.lead_in[1].t and { meta.lead_in } or meta.lead_in
    for _, p in ipairs(leads) do
      out:insert(styled("RibBody", { pandoc.Para(p) }))
    end
  end

  -- body: paragraphs numbered 1, 2, ... (WHEREFORE paragraphs excepted); "1." lists lettered (a), (b), ...
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      if pandoc.utils.stringify(b):match("^WHEREFORE") then
        out:insert(styled('RibBody', { b }))
      else
        n = n + 1
        out:insert(labelled(n .. ".", b.content, 'RibNumbered'))
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local letter = string.char(string.byte('a') + i - 1)
        local label = '(' .. letter .. ')'
        for j, blk in ipairs(item) do
          if j == 1 and is_text_block(blk) then
            out:insert(labelled(label, blk.content, 'RibItem'))
          elseif is_text_block(blk) then
            out:insert(styled('RibBody', { pandoc.Para(blk.content) }))
          else
            out:insert(blk)
          end
        end
      end
      out:insert(raw(para("RibGap16", "")))
    elseif b.t == "BlockQuote" then
      local qs = {}
      for _, blk in ipairs(b.content) do
        if is_text_block(blk) then qs[#qs + 1] = pandoc.Para(blk.content) else qs[#qs + 1] = blk end
      end
      out:insert(styled('RibQuote', qs))
    else
      out:insert(b) -- headings and anything else keep their pandoc style (Heading1-3, ...)
    end
  end

  out:insert(raw(signature_xml(meta)))
  meta.title = nil
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
