-- Fourth Circuit brief, LaTeX engine (pandoc Lua filter; see ../README.md, "Engines").
-- Writes everything that comes from the frontmatter as raw LaTeX, in document order: the cover, the disclosure
-- statement, the table of contents and of authorities, the numbered headings, the signature block, the
-- certificates and the addendum. The body goes through pandoc, except citations (toa: links) and block quotations.
-- Rules and numbers follow typst/ca4-*.typ for this brief type. This file is identical in the three doc-type
-- folders except for DOCTYPE on the next line.

local DOCTYPE = 'opening-brief'

local CFG = ({
  ['opening-brief'] = {
    numbering = 'all',       -- sub-headings numbered everywhere (I. / A. / 1. / a. in the Argument, A. / 1. / a. elsewhere)
    base = 1,                -- heading label indent = (level - base) * 0.5 in
    point_centered = false,  -- Argument point headings hang like the other sub-headings
    big_h1 = false,          -- section headings at body size
    limit = 13000,           -- FRAP 32(a)(7)(B)(i)
    limit_name = 'FRAP 32(a)(7)(B)(i)',
    count = 'request',       -- the request for oral argument is not counted (FRAP 32(f)): it is the last section
    sig = 'opening',
    cert = 'opening',
    service_default = true,  -- the certificate of service is shown unless the frontmatter says otherwise
  },
  ['answering-brief'] = {
    numbering = 'argument',  -- only the Argument's sub-headings are numbered
    base = 2,
    point_centered = true,   -- Argument point headings centred in small capitals
    big_h1 = true,
    limit = 13000,
    limit_name = 'FRAP 32(a)(7)(B)(i)',
    count = 'all',
    sig = 'answering',
    cert = 'answering',
    service_default = false,
  },
  ['reply-brief'] = {
    numbering = 'all',
    base = 1,
    point_centered = false,
    big_h1 = true,
    limit = 6500,            -- CA4-LEN-001: half the principal-brief limit
    limit_name = 'FRAP 32(a)(7)(B)(ii)',
    count = 'addendum',      -- the addendum is not part of the reply (FRAP 28(f))
    sig = 'reply',
    cert = 'reply',
    service_default = false,
  },
})[DOCTYPE]

local TAB = 0.5
local COUNSEL_FOR = nil

-- ---- strings ----

local function esc(s)
  return (s:gsub('[\\{}%$&%%#_%^~]', {
    ['\\'] = '\\textbackslash{}', ['{'] = '\\{', ['}'] = '\\}', ['$'] = '\\$', ['&'] = '\\&',
    ['%'] = '\\%', ['#'] = '\\#', ['_'] = '\\_', ['^'] = '\\textasciicircum{}', ['~'] = '\\textasciitilde{}',
  }))
end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

-- Frontmatter or inline content (markup kept: italics) to LaTeX.
local function ltx(v)
  if v == nil then return '' end
  if type(v) == 'string' then return esc(v) end
  if type(v) == 'boolean' then return tostring(v) end
  local ty = pandoc.utils.type(v)
  if ty == 'Inlines' then
    return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(v) }), 'latex'))
  elseif ty == 'Blocks' then
    return trim(pandoc.write(pandoc.Pandoc(v), 'latex'))
  end
  return esc(pandoc.utils.stringify(v))
end

