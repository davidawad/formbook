-- Innb adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/innb-adversary-complaint.typ: the court title, debtor block, parties block (closed by a rule),
-- title, lead-in, numbered paragraphs (the template numbers them, not the sample), lettered sub-items and the
-- WHEREFORE paragraph (unnumbered), headings, and the signature block (kept on one page).
-- Every case-specific word comes from the YAML frontmatter; nothing here is measured off the exemplar.
-- The cover and caption are built as OpenXML tables and paragraphs in the "Centered", "Single", "Spacer"
-- and "HalfSpacer" styles of reference.docx. Page numbers come from the reference's footer.
-- Known limits (see ../README.md, "Engines"): the table borders are not checked against the typst layout;
-- the docx.pdf and the page review are BLOCKED on a machine without LibreOffice.

local function need(meta, k)
  if meta[k] == nil then error("innb-adversary-complaint: missing required metadata field `" .. k .. "`", 0) end
  return meta[k]
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- ---- OpenXML helpers (text from the frontmatter is escaped; no markup is interpreted) ----
local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, o)
  o = o or {}
  local rpr = ""
  if o.b then rpr = rpr .. "<w:b/>" end
  if o.i then rpr = rpr .. "<w:i/>" end
  if o.u then rpr = rpr .. '<w:u w:val="single"/>' end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- a paragraph: style, runs (XML), optional left indent in twips, optional keep-with-next
local function para(style, runs, o)
  o = o or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if o.keep then ppr = ppr .. "<w:keepNext/>" end
  if o.left then ppr = ppr .. '<w:ind w:left="' .. o.left .. '" w:firstLine="0"/>' end
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

-- a table cell; `rule` draws the right and bottom rules of the caption's left cell (as typst's stroke)
local function cell(width, paras, o)
  o = o or {}
  local borders = ""
  if o.rule then
    borders = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
      .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  end
  local mar = '<w:tcMar><w:top w:w="' .. (o.top or 0) .. '" w:type="dxa"/>'
    .. '<w:left w:w="' .. (o.left or 0) .. '" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. (o.bottom or 0) .. '" w:type="dxa"/>'
    .. '<w:right w:w="' .. (o.right or 0) .. '" w:type="dxa"/></w:tcMar>'
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. borders .. mar .. '</w:tcPr>'
    .. table.concat(paras) .. '</w:tc>'
end

-- a one-row borderless table of fixed column widths (twips); `cells` is a list of cell() strings
local function row_table(widths, cells, cant_split)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local trpr = cant_split and '<w:trPr><w:cantSplit/></w:trPr>' or ''
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
    .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/></w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr>' .. trpr .. table.concat(cells) .. '</w:tr></w:tbl>'
end

local HALF_INDENT = 2304  -- 1.6 in: the designation line under a name (typst pad(left: 1.6in))
local NAME_INDENT = 720   -- 0.5 in: a debtor's name (typst pad(left: 0.5in))
local TEXT_W = 9360       -- 6.5 in: the text block between 1 in margins
local CAP_LEFT = 4680     -- caption columns (1fr, 1fr)
local SIG_LEFT = 4752     -- signature block: (1fr, 3.2in)
local SIG_RIGHT = 4608
local PAD_1_2EM = 312     -- 1.2 em at 13 pt, in twips (typst pad(... 1.2em))

