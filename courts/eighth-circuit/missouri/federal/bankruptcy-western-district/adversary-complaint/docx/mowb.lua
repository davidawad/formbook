-- U.S. Bankruptcy Court, W.D. Missouri: adversary complaint, docx engine (pandoc Lua filter; see ../README.md,
-- "Engines", and docs/DOCX.md). The court title, caption, title, signature block and certificate of service are
-- written as OOXML paragraphs (raw, with explicit tab stops); the body uses the paragraph styles of reference.docx
-- (made by make-reference.sh). The rules and numbers are those of typst/mowb-*.typ. This file is identical in the
-- two doc-type folders except for DOCTYPE below.

local DOCTYPE = 'adversary-complaint'

local CFG = ({
  ['adversary-complaint'] = {
    numbered = true,         -- paragraphs numbered from the first heading on; the lead-in and WHEREFORE are not
    adv = 'Adv. Pro. No. ',  -- caption label of the adversary number
    h1_roman = false,        -- level-1 headings are unnumbered (centred, caps)
    h2 = 'roman',            -- level-2 headings: I., II., ... counted continuously
    respectfully = true,     -- "Respectfully submitted," above the firm name
    by = 'By: /s/ ',
    list = 'letters',        -- lists are lettered (a), (b), ...
    blank = 480,             -- one line pitch (24 pt), in twentieths of a point, for the blank lines
  },
  ['motion-brief'] = {
    numbered = false,        -- memorandum: no paragraph numbers
    adv = 'Adv. No. ',
    h1_roman = true,         -- level-1 headings: I., II., ...
    h2 = 'letters',          -- level-2 headings: A., B., ...; restarted in each section
    respectfully = false,
    by = '/s/ ',
    list = 'numbers',        -- lists are numbered 1., 2., ...
    blank = 400,
  },
})[DOCTYPE]

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')
local LETTERS = 'abcdefghijklmnopqrstuvwxyz'
local ITALIC = '<w:rPr><w:i/></w:rPr>'

-- ---- plain helpers

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function text(v)
  if v == nil then return '' end
  return pandoc.utils.stringify(v)
end

