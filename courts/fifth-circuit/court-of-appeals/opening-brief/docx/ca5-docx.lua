-- ca5-docx.lua: pandoc filter for the Fifth Circuit briefs, docx engine (docs/DOCX.md): the markdown contract
-- (frontmatter + "# " sections) -> a Word document on reference.docx (docx/reference.xml).
-- The typst template (typst/ca5-*.typ) is the reference for what each block looks like and where every line and page
-- breaks (cross-engine layout model, docs/EVAL-LOOP.md; lib/docx/xengine.lua). The cover, the headings, the tables of
-- contents and authorities, the signature block and the certificates' signatures are written here as paragraphs in
-- the "CA5 ..." styles (raw WordprocessingML); the body paragraphs, lists, quotations and footnotes are pandoc's.
-- Sections (cover: no number; front matter: lower roman; body: arabic from 1) are section breaks naming the footers
-- this filter gives fb render (FORMBOOK_FOOTERS: rIdRomanFtr, rIdArabicFtr, a centered PAGE field); the last section
-- goes to FORMBOOK_FINAL. The TOC and TOA page numbers: fb render (tools/fb/src/docxpass.rs) renders the document,
-- finds the page of every heading and citation in that PDF (the needles this filter writes to FORMBOOK_NEEDLES) and
-- renders again with those pages (FORMBOOK_PAGES) until they settle (were docx/render.sh and docx/pagemap.awk). Word
-- may paginate slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md). No
-- case-specific text is in this file.

local xe = require('docx.xengine')

local FRONT = { ['certificate of interested persons'] = true, ['statement regarding oral argument'] = true }
local TEXTW = 9360        -- 6.5 in, the text width (letter, 1 in margins)
local TOC_COL = 720       -- typst toc-page-col, 36 pt
local TOA_COL = 1120      -- typst toa-page-col, 56 pt
local SIG = 4320          -- the signature 3 in from the margin
local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')
local LEAD = pandoc.Str('\u{00A0}\u{00A0}\u{00A0}')
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="rIdRomanFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
-- the footers (centered PAGE field) and the body's section (arabic from 1), which name them
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT_BODY = '<w:sectPr><w:footerReference w:type="default" r:id="rIdArabicFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'
-- the empty paragraph that ends a section takes no room (it would push a full page's last line on)
local SECT_LINE = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
local KEEP = '<w:keepNext/>'
local BREAK = '<w:pageBreakBefore/>'

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end
local function norm(s) return trim(s):lower() end
local function fail(msg) error('ca5-docx: ' .. msg, 0) end

local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

-- a metadata value as inlines
local function minl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == 'string' then return pandoc.Inlines({ pandoc.Str(v) }) end
  if v.t == 'MetaBlocks' then return pandoc.utils.blocks_to_inlines(v) end
  if v.t == nil then return pandoc.Inlines(v) end
  return pandoc.Inlines(pandoc.utils.stringify(v))
end

local function cat(...)
  local out = pandoc.Inlines({})
  for _, x in ipairs({ ... }) do
    if type(x) == 'string' then out:insert(pandoc.Str(x))
    elseif x.t == nil then out:extend(pandoc.Inlines(x))
    else out:insert(x) end
  end
  return out
end

local function upper_il(il)
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(e.text:upper()) end }).content
end

local function is_cert(title)
  local t = norm(title)
  return t:sub(1, 14) == 'certificate of' and not FRONT[t]
end

local function commas(n)
  local s = tostring(n)
  local k
  repeat
    s, k = s:gsub('^(%d+)(%d%d%d)', '%1,%2')
  until k == 0
  return s
end

