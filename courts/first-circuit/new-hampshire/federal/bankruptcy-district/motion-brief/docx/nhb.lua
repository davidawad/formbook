-- nhb (D.N.H. bankruptcy court), DOCX engine (docs/DOCX.md): the caption, the adversary caption, the title,
-- the numbered body, the signature block and (when the sample has one) the certificate of service, built as
-- Word-native paragraphs and tables from the markdown frontmatter. Matches typst/nhb-*.typ. This file holds
-- no case text: every word comes from the sample's YAML. Paragraph formats live in build-reference.sh's styles.
-- Shared with motion-brief/docx (same file): the adversary caption is drawn only when the frontmatter has one.

-- Paragraph numbers (Fed. R. Civ. P. 10(b)): on for a complaint, off for a memorandum (typst: numbered only in the complaint).
local NUMBER_PARAGRAPHS = false

local function S(v)
  if v == nil then return '' end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or single value) as a Lua array of strings
local function items(v)  -- a YAML list: pandoc gives a MetaList (or a plain Lua array); one value is a MetaInlines
  local out = {}
  if v == nil then return out end
  if v.t == "MetaList" or (v.t == nil and #v > 0) then
    for _, x in ipairs(v) do out[#out + 1] = S(x) end
  else
    out[#out + 1] = S(v)
  end
  return out
end

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function run(text, rpr)
  return '<w:r>' .. (rpr or '') .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function par(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. inner .. '</w:p>'
end

local function raw(xml)
  return pandoc.RawBlock('openxml', xml)
end

-- Caption tables: two 3.25 in columns, no table borders; the left cell has a right and a bottom rule
-- (typst: stroke right and bottom on the left block). Cell margins in twentieths of a point.
local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders>'

local function margins(t, l, b, r)
  return '<w:top w:w="' .. t .. '" w:type="dxa"/><w:left w:w="' .. l .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. b .. '" w:type="dxa"/><w:right w:w="' .. r .. '" w:type="dxa"/>'
end

local function cell(width, borders, mar, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or '')
    .. '<w:tcMar>' .. mar .. '</w:tcMar></w:tcPr>' .. paras .. '</w:tc>'
end

local function caption_table(left, right)
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/></w:tblPr><w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="4680"/></w:tblGrid>'
    .. '<w:tr>' .. cell(4680, RULE, margins(40, 0, 160, 200), left)
    .. cell(4680, nil, margins(40, 360, 0, 0), right) .. '</w:tr></w:tbl>')
end

local function bankruptcy_caption(b)
  local left = par('CapLeft', run('In re:'))
    .. par('CapNameLast', run(S(b.debtor)))
    .. par('CapRight', run(S(b.designation)))
  local right = par('CapLeft', run(S(b.chapter)))
    .. par('CapLeft', run('Case No. ' .. S(b.case_number)))
  return caption_table(left, right)
end

local function adversary_caption(a)
  local left = ''
  for i, p in ipairs(a.parties or {}) do
    if i > 1 then left = left .. par('CapLeft', run('v.')) end
    local names = items(p.names)
    for j, n in ipairs(names) do
      left = left .. par(j == #names and 'CapNameLast' or 'CapName', run(n))
    end
    left = left .. par('CapRight', run(S(p.designation)))
  end
  local right
  if S(a.number) == '' then
    -- the blank for the clerk's adversary number: a line from the text to a tab stop (1.3 in past the label)
    right = '<w:p><w:pPr><w:pStyle w:val="CapLeft"/><w:tabs><w:tab w:val="left" w:leader="underscore" w:pos="3400"/></w:tabs></w:pPr>'
      .. run('Adv. Pro. No.') .. '<w:r><w:tab/></w:r></w:p>'
  else
    right = par('CapLeft', run('Adv. Pro. No. ' .. S(a.number)))
  end
  return caption_table(left, right)
end

local function sig_block(label, date, intro, signer, lines)
  -- with no intro (the certificate), the date and signer sit closer, as in the typst template
  local solo = #intro == 0
  local out = par(solo and 'SigDateSolo' or 'SigDate', run(label .. ' ' .. date))
  for _, l in ipairs(intro) do out = out .. par('SigRight', run(l)) end
  if signer ~= '' then out = out .. par(solo and 'SigSignerSolo' or 'SigSigner', run(signer)) end
  for i, l in ipairs(lines) do
    out = out .. par(i == #lines and 'SigRightEnd' or 'SigRight', run(l))
  end
  return raw(out)
end

local function styled(blocks, name)
  return pandoc.Div(blocks, pandoc.Attr('', {}, { ['custom-style'] = name }))
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}

  -- caption: court, bankruptcy caption, (adversary caption), title
  local court = items(m.court)
  for i, l in ipairs(court) do
    out[#out + 1] = raw(par(i == #court and 'CourtLineLast' or 'CourtLine', run(l)))
  end
  if m.bankruptcy then out[#out + 1] = bankruptcy_caption(m.bankruptcy) end
  if m.adversary then
    out[#out + 1] = raw(par('GapExact10', ''))
    out[#out + 1] = adversary_caption(m.adversary)
  end
  out[#out + 1] = raw(par('TitleBlock', run(S(m.title))))

  -- body: "#" headings (sections) and "##" headings come from pandoc's Heading styles; paragraphs are numbered
  -- 1, 2, ... by this filter (Fed. R. Civ. P. 10(b), as the typst template does), except under the headings
  -- listed in `unnumbered` and the WHEREFORE paragraphs. "(A)" items are sub-items: indented, unnumbered.
  local unnumbered = {}
  for _, h in ipairs(items(m.unnumbered)) do unnumbered[h] = true end
  local blocks = doc.blocks
  local last
  for i = #blocks, 1, -1 do
    if blocks[i].t == 'Para' then last = i break end
  end
  local numbered, n = true, 0
  for i, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 then
      numbered = not unnumbered[pandoc.utils.stringify(b)]
      out[#out + 1] = b
    elseif b.t == 'Para' then
      local txt = pandoc.utils.stringify(b)
      if txt:match('^%([A-Z]%) ') then
        out[#out + 1] = styled({ b }, 'Sub Item')
      else
        if NUMBER_PARAGRAPHS and numbered and not txt:match('^WHEREFORE') then
          n = n + 1
          table.insert(b.content, 1, pandoc.Space())
          table.insert(b.content, 1, pandoc.Str(n .. '.'))
        end
        if i == last then
          out[#out + 1] = styled({ b }, 'Body Last')
        else
          out[#out + 1] = b
        end
      end
    elseif b.t == 'OrderedList' and b.listAttributes.style == 'UpperAlpha' then
      -- "(A) text" lines are read as an upper-alpha list: write the letter back as text
      for k, item in ipairs(b.content) do
        local first = item[1]
        if first and first.t == 'Para' then
          local letter = string.char(64 + b.listAttributes.start + k - 1)
          table.insert(first.content, 1, pandoc.Space())
          table.insert(first.content, 1, pandoc.Str('(' .. letter .. ')'))
          out[#out + 1] = styled({ first }, 'Sub Item')
          for j = 2, #item do out[#out + 1] = item[j] end
        else
          for _, x in ipairs(item) do out[#out + 1] = x end
        end
      end
    else
      out[#out + 1] = b
    end
  end

  -- signature block (sticky with the last paragraph)
  local s = m.signature
  out[#out + 1] = sig_block(S(m.date_label) ~= '' and S(m.date_label) or 'Date:', S(m.date),
    items(s.intro), S(s.signer), items(s.lines))

  -- certificate of service, when the frontmatter has one (motion-brief)
  local c = m.certificate
  if c then
    out[#out + 1] = raw(par('CertTitle', run(S(c.title))))
    -- the certificate is one unit: its paragraphs keep with the signature block below (CertBody, keep-with-next)
    for _, p in ipairs(c.paragraphs or {}) do
      local blocks = (p.t == "MetaBlocks") and p or { pandoc.Para(p) }
      for _, b in ipairs(blocks) do out[#out + 1] = styled({ b }, "Certificate Body") end
    end
    out[#out + 1] = sig_block(S(c.date_label) ~= '' and S(c.date_label) or 'Date:', S(c.date),
      {}, S(c.signer), items(c.lines))
  end

  -- the title and date are typeset above; keep pandoc from adding its own title block
  m.title = nil
  m.date = nil
  doc.blocks = out
  return doc
end
