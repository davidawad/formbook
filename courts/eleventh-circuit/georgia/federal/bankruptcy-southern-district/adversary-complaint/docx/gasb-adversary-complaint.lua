-- gasb-adversary-complaint.lua (docx engine): the S.D. Ga. adversary complaint as Word paragraphs and tables
-- (typst: ../typst/gasb-adversary-complaint.typ). pandoc writes the markdown body with reference.docx (make-reference.sh);
-- this filter writes what Word needs formatting for:
--   * the court title, the caption table (debtor and parties on the left, case numbers on the right, a rule under and
--     beside the left cell), the title of the complaint, the signature block, as paragraphs and tables with explicit
--     spacing, indents and tabs (the same numbers as the typst template: 24 pt line pitch, 12 pt half-gaps);
--   * the numbered paragraphs: the author types "1.", "2.", ... in the markdown; each ordered-list item becomes a
--     paragraph of the "Numbered Paragraph" style with its number and a tab (the number at half an inch, the text
--     hanging), and the numbers keep the start the author typed (paragraph 30 starts at 30).
-- No case text is in this file: every string comes from the frontmatter of the sample (schema: ../README.md).
-- Word may paginate slightly differently from the LibreOffice PDF (docs/DOCX.md).

local LINE = 480          -- line-pitch, 24 pt, in twips (GASB-FORM-002)
local HALF = 240          -- line-pitch * 0.5
local SINGLE = 240        -- single spacing ("auto" 240)
local TEXT_W = 9360       -- the text width, 6.5 in
local CAP_L = 5897        -- caption left cell: 3.4 / 5.4 of the text width (typst columns (3.4fr, 2fr))
local CAP_R = 3463        -- caption right cell
local EM_PAD = 312        -- 1.2 em at 13 pt (typst pad right 1.2em on the left cell, left 1.2em on the right cell)
local BOTTOM_PAD = 260    -- 1 em at 13 pt (typst pad bottom 1em)
local TOP_PAD = 78        -- 0.3 em at 13 pt (typst pad top 0.3em on the right cell)
local SIG_L = 4752        -- signature grid (1fr, 3.2in): the left column takes the rest
local SIG_R = 4608        -- 3.2 in
local INDENT_DEBTOR = 1728  -- 1.2 in (typst pad left 1.2in under "In re")
local INDENT_DESIG = 2592   -- 1.8 in (typst pad left 1.8in under the party names)

-- ---------------------------------------------------------------------------
-- XML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function rpr(o)
  local x = ""
  if o.b then x = x .. "<w:b/><w:bCs/>" end
  if o.i then x = x .. "<w:i/><w:iCs/>" end
  if o.caps then x = x .. "<w:caps/>" end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

