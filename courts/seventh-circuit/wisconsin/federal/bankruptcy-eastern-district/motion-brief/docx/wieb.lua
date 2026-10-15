-- E.D. Wis. bankruptcy motion with brief in support, DOCX engine (docs/DOCX.md). The markdown contract
-- (../README.md) becomes a Word document on docx/reference.docx, laid out as the typst template lays it out:
-- the notice of motion (page 1), the motion, the brief in support (each with its own caption), and the
-- certificate of service. The caption and signature block are styled paragraphs (no tables, no forced
-- breaks), and page breaks are the only raw openxml. Every case-specific word comes from the YAML
-- frontmatter; the rule text below is constant, as in the typst template.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local PAGE_BREAK = pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
local BRIEF = "%%BRIEF%%"

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("wieb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
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

-- a document heading line: centered and bold, then a gap
local function title_block(inlines)
  return { style("Centered", { pandoc.Strong(inlines) }), blank("Gap") }
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

-- numbered paragraphs: the number typed by the drafter is kept as text
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

local function para(s) return pandoc.Para({ pandoc.Str(s) }) end

function Pandoc(doc)
  local meta = doc.meta
  doc = doc:walk({ OrderedList = number_list })

  local days = tonumber(plain(need(meta, "objection_days")))
  if not days or days < 14 or days ~= math.floor(days) then
    error("wieb-motion-brief: `objection_days` must be an integer of at least 14 (LR 9014-1(a)(2)(A))", 0)
  end

  -- split at the %%BRIEF%% line: above it the motion, below it the brief in support
  local motion, brief, target, marks = {}, {}, nil, 0
  target = motion
  for _, b in ipairs(doc.blocks) do
    if (b.t == "Para" or b.t == "Plain") and pandoc.utils.stringify(b) == BRIEF then
      marks = marks + 1
      target = brief
    else
      target[#target + 1] = b
    end
  end
  if marks ~= 1 then error("wieb-motion-brief: the body must contain exactly one `" .. BRIEF .. "` line", 0) end

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end
  local title = need(meta, "title")
  local brief_title = need(meta, "brief_title")
  local movants = il(need(meta, "movants"))
  local verb = il(need(meta, "notice_verb"))

  -- 1. notice of motion (LR 9014-1(a)(1)-(3)); the objection period comes from the frontmatter
  addall(title_block({ pandoc.Str("Notice of Motion") }))
  add(pandoc.Para(cat({ pandoc.Str("PLEASE TAKE NOTICE that ") }, movants, { pandoc.Space() }, verb,
    { pandoc.Str(" the attached ") }, il(title), { pandoc.Str(" and ") }, il(brief_title),
    { pandoc.Str(" (together, the \u{201C}Motion\u{201D}).") })))
  add(para("If you want the court to consider your views on the Motion, or want a hearing, you must file and serve a written objection no later than " .. days .. " days after the date of service of this notice (LR 9014-1(a)(2)(A)). An objection must be filed with the Clerk of the Bankruptcy Court and served on the movant."))
  add(para("Absent a timely filed objection, the court may grant the relief requested without a hearing (LR 9014-1(a)(2)(B)). If no objection is timely filed, the movant will file a proposed order as required by LR 9014-2. If a timely objection is filed, the court may schedule a hearing, and the Clerk will give notice of the hearing (LR 9014-1(a)(3))."))
  addall(signature(meta, true))
  add(PAGE_BREAK)

  -- 2. the motion, with its caption
  addall(caption(meta))
  addall(title_block(il(title)))
  addall(motion)
  addall(signature(meta, true))
  add(PAGE_BREAK)

  -- 3. the brief in support, with its own caption and title
  addall(caption(meta))
  addall(title_block(il(brief_title)))
  addall(brief)
  addall(signature(meta, true))
  add(PAGE_BREAK)

  -- 4. certificate of service (LR 9013-2(a); LR 7005-1)
  local c = need(meta, "certificate")
  addall(title_block({ pandoc.Str("Certificate of Service") }))
  add(pandoc.Para(cat({ pandoc.Str("I hereby certify that on " .. plain(need(meta, "dated")) .. " the ") },
    il(title), { pandoc.Str(" and the ") }, il(brief_title),
    { pandoc.Str(" were electronically filed in this case and served upon the following parties using the CM/ECF system:") })))
  for _, n in ipairs(c.ecf or {}) do add(style("ServiceIndent", il(n))) end
  add(para("I further certify that on the same date I mailed the same document(s) by United States Mail to the following non-ECF participants:"))
  for _, n in ipairs(c.non_ecf or {}) do
    add(style("ServiceIndent", il(n.name)))
    for _, l in ipairs(n.lines or {}) do add(style("ServiceIndent", il(l))) end
    add(blank("ServiceGap"))
  end
  addall(signature(meta, false))

  -- the title is in the caption and the title lines; the docx title block would repeat it
  meta.title = nil
  doc.blocks = out
  return doc
end
