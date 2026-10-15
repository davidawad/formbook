-- txnd complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The cover (court title, caption, title of the paper) and the signature block are built here from the frontmatter,
-- as the typst template builds them (../typst/txnd-complaint.typ), in the styles of reference.docx. The body keeps
-- its markdown structure; its paragraphs are numbered as the typst template numbers them (Fed. R. Civ. P. 10(b)).
-- The page number is the footer of reference.docx. Limits: see ../README.md, "Engines".

local TEXT_W = 9360 -- 6.5 in in twips (letter, 1 in margins)
local CAP_LEFT = 5184 -- 3.6 in: the party column (caption-left)
local CAP_SIGN = 576 -- 0.4 in: the section-mark column (caption-sign)
local CAP_RIGHT = TEXT_W - CAP_LEFT - CAP_SIGN
local SIG_LEFT = 4320 -- 3.0 in: the "Dated" column of the signature block
local SIG_GUTTER = 288 -- 0.2 in
local SIG_RIGHT = TEXT_W - SIG_LEFT - SIG_GUTTER
local PITCH = 480 -- 24 pt: the double-spaced pitch, in twips (typst: pitch)
local GAP = 120 -- 6 pt: the gap between single-spaced lines of a stack (typst: single-leading)
local HALF = 240 -- 12 pt: the gap between blocks of the signature (typst: pitch * 0.5)

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

-- a paragraph: style, then spacing, justification and keep-with-next (in the order the schema wants)
local function para(content, style, o)
  o = o or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if o.keep then ppr = ppr .. "<w:keepNext/>" end
  if o.before or o.after then
    ppr = ppr .. string.format('<w:spacing w:before="%d" w:after="%d"/>', o.before or 0, o.after or 0)
  end
  if o.jc then ppr = ppr .. '<w:jc w:val="' .. o.jc .. '"/>' end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. (content or "") .. "</w:p>"
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
-- middle row and the jury legend below it; the rows are spaced as the typst caption's row gutter (see caption())
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
    elseif i == mid + 1 and meta.jury_demand then
      right = para(run("JURY TRIAL DEMANDED", { b = true }), "Single", { after = GAP })
    end
    rows[#rows + 1] = {
      para(runs(l), "Single", { after = GAP }),
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
  out[#out + 1] = para(run(plain(meta.brief_title):upper(), { b = true }), "Centered", { before = PITCH, after = PITCH })
  return out
end

-- the signature block: the date on the left; on the right "Respectfully submitted," and the firm, the signature
-- (/s/ and the name), the bar number, the address and the role, each line single-spaced with a gap (typst line-stack)
local function signature(meta)
  local sig = meta.signature
  local right = {}
  local function stack(items, before)
    for i, it in ipairs(items) do
      right[#right + 1] = para(runs(it), "Single", { after = GAP, before = (i == 1) and before or 0 })
    end
  end
  right[#right + 1] = para(run("Respectfully submitted,", {}), "Single", { before = HALF })
  stack(sig.firm, HALF)
  stack({ { pandoc.Str("/s/ " .. plain(sig.signer)) }, { pandoc.Str(plain(sig.signer)) }, sig.bar }, HALF)
  stack(sig.address, HALF)
  stack(sig.lines, HALF)
  local dated = para(run("Dated: " .. plain(meta.date), {}), "Single", { before = PITCH })
  return table_xml({ SIG_LEFT, SIG_GUTTER, SIG_RIGHT }, { { dated, para("", "Single"), table.concat(right) } })
end

function Pandoc(doc)
  local meta = doc.meta
  -- pandoc would write the frontmatter date as a title line; the date is printed in the signature block instead
  meta.date = nil
  local body = {}
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      -- each body paragraph is numbered; headings and list items are not (see the typst template)
      n = n + 1
      local num = pandoc.Str(n .. ".")
      local content = pandoc.List({ num, pandoc.Space() })
      content:extend(b.content)
      body[#body + 1] = pandoc.Para(content)
    else
      body[#body + 1] = b
    end
  end
  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  for _, b in ipairs(body) do out[#out + 1] = b end
  out[#out + 1] = pandoc.RawBlock("openxml", signature(meta))
  doc.blocks = out
  return doc
end
