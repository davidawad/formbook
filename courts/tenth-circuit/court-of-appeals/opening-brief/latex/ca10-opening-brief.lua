-- ca10-opening-brief: pandoc Lua filter for the LaTeX engine (opening-brief/latex/template.tex). Mirrors
-- typst/ca10-opening-brief.typ (the reference):
--   * the cover, the table of contents, the table of authorities, the statement of prior or related appeals, the
--     signature block, the statement in support of oral argument, the certificates and the index of attachments,
--     built from the YAML frontmatter (the same fields as the typst template);
--   * the heading labels the typst template prints (Argument: I. A. 1. a.; elsewhere A. 1. a. (1)), each heading
--     labelled for the table of contents;
--   * every [text](toa:key) citation writes its page for the table of authorities (\toahit);
--   * the word count of the certificate, counted as the typst template counts it (the markdown source).
-- Typesetting macros are in template.tex. No case-specific text lives here.

local WORD_LIMIT = 13000   -- CA10-LEN-001: FRAP 32(a)(7)(B)(i), principal brief
local TOC_DEPTH = 4        -- typst toc-depth
local TYPEFACE = 'Times New Roman' -- typst font-family.first()

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_inlines = require('latex.xengine').inlines

local function raw(s) return pandoc.RawBlock('latex', s) end

-- Inline markdown in a metadata value -> LaTeX.
local function tex(v)
  if v == nil then return '' end
  if type(v) == 'string' then v = pandoc.Inlines({ pandoc.Str(v) }) end
  if v.t == 'MetaBlocks' then v = pandoc.utils.blocks_to_inlines(v) end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(xe_inlines(pandoc.Inlines(v))) }), 'latex')
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

local function need(meta, k)
  if meta[k] == nil then error('ca10-opening-brief: missing required metadata field `' .. k .. '`') end
  return meta[k]
end

local function roman(n)
  local vals = { { 1000, 'M' }, { 900, 'CM' }, { 500, 'D' }, { 400, 'CD' }, { 100, 'C' }, { 90, 'XC' },
    { 50, 'L' }, { 40, 'XL' }, { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }
  local out = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return (out:gsub('^,', ''))
end

-- Printed label of a numbered heading (typst heading-label). Argument: I. / A. / 1. / a.; elsewhere A. / 1. / a. / (1).
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
  error('ca10-opening-brief: headings deeper than level 5 are not supported')
end

-- ---------------------------------------------------------------------------
-- Word count: the typst template's count-words over the markdown source (whitespace-delimited, markup removed,
-- footnote text included), so every engine certifies the same number.
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error('ca10-opening-brief: no input file to count words in') end
  local h = assert(io.open(f, 'r'))
  local text = h:read('a')
  h:close()
  local dashes, n = 0, 0
  for line in (text .. '\n'):gmatch('(.-)\n') do
    if dashes < 2 then
      if line == '---' then dashes = dashes + 1 end
    else
      local s = line:gsub('<!%-%-.-%-%->', ' ')
      s = s:gsub('^%[%^[^%]]+%]:', ' ')
      s = s:gsub('%[%^[^%]]*%]', '')
      s = s:gsub('%[([^%]]*)%]%([^%)]*%)', '%1')
      s = s:gsub('^#+[ \t]+', '')
      s = s:gsub('^>[ \t]?', '')
      s = s:gsub('^[ \t]*[-*+][ \t]+', '')
      s = s:gsub('^[ \t]*%d+[.)][ \t]+', '')
      s = s:gsub('\\(.)', '%1')
      s = s:gsub('%*', '')
      s = s:gsub('_', '')
      for _ in s:gmatch('%S+') do n = n + 1 end
    end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Fancy list markers ("(I)", "A.", "(1)") are text in the markdown contract, not lists (CommonMark, which the typst
-- template reads with, has no such lists): they become paragraphs that keep their marker.
-- ---------------------------------------------------------------------------

local function list_marker(n, style, delim)
  local s
  if style == 'LowerRoman' or style == 'UpperRoman' then
    s = roman(n)
    if style == 'LowerRoman' then s = s:lower() end
  elseif style == 'LowerAlpha' or style == 'UpperAlpha' then
    s = string.char((style == 'LowerAlpha' and 96 or 64) + n)
  else
    s = tostring(n)
  end
  if delim == 'OneParen' then return s .. ')' end
  if delim == 'TwoParens' then return '(' .. s .. ')' end
  return s .. '.'
end

