-- U.S. District Court, District of Montana: complaint, DOCX engine (docs/DOCX.md). Follows typst/mtd-complaint.typ:
-- counsel block (two columns), court title, caption table with a right and a bottom rule on the party cell,
-- numbered paragraphs (Fed. R. Civ. P. 10(b)), lettered prayer items (A., B., ...), unnumbered `%` paragraphs,
-- signature block. All measures are in reference.docx styles (EB Garamond 14 pt, exact 32 pt lines).
-- No case-specific text is in this file: everything comes from the frontmatter and the body of the sample.

local TEXTW = 9360 -- 6.5 in in twips
local TAB = '<w:r><w:tab/></w:r>'
local BR = '<w:r><w:br/></w:r>'

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function with(f, k)
  local g = {}
  for kk, vv in pairs(f or {}) do g[kk] = vv end
  g[k] = true
  return g
end

local function rpr(f)
  local x = ""
  if f and f.b then x = x .. "<w:b/><w:bCs/>" end
  if f and f.i then x = x .. "<w:i/><w:iCs/>" end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function run(text, f)
  return "<w:r>" .. rpr(f) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- metadata value -> list of inlines (markdown strings are parsed; MetaInlines are used as they are)
local function inlines(v)
  if v == nil then return {} end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" then return v end
  if ty == "Blocks" then return pandoc.utils.blocks_to_inlines(v) end
  if ty == "string" then
    local b = pandoc.read(v, "markdown+smart").blocks[1]
    if b and (b.t == "Para" or b.t == "Plain") then return b.content end
    return { pandoc.Str(v) }
  end
  if ty == "boolean" then return {} end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- inline list -> WordprocessingML runs (emphasis and strong kept; other inlines as text)
