-- txnd motion brief, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The cover (court title, caption, title of the brief), the table of contents and the index of authorities, and the
-- signature blocks are built here from the frontmatter, as the typst template builds them
-- (../typst/txnd-motion-brief.typ), in the styles of reference.docx. The body keeps its markdown structure.
-- Sections: the cover has no page number; the tables are numbered in roman from ii (the cover is page i, as in the
-- typst template); the body is numbered in arabic from 1. render.sh writes the footer's relationship id where this
-- filter writes the placeholder RIDPAGE. Limits (BLOCKED page numbers in the tables): see ../README.md, "Engines".

local TEXT_W = 9360 -- 6.5 in in twips (letter, 1 in margins)
local CAP_LEFT = 4320 -- 3.0 in: the party column (caption-left)
local CAP_SIGN = 432 -- 0.3 in: the section-mark column (caption-sign)
local CAP_RIGHT = TEXT_W - CAP_LEFT - CAP_SIGN
local SIG_INDENT = 4320 -- 3.0 in: the signature block (pad left)
local PITCH = 480 -- 24 pt, the double-spaced pitch in twips (typst: pitch)
local GAP = 120 -- 6 pt: the gap between the lines of a stack (typst: single-leading)
local HALF = 240 -- 12 pt: the gap between blocks (typst: pitch * 0.5)
local PAGE_SIZE = '<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />'

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function merge(a, b)
  local out = {}
  for k, v in pairs(a) do out[k] = v end
  for k, v in pairs(b) do out[k] = v end
  return out
end

