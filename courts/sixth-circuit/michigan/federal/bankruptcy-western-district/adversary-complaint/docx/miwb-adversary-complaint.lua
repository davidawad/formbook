-- U.S. Bankruptcy Court, W.D. Mich., adversary complaint (miwb), DOCX engine (docs/DOCX.md): the markdown contract ->
-- a Word document on reference.docx. Mirrors typst/miwb-adversary-complaint.typ:
--   * the caption (court, "In re" debtor block with the case number and chapter, the adversary parties with the
--     adversary number), then the title, centered and bold;
--   * allegations numbered 1, 2, ... (Fed. R. Civ. P. 10(b)): the number at 0.5 in, the text at 1 in (custom style
--     NumberedPara). Headings, block quotations and WHEREFORE clauses are not numbered;
--   * the statements the rules require (LBR 9004(c); Fed. R. Bankr. P. 7008(a); LBR 7008) are numbered and printed
--     after the first paragraph under JURISDICTION, from the frontmatter;
--   * lists are lettered a., b., ... (after a WHEREFORE: A., B., ...) with the custom style ListLetter;
--   * the signing block as a borderless two-column table.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter, and the court's
-- name is the court's own title.

local TEXT_W = 9360 -- 6.5 in of text width, in twips (letter, 1 in margins)
local BOLD = "<w:b/><w:bCs/>"
local COURT_TITLE = { "UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF MICHIGAN" }

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return (s:gsub('"', "&quot;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or a single value) as a Lua list of strings
local function strings(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then
    for _, item in ipairs(v) do out[#out + 1] = text(item) end
  else
    out[1] = text(v)
  end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("miwb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

local function flag(v)
  if type(v) == "boolean" then return v end
  return text(v) == "true"
end

-- one raw WordprocessingML paragraph; opts: style, ind (left twips), before, after, keepNext, jc, rpr (run XML)
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.before or opts.after then
    ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) .. '"/>'
  end
  if opts.ind then ppr = ppr .. '<w:ind w:left="' .. opts.ind .. '" w:firstLine="0"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local run = ""
  if s ~= nil and s ~= "" then
    run = '<w:r>' .. (opts.rpr and ('<w:rPr>' .. opts.rpr .. '</w:rPr>') or '')
      .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
  end
  return '<w:p>' .. (ppr ~= "" and ('<w:pPr>' .. ppr .. '</w:pPr>') or '') .. run .. '</w:p>'
end

local function spacer(twips)
  return p("", { style = "Single", before = twips, after = 0 })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- a table: widths in twips; rows[r][c] = { xml = paragraphs, borders = tcBorders XML or nil }
local function table_xml(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for c, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/>'
        .. (cell.borders or "") .. '</w:tcPr>' .. cell.xml .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- the caption (Fed. R. Bankr. P. 7010, 9004(b); LBR 9004(a), (b)): the typst caption as a two-column table
-- ---------------------------------------------------------------------------

local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local RULE_RIGHT = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function caption(meta)
  local c = need(meta, "debtor")
  local plaintiff = need(meta, "plaintiff")
  local defendants = need(meta, "defendants")
  local case = need(meta, "case")
  local out = {}
  for _, l in ipairs(COURT_TITLE) do out[#out + 1] = p(l, { style = "Centered", rpr = BOLD }) end
  out[#out + 1] = spacer(552)

  -- debtor block (In re:), with its case number and chapter on the right (LBR 9004(a): chapter under the number)
  local left, right = {}, {}
  left[#left + 1] = p("In re:", { style = "Single" })
  left[#left + 1] = spacer(276)
  for _, n in ipairs(strings(c.names)) do left[#left + 1] = p(n, { style = "Single", ind = 720 }) end
  left[#left + 1] = p(text(c.designation), { style = "Single", ind = 1728 })
  right[#right + 1] = p("Case No. " .. text(case.number), { style = "Single", ind = 360 })
  right[#right + 1] = p("Chapter " .. text(case.chapter), { style = "Single", ind = 360 })
  if case.judge ~= nil and text(case.judge) ~= "" then
    right[#right + 1] = p(text(case.judge), { style = "Single", ind = 360 })
  end
  out[#out + 1] = table_xml({ 5040, 4320 }, {
    { { xml = table.concat(left), borders = RULE }, { xml = table.concat(right) } },
  })
  out[#out + 1] = spacer(240)

  -- adversary block: the plaintiff, "v.", the defendants, with the rule on the right and bottom; the number on the right
  local pl, pr = {}, {}
  for _, n in ipairs(strings(plaintiff.names)) do pl[#pl + 1] = p(n, { style = "Single" }) end
  pl[#pl + 1] = p(text(plaintiff.designation), { style = "Single", ind = 1728 })
  pl[#pl + 1] = spacer(120)
  pl[#pl + 1] = p("v.", { style = "Single" })
  pl[#pl + 1] = spacer(120)
  for _, n in ipairs(strings(defendants.names)) do pl[#pl + 1] = p(n, { style = "Single" }) end
  pl[#pl + 1] = p(text(defendants.designation), { style = "Single", ind = 1728 })
  pr[#pr + 1] = p("Adv. Proc. No. " .. text(need(meta, "adversary_number")), { style = "Single", ind = 360 })
  out[#out + 1] = table_xml({ 5040, 4320 }, {
    { { xml = table.concat(pl), borders = RULE_RIGHT }, { xml = table.concat(pr) } },
  })

  out[#out + 1] = spacer(552)
  out[#out + 1] = p(text(need(meta, "title")):upper(), { style = "Centered", rpr = BOLD })
  out[#out + 1] = spacer(276)
  return out
end

-- ---------------------------------------------------------------------------
-- numbered paragraphs and generated statements
-- ---------------------------------------------------------------------------

local function inlines_of_markdown(md)
  local doc = pandoc.read(md, "markdown")
  local b = doc.blocks[1]
  return b and b.content or pandoc.Inlines({})
end

local function numbered(inlines, n)
  local content = pandoc.List({ pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. n .. '.</w:t></w:r><w:r><w:tab/></w:r>') })
  content:extend(inlines)
  return pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "NumberedPara" }))
end

-- the statements the rules require (MIWB-FORM-005, -007), from the frontmatter (see ../README.md)
local function generated_statements(meta)
  local case = need(meta, "case")
  local debtor = need(meta, "debtor")
  local dates = need(meta, "dates")
  local scope = "the United States Bankruptcy Court for the Western District of Michigan"
  if meta.division ~= nil and text(meta.division) ~= "" then
    scope = "the " .. text(meta.division) .. " of " .. scope
  end
  local petition = "The petition commencing the underlying Chapter " .. text(case.chapter) .. " case was filed on "
    .. text(dates.petition) .. ". " .. text(dates.later)
  local relation = "This Adversary Proceeding arises in and relates to *In re " .. text(debtor.name) .. "*, Case No. "
    .. text(case.number) .. " (Chapter " .. text(case.chapter) .. "), pending in " .. scope .. "."
  local core
  if flag(need(meta, "core")) then
    core = "This Adversary Proceeding is a core proceeding under 28 U.S.C. § 157(b)(2). "
  else
    core = "This Adversary Proceeding is a non-core proceeding under 28 U.S.C. § 157(c). "
  end
  local consent
  if flag(need(meta, "consent")) then
    consent = "The Plaintiff consents to the entry of a final order or judgment by the Bankruptcy Court."
  else
    consent = "The Plaintiff does not consent to the entry of a final order or judgment by the Bankruptcy Court."
  end
  return { petition, relation, core .. consent }
end

-- ---------------------------------------------------------------------------
-- signing block (LBR 9004(d)): the typst layout, as a borderless table
-- ---------------------------------------------------------------------------

local function signature(meta, date)
  local sig = need(meta, "signature")
  local right = {}
  right[#right + 1] = p("Respectfully submitted,", { style = "Single" })
  right[#right + 1] = spacer(276)
  for _, l in ipairs(strings(need(sig, "firm"))) do right[#right + 1] = p(l, { style = "Single" }) end
  right[#right + 1] = spacer(276)
  right[#right + 1] = p("By: /s/ " .. text(need(sig, "signer")), { style = "Single" })
  right[#right + 1] = p(text(need(sig, "signer")) .. " (" .. text(need(sig, "bar_id")) .. ")", { style = "Single" })
  right[#right + 1] = p(text(need(sig, "role")), { style = "Single" })
  right[#right + 1] = spacer(276)
  right[#right + 1] = p("BUSINESS ADDRESS:", { style = "Single" })
  for _, l in ipairs(strings(need(sig, "address"))) do right[#right + 1] = p(l, { style = "Single" }) end
  right[#right + 1] = p("Telephone " .. text(need(sig, "phone")), { style = "Single" })
  right[#right + 1] = p("Email " .. text(need(sig, "email")), { style = "Single" })
  return spacer(552) .. table_xml({ 4176, 5184 }, {
    { { xml = p("Dated: " .. date, { style = "Single" }) }, { xml = table.concat(right) } },
  })
end

-- ---------------------------------------------------------------------------
-- the complaint
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  local date = text(need(meta, "date"))
  -- the title is in the caption; pandoc would otherwise write the metadata title and date again
  meta.title = nil
  meta.date = nil
  meta.author = nil

  local n = 0
  local after_jurisdiction = false
  local generated_done = false
  local prayer = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      prayer = false
      after_jurisdiction = pandoc.utils.stringify(b.content):lower():find("^jurisdiction") ~= nil and not generated_done
      out[#out + 1] = b
    elseif b.t == "Para" then
      local s = pandoc.utils.stringify(b)
      if s:find("^WHEREFORE") then
        prayer = true
        out[#out + 1] = b
      else
        n = n + 1
        out[#out + 1] = numbered(b.content, n)
        if after_jurisdiction then
          for _, g in ipairs(generated_statements(meta)) do
            n = n + 1
            out[#out + 1] = numbered(inlines_of_markdown(g), n)
          end
          after_jurisdiction = false
          generated_done = true
        end
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local label
        if b.t == "BulletList" then
          label = "\u{2022}"
        elseif prayer then
          label = string.char(64 + i) .. "."
        else
          label = string.char(96 + i) .. "."
        end
        local blocks = {}
        for j, ib in ipairs(item) do
          if j == 1 and (ib.t == "Para" or ib.t == "Plain") then
            local content = pandoc.List({ pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. label .. '</w:t></w:r><w:r><w:tab/></w:r>') })
            content:extend(ib.content)
            blocks[#blocks + 1] = pandoc.Para(content)
          else
            blocks[#blocks + 1] = ib
          end
        end
        out[#out + 1] = pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = "ListLetter" }))
      end
    else
      out[#out + 1] = b
    end
  end

  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta, date))
  return pandoc.Pandoc(out, meta)
end
