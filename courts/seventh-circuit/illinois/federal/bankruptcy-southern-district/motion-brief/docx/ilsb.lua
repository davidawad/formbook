-- ilsb.lua (docx engine): the S.D. Ill. brief in support of a motion as Word paragraphs, so that it reads and breaks
-- as ../typst/ilsb-motion-brief.typ (the reference for the form) does:
--   * the court title, the caption (the same form as the adversary complaint: a table, the debtor and the parties on
--     the left with a rule on the right and bottom of their column, the case number, chapter and adversary number on
--     the right) and the title, written here;
--   * the body as written: headings written here (not numbered: the author types any labels); paragraphs and their
--     footnotes left to pandoc in the Body Text and Footnote Text styles of docx/reference.xml (Body Text Note for a
--     paragraph that anchors a footnote); block quotations as Block Text; bullets as List Item;
--   * "Dated" and the signature in the right-hand column with the attorney block under it in that column (L.R.
--     9011(A); as filed), kept together; the certificate of service on a page of its own when the frontmatter has one
--     (L.R. 9013-2(A)).
-- Every case word comes from the YAML frontmatter or the body. No coordinates, no forced line breaks.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 276, 240  -- typst pitch-body, pitch-single, gap (half a body line)
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 5184                    -- typst caption-left 3.6 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local CASE_INSET = 504                   -- typst case-inset 0.35 in
local SIG = 4320                         -- typst sig-column 3 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(v)
  local out = {}
  for _, x in ipairs(v or {}) do out[#out + 1] = x end
  return out
end

local function upper(x)
  return pandoc.Inlines(x):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, brk, tab } (keep: with the next paragraph and its
-- lines together; brk: a page break before it; tab: a left tab stop, twips). Single-spaced unless o.line.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Frontmatter lines, one single-spaced paragraph each; an empty line is a single line of space before the next one
-- (typst line-list). Returns the paragraphs' { body, before } in order.
local function line_list(items, above)
  local out, skip = {}, above or 0
  for _, i in ipairs(list(items)) do
    if plain(i) == "" then
      skip = math.max(skip, SINGLE)
    else
      out[#out + 1] = { xe.inl(i), skip }
      skip = 0
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title (Form 416; L.R. 5005-1(B)(2))
-- ---------------------------------------------------------------------------

local function cover(m, out)
  local court = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF ILLINOIS" }
  if plain(m.division) ~= "" then court[#court + 1] = pandoc.text.upper(plain(m.division)) end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  -- the party column: In re, the debtors and their designation; each side's names (a single line above them) and
  -- designation, "v." between the sides (a single line above it); the last line takes the space above the rule
  local left = { { xe.runs("In re:"), 0 } }
  for _, d in ipairs(list(m.debtors)) do left[#left + 1] = { xe.inl(d), 0 } end
  left[#left + 1] = { xe.inl(m.debtor_designation), 0 }
  for k, side in ipairs(list(m.caption.parties)) do
    if k > 1 then left[#left + 1] = { xe.runs("v."), SINGLE } end
    for j, n in ipairs(list(side.names)) do left[#left + 1] = { xe.inl(n), j == 1 and SINGLE or 0 } end
    left[#left + 1] = { xe.inl(side.designation), 0 }
  end
  local lp = {}
  for i, l in ipairs(left) do lp[#lp + 1] = p(l[1], { before = l[2], after = i == #left and CAP_INSET or 0 }) end
  local adv = plain(m.adversary_no) ~= "" and xe.inl(m.adversary_no) or xe.runs(string.rep("_", 10))
  local right = {
    p(xe.runs("Case No. ") .. xe.inl(m.bankruptcy_case_no)),
    p(xe.runs("Chapter ") .. xe.inl(m.chapter)),
    p(xe.runs("Adversary No. ") .. adv, { before = GAP }),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>' ..
    '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. rule .. '/><w:right ' ..
    rule .. '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(lp) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CASE_INSET ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- the title: Word has no space after a table, so it takes the space before it
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(m.title)), { b = true }), { jc = "center", before = BODY, after = BODY })
end

-- ---------------------------------------------------------------------------
-- Signature and attorney block (L.R. 9011(A); Electronic Filing Rules, Rule 5), kept together (typst: unbreakable),
-- and the certificate of service (L.R. 9013-2(A); Rule 7005(d))
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local sig = m.signature
  local lines = { { xe.runs("Dated: ") .. xe.inl(m.date) .. xe.runs("\tRespectfully submitted,"), BODY, 0, SIG } }
  for _, l in ipairs(line_list(sig.party, GAP)) do lines[#lines + 1] = { l[1], l[2], SIG } end
  for _, l in ipairs(line_list({ "/s/ " .. plain(sig.signer), sig.signer, sig.signer_title }, GAP)) do
    lines[#lines + 1] = { l[1], l[2], SIG }
  end
  for _, l in ipairs(line_list(sig.attorney, BODY)) do lines[#lines + 1] = { l[1], l[2], SIG } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines, tab = l[4] })
  end
end

local function certificate(m, out)
  local svc = m.service
  if not svc then return end
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { brk = true, jc = "center", after = BODY })
  out[#out + 1] = p(xe.inl(svc.statement), { line = BODY, first = 720 })
  for _, l in ipairs(line_list(svc.parties, BODY)) do out[#out + 1] = p(l[1], { before = l[2] }) end
  for _, l in ipairs(line_list(svc.signature, GAP)) do out[#out + 1] = p(l[1], { before = l[2] }) end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings, as typed: single-spaced and bold, half a body line from the text on either side, kept with the text;
-- level 1 centered capitals, level 2 centered, level 3 at the margin.
local function heading(el)
  local t = el.level == 1 and upper(el.content) or el.content
  return p(xe.inl(t, { b = true }), { keep = true, before = GAP, after = GAP, jc = el.level <= 2 and "center" or "left" })
end

-- A paragraph pandoc writes (its footnotes stay Word footnotes) in a style of docx/reference.xml; a paragraph that
-- anchors a footnote is set without widow control (Body Text Note): typst moves its last line alone to the next page
-- when the note does not fit, which Word's widow control would not.
local function body_par(inlines, style)
  local para = pandoc.Para(inlines):walk({ Inlines = xe.inlines })
  local note = false
  para:walk({ Note = function() note = true end })
  return pandoc.Div({ para }, { ["custom-style"] = style or (note and "Body Text Note" or "Body Text") })
end

-- A block quotation (typst: show quote): Block Text, single-spaced and indented both sides, half a body line around
-- it and between its paragraphs.
local function quotation(b, out)
  for _, x in ipairs(b.content) do
    if x.t ~= "Para" and x.t ~= "Plain" then error("ilsb.lua: unsupported block in a quotation: " .. x.t) end
    out[#out + 1] = body_par(x.content, "Block Text")
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter, and in a web address ("https://...") one after a period before a letter or digit (zero-width
-- spaces). None shows in the PDF text.
local function breaks(s)
  local t = s.text
  if t:match("^https?://") then t = t:gsub("%.(%w)", ".\u{200B}%1") end
  return pandoc.Str((t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A section sign or pilcrow stays with its number when doubled ("§§ 2313") or after a typed quotation mark ("“§ __"):
-- a no-break space (typst binds every sign before a space with a box; xe.inl binds a lone sign only).
local function bind_sign_runs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text:sub(-2) == "\u{00A7}" or a.text:sub(-2) == "\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_sign_runs })
  local m = doc.meta
  local head = {}
  cover(m, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = body_par(b.content)
    elseif b.t == "BlockQuote" then
      quotation(b, out)
    elseif b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x:walk({ Inlines = xe.inlines }) end
    else
      error("ilsb.lua: unsupported block " .. b.t)
    end
  end
  local tail = {}
  signature(m, tail)
  certificate(m, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
