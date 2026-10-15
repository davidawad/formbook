-- nysupct memorandum of law on a motion, DOCX engine (docs/DOCX.md). The markdown contract (../README.md) becomes
-- a Word document on docx/reference.docx, laid out as typst/nysupct-motion-brief.typ: an unnumbered cover (caption,
-- title, counsel block), the table of contents and table of authorities (lower-case roman), the body (markdown,
-- arabic from 1) with the signature block and service list, and the word-count certificate on its own page.
-- Every value comes from the sample's YAML frontmatter. No case-specific text lives here.
-- Known limits (BLOCKED, README "Engines"): TOC entries and TOA entries carry no page numbers until a field
-- update (LibreOffice does not honour TA/TOA fields); the word count is the filter's count, not Word's.

-- ---------------------------------------------------------------------------
-- Inline runs and paragraphs (WordprocessingML written as raw OpenXML)
-- ---------------------------------------------------------------------------

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, f)
  f = f or {}
  local rpr = ""
  if f.b then rpr = rpr .. "<w:b/>" end
  if f.i then rpr = rpr .. "<w:i/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function runs(inlines, f)
  f = f or {}
  local out = {}
  for _, e in ipairs(inlines) do
    local t = e.t
    if t == "Str" then
      out[#out + 1] = run(e.text, f)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "Strong" or t == "Emph" then
      out[#out + 1] = runs(e.content, { b = f.b or t == "Strong", i = f.i or t == "Emph" })
    elseif t == "Quoted" then
      local q = (e.quotetype == "DoubleQuote") and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], f) .. runs(e.content, f) .. run(q[2], f)
    elseif e.content then
      out[#out + 1] = runs(e.content, f)
    elseif e.text then
      out[#out + 1] = run(e.text, f)
    end
  end
  return table.concat(out)
end

-- o: style, inls | text | raw, f (flags), keepNext, pageBreakBefore, rule, before, after, left, right, hanging, jc
local function para(o)
  local p = {}
  if o.style then p[#p + 1] = '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keepNext then p[#p + 1] = "<w:keepNext/>" end
  if o.pageBreakBefore then p[#p + 1] = "<w:pageBreakBefore/>" end
  if o.rule then p[#p + 1] = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>' end
  if o.before or o.after then
    p[#p + 1] = "<w:spacing"
      .. (o.before and (' w:before="' .. o.before .. '"') or "")
      .. (o.after and (' w:after="' .. o.after .. '"') or "") .. "/>"
  end
  if o.left or o.right or o.hanging then
    p[#p + 1] = "<w:ind" .. (o.left and (' w:left="' .. o.left .. '"') or "")
      .. (o.right and (' w:right="' .. o.right .. '"') or "")
      .. (o.hanging and (' w:hanging="' .. o.hanging .. '"') or "") .. "/>"
  end
  if o.jc then p[#p + 1] = '<w:jc w:val="' .. o.jc .. '"/>' end
  local ppr = (#p > 0) and ("<w:pPr>" .. table.concat(p) .. "</w:pPr>") or ""
  local body = o.raw or (o.inls and runs(o.inls, o.f)) or (o.text and run(o.text, o.f)) or ""
  return "<w:p>" .. ppr .. body .. "</w:p>"
end

local function R(xml) return pandoc.RawBlock("openxml", xml) end

-- Borderless table, one row. cells: {w = twips, paras = xml, top/bottom/right = border, mar_left = twips}.
local function table_row(cells)
  local total, tcs, grid = 0, {}, {}
  for _, c in ipairs(cells) do
    total = total + c.w
    grid[#grid + 1] = '<w:gridCol w:w="' .. c.w .. '"/>'
    local b = {}
    if c.top then b[#b + 1] = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
    if c.bottom then b[#b + 1] = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
    if c.right then b[#b + 1] = '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
    local tcpr = '<w:tcW w:w="' .. c.w .. '" w:type="dxa"/>'
    if #b > 0 then tcpr = tcpr .. "<w:tcBorders>" .. table.concat(b) .. "</w:tcBorders>" end
    if c.mar_left then tcpr = tcpr .. '<w:tcMar><w:left w:w="' .. c.mar_left .. '" w:type="dxa"/></w:tcMar>' end
    tcs[#tcs + 1] = "<w:tc><w:tcPr>" .. tcpr .. "</w:tcPr>" .. c.paras .. "</w:tc>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. "<w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid><w:tr>" .. table.concat(tcs) .. "</w:tr></w:tbl>"
end

-- Section break (the paragraph that closes a section). fmt nil: the cover, with no footer.
local PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="720" w:gutter="0"/>'
local function section_break(fmt)
  local ref = fmt and '<w:footerReference w:type="default" r:id="rIdFtr1"/>' or ""
  local num = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:p><w:pPr><w:sectPr>' .. ref .. PG .. num .. "</w:sectPr></w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Metadata readers (pandoc 3.12: scalars are lists of inlines; lists are lists of those)
-- ---------------------------------------------------------------------------

local function inls(v)
  local out = {}
  if v == nil then return out end
  if type(v) ~= "table" and type(v) ~= "userdata" then
    out[1] = { t = "Str", text = tostring(v) }
    return out
  end
  for _, e in ipairs(v) do
    if e.t == "Para" or e.t == "Plain" then
      for _, x in ipairs(e.content) do out[#out + 1] = x end
    elseif e.t then
      out[#out + 1] = e
    else
      for _, x in ipairs(inls(e)) do out[#out + 1] = x end
    end
  end
  return out
end

-- A list of lines: one inline list per item.
local function items(v)
  local out = {}
  if v == nil then return out end
  if type(v) ~= "table" and type(v) ~= "userdata" then
    out[1] = inls(v)
    return out
  end
  for _, e in ipairs(v) do out[#out + 1] = inls(e) end
  return out
end

-- Plain text of a metadata value (for sorting and checks).
local function plain_of(v)
  local s = {}
  for _, e in ipairs(inls(v)) do s[#s + 1] = pandoc.utils.stringify(e) end
  return table.concat(s)
end

local function para_lines(list, o)
  local x = {}
  for _, line in ipairs(list) do
    local p = {}
    for k, v in pairs(o) do p[k] = v end
    p.inls = line
    x[#x + 1] = para(p)
  end
  return table.concat(x)
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

local TEXT_W = 9360          -- 6.5 in
local CAPTION_BOX = 5184     -- 3.6 in
local GAP = 288              -- 0.2 in
local HALF = 4680            -- 3.25 in

local function caption(m)
  local box = {}
  for i, g in ipairs(m.parties) do
    if i > 1 then box[#box + 1] = para{ style = "Centered", text = "-against-", f = { i = true }, before = 240, after = 240 } end
    box[#box + 1] = para_lines(items(g.names), { style = "Single", left = GAP, right = GAP, after = 120 })
    box[#box + 1] = para{ style = "Single", inls = inls(g.designation), jc = "right", right = GAP, before = 60, after = 120 }
  end
  local right = para{ style = "Single", inls = inls(m.index_no) }
  if m.judge then right = right .. para{ style = "Single", inls = inls(m.judge), before = 120 } end
  if m.motion_seq then right = right .. para{ style = "Single", inls = inls(m.motion_seq), before = 120 } end
  return para{ style = "Centered", text = "SUPREME COURT OF THE STATE OF NEW YORK", f = { b = true } }
    .. para{ style = "Single", inls = inls(m.county), f = { b = true }, before = 240, after = 240 }
    .. table_row{
      { w = CAPTION_BOX, paras = table.concat(box), top = true, bottom = true, right = true },
      { w = TEXT_W - CAPTION_BOX, paras = right, mar_left = GAP },
    }
    .. para{ style = "Single", after = 240 }
end

-- Cover: caption, the title centred, and the counsel block at the foot of the page (approximate spacing).
local function cover(m)
  local c = m.counsel
  local foot = para_lines(items(c.names), { style = "Single" })
    .. para_lines(items(c.lines), { style = "Single", before = 120 })
  if c.on_brief then
    foot = foot .. para{ style = "Single", text = "On the Memorandum of Law:", before = 240 }
      .. para_lines(items(c.on_brief), { style = "Single" })
  end
  return caption(m)
    .. para{ style = "Centered", inls = inls(m.title), f = { b = true }, before = 2304, after = 0 }
    .. para{ style = "Single", text = "", before = 2880 }
    .. foot
end

local function headings(blocks, maxlevel)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= maxlevel then
      out[#out + 1] = { level = b.level, text = pandoc.utils.stringify(b.content) }
    end
  end
  return out
end

-- TOC field (TOC \o "1-N" \h \z \u) whose cached result is the heading list; page numbers need a field update.
local function toc_field(hs, depth)
  if #hs == 0 then return "" end
  local out = {}
  for i, h in ipairs(hs) do
    local pre, post = "", ""
    if i == 1 then
      pre = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-'
        .. depth .. '" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    if i == #hs then post = '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="TOC' .. h.level .. '"/></w:pPr>' .. pre .. run(h.text) .. post .. "</w:p>"
  end
  return table.concat(out)
end

local TOA_GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

local function sort_key(a)
  local s = plain_of(a.sort or ((a.name and plain_of(a.name) or "") .. " " .. plain_of(a.cite)))
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

-- Table of authorities: the authorities linked from the body (toa:KEY), grouped as in the exemplar.
-- Page numbers are not printed (BLOCKED: TA/TOA fields are not honoured by LibreOffice).
local function toa_section(m, used)
  for key in pairs(used) do
    if m.authorities[key] == nil then
      error("nysupct-motion-brief: link toa:" .. key .. " has no entry under authorities:")
    end
  end
  local x = {
    para{ style = "Centered", text = "TABLE OF AUTHORITIES", f = { b = true }, after = 240 },
    para{ style = "Single", text = "Page(s)", jc = "right", after = 240 },
  }
  for _, grp in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(m.authorities) do
      if used[key] and plain_of(a.kind) == grp[1] then members[#members + 1] = { key = key, a = a } end
    end
    if #members > 0 then
      table.sort(members, function(p, q) return sort_key(p.a) < sort_key(q.a) end)
      x[#x + 1] = para{ style = "Single", text = grp[2], f = { b = true }, before = 240, after = 120, keepNext = true }
      for _, e in ipairs(members) do
        local is_case = plain_of(e.a.kind) == "case"
        local body = ""
        if e.a.name then body = runs(inls(e.a.name), { i = is_case }) .. run(", ") end
        body = body .. runs(inls(e.a.cite))
        x[#x + 1] = para{ style = "Single", raw = body, left = 504, hanging = 504, after = 120 }
      end
    end
  end
  return table.concat(x)
end

local function signature(m)
  local sig = m.signature
  local dated
  if m.place then
    dated = para{ style = "Single", text = "Dated:" } .. para{ style = "Single", inls = inls(m.place) }
      .. para{ style = "Single", inls = inls(m.date) }
  else
    dated = para{ style = "Single", raw = run("Dated: ") .. runs(inls(m.date)) }
  end
  local right = para{ style = "Single", text = "Respectfully submitted,", before = 240 }
    .. para_lines(items(sig.firm), { style = "Single", before = 240 })
    .. para{ style = "Single", text = "By:", rule = true, before = 480, right = 1080 }
    .. para{ style = "Single", inls = inls(sig.signer), before = 60 }
    .. para_lines(items(sig.lines), { style = "Single" })
  return para{ style = "Single", after = 0, before = 240 }
    .. table_row{ { w = HALF, paras = dated }, { w = HALF, paras = right } }
end

local function service(m)
  if m.to == nil then return "" end
  local x = { para{ style = "Single", text = "TO:", before = 480 } }
  for _, g in ipairs(m.to) do
    x[#x + 1] = para_lines(items(g.names), { style = "Single", before = 240 })
    x[#x + 1] = para_lines(items(g.lines), { style = "Single", f = { i = true } })
  end
  return table.concat(x)
end

-- Digits in groups of three (the certificate's count).
local function group_digits(n)
  local s = tostring(n)
  local r = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  r = r:gsub("^,", "")
  return r
end

local function certificate(m, words, filing)
  local clause = (filing == "reply") and "202.8-b(a)(ii)" or "202.8-b(a)(i)"
  local text = "I hereby certify pursuant to 22 NYCRR 202.8-b(c) that the total number of words in the foregoing "
    .. "memorandum of law, exclusive of the caption, table of contents, table of authorities, and signature block, is "
    .. group_digits(words) .. ", according to the word count of the document as prepared, and thus that the document "
    .. "complies with the word count limit set forth in 22 NYCRR " .. clause .. "."
  local dated = para{ style = "Single", text = "Dated: " .. plain_of(m.place) .. ", " .. plain_of(m.date) }
  local sig_right = para{ style = "Single", text = "", rule = true, before = 720, right = 1080 }
    .. para{ style = "Single", inls = inls(m.signature.signer), before = 60 }
  return para{ style = "Centered", text = "CERTIFICATION OF COMPLIANCE WITH WORD COUNT LIMIT", f = { b = true },
      pageBreakBefore = true, after = 240 }
    .. para{ style = "BodyText", raw = run(text) }
    .. para{ style = "Single", after = 0, before = 240 }
    .. table_row{ { w = HALF, paras = dated }, { w = HALF, paras = sig_right } }
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local filing = m.filing and plain_of(m.filing) or "in-chief"
  if filing ~= "in-chief" and filing ~= "reply" then
    error("nysupct-motion-brief: `filing` must be `in-chief` or `reply`, not `" .. filing .. "`")
  end
  local limit = (filing == "reply") and 4200 or 7000

  -- Links to toa:KEY are the authority hits: they print as their text.
  local used = {}
  local d = pandoc.Pandoc(doc.blocks):walk{
    Link = function(l)
      if l.target:sub(1, 4) == "toa:" then
        used[l.target:sub(5)] = true
        return l.content
      end
    end,
  }
  local blocks = d.blocks

  -- Word count (22 NYCRR 202.8-b(c)): the body and its footnotes, without caption, TOC, TOA and signature.
  local words = 0
  local function count(s) for _ in s:gmatch("%S+") do words = words + 1 end end
  local bare = pandoc.Pandoc(blocks):walk{
    Note = function(note)
      count(pandoc.utils.stringify(note.content))
      return {}
    end,
  }
  count(pandoc.utils.stringify(bare.blocks))
  if words > limit then
    error("nysupct-motion-brief: " .. words .. " words exceeds the 22 NYCRR 202.8-b(a) limit of " .. limit)
  end

  local out = { R(cover(m) .. section_break(nil)) }
  local front = ""
  if m.toc ~= false then
    front = para{ style = "Centered", text = "TABLE OF CONTENTS", f = { b = true }, after = 240 }
      .. para{ style = "Single", text = "Page", jc = "right", after = 240 }
      .. toc_field(headings(blocks, 4), 4)
      .. '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
  end
  out[#out + 1] = R(front .. toa_section(m, used) .. section_break("lowerRoman"))
  for _, b in ipairs(blocks) do out[#out + 1] = b end
  out[#out + 1] = R(signature(m) .. service(m))
  out[#out + 1] = R(certificate(m, words, filing))
  doc.blocks = out
  -- pandoc would print title and date above the body; the cover and certificate carry them instead
  doc.meta.title = nil
  doc.meta.date = nil
  return doc
end
