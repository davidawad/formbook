-- ilcd motion brief (memorandum of law), docx engine. Mirrors typst/ilcd-motion-brief.typ; rules and conventions are
-- in ../README.md. The cover (court title with the division, LR 40.1(E)(1); the caption; the title; the counsel block),
-- the table of contents and the table of authorities (built from the `toa:` links of the body, as typst builds
-- them), the headings (as typed), the signature block (LR 5.11(A)(2), LR 11.1) and the certificate of compliance
-- (LR 7.1(B)(4)(c)) are built here; body paragraphs stay pandoc paragraphs (style Body Text of docx/reference.xml), so
-- their footnotes are pandoc's. Content-agnostic: every case-specific word comes from the sample's frontmatter and
-- body; the certificate's wording is the template's own.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
--
-- Sections and page numbers: the cover is a section without a page number (fb render's rIdFtrNone), the tables a
-- section numbered in lower roman from i, the body a section numbered from 1 ($FORMBOOK_FINAL), both with this
-- filter's page-number footer (rIdFtrIlcd, $FORMBOOK_FOOTERS: a 13.8 pt line, as typst's footer). The tables' page
-- numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- ($FORMBOOK_NEEDLES: the two table titles, each heading, each citation, in document order) in the LibreOffice PDF and
-- renders again with their pages ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst gap: one blank double line
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAD = 4608, 216      -- typst caption-left 3.2 in, caption-pad 0.15 in
local CAP_BELOW = 261                    -- typst: a single line below the party column, less the 0.75 pt bottom rule LibreOffice adds to the row
local DESIG = 1800                       -- typst designation-indent 1.25 in
local COUNSEL = 4680                     -- typst counsel-indent 3.25 in
local HANG = 720                         -- typst heading-hang 0.5 in
local TOC_COL, TOA_COL = 720, 1080       -- typst toc-col 0.5 in, toa-col 0.75 in
local TOA_HANG = 720                     -- typst toa-hang 0.5 in
local PASSIM_AT = 7                      -- typst passim-threshold
local NEEDLE_MAX = 60
local GROUPS = { { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" } }

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
-- sign stays with its number ("§§ 1,": typst binds it with a box).
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
-- Sections: letter page, 1 in margins (LR 5.1(A)); the page number centered in a 13.8 pt line 735 twips above the
-- page foot (typst footer-descent 30 %)
-- ---------------------------------------------------------------------------

local FOOTER = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:jc w:val="center"/>'
  .. '</w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText>'
  .. '</w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/>'
  .. '</w:r></w:p>'

local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="735" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title, counsel
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local title = { "UNITED STATES DISTRICT COURT", "CENTRAL DISTRICT OF ILLINOIS",
    -- LR 40.1(E)(1): the caption identifies the division in which the case is pending
    pandoc.text.upper(plain(m.division)) }
  for _, l in ipairs(title) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end
  -- typst caption: above gap (Word has no space before a table: an empty paragraph of that height)
  out[#out + 1] = p("", { line = GAP })
  local left = {}
  local parties = items(m.caption.parties)
  for k, side in ipairs(parties) do
    if k > 1 then
      left[#left + 1] = ""
      left[#left + 1] = line(xe.runs("v."), { left = DESIG })
      left[#left + 1] = ""
    end
    for _, n in ipairs(items(side.names)) do left[#left + 1] = line(xe.inl(n)) end
    left[#left + 1] = ""
    left[#left + 1] = line(xe.inl(side.designation), { left = DESIG })
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  out[#out + 1] = table_xml({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { stack(left), rule .. '<w:tcMar><w:bottom w:w="' .. CAP_BELOW .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD
      .. '" w:type="dxa"/></w:tcMar>' },
    { stack({ line(xe.runs("Case No. " .. plain(m.case_number))) }),
      '<w:tcMar><w:left w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>' },
  })
  -- the title, in capitals, and the counsel block in the right half, two blank double lines below it
  out[#out + 1] = p(xe.inl(upper(m.brief_title), { b = true }), { before = GAP, jc = "center" })
  local lines = {}
  for i, g in ipairs(items(m.counsel)) do
    if i > 1 then lines[#lines + 1] = "" end
    for _, n in ipairs(items(g.names)) do lines[#lines + 1] = line(xe.inl(n)) end
    for _, l in ipairs(items(g.lines)) do lines[#lines + 1] = line(xe.inl(l)) end
  end
  out[#out + 1] = stack(lines, { above = 2 * GAP, left = COUNSEL })
  out[#out + 1] = section("rIdFtrNone", nil)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings, as typed: level 1 centered bold capitals; level 2 bold, hanging half an inch; level 3 the same half an
-- inch in; level 4 bold italic an inch in. On the body pitch, kept with the next block (typst sticky).
-- ---------------------------------------------------------------------------

local function heading(level, content, pre)
  if level == 1 then
    return p(xe.inl(upper(content), { b = true }), { pre = pre, line = BODY, keep = true, jc = "center" })
  elseif level <= 3 then
    local ind = (level - 2) * HANG
    return p(xe.inl(content, { b = true }), { pre = pre, line = BODY, keep = true, left = ind + HANG, hanging = HANG })
  end
  return p(xe.inl(content, { b = true, i = true }), { pre = pre, line = BODY, keep = true, left = 2 * HANG })
end

-- ---------------------------------------------------------------------------
-- The tables (contents and authorities)
-- ---------------------------------------------------------------------------

-- A table's title on the body pitch, a blank double line, and its column label (typst table-head).
local function table_head(title, col, pre)
  return p(xe.runs(title, { b = true }), { pre = pre, line = BODY, after = GAP, keep = true, jc = "center" })
    .. p(xe.runs(col, { b = true }), { keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, pages_xml, left, hanging, col)
  return p(text_xml .. xe.runs(xe.LEAD) .. pages_xml, { lines = true, tabs = xe.leader_tab(TEXTW),
    before = SINGLE, left = left, hanging = hanging, right = col })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    if e.level <= 3 then
      local ind = (e.level - 1) * HANG
      local t = e.level == 1 and upper(e.title) or e.title
      out[#out + 1] = row(xe.inl(t), xe.runs(labels[e.id] or "0"), ind + HANG, HANG, TOC_COL)
    end
  end
  return table.concat(out)
end

local function toa(authorities, cites)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)", xe.BREAK) }
  -- the distinct page labels of each authority, in document order (the page a citation starts on)
  local pages, seen = {}, {}
  for _, c in ipairs(cites) do
    if authorities[c.key] == nil then
      error("ilcd-motion-brief: link `toa:" .. c.key .. "` has no entry under `authorities:`", 0)
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
      if pages[key] and plain(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a, sort = pandoc.text.lower(plain(a.name)) }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return x.sort < y.sort end)
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { before = SINGLE, keep = true })
      for _, mm in ipairs(members) do
        local a = mm.a
        -- the name and citation as typed (typst prints them as plain strings)
        local text = xe.runs(plain(a.name), { i = g[1] == "case" })
        if plain(a.cite) ~= "" then text = text .. xe.runs(", " .. plain(a.cite)) end
        local pl = pages[mm.key]
        local pxml = #pl >= PASSIM_AT and xe.runs("passim", { i = true }) or xe.runs(table.concat(pl, ", "))
        out[#out + 1] = row(text, pxml, TOA_HANG, TOA_HANG, TOA_COL)
      end
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate (LR 5.11(A)(2), LR 11.1, LR 7.1(B)(4)(c))
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature or {}
  local right = { line(xe.runs("Respectfully submitted,")), "" }
  for _, l in ipairs(items(sig.firm)) do right[#right + 1] = line(xe.inl(l)) end
  right[#right + 1] = ""
  right[#right + 1] = line(xe.runs("/s/ " .. plain(sig.signer)))
  for _, l in ipairs(items(sig.lines)) do right[#right + 1] = line(xe.inl(l)) end
  -- the blank double line above is the block's own (typst: above gap), kept with the conclusion and the table
  return p("", { line = GAP, keep = true })
    .. table_xml({ COUNSEL, TEXTW - COUNSEL }, { { stack({ line(xe.runs("Dated: " .. plain(m.date))) }) },
      { stack(right) } })
end

-- the body's words, counted as the typst template counts them (ilcd-motion-brief.typ, word-count): link targets,
-- footnote labels and markers are not words; a token with no letter or digit is not a word
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then error("ilcd-motion-brief: no sample file to count words from", 0) end
  local h = assert(io.open(f, "r"))
  local text = h:read("a")
  h:close()
  local body, dashes = {}, 0
  for l in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if l == "---" then dashes = dashes + 1 end
    else
      body[#body + 1] = l
    end
  end
  local s = table.concat(body, "\n")
  s = s:gsub("%(toa:[^%)]*%)", "")
  s = s:gsub("%(https://[^%)]*%)", "")
  s = s:gsub("%(http://[^%)]*%)", "")
  s = s:gsub("%[%^[^%]]*%]:?", "")
  local n = 0
  for w in s:gmatch("%S+") do
    if w:find("%w") then n = n + 1 end
  end
  return n
end

-- The certificate of compliance (typst certificate), on a page of its own: its heading (in the contents), its text on
-- the body pitch, the signer in the counsel column.
local function certificate(m, cert_id)
  local sig = m.signature or {}
  local first = items(sig.lines)[1]
  local lines = { line(xe.runs("/s/ " .. plain(sig.signer))) }
  if first then lines[#lines + 1] = line(xe.inl(first)) end
  return heading(1, pandoc.Inlines({ pandoc.Str("Certificate of Compliance") }), xe.BREAK)
    .. p(xe.runs(brk("I certify pursuant to Civil Local Rule 7.1(B)(4)(c) that this memorandum complies with the "
      .. "type-volume limitation. This memorandum contains " .. source_words() .. " words, including headings, "
      .. "footnotes, and quotations, and excluding the cover page, tables, and signature block.")),
      { line = BODY, first = 720 })
    .. stack(lines, { above = GAP, left = COUNSEL, keep = true })
end

-- ---------------------------------------------------------------------------
-- The memorandum
-- ---------------------------------------------------------------------------

-- The citations of a list of inlines, in document order, as needles (B in the body, N in a footnote): the link text
-- and the words after it. A citation link prints its text.
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

local function finish(doc)
  load_pages()
  local m = doc.meta
  if not m.division then error("ilcd-motion-brief: LR 40.1(E)(1) requires the division in the caption (frontmatter: division)", 0) end
  local authorities = {}
  if m.authorities then for k, v in pairs(m.authorities) do authorities[k] = v end end

  -- the conclusion: the blocks from the last level 1 heading on (typst splits the body at its last "# ")
  local last1 = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then last1 = i end
  end

  needle("S:toc", "B", "TABLE OF CONTENTS", "Page")
  needle("S:toa", "B", "TABLE OF AUTHORITIES", "Page(s)")
  local entries, body = {}, {}
  local start = nil
  for i, b in ipairs(doc.blocks) do
    local keep = last1 ~= nil and i >= last1
    local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
    if b.t == "Header" then
      local id = "H:" .. (#entries + 1)
      needle(id, "B", stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = b.level, title = b.content }
      body[#body + 1] = xe.raw(heading(b.level, b.content))
      start = start or id
    else
      if not start then
        start = "S:body"
        needle(start, "B", stringify(b), nxt)
      end
      scan_blocks({ b }, false)
      if b.t == "Para" or b.t == "Plain" then
        -- a paragraph that anchors a footnote has no widow control (typst may leave its last line alone)
        local style = keep and "Body Text Keep" or (has_note(b) and "Body Text Noted" or "Body Text")
        body[#body + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
      elseif b.t == "BlockQuote" then
        for _, q in ipairs(b.content) do
          if q.t ~= "Para" and q.t ~= "Plain" then error("ilcd-motion-brief: unsupported block in a quotation: " .. q.t, 0) end
          body[#body + 1] = pandoc.Div({ pandoc.Para(q.content) }, { ["custom-style"] = "Block Text" })
        end
      else
        error("ilcd-motion-brief: unsupported block " .. b.t, 0)
      end
    end
  end
  local cert = m.type_volume and true or false
  if cert then
    entries[#entries + 1] = { id = "H:cert", level = 1, title = pandoc.Inlines({ pandoc.Str("Certificate of Compliance") }) }
  end

  -- the citations' needles come in document order: the certificate's heading after them
  if cert then needle("H:cert", "B", "CERTIFICATE OF COMPLIANCE", "I certify") end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. (start or "S:toa") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrIlcd\t" .. FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrIlcd", "decimal"))

  local out = { xe.raw(cover(m) .. toc(entries) .. toa(authorities, cites) .. section("rIdFtrIlcd", "lowerRoman")) }
  -- a citation link prints its text only (typst: black text, no link)
  local blocks = pandoc.Blocks(body):walk({ Link = function(el) return el.content end })
  for _, x in ipairs(blocks:walk({ Inlines = xe.inlines })) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m) .. (cert and certificate(m) or ""))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Link = function(el)
  if el.target:match("^toa:") then return nil end
  return el.content
end }, { Pandoc = finish } }
