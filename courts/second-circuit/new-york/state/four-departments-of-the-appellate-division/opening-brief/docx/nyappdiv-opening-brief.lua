-- New York Appellate Division, Fourth Department: opening brief (appellant), DOCX engine (docs/DOCX.md).
-- The markdown contract (../README.md) becomes a Word document on reference.docx: the cover, the table of
-- contents, the table of authorities, the signature block and the printing specifications statement are
-- built here from the YAML metadata; the body keeps its markdown structure. No case-specific text lives here.
-- Known limits (BLOCKED, see the README "Engines" section): the contents are a TOC field whose cached entries
-- have no page numbers until a field update; the authorities list has no page references (a TOA would need
-- the same update, and LibreOffice does not honor TA/TOA fields); the word count is measured from the markdown
-- source, not by Word, and the word limit is enforced here as in the typst template.

local CFG = {
  word_limit = 14000, -- 22 NYCRR 1250.8(f)(2): appellant's computer-generated brief
  court_lines = { "SUPREME COURT OF THE STATE OF NEW YORK", "APPELLATE DIVISION", "FOURTH JUDICIAL DEPARTMENT" },
}

local TOA_GROUPS = {
  { "case", "Cases" }, { "statute", "Statutes" }, { "regulation", "Regulations" },
  { "rule", "Rules" }, { "constitution", "Constitutional Provisions" }, { "other", "Other Authorities" },
}

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function meta_blocks(v)
  if v.t == "MetaInlines" then return { pandoc.Plain(v) } end
  local out = {}
  for _, b in ipairs(v) do out[#out + 1] = b end
  return out
end

local function styled(style, inl)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function raw(x) return pandoc.RawBlock("openxml", x) end

local function page_break()
  return raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- A section break: the paragraph ends the section it sits in. Only the body section (the reference's
-- sectPr, which carries the footer) names a footer; earlier sections name none (the cover has no
-- page number) or the same footer part through the relationship that pandoc assigns (see the probe note).
local function section_break(fmt, footer_rid, restart)
  local ref = footer_rid and ('<w:footerReference w:type="default" r:id="' .. footer_rid .. '"/>') or ""
  return raw('<w:p><w:pPr><w:spacing w:before="0" w:after="0"/><w:sectPr>' .. ref
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="' .. fmt .. '"' .. (restart and ' w:start="1"' or "") .. '/></w:sectPr></w:pPr></w:p>')
end

local function toc_entries(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then out[#out + 1] = plain(b.content) end
  end
  return out
end

-- The body's words, counted the way the typst template counts them (markdown after the frontmatter,
-- headings included, markup removed). The printing statement and the word limit use this count.
local function source_words()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return 0 end
  local h = io.open(f, "r")
  if not h then return 0 end
  local text = h:read("a")
  h:close()
  local n, dashes = 0, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    elseif not line:match("^<!%-%-") then
      local s = line
      s = s:gsub("<!%-%-.-%-%->", " ")
      s = s:gsub("^%[%^[^%]]+%]:", " ")
      s = s:gsub("%[%^[^%]]*%]", "")
      s = s:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
      s = s:gsub("^#+%s+", "")
      s = s:gsub("^>%s?", "")
      s = s:gsub("^%s*[-*+]%s+", "")
      s = s:gsub("^%s*%d+[.)]%s+", "")
      s = s:gsub("\\(.)", "%1")
      s = s:gsub("%*", "")
      for _ in s:gmatch("%S+") do n = n + 1 end
    end
  end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

function Pandoc(doc)
  local meta = doc.meta
  doc.meta = pandoc.Meta({}) -- the cover is built from these values; pandoc must not add a title block
  local words = source_words()
  if words > CFG.word_limit then
    error("nyappdiv-opening-brief: the brief has " .. words .. " words; 22 NYCRR 1250.8(f)(2) limits it to " .. CFG.word_limit, 0)
  end

  -- footnotes are refused, as in the typst template (22 NYCRR Part 1000; see README)
  doc:walk({ Note = function(_) error("nyappdiv-opening-brief: footnotes are not allowed (22 NYCRR Part 1000; see README)", 0) end })

  local auth = {}
  if meta.authorities then
    for key, a in pairs(meta.authorities) do
      auth[key] = { kind = plain(a.kind), name = a.name, cite = a.cite, sort = a.sort }
    end
  end
  local used = {}
  doc = doc:walk({
    Link = function(el)
      local key = el.target:match("^toa:(.+)$")
      if not key then return nil end
      if not auth[key] then error("nyappdiv-opening-brief: link `toa:" .. key .. "` has no entry under `authorities:`", 0) end
      used[key] = true
      return el.content
    end,
  })

  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- cover
  add(styled("Right", { pandoc.Str(plain(meta.docket)) }))
  for _, l in ipairs(CFG.court_lines) do add(styled("Centered", { pandoc.Strong({ pandoc.Str(l) }) })) end
  add(styled("Centered", {}))
  for i, side in ipairs(meta.caption or {}) do
    for _, n in ipairs(side.names or {}) do add(styled("Centered", n)) end
    add(styled("Centered", side.designation))
    add(styled("Centered", {}))
    if i < #meta.caption then add(styled("Centered", { pandoc.Str("-against-") })) add(styled("Centered", {})) end
  end
  if meta.index_number then add(styled("Right", { pandoc.Str(plain(meta.index_number)) })) end
  add(styled("Centered", meta.proceeding or {}))
  add(styled("Centered", {}))
  add(styled("Centered", { pandoc.Strong(meta.brief_title or {}) }))
  add(styled("Centered", {}))
  for _, g in ipairs(meta.counsel or {}) do
    for _, n in ipairs(g.names or {}) do add(styled("Counsel", { pandoc.Strong(n) })) end
    for _, l in ipairs(g.lines or {}) do add(styled("Counsel", l)) end
    add(styled("Counsel", {}))
  end
  if meta.phone then add(styled("Counsel", meta.phone)) end
  add(section_break("decimal", nil, false))

  -- front matter: contents and authorities, roman page numbers
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("TABLE OF CONTENTS") }) }))
  add(styled("Centered", {}))
  local heads = toc_entries(doc.blocks)
  -- TOC field: cached entries (no page numbers until the field is updated; see the BLOCKED note)
  add(raw('<w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r></w:p>'))
  for _, h in ipairs(heads) do add(styled("Single", { pandoc.Str(h) })) end
  add(raw('<w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'))
  add(page_break())

  add(styled("Centered", { pandoc.Strong({ pandoc.Str("TABLE OF AUTHORITIES") }) }))
  add(styled("Centered", {}))
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auth) do
      if a.kind == g[1] and used[key] then members[#members + 1] = key end
    end
    if #members > 0 then
      table.sort(members, function(x, y)
        local ax = auth[x].sort and plain(auth[x].sort) or (plain(auth[x].name) .. " " .. plain(auth[x].cite))
        local ay = auth[y].sort and plain(auth[y].sort) or (plain(auth[y].name) .. " " .. plain(auth[y].cite))
        return ax:lower() < ay:lower()
      end)
      add(styled("Single", { pandoc.Strong({ pandoc.Str(g[2]) }) }))
      for _, k in ipairs(members) do
        local a = auth[k]
        local line = pandoc.List({})
        if a.name then
          local nm = a.name
          if g[1] == "case" then nm = { pandoc.Emph(nm) } end
          line:extend(nm)
          line:insert(pandoc.Str(","))
          line:insert(pandoc.LineBreak())
        end
        line:extend(a.cite)
        add(styled("Single", line))
      end
    end
  end
  add(section_break("decimal", "rId100", false))

  -- body: the markdown's own sections; the signature block follows the last paragraph
  local body = {}
  for _, b in ipairs(doc.blocks) do body[#body + 1] = b end
  addall(body)
  local sig = meta.signature
  if sig then
    add(styled("Single", { pandoc.Str("Respectfully submitted,") }))
    add(styled("Signature", { pandoc.Emph({ pandoc.Str("s/ " .. plain(sig.signer)) }) }))
    add(styled("Signature", { pandoc.Str(plain(sig.signer):upper()) }))
    for _, l in ipairs(sig.lines or {}) do add(styled("Signature", l)) end
    if meta.date then add(styled("Single", meta.date)) end
  end

  -- printing specifications statement (22 NYCRR 1250.8(j)); the count is the markdown body's count
  add(page_break())
  add(styled("Centered", { pandoc.Strong({ pandoc.Str("PRINTING SPECIFICATIONS STATEMENT") }) }))
  add(styled("Centered", {}))
  add(pandoc.Para({ pandoc.Str("This brief was prepared on a computer. The typeface is EB Garamond, 14 point. The body text is double-spaced. Headings, block quotations, and the tables are single-spaced. The brief contains " .. group_digits(words) .. " words, exclusive of the cover, the tables, the signature block, and any certificate of service (22 NYCRR 1250.8(f)(2), (j)).") }))

  doc.blocks = out
  return doc
end
