-- Bankr. E.D. Okla. brief in support of a motion, docx engine (docs/DOCX.md): the same markdown contract as
-- typst/okeb-motion-brief.typ, and every block written as it sets it: the court lines, the caption (the debtor column
-- closed by a rule at its right, the case number and chapter beside it; LBR 9004-2), the title, the optional counsel
-- block, the headings, the paragraphs numbered consecutively over the whole brief (the typed numbers are ignored),
-- the unnumbered paragraphs with their native footnotes (pandoc writes them, styles of reference.xml), the
-- quotations, the bulleted lists, the signature block (LBR 9004-1(C), 9011-3(A)) and the optional certificate.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file. The caption is an
-- OOXML table. The caption, counsel and signature strings are text, not markdown, as typst sets them; the title and
-- the certificate's text are markdown: all are read from $FORMBOOK_META as written. The LBR 7007-1(B) page limit is
-- asserted by the typst template, which the docx follows page for page.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276                          -- typst pitch-double, pitch-single
local INDENT = 720                                     -- typst para-indent, 0.5 in
local LABEL = 360                                      -- typst bullet-label, 0.25 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT = 5040                                  -- typst caption-left, 3.5 in
local CAP_PAD, CAP_GAP = 288, 432                      -- typst caption-pad (0.2 in), caption-gap (0.3 in)
local NAME, ROLE = 720, 3168                           -- typst name-indent (0.5 in), role-indent (2.2 in)
local SIG = 4680                                       -- typst signature-indent, 3.25 in
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt

