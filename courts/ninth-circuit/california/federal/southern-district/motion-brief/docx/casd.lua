-- S.D. Cal. motion-brief (memorandum of points and authorities): pandoc filter for the docx engine. The same content as
-- the typst template (casd-motion-brief.typ) from the same markdown contract. Styles come from docx/reference.xml (fb
-- render builds reference.docx from it; pleading paper: Times New Roman 14 pt, 24 pt exact lines, first-line indent,
-- heading styles, Word line numbering). This filter writes what styles cannot: the cover (counsel, court, caption,
-- title, hearing block), the table of contents and table of authorities, the "I." and "A." labels of the headings, the
-- signature block, and three sections as typst has them: the cover (footer without a page number), the contents and
-- authorities (i, ii ...) and the memorandum (1, 2 ...). Each footer carries the page number, the paper's title and
-- the case number (typst footer-block); they come from the sample, so this filter writes them (FORMBOOK_FOOTERS).
-- The pages in the two tables: fb render (tools/fb/src/docxpass.rs) renders the document once, finds the page of every
-- heading and citation in that PDF (the needles this filter writes to FORMBOOK_NEEDLES), and renders again with those
-- pages (FORMBOOK_PAGES) until they settle; this filter writes the last section (FORMBOOK_FINAL). Word may paginate
-- slightly differently from the LibreOffice PDF the page numbers come from (docs/DOCX.md).

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text(m)
  if m == nil then return "" end
  return (pandoc.utils.stringify(m):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function need(meta, key)
  if meta[key] == nil then error("casd-motion-brief: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

-- One WordprocessingML paragraph from runs. runs: list of {s = text, i = italic, b = bold}.
-- opts: jc, ind_left, line (240 single, 480 double), after/before (twips), keep_next, before_break.
local function para_runs(runs, opts)
  opts = opts or {}
  local ppr = ""
  if opts.keep_next then ppr = ppr .. "<w:keepNext/>" end
  if opts.before_break then ppr = ppr .. "<w:pageBreakBefore/>" end
  ppr = ppr .. '<w:spacing w:before="' .. (opts.before or 0) .. '" w:after="' .. (opts.after or 0) .. '" w:line="' .. (opts.line or 240) .. '" w:lineRule="auto"/>'
  if opts.ind_left then ppr = ppr .. '<w:ind w:left="' .. opts.ind_left .. '" w:firstLine="0"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local body = {}
  for _, r in ipairs(runs) do
    local rpr = ""
    if r.b or r.i then rpr = "<w:rPr>" .. (r.b and "<w:b/>" or "") .. (r.i and "<w:i/>" or "") .. "</w:rPr>" end
    body[#body + 1] = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(r.s) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. table.concat(body) .. "</w:p>"
end

local function para(s, opts)
  return para_runs({ { s = s, b = opts and opts.bold, i = opts and opts.italic } }, opts)
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function lines_of(list)
  local out = {}
  for _, v in ipairs(list or {}) do out[#out + 1] = text(v) end
  return out
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return string.upper(out)
end

local function label_run(s)
  return pandoc.RawInline("openxml", '<w:r><w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r><w:r><w:tab/></w:r>')
end

-- The cover: counsel (single spaced, upper left), court, caption, title and hearing block.
local function cover(meta)
  local out = {}
  for _, s in ipairs(lines_of(need(meta, "counsel"))) do out[#out + 1] = raw(para(s)) end
  if meta.counsel_role then out[#out + 1] = raw(para(text(meta.counsel_role), { italic = true })) end
  local court = lines_of(need(meta, "court"))
  for i, s in ipairs(court) do
    out[#out + 1] = raw(para(s:upper(), { jc = "center", bold = true, before = i == 1 and 240 or 0, after = i == #court and 240 or 0 }))
  end
  -- The caption table (typst caption-table): the parties on the left, closed by a rule at the right and the bottom;
  -- the case number, the title and the noticed hearing on the right (Civil L.R. 7-2(b)(1), 7-4(a)(1)).
  local left = {}
  local caption = need(meta, "caption")
  for i, p in ipairs(caption) do
    for _, s in ipairs(lines_of(p.names)) do left[#left + 1] = para(s) end
    left[#left + 1] = para(text(p.designation), { ind_left = 2592 })
    if i < #caption then left[#left + 1] = para("v.", { jc = "center", before = 240, after = 240 }) end
  end
  local right = { para("Case No. " .. text(need(meta, "case_number"))),
    para(text(need(meta, "brief_title")):upper(), { bold = true, before = 240, after = 240 }) }
  local h = need(meta, "hearing")
  for _, k in ipairs({ { "date", "Date: " }, { "time", "Time: " }, { "place", "Place: " }, { "judge", "" } }) do
    if h[k[1]] then right[#right + 1] = para(k[2] .. text(h[k[1]])) end
  end
  local half = 4320
  out[#out + 1] = raw('<w:tbl><w:tblPr><w:tblW w:w="' .. 2 * half .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/>'
    .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. half .. '"/><w:gridCol w:w="' .. half .. '"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr><w:tc><w:tcPr><w:tcW w:w="' .. half .. '" w:type="dxa"/><w:tcBorders>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '</w:tcBorders><w:tcMar><w:bottom w:w="140" w:type="dxa"/><w:right w:w="336" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. '</w:tc><w:tc><w:tcPr><w:tcW w:w="' .. half .. '" w:type="dxa"/><w:tcMar><w:top w:w="84" w:type="dxa"/>'
    .. '<w:left w:w="336" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. "</w:tc></w:tr></w:tbl>")
  -- the cover section ends here (Pandoc)
  return out
end


local TOC_DEPTH = 4    -- heading levels listed in the contents (typst: hd.level <= 4)
local PASSIM = 7       -- an authority cited on this many pages or more is "passim" (typst: passim-threshold)
local NEEDLE_MAX = 60  -- a needle is a prefix of the text (letters and digits only)
local TAB_R = 8620     -- the right tab of the tables: 1 pt inside the 6 in text width (a glyph may overhang)

-- The page setup of every section (reference.xml has the same): letter, the pleading margins, the rules beside the
-- text, Word line numbering restarting on each page (27 lines of 24 pt, as typst), footnotes numbered through the
-- brief (LibreOffice reads eachSect as a restart on every page); the footer sits 6 pt above the
-- page edge, below the last line.
local SECT = '<w:footnotePr><w:numRestart w:val="continuous"/></w:footnotePr><w:type w:val="nextPage"/>'
  .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" w:header="720"'
  .. ' w:footer="120" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14"'
  .. ' w:color="auto"/><w:right w:val="single" w:sz="4" w:space="7" w:color="auto"/></w:pgBorders>'
  .. '<w:lnNumType w:countBy="1" w:distance="720" w:restart="newPage"/>'

local function sect_pr(footer, fmt)
  local pg = fmt and ('<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/>') or ""
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>' .. SECT .. pg .. "</w:sectPr>"
end

-- The paragraph that ends a section (not numbered as a pleading line).
local function section_end(footer, fmt)
  return raw('<w:p><w:pPr><w:suppressLineNumbers/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. sect_pr(footer, fmt) .. "</w:pPr></w:p>")
end

-- The footers (typst footer-block, 10 pt, centered below the last line): the page number when numbered, the paper's title
-- in capitals, the case number.
local function footer_xml(meta, numbered)
  local function p(runs, after)
    return '<w:p><w:pPr><w:suppressLineNumbers/><w:spacing w:before="0" w:after="' .. (after or 0)
      .. '" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>' .. runs .. "</w:p>"
  end
  local function r(s) return '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>" end
  local page = '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r>'
    .. '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    .. '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r>' .. r("1")
    .. '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>'
  return (numbered and p(page, 80) or "") .. p(r(text(need(meta, "footer_title")):upper()))
    .. p(r("No. " .. text(need(meta, "case_number"))))
end

-- ---------------------------------------------------------------------------
-- Needles and pages (the contract is in tools/fb/src/docxpages.rs)
-- ---------------------------------------------------------------------------

-- Letters and digits only, lower case: fb render normalizes the PDF text the same way.
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- A needle: { id, kind, needle, fallback }. Kind B (body, in document order: moves the search on), N (inside a
-- footnote: searched from the page the body has reached, moves nothing).
local needles = {}
local function needle(id, kind, s, context)
  local short = norm(s):sub(1, NEEDLE_MAX)
  local long = norm(s .. " " .. (context or "")):sub(1, NEEDLE_MAX)
  if short == "" then short = long end
  needles[#needles + 1] = { id = id, kind = kind, needle = long, fallback = short }
end

-- The pages of the previous pass: id -> { page, label }. Empty on the first pass.
local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local id, page, lab = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = { page = tonumber(page) or 0, label = lab } end
  end
  f:close()
end

local function label_of(id)
  local l = labels[id]
  if l then return l.label end
  return "00" -- the first pass: a placeholder of the final width
end

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- A row of a table: runs, the dot leader to the right tab and the page (`page`, a run), hanging under `left`.
local function row(runs_xml, page_xml, left, hanging, right, after)
  return raw('<w:p><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. TAB_R .. '"/></w:tabs>'
    .. '<w:spacing w:before="0" w:after="' .. after .. '" w:line="240" w:lineRule="auto"/>'
    .. '<w:ind w:left="' .. left .. '" w:right="' .. right .. '" w:hanging="' .. hanging .. '"/></w:pPr>'
    .. runs_xml .. '<w:r><w:t xml:space="preserve"> </w:t></w:r><w:r><w:tab/></w:r>' .. page_xml .. "</w:p>")
end

local function run_xml(s, i)
  return "<w:r>" .. (i and "<w:rPr><w:i/></w:rPr>" or "") .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

-- The column label above the page numbers ("Page", "Page(s)"), bold and right-aligned (typst).
local function page_head(s)
  return raw(para(s, { jc = "right", bold = true, keep_next = true, after = 120 }))
end

-- Heading labels (typst heading-num): level 2 "I.", 3 "A.", 4 "1.", 5 "a.".
local function heading_label(level, k)
  if level == 2 then return roman(k) .. "." end
  if level == 3 then return string.char(64 + k) .. "." end
  if level == 4 then return tostring(k) .. "." end
  if level == 5 then return string.char(96 + k) .. "." end
  return nil
end

-- Table of contents (typst toc-section): headings to level 4, level 1 in capitals, labels in a hanging indent.
local function toc(entries)
  local out = {}
  out[#out + 1] = raw(para("TABLE OF CONTENTS", { jc = "center", bold = true, line = 480 }))
  out[#out + 1] = page_head("Page")
  for _, e in ipairs(entries) do
    local lead, left = "", 720
    if e.label then
      lead = run_xml(e.label) .. "<w:r><w:tab/></w:r>"
      left = (e.level - 1) * 720
    end
    out[#out + 1] = row(lead .. run_xml(e.level == 1 and e.text:upper() or e.text), run_xml(label_of(e.id)), left, 720, 720, 120)
  end
  return out
end

local GROUPS = {
  { "case", "Cases" },
  { "statute", "Federal Statutes" },
  { "rule", "Federal Rules" },
  { "regulation", "Federal Regulations" },
  { "other", "Other Authorities" },
}

-- Table of authorities (typst toa-section): the authorities the body links with toa: keys, grouped by kind, each with
-- the distinct pages it is cited on, in page order ("passim" from PASSIM pages).
local function toa(meta, keys, occurrences)
  local out = {}
  out[#out + 1] = raw(para("TABLE OF AUTHORITIES", { jc = "center", bold = true, line = 480, before_break = true }))
  out[#out + 1] = page_head("Page(s)")
  local auth = meta.authorities
  for _, g in ipairs(GROUPS) do
    local items = {}
    for _, k in ipairs(keys) do
      local a = auth and auth[k]
      if a == nil then error("casd-motion-brief: toa key `" .. k .. "` has no entry in authorities") end
      if text(a.kind) == g[1] then
        local name = text(a.name)
        items[#items + 1] = { key = k, name = name, cite = text(a.cite), italic = g[1] == "case",
          sort = (name ~= "" and name or text(a.cite)):lower() }
      end
    end
    if #items > 0 then
      table.sort(items, function(x, y) return x.sort < y.sort end)
      out[#out + 1] = raw(para(g[2], { bold = true, before = 240, after = 120, keep_next = true }))
      for _, it in ipairs(items) do
        local pages, seen = {}, {}
        for oi, o in ipairs(occurrences) do
          if o.key == it.key then
            local l = labels[o.id]
            local p = l and l.page or -oi
            if not seen[p] then
              seen[p] = true
              pages[#pages + 1] = { page = l and l.page or 0, label = l and l.label or "00" }
            end
          end
        end
        table.sort(pages, function(x, y) return x.page < y.page end)
        local list
        if #pages >= PASSIM then
          list = run_xml("passim", true)
        else
          local l = {}
          for _, p in ipairs(pages) do l[#l + 1] = p.label end
          list = run_xml(table.concat(l, ", "))
        end
        local runs = run_xml(it.name, it.italic)
        if it.cite ~= "" then runs = runs .. run_xml((it.name ~= "" and ", " or "") .. it.cite) end
        out[#out + 1] = row(runs, list, 504, 504, 1120, 120)
      end
    end
  end
  return out
end

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  if meta.date then out[#out + 1] = raw(para("Dated: " .. text(meta.date), { before = 480, keep_next = true })) end
  out[#out + 1] = raw(para("Respectfully submitted,", { ind_left = 4680, before = 240, keep_next = true }))
  for _, s in ipairs(lines_of(sig.preamble)) do out[#out + 1] = raw(para(s, { ind_left = 4680, before = 240, keep_next = true })) end
  out[#out + 1] = raw(para("By: /s/ " .. text(sig.signer), { ind_left = 4680, before = 480, keep_next = true }))
  for _, s in ipairs(lines_of(sig.lines)) do out[#out + 1] = raw(para(s, { ind_left = 4680, keep_next = true })) end
  return out
end

function Pandoc(doc)
  load_pages()
  local meta = doc.meta

  -- Citations, in document order: each `toa:` link is an occurrence and a needle (kind N inside a footnote).
  local keys, seen, occurrences = {}, {}, {}
  local scan_blocks
  local function scan_inlines(list, in_note)
    for i, el in ipairs(list) do
      if el.t == "Link" and el.target:match("^toa:") then
        local k = el.target:sub(5)
        if not seen[k] then
          seen[k] = true
          keys[#keys + 1] = k
        end
        occurrences[#occurrences + 1] = { key = k, id = "T:" .. (#occurrences + 1) }
        local rest = {}
        for j = i + 1, #list do rest[#rest + 1] = list[j] end
        needle(occurrences[#occurrences].id, in_note and "N" or "B", text(el.content), pandoc.utils.stringify(rest))
      elseif el.t == "Note" then
        scan_blocks(el.content, true)
      elseif el.content and type(el.content) ~= "string" then
        scan_inlines(el.content, in_note)
      end
    end
  end
  scan_blocks = function(list, in_note)
    for _, b in ipairs(list) do
      if b.t == "Para" or b.t == "Plain" then
        scan_inlines(b.content, in_note)
      elseif b.t == "BlockQuote" or b.t == "Div" then
        scan_blocks(b.content, in_note)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for _, item in ipairs(b.content) do scan_blocks(item, in_note) end
      end
    end
  end

  -- The memorandum: heading labels, contents entries and needles of headings and citations, in order. Its page 1 is
  -- the page of its first block.
  local src = doc.blocks
  local body_id = "S:body"
  if src[1] and src[1].t == "Header" then
    body_id = "H:1"
  elseif src[1] then
    needle(body_id, "B", pandoc.utils.stringify(src[1]):sub(1, NEEDLE_MAX), "")
  end
  local counts = { 0, 0, 0, 0, 0, 0 }
  local body, entries, h_n = {}, {}, 0
  for i, b in ipairs(src) do
    if b.t == "Header" then
      counts[b.level] = counts[b.level] + 1
      for k = b.level + 1, 6 do counts[k] = 0 end
      local lab = heading_label(b.level, counts[b.level])
      h_n = h_n + 1
      local id = "H:" .. h_n
      local nxt = src[i + 1] and pandoc.utils.stringify(src[i + 1]):sub(1, 40) or ""
      needle(id, "B", (lab and (lab .. " ") or "") .. text(b.content), nxt)
      if b.level <= TOC_DEPTH then entries[#entries + 1] = { id = id, level = b.level, label = lab, text = text(b.content) } end
      if lab then
        local inl = { label_run(lab) }
        for _, x in ipairs(b.content) do inl[#inl + 1] = x end
        body[#body + 1] = pandoc.Header(b.level, inl)
      else
        body[#body + 1] = b
      end
    else
      scan_blocks({ b }, false)
      body[#body + 1] = b
    end
  end
  body = pandoc.Pandoc(body):walk({
    Link = function(el)
      if el.target:match("^toa:") then return el.content end
      return nil
    end,
  }).blocks
  -- the last paragraph stays with the signature block (typst: the signature block follows it on the page)
  if body[#body] and body[#body].t == "Para" then
    body[#body] = pandoc.Div({ body[#body] }, pandoc.Attr("", {}, { ["custom-style"] = "BodyKeep" }))
  end

  -- the needles of the two tables come first (they precede the memorandum), then the memorandum's
  local first_group = ""
  for _, g in ipairs(GROUPS) do
    for _, k in ipairs(keys) do
      local a = meta.authorities and meta.authorities[k]
      if first_group == "" and a and text(a.kind) == g[1] then first_group = g[2] end
    end
  end
  table.insert(needles, 1, { id = "S:toc", kind = "B", needle = norm("TABLE OF CONTENTS Page"), fallback = norm("TABLE OF CONTENTS") })
  table.insert(needles, 2, { id = "S:toa", kind = "B", needle = norm("TABLE OF AUTHORITIES Page(s) " .. first_group):sub(1, NEEDLE_MAX),
    fallback = norm("TABLE OF AUTHORITIES") })
  local nl = {}
  for _, n in ipairs(needles) do nl[#nl + 1] = table.concat({ n.id, n.kind, n.needle, n.fallback }, "\t") end
  -- how fb render labels pages: the front matter from the contents (i, ii ...), the memorandum from its first block
  nl[#nl + 1] = "#section\tS:toc\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_id .. "\tdecimal\t"
  write_file("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  write_file("FORMBOOK_FOOTERS", "rIdCasdCover\t" .. footer_xml(meta, false) .. "\nrIdCasdPage\t" .. footer_xml(meta, true) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdCasdPage", "decimal"))

  local out = {}
  local function addall(xs) for _, x in ipairs(xs) do out[#out + 1] = x end end
  addall(cover(meta))
  out[#out + 1] = section_end("rIdCasdCover")
  addall(toc(entries))
  addall(toa(meta, keys, occurrences))
  out[#out + 1] = section_end("rIdCasdPage", "lowerRoman")
  addall(body)
  addall(signature(meta))
  for _, k in ipairs({ "title", "subtitle", "author", "date", "abstract" }) do doc.meta[k] = nil end
  doc.blocks = out
  return doc
end
