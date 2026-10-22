-- nysb memorandum of law in support of a motion, docx engine (docs/DOCX.md): what the Word output adds to pandoc's
-- conversion, so that it reads and breaks as typst/nysb-motion-brief.typ does: the cover (counsel, LBR 9004-1(a)(4);
-- the court; the Form 416D caption, a table whose party column has a right and a bottom rule, "v." or "against"
-- between the parties, a debtors' note marked "*"; the title) in a section without a page number; the table of
-- contents (each heading with its label and page) numbered i, ii, ...; then the memorandum numbered from 1: the numbered
-- paragraphs (a paragraph marked "^" is not numbered), the headings (level 1 centered capitals; under ARGUMENT level 2
-- I., II. and level 3 A., B.; elsewhere level 2 A., B. and level 3 1., 2.), lists lettered (a), (b), ..., and the
-- signature block (a table). Numbers and letters are typed text, as the typst template types them. Every case word
-- comes from the frontmatter and the body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES: the contents' title, the memorandum's first words and every heading with its label and the words
-- after it) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle. It writes
-- the footers the sections name (rIdFtrNone, rIdFtrPage, a cover note's from FORMBOOK_FOOTERS) and the last section
-- (FORMBOOK_FINAL). Word may paginate slightly differently from LibreOffice.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276                -- typst pitch-body, pitch-single
local TEXTW = 9360                           -- typst text-width: 6.5 in
local CAP_LEFT, CAP_GUTTER = 4824, 288       -- typst caption-left 3.35 in, caption-gutter 0.2 in
local CAP_INSET = 216                        -- typst caption-inset 0.15 in
local RULE = 15                              -- the 0.75 pt bottom rule LibreOffice adds to the cell's height (typst
                                             -- strokes take no room): the cell's bottom padding is that much less
local SIG_LEFT, SIG_GUTTER = 4032, 288       -- typst sig-left 2.8 in, sig-gutter 0.2 in
local LABEL = 720                            -- typst label-box 0.5 in
local PAGE_COL = 720                         -- typst page-col 0.5 in
local GROUP_GAP = 138                        -- typst group-gap (half a single line)
local PARTY_GAP = 138                        -- typst party-gap (half a single line)
local BLOCK_GAP = 276                        -- typst block-gap (a blank single line)
local TITLE_ABOVE = 276                      -- typst title-above
local PAGE_HEAD_ABOVE = 276                  -- typst page-head-above
local ROW_ABOVE = 276                        -- typst row-above
local FOOTER = 735                           -- the page number's line 36.75 pt above the page foot (typst footer-descent 30 %)
local NOTE_CLEAR = 130                       -- a cover note's rule to its text: 6.5 pt, where the typst render sets its
                                             -- footnote separator above the note
