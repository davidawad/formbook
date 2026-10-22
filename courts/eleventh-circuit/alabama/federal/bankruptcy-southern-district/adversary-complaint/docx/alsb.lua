-- alsb adversary complaint, docx engine: the S.D. Ala. bankruptcy adversary complaint as Word paragraphs and tables,
-- so that it reads and breaks as typst/alsb-adversary-complaint.typ does: the court title and the Official Form 416
-- caption (a ruled party column and the case numbers), the title, the body (headings, paragraphs, the numbered
-- paragraphs on a running counter, "(1)" items as typed), the LBR 7026-1 statement, the signature block and the
-- optional certificate of service. Requirement IDs and rule text: ../README.md. No case-specific text lives here.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276             -- typst pitch-double, pitch-single
local INDENT = 720                        -- typst para-indent, 0.5 in
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT, CAP_INSET = 4896, 288     -- typst cap-left 3.4 in, cap-inset 0.2 in
local CAP_RIGHT_INSET = 432               -- typst cap-right-inset 0.3 in
local CAP_PAD = 138                       -- typst cap-pad, half a single line
local DESIG = 432                         -- typst designation-indent 0.3 in
local SIG_RIGHT = 4320                    -- typst sig-right 3.0 in

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("alsb.lua: missing required metadata field `" .. key .. "`") end
  return v
end

local function plain(m)
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function upper(x)
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep } (a hanging indent writes no firstLine).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Caption (Fed. R. Bankr. P. 7010, Fed. R. Civ. P. 10(a), Official Form 416A; Fed. R. Bankr. P. 9004(b))
-- ---------------------------------------------------------------------------

local function party(pt, before, out)
  for i, n in ipairs(pt.names) do out[#out + 1] = p(xe.inl(n), { before = i == 1 and before or 0 }) end
  out[#out + 1] = p(xe.inl(pt.designation), { left = DESIG })
end

local function caption(meta, out)
  local cap = need(meta, "caption")
  -- the caption stands a double line below the court title: the last title line takes the space after it, so the
  -- rule starts at the first party line
  local court = need(meta, "court")
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true, after = i == #court and BODY or 0 })
  end
  local left = {}
  party(cap.debtor, 0, left)
  party(cap.plaintiff, SINGLE, left)
  left[#left + 1] = p(xe.runs("v."), { before = SINGLE })
  party(cap.defendant, SINGLE, left)
  -- the rule runs half a line below the last party line (typst: the cell's bottom inset)
  local last = #left
  left[last] = left[last]:gsub('w:after="0"', 'w:after="' .. CAP_PAD .. '"', 1)
  local right = {
    p(xe.runs("Case No. " .. plain(need(meta, "case_number"))), {}),
    p(xe.runs("Chapter " .. plain(need(meta, "chapter"))), { before = SINGLE }),
    p(xe.runs("Adv. Pro. No. " .. plain(need(meta, "adversary_number"))), { before = SINGLE }),
  }
  local rule = 'w:val="single" w:sz="4" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- the title: centered bold capitals, a double line below the caption (Word has no space after a table)
  out[#out + 1] = p(xe.inl(upper(need(meta, "title")), { b = true }), { jc = "center", before = BODY, keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature block (Fed. R. Bankr. P. 9011): "Dated" at the left, counsel at the right; the row never splits
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local dated = meta.date and xe.inl(meta.date) or xe.runs("__________, 20__")
  local left = { p(xe.runs("Dated: ") .. dated, { before = BODY }) }
  local right = {
    p(xe.runs("Respectfully submitted,"), { before = BODY }),
    p(xe.runs("/s/ ") .. xe.inl(sig.signer), { before = SINGLE }),
  }
  for _, l in ipairs(sig.lines) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ TEXTW - SIG_RIGHT, SIG_RIGHT }, { { body = left }, { body = right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch with the half-inch first-line indent.
local function body_par(body, before)
  return p(body, { line = BODY, first = INDENT, before = before })
end

-- Level 1: centered bold capitals; level 2: bold at the margin; a line of the body pitch, kept with the text.
local function heading(el, before)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(before or 0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level == 1 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- The marker of a "(1)" / "(a)" item as typed (commonmark, and so typst, reads it as a paragraph).
local function marker(attrs, n)
  local style = tostring(attrs.style)
  local m = tostring(n)
  if style == "LowerAlpha" then m = string.char(96 + n)
  elseif style == "UpperAlpha" then m = string.char(64 + n)
  elseif style == "LowerRoman" or style == "UpperRoman" then
    local r = ({ "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x" })[n]
    m = style == "UpperRoman" and r:upper() or r
  end
  local delim = tostring(attrs.delimiter)
  if delim == "TwoParens" then return "(" .. m .. ")" end
  return m .. ")"
end

local function first_inlines(item, what)
  local f = item[1]
  if f == nil or (f.t ~= "Para" and f.t ~= "Plain") or #item > 1 then
    error("alsb.lua: a " .. what .. " item must be one paragraph")
  end
  return f.content
end

-- Blocks of the body or of the certificate. `st` keeps the running paragraph number and the space the next block
-- takes above it (Word has no space after a table).
local function blocks(list, out, st)
  local function take()
    local g = st.gap
    st.gap = 0
    return g
  end
  for _, b in ipairs(list) do
    if b.t == "Header" then
      out[#out + 1] = heading(b, take())
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(xe.inl(b.content), take())
    elseif b.t == "OrderedList" and tostring(b.listAttributes.delimiter):find("Paren") then
      -- "(1)" and "1)" items are paragraphs in commonmark: they print as typed, with the first-line indent
      for i, item in ipairs(b.content) do
        out[#out + 1] = body_par(xe.runs(marker(b.listAttributes, b.listAttributes.start + i - 1) .. " ") ..
          xe.inl(first_inlines(item, "lettered")), take())
      end
    elseif b.t == "OrderedList" then
      -- numbered paragraphs on a counter that runs through the complaint (Fed. R. Civ. P. 10(b))
      for _, item in ipairs(b.content) do
        st.n = st.n + 1
        out[#out + 1] = body_par(xe.runs(st.n .. ". ") .. xe.inl(first_inlines(item, "numbered")), take())
      end
    elseif b.t == "BulletList" then
      -- the bullet in a box of the paragraph indent at the margin, the text hanging after it (typst: xengine)
      for _, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs("\u{2022}\t") .. xe.inl(first_inlines(item, "bullet")),
          { line = BODY, left = INDENT, hanging = INDENT, before = take() })
      end
    else
      error("alsb.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local m = doc.meta
  local out = {}
  caption(m, out)
  local st = { n = 0, gap = SINGLE } -- the body stands a single line below the title
  blocks(doc.blocks, out, st)
  -- LBR 7026-1: the statement whether Fed. R. Civ. P. 26(a)(1) applies, a body paragraph
  out[#out + 1] = body_par(xe.inl(need(m, "stipulation-26-1")))
  out[#out + 1] = signature(m)
  local cert = m["certificate-of-service"]
  if cert then
    st.gap = BODY
    blocks(pandoc.Blocks(cert):walk({ Str = breaks }), out, st)
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
