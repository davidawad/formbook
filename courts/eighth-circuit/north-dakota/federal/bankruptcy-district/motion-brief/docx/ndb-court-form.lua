-- ndb-court-form.lua (docx engine): the layout the typst template (typst/ndb-*.typ) gives the sample, built from its
-- YAML frontmatter with pandoc's AST and raw OpenXML. Rules and layout values: ../README.md and reference.docx.
--   cover        court name, caption table (party column, ")" column, case block), title (the typst cover)
--   numbering    every body paragraph is numbered 1, 2, ... (FRCP 10(b)) by text, not by a list;
--                "~ ..." continuations and "WHEREFORE" paragraphs are not numbered; quotations are BlockText
--   signature    a two-column table (FRBP 9011(a)); the last numbered paragraph keeps with it
--   consent      the consent statement (FRBP 7008(a)), when the frontmatter has one, sits before the signature
--   certificate  optional certificate of service after the signature
-- Footnotes are pandoc's own (the sample's [^id] definitions). Lists are not supported, as in the typst template.

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function text_of(v)
  if v == nil then return nil end
  return pandoc.utils.stringify(v)
end

-- one paragraph of OpenXML: style id, optional text, optional left indent in twips
local function para_xml(style, text, indent)
  local ind = indent and indent > 0 and ('<w:ind w:left="' .. indent .. '" />') or ""
  local run = ""
  if text and text ~= "" then
    run = '<w:r><w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '" />' .. ind .. "</w:pPr>" .. run .. "</w:p>"
end

-- a borderless fixed-width table; cols = { { w = twips, valign = "top"|"center", xml = paragraphs }, ... }
local function table_xml(cols)
  local total, grid, cells = 0, {}, {}
  for _, c in ipairs(cols) do
    total = total + c.w
    grid[#grid + 1] = '<w:gridCol w:w="' .. c.w .. '" />'
    cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.w .. '" w:type="dxa" /><w:vAlign w:val="'
      .. (c.valign or "top") .. '" /></w:tcPr>' .. c.xml .. "</w:tc>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa" /><w:tblLayout w:type="fixed" />'
    .. '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" />'
    .. '<w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. "<w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid>"
    .. '<w:tr><w:trPr><w:cantSplit /></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- The caption rows of the left column as { text, indent level }, as caption-rows() in the typst template.
local function caption_rows(c)
  local rows = {}
  local function add(t, level) rows[#rows + 1] = { t, level } end
  if c.debtors then
    add("In re:", 0)
    for _, d in ipairs(c.debtors) do add(text_of(d), 0) end
    if c.debtor_designation then add(text_of(c.debtor_designation), 1) end
    add("", 0)
  end
  for k, p in ipairs(c.parties) do
    if k > 1 then
      add("v.", 0)
      add("", 0)
    end
    for _, n in ipairs(p.names) do add(text_of(n), 0) end
    add(text_of(p.designation), 1)
  end
  return rows
end

local function caption_table(m)
  local c = m.caption
  if c == nil then error("ndb-court-form.lua: the sample has no caption in its frontmatter") end
  local left, mid = {}, {}
  for _, r in ipairs(caption_rows(c)) do
    left[#left + 1] = para_xml("SingleSpaced", r[1], r[2] * 720)
    mid[#mid + 1] = para_xml("SingleSpaced", ")")
  end
  local right = {
    para_xml("SingleSpaced", "Case No. " .. text_of(m.case_number)),
    para_xml("SingleSpaced", text_of(m.chapter)),
    para_xml("SingleSpaced", ""),
    para_xml("SingleSpaced", "Adversary No. " .. text_of(m.adversary_number)),
  }
  -- 6.5 in text width: 3.4 in party column, 0.3 in ")" column, the rest for the case block
  return table_xml({
    { w = 4896, xml = table.concat(left) },
    { w = 432, xml = table.concat(mid) },
    { w = 4032, valign = "center", xml = table.concat(right) },
  })
end

local function signature_table(m)
  local s = m.signature
  if s == nil then error("ndb-court-form.lua: the sample has no signature in its frontmatter") end
  local items = {}
  if s.closing then
    items[#items + 1] = text_of(s.closing)
    items[#items + 1] = ""
  end
  items[#items + 1] = "By: /s/ " .. text_of(s.signer)
  items[#items + 1] = ""
  for _, l in ipairs(s.lines) do items[#items + 1] = text_of(l) end
  local right = {}
  for _, t in ipairs(items) do right[#right + 1] = para_xml("SingleSpaced", t) end
  -- 3.0 in for the date, the rest for the signer's block
  return table_xml({
    { w = 4320, xml = para_xml("SingleSpaced", "Dated: " .. text_of(m.date)) },
    { w = 5040, xml = table.concat(right) },
  })
end

local function starts_with(inlines, marker)
  local first = inlines[1]
  if first and first.t == "Str" and first.text:sub(1, #marker) == marker then
    local out = {}
    local rest = first.text:sub(#marker + 1)
    if rest ~= "" then out[#out + 1] = pandoc.Str(rest) end
    for i = 2, #inlines do out[#out + 1] = inlines[i] end
    if out[1] and out[1].t == "Space" then table.remove(out, 1) end
    return out
  end
  return nil
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local blank = raw(para_xml("BodyText", ""))

  -- cover: court name, caption, title (typst cover(): v(pitch) between the parts)
  add(raw(para_xml("CourtName", "IN THE UNITED STATES BANKRUPTCY COURT")
    .. para_xml("CourtName", "FOR THE DISTRICT OF NORTH DAKOTA")))
  add(blank)
  add(raw(caption_table(m)))
  add(blank)
  add(pandoc.Div({ pandoc.Para(m.title) }, { ["custom-style"] = "Title Line" }))
  add(blank)

  -- lead-in (unnumbered, indented), when the form has one
  if m.lead_in then
    add(pandoc.Div({ pandoc.Para(m.lead_in) }, { ["custom-style"] = "Numbered Paragraph" }))
  end

  local n = 0
  local last_numbered = nil
  local function numbered_div(inlines)
    n = n + 1
    local content = { pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>") }
    for _, i in ipairs(inlines) do content[#content + 1] = i end
    return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Numbered Paragraph" })
  end

  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" then
      local rest = starts_with(b.content, "~")
      local wherefore = b.content[1] and b.content[1].t == "Str" and b.content[1].text:sub(1, 9) == "WHEREFORE"
      if rest then
        add(pandoc.Para(rest))
      elseif wherefore then
        add(pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Numbered Paragraph" }))
      else
        last_numbered = numbered_div(b.content)
        add(last_numbered)
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      error("ndb-court-form.lua: lists are not supported by this template (as in typst/)")
    else
      add(b)
    end
  end

  -- the consent statement (complaint) and the signature stay together, as the typst template keeps them
  if m.consent_statement then
    add(pandoc.Div({ pandoc.Para(m.consent_statement) }, { ["custom-style"] = "Numbered Paragraph Keep Next" }))
  elseif last_numbered then
    last_numbered.attributes["custom-style"] = "Numbered Paragraph Keep Next"
  end
  add(blank)
  add(raw(signature_table(m)))

  if m.certificate_of_service then
    add(blank)
    add(pandoc.Div({ pandoc.Para(pandoc.Str("CERTIFICATE OF SERVICE")) }, { ["custom-style"] = "Title Line" }))
    for _, p in ipairs(m.certificate_of_service) do
      add(pandoc.Div({ pandoc.Para(p) }, { ["custom-style"] = "Numbered Paragraph" }))
    end
  end

  return pandoc.Pandoc(out)
end
