-- E.D. La. memorandum in support of a motion, docx engine. Mirrors typst/laeb-motion-brief.typ; rules and
-- conventions are in ../README.md. Built here from the frontmatter: the court title, the caption (a table whose party
-- column has a rule at its right edge), the title, the signature block and the certificate of service. In the body:
-- headings are numbered by the filter (I., A., 1.: the number, a tab, the text hanging in the heading styles); a list
-- is numbered (1), (2), ...; paragraphs, block quotations and footnotes are pandoc's own, styled in docx/reference.xml
-- (fb render builds the reference document from it, with the font, the spacing, the margins and the footer). Numbers
-- are typed text, as the typst template types them. Content-agnostic: no case word appears in this file.
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
local SIG_ABOVE, SIG_GAP, LINE_GAP = 480, 480, 240 -- typst signature-above, sig-gap 24 pt, line-gap 12 pt
local CERT_ABOVE, CERT_SIG = 480, 240     -- typst cert-above 24 pt, cert-sig 12 pt

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

-- A single-spaced paragraph: o = { before, after, left, jc, keep, line, first }.
local function p(content, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
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
  -- The title stays with the text after it (typst sticky).
  out[#out + 1] = p(xe.inl(m.title, { b = true }),
    { jc = "center", before = CAPTION_BELOW, after = TITLE_BELOW, keep = true })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Signature block (typst signature-block): the date at the margin; "Respectfully submitted,", the firm, the By line
-- and the counsel lines in the column 3 in from the margin; kept on one page. Certificate of service (typst
-- certificate-block): its title, its text, the signer's /s/ line; kept on one page.
-- ---------------------------------------------------------------------------

local function kept(lines)
  local out = {}
  for i, l in ipairs(lines) do
    local o = l[2]
    o.keep = i < #lines
    out[#out + 1] = p(l[1], o)
  end
  return table.concat(out)
end

local function signature(m)
  local s = m.signature
  local lines = {}
  local above = 0
  if m.date then
    lines[#lines + 1] = { xe.runs("Dated: ") .. xe.inl(m.date), {} }
    above = SIG_GAP
  end
  lines[#lines + 1] = { xe.runs("Respectfully submitted,"), { left = SIG_LEFT, before = above } }
  local gap = SIG_GAP
  if s.firm then
    lines[#lines + 1] = { body(s.firm), { left = SIG_LEFT, before = gap } }
    gap = LINE_GAP
  end
  lines[#lines + 1] = { xe.runs("By: ") .. xe.inl(s.by), { left = SIG_LEFT, before = gap } }
  for j, l in ipairs(items(s.lines)) do
    lines[#lines + 1] = { body(l), { left = SIG_LEFT, before = j == 1 and LINE_GAP or 0 } }
  end
  return space(SIG_ABOVE) .. kept(lines)
end

local function certificate(c)
  return space(CERT_ABOVE) .. kept({
    { xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", line = 480 } },
    { body(c.text), { line = 480, first = 720 } },
    { xe.runs("/s/ ") .. body(c.signer), { left = SIG_LEFT, before = CERT_SIG } },
  })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("10:9-109(a)(3)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("Plaintiffs/Debtors", "CM/ECF"), where LibreOffice keeps the word whole: a zero-width space
-- (U+200B) after it. Neither shows in the PDF text. U+2010 HYPHEN, which Times New Roman has no glyph for, is the
-- hyphen-minus, as in typst (no fallback face, at which LibreOffice splits the word).
local function break_rules(s)
  local t = s.text
  if t:find("\u{2010}", 1, true) then t = t:gsub("\u{2010}", "-") end
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

-- A body paragraph; one that anchors a footnote has no widow control (typst moves the line with the mark on alone
-- when its note does not fit).
local function styled(style, inlines)
  if has_note(inlines) then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function labelled(label, content)
  local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(label .. "\t")) })
  inl:extend(content)
  return inl
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do s = s .. v[2]; n = n - v[1] end
  end
  return s
end

local function finish(doc)
  local m = doc.meta
  local out = { xe.raw(cover(m)) }
  local c = { 0, 0, 0 }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lvl = math.min(b.level, 3)
      local label
      if lvl == 1 then
        c = { c[1] + 1, 0, 0 }
        label = roman(c[1]) .. "."
      elseif lvl == 2 then
        c = { c[1], c[2] + 1, 0 }
        label = string.char(64 + c[2]) .. "."
      else
        c = { c[1], c[2], c[3] + 1 }
        label = c[3] .. "."
      end
      -- Level 1 in capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
      local content = b.content
      if lvl == 1 then content = content:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end }) end
      out[#out + 1] = pandoc.Header(lvl, labelled(label, content))
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = styled("Body Text", b.content)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- Numbered (1), (2), ... (typed text, as the typst template numbers them).
      for i, item in ipairs(b.content) do
        out[#out + 1] = pandoc.Div({ pandoc.Para(labelled("(" .. i .. ")", pandoc.utils.blocks_to_inlines(item))) },
          { ["custom-style"] = "Pleading List" })
      end
    else
      -- The block quotation (Block Text) is kept as pandoc writes it.
      out[#out + 1] = b
    end
  end

  local blocks = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  blocks:insert(xe.raw(signature(m)))
  if m.certificate then blocks:insert(xe.raw(certificate(m.certificate))) end
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
