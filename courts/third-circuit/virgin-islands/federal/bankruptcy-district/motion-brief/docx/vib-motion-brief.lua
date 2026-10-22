-- Motion with memorandum of law, United States Bankruptcy Court, District of the Virgin Islands (vib), docx engine
-- (docs/DOCX.md). Mirrors typst/vib-motion-brief.typ:
--   * the cover: the court header (two centred bold single lines), the caption (a table of two rows: the parties at
--     the left in a column ruled on the right and below each row, Form 416; the chapter and case number, then the
--     adversary number at the right; VIB-MB-CAPTION), the title, and the counsel blocks lower right;
--   * the table of contents on a page of its own: every heading of levels 1 to 4, the label in a half-inch box, the
--     title hanging, a dot leader to the page number in the page column;
--   * the body: headings single-spaced (level 1 centred bold capitals; below it numbered I. / A. / 1. / a. by level,
--     VIB-MB-HEADINGS), 12 pt above and below, kept with the next block; paragraphs and footnotes as pandoc writes
--     them; the last paragraph kept on one page with the signature block (VIB-MB-SIGNATURE).
-- The footer (the short title at the left, "Page n of N" at the right; VIB-MB-PAGE) and the last section (letter,
-- 1 in margins) are written for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the body styles are in
-- docx/reference.xml. Nothing case-specific is written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
--
-- Pages: fb render (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes
-- (FORMBOOK_NEEDLES: the cover's first line, the contents' title, each heading with the words after it) in the
-- LibreOffice PDF, and renders again with their pages (FORMBOOK_PAGES) until they settle. One section, pages
-- numbered from the cover. Word may paginate slightly differently from LibreOffice.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body 24 pt, pitch-single 13.8 pt
local TW = 9360                               -- typst text-width: 6.5 in
local STEP = 720                              -- typst level-step 0.5 in
local CAP_LEFT = 5616                         -- typst cap-left 3.9 in
local CAP_PAD = 288                           -- typst cap-pad 0.2 in
local CAP_TOP, CAP_BOTTOM = 120, 200          -- typst cap-top 6 pt, cap-bottom 10 pt
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local CAP_RULE_TW = 15                        -- the same rule in twips: LibreOffice sets a cell's bottom rule below
                                              -- the row (typst strokes take no room), so the bottom margin is less
local DESIGNATION = 720                       -- typst designation-indent 0.5 in
local COUNSEL_COL = 3312                      -- typst counsel-col 2.3 in
local SIG_COL = 4320                          -- typst sig-col 3.0 in
local TOC_COL = 720                           -- typst toc-page-col 36 pt
local FOOTER_PAGE = 1872                      -- typst footer-page 1.3 in
local CAPTION_ABOVE, TITLE_ABOVE = 480, 480   -- typst caption-above, title-above 24 pt
local COUNSEL_ABOVE, COUNSEL_GAP = 480, 276   -- typst counsel-above 24 pt, counsel-gap 13.8 pt
local TOC_ABOVE, ROW_GAP = 480, 240           -- typst toc-above 24 pt, row-gap 12 pt
local HEADING_GAP = 240                       -- typst heading-gap 12 pt
local SIG_ABOVE, SIG_GAP = 480, 276           -- typst sig-above 24 pt, sig-gap 13.8 pt
local FOOTER = 432                            -- the footer's last line box ends 0.3 in above the page edge
local NEEDLE_MAX = 60

local function check(cond, msg)
  if not cond then error("vib-motion-brief docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
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

local function read_file(path)
  if not path or path == "" then return nil end
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- A paragraph: o = { before, after, pitch, left, right, hanging, jc, keep, lines, brk, tabs }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and 0 or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Single-pitch lines (typst lines): an item is a metadata value, a string of runs (`raw`), or "" (a blank single
-- line, added to the space above the next); o = { above, left, jc, keep (every line kept with the next) }.
local function lines(list, o)
  o = o or {}
  local out, gap = {}, o.above or 0
  for _, l in ipairs(list) do
    if type(l) == "string" and l == "" then gap = gap + SINGLE else
      local body = type(l) == "table" and l.raw or xe.inl(l)
      out[#out + 1] = p(body, { before = gap, left = o.left, jc = o.jc, keep = o.keep })
      gap = 0
    end
  end
  return table.concat(out)
end

local function raw(s) return { raw = s } end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" '
  .. 'w:noHBand="0" w:noVBand="0"/>'

local function tc(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>"
    .. paras .. "</w:tc>"
end

local function tbl(widths, rows)
  local cols = {}
  for _, w in ipairs(widths) do cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
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
  needles[#needles + 1] = table.concat({ id, "B", long, short:sub(1, NEEDLE_MAX) }, "\t")
end

local labels = {}
local function load_pages()
  local s = read_file(os.getenv("FORMBOOK_PAGES"))
  if not s then return end
  for l in s:gmatch("[^\n]+") do
    local id, _, label = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
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

-- ---------------------------------------------------------------------------
-- Footer (VIB-MB-PAGE) and section
-- ---------------------------------------------------------------------------

local function field(name)
  return '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> ' .. name
    .. ' </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
end

-- The short title at the left (it wraps before the page column), "Page n of N" at the right on its last line.
local function footer(m)
  local title = pandoc.text.upper(txt(m.footer or m.title))
  local cell = '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/></w:tcMar>'
  return tbl({ TW - FOOTER_PAGE, FOOTER_PAGE }, { "<w:tr>"
    .. tc(TW - FOOTER_PAGE, p(xe.runs(title)), cell)
    .. tc(FOOTER_PAGE, p(xe.runs("Page ") .. field("PAGE") .. xe.runs(" of ") .. field("NUMPAGES"), { jc = "right" }),
      cell .. '<w:vAlign w:val="bottom"/>')
    .. "</w:tr>" }) .. p("", { pitch = 20 })
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdVibFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court header, caption, title, counsel (VIB-MB-CAPTION)
-- ---------------------------------------------------------------------------

local COURT = "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS"

local function party(pt)
  return lines(items(pt.names)) .. lines({ pt.designation }, { left = DESIGNATION })
end

local function cover(m)
  local out = {}
  out[#out + 1] = lines({ raw(xe.runs(COURT, { b = true })),
    raw(xe.runs("DIVISION OF " .. pandoc.text.upper(txt(m.division)) .. ", BANKRUPTCY DIVISION", { b = true })) },
    { jc = "center" })
  local sides, adv = items(m.caption), m.adversary
  local rule = 'w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local bottom = CAP_BOTTOM - CAP_RULE_TW
  local lmar = '<w:tcBorders><w:bottom ' .. rule .. '<w:right ' .. rule .. '</w:tcBorders><w:tcMar><w:top w:w="'
    .. CAP_TOP .. '" w:type="dxa"/><w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD
    .. '" w:type="dxa"/></w:tcMar>'
  local rmar = '<w:tcMar><w:top w:w="' .. CAP_TOP .. '" w:type="dxa"/><w:left w:w="' .. CAP_PAD
    .. '" w:type="dxa"/><w:bottom w:w="' .. bottom .. '" w:type="dxa"/></w:tcMar>'
  local right_w = TW - CAP_LEFT
  local adv_lines = { raw(xe.runs("Adv. Proc. No. " .. txt(adv.number))) }
  if adv.note then adv_lines[#adv_lines + 1] = ""; adv_lines[#adv_lines + 1] = adv.note end
  local row = function(l, r)
    return "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. tc(CAP_LEFT, l, lmar) .. tc(right_w, r, rmar) .. "</w:tr>"
  end
  out[#out + 1] = p("", { pitch = CAPTION_ABOVE })
  out[#out + 1] = tbl({ CAP_LEFT, right_w }, {
    row(lines({ raw(xe.runs("In re:")), "" }) .. party(m.debtor),
      lines({ m.chapter, "", raw(xe.runs("Case No. " .. txt(m.case_number))) })),
    row(party(sides[1]) .. lines({ "", raw(xe.runs("v.")), "" }) .. party(sides[2]), lines(adv_lines)),
  })
  out[#out + 1] = lines({ raw(xe.runs(pandoc.text.upper(txt(m.title)), { b = true })) },
    { above = TITLE_ABOVE, jc = "center" })
  for i, g in ipairs(items(m.counsel)) do
    local ls = { raw(xe.runs(pandoc.text.upper(txt(g.firm)), { b = true })) }
    for _, l in ipairs(items(g.lines)) do ls[#ls + 1] = l end
    out[#out + 1] = lines(ls, { above = i == 1 and COUNSEL_ABOVE or COUNSEL_GAP, left = COUNSEL_COL })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Table of contents (typst toc-entry): on a page of its own
-- ---------------------------------------------------------------------------

local function contents(entries)
  local out = { p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", keep = true, brk = true }) }
  for i, e in ipairs(entries) do
    local ind = math.max(e.level - 2, 0) * STEP
    out[#out + 1] = p(xe.runs((e.label or "") .. "\t") .. xe.inl(e.title) .. xe.runs(xe.LEAD .. (labels[e.id] or "0")),
      { lines = true, before = i == 1 and TOC_ABOVE or ROW_GAP, left = ind + STEP, hanging = STEP, right = TOC_COL,
        tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + STEP) .. '"/><w:tab w:val="right" w:leader="dot" w:pos="'
          .. TW .. '"/></w:tabs>' })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Headings and signature
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A heading (typst show heading): single-spaced, 12 pt above and below, kept with the next block; level 1 centred
-- bold capitals; below it the label in a half-inch box (a tab) after the level's step, the title hanging, levels 2
-- and 3 bold. The first opens the body's page (no space above: typst drops it at the top of a page, Word keeps it
-- after a page break).
local function heading(b, label, first)
  local o = { keep = true, brk = first, before = first and 0 or HEADING_GAP, after = HEADING_GAP }
  if b.level == 1 then
    o.jc = "center"
    return p(xe.inl(upper(b.content), { b = true }), o)
  end
  local ind = math.max(b.level - 2, 0) * STEP
  o.left, o.hanging = ind + STEP, STEP
  o.tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + STEP) .. '"/></w:tabs>'
  local r = b.level <= 3 and { b = true } or nil
  return p(xe.runs((label or "") .. "\t", r) .. xe.inl(b.content, r), o)
end

-- The signature block (typst signature-block): "Dated:" at the margin, "Respectfully submitted," and each counsel
-- group from SIG_COL, "- and –" between two groups; kept on one page.
local function signature(m)
  local parts = { { { raw(xe.runs("Dated: " .. txt(m.date))) }, 0 },
    { { raw(xe.runs("Respectfully submitted,")) }, SIG_COL } }
  for i, g in ipairs(items(m.signature)) do
    if i > 1 then parts[#parts + 1] = { { raw(xe.runs("- and –")) }, SIG_COL } end
    local ls = {}
    if g.signer then ls[#ls + 1] = raw(xe.runs("/s/ ") .. xe.inl(g.signer)) end
    for _, l in ipairs(items(g.lines)) do ls[#ls + 1] = l end
    parts[#parts + 1] = { ls, SIG_COL }
  end
  local out = {}
  for i, part in ipairs(parts) do
    local ls, left = part[1], part[2]
    local above = i == 1 and SIG_ABOVE or SIG_GAP
    if i < #parts then
      out[#out + 1] = lines(ls, { above = above, left = left, keep = true })
    else
      -- every line but the last kept with the next
      if #ls > 1 then out[#out + 1] = lines({ table.unpack(ls, 1, #ls - 1) }, { above = above, left = left, keep = true }) end
      out[#out + 1] = lines({ ls[#ls] }, { above = #ls == 1 and above or 0, left = left })
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Break rules (typst's, which LibreOffice does not share)
-- ---------------------------------------------------------------------------

-- None inside a token of adjacent parentheses ("7012(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060)
-- between ")" and "("; one after a slash followed by a letter ("and/or"), where LibreOffice keeps the word whole: a
-- zero-width space (U+200B) after it. Neither shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("¶¶ 36"; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("^[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

local function label_for(level, n)
  if level == 2 then return pandoc.utils.to_roman_numeral(n) .. "." end
  if level == 3 then return string.char(64 + n) .. "." end
  if level == 4 then return n .. "." end
  return string.char(96 + n) .. "."
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "division", "debtor", "chapter", "case_number", "caption", "adversary", "title", "counsel",
    "date", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  local blocks = doc.blocks:walk({ Link = function(l) return l.content end })

  -- labels per heading (VIB-MB-HEADINGS: each level counts within the heading above it); the needles in document
  -- order: the cover's first line (pages from 1), the contents' title, each heading with the words after it
  need("S:cover", COURT)
  need("S:toc", "TABLE OF CONTENTS")
  local counts, labelled, entries, h_n = { 0, 0, 0, 0 }, {}, {}, 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = b.level
      if lv >= 2 and lv <= 5 then
        counts[lv - 1] = counts[lv - 1] + 1
        for k = lv, 4 do counts[k] = 0 end
        labelled[i] = label_for(lv, counts[lv - 1])
      end
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = blocks[i + 1] and blocks[i + 1].content and text_of(blocks[i + 1].content) or ""
      local title = text_of(b.content)
      need(id, (labelled[i] and (labelled[i] .. " ") or "") .. (lv == 1 and pandoc.text.upper(title) or title), nxt)
      if lv <= 4 then entries[#entries + 1] = { id = id, level = lv, label = labelled[i], title = b.content } end
    end
  end
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n#section\tS:cover\tdecimal\t\n")
  write_file("FORMBOOK_FOOTERS", "rIdVibFooter\t" .. footer(m) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  -- the last paragraph stays whole with the signature (typst: one unbreakable block)
  check(blocks[1] and blocks[1].t == "Header", "the body must open with a heading (it opens the page after the contents)")
  local tail = #blocks
  check(blocks[tail] and blocks[tail].t == "Para", "the body must end with a paragraph (the signature is set with it)")
  local out = pandoc.Blocks({ xe.raw(cover(m)), xe.raw(contents(entries)) })
  local first = true
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out:insert(xe.raw(heading(b, labelled[i], first)))
      first = false
    elseif b.t == "Para" or b.t == "Plain" then
      local style = i == tail and "Body Text Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
      out:insert(pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style }))
    else
      error("vib-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out:walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
