-- U.S. Court of Appeals for the Sixth Circuit: appellee's brief (answering brief), LaTeX engine.
-- A pandoc filter. It writes the whole brief (cover, corporate disclosure, front matter, the statements before the
-- Argument, body, signature, certificates, addendum) from the sample's frontmatter and body, with the same rules and
-- numbers as ../typst/ca6-answering-brief.typ. The macros it calls are in template.tex. Rules: ../README.md.
-- No case-specific text here: everything comes from the sample.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): the inline rules of lib/latex/xengine.lua (a hyphen
-- before a digit does not end a line, breaks at dashes, a section sign bound to its number, no ligature spellings)
-- run over the body and over every metadata value written here; blocks are spaced with \addvspace as typst spaces
-- them; a block typst keeps whole is a \vbox here.

local xe = require('latex.xengine')

local TOC_DEPTH = 4         -- typst: toc-depth
-- CA6-LEN-001: type-volume limits in words, and the rule each comes from (typst word-limits, word-limit-rule).
local LIMITS = { standard = 13000, ['cross-appeal'] = 15300, reply = 6500, ['cross-appeal-reply'] = 6500 }
local LIMIT_RULE = {
  standard = '32(a)(7)(B)(i)', ['cross-appeal'] = '28.1(e)(2)(B)(i)',
  reply = '32(a)(7)(B)(ii)', ['cross-appeal-reply'] = '28.1(e)(2)(C)',
}
local FACE = 'TeX Gyre Schola'   -- the typeface the template sets (typst font-family)

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
-- ( ) [ ] / * in a box of the OpenType advance (template.tex \cag): their Type 1 metrics differ from the font typst
-- and Word set. Regular and italic, then bold, in em.
local GLYPH = {
  ['('] = { 0.483, 0.519 }, [')'] = { 0.483, 0.519 }, ['['] = { 0.452, 0.482 }, [']'] = { 0.452, 0.482 },
  ['/'] = { 0.447, 0.462 }, ['*'] = { 0.420, 0.483 },
}
local GLYPH_SET = '[%(%)%[%]/%*]'
local function glyph_tex(c) return string.format('\\cag{%s}{%.3f}{%.3f}', c, GLYPH[c][1], GLYPH[c][2]) end
-- a literal string of this filter, as LaTeX with the boxed glyphs
local function gtext(s) return (s:gsub(GLYPH_SET, glyph_tex)) end
local function glyphs(il)
  local out = pandoc.Inlines({})
  for _, el in ipairs(il) do
    if el.t == 'Str' and el.text:find(GLYPH_SET) then
      local rest = el.text
      while true do
        local s = rest:find(GLYPH_SET)
        if not s then break end
        if s > 1 then out:insert(pandoc.Str(rest:sub(1, s - 1))) end
        out:insert(pandoc.RawInline('latex', glyph_tex(rest:sub(s, s))))
        rest = rest:sub(s + 1)
      end
      if rest ~= '' then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end
local function inlines(l) return glyphs(xe.inlines(bind_closers(l))) end

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

