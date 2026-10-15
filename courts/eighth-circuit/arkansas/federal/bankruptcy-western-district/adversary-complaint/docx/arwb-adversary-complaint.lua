-- arwb adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The layout is the one in typst/arwb-adversary-complaint.typ: the court title, the caption (a borderless
-- two-column table: the debtor and parties on the left, the case numbers on the right), the title of the paper,
-- the numbered paragraphs, the centred section headings, the prayer, and the signature block. Every paragraph is
-- set in a named style of reference.docx, and the gaps between blocks are the styles' spacing; nothing here sets
-- a line break or a position by hand.
-- Numbers: the template numbers the body paragraphs 1, 2, ... (Fed. R. Civ. P. 10(b), via Rule 7010).

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
  error("arwb-adversary-complaint: unexpected metadata value of type " .. ty, 0)
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("arwb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
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

-- The cover: court title, caption, title of the paper (typst cover()).
local function cover(meta, out)
  local courts = need(meta, "court")
  for i, l in ipairs(courts) do
    out[#out + 1] = para_in(i == #courts and "Court Title Last" or "Court Title", inlines_of(l))
  end

  local c = need(meta, "caption")
  local left = {}
  left[#left + 1] = para_in("Caption", { pandoc.Str("In re:") })
  for _, n in ipairs(c.debtor.names) do left[#left + 1] = para_in("Caption", inlines_of(n)) end
  left[#left + 1] = para_in("Caption Indent", inlines_of(c.debtor.designation))
  for k, p in ipairs(c.parties) do
    for j, n in ipairs(p.names) do
      -- the first name of a party group sits half a line below the group before it
      left[#left + 1] = para_in(j == 1 and "Caption Gap" or "Caption", inlines_of(n))
    end
    left[#left + 1] = para_in("Caption Indent", inlines_of(p.designation))
    if k < #c.parties then
      left[#left + 1] = para_in("Caption Vee", { pandoc.Str("v.") })
    end
  end

  local right = {
    para_in("Caption Right", { pandoc.Str("Case No. " .. text_of(meta, "case_number")) }),
    para_in("Caption Right", { pandoc.Str("Chapter " .. text_of(meta, "chapter")) }),
    para_in("Caption Right Gap Two", { pandoc.Str("Adv. Pro. No. " .. text_of(meta, "adversary_number")) }),
  }

  local row = pandoc.Row({ pandoc.Cell(left), pandoc.Cell(right) })
  -- the left column is 3.7 in; the right column is the rest of the 6.5 in text width, and its paragraphs are
  -- indented 0.2 in (the gutter, in the "Caption Right" styles)
  out[#out + 1] = pandoc.Table(
    pandoc.Caption(),
    { { pandoc.AlignDefault, 3.7 / 6.5 }, { pandoc.AlignDefault, 2.8 / 6.5 } },
    pandoc.TableHead({}),
    { pandoc.TableBody({ row }) },
    pandoc.TableFoot({})
  )
  out[#out + 1] = para_in("Document Title", { pandoc.Str(text_of(meta, "document_title")) })
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- The signature block (typst signature-block()): "Respectfully Submitted," then one block per signer, each
-- line single spaced. Every line keeps with the next (the block does not split across pages), and the prayer
-- keeps with the block too; the spacing between the parts is part of the styles, not blank paragraphs.
local function signature(meta, out)
  local blocks = need(meta, "signature")
  local lines = {}
  lines[#lines + 1] = { style = "Signature Lead", inl = { pandoc.Str("Respectfully Submitted,") } }
  for i, block in ipairs(blocks) do
    for j, l in ipairs(block) do
      local last_of_signer = j == #block
      local last_overall = i == #blocks and last_of_signer
      local style = "Signature Keep"
      if last_overall then
        style = "Signature"
      elseif last_of_signer then
        style = "Signature Break"
      end
      lines[#lines + 1] = { style = style, inl = inlines_of(l) }
    end
  end
  for _, item in ipairs(lines) do
    out[#out + 1] = para_in(item.style, item.inl)
  end
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}

  cover(meta, out)
  if meta.lead_in then
    out[#out + 1] = para_in("First Paragraph", inlines_of(meta.lead_in))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      -- a section heading: centred, bold, capitals (the "Section Heading" style)
      out[#out + 1] = para_in("Section Heading", b.content)
    elseif b.t == "Para" and b.content[1] and b.content[1].t == "Str" and b.content[1].text:match("^WHEREFORE") then
      -- the prayer: unnumbered, and kept with the signature block
      out[#out + 1] = para_in("Prayer", b.content)
    elseif b.t == "Para" then
      n = n + 1
      local inl = pandoc.List({ pandoc.Str(n .. "."), TAB })
      inl:extend(b.content)
      out[#out + 1] = para_in("Numbered Paragraph", inl)
    else
      out[#out + 1] = b
    end
  end

  if meta.signature then signature(meta, out) end

  doc.blocks = out
  return doc
end
