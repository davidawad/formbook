-- cit-motion-brief.lua: pandoc filter for the CIT motion for judgment on the agency record, docx engine
-- (see ../README.md, "Engines"). Mirrors typst/cit-motion-brief.typ: the motion cover with the motion's
-- paragraphs and signature, the memorandum cover with the counsel block, the contents and authorities
-- pages, the memorandum body, the signature block and the Chambers word-count certificate. Paragraph
-- formats live in reference.docx (make-reference.sh); raw WordprocessingML only for covers, caption,
-- counsel and signature blocks, which are tables and lines pandoc cannot style per cell.
--
-- BLOCKED in this engine (see README "Engines"): the table of contents and the table of authorities
-- are placeholders. They need page numbers from a first render, which this filter does not do.

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')
local BREAK_RUN = '<w:r><w:br w:type="page"/></w:r>'
local WORD_LIMIT = 14000 -- Chambers Procedures 2(B)(1)(a)

-- Text width 6 1/2 in = 9360 twips. Caption columns: party 3.4 in, ")" 0.3 in, court number the rest.
local CAP_LEFT, CAP_PAREN, CAP_RIGHT = 4896, 432, 4032
local DESIG_INDENT = 1728 -- 1.2 in

local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'
local DOUBLE = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
local CENTER = '<w:jc w:val="center"/>'
local BOLD = '<w:b/>'

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function text_of(x)
  return pandoc.utils.stringify(x)
end

local function xpara(runs, ppr)
  return '<w:p>' .. (ppr and ('<w:pPr>' .. ppr .. '</w:pPr>') or '') .. (runs or '') .. '</w:p>'
end

