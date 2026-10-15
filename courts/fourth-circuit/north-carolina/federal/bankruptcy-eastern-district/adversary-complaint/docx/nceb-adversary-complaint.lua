-- nceb-adversary-complaint.lua (docx engine). Builds what pandoc does not build from the sample's frontmatter and body,
-- in the form of typst/nceb-adversary-complaint.typ: the caption (court lines, division, caption table with the rule
-- at its right and bottom edges, title), the numbered allegations, and the signature block. No case text is written here;
-- every word comes from the sample. See ../README.md "Engines".

local function txt(x) return pandoc.utils.stringify(x) end

local function xesc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function xpara(style, text)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' ..
    (text ~= "" and ('<w:r><w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>') or "") .. '</w:p>'
end

-- Caption table: two columns, 3.2 in (left, ruled on its right and bottom) and 6.3 in (case numbers).
-- Widths in twips: 4608 + 4752 = 9360 (6.5 in text width). The right cell is indented 0.3 in.
local function caption_table(meta)
  local left = {}
  local function party(p)
    for _, n in ipairs(p.names) do table.insert(left, xpara("NCEBCaptionCell", txt(n))) end
    table.insert(left, xpara("NCEBDesignation", txt(p.designation)))
  end
  for _, p in ipairs(meta.caption.in_re) do party(p) end
  for _, p in ipairs(meta.caption.parties) do party(p) end
  local right = {}
  table.insert(right, xpara("NCEBCaseNumbers", "Case No. " .. txt(meta.case_number)))
  table.insert(right, xpara("NCEBCaptionCell", "Chapter " .. txt(meta.chapter)))
  if meta.adversary_number then
    table.insert(right, xpara("NCEBCaptionCell", ""))
    table.insert(right, xpara("NCEBCaptionCell", "Adversary Proceeding No. " .. txt(meta.adversary_number)))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="4752"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/><w:tcBorders>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/><w:tcMar><w:left w:w="432" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- Allegations: numbered 1, 2, ... by the template (FRCP 10(b)). Unnumbered: the lead-in before the first heading,
-- headings, lettered items (indented), a "~" paragraph (the author's mark, removed), a "(" continuation, a "[" note
-- (italic), lists, tables and quotations.
local function number_body(blocks)
  local first_h
  for i, b in ipairs(blocks) do
    if b.t == "Header" then first_h = i break end
  end
  local out, n = {}, 0
  for i, b in ipairs(blocks) do
    if b.t ~= "Para" then
      table.insert(out, b)
    else
      local s = txt(b)
      local c1 = s:sub(1, 1)
      if first_h == nil or i < first_h then
        table.insert(out, b)
      elseif c1 == "~" then
        local first = b.content[1]
        if first and first.t == "Str" then first.text = first.text:sub(2) end
        table.insert(out, b)
      elseif s:match("^[A-Z]%. ") then
        table.insert(out, pandoc.Div({ b }, { ["custom-style"] = "NCEB Indent Item" }))
      elseif c1 == "[" then
        table.insert(out, pandoc.Para({ pandoc.Emph(b.content) }))
      elseif c1 == "(" then
        table.insert(out, b)
      else
        n = n + 1
        table.insert(b.content, 1, pandoc.Str(n .. ".\u{2003}"))
        table.insert(out, b)
      end
    end
  end
  return out
end

-- Tables: column widths weighted by the longest word of each column (x3, so no word breaks) plus the longest cell
-- text (capped at 60 characters). Pandoc would otherwise give every column the same width.
local function table_widths(t)
  local n = #t.colspecs
  local word, text = {}, {}
  for i = 1, n do word[i] = 1; text[i] = 1 end
  local function scan(rows)
    for _, row in ipairs(rows) do
      for ci, cell in ipairs(row.cells) do
        local s = txt(cell.contents)
        for w in s:gmatch("%S+") do
          if #w > word[ci] then word[ci] = #w end
        end
        if #s > text[ci] then text[ci] = math.min(#s, 60) end
      end
    end
  end
  scan(t.head.rows)
  for _, body in ipairs(t.bodies) do scan(body.head); scan(body.body) end
  local weight, total = {}, 0
  for i = 1, n do
    weight[i] = 3 * word[i] + text[i]
    total = total + weight[i]
  end
  for i = 1, n do t.colspecs[i][2] = weight[i] / total end
  return t
end

-- A list inside a block quotation (the Section 9 terms, lettered a), b), c)): each item becomes a labelled paragraph
-- inside the quotation's indent, since pandoc's list numbering would start at the margin.
local function list_label(l, n)
  local style = tostring(l.listAttributes.style)
  local delim = tostring(l.listAttributes.delimiter)
  local v = tostring(n)
  if style == "LowerAlpha" then v = string.char(96 + n) elseif style == "UpperAlpha" then v = string.char(64 + n) end
  if delim == "OneParen" then return v .. ")" end
  if delim == "TwoParens" then return "(" .. v .. ")" end
  return v .. "."