local function unlist_fancy(doc)
  return doc:walk({
    OrderedList = function(el)
      local a = el.listAttributes
      local st, dl = tostring(a.style), tostring(a.delimiter)
      local fancy = st == 'LowerRoman' or st == 'UpperRoman' or st == 'LowerAlpha' or st == 'UpperAlpha'
        or dl == 'OneParen' or dl == 'TwoParens'
      if not fancy then return nil end
      local out = {}
      for i, item in ipairs(el.content) do
        local marker = list_marker(a.start + i - 1, st, dl)
        for j, b in ipairs(item) do
          if j == 1 and (b.t == 'Para' or b.t == 'Plain') then
            local inl = pandoc.Inlines({ pandoc.Str(marker), pandoc.Space() })
            inl:extend(b.content)
            out[#out + 1] = pandoc.Para(inl)
          else
            out[#out + 1] = b
          end
        end
      end
      return out
    end,
  })
end

-- ---------------------------------------------------------------------------
-- Line breaks inside a web address. typst breaks a word that holds "http://" or "https://" (from there to the end of
-- the word, less trailing punctuation) where the class of character changes: letter, digit, opening bracket, other;
-- after an "other" character before anything, and between a letter and a digit either way, never after an opening
-- bracket; a piece of 16 characters or more between two such places breaks after any character. TeX breaks a word
-- only after a hyphen: the other places get \allowbreak (measured with typst 0.15, docs/EVAL-LOOP.md "Cross-engine
-- gate").
-- ---------------------------------------------------------------------------

local function url_cuts(link)
  local function class(c)
    if c:match('^%a$') or #c > 1 then return 'A' end
    if c:match('^%d$') then return 'D' end
    if c == '(' or c == '[' then return 'O' end
    return 'X'
  end
  local cuts, starts = {}, {}
  for p in utf8.codes(link) do starts[#starts + 1] = p - 1 end
  local offset, prev = 0, 'X'
  for i, b in ipairs(starts) do
    local c = link:sub(b + 1, (starts[i + 1] or #link) )
    local cl = class(c)
    if b > 0 and prev ~= 'O' and ((cl == 'X' and prev == 'X') or (cl ~= 'X' and cl ~= prev)) then
      if b - offset >= 16 then
        for _, q in ipairs(starts) do if q > offset and q < b then cuts[q] = true end end
      end
      cuts[b] = true
      offset = b
    end
    prev = cl
  end
  return cuts
end

local function url_breaks(s)
  local at = s.text:find('https?://')
  if not at then return nil end
  local text = s.text
  local tail_at = #text + 1
  while tail_at > at and text:sub(tail_at - 1, tail_at - 1):match('[.,;:!?]') do tail_at = tail_at - 1 end
  local link = text:sub(at, tail_at - 1)
  local cuts = url_cuts(link)
  local out = pandoc.Inlines({})
  local from = 1
  local keys = {}
  for k in pairs(cuts) do keys[#keys + 1] = k end
  table.sort(keys)
  local head = text:sub(1, at - 1)
  local pieces = {}
  for _, k in ipairs(keys) do
    pieces[#pieces + 1] = link:sub(from, k)
    from = k + 1
  end
  pieces[#pieces + 1] = link:sub(from) .. text:sub(tail_at)
  pieces[1] = head .. pieces[1]
  for i, p in ipairs(pieces) do
    if i > 1 then out:insert(pandoc.RawInline('latex', '\\allowbreak{}')) end
    out:insert(pandoc.Str(p))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2); 10th Cir. R. 28.2(C)(1)-(2)): typst cover-body
-- ---------------------------------------------------------------------------

-- Rules in vertical mode with no interline glue: they cost their own height, as in typst.
local SHORT = '\\nointerlineskip\\hbox to\\linewidth{\\hss\\rule{2in}{0.7pt}\\hss}\\nointerlineskip'
local DOUBLE = '\\nointerlineskip\\hbox to\\linewidth{\\rule{\\linewidth}{1.6pt}}\\nointerlineskip\\vspace{2.5pt}'
  .. '\\nointerlineskip\\hbox to\\linewidth{\\rule{\\linewidth}{0.5pt}}\\nointerlineskip'

local function cover(meta)
  local L = {}
  local function add(s) L[#L + 1] = s end
  add('\\thispagestyle{empty}\\begingroup\\singlespacing\\centering\\parindent=0pt')
  add('\\cagap{}\\textbf{No.\\ ' .. tex(need(meta, 'case_number')) .. '}\\par\\cagap{}')
  add(DOUBLE .. '\\cagap{}')
  add('\\textbf{IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE TENTH CIRCUIT}\\par\\cagap{}')
  add(SHORT .. '\\cagap{}')
  local sides = need(meta, 'caption')
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. '\\par\\addvspace{4.9bp}') end
    add('{\\raggedright\\carighthalf ' .. tex(side.designation) .. '\\par}\\addvspace{4.9bp}')
    if i < #sides then add('\\cagap{}v.\\par\\cagap{}') end
  end
  add('\\cagap{}' .. SHORT .. '\\cagap{}')
  -- the originating case: district, judge, district court case number (10th Cir. R. 28.2(C)(1))
  add(tex(need(meta, 'proceeding')) .. '\\par\\addvspace{4.9bp}')
  add(tex(need(meta, 'judge')) .. '\\\\Case No.\\ ' .. tex(need(meta, 'district_court_case')) .. '\\par')
  add('\\cagap{}' .. SHORT .. '\\cagap{}')
  add('\\textbf{\\MakeUppercase{' .. tex(need(meta, 'brief_title')) .. '}}\\par\\cagap{}')
  add(SHORT .. '\\cagap{}')
  -- counsel (FRAP 32(a)(2)(F)): in the right half, the lines half an em in; 7 bp between groups
  add('{\\raggedright\\carighthalf')
  for gi, g in ipairs(need(meta, 'counsel')) do
    if gi > 1 then add('\\addvspace{7bp}') end
    for _, n in ipairs(g.names or {}) do add(tex(n) .. '\\par') end
    for _, l in ipairs(g.lines or {}) do add('\\hspace*{0.5em}\\emph{' .. tex(l) .. '}\\par') end
  end
  add('}\\cagap{}')
  -- the oral argument statement on the cover (10th Cir. R. 28.2(C)(2))
  local oral = plain(meta.oral_argument) == 'requested'
  add('\\textbf{' .. (oral and 'ORAL ARGUMENT REQUESTED' or 'ORAL ARGUMENT NOT REQUESTED') .. '}\\par\\cagap{}')
  add(DOUBLE)
  add('\\par\\endgroup')
  return table.concat(L, '\n')
end

-- ---------------------------------------------------------------------------
-- Signature blocks (typst signature-block, certificate-signature)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, 'signature')
  local L = {}
  -- "Respectfully submitted," then 16.8 bp, the signature and the signer's lines in the right half (the lines half
  -- an em in), then 11.2 bp and the date at the margin; kept with the last paragraph (one block in typst).
  L[#L + 1] = '\\par\\nobreak\\addvspace{19.6bp}\\nobreak'
  L[#L + 1] = '\\begingroup\\singlespacing\\raggedright\\carighthalf\\interlinepenalty=10000\\relax'
  L[#L + 1] = 'Respectfully submitted,\\par\\nobreak\\vspace{16.8bp}\\nobreak'
  local lines = { '/s/ ' .. tex(sig.signer), tex(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = '\\hspace*{0.5em}\\emph{' .. tex(l) .. '}' end
  L[#L + 1] = table.concat(lines, '\\\\\n') .. '\\par'
  L[#L + 1] = '\\endgroup'
  if meta.date ~= nil then
    L[#L + 1] = '\\nobreak\\vspace{11.2bp}\\nobreak\\begingroup\\singlespacing\\noindent Dated: ' .. tex(meta.date)
      .. '\\par\\endgroup'
  end
  return table.concat(L, '\n')
end

-- Under a certificate: "/s/ Name", the name and the date in the right half, 22.4 bp below the text, kept whole.
local function cert_signature(meta)
  local signer = tex(meta.signature.signer)
  return '\\par\\addvspace{22.4bp}\\begingroup\\singlespacing\\raggedright\\carighthalf\\interlinepenalty=10000\\relax '
    .. '/s/ ' .. signer .. '\\\\' .. signer .. '\\\\' .. tex(meta.date) .. '\\par\\endgroup'
end

-- ---------------------------------------------------------------------------
-- Table of authorities (typst toa-section)
-- ---------------------------------------------------------------------------

local ORDER = { 'case', 'constitution', 'statute', 'regulation', 'rule', 'other' }
local TITLES = {
  case = 'Cases:', constitution = 'Constitutional Provisions:', statute = 'Statutes:',
  regulation = 'Regulations:', rule = 'Rules:', other = 'Other Authorities:',
}

-- typst sort-key: lowercased plain text without punctuation; digit runs zero-padded so "2 U.S.C." sorts before
-- "28 U.S.C.".
local function sort_key(a)
  local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. ' ' .. plain(a.cite))
  s = s:lower():gsub('\u{2019}', ''):gsub('[^a-z0-9 ]', '')
  return (s:gsub('%d+', function(d) return string.rep('0', math.max(0, 8 - #d)) .. d end))
end

local function toa(meta, hits)
  local out = {}
  local auth = meta.authorities or {}
  for key in pairs(hits) do
    if auth[key] == nil then
      error('ca10-opening-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
    end
  end
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
  return table.concat(out, '\n')
end

-- ---------------------------------------------------------------------------
-- The filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ 'case_number', 'caption', 'proceeding', 'judge', 'district_court_case', 'brief_title',
    'counsel', 'signature', 'date', 'oral_argument', 'prior_appeals', 'digital_submission', 'attachments' }) do
    need(meta, k)
  end
  local oral = plain(meta.oral_argument)
  if oral ~= 'requested' and oral ~= 'not requested' then
    error('ca10-opening-brief: oral_argument must be `requested` or `not requested`')
  end
  if oral == 'requested' then need(meta, 'oral_argument_statement') end

  local words = source_words()
  if words > WORD_LIMIT then
    error('ca10-opening-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(i) allows ' .. WORD_LIMIT)
  end

  doc = unlist_fancy(doc)

  -- the citations: each writes its page to the aux file at its place (\toahit)
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = el.target:sub(5)
      hits[key] = (hits[key] or 0) + 1
      local out = pandoc.Inlines({ pandoc.RawInline('latex', '\\toahit{' .. key .. '}') })
      out:extend(el.content)
      return out
    end,
  })

  -- the cross-engine inline rules over the body text; web addresses break where typst breaks them
  doc = doc:walk({ Str = url_breaks })
  doc = doc:walk({ Inlines = xe_inlines })

  -- the headings, labelled as typst labels them; each is listed in the table of contents down to TOC_DEPTH
  local counts = { 0, 0, 0, 0, 0 }
  local in_arg = false
  local heads = {}
  doc = doc:walk({
    Header = function(h)
      if h.level > 5 then error('ca10-opening-brief: headings deeper than level 5 are not supported') end
      local title = tex(h.content)
      local id = 'h' .. (#heads + 1)
      if h.level == 1 then
        in_arg = plain(h.content):lower():match('^%s*argument%s*$') ~= nil
        counts = { 0, 0, 0, 0, 0 }
        heads[#heads + 1] = { level = 1, steps = 0, label = '', title = title, id = id }
        return raw(string.format('\\casection{%s}{%s}', title, id))
      end
      counts[h.level] = counts[h.level] + 1
      for i = h.level + 1, 5 do counts[i] = 0 end
      local lab = label_for(h.level, counts[h.level], in_arg)
      if in_arg and h.level == 2 then
        heads[#heads + 1] = { level = 2, steps = 0, label = lab, title = title, id = id }
        return raw(string.format('\\capoint{%s}{%s}{%s}', lab, title, id))
      end
      local steps = h.level - (in_arg and 3 or 2) + 1
      heads[#heads + 1] = { level = h.level, steps = steps, label = lab, title = title, id = id }
      return raw(string.format('\\casub{%d}{%s}{%s}{%s}{%d}', steps, lab, title, id, h.level >= 4 and 1 or 0))
    end,
  })

  local front, back = {}, {}
  local function F(s) front[#front + 1] = raw(s) end
  local function B(s) back[#back + 1] = raw(s) end

  -- cover (unnumbered), then the front matter numbered from i
  F('\\singlespacing')
  F(cover(meta))
  F('\\clearpage\\pagenumbering{roman}\\casection{Table of Contents}{toc}'
    .. '\n\\par\\addvspace{4.2bp}\\begingroup\\raggedleft\\singlespacing\\bfseries\\underline{Page}\\par\\endgroup')
  local function tocline(level, steps, label, title, id)
    return string.format('\\tocline{%d}{%d}{%s}{%s}{%s}', level, steps, label, title, id)
  end
  local toc = { tocline(1, 0, '', 'Table of Authorities', 'toa'), tocline(1, 0, '', 'Statement of Prior or Related Appeals', 'pra') }
  for _, h in ipairs(heads) do
    if h.level <= TOC_DEPTH then toc[#toc + 1] = tocline(h.level, h.steps, h.label, h.title, h.id) end
  end
  if oral == 'requested' then toc[#toc + 1] = tocline(1, 0, '', 'Statement in Support of Oral Argument', 'oas') end
  toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Compliance', 'cc')
  toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Digital Submission', 'cds')
  toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Service', 'cs')
  toc[#toc + 1] = tocline(1, 0, '', 'Index of Attachments', 'ia')
  F(table.concat(toc, '\n'))
  F('\\clearpage\\casection{Table of Authorities}{toa}\n' .. toa(meta, hits))
  -- the statement of prior or related appeals (10th Cir. R. 28.2(C)(3)): text of the brief, double-spaced
  F('\\clearpage\\casection{Statement of Prior or Related Appeals}{pra}\n\\normalsize ' .. tex(meta.prior_appeals) .. '\\par')
  F('\\clearpage\\pagenumbering{arabic}\\normalsize')

  -- the signature block; the statement in support of oral argument follows it (10th Cir. R. 28.2(C)(2))
  B(signature(meta))
  if oral == 'requested' then
    B('\\casection{Statement in Support of Oral Argument}{oas}\n\\normalsize ' .. tex(meta.oral_argument_statement) .. '\\par')
  end

  -- certificate of compliance (FRAP 32(g)(1)), on its own page
  B('\\clearpage\\casection{Certificate of Compliance}{cc}')
  B('\\begingroup\\singlespacing\\noindent This brief complies with the type-volume limitation of Federal Rule of '
    .. 'Appellate Procedure 32(a)(7)(B), because it contains ' .. group_digits(words) .. ' words, which is no more '
    .. 'than the ' .. group_digits(WORD_LIMIT) .. ' words permitted for a principal brief, excluding the parts of '
    .. 'the brief exempted by Federal Rule of Appellate Procedure 32(f).\\par\\addvspace{14bp}\\noindent '
    .. 'The brief also complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and '
    .. 'the type style requirements of Federal Rule of Appellate Procedure 32(a)(6), because it has been prepared '
    .. 'in a proportionally spaced typeface, ' .. TYPEFACE .. ', in 14-point type.\\par\\endgroup')
  B(cert_signature(meta))

  -- certificate of digital submission (FRAP 25(a)(5); 10th Cir. R. 25.5) and of service (10th Cir. R. 25.4)
  local ds = meta.digital_submission
  B('\\clearpage\\casection{Certificate of Digital Submission}{cds}')
  local items = {
    '(1) all required privacy redactions have been made per Fed. R. App. P. 25(a)(5) and 10th Cir. R. 25.5;',
    '(2) that this document is a native PDF document;',
    '(3) that the ECF submission is an exact copy of those documents;',
    '(4) the digital submission has been scanned for viruses with the most recent version of a commercial virus '
      .. 'scanning program, ' .. tex(ds.scanner) .. ', last updated on ' .. tex(ds.updated) .. '; and',
    '(5) according to the program, this document is free of viruses.',
  }
  local x = { '\\begingroup\\singlespacing\\noindent I hereby certify that with respect to the foregoing:\\par' }
  for _, it in ipairs(items) do
    x[#x + 1] = '\\addvspace{11.2bp}{\\interlinepenalty=10000\\relax\\noindent\\hangindent=22.4bp\\hangafter=1\\relax '
      .. it .. '\\par}'
  end
  x[#x + 1] = '\\endgroup'
  B(table.concat(x, '\n'))
  B(cert_signature(meta))
  B('\\casection{Certificate of Service}{cs}')
  B('\\begingroup\\singlespacing\\noindent I hereby certify that on ' .. tex(meta.date) .. ', pursuant to Fed. R. '
    .. 'App. P. 25 and 10th Cir. R. 25.4, I electronically filed the foregoing using the Court\\textquoteright{}s '
    .. 'CM/ECF system, which in turn caused electronic notifications of such filing to be sent to all counsel of '
    .. 'record.\\par\\endgroup')
  B(cert_signature(meta))

  -- index of attachments (10th Cir. R. 28.2(C)(5)), on its own page
  B('\\clearpage\\casection{Index of Attachments}{ia}')
  local rows = {}
  for i, a in ipairs(meta.attachments) do rows[#rows + 1] = '\\attachrow{' .. tex(a) .. '}{' .. i .. '}' end
  B(table.concat(rows, '\n'))

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
