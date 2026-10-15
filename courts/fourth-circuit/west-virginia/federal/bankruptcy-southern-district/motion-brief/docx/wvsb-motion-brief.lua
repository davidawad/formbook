-- Motion with its supporting argument, United States Bankruptcy Court, S.D. West Virginia (wvsb), DOCX engine.
-- Markdown contract -> Word on docx/reference.docx, mirroring typst/wvsb-motion-brief.typ: court title, the
-- two-column caption (a borderless table whose left cell carries the right and bottom rules), the document title,
-- the body (headings: level 1 centred in capitals and unnumbered; levels 2 to 4 labelled A., 1., a. by this filter,
-- hanging at the margin), the WHEREFORE clause kept with the signature, the signature block (the date and the
-- counsel blocks side by side), and the certificate of service on a new page when the sample gives one.
-- Every paragraph takes a style from reference.docx. Nothing here is case-specific.
-- Known differences: the caption's rules are paragraph borders (see wvsb-adversary-complaint.lua); the heading
-- labels are text, not Word list numbering; the lettered items are text with the label typed in.

local function empty(v)
  return v == nil or pandoc.utils.stringify(v) == ""
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- metadata (markdown inlines in the YAML) -> Inlines
local function inl(v)
  local out = pandoc.Inlines({})
  if v == nil then return out end
  if type(v) == "string" then
    out:insert(pandoc.Str(v))
  elseif v.t == "MetaInlines" then
    for _, x in ipairs(v) do out:insert(x) end
  else
    out:insert(pandoc.Str(pandoc.utils.stringify(v)))
  end
  return out
end

local function join(...)
  local out = pandoc.Inlines({})
  for _, part in ipairs({ ... }) do
    for _, x in ipairs(part) do out:insert(x) end
  end
  return out
end

local function text(s)
  return pandoc.Inlines({ pandoc.Str(s) })
end

