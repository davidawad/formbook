-- meb-adversary-complaint.lua: pandoc filter for the D. Me. adversary complaint Word template (docx/reference.docx).
-- Run by tools/render-docx.sh. Builds the cover, the caption, the numbered paragraphs, the relief, the signature
-- block and the certificate from the frontmatter, in the order of typst/meb-adversary-complaint.typ. Styles are
-- the "Pleading ..." styles that docx/make-reference.sh writes into reference.docx.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
-- Caption and signature fields are set as plain text (their markdown emphasis is dropped; the typst template keeps it).

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')

-- The caption table: 6.5 in of text width in twentieths of a point, split 3.4 in / 3.1 in as in the typst template.
local CAPTION_LEFT = 4896
local CAPTION_RIGHT = 4464

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function text(v)
  return pandoc.utils.stringify(v)
end

-- A metadata value that is a list of strings (or one string) as a Lua list of plain strings.
local function strings(v)
  local out = {}
  if v == nil then
    return out
  end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then
    for _, x in ipairs(v) do
      out[#out + 1] = text(x)
    end
  else
    out[#out + 1] = text(v)
  end
  return out
end

local function append(list, more)
  for _, s in ipairs(more) do
    list[#list + 1] = s
  end
  return list
end

-- A metadata value that holds markdown (a string, or several paragraphs) as a list of blocks.
local function meta_blocks(v)
  if v == nil then
    return {}
  end
  if v.t == 'MetaBlocks' then
    return v
  end
  if v.t == 'MetaInlines' then
    return { pandoc.Para(v) }
  end
  return { pandoc.Para({ pandoc.Str(text(v)) }) }
end

local function styled(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr('', {}, { ['custom-style'] = name }))
end

local function styled_text(name, s)
  return styled(name, { pandoc.Para({ pandoc.Str(s) }) })
end

local function gap()
  return styled('Pleading Gap', { pandoc.Para({}) })
end

-- One caption cell: its lines as single-spaced paragraphs, with the borders and margins the typst box draws.
local function cell(width, lines, borders, margins)
  local paras = {}
  for _, s in ipairs(lines) do
    paras[#paras + 1] = '<w:p><w:pPr><w:pStyle w:val="PleadingSingle"/></w:pPr><w:r><w:t xml:space="preserve">' ..
      esc(s) .. '</w:t></w:r></w:p>'
  end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. borders .. margins .. '</w:tcPr>' ..
    table.concat(paras) .. '</w:tc>'
end

local LEFT_BORDERS = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local RIGHT_BORDERS = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local LEFT_MARGINS = '<w:tcMar><w:top w:w="120" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/>' ..
  '<w:right w:w="200" w:type="dxa"/></w:tcMar>'
local RIGHT_MARGINS = '<w:tcMar><w:top w:w="120" w:type="dxa"/><w:left w:w="288" w:type="dxa"/>' ..
  '<w:bottom w:w="200" w:type="dxa"/></w:tcMar>'

-- The caption: the main case (debtor, chapter, case number) and, below it, the adversary proceeding when the
-- sample has `parties`. Each row is a left cell (names and designations) and a right cell (case numbers).
local function caption(m)
  local rows = {}
  local left = { 'In re:' }
  append(left, strings(m.debtor.names))
  left[#left + 1] = text(m.debtor.designation)
  rows[#rows + 1] = { left, { 'Chapter ' .. text(m.chapter), 'Case No. ' .. text(m.case_number) } }
  if m.parties ~= nil then
    local parties = {}
    for k, p in ipairs(m.parties) do
      if k > 1 then
        parties[#parties + 1] = 'v.'
      end
      append(parties, strings(p.names))
      parties[#parties + 1] = text(p.designation)
    end
    rows[#rows + 1] = { parties, { 'Adv. Proc. No. ' .. text(m.adv_number) } }
  end
  local trs = {}
  for _, r in ipairs(rows) do
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      cell(CAPTION_LEFT, r[1], LEFT_BORDERS, LEFT_MARGINS) ..
      cell(CAPTION_RIGHT, r[2], RIGHT_BORDERS, RIGHT_MARGINS) .. '</w:tr>'
  end
  return pandoc.RawBlock('openxml', '<w:tbl><w:tblPr><w:tblW w:w="' .. (CAPTION_LEFT + CAPTION_RIGHT) ..
    '" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>' ..
    '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>' ..
    '</w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAPTION_LEFT .. '"/><w:gridCol w:w="' ..
    CAPTION_RIGHT .. '"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>')
end

-- The date and signature block: "Dated:" and "/s/" share a line, the signer's lines follow at 3 in.
local function signature(date, signer, lines)
  local first = pandoc.Para({ pandoc.Str('Dated: ' .. date), TAB, pandoc.Str('/s/ ' .. signer) })
  local out = { styled('Pleading Signature', { first }) }
  for i, s in ipairs(lines) do
    local name = i == #lines and 'Pleading Signature Last' or 'Pleading Signature Line'
    out[#out + 1] = styled_text(name, s)
  end
  return out
end

local function letter(i)
  return string.char(96 + i)
end

local function upper_inlines(inlines)
  return pandoc.Inlines(inlines):walk({
    Str = function(s)
      return pandoc.Str(s.text:upper())
    end,
  })
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(list)
    for _, b in ipairs(list) do
      out[#out + 1] = b
    end
  end

  -- Cover: court name, caption, title of the paper (FRBP 7010; LBR 7003-1(a)).
  if m.without_hearing ~= nil and text(m.without_hearing) == 'true' then
    -- D. Me. LBR 9013-3: the legend goes in the upper right corner of the first page.
    add({ styled_text('Pleading Legend', 'RELIEF REQUESTED WITHOUT A HEARING'), gap() })
  end
  add({ styled_text('Pleading Court', 'UNITED STATES BANKRUPTCY COURT'),
    styled_text('Pleading Court', 'DISTRICT OF MAINE'), gap() })
  add({ caption(m), gap() })
  add({ styled_text('Pleading Title', text(m.title):upper()) })

  -- Opening paragraphs: unnumbered, indented.
  for _, b in ipairs(meta_blocks(m.lead_in)) do
    if b.t == 'Para' then
      add({ styled('Pleading Body', { b }) })
    end
  end

  -- Body: headings as typed (level 1 in capitals for the complaint, as the typst template sets it); paragraphs
  -- numbered 1, 2, ... (Fed. R. Civ. P. 10(b)); a list lettered (a), (b), ...
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' then
      local content = b.content
      if b.level == 1 then
        content = upper_inlines(content)
      end
      add({ pandoc.Header(b.level, content, b.attr) })
    elseif b.t == 'Para' or b.t == 'Plain' then
      n = n + 1
      local inlines = pandoc.List({ pandoc.Str(n .. '.'), TAB })
      inlines:extend(b.content)
      add({ styled('Pleading Numbered', { pandoc.Para(inlines) }) })
    elseif b.t == 'BulletList' or b.t == 'OrderedList' then
      for i, item in ipairs(b.content) do
        local inlines = pandoc.List({ pandoc.Str('(' .. letter(i) .. ')'), TAB })
        inlines:extend(item[1].content)
        add({ styled('Pleading List', { pandoc.Para(inlines) }) })
      end
    else
      add({ b })
    end
  end

  -- The closing paragraph stays on the page with the signature block it leads into.
  if m.wherefore ~= nil then
    for _, b in ipairs(meta_blocks(m.wherefore)) do
      add({ styled('Pleading Relief', { b }) })
    end
  end
  add(signature(text(m.date), text(m.signature.signer), strings(m.signature.lines)))

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
