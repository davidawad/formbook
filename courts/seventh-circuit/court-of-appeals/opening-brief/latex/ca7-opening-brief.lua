-- ca7-opening-brief: pandoc Lua filter for the LaTeX engine (see ../README.md, "Engines").
-- Builds the cover, the table of contents, the table of authorities, the signature block and the
-- certificates from the YAML frontmatter (same fields as the typst template), numbers the headings
-- and turns each [text](toa:key) citation into a counted hit for the table of authorities.
-- Typesetting macros are in template.tex. No case-specific text lives here.

-- Per-brief settings, taken from ca7-opening-brief.typ (the same numbers, with the rule each traces to).
local CONFIG = {
  answering = false,    -- answering brief: "Argument" point headings are centered; A./1./a./(1) elsewhere
  base = 2,             -- label indent: a level-2 heading sits at 0.5 in when base = 2, at 0 when base = 1
  italic_from = 5,      -- headings from this level are italic (typst style-heading)
  toc_depth = 4,        -- deepest heading level listed in the table of contents (typst toc-depth)
  word_limit = 14000,   -- Cir. R. 32(c)
  cert_sizes = '14-point',  -- body size in the certificate of compliance (FRAP 32(a)(5)(A))
}

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_inlines = require('latex.xengine').inlines

-- Inline markdown in a metadata value -> LaTeX.
local function tex(v)
  if v == nil then return '' end
  if type(v) == 'string' then v = pandoc.Inlines({pandoc.Str(v)}) end
  local s = pandoc.write(pandoc.Pandoc({pandoc.Plain(xe_inlines(pandoc.Inlines(v)))}), 'latex')
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

-- Plain text of a metadata value (for sort keys and word counts).
local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

local function roman(n)
  local vals = {{1000, 'M'}, {900, 'CM'}, {500, 'D'}, {400, 'CD'}, {100, 'C'}, {90, 'XC'},
    {50, 'L'}, {40, 'XL'}, {10, 'X'}, {9, 'IX'}, {5, 'V'}, {4, 'IV'}, {1, 'I'}}
  local out = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

-- Printed label of a numbered heading (levels 2 to 5). Opening and reply: I. / A. / 1. / a. Answering:
-- the same inside the Argument, and A. / 1. / a. / (1) elsewhere.
local function label_for(level, n, in_arg)
  local point_roman = not CONFIG.answering or in_arg
  if level == 2 then return point_roman and (roman(n) .. '.') or (string.char(64 + n) .. '.') end
  if level == 3 then return point_roman and (string.char(64 + n) .. '.') or (tostring(n) .. '.') end
  if level == 4 then return point_roman and (tostring(n) .. '.') or (string.char(96 + n) .. '.') end
  if level == 5 then return point_roman and (string.char(96 + n) .. '.') or ('(' .. n .. ')') end
  error('ca7-opening-brief: headings deeper than level 5 are not supported')
end

-- Label indent in half inches (typst label-indent): the answering brief indents its non-Argument
-- headings one step less than its Argument sub-headings.
local function steps_for(level, in_arg)
  if CONFIG.answering then return level - (in_arg and 2 or 1) end
  return level - CONFIG.base
end

local function raw(s) return pandoc.RawBlock('latex', s) end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2)(A)-(F); CA7-COVER-001 to -005)
-- ---------------------------------------------------------------------------

-- Rules in vertical mode with no interline glue: they cost their own height, as in typst.
local SHORT = '\\nointerlineskip\\hbox to\\linewidth{\\hss\\rule{2in}{0.7pt}\\hss}\\nointerlineskip'
local DOUBLE = '\\nointerlineskip\\hbox to\\linewidth{\\rule{\\linewidth}{1.6pt}}\\nointerlineskip\\vspace{2.5pt}\\nointerlineskip\\hbox to\\linewidth{\\rule{\\linewidth}{0.5pt}}\\nointerlineskip'