local function list(v)
  local out = {}
  if v == nil then return out end
  for _, x in ipairs(v) do out[#out + 1] = x end
  return out
end

local function upper(inls)
  return pandoc.Inlines(inls):walk({
    Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end,
  })
end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- an empty paragraph of a given exact height (the typst v(...) gaps)
local function gap(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr></w:p>')
end

-- Borderless table (style "Table" in reference.docx). widths in twips; rows: list of lists of blocks.
local function table_of(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local colspecs = {}
  for i, w in ipairs(widths) do colspecs[i] = { pandoc.AlignDefault, w / total } end
  local body = {}
  for _, r in ipairs(rows) do
    local cells = {}
    for _, blocks in ipairs(r) do cells[#cells + 1] = pandoc.Cell(blocks) end
    body[#body + 1] = pandoc.Row(cells)
  end
  return pandoc.Table(pandoc.Caption(), colspecs, pandoc.TableHead(), { pandoc.TableBody(body) }, pandoc.TableFoot())
end

-- ---------------------------------------------------------------------------
-- Front matter (typst: court, caption, title)
-- ---------------------------------------------------------------------------

local CAP_L, CAP_R = 4680, 4680

local function court_title(meta)
  local blocks = {}
  for _, line in ipairs(list(meta.court)) do
    blocks[#blocks + 1] = styled("Centered", inl(line))
  end
  return blocks
end

-- caption side: the names, the "v." separator, the designation (with the caption footnote, if any)
local function caption_left(sides)
  local out = {}
  for i, side in ipairs(sides) do
    if not empty(side.sep) then
      out[#out + 1] = gap("CaptionGap")
      out[#out + 1] = styled("CaptionIndent12", inl(side.sep))
      out[#out + 1] = gap("CaptionGap")
    elseif i > 1 then
      out[#out + 1] = gap("CaptionGap")
    end
    for _, n in ipairs(list(side.names)) do
      out[#out + 1] = styled("CaptionLeft", inl(n))
    end
    local d = inl(side.designation)
    if not empty(side.footnote) then
      d:insert(pandoc.Note({ pandoc.Para(inl(side.footnote)) }))
    end
    out[#out + 1] = styled("CaptionIndent18", d)
  end
  out[#out + 1] = gap("CaptionEnd")
  return out
end

local function caption(meta)
  local right = {}
  for _, line in ipairs(list(meta.case_info)) do
    right[#right + 1] = styled("CaptionRight", inl(line))
  end
  return table_of({ CAP_L, CAP_R }, { { caption_left(list(meta.caption)), right } })
end

-- ---------------------------------------------------------------------------
-- Signature block (typst: the WHEREFORE clause, the date and preamble, then one column per counsel block)
-- ---------------------------------------------------------------------------

local function signature_block(sig, closing)
  local out = {}
  if closing then
    out[#out + 1] = styled("BodyKeep", inl(closing))
    out[#out + 1] = gap("GapKeep12")
  end
  if not empty(sig.dated) or #list(sig.preamble) > 0 then
    local left = {}
    if not empty(sig.dated) then
      left[#left + 1] = styled("SingleKeep", join(text("Dated: "), inl(sig.dated)))
    else
      left[#left + 1] = styled("SingleKeep", text(""))
    end
    local right = {}
    for _, l in ipairs(list(sig.preamble)) do
      right[#right + 1] = styled("SingleKeep", inl(l))
    end
    if #right == 0 then right[1] = styled("SingleKeep", text("")) end
    out[#out + 1] = table_of({ 4752, 4608 }, { { left, right } })
    out[#out + 1] = gap("GapKeep12")
  end
  -- counsel blocks: one column each, 0.3 in gutters
  local blocks = list(sig.blocks)
  local widths, row = {}, {}
  local n = #blocks
  local colw = math.floor((9360 - 432 * (n - 1)) / n)
  for i, blk in ipairs(blocks) do
    local paras = {}
    for _, l in ipairs(list(blk)) do paras[#paras + 1] = styled("SingleKeep", inl(l)) end
    row[#row + 1] = paras
    widths[#widths + 1] = colw
    if i < n then
      widths[#widths + 1] = 432
      row[#row + 1] = { styled("SingleKeep", text("")) }
    end
  end
  if n > 0 then out[#out + 1] = table_of(widths, { row }) end
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- ordered lists become paragraphs with the label typed in (no Word list numbering), so a list inside a block quote
-- reads as the sample does: "(1) ...", "(A) ...", "(i) ...", "a. ..."
local function roman(n, upper)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return upper and s:upper() or s
end

local function list_label(a, k)
  local num
  if a.style == "LowerAlpha" then num = string.char(96 + k)
  elseif a.style == "UpperAlpha" then num = string.char(64 + k)
  elseif a.style == "LowerRoman" then num = roman(k, false)
  elseif a.style == "UpperRoman" then num = roman(k, true)
  else num = tostring(k) end
  if a.delimiter == "TwoParens" then return "(" .. num .. ")"
  elseif a.delimiter == "OneParen" then return num .. ")"
  else return num .. "." end
end

local function flatten(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local label = list_label(b.listAttributes, b.listAttributes.start + i - 1)
        for k, blk in ipairs(item) do
          if k == 1 and (blk.t == "Para" or blk.t == "Plain") then
            out[#out + 1] = pandoc.Para(join(text(label), pandoc.Inlines({ pandoc.Space() }), blk.content))
          else
            for _, x in ipairs(flatten({ blk })) do out[#out + 1] = x end
          end
        end
      end
    elseif b.t == "BlockQuote" then
      b.content = flatten(b.content)
      out[#out + 1] = b
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- heading labels: level 2 "A.", level 3 "1.", level 4 "a." (typst heading-num); a higher level resets the deeper ones
local LABEL = {
  [2] = function(k) return string.char(64 + k) .. "." end,
  [3] = function(k) return tostring(k) .. "." end,
  [4] = function(k) return string.char(96 + k) .. "." end,
}

local function number_headings(blocks)
  local count = { 0, 0, 0, 0, 0 }
  local function walk(bs)
    for _, b in ipairs(bs) do
      if b.t == "Header" then
        count[b.level] = count[b.level] + 1
        for l = b.level + 1, 5 do count[l] = 0 end
        if b.level == 1 then
          b.content = upper(b.content)
        elseif LABEL[b.level] then
          local content = pandoc.Inlines({ pandoc.Str(LABEL[b.level](count[b.level])), TAB })
          for _, x in ipairs(b.content) do content:insert(x) end
          b.content = content
        end
      end
    end
  end
  walk(blocks)
  return blocks
end

function Pandoc(doc)
  local meta = doc.meta
  local body = number_headings(flatten(doc.blocks))

  local out = {}
  for _, b in ipairs(court_title(meta)) do out[#out + 1] = b end
  out[#out + 1] = gap("Gap24")
  out[#out + 1] = caption(meta)
  out[#out + 1] = gap("Gap24")
  out[#out + 1] = pandoc.Div({ pandoc.Para(upper(inl(meta.title))) },
    pandoc.Attr("", {}, { ["custom-style"] = "DocTitle" }))
  out[#out + 1] = gap("Gap12")
  for _, b in ipairs(body) do out[#out + 1] = b end

  out[#out + 1] = gap("GapKeep24")
  for _, b in ipairs(signature_block(meta.signature, meta.closing and pandoc.utils.stringify(meta.closing) ~= "" and inl(meta.closing) or nil)) do
    out[#out + 1] = b
  end

  -- certificate of service, when the sample gives one (LR 9013-1(a)(3)): a new page
  if meta.certificate then
    local c = meta.certificate
    out[#out + 1] = pandoc.Div({ pandoc.Para(upper(text("Certificate of Service"))) },
      pandoc.Attr("", {}, { ["custom-style"] = "CertTitle" }))
    out[#out + 1] = gap("Gap12")
    out[#out + 1] = pandoc.Para(inl(c.text))
    out[#out + 1] = gap("GapKeep24")
    for _, b in ipairs(signature_block(c, nil)) do out[#out + 1] = b end
  end

  doc.blocks = out
  -- the title and metadata are printed above by this filter, not by pandoc
  doc.meta.title = nil
  doc.meta.subtitle = nil
  doc.meta.author = nil
  doc.meta.date = nil
  return doc
end
