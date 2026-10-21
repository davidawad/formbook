-- U.S. Court of Appeals for the Sixth Circuit: appellant's principal brief, LaTeX engine.
-- A pandoc filter. It writes the whole brief (cover, front matter, body, signature, certificates,
-- designation, addendum) from the sample's frontmatter and body, with the same rules and numbers as
-- ../typst/ca6-opening-brief.typ. The macros it calls are in template.tex. Rules: ../README.md.
-- No case-specific text here: everything comes from the sample.

local cited, order = {}, {}

local function R(s) return pandoc.RawBlock('latex', s) end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

-- Metadata (or any pandoc inline/block list, or a markdown string) as LaTeX.
local function tex(v)
  local t = pandoc.utils.type(v)
  if t == 'Inlines' then
    return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(v) }), 'latex'))
  elseif t == 'Blocks' then
    return trim(pandoc.write(pandoc.Pandoc(v), 'latex'))
  elseif t == 'string' then
    return trim(pandoc.write(pandoc.read(v, 'markdown+smart'), 'latex'))
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

-- A heading becomes one macro call (template.tex): level 1 is a section, the Argument's level 2 is the
-- centred point heading, and every other numbered level is a sub-heading whose depth d steps 0.5 in.
local function heading_block(h, st, numbered)
  local title = tex(h.content)
  if h.level == 1 then
    st.in_arg = trim(plain(h.content):lower()) == 'argument'
    if numbered then
      st.counters[1] = st.counters[1] + 1
      for k = 2, 6 do st.counters[k] = 0 end
    end
    return R('\\caHeadOne{' .. title .. '}')
  end
  if not numbered then return R('\\caHeadPlain{' .. title .. '}') end
  st.counters[h.level] = st.counters[h.level] + 1
  for k = h.level + 1, 6 do st.counters[k] = 0 end
  local label = label_for(h.level, st.in_arg, st.counters[h.level])
  if st.in_arg and h.level == 2 then
    return R('\\caHeadPoint{' .. label .. '}{' .. title .. '}')
  end
  local d = st.in_arg and (h.level - 2) or (h.level - 1)
  return R(string.format('\\caHeadSub{%d}{%d}{%s}{%s}', d, h.level, label, title))
end

-- FRAP 32(a)(7)(B)(i) counts the body: the words of the markdown, footnotes included, the
-- footnote numbers the plain writer prints left out.
local function count_words(blocks)
  local s = pandoc.write(pandoc.Pandoc(blocks), 'plain')
  s = s:gsub('%[%d+%]', ' ')
  s = s:gsub('\194\160', ' ')   -- smart puts no-break spaces after abbreviations ("Inc. v."); a word processor splits there
  local n = 0
  for _ in s:gmatch('%S+') do n = n + 1 end
  return n
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

