-- arwb motion brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on the styles of
-- docx/reference.xml (fb render builds reference.docx from it). The layout is the one in typst/arwb-motion-brief.typ:
-- the court title (bold), the caption (a borderless two-column table: the debtor on the left, the case number and
-- chapter on the right), the title of the paper, the opening paragraph, the argument headings (numbered by the
-- template from the heading level: I., A., 1., a.), the body paragraphs, the labelled factor items, the signature
-- block, and the certificate of service. Nothing here sets a line break or a position by hand, and nothing is
-- case-specific: every name and number comes from the sample's frontmatter.
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
local LABEL = 720                      -- typst label-box, 0.5 in
local LIST_LEFT = 720                  -- typst list-left, 0.5 in
local TEXTW = 9360                     -- the text width, 6.5 in
local CAP_LEFT = 5184                  -- typst caption-left, 3.6 in
local CAP_GUTTER = 288                 -- typst caption-gutter, 0.2 in
local DESIG = 1296                     -- typst designation-indent, 0.9 in
local RECIPIENT = 720                  -- typst recipient-indent, 0.5 in
local SIG_LEFT = 4680                  -- typst signature-left, 3.25 in

local function need(meta, key)
  if meta[key] == nil then error("arwb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function plain(m)
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function upper(m)
  return pandoc.text.upper(plain(m))
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = o.keep end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, o.hanging == nil and (o.first or 0) or nil)
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

-- the numbers the template types for the argument headings: I., A., 1., a.
local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do
      s = s .. v[2]
      n = n - v[1]
    end
  end
  return s
end

-- The cover: court title (bold), caption, title of the paper (typst cover()).
local function cover(meta, out)
  for _, l in ipairs(need(meta, "court")) do
    out[#out + 1] = p(xe.runs(upper(l), { b = true }), { jc = "center" })
  end

  local c = need(meta, "caption")
  local left = {}
  for _, n in ipairs(c.debtor.names) do left[#left + 1] = p(xe.inl(n)) end
  left[#left + 1] = p(xe.inl(c.debtor.designation), { left = DESIG })
  local right = {
    p(xe.runs("Case No: " .. plain(need(meta, "case_number")))),
    p(xe.runs("Chapter " .. plain(need(meta, "chapter")))),
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

  -- the title of the paper: bold capitals, centred, on body lines half a single line below the caption
  out[#out + 1] = p(xe.runs(upper(need(meta, "brief_title")), { b = true }),
    { jc = "center", line = BODY, before = HALF_GAP })
end

-- The body (typst body-of()): headings numbered by level, a list as labelled items, the rest as paragraphs; the
-- last paragraph keeps with the signature block after it (typst: sticky).
local function body(blocks, out)
  local c = { 0, 0, 0, 0 }
  for idx, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = b.level
      local label
      if lv == 2 then
        c[1] = c[1] + 1; c[2] = 0; c[3] = 0; c[4] = 0
        label = roman(c[1]) .. "."
      elseif lv == 3 then
        c[2] = c[2] + 1; c[3] = 0; c[4] = 0
        label = string.char(64 + c[2]) .. "."
      elseif lv == 4 then
        c[3] = c[3] + 1; c[4] = 0
        label = c[3] .. "."
      elseif lv == 5 then
        c[4] = c[4] + 1
        label = string.char(96 + c[4]) .. "."
      else
        error("arwb-motion-brief: heading level " .. lv .. " is not used by the template (use ## to #####)", 0)
      end
      out[#out + 1] = p(xe.runs(label .. "\t" .. upper(b.content), { b = true }),
        { line = BODY, left = LABEL, hanging = LABEL, tab = LABEL, keep = xe.KEEP })
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
          error("arwb-motion-brief: a list item is one paragraph (README.md, Markdown contract)", 0)
        end
        out[#out + 1] = p(xe.runs("(" .. i .. ")\t") .. xe.inl(item[1].content),
          { line = BODY, left = LIST_LEFT + LABEL, hanging = LABEL, tab = LIST_LEFT + LABEL })
      end
    elseif b.t == "Para" then
      out[#out + 1] = p(xe.inl(b.content),
        { line = BODY, first = INDENT, keep = idx == #blocks and "<w:keepNext/>" or nil })
    else
      error("arwb-motion-brief: unsupported block " .. b.t .. " (README.md, Markdown contract)", 0)
    end
  end
end

-- The signature block (typst signature-block()): "Respectfully submitted," then the signer's lines, single
-- spaced at 3.25 in; the block is not split across pages.
local function signature(meta, out)
  local ps = { p(xe.runs("Respectfully submitted,"), { left = SIG_LEFT, before = HALF_GAP, after = HALF_GAP }) }
  for _, l in ipairs(need(meta, "signature")) do ps[#ps + 1] = p(xe.inl(l), { left = SIG_LEFT }) end
  for _, x in ipairs(kept(ps)) do out[#out + 1] = x end
end

-- The certificate of service (typst certificate()): a centred heading, the text, the recipients, the signer; one
-- block, not split across pages.
local function certificate(meta, out)
  local cos = meta.certificate_of_service
  if not cos then return end
  local ps = {
    p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", line = BODY, before = HALF_GAP }),
    p(xe.inl(need(cos, "text")), { line = BODY, first = INDENT }),
  }
  for i, r in ipairs(need(cos, "recipients")) do
    ps[#ps + 1] = p(xe.inl(r), { left = RECIPIENT, before = i == 1 and HALF_GAP or 0 })
  end
  for i, l in ipairs(need(cos, "signer")) do
    ps[#ps + 1] = p(xe.inl(l), { left = SIG_LEFT, before = i == 1 and LINE_GAP or 0 })
  end
  for _, x in ipairs(kept(ps)) do out[#out + 1] = x end
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("362(d)(1)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("T/R"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
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
  body(doc.blocks, out)
  signature(meta, out)
  certificate(meta, out)

  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  meta.title = nil
  meta.author = nil
  meta.date = nil
  return pandoc.Pandoc(blocks, meta)
end

return { { Str = break_rules }, { Pandoc = finish } }
