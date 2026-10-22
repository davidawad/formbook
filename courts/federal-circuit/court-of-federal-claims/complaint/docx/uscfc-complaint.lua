-- uscfc-complaint.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads and breaks
-- as typst/uscfc-complaint.typ does (README "Engines"): the caption (RCFC 10(a), 5.5(h)), the headings, the
-- signature block (RCFC 5.5(d)-(f)), the certificate of service (RCFC 5(d)(1)(B)), and the prayer-for-relief lists
-- at their typst indents. Everything printed comes from the sample's frontmatter: no case text lives in this file.
-- Caption and signature are built as OOXML tables, because pandoc has no caption construct.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276        -- typst pitch-double, pitch-single
local INDENT = 720                   -- typst para-indent, 0.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360 -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_RIGHT_PAD = 288            -- typst: the file number column stands 0.2 in into its cell
local CAP_PAD = 138                  -- typst caption-pad: the rules stand half a line off the text
local DESIG = 2160                   -- typst designation-indent, 1.5 in
local TEXTW = 9360                   -- 6.5 in
local SIG_COL = 3240                 -- typst sig-col, 2.25 in
local LIST_IND, LIST_GAP = 720, 120  -- typst list indent 0.5 in, body-indent 0.5 em

local function need(meta, key)
  if meta[key] == nil then error("uscfc-complaint.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function plain(m)
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function flag(m)
  return m == true
end

-- A single-spaced paragraph: o = { before, after, line, left, first, jc, keep, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- The signer over a rule to the end of the column (typst `signed`: the rule takes no room of its own).
local function signed(name, left, col, before)
  return p(xe.runs("/s/ " .. name, { u = true }) .. xe.runs("\t", { u = true }),
    { tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. col .. '"/></w:tabs>', left = left, before = before, keep = true })
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
-- Caption (RCFC 10(a), 5.5(h) bid protest, 7(a) designation; 5.5(g) judge blank)
-- ---------------------------------------------------------------------------

local function caption(meta)
  local out = {}
  -- typst court-below (18 pt) under the last line above the party block.
  local bid = flag(meta.bid_protest)
  out[#out + 1] = p(xe.runs(plain(need(meta, "court")):upper(), { b = true }), { jc = "center", after = bid and 0 or 360 })
  if bid then
    out[#out + 1] = p(xe.runs("Bid Protest", { b = true }), { jc = "center", after = 360 })
  end
  -- Left cell: the parties, each side's names then its designation, single lines apart (typst party-block).
  local left = {}
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    if i > 1 then
      left[#left + 1] = p(xe.runs("v."), { jc = "center", before = SINGLE, after = SINGLE })
    end
    for _, name in ipairs(side.names) do
      left[#left + 1] = p(xe.inl(name))
    end
    left[#left + 1] = p(xe.inl(side.designation), { left = DESIG, before = SINGLE, after = i == #sides and CAP_PAD or 0 })
  end
  -- Right cell, at the bottom: the file number (blank for the clerk until given) and the judge line (RCFC 5.5(g)).
  local blank = xe.runs(string.rep("\u{00A0}", 24), { u = true })
  local fileno = meta.file_number ~= nil and xe.runs(plain(meta.file_number)) or blank
  local right = {
    p(xe.runs("Case No. ") .. fileno),
    p(xe.runs("Judge ") .. blank, { after = CAP_PAD }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + CAP_RIGHT_PAD) .. '" w:type="dxa"/></w:tcMar><w:vAlign w:val="bottom"/>',
      body = right },
  })
  -- typst title-above 24 pt and title-below 12 pt.
  out[#out + 1] = p(xe.runs(plain(need(meta, "title")):upper(), { b = true }), { jc = "center", before = 480, after = 240 })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block and certificate of service (RCFC 5.5(d)(1)(A), (e), (f); 5(d)(1)(B))
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local left = { p(xe.runs("Dated: ") .. xe.inl(need(meta, "date")), { before = BODY }) }
  local right = { p(xe.runs("Respectfully submitted,"), { before = BODY }) }
  right[#right + 1] = signed(plain(sig.signer), 0, SIG_COL, BODY)
  right[#right + 1] = p(xe.runs(plain(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do
    right[#right + 1] = p(xe.inl(l))
  end
  right[#right + 1] = p(xe.runs("Telephone: " .. plain(need(sig, "phone"))))
  right[#right + 1] = p(xe.runs("E-mail: " .. plain(need(sig, "email"))))
  -- The block never breaks across a page (typst: block(breakable: false)).
  return tbl({ TEXTW - SIG_COL, SIG_COL }, { { body = left }, { body = right } }, '<w:trPr><w:cantSplit/></w:trPr>')
end

local function certificate(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", brk = true })
  out[#out + 1] = p(xe.runs("I hereby certify that on " .. plain(need(meta, "date")) .. ", I caused a copy of the " ..
    string.lower(plain(need(meta, "title"))) .. " to be served on all parties via the Court\u{2019}s electronic case filing system."),
    { before = BODY, first = INDENT, line = BODY })
  -- the signature column of the complaint (typst: the same grid)
  out[#out + 1] = tbl({ TEXTW - SIG_COL, SIG_COL }, { { body = { p("", { before = BODY }) } },
    { body = { signed(plain(sig.signer), 0, SIG_COL, BODY), p(xe.runs(plain(sig.signer))) } } }, "<w:trPr><w:cantSplit/></w:trPr>")
  return out
end

-- ---------------------------------------------------------------------------
-- Filters
-- ---------------------------------------------------------------------------

-- Headings: "##" a centred bold capital section heading, "###" a bold sub-heading at the margin; single spaced, a
-- double line above and a single line below (typst heading-above, heading-below); kept with the text after them.
local function Header(el)
  local up = el.content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  local centred = el.level <= 2
  return xe.raw(xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(BODY, SINGLE, SINGLE), xe.ind(0, nil, 0),
    xe.jc(centred and "center" or "left") }, xe.inl(centred and up or el.content, { b = true })))
end

-- Prayer-for-relief lists. The sample types its letters and numerals (a., i.) itself, so pandoc reads them as
-- ordered-list markers and their labels would be lost: each item's label is rebuilt from the list's start number
-- and style, and every item becomes a body paragraph at its typst indent (the list indent and the 0.5 em body indent,
-- once per level), with no space of its own (typst list spacing 0).
local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function label(lst, idx)
  local a = lst.listAttributes
  local n = a.start + idx - 1
  if a.style == "LowerAlpha" then return string.char(96 + n) .. "." end
  if a.style == "UpperAlpha" then return string.char(64 + n) .. "." end
  if a.style == "LowerRoman" then return roman(n) .. "." end
  return tostring(n) .. "."
end

local function items(lst, depth, out)
  local ordered = lst.t == "OrderedList"
  for idx, item in ipairs(lst.content) do
    for _, b in ipairs(item) do
      if b.t == "Plain" or b.t == "Para" then
        local content = pandoc.Inlines({})
        if ordered then
          content:insert(pandoc.Str(label(lst, idx)))
          content:insert(pandoc.Space())
        end
        content:extend(b.content)
        out[#out + 1] = xe.raw(xe.para({ xe.style("BodyText"), xe.spacing(0, 0, BODY),
          xe.ind(depth * (LIST_IND + LIST_GAP), nil, 0), xe.jc("left") }, xe.inl(content)))
      elseif b.t == "BulletList" then
        items(b, depth + 1, out)
      elseif b.t == "OrderedList" then
        items(b, depth, out)
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

-- A body paragraph that anchors a footnote has no widow control ("Body Text Note", docx/reference.xml): its last
-- line goes to the next page with the note when the note does not fit, as typst lays it out.
local function Para(el)
  local note = false
  el:walk({ Note = function() note = true end })
  if note then return pandoc.Div({ el }, pandoc.Attr("", {}, { ["custom-style"] = "Body Text Note" })) end
end

-- The headings first (xe.inl writes their runs with the break rules), then the lists of the body (items() writes the
-- nested ones at their depth), then the break rules of typst on every run pandoc writes itself (not on the metadata:
-- the caption and signature write theirs through xe.inl and xe.runs).
local function finish(doc)
  local meta = doc.meta
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(items(b, 1, {})) do body[#body + 1] = x end
    else
      body[#body + 1] = b
    end
  end
  body = pandoc.Blocks(body):walk({ Inlines = xe.inlines })
  local blocks = {}
  for _, b in ipairs(caption(meta)) do blocks[#blocks + 1] = xe.raw(b) end
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = xe.raw(signature(meta))
  if flag(meta.certificate_of_service) then
    for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = xe.raw(b) end
  end
  doc.blocks = blocks
  -- pandoc would print title and date above the body; the caption already carries both (typst does not repeat them).
  doc.meta.title = nil
  doc.meta.date = nil
  return doc
end

return { { Header = Header, Para = Para }, { Pandoc = finish } }
