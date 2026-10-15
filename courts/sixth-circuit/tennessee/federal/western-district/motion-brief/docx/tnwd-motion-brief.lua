-- W.D. Tenn. memorandum in support of a motion (motion-brief), DOCX engine (docs/DOCX.md): the markdown contract of
-- samples/INPUT-<id>.md -> Word. Mirrors typst/tnwd-motion-brief.typ: court title (single), caption (parties with a
-- rule at the right of the party column, the file number opposite), the title, the body (paragraphs unnumbered,
-- double spaced, first line indented), section headings (centred bold), point headings (the label hung at the
-- margin, the text wrapped under it), block quotations (single spaced), the signature block (kept together), and
-- the certificate of service (kept together). Styles come from reference.docx (build-reference.sh).
-- Content-agnostic: every word comes from the frontmatter.

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, bold)
  return "<w:r>" .. (bold and "<w:rPr><w:b/></w:rPr>" or "") .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- a paragraph: style, runs, and direct paragraph properties in schema order (keepNext, pBdr, spacing, ind, jc)
local function P(style, body, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (body or "") .. "</w:p>"
end

-- an exact-height empty line (the typst v() gaps); keep = keep with the next paragraph
local function gap(twips, keep)
  return P("Single", "", (keep and "<w:keepNext/>" or "")
    .. '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/>')
end

local function line(text, ppr, bold, keep)
  return P("Single", run(text, bold), (keep and "<w:keepNext/>" or "") .. (ppr or ""))
end

local function ind(left, right)
  return '<w:ind w:left="' .. left .. '" w:right="' .. (right or 0) .. '" w:firstLine="0"/>'
end

local function tc(width, paras, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. (mar or "")
    .. "</w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

local function tbl(widths, cells)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid)
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

-- the caption: parties (3.3 in) | rule (0.3 in) | file number and the rest (2.9 in)
local function caption(meta)
  local left = {}
  for idx, side in ipairs(meta.caption) do
    if idx > 1 then
      left[#left + 1] = gap(276)
      left[#left + 1] = line("v.")
      left[#left + 1] = gap(276)
    end
    for _, n in ipairs(side.names) do left[#left + 1] = line(str(n)) end
    left[#left + 1] = line(str(side.designation), ind(1800))
  end
  local cn = str(meta.case_number)
  local right = { gap(552) }
  if cn ~= "" then
    right[#right + 1] = line("No. " .. cn)
  else
    right[#right + 1] = P("Single", run("No.") .. "<w:r><w:tab/></w:r>", '<w:tabs><w:tab w:val="left" w:leader="underscore" w:pos="2304"/></w:tabs>')
  end
  return raw(tbl({ 4752, 432, 4176 }, {
    tc(4752, left),
    tc(432, { line("") }, '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'),
    tc(4176, right, nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'),
  }))
end

-- the signature block (LR 11.1(b)): "Dated:" (optional) at the left, the rest in the right half (3.25 in)
local function signature(meta)
  local sig = meta.signature
  local out = { gap(380, true) }
  if meta.date then
    out[#out + 1] = line("Dated: " .. str(meta.date), nil, false, true)
    out[#out + 1] = gap(828, true)
  else
    out[#out + 1] = gap(328, true)
  end
  local right = ind(4680)
  out[#out + 1] = line("Respectfully submitted,", right, false, true)
  out[#out + 1] = gap(828, true)
  if sig.firm then out[#out + 1] = line(str(sig.firm), right, false, true) end
  out[#out + 1] = gap(552, true)
  out[#out + 1] = line("s/ " .. str(sig.signer), right, false, true)
  out[#out + 1] = line("Attorney Bar No. " .. str(sig.bar_number), right, false, true)
  for i, l in ipairs(sig.lines) do
    out[#out + 1] = line(str(l), right, false, i < #sig.lines)
  end
  return out
end

-- the certificate of service (kept together): heading, the method, the persons served, DATE, the signature
local function certificate(cert, title, sig)
  local out = { P("Centered", run("CERTIFICATE OF SERVICE", true), '<w:keepNext/><w:spacing w:before="434" w:after="0" w:line="276" w:lineRule="exact"/>'), gap(828, true) }
  local doc = cert.document and str(cert.document) or str(title)
  out[#out + 1] = P("Single", run("The undersigned hereby certifies that a true and correct copy of the foregoing "
    .. doc .. " was " .. str(cert.method) .. " upon:"), '<w:keepNext/><w:spacing w:before="0" w:after="276" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="720"/>')
  local served = cert.served_on or {}
  for i, l in ipairs(served) do out[#out + 1] = line(str(l), ind(720), false, true) end
  out[#out + 1] = gap(828, true)
  if cert.date then
    out[#out + 1] = line("DATE: " .. str(cert.date), nil, false, true)
    out[#out + 1] = gap(828, true)
  end
  if sig.firm then out[#out + 1] = line(str(sig.firm), ind(4680), false, true) end
  out[#out + 1] = gap(552, true)
  out[#out + 1] = line("s/ " .. str(sig.signer), ind(4680))
  return out
end

-- a point heading: "I. TEXT" hangs the label at the margin and wraps the text at 1/2 inch
local function point_heading(b)
  local c = b.content
  local label = c[1] and c[1].t == "Str" and c[1].text:match("^[IVXLC]+%.$") or (c[1] and c[1].t == "Str" and c[1].text:match("^[A-Z]%.$"))
    or (c[1] and c[1].t == "Str" and c[1].text:match("^%d+%.$"))
  if not label or not c[2] or c[2].t ~= "Space" then
    return b
  end
  local content = { pandoc.Str(c[1].text), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
  for i = 3, #c do content[#content + 1] = c[i] end
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Point Heading" }))
end

local function strip_space(para) return para end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  add(raw(line("IN THE UNITED STATES DISTRICT COURT", '<w:jc w:val="center"/>')))
  add(raw(line("FOR THE WESTERN DISTRICT OF TENNESSEE", '<w:jc w:val="center"/>')))
  if meta.court_division and str(meta.court_division) ~= "" then
    add(raw(line(str(meta.court_division), '<w:jc w:val="center"/>')))
  end
  add(raw(gap(828)))
  add(caption(meta))
  add(raw(gap(728)))
  add(raw(P("Single", run(str(meta.title), true), '<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:jc w:val="center"/>')))
  add(raw(gap(768)))

  local last = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      add(b)
    elseif b.t == "Header" then
      add(point_heading(b))
    elseif b.t == "Para" then
      add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = i == last and "Body End" or "Body Text" })))
    elseif b.t == "BlockQuote" then
      add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Block Text" })))
    else
      add(b)
    end
  end

  for _, r in ipairs(signature(meta)) do add(raw(r)) end
  if meta.certificate then
    for _, r in ipairs(certificate(meta.certificate, meta.title, meta.signature)) do add(raw(r)) end
  end

  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = out
  return doc
end
