-- D. Utah motion with its supporting memorandum, docx engine (docs/DOCX.md). The document as Word paragraphs, so that
-- it reads and breaks as typst/utd-motion-brief.typ does: the counsel block (DUCivR 10-1(6)(A)), the court title, the
-- caption (DUCivR 10-1(6)(B)), the motion (DUCivR 7-1(a)(1)(A)), the table of contents and the table of authorities
-- (built from the `toa:` links of the body, as typst builds them), the memorandum from its `# MEMORANDUM OF LAW`
-- heading (DUCivR 7-1(a)(1)(B)) with its heading labels ("I.", "A."), lists and footnotes, and the signature block
-- (DUCivR 10-1(8)). Every case-specific word comes from the sample's frontmatter and body, never from this file. Font,
-- margins, the page number and the paragraph styles are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run. A paragraph that anchors a footnote stays a
-- pandoc paragraph (style Body Text Noted, without widow control: typst may leave its last line alone).
--
-- The tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter
-- writes ($FORMBOOK_NEEDLES: the first line of the cover, the two table titles, each heading, each citation, in
-- document order) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle. The
-- pages are numbered in arabic from the first (DUCivR 10-1(5)).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst gap: a blank double line
local INDENT = 720                       -- typst para-indent 0.5 in
local HANG = 720                         -- typst label-box 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAD = 5400, 216      -- typst caption-left 3.75 in, caption-pad 0.15 in
local CAP_BELOW = 261                    -- typst: a single line below the party column, less the 0.75 pt bottom rule LibreOffice adds to the row
local DESIG = 1800                       -- typst designation-indent 1.25 in
local SIG = 4680                         -- typst sig-left 3.25 in
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-col 0.5 in, toa-col 1 in
local TOA_HANG = 720                     -- typst toa-hang 0.5 in
local TOA_ABOVE = 120                    -- typst toa-above 6 pt
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60
local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Rules" }, { "other", "Other Authorities" } }

-- The section: letter page, top margin 1 1/2 in, the others 1 in (DUCivR 10-1(1)); the page number centered on every
-- page (DUCivR 10-1(5)) in a 13.8 pt line whose box ends 0.5 in above the page edge (typst footer-distance).
local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:jc w:val="center"/>'
  .. '</w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText>'
  .. '</w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/>'
  .. '</w:r></w:p>'
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrUtd"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="2160" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

