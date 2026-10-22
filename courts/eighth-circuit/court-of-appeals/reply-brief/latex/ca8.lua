-- Eighth Circuit reply brief, LaTeX engine: the markdown contract (../README.md) -> the macros in template.tex. Builds
-- the cover, the table of contents, the table of authorities, the signature block and the certificates from the YAML
-- frontmatter (the same fields as the typst template), numbers the headings and turns each [text](toa:key) citation
-- into a counted hit for the table of authorities. No case-specific text lives here.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every block is built as the typst template
-- (../typst/ca8-reply-brief.typ) builds it (the names in [brackets] are its functions), with its spaces in bp, so the
-- lines and pages break alike.

-- Per-brief settings, taken from ca8-reply-brief.typ (the same numbers, with the rule each traces to).
local CONFIG = {
  kind = 'reply-brief',
  italic_from = 4,      -- heading titles from this level are italic; labels never (typst style-heading)
  toc_depth = 4,        -- deepest heading level listed in the table of contents (typst toc-depth)
  word_limit = 6500,    -- CA8-LIMIT-001: half of the 13,000-word principal limit (FRAP 32(a)(7)(B)(ii))
  font_name = {'Times New Roman', '14\\mbox{-}point'},   -- typst font-name, printed in the certificate of compliance
}

local function fail(msg) error('ca8-' .. CONFIG.kind .. ': ' .. msg, 0) end

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_texify = require('latex.xengine').inlines

