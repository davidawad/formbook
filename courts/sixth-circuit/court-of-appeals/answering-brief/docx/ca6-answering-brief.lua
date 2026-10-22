-- U.S. Court of Appeals for the Sixth Circuit: appellee's brief (answering brief), Word (docx) engine.
-- A pandoc filter. It writes the brief from the sample's frontmatter and body on reference.docx (built by fb render
-- from docx/reference.xml: the shared style recipe of lib/docx/xengine-reference.sh), with the same rules and
-- numbers as ../typst/ca6-answering-brief.typ. Page numbers (TOC, TOA) are plain text: fb render's multi-pass build
-- (tools/fb/src/docxpass.rs) renders the brief, finds the needles this filter writes (FORMBOOK_NEEDLES) in the
-- LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle. The sections name this
-- filter's footers (FORMBOOK_FOOTERS: rIdCa6Page, rIdCa6Add); the last section is FORMBOOK_FINAL. Word may
-- paginate slightly differently. Rules: ../README.md.
--
-- Cross-engine layout (docs/EVAL-LOOP.md, "Cross-engine gate"; lib/docx/xengine.lua): every paragraph written here
-- carries the typst template's line box (exact line spacing: 31.4 pt body, 20 pt single) and spaces (twips = 20 x
-- pt), its text as runs with typst's break rules (a no-break hyphen before a digit, pandoc's abbreviation no-break
-- spaces undone, a section sign bound to its number); the text pandoc writes itself gets the same rules.

local xe = require('docx.xengine')

local TOC_DEPTH = 4                     -- typst: toc-depth
local PASSIM = 7                        -- typst: passim-threshold
-- typst: word-limits and word-limit-rule (FRAP 32(a)(7)(B); FRAP 28.1(e)(2)), keyed by word_limit_basis
local WORD_LIMITS = { standard = 13000, ['cross-appeal'] = 15300, reply = 6500, ['cross-appeal-reply'] = 6500 }
local WORD_LIMIT_RULE = {
  standard = '32(a)(7)(B)(i)', ['cross-appeal'] = '28.1(e)(2)(B)(i)', reply = '32(a)(7)(B)(ii)',
  ['cross-appeal-reply'] = '28.1(e)(2)(C)',
}
local FACE = 'TeX Gyre Schola'          -- the typeface the template sets (typst font-family)

-- typst's numbers, in twips
local SINGLE, HEAD_SZ = 400, 30         -- pitch-single 20 pt; section headings 15 pt (half points)
local TEXTW = 9360                      -- 6.5 in
local HALF = 4680                       -- half-measure, 3.25 in
local COUNSEL = 3744                    -- counsel-indent, 2.6 in
local STEP = 140                        -- the signer's and counsel's lines step in 0.5 em (7 pt)
local QBOX = 448                        -- the disclosure's question numbers: a 1.6 em box
local TOC_COL, TOA_COL = 720, 1120      -- the page columns of the tables, 36 pt and 56 pt

