-- ncmd motion-brief, docx engine. Mirrors typst/ncmd-motion-brief.typ; rules and conventions are in ../README.md. The
-- cover (court title, caption), the table of contents and the table of authorities (built from the `toa:` links of the
-- body, as typst builds them), the heading labels (I., A., 1., a.), the signature block (LR 7.1(b)) and the
-- certificates of word count (LR 7.3(d)(1)) and service are built here; body paragraphs stay pandoc paragraphs (style
-- Body Text of docx/reference.xml), so their footnotes are pandoc's. Content-agnostic: every case-specific word comes
-- from the sample's frontmatter and body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 460 the body, 300 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
--
-- Sections and page numbers (were docx/render.sh's three passes): the cover is a section without a page number
-- (fb render's rIdFtrNone), the tables a section numbered in lower roman from i, the body a section numbered from 1
-- ($FORMBOOK_FINAL), both with fb render's page-number footer (rIdFtrPage). The tables' page numbers: fb render
-- (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes ($FORMBOOK_NEEDLES: the two
-- table titles, each heading, each citation, in document order) in the LibreOffice PDF and renders again with their
-- pages ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 460, 300            -- typst pitch-body 23 pt, pitch-single 15 pt
local BLANK = 460                        -- typst blank: one blank body line
local ROW_ABOVE = 300                    -- typst row-above 15 pt
local TEXTW = 9360                       -- 6.5 in
local CAP_COL, CAP_PAD = 4680, 288       -- typst caption: two half-width columns; caption-pad 0.2 in
local CAP_BELOW = 285                    -- typst caption-below 15 pt, less the 0.75 pt bottom rule LibreOffice adds to the row
local DESIG = 2592                       -- typst designation-indent 1.8 in
local SIG_COL = 4608                     -- typst sig-col 3.2 in
local TAB_W = 720                        -- typst heading-tab 0.5 in
local PNUM = 720                         -- typst page-col 0.5 in
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local PASSIM_AT = 7                      -- typst passim-threshold
local WORD_LIMIT = "6,250"               -- typst word-limit (LR 7.3(d)(1))
local NEEDLE_MAX = 60

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("ncmd-motion-brief.lua: missing required metadata field `" .. key .. "`") end
  return v
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
-- followed by a letter ("CM/ECF"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
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
-- keep: every line kept with the next. A cell needs a paragraph even when it holds no line.
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

-- ---------------------------------------------------------------------------
-- Sections: letter page, top 1.25 in, the others 1 in (LR 7.1(a)); the footer 0.4 in above the bottom edge
-- ---------------------------------------------------------------------------

local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1800" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="576" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper (LR 7.1)
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for _, l in ipairs(items(need(m, "court"))) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center" })
  end
  -- typst caption: above blank (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = BLANK })
  local left = {}
  local sides = items(need(m, "caption"))
  for i, side in ipairs(sides) do
    for _, n in ipairs(items(side.names)) do left[#left + 1] = line(xe.inl(n)) end
    left[#left + 1] = line(xe.inl(side.designation), { left = DESIG })
    if i < #sides then
      left[#left + 1] = ""
      left[#left + 1] = line(xe.runs("v."), { jc = "center" })
      left[#left + 1] = ""
    end
  end
  -- the title as typed: its rule citations ("12(b)(1)") keep their case
  local right = { line(xe.inl(need(m, "case_number"))), "", line(xe.inl(need(m, "brief_title"), { b = true })) }
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  out[#out + 1] = table_xml({ CAP_COL, TEXTW - CAP_COL }, {
    { stack(left), rule .. '<w:tcMar><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD
      .. '" w:type="dxa"/></w:tcMar>' },
    { stack(right), '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>' },
  })
  out[#out + 1] = section("rIdFtrNone", nil)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings: "I." level 2, "A." level 3, "1." level 4, "a." level 5; level 1 unnumbered
-- ---------------------------------------------------------------------------

local function roman(n)
  local t = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, x in ipairs(t) do while n >= x[1] do s = s .. x[2]; n = n - x[1] end end
  return s
end

local function label(level, k)
  if level == 2 then return roman(k) .. "."
  elseif level == 3 then return string.char(64 + k) .. "."
  elseif level == 4 then return k .. "."
  elseif level == 5 then return string.char(96 + k) .. "."
  end
  return ""
end

local function indent(level)
  return math.max(level - 2, 0) * TAB_W
end

-- A heading on the body pitch, kept with the next block (typst sticky): level 1 centred bold capitals; deeper levels
-- bold, the label in a box half an inch wide (a tab), the title hanging after it.
local function heading(level, lab, content)
  if level == 1 then
    return p(xe.inl(upper(content), { b = true }), { line = BODY, keep = true, jc = "center" })
  end
  local ind = indent(level)
  return p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(content, { b = true }),
    { line = BODY, keep = true, left = ind + TAB_W, hanging = TAB_W })
end

-- ---------------------------------------------------------------------------
-- The tables (contents and authorities)
-- ---------------------------------------------------------------------------

-- A table's title and its column label (typst table-head).
local function table_head(title, col, pre)
  return p(xe.runs(title, { b = true }), { pre = pre, line = BODY, after = BLANK, keep = true, jc = "center" })
    .. p(xe.runs(col, { b = true }), { keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging)
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = xe.leader_tab(TEXTW),
    before = ROW_ABOVE, left = left, hanging = hanging, right = PNUM })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    if e.level <= 4 then
      local ind = indent(e.level)
      out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.title), xe.runs(labels[e.id] or "0"), ind + TAB_W, TAB_W)
    end
  end
  return table.concat(out)
end

local GROUPS = { { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" }, { "other", "Other Authorities" } }

local function toa(authorities, cites)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)", xe.BREAK) }
  -- the distinct page labels of each authority, in document order (the page a citation starts on)
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then
      error("ncmd-motion-brief.lua: link `toa:" .. c.key .. "` has no entry under `authorities:` in the frontmatter")
    end
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
      if pages[key] and stringify(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = pandoc.text.lower(stringify(a.name or a.cite or "")) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = ROW_ABOVE, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        local text = ""
        if a.name then text = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        text = text .. xe.inl(a.cite)
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_HANG, TOA_HANG)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates (LR 7.1(b), 7.3(d)(1))
-- ---------------------------------------------------------------------------

local function signature(m)
  local right = { line(xe.runs("Respectfully submitted,")), "" }
  for i, s in ipairs(items(need(m, "signatures"))) do
    for _, k in ipairs({ "signer", "address", "phone", "email", "role" }) do
      if s[k] == nil then error("ncmd-motion-brief.lua: signer block missing `" .. k .. "` (LR 7.1(b))") end
    end
    if i > 1 then right[#right + 1] = "" end
    if s.firm then right[#right + 1] = line(xe.inl(s.firm)) end
    right[#right + 1] = line(xe.runs("/s/ " .. stringify(s.signer)))
    right[#right + 1] = line(xe.inl(s.signer))
    if s.bar_number then right[#right + 1] = line(xe.inl(s.bar_number)) end
    for _, l in ipairs(items(s.address)) do right[#right + 1] = line(xe.inl(l)) end
    right[#right + 1] = line(xe.inl(s.phone))
    right[#right + 1] = line(xe.inl(s.email))
    right[#right + 1] = line(xe.inl(s.role, { i = true }))
  end
  local left = { line(xe.runs("Dated: ") .. xe.inl(need(m, "date"))) }
  -- the blank line above is the block's own (typst: above blank), kept with the conclusion and the table
  return p("", { line = BLANK, keep = true })
    .. table_xml({ TEXTW - SIG_COL, SIG_COL }, { { stack(left) }, { stack(right) } })
end

-- A certificate (typst certificate): its title, its text on the body pitch, the signer in the signature column; kept
-- on one page.
local function certificate(title, paras, sig)
  local out = { p(xe.runs(title, { b = true }), { before = BLANK, line = BODY, keep = true, jc = "center" }) }
  for _, x in ipairs(paras) do
    out[#out + 1] = p(x, { line = BODY, first = 720, keep = true })
  end
  out[#out + 1] = stack({ line(xe.runs("/s/ " .. stringify(sig.signer))), line(xe.inl(sig.signer)) },
    { above = SINGLE, left = TEXTW - SIG_COL, keep = true })
  return table.concat(out)
end

local function certificates(m)
  local sig = items(need(m, "signatures"))[1]
  return certificate("CERTIFICATE OF WORD COUNT", {
    xe.runs(brk("I hereby certify that this brief complies with Local Rule 7.3(d)(1) in that it does not exceed "
      .. WORD_LIMIT .. " words in length, including the body of the brief, headings, and footnotes.")),
    xe.runs("This the ") .. xe.inl(need(m, "certificate_date")) .. xe.runs("."),
  }, sig) .. certificate("CERTIFICATE OF SERVICE", {
    xe.runs("I certify that, on ") .. xe.inl(need(m, "service_date"))
      .. xe.runs(brk(", a copy of the foregoing document was filed with the Clerk of the Court using the CM/ECF System, "
      .. "which will send notification of the filing to the parties and counsel of record who are registered with "
      .. "that system.")),
  }, sig)
end

-- ---------------------------------------------------------------------------
-- The brief
-- ---------------------------------------------------------------------------

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

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "brief_title", "date", "certificate_date", "service_date",
    "signatures" }) do
    local _ = need(m, k)
  end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end

  -- the conclusion: the blocks from the last level 2 heading on (typst splits the body at its last "## ")
  local last2 = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 2 then last2 = i end
  end

  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
  local counters = { 0, 0, 0, 0, 0, 0 }
  local entries, body = {}, {}
  local start = nil
  for i, b in ipairs(doc.blocks) do
    local keep = last2 ~= nil and i >= last2
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local level = math.min(b.level, 6)
      counters[level] = counters[level] + 1
      for l = level + 1, 6 do counters[l] = 0 end
      local lab = label(level, counters[level])
      local id = "H:" .. (#entries + 1)
      needle(id, "B", (lab ~= "" and (lab .. " ") or "") .. stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = level, label = lab, title = b.content }
      body[#body + 1] = xe.raw(heading(level, lab, b.content))
      start = start or id
    else
      if not start then
        start = "S:body"
        needle(start, "B", stringify(b), nxt)
      end
      scan_blocks({ b }, false)
      if b.t == "Para" or b.t == "Plain" then
        body[#body + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = keep and "Body Text Keep" or "Body Text" })
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
      else
        error("ncmd-motion-brief.lua: unsupported block " .. b.t)
      end
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (start or "S:toa") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  local out = { xe.raw(cover(m) .. toc(entries) .. toa(authorities, cites) .. section("rIdFtrPage", "lowerRoman")) }
  for _, x in ipairs(pandoc.Blocks(body):walk({ Inlines = xe.inlines })) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m) .. certificates(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
