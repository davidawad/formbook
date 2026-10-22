-- W.D. Mo. suggestions in support of a motion, docx engine (docs/DOCX.md): the markdown contract -> a Word document
-- that reads and breaks as typst/mowd-motion-brief.typ does: the cover (court title, division, caption, title of the
-- paper), the table of contents, the table of authorities, the numbered headings, the body, the signature block and
-- the certificate of service. Everything printed comes from the sample's frontmatter and body: no case text lives in
-- this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 598 the double-spaced body, 299 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES: every heading and every authority citation, in document order, with the words after it) in the
-- LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle. The cover is a section with
-- no footer (rIdFtrNone); the contents and the authorities number their pages in roman from i (rIdFtrPage); the body
-- and the certificate number theirs from 1 (FORMBOOK_FINAL, rIdFtrPage). Word may paginate slightly differently.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 598, 299           -- typst pitch-double, pitch-single
local INDENT = 720                      -- typst para-indent and quote-indent, 0.5 in
local GAP = 240                         -- typst gap, 12 pt
local TEXTW = 9360                      -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360  -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET = 200                   -- typst caption-inset 10 pt
local SIG_LEFT = 4464                   -- typst sig-left 3.1 in
local STEP, LABEL = 720, 720            -- typst level-step and label-w, 0.5 in
local TOC_COL, TOA_COL = 720, 1440      -- typst toc-page-col 36 pt, toa-page-col 72 pt
local TOA_HANG = 360                    -- typst toa-hang 0.25 in
local PASSIM_AT = 7                     -- typst passim-at
local NEEDLE_MAX = 60

local KIND_ORDER = { "case", "constitution", "statute", "regulation", "rule", "other" }
local KIND_TITLE = {
  case = "Cases", constitution = "Constitutional Provisions", statute = "Statutes",
  regulation = "Regulations", rule = "Rules", other = "Other Authorities",
}

