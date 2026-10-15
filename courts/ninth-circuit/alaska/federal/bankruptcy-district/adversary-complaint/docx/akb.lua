-- Adversary complaint, Bankruptcy Court for the District of Alaska (akb), DOCX engine (docs/DOCX.md).
-- The markdown contract -> a Word document on docx/reference.docx. The cover (counsel block, court title, caption,
-- title of the paper), the consent statement and the signature block are built here as paragraphs and one table
-- in the custom styles of the reference; the body keeps its markdown structure, with the allegations numbered
-- here (Fed. R. Civ. P. 10(b), applied by FRBP 7010) and the relief items lettered (A., B., ...) as in typst/.
-- Everything case-specific comes from the sample's frontmatter, never from this file.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- a single paragraph: style, direct pPr (in schema order, after pStyle), text, bold
local function para(style, text, ppr, bold)
  local body = (text ~= nil and text ~= "") and run(text, bold) or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. body .. '</w:p>'
end

local function sp(before, after, line, rule)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. line .. '" w:lineRule="' .. rule .. '"/>'
end

local GRID = { 4752, 360, 4248 } -- party column 3.3 in, gutter 0.25 in, rest 2.95 in (6.5 in text width)

local function cell(w, inner, bottom_rule)
  local b = bottom_rule and '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' or ''
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. b .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function borderless_table(rows)
  return '<w:tbl><w:tblPr><w:tblStyle w:val="TableNormal"/><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. GRID[1] .. '"/><w:gridCol w:w="' .. GRID[2] .. '"/><w:gridCol w:w="' .. GRID[3] .. '"/></w:tblGrid>'
    .. rows .. '</w:tbl>'
end

local function table_row(left, right)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(GRID[1], left.inner, left.rule)
    .. cell(GRID[2], para("Single", ""))
    .. cell(GRID[3], right)
    .. '</w:tr>'
end

-- caption (FRBP 9004(b), Official Form 416D layout): each party group is a left cell ruled below, the case
-- numbers beside it; "v." between the groups (typst/akb-adversary-complaint.typ, caption())
local function caption(parties)
  local rows = {}
  for k, p in ipairs(parties) do
    if k > 1 then
      rows[#rows + 1] = table_row({ inner = para("Single", "v.", sp(40, 0, 276, "exact") .. '<w:ind w:left="1728"/>') },
        para("Single", ""))
    end
    local left = ""
    if p.lead then left = left .. para("Single", plain(p.lead)) end
    for _, n in ipairs(p.names or {}) do left = left .. para("Single", plain(n)) end
    left = left .. para("Single", plain(p.designation), sp(40, 40, 276, "exact") .. '<w:jc w:val="right"/>')
    local right = ""
    for _, r in ipairs(p.right or {}) do right = right .. para("Single", plain(r), '<w:ind w:left="144"/>') end
    if right == "" then right = para("Single", "") end
    rows[#rows + 1] = table_row({ inner = left, rule = true }, right)
  end
  return raw(borderless_table(table.concat(rows)))
end

local function centered_bold(text, before, after)
  return raw(para("Centered", text, sp(before, after, 276, "exact"), true))
end

local function is_table_caption(b)
  return b.t == "Para" and plain(b.content):match("^Table %d") ~= nil and #plain(b.content) < 40
end

local function relief_item(label, blocks)
  local inl = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
  local first = blocks[1]
  if first and (first.t == "Para" or first.t == "Plain") then
    inl:extend(first.content)
    blocks = { table.unpack(blocks, 2) }
  end
  local out = { pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Relief" })) }
  for _, b in ipairs(blocks) do out[#out + 1] = b end
  return out
end

local function bold_header(tbl)
  if not tbl.head or not tbl.head.rows then return tbl end
  for _, row in ipairs(tbl.head.rows) do
    for _, c in ipairs(row.cells) do
      c.contents = c.contents:walk({
        Para = function(p) p.content = { pandoc.Strong(p.content) }; return p end,
        Plain = function(p) p.content = { pandoc.Strong(p.content) }; return p end,
      })
    end
  end
  return tbl
end

function Pandoc(doc)
  local meta = doc.meta
  if meta.consent == nil then
    error("akb: FRBP 7008(a) and LBR 7012-1 require a consent statement (frontmatter: consent)", 0)
  end
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- counsel block (LBR 9004-1(c)(2)(A)-(B)): top left, single spaced
  for _, l in ipairs(meta.counsel or {}) do add(raw(para("Single", plain(l)))) end

  -- court title (FRBP 9004(b)(1)): two bold centered lines, a double line above and below
  add(centered_bold("IN THE UNITED STATES BANKRUPTCY COURT", 360, 0))
  add(centered_bold("FOR THE DISTRICT OF ALASKA", 0, 360))

  add(caption(meta.caption.parties))

  -- title of the paper, and its subtitle
  add(centered_bold(plain(meta.brief_title):upper(), 480, 0))
  if meta.brief_subtitle then add(raw(para("Centered", plain(meta.brief_subtitle), sp(120, 600, 276, "exact")))) end

  if meta.lead_in then
    add(pandoc.Div({ pandoc.Para(meta.lead_in) }, pandoc.Attr("", {}, { ["custom-style"] = "LeadIn" })))
  end

  -- body: allegations numbered 1, 2, ...; headings, tables, table captions, quotations and lists unnumbered
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and not is_table_caption(b) then
      n = n + 1
      local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
      inl:extend(b.content)
      add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" })))
    elseif is_table_caption(b) then
      add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "TableTitle" })))
    elseif b.t == "Table" then
      add(bold_header(b))
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        for _, x in ipairs(relief_item(string.char(64 + i) .. ".", item)) do add(x) end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, x in ipairs(relief_item("\u{2022}", item)) do add(x) end
      end
    else
      add(b)
    end
  end

  -- statement of consent (FRBP 7008(a); LBR 7012-1): required in every complaint, unnumbered
  add(raw(para("Single", "STATEMENT REGARDING CONSENT", '<w:keepNext/>' .. sp(480, 0, 480, "exact"), true)))
  add(pandoc.Div({ pandoc.Para(meta.consent) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" })))

  -- signature block (LBR 9004-1(a)(9): names typed beneath signatures); date at left when given
  add(raw(para("Single", "", sp(480, 0, 276, "exact"))))
  local right = ""
  for _, l in ipairs(meta.signature.firm or {}) do right = right .. para("Single", plain(l)) end
  right = right .. para("Single", "", sp(0, 120, 276, "exact"))
  for _, l in ipairs(meta.signature.lines or {}) do right = right .. para("Single", plain(l)) end
  right = right .. para("Single", "/s/ " .. plain(meta.signature.signer), sp(240, 0, 276, "exact"))
  right = right .. para("Single", plain(meta.signature.signer))
  local left = para("Single", meta.date and ("Dated: " .. plain(meta.date)) or "")
  add(raw(borderless_table(table_row({ inner = left }, right))))

  doc.meta.date = nil
  doc.blocks = out
  return doc
end
