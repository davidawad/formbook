-- E.D. Tenn. memorandum of law (motion brief), DOCX engine (docs/DOCX.md): the markdown contract of
-- usage/INPUT-<id>.md -> Word. Mirrors typst/tned-motion-brief.typ: court title (with the division when the
-- filing names one), caption (parties left with right and bottom rules; the case number right), the title of the
-- paper, the body (double-spaced; first-line indent, none after a heading or a block quotation), headings
-- (level 1 centred caps, level 2 hanging, level 3 bold italic), block quotations (single-spaced, indented both
-- sides), native footnotes, the signature block kept together, and the optional certificate of service.
-- Styles come from reference.docx (build-reference.sh). Content-agnostic: every word comes from the sample.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- one paragraph of plain text in a named style (cover, caption, signature, certificate)
local function rp(style, text, bold)
  local rpr = bold and "<w:rPr><w:b/></w:rPr>" or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr><w:r>' .. rpr
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>"
end

-- an empty paragraph of an exact height in twips (the typst v() gaps)
local function gap_p(twips, keep)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/>' .. (keep and "<w:keepNext/>" or "")
    .. '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function wrap(block, style)
  return pandoc.Div({ block }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function tc(width, paras, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. (mar or "")
    .. "</w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

-- a borderless fixed-width table with one row of cells; the row never splits across pages
local function tbl(widths, cells)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid)
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

-- a signature-style block: a left column (2.6 in), a 0.2 in gutter, the right column (the rest)
local function two_col(left, right)
  if #left == 0 then left = { gap_p(312, true) } end
  return raw(tbl({ 3744, 288, 5328 }, {
    tc(3744, left), tc(288, { gap_p(312) }), tc(5328, right),
  }))
end

local function caption(meta)
  local left = {}
  for idx, p in ipairs(meta.caption.parties) do
    if idx > 1 then left[#left + 1] = rp("Single", "v.") end
    for _, n in ipairs(p.names) do left[#left + 1] = rp("Single", str(n)) end
    left[#left + 1] = rp("Single", str(p.designation))
  end
  local right = { rp("Single", "No. " .. str(meta.case_number)) }
  return raw(tbl({ 4608, 360, 4392 }, {
    tc(4608, left,
      '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
      '<w:tcMar><w:bottom w:w="202" w:type="dxa"/><w:right w:w="202" w:type="dxa"/></w:tcMar>'),
    tc(360, { gap_p(312) }),
    tc(4392, right, nil, '<w:tcMar><w:left w:w="202" w:type="dxa"/></w:tcMar>'),
  }))
end

local function sig_lines(meta)
  local sig = meta.signature
  local lines = { rp("Single", "Respectfully submitted,") }
  for _, l in ipairs(sig.firm or {}) do lines[#lines + 1] = rp("Single", str(l)) end
  lines[#lines + 1] = rp("Single", "By: /s/ " .. str(sig.by))
  for _, a in ipairs(sig.attorneys or {}) do
    local head = str(a.name)
    if a.bpr then head = head .. ", " .. str(a.bpr) end
    lines[#lines + 1] = rp("Single", head)
    for _, l in ipairs(a.lines or {}) do lines[#lines + 1] = rp("Single", str(l)) end
  end
  lines[#lines + 1] = rp("Single", str(sig.role))
  return lines
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court title (single spaced), caption, title of the paper, then the body
  local court = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF TENNESSEE" }
  if meta.division then court[#court + 1] = string.upper(str(meta.division)) end
  for _, l in ipairs(court) do add(raw(rp("Centered", l, true))) end
  add(raw(gap_p(492)))
  add(caption(meta))
  add(raw(gap_p(324)))
  add(raw(rp("TitleLine", string.upper(str(meta.title)))))
  add(raw(gap_p(324)))

  -- body: the first paragraph, and any paragraph after a heading or a block quotation, is not indented
  local blocks = doc.blocks
  local prev = nil
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      local first = prev == nil or prev == "Header" or prev == "BlockQuote"
      add(wrap(b, first and "First Paragraph" or "Body Text"))
    else
      add(b)
    end
    prev = b.t
  end

  -- signature block (unbreakable, after the last paragraph; no space above, as in the typst template)
  add(two_col({}, (function()
    local lines = sig_lines(meta)
    -- keep the whole block together: every line but the last keeps with the next
    for i = 1, #lines - 1 do lines[i] = lines[i]:gsub('<w:pPr><w:pStyle w:val="Single"/>',
      '<w:pPr><w:pStyle w:val="SingleKeep"/>', 1) end
    return lines
  end)()))

  -- certificate of service (optional): heading, text, recipients and the signature, kept together
  local c = meta.certificate_of_service
  if c then
    add(raw(gap_p(816)))
    add(raw(rp("TitleLine", "CERTIFICATE OF SERVICE")))
    add(raw(gap_p(324, true)))
    add(raw(rp("BodyEnd", str(c.text))))
    add(raw(gap_p(324, true)))
    local cert = {}
    for _, r in ipairs(c.recipients or {}) do
      for _, l in ipairs(r) do cert[#cert + 1] = rp("Single", str(l)) end
    end
    cert[#cert + 1] = rp("Single", "By: /s/ " .. str(c.by))
    cert[#cert + 1] = rp("Single", str(c.by))
    add(two_col({}, cert))
  end

  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end
