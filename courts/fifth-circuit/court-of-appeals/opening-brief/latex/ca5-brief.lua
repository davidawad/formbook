-- ca5-brief.lua: pandoc filter for the Fifth Circuit briefs, LaTeX engine.
-- Turns the markdown contract (frontmatter + "# " sections) into the court's form: cover, front
-- statements, table of contents, table of authorities, body, closing signature and certificates.
-- The typst template (typst/ca5-*.typ) is the reference for what each block looks like and where every line and page
-- breaks (cross-engine layout model, docs/EVAL-LOOP.md); the macros and numbers are in template.tex.
-- No case-specific text is in this file; everything comes from the sample's frontmatter.

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_inlines = require('latex.xengine').inlines

local function raw(s) return pandoc.RawBlock('latex', s) end
local function rawi(s) return pandoc.RawInline('latex', s) end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end
local function norm(s) return trim(s):lower() end

local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

-- Inlines -> LaTeX, with the cross-engine inline rules.
local function inl_tex(inlines)
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(xe_inlines(pandoc.Inlines(inlines))) }), 'latex')
  return trim(s)
end

-- Metadata value -> LaTeX. Frontmatter strings are markdown (italics, dashes), so they go through pandoc.
local function texm(v)
  if v == nil then return '' end
  if type(v) == 'string' then return inl_tex({ pandoc.Str(v) }) end
  if v.t == 'MetaBlocks' then return inl_tex(pandoc.utils.blocks_to_inlines(v)) end
  if v.t == 'MetaInlines' or v.t == nil then return inl_tex(v) end
  return inl_tex({ pandoc.Str(plain(v)) })
end

local function roman(n)
  local vals = { { 10, 'x' }, { 9, 'ix' }, { 5, 'v' }, { 4, 'iv' }, { 1, 'i' } }
  local s = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return (s:upper())
end

local function letter(n, upper)
  return string.char((upper and 64 or 96) + n)
end

-- Printed label of a numbered heading (CA5-CONT-010). Argument: I. A. 1. a.  Elsewhere: A. 1. a. (1)
local function label(level, in_arg, n)
  if in_arg then
    if level == 2 then return roman(n) .. '.' end
    if level == 3 then return letter(n, true) .. '.' end
    if level == 4 then return tostring(n) .. '.' end
    if level == 5 then return letter(n, false) .. '.' end
  else
    if level == 2 then return letter(n, true) .. '.' end
    if level == 3 then return tostring(n) .. '.' end
    if level == 4 then return letter(n, false) .. '.' end
    if level == 5 then return '(' .. n .. ')' end
  end
  error('ca5-brief: headings deeper than level 5 are not supported')
end

local function commas(n)
  local s = tostring(n)
  local k
  repeat
    s, k = s:gsub('^(%d+)(%d%d%d)', '%1,%2')
  until k == 0
  return s
end

local FRONT = { ['certificate of interested persons'] = true, ['statement regarding oral argument'] = true }

local function is_cert(title)
  local t = norm(title)
  return t:sub(1, 14) == 'certificate of' and not FRONT[t]
end

