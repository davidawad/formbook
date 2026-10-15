-- complaint.lua (docx engine): what the Word output adds to pandoc's default conversion, so that it reads like the
-- typst template (../typst/ared-complaint.typ). The cover, the lead-in and the signature block are built from the
-- sample's frontmatter as raw WordprocessingML (pandoc has no caption table); the body paragraphs are numbered here.
--   * cover: court title, caption (party column closed by a rule at right and bottom), the title of the paper;
--   * numbered paragraphs (Fed. R. Civ. P. 10(b)): "1." then a tab; a paragraph starting "~ " is unnumbered;
--   * lettered lists "(a)", "(b)", ...; the lead-in paragraph; the signature block.
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

-- The caption: parties at left (each name and designation on its own single-spaced line, "v." between the
-- parties), the case number and the title at right. Column widths: party column 3.2 in, 0.2 in gutter, rest.
local function caption(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then table.insert(left, 'v.') end
    for _, n in ipairs(p.names) do table.insert(left, str(n)) end
    table.insert(left, str(p.designation))
  end
  local lparas, rparas = '', ''
  for _, line in ipairs(left) do lparas = lparas .. para(SINGLE_GAP, line) end
  rparas = para(SINGLE_BREAK .. '<w:ind w:left="144" />', 'Case No. ' .. str(meta.case_number))
  rparas = rparas .. para('<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:left="144" />',
    str(meta.brief_title), '<w:b /><w:bCs />')
  if meta.jury_demand == true then
    rparas = rparas .. para(SINGLE_BREAK .. '<w:ind w:left="144" />', 'DEMAND FOR JURY TRIAL', '<w:b /><w:bCs />')
  end
  return table_xml({ 4608, 288, 4464 },
    cell(4608, '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000" /><w:right w:val="single" w:sz="6" w:space="0" w:color="000000" /></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="200" w:type="dxa" /><w:bottom w:w="160" w:type="dxa" /></w:tcMar>', lparas) ..
    cell(288, '', para(SINGLE, '')) ..
    cell(4464, '', rparas))
end

-- The signature block: "Dated:" at left; "Respectfully submitted," the firm, "By: /s/" and the signer, then the
-- lines (bar number, address, telephone, e-mail, "Attorneys for ..."), at right.
local function signature(meta)
  local sig = meta.signature
  local right = para(SINGLE_BREAK, 'Respectfully submitted,')
  for _, line in ipairs(sig.firm or {}) do right = right .. para(SINGLE_GAP, str(line)) end
  right = right .. para(SINGLE_BREAK, '')
  right = right .. para(SINGLE_GAP, 'By: /s/ ' .. str(sig.signer))
  for _, line in ipairs(sig.lines or {}) do right = right .. para(SINGLE_GAP, str(line)) end
  local left = para(SINGLE, meta.date and ('Dated: ' .. str(meta.date)) or '')
  return table_xml({ 3744, 288, 5328 }, cell(3744, '', left) .. cell(288, '', para(SINGLE, '')) .. cell(5328, '', right))
end

-- Lettered lists: (a), (b), ...
function OrderedList(el)
  el.listAttributes = pandoc.ListAttributes(1, pandoc.LowerAlpha, pandoc.TwoParens)
  return el
end

function Pandoc(doc)
  local m = doc.meta
  local blocks = {}
  local function raw(xml) table.insert(blocks, pandoc.RawBlock('openxml', xml)) end
  local function blank() raw(para(DOUBLE, '')) end

  -- Cover: court title (two lines, plus the division if the sample gives one), then the caption.
  raw(para(DOUBLE .. '<w:jc w:val="center" />', 'UNITED STATES DISTRICT COURT', '<w:b /><w:bCs />'))
  raw(para(DOUBLE .. '<w:jc w:val="center" />', 'EASTERN DISTRICT OF ARKANSAS', '<w:b /><w:bCs />'))
  if m.division then
    raw(para(DOUBLE .. '<w:jc w:val="center" />', str(m.division):upper(), '<w:b /><w:bCs />'))
  end
  blank()
  raw(caption(m))
  blank()

  -- The lead-in (an unnumbered opening paragraph), as markdown.
  if m.lead_in then
    for _, b in ipairs(pandoc.read(str(m.lead_in), 'markdown+smart').blocks) do table.insert(blocks, b) end
  end

  -- Body: numbered paragraphs; a paragraph that starts "~ " is unnumbered (its marker is removed).
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Para' then
      local first = b.content[1]
      if first and first.t == 'Str' and first.text == '~' then
        table.remove(b.content, 1)
        if b.content[1] and b.content[1].t == 'Space' then table.remove(b.content, 1) end
      else
        n = n + 1
        table.insert(b.content, 1, TAB)
        table.insert(b.content, 1, pandoc.Str(n .. '.'))
      end
    end
    table.insert(blocks, b)
  end

  blank()
  raw(signature(m))
  return pandoc.Pandoc(blocks, m)
end
