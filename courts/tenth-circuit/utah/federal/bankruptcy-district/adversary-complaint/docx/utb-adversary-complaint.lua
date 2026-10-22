-- utb adversary complaint, docx engine (docs/DOCX.md). The complaint as Word paragraphs, so that it reads and breaks
-- as typst/utb-adversary-complaint.typ does: the counsel block, the court title, the Form 416D caption (a table: the
-- party column ruled on its right and at its foot, the case numbers and the judge beside it), the title, the body
-- chunks (headings, the unnumbered lead-in and WHEREFORE paragraph, numbered allegations, Fed. R. Civ. P. 10(b);
-- lettered prayer items, lists), the signature block kept with the last chunk, and the verification (28 U.S.C.
-- section 1746) kept on one page. Every case-specific word comes from the sample's frontmatter (read as written,
-- $FORMBOOK_META) and body, never from this file. Font, margins and the page number are in docx/reference.xml
-- (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is), so both engines number the same paragraphs.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local LABEL = 1296                       -- typst para-indent + number-box: the text after a number, 0.9 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4752, 360   -- typst caption-left 3.3 in, caption-gutter 0.25 in
local CAP_RIGHT_PAD, CAP_BOTTOM_PAD = 200, 160 -- typst caption-right-pad 10 pt, caption-bottom-pad 8 pt
local CAP_NUMBER = 216                   -- typst caption-number-indent, 0.15 in
local RULE = 15                          -- typst caption-rule, 0.75 pt (Word sets it inside the cell's margin)
local SIG = 4896                         -- typst sig-column, 3.4 in
local PART_GAP = 480                     -- typst part-gap, 24 pt
local H_ABOVE, H_BELOW = 360, 120        -- typst h-above 18 pt, h-below 6 pt
local SIG_ABOVE = 480                    -- typst sig-above, 24 pt

local function read_file(path)
  if path == nil then return nil end
  local f = io.open(path, "r")
  if f == nil then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- The frontmatter as written (pandoc's metadata would read "__________" as a rule and smarten the plain fields).
local RAW = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)

local function need(t, key, what)
  local v = t and t[key]
  if v == nil then error("utb-adversary-complaint: missing required metadata field `" .. what .. "`", 0) end
  return v
end

local function list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A sign stays with its number, and the number is not broken ("(¶¶ 39–40,", "§ 70A-4-302": typst boxes
-- "[§¶]+ \S+", from the sign to the next space; xe.inl binds only a sign that stands alone).
local function bind_signs(inl)
  for i = 1, #inl - 1 do
    local a, b, c = inl[i], inl[i + 1], inl[i + 2]
    local tail = a.t == "Str" and a.text:sub(-2) or ""
    if (tail == "\u{00A7}" or tail == "\u{00B6}") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
      if c and c.t == "Str" then
        inl[i + 2] = pandoc.Str((c.text:gsub("\u{200B}", ""):gsub("\u{2013}", "\u{2013}\u{2060}")
          :gsub("\u{2014}", "\u{2014}\u{2060}"):gsub("/", "/\u{2060}")))
      end
    end
  end
  return inl
end

-- Markdown text as inlines, read as typst's cmarker reads it (no "(a)" or "A." lists).
local function md(s)
  local doc = pandoc.read(s, "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return bind_signs(pandoc.Inlines(pandoc.utils.blocks_to_inlines(doc.blocks)):walk({ Str = breaks }))
end

-- Markdown text as runs (typst inl()); plain text as runs (typst prints the string as written).
local function text(s, o) return xe.inl(md(s), o) end
local function plain(s, o) return xe.runs(tostring(s), o) end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, Form 416D caption, title
-- ---------------------------------------------------------------------------

local function caption(out)
  local cap, case = need(RAW, "caption", "caption"), need(RAW, "case", "case")
  local left = { p(plain("In re:")) }
  for k, d in ipairs(list(cap.debtors)) do left[#left + 1] = p(text(d), { before = k == 1 and SINGLE or 0 }) end
  left[#left + 1] = p(text(need(cap, "debtor_designation", "caption.debtor_designation")), { before = SINGLE })
  local groups = {}
  for _, g in ipairs(list(cap.parties)) do groups[#groups + 1] = g end
  for _, g in ipairs(list(cap.third_party)) do groups[#groups + 1] = g end
  for k, g in ipairs(groups) do
    if k > 1 then left[#left + 1] = p(plain("v."), { before = SINGLE }) end
    for j, n in ipairs(list(g.names)) do left[#left + 1] = p(text(n), { before = j == 1 and SINGLE or 0 }) end
    left[#left + 1] = p(text(g.designation), { before = SINGLE })
  end
  local bk = tostring(case.bankruptcy_number or "")
  if bk == "" then bk = "________" end
  local adv = tostring(case.adversary_number or "")
  if adv == "" then adv = "________" end
  local right = {
    p(plain("Bankruptcy No. " .. bk), { left = CAP_NUMBER }),
    p(plain("Chapter " .. tostring(case.chapter)), { left = CAP_NUMBER }),
    p(plain("Adversary Proceeding No. " .. adv), { before = SINGLE, left = CAP_NUMBER }),
    p(plain("Hon. " .. tostring(case.judge)), { before = SINGLE, left = CAP_NUMBER }),
  }
  local function border(side) return '<w:' .. side .. ' w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  local function cell(w, ps, pr) return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") ..
    '</w:tcPr>' .. table.concat(ps) .. '</w:tc>' end
  local right_w = TEXTW - CAP_LEFT - CAP_GUTTER
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. right_w .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, left, '<w:tcBorders>' .. border("bottom") .. border("right") .. '</w:tcBorders><w:tcMar>' ..
      '<w:bottom w:w="' .. (CAP_BOTTOM_PAD - RULE) .. '" w:type="dxa"/><w:right w:w="' .. (CAP_RIGHT_PAD - RULE) ..
      '" w:type="dxa"/></w:tcMar>') ..
    cell(CAP_GUTTER, { p("") }) .. cell(right_w, right) .. '</w:tr></w:tbl>'
end

local function cover(out)
  for _, c in ipairs(list(need(RAW, "counsel", "counsel"))) do out[#out + 1] = p(text(c)) end
  local titles = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF UTAH" }
  if RAW.division and tostring(RAW.division) ~= "" then
    titles[#titles + 1] = pandoc.text.upper(tostring(RAW.division)) .. " DIVISION"
  end
  for k, t in ipairs(titles) do
    out[#out + 1] = p(plain(t, { b = true }),
      { before = k == 1 and PART_GAP or 0, after = k == #titles and PART_GAP or 0, jc = "center" })
  end
  caption(out)
  out[#out + 1] = p(text(pandoc.text.upper(tostring(need(RAW, "title", "title"))), { b = true }),
    { before = PART_GAP, after = PART_GAP, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Signature and verification
-- ---------------------------------------------------------------------------

-- "DATED ..." at the margin, the firm beside it at the signature column; the signer and the lines under the firm.
-- Each line is kept with the next, so the block stays on one page.
local function signature(out)
  local s = need(RAW, "signature", "signature")
  local ps = {
    p(plain("DATED " .. tostring(s.date) .. ".") .. xe.runs("\t") .. text(s.firm),
      { before = SIG_ABOVE, left = SIG, hanging = SIG, tab = SIG, keep = true }),
    p(plain("/s/ ") .. text(s.signer), { before = SINGLE, left = SIG, keep = true }),
  }
  for _, l in ipairs(list(s.lines)) do ps[#ps + 1] = p(text(l), { left = SIG, keep = true }) end
  -- the last line of the block is not kept with what follows (the verification moves on its own)
  ps[#ps] = ps[#ps]:gsub(xe.KEEP, "", 1)
  for _, x in ipairs(ps) do out[#out + 1] = x end
end

local function verification(out)
  local v = RAW.verification
  if v == nil then return end
  local title = tostring(need(RAW, "title", "title"))
  out[#out + 1] = p(plain("VERIFICATION", { b = true }), { before = SIG_ABOVE, after = H_BELOW, jc = "center", keep = true })
  out[#out + 1] = p(plain("I, " .. tostring(v.declarant) .. ", declare under penalty of perjury under the laws of the " ..
    "United States of America that I am " .. tostring(v.title) .. " of " .. tostring(v.entity) .. ", that I have read " ..
    "the foregoing " .. title .. ", and that the factual allegations in it are true and correct to the best of my " ..
    "knowledge, information, and belief."), { line = BODY, first = INDENT, keep = true })
  out[#out + 1] = p(plain("Executed on " .. tostring(v.date) .. ", at " .. tostring(v.place) .. "."),
    { before = SIG_ABOVE, keep = true })
  out[#out + 1] = p(plain(tostring(v.declarant)), { before = SINGLE, left = SIG, keep = true })
  out[#out + 1] = p(plain(tostring(v.title) .. ", " .. tostring(v.entity)), { left = SIG })
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's allegations()
-- ---------------------------------------------------------------------------

-- The sample's body: the text after its frontmatter, split at blank lines.
local function chunks()
  local src = assert(read_file(PANDOC_STATE.input_files[1]))
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out
end

-- Headings single-spaced at the type size, bold (levels 1 and 2 centered), kept with the text after them.
local function heading(t)
  local hashes, s = t:match("^(#+)%s+(.-)%s*$")
  return { p(text(s, { b = true }), { before = H_ABOVE, after = H_BELOW, jc = #hashes <= 2 and "center" or "left",
    keep = true }) }
end

-- A markdown list: each item's label in a box of the paragraph indent, the text hanging after it (typst xengine).
local function list_items(t)
  local items, n = {}, nil
  for line in (t .. "\n"):gmatch("(.-)\n") do
    local num, rest = line:match("^(%d+)[.][ \t]+(.*)$")
    local bullet = line:match("^[-*+][ \t]+(.*)$")
    if num then
      n = n or tonumber(num)
      items[#items + 1] = { n .. ".", rest }
      n = n + 1
    elseif bullet then
      items[#items + 1] = { "\u{2022}", bullet }
    elseif #items > 0 then
      items[#items][2] = items[#items][2] .. " " .. line:match("^%s*(.-)$")
    end
  end
  local out = {}
  for _, it in ipairs(items) do
    out[#out + 1] = p(plain(it[1] .. "\t") .. text(it[2]),
      { line = BODY, left = INDENT, hanging = INDENT, tab = INDENT })
  end
  return out
end

local function body(out)
  local cs = chunks()
  local seen_heading, n = false, 0
  for i, t in ipairs(cs) do
    local ps
    local letter, rest = t:match("^(%u)%.[ \t]+(.*)$")
    if t:sub(1, 1) == "#" then
      seen_heading = true
      ps = heading(t)
    elseif t:match("^%d+%.[ \t]") or t:match("^[-*+][ \t]") then
      ps = list_items(t)
    elseif letter then
      ps = { p(plain(letter .. ".\t") .. text(rest),
        { line = BODY, left = LABEL, hanging = LABEL - INDENT, tab = LABEL }) }
    elseif t:match("^WHEREFORE") or not seen_heading then
      ps = { p(text(t), { line = BODY, first = INDENT }) }
    else
      n = n + 1
      ps = { p(plain(n .. ".\t") .. text(t), { line = BODY, first = INDENT, tab = LABEL }) }
    end
    if i == #cs then
      -- the last chunk stays on the signature's page, whole
      for k, x in ipairs(ps) do
        if not x:find(xe.KEEP, 1, true) then ps[k] = x:gsub("<w:pPr>", "<w:pPr>" .. xe.KEEP, 1) end
      end
    end
    for _, x in ipairs(ps) do out[#out + 1] = x end
  end
end

function Pandoc(doc)
  local out = {}
  cover(out)
  body(out)
  signature(out)
  verification(out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
