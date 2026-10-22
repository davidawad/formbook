-- nyed motion-brief (memorandum of law), docx engine (docs/DOCX.md). Mirrors typst/nyed-motion-brief.typ; rules and
-- conventions are in ../README.md. The cover (court name, caption, title, counsel at the foot of the page), the table
-- of contents and the table of authorities (built from the `toa:` links of the body, as typst builds them), the
-- headings with their labels (I., A., 1., a.), the signature block, the certificate of compliance (LCR 7.1(c), the
-- word count of the markdown as the template counts it) and the certificate of service are built here; body
-- paragraphs stay pandoc paragraphs (style Body Text of docx/reference.xml), so their footnotes are pandoc's.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter and body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Sections and page numbers (were docx/render.sh's two passes): the cover is a section without a page number (fb
-- render's rIdFtrNone), the tables a section numbered in lower roman from i, the body a section numbered from 1
-- ($FORMBOOK_FINAL), both with this filter's page-number footer ($FORMBOOK_FOOTERS: the number in a single line box,
-- as typst sets it). The tables' page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the
-- needles this filter writes ($FORMBOOK_NEEDLES: the two table titles, each heading, each citation, in document
-- order) in the LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GAP = 4896, 288      -- typst caption-left (3.4 in), caption-gap (0.2 in)
local CAP_PAD = 165                      -- typst caption-pad (9 pt) less the 0.75 pt rule LibreOffice sets inside the cell
local AGAINST, DESIGNATION = 1728, 2736  -- typst against-indent (1.2 in), designation-indent (1.9 in)
local SIG_W = 4608                       -- typst signature-w, 3.2 in
local TAB_W = 720                        -- typst heading-tab and para-indent, 0.5 in
local TOC_COL, TOA_COL = 720, 1080       -- typst toc-col (0.5 in), toa-col (0.75 in)
local TOA_HANG = 504                     -- typst toa-hang, 0.35 in
local ROW_ABOVE = 240                    -- typst row-above, 12 pt
local PASSIM_AT = 7                      -- typst passim-threshold
local RULE = 'w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt
local NEEDLE_MAX = 60

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("nyed-motion-brief.lua: missing required metadata field `" .. key .. "`") end
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

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- before a letter (a zero-width space). Neither shows in the PDF text.
local function brk(t)
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  return t
end

