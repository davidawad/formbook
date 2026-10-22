-- U.S. Court of Appeals for the Sixth Circuit: appellee's brief (answering brief), Word (docx) engine.
-- A pandoc filter. It writes the brief from the sample's frontmatter and body with the paragraph styles of
-- reference.docx (built by fb render from docx/reference.xml), with the same rules and numbers as ../typst/ca6-answering-brief.typ.
-- Page numbers (TOC, TOA) are plain text: fb render's multi-pass build (tools/fb/src/docxpass.rs) renders the
-- brief, finds the needles this filter writes (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with
-- their pages (FORMBOOK_PAGES) until they settle. The section breaks name fb render's footers (rIdFtrNone,
-- rIdFtrPage, rIdFtrAdd); the last section is FORMBOOK_FINAL. Word may paginate slightly differently.
-- Rules: ../README.md.

local TOC_DEPTH = 4                     -- typst: toc-depth
local PASSIM = 7                        -- typst: passim-threshold
local FONT = 'TeX Gyre Schola'            -- typst: font-family (the face docx/reference.xml names)
-- typst: word-limits and word-limit-rule (FRAP 32(a)(7)(B); FRAP 28.1(e)(2)), keyed by word_limit_basis
local WORD_LIMITS = { standard = 13000, ['cross-appeal'] = 15300, reply = 6500, ['cross-appeal-reply'] = 6500 }
local WORD_LIMIT_RULE = {
  standard = '32(a)(7)(B)(i)', ['cross-appeal'] = '28.1(e)(2)(B)(i)', reply = '32(a)(7)(B)(ii)',
  ['cross-appeal-reply'] = '28.1(e)(2)(C)',
}

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
  CAPlainHeading = 'CA Plain Heading', CABodyKeep = 'CA Body Keep', CASingle = 'CA Single', CAKeep = 'CA Keep',
  CACover = 'CA Cover', CACoverBold = 'CA Cover Bold', CACoverTitle = 'CA Cover Title', CACoverLeft = 'CA Cover Left',
  CACounselName = 'CA Counsel Name', CACounselLine = 'CA Counsel Line', CARule1 = 'CA Rule 1', CARule2 = 'CA Rule 2',
  CAShortRule = 'CA Short Rule', CASignature = 'CA Signature', CASignatureGap = 'CA Signature Gap',
  CASignatureLine = 'CA Signature Line', CASignatureLineKeep = 'CA Signature Line Keep',
  CACertSig = 'CA Cert Signature', CACertSigLine = 'CA Cert Signature Line', CADate = 'CA Date',
  CAServiceAddress = 'CA Service Address', CADisclosureTitle = 'CA Disclosure Title',
  CADisclosureItem = 'CA Disclosure Item', CADisclosureAnswer = 'CA Disclosure Answer',
  CATOCTitle = 'CA TOC Title', CATOCPage = 'CA TOC Page',
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
local function page_break_block() return pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>') end

-- Concatenates strings, single inlines and inline lists (MetaInlines or plain lists) into one list. A table
-- constructor cannot do this: table.unpack is truncated to one value unless it comes last.
local function cat(...)
  local out = pandoc.List()
  for _, x in ipairs({ ... }) do
    if type(x) == 'string' then out:insert(pandoc.Str(x))
    elseif x.t and not tostring(x.t):match('^Meta') then out:insert(x)
    else for _, y in ipairs(x) do out:insert(y) end end
  end
  return out
end

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
local function count_plain(blocks)
  local s = pandoc.write(pandoc.Pandoc(blocks), 'plain')
  s = s:gsub('%[%d+%]', ' ')
  s = s:gsub('\194\160', ' ')
  local n = 0
  for _ in s:gmatch('%S+') do n = n + 1 end
  return n
end

-- List markers are not words (typst strips them too): each item is counted without its marker.
local function count_words(blocks)
  local n, run = 0, pandoc.List()
  local function flush() if #run > 0 then n = n + count_plain(run); run = pandoc.List() end end
  for _, b in ipairs(blocks) do
    if b.t == 'OrderedList' or b.t == 'BulletList' then
      flush()
      for _, item in ipairs(b.content) do n = n + count_words(item) end
    else run:insert(b) end
  end
  flush()
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

