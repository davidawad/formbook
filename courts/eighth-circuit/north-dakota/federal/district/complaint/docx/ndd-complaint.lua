-- pandoc filter for the ndd complaint (docx engine). Mirrors typst/ndd-complaint.typ: the cover (court title,
-- caption table with a column of ")" marks, case number and title), numbered allegations (Fed. R. Civ. P. 10(b)),
-- lettered lists (a), (b), ..., and the signature block. Frontmatter comes from the sample, never from this file.
-- Used by tools/render-docx.sh through docx/reference.docx; see ../README.md "Engines".

-- Measures (twips; 1 in = 1440): text width 9360; caption party column 4896 (3.4 in), ")" column 432 (0.3 in),
-- right column 4032. Body and headings double (480 exact); caption and signature single (276 exact).
local BODY = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>'
local SIG_LEFT = 4680 -- signature block: 3.25 in from the margin
local CAP_INSET = 288 -- right column of the caption: 0.2 in

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text_of(v)
  return pandoc.utils.stringify(v)
end

-- One paragraph as XML. ppr: paragraph properties; rpr: run properties (may be "").
local function px(text, ppr, rpr)
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr><w:r><w:rPr>' .. (rpr or '') ..
    '</w:rPr><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r></w:p>'
end

local function blank(extra)
  return '<w:p><w:pPr>' .. BODY .. (extra or '') .. '</w:pPr></w:p>'
end

local function raw(xml)
  return pandoc.RawBlock('openxml', xml)
end

local function ind(left)
  return '<w:ind w:left="' .. left .. '"/>'
end

local function caption(meta)
  local left, paren = {}, {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then table.insert(left, 'v.') end
    for _, n in ipairs(p.names) do table.insert(left, text_of(n)) end
    local d = text_of(p.designation)
    if d ~= '' then table.insert(left, d) end
  end
  local lparas, pparas = {}, {}
  for i, s in ipairs(left) do
    table.insert(lparas, px(s, SINGLE .. '<w:jc w:val="left"/>'))
    table.insert(pparas, px(')', SINGLE))
  end
  local case_no = text_of(meta.case_number)
  if case_no == '' then case_no = '____________' end
  local rparas = {
    px('Case No. ' .. case_no, SINGLE .. ind(CAP_INSET)),
    blank(ind(CAP_INSET)),
    px(text_of(meta.title), SINGLE .. ind(CAP_INSET), '<w:b/><w:bCs/><w:caps/>'),
  }
  if meta.jury_demand == true then
    table.insert(rparas, px('JURY DEMAND', '<w:spacing w:before="120" w:after="0" w:line="276" w:lineRule="exact"/>' .. ind(CAP_INSET), '<w:b/><w:bCs/>'))
  end
  local function cell(w, paras)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(paras) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '</w:tblPr><w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="432"/><w:gridCol w:w="4032"/></w:tblGrid><w:tr>' ..
    cell(4896, lparas) .. cell(432, pparas) .. cell(4032, rparas) .. '</w:tr></w:tbl>'
end

local function cover(meta)
  local out = {}
  for _, key in ipairs({ 'court', 'district', 'division' }) do
    table.insert(out, raw(px(text_of(meta[key]), SINGLE .. '<w:jc w:val="center"/>', '<w:b/><w:bCs/><w:caps/>')))
  end
  table.insert(out, raw(blank()))
  table.insert(out, raw(caption(meta)))
  table.insert(out, raw(blank()))
  return out
end

-- The signature block does not split across pages (typst: breakable: false). It is one borderless table row that
-- may not break (cantSplit); keepNext alone was not honoured by LibreOffice across a long signature chain. An
-- empty paragraph follows, since a table cannot end a block of content.
local function signature(meta)
  local items = {}
  local function add(text, ppr)
    table.insert(items, { text = text, ppr = ppr })
  end
  if meta.date and text_of(meta.date) ~= '' then
    add('', BODY)
    add('Dated: ' .. text_of(meta.date), SINGLE)
  end
  add('', BODY)
  for _, s in ipairs(meta.signature.firm) do add(text_of(s), SINGLE .. ind(SIG_LEFT)) end
  add('', BODY)
  for _, s in ipairs(meta.signature.lines) do add(text_of(s), SINGLE .. ind(SIG_LEFT)) end
  local paras = {}
  for _, it in ipairs(items) do
    table.insert(paras, px(it.text, it.ppr))
  end
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '</w:tblPr><w:tblGrid><w:gridCol w:w="9360"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr><w:tc><w:tcPr><w:tcW w:w="9360" w:type="dxa"/></w:tcPr>' ..
    table.concat(paras) .. '</w:tc></w:tr></w:tbl>'
  return { raw(tbl), raw(blank()) }
end

local function is_wherefore(b)
  return b.t == 'Para' and text_of(b):match('^WHEREFORE') ~= nil
end

local function num_run(s)
  return pandoc.RawInline('openxml', '<w:r><w:t xml:space="preserve">' .. s .. '</w:t></w:r><w:r><w:tab/></w:r>')
end

function Pandoc(doc)
  local meta = doc.meta
  assert(meta.division, 'ndd-complaint: the caption must designate the division (Civil Rule 3.1(A))')
  local out = cover(meta)
  if meta.lead_in then
    table.insert(out, pandoc.Para(meta.lead_in))
  end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Para' and not is_wherefore(b) then
      n = n + 1
      table.insert(b.content, 1, num_run(n .. '.'))
      table.insert(out, b)
    elseif b.t == 'OrderedList' then
      -- Lettered sub-paragraphs: "(a)" at 0.5 in, text at 1 in (hanging, custom style "Lettered").
      for i, item in ipairs(b.content) do
        local blocks = pandoc.List(item)
        local first = blocks[1]
        if first and (first.t == 'Para' or first.t == 'Plain') then
          table.insert(first.content, 1, num_run('(' .. string.char(96 + i) .. ')'))
        end
        table.insert(out, pandoc.Div(blocks, { ['custom-style'] = 'Lettered' }))
      end
    else
      table.insert(out, b)
    end
  end
  for _, b in ipairs(signature(meta)) do table.insert(out, b) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
