-- Complaint for the U.S. District Court for the District of Columbia (dcd), docx engine: what the Word output adds
-- to pandoc's conversion, so that it reads and breaks as typst/dcd-complaint.typ does (README "Engines"): the court
-- title and caption (LCvR 5.1(c), (d); Fed. R. Civ. P. 10(a)), the numbered paragraphs (Fed. R. Civ. P. 10(b)), the
-- lettered prayer items, the unnumbered ">" paragraphs, the headings and the signature block. Everything printed
-- comes from the sample's frontmatter and body: no case text lives in this file. Caption and signature are OOXML
-- tables, because pandoc has no caption construct.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276          -- typst pitch-double, pitch-single
local INDENT = 720                     -- typst para-indent and item-indent, 0.5 in
local TEXTW = 9360                     -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288 -- typst caption-left 3.4 in, caption-gutter 0.2 in
local CAP_INSET, CAP_PAD = 200, 138    -- typst caption-inset 10 pt, caption-pad (half a single line)
local RIGHT_INSET = 144                -- typst right-inset 0.1 in
local SIG_LEFT, SIG_GUTTER = 4032, 288 -- typst sig-left 2.8 in, sig-gutter 0.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep } (a hanging indent writes no firstLine:
-- Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
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
-- Court title and caption (LCvR 5.1(c)(1), 5.1(d); Fed. R. Civ. P. 10(a))
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" }),
    p(xe.runs("FOR THE DISTRICT OF COLUMBIA", { b = true }), { jc = "center", after = BODY }),
  }
  -- Left cell: each party's names, then its designation; "v." between the parties.
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_PAD or 0 })
  end
  -- Right cell: the case number (blank until assigned), the title, the jury line.
  local number = plain(meta.case_number)
  if number == "" then number = "____________" end
  local right = {
    p(xe.runs("Civil Action No. " .. number)),
    p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE }),
  }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = SINGLE })
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
-- Signature block: "Dated" at the left; the signature column at the right; the row never splits.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = BODY }) }
  local right = {
    p(xe.runs("Respectfully submitted,"), { before = BODY }),
    p(xe.runs("________________________________"), { before = BODY }),
    p(xe.inl(sig.signer)),
  }
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = p(xe.inl(l)) end
  right[#right + 1] = p(xe.inl(sig.role))
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number, a tab to the
-- paragraph indent (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, before)
  if label == nil then return p(xe.inl(inlines), { line = BODY, first = INDENT, before = before }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, before = before })
end

-- Headings at the body pitch, bold, centered (level 1 in capitals) or at the margin (level 3); kept with the text.
local function heading(el, before)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(before or 0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
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

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("Loan/Award": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = cover(meta)
  -- the caption stands a double line above the text (typst: the caption block's below); Word has no space after a
  -- table, so the first paragraph after it takes the space before it
  local gap = BODY
  local function take()
    local g = gap
    gap = 0
    return g
  end
  if meta.lead_in then out[#out + 1] = body_par(nil, meta.lead_in, take()) end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b, take())
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(n .. ".", b.content, take())
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      prayer(b, out)
    elseif b.t == "BlockQuote" then
      -- A ">" line is an unnumbered paragraph (for example the WHEREFORE lead-in).
      for _, q in ipairs(b.content) do out[#out + 1] = body_par(nil, q.content, take()) end
    else
      error("complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
