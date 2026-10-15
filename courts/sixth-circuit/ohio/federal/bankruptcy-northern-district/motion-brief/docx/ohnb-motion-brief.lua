-- N.D. Ohio bankruptcy motion with memorandum, DOCX engine (docs/DOCX.md): markdown -> a Word document on reference.docx.
-- Mirrors typst/ohnb-motion-brief.typ: the caption (parties on the left, a column of ")" marks, the case, chapter, judge
-- and adversary numbers on the right), the bold centered title, the motion up to the first level-1 heading that begins
-- "MEMORANDUM", a signature block after the motion and after the memorandum, then the NOTICE OF MOTION (LBR 9013-1(a)(2))
-- and the CERTIFICATE OF SERVICE (LBR 9013-3). Nothing case-specific is written here: every string comes from the
-- sample's YAML frontmatter, and the notice wording is the rule's.

local CAP_W = { 5046, 432, 3882 }

local NOTICE_TEXT = "Any objection to this motion must be filed within 14 days, or such other time as specified by applicable "
  .. "Federal Rule of Bankruptcy Procedure or statute or as the Court may order, from the date of service as set forth on "
  .. "the certificate of service below, if the relief sought is opposed. The Court is authorized to grant the relief "
  .. "requested without further notice unless a timely objection is filed."

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return (s:gsub('"', "&quot;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function strings(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then
    for _, item in ipairs(v) do out[#out + 1] = text(item) end
  else
    out[1] = text(v)
  end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("ohnb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one raw paragraph: style, keep-with-next, exact line height (twips), run properties
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.keepLines then ppr = ppr .. "<w:keepLines/>" end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local run = ""
  if s ~= nil and s ~= "" then
    run = "<w:r>" .. (opts.rpr and ("<w:rPr>" .. opts.rpr .. "</w:rPr>") or "")
      .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
  end
  return "<w:p>" .. (ppr ~= "" and ("<w:pPr>" .. ppr .. "</w:pPr>") or "") .. run .. "</w:p>"
end

local BOLD = "<w:b/><w:bCs/>"

-- a blank paragraph of an exact height in twips (typst v(1.2em) is 288 twips at 12 pt)
local function gap(twips)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. "</w:tblCellMar></w:tblPr><w:tblGrid>" }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for c, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/></w:tcPr>' .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- caption (FRBP 9004(b) and 7010; typst caption())
-- ---------------------------------------------------------------------------

local function caption(meta)
  local out = {}
  for _, l in ipairs(strings(need(meta, "court"))) do
    out[#out + 1] = p(string.upper(l), { style = "Centered" })
  end
  if meta.division ~= nil then out[#out + 1] = p(string.upper(text(meta.division)), { style = "Centered" }) end
  out[#out + 1] = gap(288)

  local left = {}
  for _, d in ipairs(strings(need(meta, "debtor-caption"))) do left[#left + 1] = d end
  left[#left + 1] = "Debtor."
  if meta.parties ~= nil then
    local pa = meta.parties
    left[#left + 1] = ""
    left[#left + 1] = "____________________________________"
    left[#left + 1] = ""
    for _, pl in ipairs(strings(need(pa, "plaintiffs"))) do left[#left + 1] = string.upper(pl) end
    left[#left + 1] = text(need(pa, "plaintiff-designation"))
    left[#left + 1] = ""
    left[#left + 1] = "v."
    left[#left + 1] = ""
    for _, d in ipairs(strings(need(pa, "defendants"))) do left[#left + 1] = string.upper(d) end
    left[#left + 1] = text(need(pa, "defendant-designation"))
  end

  local right = { "Case No. " .. text(need(meta, "case-number")), "" }
  if meta.chapter ~= nil then right[#right + 1] = "Chapter " .. text(meta.chapter); right[#right + 1] = "" end
  if meta.judge ~= nil then right[#right + 1] = "Judge " .. text(meta.judge); right[#right + 1] = "" end
  if meta["adversary-number"] ~= nil then right[#right + 1] = "Adv. Pro. No. " .. text(meta["adversary-number"]) end

  local n = math.max(#left, #right)
  local rows = {}
  for i = 1, n do
    rows[#rows + 1] = {
      p(left[i] or "", { style = "Single" }),
      p(")", { style = "Single", jc = "center" }),
      p(right[i] or "", { style = "Single" }),
    }
  end
  out[#out + 1] = table_xml(CAP_W, rows)

  out[#out + 1] = gap(288)
  out[#out + 1] = p(text(need(meta, "title")), { style = "Centered", rpr = BOLD })
  out[#out + 1] = gap(288)
  return out
end

-- ---------------------------------------------------------------------------
-- signature block (LBR 5005-1(c); typst signature()): at the left margin, kept together
-- ---------------------------------------------------------------------------

local function md_para(s, style)
  local doc = pandoc.read(s, "markdown+smart")
  local inl = pandoc.utils.blocks_to_inlines(doc.blocks)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function signature(meta)
  local sig = need(meta, "signature")
  local out = { pandoc.RawBlock("openxml", gap(360)) }
  out[#out + 1] = pandoc.RawBlock("openxml", p("Respectfully submitted,", { style = "Signature", keepNext = true }))
  out[#out + 1] = pandoc.RawBlock("openxml", gap(240))
  out[#out + 1] = pandoc.RawBlock("openxml", p("s/ " .. text(need(sig, "signer")), { style = "Signature", keepNext = true }))
  out[#out + 1] = pandoc.RawBlock("openxml", p(text(need(sig, "signer-name-printed")), { style = "Signature", keepNext = true }))
  local lines = strings(need(sig, "lines"))
  for _, l in ipairs(lines) do out[#out + 1] = md_para(l, "Signature") end
  return out
end

-- ---------------------------------------------------------------------------
-- notice of motion and certificate of service (LBR 9013-1(a)(2), 9013-3; typst certificate())
-- ---------------------------------------------------------------------------

local function certificate(meta)
  local svc = need(meta, "service")
  local out = {}
  out[#out + 1] = p("NOTICE OF MOTION", { style = "Centered", keepNext = true, rpr = BOLD })
  out[#out + 1] = pandoc.RawBlock("openxml", gap(240))
  out[#out + 1] = pandoc.RawBlock("openxml", p(NOTICE_TEXT, { style = "BodyText" }))
  out[#out + 1] = pandoc.RawBlock("openxml", gap(360))
  out[#out + 1] = pandoc.RawBlock("openxml", p("CERTIFICATE OF SERVICE", { style = "Centered", keepNext = true, rpr = BOLD }))
  out[#out + 1] = pandoc.RawBlock("openxml", gap(240))
  local cert = "I hereby certify that on " .. text(need(svc, "date")) .. ", a true copy of the foregoing "
    .. text(need(svc, "document")) .. " was served " .. text(need(svc, "method-ecf")) .. " "
    .. text(need(svc, "method-mail"))
  out[#out + 1] = pandoc.RawBlock("openxml", p(cert, { style = "BodyText" }))
  for _, e in ipairs(strings(svc.entities)) do
    out[#out + 1] = pandoc.RawBlock("openxml", p(e, { style = "Single" }))
  end
  out[#out + 1] = pandoc.RawBlock("openxml", gap(360))
  out[#out + 1] = pandoc.RawBlock("openxml", p("s/ " .. text(need(need(meta, "signature"), "signer")), { style = "Signature", keepNext = true }))
  out[#out + 1] = pandoc.RawBlock("openxml", p(text(need(need(meta, "signature"), "signer-name-printed")), { style = "Signature" }))
  return out
end

-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local at = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and string.sub(pandoc.utils.stringify(b), 1, 11) == "MEMORANDUM " then
      at = i
      break
    end
  end
  if at == nil then error("ohnb-motion-brief: the sample needs a '# MEMORANDUM ...' heading", 0) end

  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  -- the caption carries the title; pandoc would otherwise write the metadata title again
  meta.title = nil
  for i = 1, at - 1 do out[#out + 1] = doc.blocks[i] end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  for i = at, #doc.blocks do out[#out + 1] = doc.blocks[i] end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  for _, b in ipairs(certificate(meta)) do out[#out + 1] = b end
  return pandoc.Pandoc(out, meta)
end
