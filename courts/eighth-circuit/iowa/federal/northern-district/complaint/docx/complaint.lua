-- Complaint, DOCX engine (docs/DOCX.md). The markdown contract of ../typst/iand-complaint.typ, as a Word document on
-- reference.docx: the court title and the caption (a borderless table with a column of ")" marks) are WordprocessingML
-- paragraphs; the body keeps its markdown structure. Paragraphs are numbered here (LR 10(b)); an "UNNUMBERED:" paragraph
-- and the lead-in are not. The prayer's list is lettered. Page numbers come from the reference's footer.
-- Known limits: the caption's ")" column has one mark per line of the parties, as in the typst template; a party name that
-- wraps keeps one mark, so the marks fall short by a line there (typst does the same). Run formatting inside the caption
-- and the signature is plain text (the sample's names carry no markup).

-- twips: 24 pt (double spacing, LR 10(b)(1)); 13.8 pt (single); 8.1 pt and 16.2 pt (the typst half and full body-leading)
local PITCH, SINGLE, HALF, BODY_LEAD = 480, 276, 162, 324
local GAP = 120          -- 6 pt, the typst single-leading between caption groups
local TEXT_W = 9360      -- 6.5 in: letter, 1-inch margins
local CAP_L, CAP_M = 4464, 432  -- caption: 3.1 in parties, 0.3 in marks, the rest the case number and title
local CAP_R = TEXT_W - CAP_L - CAP_M
local SIG_IND = 4320     -- 3.0 in: the signature block
local NIL = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- one single- or double-spaced paragraph. o: bold, jc (center), before, line (exact twips), left (indent), keep
local function p(text, o)
  o = o or {}
  local ppr = (o.keep and "<w:keepNext/>" or "")
    .. '<w:spacing w:before="' .. (o.before or 0) .. '" w:after="0" w:line="' .. (o.line or SINGLE) .. '" w:lineRule="exact"/>'
    .. (o.left and ('<w:ind w:left="' .. o.left .. '" w:firstLine="0"/>') or "")
    .. (o.jc and ('<w:jc w:val="' .. o.jc .. '"/>') or "")
  local run = ""
  if text ~= "" then
    run = '<w:r>' .. (o.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or "") .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr>' .. run .. '</w:p>'
end

local function spacer(twips, keep)
  return p("", { line = twips, keep = keep })
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

-- the caption: the parties on the left, a ")" per party line in the middle, the case number and title on the right
local function caption(meta)
  local left = {}
  for k, party in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = "v." end
    for _, n in ipairs(party.names) do left[#left + 1] = plain(n) end
    left[#left + 1] = plain(party.designation)
  end
  local lp, mp, rp = {}, {}, {}
  for i, line in ipairs(left) do
    lp[i] = p(line)
    mp[i] = p(")")
  end
  rp[#rp + 1] = p("No. " .. plain(meta.case_number))
  if meta.judge then rp[#rp + 1] = p("Judge: " .. plain(meta.judge), { before = GAP }) end
  if meta.magistrate_judge then rp[#rp + 1] = p("Magistrate Judge: " .. plain(meta.magistrate_judge), { before = GAP }) end
  rp[#rp + 1] = p(plain(meta.brief_title), { bold = true, before = PITCH })
  if meta.jury_demand == true then rp[#rp + 1] = p("JURY DEMAND", { bold = true, before = GAP }) end

  local function cell(w, paras, mar)
    local tcpr = '<w:tcW w:w="' .. w .. '" w:type="dxa"/>'
    if mar then tcpr = tcpr .. '<w:tcMar><w:left w:w="' .. mar .. '" w:type="dxa"/></w:tcMar>' end
    return '<w:tc><w:tcPr>' .. tcpr .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
  end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/><w:tblBorders>' .. NIL
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_L .. '"/><w:gridCol w:w="' .. CAP_M .. '"/><w:gridCol w:w="' .. CAP_R .. '"/></w:tblGrid>'
    .. '<w:tr>' .. cell(CAP_L, lp) .. cell(CAP_M, mp) .. cell(CAP_R, rp, 216) .. '</w:tr></w:tbl>')
end

-- the signature block (typst: pad 3 in; "Respectfully submitted," then the firm, "By: /s/" and the signer, its lines)
local function signature(meta, date)
  local s = { spacer(BODY_LEAD, true) }
  if date then
    s[#s + 1] = p("Dated: " .. plain(date), { keep = true })
    s[#s + 1] = spacer(BODY_LEAD, true)
  end
  local sig = meta.signature
  s[#s + 1] = p("Respectfully submitted,", { left = SIG_IND, keep = true })
  s[#s + 1] = spacer(HALF, true)
  for _, l in ipairs(sig.firm) do s[#s + 1] = p(plain(l), { left = SIG_IND, keep = true }) end
  s[#s + 1] = spacer(HALF, true)
  s[#s + 1] = p("By: /s/ " .. plain(sig.signer), { left = SIG_IND, keep = true })
  s[#s + 1] = p(plain(sig.signer), { left = SIG_IND, keep = true })
  for _, l in ipairs(sig.lines or {}) do s[#s + 1] = p(plain(l), { left = SIG_IND, keep = true }) end
  s[#s + 1] = spacer(BODY_LEAD)
  return raw(table.concat(s, ""))
end

-- strip a leading "WORD:" (and the space after it) from a paragraph; true if it was there
local function take_prefix(c, word)
  local first = c[1]
  if first and first.t == "Str" and first.text == word then
    c:remove(1)
    if c[1] and c[1].t == "Space" then c:remove(1) end
    return true
  end
  return false
end

local function upper_inlines(inl)
  return inl:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc would print the date as a title block; the date belongs to the signature block only
  local date = meta.date
  meta.date = nil
  local out = {}
  local function add(x) out[#out + 1] = x end

  -- the court title (LR 10(d)): district, division
  add(raw(p("IN THE UNITED STATES DISTRICT COURT", { bold = true, jc = "center" })
    .. p("FOR THE NORTHERN DISTRICT OF IOWA", { bold = true, jc = "center" })
    .. (meta.division and p(plain(meta.division):upper(), { bold = true, jc = "center" }) or "")))
  add(raw(spacer(PITCH)))
  add(caption(meta))
  add(raw(spacer(PITCH)))

  if meta.lead_in then add(pandoc.Para(meta.lead_in)) end

  local numbered = meta.numbered == true
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then b = pandoc.Header(1, upper_inlines(b.content), b.attr) end
      add(b)
    elseif b.t == "Para" then
      if plain(b) == "SIGNATURE" then
        add(signature(meta, date))
      else
        local c = pandoc.List(b.content)
        local unnumbered = take_prefix(c, "UNNUMBERED:")
        if numbered and not unnumbered then
          n = n + 1
          c:insert(1, pandoc.RawInline("openxml", '<w:r><w:t>' .. n .. '.</w:t></w:r><w:r><w:tab/></w:r>'))
        end
        add(pandoc.Para(c))
      end
    elseif b.t == "OrderedList" then
      -- the prayer's items are lettered (typst: enum numbering "A."): the letter at 0.5 in, the text hangs at 0.9 in,
      -- half a body-leading of space before and after the list. Written as paragraphs, not a Word list, for those indents.
      add(raw(spacer(HALF)))
      for i, item in ipairs(b.content) do
        local c = pandoc.List({ pandoc.RawInline("openxml", '<w:r><w:t>' .. string.char(64 + i) .. '.</w:t></w:r><w:r><w:tab/></w:r>') })
        c:extend(item[1].content)
        add(pandoc.Div({ pandoc.Para(c) }, pandoc.Attr("", {}, { ["custom-style"] = "List Item" })))
        for k = 2, #item do add(item[k]) end
      end
      add(raw(spacer(HALF)))
    else
      add(b)
    end
  end

  doc.blocks = out
  return doc
end
