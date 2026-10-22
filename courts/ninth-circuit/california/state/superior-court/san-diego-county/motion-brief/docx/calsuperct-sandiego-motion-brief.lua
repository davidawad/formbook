-- San Diego County Superior Court (calsuperct-sandiego), motion (notice and memorandum of points and authorities),
-- docx engine (docs/DOCX.md): the motion as Word paragraphs, so that it reads and breaks as
-- typst/calsuperct-sandiego-motion-brief.typ does: pleading paper (CRC 2.108: 28 numbered lines of 24 pt, the numbers
-- in a page-anchored frame of the footer, the rules as page borders), the attorney block on lines 1-7 with the
-- fee-exemption label at the top right (CRC 2.111(1), (2); SD Local Rule 2.1.2(H)), the court title (CRC 2.111(3)),
-- the caption with the hearing block (CRC 2.111(4)-(10), 3.1110(b)), any notice of motion, the tables of contents and
-- authorities when the frontmatter lists authorities (CRC 3.1113(f)), the memorandum with its footnotes (12 pt,
-- single spaced, CRC 2.104, 2.108(3)), the jury demand and the signature block, and the footer (CRC 2.109, 2.110: a
-- rule, the page number, the paper's title in 10 pt; FORMBOOK_FOOTERS). Every case-specific word comes from the
-- sample's frontmatter (read as written, $FORMBOOK_META: pandoc's metadata drops a caption line's leading spaces) and
-- body, never from this file.
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; a chunk that starts with "#" is a heading), each chunk by pandoc alone with the definitions of the footnotes
-- it refers to, as cmarker reads it (no "b)" lists). A paragraph that refers to a footnote stays a pandoc paragraph
-- (Body Text, Body Text Keep), so that pandoc writes the note.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle:
-- the contents' page of each heading of the memorandum and the authorities' pages of each `toa:` link. With tables,
-- two sections: the first page, any notice and the tables (lower roman from i), the memorandum (arabic from 1;
-- FORMBOOK_FINAL); without, one (arabic). Word may paginate slightly differently from LibreOffice.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered lines, 240 a single line, 276 a footnote
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE, GAP = 480, 240, 240   -- typst pitch, pitch-single, gap
local DROP = 192                          -- typst single-drop, 9.6 pt: a single group's top below a numbered line's
local LINES = 28                          -- typst lines-per-page
local TOP, LEFT = 1440, 2160              -- typst top-margin, left-margin
local TEXTW = 9360                        -- 6.5 in
local INDENT = 720                        -- typst para-indent
local CLERK = 7                           -- typst clerk-lines
local FEE_W = 3312                        -- typst fee-width, 2.3 in
local CAP_LEFT, CAP_INSET, CAP_FOOT = 5184, 180, 180   -- typst caption-left 3.6 in, caption-inset 9 pt, caption-foot 9 pt
local CAP_RIGHT = 288                     -- typst caption-right, 0.2 in
local SPACE = 60                          -- typst space-indent, 3 pt
local SIG_LEFT, SIGNER = 4464, 432        -- typst signature-left 3.1 in, signer-indent 0.3 in
local SIG_RULE = 3888                     -- typst signature-rule, 2.7 in
local FOOT = 20                           -- typst footer-size 10 pt, in half points
local TOC_IND, TOC_COL = 720, 720         -- typst toc-indent 0.5 in, toc-col 0.5 in
local TOA_HANG, TOA_COL = 360, 1080       -- typst toa-hang 0.25 in, toa-col 0.75 in
local NEEDLE_MAX = 60
local MEMO = "^#+[ \t]+[Mm][Ee][Mm][Oo][Rr][Aa][Nn][Dd][Uu][Mm] [Oo][Ff] [Pp][Oo][Ii][Nn][Tt][Ss] [Aa][Nn][Dd] [Aa][Uu][Tt][Hh][Oo][Rr][Ii][Tt][Ii][Ee][Ss]"

local function read_file(path)
  if path == nil or path == "" then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(t, key)
  if t == nil or t[key] == nil then error("calsuperct-sandiego-motion-brief: missing required metadata field `" .. key .. "`") end
  return t[key]
end

