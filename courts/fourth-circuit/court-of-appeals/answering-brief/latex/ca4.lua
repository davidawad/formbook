-- Fourth Circuit brief, LaTeX engine (pandoc Lua filter; see ../README.md, "Engines").
-- Writes everything that comes from the frontmatter as raw LaTeX, in document order: the cover, the disclosure
-- statement, the table of contents and of authorities, the numbered headings, the signature block, the
-- certificates and the addendum. The body goes through pandoc, except citations (toa: links).
-- Rules and numbers follow typst/ca4-*.typ for this brief type; the macros are in template.tex. This file is identical
-- in the three doc-type folders except for DOCTYPE on the next line.

local DOCTYPE = 'answering-brief'

local CFG = ({
  ['opening-brief'] = {
    numbering = 'all',       -- sub-headings numbered everywhere (I. / A. / 1. / a. in the Argument, A. / 1. / a. elsewhere)
    base = 1,                -- heading label indent = (level - base) * 0.5 in
    point_centered = false,  -- Argument point headings hang like the other sub-headings
    big_h1 = false,          -- section headings at body size
    italic_from = 4,         -- sub-headings from this level are bold italic (label too)
    limit = 13000,           -- FRAP 32(a)(7)(B)(i)
    limit_name = 'FRAP 32(a)(7)(B)(i)',
    count = 'request',       -- the request for oral argument is not counted (FRAP 32(f)): it is the last section
    toc_front = true,        -- the table of authorities and the certificates are listed in the contents
    toa_above = '7bp',       -- space above each authority (typst: 0.5em)
    sig = 'opening',
    cert = 'opening',
    service_default = true,  -- the certificate of service is shown unless the frontmatter says otherwise
  },
  ['answering-brief'] = {
    numbering = 'argument',  -- only the Argument's sub-headings are numbered
    base = 2,
    point_centered = true,   -- Argument point headings centred, bold
    big_h1 = true,
    italic_from = 99,
    limit = 13000,
    limit_name = 'FRAP 32(a)(7)(B)(i)',
    count = 'all',
    toc_front = false,
    toa_above = '9.8bp',
    sig = 'answering',
    cert = 'answering',
    service_default = false,
  },
  ['reply-brief'] = {
    numbering = 'all',
    base = 1,
    point_centered = false,
    big_h1 = true,
    italic_from = 4,
    limit = 6500,            -- CA4-LEN-001: half the principal-brief limit
    limit_name = 'FRAP 32(a)(7)(B)(ii)',
    count = 'addendum',      -- the addendum is not part of the reply (FRAP 28(f))
    toc_front = true,
    toa_above = '9.8bp',
    sig = 'reply',
    cert = 'reply',
    service_default = false,
  },
})[DOCTYPE]

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_inlines = require('latex.xengine').inlines

local TAB = 0.5

-- ---- strings ----

local function esc(s)
  return (s:gsub('[\\{}%$&%%#_%^~]', {
    ['\\'] = '\\textbackslash{}', ['{'] = '\\{', ['}'] = '\\}', ['$'] = '\\$', ['&'] = '\\&',
    ['%'] = '\\%', ['#'] = '\\#', ['_'] = '\\_', ['^'] = '\\textasciicircum{}', ['~'] = '\\textasciitilde{}',
  }))
end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

-- Frontmatter or inline content (markup kept: italics) to LaTeX, through the cross-engine inline rules.
local function ltx(v)
  if v == nil then return '' end
  if type(v) == 'boolean' then return tostring(v) end
  if type(v) == 'string' then v = pandoc.Inlines({ pandoc.Str(v) }) end
  local ty = pandoc.utils.type(v)
  if ty == 'Inlines' then
    return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(xe_inlines(v)) }), 'latex'))
  elseif ty == 'Blocks' then
    return trim(pandoc.write(pandoc.Pandoc(v):walk({ Inlines = xe_inlines }), 'latex'))
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

local function raw(s) return pandoc.RawBlock('latex', s) end

-- ---- headings ----

