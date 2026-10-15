-- docx engine for the areb templates (the same layout as ../typst/areb-adversary-complaint.typ and
-- ../../motion-brief/typst/areb-motion-brief.typ). Pandoc passes the YAML frontmatter as the document
-- metadata; this filter writes the caption (a table with a rule under and beside the debtor block),
-- numbers the body paragraphs continuously, and appends the signature block and, when the metadata has
-- a `service` block, the certificate of service. Rule IDs (AREB-...) are in ../README.md.
-- Nothing here is case-specific: every name and number comes from the sample's frontmatter.
-- Styles live in reference.docx (see make-reference.sh); the layout numbers are there too.

-- ---------------------------------------------------------------------------
-- XML helpers (the caption and the signature are raw WordprocessingML)
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

-- One run of text. f = {b = bool, i = bool}.
local function run(text, f)
  local rpr = (f.b and '<w:b/>' or '') .. (f.i and '<w:i/>' or '')
  if rpr ~= '' then rpr = '<w:rPr>' .. rpr .. '</w:rPr>' end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- Inline content (a list of pandoc inlines, already parsed from the YAML markdown) as runs.
local function runs(inls, f)
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == 'Str' then
      out[#out + 1] = run(el.text, f)
    elseif t == 'Space' or t == 'SoftBreak' or t == 'LineBreak' then
      out[#out + 1] = run(' ', f)
    elseif t == 'Emph' then
      out[#out + 1] = runs(el.content, {b = f.b, i = true})
    elseif t == 'Strong' then
      out[#out + 1] = runs(el.content, {b = true, i = f.i})
    elseif t == 'Quoted' then
      local q = el.quotetype == 'SingleQuote' and {'\u{2018}', '\u{2019}'} or {'\u{201C}', '\u{201D}'}
      out[#out + 1] = run(q[1], f) .. runs(el.content, f) .. run(q[2], f)
    elseif t == 'Span' or t == 'Link' then
      out[#out + 1] = runs(el.content, f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

-- A metadata value (markdown-parsed MetaInlines, or a plain string) as runs.
local function content(v, f)
  f = f or {}
  if type(v) == 'table' and v.t == 'MetaInlines' then
    return runs(v, f)
  end
  return run(pandoc.utils.stringify(v), f)
end

-- A paragraph in the given style. sp is a raw <w:spacing .../> (or nil).
local function para(style, body, sp)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (sp or '') .. '</w:pPr>' .. body .. '</w:p>'
end

-- Spacing in twentieths of a point: before, after.
local function gap(before, after)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '"/>'
end

-- ---------------------------------------------------------------------------
-- Caption: court name, then the two-column block (debtor, parties | case numbers)
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function caption(meta, title)
  local court = meta.court
  local xml = {}
  for _, k in ipairs({'name', 'district', 'division'}) do
    local last = k == 'division'
    xml[#xml + 1] = para('CaptionHeading',
      run(pandoc.utils.stringify(court[k]):upper(), {}),
      last and gap(0, 384) or nil)
  end

  local debtor = meta.debtor
  local left = {}
  -- IN RE: the debtor(s), centred, then the designation; 13.2 pt gap between the three groups
  left[#left + 1] = para('CaptionSingle', run('IN RE:', {}))
  for _, n in ipairs(debtor.names) do
    left[#left + 1] = para('CaptionCentered', content(n))
  end
  local debtor_des = #debtor.names > 1 and 'Debtors.' or 'Debtor.'
  left[#left + 1] = para('CaptionRight', run(debtor_des, {}), gap(0, 264))

  if meta.adversary_number ~= nil then
    -- plaintiffs, then "v." centred, then defendants, each group followed by its designation
    for _, n in ipairs(meta.plaintiffs.names) do
      left[#left + 1] = para('CaptionSingle', content(n))
    end
    left[#left + 1] = para('CaptionRight', content(meta.plaintiff_designation), gap(0, 264))
    left[#left + 1] = para('CaptionCentered', run('v.', {}), gap(0, 264))
    for _, n in ipairs(meta.defendants.names) do
      left[#left + 1] = para('CaptionSingle', content(n))
    end
    left[#left + 1] = para('CaptionRight', content(meta.defendant_designation))
  end

  local right = {}
  right[#right + 1] = para('CaptionCase', run('Case No. ' .. pandoc.utils.stringify(debtor.case_number), {}), gap(0, 216))
  right[#right + 1] = para('CaptionCase', run('Chapter ' .. pandoc.utils.stringify(debtor.chapter), {}), gap(0, 216))
  if meta.adversary_number ~= nil then
    right[#right + 1] = para('CaptionCase', run('Adv. Proc. No. ' .. pandoc.utils.stringify(meta.adversary_number), {}))
  end

  xml[#xml + 1] = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="5040"/><w:gridCol w:w="4320"/></w:tblGrid>'
    .. '<w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5040" w:type="dxa"/><w:tcBorders>'
    .. string.format(RULE, 'bottom') .. string.format(RULE, 'right')
    .. '</w:tcBorders><w:tcMar><w:top w:w="48" w:type="dxa"/><w:bottom w:w="216" w:type="dxa"/><w:right w:w="288" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left)
    .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa"/><w:vAlign w:val="center"/></w:tcPr>'
    .. table.concat(right)
    .. '</w:tc>'
    .. '</w:tr></w:tbl>'

  -- the document title, after the caption (typst: v(1.6em) above, v(1.2em) below)
  xml[#xml + 1] = para('CaptionHeading', content(title), gap(384, 240))
  return table.concat(xml)
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (LR 5005-4, FRBP 9011)
-- ---------------------------------------------------------------------------

local function signature(meta, dated)
  local sig = meta.signature
  local xml = {}
  if dated ~= nil then
    xml[#xml + 1] = para('CaptionSingle', run('Dated: ', {}) .. content(dated), gap(0, 0))
  end
  xml[#xml + 1] = para('SignatureBlock', run('Respectfully submitted,', {}), gap(dated and 288 or 0, 216))
  xml[#xml + 1] = para('SignatureBlock', run('s/ ' .. pandoc.utils.stringify(sig.signer), {}))
  for _, l in ipairs(sig.lines) do
    xml[#xml + 1] = para('SignatureBlock', content(l))
  end

  -- counsel: every group's names and lines, then the telephone number
  local first = true
  for _, g in ipairs(meta.counsel) do
    for _, item in ipairs(g.names) do
      xml[#xml + 1] = para('CaptionSingle', content(item), first and gap(360, 0) or nil)
      first = false
    end
    for _, l in ipairs(g.lines) do
      xml[#xml + 1] = para('CaptionSingle', content(l))
    end
  end
  xml[#xml + 1] = para('CaptionSingle', content(meta.phone))
  return table.concat(xml)
end

local function certificate(meta)
  local svc = meta.service
  local xml = {}
  xml[#xml + 1] = para('CaptionHeading', run('CERTIFICATE OF SERVICE', {}), gap(480, 216))
  xml[#xml + 1] = para('CertificateBody', run('I certify that on ', {}) .. content(svc.date)
    .. run(', the foregoing motion and memorandum in support were served electronically through the Court\u{2019}s CM/ECF system on the parties registered to receive notice, and by first-class United States mail, postage prepaid, on the parties listed below who are not registered.', {}),
    gap(0, 216))
  for i, p in ipairs(svc.parties) do
    xml[#xml + 1] = para('CaptionSingle', content(p), i == #svc.parties and gap(0, 288) or nil)
  end
  xml[#xml + 1] = para('SignatureBlock', run('s/ ' .. pandoc.utils.stringify(meta.signature.signer), {}))
  return table.concat(xml)
end

-- ---------------------------------------------------------------------------
-- Numbered paragraphs: every ordered-list item is one paragraph, numbered continuously through
-- the whole document (FRCP 10(b)), as the typst template does with its counter.
-- ---------------------------------------------------------------------------

local number = 0

local function numbered(list)
  local out = pandoc.List()
  for _, item in ipairs(list.content) do
    number = number + 1
    local blocks = pandoc.List(item)
    local first = blocks[1]
    if first and (first.t == 'Para' or first.t == 'Plain') then
      local inl = pandoc.List({pandoc.Str(number .. '.'), pandoc.Space()})
      inl:extend(first.content)
      blocks[1] = pandoc.Para(inl)
    end
    out:insert(pandoc.Div(blocks, pandoc.Attr('', {}, {{'custom-style', 'Numbered Paragraph'}})))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  -- The caption carries the title and the signature carries the date; pandoc must not add its own
  -- title block, author or date lines, so they are taken out of the metadata here.
  local title = meta.title
  local dated = meta.date
  meta.title = nil
  meta.author = nil
  meta.date = nil

  local body = doc:walk({OrderedList = numbered}).blocks

  local out = pandoc.List()
  out:insert(pandoc.RawBlock('openxml', caption(meta, title)))
  out:extend(body)
  out:insert(pandoc.RawBlock('openxml', signature(meta, dated)))
  if meta.service ~= nil then
    out:insert(pandoc.RawBlock('openxml', certificate(meta)))
  end
  return pandoc.Pandoc(out, meta)
end
