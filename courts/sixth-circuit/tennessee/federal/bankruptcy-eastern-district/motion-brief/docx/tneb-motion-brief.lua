-- tneb motion brief (memorandum), DOCX engine: a pandoc filter so that the Word document reads and breaks as
-- typst/tneb-motion-brief.typ does: the court title, the caption (one table row per frontmatter row: the party
-- text, a ")" and the case information), the title, the lead-in and body paragraphs, the headings (the typed label
-- in a half-inch box, the text hanging after it), the last paragraph kept with the signature block, and the
-- certificate of service on its own page (the persons served two to a row). Every case word comes from the
-- sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs are
-- written by pandoc in the Body Text style of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body, pitch-single
local GAP = 276                          -- typst gap: a blank single line
local TITLE_BELOW = 240                  -- typst title-below 12 pt
local HEADING_GAP = 240                  -- typst heading-gap 12 pt
local BLOCK_GAP = 480                    -- typst block-gap 24 pt
local SERVED_ABOVE = 240                 -- typst served-above 12 pt
local LABEL = 720                        -- typst label-box 0.5 in
local SIG = 4680                         -- typst sig-indent 3.25 in
local LEFT, MID = 4680, 432              -- typst caption-left 3.25 in, caption-mid 0.3 in
local GUTTER = 432                       -- typst served-gutter 0.3 in
local TEXTW = 9360                       -- 6.5 in

-- The frontmatter as written (fb render's $FORMBOOK_META).
local function read_file(path)
  local f = path and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, brk, tabs, outline }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  if o.outline then props[#props + 1] = '<w:outlineLvl w:val="' .. o.outline .. '"/>' end
  return xe.para(props, body)
end

local function tab_at(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

-- A borderless table of fixed columns, no cell margins.
local function tbl(cols, rows)
  local grid = {}
  for _, w in ipairs(cols) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 2, 5": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A frontmatter value as pandoc inlines with the break rules applied.
local function mi(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then v = pandoc.read(v, "markdown").blocks end
  if v.t == "MetaBlocks" or (v[1] and (v[1].t == "Para" or v[1].t == "Plain")) then
    v = pandoc.utils.blocks_to_inlines(v)
  end
  local para = pandoc.Pandoc({ pandoc.Plain(pandoc.Inlines(v)) })
  para = para:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  return para.blocks[1].content
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title (FRBP 9004(b); LBR 9004-2)
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  out[#out + 1] = p(xe.runs("IN THE ", { b = true }) .. xe.inl(mi(meta.court), { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.inl(mi(meta.district), { b = true }), { jc = "center" })
  if meta.division then
    out[#out + 1] = p(xe.runs(pandoc.utils.stringify(meta.division):upper(), { b = true }), { jc = "center" })
  end
  local right = TEXTW - LEFT - MID
  local rows = {}
  for k, r in ipairs(meta.caption or {}) do
    -- the first row takes the blank single line above the caption (typst gap)
    local before = k == 1 and GAP or 0
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      tc(LEFT, p(xe.inl(mi(r.left)), { before = before })) ..
      tc(MID, p(xe.runs(")"), { before = before, jc = "center" })) ..
      tc(right, p(xe.inl(mi(r.right)), { before = before })) .. '</w:tr>'
  end
  out[#out + 1] = tbl({ LEFT, MID, right }, rows)
  -- the designation of the paper: bold, underlined, centered; Word has no space after a table, so the title takes
  -- the space before it
  out[#out + 1] = p(xe.inl(mi(meta.title), { b = true, u = true }), { before = GAP, after = TITLE_BELOW,
    jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Headings: the typed label ("I.", "A.") in a half-inch box, the text hanging after it
-- ---------------------------------------------------------------------------

local function heading(b, out)
  local lvl = math.min(b.level, 2)
  local content = b.content
  local label
  if #content >= 2 and content[1].t == "Str" and content[2].t == "Space" then
    local t = content[1].text
    if t:match("^[IVXLC]+%.$") or t:match("^[A-Za-z]%.$") or t:match("^%d+%.$") or t:match("^[ivx]+%.$") then
      label = t
      local rest = pandoc.Inlines({})
      for i = 3, #content do rest:insert(content[i]) end
      content = rest
    end
  end
  local style = lvl == 1 and { b = true, u = true } or { u = true }
  local left = lvl == 1 and 0 or LABEL
  local body = xe.inl(content, style)
  local o = { before = HEADING_GAP, after = HEADING_GAP, keep = true, outline = lvl - 1, left = left }
  if label then
    o.left, o.hanging, o.tabs = left + LABEL, LABEL, tab_at(left + LABEL)
    body = xe.runs(label .. "\t", { b = lvl == 1 }) .. body
  end
  out[#out + 1] = xe.raw(p(body, o))
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (LBR 9013-3(b))
-- ---------------------------------------------------------------------------

local function signature(sig, out)
  local lines = {}
  if sig.lead then lines[#lines + 1] = { mi(sig.lead), GAP } end
  if sig.firm then lines[#lines + 1] = { mi(sig.firm), GAP } end
  if sig.by then lines[#lines + 1] = { mi(sig.by), 0 } end
  for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = { mi(l), 0 } end
  -- kept on one page (typst's unbreakable block): every line but the last keeps with the next
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.inl(l[1]), { before = i == 1 and BLOCK_GAP or 0, after = l[2], left = SIG,
      keep = i < #lines })
  end
end

local function certificate(cert, out)
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true, u = true }), { after = HEADING_GAP,
    jc = "center", brk = true, keep = true })
  out[#out + 1] = p(xe.inl(mi(cert.text)), { line = BODY, first = LABEL })
  -- the persons served, two to a row, a blank single line between rows (typst grid)
  local col = (TEXTW - GUTTER) // 2
  -- the persons served as written ($FORMBOOK_META): one line of an address per "\n" (pandoc's metadata joins them)
  local served = RAW.certificate and RAW.certificate.served or {}
  local function cell(s, before)
    if s == nil then return tc(col, p("")) end
    local ps = {}
    local i = 0
    for line in s:gmatch("[^\n]+") do
      i = i + 1
      ps[#ps + 1] = p(xe.inl(mi(line)), { before = i == 1 and before or 0 })
    end
    return tc(col, table.concat(ps))
  end
  local rows = {}
  for i = 1, #served, 2 do
    local before = i == 1 and SERVED_ABOVE or GAP
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(served[i], before) ..
      tc(GUTTER, p("", { before = before })) .. cell(served[i + 1], before) .. '</w:tr>'
  end
  out[#out + 1] = tbl({ col, GUTTER, col }, rows)
  out[#out + 1] = p(xe.inl(mi(cert.signer)), { before = BLOCK_GAP, left = SIG })
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "district", "caption", "title" }) do
    assert(meta[k], "tneb-motion-brief: frontmatter needs " .. k)
  end
  local blocks = pandoc.Blocks({})
  if meta.lead_in then blocks:insert(pandoc.Para(pandoc.Inlines(meta.lead_in))) end
  blocks:extend(doc.blocks)
  blocks = pandoc.Pandoc(blocks):walk({ Str = breaks }):walk({ Inlines = bind_doubled }).blocks
  blocks = blocks:walk({ Inlines = xe.inlines })

  local raw = {}
  cover(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end

  -- the last block, when it is a paragraph, is kept with the signature block (typst: one unbreakable block)
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      heading(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      local style = (i == #blocks and meta.signature) and "Body Keep" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    else
      error("tneb-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  raw = {}
  if meta.signature then signature(meta.signature, raw) end
  if meta.certificate then certificate(meta.certificate, raw) end
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
