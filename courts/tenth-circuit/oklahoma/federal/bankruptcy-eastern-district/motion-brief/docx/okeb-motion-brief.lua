-- okeb motion brief, DOCX engine (docs/DOCX.md). Turns the markdown contract of ../README.md into the layout of
-- typst/okeb-motion-brief.typ on reference.docx: the court heading and caption (a table with a vertical rule),
-- the title, the optional counsel block, consecutive numbered paragraphs, property lists, the signature block and
-- the optional certificate. Page numbers come from the reference footer. Nothing case-specific is in this file.
-- Known limits: see "## Engines" in ../README.md.

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a YAML list (pandoc gives a "List") as a list of strings; any other value (Inlines) is one string
local function strs(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = txt(x) end
    return out
  end
  return { txt(v) }
end

-- a YAML value that holds markdown paragraphs (a certificate body): a line break splits paragraphs
local function blocks_of(v)
  if v == nil then return {} end
  local out = {}
  if pandoc.utils.type(v) == "List" then
    for _, x in ipairs(v) do out[#out + 1] = pandoc.Para(x) end
    return out
  end
  local cur = pandoc.List()
  for _, x in ipairs(v) do
    if x.t == "LineBreak" then
      if #cur > 0 then out[#out + 1] = pandoc.Para(cur); cur = pandoc.List() end
    else
      cur:insert(x)
    end
  end
  if #cur > 0 then out[#out + 1] = pandoc.Para(cur) end
  return out
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- one paragraph as WordprocessingML (twips for indents and spacing); returns the XML string
local function px(text, o)
  o = o or {}
  local p = '<w:pStyle w:val="' .. (o.style or "Single") .. '"/>'
  if o.keep then p = p .. "<w:keepNext/>" end
  if o.before or o.after then
    p = p .. "<w:spacing" .. (o.before and (' w:before="' .. o.before .. '"') or "")
      .. (o.after and (' w:after="' .. o.after .. '"') or "") .. "/>"
  end
  if o.left or o.right then
    p = p .. "<w:ind" .. (o.left and (' w:left="' .. o.left .. '"') or "")
      .. (o.right and (' w:right="' .. o.right .. '"') or "") .. "/>"
  end
  local r = o.bold and "<w:rPr><w:b/></w:rPr>" or ""
  return "<w:p><w:pPr>" .. p .. "</w:pPr><w:r>" .. r .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- the caption (both filed exemplars: court in two lines, debtor column, case number and chapter), widths 3.5 in and 3 in
local function caption(meta)
  local out = {}
  out[#out + 1] = raw(px("IN THE UNITED STATES BANKRUPTCY COURT", { style = "Centered", bold = true }))
  out[#out + 1] = raw(px("FOR THE EASTERN DISTRICT OF OKLAHOMA", { style = "Centered", bold = true, after = 432 }))
  local left, right = {}, {}
  left[#left + 1] = px("In re:", { after = 216, right = 288 })
  for _, d in ipairs(strs(meta.debtor)) do
    left[#left + 1] = px(d, { left = 720, after = 48, right = 288 })
  end
  left[#left + 1] = px(txt(meta.debtor_role), { left = 3168, right = 288 })
  local judge = ""
  if meta.judge and txt(meta.judge) ~= "" then judge = "-" .. txt(meta.judge) end
  right[#right + 1] = px("Case No. " .. txt(meta.case_number) .. judge, { left = 432, after = 288 })
  right[#right + 1] = px("Chapter " .. txt(meta.chapter), { left = 432 })
  out[#out + 1] = raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="5040"/><w:gridCol w:w="4320"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5040" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4320" w:type="dxa"/><w:tcBorders><w:left w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders></w:tcPr>'
    .. table.concat(right) .. '</w:tc></w:tr></w:tbl>')
  return out
end

-- numbered paragraphs run consecutively over the whole brief (the typed numbers are ignored);
-- bulleted items are property lists, indented and single spaced
local function body_blocks(blocks)
  local out = {}
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" then
      for _, item in ipairs(b.content) do
        n = n + 1
        for i, ib in ipairs(item) do
          if i == 1 and (ib.t == "Para" or ib.t == "Plain") then
            local inl = pandoc.List({ pandoc.Str(tostring(n) .. "."), pandoc.Space() })
            inl:extend(ib.content)
            out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
          else
            out[#out + 1] = ib
          end
        end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        local inner = {}
        for _, ib in ipairs(item) do
          if ib.t == "Plain" then inner[#inner + 1] = pandoc.Para(ib.content) else inner[#inner + 1] = ib end
        end
        out[#out + 1] = pandoc.Div(inner, pandoc.Attr("", {}, { ["custom-style"] = "PropertyList" }))
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- counsel block (optional, first page): single spaced, set at 3.25 in, then 0.6 em
local function counsel(meta)
  local out = {}
  if not meta.counsel then return out end
  local lines = strs(meta.counsel)
  for i, l in ipairs(lines) do
    out[#out + 1] = raw(px(l, { style = "SigBlock", keep = i < #lines, after = (i == #lines) and 144 or nil }))
  end
  return out
end

-- signature block (LBR 9004-1(C)): optional date, "Respectfully submitted,", the electronic signature, the block
local function signature(meta)
  local sig = meta.signature
  if not sig then error("okeb-motion-brief: missing required metadata field `signature`") end
  local out = {}
  if meta.date then
    out[#out + 1] = raw(px("Dated: " .. txt(meta.date), { keep = true, before = 336, after = 288 }))
    out[#out + 1] = raw(px("Respectfully submitted,", { style = "SigBlock", keep = true }))
  else
    out[#out + 1] = raw(px("Respectfully submitted,", { style = "SigBlock", keep = true, before = 336 }))
  end
  out[#out + 1] = raw(px("/s/ " .. txt(sig.electronic), { style = "SigBlock", keep = true, before = 384 }))
  local lines = strs(sig.lines)
  for i, l in ipairs(lines) do
    out[#out + 1] = raw(px(l, { style = "SigBlock", keep = i < #lines, before = (i == 1) and 96 or nil }))
  end
  return out
end

-- certificate of service or of mailing (optional; follows the signature block, as in both exemplars)
local function certificate(meta)
  local out = {}
  local c = meta.certificate
  if not c then return out end
  out[#out + 1] = raw(px(txt(c.title):upper(), { style = "Centered", bold = true, before = 336, after = 288 }))
  for _, b in ipairs(blocks_of(c.body)) do out[#out + 1] = b end
  local lines = strs(c.lines)
  out[#out + 1] = raw(px("/s/ " .. txt(c.electronic), { style = "SigBlock", keep = #lines > 0, before = 240 }))
  for i, l in ipairs(lines) do
    out[#out + 1] = raw(px(l, { style = "SigBlock", keep = i < #lines, before = (i == 1) and 96 or nil }))
  end
  return out
end

function Pandoc(doc)
  local m = doc.meta
  local blocks = pandoc.List()
  for _, b in ipairs(caption(m)) do blocks:insert(b) end
  blocks:insert(raw(px(txt(m.title):upper(), { style = "Centered", bold = true, before = 480, after = 288 })))
  for _, b in ipairs(counsel(m)) do blocks:insert(b) end
  for _, b in ipairs(body_blocks(doc.blocks)) do blocks:insert(b) end
  for _, b in ipairs(signature(m)) do blocks:insert(b) end
  for _, b in ipairs(certificate(m)) do blocks:insert(b) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
