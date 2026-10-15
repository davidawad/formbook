-- ned-motion-brief.lua (docx engine, brief in support of a motion): what the Word output adds to pandoc's default
-- conversion, to match motion-brief/typst/ned-motion-brief.typ (see ../README.md, "Engines"):
--   * page 1: the two court-title lines, the caption as a table with a right and a bottom rule on the party column,
--     the case number and the bold title;
--   * the lead-in paragraph ("COME NOW ...") and unnumbered body paragraphs with a first-line indent;
--   * facts lists numbered 1., 2., ... with a hanging indent;
--   * headings: level 1 centered bold capitals; level 2 bold with a hanging indent; level 3 bold italic;
--   * the signature block at 3.25 in, kept with the last paragraph;
--   * the certificate of compliance (NECivR 7.1(d)(3)) and the certificate of service (when the sample has one);
--   * the title and the case number go to the document properties (subject, description), which the footer's
--     SUBJECT and COMMENTS fields show from page 2 on (the footers are in reference.docx).
-- Like the typst template, the build stops when the stated word count is over 13,000 (NECivR 7.1(d)(1)(A)) or the
-- sample has no compliance block. Everything case-specific comes from the sample's frontmatter.

-- ---------------------------------------------------------------------------
-- Metadata values
-- ---------------------------------------------------------------------------

-- A metadata value as a list of inlines (a frontmatter string is markdown, so it arrives as MetaInlines).
local function inl(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == nil or v.t == "MetaInlines" then return v end -- a list of inlines
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- ---------------------------------------------------------------------------
-- Raw WordprocessingML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  s = s:gsub("&amp;", "&") -- pandoc can hand over an entity that is already encoded
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- Run properties from flags: bold, italic (in schema order).
local function rpr(f)
  local x = ""
  if f.b then x = x .. "<w:b/>" end
  if f.i then x = x .. "<w:i/>" end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function run(s, f)
  return '<w:r>' .. rpr(f or {}) .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

-- Inline content (markdown already parsed by pandoc) as runs. Emphasis, strong and smart quotes are kept.
local function runs(list, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, { b = f.b, i = true })
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = f.i })
    elseif t == "Span" then
      out[#out + 1] = runs(el.content, f)
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], f) .. runs(el.content, f) .. run(q[2], f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

-- Paragraph spacing in twips (1 pt = 20): space before, space after, exact line height.
local function sp(before, after, line)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before, after, line)
end

local DOUBLE = 480 -- body pitch, 24 pt
local SINGLE = 288 -- single spacing, 14.4 pt
local GAP = 132 -- the gap the typst template puts between blocks, 6.6 pt (see complaint/docx)
local HEAD_GAP = 310 -- space before a heading (its pitch above), as in the complaint reference

local function para(ppr, body)
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. body .. '</w:p>'
end

-- A blank line of a given height (the typst v(...) spaces): an empty exact-height paragraph.
local function spacer(line)
  return para(sp(0, 0, line), '')
end

