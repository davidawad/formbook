-- lawb adversary complaint, docx engine. Mirrors typst/lawb-adversary-complaint.typ; rules and conventions are in
-- ../README.md (Engines). The cover (court name and division, title, the caption: parties left, a vertical rule, case
-- numbers right), the numbered allegations (Fed. R. Civ. P. 10(b)), the unnumbered paragraphs (the markdown's block
-- quotations), the lettered prayer items, the transfers table and the signature block (LBR 5005-1(b)) are built here.
-- Font, spacing, margins and the page number are styles and section settings in docx/reference.xml (fb render builds
-- the reference document from it). Numbers and letters are typed text, as the typst template types them, so every
-- viewer shows the same numbering. Content-agnostic: every case-specific word comes from the sample's frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 280                        -- typst pitch-single
local TEXTW = 9360                        -- typst text-width, 6.5 in
local COURT = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF LOUISIANA" }
local CAP_LEFT, CAP_GUTTER = 4752, 360    -- typst caption-left 3.3 in, caption-gutter 0.25 in
local CAP_PAD, CAP_PAD_BOTTOM = 288, 144  -- typst caption-pad 0.2 in, caption-pad-bottom 0.1 in
local CASE_PAD = 144                      -- typst case-pad 0.1 in
local PARTY_STEP = 720                    -- typst party-step 0.5 in
local COURT_BELOW, TITLE_BELOW, CAPTION_BELOW = 480, 480, 480 -- typst court-below, title-below, caption-below 24 pt
local SIG_LEFT = 4680                     -- typst sig-left 3.25 in
local SIG_ABOVE = 480                     -- typst signature-above 24 pt
local TABLE_ABOVE, TABLE_BELOW = 240, 240 -- typst table-above, table-below 12 pt

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

-- A single-spaced paragraph: o = { before, after, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- A line of text: a string as runs, a metadata value as its inlines.
local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- Single-spaced lines (typst line-stack): an empty item is a blank line, the next line a line lower. An item is
-- { text, level }; o = { left, keep } for every line (keep: all but the last line keep with the next).
local function stack(lines, o)
  o = o or {}
  local out, gap = {}, 0
  for i, l in ipairs(lines) do
    if txt(l[1]) == "" then
      gap = gap + SINGLE
    else
      out[#out + 1] = p(line(l[1]), { before = gap, left = (o.left or 0) + (l[2] or 0) * PARTY_STEP,
        keep = o.keep and i < #lines })
      gap = 0
    end
  end
  return table.concat(out)
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- ---------------------------------------------------------------------------
-- Cover: court name and division, title, caption
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(m)
  local out = {}
  local court = { table.unpack(COURT) }
  if m.division then court[#court + 1] = txt(m.division):upper() end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end
  out[#out + 1] = p(xe.runs(txt(m.title):upper(), { b = true, u = true }), { jc = "center", before = COURT_BELOW })
  out[#out + 1] = space(TITLE_BELOW)

  local left, right = {}, {}
  for _, it in ipairs(m.caption.left) do left[#left + 1] = { it.t, tonumber(txt(it.i)) or 0 } end
  for _, t in ipairs(items(m.caption.right)) do right[#right + 1] = { t, 0 } end
  local cap_right = TEXTW - CAP_LEFT - CAP_GUTTER
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' .. NOLOOK .. '</w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="'
    .. cap_right .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(CAP_LEFT, stack(left), '<w:tcBorders>' .. string.format(RULE, "right") .. '</w:tcBorders>'
      .. '<w:tcMar><w:bottom w:w="' .. CAP_PAD_BOTTOM .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. cell(CAP_GUTTER, p(""))
    .. cell(cap_right, stack(right), '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. '</w:tr></w:tbl>'
  out[#out + 1] = space(CAPTION_BELOW)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- The transfers table (typst pipe-table): unruled, single-spaced, the width of the text; a column's width in
-- proportion to its longest cell (characters) plus TABLE_SLACK, rounded to the twip, the last column the rest; cells
-- padded as typst table-inset and table-pad; kept on one page (typst: breakable: false).
-- ---------------------------------------------------------------------------

local TABLE_SLACK, TABLE_INSET, TABLE_PAD = 4, 120, 60

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
    widths[j] = math.floor(TEXTW * need[j] / total + 0.5)
    used = used + widths[j]
  end
  widths[ncol] = TEXTW - used
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for i, r in ipairs(rows) do
    local tcs = {}
    for j, c in ipairs(r.cells) do
      tcs[#tcs + 1] = cell(widths[j], p(xe.inl(pandoc.utils.blocks_to_inlines(c.contents)), { keep = i < #rows }))
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="' .. TABLE_PAD .. '" w:type="dxa"/><w:left w:w="' .. TABLE_INSET .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. TABLE_PAD .. '" w:type="dxa"/><w:right w:w="' .. TABLE_INSET .. '" w:type="dxa"/></w:tblCellMar>'
    .. NOLOOK .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 5005-1(b)): single-spaced at 3.25 in, kept on one page, after a space of its own
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local lines = { { "Respectfully submitted," }, { "" }, { s.firm },
    { pandoc.Inlines({ pandoc.Str("By:"), pandoc.Space() }) .. pandoc.Inlines(s.by) } }
  for _, l in ipairs(items(s.lines)) do lines[#lines + 1] = { l } end
  lines[#lines + 1] = { "" }
  for _, l in ipairs(items(s.counsel_for)) do lines[#lines + 1] = { l } end
  return space(SIG_ABOVE) .. stack(lines, { left = SIG_LEFT, keep = true })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

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

-- A typed label ("1.", "(a)") and a tab, then the text.
local function labelled(style, label, content)
  local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(label .. "\t")) })
  inl:extend(content)
  return styled(style, inl)
end

local function finish(doc)
  local m = doc.meta
  local out = { xe.raw(cover(m)) }
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = pandoc.Header(math.min(b.level, 2), b.content)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = labelled("Numbered Paragraph", n .. ".", b.content)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("lawb-adversary-complaint.lua: a block quotation must be a paragraph") end
        out[#out + 1] = styled("Body Text", q.content)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = labelled("List Letter", "(" .. string.char(96 + i) .. ")", pandoc.utils.blocks_to_inlines(item))
      end
    elseif b.t == "Table" then
      out[#out + 1] = xe.raw(space(TABLE_ABOVE) .. pipe_table(b) .. space(TABLE_BELOW))
    else
      error("lawb-adversary-complaint.lua: unexpected block " .. b.t)
    end
  end
  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  body:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
