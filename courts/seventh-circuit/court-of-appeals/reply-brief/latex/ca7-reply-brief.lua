-- ca7-reply-brief: pandoc Lua filter for the LaTeX engine (see ../README.md, "Engines").
-- Builds the cover, the table of contents, the table of authorities, the signature block and the
-- certificates from the YAML frontmatter (same fields as the typst template), numbers the headings
-- and turns each [text](toa:key) citation into a counted hit for the table of authorities.
-- Typesetting macros are in template.tex. No case-specific text lives here.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every block is built as the typst template builds
-- it (the names in [brackets] are its functions), with its spaces in bp, so the lines and pages break alike.

-- Per-brief settings, taken from ca7-reply-brief.typ (the same numbers, with the rule each traces to).
local CONFIG = {
  answering = false,    -- answering brief: "Argument" point headings are centered; A./1./a./(1) elsewhere
  base = 1,             -- label indent: a level-2 heading sits at 0.5 in when base = 2, at 0 when base = 1
  italic_from = 4,      -- headings from this level are italic (typst style-heading)
  toc_depth = 3,        -- deepest heading level listed in the table of contents (typst toc-depth)
  word_limit = 7000,    -- Cir. R. 32(c): a reply brief
}

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_texify = require('latex.xengine').inlines

-- Two more rules of this template's text: an ellipsis is one glyph of 1 em in typst and Word, and T1 Times has none
-- (\textellipsis is three periods, 0.75 em): template.tex's \caellipsis sets the three dots across 1 em and keeps
-- U+2026 as the PDF text. A line may end after a slash that a digit does not follow ("Meta/Spill", not "1/2"), as
-- Unicode line breaking lets typst and Word end it; TeX breaks at spaces only.
local function xe_inlines(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(l) do
    if el.t == 'Str' and (el.text:find('\u{2026}', 1, true) or el.text:find('/[^%d]')) then
      local rest = el.text
      while true do
        local s, e = rest:find('\u{2026}', 1, true)
        local t = rest:find('/[^%d]')
        if t and (not s or t < s) then
          out:insert(pandoc.Str(rest:sub(1, t)))
          out:insert(pandoc.RawInline('latex', '\\allowbreak{}'))
          rest = rest:sub(t + 1)
        elseif s then
          if s > 1 then out:insert(pandoc.Str(rest:sub(1, s - 1))) end
          out:insert(pandoc.RawInline('latex', '\\caellipsis{}'))
          rest = rest:sub(e + 1)
        else
          break
        end
      end
      if rest ~= '' then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return xe_texify(out)
end

-- Inline markdown in a metadata value -> LaTeX.
local function tex(v)
  if v == nil then return '' end
  if type(v) == 'string' then v = pandoc.Inlines({pandoc.Str(v)}) end
  local s = pandoc.write(pandoc.Pandoc({pandoc.Plain(xe_inlines(pandoc.Inlines(v)))}), 'latex')
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

-- Plain text of a metadata value (for sort keys and word counts).
local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

local function roman(n)
  local vals = {{1000, 'M'}, {900, 'CM'}, {500, 'D'}, {400, 'CD'}, {100, 'C'}, {90, 'XC'},
    {50, 'L'}, {40, 'XL'}, {10, 'X'}, {9, 'IX'}, {5, 'V'}, {4, 'IV'}, {1, 'I'}}
  local out = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return out
end

-- Printed label of a numbered heading (levels 2 to 5). Opening and reply: I. / A. / 1. / a. Answering:
-- the same inside the Argument, and A. / 1. / a. / (1) elsewhere.
local function label_for(level, n, in_arg)
  local point_roman = not CONFIG.answering or in_arg
  if level == 2 then return point_roman and (roman(n) .. '.') or (string.char(64 + n) .. '.') end
  if level == 3 then return point_roman and (string.char(64 + n) .. '.') or (tostring(n) .. '.') end
  if level == 4 then return point_roman and (tostring(n) .. '.') or (string.char(96 + n) .. '.') end
  if level == 5 then return point_roman and (string.char(96 + n) .. '.') or ('(' .. n .. ')') end
  error('ca7-reply-brief: headings deeper than level 5 are not supported')
end

-- Label indent in half inches (typst label-indent): the answering brief indents its non-Argument
-- headings one step less than its Argument sub-headings.
local function steps_for(level, in_arg)
  if CONFIG.answering then return level - (in_arg and 2 or 1) end
  return level - CONFIG.base
end

local function raw(s) return pandoc.RawBlock('latex', s) end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2)(A)-(F))
-- ---------------------------------------------------------------------------

