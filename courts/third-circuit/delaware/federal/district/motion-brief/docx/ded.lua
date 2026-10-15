-- D. Del. motion brief (opening brief), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document
-- on reference.docx. The cover, the contents, the table of citations and the signature block of
-- typst/ded-motion-brief.typ are built here (raw WordprocessingML: paragraphs, borderless tables, section
-- breaks). The memorandum keeps its markdown structure; its headings are numbered here (I., II. and A., B.,
-- 1., 2.) as the template numbers them. Content-agnostic: every word comes from the sample.
-- Sections: cover (no footer), contents and citations (lower roman, from i), memorandum (Arabic, from 1).
-- Known limits (BLOCKED in the PR, see the Engines section of ../README.md): the table of contents and the
-- table of citations list the entries without page numbers (a TOC field is updated by Word; pages for the
-- table of citations are not computed by pandoc).

local CFG = {
  pitch = 540,                  -- 27 pt exact: the double spacing of the template
  half = 270,                   -- 13.5 pt: the template's heading and block gap
  cover_left = 4896,            -- 3.4 in, the caption's party column
  cover_gutter = 432,           -- 0.3 in
  cover_right = 4032,
  caption_inset = 173,          -- 0.12 in: right and bottom inset of the party column
  caption_number_indent = 216,  -- 0.15 in before "C.A. No."
  counsel_col = 4464,           -- (6.5 in - 0.3 in) / 2
  sig_left = 4320,              -- 3.0 in, the "Dated" column
  sig_gutter = 288,             -- 0.2 in
  sig_right = 4752,             -- 3.3 in, the signing column
  toa_hang = 504,               -- 0.35 in, the citations' hanging indent
  head_indent = 720,            -- 0.5 in, the level 2 heading label; level 3 text is at 1 in
  toa_group_before = 240,
  page_w = 12240, page_h = 15840, margin = 1440,
  court_lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF DELAWARE" },
}

-- ---------------------------------------------------------------------------
-- WordprocessingML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function rpr(fl)
  local t = ""
  if fl.b then t = t .. "<w:b/><w:bCs/>" end
  if fl.i then t = t .. "<w:i/><w:iCs/>" end
  if fl.caps then t = t .. "<w:caps/>" end
  if t == "" then return "" end
  return "<w:rPr>" .. t .. "</w:rPr>"
end

local function run(text, fl)
  return '<w:r>' .. rpr(fl or {}) .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function with(fl, k)
  local n = {}
  for a, b in pairs(fl or {}) do n[a] = b end
  n[k] = true
  return n
end

