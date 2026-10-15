-- Complaint, U.S. District Court for the District of Arizona (azd), DOCX engine (docs/DOCX.md).
-- Mirrors typst/azd-complaint.typ on docx/reference.docx: counsel from line 1 (LRCiv 7.1(a)(1)); court title on or
-- below line 6 (7.1(a)(2)); caption with the case number, title and jury demand right of center (7.1(a)(3)); body
-- double spaced at exact 24 pt, numbered allegations (Fed. R. Civ. P. 10(b)); relief items lettered A., B., ...
-- The page furniture (28 pleading numbers, rules, page number) lives in build-reference.sh.
-- Everything case-specific comes from the sample's frontmatter, never from this file.

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
-- the case number, the title and the jury demand on the right. The row is at least whole numbered lines tall
-- (typst: on-grid), from an estimate of the wrapped lines.
local function caption(meta)
  local left = ""
  local left_lines = 0
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left = left .. para("Single", "v.", '<w:spacing w:before="0" w:after="0" w:line="' .. SINGLE .. '" w:lineRule="exact"/>')
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
  local right_lines = 2 + lines_for(title, 32)
  local right_pt = right_lines * 15 + 6
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

local function upper_str(blocks)
  return pandoc.walk_block(pandoc.Plain(blocks), {
    Str = function(s) s.text = s.text:upper(); return s end,
  }).content
end

-- a numbered allegation: "n." then a tab, the paragraph in the Allegation style
local function allegation(n, content)
  local inl = pandoc.List({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" }))
end

local function relief_item(label, blocks)
  local inl = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
  local first = blocks[1]
  local rest = {}
  if first and (first.t == "Para" or first.t == "Plain") then
    inl:extend(first.content)
    for i = 2, #blocks do rest[#rest + 1] = blocks[i] end
  else
    rest = blocks
  end
  local out = { pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Relief" })) }
  for _, b in ipairs(rest) do out[#out + 1] = b end
  return out
end

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

  -- body: headings unnumbered (level 1 centred caps, level 2 centred bold, level 3 bold italic);
  -- paragraphs numbered 1, 2, ...; lists lettered A., B., ...
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local content = b.content
      if b.level == 1 then
        add(pandoc.Div({ pandoc.Para(upper_str(content)) }, pandoc.Attr("", {}, { ["custom-style"] = "CHeadingOne" })))
      elseif b.level == 2 then
        add(pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "CHeadingTwo" })))
      else
        add(pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "CHeadingThree" })))
      end
    elseif b.t == "Para" then
      n = n + 1
      add(allegation(n, b.content))
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        for _, x in ipairs(relief_item(string.char(64 + i) .. ".", item)) do add(x) end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, x in ipairs(relief_item("\u{2022}", item)) do add(x) end
      end
    else
      add(b)
    end
  end

  -- signature block (LRCiv 7.1 App. C shape): "DATED this ... day of ..." on a numbered line, then the firm and the
  -- signer under "By: /s/", all single spaced and padded to whole numbered lines
  add(raw(para("Single", "DATED this " .. plain(meta.date) .. ".", sp(0, PITCH, PITCH, "exact"))))
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

  -- certificate of service (optional, unnumbered)
  if meta.certificate then
    add(raw(para("CHeadingOne", plain(meta.certificate.heading), sp(0, 0, PITCH, "exact"), true)))
    add(div("Allegation", md_inlines(meta.certificate.text)))
    add(raw(para("Single", "/s/ " .. plain(meta.certificate.signer), '<w:ind w:left="' .. CERT_IND .. '"/>' .. sp(0, 0, PITCH, "exact"))))
  end

  doc.meta.date = nil
  doc.blocks = out
  return doc
end
