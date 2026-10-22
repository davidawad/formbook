-- moeb-adversary-complaint.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads and
-- breaks as typst/moeb-adversary-complaint.typ does: the court title, the caption (a table: debtor and parties left,
-- with a rule on the right and the bottom; case block right; L.R. 9004(A)), the title, the lead-in, the numbered
-- paragraphs (Fed. R. Civ. P. 10(b); L.R. 9004(C)), `%` and `%%` paragraphs, the FRBP 7008(a) consent sentence, the
-- headings, the signature block and the optional certificate of service (L.R. 9004(D)). Everything printed comes
-- from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 5184, 360   -- typst caption-left 3.6 in, caption-gutter 0.25 in
local CAP_INSET, CAP_PAD = 200, 160      -- typst caption-inset 10 pt, caption-pad 8 pt
local RIGHT_INSET = 216                  -- typst right-inset 0.15 in
local SIG_LEFT, SIG_GUTTER = 4320, 288   -- typst sig-left 3 in, sig-gutter 0.2 in
local COURT = { "UNITED STATES BANKRUPTCY COURT", "FOR THE EASTERN DISTRICT OF MISSOURI", "EASTERN DIVISION" }
local CONSENT = "{{consent}}"
local NBSP = "\u{00A0}"

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then return v end
  return { v }
end

-- Non-breaking spaces keep "11 U.S.C. § 548" together and "§ 548" on one line (typst joins): the space before a
-- word that starts "U.S.C.", the one between "U.S.C." and a section sign, and the one after a section sign.
local function joins(ils)
  ils = xe.unabbrev(ils)
  local out = pandoc.Inlines({})
  for i, el in ipairs(ils) do
    local prev, nxt = ils[i - 1], ils[i + 1]
    if el.t == "Space" and ((nxt and nxt.t == "Str" and nxt.text:sub(1, 6) == "U.S.C.")
        or (prev and prev.t == "Str" and prev.text == "U.S.C." and nxt and nxt.t == "Str" and nxt.text:sub(1, 2) == "§")
        or (prev and prev.t == "Str" and prev.text:sub(-2) == "§")) then
      out:insert(pandoc.Str(NBSP))
    else
      out:insert(el)
    end
  end
  return out
end

-- Inline markdown in a frontmatter string (fancy_lists off: "(314) 991-4999" is an address, not a list).
local function md(s)
  local out = pandoc.Inlines({})
  for _, b in ipairs(pandoc.read(plain(s), "markdown-fancy_lists").blocks) do out:extend(b.content or {}) end
  return joins(out)
end