-- Text with tabs (\t) and line breaks (\n) as Word runs.
local function run(text, o)
  local x = rpr(o or {})
  local out = {}
  local pos = 1
  while pos <= #text do
    local c = text:sub(pos, pos)
    if c == "\t" then
      out[#out + 1] = "<w:r>" .. x .. "<w:tab/></w:r>"
      pos = pos + 1
    elseif c == "\n" then
      out[#out + 1] = "<w:r>" .. x .. "<w:br/></w:r>"
      pos = pos + 1
    else
      local e = text:find("[\t\n]", pos) or (#text + 1)
      out[#out + 1] = "<w:r>" .. x .. '<w:t xml:space="preserve">' .. esc(text:sub(pos, e - 1)) .. "</w:t></w:r>"
      pos = e
    end
  end
  return table.concat(out)
end

local BR = "<w:r><w:br/></w:r>"
local TAB = "<w:r><w:tab/></w:r>"

local function merge_opts(a, b)
  local out = {}
  for k, v in pairs(a) do out[k] = v end
  for k, v in pairs(b) do out[k] = v end
  return out
end

-- A list of pandoc inlines (a metadata value, or a markdown paragraph's content) as Word runs.
local function inl(x, o)
  o = o or {}
  if x == nil then return "" end
  if type(x) == "string" then return run(x, o) end
  local out = {}
  for _, el in ipairs(x) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, o)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", o)
    elseif t == "LineBreak" then
      out[#out + 1] = BR
    elseif t == "Emph" then
      out[#out + 1] = inl(el.content, merge_opts(o, { i = true }))
    elseif t == "Strong" then
      out[#out + 1] = inl(el.content, merge_opts(o, { b = true }))
    elseif t == "Span" or t == "Link" then
      out[#out + 1] = inl(el.content, o)
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], o) .. inl(el.content, o) .. run(q[2], o)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), o)
    end
  end
  return table.concat(out)
end

-- Lines (a list of inline lists) joined by line breaks, in one paragraph's runs.
local function lines(list, o)
  local out = {}
  for i, l in ipairs(list or {}) do
    out[#out + 1] = inl(l, o)
    if i < #list then out[#out + 1] = BR end
  end
  return table.concat(out)
end

-- A paragraph: spacing in twips (before, after, line, rule), optional left indent, alignment, keep with next.
local function p(content, o)
  o = o or {}
  local pp = ""
  if o.keep then pp = pp .. "<w:keepNext/>" end
  pp = pp .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>',
    o.before or 0, o.after or 0, o.line or SINGLE, o.rule or "auto")
  if o.left or o.first then
    pp = pp .. string.format('<w:ind w:left="%d" w:firstLine="%d"/>', o.left or 0, o.first or 0)
  end
  if o.jc then pp = pp .. string.format('<w:jc w:val="%s"/>', o.jc) end
  return "<w:p><w:pPr>" .. pp .. "</w:pPr>" .. (content or "") .. "</w:p>"
end

-- A table without borders, two cells: each cell is { w = width, xml = paragraphs, borders = xml, mar = xml }.
local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(cells, cell_mar)
  local grid, row = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = string.format('<w:gridCol w:w="%d"/>', c.w)
    local pr = string.format('<w:tcW w:w="%d" w:type="dxa"/>', c.w)
    if c.borders then pr = pr .. c.borders end
    if c.mar then pr = pr .. "<w:tcMar>" .. c.mar .. "</w:tcMar>" end
    row[#row + 1] = "<w:tc><w:tcPr>" .. pr .. "</w:tcPr>" .. c.xml .. "</w:tc>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar>' .. (cell_mar or "")
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid) .. "</w:tblGrid><w:tr>"
    .. table.concat(row) .. "</w:tr></w:tbl>"
end

local function cell_margins(left, right, top, bottom)
  return string.format('<w:top w:w="%d" w:type="dxa"/><w:left w:w="%d" w:type="dxa"/>'
    .. '<w:bottom w:w="%d" w:type="dxa"/><w:right w:w="%d" w:type="dxa"/>', top, left, bottom, right)
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title (typst: court-title, caption-left, caption-right, caption-table)
-- ---------------------------------------------------------------------------

local function court_title(meta)
  local parts = {}
  for i, l in ipairs(meta.court) do parts[i] = inl(l, { b = true, caps = true }) end
  return p(table.concat(parts, BR), { jc = "center", after = LINE })
end

local function caption_left(meta)
  local x = {}
  x[#x + 1] = p(lines(meta.in_re), { after = 0 })
  x[#x + 1] = p(inl(meta.debtor_role or { pandoc.Str("Debtor.") }), { left = INDENT_DEBTOR, after = HALF })
  if meta.trustee then
    x[#x + 1] = p(lines(meta.trustee), { after = HALF })
  end
  for i, side in ipairs(meta.caption) do
    x[#x + 1] = p(lines(side.names), { after = 0 })
    local last = i == #meta.caption
    x[#x + 1] = p(inl(side.designation), { left = INDENT_DESIG, after = last and 0 or HALF })
    if not last then x[#x + 1] = p(run("v."), { jc = "center", after = HALF }) end
  end
  return table.concat(x)
end

local function caption_right(meta, motion_order)
  local x = {}
  local function add(xml, after)
    x[#x + 1] = p(xml, { after = after })
  end
  local case = run("CASE NO. ") .. inl(meta.case_number)
  local chapter = run("CHAPTER ") .. inl(meta.chapter)
  if motion_order then
    add(chapter, HALF)
    add(case, HALF)
  else
    add(case, HALF)
    add(chapter, HALF)
  end
  if meta.judge then add(inl(meta.judge), HALF) end
  local adv = meta.adversary_number and #meta.adversary_number > 0 and inl(meta.adversary_number)
  add(run("ADV. PRO. NO. ") .. (adv or run(string.rep("_", 11))), 0)
  return table.concat(x)
end

local function caption_table(meta, motion_order)
  return table_xml({
    {
      w = CAP_L,
      xml = caption_left(meta),
      borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
      mar = cell_margins(0, EM_PAD, 0, BOTTOM_PAD),
    },
    {
      w = CAP_R,
      xml = caption_right(meta, motion_order),
      mar = cell_margins(EM_PAD, 0, TOP_PAD, 0),
    },
  }, cell_margins(0, 0, 0, 0))
end

-- ---------------------------------------------------------------------------
-- Signature block (typst: signature-block): "Respectfully submitted" at left, the firm at right
-- ---------------------------------------------------------------------------

local function signature_table(meta)
  local sig = meta.signature
  local left = p(run("Respectfully submitted this ") .. inl(meta.submitted_on) .. run("."), { after = 0 })
  local right = {}
  right[#right + 1] = p(inl(sig.firm, { b = true }), { after = HALF })
  local signer = { run("/s/ ") .. inl(sig.signer), inl(sig.signer) }
  for _, l in ipairs(sig.signer_lines or {}) do signer[#signer + 1] = inl(l) end
  right[#right + 1] = p(table.concat(signer, BR), { after = HALF })
  if sig.other_counsel_lines and #sig.other_counsel_lines > 0 then
    right[#right + 1] = p(lines(sig.other_counsel_lines), { after = HALF })
  end
  local role = { inl(sig.role, { i = true }) }
  for _, l in ipairs(sig.address) do role[#role + 1] = inl(l) end
  right[#right + 1] = p(table.concat(role, BR), { after = 0 })
  return table_xml({
    { w = SIG_L, xml = left },
    { w = SIG_R, xml = table.concat(right) },
  }, cell_margins(0, 0, 0, 0))
end

-- ---------------------------------------------------------------------------
-- Numbered paragraphs (the author's "1.", "2.", ... in the markdown)
-- ---------------------------------------------------------------------------

local function numbered_list(el)
  local start = el.listAttributes.start
  local out = pandoc.List({})
  for i, item in ipairs(el.content) do
    local blocks = pandoc.List(item)
    local label = pandoc.Str(tostring(start + i - 1) .. ".")
    local tab = pandoc.RawInline("openxml", TAB)
    local first = blocks[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inls = pandoc.List({ label, tab })
      inls:extend(first.content)
      blocks[1] = pandoc.Para(inls)
    else
      blocks:insert(1, pandoc.Para({ label, tab }))
    end
    out:extend(blocks)
  end
  return pandoc.Div(out, { ["custom-style"] = "Numbered Paragraph" })
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ OrderedList = numbered_list })
  local head = {
    pandoc.RawBlock("openxml", court_title(meta)),
    pandoc.RawBlock("openxml", caption_table(meta, false)),
    pandoc.RawBlock("openxml", p(inl(meta.title, { b = true, caps = true }), { jc = "center", before = LINE, after = HALF, keep = true })),
  }
  local tail = {
    pandoc.RawBlock("openxml", p("", { line = LINE, rule = "exact" })),
    pandoc.RawBlock("openxml", signature_table(meta)),
  }
  local body = pandoc.List(head)
  body:extend(doc.blocks)
  body:extend(tail)
  doc.blocks = body
  -- pandoc would print the YAML title as a block at the top; the caption carries the title instead.
  doc.meta.title = nil
  return doc
end