-- Single-spaced lines at a left indent (twips, or nil), each with the gap before it (the first one gets `before`).
-- Every line but the last is kept with the next one (a signature or an address block must not split).
local function single_lines(items, indent, before)
  local out = {}
  for k, body in ipairs(items) do
    local last = k == #items
    local kn = (not last) and '<w:keepNext/>' or ''
    local ind = indent and string.format('<w:ind w:left="%d"/>', indent) or ''
    out[#out + 1] = para(kn .. '<w:keepLines/>' .. sp(k == 1 and before or 0, 0, SINGLE) .. ind, body)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Tables (the caption is a ruled table)
-- ---------------------------------------------------------------------------

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(grid, cells)
  local g = {}
  for _, w in ipairs(grid) do g[#g + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(g) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

local function cell(width, inner, tcpr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (tcpr or '') .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption
-- ---------------------------------------------------------------------------

local function court_title()
  return para('<w:keepNext/><w:keepLines/>' .. sp(0, 0, SINGLE) .. '<w:jc w:val="center"/>',
      run("IN THE UNITED STATES DISTRICT COURT", { b = true }))
    .. para('<w:keepNext/><w:keepLines/>' .. sp(0, 0, SINGLE) .. '<w:jc w:val="center"/>',
      run("FOR THE DISTRICT OF NEBRASKA", { b = true }))
end

local function caption(m)
  -- Party column: names, "v." between the parties; each designation is indented 1.5 in (2160 twips).
  local col = {}
  for pk, p in ipairs(m.caption.parties) do
    if pk > 1 then col[#col + 1] = { body = run("v."), ind = 0 } end
    for _, n in ipairs(p.names) do col[#col + 1] = { body = runs(inl(n)), ind = 0 } end
    col[#col + 1] = { body = runs(inl(p.designation)), ind = 2160 }
  end
  local lines = {}
  for j, c in ipairs(col) do
    local ind = c.ind > 0 and string.format('<w:ind w:left="%d"/>', c.ind) or ''
    local before = j == 1 and 80 or 0 -- 4 pt inset from the top of the box
    lines[#lines + 1] = para(sp(before, 0, SINGLE) .. ind, c.body)
  end
  local left_cell = cell(4680, table.concat(lines),
    '<w:tcBorders><w:right ' .. RULE .. '/><w:bottom ' .. RULE .. '/></w:tcBorders>'
    .. '<w:tcMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>')

  -- Right column: case number, then the bold title.
  local right = {}
  right[#right + 1] = para(sp(0, 0, SINGLE), run("Case No. ") .. runs(inl(m.case_number)))
  right[#right + 1] = para(sp(108, 0, SINGLE), runs(inl(m.brief_title), { b = true }))
  local right_cell = cell(4320, table.concat(right), '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>')
  local gutter = cell(360, para(sp(0, 0, SINGLE), ''))
  return table_xml({ 4680, 360, 4320 }, { left_cell, gutter, right_cell })
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates (NECivR 11.1(a)(1)(A) order; at 3.25 in, as in the typst template)
-- ---------------------------------------------------------------------------

local SIG_INDENT = 4680 -- 3.25 in
local RECIPIENT_INDENT = 720 -- 0.5 in

local function signature_lines(m)
  local sig = m.signature
  local lines = {}
  lines[#lines + 1] = run("s/ ") .. runs(inl(sig.signer))
  lines[#lines + 1] = run("Bar Number: ") .. runs(inl(sig.bar_number))
  lines[#lines + 1] = run("Attorney for ") .. runs(inl(sig.attorney_for))
  for _, l in ipairs(sig.firm) do lines[#lines + 1] = runs(inl(l)) end
  return lines
end

local function signature(m)
  return single_lines(signature_lines(m), SIG_INDENT, GAP)
end

-- The certificate heading: centered bold capitals, one heading gap above.
local function certificate_heading(title)
  return para('<w:keepNext/><w:keepLines/>' .. sp(HEAD_GAP, 0, SINGLE) .. '<w:jc w:val="center"/>',
    run(title, { b = true }))
end

-- A double-spaced paragraph after a certificate heading: first-line indent, the heading's gap above.
local function certificate_text(body)
  return para('<w:keepNext/><w:keepLines/>' .. sp(170, 0, DOUBLE) .. '<w:ind w:firstLine="720"/>', body)
end

local function compliance_certificate(m)
  if m.compliance == nil then
    error("ned-motion-brief: NECivR 7.1(d)(3) requires a certificate of compliance; add a `compliance` block")
  end
  local words = text(m.compliance.word_count)
  local count = tonumber((words:gsub(",", "")))
  if count == nil or count > 13000 then
    error("ned-motion-brief: NECivR 7.1(d)(1)(A) limits a supporting brief to 13,000 words; this one states " .. words)
  end
  local out = certificate_heading("CERTIFICATE OF COMPLIANCE")
  out = out .. certificate_text(run("I hereby certify that this Brief complies with NECivR 7.1(d)(1). It contains ")
    .. runs(inl(m.compliance.word_count))
    .. run(" words, including the caption, headings, footnotes, and quotations, as calculated by the word-count function of ")
    .. runs(inl(m.compliance.software)) .. run("."))
  local sig = m.signature
  local lines = { run("s/ ") .. runs(inl(sig.signer)), runs(inl(sig.signer)) .. run(", #") .. runs(inl(sig.bar_number)) }
  return out .. single_lines(lines, SIG_INDENT, GAP)
end

local function service_certificate(m)
  if m.service == nil then return "" end
  local svc = m.service
  local out = certificate_heading("CERTIFICATE OF SERVICE") .. certificate_text(runs(inl(svc.text)))
  for _, r in ipairs(svc.recipients) do
    local lines = {}
    for _, l in ipairs(r) do lines[#lines + 1] = runs(inl(l)) end
    out = out .. single_lines(lines, RECIPIENT_INDENT, GAP)
  end
  local sig = m.signature
  local lines = { run("s/ ") .. runs(inl(sig.signer)), runs(inl(sig.signer)) .. run(", #") .. runs(inl(sig.bar_number)) }
  return out .. single_lines(lines, SIG_INDENT, GAP)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function styled(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { { "custom-style", style } }))
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end

  -- Page 1: court title and caption, then the lead-in.
  raw(court_title())
  raw(spacer(348))
  raw(caption(m))
  raw(spacer(121))
  if m.lead_in ~= nil then
    out[#out + 1] = pandoc.Para(inl(m.lead_in))
  end

  -- Body. Paragraphs are unnumbered; a list is numbered 1., 2., ...; the block after a heading takes its gap.
  local body = {}
  for i, b in ipairs(doc.blocks) do
    local after_heading = i > 1 and doc.blocks[i - 1].t == "Header"
    local last_block = i == #doc.blocks
    if b.t == "Para" then
      body[#body + 1] = pandoc.Para(b.content)
      if after_heading then
        body[#body] = styled({ body[#body] }, last_block and "Body After Heading Keep Next" or "Body After Heading")
      elseif last_block then
        body[#body] = styled({ body[#body] }, "Body Keep Next")
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and (tostring(k) .. ".") or "\u{2022}"
        local content = { pandoc.Str(label), TAB }
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          for _, x in ipairs(first.content) do content[#content + 1] = x end
        end
        local style = (after_heading and k == 1) and "Enumerated Item After Heading" or "Enumerated Item"
        body[#body + 1] = styled({ pandoc.Para(content) }, style)
      end
    else
      body[#body + 1] = b
    end
  end
  for _, b in ipairs(body) do out[#out + 1] = b end

  -- The signature stays with the last paragraph (a signature never starts a page alone).
  raw(para('<w:keepNext/><w:keepLines/>' .. sp(0, 0, DOUBLE), '') .. signature(m))
  raw(compliance_certificate(m))
  raw(service_certificate(m))

  -- Document properties for the footer (SUBJECT and COMMENTS fields): the title in capitals, the case number.
  doc.meta.date = nil
  doc.meta.title = nil
  doc.meta.subject = pandoc.MetaInlines({ pandoc.Str(text(m.footer_title):upper()) })
  doc.meta.description = pandoc.MetaInlines({ pandoc.Str(text(m.case_number)) })

  doc.blocks = out
  return doc
end
