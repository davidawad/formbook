-- nynd memorandum of law (N.D.N.Y.), docx engine (docs/DOCX.md): the same markdown contract as
-- typst/nynd-motion-brief.typ, and every block written as it sets it: the cover (the court's name, the caption between
-- two rules, L.R. 10.1(c)(1); the title of the paper; the filing firm, L.R. 10.1(c)(2)), the table of contents (L.R.
-- 7.1(b)(1)), the headings, the body paragraphs (pandoc's, style Body Text, so their footnotes are pandoc's), the
-- bulleted items and the signature block. Content-agnostic: every case-specific word comes from the sample's
-- frontmatter and body. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.
--
-- Sections and page numbers (were docx/render.sh's two passes and its awk page map): the cover is a section without a
-- page number (fb render's rIdFtrNone), the contents a section numbered in lower roman from i, the memorandum a
-- section numbered from 1 ($FORMBOOK_FINAL), both with fb render's page-number footer (rIdFtrPage). The contents'
-- page numbers: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- ($FORMBOOK_NEEDLES: the contents' title, each heading with the words after it, in document order) in the
-- LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER, CAP_PAD = 5184, 432, 144   -- typst caption-left, caption-gutter, caption-case-pad
local CAP_RULE_PAD = 185                               -- typst caption-pad (10 pt) less the 0.75 pt rule LibreOffice
                                                       -- sets inside the cell
local BETWEEN, DESIGNATION = 720, 2880                 -- typst between-indent, designation-indent
local TITLE_ABOVE, FIRM_ABOVE = 2880, 2400             -- typst cover-title-above (144 pt), cover-firm-above (120 pt)
local FIRM_LEFT = 4680                                 -- typst firm-indent, 3.25 in
local TOC_INDENT, PNUM = 720, 720                      -- typst toc-indent, page-col
local SIG_W, SIG_GUTTER = 4680, 288                    -- typst signature-w, signature-gutter
local BY_TAB = 407 + 3744                              -- "By: " (20.34 pt) and typst by-line (2.6 in)
local QUOTE, QUOTE_SPACE = 1440, 240                   -- typst quote-indent, quote-space
local RULE = 'w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt
local NEEDLE_MAX = 60

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, tabs, jc, keep, lines, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.tabs then props[#props + 1] = o.tabs end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table without cell margins that is never split: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells)
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
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- Capitals of a metadata value or inlines, as typst's upper().
local function upper(x)
  if type(x) == "string" then return pandoc.text.upper(x) end
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
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

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function needle(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = norm(text):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = table.concat({ id, "B", long, short }, "\t")
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, _, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
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

-- Sections: letter page, 1-inch margins (L.R. 10.1(a)(2)), the page number 0.5 in above the bottom edge.
local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="720" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- ---------------------------------------------------------------------------
-- Cover (L.R. 10.1(c))
-- ---------------------------------------------------------------------------

local function firm_lines(sig, role, o)
  local out = {}
  local function line(xml) out[#out + 1] = p(xml, { left = o.left, keep = true, before = #out == 0 and o.above or 0 }) end
  line(xe.inl(upper(sig.firm), { b = true }))
  for _, s in ipairs(list(sig.signers)) do
    line(xe.inl(s.name))
    line(xe.inl(s.bar_roll))
    line(xe.inl(s.email))
  end
  for _, a in ipairs(list(sig.address)) do line(xe.inl(a)) end
  line(xe.inl(sig.phone))
  line(xe.inl(role, { i = true }))
  out[#out] = out[#out]:gsub("<w:keepNext/>", "", 1)
  return table.concat(out)
end

local function cover(m)
  if not m.judges or stringify(m.judges) == "" then
    error("nynd-motion-brief: L.R. 10.1(c)(1) requires the assigned judge's initials in the caption (frontmatter: judges)", 0)
  end
  for _, s in ipairs(list(m.signature.signers)) do
    if not s.bar_roll or stringify(s.bar_roll) == "" then
      error("nynd-motion-brief: L.R. 10.1(c)(2) requires the bar roll number of each signing attorney", 0)
    end
  end
  local out = { p(xe.runs("UNITED STATES DISTRICT COURT")), p(xe.runs("NORTHERN DISTRICT OF NEW YORK"), { after = BODY }) }
  local left = {}
  for k, party in ipairs(list(m.caption.parties)) do
    if k > 1 then left[#left + 1] = p(xe.inl(m.caption.between), { before = SINGLE, left = BETWEEN }) end
    for i, n in ipairs(list(party.names)) do
      left[#left + 1] = p(xe.inl(n), { before = (k > 1 and i == 1) and SINGLE or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIGNATION })
  end
  local rules = '<w:tcBorders><w:top w:val="single" ' .. RULE .. '/><w:bottom w:val="single" ' .. RULE ..
    '/></w:tcBorders><w:tcMar><w:top w:w="' .. CAP_RULE_PAD .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_RULE_PAD ..
    '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = rules, body = left },
    { body = { p("") } },
    { body = { p(xe.runs("Case No. ") .. xe.inl(m.case_number) .. xe.runs(" (") .. xe.inl(m.judges) .. xe.runs(")"),
      { left = CAP_PAD }) } },
  })
  out[#out + 1] = p(xe.inl(upper(m.brief_title), { b = true }), { before = TITLE_ABOVE, jc = "center" })
  out[#out + 1] = firm_lines(m.signature, m.counsel_role, { left = FIRM_LEFT, above = FIRM_ABOVE })
  out[#out + 1] = section("rIdFtrNone", nil)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Table of contents (L.R. 7.1(b)(1)): a row per heading, (level - 1) half inches in, the title wrapping before the
-- page column, a dot leader to the page (typst listing-row).
-- ---------------------------------------------------------------------------

local function toc(entries)
  local out = { p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", keep = true }) }
  for i, e in ipairs(entries) do
    out[#out + 1] = p(xe.inl(e.title) .. xe.runs(xe.LEAD) .. xe.runs(labels[e.id] or "0"), { lines = true,
      tabs = xe.leader_tab(TEXTW), before = i == 1 and BODY or 0, left = (e.level - 1) * TOC_INDENT, right = PNUM })
  end
  out[#out + 1] = section("rIdFtrPage", "lowerRoman")
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (L.R. 10.1(c)(2)): a double line below the conclusion (the space above the first lines of its
-- cells); the date at the left, the firm, "By:" and the signature line, the signers, the address, telephone and role
-- at the right.
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local r = { p(xe.inl(upper(sig.firm), { b = true }), { before = BODY }) }
  r[#r + 1] = p(xe.runs("By: ") .. '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>',
    { before = BODY, tab = BY_TAB })
  for _, s in ipairs(list(sig.signers)) do
    r[#r + 1] = p(xe.inl(s.name))
    r[#r + 1] = p(xe.inl(s.bar_roll))
    r[#r + 1] = p(xe.inl(s.email))
  end
  for i, a in ipairs(list(sig.address)) do r[#r + 1] = p(xe.inl(a), { before = i == 1 and SINGLE or 0 }) end
  r[#r + 1] = p(xe.inl(sig.phone))
  r[#r + 1] = p(xe.inl(m.counsel_role, { i = true }))
  local left = { p(xe.runs("Dated: ") .. xe.inl(sig.dated), { before = BODY }) }
  return tbl({ TEXTW - SIG_W - SIG_GUTTER, SIG_GUTTER, SIG_W }, { { body = left }, { body = { p("") } }, { body = r } })
end

-- ---------------------------------------------------------------------------
-- The memorandum
-- ---------------------------------------------------------------------------

-- A heading on the body pitch, bold, kept with the next block (typst sticky): level 1 centered capitals, level 2
-- centered, level 3 at the margin.
local function heading(el)
  local content = el.content
  if el.level == 1 then content = upper(content) end
  local lvl = math.min(el.level, 3)
  return p(xe.inl(content, { b = true }), { style = "Heading" .. lvl, keep = true, line = BODY,
    jc = lvl < 3 and "center" or "left" })
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  if not m.motion_basis or stringify(m.motion_basis) == "" then
    error("nynd-motion-brief: L.R. 7.1(b)(1) requires the moving party to specify the rule or statute the motion is based on (frontmatter: motion_basis)", 0)
  end
  -- the conclusion: the blocks from the last level-1 heading on, kept with the signature block (typst: one
  -- unbreakable block)
  local last1 = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then last1 = i end
  end

  local entries, body = {}, {}
  needle("S:toc", "TABLE OF CONTENTS", stringify(doc.blocks[1] or ""):sub(1, 40))
  for i, b in ipairs(doc.blocks) do
    local keep = last1 ~= nil and i >= last1
    if b.t == "Header" then
      local id = "H:" .. (#entries + 1)
      local nxt = doc.blocks[i + 1] and stringify(doc.blocks[i + 1]):sub(1, 40) or ""
      needle(id, stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = b.level, title = b.content }
      body[#body + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      body[#body + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = keep and "Body Text Keep" or "Body Text" })
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do body[#body + 1] = x end
    elseif b.t == "BlockQuote" then
      for k, q in ipairs(b.content) do
        body[#body + 1] = xe.raw(p(xe.inl(q.content), { left = QUOTE, right = QUOTE,
          before = k == 1 and QUOTE_SPACE or 0, after = k == #b.content and QUOTE_SPACE or 0 }))
      end
    else
      error("nynd-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  needles[#needles + 1] = "#section\tS:toc\tlower-roman\t"
  needles[#needles + 1] = "#section\t" .. (entries[1] and entries[1].id or "S:toc") .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrPage", "decimal"))

  local out = { xe.raw(cover(m) .. toc(entries)) }
  for _, x in ipairs(pandoc.Blocks(body):walk({ Inlines = xe.inlines })) do out[#out + 1] = x end
  out[#out + 1] = xe.raw(signature(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = breaks, Inlines = bind_double_signs }, { Pandoc = finish } }
