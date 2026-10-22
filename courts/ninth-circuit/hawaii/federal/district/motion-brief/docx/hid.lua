-- U.S. District Court for the District of Hawaii: motion with memorandum in support, docx engine (docs/DOCX.md). The
-- same markdown contract as typst/hid-motion-brief.typ, and every part written as it sets it: the caption (counsel
-- block, court title, caption box with "Judge:"; LR 10.2(b), (c)), the motion paragraphs and signature, the table of
-- contents and the table of authorities (LR 7.4(f)), the memorandum (headings numbered I. / A. / 1., the body and
-- its footnotes as pandoc writes them), the signature at its end, the certificate of compliance when the memorandum
-- runs past 25 pages (LR 7.4(b), (e)) and the certificate of service. Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the double-spaced body, 322 a single line, 276 a counsel
-- line), the spaces between blocks those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle:
-- the contents' page of each heading, the authorities' pages of each `toa:` link (its text and the words after it,
-- as typst tags the link's first word), and the memorandum's last page. Three sections: the motion (page 1 without a
-- number, a continuation page numbered from 2), the tables (roman from i), the memorandum (arabic from 1;
-- FORMBOOK_FINAL). Word may paginate slightly differently from LibreOffice.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local COURT = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF HAWAII" }
local BODY, SINGLE, COUNSEL = 644, 322, 276          -- typst pitch-double, pitch-single, pitch-counsel
local COUNSEL_SZ = 24                                -- typst counsel-size, 12 pt
local INDENT = 720                                   -- typst para-indent, toc-step: 0.5 in
local TEXTW = 9360                                   -- 6.5 in
local CAP_LEFT, CAP_GAP = 4464, 288                  -- typst caption-left, caption-gap
local CAP_PAD = 180                                  -- typst caption-pad, 0.125 in
local CAP_FOOT = 145                                 -- typst caption-foot (160) less the 0.75 pt rule LibreOffice sets below the cell
local SIG = 4320                                     -- typst signature-indent, 3 in
local H1_ABOVE, H_ABOVE, H_BELOW = 322, 160, 160     -- typst h1-above, h-above, h-below
local ROW_GAP, GROUP_GAP = 160, 322                  -- typst row-gap, group-gap
local TOC_COL, TOA_COL, TOA_HANG = 720, 1440, 504    -- typst toc-page-col, toa-page-col, toa-hang
local FOOTER = 686                                   -- the page number's line 34.3 pt above the page foot
local PAGE_LIMIT, WORD_LIMIT = 25, 6250              -- LR 7.4(a), (b)
local PASSIM = 7                                     -- typst passim-threshold
local NEEDLE_MAX = 60
local COUNSEL_W = { { 9360 }, { 4680, 4680 }, { 3312, 3168, 2880 } } -- typst counsel-widths
local RULE = 'w:sz="6" w:space="0" w:color="000000"'
local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "regulation", "Regulations" }, { "rule", "Rules" }, { "other", "Other Authorities" },
}

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tabs, jc, keep, lines, brk, outline }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

-- A one-row table without cell margins: widths in twips, a cell = { pr, body = { paragraphs } }.
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

-- A section's properties: its footers (fb render's rIdFtrNone or rIdFtrPage; `first` for a first page of its own),
-- the page numbers, letter paper with 1-inch margins (LR 10.2(a)(1)).
local function sect_pr(footer, fmt, first)
  local refs = '<w:footerReference w:type="default" r:id="' .. footer .. '"/>'
  if first then refs = refs .. '<w:footerReference w:type="first" r:id="' .. first .. '"/>' end
  return '<w:sectPr>' .. refs .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" ' ..
    'w:bottom="1440" w:left="1440" w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' ..
    '<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>' .. (first and '<w:titlePg/>' or '') .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(...)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>' .. sect_pr(...) ..
    '</w:pPr></w:p>'
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, kind, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, kind, long, short:sub(1, NEEDLE_MAX) }, "\t")
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

