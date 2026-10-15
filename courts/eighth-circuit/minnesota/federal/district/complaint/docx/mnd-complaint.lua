-- mnd-complaint.lua (docx engine): what the Word output adds to pandoc's default conversion, to match
-- typst/mnd-complaint.typ (see ../README.md "Engines"):
--   * the front page: the court's name, the caption table (party column between rules, file number and title on the
--     right), the blank line after each block; all from the sample's frontmatter, never from this file;
--   * numbered allegations (Fed. R. Civ. P. 10(b)): every paragraph after a heading that is not DEMAND or PRAYER is
--     numbered from 1 with a tab after the number, as the typst template does;
--   * lettered prayer items (A., B., ...) hanging from the letter (custom style "Prayer Item", ../reference.docx);
--   * the signature block: date on the left, firm and signer on the right, single-spaced, kept together.
-- Frontmatter values are read as plain text (stringify): the caption, signature and lead-in carry no italics.
-- Raw openxml is used only where Word has no paragraph-level equivalent (table borders, the caption table).

local TWIP_DOUBLE = 598 -- 29.9 pt: the typst body pitch (2.3 em at 13 pt)
local TWIP_SINGLE = 299 -- 14.95 pt: the typst single pitch (1.15 em)
local TWIP_STACK = 130 -- 6.5 pt: the typst stack spacing between single-spaced items

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- One run of text; rpr is the run-property XML (bold, size) or nil.
local function run(text, rpr)
  local props = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. props .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- One paragraph: ppr is the paragraph-property XML; a blank line is an empty paragraph with the same pitch.
local function para(ppr, runs)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (runs or "") .. "</w:p>"
end

local function spacing(line, after)
  return string.format('<w:spacing w:before="0" w:after="%d" w:line="%d" w:lineRule="exact" />', after or 0, line)
end

local BOLD = '<w:b /><w:bCs /><w:sz w:val="26" /><w:szCs w:val="26" />'
local PLAIN = '<w:sz w:val="26" /><w:szCs w:val="26" />'
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>")

