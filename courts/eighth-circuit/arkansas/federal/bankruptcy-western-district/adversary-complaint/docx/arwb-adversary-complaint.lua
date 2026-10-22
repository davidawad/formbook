-- arwb adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on the styles of
-- docx/reference.xml (fb render builds reference.docx from it). The layout is the one in
-- typst/arwb-adversary-complaint.typ: the court title, the caption (a borderless two-column table: the debtor and
-- parties on the left, the case numbers on the right), the title of the paper, the numbered paragraphs, the centred
-- section headings, the prayer, and the signature block. Nothing here sets a line break or a position by hand, and
-- nothing is case-specific: every name and number comes from the sample's frontmatter.
-- Numbers: the template numbers the body paragraphs 1, 2, ... (Fed. R. Civ. P. 10(b), via Rule 7010).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 312 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY = 480                       -- typst pitch-body, 24 pt
local SINGLE = 312                     -- typst pitch-single, 15.6 pt
local LINE_GAP = 312                   -- typst line-gap, one blank single line
local HALF_GAP = 156                   -- typst half-gap, half a single line
local INDENT = 720                     -- typst para-indent, 0.5 in
local NUMBER_TAB = 1440                -- typst para-indent + number-box: the text of a numbered paragraph at 1 in
local TEXTW = 9360                     -- the text width, 6.5 in
local CAP_LEFT = 5328                  -- typst caption-left, 3.7 in
local CAP_GUTTER = 288                 -- typst caption-gutter, 0.2 in
local DESIG = 1296                     -- typst designation-indent, 0.9 in
local SIG_LEFT = 4680                  -- typst signature-left, 3.25 in

local function need(meta, key)
  if meta[key] == nil then error("arwb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function plain(m)
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function upper(m)
  return pandoc.text.upper(plain(m))
end

-- A paragraph: o = { before, after, line, left, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = o.keep end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A run of paragraphs kept on one page (typst: block(breakable: false)): every one but the last keeps with the next.
local function kept(ps)
  for i, x in ipairs(ps) do
    if i < #ps then ps[i] = x:gsub("^<w:p><w:pPr>", "<w:p><w:pPr>" .. xe.KEEP, 1) end
  end
  return ps
end

-- The cover: court title, caption, title of the paper (typst cover()).
local function cover(meta, out)
  for _, l in ipairs(need(meta, "court")) do
    out[#out + 1] = p(xe.runs(upper(l)), { jc = "center" })
  end

  local c = need(meta, "caption")
  local left = {}
  left[#left + 1] = p(xe.runs("In re:"))
  for _, n in ipairs(c.debtor.names) do left[#left + 1] = p(xe.inl(n)) end
  left[#left + 1] = p(xe.inl(c.debtor.designation), { left = DESIG })
  for k, party in ipairs(c.parties) do
    for j, n in ipairs(party.names) do
      left[#left + 1] = p(xe.inl(n), { before = j == 1 and LINE_GAP or 0 })
    end
    left[#left + 1] = p(xe.inl(party.designation), { left = DESIG })
    if k < #c.parties then
      left[#left + 1] = p(xe.runs("v."), { left = DESIG, before = LINE_GAP, after = LINE_GAP })
    end
  end

  local right = {
    p(xe.runs("Case No. " .. plain(need(meta, "case_number")))),
    p(xe.runs("Chapter " .. plain(need(meta, "chapter")))),
    p(xe.runs("Adv. Pro. No. " .. plain(need(meta, "adversary_number"))), { before = 2 * LINE_GAP }),
  }

  -- the caption starts a blank line below the court title (typst: block(above: line-gap))
  left[1] = left[1]:gsub('w:before="0"', 'w:before="' .. LINE_GAP .. '"', 1)
  right[1] = right[1]:gsub('w:before="0"', 'w:before="' .. LINE_GAP .. '"', 1)

  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/></w:tcPr>'
    .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. (TEXTW - CAP_LEFT) .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_GUTTER
    .. '" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'

  -- the title of the paper: bold capitals, centred, on a body line half a single line below the caption
  out[#out + 1] = p(xe.runs(upper(need(meta, "document_title")), { b = true }),
    { jc = "center", line = BODY, before = HALF_GAP })
end

-- The signature block (typst signature-block()): "Respectfully Submitted," then one block per signer, half a line
-- apart, each line single spaced at 3.25 in; the block is not split across pages.
local function signature(meta, out)
  local ps = { p(xe.runs("Respectfully Submitted,"), { left = SIG_LEFT, before = HALF_GAP, after = HALF_GAP }) }
  for i, b in ipairs(need(meta, "signature")) do
    for j, l in ipairs(b) do
      ps[#ps + 1] = p(xe.inl(l), { left = SIG_LEFT, before = (i > 1 and j == 1) and HALF_GAP or 0 })
    end
  end
  for _, x in ipairs(kept(ps)) do out[#out + 1] = x end
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(I)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function finish(doc)
  local meta = doc.meta
  local out = {}

  cover(meta, out)
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT })
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- a section heading: centred bold capitals on a body line, kept with the paragraph after it
      out[#out + 1] = p(xe.runs(upper(b.content), { b = true }), { jc = "center", line = BODY, keep = xe.KEEP })
    elseif b.t == "Para" and b.content[1] and b.content[1].t == "Str" and b.content[1].text:match("^WHEREFORE") then
      -- the prayer: unnumbered, and kept with the signature block (typst: sticky)
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = "<w:keepNext/>" })
    elseif b.t == "Para" then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = NUMBER_TAB })
    else
      error("arwb-adversary-complaint: unsupported block " .. b.t .. " (README.md, Markdown contract)", 0)
    end
  end

  signature(meta, out)

  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  meta.title = nil
  meta.author = nil
  meta.date = nil
  return pandoc.Pandoc(blocks, meta)
end

return { { Str = break_rules }, { Pandoc = finish } }
