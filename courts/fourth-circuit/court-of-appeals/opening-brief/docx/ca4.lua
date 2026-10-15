-- Fourth Circuit brief, docx engine (pandoc Lua filter; see ../README.md, "Engines" and docs/DOCX.md).
-- The cover, the heading numbers, the contents and table of authorities (Word fields: TOC, TA, TOA), the signature
-- and the certificates are written here as OOXML; the styles and page setup are in reference.docx. Sections:
-- cover (no folio), front matter (lowercase roman), body (arabic from 1). The same rules and numbers as the typst
-- and latex engines. This file is identical in the three doc-type folders except for DOCTYPE below.

local DOCTYPE = 'opening-brief'

local CFG = ({
  ['opening-brief'] = {
    numbering = 'all',       -- sub-headings numbered everywhere (I. / A. / 1. / a. in the Argument, A. / 1. / a. elsewhere)
    base = 1,
    point_centered = false,
    limit = 13000,           -- FRAP 32(a)(7)(B)(i)
    limit_name = 'FRAP 32(a)(7)(B)(i)',
    count = 'request',       -- the request for oral argument is not counted (FRAP 32(f)): it is the last section
    sig = 'opening',
    cert = 'opening',
    service_default = true,  -- the certificate of service is shown unless the frontmatter says otherwise
  },
  ['answering-brief'] = {
    numbering = 'argument',
    base = 2,
    point_centered = true,
    limit = 13000,
    limit_name = 'FRAP 32(a)(7)(B)(i)',
    count = 'all',
    sig = 'answering',
    cert = 'answering',
    service_default = false,
  },
  ['reply-brief'] = {
    numbering = 'all',
    base = 1,
    point_centered = false,
    limit = 6500,            -- CA4-LEN-001: half the principal-brief limit
    limit_name = 'FRAP 32(a)(7)(B)(ii)',
    count = 'addendum',      -- the addendum is not part of the reply (FRAP 28(f))
    sig = 'reply',
    cert = 'reply',
    service_default = false,
  },
})[DOCTYPE]

local TAB = 0.5
local COUNSEL_FOR = nil
local HEADINGS = {}       -- the headings of the contents, in order: { level, text }

