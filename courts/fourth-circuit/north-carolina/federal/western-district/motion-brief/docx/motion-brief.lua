-- motion-brief.lua (docx engine, ncwd memorandum of law). What pandoc's default conversion does not give the
-- template (docs/DOCX.md, "Use the Word-native feature when one exists"), built from the sample's frontmatter
-- and body exactly as ncwd-motion-brief.typ builds it:
--   * the court title (three bold centered lines; the division when the sample gives one);
--   * the caption as a borderless three-column table: the party column (one line per row), a ")" column the same
--     height, and the right column with "Civil Action No." and the title (bold);
--   * the first paragraph of the body begins 24 pt below the caption;
--   * body paragraphs are not numbered (a brief is not a pleading); a `>` chunk is unindented; an ordered list is
--     numbered 1., 2., ... with a hanging indent;
--   * the signature block: the date line at the left, then each firm's block at the right half (3.0 in), kept
--     together, with the signer's "By: /s/" line;
--   * the AI certification (when the sample sets ai_certification) and the certificate of service (when the
--     sample has service), each with the wording of the template and the signature block after it.
-- The styles (spacing, indents, fonts) are in reference.docx (make-reference.sh). The frontmatter is removed
-- from the metadata so pandoc writes no title.

local function style(name) return pandoc.Attr('', {}, { ['custom-style'] = name }) end
local function P(name, inls) return pandoc.Div({ pandoc.Para(inls) }, style(name)) end
local function txt(s) return { pandoc.Str(s) } end
local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')

local function cat(...)
  local out = {}
  for _, t in ipairs({ ... }) do
    for _, i in ipairs(t) do table.insert(out, i) end
  end
  return out
end

-- A frontmatter value as inlines (strings and markdown values alike).
local function inl(v)
  if v == nil then return {} end
  if type(v) == 'string' then return v == '' and {} or txt(v) end
  if v.t == 'MetaInlines' then return pandoc.utils.blocks_to_inlines({ pandoc.Plain(v) }) end
  if v.t == 'MetaBlocks' then return pandoc.utils.blocks_to_inlines(v) end
  local s = pandoc.utils.stringify(v)
  return s == '' and {} or txt(s)
end

local function plain(v) return pandoc.utils.stringify(inl(v)) end

