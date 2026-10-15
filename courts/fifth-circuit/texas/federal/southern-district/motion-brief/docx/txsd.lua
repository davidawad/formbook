-- txsd.lua: pandoc Lua filter for the docx engine (docx/reference.docx, docx/build-reference.sh).
-- Rebuilds the form of typst/txsd-*.typ from the sample: the court title, the caption (box or section), the title,
-- numbered and lettered paragraphs, the signature block, the certificates and, when the sample sets `toc: true`, a
-- table of contents field. Every case-specific word comes from the sample; the court's fixed text (the court name,
-- the certificate titles, "TABLE OF CONTENTS") is in this file, as it is in the typst template.

-- complaint: body paragraphs are numbered 1, 2, ... (Fed. R. Civ. P. 10(b)); motion-brief: they are not.
local NUMBERED = false
local LETTERS = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t"}
local ROMAN = {"i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x", "xi", "xii", "xiii", "xiv", "xv", "xvi", "xvii", "xviii", "xix", "xx"}
local UNNUMBERED = {["PRAYER FOR RELIEF"] = true, ["JURY TRIAL DEMAND"] = true}
local CERTIFICATES = {
  {key = "word_count_certificate", title = "CERTIFICATE OF WORD COUNT"},
  {key = "certificate_of_conference", title = "CERTIFICATE OF CONFERENCE"},
  {key = "certificate_of_service", title = "CERTIFICATE OF SERVICE"},
}
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function plain(v)
  if v == nil or type(v) == "boolean" then return "" end
  local s = pandoc.utils.stringify(v)
  if s == "null" then return "" end
  return s
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(s)
  return '<w:r><w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

local function rawp(style, inner)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. (inner or "") .. "</w:p>")
end

local function custom(style, content)
  return pandoc.Div({pandoc.Para(content)}, pandoc.Attr("", {}, {["custom-style"] = style}))
end

