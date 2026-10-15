-- nysupct verified complaint, DOCX engine (docs/DOCX.md). The markdown contract (../README.md) becomes a Word
-- document on docx/reference.docx, laid out as typst/nysupct-complaint.typ: the caption (a borderless table with
-- a bordered party box), the table of contents (a TOC field whose cached entries are the headings), the body
-- (markdown), the signature block, the service list, and the verification on its own page.
-- Every value comes from the sample's YAML frontmatter. No case-specific text and no forced layout beyond
-- the page break before the verification and after the table of contents.
-- Known limits (BLOCKED, README "Engines"): TOC entries carry no page numbers until a field update.

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

-- o: style, inls | text | raw, f (flags), keepNext, pageBreakBefore, rule, before, after, left, right, jc
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
  if o.left or o.right then
    p[#p + 1] = "<w:ind" .. (o.left and (' w:left="' .. o.left .. '"') or "")
      .. (o.right and (' w:right="' .. o.right .. '"') or "") .. "/>"
  end
  if o.jc then p[#p + 1] = '<w:jc w:val="' .. o.jc .. '"/>' end
  local ppr = (#p > 0) and ("<w:pPr>" .. table.concat(p) .. "</w:pPr>") or ""
  local body = o.raw or (o.inls and runs(o.inls, o.f)) or (o.text and run(o.text, o.f)) or ""
  return "<w:p>" .. ppr .. body .. "</w:p>"
end

local function R(xml) return pandoc.RawBlock("openxml", xml) end

-- Borderless table, one row. widths in twips; cells are {width, paragraphs, borders, left-margin}.
local function table_row(cells)
  local widths, total, tcs, grid = {}, 0, {}, {}
  for _, c in ipairs(cells) do
    total = total + c.w
    grid[#grid + 1] = '<w:gridCol w:w="' .. c.w .. '"/>'
    local b = {}
    if c.top then b[#b + 1] = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
    if c.bottom then b[#b + 1] = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
    if c.right then b[#b + 1] = '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
    local tcpr = '<w:tcW w:w="' .. c.w .. '" w:type="dxa"/>'
    if #b > 0 then tcpr = tcpr .. "<w:tcBorders>" .. table.concat(b) .. "</w:tcBorders>" end
    if c.mar_left then
      tcpr = tcpr .. '<w:tcMar><w:left w:w="' .. c.mar_left .. '" w:type="dxa"/></w:tcMar>'
    end
    tcs[#tcs + 1] = "<w:tc><w:tcPr>" .. tcpr .. "</w:tcPr>" .. c.paras .. "</w:tc>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. "<w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid><w:tr>" .. table.concat(tcs) .. "</w:tr></w:tbl>"
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
-- Blocks: caption, table of contents, signature, service list, verification
-- ---------------------------------------------------------------------------

local TEXT_W = 9360          -- 6.5 in
local CAPTION_BOX = 5184     -- 3.6 in
local GAP = 288              -- 0.2 in

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
  right = right .. para{ style = "Single", inls = inls(m.title), f = { b = true }, before = 480 }
  return para{ style = "Centered", text = "SUPREME COURT OF THE STATE OF NEW YORK", f = { b = true } }
    .. para{ style = "Single", inls = inls(m.county), f = { b = true }, before = 240, after = 240 }
    .. table_row{
      { w = CAPTION_BOX, paras = table.concat(box), top = true, bottom = true, right = true },
      { w = TEXT_W - CAPTION_BOX, paras = right, mar_left = GAP },
    }
    .. para{ style = "Single", after = 240 }
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
    .. para_lines(items(sig.lines), { style = "Single", f = { i = true } })
  return para{ style = "Single", after = 0, before = 240 }
    .. table_row{
      { w = TEXT_W // 2, paras = dated },
      { w = TEXT_W // 2, paras = right },
    }
end

local function service(m)
  if m.to == nil then return "" end
  local x = { para{ style = "Single", text = "To:", before = 480 } }
  for _, g in ipairs(m.to) do
    x[#x + 1] = para_lines(items(g.names), { style = "Single", before = 240 })
    x[#x + 1] = para_lines(items(g.lines), { style = "Single", f = { i = true } })
  end
  return table.concat(x)
end

local function verification(m)
  local v = m.verification
  local text = runs(inls(v.verifier)) .. run(", ") .. runs(inls(v.capacity))
    .. run(", affirms under the penalties of perjury under the laws of New York, which may include a fine or imprisonment, "
      .. "that the foregoing ") .. runs(inls(m.title))
    .. run(" is true to the knowledge of the affirmant, except as to matters alleged on information and belief, "
      .. "and as to those matters the affirmant believes them to be true. The affirmant understands that this document "
      .. "may be filed in an action or proceeding in a court of law.")
  local sig_right = para{ style = "Single", text = "", rule = true, before = 720, right = 1080 }
    .. para{ style = "Single", inls = inls(v.verifier), before = 60 }
  return para{ style = "Centered", text = "VERIFICATION", f = { b = true }, pageBreakBefore = true, after = 240 }
    .. para{ style = "BodyText", raw = text }
    .. para{ style = "Single", after = 0, before = 240 }
    .. table_row{
      { w = TEXT_W // 2, paras = para{ style = "Single", raw = run("Dated: ") .. runs(inls(m.date)) } },
      { w = TEXT_W // 2, paras = sig_right },
    }
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local out = { R(caption(m)) }
  if m.toc == true then
    out[#out + 1] = R(para{ style = "Centered", text = "TABLE OF CONTENTS", f = { b = true }, after = 240 }
      .. toc_field(headings(doc.blocks, 2), 2)
      .. '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
  end
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  out[#out + 1] = R(signature(m) .. service(m))
  out[#out + 1] = R(verification(m))
  doc.blocks = out
  -- pandoc would print title and date above the body; the caption and verification carry them instead
  doc.meta.title = nil
  doc.meta.date = nil
  return doc
end
