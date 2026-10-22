-- iasb adversary complaint, docx engine. Mirrors typst/iasb-adversary-complaint.typ; rules and conventions are in
-- ../README.md (Engines). The cover (court name, caption table, title), the two paragraphs the template generates for
-- Fed. R. Bankr. P. 7008, the numbered allegations, the lettered prayer and the signature block are built here. Font,
-- spacing, margins and the page number are styles and section settings in docx/reference.xml (fb render builds the
-- reference document from it). Numbers are typed text, as the typst template types them, so every viewer shows the
-- same numbering. Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 280                       -- typst pitch-single
local TEXTW = 9360                       -- typst text-width, 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360   -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_PAD, CASE_PAD = 200, 144       -- typst caption-pad 10 pt, case-pad 0.1 in
local GROUP_GAP = 120                    -- typst group-gap 6 pt
local COURT_BELOW, CAPTION_BELOW, TITLE_BELOW = 480, 480, 360 -- typst court-below, caption-below 24 pt, title-below 18 pt
local SIG_LEFT, SIG_GUTTER = 4032, 288   -- typst sig-left 2.8 in, sig-gutter 0.2 in
local SIG_ABOVE = 480                    -- typst signature-above 24 pt
local TABLE_SPACE = 120                  -- typst table-space 6 pt

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
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

