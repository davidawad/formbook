-- U.S. Bankruptcy Court, W.D. Mich., motion with brief in support, in an adversary proceeding (miwb), DOCX engine
-- (docs/DOCX.md): the markdown contract -> a Word document on reference.docx. Mirrors typst/miwb-motion-brief.typ:
--   * the motion, then the brief in support, each with its own caption and title (the brief starts a new section,
--     and its page count restarts at 1);
--   * the caption (court, "In re" debtor block with the case number and chapter, the adversary parties with the
--     adversary number), then the document's title, centered and bold;
--   * the motion's body (from the frontmatter) with the LBR 9004(c) statement of the petition date printed after its
--     first paragraph; the brief's body is the markdown of the sample;
--   * headings: levels 1 and 2 centered bold capitals, level 3 bold at the margin; lists lettered a., b., ...;
--   * the signing block as a borderless two-column table.
-- Nothing case-specific is written here: every string comes from the sample's YAML frontmatter, and the court's
-- name is the court's own title.

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
  if meta[key] == nil then error("miwb-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one raw WordprocessingML paragraph; opts: style, ind (left twips), before, after, jc, rpr (run XML)
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
-- the document head: court, caption, title (LBR 9004(a), (b); Fed. R. Bankr. P. 7010)
-- ---------------------------------------------------------------------------

local RULE = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local RULE_RIGHT = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function document_head(meta, title)
  local c = need(meta, "debtor")
  local plaintiff = need(meta, "plaintiff")
  local defendants = need(meta, "defendants")
  local case = need(meta, "case")
  local out = {}
  for _, l in ipairs(COURT_TITLE) do out[#out + 1] = p(l, { style = "Centered", rpr = BOLD }) end
  out[#out + 1] = spacer(552)

  -- debtor block (In re:), with its case number and chapter on the right (LBR 9004(a))
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
  out[#out + 1] = p(title:upper(), { style = "Centered", rpr = BOLD })
  out[#out + 1] = spacer(276)
  return out
end

-- ---------------------------------------------------------------------------
-- statements from the frontmatter (LBR 9004(c)) and the signing block (LBR 9004(d))
-- ---------------------------------------------------------------------------

local function petition_statement(meta)
  local case = need(meta, "case")
  local dates = need(meta, "dates")
  return "The petition commencing the underlying Chapter " .. text(case.chapter) .. " case was filed on "
    .. text(dates.petition) .. ". " .. text(dates.later)
end

local function signature(meta, date)
  local sig = need(meta, "signature")
  local right = {}
  right[#right + 1] = p("Respectfully submitted,", { style = "Single" })
  right[#right + 1] = spacer(276)
  for _, l in ipairs(strings(need(sig, "firm"))) do right[#right + 1] = p(l, { style = "Single" }) end
  right[#right + 1] = spacer(276)
  right[#right + 1] = p("By: /s/ " .. text(need(sig, "signer")), { style = "Single" })
  right[#right + 1] = p(text(need(sig, "signer")) .. " (" .. text(need(sig, "bar_id")) .. ")", { style = "Single" })
  for _, l in ipairs(strings(sig.also)) do right[#right + 1] = p(l, { style = "Single" }) end
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

-- the end of the motion's section: the page size, margins and footer repeat those of reference.docx; the brief's
-- section (the body's final sectPr, from reference.docx) restarts its page numbers at 1
local SECTION_BREAK = '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:sectPr>'
  .. '<w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/>'
  .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  .. '<w:cols w:space="720"/></w:sectPr></w:pPr></w:p>'

-- ---------------------------------------------------------------------------
-- the body: lettered lists, and the blocks of a markdown body
-- ---------------------------------------------------------------------------

local function body_blocks(blocks, out)
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local label = (b.t == "BulletList") and "\u{2022}" or (string.char(96 + i) .. ".")
        local content = {}
        for j, ib in ipairs(item) do
          if j == 1 and (ib.t == "Para" or ib.t == "Plain") then
            local lead = pandoc.List({ pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. label .. '</w:t></w:r><w:r><w:tab/></w:r>') })
            lead:extend(ib.content)
            content[#content + 1] = pandoc.Para(lead)
          else
            content[#content + 1] = ib
          end
        end
        out[#out + 1] = pandoc.Div(content, pandoc.Attr("", {}, { ["custom-style"] = "ListLetter" }))
      end
    else
      out[#out + 1] = b
    end
  end
end

-- the motion's body is a YAML block scalar of markdown: pandoc reads it as blocks (MetaBlocks)
-- (in a filter, a multi-paragraph metadata value is a plain Lua list of blocks; a single line is not)
local function motion_blocks(motion)
  local body = need(motion, "body")
  local out = {}
  if type(body) == "table" and body[1] ~= nil and body[1].t == "Para" then
    for _, b in ipairs(body) do out[#out + 1] = b end
    return out
  end
  return pandoc.read(text(body), "markdown").blocks
end

function Pandoc(doc)
  local meta = doc.meta
  local date = text(need(meta, "date"))
  local motion = need(meta, "motion")
  local out = {}

  -- the motion, with the LBR 9004(c) statement after its first paragraph
  for _, x in ipairs(document_head(meta, text(need(motion, "title")))) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  local inserted = false
  for _, b in ipairs(motion_blocks(motion)) do
    local chunk = {}
    body_blocks({ b }, chunk)
    for _, c in ipairs(chunk) do out[#out + 1] = c end
    if not inserted and b.t == "Para" then
      out[#out + 1] = pandoc.Para(pandoc.read(petition_statement(meta), "markdown").blocks[1].content)
      inserted = true
    end
  end
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta, date))

  -- the brief in support: a new section, with its own caption, and its page numbers restart
  out[#out + 1] = pandoc.RawBlock("openxml", SECTION_BREAK)
  for _, x in ipairs(document_head(meta, text(need(meta, "brief_title")))) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  body_blocks(doc.blocks, out)
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta, date))

  -- the title lines are in the captions; pandoc would otherwise write the metadata title and date again
  meta.title = nil
  meta.date = nil
  meta.author = nil
  return pandoc.Pandoc(out, meta)
end
