-- texapp.lua (docx engine): the Texas Court of Appeals briefs (opening, answering and reply briefs; one copy per
-- folder) as Word paragraphs, so that they read and break as ../typst/texapp-<doc>.typ (the reference for the form)
-- does (cross-engine layout model, docs/EVAL-LOOP.md; lib/docx/xengine.lua):
--   * the cover (TRAP 9.4(g)): single centered lines with rules between the parts, counsel in the right half, the
--     oral-argument request (TRAP 39.7) and cover notes;
--   * the front matter (before `{{contents}}`), the table of contents (TRAP 38.1(b)) and the index of authorities
--     (TRAP 38.1(c)) on lower-roman pages, the cover counting as i; the body on arabic pages from 1;
--   * the identity of parties and counsel (`{{identity}}`, TRAP 38.1(a)) and a two-column markdown table as label
--     rows (a table, the label in a 2.25 in column, a row never split);
--   * headings, body paragraphs (a paragraph under 50 characters at the margin; one ending in a colon kept with what
--     follows), block quotations, lists and footnotes in the styles of docx/reference.xml; the last block before
--     `{{signature}}` kept with the signature; each certificate kept on one page with its `{{signer}}`;
--   * the word count of TRAP 9.4(i)(1) in place of `{{word-count}}`, counted as the typst template counts.
-- Page numbers of the contents and the index: fb render's multi-pass build (tools/fb/src/docxpass.rs,
-- docxpages.rs): this filter writes a needle per heading and per occurrence of an authority's `find` string to
-- FORMBOOK_NEEDLES and reads the pages of the previous pass from FORMBOOK_PAGES (were docx/render.sh's two passes).
-- Every case word comes from the frontmatter or the body. No coordinates, no forced line breaks.
-- Twips = 20 x the typst pt values.

local xe = require("docx.xengine")

local BODY, SINGLE = 630, 322            -- typst pitch-body, pitch-single
local TEXTW = 9360                       -- 6.5 in
local INDENT = 720                       -- typst para-indent
local LABEL, GUTTER = 3240, 360          -- typst label-column 2.25 in, label-gutter 0.25 in
local ROW_GAP = 280                      -- typst row-gap
local SIG, SIG_ABOVE = 4320, 440         -- typst sig-indent 3 in, sig-above 22 pt
local QUOTE = 280                        -- typst quote-gap
local H1_ABOVE, H1_BELOW = 480, 240      -- typst h1-above, h1-below
local TOC_COL, TOA_COL = 720, 1120       -- typst toc-col 36 pt, toa-col 56 pt
local HANG, STEP = 360, 576              -- typst row-hang 0.25 in, toc-step 0.4 in
local TOC_ABOVE, TOC_ABOVE1 = 160, 280   -- typst toc-above, toc-above-1
local GROUP_ABOVE = 440                  -- typst group-above
local SHORT = 50                         -- typst short-line
local NEEDLE_MAX = 60
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local COVER_SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdRomanFtr"/>'
  .. '<w:footerReference w:type="first" r:id="rIdFtrNone"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:pgNumType w:fmt="lowerRoman" w:start="1"/><w:titlePg/></w:sectPr>'
local BODY_SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdArabicFtr"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'
-- the page number centered in a single line (typst: the footer's single-pitch line box)
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
-- the empty paragraph that ends a section takes no room
local SECT_LINE = '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'

local stringify = pandoc.utils.stringify
local function fail(msg) error("texapp.lua: " .. msg, 0) end

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  if type(m) == "boolean" then return tostring(m) end
  return stringify(m)
end

local function list(v)
  local out = {}
  if v == nil then return out end
  for _, x in ipairs(v) do out[#out + 1] = x end
  return out
end

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

-- ---------------------------------------------------------------------------
-- Break rules typst and LibreOffice do not share (docs/EVAL-LOOP.md, "What the federal-circuit fan-out found")
-- ---------------------------------------------------------------------------

-- none inside ")(" (a word joiner), one after a slash before a letter (a zero-width space); neither shows in the
-- PDF text
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- a doubled sign stays with its number ("§§ 54.02(d)": the typst template binds every "§ " with a no-break space)
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text:match("\u{00A7}$") or a.text:match("\u{00B6}$")) and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function fix(x)
  return x:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
end

-- ---------------------------------------------------------------------------
-- Paragraphs
-- ---------------------------------------------------------------------------

-- A raw paragraph: o = { style, before, after, line, left, hanging, first, right, jc, keep, lines, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = { xe.style(o.style or "TexSingle") }
  if o.keep then props[#props + 1] = "<w:keepNext/>" end
  if o.keep or o.lines then props[#props + 1] = "<w:keepLines/>" end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  if o.before or o.after or o.line then
    props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  end
  if o.left or o.hanging or o.first or o.right then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, o.first, o.right)
  end
  if o.jc then props[#props + 1] = xe.jc(o.jc) end
  return xe.raw(xe.para(props, body))
end

-- metadata or markdown text as inlines with the break rules
local function minl(v)
  if v == nil then return pandoc.Inlines({}) end
  local il
  if type(v) == "string" then il = pandoc.Inlines({ pandoc.Str(v) })
  elseif v.t == "MetaBlocks" then il = pandoc.utils.blocks_to_inlines(v)
  elseif v.t == "MetaString" then il = pandoc.Inlines({ pandoc.Str(v.text or v[1] or "") })
  else il = pandoc.Inlines(v) end
  return fix(pandoc.Plain(il)).content
end

local function upper_il(il)
  return pandoc.Plain(il):walk({ Str = function(e) return pandoc.Str(pandoc.text.upper(e.text)) end }).content
end

-- lines from the frontmatter, one paragraph each; an empty one is an empty line
local function lines_of(ls, o, out)
  local n = #ls
  for i, l in ipairs(ls) do
    local oo = {}
    for k, v in pairs(o) do oo[k] = v end
    if i > 1 then oo.before = 0 end
    if o.keep and i == n then oo.keep = nil; oo.lines = true end
    out[#out + 1] = p(plain(l) == "" and "" or xe.inl(minl(l)), oo)
  end
end

-- ---------------------------------------------------------------------------
-- Words (TRAP 9.4(i)): the typst template's word-count, on the markdown source
-- ---------------------------------------------------------------------------

local EXCLUDED = { "identit", "table of contents", "index of authorities", "table of authorities",
  "statement regarding oral argument", "statement concerning oral argument", "statement of the case",
  "issue presented", "issues presented", "statement of jurisdiction", "procedural history", "certificate", "appendix" }

local function count_words(s)
  s = s:gsub("{{[a-z%-]+}}", "")
  local n = 0
  for w in s:gmatch("%S+") do
    if w:find("[A-Za-z0-9]") then n = n + 1 end
  end
  return n
end

local function word_count()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then fail("no input file to count words in") end
  local h = assert(io.open(f, "r"))
  local src = h:read("a")
  h:close()
  local s, e = src:find("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n")
  if not s then fail("the sample must start with a YAML frontmatter block") end
  local body = src:sub(e + 1)
  -- chunks at every line that starts with "# "
  local chunks, pos = {}, 1
  local text = body
  local starts = {}
  if text:sub(1, 2) == "# " then starts[#starts + 1] = 1 end
  for i in text:gmatch("()\n# ") do starts[#starts + 1] = i + 1 end
  local first_end = (starts[1] or (#text + 1)) - 1
  local total = count_words(text:sub(1, first_end))
  for k, st in ipairs(starts) do
    local chunk = text:sub(st + 2, (starts[k + 1] or (#text + 1)) - 1)
    local title = trim(chunk:match("^[^\n]*")):lower()
    local skip = false
    for _, x in ipairs(EXCLUDED) do
      if title:sub(1, #x) == x then skip = true end
    end
    if not skip then total = total + count_words(chunk) end
  end
  return total
end

-- ---------------------------------------------------------------------------
-- Needles and pages (fb render's multi-pass build; the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function letters(s)
  return (s:lower():gsub("\u{00A0}", " "):gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, kind, text, context)
  local w1, w2 = text:match("^%s*(%S+)%s+(%S+)")
  local short = letters(w1 and (w1 .. " " .. w2) or text):sub(1, NEEDLE_MAX)
  local long = letters(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, kind, long, short }, "\t")
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
local function label_of(id) return labels[id] or "0" end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The text of a block for the search, with "\1" where a footnote mark stands (a needle's context stops there),
-- and its footnotes' texts.
local function block_text(b)
  local notes = {}
  local function il(inls)
    local out = {}
    for _, el in ipairs(inls) do
      if el.t == "Note" then
        out[#out + 1] = "\1"
        notes[#notes + 1] = stringify(el.content)
      elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then out[#out + 1] = " "
      elseif el.t == "Str" then out[#out + 1] = el.text
      elseif el.t == "Quoted" or el.t == "Emph" or el.t == "Strong" or el.t == "Span" or el.t == "Link"
        or el.t == "Underline" or el.t == "SmallCaps" or el.t == "Strikeout" or el.t == "Superscript"
        or el.t == "Subscript" then out[#out + 1] = il(el.content)
      else out[#out + 1] = stringify(el) end
    end
    return table.concat(out)
  end
  local parts = {}
  local function blocks(bs)
    for _, x in ipairs(bs) do
      if x.t == "Para" or x.t == "Plain" or x.t == "Header" then parts[#parts + 1] = il(x.content)
      elseif x.t == "BlockQuote" or x.t == "Div" then blocks(x.content)
      elseif x.t == "BulletList" or x.t == "OrderedList" then
        for _, item in ipairs(x.content) do blocks(item) end
      elseif x.t == "Table" then parts[#parts + 1] = stringify(x)
      end
    end
  end
  blocks({ b })
  return table.concat(parts, " "), notes
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

-- Label rows (typst label-rows): a table without borders or cell margins, the label in a 2.25 in column, the text
-- beside it after a 0.25 in gutter; a row never split.
local function label_rows(rows)
  local tw = TEXTW - LABEL - GUTTER
  local trs = {}
  -- between two rows an empty row of row-gap (typst: an empty block; LibreOffice keeps a cell's space above at the
  -- top of a page, which typst drops)
  local gap = xe.para({ xe.style("TexSingle"), xe.spacing(0, 0, ROW_GAP) }, "")
  for i, r in ipairs(rows) do
    if i > 1 then
      trs[#trs + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. tc(LABEL + GUTTER, gap) .. tc(tw, gap) .. "</w:tr>"
    end
    local above = i == 1 and ROW_GAP or 0
    trs[#trs + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. tc(LABEL + GUTTER, r[1](above))
      .. tc(tw, r[2](above)) .. "</w:tr>"
  end
  return xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. (LABEL + GUTTER) .. '"/><w:gridCol w:w="' .. tw .. '"/></w:tblGrid>'
    .. table.concat(trs) .. '</w:tbl>')
end

-- one cell paragraph's XML (the label's right indent is the gutter)
local function cell_p(body, before, right)
  local props = { xe.style("TexSingle"), xe.spacing(before, 0, SINGLE) }
  if right then props[#props + 1] = xe.ind(0, nil, 0, right) end
  return xe.para(props, body)
end

local function identity_rows(meta)
  local rows = {}
  for _, e in ipairs(list(meta.identity)) do
    rows[#rows + 1] = {
      function(gap) return cell_p(xe.inl(minl(e.role), { b = true }), gap, GUTTER) end,
      function(gap)
        local ps = {}
        for i, l in ipairs(list(e.lines)) do
          ps[#ps + 1] = cell_p(plain(l) == "" and "" or xe.inl(minl(l)), i == 1 and gap or 0)
        end
        return table.concat(ps)
      end,
    }
  end
  return label_rows(rows)
end

local function table_rows(t)
  local rows = {}
  local function cell_inlines(cell)
    local il = pandoc.Inlines({})
    for _, b in ipairs(cell.contents) do
      if b.t == "Plain" or b.t == "Para" then il:extend(b.content) else il:insert(pandoc.Str(stringify(b))) end
    end
    return fix(pandoc.Plain(il)).content
  end
  local all = {}
  for _, r in ipairs(t.head.rows) do all[#all + 1] = r end
  for _, body in ipairs(t.bodies) do
    for _, r in ipairs(body.head) do all[#all + 1] = r end
    for _, r in ipairs(body.body) do all[#all + 1] = r end
  end
  for _, r in ipairs(all) do
    local c = r.cells
    if #c ~= 2 then fail("only two-column tables are supported") end
    local a, b = cell_inlines(c[1]), cell_inlines(c[2])
    rows[#rows + 1] = {
      function(gap) return cell_p(xe.inl(a), gap, GUTTER) end,
      function(gap) return cell_p(xe.inl(b), gap) end,
    }
  end
  return label_rows(rows)
end

-- the signature block: single lines in the right half, kept together
local function signature(ls, out)
  lines_of(list(ls), { before = SIG_ABOVE, left = SIG, keep = true }, out)
end

-- ---------------------------------------------------------------------------
-- The cover (TRAP 9.4(g))
-- ---------------------------------------------------------------------------

local function cover(m, out)
  local function c(before, body) out[#out + 1] = p(body, { before = before, jc = "center" }) end
  local function rule(before)
    out[#out + 1] = xe.raw(xe.para({ xe.style("TexSingle"),
      '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr>',
      xe.spacing(before, 0, 20) }, ""))
  end
  local district = plain(m.district) ~= "" and plain(m.district) or "Fifth"
  local seat = plain(m.seat) ~= "" and plain(m.seat) or "Dallas"
  c(0, xe.inl(pandoc.Inlines({ pandoc.Str("No."), pandoc.Space() }) .. minl(m.case_number)))
  rule(220)
  c(140, xe.runs("IN THE COURT OF APPEALS", { b = true }))
  c(0, xe.runs("FOR THE " .. pandoc.text.upper(district) .. " DISTRICT OF TEXAS", { b = true }))
  c(0, xe.runs("AT " .. pandoc.text.upper(seat), { b = true }))
  rule(140)
  if m.caption then c(220, xe.inl(minl(m.caption), { b = true })) end
  c(220, xe.inl(upper_il(minl(m.appellant)), { b = true }))
  c(0, xe.runs("Appellant,"))
  c(140, xe.runs("v."))
  c(140, xe.inl(upper_il(minl(m.appellee)), { b = true }))
  c(0, xe.runs("Appellee."))
  rule(220)
  c(140, xe.inl(pandoc.Inlines({ pandoc.Str("On"), pandoc.Space(), pandoc.Str("Appeal"), pandoc.Space(),
    pandoc.Str("from"), pandoc.Space(), pandoc.Str("the"), pandoc.Space() }) .. minl(m.trial_court)
    .. pandoc.Inlines({ pandoc.Str(","), pandoc.Space() }) .. minl(m.county)
    .. pandoc.Inlines({ pandoc.Space(), pandoc.Str("County,"), pandoc.Space(), pandoc.Str("Texas") })))
  c(0, xe.inl(pandoc.Inlines({ pandoc.Str("Trial"), pandoc.Space(), pandoc.Str("Court"), pandoc.Space(),
    pandoc.Str("Cause"), pandoc.Space(), pandoc.Str("No."), pandoc.Space() }) .. minl(m.trial_cause)))
  if m.trial_judge then
    c(0, xe.inl(minl(m.trial_judge) .. pandoc.Inlines({ pandoc.Str(","), pandoc.Space(), pandoc.Str("Presiding") })))
  end
  rule(140)
  c(220, xe.inl(upper_il(minl(m.brief_title)), { b = true }))
  rule(220)
  lines_of(list(m.counsel), { before = 720, left = SIG }, out)
  local notes = {}
  if m.oral_argument_requested == true then notes[#notes + 1] = "ORAL ARGUMENT REQUESTED" end
  for _, n in ipairs(list(m.cover_notes)) do notes[#notes + 1] = plain(n) end
  for i, n in ipairs(notes) do c(i == 1 and 440 or 0, xe.runs(n, { b = true })) end
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

local function placeholder(b)
  if b.t ~= "Para" and b.t ~= "Plain" then return nil end
  local s = trim(stringify(b))
  return s:match("^{{([a-z%-]+)}}$")
end

local function has_note(b)
  local note = false
  pandoc.Blocks({ b }):walk({ Note = function() note = true end })
  return note
end

local function para_len(b)
  local s = stringify(b)
  return #trim(s), trim(s):sub(-1) == ":"
end

local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

function Pandoc(doc)
  load_pages()
  -- commonmark (typst's cmarker) reads only "1." and "1)" as list markers: pandoc's other ordered lists ("(1) whether
  -- ...", "K. On June 20 ...", "MM. On March 11 ...") are text again, as commonmark reads them: the items of a tight
  -- list one paragraph, those of a loose list a paragraph each
  doc = doc:walk({
    OrderedList = function(l)
      local a = l.listAttributes
      if a.style == "Decimal" and (a.delimiter == "Period" or a.delimiter == "OneParen") then return nil end
      if a.style == "DefaultStyle" and a.delimiter ~= "TwoParens" then return nil end
      local out, il = {}, pandoc.Inlines({})
      local n = a.start
      for _, item in ipairs(l.content) do
        local lab = tostring(n)
        if a.style == "LowerAlpha" then lab = string.char(96 + n)
        elseif a.style == "UpperAlpha" then lab = string.char(64 + n)
        elseif a.style == "LowerRoman" or a.style == "UpperRoman" then
          lab = roman(n)
          if a.style == "LowerRoman" then lab = lab:lower() end
        end
        lab = a.delimiter == "TwoParens" and ("(" .. lab .. ")") or a.delimiter == "OneParen" and (lab .. ")") or (lab .. ".")
        local loose = item[1] and item[1].t == "Para"
        if #il > 0 then il:insert(pandoc.SoftBreak()) end
        il:insert(pandoc.Str(lab))
        il:insert(pandoc.Space())
        il:extend(pandoc.utils.blocks_to_inlines(item))
        if loose then out[#out + 1] = pandoc.Para(il); il = pandoc.Inlines({}) end
        n = n + 1
      end
      if #il > 0 then out[#out + 1] = pandoc.Para(il) end
      return out
    end,
  })
  local m = doc.meta
  local words = tostring(word_count())
  doc = doc:walk({
    Str = function(el)
      if el.text:find("{{word-count}}", 1, true) then return pandoc.Str((el.text:gsub("{{word%-count}}", words))) end
    end,
  })
  -- the source blocks, with their text for the search, before the break rules change any character
  local blocks = doc.blocks
  local texts = {}
  for i, b in ipairs(blocks) do
    local t, notes = block_text(b)
    texts[i] = { text = t, notes = notes }
  end
  blocks = fix(pandoc.Pandoc(blocks)).blocks

  -- split at {{contents}}
  local ci
  for i, b in ipairs(blocks) do
    if placeholder(b) == "contents" then
      if ci then fail("the markdown needs exactly one {{contents}} line") end
      ci = i
    end
  end
  if not ci then fail("the markdown needs exactly one {{contents}} line") end

  -- the authorities, in index order, with their `find` keys (matched with spaces for no-break spaces)
  local auth = {}
  for _, g in ipairs(list(m.authorities)) do
    for _, a in ipairs(list(g.items)) do
      auth[#auth + 1] = { a = a, key = (plain(a.find) ~= "" and plain(a.find) or plain(a.name)):gsub("\u{00A0}", " "),
        occ = {} }
    end
  end

  -- the headings (contents entries), in document order: { level, inlines, id }
  local heads = {}
  local function head_id(level, il)
    local id = "H:" .. (#heads + 1)
    heads[#heads + 1] = { level = level, il = il, id = id }
    return id
  end
  local function context_after(i)
    local nb = blocks[i + 1]
    if nb == nil or nb.t == "Table" or placeholder(nb) then return "" end
    return texts[i + 1].text:gsub("\1.*$", ""):sub(1, 40)
  end

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- the cover (needle: its first line and the court lines)
  need("S:cover", "B", "No. " .. plain(m.case_number), "In the Court of Appeals")
  cover(m, out)

  -- one stretch of the markdown: blocks a..z; `opens`: the first block opens a page (hard break: no space above)
  local occ_n = 0
  local function search(i, kind_main)
    if not kind_main then return end
    local t = texts[i].text:gsub("\u{00A0}", " ")
    local hits = {}
    for k, au in ipairs(auth) do
      local from = 1
      while true do
        local s, e = t:find(au.key, from, true)
        if not s then break end
        hits[#hits + 1] = { s = s, e = e, k = k }
        from = e + 1
      end
    end
    table.sort(hits, function(x, y) return x.s < y.s or (x.s == y.s and x.k < y.k) end)
    for _, hh in ipairs(hits) do
      occ_n = occ_n + 1
      local id = "A:" .. occ_n
      -- the words after it, into the blocks that follow (a key reduced to letters and digits, "5402h", may stand in
      -- other text: "Section 54.02(h) and Moon require" against "§ 54.02(h) and Moon? Issue Two")
      local rest = t:sub(hh.e + 1)
      for k = i + 1, math.min(#texts, i + 3) do rest = rest .. " " .. texts[k].text end
      rest = rest:gsub("\1.*$", "")
      need(id, "B", auth[hh.k].key, rest)
      table.insert(auth[hh.k].occ, id)
    end
    for _, n in ipairs(texts[i].notes) do
      local nt = n:gsub("\u{00A0}", " ")
      for k, au in ipairs(auth) do
        local from = 1
        while true do
          local s, e = nt:find(au.key, from, true)
          if not s then break end
          occ_n = occ_n + 1
          local id = "A:" .. occ_n
          need(id, "N", au.key, nt:sub(e + 1))
          table.insert(auth[k].occ, id)
          from = e + 1
        end
      end
    end
  end

  local first_body_id
  local function heading(i, b, opens)
    local style = "TexHead" .. math.min(b.level, 4)
    local id = head_id(b.level, b.content)
    need(id, "B", stringify(b.content), context_after(i))
    local o = { style = style }
    if opens then o.brk = opens ~= "section"; o.before = 0; o.after = b.level == 1 and H1_BELOW or 160; o.line = SINGLE end
    -- a label-row table right after a heading: the row's own space alone (Word does not collapse across a table)
    if blocks[i + 1] and blocks[i + 1].t == "Table" then
      o.before = o.before or (b.level == 1 and H1_ABOVE or 320); o.after = 0; o.line = SINGLE
    end
    add(p(xe.inl(b.content), o))
    return id
  end

  local function body_para(b, keep_all)
    local n, colon = para_len(b)
    local flush = n < SHORT
    if keep_all then
      add(p(xe.inl(b.content), { style = flush and "BodyFlush" or "BodyText", keep = true }))
      return
    end
    local style = flush and "Body Flush" or "Body Text"
    if colon then style = flush and "Body Flush Lead" or "Body Lead"
    elseif has_note(b) then style = flush and "Body Flush Note" or "Body Text Note" end
    add(pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style }))
  end

  -- a block written whole and kept with what follows (the last block before a signature, a certificate)
  -- (last_only: of a list, only its last item is kept with what follows, as typst keeps it with the signature)
  local function kept(b, last_only)
    if b.t == "Para" or b.t == "Plain" then body_para(b, true)
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      local n = b.t == "OrderedList" and b.listAttributes.start or 1
      local plainitems = xe.list_items(b)
      for k, item in ipairs(b.content) do
        if last_only and k < #b.content then
          add(plainitems[k])
        else
          local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
          add(p(xe.runs(lab .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)), { style = "ListItem", keep = true }))
        end
        n = n + 1
      end
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(b.content) do
        add(p(xe.inl(x.content), { style = "BlockText", keep = true }))
      end
    else
      fail("cannot keep a " .. b.t .. " with a signature")
    end
  end

  local function stretch(a, z, opens, in_main)
    local i = a
    while i <= z do
      local b = blocks[i]
      local ph = placeholder(b)
      local first = (i == a) and opens
      if ph == "identity" then
        add(identity_rows(m))
      elseif ph == "signature" or ph == "signer" then
        signature(ph == "signature" and m.signature or m.signer, out)
      elseif ph ~= nil then
        fail("unknown placeholder {{" .. ph .. "}}")
      elseif b.t == "Header" and b.level == 1 and in_main then
        -- a certificate: the heading through its {{signer}} kept on one page
        local j = i + 1
        while j <= z and placeholder(blocks[j]) ~= "signer" and not (blocks[j].t == "Header" and blocks[j].level == 1) do
          j = j + 1
        end
        local id = heading(i, b, first)
        first_body_id = first_body_id or id
        search(i, in_main)
        if j <= z and placeholder(blocks[j]) == "signer" then
          -- the heading is already keepNext; every block to the signer kept with the next
          for k = i + 1, j - 1 do kept(blocks[k]); search(k, in_main) end
          signature(m.signer, out)
          i = j
        end
      elseif b.t == "Header" then
        local id = heading(i, b, first)
        if in_main then first_body_id = first_body_id or id end
        search(i, in_main)
      else
        if in_main and not first_body_id then
          first_body_id = "S:body"
          need(first_body_id, "B", texts[i].text:gsub("\1.*$", ""):sub(1, 40), "")
        end
        local nxt = blocks[i + 1]
        if nxt and placeholder(nxt) == "signature" then
          kept(b, true)
        elseif b.t == "Para" or b.t == "Plain" then
          body_para(b, false)
        elseif b.t == "BulletList" or b.t == "OrderedList" then
          for _, x in ipairs(xe.list_items(b)) do add(x) end
        elseif b.t == "Table" then
          add(table_rows(b))
        else
          add(b)
        end
        search(i, in_main)
      end
      i = i + 1
    end
  end

  -- front matter (lower roman from ii)
  local front_open = true
  local fa, fz = 1, ci - 1
  -- the front matter's first block after the cover opens a page
  if fz >= fa then
    -- a front matter that does not start with a heading: give its first block a page break of its own
    if blocks[fa].t ~= "Header" then add(p("", { brk = true, before = 0, after = 0, line = 20 })) ; front_open = false end
    stretch(fa, fz, front_open, false)
  end

  -- the contents (TRAP 38.1(b))
  local toc_at = #out + 1
  local toc_id = head_id(1, pandoc.Inlines({ pandoc.Str("Table"), pandoc.Space(), pandoc.Str("of"), pandoc.Space(),
    pandoc.Str("Contents") }))
  need(toc_id, "B", "Table of Contents", heads[1] and heads[1].id ~= toc_id and stringify(heads[1].il) or "Table of Contents")
  local toc_rows_at
  add(false) -- the contents title, filled in below
  toc_rows_at = #out + 1
  add(false) -- the contents rows, filled in below

  -- the index of authorities (TRAP 38.1(c))
  local toa_id
  local deferred = {}   -- the index rows, written once the body's citations are known
  if m.authorities then
    toa_id = head_id(1, pandoc.Inlines({ pandoc.Str("Index"), pandoc.Space(), pandoc.Str("of"), pandoc.Space(),
      pandoc.Str("Authorities") }))
    add(p(xe.runs("Index of Authorities"), { style = "TexHead1", brk = true, before = 0, after = H1_BELOW, line = SINGLE }))
    local gi = 0
    local k = 0
    for _, g in ipairs(list(m.authorities)) do
      gi = gi + 1
      local items = list(g.items)
      if gi == 1 then
        need(toa_id, "B", "Index of Authorities", plain(g.group) .. " " .. plain(items[1] and items[1].name))
      end
      add(p(xe.runs(pandoc.text.upper(plain(g.group)), { b = true }), { before = GROUP_ABOVE, after = TOC_ABOVE, keep = true }))
      for _, a in ipairs(items) do
        k = k + 1
        local au = auth[k]
        local slot = #out + 1
        add(false)
        deferred[#deferred + 1] = function()
        local name = minl(a.name)
        local body = (a.italic == false) and xe.inl(name) or xe.inl(name, { i = true })
        if a.cite then body = body .. xe.runs(", ") .. xe.inl(minl(a.cite)) end
        -- the pages: distinct, in order
        local ps, seen = {}, {}
        for _, id in ipairs(au.occ) do
          local l = label_of(id)
          if not seen[l] then seen[l] = true; ps[#ps + 1] = l end
        end
        table.sort(ps, function(x, y) return (tonumber(x) or 0) < (tonumber(y) or 0) end)
        local list_s = table.concat(ps, ", ")
        local pages = #ps == 0 and xe.runs("not cited", { b = true }) or xe.runs(list_s)
        -- the page column: TOA_COL, or the page list's own width when longer (typst measures it): Times New Roman
        -- digits are 0.5 em, the comma and the space 0.25 em (7 and 3.5 pt at 14 pt)
        local w = 0
        for ch in list_s:gmatch(".") do w = w + (ch:match("%d") and 140 or 70) end
        out[slot] = p(body .. xe.runs(xe.LEAD) .. pages, { before = TOC_ABOVE, lines = true, tabs = xe.leader_tab(TEXTW),
          left = HANG, hanging = HANG, right = math.max(TOA_COL, w) })
        end
      end
    end
  end
  -- the end of the lower-roman section
  add(xe.raw('<w:p><w:pPr>' .. SECT_LINE .. COVER_SECT .. '</w:pPr></w:p>'))

  -- the body (arabic from 1)
  stretch(ci + 1, #blocks, "section", true)

  for _, d in ipairs(deferred) do d() end

  -- the contents: a row per heading of levels 1 to 3
  out[toc_at] = p(xe.runs("Table of Contents"), { style = "TexHead1", brk = true, before = 0, after = H1_BELOW, line = SINGLE })
  local rows = {}
  for _, h in ipairs(heads) do
    if h.level <= 3 then
      local ind = (h.level - 1) * STEP
      rows[#rows + 1] = xe.para({ xe.style("TexSingle"), xe.LINES, xe.leader_tab(TEXTW),
        xe.spacing(h.level == 1 and TOC_ABOVE1 or TOC_ABOVE, 0, SINGLE), xe.ind(ind + HANG, HANG, nil, TOC_COL) },
        xe.inl(h.il) .. xe.runs(xe.LEAD .. label_of(h.id)))
    end
  end
  out[toc_rows_at] = xe.raw(table.concat(rows))

  -- the page numbering: lower roman from the cover, arabic from the body's first block
  needles[#needles + 1] = "#section\tS:cover\tlower-roman\t"
  if first_body_id then needles[#needles + 1] = "#section\t" .. first_body_id .. "\tdecimal\t" end
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdRomanFtr\t" .. FOOTER_P .. "\nrIdArabicFtr\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", BODY_SECT)

  -- the break rules on the inlines pandoc writes itself (the raw paragraphs have them from xe.inl)
  return pandoc.Pandoc(out, pandoc.Meta({})):walk({ Inlines = xe.inlines })
end
