-- E.D. Tenn. complaint, DOCX engine (docs/DOCX.md): the markdown contract of usage/INPUT-<id>.md -> Word.
-- Mirrors typst/tned-complaint.typ: court title (with the division when the filing names one), caption
-- (parties left with right and bottom rules; case number, and the title right), the lead-in, numbered
-- paragraphs (Fed. R. Civ. P. 10(b)), lettered items (a), (b), ... for lists, WHEREFORE lead-ins unnumbered,
-- headings sticky, and the signature block kept together. Styles come from reference.docx (build-reference.sh).
-- Content-agnostic: every word comes from the sample's frontmatter or body.

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

-- one paragraph of plain text in a named style (cover, caption, signature)
local function rp(style, text, bold)
  local rpr = bold and "<w:rPr><w:b/></w:rPr>" or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr><w:r>' .. rpr
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>"
end

-- an empty paragraph of an exact height in twips (the typst v() gaps)
local function gap_p(twips)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
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

-- the signature block: "Dated:" on the left (3.0 in, 0.2 in gutter, the rest on the right)
local function signature(left, right)
  if #left == 0 then left = { gap_p(312) } end
  return raw(tbl({ 3744, 288, 5328 }, {
    tc(3744, left), tc(288, { gap_p(312) }), tc(5328, right),
  }))
end

local function sig_lines(meta)
  local sig = meta.signature
  local lines = { rp("Single", "Respectfully submitted,") }
  local firm = {}
  for _, l in ipairs(sig.firm or {}) do firm[#firm + 1] = str(l) end
  for _, l in ipairs(firm) do lines[#lines + 1] = rp("Single", l) end
  lines[#lines + 1] = rp("Single", "By: /s/ " .. str(sig.signer))
  lines[#lines + 1] = rp("Single", str(sig.signer))
  if sig.bpr then lines[#lines + 1] = rp("Single", str(sig.bpr)) end
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = rp("Single", str(l)) end
  lines[#lines + 1] = rp("Single", str(sig.role))
  return lines
end

local function caption(meta)
  local left = {}
  for idx, p in ipairs(meta.caption.parties) do
    if idx > 1 then left[#left + 1] = rp("Single", "v.") end
    for _, n in ipairs(p.names) do left[#left + 1] = rp("Single", str(n)) end
    left[#left + 1] = rp("Single", str(p.designation))
  end
  local right = {
    rp("Single", "Case No. " .. str(meta.case_number)),
    gap_p(33),
    rp("CaptionTitle", str(meta.title)),
  }
  return raw(tbl({ 4608, 360, 4392 }, {
    tc(4608, left,
      '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
      '<w:tcMar><w:bottom w:w="202" w:type="dxa"/><w:right w:w="202" w:type="dxa"/></w:tcMar>'),
    tc(360, { gap_p(312) }),
    tc(4392, right, nil, '<w:tcMar><w:left w:w="202" w:type="dxa"/></w:tcMar>'),
  }))
end

-- a numbered or lettered paragraph is one BodyText-based block; the number is followed by a tab
local function numbered_para(n, inlines, style)
  local content = { pandoc.Str(n), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
  for _, x in ipairs(inlines) do content[#content + 1] = x end
  return wrap(pandoc.Para(content), style)
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court title (single spaced), gap, caption, gap, lead-in
  local court = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF TENNESSEE" }
  if meta.division then court[#court + 1] = string.upper(str(meta.division)) end
  for _, l in ipairs(court) do add(raw(rp("Centered", l, true))) end
  add(raw(gap_p(168)))
  add(caption(meta))
  add(raw(gap_p(20)))
  if meta.lead_in then
    add(wrap(pandoc.Para(meta.lead_in), "Body Text"))
  end

  local count = 0
  local blocks = doc.blocks
  local last = #blocks
  for i, b in ipairs(blocks) do
    local keep = (i == last)
    if b.t == "Header" then
      -- headings keep with what follows (keepNext in the styles); the level picks the style
      add(b)
    elseif b.t == "Para" and str(b):match("^WHEREFORE") then
      add(wrap(b, "BodyEnd"))
    elseif b.t == "Para" then
      count = count + 1
      add(numbered_para(count .. ".", b.content, keep and "AllegationEnd" or "Allegation"))
    elseif b.t == "OrderedList" then
      -- markdown "1." items are prayer or count items: set lettered (a), (b), ... (Typst enum "(a)")
      for j, item in ipairs(b.content) do
        local first = item[1]
        local inlines = {}
        if first and (first.t == "Para" or first.t == "Plain") then inlines = first.content end
        local letter = "(" .. string.char(96 + j) .. ")"
        local closing = keep and j == #b.content
        add(numbered_para(letter, inlines, closing and "LetteredEnd" or "Lettered"))
      end
    else
      add(b)
    end
  end

  -- signature block, kept together
  local dated = {}
  if meta.signature and meta.signature.date then
    dated[#dated + 1] = rp("Single", "Dated: " .. str(meta.signature.date))
  end
  add(raw(gap_p(470)))
  add(signature(dated, sig_lines(meta)))

  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end
