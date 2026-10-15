-- Complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx, laid out as the
-- typst template (ord-complaint.typ) lays it out. The cover (counsel block, court title, caption table with the case
-- number at the page center) is written as OpenXML because pandoc's table model cannot set the caption's borderless
-- columns or the signature block's column gap. The body keeps its markdown structure with the paragraph styles of
-- reference.docx. Numbered paragraphs (Fed. R. Civ. P. 10(b)) get their number typed, as the typst counter does.
-- Lettered lists (markdown "-") are typed as (a), (b), ... with a hanging indent.
-- Line spacing: body lines exact 480 twips (24 pt, double); single-spaced blocks exact 260 twips (13 pt).

local DOUBLE = 480
local SINGLE = 260

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines -> OpenXML runs (for the cover only; the body goes through pandoc's own writer)
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

-- a borderless table of the given column widths (twips), cells as OpenXML strings
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

-- the caption: party names left (ending at the page center less a 0.3 in gap), the case number and the title
-- at the page center (LR 10-2(d), (f), (g)). A blank case number is a blank line for the clerk.
local function caption_xml(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = PX({ pandoc.Str("vs.") }, "PleadingCaption") end
    for _, n in ipairs(p.names or {}) do left[#left + 1] = PX(minl(n), "PleadingCaption") end
    left[#left + 1] = PX(minl(p.designation), "PleadingCaption")
  end
  local number = str(meta.case_number)
  if number == "" then number = "________________" end
  local right = { PX({ pandoc.Str("Case No. " .. number) }, "PleadingCaption") }
  right[#right + 1] = pad(DOUBLE)
  right[#right + 1] = PX(minl(meta.brief_title), "PleadingCaption", { b = true })
  if meta.jury_demand then
    right[#right + 1] = pad(DOUBLE // 2)
    right[#right + 1] = PX({ pandoc.Str("DEMAND FOR JURY TRIAL") }, "PleadingCaption", { b = true })
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

-- DATED on the left; the firm, then "By: /s/" and the signer's lines at 3.1 in (typst: signature-block)
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

local function letter(i)
  return "(" .. string.char(96 + i) .. ")"
end

function Pandoc(doc)
  local meta = doc.meta
  -- the date is set in the signature block, not as a title block
  local date = str(meta.date)
  doc.meta.date = nil
  local out = { pandoc.RawBlock("openxml", cover(meta)) }

  if meta.lead_in then
    out[#out + 1] = pandoc.Div({ pandoc.Para(minl(meta.lead_in)) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Body" }))
  end

  local n = 0
  local last
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
      inl:extend(b.content)
      last = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Body" }))
      out[#out + 1] = last
    elseif b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local inl = pandoc.List({ pandoc.Str(letter(i)), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        local first = item[1]
        if first and (first.t == "Plain" or first.t == "Para") then inl:extend(first.content) end
        last = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Letter" }))
        out[#out + 1] = last
      end
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = pandoc.Div({ q }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Quote" }))
      end
      last = nil
    elseif b.t == "Table" then
      last = nil
      out[#out + 1] = pandoc.RawBlock("openxml", pad(240))
      out[#out + 1] = b
      out[#out + 1] = pandoc.RawBlock("openxml", pad(DOUBLE))
    elseif b.t == "Header" then
      last = nil
      out[#out + 1] = b
    else
      last = nil
      out[#out + 1] = b
    end
  end

  -- the last allegation or prayer item stays on the page with the signature block
  if last then
    local s = last.attr.attributes["custom-style"]
    last.attr.attributes["custom-style"] = (s == "Pleading Letter") and "Pleading Letter Keep" or "Pleading Body Keep"
  end
  out[#out + 1] = pandoc.RawBlock("openxml", pad(DOUBLE // 2, true))
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta, date))
  doc.blocks = out
  return doc
end
