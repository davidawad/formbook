-- txed-motion-brief.lua (docx engine): what the Word output adds to pandoc's conversion, so that it reads and breaks
-- as typst/txed-motion-brief.typ does (see ../README.md, "Engines"): the court lines, the caption (parties on the
-- left, the case number and the bold line under it at the foot of the right column) and the title of the paper;
-- level-1 headings labelled I., II., ... and level-2 headings A., B., ... (restarting under each level-1 heading),
-- level-3 headings bold italic; quotations; lists lettered a., b., ...; the signature block at the right half of the
-- page, then the certificate of service (CV-5(c): date and method from the frontmatter). The statement of the issues
-- (CV-7(a)(1)) is required unless the sample is an excerpt, as the typst template requires it; the 30-page check is
-- typst's. Everything printed comes from the sample's frontmatter and body: no case text lives in this file. The
-- caption is an OOXML table.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs and
-- quotations are pandoc's own (styles in docx/reference.xml), so that their footnotes are Word footnotes.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_RIGHT, CAP_GUTTER = 3744, 360  -- typst caption-right 2.6 in, caption-gutter 0.25 in
local DESIG = 2160                       -- typst designation-indent 1.5 in
local SIG = 4320                         -- typst signature-indent 3 in
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, jc, keep, lines, style }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function upper(ils)
  return ils:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A doubled section or paragraph sign stays with its number ("¶¶ 92"), as typst boxes it.
