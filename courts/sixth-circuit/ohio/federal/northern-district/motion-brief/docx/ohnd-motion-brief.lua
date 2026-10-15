-- N.D. Ohio memorandum in support of a motion (ohnd), DOCX engine (docs/DOCX.md): the markdown contract -> Word
-- on reference.docx. Mirrors typst/ohnd-motion-brief.typ:
--   * a 0.5 in spacer above the court title (the 1 1/2 in first-page top margin, L.R. 10.1);
--   * court title, caption as a borderless table (party column, ")" marks, "Case No." and "Judge:" at the right),
--     and the title centered bold on a 5.6 in measure, all from the sample's frontmatter;
--   * the body, unnumbered, double spaced, first-line indent; the last paragraph is kept with the signature;
--   * signature block at 2.8 in (firm block, then counsel's lines);
--   * the certification of track and page limit (L.R. 7.1(f)) after the signature.
-- Not built here (BLOCKED, see README.md "Engines"): tables of contents and authorities (a memorandum over 15 pages
-- needs them; this filter stops with an error when `contents: true`), and the page-limit assertion, which needs the
-- laid-out page count of the LibreOffice PDF.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter.

-- L.R. 7.1(f): dispositive-motion memoranda, by track; other motions 15 pages. Rule data, not case data.
local TRACK_LIMITS = {
  expedited = 10, administrative = 20, standard = 20, unassigned = 20, complex = 30, ["mass tort"] = 40,
}
local MEMO_LIMIT_PLAIN = 15

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
  if meta[key] == nil then error("ohnd-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one paragraph. opts: style, ind (left twips), right (right twips), first (first-line twips), jc, keepNext,
-- rpr (run properties XML), line (exact twips), before, after
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
  if opts.ind or opts.first or opts.right then
    ppr = ppr .. '<w:ind' .. (opts.ind and (' w:left="' .. opts.ind .. '"') or '')
      .. (opts.right and (' w:right="' .. opts.right .. '"') or '')
      .. ' w:firstLine="' .. (opts.first or 0) .. '"/>'
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

local function blank_line(keep)
  return p("", { style = "Single", line = 552, keepNext = keep })
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
-- caption (Fed. R. Civ. P. 10(a)); widths as typst: party column 3.3 in, ")" column 0.3 in, the rest
-- ---------------------------------------------------------------------------

local CAP_W = { 4752, 432, 4176 }

local function caption(meta)
  local out = {}
  out[#out + 1] = p("", { style = "Single", line = 720 })
  local court = { "UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF OHIO" }
  if meta.division ~= nil then court[#court + 1] = string.upper(text(meta.division)) end
  for _, l in ipairs(court) do
    out[#out + 1] = p(l, { style = "Centered", rpr = BOLD })
  end
  out[#out + 1] = blank_line()

  local c = need(meta, "caption")
  local rows = {}
  for k, side in ipairs(need(c, "parties")) do
    if k > 1 then
      rows[#rows + 1] = { t = "", indent = 0 }
      rows[#rows + 1] = { t = "v.", indent = 1080 }
      rows[#rows + 1] = { t = "", indent = 0 }
    end
    for _, n in ipairs(strings(side.names)) do rows[#rows + 1] = { t = n, indent = 0 } end
    rows[#rows + 1] = { t = text(side.designation), indent = 2160 }
  end
  local judge = meta.judge ~= nil and text(meta.judge) or ""
  local trs = {}
  for i, r in ipairs(rows) do
    local right = ""
    if i == 1 then right = "Case No. " .. text(need(meta, "case_number")) end
    if i == 3 then right = "Judge: " .. judge end
    trs[#trs + 1] = {
      p(r.t, { style = "Single", ind = r.indent }),
      p(r.t == "" and "" or ")", { style = "Single" }),
      p(right, { style = "Single", ind = (i <= 3) and 432 or 0 }),
    }
  end
  out[#out + 1] = table_xml(CAP_W, trs)

  -- the title: bold, centered, on a 5.6 in measure (0.45 in each side), one double-spaced line above and below
  out[#out + 1] = blank_line()
  out[#out + 1] = p(text(need(meta, "title")), { style = "Centered", rpr = BOLD, ind = 648, right = 648 })
  out[#out + 1] = blank_line()
  return out
end

-- ---------------------------------------------------------------------------
-- signature block (single-spaced, at 2.8 in: the firm block, then counsel's lines)
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = need(meta, "signature")
  local out = { p("Respectfully submitted,", { style = "Signature", keepNext = true }),
    p("", { style = "Single", keepNext = true }) }
  if sig.firm ~= nil then
    local firm = strings(sig.firm)
    for i, l in ipairs(firm) do out[#out + 1] = p(l, { style = "Signature", keepNext = true }) end
    out[#out + 1] = p("", { style = "Single", keepNext = true })
  end
  local lines = strings(need(sig, "lines"))
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { style = "Signature", keepNext = i < #lines })
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- certification of track and page limit (L.R. 7.1(f)); typst: after the signature block
-- ---------------------------------------------------------------------------

local function certification(meta)
  local dispositive = true
  if meta.dispositive ~= nil then dispositive = meta.dispositive end
  local track = text(need(meta, "track"))
  local limit = dispositive and TRACK_LIMITS[track] or MEMO_LIMIT_PLAIN
  if limit == nil then error("ohnd-motion-brief: frontmatter `track` must be one of the L.R. 7.1(f) tracks", 0) end
  local out = { p("CERTIFICATION OF TRACK AND PAGE LIMIT", { style = "Centered", keepNext = true, rpr = BOLD,
    before = 552, after = 552 }) }
  local body
  if dispositive then
    body = "Pursuant to Local Rule 7.1(f), the undersigned certifies that this memorandum relates to a dispositive motion, that this case is assigned to the "
      .. track .. " track, and that this memorandum adheres to the " .. limit
      .. "-page limitation set by Local Rule 7.1(f) for that track."
  else
    body = "Pursuant to Local Rule 7.1(f), the undersigned certifies that this memorandum relates to a motion other than a dispositive motion, that this case is assigned to the "
      .. track .. " track, and that this memorandum adheres to the " .. limit
      .. "-page limitation set by Local Rule 7.1(f) for such motions."
  end
  if meta.page_limit_order ~= nil then
    body = body .. " The page limitation was modified by order (" .. text(meta.page_limit_order)
      .. "), and this memorandum complies with that modification."
  end
  out[#out + 1] = p(body, { style = "BodyText" })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- body
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  if meta.contents ~= nil and meta.contents ~= false then
    error("ohnd-motion-brief: contents: true (table of contents and table of authorities) is not built by the docx engine; see README.md (BLOCKED)", 0)
  end
  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  -- the caption carries the title; pandoc would otherwise write the metadata title again
  meta.title = nil

  local body = {}
  for _, b in ipairs(doc.blocks) do body[#body + 1] = b end
  -- the last paragraph is kept with the signature block (the signature never stands alone)
  for k = #body, 1, -1 do
    if body[k].t == "Para" then
      body[k] = pandoc.Div({ body[k] }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" }))
      break
    end
  end
  for _, b in ipairs(body) do out[#out + 1] = b end
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta))
  out[#out + 1] = pandoc.RawBlock("openxml", certification(meta))
  return pandoc.Pandoc(out, meta)
end
