-- U.S. District Court, District of Montana: brief in support of a motion, DOCX engine (docs/DOCX.md).
-- Follows typst/mtd-motion-brief.typ: cover (counsel, court title, caption), table of contents and table of
-- authorities (roman pages), the memorandum (arabic pages from 1) with headings numbered I., A., 1. by the
-- filter, the signature block, the certificate of compliance (word count) and the certificate of service.
-- The TOC and TOA page numbers come from a first pass: docx/render.sh renders the document, finds the page
-- of every heading and every authority in the PDF, and runs this filter again with MTD_PAGES set (see
-- docx/render.sh and docx/pages.awk). A heading or authority that cannot be found fails the build.
-- Environment: MTD_KEYS (write the search keys here), MTD_PAGES (read the page numbers from here).

local TEXTW = 9360 -- 6.5 in in twips
local TAB = '<w:r><w:tab/></w:r>'
local BR = '<w:r><w:br/></w:r>'
local PASSIM_AT = 7                 -- an authority on this many pages or more prints "passim" (typst)
local WORD_LIMIT = 6500             -- L.R. 7.1(d)(2)(A)
local FONT_NAME = "EB Garamond"     -- certificate of compliance: the typeface named there (typst font-family)

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function with(f, k)
  local g = {}
  for kk, vv in pairs(f or {}) do g[kk] = vv end
  g[k] = true
  return g
end

local function rpr(f)
  local x = ""
  if f and f.b then x = x .. "<w:b/><w:bCs/>" end
  if f and f.i then x = x .. "<w:i/><w:iCs/>" end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

