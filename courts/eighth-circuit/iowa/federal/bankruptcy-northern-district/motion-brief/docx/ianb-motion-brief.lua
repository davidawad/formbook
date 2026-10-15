-- ianb motion with memorandum (docx engine): what the Word output adds to pandoc's default conversion, to match
-- ../typst/ianb-motion-brief.typ (the rules are in ../README.md):
--   * the caption (court name, party box, case numbers, title), the signature block and the certificate of
--     service are built from the YAML frontmatter as WordprocessingML, so no case text is in this file;
--   * an ordered list (the numbered grounds or facts) is numbered here (1, 2, ...), restarting after each
--     heading, with a tab to the Numbered Paragraph tab stop; other paragraphs are unnumbered;
--   * "#" headings are centered and bold (Heading 1); "##" argument headings are bold and left (Heading 2);
--   * footnotes are pandoc's own (Footnote Text style, 11 pt single-spaced);
--   * the metadata title is not written as a Title paragraph: the caption carries it.
-- The styles (Body Text, Numbered Paragraph, Heading 1, Heading 2, Footnote Text) are in docx/reference.docx.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function need(meta, key)
  local v = meta[key]
  assert(v ~= nil, "frontmatter field missing: " .. key)
  return pandoc.utils.stringify(v)
end

local function need_in(map, name, key)
  local v = map and map[key]
  assert(v ~= nil, "frontmatter field missing: " .. name .. "." .. key)
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

-- Caption (FRBP 9004(b) and 7010; the typst layout: 3.3 in party box with a right and bottom rule).
-- A contested matter (no adversary_no) has the debtor block and the case number only.
local function caption(meta)
  local adv = meta.adversary_no ~= nil
  local left = {
    P("In re:", { after = 156 }),
    P(need(meta, "debtor"), { ind = 720, after = 156 }),
    P("Debtor.", { jc = "right", after = adv and 208 or 0 }),
  }
  if adv then
    local more = {
      P(need(meta, "plaintiff"), { ind = 720, after = 156 }),
      P("Plaintiff,", { jc = "right", after = 156 }),
      P("v.", { ind = 720, after = 156 }),
      P(need(meta, "defendant"), { ind = 720, after = 156 }),
      P("Defendant.", { jc = "right" }),
    }
    for _, x in ipairs(more) do left[#left + 1] = x end
  end
  local right = {
    P(need(meta, "chapter"), { after = 104 }),
    P(need(meta, "case_no"), { after = 416 }),
  }
  if adv then right[#right + 1] = P(need(meta, "adversary_no"), { after = 416 }) end
  right[#right + 1] = P(need(meta, "title"), { b = true })
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders><w:tcMar><w:right w:w="240" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/></w:tcMar>'
  local inset = '<w:tcMar><w:top w:w="520" w:type="dxa"/><w:left w:w="320" w:type="dxa"/></w:tcMar>'
  return table.concat({
    P("UNITED STATES BANKRUPTCY COURT", { jc = "center", b = true, after = 60 }),
    P("FOR THE NORTHERN DISTRICT OF IOWA", { jc = "center", b = true }),
    blank(390),
    table_row({
      { width = 4752, tcpr = rule, xml = table.concat(left) },
      { width = 4608, tcpr = inset, xml = table.concat(right) },
    }),
    blank(312),
  })
end

-- Signature block (FRBP 9011; N.D. Iowa L.R. 9010-1(b): address, telephone, FAX and e-mail below the signature).
-- "Dated" is left out when the frontmatter has no date (typst: `if "date" in s`).
local function signature(meta)
  local s = meta.signature
  assert(s ~= nil, "frontmatter field missing: signature")
  local lines = {
    P("Respectfully submitted,", { before = 468, after = 689 }),
    P("/s/ " .. need_in(s, "signature", "signer"), { i = true, after = 65 }),
    P(need_in(s, "signature", "signer") .. ", " .. need_in(s, "signature", "bar"), { after = 65 }),
  }
  for _, l in ipairs(s.address) do
    lines[#lines + 1] = P(pandoc.utils.stringify(l), { after = 65 })
  end
  lines[#lines + 1] = P(need_in(s, "signature", "firm"), { after = 65 })
  lines[#lines + 1] = P("Telephone: " .. need_in(s, "signature", "phone"), { after = 65 })
  lines[#lines + 1] = P("Fax: " .. need_in(s, "signature", "fax"), { after = 65 })
  lines[#lines + 1] = P("E-mail: " .. need_in(s, "signature", "email"), { after = 325 })
  lines[#lines + 1] = P(need_in(s, "signature", "role"))
  local dated = s.date ~= nil and P("Dated: " .. pandoc.utils.stringify(s.date), { before = 468 }) or P("", { before = 468 })
  return table_row({
    { width = 3744, xml = dated },
    { width = 5616, xml = table.concat(lines) },
  })
end

-- Certificate of service (FRBP 9013-3): the date and the manner of service must appear.
local function certificate(meta)
  local sv = meta.service
  assert(sv ~= nil, "frontmatter field missing: service")
  local date = need_in(sv, "service", "date")
  local manner = need_in(sv, "service", "manner")
  local by = need_in(sv, "service", "by")
  return table.concat({
    P("CERTIFICATE OF SERVICE", { jc = "center", b = true, before = 520, after = 156, keep = true }),
    string.format('<w:p><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="312" w:line="481" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr><w:r><w:t xml:space="preserve">%s</w:t></w:r></w:p>',
      esc("The undersigned certifies that on " .. date .. ", " .. manner .. ".")),
    P("/s/ " .. by, { i = true, jc = "right", after = 65, keep = true }),
    P(by, { jc = "right" }),
  })
end

-- Numbered grounds or facts: one number per list item, restarting after each heading (FRBP 9013(b)).
local number = 0

local function numbered(list)
  local out = {}
  for _, item in ipairs(list.content) do
    local first = item[1]
    assert(first.t == "Para" or first.t == "Plain", "numbered item must start with a paragraph")
    number = number + 1
    local para = pandoc.Para(first.content)
    table.insert(para.content, 1, TAB)
    table.insert(para.content, 1, pandoc.Str(number .. "."))
    out[#out + 1] = pandoc.Div({ para }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Paragraph" }))
    for k = 2, #item do out[#out + 1] = item[k] end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  -- FRBP 9013(b): a motion must set out the relief requested.
  local text = pandoc.utils.stringify(pandoc.Div(doc.blocks))
  assert(text:find("relief", 1, true) or text:find("request", 1, true), "FRBP 9013(b): the motion must set out the relief requested")
  local out = { pandoc.RawBlock("openxml", caption(meta)) }
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      assert(b.level <= 2, "headings deeper than ## are not in the motion template")
      number = 0
      out[#out + 1] = b
    elseif b.t == "OrderedList" then
      for _, x in ipairs(numbered(b)) do out[#out + 1] = x end
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta))
  out[#out + 1] = pandoc.RawBlock("openxml", certificate(meta))
  return pandoc.Pandoc(out)
end