local function court_title(meta)
  local lines = { inl('UNITED STATES DISTRICT COURT'), inl('FOR THE WESTERN DISTRICT OF NORTH CAROLINA') }
  if plain(meta.division) ~= '' then table.insert(lines, inl(meta.division)) end
  local out = {}
  for k, l in ipairs(lines) do
    local content = { pandoc.Strong(l) }
    table.insert(out, P(k == #lines and 'Court Title End' or 'Court Title', content))
  end
  return out
end

local function caption(meta)
  local rows = {}
  local parties = meta.caption.parties
  for k = 1, #parties do
    if k > 1 then table.insert(rows, txt('v.')) end
    for _, l in ipairs(parties[k].lines) do table.insert(rows, inl(l)) end
    table.insert(rows, inl(parties[k].designation))
  end
  local left, mark = {}, {}
  for _, r in ipairs(rows) do
    table.insert(left, P('Caption Line', r))
    table.insert(mark, P('Caption Mark', txt(')')))
  end
  local right = { P('Caption Right', cat(txt('Civil Action No. '), inl(meta.case_number))) }
  for k, l in ipairs(meta.title) do
    table.insert(right, P(k == 1 and 'Caption Right Gap' or 'Caption Right', { pandoc.Strong(inl(l)) }))
  end
  -- 2.9 in party column, 0.3 in ")" column, the rest for the right column (6.5 in text width).
  local colspecs = { { pandoc.AlignDefault, 3.0 / 6.5 }, { pandoc.AlignDefault, 0.3 / 6.5 }, { pandoc.AlignDefault, 3.2 / 6.5 } }
  local row = pandoc.Row({ pandoc.Cell(left), pandoc.Cell(mark), pandoc.Cell(right) })
  return pandoc.Table({}, colspecs, pandoc.TableHead({}), { { attr = pandoc.Attr(), row_head_columns = 0, head = {}, body = { row } } }, pandoc.TableFoot({}))
end

-- Signature block (Fed. R. Civ. P. 11(a)): the date line, then the firm blocks; every line but the last is kept
-- with the next. Used after the memorandum, the AI certification and the certificate of service.
local function signature(sig)
  local entries = { { 'SigDate', inl(sig.date_line) } }
  for _, b in ipairs(sig.blocks) do
    local first = true
    local function add(i)
      table.insert(entries, { first and 'SigGap' or 'SigLine', i })
      first = false
    end
    add(inl(b.firm))
    if b.by ~= nil and plain(b.by) ~= '' then add(cat(txt('By: /s/ '), inl(b.by))) end
    for _, l in ipairs(b.lines) do add(inl(l)) end
  end
  entries[#entries][1] = 'SigEnd'
  local out = {}
  for _, e in ipairs(entries) do table.insert(out, P(e[1], e[2])) end
  return out
end

-- The AI certification the June 18, 2024 Standing Order requires (wording as in ncwd-motion-brief.typ).
local function ai_certification(meta)
  local out = { pandoc.Header(1, txt('CERTIFICATION REGARDING USE OF ARTIFICIAL INTELLIGENCE')) }
  table.insert(out, pandoc.Para(cat(
    txt('Pursuant to the June 18, 2024 Standing Order of this Court '),
    { pandoc.Emph(txt('In Re: Use of Artificial Intelligence')) },
    txt(', 3:24-mc-104, counsel, by signing above, submits the following certification regarding '),
    inl(meta.ai_title), txt('.'))))
  table.insert(out, pandoc.Para(txt('1. No artificial intelligence was employed in doing the research for the preparation of this Memorandum, with the exception of such artificial intelligence embedded in the standard on-line legal research sources Westlaw, Lexis, FastCase, and Bloomberg, as well as Google and Google Scholar;')))
  table.insert(out, pandoc.Para(txt('2. Every statement and every citation to an authority contained in this Memorandum has been checked by the undersigned as to the accuracy of the proposition for which it is offered, and the citation to authority provided.')))
  for _, b in ipairs(signature(meta.signature)) do table.insert(out, b) end
  return out
end

-- The certificate of service: the filing, the counsel served, the date and the signature.
local function certificate_of_service(meta)
  local out = { pandoc.Header(1, txt('CERTIFICATE OF SERVICE')) }
  table.insert(out, pandoc.Para(cat(
    txt('This is to certify that the undersigned has this day electronically filed the foregoing '),
    inl(meta.service_title),
    txt(' with the Clerk of the Court using the CM/ECF system which will send notification of such filing to the following counsel of record:'))))
  for _, c in ipairs(meta.service.counsel) do
    local n = #c
    for k, line in ipairs(c) do
      local name = k == 1 and 'CounselGap' or (k == n and 'CounselEnd' or 'CounselLine')
      table.insert(out, P(name, inl(line)))
    end
  end
  for _, b in ipairs(signature(meta.signature)) do table.insert(out, b) end
  return out
end

local function letter_or_number(k) return tostring(k) .. '.' end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, b in ipairs(court_title(meta)) do table.insert(out, b) end
  table.insert(out, caption(meta))
  local first = true
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Para' and first then
      table.insert(out, P('Lead In', b.content))
      first = false
    elseif b.t == 'Para' then
      table.insert(out, b)
    elseif b.t == 'OrderedList' then
      first = false
      for k, item in ipairs(b.content) do
        local first_block = item[1]
        local inls = (first_block.t == 'Plain' or first_block.t == 'Para') and first_block.content or {}
        table.insert(out, P('List Item', cat(txt(letter_or_number(k)), { TAB }, inls)))
      end
    elseif b.t == 'BlockQuote' then
      first = false
      for _, q in ipairs(b.content) do
        if q.t == 'Para' then table.insert(out, pandoc.Div({ q }, style('Body Flush'))) else table.insert(out, q) end
      end
    else
      first = false
      table.insert(out, b)
    end
  end
  for _, b in ipairs(signature(meta.signature)) do table.insert(out, b) end
  if meta.ai_certification == true then
    for _, b in ipairs(ai_certification(meta)) do table.insert(out, b) end
  end
  if meta.service ~= nil then
    for _, b in ipairs(certificate_of_service(meta)) do table.insert(out, b) end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
