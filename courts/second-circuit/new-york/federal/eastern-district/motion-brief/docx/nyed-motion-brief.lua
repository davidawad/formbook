-- nyed memorandum of law, DOCX engine (docs/DOCX.md): the markdown contract -> Word on reference.docx.
-- Mirrors typst/nyed-motion-brief.typ. Built here: the cover (court, caption, title, counsel at the foot),
-- the table of contents and table of authorities (from the headings and the `toa:` links; page numbers come
-- from docx/render.sh, which reads them from a first-pass PDF and passes them in NYED_PAGES), the signature
-- block, the certificate of compliance (word count from NYED_WORDS) and the certificate of service.
-- Sections: cover (no number), front matter (roman), body (arabic from 1). Headings with a label ("I.", "A.",
-- "1.", "a.") hang the label with a tab (heading styles Heading2 to Heading4).
-- No case-specific text in this file: everything comes from the frontmatter of the sample.

local COVER_FILL = 5600 -- twips of space above the counsel block on the cover (tuned to the typst page)
local SECT_PG = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function rpr(f)
  return (f.b and "<w:b/><w:bCs/>" or "") .. (f.i and "<w:i/><w:iCs/>" or "")
end

local function run(text, f)
  f = f or {}
  if f.up then text = string.upper(text) end
  local p = rpr(f)
  local rp = p ~= "" and ("<w:rPr>" .. p .. "</w:rPr>") or ""
  return "<w:r>" .. rp .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- inlines -> runs (bold, italic, curly quotes, line breaks)