-- Court title (Fed. R. Civ. P. 10(a)): single lines, the last one with the space below.
local function court_title(meta)
  local lines = {"UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF TEXAS"}
  local division = plain(meta.division)
  if division ~= "" then lines[#lines + 1] = division:upper() end
  local out = {}
  for i, l in ipairs(lines) do
    out[#out + 1] = rawp(i == #lines and "CourtTitleLast" or "CourtTitle", run(l))
  end
  return out
end

-- Table of cells: fixed columns, no borders; each cell is a list of paragraph XML.
local function table_xml(cols, rows)
  local grid, total = {}, 0
  for _, c in ipairs(cols) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c.w .. '"/>'
    total = total + c.w
  end
  local x = {
    '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
      .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
      .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
      .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
      .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>',
    "<w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid>",
  }
  for _, r in ipairs(rows) do
    x[#x + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for i, c in ipairs(cols) do
      x[#x + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c.w .. '" w:type="dxa"/>' .. (c.borders or "") .. (c.mar or "")
        .. "</w:tcPr>" .. (r[i] or '<w:p><w:pPr><w:pStyle w:val="CaptionRow"/></w:pPr></w:p>') .. "</w:tc>"
    end
    x[#x + 1] = "</w:tr>"
  end
  x[#x + 1] = "</w:tbl>"
  return pandoc.RawBlock("openxml", table.concat(x))
end

local function para_xml(style, inner)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. inner .. "</w:p>"
end

-- Party rows: names flush left, the designation indented, "v." between parties (typst party-rows).
local function party_rows(parties)
  local rows = {}
  for k, p in ipairs(parties) do
    if k > 1 then rows[#rows + 1] = {t = "v.", indent = false} end
    for _, nm in ipairs(p.names) do rows[#rows + 1] = {t = plain(nm), indent = false} end
    rows[#rows + 1] = {t = plain(p.designation), indent = true}
  end
  return rows
end

-- Box caption (typst caption-box): party column closed on the right and bottom; C.A. No. and JURY DEMANDED at right.
local function caption_box(meta)
  local left = {}
  for _, r in ipairs(party_rows(meta.caption.parties)) do
    left[#left + 1] = para_xml(r.indent and "CaptionIndent" or "CaptionRow", run(r.t))
  end
  local cn = plain(meta.case_number)
  local ca = run("C.A. No.") .. (cn ~= "" and run(" " .. cn) or "<w:r><w:tab/></w:r>")
  local right = {para_xml("CaptionCA", ca)}
  if meta.jury_demand == true then right[#right + 1] = para_xml("CaptionJury", run("JURY DEMANDED")) end
  return table_xml({
    {w = 4752, borders = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
      mar = '<w:tcMar><w:right w:w="173" w:type="dxa"/><w:bottom w:w="173" w:type="dxa"/></w:tcMar>'},
    {w = 288},
    {w = 4320, mar = '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'},
  }, {{table.concat(left), '<w:p><w:pPr><w:pStyle w:val="CaptionRow"/></w:pPr></w:p>', table.concat(right)}})
end

-- Section-symbol caption (typst caption-section): one row per line, "§" in the middle column, the civil action
-- number and judge at the right from the third row on.
local function caption_section(meta)
  local left = party_rows(meta.caption.parties)
  local right = {}
  local cn = plain(meta.case_number)
  if cn ~= "" then right[#right + 1] = "Civil Action No. " .. cn end
  local judge = plain(meta.judge)
  if judge ~= "" then right[#right + 1] = judge end
  local n = math.max(#left, #right + 2)
  local rows = {}
  for i = 1, n do
    local l = left[i]
    local lc = l and para_xml(l.indent and "CaptionSectionIndent" or "CaptionSection", run(l.t))
      or '<w:p><w:pPr><w:pStyle w:val="CaptionSection"/></w:pPr></w:p>'
    local rc = (i >= 3 and right[i - 2]) and para_xml("CaptionSection", run(right[i - 2]))
      or '<w:p><w:pPr><w:pStyle w:val="CaptionSection"/></w:pPr></w:p>'
    rows[#rows + 1] = {lc, para_xml("CaptionSectionMid", run("§")), rc}
  end
  return table_xml({{w = 4752}, {w = 576}, {w = 4032}}, rows)
end

-- Headings: the body's headings and the certificates, numbered _Toc1, _Toc2, ... for the table of contents.
-- Level 3 and deeper headings are set as level 2 (typst: heading levels 1 to 3 map to 1 and 2).
local function heading_ids(body, meta)
  local ids, entries, cert_ids, k = {}, {}, {}, 0
  for _, b in ipairs(body) do
    if b.t == "Header" then
      k = k + 1
      ids[#ids + 1] = "_Toc" .. k
      local level = math.min(b.level, 2)
      local text = plain(b)
      if level == 1 then text = text:upper() end
      entries[#entries + 1] = {level = level, text = text, id = "_Toc" .. k}
    end
  end
  for _, c in ipairs(CERTIFICATES) do
    if plain(meta[c.key]) ~= "" then
      k = k + 1
      cert_ids[c.key] = "_Toc" .. k
      entries[#entries + 1] = {level = 1, text = c.title, id = "_Toc" .. k}
    end
  end
  return ids, entries, cert_ids
end

-- Page numbers from the render's first pass (docx/render.sh writes "id<TAB>page" lines to TXSD_TOC_PAGES).
local function read_pages()
  local pages = {}
  local path = os.getenv("TXSD_TOC_PAGES")
  if path and path ~= "" then
    local f = io.open(path, "r")
    if f then
      for line in f:lines() do
        local id, page = line:match("^(_Toc%d+)\t(%d+)$")
        if id then pages[id] = page end
      end
      f:close()
    end
  end
  return pages
end

local function pageref(id, pages)
  return '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGEREF ' .. id
    .. ' \\h </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>'
    .. (pages[id] or "0") .. "</w:t></w:r>" .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
end

-- Table of contents (typst outline, depth 2): a TOC field whose entries carry PAGEREF fields to the headings.
local function toc_block(entries, pages)
  local paras = {}
  for i, e in ipairs(entries) do
    local inner = ""
    if i == 1 then
      inner = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    inner = inner .. run(e.text) .. "<w:r><w:tab/></w:r>" .. pageref(e.id, pages)
    if i == #entries then inner = inner .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    paras[#paras + 1] = para_xml(e.level == 1 and "TOC1" or "TOC2", inner)
  end
  return pandoc.RawBlock("openxml", table.concat(paras))
end

-- A heading with its own bookmark (the name the table of contents' PAGEREF fields use). Pandoc would name the
-- bookmark from the identifier with a hash, so the identifier is left empty and the bookmark is written here.
local function bookmarked(level, content, name)
  local id = 9000 + tonumber(name:match("%d+$"))
  local inl = {pandoc.RawInline("openxml", '<w:bookmarkStart w:id="' .. id .. '" w:name="' .. name .. '"/>')}
  for _, x in ipairs(content) do inl[#inl + 1] = x end
  inl[#inl + 1] = pandoc.RawInline("openxml", '<w:bookmarkEnd w:id="' .. id .. '"/>')
  return pandoc.Header(level, inl, pandoc.Attr(""))
end

local function label_for(style, n)
  if style == "UpperAlpha" then return string.char(64 + n) .. "." end
  if style == "LowerAlpha" then return string.char(96 + n) .. "." end
  if style == "UpperRoman" then return (ROMAN[n] or tostring(n)):upper() .. "." end
  if style == "LowerRoman" then return (ROMAN[n] or tostring(n)) .. "." end
  return tostring(n) .. "."
end

-- A list item: the label, a tab, then the item's first paragraph; other blocks of the item follow.
local function item(style, label, blocks)
  local content = {pandoc.Str(label), TAB}
  local out, start = {}, 1
  local first = blocks[1]
  if first and (first.t == "Para" or first.t == "Plain") then
    for _, x in ipairs(first.content) do content[#content + 1] = x end
    start = 2
  end
  out[1] = pandoc.Para(content)
  for i = start, #blocks do out[#out + 1] = blocks[i] end
  return pandoc.Div(out, pandoc.Attr("", {}, {["custom-style"] = style}))
end

local function signature(sig, date)
  local out = {}
  local d = plain(date)
  if d ~= "" then out[#out + 1] = custom("SigDate", {pandoc.Str(d)}) end
  if sig.lead ~= nil and plain(sig.lead) ~= "" then
    out[#out + 1] = custom(d ~= "" and "SigLead" or "SigLeadFirst", sig.lead)
  end
  if sig.party ~= nil and plain(sig.party) ~= "" then out[#out + 1] = custom("SigParty", {pandoc.Strong(sig.party)}) end
  if sig.by ~= nil and plain(sig.by) ~= "" then out[#out + 1] = custom("SigBy", sig.by) end
  local lines = sig.signer_lines or {}
  for i, l in ipairs(lines) do
    out[#out + 1] = custom(i == #lines and "SigLast" or "SigLine", l)
  end
  return out
end

function Pandoc(doc)
  local meta, body = doc.meta, doc.blocks
  local ids, entries, cert_ids = heading_ids(body, meta)
  local out = {}

  for _, b in ipairs(court_title(meta)) do out[#out + 1] = b end
  if plain(meta.caption.style) == "box" then
    out[#out + 1] = caption_box(meta)
  else
    out[#out + 1] = caption_section(meta)
  end
  out[#out + 1] = rawp("BriefTitle", run(plain(meta.brief_title):upper()))

  -- the heading list for the render's page lookup (docx/render.sh pass 1)
  local list_path = os.getenv("TXSD_TOC_LIST")
  if list_path and list_path ~= "" then
    local f = assert(io.open(list_path, "w"))
    for _, e in ipairs(entries) do f:write(e.id, "\t", e.text, "\n") end
    f:close()
  end

  if meta.toc == true then
    out[#out + 1] = rawp("TOCTitle", run("TABLE OF CONTENTS"))
    out[#out + 1] = toc_block(entries, read_pages())
    out[#out + 1] = pandoc.RawBlock("openxml", "<w:p><w:pPr><w:pStyle w:val=\"PageStart\"/><w:pageBreakBefore/></w:pPr></w:p>")
  elseif meta.lead_in ~= nil and plain(meta.lead_in) ~= "" then
    out[#out + 1] = pandoc.Para(meta.lead_in)
  end

  -- A prayer item ("A. ...", typst: ^[A-Z]\.\s): pandoc takes a single space after a capital letter as text,
  -- not as a list, so the item is recognized here. It keeps its letter; it is not numbered.
  local function is_prayer(b)
    return (b.t == "Para" or b.t == "Plain") and b.content[1] ~= nil and b.content[1].t == "Str"
      and b.content[1].text:match("^%u%.$") ~= nil and b.content[2] ~= nil and b.content[2].t == "Space"
  end

  local unnum, n, h = false, 0, 0
  for bi, b in ipairs(body) do
    if b.t == "Header" then
      local label = plain(b)
      unnum = UNNUMBERED[label:upper()] == true
      h = h + 1
      if b.level == 1 then
        out[#out + 1] = bookmarked(1, {pandoc.Str(label:upper())}, ids[h])
      else
        out[#out + 1] = bookmarked(2, b.content, ids[h])
      end
    elseif is_prayer(b) then
      local rest = {}
      for i = 3, #b.content do rest[#rest + 1] = b.content[i] end
      out[#out + 1] = item("NumberedItem", b.content[1].text, {pandoc.Para(rest)})
    elseif b.t == "Para" or b.t == "Plain" then
      if NUMBERED and not unnum then
        n = n + 1
        local content = {pandoc.Str(tostring(n) .. "."), TAB}
        for _, x in ipairs(b.content) do content[#content + 1] = x end
        out[#out + 1] = pandoc.Div({pandoc.Para(content)}, pandoc.Attr("", {}, {["custom-style"] = "NumberedParagraph"}))
      elseif unnum then
        out[#out + 1] = custom("LeadKeep", b.content)
      else
        out[#out + 1] = pandoc.Para(b.content)
      end
    elseif b.t == "BulletList" then
      for i, it in ipairs(b.content) do
        out[#out + 1] = item("LetteredItem", "(" .. LETTERS[i] .. ")", it)
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes.start
      local style = b.listAttributes.style
      for i, it in ipairs(b.content) do
        out[#out + 1] = item("NumberedItem", label_for(style, start + i - 1), it)
      end
    else
      out[#out + 1] = b
    end
  end

  if meta.signature ~= nil then
    for _, b in ipairs(signature(meta.signature, meta.date)) do out[#out + 1] = b end
  end

  for _, c in ipairs(CERTIFICATES) do
    if plain(meta[c.key]) ~= "" then
      out[#out + 1] = bookmarked(1, {pandoc.Str(c.title)}, cert_ids[c.key])
      out[#out + 1] = pandoc.Para(meta[c.key])
      if plain(meta.certificate_signature) ~= "" then
        out[#out + 1] = custom("SigLast", meta.certificate_signature)
      end
    end
  end

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
