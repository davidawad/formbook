-- SCOTUS cert petition, DOCX engine (docs/DOCX.md): markdown contract -> Word document on reference.docx.
-- Mirrors typst/scotus-cert-petition-cert-petition.typ. The cover, caption, counsel, front pages, tables of contents and
-- authorities, signature and certificate are written here as paragraphs in the custom styles of reference.docx; the
-- body keeps its markdown structure. Sections (cover | Questions Presented | Parties | front matter | body | certificate)
-- carry their own footers (rIdFtrNone, rIdFtrPage: fb render writes the footer parts; the page numbers are i, ii ...
-- then 1, 2 ...); this filter writes the last section, the certificate's (FORMBOOK_FINAL).
-- Passes (fb render, tools/fb/src/docxpass.rs): each writes the needles (headings and citations, in document order) for
-- the LibreOffice PDF (FORMBOOK_NEEDLES, format: tools/fb/src/docxpages.rs) and the page labels of the pass before
-- (FORMBOOK_PAGES), until they settle. Page labels are then cached text (no field needs an update).

local CFG = {
  word_limit = 9000,          -- Rule 33.1(g)(i)
  toa_groups = {
    { "case", "Cases" },
    { "constitution", "Constitutional Provisions" },
    { "statute", "Statutes and Other Authorities" },
  },
  counsel_gap = 2500,         -- twips of blank space above the counsel block (the typst v(1fr) gap; tuned against typst)
}

-- ---- the pages of the pass before (fb render): needle id -> { page, label }; empty on the first pass ----
local PAGES = {}
do
  local pf = os.getenv("FORMBOOK_PAGES")
  if pf and pf ~= "" then
    local h = assert(io.open(pf, "r"))
    for line in h:lines() do
      local id, page, label = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
      if id then PAGES[id] = { page = tonumber(page) or 0, label = label } end
    end
    h:close()
  end
end
local FIRST_PASS = next(PAGES) == nil
local NEEDLE_MAX = 60       -- letters and digits of a heading's needle (its text and what follows it)

local function norm(s) return (s:lower():gsub("[^a-z0-9]", "")) end
local function esc(s) return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
local function str(v) if v == nil then return "" end return pandoc.utils.stringify(v) end

-- ---- OOXML helpers (cover, counsel, front matter, signature, certificate) ----
local function rpr(bold, ital, sz)
  local s = ""
  if bold then s = s .. "<w:b/><w:bCs/>" end
  if ital then s = s .. "<w:i/><w:iCs/>" end
  if sz then s = s .. '<w:sz w:val="' .. sz .. '"/><w:szCs w:val="' .. sz .. '"/>' end
  if s == "" then return "" end
  return "<w:rPr>" .. s .. "</w:rPr>"
end

local function run(text, bold, ital, sz)
  return "<w:r>" .. rpr(bold, ital, sz) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local TAB = "<w:r><w:tab/></w:r>"
local BR = "<w:r><w:br/></w:r>"

