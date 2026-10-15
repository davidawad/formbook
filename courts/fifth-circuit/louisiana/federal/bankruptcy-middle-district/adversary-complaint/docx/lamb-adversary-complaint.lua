-- U.S. Bankruptcy Court, M.D. La.: adversary complaint, DOCX engine (docs/DOCX.md). Mirrors
-- ../typst/lamb-adversary-complaint.typ: Form 416 caption, court name, title, numbered allegations
-- (FRCP 10(b) via FRBP 7010), lettered prayer, signature block. Every string comes from the YAML
-- frontmatter of the sample; nothing is case-specific here. Styles are in reference.docx (build-reference.sh).
-- Known limits: see ../README.md "## Engines".

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("lamb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or one value) as a Lua list of strings
local function items(v)
  local out = {}
  if v == nil then return out end
  if pandoc.utils.type(v) == "List" then
    for _, x in ipairs(v) do out[#out + 1] = text(x) end
  else
    out[1] = text(v)
  end
  return out
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- OpenXML runs for an inline list (plain text, emphasis, strong; a RawInline passes through)
local function runs(inl, flags)
  flags = flags or {}
  local out = {}
  for _, el in ipairs(inl) do
    if el.t == "Str" or el.t == "Space" then
      local s = el.t == "Space" and " " or el.text
      local rpr = (flags.b and "<w:b/>" or "") .. (flags.i and "<w:i/>" or "")
      out[#out + 1] = '<w:r>' .. (rpr ~= "" and ('<w:rPr>' .. rpr .. '</w:rPr>') or "") ..
        '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
    elseif el.t == "Emph" then
      out[#out + 1] = runs(el.content, { b = flags.b, i = true })
    elseif el.t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = flags.i })
    elseif el.t == "RawInline" and el.format == "openxml" then
      out[#out + 1] = el.text
    else
      out[#out + 1] = runs({ pandoc.Str(text(el)) }, flags)
    end
  end
  return table.concat(out)
end

-- one OpenXML paragraph in a custom paragraph style
local function xpara(style, inl, flags)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. runs(inl, flags) .. '</w:p>'
end

local function str(s) return pandoc.List({ pandoc.Str(s) }) end

local function para(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>' ..
  '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function cell(width, xml, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' ..
    (xml ~= "" and xml or '<w:p/>') .. '</w:tc>'
end

-- three columns: 4500 | gutter 360 | 4500 twips (6.5 in text width, 0.25 in gutter, as typst/)
local function grid3(left, right, left_extra)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' .. NOBORDER ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4500"/><w:gridCol w:w="360"/><w:gridCol w:w="4500"/></w:tblGrid><w:tr>' ..
    cell(4500, left, left_extra) .. cell(360, "") .. cell(4500, right) .. '</w:tr></w:tbl>'
end

-- Form 416 caption: the left cell is closed by a rule at its right and bottom (typst: 0.7 pt stroke)
local function caption(meta)
  local out = {}
  out[#out + 1] = para("Centered", { pandoc.Strong(str("UNITED STATES BANKRUPTCY COURT")) })
  out[#out + 1] = para("CenteredGap", { pandoc.Strong(str("MIDDLE DISTRICT OF LOUISIANA")) })

  local left = {}
  left[#left + 1] = xpara("Single", str("In re:"))
  left[#left + 1] = xpara("Single", str(text(need(meta, "debtor"))))
  left[#left + 1] = xpara("CaptionRight", str("Debtor."))
  if meta.plaintiff ~= nil then
    for i, line in ipairs(items(meta.plaintiff)) do
      left[#left + 1] = xpara(i == 1 and "CaptionBreak" or "Single", str(line))
    end
    left[#left + 1] = xpara("CaptionRight", str("Plaintiff,"))
    left[#left + 1] = xpara("CaptionV", str("v."))
    for _, line in ipairs(items(need(meta, "defendants"))) do
      left[#left + 1] = xpara("Single", str(line))
    end
    left[#left + 1] = xpara("CaptionRight", str("Defendant."))
  end

  local right = {}
  right[#right + 1] = xpara("CaptionCell", str("Case No. " .. text(need(meta, "case_no"))))
  right[#right + 1] = xpara("CaptionCell", str(text(need(meta, "chapter"))))
  if meta.adv_no ~= nil then
    right[#right + 1] = xpara("CaptionCell", str("Adversary Proceeding No. " .. text(meta.adv_no)))
  end

  out[#out + 1] = pandoc.RawBlock("openxml", grid3(
    table.concat(left), table.concat(right),
    '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="173" w:type="dxa"/><w:bottom w:w="173" w:type="dxa"/></w:tcMar>'))
  return out
end

-- Dated line on the left, counsel block on the right (typst signature(): grid 1fr 1fr, 0.25 in gutter)
local function signature(meta)
  local sig = need(meta, "signature")
  local right = { xpara("Single", str("Respectfully submitted,")),
    xpara("SignatureGap", str("/s/ " .. text(sig.signer))) }
  for _, line in ipairs(items(sig.lines)) do
    right[#right + 1] = xpara("Single", str(line), { i = true })
  end
  local left = xpara("Single", str("Dated: " .. text(need(meta, "date"))))
  return pandoc.RawBlock("openxml", grid3(left, table.concat(right)))
end

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

function Pandoc(doc)
  -- a copy of the frontmatter: the caption and signature read it after the title and date are cleared below
  local meta = {}
  for k, v in pairs(doc.meta) do meta[k] = v end
  for _, k in ipairs({ "title", "debtor", "case_no", "chapter", "adv_no", "plaintiff", "defendants", "date", "signature" }) do
    local _ = need(meta, k)
  end
  -- LAMB-CONT-001: the statement of consent is required (FRBP 7008(a)); the body must state it.
  local body_text = {}
  for _, b in ipairs(doc.blocks) do body_text[#body_text + 1] = text(b) end
  if not table.concat(body_text, "\n"):find("consent", 1, true) then
    error("lamb-adversary-complaint: the body must state whether the pleader consents to the entry of final orders (FRBP 7008(a))", 0)
  end

  -- the frontmatter feeds the caption and signature below; pandoc must not add its own title or date block
  doc.meta.title = nil
  doc.meta.date = nil
  doc.meta.author = nil

  local out = {}
  local function add(b) out[#out + 1] = b end

  for _, b in ipairs(caption(meta)) do add(b) end
  add(para("TitleLine", { pandoc.Strong(str(string.upper(text(meta.title)))) }))

  -- body: numbered allegations; headings; lettered prayer; a "WHEREFORE" chunk is unnumbered (LAMB-CONT-002)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then add(pandoc.Header(1, str(string.upper(text(b)))))
      else add(b) end
    elseif b.t == "Para" or b.t == "Plain" then
      if text(b):match("^WHEREFORE") then
        add(pandoc.Para(b.content))
      else
        n = n + 1
        local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.Space() })
        inl:extend(b.content)
        add(pandoc.Para(inl))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local inl = pandoc.List({ pandoc.Str("(" .. LETTERS:sub(i, i) .. ")"),
            pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
          inl:extend(first.content)
          add(para("Lettered", inl))
          for j = 2, #item do add(item[j]) end
        else
          for _, x in ipairs(item) do add(x) end
        end
      end
    else
      add(b)
    end
  end

  add(signature(meta))
  doc.blocks = out
  return doc
end
