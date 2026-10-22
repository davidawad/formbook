-- Complaint for the D.N.H. (nhd), docx engine: what the Word output adds to pandoc's conversion, so that it reads and
-- breaks as typst/nhd-complaint.typ does: the court title, the caption (LR 5.1(c), Fed. R. Civ. P. 10(a)), the
-- title, the numbered paragraphs (Fed. R. Civ. P. 10(b)), the lettered items, the "~ " (unnumbered) paragraphs, the
-- headings and the signature block (LR 5.1(b)). Everything printed comes from the sample's frontmatter and body: no
-- case text lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_TAB = 1440                  -- typst para-indent + number-box: the text of a numbered paragraph
local ITEM = 1584                        -- typst item-indent + item-box: the text of a lettered item, 1.1 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 432   -- typst caption-left 3.4 in, caption-gutter 0.3 in
local CASE_DROP = 2 * SINGLE             -- typst case-drop
local SIG = 4680                         -- typst sig-indent 3.25 in

local stringify = pandoc.utils.stringify

local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Plain text lines (the caption and signature fields carry no markdown, as in the typst template).
local function plain(v) return xe.runs(stringify(v)) end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center", keep = true })
  out[#out + 1] = p(xe.runs("FOR THE DISTRICT OF NEW HAMPSHIRE", { b = true }), { jc = "center", keep = true })
  -- Left cell: party names and designations, one per line, "v." between the parties; right cell: the case number
  -- two single lines down (typst case-drop) and the jury demand. The caption stands a single line below the court
  -- title (typst: the caption block's above): the first paragraph of each cell carries it.
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(plain(n), { before = #left == 0 and SINGLE or 0 }) end
    left[#left + 1] = p(plain(party.designation), { before = #left == 0 and SINGLE or 0 })
  end
  local right = { p(plain(meta.case_number), { before = SINGLE + CASE_DROP }) }
  if meta.jury_demand then right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true })) end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER },
    { { body = left }, { body = { p("", { before = SINGLE }) } }, { body = right } })
  -- the title a single line below the caption (Word has no space after a table: the title takes it)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(stringify(meta.title)), { b = true }),
    { line = BODY, before = SINGLE, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature (LR 5.1(b)): groups of single lines at the right half of the page, a blank single line between them, a
-- blank double line above; the block never breaks across a page: plain paragraphs kept together (keep-with-next),
-- not a table, so that the space above it is dropped when it opens a page, as typst drops it
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local s = meta.signature
  if not s then error("nhd-complaint: the sample needs a signature block (LR 5.1(b))", 0) end
  local groups = { { s.intro } }
  if s.party then groups[#groups + 1] = s.party end
  if s.date then groups[#groups + 1] = { s.date } end
  groups[#groups + 1] = { "/s/ " .. stringify(s.signer) }
  for _, b in ipairs(s.blocks or {}) do groups[#groups + 1] = b end
  for i, g in ipairs(groups) do
    for j, l in ipairs(g) do
      local before = 0
      if j == 1 then before = i == 1 and BODY or SINGLE end
      local last = i == #groups and j == #g
      out[#out + 1] = p(type(l) == "string" and xe.runs(l) or plain(l), { before = before, left = SIG, keep = not last })
    end
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el)
  local content = el.level == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

local function body(blocks, out)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      local first = b.content[1]
      if first and first.t == "Str" and first.text == "~" then
        -- "~ " paragraph: unnumbered (WHEREFORE, the jury demand); drop the marker and the space after it
        local rest = pandoc.Inlines({})
        for i = 2, #b.content do rest:insert(b.content[i]) end
        if rest[1] and rest[1].t == "Space" then rest:remove(1) end
        out[#out + 1] = p(xe.inl(rest), { line = BODY, first = INDENT })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = NUMBER_TAB })
      end
    elseif b.t == "OrderedList" then
      -- lettered items (a), (b), ... (typst enum "(a)"): the letter half an inch in, the text 1.1 in, hanging
      local start = b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ("(" .. string.char(96 + start + j - 1) .. ")\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = BODY, left = ITEM, hanging = ITEM - INDENT })
        end
      end
    else
      error("nhd-complaint: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 2201"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local t = a.text
      if #t >= 4 and t:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
        inlines[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return inlines
end

function Pandoc(doc)
  for _, k in ipairs({ "caption", "case_number", "title", "signature" }) do
    if doc.meta[k] == nil then error("nhd-complaint: missing required metadata field `" .. k .. "`", 0) end
  end
  local meta = doc.meta
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local out = {}
  cover(meta, out)
  if doc.meta.lead_in then out[#out + 1] = p(xe.inl(doc.meta.lead_in), { line = BODY, first = INDENT }) end
  body(doc.blocks, out)
  signature(meta, out)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  -- empty metadata: pandoc would otherwise write the frontmatter title as a Title paragraph
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
