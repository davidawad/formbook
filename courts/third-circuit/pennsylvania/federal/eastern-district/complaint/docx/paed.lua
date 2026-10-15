-- paed complaint, DOCX engine. Builds the parts of complaint/typst/paed-complaint.typ that pandoc cannot write
-- from the markdown contract: the cover (court title, caption table, title of the pleading), the lead-in, the
-- numbered allegations (Fed. R. Civ. P. 10(b)), lettered lists "(a)", and the signature block. Styles come from
-- docx/reference.docx (Centered, Compact, Lettered, Body Text, Heading 1-3, Table). Every case word is read from
-- the sample's frontmatter; nothing here is case text.
-- Known differences (see the court README, "Engines"): the caption's right cell is top-aligned, not vertically
-- centred; the blank lines between blocks are one double-spaced line each, not the typst spacing.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local COL = { 3.0 / 6.5, 0.35 / 6.5, 3.15 / 6.5 } -- caption: party column, colon column, number column (6.5 in text)

local function inl(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaInlines" then return v end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function spacer()
  return pandoc.Para({})
end

local function plain_cell(lines)
  local blocks = {}
  for _, l in ipairs(lines) do blocks[#blocks + 1] = pandoc.Plain(l) end
  return pandoc.Cell(blocks)
end

-- the caption: one party line per row, a ":" per row in the middle column, the action number on the right
local function caption(meta)
  local rows = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then rows[#rows + 1] = { pandoc.Str("v.") } end
    for _, nm in ipairs(p.names) do rows[#rows + 1] = inl(nm) end
    rows[#rows + 1] = inl(p.designation)
  end
  local colons = {}
  for _ = 1, #rows do colons[#colons + 1] = { pandoc.Str(":") } end
  local number = inl(meta.case_number)
  if #number == 0 then number = { pandoc.Str("________________") } end
  local right = { { pandoc.Str("Civil Action No. ") } }
  for _, x in ipairs(number) do table.insert(right[1], x) end
  local row = pandoc.Row({ plain_cell(rows), plain_cell(colons), plain_cell(right) })
  return pandoc.Table(
    pandoc.Caption(nil, {}),
    { { pandoc.AlignDefault, COL[1] }, { pandoc.AlignDefault, COL[2] }, { pandoc.AlignDefault, COL[3] } },
    pandoc.TableHead({}),
    { { attr = pandoc.Attr(), row_head_columns = 0, head = {}, body = { row } } },
    pandoc.TableFoot({}))
end

local function cover(meta)
  local out = {}
  for _, line in ipairs(meta.court_lines) do
    out[#out + 1] = styled("Centered", { pandoc.Para({ pandoc.Strong(inl(line)) }) })
  end
  out[#out + 1] = spacer()
  out[#out + 1] = caption(meta)
  out[#out + 1] = spacer()
  out[#out + 1] = styled("Centered", { pandoc.Para({ pandoc.Strong(inl(meta.brief_title)) }) })
  out[#out + 1] = spacer()
  return out
end

local function signature(meta)
  local out = { spacer() }
  local firm = {}
  for _, l in ipairs(meta.signature.firm) do firm[#firm + 1] = pandoc.Para(inl(l)) end
  out[#out + 1] = styled("Compact", firm)
  out[#out + 1] = spacer()
  local by = { pandoc.Para({ pandoc.Str("BY: /s/ ") }) }
  for _, x in ipairs(inl(meta.signature.signer)) do table.insert(by[1].content, x) end
  for _, l in ipairs(meta.signature.lines) do by[#by + 1] = pandoc.Para(inl(l)) end
  out[#out + 1] = styled("Compact", by)
  out[#out + 1] = spacer()
  local date = { pandoc.Str("Date: ") }
  for _, x in ipairs(inl(meta.date)) do date[#date + 1] = x end
  out[#out + 1] = styled("Compact", { pandoc.Para(date) })
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end
  if meta.lead_in then blocks[#blocks + 1] = pandoc.Para(inl(meta.lead_in)) end

  -- body: numbered allegations; WHEREFORE paragraphs and headings unnumbered; lists lettered
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      if pandoc.utils.stringify(b):sub(1, 9) == "WHEREFORE" then
        blocks[#blocks + 1] = b
      else
        n = n + 1
        local inlines = { pandoc.Str(n .. "."), TAB }
        for _, x in ipairs(b.content) do inlines[#inlines + 1] = x end
        blocks[#blocks + 1] = pandoc.Para(inlines)
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local label = "(" .. string.char(96 + i) .. ")"
        local items = {}
        local first = item[1]
        if first and (first.t == "Plain" or first.t == "Para") then
          local inlines = { pandoc.Str(label), TAB }
          for _, x in ipairs(first.content) do inlines[#inlines + 1] = x end
          items[1] = pandoc.Para(inlines)
          for j = 2, #item do items[#items + 1] = item[j] end
        else
          items[1] = pandoc.Para({ pandoc.Str(label), TAB })
          for _, x in ipairs(item) do items[#items + 1] = x end
        end
        blocks[#blocks + 1] = styled("Lettered", items)
      end
    else
      blocks[#blocks + 1] = b
    end
  end

  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
