-- nywd complaint (W.D.N.Y.), docx engine (docs/DOCX.md): the same markdown contract as typst/nywd-complaint.typ, and
-- every block written as it sets it: the court title, the caption (the parties box with a rule at its right and
-- bottom; the title, the civil action number line and the jury demand at its right; Fed. R. Civ. P. 10(a)), the
-- lead-in, the numbered paragraphs (Fed. R. Civ. P. 10(b)), the headings, the unnumbered paragraphs
-- ("<!-- unnumbered -->"), the lettered items ("1." lists), block quotations and the signature block (Fed. R. Civ.
-- P. 11(a)). Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
-- Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, item-indent, item-label, quote-indent
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 432                 -- typst caption-left (3.4 in), caption-gutter (0.3 in)
local CAP_PAD = 144                                    -- typst caption-pad, 0.1 in
local CAP_FOOT = 145                                   -- typst caption-foot (160) less the 0.75 pt rule LibreOffice
                                                       -- sets below the cell
local CAP_GAP = 138                                    -- typst caption-gap, half a single line
local AGAINST, DESIGNATION = 1728, 3168                -- typst against-indent (1.2 in), designation-indent (2.2 in)
local SIG_W = 4608                                     -- typst signature-w, 3.2 in
local RULE = 'w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt
local COURT = { "UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF NEW YORK" }

local stringify = pandoc.utils.stringify

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table without cell margins that is never split: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells)
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
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

local function list(m)
  local out = {}
  for _, x in ipairs(m or {}) do out[#out + 1] = x end
  return out
end

-- Several metadata values as runs, a space between them (typst: join(" ")).
local function joined(vs)
  local out = {}
  for _, v in ipairs(list(vs)) do out[#out + 1] = xe.inl(v) end
  return table.concat(out, xe.runs(" "))
end

-- ---------------------------------------------------------------------------
-- Court title and caption
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  for i, l in ipairs(COURT) do
    -- the caption a single line below the court title (the last title line takes it as space after)
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true, after = i == #COURT and SINGLE or 0 })
  end
  local left = {}
  local parties = list(meta.caption.parties)
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { left = AGAINST, before = CAP_GAP }) end
    left[#left + 1] = p(joined(party.names), { before = k > 1 and CAP_GAP or 0 })
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIGNATION, before = CAP_GAP })
  end
  local right = {
    p(xe.runs(pandoc.text.upper(stringify(meta.title)), { b = true })),
    p(xe.runs("Civil Action No. __________________"), { before = BODY }),
  }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED", { b = true }), { before = BODY })
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom w:val="single" ' .. RULE .. '/><w:right w:val="single" ' .. RULE ..
      '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
      '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("") } },
    { body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature: a double line below the body (the space above its first lines), "Dated:" at the left; the firm in
-- bold, a double line below it "By:" and the signer's lines at the right; never split.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = {}
  for i, f in ipairs(list(sig.firm)) do
    right[#right + 1] = p(xe.inl(f, { b = true }), { before = i == 1 and BODY or 0 })
  end
  right[#right + 1] = p(xe.runs("By: ") .. xe.inl(sig.by), { before = BODY })
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = BODY }) }
  return tbl({ TEXTW - SIG_W, SIG_W }, { { body = left }, { body = right } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, o)
  local q = { line = BODY, first = INDENT, keep = o.keep, before = o.before }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings bold and centered, level 1 in capitals; single-spaced, a single line above and below, kept with the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return p(xe.inl(content, { b = true }), { style = "Heading" .. math.min(el.level, 3), keep = true, before = SINGLE,
    after = SINGLE, jc = "center" })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number, as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- An HTML comment marker (<!-- name -->): its name, or nil.
local function marker(b)
  if b.t == "RawBlock" and b.format == "html" then return b.text:match("^<!%-%-%s*(%a+)%s*%-%->") end
  return nil
end

function Pandoc(doc)
  local meta = doc.meta
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = cover(meta)
  -- the lead-in a double line below the caption
  out[#out + 1] = body_par(nil, meta.lead_in, { before = BODY })
  -- the body without its markers; an unnumbered marker flags the paragraph after it
  local blocks, flagged = {}, {}
  local pending = false
  for _, b in ipairs(doc.blocks) do
    local m = marker(b)
    if m then
      pending = pending or m == "unnumbered"
    else
      blocks[#blocks + 1] = b
      flagged[#blocks] = pending
      pending = false
    end
  end
  local n = 0
  for i, b in ipairs(blocks) do
    -- the last block stays whole with the signature block (typst: a sticky, unbreakable block)
    local last = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("nywd-complaint.lua: a list item holds one paragraph")
        end
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + k) .. ")\t") .. xe.inl(item[1].content),
          { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT, keep = last and k == #b.content })
      end
    elseif b.t == "BlockQuote" then
      local qs = b.content
      for k, q in ipairs(qs) do
        out[#out + 1] = p(xe.inl(q.content), { left = INDENT, right = INDENT, before = k == 1 and SINGLE or 0,
          after = k == #qs and SINGLE or 0, keep = last })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if flagged[i] then
        out[#out + 1] = body_par(nil, b.content, { keep = last })
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, { keep = last })
      end
    else
      error("nywd-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
