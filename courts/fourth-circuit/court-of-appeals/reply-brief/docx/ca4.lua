-- Fourth Circuit brief, docx engine (pandoc Lua filter; see ../README.md, "Engines" and docs/DOCX.md): the markdown
-- contract -> a Word document on docx/reference.xml. The cover, the disclosure statement, the table of contents, the
-- table of authorities, the signature block and the certificates are written here as paragraphs in the "CA ..."
-- styles (raw WordprocessingML, one paragraph per call to P); the body keeps its markdown structure. Headings get
-- their labels (I. A. 1. a.) as text, with a tab.
-- Sections (cover and disclosure: no number; front matter: lower roman; body: arabic from 1) are section breaks
-- naming the footers this filter gives fb render (FORMBOOK_FOOTERS: rIdRomanFtr, rIdArabicFtr, a centered PAGE
-- field); the last section goes to FORMBOOK_FINAL. The TOC and TOA page numbers: fb render (tools/fb/src/docxpass.rs)
-- renders the document once, finds the page of every heading and citation in that PDF (the needles this filter
-- writes to FORMBOOK_NEEDLES), and renders again with those pages (FORMBOOK_PAGES) until they settle; the headings a
-- pass left at the foot of a page are kept in FORMBOOK_STATE (fb-595.68.4: were docx/render.sh and docx/pagemap.awk).
-- The cross-engine layout model (lib/docx/xengine.lua): exact line boxes of the typst pitches, typst's break rules on
-- every run. This file is identical in the three doc-type folders except for DOCTYPE below.

local DOCTYPE = 'reply-brief'

local CFG = ({
  ['opening-brief'] = {
    numbering = 'all',       -- sub-headings numbered everywhere (I. / A. / 1. / a. in the Argument, A. / 1. / a. elsewhere)
    base = 1,                -- heading label indent = (level - base) half inches
    point_centered = false,
    big_h1 = false,          -- section headings at body size
    limit = 13000,           -- FRAP 32(a)(7)(B)(i)
    limit_name = 'FRAP 32(a)(7)(B)(i)',
    count = 'request',       -- the request for oral argument is not counted (FRAP 32(f)): it is the last section
    toc_front = true,        -- the table of authorities and the certificates are listed in the contents
    toa_above = 140,         -- space above each authority, twips (typst: 0.5em)
    sig = 'opening',
    cert = 'opening',
    service_default = true,  -- the certificate of service is shown unless the frontmatter says otherwise
  },
  ['answering-brief'] = {
    numbering = 'argument',  -- only the Argument's sub-headings are numbered
    base = 2,
    point_centered = true,
    big_h1 = true,
    limit = 13000,
    limit_name = 'FRAP 32(a)(7)(B)(i)',
    count = 'all',
    toc_front = false,
    toa_above = 196,
    sig = 'answering',
    cert = 'answering',
    service_default = false,
  },
  ['reply-brief'] = {
    numbering = 'all',
    base = 1,
    point_centered = false,
    big_h1 = true,
    limit = 6500,            -- CA4-LEN-001: half the principal-brief limit
    limit_name = 'FRAP 32(a)(7)(B)(ii)',
    count = 'addendum',      -- the addendum is not part of the reply (FRAP 28(f))
    toc_front = true,
    toa_above = 196,
    sig = 'reply',
    cert = 'reply',
    service_default = false,
  },
})[DOCTYPE]

local TOA_GROUPS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}

local xe = require('docx.xengine')
-- Before the page number of a table row: three no-break spaces, so the leader is never shorter than that and the last
-- word takes them along when it wraps (typst listing-row: h(0.75em)). LibreOffice keeps about 4.5 pt more on the last
-- line of a row whose tab runs past the right indent (measured: the same threshold for a one- and a three-digit page),
-- so the three spaces are set in 8 pt (2 pt each, 6 pt in all: 10.5 less 4.5) and the row wraps where typst's does.
local LEAD = pandoc.RawInline('openxml',
  '<w:r><w:rPr><w:sz w:val="16"/><w:szCs w:val="16"/></w:rPr><w:t xml:space="preserve">\u{00A0}\u{00A0}\u{00A0}</w:t></w:r>')
local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')
local LB = pandoc.LineBreak()
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="rIdRomanFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
-- the footers (centered PAGE field) and the body's section (arabic from 1), which name them
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT_BODY = '<w:sectPr><w:footerReference w:type="default" r:id="rIdArabicFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function fail(msg) error('ca4-brief: ' .. msg, 0) end

local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  if type(v) == 'boolean' then return tostring(v) end
  return pandoc.utils.stringify(v)
end

-- a metadata value as inlines
local function minl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == 'string' then return pandoc.Inlines({ pandoc.Str(v) }) end
  if v.t == nil then return pandoc.Inlines(v) end
  return pandoc.Inlines(pandoc.utils.stringify(v))
end

local function items(v)
  local out = {}
  if v ~= nil then for _, x in ipairs(v) do out[#out + 1] = x end end
  return out
end

local function need(meta, k)
  if meta[k] == nil then fail('missing required metadata field `' .. k .. '`') end
  return meta[k]
end

local function upper_il(il)
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(e.text:upper()) end }).content
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

