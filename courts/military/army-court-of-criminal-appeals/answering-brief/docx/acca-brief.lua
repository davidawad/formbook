-- ACCA brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors the typst template (typst/acca-*.typ): the cover (caption, docket, trial line, title, counsel),
-- the signature block, the certificate of filing and service, and the optional appendix are built here from
-- the YAML frontmatter; the body keeps its markdown structure. Page numbers come from reference.docx
-- (none on the cover). Nothing here is case-specific: every string comes from the frontmatter or CFG.

-- The only part that differs between the two doc types (see the README, "Engines").
local CFG = {
  brief_title = "BRIEF ON BEHALF OF THE UNITED STATES",
  court_line = "IN THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS",
  cert_recipients = "the Court and to appellate defense counsel for the appellant",
}

-- XML text escaping for the raw WordprocessingML paragraphs below
local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a YAML list of inline values as a Lua list of plain strings
local function items(v)
  local out = {}
  if v == nil then return out end
  for _, x in ipairs(v) do out[#out + 1] = plain(x) end
  return out
end

-- one raw paragraph in a reference.docx style; o: bold, before, after, indent, keep
local function para(text, style, o)
  o = o or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if o.keep then ppr = ppr .. "<w:keepNext/><w:keepLines/>" end
  if o.before or o.after then
    ppr = ppr .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '"/>'
  end
  if o.indent then
    ppr = ppr .. '<w:ind w:left="' .. o.indent .. '" w:right="' .. o.indent .. '" w:firstLine="0"/>'
  end
  local rpr = o.bold and "<w:b/><w:bCs/>" or ""
  return pandoc.RawBlock("openxml", "<w:p><w:pPr>" .. ppr .. "</w:pPr><w:r><w:rPr>" .. rpr
    .. '</w:rPr><w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>")
end

-- a page break that starts the next page (a 1 pt paragraph carries the break)
local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'
    .. '<w:rPr><w:sz w:val="2"/></w:rPr></w:pPr><w:r><w:rPr><w:sz w:val="2"/></w:rPr><w:br w:type="page"/></w:r></w:p>')
end

-- the counsel blocks, two to a row, as a borderless table (the typst cover uses a two-column grid)
local function counsel_table(counsel)
  local col = 4680
  local rows = {}
  local function cell(lines)
    local ps = {}
    for _, l in ipairs(lines) do
      ps[#ps + 1] = '<w:p><w:pPr><w:pStyle w:val="CoverLine"/></w:pPr><w:r><w:t xml:space="preserve">'
        .. esc(l) .. "</w:t></w:r></w:p>"
    end
    if #ps == 0 then ps[1] = '<w:p><w:pPr><w:pStyle w:val="CoverLine"/></w:pPr></w:p>' end
    return '<w:tc><w:tcPr><w:tcW w:w="' .. col .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. "</w:tc>"
  end
  for i = 1, #counsel, 2 do
    local right = counsel[i + 1] and cell(items(counsel[i + 1].lines)) or cell({})
    rows[#rows + 1] = "<w:tr>" .. cell(items(counsel[i].lines)) .. right .. "</w:tr>"
  end
  local nil_border = '<w:%s w:val="nil"/>'
  local borders = {}
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    borders[#borders + 1] = string.format(nil_border, side)
  end
  return pandoc.RawBlock("openxml", '<w:tbl><w:tblPr><w:tblW w:w="' .. 2 * col .. '" w:type="dxa"/>'
    .. "<w:tblBorders>" .. table.concat(borders) .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="216" w:type="dxa"/></w:tblCellMar>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. col .. '"/><w:gridCol w:w="' .. col .. '"/></w:tblGrid>'
    .. table.concat(rows) .. "</w:tbl>")
end

local function cover(meta, out)
  local app = meta.appellant
  if not app or not meta.docket or not meta.trial or not meta.counsel then
    error("acca-brief: the frontmatter needs appellant, docket, trial and counsel", 0)
  end
  out[#out + 1] = para(CFG.court_line, "Centered", { bold = true })
  out[#out + 1] = para("UNITED STATES,", "CoverLine", { before = 1728 })
  out[#out + 1] = para("Appellee,", "CoverLine")
  out[#out + 1] = para("v.", "Centered", { before = 240 })
  out[#out + 1] = para(plain(app.name) .. ",", "CoverLine", { before = 240 })
  out[#out + 1] = para(plain(app.rank), "CoverLine")
  out[#out + 1] = para(plain(app.service) .. ",", "CoverLine")
  out[#out + 1] = para("Appellant.", "CoverLine")
  out[#out + 1] = para(plain(meta.docket), "Centered", { bold = true, before = 1296 })
  out[#out + 1] = para(CFG.brief_title, "Centered", { bold = true, before = 1296 })
  local t = meta.trial
  out[#out + 1] = para("Tried at " .. plain(t.place) .. ", on " .. plain(t.dates) .. ", before a "
    .. plain(t["court-type"]) .. " court-martial appointed by " .. plain(t.convening) .. ".",
    "Centered", { before = 1440, after = 2880, indent = 1368 })
  out[#out + 1] = counsel_table(meta.counsel)
  out[#out + 1] = page_break()
end

local function closing(meta, out)
  local sig = items(meta.signature)
  for i, line in ipairs(sig) do
    out[#out + 1] = para(line, "SigBlock", { keep = i < #sig, before = i == 1 and 240 or 0 })
  end
  out[#out + 1] = page_break()
  out[#out + 1] = para("CERTIFICATE OF FILING AND SERVICE", "Centered", { bold = true, after = 240 })
  local cert = meta.certificate
  if not cert then error("acca-brief: the frontmatter needs certificate", 0) end
  out[#out + 1] = pandoc.Para({ pandoc.Str("I certify that a copy of the foregoing was mailed or delivered to "
    .. CFG.cert_recipients .. " on " .. plain(cert.date) .. ".") })
  local csig = items(cert.signature)
  for i, line in ipairs(csig) do
    out[#out + 1] = para(line, "SigBlock", { keep = i < #csig, before = i == 1 and 480 or 0 })
  end
  if meta.appendix and #meta.appendix > 0 then
    out[#out + 1] = page_break()
    out[#out + 1] = para("APPENDIX", "Centered", { bold = true, after = 240 })
    for _, item in ipairs(items(meta.appendix)) do
      out[#out + 1] = para(item, "Single")
    end
  end
end

function Pandoc(doc)
  local out = {}
  cover(doc.meta, out)
  -- the body: the markdown blocks as they are; the last paragraph stays with the signature block
  local body = doc.blocks
  for i, b in ipairs(body) do
    if i == #body and b.t == "Para" then
      b = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Body Keep Next" }))
    end
    out[#out + 1] = b
  end
  closing(doc.meta, out)
  doc.blocks = out
  return doc
end
