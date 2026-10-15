-- U.S. District Court for the District of Idaho (idd), complaint: pandoc filter for the docx engine.
-- Same content as the typst template of this doc type, from the same markdown contract. pandoc writes the body;
-- this filter writes the cover (counsel, court title, caption, title, jury notation), the lead-in, the numbered
-- paragraphs (Fed. R. Civ. P. 10(b)), the lettered prayer items and the signature block as WordprocessingML.
-- Styles (EB Garamond 12 pt, exact 24 pt body and heading lines, single-spaced cover) come from reference.docx.
-- Not produced here (see README.md, Engines): the case title in the footer, the 4-inch caption position.

local function esc(s)
  local a = s:gsub("&", "&amp;")
  local b = a:gsub("<", "&lt;")
  local c = b:gsub(">", "&gt;")
  return c
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- One WordprocessingML paragraph. opts: pstyle, jc, ind_left, ind_first (twips), bold, after (twips).
local function para_xml(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.pstyle then ppr = ppr .. '<w:pStyle w:val="' .. opts.pstyle .. '" />' end
  if opts.ind_left or opts.ind_first then
    ppr = ppr .. '<w:ind' .. (opts.ind_left and (' w:left="' .. opts.ind_left .. '"') or '')
      .. (opts.ind_first and (' w:firstLine="' .. opts.ind_first .. '"') or '') .. ' />'
  end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '" />' end
  local rpr = opts.bold and "<w:rPr><w:b /></w:rPr>" or ""
  local run = (s == "") and "" or ('<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>')
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. run .. '</w:p>'
end

local function p(s, opts) return pandoc.RawBlock("openxml", para_xml(s, opts)) end

-- A borderless two-column layout table (signature block) or the caption table (left cell ruled on its right and
-- bottom, as LR 5.2 captions are drawn in the typst template). left_xml and right_xml are paragraph XML strings.
local function table_xml(widths, cells_xml, ruled_left)
  local grid = ""
  for _, w in ipairs(widths) do grid = grid .. '<w:gridCol w:w="' .. w .. '" />' end
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local row = ""
  for i, c in ipairs(cells_xml) do
    local tcpr = '<w:tcW w:w="' .. widths[i] .. '" w:type="dxa" />'
    if ruled_left and i == 1 then
      tcpr = tcpr .. '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000" />'
        .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000" /></w:tcBorders>'
        .. '<w:tcMar><w:right w:w="144" w:type="dxa" /><w:bottom w:w="115" w:type="dxa" /></w:tcMar>'
    end
    row = row .. '<w:tc><w:tcPr>' .. tcpr .. '</w:tcPr>' .. c .. '</w:tc>'
  end
  return pandoc.RawBlock("openxml", '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa" />'
    .. '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" />'
    .. '<w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders><w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" /></w:tblPr><w:tblGrid>' .. grid .. '</w:tblGrid><w:tr>' .. row .. '</w:tr></w:tbl>')
end

local function counsel_blocks(meta)
  local out = {}
  for _, l in ipairs(meta.counsel or {}) do
    local s = text(l)
    out[#out + 1] = p(s, { pstyle = "SingleSpaced" })
  end
  return out
end

local function caption_block(meta)
  local left = ""
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left = left .. para_xml("v.", { pstyle = "SingleSpaced" }) end
    for _, n in ipairs(party.names) do left = left .. para_xml(text(n), { pstyle = "SingleSpaced" }) end
    left = left .. para_xml(text(party.designation), { pstyle = "SingleSpaced", after = 0 })
  end
  local right = para_xml("Case No. " .. text(meta.case_number), { pstyle = "SingleSpaced", ind_left = 144 })
    .. para_xml("", { pstyle = "SingleSpaced", ind_left = 144 })
    .. para_xml(text(meta.brief_title), { pstyle = "SingleSpaced", ind_left = 144, bold = true })
  if meta.jury_demand then
    -- LR 38.1: the notation goes on the front page immediately following the title.
    right = right .. para_xml("", { pstyle = "SingleSpaced", ind_left = 144 })
      .. para_xml("DEMAND FOR JURY TRIAL", { pstyle = "SingleSpaced", ind_left = 144, bold = true })
  end
  return table_xml({ 4680, 360, 4320 }, { left, "<w:p />", right }, true)
end

local function cover(meta)
  local out = counsel_blocks(meta)
  out[#out + 1] = p("", { pstyle = "BodyText" })
  out[#out + 1] = p("", { pstyle = "BodyText" })
  for _, l in ipairs(meta.caption.court) do
    out[#out + 1] = p(text(l), { pstyle = "CourtTitle" })
  end
  out[#out + 1] = p("", { pstyle = "BodyText" })
  out[#out + 1] = caption_block(meta)
  out[#out + 1] = p("", { pstyle = "BodyText" })
  return out
end

local function signature(meta, lead, sig_lines)
  local left = ""
  local right = ""
  for _, l in ipairs(lead) do right = right .. para_xml(l, { pstyle = "SingleSpaced" }) end
  right = right .. para_xml("", { pstyle = "SingleSpaced" }) .. para_xml("", { pstyle = "SingleSpaced" })
  for _, l in ipairs(meta.signature.firm) do right = right .. para_xml(text(l), { pstyle = "SingleSpaced" }) end
  right = right .. para_xml("", { pstyle = "SingleSpaced" }) .. para_xml("", { pstyle = "SingleSpaced" })
  right = right .. para_xml("/s/ " .. text(meta.signature.signer), { pstyle = "SingleSpaced" })
  for _, l in ipairs(sig_lines) do right = right .. para_xml(text(l), { pstyle = "SingleSpaced" }) end
  left = para_xml("DATED this " .. text(meta.signing_date) .. ".", { pstyle = "SingleSpaced" })
  return { p("", { pstyle = "BodyText" }), table_xml({ 4176, 288, 4896 }, { left, "<w:p />", right }, false) }
end

function Pandoc(doc)
  local m = doc.meta
  -- pandoc would print the date as a title block at the top; the date is used only in the signature.
  m.signing_date = m.date
  m.date = nil
  local out = cover(m)

  if m.lead_in then
    out[#out + 1] = p(text(m.lead_in), { pstyle = "BodyText" })
  end

  -- Body: numbered paragraphs (each non-heading, non-list paragraph), lettered prayer items.
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      table.insert(b.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>"))
      table.insert(b.content, 1, pandoc.Str(tostring(n) .. "."))
      out[#out + 1] = b
    elseif b.t == "OrderedList" then
      b.listAttributes.style = "LowerAlpha"
      b.listAttributes.delimiter = "TwoParens"
      out[#out + 1] = b
    else
      out[#out + 1] = b
    end
  end

  -- Signature block (typst: "DATED this ..." beside the firm's signature lines).
  for _, b in ipairs(signature(m, { "Respectfully submitted," }, m.signature.lines)) do out[#out + 1] = b end

  return pandoc.Pandoc(out, m)
end
