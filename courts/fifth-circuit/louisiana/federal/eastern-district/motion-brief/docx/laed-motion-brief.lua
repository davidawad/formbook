-- E.D. La. memorandum supporting a motion, DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/laed-motion-brief.typ: the court title, the caption (a table, the party column closed by a right
-- and a bottom rule; VERSUS between the sides; the case fields on the right as a label over its value), the
-- title, the body (not numbered; lettered items; single-spaced block quotations), the signature block on the
-- right half and, when the sample gives `service`, the certificate of service. Page numbers come from the
-- reference's footer (none on page 1). LR 7.7 (25 pages) is not checked here: count the pages of the PDF.

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

-- one case field on the right: its label, then its value (or a blank to fill in)
local function cap_field(label, v)
  return para("CaptionText", run(label)) .. para("CaptionText", run(or_blank(v)))
end

local function caption(meta)
  local left = {}
  for i, side in ipairs(meta.caption) do
    if i > 1 then left[#left + 1] = para("CaptionIndent", run("VERSUS")) end
    for _, n in ipairs(side.names) do
      left[#left + 1] = para("CaptionText", runs(inlines_of(n)))
    end
    left[#left + 1] = para("CaptionDesignation", runs(inlines_of(side.designation)))
  end
  local right = cap_field("CIVIL ACTION NO.", text_of(meta.civil_action_no))
    .. cap_field("SECTION:", text_of(meta.section))
    .. cap_field("JUDGE", text_of(meta.judge))
    .. cap_field("MAGISTRATE JUDGE", text_of(meta.magistrate))
  return caption_table(table.concat(left), right)
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

  -- the body: unnumbered paragraphs, lettered items, headings and quotations as written
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local c = b.content
      if is_text(c[1], "^!$") and is_space(c[2]) then
        add(pandoc.Para(slice(c, 3)))
      elseif (is_text(c[1], "^%a%.$") or is_text(c[1], "^%(%a%)$")) and is_space(c[2]) then
        -- a lettered item: the author types the label; a tab moves the text to the hanging indent
        local lead = { c[1], pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
        for _, el in ipairs(slice(c, 3)) do lead[#lead + 1] = el end
        add(pandoc.Div({ pandoc.Para(lead) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered" })))
      else
        add(b)
      end
    else
      add(b)
    end
  end

  -- the signature block: "Dated" on the left (when the sample gives a date), "Respectfully submitted," on the right
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

  -- the certificate of service (FRCP 5(b)(2)(E)), when the sample gives `service`
  if meta.service then
    local s = meta.service
    add(pandoc.Header(1, { pandoc.Str("CERTIFICATE OF SERVICE") }))
    add(pandoc.Para({ pandoc.Str("I hereby certify that a copy of the foregoing has been served on all counsel of record via the Court\u{2019}s Electronic Filing System.") }))
    add(pandoc.Para({ pandoc.Str("This " .. text_of(s.date) .. ".") }))
    add(spacer())
    add(raw(para("Signature", run("/s/ " .. text_of(s.signer)))))
  end

  doc.blocks = out
  return doc
end
