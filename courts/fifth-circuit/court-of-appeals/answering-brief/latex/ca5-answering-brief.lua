-- ca5-answering-brief: pandoc Lua filter for the LaTeX engine (see ../README.md, "Engines").
-- Builds the cover, the front statements, the table of contents, the table of authorities, the signature block and
-- the certificates from the YAML frontmatter (same fields as the typst template), numbers the headings and turns each
-- [text](toa:key) citation into a counted hit for the table of authorities. Typesetting macros are in template.tex.
-- The typst template (../typst/ca5-answering-brief.typ) is the reference for every line and page break (cross-engine
-- layout model, docs/EVAL-LOOP.md). No case-specific text lives here.

local TOC_DEPTH = 4         -- deepest heading level in the table of contents (typst toc-depth)
local WORD_LIMIT = 13000    -- CA5-LEN-001: FRAP 32(a)(7)(B)(i)

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua), and two of this template: the ellipsis
-- character as the font's glyph (\caellipsis), a hard line break that stays inside its paragraph (\newline).
local xe_base = require('latex.xengine').inlines
local function rawi(s) return pandoc.RawInline('latex', s) end
local function xe_inlines(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(xe_base(l)) do
    if el.t == 'Str' and el.text:find('\u{2026}', 1, true) then
      local first = true
      for part in (el.text .. '\u{2026}'):gmatch('(.-)\u{2026}') do
        if not first then out:insert(rawi('\\caellipsis{}')) end
        if part ~= '' then out:insert(pandoc.Str(part)) end
        first = false
      end
    elseif el.t == 'LineBreak' then
      out:insert(rawi('\\newline{}'))
    else
      out:insert(el)
    end
  end
  return out
end

-- Inline markdown in a metadata value -> LaTeX.
local function tex(v)
  if v == nil then return '' end
  if type(v) == 'string' then v = pandoc.Inlines({ pandoc.Str(v) }) end
  if v.t == 'MetaBlocks' then v = pandoc.utils.blocks_to_inlines(v) end
  local d = pandoc.Pandoc({ pandoc.Plain(pandoc.Inlines(v)) }):walk({ Inlines = xe_inlines })
  return (pandoc.write(d, 'latex'):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

local function fail(msg) error('ca5-answering-brief: ' .. msg, 0) end

local function roman(n)
  local vals = { { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }
  local out = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- Printed label of a numbered heading (typst heading-label). Argument: I. / A. / 1. / a.  Elsewhere: A. / 1. / a. / (1)
local function label_for(level, n, in_arg)
  if in_arg then
    if level == 2 then return roman(n) .. '.' end
    if level == 3 then return string.char(64 + n) .. '.' end
    if level == 4 then return tostring(n) .. '.' end
    if level == 5 then return string.char(96 + n) .. '.' end
  else
    if level == 2 then return string.char(64 + n) .. '.' end
    if level == 3 then return tostring(n) .. '.' end
    if level == 4 then return string.char(96 + n) .. '.' end
    if level == 5 then return '(' .. n .. ')' end
  end
  fail('headings deeper than level 5 are not supported')
end

-- Label indent in half inches (typst label-indent): labels sit half an inch in; in the Argument the level-2 point
-- heading is centered, so its sub-headings start at the first step.
local function steps_for(level, in_arg)
  return level - (in_arg and 3 or 2) + 1
end

local function raw(s) return pandoc.RawBlock('latex', s) end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return (out:gsub('^,', ''))
end

-- ---------------------------------------------------------------------------
-- Words (CA5-LEN-001): the typst template's count-words on the markdown source of the body (all of it but the
-- frontmatter and an addendum): markup removed, links keep their text, then whitespace-delimited words.
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then fail('no input file to count words in') end
  local h = assert(io.open(f, 'r'))
  local src = h:read('a')
  h:close()
  local t = src:gsub('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n', '', 1)
  t = '\n' .. t
  local a = t:lower():find('\n#[ \t]+addendum[ \t]*\n') or t:lower():find('\n#[ \t]+addendum[ \t]*$')
  if a then t = t:sub(1, a) end
  t = t:gsub('<!%-%-.-%-%->', ' ')
  t = t:gsub('\n%[%^[^%]]+%]:', '\n ')
  t = t:gsub('%[%^[^%]]+%]', '')
  t = t:gsub('%[([^%]]*)%]%([^%)]*%)', '%1')
  t = t:gsub('\n#+[ \t]+', '\n')
  t = t:gsub('\n>[ \t]?', '\n')
  t = t:gsub('\n[ \t]*[-*+][ \t]+', '\n')
  t = t:gsub('\n[ \t]*%d+[.)][ \t]+', '\n')
  t = t:gsub('\\(.)', '%1')
  t = t:gsub('%*', '')
  t = t:gsub('([%s%(%[\"])_', '%1'):gsub('\u{201C}_', '\u{201C}')
  t = t:gsub('_([%s%.,;:%)%]\"!%?])', '%1'):gsub('_\u{201D}', '\u{201D}'):gsub('_$', '')
  local n = 0
  for _ in t:gmatch('%S+') do n = n + 1 end
  return n
end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2); CA5-COVER-001 to -005) [cover-body]
-- ---------------------------------------------------------------------------

