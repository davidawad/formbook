-- Eighth Circuit appellee's (answering) brief, LaTeX engine: the markdown contract (../README.md) -> the macros in
-- template.tex. Builds the cover, the summary of the case, the corporate disclosure statement, the table of
-- contents, the table of authorities, the signature block and the certificates from the YAML frontmatter (the same
-- fields as the typst template), numbers the headings and turns each [text](toa:key) citation into a counted hit
-- for the table of authorities. No case-specific text lives here.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"): every block is built as the typst template
-- (../typst/ca8-answering-brief.typ) builds it (the names in [brackets] are its functions), with its spaces in bp,
-- so the lines and pages break alike.

-- Per-brief settings, taken from ca8-answering-brief.typ (the same numbers, with the rule each traces to).
local CONFIG = {
  kind = 'answering-brief',
  italic_from = 4,      -- headings from this level are italic (typst style-heading)
  toc_depth = 4,        -- deepest heading level listed in the table of contents (typst toc-depth)
  word_limit = 13000,   -- FRAP 32(a)(7)(B)(i): the appellee's brief is a principal brief (FRAP 28(b))
  summary_title = 'Summary of the Case and Statement on Oral Argument',   -- 8th Cir. R. 28A(i)(1)
  typeface = '14-point Times New Roman',   -- typst: #int(type-size / 1pt)-point #font-family.first()
}

local function fail(msg) error('ca8-' .. CONFIG.kind .. ': ' .. msg, 0) end

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_texify = require('latex.xengine').inlines