-- Word's table of authorities categories (TA \c)
local TOA_CATEGORY = { case = 1, constitution = 2, statute = 3, regulation = 4, rule = 5, other = 6 }
local TOA_GROUPS = {
  { 'case', 'Cases:' },
  { 'constitution', 'Constitutional Provisions:' },
  { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' },
  { 'rule', 'Rules:' },
  { 'other', 'Other Authorities:' },
}

-- ---- XML helpers: children are written in the order the OOXML schema requires ----

local function xesc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'))
end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

local function plain(v) return trim(pandoc.utils.stringify(v or '')) end

local function items(v)
  local out = {}
  if v ~= nil then
    for _, x in ipairs(v) do out[#out + 1] = x end
  end
  return out
end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return (out:gsub('^,', ''))
end

local function run(text, props)
  local rpr = props and ('<w:rPr>' .. props .. '</w:rPr>') or ''
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
end

local function brk() return '<w:r><w:br/></w:r>' end
local function tab() return '<w:r><w:tab/></w:r>' end

-- spacing and indentation (twentieths of a point); `exact` lines are the typst pitches
local function spacing(before, after, line)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. line .. '" w:lineRule="exact"/>'
end
local function indent(left, firstline, right)
  local a = (left and (' w:left="' .. left .. '"') or '') .. (right and (' w:right="' .. right .. '"') or '')
  return '<w:ind' .. a .. (firstline and (' w:firstLine="' .. firstline .. '"') or '') .. '/>'
end

-- A paragraph property block. `o` holds the parts; they are emitted in schema order.
local function ppr(o)
  local t = {}
  if o.style then t[#t + 1] = '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep then t[#t + 1] = '<w:keepNext/>' end
  if o.border then t[#t + 1] = o.border end
  if o.tabs then t[#t + 1] = o.tabs end
  if o.spacing then t[#t + 1] = o.spacing end
  if o.ind then t[#t + 1] = o.ind end
  if o.jc then t[#t + 1] = '<w:jc w:val="' .. o.jc .. '"/>' end
  if o.sect then t[#t + 1] = o.sect end
  return table.concat(t)
end

local function para(o, runs)
  local p = ppr(o)
  return '<w:p>' .. (p ~= '' and ('<w:pPr>' .. p .. '</w:pPr>') or '') .. (runs or '') .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock('openxml', xml) end
local function rawi(xml) return pandoc.RawInline('openxml', xml) end

local SINGLE = spacing(0, 0, 400)
local RULE_DOUBLE = '<w:pBdr><w:bottom w:val="double" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>'
local RULE_SINGLE = '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>'

-- Frontmatter text as runs: markup kept (italics, bold), everything else plain
local function frag(v, props)
  if v == nil then return '' end
  if type(v) == 'string' then return run(v, props) end
  local out = {}
  for _, x in ipairs(v) do
    if x.t == 'Emph' then out[#out + 1] = run(plain(x.content), (props or '') .. '<w:i/>')
    elseif x.t == 'Strong' then out[#out + 1] = run(plain(x.content), '<w:b/>' .. (props or ''))
    elseif x.t == 'Space' then out[#out + 1] = run(' ', props)
    else out[#out + 1] = run(pandoc.utils.stringify(x), props) end
  end
  return table.concat(out)
end

-- Section properties: the cover (no folio), the front matter (lowercase roman), and the body (arabic from 1)
local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local SECT_COVER = raw(para({ sect = '<w:sectPr>' .. PG .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>' }))
local SECT_FRONT = raw(para({ sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/>' .. PG
  .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr>' }))

-- ---- headings ----

local counters = { 0, 0, 0, 0, 0, 0 }
local in_argument = false
local in_addendum = false

local function roman(n)
  local vals = { { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }
  local out = ''
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function alpha(n) return string.char(string.byte('A') + n - 1) end

local function heading_label(lvl, n)
  if in_argument then
    if lvl == 2 then return roman(n) .. '.'
    elseif lvl == 3 then return alpha(n) .. '.'
    elseif lvl == 4 then return tostring(n) .. '.'
    elseif lvl == 5 then return string.char(96 + n) .. '.' end
  else
    if lvl == 2 then return alpha(n) .. '.'
    elseif lvl == 3 then return tostring(n) .. '.'
    elseif lvl == 4 then return string.char(96 + n) .. '.'
    elseif lvl == 5 then return '(' .. n .. ')' end
  end
  error('ca4-brief: headings deeper than level 5 are not supported')
end

local function numbered(lvl)
  if lvl < 2 then return false end
  if CFG.numbering == 'all' then return true end
  return in_argument
end

local function header(h)
  local lvl = h.level
  local text = plain(h.content)
  if lvl == 1 then
    in_argument = text:lower() == 'argument'
    in_addendum = text:lower() == 'addendum'
    for i = 2, 6 do counters[i] = 0 end
    counters[1] = counters[1] + 1
    -- section headings in capitals (typst: upper(body)); the style is centred and bold
    local content = pandoc.Inlines({})
    for _, x in ipairs(h.content) do
      if x.t == 'Str' then content:insert(pandoc.Str(x.text:upper())) else content:insert(x) end
    end
    HEADINGS[#HEADINGS + 1] = { level = 1, text = plain(content) }
    return pandoc.Header(1, content, h.attr)
  end
  counters[lvl] = counters[lvl] + 1
  for i = lvl + 1, 6 do counters[i] = 0 end
  if in_addendum or not numbered(lvl) then
    -- unnumbered sub-heading (the addendum's are not numbered)
    if lvl <= 4 and not in_addendum then HEADINGS[#HEADINGS + 1] = { level = lvl, text = text } end
    return pandoc.Header(lvl, h.content, h.attr)
  end
  local label = heading_label(lvl, counters[lvl])
  local content = pandoc.Inlines({ pandoc.Str(label), rawi(tab()) })
  for _, x in ipairs(h.content) do content:insert(x) end
  if lvl <= 4 then HEADINGS[#HEADINGS + 1] = { level = lvl, text = label .. ' ' .. text } end
  return pandoc.Header(lvl, content, h.attr)
end

-- ---- cover, disclosure, signature and certificates ----

local CENTER = { jc = 'center' }

local function cover(m)
  local out = {}
  local function add(o, runs) out[#out + 1] = raw(para(o, runs)) end
  local function gap() add({ spacing = SINGLE }, '') end
  local function short_rule() add({ ind = indent(3240, nil, 3240), border = RULE_SINGLE, spacing = SINGLE }, '') end
  add({ jc = 'center', spacing = SINGLE }, run('No. ' .. plain(m.case_number), '<w:b/>'))
  add({ border = RULE_DOUBLE, spacing = spacing(0, 0, 120) }, '')
  gap()
  add({ jc = 'center', spacing = SINGLE }, run('IN THE', '<w:b/>') .. brk() .. run('UNITED STATES COURT OF APPEALS', '<w:b/>')
    .. brk() .. run('FOR THE FOURTH CIRCUIT', '<w:b/>'))
  gap()
  short_rule()
  gap()
  local sides = items(m.caption)
  for i, side in ipairs(sides) do
    for _, name in ipairs(items(side.names)) do add({ jc = 'center', spacing = SINGLE }, frag(name)) end
    add({ ind = indent(4680, nil, nil), spacing = SINGLE }, frag(side.designation))
    if i < #sides then add({ jc = 'center', spacing = SINGLE }, run('v.')) end
  end
  gap()
  short_rule()
  gap()
  add({ jc = 'center', spacing = SINGLE }, frag(m.proceeding))
  if m.district_court_case ~= nil or m.judge ~= nil then
    local parts = {}
    if m.district_court_case ~= nil then parts[#parts + 1] = 'Case No. ' .. plain(m.district_court_case) end
    if m.judge ~= nil then parts[#parts + 1] = plain(m.judge) end
    add({ jc = 'center', spacing = SINGLE }, run(table.concat(parts, ', ')))
  end
  gap()
  short_rule()
  gap()
  add({ jc = 'center', spacing = SINGLE }, run(plain(m.brief_title):upper(), '<w:b/>'))
  gap()
  short_rule()
  gap()
  local counsel = items(m.counsel)
  for gi, g in ipairs(counsel) do
    local xml = {}
    for _, n in ipairs(items(g.names)) do xml[#xml + 1] = frag(n) .. brk() end
    local lines = items(g.lines)
    if gi == #counsel and m.phone ~= nil then lines[#lines + 1] = m.phone end
    for _, l in ipairs(lines) do xml[#xml + 1] = frag(l, '<w:i/>') .. brk() end
    add({ ind = indent(4680, nil, nil), spacing = SINGLE }, table.concat(xml))
    if gi < #counsel then gap() end
  end
  if m.date ~= nil and m.party_line ~= nil then
    gap()
    add({ tabs = '<w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs>', spacing = SINGLE },
      frag(m.date) .. tab() .. frag(m.party_line))
  end
  gap()
  add({ border = RULE_DOUBLE, spacing = spacing(0, 0, 120) }, '')
  out[#out + 1] = SECT_COVER
  return out
end

local QUESTIONS = {
  'Is party/amicus a publicly held corporation or other publicly held entity?',
  'Does party/amicus have any parent corporations?',
  'Is 10% or more of the stock of a party/amicus owned by a publicly held corporation or other publicly held entity?',
  'Is there any other publicly held corporation or other publicly held entity that has a direct financial interest in the outcome of the litigation?',
  'Is party a trade association? (amici curiae do not complete this question)',
  'Does this case arise out of a bankruptcy proceeding?',
  'Is this a criminal case in which there was an organizational victim?',
}

local function disclosure(m)
  local d = m.disclosure
  local answers = items(d.answers)
  if #answers ~= #QUESTIONS then
    error('ca4-brief: disclosure.answers needs one yes or no for each of the ' .. #QUESTIONS .. ' questions')
  end
  local out = {}
  local function add(o, runs) out[#out + 1] = raw(para(o, runs)) end
  add({ jc = 'center', spacing = SINGLE }, run('UNITED STATES COURT OF APPEALS FOR THE FOURTH CIRCUIT', '<w:b/>'))
  add({ jc = 'center', spacing = SINGLE }, run('DISCLOSURE STATEMENT', '<w:b/>'))
  add({ jc = 'center', spacing = SINGLE }, run('No. ' .. plain(m.case_number)))
  add({ spacing = spacing(200, 0, 400) }, run('Pursuant to FRAP 26.1 and Local Rule 26.1, ' .. plain(d.party) .. ', who is '
    .. plain(d.role) .. ', makes the following disclosure:'))
  for i, q in ipairs(QUESTIONS) do
    -- YAML reads a bare `no` as false
    local a = answers[i] == false and 'no' or answers[i] == true and 'yes' or plain(answers[i])
    if a ~= 'yes' and a ~= 'no' then error('ca4-brief: disclosure answer ' .. i .. ' must be `yes` or `no`') end
    add({ keep = true, spacing = spacing(180, 0, 400) }, run(i .. '. ' .. q))
    add({ ind = indent(576, nil, nil), spacing = SINGLE }, run('YES  ' .. (a == 'yes' and '[X]' or '[  ]')
      .. '        NO  ' .. (a == 'no' and '[X]' or '[  ]')))
  end
  add({ ind = indent(4680, nil, nil), spacing = spacing(320, 0, 400) },
    run('/s/ ' .. plain(d.signer)) .. brk() .. run(plain(d.date)))
  out[#out + 1] = raw(para({}, '<w:r><w:br w:type="page"/></w:r>'))
  return out
end

local function signature(m)
  local sig = m.signature
  local out = {}
  local function add(o, runs) out[#out + 1] = raw(para(o, runs)) end
  add({ keep = true, spacing = spacing(280, 0, 400) }, run('Respectfully submitted,'))
  if CFG.sig == 'answering' then
    for _, l in ipairs(items(sig.lead)) do add({ ind = indent(4680, nil, nil), spacing = SINGLE }, run(plain(l)) .. brk()) end
    add({ ind = indent(4680, nil, nil), spacing = spacing(200, 0, 400) }, run('/s/ ' .. plain(sig.signer)) .. brk())
    for _, l in ipairs(items(sig.lines)) do add({ ind = indent(4680, nil, nil), spacing = SINGLE }, run(plain(l)) .. brk()) end
  else
    add({ ind = indent(4680, nil, nil), spacing = spacing(200, 0, 400) }, run('/s/ ' .. plain(sig.signer)) .. brk())
    add({ ind = indent(4680, nil, nil), spacing = SINGLE }, run(plain(sig.signer):upper()) .. brk())
    for _, l in ipairs(items(sig.lines)) do add({ ind = indent(4680, nil, nil), spacing = SINGLE }, frag(l, '<w:i/>') .. brk()) end
  end
  if m.date ~= nil and CFG.sig ~= 'answering' then
    add({ spacing = spacing(160, 0, 400) }, run(plain(m.date)))
  end
  return out
end

-- A certificate heading: a Heading 1 (listed in the contents) or, when the contents leave it out, a plain centred line
local function certificate_heading(text, outlined)
  if outlined then return pandoc.Header(1, pandoc.Inlines({ pandoc.Str(text:upper()) })) end
  return raw(para({ keep = true, jc = 'center', spacing = spacing(300, 220, 400) }, run(text:upper(), '<w:b/>')))
end

local function body_para(runs, o)
  o = o or {}
  o.spacing = o.spacing or SINGLE
  o.ind = o.ind or indent(nil, 0, nil)
  return raw(para(o, runs))
end

local function signature_only(m)
  return body_para(run('/s/ ' .. plain(m.signature.signer)),
    { ind = indent(4680, 0, nil), spacing = spacing(320, 0, 400) })
end

local function certificate_compliance(m, words)
  local out = {}
  out[#out + 1] = certificate_heading('Certificate of Compliance', CFG.cert == 'opening')
  local n = group_digits(words)
  if CFG.cert == 'opening' then
    out[#out + 1] = body_para(run('Pursuant to Federal Rule of Appellate Procedure 32(a)(7)(B), I certify that this brief is '
      .. 'proportionately spaced and contains ' .. n .. ' words excluding parts of the document exempted by Rule 32(f).'))
    out[#out + 1] = body_para(run('/s/ ' .. plain(m.signature.signer)) .. brk() .. run(plain(m.signature.signer):upper()),
      { ind = indent(4680, 0, nil), spacing = spacing(320, 0, 400) })
  elseif CFG.cert == 'answering' then
    out[#out + 1] = body_para(run('1.  This brief complies with the type-volume limitation of Federal Rule of Appellate Procedure '
      .. '32(a)(7)(B) because this brief contains ' .. n .. ' words, excluding the parts of the brief exempted by Rule 32(f).'),
      { spacing = spacing(0, 0, 400) })
    out[#out + 1] = body_para(run('2.  This brief complies with the typeface requirements of Federal Rule of Appellate Procedure '
      .. '32(a)(5) and the type style requirements of Rule 32(a)(6) because this brief has been prepared in a proportionally '
      .. 'spaced typeface, TeX Gyre Schola, in fourteen-point type.'), { spacing = spacing(240, 0, 400) })
    out[#out + 1] = signature_only(m)
  else
    out[#out + 1] = body_para(run('I, ' .. plain(m.signature.signer) .. ', counsel for ' .. plain(COUNSEL_FOR or 'the party')
      .. ' and a member of the bar of this Court, certify that the attached reply brief is proportionally spaced, has a typeface of '
      .. '14 points, and contains ' .. n .. ' words as calculated pursuant to Fed. R. App. P. 32(f) and 32(a)(7)(B)(ii).'))
    out[#out + 1] = body_para(run('/s/ ' .. plain(m.signature.signer)) .. tab() .. run(plain(m.date or '')),
      { tabs = '<w:tabs><w:tab w:val="left" w:pos="4680"/></w:tabs>', spacing = spacing(320, 0, 400) })
    out[#out + 1] = body_para(run('Signature') .. tab() .. run('Date'), { tabs = '<w:tabs><w:tab w:val="left" w:pos="4680"/></w:tabs>' })
  end
  return out
end

local function certificate_service(m)
  local out = {}
  out[#out + 1] = certificate_heading('Certificate of Service', CFG.cert == 'opening')
  if CFG.cert == 'opening' then
    out[#out + 1] = body_para(run('I certify that on ' .. plain(m.date) .. ', the ') .. frag(m.brief_title)
      .. run(' was served on all parties or their counsel of record through the CM/ECF system.'))
    out[#out + 1] = signature_only(m)
  elseif CFG.cert == 'answering' then
    out[#out + 1] = body_para(run('I hereby certify that on this ' .. plain(m.service.date) .. ', the foregoing ')
      .. frag(m.brief_title) .. run(' was served on ' .. plain(m.service.served_on) .. '.'))
    out[#out + 1] = signature_only(m)
  else
    out[#out + 1] = body_para(run('I hereby certify that I electronically filed the foregoing document on this date with the '
      .. 'Clerk of the Court for the United States Court of Appeals for the Fourth Circuit using the CM/ECF system, which will '
      .. 'send notice of this filing to all registered CM/ECF users.'))
    out[#out + 1] = body_para(run('/s/ ' .. plain(m.signature.signer)) .. tab() .. run(plain(m.date or '')),
      { tabs = '<w:tabs><w:tab w:val="left" w:pos="4680"/></w:tabs>', spacing = spacing(320, 0, 400) })
    out[#out + 1] = body_para(run('Signature') .. tab() .. run('Date'), { tabs = '<w:tabs><w:tab w:val="left" w:pos="4680"/></w:tabs>' })
  end
  return out
end

-- ---- contents and table of authorities: Word fields (updated by Word on open: w:dirty) ----

-- A complex field: begin (dirty: Word updates it when the file opens), instruction, separator, cached result, end
local function field(instr, result, dirty)
  return '<w:r><w:fldChar w:fldCharType="begin"' .. (dirty and ' w:dirty="true"' or '') .. '/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> ' .. xesc(instr) .. ' </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' .. (result or '')
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
end

-- The contents: a TOC field over the heading styles. The cached entries have no page numbers: only Word, on update,
-- can paginate them (docs/DOCX.md; see the README's Engines section).
local function contents()
  local out = {}
  out[#out + 1] = raw(para({ jc = 'center', keep = true, spacing = spacing(400, 280, 400) }, run('TABLE OF CONTENTS', '<w:b/>')))
  out[#out + 1] = raw(para({ jc = 'right', spacing = SINGLE }, run('Page', '<w:b/><w:u w:val="single"/>')))
  -- one TOC field over all the entries: it begins in the first entry and ends in the last
  for i, h in ipairs(HEADINGS) do
    local runs = ''
    if i == 1 then
      runs = '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>'
        .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h \\z \\u </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    runs = runs .. run(h.text) .. tab()
    if i == #HEADINGS then runs = runs .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    out[#out + 1] = raw(para({ style = 'TOC' .. h.level }, runs))
  end
  return out
end

local function table_of_authorities(auth, hits)
  local out = {}
  out[#out + 1] = raw(para({ jc = 'center', keep = true, spacing = spacing(400, 280, 400) }, run('TABLE OF AUTHORITIES', '<w:b/>')))
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    local function sort_key(a)
      local s = a.sort and plain(a.sort) or (plain(a.name or '') .. ' ' .. plain(a.cite))
      return (s:lower():gsub('[^a-z0-9 ]', ''))
    end
    table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
    if #members > 0 then
      local head = run(g[2], '<w:b/>')
      if first then head = head .. tab() .. run('Page(s)', '<w:b/><w:u w:val="single"/>') end
      out[#out + 1] = raw(para({ keep = true, tabs = '<w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs>',
        spacing = spacing(first and 200 or 300, 100, 400) }, head))
      first = false
      -- the entries are the TOA field's cached result; Word replaces them with the paginated list on update
      local category = TOA_CATEGORY[g[1]]
      for i, mem in ipairs(members) do
        local a = mem.a
        local runs = ''
        if i == 1 then runs = '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>'
          .. '<w:r><w:instrText xml:space="preserve"> TOA \\h \\c "' .. category .. '" </w:instrText></w:r>'
          .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' end
        if a.name ~= nil then
          runs = runs .. frag(a.name, plain(a.kind) == 'case' and '<w:i/>' or nil) .. run(',') .. brk()
        end
        runs = runs .. frag(a.cite) .. tab()
        if i == #members then runs = runs .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
        out[#out + 1] = raw(para({ style = 'TableofAuthorities' }, runs))
      end
    end
  end
  return out
end

-- ---- the filter ----

-- Words as typst counts them (see the latex engine): non-space runs; footnote text included.
local function count_words(blocks)
  local n = 0
  local function spaced(p)
    local c = pandoc.Inlines(p.content)
    c:insert(pandoc.Space())
    return pandoc.Plain(c)
  end
  for _, b in ipairs(blocks) do
    local with_notes = pandoc.Pandoc({ b }):walk({
      Note = function(note)
        local c = pandoc.Inlines({ pandoc.Space() })
        for _, x in ipairs(pandoc.utils.blocks_to_inlines(note.content)) do c:insert(x) end
        return pandoc.Span(c)
      end,
      Para = spaced,
      Plain = spaced,
    })
    local text = pandoc.utils.stringify(with_notes.blocks):gsub('\194\160', ' ')
    local _, c = text:gsub('%S+', '')
    n = n + c
  end
  return n
end

local function is_h1(b, name)
  return b.t == 'Header' and b.level == 1 and plain(b.content):lower() == name
end

function Pandoc(doc)
  local m = doc.meta
  -- pandoc would print the frontmatter's `date` as a title block at the top; the cover carries it instead
  m.date = nil
  for _, k in ipairs({ 'case_number', 'caption', 'proceeding', 'brief_title', 'counsel', 'signature' }) do
    if m[k] == nil then error('ca4-brief: missing required metadata field `' .. k .. '`') end
  end
  local auth = m.authorities or {}
  COUNSEL_FOR = m['counsel-for']

  -- citations: each toa: link gets a TA field after its text (Word collects it into the table); the hit is recorded
  local hits = {}
  doc = doc:walk({
    Link = function(el)
      if el.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = el.target:sub(5)
      local a = auth[key]
      if a == nil then error('ca4-brief: link `toa:' .. key .. '` has no entry under `authorities:`') end
      hits[key] = true
      local long = (a.name ~= nil and (plain(a.name) .. ', ') or '') .. plain(a.cite)
      local content = pandoc.Inlines({})
      for _, x in ipairs(el.content) do content:insert(x) end
      content:insert(rawi(field('TA \\l "' .. long:gsub('"', "'") .. '" \\s "' .. key .. '" \\c '
        .. TOA_CATEGORY[plain(a.kind)], '', false)))
      return content
    end,
  })

  -- split the body: the addendum (reply) follows the certificates
  local body, addendum = {}, {}
  local split = false
  for _, b in ipairs(doc.blocks) do
    if CFG.count == 'addendum' and is_h1(b, 'addendum') then split = true end
    if split then addendum[#addendum + 1] = b else body[#body + 1] = b end
  end

  -- length: the body's words (FRAP 32(a)(7)(B)); the request for oral argument is excluded (FRAP 32(f))
  local counted = {}
  local stop = false
  for _, b in ipairs(body) do
    if CFG.count == 'request' and is_h1(b, 'request for oral argument') then stop = true end
    if not stop then counted[#counted + 1] = b end
  end
  local words = count_words(counted)
  if words > CFG.limit then
    error('ca4-brief: the brief has ' .. words .. ' words; ' .. CFG.limit_name .. ' allows ' .. CFG.limit)
  end

  -- headings (in order; they feed the contents) and the block quotations keep their own styles
  local function map(blocks)
    return pandoc.Pandoc(blocks):walk({ Header = header }).blocks
  end
  body = map(body)
  addendum = map(addendum)

  -- the front matter: cover, disclosure, contents, authorities
  local front = {}
  for _, b in ipairs(cover(m)) do front[#front + 1] = b end
  if m.disclosure ~= nil then
    for _, b in ipairs(disclosure(m)) do front[#front + 1] = b end
  end
  for _, b in ipairs(contents()) do front[#front + 1] = b end
  front[#front + 1] = raw(para({}, '<w:r><w:br w:type="page"/></w:r>'))
  for _, b in ipairs(table_of_authorities(auth, hits)) do front[#front + 1] = b end
  front[#front + 1] = SECT_FRONT

  -- the body, the signature, the certificates, then the addendum (reply)
  local main = {}
  for _, b in ipairs(body) do main[#main + 1] = b end
  for _, b in ipairs(signature(m)) do main[#main + 1] = b end
  for _, b in ipairs(certificate_compliance(m, words)) do main[#main + 1] = b end
  local show_service = CFG.service_default
  if m.service ~= nil and m.service.certificate ~= nil then show_service = m.service.certificate == true end
  if show_service then
    main[#main + 1] = raw(para({}, '<w:r><w:br w:type="page"/></w:r>'))
    for _, b in ipairs(certificate_service(m)) do main[#main + 1] = b end
  end
  for _, b in ipairs(addendum) do main[#main + 1] = b end

  local all = {}
  for _, b in ipairs(front) do all[#all + 1] = b end
  for _, b in ipairs(main) do all[#all + 1] = b end
  doc.blocks = pandoc.Blocks(all)
  return doc
end
