-- Adversary complaint, D. Del. Bankr. (typst: deb-adversary-complaint.typ), DOCX engine (docs/DOCX.md).
-- Builds from the sample's frontmatter what the typst template builds: the court line, the Form 416 caption
-- (two bordered tables), the title, the numbered allegations (FRCP 10(b), one number per body paragraph), the
-- unnumbered prayer and its lettered items, the italic bracketed notes, and the signature block. Page setup,
-- fonts and styles come from reference.docx (build-reference.sh). Limits: see ../README.md, "Engines".

local TEXT_W = 9360        -- 6.5 in, twips
local CAP_LEFT = 4896      -- 3.4 in: caption-left
local SIG_LEFT = 3744      -- 2.6 in: signature column
local GUTTER = 288         -- 0.2 in: column-gutter
local INSET = 216          -- 0.15 in: caption right-column inset

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- flags -> run properties, in schema order
local function rpr(f)
  local x = ""
  if f.b then x = x .. "<w:b/><w:bCs/>" end
  if f.i then x = x .. "<w:i/><w:iCs/>" end
  if f.sup then x = x .. '<w:vertAlign w:val="superscript"/>' end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function with(f, k)
  local g = {}
  for key, v in pairs(f) do g[key] = v end
  g[k] = true
  return g
end

local function run(text, f)
  return "<w:r>" .. rpr(f) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- markdown inlines (already parsed by pandoc) as Word runs, keeping italics and bold
local function runs(inls, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(inls or {}) do
    if el.t == "Str" then out[#out + 1] = run(el.text, f)
    elseif el.t == "Space" or el.t == "SoftBreak" then out[#out + 1] = run(" ", f)
    elseif el.t == "Emph" then out[#out + 1] = runs(el.content, with(f, "i"))
    elseif el.t == "Strong" then out[#out + 1] = runs(el.content, with(f, "b"))
    elseif el.t == "Superscript" then out[#out + 1] = runs(el.content, with(f, "sup"))
    elseif el.t == "Span" then out[#out + 1] = runs(el.content, f)
    else out[#out + 1] = run(pandoc.utils.stringify(el), f) end
  end
  return table.concat(out)
end

local function p(style, inner, ppr)
  return "<w:p><w:pPr>" .. (style and ('<w:pStyle w:val="' .. style .. '"/>') or "") .. (ppr or "") .. "</w:pPr>" .. inner .. "</w:p>"
end

-- one paragraph per line; `last` is the paragraph spacing given to the final line
local function lines(list, style, last)
  local out = {}
  for k, inls in ipairs(list) do
    out[#out + 1] = p(style, runs(inls), (k == #list and last) or nil)
  end
  return table.concat(out)
end

local function cell(w, xml, tcpr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (tcpr or "") .. "</w:tcPr>" .. xml .. "</w:tc>"
end

-- a borderless table with the given column widths and one row of cells
local function row_table(widths, cells)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local none = ""
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    none = none .. '<w:' .. side .. ' w:val="nil"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblBorders>' .. none
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid)
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

-- Form 416 caption block (LR 9004-1(a)): party names left, a rule on the right and bottom, numbers right
local function caption_block(c)
  local left = {}
  for k, party in ipairs(c.parties) do
    if k > 1 then left[#left + 1] = {} end
    for _, n in ipairs(party.names) do left[#left + 1] = n end
    if party.designation then left[#left + 1] = party.designation end
  end
  local right = {}
  for _, r in ipairs(c.right) do right[#right + 1] = r end
  local lborder = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
    .. '<w:tcMar><w:bottom w:w="160" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  local rmar = '<w:tcMar><w:left w:w="' .. (GUTTER + INSET) .. '" w:type="dxa"/></w:tcMar>'
  return row_table({ CAP_LEFT, TEXT_W - CAP_LEFT }, {
    cell(CAP_LEFT, lines(left, "Single"), lborder),
    cell(TEXT_W - CAP_LEFT, lines(right, "Single"), rmar),
  })
end

local function spacer()
  return p("BodyText", "")
end

-- signature block (typst: signature-block), one row that does not split across pages
local function signature(m, respectfully)
  local sig = m.signature
  local left = p("Single", run("Dated: ", {}) .. runs(m.date)) .. p("Single", runs(sig.place))
  local right = {}
  if respectfully then
    right[#right + 1] = p("Single", run("Respectfully submitted,", {}), '<w:spacing w:before="0" w:after="240"/>')
  end
  for _, b in ipairs(sig.blocks) do
    right[#right + 1] = lines(b.firm, "Single", '<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/>')
    right[#right + 1] = lines(b.attorneys, "Single", '<w:spacing w:before="0" w:after="480" w:line="240" w:lineRule="auto"/>')
  end
  return row_table({ SIG_LEFT, TEXT_W - SIG_LEFT }, {
    cell(SIG_LEFT, left),
    cell(TEXT_W - SIG_LEFT, table.concat(right), '<w:tcMar><w:left w:w="' .. GUTTER .. '" w:type="dxa"/></w:tcMar>'),
  })
end

local function inlines_of(v)
  local t = {}
  for _, e in ipairs(v or {}) do t[#t + 1] = e end
  return t
end

-- body: number the allegations; leave the prayer, lists and bracketed notes unnumbered
local function numbered(blocks)
  local out, n = {}, 0
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      local first = b.content[1]
      if first and first.t == "Emph" and pandoc.utils.stringify(first):sub(1, 1) == "[" then
        out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "CenteredBody" }))
      elseif pandoc.utils.stringify(b):match("^WHEREFORE") then
        out[#out + 1] = b
      else
        n = n + 1
        table.insert(b.content, 1, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
        table.insert(b.content, 1, pandoc.Str(n .. "."))
        out[#out + 1] = b
      end
    elseif b.t == "OrderedList" and b.listAttributes.style == "LowerAlpha" then
      -- lettered prayer items (a) b) ...) are plain indented lines, as in the typst template
      for i, item in ipairs(b.content) do
        local letter = string.char(96 + (b.listAttributes.start or 1) + i - 1) .. ")"
        local inls = { pandoc.Str(letter), pandoc.Space() }
        local blk = item[1]
        if blk and (blk.t == "Para" or blk.t == "Plain") then
          for _, e in ipairs(blk.content) do inls[#inls + 1] = e end
        end
        out[#out + 1] = pandoc.Para(inls)
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add(x) out[#out + 1] = x end
  add(pandoc.RawBlock("openxml", p("Centered", runs(inlines_of(m.court), { b = true }))))
  add(pandoc.RawBlock("openxml", spacer()))
  add(pandoc.RawBlock("openxml", caption_block(m.caption.bankruptcy)))
  add(pandoc.RawBlock("openxml", spacer()))
  add(pandoc.RawBlock("openxml", caption_block(m.caption.adversary)))
  add(pandoc.RawBlock("openxml", spacer()))
  add(pandoc.RawBlock("openxml", p("Centered", runs(inlines_of(m.title), { b = true }))))
  add(pandoc.RawBlock("openxml", spacer()))
  if m.preamble then add(pandoc.Para(inlines_of(m.preamble))) end
  for _, b in ipairs(numbered(doc.blocks)) do add(b) end
  add(pandoc.RawBlock("openxml", spacer()))
  add(pandoc.RawBlock("openxml", signature(m, true)))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
