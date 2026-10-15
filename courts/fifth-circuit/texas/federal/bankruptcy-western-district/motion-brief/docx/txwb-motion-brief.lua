-- txwb motion brief, docx engine (pandoc Lua filter). Same sample contract as typst/txwb-motion-brief.typ: the YAML
-- frontmatter gives the caption, the negative-notice address, the title, addressee, lead-in, signature and certificate of
-- service; the markdown body gives the sections (# and ## headings, not numbered), the numbered paragraphs (1, 2, ...)
-- and the lettered lists ((a), (b)). The cover, caption, negative notice, signature and certificate are raw OpenXML
-- tables (a caption cell needs a right and a bottom rule, which pandoc's markdown tables cannot express). Layout comes
-- from reference.docx (styles, page, footer). Nothing here is case-specific except the frontmatter.

local TAB = '<w:r><w:tab/></w:r>'

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

-- A run of text with explicit bold/italic flags (flags are written in schema order: b, then i).
local function T(s, f)
  f = f or {}
  local pr = ''
  if f.b then pr = pr .. '<w:b/><w:bCs/>' end
  if f.i then pr = pr .. '<w:i/><w:iCs/>' end
  if pr ~= '' then pr = '<w:rPr>' .. pr .. '</w:rPr>' end
  return '<w:r>' .. pr .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

-- Pandoc inlines (markdown from the frontmatter: *italics*, smart quotes) to runs.
local function runs(inlines, base)
  local out = {}
  local function walk(list, f)
    for _, el in ipairs(list) do
      local t = el.t
      if t == 'Str' then
        out[#out + 1] = T(el.text, f)
      elseif t == 'Space' or t == 'SoftBreak' or t == 'LineBreak' then
        out[#out + 1] = T(' ', f)
      elseif t == 'Emph' then
        walk(el.content, { b = f.b, i = true })
      elseif t == 'Strong' then
        walk(el.content, { b = true, i = f.i })
      elseif t == 'Quoted' then
        local q = el.quotetype == 'SingleQuote' and { '\u{2018}', '\u{2019}' } or { '\u{201C}', '\u{201D}' }
        out[#out + 1] = T(q[1], f)
        walk(el.content, f)
        out[#out + 1] = T(q[2], f)
      elseif t == 'Span' or t == 'Link' then
        walk(el.content, f)
      else
        out[#out + 1] = T(pandoc.utils.stringify(el), f)
      end
    end
  end
  walk(inlines or {}, base or {})
  return table.concat(out)
end

-- Frontmatter values are inline lists (or plain strings); a missing key is an empty list.
local function inl(v)
  if v == nil then return {} end
  if type(v) == 'string' then return { pandoc.Str(v) } end
  return v
end

local function plain(v)
  return pandoc.utils.stringify(inl(v))
end

local function has(v)
  return v ~= nil and plain(v) ~= ''
end

-- One paragraph. `keep` keeps it on the page with the next one (blocks that must not split).
local function P(style, content, opts)
  opts = opts or {}
  local ppr = ''
  if opts.keep then ppr = ppr .. '<w:keepNext/>' end
  if opts.before then ppr = ppr .. '<w:spacing w:before="' .. opts.before .. '"/>' end
  if opts.ind then ppr = ppr .. '<w:ind w:left="' .. opts.ind .. '"/>' end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. ppr .. '</w:pPr>' .. (content or '') .. '</w:p>'
end

local function EMPTY(style)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>'
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function TC(width, body, pr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (pr or '') .. '</w:tcPr>' .. body .. '</w:tc>'
end

local function TR(cells)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

local function TBL(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

local function letter(i)
  return string.char(96 + i)
end

-- Negative-notice form language, W.D. Tex. L.R. 9014-1(a) (fixed text of the rule, as in typst/txwb-motion-brief.typ).
-- The Clerk's mailing address is the one thing the rule asks to be filled in: it comes from the sample's clerk_address.
local function negative_notice(meta)
  return {
    'This pleading requests relief that may be adverse to your interests.',
    'If no timely response is filed within 21 days from the date of service, the relief requested herein may be granted without a hearing being held.',
    'A timely filed response is necessary for a hearing to be held.',
    'Any response must be timely filed with the United States Bankruptcy Clerk, Western District of Texas, ' .. plain(meta.clerk_address) .. '.',
    'If a timely response is filed, the Court will then set a hearing on the Motion, and you will be provided with notice of the date, time, and place of the hearing.',
    'If you do not attend the hearing, the Court may decide that you do not oppose the Motion.',
  }
end

-- Court title, division, the caption (parties left, case numbers right), the negative notice and the title of the paper.
local function cover(meta)
  local out = {}
  out[#out + 1] = P('CourtTitle', T('IN THE UNITED STATES BANKRUPTCY COURT'))
  out[#out + 1] = P('CourtTitle', T('FOR THE WESTERN DISTRICT OF TEXAS'))
  if has(meta.division) then
    out[#out + 1] = P('CourtTitle', T(plain(meta.division):upper() .. ' DIVISION'))
  end
  out[#out + 1] = EMPTY('Spacer')

  local left = { P('Single', T('In re:')), P('Single', runs(inl(meta.debtor.name))), P('Single', T('Debtor.'), { ind = 720 }) }
  local first = true
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = P('Single', T('v.')) end
    for _, name in ipairs(party.names) do
      left[#left + 1] = P('Single', runs(inl(name)), first and { before = 120 } or nil)
      first = false
    end
    left[#left + 1] = P('Single', runs(inl(party.designation)))
  end

  local right = {
    P('Single', T('Case No. ') .. runs(inl(meta.debtor.case_number))),
    P('Single', runs(inl(meta.debtor.chapter))),
    P('Single', T('Adv. Pro. No. ') .. runs(inl(meta.adversary_number)), { before = 204 }),
  }
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = TBL({ 4896, 432, 4032 }, {
    TR({
      TC(4896, table.concat(left), rule),
      TC(432, P('Single', '')),
      TC(4032, table.concat(right), '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'),
    }),
  })
  out[#out + 1] = EMPTY('Spacer')

  for _, line in ipairs(negative_notice(meta)) do
    out[#out + 1] = P('NegativeNotice', T(line))
  end
  out[#out + 1] = EMPTY('Spacer')

  out[#out + 1] = P('PleadingTitle', T(plain(meta.brief_title):upper()))
  out[#out + 1] = EMPTY('Spacer')
  if has(meta.addressee) then
    out[#out + 1] = P('BodyText', runs(inl(meta.addressee)))
    out[#out + 1] = EMPTY('Spacer')
  end
  return out
end

-- Signature block: "Dated:" left; "Respectfully submitted," right; each signer as "By: /s/ Name", the name and the lines
-- under it, groups separated by -AND-; then the role lines if the frontmatter has them. Gaps follow the typst template.
local function signature(meta)
  local sig = meta.signature
  local items = {}
  local function add(text, gap)
    items[#items + 1] = { text = text, gap = gap }
  end
  add(T('Respectfully submitted,'), false)
  for k, g in ipairs(sig.groups) do
    if k > 1 then add(T('-AND-'), true) end
    local first = true
    if g.signer then
      add(T('By: /s/ ' .. plain(g.signer)), true)
      first = false
      add(runs(inl(g.signer)), false)
    end
    for _, line in ipairs(g.lines or {}) do
      add(runs(inl(line)), first)
      first = false
    end
  end
  if sig.role then
    for k, line in ipairs(sig.role) do add(runs(inl(line)), k == 1) end
  end
  local right = {}
  for k, it in ipairs(items) do
    right[#right + 1] = P('Single', it.text, { keep = k < #items, before = it.gap and 204 or nil })
  end
  local left = P('Single', T('Dated:') .. T(' ') .. runs(inl(meta.date)), { keep = true })
  return TBL({ 3744, 288, 5328 }, {
    TR({ TC(3744, left), TC(288, P('Single', '')), TC(5328, table.concat(right)) }),
  })
end

-- Certificate of service: centered heading, the certifying sentence, the service list in two columns, and the signer.
local function certificate(meta)
  local c = meta.certificate
  local out = {}
  out[#out + 1] = P('PleadingTitle', T('CERTIFICATE OF SERVICE'), { keep = true })
  out[#out + 1] = EMPTY('Spacer')
  out[#out + 1] = P('LeadIn', runs(inl(c.text)), { keep = true })
  out[#out + 1] = EMPTY('Spacer')

  local cells = {}
  for _, g in ipairs(c.service or {}) do
    local lines = {}
    for _, line in ipairs(g.lines or {}) do lines[#lines + 1] = P('Single', runs(inl(line)), { keep = true }) end
    cells[#cells + 1] = table.concat(lines)
  end
  local rows = {}
  for k = 1, #cells, 2 do
    rows[#rows + 1] = TR({
      TC(4464, cells[k]),
      TC(432, P('Single', '')),
      TC(4464, cells[k + 1] or P('Single', '')),
    })
  end
  if #rows > 0 then out[#out + 1] = TBL({ 4464, 432, 4464 }, rows) end
  out[#out + 1] = EMPTY('Spacer')

  local sig = { P('Single', T('By: /s/ ' .. plain(c.signer)), { keep = true }), P('Single', runs(inl(c.signer)), { keep = #(c.lines or {}) > 0 }) }
  for k, line in ipairs(c.lines or {}) do
    sig[#sig + 1] = P('Single', runs(inl(line)), { keep = k < #c.lines })
  end
  out[#out + 1] = TBL({ 3744, 288, 5328 }, {
    TR({ TC(3744, P('Single', '')), TC(288, P('Single', '')), TC(5328, table.concat(sig)) }),
  })
  return out
end

-- Numbered body paragraph: "N." then a space and 0.2 in to the text position of the typst template (1.02 in).
local function numbered(n, inlines)
  local content = { pandoc.Str(tostring(n) .. '.'), pandoc.RawInline('openxml', TAB) }
  for _, el in ipairs(inlines) do content[#content + 1] = el end
  return pandoc.Div({ pandoc.Para(content) }, { ['custom-style'] = 'Numbered Paragraph' })
end

-- List item: a marker, then a tab to the body position (1.09 in), hanging from 0.5 in. Ordered items are lettered
-- "(a)", "(b)", ... as in the typst template.
local function item(marker, blocks)
  local out = {}
  local first = blocks[1]
  local inlines = {}
  if first and (first.t == 'Para' or first.t == 'Plain') then
    inlines = first.content
    table.remove(blocks, 1)
  end
  local content = { pandoc.Str(marker), pandoc.RawInline('openxml', TAB) }
  for _, el in ipairs(inlines) do content[#content + 1] = el end
  out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, { ['custom-style'] = 'Prayer Item' })
  for _, b in ipairs(blocks) do out[#out + 1] = b end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(x)
    if type(x) == 'string' then out[#out + 1] = pandoc.RawBlock('openxml', x) else out[#out + 1] = x end
  end

  for _, b in ipairs(cover(meta)) do add(b) end

  if has(meta.lead_in) then
    add(P('LeadIn', runs(inl(meta.lead_in))))
  end

  local paragraphs = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Para' then
      paragraphs = paragraphs + 1
      add(numbered(paragraphs, b.content))
    elseif b.t == 'OrderedList' then
      for i, blocks in ipairs(b.content) do
        for _, x in ipairs(item('(' .. letter(i) .. ')', blocks)) do add(x) end
      end
    elseif b.t == 'BulletList' then
      for _, blocks in ipairs(b.content) do
        for _, x in ipairs(item('\u{2022}', blocks)) do add(x) end
      end
    else
      add(b)
    end
  end

  add(EMPTY('Spacer'))
  add(signature(meta))
  if meta.certificate then
    add(EMPTY('Spacer'))
    for _, b in ipairs(certificate(meta)) do add(b) end
  end
  -- Empty metadata: pandoc would print the date (and title, author) above the cover; the cover is written above.
  return pandoc.Pandoc(out, {})
end
