-- E.D. La. adversary complaint, docx engine. Mirrors typst/laeb-adversary-complaint.typ; rules and conventions are
-- in ../README.md. Built here from the frontmatter: the court title, the caption (a table whose party column has a
-- rule at its right edge), the title, the lead-in and the signature block. In the body: every top-level paragraph is
-- a numbered allegation (the number, a tab, the text; Fed. R. Civ. P. 10(b)); a list is lettered (a), (b), ...;
-- headings, block quotations and footnotes are pandoc's own, styled in docx/reference.xml (fb render builds the
-- reference document from it, with the font, the spacing, the margins and the footer). Numbers are typed text, as
-- the typst template types them. Content-agnostic: no case word appears in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local SINGLE = 276                        -- typst pitch-single 13.8 pt
local TEXTW = 9360                        -- typst text-width, 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360    -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_PAD, CAP_FOOT = 200, 120        -- typst caption-pad 10 pt, caption-foot 6 pt
local CASE_PAD = 144                      -- typst case-pad 0.1 in
local DESIG = 2304                        -- typst designation-indent 1.6 in
local COURT_BELOW, CAPTION_BELOW, TITLE_BELOW = 240, 240, 240 -- typst court-below, caption-below, title-below 12 pt
local SIG_LEFT = 4320                     -- typst sig-left 3 in
local SIG_ABOVE, SIG_GAP, BLOCK_GAP = 480, 480, 240 -- typst signature-above, sig-gap 24 pt, block-gap 12 pt

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

local function body(v)
  return type(v) == "string" and xe.runs(v) or xe.inl(v)
end

-- A single-spaced paragraph: o = { before, after, left, jc, keep }.
local function p(content, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, content)
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption (Form 416), title
-- ---------------------------------------------------------------------------

-- Parties in order (typst party-stack): "v." (or the party's own sep) before every party but the first unless sep is
-- ""; a blank line between two parties; the designation 1.6 in in.
local function party_column(c)
  local out = {}
  if c.lead then out[#out + 1] = p(body(c.lead)) end
  for k, party in ipairs(items(c.parties)) do
    local gap = k > 1 and SINGLE or 0
    local sep = party.sep == nil and "v." or pandoc.utils.stringify(party.sep)
    if k > 1 and sep ~= "" then
      out[#out + 1] = p(body(party.sep or "v."), { before = gap })
      gap = 0
    end
    for _, n in ipairs(items(party.names)) do
      out[#out + 1] = p(body(n), { before = gap })
      gap = 0
    end
    out[#out + 1] = p(body(party.designation), { left = DESIG })
  end
  return table.concat(out)
end

local function cover(m)
  local out = {
    p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }),
    p(xe.runs("EASTERN DISTRICT OF LOUISIANA", { b = true }), { jc = "center" }),
    space(COURT_BELOW),
  }
  local right = {}
  for _, c in ipairs(items(m.case_info)) do right[#right + 1] = p(body(c)) end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local mar = '<w:tcMar><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  local rest = TEXTW - CAP_LEFT - CAP_GUTTER
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GUTTER .. '"/>'
    .. '<w:gridCol w:w="' .. rest .. '"/></w:tblGrid><w:tr>'
    .. cell(CAP_LEFT, party_column(m.caption), rule .. mar)
    .. cell(CAP_GUTTER, p(""))
    .. cell(rest, table.concat(right), '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>')
    .. '</w:tr></w:tbl>'
  out[#out + 1] = p(xe.inl(m.title, { b = true }), { jc = "center", before = CAPTION_BELOW, after = TITLE_BELOW, keep = true })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block): the date at the margin; "Respectfully submitted,", the BY line and each
-- counsel block in the column 3 in from the margin, blocks separated by "And"; kept on one page.
-- ---------------------------------------------------------------------------

local function signature(m)
  local lines = {}
  local function add(content, left, before) lines[#lines + 1] = { content, left, before } end
  local above = 0
  if m.date then
    add(xe.runs("Dated: ") .. xe.inl(m.date), 0, 0)
    above = SIG_GAP
  end
  add(xe.runs("Respectfully submitted,"), SIG_LEFT, above)
  add(xe.runs("BY: ") .. xe.inl(m.signature.by), SIG_LEFT, SIG_GAP)
  for i, b in ipairs(items(m.signature.blocks)) do
    if i > 1 then add(xe.runs("And"), SIG_LEFT, BLOCK_GAP) end
    for j, l in ipairs(items(b)) do add(body(l), SIG_LEFT, j == 1 and BLOCK_GAP or 0) end
  end
  local out = { space(SIG_ABOVE) }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l[1], { left = l[2], before = l[3], keep = i < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("mud/fluid"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
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

local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

-- A paragraph in `style`; a paragraph that anchors a footnote takes the style's "Note" variant (no widow control:
-- typst moves the line with the mark on alone when its note does not fit).
local function styled(style, inlines)
  if has_note(inlines) then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function labelled(label, content)
  local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(label .. "\t")) })
  inl:extend(content)
  return inl
end

local function finish(doc)
  local m = doc.meta
  local out = { xe.raw(cover(m)) }
  if m.lead_in then out[#out + 1] = styled("Body Text", pandoc.Inlines(m.lead_in)) end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- Level 1 in capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
      local c = b.content
      if b.level == 1 then c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end }) end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = styled("Numbered Paragraph", labelled(n .. ".", b.content))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- Lettered (a), (b), ... (typed text, as the typst template numbers them).
      for i, item in ipairs(b.content) do
        out[#out + 1] = pandoc.Div({ pandoc.Para(labelled("(" .. string.char(96 + i) .. ")",
          pandoc.utils.blocks_to_inlines(item))) }, { ["custom-style"] = "Pleading List" })
      end
    else
      -- The block quotation (Block Text) is kept as pandoc writes it.
      out[#out + 1] = b
    end
  end

  local blocks = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  blocks:insert(xe.raw(signature(m)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
