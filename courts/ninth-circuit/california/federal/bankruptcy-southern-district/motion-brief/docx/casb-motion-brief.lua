-- Motion with points and authorities, U.S. Bankruptcy Court, Southern District of California (casb), DOCX engine
-- (docs/DOCX.md). Mirrors typst/casb-motion-brief.typ: counsel block (single, from line 1), court title, caption
-- table (party column ruled on the right and bottom), the "TO:" line, the body with first-line indents (no
-- numbered paragraphs), headings numbered as in the typst template (I., II. for level 2; A., B. for level 3),
-- block quotations single spaced and indented, and the date and signature block. Everything case-specific comes
-- from the sample's frontmatter, never from this file. Tables of contents and authorities (toc: true) are not
-- built by this engine: the filter stops with an error rather than leave them out.

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, rpr)
  if text == nil or text == "" then return "" end
  local pr = (rpr ~= nil and rpr ~= "") and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return '<w:r>' .. pr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- pandoc inlines to runs; italic and bold are kept (the frontmatter is markdown, as in the typst template)
local function runs(inls, rpr)
  rpr = rpr or ""
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, rpr)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then out[#out + 1] = run(" ", rpr)
    elseif t == "Emph" then out[#out + 1] = runs(el.content, rpr .. "<w:i/><w:iCs/>")
    elseif t == "Strong" then out[#out + 1] = runs(el.content, rpr .. "<w:b/><w:bCs/>")
    elseif t == "Span" or t == "Link" then out[#out + 1] = runs(el.content, rpr)
    elseif t == "Quoted" then
      local q = (el.quotetype == "DoubleQuote") and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], rpr) .. runs(el.content, rpr) .. run(q[2], rpr)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), rpr)
    end
  end
  return table.concat(out)
end