local function xrun(s, rpr)
  return '<w:r>' .. (rpr and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
    '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

local function raw_para(runs, ppr)
  return pandoc.RawBlock('openxml', xpara(runs, ppr))
end

-- An empty line of the body's double pitch (typst v(pitch)).
local function spacer()
  return raw_para('', DOUBLE)
end

-- Half a line (typst v(pitch * 0.5)).
local function half_spacer()
  return raw_para('', '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>')
end

local function cell(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. paras .. '</w:tc>'
end

local function xtable(widths, rows)
  local total = 0
  local grid = {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return pandoc.RawBlock('openxml',
    '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>')
end

-- Caption (Rule 10(a)): each side's names, a designation, a ")" on every row, the joining word
-- ("v.", "and") centered between the sides, and the court number at the right of the first row.
local function caption(meta)
  local lines = {}
  for i, side in ipairs(meta.caption) do
    for _, n in ipairs(side.names) do
      lines[#lines + 1] = { text = text_of(n) }
    end
    lines[#lines + 1] = { text = text_of(side.designation), indent = DESIG_INDENT }
    if i < #meta.caption then
      lines[#lines + 1] = { text = side.between and text_of(side.between) or 'v.', center = true }
    end
  end
  local rows = {}
  for k, l in ipairs(lines) do
    local ppr = SINGLE
    if l.center then ppr = ppr .. CENTER
    elseif l.indent then ppr = ppr .. '<w:ind w:left="' .. l.indent .. '"/>' end
    local right
    if k == 1 then
      local court = xpara(xrun('Ct. No. ' .. text_of(meta.court_no)), SINGLE .. '<w:ind w:left="288"/>')
      if meta.before then
        court = court .. xpara(xrun('Before: ' .. text_of(meta.before)), SINGLE .. '<w:ind w:left="288"/>')
      end
      right = cell(CAP_RIGHT, court, '<w:vMerge w:val="restart"/>')
    else
      right = cell(CAP_RIGHT, xpara('', SINGLE), '<w:vMerge/>')
    end
    rows[#rows + 1] = '<w:tr>' ..
      cell(CAP_LEFT, xpara(xrun(l.text), ppr)) ..
      cell(CAP_PAREN, xpara(xrun(')'), SINGLE)) ..
      right .. '</w:tr>'
  end
  return xtable({ CAP_LEFT, CAP_PAREN, CAP_RIGHT }, rows)
end

-- Court name, caption, party and title: the cover of the motion and of the memorandum. With brk, the
-- cover starts a new page: the page break is the first run of its first line (no empty paragraph
-- that could spill onto a page of its own after a full signature block).
local function cover_page(meta, title, brk)
  local out = {}
  for i, l in ipairs(meta.court) do
    out[#out + 1] = raw_para((brk and i == 1 and BREAK_RUN or '') .. xrun(text_of(l):upper(), BOLD), SINGLE .. CENTER)
  end
  out[#out + 1] = spacer()
  out[#out + 1] = caption(meta)
  out[#out + 1] = spacer()
  out[#out + 1] = raw_para(xrun(text_of(meta.party):upper(), BOLD), SINGLE .. CENTER)
  out[#out + 1] = half_spacer()
  out[#out + 1] = raw_para(xrun(title:upper(), BOLD), SINGLE .. CENTER)
  return out
end

-- Signature block (Rule 11(a)): "Dated" at left, the signer and counsel lines at right.
local function signature(meta)
  local sig = meta.signature
  local right = {}
  right[#right + 1] = xpara(xrun('Respectfully submitted,'), SINGLE)
  right[#right + 1] = xpara('', '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>')
  right[#right + 1] = xpara(xrun('/s/ ' .. text_of(sig.signer)), SINGLE)
  for _, l in ipairs(sig.lines) do
    right[#right + 1] = xpara(xrun(text_of(l)), SINGLE)
  end
  local row = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(3744, xpara(xrun('Dated: ' .. text_of(meta.date)), SINGLE)) ..
    cell(5616, table.concat(right)) .. '</w:tr>'
  return { spacer(), xtable({ 3744, 5616 }, { row }) }
end

-- Counsel block on the memorandum cover: single spaced, at 3.3 in from the left margin (3.2 in wide).
local function counsel(meta)
  local out = {}
  for _, l in ipairs(meta.counsel) do
    out[#out + 1] = raw_para(xrun(text_of(l)), SINGLE .. '<w:ind w:left="4752"/>')
  end
  return out
end

-- Words of the body (Chambers 2(B)(1)(c)): headings, footnotes and quotations count; markup does not.
-- Counted on pandoc's plain-text rendering of the body (whitespace-delimited); the footnote markers the
-- plain writer prints ("[1]") are not words and are taken out. This is within a few words of the typst count.
local function count_words(blocks)
  local plain = pandoc.write(pandoc.Pandoc(blocks), "plain")
  local n, notes = 0, 0
  pandoc.Pandoc(blocks):walk({ Note = function() notes = notes + 1 end })
  for _ in plain:gmatch("%S+") do n = n + 1 end
  return n - notes
end

local function commas(n)
  local s = tostring(n)
  local k
  repeat
    s, k = s:gsub('^(%d+)(%d%d%d)', '%1,%2')
  until k == 0
  return s
end

-- Lettered or bulleted list items in the motion (its relief list): one paragraph per item, bulleted.
local function bullets(list)
  local out = {}
  for _, item in ipairs(list.content) do
    local inl = { pandoc.Str('\u{2022}'), TAB }
    if item[1] and (item[1].t == 'Plain' or item[1].t == 'Para') then
      for _, x in ipairs(item[1].content) do inl[#inl + 1] = x end
    end
    local blocks = { pandoc.Para(inl) }
    for j = 2, #item do blocks[#blocks + 1] = item[j] end
    out[#out + 1] = pandoc.Div(blocks, { ['custom-style'] = 'CIT Item' })
  end
  return out
end

-- A heading in raw WordprocessingML (Heading 1 style), optionally starting a new page.
local function heading_raw(text, brk)
  return pandoc.RawBlock('openxml', '<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr>' ..
    (brk and BREAK_RUN or '') .. xrun(text) .. '</w:p>')
end

-- Placeholder for a part the docx engine does not build (see README "Engines", BLOCKED).
local function blocked_note(what)
  return raw_para(xrun('[' .. what .. ' not generated by the docx engine: BLOCKED, Rule 56.2(c)(2); see README "Engines".]',
    '<w:i/>'), CENTER)
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}

  -- Words first: the limit is a hard error, as in the typst engine.
  local words = count_words(doc.blocks)
  if words > WORD_LIMIT then
    error('cit-motion-brief: the body has ' .. words .. ' words; Chambers Procedures 2(B)(1)(a) limit is ' .. WORD_LIMIT)
  end

  -- ---- motion cover, the motion, signature ----
  for _, b in ipairs(cover_page(meta, text_of(meta.brief_title), false)) do out[#out + 1] = b end
  out[#out + 1] = spacer()
  -- `motion` is a markdown block value (a list of blocks); a single line of inlines is wrapped in a Para.
  -- The last paragraph (WHEREFORE) keeps with the signature block, as in the typst engine.
  local motion = meta.motion
  local blocks = motion.t == 'MetaInlines' and { pandoc.Para(motion) } or motion
  for i, b in ipairs(blocks) do
    if b.t == 'BulletList' then
      for _, d in ipairs(bullets(b)) do out[#out + 1] = d end
    elseif b.t == 'Para' and i == #blocks then
      out[#out + 1] = pandoc.Div({ b }, { ['custom-style'] = 'CIT Keep' })
    else
      out[#out + 1] = b
    end
  end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end

  -- ---- memorandum cover, counsel block, date ----
  for _, b in ipairs(cover_page(meta, text_of(meta.memo_title), true)) do out[#out + 1] = b end
  out[#out + 1] = spacer()
  for _, b in ipairs(counsel(meta)) do out[#out + 1] = b end
  out[#out + 1] = spacer()
  out[#out + 1] = raw_para(xrun('Dated: ' .. text_of(meta.date)), CENTER)

  -- ---- contents and authorities: BLOCKED (see README "Engines") ----
  out[#out + 1] = heading_raw('Table of Contents', true)
  out[#out + 1] = blocked_note('Table of contents')
  out[#out + 1] = heading_raw('Table of Authorities', true)
  out[#out + 1] = blocked_note('Table of authorities')

  -- ---- memorandum body: citations (toa: links) become plain text; the first block starts a new page ----
  local body = pandoc.Pandoc(doc.blocks):walk({
    Link = function(l)
      if l.target:sub(1, 4) == 'toa:' then return l.content end
    end,
  })
  local first = body.blocks[1]
  if first and (first.t == 'Header' or first.t == 'Para') then
    table.insert(first.content, 1, pandoc.RawInline('openxml', BREAK_RUN))
  end
  for _, b in ipairs(body.blocks) do out[#out + 1] = b end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end

  -- ---- Chambers 2(B)(2) certificate of compliance ----
  out[#out + 1] = heading_raw('Certificate of Compliance', true)
  out[#out + 1] = raw_para(xrun(
    'This brief has been prepared using a proportionally spaced typeface (EB Garamond, 12-point). ' ..
    'In accordance with the Standard Chambers Procedures of this Court, the undersigned certifies that ' ..
    'this brief contains ' .. commas(words) .. ' words, excluding the parts of the brief exempted by ' ..
    'Chambers Procedures 2(B)(1)(c). The count includes headings, footnotes and quotations.'),
    '<w:ind w:firstLine="720"/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>')
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end

  local meta_out = doc.meta
  meta_out.date = nil
  return pandoc.Pandoc(out, meta_out)
end
