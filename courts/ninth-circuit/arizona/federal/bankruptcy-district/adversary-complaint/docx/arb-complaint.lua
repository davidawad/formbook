-- Adversary complaint, United States Bankruptcy Court, District of Arizona (arb), DOCX engine.
-- The markdown contract (samples/INPUT-*.md, see ../README.md) -> Word, on reference.docx.
-- Built here as raw OOXML, the same layout as typst/arb-adversary-complaint.typ:
--   filer block from line 1 (LRBP 9004-1(a)); court title on line 8; the dual caption as a table with a right
--   and a bottom rule on the debtor and party cells (LRBP 9004-1(c)); numbered allegations (Fed. R. Civ. P. 10(b));
--   lettered lists (a), (b), ...; jury line (if any); signature block as a borderless table.
-- Pleading numbers and rules, page number and footer come from reference.docx (header1.xml, footer1.xml,
-- pgBorders); docx/render.sh fills the footer tokens.
-- Metadata is read from the sample's frontmatter and the page never carries text of its own.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, o)
  o = o or {}
  local rpr = ""
  if o.b then rpr = rpr .. "<w:b/><w:bCs/>" end
  if o.i then rpr = rpr .. "<w:i/><w:iCs/>" end
  if o.caps then rpr = rpr .. "<w:caps/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function TAB()
  return '<w:r><w:tab/></w:r>'
end

