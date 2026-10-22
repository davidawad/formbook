-- C.D. Cal. motion (notice of motion, memorandum, certificate), docx engine (docs/DOCX.md): what the Word output adds
-- to pandoc's conversion, so that it reads and breaks as typst/cacd-motion-brief.typ does (see ../README.md):
--   pleading paper (L.R. 11-3.2: 27 numbered lines of 24 pt, the numbers in a page-anchored frame of the footer, the
--   rules as page borders);
--   cover (counsel from line 1, court title, caption with hearing details; no page number);
--   notice of motion (arabic from 1), signature block;
--   table of contents and table of authorities (roman from i; built from the headings and the toa: links);
--   memorandum (arabic from 1): headings numbered I., A., ... by the filter, double-spaced body, signature block;
--   certificate of compliance on its own page (L.R. 11-6.2).
-- Every case word comes from the sample's frontmatter or body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered lines, 320 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle:
-- the contents' page of each heading, and the authorities' pages of each `toa:` link. Four sections: the cover (no
-- number), the notice (arabic from 1), the tables (roman from i) and the memorandum with the certificate (arabic
-- from 1; FORMBOOK_FINAL); their footers (FORMBOOK_FOOTERS) carry the line numbers, and but for the cover's the
-- page number, the paper's title and the case number. Word may paginate slightly differently from LibreOffice.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE, GAP = 480, 320, 320                -- typst pitch, pitch-single, gap
local DROP = 128                                       -- typst single-drop, 6.4 pt: a single group's top below a numbered line's
local LINES = 27                                       -- typst lines-per-page
local TOP, LEFT = 1440, 2160                           -- typst top-margin, left-margin
local INDENT, TAB, LABEL = 720, 720, 576               -- typst para-indent, heading-tab, list-label
local TEXTW = 8640                                     -- 6 in
local CAP_LEFT, CAP_INSET, CAP_FOOT = 3888, 200, 160   -- typst caption-left 2.7 in, caption-inset 10 pt, caption-foot 8 pt
local CAP_RIGHT = 432                                  -- typst caption-right 0.3 in
local SIG_LEFT, SIG_GUTTER = 3744, 288                 -- typst signature-left 2.6 in, signature-gutter 0.2 in
local COUNSEL = 7                                      -- typst counsel-lines
local FOOT, FOOT_CASE = 20, 3600                       -- typst footer-size 10 pt (half points), footer-case 2.5 in
local TOC_COL, TOA_COL, TOA_HANG = 720, 1440, 504      -- typst toc-col 0.5 in, toa-col 1 in, toa-hang 0.35 in
local PASSIM = 7                                       -- typst passim-threshold
local NEEDLE_MAX = 60

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

local function upper(m)
  return pandoc.text.upper(plain(m))
end