local function break_rules(s)
  local t = brk(s.text)
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled section sign stays with its number, as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, jc, keep, lines, pre, tabs, frame }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.frame then props[#props + 1] = o.frame end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table without cell margins that is never split: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
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
-- Sections: letter page, 1 in margins (LCR 7.1(b)(2)); the page number in a single line box 0.5 in above the edge
-- ---------------------------------------------------------------------------

local PAGE_FOOTER = '<w:p><w:pPr>' .. xe.spacing(0, 0, SINGLE) .. xe.jc("center") .. '</w:pPr>'
  .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
  .. '</w:p>'

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
-- Cover: court name, caption, title, counsel at the foot of the page
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local court = items(need(m, "court"))
  for i, l in ipairs(court) do
    -- the caption a double line below the last line (its space after)
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", keep = true, after = i == #court and BODY or 0 })
  end
  local left = {}
  for i, side in ipairs(items(need(m, "caption"))) do
    if i > 1 then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("-against-"), { left = AGAINST })
      left[#left + 1] = p("")
    end
    for _, n in ipairs(items(side.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIGNATION })
  end
  local right = { p(xe.runs("Case No. ") .. xe.inl(need(m, "case_number")), { left = CAP_GAP }) }
  if m.legend then
    right[#right + 1] = p(xe.inl(upper(m.legend), { b = true }), { left = CAP_GAP, before = SINGLE })
  end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:top w:val="single" ' .. RULE .. '/><w:bottom w:val="single" ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:top w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', body = left },
    { body = right },
  })
  out[#out + 1] = p(xe.inl(upper(need(m, "brief_title")), { b = true }), { jc = "center", before = 2 * BODY })
  -- counsel: a frame at the bottom margin (typst: placed at the bottom of the page)
  local frame = '<w:framePr w:w="' .. TEXTW .. '" w:wrap="around" w:vAnchor="margin" w:hAnchor="margin" ' ..
    'w:x="0" w:yAlign="bottom"/>'
  for _, l in ipairs(items(m.counsel)) do out[#out + 1] = p(xe.inl(l), { frame = frame }) end
  out[#out + 1] = section("rIdFtrNone", nil)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings: level 1 centred bold capitals; levels 2 to 4 bold, the label in a half-inch box (a tab), the title
-- hanging after it, each level half an inch further in; single-spaced, a single line above and below
-- ---------------------------------------------------------------------------

local function indent(level)
  return math.max(level - 2, 0) * TAB_W
end

local function heading(level, lab, content)
  local o = { keep = true, before = SINGLE, after = SINGLE }
  if level == 1 then
    o.jc = "center"
    return p(xe.inl(upper(content), { b = true }), o)
  end
  o.left, o.hanging = indent(level) + TAB_W, TAB_W
  o.tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (indent(level) + TAB_W) .. '"/></w:tabs>'
  return p(xe.inl(lab, { b = true }) .. xe.runs("\t", { b = true }) .. xe.inl(content, { b = true }), o)
end

-- ---------------------------------------------------------------------------
-- The tables (contents and authorities)
-- ---------------------------------------------------------------------------

-- A table's title, a double line below it the column label (typst table-head).
local function table_head(title, col, pre)
  return p(xe.runs(title, { b = true }), { pre = pre, after = BODY, keep = true, jc = "center" })
    .. p(xe.runs(col, { b = true }), { keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, col, left, hanging)
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = xe.leader_tab(TEXTW),
    before = ROW_ABOVE, left = left, hanging = hanging, right = col })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    if e.level <= 4 then
      local ind = indent(e.level)
      local text
      if e.level == 1 then text = xe.inl(upper(e.title)) else
        text = xe.inl(e.label) .. xe.runs("\t") .. xe.inl(e.title)
      end
      local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + TAB_W) .. '"/>' ..
        '<w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
      out[#out + 1] = p(text .. xe.runs(xe.LEAD) .. xe.runs(labels[e.id] or "0"), { lines = true, tabs = tabs,
        before = ROW_ABOVE, left = ind + TAB_W, hanging = TAB_W, right = TOC_COL })
    end
  end
  return table.concat(out)
end

local GROUPS = { { "case", "Cases" }, { "statute", "Statutes" }, { "rule", "Federal Rules of Civil Procedure" },
  { "other", "Other Authorities" } }

local function toa(authorities, cites)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)", xe.BREAK) }
  -- the distinct page labels of each authority, in document order (the page a citation starts on)
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then
      error("nyed-motion-brief.lua: link `toa:" .. c.key .. "` has no entry under `authorities:` in the frontmatter")
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
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = BODY, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        local text = ""
        if a.name then text = xe.inl(a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        text = text .. xe.inl(a.cite)
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_COL, TOA_HANG, TOA_HANG)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block and certificates
-- ---------------------------------------------------------------------------

-- A double line below the text (the space above its first lines): "Dated:" at the left, the signature column at the
-- right; never split.
local function signature(m)
  local sig = need(m, "signature")
  local right = { p(xe.runs("Respectfully submitted,"), { before = BODY }) }
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = BODY })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(items(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("Dated: ") .. xe.inl(need(m, "date")), { before = BODY }) }
  return tbl({ TEXTW - SIG_W, SIG_W }, { { body = left }, { body = right } })
end

-- The word count of the markdown body as typst/nyed-motion-brief.typ counts it (count-words): link targets, footnote
-- marks and markdown symbols removed, a token counted if it has a letter or digit.
local function count_words()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local s, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if not s then error("nyed-motion-brief.lua: the sample must start with a YAML frontmatter block") end
  local t = src:sub(e + 1)
  t = t:gsub("%]%(toa:[^)]*%)", "]")
  t = t:gsub("%[%^[^%]]+%]:?", " ")
  t = t:gsub("[#*_>]", " ")
  local n = 0
  for w in t:gmatch("%S+") do
    if w:find("[A-Za-z0-9]") then n = n + 1 end
  end
  return n
