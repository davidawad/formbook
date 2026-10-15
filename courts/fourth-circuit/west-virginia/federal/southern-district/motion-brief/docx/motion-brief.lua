-- wvsd memorandum of law (motion brief), DOCX engine (docs/DOCX.md). Mirrors typst/wvsd-motion-brief.typ on
-- reference.docx: a cover (own section, empty footer) with the caption, the title and the counsel block at
-- 3.25 in; then the body (own section, arabic from 1): headings numbered by the template (level 1 unnumbered),
-- the markdown body, the "Dated" line and the signature block at 3.25 in.
-- Every case-specific word comes from the sample's frontmatter.

local TEXT_W = 9360
local PARTY_W = 4320         -- 3.0 in, caption party column (as in the typst template)
local PAREN_W = 432          -- 0.3 in, column of ")" marks
local RIGHT_W = TEXT_W - PARTY_W - PAREN_W
local BLOCK_IND = 4680       -- 3.25 in, counsel and signature block
local COURT = "IN THE UNITED STATES DISTRICT COURT"

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- text with *italic* segments -> w:r runs
local function runs(s, rpr)
  s = s:gsub("\\(.)", "%1")
  local parts = {}
  for p in (s .. "*"):gmatch("(.-)%*") do parts[#parts + 1] = p end
  local out = {}
  for k, p in ipairs(parts) do
    if p ~= "" then
      local r = rpr or ""
      if k % 2 == 0 then r = r .. "<w:i/>" end
      out[#out + 1] = '<w:r>' .. (r ~= "" and ('<w:rPr>' .. r .. '</w:rPr>') or '')
        .. '<w:t xml:space="preserve">' .. xesc(p) .. '</w:t></w:r>'
    end
  end
  return table.concat(out)
end

local function para(style, content, extra)
  return '<w:p><w:pPr>' .. (style and ('<w:pStyle w:val="' .. style .. '"/>') or '') .. (extra or '')
    .. '</w:pPr>' .. (content or '') .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- metadata value -> text with *italic* segments kept ("" when empty); no line wrapping
local function mdstr(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  local out = {}
  local function walk_inl(list)
    for _, i in ipairs(list) do
      if i.t == "Emph" then
        out[#out + 1] = "*"; walk_inl(i.content); out[#out + 1] = "*"
      elseif i.t == "Str" then out[#out + 1] = i.text
      elseif i.t == "Space" or i.t == "SoftBreak" or i.t == "LineBreak" then out[#out + 1] = " "
      elseif i.t == "Strong" or i.t == "Span" then walk_inl(i.content)
      else out[#out + 1] = pandoc.utils.stringify(pandoc.Inlines({ i })) end
    end
  end
  if v.t == "MetaBlocks" or (v.t == nil and v[1] and (v[1].t == "Para" or v[1].t == "Plain")) then
    for _, b in ipairs(v) do if b.content then walk_inl(b.content) end end
  else
    walk_inl(v)
  end
  return (table.concat(out):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function plain(v) return (mdstr(v):gsub("%*", "")) end

local function as_bool(v) return v ~= nil and (v == true or plain(v) == "true") end

local function section_end(footer)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:rPr><w:sz w:val="2"/></w:rPr><w:sectPr><w:footerReference w:type="default" r:id="' .. footer
    .. '"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:pPr></w:p>'
end

local function letter_roman(n)
  local r = { "i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x", "xi", "xii" }
  return r[n] or tostring(n)
end

-- heading numbers: level 2 I., level 3 A., level 4 1., level 5 a.; level 1 is unnumbered
local function heading_label(level, c)
  if level == 2 then
    local r = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII" }
    return (r[c[2]] or tostring(c[2])) .. "."
  elseif level == 3 then return string.char(string.byte("A") + ((c[3] - 1) % 26)) .. "."
  elseif level == 4 then return tostring(c[4]) .. "."
  elseif level == 5 then return string.char(string.byte("a") + ((c[5] - 1) % 26)) .. "."
  end
  return nil
end

local function caption_xml(meta)
  local rows = {}
  local sides = meta.caption or {}
  for k, side in ipairs(sides) do
    local lead
    if side.lead ~= nil then lead = mdstr(side.lead)
    elseif k == 1 then lead = "" else lead = "v." end
    if lead ~= "" then rows[#rows + 1] = { text = lead, ind = 720 } end
    for _, n in ipairs(side.names or {}) do rows[#rows + 1] = { text = mdstr(n), ind = 0 } end
    rows[#rows + 1] = { text = mdstr(side.designation), ind = 1440 }
    if k < #sides then rows[#rows + 1] = { kind = "blank" } end
  end
  local out = {}
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. PARTY_W .. '"/><w:gridCol w:w="' .. PAREN_W .. '"/><w:gridCol w:w="' .. RIGHT_W .. '"/></w:tblGrid>'
  for i, r in ipairs(rows) do
    local left, paren
    if r.kind == "blank" then
      left = para("Single", "", '<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>')
      paren = para("Single", runs(")"), '<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>')
    else
      left = para("CaptionText", runs(r.text), r.ind > 0 and ('<w:ind w:left="' .. r.ind .. '" w:firstLine="0"/>') or nil)
      paren = para("CaptionText", runs(")"))
    end
    local right
    if i == 1 then
      local body = ""
      if meta.civil_action then body = body .. para("CaptionText", runs(mdstr(meta.civil_action)), '<w:ind w:left="288" w:firstLine="0"/>') end
      if meta.judge then body = body .. para("CaptionText", runs(mdstr(meta.judge)), '<w:ind w:left="288" w:firstLine="0"/>') end
      if body == "" then body = para("CaptionText", "") end
      right = '<w:tc><w:tcPr><w:tcW w:w="' .. RIGHT_W .. '" w:type="dxa"/><w:vMerge w:val="restart"/><w:vAlign w:val="center"/></w:tcPr>' .. body .. '</w:tc>'
    else
      right = '<w:tc><w:tcPr><w:tcW w:w="' .. RIGHT_W .. '" w:type="dxa"/><w:vMerge/></w:tcPr>' .. para("CaptionText", "") .. '</w:tc>'
    end
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. PARTY_W .. '" w:type="dxa"/></w:tcPr>' .. left .. '</w:tc>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. PAREN_W .. '" w:type="dxa"/></w:tcPr>' .. paren .. '</w:tc>'
      .. right .. '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return table.concat(out)
end

-- counsel block at 3.25 in: groups of names and lines, a blank line after each group
local function counsel_xml(meta)
  local out = {}
  for _, g in ipairs(meta.counsel or {}) do
    for _, n in ipairs(g.names or {}) do out[#out + 1] = para("Signature", runs(mdstr(n))) end
    for _, l in ipairs(g.lines or {}) do out[#out + 1] = para("Signature", runs(mdstr(l))) end
    out[#out + 1] = para("Signature", "", '<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>')
  end
  return table.concat(out)
end

-- "Dated" line at the left, then the signature lines at 3.25 in, kept together
local function signature_xml(meta)
  local out = {}
  out[#out + 1] = para("Single", runs("Dated: " .. mdstr(meta.date)), '<w:keepNext/><w:spacing w:before="480" w:after="0" w:line="276" w:lineRule="exact"/>')
  out[#out + 1] = para(nil, "", '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>')
  for _, l in ipairs(meta.signature or {}) do
    local s = mdstr(l)
    if s == "" then
      out[#out + 1] = para("Signature", "", '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>')
    else
      out[#out + 1] = para("Signature", runs(s), '<w:keepNext/>')
    end
  end
  return table.concat(out)
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  local function add(b) blocks[#blocks + 1] = b end

  -- body: heading numbers (level 2 and deeper); lists are not paragraphs of the text (Compact style)
  local counters = { 0, 0, 0, 0, 0, 0 }
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local lvl = b.level
      if lvl >= 2 then
        counters[lvl] = counters[lvl] + 1
        for i = lvl + 1, 6 do counters[i] = 0 end
        local label = heading_label(lvl, counters)
        local content = pandoc.List({
          pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. xesc(label) .. '</w:t></w:r>'),
          pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>'),
        })
        content:extend(b.content)
        body[#body + 1] = pandoc.Header(lvl, content, b.attr)
      else
        -- level 1 is unnumbered but starts a new run of the deeper numbers (as the typst heading counter does)
        for i = 2, 6 do counters[i] = 0 end
        body[#body + 1] = b
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      body[#body + 1] = b:walk({ Para = function(p) return pandoc.Plain(p.content) end })
    else
      body[#body + 1] = b
    end
  end

  -- cover (section 1, no page number)
  add(raw(para("Centered", runs(COURT, "<w:b/>"), '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>')))
  add(raw(para("Centered", runs("FOR THE SOUTHERN DISTRICT OF WEST VIRGINIA", "<w:b/>"))))
  add(raw(para("Centered", runs(string.upper(plain(meta.division or "")), "<w:b/>"))))
  add(raw(para(nil, "", '<w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/>')))
  add(raw(caption_xml(meta)))
  add(raw(para("Centered", runs(mdstr(meta.brief_title), "<w:b/>"), '<w:spacing w:before="360" w:after="0" w:line="276" w:lineRule="exact"/>')))
  add(raw(para(nil, "", '<w:spacing w:before="0" w:after="0" w:line="540" w:lineRule="exact"/>')))
  add(raw(counsel_xml(meta)))
  add(raw(section_end("rId101")))

  -- body (section 2, arabic from 1)
  for _, b in ipairs(body) do add(b) end
  add(raw(signature_xml(meta)))

  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
