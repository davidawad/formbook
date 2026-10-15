-- Memorandum in support of a motion, United States District Court for the District of Alaska (akd), DOCX engine.
-- Markdown contract -> Word document on docx/reference.docx. Mirrors typst/akd-motion-brief.typ:
--   section 1 (lower roman): the cover (page i), the table of contents (ii), the table of authorities (iii, ...);
--   section 2 (decimal from 1): the memorandum body, the signature block and the certificate of service.
-- Headings: level 1 centered caps; levels 2 to 5 labelled I., A., 1., a. with a hanging indent (typst hang()).
-- Contents and authorities are built here: their page numbers come from docx/render.sh, which finds each
-- heading and each citation in a rendered pass (environment AKD_PAGES names the file of page labels; AKD_EMIT
-- names the file of search needles it writes). Everything case-specific comes from the frontmatter.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function xpara(style, ppr, runs)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function spacer(twips)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

-- typst heading-num(): level 2 I., level 3 A., level 4 1., level 5 a.
local function heading_label(level, n)
  if level == 2 then return roman(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return tostring(n) .. "." end
  if level == 5 then return string.char(96 + n) .. "." end
  return nil
end

-- inline markdown (names, citations) as pandoc inlines
local function md_inlines(s)
  local d = pandoc.read(s, "markdown+smart")
  if d.blocks[1] and d.blocks[1].content then return d.blocks[1].content end
  return pandoc.List({ pandoc.Str(s) })
end

local function listify(v)
  if v == nil then return nil end
  local t = {}
  for i, x in ipairs(v) do t[i] = x end
  return t
end

local function caption(parties, case_number, judge)
  local left = ""
  for _, s in ipairs(parties) do
    for _, n in ipairs(s.names or {}) do left = left .. xpara("Single", "", run(plain(n))) end
    left = left .. xpara("Single", '<w:spacing w:before="104" w:after="208" w:line="340" w:lineRule="exact"/><w:jc w:val="right"/>', run(plain(s.designation)))
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local right = xpara("Single", '<w:spacing w:before="52" w:after="0" w:line="340" w:lineRule="exact"/><w:ind w:left="104" w:firstLine="0"/>', run("No. " .. case_number))
  if judge then right = right .. xpara("Single", '<w:ind w:left="104" w:firstLine="0"/>', run(judge)) end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="156"/><w:gridCol w:w="4308"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/>' .. rule .. '</w:tcPr>' .. left .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="156" w:type="dxa"/></w:tcPr>' .. xpara("Single", "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4308" w:type="dxa"/></w:tcPr>' .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

-- the cover (page i): counsel block, court title, caption, title, statute (typst cover())
local function cover(m)
  local out = {}
  for _, l in ipairs(m.counsel) do out[#out + 1] = raw(xpara("Single", "", run(plain(l)))) end
  local courts = m.court
  for i, l in ipairs(courts) do
    local ppr = ''
    if i == 1 then ppr = ppr .. '<w:spacing w:before="720" w:after="0" w:line="340" w:lineRule="exact"/>' end
    if i == #courts then ppr = ppr .. '<w:spacing w:before="' .. (i == 1 and 720 or 0) .. '" w:after="432" w:line="340" w:lineRule="exact"/>' end
    out[#out + 1] = raw(xpara("CourtTitle", ppr, run(plain(l))))
  end
  out[#out + 1] = raw(spacer(260))
  out[#out + 1] = caption(m.caption, m.case_number, m.judge)
  out[#out + 1] = raw(xpara("DocTitle", '', run(plain(m.title), true)))
  if m.statute then out[#out + 1] = raw(xpara("Centered", '', run("(" .. m.statute .. ")"))) end
  if m.oral_argument then out[#out + 1] = raw(xpara("Centered", '', run("Oral Argument Requested", true))) end
  return out
end

-- the page-label file (pass 2 onward): event number -> printed page label
local function read_pages(path)
  local pages = nil
  if path and path ~= "" then
    local h = io.open(path, "r")
    if h then
      pages = {}
      for line in h:lines() do
        local k, lab = line:match("^(%d+)\t(.*)$")
        if k then pages[tonumber(k)] = lab end
      end
      h:close()
    end
  end
  return pages
end

local function page_of(pages, k)
  if pages == nil then return "0" end
  return pages[k] or "??"
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "case_number", "case_name", "footer_title", "caption", "counsel", "title", "signature" }) do
    if meta[k] == nil then error("akd-motion-brief: the sample frontmatter needs `" .. k .. "`", 0) end
  end
  local m = {
    court = listify(meta.court), counsel = listify(meta.counsel), caption = {},
    case_number = plain(meta.case_number), judge = meta.judge and plain(meta.judge) or nil,
    title = meta.title, statute = meta.statute and plain(meta.statute) or nil,
    oral_argument = meta.oral_argument and true or false,
  }
  for _, p in ipairs(meta.caption) do
    local names = {}
    for _, n in ipairs(p.names or {}) do names[#names + 1] = n end
    m.caption[#m.caption + 1] = { names = names, designation = p.designation }
  end

  -- authorities (typst groups and their sort order)
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    auth[key] = { kind = plain(a.kind), name = a.name and plain(a.name) or nil, cite = a.cite and plain(a.cite) or nil,
      sort = a.sort and plain(a.sort) or nil }
  end

  -- pass A: every heading (levels 1 to 4 are contents entries) and every authority link, in document order.
  -- Each one is an event with a number k; the page finder reports the page of each event.
  local events = {}
  local headers = {}  -- top-level body headings in order: level, content, k (nil unless level <= 4)
  local cites = {}    -- key -> true when the body cites it
  local walked = doc:walk({
    Header = function(h)
      local k = nil
      if h.level <= 4 then
        events[#events + 1] = { kind = "H", text = pandoc.utils.stringify(h.content) }
        k = #events
      end
      headers[#headers + 1] = { level = h.level, k = k, text = pandoc.utils.stringify(h.content) }
      return nil
    end,
    Link = function(l)
      local key = l.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("akd-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      events[#events + 1] = { kind = "O", key = key, text = pandoc.utils.stringify(l.content) }
      cites[key] = true
      return l.content
    end,
  })

  -- labels for the body headings (typst counter(heading) rules: a higher level resets the lower ones)
  local ctr = { 0, 0, 0, 0, 0, 0 }
  local labels = {}  -- header index -> label
  for i, hd in ipairs(headers) do
    ctr[hd.level] = ctr[hd.level] + 1
    for j = hd.level + 1, 5 do ctr[j] = 0 end
    labels[i] = heading_label(hd.level, ctr[hd.level])
  end

  -- a heading is found by its text and the start of the block after it (a short heading alone can occur earlier)
  do
    local hi = 0
    for bi, b in ipairs(walked.blocks) do
      if b.t == "Header" then
        hi = hi + 1
        local t = (labels[hi] and (labels[hi] .. " ") or "") .. pandoc.utils.stringify(b.content)
        local nxt = walked.blocks[bi + 1]
        if nxt and nxt.t == "Header" then
          local nl = labels[hi + 1]
          t = t .. " " .. (nl and (nl .. " ") or "") .. pandoc.utils.stringify(nxt.content)
        elseif nxt and (nxt.t == "Para" or nxt.t == "Plain") then
          t = t .. " " .. pandoc.utils.stringify(nxt)
        end
        if headers[hi] and headers[hi].k then events[headers[hi].k].text = t end
      end
    end
  end

  -- the needle file for the page finder: the first body heading and paragraph (the body's start), then one line
  -- per event in document order
  local first_para = nil
  for _, b in ipairs(walked.blocks) do
    if b.t == "Para" then first_para = pandoc.utils.stringify(b.content); break end
  end
  local first_head = nil
  for _, b in ipairs(walked.blocks) do
    if b.t == "Header" then first_head = pandoc.utils.stringify(b.content); break end
  end
  local emit = os.getenv("AKD_EMIT")
  if emit and emit ~= "" then
    local h = assert(io.open(emit, "w"))
    local function clean(s) return (s:gsub("[\t\r\n]", " ")) end
    h:write("B\t" .. clean((first_head or "") .. " " .. (first_para or "")):sub(1, 120) .. "\n")
    for k, e in ipairs(events) do
      h:write(k .. "\t" .. clean(e.text):sub(1, 40) .. "\n")
    end
    h:close()
  end
  local pages = read_pages(os.getenv("AKD_PAGES"))

  -- ---- front matter ----
  local out = {}
  local function add(b) out[#out + 1] = b end
  for _, b in ipairs(cover(m)) do add(b) end

  -- table of contents (page ii)
  add(raw('<w:p><w:pPr><w:pStyle w:val="TOCTitle"/><w:pageBreakBefore/></w:pPr>' .. run("Table of Contents") .. '</w:p>'))
  add(raw(xpara("PageLabel", '', run("Page"))))
  for i, hd in ipairs(headers) do
    if hd.k then
      local lab = labels[i]
      local content = md_inlines(hd.text)
      if hd.level == 1 then content = pandoc.List({ pandoc.Str(hd.text:upper()) }) end
      local inl = pandoc.List({})
      if lab then inl:insert(pandoc.Str(lab)); inl:insert(TAB) end
      inl:extend(content)
      inl:insert(TAB)
      inl:insert(pandoc.Str(page_of(pages, hd.k)))
      add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "TOCEntry" .. hd.level })))
    end
  end

  -- table of authorities (page iii and on)
  add(raw('<w:p><w:pPr><w:pStyle w:val="TOCTitle"/><w:pageBreakBefore/></w:pPr>' .. run("Table of Authorities") .. '</w:p>'))
  add(raw(xpara("PageLabel", '', run("Page(s)"))))
  local groups = {
    { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "regulation", "Regulations" }, { "other", "Other Authorities" },
  }
  -- event labels per key, in document order, distinct
  local key_pages = {}
  for k, e in ipairs(events) do
    if e.kind == "O" then
      key_pages[e.key] = key_pages[e.key] or {}
      local lab = page_of(pages, k)
      local seen = false
      for _, x in ipairs(key_pages[e.key]) do if x == lab then seen = true end end
      if not seen then key_pages[e.key][#key_pages[e.key] + 1] = lab end
    end
  end
  for _, g in ipairs(groups) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and cites[key] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      local function sk(a) return string.lower(a.sort or a.name or a.cite or "") end
      return sk(x.a) < sk(y.a)
    end)
    if #members > 0 then
      add(raw(xpara("TOAGroup", '', run(g[2]))))
      for _, mem in ipairs(members) do
        local a = mem.a
        local inl = pandoc.List({})
        if a.name then
          local nm = md_inlines(a.name)
          if g[1] == "case" then inl:insert(pandoc.Emph(nm)) else inl:extend(nm) end
          inl:insert(pandoc.Str(", "))
        end
        inl:extend(md_inlines(a.cite))
        inl:insert(TAB)
        local labs = key_pages[mem.key] or {}
        if #labs >= 7 then
          inl:insert(pandoc.Emph({ pandoc.Str("passim") }))
        else
          inl:insert(pandoc.Str(table.concat(labs, ", ")))
        end
        add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "TOAEntry" })))
      end
    end
  end

  -- section break: the front matter is lower roman (cover i, contents ii, authorities iii, ...)
  add(raw('<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="rId100"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="360" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/></w:sectPr></w:pPr></w:p>'))

  -- ---- body (section 2, from page 1) ----
  local n, hi = 0, 0
  for _, b in ipairs(walked.blocks) do
    if b.t == "Header" then
      hi = hi + 1
      if labels[hi] then
        b.content:insert(1, TAB)
        b.content:insert(1, pandoc.Str(labels[hi]))
      end
      add(b)
    elseif b.t == "Para" then
      add(pandoc.Div({ pandoc.Para(b.content) }, pandoc.Attr("", {}, { ["custom-style"] = "Body" })))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local label = (b.t == "OrderedList") and (tostring(i) .. ".") or "\u{2022}"
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local inl = pandoc.List({ pandoc.Str(label), TAB })
          inl:extend(first.content)
          add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Relief" })))
        end
        for j = 2, #item do add(item[j]) end
      end
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(b.content) do
        if x.t == "Para" or x.t == "Plain" then
          add(pandoc.Div({ pandoc.Para(x.content) }, pandoc.Attr("", {}, { ["custom-style"] = "Quote" })))
        else
          add(x)
        end
      end
    else
      add(b)
    end
  end

  -- signature block (typst signature-block()): the date line, then the firm block at 2.5 in, kept together
  local sig = meta.signature
  local function keep(x) return (x:gsub('<w:pStyle w:val="([^"]+)"/>', '<w:pStyle w:val="%1"/><w:keepNext/>', 1)) end
  if meta.date then
    add(raw(keep(xpara("SingleIndent", '<w:spacing w:before="390" w:after="0" w:line="340" w:lineRule="exact"/>', run(plain(meta.date))))))
  end
  add(raw(spacer(208)))
  for _, l in ipairs(listify(sig.preamble) or {}) do add(raw(keep(xpara("SigBlock", '', run(plain(l)))))) end
  add(raw(spacer(340)))
  add(raw(keep(xpara("SigBlock", '', run("/s/ " .. plain(sig.signer))))))
  add(raw(keep(xpara("SigBlock", '', run(plain(sig.signer))))))
  local lines = listify(sig.lines) or {}
  for i, l in ipairs(lines) do
    add(raw(i < #lines and keep(xpara("SigBlock", '', run(plain(l)))) or xpara("SigBlock", '', run(plain(l)))))
  end

  -- certificate of service, when the sample has one (page break before it, as in typst)
  if meta.certificate then
    local c = meta.certificate
    add(raw(xpara("CourtTitle", '<w:pageBreakBefore/>', run("Certificate of Service"))))
    add(pandoc.Div({ pandoc.Para(c.text) }, pandoc.Attr("", {}, { ["custom-style"] = "Body" })))
    add(raw(spacer(624)))
    add(raw('<w:p><w:pPr><w:pStyle w:val="SigBlock"/><w:pBdr><w:top w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr><w:ind w:left="3600" w:right="720" w:firstLine="0"/></w:pPr></w:p>'))
    add(raw(xpara("SigBlock", '', run(plain(c.signer)))))
  end

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
