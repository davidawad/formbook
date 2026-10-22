-- lawd complaint, docx engine. Mirrors typst/lawd-complaint.typ; rules and conventions are in ../README.md (Engines).
-- The court title, the caption (parties | one asterisk per line of the party column | case number and judges), the
-- title, the numbered allegations (FRCP 10(b)), the lettered lists and the signature block are built here as
-- WordprocessingML. Font, size, margins and the page number are styles and section settings in docx/reference.xml
-- (fb render builds the reference document from it). Numbers and letters are typed text, as the typst template
-- types them, so every viewer shows the same numbering. The <!-- unnumbered --> and <!-- upper --> directives (HTML
-- comments, not printed) are read in document order exactly as typst reads them: unnumbered applies to the next
-- paragraph, upper to the next list. Content-agnostic: every case-specific word comes from the sample.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local GAP = 480                          -- typst block-gap 24 pt
local INDENT = 720                       -- typst para-indent, list-indent 0.5 in
local TEXT_AT = 1440                     -- the text after a number or letter: 1 in (typst number-box, label-box)
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_STAR = 4752, 432     -- typst caption-left 3.3 in, caption-star 0.3 in
local DESIG = 2160                       -- typst designation-indent 1.5 in
local SIG_LEFT = 4680                    -- the signature block's date column, 3.25 in
local BLANK = string.rep("_", 23)        -- typst blank

