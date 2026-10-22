-- Pandoc filter for the W.D. Tenn. complaint, engine docx, so that it reads and breaks as typst/tnwd-complaint.typ
-- does: the court title, the caption (one table row per party line, a column of ")" marks, the case number opposite
-- the first designation and JURY DEMAND opposite "v.", LR 7.1(c)), the title, the unnumbered lead-in, numbered
-- paragraphs after the first heading (Fed. R. Civ. P. 10(b)), unnumbered "~ " paragraphs, headings, quotations, the
-- lettered prayer items, the signature block (LR 11.1(b)) kept with the last paragraph, and one verification per
-- party (28 U.S.C. § 1746) from a new page. Every case word comes from the sample's frontmatter and body, never from
-- this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs, quotations
-- and footnotes are written by pandoc in the styles of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body, pitch-single
local GAP = 276                          -- typst gap: a blank single line
local HEAD_BELOW = 138                   -- typst head-below, 6.9 pt
local SIGN_ROOM = 1104                   -- typst sign-room, two body lines
local INDENT = 720                       -- typst para-indent, item-indent and item-label, 0.5 in
local DESIGNATION = 1800                 -- typst designation-indent, 1.25 in
local SIG = 4680                         -- typst sig-indent, 3.25 in
local SIG_RULE = 3960                    -- typst sig-rule, 2.75 in
local BLANK = 2304                       -- typst blank-width, 1.6 in
local LEFT, MARKS, RIGHT = 4752, 576, 144   -- typst caption-left 3.3 in, caption-marks 0.4 in, caption-right 0.1 in
local TEXTW = 9360                       -- 6.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  if m == nil then return {} end
  return m
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- An underlined tab to `pos`: a blank to write on (typst: a box with a bottom rule).
local function rule_to(pos)
  return '<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r>', pos
end

-- ---------------------------------------------------------------------------
-- Caption (Fed. R. Civ. P. 10(a); LR 7.1(c))
-- ---------------------------------------------------------------------------

-- The lines a caption line takes in its column (typst measures it), first fit on its words: Times New Roman's
-- advances (1/1000 em, regular) at 12 pt; a character not in the table counts 0.5 em.
local ADV = {
  A = 722, B = 667, C = 667, D = 722, E = 611, F = 556, G = 722, H = 722, I = 333, J = 389, K = 722, L = 611,
  M = 889, N = 722, O = 722, P = 556, Q = 722, R = 667, S = 556, T = 611, U = 722, V = 722, W = 944, X = 722,
  Y = 722, Z = 611, a = 444, b = 500, c = 444, d = 500, e = 444, f = 333, g = 500, h = 500, i = 278, j = 278,
  k = 500, l = 278, m = 778, n = 500, o = 500, p = 500, q = 500, r = 333, s = 389, t = 278, u = 500, v = 500,
  w = 722, x = 500, y = 500, z = 444, [" "] = 250, [","] = 250, ["."] = 250, [";"] = 278, [":"] = 278,
  ["/"] = 278, ["-"] = 333, ["("] = 333, [")"] = 333, ["&"] = 778, ["'"] = 180, ['"'] = 408,
  ["\u{2018}"] = 333, ["\u{2019}"] = 333, ["\u{201C}"] = 444, ["\u{201D}"] = 444, ["\u{2013}"] = 500,
}
local function width(s)
  local w = 0
  for _, c in utf8.codes(s) do
    local ch = utf8.char(c)
    w = w + (ADV[ch] or (ch:match("^%d$") and 500) or 500) * 12 / 1000
  end
  return w
end

local function caption_rows(text, indent)
  local room = (LEFT - indent) / 20
  local lines, line = 1, nil
  for word in text:gmatch("%S+") do
    local ww = width(word)
    if line and line + width(" ") + ww > room then
      lines, line = lines + 1, ww
    else
      line = (line and line + width(" ") or 0) + ww
    end
  end
  return lines
