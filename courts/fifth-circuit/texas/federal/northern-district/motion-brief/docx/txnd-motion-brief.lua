-- N.D. Tex. brief in support of a motion, docx engine (docs/DOCX.md): what the Word output adds to pandoc's
-- conversion, so that it reads and breaks as typst/txnd-motion-brief.typ does (see ../README.md "Engines"): the cover
-- (court title, caption table with a column of section marks, title of the brief), the table of contents and the
-- index of authorities (LR 7.2), the headings, the bullets, the quotations and the signature block, which goes before
-- a certificate of service (or at the end). Everything printed comes from the sample's frontmatter and body: no case
-- text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle:
-- the contents' page of each heading, and the index's pages of each authority (every occurrence of its `key` in the
-- body, found as typst finds it: the keys tried in order at each place, leftmost first). Three sections: the cover
-- (no number), the tables (roman, the cover counted as i) and the body (arabic from 1; FORMBOOK_FINAL). Word may
-- paginate slightly differently from LibreOffice.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-double, pitch-single
local INDENT = 720                            -- typst para-indent, list-indent, quote-indent, heading-hang: 0.5 in
local TEXTW = 9360                            -- 6.5 in
local CAP_LEFT, CAP_SIGN = 4320, 432          -- typst caption-left 3.0 in, caption-sign 0.3 in
local SIG_LEFT = 4320                         -- typst sig-left 3.0 in
local COVER_GAP, TITLE_ABOVE = 360, 840       -- typst cover-gap 18 pt, title-above 42 pt
local ROW_GAP, GROUP_GAP = 120, 240           -- typst row-gap 6 pt, group-gap 12 pt
local TOC_STEP, TOC_COL, TOA_COL = 360, 720, 1440 -- typst toc-step 18 pt, toc-page-col 36 pt, toa-page-col 72 pt
local H1_ABOVE, H2_ABOVE, H_BELOW = 320, 160, 40 -- typst h1-above 16 pt, h2-above 8 pt, heading-below 2 pt
local Q_ABOVE, Q_BELOW = 240, 120             -- typst quote-above 12 pt, quote-below 6 pt
local PASSIM_AFTER = 5                        -- typst toa-passim-after
local FOOTER = 735                            -- the page number's line 36.75 pt above the page foot (typst footer-descent 30 %)
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { style, before, after, line, left, right, first, hanging, tabs, jc, keep, lines, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A section's properties: its footer (fb render's rIdFtrNone or rIdFtrPage), the page numbers, letter paper with
-- 1-inch margins (LR 10.1, LR 7.2).
local function sect_pr(footer, fmt, start)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' .. pg .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(footer, fmt, start)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' ..
    sect_pr(footer, fmt, start) .. '</w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = "B", needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
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