local function cover(meta)
  local L = {}
  local function add(s) L[#L + 1] = s end
  local function need(k)
    if meta[k] == nil then error('ca7-opening-brief: missing required metadata field `' .. k .. '`') end
    return meta[k]
  end
  add('\\thispagestyle{empty}\\begin{center}\\singlespacing')
  add('\\textbf{No.\\ ' .. tex(need('case_number')) .. '}\\par\\cagap{}')
  add(DOUBLE .. '\\par\\cagap{}')
  add('\\textbf{IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE SEVENTH CIRCUIT}\\par\\cagap{}')
  add(SHORT .. '\\cagap{}')
  local sides = need('caption')
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do
      add(tex(name) .. '\\par\\addvspace{0.35em}')
    end
    add('\\makebox[\\linewidth][l]{\\hspace*{0.5\\linewidth}' .. tex(side.designation) .. '}\\par')
    if i < #sides then add('\\cagap{}v.\\par\\cagap{}') end
  end
  add('\\cagap{}' .. SHORT .. '\\cagap{}')
  add(tex(need('proceeding')) .. '\\par')
  if meta.district_court_case ~= nil or meta.judge ~= nil then
    local parts = {}
    if meta.district_court_case ~= nil then parts[#parts + 1] = tex(meta.district_court_case) end
    if meta.judge ~= nil then parts[#parts + 1] = tex(meta.judge) end
    add('\\addvspace{0.35em}' .. table.concat(parts, '; ') .. '\\par')
  end
  add('\\cagap{}' .. SHORT .. '\\cagap{}')
  add('\\textbf{\\MakeUppercase{' .. tex(need('brief_title')) .. '}}\\par\\cagap{}')
  add(SHORT .. '\\cagap{}')
  -- Counsel (FRAP 32(a)(2)(F)): two columns, left aligned.
  local counsel = need('counsel')
  -- Two columns of (text width - 1 em) / 2, as typst's grid; the address lines step in 0.5 em, wrapped lines too.
  local function block(g)
    local b = {}
    for _, n in ipairs(g.names) do b[#b + 1] = tex(n) .. '\\par' end
    local l = {}
    for _, x in ipairs(g.lines or {}) do l[#l + 1] = tex(x) .. '\\par' end
    return '\\begin{minipage}[t]{\\dimexpr(\\linewidth-14bp)/2\\relax}\\singlespacing\\raggedright\\parindent=0pt ' ..
      table.concat(b, '\n') .. '{\\leftskip=0.5em ' .. table.concat(l, '\n') .. '}\\end{minipage}'
  end
  for i = 1, #counsel, 2 do
    local row = block(counsel[i])
    if counsel[i + 1] ~= nil then row = row .. '\\hfill' .. block(counsel[i + 1]) else row = row .. '\\hfill\\null' end
    add('\\carow{' .. row .. '}\\addvspace{8.4bp}')
  end
  if meta.counsel_for ~= nil then add('\\par\\cagap{}' .. tex(meta.counsel_for) .. '\\par') end
  add('\\cagap{}' .. DOUBLE)
  add('\\end{center}')
  return table.concat(L, '\n')
end

-- ---------------------------------------------------------------------------
-- Certificates and signature (Form 6; FRAP 25 service)
-- ---------------------------------------------------------------------------

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return (out:gsub('^,', ''))
end

local function signature(meta)
  local sig = meta.signature
  local L = {}
  -- [signature-block]: "Respectfully submitted," then 16.8 bp, the signature and the signer's lines in the right
  -- half (the address lines 0.5 em in), then 11.2 bp and the date at the margin; kept with the last paragraph.
  L[#L + 1] = '\\par\\nobreak\\addvspace{19.6bp}\\nobreak'
  L[#L + 1] = '\\begingroup\\singlespacing\\leftskip=0.5\\linewidth\\parindent=0pt'
  L[#L + 1] = 'Respectfully submitted,\\par\\nobreak\\vspace{16.8bp}\\nobreak'
  L[#L + 1] = 's/ ' .. tex(sig.signer) .. '\\par\\nobreak'
  L[#L + 1] = '\\MakeUppercase{' .. tex(sig.signer) .. '}\\par\\nobreak'
  L[#L + 1] = '\\advance\\leftskip 0.5em'
  for _, l in ipairs(sig.lines or {}) do L[#L + 1] = tex(l) .. '\\par\\nobreak' end
  L[#L + 1] = '\\endgroup'
  if meta.date ~= nil then
    L[#L + 1] = '\\nobreak\\vspace{11.2bp}\\nobreak\\begingroup\\singlespacing\\noindent ' .. tex(meta.date) .. '\\par\\endgroup'
  end
  return table.concat(L, '\n')
end

-- A signature line with its caption underneath, two columns (typst form-sig-line).
local function form_sig_line(meta, date)
  local d = date or tex(meta.date)
  -- the right column starts (text width + 1 em) / 2 in, as typst's grid
  return '\\par\\nobreak\\addvspace{22.4bp}\\nobreak\\begingroup\\singlespacing\\noindent\\makebox[241bp][l]{s/ ' ..
    tex(meta.signature.signer) .. '}' .. d .. '\\par\\nobreak\\noindent\\makebox[241bp][l]{Signature}Date\\par\\endgroup'
end

-- ---------------------------------------------------------------------------
-- Table of authorities
-- ---------------------------------------------------------------------------

local ORDER = {'case', 'constitution', 'statute', 'regulation', 'rule', 'other'}
local TITLES = {
  case = 'Cases:', constitution = 'Constitutional Provisions:', statute = 'Statutes:',
  regulation = 'Regulations:', rule = 'Rules:', other = 'Other Authorities:',
}

local function sort_key(a)
  local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. ' ' .. plain(a.cite))
  return (s:lower():gsub('[^a-z0-9 ]', ''))
end

local function toa(meta, hits)
  local out = {}
  local auth = meta.authorities or {}
  -- every hit must have an entry in the frontmatter (loud failure beats silent omission)
  for key in pairs(hits) do
    if auth[key] == nil then
      error('ca7-opening-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
    end
  end
  out[#out + 1] = '\\cahead{1}{0}{}{Table of Authorities}{toa}{99}'
  local first = true
  for _, kind in ipairs(ORDER) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == kind and hits[key] ~= nil then members[#members + 1] = {key = key, a = a} end
    end
    table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
    if #members > 0 then
      out[#out + 1] = '\\toagroup{' .. TITLES[kind] .. '}{' .. (first and 1 or 0) .. '}'
      first = false
      for _, m in ipairs(members) do
        local name = m.a.name ~= nil and tex(m.a.name) or ''
        out[#out + 1] = string.format('\\toaitem{%s}{%s}{%d}{%s}', name, tex(m.a.cite),
          kind == 'case' and 1 or 0, m.key)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Words (Cir. R. 32(c)): whitespace-delimited words of the body, footnotes included
-- ---------------------------------------------------------------------------

-- Block by block (stringify of the whole document would run the last word of one block into the first of the
-- next), footnote text included, footnote marks and list markers not counted: the typst template's count.
local function words_in(s)
  local n = 0
  for _ in s:gsub('\194\160', ' '):gmatch('%S+') do n = n + 1 end
  return n
end

local function count_blocks(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == 'BulletList' or b.t == 'OrderedList' then
      for _, item in ipairs(b.content) do n = n + count_blocks(item) end
    elseif b.t == 'BlockQuote' or b.t == 'Div' then
      n = n + count_blocks(b.content)
    elseif b.t ~= 'RawBlock' then
      local notes = {}
      local without = pandoc.Pandoc({ b }):walk({
        Note = function(note) notes[#notes + 1] = note.content; return {} end,
      })
      n = n + words_in(pandoc.utils.stringify(without.blocks))
      for _, c in ipairs(notes) do n = n + count_blocks(c) end
    end
  end
  return n
end

local function count_words(doc)
  return count_blocks(doc.blocks)
end

-- ---------------------------------------------------------------------------
-- The filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta

  -- pass 1: count the toa: citations; each writes its page to the aux file at its place (\toahit)
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = el.target:sub(5)
      hits[key] = (hits[key] or 0) + 1
      local out = pandoc.Inlines({pandoc.RawInline('latex', '\\toahit{' .. key .. '}')})
      out:extend(el.content)
      return out
    end,
  })

  -- the cross-engine inline rules over the body text
  doc = doc:walk({Inlines = xe_inlines})

  -- pass 2: headings. Level 1 is an unnumbered section; levels 2 to 5 number as in typst.
  local counters = {0, 0, 0, 0, 0, 0}
  local in_arg = false
  local heads = {}
  local function add_head(level, title_tex, label)
    heads[#heads + 1] = {level = level, label = label, title = title_tex, idx = #heads + 1,
      steps = steps_for(level, in_arg), centered = CONFIG.answering and in_arg and level == 2}
    return #heads
  end
  local words = count_words(doc)
  if words > CONFIG.word_limit then
    error('ca7-opening-brief: the brief has ' .. words .. ' words; Circuit Rule 32(c) allows ' .. CONFIG.word_limit)
  end
  doc = doc:walk({
    Header = function(h)
      local text = plain(h.content)
      if h.level == 1 and text:lower():match('^%s*addendum%s*$') then
        error('ca7-opening-brief: the LaTeX engine does not yet render an addendum (FRAP 28(f))')
      end
      if h.level == 1 then
        in_arg = text:lower():match('^%s*argument%s*$') ~= nil
        counters = {0, 0, 0, 0, 0, 0}
        counters[1] = 0
      end
      counters[h.level] = counters[h.level] + 1
      for i = h.level + 1, 6 do counters[i] = 0 end
      local label = h.level == 1 and '' or label_for(h.level, counters[h.level], in_arg)
      local title = tex(h.content)
      local idx = add_head(h.level, title, label)
      if heads[idx].centered then
        return raw(string.format('\\cacenter{%s}{%s}{h%d}', label, title, idx))
      end
      return raw(string.format('\\cahead{%d}{%d}{%s}{%s}{h%d}{%d}', h.level, steps_for(h.level, in_arg),
        label, title, idx, CONFIG.italic_from))
    end,
  })

  -- front matter: cover (i), table of contents (ii), table of authorities (iii)
  local front = {}
  -- the cover has no number; the front matter counts from i (typst: counter(page).update(1))
  front[#front + 1] = raw('\\singlespacing')
  front[#front + 1] = raw(cover(meta))
  front[#front + 1] = raw('\\clearpage\\pagenumbering{roman}\\cahead{1}{0}{}{Table of Contents}{toc}{99}' ..
    '\n\\par\\addvspace{4.2bp}\\begingroup\\raggedleft\\singlespacing\\bfseries\\underline{Page}\\par\\endgroup')

  -- table of contents: the table of authorities, every heading up to toc_depth, the certificates
  local function tocline(level, steps, label, title, idx)
    return string.format('\\tocline{%d}{%d}{%s}{%s}{%s}', level, steps, label, title, idx)
  end
  local toc = {tocline(1, 0, '', 'Table of Authorities', 'toa')}
  for _, h in ipairs(heads) do
    if h.level <= CONFIG.toc_depth then
      local steps = h.centered and 0 or h.steps
      toc[#toc + 1] = tocline(h.level, steps, h.label, h.title, 'h' .. h.idx)
    end
  end
  toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Compliance', 'cc')
  local svc = meta.service
  if svc ~= nil and svc.certificate then toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Service', 'cs') end
  front[#front + 1] = raw(table.concat(toc, '\n'))

  local toa_lines = toa(meta, hits)
  front[#front + 1] = raw('\\clearpage\n' .. table.concat(toa_lines, '\n'))
  front[#front + 1] = raw('\\clearpage\\pagenumbering{arabic}\\normalsize')

  -- back matter: signature, then the certificates on a new page (typst pagebreak(weak))
  local back = {raw(signature(meta))}
  back[#back + 1] = raw('\\clearpage\\cahead{1}{0}{}{Certificate of Compliance}{cc}{99}')
  local tot = words -- counted before the headings became raw LaTeX
  back[#back + 1] = raw('\\begingroup\\singlespacing\\noindent The foregoing brief complies with the type-volume ' ..
    'limitation of Circuit Rule 32(c). The brief contains ' .. group_digits(tot) ..
    ' words, excluding those parts of the brief exempted by Federal Rule of Appellate Procedure 32(f).' ..
    '\\par\\addvspace{14bp}\\noindent ' ..
    'This brief complies with the typeface and type-style requirements of Federal Rule of Appellate ' ..
    'Procedure 32(a)(5)-(6) and Circuit Rule 32(b) because this brief has been prepared in a ' ..
    'proportionally spaced typeface, Times New Roman, in ' .. CONFIG.cert_sizes .. ' font.\\par\\endgroup')
  back[#back + 1] = raw(form_sig_line(meta))
  if svc ~= nil and svc.certificate then
    back[#back + 1] = raw('\\cahead{1}{0}{}{Certificate of Service}{cs}{99}')
    back[#back + 1] = raw('\\begingroup\\singlespacing\\noindent Pursuant to Federal Rule of Appellate Procedure 25, ' ..
      'I hereby certify that on ' .. tex(svc.date) .. ', I electronically filed the foregoing ' ..
      tex(meta.brief_title) .. ' via the Court\u{2019}s CM/ECF system, and service was accomplished on ' ..
      'counsel of record by that means.\\par\\endgroup')
    back[#back + 1] = raw(form_sig_line(meta, tex(svc.date)))
  end

  -- The signature never stands alone: the brief's last paragraph is not broken across pages and stays with the
  -- signature block (typst: one unbreakable block).
  local n = #doc.blocks
  if n > 0 and doc.blocks[n].t == 'Para' then
    doc.blocks:insert(n, raw('\\begingroup\\interlinepenalty=10000\\relax'))
    doc.blocks:insert(raw('\\par\\endgroup'))
  end
  local blocks = pandoc.Blocks({})
  for _, b in ipairs(front) do blocks:insert(b) end
  for _, b in ipairs(doc.blocks) do blocks:insert(b) end
  for _, b in ipairs(back) do blocks:insert(b) end
  doc.blocks = blocks
  return doc
end
