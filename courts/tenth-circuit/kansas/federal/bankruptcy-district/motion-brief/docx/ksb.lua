-- D. Kan. Bankr. memorandum in support of a motion, DOCX engine (docs/DOCX.md). Mirrors
-- typst/ksb-motion-brief.typ: the counsel block, caption, title, table of contents, table of authorities,
-- body, signature block and certificate of service are built here as raw WordprocessingML; the body keeps
-- pandoc's paragraphs. Headings below level 1 get their labels (A., 1., a.) as the typst template numbers them.
-- The TOC and TOA page numbers come from a first pass (docx/render.sh): this filter writes the search phrases
-- (KSB_SEARCH) and reads the pages found in the first-pass PDF (KSB_PAGES). Toa links are read from `toa:KEY`.

local SEARCH_OUT = os.getenv("KSB_SEARCH")
local PAGES_IN = os.getenv("KSB_PAGES")
local PASSIM = 7 -- an authority on this many pages or more prints "passim" (typst passim-threshold)
local TEXT_W = 9360
local CAPTION_LEFT = 5184
local SIG_RIGHT = 4608
local GAP = 320   -- 16 pt: line-pitch * 0.5
local LINE = 640  -- 32 pt: line-pitch
local SMALL = 160 -- 8 pt: line-pitch * 0.25 (caption gaps)

local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" }, { "other", "Other Authorities" },
}

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function norm(s)
  -- non-breaking spaces (pandoc smart punctuation) are plain spaces in the PDF text
  s = s:gsub("\u{a0}", " ")
  return (s:gsub("%s+", " "):lower():gsub("^ ", ""):gsub(" $", ""))
end

