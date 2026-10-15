-- lawd-motion-brief.lua (docx engine): the W.D. La. memorandum form that markdown alone does not give Word
-- (see ../README.md, "Engines"; docs/DOCX.md).
--   * the caption, title and subtitle as single-spaced paragraphs and borderless tables, as the typst template
--     lays them out;
--   * the front matter (everything before the first level 1 heading) in its own section with lowerRoman page
--     numbers; the body in the next section, arabic from 1 (render.sh writes the front section's sectPr);
--   * the table of contents as a TOC field over the heading styles (Word updates it on open: see the README);
--   * the table of authorities as typed entries with dot leaders, page references from the sample's frontmatter;
--   * lettered and numbered lists as "(1)" items (typst: enum "(1)"); body paragraphs indented, not numbered;
--   * the signature block and the certificate of service (LR 11.1, Fed. R. Civ. P. 5).
-- Every word comes from the sample's frontmatter and body; nothing case-specific is in this file.

local TEXT_TWIPS = 9360 -- 6.5 in
local CAPTION_LEFT = 4752 -- 3.3 in, the party column
local CAPTION_STAR = 432 -- 0.3 in, the asterisk column
local CAPTION_RIGHT = TEXT_TWIPS - CAPTION_LEFT - CAPTION_STAR
local CAPTION_LEFT_PT = 237.6
local DESIGNATION_INDENT = 2160 -- 1.5 in
local BLANK_LINE = '<w:p><w:pPr><w:pStyle w:val="Normal" /></w:pPr></w:p>' -- one double-spaced line (v(pitch))
local FRONT_FOOTER = "rIdFooterRoman" -- the footer part render.sh adds for the front matter (lowerRoman numbers)

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- Runs for text with *italic* segments (the odd split pieces are plain, the even ones italic).
local function runs(text, rpr)
  local parts = {}
  for seg in (text .. "*"):gmatch("(.-)%*") do parts[#parts + 1] = seg end
  local out = {}
  for i, seg in ipairs(parts) do
    if seg ~= "" then
      local props = (rpr or "") .. ((i % 2 == 0) and "<w:i />" or "")
      local rpr_xml = props ~= "" and ("<w:rPr>" .. props .. "</w:rPr>") or ""
      out[#out + 1] = '<w:r>' .. rpr_xml .. '<w:t xml:space="preserve">' .. esc(seg) .. '</w:t></w:r>'
    end
  end
  return table.concat(out)
end

local function para(style, body, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '" />' .. (ppr or "") .. '</w:pPr>' .. body .. '</w:p>'
end

local function table_xml(widths, cells)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '" />'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa" /></w:tcPr>' .. cells[i] .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa" />'
    .. '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" />'
    .. '<w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" /></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- Width of one character in ems, for estimating how many lines a caption entry wraps to (checked against the PDF
-- when one can be made; see the README).
local function char_em(c)
  if c == " " then return 0.22 end
  if c:match("%u") then return 0.58 end
  if c:match("%d") then return 0.5 end
  if c:match("%l") then return 0.42 end
  return 0.35
end

-- Greedy word wrap at 12 pt: the number of lines the text takes in a column `width_pt` wide.
local function est_lines(text, width_pt)
  local lines, cur = 1, 0
  local space = 0.22 * 12
  for word in text:gsub("%*", ""):gmatch("%S+") do
    local w = 0
    for c in word:gmatch(utf8.charpattern) do w = w + char_em(c) * 12 end
    if cur == 0 then
      cur = w
    elseif cur + space + w > width_pt then
      lines = lines + 1
      cur = w
    else
      cur = cur + space + w
    end
  end
  return lines
end

local function str(x)
  return pandoc.utils.stringify(x)
end

-- Inlines as markdown, so *italic* survives (case names in the table of authorities).
local function md_inlines(x)
  return (pandoc.write(pandoc.Pandoc({ pandoc.Plain(x) }), "markdown"):gsub("\n+$", ""))
end

local function caption_xml(meta)
  local cap = meta.caption
  local sep = cap.separator and str(cap.separator) or "v."
  local left, nlines = {}, 0
  for i, p in ipairs(cap.parties) do
    if i > 1 then
      left[#left + 1] = para("SingleSpaced", runs(sep))
      left[#left + 1] = para("SingleSpaced", "")
      nlines = nlines + 2
    end
    for _, name in ipairs(p.names) do
      local t = str(name)
      left[#left + 1] = para("SingleSpaced", runs(t))
      nlines = nlines + est_lines(t, CAPTION_LEFT_PT)
    end
    local d = str(p.designation)
    left[#left + 1] = para("SingleSpaced", runs(d), '<w:ind w:left="' .. DESIGNATION_INDENT .. '" w:firstLine="0" />')
    nlines = nlines + est_lines(d, CAPTION_LEFT_PT - 108)
  end
  local stars = {}
  for i = 1, nlines do
    stars[i] = para("SingleCentered", '<w:r><w:t>*</w:t></w:r>')
  end

  local blank = '<w:r><w:rPr><w:u w:val="single" /></w:rPr><w:t xml:space="preserve">' .. string.rep("\u{a0}", 40) .. '</w:t></w:r>'
  local function entry(v)
    if v == nil then return blank end
    return runs(str(v))
  end
  local right = {}
  right[#right + 1] = para("SingleSpaced", runs("CIVIL ACTION NO. ") .. entry(meta.case_number))
  right[#right + 1] = para("SingleSpaced", runs("JUDGE ") .. entry(meta.judge))
  right[#right + 1] = para("SingleSpaced", runs("MAGISTRATE JUDGE ") .. entry(meta.magistrate))
  if meta.legend then
    right[#right + 1] = para("SingleSpaced", "")
    right[#right + 1] = para("SingleSpaced", runs(str(meta.legend)))
  end

  return table_xml({ CAPTION_LEFT, CAPTION_STAR, CAPTION_RIGHT }, {
    table.concat(left),
    table.concat(stars),
    table.concat(right),
  })
end

-- The signature block: the date (if the sample gives one) at the left; "Respectfully submitted," and the
-- sample's lines at the right (LR 11.1).
local function signature_xml(sig)
  local left = para("SingleSpaced", sig.date and runs("Dated: " .. str(sig.date)) or "")
  local right = { para("SingleSpaced", runs("Respectfully submitted,")), para("SingleSpaced", "") }
  for _, l in ipairs(sig.lines) do
    local t = str(l)
    right[#right + 1] = para("SingleSpaced", t == "" and "" or runs(t))
  end
  return table_xml({ 4680, 4680 }, { left, table.concat(right) })
end

local function front_xml(meta)
  local court = {
    para("SingleCentered", runs("UNITED STATES DISTRICT COURT")),
    para("SingleCentered", runs("WESTERN DISTRICT OF LOUISIANA")),
    para("SingleCentered", runs(str(meta.division):upper() .. " DIVISION")),
  }
  local out = table.concat(court) .. BLANK_LINE .. caption_xml(meta) .. BLANK_LINE
  out = out .. para("SingleCentered", runs(str(meta.title):upper(), "<w:b />"))
  if meta.subtitle then
    out = out .. para("SingleCentered", runs(str(meta.subtitle):upper(), "<w:b />"), '<w:spacing w:before="276" w:after="0" w:line="276" w:lineRule="exact" />')
  end
  return out .. BLANK_LINE
end

local function custom(name)
  return pandoc.Attr("", {}, { ["custom-style"] = name })
end

local function tab()
  return pandoc.RawInline("openxml", '<w:r><w:tab /></w:r>')
end

-- The table of contents: a TOC field over the heading styles (level 1 to 3), its cached entries the body's
-- headings. Word updates it on open; the field is marked dirty so a viewer that honors it does so.
local function toc_xml(blocks)
  local entries = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= 3 then
      entries[#entries + 1] = { level = b.level, text = str(b.content) }
    end
  end
  local out = {}
  out[#out + 1] = para("CenteredBold", runs("TABLE OF CONTENTS"), '<w:pageBreakBefore />')
  out[#out + 1] = BLANK_LINE
  for i, e in ipairs(entries) do
    local field = ""
    if i == 1 then
      field = '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true" /></w:r>'
        .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate" /></w:r>'
    end
    out[#out + 1] = para("TOC" .. e.level, field .. runs(e.text))
  end
  out[#out + 1] = '<w:p><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p>'
  return table.concat(out)
end

-- The table of authorities: one bold category per group; each entry with dot leaders to its page references.
local function toa_xml(groups)
  local out = { para("CenteredBold", runs("TABLE OF AUTHORITIES"), '<w:pageBreakBefore />'), BLANK_LINE }
  for _, g in ipairs(groups) do
    out[#out + 1] = para("TOACategory", runs(str(g.category)))
    for _, item in ipairs(g.items) do
      out[#out + 1] = para("TOAEntry", runs(md_inlines(item.cite)) .. '<w:r><w:tab /></w:r>' .. runs(str(item.pages)))
    end
  end
  return table.concat(out)
end

-- The section break that ends the front matter: lowerRoman page numbers; the body's section follows.
local function front_section_break()
  return '<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="' .. FRONT_FOOTER .. '" />'
    .. '<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />'
    .. '<w:pgNumType w:fmt="lowerRoman" w:start="1" /></w:sectPr></w:pPr></w:p>'
end

-- Walk a run of blocks: lists become "(n)" items; paragraphs stay paragraphs; Divs are unwrapped.
local function walk(blocks, out)
  for _, b in ipairs(blocks) do
    if b.t == "Div" then
      walk(b.content, out)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local content = pandoc.List({ pandoc.Str("(" .. i .. ")"), tab() })
        local first = item[1]
        local rest = 2
        if first and (first.t == "Para" or first.t == "Plain") then
          content:extend(first.content)
        else
          rest = 1
        end
        out:insert(pandoc.Div({ pandoc.Para(content) }, custom("Lettered Item")))
        for j = rest, #item do out:insert(item[j]) end
      end
    else
      out:insert(b)
    end
  end
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

function Pandoc(doc)
  local meta = doc.meta
  local front, body = pandoc.List(), pandoc.List()
  local first_h1 = nil
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      first_h1 = i
      break
    end
  end
  local split = first_h1 or (#doc.blocks + 1)
  for i, b in ipairs(doc.blocks) do
    if i < split then front:insert(b) else body:insert(b) end
  end

  local out = pandoc.List()
  out:insert(raw(front_xml(meta)))
  local front_out = pandoc.List()
  walk(front, front_out)
  out:extend(front_out)

  if meta.authorities then
    out:insert(raw(toc_xml(body)))
    out:insert(raw(toa_xml(meta.authorities)))
  end
  out:insert(raw(front_section_break()))

  local body_out = pandoc.List()
  walk(body, body_out)
  out:extend(body_out)

  local tail = BLANK_LINE .. signature_xml(meta.signature)
  if meta.certificate then
    tail = tail .. para("CenteredBold", runs("CERTIFICATE OF SERVICE"))
    tail = tail .. para("BodyText", runs(str(meta.certificate.text)))
    tail = tail .. BLANK_LINE .. signature_xml(meta.certificate.signature)
  end
  out:insert(raw(tail))

  meta.title = nil
  meta.subtitle = nil
  return pandoc.Pandoc(out, meta)
end