-- ---------------------------------------------------------------------------
-- Line count of the party column (typst measures it; Word cannot, so the filter sets the text as typst does:
-- first fit at the face's advance widths, a break at a space or after a hyphen before a letter).
-- ---------------------------------------------------------------------------

-- Times New Roman advance widths (units of 2048 per em) of U+0020..U+007E, then ’ ‘ “ ” – — § no-break space … é;
-- measured from the pinned font (typst measure, kerning off), regular and italic.
local CHARS = {}
for c = 32, 126 do CHARS[#CHARS + 1] = utf8.char(c) end
for _, c in ipairs({ "’", "‘", "“", "”", "–", "—", "§", "\u{a0}", "…", "é" }) do CHARS[#CHARS + 1] = c end
local ADV_R = { 512,682,836,1024,1024,1706,1593,369,682,682,1024,1155,512,682,512,569,1024,1024,1024,1024,1024,1024,
  1024,1024,1024,1024,569,569,1155,1155,1155,909,1886,1479,1366,1366,1479,1251,1139,1479,1479,682,797,1479,1251,1821,
  1479,1479,1139,1479,1366,1139,1251,1479,1479,1933,1479,1479,1251,682,569,682,961,1024,682,909,1024,909,1024,909,
  682,1024,1024,569,569,1024,569,1593,1024,1024,1024,1024,682,797,569,1024,1024,1479,1024,1024,909,983,410,983,1108,
  682,682,909,909,1024,2048,1024,512,2048,909 }
local ADV_I = { 512,682,860,1024,1024,1706,1593,438,682,682,1024,1382,512,682,512,569,1024,1024,1024,1024,1024,1024,
  1024,1024,1024,1024,682,682,1382,1382,1382,1024,1884,1251,1251,1366,1479,1251,1251,1479,1479,682,909,1366,1139,
  1706,1366,1479,1251,1479,1251,1024,1139,1479,1251,1706,1251,1139,1139,797,569,797,864,1024,682,1024,1024,909,1024,
  909,569,1024,1024,569,569,909,569,1479,1024,1024,1024,1024,797,797,569,1024,909,1366,909,909,797,819,563,819,1108,
  682,682,1139,1139,1024,1821,1024,512,1821,909 }
local W_R, W_I = {}, {}
for i, c in ipairs(CHARS) do W_R[c], W_I[c] = ADV_R[i], ADV_I[i] end
local SIZE = 12

-- The characters of inlines (or a metadata value), each with its width in points at the type size.
local function glyphs(x, italic, out)
  out = out or {}
  if x == nil then return out end
  if type(x) == "string" then x = pandoc.Inlines({ pandoc.Str(x) }) end
  for _, el in ipairs(x) do
    if el.t == "Str" then
      for _, c in utf8.codes(el.text) do
        local ch = utf8.char(c)
        out[#out + 1] = { ch, ((italic and W_I or W_R)[ch] or 1024) * SIZE / 2048 }
      end
    elseif el.t == "Space" or el.t == "SoftBreak" then
      out[#out + 1] = { " ", W_R[" "] * SIZE / 2048 }
    elseif el.t == "Emph" then
      glyphs(el.content, true, out)
    elseif el.content then
      glyphs(el.content, italic, out)
    end
  end
  return out
end

-- The number of lines the text takes in a column `width` points wide, broken first fit.
local function count_lines(x, width)
  local g = glyphs(x)
  -- segments: a run of characters, then whether a space follows (else a hyphen break)
  local segs, cur, w = {}, {}, 0
  for i, gl in ipairs(g) do
    if gl[1] == " " then
      segs[#segs + 1] = { w = w, space = gl[2] }
      w = 0
    else
      w = w + gl[2]
      local nxt = g[i + 1]
      if gl[1] == "-" and nxt and nxt[1] ~= " " and not nxt[1]:match("%d") then
        segs[#segs + 1] = { w = w, space = 0 }
        w = 0
      end
    end
  end
  segs[#segs + 1] = { w = w, space = 0 }
  local lines, line, pend = 1, 0, 0
  for _, s in ipairs(segs) do
    if line > 0 and line + pend + s.w > width + 0.01 then
      lines = lines + 1
      line = s.w
    else
      line = line + pend + s.w
    end
    pend = s.space
  end
  return lines
end

-- ---------------------------------------------------------------------------
-- Paragraphs and tables
-- ---------------------------------------------------------------------------

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tab_at(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

-- A one-row table with fixed column widths (twips), no borders and no cell margins; the row is not split across
-- pages (typst: one grid row).
local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. cells[i] .. '</w:tc>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- Single-spaced lines (typst line-stack): an empty item is a blank line, the next line a line lower.
local function stack(lines, o)
  local out, gap = {}, 0
  for _, l in ipairs(lines) do
    local s = type(l) == "string" and l or stringify(l)
    if s == "" then
      gap = gap + SINGLE
    else
      local q = { before = gap }
      for k, v in pairs(o or {}) do q[k] = v end
      out[#out + 1] = p(type(l) == "string" and xe.runs(l) or xe.inl(l), q)
      gap = 0
    end
  end
  return table.concat(out)
end

local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- ---------------------------------------------------------------------------
-- Court title, caption (FRCP 10(a); LR 10.1), title
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {
    p(xe.runs("UNITED STATES DISTRICT COURT"), { jc = "center" }),
    p(xe.runs("WESTERN DISTRICT OF LOUISIANA"), { jc = "center" }),
    p(xe.runs(stringify(m.division):upper() .. " DIVISION"), { jc = "center", after = GAP }),
  }
  local cap = m.caption
  local sep = cap.separator and stringify(cap.separator) or "v."
  local left, n = {}, 0
  for i, party in ipairs(cap.parties) do
    if i > 1 then
      left[#left + 1] = stack({ sep, "" })
      n = n + 2
    end
    local first = true
    for _, name in ipairs(items(party.names)) do
      -- the line after a separator's blank line sits a line lower
      left[#left + 1] = p(xe.inl(name), { before = (i > 1 and first) and SINGLE or 0 })
      first = false
      n = n + count_lines(name, CAP_LEFT / 20)
    end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG })
    n = n + count_lines(party.designation, (CAP_LEFT - DESIG) / 20)
  end
  local stars = {}
  for _ = 1, n do stars[#stars + 1] = p(xe.runs("*"), { jc = "center" }) end
  local function entry(label, v)
    return label .. " " .. (v and stringify(v) or BLANK)
  end
  local right = { entry("CIVIL ACTION NO.", m.case_number), entry("JUDGE", m.judge),
    entry("MAGISTRATE JUDGE", m.magistrate) }
  if m.legend then
    right[#right + 1] = ""
    right[#right + 1] = stringify(m.legend)
  end
  out[#out + 1] = table_xml({ CAP_LEFT, CAP_STAR, TEXTW - CAP_LEFT - CAP_STAR },
    { table.concat(left), table.concat(stars), stack(right) })
  -- the caption stands a blank double line above the title (Word has no space after a table)
  out[#out + 1] = p(xe.runs(stringify(m.title):upper(), { b = true }), { jc = "center", before = GAP, after = GAP })
  return table.concat(out)
end

-- The signature block: the date at the left; "Respectfully submitted," and the sample's lines at the right; the
-- space above it is spacing of its own, kept with the block (typst: one unbreakable block with the last paragraph).
local function signature(sig)
  local right = { "Respectfully submitted,", "" }
  for _, l in ipairs(items(sig.lines)) do right[#right + 1] = l end
  return xe.para({ xe.KEEP, xe.spacing(0, 0, GAP) }, "")
    .. table_xml({ SIG_LEFT, TEXTW - SIG_LEFT }, { stack({ "Dated: " .. stringify(sig.date) }), stack(right) })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking): none inside a token of adjacent parentheses
-- ("4(k)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter, where LibreOffice keeps the word whole: a zero-width space (U+200B). Neither shows in the
-- PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

local function heading(b)
  local c = b.content
  if b.level == 1 then c = c:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }) end
  local o = { b = true, i = b.level >= 3 }
  return p(xe.inl(c, o), { before = GAP, line = BODY, keep = true, jc = b.level < 3 and "center" or "left" })
end

local function finish(doc)
  local m = doc.meta
  local parts = {}
  local n, upper, unnumbered = 0, false, false
  for _, b in ipairs(doc.blocks) do
    if b.t == "RawBlock" then
      local t = b.text:gsub("%s+", " ")
      if t == "<!-- upper -->" then upper = true end
      if t == "<!-- unnumbered -->" then unnumbered = true end
    elseif b.t == "Header" then
      parts[#parts + 1] = { xml = heading(b) }
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local lab = string.char((upper and 64 or 96) + i) .. "."
        parts[#parts + 1] = { body = xe.runs(lab .. "\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          o = { line = BODY, left = INDENT + (TEXT_AT - INDENT), hanging = TEXT_AT - INDENT } }
      end
      upper = false
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered then
        parts[#parts + 1] = { body = xe.inl(b.content), o = { line = BODY, first = INDENT } }
        unnumbered = false
      else
        n = n + 1
        parts[#parts + 1] = { body = xe.runs(n .. ".\t") .. xe.inl(b.content),
          o = { line = BODY, first = INDENT, tabs = tab_at(TEXT_AT) } }
      end
    else
      error("lawd-complaint.lua: unsupported block " .. b.t)
    end
  end
  local out = { cover(m) }
  for i, x in ipairs(parts) do
    if x.xml then
      out[#out + 1] = x.xml
    else
      -- the last block stays whole with the signature block (typst: one unbreakable block)
      if i == #parts then x.o.keep = true end
      out[#out + 1] = p(x.body, x.o)
    end
  end
  out[#out + 1] = signature(m.signature)
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(out)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
