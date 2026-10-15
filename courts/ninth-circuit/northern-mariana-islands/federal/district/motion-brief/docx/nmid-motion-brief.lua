-- nmid motion with memorandum, docx. Mirrors typst/nmid-motion-brief.typ: the cover (counsel, court title,
-- caption with the hearing, the lead-in), the table of contents and the table of authorities (LR 7.1.d.1),
-- the body with hanging-indent headings numbered I., 1., a., (1), footnotes (native), the signature block.
-- Every case word comes from the sample's frontmatter; nothing here is case-specific.
--
-- Page numbers in the TOC and TOA come from a first pass (docx/render.sh): this filter writes the search index
-- (NMID_INDEX_OUT) on the first pass and reads the page map (NMID_PAGES) on the second.

local TEXT_W = 10080   -- twips: 7.0 in between the margins
local PASSIM_AT = 7    -- an authority on this many pages or more prints "passim" (as typst/nmid-motion-brief.typ)
local EXACT_DOUBLE = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="atLeast"/>'
local GAP = '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="atLeast"/>'
local TABXML = '<w:r><w:tab/></w:r>'
local TAB = pandoc.RawInline("openxml", TABXML)

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function run(text, opts)
  opts = opts or {}
  local rpr = ""
  if opts.bold or opts.italic then
    rpr = "<w:rPr>" .. (opts.bold and "<w:b/><w:bCs/>" or "") .. (opts.italic and "<w:i/><w:iCs/>" or "") .. "</w:rPr>"
  end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
end

-- A paragraph's properties in schema order: style, keepNext, keepLines, pageBreakBefore, tabs, spacing, ind, jc.
local function ppr(o)
  local s = '<w:pPr><w:pStyle w:val="' .. (o.style or "Normal") .. '"/>'
  if o.keepNext then s = s .. "<w:keepNext/>" end
  if o.keepLines then s = s .. "<w:keepLines/>" end
  if o.pageBreak then s = s .. "<w:pageBreakBefore/>" end
  if o.tabs then s = s .. o.tabs end
  if o.spacing then s = s .. o.spacing end
  if o.ind then s = s .. o.ind end
  if o.jc then s = s .. o.jc end
  return s .. "</w:pPr>"
end

