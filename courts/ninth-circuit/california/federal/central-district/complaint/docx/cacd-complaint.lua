-- C.D. Cal. complaint, DOCX engine (docs/DOCX.md): markdown contract -> Word document on reference.docx.
-- Mirrors typst/cacd-complaint.typ: counsel block (single spaced, lines 1 on), court title and caption (a table
-- with the party column's right and bottom rule), the lead-in, numbered allegations (Fed. R. Civ. P. 10(b)),
-- lettered list items (typst's enum), the signature block (kept on one page by cantSplit). The numbered lines,
-- pleading rules and footer come from the reference (header frame, page borders, footer placeholders).
-- Every case word comes from the sample's frontmatter, never from this file.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, rpr)
  local pr = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. pr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function para(style, inner)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. inner .. "</w:p>"
end

-- an empty paragraph of exact height `twips` (a vertical space on the grid)
local function spacer(twips)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function need(meta, key)
  if meta[key] == nil then error("cacd-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function strings(list)
  local out = {}
  for _, v in ipairs(list) do out[#out + 1] = plain(v) end
  return out
end

-- counsel lines: one Single paragraph each; the block fills whole 24 pt lines (7 lines at least)
local function counsel_xml(lines)
  local n = #lines
  local xml = {}
  for _, l in ipairs(lines) do xml[#xml + 1] = para("Single", run(l)) end
  local total = math.max(7, math.ceil(n * 16 / 24)) * 24 * 20 -- twips
  local pad = total - n * 320
  if pad > 0 then xml[#xml + 1] = spacer(pad) end
  return table.concat(xml)
end

local function caption_xml(meta)
  local left = {}
  local parties = need(meta, "caption").parties
  for k, p in ipairs(parties) do
    if k > 1 then left[#left + 1] = para("Single", run("v.")) end
    for _, nm in ipairs(strings(p.names)) do left[#left + 1] = para("Single", run(nm)) end
    left[#left + 1] = para("Single", run(plain(p.designation)))
  end
  local right = {}
  right[#right + 1] = para("Single", run("Case No. " .. plain(need(meta, "case_number"))))
  right[#right + 1] = spacer(240)
  right[#right + 1] = para("Single", run(plain(need(meta, "brief_title")), "<w:b/><w:bCs/>"))
  if meta.legend ~= nil and plain(meta.legend) ~= "" then
    right[#right + 1] = spacer(240)
    right[#right + 1] = para("Single", run(plain(meta.legend):upper(), "<w:b/><w:bCs/>"))
  end
  if meta.jury_demand then
    right[#right + 1] = spacer(240)
    right[#right + 1] = para("Single", run("DEMAND FOR JURY TRIAL", "<w:b/><w:bCs/>"))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="288"/><w:gridCol w:w="4104"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="auto"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="auto"/></w:tcBorders>'
    .. '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4104" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. "</w:tc></w:tr></w:tbl>"
end

local function signature_xml(meta)
  local sig = need(meta, "signature")
  local left = para("Normal", run("Dated: " .. plain(need(meta, "date"))))
  local right = {}
  right[#right + 1] = para("Single", run("Respectfully submitted,"))
  right[#right + 1] = spacer(240)
  for _, f in ipairs(strings(sig.firm or {})) do right[#right + 1] = para("Single", run(f)) end
  right[#right + 1] = spacer(240)
  right[#right + 1] = para("Single", run("By: /s/ " .. plain(sig.signer)))
  right[#right + 1] = para("Single", run(plain(sig.signer)))
  for _, l in ipairs(strings(sig.lines or {})) do right[#right + 1] = para("Single", run(l)) end
  return '<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="3744"/><w:gridCol w:w="288"/><w:gridCol w:w="4968"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/></w:tcPr>' .. left .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4968" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. "</w:tc></w:tr></w:tbl>"
end

-- numbered allegations: each paragraph gets the next number, then a tab (the typst template's 0.3 in gap)
local number = 0
local function allegation(blk)
  number = number + 1
  local inl = { pandoc.Str(tostring(number) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
  for _, x in ipairs(blk.content) do inl[#inl + 1] = x end
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" }))
end

local function list_blocks(items, ordered)
  local out = {}
  for i, item in ipairs(items) do
    local marker = ordered and ("(" .. string.char(96 + i) .. ")") or "\u{2022}"
    for j, blk in ipairs(item) do
      if (blk.t == "Para" or blk.t == "Plain") and j == 1 then
        local inl = { pandoc.Str(marker), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        for _, x in ipairs(blk.content) do inl[#inl + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "ListItem" }))
      elseif blk.t == "Para" or blk.t == "Plain" then
        out[#out + 1] = pandoc.Div({ pandoc.Para(blk.content) }, pandoc.Attr("", {}, { ["custom-style"] = "ListItem" }))
      else
        out[#out + 1] = blk
      end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  -- the frontmatter is read here, not printed: no title, author or date block at the top of the document
  doc.meta = pandoc.Meta({})

  -- cover: counsel from line 1 (at least 7 lines), court title, caption
  local counsel = strings(need(meta, "counsel"))
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", counsel_xml(counsel))
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", para("CourtTitle", run("UNITED STATES DISTRICT COURT")))
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", para("CourtTitle", run("CENTRAL DISTRICT OF CALIFORNIA")))
  if meta.division ~= nil then
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", para("CourtTitle", run(plain(meta.division):upper())))
  end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", spacer(480))
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", caption_xml(meta))

  -- the body starts on a new page: a one-twip paragraph that carries the page break (no blank line is left
  -- at the top of the next page)
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>')

  -- lead-in (unnumbered)
  if meta.lead_in ~= nil then
    local inl = meta.lead_in.t == "MetaBlocks" and pandoc.utils.blocks_to_inlines(meta.lead_in) or meta.lead_in
    blocks[#blocks + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "LeadIn" }))
  end

  -- body
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" then
      blocks[#blocks + 1] = allegation(b)
    elseif b.t == "BulletList" then
      for _, x in ipairs(list_blocks(b.content, false)) do blocks[#blocks + 1] = x end
    elseif b.t == "OrderedList" then
      for _, x in ipairs(list_blocks(b.content, true)) do blocks[#blocks + 1] = x end
    else
      blocks[#blocks + 1] = b
    end
  end

  blocks[#blocks + 1] = pandoc.RawBlock("openxml", signature_xml(meta))
  doc.blocks = blocks
  return doc
end
