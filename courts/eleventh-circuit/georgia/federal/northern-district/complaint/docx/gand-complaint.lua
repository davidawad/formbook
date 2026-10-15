-- gand-complaint.lua: pandoc filter for the N.D. Ga. complaint, docx engine (docs/DOCX.md).
-- The same content and frontmatter contract as typst/gand-complaint.typ, written as pandoc blocks and one
-- raw WordprocessingML caption table. Styles (fonts, spacing, indents, the page footer) come from
-- reference.docx; make-reference.sh builds it. Rules: N.D. Ga. LR 5.1(C), (D), (E), (G), (J), (K); Fed. R. Civ. P. 10(a), 10(b).
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

local TWIPS_CAPTION_PARTY = 4608 -- 3.2 in, the party column
local TWIPS_CAPTION_PAREN = 504 -- 0.35 in, the column of ")" marks
local TWIPS_CAPTION_RIGHT = 4248 -- the rest of the 6.5 in text width
local TWIPS_DESIGNATION = 2160 -- 1.5 in, the indent of "Plaintiff," and "Defendant."

local function need(meta, key)
  if meta[key] == nil then error("gand-complaint: frontmatter field `" .. key .. "` is required") end
  return meta[key]
end

local function str(m) return pandoc.utils.stringify(m) end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- A paragraph in a named paragraph style (a custom-style Div; the style is in reference.docx).
local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function words(s)
  return pandoc.Inlines({ pandoc.Str(s) })
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- One caption paragraph inside a table cell. opts: indent (twips), before (twips).
local function cap_p(text, opts)
  opts = opts or {}
  local spacing = opts.before and ('<w:spacing w:before="' .. opts.before .. '" w:after="0" w:line="392" w:lineRule="exact"/>') or ""
  local ind = (opts.indent or 0) > 0 and ('<w:ind w:left="' .. opts.indent .. '"/>') or ""
  return '<w:p><w:pPr><w:pStyle w:val="GANDCaption"/>' .. spacing .. ind .. '</w:pPr><w:r><w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>"
end