-- Pages of the previous pass (fb render's multi-pass build, tools/fb/src/docxpass.rs): FORMBOOK_PAGES holds
-- "id <TAB> page <TAB> label" for every needle this filter wrote; absent on the first pass (placeholders).
local PAGES = {}   -- needle id -> printed page label: h<id> (heading), k<k> (citation k)
local pages_file = os.getenv('FORMBOOK_PAGES')
if pages_file and pages_file ~= '' then
  for line in io.lines(pages_file) do
    local id, _, label = line:match('^([^\t]+)\t([^\t]*)\t(.*)$')
    if id then PAGES[id] = label end
  end
end
local function page_of(tag) return PAGES[tag] or '0' end

-- The needles (tools/fb/src/docxpages.rs): one per heading, citation and section start, in document order, each
-- its text and what follows it reduced to lower-case letters and digits (so a heading is found in the body, not at
-- its row in the table of contents); the text alone is the fallback. A citation in a footnote is kind N (searched
-- from the page the body has reached). A citation counts on the page of its first word, as typst tags it.
local NEEDLE_MAX = 60
local function norm(s) return (s:lower():gsub('[^%w]', '')) end
local needles = {}
local function need(id, kind, text, after)
  local alone = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. ' ' .. (after or '')):sub(1, NEEDLE_MAX)
  needles[#needles + 1] = table.concat({ id, kind, long, alone ~= '' and alone or long }, '\t')
end
local function write_file(var, text)
  local path = os.getenv(var)
  if not path or path == '' then return end
  local f = assert(io.open(path, 'w'))
  f:write(text)
  f:close()
end
-- the page-number footers (FORMBOOK_FOOTERS): centered, in a line box of the single pitch (20 pt), as typst's folio
local function footer(prefix)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="400" w:lineRule="exact"/><w:ind w:firstLine="0"/>'
    .. '<w:jc w:val="center"/></w:pPr>' .. (prefix and ('<w:r><w:t xml:space="preserve">' .. prefix .. '</w:t></w:r>') or '')
    .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
end

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
-- No break inside a token of adjacent parentheses ("32(a)(5)"; typst boxes it, LibreOffice would break between ")"
-- and "("): a word joiner between them.
local function join_parens(s) return (s:gsub('%)%(', ')\u{2060}(')) end

-- ---------------------------------------------------------------------------
-- paragraphs as WordprocessingML
-- ---------------------------------------------------------------------------

-- p(o, runs): o = { style, keep, lines, brk, bdr, tabs, before, after, line, left, hanging, first, right, jc }
-- (paragraph properties in the schema's order)
local function p(o, runs)
  local x = {}
  if o.style then x[#x + 1] = xe.style(o.style) end
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
-- "14-point" stays on one line (typst boxes it): Word's non-breaking hyphen
local NBH = '<w:r><w:noBreakHyphen/></w:r>'

-- capitals of inlines (typst upper())
local function upper(il)
  return pandoc.Inlines(il):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- the empty paragraph that ends a section takes no room (it would push a full page's last line on)
local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local function section_break(footer_rid, numfmt)
  local f = footer_rid and ('<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>') or ''
  local pg = numfmt and ('<w:pgNumType w:fmt="' .. numfmt .. '" w:start="1"/>') or ''
  return xe.raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>' .. f
    .. PG .. pg .. '</w:sectPr></w:pPr></w:p>')
end

-- ---------------------------------------------------------------------------
-- numbering, words
-- ---------------------------------------------------------------------------

-- Numbering as typst's heading labels: Argument I. / A. / 1. / a.   Elsewhere A. / 1. / a. / (1)
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
  if n > 26 then error('ca6-brief: more than 26 sub-headings at one level') end
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
  error('ca6-brief: headings deeper than level 5 are not supported')
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

-- The width of a page list in 14 pt TeX Gyre Schola (typst measure(page-text)), in twips.
local ADV = { [','] = 78, [' '] = 93, ['-'] = 93, i = 88, l = 88, v = 150, x = 150, c = 124, A = 202, d = 161,
  p = 161, a = 156, s = 130, m = 249 }
local function width_of(s)
  local w = 0
  for c in s:gmatch('.') do w = w + (c:match('%d') and 156 or ADV[c] or 156) end
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

-- ---------------------------------------------------------------------------
-- the parts
-- ---------------------------------------------------------------------------

-- The cover [cover-body]: centered single-spaced lines, the rules, the caption, the counsel block.
local function cover(m)
  local out = {}
  local GAP = 60   -- the gaps between the cover's parts (typst: the largest that lets the cover fit one page)
  local function c(runs, before) out[#out + 1] = P({ jc = 'center', before = before or 0 }, runs) end
  local function double_rule()
    out[#out + 1] = P({ bdr = '<w:pBdr><w:top w:val="single" w:sz="13" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>',
      before = GAP, after = GAP, line = 50 })
  end
  local function short_rule()
    out[#out + 1] = P({ bdr = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>',
      before = 0, after = GAP, line = 80, left = 3240, right = 3240 })
  end
  c(xe.runs('Case No. ', { b = true }) .. xe.inl(m.case_number, { b = true }))
  double_rule()
  c(xe.runs('UNITED STATES COURT OF APPEALS', { b = true }) .. xe.BR .. xe.runs('FOR THE SIXTH CIRCUIT', { b = true }), GAP)
  short_rule()
  -- the case title; a side marked `continues: true` follows the one before it without "v." (CA6-COVER-003)
  for i, side in ipairs(m.caption) do
    if i > 1 and not side.continues then c(xe.runs('v.'), 60) end
    for _, n in ipairs(side.names) do c(xe.inl(n)) end
    out[#out + 1] = P({ left = HALF }, xe.inl(side.designation))
  end
  short_rule()
  c(xe.inl(m.proceeding), GAP)
  short_rule()
  c(xe.inl(upper(m.brief_title), { b = true }), GAP)
  if m.oral_argument then c(xe.runs('ORAL ARGUMENT REQUESTED', { b = true }), GAP) end
  short_rule()
  -- counsel (FRAP 32(a)(2)(F)): 2.6 in from the margin, the lines stepped in 0.5 em
  for gi, g in ipairs(m.counsel) do
    for ni, n in ipairs(g.names) do
      out[#out + 1] = P({ keep = true, left = COUNSEL, before = (gi == 1 and ni == 1) and GAP or 0 }, xe.inl(n))
    end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #m.counsel then lines[#lines + 1] = m.phone end
    for _, l in ipairs(lines) do out[#out + 1] = P({ keep = true, left = COUNSEL + STEP }, xe.inl(l, { i = true })) end
  end
  out[#out + 1] = P({ line = 20, before = GAP })
  double_rule()
  return out
end

-- Corporate disclosure (6th Cir. R. 26.1; CA6-DISC-001) [disclosure-page]: its own unnumbered page.
local function disclosure(m)
  local d = m.disclosure
  local out = {}
  out[#out + 1] = P({ brk = true, jc = 'center' }, xe.runs('DISCLOSURE OF CORPORATE AFFILIATIONS AND FINANCIAL INTEREST', { b = true }))
  out[#out + 1] = P({ before = 560 }, xe.runs('Pursuant to 6th Cir. R. 26.1, ') .. xe.inl(d.party) .. xe.runs(' makes the following disclosure:'))
  local function q(n, text)
    out[#out + 1] = P({ tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. QBOX .. '"/></w:tabs>', before = 280, left = QBOX, hanging = QBOX },
      xe.runs(n) .. TAB .. xe.runs(text))
  end
  local function a(v) out[#out + 1] = P({ before = 280, left = QBOX }, xe.inl(v)) end
  q('1.', 'Is said party a subsidiary or affiliate of a publicly owned corporation? If yes, list below the identity of the parent corporation or affiliate and the relationship between it and the named party:')
  a(d.subsidiary)
  q('2.', 'Is there a publicly owned corporation, not a party to the appeal, that has a financial interest in the outcome? If yes, list the identity of such corporation and the nature of the financial interest:')
  a(d.financial_interest)
  return out
end

-- The filing attorney's lines [signature-lines]: "s/ Name", the name in capitals, the office lines stepped in
-- 0.5 em; `first` the space above the first line; every line kept with the next (`keep_last`: the last too).
local function signature_lines(m, left, first, keep_last)
  local sig = m.signature
  local out = {}
  local lines = sig.lines or {}
  out[#out + 1] = P({ keep = true, before = first, left = left }, xe.runs('s/ ' .. plain(sig.signer)))
  out[#out + 1] = P({ keep = keep_last or #lines > 0, left = left }, xe.runs(pandoc.text.upper(plain(sig.signer))))
  for i, l in ipairs(lines) do
    out[#out + 1] = P({ keep = keep_last or i < #lines, left = left + STEP }, xe.inl(l, { i = true }))
  end
  return out
end

-- The signature block after the Conclusion [signature-block]: 19.6 pt above; "Respectfully submitted," in the right
-- half, 16.8 pt, the lines; the date at the margin 11.2 pt below. Not split, kept with the paragraph above.
local function signature_blocks(m)
  local out = { P({ keep = true, before = 392, left = HALF }, xe.runs('Respectfully submitted,')) }
  for _, b in ipairs(signature_lines(m, HALF, 336, m.date ~= nil)) do out[#out + 1] = b end
  if m.date then out[#out + 1] = P({ before = 224 }, xe.inl(m.date)) end
  return out
end

-- The signature under a certificate [cert-block(signature-block-compact)]: 14 pt above the block and 16.8 pt inside
-- it (30.8 pt), at the margin; the date 11.2 pt below; not split.
local function signature_compact(m)
  local out = signature_lines(m, 0, 616, m.date ~= nil)
  if m.date then out[#out + 1] = P({ before = 224 }, xe.inl(m.date)) end
  return out
end

function Pandoc(doc)
  doc = doc:walk({ Str = function(s) return pandoc.Str(join_parens(s.text)) end })   -- the body and the metadata
  local meta = doc.meta
  local auth = authorities_of(meta)
  local basis = meta.word_limit_basis and plain(meta.word_limit_basis) or 'standard'
  if not WORD_LIMITS[basis] then error('ca6-brief: unknown word_limit_basis `' .. basis .. '`') end

  -- Citations, in document order: occ[k] is the key of the k-th citation in the body; cites[i] the needles of the
  -- citations in block i (the link text and what follows it in its paragraph; kind N inside a footnote).
  local occ, cites = {}, {}
  local function text_of(il) return plain(pandoc.Inlines(il):walk({ Note = function() return {} end })) end
  local function btext_of(bs) return plain(pandoc.Blocks(bs):walk({ Note = function() return {} end })) end
  local scan_blocks
  local function scan(list, il, in_note)
    for i, el in ipairs(il) do
      if el.t == 'Link' and el.target:sub(1, 4) == 'toa:' then
        local key = el.target:sub(5)
        if not auth[key] then
          error('ca6-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
        end
        occ[#occ + 1] = key
        local rest = {}
        for j = i + 1, #il do rest[#rest + 1] = il[j] end
        list[#list + 1] = { 'k' .. #occ, in_note and 'N' or 'B', text_of(el.content), text_of(rest) }
      elseif el.t == 'Note' then
        scan_blocks(list, el.content, true)
      elseif type(el.content) == 'table' then
        scan(list, el.content, in_note)
      end
    end
  end
  scan_blocks = function(list, bs, in_note)
    for _, b in ipairs(bs) do
      if b.t == 'Para' or b.t == 'Plain' or b.t == 'Header' then
        scan(list, b.content, in_note)
      elseif b.t == 'BlockQuote' or b.t == 'Div' then
        scan_blocks(list, b.content, in_note)
      elseif b.t == 'BulletList' or b.t == 'OrderedList' then
        for _, item in ipairs(b.content) do scan_blocks(list, item, in_note) end
      end
    end
  end
  for i, b in ipairs(doc.blocks) do
    cites[i] = {}
    scan_blocks(cites[i], { b }, false)
  end
  local blocks = doc.blocks:walk({
    Link = function(l) if l.target:sub(1, 4) == 'toa:' then return l.content end end,
  })
  -- the break rules of typst on the text pandoc writes itself (body, footnotes, quotations); lists as typst sets
  -- them (the number in a half-inch box, the text hanging after it)
  blocks = pandoc.Pandoc(blocks):walk({ Inlines = inlines }).blocks
  local flat = pandoc.Blocks({})
  local fcites = {}   -- the citations of each block of the flat list (a list's at its first item)
  for i, b in ipairs(blocks) do
    local items = xe.list_items(b)
    for j = 1, #items do fcites[#flat + j] = j == 1 and cites[i] or {} end
    flat:extend(items)
  end
  blocks = flat

  -- The addendum (after "# Addendum") sits after the certificates.
  local main, add = pandoc.List(), nil
  for i, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 and plain(b.content):lower():match('^%s*addendum%s*$') then
      add = pandoc.List({ table.unpack(blocks, i + 1) })
      break
    end
    main:insert(b)
  end
  if meta.oral_argument then
    local found = false
    for _, b in ipairs(main) do
      if b.t == 'Header' and b.level == 1 and plain(b.content):lower():match('oral argument') then found = true end
    end
    if not found then error('ca6-brief: oral_argument is set but the brief has no statement in support of oral argument') end
  end

  -- The statements before the Argument (preliminary_sections of them) are roman, in the front matter.
  local prelim_n = meta.preliminary_sections and tonumber(plain(meta.preliminary_sections)) or 0
  local top = 0
  for _, b in ipairs(main) do if b.t == 'Header' and b.level == 1 then top = top + 1 end end
  if prelim_n > top then
    error('ca6-brief: preliminary_sections is ' .. prelim_n .. ' but the body has ' .. top .. ' sections')
  end
  local prelim_blocks, body_blocks = pandoc.List(), pandoc.List()
  local seen = 0
  for _, b in ipairs(main) do
    if b.t == 'Header' and b.level == 1 then seen = seen + 1 end
    if seen <= prelim_n then prelim_blocks:insert(b) else body_blocks:insert(b) end
  end

  local words = source_words()
  local limit = WORD_LIMITS[basis]
  if words > limit then
    error('ca6-brief: the brief has ' .. words .. ' words; the ' .. basis .. ' limit is ' .. limit)
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

  local function body_items(bs, numbered)
    local st = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
    local items = {}
    for _, b in ipairs(bs) do
      if b.t ~= 'Header' then
        items[#items + 1] = b
      elseif b.level == 1 then
        st.in_arg = plain(b.content):lower():match('^%s*(.-)%s*$') == 'argument'
        for k = 1, 6 do st.counters[k] = 0 end
        items[#items + 1] = head({ level = 1, title = b.content, style = 'section', toc = true })
      elseif not numbered then
        items[#items + 1] = head({ level = b.level, title = b.content, style = 'plain', ind = b.level - 2, toc = true })
      else
        st.counters[b.level] = st.counters[b.level] + 1
        for k = b.level + 1, 6 do st.counters[k] = 0 end
        local label = label_for(b.level, st.in_arg, st.counters[b.level])
        if st.in_arg and b.level == 2 then
          items[#items + 1] = head({ level = 2, label = label, title = b.content, style = 'point', ind = 0, toc = true })
        else
          local d = st.in_arg and (b.level - 2) or (b.level - 1)
          items[#items + 1] = head({ level = b.level, label = label, title = b.content, style = 'sub', ind = d, toc = true })
        end
      end
    end
    return items
  end

  local function fixed(text, where)
    return head({ level = 1, title = pandoc.Inlines({ pandoc.Str(text) }), style = 'section', toc = true, where = where })
  end
  local h_toa = fixed('Table of Authorities', 'front')
  local prelim = body_items(prelim_blocks, false)
  for _, it in ipairs(prelim) do if it.kind == 'head' then it.where = 'front' end end
  local body = body_items(body_blocks, true)
  local h_cert = fixed('Certificate of Compliance', 'body')
  local h_serv = fixed('Certificate of Service', 'body')
  local h_add = add and fixed('Addendum', 'body') or nil
  local addendum = add and body_items(add, false) or nil

  -- The TOC (typst: outline of every outlined heading before the addendum's own): the Table of Authorities, the
  -- statements before the Argument, the body's headings, the certificates, and the Addendum entry. The addendum's
  -- headings are listed in the addendum's contents (level 2 only, as in typst).
  local toc = { h_toa }
  for _, it in ipairs(prelim) do if it.kind == 'head' and it.toc then toc[#toc + 1] = it end end
  for _, it in ipairs(body) do if it.kind == 'head' and it.toc then toc[#toc + 1] = it end end
  toc[#toc + 1] = h_cert
  toc[#toc + 1] = h_serv
  if h_add then toc[#toc + 1] = h_add end
  local add_toc = {}
  if addendum then
    for _, it in ipairs(addendum) do if it.kind == 'head' and it.level == 2 then add_toc[#add_toc + 1] = it end end
  end

  -- ---- the needles for fb render's page finder, in document order ----
  local function item_text(it)
    if not it then return '' end
    if it.kind == 'head' then return (it.label and (it.label .. ' ') or '') .. text_of(it.title) end
    return btext_of({ it })
  end
  local function head_need(e, after) need('h' .. e.id, 'B', item_text(e), after) end
  need('S:front', 'B', 'Table of Contents', 'Page')
  local first_group = ''
  for _, g in ipairs(KINDS) do
    for _, key in ipairs(occ) do
      if first_group == '' and auth[key].kind == g[1] then first_group = g[2] .. ' Page(s)' end
    end
  end
  head_need(h_toa, first_group)
  local function items_needles(items, first_block)
    for i, it in ipairs(items) do
      if it.kind == 'head' then head_need(it, item_text(items[i + 1]):sub(1, 40)) end
      for _, c in ipairs(fcites[first_block + i - 1] or {}) do need(c[1], c[2], c[3], c[4]) end
    end
  end
  items_needles(prelim, 1)
  local body_start = body[1] and body[1].kind == 'head' and ('h' .. body[1].id) or 'S:body'
  if body_start == 'S:body' then need('S:body', 'B', item_text(body[1]):sub(1, NEEDLE_MAX), '') end
  items_needles(body, #prelim + 1)
  head_need(h_cert, 'I certify that this brief')
  head_need(h_serv, 'I certify that on')
  if h_add then
    head_need(h_add, 'Table of Contents')
    items_needles(addendum, #main + 2)
  end
  needles[#needles + 1] = '#section\tS:front\tlower-roman\t'
  needles[#needles + 1] = '#section\t' .. body_start .. '\tdecimal\t'
  if h_add then needles[#needles + 1] = '#section\th' .. h_add.id .. '\tdecimal\tAdd-' end
  write_file('FORMBOOK_NEEDLES', table.concat(needles, '\n') .. '\n')
  write_file('FORMBOOK_FOOTERS', 'rIdCa6Page\t' .. footer() .. '\nrIdCa6Add\t' .. footer('Add-') .. '\n')
  write_file('FORMBOOK_FINAL', '<w:sectPr><w:footerReference w:type="default" r:id="' .. (h_add and 'rIdCa6Add' or 'rIdCa6Page')
    .. '"/>' .. PG .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>')

  -- A TOC row [listing-row]: the label at its heading's indent, the title hanging after it, wrapped before the
  -- 36 pt page column (right indent); three no-break spaces and a dot leader to the page at the margin.
  local function toc_row(e)
    local ind = (e.label or e.style == 'plain') and e.ind or 0
    local left = (ind + 1) * 720
    local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. left .. '"/><w:tab w:val="right" w:leader="dot" w:pos="'
      .. TEXTW .. '"/></w:tabs>'
    local runs = ''
    if ind > 0 and not e.label then runs = TAB end
    if e.label then runs = xe.runs(e.label) .. TAB end
    runs = runs .. xe.inl(e.level == 1 and upper(e.title) or e.title) .. xe.runs(xe.LEAD) .. xe.runs(page_of('h' .. e.id))
    return P({ tabs = tabs, left = left, hanging = 720, right = TOC_COL }, runs)
  end

  -- ---- the TOA: the cited authorities, grouped and sorted; each one's pages, merged by page ----
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

  -- A section heading (level 1): bold capitals, 15 pt, centered, 21 / 15.4 pt; `top`: it opens a page (no space
  -- above it, as typst drops it there); `brk`: it starts a new page; `keep_all`: its block is not split.
  local function section_head(title, top, brk)
    return P({ keep = true, brk = brk, before = top and 0 or 420, after = 308, jc = 'center' },
      xe.inl(upper(title), { b = true, sz = HEAD_SZ }))
  end

  local function toa_blocks()
    local out = { section_head(h_toa.title, true, true) }
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
          if a.name then runs2 = xe.inl(a.name, { i = a.kind == 'case' }) .. xe.runs(',') .. xe.BR end
          local pages, w = toa_pages(key)
          runs2 = runs2 .. xe.inl(a.cite) .. xe.runs(xe.LEAD) .. pages
          out[#out + 1] = P({ tabs = xe.leader_tab(TEXTW), before = 196, left = 504, hanging = 504,
            right = math.max(TOA_COL, w) }, runs2)
        end
      end
    end
    return out
  end

  -- A heading of the body [style-heading]; `top`: it opens a page.
  local function heading_block(e, top, brk)
    if e.style == 'section' then return section_head(e.title, top, brk) end
    if e.style == 'point' then
      return P({ keep = true, before = 336, after = 280, jc = 'center' },
        xe.runs(e.label .. ' ', { b = true }) .. xe.inl(e.title, { b = true }))
    end
    if e.style == 'plain' then
      return P({ keep = true, before = 336, after = 252 }, xe.inl(e.title, { b = true }))
    end
    local left = (e.ind + 1) * 720
    local o = { b = true, i = e.level >= 4 }
    return P({ keep = true, tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. left .. '"/></w:tabs>', before = 308, after = 252,
      left = left, hanging = 720 }, xe.runs(e.label, o) .. TAB .. xe.inl(e.title, o))
  end

  local out = {}
  local function push(x) out[#out + 1] = x end

  -- ---- section 1: the cover and the corporate disclosure (no page number) ----
  for _, b in ipairs(cover(meta)) do push(b) end
  if meta.disclosure then for _, b in ipairs(disclosure(meta)) do push(b) end end
  push(section_break(nil, nil))

  -- ---- section 2: front matter, lowercase roman numerals from the table of contents ----
  push(section_head(pandoc.Inlines({ pandoc.Str('Table of Contents') }), true))
  push(P({ before = 84, jc = 'right' }, xe.runs('Page', { b = true, u = true })))
  for _, e in ipairs(toc) do push(toc_row(e)) end
  for _, b in ipairs(toa_blocks()) do push(b) end
  -- the statements before the Argument start on a new page (typst: their own `set page`)
  for i, it in ipairs(prelim) do
    if it.kind == 'head' then push(heading_block(it, i == 1, i == 1)) else push(it) end
  end
  push(section_break('rIdCa6Page', 'lowerRoman'))

  -- ---- section 3: the body (arabic from 1), the certificates ----
  -- The last paragraph is kept with the signature block (typst sets them in one unbreakable block).
  local last = body[#body]
  if last and last.t == 'Para' then body[#body] = pandoc.Div({ last }, pandoc.Attr('', {}, { ['custom-style'] = 'CA Body Keep' })) end
  for i, it in ipairs(body) do
    if it.kind == 'head' then push(heading_block(it, i == 1)) else push(it) end
  end
  for _, b in ipairs(signature_blocks(meta)) do push(b) end

  -- Certificate of Compliance (FRAP 32(g)(1); typst certificate-of-compliance): a new page.
  push(section_head(h_cert.title, true, true))
  push(P({ before = 280 }, xe.runs(join_parens('I certify that this brief complies with the type-volume limitation of Fed. R. App. P. ' ..
    WORD_LIMIT_RULE[basis] .. '. Exclusive of the items exempted by Fed. R. App. P. 32(f), the brief contains ' ..
    group_digits(words) .. ' words.'))))
  push(P({ before = 280 }, xe.runs('The brief has been prepared in a proportionally spaced typeface, ' .. FACE .. ' in 14')
    .. NBH .. xe.runs(join_parens('point type, which complies with Fed. R. App. P. 32(a)(5) and (6).'))))
  for _, b in ipairs(signature_compact(meta)) do push(b) end

  -- Certificate of Service (FRAP 25(d); typst certificate-of-service): one unbreakable block.
  local svc = meta.service
  if not svc then error('ca6-brief: missing required metadata field `service`') end
  push(section_head(h_serv.title, false))
  push(P({ keep = true, before = 280 }, xe.runs('I certify that on ') .. xe.inl(svc.date) .. xe.runs(', I electronically filed the foregoing with the Clerk of the Court using the CM/ECF system, which will send notification of such filing to all attorneys of record.')))
  local unreg = svc.unregistered or {}
  if #unreg > 0 then
    push(P({ keep = true, before = 280 }, xe.runs('I further certify that I have mailed by United States Postal Service the document to the following non-ECF participants:')))
    for _, u in ipairs(unreg) do push(P({ keep = true, before = 280, left = 720 }, xe.inl(u.name) .. xe.runs(', ') .. xe.inl(u.address))) end
  end
  for _, b in ipairs(signature_compact(meta)) do push(b) end

  -- ---- section 4: the addendum (6 Cir. R. 28(b)(1)(A)(i)), numbered Add-1, Add-2; its own contents ----
  if add then
    push(section_break('rIdCa6Page', 'decimal'))
    push(section_head(h_add.title, true))
    push(section_head(pandoc.Inlines({ pandoc.Str('Table of Contents') }), false))
    for _, e in ipairs(add_toc) do push(toc_row(e)) end
    for i, it in ipairs(addendum) do
      if it.kind == 'head' then push(heading_block(it, i == 1, i == 1)) else push(it) end
    end
  end

  -- Pandoc would print the date metadata as a title block at the top of the first page; the date is in the
  -- signature and the certificate of service already.
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
