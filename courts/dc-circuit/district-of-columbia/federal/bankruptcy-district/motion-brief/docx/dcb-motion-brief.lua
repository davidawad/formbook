-- Motion with memorandum for the Bankruptcy Court for the District of Columbia (dcb), docx engine.
-- The same contract as typst/dcb-motion-brief.typ: the cover (counsel block, court title, caption, title, notice of
-- motion), the signature block and the certificate of service are WordprocessingML written from the sample's
-- frontmatter. The body is pandoc's (headings, paragraphs, block quotations). Styles (EB Garamond 12 pt, double
-- spacing, 1-inch margins, page number) come from reference.docx (make-reference.sh).
-- Content-agnostic: every case-specific word comes from the frontmatter, never from this file.

local SINGLE = "SingleSpaced"
local CAPTION_W = { 4752, 504, 4104 } -- 3.3 in party column, 0.35 in ")" column, the rest (twips; 6.5 in in all)

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
  assert(str(c.email):find("@"), "dcb-motion-brief: counsel.email is required (LBR 5005-1(c))")
  local items = { str(c.name), str(c.firm) }
  for _, t in ipairs(strs(c.address)) do items[#items + 1] = t end
  items[#items + 1] = str(c.phone)
  items[#items + 1] = str(c.email)
  for _, t in ipairs(strs(c.represents)) do items[#items + 1] = t end
  return lines(items)
end

-- The caption: parties on the left, a column of ")" marks, the case numbers on the right (FRBP 9004(b)).
local function caption(meta)
  local c = meta.caption
  local left = {}
  for _, t in ipairs(strs(c.debtor.names)) do left[#left + 1] = t end
  left[#left + 1] = str(c.debtor.designation)
  left[#left + 1] = ""
  for _, t in ipairs(strs(c.plaintiff.names)) do left[#left + 1] = t end
  left[#left + 1] = str(c.plaintiff.designation)
  left[#left + 1] = "vs."
  left[#left + 1] = "Adversary No. " .. str(c.adversary_number)
  left[#left + 1] = ""
  for _, t in ipairs(strs(c.defendant.names)) do left[#left + 1] = t end
  left[#left + 1] = str(c.defendant.designation)

  local right = { "In re:", "Case No. " .. str(c.case_number), "(Chapter " .. str(c.chapter) .. ")" }
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

-- Notice of motion, objection deadline and hearing (LBR 9013-1(c), (d)). A blank field prints a fill-in line.
local function notice(n)
  local function fill(s)
    if s == "" then return "________________" end
    return s
  end
  return P(R("NOTICE OF MOTION, OBJECTION DEADLINE, AND HEARING", { b = true }), {
      style = SINGLE, keep = true, jc = "center", box = true, left = 200, right = 200, before = 0, after = 120,
    })
    .. P(
      R("Any response to this motion must be filed with the Court and served on the movant’s counsel no later than ")
        .. R(fill(str(n.response_deadline)), { i = true })
        .. R(". If no response is timely filed, the Court may grant the relief requested without a hearing. A hearing on this motion is set for ")
        .. R(fill(str(n.hearing)), { i = true })
        .. R("."),
      { style = SINGLE, box = true, left = 200, right = 200 }
    )
end

-- The cover. The gaps are the typst template's (v(pitch), v(pitch * 0.5)) as they measure on the typst render; a
-- double-spaced line in Word and LibreOffice sits lower in its line than Typst's does (twips; 20 = 1 pt).
local function cover(meta)
  local title = P(R(str(meta.title), { b = true }), { jc = "center", before = 316, after = 0 })
  return counsel(meta.counsel)
    .. lines(strs(meta.court), { b = true, jc = "center", before = 836 })
    .. gap(556)
    .. caption(meta)
    .. title
    .. gap(476)
    .. notice(meta.notice)
    .. gap(316)
end

local function signature(s)
  local right = lines({ "Respectfully submitted,", str(s.firm) }) .. gap(276)
  local items = { "/s/ " .. str(s.signer), str(s.signer) }
  for _, t in ipairs(strs(s.address)) do items[#items + 1] = t end
  items[#items + 1] = "Phone: " .. str(s.phone)
  items[#items + 1] = "Email: " .. str(s.email)
  for _, t in ipairs(strs(s.role)) do items[#items + 1] = t end
  right = right .. lines(items)
  return gap(552) .. TBL({ 4032, 288, 5040 }, { { P(R("Date: " .. str(s.date)), { style = SINGLE }), P(""), right } })
end

-- Certificate of service (LBR 9013-1(f)): date, manner, and the recipients who are not served through CM/ECF.
-- It is one unbreakable row, as the typst block is (breakable: false), so the recipients stay with the signature.
local function certificate(s, sig)
  local body = P(R("CERTIFICATE OF SERVICE", { b = true }), { style = SINGLE, jc = "center" })
    .. gap(276)
    .. P(
      R("I HEREBY CERTIFY that on " .. str(s.date) .. ", a copy of the foregoing was served through " .. str(s.method) .. ", on the following:"),
      { style = "BodyText" }
    )
    .. gap(276)
  for _, r in ipairs(s.recipients) do
    local items = { str(r.name) }
    for _, t in ipairs(strs(r.lines)) do items[#items + 1] = t end
    body = body .. lines(items) .. gap(276)
  end
  local items = { "/s/ " .. str(sig.signer), str(sig.signer) }
  for _, t in ipairs(strs(sig.address)) do items[#items + 1] = t end
  items[#items + 1] = "Phone: " .. str(sig.phone)
  items[#items + 1] = "Email: " .. str(sig.email)
  body = body .. gap(276) .. TBL({ 5328, 4032 }, { { P(""), lines(items) } })
  return gap(552) .. TBL({ 9360 }, { { body } })
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

function Pandoc(doc)
  local m = doc.meta
  local out = pandoc.List({ raw(cover(m)) })
  for _, b in ipairs(doc.blocks) do
    out:insert(b)
  end
  out:insert(raw(signature(m.signature)))
  out:insert(raw(certificate(m.service, m.signature)))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
