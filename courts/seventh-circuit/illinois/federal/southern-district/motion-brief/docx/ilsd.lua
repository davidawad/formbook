-- ilsd motion to dismiss with a brief in support, DOCX engine (docs/DOCX.md): markdown -> Word on reference.docx.
-- Follows typst/ilsd-motion-brief.typ: court name, caption (a borderless table: parties, a column of ")" marks,
-- the civil action number), title, body with the headings numbered by the filter (I., A., 1.; the typed
-- headings carry no numbers), footnotes (pandoc), signature block, and the certificate of service on its own
-- page. Every case-specific word comes from the sample's YAML frontmatter. Page numbers come from the footer in
-- reference.docx. Known limits: see the README, "## Engines".

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function custom(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- an empty paragraph in a named style (a line of space the height of the style)
local function gap(style)
  return raw('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

-- an empty single-spaced paragraph with `twips` of space after it
local function spacer(twips)
  return raw('<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="' .. twips .. '"/></w:pPr></w:p>')
end

local function page_break()
  return raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function tab()
  return pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
end

local function p_xml(style, text, bold)
  local run = ""
  if text ~= "" then
    run = '<w:r>' .. (bold and '<w:rPr><w:b/><w:bCs/></w:rPr>' or '')
      .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. run .. '</w:p>'
end

-- the caption: one row, three cells (parties 3.5 in, ")" marks 0.4 in, the number the rest); no borders
local function caption_table(sides, right)
  local left, marks = {}, {}
  local function push(style, text)
    left[#left + 1] = p_xml(style, text, false)
    marks[#marks + 1] = p_xml("CaptionLine", ")", false)
  end
  for i, side in ipairs(sides) do
    for _, nm in ipairs(side.names or {}) do push("CaptionLine", txt(nm)) end
    push("CaptionLine", "")
    push("CaptionIndent", txt(side.designation))
    if i < #sides then
      push("CaptionLine", "")
      push("CaptionCenter", "v.")
      push("CaptionLine", "")
    end
  end
  local function cell(w, paras, valign)
    local va = valign and ('<w:vAlign w:val="' .. valign .. '"/>') or ""
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. va .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
  end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="5040"/><w:gridCol w:w="576"/><w:gridCol w:w="3744"/></w:tblGrid>'
    .. '<w:tr>' .. cell(5040, left) .. cell(576, marks) .. cell(3744, right, "center") .. '</w:tr></w:tbl>')
end

local ROMAN = {
  { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" },
}
local function roman(n)
  local s = ""
  for _, p in ipairs(ROMAN) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

function Pandoc(doc)
  local meta = doc.meta
  local title = txt(meta.title)
  -- pandoc would write the title as a paragraph of its own; the cover below carries it
  meta.title = nil
  meta.date = nil

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court name, caption, title (typst: court name, 24 pt, caption, 24 pt, title, 12 pt)
  add(custom("Centered", { pandoc.Para({
    pandoc.Str("IN THE UNITED STATES DISTRICT COURT"), pandoc.LineBreak(),
    pandoc.Str("FOR THE SOUTHERN DISTRICT OF ILLINOIS") }) }))
  add(gap("Gap24"))
  add(caption_table(meta.caption or {}, { p_xml("CaptionRight", "Civil Action No. " .. txt(meta.case_number), false) }))
  add(gap("Gap24"))
  add(custom("TitleBlock", { pandoc.Para({ pandoc.Strong({ pandoc.Str(title) }) }) }))
  add(spacer(240))

  -- body: headings labelled by the filter; paragraphs and footnotes as pandoc renders them
  local counters = { 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local L = math.min(b.level, 4)
      counters[L] = counters[L] + 1
      for k = L + 1, 4 do counters[k] = 0 end
      if L == 1 then
        local label = roman(counters[1]) .. "."
        add(custom("MotionH1", { pandoc.Para({
          pandoc.Strong({ pandoc.Str(label) }), pandoc.LineBreak(),
          pandoc.Strong(b.content) }) }))
      elseif L == 2 then
        local label = string.char(64 + counters[2]) .. "."
        add(custom("HeadingHang", { pandoc.Para({
          pandoc.Strong({ pandoc.Str(label) }), tab(), pandoc.Strong(b.content) }) }))
      else
        local label
        if L == 3 then label = counters[3] .. "." else label = string.char(96 + counters[4]) .. "." end
        add(custom("HeadingHang3", { pandoc.Para({
          pandoc.Strong({ pandoc.Str(label) }), tab(), pandoc.Strong(b.content) }) }))
      end
    else
      add(b)
    end
  end

  -- signature block: the date line at the left, the signer at 3.0 in
  local sig = meta.signature
  if sig then
    add(gap("CaptionLine"))
    add(custom("Single", { pandoc.Para({ pandoc.Str(txt(meta.date_line)) }) }))
    add(gap("CaptionLine"))
    add(custom("SigIndent30", { pandoc.Para({ pandoc.Str("Respectfully submitted,") }) }))
    add(custom("SigAfterGap30", { pandoc.Para({ pandoc.Str("By: /s/ " .. txt(sig.signer)) }) }))
    for _, l in ipairs(sig.lines or {}) do
      add(custom("SigIndent30", { pandoc.Para({ pandoc.Str(txt(l)) }) }))
    end
    if sig.role then
      add(custom("SigAfterGap30", { pandoc.Para({ pandoc.Strong({ pandoc.Str(txt(sig.role)) }) }) }))
    end
  end

  -- certificate of service (Fed. R. Civ. P. 5(b)(2)(E)); the recipients come from the frontmatter
  local svc = meta.service
  if svc then
    add(page_break())
    add(custom("Centered", { pandoc.Para({ pandoc.Strong({ pandoc.Str("CERTIFICATE OF SERVICE") }) }) }))
    add(spacer(240))
    add(pandoc.Para({ pandoc.Str([[I certify that a true and correct copy of the foregoing pleading was electronically filed with the clerk for the U.S. District Court, Southern District of Illinois, using the electronic case filing system of the court, and the electronic case filing system sent a "Notice of Electronic Filing" to the following attorneys of record who have consented in writing to accept this Notice as service of this document by electronic means, as follows:]]) }))
    add(spacer(120))
    for _, r in ipairs(svc.recipients or {}) do
      add(custom("Recipient", { pandoc.Para({
        pandoc.Str(txt(r.name)), pandoc.LineBreak(),
        pandoc.Str("Email: " .. txt(r.email)) }) }))
    end
    add(spacer(240))
    add(custom("DateLine", { pandoc.Para({
      pandoc.Str(txt(svc.date)), tab(), pandoc.Str("/s/ " .. txt(svc.signer)) }) }))
  end

  doc.blocks = out
  return doc
end
