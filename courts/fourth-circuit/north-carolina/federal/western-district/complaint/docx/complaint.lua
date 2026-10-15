-- complaint.lua (docx engine, ncwd complaint). What pandoc's default conversion does not give the template
-- (docs/DOCX.md, "Use the Word-native feature when one exists"), built from the sample's frontmatter and body
-- exactly as ncwd-complaint.typ builds it:
--   * the court title (three bold centered lines; the division when the sample gives one);
--   * the caption as a borderless three-column table: the party column with one line per row, a ")" column the
--     same height, and the right column with "Civil Action No." and the title (bold) and the jury legend;
--   * the lead-in and the first allegation after the caption begin 24 pt below it;
--   * every plain paragraph of the body is an allegation, numbered 1, 2, ... (Fed. R. Civ. P. 10(b)); a `>`
--     chunk is unnumbered; an ordered list (the prayer) is lettered A., B., ...;
--   * the signature block: "Dated:", "Respectfully submitted," and each firm's block at the right half, kept
--     together (keep-with-next), with the signer's "By: /s/" line;
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

-- Court title: the last line takes the space before the caption (the typst court-title's `below`).
local function court_title(meta)
  local lines = { { txt('IN THE UNITED STATES DISTRICT COURT'), true }, { txt('FOR THE WESTERN DISTRICT OF NORTH CAROLINA'), true } }
  if plain(meta.division) ~= '' then
    table.insert(lines, { inl(meta.division), true })
  end
  local out = {}
  for k, l in ipairs(lines) do
    local content = { pandoc.Strong(l[1]) }
    if k == #lines then
      table.insert(out, P('Court Title End', content))
    else
      table.insert(out, P('Court Title', content))
    end
  end
  return out
end

-- The caption: parties, then "v." between parties; each row is one line in every column.
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
  local right = {}
  if plain(meta.case_number) ~= '' then
    table.insert(right, P('Caption Right', cat(txt('Civil Action No. '), inl(meta.case_number))))
  else
    table.insert(right, P('Caption Right', txt('Civil Action No.:')))
  end
  for k, l in ipairs(meta.title) do
    table.insert(right, P(k == 1 and 'Caption Right Gap' or 'Caption Right', { pandoc.Strong(inl(l)) }))
  end
  if meta.jury_demand then
    table.insert(right, P('Caption Right Gap', { pandoc.Strong(txt('JURY TRIAL DEMANDED')) }))
  end
  -- 3.0 in party column, 0.3 in ")" column, the restfor the right column (6.5 in text width).
  local colspecs = { { pandoc.AlignDefault, 3.1 / 6.5 }, { pandoc.AlignDefault, 0.3 / 6.5 }, { pandoc.AlignDefault, 3.1 / 6.5 } }
  local row = pandoc.Row({ pandoc.Cell(left), pandoc.Cell(mark), pandoc.Cell(right) })
  return pandoc.Table({}, colspecs, pandoc.TableHead({}), { { attr = pandoc.Attr(), row_head_columns = 0, head = {}, body = { row } } }, pandoc.TableFoot({}))
end

-- Signature block (Fed. R. Civ. P. 11(a)); every line but the last is kept with the next.
local function signature(sig)
  local entries = { { 'SigDate', cat(txt('Dated: '), inl(sig.date)) }, { 'SigGap', txt('Respectfully submitted,') } }
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

local function letter(k) return string.char(64 + k) .. '.' end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, b in ipairs(court_title(meta)) do table.insert(out, b) end
  table.insert(out, caption(meta))
  local first = true
  if meta.lead_in ~= nil then
    table.insert(out, P('Lead In', inl(meta.lead_in)))
    first = false
  end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == 'Para' then
      n = n + 1
      local p = pandoc.Para(cat(txt(tostring(n) .. '.'), { TAB }, b.content))
      if first then p = pandoc.Div({ p }, style('Lead In')); first = false end
      table.insert(out, p)
    elseif b.t == 'OrderedList' then
      for k, item in ipairs(b.content) do
        local first_block = item[1]
        local inls = (first_block.t == 'Plain' or first_block.t == 'Para') and first_block.content or {}
        table.insert(out, P('List Item', cat(txt(letter(k)), { TAB }, inls)))
      end
    elseif b.t == 'BlockQuote' then
      for _, q in ipairs(b.content) do table.insert(out, q) end
    else
      table.insert(out, b)
    end
  end
  for _, b in ipairs(signature(meta.signature)) do table.insert(out, b) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
