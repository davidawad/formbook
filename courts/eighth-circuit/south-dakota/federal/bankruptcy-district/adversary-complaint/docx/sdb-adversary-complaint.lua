-- Bankr. D.S.D. (sdb): pandoc filter for the docx engine (one copy per doc type).
-- The same content as the typst template of this doc type (typst/sdb-motion-brief.typ), from the same markdown
-- contract: the caption, title, opening sentence, signature block and certificate are built here from the
-- frontmatter; the body paragraphs and headings stay pandoc's (styles in reference.docx). The only line that
-- differs between the copies is TYPE. Known gaps: docs/DOCX.md and README.md (Engines).

local TYPE = "complaint" -- "motion" | "complaint"

local NUMBERED = (TYPE == "complaint")   -- FRCP 10(b): the complaint's allegations are numbered
local CAPTION_JUDGE = (TYPE == "motion") -- judge and hearing lines appear in a motion's caption only
local OPENING = (TYPE == "motion")       -- "X moves the Court for Y under Z." (FRBP 9013(b))
local CERTIFICATE = (TYPE == "motion")
local KEEP_SIGNATURE = (TYPE == "motion") -- the last paragraph stays with the signature block

local LINE = 276          -- 13.8 pt exact: the typst leading (single spacing, see reference.docx)
local PARA_GAP = 240      -- 1 em at 12 pt
local SECTION_GAP = 360   -- 1.5 em
local SIG_INDENT = 4680   -- 3.25 in: the signature block starts at the middle of the page
local CAPTION_COLS = { 4752, 432, 4176 } -- 3.3 in party column (0.2 in right pad), 0.3 in ")" column, the rest

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function rpr(o)
  local p = ""
  if o.b then p = p .. "<w:b/>" end
  if o.i then p = p .. "<w:i/>" end
  return p ~= "" and ("<w:rPr>" .. p .. "</w:rPr>") or ""
end

local function run(s, o)
  return "<w:r>" .. rpr(o or {}) .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

