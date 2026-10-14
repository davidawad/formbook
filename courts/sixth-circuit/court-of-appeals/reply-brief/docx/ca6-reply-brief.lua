-- U.S. Court of Appeals for the Sixth Circuit: reply brief, Word (docx) engine.
-- A pandoc filter. It writes the brief from the sample's frontmatter and body with the paragraph styles of
-- reference.docx (reference-src/styles.xml), with the same rules and numbers as ../typst/ca6-reply-brief.typ:
-- cover, table of contents and table of authorities (roman), body and signature, the certificate of compliance,
-- and the certificate of service when the sample asks for one. The reply has no disclosure page, no statement in
-- support of oral argument, no designation and no addendum (the typst has none of them).
-- Page numbers (TOC, TOA) are plain text. docx/render.sh gets them from the rendered PDF (docx/pages.lua) and
-- builds again with them until they stop changing. Environment: CA6_DOCX_PAGES=<pagemap file> supplies the
-- numbers (absent: placeholders); CA6_DOCX_LIST=<file> writes the list of headings and citations to match.
-- Rules: ../README.md.

local TOC_DEPTH = 2                     -- typst: toc-depth (sections and point headings)
local PASSIM = 7                        -- typst: passim-threshold
local WORD_LIMIT = 6500                 -- FRAP 32(a)(7)(B)(ii): a reply brief is half the principal-brief limit

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

-- Paragraph styles are named in the document ("CA Section"); the ids are what reference-src/styles.xml calls them.
local NAME = {
  CASection = 'CA Section', CASectionNewPage = 'CA Section New Page', CAPoint = 'CA Point',
  CASub1 = 'CA Sub 1', CASub2 = 'CA Sub 2', CASub3 = 'CA Sub 3', CASub4 = 'CA Sub 4',
  CABodyKeep = 'CA Body Keep', CASingle = 'CA Single',
  CACover = 'CA Cover', CACoverBold = 'CA Cover Bold', CACourt = 'CA Court', CACoverTitle = 'CA Cover Title',
  CAShortRule = 'CA Short Rule', CASpacerS = 'CA Spacer S', CASpacerM = 'CA Spacer M',
  CASpacerL = 'CA Spacer L', CASpacerXL = 'CA Spacer XL',
  CACounsel = 'CA Counsel', CACounselEnd = 'CA Counsel End', CARespect = 'CA Respectfully',
  CASigFirst = 'CA Signature First', CASigLine = 'CA Signature Line', CASigEnd = 'CA Signature End',
  CACertFirst = 'CA Certificate Signature First',
  CATOCPage = 'CA TOC Page',
  CATOCTextTop = 'CA TOC Text Top', CATOCText0 = 'CA TOC Text 0', CATOCText1 = 'CA TOC Text 1',
  CATOCText2 = 'CA TOC Text 2', CATOCText3 = 'CA TOC Text 3',
  CATOCLabel0 = 'CA TOC Label 0', CATOCLabel1 = 'CA TOC Label 1', CATOCLabel2 = 'CA TOC Label 2',
  CATOCLabel3 = 'CA TOC Label 3', CATOAGroup = 'CA TOA Group', CATOAEntry = 'CA TOA Entry',
  CATable = 'CA Table Text', CASectionBreak = 'CA Section Break',
}

local TWIP_TEXT = 9360   -- 6.5 in
local NBSP = '\u{00A0}'

