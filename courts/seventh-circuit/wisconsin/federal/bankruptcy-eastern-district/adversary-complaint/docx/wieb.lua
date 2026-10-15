-- E.D. Wis. bankruptcy adversary complaint, DOCX engine (docs/DOCX.md). The markdown contract (../README.md)
-- becomes a Word document on docx/reference.docx, laid out as the typst template lays it out:
-- the caption, consent statement, title and signature block are styled paragraphs (no tables, no
-- forced breaks); numbered paragraphs keep the numbers typed in the markdown (FRCP 10(b) via FRBP 7010).
-- Every case-specific word comes from the YAML frontmatter. The rule text below is constant, as in the typst.

local CONSENT = { ["does"] = true, ["does not"] = true }
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("wieb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- a metadata value (inlines) as a fresh pandoc.List of inlines
local function il(v)
  local out = pandoc.List({})
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

local function plain(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function cat(...)
  local out = pandoc.List({})
  for _, part in ipairs({ ... }) do
    for _, x in ipairs(part) do out:insert(x) end
  end
  return out
end

local function style(name, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = name }))
end

-- an empty paragraph in a named style (pandoc drops empty Para elements, so this is raw openxml)
local function blank(name)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. name .. '"/></w:pPr></w:p>')
end

local function strong(s) return pandoc.Strong({ pandoc.Str(s) }) end

-- caption row: left text, a tab to the right column (4968 twips, set in the style), right text
local function row(name, left, right)
  local out = pandoc.List(left or {})
  if right and #right > 0 then
    out:insert(TAB)
    out = cat(out, right)
  end
  return style(name, out)
end

-- FRBP 7010 caption (Form 416A layout): court, debtor and case, rule, parties and adversary number, rule
local function caption(meta)
  local d, p, df = need(meta, "debtor"), need(meta, "plaintiff"), need(meta, "defendant")
  local out = {}
  local function add(b) out[#out + 1] = b end
  add(style("Centered", { strong("UNITED STATES BANKRUPTCY COURT") }))
  add(style("Centered", { strong("EASTERN DISTRICT OF WISCONSIN") }))
  add(blank("Gap"))
  add(row("CaptionLine", { pandoc.Str("In re:") }))
  add(row("CaptionIndent05", il(d.name), il(d.case_number)))
  add(row("CaptionIndent05", il(d.designation), il(d.chapter)))
  add(blank("Rule"))
  for _, n in ipairs(p.names) do add(row("CaptionLine", il(n))) end
  add(row("CaptionIndent22", il(p.designation)))
  add(row("CaptionIndent09", { pandoc.Str("v.") }, il(need(meta, "adversary_number"))))
  for _, n in ipairs(df.names) do add(row("CaptionLine", il(n))) end
  add(row("CaptionIndent22", il(df.designation)))
  add(blank("Rule"))
  add(blank("Gap"))
  return out
end

-- LR 5005-2(a)(1)(A): "/s/" followed by the printed name; the block is kept together
local function signature(meta, respectfully)
  local out = {}
  local function add(b) out[#out + 1] = b end
  add(style("Dated", { pandoc.Str("Dated: " .. plain(need(meta, "dated"))) }))
  for _, s in ipairs(need(meta, "signers")) do
    if respectfully then
      add(style("SigFirst", { pandoc.Str("Respectfully submitted,") }))
      add(style("SigLine", cat({ pandoc.Str("/s/ ") }, il(s.signer))))
    else
      add(style("SigFirst", cat({ pandoc.Str("/s/ ") }, il(s.signer))))
    end
    for _, l in ipairs(s.lines or {}) do add(style("SigIndent", il(l))) end
  end
  return out
end

-- numbered paragraphs: the number typed by the drafter is kept as text (the list restarts are not used)
local function number_list(list)
  local out = {}
  local start = list.listAttributes.start
  for i, item in ipairs(list.content) do
    for j, b in ipairs(item) do
      if j == 1 and (b.t == "Para" or b.t == "Plain") then
        local inl = pandoc.List({ pandoc.Str((start + i - 1) .. "."), TAB })
        inl = cat(inl, b.content)
        out[#out + 1] = style("Numbered", inl)
      else
        out[#out + 1] = b
      end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ OrderedList = number_list })

  local c = plain(need(meta, "consent"))
  if not CONSENT[c] then error("wieb-adversary-complaint: `consent` must be `does` or `does not` (FRBP 7008(a))", 0) end

  local out = {}
  local function add(b) out[#out + 1] = b end
  for _, b in ipairs(caption(meta)) do add(b) end
  add(style("Centered", { pandoc.Strong(il(need(meta, "title"))) }))
  add(blank("Gap"))
  add(style("Consent", { pandoc.Str("Pursuant to Fed. R. Bankr. P. 7008(a), the Plaintiff " .. c
    .. " consent to the entry of final orders or judgment by the Bankruptcy Court.") }))
  for _, b in ipairs(doc.blocks) do add(b) end
  for _, b in ipairs(signature(meta, false)) do add(b) end

  -- the title is in the caption and the title line; the docx title block would repeat it
  doc.meta.title = nil
  doc.blocks = out
  return doc
end
