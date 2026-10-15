-- flmb pleading filter for the docx engine (pandoc --lua-filter). It builds, from the sample's frontmatter,
-- what typst/flmb-motion-brief.typ builds: the court title, the caption, the title, the body with numbered
-- paragraphs, and the signature block. Styles and numbering are in docx/reference.docx (docx/build-reference.sh).
-- Nothing case-specific is typed here: every word comes from the frontmatter or the body.
-- Rules and layout: see ../README.md ("Engines").

local LIST_STYLES = 10 -- "Pleading List 1".."Pleading List 10" in reference.docx, one numbering instance each
local lists_used = 0

local function div(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para(style, inlines)
  return div(style, { pandoc.Para(inlines) })
end

local function spacer(style)
  return div(style or "Pleading Spacer", { pandoc.Para({}) })
end

-- A frontmatter value as inlines. Markdown in the YAML (case names in *italics*) is kept.
local function inlines(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then return pandoc.Inlines({ pandoc.Str(v) }) end
  return pandoc.Inlines(v)
end

local function plain(v)
  return pandoc.utils.stringify(v or "")
end

-- Title as printed: capitals, then the words the Local Rules require (typst full-title()).
local function full_title(meta)
  local parts = { plain(meta.title):upper() }
  if meta.injunctive_relief then table.insert(parts, "INJUNCTIVE RELIEF SOUGHT") end
  if meta.jury_demand then table.insert(parts, "DEMAND FOR JURY TRIAL") end
  return table.concat(parts, "; ")
end

-- Caption side: names, designation, optional rule with the slash (typst caption()).
local function caption_cell(blocks, names, designation, slash)
  for _, n in ipairs(names) do table.insert(blocks, para("Pleading Caption", inlines(n))) end
  if designation then table.insert(blocks, para("Pleading Caption Indent", inlines(designation))) end
  if slash then
    table.insert(blocks, div("Pleading Rule", { pandoc.Para({ pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"), pandoc.Str("/") }) }))
  end
  return blocks
end

-- Two-column table without rules (the Table style has no borders). Widths are fractions of the text width.
local function two_col(rows, widths)
  return pandoc.utils.from_simple_table(pandoc.SimpleTable(pandoc.Inlines({}), { pandoc.AlignDefault, pandoc.AlignDefault }, widths, {}, rows))
end

local function caption(meta)
  local left1 = caption_cell({ para("Pleading Caption", { pandoc.Str("In re:") }) }, meta.in_re, "Debtor.", true)
  table.insert(left1, spacer())

  local right1 = {
    para("Pleading Single", { pandoc.Str("Case No. " .. plain(meta.case_number)) }),
    para("Pleading Single", inlines(meta.chapter)),
  }

  local left2 = caption_cell({}, meta.caption[1].names, meta.caption[1].designation, false)
  table.insert(left2, spacer())

  local left3 = { para("Pleading Caption", { pandoc.Str("v.") }), spacer() }
  local label = meta.adversary_label and plain(meta.adversary_label) or "Adv. Case No."
  local right3 = { para("Pleading Single", { pandoc.Str(label .. " " .. plain(meta.adversary_number)) }) }

  local left4 = caption_cell({}, meta.caption[2].names, meta.caption[2].designation, true)

  return two_col({
    { left1, right1 },
    { left2, { spacer() } },
    { left3, right3 },
    { left4, { spacer() } },
  }, { 0.5538, 0.4462 })
end

-- Signature block (typst signature-block()): "Dated:" at left, counsel at right, kept on one page.
local function signature(meta)
  local sig = meta.signature
  local right = { para("Pleading Signature", { pandoc.Str("Respectfully submitted,") }), spacer("Pleading Half Spacer") }
  for _, line in ipairs(sig.firm) do table.insert(right, para("Pleading Signature", inlines(line))) end
  table.insert(right, spacer("Pleading Half Spacer"))
  local by = pandoc.Inlines({ pandoc.Str("By: /s/ ") })
  for _, x in ipairs(inlines(sig.signer)) do by:insert(x) end
  table.insert(right, para("Pleading Signature", by))
  table.insert(right, para("Pleading Signature", inlines(sig.signer)))
  for _, line in ipairs(sig.lines) do table.insert(right, para("Pleading Signature", inlines(line))) end

  local dated = meta.date and para("Pleading Signature", { pandoc.Str("Dated: " .. plain(meta.date)) }) or spacer()
  return two_col({ { { dated }, right } }, { 0.5231, 0.4769 })
end

-- Paragraph numbering: a plain paragraph is numbered; one that starts with ^ is not (typst body-chunks()).
local function body_paragraph(b)
  local first = b.content[1]
  local numbered = true
  if first and first.t == "Str" and first.text:sub(1, 1) == "^" then
    numbered = false
    first.text = first.text:sub(2)
    if first.text == "" then
      table.remove(b.content, 1)
      if b.content[1] and b.content[1].t == "Space" then table.remove(b.content, 1) end
    end
  end
  return div(numbered and "Numbered Paragraph" or "Unnumbered Paragraph", { b })
end

-- Tables (the transfer chart) are unruled and centred; their cell text is single spaced.
local function style_table(t)
  local function style_rows(rows)
    for _, r in ipairs(rows) do
      for _, c in ipairs(r.cells) do
        for i, cb in ipairs(c.contents) do
          if cb.t == "Para" or cb.t == "Plain" then c.contents[i] = div("Pleading Table Text", { pandoc.Para(cb.content) }) end
        end
      end
    end
  end
  style_rows(t.head.rows)
  for _, body in ipairs(t.bodies) do
    style_rows(body.head)
    style_rows(body.body)
  end
  style_rows(t.foot.rows)
  return t
end

local function body_blocks(blocks)
  local out = {}
  local last_block = blocks[#blocks]
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      table.insert(out, body_paragraph(b))
    elseif b.t == "OrderedList" then
      -- Each list gets its own numbering instance so it restarts at 1 (reference.docx: Pleading List n).
      lists_used = lists_used + 1
      if lists_used > LIST_STYLES then
        error("flmb-pleading.lua: more than " .. LIST_STYLES .. " ordered lists; add Pleading List styles to reference.docx")
      end
      -- A list that ends the body keeps its last item with the signature block (typst body-chunks()).
      for idx, item in ipairs(b.content) do
        local keep = b == last_block and idx == #b.content
        local style = "Pleading List " .. lists_used .. (keep and " End" or "")
        for i, ib in ipairs(item) do
          if i == 1 and (ib.t == "Para" or ib.t == "Plain") then
            table.insert(out, div(style, { pandoc.Para(ib.content) }))
          else
            table.insert(out, ib)
          end
        end
      end
    elseif b.t == "Table" then
      table.insert(out, style_table(b))
    else
      table.insert(out, b)
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  -- Court title (typst court-title()); its gap below (body-leading) is a spacer paragraph.
  for _, line in ipairs({
    "UNITED STATES BANKRUPTCY COURT",
    "MIDDLE DISTRICT OF FLORIDA",
    plain(meta.division):upper() .. " DIVISION",
  }) do
    table.insert(out, para("Pleading Court Title", { pandoc.Str(line) }))
  end
  table.insert(out, spacer())
  table.insert(out, caption(meta))
  table.insert(out, spacer())
  table.insert(out, para("Pleading Title", { pandoc.Str(full_title(meta)) }))
  table.insert(out, spacer())
  for _, b in ipairs(body_blocks(doc.blocks)) do table.insert(out, b) end
  table.insert(out, spacer())
  table.insert(out, signature(meta))

  -- The title, date and other frontmatter are printed above; pandoc must not print them again.
  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
