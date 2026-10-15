-- W.D. Ky. memorandum in support of a motion (kywd), DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/kywd-motion-brief.typ:
--   * court title (Single, centered bold), caption as a borderless table (party column, a column of ")" marks,
--     case label (default "CASE NO.") and case number on the "vs." row), title centered bold, all from the frontmatter;
--   * body paragraphs unnumbered, first-line indent 0.5 in; headings and lists as written; Heading 1 centered,
--     Heading 2 and 3 bold left;
--   * signature block at 3.25 in (Signature style), and the certificate of service with its own signature block,
--     when the frontmatter has `certificate`.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter.

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
  if meta[key] == nil then error("kywd-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one paragraph. opts: style, ind (left twips), first (first-line twips), jc, keepNext, rpr (run properties XML),
-- line (exact twips; overrides the style's line pitch), before, after
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.keepLines then ppr = ppr .. "<w:keepLines/>" end
  if opts.line then
    ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0)
      .. '" w:line="' .. opts.line .. '" w:lineRule="exact"/>'
  elseif opts.before or opts.after then
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

-- one single-spaced line of blank space at the body's double pitch (a blank line of the typst template)
local function blank_line(keep)
  return p("", { style = "Single", line = 480, keepNext = keep })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- a table: widths in twips; rows[r][c] = cell XML (paragraphs)
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
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/></w:tcPr>' .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- caption (Fed. R. Civ. P. 10(a)); widths as typst: party column 3.1 in, ")" column 0.3 in, the rest
-- ---------------------------------------------------------------------------

local CAP_W = { 4464, 432, 4464 }

local function caption(meta)
  local out = {}
  for _, l in ipairs(strings(need(meta, "court"))) do
    out[#out + 1] = p(l, { style = "Centered", rpr = BOLD })
  end
  out[#out + 1] = blank_line()

  local c = need(meta, "caption")
  local rows = {}
  for k, side in ipairs(need(c, "parties")) do
    if k > 1 then
      rows[#rows + 1] = { t = "", indent = 0 }
      rows[#rows + 1] = { t = "vs.", indent = 1080 }
      rows[#rows + 1] = { t = "", indent = 0 }
    end
    for _, n in ipairs(strings(side.names)) do rows[#rows + 1] = { t = n, indent = 0 } end
    rows[#rows + 1] = { t = text(side.designation), indent = 2160 }
  end
  local case_row = nil
  for i, r in ipairs(rows) do
    if r.t == "vs." then case_row = i; break end
  end
  local label = (meta.case_label ~= nil and text(meta.case_label) or "CASE NO.") .. " " .. text(need(meta, "case_number"))
  local trs = {}
  for i, r in ipairs(rows) do
    trs[#trs + 1] = {
      p(r.t, { style = "Single", ind = r.indent }),
      p(")", { style = "Single" }),
      p((i == case_row) and label or "", { style = "Single" }),
    }
  end
  out[#out + 1] = table_xml(CAP_W, trs)

  out[#out + 1] = blank_line()
  out[#out + 1] = p(text(need(meta, "title")), { style = "Centered", rpr = BOLD })
  out[#out + 1] = blank_line()
  return out
end

-- ---------------------------------------------------------------------------
-- signature block (LR 5.2(a) sets no form; the layout follows the filed exemplar and typst)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local out = { blank_line(true), p("Respectfully submitted,", { style = "Signature", keepNext = true }), blank_line(true) }
  out[#out + 1] = p("By: /s/ " .. text(need(sig, "by")), { style = "Signature", keepNext = true })
  out[#out + 1] = blank_line(true)
  local lines = strings(need(sig, "lines"))
  for i, l in ipairs(lines) do
    if l == "" then
      out[#out + 1] = blank_line(true)
    else
      out[#out + 1] = p(l, { style = "Signature", keepNext = i < #lines })
    end
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- body: paragraphs are not numbered (a memorandum is not a complaint; Rule 10(b) does not apply)
-- ---------------------------------------------------------------------------

-- the certificate of service (optional): heading centered bold, its text, and a signature block
local function certificate(meta)
  if meta.certificate == nil then return {} end
  local cert = meta.certificate
  local out = {}
  out[#out + 1] = p(text(need(cert, "heading")), { style = "Centered", keepNext = true, before = 240, after = 240, rpr = BOLD })
  out[#out + 1] = p(text(need(cert, "text")), { style = "BodyText" })
  out[#out + 1] = signature(meta)
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  -- the caption carries the title; pandoc would otherwise write the metadata title again
  meta.title = nil
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta))
  for _, x in ipairs(certificate(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  return pandoc.Pandoc(out, meta)
end
