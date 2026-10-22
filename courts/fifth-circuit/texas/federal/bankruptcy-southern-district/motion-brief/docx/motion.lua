-- Motion with integrated memorandum, S.D. Tex. bankruptcy court, docx engine (docs/DOCX.md): what the Word output
-- adds to pandoc's conversion, so that it reads and breaks as typst/txsb-motion-brief.typ does: the court name lines,
-- the caption (a table: the party column with a rule at its right and bottom, the case block at the right) with the
-- debtor footnote, the title, the BLR 9013-1 notice, the lead-in, the numbered paragraphs (FRCP 10(b)), the
-- lettered lists, the unnumbered ">" paragraphs, the headings, the signature block and the certificate of service
-- (BLR 9013-1(f)). Content-agnostic: every case word comes from the sample's frontmatter and body; the fixed text is
-- the court's own heading and the rule's notice and certificate wording. Caption, notice and signature lines are
-- set as written ($FORMBOOK_META, fb render), as typst sets them.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line, 230 the
-- footnote), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276                     -- typst pitch-double, pitch-single
local NOTICE_GAP = 120                            -- typst notice-gap 6 pt
local INDENT = 720                                -- typst para-indent and item-indent, 0.5 in
local ITEM_TEXT = 1296                            -- typst item-indent + item-label, 0.9 in
local TEXTW = 9360                                -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360            -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET, CAP_PAD = 240, 185               -- typst caption-inset 12 pt, caption-pad 10 pt less the 0.75 pt
                                                  -- rule, which Word sets below the cell and typst on its edge
local RIGHT_INSET = 144                           -- typst right-inset 0.1 in
local DESIGNATION, VERSUS = 1800, 720             -- typst designation-indent 1.25 in, versus-indent 0.5 in
local COURT = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF TEXAS" }

-- BLR 9013-1(b): required immediately below the title of every pleading that seeks an order (verbatim).
local NEGATIVE_NOTICE = {
  "This motion seeks an order that may adversely affect you. If you oppose the motion, you should immediately contact the moving party to resolve the dispute. If you and the moving party cannot agree, you must file a response and send a copy to the moving party. You must file and serve your response within 21 days of the date this was served on you. Your response must state why the motion should not be granted. If you do not file a timely response, the relief may be granted without further notice to you. If you oppose the motion and have not reached an agreement, you must attend the hearing. Unless the parties agree otherwise, the court may consider evidence at the hearing and may decide the motion at the hearing.",
  "Represented parties should act through their attorney.",
}
-- BLR 9013-1(i): added to the notice of an emergency motion, which must also have "Emergency" in its title (verbatim).
local EMERGENCY_NOTICE = "Emergency relief has been requested. If the Court considers the motion on an emergency basis, then you will have less than 21 days to answer. If you object to the requested relief or if you believe that the emergency consideration is not warranted, you should file an immediate response."

local function read_file(path)
  if not path then return nil end
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (fb render), where pandoc's metadata would read each string as markdown.
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

