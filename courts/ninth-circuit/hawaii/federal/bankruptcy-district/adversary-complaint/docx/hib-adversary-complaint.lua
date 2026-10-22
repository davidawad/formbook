-- hib-adversary-complaint.lua (docx engine, docs/DOCX.md): the markdown contract -> Word, laid out and broken as
-- typst/hib-adversary-complaint.typ lays it out: the counsel block, the court title, the caption (a table: the
-- bankruptcy lines and parties left, with a rule on the right and under the last party; adversary number and title
-- right; FRBP 7010), the title, the body (pandoc's, with its footnotes), and the signature block. Nothing
-- case-specific is in this file: every word comes from the sample. The frontmatter is read as written
-- ($FORMBOOK_META, fb render).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_COL = 4680                     -- typst caption grid: two equal columns
local CAP_INSET = 288                    -- typst caption-inset 0.2 in
local CAP_PAD = 240                      -- typst caption-pad 12 pt
local DESIGNATION = 2592                 -- typst designation-indent 1.8 in
local SIG_COL = 4608                     -- typst sig-column 3.2 in

local function read_file(path)
  local f = path and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(k)
  if RAW[k] == nil then error("hib-adversary-complaint.lua: missing required metadata field `" .. k .. "`") end
  return RAW[k]
end

-- A frontmatter string as inlines, read as typst's cmarker reads it.
local function md(s)
  local b = pandoc.read(s or "", "commonmark+smart", PANDOC_READER_OPTIONS).blocks[1]
  if b == nil then return pandoc.Inlines({}) end
  if b.t == "Para" or b.t == "Plain" then return b.content end
  return pandoc.Inlines({ pandoc.Str(s) })
end

-- A single line paragraph: o = { before, after, left, jc, b, i, keep, line }; an empty string is a blank line.
local function p(s, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  local body = s
  if type(s) == "string" then body = s == "" and "" or xe.inl(md(s), { b = o.b, i = o.i }) end
  return xe.para(props, body)
end

local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function tbl(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local trs = {}
  for _, cells in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(cells) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption, title of the paper (HIB-ADV-FORM-001, -005)
-- ---------------------------------------------------------------------------

local function caption_side(side, out)
  for _, n in ipairs(side.names or {}) do out[#out + 1] = p(n) end
  out[#out + 1] = p(side.designation or "", { left = DESIGNATION })
end

local function cover()
  local out = {}
  for _, l in ipairs(need("counsel")) do out[#out + 1] = p(l) end
  if RAW.counsel_role then out[#out + 1] = p(RAW.counsel_role, { i = true }) end
  for i, l in ipairs(need("court")) do
    out[#out + 1] = p(pandoc.text.upper(l), { b = true, before = i == 1 and SINGLE or 0, jc = "center" })
  end
  local sides = need("caption")
  local title = pandoc.text.upper(need("paper_title"))
  -- the left cell of a row: its text 0.2 in off the rule on its right, 12 pt above its foot; the last row's rule
  -- closes the party column below
  local function left(body, last)
    body[#body] = body[#body]:gsub('w:after="0"', 'w:after="' .. CAP_PAD .. '"', 1)
    return { pr = '<w:tcBorders>' .. (last and '<w:bottom ' .. RULE .. '/>' or '') .. '<w:right ' .. RULE .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = body }
  end
  local function right(body)
    return { pr = '<w:tcMar><w:left w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = body }
  end
  local l1 = {}
  local bk = RAW.bankruptcy or {}
  for _, l in ipairs(bk) do l1[#l1 + 1] = p(l) end
  if #bk > 0 then l1[#l1 + 1] = p("") end
  caption_side(sides[1], l1)
  local rows = { { left(l1, #sides == 1), right({ p(need("adversary_number")), p(""), p(title, { b = true }) }) } }
  for i = 2, #sides do
    local l = { p("v.", { jc = "center" }), p("") }
    caption_side(sides[i], l)
    rows[#rows + 1] = { left(l, i == #sides), right({ p("") }) }
  end
  -- the caption stands a single line below the court title (Word: the title's space after; a table has no space of
  -- its own), the title of the paper a single line below the caption
  out[#out] = out[#out]:gsub('w:after="0"', 'w:after="' .. SINGLE .. '"', 1)
  out[#out + 1] = tbl({ CAP_COL, CAP_COL }, rows)
  out[#out + 1] = p(title, { b = true, jc = "center", before = SINGLE, after = SINGLE })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (HIB-ADV-FORM-010): "DATED:" at the left, the signatures in a 3.2 in column at the right, a
-- blank line between them; the row never splits. The space above it is a 1 pt paragraph kept with the table, its
-- space before the rest: at the top of a page LibreOffice drops a paragraph's space before, as typst drops a
-- block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

local function signature()
  local right = {}
  for i, b in ipairs(need("signature")) do
    if i > 1 then right[#right + 1] = p("") end
    for _, l in ipairs(b) do right[#right + 1] = p(l) end
  end
  return p("", { keep = true, before = SINGLE - 20, line = 20 }) ..
    tbl({ TEXTW - SIG_COL, SIG_COL }, { { { body = { p("DATED: " .. need("date")) } }, { body = right } } })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157"; typst boxes it): a no-break space after it.
local function bind_doubled(ils)
  for i = 1, #ils - 1 do
    local a, b = ils[i], ils[i + 1]
    if a.t == "Str" and b.t == "Space" and (a.text == "§§" or a.text == "¶¶") then ils[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return ils
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- Headings centered and bold at the body pitch, no space of their own, kept with the text; level 1 in capitals
-- as typst sets it (the recipe's Heading 1 capitals off, so the PDF text is the text set).
local NOCAPS = '<w:caps w:val="0"/></w:rPr>'
local function heading(level, content)
  local lvl = math.min(level, 3)
  local x = xe.inl(content, { b = true })
  if lvl == 1 then
    x = x:gsub('(<w:t xml:space="preserve">)([^<]*)', function(t, s) return t .. pandoc.text.upper(s) end)
  end
  return xe.raw(xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("center") },
    (x:gsub("</w:rPr>", NOCAPS))))
end

function Pandoc(doc)
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = xe.inlines })
  local out = {}
  for _, x in ipairs(cover()) do out[#out + 1] = xe.raw(x) end
  local last = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b.level, b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      local style = i == last and "Body Text Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
    else
      error("hib-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature())
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
