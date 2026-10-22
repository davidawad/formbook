-- Pandoc filter for the ilnd memorandum in support of a motion, engine docx, so that it reads and breaks as
-- typst/ilnd-motion-brief.typ does: a cover (its own section, no page number) with the court title, the ")" caption,
-- the title and the counsel block; then the body (its own section, numbered from 1): headings with their typed labels,
-- paragraphs double-spaced with native footnotes, quotations, lists, the signature block kept together with the last
-- paragraph, and the certificate of service on its own page. Every case word comes from the sample's frontmatter and
-- body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs, headings
-- (they may carry a footnote), quotations, list items and footnotes are written by pandoc in the styles of
-- docx/reference.xml; the cover, signature and certificate here.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local BLANK, HEAD_BELOW = 276, 138       -- typst blank 13.8 pt, head-below 6.9 pt
local TITLE_GAP, COUNSEL_GAP = 552, 1104 -- typst title-gap 27.6 pt, counsel-gap 55.2 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local PARTY, PAREN = 4608, 432           -- typst caption-left 3.2 in, caption-paren 0.3 in
local DESIGNATION, VERSUS = 720, 1440    -- typst designation-indent 0.5 in, versus-indent 1 in
local COUNSEL = 4752                     -- typst counsel-left 3.3 in
local SIG = 4320                         -- typst sig-left 3 in
local FOOTER = 735                       -- the page number's line 36.75 pt above the page foot (typst footer-descent 30 %)

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, tab, brk }.
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

-- Inlines in capitals (typst upper), footnotes left as written.
local function upper(x)
  local out = pandoc.Inlines({})
  for _, el in ipairs(x) do
    if el.t == "Str" then
      out:insert(pandoc.Str(pandoc.text.upper(el.text)))
    elseif el.t == "Note" then
      out:insert(el)
    elseif el.content and pandoc.utils.type(el.content) == "Inlines" then
      local c = el:clone()
      c.content = upper(el.content)
      out:insert(c)
    else
      out:insert(el)
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title, counsel
-- ---------------------------------------------------------------------------

