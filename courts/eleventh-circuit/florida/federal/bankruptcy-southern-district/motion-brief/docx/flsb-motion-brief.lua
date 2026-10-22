-- flsb-motion-brief.lua (docx engine): the S.D. Fla. Bankruptcy motion with its memorandum, filed in an adversary
-- proceeding, as Word paragraphs, so that it reads and breaks as typst/flsb-motion-brief.typ does: the court title
-- and division, the caption (L.R. 9004-1(e)(2)) as a borderless two-row table, the title, the body (headings,
-- unnumbered paragraphs, block quotations, lettered or roman parentheticals, footnotes), the signature block
-- (three inches in), the Certificate of Conferral (only when the frontmatter gives "conferral:", L.R. 9013-1(a)) and
-- the Certificate of Service with its service list. Everything printed comes from the sample's frontmatter and body:
-- no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line, 230 a 10 pt
-- footnote line), the spaces between blocks those of the typst template, and the break rules of typst on every
-- run. A paragraph that carries a footnote is left to pandoc in the reference's style of the same layout (Body
-- Text, Block Text, Lettered), so that pandoc writes the note. pandoc reads the sample without fancy lists
-- (reference.xml pandoc-from), so "(i) ..." stays a paragraph, as typst reads it.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local GAP = 240                          -- typst gap-half, 12 pt
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local QUOTE = 720                        -- typst quote-inset, 0.5 in
local SIG = 4320                         -- typst sig-indent, 3 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 288   -- typst caption-left 3.4 in, caption-gutter 0.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single lines, the first with space above it; o is passed to every line.
local function lines(list, before, out, o)
  o = o or {}
  for i, l in ipairs(list) do
    out[#out + 1] = p(xe.inl(l), { before = i == 1 and before or 0, left = o.left, keep = o.keep })
  end
  return out
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless table: widths, then rows of cells (each a list of paragraphs); rows never split.
local function tbl(widths, rows)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. table.concat(c) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- A centered bold line (court title, certificate headings).
local function centered(text, o)
  o = o or {}
  return p(xe.runs(text, { b = true }), { jc = "center", before = o.before, after = o.after, keep = o.keep })
end

-- ---------------------------------------------------------------------------
-- Cover: court, division, caption (L.R. 9004-1(e)(2)), title
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  out[#out + 1] = centered("UNITED STATES BANKRUPTCY COURT")
  out[#out + 1] = centered(plain(meta.district))
  -- the division is printed as a blank line when the sample does not name one (L.R. 9004-1(e)(2))
  local division = meta.division and plain(meta.division):upper() or "___________"
  out[#out + 1] = centered(division .. " DIVISION", { before = BODY })

  -- the caption: the debtor with the case number and chapter; the parties with the adversary number at the first
  -- party's line (typst: a two-row grid, half a double line between the rows, a double line below the division)
  local rule = string.rep("_", 36) .. "/"
  local debtor = { "In re:" }
  for _, n in ipairs(meta.debtor.names) do debtor[#debtor + 1] = n end
  debtor[#debtor + 1] = meta.debtor.designation
  local parties = {}
  for k, party in ipairs(meta.parties) do
    if k > 1 then parties[#parties + 1] = "v." end
    for _, n in ipairs(party.names) do parties[#parties + 1] = n end
    parties[#parties + 1] = party.designation
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { lines({ rule }, GAP, lines(debtor, BODY, {})), { p("", { before = BODY }) },
      lines({ "Case No. " .. plain(meta.case_number), "Chapter " .. plain(meta.chapter) }, BODY, {}) },
    { lines({ rule }, GAP, lines(parties, GAP, {})), { p("", { before = GAP }) },
      lines({ "Adv. Case No. " .. plain(meta.adv_number) }, GAP, {}) },
  })
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = BODY, after = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block, Certificate of Conferral (L.R. 9013-1(a)) and Certificate of Service; each kept on one page
-- (typst: unbreakable blocks), every paragraph but the last kept with the next.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local out = { p(xe.runs("Respectfully submitted,"), { before = BODY, left = SIG, keep = true }) }
  lines(sig.firm, GAP, out, { left = SIG, keep = true })
  local by = { "By: /s/ " .. plain(sig.signer) }
  for _, l in ipairs(sig.lines) do by[#by + 1] = l end
  lines(by, GAP, out, { left = SIG, keep = true })
  out[#out] = out[#out]:gsub(xe.KEEP, "", 1)
  return out
end

local function conferral(meta)
  if not meta.conferral then return {} end
  return {
    centered("CERTIFICATE OF CONFERRAL", { before = BODY, after = GAP, keep = true }),
    p(xe.inl(meta.conferral), { line = BODY, first = INDENT }),
  }
end

local function certificate(meta)
  local c = meta.certificate
  if not c then return {} end
  local out = { centered("CERTIFICATE OF SERVICE", { before = BODY, after = GAP, keep = true }) }
  out[#out + 1] = p(xe.runs("I HEREBY CERTIFY that a true and correct copy of the foregoing was served electronically " ..
    "via CM/ECF, Email, and/or via U.S. Mail, as indicated on the attached service list on this ") ..
    xe.inl(c.date) .. xe.runs("."), { first = INDENT, keep = true })
  lines({ "By: /s/ " .. plain(c.signer), c.signer }, GAP, out, { left = SIG, keep = true })
  out[#out + 1] = centered("SERVICE LIST", { before = BODY, after = GAP, keep = true })
  lines(c.service_list, 0, out, { keep = true })
  -- the last line of the certificate keeps nothing after it
  out[#out] = out[#out]:gsub(xe.KEEP, "", 1)
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings (single-spaced): 12 pt, 12 pt above and below, kept with the text after them; level 1 centered bold
-- capitals, level 2 bold, level 3 bold italic. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  if b.level == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local runs = xe.inl(content, { b = true, i = b.level >= 3 })
  -- the Heading 1 style's capitals off: the text is already in capitals
  runs = runs:gsub("<w:rPr>(.-)</w:rPr>", function(x)
    local at = x:find("<w:sz", 1, true) or x:find("<w:u ", 1, true) or x:find("<w:bdr", 1, true) or (#x + 1)
    return "<w:rPr>" .. x:sub(1, at - 1) .. '<w:caps w:val="0"/>' .. x:sub(at) .. "</w:rPr>"
  end)
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(b.level, 3)), xe.KEEP, xe.spacing(GAP, GAP, SINGLE),
    xe.ind(0, nil, 0), xe.jc(b.level == 1 and "center" or "left") }, runs))
end

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- A paragraph in its layout: raw when it carries no footnote; else pandoc writes it (and its note) in `style`.
local function body_block(para, style, o)
  if has_note(para) then
    if o.keep then error("flsb-motion-brief.lua: the last paragraph carries a footnote (no keep for it)") end
    local b = pandoc.Para(para.content):walk({ Inlines = xe.inlines })
    return pandoc.Div({ b }, { ["custom-style"] = style })
  end
  return xe.raw(p(xe.inl(para.content), o))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("¶¶ 20"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = xe.raw(x) end
  local blocks = doc.blocks
  for k, b in ipairs(blocks) do
    -- the last block stays on one page with the signature block (typst: one unbreakable block)
    local last = k == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        out[#out + 1] = body_block(q, "Block Text", { before = GAP, after = GAP, left = QUOTE, right = QUOTE, keep = last })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):match("^%([a-z]+%)%s") then
        out[#out + 1] = body_block(b, "Lettered", { line = BODY, left = INDENT, keep = last })
      else
        out[#out + 1] = body_block(b, "Body Text", { line = BODY, first = INDENT, keep = last })
      end
    else
      error("flsb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  for _, part in ipairs({ signature(meta), conferral(meta), certificate(meta) }) do
    for _, x in ipairs(part) do out[#out + 1] = xe.raw(x) end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