-- A frontmatter list (caption sides, counsel groups, lines), as a Lua array.
local function items(v)
  local out = {}
  if v ~= nil then
    for _, x in ipairs(v) do out[#out + 1] = x end
  end
  return out
end

local function plain(v) return trim(pandoc.utils.stringify(v or '')) end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return (out:gsub('^,', ''))
end

local function roman(n)
  local vals = { { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }
  local out = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function alpha(n) return string.char(string.byte('A') + n - 1) end

-- ---- headings ----

local counters = { 0, 0, 0, 0, 0, 0 }
local in_argument = false
local in_addendum = false

local function heading_label(lvl, n)
  if in_argument then
    if lvl == 2 then return roman(n) .. '.'
    elseif lvl == 3 then return alpha(n) .. '.'
    elseif lvl == 4 then return tostring(n) .. '.'
    elseif lvl == 5 then return string.char(96 + n) .. '.' end
  else
    if lvl == 2 then return alpha(n) .. '.'
    elseif lvl == 3 then return tostring(n) .. '.'
    elseif lvl == 4 then return string.char(96 + n) .. '.'
    elseif lvl == 5 then return '(' .. n .. ')' end
  end
  error('ca4-brief: headings deeper than level 5 are not supported')
end

local function numbered(lvl)
  if lvl < 2 then return false end
  if CFG.numbering == 'all' then return true end
  return in_argument
end

local function indent_in(lvl)
  return string.format('%gin', (lvl - CFG.base) * TAB)
end

-- A level-1 heading's display text (capitals): larger in the answering and reply briefs (typst: 1.15 em).
local function h1_display(s)
  if CFG.big_h1 then return '{\\fontsize{16.1pt}{20pt}\\selectfont\\textbf{' .. s .. '}}' end
  return '\\textbf{' .. s .. '}'
end

local function header(h)
  local lvl = h.level
  local text = plain(h.content)
  if lvl == 1 then
    in_argument = text:lower() == 'argument'
    in_addendum = text:lower() == 'addendum'
    for i = 2, 6 do counters[i] = 0 end
    counters[1] = counters[1] + 1
    return pandoc.RawBlock('latex', '\\brfsection{' .. h1_display('\\MakeUppercase{' .. ltx(h.content) .. '}') .. '}\n'
      .. '\\addcontentsline{toc}{brfone}{' .. esc(text:upper()) .. '}')
  end
  counters[lvl] = counters[lvl] + 1
  for i = lvl + 1, 6 do counters[i] = 0 end
  local title = ltx(h.content)
  local deep = lvl >= 4
  local function style(s) if deep then return '\\textbf{\\textit{' .. s .. '}}' end return '\\textbf{' .. s .. '}' end
  if in_addendum then
    -- addendum headings are not numbered; the addendum's own table of contents lists the level-2 ones
    return pandoc.RawBlock('latex', '\\brfunnum{' .. string.format('%gin', (lvl - 2) * TAB) .. '}{' .. style(title) .. '}\n'
      .. (lvl == 2 and '\\addcontentsline{adt}{brfadd}{' .. title .. '}' or ''))
  end
  if not numbered(lvl) then
    -- unnumbered sub-heading: its toc entry has the same indent as typst's
    local ind = string.format('%gin', (lvl - 2) * TAB)
    return pandoc.RawBlock('latex', '\\brfunnum{' .. ind .. '}{' .. style(title) .. '}\n'
      .. '\\addcontentsline{toc}{brfu' .. ({ 'two', 'three', 'four' })[lvl - 1] .. '}{' .. title .. '}')
  end
  local label = heading_label(lvl, counters[lvl])
  if lvl == 2 and CFG.point_centered and in_argument then
    -- centred point heading: "I. TITLE" in bold, not small capitals (Times New Roman has none, as typst and docx
    -- render, and newtx bold small capitals would shrink the bold font descriptor); its toc entry has no indent
    return pandoc.RawBlock('latex', '\\brfpoint{' .. esc(label) .. '\\ ' .. style(title) .. '}\n'
      .. '\\addcontentsline{toc}{brfpoint}{\\protect\\numberline{' .. esc(label) .. '}' .. title .. '}')
  end
  local toc_type = ({ 'brftwo', 'brfthree', 'brffour' })[lvl - 1]
  return pandoc.RawBlock('latex', '\\brfsub{' .. indent_in(lvl) .. '}{' .. style(esc(label)) .. '}{' .. style(title) .. '}\n'
    .. '\\addcontentsline{toc}{' .. toc_type .. '}{\\protect\\numberline{' .. esc(label) .. '}' .. title .. '}')
end

-- ---- cover (FRAP 32(a)(2)) ----

-- The cover is one page, single-spaced; `gap` is the space between its parts. Rules are boxes with no
-- interline space, so a rule costs its own height only.
local function cover(m, gap)
  local rule2 = '\\cvrule{\\linewidth}{1.6pt}\\vskip 2.5pt\\cvrule{\\linewidth}{0.5pt}'
  local short = '\\cvrule{2in}{0.7pt}'
  local out = {}
  local function add(s) out[#out + 1] = s end
  add('\\thispagestyle{empty}\\begin{center}\\singlespacing')
  add('\\textbf{No. ' .. ltx(m.case_number) .. '}\\par\\vskip ' .. gap)
  add(rule2 .. '\\par\\vskip ' .. gap)
  add('\\textbf{IN THE\\\\UNITED STATES COURT OF APPEALS\\\\FOR THE FOURTH CIRCUIT}\\par\\vskip ' .. gap)
  add(short .. '\\par\\vskip ' .. gap)
  local sides = items(m.caption)
  for i, side in ipairs(sides) do
    for _, name in ipairs(items(side.names)) do
      add(ltx(name) .. '\\par')
    end
    add('\\hspace*{0.5\\textwidth}\\parbox[t]{0.5\\textwidth}{\\raggedright ' .. ltx(side.designation) .. '}\\par')
    if i < #sides then add('\\vskip ' .. gap .. 'v.\\par\\vskip ' .. gap) end
  end
  add('\\vskip ' .. gap .. short .. '\\par\\vskip ' .. gap)
  add(ltx(m.proceeding) .. '\\par')
  if m.district_court_case ~= nil or m.judge ~= nil then
    local parts = {}
    if m.district_court_case ~= nil then parts[#parts + 1] = 'Case No. ' .. ltx(m.district_court_case) end
    if m.judge ~= nil then parts[#parts + 1] = ltx(m.judge) end
    add('\\vskip ' .. gap .. table.concat(parts, ', ') .. '\\par')
  end
  add('\\vskip ' .. gap .. short .. '\\par\\vskip ' .. gap)
  add('\\textbf{' .. ltx(m.brief_title):upper() .. '}\\par\\vskip ' .. gap)
  add(short .. '\\par\\vskip ' .. gap)
  add('\\end{center}')
  -- counsel: one group in the right half of the page; two or more groups side by side in two columns
  -- (typst: counsel-group in a two-column grid). Lines are roman; markdown italics are kept.
  local counsel = items(m.counsel)
  local function group(g)
    local s = {}
    for _, n in ipairs(items(g.names)) do s[#s + 1] = ltx(n) .. '\\\\' end
    local lines = items(g.lines)
    if m.phone ~= nil and g == counsel[#counsel] then lines[#lines + 1] = m.phone end
    for _, l in ipairs(lines) do s[#s + 1] = ltx(l) .. '\\\\' end
    return table.concat(s, '\n')
  end
  add('\\begin{flushleft}\\singlespacing')
  if #counsel == 1 then
    add('\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright')
    add(group(counsel[1]))
    add('\\end{minipage}')
  else
    for gi, g in ipairs(counsel) do
      add('\\begin{minipage}[t]{0.47\\textwidth}\\raggedright')
      add(group(g))
      add('\\end{minipage}' .. (gi % 2 == 1 and gi < #counsel and '\\hfill' or '\\par\\vskip ' .. gap))
    end
  end
  add('\\end{flushleft}')
  if m.date ~= nil and m.party_line ~= nil then
    add('\\vskip ' .. gap .. '\\begin{tabular*}{\\linewidth}{@{}l@{\\extracolsep{\\fill}}r@{}}' .. ltx(m.date)
      .. ' & ' .. ltx(m.party_line) .. '\\end{tabular*}')
  end
  add('\\vskip ' .. gap .. rule2)
  add('\\clearpage')
  return pandoc.RawBlock('latex', table.concat(out, '\n'))
end

-- ---- disclosure statement (FRAP 26.1; answering brief) ----

local DISCLOSURE_QUESTIONS = {
  'Is party/amicus a publicly held corporation or other publicly held entity?',
  'Does party/amicus have any parent corporations?',
  'Is 10% or more of the stock of a party/amicus owned by a publicly held corporation or other publicly held entity?',
  'Is there any other publicly held corporation or other publicly held entity that has a direct financial interest in the outcome of the litigation?',
  'Is party a trade association? (amici curiae do not complete this question)',
  'Does this case arise out of a bankruptcy proceeding?',
  'Is this a criminal case in which there was an organizational victim?',
}

local function box(checked)
  if checked then return '\\fbox{\\makebox[0.72em][c]{\\rule{0pt}{0.72em}X}}' end
  return '\\fbox{\\rule{0pt}{0.72em}\\makebox[0.72em]{}}'
end

local function disclosure(m)
  local d = m.disclosure
  local answers = items(d.answers)
  if #answers ~= #DISCLOSURE_QUESTIONS then
    error('ca4-brief: disclosure.answers needs one yes or no for each of the ' .. #DISCLOSURE_QUESTIONS .. ' questions')
  end
  local out = {}
  out[#out + 1] = "\\thispagestyle{empty}\\singlespacing\\begin{center}"
  out[#out + 1] = '\\textbf{UNITED STATES COURT OF APPEALS FOR THE FOURTH CIRCUIT}\\\\[0.6em]'
  out[#out + 1] = '\\textbf{DISCLOSURE STATEMENT}\\\\[0.6em]No. ' .. ltx(m.case_number) .. '\\end{center}\\vskip 1em'
  out[#out + 1] = 'Pursuant to FRAP 26.1 and Local Rule 26.1, ' .. ltx(d.party) .. ', who is ' .. ltx(d.role)
    .. ', makes the following disclosure:\\par'
  for i, q in ipairs(DISCLOSURE_QUESTIONS) do
    -- YAML reads a bare `no` as false (and `yes` as true)
    local a = answers[i] == false and 'no' or answers[i] == true and 'yes' or plain(answers[i])
    if a ~= 'yes' and a ~= 'no' then error('ca4-brief: disclosure answer ' .. i .. ' must be `yes` or `no`') end
    out[#out + 1] = '\\par\\vskip 0.9em\\noindent\\begin{minipage}{\\linewidth}' .. i .. '.\\ ' .. esc(q)
      .. '\\\\\\hspace*{1.6em}YES\\hspace{0.4em}' .. box(a == 'yes') .. '\\hspace{2.4em}NO\\hspace{0.4em}' .. box(a == 'no')
      .. '\\end{minipage}'
  end
  out[#out + 1] = '\\par\\vskip 1.6em\\noindent\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright'
    .. '/s/ ' .. ltx(d.signer) .. '\\\\' .. ltx(d.date) .. "\\end{minipage}\\clearpage"
  return pandoc.RawBlock('latex', table.concat(out, '\n'))
end

-- ---- signature and certificates ----

local function signature(m)
  local sig = m.signature
  local out = { '\\par\\needspace{12\\baselineskip}\\vspace{1.4em}\\noindent\\hspace*{0.5\\textwidth}',
    '\\begin{minipage}[t]{0.5\\textwidth}\\raggedright\\singlespacing' }
  out[#out + 1] = 'Respectfully submitted,\\\\[1.2em]'
  if CFG.sig == 'opening' then
    out[#out + 1] = '/s/ ' .. ltx(sig.signer) .. '\\\\'
    out[#out + 1] = ltx(sig.signer):upper()
    for _, l in ipairs(items(sig.lines)) do out[#out + 1] = '\\\\\\hspace*{0.5em}\\emph{' .. ltx(l) .. '}' end
  elseif CFG.sig == 'answering' then
    for _, l in ipairs(items(sig.lead)) do out[#out + 1] = ltx(l) .. '\\\\' end
    out[#out + 1] = '\\vskip 0.6em /s/ ' .. ltx(sig.signer)
    for _, l in ipairs(items(sig.lines)) do out[#out + 1] = '\\\\' .. ltx(l) end
  else
    out[#out + 1] = '/s/ ' .. ltx(sig.signer) .. '\\\\'
    out[#out + 1] = ltx(sig.signer):upper()
    for _, l in ipairs(items(sig.lines)) do out[#out + 1] = '\\\\\\hspace*{0.5em}\\emph{' .. ltx(l) .. '}' end
  end
  out[#out + 1] = '\\end{minipage}'
  if m.date ~= nil and CFG.sig ~= 'answering' then out[#out + 1] = '\\par\\vskip 0.8em ' .. ltx(m.date) end
  return pandoc.RawBlock('latex', table.concat(out, '\n'))
end

-- /s/ and the signer's name, in the right half (typst: signature-only)
local function signature_only(m)
  return '\\par\\vskip 1.6em\\noindent\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright\\singlespacing'
    .. '/s/ ' .. ltx(m.signature.signer) .. '\\end{minipage}\\par'
end

-- Signature of a certificate of counsel (opening brief): /s/, the name, and the first title line.
local function certificate_signature(m)
  local sig = m.signature
  local first = items(sig.lines)[1]
  local s = '\\par\\vskip 1.6em\\noindent\\singlespacing/s/ ' .. ltx(sig.signer) .. '\\\\' .. ltx(sig.signer):upper()
  if first ~= nil then s = s .. '\\\\\\emph{' .. ltx(first) .. '}' end
  return s .. '\\par'
end

-- Form signature line (reply brief: Form 6): the signature over a line with its label, and the date.
local function form_signature(m)
  return '\\par\\needspace{6\\baselineskip}\\vskip 1.6em\\noindent\\singlespacing'
    .. '\\begin{tabular*}{\\linewidth}{@{}p{0.45\\linewidth}@{\\extracolsep{\\fill}}p{0.45\\linewidth}@{}}'
    .. '/s/ ' .. ltx(m.signature.signer) .. '\\newline\\rule{\\linewidth}{0.4pt}\\newline Signature &'
    .. ltx(m.date) .. '\\newline\\rule{\\linewidth}{0.4pt}\\newline Date\\end{tabular*}\\par'
end

local function certificate_compliance(m, words)
  local h = '\\brfsection{' .. (CFG.cert == 'answering' and '\\MakeUppercase{Certificate of Compliance}' or 'CERTIFICATE OF COMPLIANCE') .. '}'
  local toc = CFG.cert == 'answering' and '' or '\\addcontentsline{toc}{brfone}{CERTIFICATE OF COMPLIANCE}'
  local body
  if CFG.cert == 'opening' then
    body = '{\\singlespacing\\noindent Pursuant to Federal Rule of Appellate Procedure 32(a)(7)(B), I certify that this brief is '
      .. 'proportionately spaced and contains ' .. group_digits(words)
      .. ' words excluding parts of the document exempted by Rule 32(f).\\par}' .. certificate_signature(m)
  elseif CFG.cert == 'answering' then
    body = '{\\singlespacing\\noindent 1.\\hspace{0.5em}This brief complies with the type-volume limitation of Federal Rule of '
      .. 'Appellate Procedure 32(a)(7)(B) because this brief contains ' .. group_digits(words)
      .. ' words, excluding the parts of the brief exempted by Rule 32(f).\\par\\vskip 1em\\noindent'
      .. '2.\\hspace{0.5em}This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) '
      .. 'and the type style requirements of Rule 32(a)(6) because this brief has been prepared in a proportionally spaced '
      .. 'typeface, Times, in fourteen-point type.\\par}' .. signature_only(m)
  else
    body = '{\\singlespacing\\noindent I, ' .. ltx(m.signature.signer) .. ', counsel for ' .. ltx(COUNSEL_FOR or 'the party')
      .. ' and a member of the bar of this Court, certify that the attached reply brief is proportionally spaced, has a typeface of 14 points, and contains '
      .. group_digits(words) .. ' words as calculated pursuant to Fed. R. App. P. 32(f) and 32(a)(7)(B)(ii).\\par}' .. form_signature(m)
  end
  return pandoc.RawBlock('latex', '\\clearpage' .. h .. '\n' .. toc .. '\n' .. body)
end

local function certificate_service(m)
  local h = '\\brfsection{' .. (CFG.cert == 'answering' and '\\MakeUppercase{Certificate of Service}' or 'CERTIFICATE OF SERVICE') .. '}'
  local toc = CFG.cert == 'answering' and '' or '\\addcontentsline{toc}{brfone}{CERTIFICATE OF SERVICE}'
  local body
  if CFG.cert == 'opening' then
    body = '{\\singlespacing\\noindent I certify that on ' .. ltx(m.date) .. ', the ' .. ltx(m.brief_title)
      .. ' was served on all parties or their counsel of record through the CM/ECF system.\\par}' .. certificate_signature(m)
  elseif CFG.cert == 'answering' then
    body = '{\\singlespacing\\noindent I hereby certify that on this ' .. ltx(m.service.date) .. ', the foregoing '
      .. ltx(m.brief_title) .. ' was served on ' .. ltx(m.service.served_on) .. '.\\par}' .. signature_only(m)
  else
    body = '{\\singlespacing\\noindent I hereby certify that I electronically filed the foregoing document on this date with the '
      .. 'Clerk of the Court for the United States Court of Appeals for the Fourth Circuit using the CM/ECF system, which will '
      .. 'send notice of this filing to all registered CM/ECF users.\\par}' .. form_signature(m)
  end
  -- the answering brief's service certificate follows the compliance certificate on the same page when it fits
  local lead = CFG.cert == 'answering' and '\\vskip 1.6em' or '\\clearpage'
  return pandoc.RawBlock('latex', lead .. h .. '\n' .. toc .. '\n' .. body)
end

-- ---- table of authorities ----

local TOA_GROUPS = {
  { 'case', 'Cases:' },
  { 'constitution', 'Constitutional Provisions:' },
  { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' },
  { 'rule', 'Rules:' },
  { 'other', 'Other Authorities:' },
}

local function toa_sort_key(a)
  local s = a.sort and plain(a.sort) or (plain(a.name or '') .. ' ' .. plain(a.cite))
  return (s:lower():gsub('[^a-z0-9 ]', ''))
end

local function toa(auth, hits)
  local out = {}
  out[#out + 1] = '\\brfsection{TABLE OF AUTHORITIES}\n\\addcontentsline{toc}{brfone}{TABLE OF AUTHORITIES}'
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y) return toa_sort_key(x.a) < toa_sort_key(y.a) end)
    if #members > 0 then
      out[#out + 1] = '\\brftoagroup{' .. g[2] .. '}{' .. (first and 1 or 0) .. '}'
      first = false
      for _, mem in ipairs(members) do
        local a = mem.a
        local name, has = '', 0
        if a.name ~= nil then
          name = plain(a.kind) == 'case' and ('\\emph{' .. ltx(a.name) .. '}') or ltx(a.name)
          has = 1
        end
        out[#out + 1] = '\\brftoaentry{' .. name .. '}{' .. ltx(a.cite) .. '}{' .. mem.key .. '}{' .. has .. '}'
      end
    end
  end
  return pandoc.RawBlock('latex', table.concat(out, '\n'))
end

-- ---- the filter ----

-- Words as typst counts them: runs of non-space characters in the text (an em dash joins two words),
-- footnote text included, markup and list numbers not.
local function count_words(blocks)
  local n = 0
  -- a space after each paragraph, so that list items do not run together
  local function spaced(p)
    local c = pandoc.Inlines(p.content)
    c:insert(pandoc.Space())
    return pandoc.Plain(c)
  end
  for _, b in ipairs(blocks) do
    local with_notes = pandoc.Pandoc({ b }):walk({
      -- a footnote's text is a word of its own, after the mark (typst counts the note where it is written)
      Note = function(note)
        local c = pandoc.Inlines({ pandoc.Space() })
        for _, x in ipairs(pandoc.utils.blocks_to_inlines(note.content)) do c:insert(x) end
        return pandoc.Span(c)
      end,
      Para = spaced,
      Plain = spaced,
    })
    -- pandoc's smart extension joins some abbreviations to the next word with a no-break space
    local text = pandoc.utils.stringify(with_notes.blocks):gsub('\194\160', ' ')
    local _, c = text:gsub('%S+', '')
    n = n + c
  end
  return n
end

local function is_h1(b, name)
  return b.t == 'Header' and b.level == 1 and plain(b.content):lower() == name
end

function Pandoc(doc)
  local m = doc.meta
  for _, k in ipairs({ 'case_number', 'caption', 'proceeding', 'brief_title', 'counsel', 'signature' }) do
    if m[k] == nil then error('ca4-brief: missing required metadata field `' .. k .. '`') end
  end
  local auth = m.authorities or {}
  COUNSEL_FOR = m['counsel-for']

  -- citations: every toa: link needs an authority; the hit is recorded for the table of authorities
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = el.target:sub(5)
      if auth[key] == nil then error('ca4-brief: link `toa:' .. key .. '` has no entry under `authorities:`') end
      hits[key] = true
      local content = pandoc.Inlines({})
      for _, x in ipairs(el.content) do content:insert(x) end
      content:insert(pandoc.RawInline('latex', '\\brfhit{' .. key .. '}'))
      return content
    end,
  })

  -- split the body: the addendum (reply) follows the certificates; the request (opening) is the last section
  local body, addendum = {}, {}
  local split = false
  for _, b in ipairs(doc.blocks) do
    if CFG.count == 'addendum' and is_h1(b, 'addendum') then split = true end
    if split then addendum[#addendum + 1] = b else body[#body + 1] = b end
  end

  -- length: the words of the body (FRAP 32(a)(7)(B)); the request for oral argument is excluded (FRAP 32(f))
  local counted = {}
  local stop = false
  for _, b in ipairs(body) do
    if CFG.count == 'request' and is_h1(b, 'request for oral argument') then stop = true end
    if not stop then counted[#counted + 1] = b end
  end
  local words = count_words(counted)
  if words > CFG.limit then
    error('ca4-brief: the brief has ' .. words .. ' words; ' .. CFG.limit_name .. ' allows ' .. CFG.limit)
  end

  -- headings and block quotations (headings numbered in document order)
  local function map(blocks)
    local pd = pandoc.Pandoc(blocks):walk({
      Header = header,
      BlockQuote = function(el)
        local out = { pandoc.RawBlock('latex', '\\begin{quote}\\singlespacing\\par\\leftskip=0.5in\\rightskip=0.5in\\noindent\\ignorespaces') }
        for _, b in ipairs(el.content) do out[#out + 1] = b end
        out[#out + 1] = pandoc.RawBlock('latex', '\\par\\end{quote}')
        return out
      end,
    })
    return pd.blocks
  end
  body = map(body)
  addendum = map(addendum)

  -- front matter: cover, disclosure, contents, authorities
  local front = pandoc.Blocks({})
  front:insert(cover(m, '8pt'))
  if m.disclosure ~= nil then front:insert(disclosure(m)) end
  local toa_hits = hits
  front:insert(pandoc.RawBlock('latex', '\\pagenumbering{roman}\\setcounter{page}{1}\\brfcontents\\clearpage'))
  front:insert(toa(auth, toa_hits))
  front:insert(pandoc.RawBlock('latex', '\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}'))

  -- the body; its last paragraph is kept with the signature block (typst: keep the tail with the signature)
  local main = pandoc.Blocks({})
  local last = #body
  for i, b in ipairs(body) do
    if i == last and b.t == 'Para' then main:insert(pandoc.RawBlock('latex', '\\needspace{10\\baselineskip}')) end
    main:insert(b)
  end
  main:insert(signature(m))

  -- certificates
  main:insert(certificate_compliance(m, words))
  local show_service = CFG.service_default
  if m.service ~= nil and m.service.certificate ~= nil then show_service = m.service.certificate == true end
  if show_service then
    main:insert(certificate_service(m))
  end

  -- addendum (reply): its own page numbers, Add-1 ...; its contents list the level-2 headings
  if #addendum > 0 then
    main:insert(pandoc.RawBlock('latex', '\\clearpage\\renewcommand\\thepage{Add-\\arabic{page}}\\setcounter{page}{1}'))
    for i, b in ipairs(addendum) do
      main:insert(b)
      -- after the addendum's own heading: its contents (the level-2 headings), then a new page
      if i == 1 then main:insert(pandoc.RawBlock('latex', '\\brfcontentsadd\\clearpage')) end
    end
  end

  local all = pandoc.Blocks({})
  all:extend(front)
  all:extend(main)
  doc.blocks = all
  return doc
end
