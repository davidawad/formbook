-- Complaint for the U.S. District Court for the District of Nebraska (ned), docx engine: what the Word output adds
-- to pandoc's conversion, so that it reads and breaks as typst/ned-complaint.typ does (README "Engines"): the counsel
-- block, the court title and caption (Fed. R. Civ. P. 10(a); NECivR 10.1(a)(3)), the numbered paragraphs (Fed. R.
-- Civ. P. 10(b)), the unnumbered "^" paragraphs, the lettered prayer items, the headings and claim sub-lines, and
-- the signature block (NECivR 11.1(a)(1)(A)). Caption and signature are OOXML tables, because pandoc has no caption
-- construct. The footer from page 2 is in docx/reference.xml; it shows the paper's title and the case number from
-- the document properties (SUBJECT, COMMENTS), which this filter sets from the frontmatter. Everything printed comes
-- from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_BOX = 576                   -- typst number-box, 0.4 in: the text after a paragraph number
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360   -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET, CAP_PAD = 200, 138      -- typst caption-inset 10 pt, caption-pad (half a single line)
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local DESIGNATION = 2160                 -- typst designation-indent 1.5 in
local SIG_LEFT, SIG_GUTTER = 3888, 288   -- typst sig-left 2.7 in, sig-gutter 0.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tabs } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel (top left), court title, caption (Fed. R. Civ. P. 10(a); NECivR 10.1(a)(3))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  -- Counsel block: upper left, single-spaced (the exemplar's convention).
  for _, l in ipairs(meta.counsel or {}) do out[#out + 1] = p(xe.inl(l)) end
  -- Court title, a line and a half of the body pitch below the counsel block; the caption a double line below it
  -- (Word has no space before a table: the last title line takes it as space after).
  local title = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF NEBRASKA" }
  if plain(meta.division) ~= "" then title[#title + 1] = pandoc.text.upper(plain(meta.division)) end
  for k, t in ipairs(title) do
    out[#out + 1] = p(xe.runs(t, { b = true }), { jc = "center", before = k == 1 and (3 * BODY) // 2 or 0,
      after = k == #title and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation, indented; "v." between the parties.
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIGNATION, after = k == #parties and CAP_PAD or 0 })
  end
  -- Right cell: the case number, the title, the jury demand (NECivR 10.1(a)(3)), the trial location.
  local right = {
    p(xe.runs("Case No. ") .. xe.inl(meta.case_number)),
    p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE }),
  }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("Jury Trial Demanded", { b = true }), { before = SINGLE })
  end
  if plain(meta.trial_location) ~= "" then
    right[#right + 1] = p(xe.runs("Trial Location: ") .. xe.inl(meta.trial_location))
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (NECivR 11.1(a)(1)(A)): "Dated" at the left; "Respectfully submitted,", then "s/ name", bar
-- number, attorney for, firm and contact lines at the right; the row never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = BODY }) }
  local right = {
    p(xe.runs("Respectfully submitted,"), { before = BODY }),
    p(xe.runs("s/ ") .. xe.inl(sig.signer), { before = SINGLE }),
    p(xe.runs("Bar Number: ") .. xe.inl(sig.bar_number)),
    p(xe.runs("Attorney for ") .. xe.inl(sig.attorney_for)),
  }
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch, with the first-line indent: unnumbered, or numbered (the number, a tab to
-- the end of typst's number box, the text). `last`: the paragraph before the signature, kept whole and with it.
local NUMBER_TAB = '<w:tabs><w:tab w:val="left" w:pos="' .. (INDENT + NUMBER_BOX) .. '"/></w:tabs>'
local function body_par(label, inlines, before, last)
  local o = { line = BODY, first = INDENT, before = before, keep = last }
  if label == nil then return p(xe.inl(inlines), o) end
  o.tabs = NUMBER_TAB
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), o)
end

-- Headings, kept with what follows: levels 1 and 2 bold and centered (level 1 in capitals) in a line of the body
-- pitch; level 3 (a claim sub-line) centered in a single line.
local function heading(el, before)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  if el.level <= 2 then
    return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(before or 0, 0, BODY), xe.ind(0, nil, 0),
      xe.jc("center") }, xe.inl(content, { b = true }))
  end
  return p(xe.inl(content), { keep = true, before = before, jc = "center" })
end

-- Prayer items, lettered A., B., ... (typst enum "A."): the letter half an inch in, the text hanging a further
-- half inch (typst item-indent and the label box).
local function prayer(list, out)
  for j, item in ipairs(list.content) do
    for k, b in ipairs(item) do
      local lab = k == 1 and (string.char(64 + j) .. ".\t") or ""
      out[#out + 1] = p(xe.runs(lab) .. xe.inl(b.content), { line = BODY, left = 2 * INDENT, hanging = INDENT })
    end
  end
end

-- A paragraph that starts with "^" is unnumbered; the marker (and the space after it) is removed.
local function unnumbered(inlines)
  local first = inlines[1]
  if not (first and first.t == "Str" and first.text:sub(1, 1) == "^") then return nil end
  local out = pandoc.Inlines({})
  local rest = first.text:sub(2)
  if rest ~= "" then out:insert(pandoc.Str(rest)) end
  for i = 2, #inlines do
    if not (i == 2 and rest == "" and inlines[i].t == "Space") then out:insert(inlines[i]) end
  end
  return out
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ Str = breaks })
  local out = cover(meta)
  -- the caption stands a single line above the text (typst: the caption block's below); Word has no space after a
  -- table, so the first paragraph after it takes the space before it
  local gap = SINGLE
  local function take()
    local g = gap
    gap = 0
    return g
  end
  local n = 0
  for i, b in ipairs(doc.blocks) do
    local last = i == #doc.blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b, take())
    elseif b.t == "Para" or b.t == "Plain" then
      local un = unnumbered(b.content)
      if un then
        out[#out + 1] = body_par(nil, un, take(), last)
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, take(), last)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      prayer(b, out)
    else
      error("ned-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  -- The footer's SUBJECT and COMMENTS fields: the paper's title in capitals, the case number.
  return pandoc.Pandoc(blocks, pandoc.Meta({
    subject = pandoc.MetaInlines({ pandoc.Str(pandoc.text.upper(plain(meta.footer_title))) }),
    description = pandoc.MetaInlines({ pandoc.Str(plain(meta.case_number)) }),
  }))
end
