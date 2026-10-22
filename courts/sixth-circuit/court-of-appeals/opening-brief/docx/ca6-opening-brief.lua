-- U.S. Court of Appeals for the Sixth Circuit: appellant's principal brief, Word (docx) engine.
-- A pandoc filter. It writes the brief from the sample's frontmatter and body with the paragraph styles of
-- reference.docx (built by fb render from docx/reference.xml), with the same rules and numbers as ../typst/ca6-opening-brief.typ.
-- Page numbers (TOC, TOA) are plain text: fb render's multi-pass build (tools/fb/src/docxpass.rs) renders the
-- brief, finds the needles this filter writes (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with
-- their pages (FORMBOOK_PAGES) until they settle. The section breaks name fb render's footers (rIdFtrNone,
-- rIdFtrPage, rIdFtrAdd); the last section is FORMBOOK_FINAL. Word may paginate slightly differently.
-- Rules: ../README.md.

local TOC_DEPTH = 4                     -- typst: toc-depth
local PASSIM = 7                        -- typst: passim-threshold
local FONT = 'Liberation Serif'         -- typst: font-family (the face docx/reference.xml names)
local WORD_LIMIT = 13000                -- FRAP 32(a)(7)(B)(i)
local TYPESETTER = 'pandoc 3.12.1 (Word .docx), with LibreOffice 26.8.1 for the PDF'

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

-- The needles (tools/fb/src/docxpages.rs): one per heading (a Div marked ca6-h), citation (a Span marked ca6-k)
-- and numbered section start (ca6-s), in document order, each the text from that point on reduced to lower-case
-- letters and digits, so a heading is found in the body, not at its entry in the table of contents. A citation
-- in a footnote is kind N (searched from the page the body has reached). The text alone is the fallback.
local NEEDLE_MAX = 60
local function norm(s) return (s:lower():gsub('[^%w]', '')) end
local function write_file(var, text)
  local path = os.getenv(var)
  if not path or path == '' then return end
  local f = assert(io.open(path, 'w'))
  f:write(text)
  f:close()
end

