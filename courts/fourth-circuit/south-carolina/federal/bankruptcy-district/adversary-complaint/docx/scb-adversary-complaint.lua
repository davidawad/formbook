-- scb-adversary-complaint.lua (docx engine, scb/adversary-complaint).
-- What pandoc does not do by itself, following typst/scb-adversary-complaint.typ (see ../README.md, "## Engines"):
--   * the caption (Official Form 416 layout: In re: / Debtor. over the adversary parties, rules closing each block)
--     and the court title, from the frontmatter, as WordprocessingML;
--   * allegations numbered 1, 2, 3 ... (Fed. R. Civ. P. 10(b) as applied by Rule 7010): a paragraph that is not
--     directly after a quotation or list and not before a list; wrapped lines flush left;
--   * lettered prayer lists (a., b., ...); the last two blocks and the signature stay on one page (keepNext);
--   * the signature block and "Dated" line; the page number is in the reference's footer.
-- Content-agnostic: every case word comes from the sample's frontmatter.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function sx(v)
  return pandoc.utils.stringify(v)
end

-- WordprocessingML helpers. Twips: 1440 per inch, 20 per point.
local function P(o, runs)
  local x = {}
  if o.style then x[#x + 1] = '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep then x[#x + 1] = '<w:keepNext/><w:keepLines/>' end
  if o.rule then x[#x + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>' end
  x[#x + 1] = string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>',
    o.before or 0, o.after or 0, o.line or 391)
  local ind = {}
  if o.left then ind[#ind + 1] = 'w:left="' .. o.left .. '"' end
  if o.right then ind[#ind + 1] = 'w:right="' .. o.right .. '"' end
  if o.first then ind[#ind + 1] = 'w:firstLine="' .. o.first .. '"' end
  if #ind > 0 then x[#x + 1] = '<w:ind ' .. table.concat(ind, ' ') .. '/>' end
  if o.jc then x[#x + 1] = '<w:jc w:val="' .. o.jc .. '"/>' end
  return '<w:p><w:pPr>' .. table.concat(x) .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function R(text, bold)
  local rpr = bold and '<w:rPr><w:b/><w:bCs/></w:rPr>' or ''
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function raw(xml)
  return pandoc.RawBlock('openxml', xml)
end

local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

local function TC(width, paras, o)
  local b = o.rightRule and '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' or ''
  local m = '<w:tcMar><w:left w:w="' .. (o.marL or 0) .. '" w:type="dxa"/><w:right w:w="' .. (o.marR or 0) .. '" w:type="dxa"/></w:tcMar>'
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. b .. m .. '</w:tcPr>' .. paras .. '</w:tc>'
end

-- Caption: left block (In re: / Debtor. / rule / parties / rule) and right block (case, chapter, adversary, title).
local function caption(meta)
  local b = meta.bankruptcy
  -- Spacing: a docx line is 19.56 pt (exact); the typst stack items are 16.96 pt high with 12 pt gaps, so a gap
  -- between two caption lines is 9.4 pt (188 twips) here, and a rule is a bottom border (space 0).
  local left = {}
  left[#left + 1] = P({ after = 188 }, R("In re:"))
  local debtors = b.debtor
  for i, d in ipairs(debtors) do
    left[#left + 1] = P({ after = (i == #debtors) and 188 or 0 }, R(sx(d)))
  end
  left[#left + 1] = P({ jc = "right", rule = true }, R("Debtor."))
  local parties = meta.caption.parties
  for i, p in ipairs(parties) do
    for j, n in ipairs(p.names) do
      left[#left + 1] = P({ before = (i == 1 and j == 1) and 173 or 0 }, R(sx(n)))
    end
    left[#left + 1] = P({ left = 2016 }, R(sx(p.designation)))
    if i < #parties then
      left[#left + 1] = P({ before = 188, after = 188, left = 576 }, R("v."))
    end
  end
  -- the closing rule is an empty paragraph carrying the bottom border
  left[#left + 1] = P({ line = 60, rule = true }, "")

  local right = {}
  right[#right + 1] = P({}, R(sx(b.case_number)))
  right[#right + 1] = P({}, R(sx(b.chapter)))
  right[#right + 1] = P({ before = 1388 }, R(sx(meta.adversary_number)))
  right[#right + 1] = P({ before = 668 }, R(sx(meta.title), true))

  return table_xml({ 4896, 4464 }, {
    '<w:tr>' .. TC(4896, table.concat(left), { rightRule = true, marR = 216 })
      .. TC(4464, table.concat(right), { marL = 720 }) .. '</w:tr>',
  })
end

local function court_title(meta)
  local out = {}
  local lines = meta.court
  for i, l in ipairs(lines) do
    out[#out + 1] = P({ jc = "center" }, R(sx(l), i == #lines))
  end
  return table.concat(out)
end

local function kind(b)
  if b.t == "Header" then return "heading" end
  if b.t == "BlockQuote" then return "quote" end
  if b.t == "BulletList" or b.t == "OrderedList" then return "list" end
  if b.t == "Para" or b.t == "Plain" then return "para" end
  return "other"
end

local function letter(i)
  return string.char(96 + i)
end

local function attr(style)
  return pandoc.Attr("", {}, { ["custom-style"] = style })
end

local TAB = pandoc.RawInline('openxml', '<w:r><w:tab/></w:r>')

function Pandoc(doc)
  local meta = doc.meta
  local blocks = doc.blocks
  local n = #blocks
  local kinds = {}
  for i, b in ipairs(blocks) do kinds[i] = kind(b) end

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- cover (Fed. R. Bankr. P. 9004(b); 7010 and Form 416)
  add(raw(court_title(meta)))
  add(raw(P({ line = 428 }, "")))
  add(raw(caption(meta)))
  add(raw(P({ line = 218 }, "")))

  if meta.lead_in then
    add(pandoc.Div({ pandoc.Para(pandoc.read(sx(meta.lead_in), "markdown+smart").blocks[1].content) }, attr("SCB Lead In")))
  end

  local counter = 0
  for i, b in ipairs(blocks) do
    local k = kinds[i]
    local prev = (i > 1) and kinds[i - 1] or "heading"
    local nxt = (i < n) and kinds[i + 1] or ""
    local keep = (i >= n - 1)
    if k == "para" and prev ~= "quote" and prev ~= "list" and nxt ~= "list" then
      counter = counter + 1
      local inl = pandoc.List({ pandoc.Str(tostring(counter) .. "."), TAB })
      inl:extend(b.content)
      add(pandoc.Div({ pandoc.Para(inl) }, attr(keep and "SCB Numbered Keep" or "SCB Numbered")))
    elseif k == "para" then
      local style = keep and "SCB Body Keep" or (prev == "quote" and "SCB After Quote" or nil)
      if style then add(pandoc.Div({ b }, attr(style))) else add(b) end
    elseif k == "list" then
      local ordered = (b.t == "OrderedList")
      local items = {}
      for j, item in ipairs(b.content) do
        local label = ordered and (letter(j) .. ".") or "\u{2022}"
        local first = item[1]
        local inl = pandoc.List({ pandoc.Str(label), TAB })
        if first and (first.t == "Para" or first.t == "Plain") then
          inl:extend(first.content)
        end
        local st = keep and "SCB List Keep" or "SCB List"
        items[#items + 1] = pandoc.Div({ pandoc.Para(inl) }, attr(st))
        for q = 2, #item do items[#items + 1] = item[q] end
      end
      for _, it in ipairs(items) do add(it) end
    else
      add(b)
    end
  end

  -- signature block (SC LBR 9011-4); keep together with the last blocks
  local sig = meta.signature
  add(raw(P({ before = 480, left = 4680, keep = true }, R("/s/ " .. sx(sig.signer)))))
  for _, l in ipairs(sig.lines) do
    add(raw(P({ left = 4680, keep = true }, R(sx(l)))))
  end
  add(raw(P({ left = 4680, keep = true }, R(sx(sig.role)))))
  add(raw(P({ before = 480 }, R("Dated: " .. sx(sig.date)))))

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
