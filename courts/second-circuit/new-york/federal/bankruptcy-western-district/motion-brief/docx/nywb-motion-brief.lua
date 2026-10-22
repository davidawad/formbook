-- W.D.N.Y. motion with memorandum of law, docx engine (docs/DOCX.md). The brief as Word paragraphs, so that it reads
-- and breaks as typst/nywb-motion-brief.typ does: the cover (court title, the caption with the party column ruled at
-- its right and foot, beside it the case number, chapter, adversary number and the title in bold; the counsel block),
-- the table of contents (generated from the headings, levels 1 to 3), the body (headings, paragraphs, block
-- quotations) and the signature block. Every case-specific word comes from the sample's frontmatter and body, never
-- from this file. Font and body styles are in docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES) in the LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle:
-- the contents' page of each heading (the heading and the words after it). Three sections: the cover (no number),
-- the contents (roman from i) and the body (arabic from 1; FORMBOOK_FINAL); their page number is this filter's
-- footer (FORMBOOK_FOOTERS). Word may paginate slightly differently from LibreOffice.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, heading-hang, quote-inset: 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_GUTTER = 360                   -- typst caption-gutter, 0.25 in
local CAP_PAD = 185                      -- typst caption-pad, 10 pt (200 twips), less the 0.75 pt rule Word sets inside it
local CAP_RIGHT_PAD = 144                -- typst caption-right-pad, 0.1 in
local TOC_STEP, TOC_COL = 576, 720       -- typst toc-step 0.4 in, toc-page-col 36 pt
local SIG = 4608                         -- typst sig-col, 3.2 in
local COVER_GAP = 276                    -- typst cover-gap
local COUNSEL_ABOVE = 552                -- typst counsel-above
local ROW_GAP = 120                      -- typst toc-row-gap 6 pt
local QUOTE_ABOVE, QUOTE_BELOW = 276, 138 -- typst quote-above, quote-below
local SIG_ABOVE, SIG_GAP = 552, 276      -- typst sig-above, sig-gap
local FOOTER = 720                       -- typst footer-distance 0.5 in
local FOOTER_SIZE = 20                   -- typst footer-size 10 pt (half points)
local NEEDLE_MAX = 60

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph: o = { style, before, after, line, left, right, first, hanging, tabs, jc, keep, lines }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Single lines, one per item; an empty item is a blank line (typst: slines).
local function lines(list, left, out)
  out = out or {}
  for _, l in ipairs(list) do out[#out + 1] = p(plain(l) == "" and "" or xe.inl(l), { left = left }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Sections, footer, needles and pages (tools/fb/src/docxpass.rs, docxpages.rs)
-- ---------------------------------------------------------------------------

-- The page number: 10 pt, centered in a single-pitch line (typst page-foot).
local NUM = '<w:rPr><w:sz w:val="' .. FOOTER_SIZE .. '"/><w:szCs w:val="' .. FOOTER_SIZE .. '"/></w:rPr>'
local FOOTER_P = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>'
  .. '<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r>' .. NUM .. '<w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r>' .. NUM .. '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>' .. NUM
  .. '<w:fldChar w:fldCharType="separate"/></w:r><w:r>' .. NUM .. '<w:t>1</w:t></w:r><w:r>' .. NUM
  .. '<w:fldChar w:fldCharType="end"/></w:r></w:p>'

-- A section's properties: its footer (fb render's rIdFtrNone, or rIdFtrNum below), the page numbers, letter paper
-- (LBR 9004-1) with one-inch margins.
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

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, counsel
-- ---------------------------------------------------------------------------

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function caption(m)
  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then
      left[#left + 1] = ""
      left[#left + 1] = "v."
      left[#left + 1] = ""
    end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = n end
    left[#left + 1] = party.designation
  end
  local right = { "Case No. " .. plain(m.case_number) }
  if m.chapter ~= nil then right[#right + 1] = plain(m.chapter) end
  local adv = plain(m.adv_number)
  if adv ~= "" then
    right[#right + 1] = ""
    right[#right + 1] = "Adv. Proc. No. " .. adv
  end
  right[#right + 1] = ""
  local rps = lines(right, CAP_RIGHT_PAD)
  rps[#rps + 1] = p(xe.inl(m.brief_title, { b = true }), { left = CAP_RIGHT_PAD })
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, RULES .. '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', lines(left, 0)) ..
    cell(CAP_GUTTER, "", { p("") }) ..
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, "", rps) .. '</w:tr></w:tbl>'
end

local function cover(m, out)
  for _, t in ipairs(items(m.court_name)) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(t)), { b = true }), { jc = "center" })
  end
  out[#out + 1] = p("", { line = COVER_GAP })
  out[#out + 1] = caption(m)
  local counsel = items(m.counsel)
  for i, c in ipairs(counsel) do
    out[#out + 1] = p(xe.inl(c), { left = CAP_LEFT + CAP_GUTTER, before = i == 1 and COUNSEL_ABOVE or 0 })
  end
end

-- ---------------------------------------------------------------------------
-- Table of contents: one row per heading (levels 1 to 3), a dot leader to the page column (typst listing-row)
-- ---------------------------------------------------------------------------

local function contents(entries, out)
  out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", keep = true })
  for i, e in ipairs(entries) do
    local ind = (e.level - 1) * TOC_STEP
    out[#out + 1] = p(xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")), { lines = true,
      tabs = xe.leader_tab(TEXTW), before = i == 1 and COVER_GAP or ROW_GAP, left = ind, right = TOC_COL })
  end
end

-- ---------------------------------------------------------------------------
-- Body and signature
-- ---------------------------------------------------------------------------

-- Headings on the body pitch with no space of their own, kept with the text: level 1 centered bold capitals;
-- level 2 bold, level 3 bold italic, at the margin with the lines after the first hanging half an inch.
local function heading(b)
  local content = b.content
  local lvl = math.min(b.level, 3)
  local o = { style = "Heading" .. lvl, keep = true, line = BODY }
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    o.jc = "center"
  else
    o.left, o.hanging = INDENT, INDENT
  end
  return p(xe.inl(content, { b = true, i = lvl == 3 }), o)
end

local function signature(m, out)
  local sig = m.signature
  local firm = items(sig.firm)
  local ls = {}
  for _, f in ipairs(firm) do ls[#ls + 1] = { xe.inl(f), 0 } end
  ls[#ls + 1] = { xe.runs("By: /s/ " .. plain(sig.signer)), #firm > 0 and SIG_GAP or 0 }
  for _, l in ipairs(items(sig.lines)) do ls[#ls + 1] = { xe.inl(l), 0 } end
  for i, l in ipairs(ls) do
    local keep = i < #ls
    if i == 1 then
      out[#out + 1] = p(xe.runs("Dated: " .. plain(m.date) .. "\t") .. l[1],
        { before = SIG_ABOVE, left = SIG, hanging = SIG, tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. SIG .. '"/></w:tabs>', keep = keep })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = keep })
    end
  end
end

local function blocks(list, out)
  for k, b in ipairs(list) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for i, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(q.content), { before = i == 1 and QUOTE_ABOVE or SINGLE, after = QUOTE_BELOW,
          left = INDENT, right = INDENT })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = k == #list })
    else
      error("nywb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 544"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  load_pages()
  local m = doc.meta
  local body = doc.blocks

  -- the needles, in document order: the contents (roman from i), the body's first words (arabic from 1; the first
  -- heading's own needle when the body opens with one: a second needle for the same words would be searched after
  -- the first and land on a later mention), and each heading with the words after it
  need("S:toc", "TABLE OF CONTENTS")
  local body_id = "H:1"
  if body[1].t ~= "Header" then
    body_id = "S:body"
    need(body_id, stringify(body[1]):sub(1, 60))
  end
  local entries, h_n = {}, 0
  for i, b in ipairs(body) do
    if b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = body[i + 1] and stringify(body[i + 1]):sub(1, 40) or ""
      need(id, stringify(b.content), nxt)
      if b.level <= 3 then entries[#entries + 1] = { id = id, level = b.level, title = b.content } end
    end
  end
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdFtrNum\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrNum", "decimal", 1))

  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  m, body = doc.meta, doc.blocks
  for _, e in ipairs(entries) do e.title = pandoc.Inlines(e.title):walk({ Str = breaks }) end

  local out = {}
  cover(m, out)
  out[#out + 1] = section_end("rIdFtrNone")
  contents(entries, out)
  out[#out + 1] = section_end("rIdFtrNum", "lowerRoman", 1)
  blocks(body, out)
  signature(m, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
