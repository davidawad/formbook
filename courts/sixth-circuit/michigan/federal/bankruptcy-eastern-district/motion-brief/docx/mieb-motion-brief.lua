-- E.D. Mich. bankruptcy motion with brief (mieb), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document
-- on reference.docx. Mirrors typst/mieb-motion-brief.typ:
--   * the body is split into the documents of the filing at the DOCSEP paragraphs (render.sh writes the `---`
--     separators as DOCSEP); each document starts on a new page with its own caption (court, rule, the debtor and
--     case block in two borderless columns with a rule, the title in bold, centered), and the title is the
--     frontmatter `titles` entry for that document (a count mismatch is an error, as in typst);
--   * the body keeps its markdown structure: `#` centered bold, `##` bold, `###` bold italic; paragraphs are typed by
--     the author ("1\."), not numbered here; footnotes are pandoc's native footnotes;
--   * each document ends with the signature block: "Dated" at the left, "Respectfully submitted" and the signer at
--     the right (a borderless table, rows kept whole).
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter.
-- Known differences from typst are listed in ../README.md ("## Engines").

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return (s:gsub('"', "&quot;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or a single value) as a Lua list of strings
local function strings(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then
    for _, item in ipairs(v) do out[#out + 1] = text(item) end
  else
    out[1] = text(v)
  end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("mieb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- ---------------------------------------------------------------------------
-- raw WordprocessingML helpers
-- ---------------------------------------------------------------------------

-- one paragraph; opts: style, ind (left twips), first (first-line twips), jc, before, after, keepNext,
-- pageBreakBefore, border (bottom rule), rpr (run properties XML)
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.pageBreakBefore then ppr = ppr .. "<w:pageBreakBefore/>" end
  if opts.border then
    ppr = ppr .. '<w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr>'
  end
  if opts.before or opts.after then
    ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) .. '"/>'
  end
  if opts.ind or opts.first then
    ppr = ppr .. '<w:ind w:left="' .. (opts.ind or 0) .. '" w:firstLine="' .. (opts.first or 0) .. '"/>'
  end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local run = ""
  if s ~= nil and s ~= "" then
    run = '<w:r>' .. (opts.rpr and ('<w:rPr>' .. opts.rpr .. '</w:rPr>') or '')
      .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
  end
  return '<w:p>' .. (ppr ~= "" and ('<w:pPr>' .. ppr .. '</w:pPr>') or '') .. run .. '</w:p>'
end

local BOLD = "<w:b/><w:bCs/>"

local function spacer(twips)
  return p("", { style = "Single", before = twips, after = 0 })
end

local function rule()
  return p("", { style = "Single", border = true })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- a table: widths in twips; rows[r][c] = { xml = paragraphs }
local function table_xml(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for c, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/></w:tcPr>' .. cell.xml .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the caption of each document (MIEB-CAP-001)
-- ---------------------------------------------------------------------------

local function caption(meta, title, new_page)
  local out = {}
  local court = strings(need(meta, "court"))
  for i, l in ipairs(court) do
    out[#out + 1] = p(l, { style = "Centered", pageBreakBefore = (new_page and i == 1) })
  end
  out[#out + 1] = spacer(336)
  out[#out + 1] = rule()

  local ir, cs = need(meta, "in_re"), need(meta, "case")
  local left, right = {}, {}
  for i, n in ipairs(strings(ir.names)) do
    left[#left + 1] = p(((i == 1) and "In re: " or "") .. n, { style = "Single" })
  end
  left[#left + 1] = p(text(ir.role), { style = "SingleRight" })
  left[#left + 1] = p("/", { style = "Single" })
  right[#right + 1] = p("Chapter " .. text(cs.chapter), { style = "Single", ind = 360 })
  right[#right + 1] = p("Case No. " .. text(cs.number), { style = "Single", ind = 360 })
  right[#right + 1] = p(text(cs.judge), { style = "Single", ind = 360 })
  out[#out + 1] = table_xml({ 4680, 4680 }, {
    { { xml = table.concat(left) }, { xml = table.concat(right) } },
  })
  out[#out + 1] = rule()
  out[#out + 1] = spacer(336)
  out[#out + 1] = p(title, { style = "Centered", rpr = BOLD })
  out[#out + 1] = spacer(224)
  return out
end

-- ---------------------------------------------------------------------------
-- the signature block at the end of each document (MIEB-SIG-001)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local left, right = {}, {}
  left[#left + 1] = p("Dated: " .. text(need(meta, "date")), { style = "Signature" })
  right[#right + 1] = p("Respectfully submitted,", { style = "Signature" })
  right[#right + 1] = p(text(sig.signer), { style = "Signature" })
  for _, l in ipairs(strings(sig.lines)) do
    right[#right + 1] = p(l, { style = "Signature" })
  end
  return { spacer(336), table_xml({ 4752, 4608 }, {
    { { xml = table.concat(left) }, { xml = table.concat(right) } },
  }) }
end

-- ---------------------------------------------------------------------------
-- the filing: one document per DOCSEP-separated part of the body
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local titles = strings(need(meta, "titles"))

  local parts = { {} }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and text(b) == "DOCSEP" then
      parts[#parts + 1] = {}
    else
      local last = parts[#parts]
      last[#last + 1] = b
    end
  end
  if #parts ~= #titles then
    error("mieb-motion-brief: the body has " .. #parts .. " documents but `titles` lists " .. #titles, 0)
  end

  local out = {}
  for i, blocks in ipairs(parts) do
    for _, x in ipairs(caption(meta, titles[i], i > 1)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
    for _, b in ipairs(blocks) do out[#out + 1] = b end
    for _, x in ipairs(signature(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  end
  meta.titles = nil
  return pandoc.Pandoc(out, meta)
end
