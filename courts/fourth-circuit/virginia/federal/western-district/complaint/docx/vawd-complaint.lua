-- W.D. Va. complaint, DOCX engine (docs/DOCX.md). The markdown contract of ../README.md -> a Word document on
-- reference.docx (built by build-reference.sh). The same form as typst/vawd-complaint.typ:
--   cover: the three-line court title, the caption (box or ")" style), the title if the sample has one;
--   body: each paragraph numbered 1, 2, ... (Fed. R. Civ. P. 10(b)), headings and lists unnumbered, the
--         paragraph after a PRAYER heading unnumbered; prayer items lettered a., b., ... (hanging indent);
--   signature block at 3.25 in, "DATED:" line, Rule 11(a) lines.
-- Everything typed here is styled by reference.docx (Centered, Single, Allegation, Hanging, SigIndent, Gap,
-- GapHalf, Recipient, ParensMark); the body keeps its markdown structure. Page numbers come from the footer.
-- Known limits: see ../README.md "## Engines" (the ")" marks are counted from the text length, not measured).

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function stringify(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- inlines -> w:r runs; italics kept, everything else as plain text
local function runs(inls, rpr)
  rpr = rpr or ""
  local out = {}
  for _, el in ipairs(inls) do
    if el.t == "Str" then
      out[#out + 1] = '<w:r><w:rPr>' .. rpr .. '</w:rPr><w:t xml:space="preserve">' .. esc(el.text) .. '</w:t></w:r>'
    elseif el.t == "Space" or el.t == "SoftBreak" then
      out[#out + 1] = '<w:r><w:rPr>' .. rpr .. '</w:rPr><w:t xml:space="preserve"> </w:t></w:r>'
    elseif el.t == "Emph" then
      out[#out + 1] = runs(el.content, rpr .. '<w:i/>')
    elseif el.t == "Strong" then
      out[#out + 1] = runs(el.content, rpr .. '<w:b/>')
    else
      out[#out + 1] = runs({ pandoc.Str(stringify(el)) }, rpr)
    end
  end
  return table.concat(out)
end

-- a paragraph of raw WordprocessingML in a named style
local function xpara(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. inner .. '</w:p>'
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function gap(style)
  return raw(xpara(style or "Gap", ""))
end

local function div(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function centered(inls, bold)
  local inner = bold and runs(inls, '<w:b/>') or runs(inls)
  return raw(xpara("Centered", inner))
end

local function line(style, inls, ppr)
  return raw(xpara(style, runs(inls), ppr))
end

-- a line of a meta value (MetaInlines or MetaBlocks) as one Para
local function meta_inlines(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" and v[1] then return v[1].content or {} end
  return { pandoc.Str(stringify(v)) }
end

local function caseLabel(meta)
  return meta.case_label and stringify(meta.case_label) or "Civil Action No."
end

-- Estimated number of lines a caption text takes in the 3.3 in party column (for the ")" marks). A capital letter
-- is wider than a lower-case one: 40 lower-case letters per line, a capital counts 1.5.
local function caption_lines(s)
  local units = 0
  for ch in s:gmatch(".") do
    if ch:match("%u") then units = units + 1.5 else units = units + 1 end
  end
  return math.max(1, math.ceil(units / 40))
end

local function tc(width, borders, valign, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or '')
    .. (valign and ('<w:vAlign w:val="' .. valign .. '"/>') or '') .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(cols, rows)
  local grid = {}
  for _, c in ipairs(cols) do grid[#grid + 1] = '<w:gridCol w:w="' .. c .. '"/>' end
  local total = 0
  for _, c in ipairs(cols) do total = total + c end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

-- the party block: one line per name or designation; "v." between the parties
local function party_lines(caption)
  local items = {}
  for i, p in ipairs(caption.parties) do
    if i > 1 then items[#items + 1] = { text = "v.", style = "Single", ppr = '<w:ind w:left="864" w:firstLine="0"/>' } end
    for _, n in ipairs(p.names) do
      items[#items + 1] = { inl = n, style = "Single", ppr = "" }
    end
    items[#items + 1] = { inl = p.designation, style = "Single", ppr = '<w:ind w:left="2160" w:firstLine="0"/>' }
  end
  return items
end

local function item_inner(it)
  if it.text then return runs({ pandoc.Str(it.text) }) end
  return runs(meta_inlines(it.inl))
end

local function item_text(it)
  return it.text or stringify(it.inl)
end

local function caption_box(meta, caption)
  local left = {}
  for _, it in ipairs(party_lines(caption)) do
    left[#left + 1] = xpara(it.style, item_inner(it), it.ppr)
  end
  local borders = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local right = xpara("Single", runs({ pandoc.Str(caseLabel(meta)),
    pandoc.Space(), pandoc.Str(stringify(meta.case_number)) }), '<w:ind w:left="144" w:firstLine="0"/>')
  return raw(table_xml({ 4752, 216, 4392 }, {
    '<w:tr>' .. tc(4752, borders, nil, left) .. tc(216, nil, nil, { xpara("Single", "") })
      .. tc(4392, nil, "center", { right }) .. '</w:tr>' }))
end

local function caption_parens(meta, caption)
  local rows = {}
  for _, it in ipairs(party_lines(caption)) do
    local n = caption_lines(item_text(it))
    local marks = {}
    for _ = 1, n do marks[#marks + 1] = xpara("ParensMark", runs({ pandoc.Str(")") })) end
    rows[#rows + 1] = '<w:tr>' .. tc(4752, nil, nil, { xpara(it.style, item_inner(it), it.ppr) })
      .. tc(576, nil, nil, marks) .. '</w:tr>'
  end
  return raw(table_xml({ 4752, 576 }, rows))
end

-- the cover (Fed. R. Civ. P. 10(a))
local function cover(meta)
  local caption = meta.caption or {}
  local style = stringify(caption.style or "box")
  local blocks = {}
  blocks[#blocks + 1] = centered({ pandoc.Str("UNITED STATES DISTRICT COURT") })
  blocks[#blocks + 1] = centered({ pandoc.Str("WESTERN DISTRICT OF VIRGINIA") })
  blocks[#blocks + 1] = centered({ pandoc.Str(string.upper(stringify(meta.division))) })
  blocks[#blocks + 1] = gap()
  if style == "parens" then
    blocks[#blocks + 1] = caption_parens(meta, caption)
    blocks[#blocks + 1] = gap("GapHalf")
    blocks[#blocks + 1] = line("Single", {
      pandoc.Str(caseLabel(meta)), pandoc.Space(),
      pandoc.Str(stringify(meta.case_number)) })
  else
    blocks[#blocks + 1] = caption_box(meta, caption)
  end
  if meta.title then
    blocks[#blocks + 1] = gap("GapHalf")
    blocks[#blocks + 1] = centered(meta_inlines(meta.title), true)
  end
  blocks[#blocks + 1] = gap()
  return blocks
end

-- the signature block (Fed. R. Civ. P. 11(a); Local Rule 11(a))
local function signature_block(meta)
  local out = { gap() }
  out[#out + 1] = raw(xpara("Single", runs({ pandoc.Str("DATED: " .. stringify(meta.date) .. ".") }), ''))
  out[#out + 1] = gap()
  local sig = meta.signature or {}
  out[#out + 1] = line("SigIndent", { pandoc.Str("Respectfully submitted,") })
  out[#out + 1] = gap()
  for _, l in ipairs(sig.firm or {}) do out[#out + 1] = line("SigIndent", meta_inlines(l)) end
  out[#out + 1] = gap()
  out[#out + 1] = line("SigIndent", { pandoc.Str("By: /s/ " .. stringify(sig.signer)) })
  out[#out + 1] = line("SigIndent", meta_inlines(sig.signer))
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = line("SigIndent", meta_inlines(l)) end
  return out
end

local function is_prayer_heading(b)
  return b.t == "Header" and stringify(b.content):find("PRAYER", 1, true) ~= nil
end

-- an ordered or bullet list -> lettered hanging paragraphs (a., b., ...) like the typst enum
local function list_blocks(items, ordered)
  local out = {}
  for i, item in ipairs(items) do
    local label = ordered and (string.char(96 + i) .. ".") or "•"
    local first = item[1]
    if first and (first.t == "Plain" or first.t == "Para") then
      out[#out + 1] = div("Hanging", { pandoc.Para({ pandoc.Str(label), TAB, table.unpack(first.content) }) })
      for k = 2, #item do out[#out + 1] = item[k] end
    else
      out[#out + 1] = div("Hanging", { pandoc.Para({ pandoc.Str(label) }) })
      for _, b in ipairs(item) do out[#out + 1] = b end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  -- the lead-in (unnumbered, first-line indented), the cover
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end
  if meta.lead_in then
    blocks[#blocks + 1] = pandoc.Para(meta_inlines(meta.lead_in))
  end

  -- the allegations: numbered, except headings, lists, and the paragraph after a PRAYER heading
  local n = 0
  local unnumbered_next = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if is_prayer_heading(b) then unnumbered_next = true end
      blocks[#blocks + 1] = b
    elseif b.t == "OrderedList" then
      for _, x in ipairs(list_blocks(b.content, true)) do blocks[#blocks + 1] = x end
    elseif b.t == "BulletList" then
      for _, x in ipairs(list_blocks(b.content, false)) do blocks[#blocks + 1] = x end
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered_next then
        blocks[#blocks + 1] = pandoc.Para(b.content)
      else
        n = n + 1
        local inls = { pandoc.Str(tostring(n) .. "."), TAB }
        for _, el in ipairs(b.content) do inls[#inls + 1] = el end
        blocks[#blocks + 1] = div("Allegation", { pandoc.Para(inls) })
      end
      unnumbered_next = false
    else
      blocks[#blocks + 1] = b
    end
  end

  for _, b in ipairs(signature_block(meta)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