local function run(text, f)
  return "<w:r>" .. rpr(f) .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function inlines(v)
  if v == nil then return {} end
  local ty = pandoc.utils.type(v)
  if ty == "Inlines" then return v end
  if ty == "Blocks" then return pandoc.utils.blocks_to_inlines(v) end
  if ty == "string" then
    local b = pandoc.read(v, "markdown+smart").blocks[1]
    if b and (b.t == "Para" or b.t == "Plain") then return b.content end
    return { pandoc.Str(v) }
  end
  if ty == "boolean" then return {} end
  return { pandoc.Str(pandoc.utils.stringify(v)) }
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function runs(list, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(list) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then
      out[#out + 1] = BR
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, with(f, "i"))
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, with(f, "b"))
    elseif t == "Quoted" then
      local q = (el.quotetype == "DoubleQuote") and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], f)
      out[#out + 1] = runs(el.content, f)
      out[#out + 1] = run(q[2], f)
    elseif t == "Link" or t == "Span" then
      out[#out + 1] = runs(el.content, f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

local function p(style, body, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. body .. "</w:p>"
end

-- an empty paragraph whose exact height is `twips` (640 = one double-spaced line)
local function spacer(twips)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function cell(w, content, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>" .. content .. "</w:tc>"
end

local function table_xml(grid, rows, cant_split)
  local g = {}
  for _, w in ipairs(grid) do g[#g + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local trs = {}
  for _, r in ipairs(rows) do
    trs[#trs + 1] = "<w:tr>" .. (cant_split and "<w:trPr><w:cantSplit/></w:trPr>" or "") .. r .. "</w:tr>"
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(g) .. "</w:tblGrid>"
    .. table.concat(trs) .. "</w:tbl>"
end

-- ---------------------------------------------------------------- numbers, keys, page numbers
local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, v in ipairs(vals) do
    while n >= v[1] do out = out .. v[2]; n = n - v[1] end
  end
  return out
end

local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

-- labels as typst numbers the headings: level 2 "I.", 3 "A.", 4 "1.", 5 "a."; level 1 is unnumbered
local CNT = { 0, 0, 0, 0, 0 }
local function label_for(level)
  CNT[level] = CNT[level] + 1
  for l = level + 1, 5 do CNT[l] = 0 end
  if level == 1 then return nil end
  if level == 2 then return roman(CNT[2]) .. "." end
  if level == 3 then return string.char(64 + CNT[3]) .. "." end
  if level == 4 then return tostring(CNT[4]) .. "." end
  if level == 5 then return string.char(96 + CNT[5]) .. "." end
  return nil
end

-- the pages from the first pass (MTD_PAGES): "H<TAB>idx<TAB>label" and "A<TAB>key<TAB>label"
local function read_pages()
  local path = os.getenv("MTD_PAGES")
  local H, A = {}, {}
  if path == nil or path == "" then return nil, nil end
  local h = io.open(path, "r")
  if not h then error("mtd-motion-brief: MTD_PAGES file not found: " .. path, 0) end
  for line in h:lines() do
    local kind, key, label = line:match("^(%a)\t([^\t]+)\t(.+)$")
    if kind == "H" then H[tonumber(key)] = label
    elseif kind == "A" then
      A[key] = A[key] or {}
      table.insert(A[key], label)
    end
  end
  h:close()
  return H, A
end

-- the body of the sample (the text after the frontmatter), for the word count
local function source_body()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local h = f and io.open(f, "r")
  if not h then error("mtd-motion-brief: cannot read the sample for the word count", 0) end
  local text = h:read("a")
  h:close()
  if text:sub(1, 4) ~= "---\n" then return text end
  local _, e = text:find("\n%-%-%-[ \t]*\r?\n")
  if not e then return text end
  return text:sub(e + 1)
end

-- typst's count-words: whitespace-separated tokens with a letter or digit; footnote labels and (toa:KEY) excluded
local function count_words(md)
  local s = md:gsub("%[%^[^%]]*%]", " ")
  s = s:gsub("%(toa:[^%)]*%)", " ")
  local n = 0
  for tok in s:gmatch("%S+") do
    if tok:find("[A-Za-z0-9]") then n = n + 1 end
  end
  return n
end

local function commas(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------- cover (typst: cover)
local function counsel_block(meta)
  local left, right = {}, {}
  for i, g in ipairs(meta.counsel) do
    local dst = (i == 1) and left or right
    if i > 2 then dst[#dst + 1] = spacer(610) end
    for _, line in ipairs(g) do dst[#dst + 1] = p("Single", runs(inlines(line))) end
  end
  return table_xml({ 4464, 432, 4464 }, {
    cell(4464, table.concat(left)) .. cell(432, p("Single", "")) .. cell(4464, table.concat(right)),
  }, true)
end

local function caption_block(meta)
  local sides = meta.caption
  local left = {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do left[#left + 1] = p("Single", runs(inlines(n))) end
    left[#left + 1] = spacer(610)
    left[#left + 1] = p("Single", runs(inlines(side.designation)), '<w:ind w:left="2016" w:firstLine="0"/>')
    if i < #sides then
      left[#left + 1] = spacer(610)
      left[#left + 1] = p("Single", run("v."))
      left[#left + 1] = spacer(610)
    end
  end
  local right = {
    p("Single", run("Case No. " .. plain(meta.case_number))),
    spacer(1250),
    p("Single", run(plain(meta.brief_title):upper(), { b = true })),
  }
  local lborder = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local lmar = '<w:tcMar><w:bottom w:w="280" w:type="dxa"/><w:right w:w="280" w:type="dxa"/></w:tcMar>'
  local rmar = '<w:tcMar><w:top w:w="84" w:type="dxa"/><w:left w:w="336" w:type="dxa"/></w:tcMar>'
  return table_xml({ 5290, 4070 }, {
    cell(5290, table.concat(left), lborder .. lmar) .. cell(4070, table.concat(right), rmar),
  }, true)
end

local function cover(meta)
  local out = {}
  out[#out + 1] = raw(counsel_block(meta))
  out[#out + 1] = raw(spacer(610))
  out[#out + 1] = raw(p("Single", runs(inlines(meta.counsel_role), { i = true })))
  out[#out + 1] = raw(spacer(610))
  out[#out + 1] = raw(p("Centered", run("IN THE UNITED STATES DISTRICT COURT", { b = true })))
  out[#out + 1] = raw(p("Centered", run("FOR THE DISTRICT OF MONTANA", { b = true })))
  out[#out + 1] = raw(p("Centered", run(plain(meta.division):upper(), { b = true })))
  out[#out + 1] = raw(spacer(610))
  out[#out + 1] = raw(caption_block(meta))
  return out
end

-- ---------------------------------------------------------------- signature and certificates
local function sig_table(left_xml, right_xml)
  return table_xml({ 4896, 4464 }, { cell(4896, left_xml) .. cell(4464, right_xml) }, true)
end

local function signature(meta)
  local sig = meta.signature
  local right = {}
  for _, l in ipairs(sig.preamble or {}) do right[#right + 1] = p("Single", runs(inlines(l))) end
  right[#right + 1] = spacer(640)
  right[#right + 1] = p("Single", run("/s/ " .. plain(sig.signer)))
  right[#right + 1] = p("Single", runs(inlines(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p("Single", runs(inlines(l))) end
  return {
    raw(spacer(640)),
    raw(sig_table(p("Single", run("DATED: " .. plain(meta.date))), table.concat(right))),
  }
end

-- headings that are not in the body (certificates, table titles) are written here and registered
local HEADS = {}
local TOA_REFS = {}
local TOA_USED = {}

local function register_heading(level, text_inlines, label)
  local idx = #HEADS + 1
  HEADS[idx] = { idx = idx, level = level, label = label, inl = text_inlines, norm = norm(pandoc.utils.stringify(text_inlines)) }
  return idx
end

local function heading_raw(text, page_break, register)
  if register then register_heading(1, { pandoc.Str(text) }, nil) end
  return raw('<w:p><w:pPr><w:pStyle w:val="Heading1"/>' .. (page_break and "<w:pageBreakBefore/>" or "")
    .. '</w:pPr><w:r><w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>"), idx
end

local function certificates(meta, words)
  local out = {}
  local h = heading_raw("Certificate of Compliance", true, true)
  out[#out + 1] = h
  local text = "Pursuant to Local Rule 7.1(d)(2)(E), I certify that this brief is printed with a proportionately spaced "
    .. FONT_NAME .. " typeface of 14 points; is double-spaced except for footnotes and for quoted and indented material; "
    .. "and the word count is " .. commas(words) .. " words, excluding caption, certificate of compliance, table of "
    .. "contents and authorities, exhibit index, and certificate of service."
  out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="BodyText"/><w:keepLines/><w:ind w:firstLine="0"/></w:pPr>' .. run(text) .. "</w:p>")
  local right = { spacer(640), p("Single", run("/s/ " .. plain(meta.signature.signer))), p("Single", runs(inlines(meta.signature.signer))) }
  out[#out + 1] = raw(sig_table(p("Single", ""), table.concat(right)))
  if meta.certificate_service ~= false then
    out[#out + 1] = raw(spacer(640))
    local h2 = heading_raw("Certificate of Service", false, true)
    out[#out + 1] = h2
    out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="BodyText"/><w:keepLines/><w:ind w:firstLine="0"/></w:pPr>' .. run(
      "I hereby certify that on this date, an accurate copy of the foregoing document was served electronically through the Court’s CM/ECF system on registered counsel.")
      .. "</w:p>")
    out[#out + 1] = raw(spacer(640))
    local right2 = { p("Single", run("/s/ " .. plain(meta.signature.signer))), p("Single", runs(inlines(meta.signature.signer))) }
    out[#out + 1] = raw(sig_table(p("Single", run("Dated: " .. plain(meta.date))), table.concat(right2)))
  end
  return out
end

-- ---------------------------------------------------------------- body
local function letter(i) return string.char(64 + i) end

local function body_blocks(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      local label = label_for(b.level)
      local idx = register_heading(b.level, b.content, label)
      local content = {}
      if label then
        content[#content + 1] = pandoc.Str(label)
        content[#content + 1] = pandoc.RawInline("openxml", TAB)
      end
      for _, el in ipairs(b.content) do content[#content + 1] = el end
      out[#out + 1] = pandoc.Header(b.level, content)
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local blocks2 = item
        local first = blocks2[1]
        if first and first.t == "Para" then
          local inl = { pandoc.Str(letter(i) .. "."), pandoc.RawInline("openxml", TAB) }
          for _, el in ipairs(first.content) do inl[#inl + 1] = el end
          blocks2[1] = pandoc.Para(inl)
        end
        out[#out + 1] = pandoc.Div(blocks2, pandoc.Attr("", {}, { ["custom-style"] = "ListLetter" }))
      end
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        local first = item[1]
        if first and first.t == "Para" then
          local inl = { pandoc.Str("\u{2022}"), pandoc.RawInline("openxml", TAB) }
          for _, el in ipairs(first.content) do inl[#inl + 1] = el end
          item[1] = pandoc.Para(inl)
        end
        out[#out + 1] = pandoc.Div(item, pandoc.Attr("", {}, { ["custom-style"] = "ListLetter" }))
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

-- ---------------------------------------------------------------- table of contents and authorities
local function page_or(pages_for_idx)
  return pages_for_idx or "00"
end

local function toc_blocks(H)
  local out = {}
  out[#out + 1] = heading_raw("Table of Contents", true, false)
  out[#out + 1] = raw(p("PageHead", run("Page")))
  for _, h in ipairs(HEADS) do
    if h.level <= 4 then
      local inl = {}
      if h.label then
        inl[#inl + 1] = pandoc.Str(h.label)
        inl[#inl + 1] = pandoc.RawInline("openxml", TAB)
      end
      for _, el in ipairs(h.inl) do inl[#inl + 1] = el end
      inl[#inl + 1] = pandoc.RawInline("openxml", TAB)
      inl[#inl + 1] = pandoc.Str(page_or(H and H[h.idx]))
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "TOCLine" .. h.level }))
    end
  end
  return out
end

local TOA_GROUPS = {
  { "case", "Cases" }, { "constitution", "Constitutional Provisions" }, { "statute", "Statutes" },
  { "rule", "Rules" }, { "regulation", "Regulations" }, { "other", "Other Authorities" },
}

local function toa_blocks(meta, A)
  local out = {}
  local h = heading_raw("Table of Authorities", true, false)
  out[#out + 1] = h
  out[#out + 1] = raw(p("PageHead", run("Page(s)")))
  local auth = meta.authorities or {}
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if TOA_USED[key] and plain(a.kind) == g[1] then members[#members + 1] = { key = key, a = a } end
    end
    table.sort(members, function(x, y)
      local kx = plain(x.a.name ~= nil and x.a.name or x.a.cite):lower()
      local ky = plain(y.a.name ~= nil and y.a.name or y.a.cite):lower()
      return kx < ky
    end)
    if #members > 0 then
      out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Str(g[2]) }) }, pandoc.Attr("", {}, { ["custom-style"] = "TOAGroup" }))
      for _, m in ipairs(members) do
        local labels = (A and A[m.key]) or { "00" }
        local page_text
        if #labels >= PASSIM_AT then page_text = "passim" else page_text = table.concat(labels, ", ") end
        local inl = {}
        if m.a.name ~= nil then
          local name = inlines(m.a.name)
          if plain(m.a.kind) == "case" then inl[#inl + 1] = pandoc.Emph(name)
          else for _, el in ipairs(name) do inl[#inl + 1] = el end end
          inl[#inl + 1] = pandoc.Str(", ")
        end
        for _, el in ipairs(inlines(m.a.cite)) do inl[#inl + 1] = el end
        inl[#inl + 1] = pandoc.RawInline("openxml", TAB)
        inl[#inl + 1] = pandoc.Str(page_text)
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "TOALine" }))
      end
    end
  end
  return out
end

local function section_break(lower_roman)
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:sectPr>'
    .. '<w:footerReference w:type="default" r:id="rIdMtdFooter1"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="' .. (lower_roman and "lowerRoman" or "decimal") .. '" w:start="1"/>'
    .. '<w:cols w:space="720"/></w:sectPr></w:pPr></w:p>')
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "counsel", "counsel_role", "caption", "brief_title", "division", "case_number", "signature", "date" }) do
    if meta[k] == nil then error("mtd-motion-brief: missing required metadata field `" .. k .. "`", 0) end
  end
  local words = meta.word_count ~= nil and tonumber(plain(meta.word_count)) or count_words(source_body())
  assert(words <= WORD_LIMIT, "mtd-motion-brief: L.R. 7.1(d)(2)(A): " .. words .. " words exceeds the " .. WORD_LIMIT .. "-word limit")

  -- authority links: the text stays, the key is recorded (in document order)
  local auth = meta.authorities or {}
  local refs = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if auth[key] == nil then error("mtd-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      TOA_USED[key] = true
      refs[#refs + 1] = { key = key, norm = norm(pandoc.utils.stringify(el.content)) }
      return el.content
    end,
  })

  -- the memorandum body, with the first-pass page numbers (if any)
  local H, A = read_pages()
  local body = body_blocks(doc.blocks)

  local out = {}
  for _, b in ipairs(cover(meta)) do out[#out + 1] = b end
  -- table of contents and table of authorities: pages ii and onward (the cover is i)
  local certs = certificates(meta, words)
  local tocs = toc_blocks(H)
  for _, b in ipairs(tocs) do out[#out + 1] = b end
  for _, b in ipairs(toa_blocks(meta, A)) do out[#out + 1] = b end
  out[#out + 1] = section_break(true)
  -- the memorandum, arabic from 1 (the last section sectPr is the reference one)
  for _, b in ipairs(body) do out[#out + 1] = b end
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  for _, b in ipairs(certs) do out[#out + 1] = b end
  doc.blocks = out

  -- the keys for the first pass: headings (idx, level, text) and authority links (key, text)
  local kf = os.getenv("MTD_KEYS")
  if kf and kf ~= "" then
    local h = assert(io.open(kf, "w"))
    for _, hd in ipairs(HEADS) do h:write("H\t", hd.idx, "\t", hd.level, "\t", hd.norm, "\n") end
    for _, r in ipairs(refs) do h:write("A\t", r.key, "\t", r.norm, "\n") end
    h:close()
  end

  for _, k in ipairs({ "title", "subtitle", "author", "date", "abstract" }) do doc.meta[k] = nil end
  return doc
end
