-- moeb-adversary-complaint.lua: pandoc filter for the moeb adversary complaint, docx engine.
-- Builds what typst/moeb-adversary-complaint.typ builds from the sample's frontmatter and body: the court title,
-- the caption (a table: debtor and parties left, with a rule on the right and the bottom; case block right), the
-- title, the lead-in, numbered paragraphs (literal numbers, as in the typst template), `%` and `%%` paragraphs,
-- the FRBP 7008(a) consent sentence, the signature block and the optional certificate of service.
-- Styles (EB Garamond, spacing, tab stops, footer page number) are in docx/reference.docx (make-reference.sh).
-- Nothing here is case-specific: every case word comes from the sample.

local NBSP = '\u{00A0}'
local CONSENT = '{{consent}}'

local function tab()
  return pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')
end

-- Metadata value as plain text (a caption line, a name, a date).
local function plain(v)
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

-- Metadata value as a list of plain lines (a list of names, or one line).
local function lines(v)
  local out = {}
  if v == nil then return out end
  if pandoc.utils.type(v) == 'List' then
    for _, x in ipairs(v) do out[#out + 1] = plain(x) end
  else
    out[1] = plain(v)
  end
  return out
end

-- Inline markdown in a string (names with *et al.*, bold placeholders, section signs) as inline elements.
local function md(s)
  local out = {}
  if s == nil or s == '' then return out end
  -- fancy_lists is off: a line such as "(314) 991-4999" is an address, not a list.
  for _, b in ipairs(pandoc.read(s, 'markdown-fancy_lists').blocks) do
    for _, i in ipairs(b.content or {}) do out[#out + 1] = i end
  end
  return out
end

-- Metadata value as inline elements: markdown already parsed by pandoc, or a plain string.
local function inlines(v)
  if v == nil then return {} end
  if type(v) == 'string' then return md(v) end
  return v
end

local function div(style, ils)
  return pandoc.Div({ pandoc.Para(ils) }, { ['custom-style'] = style })
end

local function blank(style)
  -- A blank line is a paragraph with a no-break space: an empty paragraph would be dropped by the writer.
  return pandoc.Div({ pandoc.Para({ pandoc.Str(NBSP) }) }, { ['custom-style'] = style or 'Blank Line' })
end

-- A paragraph marker at the start of a chunk: `%%` (centered) or `%` (unnumbered). Returns the inlines after
-- the marker, or nil when the chunk has no such marker.
local function strip(ils, marker)
  local first = ils[1]
  if not first or first.t ~= 'Str' or first.text:sub(1, #marker) ~= marker then return nil end
  local out = {}
  local rest = first.text:sub(#marker + 1)
  if rest ~= '' then out[1] = pandoc.Str(rest) end
  for i = 2, #ils do out[#out + 1] = ils[i] end
  while out[1] and out[1].t == 'Space' do table.remove(out, 1) end
  return out
end

-- ---------------------------------------------------------------------------
-- Caption (L.R. 9004(A); Fed. R. Bankr. P. 7010). A two-column table, no borders except the left cell's right
-- and bottom rules. Widths in twips: left 3.6 in, gutter 0.25 in, right 2.65 in (text starts 0.15 in in).
-- Cell text is plain (names carry no emphasis in this court's captions).
-- ---------------------------------------------------------------------------

local function esc(t)
  return (t:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function cell_p(style, text)
  local run = ''
  if text ~= '' then
    run = '<w:r><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. run .. '</w:p>'
end

local function cell_ps(rows)
  local out = {}
  for _, r in ipairs(rows) do out[#out + 1] = cell_p(r[1], r[2]) end
  return table.concat(out)
end

local function caption_left(meta)
  local rows = {}
  for _, l in ipairs(lines(meta.caption.debtor)) do rows[#rows + 1] = { 'CaptionCell', l } end
  local first_party = #rows + 1
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then rows[#rows + 1] = { 'CaptionCell', 'v.' } end
    for _, n in ipairs(lines(p.names)) do rows[#rows + 1] = { 'CaptionCell', n } end
    rows[#rows + 1] = { 'CaptionCell', plain(p.designation) }
  end
  -- The gap between the debtor and the parties (typst: v(0.5 line) in the caption block).
  if rows[first_party] then rows[first_party][1] = 'CaptionCellGap' end
  return rows
end

local function caption_right(meta)
  local rows = { 'Case No. ' .. plain(meta.case_number) }
  if meta.judge then rows[#rows + 1] = plain(meta.judge) end
  if meta.chapter then rows[#rows + 1] = plain(meta.chapter) end
  if plain(meta.adversary_number) ~= '' then
    rows[#rows + 1] = 'Adv. Proc. No. ' .. plain(meta.adversary_number)
  end
  for _, h in ipairs(lines(meta.hearing)) do rows[#rows + 1] = h end
  local out = {}
  for _, r in ipairs(rows) do out[#out + 1] = { 'CaptionCell', r } end
  return out
end

local function caption_table(meta)
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  local left = '<w:tc><w:tcPr><w:tcW w:w="5184" w:type="dxa"/>' .. rule .. '</w:tcPr>'
    .. cell_ps(caption_left(meta)) .. '</w:tc>'
  local gutter = '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr>' .. cell_p('CaptionCell', '') .. '</w:tc>'
  local right = '<w:tc><w:tcPr><w:tcW w:w="3816" w:type="dxa"/>'
    .. '<w:tcMar><w:left w:w="216" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. cell_ps(caption_right(meta)) .. '</w:tc>'
  local nil_border = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return pandoc.RawBlock('openxml', '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders>' .. nil_border .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5184"/><w:gridCol w:w="360"/><w:gridCol w:w="3816"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. left .. gutter .. right .. '</w:tr></w:tbl>')
end

-- ---------------------------------------------------------------------------
-- Consent (Fed. R. Bankr. P. 7008(a)) and the typographic joins (typst: NBSP after "U.S.C.", before and after
-- "§"). A sample without a `consent` value gets a bold placeholder, so an unfinished statement shows.
-- ---------------------------------------------------------------------------

local function consent_inlines(meta)
  local c = meta.consent and plain(meta.consent) or nil
  if c == nil then
    return md('**[COUNSEL TO STATE WHETHER PLAINTIFF CONSENTS OR DOES NOT CONSENT TO THE ENTRY OF FINAL ORDERS OR JUDGMENT BY THE BANKRUPTCY JUDGE, FED. R. BANKR. P. 7008(a)]**')
  end
  assert(c == 'consents' or c == 'does not consent', 'moeb-adversary-complaint: consent must be "consents" or "does not consent"')
  return md('Pursuant to Fed. R. Bankr. P. 7008(a), Plaintiff ' .. c .. ' to the entry of final orders or judgment by the bankruptcy judge.')
end

local JOINS = { ['U.S.C.'] = true, ['§'] = true, ['§§'] = true }

local function fix_inlines(ils, consent)
  local out = {}
  for i, el in ipairs(ils) do
    local prev, nxt = ils[i - 1], ils[i + 1]
    if el.t == 'Space' and ((prev and prev.t == 'Str' and JOINS[prev.text]) or (nxt and nxt.t == 'Str' and JOINS[nxt.text])) then
      out[#out + 1] = pandoc.Str(NBSP)
    elseif el.t == 'Str' and el.text:find(CONSENT, 1, true) then
      local at = el.text:find(CONSENT, 1, true)
      local before = el.text:sub(1, at - 1)
      local after = el.text:sub(at + #CONSENT)
      if before ~= '' then out[#out + 1] = pandoc.Str(before) end
      for _, c in ipairs(consent) do out[#out + 1] = c end
      if after ~= '' then out[#out + 1] = pandoc.Str(after) end
    else
      out[#out + 1] = el
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Body: numbered paragraphs, `%`/`%%` paragraphs; headings and block quotes pass through (Heading 1-3 styles).
-- ---------------------------------------------------------------------------

local function body(blocks)
  local out, n = {}, 0
  for i, b in ipairs(blocks) do
    if b.t == 'Para' then
      local keep = i == #blocks -- the last chunk stays with the signature block
      local centered = strip(b.content, '%%')
      local unnumbered = centered == nil and strip(b.content, '%') or nil
      if centered then
        out[#out + 1] = div('Centered Paragraph', centered)
      elseif unnumbered then
        out[#out + 1] = div(keep and 'Unnumbered Paragraph Keep' or 'Unnumbered Paragraph', unnumbered)
      else
        n = n + 1
        local ils = { pandoc.Str(n .. '.'), tab() }
        for _, x in ipairs(b.content) do ils[#ils + 1] = x end
        out[#out + 1] = div(keep and 'Numbered Paragraph Keep' or 'Numbered Paragraph', ils)
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (typst grid: "Date" in the left 3 in, the rest from 3.2 in) and certificate of service.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local s = meta.signature
  local out = { blank('Blank Line') }
  local date = { pandoc.Str('Date:'), pandoc.Space() }
  for _, i in ipairs(md(plain(s.date))) do date[#date + 1] = i end
  date[#date + 1] = tab()
  for _, i in ipairs(md('Respectfully submitted,')) do date[#date + 1] = i end
  out[#out + 1] = pandoc.Div({ pandoc.Para(date) }, { ['custom-style'] = 'Signature Block' })
  out[#out + 1] = blank('Signature Right')
  out[#out + 1] = div('Signature Right', md(plain(s.firm)))
  out[#out + 1] = blank('Signature Right')
  out[#out + 1] = div('Signature Right', md('By: ' .. plain(s.by)))
  for _, a in ipairs(lines(s.attorneys)) do out[#out + 1] = div('Signature Right', md(a)) end
  for _, l in ipairs(lines(s.lines)) do out[#out + 1] = div('Signature Right', md(l)) end
  return out
end

local function certificate(meta)
  if meta.certificate == nil then return {} end
  local out = { blank('Blank Line'), div('Certificate Heading', md('CERTIFICATE OF SERVICE')) }
  for _, p in ipairs(meta.certificate) do
    out[#out + 1] = div('Unnumbered Paragraph Keep', inlines(p))
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local consent = consent_inlines(meta)
  local blocks = doc.blocks

  -- Inline fixes in the body (joins and the consent sentence), in nested inline lists too.
  blocks = pandoc.Pandoc(blocks):walk({
    Inlines = function(ils) return fix_inlines(ils, consent) end,
  }).blocks

  -- The court name (fixed text, not case-specific): three lines, centered and bold by the Court Title style.
  local court = md('UNITED STATES BANKRUPTCY COURT')
  court[#court + 1] = pandoc.LineBreak()
  for _, i in ipairs(md('FOR THE EASTERN DISTRICT OF MISSOURI')) do court[#court + 1] = i end
  court[#court + 1] = pandoc.LineBreak()
  for _, i in ipairs(md('EASTERN DIVISION')) do court[#court + 1] = i end

  local cover = {
    div('Court Title', court),
    caption_table(meta),
    div('Caption Title', inlines(meta.title)),
  }
  if meta.lead_in then cover[#cover + 1] = div('Unnumbered Paragraph', inlines(meta.lead_in)) end

  local tail = {}
  for _, b in ipairs(signature(meta)) do tail[#tail + 1] = b end
  for _, b in ipairs(certificate(meta)) do tail[#tail + 1] = b end

  local all = {}
  for _, b in ipairs(cover) do all[#all + 1] = b end
  for _, b in ipairs(body(blocks)) do all[#all + 1] = b end
  for _, b in ipairs(tail) do all[#all + 1] = b end
  return pandoc.Pandoc(all, pandoc.Meta({}))
end