local function para(style, runs, o)
  o = o or {}
  o.style = style
  return "<w:p>" .. ppr(o) .. (runs or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function cell(width, paras, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") ..
    (mar or "") .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function table_xml(grid, rows)
  local cols = {}
  local total = 0
  for _, w in ipairs(grid) do
    table.insert(cols, '<w:gridCol w:w="' .. w .. '"/>')
    total = total + w
  end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(rows) .. '</w:tr></w:tbl>')
end

-- counsel block: at least seven single lines tall (lines 1 to 7), as in the typst template
local function counsel_table(lines)
  local paras = {}
  for _, t in ipairs(lines) do table.insert(paras, para("Single", run(t), { spacing = SINGLE })) end
  return '<w:tbl><w:tblPr><w:tblW w:w="6048" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="6048"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="3360" w:hRule="atLeast"/></w:trPr>' ..
    cell(6048, paras) .. '</w:tr></w:tbl>'
end

local function blank()
  return raw(para("Normal", ""))
end

-- Labels of the memorandum's headings: level 2 "I.", 3 "1.", 4 "a.", 5 "(1)".
local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function label_of(level, c)
  if level == 2 then return roman(c[2]) .. "."
  elseif level == 3 then return tostring(c[3]) .. "."
  elseif level == 4 then return string.char(string.byte("a") + c[4] - 1) .. "."
  elseif level == 5 then return "(" .. tostring(c[5]) .. ")"
  end
  return nil
end

local function strip_ws(s)
  return (s:gsub("%s", ""):gsub("\194\160", ""))
end

local function first_chars(s, n)
  local len = utf8.len(s)
  if len and len > n then return s:sub(1, utf8.offset(s, n + 1) - 1) end
  return s
end

-- The page map of the first pass: "h<TAB>seq<TAB>page" and "t<TAB>key<TAB>pages".
local function read_pagemap()
  local path = os.getenv("NMID_PAGES")
  if not path then return { h = {}, t = {} } end
  local pm = { h = {}, t = {} }
  local f = assert(io.open(path, "r"))
  for line in f:lines() do
    local kind, id, val = line:match("^(%a+)\t([^\t]*)\t(.*)$")
    if kind == "h" then pm.h[tonumber(id)] = val
    elseif kind == "t" then pm.t[id] = val end
  end
  f:close()
  return pm
end

local KINDS = {
  { "case", "Cases" },
  { "constitution", "Constitutional Provisions" },
  { "statute", "Statutes" },
  { "rule", "Rules" },
  { "regulation", "Regulations" },
  { "other", "Other Authorities" },
}

-- The cover: counsel, court title, the caption with the hearing, the lead-in.
local function cover(meta)
  local blocks = {}
  local counsel = {}
  for _, v in ipairs(meta.counsel or {}) do table.insert(counsel, str(v)) end
  table.insert(blocks, raw(counsel_table(counsel)))
  table.insert(blocks, raw(para("CourtTitle", run("IN THE UNITED STATES DISTRICT COURT", { bold = true }))))
  table.insert(blocks, raw(para("CourtTitle", run("FOR THE NORTHERN MARIANA ISLANDS", { bold = true }))))
  table.insert(blocks, blank())

  local left = {}
  local versus = str(meta.versus)
  if versus == "" then versus = "v." end
  for k, p in ipairs(meta.caption or {}) do
    if k > 1 then table.insert(left, versus) end
    for _, n in ipairs(p.names or {}) do table.insert(left, str(n)) end
    table.insert(left, str(p.designation))
  end
  local lparas = {}
  for _, t in ipairs(left) do table.insert(lparas, para("Single", run(t), { spacing = SINGLE })) end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local h = meta.hearing or {}
  local right = {
    para("Single", run("CIVIL CASE NO. " .. str(meta.case_number)), { spacing = '<w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="atLeast"/>' }),
    para("Single", run(str(meta.brief_title), { bold = true }), { spacing = '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="atLeast"/>' }),
    para("Single", run("Hearing Date: " .. str(h.date)), { spacing = '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="atLeast"/>' }),
    para("Single", run("Hearing Time: " .. str(h.time)), { spacing = SINGLE }),
    para("Single", run("Judge: " .. str(h.judge)), { spacing = SINGLE }),
  }
  table.insert(blocks, table_xml({ 4896, 360, 4824 }, {
    cell(4896, lparas, rule, '<w:tcMar><w:right w:w="144" w:type="dxa"/></w:tcMar>'),
    cell(360, { para("Single", "") }),
    cell(4824, right, nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'),
  }))
  if meta.lead_in then
    table.insert(blocks, pandoc.Div({ pandoc.Para({ pandoc.Str(str(meta.lead_in)) }) }, { ["custom-style"] = "Body Text" }))
  end
  return blocks
end

-- The signature block: "Date:" at left and the signature at right, kept together.
local function signature(meta)
  local sig = meta.signature or {}
  local left = { para("Single", run("Date: " .. str(meta.date)), { spacing = SINGLE }) }
  local right = { para("Single", run("Respectfully submitted,"), { spacing = '<w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="atLeast"/>' }) }
  for _, v in ipairs(sig.preamble or {}) do table.insert(right, para("Single", run(str(v)), { spacing = SINGLE })) end
  local signer = str(sig.signer)
  table.insert(right, para("Single", run("/s/ " .. signer), { spacing = '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="atLeast"/>' }))
  table.insert(right, para("Single", run(signer), { spacing = SINGLE }))
  for _, v in ipairs(sig.lines or {}) do table.insert(right, para("Single", run(str(v)), { spacing = SINGLE })) end
  return table_xml({ 3744, 6336 }, {
    cell(3744, left),
    cell(6336, right, nil, '<w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>'),
  })
end

function Pandoc(doc)
  local meta = doc.meta
  local index_out = os.getenv("NMID_INDEX_OUT")
  local pm = read_pagemap()

  -- 1. the authority links (toa:KEY): recorded for the index and the table, then shown as plain text
  local hits, hit_order = {}, {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if key then
        if not meta.authorities or not meta.authorities[key] then
          error("nmid-motion-brief: link toa:" .. key .. " has no entry under authorities: in the frontmatter")
        end
        if not hits[key] then hits[key] = {}; table.insert(hit_order, key) end
        table.insert(hits[key], strip_ws(first_chars(str(el.content), 40)))
        return el.content
      end
    end,
  })

  -- 2. the headings, with the memorandum's numbering
  local headings = {}
  local c = { 0, 0, 0, 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local L = b.level
      c[L] = c[L] + 1
      for j = L + 1, 5 do c[j] = 0 end
      table.insert(headings, { level = L, label = label_of(L, c), title = str(b.content), seq = #headings + 1 })
    end
  end

  -- 3. the search index for the first pass: kind, id, the text to find on the page (whitespace removed)
  if index_out then
    local f = assert(io.open(index_out, "w"))
    f:write("start\t\tTABLEOFAUTHORITIES\n")
    for _, h in ipairs(headings) do
      f:write("h\t" .. h.seq .. "\t" .. strip_ws((h.label or "") .. h.title) .. "\n")
    end
    for _, key in ipairs(hit_order) do
      for _, s in ipairs(hits[key]) do f:write("t\t" .. key .. "\t" .. s .. "\n") end
    end
    f:close()
  end

  local out = cover(meta)

  -- 4. table of contents: each heading of level 1 to 4 with its page
  table.insert(out, raw(para("Heading1", run("TABLE OF CONTENTS"), { pageBreak = true })))
  table.insert(out, raw(para("Normal", run("Page", { bold = true }), { spacing = EXACT_DOUBLE, jc = '<w:jc w:val="right"/>' })))
  for _, h in ipairs(headings) do
    if h.level <= 4 then
      local page = pm.h[h.seq] or "0"
      local ind = (h.level - 2) * 720
      local o = { spacing = EXACT_DOUBLE }
      local runs
      if h.level == 1 then
        runs = run(string.upper(h.title)) .. TABXML .. run(page)
        o.tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/></w:tabs>'
      else
        runs = run(h.label) .. TABXML .. run(h.title) .. TABXML .. run(page)
        o.tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + 720) .. '"/><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/></w:tabs>'
        o.ind = '<w:ind w:left="' .. (ind + 720) .. '" w:hanging="720"/>'
      end
      table.insert(out, raw(para("Normal", runs, o)))
    end
  end

  -- 5. table of authorities: the authorities the memorandum links to, by kind, with their pages
  table.insert(out, raw(para("Heading1", run("TABLE OF AUTHORITIES"), { pageBreak = true })))
  table.insert(out, raw(para("Normal", run("Page(s)", { bold = true }), { spacing = EXACT_DOUBLE, jc = '<w:jc w:val="right"/>' })))
  local members = {}
  for _, key in ipairs(hit_order) do
    local a = meta.authorities[key]
    table.insert(members, { key = key, kind = str(a.kind), name = a.name and str(a.name) or nil, cite = str(a.cite) })
  end
  for _, g in ipairs(KINDS) do
    local group = {}
    for _, m in ipairs(members) do if m.kind == g[1] then table.insert(group, m) end end
    if #group > 0 then
      table.sort(group, function(x, y) return string.lower(x.name or x.cite) < string.lower(y.name or y.cite) end)
      table.insert(out, raw(para("Normal", run(g[2], { bold = true }), { keepNext = true, spacing = EXACT_DOUBLE })))
      for _, m in ipairs(group) do
        local pages = pm.t[m.key] or "0"
        local count = 0
        for _ in pages:gmatch("[^,]+") do count = count + 1 end
        local shown = count >= PASSIM_AT and run("passim", { italic = true }) or run(pages)
        local name_runs = ""
        if m.name then name_runs = run(m.name, { italic = (m.kind == "case") }) .. run(", ") end
        table.insert(out, raw(para("Normal", name_runs .. run(m.cite) .. TABXML .. shown, {
          keepLines = true,
          tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXT_W .. '"/></w:tabs>',
          spacing = EXACT_DOUBLE,
          ind = '<w:ind w:left="504" w:hanging="504"/>',
        })))
      end
    end
  end

  -- 6. the body: the memorandum's headings and lists, the signature after the last paragraph
  table.insert(out, raw('<w:p><w:pPr><w:pStyle w:val="Normal"/><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p>'))
  local blocks = {}
  local hi = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      hi = hi + 1
      if b.level == 1 then
        table.insert(blocks, b)
      else
        local inl = { pandoc.Str(headings[hi].label), TAB }
        for _, x in ipairs(b.content) do table.insert(inl, x) end
        table.insert(blocks, pandoc.Header(b.level, inl, b.attr))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local label = "(" .. string.char(string.byte("a") + k - 1) .. ")"
        for _, ib in ipairs(item) do
          if ib.t == "Plain" or ib.t == "Para" then
            local inl = { pandoc.Str(label), TAB }
            for _, x in ipairs(ib.content) do table.insert(inl, x) end
            table.insert(blocks, pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Item" }))
          else
            table.insert(blocks, ib)
          end
        end
      end
    else
      table.insert(blocks, b)
    end
  end
  for i = #blocks, 1, -1 do
    if blocks[i].t == "Para" then
      blocks[i] = pandoc.Div({ blocks[i] }, { ["custom-style"] = "Body Keep" })
      break
    end
  end
  for _, b in ipairs(blocks) do table.insert(out, b) end
  table.insert(out, signature(meta))
  return pandoc.Pandoc(out, {})
end
