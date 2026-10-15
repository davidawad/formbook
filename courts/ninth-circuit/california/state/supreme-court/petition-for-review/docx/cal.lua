-- California Supreme Court: pandoc filter for the docx engine, petition for review.
-- Writes the cover from the markdown frontmatter (the fields the typst cover reads) as WordprocessingML paragraphs,
-- then a page break; the body stays pandoc's. Fonts, sizes, spacing, page setup and the page-number footer come
-- from reference.docx (docx/make-reference.sh). Not built here (BLOCKED, see README.md "Engines"): the caption rules,
-- the table of contents and table of authorities, the signature block, the certificates and the proof of service.

local function str(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- One single-spaced paragraph. o.jc: left|center|right; o.ind: left indent in twips; o.after: space after in twips.
local function p(text, o)
  o = o or {}
  local ppr = string.format(
    '<w:pPr><w:spacing w:before="0" w:after="%d" w:line="240" w:lineRule="auto" /><w:ind w:left="%d" w:firstLine="0" /><w:jc w:val="%s" /></w:pPr>',
    o.after or 0, o.ind or 0, o.jc or "left")
  local rpr = ""
  if o.b then rpr = rpr .. "<w:b />" end
  if o.i then rpr = rpr .. "<w:i />" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return pandoc.RawBlock("openxml", "<w:p>" .. ppr .. "<w:r>" .. rpr
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>")
end

local function cover(meta)
  local b = {}
  local function add(x) table.insert(b, x) end
  add(p("No. " .. str(meta.supreme_court_case), { jc = "center", b = true, after = 480 }))
  add(p("In the Supreme Court of the State of California", { jc = "center", after = 480 }))
  for _, c in ipairs(meta.caption or {}) do
    for _, n in ipairs(c.names or {}) do add(p(str(n), { jc = "center" })) end
    add(p(str(c.designation), { jc = "right", after = 240 }))
  end
  add(p("", { after = 240 }))
  add(p(str(meta.court_of_appeal), { jc = "center" }))
  add(p(str(meta.trial_court), { jc = "center" }))
  add(p(str(meta.judge), { jc = "center", after = 480 }))
  for _, c in ipairs(meta.counsel or {}) do
    for _, n in ipairs(c.names or {}) do add(p(str(n), { b = true })) end
    for _, l in ipairs(c.lines or {}) do add(p(str(l))) end
    add(p("", {}))
  end
  add(pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page" /></w:r></w:p>'))
  return b
end

function Pandoc(doc)
  local blocks = cover(doc.meta)
  for _, blk in ipairs(doc.blocks) do table.insert(blocks, blk) end
  doc.blocks = pandoc.Blocks(blocks)
  return doc
end
