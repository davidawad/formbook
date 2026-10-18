-- S.D. Ohio pleading, DOCX engine (docs/DOCX.md): the markdown contract of usage/INPUT-<id>.md -> Word.
-- Mirrors typst/ohsd-*.typ: court title, caption table (parties left with right and bottom rules; case
-- number, judge, title and legend right), numbered allegations (Fed. R. Civ. P. 10(b)), lettered items
-- (prayer for relief), signature blocks kept together (cantSplit rows, keepNext on the closing paragraph),
-- the motion's own signature and a new page before the memorandum (motion-brief), and the certificate of
-- service. Styles come from reference.docx (build-reference.sh). Content-agnostic: every word comes from
-- the sample's frontmatter.

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

local function empty_p(style)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>'
end

-- an empty paragraph of an exact height in twips (the typst v() gaps)
local function gap_p(twips, keep)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/>' .. (keep and "<w:keepNext/>" or "") .. '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function wrap(block, style)
  return pandoc.Div({ block }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function tc(width, paras, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. (mar or "")
    .. "</w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

-- a borderless fixed-width table with one row of cells; a row never splits across pages
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

-- the signature block: "Dated:" on the left (optional), the firm's lines on the right (2.9 in | 0.2 in | 3.4 in)
local function signature(left, right)
  if #left == 0 then left = { empty_p("Single") } end
  return raw(tbl({ 4176, 288, 4896 }, {
    tc(4176, left), tc(288, { empty_p("Single") }), tc(4896, right),
  }))
end

-- "Respectfully submitted," then the firm's lines (the right column of a signature block)
local function sig_lines(meta)
  local lines = { rp("Single", "Respectfully submitted,"), gap_p(204) }
  for _, l in ipairs(meta.signature.lines) do lines[#lines + 1] = rp("Single", str(l)) end
  return lines
end

local function caption(meta)
  local left = {}
  for idx, p in ipairs(meta.caption.parties) do
    if idx == 2 then left[#left + 1] = rp("Single", "v.") end
    for _, n in ipairs(p.names) do left[#left + 1] = rp("Single", str(n)) end
    left[#left + 1] = rp("Single", str(p.designation))
  end
  local right = { rp("Single", "Case No. " .. str(meta.case_number)) }
  if meta.judge then right[#right + 1] = rp("Single", str(meta.judge)) end
  right[#right + 1] = gap_p(40)
  right[#right + 1] = rp("Single", str(meta.brief_title), true)
  if meta.legend then right[#right + 1] = rp("Single", string.upper(str(meta.legend)), true) end
  return raw(tbl({ 4752, 288, 4320 }, {
    tc(4752, left,
      '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
      '<w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'),
    tc(288, { empty_p("Single") }),
    tc(4320, right, nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'),
  }))
end

function Pandoc(doc)
  local meta = doc.meta
  local numbered = meta.numbered == true
  local unnumbered = {}
  if meta.unnumbered then
    for _, t in ipairs(meta.unnumbered) do unnumbered[str(t)] = true end
  end
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function blank(keep) add(raw(empty_p(keep and "BlankKeep" or "Blank"))) end

  -- cover: court, division, caption, title of the paper
  local court = { "UNITED STATES DISTRICT COURT", "SOUTHERN DISTRICT OF OHIO" }
  if meta.division then court[#court + 1] = str(meta.division) end
  for _, l in ipairs(court) do add(raw(rp("Centered", l, true))) end
  add(raw(gap_p(140)))
  add(caption(meta))
  add(raw(gap_p(324)))

  -- body
  local count, numnow = 0, numbered
  local blocks = doc.blocks
  local last = #blocks
  for i, b in ipairs(blocks) do
    local keep = (i == last)
    if b.t == "Header" then
      local title = str(b.content)
      numnow = numbered and not unnumbered[title]
      if meta.new_page_before and title == str(meta.new_page_before) then
        add(raw('<w:p><w:pPr><w:pStyle w:val="Heading1"/><w:pageBreakBefore/></w:pPr><w:r><w:t xml:space="preserve">'
          .. esc(title) .. "</w:t></w:r></w:p>"))
      else
        add(b)
      end
    elseif b.t == "Para" and str(b):match("^[A-Z]%. ") then
      add(wrap(b, keep and "LetteredEnd" or "LetteredKeep"))
    elseif b.t == "Para" and numnow then
      count = count + 1
      local content = { pandoc.Str(count .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
      for _, x in ipairs(b.content) do content[#content + 1] = x end
      add(wrap(pandoc.Para(content), keep and "AllegationEnd" or "Allegation"))
    elseif b.t == "Para" then
      local before_lettered = blocks[i + 1] ~= nil and blocks[i + 1].t == "Para" and str(blocks[i + 1]):match("^[A-Z]%. ") ~= nil
      add((keep or before_lettered) and wrap(b, "BodyEnd") or b)
    elseif b.t == "OrderedList" and tostring(b.listAttributes.style) == "UpperAlpha" then
      -- markdown "A. text" items: the letter is kept, the items are set unnumbered and indented
      local start = b.listAttributes.start
      for j, item in ipairs(b.content) do
        local first = item[1]
        local content = { pandoc.Str(string.char(64 + start + j - 1) .. "."), pandoc.Space() }
        if first and (first.t == "Para" or first.t == "Plain") then
          for _, x in ipairs(first.content) do content[#content + 1] = x end
        end
        local closing = keep and j == #b.content
        local style = closing and "LetteredEnd" or (j < #b.content and "LetteredKeep" or "Lettered")
        add(wrap(pandoc.Para(content), style))
      end
    else
      add(b)
    end
    -- the motion's own signature follows its first paragraph (motion_signature), undated
    if i == 1 and meta.motion_signature == true and b.t == "Para" then
      add(raw(gap_p(164)))
      add(signature({}, sig_lines(meta)))
    end
  end

  -- closing signature, kept with the last paragraph (one unbreakable block)
  local dated = {}
  if meta.date then dated[#dated + 1] = rp("Single", "Dated: " .. str(meta.date)) end
  add(raw(gap_p(164, true)))
  add(signature(dated, sig_lines(meta)))

  -- certificate of service: heading and text kept together, then its signature
  if meta.certificate then
    blank(false)
    add(raw(rp("CenteredKeep", "CERTIFICATE OF SERVICE", true)))
    blank(true)
    add(raw(rp("BodyText", str(meta.certificate.text))))
    add(raw(gap_p(164)))
    local cert_lines = {}
    for _, l in ipairs(meta.certificate.lines) do cert_lines[#cert_lines + 1] = rp("Single", str(l)) end
    add(signature({}, cert_lines))
  end
  add(raw(gap_p(20)))

  doc.meta.date = nil
  doc.blocks = out
  return doc
end
