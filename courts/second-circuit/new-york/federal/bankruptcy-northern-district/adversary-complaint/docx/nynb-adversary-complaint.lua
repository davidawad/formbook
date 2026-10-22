-- nynb-adversary-complaint.lua (docx engine): the N.D.N.Y. bankruptcy adversary complaint as Word paragraphs, so that
-- it reads and breaks as typst/nynb-adversary-complaint.typ does: the counsel lines (when given), the court title, the
-- bankruptcy caption and the adversary caption (the party column ruled on its right and bottom, the case numbers
-- beside it), the title, the body (the preamble and a WHEREFORE clause unnumbered, every other paragraph numbered 1.,
-- 2., ... per FRCP 10(b) via FRBP 7010, the number in a 0.5 in box after the 0.5 in indent; headings; the prayer's
-- "(a) ..." items indented 0.5 in) and the signature block ("Dated" beside the signing lines). Everything printed
-- comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template (the larger of the one's below and the next one's above), and the break
-- rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local GAP = 480                          -- typst gap, 24 pt
local SEP = 120                          -- typst caption-sep, 6 pt
local TEXTW = 9360                       -- 6.5 in
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUM_TAB = 1440                     -- typst para-indent + num-box: the text after the number starts at 1 in
local PRAYER = 720                       -- typst prayer-indent, 0.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_RIGHT_IND = 504                -- typst caption-gutter + caption-inset, 0.35 in
local RULE_R = 200                       -- typst rule-pad 10 pt to the right rule
local RULE_B = 185                       -- typst rule-pad 10 pt to the bottom rule, less the 0.75 pt rule LibreOffice
                                         -- adds to the row
local SIG_LEFT = 4320                    -- typst sig-left, 3 in
local SIG_GUTTER = 360                   -- typst caption-gutter, 0.25 in

local UNNUMBERED = "<!-- unnumbered -->"

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

local function tc(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- A one-row borderless table of the text width, its row never split across pages.
local function tbl(widths, cells)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

-- Single-spaced lines (typst line-stack): each value (runs) a paragraph; an empty one keeps its full height.
local function stack(values)
  local out = {}
  for _, v in ipairs(values) do out[#out + 1] = p(v) end
  return table.concat(out)
end

-- typst caption-grid: the left column ruled on its right and bottom, the right column beside it.
local function caption_table(left, right)
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. RULE_B .. '" w:type="dxa"/><w:right w:w="' .. RULE_R .. '" w:type="dxa"/></w:tcMar>'
  return tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    tc(CAP_LEFT, rule, stack(left)),
    tc(TEXTW - CAP_LEFT, '<w:tcMar><w:left w:w="' .. CAP_RIGHT_IND .. '" w:type="dxa"/></w:tcMar>', stack(right)),
  })
end

local function list(meta_list)
  local out = {}
  for _, v in ipairs(meta_list or {}) do out[#out + 1] = xe.inl(v) end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover (LBR 9004-1(c); FRBP 9004(b); FRBP 7010 / Official Form 416A)
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  if type(meta.counsel) == "table" and #meta.counsel > 0 then
    local c = list(meta.counsel)
    for i, x in ipairs(c) do out[#out + 1] = p(x, { after = i == #c and GAP or 0 }) end
  end
  out[#out + 1] = p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("NORTHERN DISTRICT OF NEW YORK", { b = true }), { jc = "center", after = GAP })
  local left = { xe.runs("In re:") }
  for _, x in ipairs(list(meta.debtor.names)) do left[#left + 1] = x end
  left[#left + 1] = xe.runs("(") .. xe.inl(meta.debtor.tin) .. xe.runs(")")
  left[#left + 1] = xe.runs("Debtor.")
  local right = {}
  if type(meta.hearing) == "table" and meta.hearing.date then
    right[#right + 1] = xe.runs("Hearing: ") .. xe.inl(meta.hearing.date)
    right[#right + 1] = xe.runs("Time: ") .. xe.inl(meta.hearing.time)
    right[#right + 1] = xe.runs("Location: ") .. xe.inl(meta.hearing.location)
  end
  right[#right + 1] = xe.runs("Case No. ") .. xe.inl(meta.case_number)
  right[#right + 1] = xe.runs("Chapter ") .. xe.inl(meta.chapter)
  out[#out + 1] = caption_table(left, right)
  -- typst: 6 pt between the two captions (and two Word tables never touch)
  out[#out + 1] = p("", { line = SEP })
  local rows = {}
  for k, pt in ipairs(meta.adversary.parties) do
    if k > 1 then rows[#rows + 1] = xe.runs("v.") end
    for _, x in ipairs(list(pt.names)) do rows[#rows + 1] = x end
    rows[#rows + 1] = xe.inl(pt.designation)
  end
  out[#out + 1] = caption_table(rows, { xe.runs("Adv. Pro. No. ") .. xe.inl(meta.adversary.number) })
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = GAP, after = GAP })
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" beside "Respectfully submitted," the firm, a blank line, "By: /s/" and the lines
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  -- typst: the block stands 24 pt below the text and is not split; the line before it keeps with it
  out[#out + 1] = p("", { line = GAP, keep = true })
  local sig = meta.signature
  local right = { xe.runs("Respectfully submitted,") }
  for _, x in ipairs(list(sig.firm)) do right[#right + 1] = x end
  right[#right + 1] = ""
  right[#right + 1] = xe.runs("By: /s/ ") .. xe.inl(sig.signer)
  for _, x in ipairs(list(sig.lines)) do right[#right + 1] = x end
  out[#out + 1] = tbl({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER }, {
    tc(SIG_LEFT, nil, stack({ xe.runs("Dated: ") .. xe.inl(meta.dated) })),
    tc(SIG_GUTTER, nil, p("")),
    tc(TEXTW - SIG_LEFT - SIG_GUTTER, nil, stack(right)),
  })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 151"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

local function is_item(b)
  return b ~= nil and (b.t == "Para" or b.t == "Plain") and plain(b):match("^%([a-z]%)%s") ~= nil
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  -- the units typst reads: a "<!-- unnumbered -->" comment marks the paragraph after it
  local units = {}
  local mark = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "RawBlock" and b.text:match("^%s*" .. UNNUMBERED:gsub("%p", "%%%0") .. "%s*$") then
      mark = true
    else
      units[#units + 1] = { b = b, unnumbered = mark }
      mark = false
    end
  end
  local pre = tonumber(plain(meta.preamble))
  local numbered, n = false, 0
  for i, u in ipairs(units) do
    local b, nxt = u.b, units[i + 1] and units[i + 1].b
    if pre and i > pre then numbered = true end
    -- a lead-in keeps with the first lettered item; the last item keeps with the signature
    local keep = (is_item(nxt) and not is_item(b)) or (nxt == nil and is_item(b))
    if b.t == "Header" then
      numbered = true
      out[#out + 1] = p(xe.inl(b.content, { b = true }), { before = GAP, line = BODY, keep = true,
        jc = b.level == 1 and "center" or "left" })
    elseif b.t == "Para" or b.t == "Plain" then
      if is_item(b) and not u.unnumbered then
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, left = PRAYER, keep = keep })
      elseif u.unnumbered or not numbered then
        out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = keep })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = NUM_TAB,
          keep = keep })
      end
    else
      error("nynb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  signature(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