-- A paragraph: o = { before, after, line, left, hanging, right, first, jc, keep, lines, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and o.hanging == nil then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function upper(inl)
  return pandoc.Inlines(inl):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = "B", needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Sections
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: court title, division, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta)
  local court = { "UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF MISSOURI" }
  local out = {}
  for _, t in ipairs(court) do out[#out + 1] = { runs = xe.runs(t, { b = true }) } end
  if meta.division ~= nil then out[#out + 1] = { runs = xe.inl(upper(meta.division), { b = true }) } end
  local res = {}
  for i, l in ipairs(out) do
    -- the caption stands a double line below the court title (Word has no space before a table)
    res[#res + 1] = p(l.runs, { jc = "center", after = i == #out and BODY or 0 })
  end
  -- Caption: each party's names, its designation a line below, the separator a line from either side; the party
  -- column ruled at its right; the case number at the right.
  local left = {}
  local between = meta.caption.between and stringify(meta.caption.between) or "v."
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs(between), { before = SINGLE }) end
    for i, n in ipairs(party.names) do
      left[#left + 1] = p(xe.inl(n), { before = (k > 1 and i == 1) and SINGLE or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { before = SINGLE })
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  res[#res + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid><w:tr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:right ' .. rule .. '/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/>' ..
    '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    p(xe.runs("Case No. ") .. xe.inl(meta.case_number)) .. '</w:tc></w:tr></w:tbl>'
  res[#res + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = BODY })
  return res
end

-- ---------------------------------------------------------------------------
-- Headings: numbered I., A., 1., a. unless the heading has its own number or is Introduction / Certificate
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

local function starts_word(s, word)
  if s:sub(1, #word) ~= word then return false end
  local nxt = s:sub(#word + 1, #word + 1)
  return nxt == "" or not nxt:match("%a")
end

-- An own number at the start of the heading ("I.", "A.", "12.", "a."): returns the label and the rest.
local function split_own_number(inl)
  local first = inl[1]
  if first == nil or first.t ~= "Str" then return nil, inl end
  local n = first.text:match("^([IVXLC]+)%.$") or first.text:match("^([A-H])%.$") or
    first.text:match("^(%d+)%.$") or first.text:match("^([a-h])%.$")
  if n == nil or inl[2] == nil or inl[2].t ~= "Space" then return nil, inl end
  local i = 2
  while inl[i] ~= nil and inl[i].t == "Space" do i = i + 1 end
  local rest = pandoc.Inlines({})
  for j = i, #inl do rest:insert(inl[j]) end
  return n .. ".", rest
end

local COUNTERS = { 0, 0, 0, 0 }
local function label_for(level, k)
  if level == 1 then return roman(k) .. "." end
  if level == 2 then return string.char(64 + k) .. "." end
  if level == 3 then return tostring(k) .. "." end
  return string.char(96 + k) .. "."
end

-- A heading paragraph; records its contents entry. o = { before, brk }.
local function heading(level, content, entries, id, o)
  if level > 4 then error("mowd-motion-brief: heading level " .. level .. " has no style") end
  local plain = stringify(content)
  local entry = { id = id, level = level, label = "", title = content }
  local para
  if starts_word(plain, "Introduction") or starts_word(plain, "Certificate of Service") then
    entry.level = 1
    para = p(xe.inl(upper(content), { b = true }), { keep = true, brk = o.brk, before = o.before, jc = "center" })
  else
    local own, rest = split_own_number(content)
    if own ~= nil then
      entry.label, entry.title = own, rest
    else
      COUNTERS[level] = COUNTERS[level] + 1
      for j = level + 1, 4 do COUNTERS[j] = 0 end
      entry.label = label_for(level, COUNTERS[level])
    end
    local ind = (level - 1) * STEP
    para = p(xe.runs(entry.label .. "\t", { b = true }) .. xe.inl(entry.title, { b = true }),
      { keep = true, brk = o.brk, before = o.before, left = ind + LABEL, hanging = LABEL,
        tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + LABEL) .. '"/></w:tabs>' })
  end
  entries[#entries + 1] = entry
  return para
end

-- ---------------------------------------------------------------------------
-- Contents and authorities: a row's text wraps before the page column, a dot leader runs to the page number
-- ---------------------------------------------------------------------------

local function row(text_xml, page_xml, left, hanging, col, extra_tab)
  local tabs = '<w:tabs>' .. (extra_tab and ('<w:tab w:val="left" w:pos="' .. extra_tab .. '"/>') or "") ..
    '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return p(text_xml .. xe.runs(xe.LEAD) .. page_xml,
    { lines = true, tabs = tabs, before = GAP, left = left, hanging = hanging, right = col })
end

local function toc(entries)
  local out = { p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", after = GAP }) }
  for _, e in ipairs(entries) do
    local ind = (e.level - 1) * STEP
    local pg = xe.runs(labels[e.id] or "0")
    if e.label ~= "" then
      out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), pg, ind + LABEL, LABEL, TOC_COL, ind + LABEL)
    else
      out[#out + 1] = row(xe.inl(e.title), pg, ind, nil, TOC_COL)
    end
  end
  return out
end

local function plain(v)
  if v == nil then return nil end
  return stringify(v)
end

local function toa(meta, cites)
  local out = { p(xe.runs("TABLE OF AUTHORITIES", { b = true }), { brk = true, jc = "center", after = GAP }) }
  local reg = meta.authorities or {}
  -- the pages of each cited authority, from the pages of its citations
  local pages = {}
  for _, c in ipairs(cites) do
    if reg[c.key] == nil then error("mowd-motion-brief: authority key not in the registry: " .. c.key) end
    pages[c.key] = pages[c.key] or {}
    local n = tonumber(labels[c.id] or "0") or 0
    pages[c.key][n] = true
  end
  for _, kind in ipairs(KIND_ORDER) do
    local keyed = {}
    for key, a in pairs(reg) do
      if plain(a.kind) == kind and pages[key] then
        keyed[#keyed + 1] = { key = key, sort = (plain(a.sort) or plain(a.name) or plain(a.cite)):lower(), a = a }
      end
    end
    if #keyed > 0 then
      table.sort(keyed, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      out[#out + 1] = p(xe.runs(KIND_TITLE[kind], { b = true }), { before = GAP, keep = true })
      for _, x in ipairs(keyed) do
        local a = x.a
        local src
        if a.name ~= nil then
          src = (kind == "case") and ("*" .. plain(a.name) .. "*, " .. plain(a.cite)) or (plain(a.name) .. ", " .. plain(a.cite))
        else
          src = plain(a.cite)
        end
        local inl = pandoc.read(src, "markdown+smart").blocks[1].content
        local list = {}
        for n in pairs(pages[x.key]) do list[#list + 1] = n end
        table.sort(list)
        local pg
        if #list >= PASSIM_AT then
          pg = xe.runs("passim", { i = true })
        else
          local s = {}
          for i, n in ipairs(list) do s[i] = tostring(n) end
          pg = xe.runs(table.concat(s, ", "))
        end
        out[#out + 1] = row(xe.inl(inl), pg, TOA_HANG, TOA_HANG, TOA_COL)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Body, signature, certificate
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- The authority links of a paragraph, in order: each a needle (its text and the words after it).
local cite_n = 0
local function record_cites(inlines, cites)
  local flat = {}
  local function walk(list)
    for _, el in ipairs(list) do
      if el.t == "Link" and el.target:sub(1, 4) == "toa:" then
        flat[#flat + 1] = { link = el }
      elseif el.content ~= nil and type(el.content) ~= "string" and el.t ~= "Note" then
        walk(el.content)
      else
        flat[#flat + 1] = { text = stringify(el) }
      end
    end
  end
  walk(inlines)
  for i, f in ipairs(flat) do
    if f.link then
      local ctx = ""
      for j = i + 1, #flat do
        ctx = ctx .. (flat[j].text or stringify(flat[j].link.content))
        if #ctx > 40 then break end
      end
      cite_n = cite_n + 1
      local id = "C:" .. cite_n
      need(id, stringify(f.link.content), ctx)
      cites[#cites + 1] = { id = id, key = f.link.target:sub(5) }
    end
  end
end

local function signature(meta)
  local sig = meta.signature
  local out = {
    p(xe.runs("Respectfully submitted,"), { before = BODY, left = SIG_LEFT, keep = true }),
    p(xe.inl(sig.signer, { b = true }), { before = GAP, left = SIG_LEFT, keep = true }),
  }
  for i, l in ipairs(sig.lines or {}) do
    out[#out + 1] = p(xe.inl(l), { left = SIG_LEFT, keep = i < #sig.lines, lines = true })
  end
  return out
end

local function certificate(meta, entries)
  local svc = meta.service
  local out = {}
  local head = pandoc.Inlines({ pandoc.Str("Certificate"), pandoc.Space(), pandoc.Str("of"), pandoc.Space(), pandoc.Str("Service") })
  need("H:cert", "Certificate of Service", "I hereby certify")
  out[#out + 1] = heading(1, head, entries, "H:cert", { before = 0, brk = true })
  out[#out + 1] = p(xe.runs("I hereby certify that on " .. stringify(svc.date) ..
    ", I caused a copy of the foregoing document to be sent to all counsel of record via this Court\u{2019}s CM/ECF system and via electronic mail to ")
    .. xe.inl(svc.recipients) .. xe.runs("."), { line = BODY, first = INDENT })
  out[#out + 1] = p(xe.inl(svc.signer, { b = true }), { before = SINGLE, left = SIG_LEFT })
  return out
end

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local blocks = doc.blocks

  local body, entries, cites = {}, {}, {}
  local h_n = 0
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local next_text = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
    -- the body's first page starts the arabic numbering (a heading's own needle, or the opening paragraph's)
    if i == 1 and b.t ~= "Header" then need("S:1", stringify(b), next_text) end
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, stringify(b.content), next_text)
      -- the body opens a section (a new page): Word keeps the space above there, typst drops it
      body[#body + 1] = heading(b.level, b.content, entries, id, { before = i == 1 and 0 or SINGLE })
    elseif b.t == "BlockQuote" then
      for j, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("mowd-motion-brief: a block quotation holds only paragraphs") end
        record_cites(q.content, cites)
        body[#body + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT,
          before = j == 1 and SINGLE or 0, after = j == #b.content and SINGLE or 0, keep = last and j == #b.content })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("mowd-motion-brief: a list item holds one paragraph")
        end
        record_cites(item[1].content, cites)
      end
      local items = b.content
      for j, item in ipairs(items) do
        local lab = "\u{2022}"
        if b.t == "OrderedList" then lab = tostring((b.listAttributes.start or 1) + j - 1) .. "." end
        body[#body + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
          { line = BODY, left = INDENT, hanging = INDENT, keep = last and j == #items })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      record_cites(b.content, cites)
      -- the last paragraph stays whole with the signature block (typst: one unbreakable block)
      body[#body + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = last })
    else
      error("mowd-motion-brief: unsupported block " .. b.t)
    end
  end
  local sig = signature(meta)
  local cert = certificate(meta, entries)

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\t" .. (blocks[1] and blocks[1].t == "Header" and "H:1" or "S:1") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  local out = cover(meta)
  out[#out + 1] = section("rIdFtrNone")
  for _, x in ipairs(toc(entries)) do out[#out + 1] = x end
  for _, x in ipairs(toa(meta, cites)) do out[#out + 1] = x end
  out[#out + 1] = section("rIdFtrPage", "lowerRoman")
  for _, x in ipairs(body) do out[#out + 1] = x end
  for _, x in ipairs(sig) do out[#out + 1] = x end
  for _, x in ipairs(cert) do out[#out + 1] = x end

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