-- A paragraph: o = { before, after, line, left, hanging, first, tab, jc, keep } (a hanging indent writes no
-- firstLine: Word takes firstLine over hanging).
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells, trpr)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Court title and caption (L.R. 9004(A); Fed. R. Bankr. P. 7010)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  for i, l in ipairs(COURT) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = i == #COURT and BODY or 0 })
  end
  -- Left cell: the debtor, a single line, then each party's names and designation, "v." between the parties; the
  -- bottom rule stands the pad off the last line (space after it).
  local left = {}
  for _, l in ipairs(list(meta.caption.debtor)) do left[#left + 1] = p(xe.inl(md(l))) end
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for j, n in ipairs(list(party.names)) do
      left[#left + 1] = p(xe.inl(md(n)), { before = (k == 1 and j == 1) and SINGLE or 0 })
    end
    left[#left + 1] = p(xe.inl(md(party.designation)), { after = k == #parties and CAP_PAD or 0 })
  end
  -- Right cell: case number, judge, chapter, adversary number and hearing lines when the sample has them.
  local right = { p(xe.inl(md("Case No. " .. plain(meta.case_number)))) }
  if meta.judge then right[#right + 1] = p(xe.inl(md(meta.judge))) end
  if meta.chapter then right[#right + 1] = p(xe.inl(md(meta.chapter))) end
  if plain(meta.adversary_number) ~= "" then
    right[#right + 1] = p(xe.inl(md("Adv. Proc. No. " .. plain(meta.adversary_number))))
  end
  for _, h in ipairs(list(meta.hearing)) do right[#right + 1] = p(xe.inl(md(h))) end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  return out
end

-- ---------------------------------------------------------------------------
-- Consent (Fed. R. Bankr. P. 7008(a)). A sample without a `consent` value gets a bold placeholder, so an
-- unfinished statement shows.
-- ---------------------------------------------------------------------------

local function consent_text(meta)
  local c = meta.consent and plain(meta.consent) or nil
  if c == nil then
    return "**[COUNSEL TO STATE WHETHER PLAINTIFF CONSENTS OR DOES NOT CONSENT TO THE ENTRY OF FINAL ORDERS OR JUDGMENT BY THE BANKRUPTCY JUDGE, FED. R. BANKR. P. 7008(a)]**"
  end
  assert(c == "consents" or c == "does not consent", 'moeb-adversary-complaint: consent must be "consents" or "does not consent"')
  return "Pursuant to Fed. R. Bankr. P. 7008(a), Plaintiff " .. c .. " to the entry of final orders or judgment by the bankruptcy judge."
end

local function put_consent(ils, consent)
  local out = pandoc.Inlines({})
  for _, el in ipairs(ils) do
    local at = el.t == "Str" and el.text:find(CONSENT, 1, true)
    if at then
      if at > 1 then out:insert(pandoc.Str(el.text:sub(1, at - 1))) end
      out:extend(consent)
      if at + #CONSENT <= #el.text then out:insert(pandoc.Str(el.text:sub(at + #CONSENT))) end
    else
      out:insert(el)
    end
  end
  return out
end

-- A `%%` (centered) or `%` (unnumbered) marker at the start of a paragraph: the inlines after it, or nil.
local function strip(ils, marker)
  local first = ils[1]
  if not first or first.t ~= "Str" or first.text:sub(1, #marker) ~= marker then return nil end
  local out = pandoc.Inlines({})
  local rest = first.text:sub(#marker + 1)
  if rest ~= "" then out:insert(pandoc.Str(rest)) end
  for i = 2, #ils do out:insert(ils[i]) end
  while out[1] and out[1].t == "Space" do out:remove(1) end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch: unnumbered (first-line indent), centered, or numbered: the number after the
-- first-line indent, a tab to the next half inch (typst: the number in a box of para-indent), the text.
local function body_par(label, inlines, o)
  o = o or {}
  if o.center then return p(xe.inl(inlines, o.r), { line = BODY, jc = "center", keep = o.keep, before = o.before }) end
  if label == nil then return p(xe.inl(inlines, o.r), { line = BODY, first = INDENT, keep = o.keep }) end
  return p(xe.runs(label .. "\t") .. xe.inl(inlines), { line = BODY, first = INDENT, tab = 2 * INDENT, keep = o.keep })
end

-- Headings at the body pitch: level 1 centered bold capitals, level 2 centered bold, level 3 bold italic; kept
-- with the text.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(el.level <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = el.level >= 3 }))
end

-- A list as typst's xengine sets it: the label in a box of the indent at the margin, the text hanging after it.
local function list_items(b, out)
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  for _, item in ipairs(b.content) do
    local lab = b.t == "OrderedList" and (n .. ".") or "\u{2022}"
    for k, blk in ipairs(item) do
      out[#out + 1] = p(xe.runs(k == 1 and (lab .. "\t") or "") .. xe.inl(blk.content),
        { line = BODY, left = INDENT, hanging = INDENT })
    end
    n = n + 1
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- ---------------------------------------------------------------------------
-- Signature block ("Date" in the left 3 in, level with "Respectfully submitted,") and certificate of service.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local s = meta.signature
  local right = {
    p(xe.runs("Respectfully submitted,"), { before = BODY }),
    p(xe.inl(md(s.firm)), { before = SINGLE }),
    p(xe.inl(md("By: " .. plain(s.by))), { before = SINGLE }),
  }
  for _, l in ipairs(list(s.attorneys)) do right[#right + 1] = p(xe.inl(md(l))) end
  for _, l in ipairs(list(s.lines)) do right[#right + 1] = p(xe.inl(md(l))) end
  local left = { p(xe.inl(md("Date: " .. plain(s.date))), { before = BODY }) }
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = left },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

local function certificate(meta, out)
  if meta.certificate == nil then return end
  out[#out + 1] = p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { line = BODY, before = BODY, jc = "center", keep = true })
  local ps = list(meta.certificate)
  for i, c in ipairs(ps) do
    out[#out + 1] = p(xe.inl(md(c)), { line = BODY, first = INDENT, keep = i < #ps })
  end
end

function Pandoc(doc)
  local meta = doc.meta
  local consent = md(consent_text(meta))
  doc = doc:walk({ Inlines = function(ils) return joins(put_consent(ils, consent)) end })
  doc = doc:walk({ Str = breaks })
  local out = cover(meta)
  -- the caption stands a double line above the title (typst: the caption block's below); Word has no space after a
  -- table, so the title takes the space before it
  out[#out + 1] = body_par(nil, pandoc.Inlines({ pandoc.Str(pandoc.text.upper(plain(meta.title))) }),
    { center = true, r = { b = true }, before = BODY })
  if meta.lead_in then out[#out + 1] = body_par(nil, md(meta.lead_in)) end
  local n = 0
  local blocks = doc.blocks
  for i, b in ipairs(blocks) do
    -- the last chunk stays with the signature block (typst: one unbreakable block)
    local keep = i == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      list_items(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      local centered = strip(b.content, "%%")
      local unnumbered = centered == nil and strip(b.content, "%") or nil
      if centered then
        out[#out + 1] = body_par(nil, centered, { center = true, keep = keep })
      elseif unnumbered then
        out[#out + 1] = body_par(nil, unnumbered, { keep = keep })
      else
        n = n + 1
        out[#out + 1] = body_par(n .. ".", b.content, { keep = keep })
      end
    else
      error("moeb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  certificate(meta, out)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