local function last_words(s, n)
  -- the page of a citation is the page where its link ends (typst records the link end, the same convention), so
  -- the search phrase is the last words of the link text; a line break inside it does not matter (see pages.lua)
  local words = {}
  for w in s:gmatch("%S+") do words[#words + 1] = w end
  local out = {}
  for i = math.max(1, #words - n + 1), #words do out[#out + 1] = words[i] end
  return table.concat(out, " ")
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, o)
  o = o or {}
  local rpr = (o.b and "<w:b/>" or "") .. (o.i and "<w:i/>" or "")
  return "<w:r>" .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local TAB = "<w:r><w:tab/></w:r>"

-- one paragraph: style, runs, and optional o.before / o.after (twips), o.left, o.hanging, o.jc, o.tabs (xml),
-- o.break_before (page break before the paragraph)
local function para(style, runs, o)
  o = o or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if o.break_before then ppr = ppr .. "<w:pageBreakBefore/>" end
  if o.tabs then ppr = ppr .. "<w:tabs>" .. o.tabs .. "</w:tabs>" end
  if o.before or o.after then
    ppr = ppr .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '"/>'
  end
  if o.hanging and o.hanging > 0 then
    ppr = ppr .. '<w:ind w:left="' .. (o.left or 0) .. '" w:hanging="' .. o.hanging .. '"/>'
  elseif o.left then
    ppr = ppr .. '<w:ind w:left="' .. o.left .. '" w:firstLine="0"/>'
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. runs .. "</w:p>"
end

local function cell(width, paras, o)
  o = o or {}
  local tcpr = '<w:tcW w:w="' .. width .. '" w:type="dxa"/>'
  if o.rule then
    tcpr = tcpr .. '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  end
  if o.ml or o.mr or o.mb then
    tcpr = tcpr .. "<w:tcMar>"
      .. (o.ml and ('<w:left w:w="' .. o.ml .. '" w:type="dxa"/>') or "")
      .. (o.mb and ('<w:bottom w:w="' .. o.mb .. '" w:type="dxa"/>') or "")
      .. (o.mr and ('<w:right w:w="' .. o.mr .. '" w:type="dxa"/>') or "")
      .. "</w:tcMar>"
  end
  return "<w:tc><w:tcPr>" .. tcpr .. "</w:tcPr>" .. paras .. "</w:tc>"
end

local function row_table(widths, cells)
  local total, grid = 0, ""
  for _, w in ipairs(widths) do
    total = total + w
    grid = grid .. '<w:gridCol w:w="' .. w .. '"/>'
  end
  return "<w:tbl><w:tblPr>"
    .. '<w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. "</w:tblPr><w:tblGrid>" .. grid .. "</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr></w:tbl>"
end

-- ---------------------------------------------------------------------------
-- headings: labels as the typst template numbers them (level 2 "A.", level 3 "1.", level 4 "a.")
-- ---------------------------------------------------------------------------

local function letter(n, lower)
  local ch = string.char(64 + n)
  return lower and ch:lower() or ch
end

local function heading_labels(blocks)
  local c = { 0, 0, 0, 0 }
  local labels = {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = b.level
      c[lv] = c[lv] + 1
      for k = lv + 1, 4 do c[k] = 0 end
      if lv == 2 then labels[i] = letter(c[2]) .. "."
      elseif lv == 3 then labels[i] = tostring(c[3]) .. "."
      elseif lv == 4 then labels[i] = letter(c[4], true) .. "."
      end
    end
  end
  return labels
end

-- ---------------------------------------------------------------------------
-- first-pass search (KSB_SEARCH) and the pages it finds (KSB_PAGES)
-- ---------------------------------------------------------------------------

local function read_pages()
  local toc, toa = {}, {}
  if not PAGES_IN then return toc, toa end
  local f = io.open(PAGES_IN, "r")
  if not f then error("ksb-motion-brief: cannot read KSB_PAGES=" .. PAGES_IN, 0) end
  for line in f:lines() do
    local kind, k, v = line:match("^(%a+)\t([^\t]*)\t?(.*)$")
    if kind == "toc" then toc[tonumber(k)] = v
    elseif kind == "toa" then toa[k] = v
    end
  end
  f:close()
  return toc, toa
end

local function write_search(headings, toa_phrases)
  if not SEARCH_OUT then return end
  local f = io.open(SEARCH_OUT, "w")
  if not f then error("ksb-motion-brief: cannot write KSB_SEARCH=" .. SEARCH_OUT, 0) end
  for i, h in ipairs(headings) do
    f:write("toc\t" .. i .. "\t" .. h.search .. "\n")
  end
  for key, list in pairs(toa_phrases) do
    f:write("toa\t" .. key .. "\t" .. table.concat(list, "|") .. "\n")
  end
  f:close()
end

-- ---------------------------------------------------------------------------
-- the table of contents and the table of authorities
-- ---------------------------------------------------------------------------

local function toc_entry(h, pg)
  local left, hanging
  if h.level == 1 then left, hanging = 720, 720
  elseif h.level == 2 then left, hanging = 720, 720
  elseif h.level == 3 then left, hanging = 1440, 720
  else left, hanging = 2160, 720 end
  local text = h.level == 1 and esc(h.text:upper()) or esc(h.text)
  local runs = ""
  if h.label then runs = runs .. run(h.label) .. TAB end
  runs = runs .. run(text) .. TAB .. run(pg)
  local tabs = '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/>'
  if h.label then tabs = '<w:tab w:val="left" w:pos="' .. left .. '"/>' .. tabs end
  return para("Single", runs, { tabs = tabs, before = 144, left = left, hanging = hanging })
end

local function toc_section(headings, toc_pages)
  local out = {}
  out[#out + 1] = para("Heading1", run("Table of Contents"), { break_before = true })
  out[#out + 1] = para("Single", run("Page", { b = true }), { jc = "right", before = 96 })
  for i, h in ipairs(headings) do
    out[#out + 1] = toc_entry(h, toc_pages[i] or "?")
  end
  return table.concat(out)
end

local function toa_section(auth, used, toa_pages)
  local out = {}
  out[#out + 1] = para("Heading1", run("Table of Authorities"), { break_before = true })
  out[#out + 1] = para("Single", run("Page(s)", { b = true }), { jc = "right", before = 96 })
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local ax, ay = auth[x].sort or auth[x].name or auth[x].cite, auth[y].sort or auth[y].name or auth[y].cite
        return ax:lower() < ay:lower()
      end)
      out[#out + 1] = para("Single", run(g[2], { b = true }), { before = first and GAP or 448, after = 64 })
      first = false
      for _, key in ipairs(members) do
        local a = auth[key]
        local pg = toa_pages[key] or "?"
        local n = 0
        for _ in pg:gmatch("%d+") do n = n + 1 end
        if n >= PASSIM then pg = "passim" end
        local runs = ""
        if a.name then
          runs = runs .. run(a.name, { i = g[1] == "case" }) .. run(", ")
        end
        runs = runs .. run(a.cite) .. TAB .. run(pg)
        local tabs = '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/>'
        out[#out + 1] = para("Single", runs, { tabs = tabs, before = 192, left = 504, hanging = 504 })
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- cover, signature block and certificate of service
-- ---------------------------------------------------------------------------

local function caption_xml(meta)
  local left = { para("Single", run("In re:")) }
  local debtor = meta.debtor
  for i, n in ipairs(debtor.names) do
    left[#left + 1] = para("Single", run(plain(n)), { before = i == 1 and SMALL or 0 })
  end
  left[#left + 1] = para("Single", run(plain(debtor.designation)), { left = 2880, hanging = 0 })
  for si, side in ipairs(meta.caption) do
    if si > 1 then left[#left + 1] = para("Single", run("v."), { before = SMALL, jc = "center" }) end
    for i, n in ipairs(side.names) do
      left[#left + 1] = para("Single", run(plain(n)), { before = i == 1 and SMALL or 0 })
    end
    local last = si == #meta.caption
    left[#left + 1] = para("Single", run(plain(side.designation)), { left = 2880, after = last and SMALL or nil })
  end
  local adv = plain(meta.adversary_number)
  if adv == "" then adv = "Adv. No. " .. string.rep("_", 10) end
  local right = {
    para("Single", run(plain(meta.bankruptcy_case)), { before = LINE * 3 // 2 }),
    para("Single", run(plain(meta.chapter))),
    para("Single", run(adv), { before = LINE * 5 // 2 }),
  }
  return row_table({ CAPTION_LEFT, TEXT_W - CAPTION_LEFT }, {
    cell(CAPTION_LEFT, table.concat(left), { rule = true, mr = 384, mb = SMALL }),
    cell(TEXT_W - CAPTION_LEFT, table.concat(right), { ml = 384 }),
  })
end

local function cover_xml(meta)
  local out = {}
  for i, l in ipairs(meta.counsel) do
    out[#out + 1] = para("Single", run(plain(l)), { before = 0 })
  end
  out[#out + 1] = para("Single", run(plain(meta.counsel_role), { i = true }), { before = GAP })
  local court = meta.court
  for i, l in ipairs(court) do
    out[#out + 1] = para("Single", run(plain(l):upper(), { b = true }),
      { jc = "center", before = i == 1 and GAP or 0, after = i == #court and GAP or 0 })
  end
  out[#out + 1] = caption_xml(meta)
  out[#out + 1] = para("Single", run(plain(meta.title):upper(), { b = true }), { jc = "center", before = GAP })
  return table.concat(out)
end

local function signature_xml(meta)
  local sig = meta.signature
  local left = para("Single", run("Dated: " .. plain(meta.date)), { before = LINE })
  local R = {}
  for i, l in ipairs(sig.preamble or {}) do
    R[#R + 1] = para("Single", run(plain(l)), { before = i == 1 and LINE or 0 })
  end
  R[#R + 1] = para("Single", run("/s/ " .. plain(sig.signer)), { before = GAP })
  local name = plain(sig.signer)
  if sig.bar then name = name .. ", " .. plain(sig.bar) end
  R[#R + 1] = para("Single", run(name))
  for _, l in ipairs(sig.lines or {}) do R[#R + 1] = para("Single", run(plain(l))) end
  if sig.role then R[#R + 1] = para("Single", run(plain(sig.role), { i = true }), { before = GAP }) end
  return row_table({ TEXT_W - SIG_RIGHT, SIG_RIGHT }, {
    cell(TEXT_W - SIG_RIGHT, left),
    cell(SIG_RIGHT, table.concat(R)),
  })
end

local function certificate_xml(meta)
  local svc = meta.service
  local sig = meta.signature
  local out = {}
  out[#out + 1] = para("Heading1", run("Certificate of Service"), { break_before = true })
  out[#out + 1] = para("BodyText", run("I hereby certify that on " .. plain(meta.date)
    .. ", I electronically filed the foregoing " .. plain(svc.document):upper()
    .. " with the Clerk of the Court using the CM/ECF system, which will send notice of electronic filing to all counsel of record."))
  local right = {
    para("Single", run("/s/ " .. plain(svc.signer)), { before = LINE }),
    para("Single", run(plain(svc.signer))),
    para("Single", run(plain(sig.role or ""), { i = true })),
  }
  out[#out + 1] = row_table({ TEXT_W - SIG_RIGHT, SIG_RIGHT }, {
    cell(TEXT_W - SIG_RIGHT, para("Single", "")),
    cell(SIG_RIGHT, table.concat(right)),
  })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtor", "bankruptcy_case", "chapter", "caption", "title", "counsel",
    "counsel_role", "date", "signature" }) do
    if meta[k] == nil then error("ksb-motion-brief: missing required metadata field `" .. k .. "`", 0) end
  end
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    auth[key] = { kind = plain(a.kind), name = a.name and plain(a.name), cite = plain(a.cite),
      sort = a.sort and plain(a.sort) }
  end

  -- authority links: the text stays; the key and its search phrase are recorded
  local used, toa_phrases = {}, {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("ksb-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      toa_phrases[key] = toa_phrases[key] or {}
      table.insert(toa_phrases[key], last_words(norm(plain(el.content)), 3))
      return el.content
    end,
  })

  -- LBR 9013.1(a)(1)-(4): the four sections must be there
  local found = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      local t = plain(b.content):upper()
      for _, frag in ipairs({ "NATURE", "FACT", "QUESTION", "ARGUMENT" }) do
        if t:find(frag, 1, true) then found[frag] = true end
      end
    end
  end
  for _, frag in ipairs({ "NATURE", "FACT", "QUESTION", "ARGUMENT" }) do
    if not found[frag] then error("ksb-motion-brief: no level-1 heading containing `" .. frag .. "` (LBR 9013.1(a))", 0) end
  end

  -- headings in document order: label, text, search phrase
  local labels = heading_labels(doc.blocks)
  local headings = {}
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local text = plain(b.content)
      -- a level-1 heading is set in capitals, so its phrase is searched in capitals; the others as typed
      local search = (text:gsub("\u{a0}", " "):gsub("%s+", " "):gsub("^ ", ""):gsub(" $", ""))
      if b.level == 1 then search = search:upper() end
      search = search:sub(1, utf8.offset(search, 41) and utf8.offset(search, 41) - 1 or #search)
      headings[#headings + 1] = { level = b.level, label = labels[i], text = text, search = search }
    end
  end
  if #headings == 0 then error("ksb-motion-brief: the body has no headings", 0) end
  write_search(headings, toa_phrases)
  local toc_pages, toa_pages = read_pages()

  local out = {}
  local function add(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end
  add(cover_xml(meta))
  add(toc_section(headings, toc_pages))
  add(toa_section(auth, used, toa_pages))

  -- body: the first heading starts on a new page (typst pagebreak after the TOA)
  local first_header = true
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local content = pandoc.List({})
      if first_header then
        -- the page break is the first run of the heading, so no empty line is left at the foot of the TOA
        content:insert(pandoc.RawInline("openxml", '<w:r><w:br w:type="page"/></w:r>'))
        first_header = false
      end
      if labels[i] then
        content:insert(pandoc.Str(labels[i]))
        content:insert(pandoc.RawInline("openxml", TAB))
      end
      content:extend(b.content)
      b.content = content
    end
    out[#out + 1] = b
  end
  add(signature_xml(meta))
  add(certificate_xml(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