-- inline markdown -> runs (italics and bold kept; other inlines as plain text)
local runs
runs = function(inls, o)
  o = o or {}
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, o)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then out[#out + 1] = run(" ", o)
    elseif t == "Emph" then out[#out + 1] = runs(el.content, { b = o.b, i = true, caps = o.caps })
    elseif t == "Strong" then out[#out + 1] = runs(el.content, { b = true, i = o.i, caps = o.caps })
    elseif t == "Span" then out[#out + 1] = runs(el.content, o)
    elseif t == "Quoted" then
      local q1, q2 = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then q1, q2 = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(q1, o) .. runs(el.content, o) .. run(q2, o)
    else out[#out + 1] = run(pandoc.utils.stringify(el), o) end
  end
  return table.concat(out)
end

-- a metadata value (string, MetaInlines or other) -> runs
local function mruns(v, o)
  if v == nil then return "" end
  if type(v) == "string" then return run(v, o) end
  if v.t == "MetaInlines" then return runs(v, o) end
  return run(pandoc.utils.stringify(v), o)
end

local function mtext(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function para(xml, style, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. xml .. '</w:p>'
end

-- Lines of a cell, estimated from its text (13 pt EB Garamond; caps wider). The row height is then rounded up
-- to whole numbered lines (24 pt), so the body after a table stays on the pleading numbers.
local function est_lines(text, width_pt, caps)
  -- greedy word wrap with EB Garamond average advances (caps about 0.6 em, lower case 0.42 em; measured on
  -- the typst render of the sample caption); a line of the cell holds whole words
  local cw = 13 * (caps and 0.6 or 0.42)
  local sp = 13 * 0.25
  local lines, cur = 1, nil
  for word in text:gmatch("%S+") do
    local w = #word * cw
    if cur == nil then cur = w
    elseif cur + sp + w <= width_pt then cur = cur + sp + w
    else lines = lines + 1; cur = w end
  end
  return lines
end

-- A caption cell: `items` are paragraphs in the Single style. A blank item is half a line (typst: an empty
-- paragraph, 6.5 pt with its spacing). With `rule`, the cell is the party box of the typst form: its paragraphs
-- carry a right rule 0.1 in inside the cell edge, and the last paragraph a bottom rule 8 pt under its text.
-- Rules on the paragraphs (not cell borders) keep the box at the height of its own text, not the row's.
-- Returns the XML and the estimated height in points.
local function cell(width, items, rule, top_pt, inner_w_pt, ind_left)
  local tcmar = '<w:tcMar><w:top w:w="' .. math.floor(top_pt * 20) .. '" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/></w:tcMar>'
  local ps, est = {}, 0
  local rightrule = '<w:pBdr><w:right w:val="single" w:sz="6" w:space="5" w:color="000000"/></w:pBdr>'
  for i, it in ipairs(items) do
    local last = (i == #items)
    local pbdr = rule and rightrule or ''
    if rule and last then
      pbdr = '<w:pBdr><w:right w:val="single" w:sz="6" w:space="5" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="8" w:color="000000"/></w:pBdr>'
    end
    local ind = rule and '<w:ind w:right="100"/>' or ((ind_left and ind_left > 0) and ('<w:ind w:left="' .. ind_left .. '"/>') or '')
    if it.xml == "" then
      ps[#ps + 1] = '<w:p><w:pPr><w:pStyle w:val="Single"/>' .. pbdr .. '<w:spacing w:before="0" w:after="0" w:line="130" w:lineRule="exact"/>' .. ind .. '</w:pPr></w:p>'
      est = est + 6.5
    else
      ps[#ps + 1] = para(it.xml, "Single", pbdr .. ind)
      est = est + est_lines(it.text or "", inner_w_pt, it.caps) * 15
    end
  end

  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. tcmar .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>', est
end

local function table_open(cols)
  local grid = {}
  local sum = 0
  for _, c in ipairs(cols) do grid[#grid + 1] = '<w:gridCol w:w="' .. c .. '"/>'; sum = sum + c end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. sum .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
end

-- The caption table. `rows` = { {left = items, right = items, top = pt, rule = bool}, ... }. The table is
-- padded at its foot so its height is whole numbered lines (typst: the whole caption is on the grid), and the
-- body after it stays on the pleading numbers.
local function caption_table(rows)
  local cells, ests = {}, {}
  for i, r in ipairs(rows) do
    local left = r.left
    if #left == 0 then left = { { xml = '', text = '' } } end
    local lx, le = cell(4464, left, r.rule, r.top, 218, 0)
    local rx, re = cell(4536, r.right, false, r.top, 205, 432)
    cells[i] = { lx, rx }
    ests[i] = math.max(le, re) + r.top
  end
  local total = 0
  for _, e in ipairs(ests) do total = total + e end
  ests[#ests] = ests[#ests] + (math.ceil(total / 24) * 24 - total)
  local out = {}
  for i, c in ipairs(cells) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. math.floor(ests[i] * 20 + 0.5)
      .. '" w:hRule="atLeast"/></w:trPr>' .. c[1] .. c[2] .. '</w:tr>'
  end
  return table.concat(out)
end

-- The caption (LRBP 9004-1(a), (b), (c), (e); FRBP 7010): the debtor and the case number; then, in an
-- adversary, the parties and the adversary number; then the title, the relief sought and the hearing.
local function caption(meta)
  local debtor = meta.debtor
  local function add(list, xml, text, caps)
    list[#list + 1] = { xml = xml, text = text, caps = caps }
  end
  local l1, r1 = {}, {}
  add(l1, run("In re:"), "In re:")
  add(l1, '', '')
  for _, n in ipairs(debtor.names) do add(l1, mruns(n), mtext(n), true) end
  add(l1, '', '')
  add(l1, run("Debtor.", { i = true }), "Debtor.")
  add(r1, run("Chapter " .. mtext(debtor.chapter)), "Chapter " .. mtext(debtor.chapter))
  add(r1, '', '')
  add(r1, run("Case No. " .. mtext(debtor.case_number)), "Case No. " .. mtext(debtor.case_number))
  local function title_rows(list)
    add(list, '', '')
    add(list, mruns(meta.title, { b = true, caps = true }), mtext(meta.title), true)
    add(list, '', '')
    add(list, mruns(meta.relief), mtext(meta.relief))
    if meta.hearing then
      local h = meta.hearing
      add(list, '', '')
      add(list, run("Hearing date: " .. mtext(h.date)), "Hearing date: " .. mtext(h.date))
      add(list, run("Time: " .. mtext(h.time)), "Time: " .. mtext(h.time))
      add(list, run("Place: " .. mtext(h.place)), "Place: " .. mtext(h.place))
    end
  end
  if meta.adversary_number then
    local l2, r2 = {}, {}
    local first = true
    for _, p in ipairs(meta.parties) do
      if not first then add(l2, '', ''); add(l2, run("v."), "v."); add(l2, '', '') end
      first = false
      for _, n in ipairs(p.names) do add(l2, mruns(n), mtext(n), true) end
      add(l2, '', '')
      add(l2, run(mtext(p.designation), { i = true }), mtext(p.designation))
    end
    local adv = "Adv. No. " .. mtext(meta.adversary_number)
    add(r2, run(adv), adv)
    title_rows(r2)
    return table_open({ 4464, 4536 }) .. caption_table({
      { left = l1, right = r1, top = 0, rule = true },
      { left = l2, right = r2, top = 0, rule = true },
    }) .. '</w:tbl>'
  end
  title_rows(r1)
  return table_open({ 4464, 4536 }) .. caption_table({ { left = l1, right = r1, top = 0, rule = true } }) .. '</w:tbl>'
end

-- filer block (LRBP 9004-1(a)): the lines single-spaced, padded to seven numbered lines
local function filer(meta)
  local xml = {}
  local n = 0
  for _, line in ipairs(meta.filer) do
    xml[#xml + 1] = para(mruns(line), "Single")
    n = n + 1
  end
  local pad = 7 * 24 - n * 15
  if pad > 0 then
    xml[#xml + 1] = '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. math.floor(pad * 20) .. '" w:lineRule="exact"/></w:pPr></w:p>'
  end
  return table.concat(xml)
end

local function court_title()
  local out = {}
  for _, l in ipairs({ "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF ARIZONA" }) do
    out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="Normal"/><w:jc w:val="center"/></w:pPr>' .. run(l, { b = true }) .. '</w:p>'
  end
  return table.concat(out)
end

local function signature(meta)
  local sig = meta.signature
  local left = { run("Dated: " .. mtext(meta.date)) }
  local right = { para(run("Respectfully submitted,"), "Single") }
  right[#right + 1] = '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/></w:pPr></w:p>'
  right[#right + 1] = para(run("/s/ " .. mtext(sig.signer)), "Single")
  local lines = 2
  for _, l in ipairs(sig.lines) do right[#right + 1] = para(mruns(l), "Single"); lines = lines + 1 end
  local h = math.floor((lines * 15 + 12) * 20 + 0.5)
  local rowxml = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. h .. '" w:hRule="atLeast"/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/></w:tcPr>' .. para(left[1], "Single") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5256" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr>'
  return table_open({ 3744, 5256 }) .. rowxml .. '</w:tbl>'
end

local function lettered_items(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local letter = "(" .. string.char(96 + i) .. ")"
    local first = true
    for _, b in ipairs(item) do
      if (b.t == "Para" or b.t == "Plain") and first then
        out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.RawInline("openxml", run(letter) .. TAB()), table.unpack(b.content) }) },
          pandoc.Attr("", {}, { ["custom-style"] = "Lettered" }))
        first = false
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  local function raw(x) blocks[#blocks + 1] = pandoc.RawBlock("openxml", x) end

  -- first page: filer block, court title, blank, dual caption
  raw(filer(meta))
  raw(court_title())
  raw('<w:p><w:pPr><w:pStyle w:val="Normal"/></w:pPr></w:p>')
  raw(caption(meta))

  -- lead-in (unnumbered), then the body
  if meta.lead_in then
    raw(para(mruns(meta.lead_in), "Numbered", "<w:ind w:firstLine=\"720\"/>"))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      local inl = { pandoc.RawInline("openxml", run(tostring(n) .. ".") .. TAB()) }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      blocks[#blocks + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(lettered_items(b)) do blocks[#blocks + 1] = x end
    else
      blocks[#blocks + 1] = b
    end
  end
  -- the last body paragraph or list item stays with the signature block (typst: the last chunk is set with the tail)
  for i = #blocks, 1, -1 do
    local b = blocks[i]
    if b.t == "Div" then
      local s = b.attr.attributes["custom-style"]
      if s == "Numbered" or s == "Lettered" then
        b.attr.attributes["custom-style"] = s .. "Keep"
        break
      end
    end
  end

  -- jury line (if demanded), then the signature block
  if meta.jury_demand == true or mtext(meta.jury_demand) == "true" then
    raw(para(run("Plaintiff demands a trial by jury on all claims so triable. Fed. R. Civ. P. 38, as applied by FRBP 9015."), "Numbered", '<w:keepNext/><w:ind w:firstLine="720"/>'))
  end
  raw(signature(meta))
  -- a 1 pt paragraph closes the body (Word needs one after a table); it does not push the signature to a page
  raw('<w:p><w:pPr><w:pStyle w:val="Normal"/><w:spacing w:line="20" w:lineRule="exact"/></w:pPr></w:p>')

  doc.blocks = blocks
  doc.meta = {}
  return doc
end
