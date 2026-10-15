-- Motion with memorandum, U.S. District Court for the District of Arizona (azd), DOCX engine (docs/DOCX.md).
-- Mirrors typst/azd-motion.typ on docx/reference.docx: counsel from line 1 (LRCiv 7.1(a)(1)); court title on or
-- below line 6 (7.1(a)(2)); caption with the case number, title and judge right of center (7.1(a)(3)); body double
-- spaced at exact 24 pt (7.1(b)(1)); headings numbered by this filter (I., A., 1., a.) and hung from the margin;
-- body paragraphs unnumbered with a first-line indent. The running header (pages 2 on) and the page furniture are
-- written by docx/render.sh and docx/build-reference.sh. Everything case-specific comes from the frontmatter.

local SINGLE = 300   -- exact single line (15 pt): counsel, caption, signature, certificate
local PITCH = 480    -- exact double line (24 pt): the numbered-line pitch
local TEXT_W = 8999  -- text width in twips (8.5 in - 1.5 in - 0.75 in)
local PARTY_W = 4608 -- party column of the caption: 3.2 in
local GUTTER = 288
local RIGHT_W = TEXT_W - PARTY_W - GUTTER
local SIG_IND = 4104 -- signature block starts 2.85 in from the left margin (typst: 3.4 in box, right aligned)
local CERT_IND = 3816

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- one paragraph: style, direct pPr (in schema order after pStyle), text, bold
local function para(style, text, ppr, bold)
  local body = (text ~= nil and text ~= "") and run(text, bold) or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. body .. '</w:p>'
end

local function sp(before, after, line, rule)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. line .. '" w:lineRule="' .. rule .. '"/>'
end

local function borderless_table(width_cols, rows)
  local grid = {}
  for _, w in ipairs(width_cols) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. rows .. '</w:tbl>'
end

-- estimated line count of a caption entry: EB Garamond 13 pt in the 3.2 in party column is about 36 characters
local function lines_for(s, per_line)
  return math.max(1, math.ceil(utf8.len(s) / per_line))
end

-- the caption (LRCiv 7.1(a)(3)): party names, designations and "v." on the left, ruled below and to the right;
-- the case number, the title and the judge on the right. The row is at least whole numbered lines tall
-- (typst: on-grid), from an estimate of the wrapped lines.
local function caption(meta)
  local left = ""
  local left_lines = 0
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left = left .. para("Single", "v.")
      left_lines = left_lines + 1
    end
    for _, n in ipairs(p.names or {}) do
      left = left .. para("Single", plain(n))
      left_lines = left_lines + lines_for(plain(n), 36)
    end
    left = left .. para("Single", plain(p.designation))
    left_lines = left_lines + lines_for(plain(p.designation), 36)
  end
  local left_pt = left_lines * 15 + 8
  local title = plain(meta.brief_title)
  local right = para("Single", "Case No. " .. plain(meta.case_number), '<w:ind w:left="144"/>')
    .. para("Single", "", sp(0, 0, 240, "exact"))
    .. para("Single", title, '<w:ind w:left="144"/>', true)
    .. para("Single", "", sp(0, 0, 240, "exact"))
    .. para("Single", plain(meta.judge), '<w:ind w:left="144"/>')
  local right_lines = 2 + lines_for(title, 32) + 1
  local right_pt = right_lines * 15 + 12
  local h = math.max(left_pt, right_pt)
  local row_h = math.max(2, math.ceil(h / 24)) * 24 * 20
  local left_cell = '<w:tc><w:tcPr><w:tcW w:w="' .. PARTY_W .. '" w:type="dxa"/>'
    .. '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders></w:tcPr>'
    .. left .. '</w:tc>'
  local gap_cell = '<w:tc><w:tcPr><w:tcW w:w="' .. GUTTER .. '" w:type="dxa"/></w:tcPr>' .. para("Single", "") .. '</w:tc>'
  local right_cell = '<w:tc><w:tcPr><w:tcW w:w="' .. RIGHT_W .. '" w:type="dxa"/></w:tcPr>' .. right .. '</w:tc>'
  local row = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. row_h .. '" w:hRule="atLeast"/></w:trPr>'
    .. left_cell .. gap_cell .. right_cell .. '</w:tr>'
  return raw(borderless_table({ PARTY_W, GUTTER, RIGHT_W }, row))
end

local function md_inlines(v)
  local s = plain(v)
  if s == "" then return pandoc.List({}) end
  local doc = pandoc.read(s, "markdown")
  return doc.blocks[1] and doc.blocks[1].content or pandoc.List({})
end

