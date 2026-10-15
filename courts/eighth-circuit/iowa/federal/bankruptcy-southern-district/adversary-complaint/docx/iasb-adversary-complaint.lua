-- iasb adversary complaint, docx engine. Mirrors typst/iasb-adversary-complaint.typ; rules and conventions are in
-- ../README.md (Engines). The cover (court name, caption table, title), the two paragraphs the template generates for
-- Fed. R. Bankr. P. 7008, the numbered allegations, the lettered prayer and the signature block are built here. Font,
-- spacing, margins and the page number are styles and section settings in reference.docx (make-reference.sh).
-- Numbers are typed text, as the typst template types them, so every viewer shows the same numbering.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

-- The strings of a metadata list (or of a single metadata value). A YAML sequence is a MetaList, or a plain List
-- of inlines when pandoc has already parsed its items.
local function strs(v)
  local out = {}
  if v == nil then return out end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    for _, x in ipairs(v) do out[#out + 1] = txt(x) end
  else
    out[#out + 1] = txt(v)
  end
  return out
end

-- Inline markdown of a string (case names in italics).
local function md(s)
  local d = pandoc.read(s, "markdown")
  if d.blocks[1] then return d.blocks[1].content end
  return {}
end

-- The inlines of a metadata value, keeping its markdown (pandoc has parsed it: an Inlines list) or parsing it.
local function inlines_of(v)
  if v.t == "MetaInlines" or pandoc.utils.type(v) == "Inlines" then
    local out = {}
    for _, i in ipairs(v) do out[#out + 1] = i end
    return out
  end
  return md(txt(v))
end

-- A raw WordprocessingML paragraph. o: style, after (twips), left (twips), jc, bold.
local function p(text, o)
  o = o or {}
  local ppr = '<w:pPr><w:pStyle w:val="' .. (o.style or "SingleSpaced") .. '"/>'
  if o.after then ppr = ppr .. '<w:spacing w:before="0" w:after="' .. o.after .. '" w:line="240" w:lineRule="auto"/>' end
  if o.left then ppr = ppr .. '<w:ind w:left="' .. o.left .. '"/>' end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  ppr = ppr .. "</w:pPr>"
  local rpr = o.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local run = text ~= "" and ("<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>") or ""
  return "<w:p>" .. ppr .. run .. "</w:p>"
end

-- An empty body line: one double-spaced line (the typst template's v(body-leading)).
local function spacer()
  return '<w:p><w:pPr><w:pStyle w:val="BodyText"/></w:pPr></w:p>'
end

-- A borderless table with fixed column widths (twips); each cell is a string of paragraphs.
local function table_xml(widths, cells, borders)
  local grid = ""
  for _, w in ipairs(widths) do grid = grid .. '<w:gridCol w:w="' .. w .. '"/>' end
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local nob = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. (borders or nob)
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. grid .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells, "") .. "</w:tr></w:tbl>"
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>" .. inner .. "</w:tc>"
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption (Form 416D), title
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = { p("UNITED STATES BANKRUPTCY COURT", { style = "CourtName" }), p("SOUTHERN DISTRICT OF IOWA", { style = "CourtName", after = 360 }) }

  -- Left column: the debtor, the plaintiffs, "v.", the defendants. A group ends with 12 pt before the next one.
  local groups = {}
  local debtors = strs(m.debtors)
  local g = { "In re:" }
  for _, d in ipairs(debtors) do g[#g + 1] = d end
  g[#g + 1] = #debtors > 1 and "Debtors." or "Debtor."
  groups[#groups + 1] = g
  for _, pl in ipairs(m.caption.plaintiffs) do
    local grp = strs(pl.names)
    grp[#grp + 1] = txt(pl.designation)
    groups[#groups + 1] = grp
  end
  groups[#groups + 1] = { "v." }
  for _, df in ipairs(m.caption.defendants) do
    local grp = strs(df.names)
    grp[#grp + 1] = txt(df.designation)
    groups[#groups + 1] = grp
  end
  local left = ""
  for gi, grp in ipairs(groups) do
    for li, line in ipairs(grp) do
      local after = 120
      if li == #grp then after = gi < #groups and 240 or 0 end
      left = left .. p(line, { after = after })
    end
  end

  -- Right column: the case number, the chapter and the adversary number (blank until the clerk assigns it).
  local adv = txt(m.adv_number)
  if adv == "" then adv = "______________" end
  local right = p("Case No. " .. txt(m.case_number), { left = 144, after = 120 })
    .. p("Chapter " .. txt(m.chapter), { left = 144, after = 120 })
    .. p("Adv. Proc. No. " .. adv, { left = 144 })

  local borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local mar = '<w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = table_xml({ 4896, 360, 4104 }, {
    cell(4896, left, borders .. mar),
    cell(360, p("")),
    cell(4104, right),
  })
  out[#out + 1] = spacer()
  out[#out + 1] = p(txt(m.brief_title), { style = "SingleSpaced", jc = "center", after = 0 })
  out[#out + 1] = spacer()
  return table.concat(out, "")
end

-- ---------------------------------------------------------------------------
-- Signature block: the date on the left; the firm, the electronic signature and counsel lines on the right (FRBP 9011)
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local right = { "Respectfully submitted,", "" }
  if s.firm then
    for _, f in ipairs(strs(s.firm)) do right[#right + 1] = f end
    right[#right + 1] = ""
  end
  right[#right + 1] = "By: /s/ " .. txt(s.signer)
  right[#right + 1] = txt(s.signer)
  for _, l in ipairs(strs(s.lines)) do right[#right + 1] = l end
  local rx = ""
  for i, line in ipairs(right) do
    rx = rx .. p(line, { after = i < #right and 120 or 0 })
  end
  return spacer() .. table_xml({ 4032, 288, 5040 }, {
    cell(4032, p("Dated: " .. txt(m.date))),
    cell(288, p("")),
    cell(5040, rx),
  })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A numbered paragraph: the number, a tab to the text, and the text (Fed. R. Civ. P. 10(b)).
local function numbered(n, content)
  local inl = { pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. n .. '.</w:t></w:r><w:r><w:tab/></w:r>') }
  for _, i in ipairs(content) do inl[#inl + 1] = i end
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Numbered Paragraph" })
end

function Pandoc(doc)
  local m = doc.meta
  if not m.division then error("iasb-adversary-complaint: frontmatter needs division (FRBP 7008)") end
  if not m.final_orders_consent then error("iasb-adversary-complaint: frontmatter needs final_orders_consent (FRBP 7008)") end

  local out = { pandoc.RawBlock("openxml", cover(m)) }
  if m.lead_in then
    out[#out + 1] = pandoc.Div({ pandoc.Para(inlines_of(m.lead_in)) }, { ["custom-style"] = "Indented Paragraph" })
  end

  -- The first two numbered paragraphs come from the frontmatter (FRBP 7008): the case reference and the consent.
  local n = 0
  local case_ref = "This adversary proceeding arises in and relates to the Chapter " .. txt(m.chapter) .. " case of "
    .. table.concat(strs(m.debtors), ", ") .. ", Case No. " .. txt(m.case_number)
    .. ", pending in the United States Bankruptcy Court for the Southern District of Iowa, " .. txt(m.division) .. " Division."
  n = n + 1
  out[#out + 1] = numbered(n, md(case_ref))
  n = n + 1
  out[#out + 1] = numbered(n, inlines_of(m.final_orders_consent))

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local c = b.content
      if b.level == 1 then
        c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      out[#out + 1] = pandoc.Header(b.level, c)
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):sub(1, 9) == "WHEREFORE" then
        -- The prayer's lead-in is not numbered.
        out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Indented Paragraph" })
      else
        n = n + 1
        out[#out + 1] = numbered(n, b.content)
      end
    elseif b.t == "BulletList" then
      -- The prayer items are lettered A., B., C. (the letter is typed text, as in the typst template).
      for i, item in ipairs(b.content) do
        local inl = { pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. string.char(64 + i) .. '.</w:t></w:r><w:r><w:tab/></w:r>') }
        for _, x in ipairs(pandoc.utils.blocks_to_inlines(item)) do inl[#inl + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Prayer Item" })
      end
    else
      -- Headings, the block quotation (Block Text) and the table are kept as pandoc writes them.
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.RawBlock("openxml", signature(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its date at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