local counters = { 0, 0, 0, 0, 0, 0 }
local in_argument = false
local in_addendum = false
local HEADS = {}   -- the contents: { level, ind (a TeX dimension), label, title, idx, addendum }

local function heading_label(lvl, n)
  if in_argument or CFG.numbering == 'argument' then
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
  if lvl < 2 or in_addendum then return false end
  if CFG.numbering == 'all' then return true end
  return in_argument
end

local function dim(halves) return string.format('%gin', halves * TAB) end

-- A level-1 heading's display text (capitals): 16 pt in the answering and reply briefs (typst: 1.15 em, in whole
-- half points).
local function h1_display(s)
  if CFG.big_h1 then return '{\\cabig\\textbf{' .. s .. '}}' end
  return '\\textbf{' .. s .. '}'
end

local function add_head(level, ind, label, title, toc)
  HEADS[#HEADS + 1] = { level = level, ind = ind, label = label, title = title, idx = #HEADS + 1, toc = toc,
    addendum = in_addendum }
  return #HEADS
end

local function header(h)
  local lvl = h.level
  local text = plain(h.content)
  if lvl == 1 then
    in_argument = text:lower() == 'argument'
    in_addendum = in_addendum or text:lower() == 'addendum'
    for i = 2, 6 do counters[i] = 0 end
    counters[1] = counters[1] + 1
    local idx = add_head(1, '0pt', '', '\\MakeUppercase{' .. ltx(h.content) .. '}', true)
    return raw('\\brfsection{' .. h1_display('\\MakeUppercase{' .. ltx(h.content) .. '}') .. '}{' .. idx .. '}')
  end
  counters[lvl] = counters[lvl] + 1
  for i = lvl + 1, 6 do counters[i] = 0 end
  local title = ltx(h.content)
  local deep = lvl >= CFG.italic_from
  local function style(s) if deep then return '\\textbf{\\textit{' .. s .. '}}' end return '\\textbf{' .. s .. '}' end
  if not numbered(lvl) then
    -- unnumbered sub-heading: bold at the margin (typst); its contents row steps in as typst's
    local toc_ind = in_addendum and dim(lvl - 2) or (CFG.numbering == 'argument' and dim(lvl - 1) or dim(lvl - 2))
    local idx = add_head(lvl, toc_ind, '', title, not in_addendum or lvl == 2)
    return raw('\\brfunnum{0pt}{' .. style(title) .. '}{' .. idx .. '}')
  end
  local label = heading_label(lvl, counters[lvl])
  if lvl == 2 and CFG.point_centered and in_argument then
    -- centred point heading: "I. TITLE" in bold (no small capitals: Word and LaTeX synthesize them differently)
    local idx = add_head(lvl, '0pt', esc(label), title, true)
    return raw('\\brfpoint{\\textbf{' .. esc(label) .. ' ' .. title .. '}}{' .. idx .. '}')
  end
  local ind = dim(lvl - CFG.base)
  local idx = add_head(lvl, ind, esc(label), title, true)
  return raw('\\brfsub{' .. ind .. '}{' .. style(esc(label)) .. '}{' .. style(title) .. '}{' .. idx .. '}')
end

-- ---- cover (FRAP 32(a)(2)) ----

-- The gaps between the cover's parts: 7 bp, more to fill the page, none when the page is full (typst: the largest
-- gap at which the cover fits one page). Rules cost their own height only.
local GAP = '\\par\\vskip 7bp plus 1fill minus 7bp\\relax'
local RULE2 = '\\cvrule{\\linewidth}{1.6pt}\\vskip 2.5pt\\cvrule{\\linewidth}{0.5pt}'
local SHORT = '\\cvrule{2in}{0.7pt}'

