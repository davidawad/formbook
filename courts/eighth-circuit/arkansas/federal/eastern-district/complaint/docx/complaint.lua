-- complaint.lua (docx engine): the Word output of the typst template (../typst/ared-complaint.typ). Pandoc passes
-- the YAML frontmatter as the document metadata; this filter writes the whole document as WordprocessingML:
--   * cover: court title (two lines, plus the division if the sample gives one), the caption (party column closed
--     by a rule at right and bottom; the case number and the title of the paper at right);
--   * the lead-in (an unnumbered opening paragraph);
--   * numbered paragraphs (Fed. R. Civ. P. 10(b)): "1." then a tab; a paragraph starting "~ " is unnumbered;
--   * headings (level 1 in capitals, as typst upper()); lettered lists "(a)", "(b)", ...; the signature block.
-- Not built: a table of contents or authorities (none in the exemplar; see ../README.md). Nothing here is
-- case-specific: every name and number comes from the sample's frontmatter. Styles live in reference.xml (fb render
-- builds reference.docx from it).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY = 480                          -- typst pitch (LR 5.5(a): double space)
local SINGLE = 276                        -- typst pitch-single
local CAP_LEFT, CAP_GUTTER = 4608, 288    -- typst caption-left 3.2 in, caption-gutter 0.2 in
local CAP_RIGHT = 9360 - CAP_LEFT - CAP_GUTTER
local CAP_INSET, CAP_PAD = 200, 160       -- typst caption-inset: right 10 pt, bottom 8 pt
local CAP_RULE = 15                       -- the 0.75 pt rule: LibreOffice adds it to the cell's height, typst does not
local CASE_PAD = 144                      -- typst case-pad 0.1 in
local SIG_LEFT = 3744                     -- typst sig-left 2.6 in
local SIG_GAP = 240                       -- typst sig-gap 12 pt

local stringify = pandoc.utils.stringify

local function str(v)
  return v and stringify(v) or ""
end

