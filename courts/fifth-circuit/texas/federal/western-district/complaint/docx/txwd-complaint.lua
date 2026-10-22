-- W.D. Tex. complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it reads
-- and breaks as typst/txwd-complaint.typ does (see ../README.md): the court title, the caption (party column, §
-- column, case column; CV-10(a), FRCP 10(a)), the title, the numbered paragraphs (FRCP 10(b)), the headings, the
-- centered count lines ("> "), the lists, the unnumbered prayer lead-in ("~ ") and the signature block (CV-10(b)).
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file. Caption and
-- signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 288 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 288                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent and list-indent, 0.5 in
local LABEL = 360                                      -- typst list-label, 0.25 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_MID = 5328, 432                    -- typst caption-left 3.7 in, caption-mid 0.3 in
local CAP_INSET, CAP_LEAD = 288, 108                   -- typst caption-right-inset 0.2 in, caption-lead 0.075 in
local SIG_RIGHT = 4608                                 -- typst signature-indent 3.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless one-row table: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- The sample's frontmatter as written ($FORMBOOK_META): pandoc drops a caption row's leading spaces, which the typst
-- template turns into an indent.
local function raw_meta()
  local path = os.getenv("FORMBOOK_META")
  if not path or path == "" then return {} end
  local f = io.open(path, "r")
  if not f then return {} end
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false) or {}
end

-- ---------------------------------------------------------------------------
-- Court title, caption and title
-- ---------------------------------------------------------------------------

local function cover(meta, rows)
  local out = {}
  local court = meta.court or {}
  for i, l in ipairs(court) do
    -- the caption stands two single lines below the court title (Word has no space before a table here: the
    -- last title line takes it as space after)
    out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center", after = i == #court and 2 * SINGLE or 0 })
  end
  local left, mid, right = {}, {}, {}
  for _, r in ipairs(rows or {}) do
    local l = r[1] or ""
    local stripped = l:gsub("^%s+", "")
    left[#left + 1] = p(xe.runs(stripped), { left = (#l - #stripped) * CAP_LEAD })
    mid[#mid + 1] = p(xe.runs("§"), { jc = "center" })
    right[#right + 1] = p(xe.runs(r[2] or ""), { left = CAP_INSET })
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_MID, TEXTW - CAP_LEFT - CAP_MID }, { { body = left }, { body = mid },
    { body = right } })
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = 2 * SINGLE, line = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (CV-10(b)): the date at the left; "Respectfully submitted", "/s/" and the signer and the signer's
-- lines in the right 3.2 inches; the row never splits. The space above it is a 1 pt paragraph kept with the table,
-- its space before the rest: at the top of a page LibreOffice drops a paragraph's space before, as typst drops a
-- block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = {
    p(xe.runs("Respectfully submitted,")),
    p(xe.runs("/s/ ") .. xe.inl(sig.signer), { before = SINGLE }),
  }
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  return p("", { keep = true, before = SINGLE - 20, line = 20 }) ..
    tbl({ TEXTW - SIG_RIGHT, SIG_RIGHT }, { { body = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) } },
      { body = right } }, '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, keep)
  local q = { line = BODY, first = INDENT, keep = keep }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings at the body pitch, bold: levels 1 and 2 centered (level 1 in capitals), level 3 at the margin; kept with
-- the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- Lists: the label half an inch in per level (a nested list a further half inch), in a box of a quarter inch, the
-- text hanging after it; numbers as written, a bullet for "-".
local function items(list, level, out)
  local n = list.t == "OrderedList" and list.listAttributes.start or 1
  for _, item in ipairs(list.content) do
    local lab = list.t == "OrderedList" and (n .. ".") or "\u{2022}"
    local left = INDENT * (level + 1) + LABEL
    local first = true
    for _, b in ipairs(item) do
      if b.t == "Plain" or b.t == "Para" then
        if not first then error("txwd-complaint.lua: a list item holds one paragraph") end
        out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(b.content),
          { line = BODY, left = left, hanging = LABEL, tab = left })
        first = false
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        items(b, level + 1, out)
      else
        error("txwd-complaint.lua: unsupported block in a list: " .. b.t)
      end
    end
    n = n + 1
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 45.50.471"), as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A paragraph that starts with "~ " is unnumbered (the prayer lead-in): its content without the marker, or nil.
local function unnumbered(b)
  local first = b.content[1]
  if first and first.t == "Str" and first.text == "~" then
    local rest = pandoc.Inlines(b.content)
    rest:remove(1)
    if rest[1] and rest[1].t == "Space" then rest:remove(1) end
    return rest
  end
  return nil
end

-- The lines of a paragraph, split at its source line breaks.
local function lines_of(inlines)
  local out, cur = {}, pandoc.Inlines({})
  for _, x in ipairs(inlines) do
    if x.t == "SoftBreak" or x.t == "LineBreak" then
      out[#out + 1] = cur
      cur = pandoc.Inlines({})
    else
      cur:insert(x)
    end
  end
  out[#out + 1] = cur
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = cover(meta, raw_meta().caption)
  local blocks = doc.blocks
  -- the first block of the body stands a single line below the title
  local gap = SINGLE
  local function take()
    local g = gap
    gap = 0
    return g
  end
  local n = 0
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    local before = take()
    local start = #out + 1
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      -- count lines: one centered single-spaced line per source line, kept with what follows
      for _, q in ipairs(b.content) do
        for _, l in ipairs(lines_of(q.content)) do out[#out + 1] = p(xe.inl(l), { jc = "center", keep = true }) end
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, 0, out)
    elseif b.t == "Para" or b.t == "Plain" then
      -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      local u = unnumbered(b)
      if u then
        out[#out + 1] = body_par(nil, u, last)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, last)
      end
    else
      error("txwd-complaint.lua: unsupported block " .. b.t)
    end
    if before > 0 then
      out[start] = out[start]:gsub('w:before="0"', 'w:before="' .. before .. '"', 1)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