local function cover(meta)
  local L = {}
  local function add(s) L[#L + 1] = s end
  local function need(k)
    if meta[k] == nil then fail('missing required metadata field `' .. k .. '`') end
    return meta[k]
  end
  add('\\thispagestyle{empty}\\begingroup\\centering\\singlespacing\\parindent=0pt')
  add('\\vskip 4.2bp plus 1fill minus 4.2bp')
  add('\\textbf{No.\\ ' .. tex(need('case_number')) .. '}\\par\\cagap')
  add('\\cadouble\\cagap')
  -- a 75 % measure lets the court's name break after "Appeals", as typst's narrower block does
  add('{\\leftskip=0.125\\linewidth plus 1fil\\rightskip=0.125\\linewidth plus 1fil\\parfillskip=0pt\\bfseries ' ..
    'IN THE UNITED STATES COURT OF APPEALS FOR THE FIFTH CIRCUIT\\par}\\cagap')
  add('\\cashort\\cagap')
  local sides = need('caption')
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. '\\par') end
    add('{\\leftskip=0.5\\linewidth\\rightskip=0pt plus 1fil\\parfillskip=0pt plus 1fil ' .. tex(side.designation) .. '\\par}')
    if i < #sides then add('\\vskip 2.1bp plus 0.3fill minus 2.1bp v.\\par\\vskip 2.1bp plus 0.3fill minus 2.1bp') end
  end
  add('\\cagap\\cashort\\cagap')
  add(tex(need('proceeding')) .. '\\par\\cagap')
  add('\\cashort\\cagap')
  add('\\textbf{\\MakeUppercase{' .. tex(need('brief_title')) .. '}}\\par\\cagap')
  add('\\cashort\\cagap')
  -- Counsel (FRAP 32(a)(2)(F)): in the right half, left aligned; the lines in italics 0.5 em in; the telephone with
  -- the last group; 7 bp between the groups.
  add('{\\leftskip=0.5\\linewidth\\rightskip=0pt plus 1fil\\parfillskip=0pt plus 1fil\\interlinepenalty=10000')
  local groups = need('counsel')
  for gi, g in ipairs(groups) do
    if gi > 1 then add('\\par\\nobreak\\addvspace{7bp}') end
    for _, n in ipairs(g.names) do add(tex(n) .. '\\par\\nobreak') end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = need('phone') end
    add('{\\advance\\leftskip 0.5em')
    for _, l in ipairs(lines) do add('\\emph{' .. tex(l) .. '}\\par\\nobreak') end
    add('}')
  end
  if meta.counsel_for ~= nil then
    add('\\addvspace{5.6bp}\\textbf{\\MakeUppercase{' .. tex(meta.counsel_for) .. '}}\\par')
  end
  add('}\\cagap\\cadouble')
  add('\\par\\endgroup')
  return table.concat(L, '\n')
end

-- ---------------------------------------------------------------------------
-- Signature and certificates (FRAP 25, 32(g); 5th Cir. R. 28.2.1)
-- ---------------------------------------------------------------------------

