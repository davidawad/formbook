-- New Jersey bankruptcy court (njb), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- docx/reference.docx. The cover (counsel, court, LBR 9004-1 note, caption, title), the body and the signature
-- block are built here in the order and spacing of typst/njb-<doctype>.typ; the body keeps its markdown.
-- Per-doctype settings are in CFG. Known limits (see README "Engines"): cover and signature text is plain
-- (inline markup in the frontmatter is dropped there); paragraph numbers and prayer letters are typed text.

local CFG = {
  numbered = true,              -- adversary: body paragraphs numbered 1, 2, ... (FRCP 10(b)); motion: not numbered
  page_break_after_cover = true, -- adversary: the body starts on page 2; motion: the body follows the title
  title_upper = true,            -- adversary: the title is upper case
}

local COURT = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEW JERSEY" }
local LBR = "Caption in Compliance with D.N.J. LBR 9004-1"
local TAB = '<w:r><w:tab/></w:r>'

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value as a list of plain lines
local function lines(v)
  local out = {}
  if v == nil then return out end
  if v.t == "MetaList" then
    for _, x in ipairs(v) do out[#out + 1] = txt(x) end
  else
    out[#out + 1] = txt(v)
  end
  return out
end

-- paragraph and run builders (raw WordprocessingML, for the parts that are not markdown)
local function para(style, text, o)
  o = o or {}
  local ppr = '<w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (o.ppr or '') .. '</w:pPr>'
  local run = ''
  if text ~= '' then
    run = '<w:r>' .. (o.rpr and ('<w:rPr>' .. o.rpr .. '</w:rPr>') or '') ..
      '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p>' .. ppr .. run .. '</w:p>'
end

-- an empty line of exact height: the typst v(em) spacing, in twips
local function gap(twips)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' ..
    twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local BORDER = "w:val=\"single\" w:sz=\"6\" w:space=\"0\" w:color=\"000000\""
local NO_BORDERS = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
  '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'

local function cell(width, inner, borders, margins)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' ..
    (borders and ('<w:tcBorders>' .. borders .. '</w:tcBorders>') or '') ..
    (margins and ('<w:tcMar>' .. margins .. '</w:tcMar>') or '') ..
    '</w:tcPr>' .. inner .. '</w:tc>'
end

local function table_xml(widths, cells, cant_split)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>' .. NO_BORDERS ..
    '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr>' ..
    (cant_split and '<w:trPr><w:cantSplit/></w:trPr>' or '') .. table.concat(cells) .. '</w:tr></w:tbl>'
end

-- caption: left cell closed by a right and bottom rule (typst stroke), right cell offset by the gutter
local CAP_LEFT, CAP_GUTTER, CAP_RIGHT = 4680, 360, 4320
local RULE = "<w:bottom " .. BORDER .. "/><w:right " .. BORDER .. "/>"
local LEFT_MAR = '<w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/>'
local RIGHT_MAR = '<w:left w:w="' .. (CAP_GUTTER + 144) .. '" w:type="dxa"/>'

local function cover(meta)
  local x = {}
  for _, l in ipairs(lines(meta.counsel)) do x[#x + 1] = para("Single", l) end
  x[#x + 1] = gap(336)
  for _, l in ipairs(COURT) do
    x[#x + 1] = para("Single", l, { rpr = '<w:b/>',
      ppr = '<w:spacing w:before="0" w:after="0" w:line="504" w:lineRule="exact"/><w:jc w:val="center"/>' })
  end
  x[#x + 1] = gap(168)
  x[#x + 1] = para("Single", LBR, { ppr = '<w:jc w:val="right"/>', rpr = '<w:sz w:val="22"/><w:szCs w:val="22"/>' })

  -- caption, first table: debtor block and case data
  local debtor = { para("Single", "In re:") }
  for _, l in ipairs(lines(meta.debtor)) do debtor[#debtor + 1] = para("Single", l) end
  debtor[#debtor + 1] = para("Single", "Debtor.")
  local case = { para("Single", "Case No.: " .. txt(meta.case_no)),
    para("Single", "Chapter " .. txt(meta.chapter)),
    para("Single", "Judge: " .. txt(meta.judge)) }
  if meta.hearing ~= nil then case[#case + 1] = para("Single", txt(meta.hearing)) end
  x[#x + 1] = table_xml({ CAP_LEFT, CAP_RIGHT + CAP_GUTTER }, {
    cell(CAP_LEFT, table.concat(debtor), RULE, LEFT_MAR),
    cell(CAP_RIGHT + CAP_GUTTER, table.concat(case), nil, RIGHT_MAR) })
  x[#x + 1] = gap(224)

  -- caption, second table: the parties (the "v." between them) and the adversary number
  local parties = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then parties[#parties + 1] = para("Single", "v.") end
    for _, l in ipairs(lines(p.names)) do parties[#parties + 1] = para("Single", l) end
    parties[#parties + 1] = para("Single", txt(p.designation))
  end
  x[#x + 1] = table_xml({ CAP_LEFT, CAP_RIGHT + CAP_GUTTER }, {
    cell(CAP_LEFT, table.concat(parties), RULE, LEFT_MAR),
    cell(CAP_RIGHT + CAP_GUTTER, para("Single", "Adv. Pro. No. " .. txt(meta.adv_no)), nil, RIGHT_MAR) })
  x[#x + 1] = gap(392)

  local title = txt(meta.title)
  if CFG.title_upper then title = string.upper(title) end
  x[#x + 1] = para("Single", title, { rpr = '<w:b/>', ppr = '<w:jc w:val="center"/>' })
  if CFG.page_break_after_cover then
    x[#x + 1] = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr>' ..
      '<w:r><w:br w:type="page"/></w:r></w:p>'
  else
    x[#x + 1] = gap(168)
  end
  return table.concat(x)
end

local function signature(meta)
  local left = para("Single", "Dated: " .. txt(meta.date))
  local r = { para("Single", "Respectfully submitted,"), gap(168) }
  for _, l in ipairs(lines(meta.signature.firm)) do r[#r + 1] = para("Single", l) end
  r[#r + 1] = gap(168)
  r[#r + 1] = para("Single", "/s/ " .. txt(meta.signature.signer))
  for _, l in ipairs(lines(meta.signature.lines)) do r[#r + 1] = para("Single", l) end
  return gap(336) .. table_xml({ 4176, 5184 }, {
    cell(4176, left),
    cell(5184, table.concat(r), nil, '<w:left w:w="288" w:type="dxa"/>') }, true)
end

local function tabbed(first, inl, style)
  local content = { pandoc.Str(first), pandoc.RawInline("openxml", TAB) }
  for _, x in ipairs(inl) do content[#content + 1] = x end
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function body(blocks)
  local out, n = {}, 0
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      local s = pandoc.utils.stringify(b)
      if s:match("^%[") then
        -- a bracketed note of the transcription: centered and italic, not numbered
        out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, pandoc.Attr("", {}, { ["custom-style"] = "Note" }))
      elseif s:match("^WHEREFORE") or not CFG.numbered then
        -- unnumbered: the prayer lead-in, and every paragraph of the motion
        out[#out + 1] = b
      else
        n = n + 1
        out[#out + 1] = tabbed(n .. ".", b.content, "Numbered")
      end
    elseif b.t == "OrderedList" and CFG.numbered then
      -- prayer items are lettered (a), (b), ... as in the typst template
      for k, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          out[#out + 1] = tabbed("(" .. string.char(96 + k) .. ")", first.content, "Lettered")
          for j = 2, #item do out[#out + 1] = item[j] end
        else
          for _, sub in ipairs(item) do out[#out + 1] = sub end
        end
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  -- the title and date are typeset below from the frontmatter; pandoc must not add its own title block
  meta.title = nil
  meta.date = nil
  local blocks = { pandoc.RawBlock("openxml", cover(meta)) }
  if meta.lead_in ~= nil then
    blocks[#blocks + 1] = pandoc.Para(meta.lead_in)
  end
  for _, b in ipairs(body(doc.blocks)) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", signature(meta))
  doc.blocks = blocks
  return doc
end
