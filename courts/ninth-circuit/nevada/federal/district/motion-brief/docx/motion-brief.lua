-- Motion to dismiss with memorandum, DOCX engine (docs/DOCX.md): the markdown contract -> a pleading-paper Word document
-- on reference.docx. The cover (counsel, court title, caption box) is written as OpenXML (a table with a right and a
-- bottom rule under the parties). The motion and the memorandum follow the caption on the same page, so the caption row
-- is rounded to whole grid lines (the body stays on the 28-line grid). Exact 462-twip lines keep every line on the grid
-- of the header's 28 numbers; single spaced blocks (280 twips) are padded to whole grid lines, as the typst template does.

local GRID = 462     -- one numbered line (exact)
local SINGLE = 280   -- one single-spaced line (exact): 14 pt

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

-- one paragraph of OpenXML with a paragraph style (styleId) and inlines
local function PX(inl, sid)
  return '<w:p><w:pPr><w:pStyle w:val="' .. sid .. '"/></w:pPr>' .. runs(inl, {}) .. '</w:p>'
end

-- an empty paragraph exactly `tw` twips high (a grid pad, or a half line)
local function pad(tw)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. tw .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- the rest of a block of n single lines up to a whole number of grid lines
local function grid_pad(n_single)
  local h = n_single * SINGLE
  local target = math.ceil(h / GRID) * GRID
  if target - h > 0 then return pad(target - h) end
  return ""
end