-- The caption (Fed. R. Civ. P. 10(a)): party lines on the left, a column of ")" marks, the case number on the
-- right, centred vertically. Each party line is one table row of exact height, so the ")" marks line up.
local function caption_table(meta)
  local cap = need(meta, "caption")
  local lines = {}
  for k, p in ipairs(need(cap, "parties")) do
    if k > 1 then lines[#lines + 1] = { text = "v.", indent = 0 } end
    for _, n in ipairs(need(p, "names")) do lines[#lines + 1] = { text = str(n), indent = 0 } end
    lines[#lines + 1] = { text = str(need(p, "designation")), indent = TWIPS_DESIGNATION }
  end
  local case_no = (meta.case_number and str(meta.case_number) ~= "") and str(meta.case_number) or "______________"
  local right = { { text = "Civil Action No. " .. case_no } }
  if meta.jury_demand then right[#right + 1] = { text = "JURY TRIAL DEMANDED", before = 392 } end

  local rows = {}
  for i, l in ipairs(lines) do
    local right_cell
    if i == 1 then
      local ps = {}
      for _, r in ipairs(right) do ps[#ps + 1] = cap_p(r.text, { before = r.before }) end
      right_cell = '<w:tc><w:tcPr><w:tcW w:w="' .. TWIPS_CAPTION_RIGHT .. '" w:type="dxa"/><w:vMerge w:val="restart"/><w:vAlign w:val="center"/></w:tcPr>' .. table.concat(ps) .. "</w:tc>"
    else
      right_cell = '<w:tc><w:tcPr><w:tcW w:w="' .. TWIPS_CAPTION_RIGHT .. '" w:type="dxa"/><w:vMerge/></w:tcPr><w:p><w:pPr><w:pStyle w:val="GANDCaption"/></w:pPr></w:p></w:tc>'
    end
    rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="392" w:hRule="exact"/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. TWIPS_CAPTION_PARTY .. '" w:type="dxa"/></w:tcPr>' .. cap_p(l.text, { indent = l.indent }) .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. TWIPS_CAPTION_PAREN .. '" w:type="dxa"/></w:tcPr>' .. cap_p(")") .. "</w:tc>"
      .. right_cell .. "</w:tr>"
  end

  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>' .. none .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. TWIPS_CAPTION_PARTY .. '"/><w:gridCol w:w="' .. TWIPS_CAPTION_PAREN .. '"/><w:gridCol w:w="' .. TWIPS_CAPTION_RIGHT .. '"/></w:tblGrid>'
    .. table.concat(rows) .. "</w:tbl>")
end

-- Cover: the three-line court title, the caption, the title of the paper (Fed. R. Civ. P. 10(a)).
local function cover(meta)
  local division = str(need(meta, "division"))
  return {
    styled("GAND Court Title", words("IN THE UNITED STATES DISTRICT COURT")),
    styled("GAND Court Title", words("FOR THE NORTHERN DISTRICT OF GEORGIA")),
    styled("GAND Court Title Last", words(division:upper() .. " DIVISION")),
    caption_table(meta),
    styled("GAND Cover Title", words(str(need(meta, "title")))),
  }
end

-- LR 5.1(G): name, complete address, telephone, email and bar number on every document.
local function signature(meta)
  local s = need(meta, "signature")
  local attorneys = need(s, "attorneys")
  assert(#attorneys > 0, "gand-complaint: LR 5.1(G) needs at least one attorney block")
  for _, a in ipairs(attorneys) do
    for _, k in ipairs({ "name", "bar", "email" }) do
      if a[k] == nil then error("gand-complaint: LR 5.1(G) needs `" .. k .. "` for every attorney") end
    end
  end
  local out = { styled("GAND Signature Lead", words("Dated: " .. str(need(meta, "date")))) }
  out[#out + 1] = styled("GAND Signature Block Lead", words("/s/ " .. str(need(s, "signer"))))
  for _, a in ipairs(attorneys) do
    out[#out + 1] = styled("GAND Signature Block", words(str(a.name) .. ", Georgia Bar No. " .. str(a.bar)))
  end
  for i, l in ipairs(need(s, "firm")) do
    out[#out + 1] = styled(i == 1 and "GAND Signature Gap" or "GAND Signature Block", words(str(l)))
  end
  for _, l in ipairs(need(s, "address")) do out[#out + 1] = styled("GAND Signature Block", words(str(l))) end
  out[#out + 1] = styled("GAND Signature Block", words("Telephone: " .. str(need(s, "phone"))))
  for _, a in ipairs(attorneys) do out[#out + 1] = styled("GAND Signature Block", words(str(a.email))) end
  out[#out + 1] = styled("GAND Signature Gap", words(str(need(s, "role"))))
  return out
end

local function letter(i)
  return string.char(64 + i)
end

-- A list item's first paragraph, as inlines.
local function item_inlines(item)
  local b = item[1]
  if b.t == "Para" or b.t == "Plain" then return b.content end
  error("gand-complaint: a list item must start with a paragraph")
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end
  if meta.lead_in then blocks[#blocks + 1] = pandoc.Para(meta.lead_in) end

  -- Body. A paragraph is numbered (Fed. R. Civ. P. 10(b)) unless it starts with the unnumbered marker "^^ ",
  -- which pandoc reads as an empty superscript followed by a space. Ordered lists are the lettered prayer items.
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local first = b.content[1]
      if first and first.t == "Superscript" and #first.content == 0 and b.content[2] and b.content[2].t == "Space" then
        local rest = pandoc.Inlines({})
        for i = 3, #b.content do rest:insert(b.content[i]) end
        blocks[#blocks + 1] = pandoc.Para(rest)
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        for _, x in ipairs(b.content) do inl:insert(x) end
        blocks[#blocks + 1] = styled("GAND Numbered", inl)
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.Str(letter(i) .. "."), TAB })
        for _, x in ipairs(item_inlines(item)) do inl:insert(x) end
        blocks[#blocks + 1] = styled("GAND Lettered", inl)
      end
    else
      blocks[#blocks + 1] = b
    end
  end

  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end

  -- pandoc writes the title, date and author metadata as a title block at the top of the document; the cover
  -- above already carries them, so they are dropped here.
  local out_meta = {}
  for k, v in pairs(meta) do out_meta[k] = v end
  out_meta.title, out_meta.subtitle, out_meta.author, out_meta.date = nil, nil, nil, nil
  return pandoc.Pandoc(blocks, out_meta)
end
