-- Motion with notice and memorandum, C.D. Cal. bankruptcy court (cacb), DOCX engine (docs/DOCX.md). Markdown
-- contract -> Word document on docx/reference.docx, laid out as typst/cacb-motion-brief.typ: counsel block on lines
-- 1-7, the court title, the caption (debtor on the left, ruled; case number, chapter, title and hearing on the right),
-- then the body on the same first page. Headings are numbered from their level here (I., A., 1., a.; level 1 is an
-- unnumbered centered section that restarts the count); paragraphs are unnumbered and indented; list items are
-- numbered 1., 2., ... (bullets stay bullets). <!-- signature --> places the signature block; <!-- pagebreak --> starts
-- the next block on a new page. Everything case-specific comes from the sample's frontmatter, never from this file.

local TEXTW = 9000
local CAPL, CAPG, CAPR = 4752, 288, 3960
local SIGL, SIGG, SIGR = 3744, 288, 4968
local TAB = '<w:r><w:tab/></w:r>'

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value as a list of plain strings (a YAML list, or one string)
local function strings(v)
  local out = {}
  if v == nil then return out end
  if v.t == nil or v.t == "MetaList" then
    for _, x in ipairs(v) do out[#out + 1] = plain(x) end
  else
    out[#out + 1] = plain(v)
  end
  return out
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- one paragraph: style, direct pPr (schema order: pageBreakBefore, spacing, ind, jc), text, bold
local function para(style, text, ppr, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  local body = ""
  if text ~= nil and text ~= "" then
    body = '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. body .. '</w:p>'
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(grid, rows)
  local cols, total = {}, 0
  for _, w in ipairs(grid) do
    cols[#cols + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NOBORDER
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
end

local function cell(w, inner, rule)
  if inner == "" then inner = para("Single", "") end
  local b = ""
  if rule then
    b = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
      .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  end
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. b .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function row(cells, height)
  local h = height and ('<w:trHeight w:val="' .. height .. '" w:hRule="atLeast"/>') or ""
  return '<w:tr><w:trPr><w:cantSplit/>' .. h .. '</w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

-- counsel block (Central Guide 9004-1(c)(1)(A)): single-spaced from line 1, at least seven numbered lines (168 pt)
local function counsel(lines)
  local ps = {}
  for _, l in ipairs(lines) do ps[#ps + 1] = para("Single", l) end
  return raw(table_xml({ TEXTW }, { row({ cell(TEXTW, table.concat(ps)) }, 3360) }))
end

-- caption of a motion in the main case (Central Guide 9004-1(c)(1)(I)): debtor on the left, ruled right and below;
-- case and chapter numbers, the title and the hearing lines on the right
local function caption(meta)
  local left = {}
  local IN = '<w:ind w:right="200"/>'
  local function add(text) left[#left + 1] = para("Single", text, IN) end
  add("In re:")
  local debtor = meta.caption and meta.caption.debtor or {}
  for _, n in ipairs(strings(debtor.names)) do add(n) end
  add(plain(debtor.designation))
  local RIGHT = '<w:ind w:left="144"/>'
  local right = {}
  local function radd(text, bold) right[#right + 1] = para("Single", text, RIGHT, bold) end
  radd("Case No. " .. plain(meta.bankruptcy_case))
  radd("Chapter " .. plain(meta.chapter))
  radd("")
  right[#right + 1] = para("Single", plain(meta.brief_title), RIGHT, true)
  radd("")
  for _, l in ipairs(strings(meta.hearing)) do radd(l) end
  return raw(table_xml({ CAPL, CAPG, CAPR }, { row({
    cell(CAPL, table.concat(left), true),
    cell(CAPG, ""),
    cell(CAPR, table.concat(right)),
  }) }))
end

-- signature block (typst signature-block): "Dated" at left; the firm, then the signer, at right
local function signature(meta)
  local sig = meta.signature or {}
  local right = {}
  for _, l in ipairs(strings(sig.firm)) do right[#right + 1] = para("Single", l) end
  right[#right + 1] = para("Single", "")
  local signer = plain(sig.signer)
  right[#right + 1] = para("Single", "By: /s/ " .. signer)
  right[#right + 1] = para("Single", string.upper(signer))
  for _, l in ipairs(strings(sig.lines)) do right[#right + 1] = para("Single", l) end
  local left = para("Single", meta.date and ("Dated: " .. plain(meta.date)) or "")
  return raw(table_xml({ SIGL, SIGG, SIGR }, { row({ cell(SIGL, left), cell(SIGG, ""), cell(SIGR, table.concat(right)) }) }))
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

function Pandoc(doc)
  local meta = doc.meta
  if meta.footer_title == nil or meta.bankruptcy_case == nil then
    error("cacb-motion: the frontmatter needs footer_title and bankruptcy_case", 0)
  end
  -- the footer reads the document properties (docProps/core.xml) through its SUBJECT and COMMENTS fields;
  -- the title property is not set, so pandoc writes no title block into the body
  doc.meta.subject = pandoc.MetaInlines({ pandoc.Str(string.upper(plain(meta.footer_title))) })
  doc.meta.description = pandoc.MetaInlines({ pandoc.Str(plain(meta.bankruptcy_case)) })

  local out = {}
  local function add(b) out[#out + 1] = b end

  add(counsel(strings(meta.counsel)))
  add(raw(para("CourtTitle", "UNITED STATES BANKRUPTCY COURT")))
  add(raw(para("CourtTitle", "CENTRAL DISTRICT OF CALIFORNIA")))
  add(raw(para("CourtTitle", string.upper(plain(meta.division)))))
  add(raw(para("CourtTitle", "")))
  add(caption(meta))
  if meta.lead_in ~= nil then
    add(raw(para("CourtTitle", "")))
    local inl = pandoc.read(plain(meta.lead_in), "markdown").blocks[1].content
    add(styled("LeadIn", { pandoc.Para(inl) }))
  end

  local c = { roman = 0, letter = 0, digit = 0, minor = 0 }
  local pending = false
  local ol_keep = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "RawBlock" and b.format == "html" then
      local marker = b.text:match("^%s*<!%-%-%s*(%S+)%s*%-%->%s*$")
      if marker == "signature" then
        -- the paragraph before a signature block stays with it (a signature never stands alone on a page)
        local last = out[#out]
        if last and last.t == "Para" then out[#out] = styled("BodyTextKeep", { last }) end
        add(signature(meta))
      elseif marker == "pagebreak" then
        pending = true
      else
        add(b)
      end
    elseif b.t == "Header" then
      local text = plain(b.content)
      local pb = pending and "<w:pageBreakBefore/>" or nil
      pending = false
      if b.level == 1 then
        c.roman, c.letter, c.digit, c.minor = 0, 0, 0, 0
        add(raw(para("Heading1", string.upper(text), pb)))
      elseif b.level == 2 then
        c.roman = c.roman + 1
        c.letter, c.digit, c.minor = 0, 0, 0
        -- a blank line, the numeral, then the title on the next line (typst: a block of two lines, centered)
        add(raw(para("CourtTitle", "", pb)))
        add(raw(para("HeadingNumeral", roman(c.roman) .. ".")))
        add(raw(para("Heading2", string.upper(text))))
      elseif b.level == 3 then
        c.letter = c.letter + 1
        c.digit, c.minor = 0, 0
        add(raw(para("Heading3", string.char(64 + c.letter) .. ". " .. text, pb)))
      elseif b.level == 4 then
        c.digit = c.digit + 1
        c.minor = 0
        add(raw(para("Heading4", c.digit .. ". " .. text, pb)))
      else
        c.minor = c.minor + 1
        add(raw(para("Heading5", string.char(96 + c.minor) .. ". " .. text, pb)))
      end
    elseif b.t == "Para" or b.t == "Plain" then
      if pending then
        add(styled("BodyTextPB", { pandoc.Para(b.content) }))
        pending = false
      else
        add(b)
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes and b.listAttributes.start or 1
      for i, item in ipairs(b.content) do
        local first = item[1]
        local label = (start + i - 1) .. "."
        if first and (first.t == "Para" or first.t == "Plain") then
          local content = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", TAB) })
          content:extend(first.content)
          add(styled("ListItem", { pandoc.Para(content) }))
          for k = 2, #item do add(item[k]) end
        end
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local content = pandoc.List({ pandoc.Str("\u{2022}"), pandoc.RawInline("openxml", TAB) })
          content:extend(first.content)
          add(styled("ListItem", { pandoc.Para(content) }))
          for k = 2, #item do add(item[k]) end
        end
      end
    elseif b.t == "Table" then
      if pending then
        add(raw(para("Single", "", '<w:pageBreakBefore/>')))
        pending = false
      end
      add(b:walk({
        Plain = function(p) return styled("Single", { pandoc.Para(p.content) }) end,
        Para = function(p) return styled("Single", { pandoc.Para(p.content) }) end,
      }))
    else
      add(b)
    end
  end

  doc.meta.date = nil
  doc.blocks = out
  return doc
end
