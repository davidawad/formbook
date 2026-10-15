-- Pandoc filter for the gub adversary complaint, docx engine (typst/gub-adversary-complaint.typ is the reference).
-- Builds the cover (counsel, court title, caption table, case information) and the signature block from the
-- sample's frontmatter as raw OpenXML, styled by docx/reference.docx; numbers the body paragraphs 1, 2, ...
-- (a paragraph beginning "§ " is unnumbered); letters list items (a), (b), ...; leaves headings and the rest
-- to pandoc. The frontmatter metadata is dropped, so pandoc writes no title or date block.
-- Content-agnostic: every case word comes from the sample. The court title is the form's own text.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- A meta value that is a list (or a single string) as a Lua list of strings.
local function list(v)
  local out = {}
  if v == nil then return out end
  if v.t == "MetaInlines" or v.t == "MetaString" or v.t == "MetaBlocks" then
    out[1] = str(v)
  else
    for _, x in ipairs(v) do out[#out + 1] = str(x) end
  end
  return out
end

-- One paragraph of raw OpenXML in a named style.
local function p(text, style, bold)
  local rpr = bold and "<w:rPr><w:b /></w:rPr>" or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '" /></w:pPr><w:r>' .. rpr
    .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r></w:p>'
end

local function raw(s)
  return pandoc.RawBlock("openxml", s)
end

-- Caption table (GNLR 5.1(c)): party column left of the centre with a bottom and a right rule; case
-- information to the right. Widths in twips (text width 9000 = 8.5 in less 2.25 in of margins less the rest).
local function caption(m)
  local left, right = {}, {}
  local c = m.caption
  if c.debtor then
    left[#left + 1] = p("In re:", "CaptionBlock")
    for _, n in ipairs(list(c.debtor.names)) do left[#left + 1] = p(n, "CaptionBlock") end
    left[#left + 1] = p(str(c.debtor.designation), "CaptionBlock")
    left[#left + 1] = p("", "CaptionBlock")
  end
  for k, party in ipairs(c.parties) do
    if k > 1 then left[#left + 1] = p("v.", "CaptionBlock") end
    for _, n in ipairs(list(party.names)) do left[#left + 1] = p(n, "CaptionBlock") end
    left[#left + 1] = p(str(party.designation), "CaptionBlock")
  end
  if m.chapter then right[#right + 1] = p(str(m.chapter), "CaptionBlock") end
  right[#right + 1] = p("Case No. " .. str(m.case_number), "CaptionBlock")
  right[#right + 1] = p("", "CaptionBlock")
  right[#right + 1] = p("Adversary Proceeding", "CaptionBlock")
  right[#right + 1] = p("Adv. Proc. No. " .. str(m.adversary_number), "CaptionBlock")
  right[#right + 1] = p("", "CaptionBlock")
  right[#right + 1] = p(str(m.brief_title), "CaptionBlock", true)
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="auto" />'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="auto" /></w:tcBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa" /><w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4608" /><w:gridCol w:w="360" /><w:gridCol w:w="4032" /></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa" />' .. rule
    .. '<w:tcMar><w:right w:w="144" w:type="dxa" /></w:tcMar></w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa" /></w:tcPr>' .. p("", "CaptionBlock") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4032" w:type="dxa" /><w:tcMar><w:left w:w="144" w:type="dxa" /></w:tcMar></w:tcPr>'
    .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

local function cover(m)
  local out = {}
  local counsel = list(m.counsel)
  for _, line in ipairs(counsel) do out[#out + 1] = raw(p(line, "Counsel")) end
  -- GNLR 5.1(b): the court title starts at least 3 in from the top (1 in margin plus the counsel block).
  local pad = 144 - #counsel * 13.8
  if pad > 0 then
    out[#out + 1] = raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. math.floor(pad * 20)
      .. '" w:lineRule="exact" /></w:pPr></w:p>')
  end
  out[#out + 1] = raw(p("IN THE DISTRICT COURT OF GUAM", "CourtTitle"))
  out[#out + 1] = raw(p("TERRITORY OF GUAM", "CourtTitle"))
  out[#out + 1] = raw(p("BANKRUPTCY DIVISION", "CourtTitle"))
  out[#out + 1] = raw(p("", "CourtTitle"))
  out[#out + 1] = raw(caption(m))
  -- The form starts the body on a new page. The break sits in the paragraph after the caption table.
  out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="Unnumbered" /></w:pPr><w:r><w:br w:type="page" /></w:r></w:p>')
  return out
end

local function signature(m)
  local out = {}
  local sig = m.signature
  if sig == nil then return out end
  out[#out + 1] = raw(p("", "Signature"))
  for _, l in ipairs(list(sig.firm)) do out[#out + 1] = raw(p(l, "Signature")) end
  out[#out + 1] = raw(p("", "Signature"))
  out[#out + 1] = raw(p("/s/ " .. str(sig.signer), "Signature"))
  out[#out + 1] = raw(p(str(sig.signer), "Signature"))
  for _, l in ipairs(list(sig.lines)) do out[#out + 1] = raw(p(l, "Signature")) end
  return out
end

local function is_unnumbered(b)
  local first = b.content[1]
  return first ~= nil and first.t == "Str" and first.text == "§"
end

function Pandoc(doc)
  local m = doc.meta
  local out = cover(m)
  if m.lead_in then
    for _, b in ipairs(pandoc.read(str(m.lead_in), "markdown").blocks) do out[#out + 1] = b end
  end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and is_unnumbered(b) then
      local c = {}
      for i = 2, #b.content do c[#c + 1] = b.content[i] end
      if c[1] and c[1].t == "Space" then table.remove(c, 1) end
      out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, { ["custom-style"] = "Unnumbered" })
    elseif b.t == "Para" then
      n = n + 1
      local c = { pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>") }
      for _, x in ipairs(b.content) do c[#c + 1] = x end
      out[#out + 1] = pandoc.Para(c)
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local c = { pandoc.Str("(" .. string.char(96 + i) .. ")"), pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>") }
        local first = item[1]
        if first and (first.t == "Plain" or first.t == "Para") then
          for _, x in ipairs(first.content) do c[#c + 1] = x end
        end
        out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, { ["custom-style"] = "Lettered" })
        for j = 2, #item do out[#out + 1] = item[j] end
      end
    else
      out[#out + 1] = b
    end
  end
  for _, x in ipairs(signature(m)) do out[#out + 1] = x end
  return pandoc.Pandoc(out)
end