local function caption_tex(m)
  local s = {}
  for i, side in ipairs(m.caption) do
    local names = {}
    for _, n in ipairs(side.names) do names[#names + 1] = tex(n) end
    s[#s + 1] = '\\begin{caCenter}' .. table.concat(names, '\\\\') .. '\\end{caCenter}'
    s[#s + 1] = '\\begin{caLeft}\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright '
      .. tex(side.designation) .. '\\end{minipage}\\end{caLeft}'
    if i < #m.caption then
      s[#s + 1] = '\\begin{caCenter}\\vspace{4.2bp}v.\\vspace{4.2bp}\\end{caCenter}'
    end
  end
  return table.concat(s, '\n')
end

local function counsel_tex(m)
  local s = { '\\begin{caLeft}\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright\\singlespacing' }
  for gi, g in ipairs(m.counsel) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = tex(n) .. '\\\\' end
    local extra = {}
    for _, l in ipairs(g.lines or {}) do extra[#extra + 1] = '\\hspace*{0.5em}\\emph{' .. tex(l) .. '}\\\\' end
    if gi == #m.counsel then extra[#extra + 1] = '\\hspace*{0.5em}\\emph{' .. tex(m.phone) .. '}\\\\' end
    s[#s + 1] = table.concat(lines, '\n') .. '\n' .. table.concat(extra, '\n')
    if gi < #m.counsel then s[#s + 1] = '\\vspace{0.5em}' end
  end
  s[#s + 1] = '\\end{minipage}\\end{caLeft}'
  return table.concat(s, '\n')
end

local function cover(m)
  return table.concat({
    '{\\thispagestyle{empty}\\singlespacing',
    '\\vspace*{3bp}\\begin{caCenter}\\textbf{No. ' .. tex(m.case_number) .. '}\\end{caCenter}',
    '\\vspace{\\caGap}\\caDoubleRule\\vspace{\\caGap}',
    '\\begin{caCenter}\\textbf{IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE SIXTH CIRCUIT}\\end{caCenter}',
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    caption_tex(m),
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    '\\begin{caCenter}' .. tex(m.proceeding) .. '\\end{caCenter}',
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    '\\begin{caCenter}\\textbf{\\MakeUppercase{' .. tex(m.brief_title) .. '}}\\end{caCenter}',
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    counsel_tex(m),
    '\\vspace{\\caGap}\\caDoubleRule}',
  }, '\n')
end

-- The signature block after the Conclusion (FRAP 32(d)).
local function signature_tex(m)
  local sig = m.signature
  local lines = {}
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = '\\hspace*{0.5em}\\emph{' .. tex(l) .. '}\\\\' end
  local dated = m.date and ('Dated: ' .. tex(m.date) .. '\\par\\nopagebreak\\vspace{0.8em}\\nopagebreak\n') or ''
  return '\\nopagebreak\\par\\nopagebreak\\vspace{1.4em}' .. dated ..
    '{\\singlespacing\\noindent\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright\n' ..
    'Respectfully submitted,\\\\[1.2em]\n' ..
    '/s/ ' .. tex(sig.signer) .. '\\\\\n' .. tex(sig.signer) .. '\\\\\n' .. table.concat(lines, '\n') ..
    '\n\\end{minipage}}'
end

-- Signature line for a certificate: "/s/ Name" and the date (FRAP 25(d)).
local function form_sig_line(m)
  return '\\par\\vspace{1.6em}\\noindent\\begin{minipage}[t]{0.48\\textwidth}\\raggedright /s/ '
    .. tex(m.signature.signer) .. '\\\\ Signature\\end{minipage}\\hfill'
    .. '\\begin{minipage}[t]{0.48\\textwidth}\\raggedright ' .. tex(m.date or '') .. '\\\\ Date\\end{minipage}\\par'
end

local function certificate_of_compliance(m, words)
  return table.concat({
    '\\caHeadOne{Certificate of Compliance}',
    '\\begin{caSingle}This brief complies with: (1) the type-volume limitation of Federal Rule of Appellate Procedure 32(a)(7)(B) because it contains '
      .. group_digits(words) .. ' words, excluding the parts of the brief exempted by Rule 32(f); and (2) the typeface requirements of Rule 32(a)(5) and the type style requirements of Rule 32(a)(6) because it has been prepared in a proportionally spaced typeface (14-point Times) using LaTeX (pdfLaTeX, TeX Live 2025). The word count is computed from the markdown source of this brief.\\end{caSingle}',
    form_sig_line(m),
  }, '\n')
end

local function certificate_of_service(m)
  return table.concat({
    '\\caHeadOne{Certificate of Service}',
    '\\begin{caSingle}I certify that on ' .. tex(m.date) .. ', this brief was served via CM/ECF on all registered counsel and transmitted to the Clerk of the Court.\\end{caSingle}',
    form_sig_line(m),
  }, '\n')
end

local function designation_section(m)
  local rows = {}
  for _, d in ipairs(m.designation) do
    rows[#rows + 1] = tex(d.date) .. ' & ' .. tex(d.rno) .. ' & ' .. tex(d.description) .. '\\\\[0.6em]'
  end
  return table.concat({
    '\\caHeadOne{Designation of District Court Record}',
    '\\begin{caSingle}' .. tex(m.designation_intro or
      'The appellant designates the following filings from the District Court\'s electronic records under Sixth Circuit Rules 28(b)(1)(A)(i) and 30(g)(1):') .. '\\end{caSingle}',
    -- three columns and two 0.15 in gaps that together fill the line: 1.5 + 0.15 + 2.3 + 0.15 + (linewidth - 4.1) in
    '\\begin{caSingle}\\begin{longtable}{@{}>{\\raggedright\\arraybackslash}p{1.5in}@{\\hspace{0.15in}}>{\\raggedright\\arraybackslash}p{2.3in}@{\\hspace{0.15in}}>{\\raggedright\\arraybackslash}p{\\dimexpr\\linewidth-4.1in\\relax}@{}}',
    '\\textbf{Date Filed} & \\textbf{R.No.; Page ID \\#} & \\textbf{Description of Document}\\\\[0.6em]',
    table.concat(rows, '\n'),
    '\\end{longtable}\\end{caSingle}',
  }, '\n')
end

-- Table of authorities: the cited ones, grouped by kind and sorted; pages come from the aux file.
local KINDS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}
local function toa_blocks(auth)
  local out = { R('\\caHeadOne{Table of Authorities}') }
  local first = true
  for _, g in ipairs(KINDS) do
    local members = {}
    for _, key in ipairs(order) do
      if auth[key].kind == g[1] then members[#members + 1] = key end
    end
    table.sort(members, function(x, y) return auth[x].sort < auth[y].sort end)
    if #members > 0 then
      out[#out + 1] = R(string.format('\\caToaGroup{%s}{%d}', g[2], first and 1 or 0))
      first = false
      for _, key in ipairs(members) do
        local a = auth[key]
        local disp = a.cite
        if a.name then
          local name = a.kind == 'case' and ('\\emph{' .. a.name .. '}') or a.name
          disp = name .. ',\\\\' .. a.cite
        end
        out[#out + 1] = R(string.format('\\caToaEntry{%s}{%s}', disp, key))
      end
    end
  end
  return out
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
      if not cited[key] then
        cited[key] = true
        order[#order + 1] = key
      end
      local out = { pandoc.RawInline('latex', '\\toahit{' .. key .. '}') }
      for _, x in ipairs(l.content) do out[#out + 1] = x end
      return out
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

  local words = count_words(main)
  if words > 13000 then
    error('ca6-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(i) allows 13000')
  end

  local out = pandoc.List()
  -- ---- cover, then the front matter (roman numerals, from the disclosure page) ----
  out:insert(R('\\doublespacing'))   -- \begin{document} reset the size; the body is double-spaced again
  out:insert(R(cover(meta)))
  out:insert(R('\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}'))
  out:insert(R('\\caHeadOneNoToc{Circuit Rule 26.1 Disclosure Statement}'))
  out:insert(R('\\begin{caSingle}'))
  out:insert(R(tex(meta.disclosure)))
  out:insert(R('\\end{caSingle}\\clearpage'))
  out:insert(R('\\caHeadOneNoToc{Table of Contents}\\par\\hfill\\textbf{\\underline{Page}}\\par\\caTocList'))
  out:insert(R('\\clearpage'))
  for _, b in ipairs(toa_blocks(auth)) do out:insert(b) end
  out:insert(R('\\clearpage'))
  out:insert(R('\\caHeadOne{Statement in Support of Oral Argument}'))
  out:insert(R(tex(meta.oral_argument)))

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
    body[#body] = R('\\begin{samepage}')
    body:insert(last)
    body:insert(R(signature_tex(meta)))
    body:insert(R('\\end{samepage}'))
  else
    body:insert(R(signature_tex(meta)))
  end
  for _, b in ipairs(body) do out:insert(b) end

  -- ---- certificates and designation (after the signature, each on its own page) ----
  out:insert(R('\\clearpage'))
  out:insert(R(certificate_of_compliance(meta, words)))
  if not meta.service or meta.service.certificate ~= false then
    out:insert(R('\\clearpage'))
    out:insert(R(certificate_of_service(meta)))
  end
  out:insert(R('\\clearpage'))
  out:insert(R(designation_section(meta)))

  -- ---- addendum: its own pages, numbered Add-1, Add-2, ... ----
  if add then
    out:insert(R('\\clearpage\\renewcommand{\\thepage}{Add-\\arabic{page}}\\setcounter{page}{1}'))
    out:insert(R('\\caHeadOne{Addendum}'))
    local ast = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
    for _, b in ipairs(add) do
      if b.t == 'Header' then out:insert(heading_block(b, ast, false)) else out:insert(b) end
    end
  end

  return pandoc.Pandoc(out, meta)
end