-- typst count-words on the markdown source of the body (frontmatter off, the addendum off, and every top-level
-- section whose heading names oral argument off: FRAP 32(f)), step by step, so that every engine certifies the same
-- number.
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error('ca6-brief: no input file to count words in', 0) end
  local h = assert(io.open(f, 'r'))
  local src = h:read('a')
  h:close()
  local fm = src:match('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n')
  if not fm then error('ca6-brief: the sample must start with a YAML frontmatter block', 0) end
  local body = src:sub(#fm + 1)
  local lines, skip = {}, false
  for line in (body .. '\n'):gmatch('(.-)\r?\n') do
    if line:lower():match('^#[ \t]+addendum[ \t]*$') then break end
    if line:match('^#[ \t]+[^#]') then skip = line:lower():find('oral argument', 1, true) ~= nil end
    if not skip then lines[#lines + 1] = line end
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
-- `toc`: which table lists it ('main', 'add' for the addendum's own, nil for none).
local heads = {}
local function new_head(title_tex, level, ind, label, toc)
  heads[#heads + 1] = { title = title_tex, level = level, ind = ind, label = label or '', toc = toc }
  return #heads
end

local function section(title, toc, macro)
  local i = new_head('\\MakeUppercase{' .. title .. '}', 1, 0, nil, toc)
  return R('\\' .. (macro or 'caHeadOne') .. '{' .. title .. '}{' .. i .. '}')
end

-- A heading of the body: level 1 is a section, the Argument's level 2 is the centred point heading, every other
-- numbered level a sub-heading whose label sits at d half inches. Unnumbered (the statements before the Argument,
-- the addendum): bold, left, indented by level in the TOC.
local function heading_block(h, st)
  local title = tex(h.content)
  if h.level == 1 then
    st.in_arg = trim(plain(h.content):lower()) == 'argument'
    for k = 1, 6 do st.counters[k] = 0 end
    return section(title, st.toc)
  end
  if not st.numbered then
    local toc = st.toc
    if st.toc == 'add' then toc = h.level == 2 and 'add' or nil
    elseif h.level > TOC_DEPTH then toc = nil end
    local i = new_head(title, h.level, h.level - 2, nil, toc)
    return R('\\caHeadPlain{' .. title .. '}{' .. i .. '}')
  end
  st.counters[h.level] = st.counters[h.level] + 1
  for k = h.level + 1, 6 do st.counters[k] = 0 end
  local label = label_for(h.level, st.in_arg, st.counters[h.level])
  local toc = h.level <= TOC_DEPTH and st.toc or nil
  if st.in_arg and h.level == 2 then
    local i = new_head(title, 2, 0, label, toc)
    return R('\\caHeadPoint{' .. label .. '}{' .. title .. '}{' .. i .. '}')
  end
  local d = st.in_arg and (h.level - 2) or (h.level - 1)
  local i = new_head(title, h.level, d, label, toc)
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

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2); CA6-COVER-001 to -007) [cover-body]: one page, no page number
-- ---------------------------------------------------------------------------

local function cover(m)
  local s = {
    '\\thispagestyle{empty}\\begingroup\\singlespacing\\parindent=0pt\\relax',
    '\\cacenter{\\textbf{Case No. ' .. tex(m.case_number) .. '}}',
    '\\cagap\\caDoubleRule\\cagap',
    '\\cacenter{\\textbf{UNITED STATES COURT OF APPEALS\\\\ FOR THE SIXTH CIRCUIT}}',
    '\\cagap\\caShortRule\\cagap',
  }
  -- the case title; a side marked `continues: true` follows the one before it without "v." (CA6-COVER-003)
  for i, side in ipairs(m.caption) do
    if i > 1 and not side.continues then s[#s + 1] = '\\cagap\\cacenter{v.}\\cagap' end
    for _, n in ipairs(side.names) do s[#s + 1] = '\\cacenter{' .. tex(n) .. '}' end
    s[#s + 1] = '\\caright{0.5\\textwidth}{' .. tex(side.designation) .. '}'
  end
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  s[#s + 1] = '\\cacenter{' .. tex(m.proceeding) .. '}'
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  s[#s + 1] = '\\cacenter{\\textbf{\\MakeUppercase{' .. tex(m.brief_title) .. '}}}'
  if m.oral_argument then s[#s + 1] = '\\cagap\\cacenter{\\textbf{ORAL ARGUMENT REQUESTED}}' end
  s[#s + 1] = '\\cagap\\caShortRule\\cagap'
  -- counsel (FRAP 32(a)(2)(F)): 2.6 in from the margin (typst counsel-indent); the lines stepped in 0.5 em
  for gi, g in ipairs(m.counsel) do
    for _, n in ipairs(g.names) do s[#s + 1] = '\\caright{2.6in}{' .. tex(n) .. '}' end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #m.counsel then lines[#lines + 1] = m.phone end
    for _, l in ipairs(lines) do s[#s + 1] = '\\caright{\\dimexpr2.6in+0.5em\\relax}{\\emph{' .. tex(l) .. '}}' end
  end
  s[#s + 1] = '\\cagap\\caDoubleRule\\par\\endgroup'
  return table.concat(s, '\n')
end

-- Corporate disclosure (6th Cir. R. 26.1; CA6-DISC-001) [disclosure-page]: the clerk's two answers, reproduced;
-- unnumbered page before the table of contents. 28 bp below the title, 14 bp between the parts; the question
-- numbers in a 1.6 em box, the text and the answer hanging at 1.6 em.
local function disclosure_tex(m)
  local d = m.disclosure
  local q = '\\caPar\\begingroup\\noindent\\hangindent=1.6em\\hangafter=1\\relax\\makebox[1.6em][l]{%s}%s\\par\\endgroup'
  local a = '\\caPar\\begingroup\\leftskip=1.6em\\relax\\noindent %s\\par\\endgroup'
  return table.concat({
    '\\begin{caSingle}',
    '\\cacenter{\\textbf{DISCLOSURE OF CORPORATE AFFILIATIONS AND FINANCIAL INTEREST}}',
    '\\par\\addvspace{28bp}\\noindent Pursuant to 6th Cir. R. 26.1, ' .. tex(d.party) .. ' makes the following disclosure:',
    string.format(q, '1.', 'Is said party a subsidiary or affiliate of a publicly owned corporation? '
      .. 'If yes, list below the identity of the parent corporation or affiliate and the relationship between it and the named party:'),
    string.format(a, tex(d.subsidiary)),
    string.format(q, '2.', 'Is there a publicly owned corporation, not a party to the appeal, that has a financial interest '
      .. 'in the outcome? If yes, list the identity of such corporation and the nature of the financial interest:'),
    string.format(a, tex(d.financial_interest)),
    '\\end{caSingle}',
  }, '\n')
end

-- ---------------------------------------------------------------------------
-- Signature and certificates
-- ---------------------------------------------------------------------------

-- The filing attorney's lines [signature-lines]: "s/ Name", the name in capitals, the office lines stepped in 0.5 em;
-- `left`: the block's indent.
local function signature_lines(m, left)
  local sig = m.signature
  local s = {
    string.format('\\caright{%s}{%s %s}', left, gtext('s/'), tex(sig.signer)),
    string.format('\\nobreak\\caright{%s}{\\MakeUppercase{%s}}', left, tex(sig.signer)),
  }
  for _, l in ipairs(sig.lines or {}) do
    s[#s + 1] = string.format('\\nobreak\\caright{\\dimexpr%s+0.5em\\relax}{\\emph{%s}}', left, tex(l))
  end
  return table.concat(s, '\n')
end

-- The signature block after the Conclusion [signature-block]: 19.6 bp above; "Respectfully submitted," in the right
-- half, 16.8 bp, the lines; the date at the margin 11.2 bp below. Not split, kept with the last paragraph.
local function signature_tex(m)
  local s = {
    '\\par\\nobreak\\addvspace{19.6bp}\\begingroup\\singlespacing\\parindent=0pt\\relax\\interlinepenalty=10000\\relax',
    '\\caright{0.5\\textwidth}{Respectfully submitted,}\\nobreak\\vskip 16.8bp',
    signature_lines(m, '0.5\\textwidth'),
  }
  if m.date then s[#s + 1] = '\\nobreak\\vskip 11.2bp\\noindent ' .. tex(m.date) .. '\\par' end
  s[#s + 1] = '\\endgroup'
  return table.concat(s, '\n')
end

-- The signature under a certificate [cert-block(signature-block-compact)]: one unbreakable block 14 bp below the
-- text, 16.8 bp inside it before the lines, at the margin; the date 11.2 bp below.
local function signature_compact(m)
  local s = { '\\vskip 16.8bp', signature_lines(m, '0pt') }
  if m.date then s[#s + 1] = '\\nobreak\\vskip 11.2bp\\noindent ' .. tex(m.date) .. '\\par' end
  return table.concat(s, '\n')
end

local function certificate_of_compliance(m, words, basis)
  return table.concat({
    section('Certificate of Compliance', 'main').text,
    '\\begin{caSingle}\\caPar ' .. gtext('I certify that this brief complies with the type-volume limitation of Fed. R. App. P. '
      .. LIMIT_RULE[basis] .. '. Exclusive of the items exempted by Fed. R. App. P. 32(f), the brief contains '
      .. group_digits(words) .. ' words.'),
    '\\caPar The brief has been prepared in a proportionally spaced typeface, ' .. FACE .. ' in 14\\mbox{-}point type, '
      .. gtext('which complies with Fed. R. App. P. 32(a)(5) and (6).'),
    '\\caPar\\vbox{' .. signature_compact(m) .. '}\\end{caSingle}',
  }, '\n')
end

-- Certificate of Service (FRAP 25(d)): one unbreakable block (the certificate and its signature never split).
local function certificate_of_service(m)
  local svc = m.service
  if not svc then error('ca6-brief: missing required metadata field `service`') end
  local parts = {
    '\\par\\addvspace{21bp}\\vbox{\\singlespacing\\parindent=0pt\\relax',
    section('Certificate of Service', 'main', 'caHeadBody').text,
    '\\noindent I certify that on ' .. tex(svc.date) .. ', I electronically filed the foregoing with the Clerk of the Court '
      .. 'using the ' .. gtext('CM/ECF') .. ' system, which will send notification of such filing to all attorneys of record.\\par',
  }
  local unreg = svc.unregistered or {}
  if #unreg > 0 then
    parts[#parts + 1] = '\\vskip 14bp\\noindent I further certify that I have mailed by United States Postal Service the document to the following non-ECF participants:\\par'
    for _, u in ipairs(unreg) do
      parts[#parts + 1] = '\\vskip 14bp\\caright{0.5in}{' .. tex(u.name) .. ', ' .. tex(u.address) .. '}'
    end
  end
  parts[#parts + 1] = signature_compact(m)
  parts[#parts + 1] = '}'
  return table.concat(parts, '\n')
end

-- Table of authorities: the cited ones, grouped by kind and sorted; pages come from the aux file.
local KINDS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}
local function toa_blocks(auth)
  local out = { section('Table of Authorities', 'main') }
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

-- The TOC rows of one table ('main' or 'add'), in document order.
local function toc_rows(which)
  local s = {}
  for i, h in ipairs(heads) do
    if h.toc == which then s[#s + 1] = string.format('\\tocline{%d}{%s}{%s}{%d}', h.ind, h.label, h.title, i) end
  end
  return table.concat(s, '\n')
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

  -- The addendum (after "# Addendum") sits after the certificates.
  local main, add = pandoc.List(), nil
  for i, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 and trim(plain(b.content):lower()) == 'addendum' then
      add = pandoc.List({ table.unpack(blocks, i + 1) })
      break
    end
    main:insert(b)
  end

  -- The statement in support of oral argument must be in the brief (6 Cir. R. 34(a); CA6-ORAL-001).
  if meta.oral_argument then
    local found = false
    for _, b in ipairs(main) do
      if b.t == 'Header' and b.level == 1 and plain(b.content):lower():find('oral argument', 1, true) then found = true end
    end
    if not found then error('ca6-brief: oral_argument is set but the brief has no statement in support of oral argument') end
  end

  -- The statements before the Argument are numbered in roman with the front matter (preliminary_sections).
  local prelim = tonumber(meta.preliminary_sections and plain(meta.preliminary_sections) or '0') or 0
  local prelim_blocks, body_blocks, seen = pandoc.List(), pandoc.List(), 0
  for _, b in ipairs(main) do
    if b.t == 'Header' and b.level == 1 then seen = seen + 1 end
    if prelim > 0 and seen <= prelim then prelim_blocks:insert(b) else body_blocks:insert(b) end
  end
  if prelim > seen then
    error('ca6-brief: preliminary_sections is ' .. prelim .. ' but the body has ' .. seen .. ' sections')
  end

  local words = source_words()
  if words > limit then
    error('ca6-brief: the brief has ' .. words .. ' words; the ' .. basis .. ' limit is ' .. limit)
  end

  local out = pandoc.List()
  -- ---- cover, the corporate disclosure (unnumbered), then the front matter (roman from the table of contents) ----
  out:insert(R('\\normalsize'))   -- \begin{document} reset the size
  out:insert(R(cover(meta)))
  if meta.disclosure then
    out:insert(R('\\clearpage\\thispagestyle{empty}'))
    out:insert(R(disclosure_tex(meta)))
  end
  out:insert(R('\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}'))
  out:insert(section('Table of Contents', nil))
  out:insert(R('\\tochead'))
  local toc_at = #out + 1
  out:insert(R(''))
  out:insert(R('\\clearpage'))
  for _, b in ipairs(toa_blocks(auth)) do out:insert(b) end

  -- ---- statements before the Argument (roman, unnumbered headings) ----
  if prelim > 0 then
    out:insert(R('\\clearpage'))
    local pst = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false, numbered = false, toc = 'main' }
    for _, b in ipairs(prelim_blocks) do
      if b.t == 'Header' then out:insert(heading_block(b, pst)) else out:insert(b) end
    end
  end

  -- ---- body (arabic from 1) ----
  out:insert(R('\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}'))
  local st = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false, numbered = true, toc = 'main' }
  local body = pandoc.List()
  for _, b in ipairs(body_blocks) do
    if b.t == 'Header' then body:insert(heading_block(b, st)) else body:insert(b) end
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

  -- ---- certificates of counsel (FRAP 32(g); 25(d)), after the signature on a new page ----
  out:insert(R('\\clearpage\\singlespacing'))
  out:insert(R(certificate_of_compliance(meta, words, basis)))
  out:insert(R(certificate_of_service(meta)))

  -- ---- addendum: its own pages, numbered Add-1, Add-2, ...; its own table of contents ----
  local add_toc_at
  if add then
    out:insert(R('\\clearpage\\renewcommand{\\thepage}{Add-\\arabic{page}}\\setcounter{page}{1}'))
    out:insert(section('Addendum', 'main'))
    out:insert(section('Table of Contents', nil))
    add_toc_at = #out + 1
    out:insert(R(''))
    out:insert(R('\\clearpage\\normalsize'))
    local ast = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false, numbered = false, toc = 'add' }
    for _, b in ipairs(add) do
      if b.t == 'Header' then out:insert(heading_block(b, ast)) else out:insert(b) end
    end
  end

  out[toc_at] = R(toc_rows('main'))
  if add_toc_at then out[add_toc_at] = R(toc_rows('add')) end
  return pandoc.Pandoc(out, meta)
end
