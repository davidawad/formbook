-- pamb (U.S. Bankruptcy Court, M.D. Pa.) docx engine (docs/DOCX.md). Mirrors typst/pamb-<kind>.typ:
--   * the court title (centred bold capitals), the caption (a table: the party column ruled at its right and foot,
--     the case column beside it; the adversary complaint has a second row for the parties and the adversary
--     number), the title, all from the sample's frontmatter (L.B.R. 9004-1);
--   * adversary: the Statement of Jurisdiction (FRBP 7008(a)), the lead-in, allegations numbered as the markdown
--     list numbers them (FRCP 10(b): the number at the indent, a tab to the text 1 in in), a pipe table borderless
--     on the body pitch, 1 in in;
--   * motion: headings labelled I., A., 1., a. in a 0.5 in box, each level 0.5 in further in, the text hanging;
--   * the last paragraph kept on one page with the signature block (single lines from the signature column);
--   * motion: the certificate of service (L.B.R. 9013-3) on a page of its own, and the word-count certificate
--     (L.B.R. 9013-2(b)) when the frontmatter states a count.
-- The footer (the page number, centred) and the last section (letter, 1 in margins) are written for fb render
-- ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the base styles are in docx/reference.xml. Nothing case-specific is written
-- here: every string comes from the sample or names a rule.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.
local CFG = { kind = "motion" } -- this copy: "motion"; the adversary-complaint copy sets "adversary"
local ADV = CFG.kind == "adversary"

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 280                 -- typst pitch-body 24 pt, pitch-single 14 pt
local TW = 9360                               -- typst text-width: 6.5 in
local INDENT = 720                            -- typst para-indent, num-box 0.5 in
local CAP_COL = 4680                          -- typst cap-col: half the text width
local CAP_PAD = 280                           -- typst cap-pad 14 pt
local CAP_BELOW = 240                         -- typst cap-below 12 pt
local CAP_RULE = 6                            -- typst cap-rule 0.75 pt (eighths of a point)
local RULE = 15                               -- LibreOffice sets the 0.75 pt rule below a row (typst strokes take no
                                              -- room): the cell padding below is that much less
local RIGHT_SET = -44                         -- a line centred in the ruled cell: LibreOffice ends the cell's lines
                                              -- 2.2 pt short of its margin
local NAME_INDENT, DESIG_INDENT = 720, 2592   -- typst name-indent 0.5 in, desig-indent 1.8 in
local ADV_BLANK = 38                          -- typst adv-blank
local SIG_COL = 4752                          -- typst sig-col 3.3 in
local COVER_GAP = 480                         -- typst cover-gap 24 pt
local TITLE_BELOW = 240                       -- typst title-below 12 pt
local SIG_ABOVE, SIG_GAP = 480, 480           -- typst sig-above, sig-gap 24 pt
local TABLE_CHAR, TABLE_SLACK = 120, 3        -- typst table-char 6 pt, table-slack
local TABLE_INDENT = 1440                     -- typst table-indent 1 in
local HEAD_TAB = 720                          -- typst heading-tab 0.5 in (motion)
local SERVED_GAP = 240                        -- typst served-gap 12 pt (motion)
local FOOTER_SZ = ADV and 22 or 24            -- typst footer-size: 11 pt (adversary), 12 pt (motion)
local FOOTER = 720                            -- typst footer-descent: the footer's line box ends 0.5 in above the edge

local function need(m, k)
  if m[k] == nil then error("pamb docx: missing required metadata field `" .. k .. "`", 0) end
  return m[k]
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

-- A paragraph: o = { before, after, pitch, left, hanging, first, right, jc, keep, brk, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- ---------------------------------------------------------------------------
-- Footer and section
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FRPR = '<w:rPr><w:sz w:val="' .. FOOTER_SZ .. '"/><w:szCs w:val="' .. FOOTER_SZ .. '"/></w:rPr>'
local FOOTER_P = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r>' .. FRPR .. '<w:fldChar w:fldCharType="begin"/></w:r><w:r>' .. FRPR
  .. '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>' .. FRPR
  .. '<w:fldChar w:fldCharType="separate"/></w:r><w:r>' .. FRPR .. '<w:t>1</w:t></w:r><w:r>' .. FRPR
  .. '<w:fldChar w:fldCharType="end"/></w:r>')

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdPambFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title (typst court-title, caption-table, cover)
-- ---------------------------------------------------------------------------

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local ZEROMAR = '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
  .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'

