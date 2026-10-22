-- S.D. Tex. complaint and motion brief, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion,
-- so that it reads and breaks as typst/txsd-*.typ does: the court title, the caption (box or section), the title,
-- numbered and lettered paragraphs, the signature block and (FORM.contents) the certificates and, when the sample
-- sets `toc: true`, a table of contents on its own page. Every case-specific word comes from the sample; the court's
-- fixed text (the court name, the certificate titles, "TABLE OF CONTENTS") is in this file, as it is in the typst
-- template. Caption and contents rows are OOXML tables and paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 520 the double-spaced body, 299 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers of the contents: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this
-- filter writes (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until
-- they settle. One section, numbered in arabic from the first page (FORMBOOK_FINAL and FORMBOOK_FOOTERS).

-- complaint: body paragraphs are numbered 1, 2, ... (Fed. R. Civ. P. 10(b)), no certificates or contents;
-- motion-brief: paragraphs are not numbered, certificates and the table of contents are set.
local FORM = { numbered = true, contents = false }

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 520, 299            -- typst pitch-double, pitch-single
local COVER_GAP, CAPTION_GAP = 350, 154  -- typst cover-gap, caption-gap
local SECTION_GAP = 193                  -- typst caption-section row-gutter, 9.65 pt
local SIG_ABOVE, SIG_BY_GAP = 175, 130   -- typst sig-above, sig-by-gap
local INDENT = 720                       -- typst para-indent, 0.5 in
local ITEM_LABEL, LETTER_LABEL = 1080, 1440 -- typst item-label 0.75 in, letter-label 1 in
local SIG_LEFT = 4680                    -- typst sig-left 3.25 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4752, 288   -- typst caption-left 3.3 in, caption-gutter 0.2 in
local CAP_INSET, CAP_RIGHT_INSET = 173, 144 -- typst caption-inset 0.12 in, caption-right-inset 0.1 in
local RULE = 15                         -- the 0.75 pt rule: LibreOffice sets it inside the cell, typst outside
local SEC_MID = 576                      -- typst caption-section middle column 0.4 in
local PNUM = 720                         -- typst toc-page-col 36 pt
local FOOTER = 709                       -- the footer line's foot above the page edge: typst footer-descent 30 %
local NEEDLE_MAX = 60

local LETTERS = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t" }
local UNNUMBERED = { ["PRAYER FOR RELIEF"] = true, ["JURY TRIAL DEMAND"] = true }
local CERTIFICATES = {
  { key = "word_count_certificate", title = "CERTIFICATE OF WORD COUNT" },
  { key = "certificate_of_conference", title = "CERTIFICATE OF CONFERENCE" },
  { key = "certificate_of_service", title = "CERTIFICATE OF SERVICE" },
}

-- ---------------------------------------------------------------------------
-- The sample's frontmatter, as written ($FORMBOOK_META)
-- ---------------------------------------------------------------------------

local function raw_meta()
  local path = os.getenv("FORMBOOK_META")
  if not path or path == "" then error("txsd.lua: FORMBOOK_META is not set (render with fb render)") end
  local f = assert(io.open(path, "r"))
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false) or {}
end

-- A frontmatter value as a string, or nil (null, absent, not a string).
local function str(v)
  if type(v) == "string" and v ~= "" then return v end
  return nil
end

-- A frontmatter string as inlines: its markdown read as typst's markdown reader reads it (no fancy list markers:
-- "(617) ..." is text); a line that still reads as a block of another kind is its text.
local function md(s)
  local b = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS).blocks[1]
  if b == nil then return pandoc.Inlines({}) end
  if b.t == "Para" or b.t == "Plain" then return b.content end
  return pandoc.Inlines({ pandoc.Str(s) })
end

-- ---------------------------------------------------------------------------
-- Break rules typst and LibreOffice do not share
-- ---------------------------------------------------------------------------