-- A paragraph: o = { before, after, line, left, right, hanging, tab, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and 0 or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- The frontmatter as written (fb render: $FORMBOOK_META).
local function raw_meta()
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  if not f then error("okeb-motion-brief.lua: no $FORMBOOK_META (render with fb render)", 0) end
  local m = pandoc.json.decode(f:read("a"), false)
  f:close()
  return m
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("okeb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function strs(v)
  if type(v) == "table" then return v end
  return { v }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function brk(t)
  return (t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1"))
end

local function breaks(x) return pandoc.Str(brk(x.text)) end

-- A frontmatter string as text (a whole number as typst prints it).
local function s(v)
  if math.type(v) == "float" and v == math.floor(v) then v = string.format("%d", v) end
  return brk(tostring(v))
end

-- A doubled section sign stays with its number, as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- typst's break rules on pandoc blocks (the body, and markdown from the frontmatter); xe.inl applies the rest to
-- what the filter writes, `written` to what pandoc writes.
local function prepare(blocks)
  return blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
end

-- A frontmatter string read as markdown, as typst's cmarker reads it: its first paragraph's inlines.
local function md(v)
  local b = prepare(pandoc.read(tostring(v), "markdown", PANDOC_READER_OPTIONS).blocks)
  if #b ~= 1 or (b[1].t ~= "Para" and b[1].t ~= "Plain") then
    error("okeb-motion-brief.lua: a frontmatter value holds one paragraph: " .. tostring(v))
  end
  return b[1].content
end

-- A paragraph pandoc writes (with its footnotes): the break rules of xe.inlines on its runs, notes included.
local function written(inlines, style)
  return pandoc.Div({ pandoc.Para(inlines):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = style })
end

local function upper(inlines)
  return inlines:walk({ Str = function(x) return pandoc.Str(pandoc.text.upper(x.text)) end })
end

local function no_notes(inlines, what)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then error("okeb-motion-brief.lua: no footnote in " .. what) end
  end
  return inlines
end

-- ---------------------------------------------------------------------------
-- Caption: the court in two bold lines; a double line below, the debtor column (closed by a rule at its right) and
-- the number column; the title a double line below; the counsel block (if any) a single line below. One single line
-- each, never split.
-- ---------------------------------------------------------------------------

local function caption(meta)
  local out = {
    p(xe.runs("IN THE UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center", keep = true }),
    p(xe.runs("FOR THE EASTERN DISTRICT OF OKLAHOMA", { b = true }), { jc = "center", keep = true, after = BODY }),
  }
  local left = { p(xe.runs("In re:")), p("") }
  for _, d in ipairs(strs(need(meta, "debtor"))) do left[#left + 1] = p(xe.runs(s(d)), { left = NAME }) end
  left[#left + 1] = p(xe.runs(s(need(meta, "debtor_role"))), { left = ROLE })
  local judge = meta.judge and s(meta.judge) or ""
  local right = {
    p(xe.runs("Case No. " .. s(need(meta, "case_number")) .. (judge ~= "" and ("-" .. judge) or ""))),
    p(xe.runs("Chapter " .. s(need(meta, "chapter"))), { before = SINGLE }),
  }
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:right ' .. RULE ..
    '/></w:tcBorders><w:tcMar><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar></w:tcPr>' ..
    table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_GAP ..
    '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  out[#out + 1] = p(xe.inl(upper(md(need(meta, "title"))), { b = true }),
    { before = BODY, after = SINGLE, jc = "center", keep = true })
  if meta.counsel then
    local lines = strs(meta.counsel)
    for i, l in ipairs(lines) do
      out[#out + 1] = p(xe.runs(s(l)), { left = SIG, before = i == 1 and SINGLE or 0,
        after = i == #lines and SINGLE or 0, keep = i < #lines })
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature (LBR 9004-1(C), 9011-3(A)), a double line below the body: the dated line at the margin (if any),
-- "Respectfully submitted," 3.25 in from the margin, a single line below it the electronic signature and the block;
-- kept whole.
-- ---------------------------------------------------------------------------

-- A block never split across pages: one table row that cannot split (typst: an unbreakable block; a paragraph kept
-- with it moves to the next page with it only when both fit there, as typst's sticky block does, where a chain of
-- kept paragraphs longer than the room left would be split).
local function whole(paras)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. TEXTW .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. TEXTW .. '" w:type="dxa"/></w:tcPr>' .. table.concat(paras) .. '</w:tc></w:tr></w:tbl>'
end

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  if meta.date then out[#out + 1] = p(xe.runs("Dated: " .. s(meta.date))) end
  out[#out + 1] = p(xe.runs("Respectfully submitted,"), { left = SIG, before = meta.date and SINGLE or 0 })
  out[#out + 1] = p(xe.runs("/s/ " .. s(sig.electronic)), { left = SIG, before = SINGLE })
  for _, l in ipairs(strs(sig.lines)) do out[#out + 1] = p(xe.runs(s(l)), { left = SIG }) end
  -- the double line above it an empty line of its own, kept with it (a cell keeps its first paragraph's space
  -- above at the top of a page, where typst drops the space above a block)
  return { p("", { line = BODY, keep = true }), whole(out) }
end

-- ---------------------------------------------------------------------------
-- Certificate of service or of mailing (optional), kept whole: its title a double line below the signature, a single
-- line above the text; its paragraphs indented and double spaced, a paragraph of lines (markdown line breaks: an
-- address) single spaced at the margin, a single line above and below; a single line below, the electronic
-- signature and its block 3.25 in from the margin.
-- ---------------------------------------------------------------------------

local function certificate(meta)
  local c = meta.certificate
  if not c then return {} end
  local out = { xe.raw(p(xe.runs(pandoc.text.upper(s(c.title)), { b = true }), { before = BODY, after = SINGLE,
    jc = "center", keep = true })) }
  local body = tostring(c.body):gsub("\r", "")
  for chunk in (body .. "\n\n"):gmatch("(.-)\n[ \t]*\n") do
    chunk = chunk:gsub("^%s+", ""):gsub("%s+$", "")
    if chunk ~= "" then
      local lines = {}
      for l in (chunk .. "\\\n"):gmatch("(.-)\\\n") do lines[#lines + 1] = l end
      if #lines > 1 then
        for i, l in ipairs(lines) do
          out[#out + 1] = xe.raw(p(xe.inl(no_notes(md(l), "a certificate")), { before = i == 1 and SINGLE or 0,
            after = i == #lines and SINGLE or 0, keep = true }))
        end
      else
        out[#out + 1] = written(no_notes(md(chunk), "a certificate"), "Body Text Keep")
      end
    end
  end
  local sig = { p(xe.runs("/s/ " .. s(c.electronic)), { left = SIG, before = SINGLE, keep = true }) }
  for _, l in ipairs(strs(c.lines or {})) do sig[#sig + 1] = p(xe.runs(s(l)), { left = SIG, keep = true }) end
  sig[#sig] = sig[#sig]:gsub("<w:keepNext/>", "", 1)
  for _, x in ipairs(sig) do out[#out + 1] = xe.raw(x) end
  return out
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings single-spaced, a single line above and below, kept with the text: level 1 centered bold capitals, level 2
-- bold at the margin, level 3 bold half an inch in.
local function heading(el)
  local content = no_notes(el.content, "a heading")
  if el.level == 1 then content = upper(content) end
  return xe.raw(p(xe.inl(content, { b = true }), { before = SINGLE, after = SINGLE, keep = true,
    jc = el.level == 1 and "center" or "left", left = el.level > 2 and INDENT or 0 }))
end

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A body paragraph (pandoc writes it, with its footnotes): the last one kept whole with the signature block.
local function para(inlines, last)
  local style = last and "Body Text Keep" or has_note(inlines) and "Body Text Note" or "Body Text"
  return written(inlines, style)
end

local function one_para(item, what)
  if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
    error("okeb-motion-brief.lua: " .. what .. " holds one paragraph")
  end
  return item[1].content
end

local function body(blocks)
  local out = {}
  local n = 0
  for k, b in ipairs(blocks) do
    local last = k == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        n = n + 1
        local inlines = pandoc.Inlines({ pandoc.Str(n .. "."), pandoc.Space() })
        inlines:extend(one_para(item, "a numbered paragraph"))
        out[#out + 1] = para(inlines, last and j == #b.content)
      end
    elseif b.t == "BlockQuote" then
      -- single-spaced, half an inch in on both sides, a single line above and below
      for j, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("okeb-motion-brief.lua: a quotation holds paragraphs") end
        out[#out + 1] = xe.raw(p(xe.inl(no_notes(q.content, "a quotation")), { left = INDENT, right = INDENT,
          before = SINGLE, after = SINGLE, keep = last and j == #b.content }))
      end
    elseif b.t == "BulletList" then
      -- the bullet half an inch in, the text hanging after it; single-spaced, a single line above and below
      for j, item in ipairs(b.content) do
        out[#out + 1] = xe.raw(p(xe.runs("\u{2022}\t") .. xe.inl(no_notes(one_para(item, "a bullet"), "a bullet")),
          { left = INDENT + LABEL, hanging = LABEL, tab = INDENT + LABEL, before = SINGLE, after = SINGLE,
            keep = last and j == #b.content }))
      end
    elseif b.t == "HorizontalRule" then
      -- a marked gap in the text ("* * *"), centered at the body pitch
      out[#out + 1] = xe.raw(p(xe.runs("* * *"), { line = BODY, jc = "center", keep = last }))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = para(b.content, last)
    else
      error("okeb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  return out
end

function Pandoc(doc)
  local meta = raw_meta()
  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = xe.raw(x) end
  for _, x in ipairs(body(prepare(doc.blocks))) do out[#out + 1] = x end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = xe.raw(x) end
  for _, x in ipairs(certificate(meta)) do out[#out + 1] = x end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