-- A frontmatter string as inlines: its markdown read as pandoc reads the body (no fancy list markers).
local function md(s)
  local b = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS).blocks[1]
  if b == nil then return pandoc.Inlines({}) end
  if b.t == "Para" or b.t == "Plain" then return b.content end
  return pandoc.Inlines({ pandoc.Str(s) })
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep }.
local function props(o)
  local x = {}
  if o.keep then x[#x + 1] = xe.KEEP end
  if o.tab then x[#x + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  x[#x + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  x[#x + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  x[#x + 1] = xe.jc(o.jc or "left")
  return x
end

local function p(body, o)
  return xe.para(props(o or {}), body)
end

local function tbl_open(widths)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
end

local function tc(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. table.concat(body) .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name lines, caption, title
-- ---------------------------------------------------------------------------

-- The cover as a list of pandoc blocks. The caption table is raw WordprocessingML, except the debtor name line that
-- carries the footnote: pandoc writes that paragraph (in the "Caption Line" style, docx/reference.xml), so the note
-- is a Word footnote; the raw blocks around it open and close the table and its cell.
local function cover()
  local out = {}
  local lines = { COURT[1], COURT[2], pandoc.text.upper(RAW.division) }
  for i, l in ipairs(lines) do
    -- the caption stands a single line below (typst: the caption block's above); Word has no space before a table
    out[#out + 1] = xe.raw(p(xe.runs(l, { b = true }), { jc = "center", after = i == #lines and SINGLE or 0 }))
  end
  local c = RAW.caption
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  local open = tbl_open({ CAP_LEFT, TEXTW - CAP_LEFT }) .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT ..
    '" w:type="dxa"/><w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
    '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
  local head = { p(xe.runs("In re:")) }
  local noted
  for i, n in ipairs(c.debtor_names) do
    if i == #c.debtor_names and c.debtor_footnote then
      noted = pandoc.Div({ pandoc.Para({ pandoc.Str(n), pandoc.Note({ pandoc.Para(xe.inlines(md(c.debtor_footnote))) }) }) },
        { ["custom-style"] = "Caption Line" })
    else
      head[#head + 1] = p(xe.runs(n))
    end
  end
  local tail = { p(xe.runs(c.debtor_designation), { left = DESIGNATION }) }
  for i, n in ipairs(c.plaintiff_names) do tail[#tail + 1] = p(xe.runs(n), { before = i == 1 and SINGLE or 0 }) end
  tail[#tail + 1] = p(xe.runs(c.plaintiff_designation), { left = DESIGNATION })
  tail[#tail + 1] = p(xe.runs("v."), { left = VERSUS })
  for _, n in ipairs(c.defendant_names) do tail[#tail + 1] = p(xe.runs(n)) end
  -- the bottom rule stands the pad off the last line (space after it)
  tail[#tail + 1] = p(xe.runs(c.defendant_designation), { left = DESIGNATION, after = CAP_PAD })
  -- Right cell: chapter, case number, joint administration, adversary number; "" a blank line.
  local rows = { RAW.chapter, "", RAW.case_number }
  if RAW.joint_admin then rows[#rows + 1] = RAW.joint_admin end
  rows[#rows + 1] = ""
  rows[#rows + 1] = ""
  rows[#rows + 1] = RAW.adversary_number
  local right = {}
  for _, r in ipairs(rows) do right[#right + 1] = p(xe.runs(r)) end
  local close = table.concat(tail) .. '</w:tc>' ..
    tc(TEXTW - CAP_LEFT, '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', right) ..
    '</w:tr></w:tbl>'
  if noted then
    out[#out + 1] = xe.raw(open .. table.concat(head))
    out[#out + 1] = noted
    out[#out + 1] = xe.raw(close)
  else
    out[#out + 1] = xe.raw(open .. table.concat(head) .. close)
  end
  out[#out + 1] = xe.raw(p(xe.runs(pandoc.text.upper(RAW.title), { b = true }),
    { jc = "center", before = SINGLE, after = SINGLE }))
  return out
end

-- The BLR 9013-1 notice: (b) always, (i) for an emergency motion, (c) the hearing line when there is one; single
-- spaced, its paragraphs a little apart, a blank single line below it.
local function notice(out)
  local ps = { NEGATIVE_NOTICE[1], NEGATIVE_NOTICE[2] }
  if RAW.emergency then
    ps[#ps + 1] = RAW.relief_by
    ps[#ps + 1] = EMERGENCY_NOTICE
  end
  if RAW.hearing then
    local h = RAW.hearing
    ps[#ps + 1] = "There will be a hearing on this motion on " .. h.date .. " at " .. h.time .. " in courtroom " ..
      h.courtroom .. ", " .. h.address .. "."
  end
  for i, s in ipairs(ps) do
    out[#out + 1] = xe.raw(p(xe.runs(s), { before = i > 1 and NOTICE_GAP or 0, after = i == #ps and SINGLE or 0 }))
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, keep)
  local q = { line = BODY, first = INDENT, keep = keep }
  if label == nil then return p(xe.inl(inlines), q) end
  q.tab = 2 * INDENT
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), q)
end

-- Headings at the body pitch, bold, as written: levels 1 and 2 centered, level 3 at the margin; kept with the text.
local function heading(el)
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(el.content, { b = true }))
end

-- Lists, lettered (a), (b), ... (typst enum "(a)"): the letter half an inch in, the text hanging after its box.
local function items(list, out)
  for j, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("motion.lua: a list item holds one paragraph")
    end
    local lab = list.t == "OrderedList" and ("(" .. string.char(96 + j) .. ")") or "\u{2022}"
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
      { line = BODY, left = ITEM_TEXT, hanging = ITEM_TEXT - INDENT })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 361"), as typst boxes "§ 361" (xe.inl binds a single one).
local function bind_doubled(ils)
  for i = 1, #ils - 1 do
    if ils[i].t == "Str" and ils[i].text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and ils[i + 1].t == "Space" then
      ils[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return ils
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated:" at the left; "Respectfully submitted," and the signing blocks at the right, a single
-- line apart around "-and-"; the row never splits. The space above it is a 1 pt paragraph kept with the table, its
-- space before the rest: at the top of a page LibreOffice drops a paragraph's space before, as typst drops a
-- block's, but keeps it in a cell.
-- ---------------------------------------------------------------------------

-- Each further signing block follows at the signature column, "-and-" a single line above it, kept whole on one page
-- (typst: one unbreakable block each).
local function signature()
  local blocks = RAW.signature.blocks
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(blocks[1]) do right[#right + 1] = p(xe.runs(l), { before = i == 1 and SINGLE or 0 }) end
  local out = { p("", { keep = true, before = SINGLE - 20, line = 20 }) ..
    tbl_open({ CAP_LEFT, TEXTW - CAP_LEFT }) .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    tc(CAP_LEFT, nil, { p(xe.runs("Dated: " .. RAW.dated)) }) ..
    tc(TEXTW - CAP_LEFT, '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', right) ..
    '</w:tr></w:tbl>' }
  for k = 2, #blocks do
    out[#out + 1] = p(xe.runs("-and-"), { before = SINGLE, left = CAP_LEFT + CAP_GUTTER, keep = true })
    for i, l in ipairs(blocks[k]) do
      out[#out + 1] = p(xe.runs(l), { before = i == 1 and SINGLE or 0, left = CAP_LEFT + CAP_GUTTER, keep = i < #blocks[k] })
    end
  end
  return table.concat(out)
end

-- BLR 9013-1(f): the certificate of service (the ECF form's wording; date and signer from the sample). A blank
-- double line above it, the heading and the statement at the double pitch, the signer's lines a single line below
-- at the signature column; kept whole on one page.
local function certificate()
  local c = RAW.certificate
  if c == nil then return "" end
  local x = { p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { line = BODY, before = BODY, jc = "center", keep = true }),
    p(xe.runs("I certify that on " .. c.date .. ", I caused a copy of the foregoing document to be served by the " ..
      "Electronic Case Filing System for the United States Bankruptcy Court for the Southern District of Texas."),
      { line = BODY, first = INDENT, keep = true }) }
  for i, l in ipairs(c.signature) do
    x[#x + 1] = p(xe.runs(l), { before = i == 1 and SINGLE or 0, left = CAP_LEFT + CAP_GUTTER, keep = i < #c.signature })
  end
  return table.concat(x)
end

function Pandoc(doc)
  doc.blocks = doc.blocks:walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Str = breaks })
  local out = cover()
  notice(out)
  local body = {}
  if RAW.lead_in then body[#body + 1] = body_par(nil, md(RAW.lead_in)) end
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    -- the last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
    local last = i == #blocks
    if b.t == "Header" then
      body[#body + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, body)
    elseif b.t == "BlockQuote" then
      -- an unnumbered paragraph (a clause the filing does not number)
      for j, q in ipairs(b.content) do
        body[#body + 1] = body_par(nil, q.content, last and j == #b.content)
      end
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      body[#body + 1] = body_par(n .. ".", b.content, last)
    else
      error("motion.lua: unsupported block " .. b.t)
    end
  end
  body[#body + 1] = signature()
  body[#body + 1] = certificate()
  out[#out + 1] = xe.raw(table.concat(body))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
