-- D. Me. motion to dismiss with incorporated memorandum of law, DOCX engine (docs/DOCX.md): the markdown
-- contract (typst/med-motion-brief.typ) -> Word. The court name, caption, title, signature block and the
-- optional certificate of service are built here as Word-native paragraphs and tables (borders on the
-- caption's party cell only) in the styles of reference.docx. The body keeps its markdown structure:
-- paragraphs, headings, block quotes and footnotes. Every case word comes from the sample's frontmatter.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local BOLD = '<w:rPr><w:b/><w:bCs/></w:rPr>'
local BOLDCAPS = '<w:rPr><w:b/><w:bCs/><w:caps/></w:rPr>'

local function run(text, rpr)
  return '<w:r>' .. (rpr or '') .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function para(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. inner .. '</w:p>'
end

local function raw(s)
  return pandoc.RawBlock('openxml', s)
end

local NOBORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- The caption: party block at left, closed by a rule at its right and bottom; "Civil Action No." at right.
local function caption_table(meta)
  local left = {}
  local parties = (meta.caption and meta.caption.parties) or {}
  for k, p in ipairs(parties) do
    if k > 1 then left[#left + 1] = para('CaptionLine', run('v.')) end
    for _, n in ipairs(p.names or {}) do
      left[#left + 1] = para('CaptionLine', run(text_of(n)))
    end
    left[#left + 1] = para('CaptionDesignation', run(text_of(p.designation)))
  end

  local right = {}
  local case_no = text_of(meta.case_number)
  if case_no == '' then
    right[#right + 1] = para('Single', run('Civil Action No.'))
    right[#right + 1] = para('Single', '', '<w:pBdr><w:bottom w:val="single" w:sz="5" w:space="1" w:color="000000"/></w:pBdr><w:ind w:left="0" w:right="1584" w:firstLine="0"/>')
  else
    right[#right + 1] = para('Single', run('Civil Action No. ' .. case_no))
  end

  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NOBORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="240" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/><w:tcMar><w:left w:w="576" w:type="dxa"/></w:tcMar>'
    .. '<w:vAlign w:val="center"/></w:tcPr>' .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

-- Signature block: the date at left; the /s/ line and the lines of the block at right. Set 19 pt below the text.
local function signature_table(meta)
  local sig = meta.signature or {}
  local right = { para('Signature', run('/s/ ' .. text_of(sig.signer)), '<w:spacing w:before="383"/>') }
  for _, l in ipairs(sig.lines or {}) do
    right[#right + 1] = para('Signature', run(text_of(l)))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NOBORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4032"/><w:gridCol w:w="5328"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4032" w:type="dxa"/></w:tcPr>'
    .. para('Signature', run('Dated: ' .. text_of(meta.date)), '<w:spacing w:before="383"/>') .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5328" w:type="dxa"/><w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

local function is_tilde(b)
  return b.t == 'Para' and b.content[1] ~= nil and b.content[1].t == 'Str' and b.content[1].text == '~'
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}

  -- cover: court name, caption, title of the motion
  out[#out + 1] = raw(para('Centered', run('UNITED STATES DISTRICT COURT', BOLD)))
  out[#out + 1] = raw(para('Centered', run('DISTRICT OF MAINE', BOLD), '<w:spacing w:after="383"/>'))
  out[#out + 1] = raw(caption_table(meta))
  out[#out + 1] = raw(para('Centered', run(text_of(meta.title), BOLDCAPS), '<w:spacing w:before="383" w:after="383" w:line="552" w:lineRule="exact"/>'))

  -- body: the markdown blocks as they are (paragraphs, headings, quotes, footnotes); the last one keeps
  -- with the signature block
  local body = doc.blocks
  local last = #body
  for i, b in ipairs(body) do
    if i == last and b.t == 'Para' then
      out[#out + 1] = pandoc.Div({ b }, pandoc.Attr('', {}, { ['custom-style'] = 'Body Text Final' }))
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = raw(signature_table(meta))

  -- certificate of service, when the sample has one (its text is markdown)
  if meta.certificate ~= nil and text_of(meta.certificate) ~= '' then
    local cert = pandoc.read(text_of(meta.certificate), 'markdown+smart').blocks
    out[#out + 1] = raw(para('Centered', run('CERTIFICATE OF SERVICE', BOLD), '<w:spacing w:before="383" w:after="260"/><w:keepNext/>'))
    for _, b in ipairs(cert) do
      if b.t == 'Para' then
        out[#out + 1] = pandoc.Div({ b }, pandoc.Attr('', {}, { ['custom-style'] = 'Body Text Final' }))
      else
        out[#out + 1] = b
      end
    end
    out[#out + 1] = raw(signature_table(meta))
  end
  out[#out + 1] = raw(para('Single', ''))

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