-- Two more rules of this template's text: an ellipsis is one glyph in typst and Word, and T1 Times has none
-- (\textellipsis is three periods, 0.75 em): template.tex's \caellipsis sets the three dots across 1 em and keeps
-- U+2026 as the PDF text. A line may end after a slash that a digit or a second slash does not follow ("Meta/Spill",
-- not "1/2"), as Unicode line breaking lets typst and Word end it; TeX breaks at spaces only.
-- A URL breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows, never after
-- the "//" of its scheme, as the typst
-- template boxes its parts (xengine.sty makes a break after a hyphen free; one before a digit is kept whole).
local function url_breaks(text, out)
  local cur = ""
  local cs = {}
  for _, c in utf8.codes(text) do cs[#cs + 1] = utf8.char(c) end
  for i, c in ipairs(cs) do
    cur = cur .. c
    local nx = cs[i + 1] or ""
    if i < #cs and (c == "?" or c == "=" or c == "&" or (c == "/" and nx ~= "/" and cs[i - 1] ~= "/" and not nx:match("^%d$"))) then
      out:insert(pandoc.Str(cur))
      out:insert(pandoc.RawInline("latex", "\\allowbreak{}"))
      cur = ""
    end
  end
  if cur ~= "" then out:insert(pandoc.Str(cur)) end
end

local function xe_inlines(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(l) do
    if el.t == "Str" and el.text:find("https?://") then
      url_breaks(el.text, out)
    elseif el.t == 'Str' and (el.text:find('\u{2026}', 1, true) or el.text:find('/[^%d/]')) then
      local rest = el.text
      while true do
        local s, e = rest:find('\u{2026}', 1, true)
        local t = rest:find('/[^%d/]')
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

-- A metadata value that holds markdown blocks (summary, disclosure) -> blocks, with the inline rules applied.
local function meta_blocks(v)
  if v == nil then return {} end
  local blocks
  local ty = pandoc.utils.type(v)
  if ty == "string" then blocks = pandoc.read(v, "markdown+smart").blocks
  elseif ty == "Blocks" then blocks = pandoc.Blocks(v)
  else blocks = pandoc.Blocks({pandoc.Para(pandoc.Inlines(v))}) end
  return pandoc.Pandoc(blocks):walk({Inlines = xe_inlines}).blocks
end

-- Plain text of a metadata value (for sort keys and word counts).
local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

local function need(meta, k)
  if meta[k] == nil then fail('missing required metadata field `' .. k .. '`') end
  return meta[k]
end

-- Printed label of a numbered heading (levels 2 to 5) [heading-label]: A. / 1. / a. / (1).
local function label_for(level, n)
  if level == 2 then return string.char(64 + n) .. '.' end
  if level == 3 then return tostring(n) .. '.' end
  if level == 4 then return string.char(96 + n) .. '.' end
  if level == 5 then return '(' .. n .. ')' end
  fail('headings deeper than level 5 are not supported')
end

local function raw(s) return pandoc.RawBlock('latex', s) end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return (out:gsub('^,', ''))
end

-- ---------------------------------------------------------------------------
-- Cover (FRAP 32(a)(2)(A)-(F)) [cover-body]
-- ---------------------------------------------------------------------------

local function cover(meta)
  local L = {}
  local function add(s) L[#L + 1] = s end
  local P = '\\par\\addvspace{4.9bp}'
  add('\\thispagestyle{empty}\\begingroup\\centering\\singlespacing\\parindent=0pt\\relax')
  add('\\textbf{No.\\ ' .. tex(need(meta, 'case_number')) .. '}\\par\\cagap{}')
  add('{\\bfseries IN THE UNITED STATES COURT OF APPEALS\\\\ FOR THE EIGHTH CIRCUIT\\par}\\cagap[1.5]')
  local sides = need(meta, 'caption')
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. P) end
    add('{\\raggedright\\leftskip=0.5\\linewidth\\noindent ' .. tex(side.designation) .. '\\par}')
    if i < #sides then add('\\cagap[0.6]v.\\par\\cagap[0.6]') end
  end
  add('\\cagap[1.5]' .. tex(need(meta, 'proceeding')) .. P)
  if meta.district_court_case ~= nil then add('D.C. No.\\ ' .. tex(plain(meta.district_court_case)) .. '\\par') end
  add('\\cagap[1.5]\\textbf{\\MakeUppercase{' .. tex(need(meta, 'brief_title')) .. '}}\\par\\cagap[1.5]')
  -- (F) counsel, from a quarter of the width: each group the names, then its lines 7 bp in (the last holds the phone)
  add('{\\raggedright\\leftskip=0.25\\linewidth\\parindent=0pt\\relax')
  for _, g in ipairs(need(meta, 'counsel')) do
    local b = {}
    for _, n in ipairs(g.names) do b[#b + 1] = tex(n) end
    for _, l in ipairs(g.lines or {}) do b[#b + 1] = '\\hspace*{7bp}' .. tex(l) end
    add('\\begingroup\\interlinepenalty=10000\\relax\\noindent ' .. table.concat(b, '\\newline ') .. '\\par\\endgroup\\cagap[0.5]')
  end
  add('}')
  if meta.date ~= nil then add('\\cagap{}' .. tex(meta.date) .. '\\par') end
  add('\\endgroup')
  return table.concat(L, '\n')
end

-- ---------------------------------------------------------------------------
-- Signature, certificates (FRAP 32(g); CA8-CERT-001 to -003)
-- ---------------------------------------------------------------------------

-- [signature-block]: 19.6 bp above; in the right half "Respectfully submitted,", 16.8 bp, "/s/ Signer", the signer,
-- the further lines; each other signer 11.2 bp below, with its lines; then 11.2 bp and the date at the margin, and
-- 11.2 bp and the note; never split.
local function signature(meta)
  local sig = need(meta, 'signature')
  local lines = {'/s/ ' .. tex(sig.signer), tex(sig.signer)}
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = tex(l) end
  local out = {'\\par\\nobreak\\addvspace{19.6bp}\\begingroup\\singlespacing\\interlinepenalty=10000\\relax\\parindent=0pt\\relax',
    '{\\raggedright\\leftskip=0.5\\linewidth\\noindent Respectfully submitted,\\par\\nobreak\\vskip16.8bp\\noindent ' ..
    table.concat(lines, '\\newline ') .. '\\par'}
  for _, a in ipairs(sig.also or {}) do
    local b = {tex(a.name)}
    for _, l in ipairs(a.lines or {}) do b[#b + 1] = tex(l) end
    out[#out + 1] = '\\nobreak\\vskip11.2bp\\noindent ' .. table.concat(b, '\\newline ') .. '\\par'
  end
  out[#out + 1] = '}'
  if meta.date ~= nil then out[#out + 1] = '\\nobreak\\vskip11.2bp\\noindent ' .. tex(meta.date) .. '\\par' end
  if sig.note ~= nil then out[#out + 1] = '\\nobreak\\vskip11.2bp\\noindent ' .. tex(sig.note) .. '\\par' end
  out[#out + 1] = '\\endgroup'
  return table.concat(out, '\n')
end

-- [cert-sig]: 19.6 bp above; in the right half "/s/ Signer", the signer, the role
local function cert_sig(meta)
  local sig = need(meta, 'signature')
  return '\\par\\addvspace{19.6bp}\\begingroup\\singlespacing\\interlinepenalty=10000\\relax' ..
    '\\raggedright\\leftskip=0.5\\linewidth\\noindent /s/ ' .. tex(sig.signer) .. '\\newline ' .. tex(sig.signer) ..
    '\\newline ' .. tex(sig.role or 'Counsel for Appellant') .. '\\par\\endgroup'
end

-- ---------------------------------------------------------------------------
-- Table of authorities [toa-section]
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
  for key in pairs(hits) do
    if auth[key] == nil then
      fail('link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
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
-- Words (FRAP 32(f), (g)(1)): whitespace-delimited words of the body, footnotes included [count-words]
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
  for _, k in ipairs({'case_number', 'caption', 'proceeding', 'brief_title', 'counsel', 'signature'}) do need(meta, k) end

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

  -- the words (CA8-LIMIT-001), footnotes included, counted before the inline rules (they turn dashes and quotes into
  -- raw LaTeX, which stringify drops)
  local words = count_blocks(doc.blocks)
  if words > CONFIG.word_limit then
    fail('the reply brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(ii) allows ' .. CONFIG.word_limit)
  end
  doc = doc:walk({Inlines = xe_inlines})
  -- [quote]: 12.6 bp between the paragraphs of a block quotation
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

  -- headings: level 1 is an unnumbered section; levels 2 to 5 A. / 1. / a. / (1), one step in per level
  local counters = {0, 0, 0, 0, 0, 0}
  local heads = {}
  doc = doc:walk({
    Header = function(h)
      if h.level == 1 and plain(h.content):lower():match('^%s*addendum%s*$') then
        fail('the LaTeX engine does not render an addendum')
      end
      if h.level == 1 then counters = {0, 0, 0, 0, 0, 0} end
      counters[h.level] = counters[h.level] + 1
      for i = h.level + 1, 6 do counters[i] = 0 end
      local label = h.level == 1 and '' or label_for(h.level, counters[h.level])
      local title = tex(h.content)
      local idx = #heads + 1
      local steps = h.level == 1 and 0 or (h.level - 2)
      heads[idx] = {level = h.level, label = label, title = title, steps = steps}
      return raw(string.format('\\cahead{%d}{%d}{%s}{%s}{h%d}{%d}', h.level, steps, label, title, idx, CONFIG.italic_from))
    end,
  })
  local svc = meta.service ~= nil and meta.service.certificate == true

  -- front matter: the cover, then (lower roman from i) the contents and the authorities, each on its own page
  local front = pandoc.Blocks({})
  front:insert(raw('\\singlespacing'))
  front:insert(raw(cover(meta)))
  front:insert(raw('\\clearpage\\pagenumbering{roman}\\singlespacing\\cahead{1}{0}{}{Table of Contents}{toc}{99}' ..
    '\\par\\addvspace{4.2bp}\\begingroup\\raggedleft\\singlespacing\\bfseries\\underline{Page}\\par\\endgroup'))
  -- [toc-section]: the outlined headings up to toc_depth (the body, the certificates; not the tables)
  local function tocline(level, steps, label, title, key)
    return string.format('\\tocline{%d}{%d}{%s}{%s}{%s}', level, steps, label, title, key)
  end
  local toc = {}
  for i, h in ipairs(heads) do
    if h.level <= CONFIG.toc_depth then toc[#toc + 1] = tocline(h.level, h.steps, h.label, h.title, 'h' .. i) end
  end
  toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Compliance', 'cc')
  if svc then toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Service', 'cs') end
  front:insert(raw(table.concat(toc, '\n')))
  front:insert(raw('\\clearpage\n' .. table.concat(toa(meta, hits), '\n')))
  front:insert(raw('\\clearpage\\pagenumbering{arabic}\\normalsize'))

  -- [certificate-of-compliance], [certificate-of-service]: single-spaced paragraphs 14 bp apart, then the signature
  local back = pandoc.Blocks({})
  back:insert(raw('\\clearpage\\cahead{1}{0}{}{Certificate of Compliance}{cc}{99}\\begingroup\\singlespacing' ..
    '\\caformpar{I certify that this brief complies with the type-volume limitation of Fed.~R.~App.~P. 32(a)(7)(B) ' ..
    'because it contains ' .. group_digits(words) .. ' words, excluding the parts of the brief exempted by ' ..
    'Fed.~R.~App.~P. 32(f). The brief complies with the typeface requirements of Fed.~R.~App.~P. 32(a)(5) and the ' ..
    'type-style requirements of Fed.~R.~App.~P. 32(a)(6) because it has been prepared in a proportionally spaced ' ..
    'typeface (\\mbox{' .. CONFIG.font_name[1] .. '}, \\mbox{' .. CONFIG.font_name[2] .. '}).}' ..
    '\\caformpar{Pursuant to Circuit~Rule~28A(h), I also certify that the electronic files of this brief have been ' ..
    'submitted to the Clerk through the Court\\textquoteright{}s CM/ECF system and have been scanned for viruses and ' ..
    'are virus-free.}' .. cert_sig(meta) .. '\\endgroup'))
  if svc then
    back:insert(raw('\\clearpage\\cahead{1}{0}{}{Certificate of Service}{cs}{99}\\begingroup\\singlespacing' ..
      '\\caformpar{Pursuant to Fed.~R.~App.~P. 25 and Circuit~Rule~25A(a), I hereby certify that on ' ..
      (meta.date ~= nil and tex(meta.date) or '\\rule{6em}{0.4bp}') .. ', I filed a copy of the ' ..
      tex(plain(meta.brief_title)) .. ' with the Clerk of the Court through the Court\\textquoteright{}s CM/ECF ' ..
      'system, which will serve electronic copies on all registered counsel.}' .. cert_sig(meta) .. '\\endgroup'))
  end

  -- The signature never stands alone: the brief's last paragraph (above the footnote definitions) is not broken
  -- across pages and stays with the signature block (typst: one unbreakable block), unless it is a heading.
  local n = #doc.blocks
  local sig = signature(meta)
  if n > 0 and doc.blocks[n].t ~= 'RawBlock' then
    doc.blocks:insert(n, raw('\\begingroup\\interlinepenalty=10000\\relax'))
    doc.blocks:insert(raw(sig .. '\\par\\endgroup'))
  else
    doc.blocks:insert(raw(sig))
  end
  local blocks = pandoc.Blocks({})
  blocks:extend(front)
  blocks:extend(doc.blocks)
  blocks:extend(back)
  doc.blocks = blocks
  return doc
end
