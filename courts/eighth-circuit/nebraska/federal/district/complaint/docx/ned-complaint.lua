-- ned-complaint.lua (docx engine, complaint): what the Word output adds to pandoc's default conversion, to match
-- complaint/typst/ned-complaint.typ (see ../README.md, "Engines"):
--   * page 1: counsel block (single-spaced, top left), the two court-title lines, the caption as a table with a
--     right and a bottom rule on the party column, the case number, the bold title and the trial notes;
--   * numbered allegations (1., 2., ...), a tab after the number; a paragraph starting with "^" is unnumbered;
--   * markdown lists become lettered items (A., B., ...) with a hanging indent (the prayer);
--   * the signature block as a borderless table ("Dated" at left, then the NECivR 11.1 lines);
--   * the title and the case number go to the document properties (subject, description), which the footer's
--     SUBJECT and COMMENTS fields show from page 2 on (the footers are in reference.docx).
-- Everything case-specific comes from the sample's frontmatter; nothing in this file is about one case.

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
local BODY_GAP = 324 -- space after a double-spaced paragraph, 16.2 pt (body-leading)

local function para(ppr, body)
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. body .. '</w:p>'
end

-- A blank line of a given height (the typst v(...) spaces): an empty exact-height paragraph.
local function spacer(line)
  return para(sp(0, 0, line), '')
end

-- Single-spaced lines, one paragraph per item (14.4 pt pitch, no extra space between them, as measured in typst). `indent` in twips (or nil).
-- Every line but the last is kept with the next one (the block must not split); the last one ends the chain.
local function single_lines(items, indent)
  local out = {}
  for k, body in ipairs(items) do
    local last = k == #items
    local kn = (not last) and '<w:keepNext/>' or ''
    local ind = indent and string.format('<w:ind w:left="%d"/>', indent) or ''
    out[#out + 1] = para(kn .. '<w:keepLines/>' .. sp(0, 0, SINGLE) .. ind, body)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Tables (the caption and the signature block are borderless or ruled tables)
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
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function counsel(m)
  local items = {}
  for _, line in ipairs(m.counsel) do items[#items + 1] = runs(inl(line)) end
  return single_lines(items)
end

local function court_title(m)
  local lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF NEBRASKA" }
  if text(m.division) ~= "" then lines[#lines + 1] = text(m.division):upper() end
  local out = {}
  for k, t in ipairs(lines) do
    out[#out + 1] = para('<w:keepNext/><w:keepLines/>' .. sp(0, 0, SINGLE)
      .. '<w:jc w:val="center"/>', run(t, { b = true }))
  end
  return table.concat(out)
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
    local before = j == 1 and 80 or 0 -- 4 pt inset from the top rule of the box
    lines[#lines + 1] = para(sp(before, 0, SINGLE) .. ind, c.body)
  end
  local left_cell = cell(4680, table.concat(lines),
    '<w:tcBorders><w:right ' .. RULE .. '/><w:bottom ' .. RULE .. '/></w:tcBorders>'
    .. '<w:tcMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>')

  -- Right column: case number, the bold title, the jury demand (when set), the trial location (when set).
  local right = {}
  right[#right + 1] = para(sp(0, 0, SINGLE), run("Case No. ") .. runs(inl(m.case_number)))
  right[#right + 1] = para(sp(108, 0, SINGLE), runs(inl(m.brief_title), { b = true }))
  if m.jury_demand then
    right[#right + 1] = para(sp(108, 0, SINGLE), run("Jury Trial Demanded", { b = true }))
  end
  if text(m.trial_location) ~= "" then
    right[#right + 1] = para(sp(0, 0, SINGLE), run("Trial Location: ") .. runs(inl(m.trial_location)))
  end
  local right_cell = cell(4320, table.concat(right), '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>')
  local gutter = cell(360, para(sp(0, 0, SINGLE), ''))
  return table_xml({ 4680, 360, 4320 }, { left_cell, gutter, right_cell })
end

-- ---------------------------------------------------------------------------
-- Signature block (NECivR 11.1(a)(1)(A)): "Dated" at left; "Respectfully submitted," then the signature lines.
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local lines = {}
  lines[#lines + 1] = run("s/ ") .. runs(inl(sig.signer))
  lines[#lines + 1] = run("Bar Number: ") .. runs(inl(sig.bar_number))
  lines[#lines + 1] = run("Attorney for ") .. runs(inl(sig.attorney_for))
  for _, l in ipairs(sig.firm) do lines[#lines + 1] = runs(inl(l)) end
  local right = para('<w:keepNext/><w:keepLines/>' .. sp(0, 0, SINGLE), run("Respectfully submitted,"))
    .. spacer(DOUBLE)
    .. single_lines(lines, nil)
  local left = para('<w:keepNext/><w:keepLines/>' .. sp(0, 0, SINGLE), run("Dated: ") .. runs(inl(m.date)))
  return para('<w:keepNext/><w:keepLines/>' .. sp(0, 0, DOUBLE), '') .. table_xml({ 3888, 288, 5184 }, {
    cell(3888, left), cell(288, para(sp(0, 0, SINGLE), '')), cell(5184, right) })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function lettered(i) return string.char(64 + i) .. "." end

-- A paragraph that starts with "^" is unnumbered; the marker (and the space after it) is removed.
local function unnumbered(inlines)
  local first = inlines[1]
  if not (first and first.t == "Str" and first.text:sub(1, 1) == "^") then return false end
  local rest = first.text:sub(2)
  if rest == "" then
    table.remove(inlines, 1)
    if inlines[1] and inlines[1].t == "Space" then table.remove(inlines, 1) end
  else
    inlines[1] = pandoc.Str(rest)
  end
  return true
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function styled(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { { "custom-style", style } }))
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end

  -- Page 1: counsel, court title and caption, with the spacing of the typst cover.
  raw(counsel(m))
  raw(spacer(588))
  raw(court_title(m))
  raw(spacer(348))
  raw(caption(m))
  raw(spacer(368))

  -- Body. Numbered paragraphs count from 1; a list is lettered; the block after a heading takes the heading's gap.
  local n = 0
  local body = {}
  for i, b in ipairs(doc.blocks) do
    local after_heading = i > 1 and doc.blocks[i - 1].t == "Header"
    if b.t == "Para" then
      local content = b.content
      if unnumbered(content) then
        body[#body + 1] = pandoc.Para(content)
      else
        n = n + 1
        local numbered = { pandoc.Str(tostring(n) .. "."), TAB }
        for _, x in ipairs(content) do numbered[#numbered + 1] = x end
        body[#body + 1] = pandoc.Para(numbered)
      end
      -- The last paragraph stays on the page with the signature (a signature never starts a page alone).
      local last_block = i == #doc.blocks
      if after_heading then
        body[#body] = styled({ body[#body] }, last_block and "Body After Heading Keep Next" or "Body After Heading")
      elseif last_block then
        body[#body] = styled({ body[#body] }, "Body Keep Next")
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and lettered(k) or "\u{2022}"
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

  raw(signature(m))

  -- Document properties for the footer (SUBJECT and COMMENTS fields): the title in capitals, the case number.
  doc.meta.date = nil
  doc.meta.title = nil
  doc.meta.subject = pandoc.MetaInlines({ pandoc.Str(text(m.footer_title):upper()) })
  doc.meta.description = pandoc.MetaInlines({ pandoc.Str(text(m.case_number)) })

  doc.blocks = out
  return doc
end
