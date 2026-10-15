-- wied motion brief (brief in support of a motion), DOCX engine (docs/DOCX.md). The markdown sample -> a Word
-- document on reference.docx. The cover (court title, caption, document title), the signature block and the
-- argument headings' hanging numerals are built here from the sample's YAML frontmatter, following the typst
-- template (motion-brief/typst/wied-motion-brief.typ). Section and sub-headings are pandoc headings styled by
-- reference.docx; block quotations are pandoc block quotes ("Block Text"). Nothing case-specific lives in this
-- file. Known limits: see motion-brief/README.md.

local TAB = '<w:r><w:tab/></w:r>'

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- plain text as inlines, one Space between words (no Str holds a space)
local function words(s)
  local out = {}
  for w in s:gmatch("%S+") do
    if #out > 0 then out[#out + 1] = pandoc.Space() end
    out[#out + 1] = pandoc.Str(w)
  end
  return out
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function styled_line(style, s)
  return styled(style, { pandoc.Para(words(s)) })
end

local function blank(style)
  return styled(style or "Double", { pandoc.Para({}) })
end

local function xml_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- one paragraph of the caption table, plain text in the given style with optional indent
local function xp(style, s, indent)
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if indent then ppr = ppr .. '<w:ind w:left="' .. indent .. '"/>' end
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr><w:r><w:t xml:space="preserve">' .. xml_escape(s) .. '</w:t></w:r></w:p>'
end

local function cell(width, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. paras .. '</w:tc>'
end

-- caption: parties left (4680 twips = 3.25 in), gutter (432 = 0.3 in), case number right (4248)
local function caption(meta)
  local left = {}
  local parties = meta.caption and meta.caption.parties or {}
  for k, p in ipairs(parties) do
    if k > 1 then left[#left + 1] = xp("Single", "v.", "1080") end
    for _, n in ipairs(p.names or {}) do left[#left + 1] = xp("Single", text(n)) end
    left[#left + 1] = xp("Single", text(p.designation), "2160")
  end
  local num = text(meta.case_number)
  if num == "" then num = "____________" end
  local right = { xp("Single", "Case No. " .. num, "144") }
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="432"/><w:gridCol w:w="4248"/></w:tblGrid>'
    .. '<w:tr>' .. cell(4680, table.concat(left))
    .. cell(432, '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p>')
    .. cell(4248, table.concat(right)) .. '</w:tr></w:tbl>')
end

-- signature block: "Dated this ...", then the firm, role, signature lines and contact block in the right
-- half of the page (left indent 3.0 in). Mirrors signature-block() in the typst template.
local function signature(meta)
  local s = meta.signature or {}
  local out = { styled_line("Single", "Dated this " .. text(meta.date) .. ".") }
  out[#out + 1] = blank("Double")
  out[#out + 1] = styled_line("SigBlock", text(s.firm))
  out[#out + 1] = styled_line("SigBlock", text(s.role))
  out[#out + 1] = styled("SigBlock", { pandoc.Para({}) })
  for _, sg in ipairs(s.signers or {}) do
    out[#out + 1] = styled_line("SigBlock", "s/ " .. text(sg.name))
    out[#out + 1] = styled_line("SigBlock", text(sg.name))
    out[#out + 1] = styled_line("SigBlock", text(sg.bar))
    out[#out + 1] = styled("SigBlock", { pandoc.Para({}) })
  end
  for _, a in ipairs(s.address or {}) do out[#out + 1] = styled_line("SigBlock", text(a)) end
  out[#out + 1] = styled_line("SigBlock", "Telephone: " .. text(s.telephone))
  for _, sg in ipairs(s.signers or {}) do
    out[#out + 1] = styled_line("SigBlock", "E-mail: " .. text(sg.email))
  end
  return out
end

-- an argument heading "I. TEXT": the numeral, a tab to the hanging column (1 in), then the text
local function hanging_numeral(h)
  local c = h.content
  if c[1] and c[1].t == "Str" and c[1].text:match("^[IVX]+%.$") and c[2] and c[2].t == "Space" then
    c[2] = pandoc.RawInline("openxml", TAB)
  end
  return h
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}

  -- cover: court title, caption, document title (typst cover())
  out[#out + 1] = styled_line("Centered", "UNITED STATES DISTRICT COURT")
  out[#out + 1] = styled_line("Centered", "FOR THE EASTERN DISTRICT OF WISCONSIN")
  out[#out + 1] = blank()
  out[#out + 1] = caption(meta)
  out[#out + 1] = blank()
  out[#out + 1] = styled("Centered", { pandoc.Para({ pandoc.Strong(words(string.upper(text(meta.document_title))))}) })
  out[#out + 1] = blank()

  -- body: unnumbered; headings and quotations keep their markdown structure
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 2 then
      out[#out + 1] = hanging_numeral(b)
    else
      out[#out + 1] = b
    end
  end

  -- signature block
  out[#out + 1] = blank()
  for _, p in ipairs(signature(meta)) do out[#out + 1] = p end

  -- empty metadata: no pandoc title block, and no "date" line from the YAML
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
