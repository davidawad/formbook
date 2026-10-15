-- U.S. Bankruptcy Court, M.D. Alabama: adversary complaint, pandoc filter for the docx engine.
-- The same form as the typst template (typst/almb-adversary-complaint.typ) and the same contract: every
-- case-specific string comes from the YAML frontmatter of the sample. The court title, the boxed caption, the
-- title, the consent block and the signature block are WordprocessingML written here; the body paragraphs,
-- headings and numbered allegations stay pandoc's, with their formatting from reference.docx (make-reference.sh).
-- Requirement IDs (ALMB-ADV-...) are in ../README.md. Known gaps and BLOCKED items: ../README.md, "Engines".

local DOUBLE = 480 -- 24 pt exact: the line pitch of the body (typst line-pitch)
local SINGLE = 240
local HALF = 240 -- 12 pt: half a line pitch, the gap the typst template uses
local INDENT = 720 -- 0.5 in first-line indent (para-indent)
local CAPTION_LEFT = 4752 -- 3.3 in boxed party column (caption-col)
local TEXT_WIDTH = 9360 -- 6.5 in between the 1-inch margins
local SIG_RIGHT = 4608 -- 3.2 in signature column

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(v)
  if v == nil then return "" end
  return (pandoc.utils.stringify(v):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("almb-adversary-complaint: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- One run of text. rpr is already-built run properties ("" for none).
local function run(s, rpr)
  if s == "" then return "" end
  rpr = rpr or ""
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

-- One WordprocessingML paragraph. opts: line (twips), exact (line rule), before, after (twips), first
-- (first-line indent), left (indent), jc, bold, caps, keep_next, page_break, rule_below (a rule under the text),
-- underline (the text is underlined), xml (runs already built with run(), used instead of s).
local function para(s, o)
  o = o or {}
  local ppr = ""
  if o.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if o.page_break then ppr = ppr .. "<w:pageBreakBefore/>" end
  if o.rule_below then ppr = ppr .. '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>' end
  ppr = ppr .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="%s"/>',
    o.before or 0, o.after or 0, o.line or SINGLE, o.exact and "exact" or "auto")
  if o.left or o.first then
    ppr = ppr .. string.format('<w:ind w:left="%d" w:firstLine="%d"/>', o.left or 0, o.first or 0)
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  local rpr = ""
  if o.bold then rpr = rpr .. "<w:b/>" end
  if o.caps then rpr = rpr .. "<w:caps/>" end
  if o.underline then rpr = rpr .. '<w:u w:val="single"/>' end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (o.xml or run(s, rpr)) .. "</w:p>"
end

-- An empty paragraph exactly `twips` high (the typst v() gaps).
local function gap(twips)
  return para("", { line = twips, exact = true })
end

-- A table with the given column widths; cells is a list of {width, xml-of-paragraphs, borders, pad}.
local function table_xml(cols, rows, opts)
  opts = opts or {}
  local grid = {}
  for _, w in ipairs(cols) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local out = {}
  for _, row in ipairs(rows) do
    local cells = {}
    for i, cell in ipairs(row) do
      local tcpr = '<w:tcW w:w="' .. cols[i] .. '" w:type="dxa"/>'
      if cell.box then
        tcpr = tcpr .. '<w:tcBorders><w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
          .. '<w:left w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
          .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
          .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
      end
      if cell.pad then
        tcpr = tcpr .. string.format('<w:tcMar><w:top w:w="%d" w:type="dxa"/><w:left w:w="%d" w:type="dxa"/>'
          .. '<w:bottom w:w="%d" w:type="dxa"/><w:right w:w="%d" w:type="dxa"/></w:tcMar>',
          cell.pad[1], cell.pad[2], cell.pad[3], cell.pad[4])
      end
      cells[#cells + 1] = "<w:tc><w:tcPr>" .. tcpr .. "</w:tcPr>" .. cell.xml .. "</w:tc>"
    end
    local trpr = opts.no_split and "<w:trPr><w:cantSplit/></w:trPr>" or ""
    out[#out + 1] = "<w:tr>" .. trpr .. table.concat(cells) .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_WIDTH .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. "</w:tblPr><w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid>" .. table.concat(out) .. "</w:tbl>"
end

-- ---------------------------------------------------------------------------
-- Court title, caption, title
-- ---------------------------------------------------------------------------

local function court_title(meta)
  local out = {}
  for _, line in ipairs(need(meta, "court")) do
    out[#out + 1] = para(text(line), { jc = "center", bold = true, line = SINGLE })
  end
  return out
end

-- The boxed left column: "IN RE:", the debtor, a rule, then each side with its designation (FRBP 7010 caption).
local function caption_left(meta)
  local debtor = need(meta, "debtor")
  local sides = need(meta, "caption")
  local out = { para("IN RE:") }
  out[#out + 1] = gap(HALF)
  for _, n in ipairs(debtor.name) do out[#out + 1] = para(text(n), { left = INDENT }) end
  out[#out + 1] = gap(HALF)
  out[#out + 1] = para("", { rule_below = true, line = SINGLE })
  out[#out + 1] = gap(HALF)
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do out[#out + 1] = para(text(n)) end
    out[#out + 1] = para(text(side.designation), { left = INDENT })
    out[#out + 1] = gap(HALF)
    if i < #sides then
      out[#out + 1] = para("v.", { jc = "center" })
      out[#out + 1] = gap(HALF)
    end
  end
  return table.concat(out)
end

-- The right column: the case number and the adversary number (a blank line when the clerk has not assigned one).
local function caption_right(meta)
  local debtor = need(meta, "debtor")
  local adv = text(meta.adversary_number)
  local out = { gap(1056), para("CASE NO. " .. text(debtor.case_number)), gap(1200) }
  if adv == "" then
    local blank = run("\u{00A0}", '<w:u w:val="single"/>'):gsub("\u{00A0}", string.rep("\u{00A0}", 12))
    out[#out + 1] = para("", { xml = run("ADV. PROC. NO. ") .. blank })
  else
    out[#out + 1] = para("ADV. PROC. NO. " .. adv)
  end
  return table.concat(out)
end

local function caption(meta)
  return table_xml({ CAPTION_LEFT, TEXT_WIDTH - CAPTION_LEFT }, {
    {
      { box = true, pad = { 160, 173, 260, 173 }, xml = caption_left(meta) },
      { pad = { 0, 240, 0, 0 }, xml = caption_right(meta) },
    },
  }, { no_split = true })
end

-- ---------------------------------------------------------------------------
-- Consent statement (FRBP 7008(a)), placed under the caption; the body does not repeat it.
-- ---------------------------------------------------------------------------

local function consent(meta)
  local j = need(meta, "jurisdiction")
  local debtor = need(meta, "debtor")
  local name = text(debtor.name[1])
  local out = {
    para("Jurisdiction and Consent", { jc = "center", bold = true, line = DOUBLE, before = HALF, keep_next = true }),
    para("This adversary proceeding arises in and relates to the " .. text(debtor.chapter) .. " case of " .. name
      .. ", Case No. " .. text(debtor.case_number) .. ", pending in the United States Bankruptcy Court for the "
      .. text(j.district) .. ".", { line = DOUBLE, exact = true, first = INDENT }),
    para(text(j.consent), { line = DOUBLE, exact = true, first = INDENT }),
  }
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (LBR 9011-1: name, address, telephone and email of each signer; /s/ is acceptable)
-- ---------------------------------------------------------------------------

-- Every line is kept with the next, so the signature block never splits across pages.
local function signer_block(sig)
  local out = { para("/s/ " .. text(sig.signer), { keep_next = true }) }
  for _, l in ipairs(sig.lines or {}) do out[#out + 1] = para(text(l), { keep_next = true }) end
  return table.concat(out)
end

local function signature(meta)
  local sig = need(meta, "signature")
  local right = { para("Respectfully submitted,", { keep_next = true }), gap(HALF), para(text(sig.firm), { keep_next = true }), gap(HALF) }
  right[#right + 1] = signer_block(sig)
  for _, also in ipairs(sig.also or {}) do
    right[#right + 1] = gap(HALF)
    right[#right + 1] = para("-and-", { keep_next = true })
    right[#right + 1] = gap(HALF)
    right[#right + 1] = signer_block(also)
  end
  local left = para(meta.date and ("Dated: " .. text(meta.date)) or "", { keep_next = true })
  return table_xml({ TEXT_WIDTH - SIG_RIGHT, SIG_RIGHT }, {
    { { xml = left }, { xml = table.concat(right) } },
  }, { no_split = true })
end

-- ---------------------------------------------------------------------------
-- The complaint body: numbered allegations keep the number the markdown gives them.
-- ---------------------------------------------------------------------------

local function numbered(n, blocks)
  local out = {}
  for i, b in ipairs(blocks) do
    if i == 1 and (b.t == "Para" or b.t == "Plain") then
      local content = { pandoc.Str(tostring(n) .. "."), pandoc.Space() }
      for _, x in ipairs(b.content) do content[#content + 1] = x end
      out[#out + 1] = pandoc.Para(content)
    else
      out[#out + 1] = b
    end
  end
  return out
end

local function body(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "OrderedList" then
      local start = b.listAttributes.start
      for k, item in ipairs(b.content) do
        for _, p in ipairs(numbered(start + k - 1, item)) do out[#out + 1] = p end
      end
    else
      out[#out + 1] = b
    end
  end
  -- The prayer (last paragraph) is kept with the signature block that follows it.
  local last = out[#out]
  if last and (last.t == "Para" or last.t == "Plain") then
    out[#out] = pandoc.Div({ pandoc.Para(last.content) }, { ["custom-style"] = "Prayer" })
  end
  return out
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtor", "caption", "title", "jurisdiction", "signature" }) do
    need(meta, k)
  end
  local out = {}
  local function add(x) out[#out + 1] = raw(x) end
  for _, p in ipairs(court_title(meta)) do add(p) end
  add(gap(DOUBLE))
  add(caption(meta))
  add(gap(DOUBLE))
  add(para(string.upper(text(meta.title)), { jc = "center", bold = true, line = SINGLE }))
  add(gap(HALF))
  for _, p in ipairs(consent(meta)) do add(p) end
  for _, b in ipairs(body(doc.blocks)) do out[#out + 1] = b end
  add(signature(meta))
  -- Word needs a paragraph after a table that ends the body.
  add(para(""))
  -- Emptied metadata: pandoc would otherwise print the frontmatter title as a Title paragraph above the caption.
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
