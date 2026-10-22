-- Motion with incorporated memorandum for the United States Bankruptcy Court, Middle District of Florida (flmb),
-- docx engine: what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/flmb-motion-brief.typ does (README "Engines"): the court title and the caption (FRBP 9004(b), Local Rule
-- 9004-1(a)), the title (Local Rules 7001-1(b), 9004-1(b)-(c)), the headings, the numbered and unnumbered
-- paragraphs, the conclusion list with its last item kept with the signature block, and the signature block.
-- Everything printed comes from the sample's frontmatter and body: no case text lives in this file. Caption and
-- signature are OOXML tables; the paragraphs that may carry footnotes are pandoc's, in the styles of
-- docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4608, 288   -- typst caption-left 3.2 in, caption-gutter 0.2 in
local SLASH = 288                        -- typst slash-box 0.2 in
local SIG_COL, SIG_GUTTER = 4464, 288    -- typst sig-col 3.1 in, sig-gutter 0.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A table: widths, then rows of cells (each a list of paragraphs, or { pr = .., body = {..} }).
local function tbl(widths, rows, trpr)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(c.body or c) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title
-- ---------------------------------------------------------------------------

-- The title as printed: capitals, then the words the Local Rules require (typst full-title()).
local function full_title(meta)
  local parts = { pandoc.text.upper(plain(meta.title)) }
  if meta.injunctive_relief then parts[#parts + 1] = "INJUNCTIVE RELIEF SOUGHT" end
  if meta.jury_demand then parts[#parts + 1] = "DEMAND FOR JURY TRIAL" end
  return table.concat(parts, "; ")
end

-- The caption (typst caption()): one table row per line; the party column, the gutter and the case numbers; each
-- party block a single line below the one before; the rule closed by "/" an underlined tab and a right tab.
local function caption(meta)
  local rows = {}
  local function row(l, r, gap) -- l, r: runs; gap: the space above the row
    local o = { before = gap or 0 }
    rows[#rows + 1] = { { p(l, o) }, { p("", o) }, { p(r or "", o) } }
  end
  local function ind(runs, gap) rows[#rows + 1] = { { p(runs, { left = INDENT, before = gap or 0 }) }, { p("") }, { p("") } } end
  local function rule()
    local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (CAP_LEFT - SLASH) .. '"/><w:tab w:val="right" w:pos="' ..
      CAP_LEFT .. '"/></w:tabs>'
    rows[#rows + 1] = { { p('<w:r><w:rPr><w:u w:val="single"/></w:rPr><w:tab/></w:r><w:r><w:tab/></w:r>' .. xe.runs("/"),
      { tabs = tabs }) }, { p("") }, { p("") } }
  end
  local function side(s, gap)
    for i, n in ipairs(s.names) do row(xe.inl(n), nil, i == 1 and gap or 0) end
    ind(xe.inl(s.designation))
  end
  row(xe.runs("In re:"), xe.runs("Case No. " .. plain(meta.case_number)))
  for i, n in ipairs(meta.in_re) do row(xe.inl(n), i == 1 and xe.inl(meta.chapter) or nil) end
  ind(xe.runs("Debtor."))
  rule()
  side(meta.caption[1], SINGLE)
  local label = meta.adversary_label and plain(meta.adversary_label) or "Adv. Case No."
  row(xe.runs("v."), xe.runs(label .. " " .. plain(meta.adversary_number)), SINGLE)
  side(meta.caption[2], SINGLE)
  rule()
  return tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, rows)
end

local function cover(meta)
  local out = {}
  for _, l in ipairs({ "UNITED STATES BANKRUPTCY COURT", "MIDDLE DISTRICT OF FLORIDA",
    pandoc.text.upper(plain(meta.division)) .. " DIVISION" }) do
    out[#out + 1] = xe.raw(p(xe.runs(l, { b = true }), { jc = "center" }))
  end
  -- typst: the caption a double line below the court title (its first row's paragraphs carry it)
  out[#out + 1] = xe.raw((caption(meta):gsub('w:before="0"', 'w:before="' .. BODY .. '"', 3)))
  -- typst: the title a double line below the caption (Word has no space after a table)
  out[#out + 1] = xe.raw(p(xe.runs(full_title(meta), { b = true }), { jc = "center", before = BODY }))
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block())
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local left = { p(meta.date and (xe.runs("Dated: ") .. xe.inl(meta.date)) or "", { before = BODY }) }
  local right = { p(xe.runs("Respectfully submitted,"), { before = BODY }) }
  for i, l in ipairs(sig.firm) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and SINGLE or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = SINGLE })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(sig.lines) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ TEXTW - SIG_COL - SIG_GUTTER, SIG_COL + SIG_GUTTER }, { { left,
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings (typst show heading): single-spaced, a double line above, kept with the text after them; level 1
-- centered bold capitals, level 2 bold, level 3 bold italic, half an inch in.
local function heading(el)
  local runs = xe.inl(el.level == 1 and pandoc.text.upper(plain(el.content)) or el.content,
    { b = true, i = el.level >= 3 })
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(el.level, 3)), xe.KEEP, xe.spacing(BODY, 0, SINGLE),
    xe.ind(el.level >= 3 and INDENT or 0, nil, 0), xe.jc(el.level == 1 and "center" or "left") },
    (runs:gsub("<w:r><w:rPr>(.-)</w:rPr>", function(x)
      -- the Heading 1 style sets capitals; typst prints the text as written (already in capitals)
      return "<w:r><w:rPr>" .. x .. '<w:caps w:val="0"/>' .. "</w:rPr>"
    end))))
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- A paragraph: numbered (the number, a tab to 1 in, the text) unless it starts with ^ (typst body-chunks()).
local function body_paragraph(b)
  local c = b.content
  local first = c[1]
  if first and first.t == "Str" and first.text:sub(1, 1) == "^" then
    first.text = first.text:sub(2)
    if first.text == "" then
      table.remove(c, 1)
      if c[1] and (c[1].t == "Space" or c[1].t == "SoftBreak") then table.remove(c, 1) end
    end
    return styled("Body Text", c), false
  end
  return c, true
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign or pilcrow stays with its number ("¶¶ 41–73"; typst binds it the same way); a single one
-- is bound by xe.inl and xe.inlines.
local function bind_doubled(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and #l[i].text >= 4 and l[i].text:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  doc = doc:walk({ Inlines = bind_doubled })
  -- the frontmatter as read: xe.runs and xe.inl apply the break rules to it themselves (a raw no-break hyphen
  -- would not survive stringify)
  local meta = doc.meta
  doc = doc:walk({ Inlines = xe.inlines })
  local out = cover(meta)
  local n = 0
  local last = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      local blk, numbered = body_paragraph(b)
      if numbered then
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(tostring(n)), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        inl:extend(blk)
        blk = styled("Numbered Paragraph", inl)
      end
      out[#out + 1] = blk
    elseif b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("flmb-motion-brief.lua: a list item must be one paragraph")
        end
        local inl = pandoc.Inlines({ pandoc.Str(j .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        inl:extend(item[1].content)
        -- a list that ends the body keeps its last item with the signature block (typst body-chunks())
        out[#out + 1] = styled((i == last and j == #b.content) and "Conclusion Item Last" or "Conclusion Item", inl)
      end
    else
      error("flmb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