local function runs(list, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then
      out[#out + 1] = BR
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, with(f, "i"))
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, with(f, "b"))
    elseif t == "Quoted" then
      local q = (el.quotetype == "DoubleQuote") and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], f)
      out[#out + 1] = runs(el.content, f)
      out[#out + 1] = run(q[2], f)
    elseif t == "Link" or t == "Span" then
      out[#out + 1] = runs(el.content, f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

local function p(style, body, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. body .. "</w:p>"
end

-- an empty paragraph whose exact height is `twips` (640 = one double-spaced line, 320 = half of it)
local function spacer(twips)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function cell(w, content, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>" .. content .. "</w:tc>"
end

local function table_xml(grid, rows, cant_split)
  local g = {}
  for _, w in ipairs(grid) do g[#g + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local trs = {}
  for _, r in ipairs(rows) do
    trs[#trs + 1] = "<w:tr>" .. (cant_split and "<w:trPr><w:cantSplit/></w:trPr>" or "") .. r .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(g) .. "</w:tblGrid>"
    .. table.concat(trs) .. "</w:tbl>"
end

-- ---------------------------------------------------------------- cover (typst: cover(), counsel-block, caption-table)
local function counsel_block(meta)
  local groups = meta.counsel
  local left, right = {}, {}
  for i, g in ipairs(groups) do
    local dst = (i == 1) and left or right
    if i > 2 then dst[#dst + 1] = spacer(152) end
    for _, line in ipairs(g) do
      dst[#dst + 1] = p("Single", runs(inlines(line)))
    end
  end
  -- two columns of 3.1 in with a 0.3 in gutter (the typst grid)
  return table_xml({ 4464, 432, 4464 }, {
    cell(4464, table.concat(left)) .. cell(432, p("Single", "")) .. cell(4464, table.concat(right)),
  }, true)
end

local function caption_block(meta, case_text)
  local sides = meta.caption
  local left = {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do
      left[#left + 1] = p("Single", runs(inlines(n)))
    end
    left[#left + 1] = spacer(152)
    left[#left + 1] = p("Single", runs(inlines(side.designation)), '<w:ind w:left="2016" w:firstLine="0"/>')
    if i < #sides then
      left[#left + 1] = spacer(152)
      left[#left + 1] = p("Single", run("v."))
      left[#left + 1] = spacer(152)
    end
  end
  local right = {
    p("Single", run(case_text)),
    spacer(792),
    p("Single", run(plain(meta.title):upper(), { b = true })),
  }
  local lborder = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local lmar = '<w:tcMar><w:bottom w:w="280" w:type="dxa"/><w:right w:w="280" w:type="dxa"/></w:tcMar>'
  local rmar = '<w:tcMar><w:top w:w="84" w:type="dxa"/><w:left w:w="336" w:type="dxa"/></w:tcMar>'
  return table_xml({ 4896, 4464 }, {
    cell(4896, table.concat(left), lborder .. lmar) .. cell(4464, table.concat(right), rmar),
  }, true)
end

local function cover(meta)
  local out = {}
  out[#out + 1] = raw(counsel_block(meta))
  out[#out + 1] = raw(spacer(152))
  out[#out + 1] = raw(p("Single", runs(inlines(meta.counsel_role), { i = true })))
  out[#out + 1] = raw(spacer(472))
  out[#out + 1] = raw(p("Centered", run("IN THE UNITED STATES DISTRICT COURT", { b = true })))
  out[#out + 1] = raw(p("Centered", run("FOR THE DISTRICT OF MONTANA", { b = true })))
  out[#out + 1] = raw(p("Centered", run(plain(meta.division):upper(), { b = true })))
  out[#out + 1] = raw(spacer(472))
  local case_no = plain(meta.case_number)
  if case_no == "" then case_no = "______________" else case_no = "Case No. " .. case_no end
  if plain(meta.case_number) == "" then case_no = "Case No. " .. case_no end
  out[#out + 1] = raw(caption_block(meta, case_no))
  return out
end

-- ---------------------------------------------------------------- body
local function letter(i)
  return string.char(64 + i)
end

local function label_para(label, content_blocks, style)
  -- the first paragraph of a block gets the label and a tab; the rest keep the style
  local blocks = content_blocks
  local first = blocks[1]
  if first and (first.t == "Para" or first.t == "Plain") then
    local inl = { pandoc.Str(label), pandoc.RawInline("openxml", TAB) }
    for _, el in ipairs(first.content) do inl[#inl + 1] = el end
    blocks[1] = pandoc.Para(inl)
  end
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function body_blocks(blocks)
  local out = {}
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      local first = b.content[1]
      if first and first.t == "Str" and first.text:sub(1, 1) == "%" then
        -- unnumbered paragraph (the prayer's lead-in, the jury demand): `%` is removed
        local content = {}
        local rest = first.text:sub(2)
        if rest ~= "" then content[#content + 1] = pandoc.Str(rest) end
        for i = 2, #b.content do content[#content + 1] = b.content[i] end
        out[#out + 1] = pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Unnumbered" }))
      else
        n = n + 1
        local inl = { pandoc.Str(n .. "."), pandoc.RawInline("openxml", TAB) }
        for _, el in ipairs(b.content) do inl[#inl + 1] = el end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "NumberedPara" }))
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = label_para(letter(i) .. ".", item, "ListLetter")
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        out[#out + 1] = label_para("\u{2022}", item, "ListLetter")
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- signature block (typst: signature-block): DATED on the left, firm, /s/ and printed name on the right
local function signature(meta)
  local sig = meta.signature
  local right = {}
  if sig.firm then right[#right + 1] = p("Single", runs(inlines(sig.firm), { b = true })) end
  right[#right + 1] = spacer(640)
  right[#right + 1] = p("Single", run("/s/ " .. plain(sig.signer)))
  right[#right + 1] = p("Single", runs(inlines(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p("Single", runs(inlines(l))) end
  local left = p("Single", run("DATED: " .. plain(meta.date)))
  return {
    raw(spacer(640)),
    raw(table_xml({ 4896, 4464 }, { cell(4896, left) .. cell(4464, table.concat(right)) }, true)),
  }
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "counsel", "counsel_role", "caption", "title", "division", "case_number", "signature", "date" }) do
    if meta[k] == nil then error("mtd-complaint: missing required metadata field `" .. k .. "`", 0) end
  end
  if meta.jury_demand == true then
    assert(plain(meta.title):upper():find("JURY TRIAL", 1, true), "mtd-complaint: L.R. 38.1: the title must indicate the jury demand")
  end
  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end
  -- the lead-in (not numbered) starts page 2 (typst: pagebreak() after the cover)
  if meta.lead_in then
    out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="BodyText"/><w:pageBreakBefore/><w:ind w:firstLine="720"/></w:pPr>'
      .. runs(inlines(meta.lead_in)) .. "</w:p>")
  else
    out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="BodyText"/><w:pageBreakBefore/></w:pPr></w:p>')
  end
  for _, b in ipairs(body_blocks(doc.blocks)) do out[#out + 1] = b end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  doc.blocks = out
  -- the title, date and author would be printed by pandoc's writer at the top of the page: drop them
  for _, k in ipairs({ "title", "subtitle", "author", "date", "abstract" }) do doc.meta[k] = nil end
  return doc
end
