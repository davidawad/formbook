-- Complaint, S.D. Fla. (flsd), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx, in the
-- form of typst/flsd-complaint.typ (S.D. Fla. L.R. 5.1(a)). The caption, the signature block and the spacing
-- blocks are paragraphs in the custom styles of reference.docx (Centered, CaptionLine, SigLine, GapLarge, ...).
-- Paragraph numbers (Fed. R. Civ. P. 10(b)) are typed text: the number, a period, then a tab. The lead-in, the
-- WHEREFORE paragraphs and the paragraph under DEMAND FOR JURY TRIAL are unnumbered, as in the typst template.
-- The page number comes from the reference's footer.

local function stringify(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a paragraph in a custom paragraph style of reference.docx
local function para(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- an empty paragraph of exact height (the typst v() gaps)
local function gap(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- caption: court (L.R. 5.1(a)(5)(A)), docket line (B), style at the left (C), title (D)
  add(para("Centered", { pandoc.Strong({ pandoc.Str("UNITED STATES DISTRICT COURT") }) }))
  add(para("Centered", { pandoc.Strong({ pandoc.Str("SOUTHERN DISTRICT OF FLORIDA") }) }))
  if m.division then
    add(para("Centered", { pandoc.Strong({ pandoc.Str(stringify(m.division):upper()) }) }))
  end
  add(gap("GapLarge"))
  add(para("Centered", { pandoc.Str("CIVIL CASE NO. " .. stringify(m.case_number)) }))
  add(gap("GapLarge"))
  local rows = {}
  for k, p in ipairs(m.caption.parties) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, n in ipairs(p.names) do rows[#rows + 1] = stringify(n) end
    rows[#rows + 1] = stringify(p.designation)
  end
  rows[#rows + 1] = "/"
  for _, r in ipairs(rows) do add(para("CaptionLine", { pandoc.Str(r) })) end
  add(gap("GapLarge"))
  add(para("Centered", { pandoc.Strong({ pandoc.Str(stringify(m.title):upper()) }) }))
  add(gap("GapLarge"))

  -- the lead-in: the unnumbered paragraph before the first heading
  if m.lead_in then
    if pandoc.utils.type(m.lead_in) == "Blocks" then
      for _, b in ipairs(m.lead_in) do add(b) end
    else
      add(pandoc.Para(m.lead_in))
    end
  end

  -- body: numbered paragraphs; headings and lists as written
  local n = 0
  local unnumbered = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      unnumbered = stringify(b.content) == "DEMAND FOR JURY TRIAL"
      add(b)
    elseif b.t == "Para" then
      if unnumbered or stringify(b):match("^WHEREFORE") then
        add(b)
      else
        n = n + 1
        local content = pandoc.List({ pandoc.Str(tostring(n) .. "."), tab() })
        content:extend(b.content)
        add(pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" })))
      end
    else
      add(b)
    end
  end

  -- signature block (L.R. 5.1(a)(6)), kept together as in the typst template
  add(gap("GapSmall"))
  add(para("SingleKeep", { pandoc.Str("Dated: " .. stringify(m.date)) }))
  add(gap("GapSmall"))
  add(para("SigLine", { pandoc.Str("Respectfully submitted,") }))
  add(gap("GapSmall"))
  add(para("SigLine", { pandoc.Str("By: /s/ " .. stringify(m.signature.signer)) }))
  for _, l in ipairs(m.signature.lines) do
    add(para("SigLine", { pandoc.Str(stringify(l)) }))
  end

  doc.blocks = out
  doc.meta = {}
  return doc
end
