-- arwb motion brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The layout is the one in typst/arwb-motion-brief.typ: the court title (bold), the caption (a borderless
-- two-column table: the debtor on the left, the case number and chapter on the right), the title of the paper,
-- the opening paragraph, the argument headings (numbered by the template from the heading level: I., A., 1., a.),
-- the body paragraphs, the lettered factor items, the signature block, and the certificate of service.
-- Every paragraph is set in a named style of reference.docx, and the gaps between blocks are the styles'
-- spacing; nothing here sets a line break or a position by hand.

-- A metadata value (inline or block markdown) as a list of inlines.
local function inlines_of(v)
  if v == nil then return pandoc.List({}) end
  local ty = pandoc.utils.type(v)
  if ty == "string" then return pandoc.List({ pandoc.Str(v) }) end
  if ty == "Inlines" then return pandoc.List(v) end
  if ty == "Blocks" then
    local out = pandoc.List({})
    for i, b in ipairs(v) do
      if i > 1 then out:insert(pandoc.Space()) end
      if b.content then out:extend(b.content) end
    end
    return out
  end
  error("arwb-motion-brief: unexpected metadata value of type " .. ty, 0)
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("arwb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

local function text_of(meta, key)
  return pandoc.utils.stringify(need(meta, key))
end

-- a block set in a named paragraph style of reference.docx
local function styled(name, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

local function para_in(name, inl)
  return styled(name, { pandoc.Para(inl) })
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- the numbers the template types for the argument headings: I., A., 1., a.
local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s
end

-- The cover: court title (bold), caption, title of the paper (typst cover()).
local function cover(meta, out)
  local courts = need(meta, "court")
  for i, l in ipairs(courts) do
    local inl = pandoc.List({ pandoc.Strong(inlines_of(l)) })
    out[#out + 1] = para_in(i == #courts and "Court Title Last" or "Court Title", inl)
  end

  local c = need(meta, "caption")
  local left = {}
  for _, n in ipairs(c.debtor.names) do left[#left + 1] = para_in("Caption", inlines_of(n)) end
  left[#left + 1] = para_in("Caption Indent", inlines_of(c.debtor.designation))

  local right = {
    para_in("Caption Right", { pandoc.Str("Case No: " .. text_of(meta, "case_number")) }),
    para_in("Caption Right", { pandoc.Str("Chapter " .. text_of(meta, "chapter")) }),
  }

  local row = pandoc.Row({ pandoc.Cell(left), pandoc.Cell(right) })
  -- the left column is 3.6 in; the right column is the rest of the 6.5 in text width, and its paragraphs are
  -- indented 0.2 in (the gutter, in the "Caption Right" style)
  out[#out + 1] = pandoc.Table(
    pandoc.Caption(),
    { { pandoc.AlignDefault, 3.6 / 6.5 }, { pandoc.AlignDefault, 2.9 / 6.5 } },
    pandoc.TableHead({}),
    { pandoc.TableBody({ row }) },
    pandoc.TableFoot({})
  )
  out[#out + 1] = para_in("Document Title", { pandoc.Str(text_of(meta, "brief_title")) })
end

-- The body (typst body-of()): headings numbered by level, a list chunk as lettered items, the rest as paragraphs.
-- With keep_last, the last paragraph keeps with the signature block after it.
local function body(blocks, out, keep_last)
  local c = { 0, 0, 0, 0 }
  for idx, b in ipairs(blocks) do
    if b.t == "Header" then
      local lv = b.level
      local label
      if lv == 2 then
        c[1] = c[1] + 1; c[2] = 0; c[3] = 0; c[4] = 0
        label = roman(c[1]) .. "."
      elseif lv == 3 then
        c[2] = c[2] + 1; c[3] = 0; c[4] = 0
        label = string.char(64 + c[2]) .. "."
      elseif lv == 4 then
        c[3] = c[3] + 1; c[4] = 0
        label = c[3] .. "."
      elseif lv == 5 then
        c[4] = c[4] + 1
        label = string.char(96 + c[4]) .. "."
      else
        error("arwb-motion-brief: heading level " .. lv .. " is not used by the template (use ## to #####)", 0)
      end
      local inl = pandoc.List({ pandoc.Str(label), TAB })
      inl:extend(b.content)
      out[#out + 1] = para_in("Argument Heading", inl)
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local label = pandoc.Str("(" .. (b.start + i - 1) .. ")")
        local first = item[1]
        local inl = pandoc.List({ label, TAB })
        if first and (first.t == "Plain" or first.t == "Para") then
          inl:extend(first.content)
        end
        out[#out + 1] = para_in("Factor Item", inl)
        for k = 2, #item do out[#out + 1] = item[k] end
      end
    elseif b.t == "Para" then
      local keep = keep_last and idx == #blocks
      out[#out + 1] = para_in(keep and "Body Text Keep" or "Body Text", b.content)
    else
      out[#out + 1] = b
    end
  end
end

-- The signature block (typst signature-block()): "Respectfully submitted," then the signer's lines, single
-- spaced at 3.25 in. The lines keep together.
local function signature(meta, out)
  local lines = need(meta, "signature")
  out[#out + 1] = para_in("Signature Lead", { pandoc.Str("Respectfully submitted,") })
  for i, l in ipairs(lines) do
    out[#out + 1] = para_in(i < #lines and "Signature Keep" or "Signature", inlines_of(l))
  end
end

-- The certificate of service (typst certificate()): a centred heading, the text, the recipients, the signer.
local function certificate(meta, out)
  local cos = meta.certificate_of_service
  if not cos then return end
  out[#out + 1] = para_in("Certificate Heading", { pandoc.Str("Certificate of Service") })
  -- the certificate is one block (typst certificate() is unbreakable): its text keeps with the recipients
  out[#out + 1] = para_in("Body Text Keep", inlines_of(cos.text))
  for _, r in ipairs(cos.recipients) do
    out[#out + 1] = para_in("Recipient", inlines_of(r))
  end
  local signer = cos.signer
  for i, l in ipairs(signer) do
    local style = i == 1 and "Signature Gap" or (i < #signer and "Signature Keep" or "Signature")
    out[#out + 1] = para_in(style, inlines_of(l))
  end
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}

  cover(meta, out)
  if meta.lead_in then
    out[#out + 1] = para_in("Body Text", inlines_of(meta.lead_in))
  end
  -- the conclusion keeps with the signature block when there is one
  body(doc.blocks, out, meta.signature ~= nil)
  signature(meta, out)
  certificate(meta, out)

  doc.blocks = out
  return doc
end
