-- E.D. Wis. bankruptcy motion with brief in support, docx engine (docs/DOCX.md). The four papers as Word paragraphs,
-- so that they read and break as typst/wieb-motion-brief.typ does: the notice of motion (LR 9014-1), the motion and
-- the brief in support (each with its caption: the court title, a table whose second row, the parties, is ruled
-- above and below), and the certificate of service (LR 9013-2), each starting a page; every signature block kept
-- whole. The motion and the brief are the sample's body split at "<!-- BRIEF -->". Every case word comes from the
-- sample's frontmatter and body, never from this file. Font, margins and the page number are in
-- docx/reference.xml (fb render builds the reference document from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 276            -- typst pitch-body 24 pt, pitch-single 13.8 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUMBER = 1440                      -- typst para-indent + number-box: a numbered paragraph's text, 1 in
local QUOTE = 720                        -- typst quote-inset
local CAP_COL, CAP_GUTTER = 4392, 576    -- typst caption-col 3.05 in, caption-gutter 0.4 in
local CAP_INDENT = 720                   -- typst caption-indent
local DESIGNATION, VERSUS = 3168, 1296   -- typst designation-indent 2.2 in, versus-indent 0.9 in
local CAP_PAD = 144                      -- typst caption-pad, 7.2 pt
local CAP_PAD_RULED = 129                -- the same less the 0.75 pt rule Word sets inside the ruled row
local SIG = 4680                         -- typst sig-indent, 3.25 in
local SERVICE = 720                      -- typst service-indent
local COURT_GAP, TITLE_GAP = 288, 192    -- typst court-gap, title-gap
local H = { { 288, 144 }, { 240, 144 }, { 192, 120 } } -- typst h1/h2/h3 above and below
local QUOTE_GAP = 240                    -- typst quote-gap
local SIG_ABOVE, SIG_GAP, SIGNER_GAP = 288, 192, 48 -- typst sig-above, sig-gap, signer-gap
local SERVICE_GAP = 240                  -- typst service-gap
local BRIEF = "<!-- BRIEF -->"

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- The frontmatter as written (fb render's $FORMBOOK_META), for the strings typst reads as markdown.
local META = (function()
  local f = assert(io.open(assert(os.getenv("FORMBOOK_META"), "wieb.lua: needs fb render ($FORMBOOK_META)"), "r"))
  local s = f:read("a")
  f:close()
  return pandoc.json.decode(s, false)
end)()

local function need(key)
  local v = META[key]
  if v == nil then error("wieb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  local t = s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^/%d%s])", "/\u{200B}%1")
  if t ~= s.text then return pandoc.Str(t) end
end

-- A doubled sign stays with its number (typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
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

-- Markdown text as inlines, read as typst's cmarker reads it.
local function md(s)
  local doc = pandoc.read(tostring(s), "markdown+smart-fancy_lists", PANDOC_READER_OPTIONS)
  return fix(pandoc.utils.blocks_to_inlines(doc.blocks))
end

-- A paragraph: o = { before, after, line, left, right, first, jc, keep, tab, brk }; single pitch by default.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body or "")
end

-- A single line of markdown text (typst: sline); "" a blank line.
local function line(s, o)
  return p(s == "" and "" or xe.inl(md(s)), o)
end

-- A body paragraph on the body pitch, its first line indented.
local function bodypar(inl, o)
  o = o or {}
  o.line, o.first = BODY, INDENT
  return p(xe.inl(inl), o)
end

-- ---------------------------------------------------------------------------
-- Caption, title, signature
-- ---------------------------------------------------------------------------

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local RULED = '<w:tcBorders><w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
  '<w:tcMar><w:top w:w="' .. CAP_PAD_RULED .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_PAD_RULED .. '" w:type="dxa"/></w:tcMar>'
local PADDED = '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'

local function caption(out, brk)
  local d, pl, df = need("debtor"), need("plaintiff"), need("defendant")
  out[#out + 1] = p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center", brk = brk })
  out[#out + 1] = p(xe.runs("EASTERN DISTRICT OF WISCONSIN", { b = true }), { jc = "center" })
  -- the court title to the caption: an empty 1 pt line takes the space typst sets above the table
  out[#out + 1] = p("", { line = COURT_GAP })
  local left1 = { line("In re:"), line(""), line(d.name, { left = CAP_INDENT }), line(d.designation, { left = CAP_INDENT }) }
  local right1 = { line(""), line(""), line(d.case_number), line(d.chapter) }
  local left2, right2 = {}, {}
  for _, n in ipairs(pl.names) do left2[#left2 + 1] = line(n) end
  left2[#left2 + 1] = line(pl.designation, { left = DESIGNATION })
  left2[#left2 + 1] = line("")
  left2[#left2 + 1] = line("v.", { left = VERSUS })
  left2[#left2 + 1] = line("")
  for _, n in ipairs(df.names) do left2[#left2 + 1] = line(n) end
  left2[#left2 + 1] = line(df.designation, { left = DESIGNATION })
  for _ = 1, #pl.names + 2 do right2[#right2 + 1] = line("") end
  right2[#right2 + 1] = line(need("adversary_number"))
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. (2 * CAP_COL + CAP_GUTTER) .. '" w:type="dxa"/>' ..
    '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
    '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" ' ..
    'w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_COL .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/><w:gridCol w:w="' ..
    CAP_COL .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(CAP_COL, PADDED, left1) .. cell(CAP_GUTTER, PADDED, { p("") }) ..
    cell(CAP_COL, PADDED, right1) .. '</w:tr>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(CAP_COL, RULED, left2) .. cell(CAP_GUTTER, RULED, { p("") }) ..
    cell(CAP_COL, RULED, right2) .. '</w:tr></w:tbl>'
end

local function title(out, s, o)
  o = o or {}
  o.after, o.jc, o.keep = TITLE_GAP, "center", true
  out[#out + 1] = p(xe.inl(md(s), { b = true }), o)
end

-- "Dated:", then each signer at SIG; kept whole (typst: a block that does not break).
local function signature(out, respectfully)
  local ls = { { xe.runs("Dated: " .. plain(need("dated"))), SIG_ABOVE, 0 } }
  for _, s in ipairs(need("signers")) do
    if respectfully then
      ls[#ls + 1] = { xe.runs("Respectfully submitted,"), SIG_ABOVE, SIG }
      ls[#ls + 1] = { xe.runs("/s/ " .. plain(s.signer)), SIG_GAP, SIG }
    else
      ls[#ls + 1] = { xe.runs("/s/ " .. plain(s.signer)), SIG_ABOVE, SIG }
    end
    for i, l in ipairs(s.lines or {}) do ls[#ls + 1] = { xe.inl(md(l)), i == 1 and SIGNER_GAP or 0, SIG } end
  end
  for i, l in ipairs(ls) do out[#out + 1] = p(l[1], { before = l[2], left = l[3], keep = i < #ls }) end
end

-- ---------------------------------------------------------------------------
-- Body: the blocks of the motion or the brief as typst's show rules set them
-- ---------------------------------------------------------------------------

local function heading(b)
  local lvl = math.min(b.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(H[lvl][1], H[lvl][2], SINGLE), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(fix(b.content), { b = lvl <= 2, i = lvl == 3 }))
end

local function blocks(list, out)
  for _, b in ipairs(list) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = bodypar(fix(b.content))
    elseif b.t == "OrderedList" then
      local n = b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(fix(pandoc.utils.blocks_to_inlines(item))),
          { line = BODY, first = INDENT, tab = NUMBER })
        n = n + 1
      end
    elseif b.t == "BlockQuote" then
      for i, q in ipairs(b.content) do
        out[#out + 1] = p(xe.inl(fix(pandoc.utils.blocks_to_inlines({ q }))), { before = i == 1 and QUOTE_GAP or 0,
          after = i == #b.content and QUOTE_GAP or 0, left = QUOTE, right = QUOTE })
      end
    else
      error("wieb.lua: unsupported block " .. b.t)
    end
  end
end

function Pandoc(doc)
  local days = tonumber(need("objection_days"))
  if not days or days < 14 or days ~= math.floor(days) then
    error("wieb-motion-brief: `objection_days` must be an integer of at least 14 (LR 9014-1(a)(2)(A))", 0)
  end
  local motion, brief, target, marks = {}, {}, nil, 0
  target = motion
  for _, b in ipairs(doc.blocks) do
    if b.t == "RawBlock" and b.text:find(BRIEF, 1, true) then
      marks = marks + 1
      target = brief
    else
      target[#target + 1] = b
    end
  end
  if marks ~= 1 then error("wieb-motion-brief: the body must contain exactly one `" .. BRIEF .. "` line", 0) end

  local t, bt = need("title"), need("brief_title")
  local out = {}

  -- 1. Notice of motion (LR 9014-1(a)(1)(A) and (a)(2)).
  title(out, "Notice of Motion")
  out[#out + 1] = bodypar(md("PLEASE TAKE NOTICE that " .. need("movants") .. " " .. need("notice_verb") ..
    " the attached " .. t .. " and " .. bt .. " (together, the \"Motion\")."))
  out[#out + 1] = bodypar(md("If you want the court to consider your views on the Motion, or want a hearing, you must file and serve a written objection no later than " .. math.floor(days) .. " days after the date of service of this notice (LR 9014-1(a)(2)(A)). An objection must be filed with the Clerk of the Bankruptcy Court and served on the movant."))
  out[#out + 1] = bodypar(md("Absent a timely filed objection, the court may grant the relief requested without a hearing (LR 9014-1(a)(2)(B)). If no objection is timely filed, the movant will file a proposed order as required by LR 9014-2. If a timely objection is filed, the court may schedule a hearing, and the Clerk will give notice of the hearing (LR 9014-1(a)(3))."))
  signature(out, true)

  -- 2. Motion; 3. brief in support: each with its caption and title.
  for _, part in ipairs({ { t, motion }, { bt, brief } }) do
    caption(out, true)
    title(out, part[1], { before = COURT_GAP })
    blocks(part[2], out)
    signature(out, true)
  end

  -- 4. Certificate of service (LR 9013-2(a)).
  local c = need("certificate")
  title(out, "Certificate of Service", { brk = true })
  out[#out + 1] = bodypar(md("I hereby certify that on " .. need("dated") .. " the " .. t .. " and the " .. bt ..
    " were electronically filed in this case and served upon the following parties using the CM/ECF system:"))
  for _, n in ipairs(c.ecf or {}) do out[#out + 1] = line(n, { left = SERVICE }) end
  out[#out + 1] = bodypar(md("I further certify that on the same date I mailed the same document(s) by United States Mail to the following non-ECF participants:"))
  for i, n in ipairs(c.non_ecf or {}) do
    local ls = { n.name }
    for _, l in ipairs(n.lines or {}) do ls[#ls + 1] = l end
    for j, l in ipairs(ls) do
      out[#out + 1] = line(l, { left = SERVICE, before = (j == 1 and i > 1) and SERVICE_GAP or 0, keep = j < #ls })
    end
  end
  signature(out, false)

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  -- The frontmatter is laid out above; pandoc must not print its title or date.
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
