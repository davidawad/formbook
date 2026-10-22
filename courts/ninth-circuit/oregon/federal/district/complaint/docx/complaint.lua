-- D. Or. complaint, docx engine. Mirrors typst/ord-complaint.typ: the counsel block upper left (LR 10-2(a)), the
-- court title one inch below it, capitalized, centered and double-spaced (LR 10-2(b)), the caption (a borderless
-- table: the parties single-spaced at the left margin, LR 10-2(d); from the page center the case number on the first
-- plaintiff's line and the title in capitals, single-spaced, LR 10-2(f)-(g); the jury demand), the lead-in, the body
-- (paragraphs numbered 1, 2, ... (Fed. R. Civ. P. 10(b)); "-" lists lettered (a), (b), ...; block quotations
-- single-spaced and indented on both sides (LR 10-1(b)); a pipe table single-spaced with rules), and the signature
-- block, kept on one page with the last paragraph. Numbers and letters are typed text, as the typst template types
-- them. Every case word comes from the frontmatter. The footer (LR 10-1(e)(1): the sample's footer_title in capitals,
-- " - " and the page number, 12 pt) and the last section are written for fb render ($FORMBOOK_FOOTERS,
-- $FORMBOOK_FINAL); font, body styles, headings and margins are in docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local TW = 9360                               -- typst text-width: 6.5 in
local INDENT = 720                            -- typst para-indent, list-indent, quote-inset: 0.5 in
local CAP_SPLIT, CAP_GAP = 4680, 432          -- typst caption-split 3.25 in, caption-gap 0.3 in
local SIG_COL = 4464                          -- typst sig-col 3.1 in
local COUNSEL_BELOW = 1440                    -- typst counsel-below 1 in
local CAPTION_ABOVE = 240                     -- typst caption-above 12 pt
local TITLE_ABOVE, DEMAND_ABOVE = 480, 240    -- typst title-above 24 pt, demand-above 12 pt
local TEXT_ABOVE = 480                        -- typst text-above 24 pt
local QUOTE_GAP = 240                         -- typst quote-gap 12 pt
local TABLE_SPACE = 240                       -- typst table-space 12 pt
local SIG_ABOVE, SIG_BY_GAP = 480, 240        -- typst sig-above 24 pt, sig-by-gap 12 pt
local TABLE_SLACK, TABLE_CHAR = 3, 120        -- typst table-slack, table-char 6 pt
local TABLE_INSET = 100                       -- typst table-inset 5 pt
local RULE = 10                               -- LibreOffice sets each 0.5 pt rule below a row (typst strokes take no
                                              -- room): the cell padding below is that much less
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("ord complaint docx: " .. msg, 0) end
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

local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- A paragraph: o = { before, after, pitch, left, right, hanging, first, jc, keep, tab, style }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  if not o.style or o.left or o.hanging or o.first then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  end
  if not o.style or o.jc then props[#props + 1] = xe.jc(o.jc or "left") end
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

-- A table: widths (twips), rows of cells (each cell: paragraphs as a string); o = { indent, rules, pad, padb }.
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
-- Footer and section (LR 10-1(d), (e)(1))
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function footer(title)
  return xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs(title:upper() .. " - ") .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    .. '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdOrdFooter"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
  .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Page one: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  for _, c in ipairs(items(m.counsel)) do out[#out + 1] = p(txt(c) == "" and "" or line(c)) end
  local court = {}
  for _, l in ipairs(items(m.court)) do court[#court + 1] = txt(l):upper() end
  if m.division then court[#court + 1] = txt(m.division):upper() end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", pitch = BODY, before = i == 1 and COUNSEL_BELOW or 0 })
  end
  local left = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("vs.")) end
    for _, n in ipairs(items(party.names)) do left[#left + 1] = p(line(n)) end
    left[#left + 1] = p(line(party.designation))
  end
  local number = txt(m.case_number)
  if number == "" then number = "________________" end
  local right = { p(xe.runs("Case No. " .. number)) }
  right[#right + 1] = p(xe.runs(txt(m.brief_title):upper(), { b = true }), { before = TITLE_ABOVE })
  if m.jury_demand then
    right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = DEMAND_ABOVE })
  end
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = grid({ CAP_SPLIT - CAP_GAP, CAP_GAP, TW - CAP_SPLIT }, { { table.concat(left), "", table.concat(right) } })
  out[#out + 1] = space(TEXT_ABOVE)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body and signature
-- ---------------------------------------------------------------------------

-- The pipe table (typst pipe-table): 0.5 pt rules, single-spaced, half an inch in; a column TABLE_CHAR per character
-- of its longest cell plus TABLE_SLACK; kept on one page.
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
  return space(TABLE_SPACE) .. grid(widths, trs, { indent = INDENT, rules = true, pad = TABLE_INSET, padb = TABLE_INSET - RULE })
    .. space(TABLE_SPACE)
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

local function letter(i)
  return "(" .. string.char(96 + i) .. ")"
end

-- The body as raw paragraphs; the last one (a paragraph or a list's last item) is kept with the signature.
local function body(blocks)
  local out = {}
  local n = 0
  local last
  for _, b in ipairs(blocks) do
    last = nil
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      out[#out + 1] = xe.raw(p(xe.inl(level == 1 and upper(b.content) or b.content),
        { style = "Heading" .. level, keep = true, pitch = BODY }))
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      local label = n .. ".\t"
      local content = b.content
      last = function(keep)
        return p(xe.runs(label) .. xe.inl(content), { style = "NumberedParagraph", keep = keep, pitch = BODY })
      end
      out[#out + 1] = last
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local content = pandoc.utils.blocks_to_inlines(item)
        last = function(keep)
          return p(xe.runs(letter(i) .. "\t") .. xe.inl(content), { style = "Lettered", keep = keep, pitch = BODY })
        end
        out[#out + 1] = last
      end
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = xe.raw(p(xe.inl(q.content), { before = QUOTE_GAP, after = QUOTE_GAP, left = INDENT, right = INDENT }))
      end
    elseif b.t == "Table" then
      out[#out + 1] = xe.raw(pipe_table(b))
    else
      error("complaint.lua: unexpected block " .. b.t)
    end
  end
  for i, x in ipairs(out) do
    if type(x) == "function" then out[i] = xe.raw(x(i == #out)) end
  end
  return out
end

-- The signature block (typst signature-block): single-spaced from SIG_COL, "DATED:" and the date at the left of its
-- first line (a tab), kept on one page, a space of its own above.
local function signature(m)
  local sig = m.signature
  local lines = {}
  for _, f in ipairs(items(sig.firm)) do lines[#lines + 1] = { line(f), 0 } end
  lines[#lines + 1] = { xe.runs("By: /s/ " .. txt(sig.signer)), SIG_BY_GAP }
  for _, l in ipairs(items(sig.lines)) do lines[#lines + 1] = { line(l), 0 } end
  local out = {}
  for i, l in ipairs(lines) do
    local before = i == 1 and SIG_ABOVE or l[2]
    local keep = i < #lines
    if i == 1 then
      out[#out + 1] = p(xe.runs("DATED: " .. txt(m.date) .. "\t") .. l[1], { before = before, left = SIG_COL,
        hanging = SIG_COL, tab = SIG_COL, keep = keep })
    else
      out[#out + 1] = p(l[1], { before = before, left = SIG_COL, keep = keep })
    end
  end
  return table.concat(out)
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("227(c)(5)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B) after it. Neither shows in
-- the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("¶¶ 8-9"; the typst template boxes them): no-break spaces.
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
  check(m.counsel ~= nil and #items(m.counsel) > 0, "LR 10-2(a): counsel information is required on page 1")
  check(m.court ~= nil, "Fed. R. Civ. P. 10(a): the court's name is required")
  check(m.caption ~= nil and m.caption.parties ~= nil, "LR 10-2(d): the caption must name the parties")
  check(m.brief_title ~= nil, "LR 10-2(g): the title of the paper is required")
  check(txt(m.footer_title) ~= "", "LR 10-1(e)(1): the sample has no footer_title")
  write_file("FORMBOOK_FOOTERS", "rIdOrdFooter\t" .. footer(txt(m.footer_title)) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = pandoc.Blocks({ xe.raw(cover(m)) })
  if m.lead_in then out:insert(xe.raw(p(xe.inl(m.lead_in), { style = "BodyText", pitch = BODY }))) end
  out:extend(body(doc.blocks))
  out:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
