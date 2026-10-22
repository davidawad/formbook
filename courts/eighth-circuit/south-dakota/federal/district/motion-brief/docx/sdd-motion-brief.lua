-- Brief in support of a motion for the U.S. District Court for the District of South Dakota (sdd), docx engine:
-- what the Word output adds to pandoc's conversion, so that it reads and breaks as typst/sdd-motion-brief.typ does:
-- the court title and caption (LR 10.1(A)), the headings (LR 83.4: single-spaced), the lettered list items, the
-- signature block (LR 10.1(B), LR 5.1(A)(4)) and the certificate of service on its own page (LR 5.1(A)(3)).
-- pandoc writes the body paragraphs (style Body Text, the last one Body Keep) and their footnotes (Footnote Text).
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file. Caption and
-- signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360   -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET = 240                    -- typst caption-inset 12 pt
local CAP_PAD = 123                      -- typst caption-pad (half a single line, 138) less the 0.75 pt rule, which
                                         -- LibreOffice adds to the cell height
local RIGHT_INSET = 216                  -- typst right-inset 0.15 in
local SIG_LEFT, SIG_GUTTER = 3744, 288   -- typst sig-left 2.6 in, sig-gutter 0.2 in
local HEAD = 240                         -- typst heading-space 12 pt
local RECIP = 240                        -- typst recipient-space 12 pt

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { style, keep, brk, before, after, line, left, hanging, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = o.keep == "next" and "<w:keepNext/>" or xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

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
-- Court title and caption (LR 10.1(A)); the double line below the caption is an empty line box of that height
-- (the body paragraphs are pandoc's, which carry no space of their own).
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  local lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF SOUTH DAKOTA" }
  if meta.division then lines[#lines + 1] = pandoc.text.upper(plain(meta.division)) end
  for k, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = k == #lines and BODY or 0 })
  end
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_PAD or 0 })
  end
  local right = {
    p(xe.runs("Case No. " .. plain(meta.case_number))),
    p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  out[#out + 1] = p("", { line = BODY })
end

-- ---------------------------------------------------------------------------
-- Signature and certificate of service
-- ---------------------------------------------------------------------------

-- The signer's lines (LR 10.1(B), LR 5.1(A)(4)): the firm, "By: /s/" and the typed name, address, telephone, e-mail.
local function signer_lines(sig)
  local right = {}
  for _, l in ipairs(sig.firm or {}) do right[#right + 1] = p(xe.inl(l)) end
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = sig.firm and SINGLE or 0 })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  return right
end

-- "Dated" at the left, the signer at the right; the row never splits. The double line above it is Body Keep's
-- space after (the paragraph before it).
local function signature(meta)
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) } },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = signer_lines(meta.signature) } })
end

-- On its own page: the heading, the statement, each person served (kept together), the signer.
local function certificate(c, out)
  out[#out + 1] = xe.para({ xe.style("Heading1"), xe.KEEP, xe.BREAK, xe.spacing(0, HEAD, SINGLE), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.runs("CERTIFICATE OF SERVICE", { b = true }))
  out[#out + 1] = p(xe.inl(c.text), { line = BODY, first = INDENT })
  for k, r in ipairs(c.recipients) do
    for j, l in ipairs(r) do
      local last = j == #r
      out[#out + 1] = p(xe.inl(l), { before = j == 1 and RECIP or 0, keep = not last and "next" or nil,
        after = (last and k == #c.recipients) and RECIP or 0 })
    end
  end
  out[#out + 1] = tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = { p("") } },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = signer_lines({ signer = c.signer }) } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings single-spaced (LR 83.4), 12 pt above and below; level 1 centered capitals, level 2 bold, level 3 bold
-- italic; kept with the block after them. A heading right after another heading or the caption takes no space
-- above (the space below that one stands).
local function heading(el, after_space)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. el.level), xe.KEEP, xe.spacing(after_space and 0 or HEAD, HEAD, SINGLE),
    xe.ind(0, nil, 0), xe.jc(el.level == 1 and "center" or "left") },
    xe.inl(content, { b = true, i = el.level >= 3 }))
end

-- List items, lettered (a), (b), ... or bulleted: the label in a box of the indent, the text hanging after it.
local function list(b, out)
  for j, item in ipairs(b.content) do
    for k, blk in ipairs(item) do
      local lab = ""
      if k == 1 then lab = (b.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")") or "\u{2022}") .. "\t" end
      out[#out + 1] = p(xe.runs(lab) .. xe.inl(blk.content), { line = BODY, left = INDENT, hanging = INDENT })
    end
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
  local blocks = doc.blocks
  local last_para = 0
  for i, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then last_para = i end
  end
  local after_space = true   -- the caption's double line, or a heading's space below, stands before this block
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b, after_space))
      after_space = true
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) },
        { ["custom-style"] = (i == last_para and meta.signature) and "Body Keep" or "Body Text" })
      after_space = false
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local l = {}
      list(b, l)
      out[#out + 1] = xe.raw(table.concat(l))
      after_space = false
    else
      error("sdd-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  if meta.signature then out[#out + 1] = xe.raw(signature(meta)) end
  if meta.certificate_of_service then
    local c = {}
    certificate(meta.certificate_of_service, c)
    out[#out + 1] = xe.raw(table.concat(c))
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
