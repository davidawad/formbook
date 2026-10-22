-- S.D. Cal. complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it reads
-- and breaks as typst/casd-complaint.typ does (see ../README.md): pleading paper (CivLR 5.1: 27 numbered lines of
-- 24 pt, the numbers in a page-anchored frame of the footer, the rules as page borders), the counsel block (lines
-- 1-7, Civil L.R. 3-4(a)(3)), the court title, the caption (Fed. R. Civ. P. 10(a)), the numbered allegations (Fed.
-- R. Civ. P. 10(b)), the headings, the prayer items lettered (a), (b), ..., the signature block and the footer (page
-- number, the paper's title and the case number; FORMBOOK_FOOTERS, the last section FORMBOOK_FINAL).
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered lines, 320 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 320, 320                -- typst pitch, pitch-single, gap
local DROP = 128                                       -- typst single-drop, 6.4 pt: a single group's top below a numbered line's
local LINES = 27                                       -- typst lines-per-page
local TOP, LEFT = 1440, 2160                           -- typst top-margin, left-margin
local INDENT = 720                                     -- typst para-indent and list-indent
local LABEL = 576                                      -- typst list-label, 0.4 in
local TEXTW = 8640                                     -- 6 in
local CAP_LEFT, CAP_INSET, CAP_FOOT = 4608, 200, 160   -- typst caption-left 3.2 in, caption-inset 10 pt, caption-foot 8 pt
local CAP_RIGHT = 432                                  -- typst caption-right 0.3 in
local SIG_LEFT, SIG_GUTTER = 3744, 288                 -- typst signature-left 2.6 in, signature-gutter 0.2 in
local COUNSEL = 7                                      -- typst counsel-lines
local FOOT = 20                                        -- typst footer-size 10 pt, in half points

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep, brk, frame, sz }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.frame then props[#props + 1] = o.frame end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="' .. (o.tabval or "left") .. '" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.sz then
    props[#props + 1] = '<w:rPr><w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/></w:rPr>'
  end
  return xe.para(props, body)
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }.
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

local function upper(m)
  return pandoc.text.upper(pandoc.utils.stringify(m))
end

local function list(m)
  local out = {}
  for _, v in ipairs(m or {}) do out[#out + 1] = v end
  return out
end

-- ---------------------------------------------------------------------------
-- Page furniture: the footer (the line numbers in a frame at the left margin, on the body's line boxes; the page
-- number "-N-"; the paper's title and the case number) and the last section (letter, the typst margins, the
-- pleading rules: a double rule left of the text, a single rule right of it).
-- ---------------------------------------------------------------------------

local function footer(meta)
  local out = {}
  local frame = '<w:framePr w:w="' .. (LEFT - INDENT) .. '" w:h="' .. (LINES * BODY) .. '" w:hRule="exact" ' ..
    'w:wrap="notBeside" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="' .. TOP .. '"/>'
  for i = 1, LINES do out[#out + 1] = p(xe.runs(tostring(i)), { line = BODY, jc = "right", frame = frame }) end
  local f = { sz = FOOT }
  out[#out + 1] = p(xe.runs("-", f) .. '<w:r><w:rPr><w:sz w:val="' .. FOOT .. '"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>' ..
    '<w:r><w:rPr><w:sz w:val="' .. FOOT .. '"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' ..
    '<w:r><w:rPr><w:sz w:val="' .. FOOT .. '"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r>' ..
    xe.runs("1", f) .. '<w:r><w:rPr><w:sz w:val="' .. FOOT .. '"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>' ..
    xe.runs("-", f), { line = 240, after = 80, jc = "center", sz = FOOT })
  out[#out + 1] = p(xe.runs(upper(meta.footer_title) .. "\tCASE NO. ", f) .. xe.runs(pandoc.utils.stringify(meta.case_number), f),
    { line = 240, tab = TEXTW, tabval = "right", sz = FOOT })
  return table.concat(out)
end

local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdCasdPage"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" ' ..
  'w:header="720" w:footer="760" w:gutter="0"/><w:pgBorders w:offsetFrom="text">' ..
  '<w:left w:val="double" w:sz="4" w:space="14" w:color="auto"/><w:right w:val="single" w:sz="4" w:space="7" ' ..
  'w:color="auto"/></w:pgBorders></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: counsel (lines 1-7 at least, single spaced), court title, caption
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local counsel = list(meta.counsel)
  -- the counsel lines start single-drop below the top margin (an empty paragraph of that height)
  out[#out + 1] = p("", { line = DROP })
  for _, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l)) end
  -- the court title starts on the numbered line after the counsel block (at least line 8)
  local n = math.max(COUNSEL, math.ceil((DROP + #counsel * SINGLE) / BODY))
  local title = { "UNITED STATES DISTRICT COURT", "SOUTHERN DISTRICT OF CALIFORNIA" }
  if meta.division then title[#title + 1] = upper(meta.division) end
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center",
      before = i == 1 and (n * BODY - DROP - #counsel * SINGLE) or 0, after = i == #title and BODY or 0 })
  end
  -- the party column: each party's names, then its designation; "v." between the parties
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, l in ipairs(list(party.names)) do left[#left + 1] = p(xe.inl(l)) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local right = { p(xe.runs("Case No. " .. pandoc.utils.stringify(meta.case_number))),
    p(xe.inl(meta.brief_title, { b = true }), { before = GAP }) }
  if meta.legend then right[#right + 1] = p(xe.runs(upper(meta.legend), { b = true }), { before = GAP }) end
  if meta.jury_demand then right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = GAP }) end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
      '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
      '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>',
      body = left },
    { pr = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:left w:w="' .. CAP_RIGHT .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: dated at the left; the firm and signer in the right column; the row never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(list(sig.firm)) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and GAP or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = GAP })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, {
    { pr = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/></w:tcMar>', body = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) } },
    { pr = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right },
  }, '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 1780"), as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A body paragraph at the numbered pitch: the first line indented half an inch, the number (if any) after it in a
-- box of half an inch (a tab to the inch).
local function body_par(label, inlines, o)
  o.line, o.first = BODY, INDENT
  if label == nil then return p(xe.inl(inlines), o) end
  o.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), o)
end

-- Headings, one numbered line each, kept with the text: level 1 centered bold capitals, level 2 centered bold,
-- level 3 bold italic at the margin.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

-- A list: each label half an inch in, in a box of 0.4 in, the text hanging after it; lettered (a), (b), ... under
-- the prayer.
local function items(list_el, letters, o, out)
  local n = list_el.t == "OrderedList" and list_el.listAttributes.start or 1
  for _, item in ipairs(list_el.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("casd.lua: a list item holds one paragraph")
    end
    local lab = list_el.t ~= "OrderedList" and "\u{2022}" or letters and ("(" .. string.char(96 + n) .. ")") or (n .. ".")
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = INDENT + LABEL,
      hanging = LABEL, tab = INDENT + LABEL, keep = o.keep, after = o.after })
    n = n + 1
  end
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = cover(meta)
  local first = true
  local function o()
    local x = { brk = first }
    first = false
    return x
  end
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in, o()) end
  local blocks = doc.blocks
  local unnumbered, n = false, 0
  -- the last block stays whole with the signature block, a numbered line above it
  local last_from = #blocks
  for i, b in ipairs(blocks) do
    local opts = o()
    local last = i == last_from
    if last then opts.keep, opts.after = true, nil end
    if b.t == "Header" then
      local h = upper(b.content)
      unnumbered = h:find("^PRAYER") ~= nil or h:find("^DEMAND") ~= nil
      local x = heading(b)
      if opts.brk then x = x:gsub("<w:keepNext/>", "<w:keepNext/>" .. xe.BREAK, 1) end
      out[#out + 1] = x
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local start = #out + 1
      items(b, unnumbered, opts, out)
      if opts.brk then out[start] = out[start]:gsub("<w:pPr>", "<w:pPr>" .. xe.BREAK, 1) end
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered then
        out[#out + 1] = body_par(nil, b.content, opts)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, opts)
      end
    else
      error("casd.lua: unsupported block " .. b.t)
    end
    if last then out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. BODY .. '"', 1) end
  end
  out[#out + 1] = signature(meta)
  write_file("FORMBOOK_FOOTERS", "rIdCasdPage\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", SECT)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
