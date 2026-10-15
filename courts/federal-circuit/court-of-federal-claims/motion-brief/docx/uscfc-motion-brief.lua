-- uscfc-motion-brief.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads as
-- typst/uscfc-motion-brief.typ does (README "Engines"): the cover (caption, title, counsel), the table of contents
-- and table of authorities (front matter, roman), the numbered headings (I., A., 1., a., (1)), the links to
-- authorities (toa:KEY), the signature block and the certificate of service (body, arabic from 1).
-- The page numbers in the table of contents and authorities are measured on a build of this file (docx/render.sh):
-- the render searches the PDF for each heading's text and each authority link's text, and this file prints them
-- again with the page numbers. Nothing here is a case's text or a measured coordinate.

local MAP_FILE = os.getenv("USCFC_MAP") or ""
local LIST_FILE = os.getenv("USCFC_LIST") or ""

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Run properties in CT_RPr order: b, i, caps, color, sz, u.
local function rpr(f)
  local x = ""
  if f.b then x = x .. "<w:b/><w:bCs/>" end
  if f.i then x = x .. "<w:i/><w:iCs/>" end
  if f.caps then x = x .. "<w:caps/>" end
  if f.color then x = x .. '<w:color w:val="' .. f.color .. '"/>' end
  if f.sz then x = x .. '<w:sz w:val="' .. f.sz .. '"/><w:szCs w:val="' .. f.sz .. '"/>' end
  if f.u then x = x .. '<w:u w:val="single"/>' end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function merge(f, more)
  local out = {}
  for k, v in pairs(f) do out[k] = v end
  for k, v in pairs(more) do out[k] = v end
  return out
end

local function run(text, f)
  return "<w:r>" .. rpr(f or {}) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local TAB = "<w:r><w:tab/></w:r>"
local BREAK = "<w:r><w:br/></w:r>"

-- Paragraph properties in CT_PPr order: pStyle, keepNext, keepLines, pageBreakBefore, tabs, spacing, ind, jc, sectPr.
-- Lines are single spaced (exact 15.6 pt, the typst single pitch) unless a spacing is given.
local function ppr(o)
  o = o or {}
  local x = ""
  if o.keepNext then x = x .. "<w:keepNext/>" end
  if o.pageBreakBefore then x = x .. "<w:pageBreakBefore/>" end
  if o.dotTab then x = x .. '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs>' end
  if o.rightTab then x = x .. '<w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs>' end
  x = x .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) ..
    '" w:line="' .. (o.line or 312) .. '" w:lineRule="exact"/>'
  if o.hang then
    x = x .. '<w:ind w:left="' .. o.left .. '" w:hanging="' .. o.hang .. '"/>'
  else
    x = x .. '<w:ind w:left="' .. (o.left or 0) .. '" w:firstLine="' .. (o.first or 0) .. '"/>'
  end
  x = x .. '<w:jc w:val="' .. (o.jc or "left") .. '"/>'
  if o.sect then x = x .. o.sect end
  return "<w:pPr>" .. x .. "</w:pPr>"
end

local function para(content, o)
  return "<w:p>" .. ppr(o) .. content .. "</w:p>"
end

