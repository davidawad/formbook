-- Motion with memorandum of authorities, DOCX engine for the E.D. Wash. bankruptcy court (WAEB): the markdown contract of
-- ../README.md -> a Word document on reference.docx that matches typst/waeb-motion-brief.typ. Same engine as the adversary
-- complaint filter: OpenXML cover and signature, pandoc paragraphs in the Pleading styles, letters and numbers typed here.
-- the body is pandoc paragraphs with the Pleading styles. Paragraph numbers, the (a) list letters and the A. heading
-- letters are typed here, as the typst template generates them. No case-specific text, no forced line breaks.

local BODY_TW = 9360      -- 6.5 in text width
local SINGLE_GAP = 34     -- v(single-leading): 0.12em, 1.7 pt
local BODY_GAP = 263      -- v(body-leading): 0.94em, 13.2 pt

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines -> runs; flags: b (bold), i (italic)
local function runs(inl, flags)
  local out = {}
  local function run(text)
    local rpr = ""
    if flags.b then rpr = rpr .. "<w:b/><w:bCs/>" end
    if flags.i then rpr = rpr .. "<w:i/><w:iCs/>" end
    out[#out + 1] = '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
      '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
  end
  for _, e in ipairs(inl) do
    local t = e.t
    if t == "Str" then run(e.text)
    elseif t == "Space" or t == "SoftBreak" then run(" ")
    elseif t == "LineBreak" then out[#out + 1] = '<w:r><w:br/></w:r>'
    elseif t == "Emph" then out[#out + 1] = runs(e.content, { b = flags.b, i = true })
    elseif t == "Strong" then out[#out + 1] = runs(e.content, { b = true, i = flags.i })
    elseif t == "Quoted" then
      local q = e.quotetype == "SingleQuote" and { "\u{2018}", "\u{2019}" } or { "\u{201C}", "\u{201D}" }
      run(q[1]); out[#out + 1] = runs(e.content, flags); run(q[2])
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(e.content, flags)
    else run(pandoc.utils.stringify(e)) end
  end
  return table.concat(out)
end

-- a metadata value (MetaInlines, MetaString) -> inlines
local function minl(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return (v[1] and v[1].content) or {} end
  if v.t == "MetaString" then return { pandoc.Str(v) } end
  -- a list item that pandoc hands over as a plain list of inlines (no .t): keep its inlines (italics, bold)
  if v.t == nil and type(v) == "table" then return v end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

-- a paragraph: style id, optional extra pPr (in schema order: keep/spacing/ind/jc), runs
local function P(content, style, ppr)
  local p = '<w:pStyle w:val="' .. style .. '"/>' .. (ppr or '')
  return '<w:p><w:pPr>' .. p .. '</w:pPr>' .. content .. '</w:p>'
end

-- an empty paragraph exactly `tw` twips high (a gap: typst v(...))
local function gap(tw, keep)
  return '<w:p><w:pPr>' .. (keep and '<w:keepNext/>' or '') .. '<w:spacing w:before="0" w:after="0" w:line="' .. tw .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function ind(tw) return '<w:ind w:left="' .. tw .. '" w:firstLine="0"/>' end

local function tc(w, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. paras .. '</w:tc>'
end

-- a borderless layout table: widths in twips, cells as xml (one row)
local function layout(widths, cells)
  local total, g = 0, {}
  for _, w in ipairs(widths) do total = total + w; g[#g + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(g) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    table.concat(cells) .. '</w:tr></w:tbl>'
end

-- counsel block: one list of lines, or a list of groups (one group per firm, side by side) (typst counsel-block)
local function counsel_xml(c)
  local groups = {}
  -- a group is a plain list (no .t) of lines; a single list of lines has MetaInlines items
  if #c > 0 and c[1].t == nil then groups = c else groups = { c } end
  local n = #groups
  local gutter = 432
  local colw = math.floor((BODY_TW - (n - 1) * gutter) / n)
  local widths, cells = {}, {}
  for i, g in ipairs(groups) do
    if i > 1 then widths[#widths + 1] = gutter; cells[#cells + 1] = tc(gutter, '<w:p/>') end
    local ps = {}
    for _, line in ipairs(g) do ps[#ps + 1] = P(runs(minl(line), {}), "PleadingSingle") end
    widths[#widths + 1] = colw
    cells[#cells + 1] = tc(colw, table.concat(ps))
  end
  return layout(widths, cells)
end

-- caption: left cell (In re:, debtors, parties, v.) with a right and a bottom rule; right cell (case numbers,
-- title, jury demand) (typst caption)
local function caption_xml(meta)
  local L = {}
  L[#L + 1] = P(runs({ pandoc.Str("In re:") }, {}), "PleadingSingle")
  -- typst: each debtor line is a block followed by a line break, so a blank line follows each one
  for _, n in ipairs(meta.in_re) do
    L[#L + 1] = P(runs(minl(n), {}), "PleadingSingle", ind(720))
    L[#L + 1] = gap(399)
  end
  L[#L + 1] = gap(SINGLE_GAP)
  local parties = meta.parties
  for i, p in ipairs(parties) do
    if i > 1 then
      L[#L + 1] = P(runs(p.joiner and minl(p.joiner) or { pandoc.Str("v.") }, {}), "PleadingSingle", ind(1152))
      L[#L + 1] = gap(SINGLE_GAP)
    end
    for _, n in ipairs(p.names) do L[#L + 1] = P(runs(minl(n), {}), "PleadingSingle") end
    L[#L + 1] = P(runs(minl(p.designation), {}), "PleadingSingle", ind(2160))
    if i < #parties then L[#L + 1] = gap(SINGLE_GAP) end
  end
  local R = {}
  for _, l in ipairs(meta.case_no) do R[#R + 1] = P(runs(minl(l), {}), "PleadingSingle") end
  R[#R + 1] = gap(BODY_GAP)
  R[#R + 1] = P(runs({ pandoc.Strong(minl(meta.title)) }, { b = true }), "PleadingSingle")
  if meta.jury_demand == true then
    R[#R + 1] = gap(BODY_GAP)
    R[#R + 1] = P(runs({ pandoc.Str("DEMAND FOR JURY TRIAL") }, {}), "PleadingSingle")
  end
  local lw, gw = 5357, 432            -- 0.6fr : 0.4fr of 6.2 in, 0.3 in gutter
  local rw = BODY_TW - lw - gw
  local left = tc(lw, table.concat(L),
    '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="216" w:type="dxa"/><w:bottom w:w="173" w:type="dxa"/></w:tcMar>')
  local right = tc(rw, table.concat(R), '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>')
  return layout({ lw, gw, rw }, { left, tc(gw, '<w:p/>'), right })
end

-- the cover: counsel, the judge line (right, body pitch, typst: judge above the court title), the court title (on or
-- below the fifth line), the caption
local function cover(meta)
  local out = { counsel_xml(meta.counsel), gap(SINGLE_GAP) }
  if meta.judge then
    out[#out + 1] = P(runs(minl(meta.judge), {}), "Normal", '<w:jc w:val="right"/>')
  end
  out[#out + 1] = gap(SINGLE_GAP)
  out[#out + 1] = P(runs({ pandoc.Strong({ pandoc.Str("UNITED STATES BANKRUPTCY COURT") }) }, { b = true }), "PleadingSingle", '<w:jc w:val="center"/>')
  out[#out + 1] = gap(399)   -- typst court-heading: the two lines are separated by a blank line
  out[#out + 1] = P(runs({ pandoc.Strong({ pandoc.Str("EASTERN DISTRICT OF WASHINGTON") }) }, { b = true }), "PleadingSingle", '<w:jc w:val="center"/>')
  out[#out + 1] = gap(399)   -- typst court-heading: a blank line after each line
  out[#out + 1] = gap(SINGLE_GAP)
  out[#out + 1] = caption_xml(meta)
  out[#out + 1] = gap(BODY_GAP)
  return table.concat(out)
end

-- the signature block after the conclusion: the date (body pitch), then one block per firm at 3.0 in: the firm, a gap,
-- "By /s/" and the signer's lines. A block follows the one before it after a single-to-single gap (typst: block spacing).
-- The date and all blocks stay on one page.
local function signature(sig)
  local out = { P(runs(minl(sig.date), {}), "Normal", '<w:keepNext/>') }
  for k, b in ipairs(sig.blocks) do
    if k > 1 then out[#out + 1] = gap(230, true) end
    out[#out + 1] = P(runs(minl(b.firm), {}), "PleadingSingle", '<w:keepNext/>' .. ind(4320))
    out[#out + 1] = gap(BODY_GAP, true)
    if b.signer then
      out[#out + 1] = P(runs({ pandoc.Str("By /s/ ") }, {}) .. runs(minl(b.signer), {}), "PleadingSingle", '<w:keepNext/>' .. ind(4320))
    end
    local lines = b.lines or {}
    for j, l in ipairs(lines) do
      out[#out + 1] = P(runs(minl(l), {}), "PleadingSingle", (j < #lines and '<w:keepNext/>' or '') .. ind(4320))
    end
  end
  return table.concat(out)
end

local function is_exhibit(b)
  return b.t == "Header" and b.level == 1 and pandoc.utils.stringify(b.content):match("^EXHIBIT") ~= nil
end

local function div(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- column widths follow the content (typst sizes table columns to their text): the share of each column is its longest cell
local function fit_widths(b)
  local n = #b.colspecs
  local longest = {}
  for i = 1, n do longest[i] = 6 end
  local function scan(rows)
    for _, row in ipairs(rows) do
      for i, cell in ipairs(row.cells) do
        if i <= n then longest[i] = math.max(longest[i], #pandoc.utils.stringify(cell.contents)) end
      end
    end
  end
  scan(b.head.rows)
  for _, body in ipairs(b.bodies) do scan(body.head); scan(body.body) end
  local total = 0
  for i = 1, n do total = total + longest[i] end
  for i = 1, n do b.colspecs[i][2] = longest[i] / total end
end

local function letter(n) return "(" .. string.char(96 + n) .. ")" end

function Pandoc(doc)
  local meta = doc.meta
  local cover_xml = cover(meta)
  local sig_xml = signature(meta.signature)
  doc.meta.title = nil
  doc.meta.date = nil
  doc.meta.author = nil

  local body, exhibits = {}, {}
  local target = body
  local para_n, sub_n = 0, 0
  for _, b in ipairs(doc.blocks) do
    if is_exhibit(b) then
      target = exhibits
      target[#target + 1] = div({ pandoc.Para(b.content) }, "Pleading Exhibit")
    elseif b.t == "Header" and b.level == 1 then
      sub_n = 0
      target[#target + 1] = b
    elseif b.t == "Header" and b.level == 2 then
      sub_n = sub_n + 1
      local inl = { pandoc.Str(string.char(64 + sub_n) .. "."), pandoc.Str("\u{2002}") }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      target[#target + 1] = pandoc.Header(2, inl)
    elseif b.t == "Para" then
      local c = b.content
      if c[1] and c[1].t == "Str" and c[1].text == "~" and c[2] and c[2].t == "Space" then
        local rest = {}
        for k = 3, #c do rest[#rest + 1] = c[k] end
        target[#target + 1] = div({ pandoc.Para(rest) }, "Pleading Body Sticky")
      elseif #c == 1 and c[1].t == "Strong" then
        target[#target + 1] = div({ pandoc.Para(c) }, "Pleading Subtitle")
      else
        para_n = para_n + 1
        local inl = { pandoc.Str(para_n .. "."), pandoc.Str("\u{2002}") }
        for _, x in ipairs(c) do inl[#inl + 1] = x end
        target[#target + 1] = div({ pandoc.Para(inl) }, "Pleading Body")
      end
    elseif b.t == "Table" then
      fit_widths(b)
      target[#target + 1] = b
    elseif b.t == "BulletList" then
      for li, item in ipairs(b.content) do
        local first = item[1]
        local inl = { pandoc.Str(letter(li)), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
        if first and (first.t == "Para" or first.t == "Plain") then
          for _, x in ipairs(first.content) do inl[#inl + 1] = x end
        end
        target[#target + 1] = div({ pandoc.Para(inl) }, "Pleading List")
      end
    else
      target[#target + 1] = b
    end
  end

  local out = { pandoc.RawBlock("openxml", cover_xml) }
  for _, b in ipairs(body) do out[#out + 1] = b end
  out[#out + 1] = pandoc.RawBlock("openxml", sig_xml)
  for _, b in ipairs(exhibits) do out[#out + 1] = b end
  doc.blocks = out
  return doc
end
