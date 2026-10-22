-- ilsb.lua (docx engine): the S.D. Ill. adversary complaint as Word paragraphs, so that it reads and breaks as
-- ../typst/ilsb-adversary-complaint.typ (the reference for the form) does:
--   * the court title, the caption (Form 416 as S.D. Ill. uses it: a table, the debtor and the parties on the left
--     with a rule on the right and bottom of their column, the case number, chapter and adversary number on the
--     right), the title and the lead-in, written here;
--   * the body: headings written here; numbered paragraphs (Fed. R. Civ. P. 10(b) via FRBP 7010; the number is the
--     template's, from 1, in a half-inch box at the first-line indent), the WHEREFORE paragraph kept with its prayer,
--     and the prayer items "A. ..." (the letter at the indent, the text hanging) left to pandoc in the styles of
--     docx/reference.xml, so their footnotes stay Word footnotes; bullets as List Item, quotations as Block Text;
--   * "Dated" and the signature in the right-hand column with the attorney block under it (L.R. 9011(A)), kept
--     together; the Summary of Exhibits on a page of its own when the frontmatter lists exhibits.
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
local EXHIBIT = 2016                     -- typst exhibit-column 1.4 in
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

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
  if pandoc.utils.type(x) == "Inlines" then
    return x:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return pandoc.text.upper(plain(x))
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, brk, tab } (keep: with the next paragraph
-- and its lines together; brk: a page break before it; tab: a left tab stop, twips). Single-spaced unless o.line.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
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
-- Court title, caption, title (Form 416; FRCP 10(a); L.R. 5005-1(B)(2))
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
-- Signature and attorney block (L.R. 9011(A); Electronic Filing Rules, Rule 5), kept together (typst: unbreakable)
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local sig = m.signature
  local lines = { { xe.runs("Dated: ") .. xe.inl(m.date) .. xe.runs("\tRespectfully submitted,"), BODY, 0, SIG } }
  for _, l in ipairs(line_list(sig.party, GAP)) do lines[#lines + 1] = { l[1], l[2], SIG } end
  local signer = { "/s/ " .. plain(sig.signer), plain(sig.signer) .. ",", sig.signer_title }
  for _, l in ipairs(line_list(signer, GAP)) do lines[#lines + 1] = { l[1], l[2], SIG } end
  for _, l in ipairs(line_list(sig.attorney, BODY)) do lines[#lines + 1] = { l[1], l[2], 0 } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines, tab = l[4] })
  end
end

-- Summary of Exhibits (Admin. Guide, adversary complaint; Electronic Filing Rules, Rule 6): the last page.
local function exhibits(m, out)
  local ex = list(m.exhibits)
  if #ex == 0 then return end
  out[#out + 1] = p(xe.runs("SUMMARY OF EXHIBITS", { b = true }), { brk = true, jc = "center", after = BODY })
  for _, e in ipairs(ex) do
    out[#out + 1] = p(xe.runs(plain(e.label), { b = true }) .. xe.runs("\t") .. xe.inl(e.description),
      { before = GAP, left = EXHIBIT, hanging = EXHIBIT, tab = EXHIBIT })
  end
  if m.exhibits_service then
    out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", before = BODY, after = GAP, keep = true })
    out[#out + 1] = p(xe.inl(m.exhibits_service), { line = BODY, first = 720 })
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings: single-spaced, half a body line from the text on either side, kept with the text; level 1 centered bold
-- capitals, level 2 centered bold, level 3 bold at the margin.
local function heading(el)
  local t = el.level == 1 and upper(el.content) or el.content
  return p(xe.inl(t, { b = true }), { keep = true, before = GAP, after = GAP, jc = el.level <= 2 and "center" or "left" })
end

-- A paragraph pandoc writes (its footnotes stay notes), in a style of docx/reference.xml, after an optional label
-- and tab.
local function styled(name, inlines, label)
  local l = pandoc.Inlines({})
  if label then
    l:insert(pandoc.Str(label))
    l:insert(TAB)
  end
  l:extend(inlines)
  return pandoc.Div({ pandoc.Para(l:walk({ Inlines = xe.inlines })) }, { ["custom-style"] = name })
end

-- A block quotation: single-spaced, indented both sides, half a body line around it (not between its paragraphs).
local function quotation(b, out)
  local paras = {}
  for _, x in ipairs(b.content) do
    if x.t == "Para" or x.t == "Plain" then paras[#paras + 1] = x.content end
  end
  for i, inl in ipairs(paras) do
    out[#out + 1] = xe.raw(p(xe.inl(inl), { before = i == 1 and GAP or 0, after = i == #paras and GAP or 0,
      left = 720, first = 0 }):gsub('<w:ind w:left="720"', '<w:ind w:left="720" w:right="720"'))
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

-- A doubled sign stays with its number ("§§ 1408": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local m = doc.meta
  local head = {}
  cover(m, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end
  if m.lead_in then out[#out + 1] = styled("Body Text", m.lead_in) end

  -- headings as written; paragraphs numbered by the template; the WHEREFORE paragraph opens a prayer whose items
  -- "A. text" are lettered, not numbered
  local n, prayer = 0, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      prayer = false
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      local letter = prayer and c[1] and c[1].t == "Str" and c[1].text:match("^([A-Z])%.$")
      if pandoc.utils.stringify(b):match("^WHEREFORE") then
        prayer = true
        out[#out + 1] = styled("Body Keep", c)
      elseif letter and c[2] and c[2].t == "Space" then
        out[#out + 1] = styled("Prayer Item", pandoc.Inlines({ table.unpack(c, 3) }), letter .. ".")
      else
        n = n + 1
        out[#out + 1] = styled("Numbered Paragraph", c, n .. ".")
      end
    elseif b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x:walk({ Inlines = xe.inlines }) end
    elseif b.t == "BlockQuote" then
      quotation(b, out)
    else
      error("ilsb.lua: unsupported block " .. b.t)
    end
  end

  local tail = {}
  signature(m, tail)
  exhibits(m, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
