-- Adversary complaint, U.S. Bankruptcy Court, Southern District of California (casb), DOCX engine (docs/DOCX.md).
-- Mirrors typst/casb-adversary-complaint.typ: counsel block (single, from line 1), court title, caption table
-- (party column ruled on the right and bottom), title of the paper, lead-in, allegations numbered 1, 2, ... (Fed. R.
-- Civ. P. 10(b), applied by FRBP 7010), markdown lists lettered (a), (b), ..., the unnumbered closing, and the
-- date and signature block. Everything case-specific comes from the sample's frontmatter, never from this file.

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

-- counsel block (single spaced, from line 1). The block is padded to whole 24 pt lines, at least 7 of them,
-- as counsel-block() does in the typst template.
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

local function court_title(meta)
  local out = {
    raw(para("Centered", run("UNITED STATES BANKRUPTCY COURT", "<w:b/><w:bCs/>"))),
    raw(para("Centered", run("SOUTHERN DISTRICT OF CALIFORNIA", "<w:b/><w:bCs/>"))),
  }
  if meta.division then
    out[#out + 1] = raw(para("Centered", run(plain(meta.division):upper(), "<w:b/><w:bCs/>")))
  end
  return out
end

-- caption: the debtor ("In re") and the adversary parties, left column ruled on the right and bottom;
-- the case numbers and the title of the paper, right column (typst caption())
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

-- a numbered allegation (paragraph) or a lettered list item: the label, a tab, then the content
local function labelled(style, label, content)
  local inl = pandoc.List({ pandoc.Str(label), pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') })
  inl:extend(content)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function signature(meta)
  local sig = meta.signature
  local left = para("Single", meta.date and run("Dated: " .. plain(meta.date)) or "")
  local right = ""
  right = right .. para("Single", run("Respectfully submitted,"))
  for i, l in ipairs(sig.firm or {}) do
    right = right .. para("Single", runs(inls(l)), (i == 1) and sp(240, 0, 240) or "")
  end
  right = right .. para("Single", run("By: /s/ " .. plain(sig.signer)), sp(240, 0, 240))
  right = right .. para("Single", run(plain(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do right = right .. para("Single", runs(inls(l))) end
  return layout_table({ 3744, 288, 4968 }, { row({
    cell(3744, left),
    cell(288, para("Single", "")),
    cell(4968, right),
  }) })
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "chapter", "counsel", "in_re", "caption", "brief_title", "footer_title", "signature", "date" }) do
    if meta[k] == nil then error("casb-adversary-complaint: missing frontmatter field `" .. k .. "`", 0) end
  end
  local out = {}
  local function add(b) out[#out + 1] = b end

  for _, b in ipairs(counsel(meta.counsel)) do add(b) end
  for _, b in ipairs(court_title(meta)) do add(b) end
  add(raw(para("Normal", "")))
  add(caption(meta))
  if meta.lead_in then add(styled("LeadIn", { pandoc.Para(inls(meta.lead_in)) })) end

  -- the body: a paragraph is an allegation (numbered); a heading stays unnumbered; a list is lettered
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      add(labelled("Allegation", n .. ".", b.content))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local label = (b.t == "OrderedList") and ("(" .. string.char(96 + i) .. ")") or "\u{2022}"
        local first = true
        for _, blk in ipairs(item) do
          if first and (blk.t == "Para" or blk.t == "Plain") then
            add(labelled("ListItem", label, blk.content))
          else
            add(styled("ListItem", { blk }))
          end
          first = false
        end
      end
    else
      add(b)
    end
  end

  if meta.closing then add(styled("LeadIn", { pandoc.Para(inls(meta.closing)) })) end
  add(signature(meta))

  doc.meta = {}
  doc.blocks = out
  return doc
end
