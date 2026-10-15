-- Adversary complaint for the Bankruptcy Court for the District of Columbia (dcb), docx engine.
-- The same contract as typst/dcb-adversary-complaint.typ: the cover (counsel block, court title, caption, title),
-- the statement on final orders and the signature block are WordprocessingML written from the sample's frontmatter.
-- The body is pandoc's; paragraphs after the first heading are numbered (Fed. R. Civ. P. 10(b)), except WHEREFORE.
-- Styles (EB Garamond 12 pt, double spacing, 1-inch margins, page number) come from reference.docx (make-reference.sh).
-- Content-agnostic: every case-specific word comes from the frontmatter, never from this file.

local SINGLE = "SingleSpaced"
local CAPTION_W = { 4752, 504, 4104 } -- 3.3 in party column, 0.35 in ")" column, the rest (twips; 6.5 in in all)
local SIG_W = { 4032, 288, 5040 } -- 2.8 in, 0.2 in gutter, the rest

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function str(m)
  if m == nil then return "" end
  return pandoc.utils.stringify(m)
end

-- A metadata list (or a single value) as a Lua array of plain strings.
local function strs(m)
  local out = {}
  if m == nil then return out end
  if pandoc.utils.type(m) == "List" then
    for _, v in ipairs(m) do out[#out + 1] = str(v) end
  else
    out[1] = str(m)
  end
  return out
end

local function R(t, o)
  o = o or {}
  local rpr = (o.b and "<w:b/>" or "") .. (o.i and "<w:i/>" or "")
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(t) .. "</w:t></w:r>"
end

local BOX = '<w:pBdr><w:top w:val="single" w:sz="6" w:space="10" w:color="000000"/>'
  .. '<w:left w:val="single" w:sz="6" w:space="10" w:color="000000"/>'
  .. '<w:bottom w:val="single" w:sz="6" w:space="10" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="6" w:space="10" w:color="000000"/></w:pBdr>'

-- One paragraph. o: style, keep (keep with next), box (bordered), before/after (twips), left/right (twips), jc.
local function P(runs, o)
  o = o or {}
  local ppr = ""
  if o.style then ppr = ppr .. '<w:pStyle w:val="' .. o.style .. '"/>' end
  if o.keep then ppr = ppr .. "<w:keepNext/>" end
  if o.box then ppr = ppr .. BOX end
  if o.before or o.after then
    ppr = ppr .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="' .. (o.after or 0) .. '"/>'
  end
  if o.left or o.right then
    ppr = ppr .. '<w:ind w:left="' .. (o.left or 0) .. '" w:right="' .. (o.right or 0) .. '"/>'
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. runs .. "</w:p>"
end

-- Vertical space of exactly `twips` (552 = one double-spaced line, 276 = half of one), as an empty paragraph.
local function gap(twips)
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

-- Lines that are each single-spaced (one paragraph per item); o.before is the space above the first line.
local function lines(items, o)
  o = o or {}
  local out = {}
  for i, t in ipairs(items) do
    out[#out + 1] = P(R(t, { b = o.b }), { style = SINGLE, jc = o.jc, before = (i == 1) and o.before or nil })
  end
  return table.concat(out)
end

-- A borderless table; every cell is a string of paragraphs. A table is always followed by a paragraph (gap(20)).
local function TBL(widths, rows)
  local total = 0
  local grid = ""
  for _, w in ipairs(widths) do
    total = total + w
    grid = grid .. '<w:gridCol w:w="' .. w .. '"/>'
  end
  local nil_borders = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  local out = '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders>' .. nil_borders .. '</w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. grid .. "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out = out .. "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for i, cell in ipairs(row) do
      out = out .. '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. cell .. "</w:tc>"
    end
    out = out .. "</w:tr>"
  end
  return out .. "</w:tbl>" .. gap(20)
end

local function counsel(c)
  assert(str(c.email):find("@"), "dcb-adversary-complaint: counsel.email is required (LBR 5005-1(c))")
  local items = { str(c.name) }
  if c.bar then items[#items + 1] = str(c.bar) end
  items[#items + 1] = str(c.firm)
  for _, t in ipairs(strs(c.address)) do items[#items + 1] = t end
  items[#items + 1] = str(c.phone)
  items[#items + 1] = str(c.email)
  for _, t in ipairs(strs(c.represents)) do items[#items + 1] = t end
  return lines(items)
end

-- The caption: parties on the left, a column of ")" marks, the case numbers on the right (FRBP 9004(b)).
-- The adversary number sits at the plaintiff's first line; the case number at the debtor's lines.
local function caption(meta)
  local c = meta.caption
  local debtor = strs(c.debtor.names)
  local plaintiff = strs(c.plaintiff.names)
  local defendant = strs(c.defendant.names)
  local left = {}
  for _, t in ipairs(debtor) do left[#left + 1] = t end
  left[#left + 1] = str(c.debtor.designation)
  left[#left + 1] = ""
  for _, t in ipairs(plaintiff) do left[#left + 1] = t end
  left[#left + 1] = str(c.plaintiff.designation)
  left[#left + 1] = "v."
  left[#left + 1] = ""
  for _, t in ipairs(defendant) do left[#left + 1] = t end
  left[#left + 1] = str(c.defendant.designation)

  local adv = str(c.adversary_number)
  if adv == "" then adv = "____________" end
  local right = { "In re:", "Case No. " .. str(c.case_number), "(Chapter " .. str(c.chapter) .. ")" }
  right[#debtor + 3] = "Adv. Case No. " .. adv -- the plaintiff's first line (1-based)

  local rows = {}
  for i, t in ipairs(left) do
    rows[#rows + 1] = {
      P(R(t), { style = SINGLE }),
      P(R(")"), { style = SINGLE, jc = "center" }),
      P(R(right[i] or ""), { style = SINGLE }),
    }
  end
  return TBL(CAPTION_W, rows)
end

-- The vertical gaps are the typst template's (v(pitch), v(pitch * 0.5)) as they measure on the typst render. A
-- double-spaced line in Word and LibreOffice puts its baseline lower than Typst does, so the gaps that follow a
-- single line or a double line are set from the baselines, not from the pitch (twips; 20 twips = 1 pt).
local function cover(meta)
  return counsel(meta.counsel)
    .. lines(strs(meta.court), { b = true, jc = "center", before = 436 })
    .. gap(176)
    .. caption(meta)
    .. P(R(str(meta.title), { b = true }), { jc = "center", before = 176, after = 148 })
end

-- Statement on final orders and judgments (FRBP 7008(a); LBR 7012-1), after the allegations.
local function final_orders(meta)
  local consent = str(meta.final_orders.consent)
  local stmt
  if consent == "consents" then
    stmt = "Plaintiff consents to the entry of final orders and judgments by the bankruptcy judge."
  elseif consent == "does-not-consent" then
    stmt = "Plaintiff does not consent to the entry of final orders and judgments by the bankruptcy judge."
  else
    error('dcb-adversary-complaint: final_orders.consent must be "consents" or "does-not-consent"')
  end
  local debtor = table.concat(strs(meta.caption.debtor.names), " ")
  return gap(552)
    .. P(R("Statement on Final Orders and Judgments"), { style = "Heading1", keep = true })
    .. P(
      R("This adversary proceeding arises in the chapter " .. str(meta.caption.chapter) .. " case of ")
        .. R("In re " .. debtor, { i = true })
        .. R(", Case No. " .. str(meta.caption.case_number) .. ". " .. stmt),
      { style = "BodyText" }
    )
end

local function signature(s)
  local right = lines({ "Respectfully submitted," }) .. gap(276)
  local items = { "By: /s/ " .. str(s.signer), str(s.signer) }
  if s.bar then items[#items + 1] = str(s.bar) end
  for _, t in ipairs(strs(s.address)) do items[#items + 1] = t end
  items[#items + 1] = "Phone: " .. str(s.phone)
  if s.fax then items[#items + 1] = "Facsimile: " .. str(s.fax) end
  items[#items + 1] = "Email: " .. str(s.email)
  for _, t in ipairs(strs(s.role)) do items[#items + 1] = t end
  right = right .. lines(items)
  return gap(552) .. TBL(SIG_W, { { P(R("Dated: " .. str(s.date)), { style = SINGLE }), P(""), right } })
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

function Pandoc(doc)
  local m = doc.meta
  local out = pandoc.List({ raw(cover(m)) })

  -- Allegations: numbered from the first heading on, except WHEREFORE paragraphs (the typst template's rule).
  local has_heading = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then has_heading = true end
  end
  local seen = not has_heading
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      seen = true
      out:insert(b)
    elseif b.t == "Para" and seen and not pandoc.utils.stringify(b):match("^WHEREFORE") then
      n = n + 1
      table.insert(b.content, 1, pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. n .. '.</w:t></w:r><w:r><w:tab/></w:r>'))
      out:insert(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Paragraph" })))
    else
      out:insert(b)
    end
  end

  out:insert(raw(final_orders(m)))
  out:insert(raw(signature(m.signature)))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