-- a frontmatter value as a list of inlines
local function inls(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaInlines" then return v end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function plain(v) return pandoc.utils.stringify(inls(v)) end

local function para(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. (inner or "") .. '</w:p>'
end

local function sp(before, after, line)
  return '<w:spacing w:before="' .. before .. '" w:after="' .. after .. '" w:line="' .. line .. '" w:lineRule="exact"/>'
end

local function cell(w, inner, borders, mar)
  local b = borders and ('<w:tcBorders>' .. borders .. '</w:tcBorders>') or ''
  local m = mar and ('<w:tcMar>' .. mar .. '</w:tcMar>') or ''
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. b .. m .. '</w:tcPr>' .. inner .. '</w:tc>'
end

-- borderless layout table (caption and signature); widths in twips, 9000 = 6.25 in text width
local function layout_table(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>')
end

local function row(cells)
  return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

-- counsel block (single spaced, from line 1), padded to whole 24 pt lines, at least 7 of them
local function counsel(list)
  local out = {}
  local n = #list
  if n == 0 then return out end
  local target = math.max(7, math.ceil(n / 2)) * 480
  local pad = target - n * 240
  for i, l in ipairs(list) do
    out[#out + 1] = raw(para("Single", runs(inls(l)), sp(0, (i == n) and pad or 0, 240)))
  end
  return out
end

local function court_title()
  return {
    raw(para("Centered", run("UNITED STATES BANKRUPTCY COURT", "<w:b/><w:bCs/>"))),
    raw(para("Centered", run("SOUTHERN DISTRICT OF CALIFORNIA", "<w:b/><w:bCs/>"))),
  }
end

-- caption: the debtor ("In re") and the parties, left column ruled on the right and bottom; the case numbers,
-- the title, a hearing (when the frontmatter gives one) and the judge, right column (typst caption())
local function caption(meta)
  local left, right = {}, {}
  left[#left + 1] = para("Single", runs({ pandoc.Str("In re") }))
  for _, p in ipairs(meta.in_re) do
    for _, n in ipairs(p.names) do left[#left + 1] = para("Single", runs(inls(n))) end
    left[#left + 1] = para("Single", runs(inls(p.designation)))
  end
  left[#left + 1] = para("Single", "", sp(240, 0, 240))
  for k, p in ipairs(meta.caption) do
    if k > 1 then left[#left + 1] = para("Single", runs({ pandoc.Str("vs.") })) end
    for _, n in ipairs(p.names) do left[#left + 1] = para("Single", runs(inls(n))) end
    left[#left + 1] = para("Single", runs(inls(p.designation)))
  end
  local ind = '<w:ind w:left="144"/>'
  right[#right + 1] = para("Single", run("Case No. " .. plain(meta.case_number)), ind)
  right[#right + 1] = para("Single", run("Chapter " .. plain(meta.chapter)), ind)
  if meta.adv_number then
    right[#right + 1] = para("Single", run("Adv. Proc. No. " .. plain(meta.adv_number)), sp(240, 0, 240) .. ind)
  end
  right[#right + 1] = para("Single", runs(inls(meta.brief_title), "<w:b/><w:bCs/>"), sp(240, 0, 240) .. ind)
  if meta.hearing then
    for i, l in ipairs(meta.hearing) do
      right[#right + 1] = para("Single", runs(inls(l)), ((i == 1) and sp(240, 0, 240) or sp(0, 0, 240)) .. ind)
    end
  end
  if meta.judge then
    right[#right + 1] = para("Single", runs(inls(meta.judge)), sp(240, 0, 240) .. ind)
  end
  local rule = '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/>'
  local mar = '<w:bottom w:w="96" w:type="dxa"/><w:right w:w="144" w:type="dxa"/>'
  return layout_table({ 4608, 288, 4104 }, { row({
    cell(4608, table.concat(left), rule, mar),
    cell(288, para("Single", "")),
    cell(4104, table.concat(right)),
  }) })
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function signature(meta)
  local sig = meta.signature
  local left = para("Single", meta.date and run("Dated: " .. plain(meta.date)) or "")
  local right = para("Single", run("Respectfully submitted,"))
  for i, l in ipairs(sig.firm or {}) do
    right = right .. para("Single", runs(inls(l)), (i == 1) and sp(240, 0, 240) or "")
  end
  right = right .. para("Single", run("/s/ " .. plain(sig.signer)), sp(240, 0, 240))
  for _, l in ipairs(sig.lines or {}) do right = right .. para("Single", runs(inls(l))) end
  return layout_table({ 3744, 288, 4968 }, { row({
    cell(3744, left),
    cell(288, para("Single", "")),
    cell(4968, right),
  }) })
end

-- heading labels as in the typst template: level 2 "I.", "II.", ...; level 3 "A.", "B.", ... (reset per level 2)
local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "chapter", "counsel", "in_re", "caption", "brief_title", "footer_title", "signature", "date" }) do
    if meta[k] == nil then error("casb-motion-brief: missing frontmatter field `" .. k .. "`", 0) end
  end
  if meta.toc and pandoc.utils.stringify(meta.toc) == "true" then
    error("casb-motion-brief: toc: true is not built by the docx engine (docs/DOCX.md); use the typst engine", 0)
  end
  local out = {}
  local function add(b) out[#out + 1] = b end

  for _, b in ipairs(counsel(meta.counsel)) do add(b) end
  for _, b in ipairs(court_title()) do add(b) end
  add(raw(para("Normal", "")))
  add(caption(meta))
  if meta.lead_in then add(styled("LeadIn", { pandoc.Para(inls(meta.lead_in)) })) end

  local c2, c3 = 0, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 2 then
      c2 = c2 + 1; c3 = 0
      local inl = pandoc.List({ pandoc.Str(roman(c2) .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
      inl:extend(b.content)
      add(pandoc.Header(2, inl))
    elseif b.t == "Header" and b.level == 3 then
      c3 = c3 + 1
      local inl = pandoc.List({ pandoc.Str(string.char(64 + c3) .. "."), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
      inl:extend(b.content)
      add(pandoc.Header(3, inl))
    else
      add(b)
    end
  end

  add(signature(meta))

  doc.meta = {}
  doc.blocks = out
  return doc
end
