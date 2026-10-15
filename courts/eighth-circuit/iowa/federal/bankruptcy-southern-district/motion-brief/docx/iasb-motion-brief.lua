-- iasb motion with supporting brief, docx engine. Mirrors typst/iasb-motion-brief.typ; rules and conventions are in
-- ../README.md (Engines). The cover (court name, caption with the label and the hearing line), the numbered paragraphs,
-- the headings, the lettered items, the signature block, the verifications and the certificate of service are built
-- here. Font, spacing, margins and the page number are styles and section settings in reference.docx
-- (make-reference.sh). Footnotes are pandoc's native footnotes (style "footnote text", 10 pt).
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

-- Inline markdown of a string.
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

-- The blocks of a metadata value: a YAML block scalar is a Blocks list (paragraphs and lists kept); a single line
-- is an Inlines list, which becomes one paragraph.
local function blocks_of(v)
  if v.t == "MetaBlocks" or pandoc.utils.type(v) == "Blocks" then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b end
    return out
  end
  if pandoc.utils.type(v) == "Inlines" then return { pandoc.Para(inlines_of(v)) } end
  return pandoc.read(txt(v), "markdown").blocks
end

-- A raw WordprocessingML paragraph. o: style, after (twips), before (twips), left (twips), jc, bold.
local function p(text, o)
  o = o or {}
  local ppr = '<w:pPr><w:pStyle w:val="' .. (o.style or "SingleSpaced") .. '"/>'
  if o.before or o.after then
    ppr = ppr .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '" w:line="240" w:lineRule="auto"/>'
  end
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
local function table_xml(widths, cells)
  local grid = ""
  local total = 0
  for _, w in ipairs(widths) do
    grid = grid .. '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  local nob = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. nob
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. grid .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells, "") .. "</w:tr></w:tbl>"
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>" .. inner .. "</w:tc>"
end

-- The lines of a stack: 6 pt between lines (after = 120), none after the last one.
local function stack(lines, o)
  local out = ""
  for i, line in ipairs(lines) do
    local after = i < #lines and 120 or 0
    local opts = { after = after, left = o and o.left, jc = o and o.jc, bold = o and o.bold, style = o and o.style }
    out = out .. p(line, opts)
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption (debtor on the left; case number, chapter, the label, the title and the hearing on the right)
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = { p("UNITED STATES BANKRUPTCY COURT", { style = "CourtName" }), p("SOUTHERN DISTRICT OF IOWA", { style = "CourtName", after = 360 }) }

  local left = { "In re:" }
  for _, d in ipairs(strs(m.debtors)) do left[#left + 1] = d end
  left[#left + 1] = txt(m.debtor_role)

  local right = { "Case No. " .. txt(m.case_number), "Chapter " .. txt(m.chapter) }
  if m.adv_number and txt(m.adv_number) ~= "" then right[#right + 1] = "Adv. Proc. No. " .. txt(m.adv_number) end
  local label = txt(m.label)
  local hearing = txt(m.hearing)
  local right_xml = stack(right, { left = 144 })
  if label ~= "" then right_xml = right_xml .. p(label, { left = 144, bold = true, before = 0, after = 0 }) end
  right_xml = right_xml .. p(txt(m.brief_title), { left = 144, bold = true, before = 240, after = hearing ~= "" and 240 or 0 })
  if hearing ~= "" then right_xml = right_xml .. p(hearing, { left = 144 }) end

  local borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local mar = '<w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = table_xml({ 4896, 360, 4104 }, {
    cell(4896, stack(left), borders .. mar),
    cell(360, p("")),
    cell(4104, right_xml),
  })
  out[#out + 1] = spacer()
  return table.concat(out, "")
end

-- ---------------------------------------------------------------------------
-- Signature block: the date on the left; the electronic signature and counsel lines on the right (FRBP 9011(a))
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local right = { "/s/ " .. txt(s.signer) }
  for _, l in ipairs(strs(s.lines)) do right[#right + 1] = l end
  return spacer() .. table_xml({ 4032, 288, 5040 }, {
    cell(4032, p("Dated: " .. txt(m.date))),
    cell(288, p("")),
    cell(5040, stack(right)),
  })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A numbered paragraph: the number, a tab to the text, and the text.
local function numbered(n, content)
  local inl = { pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. n .. '.</w:t></w:r><w:r><w:tab/></w:r>') }
  for _, i in ipairs(content) do inl[#inl + 1] = i end
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Numbered Paragraph" })
end

-- The title of a verification or certificate, in capitals.
local function upper_title(v)
  return txt(v):upper()
end

-- A verification (a declaration under penalty of perjury): its title, its numbered body, and its signature.
local function declaration(d)
  local out = { pandoc.RawBlock("openxml", p(upper_title(d.title), { style = "Heading1", before = 480, after = 240 })) }
  for _, b in ipairs(blocks_of(d.body)) do
    if b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = numbered(b.start + i - 1, pandoc.utils.blocks_to_inlines(item))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Indented Paragraph" })
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = pandoc.RawBlock("openxml", spacer() .. table_xml({ 4032, 288, 5040 }, {
    cell(4032, p("Dated: " .. txt(d.date))),
    cell(288, p("")),
    cell(5040, stack({ "/s/ " .. txt(d.signer), txt(d.signer) })),
  }))
  return out
end

-- The certificate of service, last in the document; its signature is set to the right of the page.
local function certificate(svc)
  return {
    pandoc.RawBlock("openxml", p(upper_title(svc.title), { style = "Heading1", before = 480, after = 240 })),
    pandoc.Div({ pandoc.Para(inlines_of(svc.text)) }, { ["custom-style"] = "Indented Paragraph" }),
    pandoc.RawBlock("openxml", spacer() .. stack({ "/s/ " .. txt(svc.signer), txt(svc.signer) }, { left = 4320 })),
  }
end

function Pandoc(doc)
  local m = doc.meta
  if not m.signature then error("iasb-motion-brief: frontmatter needs signature") end

  local out = { pandoc.RawBlock("openxml", cover(m)) }
  if m.lead_in then
    out[#out + 1] = pandoc.Div({ pandoc.Para(inlines_of(m.lead_in)) }, { ["custom-style"] = "Indented Paragraph" })
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local c = b.content
      if b.level == 1 then
        c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      out[#out + 1] = pandoc.Header(b.level, c)
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):sub(1, 9) == "WHEREFORE" then
        -- The conclusion is not numbered; it stays with the signature block that follows it.
        out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Indented Paragraph" })
      else
        n = n + 1
        out[#out + 1] = numbered(n, b.content)
      end
    elseif b.t == "BulletList" then
      -- Lettered items A., B., C. (the letter is typed text, as in the typst template).
      for i, item in ipairs(b.content) do
        local inl = { pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. string.char(64 + i) .. '.</w:t></w:r><w:r><w:tab/></w:r>') }
        for _, x in ipairs(pandoc.utils.blocks_to_inlines(item)) do inl[#inl + 1] = x end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Prayer Item" })
      end
    else
      -- The block quotation (Block Text), the table and the rest are kept as pandoc writes them.
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.RawBlock("openxml", signature(m))
  for _, d in ipairs(m.declarations or {}) do
    for _, b in ipairs(declaration(d)) do out[#out + 1] = b end
  end
  if m.service then
    for _, b in ipairs(certificate(m.service)) do out[#out + 1] = b end
  end

  -- The frontmatter was consumed above; pandoc would otherwise write its date at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
