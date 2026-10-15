-- U.S. District Court, District of New Jersey, motion brief (memorandum of law): DOCX engine (docs/DOCX.md).
-- The markdown contract of ../README.md -> a Word document on reference.docx, in three sections as the typst
-- template has three page runs: the cover (no page number), the contents and authorities (roman numerals),
-- and the body (arabic from 1). The cover, caption table, contents, authorities and signature block are raw
-- OOXML in the styles of reference.docx; the body keeps its markdown structure. Heading labels (I., A., 1., a.)
-- are written by this filter, as the typst heading numbering does.
-- Known limits (BLOCKED, see README.md "Engines"): the contents is a TOC field whose cached entries have no
-- page numbers; the table of authorities has no page numbers (the typst template reads them from the body).

local CFG = {
  caption_left = 4070,    -- party column: 1fr of 2.3 fr of the 6.5 in text width (typst columns 1fr, 1.3fr)
  caption_right = 5290,
  caption_left_pad = 336, -- typst pad(right: 1.2em) on the party column, 1.2 em at 14 pt
  caption_right_pad = 336,
  party_indent = 2592,    -- designation indented 1.8 in (typst pad left)
  sig_left = 4752,        -- "Dated:" column: 1fr
  sig_right = 4608,       -- 3.2 in (typst)
  toc_title = "Table of Contents",
  toa_title = "Table of Authorities",
  groups = {
    { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" },
    { "regulation", "Regulations" }, { "other", "Other Authorities" },
  },
  passim_threshold = 7,
  -- the OOXML footer relationships of the sections (ids assigned by build-reference.sh; see README.md, Engines)
  footer_blank = "rId10",
  footer_pages = "rId9",
}

-- ---------------------------------------------------------------------------
-- Metadata helpers
-- ---------------------------------------------------------------------------

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function meta_blocks(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return { pandoc.Plain(v) } end
  local out = {}
  for _, b in ipairs(v) do out[#out + 1] = b end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("njd-motion: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- ---------------------------------------------------------------------------
-- OOXML fragments
-- ---------------------------------------------------------------------------

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function with(p, k)
  local q = {}
  for a, b in pairs(p) do q[a] = b end
  q[k] = true
  return q
end

local function rpr(p)
  local s = ""
  if p.b then s = s .. "<w:b/><w:bCs/>" end
  if p.i then s = s .. "<w:i/><w:iCs/>" end
  if s == "" then return "" end
  return "<w:rPr>" .. s .. "</w:rPr>"
end

local function run(text, p)
  if p.caps then text = text:upper() end
  return "<w:r>" .. rpr(p) .. '<w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

local function runs(list, p, out)
  out = out or {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, p)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", p)
    elseif t == "LineBreak" then out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then runs(el.content, with(p, "i"), out)
    elseif t == "Strong" then runs(el.content, with(p, "b"), out)
    elseif t == "Quoted" then
      local q1, q2 = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then q1, q2 = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(q1, p)
      runs(el.content, p, out)
      out[#out + 1] = run(q2, p)
    elseif t == "Link" or t == "Span" then runs(el.content, p, out)
    elseif t == "Code" then out[#out + 1] = run(el.text, p)
    elseif t == "RawInline" then out[#out + 1] = el.text
    else out[#out + 1] = run(pandoc.utils.stringify(el), p)
    end
  end
  return out
end

-- one paragraph: style, left indent and hanging indent (twips, optional), inlines, run properties
local function para_xml(style, list, p, indent, hanging)
  local ppr = ""
  if style then ppr = '<w:pStyle w:val="' .. style .. '"/>' end
  if indent then
    ppr = ppr .. '<w:ind w:left="' .. indent .. '"' .. (hanging and (' w:hanging="' .. hanging .. '"') or "") .. ' w:firstLine="0"/>'
  end
  if ppr ~= "" then ppr = "<w:pPr>" .. ppr .. "</w:pPr>" end
  return "<w:p>" .. ppr .. table.concat(runs(list or {}, p or {}), "") .. "</w:p>"
end

local function cat(...)
  local out = {}
  for _, l in ipairs({ ... }) do
    for _, x in ipairs(l) do out[#out + 1] = x end
  end
  return out
end

local function cell_xml(w, c)
  local tcpr = '<w:tcW w:w="' .. w .. '" w:type="dxa"/>'
  local b = ""
  if c.bottom_rule then b = b .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  if c.right_rule then b = b .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  if b ~= "" then tcpr = tcpr .. "<w:tcBorders>" .. b .. "</w:tcBorders>" end
  local mar = ""
  if c.left_pad then mar = mar .. '<w:left w:w="' .. c.left_pad .. '" w:type="dxa"/>' end
  if c.right_pad then mar = mar .. '<w:right w:w="' .. c.right_pad .. '" w:type="dxa"/>' end
  if mar ~= "" then tcpr = tcpr .. "<w:tcMar>" .. mar .. "</w:tcMar>" end
  local body = {}
  for _, p in ipairs(c.paras) do body[#body + 1] = para_xml(p.style, p.list, p.p, p.indent) end
  if #body == 0 then body[1] = "<w:p/>" end
  return "<w:tc><w:tcPr>" .. tcpr .. "</w:tcPr>" .. table.concat(body) .. "</w:tc>"
end

local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local out = {
    '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
      .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
      .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
      .. '<w:tblLayout w:type="fixed"/>'
      .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
      .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. "</w:tblGrid>",
  }
  for _, row in ipairs(rows) do
    local cells = {}
    for i, c in ipairs(row) do cells[#cells + 1] = cell_xml(widths[i], c) end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- a section break: the paragraph that ends a section with its page setup and page-number format
local function section_end(footer, fmt, start)
  local pg = ""
  if fmt then
    pg = '<w:pgNumType w:fmt="' .. fmt .. '"' .. (start and (' w:start="' .. start .. '"') or "") .. "/>"
  end
  return raw('<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. "</w:sectPr></w:pPr></w:p>")
end

-- ---------------------------------------------------------------------------
-- Numbering of the headings (typst heading-num: level 2 "I.", 3 "A.", 4 "1.", 5 "a.")
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function label(level, k)
  if level == 2 then return roman(k) .. "." end
  if level == 3 then return string.char(64 + k) .. "." end
  if level == 4 then return tostring(k) .. "." end
  if level == 5 then return string.char(96 + k) .. "." end
  return nil
end

-- ---------------------------------------------------------------------------
-- Cover, contents, authorities, signature
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local function add(xml) out[#out + 1] = raw(xml) end
  for _, line in ipairs(need(meta, "counsel")) do add(para_xml("Single", line)) end
  add(para_xml("Gap", {}))
  for _, line in ipairs(need(meta, "court")) do
    add(para_xml("Centered", line, { b = true, caps = true }))
  end
  add(para_xml("Gap", {}))

  local left = {}
  for k, side in ipairs(need(meta, "caption").parties) do
    for _, n in ipairs(side.names) do left[#left + 1] = { style = "Single", list = n } end
    left[#left + 1] = { style = "Single", list = side.designation, indent = CFG.party_indent }
    if k < #need(meta, "caption").parties then
      left[#left + 1] = { style = "Single", list = { pandoc.Str("v.") } }
    end
  end
  left[#left + 1] = { style = "Half", list = {} }

  local cn = plain(need(meta, "case_number"))
  local right = { { style = "Single", list = { pandoc.Str("Civil Action No. " .. cn) } } }
  local judge = plain(need(meta, "judge"))
  if judge ~= "" then
    right[#right + 1] = { style = "Half", list = {} }
    right[#right + 1] = { style = "Single", list = { pandoc.Str("Hon. " .. judge .. ", U.S.D.J.") } }
  end
  right[#right + 1] = { style = "Half", list = {} }
  right[#right + 1] = { style = "Single", list = cat({ pandoc.Str("Motion Day: ") }, need(meta, "motion_day")) }

  add(table_xml({ CFG.caption_left, CFG.caption_right }, {
    {
      { paras = left, right_rule = true, bottom_rule = true, right_pad = CFG.caption_left_pad },
      { paras = right, left_pad = CFG.caption_right_pad },
    },
  }))
  add(para_xml("Gap", {}))
  add(para_xml("Centered", need(meta, "title"), { b = true, caps = true }))
  out[#out + 1] = section_end(CFG.footer_blank, nil, nil)
  return out
end

local function signature(meta)
  local sig = need(meta, "signature")
  local left = { { style = "Single", list = cat({ pandoc.Str("Dated: ") }, need(meta, "date")) } }
  local right = {
    { style = "Single", list = { pandoc.Str("Respectfully submitted,") } },
    { style = "Half", list = {} },
    { style = "Single", list = { pandoc.Str("/s/ " .. plain(sig.signer)) } },
    { style = "Single", list = sig.signer },
  }
  for _, l in ipairs(sig.firm) do right[#right + 1] = { style = "Single", list = l } end
  for _, l in ipairs(sig.lines) do right[#right + 1] = { style = "Single", list = l } end
  return table_xml({ CFG.sig_left, CFG.sig_right }, {
    { { paras = left }, { paras = right } },
  })
end

-- the body's headings, in order, for the contents (level 1 to 4, as the typst contents lists them)
local function contents_entries(blocks)
  local entries = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= 4 then entries[#entries + 1] = b end
  end
  return entries
end

-- ---------------------------------------------------------------------------
-- The brief
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "judge", "court", "caption", "counsel", "title", "motion_day", "signature", "date" }) do
    need(meta, k)
  end
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite }
  end

  -- authority links: the link text stays; the key is recorded for the table of authorities
  local used, order = {}, {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("njd-motion: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      if not used[key] then
        used[key] = true
        order[#order + 1] = key
      end
      return el.content
    end,
  })

  -- heading labels, as the typst counter does (a higher level resets the deeper counters)
  local counters = { 0, 0, 0, 0, 0, 0 }
  local blocks = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      counters[b.level] = counters[b.level] + 1
      for k = b.level + 1, 6 do counters[k] = 0 end
      if b.level >= 2 then
        local lab = label(b.level, counters[b.level])
        if lab then
          table.insert(b.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
          table.insert(b.content, 1, pandoc.Str(lab))
        end
      end
    end
    blocks[#blocks + 1] = b
  end

  local out = {}
  local function add(x) out[#out + 1] = x end
  local function addall(xs) for _, x in ipairs(xs) do add(x) end end

  -- section 1: the cover (blank footer, no number)
  addall(cover(meta))

  -- section 2: the contents and the table of authorities (roman numerals from i)
  add(raw(para_xml("UnlistedHeading", { pandoc.Str(CFG.toc_title) })))
  -- the contents is a TOC field over the heading styles; the cached entries are the headings (no page numbers)
  -- one paragraph per heading: the field begins in the first entry and ends in the last
  local entries = contents_entries(blocks)
  local toc_begin = '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h \\z </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  local toc_end = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
  if #entries == 0 then
    add(raw('<w:p><w:pPr><w:pStyle w:val="TOCEntry"/></w:pPr>' .. toc_begin .. toc_end .. "</w:p>"))
  end
  for i, h in ipairs(entries) do
    local list, ppr = h.content, '<w:pStyle w:val="TOCEntry"/>'
    if h.level == 1 then
      list = { pandoc.Str(plain(h.content):upper()) }
    else
      ppr = ppr .. '<w:ind w:left="' .. ((h.level - 1) * 720) .. '" w:hanging="720" w:firstLine="0"/>'
    end
    add(raw("<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (i == 1 and toc_begin or "")
      .. table.concat(runs(list, {}), "") .. (i == #entries and toc_end or "") .. "</w:p>"))
  end

  add(raw(para_xml("UnlistedHeadingNewPage", { pandoc.Str(CFG.toa_title) })))
  for _, g in ipairs(CFG.groups) do
    local members = {}
    for _, key in ipairs(order) do
      if auth[key].kind == g[1] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local kx = auth[x].name and plain(auth[x].name) or plain(auth[x].cite)
        local ky = auth[y].name and plain(auth[y].name) or plain(auth[y].cite)
        return kx:lower() < ky:lower()
      end)
      add(raw(para_xml("TOAGroup", { pandoc.Str(g[2]) })))
      for _, key in ipairs(members) do
        local a = auth[key]
        local list = {}
        if a.name then
          local nm = a.name
          if g[1] == "case" then nm = { pandoc.Emph(nm) } end
          list = cat(nm, { pandoc.Str(", ") }, a.cite)
        else
          list = a.cite
        end
        add(raw(para_xml("TOAEntry", list)))
      end
    end
  end
  add(section_end(CFG.footer_pages, "lowerRoman", "1"))

  -- section 3: the body (arabic from 1; the final section's page setup comes from reference.docx)
  -- block quotations take the BlockText style (single spaced, indented) from the reference
  for _, b in ipairs(blocks) do add(b) end
  add(raw(para_xml("Gap", {})))
  add(raw(signature(meta)))

  -- pandoc would print the title and date metadata as its own title block; the cover is built here instead
  doc.meta.title, doc.meta.subtitle, doc.meta.author, doc.meta.date, doc.meta.abstract = nil, nil, nil, nil, nil
  doc.blocks = out
  return doc
end
