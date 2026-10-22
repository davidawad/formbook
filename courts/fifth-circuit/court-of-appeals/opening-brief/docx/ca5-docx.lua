-- ca5-docx.lua: pandoc filter for the Fifth Circuit briefs, docx engine (docs/DOCX.md): the markdown contract
-- (frontmatter + "# " sections) -> a Word document on reference.docx (docx/make-reference.sh).
-- The typst template (typst/ca5-*.typ) is the reference for what each block looks like and where every line and page
-- breaks (cross-engine layout model, docs/EVAL-LOOP.md; lib/docx/xengine.lua). The cover, the headings, the tables of
-- contents and authorities, the signature block and the certificates' signatures are written here as paragraphs in
-- the "CA5 ..." styles (raw WordprocessingML); the body paragraphs, lists, quotations and footnotes are pandoc's.
-- Sections (cover: no number; front matter: lower roman; body: arabic from 1) and the footers are written by
-- docx/render.sh, which also fills the page numbers of the TOC and TOA from a first pass (DOCX_MANIFEST and
-- DOCX_PAGEMAP, see docx/pagemap.awk). No case-specific text is in this file.

local xe = require('docx.xengine')

local FRONT = { ['certificate of interested persons'] = true, ['statement regarding oral argument'] = true }
local TEXTW = 9360        -- 6.5 in, the text width (letter, 1 in margins)
local TOC_COL = 720       -- typst toc-page-col, 36 pt
local TOA_COL = 1120      -- typst toa-page-col, 56 pt
local SIG = 4320          -- the signature 3 in from the margin
local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')
local LEAD = pandoc.Str('\u{00A0}\u{00A0}\u{00A0}')
local SECT_COVER = '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
local SECT_ROMAN = '<w:sectPr><w:footerReference w:type="default" r:id="RIDROMAN"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>'
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
  inl_xml(xe.inlines(pandoc.Inlines(il)), f or {}, out)
  return pandoc.RawBlock('openxml', '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or '') .. '</w:pPr>'
    .. table.concat(out) .. '</w:p>')
end
local function sp(before, after, line)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before, after, line or 340)
end
local function custom(style, b) return pandoc.Div({ b }, pandoc.Attr('', {}, { ['custom-style'] = style })) end