local function tblpr(width, indent)
  return '<w:tblPr><w:tblW w:w="' .. width .. '" w:type="dxa"/><w:tblInd w:w="' .. (indent or 0) .. '" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/>' .. ZEROMAR .. NOLOOK .. '</w:tblPr>'
end

local function mar(top, left, bottom, right)
  return '<w:tcMar><w:top w:w="' .. top .. '" w:type="dxa"/><w:left w:w="' .. left .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. bottom .. '" w:type="dxa"/><w:right w:w="' .. right .. '" w:type="dxa"/></w:tcMar>'
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

local function court_title(m, brk)
  local out = {}
  for i, l in ipairs(items(need(m, "court"))) do
    out[#out + 1] = p(xe.inl(upper(l), { b = true }), { jc = "center", brk = brk and i == 1 })
  end
  return table.concat(out)
end

-- The caption (typst caption-table): rows of { left paragraphs, right paragraphs }; the left cell ruled at its right
-- and foot; the space above a rule (and below it, in the next row) under both cells.
local function caption(m)
  local d = need(m, "debtor")
  local row1l = { p(xe.runs("IN RE:")) }
  for i, n in ipairs(items(d.name)) do
    row1l[#row1l + 1] = p(xe.inl(n), { left = NAME_INDENT, before = i == 1 and SINGLE or 0 })
  end
  local row1r = { p(xe.inl(d.chapter)), p(xe.runs("Case No. " .. txt(d.case_number)), { before = SINGLE }) }
  if not ADV then row1l[#row1l + 1] = p(xe.runs("Debtor"), { before = SINGLE }) end
  local rows = { { row1l, row1r } }
  if ADV then
    local sides = items(need(m, "caption"))
    local l2 = {}
    for i, side in ipairs(sides) do
      for k, n in ipairs(items(side.names)) do
        l2[#l2 + 1] = p(xe.inl(n), { before = (i > 1 and k == 1) and SINGLE or 0 })
      end
      l2[#l2 + 1] = p(xe.inl(side.designation), { left = DESIG_INDENT })
      if i < #sides then l2[#l2 + 1] = p(xe.runs("v."), { jc = "center", before = SINGLE, right = RIGHT_SET }) end
    end
    -- a blank number: underlined no-break spaces, a word joiner after them (LibreOffice draws no underline under
    -- the spaces that end a paragraph)
    local adv = txt(m.adversary_number)
    local r2 = adv ~= "" and xe.runs("Adversary No. " .. adv)
      or (xe.runs("Adversary No. ") .. xe.runs(string.rep("\u{00A0}", ADV_BLANK), { u = true }) .. xe.runs("\u{2060}"))
    rows[#rows + 1] = { l2, { p(r2) } }
  end
  local rule = ' w:val="single" w:sz="' .. CAP_RULE .. '" w:space="0" w:color="000000"/>'
  local lb = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom' .. rule .. '<w:right' .. rule
    .. '</w:tcBorders>'
  local out = { tblpr(TW), '<w:tblGrid><w:gridCol w:w="' .. CAP_COL .. '"/><w:gridCol w:w="' .. (TW - CAP_COL)
    .. '"/></w:tblGrid>' }
  for y, r in ipairs(rows) do
    local top = y == 1 and 0 or CAP_BELOW
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_COL .. '" w:type="dxa"/>' .. lb .. mar(top, 0, CAP_BELOW - RULE, CAP_PAD)
      .. '</w:tcPr>' .. table.concat(r[1]) .. '</w:tc>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TW - CAP_COL) .. '" w:type="dxa"/>' .. mar(top, CAP_PAD, CAP_BELOW - RULE, 0)
      .. '</w:tcPr>' .. table.concat(r[2]) .. '</w:tc></w:tr>'
  end
  return space(COVER_GAP) .. '<w:tbl>' .. table.concat(out) .. '</w:tbl>'
end

local function cover(m, brk)
  return court_title(m, brk) .. caption(m)
    .. p(xe.inl(upper(need(m, "title")), { b = true }), { jc = "center", before = COVER_GAP })
end

-- ---------------------------------------------------------------------------
-- Signature lines (typst signature-block): single lines from SIG_COL, kept together; `left` (runs) left of the
-- first (a tab and a hanging indent). rows: { runs, space before }.
-- ---------------------------------------------------------------------------

local function sig_lines(rows, left, above)
  local out = {}
  for i, r in ipairs(rows) do
    local o = { before = i == 1 and above or r[2], left = SIG_COL, keep = i < #rows }
    local body = r[1]
    if i == 1 then
      body = (left or "") .. xe.runs("\t") .. body
      o.hanging, o.tab = SIG_COL, SIG_COL
    end
    out[#out + 1] = p(body, o)
  end
  return table.concat(out)
end

local function signature(m)
  local sig = need(m, "signature")
  local rows
  if ADV then
    rows = { { xe.runs("Respectfully submitted,"), 0 }, { xe.inl(sig.firm), SIG_GAP },
      { xe.runs("/s/ ") .. xe.inl(sig.signer), SIG_GAP }, { xe.inl(sig.signer), 0 } }
    if sig.id then rows[#rows + 1] = { xe.inl(sig.id), 0 } end
  else
    rows = { { xe.runs("Respectfully Submitted,"), 0 }, { xe.runs("By: /s/ ") .. xe.inl(sig.signer), SIG_GAP } }
  end
  for _, l in ipairs(items(sig.lines)) do rows[#rows + 1] = { xe.inl(l), 0 } end
  local date = (ADV and m.date) and (xe.runs("Dated: ") .. xe.inl(m.date)) or nil
  return sig_lines(rows, date, SIG_ABOVE)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A pipe table (typst pipe-table): borderless, on the body pitch, TABLE_INDENT in; a column TABLE_CHAR per
-- character of its longest cell plus TABLE_SLACK, aligned as the delimiter row says; kept on one page.
local function pipe_table(b)
  local rows = {}
  for _, r in ipairs(b.head.rows) do rows[#rows + 1] = r end
  for _, body in ipairs(b.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = r end
  end
  local ncol = #b.colspecs
  local widths, total, cols = {}, 0, {}
  for j = 1, ncol do
    local need_ = 0
    for _, r in ipairs(rows) do
      local c = r.cells[j]
      local n = c and utf8.len(stringify(c.contents)) or 0
      if n > need_ then need_ = n end
    end
    widths[j] = (need_ + TABLE_SLACK) * TABLE_CHAR
    total = total + widths[j]
    cols[#cols + 1] = '<w:gridCol w:w="' .. widths[j] .. '"/>'
  end
  local out = { '<w:tbl>', tblpr(total, TABLE_INDENT), '<w:tblGrid>', table.concat(cols), '</w:tblGrid>' }
  for i, r in ipairs(rows) do
    local cells = {}
    for j = 1, ncol do
      local c = r.cells[j]
      local jc = b.colspecs[j][1] == "AlignRight" and "right" or "left"
      cells[j] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[j] .. '" w:type="dxa"/></w:tcPr>'
        .. p(c and xe.inl(pandoc.utils.blocks_to_inlines(c.contents)) or "", { pitch = BODY, jc = jc, keep = i < #rows })
        .. '</w:tc>'
    end
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return table.concat(out)
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s, n = s .. v[2], n - v[1] end
  end
  return s
end

-- The body blocks as paragraphs; the last one kept with the signature block.
local function body(blocks)
  local out = {}
  local hc = { 0, 0, 0, 0 }
  local n = #blocks
  for k, b in ipairs(blocks) do
    local keep = k == n
    if b.t == "Header" then
      if ADV then
        out[#out + 1] = p(xe.inl(b.level == 1 and upper(b.content) or b.content, { b = true }),
          { pitch = BODY, keep = true, jc = b.level == 1 and "center" or "left" })
      else
        -- typst heading-num: I., A., 1., a.; the label in a box HEAD_TAB wide at (level - 1) x HEAD_TAB
        local L = math.min(b.level, 4)
        hc[L] = hc[L] + 1
        for j = L + 1, 4 do hc[j] = 0 end
        local lab = L == 1 and (roman(hc[1]) .. ".") or L == 2 and (string.char(64 + hc[2]) .. ".")
          or L == 3 and (hc[3] .. ".") or (string.char(96 + hc[4]) .. ".")
        local ind = (L - 1) * HEAD_TAB
        out[#out + 1] = p(xe.runs(lab .. "\t", { b = true }) .. xe.inl(L == 1 and upper(b.content) or b.content, { b = true }),
          { pitch = BODY, keep = true, left = ind + HEAD_TAB, hanging = HEAD_TAB, tab = ind + HEAD_TAB })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { pitch = BODY, first = INDENT, keep = keep })
    elseif b.t == "OrderedList" and ADV then
      local start = b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs((start + i - 1) .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { pitch = BODY, first = INDENT, tab = 2 * INDENT, keep = keep and i == #b.content })
      end
    elseif b.t == "Table" and ADV then
      out[#out + 1] = pipe_table(b)
    else
      -- (motion: headings and paragraphs only, as typst/pamb-motion-brief.typ reads them)
      error("pamb.lua: unexpected block " .. b.t)
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Adversary: the Statement of Jurisdiction (FRBP 7008(a), typst jurisdiction-block)
-- ---------------------------------------------------------------------------

local function jurisdiction(m)
  local j, d = need(m, "jurisdiction"), need(m, "debtor")
  local function bp(x) return p(x, { pitch = BODY, first = INDENT }) end
  return p(xe.runs("STATEMENT OF JURISDICTION", { b = true }), { pitch = BODY, jc = "center", keep = true })
    .. bp(xe.runs("This adversary proceeding arises in and relates to the ") .. xe.inl(d.chapter)
      .. xe.runs(" case of ") .. xe.inl(items(d.name)[1]) .. xe.runs(", Case No. " .. txt(d.case_number)
      .. ", pending in the United States Bankruptcy Court for the ") .. xe.inl(j.district) .. xe.runs("."))
    .. bp(xe.inl(need(j, "core"))) .. bp(xe.inl(need(j, "consent")))
end

-- ---------------------------------------------------------------------------
-- Motion: certificate of service (L.B.R. 9013-3) and word-count certificate (L.B.R. 9013-2(b))
-- ---------------------------------------------------------------------------

local function certificates(m)
  local cos = need(m, "certificate_of_service")
  local out = { court_title(m, true), caption(m),
    p(xe.runs("Certificate of Service", { b = true }), { jc = "center", before = COVER_GAP }), space(TITLE_BELOW),
    p(xe.runs("The undersigned certifies that on " .. txt(cos.date) .. ", the undersigned caused a true and correct copy of ")
      .. xe.inl(need(m, "title")) .. xe.runs(" to be served " .. txt(cos.method) .. ", on the following persons:"),
      { pitch = BODY, first = INDENT }) }
  for _, s in ipairs(items(cos.served)) do
    out[#out + 1] = p(xe.inl(s.name), { left = INDENT, keep = true, before = SERVED_GAP })
    out[#out + 1] = p(xe.inl(s.address), { left = INDENT, keep = true })
    out[#out + 1] = p(xe.runs("Represents: ") .. xe.inl(s.represents), { left = INDENT })
  end
  out[#out + 1] = sig_lines({ { xe.runs("/s/ ") .. xe.inl(cos.signer), 0 }, { xe.inl(cos.signer), 0 } },
    xe.runs("Date: " .. txt(cos.date)), SIG_ABOVE)
  if m.word_count ~= nil then
    local signer = need(m, "signature").signer
    out[#out + 1] = p(xe.runs("Certificate of Compliance with Word-Count Limit", { b = true }),
      { pitch = BODY, jc = "center", keep = true, brk = true })
    out[#out + 1] = p(xe.runs("The undersigned certifies that this brief contains " .. txt(m.word_count)
      .. " words, as counted by the word-processing system used to prepare it, and complies with the 5,000-word"
      .. " limit of L.B.R. 9013-2(b)."), { pitch = BODY, first = INDENT, keep = true })
    out[#out + 1] = sig_lines({ { xe.runs("/s/ ") .. xe.inl(signer), 0 }, { xe.inl(signer), 0 } }, nil, SIG_ABOVE)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Break rules and the document
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("541(a)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."), and none between a doubled section sign or pilcrow and its number
-- ("§§ 541"; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

local function finish(doc)
  local m = doc.meta
  for _, k in ipairs(ADV and { "court", "debtor", "caption", "title", "jurisdiction", "signature" }
    or { "court", "debtor", "title", "signature", "certificate_of_service" }) do
    need(m, k)
  end
  write_file("FORMBOOK_FOOTERS", "rIdPambFooter\t" .. FOOTER_P .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = { cover(m, false), space(TITLE_BELOW) }
  if ADV then out[#out + 1] = jurisdiction(m) end
  out[#out + 1] = body(doc.blocks)
  out[#out + 1] = signature(m)
  if not ADV then out[#out + 1] = certificates(m) end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
