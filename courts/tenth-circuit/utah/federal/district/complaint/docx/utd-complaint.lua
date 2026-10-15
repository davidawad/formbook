-- D. Utah complaint, DOCX engine (docs/DOCX.md). The form is ../typst/utd-complaint.typ, carried by
-- reference.docx (styles, footer, page size and margins; built by build-reference.sh). This filter adds what
-- the markdown cannot say: the cover (counsel block, court title, caption table with the jury notation), the
-- numbering of the allegations (DUCivR / FRCP 10(b): every paragraph except those under a "Prayer" or "Jury
-- Demand" heading, list lead-ins and the lead-in line), numbered prayer items, and the signature block.
-- No case text is in this file: every string comes from the frontmatter.
-- Known limits: the caption and signature are Word tables (border and row heights differ slightly between Word
-- and LibreOffice); allegation numbers are typed text, not a list field, so they do not renumber when a
-- paragraph is inserted by hand.

local function fail(msg) error("utd-complaint: " .. msg, 0) end

local function need(meta, key)
  if meta[key] == nil then fail("missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function xesc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local PAGE_BREAK = pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- a plain paragraph as WordprocessingML (inside the cover and signature tables)
local function xpara(s, style, ppr_extra, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or '') .. '</w:pPr>'
    .. (s ~= "" and ('<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. xesc(s) .. '</w:t></w:r>') or '') .. '</w:p>'
end

local function borderless_table(widths, cells)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local tcs = {}
  for i, c in ipairs(cells) do
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. c.tcpr .. '</w:tcPr>' .. c.body .. '</w:tc>'
  end
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblW w:w="' .. (widths[1] + widths[2]) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. table.concat(tcs) .. '</w:tr></w:tbl>')
end

-- Caption (typst: caption-table()): parties on the left with a rule on the right and the bottom; title, jury
-- notation, case number and judges on the right.
local function caption(meta)
  local sides = need(meta, "caption")
  local left = {}
  for i, side in ipairs(sides) do
    if i > 1 then left[#left + 1] = xpara("v.", "Single") end
    for _, n in ipairs(side.names) do left[#left + 1] = xpara(text(n), "Single") end
    left[#left + 1] = xpara(text(side.designation), "Single")
  end
  local right = { xpara(string.upper(text(need(meta, "brief_title"))), "Single", nil, true) }
  if meta.jury_demand == true then
    right[#right + 1] = xpara("JURY DEMANDED", "Single", '<w:spacing w:before="260"/>')
  end
  right[#right + 1] = xpara("Case No. " .. text(need(meta, "case_number")), "Single", '<w:spacing w:before="260"/>')
  if meta.judge ~= nil then right[#right + 1] = xpara("Judge " .. text(meta.judge), "Single", '<w:spacing w:before="260"/>') end
  if meta.magistrate ~= nil then
    right[#right + 1] = xpara("Magistrate Judge " .. text(meta.magistrate), "Single")
  end
  return borderless_table({ 6023, 3337 }, {
    {
      tcpr = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
        .. '<w:tcMar><w:right w:w="312" w:type="dxa"/><w:bottom w:w="260" w:type="dxa"/></w:tcMar>',
      body = table.concat(left),
    },
    {
      tcpr = '<w:tcMar><w:left w:w="312" w:type="dxa"/><w:top w:w="60" w:type="dxa"/></w:tcMar>',
      body = table.concat(right),
    },
  })
end

local function cover(meta)
  local out = {}
  for _, l in ipairs(need(meta, "counsel")) do out[#out + 1] = styled("Single", { pandoc.Str(text(l)) }) end
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="260"/></w:pPr></w:p>')
  for _, l in ipairs(need(meta, "court")) do
    out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str(string.upper(text(l))) }) }) },
      pandoc.Attr("", {}, { ["custom-style"] = "Centered" }))
  end
  if meta.division ~= nil then
    out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str(string.upper(text(meta.division))) }) }) },
      pandoc.Attr("", {}, { ["custom-style"] = "Centered" }))
  end
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="260"/></w:pPr></w:p>')
  out[#out + 1] = caption(meta)
  out[#out + 1] = PAGE_BREAK
  return out
end

-- Signature (typst: signature-block()): "DATED this ..." at left; the firm, "By: /s/" and the signer at right.
local function signature(meta)
  local sig = need(meta, "signature")
  local left = { xpara("DATED this " .. text(need(meta, "date")) .. ".", "Single") }
  local right = { xpara("Respectfully submitted,", "Single") }
  for _, l in ipairs(sig.firm or {}) do
    local extra = (#right == 1) and '<w:spacing w:before="260"/>' or nil
    right[#right + 1] = xpara(text(l), "Single", extra)
  end
  right[#right + 1] = xpara("By: /s/ " .. text(sig.signer), "Single", '<w:spacing w:before="260"/>')
  right[#right + 1] = xpara(text(sig.signer), "Single")
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = xpara(text(l), "Single") end
  return borderless_table({ 4752, 4608 }, {
    { tcpr = '', body = table.concat(left) },
    { tcpr = '', body = table.concat(right) },
  })
end

local function numbered(n, para)
  local inl = { pandoc.Str(tostring(n) .. "."), TAB }
  for _, x in ipairs(para.content) do inl[#inl + 1] = x end
  return styled("Numbered", inl)
end

-- A list item: the label, a tab, then the item's first paragraph; the rest of the item follows unchanged.
local function hanging(label, blocks)
  local out = {}
  for i, b in ipairs(blocks) do
    if (b.t == "Para" or b.t == "Plain") and i == 1 then
      local inl = { pandoc.Str(label), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = styled("Hanging", inl)
    else
      out[#out + 1] = b
    end
  end
  return out
end

local function is_list(b)
  return b ~= nil and (b.t == "OrderedList" or b.t == "BulletList")
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "counsel", "brief_title", "signature", "date" }) do
    need(meta, k)
  end
  -- links to authorities (toa:KEY) are plain text in this form
  doc = doc:walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  })

  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end

  if meta.lead_in ~= nil then
    local li = meta.lead_in
    local inl = (type(li) == "table" and li.t == "MetaInlines") and li or { pandoc.Str(text(li)) }
    out[#out + 1] = pandoc.Para(inl)
  end

  local blocks = doc.blocks
  local n = 0
  local unnumbered = false
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local s = string.lower(text(b.content))
      unnumbered = s:find("prayer", 1, true) ~= nil or s:find("jury demand", 1, true) ~= nil
      out[#out + 1] = b
    elseif b.t == "Para" then
      if unnumbered or is_list(blocks[i + 1]) then
        out[#out + 1] = b
      else
        n = n + 1
        out[#out + 1] = numbered(n, b)
      end
    elseif b.t == "OrderedList" then
      for i2, item in ipairs(b.content) do
        for _, x in ipairs(hanging(tostring(i2) .. ".", item)) do out[#out + 1] = x end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, x in ipairs(hanging("\u{2022}", item)) do out[#out + 1] = x end
      end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.Para({})
  out[#out + 1] = signature(meta)

  -- the cover is built here: pandoc must not print the title or date from the metadata again
  local m = pandoc.Meta({})
  for k, v in pairs(meta) do
    if k ~= "title" and k ~= "date" then m[k] = v end
  end
  return pandoc.Pandoc(out, m)
end
