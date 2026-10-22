-- Pandoc Lua filter for the rib adversary complaint (docx engine). The same form as typst/rib-adversary-complaint.typ
-- and the same contract: every case-specific string comes from the sample (its YAML frontmatter and body). The court
-- title, the caption table, the title, the lead-in, the body and the signature block are WordprocessingML written
-- here, so that it reads and breaks as typst does. The body is split into blocks at blank lines as the typst template
-- splits it ("#" a heading, "1." a list lettered (a), (b), ..., ">" a quotation, "WHEREFORE" an unnumbered paragraph,
-- anything else a paragraph numbered 1, 2, ...), each read as commonmark (the reader of typst's cmarker).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local COURT = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF RHODE ISLAND" }
local BODY, SINGLE = 480, 276             -- typst pitch-double, pitch-single
local GAP, HALF = 276, 138                -- typst gap, half-gap
local INDENT = 720                        -- typst para-indent, 0.5 in
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT = 4752                     -- typst caption-left, 3.3 in
local CAP_PAD, CAP_FOOT = 155, 145        -- typst caption-pad 10 pt, caption-foot 8 pt, less what LibreOffice adds for the rule
local CAP_RIGHT = 504                     -- typst caption-right, 0.35 in
local LABEL = 576                         -- typst label-box, 0.4 in
local ITEM = 864                          -- typst item-box, 0.6 in
local QUOTE_L, QUOTE_R = 1080, 720        -- typst quote-left 0.75 in, quote-right 0.5 in
local QUOTE = 240                         -- typst pitch-double / 2 around a quotation
local SIG = 4320                          -- typst sig-col, 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- a meta list (or a single value) as a Lua array
local function list(v)
  if v == nil then return {} end
  if type(v) == "table" and v[1] ~= nil and v[1].t == nil then return v end
  if pandoc.utils.type(v) == "List" then return v end
  return { v }
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tab_at(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

local TAB = "<w:r><w:tab/></w:r>"

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 157"; typst binds it too; xe.inl binds a single sign).
local function bind_doubled(l)
  for i = 1, #l - 1 do
    local a = l[i]
    if a.t == "Str" and l[i + 1].t == "Space" and #a.text >= 4 and a.text:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A markdown string read as typst's cmarker reads it.
local function read(md)
  return pandoc.read(md, "commonmark+smart").blocks:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
end

local function inlines(md)
  local b = read(md)[1]
  return b and b.content or pandoc.Inlines({})
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

-- The caption: the bankruptcy case (In re) above, the adversary parties below, in a column ruled on the right and at
-- the foot; the chapter and case numbers on the right.
local function caption(meta)
  local left = { p(xe.runs("IN RE:")) }
  for i, n in ipairs(list(meta.in_re)) do left[#left + 1] = p(xe.inl(n), { before = i == 1 and HALF or 0 }) end
  left[#left + 1] = p(xe.inl(meta.debtor_designation), { jc = "right" })
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for i, n in ipairs(list(party.names)) do
      left[#left + 1] = p(xe.inl(n), { before = (k == 1 and i == 1) and GAP or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local right = {
    p(xe.runs("Chapter ") .. xe.inl(meta.chapter)),
    p(xe.runs("Bankruptcy Case No. ") .. xe.inl(meta.case_number)),
    p(xe.runs("Adversary Proceeding No. ") .. xe.inl(meta.adversary_number), { before = HALF }),
  }
  local lw, rw = CAP_LEFT, TEXTW - CAP_LEFT
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. lw .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. lw .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE ..
    '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. rw .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_RIGHT ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

local function cover(meta, out)
  for i, l in ipairs(COURT) do
    -- the caption stands a double line below the court title (typst: the caption block's above)
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true, after = i == #COURT and BODY or 0 })
  end
  out[#out + 1] = caption(meta)
  -- Word has no space after a table: the title takes it
  out[#out + 1] = p(xe.inl(upper(meta.title), { b = true }), { jc = "center", before = BODY, after = SINGLE, keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature block: the case line (LBR 1005-1(a)), the date beside "Respectfully submitted,", the signature
-- column; every line kept with the next, so the block never splits across pages.
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = {}
  local function add(body, before, left, tabs) lines[#lines + 1] = { body = body, before = before or 0, left = left or SIG, tabs = tabs } end
  local names = {}
  for _, n in ipairs(list(meta.in_re)) do names[#names + 1] = plain(n) end
  add(xe.runs("In re " .. table.concat(names, ", ") .. ", Debtor; Chapter " .. plain(meta.chapter) ..
    "; Bankruptcy Case No. " .. plain(meta.case_number) .. "; Adversary Proceeding No. " .. plain(meta.adversary_number)),
    SINGLE, 0)
  local dated = meta.date and (xe.runs("Dated: ") .. xe.inl(meta.date)) or ""
  add(dated .. TAB .. xe.runs("Respectfully submitted,"), GAP, 0, tab_at(SIG))
  add(xe.inl(sig.client), GAP)
  add(xe.inl(sig.by))
  add(xe.runs("/s/ ") .. xe.inl(sig.signer), GAP)
  add(xe.inl(sig.signer))
  for _, l in ipairs(list(sig.firm)) do add(xe.inl(l)) end
  add(xe.runs("RI Bar No. ") .. xe.inl(sig.bar_id))
  for _, l in ipairs(list(sig.lines)) do add(xe.inl(l)) end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, left = l.left, tabs = l.tabs, keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- The body, block by block as the typst template splits it
-- ---------------------------------------------------------------------------

local function chunks(src)
  src = src:gsub("\r", "")
  src = src:gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  src = src:gsub("^%s+", ""):gsub("%s+$", "")
  local out, pos = {}, 1
  while true do
    local s, e = src:find("\n[ \t]*\n", pos)
    local c = src:sub(pos, s and s - 1 or #src):gsub("^%s+", ""):gsub("%s+$", "")
    if c ~= "" then out[#out + 1] = c end
    if not s then break end
    pos = e + 1
  end
  return out
end

local function body(src, out)
  local n = 0
  for _, t in ipairs(chunks(src)) do
    if t:sub(1, 1) == "#" then
      local hashes, rest = t:match("^(#+)%s*(.-)%s*#*$")
      local lvl = #hashes
      local txt = inlines(rest)
      if lvl == 1 then txt = upper(txt) end
      out[#out + 1] = xe.para({ xe.style("Heading" .. math.min(lvl, 3)), xe.KEEP, xe.spacing(0, 0, BODY),
        xe.ind(0, nil, 0), xe.jc("center") }, xe.inl(txt, { b = true, i = lvl >= 3 }))
    elseif t:match("^%d+%.[ \t]") then
      -- a list lettered (a), (b), ...: the letter in a box after the paragraph indent, the text hanging after it
      local items, i = {}, 0
      for line in (t .. "\n"):gmatch("(.-)\n") do
        if line:match("^%d+%.[ \t]") then items[#items + 1] = line:gsub("^%d+%.[ \t]+", "")
        else items[#items] = items[#items] .. "\n" .. line end
      end
      for _, item in ipairs(items) do
        i = i + 1
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + i) .. ")") .. TAB .. xe.inl(inlines(item)),
          { line = BODY, left = INDENT + ITEM, hanging = ITEM, tabs = tab_at(INDENT + ITEM) })
      end
    elseif t:sub(1, 1) == ">" then
      -- a quotation: single-spaced, indented on both sides, half a double line off the text
      local paras = read(t)[1].content
      for i, b in ipairs(paras) do
        out[#out + 1] = p(xe.inl(b.content), { left = QUOTE_L, right = QUOTE_R, before = i == 1 and QUOTE or GAP,
          after = i == #paras and QUOTE or 0 })
      end
    elseif t:match("^WHEREFORE") then
      out[#out + 1] = p(xe.inl(inlines(t)), { line = BODY, first = INDENT })
    else
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".") .. TAB .. xe.inl(inlines(t)),
        { line = BODY, first = INDENT, tabs = tab_at(INDENT + LABEL) })
    end
  end
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local f = io.open(PANDOC_STATE.input_files[1], "r")
  local src = f:read("a")
  f:close()
  local out = {}
  cover(meta, out)
  for _, l in ipairs(list(meta.lead_in)) do out[#out + 1] = p(xe.inl(l), { line = BODY, first = INDENT }) end
  body(src, out)
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- emptied metadata: pandoc would otherwise print the frontmatter title as a Title paragraph above the caption
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
