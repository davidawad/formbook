-- California Court of Appeal (calctapp): pandoc filter for the docx engine, one copy per doc type.
-- The same content as the typst template of this doc type, from the same markdown contract. pandoc writes the
-- body; this filter writes the cover (from the frontmatter) before it and the signature block after it.
-- Styles come from reference.docx (Calctapp Cover, Calctapp Cover Left, Calctapp Signature).
-- Not built here (BLOCKED, see README.md "Engines"): the table of contents and the table of authorities, the
-- caption box with its rules, the certificate of word count and the proof of service.

-- pandoc.utils.type: "List" for a YAML list, "table" for a map, "Inlines" for a single value.
local function items(v)
  if v == nil then return {} end
  if pandoc.utils.type(v) == "List" then return v end
  return { v }
end

local function para(style, content)
  return pandoc.Div({ pandoc.Para(content) }, { ["custom-style"] = style })
end

local function blank(style)
  return para(style, pandoc.Inlines({}))
end

local function page_break()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- Prefix text in front of an Inlines value (a meta string).
local function prefixed(prefix, v)
  if v == nil then return pandoc.Inlines({}) end
  return pandoc.Inlines({ pandoc.Str(prefix), pandoc.Space(), table.unpack(v) })
end

-- The cover of the reply and opening templates (court_lines present) and of the answering template (no court_lines).
local function cover(m)
  local out = {}
  if m.court_lines then
    for _, l in ipairs(items(m.court_lines)) do
      out[#out + 1] = para("Calctapp Cover", { pandoc.Strong(l) })
    end
    out[#out + 1] = blank("Calctapp Cover")
    out[#out + 1] = para("Calctapp Cover", prefixed("Court of Appeal Case No.", m.case_number))
    out[#out + 1] = blank("Calctapp Cover")
  else
    out[#out + 1] = para("Calctapp Cover", prefixed("No.", m.case_number))
    out[#out + 1] = blank("Calctapp Cover")
    out[#out + 1] = para("Calctapp Cover", { pandoc.Strong(pandoc.Str("IN THE COURT OF APPEAL OF THE STATE OF CALIFORNIA")) })
    if m.district then out[#out + 1] = para("Calctapp Cover", { pandoc.Strong(m.district) }) end
    out[#out + 1] = blank("Calctapp Cover")
  end
  for _, c in ipairs(items(m.caption)) do
    for _, n in ipairs(items(c.names)) do
      out[#out + 1] = para("Calctapp Cover Left", n)
    end
    out[#out + 1] = para("Calctapp Cover", c.designation)
    out[#out + 1] = blank("Calctapp Cover")
  end
  if m.trial_court then out[#out + 1] = para("Calctapp Cover Left", m.trial_court) end
  if m.superior_case_number then out[#out + 1] = para("Calctapp Cover Left", prefixed("Superior Court No.", m.superior_case_number)) end
  if m.judge then out[#out + 1] = para("Calctapp Cover Left", m.judge) end
  if m.proceeding then out[#out + 1] = para("Calctapp Cover", m.proceeding) end
  if m.trial_judge then out[#out + 1] = para("Calctapp Cover", m.trial_judge) end
  if m.trial_case_number then out[#out + 1] = para("Calctapp Cover", prefixed("Superior Court No.", m.trial_case_number)) end
  out[#out + 1] = blank("Calctapp Cover")
  if m.brief_title then out[#out + 1] = para("Calctapp Cover", { pandoc.Strong(m.brief_title) }) end
  out[#out + 1] = blank("Calctapp Cover")
  for _, c in ipairs(items(m.counsel)) do
    for _, n in ipairs(items(c.names)) do
      out[#out + 1] = para("Calctapp Cover Left", n)
    end
    for _, l in ipairs(items(c.lines)) do
      out[#out + 1] = para("Calctapp Cover Left", l)
    end
    out[#out + 1] = blank("Calctapp Cover Left")
  end
  if m.counsel_for then out[#out + 1] = para("Calctapp Cover Left", { pandoc.Emph(m.counsel_for) }) end
  out[#out + 1] = page_break()
  return out
end

local function signature(m)
  local sig = m.signature
  if sig == nil then return {} end
  local out = {}
  if m.date then out[#out + 1] = para("Calctapp Signature", prefixed("Dated:", m.date)) end
  local block = {}
  if sig.firm then block[#block + 1] = pandoc.Para(sig.firm) end
  if sig.signer then
    block[#block + 1] = pandoc.Para(pandoc.Inlines({ pandoc.Str("s/"), table.unpack(sig.signer) }))
    block[#block + 1] = pandoc.Para(sig.signer)
  end
  for _, l in ipairs(items(sig.lines)) do block[#block + 1] = pandoc.Para({ pandoc.Emph(l) }) end
  if sig.role then block[#block + 1] = pandoc.Para({ pandoc.Emph(sig.role) }) end
  out[#out + 1] = pandoc.Div(block, { ["custom-style"] = "Calctapp Signature" })
  return out
end

function Pandoc(doc)
  local blocks = cover(doc.meta)
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  for _, b in ipairs(signature(doc.meta)) do blocks[#blocks + 1] = b end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))  -- no title block: the frontmatter is consumed here
end