-- Rules in vertical mode with no interline glue: they cost their own height, as in typst.
local SHORT = '\\nointerlineskip\\hbox to\\linewidth{\\hss\\rule{2in}{0.7pt}\\hss}\\nointerlineskip'
local DOUBLE = '\\nointerlineskip\\hbox to\\linewidth{\\rule{\\linewidth}{1.6pt}}\\nointerlineskip\\vspace{2.5pt}' ..
  '\\nointerlineskip\\hbox to\\linewidth{\\rule{\\linewidth}{0.5pt}}\\nointerlineskip'

-- [cover-body]: single-spaced and centered, 4.2 bp between paragraphs; the gaps between the parts give.
local function cover(meta)
  local L = {}
  local function add(s) L[#L + 1] = s end
  local function need(k)
    if meta[k] == nil then error('ca7-reply-brief: missing required metadata field `' .. k .. '`') end
    return meta[k]
  end
  local P = '\\par\\addvspace{4.2bp}'
  add('\\thispagestyle{empty}\\begingroup\\centering\\singlespacing\\parindent=0pt\\relax')
  -- (A) the number of the case; (B) the name of the court
  add(tex(need('case_number')) .. '\\par\\cagap{}')
  add('In the United States Court of Appeals' .. P .. '\\textbf{FOR THE SEVENTH CIRCUIT}\\par\\cagap{}')
  -- (C) the title of the case
  local sides = need('caption')
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. P) end
    add('{\\raggedright\\leftskip=0.5\\linewidth\\noindent ' .. tex(side.designation) .. P .. '}')
    if i < #sides then add('\\cagap{}v.\\par\\cagap{}') end
  end
  add('\\cagap{}' .. SHORT .. '\\cagap{}')
  -- (D) the nature of the proceeding and the court below: "No. X (Judge)"
  add(tex(need('proceeding')) .. P)
  if meta.district_court_case ~= nil or meta.judge ~= nil then
    local parts = {}
    if meta.district_court_case ~= nil then parts[#parts + 1] = 'No.\\ ' .. tex(meta.district_court_case) end
    if meta.judge ~= nil then parts[#parts + 1] = '(' .. tex(meta.judge) .. ')' end
    add(table.concat(parts, ' ') .. P)
  end
  add('\\cagap{}' .. SHORT .. '\\cagap{}')
  -- (E) the title of the brief
  add('\\textbf{\\MakeUppercase{' .. tex(need('brief_title')) .. '}}\\par\\cagap{}')
  add(SHORT .. '\\cagap{}')
  -- (F) counsel: two columns of (text width - 0.3 in) / 2, as typst's grid; a group goes right when it says
  -- `column: right`; each group its names and lines as given, 8.4 bp after it; `counsel_note` closes the right one.
  local function col(groups, note)
    local b = {}
    for _, g in ipairs(groups) do
      local x = {}
      for _, n in ipairs(g.names) do x[#x + 1] = tex(n) end
      for _, l in ipairs(g.lines or {}) do x[#x + 1] = tex(l) end
      b[#b + 1] = table.concat(x, '\\newline\n') .. '\\par\\addvspace{8.4bp}'
    end
    if note ~= nil then b[#b + 1] = '\\emph{' .. tex(note) .. '}\\par' end
    return '\\begin{minipage}[t]{\\dimexpr(\\linewidth-0.3in)/2\\relax}\\singlespacing\\raggedright\\parindent=0pt ' ..
      table.concat(b, '\n') .. '\\end{minipage}'
  end
  local left, right = {}, {}
  for _, g in ipairs(need('counsel')) do
    if g.column ~= nil and plain(g.column) == 'right' then right[#right + 1] = g else left[#left + 1] = g end
  end
  add('\\carow{' .. col(left) .. '\\hfill' .. col(right, meta.counsel_note) .. '}\\cagap{}')
  add(DOUBLE)
  add('\\endgroup')
  return table.concat(L, '\n')
end

-- ---------------------------------------------------------------------------
-- Certificates and signature (FRAP 32(g), Form 6; FRAP 25(d))
-- ---------------------------------------------------------------------------

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return (out:gsub('^,', ''))
end

-- [signature-block]: 16.8 bp, then in the right half "Respectfully submitted," 14.4 bp, "/s/ Name" over NAME and the
-- signer's lines 0.5 em in, then 9.6 bp and "Dated:" at the margin; one unbreakable block.
local function signature(meta)
  local sig = meta.signature
  local L = {}
  L[#L + 1] = '\\par\\addvspace{16.8bp}\\begingroup\\singlespacing\\interlinepenalty=10000\\relax'
  L[#L + 1] = '\\begingroup\\raggedright\\leftskip=0.5\\linewidth\\parindent=0pt\\relax'
  L[#L + 1] = 'Respectfully submitted,\\par\\nobreak\\vspace{14.4bp}\\nobreak'
  local x = {'/s/ ' .. tex(sig.signer), '\\MakeUppercase{' .. tex(sig.signer) .. '}'}
  for _, l in ipairs(sig.lines or {}) do x[#x + 1] = '\\hspace*{0.5em}' .. tex(l) end
  L[#L + 1] = table.concat(x, '\\newline\n') .. '\\par'
  L[#L + 1] = '\\endgroup'
  if meta.date ~= nil then
    L[#L + 1] = '\\nobreak\\vspace{9.6bp}\\nobreak\\noindent Dated: ' .. tex(meta.date) .. '\\par'
  end
  L[#L + 1] = '\\endgroup'
  return table.concat(L, '\n')
end

-- [form-sig-line]: 19.2 bp above; "/s/ Name" over "Signature", the date over "Date" in a column that starts
-- (text width + 1 em) / 2 in, as typst's grid.
local function form_sig_line(meta)
  local col = '\\makebox[\\dimexpr(\\linewidth+12bp)/2\\relax][l]'
  return '\\par\\nobreak\\addvspace{19.2bp}\\nobreak\\begingroup\\singlespacing\\interlinepenalty=10000\\relax' ..
    '\\noindent' .. col .. '{/s/ ' .. tex(meta.signature.signer) .. '}' .. tex(meta.date) ..
    '\\par\\nobreak\\noindent' .. col .. '{Signature}Date\\par\\endgroup'
end

-- ---------------------------------------------------------------------------
-- Table of authorities
-- ---------------------------------------------------------------------------

local ORDER = {'case', 'constitution', 'statute', 'regulation', 'rule', 'other'}
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
  -- every hit must have an entry in the frontmatter (loud failure beats silent omission)
  for key in pairs(hits) do
    if auth[key] == nil then
      error('ca7-reply-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
    end
  end
  out[#out + 1] = '\\cahead{1}{0}{}{Table of Authorities}{toa}{99}'
  local first = true
  for _, kind in ipairs(ORDER) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == kind and hits[key] ~= nil then members[#members + 1] = {key = key, a = a} end
    end
    table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
    if #members > 0 then
      out[#out + 1] = '\\toagroup{' .. TITLES[kind] .. '}{' .. (first and 1 or 0) .. '}'
      first = false
      for _, m in ipairs(members) do
        local name = m.a.name ~= nil and tex(m.a.name) or ''
        out[#out + 1] = string.format('\\toaitem{%s}{%s}{%d}{%s}', name, tex(m.a.cite),
          kind == 'case' and 1 or 0, m.key)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Words (Cir. R. 32(c)): whitespace-delimited words of the body, footnotes included
-- ---------------------------------------------------------------------------

-- Block by block (stringify of the whole document would run the last word of one block into the first of the
-- next), footnote text included, footnote marks and list markers not counted: the typst template's count.
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

-- ---------------------------------------------------------------------------
-- The filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta

  -- pass 1: count the toa: citations; each writes its page to the aux file at its place (\toahit)
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = el.target:sub(5)
      hits[key] = (hits[key] or 0) + 1
      local out = pandoc.Inlines({pandoc.RawInline('latex', '\\toahit{' .. key .. '}')})
      out:extend(el.content)
      return out
    end,
  })

  -- the words, counted before the inline rules (they turn dashes and quotes into raw LaTeX, which stringify drops);
  -- then the cross-engine inline rules over the body text
  local words = count_blocks(doc.blocks)
  doc = doc:walk({Inlines = xe_inlines})
  -- [quote]: 10.8 bp between the paragraphs of a block quotation
  doc = doc:walk({
    BlockQuote = function(q)
      local c = pandoc.Blocks({})
      for i, b in ipairs(q.content) do
        if i > 1 then c:insert(raw('\\caquotepar')) end
        c:insert(b)
      end
      q.content = c
      return q
    end,
  })

  -- pass 2: headings. Level 1 is an unnumbered section; levels 2 to 5 number as in typst.
  local counters = {0, 0, 0, 0, 0, 0}
  local in_arg = false
  local heads = {}
  local function add_head(level, title_tex, label)
    heads[#heads + 1] = {level = level, label = label, title = title_tex, idx = #heads + 1,
      steps = steps_for(level, in_arg), centered = CONFIG.answering and in_arg and level == 2}
    return #heads
  end
  if words > CONFIG.word_limit then
    error('ca7-reply-brief: the brief has ' .. words .. ' words; Circuit Rule 32(c) allows ' .. CONFIG.word_limit)
  end
  doc = doc:walk({
    Header = function(h)
      local text = plain(h.content)
      if h.level == 1 and text:lower():match('^%s*addendum%s*$') then
        error('ca7-reply-brief: the LaTeX engine does not yet render an addendum (FRAP 28(f))')
      end
      if h.level == 1 then
        in_arg = text:lower():match('^%s*argument%s*$') ~= nil
        counters = {0, 0, 0, 0, 0, 0}
        counters[1] = 0
      end
      counters[h.level] = counters[h.level] + 1
      for i = h.level + 1, 6 do counters[i] = 0 end
      local label = h.level == 1 and '' or label_for(h.level, counters[h.level], in_arg)
      local title = tex(h.content)
      local idx = add_head(h.level, title, label)
      if heads[idx].centered then
        return raw(string.format('\\cacenter{%s}{%s}{h%d}', label, title, idx))
      end
      return raw(string.format('\\cahead{%d}{%d}{%s}{%s}{h%d}{%d}', h.level, steps_for(h.level, in_arg),
        label, title, idx, CONFIG.italic_from))
    end,
  })

  -- front matter: the cover counts as page i (not printed), the table of contents is ii
  local front = {}
  front[#front + 1] = raw('\\singlespacing\\pagenumbering{roman}')
  front[#front + 1] = raw(cover(meta))
  front[#front + 1] = raw('\\clearpage\\cahead{1}{0}{}{Table of Contents}{toc}{99}' ..
    '\n\\par\\addvspace{3.6bp}\\begingroup\\raggedleft\\singlespacing\\bfseries\\underline{Page}\\par\\endgroup')

  -- table of contents: the body's headings up to toc_depth; point headings at the margin, each deeper level half an
  -- inch in (typst toc-entry)
  local toc = {}
  for _, h in ipairs(heads) do
    if h.level <= CONFIG.toc_depth then
      local steps = h.level == 1 and 0 or (h.level - 2)
      toc[#toc + 1] = string.format('\\tocline{%d}{%d}{%s}{%s}{%s}', h.level, steps, h.label, h.title, 'h' .. h.idx)
    end
  end
  front[#front + 1] = raw(table.concat(toc, '\n'))

  local toa_lines = toa(meta, hits)
  front[#front + 1] = raw('\\clearpage\n' .. table.concat(toa_lines, '\n'))
  front[#front + 1] = raw('\\clearpage\\pagenumbering{arabic}\\normalsize')

  -- back matter: signature, then the certificates, each on a new page (typst pagebreak(weak))
  local back = {raw(signature(meta))}
  back[#back + 1] = raw('\\clearpage\\cahead{1}{0}{}{Certificate of Compliance}{cc}{99}')
  -- [certificate-of-compliance]: Form 6, two paragraphs 12 bp apart; the typeface is named, not the program
  back[#back + 1] = raw('\\begingroup\\singlespacing\\parindent=0pt\\relax I certify that this brief complies with ' ..
    'the type-volume limit of Fed. R. App. P. 32(a)(7)(B), as modified by Cir. R. 32(c). Excluding the parts of ' ..
    'the brief exempted by Fed. R. App. P. 32(f), this brief contains ' .. group_digits(words) .. ' words.' ..
    '\\par\\addvspace{12bp}I further certify that this brief complies with the typeface requirements of Fed. R. ' ..
    'App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6), as modified by Cir. R. 32(b). ' ..
    'This brief has been prepared in a proportionally spaced typeface, Times New Roman, in 12-point type for the ' ..
    'body text and 11-point type for the footnotes.\\par\\endgroup')
  back[#back + 1] = raw(form_sig_line(meta))
  local svc = meta.service
  if svc ~= nil and svc.certificate then
    -- [certificate-of-service]: CM/ECF notice, Cir. R. 31(b) paper copies, the unregistered participants
    back[#back + 1] = raw('\\clearpage\\cahead{1}{0}{}{Certificate of Service}{cs}{99}')
    local L = {'\\begingroup\\singlespacing\\parindent=0pt\\relax I hereby certify that on ' .. tex(meta.date) ..
      ', I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals ' ..
      'for the Seventh Circuit by using the CM/ECF system, which will send notice of such filing to all registered ' ..
      'CM/ECF users.\\par'}
    if svc.paper_copies ~= nil then
      L[#L + 1] = '\\addvspace{12bp}Pursuant to Circuit Rule 31(b), upon notice of this Court\u{2019}s acceptance of ' ..
        'the electronic brief for filing, I certify that I will cause ' .. tex(plain(svc.paper_copies)) ..
        ' copies of the above-named brief to be delivered to the Clerk of the Court.\\par'
    end
    local unreg = svc.unregistered or {}
    if #unreg > 0 then
      L[#L + 1] = '\\addvspace{12bp}\\textbf{Service on case participants who are not registered for electronic ' ..
        'filing:}\\par\\addvspace{12bp}I certify that I served the foregoing on this date by hand delivery, mail, ' ..
        'third-party commercial carrier, or, having obtained prior consent, by email, to the following unregistered ' ..
        'participants:\\par'
      for _, u in ipairs(unreg) do
        L[#L + 1] = '\\addvspace{8.4bp}{\\leftskip=0.5in\\interlinepenalty=10000\\relax ' .. tex(u.name) .. ', ' ..
          tex(u.address) .. '\\par}'
      end
    end
    L[#L + 1] = '\\endgroup'
    back[#back + 1] = raw(table.concat(L, '\n'))
    back[#back + 1] = raw(form_sig_line(meta))
  end

  -- The signature never stands alone: the brief's last paragraph is not broken across pages and stays with the
  -- signature block (typst: one unbreakable block), unless the body ends with a heading (footnote definitions are
  -- not blocks here, as typst sets them apart).
  local n = #doc.blocks
  if n > 0 and doc.blocks[n].t ~= 'RawBlock' then
    doc.blocks:insert(n, raw('\\begingroup\\interlinepenalty=10000\\relax'))
    doc.blocks:insert(raw('\\par\\nobreak\\endgroup'))
  end
  local blocks = pandoc.Blocks({})
  for _, b in ipairs(front) do blocks:insert(b) end
  for _, b in ipairs(doc.blocks) do blocks:insert(b) end
  for _, b in ipairs(back) do blocks:insert(b) end
  doc.blocks = blocks
  return doc
end
