-- ianb adversary complaint (docx engine): what the Word output adds to pandoc's default conversion, to match
-- ../typst/ianb-adversary-complaint.typ (the rules are in ../README.md):
--   * the caption (court name, party box, case numbers, title) and the signature block are built from the
--     YAML frontmatter as WordprocessingML tables, so no case text is in this file;
--   * body paragraphs are numbered here (1, 2, ...), with a tab to the Numbered Paragraph tab stop; the
--     paragraphs before the first heading and those beginning COMES NOW or WHEREFORE are not numbered;
--   * an ordered list (the prayer) is lettered (a), (b), ... as Prayer Item paragraphs;
--   * the metadata title is not written as a Title paragraph: the caption carries it.
-- The styles (Body Text, Numbered Paragraph, Prayer Item, Heading 1, Heading 2) are defined in docx/reference.docx.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function need(meta, key)
  local v = meta[key]
  assert(v ~= nil, "frontmatter field missing: " .. key)
  return pandoc.utils.stringify(v)
end

local function need_sig(sig, key)
  local v = sig[key]
  assert(v ~= nil, "frontmatter field missing: signature." .. key)
  return pandoc.utils.stringify(v)
end

-- One WordprocessingML paragraph. o: before/after (twips), ind (left, twips), jc, b (bold), i (italic), keep.
local function P(text, o)
  o = o or {}
  local ppr = (o.keep and "<w:keepNext/>" or "")
    .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="240" w:lineRule="auto"/>', o.before or 0, o.after or 0)
    .. (o.ind and string.format('<w:ind w:left="%d"/>', o.ind) or "")
    .. (o.jc and string.format('<w:jc w:val="%s"/>', o.jc) or "")
  local rpr = (o.b and "<w:b/><w:bCs/>" or "") .. (o.i and "<w:i/><w:iCs/>" or "")
  return string.format('<w:p><w:pPr>%s</w:pPr><w:r><w:rPr>%s</w:rPr><w:t xml:space="preserve">%s</w:t></w:r></w:p>', ppr, rpr, esc(text))
end

local function blank(twips)
  return string.format('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="%d" w:lineRule="exact"/></w:pPr></w:p>', twips)
end

-- A one-row table without borders; widths in twips; cells are {width=, tcpr=, xml=}.
local function table_row(cells)
  local grid, row, total = "", "", 0
  for _, c in ipairs(cells) do
    grid = grid .. string.format('<w:gridCol w:w="%d"/>', c.width)
    row = row .. string.format('<w:tc><w:tcPr><w:tcW w:w="%d" w:type="dxa"/>%s</w:tcPr>%s</w:tc>', c.width, c.tcpr or "", c.xml)
    total = total + c.width
  end
  return string.format(
    '<w:tbl><w:tblPr><w:tblW w:w="%d" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>%s</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>%s</w:tr></w:tbl>',
    total, grid, row)
end

-- Caption (FRBP 7010, 9004(b); the typst layout: 3.3 in party box with a right and bottom rule, 16 pt inset on the right).
local function caption(meta)
  local left = table.concat({
    P("In re:", { after = 156 }),
    P(need(meta, "debtor"), { ind = 720, after = 156 }),
    P("Debtor.", { jc = "right", after = 208 }),
    P(need(meta, "plaintiff"), { ind = 720, after = 156 }),
    P("Plaintiff,", { jc = "right", after = 156 }),
    P("v.", { ind = 720, after = 156 }),
    P(need(meta, "defendant"), { ind = 720, after = 156 }),
    P("Defendant.", { jc = "right" }),
  })
  local right = table.concat({
    P(need(meta, "chapter"), { after = 104 }),
    P(need(meta, "case_no"), { after = 416 }),
    P(meta.adversary_no and need(meta, "adversary_no") or "Adversary Case No. ____________", { after = 416 }),
    P(need(meta, "title"), { b = true }),
  })
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders><w:tcMar><w:right w:w="240" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/></w:tcMar>'
  local inset = '<w:tcMar><w:top w:w="520" w:type="dxa"/><w:left w:w="320" w:type="dxa"/></w:tcMar>'
  return table.concat({
    P("IN THE UNITED STATES BANKRUPTCY COURT", { jc = "center", b = true, after = 60 }),
    P("FOR THE NORTHERN DISTRICT OF IOWA", { jc = "center", b = true }),
    blank(390),
    table_row({
      { width = 4752, tcpr = rule, xml = left },
      { width = 4608, tcpr = inset, xml = right },
    }),
    blank(312),
  })