-- A paragraph: o = { style, before, after, line, left, hanging, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Several single-spaced lines, one paragraph each; an empty item leaves one blank line before the next (typst lines).
local function lines(items, before)
  local out = {}
  local gap = before or 0
  for _, l in ipairs(items) do
    if str(l) == "" then
      gap = math.max(gap, SINGLE)
    else
      out[#out + 1] = p(xe.inl(l), { before = gap })
      gap = 0
    end
  end
  return out
end

local function cell(width, tcpr, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. tcpr .. "</w:tcPr>" .. table.concat(paras)
    .. "</w:tc>"
end

local function tbl(widths, cells)
  local cols = {}
  local total = 0
  for _, w in ipairs(widths) do
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. "</w:tblPr><w:tblGrid>" .. table.concat(cols) .. "</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>"
    .. table.concat(cells) .. "</w:tr></w:tbl>"
end

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

-- The court title, at the body pitch.
local function court_title(meta)
  local rows = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF ARKANSAS" }
  if meta.division then rows[#rows + 1] = pandoc.text.upper(str(meta.division)) end
  local out = {}
  for _, r in ipairs(rows) do out[#out + 1] = p(xe.runs(r, { b = true }), { line = BODY, jc = "center" }) end
  return out
end

-- The caption: each party's names and designation at left, "v." between them a line above and below; the case
-- number, then a line below it the bold title (and the jury demand) at right. A blank double-spaced line before and
-- after it (typst: block(above: pitch, below: pitch)).
local function caption(meta)
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v."), { before = SINGLE, after = SINGLE }) end
    local items = {}
    for _, n in ipairs(party.names) do items[#items + 1] = n end
    items[#items + 1] = party.designation
    for _, x in ipairs(lines(items)) do left[#left + 1] = x end
  end
  local right = { p(xe.runs("Case No. " .. str(meta.case_number))) }
  right[#right + 1] = p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE })
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = SINGLE })
  end
  return tbl({ CAP_LEFT, CAP_GUTTER, CAP_RIGHT }, {
    cell(CAP_LEFT, "<w:tcBorders>" .. string.format(RULE, "bottom") .. string.format(RULE, "right")
      .. '</w:tcBorders><w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/><w:bottom w:w="' .. (CAP_PAD - CAP_RULE)
      .. '" w:type="dxa"/></w:tcMar>', left),
    cell(CAP_GUTTER, "", { p("") }),
    cell(CAP_RIGHT, '<w:tcMar><w:left w:w="' .. CASE_PAD .. '" w:type="dxa"/></w:tcMar>', right),
  })
end

-- The signature block: "Dated:" at left; "Respectfully submitted,", the firm, "By: /s/" and the signer, then the
-- lines at right. One row that does not split, a blank double-spaced line above it.
local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,")) }
  for _, x in ipairs(lines(sig.firm or {}, SIG_GAP)) do right[#right + 1] = x end
  local signer = { "By: /s/ " .. str(sig.signer) }
  for _, l in ipairs(sig.lines or {}) do signer[#signer + 1] = l end
  for _, x in ipairs(lines(signer, SIG_GAP)) do right[#right + 1] = x end
  local left = { p(meta.date and (xe.runs("Dated: ") .. xe.inl(meta.date)) or "") }
  return tbl({ SIG_LEFT, 9360 - SIG_LEFT }, { cell(SIG_LEFT, "", left), cell(9360 - SIG_LEFT, "", right) })
end

-- The inlines of a block's first paragraph (a list item or a Para/Plain).
local function inlines_of(blocks)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then return b.content end
  end
  return pandoc.Inlines({})
end

local function letter(n)
  return "(" .. string.char(96 + n) .. ")"
end

-- The body, block by block. `last`: the block that stays on the page of the signature (typst: sticky).
local function body(blocks)
  local out = {}
  local n = 0
  for i, b in ipairs(blocks) do
    local keep = i == #blocks
    if b.t == "Header" then
      local content = b.content
      if b.level == 1 then
        content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
      end
      out[#out + 1] = xe.para({ xe.style("Heading" .. math.min(b.level, 3)) }, xe.inl(content))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local k = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        local label = b.t == "OrderedList" and letter(k) or "\u{2022}"
        out[#out + 1] = p(xe.runs(label .. "\t") .. xe.inl(inlines_of(item)),
          { style = "ListItemLettered", line = BODY, left = 1440, hanging = 720, keep = keep and j == #b.content })
        k = k + 1
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      local first = c[1]
      if first and first.t == "Str" and first.text == "~" then
        -- unnumbered: the marker and the space after it are removed
        local rest = pandoc.Inlines({})
        for j = 3, #c do rest:insert(c[j]) end
        out[#out + 1] = p(xe.inl(rest), { style = "BodyText", line = BODY, first = 720, keep = keep })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(c),
          { style = "NumberedParagraph", line = BODY, first = 720, keep = keep })
      end
    else
      error("complaint.lua: unsupported block " .. b.t .. " (see ../README.md, Markdown contract)")
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("1681i(a)(2)(A)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function finish(doc)
  local m = doc.meta
  local xml = {}
  local function add(list) for _, x in ipairs(list) do xml[#xml + 1] = x end end
  add(court_title(m))
  -- the caption with a blank double-spaced line before and after it (an empty 24 pt line each side)
  xml[#xml + 1] = p("", { line = BODY })
  xml[#xml + 1] = caption(m)
  xml[#xml + 1] = p("", { line = BODY })
  if m.lead_in then
    local lead = pandoc.read(str(m.lead_in), "markdown+smart").blocks:walk({ Str = break_rules })
    xml[#xml + 1] = p(xe.inl(inlines_of(lead)), { style = "BodyText", line = BODY, first = 720 })
  end
  add(body(doc.blocks))
  xml[#xml + 1] = p("", { line = BODY, keep = true })
  xml[#xml + 1] = signature(m)
  local blocks = {}
  for _, x in ipairs(xml) do blocks[#blocks + 1] = xe.raw(x) end
  m.title, m.author, m.date = nil, nil, nil
  return pandoc.Pandoc(blocks, m)
end

return { { Str = break_rules }, { Pandoc = finish } }
