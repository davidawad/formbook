-- D. Kan. Bankr. adversary complaint, docx engine (docs/DOCX.md): the same markdown contract as
-- typst/ksb-adversary-complaint.typ, and every block written as it sets it: the court lines, the caption (the party
-- column ruled at its right, the case column beside it; FRBP 7010, Form 416D), the title, the numbered allegations
-- (one count through the complaint, FRCP 10(b) via FRBP 7010), the unnumbered paragraphs, the headings, quotations,
-- the signature block (FRBP 9011(a)) and, on a page of their own, the exhibits after it (a pipe table). Everything
-- printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 640 the double-spaced body, 368 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 640, 368                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, number-box (0.5 in)
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT = 5184                                  -- typst caption-left, 3.6 in
local CAP_PAD, CAP_GAP = 288, 288                      -- typst caption-pad, caption-gap (0.2 in)
local DESIGNATION = 2880                               -- typst designation-indent, 2 in
local SIG = 4752                                       -- typst sig-left, 3.3 in
local CELL_X, CELL_Y = 120, 60                         -- typst cell-inset (6 pt, 3 pt)
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

-- A paragraph: o = { before, after, line, left, hanging, first, right, tabs, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tab(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("ksb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function upper(x)
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function tblpr(total)
  return '<w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>'
end

-- ---------------------------------------------------------------------------
-- Caption: a table of one row per single line, the party column ruled at its right, rows never split.
-- ---------------------------------------------------------------------------

local function caption(meta)
  local debtor = need(meta, "debtor")
  local sides = list(need(meta, "caption"))
  local left = { p(xe.runs("In re:")), p("") }
  local at_debtor = #left + 1
  for _, n in ipairs(list(debtor.names)) do left[#left + 1] = p(xe.inl(n)) end
  left[#left + 1] = p(xe.inl(debtor.designation), { left = DESIGNATION })
  local at_v
  for i, side in ipairs(sides) do
    left[#left + 1] = p("")
    if i > 1 then
      at_v = at_v or #left + 1
      left[#left + 1] = p(xe.runs("v."), { jc = "center" })
      left[#left + 1] = p("")
    end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
  end
  at_v = at_v or #left
  local right = {}
  for i = 1, #left do right[i] = p("") end
  right[at_debtor] = p(xe.inl(need(meta, "bankruptcy_case")))
  right[at_debtor + 1] = p(xe.inl(need(meta, "chapter")))
  right[at_v] = p(meta.adversary_number and xe.inl(meta.adversary_number)
    or xe.runs("Adv. Proc. No. " .. string.rep("_", 10)))
  local rows = {}
  for i = 1, #left do
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:right ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. left[i] ..
      '</w:tc><w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' ..
      CAP_GAP .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. right[i] .. '</w:tc></w:tr>'
  end
  return '<w:tbl>' .. tblpr(TEXTW) .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' ..
    (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Exhibit tables: single-spaced cells padded 6 pt and 3 pt, the header row bold, the first column twice as wide as
-- each other one; rows never split.
-- ---------------------------------------------------------------------------

local function cells_text(c, bold)
  local out = {}
  for _, b in ipairs(c.contents) do
    if b.t == "Plain" or b.t == "Para" then out[#out + 1] = xe.inl(b.content, { b = bold }) end
  end
  return table.concat(out)
end

local function pipe_table(t)
  local head = t.head.rows[1].cells
  local n = #head
  local unit = TEXTW // (n + 1)
  local widths = { TEXTW - unit * (n - 1) }
  for i = 2, n do widths[i] = unit end
  local function row(cells, bold)
    local tcs = {}
    for i, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' ..
        p(cells_text(c, bold)) .. '</w:tc>'
    end
    return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  local rows = { row(head, true) }
  for _, body in ipairs(t.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = row(r.cells, false) end
  end
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  -- indented by the cell padding, so the text starts at the margin as in typst
  local pr = tblpr(TEXTW):gsub("<w:tblLayout", '<w:tblInd w:w="' .. CELL_X .. '" w:type="dxa"/><w:tblLayout')
    :gsub('<w:tblCellMar>.-</w:tblCellMar>', '<w:tblCellMar><w:top w:w="' .. CELL_Y ..
    '" w:type="dxa"/><w:left w:w="' .. CELL_X .. '" w:type="dxa"/><w:bottom w:w="' .. CELL_Y ..
    '" w:type="dxa"/><w:right w:w="' .. CELL_X .. '" w:type="dxa"/></w:tblCellMar>')
  return '<w:tbl>' .. pr .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature: a double line below the body, the date at the left margin and "Respectfully submitted," at sig-left (a
-- hanging indent), then the firm, "By: /s/", the signer's lines and the role in bold in that column; kept whole.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local s = need(meta, "signature")
  local out = { p(xe.inl(meta.date) .. xe.runs("\tRespectfully submitted,"),
    { left = SIG, hanging = SIG, before = BODY, keep = true }) }
  local function col(body, before) out[#out + 1] = p(body, { left = SIG, before = before or 0, keep = true }) end
  for i, l in ipairs(list(s.preamble)) do col(xe.inl(l), i == 1 and SINGLE or 0) end
  col(xe.runs("By: /s/ ") .. xe.inl(s.signer), SINGLE)
  col(xe.inl(s.signer) .. (s.bar and (xe.runs(", ") .. xe.inl(s.bar)) or ""))
  for _, l in ipairs(list(s.lines)) do col(xe.inl(l)) end
  if s.role then col(xe.inl(s.role, { b = true }), SINGLE) end
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
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- The blocks of one part (before or after the signature); `n`: the allegations numbered before it; `brk`: the part
-- opens a page.
local function body(blocks, n, brk)
  local out = {}
  for k, b in ipairs(blocks) do
    local last = k == #blocks
    local first = k == 1 and brk
    if b.t == "Header" then
      local c = b.level == 1 and upper(b.content) or b.content
      local nxt = blocks[k + 1]
      out[#out + 1] = p(xe.inl(c, { b = true }), { line = BODY, jc = "center", keep = true, brk = first,
        after = nxt and nxt.t == "Table" and SINGLE or 0 })
    elseif b.t == "Table" then
      out[#out + 1] = pipe_table(b)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT, before = SINGLE, after = SINGLE,
          keep = last, brk = first })
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("ksb-adversary-complaint.lua: a numbered paragraph holds one paragraph")
        end
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(item[1].content), { line = BODY, first = INDENT,
          tabs = tab(2 * INDENT), keep = last and i == #b.content, brk = first and i == 1 })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = last, brk = first })
    elseif b.t ~= "RawBlock" then
      error("ksb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  return out, n
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtor", "bankruptcy_case", "chapter", "caption", "title", "signature" }) do
    need(meta, k)
  end
  -- the body before and after the <!--signature--> marker
  local parts, marks = { {}, {} }, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "RawBlock" and b.text:match("^%s*<!%-%-%s*signature%s*%-%->%s*$") then
      marks = marks + 1
    else
      table.insert(parts[math.min(marks + 1, 2)], b)
    end
  end
  if marks ~= 1 then error("ksb-adversary-complaint: the body must contain exactly one <!--signature--> marker", 0) end

  local out = {}
  -- the court title, a double line below it the caption, a double line below that the title
  local court = list(need(meta, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true, after = i == #court and BODY or 0 })
  end
  out[#out + 1] = caption(meta)
  out[#out + 1] = p(xe.inl(upper(need(meta, "title")), { b = true }), { jc = "center", before = BODY, after = SINGLE })
  local before, n = body(parts[1], 0, false)
  for _, x in ipairs(before) do out[#out + 1] = x end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local after = body(parts[2], n, true)
  for _, x in ipairs(after) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
