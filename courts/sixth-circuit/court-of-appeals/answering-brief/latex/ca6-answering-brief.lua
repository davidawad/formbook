-- U.S. Court of Appeals for the Sixth Circuit: appellee's brief (answering brief), LaTeX engine.
-- A pandoc filter. It writes the whole brief (cover, corporate disclosure, front matter, body, signature,
-- certificates, addendum) from the sample's frontmatter and body, with the same rules and numbers as
-- ../typst/ca6-answering-brief.typ. The macros it calls are in template.tex. Rules: ../README.md.
-- No case-specific text here: everything comes from the sample.

local cited, order = {}, {}

-- CA6-LEN-001: type-volume limits in words, and the rule each comes from (typst word-limits, word-limit-rule).
local LIMITS = { standard = 13000, ['cross-appeal'] = 15300, reply = 6500, ['cross-appeal-reply'] = 6500 }
local LIMIT_RULE = {
  standard = '32(a)(7)(B)(i)', ['cross-appeal'] = '28.1(e)(2)(B)(i)',
  reply = '32(a)(7)(B)(ii)', ['cross-appeal-reply'] = '28.1(e)(2)(C)',
}

local function R(s) return pandoc.RawBlock('latex', s) end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

-- Metadata (or any pandoc inline/block list, or a markdown string) as LaTeX.
local function tex(v)
  local t = pandoc.utils.type(v)
  local s
  if t == 'Inlines' then
    s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(v) }), 'latex')
  elseif t == 'Blocks' then
    s = pandoc.write(pandoc.Pandoc(v), 'latex')
  elseif t == 'string' then
    s = pandoc.write(pandoc.read(v, 'markdown+smart'), 'latex')
  else
    error('ca6-brief: unexpected metadata type ' .. tostring(t))
  end
  -- Curly quotes as the body sets them (the writer's `` and '' would print as straight-looking marks).
  s = s:gsub('``', '\u{201C}'):gsub("''", '\u{201D}')
  return trim(s)
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

-- A heading becomes one macro call (template.tex). Level 1 is a section; the Argument's level 2 is the
-- centred point heading; every other numbered level is a sub-heading whose depth d steps 0.5 in.
-- Unnumbered headings (the statements before the Argument, the addendum) carry no number.
local function heading_block(h, st, numbered)
  local title = tex(h.content)
  if h.level == 1 then
    st.in_arg = trim(plain(h.content):lower()) == 'argument'
    if numbered then
      st.counters[1] = st.counters[1] + 1
      for k = 2, 6 do st.counters[k] = 0 end
    end
    if st.addendum then return R('\\caHeadOneNoToc{' .. title .. '}') end
    return R('\\caHeadOne{' .. title .. '}')
  end
  if not numbered then
    if st.addendum then
      if h.level == 2 then return R('\\caHeadAdd{' .. title .. '}') end
      return R('\\caHeadPlain{' .. title .. '}')
    end
    return R('\\caHeadUnnum{' .. title .. '}')
  end
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
-- List items without their markers: a list number is not a word (typst's count-words drops it too).
local function without_list_markers(blocks)
  local out = pandoc.List()
  for _, b in ipairs(blocks) do
    if b.t == 'OrderedList' or b.t == 'BulletList' then
      for _, item in ipairs(b.content) do
        for _, x in ipairs(without_list_markers(item)) do out:insert(x) end
      end
    else
      out:insert(b)
    end
  end
  return out
end

local function count_words(blocks)
  local s = pandoc.write(pandoc.Pandoc(without_list_markers(blocks)), 'plain')
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

-- The case title. A side marked `continues: true` follows the one before it without "v." (CA6-COVER-003).
local function caption_tex(m)
  local s = {}
  for i, side in ipairs(m.caption) do
    local names = {}
    for _, n in ipairs(side.names) do names[#names + 1] = tex(n) end
    s[#s + 1] = '\\begin{caCenter}' .. table.concat(names, '\\\\') .. '\\end{caCenter}'
    s[#s + 1] = '\\begin{caLeft}\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright '
      .. tex(side.designation) .. '\\end{minipage}\\end{caLeft}'
    local nxt = m.caption[i + 1]
    if nxt and not nxt.continues then
      s[#s + 1] = '\\begin{caCenter}\\vspace{\\caVGap}v.\\vspace{\\caVGap}\\end{caCenter}'
    end
  end
  return table.concat(s, '\n')
end

-- Counsel (FRAP 32(a)(2)(F)): the block starts at 40% of the width, as typst's pad(left: 40%).
local function counsel_tex(m)
  local s = { '\\begin{caLeft}\\hspace*{0.4\\textwidth}\\begin{minipage}[t]{0.6\\textwidth}\\raggedright\\singlespacing' }
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

-- The cover (FRAP 32(a)(2); CA6-COVER-001 to -007): one page, no page number.
local function cover(m)
  local parts = {
    '{\\thispagestyle{empty}\\singlespacing',   -- a group: the single spacing ends with the cover
    -- typst's gap above the case number is 0.6 em; the first line of page 1 in this layout sits 24.6 bp lower
    -- than typst's would, so that is taken back here (\caCoverTop, template.tex).
    '\\vspace*{\\dimexpr\\caGap*6/10-\\caCoverTop\\relax}\\begin{caCenter}\\textbf{Case No. ' .. tex(m.case_number) .. '}\\end{caCenter}',
    '\\vspace{\\caGap}\\caDoubleRule\\vspace{\\caGap}',
    '\\begin{caCenter}\\textbf{UNITED STATES COURT OF APPEALS\\\\FOR THE SIXTH CIRCUIT}\\end{caCenter}',
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    caption_tex(m),
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    '\\begin{caCenter}' .. tex(m.proceeding) .. '\\end{caCenter}',
    '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}',
    '\\begin{caCenter}\\textbf{\\MakeUppercase{' .. tex(m.brief_title) .. '}}\\end{caCenter}',
  }
  if m.oral_argument then
    parts[#parts + 1] = '\\vspace{\\caGap}\\begin{caCenter}\\textbf{ORAL ARGUMENT REQUESTED}\\end{caCenter}'
  end
  parts[#parts + 1] = '\\vspace{\\caGap}\\caShortRule\\vspace{\\caGap}'
  parts[#parts + 1] = counsel_tex(m)
  parts[#parts + 1] = '\\vspace{\\caGap}\\caDoubleRule}'
  return table.concat(parts, '\n')
end

-- Corporate disclosure (6th Cir. R. 26.1; CA6-DISC-001): the clerk's two answers, reproduced. Unnumbered
-- page, before the table of contents, as in typst's disclosure-page.
local function disclosure_tex(m)
  local d = m.disclosure
  return table.concat({
    '\\begin{caSingle}',
    '\\begin{caCenter}\\textbf{DISCLOSURE OF CORPORATE AFFILIATIONS AND FINANCIAL INTEREST}\\end{caCenter}',
    'Pursuant to 6th Cir. R. 26.1, ' .. tex(d.party) .. ' makes the following disclosure:',
    '\\begin{caHang}1.\\hspace{0.6em}Is said party a subsidiary or affiliate of a publicly owned corporation? '
      .. 'If yes, list below the identity of the parent corporation or affiliate and the relationship between it and the named party:\\end{caHang}',
    '\\begin{caHang}\\hspace*{1.6em}' .. tex(d.subsidiary) .. '\\end{caHang}',
    '\\begin{caHang}2.\\hspace{0.6em}Is there a publicly owned corporation, not a party to the appeal, that has a financial interest '
      .. 'in the outcome? If yes, list the identity of such corporation and the nature of the financial interest:\\end{caHang}',
    '\\begin{caHang}\\hspace*{1.6em}' .. tex(d.financial_interest) .. '\\end{caHang}',
    '\\end{caSingle}',
  }, '\n')
end

-- The filing attorney's lines (typst signature-lines): "s/ Name", the name in capitals, the office lines.
local function signature_lines(m)
  local sig = m.signature
  local lines = { 's/ ' .. tex(sig.signer), '\\MakeUppercase{' .. tex(sig.signer) .. '}' }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = '\\hspace*{0.5em}\\emph{' .. tex(l) .. '}' end
  return table.concat(lines, '\\\\\n')
end

-- The signature block after the Conclusion (FRAP 32(d)): "Respectfully submitted," then the lines at 50%,
-- then the date at the margin. Kept with the last paragraph (see Pandoc below).
local function signature_tex(m)
  local out = '\\nopagebreak\\par\\nopagebreak\\nointerlineskip\\vspace{1.4em}\\nopagebreak\n' ..
    '{\\singlespacing\\noindent\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright\n' ..
    'Respectfully submitted,\\\\[1.2em]\n' .. signature_lines(m) .. '\n\\end{minipage}}\\par\n'
  if m.date then
    out = out .. '\\nopagebreak\\nointerlineskip\\vspace{0.8em}\\nopagebreak{\\singlespacing\\noindent ' .. tex(m.date) .. '\\par}'
  end
  return out
end

-- The signature under a certificate (typst signature-block-compact): not indented, date below.
local function signature_compact(m)
  local out = '\\vspace{1.2em}\\par{\\singlespacing\\noindent\n' .. signature_lines(m) .. '\n\\par}'
  if m.date then
    out = out .. '\\vspace{0.8em}{\\singlespacing\\noindent ' .. tex(m.date) .. '\\par}'
  end
  return out
end

local function certificate_of_compliance(m, words, basis)
  local rule = LIMIT_RULE[basis]
  return table.concat({
    '\\caHeadOne{Certificate of Compliance}',
    '\\begin{caSingle}I certify that this brief complies with the type-volume limitation of Fed. R. App. P. '
      .. rule .. '. Exclusive of the items exempted by Fed. R. App. P. 32(f), the brief contains '
      .. group_digits(words) .. ' words.\\par',
    'The brief has been prepared in a proportionally spaced typeface, Liberation Serif in 14-point type, '
      .. 'which complies with Fed. R. App. P. 32(a)(5) and (6).\\end{caSingle}',
    '\\caKeep{240bp}', -- the unbreakable signature block (typst cert-block)
    '\\begin{caSingle}' .. signature_compact(m) .. '\\end{caSingle}',
  }, '\n')
end

local function certificate_of_service(m)
  local svc = m.service
  if not svc then error('ca6-brief: missing required metadata field `service`') end
  local parts = {
    '\\caKeep{380bp}', -- one unbreakable block: the certificate and its signature stay together (typst breakable: false)
    '\\caHeadOne{Certificate of Service}',
    '\\begin{caSingle}I certify that on ' .. tex(svc.date) .. ', I electronically filed the foregoing with the Clerk of the Court '
      .. 'using the CM/ECF system, which will send notification of such filing to all attorneys of record.',
  }
  local unreg = svc.unregistered or {}
  if #unreg > 0 then
    parts[#parts + 1] = 'I further certify that I have mailed by United States Postal Service the document to the following non-ECF participants:'
    for _, u in ipairs(unreg) do
      parts[#parts + 1] = '\\par\\vspace{0.7em}\\noindent\\hspace*{0.5in}\\begin{minipage}[t]{\\dimexpr\\linewidth-0.5in\\relax}\\raggedright '
        .. tex(u.name) .. ', ' .. tex(u.address) .. '\\end{minipage}'
    end
  end
  parts[#parts + 1] = '\\end{caSingle}'
  parts[#parts + 1] = '\\begin{caSingle}' .. signature_compact(m) .. '\\end{caSingle}'
  return table.concat(parts, '\n')
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

local function new_state(addendum)
  return { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false, addendum = addendum }
end

function Pandoc(doc)
  local meta = doc.meta
  local auth = authorities_of(meta)

  local basis = meta.word_limit_basis and plain(meta.word_limit_basis) or 'standard'
  local limit = LIMITS[basis]
  if not limit then error('ca6-brief: unknown word_limit_basis `' .. basis .. '`') end

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

  -- The addendum (after "# Addendum") sits after the certificates.
  local main, add = pandoc.List(), nil
  for i, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 and trim(plain(b.content):lower()) == 'addendum' then
      add = pandoc.List({ table.unpack(blocks, i + 1) })
      break
    end
    main:insert(b)
  end

  local words = count_words(main)
  if words > limit then
    error('ca6-brief: the brief has ' .. words .. ' words; the ' .. basis .. ' limit is ' .. limit)
  end

  -- The statement in support of oral argument must be in the brief (6 Cir. R. 34(a); CA6-ORAL-001).
  if meta.oral_argument then
    local found = false
    for _, b in ipairs(main) do
      if b.t == 'Header' and b.level == 1 and plain(b.content):lower():find('oral argument', 1, true) then found = true end
    end
    if not found then
      error('ca6-brief: oral_argument is set but the brief has no statement in support of oral argument')
    end
  end

  -- The statements before the Argument are numbered in roman with the front matter (preliminary_sections).
  local prelim = tonumber(meta.preliminary_sections and plain(meta.preliminary_sections) or '0') or 0
  local prelim_blocks, body_blocks, seen = pandoc.List(), pandoc.List(), 0
  for _, b in ipairs(main) do
    if b.t == 'Header' and b.level == 1 then seen = seen + 1 end
    if prelim > 0 and seen <= prelim then prelim_blocks:insert(b) else body_blocks:insert(b) end
  end
  local top_sections = seen
  if prelim > top_sections then
    error('ca6-brief: preliminary_sections is ' .. prelim .. ' but the body has ' .. top_sections .. ' sections')
  end

  local out = pandoc.List()
  -- ---- cover, the corporate disclosure (unnumbered), then the front matter (roman from the table of contents) ----
  out:insert(R(cover(meta)))
  out:insert(R('\\clearpage\\thispagestyle{empty}'))
  out:insert(R(disclosure_tex(meta)))
  out:insert(R('\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}'))
  out:insert(R('\\caHeadOneNoToc{Table of Contents}\\par\\hfill\\textbf{\\underline{Page}}\\par\\caTocList'))
  out:insert(R('\\clearpage'))
  for _, b in ipairs(toa_blocks(auth)) do out:insert(b) end

  -- ---- statements before the Argument (roman) ----
  if prelim > 0 then
    out:insert(R('\\clearpage'))
    local pst = new_state(false)
    for _, b in ipairs(prelim_blocks) do
      if b.t == 'Header' then out:insert(heading_block(b, pst, false)) else out:insert(b) end
    end
  end

  -- ---- body (arabic from 1) ----
  out:insert(R('\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}'))
  local st = new_state(false)
  local body = pandoc.List()
  for _, b in ipairs(body_blocks) do
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

  -- ---- certificates of counsel (FRAP 32(g); 25(d)), after the signature on a new page ----
  out:insert(R('\\clearpage'))
  out:insert(R(certificate_of_compliance(meta, words, basis)))
  out:insert(R(certificate_of_service(meta)))

  -- ---- addendum: its own pages, numbered Add-1, Add-2, ... ----
  if add then
    out:insert(R('\\clearpage\\renewcommand{\\thepage}{Add-\\arabic{page}}\\setcounter{page}{1}'))
    out:insert(R('\\caHeadOne{Addendum}'))
    out:insert(R('\\caHeadOneNoToc{Table of Contents}\\par\\hfill\\textbf{\\underline{Page}}\\par\\caAddToc'))
    out:insert(R('\\clearpage'))
    local ast = new_state(true)
    for _, b in ipairs(add) do
      if b.t == 'Header' then out:insert(heading_block(b, ast, false)) else out:insert(b) end
    end
  end

  return pandoc.Pandoc(out, meta)
end
