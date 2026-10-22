-- U.S. Court of Appeals for the Sixth Circuit: reply brief, LaTeX engine.
-- A pandoc filter. It writes the whole brief (cover, contents, authorities, body, signatures, certificates) from the
-- sample's frontmatter and body, with the same rules and numbers as ../typst/ca6-reply-brief.typ. The macros it
-- calls are in template.tex. Rules: ../README.md. No case-specific text here: everything comes from the sample.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the inline rules of lib/latex/xengine.lua run over the
-- body and over every metadata value written here; blocks are spaced with \addvspace as typst spaces them; a block
-- typst keeps whole is a \vbox here.

local xe = require('latex.xengine')

local TOC_DEPTH = 2         -- typst: toc-depth (sections and point headings, FRAP 28(c))
local WORD_LIMIT = 6500     -- CA6-LEN-001: FRAP 32(a)(7)(B)(ii)
local FACE = 'Times New Roman'   -- the typeface the template sets (typst font-family; newtx has its metrics)
local COUNSEL = '2.6in'     -- typst counsel-indent

local cited = {}

local function R(s) return pandoc.RawBlock('latex', s) end
local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

-- Unicode line breaking (typst, Word) never breaks before a closing or separating mark, even after a space
-- (UAX #14 LB13: ". . . ."): such a space is a no-break space here (written as ~, which keeps its width).
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

local function tex(v)
  local t = pandoc.utils.type(v)
  if t == 'Inlines' then
    return tex_blocks({ pandoc.Plain(v) })
  elseif t == 'Blocks' then
    return tex_blocks(v)
  elseif t == 'string' then
    return tex_blocks(pandoc.read(v, 'markdown+smart').blocks)
  end
  error('ca6-reply-brief: unexpected metadata type ' .. tostring(t))
end

local function plain(v) return pandoc.utils.stringify(v) end

local function group_digits(n)
  local s = tostring(n)
  local out = ''
  for i = 1, #s do
    if i > 1 and (#s - i + 1) % 3 == 0 then out = out .. ',' end
    out = out .. s:sub(i, i)
  end
  return out
end

-- The markdown source of the body (the frontmatter off).
local function source_body()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error('ca6-reply-brief: no input file to read', 0) end
  local h = assert(io.open(f, 'r'))
  local src = h:read('a')
  h:close()
  local fm = src:match('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n')
  if not fm then error('ca6-reply-brief: the sample must start with a YAML frontmatter block', 0) end
  return src:sub(#fm + 1)
end

-- typst count-words on the markdown source of the body, step by step, so that every engine certifies the same number.
local function source_words(body)
  local s = body:gsub('<!%-%-.-%-%->', ' ')
  local n = 0
  for line in (s .. '\n'):gmatch('(.-)\r?\n') do
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

-- typst keeps the last paragraph with the signature block unless the source ends on a heading or a footnote
-- definition.
local function keeps_last(body)
  local last = body:gsub('%s+$', ''):match('.*\n[ \t]*\n(.*)$') or body
  return last ~= '' and not last:match('^#') and not last:match('^%[%^')
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
  if n > 26 then error('ca6-reply-brief: more than 26 sub-headings at one level') end
  return string.char((upper and 64 or 96) + n)
end

-- Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
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
  error('ca6-reply-brief: headings deeper than level 5 are not supported')
end

local heads = {}
local function new_head(title_tex, level, ind, label, outlined)
  heads[#heads + 1] = { title = title_tex, level = level, ind = ind, label = label or '', outlined = outlined }
  return #heads
end

local function section(title, outlined)
  local i = new_head('\\MakeUppercase{' .. title .. '}', 1, 0, nil, outlined)
  return R('\\caHeadOne{' .. title .. '}{' .. i .. '}')
end

-- A heading of the body [style-heading]: level 1 a section; every other level numbered, its label at
-- (level - 2) half inches in the Argument and (level - 1) elsewhere (typst label-indent).
local function heading_block(h, st)
  local title = tex(h.content)
  if h.level == 1 then
    st.in_arg = trim(plain(h.content):lower()) == 'argument'
    for k = 1, 6 do st.counters[k] = 0 end
    return section(title, true)
  end
  st.counters[h.level] = st.counters[h.level] + 1
  for k = h.level + 1, 6 do st.counters[k] = 0 end
  local label = label_for(h.level, st.in_arg, st.counters[h.level])
  local d = st.in_arg and (h.level - 2) or (h.level - 1)
  local i = new_head(title, h.level, d, label, h.level <= TOC_DEPTH)
  return R(string.format('\\caHeadSub{%d}{%d}{%s}{%s}{%d}', d, h.level, label, title, i))
end

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

-- The cover (CA6-COVER-001 to -005) [cover-body]: centered single-spaced lines; the court in a 4.4 in column.
local function cover(m)
  local s = {
    '\\thispagestyle{empty}\\begingroup\\singlespacing\\parindent=0pt\\relax',
    '\\cacenter{No. ' .. tex(m.case_number) .. '}',
    '\\cagap\\par\\begingroup\\centering\\leftskip=\\dimexpr(\\textwidth-4.4in)/2\\relax plus 1fil\\rightskip=\\leftskip\\noindent'
      .. '\\textbf{IN THE UNITED STATES COURT OF APPEALS FOR THE SIXTH CIRCUIT}\\par\\endgroup',
    '\\cagap\\caShortRule\\cagap',
  }
  for i, side in ipairs(m.caption) do
    for _, n in ipairs(side.names) do s[#s + 1] = '\\cacenter{' .. tex(n) .. '}' end
    s[#s + 1] = '\\cacenter{' .. tex(side.designation) .. '}'
    if i < #m.caption then s[#s + 1] = '\\cagap\\cacenter{v.}\\cagap' end
  end
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  s[#s + 1] = '\\cacenter{' .. tex(m.proceeding) .. '}'
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  s[#s + 1] = '\\cacenter{\\textbf{\\MakeUppercase{' .. tex(m.brief_title) .. '}}}'
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  for gi, g in ipairs(m.counsel) do
    if gi > 1 then s[#s + 1] = '\\cagap' end
    for _, n in ipairs(g.names) do s[#s + 1] = '\\caright{' .. COUNSEL .. '}{' .. tex(n) .. '}' end
    for _, l in ipairs(g.lines or {}) do s[#s + 1] = '\\caright{' .. COUNSEL .. '}{' .. tex(l) .. '}' end
  end
  s[#s + 1] = '\\par\\endgroup'
  return table.concat(s, '\n')
end

-- The signature block [signature-block]: 19.6 bp above; "Respectfully submitted," at the margin; each signer 19.6 bp
-- below, at 2.6 in: "s/ Name" and the lines. Not split.
local function signature_tex(m)
  local s = { '\\par\\nobreak\\addvspace{19.6bp}\\begingroup\\singlespacing\\parindent=0pt\\relax\\interlinepenalty=10000\\relax',
    '\\noindent Respectfully submitted,\\par' }
  for _, sig in ipairs(m.signatures) do
    s[#s + 1] = '\\nobreak\\vskip 19.6bp'
    s[#s + 1] = '\\casig{' .. COUNSEL .. '}{s/ ' .. tex(sig.signer) .. '}'
    for _, l in ipairs(sig.lines or {}) do s[#s + 1] = '\\casig{' .. COUNSEL .. '}{' .. tex(l) .. '}' end
  end
  s[#s + 1] = '\\endgroup'
  return table.concat(s, '\n')
end

-- A certificate's signature [cert-signature]: 22.4 bp above, at 2.6 in: "s/ Name" and the name.
local function cert_signature(m)
  local sig = m.signatures[1]
  return '\\nobreak\\vskip 22.4bp\\casig{' .. COUNSEL .. '}{s/ ' .. tex(sig.signer) .. '}\\casig{' .. COUNSEL .. '}{'
    .. tex(sig.signer) .. '}'
end

-- Fed.~R.~App.~P.: no-break spaces, as typst writes them
local FRAP = 'Fed.~R.~App.~P.~'

local function certificate_of_compliance(m, words)
  return table.concat({
    section('Certificate of Compliance', true).text,
    '\\par\\addvspace{14bp}\\vbox{\\singlespacing\\parindent=0pt\\relax',
    '\\noindent This reply brief complies with the type-volume limitation of ' .. FRAP .. '32(a)(7)(B) because it contains '
      .. group_digits(words) .. ' words, excluding the parts of the brief exempted by ' .. FRAP .. '32(f).\\par',
    '\\vskip 14bp\\noindent This reply brief complies with the typeface requirements of ' .. FRAP .. '32(a)(5) and the type-style requirements of '
      .. FRAP .. '32(a)(6) because it has been prepared in a proportionally spaced typeface, 14\\mbox{-}point ' .. FACE .. '.\\par',
    cert_signature(m),
    '}',
  }, '\n')
end

local function certificate_of_service(m)
  return table.concat({
    section('Certificate of Service', true).text,
    '\\par\\addvspace{14bp}\\vbox{\\singlespacing\\parindent=0pt\\relax',
    '\\noindent I certify that I electronically filed and served this ' .. tex(m.brief_title)
      .. ' using the Court\'s CM/ECF system upon ' .. tex(m.service.upon) .. ' on ' .. tex(m.date) .. '.\\par',
    cert_signature(m),
    '}',
  }, '\n')
end

local KINDS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}
-- The table of authorities [toa-section]: name, a comma and the cite on one line (typst: no line break).
local function toa_blocks(auth)
  local out = { section('Table of Authorities', false) }
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
        local text = a.cite
        if a.name then text = (a.kind == 'case' and ('\\emph{' .. a.name .. '}') or a.name) .. ', ' .. a.cite end
        out[#out + 1] = R(string.format('\\toaitem{}{%s}{0}{%s}', text, key))
      end
    end
  end
  return out
end

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

  local blocks = doc.blocks:walk({
    Link = function(l)
      if l.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = l.target:sub(5)
      if not auth[key] then
        error('ca6-reply-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
      end
      cited[key] = true
      local out = { pandoc.RawInline('latex', '\\toahit{' .. key .. '}') }
      for _, x in ipairs(l.content) do out[#out + 1] = x end
      return out
    end,
  })
  blocks = pandoc.Pandoc(blocks):walk({ Inlines = inlines }).blocks
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

  local src = source_body()
  local words = source_words(src)
  if words > WORD_LIMIT then
    error('ca6-reply-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(ii) allows ' .. WORD_LIMIT .. ' for a reply brief')
  end

  local out = pandoc.List()
  out:insert(R('\\normalsize'))
  out:insert(R(cover(meta)))
  out:insert(R('\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}'))
  out:insert(section('Table of Contents', false))
  out:insert(R('\\tochead'))
  local toc_at = #out + 1
  out:insert(R(''))
  out:insert(R('\\clearpage'))
  for _, b in ipairs(toa_blocks(auth)) do out:insert(b) end

  out:insert(R('\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}'))
  local st = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
  local body = pandoc.List()
  for _, b in ipairs(blocks) do
    if b.t == 'Header' then body:insert(heading_block(b, st)) else body:insert(b) end
  end
  local last = body[#body]
  if keeps_last(src) and last and last.t == 'Para' then
    body[#body] = R('\\begingroup\\interlinepenalty=10000\\relax')
    body:insert(last)
    body:insert(R(signature_tex(meta) .. '\\endgroup'))
  else
    body:insert(R('\\par\\addvspace{19.6bp}\\vbox{' .. signature_tex(meta):gsub('^\\par\\nobreak\\addvspace{19.6bp}', '', 1) .. '}'))
  end
  for _, b in ipairs(body) do out:insert(b) end

  out:insert(R('\\singlespacing'))
  out:insert(R(certificate_of_compliance(meta, words)))
  if meta.service and meta.service.certificate then
    out:insert(R('\\clearpage'))
    out:insert(R(certificate_of_service(meta)))
  end

  out[toc_at] = R(toc_rows())
  return pandoc.Pandoc(out, meta)
end