-- Two more rules of this template's text: an ellipsis is one glyph of 1 em in typst and Word, and T1 Times has none
-- (\textellipsis is three periods, 0.75 em): template.tex's \caellipsis sets the three dots across 1 em and keeps
-- U+2026 as the PDF text. A line may end after a slash that a digit or a second slash does not follow ("Meta/Spill",
-- not "1/2"), as Unicode line breaking lets typst and Word end it; TeX breaks at spaces only.
-- A URL breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows, as the typst
-- template boxes its parts (xengine.sty makes a break after a hyphen free; one before a digit is kept whole).
local function url_breaks(text, out)
  local cur = ""
  local cs = {}
  for _, c in utf8.codes(text) do cs[#cs + 1] = utf8.char(c) end
  for i, c in ipairs(cs) do
    cur = cur .. c
    local nx = cs[i + 1] or ""
    if i < #cs and (c == "?" or c == "=" or c == "&" or (c == "/" and nx ~= "/" and not nx:match("^%d$"))) then
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

-- Printed label of a numbered heading (levels 2 to 5) [heading-label]: in the Argument I. / A. / 1. / a.,
-- elsewhere A. / 1. / a. / (1).
local function label_for(level, n, in_arg)
  if level == 2 then return in_arg and (roman(n) .. '.') or (string.char(64 + n) .. '.') end
  if level == 3 then return in_arg and (string.char(64 + n) .. '.') or (tostring(n) .. '.') end
  if level == 4 then return in_arg and (tostring(n) .. '.') or (string.char(96 + n) .. '.') end
  if level == 5 then return in_arg and (string.char(96 + n) .. '.') or ('(' .. n .. ')') end
  fail('headings deeper than level 5 are not supported')
end

-- Label indent in half inches [label-indent]: (level - first + 1), first = 3 in the Argument, 2 elsewhere.
local function steps_for(level, in_arg)
  return level - (in_arg and 2 or 1)
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

-- [counsel-block]: the counsel groups in two columns (14 pt type, single-spaced, centered): the names, then the
-- address and contact lines in italics; a group's own `phone` follows its lines, a top-level `phone` (when no group
-- has one) the last group's. Rows of two, 16.8 bp apart.
local function counsel_block(meta)
  local groups = need(meta, 'counsel')
  local has_group_phone = false
  for _, g in ipairs(groups) do if g.phone ~= nil then has_group_phone = true end end
  local cells = {}
  for gi, g in ipairs(groups) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = tex(n) end
    local rest = {}
    for _, l in ipairs(g.lines or {}) do rest[#rest + 1] = l end
    if g.phone ~= nil then rest[#rest + 1] = g.phone
    elseif gi == #groups and not has_group_phone then rest[#rest + 1] = need(meta, 'phone') end
    for _, l in ipairs(rest) do lines[#lines + 1] = '\\emph{' .. tex(l) .. '}' end
    cells[#cells + 1] = '\\centering ' .. table.concat(lines, '\\\\ ') .. '\\par'
  end
  local rows = {}
  for i = 1, #cells, 2 do
    rows[#rows + 1] = (i > 1 and '\\par\\addvspace{16.8bp}' or '') ..
      '\\cacols{16.8bp}{' .. cells[i] .. '}{' .. (cells[i + 1] or '') .. '}'
  end
  return table.concat(rows, '\n')
end

local function cover(meta)
  local L = {}
  local function add(s) L[#L + 1] = s end
  local P = '\\par\\addvspace{4.9bp}'
  add('\\thispagestyle{empty}\\begingroup\\centering\\singlespacing\\parindent=0pt\\relax')
  add('\\cagap[0.6]No.\\ ' .. tex(need(meta, 'case_number')) .. '\\par\\cagap{}')
  add('{\\bfseries IN THE UNITED STATES COURT OF APPEALS\\\\ FOR THE EIGHTH CIRCUIT\\par}\\cagap{}')
  add('\\cadoublerule\\cagap{}')
  local sides = need(meta, 'caption')
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. P) end
    add('\\emph{' .. tex(side.designation) .. '}\\par')
    if i < #sides then add('\\cagap[0.3]v.\\par\\cagap[0.3]') end
  end
  add('\\cagap{}\\cadoublerule\\cagap{}')
  add(tex(need(meta, 'proceeding')) .. P)
  local d = {}
  if meta.district_court_case ~= nil then d[#d + 1] = tex(meta.district_court_case) end
  if meta.judge ~= nil then d[#d + 1] = tex(meta.judge) end
  if #d > 0 then add(table.concat(d, ', ') .. '\\par') end
  add('\\cagap{}\\cadoublerule\\cagap{}')
  add('\\textbf{' .. tex(need(meta, 'brief_title')) .. '}\\par\\cagap{}')
  add('\\cadoublerule\\cagap{}')
  add(counsel_block(meta))
  add('\\cagap{}\\cadoublerule')
  add('\\endgroup')
  return table.concat(L, '\n')
end

-- ---------------------------------------------------------------------------
-- Signature, certificates
-- ---------------------------------------------------------------------------

-- [signature-block]: 19.6 bp above, two columns 14 bp apart: the date on the left; "Respectfully submitted,", 16.8 bp,
-- "/s/ Signer" in italics, the signer in capitals and the further lines in italics on the right; never split.
local function signature(meta)
  local sig = need(meta, 'signature')
  local right = {'\\emph{/s/ ' .. tex(sig.signer) .. '}', tex(plain(sig.signer):upper())}
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = '\\emph{' .. tex(l) .. '}' end
  local left = meta.date ~= nil and ('Dated: ' .. tex(meta.date)) or ''
  return '\\par\\nobreak\\addvspace{19.6bp}\\begingroup\\singlespacing\\interlinepenalty=10000\\relax' ..
    '\\cacols{14bp}{' .. left .. '\\par}{Respectfully submitted,\\par\\vskip16.8bp ' ..
    table.concat(right, '\\newline ') .. '\\par}\\endgroup'
end

-- [form-sig-line]: 22.4 bp above; "Dated: date" | "/s/ Signer" over the signer in capitals.
local function form_sig_line(meta)
  local sig = need(meta, 'signature')
  return '\\par\\addvspace{22.4bp}\\begingroup\\singlespacing\\interlinepenalty=10000\\relax' ..
    '\\cacols{14bp}{Dated: ' .. tex(need(meta, 'date')) .. '\\par}{\\emph{/s/ ' .. tex(sig.signer) .. '}\\newline ' ..
    tex(plain(sig.signer):upper()) .. '\\par}\\endgroup'
end

-- ---------------------------------------------------------------------------
-- Table of authorities (FRAP 28(a)(3)) [toa-section]
-- ---------------------------------------------------------------------------

local ORDER = {'case', 'constitution', 'statute', 'regulation', 'rule', 'other'}
local TITLES = {
  case = 'Cases', constitution = 'Constitutional Provisions', statute = 'Statutes',
  regulation = 'Regulations', rule = 'Rules', other = 'Other Authorities',
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
  for _, kind in ipairs(ORDER) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == kind and hits[key] ~= nil then members[#members + 1] = {key = key, a = a} end
    end
    table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
    if #members > 0 then
      out[#out + 1] = '\\toagroup{' .. TITLES[kind] .. '}'
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

-- [ca8-answering-brief]: the brief's last paragraph travels with the signature unless the markdown's last block
-- (after the last blank line) is a heading or a footnote definition. The rule reads the source as typst does.
local function keeps_tail()
  local f = PANDOC_STATE.input_files[1]
  local h = f and io.open(f, 'r')
  if not h then return true end
  local src = h:read('a')
  h:close()
  src = src:gsub('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n', '', 1):gsub('%s+$', '')
  local tail = src
  local pos = 1
  while true do
    local s, e = src:find('\n[ \t]*\n', pos)
    if not s then break end
    tail = src:sub(e + 1)
    pos = e
  end
  return #tail > 0 and tail:sub(1, 1) ~= '#' and tail:sub(1, 2) ~= '[^'
end

-- ---------------------------------------------------------------------------
-- The filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({'case_number', 'caption', 'proceeding', 'brief_title', 'counsel', 'signature', 'virus_check'}) do
    need(meta, k)
  end

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
  if words > CONFIG.word_limit then
    fail('the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(i) allows ' .. CONFIG.word_limit)
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

  -- pass 2: headings. Level 1 is an unnumbered section; levels 2 to 5 number as in typst.
  local counters = {0, 0, 0, 0, 0, 0}
  local in_arg = false
  local heads = {}
  doc = doc:walk({
    Header = function(h)
      local text = plain(h.content)
      if h.level == 1 and text:lower():match('^%s*addendum%s*$') then
        fail('the LaTeX engine does not yet render an addendum (FRAP 28(f))')
      end
      if h.level == 1 then
        in_arg = text:lower():match('^%s*argument%s*$') ~= nil
        counters = {0, 0, 0, 0, 0, 0}
      end
      counters[h.level] = counters[h.level] + 1
      for i = h.level + 1, 6 do counters[i] = 0 end
      local label = h.level == 1 and '' or label_for(h.level, counters[h.level], in_arg)
      local title = tex(h.content)
      local idx = #heads + 1
      heads[idx] = {level = h.level, label = label, title = title, steps = steps_for(h.level, in_arg),
        centered = in_arg and h.level == 2}
      if heads[idx].centered then
        return raw(string.format('\\cacenter{%s}{%s}{h%d}', label, title, idx))
      end
      return raw(string.format('\\cahead{%d}{%d}{%s}{%s}{h%d}{%d}', h.level, h.level == 1 and 0 or heads[idx].steps,
        label, title, idx, CONFIG.italic_from))
    end,
  })

  -- front matter: the cover, then (lower roman from i) the summary, the disclosure, the contents, the authorities;
  -- each starts a new page (typst pagebreak(weak: true))
  local front = pandoc.Blocks({})
  front:insert(raw('\\singlespacing'))
  front:insert(raw(cover(meta)))
  front:insert(raw('\\clearpage\\pagenumbering{roman}\\normalsize\\cahead{1}{0}{}{' .. CONFIG.summary_title .. '}{sum}{99}'))
  front:extend(meta_blocks(need(meta, 'summary')))
  if meta.disclosure ~= nil then
    front:insert(raw('\\clearpage\\cahead{1}{0}{}{Corporate Disclosure Statement}{disc}{99}'))
    front:extend(meta_blocks(meta.disclosure))
  end
  front:insert(raw('\\clearpage\\singlespacing\\cahead{1}{0}{}{Table of Contents}{toc}{99}'))

  -- table of contents [toc-section]: every outlined heading up to toc_depth, front matter and certificates included
  local function tocline(level, steps, label, title, key)
    return string.format('\\tocline{%d}{%d}{%s}{%s}{%s}', level, steps, label, title, key)
  end
  local toc = {tocline(1, 0, '', CONFIG.summary_title, 'sum')}
  if meta.disclosure ~= nil then toc[#toc + 1] = tocline(1, 0, '', 'Corporate Disclosure Statement', 'disc') end
  toc[#toc + 1] = tocline(1, 0, '', 'Table of Contents', 'toc')
  toc[#toc + 1] = tocline(1, 0, '', 'Table of Authorities', 'toa')
  for i, h in ipairs(heads) do
    if h.level <= CONFIG.toc_depth then
      toc[#toc + 1] = tocline(h.level, h.centered and 0 or (h.level == 1 and 0 or h.steps), h.label, h.title, 'h' .. i)
    end
  end
  toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Compliance', 'cc')
  toc[#toc + 1] = tocline(1, 0, '', 'Certificate of Service', 'cs')
  front:insert(raw(table.concat(toc, '\n')))
  front:insert(raw('\\clearpage\n' .. table.concat(toa(meta, hits), '\n')))
  front:insert(raw('\\clearpage\\pagenumbering{arabic}\\normalsize'))

  -- back matter: the certificates, each on a new page [certificate-of-compliance, certificate-of-service]
  local back = pandoc.Blocks({})
  back:insert(raw('\\clearpage\\cahead{1}{0}{}{Certificate of Compliance}{cc}{99}'))
  back:insert(raw('This brief complies with the type-volume limitations imposed by Federal Rule of Appellate ' ..
    'Procedure 32(a)(7)(B)(i) because it contains ' .. group_digits(words) .. ' words, excluding the parts of the ' ..
    'brief exempted by Rule 32(f). This brief complies with the typeface and typestyle requirements of Federal ' ..
    'Rules of Appellate Procedure 32(a)(5) and 32(a)(6) because it has been prepared in a proportionally spaced ' ..
    'typeface, ' .. CONFIG.typeface .. '. This brief complies with the electronic-filing requirements of Local ' ..
    'Rule 28A(h)(2) because it was ' .. tex(need(meta, 'virus_check')) .. '.\\par'))
  back:insert(raw(form_sig_line(meta)))
  back:insert(raw('\\clearpage\\cahead{1}{0}{}{Certificate of Service}{cs}{99}'))
  back:insert(raw('I hereby certify that on ' .. tex(need(meta, 'date')) .. ', the foregoing brief was filed with ' ..
    'the Clerk of Court for the U.S. Court of Appeals for the Eighth Circuit through the CM/ECF system, which will ' ..
    'send a notification of such filing to all counsel of record.\\par'))
  back:insert(raw(form_sig_line(meta)))

  -- The signature never stands alone: the brief's last paragraph is not broken across pages and stays with the
  -- signature block (typst: one unbreakable block), unless the markdown ends with a heading or footnote definition.
  local n = #doc.blocks
  local sig = signature(meta)
  if n > 0 and doc.blocks[n].t ~= 'RawBlock' and keeps_tail() then
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
