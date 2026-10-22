-- ctd motion-brief (memorandum of law), docx engine. Mirrors typst/ctd-motion-brief.typ; rules and conventions are in
-- ../README.md. The cover (court title, caption, the oral-argument legend in its lower margin when the sample has one),
-- the table of contents and the table of authorities (built from the `toa:` links of the body, as typst builds them),
-- the heading labels (A., 1., a.), the lists, the block quotations, the signature block and the certification of
-- service are built here; body paragraphs stay pandoc paragraphs (style Body Text of docx/reference.xml), so their
-- footnotes are pandoc's. Content-agnostic: every case-specific word comes from the sample's frontmatter and body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line, 230 a footnote line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.
--
-- Sections and page numbers (were docx/render.sh's two passes and pagemap.awk): the cover is a section without a page
-- number (fb render's rIdFtrNone, or the legend footer), the tables a section numbered in lower roman from i, the body
-- a section numbered from 1 ($FORMBOOK_FINAL), both with this filter's page-number footer ($FORMBOOK_FOOTERS). The
-- tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter
-- writes ($FORMBOOK_NEEDLES: the two table titles, the body's first words, each heading, each citation, in document
-- order) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local BLANK = 552                        -- typst blank: one blank body line
local SINGLE_GAP = 276                   -- typst single-gap: one blank single line
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4752                    -- typst caption-left 3.3 in
local CAP_RULE_PAD = 200                 -- typst caption-rule-pad 10 pt
local CAP_BELOW = 261                    -- typst caption inset 13.8 pt, less the 0.75 pt bottom rule LibreOffice adds to the row
local CAP_RIGHT_IN = 432                 -- typst caption-gutter 0.2 in + caption-pad 0.1 in
local DESIG = 2160                       -- typst designation-indent 1.5 in
local SIG_LEFT = 4032                    -- typst sig-left 2.8 in
local TAB_W = 720                        -- typst heading-tab 0.5 in
local PNUM = 1440                        -- typst page-col 1 in
local TOA_HANG = 504                     -- typst toa-hang 0.35 in
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("motion-brief.lua: missing required metadata field `" .. key .. "`") end
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
  if pandoc.utils.type(inlines) ~= "Inlines" then inlines = { pandoc.Str(stringify(inlines)) } end
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("CM/ECF", "Iqbal/Twombley"), where LibreOffice keeps the word whole: a zero-width space
-- (U+200B) after it. Neither shows in the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- A Str of two or more section signs or pilcrows ("§§"; each two bytes): typst boxes it with its number,
-- lib/pandoc/xengine.lua binds a single sign only.
local function doubled_sign(t)
  local _, s = t:gsub("\u{00A7}", "")
  local _, q = t:gsub("\u{00B6}", "")
  return s + q >= 2 and #t == 2 * (s + q)
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there), nor after a doubled sign: the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    if l[i].t == "Space" and l[i - 1].t == "Str" and doubled_sign(l[i - 1].text) then
      l[i] = pandoc.Str("\u{00A0}")
    end
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

-- Single-spaced lines (typst line-stack): each item a line() or "" (a blank single line). o = { above, left, keep }:
-- keep keeps every line with the next. A cell needs a paragraph even when it holds no line.
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for _, l in ipairs(lines) do
    if l == "" then
      gap = gap + SINGLE
    else
      local po = {}
      for key, v in pairs(l.o or {}) do po[key] = v end
      po.before = gap
      po.left = (po.left or 0) + (o.left or 0)
      po.keep = o.keep
      out[#out + 1] = p(l.xml, po)
      gap = 0
    end
  end
  if #out == 0 then out[1] = p("") end
  return table.concat(out)
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
-- Sections: letter page, 1 in margins (L. Civ. R. 10); the footer 0.5 in above the bottom edge
-- ---------------------------------------------------------------------------

-- The page number centred in a single line box (typst running-footer).
local PAGE_FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:left="0" w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'

local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper (CTD-CAP-001..004); the oral-argument legend (CTD-CONT-102)
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for _, l in ipairs(items(need(m, "court"))) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true })
  end
  -- typst caption: above blank (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = BLANK, keep = true })
  local rows = {}
  for i, side in ipairs(items(need(m, "caption"))) do
    if i > 1 then
      rows[#rows + 1] = ""
      rows[#rows + 1] = line(xe.runs("v."))
      rows[#rows + 1] = ""
    end
    for _, n in ipairs(items(side.names)) do rows[#rows + 1] = line(xe.inl(n)) end
    rows[#rows + 1] = line(xe.inl(side.designation), { left = DESIG })
  end
  local right = { line(xe.runs("Case No. " .. stringify(need(m, "case_number")))), "",
    line(xe.runs("Date: " .. stringify(need(m, "date")))), "", line(xe.inl(upper(need(m, "brief_title")), { b = true })) }
  local w2 = TEXTW - CAP_LEFT
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. w2 .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="' .. CAP_RULE_PAD .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/></w:tcMar>'
    .. '</w:tcPr>' .. stack(rows) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. w2 .. '" w:type="dxa"/></w:tcPr>' .. stack(right, { left = CAP_RIGHT_IN }) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
  local legend = m.oral_argument and stringify(m.oral_argument) or ""
  out[#out + 1] = section(legend ~= "" and "rIdCtdLegend" or "rIdFtrNone", nil)
  return table.concat(out), legend
end

-- ---------------------------------------------------------------------------
-- Headings: "A." level 2, "1." level 3, "a." level 4; level 1 unnumbered
-- ---------------------------------------------------------------------------

local function label(level, k)
  if level == 2 then return string.char(64 + k) .. "."
  elseif level == 3 then return k .. "."
  elseif level == 4 then return string.char(96 + k) .. "."
  end
  return ""
end

local function indent(level)
  return math.max(level - 2, 0) * TAB_W
end

-- A heading single-spaced, a blank single line above, kept with the next block (typst sticky): level 1 centred bold
-- capitals; deeper levels bold, the label in a box half an inch wide (a tab), the title hanging after it.
local function heading(level, lab, content)
  if level == 1 then
    return p(xe.inl(upper(content), { b = true }), { before = SINGLE_GAP, keep = true, jc = "center" })
  end
  local ind = indent(level)
  return p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(content, { b = true }),
    { before = SINGLE_GAP, keep = true, left = ind + TAB_W, hanging = TAB_W })
end

-- ---------------------------------------------------------------------------
-- The tables (contents and authorities)
-- ---------------------------------------------------------------------------

-- A table's title and its column label (typst table-head).
local function table_head(title, col, pre)
  return p(xe.runs(title, { b = true }), { pre = pre, keep = true, jc = "center" })
    .. p(xe.runs(col, { b = true }), { before = SINGLE_GAP, keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging)
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = xe.leader_tab(TEXTW),
    before = SINGLE_GAP, left = left, hanging = hanging, right = PNUM })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    if e.level <= 4 then
      local ind = indent(e.level)
      local text = e.level == 1 and xe.inl(upper(e.title)) or (xe.runs(e.label .. "\t") .. xe.inl(e.title))
      out[#out + 1] = row(text, xe.runs(labels[e.id] or "0"), ind + TAB_W, TAB_W)
    end
  end
  return table.concat(out)
end

local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Regulations" }, { "other", "Other Authorities" } }

local function toa(authorities, cites)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)", xe.BREAK) }
  -- the distinct page labels of each authority, in document order (the page a citation starts on)
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then
      error("motion-brief.lua: link `toa:" .. c.key .. "` has no entry under `authorities:` in the frontmatter")
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
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = SINGLE_GAP, keep = true })
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
-- Signature block and certification (CTD-ELEC-003..005; CTD-CERT-101)
-- ---------------------------------------------------------------------------

-- "Dated:" at the margin and "Respectfully submitted," in the signature column on one line (a tab); for each signer a
-- blank body line, "BY: /s/", the name with the bar number and the signer's lines; every line kept with the next
-- (typst: one unbreakable block). The last line keeps with the next too when a certification follows.
local function signature(m, keep_last)
  local sig = need(m, "signature")
  local out = { xe.para({ xe.KEEP, '<w:tabs><w:tab w:val="left" w:pos="' .. SIG_LEFT .. '"/></w:tabs>',
    xe.spacing(BLANK, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs("Dated: " .. stringify(need(m, "date")) .. "\tRespectfully submitted,")) }
  local signers = { sig }
  for _, o in ipairs(items(sig.others)) do signers[#signers + 1] = o end
  for _, s in ipairs(signers) do
    local name = stringify(s.signer)
    if s.bar then name = name .. ", Fed. Bar No. " .. stringify(s.bar) end
    local lines = { line(xe.runs("BY: /s/ " .. stringify(s.signer))), line(xe.runs(name)) }
    for _, l in ipairs(items(s.lines)) do lines[#lines + 1] = line(xe.inl(l)) end
    out[#out + 1] = stack(lines, { above = BLANK, left = SIG_LEFT, keep = true })
  end
  local x = table.concat(out)
  if not keep_last then
    -- the last line keeps with nothing
    local at = x:match(".*()" .. xe.KEEP:gsub("%p", "%%%0"))
    x = x:sub(1, at - 1) .. x:sub(at + #xe.KEEP)
  end
  return x
end

-- The certification of service (typst certification-block): its title, its text on the body pitch, "/s/" and the
-- signer's lines in the signature column; kept on one page.
local function certification(m)
  local c = m.certification
  if not c then return "" end
  local lines = { line(xe.runs("/s/ " .. stringify(c.signer))), line(xe.inl(c.signer)) }
  for _, l in ipairs(items(c.lines)) do lines[#lines + 1] = line(xe.inl(l)) end
  local s = stack(lines, { above = BLANK, left = SIG_LEFT, keep = true })
  local at = s:match(".*()" .. xe.KEEP:gsub("%p", "%%%0"))
  s = s:sub(1, at - 1) .. s:sub(at + #xe.KEEP)
  return p(xe.runs("CERTIFICATION OF SERVICE", { b = true }), { before = BLANK, keep = true, jc = "center" })
    .. p(xe.inl(c.text), { before = SINGLE_GAP, line = BODY, first = 720, keep = true })
    .. s
end

-- ---------------------------------------------------------------------------
-- The memorandum
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

-- A list's items (typst: "1)" or a bullet in a 0.4 in box half an inch in, the text hanging after it).
local function list_items(b, style)
  local out = {}
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  for _, item in ipairs(b.content) do
    local lab = b.t == "OrderedList" and (n .. ")") or "\u{2022}"
    local inl = pandoc.Inlines({ pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
    inl:extend(pandoc.utils.blocks_to_inlines(item))
    out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
    n = n + 1
  end
  return out
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "brief_title", "date", "signature" }) do
    local _ = need(m, k)
  end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end

  -- the conclusion: the blocks from the last level 1 heading on, kept with the signature block (typst splits the
  -- body at its last "# ")
  local last1 = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then last1 = i end
  end

  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
  local counters = { 0, 0, 0, 0, 0, 0 }
  local entries, body = {}, {}
  local start = nil
  for i, b in ipairs(doc.blocks) do
    local keep = last1 ~= nil and i >= last1
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if not start then
      start = "S:body"
      needle(start, "B", stringify(b), nxt)
    end
    if b.t == "Header" then
      local level = math.min(b.level, 6)
      counters[level] = counters[level] + 1
      for l = level + 1, 6 do counters[l] = 0 end
      local lab = label(level, counters[level])
      local id = "H:" .. (#entries + 1)
      needle(id, "B", (lab ~= "" and (lab .. " ") or "") .. stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = level, label = lab, title = b.content }
      body[#body + 1] = xe.raw(heading(level, lab, b.content))
    else
      scan_blocks({ b }, false)
      if b.t == "Para" or b.t == "Plain" then
        body[#body + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = keep and "Body Text Keep" or "Body Text" })
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, x in ipairs(list_items(b, "Brief Item")) do body[#body + 1] = x end
      elseif b.t == "BlockQuote" then
        for k, q in ipairs(b.content) do
          body[#body + 1] = pandoc.Div({ pandoc.Para(q.content) }, { ["custom-style"] = k == 1 and "Brief Quote First" or "Brief Quote" })
        end
      else
        error("motion-brief.lua: unsupported block " .. b.t)
      end
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tS:body\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdCtdPage", "decimal"))

  local front, legend = cover(m)
  local footers = { "rIdCtdPage\t" .. PAGE_FOOTER }
  if legend ~= "" then
    footers[#footers + 1] = "rIdCtdLegend\t" .. p(xe.runs(pandoc.text.upper("Oral argument " .. legend), { b = true }))
  end
  write_file("FORMBOOK_FOOTERS", table.concat(footers, "\n") .. "\n")

  local out = { xe.raw(front .. toc(entries) .. toa(authorities, cites) .. section("rIdCtdPage", "lowerRoman")) }
  for _, x in ipairs(pandoc.Blocks(body):walk({ Inlines = xe.inlines })) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m, false) .. certification(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
