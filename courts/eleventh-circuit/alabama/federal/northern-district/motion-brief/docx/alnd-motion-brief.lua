-- alnd motion brief (memorandum in support), DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on reference.docx. The cover, the table of contents and authorities, the body, the signature block
-- and the certificate follow typst/alnd-motion-brief.typ and are built here in the styles of reference.docx.
-- Sections: the cover has no page number; the contents and authorities are numbered i, ii; the body from 1.
-- Heading labels (I., A., 1., a.) are written as text, as the typst template prints them.
--
-- Two passes (render.sh): with `keys_out` set, the filter writes the heading texts and the authority links it
-- finds (pdftotext on the first pass finds their pages); with `pages_in` set, it reads those page numbers
-- into the contents and the authorities. Without either, the page numbers are placeholders.
-- Known limits (see README.md "Engines"): the contents and authorities are typed entries with cached page
-- numbers, not TOC/TA fields; a heading or citation split across a page break is not found by the first pass
-- (render.sh stops then).

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local SECT_COVER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:pPr></w:p>'
local SECT_FRONT = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>'
  .. '<w:footerReference w:type="default" r:id="rIdFooter1"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="lowerRoman" w:start="1"/>'
  .. '</w:sectPr></w:pPr></w:p>'
local PASSIM_AT = 7
-- an empty 1 pt paragraph that starts a new page (the certificate heading starts on its own page)
local PAGE_BREAK = '<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p>'

local function xesc(s)
  local out = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return out
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- metadata value as inlines (markdown already parsed by pandoc)
local function inlines(v)
  if v == nil then return pandoc.List({}) end
  if v.t == "MetaInlines" then return pandoc.List(v) end
  return pandoc.List({ pandoc.Str(text(v)) })
end

-- a comparison key for a heading or a citation: lower case, letters and digits only
local function norm(s)
  local out = s:lower():gsub("[^a-z0-9]", "")
  return out
end

local function need(meta, k)
  if meta[k] == nil then error("alnd-motion-brief: missing required metadata field `" .. k .. "`", 0) end
  return meta[k]
end

