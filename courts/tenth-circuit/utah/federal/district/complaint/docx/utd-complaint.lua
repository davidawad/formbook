-- D. Utah complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it reads and breaks as
-- typst/utd-complaint.typ does: the counsel block (DUCivR 10-1(6)(A)), the court title, the caption (party column
-- closed by a rule on its right and below; the title, "JURY DEMANDED" (DUCivR 10-1(7)), the case number and the
-- judge at the right; DUCivR 10-1(6)(B)), the lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, the
-- prayer list and the signature block (DUCivR 10-1(8)). Every case-specific word comes from the sample's frontmatter
-- (read as written, $FORMBOOK_META) and body, never from this file. Font, margins and the page number are in
-- docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines number the same paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst gap: a blank double line
local HEADING_ABOVE = 240                -- typst heading-above, 12 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LABEL = 1440                       -- typst para-indent + number-box: the text after a number or list label, 1 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAD = 5760, 216      -- typst caption-left 4 in, caption-pad 0.15 in
local CAP_BELOW = 261                    -- typst: a single line below the party column, less the 0.75 pt bottom rule LibreOffice adds to the row
local DESIG = 1800                       -- typst designation-indent 1.25 in
local SIG = 4680                         -- typst sig-left, 3.25 in

local function read_file(path)
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function fail(msg) error("utd-complaint: " .. msg, 0) end

local function need(key)
  if RAW[key] == nil then fail("missing required metadata field `" .. key .. "`") end
  return RAW[key]
end

local function list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 1331"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(3)" or "A." lists).
local function md(s)
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return bind_doubled(pandoc.Inlines(pandoc.utils.blocks_to_inlines(doc.blocks)):walk({ Str = breaks }))
end

