-- N.D. Okla. motion with brief in support, DOCX engine (docs/DOCX.md). The form is ../typst/oknd-motion-brief.typ,
-- carried by reference.docx (styles, footer, page size; built by build-reference.sh). This filter adds what the
-- markdown cannot say: the cover (court name, caption table, title), the heading labels (I., A., 1., a.; the
-- level-1 headings are unnumbered), the signature block and the certificate of service on its own page.
-- No case text is in this file; every string comes from the frontmatter.
-- BLOCKED here: the tables of contents and authorities (toc_toa: true). The typst form builds them; this filter
-- stops with an error rather than omit them silently. Links to authorities (toa:KEY) become plain text.
-- Known limits: the caption and signature are Word tables; heading labels are typed text (they do not renumber
-- when a heading is added by hand).

local function fail(msg) error("oknd-motion-brief: " .. msg, 0) end

local function need(meta, key)
  if meta[key] == nil then fail("missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function inlines_of(v)
  if type(v) == "table" and v.t == "MetaInlines" then return v end
  return { pandoc.Str(text(v)) }
end

local function xesc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local PAGE_BREAK = pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

local function xpara(s, style, ppr_extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or '') .. '</w:pPr>'
    .. (s ~= "" and ('<w:r><w:t xml:space="preserve">' .. xesc(s) .. '</w:t></w:r>') or '') .. '</w:p>'
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
      body = xpara("Case No. " .. text(need(meta, "case_number")), "Single"),
    },
  })
end

local function cover(meta)
  local function centered(inl)
    return pandoc.Div({ pandoc.Para({ pandoc.Strong(inl) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Centered" }))
  end
  return {
    centered({ pandoc.Str("IN THE UNITED STATES DISTRICT COURT FOR THE") }),
    centered({ pandoc.Str("NORTHERN DISTRICT OF OKLAHOMA") }),
    pandoc.Para({}),
    caption(meta),
    pandoc.Para({}),
    centered(inlines_of(need(meta, "title"))),
    pandoc.Para({}),
  }
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

-- Certificate of service (FRCP 5(d)(1)(B)); on its own page. Typst: certificate-block().
local function certificate(meta)
  local c = meta.certificate
  local out = { PAGE_BREAK }
  out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str("CERTIFICATE OF SERVICE") }) }) },
    pandoc.Attr("", {}, { ["custom-style"] = "Centered" }))
  out[#out + 1] = pandoc.Para({})
  out[#out + 1] = pandoc.Para(inlines_of(need(c, "text")))
  out[#out + 1] = pandoc.Para({})
  local svc = {}
  for _, l in ipairs(c.service or {}) do svc[#svc + 1] = xpara(text(l), "Single", '<w:ind w:left="720"/>') end
  out[#out + 1] = pandoc.RawBlock("openxml", table.concat(svc))
  local signer = text(need(c, "signer"))
  out[#out + 1] = borderless_table({ 4752, 4608 }, {
    { tcpr = '', body = xpara("", "Single") },
    { tcpr = '', body = xpara("/s/ " .. signer, "Single", '<w:spacing w:before="480"/>') .. xpara(signer, "Single") },
  })
  return out
end

-- Heading labels: level 2 is I., A., 1., a. by depth; level 1 is unnumbered.
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV",
  "XVI", "XVII", "XVIII", "XIX", "XX" }

local function label(level, n)
  if level == 2 then return (ROMAN[n] or tostring(n)) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return tostring(n) .. "." end
  return string.char(96 + n) .. "."
end

function Pandoc(doc)
  local meta = doc.meta
  if meta.toc_toa == true then
    fail("toc_toa: true (indexed TOC and TOA) is not built by the DOCX engine; BLOCKED, see README.md ## Engines")
  end
  doc = doc:walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  })

  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end

  local counters = { 0, 0, 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        out[#out + 1] = b
      else
        counters[b.level] = counters[b.level] + 1
        for k = b.level + 1, 6 do counters[k] = 0 end
        local inl = { pandoc.Str(label(b.level, counters[b.level])), TAB }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        out[#out + 1] = pandoc.Header(b.level, inl, b.attr)
      end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.Para({})
  out[#out + 1] = signature(meta)
  if meta.certificate ~= nil then
    for _, b in ipairs(certificate(meta)) do out[#out + 1] = b end
  end

  local m = pandoc.Meta({})
  for k, v in pairs(meta) do
    if k ~= "title" and k ~= "date" then m[k] = v end
  end
  return pandoc.Pandoc(out, m)
end
