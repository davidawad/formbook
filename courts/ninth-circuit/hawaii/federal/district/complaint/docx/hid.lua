-- U.S. District Court for the District of Hawaii: complaint, docx engine (docs/DOCX.md). The same markdown contract
-- as typst/hid-complaint.typ, and every block written as it sets it: the counsel block (LR 10.2(b)), the court title,
-- the caption box (LR 10.2(c)), the numbered allegations (FRCP 10(b)), the headings, the unnumbered WHEREFORE
-- paragraph ("> "), the lettered prayer ("- ") and the signature block. Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file. Counsel block and caption are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line, 253 a counsel
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local COURT = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF HAWAII" }
local BODY, SINGLE, COUNSEL = 644, 322, 253          -- typst pitch-double, pitch-single, pitch-counsel
local COUNSEL_SZ = 22                                -- typst counsel-size, 11 pt
local INDENT = 720                                   -- typst para-indent, 0.5 in
local TEXTW = 9360                                   -- 6.5 in
local CAP_LEFT, CAP_GAP = 4464, 288                -- typst caption-left, caption-gap
local CAP_PAD = 180                                  -- typst caption-pad, 0.125 in
local CAP_FOOT = 145                                 -- typst caption-foot (160) less the 0.75 pt rule LibreOffice sets below the cell
local SIG = 4320                                     -- typst signature-indent, 3 in
local COUNSEL_W = {                                  -- typst counsel-widths
  { 9360 }, { 4680, 4680 }, { 3312, 3168, 2880 },
}
local RULE = 'w:sz="6" w:space="0" w:color="000000"'

