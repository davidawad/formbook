-- Complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a pleading-paper Word document on reference.docx,
-- following wawd-complaint.typ. Every block is written as OpenXML so the grid (exact 480-twip lines, the 27 numbers of
-- the header) and the caption table come out as the typst template sets them. Numbered allegations (Fed. R. Civ. P.
-- 10(b)) get their number typed, as the typst counter does; the prayer items are typed "1." "2." hanging paragraphs.

local GRID = 480      -- one numbered line (exact 24 pt)
local SINGLE = 276    -- one single-spaced line (exact 13.8 pt)

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines -> runs; flags: b (bold), i (italic)
local function runs(inl, flags)
  local out = {}
  local function run(text)
    local rpr = ""
    if flags.b then rpr = rpr .. "<w:b/><w:bCs/>" end
    if flags.i then rpr = rpr .. "<w:i/><w:iCs/>" end
    out[#out + 1] = '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or '') ..
      '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
  end
  for _, e in ipairs(inl) do
    local t = e.t
    if t == "Str" then run(e.text)
    elseif t == "Space" or t == "SoftBreak" then run(" ")
    elseif t == "LineBreak" then out[#out + 1] = '<w:r><w:br/></w:r>'
    elseif t == "RawInline" and e.format == "openxml" then out[#out + 1] = e.text
    elseif t == "Emph" then out[#out + 1] = runs(e.content, { b = flags.b, i = true })
    elseif t == "Strong" then out[#out + 1] = runs(e.content, { b = true, i = flags.i })
    elseif t == "Quoted" then
      local q = e.quotetype == "SingleQuote" and { "\u{2018}", "\u{2019}" } or { "\u{201C}", "\u{201D}" }
      run(q[1]); out[#out + 1] = runs(e.content, flags); run(q[2])
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(e.content, flags)
    else run(pandoc.utils.stringify(e)) end
  end
  return table.concat(out)
end

local function minl(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return (v[1] and v[1].content) or {} end
  if v.t == "MetaString" then return { pandoc.Str(v) } end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

-- uppercase every string, keeping the emphasis (typst upper() on a heading)
local function upper_inl(inl)
  local out = pandoc.List({})
  for _, e in ipairs(inl) do
    if e.t == "Str" then out:insert(pandoc.Str(e.text:upper()))
    elseif e.content then
      local c = upper_inl(e.content)
      local copy = e:clone()
      copy.content = c
      out:insert(copy)
    else out:insert(e) end
  end
  return out
end

-- one paragraph: style id, optional pPr children (after pStyle), inlines, run flags
local function PX(inl, sid, pre, flags)
  return '<w:p><w:pPr><w:pStyle w:val="' .. sid .. '"/>' .. (pre or '') .. '</w:pPr>' .. runs(inl, flags or {}) .. '</w:p>'
end
local function PB(inl, sid, pre) return PX(inl, sid, pre, { b = true }) end

-- an empty paragraph exactly `tw` twips high (a grid pad, or a part of a line)
local function pad(tw)
  if tw <= 0 then return '' end
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. tw .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function ceil_grid(h) return math.ceil(h / GRID) * GRID end
local function lines_of(s, cpl) return math.max(1, math.ceil((utf8.len(s) or #s) / cpl)) end

-- the caption table (typst caption(): party column 3.1 in with a right and bottom rule, 0.25 in gutter,
-- the case number, the title and the notes at right). Its row is rounded up to whole numbered lines.
local function caption_xml(meta)
  local left, lh = {}, 0
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = PX({ pandoc.Str("v.") }, "PleadingSingle")
      lh = lh + SINGLE
    end
    for _, n in ipairs(p.names or {}) do
      left[#left + 1] = PX(minl(n), "PleadingSingle")
      lh = lh + lines_of(pandoc.utils.stringify(n), 36) * SINGLE
    end
    left[#left + 1] = PX(minl(p.designation), "PleadingSingle")
    lh = lh + lines_of(pandoc.utils.stringify(p.designation), 36) * SINGLE
  end
  left[#left + 1] = pad(160)            -- the 8 pt bottom inset of the party block
  lh = lh + 160

  local case = "Case No. " .. pandoc.utils.stringify(meta.case_number or "")
  local right = { PX({ pandoc.Str(case) }, "PleadingSingle") }
  local rh = lines_of(case, 30) * SINGLE
  right[#right + 1] = pad(240); rh = rh + 240             -- half a line (v(pitch * 0.5))
  right[#right + 1] = PB(minl(meta.brief_title), "PleadingSingle")
  rh = rh + lines_of(pandoc.utils.stringify(meta.brief_title), 30) * SINGLE
  for _, note in ipairs(meta.caption_notes or {}) do
    right[#right + 1] = pad(240); rh = rh + 240
    right[#right + 1] = PB(minl(note), "PleadingSingle")
    rh = rh + lines_of(pandoc.utils.stringify(note), 30) * SINGLE
  end

  local h = ceil_grid(math.max(lh, rh))
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="8640" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="4464"/><w:gridCol w:w="360"/><w:gridCol w:w="3816"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="', tostring(h), '" w:hRule="atLeast"/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>',
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
    '<w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>', table.concat(left), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr><w:p/></w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="3816" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>',
    table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

-- the cover: line 1 (the judge's name, when given), lines 1 to 6 blank in all, court title on lines 7 to 9,
-- a blank line, the caption, a blank line
local function cover(meta)
  local out = {}
  if meta.judge then
    out[#out + 1] = PX(minl(meta.judge), "PleadingJudge")
    out[#out + 1] = pad(5 * GRID)
  else
    out[#out + 1] = pad(6 * GRID)
  end
  out[#out + 1] = PB({ pandoc.Str("UNITED STATES DISTRICT COURT") }, "PleadingTitle")
  out[#out + 1] = PB({ pandoc.Str("WESTERN DISTRICT OF WASHINGTON") }, "PleadingTitle")
  out[#out + 1] = PB(upper_inl(minl(meta.location)), "PleadingTitle")
  out[#out + 1] = pad(GRID)
  out[#out + 1] = caption_xml(meta)
  out[#out + 1] = pad(GRID)
  return table.concat(out)
end

-- the date (left), then "Respectfully submitted," the firm and the signers (right, at 3.2 in); the additional
-- counsel block follows one line later, rounded to whole numbered lines
local function signature(sig, date)
  local out = {}
  local left = PX(minl(date), "PleadingFlush")
  local right, rh = {}, 0
  right[#right + 1] = PX({ pandoc.Str("Respectfully submitted,") }, "PleadingSingle"); rh = rh + SINGLE
  right[#right + 1] = pad(240); rh = rh + 240
  if sig.firm then
    right[#right + 1] = PX(minl(sig.firm), "PleadingSingle"); rh = rh + SINGLE
    right[#right + 1] = pad(240); rh = rh + 240
  end
  for k, s in ipairs(sig.signers or {}) do
    local inl = minl(s)
    if k == 1 then
      inl = pandoc.List({ pandoc.Str("By: ") }); inl:extend(minl(s))
    end
    right[#right + 1] = PX(inl, "PleadingSingle")
    rh = rh + lines_of(pandoc.utils.stringify(s), 40) * SINGLE
  end
  local h = ceil_grid(math.max(GRID, rh + 0))
  out[#out + 1] = table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="8640" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="4032"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="', tostring(h), '" w:hRule="atLeast"/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/><w:tcMar><w:right w:w="288" w:type="dxa"/></w:tcMar></w:tcPr>', left, '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="4032" w:type="dxa"/></w:tcPr>', table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
  out[#out + 1] = pad(GRID)
  if sig.additional then
    local rows, n = {}, 0
    for _, a in ipairs(sig.additional) do rows[#rows + 1] = PX(minl(a), "PleadingSingle"); n = n + 1 end
    if sig.role then rows[#rows + 1] = PX(minl(sig.role), "PleadingSingle"); n = n + 1 end
    out[#out + 1] = table.concat(rows)
    local block = n * SINGLE
    out[#out + 1] = pad(ceil_grid(block) - block)
  end
  return table.concat(out)
end

-- a numbered or unnumbered body paragraph; the number is typed with a tab to 1 in (the typst "1." then 0.3 in)
local function body_para(b, numbered, n)
  if numbered then
    local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
    inl:extend(b.content)
    return PX(inl, "PleadingNumbered")
  end
  return PX(b.content, "PleadingBody")
end

-- a list item (the prayer): the number typed, text hanging at 0.9 in
local function list_items(b)
  local out = {}
  local start = 1
  if b.t == "OrderedList" then start = b.listAttributes.start end
  for k, item in ipairs(b.content) do
    local first = item[1]
    if #item > 1 then io.stderr:write("wawd complaint.lua: a list item has more than one block; only its first is set\n") end
    local marker = b.t == "OrderedList" and (tostring(start + k - 1) .. ".") or "\u{2022}"
    local inl = pandoc.List({ pandoc.Str(marker), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
    inl:extend(first and first.content or {})
    out[#out + 1] = PX(inl, "PleadingPrayer")
  end
  return table.concat(out)
end

function Pandoc(doc)
  local meta = doc.meta
  local out = { cover(meta) }
  local unnumbered, n = false, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = pandoc.utils.stringify(b.content)
      unnumbered = text:find("PRAYER FOR RELIEF", 1, true) ~= nil or text:find("DEMAND FOR JURY TRIAL", 1, true) ~= nil
      local sid = "Heading" .. math.min(b.level, 3)
      local inl = b.level == 1 and upper_inl(b.content) or b.content
      out[#out + 1] = PX(inl, sid)
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered then
        out[#out + 1] = body_para(b, false)
      else
        n = n + 1
        out[#out + 1] = body_para(b, true, n)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      out[#out + 1] = list_items(b)
    else
      io.stderr:write("wawd complaint.lua: unsupported block " .. b.t .. "; set as text\n")
      out[#out + 1] = PX({ pandoc.Str(pandoc.utils.stringify(b)) }, "PleadingBody")
    end
  end
  out[#out + 1] = signature(meta.signature, meta.signature.date)
  out[#out + 1] = pad(GRID)
  doc.blocks = { pandoc.RawBlock("openxml", table.concat(out)) }
  return doc
end