end

-- Signature block (FRBP 9011; N.D. Iowa L.R. 9010-1(b): address, telephone, FAX and e-mail below the signature).
local function signature(meta)
  local s = meta.signature
  assert(s ~= nil, "frontmatter field missing: signature")
  local lines = {
    P("Respectfully submitted,", { before = 468, after = 689 }),
    P("/s/ " .. need_sig(s, "signer"), { i = true, after = 65 }),
    P(need_sig(s, "signer") .. ", " .. need_sig(s, "bar"), { after = 65 }),
  }
  for _, l in ipairs(s.address) do
    lines[#lines + 1] = P(pandoc.utils.stringify(l), { after = 65 })
  end
  lines[#lines + 1] = P(need_sig(s, "firm"), { after = 65 })
  lines[#lines + 1] = P("Telephone: " .. need_sig(s, "phone"), { after = 65 })
  lines[#lines + 1] = P("Fax: " .. need_sig(s, "fax"), { after = 65 })
  lines[#lines + 1] = P("E-mail: " .. need_sig(s, "email"), { after = 325 })
  lines[#lines + 1] = P(need_sig(s, "role"))
  return table_row({
    { width = 3744, xml = P("Dated: " .. need_sig(s, "date"), { before = 468 }) },
    { width = 5616, xml = table.concat(lines) },
  })
end

local front = true
local number = 0

-- Body paragraphs: numbered unless before the first heading or beginning COMES NOW / WHEREFORE (typst rule).
local function numbered(para)
  local text = pandoc.utils.stringify(para)
  if front or text:match("^COMES NOW") or text:match("^WHEREFORE") then
    return para
  end
  number = number + 1
  table.insert(para.content, 1, TAB)
  table.insert(para.content, 1, pandoc.Str(number .. "."))
  return pandoc.Div({ para }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Paragraph" }))
end

-- Prayer items: an ordered list, lettered (a), (b), ... (typst lettered-list).
local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local first = item[1]
    assert(first.t == "Para" or first.t == "Plain", "prayer item must start with a paragraph")
    local para = pandoc.Para(first.content)
    table.insert(para.content, 1, TAB)
    table.insert(para.content, 1, pandoc.Str("(" .. string.char(96 + i) .. ")"))
    out[#out + 1] = pandoc.Div({ para }, pandoc.Attr("", {}, { ["custom-style"] = "Prayer Item" }))
    for k = 2, #item do out[#out + 1] = item[k] end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  -- FRBP 7008(a): the complaint must say whether the pleader consents to final orders or judgment.
  assert(pandoc.utils.stringify(pandoc.Div(doc.blocks)):find("consent", 1, true), "FRBP 7008(a): the complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court")
  doc:walk({ Note = function() error("footnotes are not supported in the adversary complaint template") end })
  local out = { pandoc.RawBlock("openxml", caption(meta)) }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      assert(b.level <= 2, "headings deeper than ## are not in the adversary complaint template")
      front = false
      out[#out + 1] = b
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = numbered(pandoc.Para(b.content))
    elseif b.t == "OrderedList" then
      for _, x in ipairs(lettered(b)) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta))
  -- Word needs a paragraph after the last table of the body.
  out[#out + 1] = pandoc.RawBlock("openxml", blank(240))
  return pandoc.Pandoc(out)
end
