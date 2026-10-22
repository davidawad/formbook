-- E.D. Va. Bankruptcy pleadings (vaeb), docx engine. Mirrors typst/vaeb-adversary-complaint.typ and
-- typst/vaeb-motion-brief.typ, which share this layout: the counsel block and the court title on page 1, the caption
-- (a borderless three-column table: party column, column of ")" marks, bankruptcy and adversary numbers), the title,
-- the body (paragraphs under the level 1 sections named in numbered_sections are numbered 1, 2, ... (Fed. R. Civ. P.
-- 10(b)); ordered lists are lettered (a), (b), ...; bullets stay bullets; a pipe table single-spaced with rules), the
-- signature block and the certificate of service. Numbers and letters are typed text, as the typst templates type
-- them. Every case word comes from the frontmatter. The same file is in docx/ of both doc types; `kind` selects the
-- checks and "Respectfully submitted," (a motion). Font, the body styles, the headings, margins and the page number
-- are in docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                           -- typst pitch-single
local TW = 9360                              -- typst text-width: 6.5 in
local INDENT = 720                           -- typst para-indent, party-indent, address-indent: 0.5 in
local CAP_LEFT, CAP_PAREN = 4896, 432        -- typst caption-left 3.4 in, caption-paren 0.3 in
local CAP_RIGHT = TW - CAP_LEFT - CAP_PAREN  -- 2.8 in
local CASE_PAD = 216                         -- typst case-pad 0.15 in
local VERSUS = 360                           -- typst versus-indent 0.25 in
local BLANK = 1872                           -- typst blank-width 1.3 in
local CASE_NO = 940                          -- "Case No. " at 12 pt Times (3.916 em), where the blank starts
local SIG_DATE = 4176                        -- typst sig-date 2.9 in
local SERVICE_COL, SERVICE_GUTTER = 4464, 432 -- typst service-col 3.1 in, service-gutter 0.3 in
local SERVICE_SIG = 4608                     -- typst service-sig 3.2 in
local BLOCK_GAP = 276                        -- typst block-gap 13.8 pt
local TITLE_BELOW = 240                      -- typst title-below 12 pt
local TABLE_SPACE = 240                      -- typst table-space 12 pt
local SIG_ABOVE = 480                        -- typst sig-above 24 pt
local SERVICE_ABOVE = 480                    -- typst service-above 24 pt
local LIST_ABOVE = 240                       -- typst list-above 12 pt
local SIG_GAP = 276                          -- typst sig-gap 13.8 pt
local TABLE_SLACK, TABLE_CHAR = 3, 120       -- typst table-slack, table-char 6 pt
local TABLE_INSET = 100                      -- typst table-inset 5 pt
local RULE = 10                             -- LibreOffice sets each 0.5 pt rule below a row (typst strokes take no room): the cell
                                             -- padding below is that much less, so a row is as tall as typst's

local function check(cond, msg)
  if not cond then error("vaeb docx: " .. msg, 0) end
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

-- A line of text: a string as runs, a metadata value as its inlines.
local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- A paragraph: o = { before, after, pitch, left, hanging, jc, keep, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and 0 or nil)
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

-- A table: widths (twips), rows of cells (each cell: paragraphs as a string); o = { indent, rules, pad }.
local function grid(widths, rows, o)
  o = o or {}
  local total, cols = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local pad = o.pad or 0
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="' .. (o.indent or 0)
    .. '" w:type="dxa"/>' .. (o.rules and RULES or NOBORDER) .. '<w:tblLayout w:type="fixed"/><w:tblCellMar>'
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
-- Page one: counsel, court, caption, title (LBR 5005-1(C)(5); FRBP 7010, Form 416)
-- ---------------------------------------------------------------------------

