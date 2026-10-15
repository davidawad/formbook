-- Pandoc Lua filter for the rib motion with memorandum (docx engine). Mirrors typst/rib-motion-brief.typ:
-- caption and title; the motion (unnumbered paragraphs, "1." lists, block quotations, headings); the LBR 1005-1(d)(1)
-- response language; the signature block; a page break and the memorandum with its own caption, title and signature
-- ("Of Counsel" lines); the certificate of service on a new page. The sample's "---" line separates the motion from
-- the memorandum. Named styles come from docx/reference.docx (built by docx/build-reference.sh). Case text comes only
-- from the sample's frontmatter and body.

local COURT = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF RHODE ISLAND" }
local CAPTION_LEFT, GUTTER, TEXT_W = 4752, 360, 9360 -- twips: 3.3 in, 0.25 in, 6.5 in
-- LBR 1005-1(d)(1): the response-time language, verbatim from the template (typst/rib-motion-brief.typ)
local RESPONSE_DEFAULT = "Within fourteen (14) days after service, if served electronically, as evidenced by the certification, and an additional three (3) days pursuant to Fed. R. Bank. P. 9006(f) if served by mail or other excepted means specified, any party against whom such paper has been served, or any other party who objects to the relief sought, shall serve and file an objection or other appropriate response to said paper with the Bankruptcy Court Clerk's Office, 380 Westminster Street, 6th Floor, Providence, RI 02903, (401) 626-3100. If no objection or other response is timely filed, the paper will be deemed unopposed and will be granted unless: (1) the requested relief is forbidden by law; (2) the requested relief is against public policy; or (3) in the opinion of the Court, the interest of justice requires otherwise."

