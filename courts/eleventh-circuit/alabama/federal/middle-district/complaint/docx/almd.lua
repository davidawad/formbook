-- almd.lua (docx engine): the M.D. Ala. complaint as Word paragraphs and a borderless caption table, so that it
-- reads and breaks as typst/almd-complaint.typ does: the court title, the FRCP 10(a) caption, the title, the body
-- (headings and paragraphs), the FRCP 11(a) signature block and the service note. Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file. Lettered items ("a.") stay paragraphs with their
-- marker, as typst prints them (pandoc reads them as a list; commonmark does not).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 644, 322             -- typst pitch-double, pitch-single
local INDENT = 720                        -- typst para-indent, 0.5 in
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 80     -- typst cap-left 3.4 in, cap-gutter 4 pt
local CAP_PAREN = 216                     -- typst cap-paren 0.15 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function cell(w, body, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (mar or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Court title and caption (FRCP 10(a))
-- ---------------------------------------------------------------------------

local function court_title(meta, out)
  for _, line in ipairs(meta.court) do
    out[#out + 1] = p(xe.inl(line, { b = true }), { jc = "center", keep = true })
  end
end

-- Names on the left with a ")" column, the file number and the jury demand on the right. Each side is its names
-- (one row each) and its designation; a "v." row separates the sides; "Civil Action No." stands on the "v." row,
-- "JURY DEMAND" on the first defendant row.
local function caption(meta)
  local rows = {}
  local sep, defendant
  for i, side in ipairs(meta.caption.sides) do
    if i > 1 then
      sep = #rows + 1
      rows[#rows + 1] = { body = xe.runs("v."), indent = true }
      defendant = #rows + 1
    end
    for _, name in ipairs(side.names) do rows[#rows + 1] = { body = xe.inl(name) } end
    rows[#rows + 1] = { body = xe.inl(side.designation), indent = true }
  end
  local number = plain(meta.case_number)
  local trs = {}
  local first = true
  for k, r in ipairs(rows) do
    local right = ""
    if k == sep then right = xe.runs("Civil Action No." .. (number ~= "" and (" " .. number) or "")) end
    if meta.jury_demand == true and k == defendant then right = xe.runs("JURY DEMAND") end
    -- the caption stands a single line below the court title (typst: the caption block's above)
    local before = first and SINGLE or 0
    first = false
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      cell(CAP_LEFT, p(r.body, { left = r.indent and INDENT or 0, before = before })) ..
      cell(CAP_GUTTER + CAP_PAREN, p(xe.runs(")"), { before = before }),
        '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>') ..
      cell(TEXTW - CAP_LEFT - CAP_GUTTER - CAP_PAREN, p(right, { before = before })) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (CAP_GUTTER + CAP_PAREN) .. '"/>' ..
    '<w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER - CAP_PAREN) .. '"/></w:tblGrid>' ..
    table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature block (FRCP 11(a)) and service note: one block that never breaks across a page
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local lines = { { body = xe.runs("Respectfully submitted,"), before = SINGLE } }
  for _, g in ipairs(meta.signature) do
    local sig = (g.esign ~= false and xe.runs("/s/ ") or "") .. xe.inl(g.signer)
    if g.note then sig = sig .. xe.runs(" (") .. xe.inl(g.note) .. xe.runs(")") end
    lines[#lines + 1] = { body = sig, before = SINGLE }
    for _, l in ipairs(g.lines) do lines[#lines + 1] = { body = xe.inl(l) } end
  end
  for i, l in ipairs(meta.service_note or {}) do
    lines[#lines + 1] = { body = xe.inl(l), before = i == 1 and SINGLE or 0 }
  end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function roman(n, upper)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return upper and s:upper() or s
end

-- The marker of item n as typed ("a.", "iv.", "3)").
local function marker(attrs, n)
  local style, delim = tostring(attrs.style), tostring(attrs.delimiter)
  local m = tostring(n)
  if style == "LowerAlpha" then m = string.char(96 + n)
  elseif style == "UpperAlpha" then m = string.char(64 + n)
  elseif style == "LowerRoman" then m = roman(n)
  elseif style == "UpperRoman" then m = roman(n, true) end
  if delim == "OneParen" then return m .. ")" end
  if delim == "TwoParens" then return "(" .. m .. ")" end
  return m .. "."
end

-- A body paragraph at the double pitch with the half-inch first-line indent.
local function body_par(body)
  return p(body, { line = BODY, first = INDENT })
end

-- Headings at the body size and pitch, bold: levels 1 and 2 centered, level 3 at the margin; kept with the text.
local function heading(el)
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(el.content, { b = true }))
end

local function blocks(list, out)
  for _, b in ipairs(list) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(xe.inl(b.content))
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        if first == nil or (first.t ~= "Para" and first.t ~= "Plain") then
          error("almd.lua: a lettered item must start with a paragraph")
        end
        out[#out + 1] = body_par(xe.runs(marker(b.listAttributes, b.listAttributes.start + i - 1) .. " ") ..
          xe.inl(first.content))
        local rest = {}
        for j = 2, #item do rest[#rest + 1] = item[j] end
        blocks(rest, out)
      end
    elseif b.t == "BlockQuote" then
      blocks(b.content, out)
    else
      error("almd.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = {}
  court_title(meta, out)
  out[#out + 1] = caption(meta)
  -- the title stands a double line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { before = BODY, keep = true })
  blocks(doc.blocks, out)
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
