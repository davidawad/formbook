-- U.S. Court of Appeals for the Sixth Circuit: appellant's principal brief, Word (docx) engine.
-- A pandoc filter. It writes the brief from the sample's frontmatter and body on reference.docx (built by fb render
-- from docx/reference.xml: the shared style recipe of lib/docx/xengine-reference.sh), with the same rules and
-- numbers as ../typst/ca6-opening-brief.typ. Page numbers (TOC, TOA) are plain text: fb render's multi-pass build
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
local WORD_LIMIT = 13000                -- FRAP 32(a)(7)(B)(i)
local FACE = 'Times New Roman'          -- the typeface the template sets (typst font-family)

-- typst's numbers, in twips
local SINGLE, HEAD_SZ = 400, 32         -- pitch-single 20 pt; section headings 16 pt (half points)
local TEXTW = 9360                      -- 6.5 in
local HALF = 4680                       -- half-measure, 3.25 in
local STEP = 140                        -- the signer's and counsel's lines step in 0.5 em (7 pt)
local TOC_COL, TOA_COL = 720, 1120      -- the page columns of the tables, 36 pt and 56 pt
local SIGCOL = 4820                     -- form-sig-line: the date column, (text width + 14 pt gutter) / 2

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

-- typst count-words on the markdown source of the body (frontmatter off, the addendum off), step by step, so that
-- every engine certifies the same number.
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error('ca6-brief: no input file to count words in', 0) end
  local h = assert(io.open(f, 'r'))
  local src = h:read('a')
  h:close()
  local fm = src:match('^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n')
  if not fm then error('ca6-brief: the sample must start with a YAML frontmatter block', 0) end
  local body = src:sub(#fm + 1)
  local lines = {}
  for line in (body .. '\n'):gmatch('(.-)\r?\n') do
    if line:lower():match('^#[ \t]+addendum[ \t]*$') then break end
    lines[#lines + 1] = line
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

-- The width of a page list in 14 pt Times New Roman (typst measure(page-text)), in twips.
local ADV = { [','] = 70, [' '] = 70, ['-'] = 93, i = 78, l = 78, v = 140, x = 140, c = 124, A = 202, d = 140,
  p = 140, a = 124, s = 109, m = 218 }
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

-- ---------------------------------------------------------------------------
-- the parts
-- ---------------------------------------------------------------------------

-- Single-spaced paragraphs (disclosure, certificates, designation lead-in): 14 pt above each.
local function single_paras(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == 'Para' or b.t == 'Plain' then
      out[#out + 1] = P({ before = 280 }, xe.inl(b.content))
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- The cover [cover-body]: centered single-spaced lines, the rules, the caption, the counsel columns.
local function cover(m)
  local out = {}
  local function c(runs, before) out[#out + 1] = P({ jc = 'center', before = before or 0 }, runs) end
  local GAP = 120
  local function double_rule()
    out[#out + 1] = P({ bdr = '<w:pBdr><w:top w:val="single" w:sz="13" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>',
      before = GAP, after = GAP, line = 50 })
  end
  local function short_rule()
    out[#out + 1] = P({ bdr = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>',
      before = 0, after = GAP, line = 80, left = 3240, right = 3240 })
  end
  c(xe.runs('No. ', { b = true }) .. xe.inl(m.case_number, { b = true }))
  double_rule()
  c(xe.runs('IN THE UNITED STATES COURT OF APPEALS', { b = true }) .. xe.BR .. xe.runs('FOR THE SIXTH CIRCUIT', { b = true }), GAP)
  short_rule()
  for i, side in ipairs(m.caption) do
    for _, n in ipairs(side.names) do c(xe.inl(n)) end
    out[#out + 1] = P({ left = HALF }, xe.inl(side.designation))
    if i < #m.caption then c(xe.runs('v.'), 60) end
  end
  short_rule()
  c(xe.inl(m.proceeding), GAP)
  short_rule()
  c(xe.inl(upper(m.brief_title), { b = true }), GAP)
  short_rule()
  -- Counsel (FRAP 32(a)(2)(F)): one group in the right half; several in two columns 14 pt apart, in rows.
  local groups = m.counsel
  local function group_xml(gi, g)
    local x = {}
    for _, n in ipairs(g.names) do x[#x + 1] = p({ keep = true }, xe.inl(n)) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = m.phone end
    for _, l in ipairs(lines) do x[#x + 1] = p({ keep = true, left = STEP }, xe.inl(l, { i = true })) end
    return table.concat(x)
  end
  if #groups == 1 then
    local g = groups[1]
    for _, n in ipairs(g.names) do out[#out + 1] = P({ left = HALF, before = GAP }, xe.inl(n)) end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    lines[#lines + 1] = m.phone
    for _, l in ipairs(lines) do out[#out + 1] = P({ left = HALF + STEP }, xe.inl(l, { i = true })) end
  else
    -- typst grid(columns: (1fr, 1fr), column-gutter: 14pt): cells of 227 pt, the gutter a right margin of the left
    local cols = { { 4820, 280 }, { 4540, 0 } }
    local t = { '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblBorders>'
      .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
      .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
      .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
      .. '<w:tblGrid><w:gridCol w:w="4820"/><w:gridCol w:w="4540"/></w:tblGrid>' }
    for r = 1, #groups, 2 do
      t[#t + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      for ci = 1, 2 do
        local gi = r + ci - 1
        local body = groups[gi] and group_xml(gi, groups[gi]) or '<w:p/>'
        if r > 1 then body = body:gsub('w:before="0"', 'w:before="224"', 1) end   -- row-gutter 11.2 pt
        t[#t + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. cols[ci][1] .. '" w:type="dxa"/><w:tcMar><w:right w:w="'
          .. cols[ci][2] .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. body .. '</w:tc>'
      end
      t[#t + 1] = '</w:tr>'
    end
    t[#t + 1] = '</w:tbl>'
    out[#out + 1] = P({ line = 20, before = GAP })
    out[#out + 1] = xe.raw(table.concat(t))
  end
  if m.counsel_for then c(xe.inl(m.counsel_for), GAP) end
  out[#out + 1] = P({ line = 20, before = GAP })
  double_rule()
  return out
end

-- The signature block after the Conclusion (FRAP 32(d)) [signature-block]: not split, kept with the paragraph above.
local function signature_blocks(m)
  local sig = m.signature
  local out = {}
  local first = 392   -- 19.6 pt above the block
  if m.date then
    out[#out + 1] = P({ keep = true, before = first }, xe.runs('Dated: ') .. xe.inl(m.date))
    first = 224       -- 11.2 pt
  end
  out[#out + 1] = P({ keep = true, before = first, left = HALF }, xe.runs('Respectfully submitted,'))
  out[#out + 1] = P({ keep = true, before = 336, left = HALF }, xe.runs('/s/ ' .. plain(sig.signer)))
  local lines = sig.lines or {}
  out[#out + 1] = P({ keep = #lines > 0, left = HALF }, xe.runs(plain(sig.signer)))
  for i, l in ipairs(lines) do
    out[#out + 1] = P({ keep = i < #lines, left = HALF + STEP }, xe.inl(l, { i = true }))
  end
  return out
end

-- "/s/ Name" and the date, then "Signature" and "Date" (FRAP 25(d)) [form-sig-line]: 22.4 pt above.
local function form_sig(m)
  local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. SIGCOL .. '"/></w:tabs>'
  return {
    P({ keep = true, tabs = tabs, before = 448 }, xe.runs('/s/ ' .. plain(m.signature.signer)) .. TAB .. xe.inl(m.date or '')),
    P({ tabs = tabs }, xe.runs('Signature') .. TAB .. xe.runs('Date')),
  }
end

-- The designation (6 Cir. R. 28(b)(1)(A)(i), 30(g)(1)) [designation grid]: three columns, 1.5 in, 2.3 in and the
-- rest, 0.15 in apart (a right cell margin), 8.4 pt between rows; a row is never split across pages.
local function designation_table(m)
  local W = { { 2376, 216 }, { 3528, 216 }, { TEXTW - 2376 - 3528, 0 } }
  local function row(cells, before, bold)
    local x = { '<w:tr><w:trPr><w:cantSplit/></w:trPr>' }
    for i, v in ipairs(cells) do
      x[#x + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. W[i][1] .. '" w:type="dxa"/><w:tcMar><w:right w:w="' .. W[i][2]
        .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. p({ before = before }, xe.inl(v, { b = bold })) .. '</w:tc>'
    end
    x[#x + 1] = '</w:tr>'
    return table.concat(x)
  end
  local rows = { row({ 'Date Filed', 'R.No.; Page ID #', 'Description of Document' }, 0, true) }
  for _, d in ipairs(m.designation) do rows[#rows + 1] = row({ d.date, d.rno, d.description }, 168, false) end
  return xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. W[1][1] .. '"/><w:gridCol w:w="' .. W[2][1] .. '"/><w:gridCol w:w="' .. W[3][1]
    .. '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>')
end

function Pandoc(doc)
  local meta = doc.meta
  local auth = authorities_of(meta)

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
  -- the break rules of typst on the text pandoc writes itself (body, footnotes, quotations)
  blocks = pandoc.Pandoc(blocks):walk({ Inlines = inlines }).blocks

  -- The addendum (after "# Addendum") sits after the certificates and the designation.
  local main, add = pandoc.List(), nil
  for i, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 and plain(b.content):lower():match('^%s*addendum%s*$') then
      add = pandoc.List({ table.unpack(blocks, i + 1) })
      break
    end
    main:insert(b)
  end
  local words = source_words()
  if words > WORD_LIMIT then
    error('ca6-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(i) allows ' .. WORD_LIMIT)
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
  local h_oral = fixed('Statement in Support of Oral Argument', 'front')
  local body = body_items(main, true)
  local h_cert = fixed('Certificate of Compliance', 'body')
  local h_serv = fixed('Certificate of Service', 'body')
  local h_desig = fixed('Designation of District Court Record', 'body')
  local h_add = add and fixed('Addendum', 'body') or nil
  local addendum = add and body_items(add, false) or nil
  local has_serv = not meta.service or meta.service.certificate ~= false

  -- The TOC: the front matter's TOA and oral argument, the body's headings, then the certificates, the designation
  -- and the addendum (typst outlines every heading; the disclosure page and the TOC itself are not listed).
  local toc = { h_toa, h_oral }
  for _, it in ipairs(body) do if it.kind == 'head' and it.toc then toc[#toc + 1] = it end end
  toc[#toc + 1] = h_cert
  if has_serv then toc[#toc + 1] = h_serv end
  toc[#toc + 1] = h_desig
  if h_add then
    toc[#toc + 1] = h_add
    for _, it in ipairs(addendum) do if it.kind == 'head' and it.toc then toc[#toc + 1] = it end end
  end

  -- ---- the needles for fb render's page finder, in document order ----
  local function item_text(it)
    if not it then return '' end
    if it.kind == 'head' then return (it.label and (it.label .. ' ') or '') .. text_of(it.title) end
    return btext_of({ it })
  end
  local function head_need(e, after) need('h' .. e.id, 'B', item_text(e), after) end
  need('S:front', 'B', 'Circuit Rule 26.1 Disclosure Statement', plain(meta.disclosure or ''):sub(1, 40))
  local first_group = ''
  for _, g in ipairs(KINDS) do
    for _, key in ipairs(occ) do
      if first_group == '' and auth[key].kind == g[1] then first_group = g[2] .. ' Page(s)' end
    end
  end
  head_need(h_toa, first_group)
  head_need(h_oral, plain(meta.oral_argument or ''):sub(1, 40))
  local body_start = body[1] and body[1].kind == 'head' and ('h' .. body[1].id) or 'S:body'
  if body_start == 'S:body' then need('S:body', 'B', item_text(body[1]):sub(1, NEEDLE_MAX), '') end
  local function items_needles(items, first_block)
    for i, it in ipairs(items) do
      if it.kind == 'head' then head_need(it, item_text(items[i + 1]):sub(1, 40)) end
      for _, c in ipairs(cites[first_block + i - 1]) do need(c[1], c[2], c[3], c[4]) end
    end
  end
  items_needles(body, 1)
  head_need(h_cert, 'This brief complies with')
  if has_serv then head_need(h_serv, 'I certify that on') end
  head_need(h_desig, meta.designation_intro and plain(meta.designation_intro) or 'The appellant designates')
  if h_add then
    head_need(h_add, item_text(addendum[1]):sub(1, 40))
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
    if e.label then runs = xe.runs(e.label) .. TAB end
    runs = runs .. xe.inl(e.level == 1 and upper(e.title) or e.title) .. xe.runs(xe.LEAD) .. xe.runs(page_of('h' .. e.id))
    return P({ tabs = tabs, left = left, hanging = 720, right = TOC_COL }, runs)
  end

  -- ---- the TOA: the cited authorities, grouped and sorted; each one's pages, merged by page ----
  local function toa_pages(key)
    local seen, list = {}, {}
    for k, kk in ipairs(occ) do
      if kk == key then
        local pg = page_of('k' .. k)
        if not seen[pg] then
          seen[pg] = true
          list[#list + 1] = pg
        end
      end
    end
    if #list >= PASSIM then return xe.runs('passim', { i = true }), width_of('passim') end
    local s = table.concat(list, ', ')
    return xe.runs(s), width_of(s)
  end

  -- A section heading (level 1): bold capitals, 16 pt, centered, 21 / 15.4 pt; `top`: it opens a page (no space
  -- above it, as typst drops it there); `brk`: it starts a new page.
  local function section_head(title, top, brk)
    return P({ keep = true, brk = brk, before = top and 0 or 420, after = 308, jc = 'center' },
      xe.inl(upper(title), { b = true, sz = HEAD_SZ }))
  end

  local function toa_blocks()
    local out = { section_head(h_toa.title, true, true) }
    local first = true
    for _, g in ipairs(KINDS) do
      local members, seen = {}, {}
      for _, key in ipairs(occ) do
        if not seen[key] and auth[key].kind == g[1] then
          seen[key] = true
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
          if a.name then
            runs2 = xe.inl(a.name, { i = a.kind == 'case' }) .. xe.runs(',') .. xe.BR
          end
          local pages, w = toa_pages(key)
          runs2 = runs2 .. xe.inl(a.cite) .. xe.runs(xe.LEAD) .. pages
          out[#out + 1] = P({ tabs = xe.leader_tab(TEXTW), before = 196, left = 504, hanging = 504,
            right = math.max(TOA_COL, w) }, runs2)
        end
      end
    end
    return out
  end

  -- A heading of the body [style-heading].
  local function heading_block(e, top)
    if e.style == 'section' then return section_head(e.title, top) end
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

  -- ---- section 1: the cover (no page number) ----
  for _, b in ipairs(cover(meta)) do push(b) end
  push(section_break(nil, nil))

  -- ---- section 2: front matter, roman numerals from the disclosure page ----
  push(section_head(pandoc.Inlines({ pandoc.Str('Circuit Rule 26.1 Disclosure Statement') }), true))
  for _, b in ipairs(single_paras(meta.disclosure)) do push(b) end
  push(section_head(pandoc.Inlines({ pandoc.Str('Table of Contents') }), true, true))
  push(P({ before = 84, jc = 'right' }, xe.runs('Page', { b = true, u = true })))
  for _, e in ipairs(toc) do push(toc_row(e)) end
  for _, b in ipairs(toa_blocks()) do push(b) end
  push(section_head(h_oral.title, true, true))
  for _, b in ipairs(pandoc.Pandoc(meta.oral_argument):walk({ Inlines = inlines }).blocks) do push(b) end
  push(section_break('rIdCa6Page', 'lowerRoman'))

  -- ---- section 3: the body (arabic from 1), the certificates and the designation ----
  -- The last paragraph is kept with the signature block (typst sets them in one unbreakable block).
  local last = body[#body]
  if last and last.t == 'Para' then body[#body] = pandoc.Div({ last }, pandoc.Attr('', {}, { ['custom-style'] = 'CA Body Keep' })) end
  for i, it in ipairs(body) do
    if it.kind == 'head' then push(heading_block(it, i == 1)) else push(it) end
  end
  for _, b in ipairs(signature_blocks(meta)) do push(b) end

  push(section_head(h_cert.title, true, true))
  push(P({ before = 280 }, xe.runs('This brief complies with: (1) the type-volume limitation of Federal Rule of Appellate Procedure 32(a)(7)(B) because it contains ' ..
    group_digits(words) .. ' words, excluding the parts of the brief exempted by Rule 32(f); and (2) the typeface requirements of Rule 32(a)(5) and the type style requirements of Rule 32(a)(6) because it has been prepared in a proportionally spaced typeface (14')
    .. NBH .. xe.runs('point ' .. FACE .. '). The word count is computed from the markdown source of this brief.')))
  for _, b in ipairs(form_sig(meta)) do push(b) end

  if has_serv then
    push(section_head(h_serv.title, true, true))
    push(P({ before = 280 }, xe.runs('I certify that on ') .. xe.inl(meta.date) .. xe.runs(', this brief was served via CM/ECF on all registered counsel and transmitted to the Clerk of the Court.')))
    for _, b in ipairs(form_sig(meta)) do push(b) end
  end

  push(section_head(h_desig.title, true, true))
  for _, b in ipairs(single_paras({ pandoc.Para(meta.designation_intro or { pandoc.Str('The appellant designates the following filings from the District Court\'s electronic records under Sixth Circuit Rules 28(b)(1)(A)(i) and 30(g)(1):') }) })) do push(b) end
  push(P({ line = 20, before = 260 }))
  push(designation_table(meta))

  if add then
    push(section_break('rIdCa6Page', 'decimal'))
    push(section_head(h_add.title, true))
    for _, it in ipairs(addendum) do
      if it.kind == 'head' then push(heading_block(it)) else push(it) end
    end
  end

  -- Pandoc would print the date metadata as a title block at the top of the first page; the date is in the
  -- signature and the certificate of service already.
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
