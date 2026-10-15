-- W.D. Wis. bankruptcy adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document
-- on reference.docx. Mirrors typst/wiwb-adversary-complaint.typ: the cover (court name, caption table with a right
-- and bottom rule on the party column, title), the numbered allegations (Fed. R. Civ. P. 10(b)), the lettered prayer
-- items, the WHEREFORE paragraph unnumbered, and the signature block in a borderless table that may not break.
-- Every case word comes from the sample's frontmatter. The court name and "Respectfully submitted," are the
-- template's, as in the typst form. No table of contents, table of authorities or certificate: the typst form has none.
-- Known differences and unverified items: see README.md, "## Engines".

local COURT_NAME = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF WISCONSIN" }

-- widths in twips (1 in = 1440)
local CAPTION_LEFT = 4896 -- 3.4 in: the party column
local GUTTER = 360        -- 0.25 in
local CAPTION_RIGHT = 4104
local SIG_LEFT = 4896     -- 3.4 in: the date column
local SIG_RIGHT = 4464    -- 3.1 in: the signature column

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- a metadata value as a list of inlines (markdown emphasis kept)
local function inl(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return v
end

local function run(text, f)
  f = f or {}
  local props = (f.b and "<w:b/>" or "") .. (f.i and "<w:i/>" or "")
  return '<w:r><w:rPr>' .. props .. '</w:rPr><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- inlines -> WordprocessingML runs; emphasis and strong are kept, other inlines as plain text
local function runs(inls, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, { b = f.b, i = true })
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = f.i })
    elseif t == "Quoted" then
      local q = el.quotetype == "SingleQuote" and { "\u{2018}", "\u{2019}" } or { "\u{201C}", "\u{201D}" }
      out[#out + 1] = run(q[1], f) .. runs(el.content, f) .. run(q[2], f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

-- paragraph XML: the style, then the direct spacing/indent/justification (in schema order)
local function para(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. '</w:pPr>' .. (inner or "") .. '</w:p>'
end

local function sp(before, after)
  local a = {}
  if before then a[#a + 1] = 'w:before="' .. before .. '"' end
  if after then a[#a + 1] = 'w:after="' .. after .. '"' end
  return '<w:spacing ' .. table.concat(a, " ") .. '/>'
end

local function cell(w, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or "") .. '</w:tcPr>' .. paras .. '</w:tc>'
end

local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. rows .. '</w:tbl>'
end

local function row(cells, cant_split)
  return '<w:tr><w:trPr>' .. (cant_split and "<w:cantSplit/>" or "") .. '</w:trPr>' .. table.concat(cells) .. '</w:tr>'
end

local function attr(style)
  return pandoc.Attr("", {}, { ["custom-style"] = style })
end

local function underscores(n)
  return string.rep("_", n)
end

-- cover: court name, caption (In re block and party column; the adversary number at the right), title
local function cover(meta)
  local out = {}
  out[#out + 1] = para("Centered", run(COURT_NAME[1], { b = true }))
  out[#out + 1] = para("Centered", run(COURT_NAME[2], { b = true }), sp(0, 360))

  local left = {}
  left[#left + 1] = para("Single", run("In re:"))
  left[#left + 1] = para("Single", runs(inl(meta.debtor)))
  left[#left + 1] = para("Single", run("Case No. " .. plain(meta.bankruptcy_case)))
  if meta.chapter then left[#left + 1] = para("Single", run("Chapter " .. plain(meta.chapter))) end
  if meta.caption then
    for i, side in ipairs(meta.caption) do
      for j, n in ipairs(side.names or {}) do
        left[#left + 1] = para("Single", runs(inl(n)), (i == 1 and j == 1) and sp(288) or nil)
      end
      left[#left + 1] = para("Single", runs(inl(side.designation)),
        sp(120) .. '<w:ind w:left="0" w:right="576" w:firstLine="0"/><w:jc w:val="right"/>')
      if i < #meta.caption then
        left[#left + 1] = para("Single", run("v."), sp(192, 192) .. '<w:jc w:val="left"/>')
      end
    end
  end
  local left_cell = cell(CAPTION_LEFT, table.concat(left),
    '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
      .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
      .. '<w:tcMar><w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>')

  local value
  if meta.adversary_case and plain(meta.adversary_case) ~= "" then
    value = runs(inl(meta.adversary_case))
  else
    value = run(underscores(19))
  end
  local right = {}
  if meta.caption then
    right[1] = para("Single", run("Adversary Case No.", { b = true }) .. run("  ") .. value, sp(48))
  else
    right[1] = para("Single", "")
  end
  local right_cell = cell(CAPTION_RIGHT, table.concat(right))

  local gutter_cell = cell(GUTTER, para("Single", ""))
  out[#out + 1] = table_xml({ CAPTION_LEFT, GUTTER, CAPTION_RIGHT },
    row({ left_cell, gutter_cell, right_cell }, true))

  out[#out + 1] = para("Centered", run(plain(meta.title):upper(), { b = true }), sp(360, 360))
  return table.concat(out)
end

-- signature block (Fed. R. Bankr. P. 9011): the date at the left, the firm, "Respectfully submitted," and the
-- /s/ line, the signer and the lines at the right. The block does not break across pages.
local function signature(meta)
  local sig = meta.signature
  if not sig then return "" end
  local left = meta.date and para("Single", runs(inl(meta.date)), sp(648)) or para("Single", "", sp(648))
  local r = {}
  if sig.firm then
    r[#r + 1] = para("Single", run(plain(sig.firm), { b = true }), sp(648))
    r[#r + 1] = para("Single", run("Respectfully submitted,"), sp(120, 648))
  else
    r[#r + 1] = para("Single", run("Respectfully submitted,"), sp(648, 648))
  end
  r[#r + 1] = para("Single", run("/s/ " .. underscores(26)))
  r[#r + 1] = para("Single", runs(inl(sig.signer)), sp(48))
  for _, line in ipairs(sig.lines or {}) do
    r[#r + 1] = para("Single", runs(inl(line)))
  end
  local rows = row({ cell(SIG_LEFT, left), cell(SIG_RIGHT, table.concat(r)) }, true)
  return table_xml({ SIG_LEFT, SIG_RIGHT }, rows) .. para("Single", "")
end

local function letter(k)
  if k <= 26 then return "(" .. string.char(96 + k) .. ")" end
  return "(" .. k .. ")"
end

local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  add(pandoc.RawBlock("openxml", cover(meta)))

  -- allegations: each plain paragraph is numbered, the WHEREFORE paragraph is not; a list is the prayer (a), (b), ...
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      if pandoc.utils.stringify(b.content):match("^WHEREFORE") then
        add(pandoc.Div({ b }, attr("FirstParagraph")))
      else
        n = n + 1
        local c = pandoc.List({ pandoc.Str(n .. "."), tab() })
        c:extend(b.content)
        add(pandoc.Div({ pandoc.Para(c) }, attr("Numbered")))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local first = item[1]
        local lead = pandoc.List({ pandoc.Str(letter(k)), tab() })
        local rest = pandoc.List({})
        for i = 2, #item do rest:insert(item[i]) end
        if first and (first.t == "Para" or first.t == "Plain") then
          lead:extend(first.content)
          local blocks = pandoc.List({ pandoc.Para(lead) })
          blocks:extend(rest)
          add(pandoc.Div(blocks, attr("ListItem")))
        else
          add(pandoc.Div({ pandoc.Para(lead) }, attr("ListItem")))
          for _, r in ipairs(item) do add(r) end
        end
      end
    else
      add(b)
    end
  end

  add(pandoc.RawBlock("openxml", signature(meta)))
  -- pandoc would print the title and date metadata above the cover; the cover and signature carry them already
  for _, k in ipairs({ "title", "subtitle", "author", "date", "abstract" }) do doc.meta[k] = nil end
  doc.blocks = out
  return doc
end
