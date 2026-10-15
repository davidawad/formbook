-- vaed complaint, DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/vaed-complaint.typ: court title, party-box caption (a table), the case number, the title,
-- the unnumbered lead-in, numbered allegations (Fed. R. Civ. P. 10(b)), lettered prayer items, the
-- signature block kept together. Every paragraph takes a style from reference.docx; nothing is case-specific here.
-- Known differences: the number-to-text gap is a tab stop at 1 in (typst: 0.25 in after the number).

local CFG = { numbered = true, sig_date_label = "Dated: ", underline_title = false, keep_last = false }

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a plain string as inlines, words separated by Space (no markdown parsing)
local function words(s)
  local out, first = {}, true
  for w in s:gmatch("%S+") do
    if not first then out[#out + 1] = pandoc.Space() end
    out[#out + 1] = pandoc.Str(w)
    first = false
  end
  return out
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function px(style_id, inner)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style_id .. '"/></w:pPr>' .. (inner or "") .. "</w:p>"
end

local function raw_para(style_id, inner)
  return pandoc.RawBlock("openxml", px(style_id, inner))
end

local function run(text)
  return '<w:r><w:t xml:space="preserve">' .. xesc(text) .. "</w:t></w:r>"
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- "I. Title" -> label, tab, title (label hangs in the margin, as in the typst template)
local function label_hang(inls)
  local first, second = inls[1], inls[2]
  if first and first.t == "Str" and second and second.t == "Space"
    and (first.text:match("^[IVX]+%.$") or first.text:match("^[A-Z]%.$") or first.text:match("^%d+%.$")) then
    local out = { pandoc.Str(first.text), TAB }
    for k = 3, #inls do out[#out + 1] = inls[k] end
    return out
  end
  return inls
end

local function upper_inlines(inls)
  return pandoc.walk_inline(pandoc.Span(inls), {
    Str = function(s) return pandoc.Str(string.upper(s.text)) end,
  }).content
end

-- the caption: party box (all four sides ruled) on the left, case number on the right
local function caption_table(caption)
  local bd = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:left w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  local left = {}
  local parties = caption.parties
  for i, p in ipairs(parties) do
    for _, line in ipairs(p.lines) do
      left[#left + 1] = px("Single", run(plain(line)))
    end
    if p.designation ~= nil then
      left[#left + 1] = px("CaptionDesignation", run(plain(p.designation)))
    end
    if i < #parties then
      left[#left + 1] = px("CaptionV", run("v."))
    end
  end
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="360"/><w:gridCol w:w="4248"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/><w:tcBorders>' .. bd .. '</w:tcBorders>'
    .. '<w:tcMar><w:top w:w="216" w:type="dxa"/><w:left w:w="216" w:type="dxa"/><w:bottom w:w="216" w:type="dxa"/><w:right w:w="216" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left)
    .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr></w:p></w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4248" w:type="dxa"/><w:vAlign w:val="center"/></w:tcPr>'
    .. px("Single", run(plain(caption.case_number)))
    .. '</w:tc></w:tr></w:tbl>'
  return pandoc.RawBlock("openxml", xml)
end

-- the signature block: the date line at the margin, the rest at 3.25 in; the last line ends the block
local function signature(sig, date_label)
  local out = {}
  if sig.date ~= nil then
    out[#out + 1] = styled("Sig Dated", words(date_label .. plain(sig.date)))
  end
  if sig.closing ~= nil then out[#out + 1] = styled("Sig Gap", words(plain(sig.closing))) end
  if sig.party ~= nil then out[#out + 1] = styled("Sig Gap", words(plain(sig.party))) end
  if sig.by ~= nil then out[#out + 1] = styled("Sig Gap", words(plain(sig.by))) end
  local lines = sig.lines or {}
  for i, l in ipairs(lines) do
    local style = (i == #lines) and "Sig Last" or "Sig Line"
    out[#out + 1] = styled(style, words(plain(l)))
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- court title, then the caption, then the title of the paper
  for _, line in ipairs(meta.court or {}) do
    add(styled("Court Title", words(plain(line))))
  end
  add(raw_para("Gap12"))
  add(caption_table(meta.caption))
  add(raw_para("Gap12"))
  local title = words(plain(meta.brief_title))
  if CFG.underline_title then title = { pandoc.Underline(title) } end
  add(styled("Caption Title", title))

  -- the unnumbered lead-in paragraph
  if meta.lead_in ~= nil then
    add(pandoc.Para(meta.lead_in))
  end

  -- the body: headings, numbered allegations, lettered prayer items, unnumbered (">") paragraphs
  local n = 0
  local blocks = doc.blocks
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        b.content = upper_inlines(b.content)
      else
        b.content = label_hang(b.content)
      end
      add(b)
    elseif b.t == "Para" and CFG.numbered then
      n = n + 1
      local inls = { pandoc.RawInline("openxml", run(tostring(n) .. ".")), TAB }
      for _, x in ipairs(b.content) do inls[#inls + 1] = x end
      add(pandoc.Div({ pandoc.Para(inls) }, pandoc.Attr("", {}, { ["custom-style"] = "Allegation" })))
    elseif b.t == "OrderedList" then
      for k, item in ipairs(b.content) do
        local first = item[1]
        local letter = string.char(64 + k) .. "."
        local inls = { pandoc.RawInline("openxml", run(letter)), TAB }
        for _, x in ipairs(first.content) do inls[#inls + 1] = x end
        add(pandoc.Div({ pandoc.Para(inls) }, pandoc.Attr("", {}, { ["custom-style"] = "Prayer Item" })))
      end
    elseif b.t == "BlockQuote" then
      for _, inner in ipairs(b.content) do
        add(inner)
      end
    else
      add(b)
    end
  end

  -- the signature block, kept together
  if meta.signature ~= nil then
    for _, b in ipairs(signature(meta.signature, CFG.sig_date_label)) do add(b) end
  end

  return pandoc.Pandoc(out, doc.meta)
end
