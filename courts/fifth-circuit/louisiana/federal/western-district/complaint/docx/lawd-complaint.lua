-- lawd-complaint.lua (docx engine): the W.D. La. complaint form that markdown alone does not give Word
-- (see ../README.md, "Engines"; docs/DOCX.md).
--   * the court title, the caption, the title and the signature block: single-spaced paragraphs and borderless
--     tables (caption: parties | asterisk column | case number and judges), as the typst template lays them out;
--   * numbered paragraphs (FRCP 10(b)): "N." then a tab, in the "Numbered Paragraph" style;
--   * lettered lists ("a.", "b.", ...; "A.", ... after :::upper), in the "Lettered Item" style;
--   * the :::unnumbered and :::upper directives, read in document order exactly as typst reads them: :::unnumbered
--     applies to the next paragraph, :::upper to the next list. pandoc leaves each directive as a Div that never
--     closes, so the Divs are flattened here and their content is walked in order.
-- Every word comes from the sample's frontmatter and body; nothing case-specific is in this file.

local TEXT_TWIPS = 9360 -- 6.5 in: 8.5 in less two 1 in margins
local CAPTION_LEFT = 4752 -- 3.3 in, the party column (typst: caption-left)
local CAPTION_STAR = 432 -- 0.3 in, the asterisk column (typst: caption-star)
local CAPTION_RIGHT = TEXT_TWIPS - CAPTION_LEFT - CAPTION_STAR
local CAPTION_LEFT_PT = 237.6 -- the party column in points, for the line estimate below
local DESIGNATION_INDENT = 2160 -- 1.5 in, typst's #h(1.5in) before each designation
local BLANK_LINE = '<w:p><w:pPr><w:pStyle w:val="Normal" /></w:pPr></w:p>' -- one double-spaced line (v(pitch))

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

-- Width of one character in ems, for estimating how many lines a caption entry wraps to. Upper case is wider
-- than lower case in a serif face; the estimate is checked against the rendered PDF when one is available.
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

local function caption_xml(meta)
  local cap = meta.caption
  local sep = cap.separator and str(cap.separator) or "v."
  local left, nlines = {}, 0
  for i, p in ipairs(cap.parties) do
    if i > 1 then
      -- typst: [#sep \ \ ]: the separator line, then a blank line
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

  -- Blanks (typst: a 1.9 in rule) are underlined no-break spaces.
  local blank = '<w:r><w:rPr><w:u w:val="single" /></w:rPr><w:t xml:space="preserve">' .. string.rep("\u{a0}", 40) .. '</w:t></w:r>'
  local function entry(text)
    if text == nil then return blank end
    return runs(text)
  end
  local right = {}
  right[#right + 1] = para("SingleSpaced", runs("CIVIL ACTION NO. ") .. entry(meta.case_number and str(meta.case_number)))
  right[#right + 1] = para("SingleSpaced", runs("JUDGE ") .. entry(meta.judge and str(meta.judge)))
  right[#right + 1] = para("SingleSpaced", runs("MAGISTRATE JUDGE ") .. entry(meta.magistrate and str(meta.magistrate)))
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

local function signature_xml(sig)
  local left = para("SingleSpaced", runs("Dated: " .. (sig.date and str(sig.date) or "")))
  local right = { para("SingleSpaced", runs("Respectfully submitted,")), para("SingleSpaced", "") }
  for _, l in ipairs(sig.lines) do
    local t = str(l)
    right[#right + 1] = para("SingleSpaced", t == "" and "" or runs(t))
  end
  return table_xml({ 4680, 4680 }, { left, table.concat(right) })
end

local function front_xml(meta)
  local division = str(meta.division):upper()
  local court = {
    para("SingleCentered", runs("UNITED STATES DISTRICT COURT")),
    para("SingleCentered", runs("WESTERN DISTRICT OF LOUISIANA")),
    para("SingleCentered", runs(division .. " DIVISION")),
  }
  local title = para("SingleCentered", runs(str(meta.title):upper(), "<w:b />"))
  return table.concat(court) .. BLANK_LINE .. caption_xml(meta) .. BLANK_LINE .. title .. BLANK_LINE
end

local function custom(name)
  return pandoc.Attr("", {}, { ["custom-style"] = name })
end

local function tab()
  return pandoc.RawInline("openxml", '<w:r><w:tab /></w:r>')
end

-- Flatten the directive Divs in document order, numbering paragraphs and lettering lists as typst does.
local function walk(blocks, out, st)
  for _, b in ipairs(blocks) do
    if b.t == "Div" then
      local cls = b.attr.classes[1]
      if cls == "unnumbered" then
        st.unnumbered = true
      elseif cls == "upper" then
        st.upper = true
      end
      walk(b.content, out, st)
    elseif b.t == "Para" or b.t == "Plain" then
      if st.unnumbered then
        st.unnumbered = false
        out:insert(pandoc.Para(b.content))
      else
        st.n = st.n + 1
        local content = pandoc.List({ pandoc.Str(st.n .. "."), tab() })
        content:extend(b.content)
        out:insert(pandoc.Div({ pandoc.Para(content) }, custom("Numbered Paragraph")))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      local upper = st.upper
      st.upper = false
      for i, item in ipairs(b.content) do
        local label = string.char((upper and 64 or 96) + i) .. "."
        local content = pandoc.List({ pandoc.Str(label), tab() })
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

function Pandoc(doc)
  local meta = doc.meta
  local out = pandoc.List()
  out:insert(pandoc.RawBlock("openxml", front_xml(meta)))
  walk(doc.blocks, out, { n = 0, unnumbered = false, upper = false })
  out:insert(pandoc.RawBlock("openxml", BLANK_LINE .. signature_xml(meta.signature)))
  meta.title = nil
  meta.subtitle = nil
  return pandoc.Pandoc(out, meta)
end