local function X(s) return pandoc.RawInline('openxml', s) end
local function TAB() return X('<w:r><w:tab/></w:r>') end
-- Label to title: a tab to the hanging indent (the paragraph style's indent sets where the title starts).
local function PTAB() return TAB() end
local function attr(id) return pandoc.Attr('', {}, { ['custom-style'] = NAME[id] or id }) end
local function para(id, inlines) return pandoc.Div({ pandoc.Para(inlines) }, attr(id)) end
local function styled(id, blocks) return pandoc.Div(blocks, attr(id)) end
-- An empty paragraph of a fixed height (the spacers of the cover, the short rules).
local function spacer(id) return pandoc.Div({ pandoc.Para({ pandoc.Str(NBSP) }) }, attr(id)) end

-- Plain text with the typst's "~" (no-break space) into inlines.
local function txt(s)
  local out = pandoc.List()
  s = s:gsub('~', NBSP):gsub('%)%(', ')\u{2060}(')
  local first = true
  for w in s:gmatch('[^ ]+') do
    if not first then out:insert(pandoc.Space()) end
    first = false
    out:insert(pandoc.Str(w))
  end
  return out
end

local function concat(a, b)
  local out = pandoc.List(a)
  for _, x in ipairs(b) do out:insert(x) end
  return out
end

-- Inline lists joined with a space between them (each argument is a list of inlines).
local function seq(...)
  local out = pandoc.List()
  for i, p in ipairs({ ... }) do
    if i > 1 then out:insert(pandoc.Space()) end
    for _, x in ipairs(p) do out:insert(x) end
  end
  return out
end

local function esc(s) return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')) end

-- The section breaks. Each section's properties go in the paragraph that ends it; the last section's come from
-- reference.docx (footer with arabic numbers).
local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local function section_break(footer_rid, numfmt)
  local pg = numfmt and ('<w:pgNumType w:fmt="' .. numfmt .. '" w:start="1"/>') or ''
  return pandoc.RawBlock('openxml', '<w:p><w:pPr><w:pStyle w:val="CASectionBreak"/><w:sectPr><w:footerReference w:type="default" r:id="' ..
    footer_rid .. '"/>' .. PG .. pg .. '</w:sectPr></w:pPr></w:p>')
end

-- Numbering as typst's heading labels: Argument I. / A. / 1. / a.   Elsewhere A. / 1. / a. / (1)
local function roman(n)
  local s = ''
  for _, p in ipairs({ { 10, 'X' }, { 9, 'IX' }, { 5, 'V' }, { 4, 'IV' }, { 1, 'I' } }) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end
local function letter(n, upper)
  if n > 26 then error('ca6-reply-brief: more than 26 sub-headings at one level') end
  return string.char((upper and 64 or 96) + n)
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

-- FRAP 32(a)(7)(B): the body's words, footnotes included. The footnote numbers the plain writer prints are left
-- out; no-break spaces count as spaces, as in typst.
local function count_words(blocks)
  local s = pandoc.write(pandoc.Pandoc(blocks), 'plain')
  s = s:gsub('%[%d+%]', ' ')
  s = s:gsub('\194\160', ' ')
  local n = 0
  for _ in s:gmatch('%S+') do n = n + 1 end
  return n
end

local KINDS = {
  { 'case', 'Cases:' }, { 'constitution', 'Constitutional Provisions:' }, { 'statute', 'Statutes:' },
  { 'regulation', 'Regulations:' }, { 'rule', 'Rules:' }, { 'other', 'Other Authorities:' },
}

local function authorities_of(meta)
  local out = {}
  for key, a in pairs(meta.authorities or {}) do
    local sortsrc = a.sort and pandoc.utils.stringify(a.sort)
      or ((a.name and pandoc.utils.stringify(a.name) or '') .. ' ' .. pandoc.utils.stringify(a.cite))
    out[key] = { kind = pandoc.utils.stringify(a.kind), cite = a.cite, name = a.name, sort = sortsrc:lower():gsub('[^a-z0-9 ]', '') }
  end
  return out
end

-- Signature blocks after the Conclusion (6 Cir. R. 25(d)(1): s/Name), as typst's signature-block.
local function signature_blocks(m)
  local out = { para('CARespect', { pandoc.Str('Respectfully submitted,') }) }
  local sigs = m.signatures
  for si, sig in ipairs(sigs) do
    out[#out + 1] = para('CASigFirst', concat({ pandoc.Str('s/'), pandoc.Space() }, sig.signer))
    local lines = sig.lines or {}
    for li, l in ipairs(lines) do
      local last = si == #sigs and li == #lines
      out[#out + 1] = para(last and 'CASigEnd' or 'CASigLine', l)
    end
  end
  return out
end

-- The certificate's signature: "s/ Name" and the name (6 Cir. R. 25; FRAP 25(d)); the first signing attorney.
local function cert_signature(m)
  local sig = m.signatures[1]
  return {
    para('CACertFirst', concat({ pandoc.Str('s/'), pandoc.Space() }, sig.signer)),
    para('CASigEnd', sig.signer),
  }
end

function Pandoc(doc)
  local meta = doc.meta
  local auth = authorities_of(meta)
  local DATE = meta.date
  local UPON = meta.service and meta.service.upon
  local USE_SERVICE = meta.service ~= nil and meta.service.certificate == true

  -- Citations: occ[k] is the key of the k-th citation in the body; occ_text[k] its printed text.
  local occ, occ_text = {}, {}
  -- Typst keeps a token of adjacent parentheses ("32(a)(7)(B)") on one line: a word joiner between them.
  doc.blocks = doc.blocks:walk({
    Str = function(s)
      if s.text:find(')(', 1, true) then return pandoc.Str((s.text:gsub('%)%(', ')\u{2060}('))) end
    end,
  })
  local main = doc.blocks:walk({
    Link = function(l)
      if l.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = l.target:sub(5)
      if not auth[key] then
        error('ca6-reply-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
      end
      occ[#occ + 1] = key
      occ_text[#occ] = pandoc.utils.stringify(l.content)
      return l.content
    end,
  })
  local words = count_words(main)
  if words > WORD_LIMIT then
    error('ca6-reply-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(ii) allows ' .. WORD_LIMIT .. ' for a reply brief')
  end

  -- ---- headings: numbered as typst numbers them; each has an id (h<id>) for its page ----
  local hid = 0
  local function head(level, label, title, style, depth, in_arg, toc, where)
    hid = hid + 1
    return { kind = 'head', id = hid, level = level, label = label, title = title, style = style,
      depth = depth, in_arg = in_arg, toc = toc and level <= TOC_DEPTH, where = where or 'body' }
  end

  local function body_items(bs)
    local st = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
    local items = {}
    for _, b in ipairs(bs) do
      if b.t ~= 'Header' then
        items[#items + 1] = b
      elseif b.level == 1 then
        st.in_arg = pandoc.utils.stringify(b.content):lower():match('^%s*(.-)%s*$') == 'argument'
        st.counters[1] = st.counters[1] + 1
        for k = 2, 6 do st.counters[k] = 0 end
        items[#items + 1] = head(1, nil, b.content, 'CASection', nil, st.in_arg, true)
      else
        st.counters[b.level] = st.counters[b.level] + 1
        for k = b.level + 1, 6 do st.counters[k] = 0 end
        local label = label_for(b.level, st.in_arg, st.counters[b.level])
        if st.in_arg and b.level == 2 then
          items[#items + 1] = head(2, label, b.content, 'CAPoint', 0, true, true)
        else
          local d = st.in_arg and (b.level - 2) or (b.level - 1)
          items[#items + 1] = head(b.level, label, b.content, 'CASub' .. d, d, st.in_arg, true)
        end
      end
    end
    return items
  end

  local body = body_items(main)

  local function fixed(text, style, where)
    return head(1, nil, pandoc.Inlines({ pandoc.Str(text) }), style, nil, false, true, where)
  end
  local h_cert = fixed('Certificate of Compliance', 'CASection', 'body')
  local h_serv = fixed('Certificate of Service', 'CASectionNewPage', 'body')

  -- The TOC: the body's headings to TOC_DEPTH, then the certificates (typst outlines every heading except the
  -- table of contents and the table of authorities).
  local toc = {}
  for _, it in ipairs(body) do if it.kind == 'head' and it.toc then toc[#toc + 1] = it end end
  toc[#toc + 1] = h_cert
  if USE_SERVICE then toc[#toc + 1] = h_serv end

  -- ---- the list for the page finder (docx/pages.lua): one line per TOC heading and per citation ----
  local list_file = os.getenv('CA6_DOCX_LIST')
  if list_file and list_file ~= '' then
    local f = assert(io.open(list_file, 'w'))
    for _, e in ipairs(toc) do
      f:write('h' .. e.id, '\t', e.where, '\t', (e.label or '') .. pandoc.utils.stringify(e.title), '\n')
    end
    for k, text in ipairs(occ_text) do
      f:write('k' .. k, '\tbody\t', text, '\n')
    end
    f:close()
  end

  -- A TOC entry is a one-row table: the label in a cell as wide as its indent, the title and page in the next
  -- cell (a single dot-leader tab, so no tab sits between label and title). Section titles are capitals; the
  -- page number is left alone. Point headings (Argument) have their label at the margin, sub-headings at d * 0.5 in.
  local function toc_table(e)
    local title = pandoc.List()
    for _, x in ipairs(e.title) do
      if e.level == 1 and x.t == 'Str' then title:insert(pandoc.Str(x.text:upper())) else title:insert(x) end
    end
    title:insert(TAB())
    title:insert(pandoc.Str(page_of('h' .. e.id)))
    local tstyle = e.level == 1 and 'CATOCTextTop' or ('CATOCText' .. (e.depth or 0))
    local colspecs, rows
    if e.level == 1 or not e.label then
      colspecs = { { pandoc.AlignDefault, 1.0 } }
      rows = { pandoc.Row({ pandoc.Cell({ pandoc.Div({ pandoc.Para(title) }, attr(tstyle)) }) }) }
    else
      local d = e.depth or 0
      local lw = (d + 1) * 720
      colspecs = { { pandoc.AlignDefault, lw / TWIP_TEXT }, { pandoc.AlignDefault, (TWIP_TEXT - lw) / TWIP_TEXT } }
      rows = { pandoc.Row({
        pandoc.Cell({ pandoc.Div({ pandoc.Para({ pandoc.Str(e.label) }) }, attr('CATOCLabel' .. d)) }),
        pandoc.Cell({ pandoc.Div({ pandoc.Para(title) }, attr(tstyle)) }),
      }) }
    end
    return pandoc.Table(pandoc.Caption(''), colspecs, pandoc.TableHead({}), { pandoc.TableBody(rows) }, pandoc.TableFoot({}))
  end

  -- ---- the TOA: the cited authorities, grouped and sorted; each one's pages, in document order ----
  local function toa_pages(key)
    local seen, list = {}, {}
    for k, kk in ipairs(occ) do
      if kk == key then
        local p = page_of('k' .. k)
        if not seen[p] then
          seen[p] = true
          list[#list + 1] = p
        end
      end
    end
    if #list >= PASSIM then return pandoc.Inlines({ pandoc.Emph({ pandoc.Str('passim') }) }) end
    return pandoc.Inlines({ pandoc.Str(table.concat(list, ', ')) })
  end

  local function toa_blocks()
    local out = { para('CASectionNewPage', { pandoc.Str('Table of Authorities') }) }
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
        local title = pandoc.List({ pandoc.Str(g[2]) })
        if first then
          title:insert(TAB())
          title:insert(pandoc.Strong({ pandoc.Underline({ pandoc.Str('Page(s)') }) }))
        end
        out[#out + 1] = para('CATOAGroup', title)
        first = false
        for _, key in ipairs(members) do
          local a = auth[key]
          local inl = pandoc.List()
          if a.name then
            inl:insert(a.kind == 'case' and pandoc.Emph(a.name) or pandoc.Span(a.name))
            inl:insert(pandoc.Str(','))
            inl:insert(pandoc.Space())
          end
          for _, x in ipairs(a.cite) do inl:insert(x) end
          inl:insert(TAB())
          for _, x in ipairs(toa_pages(key)) do inl:insert(x) end
          out[#out + 1] = para('CATOAEntry', inl)
        end
      end
    end
    return out
  end

  -- ---- the cover (FRAP 32(a)(2); CA6-COVER-001 to -006) ----
  local function cover()
    local out = {}
    local function add(b) out[#out + 1] = b end
    add(spacer('CASpacerXL'))
    add(para('CACover', concat({ pandoc.Str('No.'), pandoc.Space() }, meta.case_number)))
    add(spacer('CASpacerL'))
    add(para('CACourt', txt('IN THE UNITED STATES COURT OF APPEALS FOR THE SIXTH CIRCUIT')))
    add(spacer('CASpacerL'))
    add(spacer('CAShortRule'))
    add(spacer('CASpacerL'))
    for i, side in ipairs(meta.caption) do
      for _, n in ipairs(side.names) do add(para('CACover', n)) end
      add(para('CACover', side.designation))
      if i < #meta.caption then
        add(spacer('CASpacerM'))
        add(para('CACover', { pandoc.Str('v.') }))
        add(spacer('CASpacerM'))
      end
    end
    add(spacer('CASpacerL'))
    add(spacer('CAShortRule'))
    add(spacer('CASpacerL'))
    add(para('CACover', meta.proceeding))
    add(spacer('CASpacerL'))
    add(spacer('CAShortRule'))
    add(spacer('CASpacerL'))
    add(para('CACoverTitle', meta.brief_title))
    add(spacer('CASpacerL'))
    add(spacer('CAShortRule'))
    add(spacer('CASpacerL'))
    for gi, g in ipairs(meta.counsel) do
      local lines = {}
      for _, n in ipairs(g.names) do lines[#lines + 1] = n end
      for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
      for li, l in ipairs(lines) do add(para(li < #lines and 'CACounsel' or 'CACounselEnd', l)) end
      if gi < #meta.counsel then add(spacer('CASpacerM')) end
    end
    return out
  end

  -- A heading: its label (a tab to the hanging indent), then the title.
  local function heading_block(e)
    local inl = pandoc.List()
    if e.label then
      inl:insert(pandoc.Str(e.label))
      inl:insert(PTAB())
    end
    for _, x in ipairs(e.title) do inl:insert(x) end
    return para(e.style, inl)
  end

  local out = {}
  local function push(x) out[#out + 1] = x end

  -- ---- section 1: the cover (no page number) ----
  for _, b in ipairs(cover()) do push(b) end
  push(section_break('rIdFtr0', nil))

  -- ---- section 2: front matter, lowercase roman numerals ----
  push(para('CASection', { pandoc.Str('Table of Contents') }))
  push(para('CATOCPage', { pandoc.Strong({ pandoc.Underline({ pandoc.Str('Page') }) }) }))
  for _, e in ipairs(toc) do push(toc_table(e)) end
  for _, b in ipairs(toa_blocks()) do push(b) end
  push(section_break('rIdFtr1', 'lowerRoman'))

  -- ---- section 3: the body (arabic from 1), the signature, the certificates ----
  for _, it in ipairs(body) do
    if it.kind == 'head' then push(heading_block(it)) else push(it) end
  end
  -- The signature block never stands alone on a page: the brief's last paragraph is kept with it.
  local last = body[#body]
  if last and last.t == 'Para' then out[#out] = styled('CABodyKeep', { last }) end
  for _, b in ipairs(signature_blocks(meta)) do push(b) end

  push(heading_block(h_cert))
  push(para('CASingle', txt('This reply brief complies with the type-volume limitation of Fed.~R.~App.~P.~32(a)(7)(B) because it contains ' ..
    group_digits(words) .. ' words, excluding the parts of the brief exempted by Fed.~R.~App.~P.~32(f).')))
  push(para('CASingle', txt('This reply brief complies with the typeface requirements of Fed.~R.~App.~P.~32(a)(5) and the type-style requirements of Fed.~R.~App.~P.~32(a)(6) because it has been prepared in a proportionally spaced typeface, 14-point EB Garamond.')))
  for _, b in ipairs(cert_signature(meta)) do push(b) end

  if USE_SERVICE then
    push(heading_block(h_serv))
    push(para('CASingle', concat(seq(txt('I certify that I electronically filed and served this'), meta.brief_title,
      txt('using the Court\u{2019}s CM/ECF system upon'), UPON, txt('on'), DATE), { pandoc.Str('.') })))
    for _, b in ipairs(cert_signature(meta)) do push(b) end
  end

  -- The date is in the certificate of service only; drop the metadata so pandoc prints no title block.
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
