-- Court form for the District of Wyoming bankruptcy court (docx engine). MODE is set per doc type.
-- Mirrors typst/wyb-<doc>.typ: counsel block, court title, caption table, document title, numbered
-- paragraphs (complaint) or unnumbered paragraphs (memorandum), lettered prayer items, date and
-- signature block, and (memorandum) certificate of service. Frontmatter fields as in the typst README.
local MODE = "complaint"
local UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- Frontmatter values are markdown (MetaInlines) or plain Lua strings; return inlines.
local function inl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then
    local b = pandoc.read(v, "markdown").blocks[1]
    if b and b.content then return b.content end
    return pandoc.Inlines({})
  end
  if v.t == "MetaInlines" or v.t == "MetaString" then return pandoc.Inlines(v) end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function list_of(v)
  local out = {}
  if v == nil then return out end
  for _, x in ipairs(v) do out[#out + 1] = x end
  return out
end

local function style_para(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- one raw paragraph for the caption table (plain text, escaped)
local function raw_p(style, text, ppr_extra)
  local run = ""
  if text ~= "" then run = "<w:r><w:t xml:space=\"preserve\">" .. esc(text) .. "</w:t></w:r>" end
  return "<w:p><w:pPr><w:pStyle w:val=\"" .. style .. "\"/>" .. (ppr_extra or "") .. "</w:pPr>" .. run .. "</w:p>"
end

local function caption_table(meta)
  local left_w, gutter_w, right_w = 4896, 432, 4032   -- 3.4 in, 0.3 in, 2.8 in (6.5 in text width)
  local indent = (MODE == "complaint") and 2880 or 1728 -- designation: 2 in (complaint), 1.2 in (memo)
  local left = {}
  local debtor = list_of(meta.debtor)
  for _, l in ipairs(debtor) do left[#left + 1] = raw_p("CaptionText", plain(l)) end
  if #debtor > 0 then left[#left + 1] = raw_p("CaptionText", "") end
  local function group(p)
    local out = {}
    for _, n in ipairs(list_of(p.names)) do out[#out + 1] = raw_p("CaptionText", plain(n)) end
    out[#out + 1] = "<w:p><w:pPr><w:pStyle w:val=\"CaptionParty\"/><w:ind w:left=\"" .. indent .. "\" w:firstLine=\"0\"/></w:pPr><w:r><w:t xml:space=\"preserve\">" .. esc(plain(p.designation)) .. "</w:t></w:r></w:p>"
    return out
  end
  for i, p in ipairs(list_of(meta.parties)) do
    if i > 1 then left[#left + 1] = raw_p("CaptionText", "v.", "<w:jc w:val=\"center\"/>") end
    for _, x in ipairs(group(p)) do left[#left + 1] = x end
  end
  local third = list_of(meta.third_party)
  if #third > 0 then
    left[#left + 1] = "<w:p><w:pPr><w:pStyle w:val=\"CaptionText\"/><w:pBdr><w:bottom w:val=\"single\" w:sz=\"4\" w:space=\"1\" w:color=\"000000\"/></w:pBdr><w:spacing w:before=\"0\" w:after=\"260\" w:line=\"240\" w:lineRule=\"auto\"/></w:pPr></w:p>"
    for i, p in ipairs(third) do
      if i > 1 then left[#left + 1] = raw_p("CaptionText", "v.", "<w:jc w:val=\"center\"/>") end
      for _, x in ipairs(group(p)) do left[#left + 1] = x end
    end
  end
  local right = {}
  local keys = { "bankruptcy_case", "adversary" }
  if MODE == "complaint" then keys = { "bankruptcy_case", "chapter", "adversary", "judge" } end
  for _, key in ipairs(keys) do
    if meta[key] ~= nil then
      right[#right + 1] = raw_p("CaptionText", plain(meta[key]), "<w:spacing w:before=\"0\" w:after=\"312\" w:line=\"240\" w:lineRule=\"auto\"/>")
    end
  end
  if #right == 0 then right[#right + 1] = raw_p("CaptionText", "") end
  local xml = {
    "<w:tbl><w:tblPr><w:tblW w:w=\"9360\" w:type=\"dxa\"/><w:tblLayout w:type=\"fixed\"/>",
    "<w:tblBorders><w:top w:val=\"nil\"/><w:left w:val=\"nil\"/><w:bottom w:val=\"nil\"/><w:right w:val=\"nil\"/><w:insideH w:val=\"nil\"/><w:insideV w:val=\"nil\"/></w:tblBorders>",
    "<w:tblCellMar><w:left w:w=\"0\" w:type=\"dxa\"/><w:right w:w=\"0\" w:type=\"dxa\"/></w:tblCellMar></w:tblPr>",
    "<w:tblGrid><w:gridCol w:w=\"" .. left_w .. "\"/><w:gridCol w:w=\"" .. gutter_w .. "\"/><w:gridCol w:w=\"" .. right_w .. "\"/></w:tblGrid>",
    "<w:tr><w:tc><w:tcPr><w:tcW w:w=\"" .. left_w .. "\" w:type=\"dxa\"/>",
    "<w:tcBorders><w:right w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"000000\"/><w:bottom w:val=\"single\" w:sz=\"4\" w:space=\"0\" w:color=\"000000\"/></w:tcBorders>",
    "<w:tcMar><w:top w:w=\"0\" w:type=\"dxa\"/><w:right w:w=\"288\" w:type=\"dxa\"/><w:bottom w:w=\"288\" w:type=\"dxa\"/></w:tcMar></w:tcPr>",
    table.concat(left, ""),
    "</w:tc><w:tc><w:tcPr><w:tcW w:w=\"" .. gutter_w .. "\" w:type=\"dxa\"/></w:tcPr><w:p><w:pPr><w:pStyle w:val=\"CaptionText\"/></w:pPr></w:p></w:tc>",
    "<w:tc><w:tcPr><w:tcW w:w=\"" .. right_w .. "\" w:type=\"dxa\"/>",
    "<w:tcMar><w:top w:w=\"288\" w:type=\"dxa\"/><w:left w:w=\"0\" w:type=\"dxa\"/></w:tcMar></w:tcPr>",
    table.concat(right, ""),
    "</w:tc></w:tr></w:tbl>",
  }
  return pandoc.RawBlock("openxml", table.concat(xml, ""))
end

local function counsel(meta)
  local out = {}
  for _, l in ipairs(list_of(meta.counsel)) do out[#out + 1] = style_para("Counsel", inl(l)) end
  if meta.client ~= nil then out[#out + 1] = style_para("Counsel", pandoc.Inlines({ pandoc.Emph(inl(meta.client)) })) end
  out[#out + 1] = style_para("CaptionText", pandoc.Inlines({}))
  return out
end

local function court_title()
  local first = (MODE == "complaint") and "THE UNITED STATES BANKRUPTCY COURT" or "IN THE UNITED STATES BANKRUPTCY COURT"
  return {
    style_para("CourtTitle", pandoc.Inlines({ pandoc.Strong({ pandoc.Str(first) }) })),
    style_para("CourtTitle", pandoc.Inlines({ pandoc.Strong({ pandoc.Str("FOR THE DISTRICT OF WYOMING") }) })),
    style_para("CaptionText", pandoc.Inlines({})),
  }
end

-- date (kept with the signature block), then the signature
local function signature(meta)
  local out = {}
  if meta.date ~= nil then out[#out + 1] = style_para("DateLine", inl(meta.date)) end
  local sig = meta.signature
  if sig == nil then return out end
  if MODE == "complaint" then
    if sig.firm ~= nil then out[#out + 1] = style_para("Signature", inl(sig.firm)) end
    out[#out + 1] = style_para("Signature", pandoc.Inlines({}))
    out[#out + 1] = style_para("Signature", pandoc.Inlines({ pandoc.Str("/s/ " .. plain(sig.signer)) }))
    out[#out + 1] = style_para("Signature", inl(sig.signer))
    for _, l in ipairs(list_of(sig.lines)) do out[#out + 1] = style_para("SignatureNote", inl(l)) end
  else
    for _, s in ipairs(list_of(sig.signatures)) do out[#out + 1] = style_para("Signature", inl(s)) end
    out[#out + 1] = style_para("Signature", pandoc.Inlines({}))
    for _, l in ipairs(list_of(sig.lines)) do out[#out + 1] = style_para("SignatureSmall", inl(l)) end
  end
  return out
end

-- certificate of service (memorandum; LBR 9013-3), only when frontmatter has a service block
local function certificate(meta)
  local svc = meta.service
  if svc == nil then return {} end
  local out = { style_para("CertificateTitle", pandoc.Inlines({ pandoc.Strong({ pandoc.Str("CERTIFICATE OF SERVICE") }) })) }
  local text = "I hereby certify that on " .. plain(svc.date) .. ", I served a true and correct copy of the above and foregoing through the Case Management/Electronic Case Filing (CM/ECF) system of the United States Bankruptcy Court for the District of Wyoming, and the Notice of Electronic Filing of this document sent to the recipients below by the CM/ECF system constitutes service."
  out[#out + 1] = pandoc.Para(pandoc.read(text, "markdown").blocks[1].content)
  for _, r in ipairs(list_of(svc.recipients)) do out[#out + 1] = style_para("Recipient", inl(r)) end
  out[#out + 1] = style_para("CaptionText", pandoc.Inlines({}))
  out[#out + 1] = style_para("Signature", pandoc.Inlines({ pandoc.Str("/s/ " .. plain(svc.signer)) }))
  out[#out + 1] = style_para("Signature", inl(svc.signer))
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  local function add(list) for _, b in ipairs(list) do blocks[#blocks + 1] = b end end
  add(counsel(meta))
  add(court_title())
  blocks[#blocks + 1] = caption_table(meta)
  blocks[#blocks + 1] = style_para("CaptionText", pandoc.Inlines({}))
  blocks[#blocks + 1] = style_para("DocTitle", pandoc.Inlines({ pandoc.Strong(inl(meta.title or (MODE == "complaint" and "COMPLAINT" or "MEMORANDUM"))) }))

  -- body: numbered paragraphs (complaint only) and lettered prayer items, counters as in the typst template
  local n, letter, in_body = 0, 0, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      in_body = true
      if b.level == 1 then letter = 0 end
      blocks[#blocks + 1] = b
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        letter = letter + 1
        local first = item[1]
        local body = (first and (first.t == "Para" or first.t == "Plain")) and first.content or pandoc.Inlines({})
        local lead = pandoc.Inlines({ pandoc.Str(UPPER:sub(letter, letter) .. "."), pandoc.Space() })
        blocks[#blocks + 1] = style_para("Lettered", lead .. body)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local text = pandoc.utils.stringify(b)
      if text:match("^WHEREFORE") then letter = 0 end
      if MODE == "complaint" and in_body and not text:match("^WHEREFORE") then
        n = n + 1
        blocks[#blocks + 1] = pandoc.Para(pandoc.Inlines({ pandoc.Str(n .. "."), pandoc.Space() }) .. b.content)
      else
        letter = (in_body and MODE == "complaint") and letter or letter
        blocks[#blocks + 1] = pandoc.Para(b.content)
      end
    else
      blocks[#blocks + 1] = b
    end
  end
  add(signature(meta))
  add(certificate(meta))
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
