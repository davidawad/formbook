-- ndb-court-form.lua (docx engine): the layout the typst template (typst/ndb-*.typ) gives the sample, built from its
-- YAML frontmatter with pandoc's AST and raw OpenXML, so that it reads and breaks as the typst render does. Rules and
-- layout values: ../README.md, typst/ndb-*.typ and docx/reference.xml. The same file serves the adversary complaint
-- and the motion brief of this court:
--   cover        court name, caption table (party column, ")" column, case block; one table row per line, as typst's
--                grid), title (the typst cover)
--   numbering    every body paragraph is numbered 1, 2, ... (FRCP 10(b)) by text, not by a list: the number, a tab
--                to 1 in (typst: the number in a box of the paragraph indent); "~ ..." continuations (flush left) and
--                "WHEREFORE" paragraphs are not numbered; quotations are Block Text
--   consent      the consent statement (FRBP 7008(a)), when the frontmatter has one, sits before the signature and
--                keeps with it; otherwise the last body paragraph does
--   signature    a two-column table (FRBP 9011(a))
--   certificate  optional certificate of service after the signature
-- Footnotes are pandoc's own (the sample's [^id] definitions, Footnote Text). Lists are not supported, as in the
-- typst template. Everything printed comes from the sample: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_MID = 4896, 432      -- typst caption-left 3.4 in, caption-mid 0.3 in
local CAP_STEP = 720                     -- typst caption-step 0.5 in
local SIG_LEFT = 4320                    -- typst sig-left 3.0 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A single-pitch paragraph: o = { before, after, left, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless table: widths, then rows of cells (each a list of paragraphs).
local function tbl(widths, rows, trpr)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. table.concat(c) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return xe.raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>')
end

-- The caption rows of the left column as { text, indent level, right-column text }, as caption-rows() in the typst
-- template: the case number and chapter at the debtor's first lines, the adversary number at the first party's.
local function caption_rows(m)
  local c = m.caption
  if c == nil then error("ndb-court-form.lua: the sample has no caption in its frontmatter") end
  local rows = {}
  local function add(t, level) rows[#rows + 1] = { plain(t), level, "" } end
  if c.debtors then
    add("In re:", 0)
    for _, d in ipairs(c.debtors) do add(d, 0) end
    if c.debtor_designation then add(c.debtor_designation, 1) end
    add("", 0)
  end
  local first_party = #rows + 1
  for k, pt in ipairs(c.parties) do
    if k > 1 then
      add("v.", 0)
      add("", 0)
    end
    for _, n in ipairs(pt.names) do add(n, 0) end
    add(pt.designation, 1)
  end
  local case_at = c.debtors and 2 or 1
  rows[case_at][3] = "Case No. " .. plain(m.case_number)
  rows[case_at + 1][3] = plain(m.chapter)
  rows[math.max(first_party, case_at + 3)][3] = "Adversary No. " .. plain(m.adversary_number)
  return rows
end

local function caption_table(m)
  local rows = {}
  for _, r in ipairs(caption_rows(m)) do
    rows[#rows + 1] = { { p(xe.inl(r[1]), { left = r[2] * CAP_STEP }) }, { p(xe.runs(")"), { jc = "center" }) },
      { p(xe.inl(r[3])) } }
  end
  return tbl({ CAP_LEFT, CAP_MID, TEXTW - CAP_LEFT - CAP_MID }, rows)
end

-- The signature (FRBP 9011(a)): "Dated" at the left; the closing, "By: /s/ signer" and the signer's lines at the
-- right, an empty item a blank single line; a single line of space above the block (typst: block above).
local function signature_table(m)
  local s = m.signature
  if s == nil then error("ndb-court-form.lua: the sample has no signature in its frontmatter") end
  local items = {}
  if s.closing then
    items[#items + 1] = plain(s.closing)
    items[#items + 1] = ""
  end
  items[#items + 1] = "By: /s/ " .. plain(s.signer)
  items[#items + 1] = ""
  for _, l in ipairs(s.lines) do items[#items + 1] = l end
  local right, gap = {}, SINGLE
  for _, t in ipairs(items) do
    if t == "" then
      gap = gap + SINGLE
    else
      right[#right + 1] = p(xe.inl(t), { before = gap })
      gap = 0
    end
  end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT },
    { { { p(xe.runs("Dated: ") .. xe.inl(m.date), { before = SINGLE }) }, right } }, '<w:trPr><w:cantSplit/></w:trPr>')
end

-- A heading: one centered bold line at the body pitch, as written (the heading style's capitals off), kept with the
-- text after it.
local function heading(content, level)
  local runs = xe.inl(content, { b = true })
  runs = runs:gsub("<w:rPr>(.-)</w:rPr>", function(x)
    local at = x:find("<w:sz", 1, true) or x:find("<w:u ", 1, true) or (#x + 1)
    return "<w:rPr>" .. x:sub(1, at - 1) .. '<w:caps w:val="0"/>' .. x:sub(at) .. "</w:rPr>"
  end)
  return xe.raw(xe.para({ xe.style("Heading" .. math.min(level, 2)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, runs))
end

-- A body paragraph (Body Text: the double pitch, the half-inch first-line indent) through pandoc, so its footnotes
-- are Word footnotes; style "Body Text Flush" (a continuation) or "Body Text Keep" (kept with the signature).
local function body_div(inlines, style)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style or "Body Text" })
end

local function starts_with(inlines, marker)
  local first = inlines[1]
  if first and first.t == "Str" and first.text:sub(1, #marker) == marker then
    local out = pandoc.Inlines({})
    local rest = first.text:sub(#marker + 1)
    if rest ~= "" then out:insert(pandoc.Str(rest)) end
    for i = 2, #inlines do out:insert(inlines[i]) end
    if out[1] and out[1].t == "Space" then out:remove(1) end
    return out
  end
  return nil
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A metadata value (lead-in, consent statement, certificate) as body inlines, under the same break rules.
local function meta_inlines(v)
  return xe.inlines(pandoc.Inlines(v):walk({ Str = breaks }))
end

function Pandoc(doc)
  -- the metadata as written (Pandoc:walk walks it too, and stringify drops the no-break hyphens xe.inlines adds)
  local m = doc.meta
  -- headings go through xe.inl (its own rules), the body through pandoc after xe.inlines
  doc = doc:walk({ Str = breaks })
  local walked = doc:walk({ Inlines = xe.inlines }).blocks
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover: court name, caption a double line below it, title a double line below the caption (typst cover())
  add(xe.raw(p(xe.runs("IN THE UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" }) ..
    p(xe.runs("FOR THE DISTRICT OF NORTH DAKOTA", { b = true }), { jc = "center", after = BODY })))
  add(caption_table(m))
  add(xe.raw(p(xe.inl(m.title, { b = true }), { jc = "center", before = BODY, after = SINGLE, keep = true })))

  -- lead-in (unnumbered, indented), when the form has one
  if m.lead_in then add(body_div(meta_inlines(m.lead_in))) end

  local n = 0
  local last_body = nil
  for i, raw_block in ipairs(doc.blocks) do
    local b = walked[i]
    if b.t == "Para" or b.t == "Plain" then
      local rest = starts_with(b.content, "~")
      local wherefore = b.content[1] and b.content[1].t == "Str" and b.content[1].text:sub(1, 9) == "WHEREFORE"
      if rest then
        last_body = body_div(rest, "Body Text Flush")
      elseif wherefore then
        last_body = body_div(b.content)
      else
        n = n + 1
        local content = pandoc.Inlines({ pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
        content:extend(b.content)
        last_body = body_div(content)
      end
      add(last_body)
    elseif b.t == "Header" then
      add(heading(raw_block.content, b.level))
      last_body = nil
    elseif b.t == "BlockQuote" then
      add(pandoc.Div(b.content, { ["custom-style"] = "Block Text" }))
      last_body = nil
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      error("ndb-court-form.lua: lists are not supported by this template (as in typst/)")
    else
      add(b)
      last_body = nil
    end
  end

  -- the consent statement (complaint) and the signature stay together, as the typst template keeps them; without
  -- one, the last body paragraph keeps with the signature
  if m.consent_statement then
    add(body_div(meta_inlines(m.consent_statement), "Body Text Keep"))
  elseif last_body then
    last_body.attributes["custom-style"] = last_body.attributes["custom-style"] == "Body Text Flush"
      and "Body Text Flush Keep" or "Body Text Keep"
  end
  add(signature_table(m))

  if m.certificate_of_service then
    add(xe.raw(p(xe.runs("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", before = BODY, keep = true,
      line = BODY })))
    for _, para in ipairs(m.certificate_of_service) do add(body_div(meta_inlines(para))) end
  end

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
