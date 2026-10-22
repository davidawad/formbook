-- Motion brief in an adversary proceeding, D. Del. Bankr. (deb), docx engine (docs/DOCX.md). Mirrors
-- typst/deb-motion-brief.typ. One document in three sections:
--   * the cover (LR 7007-2(a)(i); no page number): the court line, the two Form 416 captions (LR 9004-1(a); each a
--     one-row table: the party names at the left, each designation set right, the cell ruled at its right and foot;
--     the case information 0.35 in right of the rule), the title, the party designation, and "Dated:" beside the
--     counsel lines from 3.2 in;
--   * the front matter (lower roman from i): the table of contents (LR 7007-2(b)(i)(A); the table of authorities and
--     the body's level-1 and level-2 headings, single-spaced rows, a dot leader to the page column) and the table of
--     authorities (the markdown before the first level-1 heading; its "###" heading opens a page);
--   * the brief (arabic from 1): headings bold on the body pitch, kept with the next block (level 1 centred
--     capitals, level 2 at the margin hanging 0.5 in); paragraphs and block quotations pandoc writes (so footnotes
--     are Word footnotes) in the styles of docx/reference.xml; the last paragraph kept with the signature block
--     ("Dated:" and the place at the left, each counsel block from 3.2 in).
-- The contents' pages come from fb render's passes (needles in $FORMBOOK_NEEDLES, pages back in $FORMBOOK_PAGES;
-- tools/fb/src/docxpages.rs); the footers and the last section are written for fb render ($FORMBOOK_FOOTERS,
-- $FORMBOOK_FINAL). Nothing case-specific is written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 280                 -- typst pitch-body 24 pt, pitch-single 14 pt
local TW = 9360                               -- typst text-width: 6.5 in
local HANG = 720                              -- typst heading-hang 0.5 in
local CAP_LEFT = 4896                         -- typst cap-left 3.4 in
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local CAP_PAD_RIGHT = 200                     -- typst cap-pad-right 10 pt
local RIGHT_SET = -44                         -- a designation set right: LibreOffice ends it 2.2 pt short of the margin
local CAP_PAD_BELOW = 160 - 15                -- typst cap-pad-below 8 pt, less the rule LibreOffice sets below it
local CAP_RIGHT = 504                         -- typst cap-right 0.35 in
local SIG_COL = 4608                          -- typst sig-col 3.2 in
local COVER_GAP = 280                         -- typst cover-gap 14 pt
local COUNSEL_ABOVE = 560                     -- typst counsel-above 28 pt
local TOC_STEP, TOC_HANG, TOC_COL = 720, 720, 720   -- typst toc-step, toc-hang, toc-col
local TOC_ABOVE, TOC_GAP_1, TOC_GAP = 480, 280, 140 -- typst toc-above, toc-gap-1, toc-gap
local SIG_ABOVE = 480                         -- typst sig-above 24 pt
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function check(cond, msg)
  if not cond then error("deb-motion-brief docx: " .. msg, 0) end
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

-- A paragraph: o = { keep, brk, tabs, before, after, pitch, left, hanging, first, right, jc }; single pitch by
-- default; its properties in the schema's order.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

local function tab_at(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

-- Single lines, one paragraph each; an empty item is a blank single line (the space before the next).
local function lines(list, o)
  local out, gap = {}, 0
  for _, l in ipairs(list) do
    if txt(l) == "" then gap = gap + SINGLE else
      local q = { before = gap }
      for k, v in pairs(o or {}) do q[k] = v end
      out[#out + 1] = p(xe.inl(l), q)
      gap = 0
    end
  end
  return table.concat(out), gap
end

-- Lines from SIG_COL (typst column-lines): `left` (runs) beside the first of them (a tab and a hanging indent);
-- an empty row is a blank single line, except beside a left text. `keep`: the lines stay on one page.
local function column_lines(rows, left, above, keep)
  local list, gap = {}, above
  for n, r in ipairs(rows) do
    if txt(r) == "" and n > #left then gap = gap + SINGLE else
      list[#list + 1] = { left[n], txt(r) ~= "" and xe.inl(r) or "", gap }
      gap = 0
    end
  end
  local out = {}
  for i, l in ipairs(list) do
    local o = { before = l[3], left = SIG_COL, keep = keep and i < #list }
    local body = l[2]
    if l[1] then
      body = l[1] .. xe.runs("\t") .. body
      o.hanging, o.tabs = SIG_COL, tab_at(SIG_COL)
    end
    out[#out + 1] = p(body, o)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Footers and sections
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_PAGE = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')
local FOOTER_NONE = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") }, "")

-- A section's properties: its footer, letter paper, 1 in margins, the page numbering.
local function sect(footer, fmt, start)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="' .. fmt .. '"'
    .. (start and (' w:start="' .. start .. '"') or "") .. '/></w:sectPr>'
end

-- The section ends with the last paragraph of `xml` (no empty paragraph of its own: it would take a line).
local function end_section(xml, sectpr)
  local last
  local from = 1
  while true do
    local j = xml:find("</w:pPr>", from, true)
    if not j then break end
    last, from = j, j + 1
  end
  check(last ~= nil, "a section must end with a paragraph")
  return xml:sub(1, last - 1) .. sectpr .. xml:sub(last)
end

-- ---------------------------------------------------------------------------
-- Cover (typst cover)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function caption_block(c)
  local left = {}
  for k, party in ipairs(items(c.parties)) do
    local names = items(party.names)
    if k > 1 then table.insert(names, 1, "") end
    local x, gap = lines(names)
    left[#left + 1] = x
    if party.designation then
      left[#left + 1] = p(xe.inl(party.designation), { before = gap, jc = "right", right = RIGHT_SET })
    end
  end
  local right = lines(items(c.right))
  local rule = ' w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local lborders = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom' .. rule .. '<w:right' .. rule
    .. '</w:tcBorders>'
  local function mar(left_, bottom, right_)
    return '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="' .. left_ .. '" w:type="dxa"/>'
      .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right_ .. '" w:type="dxa"/></w:tcMar>'
  end
  return xe.para({ xe.spacing(0, 0, COVER_GAP) }, "")
    .. '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/>'
    .. '<w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. NOLOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TW - CAP_LEFT)
    .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/>' .. lborders .. mar(0, CAP_PAD_BELOW, CAP_PAD_RIGHT)
    .. '</w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TW - CAP_LEFT) .. '" w:type="dxa"/>' .. mar(CAP_RIGHT, CAP_PAD_BELOW, 0)
    .. '</w:tcPr>' .. (right ~= "" and right or p("")) .. '</w:tc></w:tr></w:tbl>'
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function cover(m)
  return p(xe.inl(upper(m.court), { b = true }), { jc = "center" })
    .. caption_block(m.caption.bankruptcy)
    .. caption_block(m.caption.adversary)
    .. p(xe.inl(m.title, { b = true }), { jc = "center", before = COVER_GAP })
    .. p(xe.inl(m.party_designation), { jc = "center", before = COVER_GAP })
    .. column_lines(items(m.counsel), { xe.runs("Dated: ") .. xe.inl(m.date) }, COUNSEL_ABOVE, false)
end

-- ---------------------------------------------------------------------------
-- Needles and pages (the contents' page numbers; fb render's multi-pass build)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, _, lab = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = lab end
  end
  f:close()
end

-- A heading's needle: the heading with the words after it, and the heading alone as the fallback.
local function needle(id, content, nxt)
  local h = stringify(content)
  return table.concat({ id, "B", norm(h .. " " .. nxt):sub(1, NEEDLE_MAX), norm(h):sub(1, NEEDLE_MAX) }, "\t")
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

-- Headings (typst heading-block): bold on the body pitch, kept with the next block; level 2 at the margin hanging,
-- the others centred capitals. brk: opens a page.
local function heading(level, content, brk)
  local o = { pitch = BODY, keep = true, brk = brk, jc = level == 2 and "left" or "center" }
  if level == 2 then o.left, o.hanging = HANG, HANG end
  return p(xe.inl(level == 2 and content or upper(content), { b = true }), o)
end

-- The contents (typst contents): single-spaced rows indented by level, the page in a column at the right after a
-- dot leader.
local function contents(entries)
  local out = { heading(1, pandoc.Inlines({ pandoc.Str("Table"), pandoc.Space(), pandoc.Str("of"), pandoc.Space(),
    pandoc.Str("Contents") })) }
  for i, e in ipairs(entries) do
    local ind = e.level == 2 and TOC_STEP or 0
    local title = e.level == 2 and e.content or upper(e.content)
    out[#out + 1] = p(xe.inl(title) .. xe.runs(xe.LEAD) .. xe.runs(labels[e.id] or "0"), {
      tabs = xe.leader_tab(TW), before = i == 1 and TOC_ABOVE or (e.level == 2 and TOC_GAP or TOC_GAP_1),
      left = ind + TOC_HANG, hanging = TOC_HANG, right = TOC_COL })
  end
  return table.concat(out)
end

-- A paragraph pandoc writes (so its footnotes are Word footnotes), in a style of docx/reference.xml.
local function styled(style, content)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

-- ---------------------------------------------------------------------------
-- Break rules on every run
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("523(a)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 547"; the typst template boxes them): no-break spaces.
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

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "court", "caption", "title", "party_designation", "date", "counsel", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  check(m.caption.bankruptcy ~= nil and m.caption.adversary ~= nil,
    "LR 9004-1(a): the caption needs `bankruptcy` and `adversary` blocks")
  load_pages()

  -- the front matter runs to the first level-1 heading; the brief from it
  local front, main = {}, {}
  for _, b in ipairs(doc.blocks) do
    if b.t ~= "HorizontalRule" then
      if #main == 0 and not (b.t == "Header" and b.level == 1) then front[#front + 1] = b else main[#main + 1] = b end
    end
  end

  -- the contents' entries and their needles, in document order: the contents' own heading (lower roman from it),
  -- the front-matter headings, the brief's level-1 and level-2 headings (arabic from the first)
  local entries = {}
  local needles = { table.concat({ "C", "B", norm("Table of Contents"), norm("Table of Contents") }, "\t") }
  local function collect(list_, all, prefix)
    for i, b in ipairs(list_) do
      if b.t == "Header" and (all or b.level <= 2) then
        local id = prefix .. (#entries + 1)
        entries[#entries + 1] = { id = id, level = all and 1 or b.level, content = b.content }
        needles[#needles + 1] = needle(id, b.content, list_[i + 1] and stringify(list_[i + 1]) or "")
      end
    end
  end
  collect(front, true, "F")
  local first_body = #entries + 1
  collect(main, false, "H")
  needles[#needles + 1] = "#section\tC\tlower-roman\t"
  if entries[first_body] then needles[#needles + 1] = "#section\t" .. entries[first_body].id .. "\tdecimal\t" end
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdDebPage\t" .. FOOTER_PAGE .. "\nrIdDebNone\t" .. FOOTER_NONE .. "\n")
  write_file("FORMBOOK_FINAL", sect("rIdDebPage", "decimal", 1))

  local out = pandoc.Blocks({})
  -- 1. the cover (no page number)
  out:insert(xe.raw(end_section(cover(m), sect("rIdDebNone", "decimal", nil))))
  -- 2. the contents and the front matter (i, ii, ...): a "###" heading opens a page
  local x = { contents(entries) }
  for _, b in ipairs(front) do
    if b.t == "Header" then
      x[#x + 1] = heading(b.level == 2 and 2 or 1, b.content, true)
    elseif b.t == "Para" or b.t == "Plain" then
      x[#x + 1] = p(xe.inl(b.content), { pitch = BODY, first = HANG })
    else
      error("deb-motion-brief.lua: unexpected front-matter block " .. b.t)
    end
  end
  out:insert(xe.raw(end_section(table.concat(x), sect("rIdDebPage", "lowerRoman", 1))))
  -- 3. the brief (1, 2, ...); the last paragraph kept with the signature block
  for k, b in ipairs(main) do
    if b.t == "Header" then
      out:insert(xe.raw(heading(b.level, b.content)))
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        check(q.t == "Para" or q.t == "Plain", "a block quotation holds paragraphs only")
        out:insert(styled("Quotation", q.content))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out:insert(styled(k == #main and "Body Text Keep" or "Body Text", b.content))
    else
      error("deb-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  local rows = {}
  for k, b in ipairs(items(m.signature.blocks)) do
    if k > 1 then rows[#rows + 1] = "" end
    for _, l in ipairs(items(b.firm)) do rows[#rows + 1] = l end
    rows[#rows + 1] = ""
    for _, l in ipairs(items(b.attorneys)) do rows[#rows + 1] = l end
  end
  out:insert(xe.raw(column_lines(rows, { xe.runs("Dated: ") .. xe.inl(m.date), xe.inl(m.signature.place) },
    SIG_ABOVE, true)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out:walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
