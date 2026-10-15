-- W.D. Va. brief in support of a motion, DOCX engine (docs/DOCX.md). The markdown contract of ../README.md -> a
-- Word document on reference.docx (built by build-reference.sh). The same form as typst/vawd-motion-brief.typ:
--   cover: the three-line court title, the caption (box or ")" style), the brief title in capitals;
--   body: section headings (# ) centered caps; numbered headings (## 1., ### a., #### (i)) with a hanging label;
--         paragraphs first-line indented; lettered lists (a., b., ...) with a hanging indent; block quotes single;
--         native footnotes;
--   signature block at 3.25 in ("Dated:", the preamble, the e-signature, each counsel, the role lines);
--   certificate of service (centered caps title, the text, the recipients, the signature block).
-- Everything typed here is styled by reference.docx (Centered, Single, SigIndent, Gap, GapHalf, Recipient,
-- Hanging); the body keeps its markdown structure. Page numbers come from the footer.
-- Known limits: see ../README.md "## Engines".

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function stringify(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- inlines -> w:r runs; italics and bold kept, everything else as text
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
  return raw(xpara("Centered", runs(inls, bold and '<w:b/>' or '')))
end

local function line(style, inls, ppr)
  return raw(xpara(style, runs(inls), ppr))
end

local function meta_inlines(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" and v[1] then return v[1].content or {} end
  return { pandoc.Str(stringify(v)) }
end

local function caseLabel(meta)
  return meta.case_label and stringify(meta.case_label) or "Civil Action No."
end

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
  local grid, total = {}, 0
  for _, c in ipairs(cols) do grid[#grid + 1] = '<w:gridCol w:w="' .. c .. '"/>'; total = total + c end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

local function party_lines(caption)
  local items = {}
  for i, p in ipairs(caption.parties) do
    if i > 1 then items[#items + 1] = { text = "v.", style = "Single", ppr = '<w:ind w:left="864" w:firstLine="0"/>' } end
    for _, n in ipairs(p.names) do items[#items + 1] = { inl = n, style = "Single", ppr = "" } end
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
  for _, it in ipairs(party_lines(caption)) do left[#left + 1] = xpara(it.style, item_inner(it), it.ppr) end
  local borders = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local right = xpara("Single", runs({ pandoc.Str(caseLabel(meta)), pandoc.Space(), pandoc.Str(stringify(meta.case_number)) }),
    '<w:ind w:left="144" w:firstLine="0"/>')
  return raw(table_xml({ 4752, 216, 4392 }, {
    '<w:tr>' .. tc(4752, borders, nil, left) .. tc(216, nil, nil, { xpara("Single", "") })
      .. tc(4392, nil, "center", { right }) .. '</w:tr>' }))
end

local function caption_parens(meta, caption)
  local rows = {}
  for _, it in ipairs(party_lines(caption)) do
    local marks = {}
    for _ = 1, caption_lines(item_text(it)) do marks[#marks + 1] = xpara("ParensMark", runs({ pandoc.Str(")") })) end
    rows[#rows + 1] = '<w:tr>' .. tc(4752, nil, nil, { xpara(it.style, item_inner(it), it.ppr) })
      .. tc(576, nil, nil, marks) .. '</w:tr>'
  end
  return raw(table_xml({ 4752, 576 }, rows))
end

-- the cover (Fed. R. Civ. P. 10(a); the brief's title)
local function cover(meta)
  local caption = meta.caption or {}
  local blocks = {}
  blocks[#blocks + 1] = centered({ pandoc.Str("UNITED STATES DISTRICT COURT") })
  blocks[#blocks + 1] = centered({ pandoc.Str("WESTERN DISTRICT OF VIRGINIA") })
  blocks[#blocks + 1] = centered({ pandoc.Str(string.upper(stringify(meta.division))) })
  blocks[#blocks + 1] = gap()
  if stringify(caption.style or "box") == "parens" then
    blocks[#blocks + 1] = caption_parens(meta, caption)
    blocks[#blocks + 1] = gap("GapHalf")
    blocks[#blocks + 1] = line("Single", { pandoc.Str(caseLabel(meta)), pandoc.Space(), pandoc.Str(stringify(meta.case_number)) }, '<w:ind w:firstLine="720"/>')
  else
    blocks[#blocks + 1] = caption_box(meta, caption)
  end
  blocks[#blocks + 1] = gap()
  blocks[#blocks + 1] = centered({ pandoc.Str(string.upper(stringify(meta.brief_title))) }, true)
  blocks[#blocks + 1] = gap("GapHalf")
  return blocks
end

-- the signer's block (Fed. R. Civ. P. 11(a); Local Rule 11(a)): preamble, e-signature, each counsel, role lines
local function signer_block(sig, preamble)
  local out = {}
  local function sl(inls) out[#out + 1] = line("SigIndent", inls) end
  local pre = preamble and (sig.preamble or {}) or {}
  for _, l in ipairs(pre) do sl(meta_inlines(l)) end
  if #pre > 0 then out[#out + 1] = gap() end
  sl(meta_inlines(sig.signed_by))
  for k, g in ipairs(sig.counsel or {}) do
    if k > 1 then out[#out + 1] = gap() end
    for _, n in ipairs(g.names or {}) do sl(meta_inlines(n)) end
    for _, l in ipairs(g.lines or {}) do sl(meta_inlines(l)) end
  end
  local role = sig.role or {}
  if #role > 0 then out[#out + 1] = gap() end
  for _, l in ipairs(role) do sl(meta_inlines(l)) end
  return out
end

local function signature(meta)
  local out = { gap() }
  if meta.date then
    out[#out + 1] = line("Single", { pandoc.Str("Dated: " .. stringify(meta.date)) })
    out[#out + 1] = gap()
  end
  for _, b in ipairs(signer_block(meta.signature or {}, true)) do out[#out + 1] = b end
  return out
end

local function certificate(meta)
  if not meta.service then return {} end
  local svc = meta.service
  -- kept on one page (typst's unbreakable block): every paragraph but the last keeps with the next
  local out = { gap("GapPlain"), centered({ pandoc.Str("CERTIFICATE OF SERVICE") }, true), gap("GapHalfKeep") }
  out[#out + 1] = div("BodyKeep", { pandoc.Para(meta_inlines(svc.text)) })
  out[#out + 1] = gap("GapHalfKeep")
  for _, l in ipairs(svc.recipients or {}) do out[#out + 1] = line("Recipient", meta_inlines(l)) end
  out[#out + 1] = gap()
  for _, b in ipairs(signer_block(meta.signature or {}, false)) do out[#out + 1] = b end
  return out
end

-- heading labels: level 2 "1.", level 3 "a.", level 4 "(i)"; level 1 has none (typst's numbering)
local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

local function letter(n)
  return string.char(96 + n)
end

local function list_blocks(items, ordered)
  local out = {}
  for i, item in ipairs(items) do
    local label = ordered and (letter(i) .. ".") or "•"
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
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end

  -- the last section (its level-1 heading and what follows) is kept on one page with the signature block when it
  -- is short and has no footnote (typst's final-section): its paragraphs get the BodyKeep style (keep with next)
  local last = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then last = i end
  end
  local keep_from = nil
  if last then
    local text, note = "", false
    for i = last, #doc.blocks do
      text = text .. stringify(doc.blocks[i])
      pandoc.walk_block(doc.blocks[i], { Note = function(n) note = true end })
    end
    if #text < 1200 and not note then keep_from = last end
  end

  local c = { 0, 0, 0, 0 }
  for i, b in ipairs(doc.blocks) do
    if keep_from and i >= keep_from and b.t == "Para" then
      blocks[#blocks + 1] = div("BodyKeep", { b })
    elseif b.t == "Header" then
      local lvl = b.level
      if lvl == 1 then
        c[1] = c[1] + 1; c[2], c[3], c[4] = 0, 0, 0
        blocks[#blocks + 1] = b
      else
        c[lvl] = c[lvl] + 1
        for k = lvl + 1, 4 do c[k] = 0 end
        local label
        if lvl == 2 then label = tostring(c[2]) .. "."
        elseif lvl == 3 then label = letter(c[3]) .. "."
        else label = "(" .. roman(c[4]) .. ")" end
        local inls = { pandoc.Str(label), TAB }
        for _, el in ipairs(b.content) do inls[#inls + 1] = el end
        blocks[#blocks + 1] = pandoc.Header(lvl, inls, b.attr)
      end
    elseif b.t == "OrderedList" then
      for _, x in ipairs(list_blocks(b.content, true)) do blocks[#blocks + 1] = x end
    elseif b.t == "BulletList" then
      for _, x in ipairs(list_blocks(b.content, false)) do blocks[#blocks + 1] = x end
    else
      blocks[#blocks + 1] = b
    end
  end

  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