end

-- Each list item becomes a paragraph in the given style, its label a text run and the label's end a Word tab. The
-- last item takes last_style (keep-with-next, so the prayer's last item stays with the signature block).
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function list_paragraphs(l, style, last_style)
  local out = {}
  local start = l.listAttributes.start
  for i, item in ipairs(l.content) do
    local inl = pandoc.List({ pandoc.Str(list_label(l, start + i - 1)), TAB })
    local first = item[1]
    local from = 1
    if first and (first.t == "Plain" or first.t == "Para") then
      for _, x in ipairs(first.content) do inl:insert(x) end
      from = 2
    end
    local st = (i == #l.content) and last_style or style
    table.insert(out, pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = st }))
    for k = from, #item do table.insert(out, item[k]) end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  -- pass 1: lists inside block quotations (quotation indent)
  local d1 = doc:walk({
    BlockQuote = function(bq)
      local content = {}
      for _, b in ipairs(bq.content) do
        if b.t == "OrderedList" then
          for _, x in ipairs(list_paragraphs(b, "NCEB Quote Item", "NCEB Quote Item")) do table.insert(content, x) end
        else
          table.insert(content, b)
        end
      end
      bq.content = content
      return bq
    end,
  })
  -- pass 2: tables, and the other lists (at the margin, with a hanging indent)
  local d = d1:walk({
    Table = table_widths,
    OrderedList = function(l) return list_paragraphs(l, "NCEB List Item", "NCEB List Item Last") end,
  })
  local blocks = {}
  for _, line in ipairs(meta.court) do
    table.insert(blocks, styled("NCEB Court", { pandoc.Str(txt(line):upper()) }))
  end
  table.insert(blocks, styled("NCEB Division", { pandoc.Str(txt(meta.division):upper()) }))
  table.insert(blocks, pandoc.RawBlock("openxml", caption_table(meta)))
  table.insert(blocks, styled("NCEB Title", { pandoc.Str(txt(meta.title):upper()) }))
  for _, b in ipairs(number_body(d.blocks)) do table.insert(blocks, b) end
  -- signature block (LBR 9011-4; Admin Guide 5005-4(8))
  local sig = meta.signature
  if sig then
    if sig.lead then table.insert(blocks, styled("NCEB Lead In", { pandoc.Str(txt(sig.lead)) })) end
    if sig.firm then table.insert(blocks, styled("NCEB Signature Last", { pandoc.Str(txt(sig.firm):upper()) })) end
    for _, s in ipairs(sig.signers) do
      table.insert(blocks, styled("NCEB Signature", { pandoc.Str(txt(s.sign)) }))
      local lines = s.lines
      for i, l in ipairs(lines) do
        local style = (i == #lines) and "NCEB Signature Last" or "NCEB Signature"
        table.insert(blocks, styled(style, { pandoc.Str(txt(l)) }))
      end
    end
    if sig.role then table.insert(blocks, styled("NCEB Signature", { pandoc.Emph({ pandoc.Str(txt(sig.role)) }) })) end
  end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