local function div(style, content)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function upper_inlines(content)
  return pandoc.walk_block(pandoc.Plain(content), {
    Str = function(s) s.text = s.text:upper(); return s end,
  }).content
end

-- heading labels, as typst numbers them: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 is unnumbered
local counters = { 0, 0, 0, 0, 0 }
local function roman(n)
  local vals = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" }, { 50, "L" },
    { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end
local function heading_label(level)
  counters[level] = counters[level] + 1
  for k = level + 1, 5 do counters[k] = 0 end
  if level == 2 then return roman(counters[2]) .. "." end
  if level == 3 then return string.char(64 + counters[3]) .. "." end
  if level == 4 then return tostring(counters[4]) .. "." end
  return string.char(96 + counters[5]) .. "."
end

local HEADING_STYLE = { [2] = "MHeadingTwo", [3] = "MHeadingThree", [4] = "MHeadingFour", [5] = "MHeadingFive" }

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- counsel block (LRCiv 7.1(a)(1)): from line 1, single spaced; at least five lines, then whole numbered lines
  local counsel = meta.counsel or {}
  local total = #counsel * SINGLE
  local target = math.max(5 * PITCH, math.ceil(total / PITCH) * PITCH)
  for i, l in ipairs(counsel) do
    local after = (i == #counsel) and (target - total) or 0
    add(raw(para("Single", plain(l), sp(0, after, SINGLE, "exact"))))
  end

  -- court title (LRCiv 7.1(a)(2)): on or below line 6
  add(raw(para("Centered", "IN THE UNITED STATES DISTRICT COURT", sp(0, 0, PITCH, "exact"), true)))
  add(raw(para("Centered", "FOR THE DISTRICT OF ARIZONA", sp(0, PITCH, PITCH, "exact"), true)))

  add(caption(meta))
  add(raw(para("Single", "", sp(0, PITCH, PITCH, "exact"))))

  if meta.lead_in then add(div("LeadIn", md_inlines(meta.lead_in))) end

  -- body: headings (level 1 centred caps, unnumbered; levels 2 to 5 labelled and hung); paragraphs unnumbered
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        counters = { 0, 0, 0, 0, 0 }
        add(pandoc.Div({ pandoc.Para(upper_inlines(b.content)) }, pandoc.Attr("", {}, { ["custom-style"] = "CHeadingOne" })))
      else
        local inl = pandoc.List({ pandoc.Str(heading_label(b.level)), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
        inl:extend(b.content)
        add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = HEADING_STYLE[b.level] or "MHeadingFive" })))
      end
    elseif b.t == "Para" then
      add(div("BodyPara", b.content))
    else
      add(b)
    end
  end

  -- LRCiv 12.1(c) certification (optional; author content)
  if meta.certification then
    add(raw(para("Centered", plain(meta.certification.heading), sp(0, 0, PITCH, "exact"), true)))
    add(div("BodyPara", md_inlines(meta.certification.text)))
  end

  -- signature block: "DATED: ..." on a numbered line, then the firm and the signer under "By: /s/", single spaced
  add(raw(para("Single", "DATED: " .. plain(meta.date), sp(0, PITCH, PITCH, "exact"))))
  local sig = {}
  for _, l in ipairs(meta.signature.firm or {}) do sig[#sig + 1] = plain(l) end
  sig[#sig + 1] = ""
  sig[#sig + 1] = "By: /s/ " .. plain(meta.signature.signer)
  for _, l in ipairs(meta.signature.lines or {}) do sig[#sig + 1] = plain(l) end
  local sig_total = #sig * SINGLE
  local sig_target = math.ceil(sig_total / PITCH) * PITCH
  for i, l in ipairs(sig) do
    local after = (i == #sig) and (sig_target - sig_total) or 0
    add(raw(para("Single", l, '<w:ind w:left="' .. SIG_IND .. '"/>' .. sp(0, after, SINGLE, "exact"))))
  end

  -- certificate of service (optional, unnumbered): the heading, the text, the service list, the signer
  if meta.certificate then
    add(raw(para("Centered", plain(meta.certificate.heading), sp(0, 0, PITCH, "exact"), true)))
    add(div("BodyPara", md_inlines(meta.certificate.text)))
    local svc = meta.certificate.service or {}
    for i, l in ipairs(svc) do
      add(raw(para("Single", plain(l), sp(0, (i == #svc) and 0 or 120, SINGLE, "exact"))))
    end
    add(raw(para("Single", "/s/ " .. plain(meta.certificate.signer), '<w:ind w:left="' .. CERT_IND .. '"/>' .. sp(0, 0, PITCH, "exact"))))
  end

  doc.meta.date = nil
  doc.blocks = out
  return doc
end