local function signs(ils)
  for i = 1, #ils - 1 do
    if ils[i].t == "Str" and ils[i].text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and ils[i + 1].t == "Space" then
      ils[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return ils
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function brk(t)
  return (t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1"))
end
local function breaks(s) return pandoc.Str(brk(s.text)) end

-- A frontmatter value as inlines, with the body's break rules (xe.inl applies the shared ones itself).
local function mi(v)
  return signs(pandoc.Inlines(v)):walk({ Str = breaks })
end

-- ---------------------------------------------------------------------------
-- Cover: court lines, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local court = meta.court or {}
  -- the caption stands a double line below the court (typst: the caption block's above); Word has no space before
  -- a table, so the last court line takes it as space after
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.inl(upper(mi(l)), { b = true }), { jc = "center", after = i == #court and BODY or 0 })
  end
  -- Left cell: each party's names, then its designation, indented; "v." between the parties.
  local left = {}
  for k, party in ipairs(meta.caption) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(mi(n))) end
    left[#left + 1] = p(xe.inl(mi(party.designation)), { left = DESIG })
  end
  -- Right cell, at the foot of the row (typst: align(bottom)): the case number, the bold line a single line below.
  local right = { p(xe.inl(mi(meta.case_number))) }
  if meta.jury_demand then right[#right + 1] = p(xe.inl(mi(meta.jury_demand), { b = true }), { before = SINGLE }) end
  local capl = TEXTW - CAP_RIGHT - CAP_GUTTER
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. capl .. '"/><w:gridCol w:w="' .. (TEXTW - capl) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. capl .. '" w:type="dxa"/></w:tcPr>' .. table.concat(left) .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - capl) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_GUTTER ..
    '" w:type="dxa"/></w:tcMar><w:vAlign w:val="bottom"/></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  -- The title (CV-10(a)(2)): bold capitals, centered, single spaced, a double line below the caption (as space
  -- before: Word has no space after a table); the text follows on its grid.
  out[#out + 1] = p(xe.inl(upper(mi(meta.brief_title)), { b = true }), { jc = "center", before = BODY, keep = true })
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (CV-10(a)(3)) at 3 in, single spaced, a double line below the text, kept on one page (each line
-- kept with the next, as the typst block is unbreakable); the certificate of service (CV-5(c)) a double line below
-- it, its heading kept with its statement.
-- ---------------------------------------------------------------------------

local function signature(sig)
  local lines = {}
  local function add(body, before) lines[#lines + 1] = { body, before or 0 } end
  add(xe.runs("Respectfully submitted,"), BODY)
  for i, l in ipairs(sig.firm or {}) do add(xe.inl(mi(l)), i == 1 and SINGLE or 0) end
  add(xe.runs("/s/ ") .. xe.inl(mi(sig.signer)), SINGLE)
  add(xe.inl(mi(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do add(xe.inl(mi(l))) end
  add(xe.inl(mi(sig.role)), SINGLE)
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { left = SIG, before = l[2], keep = i < #lines })
  end
  return table.concat(out)
end

local function certificate(service)
  local text = xe.runs("I hereby certify that on ") .. xe.inl(mi(service.date)) ..
    xe.runs(", the foregoing document was served on all counsel of record ") .. xe.inl(mi(service.method)) .. xe.runs(".")
  return p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", before = BODY, line = BODY, keep = true }) ..
    p(text, { line = BODY, lines = true })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- A paragraph in its style (pandoc writes it, footnotes included); the Noted variant (no widow control) for a
-- paragraph that holds a footnote: typst moves the line with the reference on with its note.
local function div(style, ils, noteable)
  local noted = false
  pandoc.Inlines(ils):walk({ Note = function() noted = true end })
  return pandoc.Div({ pandoc.Para(ils) }, { ["custom-style"] = style .. ((noted and noteable ~= false) and " Noted" or "") })
end

-- Headings at the body pitch, bold, kept with the text.
local function heading(el, label)
  local ils = pandoc.Inlines({})
  if label then ils:extend({ pandoc.Str(label), pandoc.Space() }) end
  ils:extend(el.level == 1 and upper(el.content) or el.content)
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 1 and "center" or "left") }, xe.inl(ils, { b = true, i = lvl == 3 }))
end

local function item_inlines(item)
  if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
    error("txed-motion-brief.lua: a list item holds one paragraph")
  end
  return item[1].content
end

function Pandoc(doc)
  local meta = doc.meta
  local excerpt = meta.excerpt == true or plain(meta.excerpt) == "true"
  if not excerpt and not plain(doc.blocks):lower():find("statement of the issue", 1, true) then
    error("txed-motion-brief.lua: CV-7(a)(1) requires a statement of the issues to be decided (a level-1 heading 'Statement of the Issue(s)')")
  end
  doc.blocks = doc.blocks:walk({ Inlines = function(ils) return signs(xe.inlines(ils)) end })
  doc.blocks = doc.blocks:walk({ Str = breaks })
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = xe.raw(x) end
  local sections, subsections = 0, 0
  -- typst indents a paragraph only after a paragraph (not after the title, a heading, a quotation or a list)
  local after_para = false
  for _, b in ipairs(doc.blocks) do
    local para = false
    if b.t == "Header" then
      local label = nil
      if b.level == 1 then
        sections, subsections = sections + 1, 0
        label = roman(sections) .. "."
      elseif b.level == 2 then
        subsections = subsections + 1
        label = string.char(64 + subsections) .. "."
      end
      out[#out + 1] = xe.raw(heading(b, label))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = div(after_para and "Body Text" or "First Paragraph", b.content)
      para = true
    elseif b.t == "BlockQuote" then
      -- single spaced, half an inch in from both margins, a single line above and below the quotation
      local n = #b.content
      for j, q in ipairs(b.content) do
        if q.t ~= "Para" and q.t ~= "Plain" then error("txed-motion-brief.lua: a quotation holds only paragraphs") end
        if n == 1 then
          -- (widow control stays on: typst keeps a short quotation whole, its footnote too)
          out[#out + 1] = div("Block Text", q.content, false)
        else
          out[#out + 1] = div(j == 1 and "Block Text First" or j == n and "Block Text Last" or "Block Text Middle",
            q.content, false)
        end
      end
    elseif b.t == "OrderedList" then
      -- typst sets a numbered list as the layout model does: the number in a half-inch box, the text hanging
      for _, x in ipairs(xe.list_items(b)) do out[#out + 1] = x end
    elseif b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local ils = pandoc.Inlines({ pandoc.Str(string.char(96 + i) .. "."), TAB })
        ils:extend(item_inlines(item))
        out[#out + 1] = div("Lettered Item", ils)
      end
    else
      error("txed-motion-brief.lua: unsupported block " .. b.t)
    end
    after_para = para
  end
  out[#out + 1] = xe.raw(signature(meta.signature))
  if meta.service then out[#out + 1] = xe.raw(certificate(meta.service)) end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