-- markdown inlines (from YAML values or literal text) -> runs; Emph is italic, Strong is bold
local function inl_runs(ils, sz, bold, ital, out)
  out = out or {}
  for _, el in ipairs(ils) do
    if el.t == "Str" then out[#out + 1] = run(el.text, bold, ital, sz)
    elseif el.t == "Space" or el.t == "SoftBreak" then out[#out + 1] = run(" ", bold, ital, sz)
    elseif el.t == "Emph" then inl_runs(el.content, sz, bold, true, out)
    elseif el.t == "Strong" then inl_runs(el.content, sz, true, ital, out)
    elseif el.t == "Link" then inl_runs(el.content, sz, bold, ital, out)
    else out[#out + 1] = run(pandoc.utils.stringify(el), bold, ital, sz) end
  end
  return out
end

-- a markdown string (plain text in this file) -> runs
local function md_runs(s, sz, bold, ital)
  local ils = pandoc.read(s, "markdown").blocks[1]
  if ils and ils.content then return table.concat(inl_runs(ils.content, sz, bold, ital)) end
  return run(s, bold, ital, sz)
end

-- inline content of a YAML value (MetaInlines is already a list of inlines)
local function ils_of(v)
  if v == nil or v == "" then return {} end
  if type(v) == "table" and v.t == "MetaInlines" then return v end
  local b = pandoc.read(str(v), "markdown").blocks[1]
  return (b and b.content) or {}
end

local function para(style, inner, ppr, runs)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (runs or "") .. "</w:p>"
end

local function spacer(twips)
  return '<w:spacing w:before="' .. twips .. '"/>'
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- counsel columns as a borderless three-column table (two columns and a 0.15 in gutter, as the typst grid): each
-- column wraps on its own lines. `first_before` is the space above the first line of the block (twips).
local function counsel_table(cols, first_before, keep)
  local widths = { 2862, 216, 2862 }
  local function cell(lines, w)
    local ps = {}
    if #lines == 0 then lines = { "" } end
    for i, l in ipairs(lines) do
      local ppr = (keep and "<w:keepNext/>" or "") .. ((i == 1 and first_before) and spacer(first_before) or "")
      local runs = table.concat(inl_runs(ils_of(l), 20))
      ps[#ps + 1] = para("CounselLine", nil, ppr, runs ~= "" and runs or nil)
    end
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. "</w:tc>"
  end
  local left = cols[1] or {}
  local right = cols[2] or {}
  local nil_border = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'
  return '<w:tbl><w:tblPr><w:tblW w:w="5940" w:type="dxa"/><w:tblInd w:w="108" w:type="dxa"/><w:tblBorders>'
    .. nil_border .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="2862"/><w:gridCol w:w="216"/><w:gridCol w:w="2862"/></w:tblGrid><w:tr>'
    .. cell(left, widths[1]) .. '<w:tc><w:tcPr><w:tcW w:w="216" w:type="dxa"/></w:tcPr>'
    .. para("CounselLine", nil, nil, nil) .. "</w:tc>" .. cell(right, widths[3])
    .. "</w:tr></w:tbl>"
end

-- a blank block of `twips` height (the typst v(1fr) gap on the cover)
local function gap(twips)
  return '<w:p><w:pPr><w:pStyle w:val="SectionEnd"/><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end


-- section end: the paragraph that carries the sectPr of the section it ends
local PG = '<w:pgSz w:w="8820" w:h="13320"/><w:pgMar w:top="1530" w:right="1440" w:bottom="1530" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
local function sect_pr(footer_rid, fmt, start)
  local pn = '<w:pgNumType w:fmt="' .. fmt .. '"' .. (start and (' w:start="' .. start .. '"') or "") .. "/>"
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>' .. PG .. pn .. "</w:sectPr>"
end
local function section_end(footer_rid, fmt, start)
  return raw('<w:p><w:pPr><w:pStyle w:val="SectionEnd"/>' .. sect_pr(footer_rid, fmt, start) .. "</w:pPr></w:p>")
end

local function write_env(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local h = assert(io.open(path, "w"))
  h:write(text)
  h:close()
end

-- ---- the document ----
local function sort_key(a)
  local s = a.sort or ((a.name or "") .. " " .. a.cite)
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

local function roman(n)
  local vals = { 1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1 }
  local syms = { "m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i" }
  local out = ""
  for i = 1, #vals do
    while n >= vals[i] do out = out .. syms[i]; n = n - vals[i] end
  end
  return out
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- typst's count-words, on the body's text (markdown structure is not a word)
local function count_words(blocks)
  local n = 0
  for _, b in ipairs(blocks) do
    for w in pandoc.utils.stringify(b):gmatch("%S+") do
      if w:match("[A-Za-z0-9]") then n = n + 1 end
    end
  end
  return n
end

-- typst's count-words on the markdown source of the body (the same rules: markup removed, links keep their text,
-- heading and list markers are not words, a token counts if it has a letter or a digit). The certificate uses it.
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return nil end
  local h = io.open(f, "r")
  if not h then return nil end
  local text = h:read("a")
  h:close()
  local lines, dashes, kind = {}, 0, "body"
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    else
      if line:match("^#%s") then
        local t = line:match("^#%s+(.-)%s*$"):lower()
        if t:match("^questions presented") then kind = "qp"
        elseif t:match("^parties to the proceeding") then kind = "parties"
        else kind = "body" end
      end
      if kind == "body" then lines[#lines + 1] = line end
    end
  end
  local n = 0
  for _, line in ipairs(lines) do
    local s = line
    s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
    s = s:gsub("^#+%s+", "")
    s = s:gsub("^>%s?", "")
    s = s:gsub("^%s*[-*+]%s+", "")
    s = s:gsub("^%s*%d+[.)]%s+", "")
    s = s:gsub("%*", "")
    for w in s:gmatch("%S+") do
      if w:match("[A-Za-z0-9]") then n = n + 1 end
    end
  end
  return n
end

function Pandoc(doc)
  local meta = doc.meta
  local CAP = meta.caption or {}
  local counsel = meta.counsel or {}
  local auth = {}
  for key, a in pairs(meta.authorities or {}) do
    auth[key] = { kind = str(a.kind), name = a.name and str(a.name) or nil, cite = str(a.cite),
      sort = a.sort and str(a.sort) or nil }
  end

  -- 1. split the sections (Questions Presented, Parties, body); index the headings of the front matter and the body.
  -- Links to authorities: the text stays, the entry goes to the table. Needles, in the order of the output (Questions
  -- Presented, Parties, the Table of Authorities heading, the body): every heading (its text and what follows it), and
  -- every citation in the body (kind N inside a footnote), so a heading is not found in the table of contents nor a
  -- citation in the table of authorities.
  local hits, cites = {}, {}
  local qp, parties, body = {}, {}, {}
  local needles = { [qp] = {}, [parties] = {}, [body] = {} }
  local current = body
  local heads = {}
  local nt = 0
  local pending -- the needle of the last heading, waiting for the text that follows it
  local function unlink(b)
    local list = needles[current]
    local function link(kind)
      return function(el)
        local key = el.target:match("^toa:(.+)$")
        if not key then return nil end
        if not auth[key] then error("scotus: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
        hits[key] = true
        if current == body then
          nt = nt + 1
          local id = "T:" .. nt
          local t = norm(str(el.content))
          list[#list + 1] = { id = id, kind = kind, needle = t, fallback = t }
          cites[key] = cites[key] or {}
          table.insert(cites[key], id)
        end
        return el.content
      end
    end
    return b:walk({
      traverse = "topdown",
      Note = function(n) return n:walk({ Link = link("N") }), false end,
      Link = link("B"),
    })
  end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then
      local t = str(b.content):lower()
      if t:match("^questions presented") then current = qp
      elseif t:match("^parties to the proceeding") then current = parties
      elseif current ~= body then current = body end
    end
    if pending then
      pending.needle = norm(pending.text .. " " .. str(b)):sub(1, NEEDLE_MAX)
      pending = nil
    end
    b = unlink(b)
    current[#current + 1] = b
    if b.t == "Header" and b.level <= 2 then
      local hd = { idx = #heads + 1, level = b.level, text = str(b.content), front = (current ~= body) }
      heads[#heads + 1] = hd
      local list = needles[current]
      local t = norm(hd.text)
      pending = { id = "H:" .. hd.idx, kind = "B", text = hd.text, needle = t, fallback = t }
      list[#list + 1] = pending
    end
  end
  if #body == 0 then error("scotus: the sample has no body section", 0) end
  local words = source_words() or count_words(body)
  if words > CFG.word_limit then
    error("scotus: body is " .. words .. " words; Rule 33.1(g)(i) allows " .. CFG.word_limit, 0)
  end

  -- 2. needles (fb render finds each in the LibreOffice PDF) and the numbering: lower-case roman from the first front
  -- page (after the cover), arabic from the start of the body
  local nl, all = {}, {}
  for _, s in ipairs({ qp, parties }) do
    for _, n in ipairs(needles[s]) do all[#all + 1] = n end
  end
  local toa = { id = "S:toa", kind = "B", needle = "tableofauthorities", fallback = "tableofauthorities" }
  local front_start = (all[1] or toa).id
  all[#all + 1] = toa
  local body_needles = needles[body]
  if not (body[1].t == "Header" and body[1].level <= 2) then
    local t = norm(str(body[1])):sub(1, 40)
    table.insert(body_needles, 1, { id = "S:body", kind = "B", needle = t, fallback = t })
  end
  local body_start = body_needles[1].id
  for _, n in ipairs(body_needles) do all[#all + 1] = n end
  for _, n in ipairs(all) do nl[#nl + 1] = n.id .. "\t" .. n.kind .. "\t" .. n.needle .. "\t" .. n.fallback end
  nl[#nl + 1] = "#section\t" .. front_start .. "\tlower-roman\t"
  nl[#nl + 1] = "#section\t" .. body_start .. "\tdecimal\t"
  write_env("FORMBOOK_NEEDLES", table.concat(nl, "\n") .. "\n")
  -- the certificate of compliance (Rule 33.1(h)): the last section, on its own page, no number
  write_env("FORMBOOK_FINAL", sect_pr("rIdFtrNone", "decimal", nil))

  -- 3. the page label of each heading and authority (the pass before; placeholders of the final width on the first)
  local function hlabel(i)
    local p = PAGES["H:" .. i]
    return p and p.label or "00"
  end
  local function alabel(key)
    if FIRST_PASS then return "00" end
    local ps = {}
    for _, id in ipairs(cites[key] or {}) do
      if PAGES[id] then ps[#ps + 1] = PAGES[id] end
    end
    table.sort(ps, function(x, y) return x.page < y.page end)
    local out, seen = {}, {}
    for _, p in ipairs(ps) do
      if not seen[p.label] then seen[p.label] = true; out[#out + 1] = p.label end
    end
    return table.concat(out, ", ")
  end

  local out = {}
  local function add(x) out[#out + 1] = x end

  -- ---- cover (Rule 34.1(a)-(g)): no footer ----
  local cov = {}
  local function cline(sz_bold_runs, before)
    cov[#cov + 1] = raw(para("CoverLine", nil, before and spacer(before) or nil, sz_bold_runs))
  end
  cline(md_runs("No. " .. str(meta.docket), 22), 0)
  cline(md_runs("IN THE", 22), 352)
  cline(md_runs("Supreme Court of the United States", 22, true), 110)
  for i, l in ipairs(CAP.petitioner or {}) do
    cline(table.concat(inl_runs(ils_of(l), 22)), i == 1 and 308 or 0)
  end
  cline(md_runs(str(meta["petitioner-designation"]), 22), 66)
  for i, l in ipairs(CAP.respondents or {}) do
    cline(table.concat(inl_runs(ils_of(l), 22)), i == 1 and 198 or 0)
  end
  cline(md_runs(str(meta["respondent-designation"]), 22), 66)
  cline(table.concat(inl_runs(ils_of(meta.proceeding), 22)), 264)
  cline(md_runs(str(meta.title), 26, true), 264)
  cov[#cov + 1] = raw(gap(CFG.counsel_gap))
  cov[#cov + 1] = raw(counsel_table(counsel.columns or {}, nil, false))
  for _, b in ipairs(cov) do add(b) end
  add(section_end("rIdFtrNone", "decimal", nil))

  -- ---- front pages (lowercase roman): Questions Presented, Parties (each on its own page, Rule 14.1(a)) ----
  for _, b in ipairs(qp) do add(b) end
  add(section_end("rIdFtrPage", "lowerRoman", 1))
  for _, b in ipairs(parties) do add(b) end
  add(section_end("rIdFtrPage", "lowerRoman", nil))

  -- ---- table of contents (Rule 34.2, depth 2, as typst's outline) and table of authorities (Rule 34.2) ----
  add(raw(para("FrontHeading", nil, nil, run("Table of Contents", true, false, 24))))
  for _, hd in ipairs(heads) do
    local style = hd.level == 1 and "TOCEntry1" or "TOCEntry2"
    add(raw(para(style, nil, nil, run(hd.text, false, false, 24) .. TAB .. run(hlabel(hd.idx), false, false, 24))))
  end
  add(raw(para("FrontHeading", nil, '<w:pageBreakBefore/>', run("Table of Authorities", true, false, 24))))
  for gi, g in ipairs(CFG.toa_groups) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and hits[key] then members[#members + 1] = { key, a } end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return sort_key(x[2]) < sort_key(y[2]) end)
      add(raw(para("TOAGroup", nil, nil, run(g[2], true, false, 24))))
      for _, m in ipairs(members) do
        local a = m[2]
        local name = ""
        if a.name then
          name = run(a.name, false, a.kind == "case", 24) .. run(", ", false, false, 24)
        end
        add(raw(para("TOAEntry", nil, nil, name .. run(a.cite, false, false, 24) .. TAB
          .. run(alabel(m[1]), false, false, 24))))
      end
    end
  end
  add(section_end("rIdFtrPage", "lowerRoman", nil))

  -- ---- body (arabic from 1) and the signature block (Rule 34.3) ----
  for _, b in ipairs(body) do add(b) end
  local sig = {}
  sig[#sig + 1] = raw(para("SigLine", nil, spacer(220), run("Respectfully submitted,", false, false, 24)))
  sig[#sig + 1] = raw(counsel_table(counsel.columns or {}, 180, true))
  sig[#sig + 1] = raw(para("SigLine", nil, spacer(180), table.concat(inl_runs(ils_of(counsel["attorneys-for"]), 24))
    .. BR .. run(str(counsel.date), false, false, 24)))
  for _, b in ipairs(sig) do add(b) end
  add(section_end("rIdFtrPage", "decimal", 1))

  -- ---- certificate of compliance (Rule 33.1(h)): on its own page, no number (its sectPr: FORMBOOK_FINAL) ----
  add(raw(para("CenterLine", nil, nil, run("CERTIFICATE OF COMPLIANCE", true, false, 24))))
  add(raw(para("CertBody", nil, '<w:spacing w:before="0" w:after="240" w:line="280" w:lineRule="exact"/>',
    run("I certify that this petition complies with the word limitation of Supreme Court Rule 33.1(g)(i), "
      .. group_digits(CFG.word_limit) .. " words, and contains ", false, false, 24)
    .. run(group_digits(words), true, false, 24)
    .. run(" words, counted as Rule 33.1(d) directs: the question presented, the list of parties and corporate "
      .. "disclosure statement, the table of contents, the table of cited authorities, the counsel listing and any "
      .. "appendix are excluded.", false, false, 24))))
  add(raw(para("CertSig", nil, '<w:spacing w:before="308" w:after="0" w:line="280" w:lineRule="exact"/>',
    run(str(meta["certificate-signer"]), false, false, 24) .. BR
    .. run("Counsel of Record", true, false, 24) .. BR
    .. run(str(counsel.date), false, false, 24))))

  doc.blocks = out
  doc.meta.title = nil   -- the cover is ours; pandoc would print the title above it
  return doc
end
