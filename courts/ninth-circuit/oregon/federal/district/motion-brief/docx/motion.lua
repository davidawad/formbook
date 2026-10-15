-- Motion with memorandum, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx, laid
-- out as the typst template (ord-motion-brief.typ) lays it out. The cover (counsel block, court title, caption table
-- with the case number at the page center and the legend under the title) and the signature and certificate of service
-- are written as OpenXML because pandoc's table model cannot set the borderless caption columns or the signature gap.
-- The body keeps its markdown structure with the paragraph styles of reference.docx. Motions are not numbered.
-- Line spacing: body lines exact 480 twips (24 pt, double); single-spaced blocks exact 260 twips (13 pt).

local DOUBLE = 480
local SINGLE = 260

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines -> OpenXML runs (for the cover and the certificate only; the body goes through pandoc's own writer)
local function runs(inl, flags)
  local out = {}
  local function run(text)
    local rpr = ""
    if flags.b then rpr = rpr .. "<w:b/><w:bCs/>" end
    if flags.i then rpr = rpr .. "<w:i/><w:iCs/>" end
    out[#out + 1] = "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "") ..
      '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
  end
  for _, e in ipairs(inl) do
    local t = e.t
    if t == "Str" then run(e.text)
    elseif t == "Space" or t == "SoftBreak" then run(" ")
    elseif t == "LineBreak" then out[#out + 1] = "<w:r><w:br/></w:r>"
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

local function str(v) return pandoc.utils.stringify(v or "") end

-- one paragraph of OpenXML with a paragraph style and runs
local function PX(inl, sid, flags)
  return '<w:p><w:pPr><w:pStyle w:val="' .. sid .. '"/></w:pPr>' .. runs(inl, flags or {}) .. "</w:p>"
end

-- an empty paragraph exactly `tw` twips high (a spacer)
local function pad(tw, keep)
  return '<w:p><w:pPr>' .. (keep and "<w:keepNext/>" or "") .. '<w:spacing w:before="0" w:after="0" w:line="' .. tw .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- a page break before the next paragraph (an empty paragraph one twip high, so it adds no line)
local function page_break()
  return '<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="2" w:lineRule="exact"/></w:pPr></w:p>'
end

-- a borderless table of the given column widths (twips)
local function table_xml(widths, rows)
  local grid = {}
  local total = 0
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'; total = total + w end
  local out = {
    '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>',
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>',
    '</w:tblPr><w:tblGrid>', table.concat(grid), "</w:tblGrid>",
  }
  for _, r in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for i, cell in ipairs(r.cells) do
      local mar = r.mar and r.mar[i] or ""
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. mar .. "</w:tcPr>" .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- the counsel block: single-spaced lines (blank lines keep their line), then at least one inch, rounded up to whole
-- double-spaced lines, so the court title falls on the grid (typst: counsel-block)
local function counsel_xml(meta)
  local out, n = {}, 0
  for _, c in ipairs(meta.counsel or {}) do
    n = n + 1
    if str(c) == "" then
      out[#out + 1] = pad(SINGLE)
    else
      out[#out + 1] = PX(minl(c), "PleadingSingle")
    end
  end
  local h = n * SINGLE
  local target = math.ceil((h + 1440) / DOUBLE) * DOUBLE
  out[#out + 1] = pad(target - h)
  return table.concat(out)
end

-- the caption: party names left (ending 0.3 in short of the page center), the case number and the title at the page
-- center (LR 10-2(d), (f), (g)); the legend, if any, under the title
local function caption_xml(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = PX({ pandoc.Str("vs.") }, "PleadingCaption") end
    for _, n in ipairs(p.names or {}) do left[#left + 1] = PX(minl(n), "PleadingCaption") end
    left[#left + 1] = PX(minl(p.designation), "PleadingCaption")
  end
  local right = { PX({ pandoc.Str("Case No. " .. str(meta.case_number)) }, "PleadingCaption") }
  right[#right + 1] = pad(DOUBLE)
  right[#right + 1] = PX(minl(meta.brief_title), "PleadingCaption", { b = true })
  if meta.legend then
    right[#right + 1] = pad(DOUBLE // 2)
    right[#right + 1] = PX(minl(meta.legend), "PleadingCaption")
  end
  return table_xml({ 4680, 4680 }, {
    { cells = { table.concat(left), table.concat(right) },
      mar = { '<w:tcMar><w:right w:w="432" w:type="dxa"/></w:tcMar>', "" } },
  })
end

local function cover(meta)
  local out = { counsel_xml(meta) }
  for _, l in ipairs(meta.court or {}) do
    out[#out + 1] = PX({ pandoc.Str(str(l):upper()) }, "PleadingCentered", { b = true })
  end
  if meta.division then
    out[#out + 1] = PX({ pandoc.Str(str(meta.division):upper()) }, "PleadingCentered", { b = true })
  end
  out[#out + 1] = pad(DOUBLE // 2)
  out[#out + 1] = caption_xml(meta)
  return table.concat(out)
end

-- DATED on the left; the firm, then "By: /s/" and the signer's lines at 3.1 in (typst: signature-block).
-- Unbreakable: the rows do not split, and the paragraphs keep with the next, so no line is left alone on a page.
local function signature(meta, date)
  local sig = meta.signature
  local left = PX({ pandoc.Str("DATED: " .. date) }, "PleadingSignature")
  local right = {}
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = PX(minl(l), "PleadingSignature") end
  right[#right + 1] = pad(240, true)
  right[#right + 1] = PX({ pandoc.Str("By: /s/ " .. str(sig.signer)) }, "PleadingSignature")
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = PX(minl(l), "PleadingSignature") end
  return table_xml({ 4464, 4896 }, {
    { cells = { left, table.concat(right) } },
  })
end

-- Certificate of service: the form wording, with the document title, the date, the parties served and the method
-- filled from the frontmatter (typst: certificate-of-service). It starts on its own page.
local function certificate(meta)
  local cos = meta.certificate_of_service
  local out = { page_break(), PX({ pandoc.Str("CERTIFICATE OF SERVICE") }, "PleadingCentered", { b = true }) }
  out[#out + 1] = PX({
    pandoc.Str("The undersigned declares under penalty of perjury, under the laws of the State of Oregon, that on " ..
      str(cos.date) .. ", I arranged for service of the foregoing " .. str(meta.brief_title):upper() ..
      " on the party to this action as follows:"),
  }, "PleadingBody")
  out[#out + 1] = pad(240)
  for _, l in ipairs(cos.served or {}) do out[#out + 1] = PX(minl(l), "PleadingIndent") end
  out[#out + 1] = pad(240)
  out[#out + 1] = PX({ pandoc.Str("by: " .. str(cos.method)) }, "PleadingIndent")
  out[#out + 1] = pad(DOUBLE)
  out[#out + 1] = table_xml({ 4464, 4896 }, {
    { cells = { "<w:p/>", PX({ pandoc.Str("s/ " .. str(meta.signature.signer)) }, "PleadingSignature") ..
      PX({ pandoc.Str(str(meta.signature.signer)) }, "PleadingSignature") } },
  })
  return table.concat(out)
end

function Pandoc(doc)
  local meta = doc.meta
  local date = str(meta.date)
  -- the date is set in the signature block, not as a title block
  doc.meta.date = nil
  local out = { pandoc.RawBlock("openxml", cover(meta) .. page_break()) }

  local last
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      last = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Body" }))
      out[#out + 1] = last
    elseif b.t == "BlockQuote" then
      -- a block quotation is single-spaced and indented on both sides (LR 10-1(b) exempts quotations)
      for _, q in ipairs(b.content) do
        out[#out + 1] = pandoc.Div({ q }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Quote" }))
      end
      last = nil
    elseif b.t == "Table" then
      last = nil
      out[#out + 1] = pandoc.RawBlock("openxml", pad(240))
      out[#out + 1] = b
      out[#out + 1] = pandoc.RawBlock("openxml", pad(DOUBLE))
    else
      last = nil
      out[#out + 1] = b
    end
  end

  -- the last paragraph of the memorandum stays on the page with the signature block
  if last then last.attr.attributes["custom-style"] = "Pleading Body Keep" end
  out[#out + 1] = pandoc.RawBlock("openxml", pad(DOUBLE, true))
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta, date))
  if meta.certificate_of_service then
    out[#out + 1] = pandoc.RawBlock("openxml", certificate(meta))
  end
  doc.blocks = out
  return doc
end
