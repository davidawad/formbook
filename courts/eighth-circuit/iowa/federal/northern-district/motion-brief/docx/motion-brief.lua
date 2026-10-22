-- Memorandum in support of a motion for the U.S. District Court for the Northern District of Iowa (iand), docx
-- engine: what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/iand-motion-brief.typ does (README "Engines"): the court title and caption (LR 10(d); a table with a column
-- of ")" marks), the table of contents (LR 10(b)), the headings, the numbered paragraphs ("<!--NUMBERED-->", LR
-- 10(b)), lists, block quotations, single-spaced lines ("<!--SINGLE-->", a service list) and the signature block
-- ("<!--SIGNATURE-->"). Everything printed comes from the sample's frontmatter and body: no case text lives here.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle.
-- One section, numbered in arabic from the first page (FORMBOOK_FINAL, rIdFtrPage). Word may paginate slightly
-- differently.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE, HALF = 480, 276, 240 -- typst pitch, pitch-single, half
local INDENT = 720                       -- typst para-indent and quote-indent, 0.5 in
local LIST_IND, LIST_LABEL = 720, 576    -- typst list-indent 0.5 in, list-label 0.4 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_MARKS = 4464, 432    -- typst caption-left 3.1 in, caption-marks 0.3 in
local RIGHT_INSET = 216                  -- typst right-inset 0.15 in
local SIG_LEFT = 4320                    -- typst sig-left 3.0 in
local PNUM, TOC_STEP, TOC_GAP = 720, 360, 120 -- typst toc-page-col 36 pt, toc-step 18 pt, toc-gap 6 pt
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, tab, tabs, jc, keep, lines, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
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

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Court title and caption (LR 10(d))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local titles = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF IOWA" }
  if meta.division then titles[#titles + 1] = pandoc.text.upper(plain(meta.division)) end
  local out = {}
  for i, l in ipairs(titles) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #titles and BODY or 0 })
  end
  -- the parties on the left, a ")" per party line in the middle; the case number, judges and title on the right,
  -- each on the single-spaced grid of the party lines
  local left, marks = {}, {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  for i = 1, #left do marks[i] = p(xe.runs(")")) end
  local label = meta.case_label and plain(meta.case_label) or "No."
  local right = { p(xe.runs(label .. " ") .. xe.inl(meta.case_number)) }
  if meta.judge then right[#right + 1] = p(xe.runs("Judge: ") .. xe.inl(meta.judge), { before = SINGLE }) end
  if meta.magistrate_judge then
    right[#right + 1] = p(xe.runs("Magistrate Judge: ") .. xe.inl(meta.magistrate_judge), { before = SINGLE })
  end
  right[#right + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = 2 * SINGLE })
  out[#out + 1] = tbl({ CAP_LEFT, CAP_MARKS, TEXTW - CAP_LEFT - CAP_MARKS }, { { body = left }, { body = marks },
    { pr = '<w:tcMar><w:left w:w="' .. RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>', body = right } })
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch: level 1 centered bold capitals; level 2 bold, flush left; level 3 italic, flush left;
-- kept with the text.
local function heading(el, before, brk)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local props = { xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP }
  if brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(before, 0, BODY)
  props[#props + 1] = xe.ind(0, nil, 0)
  props[#props + 1] = xe.jc(el.level == 1 and "center" or "left")
  return xe.para(props, xe.inl(content, el.level <= 2 and { b = true } or { i = true }))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- Smart punctuation as the typst template's markdown reader (cmarker, pulldown-cmark) sets it, not as pandoc's smart
-- reader does (it pairs a stray quote with a later one across the paragraph): in each paragraph, single and double
-- quotes pair separately, a quote that can close (right-flanking) closing the nearest open one of its kind, one that
-- can only open (left-flanking) opening; an unpaired single quote is an apostrophe, an unpaired double quote an
-- opening one. "---", "--" and "..." are an em dash, an en dash and an ellipsis.
local UPUNCT = { ["—"] = true, ["–"] = true, ["“"] = true, ["”"] = true, ["‘"] = true, ["’"] = true, ["…"] = true,
  ["§"] = true, ["¶"] = true }
local function is_space(c) return c == nil or c:match("^%s$") ~= nil end
local function is_punct(c) return c ~= nil and (c:match("^%p$") ~= nil or UPUNCT[c] == true) end
local function smart_list(inlines)
  -- the paragraph as a stream of characters, each Str's characters with their element
  local chars, strs = {}, {}
  local function collect(list)
    for _, x in ipairs(list) do
      if x.t == "Str" then
        local cs = {}
        for _, c in utf8.codes(x.text) do
          chars[#chars + 1] = { c = utf8.char(c) }
          cs[#cs + 1] = chars[#chars]
        end
        strs[#strs + 1] = cs
      elseif x.t == "Space" or x.t == "SoftBreak" or x.t == "LineBreak" then
        chars[#chars + 1] = { c = " " }
      elseif x.content and x.t ~= "Note" then
        collect(x.content)
      end
    end
  end
  collect(inlines)
  local stacks = { ['"'] = {}, ["'"] = {} }
  for k, ch in ipairs(chars) do
    local c = ch.c
    if c == '"' or c == "'" then
      local prev, nxt = chars[k - 1] and chars[k - 1].c, chars[k + 1] and chars[k + 1].c
      local left = not is_space(nxt) and (not is_punct(nxt) or is_space(prev) or is_punct(prev))
      local right = not is_space(prev) and (not is_punct(prev) or is_space(nxt) or is_punct(nxt))
      -- a single quote inside a word (letters on both sides) is an apostrophe: it neither opens nor closes; nor
      -- does one after a closing bracket open
      if c == "'" then
        if left and right and not is_punct(nxt) then left, right = false, false end
        if prev == ")" or prev == "]" then left = false end
      end
      local st = stacks[c]
      if right and #st > 0 then
        local o = table.remove(st)
        o.c = c == '"' and "\u{201C}" or "\u{2018}"
        ch.c = c == '"' and "\u{201D}" or "\u{2019}"
      elseif left and not (c == "'" and right) then
        st[#st + 1] = ch
      end
    end
  end
  for _, st in pairs(stacks) do for _, o in ipairs(st) do o.c = o.c == '"' and "\u{201C}" or "\u{2019}" end end
  for _, ch in ipairs(chars) do
    if ch.c == '"' then ch.c = "\u{201C}" elseif ch.c == "'" then ch.c = "\u{2019}" end
  end
  local n = 0
  local function rewrite(list)
    for _, x in ipairs(list) do
      if x.t == "Str" then
        n = n + 1
        local t = {}
        for _, ch in ipairs(strs[n]) do t[#t + 1] = ch.c end
        x.text = (table.concat(t):gsub("%-%-%-", "\u{2014}"):gsub("%-%-", "\u{2013}"):gsub("%.%.%.", "\u{2026}"))
      elseif x.content and x.t ~= "Note" then
        rewrite(x.content)
      end
    end
  end
  rewrite(inlines)
  return inlines
end
local function smart_block(b)
  b.content = smart_list(b.content)
  return b
end
local function smart_meta(v)
  local t = pandoc.utils.type(v)
  if t == "Inlines" then return smart_list(v) end
  if t == "List" or t == "table" or t == "Meta" then
    for k, x in pairs(v) do v[k] = smart_meta(x) end
  end
  return v
end

-- The lines of a paragraph, split at its source line breaks.
local function lines_of(inlines)
  local out, cur = {}, pandoc.Inlines({})
  for _, x in ipairs(inlines) do
    if x.t == "SoftBreak" or x.t == "LineBreak" then
      out[#out + 1] = cur
      cur = pandoc.Inlines({})
    else
      cur:insert(x)
    end
  end
  out[#out + 1] = cur
  return out
end

-- The body as items: a marker ("<!--NUMBERED-->", "<!--SINGLE-->") applies to the paragraph after it.
local function items_of(blocks)
  local items, mark = {}, nil
  for _, b in ipairs(blocks) do
    if b.t == "RawBlock" and b.format == "html" then
      local m = b.text:match("^<!%-%-(%u+)%-%->$")
      if m == "SIGNATURE" then items[#items + 1] = { kind = "signature" } else mark = m end
    else
      local kind = b.t == "Header" and "heading" or b.t
      if (b.t == "Para" or b.t == "Plain") then
        kind = mark == "NUMBERED" and "numbered" or mark == "SINGLE" and "single" or "para"
      end
      items[#items + 1] = { kind = kind, b = b }
      mark = nil
    end
  end
  return items
end

local function signature(meta, before)
  local ps = {}
  if meta.date then ps[#ps + 1] = { xe.runs("Dated: ") .. xe.inl(meta.date), { after = BODY } } end
  local sig = meta.signature
  for _, l in ipairs(sig.party or {}) do ps[#ps + 1] = { xe.inl(l), { left = SIG_LEFT } } end
  for i, l in ipairs(sig.firm) do
    ps[#ps + 1] = { xe.inl(l), { left = SIG_LEFT, before = (i == 1 and sig.party) and HALF or 0 } }
  end
  ps[#ps + 1] = { xe.runs("/s/ ") .. xe.inl(sig.signer), { left = SIG_LEFT, before = HALF } }
  for _, l in ipairs(sig.lines or {}) do ps[#ps + 1] = { xe.inl(l), { left = SIG_LEFT } } end
  local out = {}
  for i, x in ipairs(ps) do
    local o = x[2]
    if i == 1 then o.before = math.max(o.before or 0, before) end
    o.keep = i < #ps
    out[#out + 1] = p(x[1], o)
  end
  return out
end

function Pandoc(doc)
  load_pages()
  doc.meta = smart_meta(doc.meta)
  doc = doc:walk({ Para = smart_block, Plain = smart_block, Header = smart_block }):walk({ Str = breaks })
  local meta = doc.meta
  local items = items_of(doc.blocks)

  -- the needles: the court title (where the arabic numbering starts), then each heading with the words after it
  need("S:0", "IN THE UNITED STATES DISTRICT COURT FOR THE NORTHERN DISTRICT OF IOWA")
  local entries, h_n = {}, 0
  for i, it in ipairs(items) do
    if it.kind == "heading" then
      h_n = h_n + 1
      it.id = "H:" .. h_n
      local nxt = items[i + 1] and items[i + 1].b and stringify(items[i + 1].b):sub(1, 40) or ""
      need(it.id, stringify(it.b.content), nxt)
      if it.b.level <= 2 then entries[#entries + 1] = { id = it.id, level = it.b.level, title = it.b.content } end
    end
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:0\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = cover(meta)
  -- the space a block asks for below it, taken by the next paragraph as space before it (Word has no space after a
  -- table; between two paragraphs the larger applies, as in typst)
  local gap = BODY
  local brk = false
  local function take(before)
    local g = math.max(gap, before or 0)
    gap = 0
    return g
  end
  if meta.toc == true then
    out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", before = take() })
    gap = BODY
    for _, e in ipairs(entries) do
      local left = (e.level - 1) * TOC_STEP
      out[#out + 1] = p(xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
        { lines = true, tabs = xe.leader_tab(TEXTW), before = take(TOC_GAP), left = left, right = PNUM })
    end
    -- the body starts a new page (typst pagebreak); a page drops the space above its first line
    brk, gap = true, 0
  end

  local n = 0
  for _, it in ipairs(items) do
    local b = it.b
    local first = brk
    brk = false
    if it.kind == "heading" then
      out[#out + 1] = heading(b, take(), first)
    elseif it.kind == "signature" then
      for _, x in ipairs(signature(meta, take(BODY))) do out[#out + 1] = x end
      gap = BODY
    elseif it.kind == "single" then
      local ls = lines_of(b.content)
      for j, l in ipairs(ls) do out[#out + 1] = p(xe.inl(l), { before = j == 1 and take() or 0, brk = first and j == 1 }) end
      gap = HALF
    elseif it.kind == "numbered" or it.kind == "para" then
      local label = ""
      if it.kind == "numbered" then
        n = n + 1
        label = n .. ".\t"
      end
      out[#out + 1] = p(xe.runs(label) .. xe.inl(b.content), { line = BODY, first = INDENT, before = take(),
        tab = it.kind == "numbered" and 2 * INDENT or nil, brk = first })
    elseif it.kind == "BlockQuote" then
      out[#out + 1] = p(xe.inl(pandoc.utils.blocks_to_inlines(b.content)),
        { left = INDENT, right = INDENT, before = take(), brk = first })
      gap = HALF
    elseif it.kind == "OrderedList" or it.kind == "BulletList" then
      local num = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and (num .. ".") or "\u{2022}"
        out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { line = BODY, left = LIST_IND + LIST_LABEL, hanging = LIST_LABEL, before = take(j == 1 and HALF or 0),
            brk = first and j == 1 })
        num = num + 1
      end
      gap = HALF
    else
      error("motion-brief.lua: unsupported block " .. it.kind)
    end
  end

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
