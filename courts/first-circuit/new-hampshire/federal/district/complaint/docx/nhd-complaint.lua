-- Complaint for the D.N.H. (nhd), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors complaint/typst/nhd-complaint.typ. The cover (court title, caption table, title of the paper), the
-- signature block and the numbering are built here from the sample's frontmatter, in the styles that
-- build-reference.sh defines. Every case word comes from doc.meta; nothing case-specific is in this file.
-- Numbered allegations: body paragraphs get the "Allegation" style; the number is typed text and a tab to the style tab stop.
-- Lettered lists: ordered items are typed (a), (b), ... with a hanging indent ("ListItem" style).
-- A "~ " paragraph (WHEREFORE, the jury demand) is unnumbered body text.
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

-- one XML paragraph in a named style; `bold` makes the run bold
local function xml_para(style, s, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local run = s == "" and "" or ('<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>')
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. run .. '</w:p>'
end

local function raw_para(style, s)
  return pandoc.RawBlock("openxml", xml_para(style, s))
end

local function gap(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. (style or "Gap") .. '"/></w:pPr></w:p>')
end

local function cell(width, content, valign)
  local v = valign and ('<w:vAlign w:val="' .. valign .. '"/>') or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. v .. '</w:tcPr>' .. content .. '</w:tc>'
end

local function empty_cell(width)
  return cell(width, '<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p>')
end

-- Caption (LR 5.1(c)): party names and designations on the left, one single-spaced line each, "v." between the
-- parties; the case number (and JURY TRIAL DEMANDED) on the right, set down to the line the filed caption uses.
-- Borderless table: the widths are 3.4 in, 0.3 in gutter, the rest.
local function caption(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = xml_para("Single", "v.") end
    for _, n in ipairs(p.names or {}) do left[#left + 1] = xml_para("Single", text_of(n)) end
    left[#left + 1] = xml_para("Single", text_of(p.designation))
  end
  local right = xml_para("CaseNo", text_of(meta.case_number))
  if meta.jury_demand then right = right .. xml_para("Single", "JURY TRIAL DEMANDED", true) end
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="432"/><w:gridCol w:w="4032"/></w:tblGrid><w:tr>'
    .. cell(4896, table.concat(left))
    .. empty_cell(432)
    .. cell(4032, right)
    .. '</w:tr></w:tbl>'
  return pandoc.RawBlock("openxml", xml)
end

-- Court title (fixed text for the court, as in the typst template), caption, title of the paper.
local function cover(meta)
  local out = {
    raw_para("CourtTitle", "IN THE UNITED STATES DISTRICT COURT"),
    raw_para("CourtTitle", "FOR THE DISTRICT OF NEW HAMPSHIRE"),
    gap("GapHalf"),
    caption(meta),
    raw_para("CoverTitle", text_of(meta.title)),
  }
  return out
end

-- Signature block (LR 5.1(b)): groups of single-spaced lines at the right half of the page, a full line apart.
local function signature(meta)
  local s = meta.signature
  if not s then error("nhd-complaint: the sample needs a signature block (LR 5.1(b))") end
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

local function unnumbered(inlines)
  return styled("Body Text", { pandoc.Para(inlines) })
end

function Pandoc(doc)
  local meta = doc.meta
  local out = cover(meta)

  if meta.lead_in then
    out[#out + 1] = styled("Body Text", { pandoc.Para(meta.lead_in) })
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local first = b.content[1]
      if first and first.t == "Str" and first.text == "~" then
        -- "~ " paragraph: unnumbered (WHEREFORE, the jury demand); drop the marker and the space after it
        local rest = {}
        for i = 2, #b.content do rest[#rest + 1] = b.content[i] end
        if rest[1] and rest[1].t == "Space" then table.remove(rest, 1) end
        out[#out + 1] = unnumbered(rest)
      else
        -- Fed. R. Civ. P. 10(b): each body paragraph is a numbered allegation. The number is typed text followed by a
        -- tab to the tab stop of the "Allegation" style (pandoc drops numbering from a reference.docx).
        n = n + 1
        local content = { pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        for _, i in ipairs(b.content) do content[#content + 1] = i end
        out[#out + 1] = styled("Allegation", { pandoc.Para(content) })
      end
    elseif b.t == "OrderedList" then
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
  -- empty metadata: pandoc would otherwise write the frontmatter title as a Title paragraph
  return pandoc.Pandoc(out, {})
end
