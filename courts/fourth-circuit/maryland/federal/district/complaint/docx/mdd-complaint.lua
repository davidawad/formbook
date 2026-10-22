-- mdd-complaint.lua (docx engine): the D. Md. complaint as Word paragraphs, so that it reads and breaks as
-- typst/mdd-complaint.typ does: the court lines, the caption (LR-102.2.a: a table whose party column has the right
-- and bottom rules, the case number beside it), the title, the unnumbered lead-in, the allegations numbered 1., 2.,
-- ... (FRCP 10(b)); a paragraph beginning "^ " is unnumbered (WHEREFORE, the jury demand; the marker is removed),
-- headings, the prayer lettered (a), (b), ..., and the signature block (LR-102.1.b.i), kept with the last paragraph.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap-half
local HEAD_ABOVE = 395                   -- typst heading-above, 19.75 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local LABEL = 900                        -- typst item-label, 0.625 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAD = 5184, 288      -- typst caption-left 3.6 in, caption-pad 0.2 in
local DESIG = 2592                       -- typst designation-indent, 1.8 in
local CASE_TOP = 72                      -- typst case-top, 3.6 pt
local SIG_LEFT = 4896                    -- typst sig-left, 3.4 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless one-row table that never splits: cells = { { width, paragraphs, tcBorders } }.
local function tbl(cells)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    local body = #c[2] > 0 and table.concat(c[2]) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court lines, caption, title
-- ---------------------------------------------------------------------------

local function caption(meta)
  local parties = meta.caption.parties
  local left = {}
  local function add(x, o)
    o = o or {}
    o.right = CAP_PAD
    left[#left + 1] = p(x, o)
  end
  for k, party in ipairs(parties) do
    if k > 1 then add(xe.runs("v."), { jc = "center", before = GAP, after = GAP }) end
    for _, n in ipairs(party.names) do add(xe.inl(n)) end
    for _, a in ipairs(party.address or {}) do add(xe.inl(a)) end
    if party.county then add(xe.inl(party.county)) end
    -- the last designation keeps the caption's bottom padding (typst: pad(bottom: gap-half))
    add(xe.inl(party.designation), { before = GAP, left = DESIG, after = k == #parties and GAP or 0 })
  end
  local num = plain(meta.case_number)
  -- an empty case number leaves a blank for the clerk
  local right = { p(xe.runs("Case No. " .. (num ~= "" and num or string.rep("_", 14))), { before = CASE_TOP, left = CAP_PAD }) }
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return tbl({ { CAP_LEFT, left, rule }, { TEXTW - CAP_LEFT, right } })
end

local function cover(meta)
  local out = {}
  for _, c in ipairs(meta.court) do out[#out + 1] = p(xe.inl(c), { jc = "center" }) end
  -- typst: the caption stands a double line below the court lines
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = caption(meta)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.brief_title)), { b = true }),
    { jc = "center", before = BODY, after = GAP, line = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (LR-102.1.b.i): "Dated" beside the signature column; one row that never splits
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local lines = { "Respectfully submitted,", "/s/ " .. plain(sig.name), sig.name, sig.bar }
  for _, f in ipairs(sig.firm) do lines[#lines + 1] = f end
  for _, a in ipairs(sig.address) do lines[#lines + 1] = a end
  for _, l in ipairs({ "Telephone: " .. plain(sig.phone), "Facsimile: " .. plain(sig.fax), sig.email, sig.role }) do
    lines[#lines + 1] = l
  end
  local right = {}
  for i, l in ipairs(lines) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and BODY or 0 }) end
  local left = { p(meta.date and (xe.runs("Dated: ") .. xe.inl(meta.date)) or "", { before = BODY }) }
  return tbl({ { SIG_LEFT, left }, { TEXTW - SIG_LEFT, right } })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, kept with the text: level 1 centered bold capitals, level 2 bold hanging, level 3 bold
-- italic, level 4 centered (the cause's sub-title, close under it). Heading styles 1-3 give the outline level.
local function heading(b)
  local content = b.content
  local lvl = math.min(b.level, 4)
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local ind = lvl == 2 and xe.ind(INDENT, INDENT, nil) or xe.ind(0, nil, 0)
  -- level 4 without a Heading style: the recipe's Heading 4 is bold italic, typst sets the sub-title plain
  return xe.para({ lvl < 4 and xe.style("Heading" .. lvl) or "", xe.KEEP, xe.spacing(lvl < 4 and HEAD_ABOVE or 0, 0, BODY), ind,
    xe.jc((lvl == 1 or lvl == 4) and "center" or "left") },
    xe.inl(content, { b = lvl <= 3, i = lvl == 3 }))
end

-- A body paragraph at the double pitch, first line indented: unnumbered, or the number, a tab to the end of its
-- half-inch box (typst: box(width: para-indent)), the text.
local function body_par(label, body, keep)
  if label == nil then return p(body, { line = BODY, first = INDENT, keep = keep }) end
  return p(xe.runs(label .. "\t") .. body, { line = BODY, first = INDENT, keep = keep,
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 101"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = cover(meta)
  if meta.lead_in then
    local lead = pandoc.read(plain(meta.lead_in), "markdown+smart").blocks[1]
    out[#out + 1] = body_par(nil, xe.inl(lead.content))
  end
  local n = 0
  local blocks = doc.blocks
  for k, b in ipairs(blocks) do
    -- the last block stays on one page with the signature block (typst: one unbreakable block)
    local last = k == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + i) .. ")\t") .. xe.inl(item[1].content),
          { line = BODY, left = INDENT + LABEL, hanging = LABEL, keep = last })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      if c[1] and c[1].t == "Str" and c[1].text == "^" then
        local rest = pandoc.Inlines({ table.unpack(c, 2) })
        if rest[1] and rest[1].t == "Space" then rest:remove(1) end
        out[#out + 1] = body_par(nil, xe.inl(rest), last)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", xe.inl(c), last)
      end
    else
      error("mdd-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