local function cover(m)
  local out = {}
  local function add(s) out[#out + 1] = s end
  add('\\thispagestyle{empty}\\begingroup\\centering\\singlespacing\\parindent=0pt\\parskip=4.9bp\\relax')
  add('\\textbf{No.\\ ' .. ltx(m.case_number) .. '}' .. GAP)
  add(RULE2 .. GAP)
  if DOCTYPE == 'opening-brief' then
    add('\\textbf{IN THE\\\\UNITED STATES COURT OF APPEALS\\\\FOR THE FOURTH CIRCUIT}' .. GAP)
  else
    add('\\textbf{IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE FOURTH CIRCUIT}' .. GAP)
  end
  add(SHORT .. GAP)
  local sides = items(m.caption)
  for i, side in ipairs(sides) do
    for _, name in ipairs(items(side.names)) do add(ltx(name) .. '\\par') end
    add('{\\leftskip=0.5\\linewidth\\rightskip=0pt plus 1fil\\relax\\noindent ' .. ltx(side.designation) .. '\\par}')
    if i < #sides then add('\\vskip 2bp plus 0.3fill\\relax v.\\par\\vskip 2bp plus 0.3fill\\relax') end
  end
  add(GAP .. SHORT .. GAP)
  add(ltx(m.proceeding) .. '\\par')
  if DOCTYPE == 'answering-brief' and m.judge ~= nil then add(ltx(m.judge) .. '\\par') end
  if DOCTYPE == 'reply-brief' and (m.district_court_case ~= nil or m.judge ~= nil) then
    local parts = {}
    if m.district_court_case ~= nil then parts[#parts + 1] = 'Case No. ' .. ltx(m.district_court_case) end
    if m.judge ~= nil then parts[#parts + 1] = ltx(m.judge) end
    add(table.concat(parts, ', ') .. '\\par')
  end
  add(GAP .. SHORT .. GAP)
  add('\\textbf{\\MakeUppercase{' .. ltx(m.brief_title) .. '}}' .. GAP)
  add(SHORT .. GAP)
  -- counsel (FRAP 32(a)(2)(F)): one group in the right half of the page; in the opening brief, two or more groups
  -- side by side in two columns of (text width - 1.5 em) / 2 (typst: a grid). Lines are roman; markdown italics kept.
  local counsel = items(m.counsel)
  local function group(g, last)
    local s = {}
    for _, n in ipairs(items(g.names)) do s[#s + 1] = ltx(n) .. '\\par' end
    local lines = items(g.lines)
    if last and DOCTYPE ~= 'opening-brief' and m.phone ~= nil then lines[#lines + 1] = m.phone end
    for _, l in ipairs(lines) do s[#s + 1] = ltx(l) .. '\\par' end
    return table.concat(s, '\n')
  end
  if DOCTYPE == 'opening-brief' and #counsel > 1 then
    local function col(g)
      return '\\begin{minipage}[t]{\\dimexpr(\\linewidth-21bp)/2\\relax}\\singlespacing\\raggedright\\parindent=0pt '
        .. group(g, false) .. '\\end{minipage}'
    end
    for i = 1, #counsel, 2 do
      local row = col(counsel[i])
      if counsel[i + 1] ~= nil then row = row .. '\\hfill' .. col(counsel[i + 1]) else row = row .. '\\hfill\\null' end
      add('\\carow{' .. row .. '}\\addvspace{11.2bp}')
    end
  else
    add('{\\leftskip=0.5\\linewidth\\rightskip=0pt plus 1fil\\relax\\parskip=0pt')
    for gi, g in ipairs(counsel) do
      add(group(g, gi == #counsel))
      if gi < #counsel then add('\\vskip 7bp') end
    end
    add('}')
  end
  if DOCTYPE == 'answering-brief' then
    add(GAP .. '{\\raggedright\\noindent ' .. ltx(m.date) .. '\\hfill ' .. ltx(m.party_line) .. '\\par}\\vskip 4.2bp')
  end
  add(GAP .. RULE2)
  add('\\par\\endgroup\\clearpage')
  return raw(table.concat(out, '\n'))
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

-- A ruled box around a literal X (checked) or around a space of its width (typst checkbox; Word: a bordered run).
local function box(checked)
  local x = checked and 'X' or '\\phantom{X}'
  return '{\\setlength{\\fboxsep}{1bp}\\setlength{\\fboxrule}{0.7bp}\\fbox{' .. x .. '}}'
end

local function disclosure(m)
  local d = m.disclosure
  local answers = items(d.answers)
  if #answers ~= #DISCLOSURE_QUESTIONS then
    error('ca4-brief: disclosure.answers needs one yes or no for each of the ' .. #DISCLOSURE_QUESTIONS .. ' questions')
  end
  local out = {}
  out[#out + 1] = '\\thispagestyle{empty}\\begingroup\\singlespacing\\parindent=0pt'
  out[#out + 1] = '{\\centering\\textbf{UNITED STATES COURT OF APPEALS FOR THE FOURTH CIRCUIT}\\par\\addvspace{8.4bp}'
    .. '\\textbf{DISCLOSURE STATEMENT}\\par\\addvspace{8.4bp}No.\\ ' .. ltx(m.case_number) .. '\\par}\\addvspace{14bp}'
  out[#out + 1] = 'Pursuant to FRAP 26.1 and Local Rule 26.1, ' .. ltx(d.party) .. ', who is ' .. ltx(d.role)
    .. ', makes the following disclosure:\\par'
  for i, q in ipairs(DISCLOSURE_QUESTIONS) do
    -- YAML reads a bare `no` as false (and `yes` as true)
    local a = answers[i] == false and 'no' or answers[i] == true and 'yes' or plain(answers[i])
    if a ~= 'yes' and a ~= 'no' then error('ca4-brief: disclosure answer ' .. i .. ' must be `yes` or `no`') end
    out[#out + 1] = '\\addvspace{12.6bp}\\begingroup\\interlinepenalty=10000\\relax\\noindent ' .. i .. '. ' .. esc(q)
      .. '\\par\\nobreak\\noindent\\hspace*{1.6em}YES\\hspace{0.4em} ' .. box(a == 'yes') .. '\\hspace{2.4em} NO\\hspace{0.4em} '
      .. box(a == 'no') .. '\\par\\endgroup'
  end
  out[#out + 1] = '\\addvspace{22.4bp}{\\leftskip=0.5\\linewidth\\noindent /s/ ' .. ltx(d.signer) .. '\\par\\nobreak\\noindent '
    .. ltx(d.date) .. '\\par}\\endgroup\\clearpage'
  return raw(table.concat(out, '\n'))
end

-- ---- signature and certificates ----

-- [signature-block]: 19.6 bp above; in the right half "Respectfully submitted," then 16.8 bp and the signature; the
-- date at the margin 11.2 bp below. Kept with the brief's last paragraph.
local function signature(m)
  local sig = m.signature
  local L = { '\\par\\nobreak\\addvspace{19.6bp}\\nobreak',
    '\\begingroup\\singlespacing\\leftskip=0.5\\linewidth\\parindent=0pt\\interlinepenalty=10000\\relax' }
  L[#L + 1] = 'Respectfully submitted,\\par\\nobreak'
  if CFG.sig == 'answering' then
    L[#L + 1] = '\\vspace{16.8bp}\\nobreak'
    for _, l in ipairs(items(sig.lead)) do L[#L + 1] = ltx(l) .. '\\par\\nobreak' end
    L[#L + 1] = '\\vspace{8.4bp}\\nobreak /s/ ' .. ltx(sig.signer) .. '\\par\\nobreak'
    for _, l in ipairs(items(sig.lines)) do L[#L + 1] = ltx(l) .. '\\par\\nobreak' end
    L[#L + 1] = '\\endgroup'
    return raw(table.concat(L, '\n'))
  end
  L[#L + 1] = '\\vspace{16.8bp}\\nobreak'
  L[#L + 1] = (CFG.sig == 'reply' and 's/ ' or '/s/ ') .. ltx(sig.signer) .. '\\par\\nobreak'
  L[#L + 1] = '\\MakeUppercase{' .. ltx(sig.signer) .. '}\\par\\nobreak'
  L[#L + 1] = '\\advance\\leftskip 0.5em'
  for _, l in ipairs(items(sig.lines)) do L[#L + 1] = '\\emph{' .. ltx(l) .. '}\\par\\nobreak' end
  L[#L + 1] = '\\endgroup'
  if m.date ~= nil then
    L[#L + 1] = '\\nobreak\\vspace{11.2bp}\\nobreak\\begingroup\\singlespacing\\noindent ' .. ltx(m.date) .. '\\par\\endgroup'
  end
  return raw(table.concat(L, '\n'))
end

-- /s/ and the signer's name, in the right half (typst: signature-only), 22.4 bp below the text
local function signature_only(m)
  return '\\par\\nobreak\\addvspace{22.4bp}\\nobreak{\\singlespacing\\leftskip=0.5\\linewidth\\noindent /s/ '
    .. ltx(m.signature.signer) .. '\\par}'
end

-- Signature of a certificate of counsel (opening brief): /s/, the name, and the first title line, 22.4 bp below.
local function certificate_signature(m)
  local sig = m.signature
  local first = items(sig.lines)[1]
  local s = '\\par\\nobreak\\addvspace{22.4bp}\\nobreak\\begingroup\\singlespacing\\noindent /s/ ' .. ltx(sig.signer)
    .. '\\par\\nobreak\\noindent\\MakeUppercase{' .. ltx(sig.signer) .. '}'
  if first ~= nil then s = s .. '\\par\\nobreak\\noindent\\emph{' .. ltx(first) .. '}' end
  return s .. '\\par\\endgroup'
end

-- Form signature line (reply brief: Form 6): "s/ Name" over "Signature", the date over "Date"; the right column
-- starts (text width + 1 em) / 2 in (typst grid), 22.4 bp below the text.
local function form_signature(m)
  return '\\par\\nobreak\\addvspace{22.4bp}\\nobreak\\begingroup\\singlespacing\\noindent\\makebox[241bp][l]{s/ '
    .. ltx(m.signature.signer) .. '}' .. ltx(m.date) .. '\\par\\nobreak\\noindent\\makebox[241bp][l]{Signature}Date\\par\\endgroup'
end

local function cert_head(title, idx)
  return '\\brfsection{' .. h1_display(title) .. '}{' .. idx .. '}'
end

local function certificate_compliance(m, words)
  local idx = add_head(1, '0pt', '', 'CERTIFICATE OF COMPLIANCE', CFG.toc_front)
  local body
  if CFG.cert == 'opening' then
    body = '\\begingroup\\singlespacing\\noindent Pursuant to Federal Rule of Appellate Procedure 32(a)(7)(B), I certify that this brief is '
      .. 'proportionately spaced and contains ' .. group_digits(words)
      .. ' words excluding parts of the document exempted by Rule 32(f).\\par\\endgroup' .. certificate_signature(m)
  elseif CFG.cert == 'answering' then
    body = '\\begingroup\\singlespacing\\noindent 1.\\hspace{0.5em}This brief complies with the type-volume limitation of Federal Rule of '
      .. 'Appellate Procedure 32(a)(7)(B) because this brief contains ' .. group_digits(words)
      .. ' words, excluding the parts of the brief exempted by Rule 32(f).\\par\\addvspace{14bp}\\noindent '
      .. '2.\\hspace{0.5em}This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) '
      .. 'and the type style requirements of Rule 32(a)(6) because this brief has been prepared in a proportionally spaced '
      .. 'typeface, Times New Roman, in fourteen-point type.\\par\\endgroup' .. signature_only(m)
  else
    body = '\\begingroup\\singlespacing\\noindent I, ' .. ltx(m.signature.signer) .. ', counsel for '
      .. ltx(m['counsel-for'] or 'the party')
      .. ' and a member of the bar of this Court, certify that the attached reply brief is proportionally spaced, has a typeface of 14 points, and contains '
      .. group_digits(words) .. ' words as calculated pursuant to Fed. R. App. P. 32(f) and 32(a)(7)(B)(ii).\\par\\endgroup'
      .. form_signature(m)
  end
  return raw('\\clearpage' .. cert_head('CERTIFICATE OF COMPLIANCE', idx) .. '\n' .. body)
end

local function certificate_service(m)
  local idx = add_head(1, '0pt', '', 'CERTIFICATE OF SERVICE', CFG.toc_front)
  local body
  if CFG.cert == 'opening' then
    body = '\\begingroup\\singlespacing\\noindent I certify that on ' .. ltx(m.date) .. ', the ' .. ltx(m.brief_title)
      .. ' was served on all parties or their counsel of record through the CM/ECF system.\\par\\endgroup' .. certificate_signature(m)
  elseif CFG.cert == 'answering' then
    body = '\\begingroup\\singlespacing\\noindent I hereby certify that on this ' .. ltx(m.service.date) .. ', the foregoing '
      .. ltx(m.brief_title) .. ' was served on ' .. ltx(m.service.served_on) .. '.\\par\\endgroup' .. signature_only(m)
  else
    local s = { '\\begingroup\\singlespacing\\parskip=14bp\\noindent I hereby certify that I electronically filed the foregoing document on this date with the '
      .. 'Clerk of the Court for the United States Court of Appeals for the Fourth Circuit using the CM/ECF system, which will '
      .. 'send notice of this filing to all registered CM/ECF users.\\par' }
    local unreg = items(m.service and m.service.unregistered)
    if #unreg > 0 then
      s[#s + 1] = '\\noindent\\textbf{Service on Participants Who Are NOT Registered for Electronic Filing:}\\par'
      s[#s + 1] = '\\noindent I certify that I served the foregoing document on this date by hand delivery, mail, third-party commercial carrier, or email, as indicated, to the following unregistered participants (name and address of each):\\par'
      for _, u in ipairs(unreg) do
        s[#s + 1] = '\\addvspace{9.8bp}{\\leftskip=0.5in\\interlinepenalty=10000\\noindent ' .. ltx(u.name) .. ', ' .. ltx(u.address) .. '\\par}'
      end
    end
    body = table.concat(s, '\n') .. '\\endgroup' .. form_signature(m)
  end
  -- the answering brief's service certificate follows the compliance certificate on the same page when it fits
  local lead = CFG.cert == 'answering' and '\\par\\addvspace{22.4bp}' or '\\clearpage'
  return raw(lead .. cert_head('CERTIFICATE OF SERVICE', idx) .. '\n' .. body)
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

local function toa(auth, hits, idx)
  local out = { '\\brfsection{' .. h1_display('TABLE OF AUTHORITIES') .. '}{' .. idx .. '}' }
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
        local name = ''
        if a.name ~= nil then
          name = plain(a.kind) == 'case' and ('\\emph{' .. ltx(a.name) .. '}') or ltx(a.name)
        end
        out[#out + 1] = '\\brftoaentry{' .. CFG.toa_above .. '}{' .. name .. '}{' .. ltx(a.cite) .. '}{' .. mem.key .. '}'
      end
    end
  end
  return raw(table.concat(out, '\n'))
end

-- ---- contents ----

local function toc(addendum)
  local out = {}
  for _, h in ipairs(HEADS) do
    if h.toc and h.addendum == addendum and h.level <= (addendum and 2 or 4) and not (addendum and h.level == 1) then
      out[#out + 1] = '\\tocline{' .. (h.level == 1 and '8.4bp' or '4.9bp') .. '}{' .. h.ind .. '}{' .. h.label .. '}{'
        .. h.title .. '}{' .. h.idx .. '}'
    end
  end
  return table.concat(out, '\n')
end

-- ---- the filter ----

-- Words as typst counts them: whitespace-delimited words of the markdown source, markup, footnote marks and list
-- numbers not counted; block by block (stringify of the whole document would run words together), footnote text
-- included.
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

local function is_h1(b, name)
  return b.t == 'Header' and b.level == 1 and plain(b.content):lower() == name
end

function Pandoc(doc)
  local m = doc.meta
  for _, k in ipairs({ 'case_number', 'caption', 'proceeding', 'brief_title', 'counsel', 'signature' }) do
    if m[k] == nil then error('ca4-brief: missing required metadata field `' .. k .. '`') end
  end
  local auth = m.authorities or {}

  -- citations: every toa: link needs an authority; the hit is recorded for the table of authorities. The mark goes
  -- after the first word, so that a citation that begins a line is filed under that line's page.
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = el.target:sub(5)
      if auth[key] == nil then error('ca4-brief: link `toa:' .. key .. '` has no entry under `authorities:`') end
      hits[key] = true
      -- the mark after the first word (typst tag-after-first-word): a citation that runs over a page end is filed
      -- under the page it begins on
      local placed = false
      local content = pandoc.Inlines(el.content):walk({
        Str = function(s)
          if placed then return nil end
          placed = true
          return { s, pandoc.RawInline('latex', '\\brfhit{' .. key .. '}') }
        end,
      })
      if not placed then content:insert(pandoc.RawInline('latex', '\\brfhit{' .. key .. '}')) end
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
  local words = count_blocks(counted)
  if words > CFG.limit then
    error('ca4-brief: the brief has ' .. words .. ' words; ' .. CFG.limit_name .. ' allows ' .. CFG.limit)
  end

  -- the cross-engine inline rules over the body text
  body = pandoc.Pandoc(body):walk({ Inlines = xe_inlines }).blocks
  addendum = pandoc.Pandoc(addendum):walk({ Inlines = xe_inlines }).blocks

  -- the table of authorities is a heading of the contents (before the body's)
  local toa_idx = add_head(1, '0pt', '', 'TABLE OF AUTHORITIES', CFG.toc_front)

  -- headings, numbered in document order
  body = pandoc.Pandoc(body):walk({ Header = header }).blocks

  -- the body; its last paragraph is kept with the signature block (typst: one unbreakable block)
  local main = pandoc.Blocks({})
  local last = #body
  for i, b in ipairs(body) do
    if i == last and b.t == 'Para' then
      main:insert(raw('\\begingroup\\interlinepenalty=10000\\relax'))
      main:insert(b)
      main:insert(raw('\\par\\endgroup'))
    else
      main:insert(b)
    end
  end
  main:insert(signature(m))

  -- certificates
  main:insert(certificate_compliance(m, words))
  local show_service = CFG.service_default
  if m.service ~= nil and m.service.certificate ~= nil then show_service = m.service.certificate == true end
  if show_service then main:insert(certificate_service(m)) end

  -- addendum (reply): its own page numbers, Add-1 ...; its contents list the level-2 headings
  if #addendum > 0 then
    in_addendum = true
    addendum = pandoc.Pandoc(addendum):walk({ Header = header }).blocks
    main:insert(raw('\\clearpage\\renewcommand\\thepage{Add-\\arabic{page}}\\setcounter{page}{1}'))
    for i, b in ipairs(addendum) do
      main:insert(b)
      -- after the addendum's own heading: its contents (the level-2 headings), then a new page
      if i == 1 then
        main:insert(raw('\\brfsection{' .. h1_display('TABLE OF CONTENTS') .. '}{addtoc}\n' .. toc(true) .. '\n\\clearpage'))
      end
    end
  end

  -- front matter: cover, disclosure, contents, authorities
  local front = pandoc.Blocks({})
  front:insert(raw('\\singlespacing'))
  front:insert(cover(m))
  if m.disclosure ~= nil then front:insert(disclosure(m)) end
  front:insert(raw('\\pagenumbering{roman}\\setcounter{page}{1}\\brfsection{' .. h1_display('TABLE OF CONTENTS')
    .. '}{toc}\\tochead\n' .. toc(false) .. '\n\\clearpage'))
  front:insert(toa(auth, hits, toa_idx))
  front:insert(raw('\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}\\normalsize'))

  local all = pandoc.Blocks({})
  all:extend(front)
  all:extend(main)
  doc.blocks = all
  return doc
end
