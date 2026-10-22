-- iasb motion with supporting brief, docx engine. Mirrors typst/iasb-motion-brief.typ; rules and conventions are in
-- ../README.md (Engines). The cover (court name, caption with the label and the hearing line), the numbered paragraphs,
-- the headings, the lettered items, the signature block, the verifications and the certificate of service are built
-- here. Font, spacing, margins and the page number are styles and section settings in docx/reference.xml (fb render
-- builds the reference document from it). Footnotes are pandoc's native footnotes (style "footnote text", 10 pt).
-- Numbers are typed text, as the typst template types them, so every viewer shows the same numbering.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 280 a single line, 230 a footnote line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 280            -- typst pitch-body, pitch-single
local INDENT, NUMBER_TAB = 720, 1440     -- typst para-indent; para-indent + number-box
local TEXTW = 9360                       -- typst text-width, 6.5 in
local CAP_LEFT, CAP_GUTTER = 4896, 360   -- typst caption-left 3.4 in, caption-gutter 0.25 in
local CAP_PAD, CASE_PAD = 200, 144       -- typst caption-pad 10 pt, case-pad 0.1 in
local CAPTION_GAP = 240                  -- typst caption-gap 12 pt
local COURT_BELOW, CAPTION_BELOW = 480, 480 -- typst court-below, caption-below 24 pt
local SIG_LEFT, SIG_GUTTER = 4032, 288   -- typst sig-left 2.8 in, sig-gutter 0.2 in
local SIG_ABOVE = 480                    -- typst signature-above 24 pt
local PART_ABOVE, PART_TITLE_BELOW = 480, 240 -- typst part-above 24 pt, part-title-below 12 pt

local function txt(v)
  return v and pandoc.utils.stringify(v) or ""
end

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