-- ---------------------------------------------------------------------------
-- Words (CA5-CONT-007; FRAP 32(f)): the typst template's count-words, on the markdown source of the main sections
-- (not the front statements, the tables or the certificates): markup removed, links keep their text, then
-- whitespace-delimited words.
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error('ca5-brief: no input file to count words in', 0) end
  local h = assert(io.open(f, 'r'))
  local src = h:read('a')
  h:close()
  local body = src:gsub('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n', '', 1)
  -- the sections, split at each "# " line, as the typst template's split-sections
  local main = {}
  local parts = {}
  local s = '\n' .. body
  local pos = 1
  while true do
    local a = s:find('\n# ', pos, true)
    if not a then break end
    local b = s:find('\n# ', a + 1, true)
    parts[#parts + 1] = s:sub(a + 3, (b or (#s + 1)) - 1)
    if not b then break end
    pos = b
  end
  for _, p in ipairs(parts) do
    local title = trim(p:match('^[^\n]*'))
    if not FRONT[title:lower()] and not is_cert(title) then main[#main + 1] = '# ' .. p end
  end
  local t = table.concat(main, '\n')
  t = t:gsub('<!%-%-.-%-%->', ' ')
  t = '\n' .. t
  t = t:gsub('\n%[%^[^%]]+%]:', '\n ')                 -- footnote definition labels
  t = t:gsub('%[%^[^%]]+%]', '')                        -- footnote references
  t = t:gsub('%[([^%]]*)%]%([^%)]*%)', '%1')            -- links keep their text
  t = t:gsub('\n#+[ \t]+', '\n')
  t = t:gsub('\n>[ \t]?', '\n')
  t = t:gsub('\n[ \t]*[-*+][ \t]+', '\n')               -- list markers are not words
  t = t:gsub('\n[ \t]*%d+[.)][ \t]+', '\n')
  t = t:gsub('\\(.)', '%1')                              -- backslash escapes
  t = t:gsub('%*', '')
  t = t:gsub('([%s%(%[\"])_', '%1'):gsub('\u{201C}_', '\u{201C}')
  t = t:gsub('_([%s%.,;:%)%]\"!%?])', '%1'):gsub('_\u{201D}', '\u{201D}'):gsub('_$', '')
  local n = 0
  for _ in t:gmatch('%S+') do n = n + 1 end
  return n
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

-- typst indents a paragraph's first line only after another paragraph: every other paragraph starts \noindent.
local function indent_rule(blocks)
  local out, prev = {}, nil
  for _, b in ipairs(blocks) do
    if b.t == 'Para' and (prev == nil or prev.t ~= 'Para') then
      local c = pandoc.Inlines({ rawi('\\noindent ') })
      c:extend(b.content)
      out[#out + 1] = pandoc.Para(c)
    else
      out[#out + 1] = b
    end
    prev = b
  end
  return out
end

-- The signer block (CA5-CONT-006) [signer-block], `above` bp below what precedes it.
local function signer_tex(sig, above)
  local lines = {}
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = '\\casigline{' .. texm(l) .. '}' end
  return '\\casigner{' .. above .. '}{' .. texm(sig.signer) .. '}{' .. table.concat(lines) .. '}'
end

-- The cover (CA5-CONT-003) [cover]: single-spaced centered lines; the counsel at the foot of the page.
local function cover_tex(meta)
  local L = { '\\thispagestyle{empty}' }
  local function line(gap, t) L[#L + 1] = '\\caline{' .. gap .. '}{' .. t .. '}' end
  line(0, 'No. ' .. texm(meta.case_number))
  line(18, 'In the United States Court of Appeals for the Fifth Circuit')
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for j, n in ipairs(side.names or {}) do line(j == 1 and (i == 1 and 18 or 8.4) or 0, texm(n)) end
    line(2.8, texm(side.designation))
    if i < #sides then line(8.4, 'v.') end
  end
  line(15.6, texm(meta.proceeding))
  line(18, '\\textbf{' .. texm(meta.brief_title) .. '}')
  L[#L + 1] = '\\par\\vfill'
  for gi, g in ipairs(meta.counsel or {}) do
    for j, n in ipairs(g.names or {}) do line((j == 1 and gi > 1) and 7 or 0, texm(n)) end
    for _, l in ipairs(g.lines or {}) do line(0, texm(l)) end
  end
  if meta.date then line(14, texm(meta.date)) end
  return table.concat(L, '\n')
end

local function split_sections(blocks)
  local secs = {}
  local cur = { title = nil, inl = nil, blocks = {} }
  for _, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 then
      if cur.title or #cur.blocks > 0 then secs[#secs + 1] = cur end
      cur = { title = pandoc.utils.stringify(b.content), inl = b.content, blocks = {} }
    else
      cur.blocks[#cur.blocks + 1] = b
    end
  end
  if cur.title or #cur.blocks > 0 then secs[#secs + 1] = cur end
  return secs
end

local GROUPS = {
  { { 'case' }, 'Cases' },
  { { 'constitution', 'statute', 'regulation', 'rule', 'other' }, 'Statutes & Other Authorities' },
}

function Pandoc(doc)
  local meta = doc.meta

  -- authorities registry (frontmatter), by key
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    auth[key] = { kind = plain(a.kind), name = plain(a.name), name_tex = texm(a.name), cite = plain(a.cite),
      cite_tex = texm(a.cite) }
  end

  -- citations: [text](toa:key) -> \toahit{key} and the text; every other link keeps its text
  local hits = {}
  doc = doc:walk({
    Link = function(l)
      if l.target:sub(1, 4) ~= 'toa:' then return l.content end
      local key = l.target:sub(5)
      if not auth[key] then
        error('ca5-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
      end
      hits[key] = true
      local out = pandoc.Inlines({ rawi('\\toahit{' .. key .. '}') })
      out:extend(l.content)
      return out
    end,
  })
  doc = doc:walk({ Inlines = xe_inlines })

  local secs = split_sections(doc.blocks)
  local front, main, certs = {}, {}, {}
  for _, s in ipairs(secs) do
    if s.title ~= nil and FRONT[norm(s.title)] then
      front[#front + 1] = s
    elseif s.title ~= nil and is_cert(s.title) then
      certs[#certs + 1] = s
    else
      main[#main + 1] = s
    end
  end

  -- CA5-CONT-007 / FRAP 32(f): the word count of the body (main sections), as typst counts it.
  local words = commas(source_words())

  local out = {}
  local function add(x) out[#out + 1] = x end
  local idx = 0
  local toc = {}
  local function heading_one(inl, listed)
    idx = idx + 1
    if listed then toc[#toc + 1] = { level = 1, label = '', title = inl_tex(inl), idx = idx } end
    return raw('\\caone{' .. inl_tex(inl) .. '}{' .. idx .. '}')
  end

  -- ---- cover (page 1, unnumbered) ----
  add(raw(cover_tex(meta)))
  add(raw('\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}'))

  -- ---- front statements (before the TOC) ----
  for _, s in ipairs(front) do
    add(heading_one(s.inl, false))
    if norm(s.title) == 'certificate of interested persons' then
      -- single spaced, half a line between paragraphs
      add(raw('\\begingroup\\singlespacing'))
      for _, b in ipairs(indent_rule(s.blocks)) do add(raw('\\par\\addvspace{7bp}')); add(b) end
      add(raw(signer_tex(meta.signature, 14) .. '\\endgroup'))
    else
      for _, b in ipairs(indent_rule(s.blocks)) do add(b) end
    end
    add(raw('\\clearpage'))
  end

  -- ---- the body, converted first: the TOC lists its headings ----
  local body = {}
  for _, s in ipairs(main) do
    local in_arg = s.title ~= nil and norm(s.title) == 'argument'
    local cnt = { 0, 0, 0, 0, 0 }
    if s.title then body[#body + 1] = heading_one(s.inl, true) end
    for _, b in ipairs(indent_rule(s.blocks)) do
      if b.t == 'Header' then
        local L = b.level
        if L == 1 then error('ca5-brief: a level-1 heading inside a section') end
        cnt[L] = cnt[L] + 1
        for k = L + 1, 5 do cnt[k] = 0 end
        local lab = label(L, in_arg, cnt[L])
        idx = idx + 1
        local title = inl_tex(b.content)
        toc[#toc + 1] = { level = L, label = lab, title = title, idx = idx }
        body[#body + 1] = raw(string.format('\\casub{%d}{%s}{%s}{%d}{%d}', L, lab, title, L <= 3 and 1 or 0, idx))
      else
        body[#body + 1] = b
      end
    end
  end
  -- the certificates are listed too
  local cert_heads = {}
  for _, c in ipairs(certs) do cert_heads[#cert_heads + 1] = heading_one(c.inl, true) end

  -- ---- table of contents ----
  add(raw('\\catabletitle{Table of Contents}'))
  for _, e in ipairs(toc) do
    add(raw(string.format('\\catoc{%d}{%s}{%s}{%d}', e.level, e.label, e.title, e.idx)))
  end

  -- ---- table of authorities ----
  add(raw('\\clearpage\\catabletitle{Table of Authorities}'))
  for _, g in ipairs(GROUPS) do
    local kinds = {}
    for _, k in ipairs(g[1]) do kinds[k] = true end
    local members = {}
    for key, a in pairs(auth) do
      if kinds[a.kind] and hits[key] then members[#members + 1] = key end
    end
    -- cases by name, the others by citation (typst: lower(name), lower(cite))
    table.sort(members, function(x, y)
      local a = g[1][1] == 'case' and auth[x].name or auth[x].cite
      local b = g[1][1] == 'case' and auth[y].name or auth[y].cite
      return a:lower() < b:lower()
    end)
    if #members > 0 then
      add(raw('\\toagroup{' .. inl_tex({ pandoc.Str(g[2]) }) .. '}'))
      for _, key in ipairs(members) do
        local a = auth[key]
        local text = a.cite_tex
        if a.name ~= '' then text = '\\emph{' .. a.name_tex .. '}, ' .. text end
        add(raw('\\toaitem{' .. text .. '}{' .. key .. '}'))
      end
    end
  end

  -- ---- body (arabic from 1) ----
  add(raw('\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}'))
  -- The closing signature never stands alone on a page: the brief's last paragraph is kept with it (typst: one
  -- unbreakable block, the paragraph set as a block of its own, so its first line is not indented).
  local last = #body
  while last > 0 and body[last].t ~= 'Para' and body[last].t ~= 'RawBlock' do last = last - 1 end
  local keep = last > 0 and body[last].t == 'Para'
  for i, b in ipairs(body) do
    if keep and i == last then
      add(raw('\\par\\begingroup\\interlinepenalty=10000\\relax'))
      local c = pandoc.Inlines({ rawi('\\noindent ') })
      for _, x in ipairs(b.content) do
        if not (x.t == 'RawInline' and x.text == '\\noindent ') then c:insert(x) end
      end
      add(pandoc.Para(c))
      add(raw('\\par\\nobreak'))
    else
      add(b)
    end
  end
  local closing = { '\\par\\addvspace{28.8bp}\\begingroup\\singlespacing\\interlinepenalty=10000\\relax' }
  if meta.date then closing[#closing + 1] = '\\noindent Dated: ' .. texm(meta.date) .. '\\par\\nobreak\\addvspace{5.6bp}' end
  closing[#closing + 1] = '\\noindent\\hspace*{3in}Respectfully submitted,\\par\\nobreak'
  closing[#closing + 1] = signer_tex(meta.signature, 8.4) .. '\\endgroup'
  if keep then closing[#closing + 1] = '\\endgroup' end
  add(raw(table.concat(closing, '\n')))

  -- ---- certificates: each on its own page, flush left, after the body ----
  for i, c in ipairs(certs) do
    add(raw('\\clearpage'))
    add(cert_heads[i])
    local blocks = pandoc.Pandoc(c.blocks):walk({
      Str = function(el)
        if el.text:find('{{words}}', 1, true) then
          return pandoc.Str((el.text:gsub('{{words}}', words)))
        end
      end,
    }).blocks
    for _, b in ipairs(blocks) do
      if b.t == 'Para' then
        local cc = pandoc.Inlines({ rawi('\\noindent ') })
        cc:extend(b.content)
        add(pandoc.Para(cc))
      else
        add(b)
      end
    end
    add(raw(signer_tex(meta.signature, 14)))
  end

  return pandoc.Pandoc(out, meta)
end