local function para(style, content)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- an empty paragraph of the given style (pandoc drops an empty Para, so it is written as raw XML)
local function blank(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

local function upper_inlines(content)
  local out = pandoc.List({})
  for _, el in ipairs(content) do
    if el.t == "Str" then out:insert(pandoc.Str(el.text:upper())) else out:insert(el) end
  end
  return out
end

-- one paragraph of a Word table cell or a text box (raw XML): plain text in a reference style
local function cell_p(style, s, ppr)
  local run = s ~= "" and ('<w:r><w:t xml:space="preserve">' .. xesc(s) .. "</w:t></w:r>") or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. run .. "</w:p>"
end

local NONE = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
  .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'

local function table_xml(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>' .. NONE .. '</w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(rows) .. '</w:tr></w:tbl>'
end

-- caption (typst: two equal columns; the parties with a right and bottom rule, the case number beside them)
local function caption_xml(meta)
  local left = {}
  for i, side in ipairs(need(meta, "caption")) do
    if i > 1 then left[#left + 1] = cell_p("Single", "v.", '<w:jc w:val="center"/>') end
    for _, n in ipairs(side.names) do left[#left + 1] = cell_p("Single", text(n)) end
    left[#left + 1] = cell_p("Single", text(side.designation), '<w:ind w:left="2592"/>')
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local c1 = '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/>' .. rule
    .. '<w:tcMar><w:right w:w="312" w:type="dxa"/><w:bottom w:w="260" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
  local c2 = '<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/></w:tcPr>'
    .. cell_p("Single", text(need(meta, "case_label")) .. " " .. text(need(meta, "case_number")),
      '<w:spacing w:before="78"/><w:ind w:left="312"/>') .. "</w:tc>"
  return table_xml({ 4680, 4680 }, { c1, c2 })
end

-- signature: the firms side by side, each line one paragraph; "" is a gap of 1.5 lines (typst: sig-lines)
local function signature_grid(firms)
  local n = #firms
  local gutter = 432
  local w = math.floor((9360 - gutter * (n - 1)) / n)
  local cells, widths = {}, {}
  for i, lines in ipairs(firms) do
    local ps = {}
    for _, l in ipairs(lines) do
      local s = text(l)
      if s == "" then ps[#ps + 1] = '<w:p><w:pPr><w:pStyle w:val="Gap20Keep"/></w:pPr></w:p>'
      else ps[#ps + 1] = cell_p("Signature", s) end
    end
    local mar = i < n and ('<w:tcMar><w:right w:w="' .. gutter .. '" w:type="dxa"/></w:tcMar>') or ""
    cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. mar .. '</w:tcPr>'
      .. table.concat(ps) .. "</w:tc>"
    widths[#widths + 1] = w
  end
  return table_xml(widths, cells)
end

local function signature_blocks(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = blank("Gap24Keep")
  out[#out + 1] = para("Signature", inlines(need(meta, "date_line")))
  out[#out + 1] = blank("Gap24Keep")
  local firms = {}
  for _, f in ipairs(sig.firms) do firms[#firms + 1] = f end
  out[#out + 1] = pandoc.RawBlock("openxml", signature_grid(firms))
  out[#out + 1] = blank("Gap24Keep")
  for _, l in ipairs(sig.lines or {}) do
    if text(l) == "" then out[#out + 1] = blank("Gap20Keep")
    else out[#out + 1] = para("Signature", inlines(l)) end
  end
  return out
end

-- Heading labels as the typst template prints them: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 unlabeled.
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV",
  "XVI", "XVII", "XVIII", "XIX", "XX" }
local function heading_label(level, n)
  if level == 2 then return ROMAN[n] .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return tostring(n) .. "." end
  if level == 5 then return string.char(96 + n) .. "." end
  return ""
end

-- Reads "H<TAB>key<TAB>page" and "A<TAB>key<TAB>pages" lines (pages comma-joined) written by the first pass.
local function read_pages(path)
  local heads, auths = {}, {}
  local f = io.open(path, "r")
  if not f then error("alnd-motion-brief: cannot read the page list `" .. path .. "`", 0) end
  for line in f:lines() do
    local kind, key, value = line:match("^(%a)\t([^\t]*)\t(.*)$")
    if kind == "H" then heads[key] = value elseif kind == "A" then auths[key] = value end
  end
  f:close()
  return heads, auths
end

local function write_keys(path, first_para, heads, links)
  local f = io.open(path, "w")
  if not f then error("alnd-motion-brief: cannot write `" .. path .. "`", 0) end
  f:write("B\t" .. first_para .. "\n")
  for _, h in ipairs(heads) do f:write("H\t" .. h .. "\t\n") end
  for _, l in ipairs(links) do f:write("L\t" .. l.key .. "\t" .. l.text .. "\n") end
  f:close()
end

-- the contents: the body's headings (levels 1 to 4) and the certificate, in order, each with its page label
local function contents_block(entries, pages)
  local out = {}
  out[#out + 1] = para("FrontTitle", { pandoc.Str("Table of Contents") })
  out[#out + 1] = para("PageLabel", { pandoc.Str("Page") })
  for i, e in ipairs(entries) do
    local page = pages[norm(e.plain)] or "00"
    local content = pandoc.List({})
    if e.label ~= "" then content:insert(pandoc.Str(e.label)); content:insert(TAB) end
    content:extend(e.level == 1 and upper_inlines(e.content) or e.content)
    content:insert(TAB)
    content:insert(pandoc.Str(page))
    if i == 1 then
      content:insert(1, pandoc.RawInline("openxml", '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
        .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h \\z \\u </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'))
    end
    if i == #entries then
      content:insert(pandoc.RawInline("openxml", '<w:r><w:fldChar w:fldCharType="end"/></w:r>'))
    end
    out[#out + 1] = para("TOC" .. e.level, content)
  end
  return out
end

-- the table of authorities: the authorities the body links to, by kind, with the pages of each
local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" }, { "other", "Other Authorities" },
}

local function authorities_block(auth, used, pages)
  local out = {}
  out[#out + 1] = para("FrontTitleBreak", { pandoc.Str("Table of Authorities") })
  out[#out + 1] = para("PageLabel", { pandoc.Str("Page(s)") })
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local ax = auth[x].name ~= "" and auth[x].name or auth[x].cite
        local ay = auth[y].name ~= "" and auth[y].name or auth[y].cite
        return ax:lower() < ay:lower()
      end)
      out[#out + 1] = para("TOAGroup", { pandoc.Str(g[2]) })
      for _, key in ipairs(members) do
        local a = auth[key]
        local content = pandoc.List({})
        if a.name_inl and #a.name_inl > 0 then
          if g[1] == "case" then content:insert(pandoc.Emph(a.name_inl)) else content:extend(a.name_inl) end
          content:insert(pandoc.Str(", "))
        end
        content:extend(a.cite_inl)
        content:insert(TAB)
        local labels = pages[key] or "00"
        local n = select(2, labels:gsub(",", ",")) + 1
        if n >= PASSIM_AT then
          content:insert(pandoc.Emph({ pandoc.Str("passim") }))
        else
          content:insert(pandoc.Str((labels:gsub(",", ", "))))
        end
        out[#out + 1] = para("TOAEntry", content)
      end
    end
  end
  return out
end

-- the certificate of service (typst: heading, text, date and signature on the right)
local function certificate_blocks(meta)
  local c = meta.certificate
  local out = {}
  out[#out + 1] = pandoc.RawBlock("openxml", PAGE_BREAK)
  out[#out + 1] = pandoc.Header(1, inlines(c.title))
  out[#out + 1] = para("UnnumberedKeep", inlines(c.text))
  out[#out + 1] = blank("Gap24Keep")
  out[#out + 1] = para("CertRight", inlines(c.date_line))
  out[#out + 1] = blank("Gap24Keep")
  out[#out + 1] = para("CertRight", { pandoc.Str("/s/ " .. text(c.signer)) })
  out[#out + 1] = para("CertRight", inlines(c.signer))
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "caption", "case_label", "case_number", "brief_title", "signature", "date_line" }) do
    need(meta, k)
  end

  -- authorities: name and cite as inlines; the kind as text
  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = {
        kind = text(a.kind),
        name = text(a.name),
        name_inl = a.name and inlines(a.name) or nil,
        cite = text(a.cite),
        cite_inl = inlines(a.cite),
      }
    end
  end

  -- body links to authorities (toa:key) become their text; each use is recorded in document order
  local used, links = {}, {}
  local body = pandoc.Pandoc(doc.blocks):walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("alnd-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      links[#links + 1] = { key = key, text = norm(text(pandoc.Plain(el.content))) }
      return el.content
    end,
  }).blocks

  -- headings and their labels; the contents list levels 1 to 4
  local counts = { 0, 0, 0, 0, 0 }
  local entries, heads, first_para = {}, {}, nil
  local blocks = {}
  for _, b in ipairs(body) do
    if b.t == "Header" then
      if b.level > 5 then error("alnd-motion-brief: headings deeper than level 5 are not in the template", 0) end
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 5 do counts[k] = 0 end
      local label = heading_label(b.level, counts[b.level])
      heads[#heads + 1] = norm(text(b.content))
      if b.level <= 4 then
        entries[#entries + 1] = { level = b.level, label = label, content = b.content, plain = text(b.content) }
      end
      local content = pandoc.List({})
      if label ~= "" then content:insert(pandoc.Str(label)); content:insert(TAB) end
      content:extend(b.content)
      blocks[#blocks + 1] = pandoc.Header(b.level, content)
    else
      if not first_para and (b.t == "Para" or b.t == "Plain") then first_para = norm(text(b)) end
      blocks[#blocks + 1] = b
    end
  end
  local cert = meta.certificate
  if cert then
    entries[#entries + 1] = { level = 1, label = "", content = inlines(cert.title), plain = text(cert.title) }
    heads[#heads + 1] = norm(text(cert.title))
  end

  -- first pass: the keys for the page search; second pass: the page numbers
  if meta.keys_out then
    write_keys(text(meta.keys_out), (first_para or ""):sub(1, 60), heads, links)
  end
  local head_pages, auth_pages = {}, {}
  if meta.pages_in then
    head_pages, auth_pages = read_pages(text(meta.pages_in))
  end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover (page without a number): court, caption, title
  for _, l in ipairs(need(meta, "court")) do add(para("CourtTitle", inlines(l))) end
  add(blank("Gap24Keep"))
  add(pandoc.RawBlock("openxml", caption_xml(meta)))
  add(blank("Gap24Keep"))
  add(para("CoverTitle", inlines(need(meta, "brief_title"))))
  add(pandoc.RawBlock("openxml", SECT_COVER))

  -- front matter (roman numbers): contents, then authorities on a new page
  addall(contents_block(entries, head_pages))
  addall(authorities_block(auth, used, auth_pages))
  add(pandoc.RawBlock("openxml", SECT_FRONT))

  -- body (arabic numbers from 1), signature block, certificate on its own page
  addall(blocks)
  addall(signature_blocks(meta))
  if meta.certificate then addall(certificate_blocks(meta)) end

  doc.blocks = out
  return doc
end