-- The text of inlines as the PDF prints it, up to the first footnote mark (a needle stops there: the mark's number
-- is in the PDF text, its note is not).
local function text_of(inlines)
  local out = {}
  for _, el in ipairs(inlines) do
    if el.t == "Note" then
      out[#out + 1] = "\0"
      break
    elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then
      out[#out + 1] = " "
    elseif el.t == "Str" then
      out[#out + 1] = el.text
    elseif el.content then
      out[#out + 1] = text_of(el.content)
    else
      out[#out + 1] = stringify(el)
    end
  end
  return (table.concat(out):match("^[^\0]*"))
end

-- Every `toa:` link of a run of inlines, in order: a needle of its text and the words after it (kind B in the body,
-- N in a footnote), listed under its key.
local hits, hit_n = {}, 0
local function scan_links(inlines, kind)
  for i, el in ipairs(inlines) do
    if el.t == "Link" and el.target:sub(1, 4) == "toa:" then
      local key = el.target:sub(5)
      hit_n = hit_n + 1
      local id = "T:" .. hit_n
      local rest = {}
      for j = i + 1, #inlines do rest[#rest + 1] = inlines[j] end
      need(id, kind, text_of(el.content), text_of(rest))
      hits[key] = hits[key] or {}
      hits[key][#hits[key] + 1] = id
    elseif el.t == "Note" then
      for _, b in ipairs(el.content) do
        if b.content and b.t ~= "BulletList" and b.t ~= "OrderedList" then scan_links(b.content, "N") end
      end
    elseif el.content and type(el.content) == "table" and el.t ~= "Link" then
      scan_links(el.content, kind)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Word count (LR 7.4(d)), the memorandum's markdown as typst counts it (count-words)
-- ---------------------------------------------------------------------------

local function count_words()
  local f = io.open(PANDOC_STATE.input_files[1], "r")
  if not f then return 0 end
  local s = f:read("a")
  f:close()
  s = s:gsub("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n", "", 1)
  s = s:gsub("<!%-%-.-%-%->", " ")
  local lines = {}
  for l in (s .. "\n"):gmatch("(.-)\n") do
    l = l:gsub("^%[%^[^%]]+%]:", " ")           -- footnote definition labels
    l = l:gsub("^#+[ \t]+", "")                 -- heading marks
    l = l:gsub("^>[ \t]?", "")                  -- quotation marks
    l = l:gsub("^[ \t]*[-*+][ \t]+", "")        -- list markers are not words
    l = l:gsub("^[ \t]*%d+[.)][ \t]+", "")
    lines[#lines + 1] = l
  end
  s = table.concat(lines, "\n")
  s = s:gsub("%[%^[^%]]+%]", "")                -- footnote references
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")     -- links keep their text
  s = s:gsub("\\(.)", "%1")                     -- backslash escapes
  s = s:gsub("%*", "")
  local n = 0
  for w in s:gmatch("%S+") do
    if w ~= "_" then n = n + 1 end
  end
  return n
end

-- ---------------------------------------------------------------------------
-- Caption (LR 10.2(b), (c); LR 7.3)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local columns = list(meta.counsel and meta.counsel.columns)
  if #columns > 0 then
    local cells = {}
    for _, col in ipairs(columns) do
      local ps = {}
      for _, l in ipairs(list(col)) do ps[#ps + 1] = p(xe.inl(l, { sz = COUNSEL_SZ }), { line = COUNSEL }) end
      cells[#cells + 1] = { body = ps }
    end
    out[#out + 1] = tbl(COUNSEL_W[#columns], cells)
  end
  if meta.counsel_for then
    out[#out + 1] = p(xe.inl(meta.counsel_for, { i = true }), { before = SINGLE })
  end
  for i, l in ipairs(COURT) do
    out[#out + 1] = p(xe.runs(l, { b = true }),
      { jc = "center", keep = true, before = i == 1 and 2 * SINGLE or 0, after = i == #COURT and SINGLE or 0 })
  end
  local left = {}
  local parties = list(meta.parties)
  for i, party in ipairs(parties) do
    for _, n in ipairs(list(party.names)) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p("")
    left[#left + 1] = p(xe.inl(party.designation, { i = true }), { jc = "right" })
    if i < #parties then
      left[#left + 1] = p("")
      left[#left + 1] = p(xe.runs("v."))
      left[#left + 1] = p("")
    end
  end
  local function r(body) return p(body, { left = CAP_GAP }) end
  local title = pandoc.Inlines(meta.title):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  local right = { r(""), r(xe.runs("No. ") .. xe.inl(meta.case_number)), r(""), r(xe.inl(title, { b = true })), r(""),
    r(xe.runs("Judge: ") .. xe.inl(meta.judge)) }
  if meta.hearing then right[#right + 1] = r(xe.runs("Hearing: ") .. xe.inl(meta.hearing)) end
  if meta.trial_date then right[#right + 1] = r(xe.runs("Trial Date: ") .. xe.inl(meta.trial_date)) end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" ' .. RULE .. '/><w:right w:val="single" ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', body = left },
    { body = right },
  }, '<w:trPr><w:cantSplit/></w:trPr>')
  return out
end

-- Signature lines from 3 in, kept together; "" a blank line. The first carries `before`.
local function sig_lines(lines, out, before)
  for _, l in ipairs(lines) do
    local s = plain(l)
    out[#out + 1] = p(s == "" and "" or xe.inl(l), { keep = true, left = s ~= "" and SIG or 0, before = before })
    before = 0
  end
end

-- The dated line, a blank line, the signature blocks (a blank line between); kept whole.
local function signature(meta)
  local out = {}
  local before = SINGLE
  if meta.date then
    out[#out + 1] = p(xe.inl(meta.date), { keep = true, before = before })
    before = 0
  end
  out[#out + 1] = p("", { keep = true, before = before })
  local blocks = list(meta.signature and meta.signature.blocks)
  for i, b in ipairs(blocks) do
    sig_lines(list(b.lines), out)
    if i < #blocks then out[#out + 1] = p("", { keep = true }) end
  end
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return out
end

local function title_line(t, brk)
  return p(xe.runs(t, { b = true }), { jc = "center", after = SINGLE, keep = true, brk = brk })
end

local function body_par(text)
  return p(text, { line = BODY, first = INDENT })
end

-- ---------------------------------------------------------------------------
-- Tables (LR 7.4(f)): rows with a dot leader to the page column
-- ---------------------------------------------------------------------------

local function contents(entries)
  local out = { title_line("TABLE OF CONTENTS") }
  for _, e in ipairs(entries) do
    local ind = (e.level - 1) * INDENT
    out[#out + 1] = p(xe.runs(e.label .. "\t") .. xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
      { lines = true, before = ROW_GAP, left = ind + INDENT, hanging = INDENT, right = TOC_COL,
        tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + INDENT) .. '"/><w:tab w:val="right" w:leader="dot" w:pos="'
          .. TEXTW .. '"/></w:tabs>' })
  end
  return out
end

local function sort_key(a)
  local s = a.sort and plain(a.sort) or ((a.name and plain(a.name) or "") .. " " .. plain(a.cite))
  return (s:gsub("\u{00A0}", " "):lower():gsub("[^a-z0-9 ]", ""))
end

local function authorities(meta)
  local out = { title_line("TABLE OF AUTHORITIES", true) }
  local auth = meta.authorities or {}
  for key in pairs(hits) do
    if not auth[key] then error("hid.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter") end
  end
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if plain(a.kind) == g[1] and hits[key] then members[#members + 1] = { key = key, a = a, sk = sort_key(a) } end
    end
    table.sort(members, function(x, y) return x.sk < y.sk end)
    if #members > 0 then
      local head = xe.runs(g[2], { b = true })
      if first then head = head .. xe.runs("\t") .. xe.runs("Page(s)", { b = true, u = true }) end
      out[#out + 1] = p(head, { keep = true, before = first and 0 or GROUP_GAP,
        tabs = '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>' })
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
        text = text .. xe.inl(m.a.cite)
        out[#out + 1] = p(text .. xe.runs(xe.LEAD) .. where, { lines = true, before = ROW_GAP, left = TOA_HANG,
          hanging = TOA_HANG, right = TOA_COL, tabs = xe.leader_tab(TEXTW) })
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The memorandum
-- ---------------------------------------------------------------------------

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }

-- A heading: bold, single-spaced, the label in a half-inch box (a tab) and the text hanging after it; kept with the
-- next block.
local function heading(b, label)
  return p(xe.runs(label .. "\t", { b = true }) .. xe.inl(b.content, { b = true }), { keep = true,
    before = b.level == 1 and H1_ABOVE or H_ABOVE, after = H_BELOW, left = INDENT, hanging = INDENT,
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. INDENT .. '"/></w:tabs>', outline = math.min(b.level, 9) - 1 })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- Another of typst's rules (Unicode line breaking): no break at a space before a period, comma, colon or semicolon
-- (". . ."); that space becomes a no-break space.
local function binds(l)
  for i = 1, #l - 2 do
    local b, nxt = l[i + 1], l[i + 2]
    if l[i].t == "Str" and b.t == "Space" and nxt.t == "Str" and nxt.text:find("^[.,:;]") then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A character Times New Roman has no glyph for (the okina, U+02BB) is set in the typst template's fallback face,
-- Liberation Serif, as typst sets it; named on its own run, since LibreOffice's own fallback splits the word around
-- it in the PDF text.
local FALLBACK = '<w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif"/>'
local OKINA = "\u{02BB}"
local function fallback_xml(xml)
  return (xml:gsub("<w:r>(.-)</w:r>", function(inner)
    local t = inner:match('<w:t xml:space="preserve">([^<]*)</w:t>$')
    if not t or not t:find(OKINA, 1, true) then return nil end
    local rpr = inner:match("^<w:rPr>.-</w:rPr>") or ""
    local frpr = rpr == "" and ("<w:rPr>" .. FALLBACK .. "</w:rPr>") or rpr:gsub("^<w:rPr>", "<w:rPr>" .. FALLBACK, 1)
    local out = {}
    for piece, sep in (t .. OKINA):gmatch("(.-)(" .. OKINA .. ")") do
      if piece ~= "" then out[#out + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. piece .. "</w:t></w:r>" end
      out[#out + 1] = "<w:r>" .. frpr .. "<w:t>" .. sep .. "</w:t></w:r>"
    end
    out[#out] = nil
    return table.concat(out)
  end))
end

-- The same on inlines pandoc writes itself (a run of its own, italic or bold as around it).
local function fallback_inlines(l, o)
  o = o or {}
  local out = pandoc.Inlines({})
  for _, el in ipairs(l) do
    if el.t == "Str" and el.text:find(OKINA, 1, true) then
      out:insert(pandoc.RawInline("openxml", fallback_xml(xe.runs(el.text, o))))
    elseif el.t == "Note" then
      el.content = pandoc.Blocks(el.content):walk({
        Para = function(x) x.content = fallback_inlines(x.content) return x end,
        Plain = function(x) x.content = fallback_inlines(x.content) return x end })
      out:insert(el)
    elseif el.t == "Emph" or el.t == "Strong" then
      el.content = fallback_inlines(el.content, xe.merge(o, el.t == "Emph" and { i = true } or { b = true }))
      out:insert(el)
    elseif el.content and el.t ~= "Link" and el.t ~= "Quoted" and el.t ~= "Cite" then
      el.content = fallback_inlines(el.content, o)
      out:insert(el)
    else
      out:insert(el)
    end
  end
  return out
end

-- A doubled section or paragraph sign stays with its number (typst boxes "[§¶]{2,} \S+"; xe.inl binds one).
local function doubled_signs(inlines)
  for k = 1, #inlines - 1 do
    local a, b = inlines[k], inlines[k + 1]
    if a.t == "Str" and (a.text == "§§" or a.text == "¶¶") and b.t == "Space" then inlines[k + 1] = pandoc.Str("\u{00A0}") end
  end
  return inlines
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta
  local blocks = doc.blocks

  -- headings numbered I. / A. / 1. (typst heading-numbering); the needles in document order: the contents' title
  -- (roman from i), the memorandum's title with its first heading (arabic from 1), each heading with the words after
  -- it, each `toa:` link, and the memorandum's last line
  need("S:toc", "B", "TABLE OF CONTENTS")
  local counts, entries, labelled = { 0, 0, 0 }, {}, {}
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = math.min(b.level, 3)
      counts[lv] = counts[lv] + 1
      for k = lv + 1, 3 do counts[k] = 0 end
      local n = counts[lv]
      labelled[i] = lv == 1 and (ROMAN[n] .. ".") or lv == 2 and (string.char(64 + n) .. ".") or (n .. ".")
    end
  end
  local first_text = blocks[1] and ((labelled[1] or "") .. " " .. text_of(blocks[1].content or {})) or ""
  need("S:memo", "B", "MEMORANDUM IN SUPPORT OF MOTION", first_text)
  local h_n = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = blocks[i + 1] and blocks[i + 1].content and text_of(blocks[i + 1].content) or ""
      need(id, "B", labelled[i] .. " " .. text_of(b.content), nxt)
      if b.level <= 3 then entries[#entries + 1] = { id = id, level = b.level, label = labelled[i], title = b.content } end
      scan_links(b.content, "B")
    elseif b.t == "Para" or b.t == "Plain" then
      scan_links(b.content, "B")
    else
      pandoc.Pandoc({ b }):walk({ Para = function(x) scan_links(x.content, "B") end,
        Plain = function(x) scan_links(x.content, "B") end })
    end
  end
  local sig = list(meta.signature and meta.signature.blocks)
  local last_lines = sig[#sig] and list(sig[#sig].lines) or {}
  local last = ""
  for _, l in ipairs(last_lines) do
    if plain(l) ~= "" then last = plain(l) end
  end
  need("S:end", "B", last)
  local nl = { table.concat(needles, "\n"), "#section\tS:toc\tlower-roman\t", "#section\tS:memo\tdecimal\t" }
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  -- links keep their text; the break rules on every run pandoc writes
  blocks = blocks:walk({ Link = function(l) return l.content end }):walk({ Inlines = doubled_signs })
    :walk({ Inlines = binds })
    :walk({ Str = breaks }):walk({ Inlines = xe.inlines })
    :walk({ Para = function(x) x.content = fallback_inlines(x.content) return x end,
      Plain = function(x) x.content = fallback_inlines(x.content) return x end })

  local out = {}
  local function raw(x) out[#out + 1] = xe.raw(fallback_xml(x)) end
  for _, x in ipairs(cover(meta)) do raw(x) end
  -- the motion: unnumbered paragraphs, a single line below the caption, then the signature
  for k, m in ipairs(list(meta.motion)) do
    raw(p(xe.inl(m), { line = BODY, first = INDENT, before = k == 1 and SINGLE or 0 }))
  end
  for _, x in ipairs(signature(meta)) do raw(x) end
  raw(section_end("rIdFtrPage", "decimal", "rIdFtrNone"))
  for _, x in ipairs(contents(entries)) do raw(x) end
  for _, x in ipairs(authorities(meta)) do raw(x) end
  raw(section_end("rIdFtrPage", "lowerRoman"))

  raw(title_line("MEMORANDUM IN SUPPORT OF MOTION"))
  -- the last paragraph stays whole with the signature (typst: one unbreakable block), unless it is a heading
  local tail = #blocks
  if blocks[tail] and blocks[tail].t ~= "Para" then tail = nil end
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      raw(heading(b, labelled[i]))
    elseif b.t == "Para" or b.t == "Plain" then
      local style = i == tail and "Body Text Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BlockQuote" then
      out[#out + 1] = pandoc.Div(b.content, { ["custom-style"] = "Block Text" })
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("hid.lua: unsupported block " .. b.t)
    end
  end
  for _, x in ipairs(signature(meta)) do raw(x) end

  -- LR 7.4(b), (e): past 25 pages the memorandum must keep to 6,250 words and certify its count
  local pages = tonumber(labels["S:end"] or "")
  if pages and pages > PAGE_LIMIT then
    local words = count_words()
    if words > WORD_LIMIT then
      error("hid.lua: the memorandum is " .. pages .. " pages and " .. words .. " words; LR 7.4 allows 25 pages or 6,250 words")
    end
    raw(title_line("CERTIFICATE OF COMPLIANCE", true))
    raw(body_par(xe.runs("The undersigned certifies that the foregoing memorandum complies with the word limit of " ..
      "LR 7.4(b) and contains " .. words .. " words, counted from the headings, text, quotations and footnotes of " ..
      "the memorandum. The caption, table of contents, table of authorities and certificates are not counted " ..
      "(LR 7.4(d)).")))
    for _, x in ipairs(signature(meta)) do raw(x) end
  end
  local svc = meta.service
  if svc and svc.certificate then
    raw(title_line("CERTIFICATE OF SERVICE", true))
    raw(body_par(xe.runs("I hereby certify that on ") .. xe.inl(svc.date) .. xe.runs(", the foregoing document was " ..
      "filed electronically through the CM/ECF system, which will send notice of the filing to all counsel of record.")))
    local o = {}
    sig_lines(list(svc.signature), o, SINGLE)
    o[#o] = o[#o]:gsub("<w:keepNext/>", "", 1)
    for _, x in ipairs(o) do raw(x) end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
