-- U.S. Court of Appeals for the Sixth Circuit: reply brief, Word (docx) engine.
-- A pandoc filter. It writes the brief from the sample's frontmatter and body on reference.docx (make-reference.sh:
-- the shared style recipe of lib/docx/xengine-reference.sh), with the same rules and numbers as
-- ../typst/ca6-reply-brief.typ. Page numbers (TOC, TOA) are plain text. docx/render.sh gets them from the rendered
-- PDF (docx/pages.lua) and builds again with them until they stop changing. Environment: CA6_DOCX_PAGES=<pagemap
-- file> supplies the numbers (absent: placeholders); CA6_DOCX_LIST=<file> writes the list of headings and citations
-- to match. Rules: ../README.md.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"; lib/docx/xengine.lua): every paragraph written here
-- carries the typst template's line box (exact line spacing: 31.4 pt body, 20 pt single) and spaces (twips = 20 x
-- pt), its text as runs with typst's break rules; the text pandoc writes itself gets the same rules.

local xe = require('docx.xengine')

local TOC_DEPTH = 2                     -- typst: toc-depth
local PASSIM = 7                        -- typst: passim-threshold
local WORD_LIMIT = 6500                 -- CA6-LEN-001: FRAP 32(a)(7)(B)(ii)
local FACE = 'Times New Roman'          -- the typeface the template sets (typst font-family)

-- typst's numbers, in twips
local SINGLE = 400                      -- pitch-single 20 pt
local TEXTW = 9360                      -- 6.5 in
local COUNSEL = 3744                    -- counsel-indent, 2.6 in
local COURT = 6336                      -- the court's name in a 4.4 in column, centered
local TOC_COL, TOA_COL = 720, 1120      -- the page columns of the tables, 36 pt and 56 pt

local PAGES = {}   -- tag -> printed page label: h<id> (heading), k<k> (citation k)
local pages_file = os.getenv('CA6_DOCX_PAGES')
if pages_file and pages_file ~= '' then
  local f = assert(io.open(pages_file, 'r'))
  for line in f:lines() do
    local tag, label = line:match('^(%S+)%s+(%S+)$')
    if tag then PAGES[tag] = label end
  end
  f:close()
end
local function page_of(tag) return PAGES[tag] or '0' end

local plain = pandoc.utils.stringify

-- Unicode line breaking (typst) never breaks before a closing or separating mark, even after a space (UAX #14 LB13:
-- ". . . ."); LibreOffice does: such a space is a no-break space here.
local NOBREAK_BEFORE = '^[.,:;!?)%]}/]'
local function bind_closers(il)
  local out = pandoc.Inlines({})
  for i, el in ipairs(il) do
    local nx = il[i + 1]
    if el.t == 'Space' and nx and nx.t == 'Str' and nx.text:match(NOBREAK_BEFORE) then
      out:insert(pandoc.Str('\u{00A0}'))
    else
      out:insert(el)
    end
  end
  return out
end
local function inlines(l) return bind_closers(xe.inlines(l)) end
-- No break inside a token of adjacent parentheses ("32(a)(7)"; typst boxes it, LibreOffice would break between ")"
-- and "("): a word joiner between them.
local function join_parens(s) return (s:gsub('%)%(', ')\u{2060}(')) end

