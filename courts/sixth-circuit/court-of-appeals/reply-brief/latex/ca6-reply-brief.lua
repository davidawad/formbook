-- U.S. Court of Appeals for the Sixth Circuit: reply brief, LaTeX engine.
-- A pandoc filter. It writes the whole brief (cover, front matter, body, signature, certificates)
-- from the sample's frontmatter and body, with the same rules and numbers as
-- ../typst/ca6-reply-brief.typ. The macros it calls are in template.tex. Rules: ../README.md.
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
  error('ca6-reply-brief: unexpected metadata type ' .. tostring(t))
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
  if n > 26 then error('ca6-reply-brief: more than 26 sub-headings at one level') end
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
  error('ca6-reply-brief: headings deeper than level 5 are not supported')
end

-- A heading becomes one macro call (template.tex). Level 1 is a section. Every other level is a
-- sub-heading whose label sits d steps from the margin, d = level-2 in the Argument (so its point
-- headings, level 2, hang from the margin) and d = level-1 elsewhere (typst: label-indent).
local function heading_block(h, st)
  local title = tex(h.content)
  if h.level == 1 then
    st.in_arg = trim(plain(h.content):lower()) == 'argument'
    st.counters[1] = st.counters[1] + 1
    for k = 2, 6 do st.counters[k] = 0 end
    return R('\\caHeadOne{' .. title .. '}')
  end
  st.counters[h.level] = st.counters[h.level] + 1
  for k = h.level + 1, 6 do st.counters[k] = 0 end
  local label = label_for(h.level, st.in_arg, st.counters[h.level])
  local d = st.in_arg and (h.level - 2) or (h.level - 1)
  return R(string.format('\\caHeadSub{%d}{%d}{%s}{%s}', d, h.level, label, title))
end

-- FRAP 32(a)(7)(B)(ii) counts the body: the words of the markdown, footnotes included, the
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
    local sortsrc = a.sort and plain(a.sort) or (a.name and plain(a.name) .. " " .. plain(a.cite) or plain(a.cite))
    e.sort = sortsrc:lower():gsub('[^a-z0-9 ]', '')
    out[key] = e
  end
  return out
end

