-- Adversary complaint, S.D. Tex. bankruptcy court, DOCX engine (docs/DOCX.md): the markdown contract -> Word
-- paragraphs and tables in the styles of reference.docx (build-reference.sh), mirroring typst/txsb-adversary-complaint.typ.
-- Content-agnostic: every case word comes from the sample's frontmatter. The only fixed text is the court name
-- lines, which are the court's own heading.
-- Numbering: body paragraphs are numbered "N." with a tab (FRCP 10(b)); a list chunk is lettered "(a)", "(b)" ...
-- The caption is a two-column table with no borders: the left cell carries the right and bottom rules as
-- paragraph borders, the right cell the case numbers. Footnotes: the debtor footnote is a native footnote.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function P(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines or {}) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- a metadata value (markdown inlines) as a plain Lua list of inlines
local function inl(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "string" then
    out[1] = pandoc.Str(v)
  elseif v.t == "MetaBlocks" then
    for _, x in ipairs(pandoc.utils.blocks_to_inlines(v)) do out[#out + 1] = x end
  else
    for _, x in ipairs(v) do out[#out + 1] = x end
  end
  return out
end

local function upper_inl(v)
  return { pandoc.Str(string.upper(pandoc.utils.stringify(v))) }
end

local function cat(a, b)
  local out = {}
  for _, x in ipairs(a) do out[#out + 1] = x end
  for _, x in ipairs(b) do out[#out + 1] = x end
  return out
end

local function cell(blocks)
  return pandoc.Cell(blocks)
end

-- two-column borderless table: left (3.25 in) and right (3.25 in), cell margins zero (reference "Table" style)
local function two_col(left_blocks, right_blocks, left_frac)
  left_frac = left_frac or 0.5
  return pandoc.Table(
    pandoc.Caption({}),
    { { pandoc.AlignDefault, left_frac }, { pandoc.AlignDefault, 1 - left_frac } },
    pandoc.TableHead({}),
    { pandoc.TableBody({ pandoc.Row({ cell(left_blocks), cell(right_blocks) }) }) },
    pandoc.TableFoot({})
  )
end

local function caption_table(meta)
  local c = meta.caption
  local left = {}
  left[#left + 1] = P("Caption Left", { pandoc.Str("In re:") })
  local names = c.debtor_names
  for i, n in ipairs(names) do
    local ins = inl(n)
    if i == #names and c.debtor_footnote then
      ins[#ins + 1] = pandoc.Note({ pandoc.Para(inl(c.debtor_footnote)) })
    end
    left[#left + 1] = P("Caption Left", ins)
  end
  left[#left + 1] = P("Caption Designation Gap", inl(c.debtor_designation))
  for _, n in ipairs(c.plaintiff_names) do left[#left + 1] = P("Caption Left", inl(n)) end
  left[#left + 1] = P("Caption Left Indent", inl(c.plaintiff_designation))
  left[#left + 1] = P("Caption Left Half", { pandoc.Str("v.") })
  for _, n in ipairs(c.defendant_names) do left[#left + 1] = P("Caption Left", inl(n)) end
  left[#left + 1] = P("Caption Left Indent", inl(c.defendant_designation))
  left[#left + 1] = P("Caption Rule", {})

  local function row(v)
    if v == nil or pandoc.utils.stringify(v) == "" then return P("Caption Right Blank", {}) end
    return P("Caption Right", inl(v))
  end
  local right = { row(meta.chapter), row(""), row(meta.case_number) }
  if meta.joint_admin then right[#right + 1] = row(meta.joint_admin) end
  right[#right + 1] = row("")
  right[#right + 1] = row("")
  right[#right + 1] = row(meta.adversary_number)

  return two_col(left, right)
end

-- the signature block: "Dated" at left; "Respectfully submitted," and the signing blocks at right
local function signature_table(meta)
  local right = { P("Signature Line", { pandoc.Str("Respectfully submitted,") }), P("Signature Gap", {}) }
  local blocks = meta.signature.blocks
  for k, b in ipairs(blocks) do
    if k > 1 then
      right[#right + 1] = P("Signature Gap", {})
      right[#right + 1] = P("Signature Line", { pandoc.Str("-and-") })
      right[#right + 1] = P("Signature Gap", {})
    end
    for _, line in ipairs(b) do right[#right + 1] = P("Signature Line", inl(line)) end
  end
  local left = { P("Signature Line", cat({ pandoc.Str("Dated:"), pandoc.Space() }, inl(meta.dated))) }
  return two_col(left, right, 3.5 / 6.5)
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(bs) for _, b in ipairs(bs) do out[#out + 1] = b end end

  -- cover: court, division, caption, title
  add({ P("Court Heading", { pandoc.Str("IN THE UNITED STATES BANKRUPTCY COURT") }) })
  add({ P("Court Heading", { pandoc.Str("FOR THE SOUTHERN DISTRICT OF TEXAS") }) })
  add({ P("Court Heading Last", upper_inl(meta.division)) })
  add({ caption_table(meta) })
  add({ P("Title Block", upper_inl(meta.title)) })

  -- unnumbered lead-in paragraph, if the filing has one
  if meta.lead_in then add({ P("Unnumbered Paragraph", inl(meta.lead_in)) }) end

  -- body: numbered paragraphs, lettered lists, unnumbered (">") paragraphs, headings as written
  local n = 0
  local last = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      n = n + 1
      local style = (i == last) and "Numbered Paragraph Last" or "Numbered Paragraph"
      add({ P(style, cat({ pandoc.Str(n .. ".") , TAB }, b.content)) })
    elseif b.t == "OrderedList" then
      for j, item in ipairs(b.content) do
        local first = item[1]
        local ins = { pandoc.Str("(" .. string.char(96 + j) .. ")"), TAB }
        if first and (first.t == "Para" or first.t == "Plain") then
          ins = cat(ins, first.content)
          add({ P("Lettered Item", ins) })
          for k = 2, #item do add({ item[k] }) end
        else
          add({ P("Lettered Item", ins) })
          for _, x in ipairs(item) do add({ x }) end
        end
      end
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(b.content) do
        if x.t == "Para" or x.t == "Plain" then
          add({ P("Unnumbered Paragraph", x.content) })
        else
          add({ x })
        end
      end
    else
      add({ b })
    end
  end

  -- signature block (kept with the last paragraph by keep-with-next)
  if meta.signature then add({ signature_table(meta) }) end

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
