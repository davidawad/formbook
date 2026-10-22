-- Memorandum of law in support of a motion, docx engine (docs/DOCX.md): the markdown contract -> the layout of
-- typst/ctb-motion-brief.typ on the styles of docx/reference.xml (fb render builds the reference document from it).
-- Three sections, as the typst template: the cover (the court's name, the caption boxes, the title; the oral-argument
-- legend in its footer), the table of contents and table of authorities (lower roman from i), the body (arabic from
-- 1) and the signature blocks. Numbered paragraphs (after the first heading) get their number typed, as the typst
-- template types it; lettered sub-items ("a. ...") are indented and not numbered. Every case word comes from the
-- frontmatter and the body; no case text is written into this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
--
-- Pages and footers (were docx/build-reference.sh, docx/render.sh and docx/pagemap.awk): fb render
-- (tools/fb/src/docxpass.rs) renders the document, finds the needles this filter writes ($FORMBOOK_NEEDLES: the
-- contents' title, the first body paragraph, each heading with the words after it, in document order) in the
-- LibreOffice PDF and renders again with their pages ($FORMBOOK_PAGES) until they settle. The footers are this
-- filter's ($FORMBOOK_FOOTERS): the cover's oral-argument legend, and from page i on the page number centred with the
-- docket line (Adv. Pro. No. and the judge's initials, from the frontmatter; L. Civ. R. 10) at the right; the last
-- section is $FORMBOOK_FINAL.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                -- typst pitch-body 24 pt, pitch-single 13.8 pt
local TW = 9360                              -- typst text-width 6.5 in
local INDENT = 720                           -- typst para-indent 0.5 in
local NUMBER_BOX = 720                       -- typst number-box 0.5 in
local LETTER = 720                           -- typst letter-indent 0.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288       -- typst caption-left 3.4 in, caption-gutter 0.2 in
local CAP_RIGHT = TW - CAP_LEFT - CAP_GUTTER -- 2.9 in
local CAP_RULE = 6                           -- typst caption-rule 0.75 pt (eighths of a point)
local CAP_PAD_RIGHT = 200                    -- typst caption-pad-right 10 pt
local CAP_PAD_BELOW = 160 - 15               -- typst caption-pad-below 8 pt, less the 0.75 pt rule LibreOffice adds to the row
local CASE_PAD = 144                         -- typst case-pad 0.1 in
local DEBTOR, VERSUS, DESIG = 720, 2880, 3600 -- typst debtor-indent 0.5 in, versus-indent 2.0 in, designation-indent 2.5 in
local PNUM = 720                             -- typst page-col 0.5 in
local ROW_HANG = 720                         -- typst row-hang 0.5 in
local TOC_INDENT = 720                       -- typst toc-indent 0.5 in
local SIG_GUTTER = 432                       -- typst sig-gutter 0.3 in
local CAPTION_ABOVE = 480                    -- typst caption-above 24 pt
local CAPTION_GAP = 240                      -- typst caption-gap 12 pt
local TITLE_ABOVE = 480                      -- typst title-above 24 pt
local TABLE_TITLE_BELOW = 480                -- typst table-title-below 24 pt
local ROW_ABOVE = 240                        -- typst row-above 12 pt
local SIG_ABOVE = 480                        -- typst sig-above 24 pt
local SIG_GAP = 276                          -- typst sig-gap 13.8 pt
local DOCKET_SIZE = 20                       -- typst docket-size 10 pt (half points)
local FOOTER = 720                           -- typst footer-distance 0.5 in
local NEEDLE_MAX = 60

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, pitch, left, right, hanging, first, jc, keep, lines, pre, tab, tabs, style };
-- single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.pre then props[#props + 1] = o.pre end
  if o.tabs then props[#props + 1] = o.tabs end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst block above): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A one-row table with fixed column widths; cells = { { xml, tcpr } }; the row is not split across pages.
local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    local body = cells[i][1]
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i][2] or "") .. '</w:tcPr>'
      .. (body ~= "" and body or p("")) .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
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
  return (pandoc.text.lower(s):gsub("[^a-z0-9]", ""))
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

-- ---------------------------------------------------------------------------
-- Sections and footers: letter, 1 in margins (L. Civ. R. 10); the footer line's box ends 0.5 in above the page edge
-- ---------------------------------------------------------------------------

local FTR_LEGEND, FTR_PAGE = "rIdCtbOral", "rIdCtbPage"

local function sect_pr(footer, fmt)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>'
    .. (fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or "") .. '</w:sectPr>'
end

-- The paragraph that ends a section (a 1 pt line, so it pushes nothing on).
local function section(footer, fmt)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>"
end

-- The running footer (typst running-footer): the page number centred, the docket line at the right, 10 pt.
local function page_footer(m)
  return '<w:p><w:pPr><w:tabs><w:tab w:val="center" w:pos="' .. (TW / 2) .. '"/><w:tab w:val="right" w:pos="' .. TW
    .. '"/></w:tabs>' .. xe.spacing(0, 0, SINGLE) .. xe.ind(0, nil, 0) .. xe.jc("left") .. '</w:pPr>'
    .. '<w:r><w:tab/></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
    .. '<w:r><w:tab/></w:r>'
    .. xe.runs("Adv. Pro. No. " .. txt(m.adv_number) .. " (" .. txt(m.judge) .. ")", { sz = DOCKET_SIZE }) .. '</w:p>'
end

-- D. Conn. L. Civ. R. 7(a)(1): whether oral argument is requested, in the lower margin of the first page (the cover's
-- footer line, bold, at the left).
local function legend(m)
  local oa = m.oral_argument
  if oa == nil then return nil end
  return txt(oa) == "requested" and "ORAL ARGUMENT REQUESTED" or "ORAL ARGUMENT NOT REQUESTED"
end

-- ---------------------------------------------------------------------------
-- Cover: caption (FRBP 9004(b), Official Form 416A), title
-- ---------------------------------------------------------------------------

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/></w:tcBorders>'

-- One caption box (typst caption-box): the party column with its rules, the gutter, the case column.
local function caption_box(left, right)
  return table_xml({ CAP_LEFT, CAP_GUTTER, CAP_RIGHT }, {
    { table.concat(left), RULES .. '<w:tcMar><w:bottom w:w="' .. CAP_PAD_BELOW .. '" w:type="dxa"/><w:right w:w="'
      .. CAP_PAD_RIGHT .. '" w:type="dxa"/></w:tcMar>' },
    { "" },
    { table.concat(right), '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>' },
  })
end

local function cover(m)
  local out = {}
  for _, k in ipairs({ "court", "district", "division" }) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(txt(m[k])), { b = true }), { jc = "center" })
  end
  out[#out + 1] = space(CAPTION_ABOVE)
  local right1 = { p(xe.runs("Chapter " .. txt(m.chapter))), p(xe.inl(m.main_case)) }
  if m.jointly_administered == true then right1[#right1 + 1] = p(xe.runs("(Jointly Administered)")) end
  out[#out + 1] = caption_box({ p(xe.runs("In re:")), p(xe.inl(m.debtors), { left = DEBTOR }),
    p(xe.runs("Debtors."), { left = DESIG }) }, right1)
  out[#out + 1] = space(CAPTION_GAP)
  local left2 = {}
  for k, party in ipairs(items(m.caption.parties)) do
    if k > 1 then left2[#left2 + 1] = p(xe.runs("v."), { left = VERSUS }) end
    for _, n in ipairs(items(party.names)) do left2[#left2 + 1] = p(line(n)) end
    left2[#left2 + 1] = p(line(party.designation), { left = DESIG })
  end
  out[#out + 1] = caption_box(left2, {
    p(xe.runs("Adv. Pro. No. " .. txt(m.adv_number) .. " (" .. txt(m.judge) .. ")")),
    p(xe.runs("Dated: " .. txt(m.date))),
  })
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { jc = "center", before = TITLE_ABOVE })
  out[#out + 1] = section(legend(m) and FTR_LEGEND or "rIdFtrNone", nil)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Table of contents and table of authorities
-- ---------------------------------------------------------------------------

-- A table's title on the body pitch, then its column label at the right (typst table-head).
local function table_head(title, col, pre)
  return p(xe.runs(title, { b = true }), { pre = pre, pitch = BODY, after = TABLE_TITLE_BELOW, keep = true, jc = "center" })
    .. p(xe.runs(col), { keep = true, jc = "right" })
end

-- A row: the text wraps before the page column, a dot leader runs to the page reference (typst listing-row).
local function row(text_xml, page_xml, left, hanging, before)
  return p(text_xml .. xe.runs(xe.LEAD) .. page_xml, { lines = true, tabs = xe.leader_tab(TW),
    before = before, left = left, hanging = hanging, right = PNUM })
end

local function toc(entries)
  local out = { table_head("TABLE OF CONTENTS", "Page") }
  for _, e in ipairs(entries) do
    local ind = e.level == 1 and 0 or TOC_INDENT
    out[#out + 1] = row(xe.inl(e.title), xe.runs(labels[e.id] or "0"), ind + ROW_HANG, ROW_HANG, ROW_ABOVE)
  end
  return table.concat(out)
end

-- The authorities by category, with the pages the frontmatter gives (typst toa).
local function toa(m)
  local out = { table_head("TABLE OF AUTHORITIES", "Page(s)", xe.BREAK) }
  for _, cat in ipairs(items(m.authorities)) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(txt(cat.category)), { b = true }), { before = ROW_ABOVE, keep = true })
    for _, a in ipairs(items(cat.items)) do
      out[#out + 1] = row(xe.inl(a.cite), xe.inl(a.pages), ROW_HANG, ROW_HANG, 0)
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature blocks (D. Conn. L. Civ. R. 10): one per signing firm, side by side
-- ---------------------------------------------------------------------------

local function signature(m)
  local blocks = items(m.signature.esigners)
  local n = #blocks
  local colw = math.floor((TW - SIG_GUTTER * (n - 1)) / n)
  local widths, cells = {}, {}
  for k, b in ipairs(blocks) do
    local ps = { p(xe.runs(pandoc.text.upper(txt(b.firm)))), p(xe.runs("/s/ " .. txt(b.esigner))) }
    for _, l in ipairs(items(b.lines)) do ps[#ps + 1] = p(line(l)) end
    widths[#widths + 1] = colw
    cells[#cells + 1] = { table.concat(ps) }
    if k < n then
      widths[#widths + 1] = SIG_GUTTER
      cells[#cells + 1] = { "" }
    end
  end
  -- typst: one unbreakable block, above sig-above; "RESPECTFULLY SUBMITTED," kept with the table, a blank single
  -- line below it
  return p(xe.runs("RESPECTFULLY SUBMITTED,", { b = true }), { before = SIG_ABOVE, after = SIG_GAP, keep = true })
    .. table_xml(widths, cells)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings on the body pitch with no space of their own, kept with the next block (typst section-heading): level 1
-- centred bold, level 2 bold left.
local function heading(level, content)
  return p(xe.inl(content, { b = true }), { style = "Heading" .. level, keep = true, pitch = BODY,
    jc = level == 1 and "center" or "left" })
end

local function body(blocks, entries)
  local out = {}
  local numbered, n, h = false, 0, 0
  local function lettered(s) return s:match("^%l%.%s") or s:match("^%l%.\u{00A0}") end
  for i, b in ipairs(blocks) do
    -- the words after a heading as the PDF has them: a numbered paragraph's number first
    local nb = blocks[i + 1]
    local nxt = nb and stringify(nb) or ""
    if nb and (nb.t == "Para" or nb.t == "Plain") and not lettered(nxt) then nxt = (n + 1) .. ". " .. nxt end
    nxt = nxt:sub(1, 40)
    if b.t == "Header" then
      numbered = true
      h = h + 1
      local level = math.min(b.level, 2)
      local id = "H:" .. h
      needle(id, stringify(b.content), nxt)
      entries[#entries + 1] = { id = id, level = level, title = b.content }
      out[#out + 1] = heading(level, b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      if #needles == 1 then needle("S:body", stringify(b.content), "") end
      -- (pandoc's smart reading may join "c." to the next word with a no-break space, as an abbreviation)
      if lettered(stringify(b.content)) then
        -- a lettered sub-item: indented, every line, not numbered (typst letter-indent)
        out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, left = LETTER })
      elseif numbered then
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          { pitch = BODY, first = INDENT, tab = INDENT + NUMBER_BOX })
      else
        out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, first = INDENT })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local k = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and (k .. ".") or "\u{2022}"
        out[#out + 1] = p(xe.runs(label .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { pitch = BODY, left = INDENT + NUMBER_BOX, hanging = NUMBER_BOX, tab = INDENT + NUMBER_BOX })
        k = k + 1
      end
    else
      error("ctb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function finish(doc)
  load_pages()
  local m = doc.meta
  for _, k in ipairs({ "court", "district", "division", "chapter", "main_case", "debtors", "judge", "adv_number",
    "caption", "date", "title", "signature" }) do
    if m[k] == nil then error("ctb-motion-brief.lua: missing required metadata field `" .. k .. "`") end
  end

  -- the contents' title first, so the search starts past the cover; then the body's first paragraph (where arabic
  -- numbering starts) and the headings, in document order
  needle("S:toc", "TABLE OF CONTENTS", "Page")
  local entries = {}
  local body_xml = body(doc.blocks, entries)
  local first = #entries > 0 and "H:1" or "S:body"
  for _, nd in ipairs(needles) do
    if nd:match("^S:body\t") then first = "S:body" end
  end
  needles[#needles + 1] = "#section\tS:toc\tlower-roman\t"
  needles[#needles + 1] = "#section\t" .. first .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")

  local footers = { FTR_PAGE .. "\t" .. page_footer(m) }
  local lg = legend(m)
  if lg then
    footers[#footers + 1] = FTR_LEGEND .. "\t" .. p(xe.runs(lg, { b = true })) end
  write_file("FORMBOOK_FOOTERS", table.concat(footers, "\n") .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr(FTR_PAGE, "decimal"))

  local out = { xe.raw(cover(m) .. toc(entries) .. toa(m) .. section(FTR_PAGE, "lowerRoman")
    .. body_xml .. signature(m)) }
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
