-- tneb adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/tneb-adversary-complaint.typ: the cover (court, district, caption, title), the lead-in, the
-- headings, numbered allegations (Rule 10(b)), the lettered prayer, the signature. Every case-specific word comes
-- from the sample's frontmatter. Paragraph styles come from reference.docx (build-reference.sh).
-- Known differences (see README.md "Engines"): smart quotes and dashes (pandoc's smart extension) where typst
-- prints the sample's straight characters; the caption is tab stops in paragraphs, not a table.

local CFG = { numbered = true, prayer = true }

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function styled(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- a list marker that pandoc's markdown reader took for a list (e.g. "(865) 546-7311" in a signature block)
-- is written back as text: the marker is the start number in the delimiter style
local function marker_text(la)
  local n = tostring(la.start)
  local d = tostring(la.delimiter)
  if d == "TwoParens" then return "(" .. n .. ")" end
  if d == "OneParen" then return n .. ")" end
  return n .. "."
end

-- a metadata value (inline markdown, plain string or blocks) as Inlines
local function to_inlines(v)
  local out = pandoc.Inlines({})
  if v == nil then return out end
  if type(v) == "string" then
    return pandoc.utils.blocks_to_inlines(pandoc.read(v, "markdown").blocks)
  end
  if v.t == nil and type(v) == "table" then
    -- a plain list of inlines (pandoc's value for a metadata line made of inlines)
    for _, el in ipairs(v) do
      if el.t == "Para" or el.t == "Plain" or el.t == "OrderedList" or el.t == "BulletList" then
        for _, i in ipairs(pandoc.utils.blocks_to_inlines({ el })) do out:insert(i) end
      else
        out:insert(el)
      end
    end
    return out
  end
  if v.t == "MetaInlines" then
    for _, i in ipairs(v) do out:insert(i) end
    return out
  end
  if v.t == "MetaBlocks" then
    for _, b in ipairs(v) do
      if b.t == "OrderedList" then
        for k, item in ipairs(b.content) do
          if k > 1 then out:insert(pandoc.LineBreak()) end
          out:insert(pandoc.Str(marker_text(b.listAttributes) .. " "))
          for _, i in ipairs(pandoc.utils.blocks_to_inlines(item)) do out:insert(i) end
        end
      else
        for _, i in ipairs(pandoc.utils.blocks_to_inlines({ b })) do out:insert(i) end
      end
    end
    return out
  end
  return to_inlines(pandoc.utils.stringify(v))
end

local function concat(...)
  local out = pandoc.Inlines({})
  for _, part in ipairs({ ... }) do
    for _, i in ipairs(part) do out:insert(i) end
  end
  return out
end

-- an empty line of the given style (typst v(...)); a raw empty paragraph, since pandoc drops empty styled Divs
local function gap(style_id)
  local ppr = style_id and ('<w:pPr><w:pStyle w:val="' .. style_id .. '"/></w:pPr>') or ""
  return pandoc.RawBlock("openxml", "<w:p>" .. ppr .. "</w:p>")
end

-- an empty paragraph of an exact height in twips (a fine gap between the cover blocks)
local function spacer(twips)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>')
end

local function gap_double()
  return spacer(324)  -- v(body-leading): 16.2 pt, not a full double line
end

local function gap_single()
  return gap("Single")
end

local function caption_row(r)
  local inl = concat(to_inlines(r["left"]), pandoc.Inlines({ TAB, pandoc.Str(")"), TAB }), to_inlines(r["right"]))
  return styled("CaptionRow", { pandoc.Para(inl) })
end

local function cover(meta)
  local out = {}
  out[#out + 1] = styled("CoverLine", { pandoc.Para(concat(pandoc.Inlines({ pandoc.Str("IN THE ") }), to_inlines(meta.court))) })
  out[#out + 1] = styled("CoverLine", { pandoc.Para(to_inlines(meta.district)) })
  if meta.division then
    out[#out + 1] = styled("CoverLine", { pandoc.Para(pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(meta.division):upper()) })) })
  end
  out[#out + 1] = gap_single()
  for _, r in ipairs(meta.caption or {}) do out[#out + 1] = caption_row(r) end
  out[#out + 1] = spacer(60)  -- tuned to the typst title position (see README.md, Engines)
  out[#out + 1] = styled("CoverTitle", { pandoc.Para(to_inlines(meta.title)) })
  out[#out + 1] = spacer(440)
  return out
end

-- the signature block (typst signature()): a gap, the dated line if any, a gap, then the single-spaced lines
local function signature(sig, out)
  out[#out + 1] = spacer(sig.dated and 464 or 324)  -- v(body-leading) before the signature; a little more before a dated line (tuned to the typst page)
  if sig.dated then
    out[#out + 1] = styled("Dated", { pandoc.Para(to_inlines(sig.dated)) })
    out[#out + 1] = gap_double()
  end
  local lines = {}
  if sig.lead then lines[#lines + 1] = to_inlines(sig.lead) end
  if sig.firm then lines[#lines + 1] = to_inlines(sig.firm) end
  if sig.by then lines[#lines + 1] = to_inlines(sig.by) end
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = to_inlines(l) end
  -- the block stays on one page (typst breakable: false): every line but the last keeps with the next
  for i, l in ipairs(lines) do
    out[#out + 1] = styled(i < #lines and "SignatureNext" or "Signature", { pandoc.Para(l) })
  end
end

-- XML text escaping for the raw certificate table
local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- the lines of an inline run (a soft or hard break starts a new line)
local function lines_of(inls)
  local lines, cur = {}, {}
  for _, i in ipairs(inls) do
    if i.t == "SoftBreak" or i.t == "LineBreak" then
      lines[#lines + 1] = cur
      cur = {}
    else
      cur[#cur + 1] = i
    end
  end
  lines[#lines + 1] = cur
  return lines
end

local CELL_W, GUTTER_W = 4464, 432

local function cell_xml(served)
  local ps = {}
  for _, line in ipairs(lines_of(to_inlines(served))) do
    local text = xesc(pandoc.utils.stringify(pandoc.Inlines(line)))
    ps[#ps + 1] = '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr><w:r><w:t xml:space="preserve">' .. text .. '</w:t></w:r></w:p>'
  end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. CELL_W .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local EMPTY_CELL = '<w:tc><w:tcPr><w:tcW w:w="' .. CELL_W .. '" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
local GUTTER = '<w:tc><w:tcPr><w:tcW w:w="' .. GUTTER_W .. '" w:type="dxa"/></w:tcPr><w:p/></w:tc>'

-- the persons served, two to a row (typst grid(columns: (1fr, 1fr)), a borderless raw table)
local function served_table(served)
  local rows = {}
  for i = 1, #served, 2 do
    local right = served[i + 1] and cell_xml(served[i + 1]) or EMPTY_CELL
    rows[#rows + 1] = '<w:tr>' .. cell_xml(served[i]) .. GUTTER .. right .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="' .. CELL_W .. '"/><w:gridCol w:w="' .. GUTTER_W .. '"/><w:gridCol w:w="' .. CELL_W .. '"/></w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

-- certificate of service (typst certificate()): heading, the paper served, the persons served, the signer
local function certificate(cert, out)
  out[#out + 1] = spacer(324)
  out[#out + 1] = styled("CoverTitle", { pandoc.Para(pandoc.Inlines({ pandoc.Str("CERTIFICATE OF SERVICE") })) })
  out[#out + 1] = spacer(324)
  out[#out + 1] = pandoc.Para(to_inlines(cert.text))
  out[#out + 1] = spacer(324)
  local served = {}
  for i, s in ipairs(cert.served or {}) do served[i] = s end
  out[#out + 1] = pandoc.RawBlock("openxml", served_table(served))
  out[#out + 1] = spacer(324)
  out[#out + 1] = styled("Indented", { pandoc.Para(to_inlines(cert.signer)) })
end

function Pandoc(doc)
  local meta = doc.meta
  local out = cover(meta)

  if meta.lead_in then
    out[#out + 1] = pandoc.Para(to_inlines(meta.lead_in))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local text = pandoc.utils.stringify(b)
      if CFG.numbered and not text:match("^WHEREFORE") then
        n = n + 1
        out[#out + 1] = styled("Numbered", { pandoc.Para(concat(pandoc.Inlines({ pandoc.Str(n .. ".") }), pandoc.Inlines({ TAB }), b.content)) })
      else
        out[#out + 1] = b
      end
    elseif b.t == "OrderedList" and CFG.prayer then
      for k, item in ipairs(b.content) do
        local inl = concat(pandoc.Inlines({ pandoc.Str("(" .. string.char(96 + k) .. ")"), TAB }),
          pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Prayer", { pandoc.Para(inl) })
      end
    else
      out[#out + 1] = b
    end
  end

  if meta.signature then signature(meta.signature, out) end
  if meta.certificate then certificate(meta.certificate, out) end

  doc.blocks = out
  -- the frontmatter is the cover, not pandoc's document title block (Title style)
  doc.meta = pandoc.Meta({})
  return doc
end