local function list(m)
  local out = {}
  for _, v in ipairs(m or {}) do out[#out + 1] = v end
  return out
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tabs, jc, keep, brk, frame, sz }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.frame then props[#props + 1] = o.frame end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.sz then
    props[#props + 1] = '<w:rPr><w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/></w:rPr>'
  end
  return xe.para(props, body)
end

local function tabs(list_)
  local x = {}
  for _, t in ipairs(list_) do
    x[#x + 1] = '<w:tab w:val="' .. t[1] .. '"' .. (t[3] and (' w:leader="' .. t[3] .. '"') or "") ..
      ' w:pos="' .. t[2] .. '"/>'
  end
  return "<w:tabs>" .. table.concat(x) .. "</w:tabs>"
end

-- A one-row table: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells, trpr)
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
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function mar(o)
  local x = {}
  for _, k in ipairs({ "top", "left", "bottom", "right" }) do
    if o[k] then x[#x + 1] = '<w:' .. k .. ' w:w="' .. o[k] .. '" w:type="dxa"/>' end
  end
  return "<w:tcMar>" .. table.concat(x) .. "</w:tcMar>"
end

-- ---------------------------------------------------------------------------
-- Page furniture: the footers (the line numbers in a frame at the left margin, on the body's line boxes; but on
-- the cover the page number, the paper's title and the case number) and the sections (letter, the typst margins,
-- the pleading rules: a double rule left of the text, a single rule right of it).
-- ---------------------------------------------------------------------------

local function line_numbers()
  local out = {}
  local frame = '<w:framePr w:w="' .. (LEFT - INDENT) .. '" w:h="' .. (LINES * BODY) .. '" w:hRule="exact" ' ..
    'w:wrap="notBeside" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="' .. TOP .. '"/>'
  for i = 1, LINES do out[#out + 1] = p(xe.runs(tostring(i)), { line = BODY, jc = "right", frame = frame }) end
  return table.concat(out)
end

local function footer(meta)
  local f = { sz = FOOT }
  local r = '<w:r><w:rPr><w:sz w:val="' .. FOOT .. '"/></w:rPr>'
  local num = p(r .. '<w:fldChar w:fldCharType="begin"/></w:r>' .. r ..
    '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' .. r .. '<w:fldChar w:fldCharType="separate"/></w:r>' ..
    xe.runs("1", f) .. r .. '<w:fldChar w:fldCharType="end"/></w:r>', { line = 240, after = 80, jc = "center", sz = FOOT })
  local case = "CASE NO. " .. plain(meta.case_number)
  return line_numbers() .. num .. tbl({ TEXTW - FOOT_CASE, FOOT_CASE }, {
    { body = { p(xe.runs(upper(meta.footer_title), f), { line = 240, sz = FOOT }) } },
    { body = { p(xe.runs(case, f), { line = 240, jc = "right", sz = FOOT }) } },
  }) .. p("", { line = 20 })
end

local function sect_pr(footer_id, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer_id .. '"/>' ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" ' ..
    'w:header="720" w:footer="500" w:gutter="0"/><w:pgBorders w:offsetFrom="text">' ..
    '<w:left w:val="double" w:sz="4" w:space="14" w:color="auto"/><w:right w:val="single" w:sz="4" w:space="7" ' ..
    'w:color="auto"/></w:pgBorders>' .. pg .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line).
local function section_end(footer_id, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' ..
    sect_pr(footer_id, fmt) .. '</w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context, fallback)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  if fallback then short = norm(fallback) end
  needles[#needles + 1] = table.concat({ id, "B", long, short:sub(1, NEEDLE_MAX) }, "\t")
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

-- ---------------------------------------------------------------------------
-- Cover: counsel (lines 1-7 at least, single spaced), court title, caption with the hearing details
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local counsel = list(meta.counsel)
  -- the counsel lines start single-drop below the top margin (an empty paragraph of that height)
  out[#out + 1] = p("", { line = DROP })
  for _, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l)) end
  -- the court title starts on the numbered line after the counsel block (at least line 8)
  local n = math.max(COUNSEL, math.ceil((DROP + #counsel * SINGLE) / BODY))
  local title = { "UNITED STATES DISTRICT COURT", "CENTRAL DISTRICT OF CALIFORNIA" }
  if meta.division then title[#title + 1] = upper(meta.division) end
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center",
      before = i == 1 and (n * BODY - DROP - #counsel * SINGLE) or 0, after = i == #title and BODY or 0 })
  end
  -- the party column: each party's names, then its designation; "v." between the parties
  local left = {}
  for k, party in ipairs(meta.caption) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, l in ipairs(list(party.names)) do left[#left + 1] = p(xe.inl(l)) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local right = { p(xe.runs("Case No. " .. plain(meta.case_number))),
    p(xe.inl(meta.brief_title, { b = true }), { before = GAP }) }
  local first = true
  for _, k in ipairs({ { "date", "Date:" }, { "time", "Time:" }, { "place", "Courtroom:" }, { "judge", "Judge:" } }) do
    local v = meta.hearing[k[1]]
    if v then
      right[#right + 1] = p(xe.runs(k[2] .. " ") .. xe.inl(v), { before = first and GAP or 0 })
      first = false
    end
  end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
      '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
      mar({ top = DROP, bottom = CAP_FOOT, right = CAP_INSET }), body = left },
    { pr = mar({ top = DROP, left = CAP_RIGHT }), body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: a numbered line below the text (the paragraph before it has that space after it and is kept
-- with it); dated at the left; the firm and signer in the right column; the row never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(list(sig.firm)) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and GAP or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = GAP })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, {
    { pr = mar({ top = DROP }), body = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) } },
    { pr = mar({ top = DROP, left = SIG_GUTTER }), body = right },
  }, '<w:trPr><w:cantSplit/></w:trPr>')
end

-- The last paragraph before a signature block: kept whole with it, a numbered line of space after it.
local function before_signature(x)
  x = x:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1)
  return (x:gsub('w:after="0"', 'w:after="' .. BODY .. '"', 1))
end

-- ---------------------------------------------------------------------------
-- Headings, tables of contents and authorities
-- ---------------------------------------------------------------------------

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }

-- typst heading-num: level 2 "I.", 3 "A.", 4 "1.", 5 "a."
local function heading_label(level, k)
  if level == 2 then return (ROMAN[k] or tostring(k)) .. "." end
  if level == 3 then return string.char(64 + k) .. "." end
  if level == 4 then return k .. "." end
  if level == 5 then return string.char(96 + k) .. "." end
  return ""
end

-- A centered bold title in capitals at the body pitch (the tables, the certificate), kept with what follows.
local function title(t, brk)
  return p(xe.runs(pandoc.text.upper(t), { b = true }), { line = BODY, jc = "center", keep = true, brk = brk })
end

local function page_head(t)
  return p(xe.runs(t, { b = true }), { line = BODY, jc = "right", keep = true })
end

-- A heading of the memorandum at the body pitch, bold: the label in a box of half an inch, the lines after the first
-- hanging after it, each level half an inch further in; kept with the text.
local function heading(label, level, content)
  local ind = (level - 2) * TAB
  return p(xe.runs(label .. "\t", { b = true }) .. xe.inl(content, { b = true }), { line = BODY, keep = true,
    left = ind + TAB, hanging = TAB, tabs = tabs({ { "left", ind + TAB } }) })
end

-- A row of a table: the text hanging by `hang` from `left0`, a leader to the page column `col`.
local function row(text, page, left0, hang, col, extra_tab)
  local t = { { "right", TEXTW, "dot" } }
  if extra_tab then table.insert(t, 1, { "left", extra_tab }) end
  return p(text .. xe.runs(xe.LEAD) .. page, { line = BODY, left = left0 + hang, hanging = hang, right = col,
    tabs = tabs(t), keep = false })
end

local function contents(entries)
  local out = { title("Table of Contents"), page_head("Page") }
  for _, e in ipairs(entries) do
    local ind = (e.level - 2) * TAB
    out[#out + 1] = row(xe.runs(e.label .. "\t") .. xe.inl(e.content), xe.runs(labels[e.id] or "0"), ind, TAB,
      TOC_COL, ind + TAB)
  end
  return out
end

local GROUPS = { { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" }, { "other", "Other Authorities" } }

local function authorities(meta, hits)
  local out = { title("Table of Authorities", true), page_head("Page(s)") }
  local first = true
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(meta.authorities or {}) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    local function sort_key(m) return plain(m.a.name or m.a.cite):lower() end
    table.sort(members, function(x, y) return sort_key(x) < sort_key(y) end)
    if #members > 0 then
      out[#out + 1] = p(xe.runs(g[2], { b = true }), { line = BODY, keep = true, before = first and 0 or BODY })
      first = false
      for _, m in ipairs(members) do
        local pages, seen = {}, {}
        for _, id in ipairs(hits[m.key]) do
          local l = labels[id] or "0"
          if not seen[l] then
            seen[l] = true
            pages[#pages + 1] = l
          end
        end
        local where = #pages >= PASSIM and xe.runs("passim", { i = true }) or xe.runs(table.concat(pages, ", "))
        local text = ""
        if m.a.name then text = xe.inl(m.a.name, { i = g[1] == "case" }) .. xe.runs(", ") end
        out[#out + 1] = row(text .. xe.inl(m.a.cite), where, 0, TOA_HANG, TOA_COL)
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
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

local function body_par(inlines)
  return p(xe.inl(inlines), { line = BODY, first = INDENT })
end

local function items(b, out)
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  for _, item in ipairs(b.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("cacd-motion-brief.lua: a list item holds one paragraph")
    end
    local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content), { line = BODY, left = INDENT + LABEL,
      hanging = LABEL, tabs = tabs({ { "left", INDENT + LABEL } }) })
    n = n + 1
  end
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Inlines = bind_double_signs })
  local blocks = doc.blocks

  -- the needles, in document order: the notice (arabic from 1), the contents (roman from i), each heading of the
  -- memorandum with its label and the words after it (the first one starts arabic from 1), each toa: link
  local notice = list(meta.notice)
  need("S:notice", meta.notice_to and plain(meta.notice_to) or "", plain(notice[1]))
  need("S:toc", "TABLE OF CONTENTS Page")
  local entries, hits = {}, {}
  local counts, h_n, k_n = { 0, 0, 0, 0, 0 }, 0, 0
  local labels_of = {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = math.min(b.level, 5)
      counts[lv] = counts[lv] + 1
      for j = lv + 1, 5 do counts[j] = 0 end
      h_n = h_n + 1
      local id = "H:" .. h_n
      local label = heading_label(lv, counts[lv])
      labels_of[i] = label
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 30) or ""
      -- pdftotext reads a heading's text in place when it stands at the label column's step (level 2), else
      -- (its text alone at its indent) after the paragraph below it, but its label in place: the fallback is the
      -- label and the heading, or the label and the words after the heading
      need(id, label .. " " .. stringify(b.content), nxt, label .. " " .. (lv == 2 and stringify(b.content) or nxt))
      if b.level <= 4 then entries[#entries + 1] = { id = id, level = lv, label = label, content = b.content } end
    end
    pandoc.Pandoc({ b }):walk({ Link = function(l)
      local key = l.target:match("^toa:(.+)$")
      if key then
        k_n = k_n + 1
        local id = "K:" .. k_n
        hits[key] = hits[key] or {}
        hits[key][#hits[key] + 1] = id
        need(id, stringify(l.content), "")
      end
    end })
  end
  local nl = needles
  nl[#nl + 1] = "#section\tS:notice\tdecimal\t"
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tH:1\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdCacdCover\t" .. line_numbers() .. p("", { line = 20 }) .. "\nrIdCacdPage\t" ..
    footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdCacdPage", "decimal"))

  blocks = blocks:walk({ Str = breaks })
  local out = cover(meta)
  out[#out + 1] = section_end("rIdCacdCover")

  -- the notice of motion
  local np = {}
  if meta.notice_to then np[#np + 1] = p(xe.inl(meta.notice_to), { line = BODY }) end
  for _, x in ipairs(notice) do np[#np + 1] = body_par(x) end
  np[#np] = before_signature(np[#np])
  for _, x in ipairs(np) do out[#out + 1] = x end
  out[#out + 1] = signature(meta)
  out[#out + 1] = section_end("rIdCacdPage", "decimal")

  -- the tables
  for _, x in ipairs(contents(entries)) do out[#out + 1] = x end
  for _, x in ipairs(authorities(meta, hits)) do out[#out + 1] = x end
  out[#out + 1] = section_end("rIdCacdPage", "lowerRoman")

  -- the memorandum, its last block kept with the signature block
  for i, b in ipairs(blocks) do
    local start = #out + 1
    if b.t == "Header" then
      out[#out + 1] = heading(labels_of[i], math.min(b.level, 5), b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content)
    else
      error("cacd-motion-brief.lua: unsupported block " .. b.t)
    end
    if i == #blocks then
      for j = start, #out - 1 do out[j] = out[j]:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1) end
      out[#out] = before_signature(out[#out])
    end
  end
  out[#out + 1] = signature(meta)

  -- the certificate of compliance, on its own page
  out[#out + 1] = title("Certificate of Compliance", true)
  out[#out + 1] = before_signature(p(xe.runs("The undersigned, counsel of record for ") ..
    xe.inl(meta.certificate_party) .. xe.runs(", certifies that this brief contains " .. plain(meta.word_count) ..
    " words, which complies with the word limit of L.R. 11-6.1."), { line = BODY, first = INDENT }))
  out[#out + 1] = signature(meta)

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