end

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function caption(meta, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT"), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE WESTERN DISTRICT OF TENNESSEE"), { jc = "center" })
  if plain(meta.court_division) ~= "" then
    out[#out + 1] = p(xe.inl(meta.court_division), { jc = "center" })
  end
  -- the party lines: { inlines, plain text, left indent, kind }; nil inlines is a blank line
  local left = {}
  local sides = list(meta.caption)
  for i, side in ipairs(sides) do
    for _, n in ipairs(list(side.names)) do left[#left + 1] = { xe.inl(n), plain(n), 0, "name" } end
    left[#left + 1] = { xe.inl(side.designation), plain(side.designation), DESIGNATION, i == 1 and "first" or "designation" }
    if i < #sides then
      left[#left + 1] = { nil, "", 0, "blank" }
      left[#left + 1] = { xe.runs("v."), "v.", 0, "v" }
      left[#left + 1] = { nil, "", 0, "blank" }
    end
  end
  local right = TEXTW - LEFT - MARKS
  local rows = {}
  for k, l in ipairs(left) do
    local text, n = p(""), 1
    if l[1] then
      text = p(l[1], { left = l[3] })
      n = caption_rows(l[2], l[3])
    end
    local marks = {}
    for _ = 1, n do marks[#marks + 1] = p(xe.runs(")"), { jc = "center" }) end
    local r = p("")
    if l[4] == "first" then
      local cn = plain(meta.case_number)
      if cn ~= "" then
        r = p(xe.runs("Case No. " .. cn), { left = RIGHT })
      else
        local run, pos = rule_to(RIGHT + 1000 + BLANK)
        r = p(xe.runs("Case No. ") .. run, { left = RIGHT, tab = pos })
      end
    elseif l[4] == "v" and meta.jury_demand == true then
      r = p(xe.runs("JURY DEMAND"), { left = RIGHT })
    end
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(LEFT, text) .. tc(MARKS, table.concat(marks)) ..
      tc(right, r) .. '</w:tr>'
  end
  -- typst: the caption a blank double line under the court title
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. MARKS .. '"/><w:gridCol w:w="' .. right ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- Fed. R. Civ. P. 7(a), 10(a): the title names the pleading; Word has no space after a table, so the title takes
  -- the space before it
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { before = BODY, after = BODY, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature (LR 11.1(b)) and verifications (28 U.S.C. § 1746)
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local lines = {}
  local dated = plain(meta.date) ~= ""
  if dated then lines[#lines + 1] = { xe.runs("Dated: " .. plain(meta.date)), BODY, 0 } end
  lines[#lines + 1] = { xe.runs("Respectfully submitted,"), dated and GAP or BODY, SIG }
  lines[#lines + 1] = { xe.runs("s/ ") .. xe.inl(sig.signer), GAP, SIG }
  lines[#lines + 1] = { xe.runs("Attorney Bar No. " .. plain(sig.bar_number)), 0, SIG }
  if sig.firm then lines[#lines + 1] = { xe.inl(sig.firm), 0, SIG } end
  for _, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { xe.inl(l), 0, SIG } end
  -- kept on one page (typst's unbreakable block): every line but the last keeps with the next
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #lines })
  end
end

local function verifications(meta, out)
  for i, v in ipairs(list(meta.verifications)) do
    -- the first starts a page (Word keeps the space above a paragraph after a page break: none there)
    out[#out + 1] = p(xe.runs("VERIFICATION", { b = true }),
      { before = i == 1 and 0 or BODY, after = GAP, jc = "center", keep = true, brk = i == 1 })
    out[#out + 1] = p(xe.runs("I, ") .. xe.inl(v.name) ..
      xe.runs(", declare under penalty of perjury that the foregoing is true and correct."),
      { line = BODY, first = INDENT, keep = true })
    local run, pos = rule_to(SIG + SIG_RULE)
    out[#out + 1] = p(run, { before = SIGN_ROOM, left = SIG, tab = pos, keep = true })
    local executed = plain(v.executed) ~= ""
    out[#out + 1] = p(xe.inl(v.name), { left = SIG, keep = executed })
    if executed then out[#out + 1] = p(xe.runs("Executed on: " .. plain(v.executed)), { left = SIG }) end
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). In a web address typst breaks after "//" and after each "/", ".",
-- "-", "_", "?", "=", "&", "#" inside it: a zero-width space there too. None shows in the PDF text.
local function url_breaks(u)
  local head, rest = u:match("^(%a+://)(.*)$")
  rest = rest:gsub("([/%.%-_%?=&#])(.)", "%1\u{200B}%2")
  return head .. "\u{200B}" .. rest
end

local function breaks(s)
  local t = s.text
  local a, b = t:find("%a+://%S*")
  if a then
    return pandoc.Str(t:sub(1, a - 1) .. url_breaks(t:sub(a, b)) .. t:sub(b + 1))
  end
  return pandoc.Str((t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1331": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A paragraph that starts "~ " is unnumbered: the inlines without the marker, or nil.
local function unmarked(inl)
  if inl[1] and inl[1].t == "Str" and inl[1].text == "~" then
    local rest = pandoc.Inlines({})
    for k = 2, #inl do rest:insert(inl[k]) end
    if rest[1] and rest[1].t == "Space" then rest:remove(1) end
    return rest
  end
  return nil
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  for _, k in ipairs({ "caption", "title", "signature" }) do
    assert(meta[k], "tnwd-complaint: frontmatter needs " .. k)
  end

  local raw = {}
  caption(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end

  -- The body as a list of items: { kind, inlines | block, level }. pandoc reads a "~ " paragraph after another
  -- paragraph as the definition of a term (the paragraph before it); both are paragraphs here.
  local items = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "DefinitionList" then
      for _, item in ipairs(b.content) do
        items[#items + 1] = { "para", item[1] }
        for _, d in ipairs(item[2]) do
          for _, db in ipairs(d) do
            if db.t ~= "Para" and db.t ~= "Plain" then error("tnwd-complaint.lua: unsupported block " .. db.t) end
            local c = pandoc.Inlines({ pandoc.Str("~"), pandoc.Space() })
            c:extend(db.content)
            items[#items + 1] = { "para", c }
          end
        end
      end
    elseif b.t == "Header" then
      items[#items + 1] = { "head", b.content, b.level }
    elseif b.t == "Para" or b.t == "Plain" then
      items[#items + 1] = { "para", b.content }
    elseif b.t == "OrderedList" then
      items[#items + 1] = { "list", b }
    elseif b.t == "BlockQuote" then
      items[#items + 1] = { "quote", b }
    else
      error("tnwd-complaint.lua: unsupported block " .. b.t)
    end
  end

  local seen_head = false
  local n = 0
  for k, it in ipairs(items) do
    local last = k == #items
    if it[1] == "head" then
      seen_head = true
      -- single-spaced, a blank single line above and half a line below; level 1 centered bold, level 2 bold,
      -- level 3 bold italic at the left
      local lvl = it[3]
      out[#out + 1] = xe.raw(xe.para({ xe.KEEP, xe.spacing(GAP, HEAD_BELOW, SINGLE), xe.ind(0, nil, 0),
        xe.jc(lvl == 1 and "center" or "left"), '<w:outlineLvl w:val="' .. (math.min(lvl, 3) - 1) .. '"/>' },
        xe.inl(it[2], { b = true, i = lvl >= 3 })))
    elseif it[1] == "list" then
      -- prayer items: lettered by the template, the letter in a half-inch box half an inch in, the text hanging an
      -- inch in, double-spaced
      local its = it[2].content
      for j, item in ipairs(its) do
        local inl = pandoc.Inlines({})
        for m, b in ipairs(item) do
          if m > 1 then inl:insert(pandoc.Space()) end
          inl:extend(b.content)
        end
        local body = xe.runs("(" .. string.char(96 + j) .. ")\t") .. xe.inl(inl)
        out[#out + 1] = xe.raw(p(body, { line = BODY, left = 2 * INDENT, hanging = INDENT,
          tab = 2 * INDENT, keep = last and j == #its }))
      end
    elseif it[1] == "quote" then
      out[#out + 1] = pandoc.Div(it[2].content, { ["custom-style"] = "Block Text" })
    else
      local rest = unmarked(it[2])
      local style, inl
      if rest or not seen_head then
        style, inl = "Body Text", rest or it[2]
      else
        n = n + 1
        style = "Body Numbered"
        inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inl:extend(it[2])
      end
      if last then style = style == "Body Text" and "Body Keep" or "Body Numbered Keep" end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
    end
  end

  local tail = {}
  signature(meta, tail)
  verifications(meta, tail)
  for _, x in ipairs(tail) do out[#out + 1] = xe.raw(x) end
  -- pandoc would print the metadata title and date above the body; the caption, title and date are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
