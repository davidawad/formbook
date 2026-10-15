-- msnd-complaint.lua (docx engine). What the Word output adds to pandoc's conversion, so that it matches
-- typst/msnd-complaint.typ (see README.md, "Engines"):
--   * the cover, built from the sample's frontmatter: the court-title lines, the caption table (the party column
--     closed by a rule at right and bottom; "CIVIL ACTION NO.:" and the case number; "JURY TRIAL DEMANDED" when
--     jury_demand is set), and the title;
--   * the lead-in, which is not numbered; the numbered paragraphs (Fed. R. Civ. P. 10(b)), numbered here, not by
--     Word's list numbering; a paragraph that starts with "WHEREFORE" is the unnumbered lead-in of the prayer;
--   * the prayer list, as hanging-indent paragraphs ("1." at 0.5 in, the text at 0.9 in);
--   * level 1 headings in capitals; the jury demand heading and paragraph;
--   * the signature block (Dated; Respectfully submitted; the signer and counsel lines) as a borderless table.
-- Nothing case-specific is written here: every word comes from the sample. Raw OpenXML is used where Word needs
-- borders or a table layout that pandoc does not express (docs/DOCX.md, "Use the Word-native feature").
-- The sample's own footnotes are pandoc footnotes; they need no code here.

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function text_of(v)
  return pandoc.utils.stringify(v)
end

-- Paragraph properties in schema order: keepNext, spacing, ind, jc. Lines are exact: 480 (24 pt, double) for body and
-- title text, 280 (14 pt, single: typst single leading is about 14 pt for this face) for the cover, caption and signature.
local function ppr(o)
  local s = '<w:pPr>'
  if o.keep then s = s .. '<w:keepNext/>' end
  local rule = "exact"
  s = s .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>',
    o.before or 0, o.after or 0, o.line or 280, rule)
  if o.left then s = s .. string.format('<w:ind w:left="%d"/>', o.left) end
  if o.jc then s = s .. string.format('<w:jc w:val="%s"/>', o.jc) end
  return s .. '</w:pPr>'
end

local function run(text, bold)
  local rpr = bold and '<w:rPr><w:b/><w:bCs/></w:rPr>' or ''
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function para(o, text, bold)
  return '<w:p>' .. ppr(o) .. run(text, bold) .. '</w:p>'
end

