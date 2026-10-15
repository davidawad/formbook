-- nyeb motion with memorandum of law, DOCX engine (docs/DOCX.md). Mirrors typst/nyeb-motion-brief.typ:
--   counsel block (top left, single spaced); court title; caption (a borderless table with the typst rules),
--   "v." between the parties; the title centred and bold; body paragraphs with a 0.5 in first-line indent on an
--   exact 24 pt pitch (pandoc's Body Text); headings (reference.docx); bullets with a hanging indent (typed
--   bullet and a tab, not list numbering); block quotations (Block Text, single spaced, 1 in each side);
--   the conclusion and the signature block kept together.
-- The cover and signature are raw OpenXML built from the frontmatter. The footer (matter number and page number)
-- is in reference.docx; render.sh sets the matter number from the frontmatter.

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

-- a metadata list (or single value) as plain strings, one per line
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

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run_xml(text, rpr)
  local rp = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  if text == "" then return "" end
  return "<w:r>" .. rp .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- one paragraph: style, then extra pPr children (spacing, ind, in that order), then the run
local function p_xml(style, text, extra, rpr)
  return "<w:p><w:pPr><w:pStyle w:val=\"" .. style .. "\"/>" .. (extra or "") .. "</w:pPr>"
    .. run_xml(text, rpr) .. "</w:p>"
end

local function spacer_xml(keep)
  return "<w:p><w:pPr><w:pStyle w:val=\"" .. (keep and "SpacerKeep" or "Spacer") .. "\"/></w:pPr></w:p>"
end

-- an exact 18 pt spacer: the cover lines sit on the typst box (0.65 em), so the gaps after them are trimmed by 6 pt
local function short_spacer_xml()
  return "<w:p><w:pPr><w:pStyle w:val=\"SpacerShort\"/></w:pPr></w:p>"
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

local function counsel_xml(m)
  local out = {}
  for _, l in ipairs(meta_list(m.counsel)) do out[#out + 1] = p_xml("Single", l) end
  return table.concat(out) .. short_spacer_xml()
end

local function court_title()
  return p_xml("Centered", "UNITED STATES BANKRUPTCY COURT", '<w:spacing w:before="0" w:after="120"/>', "<w:b/><w:bCs/>")
    .. p_xml("Centered", "EASTERN DISTRICT OF NEW YORK", '<w:spacing w:before="0" w:after="360"/>', "<w:b/><w:bCs/>")
end

local function caption(m)
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

  local pl = {}
  for k, p in ipairs(m.caption.parties) do
    if k > 1 then
      pl[#pl + 1] = p_xml("Centered", "v.", '<w:spacing w:before="120" w:after="120"/>')
    end
    for _, n in ipairs(meta_list(p.names)) do pl[#pl + 1] = p_xml("Single", n) end
    pl[#pl + 1] = p_xml("Single", plain(p.designation), '<w:ind w:left="1728" w:firstLine="0"/>')
  end
  local pr = { p_xml("Single", "Adv. Pro. No. " .. plain(m.adversary_number)) }
  local row2 = row({
    cell(CAP_LEFT, { "bottom" }, "top", 40, 0, pl),
    cell(CAP_RIGHT, { "bottom" }, "center", 40, 288, pr),
  })
  return table_xml({ CAP_LEFT, CAP_RIGHT }, { row1, row2 })
end

-- the title of the paper: centred, bold, single spaced (typst sets it inside the caption, so it is single)
local function title_xml(title)
  return "<w:p><w:pPr><w:pStyle w:val=\"Centered\"/></w:pPr>" .. run_xml(title, "<w:b/><w:bCs/>") .. "</w:p>"
end

-- the signature: the place and date at the left, the firm's block from the centre of the page; kept together
local function signature(m)
  local sig = m.signature
  local left, right = {}, {}
  local dated = meta_list(sig.dated)
  for i, l in ipairs(dated) do left[#left + 1] = p_xml(i < #dated and "SingleKeep" or "Single", l) end
  local lines = meta_list(sig.lines)
  for i, l in ipairs(lines) do right[#right + 1] = p_xml(i < #lines and "SingleKeep" or "Single", l) end
  local r = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    .. cell(SIG_COL, nil, "top", 0, 0, left) .. cell(TEXT_W - SIG_COL, nil, "top", 0, 0, right) .. "</w:tr>"
  return table_xml({ SIG_COL, TEXT_W - SIG_COL }, { r })
end

-- a bulleted list: a typed bullet at 0.5 in, the text at 0.75 in
local function bullets(list, keep_last)
  local out = {}
  for k, item in ipairs(list.content) do
    local first = item[1]
    local inl = { pandoc.Str("•"), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
    local style = (keep_last and k == #list.content) and "BulletKeep" or "Bullet"
    if first and (first.t == "Plain" or first.t == "Para") then
      for _, x in ipairs(first.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
      for i = 2, #item do out[#out + 1] = item[i] end
    else
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
      for i = 1, #item do out[#out + 1] = item[i] end
    end
  end
  return out
end

function Pandoc(doc)
  local m = doc.meta
  -- the title is set below the caption; it is removed from the metadata so no title block is written in the body
  local title = plain(m.title)
  m.title = nil

  local out = {}
  local function add(x) out[#out + 1] = x end
  if m.counsel then add(raw(counsel_xml(m))) end
  add(raw(court_title()))
  add(raw(caption(m)))
  add(raw(short_spacer_xml()))
  add(raw(title_xml(title)))
  add(raw("<w:p><w:pPr><w:pStyle w:val=\"SpacerAfterTitle\"/></w:pPr></w:p>"))

  -- the conclusion (the last paragraph or list) stays with the signature
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    local last = (i == #blocks)
    if b.t == "BulletList" then
      for _, x in ipairs(bullets(b, last)) do add(x) end
    elseif b.t == "Para" and last then
      add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" })))
    else
      add(b)
    end
  end
  if m.signature then
    add(raw(spacer_xml(true)))
    add(raw(signature(m)))
  end
  doc.blocks = out
  return doc
end