local function caption(m)
  local left = {
    p(xe.runs("In re:")),
    p(xe.inl(m.debtor.name) .. xe.runs(","), { left = INDENT }),
    p(xe.runs("Debtor."), { left = INDENT }),
    "",
  }
  local party_start = #left
  for k, party in ipairs(m.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { left = VERSUS }) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(line(n)) end
    left[#left + 1] = p(line(party.designation), { left = INDENT })
  end
  local adv_row = party_start + 1 -- 0-based index of the row that carries "Adversary Proceeding"
  local adv_number = txt(m.adversary_number)
  local rows = {}
  for i = 0, #left - 1 do
    local right = ""
    if i == 0 then
      right = p(xe.runs("Chapter " .. txt(m.debtor.chapter)), { left = CASE_PAD })
    elseif i == 1 then
      right = p(xe.runs("Case No. " .. txt(m.debtor.case_number)), { left = CASE_PAD })
    elseif i == adv_row then
      right = p(xe.runs("Adversary Proceeding"), { left = CASE_PAD })
    elseif i == adv_row + 1 then
      if adv_number ~= "" then
        right = p(xe.runs("Case No. " .. adv_number), { left = CASE_PAD })
      else
        -- the blank: an underlined tab to a stop 1.3 in after "Case No. " (typst: a ruled box)
        right = p(xe.runs("Case No. ") .. xe.runs("\t", { u = true }), { left = CASE_PAD, tab = CASE_PAD + CASE_NO + BLANK })
      end
    end
    rows[#rows + 1] = { left[i + 1], p(xe.runs(")")), right }
  end
  return grid({ CAP_LEFT, CAP_PAREN, CAP_RIGHT }, rows)
end

local function cover(m)
  local out = {}
  for _, c in ipairs(items(m.counsel)) do out[#out + 1] = p(line(c)) end
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center", before = BLOCK_GAP })
  out[#out + 1] = p(xe.runs("FOR THE EASTERN DISTRICT OF VIRGINIA", { b = true }), { jc = "center" })
  out[#out + 1] = p(line(m.division), { jc = "center" })
  out[#out + 1] = space(BLOCK_GAP)
  out[#out + 1] = caption(m)
  out[#out + 1] = p(xe.runs(txt(m.title):upper(), { b = true }), { jc = "center", before = BLOCK_GAP, after = TITLE_BELOW })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service
-- ---------------------------------------------------------------------------

-- The signature block (typst signature-block): single-spaced from SIG_DATE, the date at the left of its first line
-- (a tab), kept on one page, after a space of its own.
local function signature(m)
  local sig = m.signature
  local firm = items(sig.firm)
  local lines = {} -- { xml, space before }
  if txt(m.kind) == "motion-brief" then lines[#lines + 1] = { xe.runs("Respectfully submitted,"), 0 } end
  local gap = #lines > 0 and SIG_GAP or 0
  for _, f in ipairs(firm) do
    lines[#lines + 1] = { line(f), gap }
    gap = 0
  end
  lines[#lines + 1] = { xe.runs((#firm > 0 and "By: /s/ " or "/s/ ") .. txt(sig.signer)), gap }
  for _, l in ipairs(items(sig.lines)) do lines[#lines + 1] = { line(l), 0 } end
  local date = m.date ~= nil and ("Date: " .. txt(m.date)) or ""
  local out = { space(SIG_ABOVE) }
  for i, l in ipairs(lines) do
    local keep = i < #lines
    if i == 1 then
      out[#out + 1] = p(xe.runs(date .. "\t") .. l[1], { before = l[2], left = SIG_DATE, hanging = SIG_DATE,
        tab = SIG_DATE, keep = keep })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG_DATE, keep = keep })
    end
  end
  return table.concat(out)
end

-- Certificate of service (typst service-block): the heading on the body pitch, the form paragraph, the service list
-- in two columns (each address single-spaced, half an inch in; a blank single line between rows), the signature.
local function service(m)
  local s = m.service
  if s == nil then return {} end
  local mailed = items(s.mailed)
  local out = {
    xe.raw(p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", pitch = 480, before = SERVICE_ABOVE, keep = true })),
    pandoc.Div({ pandoc.Para({ pandoc.Str("I hereby certify that on the " .. txt(s.date)
      .. ", I caused a copy of the foregoing to be served by electronic means through the ECF system"
      .. (#mailed > 0 and " and a copy mailed to the following:" or ".")) }) }, { ["custom-style"] = "Body Text" }),
  }
  local xml = {}
  if #mailed > 0 then
    local rows, last = {}, math.ceil(#mailed / 2)
    for i = 1, #mailed, 2 do
      local row = (i + 1) / 2
      local cells = {}
      for _, j in ipairs({ i, i + 1 }) do
        local addr = mailed[j] and items(mailed[j]) or {}
        local ls = {}
        for k, a in ipairs(addr) do
          ls[#ls + 1] = p(line(a), { left = INDENT, after = (k == #addr and row < last) and SIG_GAP or 0 })
        end
        cells[#cells + 1] = table.concat(ls)
      end
      rows[#rows + 1] = { cells[1], "", cells[2] }
    end
    xml[#xml + 1] = space(LIST_ABOVE) .. grid({ SERVICE_COL, SERVICE_GUTTER, SERVICE_COL }, rows)
  end
  local signer = txt(s.signer)
  xml[#xml + 1] = p(xe.runs("/s/ " .. signer), { left = TW - SERVICE_SIG, before = SIG_ABOVE, keep = true })
  xml[#xml + 1] = p(xe.runs(signer), { left = TW - SERVICE_SIG })
  out[#out + 1] = xe.raw(table.concat(xml))
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- The pipe table (typst pipe-table): 0.5 pt rules, single-spaced, the text width less the indent, indented by it; a
-- column TABLE_CHAR per character of its longest cell plus TABLE_SLACK, the last column the rest; kept on one page.
local function pipe_table(b)
  local rows = {}
  for _, r in ipairs(b.head.rows) do rows[#rows + 1] = r end
  for _, body in ipairs(b.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = r end
  end
  local ncol = #b.colspecs
  local width = TW - INDENT
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
  widths[ncol] = width - used
  local trs = {}
  for i, r in ipairs(rows) do
    local cells = {}
    for j = 1, ncol do
      local c = r.cells[j]
      cells[j] = p(c and xe.inl(pandoc.utils.blocks_to_inlines(c.contents)) or "", { keep = i < #rows })
    end
    trs[#trs + 1] = cells
  end
  return space(TABLE_SPACE) .. grid(widths, trs, { indent = INDENT, rules = true, pad = TABLE_INSET, padb = TABLE_INSET - RULE }) .. space(TABLE_SPACE)
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- A typed label ("1.", "(a)") and a tab, then the text.
local function labelled(style, label, content)
  local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(label .. "\t")) })
  inl:extend(content)
  return styled(style, inl)
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

local function body(blocks, numbered)
  local out = {}
  local in_numbered, n = false, 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      if b.level == 1 then
        in_numbered = numbered[string.upper(pandoc.utils.stringify(b.content))] == true
        out[#out + 1] = pandoc.Header(level, upper(b.content))
      else
        out[#out + 1] = pandoc.Header(level, b.content)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if in_numbered then
        n = n + 1
        out[#out + 1] = labelled("Numbered Paragraph", n .. ".", b.content)
      else
        out[#out + 1] = styled("Body Text", b.content)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and ("(" .. string.char(96 + i) .. ")") or "\u{2022}"
        out[#out + 1] = labelled("Lettered", label, pandoc.utils.blocks_to_inlines(item))
      end
    elseif b.t == "Table" then
      out[#out + 1] = xe.raw(pipe_table(b))
    else
      error("vaeb.lua: unexpected block " .. b.t)
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
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

local function all_text(blocks)
  local t = {}
  for _, b in ipairs(blocks) do t[#t + 1] = pandoc.utils.stringify(b) end
  return table.concat(t, "\n")
end

local function finish(doc)
  local m = doc.meta
  local kind = txt(m.kind)
  check(kind == "adversary-complaint" or kind == "motion-brief", "frontmatter kind must be adversary-complaint or motion-brief")
  check(m.counsel ~= nil and #items(m.counsel) > 0, "LBR 5005-1(C)(5): counsel, State Bar number and address are required on page 1")
  check(m.division ~= nil, "FRBP 7010 (Form 416): the division of the court is required in the caption")
  check(m.debtor ~= nil and m.debtor.name ~= nil and m.debtor.chapter ~= nil and m.debtor.case_number ~= nil,
    "LBR 5005-1(C)(2): the debtor's name, chapter and case number must appear on the document")
  check(m.parties ~= nil and #m.parties > 0, "FRCP 10(a): the caption must name the parties")
  check(m.title ~= nil, "FRCP 10(a): the title of the paper is required")
  local text = all_text(doc.blocks)
  local upper_text = string.upper(text)
  if kind == "adversary-complaint" then
    check(upper_text:find("JURISDICTION AND VENUE", 1, true), "FRBP 7008(a): a jurisdiction statement is required")
    check(text:lower():find("core", 1, true), "FRBP 7008(a): the complaint must say whether the proceeding is core or non-core")
    check(upper_text:find("PRAYER FOR RELIEF", 1, true), "FRBP 7008(a): the complaint must demand the relief sought")
  else
    check(upper_text:find("WHEREFORE", 1, true), "LBR 9013-1(C): the motion must state the relief sought")
    if m.summary_judgment == true then
      check(upper_text:find("STATEMENT OF UNDISPUTED MATERIAL FACTS", 1, true),
        "LBR 7056-1(C): a summary judgment memorandum must include a Statement of Undisputed Material Facts")
      check(m.numbered_sections ~= nil and #m.numbered_sections > 0,
        "LBR 7056-1(C): the Statement of Undisputed Material Facts must be in numbered paragraphs")
    end
  end

  local numbered = {}
  for _, s in ipairs(items(m.numbered_sections)) do numbered[string.upper(txt(s))] = true end
  local out = pandoc.Blocks(body(doc.blocks, numbered))
  local tail = pandoc.Blocks({ xe.raw(signature(m)) })
  tail:extend(service(m))
  out:extend(tail)
  out = out:walk({ Inlines = xe.inlines })
  out:insert(1, xe.raw(cover(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
