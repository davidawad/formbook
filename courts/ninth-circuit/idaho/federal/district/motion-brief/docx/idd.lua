-- U.S. District Court for the District of Idaho (idd), memorandum in support of a motion: pandoc filter for the docx
-- engine. Same content as the typst template of this doc type, from the same markdown contract. pandoc writes the
-- body and its footnotes; this filter writes the cover (counsel, court title, caption, title and the motion's docket
-- number), the signature block and the certificate of service as WordprocessingML.
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

-- One WordprocessingML paragraph. opts: pstyle, jc, ind_left, ind_first (twips), bold.
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
-- bottom, as the typst caption is drawn). cells_xml holds paragraph XML strings.
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

local function cover(meta)
  local out = {}
  for _, l in ipairs(meta.counsel or {}) do
    out[#out + 1] = p(text(l), { pstyle = "SingleSpaced" })
  end
  out[#out + 1] = p("", { pstyle = "BodyText" })
  out[#out + 1] = p("", { pstyle = "BodyText" })
  for _, l in ipairs(meta.caption.court) do
    out[#out + 1] = p(text(l), { pstyle = "CourtTitle" })
  end
  out[#out + 1] = p("", { pstyle = "BodyText" })

  local left = ""
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left = left .. para_xml("v.", { pstyle = "SingleSpaced" }) end
    for _, n in ipairs(party.names) do left = left .. para_xml(text(n), { pstyle = "SingleSpaced" }) end
    left = left .. para_xml(text(party.designation), { pstyle = "SingleSpaced" })
  end
  local right = para_xml("Case No. " .. text(meta.case_number), { pstyle = "SingleSpaced", ind_left = 144 })
    .. para_xml("", { pstyle = "SingleSpaced", ind_left = 144 })
    .. para_xml(text(meta.brief_title), { pstyle = "SingleSpaced", ind_left = 144, bold = true })
  if meta.motion_docket and meta.motion_docket ~= "" then
    -- LR 7.1(a)(3): a paper filed in support of a motion carries that motion's docket number in the caption.
    right = right .. para_xml("", { pstyle = "SingleSpaced", ind_left = 144 })
      .. para_xml("[" .. text(meta.motion_docket) .. "]", { pstyle = "SingleSpaced", ind_left = 144, bold = true })
  end
  out[#out + 1] = table_xml({ 4680, 360, 4320 }, { left, "<w:p />", right }, true)
  out[#out + 1] = p("", { pstyle = "BodyText" })
  return out
end

local function signature(meta, sig_lines)
  local left = para_xml("Dated: " .. text(meta.signing_date), { pstyle = "SingleSpaced" })
  local right = para_xml("Respectfully submitted,", { pstyle = "SingleSpaced" })
    .. para_xml("", { pstyle = "SingleSpaced" }) .. para_xml("", { pstyle = "SingleSpaced" })
  for _, l in ipairs(meta.signature.firm) do right = right .. para_xml(text(l), { pstyle = "SingleSpaced" }) end
  right = right .. para_xml("", { pstyle = "SingleSpaced" }) .. para_xml("", { pstyle = "SingleSpaced" })
  right = right .. para_xml("/s/ " .. text(meta.signature.signer), { pstyle = "SingleSpaced" })
  for _, l in ipairs(sig_lines) do right = right .. para_xml(text(l), { pstyle = "SingleSpaced" }) end
  return { p("", { pstyle = "BodyText" }), table_xml({ 4176, 288, 4896 }, { left, "<w:p />", right }, false) }
end

local function certificate(meta)
  local out = {}
  -- Its own page (convention; LR 5.2 is silent), headed like the body headings.
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page" /></w:r></w:p>')
  out[#out + 1] = p("CERTIFICATE OF SERVICE", { pstyle = "Heading1" })
  out[#out + 1] = p(text(meta.certificate.text), { pstyle = "BodyText" })
  local right = para_xml("/s/ " .. text(meta.certificate.signer), { pstyle = "SingleSpaced" })
  for _, l in ipairs(meta.certificate.lines) do right = right .. para_xml(text(l), { pstyle = "SingleSpaced" }) end
  out[#out + 1] = p("", { pstyle = "BodyText" })
  out[#out + 1] = table_xml({ 4176, 288, 4896 }, { "<w:p />", "<w:p />", right }, false)
  return out
end

function Pandoc(doc)
  local m = doc.meta
  -- pandoc would print the date as a title block at the top; the date is used only in the signature.
  m.signing_date = m.date
  m.date = nil
  local out = cover(m)
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  for _, b in ipairs(signature(m, m.signature.lines)) do out[#out + 1] = b end
  if m.certificate then
    for _, b in ipairs(certificate(m)) do out[#out + 1] = b end
  end
  return pandoc.Pandoc(out, m)
end
