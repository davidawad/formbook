-- gactapp-motion.lua (docx engine): the Court of Appeals of Georgia motion as Word paragraphs, so that it reads and
-- breaks as ../typst/gactapp-motion-brief.typ (the reference for the form) does:
--   * the cover, on a page of its own unless `cover_page: false`: court, case number, caption (each party's name centered, its designation from
--     the middle of the line), the lower court, the title, and counsel (a group without lines centered, the others
--     two to a row in half-width columns);
--   * the table of contents (`toc: true`) and the table of authorities (`authorities:`), each row the text wrapping
--     before a page column, a dot leader to the page; the pages come from fb render's passes (needles, below);
--   * the body: headings (level 1 centered capitals, levels 2 and 3 with wrapped lines hanging half an inch),
--     paragraphs, quotations, lists and footnotes written by pandoc in the styles of docx/reference.xml;
--   * the Rule 24 (f) (1) certification, the date line and the signature (Rule 2 (a) (2) (ii)), kept together;
--   * the certificate of service (Rule 6) on a page of its own, the last addressee kept with the closing and the
--     signer's lines.
-- Every case word comes from the YAML frontmatter or the body. No coordinates, no forced line breaks.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs): the filter writes a
-- needle for the cover (where the decimal numbering starts: the cover is page 1, Rule 24 (e)), for every heading
-- (its text and the words after it) and for every occurrence of an authority's `find` text in the body and the
-- footnotes (the words from there on), and reads the pages of the previous pass from FORMBOOK_PAGES. The typst
-- template marks the same occurrences. The footer (a centered PAGE field in a single line) and the last section go
-- to FORMBOOK_FOOTERS and FORMBOOK_FINAL.

local xe = require("docx.xengine")

local BODY, SINGLE, HALF = 644, 322, 161 -- typst pitch-body, pitch-single, half
local TEXTW = 9360                       -- 6.5 in
local INDENT = 720                       -- typst para-indent
local ROLE = 4680                        -- typst role-indent 3.25 in
local TITLE_INSET = 702                  -- typst title-inset 0.4875 in
local SIG = 3600                         -- typst sig-indent 2.5 in
local GUTTER = 360                       -- typst counsel-gutter 0.25 in
local RECIP = 1440                       -- typst recipient-indent 1 in
local TOC_HANG, TOA_HANG = 720, 420      -- typst toc-hang 0.5 in, toa-hang 21 pt
local TOC_COL, TOA_COL = 720, 1120       -- typst toc-col 36 pt, toa-col 56 pt
local TOC_DEPTH = 3
local SIZE = 14                          -- pt
local NEEDLE_MAX = 60
-- The three spaces before a leader tab: LibreOffice moves a row's last word to a new line unless about 4.5 pt more
-- than typst's 0.75 em are free before the page column, so the spaces are set in 8 pt (6 pt, 10.5 less 4.5; as the
-- Fourth Circuit briefs); the tab follows.
local function lead(pg)
  return xe.runs("\u{00A0}\u{00A0}\u{00A0}", { sz = 16 }) .. xe.runs("\t" .. pg)
end
local WORD_COUNT_TEXT = "This submission does not exceed the word count limit imposed by Rule 24."

local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdPageFtr"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="686" w:gutter="0"/>'
  .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

local function fail(msg) error("gactapp-motion.lua: " .. msg, 0) end

-- ---------------------------------------------------------------------------
-- The frontmatter as written (FORMBOOK_META), inline markdown read as the typst template's cmarker reads it
-- ---------------------------------------------------------------------------

local function read_meta()
  local path = os.getenv("FORMBOOK_META")
  if not path or path == "" then fail("FORMBOOK_META is not set (render with fb render)") end
  local f = assert(io.open(path, "r"))
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false)
end

local function list(v)
  local out = {}
  if type(v) == "table" then for _, x in ipairs(v) do out[#out + 1] = x end end
  return out
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash between a letter or digit and a letter ("CM/ECF": a zero-width space; none in "/s/"). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("(%w)/(%a)", "%1/\u{200B}%2")))
end