-- No break inside ")(" (a word joiner); one after a slash before a letter (a zero-width space). Neither shows in the
-- PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign or pilcrow ("¶¶ 5-7") stays with its number, as typst binds the last sign to it.
local function bind(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then inlines[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return inlines
end

local function fix(inlines)
  return bind(pandoc.Inlines(inlines):walk({ Str = breaks }))
end

-- ---------------------------------------------------------------------------
-- Paragraphs and tables
-- ---------------------------------------------------------------------------

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, tabs, jc, keep, next, lines, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.next then props[#props + 1] = "<w:keepNext/>"
  elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function inl(x, o)
  if type(x) == "string" then x = md(x) end
  return xe.inl(fix(x), o)
end

-- A table of fixed columns without borders or cell margins; rows = { { cell, ... }, ... }, a cell
-- { pr = tcPr children, body = { paragraph xml, ... } }.
local function tbl(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local trs = {}
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, w in ipairs(widths) do
      local c = cells[i] or {}
      local body = c.body and #c.body > 0 and table.concat(c.body) or p("")
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' .. body ..
        '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Court title and caption (Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function court_title(m)
  local lines = { "UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF TEXAS" }
  if str(m.division) then lines[#lines + 1] = pandoc.text.upper(m.division) end
  local out = {}
  for i, l in ipairs(lines) do
    -- the caption stands cover-gap below the court title (Word has no space before a table)
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #lines and COVER_GAP or 0 })
  end
  return out
end

-- Party lines: names flush left, the designation indented, "v." between parties (typst party-rows).
local function party_rows(parties)
  local rows = {}
  for k, party in ipairs(parties) do
    if k > 1 then rows[#rows + 1] = { t = "v.", left = 0 } end
    for _, nm in ipairs(party.names) do rows[#rows + 1] = { t = nm, left = 0 } end
    rows[#rows + 1] = { t = party.designation, left = INDENT }
  end
  return rows
end

-- Box caption (typst caption-box): the party column closed by a right and a bottom rule, the text standing off
-- them; "C.A. No." and "JURY DEMANDED" at the right.
local function caption_box(m)
  local left = {}
  for i, r in ipairs(party_rows(m.caption.parties)) do
    left[#left + 1] = p(inl(r.t), { left = r.left, before = i > 1 and CAPTION_GAP or 0 })
  end
  local cn = str(m.case_number)
  local right = { p(xe.runs("C.A. No. ") .. (cn and inl(cn) or "<w:r><w:tab/></w:r>"),
    { tab = cn and nil or 2304 }) }
  if m.jury_demand == true then right[#right + 1] = p(xe.runs("JURY DEMANDED"), { before = COVER_GAP }) end
  return tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, { {
    { pr = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
      '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
      '<w:tcMar><w:bottom w:w="' .. CAP_INSET - RULE .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>',
      body = left },
    {},
    { pr = '<w:tcMar><w:left w:w="' .. CAP_RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>', body = right },
  } })
end

-- Section-symbol caption (typst caption-section): one row per line, "§" in the middle column, the civil action
-- number and judge at the right from the third row on; rows a gutter apart.
local function caption_section(m)
  local left = party_rows(m.caption.parties)
  local right = {}
  if str(m.case_number) then right[#right + 1] = "Civil Action No. " .. m.case_number end
  if str(m.judge) then right[#right + 1] = m.judge end
  local n = math.max(#left, #right + 2)
  local rows = {}
  for i = 1, n do
    local b = i > 1 and SECTION_GAP or 0
    local l = left[i]
    local r = i >= 3 and right[i - 2] or nil
    rows[#rows + 1] = {
      { body = { p(l and inl(l.t) or "", { left = l and l.left or 0, before = b }) } },
      { body = { p(xe.runs("\u{00A7}"), { jc = "center", before = b }) } },
      { body = { p(r and inl(r) or "", { before = b }) } },
    }
  end
  return tbl({ CAP_LEFT, SEC_MID, TEXTW - CAP_LEFT - SEC_MID }, rows)
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

-- The page number: centered in a single-spaced line box (typst: the footer's line box).
local PAGE_FOOTER = '<w:p><w:pPr>' .. xe.spacing(0, 0, SINGLE) .. xe.ind(0, nil, 0) .. xe.jc("center") .. '</w:pPr>' ..
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' ..
  '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdTxsdPage"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" ' ..
  'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, bold: level 1 centered (capitals), level 2 (and deeper) flush left; kept with the text.
local function heading(level, content, before, brk)
  local props = { xe.style(level == 1 and "Heading1" or "Heading2"), xe.KEEP }
  if brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(before or 0, 0, BODY)
  props[#props + 1] = xe.ind(0, nil, 0)
  props[#props + 1] = xe.jc(level == 1 and "center" or "left")
  return xe.para(props, xe.inl(content, { b = true }))
end

-- A heading's text as set: level 1 in capitals (typst upper), levels 2 and 3 as written.
local function heading_text(b)
  local content = fix(b.content)
  if b.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return content
end

-- A body paragraph at the double pitch: the first-line indent, then (numbered) the number and a tab to the next half
-- inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, o)
  o = o or {}
  local q = { line = BODY, first = INDENT, before = o.before, keep = o.keep, next = o.next, brk = o.brk }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- A labelled item at the double pitch: the label at `left`, the text hanging a label box after it.
local function label_item(left, width, label, inlines, o)
  o = o or {}
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, left = left + width, hanging = width,
    tab = left + width, before = o.before, brk = o.brk })
end

-- A prayer item ("A. ..."): pandoc takes a single space after a capital letter as text, not as a list (typst:
-- ^[A-Z]\.\s).
local function prayer(b)
  return (b.t == "Para" or b.t == "Plain") and b.content[1] ~= nil and b.content[1].t == "Str"
    and b.content[1].text:match("^%u%.$") ~= nil and b.content[2] ~= nil and b.content[2].t == "Space"
end

local function signature(sig, date, before)
  local ps = {}
  if str(date) then ps[#ps + 1] = { inl(date), { after = COVER_GAP } } end
  if str(sig.lead) then ps[#ps + 1] = { inl(sig.lead), { left = SIG_LEFT, after = SIG_ABOVE } } end
  if str(sig.party) then ps[#ps + 1] = { inl(sig.party, { b = true }), { left = SIG_LEFT, after = SIG_ABOVE } } end
  if str(sig.by) then ps[#ps + 1] = { inl(sig.by), { left = SIG_LEFT, after = SIG_BY_GAP } } end
  for _, l in ipairs(sig.signer_lines or {}) do ps[#ps + 1] = { inl(l), { left = SIG_LEFT } } end
  local out = {}
  for i, x in ipairs(ps) do
    local o = x[2]
    if i == 1 then o.before = before end
    o.keep = i < #ps
    out[#out + 1] = p(x[1], o)
  end
  return out
end

function Pandoc(doc)
  load_pages()
  local m = raw_meta()
  local blocks = doc.blocks

  -- the headings in order (the body's, then the certificates'), for the contents and its needles
  local entries, ids, h = {}, {}, 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h = h + 1
      ids[i] = "H:" .. h
      local nxt = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
      local text = heading_text(b)
      need(ids[i], stringify(text), nxt)
      entries[#entries + 1] = { id = ids[i], title = text }
    end
  end
  local certs = {}
  if FORM.contents then
    for _, c in ipairs(CERTIFICATES) do
      if str(m[c.key]) then
        h = h + 1
        certs[#certs + 1] = { id = "H:" .. h, title = c.title, text = m[c.key] }
        need("H:" .. h, c.title, m[c.key]:sub(1, 40))
        entries[#entries + 1] = { id = "H:" .. h, title = pandoc.Inlines({ pandoc.Str(c.title) }) }
      end
    end
  end
  local toc = FORM.contents and m.toc == true
  if toc then
    local nl = { table.concat({ "S:0", "B", norm("UNITED STATES DISTRICT COURT FOR THE SOUTHERN DISTRICT OF TEXAS"),
      norm("UNITED STATES DISTRICT COURT") }, "\t") }
    for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
    nl[#nl + 1] = "#section\tS:0\tdecimal\t"
    write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  end
  write_file("FORMBOOK_FOOTERS", "rIdTxsdPage\t" .. PAGE_FOOTER .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = court_title(m)
  out[#out + 1] = m.caption.style == "box" and caption_box(m) or caption_section(m)
  -- the title of the paper, bold and centered at the body pitch, a double line below the caption
  out[#out + 1] = p(inl(m.brief_title, { b = true }), { line = BODY, jc = "center", before = BODY,
    after = toc and 0 or COVER_GAP })

  -- the space a block asks for below it is taken by the next paragraph as space before it; a page break drops it
  local gap, brk = 0, false
  local function take(before)
    local g = math.max(gap, before or 0)
    gap = 0
    return g
  end
  local function first()
    local b = brk
    brk = false
    return b
  end

  if toc then
    -- the cover is its own page; the contents (the headings of levels 1 and 2 and the certificates, with their
    -- pages) on the next; the body on a new page (typst pagebreak)
    out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { line = BODY, jc = "center", brk = true, keep = true })
    for _, e in ipairs(entries) do
      out[#out + 1] = p(xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
        { line = BODY, lines = true, tabs = xe.leader_tab(TEXTW), right = PNUM })
    end
    brk = true
  elseif str(m.lead_in) then
    out[#out + 1] = body_par(nil, fix(md(m.lead_in)))
  end

  local unnum, n = false, 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local text = heading_text(b)
      unnum = UNNUMBERED[pandoc.text.upper(stringify(b.content))] == true
      out[#out + 1] = heading(b.level == 1 and 1 or 2, text, take(), first())
    elseif prayer(b) then
      local rest = pandoc.Inlines({})
      for k = 3, #b.content do rest:insert(b.content[k]) end
      out[#out + 1] = label_item(INDENT, ITEM_LABEL, b.content[1].text, fix(rest), { before = take(), brk = first() })
    elseif b.t == "Para" or b.t == "Plain" then
      if FORM.numbered and not unnum then
        n = n + 1
        out[#out + 1] = body_par(n .. ".", fix(b.content), { before = take(), brk = first() })
      else
        -- an unnumbered lead-in under PRAYER FOR RELIEF or JURY TRIAL DEMAND stays with the block after it
        out[#out + 1] = body_par(nil, fix(b.content), { before = take(), brk = first(), next = unnum })
      end
    elseif b.t == "BulletList" then
      for j, item in ipairs(b.content) do
        out[#out + 1] = label_item(0, LETTER_LABEL, "(" .. LETTERS[j] .. ")",
          fix(pandoc.utils.blocks_to_inlines(item)), { before = take(), brk = first() })
      end
    elseif b.t == "OrderedList" then
      local num = b.listAttributes.start
      for _, item in ipairs(b.content) do
        out[#out + 1] = label_item(INDENT, ITEM_LABEL, num .. ".", fix(pandoc.utils.blocks_to_inlines(item)),
          { before = take(), brk = first() })
        num = num + 1
      end
    else
      error("txsd.lua: unsupported block " .. b.t)
    end
  end

  if type(m.signature) == "table" then
    for _, x in ipairs(signature(m.signature, m.date, take(SIG_ABOVE))) do out[#out + 1] = x end
  end

  -- certificates: a level-1 heading, the text, the signature 3.25 inches in, a signature's space above it; each on
  -- one page (typst: an unbreakable block)
  for _, c in ipairs(certs) do
    out[#out + 1] = heading(1, pandoc.Inlines({ pandoc.Str(c.title) }), 0)
    out[#out + 1] = body_par(nil, fix(md(c.text)), { keep = str(m.certificate_signature) ~= nil })
    if str(m.certificate_signature) then
      out[#out + 1] = p(inl(m.certificate_signature), { left = SIG_LEFT, before = SIG_ABOVE })
    end
  end

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