-- Inline pandoc content to runs (emphasis kept: case names and the italic lines of the sample).
local function inl(list, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then
      out[#out + 1] = BREAK
    elseif t == "Emph" then
      out[#out + 1] = inl(el.content, merge(f, { i = true }))
    elseif t == "Strong" then
      out[#out + 1] = inl(el.content, merge(f, { b = true }))
    elseif t == "Quoted" then
      local open, close = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then open, close = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(open, f) .. inl(el.content, f) .. run(close, f)
    elseif t == "Link" or t == "Span" then
      out[#out + 1] = inl(el.content, f)
    elseif t == "RawInline" then
      -- tabs are not text
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

local function mi(m)
  if m == nil then return {} end
  if type(m) == "string" then return { pandoc.Str(m) } end
  if type(m) == "boolean" then return {} end
  return m
end

local function plain(m)
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(mi(m))
end

local function flag(m)
  return m == true
end

local function need(meta, key)
  if meta[key] == nil then error("uscfc-motion-brief.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- ---------------------------------------------------------------------------
-- Page map: from docx/render.sh, lines "H <index> <body page>" and "A <key> <body pages>" (written after a measured
-- build). USCFC_LIST, when set, makes this build write the texts render.sh searches for: "H <index> <text>" for each
-- heading and "L <key> <text>" for each authority link.
-- ---------------------------------------------------------------------------

local HEADPAGE = {}
local AUTHPAGES = {}
if MAP_FILE ~= "" then
  local fh = io.open(MAP_FILE, "r")
  if fh == nil then error("uscfc-motion-brief.lua: cannot read " .. MAP_FILE) end
  for line in fh:lines() do
    local kind, a, b = line:match("^(%a) (%S+) (%S+)$")
    if kind == "H" then HEADPAGE[tonumber(a)] = b
    elseif kind == "A" then AUTHPAGES[a] = b end
  end
  fh:close()
end

-- ---------------------------------------------------------------------------
-- Headings: the numbering of the typst template (I. / A. / 1. / a. / (1))
-- ---------------------------------------------------------------------------

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function label(level, n)
  if level == 1 then return roman(n) .. "." end
  if level == 2 then return string.char(64 + n) .. "." end
  if level == 3 then return n .. "." end
  if level == 4 then return string.char(96 + n) .. "." end
  return "(" .. n .. ")"
end

local counts = { 0, 0, 0, 0, 0, 0 }
local HEADINGS = {}   -- { index, level, label, content (inlines) }
local LINKED = {}     -- authority keys linked in the body
local LINK_TEXTS = {} -- { key, text } for each link, for the page search (USCFC_LIST)

function Header(el)
  if el.level > 5 then error("uscfc-motion-brief.lua: headings deeper than level 5 are not supported") end
  counts[el.level] = counts[el.level] + 1
  for k = el.level + 1, 6 do counts[k] = 0 end
  local idx = #HEADINGS + 1
  local lab = label(el.level, counts[el.level])
  -- The table of contents gets its own copy of the text, without the label.
  local text = {}
  for i, x in ipairs(el.content) do text[i] = x end
  HEADINGS[idx] = { index = idx, level = el.level, label = lab, content = text }
  -- The label goes before the text, then a tab (level 1: a space, centred).
  local sep = el.level == 1 and pandoc.Space() or pandoc.RawInline("openxml", TAB)
  table.insert(el.content, 1, sep)
  table.insert(el.content, 1, pandoc.Str(lab))
  return el
end

-- Authority links: [*Full cite*](toa:KEY). The text is shown as is.
function Link(el)
  if el.target:sub(1, 4) == "toa:" then
    local key = el.target:sub(5)
    LINKED[key] = true
    LINK_TEXTS[#LINK_TEXTS + 1] = { key = key, text = pandoc.utils.stringify(el.content) }
    return el.content
  end
  return nil
end

-- ---------------------------------------------------------------------------
-- Cover (RCFC 10(a), 5.5(h) bid protest, 5.5(g) judge; 5.5(f) counsel)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  out[#out + 1] = para(run("IN THE UNITED STATES COURT OF FEDERAL CLAIMS", { b = true }), { jc = "center" })
  if flag(meta.bid_protest) then
    out[#out + 1] = para(run("BID PROTEST", { b = true }), { jc = "center" })
  end
  out[#out + 1] = para("", { before = 240 })
  -- Caption rows: each party's name, then its role indented 1.6 in, then a gap row (typst caption-block).
  local rows = {}
  for _, p in ipairs(need(meta, "parties")) do
    if p.name ~= nil then rows[#rows + 1] = para(inl(mi(p.name), {}), {}) end
    if p.role ~= nil then rows[#rows + 1] = para(inl(mi(p.role), {}), { left = 2304 }) end
    if p.name == nil and p.role == nil then rows[#rows + 1] = para("", {}) end
    rows[#rows + 1] = para("", {})
  end
  local bars = {}
  for i = 1, #rows do bars[i] = para(run(")", {}), { jc = "center" }) end
  local right = {
    para(run("Case No. " .. plain(need(meta, "case_number")), {}), { before = 0 }),
    para("", {}),
    para(inl(mi(need(meta, "judge")), {}), {}),
  }
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="504"/><w:gridCol w:w="3960"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/></w:tcPr>' .. table.concat(rows) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="504" w:type="dxa"/></w:tcPr>' .. table.concat(bars) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="3960" w:type="dxa"/><w:vAlign w:val="center"/></w:tcPr>' .. table.concat(right) .. '</w:tc>' ..
    '</w:tr></w:tbl>'
  out[#out + 1] = para(run(plain(need(meta, "brief_title")):upper(), { b = true }), { jc = "center", before = 480, after = 360 })
  -- Counsel groups side by side (RCFC 5.5(f): the attorney of record's e-mail and telephone number).
  local groups = need(meta, "counsel")
  local cells = {}
  local width = math.floor(9360 / #groups)
  for _, g in ipairs(groups) do
    local lines = {}
    for _, n in ipairs(g.names) do lines[#lines + 1] = para(inl(mi(n), {}), { after = 90 }) end
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = para(inl(mi(l), { i = true }), { after = 90 }) end
    cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. table.concat(lines) .. '</w:tc>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. string.rep('<w:gridCol w:w="' .. width .. '"/>', #groups) .. '</w:tblGrid><w:tr>' ..
    table.concat(cells) .. '</w:tr></w:tbl>'
  return out
end

-- Section properties: the cover has no page number, the front matter is roman from i, the body arabic from 1
-- (the body's own sectPr is in the reference). Each break is a paragraph that ends its section.
local SECT_PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local function section_break(fmt)
  local footer = fmt == "none" and "" or '<w:footerReference w:type="default" r:id="rIdFooter1"/>'
  local numfmt = fmt == "none" and "decimal" or fmt
  local sect = "<w:sectPr>" .. footer .. SECT_PG .. '<w:pgNumType w:fmt="' .. numfmt .. '" w:start="1"/></w:sectPr>'
  return para("", { sect = sect })
end

-- ---------------------------------------------------------------------------
-- Table of contents and table of authorities (RCFC 5.4(a)(2)(A)-(B))
-- ---------------------------------------------------------------------------

local function toc()
  local out = {}
  out[#out + 1] = para(run("TABLE OF CONTENTS", { b = true }), { jc = "center", before = 360, after = 264 })
  out[#out + 1] = para(run("Page", { b = true, u = true }), { jc = "right", after = 120 })
  for _, h in ipairs(HEADINGS) do
    local ind = h.level >= 2 and (h.level - 1) * 720 or 0
    local page = HEADPAGE[h.index] or "0"
    -- Level 1 entries are capitals, as the typst table of contents sets them.
    local text = inl(h.content, { caps = h.level == 1 })
    out[#out + 1] = para(run(h.label, {}) .. TAB .. text .. TAB .. run(page, {}),
      { dotTab = true, left = ind + 720, hang = 720, before = h.level == 1 and 144 or 84, after = 0 })
  end
  return out
end

local function toa(meta)
  local authorities = meta.authorities or {}
  for key, _ in pairs(LINKED) do
    if authorities[key] == nil then
      error("uscfc-motion-brief.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  local groups = {
    { "case", "Cases:" }, { "statute", "Statutes:" }, { "regulation", "Regulations:" },
    { "rule", "Rules:" }, { "other", "Other Authorities:" },
  }
  local out = {}
  out[#out + 1] = para(run("TABLE OF AUTHORITIES", { b = true }), { jc = "center", pageBreakBefore = true, after = 264 })
  local first = true
  for _, g in ipairs(groups) do
    local members = {}
    for key, a in pairs(authorities) do
      if plain(a.kind) == g[1] and AUTHPAGES[key] ~= nil then members[#members + 1] = key end
    end
    if #members > 0 then
      local function sk(key)
        local a = authorities[key]
        local s = a.sort and plain(a.sort) or (plain(a.name or "") .. " " .. plain(a.cite))
        return s:lower():gsub("[^a-z0-9 ]", "")
      end
      table.sort(members, function(x, y) return sk(x) < sk(y) end)
      local head = run(g[2], { b = true })
      if first then head = head .. TAB .. run("Page(s)", { b = true, u = true }) end
      out[#out + 1] = para(head, { rightTab = first, before = first and 240 or 336, after = 120 })
      first = false
      for _, key in ipairs(members) do
        local a = authorities[key]
        local pages = AUTHPAGES[key]
        local pagecount = 0
        for _ in pages:gmatch("[^,]+") do pagecount = pagecount + 1 end
        local shown = pagecount >= 7 and run("passim", { i = true }) or run((pages:gsub(",", ", ")), {})
        local lead = {}
        if a.name ~= nil then
          local nameruns = g[1] == "case" and inl(mi(a.name), { i = true }) or inl(mi(a.name), {})
          lead[#lead + 1] = nameruns .. run(",", {}) .. BREAK
        end
        lead[#lead + 1] = inl(mi(a.cite), {}) .. TAB .. shown
        out[#out + 1] = para(table.concat(lead), { dotTab = true, hang = 504, left = 504, before = 168, after = 0 })
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (RCFC 5.5(e), 5.5(f), 5.3)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = para(run("Dated: " .. plain(need(meta, "date")), {}), { keepNext = true, before = 672 })
  out[#out + 1] = para(run("Respectfully submitted,", {}), { keepNext = true, left = 4680, before = 168 })
  out[#out + 1] = para(run("/s/ " .. plain(need(sig, "signer")), {}), { keepNext = true, left = 4680, before = 432 })
  out[#out + 1] = para(run(plain(sig.signer), {}), { keepNext = true, left = 4680 })
  out[#out + 1] = para(run("Phone: " .. plain(need(meta, "phone")), {}), { keepNext = true, left = 4680 })
  out[#out + 1] = para(run("Email: " .. plain(need(meta, "email")), {}), { keepNext = (#(sig.lines or {}) > 0), left = 4680 })
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do
    out[#out + 1] = para(inl(mi(l), { i = true }), { keepNext = i < #lines, left = 4680 })
  end
  return out
end

local function certificate(meta)
  local svc = need(meta, "service")
  local out = {}
  out[#out + 1] = para(run("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", pageBreakBefore = true, after = 264 })
  out[#out + 1] = para(run("I hereby certify that on this " .. plain(need(svc, "day")) .. ", I caused a true and correct copy of the foregoing ", {}) ..
    inl(mi(svc.documents), {}) .. run(" to be served by " .. plain(need(svc, "manner")) .. " on:", {}),
    { before = 0, after = 240, first = 0, jc = "both" })
  for _, r in ipairs(need(svc, "recipients")) do
    local lines = {}
    for _, l in ipairs(r.lines) do lines[#lines + 1] = inl(mi(l), {}) end
    out[#out + 1] = para(table.concat(lines, BREAK), { left = 720, before = 192, after = 0, keepNext = true })
  end
  out[#out + 1] = para(run("/s/ " .. plain(need(need(meta, "signature"), "signer")), {}), { left = 4680, before = 432 })
  return out
end

-- ---------------------------------------------------------------------------
-- Document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local authorities = meta.authorities or {}
  for _, k in ipairs({ "case_number", "judge", "parties", "brief_title", "counsel", "phone", "email", "signature", "date", "service" }) do
    need(meta, k)
  end

  -- Front matter: cover (no number), then the table of contents and authorities (roman).
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = raw(b) end
  blocks[#blocks + 1] = raw(section_break("none"))
  for _, b in ipairs(toc()) do blocks[#blocks + 1] = raw(b) end
  for _, b in ipairs(toa(meta)) do blocks[#blocks + 1] = raw(b) end
  blocks[#blocks + 1] = raw(section_break("lowerRoman"))

  -- Body (arabic from 1). The render finds its first page by the footer "1" (docx/render.sh).
  local body = doc.blocks
  -- The signature block never stands alone: the last paragraph is kept with it.
  if #body > 0 and body[#body].t == "Para" then
    local last = body[#body]
    body[#body] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "Keep With Next" }))
  end
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = raw(b) end
  for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = raw(b) end

  -- The texts docx/render.sh searches the PDF for (USCFC_LIST): each heading without its label, each link.
  if LIST_FILE ~= "" then
    local fh = assert(io.open(LIST_FILE, "w"))
    for _, h in ipairs(HEADINGS) do fh:write("H ", h.index, " ", pandoc.utils.stringify(h.content), "\n") end
    for _, l in ipairs(LINK_TEXTS) do fh:write("L ", l.key, " ", l.text, "\n") end
    fh:close()
  end

  doc.blocks = blocks
  -- pandoc would print title and date above the body; the cover carries them.
  doc.meta.title = nil
  doc.meta.date = nil
  doc.meta.author = nil
  return doc
end