local function list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 17200"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "b)" or "A." lists); footnotes included.
local function md(s)
  local doc = pandoc.read(tostring(s), "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  local para = pandoc.Para(pandoc.utils.blocks_to_inlines(doc.blocks))
  return para:walk({ Str = breaks }):walk({ Inlines = bind_doubled }).content
end

local function upper(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function has_note(inl)
  local found = false
  pandoc.Inlines(inl):walk({ Note = function() found = true end })
  return found
end

-- A paragraph: o = { style, before, after, line, left, right, first, hanging, jc, keep, lines, brk, tabs, frame,
-- border, sz }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.frame then props[#props + 1] = o.frame end
  if o.border then props[#props + 1] = o.border end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.sz then
    props[#props + 1] = '<w:rPr><w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/></w:rPr>'
  end
  return xe.para(props, body or "")
end

local function tab(kind, pos, leader)
  return '<w:tab w:val="' .. kind .. '"' .. (leader and (' w:leader="' .. leader .. '"') or "") .. ' w:pos="' .. pos .. '"/>'
end

-- typst line-stack(): one single line per item; an empty item an empty line; each leading space a quarter em in.
local function line_stack(items, o)
  o = o or {}
  local out = {}
  for i, it in ipairs(list(items)) do
    local sp, t = tostring(it):match("^( *)(.*)$")
    local before = i == 1 and (o.before or 0) or 0
    out[#out + 1] = p(t == "" and "" or xe.inl(md(t), { b = o.b }), { before = before, left = (o.left or 0) + #sp * SPACE,
      jc = o.jc, keep = o.keep })
  end
  return out
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    local body = #cells[i].body > 0 and table.concat(cells[i].body) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function top_cell(body)
  return { pr = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/></w:tcMar>', body = body }
end

-- ---------------------------------------------------------------------------
-- Page furniture: the footer (the line numbers in a frame at the left margin, on the body's line boxes; a rule, the
-- page number in the section's numbering, the paper's title in 10 pt) and the sections (letter, the typst margins,
-- the pleading rules: a double rule left of the text, a single rule right of it).
-- ---------------------------------------------------------------------------

local function footer()
  local out = {}
  local frame = '<w:framePr w:w="' .. (LEFT - INDENT) .. '" w:h="' .. (LINES * BODY) .. '" w:hRule="exact" ' ..
    'w:wrap="notBeside" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="' .. TOP .. '"/>'
  for i = 1, LINES do out[#out + 1] = p(xe.runs(tostring(i)), { line = BODY, jc = "right", frame = frame }) end
  local fld = function(x) return '<w:r>' .. x .. '</w:r>' end
  out[#out + 1] = p(fld('<w:fldChar w:fldCharType="begin"/>') .. fld('<w:instrText xml:space="preserve"> PAGE </w:instrText>') ..
    fld('<w:fldChar w:fldCharType="separate"/>') .. xe.runs("1") .. fld('<w:fldChar w:fldCharType="end"/>'),
    { jc = "center", border = '<w:pBdr><w:top w:val="single" w:sz="4" w:space="2" w:color="000000"/></w:pBdr>' })
  out[#out + 1] = p(xe.runs(tostring(need(RAW, "footer_title")), { sz = FOOT }), { jc = "center", sz = FOOT })
  return table.concat(out)
end

local function sect_pr(fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="rIdSdPage"/>' ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="720" w:bottom="960" w:left="2160" ' ..
    'w:header="720" w:footer="360" w:gutter="0"/><w:pgBorders w:offsetFrom="text">' ..
    '<w:left w:val="double" w:sz="4" w:space="12" w:color="auto"/><w:right w:val="single" w:sz="4" w:space="7" ' ..
    'w:color="auto"/></w:pgBorders><w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/></w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line).
local function section_end(fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. sect_pr(fmt) ..
    '</w:pPr></w:p>'
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
  local short = norm(text):sub(1, NEEDLE_MAX)
  needles[#needles + 1] = table.concat({ id, kind, long, short ~= "" and short or long }, "\t")
end

local labels = {}
local function load_pages()
  local f = io.open(os.getenv("FORMBOOK_PAGES") or "", "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

-- ---------------------------------------------------------------------------
-- First page: attorney block (lines 1-7 at least), fee label at the top right, court title, caption
-- ---------------------------------------------------------------------------

local function first_page(out)
  local att, fee = list(need(RAW, "attorney")), list(RAW.fee_exempt)
  local n = math.max(CLERK, math.ceil((DROP + math.max(#att, #fee) * SINGLE) / BODY))
  local row = '<w:trPr><w:cantSplit/><w:trHeight w:val="' .. (n * BODY) .. '" w:hRule="exact"/></w:trPr>'
  if #fee > 0 then
    out[#out + 1] = tbl({ TEXTW - FEE_W, FEE_W }, { top_cell(line_stack(att)), top_cell(line_stack(fee, { jc = "right" })) }, row)
  else
    out[#out + 1] = tbl({ TEXTW }, { top_cell(line_stack(att)) }, row)
  end
  local court = list(need(RAW, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(md(l), { b = true }), { line = BODY, jc = "center", after = i == #court and BODY or 0 })
  end
  -- the caption: the party column ruled at its right and foot, the case column beside it
  local cap = need(RAW, "caption")
  local right, above = {}, 0
  local function add(ps) for _, x in ipairs(ps) do right[#right + 1] = x end end
  if cap.case_number then add(line_stack({ cap.case_number })); above = GAP end
  if cap.limited_civil == true then add(line_stack({ "LIMITED CIVIL CASE" }, { before = above })); above = GAP end
  add(line_stack(need(cap, "title"), { before = above, b = true }))
  if cap.details then add(line_stack(cap.details, { before = GAP })) end
  local rows = {}
  if cap.hearing then
    for _, k in ipairs({ { "date", "Date:" }, { "time", "Time:" }, { "dept", "Dept.:" }, { "judge", "Judge:" } }) do
      if cap.hearing[k[1]] then rows[#rows + 1] = k[2] .. " " .. tostring(cap.hearing[k[1]]) end
    end
  else
    if cap.dept then rows[#rows + 1] = "Dept.: " .. tostring(cap.dept) end
    if cap.judge then rows[#rows + 1] = "Judge: " .. tostring(cap.judge) end
  end
  if cap.action_filed then rows[#rows + 1] = "Action filed: " .. tostring(cap.action_filed) end
  if cap.trial_date then rows[#rows + 1] = "Trial date: " .. tostring(cap.trial_date) end
  if #rows > 0 then add(line_stack(rows, { before = GAP })) end
  if cap.amount_demanded then add(line_stack({ cap.amount_demanded }, { before = GAP })) end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
      '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
      '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>',
      body = line_stack(need(cap, "left")) },
    { pr = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:left w:w="' .. CAP_RIGHT .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
end

-- ---------------------------------------------------------------------------
-- Signature block: a numbered line below the text; the date at the left, the signature column; kept together.
-- ---------------------------------------------------------------------------

local function signature(out)
  local sig = need(RAW, "signature")
  local first = BODY + DROP
  local function take()
    local b = first
    first = 0
    return b
  end
  if sig.dated then out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(md(sig.dated)), { before = take(), keep = true }) end
  for _, l in ipairs(list(sig.lines)) do
    out[#out + 1] = p(xe.inl(md(l)), { before = take(), left = SIG_LEFT, keep = true })
  end
  -- "By:", then the signature line (an underlined tab) to its end
  out[#out + 1] = p(xe.runs("By: ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    { before = math.max(take(), BODY), left = SIG_LEFT, keep = true,
      tabs = "<w:tabs>" .. tab("left", SIG_LEFT + 406 + SIG_RULE) .. "</w:tabs>" })
  local role = sig.role
  out[#out + 1] = p(xe.inl(md(pandoc.text.upper(tostring(need(sig, "signer")))), { b = true }),
    { left = SIG_LEFT + SIGNER, keep = role ~= nil })
  if role then out[#out + 1] = p(xe.inl(md(role)), { left = SIG_LEFT + SIGNER }) end
end

-- ---------------------------------------------------------------------------
-- The body: the chunks of typst's pieces-of()
-- ---------------------------------------------------------------------------

local function source_body()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  return (src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1))
end

local function chunks_of(s)
  local out = {}
  for c in (s .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" and not c:match("^%[%^[^%]]+%]:") then out[#out + 1] = c end
  end
  return out
end

-- The toa: links of inlines, in order, those in the text before those in its footnotes: { key, text, note }.
local function links_of(inl)
  local out = {}
  local function grab(note)
    return function(l)
      local key = l.target:match("^toa:(.+)$")
      if key then out[#out + 1] = { key = key, text = stringify(l.content), note = note } end
    end
  end
  local para = pandoc.Para(inl)
  para:walk({ Note = function() return {} end }):walk({ Link = grab(false) })
  para:walk({ Note = function(n) pandoc.Blocks(n.content):walk({ Link = grab(true) }) end })
  return out
end

local function plain_links(inl)
  return pandoc.Para(inl):walk({ Link = function(l) return l.content end }).content
end

-- The memorandum's headings and citations, for the tables (filled by body()).
local entries, hits, counts = {}, {}, { h = 0, k = 0 }

-- One body (typst pieces-of() and with-closing()): o = { first_before, keep_last, memo }.
local function body(cs, notes, o, out)
  for i, t in ipairs(cs) do
    local last = o.keep_last and i == #cs
    local before = i == 1 and (o.first_before or 0) or 0
    local defs = ""
    for id in t:gmatch("%[%^([^%]]+)%]") do defs = defs .. "\n\n[^" .. id .. "]: " .. (notes[id] or "") end
    local hashes, htext = t:match("^(#+)[ \t]+(.-)[ \t#]*$")
    local inl = md(t .. defs)
    if o.memo then
      if hashes then
        counts.h = counts.h + 1
        local id = "H:" .. counts.h
        local nxt = cs[i + 1] and stringify(md(cs[i + 1]:gsub("^#+[ \t]+", ""))):sub(1, 40) or ""
        needle(id, "B", stringify(plain_links(inl)), nxt)
        entries[#entries + 1] = { id = id, level = #hashes, content = inl }
        if not o.start_id then o.start_id = id end
      elseif not o.start_id then
        o.start_id = "M:start"
        needle("M:start", "B", stringify(plain_links(inl)):sub(1, 40))
      end
      for _, l in ipairs(links_of(inl)) do
        counts.k = counts.k + 1
        local id = "K:" .. counts.k
        hits[l.key] = hits[l.key] or {}
        hits[l.key][#hits[l.key] + 1] = id
        needle(id, l.note and "N" or "B", l.text)
      end
    end
    if hashes then
      -- on the numbered lines: levels 1 and 2 centered bold capitals, 3 bold, 4 and 5 bold italic; kept with the
      -- next chunk
      local lvl = #hashes
      if lvl <= 2 then inl = upper(inl) end
      out[#out + 1] = xe.raw(p(xe.inl(inl, { b = true, i = lvl >= 4 }), { style = "Heading" .. math.min(lvl, 5),
        line = BODY, before = before, keep = true, jc = lvl <= 2 and "center" or "left" }))
    elseif has_note(inl) then
      -- a pandoc paragraph (Body Text: the body pitch and indent; Body Text Keep kept with the signature block)
      local para = plain_links(xe.inlines(inl))
      para = pandoc.Para(para):walk({ Note = function(n)
        return pandoc.Note(pandoc.Blocks(n.content):walk({ Inlines = xe.inlines }):walk({ Link = function(l) return l.content end }))
      end }).content
      if before > 0 then out[#out + 1] = xe.raw(p("", { line = before })) end
      out[#out + 1] = pandoc.Div({ pandoc.Para(para) }, { ["custom-style"] = last and "Body Text Keep" or "Body Text" })
    else
      out[#out + 1] = xe.raw(p(xe.inl(inl), { line = BODY, first = INDENT, before = before, keep = last }))
    end
  end
end

-- ---------------------------------------------------------------------------
-- Tables of contents and authorities (typst toc-section, toa-section)
-- ---------------------------------------------------------------------------

-- A row: the text hanging by `hang` from `left0`, a leader to the page column `col`.
local function row(text, page, left0, hang, col, keep)
  return xe.raw(p(text .. xe.runs(xe.LEAD) .. page, { line = BODY, left = left0 + hang, hanging = hang, right = col,
    tabs = xe.leader_tab(TEXTW), keep = keep, lines = true }))
end

local function title(t)
  return xe.raw(p(xe.runs(t, { b = true }), { line = BODY, jc = "center", keep = true, brk = true }))
end

local function contents(out)
  out[#out + 1] = title("TABLE OF CONTENTS")
  if #entries == 0 then error("calsuperct-sandiego-motion-brief: the memorandum has no headings for its table of contents") end
  local top = math.huge
  for _, e in ipairs(entries) do top = math.min(top, e.level) end
  for _, e in ipairs(entries) do
    local ind = (e.level - top) * TOC_IND
    out[#out + 1] = row(xe.inl(plain_links(e.content)), xe.runs(labels[e.id] or "0"), ind, TOC_IND, TOC_COL)
  end
end

local GROUPS = { { "case", "CASES" }, { "constitution", "CONSTITUTIONAL PROVISIONS" }, { "statute", "STATUTES" },
  { "regulation", "REGULATIONS" }, { "rule", "RULES" }, { "other", "OTHER AUTHORITIES" } }

local function authorities(out, auth)
  out[#out + 1] = title("TABLE OF AUTHORITIES")
  for key in pairs(hits) do
    if auth[key] == nil then
      error("calsuperct-sandiego-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
    end
  end
  local first = true
  for _, g in ipairs(GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if tostring(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a } end
    end
    local function sort_key(m) return tostring(m.a.sort or m.a.name or m.a.cite):lower() end
    table.sort(members, function(x, y) return sort_key(x) < sort_key(y) end)
    if #members > 0 then
      out[#out + 1] = xe.raw(p(xe.runs(g[2], { b = true }), { line = BODY, keep = true, before = first and 0 or BODY }))
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
        local where = xe.runs(table.concat(pages, ", "))
        if m.a.name then
          out[#out + 1] = xe.raw(p(xe.inl(md(m.a.name), { i = g[1] == "case" }) .. xe.runs(","), { line = BODY,
            left = TOA_HANG, hanging = TOA_HANG, keep = true }))
          out[#out + 1] = row(xe.inl(md(m.a.cite)), where, TOA_HANG, 0, TOA_COL)
        else
          out[#out + 1] = row(xe.inl(md(m.a.cite)), where, 0, TOA_HANG, TOA_COL)
        end
      end
    end
  end
end

function Pandoc(doc)
  load_pages()
  local src = source_body()
  local notes = {}
  for id, text in ("\n" .. src):gmatch("\n%[%^([^%]]+)%]:[ \t]*([^\n]*)") do notes[id] = text end
  local cs = chunks_of(src)
  local memo_at
  for i, c in ipairs(cs) do
    if c:match(MEMO) then memo_at = i; break end
  end
  local notice, head, memo = {}, {}, cs
  if memo_at then
    notice, head, memo = { table.unpack(cs, 1, memo_at - 1) }, { cs[memo_at] }, { table.unpack(cs, memo_at + 1) }
  end
  local auth = RAW.authorities

  local front, mem = {}, {}
  local raw_first = {}
  first_page(raw_first)
  for _, x in ipairs(raw_first) do front[#front + 1] = xe.raw(x) end
  if #notice > 0 then body(notice, notes, { first_before = BODY }, front) end
  body(head, notes, { first_before = (auth == nil and #notice == 0) and BODY or 0 }, mem)
  local mo = { memo = true, keep_last = true, first_before = (auth == nil and #notice == 0 and #head == 0) and BODY or 0 }
  body(memo, notes, mo, mem)
  local closing = {}
  if RAW.jury_demand then
    closing[#closing + 1] = p(xe.runs(pandoc.text.upper(tostring(RAW.jury_demand)), { b = true }),
      { line = BODY, before = BODY, jc = "center", keep = true })
  end
  signature(closing)
  for _, x in ipairs(closing) do mem[#mem + 1] = xe.raw(x) end

  local out = front
  if auth ~= nil then
    -- the needles: the first page (lower roman from i), the memorandum's first needle (arabic from 1), in order
    local first_line = tostring(list(need(RAW, "attorney"))[1] or "")
    table.insert(needles, 1, table.concat({ "S:front", "B", norm(first_line):sub(1, NEEDLE_MAX), norm(first_line):sub(1, NEEDLE_MAX) }, "\t"))
    needles[#needles + 1] = "#section\tS:front\tlower-roman\t"
    needles[#needles + 1] = "#section\t" .. mo.start_id .. "\tdecimal\t"
    write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
    contents(out)
    authorities(out, auth)
    out[#out + 1] = xe.raw(section_end("lowerRoman"))
  end
  for _, x in ipairs(mem) do out[#out + 1] = x end
  write_file("FORMBOOK_FOOTERS", "rIdSdPage\t" .. footer() .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("decimal"))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