local function xesc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function s(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a list of values (each a list of inlines, or a meta value) or one value (a list of inlines)
local function strings(v)
  local t = {}
  if v == nil then return t end
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

-- one paragraph of raw WordprocessingML; ppr holds direct pPr children after pStyle, in schema order
local function para(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. (inner or '') .. '</w:p>'
end

local function raw(xml)
  return pandoc.RawBlock('openxml', xml)
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr('', {}, { ['custom-style'] = style }))
end

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

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
  .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local NOCELLMAR = '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'

-- caption: the bankruptcy case (In re) on the left above a rule, the case numbers on the right
local function caption_table(meta)
  local left = {}
  left[#left + 1] = para('RibSingle', run('IN RE:'))
  for _, name in ipairs(strings(meta.in_re)) do
    left[#left + 1] = para('RibSingle', run(name))
  end
  left[#left + 1] = para('RibRight', run(s(meta.debtor_designation)), '<w:spacing w:before="0" w:after="120"/>')
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
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/>' .. NOCELLMAR .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAPTION_LEFT .. '"/><w:gridCol w:w="' .. GUTTER .. '"/><w:gridCol w:w="'
    .. (TEXT_W - CAPTION_LEFT - GUTTER) .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_LEFT .. '" w:type="dxa"/>' .. rule .. lmar .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. GUTTER .. '" w:type="dxa"/></w:tcPr>' .. para('RibSingle', '') .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXT_W - CAPTION_LEFT - GUTTER) .. '" w:type="dxa"/>' .. rmar .. '</w:tcPr>' .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

-- the court title, the caption and the title of the paper; the first line may start a new page
local function titled_caption(meta, title, new_page)
  local out = {}
  for k, line in ipairs(COURT) do
    out[#out + 1] = para('RibCenterBold', run(line), (k == 1 and new_page) and '<w:pageBreakBefore/>' or nil)
  end
  out[#out + 1] = para('RibGap16', '')
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = para('RibGap16', '')
  out[#out + 1] = para('RibTitle', run(s(title):upper()))
  out[#out + 1] = para('RibGap16', '')
  return table.concat(out)
end

-- signature block: the case line (LBR 1005-1(a)), "Respectfully submitted", signer, firm, bar number; then "Of Counsel"
local function signature_xml(meta, of_counsel, gap_before)
  local sig = meta.signature
  local out = {}
  -- typst: a block after a paragraph is set 16 pt below it (the memorandum, and a motion with no response language)
  if gap_before then out[#out + 1] = para("RibGap16", "") end
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
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/>' .. NOCELLMAR .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4032"/><w:gridCol w:w="288"/><w:gridCol w:w="5040"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4032" w:type="dxa"/></w:tcPr>' .. dated .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. para('RibSingle', '') .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5040" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
  if of_counsel then
    out[#out + 1] = para('RibGap16', '')
    for _, line in ipairs(of_counsel) do out[#out + 1] = para('RibSignature', run(line)) end
  end
  return table.concat(out)
end

-- the certificate of service (typst certificate-block): on a new page, the CM/ECF text, recipients, /s/ signer
local function certificate_xml(meta)
  local c = meta.certificate
  local out = {}
  out[#out + 1] = para('RibCenterBold', run('CERTIFICATE OF SERVICE'), '<w:pageBreakBefore/>')
  out[#out + 1] = para('RibGap16', '')
  out[#out + 1] = para('RibBody', run('I hereby certify that on ' .. s(c.date) .. ', I electronically filed the within '
    .. s(meta.title) .. ' with the Clerk of the Bankruptcy Court for the District of Rhode Island using the CM/ECF System. '
    .. 'The following participant has received notice electronically:'), '<w:spacing w:before="0" w:after="120"/>')
  for _, line in ipairs(strings(c.recipients)) do out[#out + 1] = para('RibRecipient', run(line)) end
  out[#out + 1] = para('RibGap16', '')
  out[#out + 1] = para('RibSignRight', run('/s/ ' .. s(meta.signature.signer)))
  out[#out + 1] = para('RibSignRight', run(s(meta.signature.signer)))
  return table.concat(out)
end

-- body blocks: paragraphs (unnumbered), "1." lists (1., 2., ...), block quotations, headings (pandoc styles)
local function body(blocks, out)
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      out:insert(styled('RibBody', { b }))
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        for j, blk in ipairs(item) do
          if j == 1 and is_text_block(blk) then
            out:insert(labelled(i .. '.', blk.content, 'RibItemNum'))
          elseif is_text_block(blk) then
            out:insert(styled('RibBody', { pandoc.Para(blk.content) }))
          else
            out:insert(blk)
          end
        end
      end
      out:insert(raw(para('RibGap16', '')))
    elseif b.t == "BlockQuote" then
      local qs = {}
      for _, blk in ipairs(b.content) do
        if is_text_block(blk) then qs[#qs + 1] = pandoc.Para(blk.content) else qs[#qs + 1] = blk end
      end
      out:insert(styled('RibQuote', qs))
    else
      out:insert(b)
    end
  end
end

function Pandoc(doc)
  local meta = doc.meta
  local motion, memo = pandoc.List(), nil
  local target = motion
  for _, b in ipairs(doc.blocks) do
    if b.t == "HorizontalRule" and memo == nil then
      memo = pandoc.List()
      target = memo
    elseif b.t ~= "HorizontalRule" then
      target:insert(b)
    end
  end

  local out = pandoc.List()
  -- part 1: the motion
  out:insert(raw(titled_caption(meta, meta.title, false)))
  body(motion, out)
  -- the response-time language and the signature are kept together
  if s(meta.response) ~= "none" then
    local text = meta.response_text and s(meta.response_text) or RESPONSE_DEFAULT
    out:insert(raw(para('RibResponse', run(text))))
    out:insert(raw(para('RibGap16', '')))
  end
  out:insert(raw(signature_xml(meta, nil, s(meta.response) == "none")))

  -- part 2: the memorandum, on a new page with the caption repeated and its own title
  if memo ~= nil then
    out:insert(raw(titled_caption(meta, meta.memorandum_title, true)))
    body(memo, out)
    local of_counsel = nil
    if meta.of_counsel then
      of_counsel = {}
      for _, line in ipairs(strings(meta.of_counsel)) do of_counsel[#of_counsel + 1] = line end
    end
    out:insert(raw(signature_xml(meta, of_counsel, true)))
  end

  if meta.certificate then
    out:insert(raw(certificate_xml(meta)))
  end

  meta.title = nil
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