-- ---- the cover ----
local function court_title(meta, out)
  for _, l in ipairs(need(meta, "court")) do
    out[#out + 1] = pandoc.RawBlock("openxml", para("Centered", run(plain(l), { b = true })))
  end
end

local function debtor_table(meta, out)
  local left = { para("Single", run("In re:")), para("Single", "") }
  for _, d in ipairs(need(meta, "debtors")) do
    left[#left + 1] = para("Single", run(plain(d.names)), { left = NAME_INDENT })
    left[#left + 1] = para("Single", run(plain(d.designation)), { left = HALF_INDENT })
    left[#left + 1] = para("Single", "")
  end
  local right = {
    para("Single", ""),
    para("Single", run("Case No. " .. plain(need(meta, "case_number")))),
    para("Single", run("Chapter " .. plain(need(meta, "chapter")))),
  }
  out[#out + 1] = pandoc.RawBlock("openxml", row_table({ CAP_LEFT, CAP_LEFT }, {
    cell(CAP_LEFT, left, { rule = true, right = PAD_1_2EM }),
    cell(CAP_LEFT, right, { left = PAD_1_2EM }),
  }))
end

local function parties_table(meta, out)
  local sides = need(meta, "caption")
  local left = {}
  for i, side in ipairs(sides) do
    left[#left + 1] = para("Single", run(plain(side.names)))
    left[#left + 1] = para("Single", run(plain(side.designation)), { left = HALF_INDENT })
    if i < #sides then
      left[#left + 1] = para("HalfSpacer", "")
      left[#left + 1] = para("Single", run("v."))
      left[#left + 1] = para("HalfSpacer", "")
    end
  end
  local right = {
    para("HalfSpacer", ""),
    para("Single", run("Adv. Proc. No. " .. plain(need(meta, "adv_number")))),
  }
  out[#out + 1] = pandoc.RawBlock("openxml", row_table({ CAP_LEFT, CAP_LEFT }, {
    cell(CAP_LEFT, left, { rule = true, right = PAD_1_2EM, bottom = 260 }),
    cell(CAP_LEFT, right, { left = PAD_1_2EM, top = 78 }),
  }))
end

local function title_block(meta, out)
  for _, l in ipairs(need(meta, "title")) do
    out[#out + 1] = pandoc.RawBlock("openxml", para("Centered", run(plain(l):upper(), { b = true })))
  end
end

-- the signature block: a borderless two-column table; the row is kept on one page (typst breakable: false)
local function signature_block(meta, out)
  local sig = need(meta, "signature")
  local left = { para("Single", meta.date and run("Dated: " .. plain(meta.date)) or "") }
  local right = {}
  for _, l in ipairs(sig.preamble or {}) do right[#right + 1] = para("Single", run(plain(l))) end
  right[#right + 1] = para("Spacer", "")
  right[#right + 1] = para("Single", run(plain(sig.firm)))
  right[#right + 1] = para("Single", run(plain(sig.role), { i = true }))
  right[#right + 1] = para("Spacer", "")
  right[#right + 1] = para("Single", run("By: ") .. run(string.rep(" ", 40), { u = true }))
  right[#right + 1] = para("Single", run(plain(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = para("Single", run(plain(l))) end
  out[#out + 1] = pandoc.RawBlock("openxml", para("Spacer", ""))
  out[#out + 1] = pandoc.RawBlock("openxml", row_table({ SIG_LEFT, SIG_RIGHT }, {
    cell(SIG_LEFT, left),
    cell(SIG_RIGHT, right),
  }, true))
end

-- ---- the body ----
local function is_wherefore(b)
  return plain(b):sub(1, 9) == "WHEREFORE"
end

-- a lettered sub-item ("A. ...", typst regex ^[A-Z]\.\s): unnumbered
local function is_subitem(b)
  return plain(b):match("^%u%.%s") ~= nil
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "court", "debtors", "case_number", "chapter", "caption", "adv_number", "title", "signature" }) do
    need(meta, k)
  end

  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover and caption (FRBP 9004(b); FRBP 7010 with Form 416D; see ../README.md)
  court_title(meta, out)
  add(pandoc.RawBlock("openxml", para("Spacer", "")))
  debtor_table(meta, out)
  add(pandoc.RawBlock("openxml", para("HalfSpacer", "")))
  parties_table(meta, out)
  add(pandoc.RawBlock("openxml", para("HalfSpacer", "")))
  title_block(meta, out)
  add(pandoc.RawBlock("openxml", para("HalfSpacer", "")))
  if meta.lead_in then add(pandoc.Para(meta.lead_in)) end

  -- body: headings as written; numbered paragraphs (INNB-CMP-001); lettered sub-items and WHEREFORE unnumbered
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      if is_wherefore(b) or is_subitem(b) then
        add(b)
      else
        n = n + 1
        table.insert(b.content, 1, pandoc.Space())
        table.insert(b.content, 1, pandoc.Str(n .. "."))
        add(b)
      end
    elseif b.t == "OrderedList" then
      -- "A. ..." sub-items come through pandoc as an upper-alpha list; write them back as lettered paragraphs
      if b.listAttributes.style ~= "UpperAlpha" then
        error("innb-adversary-complaint: the body has a list that is not a lettered sub-item list", 0)
      end
      for i, item in ipairs(b.content) do
        local first = item[1]
        if not first or first.t ~= "Para" then
          error("innb-adversary-complaint: a lettered sub-item must start with a paragraph", 0)
        end
        local letter = string.char(64 + b.listAttributes.start + i - 1)
        local content = pandoc.List({ pandoc.Str(letter .. "."), pandoc.Space() })
        content:extend(first.content)
        add(pandoc.Para(content))
        for j = 2, #item do add(item[j]) end
      end
    elseif b.t == "BulletList" then
      error("innb-adversary-complaint: bullet lists are not part of the form", 0)
    else
      add(b)
    end
  end

  signature_block(meta, out)

  -- the frontmatter is consumed here; drop it so pandoc does not write its own title block
  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
