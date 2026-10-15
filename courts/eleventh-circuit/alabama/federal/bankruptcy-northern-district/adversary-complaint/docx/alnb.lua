-- alnb.lua (docx engine, adversary complaint): what the Word output adds to pandoc's default conversion, so that it
-- prints the form of typst/alnb-adversary-complaint.typ (see ../README.md "Engines"):
--   * the court title, the caption (a borderless table: party names | ")" column | case text), the title of the paper;
--   * the consent statement (Fed. R. Bankr. P. 7008(a)) and every body paragraph except a WHEREFORE prayer numbered
--     1., 2., ... (Fed. R. Civ. P. 10(b)), with a tab after the number;
--   * the signature block after the prayer, built from the frontmatter.
-- Everything comes from the sample's frontmatter and body; nothing case-specific or measured is in this file.

local TEXT_WIDTH = 9360 -- 6.5 in in twips (letter, 1-in margins)
local CAPTION_COLS = { 4824, 576, 3960 } -- 3.35 in | 0.4 in | the rest

local function custom(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para(inlines, style)
  return custom({ pandoc.Para(inlines) }, style)
end

local function spacer()
  return custom({ pandoc.Para({}) }, "Spacer")
end

local function text_of(v)
  return pandoc.utils.stringify(v)
end

local function xml_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Designations in the caption ("Plaintiff,", "Defendants.") sit in from the left; other caption lines do not.
local designations = {
  ["Plaintiff,"] = true, ["Plaintiffs,"] = true, ["Defendant."] = true, ["Defendants."] = true,
  ["Debtor."] = true, ["Debtors."] = true, ["Movant."] = true, ["Movants."] = true,
  ["Respondent."] = true, ["Respondents."] = true,
}

local function cell(text, style, width)
  return string.format(
    '<w:tc><w:tcPr><w:tcW w:w="%d" w:type="dxa" /></w:tcPr><w:p><w:pPr><w:pStyle w:val="%s" /></w:pPr>'
      .. '<w:r><w:t xml:space="preserve">%s</w:t></w:r></w:p></w:tc>',
    width, style, xml_escape(text))
end

-- One caption block as a fixed-width table with no borders (the Table style in reference.docx has none).
local function caption_table(blk)
  local left = blk.left or {}
  local right = blk.right or {}
  local n = math.max(#left, #right)
  local rows = {}
  for i = 1, n do
    local l = left[i] and text_of(left[i]) or ""
    local r = right[i] and text_of(right[i]) or ""
    local lstyle = designations[l] and "CaptionDesignation" or "CaptionBlock"
    rows[#rows + 1] = "<w:tr><w:trPr><w:cantSplit /></w:trPr>"
      .. cell(l, lstyle, CAPTION_COLS[1])
      .. cell(")", "CaptionMid", CAPTION_COLS[2])
      .. cell(r, "CaptionBlock", CAPTION_COLS[3])
      .. "</w:tr>"
  end
  local xml = '<w:tbl><w:tblPr><w:tblStyle w:val="Table" /><w:tblW w:w="' .. TEXT_WIDTH
    .. '" w:type="dxa" /><w:tblLayout w:type="fixed" /></w:tblPr><w:tblGrid>'
    .. "<w:gridCol w:w=\"" .. CAPTION_COLS[1] .. "\" /><w:gridCol w:w=\"" .. CAPTION_COLS[2]
    .. "\" /><w:gridCol w:w=\"" .. CAPTION_COLS[3] .. "\" /></w:tblGrid>"
    .. table.concat(rows) .. "</w:tbl>"
  return pandoc.RawBlock("openxml", xml)
end

local function signature(sig)
  local out = {}
  out[#out + 1] = para({ pandoc.Str("Dated: " .. text_of(sig.date)) }, "CaptionBlock")
  out[#out + 1] = spacer()
  out[#out + 1] = para({ pandoc.Str("Respectfully submitted,") }, "Signature")
  out[#out + 1] = spacer()
  for i, s in ipairs(sig.signers or {}) do
    local inl = {}
    if i == 1 then
      inl[#inl + 1] = pandoc.Str("/s/")
      inl[#inl + 1] = pandoc.Space()
    end
    inl[#inl + 1] = pandoc.Str(text_of(s))
    out[#out + 1] = para(inl, "Signature")
  end
  for _, group in ipairs({ sig.firm or {}, sig.address or {}, sig.contact or {}, sig.role or {} }) do
    out[#out + 1] = spacer()
    for _, l in ipairs(group) do
      out[#out + 1] = para({ pandoc.Str(text_of(l)) }, "Signature")
    end
  end
  return out
end

local function is_wherefore(b)
  local first = b.content[1]
  return first ~= nil and first.t == "Str" and first.text == "WHEREFORE,"
end

local function numbered(n, inlines)
  local inl = { pandoc.Str(tostring(n) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>") }
  for _, x in ipairs(inlines) do inl[#inl + 1] = x end
  return pandoc.Para(inl)
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}

  for _, l in ipairs(m.court or {}) do
    out[#out + 1] = para(l, "CourtTitle")
  end
  out[#out + 1] = spacer()

  for _, blk in ipairs(m.caption or {}) do
    out[#out + 1] = caption_table(blk)
    out[#out + 1] = spacer()
  end

  out[#out + 1] = custom({ pandoc.Para(m.title) }, "DocumentTitle")

  if m.lead_in then out[#out + 1] = para(m.lead_in, "FirstParagraph") end

  local n = 0
  if m.consent then
    n = n + 1
    out[#out + 1] = numbered(n, m.consent)
  end

  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and not is_wherefore(b) then
      n = n + 1
      out[#out + 1] = numbered(n, b.content)
    else
      out[#out + 1] = b
    end
  end

  if m.signature then
    out[#out + 1] = spacer()
    for _, b in ipairs(signature(m.signature)) do out[#out + 1] = b end
  end

  -- The title is printed once, by the DocumentTitle block above; drop the metadata copy pandoc would print.
  local meta = {}
  for k, v in pairs(m) do
    if k ~= "title" then meta[k] = v end
  end
  return pandoc.Pandoc(out, meta)
end
