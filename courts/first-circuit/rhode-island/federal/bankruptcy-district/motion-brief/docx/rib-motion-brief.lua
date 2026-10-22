-- Pandoc Lua filter for the rib motion with memorandum (docx engine). The same form as typst/rib-motion-brief.typ and
-- the same contract: every case-specific string comes from the sample (its YAML frontmatter and body). The caption and
-- title; the motion (unnumbered paragraphs, "1." lists, block quotations, headings); the LBR 1005-1(d)(1) response
-- language kept with the signature block; a page break and the memorandum with its own caption, title and signature
-- ("Of Counsel" lines); the certificate of service on a new page. The sample's "---" line separates the motion from
-- the memorandum. The body is split into blocks at blank lines as the typst template splits it, each read as
-- commonmark (the reader of typst's cmarker), a block that refers to a footnote together with its definition.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs stay pandoc
-- paragraphs (style "Body Text", or "Body Text Note" in reference.xml), so pandoc writes their footnotes.

local xe = require("docx.xengine")

local COURT = { "UNITED STATES BANKRUPTCY COURT", "DISTRICT OF RHODE ISLAND" }
-- LBR 1005-1(d)(1): the response-time language, verbatim as in the typst template
local RESPONSE_DEFAULT = "Within fourteen (14) days after service, if served electronically, as evidenced by the certification, and an additional three (3) days pursuant to Fed. R. Bank. P. 9006(f) if served by mail or other excepted means specified, any party against whom such paper has been served, or any other party who objects to the relief sought, shall serve and file an objection or other appropriate response to said paper with the Bankruptcy Court Clerk's Office, 380 Westminster Street, 6th Floor, Providence, RI 02903, (401) 626-3100. If no objection or other response is timely filed, the paper will be deemed unopposed and will be granted unless: (1) the requested relief is forbidden by law; (2) the requested relief is against public policy; or (3) in the opinion of the Court, the interest of justice requires otherwise."
local BODY, SINGLE = 480, 276             -- typst pitch-double, pitch-single
local GAP, HALF = 276, 138                -- typst gap, half-gap
local INDENT = 720                        -- typst para-indent, 0.5 in
local TEXTW = 9360                        -- 6.5 in
local CAP_LEFT = 4752                     -- typst caption-left, 3.3 in
local CAP_PAD, CAP_FOOT = 155, 145        -- typst caption-pad 10 pt, caption-foot 8 pt, less what LibreOffice adds for the rule
local CAP_RIGHT = 504                     -- typst caption-right, 0.35 in
local LABEL = 576                         -- typst label-box, 0.4 in
local QUOTE_L, QUOTE_R = 1080, 720        -- typst quote-left 0.75 in, quote-right 0.5 in
local QUOTE = 240                         -- typst pitch-double / 2 around a quotation
local SIG = 4320                          -- typst sig-col, 3 in
local CERT_SIG = 5040                     -- typst cert-sig, 3.5 in
local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- a meta list (or a single value) as a Lua array
local function list(v)
  if v == nil then return {} end
  if type(v) == "table" and v[1] ~= nil and v[1].t == nil then return v end
  if pandoc.utils.type(v) == "List" then return v end
  return { v }
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tab_at(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

local TAB = "<w:r><w:tab/></w:r>"

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("and/or": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 157"; typst binds it too; xe.inl binds a single sign).
local function bind_doubled(l)
  for i = 1, #l - 1 do
    local a = l[i]
    if a.t == "Str" and l[i + 1].t == "Space" and #a.text >= 4 and a.text:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- A markdown string read as typst's cmarker reads it.
local function read(md)
  return pandoc.read(md, "commonmark+smart").blocks:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
end

local function inlines(md)
  local b = read(md)[1]
  return b and b.content or pandoc.Inlines({})
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title
-- ---------------------------------------------------------------------------

local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

-- The caption: the bankruptcy case (In re) above, the adversary parties below, in a column ruled on the right and at
-- the foot; the chapter and case numbers on the right.
local function caption(meta)
  local left = { p(xe.runs("IN RE:")) }
  for i, n in ipairs(list(meta.in_re)) do left[#left + 1] = p(xe.inl(n), { before = i == 1 and HALF or 0 }) end
  left[#left + 1] = p(xe.inl(meta.debtor_designation), { jc = "right" })
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for i, n in ipairs(list(party.names)) do
      left[#left + 1] = p(xe.inl(n), { before = (k == 1 and i == 1) and GAP or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local right = {
    p(xe.runs("Chapter ") .. xe.inl(meta.chapter)),
    p(xe.runs("Bankruptcy Case No. ") .. xe.inl(meta.case_number)),
    p(xe.runs("Adversary Proceeding No. ") .. xe.inl(meta.adversary_number), { before = HALF }),
  }
  local lw, rw = CAP_LEFT, TEXTW - CAP_LEFT
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. lw .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. lw .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE ..
    '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. rw .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_RIGHT ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
end

local function titled_caption(meta, title, new_page, out)
  for i, l in ipairs(COURT) do
    -- the caption stands a double line below the court title (typst: the caption block's above)
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", keep = true, after = i == #COURT and BODY or 0,
      brk = new_page and i == 1 })
  end
  out[#out + 1] = caption(meta)
  -- Word has no space after a table: the title takes it
  out[#out + 1] = p(xe.inl(upper(inlines(plain(title))), { b = true }), { jc = "center", before = BODY, after = SINGLE, keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature block: the case line (LBR 1005-1(a)), the date beside "Respectfully submitted,", the signature column,
-- any "Of Counsel" lines. Lines are added to `lines`; the caller chains them so the block never splits.
-- ---------------------------------------------------------------------------

local function signature(meta, of_counsel, lines, first_before)
  local sig = meta.signature
  local function add(body, before, left, tabs) lines[#lines + 1] = { body = body, before = before or 0, left = left or SIG, tabs = tabs } end
  local names = {}
  for _, n in ipairs(list(meta.in_re)) do names[#names + 1] = plain(n) end
  add(xe.runs("In re " .. table.concat(names, ", ") .. ", Debtor; Chapter " .. plain(meta.chapter) ..
    "; Bankruptcy Case No. " .. plain(meta.case_number) .. "; Adversary Proceeding No. " .. plain(meta.adversary_number)),
    first_before, 0)
  local dated = meta.date and (xe.runs("Dated: ") .. xe.inl(meta.date)) or ""
  add(dated .. TAB .. xe.runs("Respectfully submitted,"), GAP, 0, tab_at(SIG))
  add(xe.inl(sig.client), GAP)
  add(xe.inl(sig.by))
  add(xe.runs("/s/ ") .. xe.inl(sig.signer), GAP)
  add(xe.inl(sig.signer))
  for _, l in ipairs(list(sig.firm)) do add(xe.inl(l)) end
  add(xe.runs("RI Bar No. ") .. xe.inl(sig.bar_id))
  for _, l in ipairs(list(sig.lines)) do add(xe.inl(l)) end
  for i, l in ipairs(of_counsel or {}) do add(xe.inl(l), i == 1 and GAP or 0, 0) end
end

-- Paragraphs that never break across a page: each kept with the next, the last one ends the chain.
local function chain(lines, out)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l.body, { before = l.before, after = l.after, line = l.line, left = l.left, first = l.first,
      tabs = l.tabs, jc = l.jc, brk = l.brk, keep = i < #lines })
  end
end

-- The certificate of service: on a new page, the CM/ECF statement, the recipients, the signer.
local function certificate(meta, out)
  local c = meta.certificate
  local lines = { { body = xe.runs("CERTIFICATE OF SERVICE", { b = true }), jc = "center", brk = true } }
  lines[#lines + 1] = { body = xe.inl(inlines("I hereby certify that on " .. plain(c.date) ..
    ", I electronically filed the within " .. plain(meta.title) .. " with the Clerk of the Bankruptcy Court for the District" ..
    " of Rhode Island using the CM/ECF System. The following participant has received notice electronically:")),
    before = SINGLE, line = BODY, first = INDENT }
  for i, l in ipairs(list(c.recipients)) do
    lines[#lines + 1] = { body = xe.inl(l), before = i == 1 and HALF or 0, left = INDENT }
  end
  lines[#lines + 1] = { body = xe.runs("/s/ ") .. xe.inl(meta.signature.signer), before = BODY, left = CERT_SIG }
  lines[#lines + 1] = { body = xe.inl(meta.signature.signer), left = CERT_SIG }
  chain(lines, out)
end

-- ---------------------------------------------------------------------------
-- The body, block by block as the typst template splits it
-- ---------------------------------------------------------------------------

local function chunks(src)
  local out, pos = {}, 1
  while true do
    local s, e = src:find("\n[ \t]*\n", pos)
    local c = src:sub(pos, s and s - 1 or #src):gsub("^%s+", ""):gsub("%s+$", "")
    if c ~= "" then out[#out + 1] = c end
    if not s then break end
    pos = e + 1
  end
  return out
end

local function has_note(l)
  for _, el in ipairs(l) do
    if el.t == "Note" then return true end
  end
  return false
end

local function body(src, defs, out)
  for _, t in ipairs(chunks(src)) do
    if t:match("^%[%^[^%]]+%]:") then
      -- a footnote definition: read with the block that refers to it
    elseif t:sub(1, 1) == "#" then
      local hashes, rest = t:match("^(#+)%s*(.-)%s*#*$")
      local lvl = #hashes
      local txt = inlines(rest)
      if lvl == 1 then txt = upper(txt) end
      out[#out + 1] = xe.raw(xe.para({ xe.style("Heading" .. math.min(lvl, 3)), xe.KEEP, xe.spacing(0, 0, BODY),
        xe.ind(0, nil, 0), xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(txt, { b = true, i = lvl >= 3 })))
    elseif t:match("^%d+%.[ \t]") then
      -- a numbered list: the number in a box after the paragraph indent, the text hanging after it
      local items, i = {}, 0
      for line in (t .. "\n"):gmatch("(.-)\n") do
        if line:match("^%d+%.[ \t]") then items[#items + 1] = line:gsub("^%d+%.[ \t]+", "")
        else items[#items] = items[#items] .. "\n" .. line end
      end
      for _, item in ipairs(items) do
        i = i + 1
        out[#out + 1] = xe.raw(p(xe.runs(i .. ".") .. TAB .. xe.inl(inlines(item)),
          { line = BODY, left = INDENT + LABEL, hanging = LABEL, tabs = tab_at(INDENT + LABEL) }))
      end
    elseif t:sub(1, 1) == ">" then
      -- a quotation: single-spaced, indented on both sides, half a double line off the text
      local paras = read(t)[1].content
      for i, b in ipairs(paras) do
        out[#out + 1] = xe.raw(p(xe.inl(b.content), { left = QUOTE_L, right = QUOTE_R, before = i == 1 and QUOTE or GAP,
          after = i == #paras and QUOTE or 0 }))
      end
    else
      -- a paragraph, with the definitions of the footnotes it refers to; pandoc writes it and its notes
      local full = t
      for key in t:gmatch("%[%^([^%]]+)%]") do
        if defs[key] then full = full .. "\n\n" .. defs[key] end
      end
      local b = pandoc.read(full, "commonmark+smart+footnotes").blocks:walk({ Str = breaks })
        :walk({ Inlines = bind_doubled }):walk({ Inlines = xe.inlines })[1]
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = has_note(b.content) and "Body Text Note" or "Body Text" })
    end
  end
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local f = io.open(PANDOC_STATE.input_files[1], "r")
  local src = f:read("a")
  f:close()
  src = src:gsub("\r", ""):gsub("^%-%-%-\n.-\n%-%-%-[ \t]*\n", "", 1)
  -- footnote definitions by key
  local defs = {}
  for _, c in ipairs(chunks(src)) do
    local key = c:match("^%[%^([^%]]+)%]:")
    if key then defs[key] = c end
  end
  -- the motion, then (after a line holding only ---) the memorandum
  local s, e = src:find("\n%-%-%-[ \t]*\n")
  local motion = s and src:sub(1, s) or src
  local memo = s and src:sub(e + 1) or nil

  local out = {}
  local function emit(xml) out[#out + 1] = xe.raw(xml) end
  local cover = {}
  titled_caption(meta, meta.title, false, cover)
  for _, x in ipairs(cover) do emit(x) end
  body(motion, defs, out)
  -- the response-time language and the signature, chained so they never split
  local lines = {}
  if plain(meta.response) ~= "none" then
    local text = meta.response_text and plain(meta.response_text) or RESPONSE_DEFAULT
    lines[#lines + 1] = { body = xe.runs(text), before = SINGLE, after = BODY, first = INDENT }
    signature(meta, nil, lines, 0)
  else
    signature(meta, nil, lines, SINGLE)
  end
  local x = {}
  chain(lines, x)
  for _, y in ipairs(x) do emit(y) end

  if memo then
    local c = {}
    titled_caption(meta, meta.memorandum_title, true, c)
    for _, y in ipairs(c) do emit(y) end
    body(memo, defs, out)
    local oc = nil
    if meta.of_counsel then oc = list(meta.of_counsel) end
    local l2, x2 = {}, {}
    signature(meta, oc, l2, SINGLE)
    chain(l2, x2)
    for _, y in ipairs(x2) do emit(y) end
  end

  if meta.certificate then
    local x3 = {}
    certificate(meta, x3)
    for _, y in ipairs(x3) do emit(y) end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