local function roman(n)
  local vals = { { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }
  local s = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

-- Printed label of a numbered heading (CA5-CONT-010). Argument: I. A. 1. a.  Elsewhere: A. 1. a. (1)
local function label(level, in_arg, n)
  local up, low = string.char(64 + n), string.char(96 + n)
  if in_arg then
    if level == 2 then return roman(n) .. '.' end
    if level == 3 then return up .. '.' end
    if level == 4 then return tostring(n) .. '.' end
    if level == 5 then return low .. '.' end
  else
    if level == 2 then return up .. '.' end
    if level == 3 then return tostring(n) .. '.' end
    if level == 4 then return low .. '.' end
    if level == 5 then return '(' .. n .. ')' end
  end
  fail('headings deeper than level 5 are not supported')
end

-- ---------------------------------------------------------------------------
-- Words (CA5-CONT-007; FRAP 32(f)): the typst template's count-words, on the markdown source of the main sections
-- (not the front statements, the tables or the certificates): markup removed, links keep their text, then
-- whitespace-delimited words. The LaTeX engine counts the same way (latex/ca5-brief.lua).
-- ---------------------------------------------------------------------------

local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then fail('no input file to count words in') end
  local h = assert(io.open(f, 'r'))
  local src = h:read('a')
  h:close()
  local body = src:gsub('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n', '', 1)
  local main, parts = {}, {}
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
-- Raw paragraphs
-- ---------------------------------------------------------------------------

local function xesc(s) return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')) end
local function run(text, f)
  local rpr = (f.b and '<w:b/><w:bCs/>' or '') .. (f.i and '<w:i/><w:iCs/>' or '') .. (f.u and '<w:u w:val="single"/>' or '')
  if rpr ~= '' then rpr = '<w:rPr>' .. rpr .. '</w:rPr>' end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
end
local function inl_xml(il, f, out)
  for _, el in ipairs(il) do
    local t = el.t
    if t == 'Str' then out[#out + 1] = run(el.text, f)
    elseif t == 'Space' or t == 'SoftBreak' then out[#out + 1] = run(' ', f)
    elseif t == 'Emph' then inl_xml(el.content, { b = f.b, i = true, u = f.u }, out)
    elseif t == 'Strong' then inl_xml(el.content, { b = true, i = f.i, u = f.u }, out)
    elseif t == 'Underline' then inl_xml(el.content, { b = f.b, i = f.i, u = true }, out)
    elseif t == 'Span' or t == 'Link' or t == 'SmallCaps' then inl_xml(el.content, f, out)
    elseif t == 'RawInline' then
      if el.format == 'openxml' then out[#out + 1] = el.text end
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
end

-- one paragraph: style, inlines, extra pPr elements in schema order, run format
local function P(style, il, extra, f)
  local out = {}
  local d = pandoc.Pandoc({ pandoc.Plain(pandoc.Inlines(il)) }):walk({ Inlines = xe.inlines })
  inl_xml(d.blocks[1].content, f or {}, out)
  return pandoc.RawBlock('openxml', '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or '') .. '</w:pPr>'
    .. table.concat(out) .. '</w:p>')
end
local function sp(before, after, line)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before, after, line or 340)
end
local function custom(style, b) return pandoc.Div({ b }, pandoc.Attr('', {}, { ['custom-style'] = style })) end

-- typst indents a paragraph's first line only after another paragraph: every other one is set flush.
-- The second result: the index in `blocks` each output block comes from.
local function indent_rule(blocks, flush)
  local out, src, prev = {}, {}, nil
  for bi, b in ipairs(blocks) do
    local items = xe.list_items(b)
    if b.t == 'Para' and (prev == nil or prev.t ~= 'Para') then
      out[#out + 1] = custom(flush or 'CA5 No Indent', b)
      src[#out] = bi
    else
      for _, x in ipairs(items) do out[#out + 1] = x; src[#out] = bi end
    end
    prev = b
  end
  return out, src
end

-- The signer block (CA5-CONT-006) [signer-block]: "/s/ Name", the name 7 pt below, the lines; `above` twips clear.
local function signer(sig, above, out)
  out[#out + 1] = P('CA5Signature', cat('/s/ ', minl(sig.signer)), sp(above, 0))
  out[#out + 1] = P('CA5Signature', minl(sig.signer), sp(140, 0))
  for i, l in ipairs(sig.lines or {}) do
    -- the last line ends the block: nothing to keep it with
    out[#out + 1] = P('CA5Signature', minl(l), i == #sig.lines and '<w:keepLines/>' or nil)
  end
end

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60   -- a needle is a prefix of the text (letters and digits only)
local PASSIM = 7        -- an authority cited on this many pages or more is "passim"

-- letters and digits only, lower case: fb render normalizes the PDF text the same way
local function letters(s)
  return (s:lower():gsub('[^a-z0-9]', ''))
end

-- a needle: { id, kind, needle, fallback }; kind B (body, in document order: moves the search on) or N (inside a
-- footnote: searched from the page the body has reached, moves nothing). The fallback, for a needle that runs over
-- a page end (the folio and the footnotes come between its halves), is the text's first two words.
local needles = {}
local function need_at(id, kind, text, context)
  local w1, w2 = text:match('^%s*(%S+)%s+(%S+)')
  local short = letters(w1 and (w1 .. ' ' .. w2) or text):sub(1, NEEDLE_MAX)
  local long = letters(text .. ' ' .. (context or '')):sub(1, NEEDLE_MAX)
  if short == '' then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- the pages of the previous pass: id -> printed page; empty on the first pass
local labels = {}
local function load_pages()
  local path = os.getenv('FORMBOOK_PAGES')
  if not path or path == '' then return end
  local f = io.open(path, 'r')
  if not f then return end
  for line in f:lines() do
    local id, _, lab = line:match('^([^\t]+)\t([^\t]*)\t(.*)$')
    if id then labels[id] = lab end
  end
  f:close()
end

-- the printed page of a needle: "0" on the first pass
local function label_of(id)
  return labels[id] or '0'
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == '' then return end
  local f = assert(io.open(path, 'w'))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- The cover (CA5-CONT-003) [cover]: single-spaced centered lines; the counsel in the lower part of the page
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  -- the lines: {gap above in twips, inlines, run format, counsel}
  local L = {}
  local function line(before, il, f, counsel) L[#L + 1] = { before, il, f, counsel } end
  line(0, cat('No. ', minl(meta.case_number)))
  line(360, cat('In the United States Court of Appeals for the Fifth Circuit'))
  local sides = meta.caption or {}
  for i, side in ipairs(sides) do
    for j, n in ipairs(side.names or {}) do line(j == 1 and (i == 1 and 360 or 168) or 0, minl(n)) end
    line(56, minl(side.designation))
    if i < #sides then line(168, cat('v.')) end
  end
  line(312, minl(meta.proceeding))
  line(360, minl(meta.brief_title), { b = true })
  for gi, g in ipairs(meta.counsel or {}) do
    for j, n in ipairs(g.names or {}) do line((j == 1 and gi > 1) and 140 or 0, minl(n), nil, j == 1 and gi == 1) end
    for _, l in ipairs(g.lines or {}) do line(0, minl(l)) end
  end
  if meta.date then line(280, minl(meta.date)) end
  -- An estimate of the cover's height (a line of the text width holds about 70 characters; the estimate errs
  -- high, and one line is kept spare): typst shrinks every gap alike as far as the page needs, and so does this.
  local lines, gaps = 0, 0
  for _, x in ipairs(L) do
    lines = lines + math.ceil(math.max(1, #plain(x[2])) / 70)
    gaps = gaps + x[1]
  end
  local cap = 12960 / 340   -- the page's text height (9 in) in single-spaced lines
  local s = 1
  if gaps > 0 then s = math.min(1, math.max(0, (cap - lines - 1) * 340 / gaps)) end
  -- typst sets the counsel at the foot of the page (v(1fr)); Word has no fill: the gap is what the page leaves
  -- after the estimated lines, less one line to spare
  local fill = math.max(0, math.floor((cap - lines - s * gaps / 340 - 1) * 340))
  for _, x in ipairs(L) do
    out[#out + 1] = P('CA5Centered', x[2], sp(x[4] and fill or math.floor(x[1] * s), 0), x[3])
  end
  out[#out + 1] = pandoc.RawBlock('openxml', '<w:p><w:pPr>' .. SECT_LINE .. SECT_COVER .. '</w:pPr></w:p>')
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
  local auth = meta.authorities or {}
  load_pages()

  -- every toa: citation in document order, per block of a main section, for a needle: the link text and the words
  -- after it in its paragraph (up to a footnote mark or a quotation), so that the same words elsewhere in the brief,
  -- unlinked, are not taken for it. Kind B (body) moves the search on; N (in a footnote) is searched from the page
  -- the body has reached.
  local scan_blocks
  local function scan(inls, kind, list)
    for i, el in ipairs(inls) do
      if el.t == 'Link' and el.target:match('^toa:') then
        local rest = {}
        for j = i + 1, math.min(#inls, i + 12) do
          local t = inls[j].t
          if t == 'Note' or t == 'Quoted' or t == 'Link' then break end
          rest[#rest + 1] = inls[j]
        end
        list[#list + 1] = { key = el.target:sub(5), kind = kind, text = plain(pandoc.Inlines(el.content)),
          context = plain(pandoc.Inlines(rest)) }
      elseif el.t == 'Note' then
        scan_blocks(el.content, 'N', list)
      elseif el.content ~= nil and type(el.content) == 'table' and el.t ~= 'Code' then
        scan(el.content, kind, list)
      end
    end
  end
  scan_blocks = function(blocks, kind, list)
    for _, b in ipairs(blocks) do
      if b.t == 'Para' or b.t == 'Plain' or b.t == 'Header' then scan(b.content, kind, list)
      elseif b.t == 'BlockQuote' or b.t == 'Div' then scan_blocks(b.content, kind, list)
      elseif b.t == 'BulletList' or b.t == 'OrderedList' then
        for _, item in ipairs(b.content) do scan_blocks(item, kind, list) end
      end
    end
  end

  local secs = split_sections(doc.blocks)
  local front, main, certs = {}, {}, {}
  for _, s in ipairs(secs) do
    if s.title ~= nil and FRONT[norm(s.title)] then front[#front + 1] = s
    elseif s.title ~= nil and is_cert(s.title) then certs[#certs + 1] = s
    else main[#main + 1] = s end
  end
  for _, s in ipairs(main) do
    s.cites = {}
    for bi, b in ipairs(s.blocks) do
      s.cites[bi] = {}
      scan_blocks({ b }, 'B', s.cites[bi])
    end
  end

  -- citations keep their text; every key must be in the registry
  local hits = {}
  local function unlink(blocks)
    return pandoc.Pandoc(blocks):walk({
      Link = function(el)
        local key = el.target:match('^toa:(.+)$')
        if key then
          if auth[key] == nil then fail('link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter') end
          hits[key] = true
        end
        return el.content
      end,
    }):walk({ Inlines = xe.inlines }).blocks
  end
  for _, s in ipairs(secs) do s.blocks = unlink(s.blocks) end

  local words = commas(source_words())

  -- the needles, in document order: the table of authorities' title with its first group (the body's are searched
  -- after it), the body's headings and citations, the certificates' titles. A heading's needle is its label and
  -- title with the first words of the block after it.
  local toa_first = ''
  for _, g in ipairs(GROUPS) do
    local kinds = {}
    for _, k in ipairs(g[1]) do kinds[k] = true end
    for key, a in pairs(auth) do
      if toa_first == '' and kinds[plain(a.kind)] and hits[key] then toa_first = g[2] end
    end
    if toa_first ~= '' then break end
  end
  need_at('S:toa', 'B', 'Table of Authorities ' .. toa_first, '')
  local occurrences = {}
  local function cite_needles(s, bi)
    for _, c in ipairs(s.cites[bi] or {}) do
      occurrences[#occurrences + 1] = { key = c.key, id = 'T:' .. (#occurrences + 1) }
      need_at(occurrences[#occurrences].id, c.kind, c.text, c.context)
    end
  end
  -- the words after a heading: the next block's first words, or the next heading's label and title
  local function after(blocks, bi, labs)
    local b = blocks[bi]
    if b == nil then return '' end
    if b.t == 'Header' and labs[bi] then return labs[bi] .. ' ' .. plain(b.content) end
    return plain(b):sub(1, 40)
  end
  -- the labels of a section's headings, by block
  local function section_labels(blocks, in_arg)
    local c, labs = { 0, 0, 0, 0, 0 }, {}
    for bi, b in ipairs(blocks) do
      if b.t == 'Header' and b.level > 1 and b.level <= 5 then
        c[b.level] = c[b.level] + 1
        for k = b.level + 1, 5 do c[k] = 0 end
        labs[bi] = label(b.level, in_arg, c[b.level])
      end
    end
    return labs
  end

  -- the body: headings get their labels; the TOC lists them, and the certificates
  local heads, body = {}, {}
  local body_id
  local function title_para(s, extra, context)
    local idx = #heads + 1
    heads[idx] = { level = 1, label = '', title = s.inl, idx = idx, id = 'H:' .. idx }
    need_at(heads[idx].id, 'B', plain(s.inl), context)
    return P('CA5Title', s.inl, extra), idx
  end
  for _, s in ipairs(main) do
    local in_arg = s.title ~= nil and norm(s.title) == 'argument'
    local cnt = { 0, 0, 0, 0, 0 }
    local labs = section_labels(s.blocks, in_arg)
    if s.title then
      local p, idx = title_para(s, #body == 0 and sp(0, 252) or nil, after(s.blocks, 1, labs))
      body_id = body_id or heads[idx].id
      body[#body + 1] = p
    elseif #body == 0 and s.blocks[1] then
      body_id = 'S:body'
      need_at(body_id, 'B', plain(s.blocks[1]):sub(1, NEEDLE_MAX), '')
    end
    local blocks, src = indent_rule(s.blocks)
    local done = 0
    for oi, b in ipairs(blocks) do
      if b.t == 'Header' then
        local L = b.level
        if L == 1 then fail('a level-1 heading inside a section') end
        cnt[L] = cnt[L] + 1
        for k = L + 1, 5 do cnt[k] = 0 end
        local lab = label(L, in_arg, cnt[L])
        local idx = #heads + 1
        heads[idx] = { level = L, label = lab, title = b.content, idx = idx, id = 'H:' .. idx }
        need_at(heads[idx].id, 'B', lab .. ' ' .. plain(b.content), after(s.blocks, src[oi] + 1, labs))
        body[#body + 1] = P('CA5Sub' .. L, cat(lab, TAB, b.content), nil, { b = L <= 3 })
      else
        body[#body + 1] = b
      end
      -- a source block's citations follow its last output block
      if src[oi + 1] ~= src[oi] then
        for k = done + 1, src[oi] do cite_needles(s, k) end
        done = src[oi]
      end
    end
    for k = done + 1, #s.blocks do cite_needles(s, k) end
  end
  local cert_paras = {}
  for _, c in ipairs(certs) do
    local first = c.blocks[1] and plain(c.blocks[1]):gsub('{{words}}', words) or ''
    local p = title_para(c, BREAK .. sp(0, 252), first:sub(1, 40))
    cert_paras[#cert_paras + 1] = p
  end

  -- the printed pages of an authority: its distinct pages in the order cited; passim from PASSIM pages
  local function pages_of(key)
    local ls, seen = {}, {}
    for _, o in ipairs(occurrences) do
      local l = label_of(o.id)
      if o.key == key and not seen[l] then seen[l] = true; ls[#ls + 1] = l end
    end
    if #ls >= PASSIM then return 'passim' end
    return table.concat(ls, ', ')
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, '\t') end
  -- how fb render labels pages: the body and the certificates from the body's first block (the front matter's
  -- roman pages are not listed)
  if body_id then nl[#nl + 1] = '#section\t' .. body_id .. '\tdecimal\t' end
  write_file('FORMBOOK_NEEDLES', table.concat(nl, '\n') .. '\n')
  write_file('FORMBOOK_FOOTERS', 'rIdRomanFtr\t' .. FOOTER_P .. '\nrIdArabicFtr\t' .. FOOTER_P .. '\n')
  write_file('FORMBOOK_FINAL', SECT_BODY)

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- section 1: the cover (no page number)
  cover(meta, out)

  -- section 2 (lower roman): the front statements, the table of contents, the table of authorities
  local first_front = true
  for _, s in ipairs(front) do
    add(P('CA5Title', s.inl, (first_front and '' or BREAK) .. sp(0, 252)))
    first_front = false
    if norm(s.title) == 'certificate of interested persons' then
      for _, b in ipairs(indent_rule(s.blocks, 'CA5 CIP No Indent')) do
        if b.t == 'Para' then add(custom('CA5 CIP', b)) else add(b) end
      end
      signer(meta.signature, 280, out)
    else
      for _, b in ipairs(indent_rule(s.blocks)) do add(b) end
    end
  end

  add(P('CA5TableTitle', { pandoc.Str('Table of Contents') }, first_front and '' or BREAK))
  for _, h in ipairs(heads) do
    local page = label_of(h.id)
    local tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
    if h.level == 1 then
      add(P('CA5Single', cat(h.title, LEAD, TAB, page), '<w:keepLines/>' .. tabs .. sp(224, 0)
        .. '<w:ind w:left="0" w:right="' .. TOC_COL .. '" w:firstLine="0"/>'))
    else
      local ind = (h.level - 1) * 576
      add(P('CA5Single', cat(h.label, TAB, h.title, LEAD, TAB, page), '<w:keepLines/><w:tabs><w:tab w:val="left" w:pos="'
        .. (ind + 720) .. '"/><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>' .. sp(224, 0)
        .. '<w:ind w:left="' .. (ind + 720) .. '" w:right="' .. TOC_COL .. '" w:hanging="720"/>'))
    end
  end
  -- the TOC row's first line starts at the level's indent: Word sets the label from the hanging indent's start
  -- (a left indent less the hanging one), so a level's label sits at `ind`

  add(P('CA5TableTitle', { pandoc.Str('Table of Authorities') }, BREAK))
  for _, g in ipairs(GROUPS) do
    local kinds = {}
    for _, k in ipairs(g[1]) do kinds[k] = true end
    local members = {}
    for key, a in pairs(auth) do
      if kinds[plain(a.kind)] and hits[key] then members[#members + 1] = key end
    end
    table.sort(members, function(x, y)
      local a = g[1][1] == 'case' and plain(auth[x].name) or plain(auth[x].cite)
      local b = g[1][1] == 'case' and plain(auth[y].name) or plain(auth[y].cite)
      return a:lower() < b:lower()
    end)
    if #members > 0 then
      add(P('CA5Single', { pandoc.Str(g[2]) }, KEEP .. sp(336, 224), { b = true }))
      for _, key in ipairs(members) do
        local a = auth[key]
        local il = pandoc.Inlines({})
        if plain(a.name) ~= '' then il:insert(pandoc.Emph(minl(a.name))); il:insert(pandoc.Str(',')); il:insert(pandoc.Space()) end
        il:extend(minl(a.cite))
        il:extend({ LEAD, TAB, pandoc.Str(pages_of(key)) })
        add(P('CA5Single', il, '<w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
          .. sp(224, 0) .. '<w:ind w:left="504" w:right="' .. TOA_COL .. '" w:hanging="504"/>'))
      end
    end
  end
  add(pandoc.RawBlock('openxml', '<w:p><w:pPr>' .. SECT_LINE .. SECT_ROMAN .. '</w:pPr></w:p>'))

  -- section 3 (arabic from 1): the body, the closing signature, the certificates
  -- The closing signature never stands alone on a page: the brief's last paragraph is kept whole with it.
  local last = #body
  while last > 0 and body[last].t ~= 'Div' and body[last].t ~= 'Para' and body[last].t ~= 'RawBlock' do last = last - 1 end
  for i, b in ipairs(body) do
    if i == last and (b.t == 'Para' or b.t == 'Div') then
      local para = b.t == 'Div' and b.content[1] or b
      add(custom('CA5 Body Last', para))
    else
      add(b)
    end
  end
  if meta.date then add(P('CA5Single', cat('Dated: ', minl(meta.date)), KEEP .. '<w:keepLines/>' .. sp(576, 0))) end
  add(P('CA5Signature', cat('Respectfully submitted,'), sp(meta.date and 112 or 576, 0)))
  signer(meta.signature, 168, out)

  for i, c in ipairs(certs) do
    add(cert_paras[i])
    local blocks = pandoc.Pandoc(c.blocks):walk({
      Str = function(el)
        if el.text:find('{{words}}', 1, true) then return pandoc.Str((el.text:gsub('{{words}}', words))) end
      end,
    }).blocks
    for _, b in ipairs(blocks) do
      if b.t == 'Para' then add(custom('CA5 No Indent', b)) else add(b) end
    end
    signer(meta.signature, 280, out)
  end

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({})   -- pandoc would print the date and title as a block at the top
  return doc
end