-- one run of text with the character formatting in fmt
local function run(text, fmt)
  local pr = ""
  if fmt.b then pr = pr .. "<w:b/>" end
  if fmt.i then pr = pr .. "<w:i/>" end
  local rpr = pr ~= "" and ("<w:rPr>" .. pr .. "</w:rPr>") or ""
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- inline markdown (Str, Emph, Strong, Quoted, ...) as runs
local function runs(inlines, fmt)
  fmt = fmt or {}
  local out = {}
  for _, el in ipairs(inlines) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, fmt)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out[#out + 1] = run(" ", fmt)
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, merge(fmt, { i = true }))
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, merge(fmt, { b = true }))
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], fmt) .. runs(el.content, fmt) .. run(q[2], fmt)
    elseif t == "Span" then
      out[#out + 1] = runs(el.content, fmt)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), fmt)
    end
  end
  return table.concat(out)
end

-- a paragraph: style, then keep-with-next, page break, spacing and justification (the order the schema wants)
local function para(content, style, o)
  o = o or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if o.keep then ppr = ppr .. "<w:keepNext/>" end
  if o.pbb then ppr = ppr .. "<w:pageBreakBefore/>" end
  if o.before or o.after then
    ppr = ppr .. string.format('<w:spacing w:before="%d" w:after="%d"/>', o.before or 0, o.after or 0)
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (content or "") .. "</w:p>"
end

-- the paragraph that ends a section: its properties are the section's. The schema orders them: the footer
-- reference, the page size and margins, then the page numbering.
local function section_end(footer, numbering)
  return "<w:p><w:pPr><w:sectPr>" .. footer .. PAGE_SIZE .. numbering .. "</w:sectPr></w:pPr></w:p>"
end

-- a table with no borders: rows of cells, each cell a string of paragraphs
local function table_xml(widths, rows)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local trs = {}
  for _, r in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(r) do
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. c .. "</w:tc>"
    end
    trs[#trs + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>" .. table.concat(tcs) .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. '</w:tblCellMar></w:tblPr><w:tblGrid>' .. table.concat(grid) .. "</w:tblGrid>" .. table.concat(trs) .. "</w:tbl>"
end

-- the caption: one row per party name (and designation), a section mark beside each, the case number on the
-- middle row; the rows are spaced as the typst caption's row gutter
local function caption(meta)
  local lines = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then lines[#lines + 1] = { pandoc.Str("v.") } end
    for _, n in ipairs(p.names) do lines[#lines + 1] = n end
    lines[#lines + 1] = p.designation
  end
  local mid = math.floor(#lines / 2)
  local rows = {}
  for i, l in ipairs(lines) do
    local right = para("", "Single", { after = GAP })
    if i == mid then
      right = para(run("CIVIL ACTION NO. " .. plain(meta.case_number), {}), "Single", { after = GAP })
    end
    rows[#rows + 1] = {
      para(runs(l, {}), "Single", { after = GAP }),
      para(run("§", {}), "Centered", { after = GAP }),
      right,
    }
  end
  return table_xml({ CAP_LEFT, CAP_SIGN, CAP_RIGHT }, rows)
end

local function cover(meta)
  local out = {}
  local court = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF TEXAS" }
  if meta.court_division and plain(meta.court_division) ~= "" then
    court[#court + 1] = plain(meta.court_division):upper()
  end
  for i, line in ipairs(court) do
    local last = i == #court
    out[#out + 1] = para(run(line, { b = true }), "Centered", { after = last and PITCH or GAP })
  end
  out[#out + 1] = caption(meta)
  out[#out + 1] = para(runs(meta.brief_title, { b = true }), "Centered", { before = 2 * PITCH })
  return out
end

-- the table of contents: a TOC field over the body's headings (levels 1 to 3). Its cached result lists the
-- headings without page numbers: the numbers come from a field update (BLOCKED, see the README).
local function toc(headings)
  local out = { para(run("TABLE OF CONTENTS", { b = true }), "Centered", { after = PITCH }) }
  local begin = '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>'
    .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  local finish = '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
  if #headings == 0 then
    out[#out + 1] = para(begin .. finish, "TOC1")
    return out
  end
  for i, h in ipairs(headings) do
    local content = run(plain(h.content), {})
    if i == 1 then content = begin .. content end
    if i == #headings then content = content .. finish end
    out[#out + 1] = para(content, "TOC" .. h.level)
  end
  return out
end

-- the index of authorities: each group (Cases, Statutes, Rules) and its entries in the frontmatter's order. The
-- pages on which each authority is cited are not written (BLOCKED, see the README).
local function index_of_authorities(meta)
  local out = { para(run("INDEX OF AUTHORITIES", { b = true }), "Centered", { pbb = true, after = PITCH }) }
  for _, cat in ipairs(meta.authorities or {}) do
    out[#out + 1] = para(run(plain(cat.category), { b = true }), "AuthorityGroup")
    for _, e in ipairs(cat.entries) do
      out[#out + 1] = para(runs(e.cite, {}), "Authority")
    end
  end
  return out
end

-- the signature blocks, indented to the right half: "Respectfully submitted," and, for each signer, the
-- signature (/s/ and the name), the name, the bar number, the firm, the address and the role (typst line-stack)
local function signature(meta)
  local out = { para(run("Respectfully submitted,", {}), "SigBlock", { before = PITCH }) }
  for _, s in ipairs(meta.signature or {}) do
    local items = { { pandoc.Str("/s/ " .. plain(s.signer)) }, { pandoc.Str(plain(s.signer)) }, s.bar }
    for _, group in ipairs({ s.firm, s.address, s.lines }) do
      for _, it in ipairs(group) do items[#items + 1] = it end
    end
    for i, it in ipairs(items) do
      out[#out + 1] = para(runs(it, {}), "SigBlock", { before = (i == 1) and HALF or GAP })
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc would write the frontmatter date as a title line; the brief has no date line
  meta.date = nil

  local headings = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 3 then headings[#headings + 1] = b end
  end

  local out = {}
  local function raw(x) out[#out + 1] = pandoc.RawBlock("openxml", x) end

  -- section 1: the cover (no footer, so no page number)
  for _, x in ipairs(cover(meta)) do raw(x) end
  raw(section_end("", ""))

  -- section 2: the tables, roman numerals from ii (the cover is page i)
  for _, x in ipairs(toc(headings)) do raw(x) end
  for _, x in ipairs(index_of_authorities(meta)) do raw(x) end
  raw(section_end('<w:footerReference w:type="default" r:id="RIDPAGE" />', '<w:pgNumType w:fmt="lowerRoman" w:start="2" />'))

  -- section 3: the body (its section is the reference's last sectPr: arabic from 1)
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  for _, x in ipairs(signature(meta)) do raw(x) end

  doc.blocks = out
  return doc
end