local function lines_of(s, cpl) return math.max(1, math.ceil(#s / cpl)) end

-- the caption box: parties at left (right and bottom rule), the case number and title at right
local function caption_xml(meta)
  local left, lh = {}, 0
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = PX(meta.caption.separator and minl(meta.caption.separator) or { pandoc.Str("v.") }, "PleadingCaption")
      lh = lh + 1
    end
    for _, n in ipairs(p.names or {}) do
      left[#left + 1] = PX(minl(n), "PleadingCaption")
      lh = lh + lines_of(pandoc.utils.stringify(n), 34)
    end
    left[#left + 1] = PX(minl(p.designation), "PleadingDesignation")
    lh = lh + lines_of(pandoc.utils.stringify(p.designation), 26)
  end
  local case = "Case No.: " .. pandoc.utils.stringify(meta.case_number or "")
  local right, rh = { PX({ pandoc.Str(case) }, "PleadingCaption") }, lines_of(case, 32)
  right[#right + 1] = pad(231)
  rh = rh + 0.5
  right[#right + 1] = PX({ pandoc.Strong(minl(meta.brief_title)) }, "PleadingCaption")
  rh = rh + lines_of(pandoc.utils.stringify(meta.brief_title), 20)
  -- rounded to the grid: the memorandum follows on this page
  local h = math.ceil(math.max(lh, rh) * SINGLE / GRID) * GRID
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="8640" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="288"/><w:gridCol w:w="3744"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="', tostring(h), '" w:hRule="atLeast"/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>',
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
    '<w:tcMar><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>', table.concat(left), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>',
    table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

-- the cover: counsel single spaced (padded to whole lines, at least 7), a grid line, the court title, a grid line,
-- the caption box, a grid line
local function cover(meta)
  local out = {}
  local counsel = meta.counsel or {}
  for _, c in ipairs(counsel) do out[#out + 1] = PX(minl(c), "PleadingSingle") end
  local h = #counsel * SINGLE
  local target = math.max(7 * GRID, math.ceil(h / GRID) * GRID)
  if target - h > 0 then out[#out + 1] = pad(target - h) end
  out[#out + 1] = '<w:p/>'
  out[#out + 1] = PX({ pandoc.Strong({ pandoc.Str("UNITED STATES DISTRICT COURT") }) }, "PleadingCentered")
  out[#out + 1] = PX({ pandoc.Strong({ pandoc.Str("DISTRICT OF NEVADA") }) }, "PleadingCentered")
  out[#out + 1] = '<w:p/>'
  out[#out + 1] = caption_xml(meta)
  out[#out + 1] = '<w:p/>'
  return table.concat(out)
end

-- the date, the signature block at 2.6 in (the firm, then "By: /s/" and the signer's lines)
local function signature(sig, date)
  local out = { PX(minl(date), "PleadingFlush"), '<w:p/>' }
  local firm = {}
  for _, l in ipairs(sig.firm or {}) do firm[#firm + 1] = PX(minl(l), "PleadingSignature") end
  out[#out + 1] = table.concat(firm)
  out[#out + 1] = grid_pad(#(sig.firm or {}))
  out[#out + 1] = pad(231)
  local by = { PX({ pandoc.Str("By: /s/ " .. pandoc.utils.stringify(sig.signer)) }, "PleadingSignature") }
  for _, l in ipairs(sig.lines or {}) do by[#by + 1] = PX(minl(l), "PleadingSignature") end
  out[#out + 1] = table.concat(by)
  out[#out + 1] = grid_pad(#(sig.lines or {}) + 1)
  return table.concat(out)
end

-- the certificate of service: its own page (the heading starts the page), the paragraphs, the recipients at 0.5 in,
-- the signature block at 2.6 in
local function certificate(cert, date)
  local out = { PX({ pandoc.Str("CERTIFICATE OF SERVICE") }, "PleadingCertHeading") }
  for _, p in ipairs(cert.paragraphs or {}) do out[#out + 1] = PX(minl(p), "PleadingBody") end
  local rec = {}
  for _, r in ipairs(cert.recipients or {}) do rec[#rec + 1] = PX(minl(r), "PleadingRecipient") end
  out[#out + 1] = table.concat(rec)
  out[#out + 1] = grid_pad(#(cert.recipients or {}))
  out[#out + 1] = '<w:p/>'
  local by = { PX({ pandoc.Str("By: /s/ " .. pandoc.utils.stringify(cert.signer)) }, "PleadingSignature") }
  for _, l in ipairs(cert.lines or {}) do by[#by + 1] = PX(minl(l), "PleadingSignature") end
  out[#out + 1] = table.concat(by)
  return table.concat(out)
end

-- A block quotation (LR IA 10-1(a)(4): indented and single spaced) is a borderless table cell, indented 0.5 in on
-- both sides: its single lines are not whole grid lines, so the row is set to at least the grid-rounded height of
-- an estimate (58 characters per line, a generous count). An over-estimate leaves white space under the quotation;
-- an under-estimate grows the row. Either way the text after the quotation stays on the numbered-line grid.
-- Lists in a quotation are set as hanging paragraphs with their number typed.
local function quote_table(bq)
  local paras, est = {}, 0
  local function add(blocks, prefix_fn)
    for j, b in ipairs(blocks) do
      if b.t == "Para" or b.t == "Plain" then
        local inl = {}
        if prefix_fn and j == 1 then
          for _, x in ipairs(prefix_fn()) do inl[#inl + 1] = x end
        end
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        paras[#paras + 1] = PX(inl, prefix_fn and "PleadingHanging" or "PleadingCaption")
        est = est + lines_of(pandoc.utils.stringify(b), 58)
      else
        paras[#paras + 1] = PX({ pandoc.Str(pandoc.utils.stringify(b)) }, "PleadingCaption")
        est = est + lines_of(pandoc.utils.stringify(b), 58)
      end
    end
  end
  for _, b in ipairs(bq.content) do
    if b.t == "OrderedList" then
      -- the marker as the author typed it: "(b)" is a list to pandoc, not a renumbered "1."
      local a = b.listAttributes
      for k, item in ipairs(b.content) do
        local n = a.start + k - 1
        local s = tostring(n)
        if a.style == "LowerAlpha" then s = string.char(96 + n)
        elseif a.style == "UpperAlpha" then s = string.char(64 + n) end
        local marker = a.delimiter == "TwoParens" and ("(" .. s .. ")") or (a.delimiter == "OneParen" and (s .. ")") or (s .. "."))
        add(item, function() return { pandoc.Str(marker), pandoc.Space() } end)
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        add(item, function() return { pandoc.Str("\u{2022}"), pandoc.Space() } end)
      end
    else
      add({ b }, nil)
    end
  end
  local h = math.ceil(est * SINGLE / GRID) * GRID
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="7200" w:type="dxa"/><w:tblInd w:w="720" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="7200"/></w:tblGrid>',
    '<w:tr><w:trPr><w:trHeight w:val="', tostring(h), '" w:hRule="atLeast"/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="7200" w:type="dxa"/></w:tcPr>', table.concat(paras), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc would print the date as a title block at the top; the date is set in the signature block instead
  local date = meta.date
  doc.meta.date = nil
  local out = { pandoc.RawBlock("openxml", cover(meta)) }

  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Body" }))
    elseif b.t == "BlockQuote" then
      out[#out + 1] = pandoc.RawBlock("openxml", quote_table(b))
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta.signature, date))
  if meta.certificate then
    out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="2" w:lineRule="exact"/></w:pPr></w:p>')
    out[#out + 1] = pandoc.RawBlock("openxml", certificate(meta.certificate, date))
  end
  doc.blocks = out
  return doc
end
