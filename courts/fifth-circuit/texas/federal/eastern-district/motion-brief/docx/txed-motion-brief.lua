-- txed-motion-brief.lua (docx engine): what the Word output adds to pandoc's default conversion, so that the
-- .docx follows ../typst/txed-motion-brief.typ (see ../README.md, "Engines"):
--   * the cover: court lines, the caption (parties on the left, case number and oral-argument line on the right),
--     and the title of the paper, from the sample's frontmatter (no case text here);
--   * level-1 headings labelled I., II., ... (the statement of the issues is numbered too, as in the typst
--     template); level-2 headings labelled A., B., ... and restarted under each level-1 heading; level-3
--     headings are unlabelled bold italic run-in lines (pandoc's Heading 3 style, set in reference.docx);
--   * the relief list lettered a., b., ... with a hanging indent;
--   * the signature block, then the certificate of service (date and method from the frontmatter).
-- Footnotes are pandoc's native footnotes (Footnote Text style, single spaced, from reference.docx).
-- The excerpt flag and the 30-page check are typst-only (see ../README.md).

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function styled(style, content)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

-- An empty paragraph in a named style. pandoc drops empty styled paragraphs, so it is written as raw OOXML.
local function gap(style)
  return pandoc.RawBlock("openxml", "<w:p><w:pPr><w:pStyle w:val=\"" .. style .. "\" /></w:pPr></w:p>")
end

local function concat(a, b)
  local out = pandoc.Inlines({})
  for _, x in ipairs(a) do out:insert(x) end
  for _, x in ipairs(b) do out:insert(x) end
  return out
end

local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- Cover: the court lines, a gap, the caption table, the title of the paper.
local function cover(meta)
  local blocks = {}
  for _, line in ipairs(meta.court or {}) do
    table.insert(blocks, styled("Court Title", line))
  end
  table.insert(blocks, gap("BlockGap"))

  local left, right = {}, {}
  for k, p in ipairs(meta.caption or {}) do
    if k > 1 then table.insert(left, styled("Caption Line", { pandoc.Str("v.") })) end
    for _, n in ipairs(p.names) do table.insert(left, styled("Caption Line", n)) end
    table.insert(left, styled("Caption Designation", p.designation))
  end
  -- The case number and the jury line sit at the foot of the caption, as in the typst template (bottom-aligned
  -- there). A pandoc table cell cannot be bottom-aligned, so the right column is padded with empty lines.
  table.insert(right, styled("Caption Line", meta.case_number))
  if meta.jury_demand then
    table.insert(right, gap("CaptionLine"))
    table.insert(right, styled("Caption Line", { pandoc.Strong(meta.jury_demand) }))
  end
  for _ = 1, #left - #right do table.insert(right, 1, gap("CaptionLine")) end

  -- Column proportions of the typst caption (3.65 in, 0.25 in gutter, 2.6 in on 6.5 in); pandoc sizes them as
  -- fractions of the table width (5000 pct), so they are not twips.
  local caption = pandoc.Table(
    pandoc.Caption(),
    { { pandoc.AlignDefault, 0.5615 }, { pandoc.AlignDefault, 0.0385 }, { pandoc.AlignDefault, 0.4 } },
    pandoc.TableHead({}),
    { { attr = pandoc.Attr(), head = {}, body = { pandoc.Row({ pandoc.Cell(left), pandoc.Cell({}), pandoc.Cell(right) }) }, row_head_columns = 0 } },
    pandoc.TableFoot({})
  )
  table.insert(blocks, caption)
  table.insert(blocks, styled("Title of Paper", meta.brief_title))
  return blocks
end

-- Signature block (CV-10(a)(3)): the firm, the signer, the bar and contact lines, the role.
local function signature(sig)
  local blocks = {}
  local function line(content) table.insert(blocks, styled("Signature Block", content)) end
  local function sig_gap() table.insert(blocks, gap("SignatureGap")) end
  line({ pandoc.Str("Respectfully submitted,") })
  sig_gap()
  for _, l in ipairs(sig.firm or {}) do line(l) end
  sig_gap()
  line(concat({ pandoc.Str("/s/"), pandoc.Space() }, sig.signer))
  line(sig.signer)
  for _, l in ipairs(sig.lines or {}) do line(l) end
  sig_gap()
  line(sig.role)
  return blocks
end

-- Certificate of service (CV-5(c)): the date and the method, from the frontmatter.
local function certificate(service)
  local blocks = {}
  table.insert(blocks, styled("Certificate Heading", { pandoc.Str("CERTIFICATE OF SERVICE") }))
  table.insert(blocks, pandoc.Para({
    pandoc.Str("I hereby certify that on " .. pandoc.utils.stringify(service.date) .. ", the foregoing document was served on all counsel of record " .. pandoc.utils.stringify(service.method) .. "."),
  }))
  return blocks
end

-- Body: level-1 headings get I., II., ...; level-2 headings get A., B., ... (restarting under each level-1
-- heading); a bulleted list is lettered a., b., ... with a hanging indent.
local function body(blocks)
  local out = {}
  local sections, subsections = 0, 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      sections = sections + 1
      subsections = 0
      table.insert(b.content, 1, pandoc.Space())
      table.insert(b.content, 1, pandoc.Str(roman(sections) .. "."))
      table.insert(out, b)
    elseif b.t == "Header" and b.level == 2 then
      subsections = subsections + 1
      table.insert(b.content, 1, pandoc.Space())
      table.insert(b.content, 1, pandoc.Str(string.char(64 + subsections) .. "."))
      table.insert(out, b)
    elseif b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        local inl = pandoc.Inlines({ pandoc.Str(string.char(96 + i) .. "."), TAB })
        if first and (first.t == "Plain" or first.t == "Para") then
          inl = concat(inl, first.content)
        end
        table.insert(out, styled("Lettered Item", inl))
        for j = 2, #item do table.insert(out, item[j]) end
      end
    else
      table.insert(out, b)
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = cover(meta)
  for _, b in ipairs(body(doc.blocks)) do table.insert(blocks, b) end
  for _, b in ipairs(signature(meta.signature or {})) do table.insert(blocks, b) end
  if meta.service then
    for _, b in ipairs(certificate(meta.service)) do table.insert(blocks, b) end
  end
  doc.blocks = blocks
  return doc
end
