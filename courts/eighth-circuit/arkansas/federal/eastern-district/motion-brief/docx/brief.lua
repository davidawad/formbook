-- brief.lua (docx engine): the Word output of the typst template (../typst/ared-motion-brief.typ). Pandoc passes
-- the YAML frontmatter as the document metadata; this filter writes the whole document as WordprocessingML:
--   * cover: court title (two lines, plus the division), the caption, the centered bold title of the paper;
--   * headings: level 1 numbered I., II., ... in capitals (a leading <!--unnumbered--> makes it unnumbered:
--     INTRODUCTION, CONCLUSION); level 2 lettered A., B., ...; level 3 numbered 1., 2., ...; a level 2 or 3 number
--     is followed by a tab to the half-inch hanging indent;
--   * body paragraphs (not numbered: a brief's paragraphs are not numbered by the rules); lists "(1)", "(2)", ...;
--     pipe tables (equal columns, 11 pt, ruled, header bold, kept on one page); block quotations;
--   * the signature block.
-- Not built: a table of contents or authorities (none in the exemplar; see ../README.md). Nothing here is
-- case-specific: every name and number comes from the sample's frontmatter. Styles live in reference.xml (fb render
-- builds reference.docx from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line, 253 a table line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY = 480                          -- typst pitch (LR 5.5(a): double space)
local SINGLE = 276                        -- typst pitch-single
local TABLE_LINE, TABLE_SIZE = 253, 22    -- typst pitch-table 12.65 pt, table-size 11 pt
local TEXTW = 9360                        -- typst text-width, 6.5 in
local CAP_LEFT, CAP_GUTTER = 4608, 288    -- typst caption-left 3.2 in, caption-gutter 0.2 in
local CAP_RIGHT = TEXTW - CAP_LEFT - CAP_GUTTER
local CAP_INSET, CAP_PAD = 200, 160       -- typst caption-inset: right 10 pt, bottom 8 pt
local CAP_RULE = 15                       -- the 0.75 pt rule: LibreOffice adds it to the cell's height, typst does not
local CASE_PAD = 144                      -- typst case-pad 0.1 in
local SIG_LEFT = 3744                     -- typst sig-left 2.6 in
local SIG_GAP = 240                       -- typst sig-gap 12 pt
local GAP = 240                           -- typst block-gap 12 pt
local QUOTE = 1440                        -- typst quote-indent 1 in
local CELL_X, CELL_Y = 72, 36             -- typst cell-inset 3.6 pt, 1.8 pt
local RULE_W = 10                         -- typst rule 0.5 pt: LibreOffice adds it to a row's height, typst does not

local stringify = pandoc.utils.stringify

local function str(v)
  return v and stringify(v) or ""
end

-- A paragraph: o = { style, before, after, line, left, right, hanging, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Several single-spaced lines, one paragraph each; an empty item leaves one blank line before the next (typst lines).
local function lines(items, before)
  local out = {}
  local gap = before or 0
  for _, l in ipairs(items) do
    if str(l) == "" then
      gap = math.max(gap, SINGLE)
    else
      out[#out + 1] = p(xe.inl(l), { before = gap })
      gap = 0
    end
  end
  return out
end

local function cell(width, tcpr, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. tcpr .. "</w:tcPr>" .. table.concat(paras)
    .. "</w:tc>"
end

-- A table of fixed columns; `rows` is a list of lists of cells; `borders` the table borders, `mar` its cell margins
-- { left and right, bottom, top }.
local function tbl(widths, rows, borders, mar)
  local cols = {}
  local total = 0
  for _, w in ipairs(widths) do
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  local tr = {}
  for _, cells in ipairs(rows) do
    tr[#tr + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(cells) .. "</w:tr>"
  end
  mar = mar or { 0, 0, 0 }
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. (borders or "")
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="' .. (mar[3] or mar[2]) .. '" w:type="dxa"/><w:left w:w="' .. mar[1] .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. mar[2] .. '" w:type="dxa"/><w:right w:w="' .. mar[1] .. '" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. "</w:tblPr><w:tblGrid>" .. table.concat(cols) .. "</w:tblGrid>" .. table.concat(tr) .. "</w:tbl>"
end

local RULE = '<w:%s w:val="single" w:sz="%d" w:space="0" w:color="000000"/>'

-- The court title, at the body pitch.
local function court_title(meta)
  local rows = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF ARKANSAS" }
  if meta.division then rows[#rows + 1] = pandoc.text.upper(str(meta.division)) end
  local out = {}
  for _, r in ipairs(rows) do out[#out + 1] = p(xe.runs(r), { line = BODY, jc = "center" }) end
  return out
end

-- The caption: each party's names and designation at left, "v." between them a line above and below; the case
-- number at right. A blank double-spaced line before it (typst: block(above: pitch)).
local function caption(meta)
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { before = SINGLE, after = SINGLE }) end
    local items = {}
    for _, n in ipairs(party.names) do items[#items + 1] = n end
    items[#items + 1] = party.designation
    for _, x in ipairs(lines(items)) do left[#left + 1] = x end
  end
  local right = { p(xe.runs("Case No. " .. str(meta.case_number))) }
  return tbl({ CAP_LEFT, CAP_GUTTER, CAP_RIGHT }, { {
    cell(CAP_LEFT, "<w:tcBorders>" .. string.format(RULE, "bottom", 6) .. string.format(RULE, "right", 6)
      .. '</w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/><w:bottom w:w="' .. (CAP_PAD - CAP_RULE)
      .. '" w:type="dxa"/></w:tcMar>', left),
    cell(CAP_GUTTER, "", { p("") }),
    cell(CAP_RIGHT, '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>', right),
  } })
end

-- The signature block: "Dated:" (when the sample gives a date) at left; "Respectfully submitted,", the firm, the
-- "/s/" line and the signer, then the lines at right. One row that does not split.
local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,")) }
  for _, x in ipairs(lines(sig.firm or {}, SIG_GAP)) do right[#right + 1] = x end
  local signer = { "/s/ " .. str(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do signer[#signer + 1] = l end
  for _, x in ipairs(lines(signer, SIG_GAP)) do right[#right + 1] = x end
  local left = { p(meta.date and (xe.runs("Dated: ") .. xe.inl(meta.date)) or "") }
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { cell(SIG_LEFT, "", left), cell(TEXTW - SIG_LEFT, "", right) } })
end

-- The inlines of a list of blocks (a cell, a list item): the first Para or Plain.
local function inlines_of(blocks)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then return b.content end
  end
  return pandoc.Inlines({})
end

-- A pipe table (typst pipe-table): equal columns, ruled, single-spaced at 11 pt, the header row bold; kept on one
-- page (every row keeps with the next; rows do not split).
local function pipe_table(el)
  local s = pandoc.utils.to_simple_table(el)
  local n = #s.headers
  local w = math.floor(TEXTW / n)
  local widths = {}
  for i = 1, n do widths[i] = i < n and w or TEXTW - w * (n - 1) end
  local all = { s.headers }
  for _, r in ipairs(s.rows) do all[#all + 1] = r end
  local rows = {}
  for ri, r in ipairs(all) do
    local cells = {}
    for ci, c in ipairs(r) do
      cells[#cells + 1] = cell(widths[ci], "", { p(xe.inl(inlines_of(c), { b = ri == 1, sz = TABLE_SIZE }),
        { style = "TableText", line = TABLE_LINE, keep = ri < #all }) })
    end
    rows[#rows + 1] = cells
  end
  local b = "<w:tblBorders>"
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    b = b .. string.format(RULE, side, 4)
  end
  return tbl(widths, rows, b .. "</w:tblBorders>", { CELL_X, CELL_Y, CELL_Y - RULE_W })
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- Headings: the numbers (I., A., 1.) are written here, not by the author.
local h1, h2, h3 = 0, 0, 0

local function heading(el)
  if el.level > 3 then error("brief.lua: headings deeper than level 3 are not supported") end
  local content = pandoc.Inlines({})
  local unnumbered = false
  for _, x in ipairs(el.content) do
    if x.t == "RawInline" and x.text:match("^<!%-%-%s*unnumbered%s*%-%->$") then
      unnumbered = true
    elseif not (#content == 0 and x.t == "Space") then
      content:insert(x)
    end
  end
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    local lab = ""
    if not unnumbered then
      h1 = h1 + 1
      h2, h3 = 0, 0
      lab = roman(h1) .. ". "
    end
    return xe.para({ xe.style("Heading1"), xe.spacing(0, 0, BODY) },
      xe.runs(lab, { b = true }) .. xe.inl(content, { b = true }))
  elseif el.level == 2 then
    h2 = h2 + 1
    h3 = 0
    return xe.para({ xe.style("Heading2"), xe.spacing(0, 0, BODY) },
      xe.runs(string.char(64 + h2) .. ".\t", { b = true })
      .. xe.inl(content, { b = true }))
  end
  h3 = h3 + 1
  return xe.para({ xe.style("Heading3"), xe.spacing(0, 0, BODY) },
    xe.runs(h3 .. ".\t") .. xe.inl(content, { b = true, i = true }))
end

-- The body, block by block; the last block keeps with the signature (typst: sticky).
local function body(blocks)
  local out = {}
  local spaced = {}  -- the blocks after a table: 12 pt above them
  for i, b in ipairs(blocks) do
    local keep = i == #blocks
    local first = #out + 1
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { style = "BodyText", line = BODY, first = 720, keep = keep })
    elseif b.t == "BlockQuote" then
      local text = pandoc.Inlines({})
      for j, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("brief.lua: a block quotation holds paragraphs only") end
        if j > 1 then text:insert(pandoc.Space()) end
        text:extend(q.content)
      end
      out[#out + 1] = p(xe.inl(text), { style = "BlockText", before = GAP, after = GAP, left = QUOTE, right = QUOTE,
        keep = keep })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local k = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and ("(" .. k .. ")") or "\u{2022}"
        out[#out + 1] = p(xe.runs(label .. "\t") .. xe.inl(inlines_of(item)),
          { style = "ListItemNumbered", line = BODY, left = 1440, hanging = 720, keep = keep and j == #b.content })
        k = k + 1
      end
    elseif b.t == "Table" then
      -- 12 pt above and below (typst block-gap): the space after the block before it, before the block after it
      if #out > 0 then out[#out] = (out[#out]:gsub('w:after="0"', 'w:after="' .. GAP .. '"', 1)) end
      out[#out + 1] = pipe_table(b)
      spaced[#out + 1] = true
    else
      error("brief.lua: unsupported block " .. b.t .. " (see ../README.md, Markdown contract)")
    end
    if spaced[first] and out[first] then
      out[first] = (out[first]:gsub('w:before="0"', 'w:before="' .. GAP .. '"', 1))
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("227(c)(5)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("d/b/a"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function finish(doc)
  local m = doc.meta
  local xml = {}
  local function add(list) for _, x in ipairs(list) do xml[#xml + 1] = x end end
  add(court_title(m))
  -- a blank double-spaced line, the caption, a blank line, the title, a blank line (typst caption)
  xml[#xml + 1] = p("", { line = BODY })
  xml[#xml + 1] = caption(m)
  xml[#xml + 1] = p("", { line = BODY })
  xml[#xml + 1] = p(xe.inl(m.brief_title, { b = true }), { line = BODY, jc = "center" })
  xml[#xml + 1] = p("", { line = BODY })
  add(body(doc.blocks))
  xml[#xml + 1] = p("", { line = BODY, keep = true })
  xml[#xml + 1] = signature(m)
  local blocks = {}
  for _, x in ipairs(xml) do blocks[#blocks + 1] = xe.raw(x) end
  m.title, m.author, m.date = nil, nil, nil
  return pandoc.Pandoc(blocks, m)
end

return { { Str = break_rules }, { Pandoc = finish } }
