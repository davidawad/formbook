-- txnb (N.D. Tex. bankruptcy) DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- docx/reference.xml. Mirrors typst/txnb-<doc>.typ: the cover (counsel, court title, Form 416 caption as a table with
-- the party column ruled on the right and bottom, title), the table of contents when asked for, the body, the
-- signature block and (motion) the certificates. Page numbers come from the reference's footer. Paragraph and list
-- numbers are typed text (a label, a tab), as the typst template sets them. Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template (the larger of the one's below and the next one's above, written as
-- the next paragraph's space before), and the break rules of typst on every run.
--
-- Table of contents (toc: true): fb render (tools/fb/src/docxpass.rs) finds the needles this filter writes
-- (FORMBOOK_NEEDLES: the first counsel line and every heading, with the words after it) in the LibreOffice PDF and
-- renders again with their pages (FORMBOOK_PAGES) until they settle; the pages are numbered from the cover on.

local xe = require("docx.xengine")

-- The only part that differs between the two doc types (the typst templates have the same switches).
local CFG = {
  numbered = true,            -- complaint: body paragraphs are numbered (Fed. R. Civ. P. 10(b)); motion: not
  enum = "letter",            -- complaint lists are (a), (b), ...; motion lists are 1., 2., ... as written
  certificates = false,       -- motion: certificate_conference / certificate_service
  toc = false,                -- motion: table of contents when the frontmatter says toc: true (L.B.R. 7007-2(d))
}

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, label-box: 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360   -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET, CAP_PAD = 200, 138      -- typst caption-inset 10 pt, caption-pad (half a single line)
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local DESIGNATION = 2160                 -- typst designation-indent 1.5 in
local SIG_INDENT = 4320                  -- typst sig-indent 3 in
local TOC_COL = 720                      -- typst toc-page-col 36 pt
local NEEDLE_MAX = 60

local stringify = pandoc.utils.stringify

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, line, left, right, hanging, first, jc, keep, lines, brk, tabs } (a hanging indent writes
-- no firstLine: Word takes firstLine over hanging). No space after: the next paragraph's space before carries it.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tab_at(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter ("CM/ECF": a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign or pilcrow stays with its number ("§§ 157"; xe binds a single sign), as typst binds it.
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A metadata value (markdown) as its paragraphs, each a list of inlines.
local function paras_of(v)
  if v == nil then return {} end
  if type(v) == "string" or v.t == "MetaString" then return { pandoc.Inlines({ pandoc.Str(plain(v)) }) } end
  if v[1] and (v[1].t == "Para" or v[1].t == "Plain") then
    local out = {}
    for _, b in ipairs(v) do out[#out + 1] = b.content end
    return out
  end
  -- a one-line YAML string with blank lines in it comes as inlines with a LineBreak per blank line
  local out, cur = {}, pandoc.Inlines({})
  for _, el in ipairs(v) do
    if el.t == "LineBreak" then out[#out + 1] = cur; cur = pandoc.Inlines({}) else cur:insert(el) end
  end
  out[#out + 1] = cur
  return out
end

-- a tag such as "[noindent]" at the start of a paragraph: removed, and reported
local function strip_tag(inls, tag)
  if inls[1] and inls[1].t == "Str" and inls[1].text == tag then
    inls:remove(1)
    if inls[1] and (inls[1].t == "Space" or inls[1].t == "SoftBreak") then inls:remove(1) end
    return true
  end
  return false
end

-- ---------------------------------------------------------------------------
-- Needles and pages (tools/fb/src/docxpages.rs), for the table of contents
-- ---------------------------------------------------------------------------

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local needles = {}
local function need(id, text, context)
  local long = norm(text .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  local short = ""
  for w in text:gmatch("%S+") do
    short = short .. norm(w)
    if #short >= 8 then break end
  end
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, needle = long, fallback = short:sub(1, NEEDLE_MAX) }
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, _, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = label end
  end
  f:close()
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, Form 416 caption, title of the paper
-- ---------------------------------------------------------------------------

local function blank(o)
  o = o or {}
  return p("", o)
end

local function caption_table(meta)
  local cap = meta.caption
  local left = {}
  local function desig(text, after)
    return p(xe.inl(text) .. xe.runs("."), { left = DESIGNATION, after = after or 0 })
  end
  if cap.debtor then
    left[#left + 1] = p(xe.runs("In re:"))
    left[#left + 1] = p(xe.inl(cap.debtor))
    left[#left + 1] = desig(cap.debtor_designation or "Debtor")
    left[#left + 1] = blank()
  end
  for k, party in ipairs(cap.parties) do
    if k > 1 then
      left[#left + 1] = blank()
      left[#left + 1] = p(xe.runs("v."))
      left[#left + 1] = blank()
    end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = desig(party.designation, k == #cap.parties and CAP_PAD or 0)
  end
  local right = {
    p(xe.runs("Chapter " .. plain(meta.chapter))), blank(),
    p(xe.runs("Case No. ") .. xe.inl(meta.case_number)), blank(),
    p(xe.runs("Adversary Proceeding No. ") .. xe.inl(meta.adversary_number)),
  }
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  local function tc(w, pr, body)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    tc(CAP_LEFT, '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', left) ..
    tc(TEXTW - CAP_LEFT, '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', right) ..
    '</w:tr></w:tbl>'
end

local function cover(meta)
  local out = {}
  for _, l in ipairs(meta.counsel) do out[#out + 1] = p(xe.inl(l)) end
  local title = { "UNITED STATES BANKRUPTCY COURT", "NORTHERN DISTRICT OF TEXAS" }
  if meta.division then title[#title + 1] = pandoc.text.upper(plain(meta.division)) end
  -- the court title stands a double line below the counsel; the caption a double line below the court title (Word
  -- has no space before a table: the last title line takes it as space after)
  for i, l in ipairs(title) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", before = i == 1 and BODY or 0,
      after = i == #title and BODY or 0 })
  end
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { jc = "center", before = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- The document: blocks with the space above and below them (typst block above/below)
-- ---------------------------------------------------------------------------

local LETTERS = "abcdefghijklmnopqrstuvwxyz"

function Pandoc(doc)
  load_pages()
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local blocks = doc.blocks
  local want_toc = CFG.toc and meta.toc == true

  local body = {}
  -- the title stands a double line above the text (typst: the title block's below)
  local pend, brk = BODY, false
  local function add(xml, o, above, below)
    o.before = math.max(pend, above or 0)
    if brk then o.brk, o.before, brk = true, 0, false end
    body[#body + 1] = p(xml, o)
    pend = below or 0
  end

  local entries = {}
  local n, h_n = 0, 0
  local unnumbered = false
  -- the index of the last block that prints (the one kept with the signature)
  local last_i = #blocks
  while last_i > 0 and blocks[last_i].t == "RawBlock" do last_i = last_i - 1 end
  if want_toc then brk = true end
  for i, b in ipairs(blocks) do
    local last = i == last_i
    local next_text = blocks[i + 1] and stringify(blocks[i + 1]):sub(1, 40) or ""
    if b.t == "RawBlock" then
      if b.text:match("^<!%-%-%s*unnumbered%s*%-%->$") then unnumbered = true
      elseif not b.text:match("^<!%-%-.*%-%->$") then error("txnb: unsupported raw block " .. b.text) end
    elseif b.t == "Header" then
      h_n = h_n + 1
      local id = "H:" .. h_n
      need(id, stringify(b.content), next_text)
      if b.level <= 2 then entries[#entries + 1] = { id = id, level = b.level, title = b.content } end
      add(xe.inl(b.content, { b = true, i = b.level > 2 }), { line = BODY, jc = b.level == 1 and "center" or "left",
        keep = true })
    elseif b.t == "Para" or b.t == "Plain" then
      local inls = b.content
      if unnumbered then
        unnumbered = false
        add(xe.inl(inls), { line = BODY, first = INDENT, keep = last })
      elseif strip_tag(inls, "[noindent]") then
        add(xe.inl(inls), { line = BODY, keep = last })
      elseif CFG.numbered then
        n = n + 1
        add(xe.runs(n .. ".\t") .. xe.inl(inls), { line = BODY, first = INDENT, keep = last,
          tabs = tab_at(2 * INDENT) })
      else
        add(xe.inl(inls), { line = BODY, first = INDENT, keep = last })
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("txnb: a list item holds one paragraph")
        end
        local lab = "\u{2022}"
        if b.t == "OrderedList" then
          lab = CFG.enum == "letter" and ("(" .. LETTERS:sub(j, j) .. ")") or ((start + j - 1) .. ".")
        end
        add(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
          { line = BODY, left = 2 * INDENT, hanging = INDENT, keep = last and j == #b.content })
      end
    else
      error("txnb: unsupported block " .. b.t)
    end
  end

  -- Signature block: the date, then at the right the closing, the firm and the signer's lines; never split.
  local sig = meta.signature
  add(xe.runs("Dated: ") .. xe.inl(meta.date), { line = BODY, keep = true })
  local lines = { "", xe.runs("Respectfully submitted,"), "" }
  for _, l in ipairs(sig.firm) do lines[#lines + 1] = xe.inl(l) end
  lines[#lines + 1] = ""
  lines[#lines + 1] = xe.runs("By: /s/ ") .. xe.inl(sig.signer)
  for _, l in ipairs(sig.lines) do lines[#lines + 1] = xe.inl(l) end
  for k, l in ipairs(lines) do add(l, { left = SIG_INDENT, keep = k < #lines }) end

  -- Certificates: a centered bold heading a double line below, the paragraphs at the double pitch (not indented),
  -- "/s/" and the signer at the right a single line below; never split.
  local function certificate(title, value)
    add(xe.runs(pandoc.text.upper(title), { b = true }), { line = BODY, jc = "center", keep = true }, BODY)
    for _, inls in ipairs(paras_of(value)) do
      inls = pandoc.Inlines(inls)
      strip_tag(inls, "[noindent]")
      add(xe.inl(inls), { line = BODY, keep = true })
    end
    add(xe.runs("/s/ ") .. xe.inl(sig.signer), { jc = "right" }, SINGLE)
  end
  if CFG.certificates then
    if meta.certificate_conference then certificate("Certificate of Conference", meta.certificate_conference) end
    if meta.certificate_service then certificate("Certificate of Service", meta.certificate_service) end
  end

  local out = cover(meta)
  if want_toc then
    -- the contents on a page of their own (typst: pagebreak before and after); page numbers count from the cover
    local nl = { table.concat({ "C:1", "B", norm(plain(meta.counsel[1]) .. " " .. plain(meta.counsel[2] or "")):sub(1, NEEDLE_MAX),
      norm(plain(meta.counsel[1])):sub(1, NEEDLE_MAX) }, "\t") }
    for _, x in ipairs(needles) do nl[#nl + 1] = table.concat({ x.id, "B", x.needle, x.fallback }, "\t") end
    nl[#nl + 1] = "#section\tC:1\tdecimal\t"
    write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
    -- the last section: the reference's (the recipe's page-number footer, the page, the footer distance)
    write_file("FORMBOOK_FINAL", '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/>'
      .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
      .. 'w:header="720" w:footer="735" w:gutter="0"/></w:sectPr>')
    out[#out + 1] = p(xe.runs("TABLE OF CONTENTS", { b = true }), { jc = "center", brk = true })
    local tabs = '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TEXTW .. '"/></w:tabs>'
    for _, e in ipairs(entries) do
      local ind = (e.level - 1) * INDENT
      out[#out + 1] = p(xe.inl(e.title) .. xe.runs(xe.LEAD) .. xe.runs(labels[e.id] or "0"),
        { lines = true, tabs = tabs, before = SINGLE, left = ind, right = TOC_COL })
    end
  end
  for _, x in ipairs(body) do out[#out + 1] = x end

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
