-- nced-complaint.lua (docx engine): the E.D.N.C. complaint as Word paragraphs, so that it reads and breaks as
-- typst/nced-complaint.typ does: the court and division (LR 10.1(b)), the "No." line (LR 10.1(c)), the caption with
-- its ")" column and the title block centered beside it (LR 10.1(d), (e)), the unnumbered lead-in, the allegations
-- numbered 1., 2., ... (Fed. R. Civ. P. 10(b); not headings, the prayer or the WHEREFORE clause), headings, the
-- prayer lettered A., B., ..., footnotes (Word footnotes) and the signature block (LR 10.1(f)-(i)). Everything
-- printed comes from the sample's frontmatter and body: no case text lives in this file. The page number comes from
-- the reference's footer (docx/reference.xml).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. A paragraph that carries a
-- footnote is left to pandoc (it writes the note) in the style "Body Text Note"; every other one is written here.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = SINGLE                       -- typst gap and heading-gap: a blank single line
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_PAREN = 4896, 360    -- typst caption-left 3.4 in, caption-paren 0.25 in
local TITLE_GAP = 360                    -- typst title-gap, 0.25 in
local SIG = 4320                         -- typst sig-indent, 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
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

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 2201"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- ---------------------------------------------------------------------------
-- Cover: court and division, "No." line, caption with the title block
-- ---------------------------------------------------------------------------

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- One row of exact single height per caption line: the party text, ")", and the title block in a cell merged over
-- every row and centered on them (typst: a grid cell spanning the rows, align(horizon)).
local function caption(meta)
  local rows = {}
  for _, item in ipairs(meta.caption.lines) do
    if type(item) == "table" and item.t ~= nil then
      rows[#rows + 1] = { item.t, tonumber(plain(item.i)) or 0 }
    else
      rows[#rows + 1] = { item, 0 }
    end
  end
  local title = p(xe.inl(meta.brief_title, { b = true }), { left = TITLE_GAP })
  if meta.jury_demand then
    title = title .. p(xe.runs("(JURY TRIAL DEMANDED)", { b = true }), { left = TITLE_GAP, before = GAP })
  end
  local col3 = TEXTW - CAP_LEFT - CAP_PAREN
  local trs = {}
  for k, r in ipairs(rows) do
    local tc
    if k == 1 then
      tc = '<w:tc><w:tcPr><w:tcW w:w="' .. col3 .. '" w:type="dxa"/><w:vMerge w:val="restart"/><w:vAlign w:val="center"/></w:tcPr>' ..
        title .. '</w:tc>'
    else
      tc = '<w:tc><w:tcPr><w:tcW w:w="' .. col3 .. '" w:type="dxa"/><w:vMerge/></w:tcPr>' .. p("") .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. SINGLE .. '" w:hRule="exact"/></w:trPr>' ..
      '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/></w:tcPr>' .. p(xe.inl(r[1]), { left = r[2] * INDENT }) .. '</w:tc>' ..
      '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_PAREN .. '" w:type="dxa"/></w:tcPr>' .. p(xe.runs(")")) .. '</w:tc>' ..
      tc .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    '<w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_PAREN .. '"/><w:gridCol w:w="' .. col3 .. '"/>' ..
    '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local function cover(meta, out)
  for _, l in ipairs({ "IN THE UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF NORTH CAROLINA",
    pandoc.text.upper(plain(meta.division)) .. " DIVISION" }) do
    out[#out + 1] = p(xe.runs(l), { jc = "center" })
  end
  -- LR 10.1(c): the case number is assigned by the clerk; an initial filing leaves it blank.
  local num = plain(meta.case_number)
  out[#out + 1] = p(xe.runs("No. " .. (num ~= "" and num or string.rep("_", 14))), { jc = "center", before = GAP })
  -- typst: the caption stands a blank single line below the "No." line
  out[#out + 1] = p("", { line = GAP })
  out[#out + 1] = caption(meta)
end

-- ---------------------------------------------------------------------------
-- Signature block (LR 10.1(f)-(i)): kept together (typst: an unbreakable block)
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local rows = { { xe.runs("This the ") .. xe.inl(meta.date) .. xe.runs("."), 0, BODY } }
  local firm = sig.firm or {}
  local by = sig.by and plain(sig.by) or plain(sig.signers[1].name)
  local groups = {}
  if #firm > 0 then groups[#groups + 1] = firm end
  groups[#groups + 1] = { (#firm > 0 and "BY: /s/ " or "/s/ ") .. by }
  for _, s in ipairs(sig.signers) do
    local g = { s.name }
    for _, l in ipairs(s.lines or {}) do g[#g + 1] = l end
    groups[#groups + 1] = g
  end
  groups[#groups + 1] = sig.address or {}
  groups[#groups + 1] = sig.counsel_for or {}
  local first = true
  for _, g in ipairs(groups) do
    if #g > 0 then
      for i, l in ipairs(g) do
        rows[#rows + 1] = { xe.inl(l), SIG, i == 1 and (first and BODY or GAP) or 0 }
      end
      first = false
    end
  end
  for i, r in ipairs(rows) do out[#out + 1] = p(r[1], { left = r[2], before = r[3], keep = i < #rows }) end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, a single line above and below, kept with the text: level 1 centered bold capitals,
-- level 2 centered bold, level 3 bold italic at the margin. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  if b.level == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(b.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(GAP, GAP, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

local function has_note(b)
  local found = false
  b:walk({ Note = function() found = true end })
  return found
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- A body paragraph at the double pitch, first line indented: unnumbered, or the number, a tab to the end of its
-- half-inch box (typst: box(width: para-indent)), the text. One with a footnote is left to pandoc ("Body Text
-- Note": Body Text's pitch and indent; the default tab stops put the text at 1 in).
local function body_par(label, inlines, before)
  if has_note(pandoc.Para(inlines)) then
    local c = pandoc.Inlines({})
    if label then c:extend({ pandoc.Str(label), TAB }) end
    c:extend(inlines)
    return pandoc.Div({ pandoc.Para(c):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = "Body Text Note" })
  end
  if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT, before = before }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT,
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' })
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in, GAP) end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" then
      -- the prayer, lettered: the letter at the item indent in a box of its width, the text hanging after it
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs(string.char(64 + i) .. ".\t") .. xe.inl(item[1].content),
          { line = BODY, left = 2 * INDENT, hanging = INDENT })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if stringify(b):match("^WHEREFORE") then
        out[#out + 1] = body_par(nil, b.content)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content)
      end
    else
      error("nced-complaint.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