-- Cover (FRAP 32(a)(2)). Everything is centred except the counsel block, which starts 40% in.
local function caption_tex(m)
  local s = {}
  for i, side in ipairs(m.caption) do
    local names = {}
    for _, n in ipairs(side.names) do names[#names + 1] = tex(n) end
    s[#s + 1] = '\\begin{caCenter}' .. table.concat(names, '\\par ') .. '\\par ' .. tex(side.designation) .. '\\end{caCenter}'
    if i < #m.caption then
      s[#s + 1] = '\\vspace{\\caGap}\\begin{caCenter}v.\\end{caCenter}\\vspace{\\caGap}'
    end
  end
  return table.concat(s, '\n')
end

local function counsel_tex(m)
  local s = { '\\begin{caLeft}\\singlespacing\\hspace*{0.4\\textwidth}\\begin{minipage}[t]{0.62\\textwidth}\\raggedright' }
  for gi, g in ipairs(m.counsel) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = tex(n) end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = tex(l) end
    s[#s + 1] = table.concat(lines, '\\\\[4.2pt]\n') .. '\\\\'
    if gi < #m.counsel then s[#s + 1] = '\\vspace{0.5\\caGap}\\vspace{\\caGap}' end
  end
  s[#s + 1] = '\\end{minipage}\\end{caLeft}'
  return table.concat(s, '\n')
end

local function cover(m)
  return table.concat({
    '\\thispagestyle{empty}\\singlespacing',
    '\\vspace*{0.6\\caGap}\\begin{caCenter}No. ' .. tex(m.case_number) .. '\\end{caCenter}',
    '\\vspace{\\caGap}',
    '\\begin{caCenter}\\begin{minipage}{4.4in}\\centering\\textbf{IN THE UNITED STATES COURT OF APPEALS FOR THE SIXTH CIRCUIT}\\end{minipage}\\end{caCenter}',
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    caption_tex(m),
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    '\\begin{caCenter}' .. tex(m.proceeding) .. '\\end{caCenter}',
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    '\\begin{caCenter}\\textbf{\\MakeUppercase{' .. tex(m.brief_title) .. '}}\\end{caCenter}',
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    counsel_tex(m),
  }, '\n')
end

-- A signing block: "s/ Name" then the lines of the signer (typst: stack, 0.3 em apart, 40% in).
local function sig_block(signer, lines)
  local items = { 's/ ' .. tex(signer) }
  for _, l in ipairs(lines or {}) do items[#items + 1] = tex(l) end
  return '{\\singlespacing\\noindent\\hspace*{0.4\\textwidth}\\begin{minipage}[t]{0.62\\textwidth}\\raggedright\n' ..
    table.concat(items, '\\\\[4.2pt]\n') .. '\n\\end{minipage}}'
end

-- The signature block after the Conclusion (6 Cir. R. 25(d)(1): s/Name). The last paragraph is kept
-- with it by the caller (samepage plus the penalties below).
local function signature_tex(m)
  local out = { '\\nopagebreak\\par\\nopagebreak\\vspace{1.4em}\\nopagebreak',
    '{\\singlespacing\\noindent Respectfully submitted,\\par}' }
  for _, sig in ipairs(m.signatures) do
    out[#out + 1] = '\\vspace{1.4em}\\nopagebreak'
    out[#out + 1] = sig_block(sig.signer, sig.lines)
  end
  return table.concat(out, '\n')
end

-- Signature for a certificate: "s/ Name" and the name (6 Cir. R. 25; FRAP 25(d)). Typst: 1.6 em above.
local function cert_signature(m)
  local sig = m.signatures[1]
  return '\\par\\vspace{1.6em}\\nopagebreak' .. '{\\singlespacing\\noindent\\hspace*{0.4\\textwidth}\\begin{minipage}[t]{0.6\\textwidth}\\raggedright\n' ..
    's/ ' .. tex(sig.signer) .. '\\\\[4.2pt]\n' .. tex(sig.signer) .. '\n\\end{minipage}}'
end

local function certificate_of_compliance(m, words)
  return table.concat({
    '\\caHeadOne{Certificate of Compliance}',
    '\\begin{minipage}{\\textwidth}',
    '\\begin{caSingle}This reply brief complies with the type-volume limitation of Fed.~R.~App.~P.~32(a)(7)(B) because it contains '
      .. group_digits(words) .. ' words, excluding the parts of the brief exempted by Fed.~R.~App.~P.~32(f).\\end{caSingle}',
    '\\begin{caSingle}This reply brief complies with the typeface requirements of Fed.~R.~App.~P.~32(a)(5) and the type-style requirements of Fed.~R.~App.~P.~32(a)(6) because it has been prepared in a proportionally spaced typeface, 14-point Liberation Serif.\\end{caSingle}',
    cert_signature(m),
    '\\end{minipage}',
  }, '\n')
end

local function certificate_of_service(m)
  local svc = m.service
  return table.concat({
    '\\caHeadOne{Certificate of Service}',
    '\\begin{minipage}{\\textwidth}',
    '\\begin{caSingle}I certify that I electronically filed and served this ' .. tex(m.brief_title)
      .. ' using the Court\'s CM/ECF system upon ' .. tex(svc.upon) .. ' on ' .. tex(m.date) .. '.\\end{caSingle}',
    cert_signature(m),
    '\\end{minipage}',
  }, '\n')
end

-- Table of authorities: the cited ones, grouped by kind and sorted; pages come from the aux file.
local KINDS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}
local function toa_blocks(auth)
  local out = { R('\\caHeadOneNoToc{Table of Authorities}') }
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
          disp = name .. ',\\hspace{0.2em}' .. a.cite
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
        error('ca6-reply-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
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

  local words = count_words(blocks)
  if words > 6500 then
    error('ca6-reply-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(ii) allows 6500 for a reply brief')
  end

  local out = pandoc.List()
  -- ---- cover, then the front matter (roman numerals) ----
  out:insert(R(cover(meta)))
  out:insert(R('\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}'))
  out:insert(R('\\caHeadOneNoToc{Table of Contents}\\par\\hfill\\textbf{\\underline{Page}}\\par\\caTocList'))
  out:insert(R('\\clearpage'))
  for _, b in ipairs(toa_blocks(auth)) do out:insert(b) end

  -- ---- body (arabic from 1) ----
  out:insert(R('\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}'))
  local st = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
  local body = pandoc.List()
  for _, b in ipairs(blocks) do
    if b.t == 'Header' then body:insert(heading_block(b, st)) else body:insert(b) end
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

  -- ---- certificates of counsel: the compliance certificate follows the signature (6 Cir. R. 32(a)) ----
  out:insert(R(certificate_of_compliance(meta, words)))
  if meta.service and meta.service.certificate == true then
    out:insert(R('\\clearpage'))
    out:insert(R(certificate_of_service(meta)))
  end

  return pandoc.Pandoc(out, meta)
end