-- Caption: a two-column borderless table; the party column has a rule above and below (typst "caption").
local function caption_table(meta)
  local left = {}
  local parties = meta.caption or {}
  for k, p in ipairs(parties) do
    if k > 1 then
      left[#left + 1] = { ppr = spacing(TWIP_SINGLE, TWIP_STACK) .. '<w:ind w:left="432" />', runs = run("v.", PLAIN) }
    end
    for _, name in ipairs(p.names or {}) do
      left[#left + 1] = { ppr = spacing(TWIP_SINGLE, TWIP_STACK), runs = run(txt(name), PLAIN) }
    end
    left[#left + 1] = { ppr = spacing(TWIP_SINGLE, TWIP_STACK) .. '<w:ind w:left="1728" />', runs = run(txt(p.designation), PLAIN) }
  end
  local left_xml = {}
  for i, item in ipairs(left) do
    local ppr = item.ppr
    if i == #left then ppr = ppr:gsub('w:after="%d+"', 'w:after="0"') end
    left_xml[#left_xml + 1] = para(ppr, item.runs)
  end
  local case_no = txt(meta.case_number)
  if case_no == "" then case_no = "____________________" end
  local right_xml = {
    para(spacing(TWIP_SINGLE, 0), run("Civil No. " .. case_no, PLAIN)),
    para(spacing(TWIP_DOUBLE, 0), ""),
    para(spacing(TWIP_SINGLE, 0) .. '<w:jc w:val="center" />', run(string.upper(txt(meta.brief_title)), BOLD)),
  }
  local rule = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000" /><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000" />'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" /><w:tblInd w:w="0" w:type="dxa" />'
    .. '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar><w:tblLook w:val="0000" /></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752" /><w:gridCol w:w="432" /><w:gridCol w:w="4176" /></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa" /><w:tcBorders>' .. rule .. '</w:tcBorders>'
    .. '<w:tcMar><w:top w:w="160" w:type="dxa" /><w:bottom w:w="160" w:type="dxa" /></w:tcMar></w:tcPr>' .. table.concat(left_xml) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="432" w:type="dxa" /></w:tcPr>' .. para(spacing(TWIP_SINGLE, 0), "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa" /><w:tcMar><w:left w:w="144" w:type="dxa" /></w:tcMar></w:tcPr>' .. table.concat(right_xml) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

-- Court name, centred and bold, single-spaced; then a double line (typst court-title and front-page).
local function front_page(meta)
  local out = {}
  for _, line in ipairs({ "UNITED STATES DISTRICT COURT", "DISTRICT OF MINNESOTA" }) do
    out[#out + 1] = para(spacing(TWIP_SINGLE, 0) .. '<w:jc w:val="center" />', run(line, BOLD))
  end
  out[#out + 1] = para(spacing(TWIP_DOUBLE, 0), "")
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = para(spacing(TWIP_DOUBLE, 0), "")
  return table.concat(out)
end

-- Signature block: date in a 2.6-inch column, the firm and signer in the column to its right (typst "signature-block").
local function signature_block(meta)
  local lines = meta.signature or {}
  local right = {}
  for i, l in ipairs(lines) do
    local s = txt(l)
    if s == "" then s = "\u{00A0}" end
    local after = (i < #lines) and TWIP_STACK or 0
    right[#right + 1] = para('<w:keepNext />' .. spacing(TWIP_SINGLE, after), run(s, PLAIN))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa" /><w:tblInd w:w="0" w:type="dxa" />'
    .. '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar><w:tblLook w:val="0000" /></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="3744" /><w:gridCol w:w="288" /><w:gridCol w:w="5328" /></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit /></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa" /></w:tcPr>' .. para('<w:keepNext />' .. spacing(TWIP_SINGLE, 0), run("Dated: " .. txt(meta.date), PLAIN)) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa" /></w:tcPr>' .. para(spacing(TWIP_SINGLE, 0), "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="5328" w:type="dxa" /></w:tcPr>' .. table.concat(right) .. '</w:tc>'
    .. '</w:tr></w:tbl>'
end

-- A lettered prayer item: "A." then a tab to the text, hanging from the letter.
local function prayer_item(letter, content)
  table.insert(content, 1, TAB)
  table.insert(content, 1, pandoc.Str(letter))
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Prayer Item" })
end

-- Lettered item as markdown gives it: a paragraph that begins "A." (pandoc does not read it as a list).
local function lettered(b)
  if b.t ~= "Para" or #b.content < 2 then return nil end
  local first = b.content[1]
  if first.t ~= "Str" or not first.text:match("^[A-Z][.)]$") then return nil end
  if b.content[2].t ~= "Space" then return nil end
  local rest = {}
  for i = 3, #b.content do rest[#rest + 1] = b.content[i] end
  return first.text, rest
end

function Pandoc(doc)
  local blocks = doc.blocks
  local body = {}
  local numbered = false
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      local head = txt(b.content)
      if head:match("^DEMAND") or head:match("^PRAYER") then
        numbered = false
      else
        numbered = true
      end
      body[#body + 1] = b
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local letter = string.char(64 + b.listAttributes.start + i - 1)
        local first = item[1]
        if first and first.t == "Para" then
          body[#body + 1] = prayer_item(letter .. ".", first.content)
          for k = 2, #item do body[#body + 1] = item[k] end
        else
          body[#body + 1] = pandoc.Div(item)
        end
      end
    else
      local letter, rest = lettered(b)
      if letter then
        body[#body + 1] = prayer_item(letter, rest)
      elseif b.t == "Para" and numbered then
        n = n + 1
        local content = { pandoc.Str(tostring(n) .. "."), TAB }
        for _, c in ipairs(b.content) do content[#content + 1] = c end
        body[#body + 1] = pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Numbered Paragraph" })
      else
        body[#body + 1] = b
      end
    end
  end

  local out = {}
  out[#out + 1] = pandoc.RawBlock("openxml", front_page(doc.meta))
  if doc.meta.lead_in then
    out[#out + 1] = pandoc.RawBlock("openxml", para("<w:pStyle w:val=\"BodyText\" />", run(txt(doc.meta.lead_in), nil)))
  end
  for _, b in ipairs(body) do out[#out + 1] = b end
  out[#out + 1] = pandoc.RawBlock("openxml", para(spacing(TWIP_DOUBLE, 0), ""))
  out[#out + 1] = pandoc.RawBlock("openxml", signature_block(doc.meta))
  doc.meta.date = nil -- the date is printed in the signature block only, not as a title block
  return pandoc.Pandoc(out, doc.meta)
end
