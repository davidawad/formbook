-- W.D. Mich. complaint (miwd), DOCX engine (docs/DOCX.md): the markdown contract -> a Word body on reference.docx.
-- Mirrors typst/miwd-complaint.typ:
--   * cover: court title, caption (party column closed by a rule; case number, judge, title at right), counsel block;
--   * page 2: the title (centered bold, new page), then the lead-in paragraph;
--   * body paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b)) with a tab after the number, until the heading
--     named by numbering_stops_at; headings as written (Heading 1 to 3 styles); ordered lists lettered A., B., ...;
--   * signature block: "Dated" at left, firm, "By: /s/" and the remaining lines at right, one unbreakable row.
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
  if pandoc.utils.type(v) == "List" then
    for _, item in ipairs(v) do out[#out + 1] = text(item) end
  else
    out[1] = text(v)
  end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("miwd-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one paragraph. opts: style, ind (left twips), first (first-line twips), jc, keepNext, pageBreak, rpr, line (exact
-- twips), before, after
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.keepLines then ppr = ppr .. "<w:keepLines/>" end
  if opts.pageBreak then ppr = ppr .. "<w:pageBreakBefore/>" end
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
local SINGLE = 276   -- exact single line (13.8 pt), as the typst single-leading
local DOUBLE = 480   -- exact double line (24 pt pitch)

-- a blank line at the given exact pitch
local function blank(line)
  return p("", { style = "Single", line = line or SINGLE })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- a borderless fixed-width table; widths in twips; rows[r][c] = cell XML (paragraphs); borders[c] optional tcBorders
local function table_xml(widths, rows, borders)
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
      local tcb = (borders and borders[c]) or ""
      local tcmar = (borders and borders[c]) and '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>' or ""
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/>' .. tcb .. tcmar .. '</w:tcPr>' .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

local RULE = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

-- ---------------------------------------------------------------------------
-- Cover (Fed. R. Civ. P. 10(a)); caption widths: party column 3.25 in, gutter 0.25 in (the right cell's 0.35 in indent)
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  out[#out + 1] = p("UNITED STATES DISTRICT COURT", { style = "Centered", rpr = BOLD })
  out[#out + 1] = p("WESTERN DISTRICT OF MICHIGAN", { style = "Centered", rpr = BOLD })
  if meta.division ~= nil and text(meta.division) ~= "" then
    out[#out + 1] = p(string.upper(text(meta.division)), { style = "Centered", rpr = BOLD })
  end
  out[#out + 1] = blank(DOUBLE)

  local cn = text(meta.case_number)
  if cn == "" then cn = "__________________" end
  local hon = text(meta.judge)
  if hon == "" then hon = "__________________" end

  local left = {}
  local parties = need(meta, "caption").parties
  for k, side in ipairs(parties) do
    if k > 1 then left[#left + 1] = p("v.", { style = "Single" }) end
    for _, n in ipairs(strings(side.names)) do left[#left + 1] = p(n, { style = "Single" }) end
    left[#left + 1] = p(text(side.designation), { style = "Single" })
  end
  local right = {
    p("Case No. " .. cn, { style = "Single", ind = 504 }),
    p("Hon. " .. hon, { style = "Single", ind = 504 }),
    blank(DOUBLE),
    p(text(meta.title), { style = "Single", ind = 504, rpr = BOLD, line = DOUBLE }),
  }
  out[#out + 1] = table_xml({ 4680, 4680 }, { { table.concat(left), table.concat(right) } }, { RULE, nil })
  out[#out + 1] = blank(DOUBLE)
  out[#out + 1] = blank(DOUBLE)

  for k, g in ipairs(need(meta, "counsel")) do
    if k > 1 then out[#out + 1] = blank(SINGLE) end
    for _, n in ipairs(strings(g.names)) do out[#out + 1] = p(n, { style = "Single" }) end
    for _, n in ipairs(strings(g.lines)) do out[#out + 1] = p(n, { style = "Single" }) end
  end
  return out
end

-- Page 2: title centered bold, then the lead-in (unnumbered, first-line indent).
local function opening(meta)
  local out = { p(text(meta.title), { style = "Centered", rpr = BOLD, line = DOUBLE, pageBreak = true }) }
  out[#out + 1] = p("", { style = "Centered", line = DOUBLE })
  if meta.lead_in ~= nil then out[#out + 1] = p(text(meta.lead_in), { style = "BodyText" }) end
  return out
end

-- Signature block (Fed. R. Civ. P. 11(a); LCivR 10.3): "Dated" at left, the signer's block at right.
local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function signature(meta)
  local sig = need(meta, "signature")
  local left = p("Dated: " .. text(meta.date), { style = "Single", keepNext = true })
  local right = {}
  right[#right + 1] = p("Respectfully submitted,", { style = "Single", ind = 288, keepNext = true })
  right[#right + 1] = blank(SINGLE)
  for _, n in ipairs(strings(sig.firm)) do right[#right + 1] = p(n, { style = "Single", ind = 288, keepNext = true }) end
  right[#right + 1] = blank(SINGLE)
  right[#right + 1] = p("By: /s/ " .. text(sig.signer), { style = "Single", ind = 288, keepNext = true })
  local lines = strings(sig.lines)
  for k, n in ipairs(lines) do
    right[#right + 1] = p(n, { style = "Single", ind = 288, keepNext = k < #lines })
  end
  return { raw(table_xml({ 3744, 5616 }, { { left, table.concat(right) } })) }
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

function Pandoc(doc)
  local meta = doc.meta
  local stop_at = meta.numbering_stops_at and text(meta.numbering_stops_at) or nil
  local numbering = true
  local n = 0
  local body = {}

  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if stop_at ~= nil and text(pandoc.Plain(b.content)) == stop_at then numbering = false end
      body[#body + 1] = b
    elseif b.t == "Para" then
      if numbering then
        n = n + 1
        local inl = { pandoc.Str(tostring(n) .. "."), TAB }
        for _, i in ipairs(b.content) do inl[#inl + 1] = i end
        body[#body + 1] = pandoc.Para(inl)
      else
        body[#body + 1] = b
      end
    elseif b.t == "OrderedList" then
      -- lettered A., B., ... (the template letters the request for relief; the sample's numbers are not used)
      for k, item in ipairs(b.content) do
        local first = item[1]
        local content = {}
        if first and (first.t == "Plain" or first.t == "Para") then content = first.content end
        local inl = { pandoc.Str(string.sub(LETTERS, k, k) .. "."), TAB }
        for _, i in ipairs(content) do inl[#inl + 1] = i end
        body[#body + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "List Letter" }))
      end
    else
      body[#body + 1] = b
    end
  end

  local blocks = {}
  for _, x in ipairs(cover(meta)) do blocks[#blocks + 1] = raw(x) end
  for _, x in ipairs(opening(meta)) do blocks[#blocks + 1] = raw(x) end
  for _, b in ipairs(body) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  -- the title and date of the metadata are printed by the cover above, not as a pandoc title block
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
