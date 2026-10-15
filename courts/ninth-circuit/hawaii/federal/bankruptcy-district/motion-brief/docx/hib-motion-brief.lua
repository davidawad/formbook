-- Cover, caption, heading labels and signature of the D. Haw. motion, for the docx engine. Mirrors
-- cover(), caption-table(), the heading show rule and signature-block() in typst/hib-motion-brief.typ.
-- The body is pandoc's. The styles used here (CounselBlock, CourtTitle, CaptionText, SignatureBlock)
-- are defined by docx/make-reference.sh. Metadata comes from the YAML frontmatter of the sample
-- (schema: ../README.md). Nothing is case-specific. Not done here: the table of contents and the
-- table of authorities (typst generates them from the headings and an authorities list); see README.

local function str(x)
  return pandoc.utils.stringify(x)
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- A paragraph in a custom style, from inlines.
local function para(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function text(s)
  return { pandoc.Str(s) }
end

-- Raw OOXML helpers for the caption and signature tables (a pandoc table cannot set per-cell
-- borders reliably in docx). Each paragraph is in one of the custom styles above.
local function xp(style, s, opts)
  opts = opts or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>' .. (opts.ind or "") .. (opts.jc or "")
  local rpr = opts.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local run = s == "" and "" or ('<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>')
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. run .. '</w:p>'
end

local function cell(paras, width, borders, mar)
  local tcpr = '<w:tcW w:w="' .. width .. '" w:type="dxa"/>'
  if borders ~= "" then tcpr = tcpr .. '<w:tcBorders>' .. borders .. '</w:tcBorders>' end
  if mar then tcpr = tcpr .. mar end
  return '<w:tc><w:tcPr>' .. tcpr .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local NONE_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NONE_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
end

local function row(cells)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

local RULE = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
local RIGHT = string.format(RULE, "right")
local RIGHT_BOTTOM = string.format(RULE, "bottom") .. RIGHT

-- Caption (FRBP 7010; FRCP 10(a)). Left column: bankruptcy lines, then each party with its
-- designation; the rule closes the party column. Right column: adversary number and paper title.
local function caption_xml(m)
  local sides = m.caption or {}
  local bk = m.bankruptcy or {}
  local left1, right1 = {}, {}
  for _, l in ipairs(bk) do left1[#left1 + 1] = xp("CaptionText", str(l)) end
  if #bk > 0 then left1[#left1 + 1] = xp("CaptionText", "") end
  local function party(side)
    local out = {}
    for _, n in ipairs(side.names or {}) do out[#out + 1] = xp("CaptionText", str(n)) end
    out[#out + 1] = xp("CaptionText", str(side.designation or ""), { ind = '<w:ind w:left="2592" w:right="288"/>' })
    return out
  end
  if sides[1] then
    for _, p in ipairs(party(sides[1])) do left1[#left1 + 1] = p end
  end
  right1[#right1 + 1] = xp("CaptionText", str(m.adversary_number or ""), { ind = '<w:ind w:left="288"/>' })
  right1[#right1 + 1] = xp("CaptionText", "", { ind = '<w:ind w:left="288"/>' })
  right1[#right1 + 1] = xp("CaptionText", str(m.brief_title or ""):upper(), { ind = '<w:ind w:left="288"/>', bold = true })

  -- Noticed hearing date, time, place and judge, opposite the remaining parties (LBR 9013-1(c)(1)).
  local right2 = {}
  local h = m.hearing or {}
  for _, k in ipairs({ { "date", "Date:" }, { "time", "Time:" }, { "place", "Place:" }, { "judge", "Judge:" } }) do
    if h[k[1]] then right2[#right2 + 1] = xp("CaptionText", k[2] .. " " .. str(h[k[1]]), { ind = '<w:ind w:left="288"/>' }) end
  end
  if #right2 == 0 then right2[1] = xp("CaptionText", "") end

  local rows = {}
  local mar_l = '<w:tcMar><w:right w:w="288" w:type="dxa"/></w:tcMar>'
  local mar_r = '<w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>'
  if #sides <= 1 then
    rows[1] = row({ cell(left1, 4680, RIGHT_BOTTOM, mar_l), cell(right1, 4680, "", mar_r) })
  else
    rows[1] = row({ cell(left1, 4680, RIGHT, mar_l), cell(right1, 4680, "", mar_r) })
    for i = 2, #sides do
      local left = {}
      left[#left + 1] = xp("CaptionText", "v.", { jc = '<w:jc w:val="center"/>' })
      left[#left + 1] = xp("CaptionText", "")
      for _, p in ipairs(party(sides[i])) do left[#left + 1] = p end
      local borders = (i == #sides) and RIGHT_BOTTOM or RIGHT
      local rc = (i == 2) and right2 or { xp("CaptionText", "") }
      rows[#rows + 1] = row({ cell(left, 4680, borders, mar_l), cell(rc, 4680, "", mar_r) })
    end
  end
  return table_xml({ 4680, 4680 }, rows)
end

-- Signature block: "DATED:" on the left, the signatures on the right (3.2 in column).
local function signature_xml(m)
  local left = { xp("SignatureBlock", "DATED: " .. str(m.date or "")) }
  local right = {}
  for i, b in ipairs(m.signature or {}) do
    if i > 1 then right[#right + 1] = xp("SignatureBlock", "") end
    for _, l in ipairs(b) do right[#right + 1] = xp("SignatureBlock", str(l)) end
  end
  return table_xml({ 3240, 4608 }, { row({ cell(left, 3240, "", ""), cell(right, 4608, "", "") }) })
end

-- Heading labels as in the typst heading show rule: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 is
-- unnumbered. The label is followed by a tab (the hanging indent is set in the heading styles).
local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
    { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

local counters = { 0, 0, 0, 0, 0, 0 }

function Header(h)
  if h.level < 2 or h.level > 5 then return nil end
  counters[h.level] = counters[h.level] + 1
  for l = h.level + 1, 5 do counters[l] = 0 end
  local k = counters[h.level]
  local lab
  if h.level == 2 then lab = roman(k) .. "."
  elseif h.level == 3 then lab = string.char(64 + k) .. "."
  elseif h.level == 4 then lab = tostring(k) .. "."
  else lab = string.char(96 + k) .. "." end
  table.insert(h.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
  table.insert(h.content, 1, pandoc.Str(lab))
  return h
end

function Pandoc(doc)
  local m = doc.meta
  local out = pandoc.List()

  -- Counsel block, upper left, single-spaced (LBR 9004-1(b)(2): counsel identification is exempt).
  for _, l in ipairs(m.counsel or {}) do
    out:insert(para("CounselBlock", text(str(l))))
  end
  if m.counsel_role then
    out:insert(para("CounselBlock", { pandoc.Emph(text(str(m.counsel_role))) }))
  end
  out:insert(para("CounselBlock", {}))

  -- Court name, centered and bold.
  for _, l in ipairs(m.court or {}) do
    out:insert(para("CourtTitle", text(str(l):upper())))
  end
  out:insert(para("CounselBlock", {}))

  out:insert(pandoc.RawBlock("openxml", caption_xml(m)))
  out:insert(para("CounselBlock", {}))

  for _, b in ipairs(doc.blocks) do out:insert(b) end

  out:insert(pandoc.RawBlock("openxml", signature_xml(m)))
  doc.blocks = out
  return doc
end
