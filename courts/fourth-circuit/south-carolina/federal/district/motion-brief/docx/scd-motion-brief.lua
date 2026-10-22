-- scd-motion-brief.lua (docx engine). Mirrors typst/scd-motion-brief.typ; rules are in ../README.md. Builds from the
-- sample's frontmatter what the typst template builds: the court heading, the caption table (parties, a column of
-- ")" marks, the case number), the document title and the signature block (location and date; the signing
-- attorneys; the firm). Body paragraphs, the indented quotation and the footnotes are pandoc's, in the styles of
-- docx/reference.xml (fb render builds the reference document from it). Every string comes from the frontmatter.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line and a footnote line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                            -- typst pitch-single 13.8 pt
local TEXTW = 9360                            -- typst text-width, 6.5 in
local PARTY_STEP = 720                        -- typst party-step 0.5 in
local PAREN_W, CASE_W = 432, 3744             -- typst paren-w 0.3 in, case-w 2.6 in
local SIG_W = 4608                            -- typst sig-w 3.2 in
local COURT_BELOW = 360                       -- typst court-below 18 pt
local ROW_GAP = 216                           -- typst row-gap 10.8 pt
local TITLE_ABOVE, TITLE_BELOW = 360, 288     -- typst title-above 18 pt, title-below 14.4 pt
local HEAD_ABOVE, SUB_ABOVE, HEAD_BELOW = 288, 240, 216 -- typst heading-above, subheading-above, heading-below
local SIG_ABOVE, FIRM_GAP = 360, 144          -- typst sig-above 18 pt, firm-gap 7.2 pt

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A metadata value as inlines (typst reads every frontmatter string as markdown).
local function md(v)
  if type(v) == "string" then
    return pandoc.utils.blocks_to_inlines(pandoc.read(v, "commonmark+smart").blocks)
  end
  return v
end

-- A single-spaced paragraph: o = { before, after, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single-spaced lines (typst line-stack): an empty item is a blank line; `gap` between two lines; `left(k)` the
-- indent of line k; `above` the space above the first line.
local function stack(lines, o)
  o = o or {}
  local out, blank = {}, 0
  for k, l in ipairs(lines) do
    if txt(l) == "" then
      blank = blank + SINGLE
    else
      local before = k == 1 and (o.above or 0) or math.max(o.gap or 0, blank)
      out[#out + 1] = p(xe.inl(md(l)), { before = before, left = o.left and o.left(k) or 0, jc = o.jc })
      blank = 0
    end
  end
  return table.concat(out)
end

local function cell(width, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. inner .. '</w:tc>'
end

-- A borderless fixed-width table of one unsplittable row; widths in twips.
local function table_xml(widths, cells)
  local cols, tcs = {}, {}
  for i, w in ipairs(widths) do
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = cell(w, cells[i])
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption, title
-- ---------------------------------------------------------------------------

local function cover(m)
  local out = {}
  local court = items(m.court)
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(txt(l):upper(), { b = true }),
      { jc = "center", keep = true, after = i == #court and COURT_BELOW or 0 })
  end
  local parties, parens = {}, {}
  for _, r in ipairs(items(m.parties)) do
    parties[#parties + 1] = r.text
    parens[#parens + 1] = ")"
  end
  local left = function(k) return (tonumber(txt(m.parties[k].indent)) or 0) * PARTY_STEP end
  out[#out + 1] = table_xml({ TEXTW - PAREN_W - CASE_W, PAREN_W, CASE_W }, {
    stack(parties, { gap = ROW_GAP, left = left }),
    stack(parens, { gap = ROW_GAP, jc = "center" }),
    stack({ "CASE NO.: " .. txt(m.case_number) }),
  })
  out[#out + 1] = p(xe.inl(upper(md(m.doc_title)), { b = true }),
    { jc = "center", keep = true, before = TITLE_ABOVE, after = TITLE_BELOW })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block: place and date at the left, the signers and the firm at the right margin, kept on one page
-- ---------------------------------------------------------------------------

local function signature(m)
  local s = m.signature
  local right = stack(items(s.signers), { above = SIG_ABOVE }) .. stack(items(s.firm), { above = FIRM_GAP })
  return table_xml({ TEXTW - SIG_W, SIG_W }, {
    stack({ s.location, s.dated }, { above = SIG_ABOVE }),
    right,
  })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("ESSER/CARES"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text.
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

-- A paragraph that anchors a footnote has no widow control ("Body Text Note", docx/reference.xml).
local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function styled(style, inlines)
  if style == "Body Text" and has_note(inlines) then style = "Body Text Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- The markdown blocks as the typst template sets them (typst blocks()).
local function convert(blocks, out)
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      -- levels 1 and 2 centred bold capitals, level 3 bold at the margin; single spaced, kept with the next block
      local sub = b.level >= 3
      out[#out + 1] = xe.raw(xe.para({ xe.style("Heading" .. math.min(b.level, 3)), xe.KEEP,
        xe.spacing(sub and SUB_ABOVE or HEAD_ABOVE, HEAD_BELOW, SINGLE), xe.ind(0, nil, 0),
        xe.jc(sub and "left" or "center") }, xe.inl(sub and b.content or upper(b.content), { b = true })))
    elseif b.t == "BlockQuote" then
      for _, c in ipairs(b.content) do out[#out + 1] = styled("Block Text", c.content) end
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled("Body Text", b.content)
    else
      error("scd-motion-brief.lua: unexpected block " .. b.t)
    end
  end
  return out
end

local function finish(doc)
  local m = doc.meta
  local out = convert(doc.blocks, { xe.raw(cover(m)) })
  out[#out + 1] = xe.raw(signature(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc(pandoc.Blocks(out):walk({ Inlines = xe.inlines }), pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
