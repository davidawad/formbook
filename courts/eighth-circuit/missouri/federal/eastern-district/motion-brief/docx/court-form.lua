-- Court form for the E.D. Mo. docx engine (tools/render-docx.sh passes this as --lua-filter).
-- Mirrors typst/moed-<doctype>.typ: court title band, caption table, title, lead-in, body, signature block.
-- Content comes only from the sample's frontmatter; the layout is in docx/reference.docx (styles) and here.
-- NUMBERED: the template numbers each body paragraph (the complaint); the motion brief is unnumbered prose.
local NUMBERED = false

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function str(v)
  return pandoc.utils.stringify(v)
end

-- A text run; rpr is run formatting (for example "<w:b/>"), optional.
local function run(s, rpr)
  local props = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. props .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

-- A paragraph in a named style; ppr is extra paragraph properties (spacing, jc), in schema order.
local function para(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. inner .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- First page: the court name in the 2 inch band (L.R. 2.01(A)(2)). Each line is exactly 14 pt; the last
-- line's space after brings the band to 1 inch, so the caption starts 2 inches from the top of the page.
local function court_title_xml(m)
  local lines = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF MISSOURI" }
  if m.division then
    lines[#lines + 1] = str(m.division)
  end
  local out = {}
  for i, l in ipairs(lines) do
    local ppr = ""
    if i == #lines then
      ppr = '<w:spacing w:before="0" w:after="' .. (1440 - 280 * #lines) .. '" w:line="280" w:lineRule="exact"/>'
    end
    out[#out + 1] = para("CourtTitleLine", run(l, "<w:b/>"), ppr)
  end
  return table.concat(out)
end

-- The caption: parties in a left column with a right and a bottom rule; case number and legends at right.
local function caption_xml(m)
  local left = {}
  for i, party in ipairs(m.caption.parties) do
    if i > 1 then
      left[#left + 1] = para("CourtCaption", run("v."))
    end
    left[#left + 1] = para("CourtCaption", run(str(party.names)))
    left[#left + 1] = para("CourtCaptionDesignation", run(str(party.designation)))
  end
  local right = {}
  if m.case_number then
    right[#right + 1] = para("CourtCaption", run("Case No. " .. str(m.case_number)),
      '<w:spacing w:before="0" w:after="480" w:line="240" w:lineRule="auto"/>')
  else
    right[#right + 1] = para("CourtCaption", run("Case No. ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:t xml:space="preserve">' .. string.rep("\u{00A0}", 14) .. "</w:t></w:r>",
      '<w:spacing w:before="0" w:after="480" w:line="240" w:lineRule="auto"/>')
  end
  for _, l in ipairs(m.legends or {}) do
    right[#right + 1] = para("CourtCaption", run(str(l), "<w:b/>"))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="432"/><w:gridCol w:w="4176"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/><w:tcBorders>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="auto"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="auto"/>'
    .. '</w:tcBorders><w:tcMar><w:right w:w="216" w:type="dxa"/><w:bottom w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="432" w:type="dxa"/></w:tcPr><w:p/></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. "</w:tc>"
    .. "</w:tr></w:tbl>"
end

-- The title of the paper: bold, centered, double spaced, 24 pt above.
local function title_xml(s)
  return para("CourtTitleLine", run(s, "<w:b/>"),
    '<w:keepNext/><w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/><w:jc w:val="center"/>')
end

-- The signature block (L.R. 2.01(A)(1): name, address, telephone, email and bar number under each signature),
-- at 3.25 inch, single spaced; then the party represented.
local function signature_xml(m)
  local out = {}
  if m.date then
    out[#out + 1] = para("CourtCaption", run("DATED: " .. str(m.date)), '<w:spacing w:before="0" w:after="480" w:line="240" w:lineRule="auto"/>')
  end
  out[#out + 1] = para("CourtSignature", run("Respectfully submitted,"))
  for _, f in ipairs(m.signature) do
    out[#out + 1] = para("CourtSignature", run(str(f.firm), "<w:b/>"), '<w:spacing w:before="240" w:after="120" w:line="240" w:lineRule="auto"/>')
    if f.signer then
      out[#out + 1] = para("CourtSignature", run(str(f.signer)))
    end
    for _, l in ipairs(f.lines) do
      out[#out + 1] = para("CourtSignature", run(str(l)))
    end
  end
  if m.attorneys_for then
    out[#out + 1] = para("CourtSignature", run(str(m.attorneys_for), "<w:i/>"), '<w:spacing w:before="240" w:after="120" w:line="240" w:lineRule="auto"/>')
  end
  return table.concat(out)
end

local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

local function is_certificate(b)
  return b.t == "Header" and b.level == 1 and starts_with(str(b.content), "CERTIFICATE")
end

local function is_signature_line(b)
  return b.t == "Para" and starts_with(str(b.content), "/s/")
end

-- Each lettered item: "(a)" at 0.5 in, text at 1 in, wrapped lines at 1 in.
local function list_div(items)
  local blocks = {}
  for i, item in ipairs(items) do
    local letter = "(" .. string.char(96 + i) .. ")"
    local first = true
    for _, b in ipairs(item) do
      if b.t == "Plain" or b.t == "Para" then
        local content = b.content
        if first then
          table.insert(content, 1, pandoc.RawInline("openxml", run(letter) .. "<w:r><w:tab/></w:r>"))
          first = false
        end
        blocks[#blocks + 1] = pandoc.Para(content)
      else
        blocks[#blocks + 1] = b
      end
    end
  end
  return pandoc.Div(blocks, { ["custom-style"] = "Court List" })
end

function Pandoc(doc)
  local m = doc.meta
  local blocks = {}
  local function add(b)
    blocks[#blocks + 1] = b
  end

  add(raw(court_title_xml(m)))
  add(raw(caption_xml(m)))
  if m.title then
    add(raw(title_xml(str(m.title))))
  end
  if m.lead_in then
    add(pandoc.Para(m.lead_in))
  end

  local signature = m.signature and raw(signature_xml(m)) or nil
  local signed = false
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if is_certificate(b) then
      -- The signature ends the argument; the certificate of service follows it (as in the filed brief).
      if signature then
        add(signature)
        signed = true
      end
      add(b)
    elseif is_signature_line(b) then
      add(pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Court Signature Line" }))
    elseif b.t == "Para" and NUMBERED then
      n = n + 1
      local content = b.content
      table.insert(content, 1, pandoc.RawInline("openxml", run(n .. ".") .. "<w:r><w:tab/></w:r>"))
      add(pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Numbered Paragraph" }))
    elseif b.t == "BlockQuote" then
      add(pandoc.Div(b.content, { ["custom-style"] = "Court Note" }))
    elseif b.t == "OrderedList" then
      add(list_div(b.content))
    else
      add(b)
    end
  end
  if signature and not signed then
    add(signature)
  end
  return pandoc.Pandoc(blocks, {})
end
