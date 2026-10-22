-- California Court of Appeal brief, docx engine (docs/DOCX.md). The document as Word paragraphs, so that it reads and
-- breaks as the typst template of this doc type (typst/calctapp-*.typ) does: the cover (Rule 8.204(b)(10), 8.74(a)(9),
-- (c)(1): court, caption with the Court of Appeal number, trial court, its number and judge, title, counsel and the
-- party they represent), the table of contents and the table of authorities (Rule 8.204(a)(1)(A), built from the
-- headings and the `toa:` links of the body, as typst builds them), the body with its heading labels ("I.", "A.",
-- "1.", "a."), block quotations and footnotes, the signature block, the certificate of word count (Rule 8.204(c)(1),
-- the count of the markdown as typst counts it) and the proof of service. Every case-specific word comes from the
-- sample's frontmatter and body, never from this file. Font, the page number's style and the paragraph styles are in
-- docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 450 the body, 300 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run. A paragraph that anchors a footnote stays a
-- pandoc paragraph (style Body Text Note, without widow control: typst may leave its last line alone).
--
-- The tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter
-- writes ($FORMBOOK_NEEDLES: the first lines of the cover, each heading, each citation, in document order) in the
-- LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle. The pages are numbered in
-- arabic from the cover as page 1, the cover's number not printed (Rule 8.74(a)(2): titlePg).

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local NAME = "calctapp"
local BODY, SINGLE = 450, 300            -- typst pitch-body 22.5 pt, pitch-single 15 pt
local GAP = 600                          -- typst gap: two blank single lines, between the cover's parts
local HEAD_ABOVE, HEAD_BELOW = 300, 150  -- typst head-above 15 pt, head-below 7.5 pt
local QUOTE_GAP = 150                    -- typst quote-gap 7.5 pt
local PARA_GAP = 300                     -- typst para-gap 15 pt
local INDENT = 720                       -- typst para-indent 0.5 in
local HANG = 720                         -- typst label-box 0.5 in
local QUOTE_IND = 720                    -- typst quote-indent 0.5 in
local TEXTW = 7920                       -- 5.5 in: letter width less 1 1/2 in on each side
local CAP_LEFT, CAP_PAD = 4896, 144      -- typst caption-left 3.4 in, caption-pad 0.1 in
local CAP_BELOW = 285                    -- typst: a single line below the party column, less the 0.75 pt rule LibreOffice adds
local DESIG = 2160                       -- typst designation-indent 1.5 in
local SIG = 4320                         -- typst sig-col 3 in
local SERVED = 720                       -- typst served-indent 0.5 in
local TOC_COL, TOA_COL = 720, 1440       -- typst toc-col 0.5 in, toa-col 1 in
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local TOC_ABOVE, TOC_SUB_ABOVE = 150, 80 -- typst toc-above 7.5 pt, toc-sub-above 4 pt
local TOA_ABOVE = 150                    -- typst toa-above 7.5 pt
local TOC_DEPTH = 5
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60
local GROUPS = {
  { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
  { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
}

-- The section: letter page, 1 1/2 in left and right, 1 in top and bottom (Rule 8.204(b)(6)); the page number centered
-- in a 15 pt line whose box ends 0.5 in above the page edge (typst footer-distance), none on the cover (titlePg).
local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/><w:jc w:val="center"/>'
  .. '</w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText>'
  .. '</w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/>'
  .. '</w:r></w:p>'
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrCal"/>'
  .. '<w:footerReference w:type="first" r:id="rIdFtrNone"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="2160" w:bottom="1440" w:left="2160" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:pgNumType w:fmt="decimal" w:start="1"/><w:titlePg/></w:sectPr>'

local function fail(msg) error(NAME .. ": " .. msg, 0) end

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
-- ("(a)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash followed
-- by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in the PDF
-- text.
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
-- sign stays with its number ("§§ 1.24.010": typst binds it with a box).
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

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs, valign }.
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
      if o.pre and #out == 0 then po.pre = o.pre end
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
-- Word count (typst count-words, rule for rule, on the sample's markdown body)
-- ---------------------------------------------------------------------------

local function count_words()
  local path = PANDOC_STATE.input_files[1]
  local f = path and io.open(path, "r")
  if not f then fail("cannot read the sample to count its words") end
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if not e then fail("the sample must start with a YAML frontmatter block") end
  local s = src:sub(e + 1)
  -- a line start is "\n" (a newline is put in front and taken off at the end)
  s = "\n" .. s:gsub("<!%-%-.-%-%->", " ")
  s = s:gsub("\n%[%^[^%]]+%]:", "\n ")                      -- footnote definition labels
  s = s:gsub("%[%^[^%]]+%]", "")                            -- footnote references
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")                 -- links keep their text
  s = s:gsub("\n(#+)[ \t]+", function(h) if #h <= 6 then return "\n" end end)
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[-*+][ \t]+", "\n"):gsub("\n[ \t]*%d+[.)][ \t]+", "\n")   -- list markers are not words
  s = s:gsub("\\(.)", "%1")                                 -- backslash escapes
  s = s:gsub("%*", "")
  s = s:gsub("([%s%(%[\"])_", "%1"):gsub("\u{201C}_", "\u{201C}")
  s = s:gsub("_([%s%.,;:%)%]\"!%?])", "%1"):gsub("_\u{201D}", "\u{201D}"):gsub("_$", "")
  s = s:gsub("\u{00A0}", " ")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

local function centered(lines, o)
  local out = {}
  for _, l in ipairs(lines) do
    if l == "" then out[#out + 1] = l else out[#out + 1] = line(l, { jc = "center" }) end
  end
  return stack(out, o)
end

local function cover(m)
  local out = {}
  local court = {}
  for _, l in ipairs(items(m.court_lines)) do court[#court + 1] = xe.inl(l, { b = true }) end
  out[#out + 1] = centered(court)
  -- typst caption: above gap (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = GAP })
  local left = {}
  for k, side in ipairs(items(m.caption)) do
    if k > 1 then
      left[#left + 1] = ""
      left[#left + 1] = line(xe.runs("v."), { left = DESIG })
      left[#left + 1] = ""
    end
    for _, n in ipairs(items(side.names)) do left[#left + 1] = line(xe.inl(n)) end
    left[#left + 1] = line(xe.inl(side.designation), { left = DESIG })
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  out[#out + 1] = table_xml({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { stack(left), rule .. '<w:tcMar><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD
      .. '" w:type="dxa"/></w:tcMar>' },
    { stack({ line(xe.runs("Court of Appeal Case No. " .. plain(m.case_number))) }),
      '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>' },
  })
  out[#out + 1] = centered({ xe.inl(m.trial_court), xe.runs("Case No. " .. plain(m.superior_case_number)),
    xe.inl(m.judge) }, { above = GAP })
  out[#out + 1] = centered({ xe.inl(upper(m.brief_title), { b = true }) }, { above = GAP })
  local counsel = {}
  for k, g in ipairs(items(m.counsel)) do
    if k > 1 then counsel[#counsel + 1] = "" end
    for _, n in ipairs(items(g.names)) do counsel[#counsel + 1] = xe.inl(n) end
    for _, l in ipairs(items(g.lines)) do counsel[#counsel + 1] = xe.inl(l) end
  end
  counsel[#counsel + 1] = ""
  counsel[#counsel + 1] = xe.inl(m.counsel_for, { i = true })
  out[#out + 1] = centered(counsel, { above = GAP })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings: single spaced, bold, 15 pt above and 7.5 pt below, kept with the next block. Level 1 centered capitals;
-- deeper levels their label in a half-inch box at (level - 2) half inches, later lines under the text; levels 4 and
-- 5 bold italic.
-- ---------------------------------------------------------------------------

local function roman(n)
  local vals = { { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
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
  if level == 5 then return string.char(96 + c[5]) .. "." end
  return ""
end

local function heading(level, label, content, first)
  local o = { pre = first and xe.BREAK or nil, before = first and 0 or HEAD_ABOVE, after = HEAD_BELOW, keep = true }
  if level == 1 then
    o.jc = "center"
    return p(xe.inl(upper(content), { b = true }), o)
  end
  if label == "" then return p(xe.inl(content, { b = true }), o) end
  local ind = (level - 2) * HANG
  o.left, o.hanging = ind + HANG, HANG
  o.tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + HANG) .. '"/></w:tabs>'
  return p(xe.runs(label .. "\t", { b = true }) .. xe.inl(content, { b = true, i = level >= 4 }), o)
end

-- ---------------------------------------------------------------------------
-- The tables (contents and authorities)
-- ---------------------------------------------------------------------------

-- The title of a part that is not a heading of the brief: a new page, centered bold capitals, half a line below.
local function part_title(title)
  return p(xe.runs(pandoc.text.upper(title), { b = true }), { pre = xe.BREAK, after = HEAD_BELOW, keep = true, jc = "center" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging, col, before, label_tab)
  local tabs = '<w:tabs>' .. (label_tab and ('<w:tab w:val="left" w:pos="' .. label_tab .. '"/>') or "")
    .. '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = tabs,
    before = before, left = left, hanging = hanging, right = col })
end

local function toc(entries)
  local out = { part_title("Table of Contents"), p(xe.runs("Page", { b = true }), { keep = true, jc = "right" }) }
  for _, e in ipairs(entries) do
    if e.level <= TOC_DEPTH then
      local page = xe.runs(labels[e.id] or "0")
      if e.level == 1 then
        out[#out + 1] = row(xe.inl(upper(e.title)), page, HANG, HANG, TOC_COL, TOC_ABOVE)
      elseif e.label == "" then
        local ind = (e.level - 2) * HANG
        out[#out + 1] = row(xe.inl(e.title), page, ind + HANG, HANG, TOC_COL, TOC_SUB_ABOVE)
      else
        local ind = (e.level - 2) * HANG
        out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), page, ind + HANG, HANG, TOC_COL,
          TOC_SUB_ABOVE, ind + HANG)
      end
    end
  end
  return table.concat(out)
end

local function sort_key(a)
  local s = a.sort ~= nil and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  s = s:gsub("\u{00A0}", " ")
  return (pandoc.text.lower(s):gsub("[^a-z0-9 ]", ""))
end

local function toa(authorities)
  local out = { part_title("Table of Authorities") }
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
  local first = true
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if pages[key] and plain(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = sort_key(a) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      local head = xe.runs(g[2], { b = true })
      local o = { before = first and HEAD_BELOW or HEAD_ABOVE, keep = true }
      if first then
        head = head .. xe.runs("\t") .. xe.runs("Page(s)", { b = true })
        o.tabs = '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>'
      end
      out[#out + 1] = p(head, o)
      first = false
      for _, mm in ipairs(members) do
        local a = mm.a
        local text
        if a.name ~= nil then
          if g[1] == "case" then
            text = xe.inl(a.name, { i = true }) .. xe.runs(" ") .. xe.inl(a.cite)
          else
            text = xe.inl(a.name) .. xe.runs(", ") .. xe.inl(a.cite)
          end
        else
          text = xe.inl(a.cite)
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
-- Signature block, certificate of word count, proof of service
-- ---------------------------------------------------------------------------

-- The blank 1.5 line above is the block's own (typst: above pitch-body), kept with what it follows.
local function two_columns(left, right)
  return p("", { line = BODY, keep = true })
    .. table_xml({ TEXTW - SIG, SIG }, { { stack(left) }, { stack(right) } })
end

local function signature(m)
  local sig = m.signature or {}
  return two_columns({ line(xe.runs("Dated: ") .. xe.inl(m.date)) }, {
    line(xe.inl(sig.firm)), line(xe.runs("s/") .. xe.inl(sig.signer)), line(xe.inl(sig.signer)),
    line(xe.inl(sig.role, { i = true })) })
end

local function single_par(xml, before, o)
  o = o or {}
  o.before = before
  return p(xml, o)
end

local function certificate(m, words)
  return part_title("Certificate of Word Count")
    .. single_par(xe.runs("Under Rule 8.204, subdivision (c)(1), of the California Rules of Court, I certify that the "
      .. "attached ") .. xe.inl(m.brief_title, { i = true }) .. xe.runs(" is 1\u{00BD}-spaced, typed in a "
      .. "proportionally spaced, 13-point font, and the brief contains " .. group_digits(words) .. " words of text, "
      .. "including footnotes, as counted by the word-count feature of the word-processing program used to prepare "
      .. "the brief."), 0)
    .. signature(m)
end

local function proof_of_service(m)
  local svc = m.service or {}
  local out = { part_title("Proof of Service") }
  out[#out + 1] = stack({ line(xe.runs("Case Name: ") .. xe.inl(m.case_name)),
    line(xe.runs("Court of Appeal Case No.: " .. plain(m.case_number))),
    line(xe.runs("Superior Court Case No.: " .. plain(m.superior_case_number))) })
  out[#out + 1] = single_par(xe.runs("I, ") .. xe.inl(svc.declarant) .. xe.runs(", am employed in ")
    .. xe.inl(svc.employed_in) .. xe.runs(". I am over the age of eighteen (18) years and am not a party to the within "
    .. "action. My business address is ") .. xe.inl(svc.business_address) .. xe.runs("."), PARA_GAP)
  out[#out + 1] = single_par(xe.runs("On ") .. xe.inl(m.date) .. xe.runs(", I served a copy of the foregoing document "
    .. "described as: ") .. xe.inl(m.brief_title) .. xe.runs(", on the following parties, as follows:"), PARA_GAP)
  for _, s in ipairs(items(svc.served)) do
    out[#out + 1] = stack({ line(xe.inl(s.name), { lines = true }),
      line(xe.runs("Served ") .. xe.inl(s.method) .. xe.runs("."), { lines = true }) },
      { above = PARA_GAP, left = SERVED, keep = true })
  end
  out[#out + 1] = single_par(xe.runs("I declare under penalty of perjury under the laws of the State of California "
    .. "that the foregoing is true and correct."), PARA_GAP)
  out[#out + 1] = single_par(xe.runs("Executed on ") .. xe.inl(svc.executed) .. xe.runs("."), PARA_GAP)
  out[#out + 1] = two_columns({}, { line(xe.inl(svc.declarant)), line(xe.runs("Declarant")) })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- A body block as Word paragraphs: a paragraph on the body pitch, its first line indented (one with a footnote stays
-- a pandoc paragraph); a block quotation's paragraphs single spaced, half an inch in on both sides.
local function body_block(b, out, keep)
  if b.t == "Para" or b.t == "Plain" then
    if has_note(b) then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = keep and "Body Text Keep" or "Body Text Note" })
    else
      out[#out + 1] = xe.raw(p(xe.inl(b.content), { line = BODY, first = INDENT, keep = keep }))
    end
  elseif b.t == "BlockQuote" then
    for _, q in ipairs(b.content) do
      if q.t ~= "Para" and q.t ~= "Plain" then fail("unsupported block in a quotation: " .. q.t) end
      if has_note(q) then fail("a footnote in a block quotation is not supported") end
      out[#out + 1] = xe.raw(p(xe.inl(q.content), { before = QUOTE_GAP, after = QUOTE_GAP, left = QUOTE_IND,
        right = QUOTE_IND, keep = keep }))
    end
  elseif b.t == "BulletList" or b.t == "OrderedList" then
    fail("lists are not supported in the body (the typst template sets none)")
  else
    fail("unsupported block " .. b.t)
  end
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "court_lines", "case_number", "case_name", "caption", "trial_court", "superior_case_number",
      "judge", "brief_title", "counsel", "counsel_for", "signature", "date", "service" }) do
    if m[k] == nil then fail("missing required metadata field `" .. k .. "`") end
  end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end
  local words = count_words()

  local court = items(m.court_lines)
  needle("S:start", "B", plain(court[1]), plain(court[2]))

  -- The last block is kept with the signature block (typst: one unbreakable block), unless it is a heading or holds
  -- a footnote.
  local last = #doc.blocks
  local keep_last = last > 0 and doc.blocks[last].t ~= "Header" and not has_note(doc.blocks[last])

  -- the body: heading labels (the counters restart under each level 1 heading), the contents' entries
  local c = { 0, 0, 0, 0, 0 }
  local entries, body = {}, {}
  for i, b in ipairs(doc.blocks) do
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local lv = b.level
      if lv > 5 then fail("headings deeper than level 5 are not supported") end
      c[lv] = c[lv] + 1
      for j = lv + 1, 5 do c[j] = 0 end
      local label = heading_label(lv, c)
      local id = "H:" .. (#entries + 1)
      needle(id, "B", (label ~= "" and (label .. " ") or "") .. stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = lv, label = label, title = b.content }
      body[#body + 1] = xe.raw(heading(lv, label, b.content, i == 1))
    else
      scan_blocks({ b }, false)
      body_block(b, body, keep_last and i == last)
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:start\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrCal\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", SECT)

  local out = { xe.raw(cover(m) .. toc(entries) .. toa(authorities)) }
  for _, x in ipairs(body) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m) .. certificate(m, words) .. proof_of_service(m))
  -- a citation link prints its text only (typst: no link); the break rules on what pandoc writes
  local blocks = pandoc.Blocks(out):walk({ Link = function(el) return el.content end }):walk({ Inlines = xe.inlines })
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