end

-- The certificate of compliance (LCR 7.1(c)), a double line below the signature block: its title and its text on the
-- body pitch, kept on one page.
local function word_certificate(words, limit)
  if words > limit then
    error("nyed-motion-brief.lua: " .. words .. " words exceeds the LCR 7.1(c) limit of " .. limit)
  end
  return p(xe.runs("CERTIFICATE OF COMPLIANCE", { b = true }), { before = BODY, keep = true, jc = "center" })
    .. p(xe.runs("I certify that this memorandum of law complies with the word-count limit of Local Civil Rule "
      .. "7.1(c). Excluding the caption, table of contents, table of authorities, signature block, and certificates, it "
      .. "contains " .. words .. " words, as counted by the template. The count must be confirmed against the "
      .. "word-processing program used to prepare the filed document."), { line = BODY, first = TAB_W, lines = true })
end

local function service(m)
  return p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { pre = xe.BREAK, keep = true, jc = "center" })
    .. p(xe.inl(m.service), { line = BODY, first = TAB_W, before = SINGLE, keep = true })
    .. signature(m)
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
    if b.t == "Para" or b.t == "Plain" then scan_inlines(b.content, in_note) end
  end
end

-- The markdown heading lines of the body, in order: a label ("I.", "A.", "1.") when two spaces follow it, as typst's
-- parse-heading reads them.
local function heading_labels()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local _, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  local out = {}
  for l in src:sub((e or 0) + 1):gmatch("[^\n]+") do
    if l:match("^#") then out[#out + 1] = l:match("^#+%s+(%S+%.)%s%s+%S") or "" end
  end
  return out
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "brief_title", "signature", "date" }) do
    local _ = need(m, k)
  end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end
  local labs = heading_labels()

  local last = 0
  for i, b in ipairs(doc.blocks) do
    if b.t ~= "Header" then last = i end
  end

  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
  local entries, body = {}, {}
  local start = nil
  local hk = 0
  for i, b in ipairs(doc.blocks) do
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      hk = hk + 1
      local lab = labs[hk] or ""
      local content = pandoc.Inlines(b.content)
      if lab ~= "" then
        -- the label is the heading's first word; the title follows it
        content = pandoc.Inlines({ table.unpack(b.content, 3) })
      end
      local level = math.min(b.level, 6)
      local id = "H:" .. (#entries + 1)
      needle(id, "B", (lab ~= "" and (lab .. " ") or "") .. stringify(content), nxt)
      entries[#entries + 1] = { id = id, level = level, label = lab, title = content }
      local h = heading(level, lab, content)
      -- a heading that opens the body opens a page: no space above it (typst drops it at the top of a page; Word
      -- keeps it after a section break)
      if i == 1 then h = h:gsub('w:before="' .. SINGLE .. '"', 'w:before="0"', 1) end
      body[#body + 1] = xe.raw(h)
      start = start or id
    else
      if not start then
        start = "S:body"
        needle(start, "B", stringify(b), nxt)
      end
      scan_blocks({ b }, false)
      if b.t == "Para" or b.t == "Plain" then
        -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
        body[#body + 1] = pandoc.Div({ pandoc.Para(b.content) },
          { ["custom-style"] = i == last and "Body Text Keep" or "Body Text" })
      else
        error("nyed-motion-brief.lua: unsupported block " .. b.t)
      end
    end
  end

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (start or "S:toa") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdNyedPage\t" .. PAGE_FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdNyedPage", "decimal"))

  local limit = m.word_limit and tonumber(stringify(m.word_limit)) or 8750
  local out = { xe.raw(cover(m) .. toc(entries) .. toa(authorities, cites) .. section("rIdNyedPage", "lowerRoman")) }
  for _, x in ipairs(pandoc.Blocks(body):walk({ Inlines = xe.inlines })) do out[#out + 1] = x end
  local tail = signature(m) .. word_certificate(count_words(), limit)
  if m.service then tail = tail .. service(m) end
  out[#out + 1] = xe.raw(tail)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules }, { Inlines = bind_double_signs }, { Pandoc = finish } }