-- A single-spaced paragraph: o = { before, after, line, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- A one-row table with fixed column widths (twips), no borders and no cell margins unless a cell sets its own; the
-- row is not split across pages (typst: one grid row).
local function table_xml(widths, cells)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- Single-spaced lines (typst line-stack): an empty item is a blank line, the next line a line lower.
local function stack(lines)
  local out, gap = {}, 0
  for _, l in ipairs(lines) do
    if l == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(type(l) == "string" and xe.runs(l) or xe.inl(l), { before = gap })
      gap = 0
    end
  end
  return table.concat(out)
end

-- The pipe table (typst pipe-table): ruled, single-spaced, half an inch in and the rest of the text wide; a column's
-- width in proportion to its longest cell (characters) plus TABLE_SLACK, rounded to the twip, the last column the
-- rest; cells 5.4 pt in at the sides (typst table-inset); kept on one page (typst: breakable: false).
local TABLE_W, TABLE_IND, TABLE_SLACK, TABLE_INSET = 8640, 720, 4, 108
local TRULE = '<w:%s w:val="single" w:sz="4" w:space="0" w:color="000000"/>'

local function pipe_table(b)
  local rows = {}
  for _, r in ipairs(b.head.rows) do rows[#rows + 1] = r end
  for _, body in ipairs(b.bodies) do
    for _, r in ipairs(body.body) do rows[#rows + 1] = r end
  end
  local ncol = #b.colspecs
  local need = {}
  for j = 1, ncol do need[j] = TABLE_SLACK end
  for _, r in ipairs(rows) do
    for j, c in ipairs(r.cells) do
      local n = utf8.len(pandoc.utils.stringify(c.contents)) + TABLE_SLACK
      if n > need[j] then need[j] = n end
    end
  end
  local total = 0
  for _, n in ipairs(need) do total = total + n end
  local widths, used = {}, 0
  for j = 1, ncol - 1 do
    widths[j] = math.floor(TABLE_W * need[j] / total + 0.5)
    used = used + widths[j]
  end
  widths[ncol] = TABLE_W - used
  local borders = {}
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    borders[#borders + 1] = string.format(TRULE, side)
  end
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for i, r in ipairs(rows) do
    local tcs = {}
    for j, c in ipairs(r.cells) do
      local inl = pandoc.utils.blocks_to_inlines(c.contents)
      tcs[#tcs + 1] = cell(widths[j], p(xe.inl(inl), { keep = i < #rows }))
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TABLE_W .. '" w:type="dxa"/><w:tblInd w:w="' .. TABLE_IND .. '" w:type="dxa"/>'
    .. '<w:tblBorders>' .. table.concat(borders) .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="' .. TABLE_INSET .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="' .. TABLE_INSET .. '" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption (Form 416D), title
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(m)
  local out = {
    p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }),
    p(xe.runs("SOUTHERN DISTRICT OF IOWA", { b = true }), { jc = "center" }),
  }

  -- Left column: the debtor, the plaintiffs, "v.", the defendants; a group is set off by typst group-gap.
  local groups = {}
  local debtors = items(m.debtors)
  local g = { "In re:" }
  for _, d in ipairs(debtors) do g[#g + 1] = d end
  g[#g + 1] = #debtors > 1 and "Debtors." or "Debtor."
  groups[#groups + 1] = g
  for _, pl in ipairs(m.caption.plaintiffs) do
    local grp = items(pl.names)
    grp[#grp + 1] = pl.designation
    groups[#groups + 1] = grp
  end
  groups[#groups + 1] = { "v." }
  for _, df in ipairs(m.caption.defendants) do
    local grp = items(df.names)
    grp[#grp + 1] = df.designation
    groups[#groups + 1] = grp
  end
  local left = {}
  for gi, grp in ipairs(groups) do
    for li, line in ipairs(grp) do
      local body = type(line) == "string" and xe.runs(line) or xe.inl(line)
      left[#left + 1] = p(body, { before = (li == 1 and gi > 1) and GROUP_GAP or 0 })
    end
  end

  -- Right column: the case number, the chapter and the adversary number (blank until the clerk assigns it).
  local adv = txt(m.adv_number)
  if adv == "" then adv = "______________" end
  local right = stack({ "Case No. " .. txt(m.case_number), "Chapter " .. txt(m.chapter), "Adv. Proc. No. " .. adv })

  local borders = '<w:tcBorders>' .. string.format(RULE, "bottom") .. string.format(RULE, "right") .. '</w:tcBorders>'
  local mar = '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = space(COURT_BELOW)
  out[#out + 1] = table_xml({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    cell(CAP_LEFT, table.concat(left), borders .. mar),
    cell(CAP_GUTTER, p("")),
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, right,
      '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>'),
  })
  out[#out + 1] = p(xe.inl(m.brief_title, { b = true }), { jc = "center", before = CAPTION_BELOW, after = TITLE_BELOW })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: the date on the left; the firm, the electronic signature and counsel lines on the right (FRBP 9011)
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local right = { "Respectfully submitted,", "" }
  if s.firm then
    for _, f in ipairs(items(s.firm)) do right[#right + 1] = f end
    right[#right + 1] = ""
  end
  right[#right + 1] = "By: /s/ " .. txt(s.signer)
  right[#right + 1] = s.signer
  for _, l in ipairs(items(s.lines)) do right[#right + 1] = l end
  return {
    space(SIG_ABOVE),
    table_xml({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER }, {
      cell(SIG_LEFT, p(xe.runs("Dated: ") .. xe.inl(m.date))),
      cell(SIG_GUTTER, p("")),
      cell(TEXTW - SIG_LEFT - SIG_GUTTER, stack(right)),
    }),
  }
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(I)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("botox/fillers"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there even after a word joiner): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- A numbered paragraph: the number, a tab to the text (typst number-box), and the text (Fed. R. Civ. P. 10(b)).
local function numbered(n, content)
  local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
  inl:extend(content)
  return styled("Numbered Paragraph", inl)
end

-- Inline markdown of a string the filter writes, with the break rules of the body.
local function md(s)
  local d = pandoc.read(s, "markdown+smart"):walk({ Str = break_rules })
  if d.blocks[1] then return d.blocks[1].content end
  return pandoc.Inlines({})
end

local function finish(doc)
  local m = doc.meta
  if not m.division then error("iasb-adversary-complaint: frontmatter needs division (FRBP 7008)") end
  if not m.final_orders_consent then error("iasb-adversary-complaint: frontmatter needs final_orders_consent (FRBP 7008)") end

  local raw = {}
  for _, x in ipairs(cover(m)) do raw[#raw + 1] = x end
  local out = { xe.raw(table.concat(raw)) }
  if m.lead_in then out[#out + 1] = styled("Body Text", pandoc.Inlines(m.lead_in)) end

  -- The first two numbered paragraphs come from the frontmatter (FRBP 7008): the case reference and the consent.
  local n = 0
  local names = {}
  for _, d in ipairs(items(m.debtors)) do names[#names + 1] = txt(d) end
  local case_ref = "This adversary proceeding arises in and relates to the Chapter " .. txt(m.chapter) .. " case of "
    .. table.concat(names, ", ") .. ", Case No. " .. txt(m.case_number)
    .. ", pending in the United States Bankruptcy Court for the Southern District of Iowa, " .. txt(m.division) .. " Division."
  n = n + 1
  out[#out + 1] = numbered(n, md(case_ref))
  n = n + 1
  out[#out + 1] = numbered(n, pandoc.Inlines(m.final_orders_consent))

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- Level 1 in capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
      local c = b.content
      if b.level == 1 then
        c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):sub(1, 9) == "WHEREFORE" then
        -- The prayer's lead-in is not numbered.
        out[#out + 1] = styled("Body Text", b.content)
      else
        n = n + 1
        out[#out + 1] = numbered(n, b.content)
      end
    elseif b.t == "BulletList" then
      -- The prayer items are lettered A., B., C. (the letter is typed text, as in the typst template).
      for i, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(string.char(64 + i) .. ".\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Prayer Item", inl)
      end
    elseif b.t == "Table" then
      -- The table, with typst table-space above and below it.
      out[#out + 1] = xe.raw(space(TABLE_SPACE) .. pipe_table(b) .. space(TABLE_SPACE))
    else
      -- The block quotation (Block Text) is kept as pandoc writes it.
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(table.concat(signature(m))))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