-- [signature-block]: "Respectfully submitted," then 16.8 bp, the signature and the signer's lines in the right half
-- (the lines 0.5 em in, in italics), then 11.2 bp and the date at the margin; kept with the last paragraph.
local function signature(meta)
  local sig = meta.signature
  local L = {}
  L[#L + 1] = '\\par\\nobreak\\addvspace{19.6bp}\\nobreak'
  L[#L + 1] = '\\begingroup\\singlespacing\\leftskip=0.5\\linewidth\\parindent=0pt\\interlinepenalty=10000'
  L[#L + 1] = 'Respectfully submitted,\\par\\nobreak\\vskip 16.8bp\\nobreak'
  L[#L + 1] = 's/ ' .. tex(sig.signer) .. '\\par\\nobreak'
  L[#L + 1] = '\\MakeUppercase{' .. tex(sig.signer) .. '}\\par\\nobreak'
  L[#L + 1] = '\\advance\\leftskip 0.5em'
  for _, l in ipairs(sig.lines or {}) do L[#L + 1] = '\\emph{' .. tex(l) .. '}\\par\\nobreak' end
  L[#L + 1] = '\\endgroup'
  if meta.date ~= nil then
    L[#L + 1] = '\\nobreak\\vskip 11.2bp\\nobreak\\begingroup\\singlespacing\\noindent ' .. tex(meta.date) .. '\\par\\endgroup'
  end
  return table.concat(L, '\n')
end

-- [signature-mark]: "s/ Name" over the first line of the signature, 45 % in; never split.
local function signature_mark(meta)
  local lines = meta.signature.lines or {}
  local s = '\\par\\addvspace{19.6bp}\\begingroup\\singlespacing\\leftskip=0.45\\linewidth\\parindent=0pt' ..
    '\\interlinepenalty=10000 s/ ' .. tex(meta.signature.signer) .. '\\par\\nobreak '
  if #lines > 0 then s = s .. tex(lines[1]) .. '\\par' end
  return s .. '\\endgroup'
end

-- ---------------------------------------------------------------------------
-- Table of authorities
-- ---------------------------------------------------------------------------

local ORDER = { 'case', 'constitution', 'statute', 'regulation', 'rule', 'other' }
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
  out[#out + 1] = '\\cahead{1}{0}{}{Table of Authorities}{toa}'
  local first = true
  for _, kind in ipairs(ORDER) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == kind and hits[key] ~= nil then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
    if #members > 0 then
      out[#out + 1] = '\\toagroup{' .. TITLES[kind] .. '}{' .. (first and 1 or 0) .. '}'
      first = false
      for _, m in ipairs(members) do
        local name = m.a.name ~= nil and tex(m.a.name) or ''
        out[#out + 1] = string.format('\\toaitem{%s}{%s}{%d}{%s}', name, tex(m.a.cite), kind == 'case' and 1 or 0, m.key)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ 'case_number', 'caption', 'proceeding', 'brief_title', 'counsel', 'phone', 'signature', 'prepared_with' }) do
    if meta[k] == nil then fail('missing required metadata field `' .. k .. '`') end
  end
  local auth = meta.authorities or {}

  -- the toa: citations; each writes its page to the aux file at its place (\toahit)
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) ~= 'toa:' then return el.content end
      local key = el.target:sub(5)
      if auth[key] == nil then fail('link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter') end
      hits[key] = true
      local out = pandoc.Inlines({ rawi('\\toahit{' .. key .. '}') })
      out:extend(el.content)
      return out
    end,
  })
  doc = doc:walk({ Inlines = xe_inlines })

  local words = source_words()
  if words > WORD_LIMIT then fail('the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(i) allows ' .. WORD_LIMIT) end

  -- headings: level 1 a section with no number; levels 2 to 5 numbered as in typst
  local counters = { 0, 0, 0, 0, 0, 0 }
  local in_arg = false
  local heads = {}
  local has = { arg = false, concl = false }
  local body = pandoc.Blocks({})
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' then
      local text = plain(b.content)
      if b.level == 1 and text:lower():match('^%s*addendum%s*$') then
        fail('the LaTeX engine does not yet render an addendum (FRAP 28(f)); see the Engines section of the README')
      end
      if b.level == 1 then
        in_arg = text:lower():match('^%s*argument%s*$') ~= nil
        if in_arg then has.arg = true end
        if text:lower():match('^%s*conclusion%s*$') then has.concl = true end
      end
      counters[b.level] = counters[b.level] + 1
      for i = b.level + 1, 6 do counters[i] = 0 end
      local idx = #heads + 1
      local title = tex(b.content)
      if b.level == 1 then
        heads[idx] = { level = 1, label = '', title = title, steps = 0 }
        body:insert(raw(string.format('\\cahead{1}{0}{}{%s}{h%d}', title, idx)))
      else
        local label = label_for(b.level, counters[b.level], in_arg)
        if in_arg and b.level == 2 then
          heads[idx] = { level = 2, label = label, title = title, steps = 0 }
          body:insert(raw(string.format('\\cacenter{%s}{%s}{h%d}', label, title, idx)))
        else
          local steps = steps_for(b.level, in_arg)
          heads[idx] = { level = b.level, label = label, title = title, steps = steps }
          body:insert(raw(string.format('\\cahead{%d}{%d}{%s}{%s}{h%d}', b.level, steps, label, title, idx)))
        end
      end
    else
      body:insert(b)
    end
  end
  if not has.arg then fail('the brief has no `# Argument` section (FRAP 28(a)(8))') end
  if not has.concl then fail('the brief has no `# Conclusion` section (FRAP 28(a)(9))') end

  local out = pandoc.Blocks({})
  -- the cover is page 1 and is not numbered; the count goes on (page 2 is printed "2")
  out:insert(raw('\\singlespacing'))
  out:insert(raw(cover(meta)))
  out:insert(raw('\\clearpage\\normalsize'))

  -- front statements (Fifth Circuit Local Rule 28.2.1; FRAP 28(b)), each on its own page, double spaced
  local svc = meta.service
  local has_svc = svc ~= nil and svc.certificate == true
  local toc = {}
  local function tocline(level, steps, label, title, ref)
    return string.format('\\tocline{%d}{%d}{%s}{%s}{%s}', level, steps, label, title, ref)
  end
  if meta.interested_persons ~= nil then
    out:insert(raw('\\cahead{1}{0}{}{Certificate of Interested Persons}{cip}'))
    out:insert(pandoc.Para(pandoc.Inlines(meta.interested_persons):walk({ Inlines = xe_inlines })))
    out:insert(raw(signature_mark(meta) .. '\\clearpage'))
    toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Interested Persons', 'cip')
  end
  if meta.oral_argument ~= nil then
    out:insert(raw('\\cahead{1}{0}{}{Statement Regarding Oral Argument}{oral}'))
    out:insert(pandoc.Para(pandoc.Inlines(meta.oral_argument):walk({ Inlines = xe_inlines })))
    out:insert(raw('\\clearpage'))
    toc[#toc + 1] = tocline(1, 0, '', 'Statement Regarding Oral Argument', 'oral')
  end

  -- table of contents: the outlined headings up to TOC_DEPTH, the certificates
  toc[#toc + 1] = tocline(1, 0, '', 'Table of Authorities', 'toa')
  for idx, h in ipairs(heads) do
    if h.level <= TOC_DEPTH then toc[#toc + 1] = tocline(h.level, h.steps, h.label, h.title, 'h' .. idx) end
  end
  if has_svc then toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Service', 'cs') end
  toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Compliance', 'cc')
  out:insert(raw('\\begingroup\\singlespacing\\cahead{1}{0}{}{Table of Contents}{toc}' ..
    '\n\\par\\addvspace{4.2bp}\\begingroup\\raggedleft\\bfseries\\underline{Page}\\par\\endgroup\n' ..
    table.concat(toc, '\n')))
  out:insert(raw('\\clearpage\n' .. table.concat(toa(meta, hits), '\n') .. '\\endgroup\\clearpage'))

  -- the body; the signature never stands alone: the brief's last paragraph is not broken across pages and stays with
  -- the signature block (typst: one unbreakable block)
  local n = #body
  if n > 0 and body[n].t == 'Para' then
    body:insert(n, raw('\\begingroup\\interlinepenalty=10000\\relax'))
    body:insert(raw('\\par\\endgroup'))
  end
  out:extend(body)
  out:insert(raw(signature(meta)))

  -- certificates, single spaced, flush left, 14 bp between paragraphs, each on its own page
  if has_svc then
    out:insert(raw('\\clearpage\\begingroup\\singlespacing\\parindent=0pt' ..
      '\\cahead{1}{0}{}{Certificate of Service}{cs}'))
    out:insert(raw('I certify that on ' .. tex(meta.date) .. ', the foregoing document was electronically filed with the ' ..
      'Clerk of the Court for the United States Court of Appeals for the Fifth Circuit using the electronic case ' ..
      'filing system of the Court. I further certify that I have complied with the privacy and redaction ' ..
      'requirements of Fed. R. App. P. 25(a)(5).'))
    if svc.recipients ~= nil then out:insert(raw('\\par\\addvspace{14bp}' .. tex(svc.recipients))) end
    out:insert(raw(signature_mark(meta) .. '\\endgroup'))
  end
  out:insert(raw('\\clearpage\\begingroup\\singlespacing\\parindent=0pt' ..
    '\\cahead{1}{0}{}{Certificate of Compliance}{cc}'))
  out:insert(raw('1.\\hspace{0.4em}This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) ' ..
    'because: this brief contains ' .. group_digits(words) .. ' words, excluding the parts of the brief exempted by ' ..
    'Fed. R. App. P. 32(f).\\par\\addvspace{14bp}'))
  out:insert(raw('2.\\hspace{0.4em}This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and ' ..
    'the type style requirements of Fed. R. App. P. 32(a)(6) because: this brief has been prepared in a ' ..
    'proportionally spaced typeface using ' .. tex(meta.prepared_with) .. '.\\par'))
  out:insert(raw(signature_mark(meta) .. '\\endgroup'))

  doc.blocks = out
  return doc
end