local function items(v)
  local out = {}
  for _, x in ipairs(v or {}) do out[#out + 1] = text(x) end
  return out
end

-- Markdown inline text (italics and the like) for the strings that may carry it.
local function md_inlines(s)
  return pandoc.read(s, 'markdown').blocks[1].content
end

local function roman(n)
  local vals = { { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }
  local s = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

local function prefix(block, s)
  table.insert(block.content, 1, TAB)
  table.insert(block.content, 1, pandoc.Str(s))
end

-- ---- OOXML paragraphs (pPr children in schema order: pStyle, tabs, spacing, ind, jc)

local function run(s, rpr)
  if s == '' then return '' end
  return '<w:r>' .. (rpr or '') .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

local function para(ppr, body)
  return pandoc.RawBlock('openxml', '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. body .. '</w:p>')
end

local function style(name)
  return '<w:pStyle w:val="' .. name .. '"/>'
end

local function blank()
  return para('<w:spacing w:before="0" w:after="0" w:line="' .. CFG.blank .. '" w:lineRule="exact"/>', '')
end

-- ---- caption (FRBP 7010, Official Form 416D; FRBP 9004(b); W.D. Mo. L.R. 17004-1(A))

local function court_block(meta)
  local out = {}
  for _, l in ipairs(items(meta.court)) do
    out[#out + 1] = para(style('CourtTitle'), run(l:upper()))
  end
  if text(meta.division) ~= '' then
    out[#out + 1] = para(style('CourtTitle'), run(text(meta.division):upper()))
  end
  out[#out + 1] = blank()
  return out
end

-- One caption line: the name column, a ")" at 3.8 in, then the number column at 4.15 in. Every line has
-- a ")" so the column runs unbroken, as in the typst grid.
local CAPTION_PPR = '<w:tabs><w:tab w:val="left" w:pos="5472"/><w:tab w:val="left" w:pos="5976"/></w:tabs>'
  .. '<w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/>'

local function caption_row(left, right, indent)
  local ind = indent and ('<w:ind w:left="' .. indent .. '"/>') or ''
  return para(CAPTION_PPR .. ind, run(left) .. '<w:r><w:tab/></w:r>' .. run(')') .. '<w:r><w:tab/></w:r>' .. run(right))
end

local function caption(meta)
  local plaintiffs, defendants = items(meta.plaintiffs), items(meta.defendants)
  local adv = text(meta.adv_number)
  adv = CFG.adv .. (adv ~= '' and adv or '____________')
  local out = {}
  local function row(l, r, ind)
    out[#out + 1] = caption_row(l, r, ind)
  end
  row('In re:', '')
  row('', '')
  row(text(meta.debtor):upper(), 'Case No. ' .. text(meta.case_number))
  row('', 'Chapter ' .. text(meta.chapter))
  if text(meta.judge) ~= '' then row('', text(meta.judge)) end
  row('Debtor.', '', 2160)
  row('', '')
  for i, p in ipairs(plaintiffs) do
    row(p:upper(), i == 1 and adv or '')
  end
  row(#plaintiffs > 1 and 'Plaintiffs,' or 'Plaintiff,', '', 2160)
  row('', '')
  row('v.', '')
  row('', '')
  for _, d in ipairs(defendants) do
    row(d:upper(), '')
  end
  row(#defendants > 1 and 'Defendants.' or 'Defendant.', '', 2160)
  return out
end

-- ---- signature block and certificate of service (W.D. Mo. L.R. 9011-4, 9013-3)

local function sig_line(s, ppr, rpr)
  return para(style('SignatureBlock') .. (ppr or ''), run(s, rpr))
end

local GROUP_GAP = '<w:spacing w:before="240" w:after="0" w:line="240" w:lineRule="auto"/>'

local function signature(meta)
  local sig = meta.signature
  local out = {}
  if text(meta.date) ~= '' then
    out[#out + 1] = para('<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>',
      run('Dated: ' .. text(meta.date)))
    out[#out + 1] = blank()
  end
  -- Each group is one column of the typst grid; the groups are stacked with a half line between them.
  local groups = {}
  if CFG.respectfully then groups[#groups + 1] = { { 'Respectfully submitted,' } } end
  local firm = {}
  for _, l in ipairs(items(sig.firm)) do firm[#firm + 1] = { l:upper() } end
  groups[#groups + 1] = firm
  groups[#groups + 1] = { { CFG.by .. text(sig.signer) }, { text(sig.signer) .. ', ' .. text(sig.bar) } }
  local last = {}
  for _, l in ipairs(items(sig.lines)) do last[#last + 1] = { l } end
  last[#last + 1] = { text(sig.role), true }
  groups[#groups + 1] = last
  for gi, g in ipairs(groups) do
    for li, ln in ipairs(g) do
      local gap = (li == 1 and gi > 1) and GROUP_GAP or nil
      out[#out + 1] = sig_line(ln[1], gap, ln[2] and ITALIC or nil)
    end
  end
  return out
end

local function certificate(meta)
  local cert, sig = meta.certificate, meta.signature
  local out = {}
  out[#out + 1] = para(style('CertificateHeading'), run('Certificate of Service'))
  out[#out + 1] = para(style('IndentedParagraph'),
    run('I certify that on ' .. text(cert.date) .. ', ' .. text(cert.manner) .. '.'))
  out[#out + 1] = blank()
  out[#out + 1] = sig_line('/s/ ' .. text(sig.signer))
  out[#out + 1] = sig_line(text(sig.signer))
  return out
end

-- ---- body

local function list_label(i)
  if CFG.list == 'letters' then return '(' .. LETTERS:sub(i, i) .. ')' end
  return i .. '.'
end

function Pandoc(doc)
  local meta = doc.meta
  doc.meta = pandoc.MetaMap({}) -- the frontmatter is printed by this filter; no pandoc title block

  local out = court_block(meta)
  for _, b in ipairs(caption(meta)) do out[#out + 1] = b end
  out[#out + 1] = blank()
  out[#out + 1] = pandoc.Div({ pandoc.Para(md_inlines(text(meta.title):upper())) },
    { ['custom-style'] = 'Document Title' })
  out[#out + 1] = blank()

  local sec, sub, n = 0, 0, 0
  local seen_heading, consent_done = false, false
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' then
      if not consent_done then
        consent_done = true
        -- FRBP 7008(a): the consent statement, printed once before the first heading, unnumbered.
        if text(meta.consent) ~= '' then
          out[#out + 1] = pandoc.Div({ pandoc.Para(md_inlines(text(meta.consent))) },
            { ['custom-style'] = 'Indented Paragraph' })
        end
      end
      seen_heading = true
      if b.level == 1 then
        sec = sec + 1
        if CFG.h2 == 'letters' then sub = 0 end
        if CFG.h1_roman then prefix(b, roman(sec) .. '.') end
      elseif b.level == 2 then
        sub = sub + 1
        if CFG.h2 == 'roman' then
          prefix(b, roman(sub) .. '.')
        else
          prefix(b, LETTERS:sub(sub, sub):upper() .. '.')
        end
      end
      out[#out + 1] = b
    elseif b.t == 'Para' then
      -- Paragraphs before the first heading (the lead-in) and those beginning WHEREFORE are unnumbered.
      if CFG.numbered and seen_heading and pandoc.utils.stringify(b):sub(1, 8) ~= 'WHEREFORE' then
        n = n + 1
        table.insert(b.content, 1, TAB)
        table.insert(b.content, 1, pandoc.Str(n .. '.'))
        out[#out + 1] = pandoc.Div({ b }, { ['custom-style'] = 'Numbered Paragraph' })
      else
        out[#out + 1] = pandoc.Div({ b }, { ['custom-style'] = 'Indented Paragraph' })
      end
    elseif b.t == 'OrderedList' or b.t == 'BulletList' then
      for i, item in ipairs(b.content) do
        local lab = b.t == 'BulletList' and '\u{2022}' or list_label(i)
        local first = item[1]
        if first and (first.t == 'Para' or first.t == 'Plain') then
          table.insert(first.content, 1, TAB)
          table.insert(first.content, 1, pandoc.Str(lab))
        else
          table.insert(item, 1, pandoc.Plain({ pandoc.Str(lab), TAB }))
        end
        out[#out + 1] = pandoc.Div(item, { ['custom-style'] = 'Lettered Item' })
      end
    else
      out[#out + 1] = b
    end
  end

  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  out[#out + 1] = blank()
  for _, x in ipairs(certificate(meta)) do out[#out + 1] = x end
  return pandoc.Pandoc(out, pandoc.MetaMap({}))
end