-- Every occurrence of an authority key in a block's text, as typst's show rule finds them: at each place the keys
-- are tried in the frontmatter's order, and the search goes on after a match. Each is a needle (the key and the
-- words after it), and its id is listed under the key.
local keys, hits = {}, {}
local k_n = 0
local function scan_keys(text)
  local pos = 1
  while pos <= #text do
    local hit
    for _, k in ipairs(keys) do
      if text:sub(pos, pos + #k - 1) == k then
        hit = k
        break
      end
    end
    if hit then
      k_n = k_n + 1
      local id = "K:" .. k_n
      need(id, hit, text:sub(pos + #hit, pos + #hit + 60))
      hits[hit][#hits[hit] + 1] = id
      pos = pos + #hit
    else
      pos = pos + 1
    end
  end
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the brief
-- ---------------------------------------------------------------------------

local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, w in ipairs(widths) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. cells[i] .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local COURT = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF TEXAS" }

local function cover(meta)
  local out = {}
  local court = { COURT[1], COURT[2] }
  if meta.court_division and plain(meta.court_division) ~= "" then
    court[#court + 1] = pandoc.text.upper(plain(meta.court_division))
  end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end
  local lines = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then lines[#lines + 1] = "v." end
    for _, n in ipairs(party.names) do lines[#lines + 1] = n end
    lines[#lines + 1] = party.designation
  end
  local mid = math.floor(#lines / 2)
  local rows = {}
  for i, l in ipairs(lines) do
    local right = i == mid and (xe.runs("CIVIL ACTION NO. ") .. xe.inl(meta.case_number)) or ""
    rows[#rows + 1] = { p(xe.inl(l)), p(xe.runs("§"), { jc = "center" }), p(right) }
  end
  -- the space above the caption: a 1 pt paragraph carries it (Word has no space around a table)
  out[#out + 1] = p("", { before = COVER_GAP - 20, line = 20 })
  out[#out + 1] = tbl({ CAP_LEFT, CAP_SIGN, TEXTW - CAP_LEFT - CAP_SIGN }, rows)
  out[#out + 1] = p(xe.inl(meta.brief_title, { b = true }), { jc = "center", before = TITLE_ABOVE })
  return out
end

-- ---------------------------------------------------------------------------
-- Tables (LR 7.2): contents and index of authorities, rows with a dot leader to the page column
-- ---------------------------------------------------------------------------

local function table_title(t, brk)
  return p(xe.runs(t, { b = true }), { jc = "center", after = COVER_GAP, keep = true, brk = brk })
end

local function row(text, page, left, col)
  return p(text .. xe.runs(xe.LEAD .. page), { lines = true, tabs = xe.leader_tab(TEXTW), before = ROW_GAP,
    left = left, right = col })
end

local function contents(entries)
  local out = { table_title("TABLE OF CONTENTS") }
  for _, e in ipairs(entries) do
    out[#out + 1] = row(xe.inl(e.title), labels[e.id] or "0", (e.level - 1) * TOC_STEP, TOC_COL)
  end
  return out
end

local function authorities(meta)
  local out = { table_title("INDEX OF AUTHORITIES", true) }
  for k, cat in ipairs(meta.authorities) do
    out[#out + 1] = p(xe.inl(cat.category, { b = true }), { before = k == 1 and 0 or GROUP_GAP, keep = true })
    for _, e in ipairs(cat.entries) do
      local pages, seen = {}, {}
      for _, id in ipairs(hits[plain(e.key)] or {}) do
        local l = labels[id] or "0"
        if not seen[l] then
          seen[l] = true
          pages[#pages + 1] = l
        end
      end
      local where = #pages > PASSIM_AFTER and "passim" or table.concat(pages, ", ")
      out[#out + 1] = row(xe.inl(e.cite), where, 0, TOA_COL)
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings, single spaced and bold, kept with the text: level 1 centered, levels 2 and 3 at the margin with the
-- lines after the first hanging half an inch.
local function heading(b, first)
  local o = { style = "Heading" .. math.min(b.level, 3), keep = true, after = H_BELOW }
  if b.level == 1 then
    o.before, o.jc = H1_ABOVE, "center"
  else
    o.before, o.left, o.hanging = H2_ABOVE, INDENT, INDENT
  end
  if first then o.before = 0 end
  return p(xe.inl(b.content, { b = true }), o)
end

-- The signature block at the right: "Respectfully submitted," and, for each signer, the signature, the name, the
-- bar number, the firm, the address and the role, single spaced, the signers 6 pt apart; kept whole.
local function signature(meta)
  local ps = { { xe.runs("Respectfully submitted,"), BODY } }
  for _, s in ipairs(meta.signature) do
    local items = { "/s/ " .. plain(s.signer), plain(s.signer), s.bar }
    for _, g in ipairs({ s.firm, s.address, s.lines }) do
      for _, l in ipairs(g) do items[#items + 1] = l end
    end
    for i, l in ipairs(items) do ps[#ps + 1] = { xe.inl(l), i == 1 and ROW_GAP or 0 } end
  end
  local out = {}
  for i, x in ipairs(ps) do
    out[#out + 1] = p(x[1], { left = SIG_LEFT, before = x[2], keep = i < #ps, lines = true })
  end
  return out
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section or paragraph sign stays with its number ("¶¶ 42"; typst boxes "[§¶]+ \S+"; xe.inl binds one).
local function doubled_signs(inlines)
  for k = 1, #inlines - 1 do
    local a, b = inlines[k], inlines[k + 1]
    if a.t == "Str" and (a.text == "§§" or a.text == "¶¶") and b.t == "Space" then inlines[k + 1] = pandoc.Str("\u{00A0}") end
  end
  return inlines
end

local function is_certificate(b)
  return b.t == "Header" and b.level == 1 and norm(stringify(b.content)) == "certificateofservice"
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  for _, cat in ipairs(meta.authorities or {}) do
    for _, e in ipairs(cat.entries) do
      local k = plain(e.key)
      keys[#keys + 1] = k
      hits[k] = {}
    end
  end
  doc.blocks = doc.blocks:walk({ Inlines = doubled_signs })
  local blocks = doc.blocks

  -- where the signature block goes: before a certificate of service, else at the end
  local sig_at = #blocks + 1
  for i, b in ipairs(blocks) do
    if is_certificate(b) then
      sig_at = i
      break
    end
  end

  -- the needles, in document order: the cover (roman numbering counts it as i), the body's first words (arabic from
  -- 1), each heading with the words after it, and each authority key with the words after it
  need("S:cover", table.concat(COURT, " "))
  need("S:body", stringify(blocks[1]):sub(1, 60))
  local entries, h_n = {}, 0
  for i, b in ipairs(blocks) do
    local text = stringify(b)
    if b.t == "Header" then
      h_n = h_n + 1
      b.identifier = "H:" .. h_n
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      need(b.identifier, text, nxt)
      if b.level <= 3 then entries[#entries + 1] = { id = b.identifier, level = b.level, title = b.content } end
    end
    if b.t == "BulletList" or b.t == "OrderedList" or b.t == "BlockQuote" then
      pandoc.Pandoc({ b }):walk({ Plain = function(x) scan_keys(stringify(x)) end,
        Para = function(x) scan_keys(stringify(x)) end })
    else
      scan_keys(text)
    end
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tlower-roman\t"
  nl[#nl + 1] = "#section\tS:body\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))

  blocks = blocks:walk({ Str = breaks })
  local out = cover(meta)
  out[#out + 1] = section_end("rIdFtrNone")
  for _, x in ipairs(contents(entries)) do out[#out + 1] = x end
  for _, x in ipairs(authorities(meta)) do out[#out + 1] = x end
  out[#out + 1] = section_end("rIdFtrPage", "lowerRoman", 2)

  for i, b in ipairs(blocks) do
    local first = i == 1
    if i == sig_at then
      for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
    end
    if b.t == "Header" then
      out[#out + 1] = heading(b, first)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("txnd-motion-brief.lua: a list item holds one paragraph")
        end
        local lab = b.t == "OrderedList" and ((b.listAttributes.start + j - 1) .. ".") or "\u{2022}"
        out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
          { line = BODY, left = 2 * INDENT, hanging = INDENT })
      end
    elseif b.t == "BlockQuote" then
      for j, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT,
          before = (j == 1 and not first) and Q_ABOVE or 0, after = j == #b.content and Q_BELOW or 0 })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      -- the paragraph before the signature block stays whole with it (typst: a sticky, unbreakable block)
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = i == sig_at - 1 })
    else
      error("txnd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  if sig_at > #blocks then
    for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
