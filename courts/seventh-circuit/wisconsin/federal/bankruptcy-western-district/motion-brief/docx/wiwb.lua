-- W.D. Wis. bankruptcy motion and memorandum in support, docx engine (docs/DOCX.md). The paper as Word paragraphs,
-- so that it reads and breaks as typst/wiwb-motion-brief.typ does: the court title, the caption (Official Form 416B
-- for a contested matter; the ruled party column for an adversary proceeding), the title, the body (paragraphs,
-- headings, bulleted and numbered items, block quotations, footnotes) and the signature block. Every case word
-- comes from the sample's frontmatter and body, never from this file. Font, margins, the page number and the
-- footnote style are in docx/reference.xml (fb render builds the reference document from it).
--
-- The body is read chunk by chunk from the sample, as the typst template reads it (a chunk is the text between blank
-- lines; its first characters say what it is); a paragraph that refers to a footnote stays a pandoc paragraph (in
-- the Body Text style), so that pandoc writes the note.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line, 230 a
-- footnote line), the spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local BULLET = 1296                      -- typst para-indent + bullet-box: an item's text, 0.9 in
local HANG = 576                         -- typst heading-hang, 0.4 in
local TITLE_INSET = 720                  -- typst title-inset
local QUOTE = 720                        -- typst quote-inset
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360   -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_PAD = 185                      -- typst caption-pad, 10 pt (200 twips), less the 0.75 pt rule Word sets inside it
local DESIGNATION_RIGHT = 376            -- typst designation-right less caption-pad: 0.4 in - 10 pt
local SIG = 4896                         -- typst sig-col, 3.4 in
local COURT_GAP, CAPTION_GAP = 360, 276  -- typst court-gap, caption-gap
local TITLE_GAP = 480                    -- typst title-gap
local HEADING_GAP, QUOTE_GAP = 276, 276  -- typst heading-gap, quote-gap
local SIG_ABOVE, SIG_GAP, SIGNER_ABOVE = 792, 360, 48 -- typst sig-above, sig-gap, signer-above
local DESIGNATION_GAP, VERSUS_GAP, ADV_ABOVE = 120, 192, 48 -- typst designation-gap, versus-gap, adv-above
local ADV_BLANK = "____________"         -- typst adv-blank
local COURT_NAME = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF WISCONSIN" } -- Fed. R. Bankr. P. 9004(b)(1)

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- The frontmatter as written (fb render's $FORMBOOK_META), for the strings typst reads as markdown.
local META = (function()
  local f = assert(io.open(assert(os.getenv("FORMBOOK_META"), "wiwb.lua: needs fb render ($FORMBOOK_META)"), "r"))
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false)
end)()

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number ("§§ 157"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

local function fix(inl)
  return bind_doubled(pandoc.Inlines(inl):walk({ Str = breaks }))
end

-- Markdown text as blocks / inlines, read as typst's cmarker reads it (no "(a)" or "A." lists).
local function read(s)
  return pandoc.read(tostring(s), "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS).blocks
end

local function md(s)
  return fix(pandoc.utils.blocks_to_inlines(read(s)))
end

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

local function line(s, o)
  return p(xe.inl(md(s)), o)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
  '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'

local function caption(m)
  local left, right, lpr = {}, {}, ""
  local chapter = META.chapter ~= nil and ("Chapter " .. tostring(META.chapter)) or nil
  if META.caption == nil then
    -- Official Form 416B: a blank single line between the elements, no rules
    left = { line("In re:"), line(META.debtor, { before = CAPTION_GAP }),
      line("Debtor.", { before = CAPTION_GAP, left = INDENT }) }
    right = { line("Case No. " .. META.bankruptcy_case) }
    if chapter then right[#right + 1] = line(chapter, { before = CAPTION_GAP }) end
  else
    for _, l in ipairs({ "In re:", META.debtor, "Debtor.", "Case No. " .. META.bankruptcy_case }) do
      left[#left + 1] = line(l)
    end
    if chapter then left[#left + 1] = line(chapter) end
    for i, side in ipairs(META.caption) do
      for j, n in ipairs(side.names) do left[#left + 1] = line(n, { before = (i == 1 and j == 1) and CAPTION_GAP or 0 }) end
      left[#left + 1] = line(side.designation, { before = DESIGNATION_GAP, right = DESIGNATION_RIGHT, jc = "right" })
      if i < #META.caption then left[#left + 1] = line("v.", { before = VERSUS_GAP, after = VERSUS_GAP }) end
    end
    local adv = META.adversary_case ~= nil and tostring(META.adversary_case) or ""
    right = { p(xe.runs("Adversary Case No.", { b = true }) .. xe.inl(md(" " .. (adv ~= "" and adv or ADV_BLANK))),
      { before = ADV_ABOVE }) }
    lpr = RULES
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT - CAP_GUTTER) ..
    '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(CAP_LEFT, lpr, left) .. cell(CAP_GUTTER, "", { p("") }) ..
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, "", right) .. '</w:tr></w:tbl>'
end

local function cover(m, out)
  for _, t in ipairs(COURT_NAME) do out[#out + 1] = p(xe.runs(t, { b = true }), { jc = "center" }) end
  out[#out + 1] = p("", { line = COURT_GAP })
  out[#out + 1] = caption(m)
  local title = md(META.title):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  out[#out + 1] = p(xe.inl(title, { b = true }), { before = TITLE_GAP, after = TITLE_GAP, left = TITLE_INSET,
    right = TITLE_INSET, jc = "center" })
end

-- ---------------------------------------------------------------------------
-- Signature
-- ---------------------------------------------------------------------------

local function signature(out)
  local sig = META.signature
  local ls = {}
  if sig.closing ~= nil then ls[#ls + 1] = { "", xe.inl(md(sig.closing)), 0 } end
  if sig.firm ~= nil then ls[#ls + 1] = { "", xe.inl(md(sig.firm), { b = true }), #ls > 0 and SIG_GAP or 0 } end
  ls[#ls + 1] = { META.date ~= nil and xe.inl(md(META.date)) or "", xe.inl(md("By: /s/ " .. sig.signer)),
    #ls > 0 and SIG_GAP or 0 }
  for k, l in ipairs(sig.lines or {}) do ls[#ls + 1] = { "", xe.inl(md(l)), k == 1 and SIGNER_ABOVE or 0 } end
  for i, l in ipairs(ls) do
    out[#out + 1] = p(l[1] .. xe.runs("\t") .. l[2], { before = i == 1 and SIG_ABOVE or l[3], left = SIG,
      hanging = SIG, tab = SIG, keep = i < #ls })
  end
end

-- ---------------------------------------------------------------------------
-- Body: the chunks of typst's brief-body()
-- ---------------------------------------------------------------------------

local function chunks()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local body = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  local out = {}
  for c in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    c = c:match("^%s*(.-)%s*$")
    if c ~= "" then out[#out + 1] = c end
  end
  return out, body
end

local function has_note(inl)
  local found = false
  pandoc.Inlines(inl):walk({ Note = function() found = true end })
  return found
end

-- Headings at the type size on the single pitch, a blank single line above and below, kept with the text: level 1
-- centered bold capitals, level 2 bold, its lines after the first hanging 0.4 in.
local function heading(t, defs)
  local b = read(t .. defs)[1]
  local lvl = math.min(b.level, 2)
  local inl = fix(b.content)
  if lvl == 1 then inl = inl:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end }) end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(HEADING_GAP, HEADING_GAP, SINGLE),
    lvl == 1 and xe.ind(0, nil, 0) or xe.ind(HANG, HANG, nil), xe.jc(lvl == 1 and "center" or "left") },
    xe.inl(inl, { b = true }))
end

-- A body paragraph; one that carries a footnote is left to pandoc (Body Text: the same pitch and indent), which
-- writes the note.
local function bodypar(inl, keep, out)
  if has_note(inl) then
    out[#out + 1] = pandoc.Div({ pandoc.Para(xe.inlines(inl)) }, { ["custom-style"] = keep and "Body Text Keep" or "Body Text" })
  else
    out[#out + 1] = xe.raw(p(xe.inl(inl), { line = BODY, first = INDENT, keep = keep }))
  end
end

local function body(out)
  local list, src = chunks()
  local notes = {}
  for id, text in src:gmatch("\n%[%^([^%]]+)%]:[ \t]*([^\n]*)") do notes[id] = text end
  local kept = {}
  for _, c in ipairs(list) do if not c:match("^%[%^[^%]]+%]:") then kept[#kept + 1] = c end end
  for i, t in ipairs(kept) do
    local defs = ""
    for id in t:gmatch("%[%^([^%]]+)%]") do defs = defs .. "\n\n[^" .. id .. "]: " .. (notes[id] or "") end
    local last = i == #kept
    if t:sub(1, 1) == "#" then
      out[#out + 1] = xe.raw(heading(t, defs))
    elseif t:sub(1, 1) == ">" then
      local q = t:gsub("\n>[ \t]?", "\n"):gsub("^>[ \t]?", "")
      out[#out + 1] = xe.raw(p(xe.inl(md(q .. defs)), { before = QUOTE_GAP, after = QUOTE_GAP, left = QUOTE,
        right = QUOTE, keep = last }))
    elseif t:match("^%d+%.[ \t]") or t:match("^[-*+][ \t]") then
      local bullet = t:match("^[-*+]") ~= nil
      local items = {}
      for l in (t .. "\n"):gmatch("(.-)\n") do
        local rest = l:match("^%d+%.[ \t]+(.*)$") or l:match("^[-*+][ \t]+(.*)$")
        if rest then items[#items + 1] = rest elseif #items > 0 then items[#items] = items[#items] .. "\n" .. l end
      end
      for k, item in ipairs(items) do
        local label = bullet and "\u{2022}" or (k .. ".")
        local inl, keep = md(item .. defs), last and k == #items
        if has_note(inl) then
          local c = pandoc.Inlines({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
          c:extend(xe.inlines(inl))
          out[#out + 1] = pandoc.Div({ pandoc.Para(c) }, { ["custom-style"] = keep and "List Note Keep" or "List Note" })
        else
          out[#out + 1] = xe.raw(p(xe.runs(label .. "\t") .. xe.inl(inl),
            { line = BODY, left = BULLET, hanging = BULLET - INDENT, tab = BULLET, keep = keep }))
        end
      end
    else
      bodypar(md(t .. defs), last, out)
    end
  end
end

function Pandoc(doc)
  local out = {}
  cover(doc.meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  body(res)
  local sig = {}
  signature(sig)
  for _, x in ipairs(sig) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
