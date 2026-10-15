-- Complaint, DOCX engine (docs/DOCX.md). Mirrors typst/ctd-complaint.typ (layout, requirement IDs in ../README.md).
-- The caption (court title, parties, case number, date, title) is a table with a right and a bottom rule on the
-- party column, written as OpenXML because pandoc's table model cannot style cell borders. The body keeps its
-- markdown structure and the paragraph styles of reference.docx. Numbered paragraphs (Fed. R. Civ. P. 10(b)) get
-- their number typed, as the typst counter does; lists are lettered (a), (b), ... and bullets stay bullets.
-- Every case word comes from the sample's frontmatter; nothing here is case-specific.

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- inlines -> OpenXML runs; flags: b (bold), i (italic)
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
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- one paragraph of OpenXML with a paragraph style (styleId) and inlines
local function PX(inl, sid)
  return '<w:p><w:pPr><w:pStyle w:val="' .. sid .. '"/></w:pPr>' .. runs(inl, {}) .. '</w:p>'
end

-- an empty paragraph in a style (a blank line of the grid, or a half line)
local function blank(sid)
  return '<w:p><w:pPr><w:pStyle w:val="' .. sid .. '"/></w:pPr></w:p>'
end

-- the caption: parties at left (right and bottom rule), the case number, date, title and jury demand at right
local function caption_xml(meta)
  local parties = meta.caption.parties or meta.caption
  local left = {}
  for k, p in ipairs(parties) do
    if k > 1 then left[#left + 1] = PX({ pandoc.Str("v.") }, "PleadingCaption") end
    for _, n in ipairs(p.names or {}) do left[#left + 1] = PX(minl(n), "PleadingCaption") end
    left[#left + 1] = PX(minl(p.designation), "PleadingDesignation")
  end
  local right = {
    PX({ pandoc.Str("Case No. " .. str(meta.case_number)) }, "PleadingCaption"),
    PX({ pandoc.Str("Date: " .. str(meta.date)) }, "PleadingCaption"),
    blank("PleadingCaption"),
    PX({ pandoc.Strong(minl(meta.brief_title)) }, "PleadingCaption"),
  }
  if meta.jury_demand then
    right[#right + 1] = blank("PleadingCaption")
    right[#right + 1] = PX({ pandoc.Strong({ pandoc.Str("DEMAND FOR JURY TRIAL") }) }, "PleadingCaption")
  end
  return table.concat({
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="288"/><w:gridCol w:w="4320"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>',
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
    '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="160" w:type="dxa"/></w:tcMar></w:tcPr>', table.concat(left), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="PleadingSingle"/></w:pPr></w:p></w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>',
    table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

-- the cover: the court title (bold, centred, two lines), a blank line, the caption; the body follows on page 1
local function cover(meta)
  local out = {}
  for _, l in ipairs(meta.court or {}) do out[#out + 1] = PX(minl(l), "PleadingCentered") end
  out[#out + 1] = blank("Normal")
  out[#out + 1] = caption_xml(meta)
  out[#out + 1] = blank("Normal")
  return table.concat(out)
end

-- the signature block (CTD-SIG-001, CTD-SIG-002): "Dated:" at left, the signer at 2.6 in and right
local function signature(meta)
  local sig = meta.signature
  local left = { PX({ pandoc.Str("Dated: " .. str(meta.date)) }, "PleadingFlush") }
  local right = { PX({ pandoc.Str("Respectfully submitted,") }, "PleadingSignature"), blank("Normal") }
  table.insert(right, PX({ pandoc.Str("/s/ " .. str(sig.signer)) }, "PleadingSignature"))
  local name = str(sig.signer)
  if sig.bar then name = name .. ", Fed. Bar No. " .. str(sig.bar) end
  table.insert(right, PX({ pandoc.Str(name) }, "PleadingSignature"))
  for _, l in ipairs(sig.lines or {}) do table.insert(right, PX(minl(l), "PleadingSignature")) end
  return table.concat({
    blank("Normal"),
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>',
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>',
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>',
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    '<w:tblGrid><w:gridCol w:w="3744"/><w:gridCol w:w="5616"/></w:tblGrid>',
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>',
    '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/></w:tcPr>', table.concat(left), '</w:tc>',
    '<w:tc><w:tcPr><w:tcW w:w="5616" w:type="dxa"/><w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar></w:tcPr>',
    table.concat(right), '</w:tc>',
    '</w:tr></w:tbl>',
  })
end

local UNNUMBERED = "[unnumbered]"

-- a paragraph's inlines without a leading "[unnumbered]" marker; returns inlines, marked
local function strip_marker(inl)
  if #inl >= 1 and inl[1].t == "Str" and inl[1].text == UNNUMBERED then
    local rest = pandoc.List({})
    local start = 2
    if inl[2] and inl[2].t == "Space" then start = 3 end
    for i = start, #inl do rest:insert(inl[i]) end
    return rest, true
  end
  return inl, false
end

function Pandoc(doc)
  -- a copy of the metadata: pandoc would print the date as a title block, so the date is taken out of the
  -- document (it is set in the caption and the signature block instead)
  local meta = {}
  for k, v in pairs(doc.meta) do meta[k] = v end
  doc.meta.date = nil
  local out = { pandoc.RawBlock("openxml", cover(meta)) }

  if meta.lead_in then
    out[#out + 1] = pandoc.Div({ pandoc.Para(minl(meta.lead_in)) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Unnumbered" }))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local inl, unnumbered = strip_marker(b.content)
      if unnumbered then
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Unnumbered" }))
      else
        n = n + 1
        local num = pandoc.List({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        num:extend(b.content)
        out[#out + 1] = pandoc.Div({ pandoc.Para(num) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Para" }))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- lettered (a), (b), ... as the typst enum; bullets stay bullets
      for k, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and ("(" .. string.char(string.byte("a") + k - 1) .. ")") or "\u{2022}"
        for _, ib in ipairs(item) do
          if ib.t == "Plain" or ib.t == "Para" then
            local inl = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
            inl:extend(ib.content)
            out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Pleading Item" }))
          else
            out[#out + 1] = ib
          end
        end
      end
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = pandoc.Div({ q }, pandoc.Attr("", {}, { ["custom-style"] = "Block Text" }))
      end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta))
  doc.blocks = out
  return doc
end
