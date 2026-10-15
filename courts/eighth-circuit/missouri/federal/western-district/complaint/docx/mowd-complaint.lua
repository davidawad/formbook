-- W.D. Mo. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The same content and numbering as typst/mowd-complaint.typ, from the same markdown contract:
--   cover (court title, caption table, title, jury legend), numbered paragraphs (1., 2., ...), headings,
--   block quotations, lettered lists (A., B., ...), the unnumbered WHEREFORE lead-in, and the signature block.
-- Paragraphs are pandoc Divs with the custom styles defined in reference.docx (build-reference.sh), so the
-- inline markdown (italics, quotes) stays pandoc's. Numbers are literal text, as in the typst template.
-- Known gaps (see ../README.md "Engines"): no footnotes (the template has none either).

local BODY_NUMBER_TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')

local function styled(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

local function para(name, inlines)
  return styled(name, { pandoc.Para(inlines) })
end

-- An empty paragraph in a style (pandoc drops empty paragraphs in a Div, so the spacers are written here).
local function spacer(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

-- A metadata value as inlines (YAML strings are parsed as markdown by pandoc).
local function inlines_of(v)
  if v == nil then return pandoc.Inlines({}) end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" and v[1] and v[1].t == "Para" then return v[1].content end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

-- A table with no borders: one row per list of cells, each cell a list of blocks.
local function borderless_table(widths, rows)
  local specs = {}
  for i, w in ipairs(widths) do specs[i] = { pandoc.AlignDefault, w } end
  local body = {}
  for _, r in ipairs(rows) do
    local cells = {}
    for _, c in ipairs(r) do cells[#cells + 1] = pandoc.Cell(c) end
    body[#body + 1] = pandoc.Row(cells)
  end
  return pandoc.Table(pandoc.Caption(), specs, pandoc.TableHead(), { pandoc.TableBody(body) }, pandoc.TableFoot())
end

local LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function cover(m, out)
  out[#out + 1] = para("MowdCourtTitle", { pandoc.Str("UNITED STATES DISTRICT COURT") })
  out[#out + 1] = para("MowdCourtTitleLast", { pandoc.Str("FOR THE WESTERN DISTRICT OF MISSOURI") })

  -- Caption: parties left, "v." between the sides; case number, title and jury legend right.
  local left = {}
  for k, p in ipairs(m.caption.parties) do
    if k > 1 then left[#left + 1] = para("MowdCaptionLine", { pandoc.Str("v.") }) end
    for _, n in ipairs(p.names) do
      left[#left + 1] = para("MowdCaptionLine", inlines_of(n))
    end
    left[#left + 1] = para("MowdCaptionLine", inlines_of(p.designation))
  end
  local right = {
    para("MowdCaptionRight", { pandoc.Str("Case No. " .. pandoc.utils.stringify(m.case_number)) }),
    para("MowdCaptionTitle", { pandoc.Strong(inlines_of(m.title)) }),
  }
  if pandoc.utils.stringify(m.jury_demand) == "true" then
    right[#right + 1] = para("MowdCaptionJury", { pandoc.Strong({ pandoc.Str("JURY TRIAL DEMANDED") }) })
  end
  out[#out + 1] = borderless_table({ 3.25, 0.25, 3.0 }, { { left, {}, right } })
  out[#out + 1] = spacer("MowdGap")
end

-- The signature block is one table row that may not break across pages (the typst block is unbreakable),
-- which a pandoc table cannot say; so it is written as WordprocessingML with w:cantSplit.
local function xml_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function xml_para(style, text, bold)
  local rpr = bold and "<w:rPr><w:b/></w:rPr>" or ""
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr><w:r>' .. rpr ..
    '<w:t xml:space="preserve">' .. xml_escape(text) .. "</w:t></w:r></w:p>"
end

local function signature(m, out)
  local sig = m.signature
  local right = xml_para("MowdSigRespect", "Respectfully submitted,", false) ..
    xml_para("MowdSigSigner", pandoc.utils.stringify(sig.signer), true)
  for _, firm in ipairs(sig.blocks) do
    for i, line in ipairs(firm) do
      local name = (i == #firm) and "MowdSigFirmEnd" or "MowdSigLine"
      right = right .. xml_para(name, pandoc.utils.stringify(line), false)
    end
  end
  out[#out + 1] = pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="MowdSpacerKeep"/></w:pPr></w:p>')
  local left = xml_para("MowdDated", "Dated: " .. pandoc.utils.stringify(sig.date), false)
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:tbl><w:tblPr><w:tblStyle w:val="Table"/><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="3744"/><w:gridCol w:w="288"/><w:gridCol w:w="5328"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/></w:tcPr>' .. left .. '</w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc>' ..
    '<w:tc><w:tcPr><w:tcW w:w="5328" w:type="dxa"/></w:tcPr>' .. right .. '</w:tc>' ..
    '</w:tr></w:tbl>')
  -- Word needs a paragraph after a table at the end of the body.
  out[#out + 1] = spacer("MowdGap")
end

local HEADING_STYLE = { [1] = "MowdHeadingCaps", [2] = "MowdHeadingCenter", [3] = "MowdHeadingLeft" }

-- The last paragraph keeps with the signature block: a signature alone on a page is a defect.
local KEEP_NEXT = { MowdBodyNumbered = true, MowdBodyPara = true }
local function keep_with_next(blocks)
  local last = blocks[#blocks]
  if last ~= nil and last.t == "Div" then
    local name = last.attr.attributes["custom-style"]
    if KEEP_NEXT[name] then blocks[#blocks] = styled(name .. "Keep", last.content) end
  end
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  cover(m, out)

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local style = HEADING_STYLE[b.level]
      if style == nil then error("mowd-complaint: heading level " .. b.level .. " has no style") end
      out[#out + 1] = para(style, b.content)
    elseif b.t == "BlockQuote" then
      for _, q in ipairs(b.content) do
        if q.t ~= "Para" then error("mowd-complaint: a block quotation holds only paragraphs") end
        out[#out + 1] = para("MowdBlockQuote", q.content)
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        if first == nil or (first.t ~= "Plain" and first.t ~= "Para") or #item > 1 then
          error("mowd-complaint: a list item holds one paragraph")
        end
        local marker
        if b.t == "OrderedList" then
          if i > #LETTERS then error("mowd-complaint: more than 26 list items") end
          marker = LETTERS:sub(i, i) .. "."
        else
          marker = "•"
        end
        local inl = pandoc.Inlines({ pandoc.Str(marker), BODY_NUMBER_TAB })
        inl:extend(first.content)
        out[#out + 1] = para("MowdListItem", inl)
      end
    elseif b.t == "Para" then
      local text = pandoc.utils.stringify(b)
      if text:sub(1, 9) == "WHEREFORE" then
        out[#out + 1] = para("MowdBodyPlain", b.content)
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(tostring(n) .. "."), BODY_NUMBER_TAB })
        inl:extend(b.content)
        out[#out + 1] = para("MowdBodyNumbered", inl)
      end
    else
      error("mowd-complaint: unsupported block " .. b.t)
    end
  end

  keep_with_next(out)
  signature(m, out)
  -- The title is printed by the cover, not by pandoc's title block.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
