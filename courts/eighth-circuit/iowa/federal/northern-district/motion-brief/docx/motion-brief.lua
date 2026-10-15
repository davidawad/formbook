-- Memorandum in support of a motion, DOCX engine (docs/DOCX.md). The markdown contract of ../typst/iand-motion-brief.typ,
-- as a Word document on reference.docx: the court title, the caption (a borderless table with a column of ")" marks), and
-- the table of contents (a TOC field with its entries and page numbers written in, see render.sh) are WordprocessingML;
-- the body keeps its markdown structure. "NUMBERED:" paragraphs are numbered here (LR 10(b)); other paragraphs are not.
-- "SINGLE:" chunks are single-spaced lines (a service list). Page numbers come from the reference's footer.
-- Known limits: the caption's ")" column has one mark per line of the parties, as in the typst template; a party name that
-- wraps keeps one mark. The table of contents page numbers come from a first LibreOffice pass (render.sh); Word shows
-- them until fields are updated, and its pagination may differ by a line or a page (docs/DOCX.md).

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

-- one single- or double-spaced paragraph. o: bold, italic, jc (center), before, line (exact twips), left (indent), keep
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

-- the caption: the parties on the left, a ")" per party line in the middle, the case number, judges and title on the right
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
  local label = meta.case_label and plain(meta.case_label) or "No."
  rp[#rp + 1] = p(label .. " " .. plain(meta.case_number))
  if meta.judge then rp[#rp + 1] = p("Judge: " .. plain(meta.judge), { before = GAP }) end
  if meta.magistrate_judge then rp[#rp + 1] = p("Magistrate Judge: " .. plain(meta.magistrate_judge), { before = GAP }) end
  rp[#rp + 1] = p(plain(meta.brief_title), { bold = true, before = PITCH })

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

-- the signature block (typst: pad 3 in; the party, the firm, "/s/" and the signer, its lines)
local function signature(meta, date)
  local s = { spacer(BODY_LEAD, true) }
  if date then
    s[#s + 1] = p("Dated: " .. plain(date), { keep = true })
    s[#s + 1] = spacer(BODY_LEAD, true)
  end
  local sig = meta.signature
  if sig.party then
    for _, l in ipairs(sig.party) do s[#s + 1] = p(plain(l), { left = SIG_IND, keep = true }) end
    s[#s + 1] = spacer(HALF, true)
  end
  for _, l in ipairs(sig.firm) do s[#s + 1] = p(plain(l), { left = SIG_IND, keep = true }) end
  s[#s + 1] = spacer(HALF, true)
  s[#s + 1] = p("/s/ " .. plain(sig.signer), { left = SIG_IND, keep = true })
  for _, l in ipairs(sig.lines or {}) do s[#s + 1] = p(plain(l), { left = SIG_IND, keep = true }) end
  s[#s + 1] = spacer(BODY_LEAD)
  return raw(table.concat(s, ""))
end

-- the table of contents (typst: "TABLE OF CONTENTS", then the headings of levels 1 and 2 with their pages). A TOC field
-- whose cached result is these entries, so every viewer shows them; Word can update it (\o "1-2").
local function toc(entries, pages)
  local rows = {}
  for i, e in ipairs(entries) do
    local begin = i == 1 and '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r>' or ""
    local stop = i == #entries and '<w:r><w:fldChar w:fldCharType="end"/></w:r>' or ""
    rows[#rows + 1] = '<w:p><w:pPr><w:pStyle w:val="' .. (e.level == 1 and "TOC1" or "TOC2") .. '"/></w:pPr>' .. begin
      .. '<w:r><w:t xml:space="preserve">' .. esc(e.text) .. '</w:t></w:r><w:r><w:tab/></w:r>'
      .. '<w:r><w:t>' .. esc(pages[i] or "") .. '</w:t></w:r>' .. stop .. '</w:p>'
  end
  return table.concat(rows, "")
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

-- the page of each table-of-contents entry, one per line, from render.sh's first pass (empty on that pass)
local function read_pages()
  local pages = {}
  local path = os.getenv("DOCX_PAGES")
  if path and path ~= "" then
    local f = assert(io.open(path, "r"), "motion-brief.lua: cannot read " .. path)
    for line in f:lines() do pages[#pages + 1] = line end
    f:close()
  end
  return pages
end

-- render.sh's first pass writes the entries it needs: a line "0<TAB>first body paragraph" to find the body's first page,
-- then "level<TAB>heading" for each heading of levels 1 and 2
local function write_toc_list(path, body_start, entries)
  local f = assert(io.open(path, "w"), "motion-brief.lua: cannot write " .. path)
  f:write("0\t", body_start, "\n")
  for _, e in ipairs(entries) do f:write(e.level, "\t", e.text, "\n") end
  f:close()
end

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc would print the date as a title block; the date belongs to the signature block only
  local date = meta.date
  meta.date = nil
  -- pandoc would also insert its own table of contents for toc: true; this filter writes the court's (below)
  local court_toc = meta.toc == true
  meta.toc = nil
  local out = {}
  local function add(x) out[#out + 1] = x end

  -- the entries of the table of contents, and the first body paragraph (for render.sh to find the body's first page)
  local entries, body_start = {}, nil
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 2 then entries[#entries + 1] = { level = b.level, text = plain(b.content) } end
    if b.t == "Para" and body_start == nil and plain(b) ~= "SIGNATURE" then body_start = plain(b) end
  end
  local toc_path = os.getenv("DOCX_TOC_LIST")
  if toc_path and toc_path ~= "" and body_start then write_toc_list(toc_path, body_start, entries) end

  -- the court title (LR 10(d)): district, division
  add(raw(p("IN THE UNITED STATES DISTRICT COURT", { bold = true, jc = "center" })
    .. p("FOR THE NORTHERN DISTRICT OF IOWA", { bold = true, jc = "center" })
    .. (meta.division and p(plain(meta.division):upper(), { bold = true, jc = "center" }) or "")))
  add(raw(spacer(PITCH)))
  add(caption(meta))
  add(raw(spacer(PITCH)))

  if court_toc then
    local pages = read_pages()
    add(raw(p("TABLE OF CONTENTS", { bold = true, jc = "center" }) .. spacer(PITCH) .. toc(entries, pages)))
    -- a page break in a 1-point paragraph, so no blank line opens the body's page
    add(raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>'))
  end

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      if b.level == 1 then b = pandoc.Header(1, upper_inlines(b.content), b.attr) end
      add(b)
    elseif b.t == "Para" then
      local c = pandoc.List(b.content)
      if plain(b) == "SIGNATURE" then
        add(signature(meta, date))
      elseif take_prefix(c, "SINGLE:") then
        -- single-spaced lines, one per source line, then half a body-leading of space as in typst
        local lines = pandoc.Para(c):walk({ SoftBreak = function() return pandoc.LineBreak() end })
        add(pandoc.Div({ lines }, pandoc.Attr("", {}, { ["custom-style"] = "Single" })))
        add(raw(spacer(BODY_LEAD)))
      else
        if take_prefix(c, "NUMBERED:") then
          n = n + 1
          c:insert(1, pandoc.RawInline("openxml", '<w:r><w:t>' .. n .. '.</w:t></w:r><w:r><w:tab/></w:r>'))
          add(pandoc.Para(c))
        else
          add(pandoc.Para(c))
        end
      end
    elseif b.t == "OrderedList" then
      -- the memorandum's list is numbered 1., 2., ... with the text hanging at 0.9 in, half a body-leading before and
      -- after (typst). Written as paragraphs for those indents, as in the complaint.
      add(raw(spacer(HALF)))
      for i, item in ipairs(b.content) do
        local c = pandoc.List({ pandoc.RawInline("openxml", '<w:r><w:t>' .. i .. '.</w:t></w:r><w:r><w:tab/></w:r>') })
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
