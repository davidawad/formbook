-- Motion brief in an adversary proceeding, D. Del. Bankr. (typst: deb-motion-brief.typ), DOCX engine (docs/DOCX.md).
-- Builds from the sample's frontmatter what the typst template builds: the cover (court line, Form 416 caption,
-- title, party designation, and the date and counsel at the foot of the page, LR 7007-2(a)(i)), the table of
-- contents (a TOC field with its entries cached; page numbers appear after the field is updated), a page break
-- before the body, and the signature block. The body is the markdown on reference.docx (build-reference.sh).
-- Limits: see ../README.md, "Engines".

local TEXT_W = 9360        -- 6.5 in, twips
local CAP_LEFT = 4896      -- 3.4 in: caption-left
local COUNSEL_W = 4752     -- 3.3 in: counsel column of the cover
local DATED_W = TEXT_W - COUNSEL_W
local SIG_LEFT = 3456      -- 2.4 in: signature column
local GUTTER = 288         -- 0.2 in: column-gutter
local INSET = 216          -- 0.15 in: caption right-column inset
local PAGE_BREAK = '<w:r><w:br w:type="page"/></w:r>'

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
local function lines(list, style, last, ppr)
  local out = {}
  for k, inls in ipairs(list) do
    out[#out + 1] = p(style, runs(inls), (k == #list and last) or ppr)
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

local function inlines_of(v)
  local t = {}
  for _, e in ipairs(v or {}) do t[#t + 1] = e end
  return t
end

-- cover foot (LR 7007-2(a)(i)): the date and the counsel block sit on the bottom margin, as in the typst
-- template (v(1fr)); they are two frames anchored to the bottom of the text area.
local function cover_foot(m)
  local dated = p("Single", run("Dated: ", {}) .. runs(inlines_of(m.date)),
    '<w:framePr w:w="' .. DATED_W .. '" w:wrap="around" w:vAnchor="margin" w:hAnchor="margin" w:xAlign="left" w:yAlign="bottom"/>')
  local counsel = {}
  for _, inls in ipairs(m.counsel) do
    counsel[#counsel + 1] = p("Single", runs(inlines_of(inls)),
      '<w:framePr w:w="' .. COUNSEL_W .. '" w:wrap="around" w:vAnchor="margin" w:hAnchor="margin" w:xAlign="right" w:yAlign="bottom"/>')
  end
  return dated .. table.concat(counsel)
end

-- signature block (typst: signature-block): date and place left; firms and attorneys right; one row
local function signature(m)
  local sig = m.signature
  local left = p("Single", run("Dated: ", {}) .. runs(inlines_of(m.date))) .. p("Single", runs(inlines_of(sig.place)))
  local right = {}
  for _, b in ipairs(sig.blocks) do
    right[#right + 1] = lines(b.firm, "Single", '<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/>')
    right[#right + 1] = lines(b.attorneys, "Single", '<w:spacing w:before="0" w:after="480" w:line="240" w:lineRule="auto"/>')
  end
  return row_table({ SIG_LEFT, TEXT_W - SIG_LEFT }, {
    cell(SIG_LEFT, left),
    cell(TEXT_W - SIG_LEFT, table.concat(right), '<w:tcMar><w:left w:w="' .. GUTTER .. '" w:type="dxa"/></w:tcMar>'),
  })
end

-- table of contents: a TOC field over levels 1 and 2 (LR 7007-2(b)(i)(A)), entries cached in the field
local function toc(blocks)
  local entries = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= 2 then entries[#entries + 1] = b end
  end
  local out = {}
  out[#out + 1] = p("Centered", PAGE_BREAK .. run("TABLE OF CONTENTS", { b = true }))
  out[#out + 1] = spacer()
  for k, h in ipairs(entries) do
    local ppr = h.level == 2 and '<w:ind w:left="720" w:hanging="720" w:firstLine="0"/>' or '<w:ind w:firstLine="0"/>'
    local inner = runs(h.content)
    if k == 1 then
      inner = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' .. inner
    end
    if k == #entries then inner = inner .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    out[#out + 1] = p("Single", inner, '<w:spacing w:before="0" w:after="200" w:line="240" w:lineRule="auto"/>' .. ppr)
  end
  return table.concat(out)
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
  add(pandoc.RawBlock("openxml", p("Centered", runs(inlines_of(m.party_designation)))))
  add(pandoc.RawBlock("openxml", cover_foot(m)))
  add(pandoc.RawBlock("openxml", toc(doc.blocks)))
  -- the body starts on a new page (the TOC ends the page before it)
  local body = doc.blocks
  if body[1] and body[1].t == "Header" then
    table.insert(body[1].content, 1, pandoc.RawInline("openxml", PAGE_BREAK))
  end
  for _, b in ipairs(body) do add(b) end
  add(pandoc.RawBlock("openxml", spacer()))
  add(pandoc.RawBlock("openxml", signature(m)))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
