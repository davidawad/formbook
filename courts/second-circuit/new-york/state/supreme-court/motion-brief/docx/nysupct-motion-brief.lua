-- N.Y. Supreme Court memorandum of law on a motion, docx engine (docs/DOCX.md). The memorandum as Word paragraphs, so
-- that it reads and breaks as typst/nysupct-motion-brief.typ does: the cover (court, county, the bordered party box
-- with the index number, judge and motion sequence at its right, 22 NYCRR 202.5(a); the title; the counsel block)
-- without a page number, the table of contents and the table of authorities (built from the `toa:` links of the
-- body, as typst builds them) in lower-case roman from i, the body in arabic from 1 (headings, paragraphs,
-- quotations, lists, footnotes), the signature block (CPLR 2101(a)), the service list and the word-count
-- certification on a page of its own (202.8-b(c), the count made from the sample as typst makes it). Every
-- case-specific word comes from the sample's frontmatter and body, never from this file. Font and paragraph styles
-- are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run. A paragraph that anchors a footnote stays a
-- pandoc paragraph (style Body Text Note, without widow control: typst may leave its last line alone).
--
-- The tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter
-- writes ($FORMBOOK_NEEDLES: the court line, the two table titles, each heading with the words after it, each
-- citation with the words after it, in document order) in the LibreOffice PDF and renders again with their pages
-- ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst gap: a blank double line
local HGAP = 240                         -- typst heading-gap 12 pt
local INDENT = 720                       -- typst para-indent 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_BOX, CAP_GUTTER = 5184, 288    -- typst caption-box 3.6 in, caption-gutter 0.2 in
local COVER_GAP = 2304                   -- typst cover-gap 1.6 in
local COUNSEL_W = 5184                   -- typst counsel-width 3.6 in
local QUOTE = 720                        -- typst quote-indent 0.5 in
local TOC_INDENT, TOC_COL = 576, 720     -- typst toc-indent 0.4 in, toc-col 0.5 in
local TOA_COL, TOA_HANG = 1440, 720      -- typst toa-col 1 in, toa-hang 0.5 in
local TOA_ABOVE = 120                    -- typst toa-above 6 pt
local SIG = 4608                         -- typst sig-col 3.2 in
local RULE_SHORT = 864                   -- typst rule-short 0.6 in
local TOC_DEPTH = 4
local PASSIM_AT = 7                      -- typst passim-threshold
local LIMIT_IN_CHIEF, LIMIT_REPLY = 7000, 4200 -- 22 NYCRR 202.8-b(a)(i), (ii)
local NEEDLE_MAX = 60
local GROUPS = { { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" } }

-- The sections: letter page, one-inch margins (22 NYCRR 202.5(a)); the page number centered in a 13.8 pt line whose
-- box ends 0.5 in above the page edge (typst footer-distance), none on the cover.
local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:jc w:val="center"/>'
  .. '</w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText>'
  .. '</w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/>'
  .. '</w:r></w:p>'

local function sect_pr(footer, fmt, start)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/><w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. pg .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(footer, fmt, start)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt, start) .. '</w:pPr></w:p>'
end

local function fail(msg) error("nysupct-motion-brief: " .. msg, 0) end

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

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("3211(a)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
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
-- sign stays with its number ("§§ 3211": typst binds it with a box).
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

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs, border }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.border then
    props[#props + 1] = '<w:pBdr><w:' .. o.border .. ' w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>'
  end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

local function line(xml, o)
  return { xml = xml, o = o }
end

-- Single-spaced lines (typst line-stack): each item a line() or "" (a blank single line). `o.keep`: every line kept
-- with the next (typst: an unbreakable block); `o.above`: the space above the first.
local function stack(lines, o)
  o = o or {}
  local out = {}
  for k, l in ipairs(lines) do
    local po = {}
    if l ~= "" then for key, v in pairs(l.o or {}) do po[key] = v end end
    po.before = k == 1 and (o.above or 0) or 0
    if o.keep and k < #lines then po.keep = true end
    out[#out + 1] = p(l == "" and "" or l.xml, po)
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

local function has_note(b)
  local found = false
  pandoc.Blocks({ b }):walk({ Note = function() found = true end })
  return found
end

-- ---------------------------------------------------------------------------

local function read_file(path)
  if path == nil or path == "" then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (the authorities' names and citations print as typed, as typst prints them).
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

-- ---------------------------------------------------------------------------
-- Word count (typst count-words, rule for rule; NYSUPCT-LEN-002)
-- ---------------------------------------------------------------------------

local function each_line(s, f)
  local out = {}
  for l in (s .. "\n"):gmatch("(.-)\n") do out[#out + 1] = f(l) end
  return table.concat(out, "\n")
end

local function count_words(md)
  local s = md:gsub("<!%-%-.-%-%->", " ")
  s = each_line(s, function(l) return (l:gsub("^%[%^[^%]]+%]:", " ")) end)   -- footnote definition labels
  s = s:gsub("%[%^[^%]]+%]", "")                                              -- footnote references
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")                                   -- links keep their text
  s = each_line(s, function(l)
    l = l:gsub("^######?[ \t]+", ""):gsub("^#?#?#?#?#[ \t]+", "")
    l = l:gsub("^>[ \t]?", "")
    l = l:gsub("^[ \t]*[-*+][ \t]+", ""):gsub("^[ \t]*%d+[.)][ \t]+", "")    -- list markers are not words
    return l
  end)
  s = s:gsub("\\(.)", "%1")                                                   -- backslash escapes
  s = s:gsub("%*", "")
  s = s:gsub("^_", ""):gsub("([%s%(%[\"])_", "%1"):gsub("\u{201C}_", "\u{201C}")
  s = s:gsub("_([%s%.,;:%)%]\"!?])", "%1"):gsub("_\u{201D}", "\u{201D}"):gsub("_$", "")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = ""
  for i = 1, #s do
    if i > 1 and (#s - i + 1) % 3 == 0 then out = out .. "," end
    out = out .. s:sub(i, i)
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover: caption, title, counsel (typst cover)
-- ---------------------------------------------------------------------------

local function caption(m)
  local out = { stack({
    line(xe.runs("SUPREME COURT OF THE STATE OF NEW YORK", { b = true }), { jc = "center" }),
    line(xe.runs("COUNTY OF " .. pandoc.text.upper(plain(m.county)), { b = true })),
  }) }
  local left = { "" }
  for i, g in ipairs(items(m.parties)) do
    if i > 1 then
      left[#left + 1] = ""
      left[#left + 1] = line(xe.runs("-against-", { i = true }), { jc = "center" })
      left[#left + 1] = ""
    end
    for _, n in ipairs(items(g.names)) do
      left[#left + 1] = line(xe.inl(n), { left = CAP_GUTTER, right = CAP_GUTTER })
    end
    left[#left + 1] = ""
    left[#left + 1] = line(xe.inl(g.designation), { right = CAP_GUTTER, jc = "right" })
  end
  left[#left + 1] = ""
  local right = { "", line(xe.inl(m.index_no)) }
  if m.judge then right[#right + 1] = line(xe.inl(m.judge)) end
  if m.motion_seq then right[#right + 1] = line(xe.inl(m.motion_seq)) end
  local rule = '<w:tcBorders><w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  -- typst: the caption block 12 pt below the county line (Word has no space before a table: an empty paragraph)
  out[#out + 1] = p("", { line = HGAP })
  out[#out + 1] = table_xml({ CAP_BOX, TEXTW - CAP_BOX }, {
    { stack(left), rule },
    { stack(right), '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>' },
  })
  return table.concat(out)
end

local function cover(m)
  local c = m.counsel or {}
  local ls = {}
  for _, l in ipairs(items(c.names)) do ls[#ls + 1] = line(xe.inl(l)) end
  for _, l in ipairs(items(c.lines)) do ls[#ls + 1] = line(xe.inl(l)) end
  if c.on_brief then
    ls[#ls + 1] = ""
    ls[#ls + 1] = line(xe.runs("On the Memorandum of Law:"))
    for _, l in ipairs(items(c.on_brief)) do ls[#ls + 1] = line(xe.inl(l)) end
  end
  for _, l in ipairs(ls) do if l ~= "" then l.o = { right = TEXTW - COUNSEL_W } end end
  return caption(m)
    .. p(xe.inl(m.title, { b = true }), { before = COVER_GAP, jc = "center" })
    .. stack(ls, { above = COVER_GAP, keep = true })
    .. section_end("rIdFtrNone")
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities (typst toc-section, toa-section)
-- ---------------------------------------------------------------------------

-- A table's title, its column label at the right; the title opens a page.
local function table_head(title, col, brk_before)
  return p(xe.runs(title, { b = true }), { pre = brk_before and xe.BREAK or nil, after = HGAP, keep = true, jc = "center" })
    .. p(xe.runs(col), { keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging, col, before)
  local tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = tabs,
    before = before, left = left, hanging = hanging, right = col })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page", false) }
  for _, e in ipairs(entries) do
    if e.level <= TOC_DEPTH then
      local ind = (e.level - 1) * TOC_INDENT
      out[#out + 1] = row(xe.inl(e.title), xe.runs(labels[e.id] or "0"), ind + TOC_INDENT, TOC_INDENT, TOC_COL, 0)
    end
  end
  return table.concat(out)
end

local function sort_key(a)
  local s = a.sort or ((a.name or "") .. " " .. (a.cite or ""))
  return (pandoc.text.lower(tostring(s)):gsub("[^a-z0-9 ]", ""))
end

local function toa(cites, brk_before)
  local authorities = RAW.authorities or {}
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)", brk_before) }
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
      if pages[key] and a.kind == g[1] then members[#members + 1] = { key = key, a = a, sort = sort_key(a) } end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        if x.sort ~= y.sort then return x.sort < y.sort end
        return x.key < y.key
      end)
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = SINGLE, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        -- the name and citation as typed (typst prints them as plain strings)
        local text
        if a.name ~= nil then
          text = xe.runs(tostring(a.name), { i = g[1] == "case" }) .. xe.runs(", " .. tostring(a.cite))
        else
          text = xe.runs(tostring(a.cite))
        end
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_HANG, TOA_HANG, TOA_COL, TOA_ABOVE)
      end
    end
  end
  return table.concat(out)
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

-- ---------------------------------------------------------------------------
-- Body blocks
-- ---------------------------------------------------------------------------

-- `top`: the heading opens the body section, where Word keeps the space above it and typst drops it.
local function heading(b, top)
  local lv = b.level
  if lv > 5 then fail("headings deeper than level 5 are not supported") end
  local o = { before = top and 0 or HGAP, after = HGAP, keep = true }
  if lv == 1 then o.jc = "center" end
  return p(xe.inl(b.content, { b = lv <= 4, i = lv >= 4 }), o)
end

local function body_block(b, out, top)
  if b.t == "Para" or b.t == "Plain" then
    if has_note(b) then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = "Body Text Note" })
    else
      out[#out + 1] = xe.raw(p(xe.inl(b.content), { line = BODY, first = INDENT }))
    end
  elseif b.t == "Header" then
    out[#out + 1] = xe.raw(heading(b, top))
  elseif b.t == "BlockQuote" then
    for k, q in ipairs(b.content) do
      if q.t ~= "Para" and q.t ~= "Plain" then fail("unsupported block in a quotation: " .. q.t) end
      out[#out + 1] = xe.raw(p(xe.inl(q.content), { left = QUOTE, right = QUOTE,
        before = k == 1 and HGAP or 0, after = k == #b.content and HGAP or 0 }))
    end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    local n = b.t == "OrderedList" and b.listAttributes.start or 1
    for _, item in ipairs(b.content) do
      if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then fail("unsupported list item (one paragraph each)") end
      local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
      out[#out + 1] = xe.raw(p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = 2 * INDENT,
        hanging = INDENT, tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' }))
      n = n + 1
    end
  else
    fail("unsupported block " .. b.t)
  end
end

-- ---------------------------------------------------------------------------
-- Signature block, service list, certification
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature or {}
  local right = { line(xe.runs("Respectfully submitted,")), "" }
  for _, l in ipairs(items(sig.firm)) do right[#right + 1] = line(xe.inl(l)) end
  right[#right + 1] = ""
  right[#right + 1] = line(xe.runs("By:"), { border = "bottom", right = RULE_SHORT })
  right[#right + 1] = line(xe.inl(sig.signer))
  for _, l in ipairs(items(sig.lines)) do right[#right + 1] = line(xe.inl(l)) end
  local left = { line(xe.runs("Dated:")), line(xe.inl(m.place)), line(xe.inl(m.date)) }
  -- the blank double line above is the block's own (typst: above gap)
  return p("", { line = GAP, keep = true })
    .. table_xml({ TEXTW - SIG, SIG }, { { stack(left) }, { stack(right) } })
end

local function service(m)
  if m.to == nil then return "" end
  local ls = { line(xe.runs("TO:")) }
  for _, g in ipairs(items(m.to)) do
    ls[#ls + 1] = ""
    for _, n in ipairs(items(g.names)) do ls[#ls + 1] = line(xe.inl(n)) end
    for _, l in ipairs(items(g.lines)) do ls[#ls + 1] = line(xe.inl(l)) end -- as typed (typst)
  end
  return stack(ls, { above = GAP, keep = true })
end

local function certificate(m, words, filing)
  local clause = filing == "reply" and "202.8-b(a)(ii)" or "202.8-b(a)(i)"
  local text = "I hereby certify pursuant to 22 NYCRR 202.8-b(c) that the total number of words in the foregoing "
    .. "memorandum of law, exclusive of the caption, table of contents, table of authorities, and signature block, is "
    .. group_digits(words) .. ", according to the word count of the document as prepared, and thus that the document "
    .. "complies with the word count limit set forth in 22 NYCRR " .. clause .. "."
  return p(xe.runs("CERTIFICATION OF COMPLIANCE WITH WORD COUNT LIMIT", { b = true }),
      { pre = xe.BREAK, after = GAP, keep = true, jc = "center" })
    .. p(xe.runs(text), { line = BODY, first = INDENT })
    .. stack({ line(xe.runs("Dated: ") .. xe.inl(m.place) .. xe.runs(", ") .. xe.inl(m.date)), "", "" },
      { above = GAP, keep = true })
    .. table_xml({ TEXTW - SIG, SIG }, { { p("") },
      { stack({ line(xe.inl((m.signature or {}).signer), { border = "top" }) }) } })
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "county", "index_no", "parties", "title", "date", "place", "counsel", "signature", "authorities" }) do
    if m[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  end
  local filing = plain(m.filing ~= nil and m.filing or "in-chief")
  if filing ~= "in-chief" and filing ~= "reply" then fail("`filing` must be `in-chief` or `reply`, not `" .. filing .. "`") end
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  local words = count_words((src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)))
  local limit = filing == "reply" and LIMIT_REPLY or LIMIT_IN_CHIEF
  if words > limit then fail(words .. " words exceeds the 22 NYCRR 202.8-b(a) limit of " .. limit) end
  local with_toc = m.toc ~= false

  needle("S:start", "B", "SUPREME COURT OF THE STATE OF NEW YORK", "COUNTY OF " .. plain(m.county))
  if with_toc then needle("S:toc", "B", "TABLE OF CONTENTS", "Page") end
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
  local entries, body, first_id = {}, {}, nil
  for i, b in ipairs(doc.blocks) do
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local id = "H:" .. (#entries + 1)
      needle(id, "B", stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = b.level, title = b.content }
      first_id = first_id or (i == 1 and id or nil)
    else
      if i == 1 then
        first_id = "S:body"
        needle(first_id, "B", stringify(b):sub(1, 40), nxt)
      end
      scan_blocks({ b }, false)
    end
    body_block(b, body, i == 1)
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\t" .. (with_toc and "S:toc" or "S:toa") .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (first_id or "S:toa") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrNy\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrNy", "decimal", 1))

  local front = (with_toc and toc(entries) or "") .. toa(cites, with_toc) .. section_end("rIdFtrNy", "lowerRoman", 1)
  local out = { xe.raw(cover(m) .. front) }
  for _, x in ipairs(body) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m) .. service(m) .. certificate(m, words, filing))
  local blocks = pandoc.Blocks(out):walk({ Link = function(el) return el.content end }):walk({ Inlines = xe.inlines })
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top.
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
