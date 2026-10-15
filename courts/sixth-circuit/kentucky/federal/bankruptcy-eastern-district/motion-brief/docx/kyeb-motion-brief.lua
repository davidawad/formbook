-- E.D. Ky. bankruptcy motion with memorandum, DOCX engine (docs/DOCX.md): markdown + YAML metadata -> Word on
-- reference.docx. Mirrors typst/kyeb-motion-brief.typ: the caption table, the court and title lines, the
-- notice of hearing under the title (LBR 9013-1(a), 9014-1(a)), the body (unnumbered, first-line indented),
-- the signature block (FRBP 9011(a)) and the certificate of service. No case-specific text.

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

-- a metadata value as a plain list of inlines (a plain YAML string is read as markdown, as pandoc does)
local function inl(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "string" or v.t == "MetaString" then
    v = pandoc.utils.blocks_to_inlines(pandoc.read(pandoc.utils.stringify(v), "markdown").blocks)
  elseif v.t == "MetaBlocks" then
    v = pandoc.utils.blocks_to_inlines(v)
  elseif v.t ~= nil and v.t ~= "MetaInlines" then
    return out
  end
  for _, x in ipairs(v) do out[#out + 1] = x end
  return out
end

local function cat(...)
  local out = {}
  for _, list in ipairs({ ... }) do
    for _, x in ipairs(list) do out[#out + 1] = x end
  end
  return out
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para(style, content)
  return styled(style, { pandoc.Para(content) })
end

-- an empty paragraph of a given height (twips after), the template's v(...) gap
local function spacer(after, style)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. (style or "Single") ..
    '"/><w:spacing w:before="0" w:after="' .. after .. '"/></w:pPr></w:p>')
end

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
local LINE_PITCH = 480 -- twips (24 pt)
local HALF_LINE = 240  -- twips (12 pt)

-- ---------------------------------------------------------------------------
-- caption (FRBP 9004(b): court, title of the case, case number and adversary number if any, designation)
-- ---------------------------------------------------------------------------

local function caption_table(meta)
  local cap = meta.caption
  local debtors = cap.debtors

  local left_top = { para("Single", { pandoc.Str("In re:") }), spacer(HALF_LINE) }
  for i, n in ipairs(debtors.names) do
    local content = inl(n)
    if i == 1 and debtors.footnote then
      content = cat(content, { pandoc.Note({ pandoc.Para(inl(debtors.footnote)) }) })
    end
    left_top[#left_top + 1] = para("Single", content)
  end
  left_top[#left_top + 1] = para("CaptionDesignation", inl(debtors.designation))

  local right_top = { para("Single", inl(meta.chapter)), spacer(HALF_LINE),
    para("Single", cat({ pandoc.Str("Case No. ") }, inl(meta.case_number))) }
  if meta.jointly_administered == true then
    right_top[#right_top + 1] = para("Single", { pandoc.Str("(Jointly Administered)") })
  end

  local left_bot = {}
  for i, side in ipairs(cap.parties) do
    for _, n in ipairs(side.names) do left_bot[#left_bot + 1] = para("Single", inl(n)) end
    if side.serve then
      for _, l in ipairs(side.serve) do left_bot[#left_bot + 1] = para("Single", inl(l)) end
      left_bot[#left_bot + 1] = spacer(HALF_LINE)
    end
    left_bot[#left_bot + 1] = para("CaptionDesignation", inl(side.designation))
    if i < #cap.parties then
      left_bot[#left_bot + 1] = spacer(HALF_LINE)
      left_bot[#left_bot + 1] = para("Single", { pandoc.Str("v.") })
      left_bot[#left_bot + 1] = spacer(HALF_LINE)
    end
  end

  local adv = pandoc.utils.stringify(meta.adversary_number or "")
  local right_bot = { spacer(LINE_PITCH) }
  if adv ~= "" then
    right_bot[#right_bot + 1] = para("Single", cat({ pandoc.Str("Adv. No. ") }, inl(meta.adversary_number)))
  end

  local rows = {
    pandoc.Row({ pandoc.Cell(left_top), pandoc.Cell(right_top) }),
    pandoc.Row({ pandoc.Cell(left_bot), pandoc.Cell(right_bot) }),
  }
  return pandoc.Table(pandoc.Caption(),
    { { pandoc.AlignDefault, 3.3 / 6.5 }, { pandoc.AlignDefault, 3.2 / 6.5 } },
    pandoc.TableHead({}), { pandoc.TableBody(rows) }, pandoc.TableFoot({}))
end

-- ---------------------------------------------------------------------------
-- notice of hearing (LBR 9013-1(a), 9014-1(a)): printed under the title when the motion is set for hearing
-- ---------------------------------------------------------------------------

local function hearing_notice(meta)
  local h = meta.hearing
  local out = {}
  if h == nil then return out end
  out[#out + 1] = spacer(HALF_LINE)
  local lines = {
    { "date", "Hearing: " }, { "time", "Time: " }, { "place", "Place: " },
    { "objection_deadline", "Objections due: " },
  }
  for _, l in ipairs(lines) do
    if h[l[1]] ~= nil then
      out[#out + 1] = para("Single", cat({ pandoc.Str(l[2]) }, inl(h[l[1]])))
    end
  end
  out[#out + 1] = spacer(HALF_LINE)
  return out
end

-- ---------------------------------------------------------------------------
-- signature block (FRBP 9011(a)) and certificate of service (FRBP 9014(b), by convention)
-- ---------------------------------------------------------------------------

local function signature_block(meta)
  local sig = meta.signature
  local out = {
    spacer(LINE_PITCH, "Signature"),
    pandoc.Para(cat({ pandoc.Str("Dated: ") }, inl(meta.date), { TAB }, inl(sig.firm))),
    spacer(LINE_PITCH, "SignatureBlock"),
    para("SignatureBlock", cat({ pandoc.Str("By: /s/ ") }, inl(sig.signer))),
  }
  for _, l in ipairs(sig.lines or {}) do
    out[#out + 1] = para("SignatureBlock", inl(l))
  end
  return out
end

local function certificate_block(meta)
  local cert = meta.certificate_of_service
  local out = {}
  if cert == nil then return out end
  out[#out + 1] = spacer(LINE_PITCH)
  out[#out + 1] = para("Centered", { pandoc.Strong({ pandoc.Str("CERTIFICATE OF SERVICE") }) })
  out[#out + 1] = pandoc.Para(inl(cert.text))
  out[#out + 1] = spacer(LINE_PITCH, "Signature")
  out[#out + 1] = pandoc.Para(cat({ pandoc.Str("Dated: ") }, inl(meta.date), { TAB },
    { pandoc.Str("By: /s/ ") }, inl(meta.signature.signer)))
  return out
end

-- ---------------------------------------------------------------------------
-- filter
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local out = {}

  -- first page: court, caption, title, notice of hearing
  for _, l in ipairs(meta.court) do
    out[#out + 1] = para("Centered", { pandoc.Strong(inl(l)) })
  end
  out[#out + 1] = spacer(LINE_PITCH)
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = spacer(HALF_LINE)
  for _, l in ipairs(meta.title) do
    out[#out + 1] = para("Centered", { pandoc.Strong(inl(l)) })
  end
  for _, b in ipairs(hearing_notice(meta)) do out[#out + 1] = b end
  out[#out + 1] = spacer(HALF_LINE)

  -- body: the author's headings, lists (lettered a., b., c.) and paragraphs as written
  for _, b in ipairs(doc.blocks) do
    if b.t == "OrderedList" then
      b.listAttributes.style = pandoc.LowerAlpha
      b.listAttributes.delimiter = pandoc.Period
    end
    out[#out + 1] = b
  end

  for _, b in ipairs(signature_block(meta)) do out[#out + 1] = b end
  for _, b in ipairs(certificate_block(meta)) do out[#out + 1] = b end

  -- the metadata title and date are written by the template above, not by pandoc's title block
  meta.title = nil
  meta.date = nil
  return pandoc.Pandoc(out, meta)
end
