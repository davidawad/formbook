-- brief.lua (docx engine): what the Word output adds to pandoc's default conversion, so that it reads like the typst
-- template (../typst/ared-motion-brief.typ). The cover and the signature block are built from the sample's
-- frontmatter as raw WordprocessingML (pandoc has no caption table).
--   * cover: court title (three lines, plus the division), caption, the centered bold title of the paper;
--   * headings: level 1 numbered I., II., ... (a "~ " marker makes it unnumbered: INTRODUCTION, CONCLUSION);
--     level 2 lettered A., B., ...; level 3 numbered 1., 2., ...; the number is followed by a tab;
--   * lists "(1)", "(2)", ...; table cells single-spaced ("Table Text"); block quotes from pandoc's BlockQuote;
--   * the signature block.
-- Paragraphs are not numbered (a brief's paragraphs are not numbered by the rules).
-- Not built: a table of contents or authorities (none in the exemplar; see ../README.md).

local DOUBLE = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />'
local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" />'
local SINGLE_GAP = '<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto" />'
local SINGLE_BREAK = '<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" />'
local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'))
end

local function para(ppr, text, rpr)
  local r = ''
  if text and text ~= '' then
    r = '<w:r>' .. (rpr and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
        '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. r .. '</w:p>'
end

local function cell(width, tcpr, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa" />' .. tcpr .. '</w:tcPr>' .. paras .. '</w:tc>'
end

local function table_xml(grid, rows)
  local cols = ''
  local total = 0
  for _, w in ipairs(grid) do
    cols = cols .. '<w:gridCol w:w="' .. w .. '" />'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa" /><w:tblLayout w:type="fixed" />' ..
      '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>' ..
      '<w:tblGrid>' .. cols .. '</w:tblGrid><w:tr>' .. rows .. '</w:tr></w:tbl>'
end

local function str(v)
  return v and pandoc.utils.stringify(v) or ''
end

local function roman(n)
  local out = ''
  for _, v in ipairs({ { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- The caption: parties at left (each name and designation on its own single-spaced line, "v." between the
-- parties), the case number at right. Column widths: party column 3.2 in, 0.2 in gutter, rest.
local function caption(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then table.insert(left, 'v.') end
    for _, n in ipairs(p.names) do table.insert(left, str(n)) end
    table.insert(left, str(p.designation))
  end
  local lparas = ''
  for _, line in ipairs(left) do lparas = lparas .. para(SINGLE_GAP, line) end
  local rparas = para(SINGLE .. '<w:ind w:left="144" />', 'Case No. ' .. str(meta.case_number))
  return table_xml({ 4608, 288, 4464 },
    cell(4608, '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000" /><w:right w:val="single" w:sz="6" w:space="0" w:color="000000" /></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="200" w:type="dxa" /><w:bottom w:w="160" w:type="dxa" /></w:tcMar>', lparas) ..
    cell(288, '', para(SINGLE, '')) ..
    cell(4464, '', rparas))
end

-- The signature block: "Dated:" (when the sample gives a date) at left; "Respectfully submitted," the firm, the
-- "/s/" line and the signer, then the lines (bar number, address, telephone, fax, e-mail, "Attorneys for ...") at right.
local function signature(meta)
  local sig = meta.signature
  local right = para(SINGLE_BREAK, 'Respectfully submitted,')
  for _, line in ipairs(sig.firm or {}) do right = right .. para(SINGLE_GAP, str(line)) end
  right = right .. para(SINGLE_BREAK, '')
  right = right .. para(SINGLE_GAP, '/s/ ' .. str(sig.signer))
  for _, line in ipairs(sig.lines or {}) do right = right .. para(SINGLE_GAP, str(line)) end
  local left = para(SINGLE, meta.date and ('Dated: ' .. str(meta.date)) or '')
  return table_xml({ 3744, 288, 5328 }, cell(3744, '', left) .. cell(288, '', para(SINGLE, '')) .. cell(5328, '', right))
end

-- Headings: the numbers (I., A., 1.) are typed here, not by the author. A "~ " marker makes a level 1 heading
-- unnumbered. A level 2 or 3 number is followed by a tab (the heading style hangs the text at 0.5 in).
local h1, h2, h3 = 0, 0, 0

function Header(el)
  if el.level > 3 then error('brief.lua: headings deeper than level 3 are not supported') end
  local first = el.content[1]
  local unnumbered = first and first.t == 'Str' and first.text == '~'
  if unnumbered then
    table.remove(el.content, 1)
    if el.content[1] and el.content[1].t == 'Space' then table.remove(el.content, 1) end
  end
  if el.level == 1 then
    if not unnumbered then
      h1 = h1 + 1
      h2, h3 = 0, 0
      table.insert(el.content, 1, pandoc.Space())
      table.insert(el.content, 1, pandoc.Str(roman(h1) .. '.'))
    end
  elseif el.level == 2 then
    h2 = h2 + 1
    h3 = 0
    table.insert(el.content, 1, TAB)
    table.insert(el.content, 1, pandoc.Str(string.char(64 + h2) .. '.'))
  else
    h3 = h3 + 1
    table.insert(el.content, 1, TAB)
    table.insert(el.content, 1, pandoc.Str(h3 .. '.'))
  end
  return el
end

-- Table cells: single-spaced, 11 pt (the typst template sets tables smaller than body text).
function Table(el)
  return el:walk({
    Plain = function(p)
      return pandoc.Div({ pandoc.Para(p.content) }, { ['custom-style'] = 'Table Text' })
    end,
  })
end

-- Lists: (1), (2), ...
function OrderedList(el)
  el.listAttributes = pandoc.ListAttributes(1, pandoc.Decimal, pandoc.TwoParens)
  return el
end

function Pandoc(doc)
  local m = doc.meta
  local blocks = {}
  local function raw(xml) table.insert(blocks, pandoc.RawBlock('openxml', xml)) end
  local function blank() raw(para(DOUBLE, '')) end
  local function centered(text)
    raw(para(DOUBLE .. '<w:jc w:val="center" />', text))
  end

  -- Cover: court title (three lines), the caption, the centered bold title of the paper.
  centered('IN THE UNITED STATES DISTRICT COURT')
  centered('FOR THE EASTERN DISTRICT OF ARKANSAS')
  if m.division then centered(str(m.division):upper()) end
  blank()
  raw(caption(m))
  raw(para(DOUBLE, ''))
  raw(para(DOUBLE .. '<w:jc w:val="center" />', str(m.brief_title), '<w:b /><w:bCs />'))
  blank()

  for _, b in ipairs(doc.blocks) do table.insert(blocks, b) end

  blank()
  raw(signature(m))
  return pandoc.Pandoc(blocks, m)
end
