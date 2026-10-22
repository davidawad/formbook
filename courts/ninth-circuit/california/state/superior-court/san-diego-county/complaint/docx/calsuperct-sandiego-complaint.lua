-- San Diego County Superior Court (calsuperct-sandiego), civil complaint, docx engine (docs/DOCX.md): the complaint
-- as Word paragraphs, so that it reads and breaks as typst/calsuperct-sandiego-complaint.typ does: pleading paper
-- (CRC 2.108: 28 numbered lines of 24 pt, the numbers in a page-anchored frame of the footer, the rules as page
-- borders), the attorney block on lines 1-7 with the fee-exemption label at the top right (CRC 2.111(1), (2); SD
-- Local Rule 2.1.2(H)), the court title (CRC 2.111(3)), the caption (CRC 2.111(4)-(10)), the body, the jury demand
-- and the signature block, and the footer (CRC 2.109, 2.110: a rule, the page number, the paper's title in 10 pt;
-- FORMBOOK_FOOTERS, the last section FORMBOOK_FINAL). Every case-specific word comes from the sample's frontmatter
-- (read as written, $FORMBOOK_META: pandoc's metadata drops a caption line's leading spaces) and body, never from
-- this file.
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; a chunk that starts with "#" is a heading), each chunk by pandoc alone as cmarker reads it (no "b)" lists).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered lines, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 240, 240   -- typst pitch, pitch-single, gap
local DROP = 192                          -- typst single-drop, 9.6 pt: a single group's top below a numbered line's
local LINES = 28                          -- typst lines-per-page
local TOP, LEFT = 1440, 2160              -- typst top-margin, left-margin
local TEXTW = 9360                        -- 6.5 in
local INDENT = 720                        -- typst para-indent
local CLERK = 7                           -- typst clerk-lines
local FEE_W = 3312                        -- typst fee-width, 2.3 in
local CAP_LEFT, CAP_INSET, CAP_FOOT = 5184, 180, 180   -- typst caption-left 3.6 in, caption-inset 9 pt, caption-foot 9 pt
local CAP_RIGHT = 288                     -- typst caption-right, 0.2 in
local SPACE = 60                          -- typst space-indent, 3 pt
local SIG_LEFT, SIGNER = 4464, 432        -- typst signature-left 3.1 in, signer-indent 0.3 in
local SIG_RULE = 3888                     -- typst signature-rule, 2.7 in
local FOOT = 20                           -- typst footer-size 10 pt, in half points

local function read_file(path)
  if path == nil or path == "" then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(t, key)
  if t == nil or t[key] == nil then error("calsuperct-sandiego-complaint: missing required metadata field `" .. key .. "`") end
  return t[key]
end

