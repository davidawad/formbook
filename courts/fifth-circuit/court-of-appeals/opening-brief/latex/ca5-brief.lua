-- ca5-brief.lua: pandoc filter for the Fifth Circuit briefs, LaTeX engine.
-- Turns the markdown contract (frontmatter + "# " sections) into the court's form: cover, front
-- statements, table of contents, table of authorities, body, closing signature and certificates.
-- The typst template (typst/ca5-*.typ) is the reference for what each block looks like; the
-- numbers (14 pt, 30.8 pt double pitch, 1 in margins, 7 = passim) live in template.tex and here.
-- No case-specific text is in this file; everything comes from the sample's frontmatter.

local function raw(s) return pandoc.RawBlock('latex', s) end
local function rawi(s) return pandoc.RawInline('latex', s) end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end
local function norm(s) return trim(s):lower() end

local function inl_tex(inlines)
  return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), 'latex'))
end

-- Metadata value -> LaTeX. Frontmatter strings are markdown (italics, dashes), so they go through pandoc.
local function texm(v)
  if v == nil then return '' end
  if type(v) == 'string' then return inl_tex({ pandoc.Str(v) }) end
  if v.t == 'MetaBlocks' then return trim(pandoc.write(pandoc.Pandoc(v), 'latex')) end
  if v.t == 'MetaInlines' then return inl_tex(v) end
  return inl_tex({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function plain(v)
  if v == nil then return '' end
  return pandoc.utils.stringify(v)
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

local function prefixed(prefix, inlines)
  local out = { rawi(prefix) }
  for _, x in ipairs(inlines) do out[#out + 1] = x end
  out[#out + 1] = rawi('}')
  return pandoc.Plain(out)
end

-- Signer block (CA5-CONT-006): "/s/ Name", the name, the firm and contact lines, at 3 in.
local function signer_tex(sig)
  local out = { '\\par\\begingroup\\sglspace\\noindent\\hspace*{3in}\\begin{minipage}[t]{3.2in}\\raggedright',
    '/s/ ' .. texm(sig.signer) .. '\\\\[0.5em]', texm(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = '\\\\' .. texm(l) end
  out[#out + 1] = '\\end{minipage}\\par\\endgroup\\vspace{0.4em}'
  return table.concat(out, '\n')
end

-- Cover (CA5-CONT-003): each piece is one line; `gap` is the space after it (nil: a plain line break).
local function cover_tex(meta)
  local pieces = {}
  local function piece(text, gap) pieces[#pieces + 1] = { text = text, gap = gap } end
  piece('No.\\ ' .. texm(meta.case_number), '0.25in')
  piece('In the United States Court of Appeals for the Fifth Circuit', '0.25in')
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names or {}) do piece(texm(n), '0.1em') end
    piece(texm(side.designation), i < #sides and '0.2em' or nil)
    if i < #sides then piece('v.', '0.6em') end
  end
  piece(texm(meta.proceeding), '0.25in')
  local head = { '\\thispagestyle{empty}\\begin{center}\\sglspace' }
  for _, p in ipairs(pieces) do
    local br = p.gap and ('\\\\[' .. p.gap .. ']') or '\\\\'
    head[#head + 1] = p.text .. br
  end
  head[#head + 1] = '\\textbf{' .. texm(meta.brief_title) .. '}'
  head[#head + 1] = '\\end{center}\\par\\vfill\\begin{center}\\sglspace'
  local tail = {}
  for _, g in ipairs(meta.counsel or {}) do
    local lines = {}
    for _, n in ipairs(g.names or {}) do lines[#lines + 1] = texm(n) end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = texm(l) end
    if #lines > 0 then tail[#tail + 1] = table.concat(lines, '\\\\') .. '\\\\[0.5em]' end
  end
  if meta.date then tail[#tail + 1] = texm(meta.date) end
  return table.concat(head, '\n') .. '\n' .. table.concat(tail, '\n') .. '\n\\end{center}'
end

local function front_heading_tex(title)
  return '\\brfront{' .. title .. '}'
end

local FRONT = { ['certificate of interested persons'] = true, ['statement regarding oral argument'] = true }

local function is_cert(title)
  local t = norm(title)
  return t:sub(1, 14) == 'certificate of' and not FRONT[t]
end

local function md_blocks(s)
  return pandoc.read(s, 'markdown').blocks
end

-- Walk the sections' blocks: turn each level-2..5 heading into its styled macro and its TOC entry.
local function convert_body(blocks, in_arg, cnt, out)
  for _, b in ipairs(blocks) do
    if b.t == 'Header' then
      local L = b.level
      if L == 1 then error('ca5-brief: a level-1 heading inside a section') end
      cnt[L] = cnt[L] + 1
      for k = L + 1, 5 do cnt[k] = 0 end
      local lab = label(L, in_arg, cnt[L])
      if L == 2 and in_arg then
        out[#out + 1] = prefixed('\\brargtwo{' .. lab .. '}{', b.content)
      else
        local first = in_arg and 3 or 2
        local ind = string.format('%.1fin', (L - first + 1) * 0.5)
        local macro = (L <= 3) and '\\brsub' or '\\brsubi'
        out[#out + 1] = prefixed(macro .. '{' .. ind .. '}{' .. lab .. '}{', b.content)
      end
    else
      out[#out + 1] = b
    end
  end
  return out
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

local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    for _ in pandoc.utils.stringify(b):gmatch('%S+') do n = n + 1 end
  end
  return n
end

local GROUPS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}

function Pandoc(doc)
  local meta = doc.meta

  -- authorities registry (frontmatter), by key
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    auth[key] = {
      kind = plain(a.kind),
      name = plain(a.name),
      name_tex = texm(a.name),
      cite_tex = texm(a.cite),
    }
  end

  local secs = split_sections(doc.blocks)
  local front, main, certs = {}, {}, {}
  for _, s in ipairs(secs) do
    if s.title == nil then
      main[#main + 1] = s
    elseif FRONT[norm(s.title)] then
      front[#front + 1] = s
    elseif is_cert(s.title) then
      certs[#certs + 1] = s
    else
      main[#main + 1] = s
    end
  end

  -- CA5-CONT-007 / FRAP 32(f): the word count of the body (main sections), not the front, TOC, TOA or certificates.
  local main_blocks = {}
  for _, s in ipairs(main) do
    for _, b in ipairs(s.blocks) do main_blocks[#main_blocks + 1] = b end
  end
  local words = commas(count_words(main_blocks))

  -- citations: [text](toa:key) -> \toacite{key}{text}; collect keys in order of first use
  local hits, hit_order = {}, {}
  local function link_filter(l)
    if l.target:sub(1, 4) ~= 'toa:' then return nil end
    local key = l.target:sub(5)
    if not auth[key] then
      error('ca5-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
    end
    if not hits[key] then hits[key] = true; hit_order[#hit_order + 1] = key end
    local out = { rawi('\\toacite{' .. key .. '}{') }
    for _, x in ipairs(l.content) do out[#out + 1] = x end
    out[#out + 1] = rawi('}')
    return out
  end
  local function linked(blocks)
    return pandoc.Pandoc(blocks):walk({ Link = link_filter }).blocks
  end

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- ---- cover (page 1, unnumbered) ----
  add(raw(cover_tex(meta)))
  add(raw('\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}'))

  -- ---- front statements (before the TOC) ----
  if meta.interested_persons then
    add(raw(front_heading_tex('Certificate of Interested Persons')))
    add(pandoc.Para(meta.interested_persons))
    add(raw(signer_tex(meta.signature)))
    add(raw('\\clearpage'))
  end
  if meta.oral_argument then
    add(raw(front_heading_tex('Statement Regarding Oral Argument')))
    add(pandoc.Para(meta.oral_argument))
    add(raw('\\clearpage'))
  end
  for _, s in ipairs(front) do
    add(prefixed('\\brfront{', s.inl))
    for _, b in ipairs(linked(s.blocks)) do add(b) end
    if norm(s.title) == 'certificate of interested persons' then add(raw(signer_tex(meta.signature))) end
    add(raw('\\clearpage'))
  end

  -- ---- table of contents and table of authorities (built from the headings and citations of the body) ----
  -- (the entries are read from the aux/toc files of the previous run; tectonic reruns to settle them)
  local toa = { '\\clearpage\\begingroup\\sglspace\\begin{center}\\bfseries TABLE OF AUTHORITIES\\end{center}\\endgroup\\vspace{0.4in}' }
  -- hits are only known after the body is walked, so the body is converted first into a buffer
  local body = {}
  local cnt = { 0, 0, 0, 0, 0 }
  for _, s in ipairs(main) do
    cnt = { 0, 0, 0, 0, 0 }
    local in_arg = s.title ~= nil and norm(s.title) == 'argument'
    if s.title then
      body[#body + 1] = prefixed('\\brone{', s.inl)
    end
    convert_body(linked(s.blocks), in_arg, cnt, body)
  end

  local group_done = false
  for _, g in ipairs(GROUPS) do
    local members = {}
    for _, key in ipairs(hit_order) do
      if auth[key].kind == g[1] then members[#members + 1] = key end
    end
    table.sort(members, function(x, y)
      local a = norm(auth[x].name ~= '' and auth[x].name or auth[x].cite_tex)
      local b = norm(auth[y].name ~= '' and auth[y].name or auth[y].cite_tex)
      return a < b
    end)
    if #members > 0 then
      toa[#toa + 1] = string.format('\\brtoagroup{%s}{%s}{%s}', g[2], group_done and '1.4em' or '1em',
        group_done and '' or 'Page(s)')
      group_done = true
      for _, key in ipairs(members) do
        local a = auth[key]
        local text = a.cite_tex
        if a.name ~= '' then
          local nm = a.kind == 'case' and ('\\emph{' .. a.name_tex .. '}') or a.name_tex
          text = nm .. ', ' .. text
        end
        toa[#toa + 1] = '\\brtoaentry{' .. text .. '}{' .. key .. '}'
      end
    end
  end

  add(raw('\\clearpage\\brtoc'))
  add(raw(table.concat(toa, '\n')))

  -- ---- body (arabic from 1) ----
  add(raw('\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}'))
  for _, b in ipairs(body) do add(b) end
  local closing = {}
  if meta.date then closing[#closing + 1] = 'Dated: ' .. texm(meta.date) .. '\\par\\vspace{0.4em}' end
  closing[#closing + 1] = '\\noindent\\hspace*{3in}Respectfully submitted,\\par\\vspace{0.6em}'
  add(raw('\\par\\vspace{0.4in}\\begingroup\\sglspace\\noindent\n' .. table.concat(closing, '\n')
    .. '\n' .. signer_tex(meta.signature) .. '\\endgroup'))

  -- ---- certificates: each on its own page, after the body ----
  local have = {}
  for _, c in ipairs(certs) do
    local t = norm(c.title)
    have[t] = true
    add(raw('\\clearpage'))
    add(prefixed('\\brone{', c.inl))
    local blocks = pandoc.Pandoc(c.blocks):walk({
      Str = function(el)
        if el.text:find('{{words}}', 1, true) then
          return pandoc.Str((el.text:gsub('{{words}}', words)))
        end
      end,
    }).blocks
    for _, b in ipairs(linked(blocks)) do add(b) end
    add(raw(signer_tex(meta.signature)))
  end
  -- certificates the frontmatter asks for (the answering-brief layout): service, then compliance
  local service = meta.service
  if service and service.certificate and not have['certificate of service'] then
    add(raw('\\clearpage'))
    add(raw('\\brone{Certificate of Service}'))
    add(pandoc.Para(md_blocks('I certify that on ' .. plain(meta.date) .. ', the foregoing document was electronically filed with the Clerk of the Court for the United States Court of Appeals for the Fifth Circuit using the electronic case filing system of the Court. I further certify that I have complied with the privacy and redaction requirements of Fed. R. App. P. 25(a)(5).')[1].content))
    if service.recipients then add(pandoc.Para(service.recipients)) end
    add(raw(signer_tex(meta.signature)))
  end
  if not have['certificate of compliance'] then
    add(raw('\\clearpage'))
    add(raw('\\brone{Certificate of Compliance}'))
    add(pandoc.Para(md_blocks('1\\. This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because: this brief contains ' .. words .. ' words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f).')[1].content))
    add(pandoc.Para(md_blocks('2\\. This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because: this brief has been prepared in a proportionally spaced typeface using ' .. plain(meta.prepared_with) .. '.')[1].content))
    add(raw(signer_tex(meta.signature)))
  end

  return pandoc.Pandoc(out, meta)
end
