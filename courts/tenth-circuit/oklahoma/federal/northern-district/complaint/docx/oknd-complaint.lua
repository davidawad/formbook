-- N.D. Okla. complaint, DOCX engine (docs/DOCX.md). The form is ../typst/oknd-complaint.typ, carried by
-- reference.docx (styles, footer, page size; built by build-reference.sh). This filter adds what the
-- markdown cannot say: the cover (court name, caption table, title, jury notation), the numbering of the
-- allegations (FRCP 10(b): every paragraph that is not a heading, a list or the WHEREFORE lead-in), lettered
-- lists "(a)", and the signature block. No case text is in this file; every string comes from the frontmatter.
-- Known limits: the caption and signature are Word tables (border and row heights differ slightly between
-- Word and LibreOffice); the allegation numbers are typed text, not a list field (they do not renumber
-- when a paragraph is added by hand).

local function fail(msg) error("oknd-complaint: " .. msg, 0) end

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

-- a plain paragraph as WordprocessingML (used inside the cover and signature tables)
local function xpara(s, style, ppr_extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or '') .. '</w:pPr>'
    .. (s ~= "" and ('<w:r><w:t xml:space="preserve">' .. xesc(s) .. '</w:t></w:r>') or '') .. '</w:p>'
end

local function borderless_table(widths, cells_xml)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local tcs = {}
  for i, c in ipairs(cells_xml) do
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. c.tcpr .. '</w:tcPr>' .. c.body .. '</w:tc>'
  end
  return pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblW w:w="' .. (widths[1] + widths[2]) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. table.concat(tcs) .. '</w:tr></w:tbl>')
end

-- Caption: parties on the left (names, designation, "v." between sides) with a rule on the right and the
-- bottom; the case number on the right, vertically centered. Typst: caption-table().
local function caption(meta)
  local sides = need(meta, "caption")
  local left = {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do left[#left + 1] = xpara(text(n), "Single") end
    left[#left + 1] = xpara(text(side.designation), "Single", '<w:ind w:left="2592"/>')
    if i < #sides then
      left[#left + 1] = xpara("v.", "Centered", '<w:spacing w:before="240" w:after="240"/>')
    end
  end
  local right = xpara("Case No. " .. text(need(meta, "case_number")), "Single")
  return borderless_table({ 4680, 4680 }, {
    {
      tcpr = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
        .. '<w:tcMar><w:right w:w="312" w:type="dxa"/><w:bottom w:w="240" w:type="dxa"/></w:tcMar>',
      body = table.concat(left),
    },
    {
      tcpr = '<w:tcMar><w:left w:w="312" w:type="dxa"/><w:top w:w="60" w:type="dxa"/><w:bottom w:w="60" w:type="dxa"/></w:tcMar>'
        .. '<w:vAlign w:val="center"/>',
      body = right,
    },
  })
end

local function cover(meta)
  local blocks = {
    pandoc.Div({ pandoc.Para({ pandoc.Strong("UNITED STATES DISTRICT COURT") }) }, pandoc.Attr("", {}, { ["custom-style"] = "Centered" })),
    pandoc.Div({ pandoc.Para({ pandoc.Strong("NORTHERN DISTRICT OF OKLAHOMA") }) }, pandoc.Attr("", {}, { ["custom-style"] = "Centered" })),
    pandoc.Para({}),
    caption(meta),
    pandoc.Para({}),
  }
  local title = need(meta, "title")
  local t = (type(title) == "table" and title.t == "MetaInlines") and title or { pandoc.Str(text(title)) }
  blocks[#blocks + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong(t) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Centered" }))
  if meta.jury_demand == true then
    blocks[#blocks + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong("Jury Trial Demanded") }) },
      pandoc.Attr("", {}, { ["custom-style"] = "Centered" }))
  end
  blocks[#blocks + 1] = pandoc.Para({})
  return blocks
end

local function signature(meta)
  local sig = need(meta, "signature")
  local left = { xpara(meta.date and ("Dated: " .. text(meta.date)) or "", "Single") }
  local right = { xpara("Respectfully submitted,", "Single"), xpara("/s/ " .. text(sig.signer), "Single", '<w:spacing w:before="480"/>') }
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = xpara(text(l), "Single") end
  return borderless_table({ 4752, 4608 }, {
    { tcpr = '', body = table.concat(left) },
    { tcpr = '', body = table.concat(right) },
  })
end

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

local function numbered(n, para)
  local inl = { pandoc.Str(n .. "."), TAB }
  for _, x in ipairs(para.content) do inl[#inl + 1] = x end
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
end

local function hanging(label, blocks)
  local out = {}
  for i, b in ipairs(blocks) do
    if (b.t == "Para" or b.t == "Plain") and i == 1 then
      local inl = { pandoc.Str(label), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Hanging" }))
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  -- links to authorities (toa:KEY) are plain text in this form; a real link target would be a broken URL
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

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local s = text(b)
      if s:match("^WHEREFORE") then
        out[#out + 1] = b
      else
        n = n + 1
        out[#out + 1] = numbered(tostring(n), b)
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local label = "(" .. LETTERS:sub(i, i) .. ")"
        for _, x in ipairs(hanging(label, item)) do out[#out + 1] = x end
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
