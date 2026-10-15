-- D. Vt. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/vtd-complaint.typ: the caption (a table: parties closed by a rule at the right and the bottom;
-- the case number, the title and the jury legend at the right), then the body. Body paragraphs are numbered
-- 1, 2, ... (Fed. R. Civ. P. 10(b)) by this filter, not by Word numbering; a paragraph whose text starts with
-- "~ " is unnumbered (the WHEREFORE clause); a list is lettered A., B., ... (the prayer). Headings are the
-- Heading 1-3 styles of reference.docx. The signature block is kept on one page (keepNext in SigBlock).
-- Only the caption table is raw OpenXML (a table border cannot be expressed in the pandoc AST).

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, rpr)
  return "<w:r>" .. (rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or "")
    .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function p_xml(style, runs, ppr)
  return ('<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>"
    .. (runs or "") .. "</w:p>")
end

local function raw_para(style, runs, ppr)
  return pandoc.RawBlock("openxml", p_xml(style, runs, ppr))
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function parties_cells(meta)
  local left = {}
  local function line(text, rpr)
    left[#left + 1] = p_xml("Single", text ~= "" and run(text, rpr) or nil)
  end
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = p_xml("Blank")
      line("v.")
      left[#left + 1] = p_xml("Blank")
    end
    for _, n in ipairs(p.names) do line(plain(n)) end
    left[#left + 1] = p_xml("Blank")
    line(plain(p.designation))
  end
  return table.concat(left)
end

-- The caption: 3.1 in party column (right and bottom rule, 12 pt right inset, 10 pt bottom inset), 0.25 in gutter,
-- 3.15 in right column (0.15 in left inset). Widths in twips: 4464, 360, 4536.
local function caption_table(meta)
  local label = meta.case_label and plain(meta.case_label) or "Civil Action No."
  local right = p_xml("Single", run(label .. " " .. plain(meta.case_number)))
    .. p_xml("CaptionTitle", run(plain(meta.brief_title), "<w:b/><w:bCs/>"), '<w:spacing w:before="351"/>')
  if meta.jury_demand then
    right = right .. p_xml("CaptionTitle", run("JURY TRIAL DEMANDED", "<w:b/><w:bCs/>"), '<w:spacing w:before="130"/>')
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4464"/><w:gridCol w:w="360"/><w:gridCol w:w="4536"/></w:tblGrid>'
    .. '<w:tr><w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/>' .. rule
    .. '<w:tcMar><w:right w:w="240" w:type="dxa"/><w:bottom w:w="200" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. parties_cells(meta) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4536" w:type="dxa"/><w:tcMar><w:left w:w="216" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. right .. '</w:tc></w:tr></w:tbl>'
  return pandoc.RawBlock("openxml", xml)
end

local function signature(sig, out)
  local function add(b) out[#out + 1] = b end
  if sig.date_line then add(styled("SigDate", { pandoc.Para(sig.date_line) })) end
  if sig.by then
    add(pandoc.RawBlock("openxml", p_xml("SigBlock", run("By: /s/ " .. plain(sig.by)), '<w:spacing w:before="351"/>')))
  end
  for _, b in ipairs(sig.blocks or {}) do
    add(pandoc.RawBlock("openxml", p_xml("Blank")))
    for _, l in ipairs(b) do add(styled("SigBlock", { pandoc.Para(l) })) end
  end
  if sig.counsel_for then
    add(pandoc.RawBlock("openxml", p_xml("Blank")))
    add(styled("SigEnd", { pandoc.Para(sig.counsel_for) }))
  end
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court title (two bold lines), gap, caption, gap (no separate cover page)
  add(raw_para("Centered", run("UNITED STATES DISTRICT COURT", "<w:b/><w:bCs/>")))
  add(raw_para("Centered", run("FOR THE DISTRICT OF VERMONT", "<w:b/><w:bCs/>")))
  add(raw_para("Gap"))
  add(caption_table(meta))
  add(raw_para("Gap"))

  -- body
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" and b.content[1] and b.content[1].t == "Str" and b.content[1].text == "~" then
      -- unnumbered paragraph: drop the "~" marker and the space after it
      local rest = { table.unpack(b.content, 3) }
      add(pandoc.Para(rest))
    elseif b.t == "Para" then
      n = n + 1
      add(styled("NumPara", { pandoc.Para({
        pandoc.RawInline("openxml", run(tostring(n) .. ".")),
        pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"),
        table.unpack(b.content),
      }) }))
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local letter = string.char(64 + i) .. "."
        local first = item[1]
        local inl = (first and (first.t == "Para" or first.t == "Plain")) and first.content or pandoc.List({})
        add(styled("Prayer", { pandoc.Para({
          pandoc.RawInline("openxml", run(letter)),
          pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"),
          table.unpack(inl),
        }) }))
        for j = 2, #item do add(item[j]) end
      end
    else
      add(b)
    end
  end

  signature(meta.signature or {}, out)
  doc.blocks = out
  return doc
end
