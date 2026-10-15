-- S.D. Ind. bankruptcy motion with supporting argument, DOCX engine (docs/DOCX.md): the markdown contract ->
-- a Word document on reference.docx. Matches typst/insb-motion-brief.typ (see ../README.md, "Engines"):
-- the cover (court title, bankruptcy caption, title of the paper), the body (headings, block quotations,
-- paragraphs with a first-line indent, citation lines flush left), the date line and signature block, and the
-- certificate of service on its own page. The page number comes from the reference's footer. Every case word
-- comes from the sample's frontmatter; the template holds none.
-- Known limits (BLOCKED, see the PR): the .docx could not be rendered to PDF on this box (no soffice), so
-- the layout is unverified against the typst form; caption table borders are not checked.

local CFG = {
  numbered = false,     -- motions are not numbered (only the complaint template numbers its allegations)
}

local TEXT_W = 9360 -- twips: letter page, 1 in margins

local BLOCK_TAGS = { Para = true, Plain = true, BlockQuote = true, BulletList = true, OrderedList = true, Header = true, Div = true, CodeBlock = true, RawBlock = true, LineBlock = true, Table = true, HorizontalRule = true }

local function copy_inlines(v)
  local inl = {}
  for _, x in ipairs(v) do inl[#inl + 1] = x end
  return inl
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

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

-- one paragraph of plain text in a named style (the caption and the signature block)
local function para_xml(text, style)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr><w:r><w:t xml:space="preserve">'
    .. esc(text) .. '</w:t></w:r></w:p>'
end

local function gap(style)
  return raw('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

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

-- caption: the debtor column (3.4 in) with a right and bottom rule, a 0.2 in gutter, the case number column
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

-- the cover: court title (template text), bankruptcy caption, title of the paper
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
  out[#out + 1] = gap("Gap")

  out[#out + 1] = styled({ pandoc.Para({ pandoc.Strong(copy_inlines(meta.title)) }) }, "Centered")
  out[#out + 1] = gap("Gap")
  return out
end

-- the signature block: "/s/" and the name, the name again, then the address lines (left from 3 in)
local function signature_lines(sig)
  local out = { raw(para_xml("/s/ " .. plain(sig.signer), "SignatureBlock")), raw(para_xml(plain(sig.signer), "SignatureBlock")) }
  for _, s in ipairs(names_of(sig.lines)) do out[#out + 1] = raw(para_xml(s, "SignatureBlock")) end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  addall(cover(meta))

  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local t = plain(b)
      if t:match("^%[") then
        add(styled({ pandoc.Para(b.content) }, "CenteredBody"))
      elseif t:match("^Id%.") or t:match("^%d") then
        -- a citation line that continues after a block quotation: flush left, not indented
        add(styled({ pandoc.Para(b.content) }, "Continuation"))
      else
        add(b)
      end
    else
      add(b)
    end
  end

  if meta.date_line then
    addall(meta_blocks(meta.date_line))
  end
  if meta.signature then
    add(gap("HalfGap"))
    addall(signature_lines(meta.signature))
  end

  if meta.certificate then
    -- CERTIFICATE OF SERVICE on its own page (B-9013-2)
    add(styled({ pandoc.Para({ pandoc.Str("Certificate of Service") }) }, "NewPageTitle"))
    add(gap("Gap"))
    addall(meta_blocks(meta.certificate.text))
    add(gap("Gap"))
    local lines = { para_xml("/s/ " .. plain(meta.certificate.signer), "SignatureBlock") }
    for _, s in ipairs(names_of(meta.certificate.lines)) do lines[#lines + 1] = para_xml(s, "SignatureBlock") end
    addall({ raw(table.concat(lines)) })
  end

  doc.blocks = out
  return doc
end