-- p(o, runs): o = { keep, lines, brk, bdr, tabs, before, after, line, left, hanging, first, right, jc }
local function p(o, runs)
  local x = {}
  if o.keep then x[#x + 1] = '<w:keepNext/>' end
  if o.lines ~= false then x[#x + 1] = '<w:keepLines/>' end
  if o.brk then x[#x + 1] = xe.BREAK end
  if o.bdr then x[#x + 1] = o.bdr end
  if o.tabs then x[#x + 1] = o.tabs end
  x[#x + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and o.hanging == nil then first = 0 end
  x[#x + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  if o.jc then x[#x + 1] = xe.jc(o.jc) end
  return xe.para(x, runs or '')
end
local function P(o, runs) return xe.raw(p(o, runs)) end
local TAB = '<w:r><w:tab/></w:r>'
local NBH = '<w:r><w:noBreakHyphen/></w:r>'

local function upper(il)
  return pandoc.Inlines(il):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local function section_break(footer_rid, numfmt)
  local f = footer_rid and ('<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>') or ''
  local pg = numfmt and ('<w:pgNumType w:fmt="' .. numfmt .. '" w:start="1"/>') or ''
  return xe.raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>' .. f
    .. PG .. pg .. '</w:sectPr></w:pPr></w:p>')
end

local function roman(n)
  local s = ''
  for _, q in ipairs({ { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }) do
    while n >= q[1] do
      s = s .. q[2]
      n = n - q[1]
    end
  end
  return s
end
local function letter(n, up)
  if n > 26 then error('ca6-reply-brief: more than 26 sub-headings at one level') end
  return string.char((up and 64 or 96) + n)
end
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

local function group_digits(n)
  local s = tostring(n)
  local out = ''
  for i = 1, #s do
    if i > 1 and (#s - i + 1) % 3 == 0 then out = out .. ',' end
    out = out .. s:sub(i, i)
  end
  return out
end

local function source_body()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error('ca6-reply-brief: no input file to read', 0) end
  local h = assert(io.open(f, 'r'))
  local src = h:read('a')
  h:close()
  local fm = src:match('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n')
  if not fm then error('ca6-reply-brief: the sample must start with a YAML frontmatter block', 0) end
  return src:sub(#fm + 1)
end

-- typst count-words on the markdown source of the body, step by step, so that every engine certifies the same number.
local function source_words(body)
  local s = body:gsub('<!%-%-.-%-%->', ' ')
  local n = 0
  for line in (s .. '\n'):gmatch('(.-)\r?\n') do
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

-- typst keeps the last paragraph with the signature block unless the source ends on a heading or a footnote
-- definition.
local function keeps_last(body)
  local last = body:gsub('%s+$', ''):match('.*\n[ \t]*\n(.*)$') or body
  return last ~= '' and not last:match('^#') and not last:match('^%[%^')
end

local ADV = { [','] = 70, [' '] = 70, ['-'] = 93, i = 78, l = 78, v = 140, x = 140, c = 124, p = 140, a = 124,
  s = 109, m = 218 }
local function width_of(s)
  local w = 0
  for c in s:gmatch('.') do w = w + (c:match('%d') and 140 or ADV[c] or 140) end
  return w
end

local KINDS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}

local function authorities_of(meta)
  local out = {}
  for key, a in pairs(meta.authorities or {}) do
    local sortsrc = a.sort and plain(a.sort) or ((a.name and plain(a.name) or '') .. ' ' .. plain(a.cite))
    out[key] = { kind = plain(a.kind), cite = a.cite, name = a.name, sort = sortsrc:lower():gsub('[^a-z0-9 ]', '') }
  end
  return out
end

-- The cover [cover-body]: centered single-spaced lines; the court in a 4.4 in column; counsel at 2.6 in.
local function cover(m)
  local out = {}
  local GAP = 120
  local function c(runs, before) out[#out + 1] = P({ jc = 'center', before = before or 0 }, runs) end
  local function short_rule()
    out[#out + 1] = P({ bdr = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>',
      before = 0, after = GAP, line = 80, left = 3240, right = 3240 })
  end
  c(xe.runs('No. ') .. xe.inl(m.case_number))
  local side = (TEXTW - COURT) // 2
  out[#out + 1] = P({ jc = 'center', before = GAP, left = side, right = side },
    xe.runs('IN THE UNITED STATES COURT OF APPEALS FOR THE SIXTH CIRCUIT', { b = true }))
  short_rule()
  for i, s in ipairs(m.caption) do
    for _, n in ipairs(s.names) do c(xe.inl(n)) end
    c(xe.inl(s.designation))
    if i < #m.caption then c(xe.runs('v.'), 60) end
  end
  short_rule()
  c(xe.inl(m.proceeding), GAP)
  short_rule()
  c(xe.inl(upper(m.brief_title), { b = true }), GAP)
  short_rule()
  for gi, g in ipairs(m.counsel) do
    for ni, n in ipairs(g.names) do
      out[#out + 1] = P({ keep = true, left = COUNSEL, before = ni == 1 and GAP or 0 }, xe.inl(n))
    end
    for _, l in ipairs(g.lines or {}) do out[#out + 1] = P({ keep = true, left = COUNSEL }, xe.inl(l)) end
  end
  return out
end

-- The signature block [signature-block]: 19.6 pt above; "Respectfully submitted," at the margin; each signer 19.6 pt
-- below, at 2.6 in. Not split.
local function signature_blocks(m)
  local out = { P({ keep = true, before = 392 }, xe.runs('Respectfully submitted,')) }
  local sigs = m.signatures
  for si, sig in ipairs(sigs) do
    local lines = sig.lines or {}
    out[#out + 1] = P({ keep = si < #sigs or #lines > 0, before = 392, left = COUNSEL }, xe.runs('s/ ' .. plain(sig.signer)))
    for i, l in ipairs(lines) do
      out[#out + 1] = P({ keep = si < #sigs or i < #lines, left = COUNSEL }, xe.inl(l))
    end
  end
  return out
end

-- A certificate's signature [cert-signature]: 22.4 pt above, at 2.6 in.
local function cert_signature(m)
  local sig = m.signatures[1]
  return {
    P({ keep = true, before = 448, left = COUNSEL }, xe.runs('s/ ' .. plain(sig.signer))),
    P({ left = COUNSEL }, xe.runs(plain(sig.signer))),
  }
end

local NB = '\u{00A0}'
local FRAP = 'Fed.' .. NB .. 'R.' .. NB .. 'App.' .. NB .. 'P.' .. NB   -- typst: Fed.~R.~App.~P.~

function Pandoc(doc)
  doc = doc:walk({ Str = function(s) return pandoc.Str(join_parens(s.text)) end })   -- the body and the metadata
  local meta = doc.meta
  local auth = authorities_of(meta)

  local occ, occ_text = {}, {}
  local blocks = doc.blocks:walk({
    Link = function(l)
      if l.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = l.target:sub(5)
      if not auth[key] then
        error('ca6-reply-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
      end
      occ[#occ + 1] = key
      occ_text[#occ] = plain(l.content)
      return l.content
    end,
  })
  blocks = pandoc.Pandoc(blocks):walk({ Inlines = inlines }).blocks
  local flat = pandoc.Blocks({})
  for _, b in ipairs(blocks) do flat:extend(xe.list_items(b)) end
  blocks = flat

  local src = source_body()
  local words = source_words(src)
  if words > WORD_LIMIT then
    error('ca6-reply-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(ii) allows ' .. WORD_LIMIT .. ' for a reply brief')
  end

  -- ---- headings: numbered as typst numbers them; each has an id (h<id>) for its page ----
  local hid = 0
  local function head(o)
    hid = hid + 1
    o.kind, o.id = 'head', hid
    o.toc = o.toc and o.level <= TOC_DEPTH
    o.where = o.where or 'body'
    return o
  end
  local st = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
  local body = {}
  for _, b in ipairs(blocks) do
    if b.t ~= 'Header' then
      body[#body + 1] = b
    elseif b.level == 1 then
      st.in_arg = plain(b.content):lower():match('^%s*(.-)%s*$') == 'argument'
      for k = 1, 6 do st.counters[k] = 0 end
      body[#body + 1] = head({ level = 1, title = b.content, style = 'section', toc = true })
    else
      st.counters[b.level] = st.counters[b.level] + 1
      for k = b.level + 1, 6 do st.counters[k] = 0 end
      local label = label_for(b.level, st.in_arg, st.counters[b.level])
      local d = st.in_arg and (b.level - 2) or (b.level - 1)
      body[#body + 1] = head({ level = b.level, label = label, title = b.content, style = 'sub', ind = d, toc = true })
    end
  end
  local function fixed(text)
    return head({ level = 1, title = pandoc.Inlines({ pandoc.Str(text) }), style = 'section', toc = true })
  end
  local h_cert = fixed('Certificate of Compliance')
  local has_serv = meta.service and meta.service.certificate
  local h_serv = has_serv and fixed('Certificate of Service') or nil

  local toc = {}
  for _, it in ipairs(body) do if it.kind == 'head' and it.toc then toc[#toc + 1] = it end end
  toc[#toc + 1] = h_cert
  if h_serv then toc[#toc + 1] = h_serv end

  -- ---- the list for the page finder (docx/pages.lua) ----
  local list_file = os.getenv('CA6_DOCX_LIST')
  if list_file and list_file ~= '' then
    local f = assert(io.open(list_file, 'w'))
    for _, e in ipairs(toc) do
      local where = e.style == 'section' and 'line' or 'body'
      local text = plain(e.title)
      if e.label then text = e.label .. ' ' .. text end
      f:write('h' .. e.id, '\t', where, '\t', text, '\n')
    end
    for k, text in ipairs(occ_text) do f:write('k' .. k, '\tbody\t', text, '\n') end
    f:close()
  end

  -- A TOC row [listing-row]: wrapped before the 36 pt page column, a dot leader to the page.
  local function toc_row(e)
    local ind = e.label and e.ind or 0
    local left = (ind + 1) * 720
    local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. left .. '"/><w:tab w:val="right" w:leader="dot" w:pos="'
      .. TEXTW .. '"/></w:tabs>'
    local runs = ''
    if e.label then runs = xe.runs(e.label) .. TAB end
    runs = runs .. xe.inl(e.level == 1 and upper(e.title) or e.title) .. xe.runs(xe.LEAD) .. xe.runs(page_of('h' .. e.id))
    return P({ tabs = tabs, left = left, hanging = 720, right = TOC_COL }, runs)
  end

  local function toa_pages(key)
    local seen_p, list = {}, {}
    for k, kk in ipairs(occ) do
      if kk == key then
        local pg = page_of('k' .. k)
        if not seen_p[pg] then
          seen_p[pg] = true
          list[#list + 1] = pg
        end
      end
    end
    if #list >= PASSIM then return xe.runs('passim', { i = true }), width_of('passim') end
    local s = table.concat(list, ', ')
    return xe.runs(s), width_of(s)
  end

  -- A section heading (level 1): bold capitals, 14 pt, centered, 21 / 15.4 pt; `top`: it opens a page.
  local function section_head(title, top, brk)
    return P({ keep = true, brk = brk, before = top and 0 or 420, after = 308, jc = 'center' },
      xe.inl(upper(title), { b = true }))
  end

  local function toa_blocks()
    local out = { section_head(pandoc.Inlines({ pandoc.Str('Table of Authorities') }), true, true) }
    local first = true
    for _, g in ipairs(KINDS) do
      local members, seen_k = {}, {}
      for _, key in ipairs(occ) do
        if not seen_k[key] and auth[key].kind == g[1] then
          seen_k[key] = true
          members[#members + 1] = key
        end
      end
      table.sort(members, function(x, y) return auth[x].sort < auth[y].sort end)
      if #members > 0 then
        local runs = xe.runs(g[2], { b = true })
        local tabs
        if first then
          runs = runs .. TAB .. xe.runs('Page(s)', { b = true, u = true })
          tabs = '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>'
        end
        out[#out + 1] = P({ keep = true, tabs = tabs, before = first and 280 or 392, after = 56 }, runs)
        first = false
        for _, key in ipairs(members) do
          local a = auth[key]
          local runs2 = ''
          if a.name then runs2 = xe.inl(a.name, { i = a.kind == 'case' }) .. xe.runs(', ') end
          local pages, w = toa_pages(key)
          runs2 = runs2 .. xe.inl(a.cite) .. xe.runs(xe.LEAD) .. pages
          out[#out + 1] = P({ tabs = xe.leader_tab(TEXTW), before = 196, left = 504, hanging = 504,
            right = math.max(TOA_COL, w) }, runs2)
        end
      end
    end
    return out
  end

  local function heading_block(e, top)
    if e.style == 'section' then return section_head(e.title, top) end
    local left = (e.ind + 1) * 720
    local o = { b = true, i = e.level >= 4 }
    return P({ keep = true, tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. left .. '"/></w:tabs>', before = 308, after = 252,
      left = left, hanging = 720 }, xe.runs(e.label, { b = true }) .. TAB .. xe.inl(e.title, o))
  end

  local out = {}
  local function push(x) out[#out + 1] = x end

  -- ---- section 1: the cover (no page number) ----
  for _, b in ipairs(cover(meta)) do push(b) end
  push(section_break(nil, nil))

  -- ---- section 2: contents and authorities (lowercase roman) ----
  push(section_head(pandoc.Inlines({ pandoc.Str('Table of Contents') }), true))
  push(P({ before = 84, jc = 'right' }, xe.runs('Page', { b = true, u = true })))
  for _, e in ipairs(toc) do push(toc_row(e)) end
  for _, b in ipairs(toa_blocks()) do push(b) end
  push(section_break('rIdFtr1', 'lowerRoman'))

  -- ---- section 3: the body (arabic from 1), the signatures, the certificates ----
  local last = body[#body]
  if keeps_last(src) and last and last.t == 'Para' then
    body[#body] = pandoc.Div({ last }, pandoc.Attr('', {}, { ['custom-style'] = 'CA Body Keep' }))
  end
  for i, it in ipairs(body) do
    if it.kind == 'head' then push(heading_block(it, i == 1)) else push(it) end
  end
  for _, b in ipairs(signature_blocks(meta)) do push(b) end

  -- Certificate of Compliance: after the signatures; its text and signature one unbreakable block.
  push(section_head(h_cert.title, false))
  push(P({ keep = true, before = 280 }, xe.runs(join_parens('This reply brief complies with the type-volume limitation of ' .. FRAP .. '32(a)(7)(B) because it contains '
    .. group_digits(words) .. ' words, excluding the parts of the brief exempted by ' .. FRAP .. '32(f).'))))
  push(P({ keep = true, before = 280 }, xe.runs(join_parens('This reply brief complies with the typeface requirements of ' .. FRAP .. '32(a)(5) and the type-style requirements of '
    .. FRAP .. '32(a)(6) because it has been prepared in a proportionally spaced typeface, 14')) .. NBH .. xe.runs('point ' .. FACE .. '.')))
  for _, b in ipairs(cert_signature(meta)) do push(b) end

  if h_serv then
    push(section_head(h_serv.title, true, true))
    push(P({ keep = true, before = 280 }, xe.runs('I certify that I electronically filed and served this ') .. xe.inl(meta.brief_title)
      .. xe.runs(' using the Court\u{2019}s CM/ECF system upon ') .. xe.inl(meta.service.upon) .. xe.runs(' on ') .. xe.inl(meta.date) .. xe.runs('.')))
    for _, b in ipairs(cert_signature(meta)) do push(b) end
  end

  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
