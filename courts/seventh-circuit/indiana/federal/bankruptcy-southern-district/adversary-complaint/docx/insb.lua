-- S.D. Ind. bankruptcy adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on reference.docx. Matches typst/insb-adversary-complaint.typ (see ../README.md, "Engines"):
-- the cover (court title, bankruptcy caption, adversary caption, title), the body with numbered allegations
-- (Fed.R.Civ.P. 10(b)), lettered items shown as "a.", the signature block. The page number comes from the
-- reference's footer. Every case word comes from the sample's frontmatter; the template holds none.
-- Caption and signature blocks are tables with no borders except the caption's right and bottom rules.
-- Known limits (BLOCKED, see the PR): the .docx could not be rendered to PDF on this box (no soffice), so
-- the layout is unverified against the typst form; caption table borders are not checked.

local CFG = {
  numbered = true,       -- allegations are numbered by the template (Fed.R.Civ.P. 10(b))
}

-- the body widths in twips: letter page, 1 in margins = 9360
local TEXT_W = 9360

local function copy_inlines(v)
  local inl = {}
  for _, x in ipairs(v) do inl[#inl + 1] = x end
  return inl
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value (markdown inlines or blocks) as a list of blocks
local BLOCK_TAGS = { Para = true, Plain = true, BlockQuote = true, BulletList = true, OrderedList = true, Header = true, Div = true, CodeBlock = true, RawBlock = true, LineBlock = true, Table = true, HorizontalRule = true }

-- a metadata value as a list of blocks: a list of blocks (MetaBlocks) or a list of inlines (MetaInlines, one paragraph)
local function meta_blocks(v)
  local out = {}
  local first = v[1]
  if first and BLOCK_TAGS[first.t] then
    for _, b in ipairs(v) do out[#out + 1] = b end
  else
    out[1] = pandoc.Para(copy_inlines(v))
  end
  return out
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function styled(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

-- one paragraph of plain text in a named style (used inside the caption and signature tables)
local function para_xml(text, style)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr><w:r><w:t xml:space="preserve">'
    .. esc(text) .. '</w:t></w:r></w:p>'
end

local function gap(style)
  return raw('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

-- a table cell: width in twips, body = paragraphs; o.right / o.bottom = a 0.75 pt rule on that side
local function tc(w, body, o)
  o = o or {}
  local borders = ""
  if o.bottom or o.right then
    borders = "<w:tcBorders>"
      .. (o.bottom and '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' or "")
      .. (o.right and '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' or "")
      .. "</w:tcBorders>"
  end
  local mar = ""
  if o.mar_left or o.mar_right or o.mar_bottom then
    mar = "<w:tcMar>"
      .. (o.mar_left and ('<w:left w:w="' .. o.mar_left .. '" w:type="dxa"/>') or "")
      .. (o.mar_bottom and ('<w:bottom w:w="' .. o.mar_bottom .. '" w:type="dxa"/>') or "")
      .. (o.mar_right and ('<w:right w:w="' .. o.mar_right .. '" w:type="dxa"/>') or "")
      .. "</w:tcMar>"
  end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. borders .. mar .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- a borderless fixed-width table row of cells (widths sum to TEXT_W)
local function table_xml(widths, cells)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

-- caption: the party column (3.4 in) with a right and bottom rule, a 0.2 in gutter, the number column
local CAPTION_LEFT = 4896
local CAPTION_GUTTER = 288
local CAPTION_RIGHT = TEXT_W - CAPTION_LEFT - CAPTION_GUTTER

local function caption(left_lines, right_lines)
  local l, r = {}, {}
  for _, s in ipairs(left_lines) do l[#l + 1] = para_xml(s, "Single") end
  for _, s in ipairs(right_lines) do r[#r + 1] = para_xml(s, "Single") end
  return raw(table_xml({ CAPTION_LEFT, CAPTION_GUTTER, CAPTION_RIGHT }, {
    tc(CAPTION_LEFT, table.concat(l), { right = true, bottom = true, mar_right = 200, mar_bottom = 160 }),
    tc(CAPTION_GUTTER, "<w:p/>"),
    tc(CAPTION_RIGHT, table.concat(r), { mar_left = 144 }),
  }))
end

local function names_of(list)
  local out = {}
  for _, n in ipairs(list or {}) do out[#out + 1] = plain(n) end
  return out
end

-- the cover: court title (template text), bankruptcy caption, adversary caption, title of the paper
local function cover(meta)
  local out = {
    styled({ pandoc.Para({ pandoc.Strong({ pandoc.Str("UNITED STATES BANKRUPTCY COURT") }) }) }, "Centered"),
    styled({ pandoc.Para({ pandoc.Strong({ pandoc.Str("SOUTHERN DISTRICT OF INDIANA") }) }) }, "Centered"),
  }
  if meta.division and plain(meta.division) ~= "" then
    out[#out + 1] = styled({ pandoc.Para({ pandoc.Strong({ pandoc.Str(plain(meta.division):upper() .. " DIVISION") }) }) }, "Centered")
  end
  out[#out + 1] = gap("Gap")

  local left = { "In re:", "" }
  for _, s in ipairs(names_of(meta.debtor.names)) do left[#left + 1] = s end
  left[#left + 1] = plain(meta.debtor.designation)
  out[#out + 1] = caption(left, { "Case No. " .. plain(meta.case_number), "Chapter " .. plain(meta.chapter) })
  out[#out + 1] = gap("HalfGap")

  local rows = {}
  for k, p in ipairs(meta.adversary.parties) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, s in ipairs(names_of(p.names)) do rows[#rows + 1] = s end
    rows[#rows + 1] = plain(p.designation)
  end
  local number = plain(meta.adversary.adv_number)
  if number == "" then number = "____________" end
  out[#out + 1] = caption(rows, { "Adv. Pro. No. " .. number })
  out[#out + 1] = gap("Gap")

  out[#out + 1] = styled({ pandoc.Para({ pandoc.Strong(copy_inlines(meta.title)) }) }, "Centered")
  out[#out + 1] = gap("Gap")
  return out
end

-- an ordered list (the markdown "(a)" and "(1)" items): shown as "a." or "1." with a hanging indent
local function lettered(list)
  local out = {}
  local start = list.listAttributes.start or 1
  local alpha = tostring(list.listAttributes.style):find("Alpha") ~= nil
  for i, item in ipairs(list.content) do
    local n = start + i - 1
    local label = (alpha and string.char(96 + n) or tostring(n)) .. "."
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      out[#out + 1] = styled({ pandoc.Para({ pandoc.Str(label), TAB, table.unpack(first.content) }) }, "Lettered")
      for j = 2, #item do out[#out + 1] = item[j] end
    else
      out[#out + 1] = styled({ pandoc.Para({ pandoc.Str(label) }) }, "Lettered")
      for _, b in ipairs(item) do out[#out + 1] = b end
    end
  end
  return out
end

local function signature(meta)
  local sig = meta.signature
  local right = {}
  for _, s in ipairs(names_of(sig.firm)) do right[#right + 1] = para_xml(s, "Single") end
  right[#right + 1] = para_xml("", "HalfGap")
  right[#right + 1] = para_xml("By: /s/ " .. plain(sig.signer), "Single")
  right[#right + 1] = para_xml(plain(sig.signer):upper(), "Single")
  for _, s in ipairs(names_of(sig.lines)) do right[#right + 1] = para_xml(s, "Single") end
  local left = para_xml("Dated: " .. plain(meta.date), "Single")
  return raw(table_xml({ 4032, TEXT_W - 4032 }, {
    tc(4032, left),
    tc(TEXT_W - 4032, table.concat(right)),
  }))
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  addall(cover(meta))

  if meta.lead_in then
    addall(meta_blocks(meta.lead_in))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local t = plain(b)
      if t:match("^%[") then
        -- a bracketed note: centered, not numbered
        add(styled({ pandoc.Para(b.content) }, "CenteredBody"))
      elseif t:match("^WHEREFORE") then
        add(b)
      elseif t:match("^%l") then
        -- continues the paragraph before it (e.g. the total after a lettered list): not numbered, no indent
        add(styled({ pandoc.Para(b.content) }, "Continuation"))
      elseif CFG.numbered then
        n = n + 1
        add(styled({ pandoc.Para({ pandoc.Str(n .. "."), TAB, table.unpack(b.content) }) }, "Allegation"))
      else
        add(b)
      end
    elseif b.t == "OrderedList" then
      addall(lettered(b))
    else
      add(b)
    end
  end

  if meta.signature then
    add(gap("Gap"))
    add(signature(meta))
  end

  doc.blocks = out
  return doc
end
