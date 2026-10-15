-- nyeb adversary complaint, DOCX engine (docs/DOCX.md). Mirrors typst/nyeb-adversary-complaint.typ:
--   court title; caption (a borderless table with the rules of the typst caption); lead-in; numbered
--   allegations (number at 0.5 in, text at 1 in, wrapped lines back at 1 in); lettered prayer items; the last
--   item and the signature block kept together. The page number comes from reference.docx's footer.
-- The cover and signature are raw OpenXML built from the frontmatter; the body keeps its markdown structure.
-- Known limit (see the README, "Engines"): the paragraph numbers and prayer letters are typed text followed by
-- a tab, not Word list numbering, so they do not renumber when a paragraph is added in Word.

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- a metadata list (or single value) as plain strings, one per line of the caption
local function meta_list(v)
  local out = {}
  if v == nil then return out end
  if v.t == nil then -- a YAML list (pandoc gives plain Lua tables without a t field)
    for _, x in ipairs(v) do out[#out + 1] = plain(x) end
  else
    out[#out + 1] = plain(v)
  end
  return out
end

local function run_xml(text, rpr)
  local rp = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  if text == "" then return "" end
  return "<w:r>" .. rp .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- one paragraph: style, then extra pPr children (keepNext, spacing, ind, jc, in that order), then the run
local function p_xml(style, text, extra, rpr)
  return "<w:p><w:pPr><w:pStyle w:val=\"" .. style .. "\"/>" .. (extra or "") .. "</w:pPr>"
    .. run_xml(text, rpr) .. "</w:p>"
end

local function spacer_xml()
  return "<w:p><w:pPr><w:pStyle w:val=\"Spacer\"/></w:pPr></w:p>"
end

local function rule(side)
  return "<w:" .. side .. " w:val=\"single\" w:sz=\"6\" w:space=\"0\" w:color=\"000000\"/>"
end

local function cell(width, sides, valign, top_mar, left_mar, paras)
  local bd = ""
  if sides then
    local parts = {}
    for _, s in ipairs(sides) do parts[#parts + 1] = rule(s) end
    bd = "<w:tcBorders>" .. table.concat(parts) .. "</w:tcBorders>"
  end
  return "<w:tc><w:tcPr><w:tcW w:w=\"" .. width .. "\" w:type=\"dxa\"/>" .. bd
    .. "<w:tcMar><w:top w:w=\"" .. top_mar .. "\" w:type=\"dxa\"/><w:left w:w=\"" .. left_mar
    .. "\" w:type=\"dxa\"/><w:bottom w:w=\"160\" w:type=\"dxa\"/><w:right w:w=\"0\" w:type=\"dxa\"/></w:tcMar>"
    .. "<w:vAlign w:val=\"" .. valign .. "\"/></w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

local function row(cells)
  return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
end

local function table_xml(widths, rows)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = "<w:gridCol w:w=\"" .. w .. "\"/>"
    total = total + w
  end
  return "<w:tbl><w:tblPr><w:tblW w:w=\"" .. total .. "\" w:type=\"dxa\"/><w:tblInd w:w=\"0\" w:type=\"dxa\"/>"
    .. "<w:tblBorders><w:top w:val=\"nil\"/><w:left w:val=\"nil\"/><w:bottom w:val=\"nil\"/><w:right w:val=\"nil\"/>"
    .. "<w:insideH w:val=\"nil\"/><w:insideV w:val=\"nil\"/></w:tblBorders>"
    .. "<w:tblLayout w:type=\"fixed\"/><w:tblCellMar><w:left w:w=\"0\" w:type=\"dxa\"/><w:right w:w=\"0\" w:type=\"dxa\"/></w:tblCellMar>"
    .. "<w:tblLook w:val=\"0000\" w:firstRow=\"0\" w:lastRow=\"0\" w:firstColumn=\"0\" w:lastColumn=\"0\" w:noHBand=\"1\" w:noVBand=\"1\"/>"
    .. "</w:tblPr><w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid>" .. table.concat(rows) .. "</w:tbl>"
end

local TEXT_W = 9360          -- 6.5 in
local CAP_LEFT = 5472        -- 3.8 in: the names column
local CAP_RIGHT = 3888       -- the rest; its left margin (0.2 in) is the gutter
local SIG_COL = 4680         -- 3.25 in: the signature column starts at the page's centre

local function court_title()
  return p_xml("Centered", "UNITED STATES BANKRUPTCY COURT", '<w:spacing w:before="0" w:after="120"/>', "<w:b/><w:bCs/>")
    .. p_xml("Centered", "EASTERN DISTRICT OF NEW YORK", '<w:spacing w:before="0" w:after="360"/>', "<w:b/><w:bCs/>")
end

local function caption(m, title)
  local debtor = m.caption.debtor
  local left = { p_xml("Single", "In re:") }
  for _, n in ipairs(meta_list(debtor.names)) do left[#left + 1] = p_xml("Single", n) end
  left[#left + 1] = p_xml("Single", plain(debtor.designation), '<w:ind w:left="1728" w:firstLine="0"/>')
  local right = {
    p_xml("Single", "Case No. " .. plain(m.case_number)),
    p_xml("Single", "Chapter " .. plain(m.chapter)),
  }
  local row1 = row({
    cell(CAP_LEFT, { "top", "bottom" }, "top", 160, 0, left),
    cell(CAP_RIGHT, { "top", "bottom" }, "center", 160, 288, right),
  })

  local pl, pr = {}, {}
  for k, p in ipairs(m.caption.parties) do
    if k > 1 then
      pl[#pl + 1] = p_xml("Centered", "-against-", '<w:spacing w:before="120" w:after="120"/>')
    end
    for _, n in ipairs(meta_list(p.names)) do pl[#pl + 1] = p_xml("Single", n) end
    pl[#pl + 1] = p_xml("Single", plain(p.designation), '<w:ind w:left="1728" w:firstLine="0"/>')
  end
  pr[#pr + 1] = p_xml("Single", "Adv. Pro. No. " .. plain(m.adversary_number))
  pr[#pr + 1] = p_xml("Gap6", "")
  pr[#pr + 1] = p_xml("Single", title, nil, "<w:b/><w:bCs/>")
  -- the gap between the two blocks is the typst block spacing (about 16 pt) plus the 8 pt inset
  local row2 = row({
    cell(CAP_LEFT, { "bottom" }, "top", 40, 0, pl),
    cell(CAP_RIGHT, { "bottom" }, "center", 40, 288, pr),
  })
  return table_xml({ CAP_LEFT, CAP_RIGHT }, { row1, row2 })
end

-- the signature: "Dated" at the left, the signer's block from the centre of the page; kept together
local function signature(m)
  local sig = m.signature
  local left, right = { p_xml("SingleKeep", "Dated: " .. plain(sig.date)) }, {}
  local lines = meta_list(sig.lines)
  for i, l in ipairs(lines) do
    right[#right + 1] = p_xml(i < #lines and "SingleKeep" or "Single", l)
  end
  local r = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    .. cell(SIG_COL, nil, "top", 0, 0, left) .. cell(TEXT_W - SIG_COL, nil, "top", 0, 0, right) .. "</w:tr>"
  return table_xml({ SIG_COL, TEXT_W - SIG_COL }, { r })
end

local KEEP = { Allegation = "AllegationKeep", Prayer = "PrayerKeep", Lead = "LeadKeep" }

function Pandoc(doc)
  local m = doc.meta
  -- the title is set in the caption; it is removed from the metadata so no title block is written in the body
  local title = plain(m.title)
  m.title = nil

  local out = {}
  local function add(x) out[#out + 1] = x end
  add(pandoc.RawBlock("openxml", court_title()))
  add(pandoc.RawBlock("openxml", caption(m, title)))
  add(pandoc.RawBlock("openxml", spacer_xml()))

  -- the body as entries: {div = style, inlines = ...} for styled paragraphs, {block = b} otherwise
  local entries = {}
  if m.lead_in then
    entries[#entries + 1] = { div = "Lead", inlines = m.lead_in }
  end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local s = plain(b)
      if s:match("^WHEREFORE") then
        entries[#entries + 1] = { block = pandoc.RawBlock("openxml", spacer_xml()) }
        entries[#entries + 1] = { div = "Lead", inlines = b.content }
      else
        n = n + 1
        local inl = { pandoc.Str(tostring(n) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        entries[#entries + 1] = { div = "Allegation", inlines = inl }
      end
    elseif b.t == "OrderedList" then
      -- the prayer: one lettered item per list item, the letter at 0.5 in and the text at 1 in
      for k, item in ipairs(b.content) do
        local first = item[1]
        local inl = { pandoc.Str("(" .. string.char(96 + k) .. ")"), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        if first and (first.t == "Plain" or first.t == "Para") then
          for _, x in ipairs(first.content) do inl[#inl + 1] = x end
          entries[#entries + 1] = { div = "Prayer", inlines = inl }
          for i = 2, #item do entries[#entries + 1] = { block = item[i] } end
        else
          entries[#entries + 1] = { div = "Prayer", inlines = inl }
          for i = 1, #item do entries[#entries + 1] = { block = item[i] } end
        end
      end
    else
      entries[#entries + 1] = { block = b }
    end
  end

  -- the last paragraph of the pleading stays with the signature (a signature never stands alone)
  local last = entries[#entries]
  if last and last.div and KEEP[last.div] then last.div = KEEP[last.div] end

  for _, e in ipairs(entries) do
    if e.div then
      add(pandoc.Div({ pandoc.Para(e.inlines) }, pandoc.Attr("", {}, { ["custom-style"] = e.div })))
    else
      add(e.block)
    end
  end
  if m.signature then
    add(pandoc.RawBlock("openxml", spacer_xml()))
    add(pandoc.RawBlock("openxml", signature(m)))
  end
  doc.blocks = out
  return doc
end
