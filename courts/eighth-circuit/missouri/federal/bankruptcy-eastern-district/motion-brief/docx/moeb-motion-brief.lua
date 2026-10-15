-- moeb-motion-brief.lua: pandoc filter for the moeb motion (with an optional supporting memorandum), docx engine.
-- Builds what typst/moeb-motion-brief.typ builds from the sample's frontmatter and body: the court title, the
-- caption (a table: debtor and movant/respondent left, with a rule on the right and the bottom; case block right),
-- the title, the lead-in, numbered paragraphs (literal numbers, as in the typst template), `%` and `%%` paragraphs,
-- footnotes (pandoc's own, in the Footnote Text style), the signature block and the certificate of service.
-- Styles (EB Garamond, spacing, tab stops, footer page number) are in docx/reference.docx (make-reference.sh).
-- Nothing here is case-specific: every case word comes from the sample.

local NBSP = '\u{00A0}'

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

-- Inline markdown in a string (names with *et al.*, section signs, bold) as inline elements.
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
-- Caption (L.R. 9004(A); Local Form 22). A two-column table, no borders except the left cell's right and bottom
-- rules. Widths in twips: left 3.6 in, gutter 0.25 in, right 2.65 in (text starts 0.15 in in).
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
  if plain(meta.motion_number) ~= '' then
    rows[#rows + 1] = 'Motion No. ' .. plain(meta.motion_number)
  end
  for _, h in ipairs(lines(meta.hearing)) do rows[#rows + 1] = h end
  if plain(meta.response_date) ~= '' then rows[#rows + 1] = plain(meta.response_date) end
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
-- Typography (typst: NBSP after "U.S.C.", before and after "§", so "§ 548" never splits).
-- ---------------------------------------------------------------------------

local JOINS = { ['U.S.C.'] = true, ['§'] = true, ['§§'] = true }

local function fix_inlines(ils)
  local out = {}
  for i, el in ipairs(ils) do
    local prev, nxt = ils[i - 1], ils[i + 1]
    if el.t == 'Space' and ((prev and prev.t == 'Str' and JOINS[prev.text]) or (nxt and nxt.t == 'Str' and JOINS[nxt.text])) then
      out[#out + 1] = pandoc.Str(NBSP)
    else
      out[#out + 1] = el
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Body: numbered paragraphs, `%`/`%%` paragraphs; headings, lists and block quotes pass through (Heading 1-3 and
-- Body styles). Footnotes are pandoc's own (the definitions are not blocks, so they are not numbered).
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
-- Signature block (typst grid: "Date" in the left 3 in, the rest from 3.2 in) and the certificate of service
-- (L.R. 9004(D)): paragraphs, the persons served (one entry per block of lines), then the date and signature.
-- ---------------------------------------------------------------------------

local function date_line(date_text, right_text)
  local ils = { pandoc.Str('Date:'), pandoc.Space() }
  for _, i in ipairs(md(date_text)) do ils[#ils + 1] = i end
  ils[#ils + 1] = tab()
  for _, i in ipairs(md(right_text)) do ils[#ils + 1] = i end
  return pandoc.Div({ pandoc.Para(ils) }, { ['custom-style'] = 'Signature Block' })
end

local function signature(meta)
  local s = meta.signature
  local out = { blank('Blank Line') }
  out[#out + 1] = date_line(plain(s.date), 'Respectfully Submitted,')
  out[#out + 1] = blank('Signature Right')
  out[#out + 1] = div('Signature Right', md(plain(s.firm)))
  out[#out + 1] = blank('Signature Right')
  out[#out + 1] = div('Signature Right', md('By: ' .. plain(s.by)))
  for _, a in ipairs(lines(s.attorneys)) do out[#out + 1] = div('Signature Right', md(a)) end
  for _, l in ipairs(lines(s.lines)) do out[#out + 1] = div('Signature Right', md(l)) end
  -- The typst signature block ends the body chunk; the certificate is a separate block, so the chain of
  -- keep-with-next stops at the last signature line.
  local last = out[#out]
  out[#out] = pandoc.Div(last.content, { ['custom-style'] = 'Signature Right Last' })
  return out
end

local function certificate(meta)
  assert(meta.certificate, 'moeb-motion-brief: every motion needs a certificate of service (L.R. 9004(D))')
  local c = meta.certificate
  local out = { blank('Blank Line'), div('Certificate Heading', md('CERTIFICATE OF SERVICE')) }
  -- The certificate is one block in typst: every line keeps with the next, so it moves to a page as a whole.
  for _, p in ipairs(c.paragraphs) do
    out[#out + 1] = div('Unnumbered Paragraph Keep', inlines(p))
  end
  if c.served then
    out[#out + 1] = blank('Blank Line')
    for _, entry in ipairs(c.served) do
      local ils = {}
      for j, row in ipairs(entry) do
        for _, i in ipairs(inlines(row)) do ils[#ils + 1] = i end
        if j < #entry then ils[#ils + 1] = pandoc.LineBreak() end
      end
      out[#out + 1] = div('Served Entry Keep', ils)
    end
    out[#out + 1] = blank('Signature Right')
  end
  out[#out + 1] = date_line(plain(c.date), plain(c.signature))
  return out
end

function Pandoc(doc)
  local blocks = pandoc.Pandoc(doc.blocks):walk({
    Inlines = fix_inlines,
  }).blocks

  -- The court name (fixed text, not case-specific): three lines, centered and bold by the Court Title style.
  local court = md('UNITED STATES BANKRUPTCY COURT')
  court[#court + 1] = pandoc.LineBreak()
  for _, i in ipairs(md('EASTERN DISTRICT OF MISSOURI')) do court[#court + 1] = i end
  court[#court + 1] = pandoc.LineBreak()
  for _, i in ipairs(md('EASTERN DIVISION')) do court[#court + 1] = i end

  local cover = {
    div('Court Title', court),
    caption_table(doc.meta),
    div('Caption Title', inlines(doc.meta.title)),
  }
  if doc.meta.lead_in then cover[#cover + 1] = div('Unnumbered Paragraph', inlines(doc.meta.lead_in)) end

  local all = {}
  for _, b in ipairs(cover) do all[#all + 1] = b end
  for _, b in ipairs(body(blocks)) do all[#all + 1] = b end
  for _, b in ipairs(signature(doc.meta)) do all[#all + 1] = b end
  for _, b in ipairs(certificate(doc.meta)) do all[#all + 1] = b end
  return pandoc.Pandoc(all, pandoc.Meta({}))
end