local runs
runs = function(inls, f)
  f = f or {}
  local out = {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = run(el.text, f)
    elseif t == "Space" or t == "SoftBreak" then
      out[#out + 1] = run(" ", f)
    elseif t == "LineBreak" then
      out[#out + 1] = "<w:r><w:br/></w:r>"
    elseif t == "Emph" then
      out[#out + 1] = runs(el.content, { b = f.b, i = true, up = f.up })
    elseif t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = f.i, up = f.up })
    elseif t == "Quoted" then
      local o, c = "\u{201C}", "\u{201D}"
      if el.quotetype == "SingleQuote" then o, c = "\u{2018}", "\u{2019}" end
      out[#out + 1] = run(o, f) .. runs(el.content, f) .. run(c, f)
    elseif el.content then
      out[#out + 1] = runs(el.content, f)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), f)
    end
  end
  return table.concat(out)
end

-- pandoc 3 exposes metadata as plain Lua values: a string, a list (a table of values with no .t), inlines
-- (a table whose items have .t, e.g. Str) or blocks (items with .t Para or Plain).
local function is_list(v)
  return type(v) == "table" and v.t == nil and #v > 0 and type(v[1]) == "table" and v[1].t == nil
end

local function mx(v, f)
  if v == nil then return "" end
  if type(v) == "string" then return run(v, f) end
  if v.t == "MetaInlines" then return runs(v, f) end
  if v.t == "MetaString" then return run(v.text or pandoc.utils.stringify(v), f) end
  if v[1] and (v[1].t == "Para" or v[1].t == "Plain") then
    local o = {}
    for _, b in ipairs(v) do
      if b.content then o[#o + 1] = runs(b.content, f) end
    end
    return table.concat(o)
  end
  return runs(v, f)
end

local function list(v)
  if v == nil then return {} end
  if is_list(v) then return v end
  return { v }
end

local function need(meta, key)
  local v = meta[key]
  if v == nil then error("nyed-motion-brief: missing required metadata field `" .. key .. "`", 0) end
  return v
end

-- paragraph XML: style, run XML, and the pPr children (already in schema order after pStyle)
local function p(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (inner or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function gap(twips)
  return p("Single", "", '<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/>')
end

local function section_break(footer_rid, pgnum)
  return '<w:p><w:pPr><w:sectPr><w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>'
    .. SECT_PG .. (pgnum or "") .. "</w:sectPr></w:pPr></w:p>"
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function caption_table(left_xml, right_xml)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4896"/><w:gridCol w:w="4464"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4896" w:type="dxa"/><w:tcBorders>'
    .. '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. "</w:tcBorders></w:tcPr>" .. left_xml .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/><w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. right_xml .. "</w:tc></w:tr></w:tbl>"
end

local function caption_xml(meta)
  local sides = list(need(meta, "caption"))
  local left = {}
  for i, side in ipairs(sides) do
    if i > 1 then
      left[#left + 1] = p("Single", run("-against-"), '<w:spacing w:before="240" w:after="240"/><w:ind w:left="1728"/>')
    end
    local names = list(side.names)
    for j, n in ipairs(names) do
      local ppr = nil
      if i == 1 and j == 1 then ppr = '<w:spacing w:before="168"/>' end
      left[#left + 1] = p("Single", mx(n), ppr)
    end
    local last = (i == #sides)
    left[#left + 1] = p("Single", mx(side.designation),
      (last and '<w:spacing w:after="180"/>' or "") .. '<w:ind w:left="2736"/>')
  end
  local right = { p("Single", run("Case No. ") .. mx(need(meta, "case_number"))) }
  if meta.legend then
    right[#right + 1] = p("Single", mx(meta.legend, { b = true, up = true }), '<w:spacing w:before="240"/>')
  end
  return caption_table(table.concat(left), table.concat(right))
end

-- the cover: court (centered, bold capitals), the caption, the title, and the counsel block at the foot
local function cover(meta)
  local out = {}
  for _, l in ipairs(list(need(meta, "court"))) do
    out[#out + 1] = p("Centered", mx(l, { b = true, up = true }))
  end
  out[#out + 1] = gap(480)
  out[#out + 1] = raw(caption_xml(meta))
  out[#out + 1] = gap(960)
  out[#out + 1] = p("Centered", mx(need(meta, "brief_title"), { b = true, up = true }))
  out[#out + 1] = gap(COVER_FILL)
  for _, l in ipairs(list(meta.counsel)) do
    out[#out + 1] = p("Single", mx(l))
  end
  return out
end

-- the signature block: "Dated:" at left, the signer at right (Fed. R. Civ. P. 11(a))
local function signature_xml(meta)
  local sig = need(meta, "signature")
  local right = { p("Single", run("Respectfully submitted,")) }
  right[#right + 1] = p("Single", run("By: /s/ ") .. mx(sig.signer), '<w:spacing w:before="480"/>')
  for _, l in ipairs(list(sig.lines)) do
    right[#right + 1] = p("Single", mx(l))
  end
  local left = p("Single", run("Dated: ") .. mx(need(meta, "date")))
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="4608"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/></w:tcPr>' .. left .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/></w:tcPr>' .. table.concat(right) .. "</w:tc>"
    .. "</w:tr></w:tbl>"
end

-- inline words of a plain string (for cites and case names)
local function words(s)
  local out = {}
  local first = true
  for w in s:gmatch("%S+") do
    if not first then out[#out + 1] = pandoc.Space() end
    out[#out + 1] = pandoc.Str(w)
    first = false
  end
  return out
end

-- a heading whose text starts with a label ("I.", "A.", "1.", "a.") gets the label, a tab, the text
local function split_label(inl)
  if inl[1] and inl[1].t == "Str" and inl[2] and inl[2].t == "Space" then
    local s = inl[1].text
    if s:match("^%u+%.$") or s:match("^%d+%.$") or s:match("^%l+%.$") then
      local out = { pandoc.Str(s), TAB }
      for i = 3, #inl do out[#out + 1] = inl[i] end
      return out
    end
  end
  return inl
end

local function page_of(pages, ord_or_key, kind)
  local v = pages[kind][ord_or_key]
  if v == nil then
    if next(pages.H) == nil and next(pages.A) == nil then return "00" end
    error("nyed-motion-brief: no page for " .. kind .. " `" .. tostring(ord_or_key) .. "` in NYED_PAGES", 0)
  end
  return v
end

local function read_pages()
  local pages = { H = {}, A = {} }
  local path = os.getenv("NYED_PAGES")
  if not path or path == "" then return pages end
  local h = io.open(path, "r")
  if not h then error("nyed-motion-brief: cannot read NYED_PAGES " .. path, 0) end
  for line in h:lines() do
    local kind, key, val = line:match("^(%a)\t([^\t]*)\t(.*)$")
    if kind == "H" then pages.H[tonumber(key)] = val
    elseif kind == "A" then pages.A[key] = val end
  end
  h:close()
  return pages
end

-- the TOA group titles, in the order the template lists them (kind -> title)
local TOA_GROUPS = {
  { "case", "Cases" },
  { "statute", "Statutes" },
  { "rule", "Federal Rules of Civil Procedure" },
  { "other", "Other Authorities" },
}

local function count_pages(s)
  local n = 1
  for _ in s:gmatch(", ") do n = n + 1 end
  return n
end

local function front_matter(meta, heads, used, pages)
  local out = {}
  -- table of contents: one entry per body heading, level 1 to 4, with its page
  out[#out + 1] = p("Heading1", run("TABLE OF CONTENTS"))
  out[#out + 1] = p("Single", run("Page", { b = true }), '<w:jc w:val="right"/>')
  for _, h in ipairs(heads) do
    local inl = {}
    for _, x in ipairs(h.inl) do inl[#inl + 1] = x end
    -- the page number follows a right tab with dot leader (style TOCLevel<n>)
    inl[#inl + 1] = TAB
    inl[#inl + 1] = pandoc.Str(page_of(pages, h.ord, "H"))
    out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "TOCLevel" .. tostring(h.level) }))
  end

  -- table of authorities: the cited authorities, grouped, with their pages (passim from 7 pages)
  out[#out + 1] = p("Heading1", run("TABLE OF AUTHORITIES"), "<w:pageBreakBefore/>")
  out[#out + 1] = p("Single", run("Page(s)", { b = true }), '<w:jc w:val="right"/>')
  local authorities = meta.authorities or {}
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and pandoc.utils.stringify(a.kind) == g[1] then
        members[#members + 1] = { key = key, a = a }
      end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local kx = string.lower(pandoc.utils.stringify(x.a.name or x.a.cite))
        local ky = string.lower(pandoc.utils.stringify(y.a.name or y.a.cite))
        return kx < ky
      end)
      out[#out + 1] = pandoc.Div({ pandoc.Para({ pandoc.Str(g[2]) }) },
        pandoc.Attr("", {}, { ["custom-style"] = "TOAGroup" }))
      for _, m in ipairs(members) do
        local inl = {}
        if m.a.name then
          local name = pandoc.utils.stringify(m.a.name)
          if g[1] == "case" then
            inl[#inl + 1] = pandoc.Emph(words(name))
          else
            for _, x in ipairs(words(name)) do inl[#inl + 1] = x end
          end
          inl[#inl + 1] = pandoc.Str(",")
          inl[#inl + 1] = pandoc.Space()
        end
        for _, x in ipairs(words(pandoc.utils.stringify(m.a.cite))) do inl[#inl + 1] = x end
        inl[#inl + 1] = TAB
        local pg = page_of(pages, m.key, "A")
        if count_pages(pg) >= 7 then
          inl[#inl + 1] = pandoc.Emph({ pandoc.Str("passim") })
        else
          inl[#inl + 1] = pandoc.Str(pg)
        end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "TOAEntry" }))
      end
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local pages = read_pages()

  -- 1. links to authorities: the link text stays; the key is recorded
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not (meta.authorities and meta.authorities[key]) then
        error("nyed-motion-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0)
      end
      used[key] = true
      return el.content
    end,
  })

  -- 2. headings of the body, in order, with their labels split off
  local heads = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      heads[#heads + 1] = { level = b.level, inl = split_label(b.content), ord = #heads + 1 }
    end
  end

  local out = {}
  for _, x in ipairs(cover(meta)) do out[#out + 1] = x end
  out[#out + 1] = raw(section_break("rId101"))
  for _, x in ipairs(front_matter(meta, heads, used, pages)) do out[#out + 1] = x end
  out[#out + 1] = raw(section_break("rId100", '<w:pgNumType w:fmt="lowerRoman" w:start="1"/>'))

  -- 3. the body: its headings, its paragraphs (footnotes stay native), the signature, the word certificate
  local h = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      h = h + 1
      out[#out + 1] = pandoc.Header(b.level, heads[h].inl)
    else
      out[#out + 1] = b
    end
  end
  out[#out + 1] = gap(480)
  out[#out + 1] = signature_xml(meta)

  local words_n = os.getenv("NYED_WORDS") or "0"
  out[#out + 1] = p("Heading1", run("CERTIFICATE OF COMPLIANCE"), '<w:spacing w:before="480" w:after="240"/>')
  out[#out + 1] = p("BodyText", run("I certify that this memorandum of law complies with the word-count limit of Local Civil Rule 7.1(c). Excluding the caption, table of contents, table of authorities, signature block, and certificates, it contains " .. words_n .. " words, as counted by the template. The count must be confirmed against the word-processing program used to prepare the filed document."), '<w:ind w:firstLine="0"/>')

  -- 4. the certificate of service, on its own page (the frontmatter service text)
  if meta.service then
    out[#out + 1] = p("Heading1", run("CERTIFICATE OF SERVICE"), "<w:pageBreakBefore/>")
    out[#out + 1] = p("BodyText", mx(meta.service))
    out[#out + 1] = gap(480)
    out[#out + 1] = signature_xml(meta)
  end

  for i, x in ipairs(out) do
    if type(x) == "string" then out[i] = raw(x) end
  end
  return pandoc.Pandoc(out)
end