-- A paragraph: o = { before, after, line (single), left, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Vertical space of its own (typst v() or a block's space above): an empty paragraph in a line box of that height.
local function space(twips, keep)
  return xe.para({ keep and xe.KEEP or "", xe.spacing(0, 0, twips) }, "")
end

-- A run of paragraphs kept on one page (typst: block(breakable: false)): every one but the last keeps with the next.
local function kept(ps)
  for i, x in ipairs(ps) do
    if i < #ps and not x:find("^<w:p><w:pPr><w:keepNext/>") then
      ps[i] = x:gsub("^<w:p><w:pPr>", "<w:p><w:pPr>" .. xe.KEEP, 1)
    end
  end
  return ps
end

-- A one-row table with fixed column widths (twips) and no cell margins unless a cell sets its own; the row is not
-- split across pages (typst: one grid row).
local function table_xml(widths, cells)
  local grid, total = {}, 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

local function cell(width, inner, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- A line of text: a string as runs, a metadata value as its inlines.
local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- Single-spaced lines (typst line-stack).
local function stack(lines, o)
  local out = {}
  for _, l in ipairs(lines) do out[#out + 1] = p(line(l), o) end
  return table.concat(out)
end

-- A signature block (typst signature-grid): typst signature-above, then the date (left) and the signature lines.
local function signature_grid(date, lines)
  return space(SIG_ABOVE, true) .. table_xml({ SIG_LEFT, SIG_GUTTER, TEXTW - SIG_LEFT - SIG_GUTTER }, {
    cell(SIG_LEFT, p(xe.runs("Dated: ") .. xe.inl(date))),
    cell(SIG_GUTTER, p("")),
    cell(TEXTW - SIG_LEFT - SIG_GUTTER, stack(lines)),
  })
end

-- The centred bold title of a verification or of the certificate (typst part-title), kept with what follows.
local function part_title(t)
  return p(xe.runs(txt(t):upper(), { b = true }), { jc = "center", after = PART_TITLE_BELOW, keep = true })
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption (debtor on the left; case number, chapter, the label, the title and the hearing on the right)
-- ---------------------------------------------------------------------------

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

local function cover(m)
  local out = {
    p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }),
    p(xe.runs("SOUTHERN DISTRICT OF IOWA", { b = true }), { jc = "center" }),
    space(COURT_BELOW),
  }

  local left = { "In re:" }
  for _, d in ipairs(items(m.debtors)) do left[#left + 1] = d end
  left[#left + 1] = m.debtor_role

  local right = { "Case No. " .. txt(m.case_number), "Chapter " .. txt(m.chapter) }
  if m.adv_number and txt(m.adv_number) ~= "" then right[#right + 1] = "Adv. Proc. No. " .. txt(m.adv_number) end
  local right_xml = stack(right)
  if m.label and txt(m.label) ~= "" then right_xml = right_xml .. p(line(m.label, { b = true })) end
  right_xml = right_xml .. p(xe.inl(m.brief_title, { b = true }), { before = CAPTION_GAP })
  if m.hearing and txt(m.hearing) ~= "" then right_xml = right_xml .. p(xe.inl(m.hearing), { before = CAPTION_GAP }) end

  local borders = '<w:tcBorders>' .. string.format(RULE, "bottom") .. string.format(RULE, "right") .. '</w:tcBorders>'
  local mar = '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = table_xml({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    cell(CAP_LEFT, stack(left), borders .. mar),
    cell(CAP_GUTTER, p("")),
    cell(TEXTW - CAP_LEFT - CAP_GUTTER, right_xml, '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>'),
  })
  out[#out + 1] = space(CAPTION_BELOW)
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Verifications and the certificate of service: each one block, kept on one page (typst breakable: false), after
-- typst part-above of space of its own.
-- ---------------------------------------------------------------------------

-- The blocks of a metadata value: a YAML block scalar is a Blocks list; a single line is one paragraph.
local function blocks_of(v)
  if v.t == "MetaBlocks" or pandoc.utils.type(v) == "Blocks" then return pandoc.Blocks(v) end
  return pandoc.Blocks({ pandoc.Para(pandoc.Inlines(v)) })
end

local function declaration(d)
  local ps = { part_title(d.title) }
  for _, b in ipairs(blocks_of(d.body)) do
    if b.t == "OrderedList" then
      local n = b.start
      for _, item in ipairs(b.content) do
        ps[#ps + 1] = p(xe.runs(n .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)),
          { line = BODY, first = INDENT, tab = NUMBER_TAB })
        n = n + 1
      end
    elseif b.t == "Para" or b.t == "Plain" then
      ps[#ps + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    end
  end
  ps[#ps + 1] = signature_grid(d.date, { "/s/ " .. txt(d.signer), d.signer })
  return space(PART_ABOVE) .. table.concat(kept(ps))
end

local function certificate(svc)
  local ps = {
    part_title(svc.title),
    p(xe.inl(svc.text), { line = BODY, first = INDENT }),
    p(xe.runs("/s/ " .. txt(svc.signer)), { left = SIG_LEFT + SIG_GUTTER, before = SIG_ABOVE }),
    p(xe.inl(svc.signer), { left = SIG_LEFT + SIG_GUTTER }),
  }
  return space(PART_ABOVE) .. table.concat(kept(ps))
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("CM/ECF"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ." after a word: UAX #14 has no break before a full stop, LibreOffice
-- breaks there even after a word joiner): the space becomes a no-break space, as wide.
local function no_break_before_stop(l)
  for i = 2, #l do
    local s = l[i]
    if s.t == "Str" and l[i - 1].t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
  end
  return l
end

-- A paragraph that anchors a footnote has no widow control (the "Note" styles, docx/reference.xml).
local function has_note(inlines)
  local note = false
  pandoc.Inlines(inlines):walk({ Note = function() note = true end })
  return note
end

local function styled(style, inlines)
  if has_note(inlines) then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

-- A numbered paragraph: the number, a tab to the text (typst number-box), and the text.
local function numbered(n, content)
  local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(n .. ".\t")) })
  inl:extend(content)
  return styled("Numbered Paragraph", inl)
end

local function finish(doc)
  local m = doc.meta
  if not m.signature then error("iasb-motion-brief: frontmatter needs signature") end

  local out = { xe.raw(cover(m)) }
  if m.lead_in then out[#out + 1] = styled("Body Text", pandoc.Inlines(m.lead_in)) end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- Level 1 in capitals, as typst's upper() (the text is upper-cased, not a style, so the PDF text agrees).
      local c = b.content
      if b.level == 1 then
        c = c:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
      end
      out[#out + 1] = pandoc.Header(math.min(b.level, 3), c)
    elseif b.t == "Para" or b.t == "Plain" then
      if pandoc.utils.stringify(b):sub(1, 9) == "WHEREFORE" then
        -- The conclusion is not numbered; it stays with the signature block that follows it (typst sticky).
        out[#out + 1] = styled("Conclusion", b.content)
      else
        n = n + 1
        out[#out + 1] = numbered(n, b.content)
      end
    elseif b.t == "BulletList" then
      -- Lettered items A., B., C. (the letter is typed text, as in the typst template).
      for i, item in ipairs(b.content) do
        local inl = pandoc.Inlines({ pandoc.RawInline("openxml", xe.runs(string.char(64 + i) .. ".\t")) })
        inl:extend(pandoc.utils.blocks_to_inlines(item))
        out[#out + 1] = styled("Prayer Item", inl)
      end
    else
      -- The block quotation (Block Text) is kept as pandoc writes it.
      out[#out + 1] = b
    end
  end

  local body = pandoc.Blocks(out):walk({ Inlines = xe.inlines })
  local tail = { signature_grid(m.date, { "/s/ " .. txt(m.signature.signer), table.unpack(items(m.signature.lines)) }) }
  for _, d in ipairs(items(m.declarations)) do tail[#tail + 1] = declaration(d) end
  if m.service then tail[#tail + 1] = certificate(m.service) end
  body:insert(xe.raw(table.concat(tail)))
  -- The frontmatter was consumed above; pandoc would otherwise write its title and date at the top of the document.
  return pandoc.Pandoc(body, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = no_break_before_stop }, { Pandoc = finish } }