-- A doubled sign stays with its number ("§§ 21-2-501(a)(1)": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- typst's break rules on inlines that xe.inl writes (it binds a hyphen before a digit and a single sign itself)
local function fix(inlines)
  return bind_doubled(pandoc.Inlines(inlines):walk({ Str = breaks }))
end

-- pandoc inlines after xe.inlines: its no-break hyphens (raw runs) as hyphens again, for xe.inl and for the text
local function unraw(inlines)
  return pandoc.Inlines(inlines):walk({ RawInline = function(r)
    if r.text:find("noBreakHyphen", 1, true) then return pandoc.Str("-") end
  end })
end

-- A frontmatter string as inlines (inline markdown, smart punctuation).
local function md(s)
  if s == nil then return pandoc.Inlines({}) end
  s = tostring(s)
  if s == "" then return pandoc.Inlines({}) end
  local blocks = pandoc.read(s, "markdown+smart").blocks
  if #blocks == 1 and (blocks[1].t == "Para" or blocks[1].t == "Plain") then return fix(blocks[1].content) end
  return fix(pandoc.Inlines({ pandoc.Str(s) }))
end

local function upper_inl(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- ---------------------------------------------------------------------------
-- Paragraphs
-- ---------------------------------------------------------------------------

-- o = { before, after, line, left, right, first, hanging, jc, keep, lines, brk, tabs, style }
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = "<w:keepNext/>" end
  if o.keep or o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = nil
  if not o.hanging then first = o.first or 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. "</w:tc>"
end

local function tbl(widths, rows)
  local grid = {}
  for i, w in ipairs(widths) do grid[i] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>'
    .. "<w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid>" .. table.concat(rows) .. "</w:tbl>"
end

-- ---------------------------------------------------------------------------
-- Needles and pages
-- ---------------------------------------------------------------------------

local function letters(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need_at(id, kind, text, context)
  local w1, w2 = text:match("^%s*(%S+)%s+(%S+)")
  local short = letters(w1 and (w1 .. " " .. w2) or text):sub(1, NEEDLE_MAX)
  local long = letters(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = lab end
  end
  f:close()
end

local function label_of(id)
  return labels[id] or "0"
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The text of inlines as the PDF shows it: a footnote is its number (a superscript in the line); `notes` collects
-- each note's blocks with its number, in document order.
local note_no = 0
local function plain(inlines, notes)
  local out = {}
  for _, el in ipairs(inlines) do
    local t = el.t
    if t == "Str" then out[#out + 1] = el.text
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then out[#out + 1] = " "
    elseif t == "Note" then
      note_no = note_no + 1
      out[#out + 1] = tostring(note_no)
      if notes then notes[#notes + 1] = { n = note_no, blocks = el.content } end
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = q[1] .. plain(el.content, notes) .. q[2]
    elseif el.content and type(el.content) ~= "string" then out[#out + 1] = plain(el.content, notes)
    elseif t == "Code" or t == "Math" then out[#out + 1] = el.text
    elseif t == "RawInline" and el.text:find("noBreakHyphen", 1, true) then out[#out + 1] = "-"
    end
  end
  return (table.concat(out):gsub("\u{00A0}", " "))
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

-- own: the cover on a page of its own (`cover_page`, default true); without it no counsel, the text starting a double
-- line below the title
local function cover(m, out, own)
  local court = pandoc.text.upper(tostring(m.court or fail("missing frontmatter field `court`")))
  out[#out + 1] = p(xe.runs(court, { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("Case No. " .. tostring(m.case_number or fail("missing `case_number`")), { b = true }),
    { before = SINGLE, jc = "center" })
  for i, party in ipairs(list(m.parties)) do
    out[#out + 1] = p(xe.inl(md(party.name)), { before = i == 1 and BODY or SINGLE, jc = "center" })
    if tostring(party.role or "") ~= "" then
      out[#out + 1] = p(xe.inl(md(party.role), { i = true }), { left = ROLE })
    end
  end
  if m.lower_court_case then
    out[#out + 1] = p(xe.inl(md(m.lower_court_case)), { before = SINGLE, jc = "center" })
  end
  out[#out + 1] = p(xe.inl(upper_inl(md(m.title)), { b = true }),
    { before = BODY, after = own and 0 or BODY, left = TITLE_INSET, right = TITLE_INSET, jc = "center" })
  if not own then return end
  -- counsel: a group without lines centered; the others two to a row (a table row kept whole)
  local colw = (TEXTW - GUTTER) // 2
  local pending, above = {}, BODY
  local function column(g)
    local x = {}
    for _, n in ipairs(list(g.names)) do x[#x + 1] = p(xe.inl(md(n), { b = true })) end
    for _, l in ipairs(list(g.lines)) do x[#x + 1] = p(xe.inl(md(l))) end
    return table.concat(x)
  end
  local function flush()
    -- Word sets no space after a table and none before one: an empty line box of the gap stands above the row
    out[#out + 1] = p("", { line = above })
    local right = pending[2] and column(pending[2]) or p("")
    out[#out + 1] = tbl({ colw, GUTTER, colw }, { '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(colw, column(pending[1]))
      .. tc(GUTTER, p("")) .. tc(colw, right) .. "</w:tr>" })
    pending, above = {}, SINGLE
  end
  for _, g in ipairs(list(m.counsel)) do
    if #list(g.lines) == 0 then
      if #pending > 0 then flush() end
      for _, n in ipairs(list(g.names)) do
        out[#out + 1] = p(xe.inl(md(n)), { before = above, jc = "center" })
        above = 0
      end
      above = SINGLE
    else
      pending[#pending + 1] = g
      if #pending == 2 then flush() end
    end
  end
  if #pending > 0 then flush() end
end

-- ---------------------------------------------------------------------------
-- Signature and certificate of service
-- ---------------------------------------------------------------------------

local function signature_rows(sig, short)
  local rows = { xe.inl(md(sig.signer_line or fail("missing `signature.signer_line`")), { u = true }) }
  if sig.name then rows[#rows + 1] = xe.inl(md(sig.name)) end
  local rest = list(sig.signer)
  for i, l in ipairs(rest) do
    if short and i > 1 then break end
    rows[#rows + 1] = xe.inl(md(l))
  end
  return rows
end

-- Paragraphs kept together on one page (typst: an unbreakable block).
local function together(paras, out)
  for i, x in ipairs(paras) do
    if i < #paras then x = x:gsub("<w:pPr>", "<w:pPr><w:keepNext/>", 1) end
    x = x:gsub("<w:pPr>", "<w:pPr>" .. xe.LINES, 1)
    out[#out + 1] = x
  end
end

local function signature(m, out)
  local sig = m.signature or fail("missing `signature`")
  local paras = { p(xe.runs(WORD_COUNT_TEXT), { before = HALF, line = BODY, first = INDENT }) }
  if sig.date then
    local il = pandoc.Inlines({ pandoc.Str("Respectfully"), pandoc.Space(), pandoc.Str("submitted"), pandoc.Space(),
      pandoc.Str("this"), pandoc.Space() })
    il:extend(md(sig.date))
    il:insert(pandoc.Str("."))
    paras[#paras + 1] = p(xe.inl(il), { line = BODY, first = INDENT })
  end
  for i, l in ipairs(list(sig.lines)) do
    paras[#paras + 1] = p(xe.inl(md(l)), { before = i == 1 and SINGLE or 0, left = SIG })
  end
  for i, r in ipairs(signature_rows(sig)) do
    paras[#paras + 1] = p(r, { before = i == 1 and SINGLE or 0, left = SIG })
  end
  together(paras, out)
end

local function certificate(m, out)
  local svc = m.service or fail("missing `service`")
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE"), { style = "Head1", brk = true, before = 0, after = HALF,
    jc = "center", keep = true })
  if svc.paragraphs then
    for _, x in ipairs(list(svc.paragraphs)) do out[#out + 1] = p(xe.inl(md(x)), { line = BODY, first = INDENT }) end
  else
    out[#out + 1] = p(xe.inl(md("I certify that on " .. tostring(svc.date) .. ", I served a copy of this "
      .. tostring(svc.doc_type) .. " on " .. tostring(svc.served_on) .. " by " .. tostring(svc.method)
      .. ", addressed as follows:")), { line = BODY, first = INDENT })
  end
  local recips = svc.recipients and list(svc.recipients) or { list(svc.address) }
  local function addressee(r)
    local x = {}
    for j, l in ipairs(list(r)) do x[#x + 1] = p(xe.inl(md(l)), { before = j == 1 and SINGLE or 0, left = RECIP }) end
    return x
  end
  for k = 1, #recips - 1 do together(addressee(recips[k]), out) end
  local last = #recips > 0 and addressee(recips[#recips]) or {}
  if svc.closing then last[#last + 1] = p(xe.inl(md(svc.closing)), { before = SINGLE, line = BODY, first = INDENT }) end
  for i, r in ipairs(signature_rows(m.signature, true)) do
    last[#last + 1] = p(r, { before = i == 1 and SINGLE or 0, left = SIG })
  end
  together(last, out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- a heading in the table of contents: its text without footnotes
local function nonotes(il)
  return pandoc.Inlines(il):walk({ Note = function() return {} end })
end

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function div(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- pandoc reads "(1) The ..." in a quotation as a list item; typst (cmarker) reads a paragraph that starts with it.
local function unlist(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" and b.listAttributes.delimiter == "TwoParens" then
      local n = b.listAttributes.start
      for _, item in ipairs(b.content) do
        local first = true
        for _, x in ipairs(item) do
          if first and (x.t == "Para" or x.t == "Plain") then
            local il = pandoc.Inlines({ pandoc.Str("(" .. n .. ")"), pandoc.Space() })
            il:extend(x.content)
            out[#out + 1] = pandoc.Para(il)
          else
            out[#out + 1] = x
          end
          first = false
        end
        n = n + 1
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- every text unit of a block (a paragraph, a heading, a list item's paragraph), in order
local function units(b, acc)
  if b.t == "Para" or b.t == "Plain" or b.t == "Header" then acc[#acc + 1] = b.content
  elseif b.t == "BlockQuote" or b.t == "Div" then for _, x in ipairs(b.content) do units(x, acc) end
  elseif b.t == "OrderedList" or b.t == "BulletList" then
    for _, item in ipairs(b.content) do for _, x in ipairs(item) do units(x, acc) end end
  end
  return acc
end

function Pandoc(doc)
  load_pages()
  local m = read_meta()
  local blocks = unlist(doc.blocks)
  blocks = pandoc.Blocks(blocks):walk({ BlockQuote = function(q) q.content = unlist(q.content); return q end })
  blocks = blocks:walk({ Inlines = function(il) return xe.inlines(bind_doubled(il)) end })

  -- the authorities: { group, entries = { cite, find } }
  local keys = {}
  for _, g in ipairs(list(m.authorities)) do
    for _, e in ipairs(list(g.entries)) do
      if e.find then keys[#keys + 1] = tostring(e.find) end
    end
  end
  local hits = {}   -- find text -> needle ids

  -- the occurrences of the authorities' find texts in one text unit, as needles in order
  local function cite_needles(s, kind, prefix)
    local found = {}
    for ki, key in ipairs(keys) do
      local from = 1
      while true do
        local a = s:find(key, from, true)
        if not a then break end
        found[#found + 1] = { pos = a, key = key, ki = ki }
        from = a + #key
      end
    end
    table.sort(found, function(x, y) return x.pos < y.pos or (x.pos == y.pos and x.ki < y.ki) end)
    for k, f in ipairs(found) do
      local id = "A:" .. prefix .. ":" .. k
      need_at(id, kind, s:sub(f.pos), "")
      hits[f.key] = hits[f.key] or {}
      table.insert(hits[f.key], id)
    end
  end

  -- needles: the cover, the table of authorities' title, the headings and citations of the body, the certificate
  need_at("S:cover", "B", tostring(m.court) .. " Case No", "")
  local first_group = ""
  local auth = list(m.authorities)
  if #auth > 0 then
    local e1 = list(auth[1].entries)[1]
    first_group = tostring(auth[1].heading) .. " " .. (e1 and plain(md(e1.cite)) or "")
  end
  local heads = {}  -- { id, level, content }
  if #auth > 0 then
    heads[#heads + 1] = { id = "H:toa", level = 1, content = pandoc.Inlines({ pandoc.Str("Table"), pandoc.Space(),
      pandoc.Str("of"), pandoc.Space(), pandoc.Str("Authorities") }) }
    need_at("H:toa", "B", "Table of Authorities", first_group)
  end
  note_no = 0
  local texts = {}
  for bi, b in ipairs(blocks) do
    local notes = {}
    local us = units(b, {})
    local ss = {}
    for ui, u in ipairs(us) do ss[ui] = plain(u, notes) end
    texts[bi] = { ss = ss, notes = notes }
  end
  local function next_text(bi)
    local t = texts[bi + 1]
    return t and table.concat(t.ss, " ") or ""
  end
  for bi, b in ipairs(blocks) do
    local t = texts[bi]
    if b.t == "Header" then
      local id = "H:" .. bi
      if b.level <= TOC_DEPTH then heads[#heads + 1] = { id = id, level = b.level, content = b.content } end
      need_at(id, "B", t.ss[1], next_text(bi))
    end
    for ui, s in ipairs(t.ss) do cite_needles(s, "B", bi .. "." .. ui) end
    for _, nt in ipairs(t.notes) do
      local ns = {}
      for _, x in ipairs(nt.blocks) do for _, u in ipairs(units(x, {})) do ns[#ns + 1] = plain(u) end end
      for ui, s in ipairs(ns) do cite_needles(s, "N", "n" .. nt.n .. "." .. ui) end
    end
  end
  heads[#heads + 1] = { id = "H:cos", level = 1, content = pandoc.Inlines({ pandoc.Str("Certificate"), pandoc.Space(),
    pandoc.Str("of"), pandoc.Space(), pandoc.Str("Service") }) }
  local svc = m.service or {}
  need_at("H:cos", "B", "CERTIFICATE OF SERVICE", svc.paragraphs and plain(md(list(svc.paragraphs)[1]))
    or ("I certify that on " .. tostring(svc.date)))

  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:cover\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdPageFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", SECT)

  -- the document
  local raw = {}
  local own = m.cover_page ~= false
  cover(m, raw, own)
  local out = {}
  local function flush_raw()
    for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
    raw = {}
  end
  if m.toc then
    raw[#raw + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { brk = own, after = SINGLE, jc = "center" })
    for i, h in ipairs(heads) do
      local ind = (h.level - 1) * TOC_HANG
      raw[#raw + 1] = p(xe.inl(fix(nonotes(unraw(h.content)))) .. lead(label_of(h.id)), {
        before = i == 1 and 0 or HALF, left = ind + TOC_HANG, hanging = TOC_HANG, right = TOC_COL, lines = true,
        tabs = xe.leader_tab(TEXTW) })
    end
  end
  if #auth > 0 then
    raw[#raw + 1] = p(xe.runs("TABLE OF AUTHORITIES"), { style = "Head1", brk = own or m.toc == true, before = (own or m.toc) and 0 or SINGLE, after = HALF,
      jc = "center", keep = true })
    for _, g in ipairs(auth) do
      raw[#raw + 1] = p(xe.inl(md(g.heading), { b = true }), { before = SINGLE, after = HALF, keep = true })
      for _, e in ipairs(list(g.entries)) do
        local pg
        if e.find then
          local seen, ps = {}, {}
          for _, id in ipairs(hits[tostring(e.find)] or {}) do
            local lab = label_of(id)
            if not seen[lab] then seen[lab] = true; ps[#ps + 1] = lab end
          end
          table.sort(ps, function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end)
          pg = #ps == 0 and "--" or table.concat(ps, ", ")
        else
          pg = tostring(e.pages or "")
        end
        -- the page column: 56 pt, or the page list's width when wider (Times New Roman: a digit 1/2 em, a comma
        -- and a space 1/4 em, a hyphen 682/2048 em), in whole twips as typst measures it
        local w = 0
        for c in pg:gmatch(".") do
          if c:match("%d") then w = w + 0.5 elseif c == "," or c == " " then w = w + 0.25
          elseif c == "-" then w = w + 682 / 2048 else w = w + 0.5 end
        end
        local col = math.max(TOA_COL, math.floor(w * SIZE * 20 + 0.5))
        raw[#raw + 1] = p(xe.inl(md(e.cite)) .. lead(pg), { before = HALF, left = TOA_HANG,
          hanging = TOA_HANG, right = col, lines = true, tabs = xe.leader_tab(TEXTW) })
      end
    end
  end
  flush_raw()

  -- the body: its first block opens a page (typst: pagebreak after the cover or the tables), in a style that breaks
  -- the page before it with no space above (Word would keep it after the break, typst drops it at the top of a page)
  local first = own or m.toc == true or #auth > 0
  local function add(b)
    if first then
      first = false
      local st = b.t == "Div" and b.attr.attributes["custom-style"]
      if st ~= "Head 1" and st ~= "Body Text" and st ~= "Body Text Note" then fail("the body must start with a level-1 heading or a paragraph") end
      b.attr.attributes["custom-style"] = st .. " Page"
    end
    out[#out + 1] = b
  end
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local style = "Head" .. math.min(b.level, 3)
      local il = b.level == 1 and upper_inl(b.content) or b.content
      add(div(style == "Head1" and "Head 1" or style == "Head2" and "Head 2" or "Head 3", il))
    elseif b.t == "Para" or b.t == "Plain" then
      add(div(has_note(b.content) and "Body Text Note" or "Body Text", b.content))
    elseif b.t == "BlockQuote" then
      add(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- typst (cmarker) numbers every ordered list "1.", whatever the markdown's delimiter ("1)")
      if b.t == "OrderedList" then b.listAttributes.delimiter = "Period" end
      for _, x in ipairs(xe.list_items(b)) do add(x) end
    elseif b.t == "HorizontalRule" then
      -- nothing
    else
      fail("unsupported block " .. b.t)
    end
  end

  signature(m, raw)
  certificate(m, raw)
  flush_raw()
  return pandoc.Pandoc(out, pandoc.Meta({})):walk({ Str = breaks })
end
