-- U.S. Bankruptcy Court, W.D. Missouri: adversary complaint, docx engine (pandoc Lua filter; see ../README.md,
-- "Engines", and docs/DOCX.md), so that the Word output reads and breaks as typst/mowb-*.typ does. The court title,
-- caption, title, body, signature block and certificate of service are written as OOXML paragraphs from the
-- sample's frontmatter and body: no case text lives in this file. This file is identical in the two doc-type
-- folders except for DOCTYPE below.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 276 a single line, 552 the double-spaced body), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local DOCTYPE = 'adversary-complaint'

local xe = require('docx.xengine')

local SINGLE = 276                       -- typst pitch-single, 13.8 pt
local INDENT = 720                       -- typst para-indent, item-indent, heading-label: 0.5 in
local CAP_LEFT, CAP_PAREN = 5472, 504    -- typst caption-left 3.8 in, caption-paren 0.35 in
local LABEL = 2160                       -- typst label-indent 1.5 in
local SIG_LEFT = 4752                    -- typst sig-left 3.3 in

local CFG = ({
  ['adversary-complaint'] = {
    body = 552,              -- typst pitch-double: the body is double-spaced
    gap = 0,                 -- no space between paragraphs: the double pitch sets them off
    numbered = true,         -- paragraphs numbered from the first heading on; the lead-in and WHEREFORE are not
    adv = 'Adv. Pro. No. ',  -- caption label of the adversary number
    h1_roman = false,        -- level-1 headings are unnumbered (centred, caps)
    h2 = 'roman',            -- level-2 headings: I., II., ... counted continuously
    respectfully = true,     -- "Respectfully submitted," above the firm name
    by = 'By: /s/ ',
    list = 'letters',        -- lists are lettered (a), (b), ...
  },
  ['motion-brief'] = {
    body = SINGLE,           -- typst pitch-single: single spacing within a paragraph
    gap = SINGLE,            -- one blank line between paragraphs
    numbered = false,        -- memorandum: no paragraph numbers
    adv = 'Adv. No. ',
    h1_roman = true,         -- level-1 headings: I., II., ...
    h2 = 'letters',          -- level-2 headings: A., B., ...; restarted in each section
    respectfully = false,
    by = '/s/ ',
    list = 'numbers',        -- lists are numbered 1., 2., ...
  },
})[DOCTYPE]
local BODY = CFG.body
local BLANK = 2 * SINGLE                 -- typst pitch-double: the space around the caption, title and signature

local LETTERS = 'abcdefghijklmnopqrstuvwxyz'

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
local function md(s)
  local b = pandoc.read(s, 'markdown').blocks[1]
  return b and b.content or pandoc.Inlines({})
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