-- sections: { { name, format, prefix }, ... } (the ca6-s marks); final: the document's last sectPr.
local function write_needles(blocks, sections, final)
  local events, sec_id = {}, {}
  local function walker(buf, kind)
    local function event(id, el)
      events[#events + 1] = { id = id, kind = kind, buf = buf, at = #table.concat(buf),
        alone = norm(pandoc.utils.stringify(el)):sub(1, NEEDLE_MAX) }
    end
    return {
      traverse = 'topdown',
      Div = function(d)
        local h, s = d.attributes['ca6-h'], d.attributes['ca6-s']
        local id = h and ('h' .. h) or (s and ('S:' .. s))
        if id then event(id, d) end
        if s then sec_id[s] = id end
      end,
      Span = function(sp)
        if sp.attributes['ca6-k'] then event('k' .. sp.attributes['ca6-k'], sp) end
      end,
      Str = function(s) buf[#buf + 1] = norm(s.text) end,
      Code = function(c) buf[#buf + 1] = norm(c.text) end,
      Note = function(n)
        pandoc.Blocks(n.content):walk(walker({}, 'N'))
        return nil, false
      end,
    }
  end
  pandoc.Blocks(blocks):walk(walker({}, 'B'))
  local lines = {}
  for _, e in ipairs(events) do
    local text = table.concat(e.buf)
    lines[#lines + 1] = table.concat({ e.id, e.kind, text:sub(e.at + 1, e.at + NEEDLE_MAX), e.alone }, '\t')
  end
  for _, s in ipairs(sections) do
    lines[#lines + 1] = table.concat({ '#section', assert(sec_id[s[1]], 'no section start ' .. s[1]), s[2], s[3] or '' }, '\t')
  end
  write_file('FORMBOOK_NEEDLES', table.concat(lines, '\n') .. '\n')
  write_file('FORMBOOK_FINAL', final)
end

-- A heading's title as its table-of-contents entry prints it: citation marks dropped (an entry is not a needle).
local function unmarked(inlines)
  return pandoc.Inlines(inlines):walk({ Span = function(sp) if sp.attributes['ca6-k'] then return sp.content end end })
end

-- Paragraph styles are named in the document ("CA Section"); the ids are what docx/reference.xml calls them.
local NAME = {
  CASection = 'CA Section', CASectionNewPage = 'CA Section New Page', CAPoint = 'CA Point',
  CASub1 = 'CA Sub 1', CASub2 = 'CA Sub 2', CASub3 = 'CA Sub 3', CASub4 = 'CA Sub 4',
  CAPlainHeading = 'CA Plain Heading', CABodyKeep = 'CA Body Keep', CASingle = 'CA Single', CASingleKeep = 'CA Single Keep',
  CACover = 'CA Cover', CACoverBold = 'CA Cover Bold', CACoverTitle = 'CA Cover Title', CACoverLeft = 'CA Cover Left',
  CACounselLine = 'CA Counsel Line', CARule1 = 'CA Rule 1', CARule2 = 'CA Rule 2',
  CAShortRule = 'CA Short Rule', CASignature = 'CA Signature', CASignatureGap = 'CA Signature Gap',
  CASignatureLine = 'CA Signature Line', CASignatureLineKeep = 'CA Signature Line Keep',
  CAFormSig = 'CA Form Signature', CATOCTitle = 'CA TOC Title', CATOCPage = 'CA TOC Page',
  CATOCText0 = 'CA TOC Text 0', CATOCTextTop = 'CA TOC Text Top', CATOCText2 = 'CA TOC Text 2', CATOCText3 = 'CA TOC Text 3',
  CATOCLabel0 = 'CA TOC Label 0',
  CATOCLabel1 = 'CA TOC Label 1', CATOCLabel2 = 'CA TOC Label 2', CATOCLabel3 = 'CA TOC Label 3', CATOAGroup = 'CA TOA Group',
  CATOAEntry = 'CA TOA Entry', CATable = 'CA Table Text', CASectionBreak = 'CA Section Break',
}

local TWIP_TEXT = 9360   -- 6.5 in

local function X(s) return pandoc.RawInline('openxml', s) end
local function TAB() return X('<w:r><w:tab/></w:r>') end
local function BR() return X('<w:r><w:br/></w:r>') end
-- Label to title: a positional tab at the hanging indent, with no leader (a dot-leader tab stop in the style would
-- otherwise fill the label's gap with dots).
local function PTAB() return TAB() end
local function attr(id) return pandoc.Attr('', {}, { ['custom-style'] = NAME[id] or id }) end
local function para(id, inlines) return pandoc.Div({ pandoc.Para(inlines) }, attr(id)) end
local function styled(id, blocks) return pandoc.Div(blocks, attr(id)) end
local function blank(id) return pandoc.Div({ pandoc.Para({ pandoc.Str('\u{00A0}') }) }, attr(id)) end
local function esc(s) return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')) end

-- Section breaks. Each section's properties go in the paragraph that ends it; the last section's come from
-- FORMBOOK_FINAL (footer with arabic numbers, or Add- numbers after an addendum).
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
  if n > 26 then error('ca6-brief: more than 26 sub-headings at one level') end
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

-- FRAP 32(a)(7)(B)(i): the body's words, footnotes included. The footnote numbers the plain writer prints
-- are left out; no-break spaces (smart puts them after abbreviations) count as spaces, as in typst.
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

local function signature_blocks(m)
  local sig = m.signature
  local out = {}
  if m.date then out[#out + 1] = para('CASingleKeep', { pandoc.Str('Dated: '), table.unpack(m.date) }) end
  out[#out + 1] = para('CASignatureGap', { pandoc.Str('Respectfully submitted,') })
  out[#out + 1] = para('CASignature', { pandoc.Str('/s/ ' .. pandoc.utils.stringify(sig.signer)) })
  out[#out + 1] = para('CASignature', { pandoc.Str(pandoc.utils.stringify(sig.signer)) })
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do
    out[#out + 1] = para(i < #lines and 'CASignatureLineKeep' or 'CASignatureLine', l)
  end
  return out
end

-- "/s/ Name" and the date, then "Signature" and "Date" (FRAP 25(d)).
local function form_sig(m)
  return styled('CAFormSig', {
    pandoc.Para({ pandoc.Str('/s/ ' .. pandoc.utils.stringify(m.signature.signer)), TAB(), pandoc.Str(pandoc.utils.stringify(m.date or '')) }),
    pandoc.Para({ pandoc.Str('Signature'), TAB(), pandoc.Str('Date') }),
  })
end

-- The designation (6 Cir. R. 28(b)(1)(A)(i), 30(g)(1)): a borderless table, the header row repeated.
local function designation_table(m)
  local W1, W2, GAP = 2160, 3312, 216
  local W3 = TWIP_TEXT - W1 - W2 - 2 * GAP
  local function cell(text, bold, width)
    local rpr = bold and '<w:rPr><w:b/></w:rPr>' or ''
    return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="CATable"/></w:pPr>' ..
      '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r></w:p></w:tc>'
  end
  local gap = '<w:tc><w:tcPr><w:tcW w:w="' .. GAP .. '" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="CATable"/></w:pPr></w:p></w:tc>'
  local rows = {}
  rows[#rows + 1] = '<w:tr><w:trPr><w:tblHeader/></w:trPr>' .. cell('Date Filed', true, W1) .. gap ..
    cell('R.No.; Page ID #', true, W2) .. gap .. cell('Description of Document', true, W3) .. '</w:tr>'
  for _, d in ipairs(m.designation) do
    rows[#rows + 1] = '<w:tr>' .. cell(pandoc.utils.stringify(d.date), false, W1) .. gap ..
      cell(pandoc.utils.stringify(d.rno), false, W2) .. gap ..
      cell(pandoc.utils.stringify(d.description), false, W3) .. '</w:tr>'
  end
  return pandoc.RawBlock('openxml', '<w:tbl><w:tblPr><w:tblStyle w:val="Table"/><w:tblW w:w="' .. TWIP_TEXT ..
    '" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="' .. W1 ..
    '"/><w:gridCol w:w="' .. GAP .. '"/><w:gridCol w:w="' .. W2 .. '"/><w:gridCol w:w="' .. GAP .. '"/><w:gridCol w:w="' .. W3 ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>')
end

function Pandoc(doc)
  local meta = doc.meta
  local auth = authorities_of(meta)

  -- Citations: occ[k] is the key of the k-th citation in the body; occ_text[k] its printed text.
  local occ, occ_text = {}, {}
  local blocks = doc.blocks:walk({
    Link = function(l)
      if l.target:sub(1, 4) ~= 'toa:' then return nil end
      local key = l.target:sub(5)
      if not auth[key] then
        error('ca6-brief: link `toa:' .. key .. '` has no entry under `authorities:` in the frontmatter')
      end
      occ[#occ + 1] = key
      occ_text[#occ] = pandoc.utils.stringify(l.content)
      -- marked for the needles (write_needles); the docx writer prints only the content
      return pandoc.Span(l.content, pandoc.Attr('', {}, { { 'ca6-k', tostring(#occ) } }))
    end,
  })

  -- The addendum (after "# Addendum") sits after the certificates and the designation.
  local main, add = pandoc.List(), nil
  for i, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 and pandoc.utils.stringify(b.content):lower():match('^%s*addendum%s*$') then
      add = pandoc.List({ table.unpack(blocks, i + 1) })
      break
    end
    main:insert(b)
  end
  local words = count_words(main)
  if words > WORD_LIMIT then
    error('ca6-brief: the brief has ' .. words .. ' words; FRAP 32(a)(7)(B)(i) allows ' .. WORD_LIMIT)
  end

  -- ---- headings: numbered as typst numbers them; each has an id (h<id>) for its page ----
  local hid = 0
  local function head(level, label, title, style, depth, in_arg, toc, where)
    hid = hid + 1
    return { kind = 'head', id = hid, level = level, label = label, title = title, style = style,
      depth = depth, in_arg = in_arg, toc = toc and level <= TOC_DEPTH, where = where or 'body' }
  end

  local function body_items(bs, numbered)
    local st = { counters = { 0, 0, 0, 0, 0, 0 }, in_arg = false }
    local items = {}
    for _, b in ipairs(bs) do
      if b.t ~= 'Header' then
        items[#items + 1] = b
      elseif b.level == 1 then
        st.in_arg = pandoc.utils.stringify(b.content):lower():match('^%s*(.-)%s*$') == 'argument'
        if numbered then
          st.counters[1] = st.counters[1] + 1
          for k = 2, 6 do st.counters[k] = 0 end
        end
        items[#items + 1] = head(1, nil, b.content, 'CASection', nil, st.in_arg, true)
      elseif not numbered then
        items[#items + 1] = head(b.level, nil, b.content, 'CAPlainHeading', nil, false, b.level <= 2)
      else
        st.counters[b.level] = st.counters[b.level] + 1
        for k = b.level + 1, 6 do st.counters[k] = 0 end
        local label = label_for(b.level, st.in_arg, st.counters[b.level])
        if st.in_arg and b.level == 2 then
          items[#items + 1] = head(2, label, b.content, 'CAPoint', nil, true, true)
        else
          local d = st.in_arg and (b.level - 2) or (b.level - 1)
          items[#items + 1] = head(b.level, label, b.content, 'CASub' .. d, d, st.in_arg, true)
        end
      end
    end
    return items
  end

  local body = body_items(main, true)
  local addendum = add and body_items(add, false) or nil

  local function fixed(text, style, where)
    return head(1, nil, pandoc.Inlines({ pandoc.Str(text) }), style, nil, false, true, where)
  end
  local h_toa = fixed('Table of Authorities', 'CASectionNewPage', 'front')
  local h_oral = fixed('Statement in Support of Oral Argument', 'CASectionNewPage', 'front')
  local h_cert = fixed('Certificate of Compliance', 'CASectionNewPage', 'body')
  local h_serv = fixed('Certificate of Service', 'CASectionNewPage', 'body')
  local h_desig = fixed('Designation of District Court Record', 'CASectionNewPage', 'body')
  local h_add = add and fixed('Addendum', 'CASection', 'body') or nil

  -- The TOC: the front matter's TOA and oral argument, the body's headings, then the certificates, the designation
  -- and the addendum. Typst outlines every heading; the disclosure page and the TOC itself are not listed.
  local toc = { h_toa, h_oral }
  for _, it in ipairs(body) do if it.kind == 'head' and it.toc then toc[#toc + 1] = it end end
  toc[#toc + 1] = h_cert
  if not meta.service or meta.service.certificate ~= false then toc[#toc + 1] = h_serv end
  toc[#toc + 1] = h_desig
  if h_add then
    toc[#toc + 1] = h_add
    for _, it in ipairs(addendum) do if it.kind == 'head' and it.toc then toc[#toc + 1] = it end end
  end

  -- The TOC is one table, a row per entry: the label in a cell as wide as its indent, the title and page in the
  -- next cell (a single dot-leader tab, so no tab sits between label and title). One table, not one per entry:
  -- pandoc puts an empty paragraph after every table, a blank line between entries. The grid is four 0.5 in label
  -- columns and the rest; a label at depth d spans d + 1 of them, its title the others; an entry without a label
  -- spans the row. Section titles are capitals; the page number is left alone. Point headings (Argument) have a
  -- label at the margin, sub-headings at d * 0.5 in.
  local TEXT_W = 9360
  local LABEL_COLS = 4
  local function toc_table(entries)
    local rows = {}
    for _, e in ipairs(entries) do
      local title = pandoc.List()
      for _, x in ipairs(unmarked(e.title)) do
        if e.level == 1 and x.t == 'Str' then title:insert(pandoc.Str(x.text:upper())) else title:insert(x) end
      end
      title:insert(TAB())
      title:insert(pandoc.Str(page_of('h' .. e.id)))
      local tstyle = e.level == 1 and 'CATOCTextTop' or ('CATOCText' .. (e.depth or 0))
      local function cell(blocks, span) return pandoc.Cell(blocks, pandoc.AlignDefault, 1, span) end
      if e.level == 1 or not e.label then
        rows[#rows + 1] = pandoc.Row({ cell({ pandoc.Div({ pandoc.Para(title) }, attr(tstyle)) }, LABEL_COLS + 1) })
      else
        local d = e.depth or 0
        if d >= LABEL_COLS then error('ca6-brief: a contents entry deeper than ' .. LABEL_COLS .. ' label columns') end
        rows[#rows + 1] = pandoc.Row({
          cell({ pandoc.Div({ pandoc.Para({ pandoc.Str(e.label) }) }, attr('CATOCLabel' .. d)) }, d + 1),
          cell({ pandoc.Div({ pandoc.Para(title) }, attr(tstyle)) }, LABEL_COLS - d),
        })
      end
    end
    local colspecs = {}
    for i = 1, LABEL_COLS do colspecs[i] = { pandoc.AlignDefault, 720 / TEXT_W } end
    colspecs[LABEL_COLS + 1] = { pandoc.AlignDefault, (TEXT_W - LABEL_COLS * 720) / TEXT_W }
    return pandoc.Table(pandoc.Caption(''), colspecs, pandoc.TableHead({}), { pandoc.TableBody(rows) }, pandoc.TableFoot({}))
  end

  -- ---- the TOA: the cited authorities, grouped and sorted; each one's pages, merged by page ----
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
    local title = para('CASectionNewPage', { pandoc.Str('Table of Authorities') })
    title.attributes['ca6-h'] = tostring(h_toa.id)
    local out = { title }
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
            inl:insert(BR())
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

  -- ---- the cover (FRAP 32(a)(2); 6 Cir. R. 28(d)) ----
  local function cover()
    local out = {}
    out[#out + 1] = para('CACoverBold', { pandoc.Str('No. '), table.unpack(meta.case_number) })
    out[#out + 1] = blank('CARule1')
    out[#out + 1] = blank('CARule2')
    out[#out + 1] = para('CACoverBold', { pandoc.Str('IN THE UNITED STATES COURT OF APPEALS'), BR(), pandoc.Str('FOR THE SIXTH CIRCUIT') })
    out[#out + 1] = blank('CAShortRule')
    for i, side in ipairs(meta.caption) do
      for _, n in ipairs(side.names) do out[#out + 1] = para('CACover', n) end
      out[#out + 1] = para('CACoverLeft', side.designation)
      if i < #meta.caption then out[#out + 1] = para('CACover', { pandoc.Str('v.') }) end
    end
    out[#out + 1] = blank('CAShortRule')
    out[#out + 1] = para('CACover', meta.proceeding)
    out[#out + 1] = blank('CAShortRule')
    out[#out + 1] = para('CACoverTitle', meta.brief_title)
    out[#out + 1] = blank('CAShortRule')
    for gi, g in ipairs(meta.counsel) do
      for _, n in ipairs(g.names) do out[#out + 1] = para('CACoverLeft', n) end
      for _, l in ipairs(g.lines or {}) do out[#out + 1] = para('CACounselLine', l) end
      if gi == #meta.counsel then out[#out + 1] = para('CACounselLine', meta.phone) end
    end
    -- typst: the optional party line (frontmatter counsel_for), centred under the counsel block
    if meta.counsel_for then out[#out + 1] = para('CACover', meta.counsel_for) end
    out[#out + 1] = blank('CARule1')
    out[#out + 1] = blank('CARule2')
    return out
  end

  -- A heading: its label (point headings carry the label in the title line), then the title.
  local function heading_block(e)
    local inl = pandoc.List()
    if e.label then
      if e.style == 'CAPoint' then
        inl:insert(pandoc.Str(e.label .. ' '))
      else
        inl:insert(pandoc.Str(e.label))
        inl:insert(PTAB())
      end
    end
    for _, x in ipairs(e.title) do inl:insert(x) end
    local d = para(e.style, inl)
    d.attributes['ca6-h'] = tostring(e.id)
    return d
  end

  local out = {}
  local function push(x) out[#out + 1] = x end

  -- ---- section 1: the cover (no page number) ----
  for _, b in ipairs(cover()) do push(b) end
  push(section_break('rIdFtrNone', nil))

  -- ---- section 2: front matter, roman numerals from the disclosure page ----
  local front = para('CASection', { pandoc.Str('Circuit Rule 26.1 Disclosure Statement') })
  front.attributes['ca6-s'] = 'front'
  push(front)
  push(styled('CASingle', meta.disclosure))
  push(para('CATOCTitle', { pandoc.Str('Table of Contents') }))
  push(para('CATOCPage', { pandoc.Strong({ pandoc.Underline({ pandoc.Str('Page') }) }) }))
  push(toc_table(toc))
  for _, b in ipairs(toa_blocks()) do push(b) end
  push(heading_block(h_oral))
  for _, b in ipairs(meta.oral_argument) do push(b) end
  push(section_break('rIdFtrPage', 'lowerRoman'))

  -- ---- section 3: the body (arabic from 1), the certificates and the designation ----
  -- The last paragraph is kept with the signature block (CABodyKeep keeps it with the next paragraph).
  local last = body[#body]
  if last and last.t == 'Para' then body[#body] = styled('CABodyKeep', { last }) end
  for i, it in ipairs(body) do
    local b = it.kind == 'head' and heading_block(it) or it
    if i == 1 then
      if b.t ~= 'Div' then b = pandoc.Div({ b }) end
      b.attributes['ca6-s'] = 'body'
    end
    push(b)
  end
  for _, b in ipairs(signature_blocks(meta)) do push(b) end

  push(heading_block(h_cert))
  push(para('CASingle', { pandoc.Str('This brief complies with: (1) the type-volume limitation of Federal Rule of Appellate Procedure 32(a)(7)(B) because it contains ' ..
    group_digits(words) .. ' words, excluding the parts of the brief exempted by Rule 32(f); and (2) the typeface requirements of Rule 32(a)(5) and the type style requirements of Rule 32(a)(6) because it has been prepared in a proportionally spaced typeface (14-point ' .. FONT .. ') using ' .. TYPESETTER .. '. The word count is computed from the markdown source of this brief.') }))
  push(form_sig(meta))

  if not meta.service or meta.service.certificate ~= false then
    push(heading_block(h_serv))
    -- the date in the middle: table.unpack inside a table constructor keeps only its first value unless it comes last
    local served = pandoc.List({ pandoc.Str('I certify that on ') })
    served:extend(meta.date)
    served:insert(pandoc.Str(', this brief was served via CM/ECF on all registered counsel and transmitted to the Clerk of the Court.'))
    push(para('CASingle', served))
    push(form_sig(meta))
  end

  push(heading_block(h_desig))
  push(para('CASingle', meta.designation_intro or { pandoc.Str('The appellant designates the following filings from the District Court\'s electronic records under Sixth Circuit Rules 28(b)(1)(A)(i) and 30(g)(1):') }))
  push(designation_table(meta))

  if add then
    push(section_break('rIdFtrPage', 'decimal'))
    local hb = heading_block(h_add)
    hb.attributes['ca6-s'] = 'add'
    push(hb)
    for _, it in ipairs(addendum) do
      if it.kind == 'head' then push(heading_block(it)) else push(it) end
    end
  end

  -- the needles and the last section for fb render (tools/fb/src/docxpass.rs)
  local sections = { { 'front', 'lower-roman' }, { 'body', 'decimal' } }
  if add then sections[#sections + 1] = { 'add', 'decimal', 'Add-' } end
  write_needles(out, sections, '<w:sectPr><w:footerReference w:type="default" r:id="' ..
    (add and 'rIdFtrAdd' or 'rIdFtrPage') .. '"/>' .. PG .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>')

  -- Pandoc would print the date metadata as a title block at the top of the first page; the date is in the
  -- signature and the certificate of service already.
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