-- typst indents a paragraph's first line only after another paragraph: every other one is set flush.
local function indent_rule(blocks, flush)
  local out, prev = {}, nil
  for _, b in ipairs(blocks) do
    local items = xe.list_items(b)
    if b.t == 'Para' and (prev == nil or prev.t ~= 'Para') then
      out[#out + 1] = custom(flush or 'CA5 No Indent', b)
    else
      for _, x in ipairs(items) do out[#out + 1] = x end
    end
    prev = b
  end
  return out
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
-- Page numbers from a first pass (docx/render.sh): DOCX_PAGEMAP, DOCX_MANIFEST
-- ---------------------------------------------------------------------------

local PM = { H = {}, S = {}, T = {} }
local pm_path = os.getenv('DOCX_PAGEMAP')
local have_pm = pm_path ~= nil and pm_path ~= ''
if have_pm then
  local f = io.open(pm_path, 'r')
  if not f then fail('cannot read the page map ' .. pm_path) end
  for line in f:lines() do
    local k, a, b = line:match('^(%u)\t([^\t]*)\t(.*)$')
    if k == 'H' then PM.H[tonumber(a)] = b
    elseif k == 'T' then PM.T[a] = b end
  end
  f:close()
end
local function pm_get(tbl, key, what)
  if not have_pm then return '0' end
  local v = tbl[key]
  if v == nil then fail('no page for ' .. what .. ' in the page map') end
  return v
end

local function norm_text(s)
  return (s:gsub('\u{00A0}', ' '):lower():gsub('%s+', ' '):gsub('^ ', ''):gsub(' $', ''))
end
-- the search key of a heading in the PDF: its label and title, lower case, at most about 30 characters
local function search_key(s)
  s = norm_text(s)
  if #s > 30 then s = s:sub(1, 30):match('^(.*)%s%S*$') or s:sub(1, 30) end
  return s
end

-- ---------------------------------------------------------------------------
-- The cover (CA5-CONT-003) [cover]: single-spaced centered lines; the counsel in the lower part of the page
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  local lines = 0   -- an estimate of the cover's height in lines, for the gap above the counsel
  local function line(before, il, f)
    out[#out + 1] = P('CA5Centered', il, sp(before, 0), f)
    lines = lines + math.ceil(math.max(1, #plain(il)) / 70) + before / 340
  end
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
  local tail = 0
  for gi, g in ipairs(meta.counsel or {}) do
    tail = tail + #(g.names or {}) + #(g.lines or {}) + (gi > 1 and 140 / 340 or 0)
  end
  if meta.date then tail = tail + 1 + 280 / 340 end
  -- typst sets the counsel at the foot of the page (v(1fr)); Word has no fill: the gap is what the page leaves
  -- after the estimated lines, less one line to spare
  local gap = math.max(280, math.floor((648 / 17 - lines - tail - 1) * 340))
  for gi, g in ipairs(meta.counsel or {}) do
    for j, n in ipairs(g.names or {}) do
      local before = 0
      if gi == 1 and j == 1 then before = gap elseif j == 1 then before = 140 end
      out[#out + 1] = P('CA5Centered', minl(n), sp(before, 0))
    end
    for _, l in ipairs(g.lines or {}) do out[#out + 1] = P('CA5Centered', minl(l), sp(0, 0)) end
  end
  if meta.date then out[#out + 1] = P('CA5Centered', minl(meta.date), sp(280, 0)) end
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

  -- every toa: citation in document order, as a needle for the page map (docx/pagemap.awk): the link text and the
  -- words after it in its paragraph (up to a footnote mark or a quotation). Kind B (body) moves the search on;
  -- N (in a footnote) is searched from the page the body has reached.
  local needles = {}
  local scan_blocks
  local function scan(inls, kind)
    for i, el in ipairs(inls) do
      if el.t == 'Link' and el.target:match('^toa:') then
        local rest = {}
        for j = i + 1, math.min(#inls, i + 12) do
          local t = inls[j].t
          if t == 'Note' or t == 'Quoted' or t == 'Link' then break end
          rest[#rest + 1] = inls[j]
        end
        local lt = norm_text(plain(pandoc.Inlines(el.content)))
        local tail = norm_text(plain(pandoc.Inlines(rest)))
        if #tail > 20 then tail = tail:sub(1, 20):match('^(.*)%s%S*$') or '' end
        local text = lt
        if tail ~= '' then text = lt .. (tail:match('^[%.,;:%)]') and '' or ' ') .. tail end
        needles[#needles + 1] = { key = el.target:sub(5), kind = kind, text = text }
      elseif el.t == 'Note' then
        scan_blocks(el.content, 'N')
      elseif el.content ~= nil and type(el.content) == 'table' and el.t ~= 'Code' then
        scan(el.content, kind)
      end
    end
  end
  scan_blocks = function(blocks, kind)
    for _, b in ipairs(blocks) do
      if b.t == 'Para' or b.t == 'Plain' or b.t == 'Header' then scan(b.content, kind)
      elseif b.t == 'BlockQuote' or b.t == 'Div' then scan_blocks(b.content, kind)
      elseif b.t == 'BulletList' or b.t == 'OrderedList' then
        for _, item in ipairs(b.content) do scan_blocks(item, kind) end
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
  for _, s in ipairs(main) do scan_blocks(s.blocks, 'B') end

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

  -- the body: headings get their labels; the TOC lists them, and the certificates
  local heads, body = {}, {}
  local function title_para(s, extra)
    local idx = #heads + 1
    heads[idx] = { level = 1, label = '', title = s.inl, idx = idx, key = search_key(plain(s.inl)) }
    return P('CA5Title', s.inl, extra), idx
  end
  for _, s in ipairs(main) do
    local in_arg = s.title ~= nil and norm(s.title) == 'argument'
    local cnt = { 0, 0, 0, 0, 0 }
    if s.title then
      local p = title_para(s, #body == 0 and sp(0, 252) or nil)
      body[#body + 1] = p
    end
    for _, b in ipairs(indent_rule(s.blocks)) do
      if b.t == 'Header' then
        local L = b.level
        if L == 1 then fail('a level-1 heading inside a section') end
        cnt[L] = cnt[L] + 1
        for k = L + 1, 5 do cnt[k] = 0 end
        local lab = label(L, in_arg, cnt[L])
        local idx = #heads + 1
        heads[idx] = { level = L, label = lab, title = b.content, idx = idx, key = search_key(lab .. ' ' .. plain(b.content)) }
        body[#body + 1] = P('CA5Sub' .. L, cat(lab, TAB, b.content), nil, { b = L <= 3 })
      else
        body[#body + 1] = b
      end
    end
  end
  local cert_paras = {}
  for _, c in ipairs(certs) do
    local p = title_para(c, BREAK .. sp(0, 252))
    cert_paras[#cert_paras + 1] = p
  end

  -- manifest for the first pass of docx/render.sh
  local man_path = os.getenv('DOCX_MANIFEST')
  if man_path ~= nil and man_path ~= '' then
    local f = assert(io.open(man_path, 'w'))
    for _, h in ipairs(heads) do f:write(string.format('H\t%d\t%d\t%s\n', h.idx, h.level, h.key)) end
    for _, n in ipairs(needles) do f:write(string.format('C\t%s\t%s\t%s\n', n.key, n.kind, n.text)) end
    f:close()
  end

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
    local page = pm_get(PM.H, h.idx, 'heading ' .. h.idx)
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
        il:extend({ LEAD, TAB, pandoc.Str(pm_get(PM.T, key, 'authority ' .. key)) })
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
