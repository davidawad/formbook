-- S.D. Ohio adversary complaint (ohsb), docx engine (docs/DOCX.md). Mirrors typst/ohsb-adversary-complaint.typ:
--   * the court title (three centred bold single lines), the caption (a borderless table, one row per single line:
--     the parties | a ")" beside every party line | the case information 0.15 in in), the title of the paper, all from
--     the sample's frontmatter (LBR 9004-2);
--   * the lead-in, unnumbered; body paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b), via FRBP 7010): the number,
--     a tab to the text 1 in in; headings centred bold (level 1 in capitals) on the body pitch, kept with the next
--     block; roman relief items renumbered i., ii., ... as the allegations are; a markdown list numbered half an inch
--     in, the text hanging;
--   * the signature block at {{SIGNATURE}} (single lines in the signature column, "Dated:" left of the first when the
--     frontmatter has a date), kept on one page with the paragraph before it;
--   * an "EXHIBIT" heading opens a page; a pipe table single-spaced with 0.5 pt rules, centred.
-- The footer (the page number, centred) and the last section (letter, 1 in margins, LBR 9004-1(b)) are written for fb
-- render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the body styles are in docx/reference.xml. Nothing case-specific is
-- written here: every string comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 280                 -- typst pitch-body 24 pt, pitch-single 14 pt
local TW = 9360                               -- typst text-width: 6.5 in
local INDENT = 720                            -- typst para-indent, num-box 0.5 in
local CAP_LEFT, CAP_MID = 4896, 432           -- typst cap-left 3.4 in, cap-mid 0.3 in
local CAP_PAD = 216                           -- typst cap-pad 0.15 in
local SIG_COL = 4032                          -- typst sig-col 2.8 in
local COVER_GAP = 280                         -- typst cover-gap 14 pt
local TEXT_ABOVE = 480                        -- typst text-above 24 pt
local SIG_ABOVE = 240                         -- typst sig-above 12 pt
local TABLE_SPACE = 240                       -- typst table-space 12 pt
local TABLE_SLACK, TABLE_CHAR = 3, 120        -- typst table-slack, table-char 6 pt
local TABLE_INSET = 100                       -- typst table-inset 5 pt
local RULE = 10                               -- LibreOffice sets each 0.5 pt rule below a row (typst strokes take no
                                              -- room): the cell padding below is that much less
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function check(cond, msg)
  if not cond then error("ohsb-adversary-complaint docx: " .. msg, 0) end
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, brk, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local RULES = '<w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  .. '<w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tblBorders>'

