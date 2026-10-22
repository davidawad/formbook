-- U.S. Court of Appeals for the Sixth Circuit: appellant's principal brief, LaTeX engine.
-- A pandoc filter. It writes the whole brief (cover, front matter, body, signature, certificates,
-- designation, addendum) from the sample's frontmatter and body, with the same rules and numbers as
-- ../typst/ca6-opening-brief.typ. The macros it calls are in template.tex. Rules: ../README.md.
-- No case-specific text here: everything comes from the sample.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the inline rules of lib/latex/xengine.lua (a hyphen
-- before a digit does not end a line, breaks at dashes, a section sign bound to its number, no ligature spellings)
-- run over the body and over every metadata value written here; blocks are spaced with \addvspace as typst spaces
-- them.

local xe = require('latex.xengine')

local TOC_DEPTH = 4         -- typst: toc-depth
local WORD_LIMIT = 13000    -- FRAP 32(a)(7)(B)(i); 6 Cir. R. 28(e)(2)(A)(i)
local FACE = 'Times New Roman'   -- the typeface the template sets (typst font-family; newtx has its metrics)

local cited = {}

local function R(s) return pandoc.RawBlock('latex', s) end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

-- Unicode line breaking (typst, Word) never breaks before a closing or separating mark, even after a space
-- (UAX #14 LB13: ". . . .", "(x )"): such a space is a no-break space here (written as ~, which keeps its width).
local NOBREAK_BEFORE = '^[.,:;!?)%]}/]'
local function bind_closers(inlines)
  local out = pandoc.Inlines({})
  for i, el in ipairs(inlines) do
    local nx = inlines[i + 1]
    if el.t == 'Space' and nx and nx.t == 'Str' and nx.text:match(NOBREAK_BEFORE) then
      out:insert(pandoc.RawInline('latex', '~'))
    else
      out:insert(el)
    end
  end
  return out
end
local function inlines(l) return xe.inlines(bind_closers(l)) end

local function tex_blocks(bs)
  return trim(pandoc.write(pandoc.Pandoc(bs):walk({ Inlines = inlines }), 'latex'))
end

-- Metadata (or any pandoc inline/block list, or a markdown string) as LaTeX, with the cross-engine inline rules.
local function tex(v)
  local t = pandoc.utils.type(v)
  if t == 'Inlines' then
    return tex_blocks({ pandoc.Plain(v) })
  elseif t == 'Blocks' then
    return tex_blocks(v)
  elseif t == 'string' then
    return tex_blocks(pandoc.read(v, 'markdown+smart').blocks)
  end
  error('ca6-brief: unexpected metadata type ' .. tostring(t))
end

-- Plain text of metadata, for comparisons and the sort key.
local function plain(v) return pandoc.utils.stringify(v) end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = ''
  for i = 1, #s do
    if i > 1 and (#s - i + 1) % 3 == 0 then out = out .. ',' end
    out = out .. s:sub(i, i)
  end
  return out
end

-- typst count-words on the markdown source of the body (frontmatter off, the addendum off), step by step, so that
-- every engine certifies the same number: comments, footnote labels and references, link targets, heading, quote and
-- list markers, backslash escapes, asterisks and emphasis underscores go; the rest splits on white space.
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error('ca6-brief: no input file to count words in', 0) end
  local h = assert(io.open(f, 'r'))
  local src = h:read('a')
  h:close()
  local fm = src:match('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n')
  if not fm then error('ca6-brief: the sample must start with a YAML frontmatter block', 0) end
  local body = src:sub(#fm + 1)
  local lines = {}
  for line in (body .. '\n'):gmatch('(.-)\r?\n') do
    if line:lower():match('^#[ \t]+addendum[ \t]*$') then break end
    lines[#lines + 1] = line
  end
  local s = table.concat(lines, '\n'):gsub('<!%-%-.-%-%->', ' ')
  local n = 0
  for line in (s .. '\n'):gmatch('(.-)\n') do
    line = line:gsub('^%[%^[^%]]+%]:', ' ')
    line = line:gsub('%[%^[^%]]+%]', '')
    line = line:gsub('%[([^%]]*)%]%([^)]*%)', '%1')
    line = line:gsub('^#+[ \t]+', '')
    line = line:gsub('^>[ \t]?', '')
    line = line:gsub('^[ \t]*[-*+][ \t]+', ''):gsub('^[ \t]*%d+[.)][ \t]+', '')
    line = line:gsub('\\(.)', '%1')
    line = line:gsub('%*', '')
    line = line:gsub('^_', ''):gsub('([%s(%[\u{201C}"])_', '%1')
    line = line:gsub('_([%s.,;:)%]\u{201D}"!?])', '%1'):gsub('_$', '')
    for _ in line:gmatch('%S+') do n = n + 1 end
  end
  return n
end

local function roman(n)
  local s = ''
  for _, p in ipairs({ { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

local function letter(n, upper)
  if n > 26 then error('ca6-brief: more than 26 sub-headings at one level') end
  return string.char((upper and 64 or 96) + n)
end

-- Printed label of a numbered heading. Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
local function label_for(level, in_arg, n)
  if in_arg then
    if level == 2 then return roman(n) .. '.' end
    if level == 3 then return letter(n, true) .. '.' end
    if level == 4 then return n .. '.' end
    if level == 5 then return letter(n, false) .. '.' end
  else
    if level == 2 then return letter(n, true) .. '.' end
    if level == 3 then return n .. '.' end
    if level == 4 then return letter(n, false) .. '.' end
    if level == 5 then return '(' .. n .. ')' end
  end
  error('ca6-brief: headings deeper than level 5 are not supported')
end

-- Headings, in document order; each gets an index (its \label ca-hd-<index>) and, when outlined, a TOC row.
local heads = {}
local function new_head(title_tex, level, ind, label, outlined)
  heads[#heads + 1] = { title = title_tex, level = level, ind = ind, label = label or '', outlined = outlined }
  return #heads
end

-- A section heading (level 1); `outlined`: listed in the TOC.
local function section(title, outlined)
  local i = new_head('\\MakeUppercase{' .. title .. '}', 1, 0, nil, outlined)
  return R('\\caHeadOne{' .. title .. '}{' .. i .. '}')
end

-- A heading of the body becomes one macro call (template.tex): level 1 is a section, the Argument's level 2 is the
-- centred point heading, and every other numbered level is a sub-heading whose label sits at d half inches.
local function heading_block(h, st, numbered)
  local title = tex(h.content)
  if h.level == 1 then
    st.in_arg = trim(plain(h.content):lower()) == 'argument'
    for k = 1, 6 do st.counters[k] = 0 end
    return section(title, true)
  end
  if not numbered then
    -- the addendum's headings: bold, left; in the TOC indented by level, with no label
    local i = new_head(title, h.level, h.level - 2, nil, h.level <= TOC_DEPTH)
    return R('\\caHeadPlain{' .. title .. '}{' .. i .. '}')
  end
  st.counters[h.level] = st.counters[h.level] + 1
  for k = h.level + 1, 6 do st.counters[k] = 0 end
  local label = label_for(h.level, st.in_arg, st.counters[h.level])
  local outlined = h.level <= TOC_DEPTH
  if st.in_arg and h.level == 2 then
    local i = new_head(title, 2, 0, label, outlined)
    return R('\\caHeadPoint{' .. label .. '}{' .. title .. '}{' .. i .. '}')
  end
  local d = st.in_arg and (h.level - 2) or (h.level - 1)
  local i = new_head(title, h.level, d, label, outlined)
  return R(string.format('\\caHeadSub{%d}{%d}{%s}{%s}{%d}', d, h.level, label, title, i))
end

-- Authorities from the frontmatter: kind, the printed name and cite, and the sort key (typst's sort-key).
local function authorities_of(meta)
  local out = {}
  for key, a in pairs(meta.authorities or {}) do
    local e = { kind = plain(a.kind), cite = tex(a.cite) }
    if a.name then e.name = tex(a.name) end
    local sortsrc = a.sort and plain(a.sort) or ((a.name and plain(a.name) or '') .. ' ' .. plain(a.cite))
    e.sort = sortsrc:lower():gsub('[^a-z0-9 ]', '')
    out[key] = e
  end
  return out
end

-- Single-spaced blocks (disclosure, certificates, designation lead-in): 14 bp before each paragraph.
local function single(blocks)
  local s = { '\\begin{caSingle}' }
  for _, b in ipairs(blocks) do s[#s + 1] = '\\caPar ' .. tex_blocks({ b }) end
  s[#s + 1] = '\\end{caSingle}'
  return table.concat(s, '\n')
end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2); 6 Cir. R. 28(d)) [cover-body]
-- ---------------------------------------------------------------------------

local function counsel_group(m, gi, g)
  local s = {}
  for _, n in ipairs(g.names) do s[#s + 1] = '\\noindent ' .. tex(n) .. '\\par' end
  local lines = {}
  for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
  if gi == #m.counsel then lines[#lines + 1] = m.phone end
  for _, l in ipairs(lines) do s[#s + 1] = '{\\leftskip=0.5em\\relax\\noindent\\emph{' .. tex(l) .. '}\\par}' end
  return table.concat(s, '\n')
end

local function minipage(width, body)
  return '\\begin{minipage}[t]{' .. width .. '}\\singlespacing\\parindent=0pt\\relax\\raggedright\n' .. body .. '\n\\end{minipage}'
end

local function cover(m)
  local s = {
    '\\thispagestyle{empty}\\begingroup\\singlespacing\\parindent=0pt\\relax',
    '\\cacenter{\\textbf{No. ' .. tex(m.case_number) .. '}}',
    '\\cagap\\caDoubleRule\\cagap',
    '\\cacenter{\\textbf{IN THE UNITED STATES COURT OF APPEALS\\\\ FOR THE SIXTH CIRCUIT}}',
    '\\cagap\\caShortRule\\cagap',
  }
  for i, side in ipairs(m.caption) do
    for _, n in ipairs(side.names) do s[#s + 1] = '\\cacenter{' .. tex(n) .. '}' end
    s[#s + 1] = '\\caright{0.5\\textwidth}{' .. tex(side.designation) .. '}'
    if i < #m.caption then s[#s + 1] = '\\cagap\\cacenter{v.}\\cagap' end
  end
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  s[#s + 1] = '\\cacenter{' .. tex(m.proceeding) .. '}'
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  s[#s + 1] = '\\cacenter{\\textbf{\\MakeUppercase{' .. tex(m.brief_title) .. '}}}'
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  -- Counsel (FRAP 32(a)(2)(F)): one group in the right half; several in two columns, 14 bp apart, in rows
  local groups = m.counsel
  if #groups == 1 then
    s[#s + 1] = '\\carow{\\hspace*{0.5\\textwidth}' .. minipage('0.5\\textwidth', counsel_group(m, 1, groups[1])) .. '}'
  else
    for r = 1, #groups, 2 do
      if r > 1 then s[#s + 1] = '\\vskip 11.2bp' end
      local right = groups[r + 1] and minipage('227bp', counsel_group(m, r + 1, groups[r + 1])) or ''
      s[#s + 1] = '\\carow{' .. minipage('227bp', counsel_group(m, r, groups[r])) .. '\\hspace{14bp}' .. right .. '}'
    end
  end
  if m.counsel_for then s[#s + 1] = '\\cagap\\cacenter{' .. tex(m.counsel_for) .. '}' end
  s[#s + 1] = '\\cagap\\caDoubleRule\\par\\endgroup'
  return table.concat(s, '\n')
end

-- ---------------------------------------------------------------------------
-- Signature, certificates, designation
-- ---------------------------------------------------------------------------

-- The signature block after the Conclusion (FRAP 32(d)) [signature-block].
local function signature_tex(m)
  local sig = m.signature
  local s = { '\\par\\nobreak\\addvspace{19.6bp}\\begingroup\\singlespacing\\parindent=0pt\\relax' }
  if m.date then s[#s + 1] = '\\noindent Dated: ' .. tex(m.date) .. '\\par\\nobreak\\vskip 11.2bp' end
  s[#s + 1] = '\\casig{Respectfully submitted,}\\nobreak\\vskip 16.8bp'
  s[#s + 1] = '\\casig{/s/ ' .. tex(sig.signer) .. '}'
  s[#s + 1] = '\\casig{' .. tex(sig.signer) .. '}'
  for _, l in ipairs(sig.lines or {}) do s[#s + 1] = '\\casigline{' .. tex(l) .. '}' end
  s[#s + 1] = '\\endgroup'
  return table.concat(s, '\n')
end

local function form_sig_line(m)
  return '\\caformsig{/s/ ' .. tex(m.signature.signer) .. '}{' .. (m.date and tex(m.date) or '') .. '}'
end

local function certificate_of_compliance(m, words)
  return table.concat({
    section('Certificate of Compliance', true).text,
    single({ pandoc.Para({ pandoc.Str('This brief complies with: (1) the type-volume limitation of Federal Rule of Appellate Procedure 32(a)(7)(B) because it contains '
      .. group_digits(words) .. ' words, excluding the parts of the brief exempted by Rule 32(f); and (2) the typeface requirements of Rule 32(a)(5) and the type style requirements of Rule 32(a)(6) because it has been prepared in a proportionally spaced typeface (14'),
      pandoc.RawInline('latex', '\\mbox{-}'),   -- "14-point" stays on one line (typst boxes it)
      pandoc.Str('point ' .. FACE .. '). The word count is computed from the markdown source of this brief.') }) }),
    form_sig_line(m),
  }, '\n')
end

local function certificate_of_service(m)
  local il = pandoc.Inlines({ pandoc.Str('I certify that on ') })
  il:extend(m.date)
  il:insert(pandoc.Str(', this brief was served via CM/ECF on all registered counsel and transmitted to the Clerk of the Court.'))
  return table.concat({
    section('Certificate of Service', true).text,
    single({ pandoc.Para(il) }),
    form_sig_line(m),
  }, '\n')
end

local function designation_section(m)
  local intro = m.designation_intro or pandoc.Inlines({ pandoc.Str(
    'The appellant designates the following filings from the District Court\'s electronic records under Sixth Circuit Rules 28(b)(1)(A)(i) and 30(g)(1):') })
  local rows = { '\\textbf{Date Filed} & \\textbf{R.No.; Page ID \\#} & \\textbf{Description of Document}\\\\' }
  for _, d in ipairs(m.designation) do
    rows[#rows + 1] = '\\noalign{\\vskip 8.4bp}' .. tex(d.date) .. ' & ' .. tex(d.rno) .. ' & ' .. tex(d.description) .. '\\\\'
  end
  -- [designation grid] three columns, 0.15 in apart: 1.5 in, 2.3 in, the rest; 8.4 bp between rows; a row is never
  -- split across pages (a longtable row is one box)
  local col = '>{\\singlespacing\\raggedright\\arraybackslash}'
  return table.concat({
    section('Designation of District Court Record', true).text,
    single({ pandoc.Para(intro) }),
    '\\par\\addvspace{14bp}\\begingroup\\singlespacing\\setlength{\\LTpre}{0pt}\\setlength{\\LTpost}{0pt}\\setlength{\\tabcolsep}{0pt}',
    '\\begin{longtable}{@{}' .. col .. 'p{1.5in}@{\\hspace{0.15in}}' .. col .. 'p{2.3in}@{\\hspace{0.15in}}' .. col
      .. 'p{\\dimexpr\\linewidth-4.1in\\relax}@{}}',
    table.concat(rows, '\n'),
    '\\end{longtable}\\endgroup',
  }, '\n')
end

-- Table of authorities: the cited ones, grouped by kind and sorted; pages come from the aux file.
local KINDS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}
local function toa_blocks(auth)
  local out = { section('Table of Authorities', true) }
  local first = true
  for _, g in ipairs(KINDS) do
    local members = {}
    for key in pairs(cited) do
      if auth[key].kind == g[1] then members[#members + 1] = key end
    end
    table.sort(members, function(x, y) return auth[x].sort < auth[y].sort end)
    if #members > 0 then
      out[#out + 1] = R(string.format('\\toagroup{%s}{%d}', g[2], first and 1 or 0))
      first = false
      for _, key in ipairs(members) do
        local a = auth[key]
        out[#out + 1] = R(string.format('\\toaitem{%s}{%s}{%d}{%s}', a.name or '', a.cite, a.kind == 'case' and 1 or 0, key))
      end
    end
  end
  return out
end

-- The TOC rows: every outlined heading, front matter and body alike, in document order.
local function toc_rows()
  local s = {}
  for i, h in ipairs(heads) do
    if h.outlined then s[#s + 1] = string.format('\\tocline{%d}{%s}{%s}{%d}', h.ind, h.label, h.title, i) end
  end
  return table.concat(s, '\n')
end

function Pandoc(doc)
  local meta = doc.meta
  local auth = authorities_of(meta)

  -- Citations: a link to toa:KEY records the authority and marks the page it sits on.
  local blocks = doc.blocks:walk({
    Link = function(l)
      if l.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = l.target:sub(5)
      if not auth[key] then
        error('ca6-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
      end
      cited[key] = true
      local out = { pandoc.RawInline('latex', '\\toahit{' .. key .. '}') }
      for _, x in ipairs(l.content) do out[#out + 1] = x end
      return out
    end,
  })
  blocks = pandoc.Pandoc(blocks):walk({ Inlines = inlines }).blocks
  -- Quotations: 12.6 bp between their paragraphs (typst: par spacing inside the quote).
  blocks = blocks:walk({
    BlockQuote = function(q)
      local c = pandoc.Blocks({})
      for i, b in ipairs(q.content) do
        if i > 1 then c:insert(R('\\par\\addvspace{12.6bp}')) end
        c:insert(b)
      end
      q.content = c
      return q
    end,
  })

  -- The addendum (after "# Addendum") sits after the certificates and the designation.
  local main, add = pandoc.List(), nil
  for i, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 and trim(plain(b.content):lower()) == 'addendum' then
      add = pandoc.List({ table.unpack(blocks, i + 1) })
      break
    end
    main:insert(b)
  end

  local words = source_words()
  if words > WORD_LIMIT then
    error('ca6-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(i) allows ' .. WORD_LIMIT)
  end

  -- The parts, in order; the TOC rows are filled in once every heading is known.
  local out = pandoc.List()
  -- ---- cover, then the front matter (roman numerals, from the disclosure page) ----
  out:insert(R('\\normalsize'))   -- \begin{document} reset the size
  out:insert(R(cover(meta)))
  out:insert(R('\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}'))
  out:insert(section('Circuit Rule 26.1 Disclosure Statement', false))
  out:insert(R(single(meta.disclosure)))
  out:insert(R('\\clearpage'))
  out:insert(section('Table of Contents', false))
  out:insert(R('\\tochead'))
  local toc_at = #out + 1
  out:insert(R(''))
  out:insert(R('\\clearpage'))
  for _, b in ipairs(toa_blocks(auth)) do out:insert(b) end
  out:insert(R('\\clearpage'))
  out:insert(section('Statement in Support of Oral Argument', true))
  for _, b in ipairs(pandoc.Pandoc(meta.oral_argument):walk({ Inlines = inlines }).blocks) do out:insert(b) end

  -- ---- body (arabic from 1) ----
  out:insert(R('\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}'))
  local st = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
  local body = pandoc.List()
  for _, b in ipairs(main) do
    if b.t == 'Header' then body:insert(heading_block(b, st, true)) else body:insert(b) end
  end
  -- The last paragraph is kept on the page with the signature block (unless the body ends on a heading).
  local last = body[#body]
  if last and last.t == 'Para' then
    body[#body] = R('\\begingroup\\interlinepenalty=10000\\relax')
    body:insert(last)
    body:insert(R(signature_tex(meta) .. '\\endgroup'))
  else
    body:insert(R(signature_tex(meta)))
  end
  for _, b in ipairs(body) do out:insert(b) end

  -- ---- certificates and designation (after the signature, each on its own page) ----
  out:insert(R('\\clearpage\\singlespacing'))
  out:insert(R(certificate_of_compliance(meta, words)))
  if not meta.service or meta.service.certificate ~= false then
    out:insert(R('\\clearpage'))
    out:insert(R(certificate_of_service(meta)))
  end
  out:insert(R('\\clearpage'))
  out:insert(R(designation_section(meta)))

  -- ---- addendum: its own pages, numbered Add-1, Add-2, ... ----
  if add then
    out:insert(R('\\clearpage\\normalsize\\renewcommand{\\thepage}{Add-\\arabic{page}}\\setcounter{page}{1}'))
    out:insert(section('Addendum', true))
    local ast = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
    for _, b in ipairs(add) do
      if b.t == 'Header' then out:insert(heading_block(b, ast, false)) else out:insert(b) end
    end
  end

  out[toc_at] = R(toc_rows())
  return pandoc.Pandoc(out, meta)
end
