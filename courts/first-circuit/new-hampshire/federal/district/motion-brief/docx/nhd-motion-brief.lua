-- Motion to dismiss with accompanying memorandum of law (nhd), DOCX engine (docs/DOCX.md): the markdown contract ->
-- Word on reference.docx. Mirrors motion-brief/typst/nhd-motion-brief.typ. The cover (court title, caption table with
-- the column of ")" marks, title of the paper), the signature block and the certificate of service are built here from
-- the sample's frontmatter, in the styles that build-reference.sh defines. The body is pandoc's own paragraphs and
-- headings; lists are lettered. Every case word comes from doc.meta; nothing case-specific is in this file.
-- Known limits: the caption is a borderless table; the party names are plain text (no inline markup).

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text_of(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- one XML paragraph in a named style
local function xml_para(style, s)
  local run = s == "" and "" or ('<w:r><w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>')
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. run .. '</w:p>'
end

local function raw_para(style, s)
  return pandoc.RawBlock("openxml", xml_para(style, s))
end

local function gap(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. (style or "Gap") .. '"/></w:pPr></w:p>')
end

local function cell(width, content)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. content .. '</w:tc>'
end

local EMPTY = '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p>'

-- Caption (LR 5.1(c)): one single-spaced row per line of the party block, "v." between the parties, a ")" in the
-- middle column of each row, and the case number on the middle row (the typst grid, as a borderless table).
-- Widths: 3.7 in names, 0.3 in ")", the rest for the case number.
local function caption(meta)
  local rows = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then rows[#rows + 1] = "v." end
    for _, n in ipairs(p.names or {}) do rows[#rows + 1] = text_of(n) end
    rows[#rows + 1] = text_of(p.designation)
  end
  local mid = math.floor(#rows / 2)  -- 0-based, as the typst template
  local trs = {}
  for i, r in ipairs(rows) do
    local case = (i - 1 == mid) and xml_para("Single", text_of(meta.case_number)) or EMPTY
    trs[#trs + 1] = '<w:tr>' .. cell(5328, xml_para("Single", r)) .. cell(432, xml_para("Single", ")")) .. cell(3600, case) .. '</w:tr>'
  end
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5328"/><w:gridCol w:w="432"/><w:gridCol w:w="3600"/></w:tblGrid>'
    .. table.concat(trs) .. '</w:tbl>'
  return pandoc.RawBlock("openxml", xml)
end

-- Court title (fixed text for the court, as in the typst template), caption, title of the paper.
local function cover(meta)
  return {
    raw_para("CourtTitle", "IN THE UNITED STATES DISTRICT COURT"),
    raw_para("CourtTitle", "FOR THE DISTRICT OF NEW HAMPSHIRE"),
    gap("GapHalf"),
    caption(meta),
    raw_para("CoverTitle", text_of(meta.title)),
  }
end

-- Signature block (LR 5.1(b)): groups of single-spaced lines at the right half of the page, a full line apart.
local function signature(meta)
  local s = meta.signature
  if not s then error("nhd-motion-brief: the sample needs a signature block (LR 5.1(b))") end
  local groups = { { text_of(s.intro) } }
  if s.party then
    local g = {}
    for _, l in ipairs(s.party) do g[#g + 1] = text_of(l) end
    groups[#groups + 1] = g
  end
  if s.date then groups[#groups + 1] = { text_of(s.date) } end
  groups[#groups + 1] = { "/s/ " .. text_of(s.signer) }
  for _, b in ipairs(s.blocks or {}) do
    local g = {}
    for _, l in ipairs(b) do g[#g + 1] = text_of(l) end
    groups[#groups + 1] = g
  end
  local out = {}
  for _, g in ipairs(groups) do
    out[#out + 1] = gap("SigGap")
    for _, l in ipairs(g) do out[#out + 1] = raw_para("SigBlock", l) end
  end
  return out
end

-- LR 5.1(d) and Fed. R. Civ. P. 5(d)(1): the certificate of service, personally signed by counsel.
local function certificate(meta)
  local cert = meta.certificate
  local out = { gap("SigGap"), pandoc.Header(1, { pandoc.Str("Certificate of Service") }) }
  out[#out + 1] = raw_para("CertText", text_of(cert.text))
  out[#out + 1] = gap("SigGap")
  for _, l in ipairs(cert.signer) do out[#out + 1] = raw_para("SigBlock", text_of(l)) end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = cover(meta)

  for _, b in ipairs(doc.blocks) do
    if b.t == "OrderedList" then
      -- lettered items (a), (b), ... with a hanging indent: marker at 0.5 in, text at 1.1 in (the typst enum)
      local start = b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        for j, blk in ipairs(item) do
          if j == 1 and (blk.t == "Para" or blk.t == "Plain") then
            local marker = "(" .. string.char(96 + start + i - 1) .. ")"
            local content = { pandoc.Str(marker), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
            for _, x in ipairs(blk.content) do content[#content + 1] = x end
            out[#out + 1] = styled("List Item", { pandoc.Para(content) })
          else
            out[#out + 1] = styled("List Item", { blk })
          end
        end
      end
    else
      out[#out + 1] = b
    end
  end

  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  if meta.certificate then
    for _, b in ipairs(certificate(meta)) do out[#out + 1] = b end
  end
  -- empty metadata: pandoc would otherwise write the frontmatter title as a Title paragraph
  return pandoc.Pandoc(out, {})
end