-- a cover note's mark: "*" raised as a footnote mark is (typst: a footnote numbered "*")
local NOTE_MARK = '<w:r><w:rPr><w:vertAlign w:val="superscript"/></w:rPr><w:t>*</w:t></w:r>'
local COURT = { "UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF NEW YORK" } -- Form 416D; Fed. R. Bankr. P. 9004(b)
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- Paragraph properties: o = { style, keep, lines, tabs, before, after, line, left, right, hanging, first, jc, sect };
-- single pitch by default; tabs = { { kind, pos, leader } }.
local function props(o)
  local pr = {}
  if o.style then pr[#pr + 1] = xe.style(o.style) end
  if o.keep then pr[#pr + 1] = xe.KEEP elseif o.lines then pr[#pr + 1] = xe.LINES end
  if o.tabs then
    local t = {}
    for _, s in ipairs(o.tabs) do
      t[#t + 1] = '<w:tab w:val="' .. s[1] .. '"' .. (s[3] and (' w:leader="' .. s[3] .. '"') or "") .. ' w:pos="' .. s[2] .. '"/>'
    end
    pr[#pr + 1] = "<w:tabs>" .. table.concat(t) .. "</w:tabs>"
  end
  pr[#pr + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  pr[#pr + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  pr[#pr + 1] = xe.jc(o.jc or "left")
  if o.sect then pr[#pr + 1] = o.sect end
  return pr
end

local function p(body, o)
  return xe.para(props(o or {}), body or "")
end

-- A section's properties: its footer (fb render's rIdFtrNone or rIdFtrPage, or a cover note's) and the footer's
-- distance from the page foot, the page numbers (fmt from start), letter paper with 1-inch margins.
local function sect_pr(footer, fmt, start, distance)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="' .. start .. '"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. (distance or FOOTER) .. '" w:gutter="0"/>' .. pg .. '</w:sectPr>'
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
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

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A one-row table without rules or cell padding: the opening up to the first cell's paragraphs, a cell break, and the
-- close; cells = { { width, tcPr children } }.
local function tbl_open(cells)
  local grid = {}
  for _, c in ipairs(cells) do grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
end
local function tc_open(c)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[2] or "") .. '</w:tcPr>'
end
local TC_CLOSE, TBL_CLOSE = '</w:tc>', '</w:tr></w:tbl>'
-- ---------------------------------------------------------------------------
-- The cover: counsel, the court, the caption, the title; its section has no page number. The debtors' note (their
-- tax-identification numbers, as in the exemplar) is marked "*" on their last name and set at the foot of the cover,
-- in the cover section's footer: a Word footnote would take a number, and LibreOffice cannot number the body's notes
-- from 1 again after it (typst: a footnote numbered "*", the body's notes counted from 1).
-- ---------------------------------------------------------------------------

local function cover(m)
  local x = {}
  local function add(s) x[#x + 1] = s end
  for k, g in ipairs(items(m.counsel)) do
    for i, l in ipairs(items(g)) do add(p(xe.inl(l), { before = (k > 1 and i == 1) and GROUP_GAP or 0 })) end
  end
  if m.counsel_for then add(p(xe.inl(m.counsel_for, { i = true }), { before = GROUP_GAP })) end
  add(p(xe.runs(COURT[1], { b = true }), { before = BLOCK_GAP, jc = "center" }))
  add(p(xe.runs(COURT[2], { b = true }), { jc = "center" }))
  -- Word has no space before a table: the court's last line would take it as space after; an empty line box of the
  -- gap's height does the same and keeps the court lines plain.
  add(xe.para({ xe.spacing(0, 0, BLOCK_GAP) }, ""))

  -- the caption: the party column (right and bottom rules), the case data
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  local left = { CAP_LEFT, '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/><w:bottom w:w="' .. (CAP_INSET - RULE) .. '" w:type="dxa"/></w:tcMar>' }
  local right = { TEXTW - CAP_LEFT, '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + CAP_INSET) .. '" w:type="dxa"/></w:tcMar>' }
  add(tbl_open({ left, right }) .. tc_open(left))
  local c = m.caption
  local note
  local function party(pt, above)
    local names = items(pt.names)
    for i, n in ipairs(names) do
      local mark = ""
      if i == #names and pt.note then
        note = pt.note
        mark = NOTE_MARK
      end
      add(p(xe.inl(n) .. mark, { before = i == 1 and above or 0 }))
    end
    add(p(xe.inl(pt.designation), { jc = "right" }))
  end
  party(c.debtors, 0)
  local sep = c.separator and plain(c.separator) or "against"
  for k, pt in ipairs(items(c.parties)) do
    if k > 1 then add(p(xe.runs(sep), { before = PARTY_GAP, jc = "center" })) end
    party(pt, PARTY_GAP)
  end
  add(TC_CLOSE .. tc_open(right))
  add(p(xe.runs("Chapter " .. plain(m.chapter))))
  add(p(xe.runs("Case No. " .. plain(m.case_number)), { before = BLOCK_GAP }))
  if m.jointly_administered == true then add(p(xe.runs("(Jointly Administered)"))) end
  add(p(xe.runs("Adv. Pro. No. " .. plain(m.adv_proc_no)), { before = BLOCK_GAP }))
  add(TC_CLOSE .. TBL_CLOSE)

  -- the cover's footer: the note under a rule 30 % of the measure long (typst's footnote separator), its last line
  -- at the foot of the text (footer distance 1440); without a note, no footer
  local footer, distance = "rIdFtrNone", FOOTER
  if note then
    footer, distance = "rIdFtrNote", 1440
    local rule_line = xe.para({ '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:pBdr>',
      xe.spacing(0, NOTE_CLEAR, 20), xe.ind(0, nil, 0, TEXTW - TEXTW * 3 // 10) }, "")
    local text = p(NOTE_MARK .. xe.runs(" ") .. xe.inl(note), { keep = true })
    write_file("FORMBOOK_FOOTERS", footer .. "\t" .. rule_line .. text .. "\n")
  end
  -- the title, a blank single line below the caption (Word has no space after a table: the title takes it before);
  -- it ends the cover's section
  add(p(xe.inl(m.title, { b = true }), { before = TITLE_ABOVE, jc = "center", sect = sect_pr(footer, nil, nil, distance) }))
  return table.concat(x)
end



-- ---------------------------------------------------------------------------
-- Signature block: "Dated:" at the left; the firm, "By: /s/" and the signer's lines at the right; the row never
-- splits. The double line above it is the last paragraph's space after (Body Keep, Lettered Keep).
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local left = { SIG_LEFT }
  local right = { TEXTW - SIG_LEFT, '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>' }
  local out = { tbl_open({ left, right }), tc_open(left), p(xe.runs("Dated: ") .. xe.inl(m.date), { keep = true }),
    TC_CLOSE, tc_open(right) }
  for _, l in ipairs(items(sig.firm)) do out[#out + 1] = p(xe.inl(l), { keep = true }) end
  out[#out + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = BLOCK_GAP, keep = true })
  out[#out + 1] = p(xe.inl(sig.signer), { keep = true })
  for _, l in ipairs(items(sig.lines)) do out[#out + 1] = p(xe.inl(l), { keep = true }) end
  out[#out + 1] = TC_CLOSE .. TBL_CLOSE
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function labelled(style, label, content)
  local inl = pandoc.Inlines({ pandoc.Str(label), TAB })
  inl:extend(content)
  return styled(style, inl)
end

-- Headings on the body pitch, kept with what follows: level 1 centered bold capitals; levels 2 and 3 bold, the label
-- at the heading's indent in a half-inch box (a tab), the title hanging after it.
local function heading(level, label, ind, content)
  if level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return xe.raw(xe.para({ xe.style("Heading1"), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
      xe.inl(content, { b = true })))
  end
  return xe.raw(p(xe.runs(label .. "\t", { b = true }) .. xe.inl(content, { b = true }), { style = "Heading" .. level,
    keep = true, tabs = { { "left", ind + LABEL } }, line = BODY, left = ind + LABEL, hanging = LABEL }))
end

-- Where a heading's label starts and what it reads (typst label-indent, heading-label): under ARGUMENT level 2 I., II.
-- at the margin and level 3 A., B. half an inch in; elsewhere level 2 A., B. half an inch in and level 3 1., 2. an inch in.
local function roman(n)
  local v, s, r = { 10, 9, 5, 4, 1 }, { "X", "IX", "V", "IV", "I" }, ""
  for i = 1, #v do
    while n >= v[i] do r, n = r .. s[i], n - v[i] end
  end
  return r
end
local function label_of(level, k, in_argument)
  if level == 2 then return (in_argument and roman(k) or string.char(64 + k)) .. "." end
  return (in_argument and string.char(64 + k) or tostring(k)) .. "."
end
local function label_indent(level, in_argument)
  return (in_argument and (level - 2) or (level - 1)) * LABEL
end

-- The table of contents (typst contents): the title, "Page" over the page column, then one row per heading with a
-- blank single line above it: the label at the heading's indent and a tab, the title wrapping before the page column
-- (right indent), xe.LEAD and a dot leader to the page at the right margin. Rows are not split.
local function contents(entries)
  local out = {
    p(xe.runs("TABLE OF CONTENTS", { b = true }), { line = BODY, jc = "center", keep = true }),
    p(xe.runs("Page", { b = true }), { before = PAGE_HEAD_ABOVE, jc = "right", keep = true }),
  }
  for _, e in ipairs(entries) do
    local page = labels[e.id] or "0"
    local lead = xe.runs(xe.LEAD .. page)
    if e.level == 1 then
      local caps = e.title:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
      out[#out + 1] = p(xe.inl(caps) .. lead, { lines = true, tabs = { { "right", TEXTW, "dot" } }, before = ROW_ABOVE,
        right = PAGE_COL })
    else
      out[#out + 1] = p(xe.runs(e.label .. "\t") .. xe.inl(e.title) .. lead, { lines = true,
        tabs = { { "left", e.ind + LABEL }, { "right", TEXTW, "dot" } }, before = ROW_ABOVE, left = e.ind + LABEL,
        hanging = LABEL, right = PAGE_COL })
    end
  end
  return table.concat(out)
end

-- "^" at the start of a paragraph: not numbered (the opening paragraph).
local function unmarked(inl)
  local first = inl[1]
  if not (first and first.t == "Str" and first.text:sub(1, 1) == "^") then return nil end
  local rest = pandoc.Inlines({})
  if #first.text > 1 then rest:insert(pandoc.Str(first.text:sub(2))) end
  for i = 2, #inl do rest:insert(inl[i]) end
  if rest[1] and rest[1].t == "Space" then rest:remove(1) end
  return rest
end

-- The memorandum; fills `entries` (the contents) and the needles of its headings, each with its label and the words
-- after it (the next block's first words, a following heading's label included).
local function body(blocks, entries)
  -- the last paragraph or list item keeps with the signature block
  local last = 0
  for i, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" or b.t == "OrderedList" or b.t == "BulletList" then last = i end
  end
  local out = {}
  local n, c2, c3, in_argument = 0, 0, 0, false
  local pending -- a heading's needle, waiting for the words after it
  local function words(text)
    if pending then
      need(pending[1], pending[2], text:sub(1, 40))
      pending = nil
    end
  end
  for i, b in ipairs(blocks) do
    local keep = i == last
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      local title = stringify(b.content)
      local label, ind = nil, 0
      if level == 1 then
        c2, c3 = 0, 0
        in_argument = title:upper():find("ARGUMENT", 1, true) ~= nil
      else
        if level == 2 then c2, c3 = c2 + 1, 0 else c3 = c3 + 1 end
        label = label_of(level, level == 2 and c2 or c3, in_argument)
        ind = label_indent(level, in_argument)
      end
      local id = "H:" .. (#entries + 1)
      local text = (label and (label .. " ") or "") .. title
      words(text)
      pending = { id, text }
      entries[#entries + 1] = { id = id, level = level, label = label, ind = ind, title = b.content }
      out[#out + 1] = heading(level, label, ind, b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      local rest = unmarked(b.content)
      if rest then
        words(stringify(rest))
        out[#out + 1] = styled(keep and "Body Keep" or "Body Text", rest)
      else
        n = n + 1
        words(n .. ". " .. stringify(b.content))
        out[#out + 1] = labelled(keep and "Body Keep" or "Body Number", n .. ".", b.content)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and ("(" .. string.char(96 + k) .. ")") or "\u{2022}"
        words(label .. " " .. stringify(item))
        out[#out + 1] = labelled((keep and k == #b.content) and "Lettered Keep" or "Lettered", label,
          pandoc.utils.blocks_to_inlines(item))
      end
    else
      error("nysb-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  words("")
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there): the space becomes a no-break space, as wide. A space before a footnote mark is dropped, as the typst
-- template does (its markdown renderer trims it). A doubled section sign or pilcrow stays with its number ("§§ 544":
-- the typst template boxes it): a no-break space after it.
local function inline_rules(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  for i = 1, #l - 1 do
    local a = l[i]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  local out = pandoc.Inlines({})
  for i, el in ipairs(l) do
    local nxt = l[i + 1]
    if not (el.t == "Space" and nxt and nxt.t == "Note") then out:insert(el) end
  end
  return out
end

-- The paragraph that ends a section (a 1 pt line, so it never pushes a full page's last line on).
local function section_end(sect)
  return xe.para({ xe.spacing(0, 0, 20), sect }, "")
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  -- the needles, in document order: the contents' title (roman from i), the memorandum's first words (arabic from 1),
  -- then (body) each heading with its label and the words after it
  need("S:toc", "TABLE OF CONTENTS")
  local first = doc.blocks[1]
  local first_text = first and stringify(first) or ""
  if first and (first.t == "Para" or first.t == "Plain") then
    local rest = unmarked(first.content)
    first_text = rest and stringify(rest) or ("1. " .. first_text)
  end
  need("S:body", first_text:sub(1, 60))
  local entries = {}
  local out = pandoc.Blocks(body(doc.blocks, entries))
  out = out:walk({ Inlines = xe.inlines })
  out:insert(1, xe.raw(cover(m) .. contents(entries) .. section_end(sect_pr("rIdFtrPage", "lowerRoman", 1))))
  out:insert(xe.raw(signature(m)))
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\tS:body\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  -- the memorandum's section: the page number centered, from 1
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal", 1))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = inline_rules }, { Pandoc = finish } }