-- inline content as WordprocessingML runs (emphasis, strong, underline, line breaks, raw openxml)
local function xesc(s) return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')) end
local function run(text, f)
  local rpr = (f.b and '<w:b/>' or '') .. (f.i and '<w:i/>' or '') .. (f.u and '<w:u w:val="single"/>' or '')
    .. (f.box and '<w:bdr w:val="single" w:sz="6" w:space="0" w:color="000000"/>' or '')
  if rpr ~= '' then rpr = '<w:rPr>' .. rpr .. '</w:rPr>' end
  -- a hyphen before a digit does not end a line ("ER-178-82"; Unicode line breaking, as typst breaks)
  local t = xesc(text):gsub('%-(%d)', '</w:t></w:r><w:r>' .. rpr .. '<w:noBreakHyphen/></w:r><w:r>' .. rpr
    .. '<w:t xml:space="preserve">%1')
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. t .. '</w:t></w:r>'
end
local function inl_xml(il, f, out)
  for _, el in ipairs(il) do
    local t = el.t
    if t == 'Str' then out[#out + 1] = run(el.text, f)
    elseif t == 'Space' or t == 'SoftBreak' then out[#out + 1] = run(' ', f)
    elseif t == 'LineBreak' then out[#out + 1] = '<w:r><w:br/></w:r>'
    elseif t == 'Emph' then inl_xml(el.content, { b = f.b, i = true, u = f.u }, out)
    elseif t == 'Strong' then inl_xml(el.content, { b = true, i = f.i, u = f.u }, out)
    elseif t == 'Underline' then inl_xml(el.content, { b = f.b, i = f.i, u = true }, out)
    elseif t == 'Span' then
      inl_xml(el.content, { b = f.b, i = f.i, u = f.u, box = el.classes:includes('box') }, out)
    elseif t == 'Link' or t == 'SmallCaps' then inl_xml(el.content, f, out)
    elseif t == 'Quoted' then
      local q = el.quotetype == 'DoubleQuote' and { '\u{201C}', '\u{201D}' } or { '\u{2018}', '\u{2019}' }
      out[#out + 1] = run(q[1], f); inl_xml(el.content, f, out); out[#out + 1] = run(q[2], f)
    elseif t == 'RawInline' then
      if el.format == 'openxml' then out[#out + 1] = el.text end
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
end

-- one paragraph as WordprocessingML: style, inlines, optional extra pPr elements in schema order
local function P_xml(style, il, extra)
  local out = {}
  inl_xml(xe.inlines(pandoc.Inlines(il)), {}, out)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or '') .. '</w:pPr>' .. table.concat(out) .. '</w:p>'
end
local function P(style, il, extra) return pandoc.RawBlock('openxml', P_xml(style, il, extra)) end
local function raw_p(xml) return pandoc.RawBlock('openxml', xml) end
local KEEP = '<w:keepNext/>'
local function sp(before, after) return xe.spacing(before, after, 320) end
-- the empty paragraph that ends a section takes no room (it would push a full page's last line on)
local SECT_LINE = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
local BREAK_BEFORE = '<w:pageBreakBefore/>'
-- a section heading that opens a page has no space above it (typst drops it at the top of a page; Word keeps it
-- after a section or page break)
local TOP = sp(0, 308)

local function rule(style) return raw_p('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>') end
local function gap(twips)
  return raw_p('<w:p><w:pPr><w:pStyle w:val="CAGap"/><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return (out:gsub('^,', ''))
end

local function roman(n)
  local vals = { { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }
  local out = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- needles and pages (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60   -- a needle is a prefix of the text (letters and digits only)
local PASSIM = 7        -- an authority cited on this many pages or more is "passim"

-- letters and digits only, lower case: fb render normalizes the PDF text the same way
local function norm(s)
  return (s:lower():gsub('[^a-z0-9]', ''))
end

-- a needle: { id, kind, needle, fallback }; kind B (body, in document order: moves the search on) or N (inside a
-- footnote, or the first words after a heading: searched from the page the body has reached, moves nothing)
local needles = {}
local function need_at(id, kind, text, context)
  local short = norm(text):sub(1, NEEDLE_MAX)
  local long = norm(text .. ' ' .. (context or '')):sub(1, NEEDLE_MAX)
  if short == '' then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- the text a block starts with, up to its first footnote (the PDF has only the footnote's number there)
local function lead_text(b)
  while (b.t == 'BlockQuote' or b.t == 'Div') and b.content[1] ~= nil do b = b.content[1] end
  if (b.t == 'BulletList' or b.t == 'OrderedList') and b.content[1] ~= nil and b.content[1][1] ~= nil then
    return lead_text(b.content[1][1])
  end
  local s = plain(pandoc.Pandoc({ b }):walk({ Note = function() return pandoc.Str('\1') end }).blocks)
  return s:match('^[^\1]*')
end

-- the pages of the previous pass: id -> printed page, and id -> physical page; empty on the first pass
local labels, pages = {}, {}
local have_pages = false
local function load_pages()
  local path = os.getenv('FORMBOOK_PAGES')
  if not path or path == '' then return end
  local f = io.open(path, 'r')
  if not f then return end
  have_pages = true
  for line in f:lines() do
    local id, page, lab = line:match('^([^\t]+)\t([^\t]*)\t(.*)$')
    if id then labels[id] = lab; pages[id] = tonumber(page) end
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

-- The headings a pass left at the foot of a page (the block after it, or the heading after it, is on a later page):
-- typst would have moved each to the next page with what follows (a sticky heading), so the following passes break
-- the page before it. Once moved it no longer ends a page, so the set only grows over the passes of one render
-- (FORMBOOK_STATE, empty on the first pass: fb render's docxpass.rs).
local sticky = {}
local function load_sticky()
  if not have_pages then return end
  local path = os.getenv('FORMBOOK_STATE')
  local f = path and path ~= '' and io.open(path, 'r')
  if not f then return end
  for line in f:lines() do
    local idx = line:match('^E\t(%d+)$')
    if idx then sticky[tonumber(idx)] = true end
  end
  f:close()
end
-- heading idx ends its page in the previous pass: `after` is the needle of what follows it
local function ends_page(idx, after)
  local here, there = pages['H:' .. idx], pages[after]
  return here ~= nil and there ~= nil and there > here
end
local function save_sticky()
  local ids = {}
  for idx in pairs(sticky) do ids[#ids + 1] = idx end
  table.sort(ids)
  local lines = {}
  for _, idx in ipairs(ids) do lines[#lines + 1] = 'E\t' .. idx .. '\n' end
  write_file('FORMBOOK_STATE', table.concat(lines))
end

local function folio_il(v)
  if v == 'passim' then return { pandoc.Emph({ pandoc.Str('passim') }) } end
  return { pandoc.Str(v) }
end

-- ---------------------------------------------------------------------------
-- cover (FRAP 32(a)(2); typst cover-body)
-- ---------------------------------------------------------------------------

-- The counsel columns: typst's grid, two halves of the text width less a 1.5 em (21 pt) gutter, the gutter a right
-- margin of the left cell.
local function grid(rows)
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4890"/><w:gridCol w:w="4470"/></w:tblGrid>' }
  local cols = { { 4890, 420 }, { 4470, 0 } }
  for _, row in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for c = 1, 2 do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. cols[c][1] .. '" w:type="dxa"/><w:tcMar><w:right w:w="'
        .. cols[c][2] .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. (row[c] or '<w:p/>') .. '</w:tc>'
    end
    out[#out + 1] = '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return raw_p(table.concat(out))
end

local function cover(meta)
  local B = {}
  local function add(b) B[#B + 1] = b end
  add(gap(160))
  add(P('CACentered', { pandoc.Strong(cat('No. ', minl(need(meta, 'case_number')))) }))
  add(gap(200))
  add(rule('CADoubleRule'))
  add(gap(160))
  if DOCTYPE == 'opening-brief' then
    add(P('CACentered', { pandoc.Strong({ pandoc.Str('IN THE'), LB, pandoc.Str('UNITED STATES COURT OF APPEALS'), LB,
      pandoc.Str('FOR THE FOURTH CIRCUIT') }) }))
  else
    add(P('CACentered', { pandoc.Strong({ pandoc.Str('IN THE UNITED STATES COURT OF APPEALS'), LB,
      pandoc.Str('FOR THE FOURTH CIRCUIT') }) }))
  end
  add(gap(200))
  add(rule('CARule'))
  add(gap(200))
  local sides = need(meta, 'caption')
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(P('CACentered', minl(name))) end
    add(P('CACaption', minl(side.designation)))
    if i < #sides then add(P('CACentered', { pandoc.Str('v.') })) end
  end
  add(gap(200))
  add(rule('CARule'))
  add(gap(200))
  add(P('CACentered', minl(need(meta, 'proceeding'))))
  if DOCTYPE == 'answering-brief' and meta.judge ~= nil then add(P('CACentered', minl(meta.judge))) end
  if DOCTYPE == 'reply-brief' and (meta.district_court_case ~= nil or meta.judge ~= nil) then
    local il = pandoc.Inlines({})
    if meta.district_court_case ~= nil then il:extend(cat('Case No. ', minl(meta.district_court_case))) end
    if meta.district_court_case ~= nil and meta.judge ~= nil then il:insert(pandoc.Str(', ')) end
    if meta.judge ~= nil then il:extend(minl(meta.judge)) end
    add(P('CACentered', il))
  end
  add(gap(200))
  add(rule('CARule'))
  add(gap(200))
  add(P('CACentered', { pandoc.Strong(upper_il(minl(need(meta, 'brief_title')))) }))
  add(gap(200))
  add(rule('CARule'))
  add(gap(200))
  -- counsel (FRAP 32(a)(2)(F)): name, office address, telephone number. Opening brief: two or more groups side by side
  -- in two columns; otherwise in the right half of the page.
  local groups = need(meta, 'counsel')
  local function lines_of(gi, g)
    local ls = {}
    for _, n in ipairs(g.names) do ls[#ls + 1] = minl(n) end
    for _, l in ipairs(g.lines or {}) do ls[#ls + 1] = minl(l) end
    if DOCTYPE ~= 'opening-brief' and gi == #groups and meta.phone ~= nil then ls[#ls + 1] = minl(meta.phone) end
    return ls
  end
  if DOCTYPE == 'opening-brief' and #groups > 1 then
    local function cell(gi)
      local x = {}
      for _, l in ipairs(lines_of(gi, groups[gi])) do x[#x + 1] = P_xml('CACounsel', l, KEEP) end
      return table.concat(x)
    end
    local rows = {}
    for r = 1, #groups, 2 do
      rows[#rows + 1] = { cell(r), groups[r + 1] and cell(r + 1) or nil }
    end
    add(grid(rows))
  else
    for gi, g in ipairs(groups) do
      if gi > 1 then add(gap(140)) end
      for _, l in ipairs(lines_of(gi, g)) do add(P('CASignature', l)) end
    end
  end
  if DOCTYPE == 'answering-brief' then
    add(gap(200))
    add(P('CACounsel', cat(minl(need(meta, 'date')), TAB, minl(need(meta, 'party_line'))),
      '<w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs>'))
  end
  add(gap(200))
  add(rule('CADoubleRule'))
  return B
end

-- ---------------------------------------------------------------------------
-- disclosure statement (FRAP 26.1; answering brief)
-- ---------------------------------------------------------------------------

local DISCLOSURE_QUESTIONS = {
  'Is party/amicus a publicly held corporation or other publicly held entity?',
  'Does party/amicus have any parent corporations?',
  'Is 10% or more of the stock of a party/amicus owned by a publicly held corporation or other publicly held entity?',
  'Is there any other publicly held corporation or other publicly held entity that has a direct financial interest in the outcome of the litigation?',
  'Is party a trade association? (amici curiae do not complete this question)',
  'Does this case arise out of a bankruptcy proceeding?',
  'Is this a criminal case in which there was an organizational victim?',
}

-- a ruled box around a literal X, or around a no-break space of its width when not checked (typst checkbox)
local function box(checked)
  return pandoc.Span({ pandoc.Str(checked and 'X' or '\u{2007}') }, pandoc.Attr('', { 'box' }))
end

local function disclosure(meta)
  local d = meta.disclosure
  local answers = items(d.answers)
  if #answers ~= #DISCLOSURE_QUESTIONS then
    fail('disclosure.answers needs one yes or no for each of the ' .. #DISCLOSURE_QUESTIONS .. ' questions')
  end
  local B = {}
  local function add(b) B[#B + 1] = b end
  add(P('CACentered', { pandoc.Strong({ pandoc.Str('UNITED STATES COURT OF APPEALS FOR THE FOURTH CIRCUIT') }) }, sp(0, 168)))
  add(P('CACentered', { pandoc.Strong({ pandoc.Str('DISCLOSURE STATEMENT') }) }, sp(0, 168)))
  add(P('CACentered', cat('No. ', minl(meta.case_number)), sp(0, 280)))
  add(P('CACounsel', cat('Pursuant to FRAP 26.1 and Local Rule 26.1, ', minl(d.party), ', who is ', minl(d.role),
    ', makes the following disclosure:')))
  for i, q in ipairs(DISCLOSURE_QUESTIONS) do
    local a = answers[i] == false and 'no' or answers[i] == true and 'yes' or plain(answers[i])
    if a ~= 'yes' and a ~= 'no' then fail('disclosure answer ' .. i .. ' must be `yes` or `no`') end
    add(P('CACounsel', cat(tostring(i) .. '. ' .. q), KEEP .. '<w:keepLines/>' .. sp(252, 0)))
    -- typst: YES, a space and h(0.4em) (9.1 pt), the box, a space and h(2.4em) (37.1 pt), NO, 9.1 pt, the box; Word has
    -- no fixed space, so a no-break space (0.25 em) in a size that gives that width (36 pt: 9 pt; 148.5 pt: 37.1 pt)
    local function gap(halfpts)
      return pandoc.RawInline('openxml', '<w:r><w:rPr><w:sz w:val="' .. halfpts .. '"/><w:szCs w:val="' .. halfpts
        .. '"/></w:rPr><w:t xml:space="preserve">\u{00A0}</w:t></w:r>')
    end
    add(P('CACounsel', cat('YES', gap(72), box(a == 'yes'), gap(297), 'NO', gap(72), box(a == 'no')),
      '<w:keepLines/>' .. sp(0, 0) .. '<w:ind w:left="448" w:firstLine="0"/>'))
  end
  add(P('CASignature', cat('/s/ ', minl(d.signer)), sp(448, 0)))
  add(P('CASignature', minl(d.date)))
  return B
end

-- ---------------------------------------------------------------------------
-- signature and certificates
-- ---------------------------------------------------------------------------

-- the signature block (typst signature-block): 19.6 pt above; in the right half "Respectfully submitted," then 16.8 pt
-- and the signature; the date at the margin 11.2 pt below
local function signature(meta)
  local sig = need(meta, 'signature')
  local B = {}
  B[#B + 1] = P('CASigHead', { pandoc.Str('Respectfully submitted,') }, KEEP)
  if CFG.sig == 'answering' then
    for i, l in ipairs(items(sig.lead)) do B[#B + 1] = P('CASignature', minl(l), KEEP .. (i == 1 and sp(336, 0) or '')) end
    B[#B + 1] = P('CASignature', cat('/s/ ', minl(sig.signer)), KEEP .. sp(168, 0))
    for _, l in ipairs(items(sig.lines)) do B[#B + 1] = P('CASignature', minl(l), KEEP) end
    return B
  end
  local slash = CFG.sig == 'reply' and 's/ ' or '/s/ '
  B[#B + 1] = P('CASignature', cat(slash, minl(sig.signer)), KEEP .. sp(336, 0))
  B[#B + 1] = P('CASignature', { pandoc.Str(plain(sig.signer):upper()) }, KEEP)
  for _, l in ipairs(items(sig.lines)) do
    B[#B + 1] = P('CASignature', { pandoc.Emph(minl(l)) }, KEEP .. '<w:ind w:left="4820" w:firstLine="0"/>')
  end
  if meta.date ~= nil then
    B[#B + 1] = P('CASignature', minl(meta.date), sp(224, 0) .. '<w:ind w:left="0" w:firstLine="0"/>')
  end
  return B
end

-- /s/ and the signer's name in the right half, 22.4 pt below the text (typst signature-only)
local function signature_only(meta)
  return { P('CASignature', cat('/s/ ', minl(meta.signature.signer)), sp(448, 0)) }
end

-- the signature of a certificate (opening brief): /s/, the name and the first title line at the margin, 22.4 pt below
local function certificate_signature(meta)
  local sig = meta.signature
  local B = {
    P('CACounsel', cat('/s/ ', minl(sig.signer)), KEEP .. sp(448, 0)),
    P('CACounsel', { pandoc.Str(plain(sig.signer):upper()) }, KEEP),
  }
  local first = items(sig.lines)[1]
  if first ~= nil then B[#B + 1] = P('CACounsel', { pandoc.Emph(minl(first)) }) end
  return B
end

-- Form 6 signature line (reply brief): "s/ Name" over "Signature", the date over "Date"; the right column starts
-- (text width + 1 em) / 2 in (typst grid), 22.4 pt below the text
local function form_signature(meta)
  local tabs = '<w:tabs><w:tab w:val="left" w:pos="4820"/></w:tabs>'
  return {
    P('CACounsel', cat('s/ ', minl(meta.signature.signer), TAB, minl(meta.date)), KEEP .. tabs .. sp(448, 0)),
    P('CACounsel', cat('Signature', TAB, 'Date'), tabs),
  }
end

local function section_head(title, extra)
  return P(CFG.big_h1 and 'CASectionBig' or 'CASection', { pandoc.Str(title) }, extra)
end

local function certificate_compliance(meta, words, out)
  out[#out + 1] = section_head('Certificate of Compliance', BREAK_BEFORE .. TOP)
  local function add_all(bs) for _, b in ipairs(bs) do out[#out + 1] = b end end
  if CFG.cert == 'opening' then
    out[#out + 1] = P('CACertificate', { pandoc.Str('Pursuant to Federal Rule of Appellate Procedure 32(a)(7)(B), I certify that this brief is proportionately spaced and contains '
      .. group_digits(words) .. ' words excluding parts of the document exempted by Rule 32(f).') }, sp(0, 0))
    add_all(certificate_signature(meta))
  elseif CFG.cert == 'answering' then
    out[#out + 1] = P('CACertificate', { pandoc.Str('1.'), pandoc.RawInline('openxml', '<w:r><w:t xml:space="preserve">\u{2002}</w:t></w:r>'),
      pandoc.Str('This brief complies with the type-volume limitation of Federal Rule of Appellate Procedure 32(a)(7)(B) because this brief contains '
      .. group_digits(words) .. ' words, excluding the parts of the brief exempted by Rule 32(f).') }, sp(0, 280))
    out[#out + 1] = P('CACertificate', { pandoc.Str('2.'), pandoc.RawInline('openxml', '<w:r><w:t xml:space="preserve">\u{2002}</w:t></w:r>'),
      pandoc.Str('This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and the type style requirements of Rule 32(a)(6) because this brief has been prepared in a proportionally spaced typeface, Times New Roman, in fourteen-point type.') }, sp(0, 0))
    add_all(signature_only(meta))
  else
    out[#out + 1] = P('CACertificate', cat('I, ', minl(meta.signature.signer), ', counsel for ',
      minl(meta['counsel-for'] or 'the party'),
      ' and a member of the bar of this Court, certify that the attached reply brief is proportionally spaced, has a typeface of 14 points, and contains '
      .. group_digits(words) .. ' words as calculated pursuant to Fed. R. App. P. 32(f) and 32(a)(7)(B)(ii).'), sp(0, 0))
    add_all(form_signature(meta))
  end
end

local function certificate_service(meta, out)
  local function add_all(bs) for _, b in ipairs(bs) do out[#out + 1] = b end end
  if CFG.cert == 'answering' then
    out[#out + 1] = section_head('Certificate of Service', sp(448, 308))
    out[#out + 1] = P('CACertificate', cat('I hereby certify that on this ', minl(meta.service.date), ', the foregoing ',
      minl(meta.brief_title), ' was served on ', minl(meta.service.served_on), '.'), sp(0, 0))
    add_all(signature_only(meta))
    return
  end
  out[#out + 1] = section_head('Certificate of Service', BREAK_BEFORE .. TOP)
  if CFG.cert == 'opening' then
    out[#out + 1] = P('CACertificate', cat('I certify that on ', minl(meta.date), ', the ', minl(meta.brief_title),
      ' was served on all parties or their counsel of record through the CM/ECF system.'), sp(0, 0))
    add_all(certificate_signature(meta))
  else
    out[#out + 1] = P('CACertificate', { pandoc.Str('I hereby certify that I electronically filed the foregoing document on this date with the Clerk of the Court for the United States Court of Appeals for the Fourth Circuit using the CM/ECF system, which will send notice of this filing to all registered CM/ECF users.') }, sp(0, 280))
    local unreg = items(meta.service and meta.service.unregistered)
    if #unreg > 0 then
      out[#out + 1] = P('CACertificate', { pandoc.Strong({ pandoc.Str('Service on Participants Who Are NOT Registered for Electronic Filing:') }) }, sp(0, 280))
      out[#out + 1] = P('CACertificate', { pandoc.Str('I certify that I served the foregoing document on this date by hand delivery, mail, third-party commercial carrier, or email, as indicated, to the following unregistered participants (name and address of each):') }, sp(0, 0))
      for _, u in ipairs(unreg) do
        out[#out + 1] = P('CACounsel', cat(minl(u.name), ', ', minl(u.address)), '<w:keepLines/>' .. sp(196, 0) .. '<w:ind w:left="720" w:firstLine="0"/>')
      end
    end
    add_all(form_signature(meta))
  end
end

-- ---------------------------------------------------------------------------
-- words (FRAP 32(a)(7)(B), 32(f)): the typst count, block by block, footnotes included
-- ---------------------------------------------------------------------------

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
-- the filter
-- ---------------------------------------------------------------------------

local function is_h1(b, name)
  return b.t == 'Header' and b.level == 1 and plain(b.content):lower():match('^%s*(.-)%s*$') == name
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ 'case_number', 'caption', 'proceeding', 'brief_title', 'counsel', 'signature' }) do need(meta, k) end
  local auth = meta.authorities or {}

  load_pages()
  load_sticky()

  -- every toa: citation in document order, per top-level block, for a needle: the link text and the words after it
  -- in its paragraph (up to a footnote mark or a quotation). Kind B (body) moves the search on; N (in a footnote) is
  -- searched from the page the body has reached.
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

  -- split the body: the addendum (reply) follows the certificates
  local body, addendum = {}, {}
  local split = false
  for _, b in ipairs(doc.blocks) do
    if CFG.count == 'addendum' and is_h1(b, 'addendum') then split = true end
    if split then addendum[#addendum + 1] = b else body[#body + 1] = b end
  end
  -- the citations of each body block, and which blocks are headings (in the order headings() numbers them)
  local cites, is_head = {}, {}
  for bi, b in ipairs(body) do
    cites[bi] = {}
    scan_blocks({ b }, 'B', cites[bi])
    is_head[bi] = b.t == 'Header'
  end
  local raw_body = body

  -- citations: every toa: link needs an authority; the link keeps its text
  local hits = {}
  local function unlink(blocks)
    return pandoc.Pandoc(blocks):walk({
      Link = function(el)
        local key = el.target:match('^toa:(.+)$')
        if not key then return nil end
        if auth[key] == nil then fail('link `toa:' .. key .. '` has no entry under `authorities:`') end
        hits[key] = true
        return el.content
      end,
    }).blocks
  end
  body = unlink(body)
  addendum = unlink(addendum)

  -- length: the words of the body; the request for oral argument is excluded (FRAP 32(f))
  local counted = {}
  local stop = false
  for _, b in ipairs(body) do
    if CFG.count == 'request' and is_h1(b, 'request for oral argument') then stop = true end
    if not stop then counted[#counted + 1] = b end
  end
  local words = count_blocks(counted)
  if words > CFG.limit then fail('the brief has ' .. words .. ' words; ' .. CFG.limit_name .. ' allows ' .. CFG.limit) end

  -- the break rules of typst on the text pandoc writes itself (body, footnotes); lists as List Item paragraphs
  local function prepare(blocks)
    local out = {}
    for _, b in ipairs(pandoc.Pandoc(blocks):walk({ Inlines = xe.inlines }).blocks) do
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    end
    return out
  end
  body = prepare(body)
  addendum = prepare(addendum)

  -- headings, numbered as in typst
  local heads = {}
  local counters = { 0, 0, 0, 0, 0, 0 }
  local in_arg, in_add = false, false
  local function label_for(level, n)
    if in_arg or CFG.numbering == 'argument' then
      if level == 2 then return roman(n) .. '.' end
      if level == 3 then return string.char(64 + n) .. '.' end
      if level == 4 then return tostring(n) .. '.' end
      if level == 5 then return string.char(96 + n) .. '.' end
    else
      if level == 2 then return string.char(64 + n) .. '.' end
      if level == 3 then return tostring(n) .. '.' end
      if level == 4 then return string.char(96 + n) .. '.' end
      if level == 5 then return '(' .. n .. ')' end
    end
    fail('headings deeper than level 5 are not supported')
  end
  local function headings(blocks, first_top)
    local out = {}
    -- a heading a pass left at the foot of a page (sticky) takes the headings right before it along: the break goes
    -- before the first of them
    local brk = {}
    do
      local idx, start = #heads, nil
      for bi, b in ipairs(blocks) do
        if b.t == 'Header' then
          idx = idx + 1
          if bi == 1 or blocks[bi - 1].t ~= 'Header' then start = idx end
          local nb = blocks[bi + 1]
          if nb ~= nil and ends_page(idx, nb.t == 'Header' and ('H:' .. (idx + 1)) or ('X:' .. idx)) then
            sticky[idx] = true
          end
          if sticky[idx] then brk[start] = true end
        end
      end
    end
    for bi, b in ipairs(blocks) do
      if b.t == 'Header' then
        local text = plain(b.content)
        if b.level == 1 then
          in_arg = text:lower():match('^%s*argument%s*$') ~= nil
          in_add = in_add or text:lower():match('^%s*addendum%s*$') ~= nil
          counters = { 0, 0, 0, 0, 0, 0 }
        end
        counters[b.level] = counters[b.level] + 1
        for i = b.level + 1, 6 do counters[i] = 0 end
        local h = { level = b.level, title = b.content, idx = #heads + 1, label = '', addendum = in_add, toc = true }
        -- No keep-with-next: LibreOffice moves a heading that has it to the next page whenever the paragraph after it
        -- must be split, where typst splits it. typst's sticky heading instead: a heading the first pass left at the
        -- foot of a page (page map E) opens the next page, with no space above it.
        local function moved(after) return brk[h.idx] and (BREAK_BEFORE .. sp(0, after)) or nil end
        if b.level == 1 then
          h.steps = 0
          local top = (#out == 0 and first_top) and TOP or moved(308)
          out[#out + 1] = P(CFG.big_h1 and 'CASectionBig' or 'CASection', b.content, top)
        elseif in_add or (CFG.numbering == 'argument' and not in_arg) then
          -- unnumbered sub-heading: bold at the margin; its contents row steps in as typst's
          h.steps = in_add and (b.level - 2) or (b.level - 1)
          h.unnumbered = true
          h.toc = not in_add or b.level == 2
          out[#out + 1] = P('CAUnnum', b.content, moved(252))
        else
          h.label = label_for(b.level, counters[b.level])
          if b.level == 2 and CFG.point_centered and in_arg then
            h.steps = 0
            out[#out + 1] = P('CAPoint', cat(h.label, ' ', b.content), moved(280))
          else
            h.steps = b.level - CFG.base
            out[#out + 1] = P('CAHeadL' .. b.level .. 'S' .. h.steps, cat(h.label, TAB, b.content), moved(252))
          end
        end
        -- the heading as printed, for its needle
        h.text = h.label ~= '' and (h.label .. ' ' .. text) or text
        heads[#heads + 1] = h
      else
        out[#out + 1] = b
      end
    end
    return out
  end
  body = headings(body, true)

  -- the last paragraph stays with the signature block (typst keeps them together)
  if #body > 0 and body[#body].t == 'Para' then
    body[#body] = pandoc.Div({ body[#body] }, pandoc.Attr('', {}, { ['custom-style'] = 'CA Body Last' }))
  end

  local show_service = CFG.service_default
  if meta.service ~= nil and meta.service.certificate ~= nil then show_service = meta.service.certificate == true end

  -- the addendum's headings (reply): its own page numbers, Add-1 ...
  local add_blocks = {}
  if #addendum > 0 then add_blocks = headings(addendum, true) end

  -- the needles, in document order: the contents and authorities headings (the latter with its first group's head,
  -- so the contents' "TABLE OF AUTHORITIES" row is not taken for it); the body's headings, each followed (kind N) by
  -- the first words of the block after it, for a sticky heading, and the citations; then the certificates
  local toa_first = ''
  for _, g in ipairs(TOA_GROUPS) do
    for key, a in pairs(auth) do
      if toa_first == '' and plain(a.kind) == g[1] and hits[key] then toa_first = g[2] end
    end
  end
  local toa = norm('Table of Authorities' .. toa_first)
  needles[#needles + 1] = { id = 'S:toc', kind = 'B', needle = norm('Table of Contents Page'), fallback = norm('Table of Contents') }
  needles[#needles + 1] = { id = 'S:toa', kind = 'B', needle = toa, fallback = toa }
  local occurrences = {}
  local body_id = 'H:1'
  local hk = 0
  for bi, b in ipairs(raw_body) do
    if is_head[bi] then
      hk = hk + 1
      local nb = raw_body[bi + 1]
      local after = ''
      if nb ~= nil then after = nb.t == 'Header' and heads[hk + 1].text or lead_text(nb) end
      need_at('H:' .. hk, 'B', heads[hk].text, after)
      if nb ~= nil and nb.t ~= 'Header' and norm(after) ~= '' then
        needles[#needles + 1] = { id = 'X:' .. hk, kind = 'N', needle = norm(after):sub(1, NEEDLE_MAX),
          fallback = norm(after):sub(1, 24) }
      end
    elseif bi == 1 then
      body_id = 'S:body'
      need_at(body_id, 'B', lead_text(b), '')
    end
    for _, c in ipairs(cites[bi]) do
      occurrences[#occurrences + 1] = { key = c.key, id = 'T:' .. (#occurrences + 1) }
      need_at(occurrences[#occurrences].id, c.kind, c.text, c.context)
    end
  end
  if CFG.toc_front then
    need_at('C:compliance', 'B', 'Certificate of Compliance', '')
    if show_service then need_at('C:service', 'B', 'Certificate of Service', '') end
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, '\t') end
  -- how fb render labels pages: the contents are page i, the body and the certificates from the body's first block
  nl[#nl + 1] = '#section\tS:toc\tlower-roman\t'
  nl[#nl + 1] = '#section\t' .. body_id .. '\tdecimal\t'
  write_file('FORMBOOK_NEEDLES', table.concat(nl, '\n') .. '\n')
  write_file('FORMBOOK_FOOTERS', 'rIdRomanFtr\t' .. FOOTER_P .. '\nrIdArabicFtr\t' .. FOOTER_P .. '\n')
  write_file('FORMBOOK_FINAL', SECT_BODY)
  save_sticky()

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

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- section 1: the cover (no page number); the disclosure statement on its own page
  addall(cover(meta))
  if meta.disclosure ~= nil then
    add(raw_p('<w:p><w:pPr><w:pageBreakBefore/>' .. SECT_LINE .. '</w:pPr></w:p>'))
    addall(disclosure(meta))
  end
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_COVER .. '</w:pPr></w:p>'))

  -- section 2 (lower roman): the table of contents
  local function toc_row(level, steps, label, title, page)
    if label ~= '' then
      return P('CATocS' .. steps, cat(label, TAB, title, LEAD, TAB, folio_il(page)), level == 1 and sp(168, 0) or nil)
    end
    if level == 1 then return P('CATocTop', cat(upper_il(title), LEAD, TAB, folio_il(page))) end
    -- an unnumbered row: the title at the row's indent, hanging a half inch more
    local ind = (steps + 1) * 720
    return P('CATocS0', cat(title, LEAD, TAB, folio_il(page)),
      '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs>' .. sp(98, 0)
      .. '<w:ind w:left="' .. ind .. '" w:right="720" w:hanging="720"/>')
  end
  add(P(CFG.big_h1 and 'CASectionBig' or 'CASection', { pandoc.Str('Table of Contents') }, TOP))
  add(P('CATocPage', { pandoc.Str('Page') }))
  if CFG.toc_front then
    add(P('CATocTop', cat(pandoc.Str('TABLE OF AUTHORITIES'), LEAD, TAB, folio_il(label_of('S:toa')))))
  end
  for _, h in ipairs(heads) do
    if h.toc and not h.addendum and h.level <= 4 then
      local toc_row_page = label_of('H:' .. h.idx)
      add(toc_row(h.level, h.steps, h.label, h.title, toc_row_page))
    end
  end
  if CFG.toc_front then
    add(P('CATocTop', cat(pandoc.Str('CERTIFICATE OF COMPLIANCE'), LEAD, TAB, folio_il(label_of('C:compliance')))))
    if show_service then
      add(P('CATocTop', cat(pandoc.Str('CERTIFICATE OF SERVICE'), LEAD, TAB, folio_il(label_of('C:service')))))
    end
  end

  -- table of authorities (its own page)
  add(P(CFG.big_h1 and 'CASectionBig' or 'CASection', { pandoc.Str('Table of Authorities') }, BREAK_BEFORE .. TOP))
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    local function sk(a)
      local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. ' ' .. plain(a.cite))
      return (s:lower():gsub('[^a-z0-9 ]', ''))
    end
    table.sort(members, function(x, y) return sk(x.a) < sk(y.a) end)
    if #members > 0 then
      local head = { pandoc.Str(g[2]) }
      if first then head[#head + 1] = TAB; head[#head + 1] = pandoc.Strong({ pandoc.Underline({ pandoc.Str('Page(s)') }) }) end
      -- the first group 14 pt below the heading, the others 19.6 pt below the last entry
      add(P('CAToaGroup', head, first and sp(280, 56) or nil))
      first = false
      for _, m in ipairs(members) do
        local il = pandoc.Inlines({})
        if m.a.name ~= nil then
          local nm = minl(m.a.name)
          if g[1] == 'case' then il:insert(pandoc.Emph(nm)) else il:extend(nm) end
          il:insert(pandoc.Str(',')); il:insert(LB)
        end
        il:extend(minl(m.a.cite))
        il:insert(LEAD)
        il:insert(TAB)
        il:extend(folio_il(pages_of(m.key)))
        add(P('CAToaEntry', il, sp(CFG.toa_above, 0)))
      end
    end
  end
  add(raw_p('<w:p><w:pPr>' .. SECT_LINE .. SECT_ROMAN .. '</w:pPr></w:p>'))

  -- section 3 (arabic from 1): the body, the signature block, the certificates
  addall(body)
  addall(signature(meta))
  local certs = {}
  certificate_compliance(meta, words, certs)
  addall(certs)
  if show_service then certificate_service(meta, out) end

  if #add_blocks > 0 then
    fail('the docx engine does not yet render the addendum')
  end

  doc.blocks = pandoc.Blocks(out)
  doc.meta = pandoc.Meta({})   -- pandoc would print the date and title as a block at the top
  return doc
end