-- A table with no borders, fixed column widths in twips (the page text width is 9360).
local function table_xml(grid, row)
  local cols, total = {}, 0
  for _, w in ipairs(grid) do
    cols[#cols + 1] = string.format('<w:gridCol w:w="%d"/>', w)
    total = total + w
  end
  return '<w:tbl><w:tblPr>' .. string.format('<w:tblW w:w="%d" w:type="dxa"/>', total) ..
    '<w:tblInd w:w="0" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '</w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. row .. '</w:tr></w:tbl>'
end

local function cell(width, paras, tcpr_extra)
  return string.format('<w:tc><w:tcPr><w:tcW w:w="%d" w:type="dxa"/>%s</w:tcPr>%s</w:tc>',
    width, tcpr_extra or '', paras)
end

local EMPTY_CELL = '<w:p/>'

local function court_title(meta)
  local lines = { 'IN THE UNITED STATES DISTRICT COURT', 'FOR THE NORTHERN DISTRICT OF MISSISSIPPI' }
  if meta.division and text_of(meta.division) ~= '' then
    lines[#lines + 1] = pandoc.text.upper(text_of(meta.division)) .. ' DIVISION'
  end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = para({ line = 280, after = (i == #lines) and 480 or 0, jc = 'center' }, l, true)
  end
  return table.concat(out)
end

-- The caption: party column (3.25 in) with a rule at right and bottom, a 0.25 in gutter, the case column (3.0 in).
local function caption(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = 'v.' end
    for _, n in ipairs(p.names) do left[#left + 1] = text_of(n) end
    left[#left + 1] = text_of(p.designation)
  end
  local left_paras = {}
  for _, l in ipairs(left) do left_paras[#left_paras + 1] = para({ line = 280, after = 120 }, l) end
  local rules = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="240" w:type="dxa"/></w:tcMar>'

  local right = { para({ line = 280, after = 120, left = 288 }, 'CIVIL ACTION NO.:') }
  right[#right + 1] = para({ line = 280, after = 120, left = 288 }, text_of(meta.case_number))
  if meta.jury_demand then
    right[#right + 1] = para({ line = 280, before = 240, left = 288 }, 'JURY TRIAL DEMANDED')
  end

  return table_xml({ 4680, 360, 4320 },
    cell(4680, table.concat(left_paras), rules) ..
    cell(360, EMPTY_CELL) ..
    cell(4320, table.concat(right)))
end

-- The case-caption title: centered, bold, double-spaced, one blank line above and below.
local function title(meta)
  return para({ line = 480, before = 480, after = 480, jc = 'center' }, text_of(meta.title), true)
end

-- Signature block: "Dated" at 2.6 in, a 0.2 in gutter, then the signing counsel at 3.7 in.
local function signature(meta)
  local sig = meta.signature
  local left = para({ line = 280, before = 480 }, 'Dated: ' .. text_of(meta.date))
  local right = { para({ line = 280, before = 480, after = 480 }, 'Respectfully submitted,') }
  local names = { 'By: /s/ ' .. text_of(sig.signer) }
  for _, c in ipairs(sig.counsel) do names[#names + 1] = text_of(c) end
  for _, n in ipairs(names) do right[#right + 1] = para({ line = 280, after = 120 }, n) end
  return table_xml({ 3744, 288, 5328 },
    cell(3744, left) .. cell(288, EMPTY_CELL) .. cell(5328, table.concat(right))) .. '<w:p/>'
end

local function caps_str(s)
  return pandoc.Str(pandoc.text.upper(s.text))
end

-- A space before a footnote mark is dropped, as the typst template does (its markdown renderer trims the space before
-- a mark). Kept, it lets Word wrap the mark onto a line of its own.
local function tight_marks(inlines)
  local out = {}
  for i, el in ipairs(inlines) do
    local nxt = inlines[i + 1]
    if not (el.t == 'Space' and nxt and nxt.t == 'Note') then out[#out + 1] = el end
  end
  return pandoc.Inlines(out)
end

function Pandoc(doc)
  doc = doc:walk({ Inlines = tight_marks })
  local m = doc.meta
  local out = {
    pandoc.RawBlock('openxml', court_title(m)),
    pandoc.RawBlock('openxml', caption(m)),
    pandoc.RawBlock('openxml', title(m)),
  }
  if m.lead_in then
    out[#out + 1] = pandoc.Para(pandoc.Inlines(m.lead_in))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' then
      if b.level == 1 then b = b:walk({ Str = caps_str }) end
      out[#out + 1] = b
    elseif b.t == 'Para' then
      if text_of(b):match('^WHEREFORE') then
        out[#out + 1] = b
      else
        n = n + 1
        out[#out + 1] = pandoc.Para({ pandoc.Str(string.format('%d.', n)), TAB, table.unpack(b.content) })
      end
    elseif b.t == 'OrderedList' then
      local start = b.listAttributes.start
      for i, item in ipairs(b.content) do
        if #item ~= 1 then
          error('msnd-complaint.lua: a list item with more than one block is not supported')
        end
        local p = pandoc.Para({ pandoc.Str(string.format('%d.', start + i - 1)), TAB, table.unpack(item[1].content) })
        out[#out + 1] = pandoc.Div({ p }, { ['custom-style'] = 'Prayer Item' })
      end
    else
      out[#out + 1] = b
    end
  end

  if m.jury_demand_text then
    out[#out + 1] = pandoc.Header(1, pandoc.Inlines({ pandoc.Str('JURY DEMAND') }))
    out[#out + 1] = pandoc.Para(pandoc.Inlines(m.jury_demand_text))
  end
  out[#out + 1] = pandoc.RawBlock('openxml', signature(m))

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