local function fail(msg) error("utd-motion-brief: " .. msg, 0) end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide. A doubled
-- sign stays with its number ("¶¶ 2,": typst binds it with a box).
local function bind(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    local a = l[i]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function line(xml, o)
  return { xml = xml, o = o }
end

-- Single-spaced lines (typst line-stack): each item a line() or "" (a blank single line: the next line a line lower).
-- A cell needs a paragraph even when it holds no line.
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

-- A one-row table with fixed column widths; cells = { { xml, tcpr } }; the row is not split across pages.
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

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function needle(id, kind, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, _, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
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

-- The citations of a list of inlines, in document order, as needles (B in the body, N in a footnote): the link text
-- and the words after it.
local cites = {}
local scan_blocks
local function scan_inlines(list, in_note)
  for i, el in ipairs(list) do
    if el.t == "Link" and el.target:match("^toa:") then
      local rest = {}
      for j = i + 1, #list do rest[#rest + 1] = list[j] end
      local id = "A:" .. (#cites + 1)
      cites[#cites + 1] = { id = id, key = el.target:sub(5) }
      needle(id, in_note and "N" or "B", stringify(el.content), stringify(rest):sub(1, 40))
    elseif el.t == "Note" then
      scan_blocks(el.content, true)
    elseif el.content and type(el.content) ~= "string" and el.t ~= "Link" then
      scan_inlines(el.content, in_note)
    end
  end
end
scan_blocks = function(blocks, in_note)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      scan_inlines(b.content, in_note)
    elseif b.t == "BlockQuote" then
      scan_blocks(b.content, in_note)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
    end
  end
end

local function has_note(b)
  local found = false
  pandoc.Blocks({ b }):walk({ Note = function() found = true end })
  return found
end

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, caption
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local counsel = {}
  for _, l in ipairs(items(m.counsel)) do counsel[#counsel + 1] = line(xe.inl(l)) end
  counsel[#counsel + 1] = line(xe.inl(m.counsel_role, { i = true }))
  out[#out + 1] = stack(counsel)
  local court = {}
  for _, l in ipairs(items(m.court)) do court[#court + 1] = line(xe.inl(upper(l), { b = true }), { jc = "center" }) end
  out[#out + 1] = stack(court, { above = GAP })
  -- typst caption: above gap (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = GAP })
  local left = {}
  for k, side in ipairs(items(m.caption)) do
    if k > 1 then
      left[#left + 1] = ""
      left[#left + 1] = line(xe.runs("v."))
      left[#left + 1] = ""
    end
    for _, n in ipairs(items(side.names)) do left[#left + 1] = line(xe.inl(n)) end
    left[#left + 1] = ""
    left[#left + 1] = line(xe.inl(side.designation), { left = DESIG })
  end
  local right = { line(xe.runs("Case No. " .. plain(m.case_number))), "", line(xe.inl(upper(m.brief_title), { b = true })) }
  if m.judge then
    right[#right + 1] = ""
    right[#right + 1] = line(xe.runs("Judge " .. plain(m.judge)))
  end
  if m.magistrate then right[#right + 1] = line(xe.runs("Magistrate Judge " .. plain(m.magistrate))) end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  out[#out + 1] = table_xml({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { stack(left), rule .. '<w:tcMar><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD
      .. '" w:type="dxa"/></w:tcMar>' },
    { stack(right), '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>' },
  })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings: level 1 centered bold capitals; level 2 its label at the margin in a half-inch box, its later lines
-- under its text; level 3 the same half an inch in; level 4 an inch in. On the body pitch, kept with the next block.
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

local function heading_label(level, c)
  if level == 2 then return roman(c[2]) .. "." end
  if level == 3 then return string.char(64 + c[3]) .. "." end
  if level == 4 then return tostring(c[4]) .. "." end
  return ""
end

local function heading(level, label, content, pre)
  if level == 1 then
    return p(xe.inl(upper(content), { b = true }), { pre = pre, line = BODY, keep = true, jc = "center" })
  end
  local ind = (level - 2) * HANG
  return p(xe.runs(label .. "\t", { b = true }) .. xe.inl(content, { b = true }), { pre = pre, line = BODY, keep = true,
    left = ind + HANG, hanging = HANG,
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + HANG) .. '"/></w:tabs>' })
end

-- ---------------------------------------------------------------------------
-- The tables (contents and authorities)
-- ---------------------------------------------------------------------------

-- A table's title on the body pitch, a blank double line, and its column label (typst table-head); a new page.
local function table_head(title, col)
  return p(xe.runs(title, { b = true }), { pre = xe.BREAK, line = BODY, after = GAP, keep = true, jc = "center" })
    .. p(xe.runs(col, { b = true }), { keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging, col, before, label_tab)
  local tabs = '<w:tabs>' .. (label_tab and ('<w:tab w:val="left" w:pos="' .. label_tab .. '"/>') or "")
    .. '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = tabs,
    before = before, left = left, hanging = hanging, right = col })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    if e.level <= 3 then
      local page = xe.runs(labels[e.id] or "0")
      if e.level == 1 then
        out[#out + 1] = row(xe.inl(upper(e.title)), page, HANG, HANG, TOC_COL, SINGLE)
      else
        local ind = (e.level - 2) * HANG
        out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), page, ind + HANG, HANG, TOC_COL, SINGLE, ind + HANG)
      end
    end
  end
  return table.concat(out)
end

local function toa(authorities)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)") }
  -- the distinct page labels of each authority, in document order (the page a citation starts on)
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then fail("link `toa:" .. c.key .. "` has no entry under `authorities:` in the frontmatter") end
    pages[c.key] = pages[c.key] or {}
    seen[c.key] = seen[c.key] or {}
    local l = labels[c.id] or "0"
    if not seen[c.key][l] then
      seen[c.key][l] = true
      pages[c.key][#pages[c.key] + 1] = l
    end
  end
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if pages[key] and plain(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = pandoc.text.lower(plain(a.name ~= nil and a.name or a.cite)) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = SINGLE, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        -- the name and citation as typed (typst prints them as plain strings)
        local text
        if a.name ~= nil then
          text = xe.runs(plain(a.name), { i = g[1] == "case" }) .. xe.runs(", " .. plain(a.cite))
        else
          text = xe.runs(plain(a.cite))
        end
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_HANG, TOA_HANG, TOA_COL, TOA_ABOVE)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (DUCivR 10-1(8)): the date at the left; the firm, "/s/", the signer and the lines at the right
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature or {}
  local right = {}
  for _, l in ipairs(items(sig.firm)) do right[#right + 1] = line(xe.inl(l)) end
  right[#right + 1] = ""
  right[#right + 1] = line(xe.runs("/s/ " .. plain(sig.signer)))
  right[#right + 1] = line(xe.inl(sig.signer))
  for _, l in ipairs(items(sig.lines)) do right[#right + 1] = line(xe.inl(l)) end
  -- the blank double line above is the block's own (typst: above gap), kept with the conclusion
  return p("", { line = GAP, keep = true })
    .. table_xml({ SIG, TEXTW - SIG }, { { stack({ line(xe.runs("DATED: " .. plain(m.date))) }) }, { stack(right) } })
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- A body block as Word paragraphs: a paragraph on the body pitch, its first line indented (one with a footnote stays
-- a pandoc paragraph), a list's items with the label half an inch in and the text an inch in.
local function body_block(b, out, o)
  if b.t == "Para" or b.t == "Plain" then
    if has_note(b) then
      local style = o.keep and "Body Text Keep" or "Body Text Noted"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    else
      out[#out + 1] = xe.raw(p(xe.inl(b.content), { line = BODY, first = INDENT, before = o.before, keep = o.keep }))
    end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    local n = b.t == "OrderedList" and b.listAttributes.start or 1
    for k, item in ipairs(b.content) do
      if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then fail("unsupported list item (one paragraph each)") end
      local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
      out[#out + 1] = xe.raw(p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = INDENT + HANG,
        hanging = HANG, before = k == 1 and o.before or 0, keep = o.keep,
        tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (INDENT + HANG) .. '"/></w:tabs>' }))
      n = n + 1
    end
  else
    fail("unsupported block " .. b.t)
  end
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "counsel", "counsel_role", "brief_title", "signature", "date" }) do
    if m[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end

  -- The memorandum starts at its level 1 heading (typst: split at `# MEMORANDUM OF LAW`).
  local memo_at, last1 = nil, nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      if memo_at == nil and pandoc.text.upper(stringify(b.content)) == "MEMORANDUM OF LAW" then memo_at = i end
      last1 = i
    end
  end
  if memo_at == nil then fail("the body needs a `# MEMORANDUM OF LAW` heading (DUCivR 7-1(a)(1)(B))") end

  needle("S:start", "B", plain(items(m.counsel)[1]), plain(items(m.counsel)[2]))
  -- the motion, a blank double line under the caption
  local motion = {}
  for i = 1, memo_at - 1 do
    local b = doc.blocks[i]
    scan_blocks({ b }, false)
    body_block(b, motion, { before = i == 1 and GAP or 0 })
  end
  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")

  -- the memorandum: heading labels (the counters restart under each level 1 heading), the contents' entries
  local c = { 0, 0, 0, 0 }
  local entries, memo = {}, {}
  for i = memo_at, #doc.blocks do
    local b = doc.blocks[i]
    local keep = last1 ~= nil and i >= last1
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local lv = b.level
      if lv == 1 then c = { 0, 0, 0, 0 } elseif lv <= 4 then
        c[lv] = c[lv] + 1
        for j = lv + 1, 4 do c[j] = 0 end
      end
      local label = heading_label(lv, c)
      local id = "H:" .. (#entries + 1)
      needle(id, "B", (label ~= "" and (label .. " ") or "") .. stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = lv, label = label, title = b.content }
      memo[#memo + 1] = xe.raw(heading(lv, label, b.content, i == memo_at and xe.BREAK or nil))
    else
      scan_blocks({ b }, false)
      body_block(b, memo, { keep = keep })
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:start\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrUtd\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", SECT)

  local out = { xe.raw(cover(m)) }
  for _, x in ipairs(motion) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(toc(entries) .. toa(authorities))
  for _, x in ipairs(memo) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m))
  -- a citation link prints its text only (typst: black text, no link); the break rules on what pandoc writes
  local blocks = pandoc.Blocks(out):walk({ Link = function(el) return el.content end }):walk({ Inlines = xe.inlines })
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
