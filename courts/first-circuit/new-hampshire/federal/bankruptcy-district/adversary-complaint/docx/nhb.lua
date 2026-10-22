-- nhb (D.N.H. bankruptcy court) adversary complaint, DOCX engine (docs/DOCX.md): the court title, the bankruptcy
-- caption, the adversary caption, the title, the numbered body and the signature block, written as WordprocessingML
-- so that it reads and breaks as typst/nhb-adversary-complaint.typ does. This file holds no case text: every word
-- comes from the sample (its YAML frontmatter and body). The body is split into blocks at blank lines as the typst
-- template splits it ("#" a section heading, "##" a sub-heading, "(A) " a sub-item, every other block a paragraph,
-- numbered 1, 2, ... per Fed. R. Civ. P. 10(b) unless its section is listed in `unnumbered` or it starts with
-- "WHEREFORE"), each read as commonmark (the reader of typst's cmarker).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276             -- typst pitch-double, pitch-single
local CAP_GAP = 240                       -- typst cap-gap, 12 pt
local HEAD_ABOVE = 120                    -- typst head-above, 6 pt
local INDENT = 720                        -- typst para-indent, 0.5 in
local SUB = 1440                          -- typst sub-indent, 1 in
local SIG = 4680                          -- typst sig-indent, 3.25 in
local TEXTW = 9360                        -- 6.5 in
local COL = TEXTW / 2                     -- typst caption-grid: two equal columns
local ADV_BLANK = 3240                    -- typst adv-blank, 2.25 in
local RULE = 'w:val="single" w:sz="4" w:space="0" w:color="000000"'   -- typst rule, 0.5 pt

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A metadata list (or a single value) as an array.
local function list(v)
  if v == nil then return {} end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" or ty == "Blocks" or ty == "string" then return { v } end
  return v
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A section sign or pilcrow stays with its number when it is doubled ("§§ 544") or follows other characters ("“§
-- 547"), as the typst template boxes it (xe.inl binds a sign that stands alone only).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" and (a.text:find("\u{00A7}$") or a.text:find("\u{00B6}$")) then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A markdown string read as typst's cmarker reads it, as inlines.
local function inlines(md)
  local b = pandoc.read(md, "commonmark+smart").blocks:walk({ Str = breaks }):walk({ Inlines = signs })[1]
  return b and b.content or pandoc.Inlines({})
end

-- ---------------------------------------------------------------------------
-- Captions (Fed. R. Bankr. P. 7010, Official Form 416D; 9004(b); LBR 9004-1(a), (b))
-- ---------------------------------------------------------------------------

local function margins(t, l, b, r)
  return '<w:tcMar><w:top w:w="' .. t .. '" w:type="dxa"/><w:left w:w="' .. l .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. b .. '" w:type="dxa"/><w:right w:w="' .. r .. '" w:type="dxa"/></w:tcMar>'
end

-- Two equal columns; the left one ruled at its right and foot, its text 10 pt off the rule and 8 pt above the
-- foot (typst inset), the right one 18 pt off the rule; both 2 pt from the top.
local function caption_table(left, right)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. COL .. '"/><w:gridCol w:w="' .. COL .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. COL .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE ..
    '/></w:tcBorders>' .. margins(40, 0, 160, 200) .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. COL .. '" w:type="dxa"/>' .. margins(40, 360, 0, 0) .. '</w:tcPr>' ..
    table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

local function bankruptcy_caption(b)
  return caption_table({
    p(xe.runs("In re:")),
    p(xe.inl(b.debtor, { b = true }), { before = CAP_GAP }),
    p(xe.inl(b.designation), { before = CAP_GAP, jc = "right" }),
  }, {
    p(xe.inl(b.chapter)),
    p(xe.runs("Case No. ") .. xe.inl(b.case_number), { before = CAP_GAP }),
  })
end

local function adversary_caption(a)
  local left = {}
  for i, party in ipairs(list(a.parties)) do
    if i > 1 then left[#left + 1] = p(xe.runs("v."), { before = CAP_GAP }) end
    for k, n in ipairs(list(party.names)) do
      left[#left + 1] = p(xe.inl(n, { b = true }), { before = (i > 1 and k == 1) and CAP_GAP or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { before = CAP_GAP, jc = "right" })
  end
  local right
  if plain(a.number) == "" then
    -- the clerk's blank: an underlined tab to adv-blank
    right = p(xe.runs("Adv. Pro. No. ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
      { tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. ADV_BLANK .. '"/></w:tabs>' })
  else
    right = p(xe.runs("Adv. Pro. No. ") .. xe.inl(a.number))
  end
  return caption_table(left, { right })
end

-- ---------------------------------------------------------------------------
-- Signature block: the date at the margin, the rest at the signature indent; every line kept with the next, so
-- the block never splits (typst: one unbreakable block).
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local s = meta.signature
  local label = plain(meta.date_label) ~= "" and plain(meta.date_label) or "Date:"
  local lines = { { body = xe.runs(label .. " ") .. xe.inl(meta.date), before = CAP_GAP, left = 0 } }
  for i, l in ipairs(list(s.intro)) do lines[#lines + 1] = { body = xe.inl(l), before = i == 1 and CAP_GAP or 0 } end
  lines[#lines + 1] = { body = xe.inl(s.signer), before = 2 * CAP_GAP }
  for i, l in ipairs(list(s.lines)) do lines[#lines + 1] = { body = xe.inl(l), before = i == 1 and CAP_GAP or 0 } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, left = l.left or SIG, keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- The body, block by block as the typst template splits it
-- ---------------------------------------------------------------------------

local function body(src, unnumbered, out)
  src = src:gsub("\r", "")
  src = src:gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local chunks = {}
  local pos = 1
  while true do
    local s, e = src:find("\n[ \t]*\n", pos)
    local c = src:sub(pos, s and s - 1 or #src):gsub("^%s+", ""):gsub("%s+$", "")
    if c ~= "" then chunks[#chunks + 1] = c end
    if not s then break end
    pos = e + 1
  end
  local n, numbered = 0, true
  for i, c in ipairs(chunks) do
    local last = i == #chunks
    if c:sub(1, 3) == "## " then
      out[#out + 1] = p(xe.inl(inlines(c:sub(4)), { b = true }), { line = BODY, jc = "center", keep = true })
    elseif c:sub(1, 2) == "# " then
      local h = c:sub(3):gsub("%s+$", "")
      numbered = not unnumbered[h]
      out[#out + 1] = p(xe.inl(inlines(h), { b = true }), { before = HEAD_ABOVE, line = BODY, jc = "center", keep = true })
    elseif c:match("^%([A-Z]%) ") then
      out[#out + 1] = p(xe.inl(inlines(c)), { line = BODY, left = SUB, keep = last })
    elseif numbered and not c:match("^WHEREFORE") then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ". ") .. xe.inl(inlines(c)), { line = BODY, first = INDENT, keep = last })
    else
      out[#out + 1] = p(xe.inl(inlines(c)), { line = BODY, first = INDENT, keep = last })
    end
  end
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local m = doc.meta
  local f = io.open(PANDOC_STATE.input_files[1], "r")
  local src = f:read("a")
  f:close()
  local out = {}
  -- court title, centered bold, one line per entry; the caption stands 18 pt below
  local court = list(m.court)
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", keep = true, after = i == #court and 360 or 0 })
  end
  out[#out + 1] = bankruptcy_caption(m.bankruptcy)
  if m.adversary then
    -- 10 pt between the two captions (typst: the adversary caption's above); Word joins two adjacent tables
    out[#out + 1] = p("", { line = 200 })
    out[#out + 1] = adversary_caption(m.adversary)
  end
  -- the title 18 pt below the caption (Word has no space after a table: the title takes it), 12 pt above the body
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { before = 360, after = 240, jc = "center", keep = true })
  local unnumbered = {}
  for _, h in ipairs(list(m.unnumbered)) do unnumbered[plain(h)] = true end
  body(src, unnumbered, out)
  signature(m, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- emptied metadata: pandoc would otherwise print the frontmatter title as a Title paragraph above the caption
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
