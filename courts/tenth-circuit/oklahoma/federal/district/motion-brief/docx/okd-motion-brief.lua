-- okd motion-brief, DOCX. Mirrors typst/okd-motion-brief.typ (same rules and layout; see ../README.md, "Engines").
-- Frontmatter -> cover (court lines, caption table, title); body as written (section and paragraph numbers are typed
-- in the sample); signature block at 3 in; certificate on a new page. Styles come from docx/reference.docx.

local function to_inlines(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then return pandoc.Inlines({ pandoc.Str(v) }) end
  if type(v) == "boolean" then return pandoc.Inlines({ pandoc.Str(tostring(v)) }) end
  if v.t == "MetaInlines" then return pandoc.Inlines(v) end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return pandoc.Inlines({ pandoc.Str(pandoc.utils.stringify(v)) })
end

local function styled(style, content)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

-- An empty paragraph in the given style. Pandoc drops an empty Div, so it is written as raw WordprocessingML.
local function empty(style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style:gsub(" ", "") .. '"/></w:pPr></w:p>')
end

local function list_of(v)
  local out = {}
  if v == nil then return out end
  for i = 1, #v do out[#out + 1] = v[i] end
  return out
end

-- Caption: one row per party line, the ")" column, and the case information on the right (typst caption()).
local function caption(meta)
  local rows = {}
  for k, p in ipairs(list_of(meta.caption.parties)) do
    if k > 1 then rows[#rows + 1] = { style = "Caption Vs", content = pandoc.Inlines({ pandoc.Str("v.") }) } end
    for _, n in ipairs(list_of(p.names)) do
      rows[#rows + 1] = { style = "Caption Line", content = to_inlines(n) }
    end
    rows[#rows + 1] = { style = "Caption Designation", content = to_inlines(p.designation) }
  end
  local right = {}
  local case_no = pandoc.Inlines({ pandoc.Str("Case"), pandoc.Space(), pandoc.Str("No."), pandoc.Space() })
  for _, x in ipairs(to_inlines(meta.case_number)) do case_no:insert(x) end
  right[#right + 1] = case_no
  if meta.jury_demand == true then
    right[#right + 1] = pandoc.Inlines({})
    right[#right + 1] = pandoc.Inlines({ pandoc.Str("JURY"), pandoc.Space(), pandoc.Str("TRIAL"), pandoc.Space(),
      pandoc.Str("DEMANDED") })
  end

  local left, marks, rightcol = {}, {}, {}
  for _, r in ipairs(rows) do
    left[#left + 1] = styled(r.style, r.content)
    marks[#marks + 1] = styled("Caption Mark", pandoc.Inlines({ pandoc.Str(")") }))
  end
  for _, c in ipairs(right) do
    if #c == 0 then rightcol[#rightcol + 1] = empty("Caption Right") else rightcol[#rightcol + 1] = styled("Caption Right", c) end
  end
  local bodyrow = pandoc.Row({ pandoc.Cell(left), pandoc.Cell(marks), pandoc.Cell(rightcol) })
  local colspecs = {
    { pandoc.AlignDefault, 3.6 / 6.5 },
    { pandoc.AlignDefault, 0.3 / 6.5 },
    { pandoc.AlignDefault, 2.6 / 6.5 },
  }
  return pandoc.Table(pandoc.Caption(), colspecs, pandoc.TableHead({}), { pandoc.TableBody({ bodyrow }) }, pandoc.TableFoot({}))
end

local function cover(meta)
  local blocks = {}
  for _, l in ipairs(list_of(meta.court)) do blocks[#blocks + 1] = styled("Court Name", to_inlines(l)) end
  blocks[#blocks + 1] = empty("Sig Gap")
  blocks[#blocks + 1] = caption(meta)
  blocks[#blocks + 1] = styled("Cover Title", to_inlines(meta.brief_title))
  return blocks
end

-- Signature block in the right half of the page (typst signature-block: pad left 3 in).
local function signature(meta)
  local blocks = {}
  local sig = meta.signature
  if sig.closing then
    for _, l in ipairs(list_of(sig.closing)) do blocks[#blocks + 1] = styled("Sig Block", to_inlines(l)) end
    blocks[#blocks + 1] = empty("Sig Gap")
  end
  for _, g in ipairs(list_of(sig.groups)) do
    local lines = list_of(g.lines)
    for i, l in ipairs(lines) do
      blocks[#blocks + 1] = styled(i == #lines and "Sig Block Group End" or "Sig Block", to_inlines(l))
    end
  end
  return blocks
end

-- Certificate on a new page (the title style starts the page): text, then the parties served (flush left),
-- then the signer's lines in the right half.
local function certificate(meta)
  local c = meta.certificate
  if not c then return {} end
  local blocks = {}
  blocks[#blocks + 1] = styled("Certificate Title", to_inlines(c.title))
  blocks[#blocks + 1] = pandoc.Para(to_inlines(c.text))
  blocks[#blocks + 1] = empty("Sig Gap")
  if c.served then
    for _, l in ipairs(list_of(c.served)) do blocks[#blocks + 1] = styled("Served Line", to_inlines(l)) end
    blocks[#blocks + 1] = empty("Sig Gap")
  end
  for _, g in ipairs(list_of(c.groups)) do
    local lines = list_of(g.lines)
    for i, l in ipairs(lines) do
      blocks[#blocks + 1] = styled(i == #lines and "Sig Block Group End" or "Sig Block", to_inlines(l))
    end
  end
  return blocks
end

-- Ordered lists (prayer items): the number is typed in front of each item, at the margin, with the text at 0.5 in
-- (typst enum with body-indent 0.5 in); pandoc's own list numbering indents the number, so it is not used.
function OrderedList(el)
  local out = {}
  local start = el.listAttributes.start
  for i, item in ipairs(el.content) do
    local first = true
    for _, b in ipairs(item) do
      if first and (b.t == "Plain" or b.t == "Para") then
        local c = pandoc.Inlines({ pandoc.Str(tostring(start + i - 1) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        for _, x in ipairs(b.content) do c:insert(x) end
        out[#out + 1] = styled("Numbered Item", c)
        first = false
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = empty("Sig Gap")
  for _, b in ipairs(signature(meta)) do blocks[#blocks + 1] = b end
  for _, b in ipairs(certificate(meta)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
