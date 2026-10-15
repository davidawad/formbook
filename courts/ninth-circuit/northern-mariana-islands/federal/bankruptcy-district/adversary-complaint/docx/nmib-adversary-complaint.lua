-- NMIB adversary complaint, DOCX engine (docs/DOCX.md). The markdown contract of
-- typst/nmib-adversary-complaint.typ, as Word XML on docx/reference.docx:
--   cover: counsel block (single spaced), court title, Official Form 416D caption (a table with a right
--   and bottom rule on the party column), title of the paper, page break;
--   body: each markdown paragraph is a numbered allegation (Fed. R. Civ. P. 10(b)); a paragraph that starts
--   with "::" (a lead-in such as WHEREFORE) is not numbered; headings and lists are unnumbered;
--   signature block. Every case-specific word comes from the sample's YAML frontmatter, never from here.
-- Known limits (BLOCKED, see README.md "Engines"): the case-number and footer-title line of the typst footer
-- is not in the docx footer (the footer is static in reference.docx); the caption table is not numbered by
-- Word's line numbering (Word skips tables); the counsel block is single spaced, not on the 24-point grid.

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- one run of text; bold / italic as flags
local function run(s, bold, italic)
  local rpr = ""
  if bold then rpr = rpr .. "<w:b/>" end
  if italic then rpr = rpr .. "<w:i/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

-- one paragraph: style, optional pPr extras (in schema order: spacing, ind, jc), runs
local function para(style, runs, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or '') .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function page_break()
  return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
end

-- a borderless 2-column table; the left cell may carry a right and a bottom rule (caption)
local function two_col(left_xml, right_xml, lw, rw, left_rules)
  local rules = ''
  if left_rules then
    rules = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
      .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (lw + rw) .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. lw .. '"/><w:gridCol w:w="' .. rw .. '"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. lw .. '" w:type="dxa"/>' .. rules
    .. '<w:tcMar><w:right w:w="144" w:type="dxa"/></w:tcMar></w:tcPr>' .. left_xml .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. rw .. '" w:type="dxa"/><w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. right_xml .. '</w:tc></w:tr></w:tbl>'
end

-- text width is 6.2 in = 8928 twips (letter, 1.3 in left, 1 in right)
local TEXT_W = 8928
local CAP_L = 4608   -- party column (3.2 in)

local function cover(meta)
  local out = {}
  -- counsel block, upper left, single spaced
  for _, l in ipairs(meta.counsel or {}) do
    out[#out + 1] = para("Single", run(str(l)))
  end
  -- court title: centered, bold, capitals, one double-spaced line each
  out[#out + 1] = para("Centered", '', '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>')
  for _, l in ipairs(meta.court or {}) do
    out[#out + 1] = para("Centered", run(str(l):upper(), true),
      '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>')
  end
  out[#out + 1] = para("Single", '')
  -- caption (Official Form 416D): each side, its designation under it, a blank line between sides
  local left, sides = {}, meta.caption or {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names or {}) do left[#left + 1] = para("Single", run(str(n))) end
    left[#left + 1] = para("Single", run(str(side.designation)), '<w:ind w:left="1440"/>')
    if i < #sides then left[#left + 1] = para("Single", '') end
  end
  local adv = meta.adv_number and str(meta.adv_number) or string.rep("_", 8)
  local right = {
    para("Single", run("Case No. " .. str(meta.case_number))),
    para("Single", run("Chapter " .. str(meta.chapter))),
    para("Single", ''),
    para("Single", run("Adv. Proc. No. " .. adv)),
    para("Single", ''),
    para("Single", run(str(meta.brief_title), true)),
  }
  if meta.jury_demand == true then
    right[#right + 1] = para("Single", '')
    right[#right + 1] = para("Single", run("DEMAND FOR JURY TRIAL", true))
  end
  out[#out + 1] = two_col(table.concat(left), table.concat(right), CAP_L, TEXT_W - CAP_L, true)
  out[#out + 1] = page_break()
  return out
end

local function signature(meta)
  local sig = meta.signature or {}
  local firm = {}
  for _, l in ipairs(sig.firm or {}) do firm[#firm + 1] = para("Single", run(str(l))) end
  local right = { para("Single", run("Respectfully submitted,")), para("Single", '') }
  for _, l in ipairs(firm) do right[#right + 1] = l end
  right[#right + 1] = para("Single", '')
  right[#right + 1] = para("Single", run("By: /s/ " .. str(sig.signer)))
  right[#right + 1] = para("Single", run(str(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = para("Single", run(str(l))) end
  local left = para("Single", run("Dated: " .. str(meta.date)))
  return {
    para("BodyText", ''),
    two_col(left, table.concat(right), 4608, TEXT_W - 4608, false),
  }
end

-- one numbered allegation: "1." then a tab, the paragraph text follows
local function numbered(b, n)
  table.insert(b.content, 1, pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>'))
  table.insert(b.content, 1, pandoc.Str(n .. "."))
  return b
end

-- the "::" lead-in: drop the markers and the space after them, no number
local function unnumbered(b)
  local first = b.content[1]
  if first and first.t == "Str" then
    first.text = first.text:gsub("^:+", "")
    if first.text == "" then table.remove(b.content, 1) end
    if b.content[1] and b.content[1].t == "Space" then table.remove(b.content, 1) end
  end
  return b
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  -- cover, caption and signature are Word XML strings; wrap them as raw openxml blocks
  local function raw(b)
    if type(b) == "string" then return pandoc.RawBlock("openxml", b) end
    return b
  end
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = raw(b) end

  -- the section break that ends the cover is the reference's final sectPr, so the body is one section
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local s = str(b)
      if s:match("^:") then
        blocks[#blocks + 1] = unnumbered(b)
      else
        n = n + 1
        blocks[#blocks + 1] = numbered(b, n)
      end
    else
      blocks[#blocks + 1] = b
    end
  end

  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = raw(b) end
  -- pandoc would print the date metadata as a title block; the date is printed in the signature block instead
  meta.date = nil
  return pandoc.Pandoc(blocks, meta)
end
