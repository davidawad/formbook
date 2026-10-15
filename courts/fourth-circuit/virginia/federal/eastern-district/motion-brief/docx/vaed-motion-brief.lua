-- vaed motion brief (memorandum in support), DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/vaed-motion-brief.typ: court title, party-box caption (a table), the case number, the underlined title,
-- headings (label hangs), paragraphs with a first-line indent, the last paragraph kept with the signature block,
-- the certificate of service on its own page. Nothing is case-specific here.
-- Known differences: the 30-page cap of L.R. 7(F)(3) is a typst build assertion; it is not enforced here (see README).

local CFG = { numbered = false, sig_date_label = "Date: ", underline_title = true }

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a plain string as inlines, words separated by Space (no markdown parsing)
local function words(s)
  local out, first = {}, true
  for w in s:gmatch("%S+") do
    if not first then out[#out + 1] = pandoc.Space() end
    out[#out + 1] = pandoc.Str(w)
    first = false
  end
  return out
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function px(style_id, inner)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style_id .. '"/></w:pPr>' .. (inner or "") .. "</w:p>"
end

local function raw_para(style_id, inner)
  return pandoc.RawBlock("openxml", px(style_id, inner))
end

local function run(text)
  return '<w:r><w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- "I. Title" -> label, tab, title (label hangs in the margin, as in the typst template)
local function label_hang(inls)
  local first, second = inls[1], inls[2]
  if first and first.t == "Str" and second and second.t == "Space"
    and (first.text:match("^[IVX]+%.$") or first.text:match("^[A-Z]%.$") or first.text:match("^%d+%.$")) then
    local out = { pandoc.Str(first.text), TAB }
    for k = 3, #inls do out[#out + 1] = inls[k] end
    return out
  end
  return inls
end

local function upper_inlines(inls)
  return pandoc.walk_inline(pandoc.Span(inls), {
    Str = function(s) return pandoc.Str(string.upper(s.text)) end,
  }).content
end

-- the caption: party box (all four sides ruled) on the left, case number on the right
local function caption_table(caption)
  local bd = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:left w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  local left = {}
  local parties = caption.parties
  for i, p in ipairs(parties) do
    for _, line in ipairs(p.lines) do
      left[#left + 1] = px("Single", run(plain(line)))
    end
    if p.designation ~= nil then
      left[#left + 1] = px("CaptionDesignation", run(plain(p.designation)))
    end
    if i < #parties then
      left[#left + 1] = px("CaptionV", run("v."))
    end
  end
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="360"/><w:gridCol w:w="4248"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/><w:tcBorders>' .. bd .. '</w:tcBorders>'
    .. '<w:tcMar><w:top w:w="216" w:type="dxa"/><w:left w:w="216" w:type="dxa"/><w:bottom w:w="216" w:type="dxa"/><w:right w:w="216" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left)
    .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4248" w:type="dxa"/><w:vAlign w:val="center"/></w:tcPr>'
    .. px("Single", run(plain(caption.case_number)))
    .. '</w:tc></w:tr></w:tbl>'
  return pandoc.RawBlock("openxml", xml)
end

-- the signature block: the date line at the margin, the rest at 3.25 in; the last line ends the block
local function signature(sig, date_label)
  local out = {}
  if sig.date ~= nil then
    out[#out + 1] = styled("Sig Dated", words(date_label .. plain(sig.date)))
  end
  if sig.closing ~= nil then out[#out + 1] = styled("Sig Gap", words(plain(sig.closing))) end
  if sig.party ~= nil then out[#out + 1] = styled("Sig Gap", words(plain(sig.party))) end
  if sig.by ~= nil then out[#out + 1] = styled("Sig Gap", words(plain(sig.by))) end
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do
    local style = (i == #lines) and "Sig Last" or "Sig Line"
    out[#out + 1] = styled(style, words(plain(l)))
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- court title, then the caption, then the title of the paper
  for _, line in ipairs(meta.court or {}) do
    add(styled("Court Title", words(plain(line))))
  end
  add(raw_para("Gap12"))
  add(caption_table(meta.caption))
  add(raw_para("Gap12"))
  local title = words(plain(meta.brief_title))
  if CFG.underline_title then title = { pandoc.Underline(title) } end
  add(styled("Caption Title", title))

  -- the unnumbered lead-in paragraph
  if meta.lead_in ~= nil then
    add(pandoc.Para(meta.lead_in))
  end

  -- the body: headings and paragraphs (a brief has no numbered allegations). The last paragraph is kept
  -- with the signature block, so a signature never stands alone on a page.
  local blocks = doc.blocks
  local sig = meta.signature
  for idx, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        b.content = upper_inlines(b.content)
      else
        b.content = label_hang(b.content)
      end
      add(b)
    elseif b.t == "Para" then
      if sig ~= nil and idx == #blocks then
        add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Body Keep" })))
      else
        add(b)
      end
    elseif b.t == "BlockQuote" then
      for _, inner in ipairs(b.content) do add(inner) end
    else
      add(b)
    end
  end

  -- the signature block, kept together
  if sig ~= nil then
    for _, b in ipairs(signature(sig, CFG.sig_date_label)) do add(b) end
  end

  -- the certificate of service on its own page (CertTitle starts a page), then the served list and the signature
  local cert = meta.certificate
  if cert ~= nil then
    add(styled("Cert Title", words(string.upper(plain(cert.title)))))
    add(pandoc.Para(cert.text))
    local served = cert.served or {}
    for i, s in ipairs(served) do
      local style = (i == #served) and "Served Last" or "Served"
      if plain(s) == "" then
        add(raw_para("Served"))
      else
        add(styled(style, words(plain(s))))
      end
    end
    if sig ~= nil then
      for _, b in ipairs(signature(sig, CFG.sig_date_label)) do add(b) end
    end
  end

  return pandoc.Pandoc(out, doc.meta)
end
