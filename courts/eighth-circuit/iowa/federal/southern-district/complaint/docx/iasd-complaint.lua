-- iasd complaint, docx engine (docs/DOCX.md). Mirrors typst/iasd-complaint.typ:
--   * court title, caption (a borderless table: party column with a right and bottom rule), case number and title
--     are built here from the frontmatter, as raw WordprocessingML;
--   * body paragraphs are numbered by this filter (1., 2., ...), except after "Requested Relief" and "Jury Demand";
--     lettered lists become (a), (b), ... ; headings, block quotations and footnotes are pandoc's, styled by
--     reference.docx;
--   * signature block (LR 11) and the optional filing note are raw paragraphs at the margin or the signature column.
-- Content-agnostic: every case word comes from the sample's frontmatter.
local LETTERS = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t" }
local UNNUMBERED_AFTER = { ["REQUESTED RELIEF"] = true, ["JURY DEMAND"] = true }
local SIG_INDENT = 4968 -- twips: 3.25 in caption column + 0.2 in gutter, as the typst signature block

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function need(meta, k)
  if meta[k] == nil then error("iasd-complaint.lua: frontmatter field `" .. k .. "` is required") end
  return meta[k]
end

local function rb(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- One single-spaced or double-spaced paragraph, as raw WordprocessingML. Spacing in twips: 280 = 14 pt (single),
-- 480 = 24 pt (double).
local function p(s, o)
  o = o or {}
  local ppr = "<w:pPr>"
    .. '<w:spacing w:before="0" w:after="' .. (o.after or 0) .. '" w:line="' .. (o.line or 280) .. '" w:lineRule="exact"/>'
    .. '<w:ind w:left="' .. (o.left or 0) .. '" w:firstLine="' .. (o.first or 0) .. '"/>'
    .. (o.jc and ('<w:jc w:val="' .. o.jc .. '"/>') or "")
    .. "</w:pPr>"
  local rpr = o.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return "<w:p>" .. ppr .. '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r></w:p>"
end

local function page_break()
  return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
end

local BORDER_NONE = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
local RULE = '<w:single w:sz="6" w:space="0" w:color="000000"/>'

-- The caption: party column (4680 twips, right and bottom rule), gutter (288), case number and title (4392).
local function caption_table(meta)
  local cap = need(meta, "caption")
  local versus = cap.versus and text(cap.versus) or "v."
  local left = {}
  for k, party in ipairs(cap.parties) do
    if k > 1 then left[#left + 1] = p(versus) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(text(n)) end
    left[#left + 1] = p(text(party.designation))
  end
  local right = {
    p("Case No. " .. text(need(meta, "case_number")), { after = 240 }),
    p(string.upper(text(need(meta, "title"))), { bold = true }),
  }
  return "<w:tbl><w:tblPr><w:tblW w:w=\"9360\" w:type=\"dxa\"/><w:tblBorders>" .. BORDER_NONE
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="288"/><w:gridCol w:w="4392"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/><w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders><w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. p("") .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4392" w:type="dxa"/><w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. "</w:tc>"
    .. "</w:tr></w:tbl>"
end

local function court_title(meta)
  return p("IN THE UNITED STATES DISTRICT COURT", { bold = true, jc = "center" })
    .. p("FOR THE SOUTHERN DISTRICT OF IOWA", { bold = true, jc = "center" })
    .. p(string.upper(text(need(meta, "division"))), { bold = true, jc = "center", after = 480 })
end

-- A paragraph whose first inline is a label (1., (a)) and a tab, so the text starts at the next tab stop.
local function labelled(label, inlines)
  local c = { pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
  for _, x in ipairs(inlines) do c[#c + 1] = x end
  return pandoc.Para(c)
end

-- A non-breaking space after a section or paragraph sign, so the sign stays with its number.
local function nbsp_signs(inlines)
  local out = {}
  for i, x in ipairs(inlines) do
    local prev = inlines[i - 1]
    if x.t == "Space" and prev and prev.t == "Str" and (prev.text == "§" or prev.text == "¶") then
      out[#out + 1] = pandoc.Str("\u{a0}")
    else
      out[#out + 1] = x
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}

  out[#out + 1] = rb(court_title(meta))
  out[#out + 1] = rb(caption_table(meta))
  out[#out + 1] = rb(p("", { line = 480 }))
  if meta.lead_in ~= nil then
    out[#out + 1] = pandoc.Para(meta.lead_in)
  end

  local numbered, n = true, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 and UNNUMBERED_AFTER[string.upper(text(b.content))] then numbered = false end
      out[#out + 1] = b
    elseif b.t == "Para" then
      if numbered then
        n = n + 1
        out[#out + 1] = labelled(n .. ".", b.content)
      else
        out[#out + 1] = b
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = labelled("(" .. LETTERS[i] .. ")", item[1].content)
      end
    else
      out[#out + 1] = b
    end
  end

  -- Signature block (LR 11): the signature lines in the signature column, then the filing note at the margin.
  local sig = need(meta, "signature")
  out[#out + 1] = rb(p("", { line = 480 }))
  for _, l in ipairs(sig.lines) do
    out[#out + 1] = rb(p(text(l), { left = SIG_INDENT }))
  end
  if meta.filing_note ~= nil then
    out[#out + 1] = rb(p("", { line = 480 }))
    out[#out + 1] = rb(p(text(meta.filing_note)))
  end

  local result = pandoc.Pandoc(out, pandoc.Meta({}))
  return result:walk({
    Inlines = nbsp_signs,
  })
end
