-- txwb adversary complaint, docx engine (pandoc Lua filter). Same sample contract as
-- typst/txwb-adversary-complaint.typ: the YAML frontmatter gives the caption, title, lead-in, signature; the markdown
-- body gives the sections (# roman, ## lettered), the numbered paragraphs (1, 2, ...) and the lettered lists ((a), (b)).
-- The cover, caption and signature block are written as raw OpenXML tables (a caption cell needs a right and a bottom
-- rule, which pandoc's markdown tables cannot express). Layout comes from reference.docx (styles, page, footer).
-- Nothing here is case-specific: every case word comes from the sample's frontmatter.

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

local function roman(n)
  local vals = { { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }
  local out = ''
  for _, v in ipairs(vals) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
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

-- Court title, division, the caption (parties left, case numbers right) and the title of the paper.
local function cover(meta)
  local out = {}
  out[#out + 1] = P('CourtTitle', T('IN THE UNITED STATES BANKRUPTCY COURT'))
  out[#out + 1] = P('CourtTitle', T('FOR THE WESTERN DISTRICT OF TEXAS'))
  if has(meta.division) then
    out[#out + 1] = P('CourtTitle', T(plain(meta.division):upper() .. ' DIVISION'))
  end
  out[#out + 1] = EMPTY('Spacer')

  local left = { P('Single', T('IN RE:')), P('Single', runs(inl(meta.debtor.name))), P('Single', T('Debtor.'), { ind = 720 }) }
  local first = true
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = P('Single', T('v.')) end
    for _, name in ipairs(party.names) do
      left[#left + 1] = P('Single', runs(inl(name)), first and { before = 120 } or nil)
      first = false
    end
    left[#left + 1] = P('Single', runs(inl(party.designation)))
  end

  local adv = has(meta.adversary_number) and runs(inl(meta.adversary_number)) or T('____________________')
  local right = {
    P('Single', T('Case No. ') .. runs(inl(meta.debtor.case_number))),
    P('Single', runs(inl(meta.debtor.chapter))),
    P('Single', T('Adv. Pro. No. ') .. adv, { before = 204 }),
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
  out[#out + 1] = P('PleadingTitle', T(plain(meta.brief_title):upper()))
  out[#out + 1] = EMPTY('Spacer')
  return out
end

-- Signature block: "Dated:" left; "Respectfully submitted," and the firm right; each signer as "/s/ Name", the name
-- and the lines under it, groups separated by -AND-; then the role lines. Gaps follow the typst template.
local function signature(meta)
  local sig = meta.signature
  local items = {}
  local function add(text, gap)
    items[#items + 1] = { text = text, gap = gap }
  end
  add(T('Respectfully submitted,'), false)
  if sig.firm then
    for k, line in ipairs(sig.firm) do add(runs(inl(line)), k == 1) end
  end
  for k, g in ipairs(sig.groups) do
    if k > 1 then
      add(T('-AND-'), true)
    end
    local first = true
    if g.signer then
      add(T('/s/ ' .. plain(g.signer)), true)
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

-- Numbered body paragraph: "N." then a tab to the text position of the typst template (0.92 in).
local function numbered(n, inlines)
  local content = { pandoc.Str(tostring(n) .. '.'), pandoc.RawInline('openxml', TAB) }
  for _, el in ipairs(inlines) do content[#content + 1] = el end
  return pandoc.Div({ pandoc.Para(content) }, { ['custom-style'] = 'Numbered Paragraph' })
end

-- List item: a marker, then a tab to the body position (1.09 in), hanging from 0.5 in. Ordered items are lettered
-- "(a)", "(b)", ... as in the typst template; bullets get a dot.
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

  local paragraphs, h1, h2 = 0, 0, 0
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' and b.level == 1 then
      h1, h2 = h1 + 1, 0
      local c = { pandoc.Str(roman(h1) .. '.'), pandoc.Space() }
      for _, el in ipairs(b.content) do c[#c + 1] = el end
      body[#body + 1] = pandoc.Header(1, c, b.attr)
    elseif b.t == 'Header' and b.level == 2 then
      h2 = h2 + 1
      local c = { pandoc.Str(string.char(64 + h2) .. '.'), pandoc.Space() }
      for _, el in ipairs(b.content) do c[#c + 1] = el end
      body[#body + 1] = pandoc.Header(2, c, b.attr)
    elseif b.t == 'Para' then
      paragraphs = paragraphs + 1
      body[#body + 1] = numbered(paragraphs, b.content)
    elseif b.t == 'OrderedList' then
      for i, blocks in ipairs(b.content) do
        for _, x in ipairs(item('(' .. string.char(96 + i) .. ')', blocks)) do body[#body + 1] = x end
      end
    elseif b.t == 'BulletList' then
      for _, blocks in ipairs(b.content) do
        for _, x in ipairs(item('\u{2022}', blocks)) do body[#body + 1] = x end
      end
    else
      body[#body + 1] = b
    end
  end
  for _, b in ipairs(body) do add(b) end

  add(EMPTY('Spacer'))
  add(signature(meta))
  -- Empty metadata: pandoc would print the date (and title, author) above the cover; the cover is written above.
  return pandoc.Pandoc(out, {})
end