local function upper(inlines)
  return inlines:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, tabs, jc, keep } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then
    local t = {}
    for _, pos in ipairs(o.tabs) do t[#t + 1] = '<w:tab w:val="left" w:pos="' .. pos .. '"/>' end
    props[#props + 1] = '<w:tabs>' .. table.concat(t) .. '</w:tabs>'
  end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or 'left')
  return xe.para(props, body)
end

-- ---- caption (FRBP 7010, Official Form 416D; FRBP 9004(b); W.D. Mo. L.R. 17004-1(A))

local function court_block(meta, out)
  for _, l in ipairs(items(meta.court)) do out[#out + 1] = p(xe.runs(l:upper()), { jc = 'center' }) end
  if text(meta.division) ~= '' then out[#out + 1] = p(xe.runs(text(meta.division):upper()), { jc = 'center' }) end
end

-- One caption line: the name column, a ")" at 3.8 in, then the number column at 4.15 in (typst: one grid row per
-- line). The first row stands a double line below the court title.
local function caption(meta, out)
  local plaintiffs, defendants = items(meta.plaintiffs), items(meta.defendants)
  local adv = text(meta.adv_number)
  adv = CFG.adv .. (adv ~= '' and adv or '____________')
  local first = true
  local function row(l, r, label)
    out[#out + 1] = p(xe.runs(l .. '\t)\t' .. r), { tabs = { CAP_LEFT, CAP_LEFT + CAP_PAREN },
      left = label and LABEL or 0, before = first and BLANK or 0 })
    first = false
  end
  row('In re:', '')
  row('', '')
  row(text(meta.debtor):upper(), 'Case No. ' .. text(meta.case_number))
  row('', 'Chapter ' .. text(meta.chapter))
  if text(meta.judge) ~= '' then row('', text(meta.judge)) end
  row('Debtor.', '', true)
  row('', '')
  for i, pl in ipairs(plaintiffs) do row(pl:upper(), i == 1 and adv or '') end
  row(#plaintiffs > 1 and 'Plaintiffs,' or 'Plaintiff,', '', true)
  row('', '')
  row('v.', '')
  row('', '')
  for _, d in ipairs(defendants) do row(d:upper(), '') end
  row(#defendants > 1 and 'Defendants.' or 'Defendant.', '', true)
end

-- ---- signature block and certificate of service (W.D. Mo. L.R. 9011-4, 9013-3)

-- Groups of single-spaced lines in the signature column, a blank line between the groups; every line but the last
-- is kept with the next, so the block never breaks across a page (typst: an unbreakable block).
local function sig_lines(groups, before, out, keep_last)
  for gi, g in ipairs(groups) do
    for li, body in ipairs(g) do
      local last = gi == #groups and li == #g
      out[#out + 1] = p(body, { left = SIG_LEFT, keep = keep_last or not last,
        before = li == 1 and (gi == 1 and before or SINGLE) or 0 })
    end
  end
end

local function signature(meta, out)
  local sig = meta.signature
  local before = BLANK
  if text(meta.date) ~= '' then
    out[#out + 1] = p(xe.runs('Dated: ' .. text(meta.date)), { before = before, keep = true })
    before = BLANK
  end
  local groups = {}
  if CFG.respectfully then groups[#groups + 1] = { xe.runs('Respectfully submitted,') } end
  local firm = {}
  for _, l in ipairs(items(sig.firm)) do firm[#firm + 1] = xe.runs(l:upper()) end
  groups[#groups + 1] = firm
  groups[#groups + 1] = { xe.runs(CFG.by .. text(sig.signer)), xe.runs(text(sig.signer) .. ', ' .. text(sig.bar)) }
  local last = {}
  for _, l in ipairs(items(sig.lines)) do last[#last + 1] = xe.runs(l) end
  last[#last + 1] = xe.inl(md(text(sig.role)), { i = true })
  groups[#groups + 1] = last
  sig_lines(groups, before, out)
end

local function certificate(meta, out)
  local cert, sig = meta.certificate, meta.signature
  local head = xe.runs('CERTIFICATE OF SERVICE', { b = true })
  if DOCTYPE == 'adversary-complaint' then
    out[#out + 1] = xe.para({ xe.style('Heading1'), xe.KEEP, xe.spacing(BLANK, 0, BODY), xe.ind(0, nil, 0),
      xe.jc('center') }, head)
  else
    out[#out + 1] = p(head, { before = BLANK, keep = true })
  end
  out[#out + 1] = p(xe.inl(md('I certify that on ' .. text(cert.date) .. ', ' .. text(cert.manner) .. '.')),
    { line = BODY, first = INDENT, before = CFG.gap, keep = true })
  sig_lines({ { xe.runs('/s/ ' .. text(sig.signer)), xe.runs(text(sig.signer)) } }, BLANK, out)
end

-- ---- body

local function list_label(i)
  if CFG.list == 'letters' then return '(' .. LETTERS:sub(i, i) .. ')' end
  return i .. '.'
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub('%)%(', ')\u{2060}('):gsub('/([^%d/])', '/\u{200B}%1')))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = {}
  court_block(meta, out)
  caption(meta, out)
  out[#out + 1] = p(xe.inl(md(text(meta.title):upper()), { b = true }), { jc = 'center', before = BLANK, after = BLANK })

  -- body paragraphs: the first-line indent; numbered ones the number then a tab to the next half inch
  local function body_par(label, inlines)
    if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT, before = CFG.gap }) end
    return p(xe.runs(label .. '\t') .. xe.inl(inlines), { line = BODY, first = INDENT, tabs = { 2 * INDENT },
      before = CFG.gap })
  end

  local sec, sub, n = 0, 0, 0
  local seen_heading = false
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' then
      if not seen_heading and DOCTYPE == 'adversary-complaint' then
        -- FRBP 7008(a): the consent statement, printed once before the first heading, unnumbered.
        out[#out + 1] = body_par(nil, md(text(meta.consent)))
      end
      seen_heading = true
      local label, content, jc, o = '', b.content, 'left', {}
      if b.level == 1 then
        sec = sec + 1
        if CFG.h2 == 'letters' then sub = 0 end
        content = upper(content)
        if CFG.h1_roman then label = roman(sec) .. '.\t' else jc = 'center' end
      elseif b.level == 2 then
        sub = sub + 1
        label = (CFG.h2 == 'roman' and roman(sub) or LETTERS:sub(sub, sub):upper()) .. '.\t'
      else
        o.i = true
      end
      o.b = true
      out[#out + 1] = xe.para({ xe.style('Heading' .. b.level), xe.KEEP,
        '<w:tabs><w:tab w:val="left" w:pos="' .. INDENT .. '"/></w:tabs>', xe.spacing(CFG.gap, 0, BODY),
        xe.ind(0, nil, 0), xe.jc(jc) }, xe.runs(label, o) .. xe.inl(content, o))
    elseif b.t == 'Para' or b.t == 'Plain' then
      -- Paragraphs before the first heading (the lead-in) and those beginning WHEREFORE are unnumbered.
      if CFG.numbered and seen_heading and text(b):sub(1, 9) ~= 'WHEREFORE' then
        n = n + 1
        out[#out + 1] = body_par(n .. '.', b.content)
      else
        out[#out + 1] = body_par(nil, b.content)
      end
    elseif b.t == 'OrderedList' or b.t == 'BulletList' then
      -- the label half an inch in, the text hanging a further half inch (typst item-indent and the label box)
      for i, item in ipairs(b.content) do
        local lab = b.t == 'BulletList' and '\u{2022}' or list_label(i)
        for k, x in ipairs(item) do
          out[#out + 1] = p(xe.runs(k == 1 and (lab .. '\t') or '') .. xe.inl(x.content),
            { line = BODY, left = 2 * INDENT, hanging = INDENT, before = (i == 1 and k == 1) and CFG.gap or 0 })
        end
      end
    else
      error('mowb.lua: unsupported block ' .. b.t)
    end
  end

  signature(meta, out)
  certificate(meta, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
