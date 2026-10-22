-- tnmb-adversary-complaint.lua (docx engine): the M.D. Tenn. bankruptcy adversary complaint as Word paragraphs, so
-- that it reads and breaks as ../typst/tnmb-adversary-complaint.typ (the reference for the form) does:
--   * the court title, the caption (LBR 9004-2: a table, one single line per row, the debtor and the parties on the
--     left, a ")" column, the case number, chapter, judge and adversary number on the right) and the title, written
--     here;
--   * the body: headings written here (level 1 centered and underlined, level 2 centered, level 3 bold italic, in
--     the body's double-spaced line, kept with the text); numbered allegations (Civil Rule 10(b) via FRBP 7010; the
--     number is the template's, from 1, in a half-inch box at the first-line indent), unnumbered paragraphs ("~ ";
--     flush left right after a quotation; the WHEREFORE paragraph kept with the prayer), the prayer items lettered
--     A., B., ... (the letter in a half-inch box at the indent, the text hanging) left to pandoc in the styles of
--     docx/reference.xml, so their footnotes stay Word footnotes; block quotations written here;
--   * "Respectfully submitted," and the signature lines at the right half, kept together.
-- Every case word comes from the YAML frontmatter or the body. No coordinates, no forced line breaks.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE, GAP = 480, 276, 240  -- typst pitch-body, pitch-single, gap (half a body line)
local TEXTW = 9360                       -- 6.5 in
local INDENT = 720                       -- typst para-indent, quote-indent, designation-indent 0.5 in
local CAP_LEFT, CAP_MID = 5328, 432      -- typst caption-left 3.7 in, caption-mid 0.3 in
local SIG = 4680                         -- typst sig-indent 3.25 in
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

-- A paragraph: o = { before, after, line, left, right, first, jc, keep } (keep: with the next paragraph and its
-- lines together). Single-spaced unless o.line.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title (LBR 9004-2(a)(1), (b))
-- ---------------------------------------------------------------------------

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function cover(m, out)
  local court = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE MIDDLE DISTRICT OF TENNESSEE" }
  if plain(m.division) ~= "" then court[#court + 1] = pandoc.text.upper(plain(m.division)) end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  -- the rows: { inlines, indent } or false for a blank row
  local c = m.caption
  local left = { { xe.runs("IN RE:"), 0 }, false }
  for _, d in ipairs(list(c.debtor)) do left[#left + 1] = { xe.inl(d), 0 } end
  left[#left + 1] = { xe.runs("Debtor."), INDENT }
  left[#left + 1] = false
  for k, side in ipairs(list(c.parties)) do
    if k > 1 then
      left[#left + 1] = { xe.runs("v."), 0 }
      left[#left + 1] = false
    end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = { xe.inl(n), 0 } end
    left[#left + 1] = { xe.inl(side.designation), INDENT }
    left[#left + 1] = false
  end
  local adv = plain(m.adv_proc_no)
  if adv == "" then adv = string.rep("_", 8) end
  local right = {
    xe.runs("Case No. " .. plain(m.case_number)),
    xe.runs("Chapter " .. plain(m.chapter)),
    xe.runs("Judge " .. plain(m.judge)),
    false,
    xe.runs("Adv. Proc. No. " .. adv),
  }
  local rw = TEXTW - CAP_LEFT - CAP_MID
  local rows = {}
  for i = 1, math.max(#left, #right) do
    local l, r = left[i], right[i]
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      tc(CAP_LEFT, l and p(l[1], { left = l[2] }) or p("")) .. tc(CAP_MID, p(xe.runs(")"))) ..
      tc(rw, r and p(r) or p("")) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_MID .. '"/><w:gridCol w:w="' .. rw ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- the title, bold and underlined; Word has no space after a table, so the first line takes the space before it
  local title = list(m.title)
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true, u = true }),
      { jc = "center", before = i == 1 and BODY or 0, after = i == #title and BODY or 0 })
  end
end

-- ---------------------------------------------------------------------------
-- Signature: "Respectfully submitted," and the lines at the right half, kept together (typst: unbreakable)
-- ---------------------------------------------------------------------------

local function signature(m, out)
  local lines = { { xe.runs("Respectfully submitted,"), SINGLE } }
  for i, l in ipairs(list(m.signature)) do lines[#lines + 1] = { xe.inl(l), i == 1 and SINGLE or 0 } end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = SIG, keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings in the body's double-spaced line, kept with the text: level 1 centered and underlined, level 2 centered,
-- level 3 bold italic at the margin.
local function heading(el)
  local o = {}
  local t = el.content
  if el.level == 1 then
    o.u = true
    t = t:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  elseif el.level >= 3 then
    o.b, o.i = true, true
  end
  return p(xe.inl(t, o), { keep = true, line = BODY, jc = el.level <= 2 and "center" or "left" })
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
      left = INDENT, right = INDENT }))
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 541": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- "~ text": an unnumbered paragraph; returns its inlines without the marker, or nil.
local function unnumbered(c)
  if c[1] and c[1].t == "Str" and c[1].text == "~" and c[2] and c[2].t == "Space" then
    return pandoc.Inlines({ table.unpack(c, 3) })
  end
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local m = doc.meta
  local head = {}
  cover(m, head)
  local out = {}
  for _, x in ipairs(head) do out[#out + 1] = xe.raw(x) end

  local n, after_quote = 0, false
  for _, b in ipairs(doc.blocks) do
    local quote = false
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      local u = unnumbered(b.content)
      if u then
        local style = after_quote and "Body Flush" or "Body Text"
        if pandoc.utils.stringify(u):match("^WHEREFORE") then style = "Body Keep" end
        out[#out + 1] = styled(style, u)
      else
        n = n + 1
        out[#out + 1] = styled("Numbered Paragraph", b.content, n .. ".")
      end
    elseif b.t == "OrderedList" then
      -- the prayer: lettered A., B., ...
      for i, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Para" and item[1].t ~= "Plain") then
          error("tnmb-adversary-complaint.lua: a prayer item is one paragraph")
        end
        out[#out + 1] = styled("Prayer Item", item[1].content, string.char(64 + i) .. ".")
      end
    elseif b.t == "BlockQuote" then
      quote = true
      quotation(b, out)
    else
      error("tnmb-adversary-complaint.lua: unsupported block " .. b.t)
    end
    after_quote = quote
  end

  local tail = {}
  signature(m, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
