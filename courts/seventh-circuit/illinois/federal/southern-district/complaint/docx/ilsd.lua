-- ilsd complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Follows typst/ilsd-complaint.typ: court name, caption (a borderless table: parties, a column of ")" marks,
-- the case number and the jury demand), title, unnumbered lead-in, numbered paragraphs, headings, prayer items
-- and the signature block. Every case-specific word comes from the sample's YAML frontmatter.
-- Page numbers come from the footer in reference.docx. Known limits: see the README, "## Engines".

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

-- a metadata value (markdown inlines or blocks) as a list of blocks
local function meta_blocks(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Para({ pandoc.Str(v) }) } end
  if v.t == "MetaInlines" then return { pandoc.Para(v) } end
  local out = {}
  for _, b in ipairs(v) do out[#out + 1] = b end
  return out
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

local function p_xml(style, text, bold)
  local run = ""
  if text ~= "" then
    run = '<w:r>' .. (bold and '<w:rPr><w:b/><w:bCs/></w:rPr>' or '')
      .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. run .. '</w:p>'
end

-- the caption: one row, three cells (parties 3.5 in, ")" marks 0.4 in, case number the rest); no borders
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

local function tab()
  return pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
end

function Pandoc(doc)
  local meta = doc.meta
  local title = txt(meta.title)
  local date = txt(meta.date)
  -- pandoc would write title and date as paragraphs of its own; the cover below carries them
  meta.title = nil
  meta.date = nil

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover (Fed. R. Civ. P. 10(a)): court name, caption, title
  add(custom("Centered", { pandoc.Para({
    pandoc.Str("UNITED STATES DISTRICT COURT"), pandoc.LineBreak(),
    pandoc.Str("FOR THE SOUTHERN DISTRICT OF ILLINOIS") }) }))
  add(gap("Gap24"))
  local right = { p_xml("CaptionRight", "Case No. " .. txt(meta.case_number), false) }
  if meta.jury_demand == true then
    right[#right + 1] = p_xml("CaptionLine", "", false)
    right[#right + 1] = p_xml("CaptionRight", "DEMAND FOR JURY TRIAL", true)
  end
  add(caption_table(meta.caption or {}, right))
  add(gap("Gap24"))
  add(custom("Centered", { pandoc.Para({ pandoc.Strong({ pandoc.Str(title) }) }) }))
  add(spacer(120))

  -- unnumbered lead-in
  for _, b in ipairs(meta_blocks(meta.lead_in)) do add(b) end

  -- body: headings as styled, paragraphs numbered from 1 (a "%" marks an unnumbered paragraph),
  -- "- " items as prayer items with a hanging label
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      add(pandoc.Header(b.level, b.content))
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, ib in ipairs(item) do
          if ib.t == "Plain" or ib.t == "Para" then
            add(custom("PrayerItem", { pandoc.Para(ib.content) }))
          end
        end
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      if c[1] and c[1].t == "Str" and c[1].text:sub(1, 1) == "%" then
        c[1].text = c[1].text:sub(2)
        add(pandoc.Para(c))
      else
        n = n + 1
        local lead = pandoc.List({ pandoc.Str(n .. "."), pandoc.Space() })
        lead:extend(c)
        add(pandoc.Para(lead))
      end
    else
      add(b)
    end
  end

  -- signature block (Fed. R. Civ. P. 11(a)); the typst template keeps it on one page
  local sig = meta.signature
  if sig then
    add(custom("Single", { pandoc.Para({ pandoc.Str("Dated: " .. date) }) }))
    add(gap("CaptionLine"))
    add(custom("SigIndent", { pandoc.Para({ pandoc.Str("Respectfully submitted,") }) }))
    add(custom("SigAfterGap", { pandoc.Para({ pandoc.Strong({ pandoc.Str(txt(sig.firm)) }) }) }))
    add(custom("SigAfterGap", { pandoc.Para({ pandoc.Str("By: /s/ " .. txt(sig.signer)) }) }))
    for _, l in ipairs(sig.lines or {}) do
      add(custom("SigIndent", { pandoc.Para({ pandoc.Str(txt(l)) }) }))
    end
    for i, l in ipairs(sig.other or {}) do
      add(custom(i == 1 and "SigAfterGap" or "SigIndent", { pandoc.Para({ pandoc.Str(txt(l)) }) }))
    end
    if sig.role then
      add(custom("SigAfterGap", { pandoc.Para({ pandoc.Emph({ pandoc.Str(txt(sig.role)) }) }) }))
    end
  end

  doc.blocks = out
  return doc
end