-- inline markdown content -> runs (italics and bold kept; links and spans keep their text)
local function runs(inls, fl, out)
  out = out or {}
  fl = fl or {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, fl)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then out[#out + 1] = run(" ", fl)
    elseif t == "Emph" then runs(el.content, with(fl, "i"), out)
    elseif t == "Strong" then runs(el.content, with(fl, "b"), out)
    elseif t == "Span" or t == "Link" then runs(el.content, fl, out)
    elseif t == "Quoted" then
      local q = (el.quotetype == "DoubleQuote") and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], fl)
      runs(el.content, fl, out)
      out[#out + 1] = run(q[2], fl)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), fl)
    end
  end
  return table.concat(out)
end

local function inlines_of(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  return v
end

local function para(ppr, body)
  local p = ppr ~= "" and ("<w:pPr>" .. ppr .. "</w:pPr>") or ""
  return "<w:p>" .. p .. body .. "</w:p>"
end

local function spacer(twips)
  return para('<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/>', "")
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local SINGLE = '<w:pStyle w:val="Single"/>'
local CENTERED = '<w:pStyle w:val="Centered"/>'
local FRONT = '<w:pStyle w:val="FrontHeading"/>'
local PAGE_BREAK = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'

local function pgsz()
  return '<w:pgSz w:w="' .. CFG.page_w .. '" w:h="' .. CFG.page_h .. '"/><w:pgMar w:top="' .. CFG.margin
    .. '" w:right="' .. CFG.margin .. '" w:bottom="' .. CFG.margin .. '" w:left="' .. CFG.margin
    .. '" w:header="720" w:footer="720" w:gutter="0"/>'
end

-- a section break as the last paragraph of a section
local function section_break(footer, numfmt)
  local ref = footer and '<w:footerReference w:type="default" r:id="rId100"/>' or ""
  local num = numfmt and ('<w:pgNumType w:fmt="' .. numfmt .. '" w:start="1"/>') or ""
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:sectPr>'
    .. ref .. pgsz() .. num .. '</w:sectPr></w:pPr></w:p>')
end

-- borderless table with one row; cells: { xml = paragraphs, borders = tcBorders+tcMar xml }
local function row_table(widths, cells)
  local total, grid, tcs = 0, {}, {}
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    local c = cells[i] or { xml = "<w:p/>" }
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (c.borders or "")
      .. '</w:tcPr>' .. c.xml .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

-- ---------------------------------------------------------------------------
-- Cover: court, caption, title, counsel columns, date (LR 7.1.3(a)(1))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  for _, line in ipairs(CFG.court_lines) do
    out[#out + 1] = raw(para(CENTERED, run(line, { b = true })))
  end
  out[#out + 1] = raw(spacer(CFG.pitch))

  local left = {}
  for k, p in ipairs(meta.caption) do
    if k > 1 then left[#left + 1] = para(SINGLE, run("v.")) end
    for _, n in ipairs(p.names) do left[#left + 1] = para(SINGLE, runs(inlines_of(n))) end
    left[#left + 1] = para(SINGLE, runs(inlines_of(p.designation)))
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="' .. CFG.caption_inset .. '" w:type="dxa"/><w:bottom w:w="' .. CFG.caption_inset .. '" w:type="dxa"/></w:tcMar>'
  local number = para(SINGLE .. '<w:spacing w:before="' .. CFG.half .. '" w:after="0" w:line="240" w:lineRule="auto"/>'
    .. '<w:ind w:left="' .. CFG.caption_number_indent .. '" w:firstLine="0"/>',
    run("C.A. No. " .. pandoc.utils.stringify(inlines_of(meta.case_number))))
  out[#out + 1] = raw(row_table({ CFG.cover_left, CFG.cover_gutter, CFG.cover_right },
    { { xml = table.concat(left), borders = rule }, { xml = "<w:p/>" }, { xml = number } }))

  out[#out + 1] = raw(spacer(CFG.pitch))
  out[#out + 1] = raw(para(CENTERED, runs(inlines_of(meta.brief_title), { b = true, caps = true })))
  out[#out + 1] = raw(spacer(CFG.pitch))

  local of = ""
  if meta.of_counsel then
    of = para(SINGLE .. '<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/>', run("OF COUNSEL:"))
    for _, l in ipairs(meta.of_counsel) do of = of .. para(SINGLE, runs(inlines_of(l))) end
  end
  local counsel = ""
  for _, l in ipairs(meta.counsel) do counsel = counsel .. para(SINGLE, runs(inlines_of(l))) end
  out[#out + 1] = raw(row_table({ CFG.counsel_col, CFG.cover_gutter, CFG.counsel_col },
    { { xml = of ~= "" and of or "<w:p/>" }, { xml = "<w:p/>" }, { xml = counsel } }))

  out[#out + 1] = raw(spacer(CFG.pitch))
  out[#out + 1] = raw(para(SINGLE, run("Dated: " .. pandoc.utils.stringify(inlines_of(meta.date)))))
  out[#out + 1] = section_break(false, nil)
  return out
end

-- ---------------------------------------------------------------------------
-- Contents and table of citations (LR 7.1.3(b)(1)(A)-(B))
-- ---------------------------------------------------------------------------

local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

local function toc_entries(heads)
  local out = {}
  if #heads == 0 then
    out[1] = '<w:p>' .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
      .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h </w:instrText></w:r>'
      .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
      .. run("No headings.") .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
    return out
  end
  for i, h in ipairs(heads) do
    local ind = (h.level <= 1) and 0 or ((h.level - 1) * CFG.head_indent)
    local hang = (h.level <= 1) and 0 or CFG.head_indent
    local ppr = SINGLE .. '<w:spacing w:before="0" w:after="200" w:line="240" w:lineRule="auto"/>'
      .. '<w:ind w:left="' .. ind .. '" w:hanging="' .. hang .. '"/>'
    local body = ""
    if i == 1 then
      body = '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
        .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    if h.label ~= "" then body = body .. run(h.label) .. '<w:r><w:tab/></w:r>' end
    body = body .. run(h.text)
    if i == #heads then body = body .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    out[#out + 1] = para(ppr, body)
  end
  return out
end

-- the table of citations: one entry per authority the body links to, grouped and sorted as the template
local function toa_entries(auth, used)
  local out = {}
  for _, g in ipairs(TOA_GROUPS) do
    local keys = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then keys[#keys + 1] = key end
    end
    if #keys > 0 then
      local function sk(k) local a = auth[k]; return (a.name and pandoc.utils.stringify(a.name) or pandoc.utils.stringify(a.cite)):lower() end
      table.sort(keys, function(x, y) return sk(x) < sk(y) end)
      out[#out + 1] = para(SINGLE .. '<w:keepNext/><w:spacing w:before="' .. CFG.toa_group_before .. '" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>',
        run(g[2], { b = true }))
      for _, k in ipairs(keys) do
        local a = auth[k]
        local body = ""
        if a.name then
          body = runs(inlines_of(a.name), (g[1] == "case") and { i = true } or {}) .. run(" ")
        end
        body = body .. runs(inlines_of(a.cite))
        out[#out + 1] = para(SINGLE .. '<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/>'
          .. '<w:ind w:left="' .. CFG.toa_hang .. '" w:hanging="' .. CFG.toa_hang .. '"/>', body)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The memorandum: numbered headings, citations linked to the table, signature block
-- ---------------------------------------------------------------------------

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function signature(meta)
  local sig = meta.signature
  local left = para(SINGLE, run("Dated: " .. pandoc.utils.stringify(inlines_of(meta.date))))
  local right = ""
  for _, l in ipairs(sig.firm or {}) do right = right .. para(SINGLE, runs(inlines_of(l))) end
  right = right .. spacer(CFG.half)
  right = right .. para(SINGLE, run("/s/ " .. pandoc.utils.stringify(inlines_of(sig.signer))))
  for _, l in ipairs(sig.lines or {}) do right = right .. para(SINGLE, runs(inlines_of(l))) end
  return raw(spacer(CFG.pitch) .. row_table({ CFG.sig_left, CFG.sig_gutter, CFG.sig_right },
    { { xml = left }, { xml = "<w:p/>" }, { xml = right } }))
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "brief_title", "counsel", "date", "signature" }) do
    if meta[k] == nil then error("ded: missing required metadata field `" .. k .. "`", 0) end
  end
  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = pandoc.utils.stringify(a.kind), name = a.name, cite = a.cite }
    end
  end

  -- citations: [text](toa:KEY) keeps its text; the key is recorded for the table
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("ded: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter", 0) end
      used[key] = true
      return el.content
    end,
  })

  -- headings: numbered as the template numbers them, and listed in the contents
  -- counters for levels 2, 3 and 4 (a deeper level restarts after a shallower one)
  local counts = { 0, 0, 0 }
  local heads = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level >= 1 and b.level <= 4 then
      local label = ""
      local text = pandoc.utils.stringify(b.content)
      if b.level >= 2 then
        counts[b.level - 1] = counts[b.level - 1] + 1
        for l = b.level, 3 do counts[l] = 0 end
        if b.level == 2 then label = roman(counts[1]):upper() .. "." end
        if b.level == 3 then label = string.char(64 + counts[2]) .. "." end
        if b.level == 4 then label = tostring(counts[3]) .. "." end
        local content = pandoc.List({ pandoc.Str(label), TAB })
        content:extend(b.content)
        b.content = content
      end
      heads[#heads + 1] = { level = b.level, label = label, text = text }
    end
  end

  local out = {}
  local function add(xs) for _, x in ipairs(xs) do out[#out + 1] = x end end

  add(cover(meta))

  -- contents (roman i)
  out[#out + 1] = raw(para(FRONT, run("Table of Contents")))
  out[#out + 1] = raw(para(SINGLE .. '<w:jc w:val="right"/>', run("Page", { b = true })))
  add((function()
    local xs = {}
    for _, x in ipairs(toc_entries(heads)) do xs[#xs + 1] = raw(x) end
    return xs
  end)())
  out[#out + 1] = raw(PAGE_BREAK)

  -- table of citations (roman ii, iii)
  out[#out + 1] = raw(para(FRONT, run("Table of Citations")))
  out[#out + 1] = raw(para(SINGLE .. '<w:jc w:val="right"/>', run("Page(s)", { b = true })))
  for _, x in ipairs(toa_entries(auth, used)) do out[#out + 1] = raw(x) end
  out[#out + 1] = section_break(true, "lowerRoman")

  -- the memorandum (Arabic, from 1)
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  out[#out + 1] = signature(meta)

  doc.blocks = out
  return doc
end