-- Caption: a borderless three-column table, one row per single line (typst caption()): each party's names, a blank
-- row and its designation, then a blank row, "v." and a blank row between the parties; a ")" on every row; the case
-- number, a blank row and the judge on the rows at the middle of the caption.
local function caption(meta, out)
  local rows = {}
  local parties = meta.caption.parties
  for k, side in ipairs(parties) do
    for _, n in ipairs(side.names) do rows[#rows + 1] = { xe.inl(n), 0 } end
    rows[#rows + 1] = false
    rows[#rows + 1] = { xe.inl(side.designation), DESIGNATION }
    if k < #parties then
      rows[#rows + 1] = false
      rows[#rows + 1] = { xe.runs("v."), VERSUS }
      rows[#rows + 1] = false
    end
  end
  local right = { xe.runs("Case No. " .. plain(meta.case_number)) }
  if meta.judge then
    right[#right + 1] = false
    right[#right + 1] = xe.runs("Honorable " .. plain(meta.judge))
  end
  local first = (#rows - #right) // 2
  local function cell(w, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
  end
  local trs = {}
  for i, r in ipairs(rows) do
    local rt = right[i - first]
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
      cell(PARTY, r and p(r[1], { left = r[2] }) or p("")) ..
      cell(PAREN, p(xe.runs(")"))) ..
      cell(TEXTW - PARTY - PAREN, rt and p(rt) or p("")) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. PARTY .. '"/><w:gridCol w:w="' .. PAREN .. '"/><w:gridCol w:w="' ..
    (TEXTW - PARTY - PAREN) .. '"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local function cover(meta, out)
  local court = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF ILLINOIS" }
  if meta.division then court[#court + 1] = pandoc.text.upper(plain(meta.division)) end
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #court and BLANK or 0 })
  end
  caption(meta, out)
  -- the title: Word has no space after a table, so it takes the space before it
  for i, l in ipairs(meta.brief_title) do
    out[#out + 1] = p(xe.inl(l, { b = true }), { before = i == 1 and TITLE_GAP or 0, jc = "center" })
  end
  for k, g in ipairs(meta.counsel or {}) do
    for i, l in ipairs(g) do
      out[#out + 1] = p(xe.inl(l), { before = i > 1 and 0 or (k == 1 and COUNSEL_GAP or BLANK), left = COUNSEL })
    end
  end
end

-- ---------------------------------------------------------------------------
-- Signature and certificate (Fed. R. Civ. P. 11(a), 5(b))
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature
  local rows = { { xe.runs("Dated: " .. plain(meta.date) .. "\tRespectfully submitted,"), 0, BLANK } }
  for i, l in ipairs(sig.party) do rows[#rows + 1] = { xe.inl(l), SIG, i == 1 and BLANK or 0 } end
  rows[#rows + 1] = { xe.runs("By: /s/ ") .. xe.inl(sig.signer), SIG, BLANK }
  for _, l in ipairs(sig.role) do rows[#rows + 1] = { xe.inl(l), SIG, 0 } end
  for i, r in ipairs(rows) do
    out[#out + 1] = p(r[1], { left = r[2], before = r[3], keep = i < #rows, tab = i == 1 and SIG or nil })
  end
end

local function certificate(meta, out)
  local c = meta.certificate
  if not c then return end
  -- its own page: Word keeps the space above a paragraph after a page break, typst drops it, so none here
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true, u = true }),
    { after = HEAD_BELOW, jc = "center", keep = true, brk = true })
  out[#out + 1] = p(xe.inl(c.text), { line = BODY, first = INDENT })
  local lines = { "/s/ " .. plain(c.signer) }
  for _, l in ipairs(c.role) do lines[#lines + 1] = l end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.inl(l), { left = COUNSEL, before = i == 1 and BODY or 0, keep = i < #lines })
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

-- A heading's typed label ("I.", "A.", "1.": its first word) and the rest of its inlines (typst split-label).
local function split_label(inl)
  local a, b = inl[1], inl[2]
  if a and a.t == "Str" and b and b.t == "Space" and
    (a.text:match("^[IVXLC]+%.$") or a.text:match("^%a%.$") or a.text:match("^%d+%.$")) then
    local rest = pandoc.Inlines({})
    for i = 3, #inl do rest:insert(inl[i]) end
    return a.text, rest
  end
  return "", inl
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
-- In a web address typst also breaks after "//" and after each "/", ".", "-", "_", "?", "=", "&", "#" inside it:
-- a zero-width space there too.
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

-- A doubled sign stays with its number ("¶¶ 14–15": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/>' .. pg .. "</w:sectPr>"
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  assert(meta.caption and meta.caption.parties, "ilnd-motion-brief: frontmatter needs caption.parties")
  assert(meta.brief_title, "ilnd-motion-brief: frontmatter needs brief_title")
  assert(meta.signature, "ilnd-motion-brief: frontmatter needs signature")
  local out = {}
  local function raw(list)
    for _, x in ipairs(list) do out[#out + 1] = xe.raw(x) end
  end

  local cov = {}
  cover(meta, cov)
  -- the paragraph that ends the cover's section (a 1 pt line, so it pushes nothing on); no page number there
  cov[#cov + 1] = '<w:p><w:pPr>' .. xe.spacing(0, 0, 20) .. sect_pr("rIdFtrNone") .. '</w:pPr></w:p>'
  raw(cov)

  local blocks = doc.blocks
  -- the last paragraph and the headings right before it stay with the signature block
  local tail = #blocks
  while tail > 1 and blocks[tail - 1].t == "Header" do tail = tail - 1 end
  for i, b in ipairs(blocks) do
    local keep = i >= tail
    if b.t == "Header" then
      local lv = math.min(b.level, 4)
      local style = "Head " .. lv .. (i == 1 and " Top" or "")
      local inl
      if lv == 1 then
        inl = upper(b.content)
      else
        local lab, rest = split_label(b.content)
        inl = pandoc.Inlines({ pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        inl:extend(rest)
      end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
    elseif b.t == "Para" or b.t == "Plain" then
      local style = keep and "Body Keep" or has_note(b.content) and "Body Text Note" or "Body Text"
      out[#out + 1] = pandoc.Div({ pandoc.Para(b.content) }, { ["custom-style"] = style })
    elseif b.t == "BlockQuote" then
      out[#out + 1] = b
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    else
      error("ilnd-motion-brief.lua: unsupported block " .. b.t)
    end
  end

  local tl = {}
  signature(meta, tl)
  certificate(meta, tl)
  raw(tl)

  -- the body's page number: a single line, centered
  write_file("FORMBOOK_FOOTERS", "rIdFtrIlnd\t" .. p('<w:r><w:fldChar w:fldCharType="begin"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>', { jc = "center" }) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdFtrIlnd", "decimal"))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
