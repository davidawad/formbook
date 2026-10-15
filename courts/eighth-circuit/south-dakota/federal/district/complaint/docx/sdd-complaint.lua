-- Complaint, D.S.D. (sdd), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx, in the
-- form of typst/sdd-complaint.typ. The cover (court title and caption), the signature block are raw OpenXML:
-- a caption with a rule on two sides and a borderless signature grid are not pandoc tables. The body keeps its
-- markdown structure; the numbered paragraphs are numbered here, as the typst template numbers them (Fed. R.
-- Civ. P. 10(b)). The footnote and table syntax is pandoc's.

local CFG = {
  numbered = true,
  court_lines = { "UNITED STATES DISTRICT COURT", "DISTRICT OF SOUTH DAKOTA" },
}

-- a metadata value as a list of inlines
local function inlist(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return v
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- one run of text; the direct formatting is bold (b) and italic (i), in schema order
local function run(text, fmt)
  local rpr = (fmt.b and "<w:b/>" or "") .. (fmt.i and "<w:i/>" or "")
  return "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
    .. '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

-- inlines as runs; markdown emphasis becomes direct italic or bold
local function runs(inls, fmt)
  fmt = fmt or {}
  local out = {}
  for _, el in ipairs(inls) do
    if el.t == "Str" then
      out[#out + 1] = run(el.text, fmt)
    elseif el.t == "Space" or el.t == "SoftBreak" then
      out[#out + 1] = run(" ", fmt)
    elseif el.t == "Emph" then
      out[#out + 1] = runs(el.content, { b = fmt.b, i = true })
    elseif el.t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = fmt.i })
    elseif el.t == "Quoted" then
      local q = tostring(el.quotetype) == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], fmt) .. runs(el.content, fmt) .. run(q[2], fmt)
    else
      out[#out + 1] = run(plain(el), fmt)
    end
  end
  return table.concat(out)
end

-- a paragraph: style, runs, and pPr children (already in schema order, after pStyle)
local function para_xml(style, inls, fmt, ppr)
  return "<w:p><w:pPr>" .. (style and ('<w:pStyle w:val="' .. style .. '"/>') or "") .. (ppr or "")
    .. "</w:pPr>" .. runs(inls, fmt) .. "</w:p>"
end

local function concat_inlines(a, b)
  local out = pandoc.List({})
  for _, x in ipairs(a) do out:insert(x) end
  for _, x in ipairs(b) do out:insert(x) end
  return out
end

-- an empty paragraph of an exact height (twips): the vertical gaps of the typst template (v(pitch) and so on)
local function spacer(twips, keep)
  return '<w:p><w:pPr>' .. (keep and "<w:keepNext/>" or "")
    .. '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- a table with no borders (set per cell where a rule is wanted); widths in twips
local function table_xml(widths, rows)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

local function cell(width, content, tcpr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (tcpr or "") .. "</w:tcPr>"
    .. content .. "</w:tc>"
end

local function row(cells)
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
end

-- Cover (LR 10.1(A)): the court title, then the caption. Parties on the left, closed by a right and a bottom
-- rule; the case number, the title and the jury demand on the right.
local function court_title(meta)
  local out = {}
  for _, l in ipairs(CFG.court_lines) do
    out[#out + 1] = para_xml("Single", { pandoc.Str(l) }, { b = true }, '<w:jc w:val="center"/>')
  end
  if meta.division then
    out[#out + 1] = para_xml("Single", { pandoc.Str(plain(meta.division):upper()) }, { b = true }, '<w:jc w:val="center"/>')
  end
  out[#out + 1] = spacer(360)
  return table.concat(out)
end

local function caption(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = para_xml("Single", { pandoc.Str("v.") }) end
    for _, n in ipairs(p.names) do left[#left + 1] = para_xml("Single", inlist(n)) end
    left[#left + 1] = para_xml("Single", inlist(p.designation))
  end
  local right = {
    para_xml("Single", { pandoc.Str("Case No. " .. plain(meta.case_number)) }),
    spacer(240),
    para_xml("Single", inlist(meta.brief_title), { b = true }),
  }
  if meta.jury_demand then
    right[#right + 1] = spacer(240)
    right[#right + 1] = para_xml("Single", { pandoc.Str("JURY TRIAL DEMANDED") }, { b = true })
  end
  return table_xml({ 4680, 360, 4320 }, {
    row({
      cell(4680, table.concat(left),
        '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
        .. '<w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="240" w:type="dxa"/></w:tcMar>'),
      cell(360, para_xml("Single", {})),
      cell(4320, table.concat(right), '<w:tcMar><w:left w:w="216" w:type="dxa"/></w:tcMar>'),
    }),
  })
end

-- Signature block (LR 10.1(B), LR 5.1(A)(4)): "Dated" on the left; on the right the signature line and the
-- typed name, address, telephone and e-mail beneath it. A party without an attorney signs personally.
local function signature(meta)
  local sig = meta.signature
  local right = {}
  if sig.pro_se then
    right[#right + 1] = spacer(480)
    right[#right + 1] = '<w:p><w:pPr><w:keepNext/><w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>'
      .. '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:right="720"/></w:pPr></w:p>'
    right[#right + 1] = spacer(80, true)
    right[#right + 1] = para_xml("Single", inlist(sig.signer), nil, "<w:keepNext/>")
    right[#right + 1] = para_xml("Single", { pandoc.Str("Plaintiff, without counsel") }, nil, "<w:keepNext/>")
  else
    if sig.firm then
      for _, l in ipairs(sig.firm) do right[#right + 1] = para_xml("Single", inlist(l), nil, "<w:keepNext/>") end
      right[#right + 1] = spacer(120, true)
    end
    right[#right + 1] = para_xml("Single", concat_inlines({ pandoc.Str("By: /s/ ") }, inlist(sig.signer)), nil, "<w:keepNext/>")
    right[#right + 1] = para_xml("Single", inlist(sig.signer), nil, "<w:keepNext/>")
  end
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = para_xml("Single", inlist(l), nil, "<w:keepNext/>") end
  return spacer(480, true) .. table_xml({ 3744, 288, 5328 }, {
    row({
      cell(3744, para_xml("Single", { pandoc.Str("Dated: " .. plain(meta.date)) }, nil, "<w:keepNext/>")),
      cell(288, para_xml("Single", {}, nil, "<w:keepNext/>")),
      cell(5328, table.concat(right)),
    }),
  })
end

-- "~" marks an unnumbered paragraph (the typst template's rule); the mark is removed
local function strip_tilde(inls)
  local first = inls[1]
  if not (first and first.t == "Str" and first.text:sub(1, 1) == "~") then return false end
  local rest = first.text:sub(2)
  if rest == "" then table.remove(inls, 1) else inls[1] = pandoc.Str(rest) end
  if inls[1] and inls[1].t == "Space" then table.remove(inls, 1) end
  return true
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  add(raw(court_title(meta)))
  add(raw(spacer(480)))
  add(raw(caption(meta)))
  add(raw(spacer(480)))

  local blocks = doc.blocks
  local n = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      b = pandoc.walk_block(b, { Str = function(s) return pandoc.Str(s.text:upper()) end })
    elseif b.t == "Para" then
      local unnumbered = strip_tilde(b.content)
      if CFG.numbered and not unnumbered then
        n = n + 1
        table.insert(b.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
        table.insert(b.content, 1, pandoc.Str(n .. "."))
      end
      -- the last paragraph stays on the page with the signature block: a signature alone on a page is not allowed
      if i == #blocks then
        b = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" }))
      end
    end
    add(b)
  end

  if meta.signature then add(raw(signature(meta))) end

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
