-- Memorandum brief in support of a motion, S.D. Miss. (mssd), docx engine: what the Word output adds to pandoc's
-- conversion, so that it reads and breaks as typst/mssd-motion-brief.typ does: the court title and caption, the
-- title of the paper, the headings, the list items, the signature block (L.U.Civ.R. 11(a)) and the certificate of
-- service. pandoc writes the body paragraphs (style Body Text) and their footnotes (Footnote Text, 11 pt:
-- 7(b)(5)(B)). Everything printed comes from the sample's frontmatter and body: no case text lives in this file. The
-- caption is an OOXML table. The 35-page limit of L.U.Civ.R. 7(b)(5) is asserted by the typst engine.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 5184, 144   -- typst caption-left 3.6 in, caption-gutter 0.1 in
local SIG_LEFT = 4320                    -- typst sig-left 3 in
local HEAD = 276                         -- typst heading-space

local REQUIRED_SIG = { "signer", "bar_no", "firm", "address", "telephone", "fax", "email" }

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { style, keep, before, after, line, left, hanging, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = (o.keep == "next" and "<w:keepNext/>") or (o.keep == "lines" and xe.LINES) or xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless one-row table; cells = { { pr, body = { paragraphs } }, ... }.
local function tbl(widths, cells)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title of the paper. The title's space below is an empty paragraph of that height when
-- pandoc's body paragraph follows (they carry no space of their own); a heading after it brings the same space.
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  for k, l in ipairs(meta.court) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }),
      { jc = "center", after = k == #meta.court and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation; "v." between the parties, a blank line above and below.
  -- Right cell: "CIVIL ACTION NO." and the case number from the line of the first "v.".
  local left, row, v_row, pending = {}, 0, nil, 0
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then
      if not v_row then v_row = row + 1 end
      left[#left + 1] = p(xe.runs("v."), { before = SINGLE })
      row = row + 3
      pending = SINGLE
    end
    local lines = {}
    for _, n in ipairs(party.names) do lines[#lines + 1] = n end
    lines[#lines + 1] = party.designation
    for _, n in ipairs(lines) do
      left[#left + 1] = p(xe.inl(n), { before = pending })
      pending = 0
      row = row + 1
    end
  end
  local right = {
    p(xe.runs("CIVIL ACTION NO."), { before = (v_row or 0) * SINGLE }),
    p(xe.inl(meta.case_number)),
  }
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  out[#out + 1] = p(xe.inl(pandoc.text.upper(plain(meta.brief_title)), { b = true, u = true }),
    { jc = "center", before = BODY })
end

-- ---------------------------------------------------------------------------
-- Signature block (L.U.Civ.R. 11(a)) and certificate of service; each stays whole.
-- ---------------------------------------------------------------------------

local function keep_all(lines, out)
  for k, l in ipairs(lines) do
    local o = l.o
    o.keep = k < #lines and (o.keep or "next") or "lines"
    out[#out + 1] = p(l.body, o)
  end
end

local function signature(meta, out)
  local s = meta.signature
  if not s then error("mssd-motion-brief: the sample needs a signature block (L.U.Civ.R. 11(a))") end
  for _, k in ipairs(REQUIRED_SIG) do
    if s[k] == nil then error("mssd-motion-brief: signature." .. k .. " is required (L.U.Civ.R. 11(a))") end
  end
  local lines = {}
  local function add(body, before) lines[#lines + 1] = { body = body, o = { before = before or 0, left = SIG_LEFT } } end
  if s.date then
    lines[1] = { body = xe.runs("Respectfully submitted, this the ") .. xe.inl(s.date), o = { first = INDENT } }
  end
  add(xe.inl(s.firm), s.date and SINGLE or 0)
  for _, a in ipairs(s.address) do add(xe.inl(a)) end
  add(xe.runs("Telephone: " .. plain(s.telephone)))
  add(xe.runs("Facsimile: " .. plain(s.fax)))
  add(xe.runs("s/ ") .. xe.inl(s.signer), SINGLE)
  add(xe.runs(pandoc.text.upper(plain(s.signer)) .. ", " .. plain(s.bar_no)))
  add(xe.runs("Email: " .. plain(s.email)))
  lines[1].o.before = BODY
  keep_all(lines, out)
end

local function certificate(meta, out)
  local c = meta.certificate
  if not c then return end
  local lines = {
    { body = xe.runs("CERTIFICATE OF SERVICE", { b = true, u = true }), o = { before = BODY, jc = "center",
      keep = true } },
    { body = xe.inl(c.text), o = { before = HEAD, line = BODY, first = INDENT, keep = true } },
    { body = xe.runs("s/ ") .. xe.inl(c.signer), o = { before = SINGLE, left = SIG_LEFT } },
    { body = xe.runs(pandoc.text.upper(plain(c.signer)) .. ", " .. plain(c.bar_no)), o = { left = SIG_LEFT } },
  }
  keep_all(lines, out)
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings single-spaced, a single line above and below; level 1 centered, bold, underlined capitals, level 2 bold
-- at the left; kept with the block after them. A heading right after another heading or the title takes no space
-- above (the space below that one stands).
local function heading(el, after_space)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return p(xe.inl(content, { b = true, u = el.level == 1 }), { style = "Heading" .. math.min(el.level, 2),
    keep = true, before = after_space and 0 or HEAD, after = HEAD, jc = el.level == 1 and "center" or "left" })
end

-- List items: the number or bullet in a box of the indent, the text hanging after it (typst xengine lists).
local function list(b, out)
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  for _, item in ipairs(b.content) do
    for k, blk in ipairs(item) do
      local lab = ""
      if k == 1 then lab = (b.t == "OrderedList" and (n .. ".") or "\u{2022}") .. "\t" end
      out[#out + 1] = p(xe.runs(lab) .. xe.inl(blk.content), { line = BODY, left = INDENT, hanging = INDENT })
    end
    n = n + 1
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space), none between a doubled section sign and its number (typst boxes the
-- last sign with the number).
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end
local function signs(inls)
  for i = 1, #inls - 1 do
    local a, b = inls[i], inls[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then inls[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return inls
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  -- the body inlines pandoc writes itself; the metadata strings stay text (xe.inl applies the same rules to them)
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local raw = {}
  cover(meta, raw)
  local out = { xe.raw(table.concat(raw)) }
  local nb = #doc.blocks   -- the last block, when a paragraph, stays with the signature (typst brief-body)
  local last_para = (nb > 0 and (doc.blocks[nb].t == "Para" or doc.blocks[nb].t == "Plain")) and nb or 0
  local first = true          -- the title's space below stands before this block
  local after_space = false   -- a heading's space below stands before this block
  for i, b in ipairs(doc.blocks) do
    if first and b.t ~= "Header" then
      out[#out + 1] = xe.raw(p("", { line = HEAD }))
    end
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b, after_space))
      after_space = true
    elseif b.t == "Para" or b.t == "Plain" then
      -- a paragraph that anchors a footnote has no widow control (typst: no widow or orphan costs for it); the last
      -- one is kept whole and with the signature block (typst: one unbreakable block)
      local noted = false
      b.content:walk({ Note = function() noted = true end })
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] =
        (i == last_para and "Body Keep") or (noted and "Body Text Noted") or "Body Text" })
      after_space = false
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local l = {}
      list(b, l)
      out[#out + 1] = xe.raw(table.concat(l))
      after_space = false
    else
      error("mssd-motion-brief.lua: unsupported block " .. b.t)
    end
    first = false
  end
  local tail = {}
  signature(meta, tail)
  certificate(meta, tail)
  out[#out + 1] = xe.raw(table.concat(tail))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
