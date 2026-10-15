-- prd-complaint.lua (docx engine, D.P.R. complaint). What the Word output adds to pandoc's default conversion,
-- so that the .docx reads as typst/prd-complaint.typ does (see ../README.md, "Engines"):
--   * the cover from the sample's YAML frontmatter: court title, caption table (parties with rules, case
--     number and title), the lead-in; the signature block as a borderless table. Pandoc's own title block is dropped;
--   * numbered allegations (Fed. R. Civ. P. 10(b)): each body paragraph that is not a heading, a list or the
--     WHEREFORE line gets its number at 0.5 inch, text after a tab (style "Allegation");
--   * the prayer's lettered items (A., B., ...) as hanging paragraphs (style "PrayerItem").
-- Raw Word XML is written for the tables and cover paragraphs (pandoc has no per-cell borders).

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, flags)
  local rpr = ""
  if flags.b then rpr = rpr .. "<w:b/><w:bCs/>" end
  if flags.i then rpr = rpr .. "<w:i/><w:iCs/>" end
  if flags.caps then rpr = rpr .. "<w:caps/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- Inline content (pandoc AST) to Word runs; emphasis and strong carried as flags.
local function runs(inls, flags)
  flags = flags or {}
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, flags)
    elseif t == "Space" or t == "SoftBreak" then out[#out + 1] = run(" ", flags)
    elseif t == "LineBreak" then out[#out + 1] = '<w:r><w:br/></w:r>'
    elseif t == "Emph" then
      local f = { b = flags.b, i = true, caps = flags.caps }
      out[#out + 1] = runs(el.content, f)
    elseif t == "Strong" then
      local f = { b = true, i = flags.i, caps = flags.caps }
      out[#out + 1] = runs(el.content, f)
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], flags) .. runs(el.content, flags) .. run(q[2], flags)
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(el.content, flags)
    elseif t == "Code" then out[#out + 1] = run(el.text, flags)
    else out[#out + 1] = run(pandoc.utils.stringify(el), flags)
    end
  end
  return table.concat(out)
end

-- A frontmatter value as inline content. YAML strings are markdown (pandoc parses them into MetaInlines).
local function inlines_of(v)
  if v == nil then return {} end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaString" then return pandoc.utils.blocks_to_inlines(pandoc.read(v, "markdown").blocks) end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function para(style, inner, ppr_extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or "") .. '</w:pPr>' .. inner .. '</w:p>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local BORDER_NONE = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function cell(width, content, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. (mar or "")
    .. '<w:vAlign w:val="top"/></w:tcPr>' .. content .. '</w:tc>'
end

local function table_xml(widths, rows)
  local grid = {}
  local total = 0
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'; total = total + w end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' .. BORDER_NONE
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(rows) .. '</w:tr></w:tbl>'
end

local RULE = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

-- Caption (PRD-CAP-002): parties left with a rule on the right and bottom; case number and title right.
local function caption_xml(meta)
  local left = {}
  for i, side in ipairs(meta.caption or {}) do
    for _, n in ipairs(side.names) do
      left[#left + 1] = para("Single", runs(inlines_of(n)))
    end
    left[#left + 1] = para("Single", runs(inlines_of(side.designation)), '<w:ind w:left="2016"/>')
    if i < #meta.caption then
      left[#left + 1] = para("Single", run("v.", {}), '<w:spacing w:before="120" w:after="120"/><w:jc w:val="center"/>')
    end
  end
  local right = {}
  right[#right + 1] = para("Single", run("No. " .. pandoc.utils.stringify(meta.case_number), {}))
  right[#right + 1] = para("Single", "", '<w:spacing w:before="240" w:after="0"/>')
  right[#right + 1] = para("Single", runs(inlines_of(meta.brief_title), { b = true, caps = true }))
  if meta.jury_demand then
    right[#right + 1] = para("Single", run("JURY TRIAL DEMANDED", { b = true }), '<w:spacing w:before="240" w:after="0"/>')
  end
  return table_xml({ 4896, 360, 4104 }, {
    cell(4896, table.concat(left), RULE, '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="240" w:type="dxa"/></w:tcMar>'),
    cell(360, para("Single", "")),
    cell(4104, table.concat(right), nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'),
  })
end

local function signature_xml(meta)
  local sig = meta.signature
  local groups = {}
  for _, g in ipairs(sig.groups) do
    local ps = {}
    local k = 0
    if g.signer then
      ps[#ps + 1] = para("SigGroup", run("By: s/ " .. pandoc.utils.stringify(g.signer), {}))
      ps[#ps + 1] = para("Single", run(pandoc.utils.stringify(g.signer), {}))
    end
    for _, l in ipairs(g.lines or {}) do
      k = k + 1
      local st = (k == 1 and not g.signer) and "SigGroup" or "Single"
      ps[#ps + 1] = para(st, runs(inlines_of(l)))
    end
    groups[#groups + 1] = table.concat(ps)
  end
  local right = para("Single", run("Respectfully submitted,", {})) .. table.concat(groups)
  local left = para("Single", run("Dated: " .. pandoc.utils.stringify(meta.date), {}))
  return raw(para("Spacer", "") .. table_xml({ 4752, 4608 }, {
    cell(4752, left),
    cell(4608, right),
  }))
end

local function is_wherefore(el)
  return el.t == "Para" and pandoc.utils.stringify(el):sub(1, 9) == "WHEREFORE"
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court title (PRD-CAP-001), then the caption
  for _, l in ipairs({ "UNITED STATES DISTRICT COURT", "DISTRICT OF PUERTO RICO" }) do
    add(raw(para("CourtTitle", run(l, { b = true }))))
  end
  add(raw(para("Spacer", "")))
  add(raw(caption_xml(meta)))
  add(raw(para("Spacer", "")))
  if meta.lead_in then
    add(pandoc.Para(inlines_of(meta.lead_in)))
  end

  -- body: numbered allegations, lettered prayer items
  local n = 0
  for _, el in ipairs(doc.blocks) do
    if el.t == "Para" and not is_wherefore(el) then
      n = n + 1
      local content = { pandoc.Str(tostring(n) .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
      for _, c in ipairs(el.content) do content[#content + 1] = c end
      add(pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "Allegation" }))
    elseif el.t == "OrderedList" then
      for i, item in ipairs(el.content) do
        local letter = string.char(64 + i) .. "."
        local first = item[1]
        if first and first.t == "Para" or (first and first.t == "Plain") then
          local content = { pandoc.Str(letter), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') }
          for _, c in ipairs(first.content) do content[#content + 1] = c end
          add(pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = "PrayerItem" }))
          for j = 2, #item do add(item[j]) end
        else
          for _, b in ipairs(item) do add(b) end
        end
      end
    else
      add(el)
    end
  end

  -- signature block (PRD-SIG-001)
  add(signature_xml(meta))

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
