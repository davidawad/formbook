-- Motion to dismiss with memorandum, DOCX engine (docs/DOCX.md): the markdown contract -> a pleading-paper Word
-- document on reference.docx, following wawd-motion-brief.typ. Every block is written as OpenXML so the grid (exact
-- 480-twip lines matching the 27 numbers of the header) and the caption table come out as the typst template sets them.
-- The table of contents is a two-column table (entry, page); the sections named in the frontmatter (page_breaks) start
-- a new page; the word-count certificate and the certificate of service follow the signature (LCR 7(e)(6)).
-- The page numbers in the table of contents are the author's (typed, as in the typst template), not computed.

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
      local copy = e:clone()
      copy.content = upper_inl(e.content)
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

-- the caption table (typst caption(): party column 3.1 in with a right and bottom rule, 0.25 in gutter, the case
-- number, title and notes at right). Its row is rounded up to whole numbered lines.
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

-- the date (left), then "Respectfully submitted," the firm (when the sample gives one) and the signers (right, at
-- 3.2 in); the additional counsel block follows one line later, rounded to whole numbered lines
local function signature(sig)
  local out = {}
  local left = PX(minl(sig.date), "PleadingFlush")
  local right, rh = {}, 0
  right[#right + 1] = PX({ pandoc.Str("Respectfully submitted,") }, "PleadingSingle"); rh = rh + SINGLE
  right[#right + 1] = pad(240); rh = rh + 240
  if sig.firm and pandoc.utils.stringify(sig.firm) ~= "" then
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
  local h = ceil_grid(math.max(GRID, rh))
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

-- the table of contents (or authorities): rows of (entry, page). The entry is indented by its level ("I. " at 0.5 in,
-- "A. " at 1 in); the header row prints "Page" at the right. Each row is one single-spaced entry with 12 pt after.
local function cell_inl(cell)
  local out = pandoc.List({})
  for _, blk in ipairs(cell.contents) do
    if blk.content then out:extend(blk.content) end
  end
  return out
end

local function toc_xml(tbl)
  local rows = {}
  local function all_rows()
    local list = {}
    for _, r in ipairs(tbl.head.rows) do list[#list + 1] = r end
    for _, body in ipairs(tbl.bodies) do
      for _, r in ipairs(body.body) do list[#list + 1] = r end
    end
    return list
  end
  for _, r in ipairs(all_rows()) do
    local entry = cell_inl(r.cells[1])
    local page = pandoc.utils.stringify(r.cells[2] and cell_inl(r.cells[2]) or {})
    local etext = pandoc.utils.stringify(entry)
    local ind = ""
    if etext:match("^I+V?%. ") or etext:match("^V%. ") then
      ind = '<w:ind w:left="720"/>'
    elseif etext:match("^[A-Z]%. ") then
      ind = '<w:ind w:left="1440"/>'
    end
    local header = etext == "" and page == "Page"
    local entry_xml = header and PB({}, "PleadingToc") or PX(entry, "PleadingToc", ind)
    local page_xml = header and PB({ pandoc.Str("Page") }, "PleadingTocPage") or PX({ pandoc.Str(page) }, "PleadingTocPage")
    rows[#rows + 1] = table.concat({
      '<w:tr><w:trPr><w:cantSplit/></w:trPr>',
      '<w:tc><w:tcPr><w:tcW w:w="7632" w:type="dxa"/></w:tcPr>', entry_xml, '</w:tc>',
      '<w:tc><w:tcPr><w:tcW w:w="144" w:type="dxa"/></w:tcPr>', PX({}, "PleadingToc"), '</w:tc>',
      '<w:tc><w:tcPr><w:tcW w:w="864" w:type="dxa"/></w:tcPr>', page_xml, '</w:tc>',
      '</w:tr>',
    })
  end
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="8640" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="7632"/><w:gridCol w:w="144"/><w:gridCol w:w="864"/></w:tblGrid>',
    table.concat(rows),
    '</w:tbl>',
  })
end

-- LCR 7(e)(6): the signer certifies the word count of the memorandum (form language of wawd-motion-brief.typ)
local function word_certificate(meta)
  return PX({ pandoc.Str("The undersigned certifies that this memorandum contains " .. pandoc.utils.stringify(meta.word_count) ..
    " words, excluding captions, tables of contents, tables of authorities, signature blocks, required marginal text (e.g., title information and page numbers), or certificates of service, in compliance with the applicable Local Civil Rules, specifically LCR 7(d)(4) and LCR 7(e)(6).") }, "PleadingBody")
end

-- the certificate of service: its own page, the heading starts the page; the signer's line at 3.2 in
local function certificate(c)
  local out = {}
  out[#out + 1] = PX({ pandoc.Str("CERTIFICATE OF SERVICE") }, "PleadingCertHeading", '<w:pageBreakBefore/>')
  out[#out + 1] = PX({ pandoc.Str("I certify that on " .. pandoc.utils.stringify(c.date) ..
    ", a true and correct copy of the foregoing document was electronically filed with the Court's ECF system to be sent via the electronic notification system to all counsel of record in the above-captioned matter.") }, "PleadingBody")
  out[#out + 1] = PX({ pandoc.Str("By: " .. pandoc.utils.stringify(c.signer)) }, "PleadingSigRight")
  out[#out + 1] = pad(GRID - SINGLE)
  return table.concat(out)
end

-- a body paragraph (indented first line) or a list item (the number typed, text hanging at 0.9 in)
local function list_items(b)
  local out = {}
  local start = 1
  if b.t == "OrderedList" then start = b.listAttributes.start end
  for k, item in ipairs(b.content) do
    local first = item[1]
    if #item > 1 then io.stderr:write("wawd motion-brief.lua: a list item has more than one block; only its first is set\n") end
    local marker = b.t == "OrderedList" and (tostring(start + k - 1) .. ".") or "\u{2022}"
    local inl = pandoc.List({ pandoc.Str(marker), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
    inl:extend(first and first.content or {})
    out[#out + 1] = PX(inl, "PleadingPrayer")
  end
  return table.concat(out)
end

function Pandoc(doc)
  local meta = doc.meta
  local breaks = {}
  for _, s in ipairs(meta.page_breaks or {}) do breaks[#breaks + 1] = pandoc.utils.stringify(s) end
  local out = { cover(meta) }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = pandoc.utils.stringify(b.content)
      local pre = nil
      for _, s in ipairs(breaks) do
        if text:find(s, 1, true) then pre = '<w:pageBreakBefore/>' end
      end
      local sid = "Heading" .. math.min(b.level, 3)
      local inl = b.level == 1 and upper_inl(b.content) or b.content
      out[#out + 1] = PX(inl, sid, pre)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = PX(b.content, "PleadingBody")
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      out[#out + 1] = list_items(b)
    elseif b.t == "Table" then
      out[#out + 1] = toc_xml(b)
      out[#out + 1] = pad(GRID)
    else
      io.stderr:write("wawd motion-brief.lua: unsupported block " .. b.t .. "; set as text\n")
      out[#out + 1] = PX({ pandoc.Str(pandoc.utils.stringify(b)) }, "PleadingBody")
    end
  end
  out[#out + 1] = word_certificate(meta)
  out[#out + 1] = signature(meta.signature)
  out[#out + 1] = pad(GRID)
  if meta.certificate_of_service then
    out[#out + 1] = certificate(meta.certificate_of_service)
  end
  doc.blocks = { pandoc.RawBlock("openxml", table.concat(out)) }
  return doc
end
