-- District of Idaho bankruptcy court, motion or brief in a contested matter: pandoc filter for the docx engine.
-- Mirrors typst/idb-motion-brief.typ, from the same markdown contract (see ../README.md).
-- Written here: the counsel block, the court heading, the caption table (a vertical rule between the
-- party column and the case-number column), the title, the lead-in, the numbered paragraphs, the lettered
-- items, the dated line and the signature block. Body text is pandoc's, styled by the custom styles that
-- make-reference.sh adds to reference.docx. Nothing case-specific is written in this file. Page setup and
-- fonts live in reference.docx.
-- Known gaps (docs/DOCX.md; see the Engines section of ../README.md): the caption rule is a table border,
-- and the numbers are typed text, not Word list numbering.

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("idb-motion-brief: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- One WordprocessingML paragraph. o: spacing (xml attrs), ind (xml attrs), jc, bold.
local function xpara(s, style, o)
  o = o or {}
  local p = '<w:pPr><w:pStyle w:val="' .. style .. '" />'
  if o.spacing then p = p .. '<w:spacing ' .. o.spacing .. ' />' end
  if o.ind then p = p .. '<w:ind ' .. o.ind .. ' />' end
  if o.jc then p = p .. '<w:jc w:val="' .. o.jc .. '" />' end
  p = p .. '</w:pPr>'
  local r = ''
  if s ~= '' then
    r = '<w:r>' .. (o.bold and '<w:rPr><w:b /></w:rPr>' or '') .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
  end
  return '<w:p>' .. p .. r .. '</w:p>'
end

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab /></w:r>')

-- Caption: left cell = debtor(s) under "In re:"; right cell = case identifiers.
-- Widths: 3.4 in party column (4896 twips), the rest of the 6.5 in text block (4464 twips).
local function caption_table(m)
  local left, right = {}, {}
  local pad_r = 'w:right="288"'
  left[#left + 1] = xpara('In re:', 'CaptionCell', { ind = pad_r, spacing = 'w:before="0" w:after="156"' })
  for _, n in ipairs(m.debtors.names) do
    left[#left + 1] = xpara(text(n), 'CaptionCell', { ind = pad_r })
  end
  left[#left + 1] = xpara(text(m.debtors.designation), 'CaptionCell', { ind = pad_r, jc = 'center', spacing = 'w:before="60" w:after="0"' })

  local rightInd = 'w:left="432"'
  right[#right + 1] = xpara('Case No. ' .. text(m.case_number), 'CaptionCell', { ind = rightInd, spacing = 'w:before="156" w:after="234"' })
  right[#right + 1] = xpara('Chapter ' .. text(m.chapter), 'CaptionCell', { ind = rightInd, spacing = 'w:before="0" w:after="0"' })

  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" />'
    .. '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896" /><w:gridCol w:w="4464" /></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa" /><w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000" /></w:tcBorders></w:tcPr>'
    .. table.concat(left)
    .. '</w:tc><w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa" /></w:tcPr>'
    .. table.concat(right)
    .. '</w:tc></w:tr></w:tbl>'
end

-- A paragraph of pandoc inlines in a custom style (the style carries the indents and spacing).
local function styled(inlines, style)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr('', {}, { ['custom-style'] = style }))
end

local function plain_text_styled(s, style)
  return pandoc.RawBlock('openxml', xpara(s, style))
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- counsel block: upper left, single spaced, from the top margin (LBR 5005-1(c)(1))
  for _, l in ipairs(need(m, 'counsel')) do add(plain_text_styled(text(l), 'Counsel')) end

  -- court heading
  add(pandoc.RawBlock('openxml', xpara('UNITED STATES BANKRUPTCY COURT', 'CourtHead', { spacing = 'w:before="240" w:after="0"', jc = 'center' })))
  add(pandoc.RawBlock('openxml', xpara('FOR THE DISTRICT OF IDAHO', 'CourtHead', { jc = 'center' })))

  add(pandoc.RawBlock('openxml', caption_table(m)))

  -- title, centered bold caps (typst: upper(meta.title))
  add(pandoc.RawBlock('openxml', xpara(string.upper(text(need(m, 'title'))), 'CoverTitle')))

  -- lead-in paragraph (first-line indent, like every numbered paragraph)
  add(styled(need(m, 'lead_in'), 'Allegation'))

  -- body: `# ` centered bold caps, `## ` centered bold, `### ` bold at the left (pandoc headings, styled in
  -- reference.docx); `- ` lettered items; `> ` block quote (pandoc BlockText); `~ ` unnumbered continuation;
  -- `WHEREFORE` and footnote `¹` paragraphs unnumbered; any other paragraph is a numbered paragraph.
  -- Numbering stops after the PRAYER and CERTIFICATE headings.
  local num, num_on = 0, true
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' then
      local t = pandoc.utils.stringify(b.content)
      if b.level == 1 and (t:sub(1, 6) == 'PRAYER' or t:sub(1, 11) == 'CERTIFICATE') then num_on = false end
      add(b)
    elseif b.t == 'Para' or b.t == 'Plain' then
      local first = b.content[1]
      local s = first and pandoc.utils.stringify(first) or ''
      if s == '~' then
        local rest = pandoc.List(b.content)
        rest:remove(1)
        if rest[1] and rest[1].t == 'Space' then rest:remove(1) end
        add(styled(rest, 'Continuation'))
      elseif s:sub(1, 9) == 'WHEREFORE' or s:sub(1, 2) == '¹' then
        add(styled(b.content, 'Allegation'))
      elseif num_on then
        num = num + 1
        local inl = pandoc.List({ pandoc.Str(tostring(num) .. '.'), TAB })
        inl:extend(b.content)
        add(styled(inl, 'Allegation'))
      else
        add(styled(b.content, 'Allegation'))
      end
    elseif b.t == 'BulletList' then
      for i, item in ipairs(b.content) do
        local inl = pandoc.List({ pandoc.Str('(' .. LETTERS:sub(i, i) .. ')'), TAB })
        for j, blk in ipairs(item) do
          if j > 1 then inl:insert(pandoc.Space()) end
          if blk.content then inl:extend(blk.content) end
        end
        add(styled(inl, 'Lettered'))
      end
    else
      add(b)
    end
  end

  -- the dated line and the firm signature block, the way the filed brief closes (typst: signature-block)
  add(plain_text_styled(text(need(m, 'dated')), 'Continuation'))
  local s = need(m, 'signature')
  for _, l in ipairs(s.lines_above or {}) do add(plain_text_styled(text(l), 'SigBlock')) end
  add(pandoc.RawBlock('openxml', xpara('', 'SigBlock', { spacing = 'w:before="120" w:after="0"' })))
  add(plain_text_styled('By /s/ ' .. text(s.signer), 'SigBlock'))
  add(plain_text_styled(text(s.signer), 'SigBlock'))

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
