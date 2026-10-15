-- Complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on docx/reference.docx,
-- laid out to match complaint/typst/ilcd-complaint.typ (see ../README.md, "Engines").
-- Every case-specific word comes from the sample's frontmatter or body; no text, coordinate or forced
-- line break is written here. The cover and signature block are paragraphs in the custom styles of
-- reference.docx ("Centered", "Single", "Signature"); the caption is a borderless table with one row per
-- caption line, as in the typst grid. Paragraph numbers (Fed. R. Civ. P. 10(b)) and the lettered prayer
-- items (a), (b), ... are generated here, not typed in the sample.
-- Known limits (BLOCKED, see the README): the caption's ")" marks are one per caption line as written, not
-- one per line a long name wraps onto; the footer page number is a PAGE field.

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, fmt)
  return "<w:r>" .. (fmt ~= "" and ("<w:rPr>" .. fmt .. "</w:rPr>") or "")
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- inline content -> OpenXML runs (bold, italic, quotes; a link keeps its text, no hyperlink part is written)
local function runs(inl, fmt)
  fmt = fmt or ""
  local out = {}
  for _, x in ipairs(inl) do
    if x.t == "Str" then out[#out + 1] = run(x.text, fmt)
    elseif x.t == "Space" or x.t == "SoftBreak" then out[#out + 1] = run(" ", fmt)
    elseif x.t == "Emph" then out[#out + 1] = runs(x.content, fmt .. "<w:i/>")
    elseif x.t == "Strong" then out[#out + 1] = runs(x.content, fmt .. "<w:b/>")
    elseif x.t == "Link" or x.t == "Span" then out[#out + 1] = runs(x.content, fmt)
    elseif x.t == "Quoted" then
      local q = x.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], fmt) .. runs(x.content, fmt) .. run(q[2], fmt)
    else out[#out + 1] = run(pandoc.utils.stringify(x), fmt) end
  end
  return table.concat(out)
end

local function para_xml(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. inner .. '</w:p>'
end

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- one blank double-spaced line (typst "gap"), in the given style
local function gap(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. (style or "Single")
    .. '"/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:p>')
end

-- caption: party names, one ")" per caption line, the case number and the jury legend at the right
local COLS = { 4608, 432, 4320 } -- 3.2 in party column, 0.3 in ")" column, the rest of 6.5 in

local function cell(w, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or '') .. '</w:tcPr>' .. paras .. '</w:tc>'
end

local function caption_table(meta)
  local rows = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then rows[#rows + 1] = { text = pandoc.Inlines({ pandoc.Str("v.") }), indent = true } end
    for _, n in ipairs(p.names) do rows[#rows + 1] = { text = n } end
    rows[#rows + 1] = { text = p.designation, indent = true }
  end
  local trs = {}
  for k, r in ipairs(rows) do
    local c1 = para_xml("Single", runs(r.text), r.indent and '<w:ind w:left="1800"/>' or nil)
    local c2 = para_xml("Single", '<w:r><w:t>)</w:t></w:r>', '<w:jc w:val="right"/>')
    local c3
    if k == 1 then
      local case_p = para_xml("Single", run("Case No. " .. plain(meta.case_number), ""), '<w:ind w:left="216"/>')
      if meta.jury_demand then
        case_p = case_p .. para_xml("Single", run("Jury Trial Demanded", ""),
          '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="216"/>')
      end
      c3 = cell(COLS[3], case_p, '<w:vMerge w:val="restart"/><w:vAlign w:val="center"/>')
    else
      c3 = cell(COLS[3], para_xml("Single", ''), '<w:vMerge/>')
    end
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. cell(COLS[1], c1)
      .. cell(COLS[2], c2) .. c3 .. '</w:tr>'
  end
  local none = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>' .. none .. '</w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="432"/>'
    .. '<w:gridCol w:w="4320"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

local function drop_front(inl, k)
  local r = pandoc.List({})
  for i = k, #inl do r[#r + 1] = inl[i] end
  return r
end

local function letter(i)
  if i > 26 then error("ilcd-complaint: more than 26 lettered items in one list", 0) end
  return string.char(96 + i)
end

function Pandoc(doc)
  local meta = doc.meta
  if not meta.division then error("ilcd-complaint: LR 40.1(E)(1) requires the division in the caption (frontmatter: division)", 0) end
  if meta.jury_demand and not plain(meta.brief_title):lower():find("and demand for jury trial", 1, true) then
    error("ilcd-complaint: LR 38.1: a jury demand needs 'and demand for jury trial' in the title", 0)
  end

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover (the typst court title, caption, title)
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("UNITED STATES DISTRICT COURT") }) }))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("CENTRAL DISTRICT OF ILLINOIS") }) }))
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(plain(meta.division):upper()) }) }))
  add(gap())
  add(pandoc.RawBlock("openxml", caption_table(meta)))
  add(gap())
  add(styled("Centered", { pandoc.Strong({ pandoc.Str(plain(meta.brief_title):upper()) }) }))
  if meta.equitable_relief then
    add(styled("Centered", { pandoc.Strong({ pandoc.Str("EQUITABLE RELIEF IS SOUGHT") }) }))
  end
  add(gap())

  -- the unnumbered lead-in sentence, then the body
  if meta.lead_in then add(pandoc.Para(meta.lead_in)) end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      add(b)
    elseif b.t == "Para" then
      local content = b.content
      if content[1] and content[1].t == "Str" and content[1].text == "[unnumbered]" then
        content = drop_front(content, 2)
        if content[1] and content[1].t == "Space" then content = drop_front(content, 2) end
        add(pandoc.Para(content))
      else
        n = n + 1
        local c = pandoc.List({ pandoc.Str(tostring(n) .. "."), TAB })
        for _, x in ipairs(content) do c[#c + 1] = x end
        add(pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" })))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        if not first or (first.t ~= "Para" and first.t ~= "Plain") then
          error("ilcd-complaint: a list item must start with a paragraph", 0)
        end
        local c = pandoc.List({ pandoc.Str("(" .. letter(i) .. ")"), TAB })
        for _, x in ipairs(first.content) do c[#c + 1] = x end
        add(pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered" })))
        for k = 2, #item do add(item[k]) end
      end
    else
      add(b)
    end
  end

  -- signature block (LR 5.11(A)(2), LR 11.1): kept together
  add(gap("Signature"))
  add(styled("Signature", pandoc.Inlines({ pandoc.Str("Dated: " .. plain(meta.date)) })))
  add(gap("Signature"))
  add(styled("Signature", pandoc.Inlines({ pandoc.Str("Respectfully submitted,") })))
  for _, s in ipairs(meta.signature or {}) do
    add(gap("Signature"))
    add(styled("Signature", pandoc.Inlines({ pandoc.Str("/s/ " .. plain(s.signer)) })))
    for _, l in ipairs(s.lines or {}) do
      add(styled("Signature", l))
    end
  end

  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
