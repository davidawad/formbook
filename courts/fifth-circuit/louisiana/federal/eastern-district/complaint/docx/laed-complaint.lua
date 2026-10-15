-- E.D. La. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/laed-complaint.typ: the court title, the caption (a table, the party column closed by a right
-- and a bottom rule), the title, the body (numbered paragraphs, unnumbered "!" paragraphs, lettered items,
-- single-spaced block quotations) and the signature block on the right half. Page numbers come from the
-- reference's footer (none on page 1).
-- Paragraph numbers are typed as text by this filter, as the typst template does it; Word's list numbering is
-- not used, so the numbers cannot restart or renumber when a paragraph is moved.

local BLANK = "______________"

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- one run of text with its bold and italic flags
local function run(text, bold, italic)
  local rpr = (bold and "<w:b/><w:bCs/>" or "") .. (italic and "<w:i/><w:iCs/>" or "")
  local rp = rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return '<w:r>' .. rp .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- inline content (a markdown string in the sample) as runs: case names in italics, and so on
local function runs(inls, bold, italic)
  local out = {}
  for _, el in ipairs(inls) do
    if el.t == "Str" then
      out[#out + 1] = run(el.text, bold, italic)
    elseif el.t == "Space" or el.t == "SoftBreak" then
      out[#out + 1] = run(" ", bold, italic)
    elseif el.t == "Emph" then
      out[#out + 1] = runs(el.content, bold, true)
    elseif el.t == "Strong" then
      out[#out + 1] = runs(el.content, true, italic)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), bold, italic)
    end
  end
  return table.concat(out)
end

-- a metadata value as inlines (a markdown value keeps its emphasis; a plain value is one string)
local function inlines_of(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function or_blank(v)
  if v == "" then return BLANK end
  return v
end

local function para(style, content)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. (content or "") .. '</w:p>'
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function spacer()
  return raw(para("BodyText"))
end

-- the caption: a borderless table; the party column has a right and a bottom rule (LR 10.1 caption)
local function caption_table(left_xml, right_xml)
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="504"/><w:gridCol w:w="4176"/></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/>' .. rule
    .. '<w:tcMar><w:right w:w="288" w:type="dxa"/><w:bottom w:w="288" w:type="dxa"/></w:tcMar></w:tcPr>' .. left_xml .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="504" w:type="dxa"/></w:tcPr>' .. para("Single") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa"/></w:tcPr>' .. right_xml .. '</w:tc></w:tr></w:tbl>'
end

local function caption(meta)
  local left = {}
  for i, side in ipairs(meta.caption) do
    if i > 1 then left[#left + 1] = para("CaptionIndent", run("v.")) end
    for _, n in ipairs(side.names) do
      left[#left + 1] = para("CaptionText", runs(inlines_of(n)))
    end
    left[#left + 1] = para("CaptionDesignation", runs(inlines_of(side.designation)))
  end
  local right = {
    para("CaptionText", run("CIVIL ACTION NO. " .. or_blank(text_of(meta.civil_action_no)))),
    para("CaptionText", run("SECTION: " .. or_blank(text_of(meta.section)))),
    para("CaptionText", run("JUDGE " .. or_blank(text_of(meta.judge)))),
    para("CaptionText", run("MAGISTRATE JUDGE " .. or_blank(text_of(meta.magistrate)))),
  }
  return caption_table(table.concat(left), table.concat(right))
end

local function slice(list, i)
  local t = {}
  for k = i, #list do t[#t + 1] = list[k] end
  return t
end

local function is_text(el, pattern)
  return el ~= nil and el.t == "Str" and el.text:match(pattern) ~= nil
end

local function is_space(el)
  return el ~= nil and el.t == "Space"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b)
    out[#out + 1] = b
  end

  -- the court title and the caption
  add(raw(para("Centered", run("UNITED STATES DISTRICT COURT", true))))
  add(raw(para("CenteredDouble", run("EASTERN DISTRICT OF LOUISIANA", true))))
  add(raw(caption(meta)))
  add(raw(para("CenteredDouble", runs(inlines_of(meta.title), true))))
  if meta.jury_demand == true then
    add(raw(para("Centered", run("JURY TRIAL DEMANDED", true))))
  end

  -- the body: numbered paragraphs, unnumbered "!" paragraphs, lettered items, headings and quotations as written
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local c = b.content
      if is_text(c[1], "^!$") and is_space(c[2]) then
        -- an unnumbered paragraph ("! " in the sample): a lead-in, or the jury demand
        add(pandoc.Para(slice(c, 3)))
      elseif (is_text(c[1], "^%a%.$") or is_text(c[1], "^%(%a%)$")) and is_space(c[2]) then
        -- a lettered item: the author types the label; a tab moves the text to the hanging indent
        local lead = { c[1], pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
        for _, el in ipairs(slice(c, 3)) do lead[#lead + 1] = el end
        add(pandoc.Div({ pandoc.Para(lead) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered" })))
      else
        n = n + 1
        local lead = { pandoc.Str(n .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
        for _, el in ipairs(slice(c, 1)) do lead[#lead + 1] = el end
        add(pandoc.Para(lead))
      end
    else
      add(b)
    end
  end

  -- the signature block: "Dated" on the left, "Respectfully submitted," on the right half (sig-indent 3 in)
  add(spacer())
  local date = text_of(meta.date)
  local left = date ~= "" and run("Dated: " .. date) or ""
  add(raw('<w:p><w:pPr><w:pStyle w:val="Single"/><w:tabs><w:tab w:val="left" w:pos="4320"/></w:tabs></w:pPr>'
    .. left .. '<w:r><w:tab/></w:r>' .. run("Respectfully submitted,") .. '</w:p>'))
  for _, group in ipairs(meta.signature) do
    add(spacer())
    for _, nm in ipairs(group.names) do
      add(raw(para("Signature", runs(inlines_of(nm)))))
    end
    for _, l in ipairs(group.lines or {}) do
      add(raw(para("Signature", runs(inlines_of(l)))))
    end
  end

  doc.blocks = out
  return doc
end