-- The filing attorney's block after the conclusion (typst signature-block): "Respectfully submitted,", then
-- "s/ Name" and the name in capitals, the office lines, and the date after the block.
local function signature_blocks(m)
  local sig = m.signature
  local signer = pandoc.utils.stringify(sig.signer)
  local out = {}
  out[#out + 1] = para('CASignatureGap', { pandoc.Str('Respectfully submitted,') })
  out[#out + 1] = para('CASignature', cat('s/ ' .. signer, BR(), signer:upper()))
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do
    out[#out + 1] = para(i < #lines and 'CASignatureLineKeep' or 'CASignatureLine', l)
  end
  if m.date then out[#out + 1] = para('CADate', m.date) end
  return out
end

-- The signature of a certificate (typst signature-block-compact): not indented, the date after it.
local function signature_compact(m)
  local sig = m.signature
  local signer = pandoc.utils.stringify(sig.signer)
  local out = { para('CACertSig', cat('s/ ' .. signer, BR(), signer:upper())) }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = para('CACertSigLine', l) end
  if m.date then out[#out + 1] = para('CADate', m.date) end
  return out
end

local function signature_has_oral(blocks)
  for _, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 and pandoc.utils.stringify(b.content):lower():match('oral argument') then return true end
  end
  return false
end

function Pandoc(doc)
  local meta = doc.meta
  local auth = authorities_of(meta)
  local basis = meta.word_limit_basis and pandoc.utils.stringify(meta.word_limit_basis) or 'standard'
  if not WORD_LIMITS[basis] then error('ca6-brief: unknown word_limit_basis `' .. basis .. '`') end

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

  -- The addendum (after "# Addendum") sits after the certificates.
  local main, add = pandoc.List(), nil
  for i, b in ipairs(blocks) do
    if b.t == 'Header' and b.level == 1 and pandoc.utils.stringify(b.content):lower():match('^%s*addendum%s*$') then
      add = pandoc.List({ table.unpack(blocks, i + 1) })
      break
    end
    main:insert(b)
  end
  if meta.oral_argument and not signature_has_oral(main) then
    error('ca6-brief: oral_argument is set but the brief has no statement in support of oral argument')
  end

  -- The statements before the Argument (preliminary_sections of them) are roman, in the front matter.
  local prelim_n = meta.preliminary_sections and tonumber(pandoc.utils.stringify(meta.preliminary_sections)) or 0
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

  -- FRAP 32(f) excludes the statement regarding oral argument from the count (typst: counted-md): any top-level
  -- section whose heading names oral argument is left out.
  local counted, skipping = pandoc.List(), false
  for _, b in ipairs(main) do
    if b.t == 'Header' and b.level == 1 then
      skipping = pandoc.utils.stringify(b.content):lower():match('oral argument') ~= nil
    end
    if not skipping then counted:insert(b) end
  end
  local words = count_words(counted)
  local limit = WORD_LIMITS[basis]
  if words > limit then
    error('ca6-brief: the brief has ' .. words .. ' words; the ' .. basis .. ' limit is ' .. limit)
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

  local prelim = body_items(prelim_blocks, false)
  for _, it in ipairs(prelim) do if it.kind == 'head' then it.where = 'front' end end
  -- typst starts the statements before the Argument on a new page (its `set page` for them)
  if prelim[1] and prelim[1].kind == 'head' then prelim[1].style = 'CASectionNewPage' end
  local body = body_items(body_blocks, true)
  local addendum = add and body_items(add, false) or nil

  local function fixed(text, style, where)
    return head(1, nil, pandoc.Inlines({ pandoc.Str(text) }), style, nil, false, true, where)
  end
  local h_toa = fixed('Table of Authorities', 'CASectionNewPage', 'front')
  local h_cert = fixed('Certificate of Compliance', 'CASectionNewPage', 'body')
  local h_serv = fixed('Certificate of Service', 'CASection', 'body')
  local h_add = add and fixed('Addendum', 'CASection', 'body') or nil

  -- The TOC (typst: outline of every outlined heading): the Table of Authorities, the statements before the
  -- Argument, the body's headings, the certificates, and the Addendum entry. The addendum's own headings are
  -- listed in the addendum's contents (level 2 only, as in typst), not here.
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

  -- ---- the cover (FRAP 32(a)(2); CA6-COVER-001 to -007) ----
  local function cover()
    local out = {}
    out[#out + 1] = para('CACoverBold', cat('Case No. ', meta.case_number))
    out[#out + 1] = blank('CARule1')
    out[#out + 1] = blank('CARule2')
    out[#out + 1] = para('CACoverBold', { pandoc.Str('UNITED STATES COURT OF APPEALS'), BR(), pandoc.Str('FOR THE SIXTH CIRCUIT') })
    out[#out + 1] = blank('CAShortRule')
    -- A side marked `continues` follows the one before it without "v." (CA6-COVER-003).
    for i, side in ipairs(meta.caption) do
      if i > 1 and not side.continues then out[#out + 1] = para('CACover', { pandoc.Str('v.') }) end
      for _, n in ipairs(side.names) do out[#out + 1] = para('CACover', n) end
      out[#out + 1] = para('CACoverLeft', side.designation)
    end
    out[#out + 1] = blank('CAShortRule')
    out[#out + 1] = para('CACover', meta.proceeding)
    out[#out + 1] = blank('CAShortRule')
    out[#out + 1] = para('CACoverTitle', meta.brief_title)
    if meta.oral_argument then out[#out + 1] = para('CACoverBold', { pandoc.Str('ORAL ARGUMENT REQUESTED') }) end
    out[#out + 1] = blank('CAShortRule')
    -- Counsel at 40% of the text width (FRAP 32(a)(2)(F)): name, office address, telephone number.
    for gi, g in ipairs(meta.counsel) do
      for _, n in ipairs(g.names) do out[#out + 1] = para('CACounselName', n) end
      for _, l in ipairs(g.lines or {}) do out[#out + 1] = para('CACounselLine', l) end
      if gi == #meta.counsel then out[#out + 1] = para('CACounselLine', meta.phone) end
    end
    out[#out + 1] = blank('CARule1')
    out[#out + 1] = blank('CARule2')
    return out
  end

  -- The corporate disclosure (6th Cir. R. 26.1; typst disclosure-page): its own page, no number.
  local function disclosure()
    local d = meta.disclosure
    local out = {}
    out[#out + 1] = para('CADisclosureTitle', { pandoc.Str('DISCLOSURE OF CORPORATE AFFILIATIONS AND FINANCIAL INTEREST') })
    out[#out + 1] = para('CASingle', cat('Pursuant to 6th Cir. R. 26.1, ', d.party, ' makes the following disclosure:'))
    out[#out + 1] = para('CADisclosureItem', cat('1.', TAB(), 'Is said party a subsidiary or affiliate of a publicly owned corporation? If yes, list below the identity of the parent corporation or affiliate and the relationship between it and the named party:'))
    out[#out + 1] = para('CADisclosureAnswer', d.subsidiary)
    out[#out + 1] = para('CADisclosureItem', cat('2.', TAB(), 'Is there a publicly owned corporation, not a party to the appeal, that has a financial interest in the outcome? If yes, list the identity of such corporation and the nature of the financial interest:'))
    out[#out + 1] = para('CADisclosureAnswer', d.financial_interest)
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

  -- ---- section 2: the corporate disclosure, when the frontmatter has one (no page number) ----
  if meta.disclosure then
    for _, b in ipairs(disclosure()) do push(b) end
    push(section_break('rIdFtrNone', nil))
  end

  -- ---- section 3: front matter, lowercase roman numerals ----
  local toc_title = para('CATOCTitle', { pandoc.Str('Table of Contents') })
  toc_title.attributes['ca6-s'] = 'front'
  push(toc_title)
  push(para('CATOCPage', { pandoc.Strong({ pandoc.Underline({ pandoc.Str('Page') }) }) }))
  push(toc_table(toc))
  for _, b in ipairs(toa_blocks()) do push(b) end
  for _, it in ipairs(prelim) do
    if it.kind == 'head' then push(heading_block(it)) else push(it) end
  end
  push(section_break('rIdFtrPage', 'lowerRoman'))

  -- ---- section 4: the body (arabic from 1), the certificates ----
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

  -- Certificate of Compliance (FRAP 32(g)(1); typst certificate-of-compliance).
  push(heading_block(h_cert))
  push(para('CAKeep', { pandoc.Str('I certify that this brief complies with the type-volume limitation of Fed. R. App. P. ' ..
    WORD_LIMIT_RULE[basis] .. '. Exclusive of the items exempted by Fed. R. App. P. 32(f), the brief contains ' ..
    group_digits(words) .. ' words.') }))
  push(para('CAKeep', { pandoc.Str('The brief has been prepared in a proportionally spaced typeface, ' .. FONT .. ' in 14-point type, ' ..
    'which complies with Fed. R. App. P. 32(a)(5) and (6).') }))
  for _, b in ipairs(signature_compact(meta)) do push(b) end

  -- Certificate of Service (FRAP 25(d); typst certificate-of-service): served through CM/ECF.
  local svc = meta.service
  push(heading_block(h_serv))
  push(para('CAKeep', cat('I certify that on ', svc.date, ', I electronically filed the foregoing with the Clerk of the Court using the CM/ECF system, which will send notification of such filing to all attorneys of record.')))
  local unreg = svc.unregistered or {}
  if #unreg > 0 then
    push(para('CAKeep', { pandoc.Str('I further certify that I have mailed by United States Postal Service the document to the following non-ECF participants:') }))
    for _, u in ipairs(unreg) do push(para('CAServiceAddress', cat(u.name, ', ', u.address))) end
  end
  for _, b in ipairs(signature_compact(meta)) do push(b) end

  -- ---- section 5: the addendum (6 Cir. R. 28(b)(1)(A)(i)), numbered Add-1, Add-2 ----
  if add then
    push(section_break('rIdFtrPage', 'decimal'))
    local hb = heading_block(h_add)
    hb.attributes['ca6-s'] = 'add'
    push(hb)
    push(para('CATOCTitle', { pandoc.Str('Table of Contents') }))
    if #add_toc > 0 then push(toc_table(add_toc)) end
    push(page_break_block())
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