local function list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 17200"; typst boxes "[§¶] \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "b)" or "A." lists).
local function md(s)
  local doc = pandoc.read(tostring(s), "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return bind_doubled(pandoc.Inlines(pandoc.utils.blocks_to_inlines(doc.blocks)):walk({ Str = breaks }))
end

local function upper(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { style, before, after, line, left, right, first, hanging, jc, keep, lines, tab, tabval, frame,
-- border, sz }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.frame then props[#props + 1] = o.frame end
  if o.border then props[#props + 1] = o.border end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="' .. (o.tabval or "left") .. '" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.sz then
    props[#props + 1] = '<w:rPr><w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/></w:rPr>'
  end
  return xe.para(props, body or "")
end

-- typst line-stack(): one single line per item; an empty item an empty line; each leading space a quarter em in.
local function line_stack(items, o)
  o = o or {}
  local out = {}
  for i, it in ipairs(list(items)) do
    local sp, t = tostring(it):match("^( *)(.*)$")
    local before = i == 1 and (o.before or 0) or 0
    out[#out + 1] = p(t == "" and "" or xe.inl(md(t), { b = o.b }), { before = before, left = (o.left or 0) + #sp * SPACE,
      jc = o.jc, keep = o.keep })
  end
  return out
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    local body = #cells[i].body > 0 and table.concat(cells[i].body) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function top_cell(w, body)
  return { pr = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/></w:tcMar>', body = body }
end

-- ---------------------------------------------------------------------------
-- Page furniture: the footer (the line numbers in a frame at the left margin, on the body's line boxes; a rule, the
-- page number, the paper's title in 10 pt) and the last section (letter, the typst margins, the pleading rules: a
-- double rule left of the text, a single rule right of it).
-- ---------------------------------------------------------------------------

local function footer()
  local out = {}
  local frame = '<w:framePr w:w="' .. (LEFT - INDENT) .. '" w:h="' .. (LINES * BODY) .. '" w:hRule="exact" ' ..
    'w:wrap="notBeside" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="' .. TOP .. '"/>'
  for i = 1, LINES do out[#out + 1] = p(xe.runs(tostring(i)), { line = BODY, jc = "right", frame = frame }) end
  local fld = function(x) return '<w:r>' .. x .. '</w:r>' end
  out[#out + 1] = p(fld('<w:fldChar w:fldCharType="begin"/>') .. fld('<w:instrText xml:space="preserve"> PAGE </w:instrText>') ..
    fld('<w:fldChar w:fldCharType="separate"/>') .. xe.runs("1") .. fld('<w:fldChar w:fldCharType="end"/>'),
    { jc = "center", border = '<w:pBdr><w:top w:val="single" w:sz="4" w:space="2" w:color="000000"/></w:pBdr>' })
  out[#out + 1] = p(xe.runs(tostring(need(RAW, "footer_title")), { sz = FOOT }), { jc = "center", sz = FOOT })
  return table.concat(out)
end

local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdSdPage"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="720" w:bottom="960" w:left="2160" ' ..
  'w:header="720" w:footer="360" w:gutter="0"/><w:pgBorders w:offsetFrom="text">' ..
  '<w:left w:val="double" w:sz="4" w:space="12" w:color="auto"/><w:right w:val="single" w:sz="4" w:space="7" ' ..
  'w:color="auto"/></w:pgBorders></w:sectPr>'

-- ---------------------------------------------------------------------------
-- First page: attorney block (lines 1-7 at least), fee label at the top right, court title, caption
-- ---------------------------------------------------------------------------

local function first_page(out)
  local att, fee = list(need(RAW, "attorney")), list(RAW.fee_exempt)
  local n = math.max(CLERK, math.ceil((DROP + math.max(#att, #fee) * SINGLE) / BODY))
  local row = '<w:trPr><w:cantSplit/><w:trHeight w:val="' .. (n * BODY) .. '" w:hRule="exact"/></w:trPr>'
  if #fee > 0 then
    out[#out + 1] = tbl({ TEXTW - FEE_W, FEE_W }, { top_cell(TEXTW - FEE_W, line_stack(att)),
      top_cell(FEE_W, line_stack(fee, { jc = "right" })) }, row)
  else
    out[#out + 1] = tbl({ TEXTW }, { top_cell(TEXTW, line_stack(att)) }, row)
  end
  local court = list(need(RAW, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(md(l), { b = true }), { line = BODY, jc = "center", after = i == #court and BODY or 0 })
  end
  -- the caption: the party column ruled at its right and foot, the case column beside it
  local cap = need(RAW, "caption")
  local right, above = {}, 0
  local function add(ps) for _, x in ipairs(ps) do right[#right + 1] = x end end
  if cap.case_number then add(line_stack({ cap.case_number })); above = GAP end
  if cap.limited_civil == true then add(line_stack({ "LIMITED CIVIL CASE" }, { before = above })); above = GAP end
  add(line_stack(need(cap, "title"), { before = above, b = true }))
  if cap.details then add(line_stack(cap.details, { before = GAP })) end
  local jd = {}
  if cap.dept then jd[#jd + 1] = "Dept.: " .. tostring(cap.dept) end
  if cap.judge then jd[#jd + 1] = "Judge: " .. tostring(cap.judge) end
  if #jd > 0 then add(line_stack(jd, { before = GAP })) end
  if cap.amount_demanded then add(line_stack({ cap.amount_demanded }, { before = GAP })) end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
      '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
      '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>',
      body = line_stack(need(cap, "left")) },
    { pr = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:left w:w="' .. CAP_RIGHT .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
end

-- ---------------------------------------------------------------------------
-- Signature block: a numbered line below the text; the date at the left, the signature column; kept together.
-- ---------------------------------------------------------------------------

local function signature(out)
  local sig = need(RAW, "signature")
  local first = BODY + DROP
  local function take()
    local b = first
    first = 0
    return b
  end
  if sig.dated then out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(md(sig.dated)), { before = take(), keep = true }) end
  for _, l in ipairs(list(sig.lines)) do
    out[#out + 1] = p(xe.inl(md(l)), { before = take(), left = SIG_LEFT, keep = true })
  end
  -- "By:", then the signature line (an underlined tab) to its end
  out[#out + 1] = p(xe.runs("By: ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    { before = math.max(take(), BODY), left = SIG_LEFT, keep = true, tab = SIG_LEFT + 406 + SIG_RULE })
  local role = sig.role
  out[#out + 1] = p(xe.inl(md(pandoc.text.upper(tostring(need(sig, "signer")))), { b = true }),
    { left = SIG_LEFT + SIGNER, keep = role ~= nil })
  if role then out[#out + 1] = p(xe.inl(md(role)), { left = SIG_LEFT + SIGNER }) end
end

-- ---------------------------------------------------------------------------
-- The body: the chunks of typst's body-pieces()
-- ---------------------------------------------------------------------------

local function chunks()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out
end

local function body(out)
  local cs = chunks()
  for i, t in ipairs(cs) do
    local o = { line = BODY, before = i == 1 and BODY or 0, keep = i == #cs }
    local hashes, htext = t:match("^(#+)[ \t]+(.-)[ \t#]*$")
    if hashes then
      -- one numbered line: levels 1 and 2 centered bold capitals, 3 bold, 4 bold italic; kept with the next chunk
      local lvl = #hashes
      local inl = md(htext)
      if lvl <= 2 then inl = upper(inl) end
      o.style, o.keep, o.jc = "Heading" .. math.min(lvl, 4), true, lvl <= 2 and "center" or "left"
      out[#out + 1] = p(xe.inl(inl, { b = true, i = lvl >= 4 }), o)
    else
      o.first = INDENT
      out[#out + 1] = p(xe.inl(md(t)), o)
    end
  end
end

function Pandoc(doc)
  local out = {}
  first_page(out)
  body(out)
  if RAW.jury_demand then
    out[#out + 1] = p(xe.runs(pandoc.text.upper(tostring(RAW.jury_demand)), { b = true }),
      { line = BODY, before = BODY, jc = "center", keep = true })
  end
  signature(out)
  write_file("FORMBOOK_FOOTERS", "rIdSdPage\t" .. footer() .. "\n")
  write_file("FORMBOOK_FINAL", SECT)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
