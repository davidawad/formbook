-- ca7-answering-brief: pandoc Lua filter for the LaTeX engine (see ../README.md, "Engines").
-- Builds the cover, the table of contents, the table of authorities, the signature block and the
-- certificates from the YAML frontmatter (same fields as the typst template), numbers the headings
-- and turns each [text](toa:key) citation into a counted hit for the table of authorities.
-- Typesetting macros are in template.tex. No case-specific text lives here.

-- Per-brief settings, taken from ca7-answering-brief.typ (the same numbers, with the rule each traces to).
local CONFIG = {
  answering = true,    -- answering brief: "Argument" point headings are centered; A./1./a./(1) elsewhere
  base = 1,             -- label indent: a level-2 heading sits at 0.5 in when base = 2, at 0 when base = 1
  italic_from = 4,      -- headings from this level are italic (typst style-heading)
  toc_depth = 5,        -- deepest heading level listed in the table of contents
  word_limit = 14000,   -- Cir. R. 32(c)
  cert_sizes = '12-point',  -- body size in the certificate of compliance (FRAP 32(a)(5)(A))
}

-- Inline markdown in a metadata value -> LaTeX.
local function tex(v)
  if v == nil then return '' end
  if type(v) == 'string' then v = pandoc.Inlines({pandoc.Str(v)}) end
  local s = pandoc.write(pandoc.Pandoc({pandoc.Plain(v)}), 'latex')
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
  error('ca7-answering-brief: headings deeper than level 5 are not supported')
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
    if meta[k] == nil then error('ca7-answering-brief: missing required metadata field `' .. k .. '`') end
    return meta[k]
  end
  add('\\thispagestyle{empty}\\begin{center}\\singlespacing')
  add('\\textbf{No.\\ ' .. tex(need('case_number')) .. '}\\par\\vspace{0.5em}')
  add(DOUBLE .. '\\par\\vspace{0.5em}')
  add('\\textbf{IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE SEVENTH CIRCUIT}\\par\\vspace{0.5em}')
  add(SHORT .. '\\vspace{0.5em}')
  local sides = need('caption')
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do
      add(tex(name) .. '\\par\\addvspace{0.35em}')
    end
    add('\\makebox[\\linewidth][l]{\\hspace*{0.5\\linewidth}' .. tex(side.designation) .. '}\\par')
    if i < #sides then add('\\vspace{0.5em}v.\\par\\vspace{0.5em}') end
  end
  add('\\vspace{0.5em}' .. SHORT .. '\\vspace{0.5em}')
  add(tex(need('proceeding')) .. '\\par')
  if meta.district_court_case ~= nil or meta.judge ~= nil then
    local parts = {}
    if meta.district_court_case ~= nil then parts[#parts + 1] = tex(meta.district_court_case) end
    if meta.judge ~= nil then parts[#parts + 1] = tex(meta.judge) end
    add('\\addvspace{0.35em}' .. table.concat(parts, '; ') .. '\\par')
  end
  add('\\vspace{0.5em}' .. SHORT .. '\\vspace{0.5em}')
  add('\\textbf{\\MakeUppercase{' .. tex(need('brief_title')) .. '}}\\par\\vspace{0.5em}')
  add(SHORT .. '\\vspace{0.5em}')
  -- Counsel (FRAP 32(a)(2)(F)): one column at mid-page, the firm's lines in italics; the last group
  -- carries the telephone line, then the role and the date (typst cover-body, answering brief).
  local counsel = need('counsel')
  for gi, g in ipairs(counsel) do
    local b = {}
    for _, n in ipairs(g.names) do b[#b + 1] = tex(n) .. '\\\\' end
    for _, l in ipairs(g.lines or {}) do b[#b + 1] = '\\hspace*{0.5em}\\emph{' .. tex(l) .. '}\\\\' end
    if gi == #counsel and meta.phone ~= nil then b[#b + 1] = '\\hspace*{0.5em}\\emph{' .. tex(meta.phone) .. '}\\\\' end
    add('\\makebox[\\linewidth][l]{\\hspace*{0.5\\linewidth}\\begin{minipage}[t]{0.5\\linewidth}\\raggedright ' ..
      table.concat(b, '\n') .. '\\end{minipage}}\\par\\vspace{0.5em}')
  end
  if meta.role ~= nil then add('\\makebox[\\linewidth][l]{\\hspace*{0.5\\linewidth}\\emph{' .. tex(meta.role) .. '}}\\par') end
  if meta.date ~= nil then add('\\vspace{0.5em}' .. tex(meta.date) .. '\\par') end
  add('\\vspace{0.5em}' .. DOUBLE)
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

-- Signers as "/s/ Name" over "Name (No. X)" (as in the exemplar), then the firm's lines (typst signers-block).
local function signers_tex(meta)
  local sig = meta.signature
  local L = {}
  for _, s in ipairs(sig.signers) do
    local num = s.number ~= nil and (' (No. ' .. tex(s.number) .. ')') or ''
    L[#L + 1] = '\\par\\addvspace{0.9em}\\noindent s/ ' .. tex(s.name) .. '\\\\' .. tex(s.name) .. num .. '\\par'
  end
  local lines = {}
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = '\\emph{' .. tex(l) .. '}\\\\' end
  L[#L + 1] = '\\par\\addvspace{0.6em}\\noindent' .. table.concat(lines, '\n')
  return table.concat(L, '\n')
end

local function signature(meta)
  local L = {}
  L[#L + 1] = '\\par\\needspace{8\\baselineskip}\\addvspace{1.4em}\\begingroup\\singlespacing\\noindent'
  L[#L + 1] = '\\hspace*{0.5\\linewidth}\\begin{minipage}[t]{0.5\\linewidth}\\raggedright'
  L[#L + 1] = 'Respectfully submitted,'
  L[#L + 1] = signers_tex(meta)
  L[#L + 1] = '\\end{minipage}'
  if meta.date ~= nil then L[#L + 1] = '\\par\\addvspace{0.8em}\\noindent ' .. tex(meta.date) .. '\\par' end
  L[#L + 1] = '\\endgroup'
  return table.concat(L, '\n')
end

-- A signature line with its caption underneath, two columns (typst form-sig-line).
local function form_sig_line(meta, date)
  local d = date or plain(meta.date)
  return '\\par\\addvspace{1.6em}\\begingroup\\singlespacing\\noindent\\begin{minipage}[t]{0.5\\linewidth}' ..
    's/ ' .. tex(meta.signature.signer) .. '\\\\Signature\\end{minipage}' ..
    '\\begin{minipage}[t]{0.45\\linewidth}' .. tex(d) .. '\\\\Date\\end{minipage}\\par\\endgroup'
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
      error('ca7-answering-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
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

local function count_words(doc)
  local n = 0
  for _ in pandoc.utils.stringify(doc.blocks):gmatch('%S+') do n = n + 1 end
  return n
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
    error('ca7-answering-brief: the brief has ' .. words .. ' words; Circuit Rule 32(c) allows ' .. CONFIG.word_limit)
  end
  doc = doc:walk({
    Header = function(h)
      local text = plain(h.content)
      if h.level == 1 and text:lower():match('^%s*addendum%s*$') then
        error('ca7-answering-brief: the LaTeX engine does not yet render an addendum (FRAP 28(f))')
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
  front[#front + 1] = raw('\\pagenumbering{roman}')
  front[#front + 1] = raw(cover(meta))
  front[#front + 1] = raw('\\clearpage\\cahead{1}{0}{}{Table of Contents}{toc}{99}' ..
    '\n\\begin{flushright}\\textbf{\\underline{Page}}\\end{flushright}')

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
  front[#front + 1] = raw('\\clearpage\\pagenumbering{arabic}')

  -- back matter: signature, then the certificates on a new page (typst pagebreak(weak))
  local back = {raw(signature(meta))}
  back[#back + 1] = raw('\\clearpage\\cahead{1}{0}{}{Certificate of Compliance with Type-Volume Limit, ' ..
    'Typeface Requirements, and Type-Style Requirements}{cc}{99}')
  local tot = count_words(doc)
  back[#back + 1] = raw('\\begingroup\\singlespacing\\noindent 1.\\ This document complies with the page and word ' ..
    'limitation of Fed. R. App. P. 32(a)(7)(B) and Circuit Rule 32(c) and, excluding the portions of the filing ' ..
    'exempted by Fed. R. App. P. 32(f), contains ' .. group_digits(tot) .. ' words (including footnotes).' ..
    '\\par\\addvspace{1em}2.\\ This document complies with the typeface requirements and the type-style ' ..
    'requirements of Fed. R. App. P. 32(a)(5) and (6) and Circuit Rule 32(b) because it has been prepared in a ' ..
    'proportionally spaced typeface, ' .. tex(meta.typeface) .. ', in ' .. CONFIG.cert_sizes ..
    ' text and 11-point footnotes.\\endgroup')
  back[#back + 1] = raw(signers_tex(meta))
  if svc ~= nil and svc.certificate then
    back[#back + 1] = raw('\\cahead{1}{0}{}{Certificate of Service}{cs}{99}')
    -- the counsel served, each group in the margin-indented block of typst certificate-of-service
    local served = {}
    served[#served + 1] = '\\begingroup\\singlespacing\\noindent I hereby certify that on ' .. tex(meta.date) ..
      ', the foregoing ' .. tex(meta.brief_title) ..
      ' was submitted for filing with the Clerk of Court of the United States Court of Appeals for the Seventh ' ..
      'Circuit ' .. tex(svc.method or 'using the CM/ECF system') ..
      (svc.served_by ~= nil and (' and served by ' .. tex(svc.served_by)) or '') ..
      ' on the following counsel of record:\\endgroup'
    for _, g in ipairs(svc.counsel or {}) do
      local b = {}
      for _, n in ipairs(g.names) do b[#b + 1] = tex(n) .. '\\\\' end
      for _, l in ipairs(g.lines or {}) do b[#b + 1] = '\\emph{' .. tex(l) .. '}\\\\' end
      served[#served + 1] = '\\par\\addvspace{0.8em}\\begingroup\\singlespacing\\noindent\\hspace*{0.5in}' ..
        '\\begin{minipage}[t]{\\dimexpr\\linewidth-0.5in\\relax}\\raggedright ' .. table.concat(b, '\n') ..
        '\\end{minipage}\\endgroup'
    end
    for _, s in ipairs(served) do back[#back + 1] = raw(s) end
    back[#back + 1] = raw(signers_tex(meta))
  end

  local blocks = pandoc.Blocks({})
  for _, b in ipairs(front) do blocks:insert(b) end
  for _, b in ipairs(doc.blocks) do blocks:insert(b) end
  for _, b in ipairs(back) do blocks:insert(b) end
  doc.blocks = blocks
  return doc
end