-- A table: widths (twips), rows of cells (each cell: paragraphs as a string); o = { rules, pad, padb, center }.
local function grid(widths, rows, o)
  o = o or {}
  local total, cols = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local pad = o.pad or 0
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. (o.center and '<w:jc w:val="center"/>' or '<w:tblInd w:w="0" w:type="dxa"/>')
    .. (o.rules and RULES or NOBORDER) .. '<w:tblLayout w:type="fixed"/><w:tblCellMar>'
    .. '<w:top w:w="' .. pad .. '" w:type="dxa"/><w:left w:w="' .. pad .. '" w:type="dxa"/><w:bottom w:w="' .. (o.padb or pad)
    .. '" w:type="dxa"/><w:right w:w="' .. pad .. '" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' }
  for _, row in ipairs(rows) do
    local cells = {}
    for i, cell in ipairs(row) do
      cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>'
        .. (cell ~= "" and cell or p("")) .. "</w:tc>"
    end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Footer and section (LBR 9004-1(b))
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_P = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdOhsbFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper (typst cover)
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for _, l in ipairs({ "UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF OHIO", txt(m.division) }) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" })
  end
  local left, right = items(m.caption.left), items(m.caption.right)
  local rows = {}
  for i = 1, math.max(#left, #right) do
    local l, r = left[i], right[i]
    rows[#rows + 1] = {
      p(l and txt(l) ~= "" and xe.inl(l) or ""),
      p(i <= #left and xe.runs(")") or "", { jc = "center" }),
      p(r and txt(r) ~= "" and xe.inl(r) or "", { left = CAP_PAD }),
    }
  end
  out[#out + 1] = space(COVER_GAP)
  out[#out + 1] = grid({ CAP_LEFT, CAP_MID, TW - CAP_LEFT - CAP_MID }, rows)
  out[#out + 1] = p(xe.runs(txt(m.brief_title), { b = true }), { jc = "center", before = COVER_GAP })
  out[#out + 1] = space(TEXT_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-lines): single lines from SIG_COL, "Dated:" left of the first (a tab and a hanging
-- indent), kept on one page
-- ---------------------------------------------------------------------------

local function signature(m)
  local sig = m.signature
  local list = {}
  if sig.closing and txt(sig.closing) ~= "" then list[#list + 1] = sig.closing; list[#list + 1] = "" end
  if sig.firm then
    for _, l in ipairs(items(sig.firm)) do list[#list + 1] = l end
    list[#list + 1] = ""
  end
  for _, l in ipairs(items(sig.lines)) do list[#list + 1] = l end
  local date = m.date and txt(m.date) ~= "" and xe.runs("Dated: ") .. xe.inl(m.date) or ""
  local lines, gap = {}, SIG_ABOVE
  for _, l in ipairs(list) do
    if l == "" then gap = gap + SINGLE else
      lines[#lines + 1] = { xe.inl(l), gap }
      gap = 0
    end
  end
  local out = {}
  for i, l in ipairs(lines) do
    local first = i == 1 and (date .. xe.runs("\t")) or ""
    out[#out + 1] = p(first .. l[1], { before = l[2], left = SIG_COL, hanging = i == 1 and SIG_COL or nil,
      tab = i == 1 and SIG_COL or nil, keep = i < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- The pipe table (typst pipe-table): 0.5 pt rules, single-spaced, centred; a column TABLE_CHAR per character of its
-- longest cell plus TABLE_SLACK; kept on one page.
local function pipe_table(b)
  local rows = {}
  for _, r in ipairs(b.head.rows) do rows[#rows + 1] = r end
  for _, body in ipairs(b.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = r end
  end
  local ncol = #b.colspecs
  local widths = {}
  for j = 1, ncol do
    local need = 0
    for _, r in ipairs(rows) do
      local c = r.cells[j]
      local n = c and utf8.len(stringify(c.contents)) or 0
      if n > need then need = n end
    end
    widths[j] = (need + TABLE_SLACK) * TABLE_CHAR
  end
  local trs = {}
  for i, r in ipairs(rows) do
    local cells = {}
    for j = 1, ncol do
      local c = r.cells[j]
      cells[j] = p(c and xe.inl(pandoc.utils.blocks_to_inlines(c.contents)) or "", { keep = i < #rows })
    end
    trs[#trs + 1] = cells
  end
  return space(TABLE_SPACE) .. grid(widths, trs, { center = true, rules = true, pad = TABLE_INSET, padb = TABLE_INSET - RULE })
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph pandoc writes (so its footnotes are Word footnotes): `label` and a tab, then the text.
local function styled(style, label, content)
  local inl = pandoc.Inlines({})
  if label then inl:insert(pandoc.RawInline("openxml", xe.runs(label .. "\t"))) end
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
end

local ROMAN = { { 1000, "m" }, { 900, "cm" }, { 500, "d" }, { 400, "cd" }, { 100, "c" }, { 90, "xc" },
  { 50, "l" }, { 40, "xl" }, { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
local function roman(n)
  local s = ""
  for _, r in ipairs(ROMAN) do
    while n >= r[1] do s, n = s .. r[2], n - r[1] end
  end
  return s
end

-- A paragraph that starts with a lower-case roman numeral and a period (a relief item, typst is-relief): its text.
local function relief_text(c)
  if c[1] and c[1].t == "Str" and c[1].text:match("^[ivxlcdm]+%.$") and c[2] and c[2].t == "Space" then
    local rest = pandoc.Inlines({})
    for k = 3, #c do rest:insert(c[k]) end
    return rest
  end
end

local function is_signature(b)
  return (b.t == "Para" or b.t == "Plain") and stringify(b) == "{{SIGNATURE}}"
end

-- The body as blocks; the paragraph (or a list's last item) before the signature is kept with it.
local function body(blocks, m)
  local out = pandoc.Blocks({})
  local n, relief = 0, 0
  for k, b in ipairs(blocks) do
    local keep = blocks[k + 1] ~= nil and is_signature(blocks[k + 1])
    if b.t == "Header" then
      local t = stringify(b.content)
      out:insert(xe.raw(p(xe.inl(b.level == 1 and upper(b.content) or b.content, { b = true }),
        { pitch = BODY, jc = "center", keep = true, brk = b.level == 1 and t:upper():match("^EXHIBIT") ~= nil })))
    elseif is_signature(b) then
      out:insert(xe.raw(signature(m)))
    elseif b.t == "Para" or b.t == "Plain" then
      local r = relief_text(b.content)
      local style = keep and "Numbered Paragraph Keep" or "Numbered Paragraph"
      if r then
        relief = relief + 1
        out:insert(styled(style, roman(relief) .. ".", r))
      else
        n = n + 1
        out:insert(styled(style, n .. ".", b.content))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        out:insert(styled((keep and i == #b.content) and "List Number Keep" or "List Number", (start + i - 1) .. ".",
          pandoc.utils.blocks_to_inlines(item)))
      end
    elseif b.t == "Table" then
      out:insert(xe.raw(pipe_table(b)))
    else
      error("ohsb-adversary-complaint.lua: unexpected block " .. b.t)
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("547(c)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
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

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs({ "division", "caption", "brief_title", "signature" }) do
    check(m[k] ~= nil, "missing required metadata field `" .. k .. "`")
  end
  check(m.caption.left ~= nil and m.caption.right ~= nil, "LBR 9004-2: the caption needs `left` and `right` lines")
  write_file("FORMBOOK_FOOTERS", "rIdOhsbFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  if m.lead_in then out:insert(styled("Body Text", nil, m.lead_in)) end
  out:extend(body(doc.blocks, m))
  -- the document ends in a paragraph of its own, 1 pt high (a last table would otherwise end it)
  out:insert(xe.raw(space(20)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out:walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
