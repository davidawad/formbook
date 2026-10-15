-- lawb-motion-brief.lua (docx engine): what the Word output adds to pandoc's default conversion, so that it follows
-- typst/lawb-motion-brief.typ (see ../README.md, "Engines"):
--   * the cover: court name, the caption box (parties left, case numbers right, a rule around and between them),
--     the title lines, and a rule under the title;
--   * lettered items "a.", "b." ... from the markdown's numbered lists (the typst enum "a.");
--   * the signature block (LBR 5005-1(b)): the lead-in, then the firm, the "By:" line, names with bar numbers, address,
--     telephone, fax, email and the counsel line, single-spaced at 2.75 in and kept together;
--   * the certificate of service (LBR 9013-1(d)) when the frontmatter supplies one.
-- Court name and layout constants are here; every case-specific word comes from the sample's frontmatter.
-- Lengths are in twips (1 pt = 20): SINGLE is 15 pt, DOUBLE is 26 pt (the typst pitch), HALF is half of it.

local SINGLE = 300
local DOUBLE = 520
local HALF = 260
local COURT = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF LOUISIANA" }
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Metadata value to plain text.
local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- Metadata value to a list of plain-text lines (a YAML list or a single value).
local function lines(v)
  local out = {}
  if v == nil then return out end
  if v.t == "MetaList" then
    for _, item in ipairs(v) do out[#out + 1] = str(item) end
  else
    out[1] = str(v)
  end
  return out
end

local function spacing(before, after, line)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before, after, line)
end

local function xrun(s, rpr)
  return string.format('<w:r>%s<w:t xml:space="preserve">%s</w:t></w:r>', rpr or "", esc(s))
end

local function xpara(ppr, runs)
  return string.format("<w:p><w:pPr>%s</w:pPr>%s</w:p>", ppr, runs or "")
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function spacer(height)
  return raw(xpara(spacing(0, 0, height)))
end

local BOLD = "<w:rPr><w:b/><w:bCs/></w:rPr>"
local CENTER = '<w:jc w:val="center"/>'

-- ---------------------------------------------------------------------------
-- Cover: court name, caption box, title, rule
-- ---------------------------------------------------------------------------

-- The caption box: one table, a single rule round both cells and between them (the typst table stroke).
local function caption(meta)
  local left, right = {}, {}
  for _, item in ipairs(meta.caption.left) do
    local t = str(item.t)
    local indent = tonumber(str(item.i)) or 0
    local ppr = spacing(0, 0, SINGLE)
    if indent > 0 then ppr = ppr .. string.format('<w:ind w:left="%d"/>', 720 * indent) end
    left[#left + 1] = xpara(ppr, t ~= "" and xrun(t) or nil)
  end
  for _, t in ipairs(lines(meta.caption.right)) do
    right[#right + 1] = xpara(spacing(0, 0, SINGLE), t ~= "" and xrun(t) or nil)
  end
  local function cell(width, paras)
    return string.format('<w:tc><w:tcPr><w:tcW w:w="%d" w:type="dxa"/></w:tcPr>%s</w:tc>', width, table.concat(paras))
  end
  local rule = '<w:%s w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  local borders = "<w:tblBorders>"
    .. string.format(rule, "top") .. string.format(rule, "left") .. string.format(rule, "bottom")
    .. string.format(rule, "right") .. string.format(rule, "insideH") .. string.format(rule, "insideV")
    .. "</w:tblBorders>"
  return string.format(
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>%s<w:tblLayout w:type="fixed"/>'
      .. '<w:tblCellMar><w:top w:w="144" w:type="dxa"/><w:left w:w="173" w:type="dxa"/>'
      .. '<w:bottom w:w="144" w:type="dxa"/><w:right w:w="173" w:type="dxa"/></w:tblCellMar></w:tblPr>'
      .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid><w:tr>%s%s</w:tr></w:tbl>',
    borders, cell(4896, left), cell(4464, right))
end

local function cover(meta)
  local out = {}
  for _, line in ipairs(COURT) do
    out[#out + 1] = raw(xpara(spacing(0, 0, SINGLE) .. CENTER, xrun(line, BOLD)))
  end
  out[#out + 1] = spacer(DOUBLE)
  out[#out + 1] = raw(caption(meta))
  out[#out + 1] = spacer(DOUBLE)
  local title = lines(meta.title)
  for _, line in ipairs(title) do
    out[#out + 1] = raw(xpara(spacing(0, 0, SINGLE) .. CENTER, xrun(line:upper(), BOLD)))
  end
  out[#out + 1] = spacer(HALF)
  -- A paragraph with a bottom border and a one-point line: the rule under the title.
  out[#out + 1] = raw(xpara('<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>'
    .. spacing(0, DOUBLE, 20)))
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 5005-1(b)) and certificate
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local items = { { str(sig.lead), HALF } }
  items[#items + 1] = { str(sig.firm) }
  items[#items + 1] = { "By: " .. str(sig.by) }
  for _, l in ipairs(lines(sig.lines)) do items[#items + 1] = { l } end
  items[#items + 1] = { "" }
  for _, l in ipairs(lines(sig.counsel_for)) do items[#items + 1] = { l } end
  local out = {}
  for i, item in ipairs(items) do
    local keep = i < #items and "<w:keepNext/><w:keepLines/>" or "<w:keepLines/>"
    local before = item[2] or 0
    local sp = spacing(before, before, SINGLE)
    local text = item[1] ~= "" and xrun(item[1]) or nil
    out[#out + 1] = raw(xpara(keep .. sp .. '<w:ind w:left="3960"/>', text))
  end
  return out
end

local function certificate(meta)
  local out = pandoc.List()
  local c = meta.certificate
  if c.t == "MetaBlocks" then
    out:extend(c)
  elseif c.t == "MetaInlines" then
    out:insert(pandoc.Para(c))
  else
    out:extend(pandoc.read(str(c), "markdown").blocks)
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function lettered_item(i, blocks)
  local first = blocks[1]
  if #blocks ~= 1 or (first.t ~= "Para" and first.t ~= "Plain") then
    error("lawb-motion-brief.lua: a list item must be a single paragraph")
  end
  local content = pandoc.List({ pandoc.Str(string.char(96 + i) .. "."), TAB })
  content:extend(first.content)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "List Letter" })
end

function Pandoc(doc)
  local meta = doc.meta
  local out = pandoc.List()
  out:extend(cover(meta))
  for _, b in ipairs(doc.blocks) do
    if b.t == "OrderedList" then
      for i, item in ipairs(b.content) do out:insert(lettered_item(i, item)) end
    else
      out:insert(b)
    end
  end
  out:extend(signature(meta))
  if meta.certificate then
    out:insert(spacer(DOUBLE))
    out:extend(certificate(meta))
  end
  -- The YAML title is printed on the cover, not as a Title paragraph.
  meta.title = nil
  return pandoc.Pandoc(out, meta)
end