local function upper(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab, pre }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.pre then props[#props + 1] = o.pre end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Single-spaced lines (typst line-stack): each item { xml, o } or "" (a blank single line). keep: every line kept
-- with the next. A cell needs a paragraph even when it holds no line.
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for k, l in ipairs(lines) do
    if l == "" then
      gap = gap + SINGLE
    else
      local po = {}
      for key, v in pairs(l.o or {}) do po[key] = v end
      po.before = gap
      po.left = (po.left or 0) + (o.left or 0)
      if o.keep and k < #lines then po.keep = true end
      out[#out + 1] = p(l.xml, po)
      gap = 0
    end
  end
  if #out == 0 then out[1] = p("") end
  return table.concat(out)
end

local function line(xml, o) return { xml = xml, o = o } end

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, caption
-- ---------------------------------------------------------------------------

local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i][2] or "") .. '</w:tcPr>'
      .. cells[i][1] .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function cover(out)
  local counsel = {}
  for _, l in ipairs(list(need("counsel"))) do counsel[#counsel + 1] = line(xe.inl(md(l))) end
  if RAW.counsel_role then counsel[#counsel + 1] = line(xe.inl(md(RAW.counsel_role), { i = true })) end
  out[#out + 1] = stack(counsel)
  local court = {}
  for _, l in ipairs(list(need("court"))) do court[#court + 1] = l end
  if RAW.division then court[#court + 1] = RAW.division end
  local ct = {}
  for _, l in ipairs(court) do ct[#ct + 1] = line(xe.inl(upper(md(l)), { b = true }), { jc = "center" }) end
  out[#out + 1] = stack(ct, { above = GAP })
  -- typst caption: above gap (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = GAP })
  local left = {}
  for k, side in ipairs(list(need("caption"))) do
    if k > 1 then
      left[#left + 1] = ""
      left[#left + 1] = line(xe.runs("v."))
      left[#left + 1] = ""
    end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = line(xe.inl(md(n))) end
    left[#left + 1] = ""
    left[#left + 1] = line(xe.inl(md(side.designation or "")), { left = DESIG })
  end
  local right = { line(xe.inl(upper(md(need("brief_title"))), { b = true })) }
  if RAW.jury_demand == true then right[#right + 1] = line(xe.runs("JURY DEMANDED", { b = true })) end
  right[#right + 1] = ""
  right[#right + 1] = line(xe.runs("Case No. " .. need("case_number")))
  if RAW.judge then
    right[#right + 1] = ""
    right[#right + 1] = line(xe.runs("Judge " .. RAW.judge))
  end
  if RAW.magistrate then right[#right + 1] = line(xe.runs("Magistrate Judge " .. RAW.magistrate)) end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  out[#out + 1] = table_xml({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { stack(left), rule .. '<w:tcMar><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD
      .. '" w:type="dxa"/></w:tcMar>' },
    { stack(right), '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>' },
  })
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's document loop
-- ---------------------------------------------------------------------------

-- The sample's body: the text after its frontmatter, split at blank lines.
local function chunks()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out
end

local function is_list(t)
  return t ~= nil and (t:match("^%- ") ~= nil or t:match("^%d+%. ") ~= nil)
end

-- One chunk (typst: chunk()); above: the space above a heading, keep: kept with the next block.
local function chunk(t, num, above, keep, out)
  local hashes, htext = t:match("^(#+) (.*)$")
  if hashes and #hashes <= 3 then
    -- a heading on the body pitch, bold, kept with the text after it; levels 1 and 2 centered, level 1 in capitals
    local inl = md(htext)
    if #hashes == 1 then inl = upper(inl) end
    out[#out + 1] = p(xe.inl(inl, { b = true }), { before = above, line = BODY,
      jc = #hashes == 3 and "left" or "center", keep = true })
  elseif is_list(t) then
    -- a list: each item's number as written (a bullet as "•") at the indent, its lines hanging at 1 in
    local items = {}
    for l in (t .. "\n"):gmatch("(.-)\n") do
      local mark, rest = l:match("^(%d+%.)[ \t]+(.*)$")
      if not mark and l:match("^%-[ \t]") then mark, rest = "\u{2022}", l:match("^%-[ \t]+(.*)$") end
      if mark then items[#items + 1] = { mark, rest } else items[#items][2] = items[#items][2] .. "\n" .. l end
    end
    for k, it in ipairs(items) do
      out[#out + 1] = p(xe.runs(it[1] .. "\t") .. xe.inl(md(it[2])), { line = BODY, left = LABEL,
        hanging = LABEL - INDENT, tab = LABEL, keep = keep and k == #items })
    end
  elseif num then
    out[#out + 1] = p(xe.runs(num .. ".\t") .. xe.inl(md(t)), { line = BODY, first = INDENT, tab = LABEL, keep = keep })
  else
    out[#out + 1] = p(xe.inl(md(t)), { line = BODY, first = INDENT, keep = keep })
  end
end

local function body(out)
  -- the lead-in, a blank double line under the caption; unnumbered
  if RAW.lead_in then
    out[#out + 1] = p(xe.inl(md(RAW.lead_in)), { before = GAP, line = BODY, first = INDENT })
  else
    out[#out + 1] = p("", { line = GAP })
  end
  local cs = chunks()
  local unnumbered, n = false, 0
  for i, t in ipairs(cs) do
    local head = t:sub(1, 1) == "#"
    if head then
      local l = t:lower()
      unnumbered = l:find("prayer", 1, true) ~= nil or l:find("jury demand", 1, true) ~= nil
    end
    local para = not head and not is_list(t) and not unnumbered and not is_list(cs[i + 1])
    if para then n = n + 1 end
    local above = (head and i > 1 and cs[i - 1]:sub(1, 1) ~= "#") and HEADING_ABOVE or 0
    -- the last chunk is kept with the signature (a signature never stands alone on a page)
    chunk(t, para and n or nil, above, i == #cs, out)
  end
end

-- ---------------------------------------------------------------------------
-- Signature block: the date, then the signer's lines from 3.25 in, kept on one page
-- ---------------------------------------------------------------------------

local function signature(out)
  local sig = need("signature")
  out[#out + 1] = p(xe.runs("DATED this " .. need("date") .. "."), { before = GAP, keep = true })
  local lines = { line(xe.runs("Respectfully submitted,")), "" }
  for _, l in ipairs(list(sig.firm)) do lines[#lines + 1] = line(xe.inl(md(l))) end
  lines[#lines + 1] = ""
  lines[#lines + 1] = line(xe.runs("By: /s/ " .. (sig.signer or "")))
  lines[#lines + 1] = line(xe.runs(sig.signer or ""))
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = line(xe.inl(md(l))) end
  out[#out + 1] = stack(lines, { above = SINGLE, left = SIG, keep = true })
end

function Pandoc(doc)
  for _, k in ipairs({ "case_number", "court", "caption", "counsel", "brief_title", "signature", "date" }) do need(k) end
  local out = {}
  cover(out)
  body(out)
  signature(out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