-- A paragraph: o = { before, after, line, left, hanging, first, tab, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table without cell margins: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- ---------------------------------------------------------------------------
-- Counsel block, court title, caption box
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local columns = list(meta.counsel and meta.counsel.columns)
  if #columns > 0 then
    local cells = {}
    for _, col in ipairs(columns) do
      local ps = {}
      for _, l in ipairs(list(col)) do ps[#ps + 1] = p(xe.inl(l, { sz = COUNSEL_SZ }), { line = COUNSEL }) end
      cells[#cells + 1] = { body = ps }
    end
    out[#out + 1] = tbl(COUNSEL_W[#columns], cells)
  end
  if meta.counsel_for then
    out[#out + 1] = p(xe.inl(meta.counsel_for, { i = true }), { before = SINGLE })
  end
  for i, l in ipairs(COURT) do
    out[#out + 1] = p(xe.runs(l, { b = true }),
      { jc = "center", keep = true, before = i == 1 and SINGLE or 0, after = i == #COURT and SINGLE or 0 })
  end
  -- the parties box: a rule at its right and bottom, the text a pad off them; one single line each
  local left = {}
  local parties = list(meta.parties)
  for i, party in ipairs(parties) do
    for _, n in ipairs(list(party.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p("")
    left[#left + 1] = p(xe.inl(party.designation, { i = true }), { jc = "right" })
    if i < #parties then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("v."))
      left[#left + 1] = p("")
    end
  end
  local case = "Civil No. " .. pandoc.utils.stringify(meta.case_number)
  local ji = meta.judge_initials and pandoc.utils.stringify(meta.judge_initials) or ""
  if ji ~= "" then case = case .. "-" .. ji end
  local right = {
    p("", { left = CAP_GAP }),
    p(xe.runs(case), { left = CAP_GAP }),
    p("", { left = CAP_GAP }),
    p(xe.inl(meta.title, { b = true }), { left = CAP_GAP }),
  }
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" ' .. RULE .. '/><w:right w:val="single" ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', body = left },
    { body = right },
  }, '<w:trPr><w:cantSplit/></w:trPr>')
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: the dated line, a blank line, the signature lines from 3 in; kept whole.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local out = {}
  local first = true
  local function line(body, left)
    out[#out + 1] = p(body, { keep = true, left = left, before = first and SINGLE or 0 })
    first = false
  end
  if meta.date then line(xe.inl(meta.date)) end
  line("")
  local blocks = list(meta.signature and meta.signature.blocks)
  for i, b in ipairs(blocks) do
    for _, l in ipairs(list(b.lines)) do
      local s = pandoc.utils.stringify(l)
      if s == "" then line("") else line(xe.inl(l), SIG) end
    end
    if i < #blocks then line("") end
  end
  -- the last paragraph ends the block: nothing after it to keep with
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number, as the typst template boxes it.
-- Another of typst's rules (Unicode line breaking): no break at a space before a period, comma, colon or semicolon
-- (". . ."); that space becomes a no-break space.
local function binds(l)
  for i = 1, #l - 2 do
    local b, nxt = l[i + 1], l[i + 2]
    if l[i].t == "Str" and b.t == "Space" and nxt.t == "Str" and nxt.text:find("^[.,:;]") then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A character Times New Roman has no glyph for (the okina, U+02BB) is set in the typst template's fallback face,
-- Liberation Serif, as typst sets it; named on its own run, since LibreOffice's own fallback splits the word around
-- it in the PDF text.
local FALLBACK = '<w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif"/>'
local OKINA = "\u{02BB}"
local function fallback_xml(xml)
  return (xml:gsub("<w:r>(.-)</w:r>", function(inner)
    local t = inner:match('<w:t xml:space="preserve">([^<]*)</w:t>$')
    if not t or not t:find(OKINA, 1, true) then return nil end
    local rpr = inner:match("^<w:rPr>.-</w:rPr>") or ""
    local frpr = rpr == "" and ("<w:rPr>" .. FALLBACK .. "</w:rPr>") or rpr:gsub("^<w:rPr>", "<w:rPr>" .. FALLBACK, 1)
    local out = {}
    for piece, sep in (t .. OKINA):gmatch("(.-)(" .. OKINA .. ")") do
      if piece ~= "" then out[#out + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. piece .. "</w:t></w:r>" end
      out[#out + 1] = "<w:r>" .. frpr .. "<w:t>" .. sep .. "</w:t></w:r>"
    end
    out[#out] = nil
    return table.concat(out)
  end))
end

local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function heading(el, h2)
  if el.level == 1 then
    local content = el.content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(content, { b = true }))
  end
  local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
  return xe.para({ xe.style("Heading2"), xe.KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. INDENT .. '"/></w:tabs>',
    xe.spacing(SINGLE, SINGLE, SINGLE), xe.ind(INDENT, INDENT), xe.jc("left") },
    xe.runs(ROMAN[h2] .. ".\t", { b = true }) .. xe.inl(el.content, { b = true }))
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs }):walk({ Inlines = binds })
  local out = cover(meta)
  -- the body's blocks in order: { kind, content }
  local blocks = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      blocks[#blocks + 1] = { "h", b }
    elseif b.t == "Para" or b.t == "Plain" then
      blocks[#blocks + 1] = { "numbered", b.content }
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do blocks[#blocks + 1] = { "unnumbered", q.content } end
    elseif b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("hid.lua: a prayer item holds one paragraph")
        end
        blocks[#blocks + 1] = { "item", { i, item[1].content } }
      end
    else
      error("hid.lua: unsupported block " .. b.t)
    end
  end
  local n, h2 = 0, 0
  -- the first block of the body stands a single line below the caption
  local start = #out + 1
  for k, blk in ipairs(blocks) do
    local kind, c = blk[1], blk[2]
    local keep = k == #blocks
    if kind == "h" then
      if c.level == 2 then h2 = h2 + 1 end
      out[#out + 1] = heading(c, h2)
    elseif kind == "item" then
      local lab = string.char(96 + c[1]) .. ".\t"
      out[#out + 1] = p(xe.runs(lab) .. xe.inl(c[2]),
        { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT, keep = keep })
    elseif kind == "unnumbered" then
      out[#out + 1] = p(xe.inl(c), { line = BODY, first = INDENT, keep = keep })
    else
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ". ") .. xe.inl(c), { line = BODY, first = INDENT, keep = keep })
    end
  end
  if out[start] and not out[start]:find('w:before="' .. SINGLE .. '"') then
    out[start] = out[start]:gsub('w:before="0"', 'w:before="' .. SINGLE .. '"', 1)
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(fallback_xml(x)) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