-- Inline content (a list of pandoc inlines) as WordprocessingML runs: emphasis and bold kept, the rest as text.
local runs
runs = function(inlines, o)
  o = o or {}
  local out = {}
  for _, el in ipairs(inlines) do
    if el.t == "Str" then
      out[#out + 1] = run(el.text, o)
    elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then
      out[#out + 1] = run(" ", o)
    elseif el.t == "Emph" then
      out[#out + 1] = runs(el.content, { b = o.b, i = true })
    elseif el.t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = o.i })
    elseif el.t == "Quoted" then
      local q = (el.quotetype == "DoubleQuote") and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], o) .. runs(el.content, o) .. run(q[2], o)
    elseif el.content then
      out[#out + 1] = runs(el.content, o)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), o)
    end
  end
  return table.concat(out)
end

-- A frontmatter value (string, markdown inlines, or anything else) as runs.
local function mruns(v, o)
  if v == nil then return "" end
  if type(v) == "string" then return run(v, o) end
  if v.t == "MetaInlines" then return runs(v, o) end
  return run(pandoc.utils.stringify(v), o)
end

local function txt(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- One WordprocessingML paragraph. o: before, after (twips), first (first-line indent), left (indent),
-- jc (alignment), keep_next. Line spacing is the exact typst leading.
local function p(content, o)
  o = o or {}
  local ppr = ""
  if o.keep_next then ppr = ppr .. "<w:keepNext/>" end
  ppr = ppr .. string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>',
    o.before or 0, o.after or 0, LINE)
  ppr = ppr .. string.format('<w:ind w:left="%d" w:firstLine="%d"/>', o.left or 0, o.first or 0)
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (content or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- The caption: each row is one line in three columns (party, ")" marks, numbers), as in the typst grid.
-- A row is { left runs, right runs, left alignment }. Rules: Bankr. D.S.D. R. 9004-2(a) (full debtor name,
-- EIN, last four of SSN or TIN, names used); Rule 7010-2 and Form 416D for the adversary block.
local function caption_rows(meta)
  local rows = {}
  local function row(l, r, jc)
    rows[#rows + 1] = { l or "", r or "", jc }
  end
  row(run("In re:"), run("Bankr. No. " .. txt(meta.bankr_no)))
  row("", run("Chapter " .. txt(meta.chapter)))
  if CAPTION_JUDGE and meta.judge then row("", run("Hon. " .. txt(meta.judge))) end
  if CAPTION_JUDGE and meta.hearing then
    row("", "")
    for _, line in ipairs(meta.hearing) do row("", mruns(line)) end
  end
  row("", "")
  for _, d in ipairs(meta.debtors) do
    row(mruns(d.name), "")
    if d.ssn_last4 then row(run("SSN xxx-xx-" .. txt(d.ssn_last4)), "") end
    if d.ein then row(run("EIN " .. txt(d.ein)), "") end
    if d.tin_last4 then row(run("TIN xx-xxx" .. txt(d.tin_last4)), "") end
    for _, a in ipairs(d.aka or {}) do row(run("aka " .. txt(a)), "") end
    for _, a in ipairs(d.fka or {}) do row(run("fka " .. txt(a)), "") end
    row("", "")
  end
  row(run(#meta.debtors > 1 and "Debtors." or "Debtor."), "", "right")
  row("", "")
  if meta.adversary_no then
    local adv_done = false
    for _, pl in ipairs(meta.plaintiffs) do
      for _, n in ipairs(pl.names) do
        if not adv_done then
          row(mruns(n), run("Adv. No. " .. txt(meta.adversary_no)))
          adv_done = true
        else
          row(mruns(n), "")
        end
      end
      row(mruns(pl.designation), "", "right")
      row("", "")
    end
    row(run("v."), "")
    row("", "")
    for _, df in ipairs(meta.defendants) do
      for _, n in ipairs(df.names) do row(mruns(n), "") end
      row(mruns(df.designation), "", "right")
    end
  end
  return rows
end

local function caption(meta)
  local out = {}
  out[#out + 1] = p(run("UNITED STATES BANKRUPTCY COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(run("DISTRICT OF SOUTH DAKOTA", { b = true }), { jc = "center", after = SECTION_GAP })
  local grid = {}
  for _, r in ipairs(caption_rows(meta)) do
    local cells = {}
    local function cell(w, content, mar)
      local tcpr = string.format('<w:tcW w:w="%d" w:type="dxa"/>', w)
      if mar then tcpr = tcpr .. string.format('<w:tcMar><w:right w:w="%d" w:type="dxa"/></w:tcMar>', mar) end
      cells[#cells + 1] = "<w:tc><w:tcPr>" .. tcpr .. "</w:tcPr>" .. content .. "</w:tc>"
    end
    cell(CAPTION_COLS[1], p(r[1], { jc = r[3] }), 288)
    cell(CAPTION_COLS[2], p(run(")")))
    cell(CAPTION_COLS[3], p(r[2]))
    grid[#grid + 1] = "<w:tr>" .. table.concat(cells) .. "</w:tr>"
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders>'
    .. '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="4752"/><w:gridCol w:w="432"/><w:gridCol w:w="4176"/></w:tblGrid>'
    .. table.concat(grid) .. "</w:tbl>"
  return out
end

-- The signature block: "DATED <date>." at the left, the signer and firm lines at the middle of the page.
local function signature(sig)
  local out = {}
  out[#out + 1] = p(run("DATED ") .. mruns(sig.date) .. run("."), { before = SECTION_GAP, keep_next = true })
  local lines = { run("/s/ ") .. mruns(sig.signer) }
  lines[#lines + 1] = mruns(sig.signer)
  for _, l in ipairs(sig.firm or {}) do lines[#lines + 1] = mruns(l) end
  lines[#lines + 1] = mruns(sig.role)
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { left = SIG_INDENT, before = (i == 1) and SECTION_GAP or 0, keep_next = i < #lines })
  end
  return out
end

local function certificate(c)
  local out = {}
  out[#out + 1] = p(run("CERTIFICATE OF SERVICE", { b = true }), { jc = "center", before = 480 })
  out[#out + 1] = p(mruns(c.text), { before = 180, after = 0 })
  local lines = { run("/s/ ") .. mruns(c.signer) }
  lines[#lines + 1] = mruns(c.signer)
  for _, l in ipairs(c.firm or {}) do lines[#lines + 1] = mruns(l) end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { left = SIG_INDENT, before = (i == 1) and SECTION_GAP or 0, keep_next = i < #lines })
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  assert(meta.debtors and #meta.debtors > 0, "R. 9004-2(a): the caption needs at least one debtor")
  for _, d in ipairs(meta.debtors) do
    assert(d.ssn_last4 or d.ein or d.tin_last4,
      "R. 9004-2(a)(2)-(4): each debtor needs an EIN, the last four of an SSN, or the last four of a TIN: " .. txt(d.name))
  end
  if TYPE == "motion" then
    assert(meta.movant and meta.relief and meta.basis,
      "FRBP 9013(b): the motion must state the movant, the relief requested and the grounds (basis)")
  end

  local out = {}
  for _, b in ipairs(caption(meta)) do out[#out + 1] = raw(b) end
  out[#out + 1] = raw(p(mruns(meta.title, { b = true }), { jc = "center", before = SECTION_GAP, after = SECTION_GAP }))
  if OPENING then
    out[#out + 1] = raw(p(run("") .. mruns(meta.movant) .. run(" moves the Court for ") .. mruns(meta.relief)
      .. run(" under ") .. mruns(meta.basis) .. run("."), { first = 720, after = PARA_GAP }))
  end
  if meta.lead_in then
    out[#out + 1] = raw(p(mruns(meta.lead_in), { after = PARA_GAP }))
  end

  -- Numbering (complaint): every paragraph is numbered from 1, except after a PRAYER heading.
  local n = 0
  local numbered = NUMBERED
  local body = doc.blocks
  for i, b in ipairs(body) do
    if b.t == "Header" and b.level == 1 then
      if NUMBERED then numbered = not pandoc.utils.stringify(b.content):find("PRAYER", 1, true) end
    elseif b.t == "Para" and numbered then
      n = n + 1
      table.insert(b.content, 1, pandoc.Str(n .. ".\u{2002}"))
    end
    if KEEP_SIGNATURE and i == #body and b.t == "Para" then
      -- Convention (typst): a signature never stands alone; the last paragraph keeps with the block.
      b = pandoc.Div({ b }, { ["custom-style"] = "Body Text Keep Next" })
    end
    out[#out + 1] = b
  end

  for _, s in ipairs(signature(meta.signature)) do out[#out + 1] = raw(s) end
  if CERTIFICATE and meta.certificate then
    for _, s in ipairs(certificate(meta.certificate)) do out[#out + 1] = raw(s) end
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
