-- Bankr. E.D. Okla. adversary complaint, docx engine (docs/DOCX.md): the same markdown contract as
-- typst/okeb-adversary-complaint.typ, and every block written as it sets it: the court lines, the caption (the party
-- column closed by a rule at its right, the number column beside it; Official Form 416D, LBR 9004-2), the title, the
-- headings, the allegations numbered consecutively over the whole complaint (FRCP 10(b) via FRBP 7010; the typed
-- numbers are ignored), the property lists ("- "), the unnumbered paragraphs with their native footnotes (pandoc
-- writes them, styles of reference.xml) and the signature block (LBR 9004-1(C)). Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file. The caption is an OOXML table. The caption and
-- signature strings are text, not markdown, as typst sets them: they are read from $FORMBOOK_META as written.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276                          -- typst pitch-double, pitch-single
local LIST = 1440                                      -- typst list-indent, 1 in
local TEXTW = 9360                                     -- 6.5 in
local CAP_LEFT = 5040                                  -- typst caption-left, 3.5 in
local CAP_PAD, CAP_GAP = 288, 432                      -- typst caption-pad (0.2 in), caption-gap (0.3 in)
local NAME, ROLE, VERSUS = 720, 3168, 1728             -- typst name-indent (0.5 in), role-indent (2.2 in),
                                                       -- versus-indent (1.2 in)
local SIG = 4680                                       -- typst signature-indent, 3.25 in
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'   -- 0.75 pt

-- A paragraph: o = { before, after, line, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- The frontmatter as written (fb render: $FORMBOOK_META), for the strings typst sets as text.
local function raw_meta()
  local f = io.open(os.getenv("FORMBOOK_META") or "", "r")
  if not f then error("okeb-adversary-complaint.lua: no $FORMBOOK_META (render with fb render)", 0) end
  local m = pandoc.json.decode(f:read("a"), false)
  f:close()
  return m
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("okeb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function strs(v)
  if type(v) == "table" then return v end
  return { v }
end

-- A frontmatter string as text, with typst's break opportunities (see `breaks` below).
local function s(v) return (tostring(v):gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")) end

-- ---------------------------------------------------------------------------
-- Caption: the court in two bold lines; a double line below, the party column (closed by a rule at its right) and
-- the number column; one single line each, never split.
-- ---------------------------------------------------------------------------

local function caption(meta)
  local out = {
    p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center", keep = true }),
    p(xe.runs("EASTERN DISTRICT OF OKLAHOMA", { b = true }), { jc = "center", keep = true, after = BODY }),
  }
  local left = { p(xe.runs("In re:")), p("") }
  for _, d in ipairs(strs(need(meta, "debtor"))) do left[#left + 1] = p(xe.runs(s(d)), { left = NAME }) end
  left[#left + 1] = p(xe.runs(s(meta.debtor_role or "Debtor.")), { left = ROLE })
  for i, party in ipairs(need(meta, "parties")) do
    left[#left + 1] = p("")
    if i > 1 then
      left[#left + 1] = p(xe.runs("v."), { left = VERSUS })
      left[#left + 1] = p("")
    end
    left[#left + 1] = p(xe.runs(s(party.names)), { left = NAME })
    left[#left + 1] = p(xe.runs(s(party.role)), { left = ROLE })
  end
  local judge = meta.judge and s(meta.judge) or ""
  local right = {
    p(xe.runs("Case No. " .. s(need(meta, "case_number")) .. (judge ~= "" and ("-" .. judge) or ""))),
    p(xe.runs("Chapter " .. s(need(meta, "chapter")))),
    p(xe.runs("Adv. Proc. No. " .. s(need(meta, "adversary_number"))), { before = SINGLE }),
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
  -- the title a double line below the caption, at the body pitch
  out[#out + 1] = p(xe.runs(pandoc.text.upper(s(need(meta, "title"))), { b = true }),
    { line = BODY, before = BODY, jc = "center", keep = true })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature (LBR 9004-1(C)), a double line below the body: the dated line at the margin (if any), "Respectfully
-- submitted:" 3.25 in from the margin, a single line below it the electronic signature and the block; kept whole.
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
  out[#out + 1] = p(xe.runs("Respectfully submitted:"), { left = SIG, before = meta.date and SINGLE or 0 })
  out[#out + 1] = p(xe.runs("s/ " .. s(sig.electronic)), { left = SIG, before = SINGLE })
  for _, l in ipairs(strs(sig.lines)) do out[#out + 1] = p(xe.runs(s(l)), { left = SIG }) end
  -- the double line above it an empty line of its own, kept with it (a cell keeps its first paragraph's space
  -- above at the top of a page, where typst drops the space above a block)
  return { p("", { line = BODY, keep = true }), whole(out) }
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, centered bold capitals, kept with the text.
local function heading(el)
  local content = el.content:walk({ Str = function(x) return pandoc.Str(pandoc.text.upper(x.text)) end })
  return xe.raw(p(xe.inl(content, { b = true }), { line = BODY, jc = "center", keep = true }))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(x)
  return pandoc.Str((x.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
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

local function has_note(inlines)
  for _, el in ipairs(inlines) do
    if el.t == "Note" then return true end
  end
  return false
end

-- A body paragraph (pandoc writes it, with its footnotes): the last one kept whole with the signature block.
local function para(inlines, last)
  local style = last and "Body Text Keep" or has_note(inlines) and "Body Text Note" or "Body Text"
  -- the break rules of xe.inlines on the runs pandoc writes, notes included (xe.inl applies them to the rest)
  return pandoc.Div({ pandoc.Para(inlines):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = style })
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
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("okeb-adversary-complaint.lua: an allegation holds one paragraph")
        end
        n = n + 1
        local inlines = pandoc.Inlines({ pandoc.Str(n .. "."), pandoc.Space() })
        inlines:extend(item[1].content)
        out[#out + 1] = para(inlines, last and j == #b.content)
      end
    elseif b.t == "BulletList" then
      -- a property list: one single line each, an inch in, a single line above and below
      for j, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("okeb-adversary-complaint.lua: a property list item holds one line")
        end
        out[#out + 1] = xe.raw(p(xe.inl(item[1].content), { left = LIST, before = j == 1 and SINGLE or 0,
          after = j == #b.content and SINGLE or 0, keep = last }))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = para(b.content, last)
    else
      error("okeb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  return out
end

function Pandoc(doc)
  local meta = raw_meta()
  local blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = xe.raw(x) end
  for _, x in ipairs(body(blocks)) do out[#out + 1] = x end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = xe.raw(x) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
