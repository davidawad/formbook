-- Brief in support of a motion, U.S. District Court for the District of Nebraska (ned), docx engine: what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/ned-motion-brief.typ does (README
-- "Engines"): the court title and caption (NECivR 10.1(a)(3)), the lead-in and the unnumbered body paragraphs, the
-- headings, the block quotations, the numbered facts lists, the signature block (NECivR 11.1(a)(1)(A)), the
-- certificate of compliance (NECivR 7.1(d)(3)) and the certificate of service (when the sample has one). The caption
-- is an OOXML table, because pandoc has no caption construct. The footer from page 2 is in docx/reference.xml; it
-- shows the paper's title and the case number from the document properties (SUBJECT, COMMENTS), which this filter
-- sets from the frontmatter. Like the typst template, the build stops when the stated word count is over 13,000
-- (NECivR 7.1(d)(1)(A)) or the sample has no compliance block. Everything printed comes from the sample's
-- frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template (the larger of the one's below and the next one's above, written as
-- the next paragraph's space before), and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, item-indent, heading-hang, quote-indent: 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360   -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET, CAP_PAD = 200, 138      -- typst caption-inset 10 pt, caption-pad (half a single line)
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local DESIGNATION = 2160                 -- typst designation-indent 1.5 in
local SIG_INDENT = 4680                  -- typst sig-indent 3.25 in
local RECIPIENT_INDENT = 720             -- typst recipient-indent 0.5 in
local WORD_LIMIT = 13000                 -- NECivR 7.1(d)(1)(A)

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, line, left, right, hanging, first, jc, keep } (a hanging indent writes no firstLine:
-- Word takes firstLine over hanging). No space after: the next paragraph's space before carries the gap.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
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
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court title and caption (NECivR 10.1(a)(3))
-- ---------------------------------------------------------------------------

local function cover(meta)
  -- The caption stands a double line below the title (Word has no space before a table: the last title line takes
  -- it as space after).
  local out = {
    p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" }),
    xe.para({ xe.spacing(0, BODY, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
      xe.runs("FOR THE DISTRICT OF NEBRASKA", { b = true })),
  }
  -- Left cell: each party's names, then its designation, indented; "v." between the parties.
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    local last = k == #parties
    left[#left + 1] = xe.para({ xe.spacing(0, last and CAP_PAD or 0, SINGLE), xe.ind(DESIGNATION, nil, 0),
      xe.jc("left") }, xe.inl(party.designation))
  end
  -- Right cell: the case number, the title.
  local right = {
    p(xe.runs("Case No. ") .. xe.inl(meta.case_number)),
    p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- The document: blocks with the space above and below them (typst block above/below)
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = cover(meta)
  -- the caption stands a single line above the text (typst: the caption block's below)
  local pend = SINGLE
  -- one paragraph: `above`/`below` as in typst, the rest as for p()
  local function add(body, o, above, below)
    o.before = math.max(pend, above or 0)
    out[#out + 1] = p(body, o)
    pend = below or 0
  end
  -- typst line-group: single lines at an indent, a blank single line above, never split (`sticky`: kept with what
  -- follows)
  local function group(indent, lines, sticky)
    for k, l in ipairs(lines) do
      add(l, { left = indent, keep = sticky or k < #lines }, k == 1 and SINGLE or 0)
    end
  end
  local function body_par(inlines, keep)
    add(xe.inl(inlines), { line = BODY, first = INDENT, keep = keep })
  end

  if meta.lead_in then body_par(meta.lead_in) end
  for i, b in ipairs(doc.blocks) do
    local last = i == #doc.blocks
    if b.t == "Header" then
      if b.level == 1 then
        local content = b.content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
        add(xe.inl(content, { b = true }), { line = BODY, jc = "center", keep = true })
      else
        add(xe.inl(b.content, { b = true, i = b.level > 2 }), { left = INDENT, hanging = INDENT, keep = true }, SINGLE)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      body_par(b.content, last)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local n = b.t == "OrderedList" and b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
        for k, ib in ipairs(item) do
          add(xe.runs(k == 1 and (lab .. "\t") or "") .. xe.inl(ib.content),
            { line = BODY, left = 2 * INDENT, hanging = INDENT })
        end
        n = n + 1
      end
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        add(xe.inl(q.content), { left = INDENT, right = INDENT }, SINGLE, SINGLE)
      end
    else
      error("ned-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  -- Signature block in NECivR 11.1(a)(1)(A) order.
  local sig = meta.signature
  local lines = { xe.runs("s/ ") .. xe.inl(sig.signer), xe.runs("Bar Number: ") .. xe.inl(sig.bar_number),
    xe.runs("Attorney for ") .. xe.inl(sig.attorney_for) }
  for _, l in ipairs(sig.firm or {}) do lines[#lines + 1] = xe.inl(l) end
  group(SIG_INDENT, lines)
  local short = { xe.runs("s/ ") .. xe.inl(sig.signer), xe.inl(sig.signer) .. xe.runs(", #") .. xe.inl(sig.bar_number) }
  local function cert_heading(t)
    add(xe.runs(t, { b = true }), { line = BODY, jc = "center", keep = true }, SINGLE)
  end

  -- Certificate of compliance (NECivR 7.1(d)(3)); the stated count must be within NECivR 7.1(d)(1)(A).
  if meta.compliance == nil then
    error("ned-motion-brief: NECivR 7.1(d)(3) requires a certificate of compliance; add a `compliance` block")
  end
  local words = plain(meta.compliance.word_count)
  local count = tonumber((words:gsub(",", "")))
  if count == nil or count > WORD_LIMIT then
    error("ned-motion-brief: NECivR 7.1(d)(1)(A) limits a supporting brief to 13,000 words; this one states " .. words)
  end
  cert_heading("CERTIFICATE OF COMPLIANCE")
  add(xe.runs("I hereby certify that this Brief complies with NECivR 7.1(d)(1). It contains " .. words ..
    " words, including the caption, headings, footnotes, and quotations, as calculated by the word-count function of ")
    .. xe.inl(meta.compliance.software) .. xe.runs("."), { line = BODY, first = INDENT, keep = true })
  group(SIG_INDENT, short)

  -- Certificate of service, when the sample has one: the sentence, each recipient's block, the signature.
  if meta.service then
    local svc = meta.service
    cert_heading("CERTIFICATE OF SERVICE")
    body_par(svc.text, true)
    for _, r in ipairs(svc.recipients) do
      local rl = {}
      for _, l in ipairs(r) do rl[#rl + 1] = xe.inl(l) end
      group(RECIPIENT_INDENT, rl, true)
    end
    group(SIG_INDENT, short)
  end

  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  -- The footer's SUBJECT and COMMENTS fields: the paper's title in capitals, the case number.
  return pandoc.Pandoc(blocks, pandoc.Meta({
    subject = pandoc.MetaInlines({ pandoc.Str(pandoc.text.upper(plain(meta.footer_title))) }),
    description = pandoc.MetaInlines({ pandoc.Str(plain(meta.case_number)) }),
  }))
end
