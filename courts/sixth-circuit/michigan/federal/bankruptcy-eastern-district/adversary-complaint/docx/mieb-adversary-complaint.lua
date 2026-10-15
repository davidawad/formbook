-- E.D. Mich. bankruptcy adversary complaint (mieb), DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on reference.docx. Mirrors typst/mieb-adversary-complaint.typ:
--   * the court name (centered, single spaced), a rule, the debtor caption and the adversary caption as two
--     borderless two-column tables with rules (paragraph bottom border, cell borders), the title in bold, centered;
--   * the lead-in paragraph (frontmatter `lead_in`), unnumbered, no first-line indent;
--   * the body: `#` and `##` headings centered and bold; every other paragraph numbered here, from 1, with the
--     number typed as text ("1."); a paragraph beginning WHEREFORE is an unnumbered prayer;
--   * the signature block: "Dated" at the left, the signer at the right (a borderless table, rows kept whole).
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter.
-- Known differences from typst are listed in ../README.md ("## Engines").

local TEXT_W = 9360 -- 6.5 in of text width in twips (letter, 1 in margins)

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
  if meta[key] == nil then error("mieb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- ---------------------------------------------------------------------------
-- raw WordprocessingML helpers
-- ---------------------------------------------------------------------------

-- one paragraph; opts: style, ind (left twips), first (first-line twips), jc, before, after, keepNext,
-- pageBreakBefore, rpr (run properties XML)
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

-- a table: widths in twips; rows[r][c] = { xml = paragraphs, borders = tcBorders XML or nil }
local function table_xml(widths, rows, tbl_borders)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. tbl_borders
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for c, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/>'
        .. (cell.borders or "") .. '</w:tcPr>' .. cell.xml .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the cover: court, caption, title (MIEB-CAP-001, MIEB-CAP-002)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  for _, l in ipairs(strings(need(meta, "court"))) do
    out[#out + 1] = p(l, { style = "Centered" })
  end
  out[#out + 1] = spacer(336)
  out[#out + 1] = rule()

  -- debtor caption: the in re block on the left (role at the right), the case block on the right
  local ir, cs = need(meta, "in_re"), need(meta, "case")
  local left, right = {}, {}
  local names = strings(ir.names)
  for i, n in ipairs(names) do
    local lead = (i == 1) and "In re: " or ""
    left[#left + 1] = p(lead .. n, { style = "Single" })
  end
  left[#left + 1] = p(text(ir.role), { style = "SingleRight" })
  right[#right + 1] = p("Case No. " .. text(cs.number), { style = "Single", ind = 360 })
  right[#right + 1] = p("Chapter " .. text(cs.chapter), { style = "Single", ind = 360 })
  right[#right + 1] = p(text(cs.judge), { style = "Single", ind = 360 })
  out[#out + 1] = table_xml({ 4680, 4680 }, {
    { { xml = table.concat(left) }, { xml = table.concat(right) } },
  }, NO_BORDERS)
  out[#out + 1] = rule()
  out[#out + 1] = spacer(168)

  -- adversary caption: the parties on the left ("vs." between them), the chapter and the adversary number on the right
  local pl, pr = {}, {}
  local parties = need(meta, "caption")
  for i, side in ipairs(parties) do
    for _, n in ipairs(strings(side.names)) do pl[#pl + 1] = p(n, { style = "Single" }) end
    pl[#pl + 1] = p(text(side.designation), { style = "SingleRight" })
    if i < #parties then
      pl[#pl + 1] = p("vs.", { style = "Centered", before = 120, after = 120 })
    end
  end
  local an = text(need(meta, "adversary_number"))
  if an == "" then an = string.rep("_", 14) end
  pr[#pr + 1] = p("Chapter " .. text(cs.chapter), { style = "Single", ind = 360 })
  pr[#pr + 1] = p("Adversary Proceeding No. " .. an, { style = "Single", ind = 360 })
  out[#out + 1] = table_xml({ 4680, 4680 }, {
    { { xml = table.concat(pl) }, { xml = table.concat(pr) } },
  }, NO_BORDERS)
  out[#out + 1] = rule()
  out[#out + 1] = spacer(336)
  out[#out + 1] = p(text(need(meta, "title")), { style = "Centered", rpr = BOLD })
  out[#out + 1] = spacer(224)
  return out
end

-- ---------------------------------------------------------------------------
-- the signature block (MIEB-SIG-001): "Dated" at the left, the signer at the right
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local left, right = {}, {}
  left[#left + 1] = p("Dated: " .. text(need(meta, "date")), { style = "Signature" })
  right[#right + 1] = p(text(sig.signer), { style = "Signature" })
  for _, l in ipairs(strings(sig.lines)) do
    right[#right + 1] = p(l, { style = "Signature" })
  end
  local out = { spacer(336) }
  out[#out + 1] = table_xml({ 4752, 4608 }, {
    { { xml = table.concat(left) }, { xml = table.concat(right) } },
  }, NO_BORDERS)
  return out
end

-- ---------------------------------------------------------------------------
-- the body: numbered paragraphs, unnumbered prayers, centered headings
-- ---------------------------------------------------------------------------

local function starts_with_wherefore(para)
  local first = para.content[1]
  return first and first.t == "Str" and first.text:match("^WHEREFORE") ~= nil
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end

  -- the lead-in: the opening paragraph before the first heading, unnumbered, not indented
  out[#out + 1] = pandoc.RawBlock("openxml", p(text(need(meta, "lead_in")), { style = "BodyText", first = 0 }))

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      if not starts_with_wherefore(b) then
        n = n + 1
        table.insert(b.content, 1, pandoc.Space())
        table.insert(b.content, 1, pandoc.Str(tostring(n) .. "."))
      end
    end
    out[#out + 1] = b
  end

  for _, x in ipairs(signature(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  meta.title = nil
  return pandoc.Pandoc(out, meta)
end
