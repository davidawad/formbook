-- E.D. Wash. Bankruptcy pleadings (waeb), docx engine. Mirrors typst/waeb-adversary-complaint.typ and
-- typst/waeb-motion-brief.typ, which share this layout: the counsel block (groups side by side) and the court title on
-- page 1 (LBR 9004-1(a)(4), (6)), the caption (a borderless table: the party column with a rule at its right and
-- foot, a gutter, the case column; LBR 9004-1(a)(5)), the body (numbered paragraphs, FRCP 10(b); `~ ` paragraphs
-- unnumbered; `#` headings centred bold, `##` lettered A., B., ...; a bold-only line centred; `- ` items lettered
-- (a), (b), ...; the complaint's pipe tables), the signature block and, in a complaint, the exhibits on pages of
-- their own. Numbers and letters are typed text, as the typst templates type them. Every case word comes from the
-- frontmatter. The same file is in docx/ of both doc types: a frontmatter with `case_no` is a motion (judge line,
-- signature blocks), one with `related_case` a complaint. The footer (LBR 9004-1(a)(7): the abbreviated name of the
-- document and the page number, bottom left) is written to $FORMBOOK_FOOTERS, the section to $FORMBOOK_FINAL. Font,
-- the body styles and the footnotes are in docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 560 the body, 322 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 560, 322                -- typst pitch-body 28 pt, pitch-single 16.1 pt
local TW = 9360                              -- typst text-width: 6.5 in
local INDENT = 720                           -- typst para-indent; number-box, letter-box, heading-box 0.5 in
local COUNSEL_GUTTER = 432                   -- typst counsel-gutter 0.3 in
local CAP_LEFT, CAP_GUTTER = 5328, 432       -- typst caption-left 3.7 in, caption-gutter 0.3 in
local CAP_RIGHT = TW - CAP_LEFT - CAP_GUTTER -- 2.5 in
local CAP_PAD, CAP_FOOT = 216, 180           -- typst caption-pad 0.15 in, caption-foot 9 pt
local CAP_CASE_PAD = 144                     -- typst caption-case-pad 0.1 in
local CAP_RULE = 15                          -- typst rule 0.75 pt (w:sz 6); LibreOffice sets a border inside the cell
                                             -- (typst strokes take no room): the padding next to it is that much less
local DESIGNATION, VERSUS = 2160, 1152       -- typst designation-indent 1.5 in, versus-indent 0.8 in
local SIG_LEFT = 4320                        -- typst sig-left 3.0 in
local BLOCK_GAP = 322                        -- typst block-gap 16.1 pt
local COVER_BELOW = 560                      -- typst cover-below 28 pt
local SIG_ABOVE = 560                        -- typst sig-above 28 pt
local JUDGE_BELOW = 0
local TABLE_SLACK, TABLE_CHAR = 1, 140       -- typst table-slack, table-char 7 pt
local TABLE_INSET = 100                      -- typst table-inset 5 pt
local RULE = 10                              -- a 0.5 pt rule below each row in LibreOffice: the padding below is less
local FOOTER = 720                           -- typst footer-distance 0.5 in

local function check(cond, msg)
  if not cond then error("waeb docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
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

local function is_list(v)
  return v ~= nil and (v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List"))
end

-- A paragraph: o = { before, after, pitch, left, hanging, first, jc, keep, tab, style, brk }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
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

-- A table: widths (twips), rows of cells (a cell: paragraphs as a string, or { xml, tcpr }); o = { rules, pad, padb }.
local function grid(widths, rows, o)
  o = o or {}
  local total, cols = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local pad = o.pad or 0
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. (o.rules and RULES or NOBORDER) .. '<w:tblLayout w:type="fixed"/><w:tblCellMar>'
    .. '<w:top w:w="' .. pad .. '" w:type="dxa"/><w:left w:w="' .. pad .. '" w:type="dxa"/><w:bottom w:w="' .. (o.padb or pad)
    .. '" w:type="dxa"/><w:right w:w="' .. pad .. '" w:type="dxa"/></w:tblCellMar>' .. NOLOOK
    .. '</w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' }
  for _, row in ipairs(rows) do
    local cells = {}
    for i, cell in ipairs(row) do
      local xml, tcpr = cell, ""
      if type(cell) == "table" then xml, tcpr = cell[1], cell[2] end
      cells[#cells + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. tcpr .. '</w:tcPr>'
        .. (xml ~= "" and xml or p("")) .. "</w:tc>"
    end
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Page one: counsel, judge, court title, caption (LBR 9004-1(a)(4)-(6); FRBP 7010, FRCP 10(a))
-- ---------------------------------------------------------------------------

-- Counsel: one list of lines, or a list of groups set side by side (typst counsel-block).
local function counsel(m)
  local c = items(m.counsel)
  local groups = is_list(c[1]) and c or { c }
  local n = #groups
  local col = math.floor((TW - (n - 1) * COUNSEL_GUTTER) / n)
  local widths, cells = {}, {}
  for i, g in ipairs(groups) do
    if i > 1 then
      widths[#widths + 1] = COUNSEL_GUTTER
      cells[#cells + 1] = ""
    end
    local ls = {}
    for _, l in ipairs(items(g)) do ls[#ls + 1] = p(xe.inl(l)) end
    widths[#widths + 1] = col
    cells[#cells + 1] = table.concat(ls)
  end
  return grid(widths, { cells })
end

local function court_heading(m, motion)
  local out = {}
  local before = BLOCK_GAP
  if motion and m.judge ~= nil then
    out[#out + 1] = p(xe.inl(m.judge), { jc = "right", before = BLOCK_GAP, after = JUDGE_BELOW })
  end
  out[#out + 1] = p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center", before = before })
  out[#out + 1] = p(xe.runs("EASTERN DISTRICT OF WASHINGTON", { b = true }), { jc = "center" })
  if not motion and m.division ~= nil then out[#out + 1] = p(xe.inl(m.division), { jc = "center" }) end
  return table.concat(out)
end

-- The caption (typst caption): the party column with its rules, a gutter, the case column.
local function caption(m, motion)
  local L = { p(xe.runs("In re:")) }
  local in_re = items(m.in_re)
  for i, n in ipairs(in_re) do
    L[#L + 1] = p(xe.inl(n), { left = (i == #in_re and i > 1) and DESIGNATION or 0 })
  end
  local parties = items(m.parties)
  for i, party in ipairs(parties) do
    if i > 1 then
      local joiner = (motion and party.joiner ~= nil) and xe.inl(party.joiner) or xe.runs("v.")
      L[#L + 1] = p(joiner, { left = VERSUS, before = BLOCK_GAP })
    end
    for j, n in ipairs(items(party.names)) do L[#L + 1] = p(xe.inl(n), { before = j == 1 and BLOCK_GAP or 0 }) end
    L[#L + 1] = p(xe.inl(party.designation), { left = DESIGNATION })
  end
  local R = {}
  if motion then
    for _, l in ipairs(items(m.case_no)) do R[#R + 1] = p(xe.inl(l)) end
  else
    R[#R + 1] = p(xe.inl(m.related_case))
    R[#R + 1] = p(xe.inl(m.adversary_no))
  end
  R[#R + 1] = p(xe.inl(m.title, { b = true }), { before = BLOCK_GAP })
  if m.jury_demand == true then R[#R + 1] = p(xe.runs("DEMAND FOR JURY TRIAL"), { before = BLOCK_GAP }) end
  local left_pr = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:right w:w="' .. (CAP_PAD - CAP_RULE) .. '" w:type="dxa"/><w:bottom w:w="' .. (CAP_FOOT - CAP_RULE)
    .. '" w:type="dxa"/></w:tcMar>'
  local right_pr = '<w:tcMar><w:left w:w="' .. CAP_CASE_PAD .. '" w:type="dxa"/></w:tcMar>'
  return space(BLOCK_GAP) .. grid({ CAP_LEFT, CAP_GUTTER, CAP_RIGHT },
    { { { table.concat(L), left_pr }, "", { table.concat(R), right_pr } } })
end

local function cover(m, motion)
  return counsel(m) .. court_heading(m, motion) .. caption(m, motion) .. space(COVER_BELOW)
end

-- ---------------------------------------------------------------------------
-- Signature block
-- ---------------------------------------------------------------------------

-- The complaint's (typst signature-block): single-spaced and kept on one page, the date at the margin and the firm
-- in the signature column on its first line (a tab and a hanging indent), a blank line, the /s/ signer and the names.
local function signature_complaint(m)
  local s = m.signature
  local out = {}
  local lines = items(s.lines)
  out[#out + 1] = p(xe.inl(s.date) .. xe.runs("\t") .. xe.inl(s.firm),
    { before = SIG_ABOVE, left = SIG_LEFT, hanging = SIG_LEFT, tab = SIG_LEFT, keep = true })
  out[#out + 1] = p(xe.runs("/s/ ") .. xe.inl(s.signer), { before = BLOCK_GAP, left = SIG_LEFT, keep = #lines > 0 })
  for i, l in ipairs(lines) do out[#out + 1] = p(xe.inl(l), { left = SIG_LEFT, keep = i < #lines }) end
  return table.concat(out)
end

-- The motion's (typst signature-block): the date on the body pitch, then each block in the signature column: the
-- firm, a blank line, "By /s/" and the signer's lines; blocks a blank single line apart; all kept on one page.
local function signature_motion(m)
  local s = m.signature
  local out = { p(xe.inl(s.date), { pitch = BODY, before = SIG_ABOVE, keep = true }) }
  local blocks = items(s.blocks)
  for k, b in ipairs(blocks) do
    local lines = items(b.lines)
    local last_block = k == #blocks
    out[#out + 1] = p(xe.inl(b.firm), { before = BLOCK_GAP, left = SIG_LEFT, keep = true })
    if b.signer ~= nil then
      out[#out + 1] = p(xe.runs("By /s/ ") .. xe.inl(b.signer),
        { before = BLOCK_GAP, left = SIG_LEFT, keep = not last_block or #lines > 0 })
    end
    for i, l in ipairs(lines) do
      out[#out + 1] = p(xe.inl(l), { left = SIG_LEFT, keep = not last_block or i < #lines })
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A pipe table (typst pipe-table): 0.5 pt rules, single-spaced, the text width; a column TABLE_CHAR per character of
-- its longest cell plus TABLE_SLACK, the last column the rest; the header row bold, rows not split.
local function pipe_table(b)
  local rows = {}
  for _, r in ipairs(b.head.rows) do rows[#rows + 1] = r end
  for _, body in ipairs(b.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = r end
  end
  local ncol = #b.colspecs
  local widths, used = {}, 0
  for j = 1, ncol - 1 do
    local need = 0
    for _, r in ipairs(rows) do
      local c = r.cells[j]
      local n = c and utf8.len(pandoc.utils.stringify(c.contents)) or 0
      if n > need then need = n end
    end
    widths[j] = (need + TABLE_SLACK) * TABLE_CHAR
    used = used + widths[j]
  end
  widths[ncol] = TW - used
  local trs = {}
  for i, r in ipairs(rows) do
    local cells = {}
    for j = 1, ncol do
      local c = r.cells[j]
      local inl = c and pandoc.Inlines(xe.inlines(pandoc.utils.blocks_to_inlines(c.contents))) or nil
      cells[j] = p(inl and xe.inl(inl, { b = i == 1 }) or "")
    end
    trs[#trs + 1] = cells
  end
  return grid(widths, trs, { rules = true, pad = TABLE_INSET, padb = TABLE_INSET - RULE })
end

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function styled(style, inlines)
  if has_note(inlines) then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- A typed label ("1.", "(a)") and a tab, then the text.
local function labelled(style, label, content)
  local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(label .. "\t")) })
  inl:extend(content)
  return styled(style, inl)
end

local function letters(n, upper)
  return string.char((upper and 64 or 96) + n)
end

local function body(blocks)
  local out = {}
  local n, sub = 0, 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      sub = 0
      local t = pandoc.utils.stringify(b.content)
      out[#out + 1] = xe.raw(p(xe.inl(b.content, { b = true }),
        { pitch = BODY, jc = "center", keep = true, brk = t:match("^EXHIBIT") ~= nil }))
    elseif b.t == "Header" then
      sub = sub + 1
      out[#out + 1] = xe.raw(p(xe.runs(letters(sub, true) .. ".\t", { b = true }) .. xe.inl(b.content, { b = true }),
        { pitch = BODY, left = INDENT, hanging = INDENT, tab = INDENT, keep = true }))
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      if c[1] and c[1].t == "Str" and c[1].text == "~" and c[2] and c[2].t == "Space" then
        local rest = pandoc.Inlines({})
        for k = 3, #c do rest:insert(c[k]) end
        out[#out + 1] = styled("Body Text Keep", rest)
      elseif #c == 1 and c[1].t == "Strong" then
        out[#out + 1] = xe.raw(p(xe.inl(c[1].content, { b = true }), { pitch = BODY, jc = "center", keep = true }))
      else
        n = n + 1
        out[#out + 1] = labelled("Numbered Paragraph", n .. ".", c)
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = labelled("Lettered", "(" .. letters(i) .. ")", pandoc.utils.blocks_to_inlines(item))
      end
    elseif b.t == "Table" then
      out[#out + 1] = xe.raw(pipe_table(b))
    else
      error("waeb.lua: unexpected block " .. b.t)
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("548(a)(1)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The footer (LBR 9004-1(a)(7); typst page footer): bottom left, the abbreviated name in capitals, a 1 em space, the
-- page number, in a single-pitch line box whose foot is FOOTER above the page edge; one section, letter, 1 in margins.
-- The 1 em space is a space (0.25 em) widened by 10.5 pt (typst h(1em)): an em space character comes out of
-- LibreOffice's PDF as the space of that font subset, so every space of a footnote would read as an em space.
local SPACE_1EM = '<w:r><w:rPr><w:spacing w:val="210"/></w:rPr><w:t xml:space="preserve"> </w:t></w:r>'
local function footer_and_section(m, motion)
  local title = txt(m.footer_title)
  if title == "" then title = motion and "MEMORANDUM" or "COMPLAINT" end
  local foot = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs(title:upper()) .. SPACE_1EM .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')
  write_file("FORMBOOK_FOOTERS", "rIdWaebFooter\t" .. foot .. "\n")
  write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdWaebFooter"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>')
end

local function finish(doc)
  local m = doc.meta
  local motion = m.case_no ~= nil
  local need = motion and { "in_re", "parties", "case_no", "title", "counsel", "signature" }
    or { "in_re", "parties", "related_case", "adversary_no", "title", "counsel", "signature" }
  for _, k in ipairs(need) do check(m[k] ~= nil, "missing required metadata field `" .. k .. "`") end

  -- a complaint: the body, the signature after the prayer, then the exhibits (from the first `# EXHIBIT`)
  local main, exhibits = pandoc.Blocks({}), pandoc.Blocks({})
  local target = main
  for _, b in ipairs(doc.blocks) do
    if not motion and b.t == "Header" and b.level == 1 and pandoc.utils.stringify(b.content):match("^EXHIBIT") then
      target = exhibits
    end
    target:insert(b)
  end
  local out = pandoc.Blocks({})
  out:extend(pandoc.Blocks(body(main)):walk({ Inlines = xe.inlines }))
  out:insert(xe.raw(motion and signature_motion(m) or signature_complaint(m)))
  out:extend(pandoc.Blocks(body(exhibits)):walk({ Inlines = xe.inlines }))
  -- the document ends in a paragraph of its own, 1 pt high (a last table would otherwise end it, which LibreOffice
  -- sets half a cell padding to the left)
  out:insert(xe.raw(space(20)))
  out:insert(1, xe.raw(cover(m, motion)))
  footer_and_section(m, motion)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
